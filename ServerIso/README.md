# PBOS Server Edition

> **24/7 Server Optimized**: CLI-only Arch Linux distribution designed for server workloads, web hosting, Docker containers, and development environments.

PBOS Server Edition is a streamlined Arch Linux ISO optimized for server use with Python, Docker, Java, Node.js, and Tailscale pre-configured.

## Philosophy: Server-First

**Optimized for uptime and performance**:
- No desktop environment (CLI only)
- Server performance tuning out of the box
- SSH with security hardening
- UFW firewall pre-configured
- Docker ready with compose
- Tailscale for secure remote access

## Quick Start

### 1. Build the ISO

```bash
cd ServerIso
bash build-server-iso.sh
```

The ISO will be created in `iso-output/`

### 2. Test in QEMU

```bash
# Test installation
bash test-iso-qemu-install.sh

# Boot installed system (with SSH on port 2222)
bash run-installed-qemu.sh
```

### 3. Deploy to Server

```bash
# Write to USB
sudo dd if=iso-output/pbos-server-*.iso of=/dev/sdX bs=4M status=progress

# Boot from USB
# Run: install-arch
# Follow prompts
# After reboot: cd ~/custom-setup && bash post-install.sh
# Reboot again
```

## Features

### Development Stack
- **Python** - Python 3 with pip and virtualenv
- **Docker** - Container platform with docker-compose
- **Node.js** - JavaScript runtime with npm
- **Java** - OpenJDK (JRE and JDK)
- **Git** - Version control

### Server Infrastructure
- **SSH Server** - OpenSSH with security hardening
- **Tailscale VPN** - Secure networking and remote access
- **UFW Firewall** - Pre-configured with SSH access
- **Server Monitoring** - htop, btop, iotop, iftop, nethogs

### Performance Optimization
- **Kernel Tuning** - BBR congestion control, optimized network parameters
- **File Limits** - Increased descriptor limits for high-load servers
- **Security Hardening** - Kernel security parameters enabled
- **Swap Optimization** - Swappiness set to 10 for server workloads

## System Requirements

### Minimum
- **CPU**: 64-bit processor (x86_64)
- **RAM**: 512MB (1GB+ recommended)
- **Disk**: 10GB free space
- **Network**: Ethernet or WiFi

### Recommended for Production
- **CPU**: 2+ cores
- **RAM**: 2GB+
- **Disk**: 20GB+ (SSD recommended)
- **Network**: Gigabit Ethernet

## File Structure

```
ServerIso/
├── build-server-iso.sh         # Main build script
├── install-auto.sh              # Auto-detect installation
├── install.sh                   # Base system installation
├── post-install.sh              # Server stack setup
├── wifi-setup.sh                # WiFi connection helper
├── partition-helper-safe.sh     # Disk partitioning helper
├── iso-output/                  # Generated ISO files
├── test-iso-qemu-install.sh    # QEMU installation test
├── run-installed-qemu.sh       # Boot installed system (SSH port 2222)
├── cleanup-qemu.sh             # Clean QEMU artifacts
├── list-qemu-disk.sh           # List virtual disks
└── README.md                    # This file
```

## Installation Instructions

### Step 1: Boot from ISO

1. Write ISO to USB drive or mount in hypervisor
2. Boot from ISO
3. Wait for PBOS login screen

### Step 2: Connect to Network (if needed)

```bash
# For WiFi
setup-wifi

# Or manually
iwctl station wlan0 connect YOUR_SSID

# For Ethernet, usually auto-configured
ip addr show
```

### Step 3: Install Base System

```bash
install-arch
```

Follow the prompts:
- Select disk
- Enter username and password
- Wait for installation (5-10 minutes)

### Step 4: Reboot

Remove USB and reboot:
```bash
reboot
```

### Step 5: Complete Server Setup

After logging in:
```bash
cd ~/custom-setup
bash post-install.sh
```

Wait for server installation (10-15 minutes)

### Step 6: Final Reboot

```bash
reboot
```

Your server is now ready!

## Post-Installation Setup

### Connect via SSH

From another machine:
```bash
ssh username@<server-ip>
```

### Setup Tailscale VPN

```bash
sudo tailscale up
# Opens browser for authentication
```

Get your Tailscale IP:
```bash
tailscale ip -4
```

Now you can SSH via Tailscale from anywhere:
```bash
ssh username@<tailscale-ip>
```

### Configure Firewall

Allow additional ports:
```bash
# Allow HTTP
sudo ufw allow 80/tcp

# Allow HTTPS
sudo ufw allow 443/tcp

# Allow custom port
sudo ufw allow 8080/tcp

# Check status
sudo ufw status
```

### Start Using Docker

Test Docker:
```bash
docker run hello-world
```

Run a web server:
```bash
docker run -d -p 80:80 nginx
```

Use docker-compose:
```bash
cd /path/to/project
docker-compose up -d
```

## Server Management

### System Status

Check overall server status:
```bash
server-status
```

Shows:
- Uptime
- Memory usage
- Disk usage
- Network connections
- Docker status
- Active services

### Docker Management

View all Docker stats:
```bash
docker-stats
```

Shows:
- Running containers
- Docker images
- Resource usage

### Update System

Update all packages:
```bash
server-update
```

Updates:
- System packages (pacman)
- Python packages (pip)
- npm global packages

### Monitoring

Real-time system monitor:
```bash
htop  # or btop for modern UI
```

Network monitoring:
```bash
iftop   # Network bandwidth by connection
nethogs # Network bandwidth by process
```

Disk I/O monitoring:
```bash
iotop
```

## Use Cases

### Web Hosting

Host websites with Docker:
```bash
# WordPress
docker-compose up -d

# Static site with nginx
docker run -d -p 80:80 -v /path/to/site:/usr/share/nginx/html nginx
```

### Development Server

Run development environments:
```bash
# Node.js app
npm install
npm start

# Python app
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py

# Java app
javac MyApp.java
java MyApp
```

### Container Orchestration

Run microservices with Docker:
```bash
docker-compose -f docker-compose.yml up -d
docker ps
docker logs container-name
```

### Remote Development

Use as remote dev machine via Tailscale:
```bash
# From local machine
ssh -L 8080:localhost:8080 username@<tailscale-ip>
```

Now access server's port 8080 at localhost:8080

## Troubleshooting

### Can't SSH to Server

Check SSH is running:
```bash
sudo systemctl status sshd
```

Check firewall:
```bash
sudo ufw status
```

Check IP address:
```bash
ip addr show
```

### Docker Permission Denied

Add user to docker group (done automatically, but requires logout):
```bash
sudo usermod -aG docker $USER
# Logout and login again
```

Or use sudo:
```bash
sudo docker ps
```

### Tailscale Not Connecting

Check service status:
```bash
sudo systemctl status tailscaled
```

Restart service:
```bash
sudo systemctl restart tailscaled
sudo tailscale up
```

### Firewall Blocking Traffic

Check firewall rules:
```bash
sudo ufw status verbose
```

Allow specific port:
```bash
sudo ufw allow <port>/tcp
```

Temporarily disable (not recommended):
```bash
sudo ufw disable
```

## Security Best Practices

### 1. Change Default SSH Port

Edit `/etc/ssh/sshd_config`:
```bash
Port 2222
```

Update firewall:
```bash
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp
sudo systemctl restart sshd
```

### 2. Use SSH Keys

Generate key on local machine:
```bash
ssh-keygen -t ed25519
ssh-copy-id username@server-ip
```

Disable password authentication in `/etc/ssh/sshd_config`:
```bash
PasswordAuthentication no
```

### 3. Keep System Updated

Run regularly:
```bash
server-update
```

### 4. Enable Automatic Security Updates

Install unattended-upgrades equivalent for Arch:
```bash
# Coming soon in future updates
```

### 5. Monitor System Logs

Check for issues:
```bash
sudo journalctl -xe
sudo journalctl -u sshd -n 50
```

## Performance Tuning

### Already Applied

The following optimizations are pre-configured:
- BBR TCP congestion control
- Increased network buffers
- Optimized file descriptor limits
- Swappiness set to 10
- Security hardening enabled

### Additional Tuning

For high-traffic servers, consider:

1. **Increase connection tracking**:
```bash
# Already set to 262144 in kernel params
```

2. **Tune for your workload**:
- CPU-heavy: More cores, CPU governor
- Memory-heavy: More RAM, adjust swappiness
- I/O-heavy: SSD, adjust I/O scheduler

3. **Monitor and adjust**:
```bash
htop
iotop
iftop
```

## Comparison to Other Editions

| Feature | Server Edition | XFCE Edition (Jan12) | HyDE Edition (Nov21) |
|---------|---------------|---------------------|---------------------|
| Desktop | None (CLI) | XFCE | Hyprland |
| RAM Usage | ~100-200MB | ~400MB | ~1.5GB |
| Target | Servers | 4GB laptops | 8GB+ systems |
| Gaming | No | Yes | Yes |
| Docker | Yes | No | No |
| Remote Access | SSH + Tailscale | Optional | Optional |

## Why Server Edition?

PBOS Server Edition is designed for:
- **Web developers** running staging/dev servers
- **DevOps engineers** testing containerized apps
- **Homelab enthusiasts** self-hosting services
- **Students** learning server administration
- **Small businesses** needing affordable hosting

**Benefits:**
- Pre-configured for server use
- Minimal resource usage
- Security hardened by default
- Development tools included
- Docker ready out of the box

## Credits

Built on:
- Arch Linux
- Docker
- Python, Node.js, Java
- Tailscale
- OpenSSH
- UFW

## License

This is a custom Arch Linux distribution. Individual components retain their original licenses.

---

**PBOS Server Edition** - Professional server platform built on Arch Linux.
