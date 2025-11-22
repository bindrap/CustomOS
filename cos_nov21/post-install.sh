#!/bin/bash

# CustomOS Nov21 Post-Installation Script
# Simple, clean installation of Hyprland

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"

clear
echo -e "${CYAN}"
cat << 'EOF'
===================================================
   CustomOS Nov21 - Hyprland Setup
===================================================
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}Installing Hyprland desktop environment...${NC}"
echo -e "${YELLOW}This will take about 10-15 minutes.${NC}"
echo ""
read -p "Press ENTER to continue..."

# Check internet
echo ""
echo -e "${YELLOW}→${NC} Checking internet connectivity..."
if ping -c 2 archlinux.org &>/dev/null; then
    echo -e "${GREEN}✓${NC} Internet connection detected"
else
    echo -e "${RED}✗${NC} No internet connection!"
    echo -e "${YELLOW}Warning:${NC} Internet required for package installation."
    read -p "Continue anyway? (yes/no): " CONTINUE_OFFLINE
    if [ "$CONTINUE_OFFLINE" != "yes" ]; then
        exit 0
    fi
fi

# Update system
echo ""
echo -e "${YELLOW}→${NC} Updating system packages..."
sudo pacman -Syu --noconfirm

# Install all required packages
echo ""
echo -e "${YELLOW}→${NC} Installing Hyprland and dependencies..."
echo -e "${BLUE}This may take 10-15 minutes...${NC}"

sudo pacman -S --needed --noconfirm \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    polkit \
    polkit-gnome \
    qt5-wayland \
    qt6-wayland \
    waybar \
    mako \
    wofi \
    rofi-wayland \
    kitty \
    swaybg \
    swayidle \
    swaylock \
    sway \
    greetd \
    greetd-tuigreet \
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
    wl-clipboard \
    cliphist \
    imagemagick \
    imv \
    zathura \
    zathura-pdf-mupdf \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    noto-fonts-extra \
    ttf-font-awesome \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    ttf-nerd-fonts-symbols \
    ttf-nerd-fonts-symbols-mono \
    ttf-ubuntu-font-family \
    ttf-roboto \
    ttf-roboto-mono \
    gnu-free-fonts \
    cantarell-fonts \
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

# Rebuild font cache
echo ""
echo -e "${YELLOW}→${NC} Building font cache..."
fc-cache -fv > /dev/null 2>&1
echo -e "${GREEN}✓${NC} Font cache rebuilt"

# Enable services
echo ""
echo -e "${YELLOW}→${NC} Enabling system services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable greetd
echo -e "${GREEN}✓${NC} Services enabled"

# Create config directories
echo ""
echo -e "${YELLOW}→${NC} Setting up configuration directories..."
mkdir -p ~/.config/{hypr,waybar,wofi,kitty,mako,fontconfig}
mkdir -p ~/Pictures/wallpapers

# Copy all configs from dotfiles
echo -e "${YELLOW}→${NC} Installing configurations..."
if [ -d "$SCRIPT_DIR/dotfiles" ]; then
    cp -r "$SCRIPT_DIR/dotfiles/hypr"/* ~/.config/hypr/
    cp -r "$SCRIPT_DIR/dotfiles/waybar"/* ~/.config/waybar/
    cp -r "$SCRIPT_DIR/dotfiles/kitty"/* ~/.config/kitty/
    cp -r "$SCRIPT_DIR/dotfiles/mako"/* ~/.config/mako/
    cp -r "$SCRIPT_DIR/dotfiles/wofi"/* ~/.config/wofi/
    cp -r "$SCRIPT_DIR/dotfiles/fontconfig"/* ~/.config/fontconfig/

    # Make scripts executable
    chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null || true
    chmod +x ~/.config/waybar/scripts/*.sh 2>/dev/null || true

    echo -e "${GREEN}✓${NC} All configurations installed"
else
    echo -e "${RED}✗${NC} Dotfiles not found!"
fi

# Copy wallpapers
if [ -d "$SCRIPT_DIR/wallpapers" ]; then
    cp -r "$SCRIPT_DIR/wallpapers"/* ~/Pictures/wallpapers/ 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Wallpapers copied"
fi

# Configure greetd
echo ""
echo -e "${YELLOW}→${NC} Setting up login screen..."
if [ -d "$SCRIPT_DIR/dotfiles/greetd" ]; then
    sudo mkdir -p /etc/greetd
    sudo cp "$SCRIPT_DIR/dotfiles/greetd/config.toml" /etc/greetd/config.toml
    echo -e "${GREEN}✓${NC} Login screen configured (tuigreet)"
else
    echo -e "${YELLOW}⚠${NC} Greetd config not found, skipping"
fi

# Set default shell to zsh
echo ""
echo -e "${YELLOW}→${NC} Setting up Zsh..."
chsh -s $(which zsh)
echo -e "${GREEN}✓${NC} Zsh configured as default shell"

# Note: With greetd enabled, Hyprland will start from the login screen
# No need for .zprofile auto-start
echo ""
echo -e "${GREEN}✓${NC} Hyprland will start from login screen (greetd)"

# Done!
clear
echo -e "${GREEN}"
cat << 'EOF'
===================================================
          Setup Complete!
===================================================
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}✓${NC} Hyprland installation complete!"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Type ${GREEN}reboot${NC} to restart"
echo -e "  2. Hyprland will auto-start on login"
echo ""
echo -e "${YELLOW}Keybindings - Mod = SUPER (Windows key):${NC}"
echo -e "  ${BLUE}SUPER + T${NC}       - Terminal (kitty)"
echo -e "  ${BLUE}SUPER + A${NC}       - App launcher (wofi)"
echo -e "  ${BLUE}SUPER + Q${NC}       - Close window"
echo -e "  ${BLUE}SUPER + E${NC}       - File manager"
echo -e "  ${BLUE}SUPER + M${NC}       - Exit Hyprland"
echo ""
echo -e "${YELLOW}Troubleshooting:${NC}"
echo -e "  • Check logs: ${GREEN}cat /tmp/hyprland.log${NC}"
echo -e "  • Check config: ${GREEN}cat ~/.config/hypr/hyprland.conf${NC}"
echo -e "  • Reload Waybar: ${GREEN}SUPER + Shift + R${NC}"
echo ""
