# Latency Hunter - Complete Installation Guide

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [System Requirements](#system-requirements)
3. [Initial Setup](#initial-setup)
4. [Installation Steps](#installation-steps)
5. [Post-Installation Verification](#post-installation-verification)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- Ubuntu 22.04 LTS (Desktop or Server)
- Sudo privileges
- Internet connectivity
- Minimum 50 GB free disk space

### Recommended VM Configuration
- **CPU**: 4 cores minimum
- **RAM**: 8 GB minimum
- **Disk**: 50 GB minimum
- **Network**: NAT or Bridged adapter

---

## System Requirements

### Hardware Requirements
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU Cores | 4 | 8 |
| RAM | 8 GB | 16 GB |
| Disk Space | 50 GB | 100 GB |
| Network | 1 Gbps | 10 Gbps |

### Software Dependencies
The installation script will install:
- Docker CE (latest)
- Docker Compose
- Containerlab
- Python 3.10+
- iperf3
- Required Python packages

---

## Initial Setup

### Step 1: Download Project

```bash
# Navigate to home directory
cd ~

# If project is not yet extracted
tar -xzf latency-hunter-final-YYYYMMDD.tar.gz

# Navigate to project directory
cd latency-hunter

# Verify project structure
ls -la
```

Expected output:
```
drwxr-xr-x configs/
drwxr-xr-x docs/
drwxr-xr-x scripts/
drwxr-xr-x topology/
-rw-r--r-- README.md
-rw-r--r-- docker-compose-simple.yml
-rw-r--r-- requirements.txt
```

### Step 2: Make Installation Script Executable

```bash
chmod +x scripts/install.sh
```

### Step 3: Review Installation Script (Optional)

```bash
cat scripts/install.sh
```

---

## Installation Steps

### Step 4: Run Automated Installation

```bash
sudo ./scripts/install.sh
```

**Installation Process:**
1. Updates APT repositories
2. Installs Docker and Docker Compose
3. Installs Containerlab
4. Installs Python dependencies
5. Configures network prerequisites
6. Sets up user permissions

**Expected Duration**: 5-10 minutes (depending on internet speed)

### Step 5: Apply User Permissions

After installation completes:

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Verify docker access (no sudo required)
docker ps
```

Expected output: Empty container list (no permission errors)

---

## Post-Installation Verification

### Verify Docker Installation

```bash
# Check Docker version
docker --version

# Expected: Docker version 24.x.x or higher
```

```bash
# Check Docker Compose version
docker-compose --version

# Expected: docker-compose version 1.29.x or 2.x.x
```

### Verify Containerlab Installation

```bash
# Check Containerlab version
sudo containerlab version

# Expected: containerlab version 0.4x.x or higher
```

### Verify Python Dependencies

```bash
# Check Python version
python3 --version

# Expected: Python 3.10.x or higher
```

```bash
# Verify iperf3
iperf3 --version

# Expected: iperf 3.x
```

### Verify Network Prerequisites

```bash
# Check for ip_forward
cat /proc/sys/net/ipv4/ip_forward

# Expected: 1
```

```bash
# Check for bridge module
lsmod | grep bridge

# Expected: bridge module loaded
```

---

## Common Installation Issues

### Issue 1: Docker GPG Key Error

**Symptom:**
```
GPG error: ... NO_PUBKEY 7EA0A9C3F273FCD8
```

**Solution:**
```bash
# Remove old Docker repository
sudo rm /etc/apt/sources.list.d/docker.list 2>/dev/null || true

# Update package list
sudo apt-get update

# Re-run installation
sudo ./scripts/install.sh
```

### Issue 2: Permission Denied (Docker)

**Symptom:**
```
permission denied while trying to connect to Docker daemon
```

**Solution:**
```bash
# Ensure user is in docker group
sudo usermod -aG docker $USER

# Apply changes
newgrp docker

# Verify
docker ps
```

### Issue 3: Containerlab Not Found

**Symptom:**
```
containerlab: command not found
```

**Solution:**
```bash
# Manual Containerlab installation
bash -c "$(curl -sL https://get.containerlab.dev)"

# Verify installation
sudo containerlab version
```

### Issue 4: Python Module Not Found

**Symptom:**
```
ModuleNotFoundError: No module named 'xxx'
```

**Solution:**
```bash
# Reinstall Python dependencies
cd ~/latency-hunter
pip3 install -r requirements.txt --user
```

---

## Manual Installation (Alternative)

If automated installation fails, perform manual installation:

### Install Docker

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker GPG key
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install docker-compose (standalone)
sudo apt-get install -y docker-compose
```

### Install Containerlab

```bash
bash -c "$(curl -sL https://get.containerlab.dev)"
```

### Install Python Dependencies

```bash
sudo apt-get install -y python3-pip iperf3
pip3 install -r requirements.txt --user
```

### Configure System

```bash
# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

---

## Next Steps

After successful installation:

1. **Deploy Network Topology**
   ```bash
   sudo containerlab deploy -t topology/latency-hunter.clab.yml
   ```

2. **Start Monitoring Stack**
   ```bash
   docker-compose -f docker-compose-simple.yml up -d
   ```

3. **Access Grafana**
   ```
   http://<VM-IP>:3000
   Username: admin
   Password: admin
   ```

4. **Generate Test Traffic**
   ```bash
   python3 scripts/generate_microburst.py --duration 200 --rate 8G
   ```

---

## Verification Checklist

- [ ] Docker installed and accessible without sudo
- [ ] Docker Compose installed and functional
- [ ] Containerlab installed and accessible
- [ ] Python 3.10+ installed
- [ ] iperf3 installed
- [ ] IP forwarding enabled
- [ ] User in docker group
- [ ] Project files present and readable

---

## Support Resources

- **Project Documentation**: See `README.md`
- **Troubleshooting Guide**: See `docs/TROUBLESHOOTING.md`
- **Architecture Details**: See `docs/ARCHITECTURE.md`

---

## Installation Complete

You are now ready to deploy the Latency Hunter network topology and begin testing.

Proceed to deployment instructions in `README.md` or `QUICKSTART.md`.

