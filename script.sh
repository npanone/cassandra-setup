#!/usr/bin/env bash

SEEDS=
LISTEN_ADDRESS=
RPC_ADDRESS=
CLUSTER_NAME=
DATACENTER_NAME=
RACK_NAME=

#*********************************************
#**       PROVIDE THE VARIABLES AVOVE       **
#*********************************************


echo "Updating... because you should!"
apt-get update -y

echo "Installing OpenSSH Server"
apt-get install -y openssh-server

echo "Enabling UFW"
ufw enable
echo "Allowing SSH"
ufw allow ssh
echo "Allowing Cassandra Default Ports"
ufw allow 7000
ufw allow 7001
ufw allow 7199
ufw allow 9042
ufw allow 9160
ufw allow 9142

echo "Installing JDK"
apt-get install -y default-jdk

echo "Adding DataStax Cassandra repo"
echo "deb http://debian.datastax.com/datastax-ddc 3.9 main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list

echo "Adding DataStax repo key"
curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -

echo "Install Cassandra"
apt-get update -y
apt-get install -y datastax-ddc


echo "Stop Cassandra and Clear the storage"
service cassandra stop
rm -rf /var/lib/cassandra/data/system/*


echo "Generating cassandra.yaml"
mv /etc/cassandra/cassandra.yaml /etc/cassandra/cassandra.yaml.original

cat << EOL | tee /etc/cassandra/cassandra.yaml
cluster_name: $CLUSTER_NAME
num_tokens: 256
allocate_tokens_for_keyspace: KEYSPACE
hinted_handoff_enabled: true
max_hint_window_in_ms: 10800000
hinted_handoff_throttle_in_kb: 1024
max_hints_delivery_threads: 2
hints_flush_period_in_ms: 10000
max_hints_file_size_in_mb: 128
batchlog_replay_throttle_in_kb: 1024
authenticator: AllowAllAuthenticator
authorizer: AllowAllAuthorizer
role_manager: CassandraRoleManager
roles_validity_in_ms: 2000
permissions_validity_in_ms: 2000
credentials_validity_in_ms: 2000
partitioner: org.apache.cassandra.dht.Murmur3Partitioner
data_file_directories:
    - /var/lib/cassandra/data
commitlog_directory: /var/lib/cassandra/commitlog
cdc_enabled: false
disk_failure_policy: stop
commit_failure_policy: stop
prepared_statements_cache_size_mb:
thrift_prepared_statements_cache_size_mb:
key_cache_size_in_mb:
key_cache_save_period: 14400
row_cache_size_in_mb: 0
row_cache_save_period: 0
counter_cache_size_in_mb:
counter_cache_save_period: 7200
saved_caches_directory: /var/lib/cassandra/saved_caches
commitlog_sync: periodic
commitlog_sync_period_in_ms: 10000
commitlog_segment_size_in_mb: 32
seed_provider:
  - class_name: org.apache.cassandra.locator.SimpleSeedProvider
    parameters:
         - seeds: $SEEDS
concurrent_reads: 32
concurrent_writes: 32
concurrent_counter_writes: 32
concurrent_materialized_view_writes: 32
memtable_allocation_type: heap_buffers
index_summary_capacity_in_mb:
index_summary_resize_interval_in_minutes: 60
trickle_fsync: false
trickle_fsync_interval_in_kb: 10240
storage_port: 7000
ssl_storage_port: 7001
listen_address: $LISTEN_ADDRESS
start_native_transport: true
native_transport_port: 9042
start_rpc: false
rpc_address: $RPC_ADDRESS
rpc_port: 9160
rpc_keepalive: true
rpc_server_type: sync
thrift_framed_transport_size_in_mb: 15
incremental_backups: false
snapshot_before_compaction: false
auto_snapshot: true
column_index_size_in_kb: 64
column_index_cache_size_in_kb: 2
compaction_throughput_mb_per_sec: 16
sstable_preemptive_open_interval_in_mb: 50
read_request_timeout_in_ms: 5000
range_request_timeout_in_ms: 10000
write_request_timeout_in_ms: 2000
counter_write_request_timeout_in_ms: 5000
cas_contention_timeout_in_ms: 1000
truncate_request_timeout_in_ms: 60000
request_timeout_in_ms: 10000
cross_node_timeout: false
endpoint_snitch: GossipingPropertyFileSnitch
dynamic_snitch_update_interval_in_ms: 100
dynamic_snitch_reset_interval_in_ms: 600000
dynamic_snitch_badness_threshold: 0.1
request_scheduler: org.apache.cassandra.scheduler.NoScheduler
server_encryption_options:
    internode_encryption: none
    keystore: conf/.keystore
    keystore_password: cassandra
    truststore: conf/.truststore
    truststore_password: cassandra
client_encryption_options:
    enabled: false
    optional: false
    keystore: conf/.keystore
    keystore_password: cassandra
internode_compression: dc
inter_dc_tcp_nodelay: false
tracetype_query_ttl: 86400
tracetype_repair_ttl: 604800
enable_user_defined_functions: false
enable_scripted_user_defined_functions: false
windows_timer_interval: 1
transparent_data_encryption_options:
    enabled: false
    chunk_length_kb: 64
    cipher: AES/CBC/PKCS5Padding
    key_alias: testing:1
    key_provider:
      - class_name: org.apache.cassandra.security.JKSKeyProvider
        parameters:
          - keystore: conf/.keystore
            keystore_password: cassandra
            store_type: JCEKS
            key_password: cassandra
tombstone_warn_threshold: 1000
tombstone_failure_threshold: 100000
batch_size_warn_threshold_in_kb: 5
batch_size_fail_threshold_in_kb: 50
unlogged_batch_across_partitions_warn_threshold: 10
compaction_large_partition_warning_threshold_mb: 100
gc_warn_threshold_in_ms: 1000
# max_value_size_in_mb: 256
EOL

echo "Generating cassandra-rackdc.properties"
mv /etc/cassandra/cassandra-rackdc.properties /etc/cassandra/cassandra-rackdc.properties.original
cat << EOL | tee /etc/cassandra/cassandra-rackdc.properties
dc=$DATACENTER_NAME
rack=$RACK_NAME
EOL

echo "Renaming cassandra-topology.properties => cassandra-topology.properties.original"
mv /etc/cassandra/cassandra-topology.properties /etc/cassandra/cassandra-topology.properties.original

echo "Starting cassandra"
service cassandra start
