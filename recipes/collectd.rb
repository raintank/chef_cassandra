#
# Cookbook Name:: chef_cassandra
# Recipe:: collectd
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

node.set["collectd_personality"] = "cassandra"
if node['use_collectd'] && node['collectd']['java_plugins']['cassandra']
  node.set['collectd']['java_plugins']['cassandra']['config']['connection']['Host'] = node.name.sub /\.raintank\.io$/, ''
end

include_recipe "chef_base::collectd"
