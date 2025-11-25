#!/bin/bash

###############################################################################
# Latency Hunter - Baseline Monitoring Script
# Description: Monitors network traffic and system performance
# Author: Latency Hunter Project
###############################################################################

# Output colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Display header
echo -e "${GREEN}=========================================================${NC}"
echo -e "${GREEN}  Latency Hunter - Real-time Monitoring${NC}"
echo -e "${GREEN}=========================================================${NC}\n"

# Check if topology is deployed
if ! docker ps | grep -q "clab-latency-hunter"; then
    echo -e "${YELLOW}[WARNING]${NC} Containerlab topology not deployed"
    echo "Deploy with: sudo containerlab deploy -t topology/latency-hunter.clab.yml"
    exit 1
fi

echo -e "${CYAN}[INFO]${NC} Monitoring traffic between generators..."
echo -e "${CYAN}[INFO]${NC} Press Ctrl+C to stop\n"

# Function to display traffic statistics
monitor_traffic() {
    echo -e "${GREEN}Container Status:${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}" | grep latency-hunter
    echo ""
    
    echo -e "${GREEN}Network Statistics (traffic-gen-1):${NC}"
    docker exec clab-latency-hunter-traffic-gen-1 ip -s link show eth1 2>/dev/null || echo "  Interface stats unavailable"
    echo ""
    
    echo -e "${GREEN}Network Statistics (traffic-gen-2):${NC}"
    docker exec clab-latency-hunter-traffic-gen-2 ip -s link show eth1 2>/dev/null || echo "  Interface stats unavailable"
    echo ""
    
    echo -e "${GREEN}Bridge Status (spine-01):${NC}"
    docker exec clab-latency-hunter-spine-01 ip -s link show br0 2>/dev/null || echo "  Bridge stats unavailable"
    echo ""
}

# Function to test connectivity
test_connectivity() {
    echo -e "${GREEN}Connectivity Test:${NC}"
    docker exec clab-latency-hunter-traffic-gen-1 ping -c 3 10.0.1.12 2>&1 | grep -E "transmitted|packet loss"
    echo ""
}

# Function to check iperf3 server
check_iperf_server() {
    echo -e "${GREEN}iperf3 Server Status:${NC}"
    if docker exec clab-latency-hunter-traffic-gen-2 ps aux 2>/dev/null | grep -q "[i]perf3 -s"; then
        echo -e "  ${GREEN}RUNNING${NC}"
    else
        echo -e "  ${YELLOW}NOT RUNNING${NC}"
        echo "  Start with: docker exec -d clab-latency-hunter-traffic-gen-2 iperf3 -s"
    fi
    echo ""
}

# Main monitoring loop
while true; do
    clear
    echo -e "${GREEN}=========================================================${NC}"
    echo -e "${GREEN}  Latency Hunter - Real-time Monitoring${NC}"
    echo -e "${GREEN}  $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${GREEN}=========================================================${NC}\n"
    
    monitor_traffic
    test_connectivity
    check_iperf_server
    
    echo -e "${CYAN}[INFO]${NC} Refreshing in 5 seconds... (Ctrl+C to stop)"
    sleep 5
done
