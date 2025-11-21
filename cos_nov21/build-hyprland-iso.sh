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
  CustomOS Nov21 ISO Builder
  Clean & Simple
===================================================
EOF
echo -e "${NC}"

ISO_NAME="customos-nov21"
ISO_VERSION=$(date +%Y%m%d-%H%M)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/iso-output"
CACHE_DIR="$HOME/.cache/archiso-customos"
IMAGE_NAME="archiso-builder"

echo ""
echo -e "${YELLOW}CustomOS Nov21 - Simplified Hyprland ISO${NC}"
echo "Output: $OUTPUT_DIR/${ISO_NAME}-${ISO_VERSION}.iso"
echo ""
echo "Includes:"
echo "  ✓ Hyprland with SUPER key bindings"
echo "  ✓ Complete font stack"
echo "  ✓ Waybar + Mako + Wofi"
echo "  ✓ All configs in cos_nov21/dotfiles/"
echo "  ✓ Separate post-install script"
echo ""

# Verify files exist
if [ ! -f "$SCRIPT_DIR/post-install.sh" ]; then
    echo -e "${RED}✗${NC} post-install.sh not found!"
    exit 1
fi

if [ ! -d "$SCRIPT_DIR/dotfiles" ]; then
    echo -e "${RED}✗${NC} dotfiles directory not found!"
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

docker run --rm --privileged \
    -v "$ROOT_DIR:/workspace" \
    -v "$CACHE_DIR:/var/cache/pacman/pkg" \
    -w /workspace/cos_nov21 \
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
WORK_DIR="/tmp/archiso-customos-nov21"
ISO_DIR="$WORK_DIR/iso-build"
OUTPUT_DIR="/workspace/cos_nov21/iso-output"

echo "→ Cleaning old work..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

echo "→ Copying archiso releng profile..."
cp -r /usr/share/archiso/configs/releng "$ISO_DIR"
cd "$ISO_DIR"

echo "→ Creating custom setup in ISO..."
mkdir -p airootfs/root/custom-setup

# Copy dotfiles
echo "→ Copying dotfiles..."
if [ -d "/workspace/cos_nov21/dotfiles" ]; then
    cp -r /workspace/cos_nov21/dotfiles airootfs/root/custom-setup/
    echo "  ✓ Dotfiles copied"
else
    echo "  ✗ ERROR: dotfiles not found!"
    exit 1
fi

# Copy post-install script
echo "→ Copying post-install script..."
if [ -f "/workspace/cos_nov21/post-install.sh" ]; then
    cp /workspace/cos_nov21/post-install.sh airootfs/root/custom-setup/
    chmod +x airootfs/root/custom-setup/post-install.sh
    echo "  ✓ Post-install script copied"
else
    echo "  ✗ ERROR: post-install.sh not found!"
    exit 1
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

# Create install command
echo "→ Creating install-arch command..."
mkdir -p airootfs/usr/local/bin
cat > airootfs/usr/local/bin/install-arch << "EOFCMD"
#!/bin/bash
cd /root/custom-setup || exit 1
if [ -f post-install.sh ]; then
    chmod +x post-install.sh
    exec bash ./post-install.sh
else
    echo "Error: post-install.sh not found!"
    exit 1
fi
EOFCMD
chmod +x airootfs/usr/local/bin/install-arch

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

# Set permissions
cat >> profiledef.sh << "EOFPERMS"

# File permissions
file_permissions=(
  ["/usr/local/bin/install-arch"]="0:0:755"
  ["/root/custom-setup"]="0:0:755"
  ["/root/custom-setup/post-install.sh"]="0:0:755"
  ["/root"]="0:0:750"
)
EOFPERMS

# Customize ISO name
ISO_DATE=$(date +%Y.%m.%d)
sed -i "s/iso_name=\"archlinux\"/iso_name=\"${ISO_NAME}\"/" profiledef.sh
sed -i "s/iso_version=\"[0-9.]*\"/iso_version=\"${ISO_DATE}\"/" profiledef.sh

echo "→ ISO customization applied:"
echo "  Name: ${ISO_NAME}"
echo "  Version: ${ISO_DATE}"

# Build ISO
echo ""
echo "=================================================="
echo "  Building CustomOS Nov21 ISO - 10-15 minutes"
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
'

# Check if build succeeded
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)

    echo ""
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN}  CustomOS Nov21 ISO Build Complete!${NC}"
    echo -e "${GREEN}====================================================${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} ISO created successfully!"
    echo ""
    echo "Details:"
    echo "  File: $ISO_FILE"
    echo "  Size: $ISO_SIZE"
    echo ""
    echo "Features:"
    echo "  ✓ SUPER key bindings (SUPER+T for terminal)"
    echo "  ✓ All configs in cos_nov21/dotfiles/"
    echo "  ✓ Separate post-install.sh for easy editing"
    echo "  ✓ Complete font stack"
    echo "  ✓ Waybar, Mako, Wofi pre-configured"
    echo ""
    echo "Test with QEMU:"
    echo "  ./test-iso-qemu-install.sh"
    echo ""
else
    echo ""
    echo -e "${RED}✗ ISO build failed!${NC}"
    exit 1
fi
