#!/bin/bash

# WiFi Setup Script for Arch ISO
# Helps connect to WiFi during installation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║          WiFi Setup for CustomOS Installation             ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${YELLOW}This script will help you connect to WiFi.${NC}"
echo ""
echo "Choose your setup method:"
echo "  1) Quick setup (one-liner - requires SSID and password)"
echo "  2) Interactive setup (step-by-step guide)"
echo "  3) Manual instructions only"
echo ""
read -p "Select option (1-3): " OPTION

case $OPTION in
    1)
        echo ""
        echo -e "${BLUE}Quick WiFi Setup${NC}"
        echo ""

        # List available devices
        echo "Available wireless devices:"
        iwctl device list
        echo ""

        read -p "Enter wireless device name (usually wlan0): " DEVICE
        DEVICE=${DEVICE:-wlan0}

        echo ""
        echo "Scanning for networks..."
        iwctl station $DEVICE scan
        sleep 2

        echo ""
        echo "Available networks:"
        iwctl station $DEVICE get-networks
        echo ""

        read -p "Enter WiFi SSID (network name): " SSID
        read -sp "Enter WiFi password: " PASSWORD
        echo ""

        echo ""
        echo -e "${YELLOW}→${NC} Connecting to $SSID..."

        # Connect using one-liner
        if iwctl --passphrase "$PASSWORD" station $DEVICE connect "$SSID"; then
            echo -e "${GREEN}✓${NC} Successfully connected to $SSID"
            echo ""
            echo "Testing connection..."
            sleep 2
            if ping -c 3 google.com; then
                echo ""
                echo -e "${GREEN}✓${NC} Internet connection verified!"
                echo ""
                echo "You can now proceed with the installation."
            else
                echo ""
                echo -e "${YELLOW}!${NC} Connected to WiFi but internet test failed."
                echo "This might be normal if your network requires additional setup."
            fi
        else
            echo -e "${RED}✗${NC} Failed to connect to $SSID"
            echo ""
            echo "Please check:"
            echo "  - SSID is correct (case-sensitive)"
            echo "  - Password is correct"
            echo "  - Network is in range"
            exit 1
        fi
        ;;

    2)
        echo ""
        echo -e "${BLUE}Interactive WiFi Setup${NC}"
        echo ""
        echo "Starting iwctl interactive mode..."
        echo ""
        echo -e "${YELLOW}In the iwctl prompt, run these commands:${NC}"
        echo ""
        echo "  1. device list              # List your wireless devices"
        echo "  2. station wlan0 scan       # Scan for networks (replace wlan0 if needed)"
        echo "  3. station wlan0 get-networks   # Show available networks"
        echo "  4. station wlan0 connect YOUR_SSID   # Connect (it will ask for password)"
        echo "  5. exit                     # Exit iwctl when done"
        echo ""
        echo -e "${YELLOW}Press ENTER to start iwctl...${NC}"
        read

        iwctl

        echo ""
        echo "Testing connection..."
        if ping -c 3 google.com; then
            echo ""
            echo -e "${GREEN}✓${NC} Internet connection verified!"
        else
            echo ""
            echo -e "${YELLOW}!${NC} Internet test failed."
            echo "Run: ping -c 3 google.com"
            echo "to test your connection manually."
        fi
        ;;

    3)
        echo ""
        echo -e "${BLUE}Manual WiFi Setup Instructions${NC}"
        echo ""
        echo "To connect to WiFi from the Arch ISO, use iwctl:"
        echo ""
        echo -e "${YELLOW}Method 1: One-liner (fastest)${NC}"
        echo "  iwctl --passphrase YOUR_PASSWORD station wlan0 connect YOUR_SSID"
        echo ""
        echo -e "${YELLOW}Method 2: Interactive${NC}"
        echo "  1. Run: iwctl"
        echo "  2. In iwctl prompt:"
        echo "     device list"
        echo "     station wlan0 scan"
        echo "     station wlan0 get-networks"
        echo "     station wlan0 connect YOUR_SSID"
        echo "  3. Enter password when prompted"
        echo "  4. Type: exit"
        echo ""
        echo -e "${YELLOW}Verify connection:${NC}"
        echo "  ping -c 3 google.com"
        echo ""
        echo -e "${YELLOW}Troubleshooting:${NC}"
        echo "  - If wlan0 doesn't exist, check 'device list' for your device name"
        echo "  - Some devices may be named wlp2s0, wlp3s0, etc."
        echo "  - SSID is case-sensitive"
        echo "  - Use quotes if SSID or password contains spaces"
        echo ""
        ;;

    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}WiFi setup complete!${NC}"
echo ""
