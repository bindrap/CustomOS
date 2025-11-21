#!/bin/bash

# CustomOS v2 ISO Builder - Optimized for Real Hardware/QEMU
# Clean version without VirtualBox-specific workarounds

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
║  CustomOS v2 ISO Builder (Clean)               ║
║  Optimized for Real Hardware & QEMU            ║
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
echo -e "${YELLOW}CustomOS v2 - Complete Hyprland Environment (Hardware Optimized)${NC}"
echo "Output: $OUTPUT_DIR/${ISO_NAME}-${ISO_VERSION}.iso"
echo ""
echo "Includes:"
echo "  ✓ Enhanced Hyprland configuration"
echo "  ✓ Complete font stack (JetBrains Mono, Nerd Fonts, Noto)"
echo "  ✓ Custom wallpapers for desktop"
echo "  ✓ Polished Waybar with icon support"
echo "  ✓ Hardware acceleration enabled"
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

# Create post-install script for Hyprland
echo "→ Creating post-install script..."
cat > airootfs/root/custom-setup/post-install.sh << '\''EOFPOSTINSTALL'\''
#!/bin/bash

# Post-Installation Script for Hyprland
# Optimized for real hardware and QEMU

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
cat << '\''EOF'\''
╔═══════════════════════════════════════════════════╗
║   Hyprland Setup - Custom Arch Linux             ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}Installing Hyprland and desktop environment...${NC}"
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
    echo "  cd ~/custom-setup && ./post-install.sh"
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

# Install Hyprland and all required packages
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
    echo -e "${YELLOW}!${NC} Hyprland config not found, creating basic config..."
    mkdir -p ~/.config/hypr
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
chsh -s $(which zsh)
echo -e "${GREEN}✓${NC} Zsh configured as default shell"

# Create auto-start
echo ""
echo -e "${YELLOW}→${NC} Configuring auto-start for Hyprland..."
cat > ~/.zprofile << '\''EOFZPROFILE'\''
# Auto-start Hyprland on TTY1
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec Hyprland 2>/tmp/hyprland.log
fi
EOFZPROFILE
echo -e "${GREEN}✓${NC} Hyprland will auto-start on login"

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
cat << '\''EOF'\''
╔═══════════════════════════════════════════════════╗
║          Setup Complete!                          ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}✓${NC} Hyprland installation complete!"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Type ${GREEN}reboot${NC} to restart"
echo -e "  2. Hyprland will auto-start on login"
echo ""
echo -e "${YELLOW}Keybindings (Mod = ALT):${NC}"
echo -e "  ${BLUE}ALT + T${NC}         - Terminal (kitty)"
echo -e "  ${BLUE}SUPER + Enter${NC}   - Terminal (alternative)"
echo -e "  ${BLUE}ALT + A${NC}         - App launcher (wofi)"
echo -e "  ${BLUE}ALT + Q${NC}         - Close window"
echo -e "  ${BLUE}ALT + E${NC}         - File manager"
echo -e "  ${BLUE}ALT + M${NC}         - Exit Hyprland"
echo ""
echo -e "${YELLOW}Troubleshooting:${NC}"
echo -e "  • If ALT keybindings don't work, try ${BLUE}SUPER + Enter${NC} for terminal"
echo -e "  • Or manually run: ${GREEN}kitty${NC}"
echo -e "  • Check config: ${GREEN}cat ~/.config/hypr/hyprland.conf${NC}"
echo -e "  • View Hyprland logs: ${GREEN}cat /tmp/hyprland.log${NC}"
echo -e "  • No wallpaper? Add images to ~/Pictures/wallpapers/"
echo ""

EOFPOSTINSTALL

chmod +x airootfs/root/custom-setup/post-install.sh

# Ensure all scripts are executable
echo "→ Making scripts executable..."
find airootfs/root/custom-setup -type f -name "*.sh" -exec chmod +x {} \;
chmod +x airootfs/root/custom-setup/dotfiles/hypr/scripts/* 2>/dev/null || true
chmod +x airootfs/root/custom-setup/dotfiles/waybar/scripts/* 2>/dev/null || true

# Create welcome message
cat > airootfs/root/.zshrc << '\''EOFZSH'\''
cat << "WELCOME"

╔════════════════════════════════════════════════════════════╗
║                  Hyprland Custom Arch ISO                  ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  INSTALLATION:                                             ║
║                                                            ║
║    Run: install-arch                                       ║
║                                                            ║
║  This will:                                                ║
║    • Install base Arch Linux                              ║
║    • Copy Hyprland setup                                  ║
║    • On first login: Run post-install                     ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

WELCOME
echo ""
echo "Available disks:"
lsblk -d -o NAME,SIZE,TYPE | grep disk || true
echo ""
EOFZSH

# Create install-arch command
echo "→ Creating install-arch command..."
mkdir -p airootfs/usr/local/bin
cat > airootfs/usr/local/bin/install-arch << '\''EOFCMD'\''
#!/bin/bash
cd /root/custom-setup || exit 1
chmod +x install-auto.sh
exec bash ./install-auto.sh
EOFCMD
chmod +x airootfs/usr/local/bin/install-arch

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
  ["/root/custom-setup/post-install.sh"]="0:0:755"
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
    echo -e "${GREEN}║  Hyprland ISO Build Complete!                              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} ISO created successfully!"
    echo ""
    echo "Details:"
    echo "  File: $ISO_FILE"
    echo "  Size: $ISO_SIZE"
    echo ""
    echo "What's Included:"
    echo "  ✓ Hyprland with full desktop environment"
    echo "  ✓ All themes and configurations"
    echo "  ✓ Waybar, Wofi, Kitty, Mako"
    echo "  ✓ Network Manager, Bluetooth"
    echo "  ✓ Development tools"
    echo ""
    echo "Usage:"
    echo "  1. Boot ISO (works in QEMU, VirtualBox, or real hardware)"
    echo "  2. Run: install-arch"
    echo "  3. Reboot and login"
    echo "  4. Hyprland starts automatically"
    echo ""
else
    echo ""
    echo -e "${RED}✗ ISO build failed!${NC}"
    exit 1
fi
