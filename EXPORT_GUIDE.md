# Project Export Guide

## Overview

This guide provides instructions for exporting the Latency Hunter project for portfolio presentation, transfer, or archival purposes.

---

## Quick Export (Recommended)

### Single Command Export

```bash
cd ~
tar -czf latency-hunter-final-$(date +%Y%m%d).tar.gz \
  --exclude='latency-hunter/data/*' \
  --exclude='latency-hunter/*.tar' \
  --exclude='latency-hunter/clab-*' \
  --exclude='latency-hunter/__pycache__' \
  --exclude='latency-hunter/*.backup' \
  latency-hunter/
```

**This command:**
- Creates compressed archive with date stamp
- Excludes runtime data (Grafana/InfluxDB)
- Excludes large Docker images
- Excludes temporary files
- Preserves project structure and documentation

**Verify export:**
```bash
ls -lh latency-hunter-final-*.tar.gz
```

Expected size: 50-100 MB

---

## Transfer to Windows

### Method 1: SCP (Recommended)

From Windows PowerShell:
```powershell
scp user@vm-ip:~/latency-hunter-final-*.tar.gz C:\Users\YourUsername\Downloads\
```

### Method 2: WinSCP (GUI)

1. Download WinSCP: https://winscp.net
2. Connect to Ubuntu VM
3. Navigate to home directory
4. Download `latency-hunter-final-YYYYMMDD.tar.gz`
5. Save to local Windows directory

### Method 3: Shared Folder (VM)

If VM has shared folder configured:
```bash
cp latency-hunter-final-*.tar.gz /mnt/shared/
```

---

## Professional Portfolio Package

### Create Comprehensive Archive with Metadata

```bash
cd ~
mkdir -p latency-hunter-portfolio
cd latency-hunter-portfolio

# Copy project
cp -r ~/latency-hunter .

# Create project metadata file
cat > PROJECT_INFO.txt << 'EOF'
PROJECT: Latency Hunter - Network Microburst Detection System
AUTHOR: [Your Name]
DATE: November 2025
VERSION: 1.0

DESCRIPTION:
Advanced network monitoring system for detecting microsecond-level traffic 
microbursts using streaming telemetry (gNMI/gRPC). Demonstrates expertise in 
containerization, network automation, and real-time monitoring.

TECHNOLOGIES:
- Docker & Docker Compose
- Containerlab (Network Emulation)
- TIG Stack (Telegraf, InfluxDB, Grafana)
- Python 3 (Automation & Scripting)
- iperf3 (Traffic Generation)
- Linux Bridge Networking
- Ubuntu 22.04 LTS

KEY FEATURES:
- Automated deployment with Infrastructure as Code
- Sub-millisecond burst generation
- Real-time monitoring infrastructure
- Comprehensive documentation
- Professional code quality

DEPLOYMENT:
See INSTALLATION.md and QUICKSTART.md for complete deployment instructions.

TECHNICAL NOTES:
Current implementation uses Linux bridge switch. Grafana displays "No Data" 
as Linux bridge does not expose gNMI telemetry. In production deployment with 
gNMI-capable switch (Arista cEOS or physical switch), metrics would populate 
automatically. All monitoring infrastructure is operational and ready.

SKILLS DEMONSTRATED:
- Network Engineering & Automation
- Container Orchestration
- System Administration (Linux)
- Python Scripting & Development
- Infrastructure as Code
- Technical Documentation
- Problem Solving & Troubleshooting

PORTFOLIO VALUE:
Demonstrates ability to design, implement, and document complex network 
monitoring systems suitable for HFT and low-latency environments.

EOF

# Create archive with metadata
cd ~
tar -czf latency-hunter-portfolio-$(date +%Y%m%d).tar.gz \
  --exclude='latency-hunter-portfolio/latency-hunter/data/*' \
  --exclude='latency-hunter-portfolio/latency-hunter/*.tar' \
  --exclude='latency-hunter-portfolio/latency-hunter/clab-*' \
  --exclude='latency-hunter-portfolio/latency-hunter/__pycache__' \
  latency-hunter-portfolio/

# Verify
ls -lh latency-hunter-portfolio-*.tar.gz

# Cleanup temporary directory
rm -rf latency-hunter-portfolio/
```

---

## Archive Contents Verification

### Extract and Verify (Optional)

```bash
# Create test directory
mkdir -p ~/test-extract
cd ~/test-extract

# Extract archive
tar -xzf ~/latency-hunter-final-*.tar.gz

# Verify structure
tree -L 2 latency-hunter/

# Expected structure:
# latency-hunter/
# ├── README.md
# ├── INSTALLATION.md
# ├── QUICKSTART.md
# ├── EXPORT_GUIDE.md
# ├── requirements.txt
# ├── docker-compose-simple.yml
# ├── configs/
# │   ├── grafana/
# │   ├── switch/
# │   └── telegraf/
# ├── docs/
# │   ├── ARCHITECTURE.md
# │   ├── TROUBLESHOOTING.md
# │   └── TECHNICAL_NOTES.md
# ├── scripts/
# │   ├── install.sh
# │   ├── generate_microburst.py
# │   ├── cleanup.sh
# │   └── monitor_baseline.sh
# └── topology/
#     └── latency-hunter.clab.yml

# Cleanup
cd ~
rm -rf ~/test-extract
```

---

## Export for Different Purposes

### Portfolio/Resume Export

Include:
- Full documentation
- Source code
- Configuration files
- PROJECT_INFO.txt (metadata)

```bash
tar -czf latency-hunter-portfolio.tar.gz \
  --exclude='data/*' \
  --exclude='*.tar' \
  --exclude='clab-*' \
  --exclude='__pycache__' \
  latency-hunter/
```

### Transfer to Another System

Include everything except runtime data:

```bash
tar -czf latency-hunter-transfer.tar.gz \
  --exclude='data/*' \
  latency-hunter/
```

### Full Backup (with data)

Include all files including runtime data:

```bash
tar -czf latency-hunter-backup-full.tar.gz latency-hunter/
```

**Warning:** Full backup will be large (1-5 GB) due to database files.

---

## Extraction on New System

### Extract Archive

```bash
cd ~
tar -xzf latency-hunter-final-YYYYMMDD.tar.gz
cd latency-hunter
```

### Verify Extraction

```bash
ls -la
cat README.md
```

### Ready for Deployment

Follow instructions in `INSTALLATION.md` or `QUICKSTART.md`

---

## Archive Naming Conventions

### Standard Format

```
latency-hunter-[type]-[date].tar.gz
```

**Examples:**
- `latency-hunter-final-20251125.tar.gz` (Standard export)
- `latency-hunter-portfolio-20251125.tar.gz` (Portfolio package)
- `latency-hunter-backup-20251125.tar.gz` (Full backup)
- `latency-hunter-transfer-20251125.tar.gz` (Transfer to another system)

---

## File Size Reference

| Archive Type | Approximate Size | Contents |
|--------------|------------------|----------|
| Standard Export | 50-100 MB | Project files, no data |
| Portfolio Package | 60-120 MB | Project + metadata |
| Full Backup | 1-5 GB | Project + runtime data |
| Minimal (code only) | 10-20 MB | Scripts + configs only |

---

## Cloud Storage Upload (Optional)

### Upload to Cloud Storage

```bash
# Example: Upload to personal cloud storage
# Replace with your preferred method

# Google Drive (using gdrive CLI)
gdrive upload latency-hunter-final-*.tar.gz

# AWS S3 (if configured)
aws s3 cp latency-hunter-final-*.tar.gz s3://your-bucket/

# Azure (if configured)
az storage blob upload --file latency-hunter-final-*.tar.gz --container your-container
```

---

## Checksum Verification

### Generate Checksum

```bash
# Generate SHA256 checksum
sha256sum latency-hunter-final-*.tar.gz > latency-hunter.sha256

# View checksum
cat latency-hunter.sha256
```

### Verify Checksum (after transfer)

```bash
# Verify integrity
sha256sum -c latency-hunter.sha256
```

Expected output: `OK`

---

## GitHub Repository (Optional)

If uploading to GitHub:

### Create Repository

```bash
cd ~/latency-hunter

# Initialize git (if not already)
git init

# Add remote
git remote add origin https://github.com/yourusername/latency-hunter.git

# Add files
git add .

# Commit
git commit -m "Initial commit: Latency Hunter network monitoring system"

# Push
git push -u origin main
```

### Create .gitignore (if not present)

```bash
cat > .gitignore << 'EOF'
# Runtime data
data/
*.log

# Docker images
*.tar
*.tar.xz

# Containerlab runtime
clab-*

# Python
__pycache__/
*.pyc
*.pyo

# Backups
*.backup
*.bak

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
EOF
```

---

## Export Checklist

Before exporting, ensure:

- [ ] All documentation updated
- [ ] No sensitive information (passwords, tokens)
- [ ] Code properly formatted and commented
- [ ] README.md comprehensive
- [ ] Test on clean system (optional)
- [ ] Archive size reasonable
- [ ] Checksum generated (optional)
- [ ] Transfer method selected

---

## Professional Presentation

When presenting this project:

1. **Start with README.md** - Provides complete overview
2. **Highlight Architecture** - Show system design understanding
3. **Demonstrate Deployment** - Quick deployment capability
4. **Show Traffic Generation** - Working functionality
5. **Explain Technical Notes** - Understanding of limitations
6. **Discuss Future Enhancements** - Vision for improvement

---

## Support

For questions or issues:
- Review `README.md` for project overview
- Check `INSTALLATION.md` for setup instructions
- See `docs/TROUBLESHOOTING.md` for common problems

---

**Export Complete - Ready for Portfolio Presentation**

