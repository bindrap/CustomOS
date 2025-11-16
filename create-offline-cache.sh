#!/bin/bash

# Create Offline Package Cache
# Downloads all packages needed for offline installation

set -e

CACHE_DIR="$HOME/offline-packages"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔════════════════════════════════════════════╗"
echo "║  Offline Package Cache Creator             ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Create cache directory
mkdir -p "$CACHE_DIR"
cd "$CACHE_DIR"

echo "→ Downloading packages to: $CACHE_DIR"
echo ""

# Complete package list
PACKAGES=(
    # Base system
    base base-devel linux linux-firmware
    vim nano networkmanager sudo git
    
    # Wayland & Hyprland
    wayland wayland-protocols
    hyprland
    xorg-xwayland
    
    # VirtualBox (optional, comment out if not needed)
    virtualbox-guest-utils
    
    # Hyprland tools
    hyprpaper
    hyprlock
    hypridle
    
    # Status bar & notifications
    waybar
    mako
    
    # App launchers & menus
    wofi
    
    # Terminal
    kitty
    zsh zsh-completions
    
    # File managers
    thunar
    ranger
    
    # Browsers
    firefox
    
    # Audio
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    pamixer
    pavucontrol
    playerctl
    
    # Bluetooth
    bluez
    bluez-utils
    blueman
    
    # Network
    network-manager-applet
    
    # Screenshots & screen tools
    grim
    slurp
    hyprpicker
    wl-clipboard
    cliphist
    
    # System monitoring
    btop
    htop
    
    # Utilities
    brightnessctl
    curl
    wget
    jq
    unzip
    zip
    tree
    
    # Fonts
    ttf-dejavu
    ttf-liberation
    noto-fonts
    ttf-font-awesome
    ttf-jetbrains-mono
    noto-fonts-emoji
    
    # Image viewer
    imv
    
    # PDF viewer
    zathura
    zathura-pdf-mupdf
    
    # Text editor
    neovim
    
    # Development tools
    python
    python-pip
    nodejs
    npm
    docker
    docker-compose
    tmux
    ripgrep
    fd
    bat
    exa
    fzf
)

echo "→ Package count: ${#PACKAGES[@]}"
echo ""

# Download packages (without installing)
echo "→ Downloading packages..."
sudo pacman -Sw --cachedir "$CACHE_DIR" --noconfirm "${PACKAGES[@]}"

echo ""
echo "→ Organizing packages..."

# Copy packages from pacman cache to our cache
sudo cp /var/cache/pacman/pkg/*.pkg.tar.zst "$CACHE_DIR/" 2>/dev/null || true

# Fix permissions
sudo chown -R $USER:$USER "$CACHE_DIR"

# Count packages
PKG_COUNT=$(ls -1 "$CACHE_DIR"/*.pkg.tar.zst 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh "$CACHE_DIR" | cut -f1)

echo ""
echo "✓ Package cache created!"
echo ""
echo "Statistics:"
echo "  Packages downloaded: $PKG_COUNT"
echo "  Total size: $TOTAL_SIZE"
echo "  Location: $CACHE_DIR"
echo ""

# Create package database
echo "→ Creating package database..."
cd "$CACHE_DIR"
repo-add custom.db.tar.gz *.pkg.tar.zst

echo ""
echo "✓ Offline package cache is ready!"
echo ""
echo "Next steps:"
echo "  1. This cache will be bundled in your ISO"
echo "  2. Run: bash build-iso.sh"
echo ""
