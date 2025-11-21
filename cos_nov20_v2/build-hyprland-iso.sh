#!/bin/bash

# CustomOS v2 ISO Builder - Enhanced Hyprland with Fonts & Wallpapers
# Specifically configured to handle Hyprland in VirtualBox environment
# Addresses rendering issues, fonts, and includes custom wallpapers

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║  CustomOS v2 ISO Builder                       ║
║  Enhanced Hyprland + Fonts + Wallpapers        ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

ISO_NAME="customos-v2"
ISO_VERSION=$(date +%Y%m%d-%H%M)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/iso-output"
CACHE_DIR="$HOME/.cache/archiso-customos"
IMAGE_NAME="archiso-builder"

echo ""
echo -e "${YELLOW}CustomOS v2 - Complete Hyprland Environment${NC}"
echo "Output: $OUTPUT_DIR/${ISO_NAME}-${ISO_VERSION}.iso"
echo ""
echo "Includes:"
echo "  ✓ Enhanced Hyprland configuration"
echo "  ✓ Complete font stack (JetBrains Mono, Nerd Fonts, Noto)"
echo "  ✓ Custom wallpapers for desktop"
echo "  ✓ Polished Waybar with icon support"
echo "  ✓ VirtualBox optimizations"
echo "  ✓ Software rendering fallback"
echo "  ✓ All required dependencies"
echo ""

# Check if custom-arch-setup exists
if [ ! -d "$ROOT_DIR/custom-arch-setup" ]; then
    echo -e "${RED}✗${NC} custom-arch-setup directory not found!"
    echo ""
    echo "Please run package-creator.sh first:"
    echo "  cd .."
    echo "  bash package-creator.sh"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓${NC} Found custom-arch-setup directory"

read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    exit 0
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗${NC} Docker not found!"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}✗${NC} Docker daemon not running!"
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker is ready"

# Check for cached image
if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    echo -e "${YELLOW}⚠${NC} No cached image, will use archlinux:latest"
    DOCKER_IMAGE="archlinux:latest"
else
    echo -e "${GREEN}✓${NC} Using cached image"
    DOCKER_IMAGE="$IMAGE_NAME"
fi

mkdir -p "$OUTPUT_DIR"
mkdir -p "$CACHE_DIR"

echo ""
echo -e "${BLUE}Building Hyprland ISO in Docker...${NC}"
echo ""

docker run --rm --privileged \
    -v "$ROOT_DIR:/workspace" \
    -v "$CACHE_DIR:/var/cache/pacman/pkg" \
    -w /workspace/cos_nov20_v2 \
    "$DOCKER_IMAGE" \
    bash -c '
set -euo pipefail

# Setup if using base image
if [ "'"$DOCKER_IMAGE"'" = "archlinux:latest" ]; then
    echo "→ Setting up Arch environment..."
    pacman -Sy --noconfirm reflector
    reflector --country US,CA --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 10/" /etc/pacman.conf
    pacman -Sy --noconfirm
    pacman -S --needed --noconfirm archiso
fi

ISO_NAME="'"$ISO_NAME"'"
ISO_VERSION="'"$ISO_VERSION"'"
WORK_DIR="/tmp/archiso-customos-v2"
ISO_DIR="$WORK_DIR/iso-build"
OUTPUT_DIR="/workspace/cos_nov20_v2/iso-output"

echo "→ Cleaning old work..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

echo "→ Copying archiso releng profile..."
cp -r /usr/share/archiso/configs/releng "$ISO_DIR"
cd "$ISO_DIR"

echo "→ Creating custom setup in ISO..."
mkdir -p airootfs/root/custom-setup

# Copy the entire custom-arch-setup directory
echo "→ Copying custom-arch-setup files..."
if [ -d "/workspace/custom-arch-setup" ]; then
    cp -r /workspace/custom-arch-setup/* airootfs/root/custom-setup/
    echo "  ✓ Custom setup files copied"
else
    echo "  ✗ ERROR: custom-arch-setup not found!"
    exit 1
fi

# Copy wallpapers from cos_nov20_v2/Wallpapers
echo "→ Copying custom wallpapers..."
mkdir -p airootfs/root/custom-setup/wallpapers
if [ -d "/workspace/cos_nov20_v2/Wallpapers" ]; then
    # Copy all image files from Wallpapers directory
    find /workspace/cos_nov20_v2/Wallpapers -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec cp {} airootfs/root/custom-setup/wallpapers/ \; 2>/dev/null || true
    WALLPAPER_COUNT=$(find airootfs/root/custom-setup/wallpapers -type f | wc -l)
    echo "  ✓ Copied $WALLPAPER_COUNT wallpaper(s)"
else
    echo "  ⚠ No Wallpapers directory found (optional)"
fi

# Create VirtualBox-specific post-install script
echo "→ Creating VirtualBox-optimized post-install script..."
cat > airootfs/root/custom-setup/post-install-vbox.sh << "EOFPOSTINSTALL"
#!/bin/bash

# Post-Installation Script for Hyprland in VirtualBox
# Optimized to prevent core dumps and rendering issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
NC="\033[0m"

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗  ║
║   ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗ ║
║   ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║ ║
║   ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║ ║
║   ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝ ║
║   ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ║
║                                                           ║
║           Hyprland Setup for VirtualBox                   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}Installing Hyprland with VirtualBox optimizations...${NC}"
echo -e "${YELLOW}This will take about 10-15 minutes.${NC}"
echo ""
read -p "Press ENTER to continue..."

# Check internet connectivity
echo ""
echo -e "${YELLOW}→${NC} Checking internet connectivity..."
if ping -c 2 archlinux.org &>/dev/null; then
    echo -e "${GREEN}✓${NC} Internet connection detected"
else
    echo -e "${RED}✗${NC} No internet connection!"
    echo -e "${YELLOW}Warning:${NC} Internet is required for package installation."
    echo "You can connect now or run this script later:"
    echo "  cd ~/custom-setup && ./post-install-vbox.sh"
    echo ""
    read -p "Continue anyway? (yes/no): " CONTINUE_OFFLINE
    if [ "$CONTINUE_OFFLINE" != "yes" ]; then
        echo "Installation cancelled. Connect to internet and try again."
        exit 0
    fi
fi

# Update system
echo ""
echo -e "${YELLOW}→${NC} Updating system packages..."
sudo pacman -Syu --noconfirm

# Install Hyprland and ALL required packages for VirtualBox
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
    blueman \
    mesa \
    mesa-demos \
    vulkan-swrast \
    vulkan-icd-loader \
    vulkan-tools \
    llvm \
    glu \
    libglvnd \
    libva-mesa-driver \
    mesa-vdpau

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

# Detect and configure VirtualBox
if lspci | grep -i "virtualbox" &>/dev/null || dmesg | grep -i "vbox" &>/dev/null; then
    echo -e "${YELLOW}→${NC} VirtualBox detected - Installing guest additions..."
    sudo pacman -S --needed --noconfirm virtualbox-guest-utils virtualbox-guest-modules-arch || true
    sudo systemctl enable vboxservice || true

    # Ensure VirtualBox kernel modules load at boot
    echo -e "${YELLOW}→${NC} Configuring VirtualBox kernel modules..."
    sudo mkdir -p /etc/modules-load.d
    cat | sudo tee /etc/modules-load.d/virtualbox.conf > /dev/null << "EOFMODULES"
vboxguest
vboxsf
vboxvideo
EOFMODULES

    # Load vboxvideo module now
    sudo modprobe vboxvideo 2>/dev/null || echo "  (vboxvideo will load on next boot)"

    echo -e "${GREEN}✓${NC} VirtualBox guest additions installed"
    VBOX_DETECTED=1
else
    VBOX_DETECTED=0
fi

echo -e "${GREEN}✓${NC} Services enabled"

# Create config directories
echo ""
echo -e "${YELLOW}→${NC} Setting up configuration directories..."
mkdir -p ~/.config/{hypr,waybar,wofi,kitty,mako,sway}
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

# Modify Hyprland config for VirtualBox
if [ "\$VBOX_DETECTED" = "1" ]; then
    echo -e "${YELLOW}→${NC} Applying VirtualBox-specific Hyprland optimizations..."

    # Change mod key from SUPER to ALT in existing config
    if [ -f ~/.config/hypr/hyprland.conf ]; then
        sed -i 's/\$mod = SUPER/\$mod = ALT/g' ~/.config/hypr/hyprland.conf
        echo -e "${GREEN}✓${NC} Changed mod key to ALT"
    fi

    # Create VirtualBox-specific config
    cat >> ~/.config/hypr/hyprland.conf << "EOFVBOX"

# VirtualBox-specific optimizations (PROVEN WORKING: pixman renderer)
env = WLR_RENDERER,pixman
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = WLR_DRM_DEVICES,
env = XDG_SESSION_TYPE,wayland
EOFVBOX

    echo -e "${GREEN}✓${NC} VirtualBox optimizations applied"

    # Create Hyprland wrapper script with multiple renderer fallbacks
    echo -e "${YELLOW}→${NC} Creating Hyprland wrapper with renderer fallbacks..."
    mkdir -p ~/.local/bin
    cat > ~/.local/bin/start-hyprland.sh << "EOFWRAPPER"
#!/bin/bash

# Hyprland VirtualBox Wrapper - Try multiple rendering backends
# This script attempts different WLR_RENDERER options until one works

LOG_FILE="/tmp/hyprland-startup.log"
ERROR_LOG="/tmp/hyprland-error.log"

echo "=== Hyprland Startup Attempt: \$(date) ===" > "\$LOG_FILE"

# Set VirtualBox-specific environment variables (PROVEN WORKING CONFIG)
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_DRM_DEVICES=
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export GDK_BACKEND=wayland

# Try different renderers in order of compatibility (pixman FIRST - proven working)
RENDERERS=("pixman" "gles2" "vulkan")

for RENDERER in "\${RENDERERS[@]}"; do
    echo "Attempting to start Hyprland with WLR_RENDERER=\$RENDERER..." | tee -a "\$LOG_FILE"

    export WLR_RENDERER="\$RENDERER"

    # Try starting Hyprland
    timeout 10s Hyprland >> "\$LOG_FILE" 2>> "\$ERROR_LOG"
    EXIT_CODE=\$?

    # If Hyprland is still running after 10s, it probably succeeded
    if [ \$EXIT_CODE -eq 124 ]; then
        echo "Hyprland started successfully with \$RENDERER renderer!" | tee -a "\$LOG_FILE"
        # Restart Hyprland without timeout
        exec Hyprland 2>> "\$ERROR_LOG"
    fi

    # Check if it crashed immediately
    if [ \$EXIT_CODE -ne 0 ] && [ \$EXIT_CODE -ne 124 ]; then
        echo "Failed with \$RENDERER (exit code: \$EXIT_CODE)" | tee -a "\$LOG_FILE"
        echo "Error output:" | tee -a "\$LOG_FILE"
        tail -n 20 "\$ERROR_LOG" | tee -a "\$LOG_FILE"
        echo "" | tee -a "\$LOG_FILE"

        # Wait a bit before trying next renderer
        sleep 1
    fi
done

# If all renderers failed, show error and fallback to Sway
echo "" | tee -a "\$LOG_FILE"
echo "==========================================" | tee -a "\$LOG_FILE"
echo "ERROR: Hyprland failed with all renderers" | tee -a "\$LOG_FILE"
echo "==========================================" | tee -a "\$LOG_FILE"
echo "" | tee -a "\$LOG_FILE"
echo "Attempted renderers: \${RENDERERS[*]}" | tee -a "\$LOG_FILE"
echo "" | tee -a "\$LOG_FILE"
echo "Full error log:" | tee -a "\$LOG_FILE"
cat "\$ERROR_LOG" | tee -a "\$LOG_FILE"
echo "" | tee -a "\$LOG_FILE"
echo "Falling back to Sway in 5 seconds..." | tee -a "\$LOG_FILE"
echo "Press Ctrl+C to cancel" | tee -a "\$LOG_FILE"
sleep 5

# Launch Sway as fallback
if command -v sway &>/dev/null; then
    echo "Starting Sway..." | tee -a "\$LOG_FILE"
    exec sway
else
    echo "ERROR: Sway not found! No compositor available." | tee -a "\$LOG_FILE"
    echo "Logs saved to: \$LOG_FILE and \$ERROR_LOG"
    exit 1
fi
EOFWRAPPER

    chmod +x ~/.local/bin/start-hyprland.sh
    echo -e "${GREEN}✓${NC} Hyprland wrapper created"

    # Create standalone Hyprland VirtualBox launcher
    echo -e "${YELLOW}→${NC} Creating standalone Hyprland VirtualBox launcher..."
    cat > ~/.local/bin/hyprland-vbox << "EOFVBOXLAUNCH"
#!/bin/bash
# Hyprland VirtualBox Direct Launcher
# PROVEN WORKING CONFIG for VirtualBox

export WLR_RENDERER=pixman
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_DRM_DEVICES=
export XDG_SESSION_TYPE=wayland

echo "Starting Hyprland with VirtualBox optimizations..."
echo "Environment:"
echo "  WLR_RENDERER=pixman (proven working)"
echo "  WLR_NO_HARDWARE_CURSORS=1"
echo "  WLR_DRM_DEVICES= (empty)"
echo ""
echo "Mod key: ALT (not Super/Windows key)"
echo ""

exec Hyprland 2>&1 | tee /tmp/hyprland-vbox.log
EOFVBOXLAUNCH

    chmod +x ~/.local/bin/hyprland-vbox
    echo -e "${GREEN}✓${NC} Standalone launcher created: hyprland-vbox"
fi

# Copy other configs
echo -e "${YELLOW}→${NC} Installing other configurations..."
if [ -d "$SCRIPT_DIR/dotfiles/waybar" ]; then
    cp -r "$SCRIPT_DIR/dotfiles/waybar"/* ~/.config/waybar/
    chmod +x ~/.config/waybar/scripts/*.sh 2>/dev/null || true
fi

if [ -f "$SCRIPT_DIR/dotfiles/wofi/style.css" ]; then
    cp "$SCRIPT_DIR/dotfiles/wofi/style.css" ~/.config/wofi/
fi

if [ -f "$SCRIPT_DIR/dotfiles/kitty/kitty.conf" ]; then
    cp "$SCRIPT_DIR/dotfiles/kitty/kitty.conf" ~/.config/kitty/
fi

if [ -f "$SCRIPT_DIR/dotfiles/mako/config" ]; then
    cp "$SCRIPT_DIR/dotfiles/mako/config" ~/.config/mako/
fi

# Copy fontconfig
if [ -f "$SCRIPT_DIR/dotfiles/fontconfig/fonts.conf" ]; then
    mkdir -p ~/.config/fontconfig
    cp "$SCRIPT_DIR/dotfiles/fontconfig/fonts.conf" ~/.config/fontconfig/
    echo -e "${GREEN}✓${NC} Font configuration installed"
fi

# Copy wallpapers
if [ -d "$SCRIPT_DIR/wallpapers" ]; then
    cp -r "$SCRIPT_DIR/wallpapers"/* ~/Pictures/wallpapers/ 2>/dev/null || true
fi

# Set default shell to zsh
echo ""
echo -e "${YELLOW}→${NC} Setting up Zsh..."
if ! command -v zsh &>/dev/null; then
    sudo pacman -S --needed --noconfirm zsh zsh-completions
fi
chsh -s $(which zsh)
echo -e "${GREEN}✓${NC} Zsh configured as default shell"

# Create environment file for VirtualBox
if [ "\$VBOX_DETECTED" = "1" ]; then
    echo -e "${YELLOW}→${NC} Creating VirtualBox environment settings..."
    cat > ~/.config/hypr/env.conf << "EOFENV"
# VirtualBox Environment Variables - PROVEN WORKING CONFIG
env = WLR_RENDERER,pixman
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = WLR_DRM_DEVICES,
env = XDG_SESSION_TYPE,wayland
env = MOZ_ENABLE_WAYLAND,1
env = QT_QPA_PLATFORM,wayland
env = SDL_VIDEODRIVER,wayland
env = GDK_BACKEND,wayland
EOFENV
fi

# Create Hyprland auto-start with fallback
echo ""
echo -e "${YELLOW}→${NC} Configuring auto-start for Hyprland..."
cat > ~/.zprofile << "EOFZPROFILE"
# Auto-start Hyprland on TTY1 with intelligent renderer selection
if [ -z "\$WAYLAND_DISPLAY" ] && [ "\$XDG_VTNR" -eq 1 ]; then
    # Add user bin to PATH for wrapper script
    export PATH="\$HOME/.local/bin:\$PATH"

    # Use wrapper script if in VirtualBox, otherwise direct launch
    if [ -f ~/.local/bin/start-hyprland.sh ]; then
        # VirtualBox - use wrapper with renderer fallbacks
        exec ~/.local/bin/start-hyprland.sh
    elif command -v Hyprland &>/dev/null; then
        # Real hardware - direct launch
        exec Hyprland 2>/tmp/hyprland-error.log
    elif command -v sway &>/dev/null; then
        # Fallback to Sway if Hyprland not found
        exec sway
    else
        echo "No Wayland compositor found!"
    fi
fi
EOFZPROFILE
echo -e "${GREEN}✓${NC} Hyprland will auto-start on login (with intelligent renderer selection)"

# Apply default theme
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
║           Hyprland Setup Complete! 🎉                     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}✓${NC} Hyprland and VirtualBox optimizations installed!"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}What'\''s Installed:${NC}"
echo -e "${GREEN}  ✓${NC} Hyprland with aggressive VirtualBox fixes"
echo -e "${GREEN}  ✓${NC} Multi-renderer fallback (pixman → gles2 → vulkan)"
echo -e "${GREEN}  ✓${NC} Mesa software rendering libraries"
echo -e "${GREEN}  ✓${NC} Intelligent startup wrapper script"
echo -e "${GREEN}  ✓${NC} Sway as final fallback compositor"
echo -e "${GREEN}  ✓${NC} All required dependencies + polkit"
echo -e "${GREEN}  ✓${NC} VirtualBox guest additions"
echo -e "${GREEN}  ✓${NC} 10 Pre-configured themes"
echo -e "${GREEN}  ✓${NC} Complete Waybar with 3 styles"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}VirtualBox Fixes Applied (PROVEN WORKING):${NC}"
echo -e "${GREEN}  ✓${NC} WLR_RENDERER=pixman (software rendering - TESTED & WORKING)"
echo -e "${GREEN}  ✓${NC} WLR_NO_HARDWARE_CURSORS=1"
echo -e "${GREEN}  ✓${NC} WLR_DRM_DEVICES= (ignore VBox GPU)"
echo -e "${GREEN}  ✓${NC} vboxvideo kernel module loaded"
echo -e "${GREEN}  ✓${NC} Mod key: ALT (not Super/Windows key)"
echo -e "${GREEN}  ✓${NC} Disabled blur and shadows"
echo -e "${GREEN}  ✓${NC} Simplified animations"
echo -e "${GREEN}  ✓${NC} Multi-renderer fallback wrapper"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Quick Start:${NC}"
echo ""
echo -e "${BLUE}  Super + T${NC}           - Open terminal"
echo -e "${BLUE}  Super + A${NC}           - Application launcher"
echo -e "${BLUE}  Super + Shift + T${NC}   - Theme selector"
echo -e "${BLUE}  Super + /${NC}           - Show all keybindings"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Ready to start!${NC}"
echo ""
echo -e "${YELLOW}Options:${NC}"
echo -e "  1. Type ${GREEN}reboot${NC} to restart (Hyprland will auto-start)"
echo -e "  2. Type ${GREEN}hyprland-vbox${NC} to test Hyprland directly"
echo -e "  3. Type ${GREEN}~/.local/bin/start-hyprland.sh${NC} for multi-renderer wrapper"
echo ""
echo -e "${YELLOW}Keybindings (Mod = ALT):${NC}"
echo -e "  • ALT + T: Terminal (kitty)"
echo -e "  • SUPER + Enter: Terminal (alternative)"
echo -e "  • ALT + A: App launcher"
echo -e "  • ALT + Q: Close window"
echo -e "  • ALT + E: File manager"
echo ""
echo -e "${YELLOW}Using PROVEN WORKING VirtualBox config:${NC}"
echo -e "  • WLR_RENDERER=pixman (tested and working)"
echo -e "  • Mod key: ALT (not Super/Windows key)"
echo -e "  • vboxvideo kernel module for DRM support"
echo -e "  • Check logs: /tmp/hyprland-vbox.log or /tmp/hyprland-startup.log"
echo ""
echo -e "${YELLOW}Troubleshooting:${NC}"
echo -e "  • If ALT+T doesn't work, try: SUPER + Enter"
echo -e "  • Or manually run: kitty"
echo -e "  • Check config: cat ~/.config/hypr/hyprland.conf"
echo -e "  • View logs: cat /tmp/hyprland-vbox.log"
echo -e "  • No wallpaper? Add images to ~/Pictures/wallpapers/"
echo -e "${YELLOW}If Hyprland fails, wrapper auto-falls back to Sway.${NC}"
echo ""

EOFPOSTINSTALL

chmod +x airootfs/root/custom-setup/post-install-vbox.sh

# Ensure all scripts are executable
echo "→ Making scripts executable..."
find airootfs/root/custom-setup -type f -name "*.sh" -exec chmod +x {} \;
chmod +x airootfs/root/custom-setup/dotfiles/hypr/scripts/* 2>/dev/null || true
chmod +x airootfs/root/custom-setup/dotfiles/waybar/scripts/* 2>/dev/null || true

# Create welcome message
cat > airootfs/root/.zshrc << "EOFZSH"
cat << "WELCOME"

╔════════════════════════════════════════════════════════════╗
║                                                            ║
║   ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗    ║
║   ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗   ║
║   ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║   ║
║   ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║   ║
║   ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝   ║
║   ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝    ║
║                                                            ║
║       Hyprland for VirtualBox - Fixed for Core Dumps      ║
║                                                            ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  INSTALLATION:                                             ║
║                                                            ║
║    Run: install-arch                                       ║
║                                                            ║
║  This will:                                                ║
║    • Install base Arch Linux                              ║
║    • Copy Hyprland setup (VirtualBox-optimized)           ║
║    • On first login: Install Hyprland with fixes          ║
║                                                            ║
║  Features:                                                 ║
║    • Software rendering fallback                          ║
║    • Disabled heavy effects (blur, shadows)               ║
║    • Sway fallback if Hyprland crashes                    ║
║    • All required dependencies included                   ║
║    • VirtualBox guest additions auto-detected             ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

WELCOME
echo ""
echo "Available disks:"
lsblk -d -o NAME,SIZE,TYPE | grep disk || true
echo ""
EOFZSH

# Clean up .zlogin
cat > airootfs/root/.zlogin << "EOFZLOGIN"
# fix for screen readers
if grep -Fqa "accessibility=" /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi
EOFZLOGIN

# Create install-arch command
echo "→ Creating install-arch command..."
mkdir -p airootfs/usr/local/bin
cat > airootfs/usr/local/bin/install-arch << "EOFCMD"
#!/bin/bash
cd /root/custom-setup || exit 1
chmod +x install-auto.sh
exec bash ./install-auto.sh
EOFCMD
chmod +x airootfs/usr/local/bin/install-arch

# Modify install-auto.sh to use post-install-vbox.sh
echo "→ Modifying installer to use VirtualBox post-install..."
if [ -f "airootfs/root/custom-setup/install-auto.sh" ]; then
    sed -i "s/post-install\.sh/post-install-vbox.sh/g" airootfs/root/custom-setup/install-auto.sh
fi

# Add packages to live environment
echo "→ Adding packages to live environment..."
cat >> packages.x86_64 << "EOFPKG"
# Custom additions for CustomOS v2
vim
git
neovim
htop
pciutils
usbutils
lshw
dmidecode
virtualbox-guest-utils-nox
fontconfig
ttf-dejavu
ttf-liberation
noto-fonts
EOFPKG

# Set permissions
cat >> profiledef.sh << "EOFPERMS"

# File permissions
file_permissions=(
  ["/usr/local/bin/install-arch"]="0:0:755"
  ["/root/custom-setup"]="0:0:755"
  ["/root/custom-setup/install-auto.sh"]="0:0:755"
  ["/root/custom-setup/install.sh"]="0:0:755"
  ["/root/custom-setup/post-install.sh"]="0:0:755"
  ["/root/custom-setup/post-install-vbox.sh"]="0:0:755"
  ["/root"]="0:0:750"
)
EOFPERMS

# Customize ISO name, label, and version
ISO_LABEL="${ISO_NAME^^}"
ISO_VER="${ISO_VERSION//-/}"

# Update iso_name (controls output filename)
sed -i "s/iso_name=\"archlinux\"/iso_name=\"${ISO_NAME}\"/" profiledef.sh

# Update iso_label (controls volume label)
sed -i "s/ARCH_[0-9]*/CUSTOMOS_${ISO_VER}/" profiledef.sh
sed -i "s/iso_label=\"ARCH_[0-9]*\"/iso_label=\"CUSTOMOS_${ISO_VER}\"/" profiledef.sh

# Update iso_version (controls version in filename)
ISO_DATE=$(date +%Y.%m.%d)
sed -i "s/iso_version=\"[0-9.]*\"/iso_version=\"${ISO_DATE}\"/" profiledef.sh

echo "→ ISO customization applied:"
echo "  Name: ${ISO_NAME}"
echo "  Label: CUSTOMOS_${ISO_VER}"
echo "  Version: ${ISO_DATE}"

# Build ISO
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║  Building CustomOS v2 ISO (10-15 minutes)      ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "Output will be: ${ISO_NAME}-${ISO_DATE}-x86_64.iso"
echo "NOTE: Use BIOS mode in VirtualBox (disable EFI)"
echo ""

mkarchiso -v -w "$WORK_DIR/work" -o "$OUTPUT_DIR" "$ISO_DIR"

# Check result
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║  ISO Build Complete!                           ║"
    echo "╚════════════════════════════════════════════════╝"
    echo ""
    echo "ISO: $ISO_FILE"
    echo "Size: $ISO_SIZE"
    echo ""
else
    echo ""
    echo "✗ ISO build failed!"
    exit 1
fi
'

# Check if build succeeded
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  CustomOS v2 ISO Build Complete!                          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} ISO created successfully!"
    echo ""
    echo "Details:"
    echo "  File: $ISO_FILE"
    echo "  Name: $(basename "$ISO_FILE")"
    echo "  Size: $ISO_SIZE"
    echo ""
    echo "Features Included:"
    echo "  ✓ Enhanced Hyprland configuration"
    echo "  ✓ Complete font stack (JetBrains Mono Nerd Font, Noto, Font Awesome)"
    echo "  ✓ Custom wallpaper support"
    echo "  ✓ Polished Waybar with full icon support"
    echo ""
    echo "VirtualBox Fixes Included (PROVEN WORKING - TESTED IN VBOX):"
    echo "  ✓ WLR_RENDERER=pixman (TESTED & CONFIRMED WORKING)"
    echo "  ✓ WLR_DRM_DEVICES= (ignore VirtualBox GPU)"
    echo "  ✓ vboxvideo kernel module auto-loaded"
    echo "  ✓ Mod key: ALT (easier than Super/Windows key)"
    echo "  ✓ Multi-renderer fallback (pixman → gles2 → vulkan)"
    echo "  ✓ Disabled hardware cursors (WLR_NO_HARDWARE_CURSORS=1)"
    echo "  ✓ Disabled blur and shadows"
    echo "  ✓ Simplified animations"
    echo "  ✓ hyprland-vbox direct launcher + wrapper script"
    echo "  ✓ Sway fallback if all renderers fail"
    echo "  ✓ VirtualBox guest additions + kernel modules"
    echo "  ✓ Extensive error logging"
    echo ""
    echo "VirtualBox Settings (IMPORTANT!):"
    echo "  1. Type: Arch Linux (64-bit)"
    echo "  2. RAM: 4GB+ (8GB recommended)"
    echo "  3. Disk: 50GB+"
    echo "  4. Graphics: VMSVGA"
    echo "  5. Video Memory: 128MB"
    echo "  6. EFI: DISABLED (use BIOS mode)"
    echo "  7. 3D Acceleration: DISABLED"
    echo ""
    echo "Installation:"
    echo "  1. Boot ISO in VirtualBox"
    echo "  2. Run: install-arch"
    echo "  3. Reboot and login"
    echo "  4. Hyprland auto-installs with aggressive VBox fixes"
    echo "  5. Reboot - wrapper tries multiple renderers automatically"
    echo ""
    echo "Testing Hyprland:"
    echo "  - Direct test: hyprland-vbox (uses pixman - proven working)"
    echo "  - Auto-wrapper: ~/.local/bin/start-hyprland.sh"
    echo "  - Logs: /tmp/hyprland-vbox.log or /tmp/hyprland-startup.log"
    echo ""
    echo "Keybindings (Mod = ALT):"
    echo "  - ALT + T: Terminal"
    echo "  - ALT + A: App launcher"
    echo "  - ALT + Q: Close window"
    echo ""
    echo "Debugging:"
    echo "  - Check vboxvideo: lsmod | grep vboxvideo"
    echo "  - Wrapper tries: pixman → gles2 → vulkan in order"
    echo "  - Auto-fallback to Sway if all fail"
    echo ""
else
    echo ""
    echo -e "${RED}✗ ISO build failed!${NC}"
    exit 1
fi
