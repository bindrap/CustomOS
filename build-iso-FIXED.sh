#!/bin/bash

# Docker-based Arch Linux ISO Builder for WSL
# Runs the ISO build inside an Arch Linux container
# Output ISO is accessible from Windows
# FIX: Remove hyphens from ISO label to fix boot issues

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
║        Custom Arch Linux ISO Builder (FIXED)              ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

ISO_NAME="parteekarch"  # NO HYPHEN - this is critical for boot!
ISO_VERSION=$(date +%Y.%m.%d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/iso-output"

echo ""
echo -e "${YELLOW}Docker-based ISO Builder for WSL (FIXED VERSION)${NC}"
echo "This will build the ISO inside an Arch Linux container"
echo "Output: $OUTPUT_DIR/archlinux-${ISO_VERSION}-x86_64.iso"
echo ""
echo -e "${GREEN}FIX APPLIED:${NC} Removed hyphen from ISO label to fix boot issues"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗${NC} Docker is not installed!"
    echo ""
    echo "Please install Docker Desktop for Windows:"
    echo "  1. Download from: https://www.docker.com/products/docker-desktop"
    echo "  2. Install and restart your computer"
    echo "  3. Enable WSL 2 integration in Docker Desktop settings"
    echo ""
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}✗${NC} Docker daemon is not running!"
    echo ""
    echo "Please start Docker Desktop on Windows and try again."
    echo ""
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
echo -e "${BLUE}Building ISO in Docker container...${NC}"
echo ""

# Build the ISO inside Arch Linux container
# Mount the current directory so files are accessible
docker run --rm --privileged \
    -v "$SCRIPT_DIR:/workspace" \
    -w /workspace \
    archlinux:latest \
    bash -c '
# Update package database with better mirrors
echo "→ Configuring fast mirrors..."
# Use reflector to get fast mirrors
pacman -Sy --noconfirm reflector
reflector --country US --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo "→ Updating package database..."
pacman -Sy --noconfirm

# Install required packages
echo "→ Installing archiso and dependencies..."
pacman -S --needed --noconfirm archiso git

# Set up variables
ISO_NAME="parteekarch"  # NO HYPHEN!
ISO_VERSION=$(date +%Y.%m.%d)
WORK_DIR="/tmp/archiso-work"
ISO_DIR="$WORK_DIR/iso-build"
OUTPUT_DIR="/workspace/iso-output"

# Clean up old work
if [ -d "$WORK_DIR" ]; then
    echo "→ Cleaning up old work directory..."
    rm -rf "$WORK_DIR"
fi

# Create directories
echo "→ Creating work directories..."
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

# Copy archiso profile
echo "→ Copying archiso profile..."
cp -r /usr/share/archiso/configs/releng "$ISO_DIR"
cd "$ISO_DIR"

# Create custom setup directory in ISO
echo "→ Creating custom setup directory..."
mkdir -p airootfs/root/custom-setup

# Copy custom setup files if they exist
echo "→ Copying custom setup files..."
if [ -d "/workspace/custom-arch-setup" ]; then
    cp -r /workspace/custom-arch-setup/* airootfs/root/custom-setup/
    echo "  ✓ Custom setup files copied"
else
    echo "  ! No custom-arch-setup directory found"
    echo "  ! Creating minimal setup..."
    mkdir -p airootfs/root/custom-setup
fi

# Ensure install scripts are executable
echo "→ Ensuring install scripts are executable..."
chmod +x airootfs/root/custom-setup/*.sh 2>/dev/null || true
# Make all scripts executable recursively
find airootfs/root/custom-setup -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

# Verify critical files exist
echo "→ Verifying setup files..."
if [ -f "airootfs/root/custom-setup/install-auto.sh" ]; then
    echo "  ✓ install-auto.sh found"
else
    echo "  ! WARNING: install-auto.sh missing!"
fi
if [ -d "airootfs/root/custom-setup/dotfiles" ]; then
    echo "  ✓ dotfiles directory found"
else
    echo "  ! WARNING: dotfiles directory missing!"
fi

# Copy offline packages if they exist
if [ -d "/workspace/offline-packages" ]; then
    echo "→ Copying offline package cache..."
    mkdir -p airootfs/root/custom-setup/packages
    cp /workspace/offline-packages/*.pkg.tar.zst airootfs/root/custom-setup/packages/ 2>/dev/null || true
    OFFLINE_MODE="yes"
else
    echo "! No offline packages found (online-only ISO)"
    OFFLINE_MODE="no"
fi

# Create welcome script
echo "→ Creating welcome message..."
cat > airootfs/root/.zshrc << "EOFZSH"
# Display welcome message
cat << "WELCOME"

╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   ██████╗  █████╗ ██████╗ ████████╗███████╗███████╗██╗  ║
║   ██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔════╝██║  ║
║   ██████╔╝███████║██████╔╝   ██║   █████╗  █████╗  ██║  ║
║   ██╔═══╝ ██╔══██║██╔══██╗   ██║   ██╔══╝  ██╔══╝  ██║  ║
║   ██║     ██║  ██║██║  ██║   ██║   ███████╗███████╗██║  ║
║   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ║
║                                                          ║
║     Custom Arch Linux - Automated Installation           ║
║                  By Parteek                              ║
║                                                          ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  AUTOMATED INSTALLATION:                                 ║
║                                                          ║
║    Run: install-arch                                     ║
║                                                          ║
║  This will:                                              ║
║    • Auto-detect online/offline mode                     ║
║    • Partition and format disk                           ║
║    • Install base Arch Linux                             ║
║    • Install Hyprland + all configs                      ║
║    • Setup user and system                               ║
║                                                          ║
║  MANUAL INSTALLATION:                                    ║
║                                                          ║
║    Run: archinstall  (guided)                            ║
║    Then: cd /root/custom-setup && ./install.sh           ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

WELCOME

# Show disk info
echo ""
echo "Available disks:"
lsblk -d -o NAME,SIZE,TYPE | grep disk
echo ""
EOFZSH

# Create install-arch command
echo "→ Creating install-arch command..."
mkdir -p airootfs/usr/local/bin
cat > airootfs/usr/local/bin/install-arch << "EOFINSTALL"
#!/bin/bash
cd /root/custom-setup
exec ./install-auto.sh
EOFINSTALL
chmod +x airootfs/usr/local/bin/install-arch

# Verify install-arch was created
if [ -f airootfs/usr/local/bin/install-arch ]; then
    echo "  ✓ install-arch command created"
else
    echo "  ! WARNING: install-arch command failed to create"
fi

# Customize packages (add tools to live environment)
echo "→ Adding packages to live environment..."
cat >> packages.x86_64 << "EOFPKG"
# Custom additions
git
neovim
htop
EOFPKG

# Customize ISO label - CRITICAL FIX
# ISO 9660 labels cannot contain hyphens or special characters
echo "→ Customizing ISO label (removing invalid characters)..."
ISO_LABEL=$(echo "${ISO_NAME}" | tr "[:lower:]" "[:upper:]" | tr -d "-")  # Remove hyphens!
ISO_VER_NODOTS=$(echo "${ISO_VERSION}" | tr -d ".")
echo "  ISO Label will be: ${ISO_LABEL}_${ISO_VER_NODOTS}"
sed -i "s/ARCH_[0-9]*/${ISO_LABEL}_${ISO_VER_NODOTS}/" profiledef.sh

# Build ISO
echo ""
echo "╔════════════════════════════════════════╗"
echo "║ Building ISO (this may take 10-15 min) ║"
echo "╚════════════════════════════════════════╝"
echo ""

mkarchiso -v -w "$WORK_DIR/work" -o "$OUTPUT_DIR" "$ISO_DIR"
BUILD_EXIT_CODE=$?

# Check if build succeeded
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    # Get ISO filename and size
    ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
    if [ -f "$ISO_FILE" ]; then
        ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)

        # Success message
        echo ""
        echo "╔═══════════════════════════════════════════════════════════╗"
        echo "║              ISO Build Complete! 🎉                       ║"
        echo "╚═══════════════════════════════════════════════════════════╝"
        echo ""
        echo "✓ ISO created successfully!"
        echo ""
        echo "ISO Details:"
        echo "  File: $ISO_FILE"
        echo "  Size: $ISO_SIZE"
        echo "  Offline support: $OFFLINE_MODE"
        echo ""
    else
        echo ""
        echo "╔═══════════════════════════════════════════════════════════╗"
        echo "║              BUILD FAILED ✗                               ║"
        echo "╚═══════════════════════════════════════════════════════════╝"
        echo ""
        echo "✗ ISO file not found after build!"
        echo ""
        exit 1
    fi
else
    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║              BUILD FAILED ✗                               ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    echo "✗ mkarchiso failed with exit code: $BUILD_EXIT_CODE"
    echo ""
    echo "Common causes:"
    echo "  • Network timeout downloading packages"
    echo "  • Slow mirror connection"
    echo "  • Insufficient disk space"
    echo ""
    echo "Try running the script again. It will use faster mirrors."
    echo ""
    exit 1
fi
'

# Check if build succeeded (outside Docker container)
if [ -f "$OUTPUT_DIR"/*.iso ]; then
    ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso | head -1)
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)

    # Convert WSL path to Windows path for user convenience
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
    echo -e "${GREEN}✓ FIX APPLIED:${NC} ISO label has NO HYPHENS (will boot properly)"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Open VirtualBox on Windows"
    echo ""
    echo "  2. VM Settings (CRITICAL):"
    echo "     - Display → UNCHECK '3D Acceleration'"
    echo "     - Display → Video Memory: 128MB"
    echo "     - Display → Graphics Controller: VMSVGA"
    echo "     - System → Motherboard → UNCHECK 'Enable EFI' (easiest)"
    echo "       OR: CHECK 'Enable EFI' + UNCHECK 'Secure Boot'"
    echo ""
    echo "  3. Mount ISO and boot VM"
    echo ""
    echo "  4. Run: install-arch"
    echo ""
else
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║              BUILD FAILED ✗                               ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}✗${NC} ISO build failed!"
    echo ""
    echo "The build failed inside the Docker container."
    echo "Common causes:"
    echo "  • Network timeout downloading packages (most likely)"
    echo "  • Slow or unstable internet connection"
    echo "  • Mirror server issues"
    echo ""
    echo "Solutions:"
    echo "  1. Try running ./build-iso-FIXED.sh again (will use faster mirrors)"
    echo "  2. Check your internet connection"
    echo "  3. Try again later when mirrors are less busy"
    echo ""
    exit 1
fi
