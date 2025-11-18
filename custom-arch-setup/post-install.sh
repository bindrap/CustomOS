#!/bin/bash

# Post-Installation Script
# Automatically installs and configures Hyprland + all dotfiles
# This runs on first login after base system installation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ██████╗  █████╗ ██████╗ ████████╗███████╗███████╗██╗  ██╗║
║   ██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔════╝██║ ██╔╝║
║   ██████╔╝███████║██████╔╝   ██║   █████╗  █████╗  █████╔╝ ║
║   ██╔═══╝ ██╔══██║██╔══██╗   ██║   ██╔══╝  ██╔══╝  ██╔═██╗ ║
║   ██║     ██║  ██║██║  ██║   ██║   ███████╗███████╗██║  ██╗║
║   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝║
║                                                           ║
║           CustomOS Setup - Final Configuration            ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}Welcome to your Custom Arch Linux setup!${NC}"
echo -e "${YELLOW}This will install Hyprland and all customizations...${NC}"
echo ""
echo -e "${BLUE}This will take about 5-10 minutes.${NC}"
echo ""
read -p "Press ENTER to continue..."

# Check internet connectivity and offline packages
echo ""
echo -e "${YELLOW}→${NC} Detecting installation mode..."
INSTALL_MODE="offline"
OFFLINE_PKG_DIR="$SCRIPT_DIR/packages"

if ping -c 2 archlinux.org &>/dev/null; then
    INSTALL_MODE="online"
    echo -e "${GREEN}✓${NC} Internet connection detected - Using online installation"
elif [ -d "$OFFLINE_PKG_DIR" ] && [ "$(ls -A $OFFLINE_PKG_DIR/*.pkg.tar.zst 2>/dev/null | wc -l)" -gt 0 ]; then
    INSTALL_MODE="offline"
    PKG_COUNT=$(ls -1 $OFFLINE_PKG_DIR/*.pkg.tar.zst 2>/dev/null | wc -l)
    echo -e "${YELLOW}!${NC} No internet - Using offline packages ($PKG_COUNT packages)"
else
    echo -e "${RED}✗${NC} No internet connection and no offline packages!"
    echo ""
    echo "Please either:"
    echo "  1. Connect to the internet, OR"
    echo "  2. Use an offline ISO with packages included"
    echo ""
    exit 1
fi

# Set up offline repository if needed
if [ "$INSTALL_MODE" = "offline" ]; then
    echo -e "${YELLOW}→${NC} Setting up offline package repository..."

    # Create local repository configuration
    sudo mkdir -p /var/cache/pacman/pkg-offline
    sudo cp $OFFLINE_PKG_DIR/*.pkg.tar.zst /var/cache/pacman/pkg-offline/

    # Create repo database if not exists
    if [ ! -f "$OFFLINE_PKG_DIR/custom.db.tar.gz" ]; then
        cd $OFFLINE_PKG_DIR
        sudo repo-add custom.db.tar.gz *.pkg.tar.zst
        cd -
    fi

    # Add custom repository to pacman.conf
    if ! grep -q "\[custom-offline\]" /etc/pacman.conf; then
        echo "" | sudo tee -a /etc/pacman.conf
        echo "[custom-offline]" | sudo tee -a /etc/pacman.conf
        echo "SigLevel = Never" | sudo tee -a /etc/pacman.conf
        echo "Server = file://$OFFLINE_PKG_DIR" | sudo tee -a /etc/pacman.conf
    fi

    # Update package database
    sudo pacman -Sy
    echo -e "${GREEN}✓${NC} Offline repository configured"
fi

# Update system (only if online)
if [ "$INSTALL_MODE" = "online" ]; then
    echo ""
    echo -e "${YELLOW}→${NC} Updating system packages..."
    sudo pacman -Syu --noconfirm
fi

# Install Hyprland and all required packages
echo ""
echo -e "${YELLOW}→${NC} Installing Hyprland and all packages..."
if [ "$INSTALL_MODE" = "online" ]; then
    echo -e "${BLUE}This may take 5-10 minutes...${NC}"
else
    echo -e "${BLUE}Installing from offline cache...${NC}"
fi

sudo pacman -S --needed --noconfirm \
    hyprland \
    waybar \
    mako \
    wofi \
    rofi-wayland \
    kitty \
    hyprpaper \
    hyprlock \
    hypridle \
    swww \
    firefox \
    thunar \
    ranger \
    git \
    neovim \
    htop \
    btop \
    networkmanager \
    network-manager-applet \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber \
    pamixer \
    pavucontrol \
    playerctl \
    brightnessctl \
    grim \
    slurp \
    hyprpicker \
    wl-clipboard \
    cliphist \
    wf-recorder \
    imagemagick \
    imv \
    zathura \
    zathura-pdf-mupdf \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts \
    ttf-font-awesome \
    ttf-jetbrains-mono \
    noto-fonts-emoji \
    python-pywal \
    python-pillow \
    zsh \
    tmux \
    ripgrep \
    fd \
    bat \
    exa \
    fzf \
    bluez \
    bluez-utils \
    blueman

echo -e "${GREEN}✓${NC} All packages installed!"

# Detect and configure VirtualBox
echo ""
echo -e "${YELLOW}→${NC} Checking for VirtualBox environment..."
if lspci | grep -i "virtualbox" &>/dev/null || systemd-detect-virt | grep -q "oracle"; then
    echo -e "${GREEN}✓${NC} VirtualBox detected - Installing guest utilities..."
    sudo pacman -S --needed --noconfirm virtualbox-guest-utils
    sudo systemctl enable vboxservice
    echo -e "${GREEN}✓${NC} VirtualBox guest utilities installed and enabled"
else
    echo -e "${BLUE}ℹ${NC} Not running in VirtualBox - skipping guest utilities"
fi

# Enable services
echo ""
echo -e "${YELLOW}→${NC} Enabling system services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
echo -e "${GREEN}✓${NC} Services enabled"

# Create config directories
echo ""
echo -e "${YELLOW}→${NC} Setting up configuration directories..."
mkdir -p ~/.config/{hypr,waybar,wofi,kitty,mako}
mkdir -p ~/Pictures/wallpapers

# Copy Hyprland configs
echo -e "${YELLOW}→${NC} Installing Hyprland configuration..."
if [ -d "$SCRIPT_DIR/dotfiles/hypr" ]; then
    cp -r "$SCRIPT_DIR/dotfiles/hypr"/* ~/.config/hypr/
    chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Hyprland config installed"
else
    echo -e "${RED}✗${NC} Hyprland config not found!"
fi

# Copy Waybar configs
echo -e "${YELLOW}→${NC} Installing Waybar configuration..."
if [ -d "$SCRIPT_DIR/dotfiles/waybar" ]; then
    cp -r "$SCRIPT_DIR/dotfiles/waybar"/* ~/.config/waybar/
    chmod +x ~/.config/waybar/scripts/*.sh 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Waybar config installed"
else
    echo -e "${RED}✗${NC} Waybar config not found!"
fi

# Copy Wofi config
echo -e "${YELLOW}→${NC} Installing Wofi configuration..."
if [ -f "$SCRIPT_DIR/dotfiles/wofi/style.css" ]; then
    cp "$SCRIPT_DIR/dotfiles/wofi/style.css" ~/.config/wofi/
    echo -e "${GREEN}✓${NC} Wofi config installed"
fi

# Copy Kitty config
echo -e "${YELLOW}→${NC} Installing Kitty configuration..."
if [ -f "$SCRIPT_DIR/dotfiles/kitty/kitty.conf" ]; then
    cp "$SCRIPT_DIR/dotfiles/kitty/kitty.conf" ~/.config/kitty/
    echo -e "${GREEN}✓${NC} Kitty config installed"
fi

# Copy Mako config
echo -e "${YELLOW}→${NC} Installing Mako configuration..."
if [ -f "$SCRIPT_DIR/dotfiles/mako/config" ]; then
    cp "$SCRIPT_DIR/dotfiles/mako/config" ~/.config/mako/
    echo -e "${GREEN}✓${NC} Mako config installed"
fi

# Copy wallpapers
echo -e "${YELLOW}→${NC} Installing wallpapers..."
if [ -d "$SCRIPT_DIR/wallpapers" ]; then
    cp -r "$SCRIPT_DIR/wallpapers"/* ~/Pictures/wallpapers/ 2>/dev/null || echo "  No wallpapers found"
fi

# Set default shell to zsh
echo ""
echo -e "${YELLOW}→${NC} Setting up Zsh..."
if ! command -v zsh &>/dev/null; then
    sudo pacman -S --needed --noconfirm zsh zsh-completions
fi
chsh -s $(which zsh)
echo -e "${GREEN}✓${NC} Zsh configured as default shell"

# Create .zprofile to auto-start Hyprland on login
echo ""
echo -e "${YELLOW}→${NC} Configuring auto-start for Hyprland..."
cat > ~/.zprofile << 'EOF'
# VirtualBox compatibility settings for Hyprland
# Only apply these if running in VirtualBox
if lspci | grep -i "virtualbox" &>/dev/null || systemd-detect-virt | grep -q "oracle"; then
    export WLR_NO_HARDWARE_CURSORS=1
    export WLR_RENDERER_ALLOW_SOFTWARE=1
    export WLR_RENDERER=pixman
fi

# Auto-start Hyprland on TTY1
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec Hyprland
fi
EOF
echo -e "${GREEN}✓${NC} Hyprland will auto-start on login"
echo -e "${GREEN}✓${NC} VirtualBox compatibility settings will auto-detect and apply if needed"

# Apply default theme (Catppuccin Mocha)
echo ""
echo -e "${YELLOW}→${NC} Applying default theme..."
if [ -f ~/.config/hypr/scripts/theme-apply.sh ]; then
    bash ~/.config/hypr/scripts/theme-apply.sh catppuccin-mocha &>/dev/null || true
    echo -e "${GREEN}✓${NC} Catppuccin Mocha theme applied"
fi

# Done!
clear
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ███████╗██╗   ██╗ ██████╗ ██████╗███████╗███████╗███████╗
║   ██╔════╝██║   ██║██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝
║   ███████╗██║   ██║██║     ██║     █████╗  ███████╗███████╗
║   ╚════██║██║   ██║██║     ██║     ██╔══╝  ╚════██║╚════██║
║   ███████║╚██████╔╝╚██████╗╚██████╗███████╗███████║███████║
║   ╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝╚══════╝╚══════╝╚══════╝
║                                                           ║
║           CustomOS Setup Complete! 🎉                     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}✓${NC} Hyprland and all customizations installed!"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}What's Installed:${NC}"
echo -e "${GREEN}  ✓${NC} Hyprland Wayland Compositor"
echo -e "${GREEN}  ✓${NC} 10 Pre-configured Themes (Catppuccin Mocha active)"
echo -e "${GREEN}  ✓${NC} Complete Waybar with 3 style variants"
echo -e "${GREEN}  ✓${NC} All utility scripts (theme switcher, wallpaper manager, etc.)"
echo -e "${GREEN}  ✓${NC} Firefox, Kitty terminal, file managers"
echo -e "${GREEN}  ✓${NC} Developer tools (Neovim, Git, etc.)"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Quick Start Guide:${NC}"
echo ""
echo -e "${BLUE}  Super + T${NC}           - Open terminal"
echo -e "${BLUE}  Super + A${NC}           - Application launcher"
echo -e "${BLUE}  Super + Shift + T${NC}   - Theme selector (try all 10 themes!)"
echo -e "${BLUE}  Super + Shift + W${NC}   - Wallpaper picker"
echo -e "${BLUE}  Super + /${NC}           - Show all keybindings"
echo -e "${BLUE}  Super + Q${NC}           - Close window"
echo -e "${BLUE}  Super + L${NC}           - Lock screen"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Ready to start Hyprland!${NC}"
echo ""
echo -e "${YELLOW}Options:${NC}"
echo -e "  1. Type ${WHITE}Hyprland${NC} to start now"
echo -e "  2. Type ${WHITE}reboot${NC} to restart (Hyprland will auto-start)"
echo ""
