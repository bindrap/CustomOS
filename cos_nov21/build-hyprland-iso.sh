#!/bin/bash

# CustomOS Nov21 ISO Builder
# Clean, simplified build process

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
===================================================
  PBOS (Parteek Bindra Operating System)
  Hyprland Edition ISO Builder
===================================================
EOF
echo -e "${NC}"

ISO_NAME="pbos-hyprland"
ISO_VERSION=$(date +%Y%m%d-%H%M)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/iso-output"
CACHE_DIR="$HOME/.cache/archiso-pbos"
IMAGE_NAME="archiso-builder"

echo ""
echo -e "${YELLOW}PBOS (Parteek Bindra Operating System) - Hyprland Edition${NC}"
echo "Output: $OUTPUT_DIR/${ISO_NAME}-${ISO_VERSION}.iso"
echo ""
echo "Includes:"
echo "  ✓ HyDE Desktop Environment"
echo "  ✓ Complete font stack"
echo "  ✓ CachyOS kernel + zram"
echo "  ✓ Full installation scripts"
echo ""

# Verify files exist
if [ ! -f "$SCRIPT_DIR/install-auto.sh" ]; then
    echo -e "${RED}✗${NC} install-auto.sh not found!"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/install.sh" ]; then
    echo -e "${RED}✗${NC} install.sh not found!"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/post-install.sh" ]; then
    echo -e "${RED}✗${NC} post-install.sh not found!"
    exit 1
fi

echo -e "${GREEN}✓${NC} All required files found"

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
echo -e "${BLUE}Building ISO in Docker...${NC}"
echo ""

docker run --rm -i --privileged \
    -v "$ROOT_DIR:/workspace" \
    -v "$CACHE_DIR:/var/cache/pacman/pkg" \
    -w /workspace/cos_nov21 \
    -e ISO_NAME="$ISO_NAME" \
    -e ISO_VERSION="$ISO_VERSION" \
    -e DOCKER_IMAGE="$DOCKER_IMAGE" \
    "$DOCKER_IMAGE" \
    bash -s <<'EOSCRIPT'
set -euo pipefail

# Setup if using base image
if [ "${DOCKER_IMAGE}" = "archlinux:latest" ]; then
    echo "→ Setting up Arch environment..."
    pacman -Sy --noconfirm reflector
    reflector --country US,CA --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 10/" /etc/pacman.conf
    pacman -Sy --noconfirm
    pacman -S --needed --noconfirm archiso
fi

WORK_DIR="/workspace/cos_nov21/work"
ISO_DIR="$WORK_DIR/iso-build"
OUTPUT_DIR="/workspace/cos_nov21/iso-output"

echo "→ Cleaning old work..."
rm -rf "$WORK_DIR"
# Also clean any failed SquashFS temp files
rm -rf /tmp/squashfs-* 2>/dev/null || true
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

echo "→ Copying archiso releng profile..."
cp -r /usr/share/archiso/configs/releng "$ISO_DIR"
cd "$ISO_DIR"

# Remove auto-run stub that prints permission denied on login
rm -f airootfs/root/.automated_script.sh
sed -i '/automated_script/d' airootfs/root/.zlogin 2>/dev/null || true

echo "→ Creating custom setup in ISO..."
mkdir -p airootfs/root/custom-setup

# Copy installation scripts
echo "→ Copying installation scripts..."
if [ -f "/workspace/cos_nov21/install-auto.sh" ]; then
    cp /workspace/cos_nov21/install-auto.sh airootfs/root/custom-setup/
    chmod +x airootfs/root/custom-setup/install-auto.sh
    echo "  ✓ install-auto.sh copied"
else
    echo "  ✗ ERROR: install-auto.sh not found!"
    exit 1
fi

if [ -f "/workspace/cos_nov21/install.sh" ]; then
    cp /workspace/cos_nov21/install.sh airootfs/root/custom-setup/
    chmod +x airootfs/root/custom-setup/install.sh
    echo "  ✓ install.sh copied"
else
    echo "  ✗ ERROR: install.sh not found!"
    exit 1
fi

if [ -f "/workspace/cos_nov21/post-install.sh" ]; then
    cp /workspace/cos_nov21/post-install.sh airootfs/root/custom-setup/
    chmod +x airootfs/root/custom-setup/post-install.sh
    echo "  ✓ post-install.sh copied"
else
    echo "  ✗ ERROR: post-install.sh not found!"
    exit 1
fi

# Copy WiFi setup script
if [ -f "/workspace/cos_nov21/wifi-setup.sh" ]; then
    cp /workspace/cos_nov21/wifi-setup.sh airootfs/root/custom-setup/
    chmod +x airootfs/root/custom-setup/wifi-setup.sh
    echo "  ✓ wifi-setup.sh copied"
else
    echo "  ⚠ wifi-setup.sh not found (optional)"
fi

# Copy partition helper script
if [ -f "/workspace/cos_nov21/partition-helper-safe.sh" ]; then
    cp /workspace/cos_nov21/partition-helper-safe.sh airootfs/root/custom-setup/
    chmod +x airootfs/root/custom-setup/partition-helper-safe.sh
    echo "  ✓ partition-helper-safe.sh copied"
else
    echo "  ⚠ partition-helper-safe.sh not found (optional)"
fi

# Copy documentation
echo "→ Copying documentation..."
if [ -f "/workspace/cos_nov21/SAFE_DUAL_BOOT_SETUP.md" ]; then
    cp /workspace/cos_nov21/SAFE_DUAL_BOOT_SETUP.md airootfs/root/custom-setup/
    echo "  ✓ SAFE_DUAL_BOOT_SETUP.md copied"
fi
if [ -f "/workspace/cos_nov21/DUAL_BOOT_GUIDE.md" ]; then
    cp /workspace/cos_nov21/DUAL_BOOT_GUIDE.md airootfs/root/custom-setup/
    echo "  ✓ DUAL_BOOT_GUIDE.md copied"
fi
if [ -f "/workspace/cos_nov21/SWAP_SETUP_GUIDE.md" ]; then
    cp /workspace/cos_nov21/SWAP_SETUP_GUIDE.md airootfs/root/custom-setup/
    echo "  ✓ SWAP_SETUP_GUIDE.md copied"
fi

# Copy stoic quotes for dynamic MOTD
if [ -f "/workspace/cos_nov21/stoic-quotes.txt" ]; then
    cp /workspace/cos_nov21/stoic-quotes.txt airootfs/root/custom-setup/
    mkdir -p airootfs/usr/share/pbos
    cp /workspace/cos_nov21/stoic-quotes.txt airootfs/usr/share/pbos/
    echo "  ✓ stoic-quotes.txt copied"
fi

# Copy MOTD generator script
if [ -f "/workspace/cos_nov21/generate-motd.sh" ]; then
    cp /workspace/cos_nov21/generate-motd.sh airootfs/usr/local/bin/
    chmod +x airootfs/usr/local/bin/generate-motd.sh
    echo "  ✓ generate-motd.sh copied"
fi

# Copy issue generator script (for login screen branding)
if [ -f "/workspace/cos_nov21/generate-issue.sh" ]; then
    cp /workspace/cos_nov21/generate-issue.sh airootfs/usr/local/bin/
    chmod +x airootfs/usr/local/bin/generate-issue.sh
    echo "  ✓ generate-issue.sh copied"
fi

# Copy wallpapers
echo "→ Copying wallpapers..."
mkdir -p airootfs/root/custom-setup/wallpapers
if [ -d "/workspace/cos_nov21/wallpapers" ]; then
    find /workspace/cos_nov21/wallpapers -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec cp {} airootfs/root/custom-setup/wallpapers/ \; 2>/dev/null || true
    WALLPAPER_COUNT=$(find airootfs/root/custom-setup/wallpapers -type f | wc -l)
    echo "  ✓ Copied $WALLPAPER_COUNT wallpapers"
else
    echo "  ⚠ No wallpapers directory"
fi

# Create convenience commands
echo "→ Creating helper commands..."
mkdir -p airootfs/usr/local/bin

# Install command
cat > airootfs/usr/local/bin/install-arch << "EOFCMD"
#!/bin/bash
cd /root/custom-setup || exit 1
if [ -f install-auto.sh ]; then
    chmod +x install-auto.sh
    exec bash ./install-auto.sh
else
    echo "Error: install-auto.sh not found!"
    exit 1
fi
EOFCMD
chmod +x airootfs/usr/local/bin/install-arch

# WiFi setup command
cat > airootfs/usr/local/bin/setup-wifi << "EOFCMD"
#!/bin/bash
cd /root/custom-setup || exit 1
if [ -f wifi-setup.sh ]; then
    chmod +x wifi-setup.sh
    exec bash ./wifi-setup.sh
else
    echo "Error: wifi-setup.sh not found!"
    echo "Try: iwctl --passphrase PASSWORD station wlan0 connect SSID"
    exit 1
fi
EOFCMD
chmod +x airootfs/usr/local/bin/setup-wifi

# Partition helper command
cat > airootfs/usr/local/bin/partition-disk << "EOFCMD"
#!/bin/bash
cd /root/custom-setup || exit 1
if [ -f partition-helper-safe.sh ]; then
    chmod +x partition-helper-safe.sh
    exec bash ./partition-helper-safe.sh
else
    echo "Error: partition-helper-safe.sh not found!"
    exit 1
fi
EOFCMD
chmod +x airootfs/usr/local/bin/partition-disk

# Add packages to live environment
echo "→ Adding packages to live environment..."
cat >> packages.x86_64 << "EOFPKG"
# CustomOS Nov21 additions
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

# Configure dynamic MOTD on login
echo "→ Configuring dynamic MOTD..."
mkdir -p airootfs/root

# Create .bash_profile for root that runs generate-motd.sh on login
cat > airootfs/root/.bash_profile << "EOFPROFILE"
# Run dynamic MOTD generator on login
if [ -x /usr/local/bin/generate-motd.sh ]; then
    /usr/local/bin/generate-motd.sh
fi

# Source .bashrc if it exists
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
EOFPROFILE

# Create a minimal static motd as fallback (dynamic one is better)
mkdir -p airootfs/etc
cat > airootfs/etc/motd << "EOFMOTD"

Welcome to PBOS (Parteek Bindra Operating System)

Quick Start:
  setup-wifi       - Connect to WiFi
  partition-disk   - Prepare disk for dual boot
  install-arch     - Install PBOS

Docs: ~/custom-setup/

EOFMOTD

# Generate initial /etc/issue with PBOS branding
echo "→ Generating /etc/issue with PBOS branding..."
if [ -x airootfs/usr/local/bin/generate-issue.sh ]; then
    if bash airootfs/usr/local/bin/generate-issue.sh; then
        echo "  ✓ /etc/issue generated by script"
    else
        cat > airootfs/etc/issue << 'PBOS_ISSUE_END'

╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║   ██████╗   ██████╗   ██████╗   ██████╗                                  ║
║   ██╔══██╗  ██╔══██╗ ██╔═══██╗ ██╔══██╗                                  ║
║   ██████╔╝  ██████╔╝ ██║   ██║ ╚█████╔╝                                  ║
║   ██╔═══╝   ██╔══██╗ ██║   ██║  ██╔══██╗                                 ║
║   ██║       ██████╔╝ ╚██████╔╝  ██████╔╝                                 ║
║   ╚═╝       ╚═════╝   ╚═════╝   ╚═════╝                                  ║
║                                                                          ║
║        Parteek Bindra Operating System                                   ║
║          Terminus Ut Exordium.                                           ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

PBOS_ISSUE_END
        echo "  ✓ Fallback /etc/issue created"
    fi
else
    cat > airootfs/etc/issue << 'PBOS_ISSUE_END'

╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║   ██████╗   ██████╗   ██████╗   ██████╗                                  ║
║   ██╔══██╗  ██╔══██╗ ██╔═══██╗ ██╔══██╗                                  ║
║   ██████╔╝  ██████╔╝ ██║   ██║ ╚█████╔╝                                  ║
║   ██╔═══╝   ██╔══██╗ ██║   ██║  ██╔══██╗                                 ║
║   ██║       ██████╔╝ ╚██████╔╝  ██████╔╝                                 ║
║   ╚═╝       ╚═════╝   ╚═════╝   ╚═════╝                                  ║
║                                                                          ║
║        Parteek Bindra Operating System                                   ║
║          Terminus Ut Exordium.                                           ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

PBOS_ISSUE_END
    echo "  ⚠ generate-issue.sh not found, using static /etc/issue"
fi

# Set permissions
cat >> profiledef.sh << "EOFPERMS"

# File permissions
file_permissions=(
  ["/usr/local/bin/install-arch"]="0:0:755"
  ["/usr/local/bin/setup-wifi"]="0:0:755"
  ["/usr/local/bin/partition-disk"]="0:0:755"
  ["/usr/local/bin/generate-motd.sh"]="0:0:755"
  ["/usr/local/bin/generate-issue.sh"]="0:0:755"
  ["/root/custom-setup"]="0:0:755"
  ["/root/custom-setup/install-auto.sh"]="0:0:755"
  ["/root/custom-setup/install.sh"]="0:0:755"
  ["/root/custom-setup/post-install.sh"]="0:0:755"
  ["/root/custom-setup/wifi-setup.sh"]="0:0:755"
  ["/root/custom-setup/partition-helper-safe.sh"]="0:0:755"
  ["/root/custom-setup/stoic-quotes.txt"]="0:0:644"
  ["/usr/share/pbos/stoic-quotes.txt"]="0:0:644"
  ["/root/.bash_profile"]="0:0:644"
  ["/root"]="0:0:750"
  ["/etc/motd"]="0:0:644"
  ["/etc/issue"]="0:0:644"
)
EOFPERMS

# Customize ISO name
ISO_DATE=$(date +%Y.%m.%d)
sed -i "s/iso_name=\"archlinux\"/iso_name=\"${ISO_NAME}\"/" profiledef.sh
sed -i "s/iso_version=\"[0-9.]*\"/iso_version=\"${ISO_DATE}\"/" profiledef.sh

# Use lighter compression to avoid out-of-memory errors in Docker
# gzip uses much less memory than xz (default)
echo "→ Setting compression to gzip (lower memory usage)..."
# Add compression options after the airootfs_image_type line
sed -i "/airootfs_image_type=\"squashfs\"/a airootfs_image_tool_options=(\"-comp\" \"gzip\" \"-Xcompression-level\" \"6\" \"-b\" \"1M\")" profiledef.sh

echo "→ ISO customization applied:"
echo "  Name: ${ISO_NAME}"
echo "  Version: ${ISO_DATE}"
echo "  Compression: gzip (memory-efficient)"

# Build ISO
echo ""
echo "=================================================="
echo "  Building PBOS Hyprland ISO - 10-15 minutes"
echo "=================================================="
echo ""

mkarchiso -v -w "$WORK_DIR/work" -o "$OUTPUT_DIR" "$ISO_DIR"

# Check result
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
    echo ""
    echo "=================================================="
    echo "  ISO Build Complete!"
    echo "=================================================="
    echo ""
    echo "ISO: $ISO_FILE"
    echo "Size: $ISO_SIZE"
    echo ""
else
    echo ""
    echo "✗ ISO build failed!"
    exit 1
fi
EOSCRIPT

# Check if build succeeded
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)

    echo ""
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN}  PBOS Hyprland ISO Build Complete!${NC}"
    echo -e "${GREEN}====================================================${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} ISO created successfully!"
    echo ""
    echo "Details:"
    echo "  File: $ISO_FILE"
    echo "  Size: $ISO_SIZE"
    echo ""
    echo "Features:"
    echo "  ✓ Hyprland with ALT key bindings"
    echo "  ✓ WiFi and partition helper scripts"
    echo "  ✓ Dual boot safe installation"
    echo "  ✓ Complete Hyprland configs"
    echo "  ✓ Dynamic MOTD with colorful ASCII art"
    echo "  ✓ Random stoic philosophy quotes on each login"
    echo ""
    echo "Test with QEMU:"
    echo "  ./test-iso-qemu-install.sh"
    echo ""
else
    echo ""
    echo -e "${RED}✗ ISO build failed!${NC}"
    exit 1
fi
