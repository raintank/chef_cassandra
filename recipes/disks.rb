#
# Cookbook Name:: chef_cassandra
# Recipe:: disks
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

unless node[:chef_base][:is_img_build]
  include_recipe "lvm"
end

group "cassandra" do
  system true
  action :create
end
user "cassandra" do
  system true
  gid "cassandra"
  home "/var/lib/cassandra"
  action :create
end

directory "/var/lib/cassandra" do
  owner "cassandra"
  group "cassandra"
  mode "0755"
  action :create
end

directory "/var/lib/cassandra/commitlog" do
  owner "cassandra"
  group "cassandra"
  mode "0755"
  action :create
end

unless node[:chef_base][:is_img_build]
  lvm_volume_group 'cassandra00' do
    physical_volumes [ node['chef_cassandra']['cassandra_disk'] ] 

    logical_volume 'cassandra' do
      size        '100%VG'
      filesystem  'ext4'
      stripes     1
    end
  end
  mount '/var/lib/cassandra' do
    device '/dev/mapper/cassandra00-cassandra'
    fstype 'ext4'
    options 'noatime,nodiratime'
    action [:mount,:enable]
  end
  directory "/var/lib/cassandra" do
    owner "cassandra"
    group "cassandra"
    mode "0755"
    action :create
  end
  lvm_volume_group 'cassandra01' do
    physical_volumes [ node['chef_cassandra']['cassandra_commit_disk'] ]
    logical_volume 'cassandra-commit' do
      size '100%VG'
      filesystem 'ext4'
      stripes 1
    end
  end
  directory "/var/lib/cassandra/commitlog" do
    owner "cassandra"
    group "cassandra"
    mode "0755"
    action :create
  end
  mount '/var/lib/cassandra/commitlog' do
    device '/dev/mapper/cassandra01-cassandra--commit'
    fstype 'ext4'
    options 'noatime,nodiratime'
    action [:mount,:enable]
  end
end
