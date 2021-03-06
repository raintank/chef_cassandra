#
# Cookbook Name:: chef_cassandra
# Recipe:: install
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

include_recipe "apt"
include_recipe "java"

apt_repository 'cassandra' do
  uri 'http://debian.datastax.com/community'
  distribution 'stable'
  components [ 'main' ]
  key 'http://debian.datastax.com/debian/repo_key'
end

package 'cassandra' do
  version node['chef_cassandra']['version']
  action :install
end
package 'cassandra-tools' do
  version node['chef_cassandra']['version']
  action :install
end
package 'dsc30' do
  version node['chef_cassandra']['dsc_version']
  action :install
end

service 'cassandra' do
  action :nothing
end

seeds = if Chef::Config[:solo]
    node[:chef_cassandra][:seeds].join(",") # todo: search for
  else
    s = search("node", node['chef_cassandra']['search']).map { |c| c.fqdn } || node[:chef_cassandra][:seeds]
    s.join(",")
  end

auto_bootstrap = seeds != ""

template "/etc/cassandra/cassandra.yaml" do
  source "cassandra.yaml.erb"
  mode "0644"
  owner "root"
  group "root"
  action :create
  variables({
    :cluster_name => node['chef_cassandra']['cluster_name'],
    :num_tokens => node['chef_cassandra']['num_tokens'],
    :seeds => seeds,
    :listen_interface => node['chef_cassandra']['listen_interface'],
    :rpc_address => node['chef_cassandra']['rpc_address'],
    :broadcast_rpc_address => node['chef_cassandra']['broadcast_rpc_address'],
    :snitch => node['chef_cassandra']['snitch'],
    :concurrent_reads => node['chef_cassandra']['concurrent_reads'],
    :concurrent_writes => node['chef_cassandra']['concurrent_writes'],
    :auto_bootstrap => auto_bootstrap
  })
  notifies :restart, 'service[cassandra]', :immediately
end

service 'cassandra' do
  action [ :enable, :start ]
end

include_recipe "logrotate"
logrotate_app "cassandra" do
  path "/var/log/cassandra/system.log"
  frequency "daily"
  create "644 cassandra cassandra"
  rotate 7
  enable false
end

if node["platform"] == "ubuntu" && node["platform_version"].to_f >= 16.04
  bash 'install_cassandra_driver' do
    cwd '/tmp'
    code "pip install cassandra-driver"
  end
  file "/etc/profile.d/Z99-csqlsh.sh" do
    mode "0644"
    owner "root"
    group "root"
    content "export CQLSH_NO_BUNDLED=TRUE\n"
  end
end

tag("cassandra")
