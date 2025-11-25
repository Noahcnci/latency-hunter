# Troubleshooting Guide

## Overview

This document provides solutions to common issues encountered during installation, deployment, and operation of Latency Hunter.

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Docker Issues](#docker-issues)
3. [Containerlab Issues](#containerlab-issues)
4. [Network Connectivity Issues](#network-connectivity-issues)
5. [Traffic Generation Issues](#traffic-generation-issues)
6. [Monitoring Stack Issues](#monitoring-stack-issues)
7. [Performance Issues](#performance-issues)

---

## Installation Issues

### Issue: Docker GPG Key Error

**Symptom:**
```
GPG error: ... NO_PUBKEY 7EA0A9C3F273FCD8
E: The repository ... is not signed
```

**Root Cause:**  
Old or misconfigured Docker repository in APT sources.

**Solution 1: Automated Fix (Recommended)**
```bash
sudo rm /etc/apt/sources.list.d/docker.list 2>/dev/null || true
sudo apt-get update
sudo ./scripts/install.sh
```

**Solution 2: Manual Fix**
```bash
# Remove old Docker repository files
sudo rm /etc/apt/sources.list.d/docker.list
sudo rm /etc/apt/sources.list.d/docker.list.save

# Clean APT cache
sudo apt-get clean
sudo apt-get update

# Re-run installation
sudo ./scripts/install.sh
```

**Verification:**
```bash
sudo apt-get update
# Should complete without errors
```

---

### Issue: Permission Denied During Installation

**Symptom:**
```
Permission denied
```

**Root Cause:**  
Installation script not run with sudo privileges.

**Solution:**
```bash
sudo ./scripts/install.sh
```

---

### Issue: Network Timeout During Package Download

**Symptom:**
```
Failed to fetch ... Connection timed out
```

**Root Cause:**  
Network connectivity issues or firewall restrictions.

**Solution:**
```bash
# Test internet connectivity
ping -c 3 google.com

# Check DNS resolution
nslookup google.com

# If behind proxy, configure APT proxy
sudo nano /etc/apt/apt.conf.d/proxy.conf
# Add: Acquire::http::Proxy "http://proxy:port";

# Retry installation
sudo ./scripts/install.sh
```

---

## Docker Issues

### Issue: Docker Permission Denied

**Symptom:**
```
Got permission denied while trying to connect to the Docker daemon socket
```

**Root Cause:**  
User not in docker group.

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Verify
docker ps
```

**Alternative (temporary):**
```bash
# Use sudo (not recommended for regular use)
sudo docker ps
```

**Persistent Solution:**
```bash
# Logout and login again
logout
# Or reboot
sudo reboot
```

---

### Issue: Docker Service Not Running

**Symptom:**
```
Cannot connect to the Docker daemon. Is the docker daemon running?
```

**Root Cause:**  
Docker service stopped or failed to start.

**Solution:**
```bash
# Check Docker service status
sudo systemctl status docker

# Start Docker service
sudo systemctl start docker

# Enable Docker on boot
sudo systemctl enable docker

# Verify
docker ps
```

---

### Issue: Docker Compose Command Not Found

**Symptom:**
```
docker compose: command not found
```

**Root Cause:**  
Docker Compose plugin not installed, or using wrong command syntax.

**Solution 1: Use docker-compose (hyphenated)**
```bash
docker-compose --version
docker-compose -f docker-compose-simple.yml up -d
```

**Solution 2: Install docker-compose**
```bash
sudo apt-get install -y docker-compose
docker-compose --version
```

**Solution 3: Install Docker Compose plugin**
```bash
sudo apt-get install -y docker-compose-plugin
docker compose version
```

---

## Containerlab Issues

### Issue: Containerlab Command Not Found

**Symptom:**
```
containerlab: command not found
```

**Root Cause:**  
Containerlab not installed or not in PATH.

**Solution:**
```bash
# Install Containerlab
bash -c "$(curl -sL https://get.containerlab.dev)"

# Verify installation
sudo containerlab version

# Check PATH
echo $PATH | grep /usr/local/bin
```

---

### Issue: Containerlab Deployment Fails

**Symptom:**
```
Error: failed to create container: ...
```

**Root Cause:**  
Various potential causes (Docker issues, image problems, network conflicts).

**Solution:**
```bash
# Destroy any existing topology
sudo containerlab destroy -a

# Clean up Docker networks
docker network prune -f

# Redeploy
sudo containerlab deploy -t topology/latency-hunter.clab.yml

# Check logs
docker logs clab-latency-hunter-spine-01
docker logs clab-latency-hunter-traffic-gen-1
docker logs clab-latency-hunter-traffic-gen-2
```

---

### Issue: Network Already Exists

**Symptom:**
```
Error: network with name latency-hunter-mgmt already exists
```

**Root Cause:**  
Previous deployment not properly cleaned up.

**Solution:**
```bash
# Destroy existing topology
sudo containerlab destroy -a

# Remove network manually if needed
docker network rm latency-hunter-mgmt

# Redeploy
sudo containerlab deploy -t topology/latency-hunter.clab.yml
```

---

## Network Connectivity Issues

### Issue: Ping Test Fails (100% Packet Loss)

**Symptom:**
```bash
docker exec clab-latency-hunter-traffic-gen-1 ping -c 3 10.0.1.12
# 100% packet loss
```

**Root Cause:**  
Bridge not configured properly, interfaces not up, or routing issues.

**Solution 1: Verify Bridge Configuration**
```bash
# Check bridge on spine-01
docker exec clab-latency-hunter-spine-01 ip link show br0
docker exec clab-latency-hunter-spine-01 ip addr show br0

# Verify interfaces in bridge
docker exec clab-latency-hunter-spine-01 ip link | grep "eth"
```

**Solution 2: Restart Topology**
```bash
sudo containerlab destroy -a
sudo containerlab deploy -t topology/latency-hunter.clab.yml
```

**Solution 3: Manual Bridge Reconfiguration**
```bash
docker exec clab-latency-hunter-spine-01 sh -c '
  ip link set br0 down
  ip link delete br0
  ip link add name br0 type bridge
  ip link set br0 up
  ip addr add 10.0.1.1/24 dev br0
  ip link set eth1 master br0
  ip link set eth2 master br0
  ip link set eth1 up
  ip link set eth2 up
'

# Test again
docker exec clab-latency-hunter-traffic-gen-1 ping -c 3 10.0.1.12
```

---

### Issue: Cannot Reach Management Network

**Symptom:**
```
Cannot access Grafana at http://VM-IP:3000
```

**Root Cause:**  
Firewall blocking ports, or service not bound to correct interface.

**Solution:**
```bash
# Check if port is listening
sudo netstat -tulpn | grep 3000

# Check Docker port mapping
docker ps | grep grafana

# Test from VM
curl http://localhost:3000

# If firewall issue, allow port
sudo ufw allow 3000/tcp
sudo ufw allow 8086/tcp  # InfluxDB

# Verify firewall rules
sudo ufw status
```

---

## Traffic Generation Issues

### Issue: iperf3 Connection Refused

**Symptom:**
```
iperf3: error - unable to connect to server: Connection refused
```

**Root Cause:**  
iperf3 server not running on traffic-gen-2.

**Solution:**
```bash
# Kill any stuck iperf3 processes
docker exec clab-latency-hunter-traffic-gen-2 pkill -9 iperf3

# Start iperf3 server
docker exec -d clab-latency-hunter-traffic-gen-2 iperf3 -s

# Verify server is running
docker exec clab-latency-hunter-traffic-gen-2 ps aux | grep iperf3

# Test connection
docker exec clab-latency-hunter-traffic-gen-1 iperf3 -c 10.0.1.12 -t 1
```

---

### Issue: Server Busy Running Test

**Symptom:**
```
iperf3: error - the server is busy running a test. try again later
```

**Root Cause:**  
Previous test still running or not properly terminated.

**Solution:**
```bash
# Kill all iperf3 processes on both nodes
docker exec clab-latency-hunter-traffic-gen-1 pkill -9 iperf3
docker exec clab-latency-hunter-traffic-gen-2 pkill -9 iperf3

# Restart server
docker exec -d clab-latency-hunter-traffic-gen-2 iperf3 -s

# Wait a moment
sleep 2

# Retry test
python3 scripts/generate_microburst.py --duration 200 --rate 8G
```

---

### Issue: Python Script Import Error

**Symptom:**
```
ModuleNotFoundError: No module named 'xxx'
```

**Root Cause:**  
Python dependencies not installed.

**Solution:**
```bash
# Install requirements
pip3 install -r requirements.txt --user

# Verify installation
pip3 list | grep argparse

# Retry script
python3 scripts/generate_microburst.py --help
```

---

### Issue: Timeout During Burst Generation

**Symptom:**
```
subprocess.TimeoutExpired
```

**Root Cause:**  
Expected behavior for bursts < 1 second. iperf3 doesn't handle sub-second durations well.

**Solution:**  
This is normal and handled by the script. The burst is actually sent successfully.

**Verification:**
Check script output:
```
[STATUS] Burst completed (forced timeout)
Note: Timeout forced termination (normal for bursts < 1s)
```

---

## Monitoring Stack Issues

### Issue: Grafana Permission Denied

**Symptom:**
```
GF_PATHS_DATA='/var/lib/grafana' is not writable
Permission denied
```

**Root Cause:**  
Incorrect permissions on data directories.

**Solution:**
```bash
# Fix permissions
sudo mkdir -p data/grafana data/influxdb
sudo chown -R 472:472 data/grafana
sudo chown -R 1000:1000 data/influxdb
sudo chmod -R 755 data/

# Restart services
docker-compose -f docker-compose-simple.yml down
docker-compose -f docker-compose-simple.yml up -d

# Verify
docker-compose -f docker-compose-simple.yml ps
```

---

### Issue: InfluxDB Connection Refused

**Symptom:**
```
Failed to connect to InfluxDB
```

**Root Cause:**  
InfluxDB not fully started or not accessible.

**Solution:**
```bash
# Check InfluxDB status
docker logs latency-hunter-influxdb

# Restart InfluxDB
docker-compose -f docker-compose-simple.yml restart influxdb

# Wait for startup
sleep 10

# Test connection
curl http://localhost:8086/health

# Verify from Grafana container
docker exec latency-hunter-grafana curl http://influxdb:8086/health
```

---

### Issue: Grafana Shows "No Data"

**Symptom:**  
Grafana dashboard displays "No Data" for all panels.

**Root Cause:**  
Current implementation uses Linux bridge switch which does not expose gNMI/gRPC telemetry.

**This is Expected Behavior:**  
- Linux bridge does not provide streaming telemetry
- Telegraf service disabled (no metrics to collect)
- In production with gNMI-capable switch (Arista cEOS or physical), metrics would populate automatically

**Verification:**
```bash
# Verify InfluxDB is operational
docker exec latency-hunter-influxdb influx ping

# Verify Grafana datasource
docker exec latency-hunter-grafana curl http://influxdb:8086/health
```

**Note:** This is documented in README.md Technical Notes section.

---

## Performance Issues

### Issue: High CPU Usage

**Symptom:**  
System slow, high load average.

**Root Cause:**  
Insufficient resources or too many containers.

**Solution:**
```bash
# Check resource usage
docker stats

# Check system load
top
htop

# If needed, stop unnecessary services
docker-compose -f docker-compose-simple.yml down

# Increase VM resources if possible (4 CPU minimum, 8 GB RAM)
```

---

### Issue: Disk Space Full

**Symptom:**
```
No space left on device
```

**Root Cause:**  
Docker images, logs, or data accumulated.

**Solution:**
```bash
# Check disk usage
df -h

# Clean Docker system
docker system prune -af
docker volume prune -f

# Remove old logs
sudo find /var/log -name "*.log" -type f -delete

# Check Containerlab cleanup
sudo containerlab destroy -a
```

---

## Diagnostic Commands

### System Information
```bash
# OS version
lsb_release -a

# Kernel version
uname -a

# System resources
free -h
df -h
lscpu
```

### Docker Diagnostics
```bash
# Docker version
docker --version
docker-compose --version

# Docker info
docker info

# Container status
docker ps -a

# Docker networks
docker network ls

# Docker logs
docker logs <container-name>
```

### Network Diagnostics
```bash
# Container network config
docker exec <container> ip addr
docker exec <container> ip route

# Test connectivity
docker exec <container> ping -c 3 <target-ip>

# Port listening
sudo netstat -tulpn | grep <port>
```

### Containerlab Diagnostics
```bash
# Containerlab version
sudo containerlab version

# Inspect topology
sudo containerlab inspect -a

# View topology details
sudo containerlab inspect -t topology/latency-hunter.clab.yml
```

---

## Getting Help

### Collect Information

Before requesting help, collect:

1. **System Information**
   ```bash
   lsb_release -a > system-info.txt
   docker --version >> system-info.txt
   sudo containerlab version >> system-info.txt
   ```

2. **Error Logs**
   ```bash
   docker-compose -f docker-compose-simple.yml logs > docker-logs.txt
   sudo containerlab inspect -a > containerlab-info.txt
   ```

3. **Container Status**
   ```bash
   docker ps -a > containers.txt
   docker network ls > networks.txt
   ```

### Resources

- **Project Documentation**: README.md
- **Architecture**: docs/ARCHITECTURE.md
- **Installation Guide**: INSTALLATION.md

---

## Reset Everything (Nuclear Option)

If all else fails, complete reset:

```bash
# Destroy Containerlab topology
sudo containerlab destroy -a

# Stop and remove all Docker containers
docker-compose -f docker-compose-simple.yml down
docker rm -f $(docker ps -aq)

# Remove networks
docker network prune -f

# Remove volumes
docker volume prune -f

# Clean system
docker system prune -af

# Start fresh
cd ~/latency-hunter
sudo containerlab deploy -t topology/latency-hunter.clab.yml
docker-compose -f docker-compose-simple.yml up -d
```

---

**End of Troubleshooting Guide**
