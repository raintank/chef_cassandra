#
# Cookbook Name:: raintank_cassandra
# Recipe:: snapshotter
#
# Copyright (C) 2016 Raintank, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unless node[:raintank_base][:is_img_build]
  s3creds = Chef::EncryptedDataBagItem.load(:s3credentials, node.chef_environment).to_hash
  directory "/var/lib/cassandra/.ssh" do
    owner "cassandra"
    group "cassandra"
    mode "0700"
    action :create
  end

  file "/var/lib/cassandra/.ssh/authorized_keys" do
    content s3creds['id_rsa_pub']
    owner "cassandra"
    group "cassandra"
    mode "0755"
    action :create
  end
end

package 'python-pip'
package 'python-dev'

bash 'install_cassandra_snapshotter' do
  cwd "/tmp"
  code "pip install pip==7.1.2; pip install cassandra_snapshotter"
end
package "lzop"

cron "cassandra_clear_snapshots" do
  action :create
  minute '0'
  hour '5'
  user 'root'
  mailto node['raintank_cassandra']['cron_mailto']
  command %Q(/usr/bin/nice -n 15 /usr/bin/find /var/lib/cassandra/data/*/*/snapshots -type f -mtime +8 -delete)
end

cron "cassandra_clear_backups" do
  action :create
  minute '10'
  hour '5'
  user 'root'
  mailto node['raintank_cassandra']['cron_mailto']
  command %Q(/usr/bin/nice -n 15 /usr/bin/find /var/lib/cassandra/data/*/*/backups -type f -mtime +8 -delete)
end
