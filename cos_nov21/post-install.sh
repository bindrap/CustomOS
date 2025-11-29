#!/bin/bash

# CustomOS Nov21 Post-Installation Script
# HyDE setup replacing custom Hyprland configuration

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
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║      ██╗  ██╗██╗   ██╗██████╗ ███████╗                 ║
║      ██║  ██║██║   ██║██╔══██╗██╔════╝                 ║
║      ███████║██║   ██║██████╔╝█████╗                   ║
║      ██╔══██║██║   ██║██╔══██╗██╔══╝                   ║
║      ██║  ██║╚██████╔╝██║  ██║███████╗                 ║
║      ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝                 ║
║                                                       ║
║          HyDE Desktop Environment Setup               ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
EOF_BANNER
echo -e "${NC}"

echo ""
echo -e "${GREEN}Installing HyDE desktop environment...${NC}"
echo -e "${YELLOW}This will replace the previous Hyprland-specific setup.${NC}"
echo ""
read -p "Press ENTER to continue..."

# Check internet
require_internet() {
    echo ""
    echo -e "${YELLOW}→${NC} Checking internet connectivity..."

    # Prefer an HTTP(S) check because ICMP can be blocked on some hypervisors/VMs
    local urls=("https://archlinux.org" "https://github.com")
    if command -v curl &>/dev/null; then
        for url in "${urls[@]}"; do
            if curl --silent --head --fail --connect-timeout 5 --max-time 10 "$url" >/dev/null; then
                echo -e "${GREEN}✓${NC} Internet connection detected"
                return 0
            fi
        done
    fi

    # Fallback to ICMP if HTTP checks are unavailable
    if command -v ping &>/dev/null; then
        if ping -c 1 -W 2 archlinux.org &>/dev/null || ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
            echo -e "${GREEN}✓${NC} Internet connection detected"
            return 0
        fi
    fi

    echo -e "${RED}✗${NC} No internet connection!"
    echo -e "${YELLOW}HyDE and Chaotic-AUR installs require internet. Please connect and rerun.${NC}"
    exit 1
}

require_internet

# Update system
echo ""
echo -e "${YELLOW}→${NC} Updating system packages..."
sudo pacman -Syu --noconfirm

echo ""
echo -e "${YELLOW}→${NC} Installing HyDE build prerequisites (git, base-devel)..."
sudo pacman -S --needed --noconfirm git base-devel

require_internet

echo ""
echo -e "${YELLOW}→${NC} Fetching HyDE repository..."
HYDE_DIR="$HOME/HyDE"
if [ -d "$HYDE_DIR/.git" ]; then
    echo -e "${BLUE}HyDE repository already exists, updating...${NC}"
    git -C "$HYDE_DIR" pull --ff-only || {
        echo -e "${RED}Failed to update existing HyDE repo. Remove $HYDE_DIR and rerun.${NC}"
        exit 1
    }
else
    rm -rf "$HYDE_DIR"
    git clone --depth 1 https://github.com/HyDE-Project/HyDE "$HYDE_DIR"
fi

echo ""
echo -e "${YELLOW}→${NC} Running HyDE installer..."
cd "$HYDE_DIR/Scripts"
./install.sh

echo ""
echo -e "${YELLOW}→${NC} Optional: run hydevm helper for VM testing and development?${NC}"
read -p "Type 'yes' to run hydevm (recommended for Arch VMs): " RUN_HYDEVM
if [ "$RUN_HYDEVM" == "yes" ]; then
    require_internet
    echo -e "${BLUE}Downloading hydevm utility...${NC}"
    curl -L https://raw.githubusercontent.com/HyDE-Project/HyDE/main/Scripts/hydevm/hydevm.sh -o hydevm
    chmod +x hydevm
    ./hydevm
else
    echo -e "${YELLOW}Skipping hydevm helper.${NC}"
fi

cd "$SCRIPT_DIR"

clear
echo -e "${MAGENTA}"
cat << 'EOF_DONE'
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║              ✨ HyDE Setup Complete! ✨               ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
EOF_DONE
echo -e "${NC}"

echo ""
echo -e "${GREEN}✓${NC} HyDE installation complete!"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Type ${GREEN}reboot${NC} to restart"
echo -e "  2. Log in and enjoy the HyDE desktop environment"
echo ""
