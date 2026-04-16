# Redis

**English** | [中文](README_zh.md)

In-memory data structure store for Kubernetes with cluster, sentinel, and proxy deployment modes.

## Overview

Redis is an open-source, in-memory data structure store that can serve as a database, cache, and message broker. This package delivers an enterprise-grade Redis deployment on Kubernetes, supporting multiple data structures, persistence, cluster mode, sentinel mode, and proxy-based load balancing. Redis is renowned for its high performance, rich data types, and atomic operations, and is widely used for caching, session storage, real-time analytics, and message queuing.

## Features

### Core Capabilities
- **Rich data structures**: Strings, hashes, lists, sets, sorted sets, bitmaps, HyperLogLog, geospatial indexes, and more
- **High performance**: In-memory operations with high-concurrency read/write support
- **Persistence**: RDB snapshots and AOF (Append Only File) journaling
- **Atomic operations**: Transactions, Lua scripting, and atomic counters
- **Expiration policies**: TTL-based key expiry and eviction strategies
- **Pub/Sub**: Publish-subscribe messaging pattern

### Enterprise Features
- **Cluster mode**: Redis Cluster for distributed sharding
- **Sentinel mode**: Redis Sentinel for high-availability failover
- **Proxy mode**: Predixy proxy for load balancing
- **Monitoring and alerting**: Integrated Prometheus metrics and alert rules
- **Log management**: Structured log output and log rotation
- **External access**: NodePort and Traefik-based external exposure

### Operations Features
- **Resource management**: CPU and memory resource limits
- **Node affinity**: Pod anti-affinity and node affinity configuration
- **Tolerations**: Taint toleration settings
- **Health checks**: Built-in liveness and readiness probes
- **Metrics export**: Prometheus-format metrics
- **Graceful shutdown**: Graceful termination support

### Advanced Features
- **Data sharding**: Automatic data partitioning in cluster mode
- **Automatic failover**: Sentinel-driven failover
- **Read-write splitting**: Primary-replica replication with read-write separation
- **Connection pooling**: Connection pool management
- **Slow query logging**: Slow query log and analysis
- **Memory optimization**: Memory optimization and eviction policies

## Supported Versions

### Redis Releases
- **8.2.3** (latest, recommended)
- **8.0.4**
- **7.4.6**
- **7.2.11**
- **7.2.4**

### Component Releases
- **Redis Operator**: v1alpha1
- **Redis Init**: v1.7.3
- **Redis Exporter**: v1.0.5-1.0.0
- **Logrotate**: 3.21.0-1.0.0

## Architecture

### Deployment Modes

#### 1. Standard (operator-standard)
- **Use cases**: Development, testing, and quick deployment
- **Replicas**: 1
- **Traits**: Minimal resource footprint, simple deployment

#### 2. Highly Available (operator-highly-available)
- **Use cases**: Production workloads
- **Replicas**: 3
- **Traits**: High availability with automatic failover

#### 3. Cluster (cluster)
- **Use cases**: Large-scale data storage and high-concurrency access
- **Replicas**: Configurable (6+ recommended)
- **Traits**: Data sharding, high availability, high performance

#### 4. Sentinel (sentinel)
- **Use cases**: High-availability primary-replica replication
- **Redis replicas**: Configurable (2+ recommended)
- **Sentinel replicas**: Configurable (3+ recommended)
- **Traits**: Automatic failover, read-write splitting

### Technical Architecture

```
+---------------------------------------------------------+
|                    Redis Architecture                   |
+---------------------------------------------------------+
|  Cluster Mode                                           |
|  +-----------+  +-----------+  +-----------+            |
|  |  Master   |  |  Master   |  |  Master   |            |
|  |  Shard 0  |  |  Shard 1  |  |  Shard 2  |            |
|  | +-------+ |  | +-------+ |  | +-------+ |            |
|  | |Slave 0| |  | |Slave 1| |  | |Slave 2| |            |
|  | +-------+ |  | +-------+ |  | +-------+ |            |
|  +-----------+  +-----------+  +-----------+            |
+---------------------------------------------------------+
|  Sentinel Mode                                          |
|  +-----------+  +-----------+  +-----------+            |
|  |  Master   |  |  Slave 1  |  |  Slave 2  |            |
|  +-----------+  +-----------+  +-----------+            |
|  +-----------+  +-----------+  +-----------+            |
|  | Sentinel  |  | Sentinel  |  | Sentinel  |            |
|  |     1     |  |     2     |  |     3     |            |
|  +-----------+  +-----------+  +-----------+            |
+---------------------------------------------------------+
|  Predixy Proxy Layer                                    |
|  +-----------+  +-----------+  +-----------+            |
|  |  Predixy  |  |  Predixy  |  |  Predixy  |            |
|  |  Proxy 1  |  |  Proxy 2  |  |  Proxy 3  |            |
|  +-----------+  +-----------+  +-----------+            |
+---------------------------------------------------------+
|  Redis Operator                                         |
|  +-----------+  +-----------+  +-----------+            |
|  |  Manager  |  |Controller |  |  Webhook  |            |
|  +-----------+  +-----------+  +-----------+            |
+---------------------------------------------------------+
|                 Kubernetes Resources                    |
|  * StatefulSet (Redis nodes)                            |
|  * Service (service discovery)                          |
|  * PersistentVolumeClaim (data persistence)             |
|  * ConfigMap (configuration management)                 |
|  * Secret (authentication credentials)                  |
|  * Job (initialization tasks)                           |
+---------------------------------------------------------+
```

### Component Overview

- **Redis Server**: Core in-memory data store engine
- **Redis Operator**: Cluster lifecycle management controller (Manager, Controller, Webhook)
- **Predixy**: High-performance proxy for load balancing and unified access
- **Redis Exporter**: Prometheus metrics collector
- **Logrotate**: Log rotation management

### Resource Requirements

#### Operator
- **CPU limit**: 200m / **CPU request**: 100m
- **Memory limit**: 512Mi / **Memory request**: 256Mi

#### Redis Node (default)
- **CPU limit**: 2 cores / **CPU request**: 2 cores
- **Memory limit**: 4Gi / **Memory request**: 4Gi

#### Sentinel Node (default)
- **CPU limit**: 1 core / **CPU request**: 1 core
- **Memory limit**: 4Gi / **Memory request**: 4Gi

## Prerequisites

- Kubernetes 1.26+
- [OpenSaola Operator](https://github.com/harmonycloud/opensaola) deployed
- [saola-cli](https://github.com/harmonycloud/saola-cli) installed

## Quick Start

```bash
# Publish the package
saola publish redis/

# Install the operator
saola operator create redis-operator --type Redis --version 8.2.3

# Create an instance
saola middleware create my-redis --type Redis --version 8.2.3

# Check status
saola middleware get my-redis
```

## Available Actions

| Action | Description |
|--------|-------------|
| restart | Restart the middleware instance |
| scale | Scale the number of Redis replicas |
| migrate | Migrate nodes to different Kubernetes nodes |
| datasecurity | Manage data security settings |
| setParameters | Modify runtime configuration parameters |
| expose-cluster-external | Expose the cluster for external access |
| expose-proxy | Expose the Predixy proxy endpoint |
| expose-sentinel-external | Expose sentinel for external access |
| expose-sentinel-readonly | Expose a read-only sentinel endpoint |
| expose-sentinel-readwrite | Expose a read-write sentinel endpoint |

## Configuration

Key parameters can be customized via the baseline configuration. See `manifests/*parameters.yaml` for the full parameter reference.

### Resource Planning

```yaml
# Recommended production settings
resources:
  redis:
    limits:
      cpu: "4"
      memory: "8Gi"
    requests:
      cpu: "2"
      memory: "4Gi"
    replicas: 6  # 6+ nodes recommended for cluster mode
    volume:
      size: 100  # GB
      storageClass: "fast-ssd"
```

### Key Monitoring Metrics

- **Node status**: `redis_up`
- **Connected clients**: `redis_connected_clients`
- **Memory usage**: `redis_memory_used_bytes`
- **Commands processed**: `redis_commands_processed_total`
- **Slow queries**: `redis_slowlog_length`
- **Replication**: `redis_connected_slaves`

## Usage Guidance

### Environment Selection

#### Development and Test
- Use the **Standard** baseline
- Single-node deployment with reduced resources
- Suitable for functional verification and development

#### Production
- **Small-scale applications**: Use **Sentinel** mode
- **Large-scale applications**: Use **Cluster** mode
- **High-concurrency scenarios**: Use **Cluster** mode with Predixy proxy
- At least 3-node deployment
- Configure Pod anti-affinity to spread nodes across hosts
- Enable monitoring and alerting

### Best Practices

#### Security
- Set strong passwords
- Configure ACL permissions
- Restrict network access
- Rotate credentials periodically
- Use TLS encryption in production

#### Performance Tuning
- Set appropriate `maxmemory` and eviction policies
- Avoid large keys and hot keys
- Use connection pooling and pipelining to reduce latency
- Batch operations to minimize network round trips
- Choose between RDB and AOF persistence based on workload

#### Operations
- Routinely check cluster status and node health
- Configure automatic failover
- Monitor storage usage and plan capacity
- Define log rotation policies to prevent disk saturation
- Schedule regular data backups

### Typical Use Cases

- **Caching**: Application data caching
- **Session storage**: User session management
- **Counters**: Visit statistics, rate limiting
- **Leaderboards**: Gaming rankings, trending content
- **Message queuing**: Asynchronous task processing
- **Real-time analytics**: Real-time data processing

### Important Notes

1. **Cluster sizing**: Production environments recommend at least 6 nodes
2. **Memory planning**: Size memory according to the data volume
3. **Persistence**: Critical data must have persistence configured
4. **Version compatibility**: Ensure client and server versions are compatible
5. **Authentication**: Production environments must enable authentication
6. **Log management**: Configure log rotation to prevent disk exhaustion

## Related Projects

| Project | Description |
|---------|-------------|
| [OpenSaola Operator](https://github.com/harmonycloud/opensaola) | Core Kubernetes operator for middleware lifecycle management |
| [saola-cli](https://github.com/harmonycloud/saola-cli) | Command-line tool for middleware management |
| [PostgreSQL](https://github.com/harmonycloud/postgresql) | PostgreSQL database package |
| [MySQL](https://github.com/harmonycloud/mysql) | MySQL database package |
| [Kafka](https://github.com/harmonycloud/kafka) | Apache Kafka streaming platform package |
| [Elasticsearch](https://github.com/harmonycloud/elasticsearch) | Elasticsearch search engine package |
| [ZooKeeper](https://github.com/harmonycloud/zookeeper) | Apache ZooKeeper coordination service package |
| [RabbitMQ](https://github.com/harmonycloud/rabbitmq) | RabbitMQ message broker package |

## License

This project is licensed under the [Apache License 2.0](LICENSE).
