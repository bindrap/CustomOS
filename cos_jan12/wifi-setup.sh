#!/bin/bash

# WiFi Setup Script for CustomOS
# Works in both Arch ISO (iwctl) and post-install (nmcli) environments

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

# Detect which WiFi tool to use
if command -v nmcli &> /dev/null && systemctl is-active --quiet NetworkManager 2>/dev/null; then
    WIFI_TOOL="nmcli"
    echo -e "${GREEN}Detected NetworkManager (post-install environment)${NC}"
elif command -v iwctl &> /dev/null; then
    WIFI_TOOL="iwctl"
    echo -e "${GREEN}Detected iwd (Arch ISO environment)${NC}"
else
    echo -e "${RED}✗${NC} No WiFi tools found (neither nmcli nor iwctl)"
    echo "Please install NetworkManager or iwd"
    exit 1
fi

echo ""
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

        if [ "$WIFI_TOOL" = "nmcli" ]; then
            # NetworkManager method
            echo "Scanning for networks..."
            nmcli device wifi rescan 2>/dev/null || true
            sleep 2

            echo ""
            echo "Available networks:"
            nmcli device wifi list
            echo ""

            read -p "Enter WiFi SSID (network name): " SSID
            read -sp "Enter WiFi password: " PASSWORD
            echo ""

            echo ""
            echo -e "${YELLOW}→${NC} Connecting to $SSID..."

            if nmcli device wifi connect "$SSID" password "$PASSWORD"; then
                echo -e "${GREEN}✓${NC} Successfully connected to $SSID"
                echo ""
                echo "Testing connection..."
                sleep 2
                if ping -c 3 google.com; then
                    echo ""
                    echo -e "${GREEN}✓${NC} Internet connection verified!"
                    echo ""
                    echo "You can now proceed with your work."
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

        else
            # iwctl method (ISO environment)
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
        fi
        ;;

    2)
        echo ""
        echo -e "${BLUE}Interactive WiFi Setup${NC}"
        echo ""

        if [ "$WIFI_TOOL" = "nmcli" ]; then
            # NetworkManager interactive
            echo "This will show you available networks and let you choose."
            echo ""
            echo "Available networks:"
            nmcli device wifi list
            echo ""
            read -p "Enter SSID to connect: " SSID
            read -sp "Enter password: " PASSWORD
            echo ""

            if nmcli device wifi connect "$SSID" password "$PASSWORD"; then
                echo -e "${GREEN}✓${NC} Connected successfully!"
                echo ""
                echo "Testing connection..."
                if ping -c 3 google.com; then
                    echo -e "${GREEN}✓${NC} Internet connection verified!"
                else
                    echo -e "${YELLOW}!${NC} Internet test failed."
                fi
            else
                echo -e "${RED}✗${NC} Connection failed"
            fi
        else
            # iwctl interactive
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
        fi
        ;;

    3)
        echo ""
        echo -e "${BLUE}Manual WiFi Setup Instructions${NC}"
        echo ""

        if [ "$WIFI_TOOL" = "nmcli" ]; then
            echo "Using NetworkManager (nmcli):"
            echo ""
            echo -e "${YELLOW}Method 1: One-liner (fastest)${NC}"
            echo "  nmcli device wifi connect \"YOUR_SSID\" password \"YOUR_PASSWORD\""
            echo ""
            echo -e "${YELLOW}Method 2: Step-by-step${NC}"
            echo "  1. List available networks:"
            echo "     nmcli device wifi list"
            echo ""
            echo "  2. Connect to network:"
            echo "     nmcli device wifi connect \"YOUR_SSID\" password \"YOUR_PASSWORD\""
            echo ""
            echo -e "${YELLOW}Method 3: Interactive editor${NC}"
            echo "  nmcli connection edit type wifi"
            echo "  (Follow prompts)"
            echo ""
            echo -e "${YELLOW}Check connection status:${NC}"
            echo "  nmcli device status"
            echo "  nmcli connection show"
            echo ""
            echo -e "${YELLOW}Verify internet:${NC}"
            echo "  ping -c 3 google.com"
            echo ""
        else
            echo "Using iwd (iwctl) for Arch ISO:"
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
        fi

        echo -e "${YELLOW}Troubleshooting:${NC}"
        echo "  - SSID is case-sensitive"
        echo "  - Use quotes if SSID or password contains spaces"
        echo "  - Device names: wlan0, wlp2s0, wlp3s0, etc."
        echo "  - If NetworkManager not running: sudo systemctl start NetworkManager"
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
