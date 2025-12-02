#!/bin/bash

# First Boot Automation Script for CustomOS
# Automatically checks network, connects WiFi if needed, and runs post-install

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if setup is already complete
if [ -f ~/.setup-complete ]; then
    # Setup already done, exit silently
    exit 0
fi

clear
echo -e "${MAGENTA}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║         Welcome to PBOS (Parteek Bindra OS)               ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}Base system installed successfully!${NC}"
echo ""
echo -e "${YELLOW}→${NC} Starting automated post-installation setup..."
echo ""
echo "This will:"
echo "  • Check network connectivity"
echo "  • Help you connect to WiFi if needed"
echo "  • Install HyDE desktop environment"
echo "  • Install CachyOS performance kernel"
echo "  • Configure zram swap"
echo "  • Install all fonts and dependencies"
echo ""

# Function to check internet connectivity
check_internet() {
    local urls=("https://archlinux.org" "https://github.com" "http://1.1.1.1")

    # Try HTTP checks with curl
    if command -v curl &>/dev/null; then
        for url in "${urls[@]}"; do
            if curl --silent --head --fail --connect-timeout 5 --max-time 10 "$url" >/dev/null 2>&1; then
                return 0
            fi
        done
    fi

    # Fallback to ping
    if command -v ping &>/dev/null; then
        if ping -c 1 -W 3 archlinux.org &>/dev/null 2>&1 || ping -c 1 -W 3 1.1.1.1 &>/dev/null 2>&1; then
            return 0
        fi
    fi

    return 1
}

# Check for internet connectivity
echo -e "${YELLOW}→${NC} Checking internet connectivity..."
if check_internet; then
    echo -e "${GREEN}✓${NC} Internet connection detected!"
    echo ""
else
    echo -e "${YELLOW}!${NC} No internet connection detected"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Post-installation requires internet to download packages.${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Let's connect to WiFi now..."
    echo ""

    # Wait a moment for user to read
    sleep 2

    # Check if wifi-setup.sh exists
    if [ -f "$SCRIPT_DIR/wifi-setup.sh" ]; then
        echo -e "${BLUE}Running WiFi setup wizard...${NC}"
        echo ""
        bash "$SCRIPT_DIR/wifi-setup.sh"

        # Check again after WiFi setup
        echo ""
        echo -e "${YELLOW}→${NC} Verifying internet connectivity..."
        if check_internet; then
            echo -e "${GREEN}✓${NC} Successfully connected to internet!"
            echo ""
        else
            echo -e "${RED}✗${NC} Still no internet connection"
            echo ""
            echo "Please connect to internet manually and then run:"
            echo -e "  ${GREEN}cd ~/custom-setup && bash post-install.sh${NC}"
            echo ""
            exit 1
        fi
    else
        echo -e "${RED}✗${NC} WiFi setup script not found!"
        echo ""
        echo "Please connect to internet manually using one of these methods:"
        echo ""
        echo -e "${YELLOW}Method 1: NetworkManager (nmcli)${NC}"
        echo "  nmcli device wifi list"
        echo "  nmcli device wifi connect \"SSID\" password \"PASSWORD\""
        echo ""
        echo -e "${YELLOW}Method 2: iwd (iwctl)${NC}"
        echo "  iwctl"
        echo "  station wlan0 scan"
        echo "  station wlan0 get-networks"
        echo "  station wlan0 connect \"SSID\""
        echo ""
        echo "Then run:"
        echo -e "  ${GREEN}cd ~/custom-setup && bash post-install.sh${NC}"
        echo ""
        exit 1
    fi
fi

# Internet is available, proceed with post-install
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Ready to proceed with post-installation!${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Starting HyDE desktop environment installation in 3 seconds..."
sleep 3

# Check if post-install.sh exists and run it
if [ -f "$SCRIPT_DIR/post-install.sh" ]; then
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Running post-installation script...${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    bash "$SCRIPT_DIR/post-install.sh"

    # Check if post-install was successful
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓${NC} Post-installation completed successfully!"
        echo ""
    else
        echo ""
        echo -e "${RED}✗${NC} Post-installation encountered errors"
        echo ""
        echo "You can re-run the post-install script manually:"
        echo -e "  ${GREEN}cd ~/custom-setup && bash post-install.sh${NC}"
        echo ""
        exit 1
    fi
else
    echo -e "${RED}✗${NC} Post-install script not found at: $SCRIPT_DIR/post-install.sh"
    echo ""
    echo "Please check the installation and run post-install manually."
    exit 1
fi
