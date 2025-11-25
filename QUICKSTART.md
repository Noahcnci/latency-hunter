# Latency Hunter - Quick Start Guide

## Complete Setup in 10 Minutes

This guide provides step-by-step commands to deploy Latency Hunter from scratch.

---

## Prerequisites

- Ubuntu 22.04 LTS VM
- Sudo access
- Internet connectivity
- Minimum: 4 CPU, 8 GB RAM, 50 GB disk

---

## Step 1: Extract Project

```bash
cd ~
tar -xzf latency-hunter-final-YYYYMMDD.tar.gz
cd latency-hunter
```

**Verification:**
```bash
ls -la
```

Expected: `configs/`, `docs/`, `scripts/`, `topology/`, `README.md`

---

## Step 2: Run Automated Installation

```bash
chmod +x scripts/install.sh
sudo ./scripts/install.sh
```

**Note:** If Docker GPG error occurs:
```bash
sudo rm /etc/apt/sources.list.d/docker.list 2>/dev/null || true
sudo apt-get update
sudo ./scripts/install.sh
```

**Duration:** 5-10 minutes

---

## Step 3: Apply User Permissions

```bash
sudo usermod -aG docker $USER
newgrp docker
docker ps
```

**Verification:** Command should execute without errors

---

## Step 4: Import Arista cEOS Image (Optional)

If you have Arista cEOS image:

```bash
# Extract image
xz -d ~/Downloads/cEOS64-lab-4.30.0F.tar.xz

# Import to Docker
docker import ~/Downloads/cEOS64-lab-4.30.0F.tar ceos:4.30.0F

# Verify import
docker images | grep ceos
```

**Note:** Current implementation uses Linux bridge; cEOS import is optional for future enhancements.

---

## Step 5: Deploy Network Topology

```bash
cd ~/latency-hunter
sudo containerlab deploy -t topology/latency-hunter.clab.yml
```

**Verification:**
```bash
docker ps | grep clab-latency-hunter
```

Expected: 3 containers running (traffic-gen-1, traffic-gen-2, spine-01)

---

## Step 6: Verify Network Connectivity

```bash
# Test connectivity between traffic generators
docker exec clab-latency-hunter-traffic-gen-1 ping -c 3 10.0.1.12
```

**Expected output:**
```
3 packets transmitted, 3 received, 0% packet loss
```

If successful, network topology is operational.

---

## Step 7: Start iperf3 Server

```bash
# Kill any existing iperf3 processes
docker exec clab-latency-hunter-traffic-gen-2 pkill -9 iperf3

# Start iperf3 server
docker exec -d clab-latency-hunter-traffic-gen-2 iperf3 -s

# Verify server is running
docker exec clab-latency-hunter-traffic-gen-2 ps aux | grep iperf3
```

**Expected:** iperf3 process running

---

## Step 8: Start Monitoring Stack

```bash
cd ~/latency-hunter

# Fix permissions for Grafana/InfluxDB data directories
sudo mkdir -p data/grafana data/influxdb
sudo chmod -R 777 data/

# Start TIG stack
docker-compose -f docker-compose-simple.yml up -d

# Verify services
docker-compose -f docker-compose-simple.yml ps
```

**Expected:** influxdb and grafana containers running

---

## Step 9: Access Grafana

1. Open browser
2. Navigate to: `http://<VM-IP>:3000`
3. Login credentials:
   - **Username:** admin
   - **Password:** admin

**Note:** Grafana will display "No Data" (expected behavior - see Technical Notes in README.md)

---

## Step 10: Generate Test Traffic

```bash
cd ~/latency-hunter

# Generate single 200ms burst at 8 Gbps
python3 scripts/generate_microburst.py --duration 200 --rate 8G
```

**Expected output:**
```
BURST CONFIGURATION
====================
Target          : 10.0.1.12:5201
Duration        : 200 ms
Bandwidth       : 8G
Protocol        : UDP
...
[STATUS] Burst completed successfully
```

---

## Advanced Usage

### Generate Burst Pattern

```bash
# 5 bursts, 10 seconds apart
python3 scripts/generate_microburst.py --duration 200 --rate 8G --pattern 5 --interval 10
```

### Test Different Configurations

**Short intense burst:**
```bash
python3 scripts/generate_microburst.py --duration 100 --rate 10G
```

**Long sustained burst:**
```bash
python3 scripts/generate_microburst.py --duration 500 --rate 8G
```

**TCP protocol:**
```bash
python3 scripts/generate_microburst.py --duration 500 --rate 8G --protocol tcp
```

---

## Cleanup Commands

### Destroy Topology

```bash
sudo containerlab destroy -a
```

### Stop Monitoring Stack

```bash
docker-compose -f docker-compose-simple.yml down
```

### Remove All Containers

```bash
docker rm -f $(docker ps -aq)
```

### Full System Cleanup

```bash
sudo containerlab destroy -a
docker-compose -f docker-compose-simple.yml down
docker system prune -af
```

---

## Troubleshooting Quick Reference

| Issue | Command |
|-------|---------|
| Docker permission denied | `sudo usermod -aG docker $USER && newgrp docker` |
| iperf3 connection refused | `docker exec clab-latency-hunter-traffic-gen-2 pkill -9 iperf3 && docker exec -d clab-latency-hunter-traffic-gen-2 iperf3 -s` |
| Grafana permission error | `sudo chmod -R 777 data/` |
| Containers not starting | `sudo containerlab destroy -a && sudo containerlab deploy -t topology/latency-hunter.clab.yml` |

For detailed troubleshooting, see `docs/TROUBLESHOOTING.md`

---

## Verification Checklist

- [ ] Installation completed without errors
- [ ] User added to docker group
- [ ] Containerlab topology deployed (3 containers)
- [ ] Ping test successful (0% packet loss)
- [ ] iperf3 server running
- [ ] Monitoring stack started
- [ ] Grafana accessible
- [ ] Test burst successful

---

## Next Steps

- Review full documentation: `README.md`
- Explore architecture: `docs/ARCHITECTURE.md`
- Review technical notes regarding Grafana "No Data"
- Export project for portfolio

---

## Support

For detailed information:
- **Installation:** `INSTALLATION.md`
- **Architecture:** `docs/ARCHITECTURE.md`
- **Troubleshooting:** `docs/TROUBLESHOOTING.md`
- **Export:** `EXPORT_GUIDE.md`

---

**Project Ready for Testing and Demonstration**
