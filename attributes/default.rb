default[:raintank_cassandra][:cluster_name] = "Test Cluster"
default[:raintank_cassandra][:num_tokens] = 256
default[:raintank_cassandra][:seeds] = []
default[:raintank_cassandra][:listen_interface] = "eth0"
default[:raintank_cassandra][:rpc_address] = "0.0.0.0"
default[:raintank_cassandra][:broadcast_rpc_address] = node.ipaddress
default[:raintank_cassandra][:snitch] = "SimpleSnitch"
default[:raintank_cassandra][:concurrent_reads] = 8 * node.cpu.total
default[:raintank_cassandra][:concurrent_writes] = 8 * node.cpu.total
default[:raintank_cassandra][:search] = "tags:cassandra AND chef_environment:#{node.chef_environment}"
default[:raintank_cassandra][:cassandra_disk] = "/dev/sdb"
default[:raintank_cassandra][:cassandra_commit_disk] = "/dev/sdc"
default[:raintank_cassandra][:cron_mailto] = "root@localhost"

default[:java][:install_flavor] = "oracle"
default[:java][:jdk_version] = "8"
default[:java][:oracle][:accept_oracle_download_terms] = true
