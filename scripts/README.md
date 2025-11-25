# Scripts Directory

This directory contains automation scripts for the Latency Hunter project.

---

## Available Scripts

### install.sh
**Purpose**: Automated installation of all project dependencies

**Requirements**:
- Ubuntu 22.04 LTS
- Sudo privileges
- Internet connectivity

**Usage**:
```bash
chmod +x scripts/install.sh
sudo ./scripts/install.sh
```

**What it does**:
- Updates system packages
- Installs Docker and Docker Compose
- Installs Containerlab
- Installs Python dependencies
- Configures system prerequisites
- Sets up directory permissions

**Duration**: 5-10 minutes (depending on internet speed)

---

### generate_microburst.py
**Purpose**: Generates controlled network traffic microbursts using iperf3

**Requirements**:
- Deployed Containerlab topology
- iperf3 server running on traffic-gen-2
- Python 3.10+

**Usage**:
```bash
# Basic burst
python3 scripts/generate_microburst.py --duration 200 --rate 8G

# Burst pattern
python3 scripts/generate_microburst.py --duration 200 --rate 8G --pattern 5 --interval 10

# TCP burst
python3 scripts/generate_microburst.py --duration 500 --rate 10G --protocol tcp

# Custom configuration
python3 scripts/generate_microburst.py \
  --duration 300 \
  --rate 5G \
  --protocol udp \
  --parallel 8 \
  --packet-size 1400
```

**Parameters**:
- `--duration`: Burst duration in milliseconds (default: 200)
- `--rate`: Target bandwidth (e.g., 8G, 10G, 500M) (default: 8G)
- `--protocol`: Transport protocol (udp or tcp) (default: udp)
- `--parallel`: Number of parallel streams (default: 4)
- `--packet-size`: Packet size in bytes (default: 1400)
- `--pattern`: Generate N bursts (optional)
- `--interval`: Seconds between bursts in pattern mode (default: 10)
- `--quiet`: Suppress detailed output

**Output**:
- Burst configuration details
- Real-time execution status
- Performance metrics (duration, throughput, data sent)
- JSON-formatted results (when available)

---

### cleanup.sh
**Purpose**: Destroys lab topology and cleans up Docker resources

**Requirements**:
- Sudo privileges (for Containerlab operations)

**Usage**:
```bash
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh
```

**What it does**:
- Destroys Containerlab topology
- Stops Docker Compose services
- Removes Docker containers
- Prunes Docker networks and volumes
- Optional: Complete Docker system cleanup

**Options**:
- Standard cleanup: Removes topology and services
- Complete cleanup: Also removes all Docker images (prompted)

---

### monitor_baseline.sh
**Purpose**: Real-time monitoring of network topology and traffic

**Requirements**:
- Deployed Containerlab topology
- Bash shell

**Usage**:
```bash
chmod +x scripts/monitor_baseline.sh
./scripts/monitor_baseline.sh
```

**What it displays**:
- Container status
- Network interface statistics
- Bridge status
- Connectivity test results
- iperf3 server status

**Controls**:
- Auto-refresh every 5 seconds
- Press Ctrl+C to exit

---

## Script Execution Order

### Initial Setup
```bash
# 1. Install dependencies
sudo ./scripts/install.sh

# 2. Deploy topology (from project root)
sudo containerlab deploy -t topology/latency-hunter.clab.yml

# 3. Start monitoring stack (from project root)
docker-compose -f docker-compose-simple.yml up -d

# 4. Start iperf3 server
docker exec -d clab-latency-hunter-traffic-gen-2 iperf3 -s
```

### Daily Operation
```bash
# Check system status
./scripts/monitor_baseline.sh

# Generate test burst
python3 scripts/generate_microburst.py --duration 200 --rate 8G
```

### Cleanup
```bash
# Clean up lab environment
./scripts/cleanup.sh
```

---

## Troubleshooting

### Script Permission Denied
```bash
chmod +x scripts/*.sh scripts/*.py
```

### Python Module Not Found
```bash
pip3 install -r requirements.txt --user
```

### Docker Permission Denied
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### iperf3 Connection Refused
```bash
docker exec clab-latency-hunter-traffic-gen-2 pkill -9 iperf3
docker exec -d clab-latency-hunter-traffic-gen-2 iperf3 -s
```

---

## Script Development

### Adding New Scripts

Follow these guidelines:
1. Use `#!/bin/bash` or `#!/usr/bin/env python3` shebang
2. Include header comment block with purpose and usage
3. Implement proper error handling
4. Use professional English
5. Add comprehensive inline comments
6. Make executable: `chmod +x script_name.sh`
7. Update this README

### Code Style

**Bash**:
- Use `set -e` for error handling
- Define color variables for output
- Create helper functions for common tasks
- Use descriptive variable names

**Python**:
- Follow PEP 8 style guide
- Use type hints where applicable
- Implement proper exception handling
- Add docstrings to all functions
- Use argparse for command-line arguments

---

## Additional Resources

- **Project Documentation**: See `../README.md`
- **Installation Guide**: See `../INSTALLATION.md`
- **Troubleshooting**: See `../docs/TROUBLESHOOTING.md`
- **Architecture**: See `../docs/ARCHITECTURE.md`

---

**Last Updated**: November 2025  
**Maintainer**: Latency Hunter Project
