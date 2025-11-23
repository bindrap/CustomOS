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

# Network Connection Helper Function
connect_to_network() {
    echo ""
    echo -e "${CYAN}───────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}Network Connection Helper${NC}"
    echo -e "${CYAN}───────────────────────────────────────────────${NC}"
    echo ""
    echo -e "Choose a connection method:"
    echo -e "  ${GREEN}1${NC} - nmtui (Text-based UI - Recommended for WiFi)"
    echo -e "  ${GREEN}2${NC} - nmcli (Command line - For Ethernet)"
    echo -e "  ${GREEN}3${NC} - Manual commands guide"
    echo -e "  ${GREEN}4${NC} - Skip (already connected)"
    echo ""
    read -p "Enter choice (1-4): " NET_CHOICE

    case $NET_CHOICE in
        1)
            echo ""
            echo -e "${YELLOW}→${NC} Launching NetworkManager TUI..."
            echo -e "${BLUE}Use arrow keys to navigate, Enter to select${NC}"
            echo -e "${BLUE}Select 'Activate a connection' to connect to WiFi${NC}"
            echo ""
            read -p "Press ENTER to open nmtui..."
            sudo nmtui
            echo ""
            echo -e "${GREEN}✓${NC} Returned from nmtui"
            ;;
        2)
            echo ""
            echo -e "${YELLOW}→${NC} Starting NetworkManager service..."
            sudo systemctl start NetworkManager
            echo -e "${GREEN}✓${NC} NetworkManager started"
            echo ""
            echo -e "${YELLOW}→${NC} Checking for Ethernet connection..."
            sleep 3
            if ip link show | grep -q "state UP"; then
                echo -e "${GREEN}✓${NC} Network interface is up"
            else
                echo -e "${YELLOW}⚠${NC} No active connection detected"
                echo -e "Try option 1 (nmtui) for WiFi"
            fi
            ;;
        3)
            echo ""
            echo -e "${YELLOW}Manual Connection Commands:${NC}"
            echo ""
            echo -e "${CYAN}For WiFi:${NC}"
            echo -e "  ${GREEN}sudo systemctl start NetworkManager${NC}"
            echo -e "  ${GREEN}nmcli device wifi list${NC}                    # List networks"
            echo -e "  ${GREEN}nmcli device wifi connect 'SSID' password 'PASSWORD'${NC}"
            echo ""
            echo -e "${CYAN}For Ethernet:${NC}"
            echo -e "  ${GREEN}sudo systemctl start NetworkManager${NC}"
            echo -e "  ${GREEN}sudo dhcpcd${NC}                              # Get IP automatically"
            echo ""
            echo -e "${CYAN}Check connection:${NC}"
            echo -e "  ${GREEN}ip addr${NC}                                   # Show IP addresses"
            echo -e "  ${GREEN}ping archlinux.org${NC}                        # Test connectivity"
            echo ""
            read -p "Press ENTER when you've connected..."
            ;;
        4)
            echo ""
            echo -e "${YELLOW}→${NC} Skipping network setup"
            ;;
        *)
            echo ""
            echo -e "${RED}✗${NC} Invalid choice, skipping..."
            ;;
    esac
}

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
    echo ""
    read -p "Would you like to connect to network now? (yes/no): " WANT_CONNECT
    if [ "$WANT_CONNECT" = "yes" ]; then
        connect_to_network
        echo ""
        echo -e "${YELLOW}→${NC} Rechecking internet connectivity..."
        if ping -c 2 archlinux.org &>/dev/null; then
            echo -e "${GREEN}✓${NC} Internet connection detected"
        else
            echo -e "${RED}✗${NC} Still no internet connection!"
            read -p "Continue anyway? (yes/no): " CONTINUE_OFFLINE
            if [ "$CONTINUE_OFFLINE" != "yes" ]; then
                exit 0
            fi
        fi
    else
        read -p "Continue without internet? (yes/no): " CONTINUE_OFFLINE
        if [ "$CONTINUE_OFFLINE" != "yes" ]; then
            exit 0
        fi
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

# Optional Hyde Installation
echo ""
echo -e "${CYAN}───────────────────────────────────────────────${NC}"
echo -e "${YELLOW}Hyde Installation Option${NC}"
echo -e "${CYAN}───────────────────────────────────────────────${NC}"
echo ""
echo -e "Hyde is a comprehensive Hyprland theme manager with:"
echo -e "  • Multiple pre-configured themes"
echo -e "  • Advanced customization tools"
echo -e "  • Wallpaper management"
echo -e "  • Theme switcher and more"
echo ""
echo -e "${YELLOW}Note:${NC} Hyde will replace existing Hyprland configs"
echo -e "${YELLOW}      The original configs will be backed up${NC}"
echo ""
read -p "Install Hyde? (yes/no): " INSTALL_HYDE

if [ "$INSTALL_HYDE" = "yes" ]; then
    # Verify internet connection for Hyde
    echo ""
    echo -e "${YELLOW}→${NC} Verifying internet for Hyde installation..."
    if ! ping -c 2 archlinux.org &>/dev/null; then
        echo -e "${RED}✗${NC} No internet connection!"
        echo -e "${YELLOW}Hyde requires internet to download from GitHub${NC}"
        echo ""
        read -p "Would you like to connect to network now? (yes/no): " WANT_CONNECT_HYDE
        if [ "$WANT_CONNECT_HYDE" = "yes" ]; then
            connect_to_network
            echo ""
            echo -e "${YELLOW}→${NC} Rechecking internet connectivity..."
            if ! ping -c 2 archlinux.org &>/dev/null; then
                echo -e "${RED}✗${NC} Still no internet connection!"
                echo -e "${YELLOW}Skipping Hyde installation${NC}"
                INSTALL_HYDE="no"
            else
                echo -e "${GREEN}✓${NC} Internet connection detected"
            fi
        else
            echo -e "${YELLOW}Skipping Hyde installation${NC}"
            INSTALL_HYDE="no"
        fi
    else
        echo -e "${GREEN}✓${NC} Internet connection confirmed"
    fi
fi

if [ "$INSTALL_HYDE" = "yes" ]; then
    echo ""
    echo -e "${YELLOW}→${NC} Installing Hyde dependencies..."

    # Install additional Hyde dependencies
    sudo pacman -S --needed --noconfirm \
        sddm \
        qt5-svg \
        qt5-quickcontrols2 \
        qt5-graphicaleffects \
        kvantum \
        gtk-engine-murrine \
        gnome-themes-extra \
        curl \
        wget \
        jq \
        gawk \
        sed \
        coreutils \
        findutils \
        python-requests \
        python-pyquery \
        python-click \
        xdg-user-dirs \
        parallel \
        rsync \
        wlogout

    echo -e "${GREEN}✓${NC} Hyde dependencies installed"

    echo ""
    echo -e "${YELLOW}→${NC} Cloning Hyde repository..."
    mkdir -p ~/Build
    cd ~/Build

    if [ -d "HyDE" ]; then
        rm -rf HyDE
    fi

    git clone --depth 1 https://github.com/prasanthrangan/hyprdots HyDE
    cd HyDE

    echo -e "${GREEN}✓${NC} Hyde repository cloned"

    echo ""
    echo -e "${YELLOW}→${NC} Backing up existing configs..."
    mkdir -p ~/.config-backup-$(date +%Y%m%d-%H%M%S)
    if [ -d ~/.config/hypr ]; then
        cp -r ~/.config/hypr ~/.config-backup-$(date +%Y%m%d-%H%M%S)/
    fi
    echo -e "${GREEN}✓${NC} Configs backed up"

    echo ""
    echo -e "${YELLOW}→${NC} Installing Hyde...${NC}"
    echo -e "${BLUE}This may take a few minutes...${NC}"

    # Run Hyde install script
    chmod +x Scripts/install.sh
    ./Scripts/install.sh

    echo -e "${GREEN}✓${NC} Hyde installed successfully!"
    echo ""
    echo -e "${CYAN}───────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}Hyde Update Instructions:${NC}"
    echo -e "${CYAN}───────────────────────────────────────────────${NC}"
    echo -e "To update Hyde in the future, run:"
    echo -e "  ${GREEN}cd ~/Build/HyDE/Scripts${NC}"
    echo -e "  ${GREEN}git pull origin master${NC}"
    echo -e "  ${GREEN}./install.sh -r${NC}         # -r flag for reinstall"
    echo -e "${CYAN}───────────────────────────────────────────────${NC}"

    # Return to home directory
    cd ~
else
    echo ""
    echo -e "${YELLOW}→${NC} Skipping Hyde installation"
    echo -e "${BLUE}Will use default CustomOS configurations${NC}"
fi

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
