# Technical Architecture

## System Overview

Latency Hunter is a network monitoring laboratory designed to detect microsecond-level traffic microbursts using modern streaming telemetry protocols. The system demonstrates high-frequency trading (HFT) monitoring techniques applicable to low-latency network environments.

---

## Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────────┐
│                          Ubuntu 22.04 LTS Host                         │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                    Containerlab Topology                          │ │
│  │                                                                   │ │
│  │  ┌─────────────────┐                    ┌─────────────────┐     │ │
│  │  │  traffic-gen-1  │                    │  traffic-gen-2  │     │ │
│  │  │   Alpine Linux  │                    │   Alpine Linux  │     │ │
│  │  │   10.0.1.11/24  │                    │   10.0.1.12/24  │     │ │
│  │  │   iperf3 client │                    │   iperf3 server │     │ │
│  │  └────────┬────────┘                    └────────┬────────┘     │ │
│  │           │ eth1                              eth1 │            │ │
│  │           │                                        │            │ │
│  │           │         ┌────────────────┐            │            │ │
│  │           └─────────┤   spine-01     ├────────────┘            │ │
│  │                eth1 │ Linux Bridge   │ eth2                    │ │
│  │                     │ 10.0.1.1/24    │                         │ │
│  │                     │  Alpine Linux  │                         │ │
│  │                     └────────────────┘                         │ │
│  │                                                                 │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                    Monitoring Stack (Docker)                      │ │
│  │                                                                   │ │
│  │  ┌─────────────────────────────────────────────────────────────┐ │ │
│  │  │  Grafana                                                     │ │ │
│  │  │  - Web UI: http://localhost:3000                            │ │ │
│  │  │  - Visualization Engine                                     │ │ │
│  │  │  - Dashboard Management                                     │ │ │
│  │  └───────────────────┬─────────────────────────────────────────┘ │ │
│  │                      │ Query (InfluxQL/Flux)                     │ │
│  │  ┌───────────────────▼─────────────────────────────────────────┐ │ │
│  │  │  InfluxDB 2.7                                                │ │ │
│  │  │  - Time Series Database                                      │ │ │
│  │  │  - Organization: latency-hunter                              │ │ │
│  │  │  - Bucket: network-telemetry                                 │ │ │
│  │  │  - Port: 8086                                                │ │ │
│  │  └──────────────────────────────────────────────────────────────┘ │ │
│  │                                                                   │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                    Management Network                             │ │
│  │            latency-hunter-mgmt (Docker Bridge)                    │ │
│  │                     172.20.20.0/24                                │ │
│  └──────────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Component Details

### Data Plane Network

#### Traffic Generator 1 (Client)
- **Container**: `clab-latency-hunter-traffic-gen-1`
- **Image**: `alpine:latest`
- **IP Address**: `10.0.1.11/24`
- **Role**: Traffic generation client
- **Software**: iperf3 client
- **Function**: Generates controlled network microbursts

#### Traffic Generator 2 (Server)
- **Container**: `clab-latency-hunter-traffic-gen-2`
- **Image**: `alpine:latest`
- **IP Address**: `10.0.1.12/24`
- **Role**: Traffic sink
- **Software**: iperf3 server (listening on port 5201)
- **Function**: Receives and measures traffic bursts

#### Spine Switch (Bridge)
- **Container**: `clab-latency-hunter-spine-01`
- **Image**: `alpine:latest`
- **IP Address**: `10.0.1.1/24`
- **Role**: Layer 2 network bridge
- **Interfaces**:
  - `eth1`: Connected to traffic-gen-1
  - `eth2`: Connected to traffic-gen-2
  - `br0`: Linux bridge interface
- **Configuration**:
  ```bash
  ip link add name br0 type bridge
  ip link set eth1 master br0
  ip link set eth2 master br0
  ip addr add 10.0.1.1/24 dev br0
  ```

### Management Plane Network

#### InfluxDB
- **Container**: `latency-hunter-influxdb`
- **Image**: `influxdb:2.7-alpine`
- **Port**: `8086`
- **Organization**: `latency-hunter`
- **Bucket**: `network-telemetry`
- **Token**: Configured via environment variable
- **Function**: Time-series data storage
- **Retention**: Configurable (default: infinite)

#### Grafana
- **Container**: `latency-hunter-grafana`
- **Image**: `grafana/grafana:10.2.0`
- **Port**: `3000`
- **Credentials**: `admin/admin`
- **Datasource**: InfluxDB (pre-provisioned)
- **Dashboards**: Pre-configured network monitoring dashboards
- **Function**: Data visualization and alerting

---

## Network Topology

### Data Plane (10.0.1.0/24)

| Node | IP Address | MAC Address | Interface |
|------|-----------|-------------|-----------|
| traffic-gen-1 | 10.0.1.11 | Auto-assigned | eth1 |
| traffic-gen-2 | 10.0.1.12 | Auto-assigned | eth1 |
| spine-01 (br0) | 10.0.1.1 | Auto-assigned | br0 |

### Management Plane (172.20.20.0/24)

| Service | IP Address | Port(s) | Protocol |
|---------|-----------|---------|----------|
| InfluxDB | Dynamic (Docker) | 8086 | HTTP |
| Grafana | Dynamic (Docker) | 3000 | HTTP |

---

## Data Flow

### Traffic Generation Flow

```
1. Python Script (generate_microburst.py)
   ↓ (Docker exec command)
2. Traffic Generator 1 Container
   ↓ (iperf3 UDP/TCP traffic)
3. Spine-01 Bridge (eth1 → br0 → eth2)
   ↓ (Layer 2 forwarding)
4. Traffic Generator 2 Container
   ↓ (iperf3 measurements)
5. Console Output (JSON results)
```

### Telemetry Flow (Production with gNMI Switch)

```
1. Switch (gNMI/gRPC streaming)
   ↓ (gRPC stream, port 6030)
2. Telegraf (gNMI input plugin)
   ↓ (Line Protocol over HTTP)
3. InfluxDB (time-series storage)
   ↓ (InfluxQL/Flux queries)
4. Grafana (visualization)
   ↓ (HTTP)
5. User Browser
```

**Note**: Current implementation uses Linux bridge (no gNMI support). Telemetry flow ready for gNMI-capable switch.

---

## Technology Stack

### Containerization Layer
- **Docker**: Container runtime
- **Docker Compose**: Multi-container orchestration
- **Containerlab**: Network topology orchestration
- **Alpine Linux**: Lightweight base image

### Network Layer
- **Linux Bridge**: Layer 2 switching
- **iperf3**: Traffic generation and measurement
- **iproute2**: Network configuration utilities

### Monitoring Layer
- **InfluxDB 2.7**: Time-series database
- **Grafana 10.2**: Visualization platform
- **Telegraf**: Metrics collection agent (configured, not active)

### Automation Layer
- **Python 3**: Scripting and automation
- **Bash**: System scripting
- **Infrastructure as Code**: Declarative topology files

---

## Deployment Architecture

### File System Layout

```
/home/user/latency-hunter/
├── configs/
│   ├── grafana/
│   │   ├── datasources/           # InfluxDB datasource config
│   │   ├── dashboards/            # Dashboard provisioning
│   │   └── dashboard-files/       # Dashboard JSON definitions
│   ├── telegraf/
│   │   └── telegraf.conf          # Telegraf configuration
│   └── switch/
│       └── arista-ceos.cfg        # cEOS configuration (reference)
├── data/
│   ├── grafana/                   # Grafana persistent storage
│   └── influxdb/                  # InfluxDB persistent storage
├── docs/
│   ├── ARCHITECTURE.md            # This document
│   ├── TROUBLESHOOTING.md         # Problem resolution
│   └── TECHNICAL_NOTES.md         # Additional technical details
├── scripts/
│   ├── install.sh                 # Automated installation
│   ├── generate_microburst.py     # Traffic burst generator
│   ├── cleanup.sh                 # Cleanup script
│   └── monitor_baseline.sh        # Real-time monitoring
├── topology/
│   └── latency-hunter.clab.yml    # Containerlab topology definition
├── docker-compose-simple.yml      # TIG stack orchestration
├── requirements.txt               # Python dependencies
└── README.md                      # Project documentation
```

---

## Security Considerations

### Network Isolation
- Data plane isolated from management plane
- Container network segregation via Docker networks
- No direct internet access for topology containers

### Credentials Management
- Default credentials provided for lab environment
- **Production**: Use strong passwords and secrets management
- **Production**: Enable TLS for Grafana and InfluxDB
- **Production**: Implement RBAC in Grafana

### Access Control
- Grafana: Username/password authentication
- InfluxDB: Token-based authentication
- Docker: User group membership required

---

## Scalability Considerations

### Current Implementation
- Single bridge switch
- 2 traffic generators
- Single InfluxDB instance
- Single Grafana instance

### Production Scaling
- **Horizontal**: Add multiple spine switches, leaf switches
- **Vertical**: Increase container resources
- **Geographic**: Deploy in multiple regions
- **Database**: InfluxDB clustering for high availability
- **Monitoring**: Multiple Grafana instances with load balancer

---

## Performance Characteristics

### Network Performance
- **Bandwidth**: Up to 10 Gbps per stream
- **Latency**: Sub-millisecond forwarding (bridge)
- **Burst Duration**: 50ms - 500ms
- **Packet Size**: 1400 bytes (default)
- **Parallel Streams**: 1-16 configurable

### Database Performance
- **Write Throughput**: Depends on gNMI metrics rate
- **Query Performance**: Sub-second for typical dashboards
- **Storage**: Approximately 1 GB/day for continuous telemetry
- **Retention**: Configurable (default: unlimited)

### System Requirements
- **CPU**: 4 cores minimum, 8 cores recommended
- **RAM**: 8 GB minimum, 16 GB recommended
- **Disk I/O**: SSD recommended for InfluxDB
- **Network**: 1 Gbps minimum, 10 Gbps for high-rate testing

---

## High Availability Considerations

### Single Points of Failure (Current)
- Single bridge switch
- Single InfluxDB instance
- Single Grafana instance

### HA Enhancements (Production)
- **Switch Redundancy**: Dual spine switches with MLAG
- **Database HA**: InfluxDB Enterprise clustering
- **Monitoring HA**: Multiple Grafana instances
- **Storage HA**: Persistent volumes with replication

---

## Monitoring and Observability

### System Monitoring
- Container resource usage via `docker stats`
- Host system metrics via `top/htop`
- Network statistics via `ip -s link`

### Application Monitoring
- iperf3 output (bandwidth, jitter, packet loss)
- Docker logs for all containers
- Grafana dashboard metrics (when switch supports gNMI)

### Logging
- Docker container logs: `docker logs <container>`
- Containerlab logs: stdout during deployment
- Application logs: Container-specific stdout/stderr

---

## Integration Points

### External Systems
- **Git Repository**: Version control for configurations
- **CI/CD Pipeline**: Automated deployment and testing
- **Monitoring Aggregation**: Export to centralized monitoring
- **Alerting**: Integration with PagerDuty, Slack, etc.

### API Access
- **InfluxDB API**: HTTP REST API for data access
- **Grafana API**: HTTP REST API for dashboard management
- **Docker API**: Container management and monitoring

---

## Technical Limitations

### Current Implementation
1. **Switch Telemetry**: Linux bridge does not support gNMI/gRPC streaming
2. **Metrics Collection**: Telegraf disabled due to lack of telemetry source
3. **Visualization**: Grafana displays "No Data" (expected behavior)
4. **Scale**: Limited to small topology (educational/demonstration)

### Production Requirements
1. **Switch**: gNMI-capable switch (Arista cEOS-lab, physical Arista switch)
2. **Streaming Telemetry**: gRPC streaming at 5-10 second intervals
3. **Performance**: Physical hardware for production workloads
4. **Redundancy**: HA configuration for critical components

---

## Future Enhancements

### Short-Term
- Deploy with actual Arista cEOS switch
- Enable gNMI streaming telemetry
- Activate Telegraf metrics collection
- Populate Grafana dashboards with live data

### Medium-Term
- Implement P4-based in-band telemetry (INT)
- Add DPDK for kernel bypass traffic generation
- Integrate PTP (IEEE 1588) time synchronization
- Implement automated alerting

### Long-Term
- Multi-datacenter topology
- eBPF-based packet analysis
- Machine learning anomaly detection
- Integration with commercial NMS platforms

---

## Design Decisions

### Why Linux Bridge Instead of cEOS?
- **Compatibility**: cEOS Docker image compatibility issues in test environment
- **Simplicity**: Linux bridge provides functional Layer 2 forwarding
- **Educational**: Demonstrates network fundamentals
- **Future-Ready**: Infrastructure configured for easy cEOS integration

### Why TIG Stack?
- **Industry Standard**: Widely used in production environments
- **Scalability**: Proven performance for high-volume metrics
- **Flexibility**: Extensive plugin ecosystem
- **Visualization**: Grafana's powerful query and dashboard capabilities

### Why Containerlab?
- **Declarative**: Infrastructure as Code approach
- **Reproducible**: Identical deployments across systems
- **Automation**: CLI-driven deployment and destruction
- **Community**: Active development and support

---

## References

### Technical Documentation
- [Containerlab Documentation](https://containerlab.dev)
- [InfluxDB 2.x Documentation](https://docs.influxdata.com/influxdb/v2.7/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Linux Bridge Documentation](https://wiki.linuxfoundation.org/networking/bridge)

### Protocol Specifications
- [gNMI Specification](https://github.com/openconfig/gnmi)
- [gRPC Documentation](https://grpc.io/docs/)
- [OpenConfig Models](https://github.com/openconfig/public)

### Related Projects
- [Arista cEOS Documentation](https://www.arista.com/en/support/software-download)
- [iperf3 Documentation](https://iperf.fr/)
- [Telegraf Documentation](https://docs.influxdata.com/telegraf/)

---

**End of Architecture Documentation**
