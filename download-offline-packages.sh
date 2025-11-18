#!/bin/bash

# Offline Package Downloader for CustomOS
# Downloads ALL packages needed for a fully offline installation
# Run this on a system with internet connection (Endeavour OS, Arch, etc.)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="$SCRIPT_DIR/offline-packages"

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   Offline Package Downloader for CustomOS                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${YELLOW}This will download ALL packages for offline installation${NC}"
echo -e "${YELLOW}Total download size: ~3-4 GB${NC}"
echo ""

# Check if running on Arch-based system
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}✗${NC} This script must be run on an Arch-based system!"
    echo "  (Endeavour OS, Arch Linux, Manjaro, etc.)"
    exit 1
fi

read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    exit 0
fi

# Create cache directory
echo ""
echo -e "${YELLOW}→${NC} Creating cache directory: $CACHE_DIR"
mkdir -p "$CACHE_DIR"

# Complete package list (matches post-install.sh exactly)
PACKAGES=(
    # Base system packages (for pacstrap)
    base
    base-devel
    linux
    linux-firmware
    vim
    networkmanager
    sudo
    git

    # Hyprland and Wayland
    hyprland
    waybar
    mako
    wofi
    rofi-wayland
    kitty
    hyprpaper
    hyprlock
    hypridle
    swww

    # Applications
    firefox
    thunar
    ranger

    # System tools
    neovim
    htop
    btop

    # Network
    network-manager-applet

    # Audio
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    pamixer
    pavucontrol
    playerctl

    # Utilities
    brightnessctl
    grim
    slurp
    hyprpicker
    wl-clipboard
    cliphist
    wf-recorder
    imagemagick
    imv

    # PDF viewer
    zathura
    zathura-pdf-mupdf

    # Fonts
    ttf-dejavu
    ttf-liberation
    noto-fonts
    ttf-font-awesome
    ttf-jetbrains-mono
    noto-fonts-emoji

    # Theming
    python-pywal
    python-pillow

    # Shell
    zsh
    zsh-completions
    tmux
    ripgrep
    fd
    bat
    exa
    fzf

    # Bluetooth
    bluez
    bluez-utils
    blueman

    # VirtualBox guest utilities
    virtualbox-guest-utils

    # Wayland protocols
    wayland
    wayland-protocols
    xorg-xwayland

    # Additional utilities
    curl
    wget
    unzip
    zip
    tree
    jq
)

echo ""
echo -e "${BLUE}Package List:${NC}"
echo -e "${YELLOW}  Total packages: ${#PACKAGES[@]}${NC}"
echo ""

# Update package database
echo -e "${YELLOW}→${NC} Updating package database..."
sudo pacman -Sy

# Download packages
echo ""
echo -e "${YELLOW}→${NC} Downloading packages..."
echo -e "${BLUE}This will take 10-30 minutes depending on your connection...${NC}"
echo ""

# Use -Sw to download only (don't install)
sudo pacman -Sw --cachedir "$CACHE_DIR" --noconfirm "${PACKAGES[@]}"

# Copy from system cache to our cache
echo ""
echo -e "${YELLOW}→${NC} Copying packages from system cache..."
sudo cp -n /var/cache/pacman/pkg/*.pkg.tar.zst "$CACHE_DIR/" 2>/dev/null || true

# Fix permissions
echo -e "${YELLOW}→${NC} Fixing permissions..."
sudo chown -R $USER:$USER "$CACHE_DIR"

# Get statistics
PKG_COUNT=$(ls -1 "$CACHE_DIR"/*.pkg.tar.zst 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh "$CACHE_DIR" | cut -f1)

# Create a package list file
echo -e "${YELLOW}→${NC} Creating package list..."
ls -1 "$CACHE_DIR"/*.pkg.tar.zst | xargs -n1 basename > "$CACHE_DIR/package-list.txt"

# Create a repository database
echo -e "${YELLOW}→${NC} Creating repository database..."
cd "$CACHE_DIR"
repo-add custom.db.tar.gz *.pkg.tar.zst 2>/dev/null || true
cd "$SCRIPT_DIR"

# Create README
cat > "$CACHE_DIR/README.txt" << 'EOFREADME'
# Offline Package Cache for CustomOS

This directory contains all packages needed for offline installation.

## Contents:
- Package files: *.pkg.tar.zst
- Repository database: custom.db.tar.gz
- Package list: package-list.txt

## Usage:
1. Keep this folder: offline-packages/
2. Run: ./build-iso-docker.sh
3. The ISO will include these packages for offline installation

## Size Information:
See package-list.txt for complete list of packages.

EOFREADME

# Success!
clear
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ✓ Offline Package Cache Created!                       ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}✓${NC} Download complete!"
echo ""
echo "Statistics:"
echo "  Packages: $PKG_COUNT"
echo "  Total size: $TOTAL_SIZE"
echo "  Location: $CACHE_DIR"
echo ""
echo "Next steps:"
echo ""
echo "  ${BLUE}1.${NC} Build offline ISO:"
echo "     ${GREEN}./build-iso-docker.sh${NC}"
echo ""
echo "  ${BLUE}2.${NC} The ISO will automatically:"
echo "     - Detect offline packages"
echo "     - Include them in the ISO"
echo "     - Use them during installation"
echo ""
echo "  ${BLUE}3.${NC} Installation will work ${GREEN}WITHOUT INTERNET!${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} You can delete this cache after building the ISO"
echo "      (it will be embedded in the ISO file)"
echo ""
