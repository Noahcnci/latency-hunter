# GitHub Repository Setup Guide

## Overview

This guide provides step-by-step instructions for publishing the Latency Hunter project to GitHub.

---

## Prerequisites

- GitHub account (free tier sufficient)
- Git installed on your system
- Project files ready for publication

---

## Step 1: Create GitHub Repository

### Via GitHub Web Interface

1. Navigate to https://github.com
2. Click "New repository" or go to https://github.com/new
3. Configure repository:
   - **Repository name**: `latency-hunter` (or preferred name)
   - **Description**: `Real-time network microburst detection system using streaming telemetry`
   - **Visibility**: Public or Private
   - **Initialize**: Do NOT initialize with README, .gitignore, or license (we have these)
4. Click "Create repository"

---

## Step 2: Prepare Local Repository

### Initialize Git Repository

```bash
cd ~/latency-hunter

# Initialize git (if not already initialized)
git init

# Verify .gitignore is present
cat .gitignore

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Latency Hunter network monitoring system"
```

### Verify Files to be Committed

```bash
# Check status
git status

# View files to be committed
git ls-files

# Ensure sensitive data excluded
git ls-files | grep -E "\.env|\.key|\.pem|data/"
# Should return nothing
```

---

## Step 3: Connect to GitHub

### Add Remote Repository

```bash
# Replace 'yourusername' with your GitHub username
git remote add origin https://github.com/yourusername/latency-hunter.git

# Verify remote
git remote -v
```

### Alternative: SSH (Recommended for Frequent Updates)

```bash
# If you have SSH key configured on GitHub
git remote add origin git@github.com:yourusername/latency-hunter.git
```

---

## Step 4: Push to GitHub

### Push Main Branch

```bash
# Push to GitHub
git push -u origin main

# If 'main' branch doesn't exist, create from master
git branch -M main
git push -u origin main
```

### Verify Upload

1. Navigate to repository URL in browser
2. Verify all files present
3. Check README.md displays correctly

---

## Step 5: Repository Configuration

### Add Repository Description

On GitHub repository page:
1. Click "About" gear icon
2. Add description: `Real-time network microburst detection system using streaming telemetry and containerized infrastructure`
3. Add website (if applicable)
4. Add topics/tags:
   - `network-monitoring`
   - `containerlab`
   - `docker`
   - `grafana`
   - `influxdb`
   - `networking`
   - `automation`
   - `infrastructure-as-code`
   - `telemetry`
   - `low-latency`

### Repository Settings

Navigate to Settings tab:

**General**:
- Enable "Issues" for bug tracking
- Enable "Discussions" for Q&A (optional)
- Disable "Wiki" (documentation in repo)
- Disable "Projects" (unless needed)

**Branches**:
- Set `main` as default branch
- Add branch protection (optional):
  - Require pull request reviews
  - Require status checks
  - Enforce linear history

---

## Step 6: Create README Badge (Optional)

### Add Status Badges

Add to top of README.md:

```markdown
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Language](https://img.shields.io/badge/language-Python-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)
![Docker](https://img.shields.io/badge/docker-required-blue.svg)
```

---

## Step 7: Create Release (Optional)

### Tag Release

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Initial release: Latency Hunter v1.0"

# Push tag to GitHub
git push origin v1.0.0
```

### Create GitHub Release

1. Navigate to repository "Releases" page
2. Click "Draft a new release"
3. Select tag: `v1.0.0`
4. Release title: `Latency Hunter v1.0.0`
5. Description:
```markdown
## Latency Hunter v1.0.0

First public release of Latency Hunter network monitoring system.

### Features
- Automated network topology deployment with Containerlab
- Traffic burst generation with configurable duration and bandwidth
- TIG stack monitoring infrastructure (Telegraf, InfluxDB, Grafana)
- Comprehensive documentation and setup guides
- Professional code quality and error handling

### Installation
See [INSTALLATION.md](INSTALLATION.md) for complete setup instructions.

### Quick Start
See [QUICKSTART.md](QUICKSTART.md) for rapid deployment.

### Technical Notes
Current implementation uses Linux bridge. See [TECHNICAL_NOTES.md](docs/TECHNICAL_NOTES.md) for details on production deployment with gNMI-capable switches.

### Requirements
- Ubuntu 22.04 LTS
- Docker & Docker Compose
- Containerlab
- Minimum 4 CPU, 8 GB RAM
```
6. Click "Publish release"

---

## Step 8: Repository Enhancement

### Add LICENSE File

Create `LICENSE` file:

```bash
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

git add LICENSE
git commit -m "Add MIT license"
git push
```

### Add CONTRIBUTING.md (Optional)

For open-source collaboration:

```bash
cat > CONTRIBUTING.md << 'EOF'
# Contributing to Latency Hunter

Thank you for your interest in contributing!

## How to Contribute

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## Code Standards

- Follow existing code style
- Add comments for complex logic
- Update documentation for new features
- Test thoroughly before submitting

## Reporting Issues

Use GitHub Issues for:
- Bug reports
- Feature requests
- Documentation improvements

Include:
- Clear description
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Environment details (OS, versions)

## Questions

Open a GitHub Discussion for general questions.
EOF

git add CONTRIBUTING.md
git commit -m "Add contributing guidelines"
git push
```

---

## Step 9: Maintain Repository

### Update Repository

```bash
# Make changes to files

# Stage changes
git add .

# Commit with descriptive message
git commit -m "Description of changes"

# Push to GitHub
git push
```

### View Commit History

```bash
# View log
git log --oneline --graph --all

# View specific file history
git log --follow -- path/to/file
```

### Create Branches (For Features)

```bash
# Create and switch to feature branch
git checkout -b feature/new-dashboard

# Work on feature...

# Push feature branch
git push -u origin feature/new-dashboard

# Create pull request on GitHub
# Merge via GitHub UI
# Delete branch after merge
```

---

## Step 10: Portfolio Integration

### Link from Portfolio/Resume

**GitHub Profile README**:
```markdown
## Featured Projects

### Latency Hunter - Network Monitoring System
Real-time microsecond-level traffic burst detection using streaming telemetry.
[View Project](https://github.com/yourusername/latency-hunter)

**Technologies**: Docker, Containerlab, InfluxDB, Grafana, Python
**Skills**: Network automation, Infrastructure as Code, Time-series databases
```

**LinkedIn**:
- Add to Projects section
- Link to GitHub repository
- Describe technologies and outcomes

**Personal Website**:
- Add to portfolio with screenshots
- Link to live demo (if available)
- Link to GitHub repository

---

## Repository URL Examples

### Public Repository
```
https://github.com/yourusername/latency-hunter
```

### Clone Commands

**HTTPS**:
```bash
git clone https://github.com/yourusername/latency-hunter.git
```

**SSH**:
```bash
git clone git@github.com:yourusername/latency-hunter.git
```

---

## Troubleshooting

### Authentication Failed

**HTTPS**: Use Personal Access Token instead of password
1. Go to Settings > Developer settings > Personal access tokens
2. Generate new token with `repo` scope
3. Use token as password when prompted

**SSH**: Configure SSH key
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub
# Add public key to GitHub Settings > SSH Keys
```

### Large Files

If files > 100 MB:
```bash
# Use Git LFS for large files
git lfs install
git lfs track "*.tar"
git add .gitattributes
git commit -m "Configure Git LFS"
```

### Rejected Push

```bash
# Pull latest changes first
git pull origin main --rebase

# Resolve conflicts if any
git add .
git rebase --continue

# Push again
git push
```

---

## Best Practices

1. **Commit Often**: Small, focused commits with clear messages
2. **Write Good Commit Messages**:
   - Present tense ("Add feature" not "Added feature")
   - Imperative mood ("Fix bug" not "Fixes bug")
   - 50 characters max for subject line
   - Detailed description in body if needed
3. **Keep Repository Clean**: Use .gitignore effectively
4. **Document Changes**: Update README and docs with changes
5. **Use Branches**: Don't commit directly to main for major changes
6. **Tag Releases**: Use semantic versioning (v1.0.0, v1.1.0, etc.)
7. **Security**: Never commit secrets, passwords, or API keys

---

## Completion Checklist

- [ ] Repository created on GitHub
- [ ] Local repository initialized
- [ ] .gitignore configured
- [ ] Initial commit created
- [ ] Remote repository added
- [ ] Code pushed to GitHub
- [ ] Repository description added
- [ ] Topics/tags added
- [ ] README displays correctly
- [ ] LICENSE file added
- [ ] Release created (optional)
- [ ] Repository linked in portfolio

---

## Next Steps

1. Share repository URL on resume/portfolio
2. Consider adding continuous integration (GitHub Actions)
3. Add project to GitHub Profile README
4. Write blog post about project
5. Present in technical interviews

---

**Your Latency Hunter project is now professionally published on GitHub!**

