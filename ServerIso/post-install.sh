#!/bin/bash

# PBOS Server Edition Post-Installation Script
# Optimized for 24/7 server use - CLI only

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
MAGENTA="\033[0;35m"
NC="\033[0m"

clear
echo -e "${MAGENTA}"
cat << 'EOF_BANNER'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ██████╗ ██████╗  ██████╗ ███████╗                      ║
║   ██╔══██╗██╔══██╗██╔═══██╗██╔════╝                      ║
║   ██████╔╝██████╔╝██║   ██║███████╗                      ║
║   ██╔═══╝ ██╔══██╗██║   ██║╚════██║                      ║
║   ██║     ██████╔╝╚██████╔╝███████║                      ║
║   ╚═╝     ╚═════╝  ╚═════╝ ╚══════╝                      ║
║                                                           ║
║              Server Edition                               ║
║         Optimized for 24/7 Server Use                     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF_BANNER

echo -e "${NC}"

echo ""
echo -e "${GREEN}Installing PBOS Server Edition...${NC}"
echo -e "${YELLOW}CLI-only system optimized for server workloads.${NC}"
echo ""
read -p "Press ENTER to continue..."

# Check internet
require_internet() {
    echo ""
    echo -e "${YELLOW}→${NC} Checking internet connectivity..."

    local attempts=3
    local delay=5
    local urls=("https://archlinux.org" "https://github.com" "http://1.1.1.1")

    for attempt in $(seq 1 "$attempts"); do
        echo -e "${BLUE}Attempt ${attempt}/${attempts}...${NC}"

        if command -v curl &>/dev/null; then
            for url in "${urls[@]}"; do
                if curl --silent --head --fail --connect-timeout 5 --max-time 10 "$url" >/dev/null; then
                    echo -e "${GREEN}✓${NC} Internet connection detected"
                    return 0
                fi
            done
        fi

        if command -v ping &>/dev/null; then
            if ping -c 1 -W 3 archlinux.org &>/dev/null || ping -c 1 -W 3 1.1.1.1 &>/dev/null; then
                echo -e "${GREEN}✓${NC} Internet connection detected"
                return 0
            fi
        fi

        if [ "$attempt" -lt "$attempts" ]; then
            echo -e "${YELLOW}No connection detected yet. Retrying in ${delay}s...${NC}"
            sleep "$delay"
        fi
    done

    echo -e "${RED}✗${NC} No internet connection after ${attempts} attempts!"
    echo -e "${YELLOW}Server installation requires internet. Please connect and rerun.${NC}"
    exit 1
}

require_internet

# Update system
echo ""
echo -e "${YELLOW}→${NC} Updating system packages..."
sudo pacman -Syu --noconfirm

# Install essential server packages
echo ""
echo -e "${YELLOW}→${NC} Installing essential server packages..."
sudo pacman -S --needed --noconfirm \
    base-devel \
    linux-headers \
    openssh \
    sudo \
    wget \
    curl \
    git \
    vim \
    neovim \
    nano \
    htop \
    btop \
    fastfetch \
    tmux \
    screen \
    rsync \
    unzip \
    zip \
    p7zip \
    man-db \
    man-pages

# Install Python
echo ""
echo -e "${YELLOW}→${NC} Installing Python development environment..."
sudo pacman -S --needed --noconfirm \
    python \
    python-pip \
    python-virtualenv \
    python-setuptools

# Install Node.js and npm
echo ""
echo -e "${YELLOW}→${NC} Installing Node.js and npm..."
sudo pacman -S --needed --noconfirm \
    nodejs \
    npm

# Install Java (JDK for servers - includes JRE)
echo ""
echo -e "${YELLOW}→${NC} Installing Java Development Kit..."
sudo pacman -S --needed --noconfirm \
    jdk-openjdk

# Install Docker
echo ""
echo -e "${YELLOW}→${NC} Installing Docker..."
sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose

# Enable and start Docker
echo ""
echo -e "${YELLOW}→${NC} Enabling Docker service..."
sudo systemctl enable docker
echo -e "${GREEN}✓${NC} Docker will start on boot"

# Add current user to docker group
CURRENT_USER=$(whoami)
if [ "$CURRENT_USER" != "root" ]; then
    sudo usermod -aG docker "$CURRENT_USER"
    echo -e "${GREEN}✓${NC} Added $CURRENT_USER to docker group (logout/login required)"
fi

# Install Tailscale
echo ""
echo -e "${YELLOW}→${NC} Installing Tailscale VPN..."
sudo pacman -S --needed --noconfirm tailscale
sudo systemctl enable --now tailscaled
echo -e "${GREEN}✓${NC} Tailscale installed and enabled"

# Install monitoring tools
echo ""
echo -e "${YELLOW}→${NC} Installing server monitoring tools..."
sudo pacman -S --needed --noconfirm \
    iotop \
    iftop \
    nethogs \
    ncdu \
    lsof \
    strace

# Enable SSH
echo ""
echo -e "${YELLOW}→${NC} Configuring SSH server..."
sudo systemctl enable sshd

# Configure SSH for better security
sudo tee -a /etc/ssh/sshd_config.d/pbos-server.conf >/dev/null <<'EOF_SSH'
# PBOS Server SSH Configuration
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/ssh/sftp-server
EOF_SSH

echo -e "${GREEN}✓${NC} SSH configured (root login disabled, X11 forwarding disabled)"

# Install and configure firewall
echo ""
echo -e "${YELLOW}→${NC} Installing and configuring firewall..."
sudo pacman -S --needed --noconfirm ufw

# Configure basic firewall rules
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable
sudo systemctl enable ufw

echo -e "${GREEN}✓${NC} Firewall enabled (SSH allowed)"

# Disable unnecessary services for server
echo ""
echo -e "${YELLOW}→${NC} Optimizing for server use..."

# Services to disable on a headless server
DISABLE_SERVICES=(
    "bluetooth.service"
    "cups.service"
    "avahi-daemon.service"
)

for service in "${DISABLE_SERVICES[@]}"; do
    if systemctl is-enabled "$service" &>/dev/null; then
        sudo systemctl disable "$service" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Disabled $service"
    fi
done

# Performance tuning for servers
echo ""
echo -e "${YELLOW}→${NC} Applying server performance tuning..."

# Increase file descriptor limits
sudo tee /etc/security/limits.d/pbos-server.conf >/dev/null <<'EOF_LIMITS'
# PBOS Server Limits
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
EOF_LIMITS

# Sysctl tuning for servers
sudo tee /etc/sysctl.d/99-pbos-server.conf >/dev/null <<'EOF_SYSCTL'
# PBOS Server Kernel Parameters

# Network Performance
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq

# Connection Tracking
net.netfilter.nf_conntrack_max = 262144
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_tw_reuse = 1

# File System
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288

# Virtual Memory (for servers)
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# Security
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
EOF_SYSCTL

sudo sysctl -p /etc/sysctl.d/99-pbos-server.conf >/dev/null 2>&1 || true

echo -e "${GREEN}✓${NC} Server performance tuning applied"

# Create server management scripts
echo ""
echo -e "${YELLOW}→${NC} Creating server management scripts..."

# System status script
sudo tee /usr/local/bin/server-status << 'EOF_STATUS' >/dev/null
#!/bin/bash
# PBOS Server Status

echo "======================================"
echo "  PBOS Server Status"
echo "======================================"
echo ""
echo "Uptime:"
uptime
echo ""
echo "Memory Usage:"
free -h
echo ""
echo "Disk Usage:"
df -h / /home 2>/dev/null | grep -v tmpfs
echo ""
echo "Network Connections:"
ss -tuln | grep LISTEN | wc -l | xargs echo "Listening ports:"
echo ""
echo "Docker Status:"
if systemctl is-active docker >/dev/null 2>&1; then
    echo "Docker: Running"
    docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo "No containers"
else
    echo "Docker: Stopped"
fi
echo ""
echo "Active Services:"
systemctl list-units --type=service --state=running --no-pager | head -n 10
EOF_STATUS
sudo chmod +x /usr/local/bin/server-status

# Docker management helper
sudo tee /usr/local/bin/docker-stats << 'EOF_DOCKER' >/dev/null
#!/bin/bash
# Quick Docker Stats

echo "Docker Containers:"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "Docker Images:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
echo ""
echo "Docker Resource Usage:"
docker stats --no-stream
EOF_DOCKER
sudo chmod +x /usr/local/bin/docker-stats

# Update script
sudo tee /usr/local/bin/server-update << 'EOF_UPDATE' >/dev/null
#!/bin/bash
# PBOS Server Update Script

echo "Updating PBOS Server..."
echo ""

echo "→ Updating system packages..."
sudo pacman -Syu --noconfirm

echo ""
echo "→ Updating Python packages..."
pip list --outdated 2>/dev/null || true

echo ""
echo "→ Updating npm packages..."
sudo npm update -g 2>/dev/null || true

echo ""
echo "✓ Update complete!"
echo ""
echo "Reboot recommended if kernel was updated."
EOF_UPDATE
sudo chmod +x /usr/local/bin/server-update

echo -e "${GREEN}✓${NC} Server management scripts created"

cd "$SCRIPT_DIR"

clear
echo -e "${MAGENTA}"
cat << 'EOF_DONE'
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║         ✨ PBOS Server Setup Complete! ✨            ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
EOF_DONE
echo -e "${NC}"

echo ""
echo -e "${GREEN}✓${NC} Server installation complete!"
echo ""

# Mark setup as complete
touch ~/.setup-complete

echo -e "${YELLOW}Installed components:${NC}"
echo -e "  ${GREEN}✓${NC} Python (with pip and virtualenv)"
echo -e "  ${GREEN}✓${NC} Docker (with docker-compose)"
echo -e "  ${GREEN}✓${NC} Node.js and npm"
echo -e "  ${GREEN}✓${NC} Java JDK"
echo -e "  ${GREEN}✓${NC} Tailscale VPN"
echo -e "  ${GREEN}✓${NC} SSH Server (secured)"
echo -e "  ${GREEN}✓${NC} UFW Firewall (enabled)"
echo -e "  ${GREEN}✓${NC} Server monitoring tools"
echo ""

echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  ${GREEN}server-status${NC}       - View system status"
echo -e "  ${GREEN}docker-stats${NC}        - View Docker containers and stats"
echo -e "  ${GREEN}server-update${NC}       - Update all system packages"
echo -e "  ${GREEN}sudo tailscale up${NC}   - Connect to Tailscale VPN"
echo -e "  ${GREEN}sudo ufw status${NC}     - Check firewall status"
echo -e "  ${GREEN}htop${NC} / ${GREEN}btop${NC}          - System monitor"
echo ""

echo -e "${YELLOW}SSH Access:${NC}"
echo -e "  ${BLUE}→${NC} SSH is enabled and will start on boot"
echo -e "  ${BLUE}→${NC} Connect: ${GREEN}ssh username@<server-ip>${NC}"
echo -e "  ${BLUE}→${NC} Root login disabled for security"
echo ""

echo -e "${YELLOW}Docker:${NC}"
echo -e "  ${BLUE}→${NC} Docker service will start on boot"
echo -e "  ${BLUE}→${NC} User added to docker group (logout/login required)"
echo -e "  ${BLUE}→${NC} Test: ${GREEN}docker run hello-world${NC}"
echo ""

echo -e "${YELLOW}Firewall:${NC}"
echo -e "  ${BLUE}→${NC} UFW firewall enabled"
echo -e "  ${BLUE}→${NC} SSH port (22) allowed"
echo -e "  ${BLUE}→${NC} Add rules: ${GREEN}sudo ufw allow <port>${NC}"
echo ""

echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Type ${GREEN}reboot${NC} to restart"
echo -e "  2. SSH into your server"
echo -e "  3. Run ${GREEN}sudo tailscale up${NC} to connect VPN"
echo -e "  4. Start deploying Docker containers!"
echo ""
echo -e "${BLUE}Note:${NC} If you need to re-run this script, just execute:"
echo -e "  ${GREEN}cd ~/custom-setup && bash post-install.sh${NC}"
echo ""
