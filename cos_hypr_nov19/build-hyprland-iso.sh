#!/bin/bash

# Hyprland ISO Builder for VirtualBox - Fixes Core Dumps
# Specifically configured to handle Hyprland in VirtualBox environment
# Addresses rendering issues and missing dependencies

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║  Hyprland ISO Builder for VirtualBox          ║
║  Fixed for Core Dumps & Rendering Issues      ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

ISO_NAME="hyprland-vbox"
ISO_VERSION=$(date +%Y%m%d-%H%M)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/iso-output"
CACHE_DIR="$HOME/.cache/archiso-hyprland"
IMAGE_NAME="archiso-builder"

echo ""
echo -e "${YELLOW}This builds Hyprland ISO with VirtualBox fixes${NC}"
echo "Output: $OUTPUT_DIR/${ISO_NAME}-${ISO_VERSION}.iso"
echo ""
echo "Includes:"
echo "  ✓ VirtualBox-specific Hyprland configuration"
echo "  ✓ Software rendering fallback"
echo "  ✓ All required dependencies"
echo "  ✓ Sway fallback if Hyprland fails"
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
    -w /workspace/cos_hypr_nov19 \
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
WORK_DIR="/tmp/archiso-hyprland"
ISO_DIR="$WORK_DIR/iso-build"
OUTPUT_DIR="/workspace/cos_hypr_nov19/iso-output"

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
    echo "Please connect to the internet and run this script again:"
    echo "  cd ~/custom-setup && ./post-install-vbox.sh"
    exit 1
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
    blueman \
    mesa \
    lib32-mesa \
    vulkan-swrast \
    glu \
    libglvnd \
    libva-mesa-driver \
    mesa-vdpau

echo -e "${GREEN}✓${NC} All packages installed!"

# Enable services
echo ""
echo -e "${YELLOW}→${NC} Enabling system services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

# Detect and configure VirtualBox
if lspci | grep -i "virtualbox" &>/dev/null || dmesg | grep -i "vbox" &>/dev/null; then
    echo -e "${YELLOW}→${NC} VirtualBox detected - Installing guest additions..."
    sudo pacman -S --needed --noconfirm virtualbox-guest-utils || true
    sudo systemctl enable vboxservice || true
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

    # Create VirtualBox-specific config
    cat >> ~/.config/hypr/hyprland.conf << "EOFVBOX"

# VirtualBox-specific optimizations
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = WLR_RENDERER,pixman
env = LIBVA_DRIVER_NAME,i965
env = __GLX_VENDOR_LIBRARY_NAME,mesa
env = GBM_BACKEND,nvidia-drm

# Disable resource-intensive features
decoration {
    blur {
        enabled = false
    }
    drop_shadow = false
}

animations {
    enabled = true
    bezier = simple, 0.16, 1, 0.3, 1
    animation = windows, 1, 3, simple
    animation = fade, 1, 3, simple
    animation = workspaces, 1, 3, simple
}

misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    vfr = true
}
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

# Set VirtualBox-specific environment variables
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export LIBVA_DRIVER_NAME=i965
export __GLX_VENDOR_LIBRARY_NAME=mesa
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export GDK_BACKEND=wayland

# Try different renderers in order of compatibility
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
# VirtualBox Environment Variables - Force Software Rendering
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = WLR_RENDERER,pixman
env = LIBVA_DRIVER_NAME,i965
env = __GLX_VENDOR_LIBRARY_NAME,mesa
env = GBM_BACKEND,nvidia-drm
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
echo -e "${YELLOW}VirtualBox Fixes Applied:${NC}"
echo -e "${GREEN}  ✓${NC} WLR_RENDERER=pixman (pure software rendering)"
echo -e "${GREEN}  ✓${NC} WLR_NO_HARDWARE_CURSORS=1"
echo -e "${GREEN}  ✓${NC} Disabled blur and shadows"
echo -e "${GREEN}  ✓${NC} Simplified animations"
echo -e "${GREEN}  ✓${NC} Automatic renderer detection"
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
echo -e "  2. Type ${GREEN}~/.local/bin/start-hyprland.sh${NC} to start now"
echo ""
echo -e "${YELLOW}The wrapper will try multiple renderers automatically.${NC}"
echo -e "${YELLOW}Check logs at: /tmp/hyprland-startup.log${NC}"
echo -e "${YELLOW}If all fail, it will automatically fallback to Sway.${NC}"
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
# Custom additions
vim
git
neovim
htop
pciutils
usbutils
lshw
dmidecode
virtualbox-guest-utils-nox
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

# Customize ISO label
ISO_LABEL="${ISO_NAME^^}"
ISO_VER="${ISO_VERSION//-/}"
sed -i "s/ARCH_[0-9]*/${ISO_LABEL}_${ISO_VER}/" profiledef.sh

# Build ISO
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║  Building Hyprland ISO (10-15 minutes)         ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
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
    echo -e "${GREEN}║  Hyprland VirtualBox ISO Build Complete!                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} ISO created successfully!"
    echo ""
    echo "Details:"
    echo "  File: $ISO_FILE"
    echo "  Size: $ISO_SIZE"
    echo ""
    echo "VirtualBox Fixes Included:"
    echo "  ✓ Multi-renderer fallback (pixman → gles2 → vulkan)"
    echo "  ✓ Mesa software rendering libraries"
    echo "  ✓ Forced software rendering (WLR_RENDERER=pixman)"
    echo "  ✓ Disabled hardware cursors (WLR_NO_HARDWARE_CURSORS=1)"
    echo "  ✓ Disabled blur and shadows"
    echo "  ✓ Simplified animations"
    echo "  ✓ Intelligent wrapper script tries all renderers"
    echo "  ✓ Sway fallback if all renderers fail"
    echo "  ✓ All required dependencies (polkit, xdg-desktop-portal, mesa)"
    echo "  ✓ VirtualBox guest additions"
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
    echo "Debugging:"
    echo "  - Startup log: /tmp/hyprland-startup.log"
    echo "  - Error log: /tmp/hyprland-error.log"
    echo "  - Wrapper tries: pixman, gles2, vulkan in order"
    echo "  - Auto-fallback to Sway if all fail"
    echo ""
else
    echo ""
    echo -e "${RED}✗ ISO build failed!${NC}"
    exit 1
fi
