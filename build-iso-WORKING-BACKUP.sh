#!/bin/bash

# Simplified ISO Builder - Skips mirror optimization for slow connections
# This version uses default mirrors and increased timeouts

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ISO_NAME="parteek-arch"
ISO_VERSION=$(date +%Y.%m.%d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/iso-output"

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ██╗███████╗ ██████╗     ██████╗ ██╗   ██╗██╗██╗     ██████╗ ║
║   ██║██╔════╝██╔═══██╗    ██╔══██╗██║   ██║██║██║     ██╔══██╗║
║   ██║███████╗██║   ██║    ██████╔╝██║   ██║██║██║     ██║  ██║║
║   ██║╚════██║██║   ██║    ██╔══██╗██║   ██║██║██║     ██║  ██║║
║   ██║███████║╚██████╔╝    ██████╔╝╚██████╔╝██║███████╗██████╔╝║
║   ╚═╝╚══════╝ ╚═════╝     ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ║
║                                                           ║
║    Custom Arch Linux ISO Builder (Simple/Slow Network)    ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${YELLOW}Simplified ISO Builder for Slow Connections${NC}"
echo "This version uses increased timeouts and skips mirror optimization"
echo "Output: $OUTPUT_DIR/${ISO_NAME}-${ISO_VERSION}.iso"
echo ""

# Check Docker
if ! docker info &> /dev/null; then
    echo -e "${RED}✗${NC} Docker daemon is not running!"
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker is ready"
echo ""

read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    exit 0
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo ""
echo -e "${BLUE}Building ISO in Docker container (this may take 20-30 minutes on slow connections)...${NC}"
echo ""

# Build with increased timeout and without mirror optimization
docker run --rm --privileged \
    --dns 8.8.8.8 \
    --dns 1.1.1.1 \
    -v "$SCRIPT_DIR:/workspace" \
    -w /workspace \
    archlinux:latest \
    bash -c '
set -e

echo "→ Fixing DNS configuration..."
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

echo "→ Configuring pacman for slow connections..."
# Increase pacman timeout
sed -i "s/#XferCommand/XferCommand/" /etc/pacman.conf
sed -i "s/^#\?\(XferCommand.*\)/XferCommand = \/usr\/bin\/curl -L -C - -f --retry 3 --retry-delay 3 -o %o %u/" /etc/pacman.conf

echo "→ Updating package database..."
pacman -Sy --noconfirm

echo "→ Installing archiso and dependencies..."
pacman -S --needed --noconfirm archiso git

# Set up variables
ISO_NAME="parteek-arch"
ISO_VERSION=$(date +%Y.%m.%d)
WORK_DIR="/tmp/archiso-work"
ISO_DIR="$WORK_DIR/iso-build"
OUTPUT_DIR="/workspace/iso-output"

# Clean up
echo "→ Cleaning old build..."
rm -rf "$WORK_DIR"

# Create directories
echo "→ Creating work directories..."
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

# Copy archiso profile
echo "→ Copying archiso profile..."
cp -r /usr/share/archiso/configs/releng "$ISO_DIR"
cd "$ISO_DIR"

# Create custom setup directory
echo "→ Creating custom setup directory..."
mkdir -p airootfs/root/custom-setup

# Copy custom setup files
echo "→ Copying custom setup files..."
if [ -d "/workspace/custom-arch-setup" ]; then
    cp -r /workspace/custom-arch-setup/* airootfs/root/custom-setup/
    echo "  ✓ Custom setup files copied"
else
    echo "  ! No custom-arch-setup directory found"
fi

# Make all scripts executable
echo "→ Making scripts executable..."
find airootfs/root/custom-setup -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

# Verify files
echo "→ Verifying setup files..."
if [ -f "airootfs/root/custom-setup/install-auto.sh" ]; then
    echo "  ✓ install-auto.sh found"
else
    echo "  ! WARNING: install-auto.sh missing!"
fi

# Create install-arch command
echo "→ Creating install-arch command..."
mkdir -p airootfs/usr/local/bin
cat > airootfs/usr/local/bin/install-arch << "EOFINSTALL"
#!/bin/bash
cd /root/custom-setup
exec ./install-auto.sh
EOFINSTALL
chmod +x airootfs/usr/local/bin/install-arch
echo "  ✓ install-arch command created"

# CRITICAL: Set file permissions that will persist in the ISO
echo "→ Configuring persistent file permissions..."
# Add to profiledef.sh to ensure permissions persist
cat >> profiledef.sh << "EOFPERMS"

# File permissions that will be set in the live environment
file_permissions=(
  ["/usr/local/bin/install-arch"]="0:0:755"
  ["/root/custom-setup/install.sh"]="0:0:755"
  ["/root/custom-setup/install-auto.sh"]="0:0:755"
  ["/root"]="0:0:750"
)
EOFPERMS
echo "  ✓ File permissions configured"

# Create welcome message with cool ASCII art
echo "→ Creating welcome message with ASCII art..."
cat > airootfs/root/.zshrc << '\''EOFZSH'\''
# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[1;37m"
NC="\033[0m"

clear
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   ██████╗  █████╗ ██████╗ ████████╗███████╗███████╗██╗  ██╗                 ║
║   ██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔════╝██║ ██╔╝                 ║
║   ██████╔╝███████║██████╔╝   ██║   █████╗  █████╗  █████╔╝                  ║
║   ██╔═══╝ ██╔══██║██╔══██╗   ██║   ██╔══╝  ██╔══╝  ██╔═██╗                  ║
║   ██║     ██║  ██║██║  ██║   ██║   ███████╗███████╗██║  ██╗                 ║
║   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝                 ║
║                                                                              ║
EOF
echo -e "${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${WHITE}║                                                                              ║${NC}"
echo -e "${GREEN}║                    ✨ Custom Arch Linux - By Parteek ✨                       ║${NC}"
echo -e "${WHITE}║                                                                              ║${NC}"
echo -e "${YELLOW}║  🚀 Hyprland Wayland Compositor  │  🎨 10 Beautiful Themes                   ║${NC}"
echo -e "${YELLOW}║  ⚡ Hyde-Inspired Customization  │  🔧 Developer-Focused Setup               ║${NC}"
echo -e "${WHITE}║                                                                              ║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${WHITE}║                                                                              ║${NC}"
echo -e "${CYAN}║  🎯 AUTOMATED INSTALLATION:                                                   ║${NC}"
echo -e "${WHITE}║                                                                              ║${NC}"
echo -e "${GREEN}║     Run: ${WHITE}install-arch${NC}                                                          ${WHITE}║${NC}"
echo -e "${WHITE}║                                                                              ║${NC}"
echo -e "${CYAN}║  ⏱️  Installation takes 15-20 minutes                                         ║${NC}"
echo -e "${CYAN}║  🌐 Requires internet connection (or use offline ISO)                         ║${NC}"
echo -e "${WHITE}║                                                                              ║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${WHITE}║                                                                              ║${NC}"
echo -e "${YELLOW}║  📚 FEATURES AFTER INSTALLATION:                                             ║${NC}"
echo -e "${WHITE}║                                                                              ║${NC}"
echo -e "${GREEN}║     • Super + Shift + T  ${WHITE}→${NC}  Theme selector (10 themes!)                    ${WHITE}║${NC}"
echo -e "${GREEN}║     • Super + Shift + W  ${WHITE}→${NC}  Wallpaper picker                               ${WHITE}║${NC}"
echo -e "${GREEN}║     • Super + T          ${WHITE}→${NC}  Terminal                                       ${WHITE}║${NC}"
echo -e "${GREEN}║     • Super + A          ${WHITE}→${NC}  Application launcher                           ${WHITE}║${NC}"
echo -e "${GREEN}║     • Super + /          ${WHITE}→${NC}  Show all keybindings                           ${WHITE}║${NC}"
echo -e "${WHITE}║                                                                              ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${CYAN}📦 Available disks:${NC}"
lsblk -d -o NAME,SIZE,TYPE | grep disk | while read line; do
    echo -e "   ${YELLOW}$line${NC}"
done
echo ""
echo -e "${GREEN}Ready to install? Type: ${WHITE}install-arch${NC}"
echo ""
EOFZSH

# Add packages
echo "→ Adding packages to live environment..."
cat >> packages.x86_64 << "EOFPKG"
git
neovim
htop
EOFPKG

# Build ISO
echo ""
echo "╔════════════════════════════════════════╗"
echo "║ Building ISO (20-30 minutes)           ║"
echo "╚════════════════════════════════════════╝"
echo ""

mkarchiso -v -w "$WORK_DIR/work" -o "$OUTPUT_DIR" "$ISO_DIR"
BUILD_EXIT=$?

if [ $BUILD_EXIT -eq 0 ]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║              ISO Build Complete! 🎉                       ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    ls -lh "$OUTPUT_DIR"/*.iso
    exit 0
else
    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║              BUILD FAILED ✗                               ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    exit 1
fi
'

BUILD_RESULT=$?

# Check result
if [ $BUILD_RESULT -eq 0 ]; then
    ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
    if [ -f "$ISO_FILE" ]; then
        ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
        WIN_PATH=$(wslpath -w "$ISO_FILE")

        echo ""
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║              ISO Build Complete! 🎉                       ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${GREEN}✓${NC} ISO created successfully!"
        echo ""
        echo "ISO Details:"
        echo "  File: $ISO_FILE"
        echo "  Windows path: $WIN_PATH"
        echo "  Size: $ISO_SIZE"
        echo ""
        echo "Next steps:"
        echo "  1. Use this ISO in VirtualBox"
        echo "  2. Boot the VM and run: install-arch"
        echo ""
    fi
else
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║              BUILD FAILED ✗                               ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}✗${NC} Build failed. Check the output above for errors."
    echo ""
    exit 1
fi
