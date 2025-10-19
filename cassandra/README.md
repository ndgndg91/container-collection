# Cassandra Cluster

This directory contains a Docker Compose setup for a 3-node Cassandra cluster.

## Usage

To start the cluster, run:

```bash
./run.sh
```

To stop the cluster, run:

```bash
./down.sh
```

Each node exposes the CQL port to the host machine:

- **cassandra-1**: `localhost:9042`
- **cassandra-2**: `localhost:9043`
- **cassandra-3**: `localhost:9044`
