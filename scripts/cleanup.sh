#!/bin/bash

###############################################################################
# Latency Hunter - Cleanup Script
# Description: Destroys lab topology and cleans up Docker resources
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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo -e "\n${GREEN}=========================================================${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}=========================================================${NC}\n"
}

print_header "Latency Hunter - Cleanup"

# 1. Destroy Containerlab topology
print_header "Step 1/4: Destroying Containerlab Topology"
if command -v containerlab &> /dev/null; then
    sudo containerlab destroy -a
    print_status "Topology destroyed"
else
    print_warning "Containerlab not installed, skipping"
fi

# 2. Stop Docker Compose services
print_header "Step 2/4: Stopping Monitoring Stack"
cd "$(dirname "$0")/.." || exit

if [ -f "docker-compose-simple.yml" ]; then
    docker-compose -f docker-compose-simple.yml down
    print_status "Monitoring stack stopped"
else
    print_warning "docker-compose-simple.yml not found"
fi

# 3. Clean Docker resources
print_header "Step 3/4: Cleaning Docker Resources"

# Stop all containers
print_warning "Stopping all containers..."
docker stop $(docker ps -aq) 2>/dev/null || true

# Remove all containers
print_warning "Removing all containers..."
docker rm $(docker ps -aq) 2>/dev/null || true

# Remove Docker networks
print_warning "Pruning networks..."
docker network prune -f

# Remove dangling volumes
print_warning "Pruning volumes..."
docker volume prune -f

print_status "Docker resources cleaned"

# 4. Optional: Complete system cleanup
print_header "Step 4/4: Additional Cleanup Options"

echo "Do you want to perform complete cleanup? (removes all Docker images)"
read -p "This will free significant disk space but requires re-download. [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Performing complete Docker system cleanup..."
    docker system prune -af
    docker volume prune -af
    print_status "Complete cleanup performed"
else
    print_status "Skipped complete cleanup"
fi

print_header "Cleanup Complete"

echo "Lab environment has been cleaned up."
echo ""
echo "To redeploy:"
echo "  sudo containerlab deploy -t topology/latency-hunter.clab.yml"
echo "  docker-compose -f docker-compose-simple.yml up -d"
echo ""

exit 0
