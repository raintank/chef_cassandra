CREATE KEYSPACE IF NOT EXISTS raintank WITH replication = {'class': 'NetworkTopologyStrategy', 'us-central1': '2'}  AND durable_writes = true;

CREATE TABLE IF NOT EXISTS raintank.metric (
    key ascii,
    ts int,
    data blob,
    PRIMARY KEY (key, ts)
) WITH CLUSTERING ORDER BY (ts DESC)
    AND compaction = {'class': 'org.apache.cassandra.db.compaction.TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': '1' }
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'};
