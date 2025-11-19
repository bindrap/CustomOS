#!/bin/bash

# Custom Arch ISO Builder with Hyprland
# Based on working minimal ISO + adds custom setup
# Built incrementally on proven foundation

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
║  Custom Arch ISO Builder with Hyprland        ║
║  Minimal Base + Custom Setup                  ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

ISO_NAME="custom-arch"
ISO_VERSION=$(date +%Y%m%d-%H%M)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/iso-output"
CACHE_DIR="$HOME/.cache/archiso-custom"
IMAGE_NAME="archiso-builder"

echo ""
echo -e "${YELLOW}This builds CustomOS with Hyprland${NC}"
echo "Output: $OUTPUT_DIR/${ISO_NAME}-${ISO_VERSION}.iso"
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
echo -e "${BLUE}Building custom ISO in Docker...${NC}"
echo ""

docker run --rm --privileged \
    -v "$ROOT_DIR:/workspace" \
    -v "$CACHE_DIR:/var/cache/pacman/pkg" \
    -w /workspace/customIso_nov19 \
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
WORK_DIR="/tmp/archiso-custom"
ISO_DIR="$WORK_DIR/iso-build"
OUTPUT_DIR="/workspace/customIso_nov19/iso-output"

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

# Ensure all scripts are executable
echo "→ Making scripts executable..."
find airootfs/root/custom-setup -type f -name "*.sh" -exec chmod +x {} \;
chmod +x airootfs/root/custom-setup/dotfiles/hypr/scripts/* 2>/dev/null || true
chmod +x airootfs/root/custom-setup/dotfiles/waybar/scripts/* 2>/dev/null || true

# Verify critical files exist
echo "→ Verifying setup files..."
if [ -f "airootfs/root/custom-setup/install-auto.sh" ]; then
    echo "  ✓ install-auto.sh found"
else
    echo "  ✗ ERROR: install-auto.sh missing!"
    exit 1
fi

if [ -f "airootfs/root/custom-setup/post-install.sh" ]; then
    echo "  ✓ post-install.sh found"
else
    echo "  ✗ WARNING: post-install.sh missing!"
fi

if [ -d "airootfs/root/custom-setup/dotfiles/hypr" ]; then
    echo "  ✓ Hyprland configs found"
else
    echo "  ✗ WARNING: Hyprland configs missing!"
fi

# Create welcome message
cat > airootfs/root/.zshrc << "EOFZSH"
cat << "WELCOME"

╔════════════════════════════════════════════════════════════╗
║                                                            ║
║   ██████╗██╗   ██╗███████╗████████╗ ██████╗ ███╗   ███╗   ║
║  ██╔════╝██║   ██║██╔════╝╚══██╔══╝██╔═══██╗████╗ ████║   ║
║  ██║     ██║   ██║███████╗   ██║   ██║   ██║██╔████╔██║   ║
║  ██║     ██║   ██║╚════██║   ██║   ██║   ██║██║╚██╔╝██║   ║
║  ╚██████╗╚██████╔╝███████║   ██║   ╚██████╔╝██║ ╚═╝ ██║   ║
║   ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝   ║
║                                                            ║
║           CustomOS with Hyprland - Live ISO                ║
║                                                            ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  INSTALLATION:                                             ║
║                                                            ║
║    Run: install-arch                                       ║
║                                                            ║
║  This will:                                                ║
║    • Partition and format your disk                       ║
║    • Install base Arch Linux                              ║
║    • Copy CustomOS setup                                  ║
║    • On first login: Install Hyprland + all themes        ║
║                                                            ║
║  Features after installation:                              ║
║    • Hyprland Wayland Compositor                          ║
║    • 10 Pre-configured Themes                             ║
║    • Complete Waybar with 3 styles                        ║
║    • Hyde-inspired customization system                   ║
║    • All utility scripts                                  ║
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

# Verify install-arch was created
if [ -f airootfs/usr/local/bin/install-arch ]; then
    echo "  ✓ install-arch command created"
else
    echo "  ✗ ERROR: install-arch command failed!"
    exit 1
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
  ["/root"]="0:0:750"
)
EOFPERMS

# Customize ISO label
ISO_LABEL="${ISO_NAME^^}"
ISO_VER="${ISO_VERSION//-/}"
sed -i "s/ARCH_[0-9]*/${ISO_LABEL}_${ISO_VER}/" profiledef.sh

# Fix UEFI boot issues for VirtualBox compatibility
echo "→ Applying VirtualBox boot compatibility fixes..."
# Ensure syslinux (BIOS boot) works properly
if [ -f "syslinux/archiso_sys-linux.cfg" ]; then
    # Add nomodeset as fallback option
    sed -i "s|archisobasedir=arch|archisobasedir=arch nomodeset|" syslinux/archiso_sys-linux.cfg 2>/dev/null || true
fi
echo "  ✓ BIOS boot compatibility configured"

# Build ISO
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║  Building ISO (10-15 minutes)                  ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "NOTE: If ISO fails to boot in VirtualBox UEFI mode,"
echo "      disable EFI in VM settings (use BIOS mode)."
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
    echo -e "${GREEN}║  CustomOS ISO Build Complete!                              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} ISO created successfully!"
    echo ""
    echo "Details:"
    echo "  File: $ISO_FILE"
    echo "  Size: $ISO_SIZE"
    echo ""
    echo "What's included:"
    echo "  ✓ Base Arch Linux"
    echo "  ✓ Custom installer (install-arch command)"
    echo "  ✓ Hyprland configs (10 themes)"
    echo "  ✓ Waybar configs (3 styles)"
    echo "  ✓ All custom scripts"
    echo "  ✓ VirtualBox guest additions"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Test in VirtualBox:"
    echo "     - Create VM: Arch Linux 64-bit"
    echo "     - RAM: 4GB+, Disk: 50GB+"
    echo "     - Graphics: VMSVGA with 3D"
    echo "     - Enable EFI in System settings"
    echo ""
    echo "  2. Boot the ISO"
    echo ""
    echo "  3. Run: install-arch"
    echo ""
    echo "  4. Follow prompts (10-15 minutes)"
    echo ""
    echo "  5. Reboot and login"
    echo ""
    echo "  6. Hyprland + themes auto-install on first login!"
    echo ""
else
    echo ""
    echo -e "${RED}✗ ISO build failed!${NC}"
    exit 1
fi
