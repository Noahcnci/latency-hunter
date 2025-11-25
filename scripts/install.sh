#!/bin/bash

###############################################################################
# Latency Hunter - Automated Installation Script
# Description: Installs all prerequisites for network microburst detection lab
# OS Support: Ubuntu 22.04 LTS
# Author: Latency Hunter Project
###############################################################################

set -e

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Display functions
print_status() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo -e "\n${GREEN}=========================================================${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}=========================================================${NC}\n"
}

# Check root privileges
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run with sudo"
   exit 1
fi

print_header "Latency Hunter - Installation"

# 0. Preventive cleanup of old Docker repositories (avoids GPG key errors)
print_header "Step 0/8: Preventive Cleanup"
print_warning "Removing misconfigured Docker repositories..."
rm -f /etc/apt/sources.list.d/docker.list 2>/dev/null || true
rm -f /etc/apt/sources.list.d/docker.list.save 2>/dev/null || true
print_status "Cleanup completed"

# 1. System update
print_header "Step 1/8: System Update"
apt-get update
apt-get upgrade -y
print_status "System updated"

# 2. Base dependencies installation
print_header "Step 2/8: Base Tools Installation"
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    iputils-ping \
    traceroute \
    tcpdump \
    iperf3 \
    python3 \
    python3-pip \
    python3-venv \
    jq \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release

print_status "Base tools installed"

# 3. Docker installation
print_header "Step 3/8: Docker Installation"
if ! command -v docker &> /dev/null; then
    # Add official Docker repository
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Install standalone docker-compose for compatibility
    apt-get install -y docker-compose
    
    # Allow non-root user to use Docker
    usermod -aG docker $SUDO_USER
    
    print_status "Docker installed successfully"
else
    print_warning "Docker already installed"
fi

# Docker verification
systemctl start docker
systemctl enable docker
docker --version

# 4. Containerlab installation
print_header "Step 4/8: Containerlab Installation"
if ! command -v containerlab &> /dev/null; then
    bash -c "$(curl -sL https://get.containerlab.dev)"
    print_status "Containerlab installed"
else
    print_warning "Containerlab already installed"
fi

containerlab version

# 5. Arista cEOS image configuration
print_header "Step 5/8: Arista cEOS Image Configuration"
print_warning "NOTE: Arista cEOS image is optional for this lab"
print_warning "Current implementation uses Linux bridge"
print_warning "For production deployment with gNMI telemetry:"
print_warning "1. Create free account at: https://www.arista.com/en/support/software-download"
print_warning "2. Download: cEOS64-lab-4.30.0F.tar.xz"
print_warning "3. Extract: xz -d cEOS64-lab-4.30.0F.tar.xz"
print_warning "4. Import: docker import cEOS64-lab-4.30.0F.tar ceos:4.30.0F"
echo ""

# Check for cEOS image (optional)
if docker images | grep -q "ceos"; then
    print_status "cEOS image detected"
else
    print_warning "cEOS image not found (this is OK for current implementation)"
fi

# 6. TIG stack configuration
print_header "Step 6/8: TIG Stack Configuration"
cd "$(dirname "$0")/.." || exit

# Verify docker-compose file exists
if [ ! -f "docker-compose-simple.yml" ]; then
    print_error "docker-compose-simple.yml file not found"
    exit 1
fi

print_status "Configuration files detected"

# 7. Python dependencies installation
print_header "Step 7/8: Python Dependencies Installation"
pip3 install --upgrade pip
pip3 install -r requirements.txt
print_status "Python dependencies installed"

# 8. Permissions configuration and finalization
print_header "Step 8/8: Finalization"

# Create necessary directories
mkdir -p data/influxdb
mkdir -p data/grafana
chmod -R 777 data/

# Make scripts executable
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x scripts/*.py 2>/dev/null || true

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf
sysctl -p

print_status "Permissions configured"

# Display summary
print_header "Installation Complete"

echo -e "${GREEN}Next steps:${NC}"
echo ""
echo "1. Deploy network topology:"
echo "   ${YELLOW}sudo containerlab deploy -t topology/latency-hunter.clab.yml${NC}"
echo ""
echo "2. Start monitoring stack:"
echo "   ${YELLOW}docker-compose -f docker-compose-simple.yml up -d${NC}"
echo ""
echo "3. Access Grafana:"
echo "   ${YELLOW}http://localhost:3000${NC}"
echo "   Login: admin / Password: admin"
echo ""
echo "4. Generate test burst:"
echo "   ${YELLOW}python3 scripts/generate_microburst.py --duration 200 --rate 8G${NC}"
echo ""
echo -e "${GREEN}See README.md for detailed documentation${NC}"
echo ""

# Important note about restart
print_warning "IMPORTANT: If this is your first Docker installation,"
print_warning "logout and login again for group permissions to take effect"
print_warning "or execute: newgrp docker"

exit 0
