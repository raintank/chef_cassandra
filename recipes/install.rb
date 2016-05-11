#
# Cookbook Name:: raintank_cassandra
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
  version '2.2.3'
  action :install
end
package 'cassandra-tools' do
  version '2.2.3'
  action :install
end
package 'dsc22' do
  version '2.2.3-1'
  action :install
end

service 'cassandra' do
  action [ :enable, :start ]
end

seeds = if Chef::Config[:solo]
    node[:raintank_cassandra][:seeds].join(",") # todo: search for
  else
    s = search("node", node['raintank_cassandra']['search']).map { |c| c.fqdn } || node[:raintank_cassandra][:seeds]
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
    :cluster_name => node['raintank_cassandra']['cluster_name'],
    :num_tokens => node['raintank_cassandra']['num_tokens'],
    :seeds => seeds,
    :listen_interface => node['raintank_cassandra']['listen_interface'],
    :rpc_address => node['raintank_cassandra']['rpc_address'],
    :broadcast_rpc_address => node['raintank_cassandra']['broadcast_rpc_address'],
    :snitch => node['raintank_cassandra']['snitch'],
    :concurrent_reads => node['raintank_cassandra']['concurrent_reads'],
    :concurrent_writes => node['raintank_cassandra']['concurrent_writes'],
    :auto_bootstrap => auto_bootstrap
  })
  notifies :restart, 'service[cassandra]', :immediately
end

include_recipe "logrotate"
logrotate_app "cassandra" do
  path "/var/log/cassandra/system.log"
  frequency "daily"
  create "644 cassandra cassandra"
  rotate 7
  enable false
end

tag("cassandra")
