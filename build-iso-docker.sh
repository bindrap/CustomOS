#!/bin/bash

# Docker-based Arch Linux ISO Builder for WSL (Improved)
# Runs the ISO build inside an Arch Linux container
# Output ISO is accessible from Windows
#
# IMPROVEMENTS:
# - Uses cached Docker image for faster builds
# - Persistent package cache between builds
# - Parallel package downloads
# - Build validation
# - Better error handling
# - Old ISO cleanup

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Error handler
trap 'echo "❌ Build failed at line $LINENO"' ERR

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
║     Custom Arch Linux ISO Builder (Docker - Improved)     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

ISO_NAME="parteek-arch"
ISO_VERSION=$(date +%Y.%m.%d-%H%M)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/iso-output"
CACHE_DIR="$HOME/.cache/archiso-pkgs"
IMAGE_NAME="archiso-builder"
USE_CACHED_IMAGE="yes"

echo ""
echo -e "${YELLOW}Docker-based ISO Builder for WSL${NC}"
echo "This will build the ISO inside an Arch Linux container"
echo "Output: $OUTPUT_DIR/${ISO_NAME}-${ISO_VERSION}.iso"
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

# Check if cached image exists
if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    echo -e "${YELLOW}⚠${NC} Cached Docker image not found"
    echo ""
    echo "For faster builds, you can create a reusable Docker image:"
    echo "  ./build-docker-image.sh"
    echo ""
    echo "This build will use the base archlinux:latest image (slower)"
    read -p "Continue anyway? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        exit 0
    fi
    USE_CACHED_IMAGE="no"
else
    echo -e "${GREEN}✓${NC} Using cached Docker image (faster build!)"
fi

echo ""
read -p "Continue with ISO build? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    exit 0
fi

# Create directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$CACHE_DIR"

echo ""
echo -e "${BLUE}Building ISO in Docker container...${NC}"
echo ""

# Determine which image to use
if [ "$USE_CACHED_IMAGE" = "yes" ]; then
    DOCKER_IMAGE="$IMAGE_NAME"
else
    DOCKER_IMAGE="archlinux:latest"
fi

# Build the ISO inside Arch Linux container
# Mount the current directory AND a persistent package cache
docker run --rm --privileged \
    -v "$SCRIPT_DIR:/workspace" \
    -v "$CACHE_DIR:/var/cache/pacman/pkg" \
    -w /workspace \
    "$DOCKER_IMAGE" \
    bash -c '
# Error handling
set -euo pipefail
trap '\''echo "❌ Build failed inside container at line $LINENO"'\'' ERR

# If using base archlinux image, set up environment
if [ "'"$USE_CACHED_IMAGE"'" = "no" ]; then
    echo "→ Configuring fast mirrors..."
    pacman -Sy --noconfirm reflector
    reflector --country US,CA --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

    echo "→ Enabling parallel downloads..."
    sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 10/" /etc/pacman.conf

    echo "→ Updating package database..."
    pacman -Sy --noconfirm

    echo "→ Installing archiso and dependencies..."
    pacman -S --needed --noconfirm archiso git
fi

# Set up variables
ISO_NAME="'"$ISO_NAME"'"
ISO_VERSION="'"$ISO_VERSION"'"
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

# Remove default automated script and clean up .zlogin
echo "→ Removing default automated_script.sh..."
rm -f airootfs/root/.automated_script.sh

# Create a clean .zlogin (remove automated_script.sh call)
cat > airootfs/root/.zlogin << "EOFZLOGIN"
# fix for screen readers
if grep -Fqa '\''accessibility='\'' /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi
EOFZLOGIN

# Create install-arch command
echo "→ Creating install-arch command..."
mkdir -p airootfs/usr/local/bin
cat > airootfs/usr/local/bin/install-arch << "EOFINSTALL"
#!/bin/bash
cd /root/custom-setup || exit 1
chmod +x install-auto.sh
exec bash ./install-auto.sh
EOFINSTALL
chmod +x airootfs/usr/local/bin/install-arch

# Verify install-arch was created and is executable
if [ -f airootfs/usr/local/bin/install-arch ]; then
    echo "  ✓ install-arch command created"
    ls -la airootfs/usr/local/bin/install-arch | grep -q "x" && echo "  ✓ install-arch is executable" || echo "  ! WARNING: install-arch not executable"
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
pciutils
usbutils
lshw
dmidecode
virtualbox-guest-utils-nox
EOFPKG

# Set proper permissions in profiledef.sh
echo "→ Configuring file permissions in profiledef.sh..."
# Append file_permissions array to profiledef.sh to ensure permissions persist in the ISO
cat >> profiledef.sh << "EOFPERMS"

# File permissions that will be set in the live environment
file_permissions=(
  ["/usr/local/bin/install-arch"]="0:0:755"
  ["/root/custom-setup"]="0:0:755"
  ["/root/custom-setup/install.sh"]="0:0:755"
  ["/root/custom-setup/install-auto.sh"]="0:0:755"
  ["/root/custom-setup/post-install.sh"]="0:0:755"
  ["/root"]="0:0:750"
)
EOFPERMS
echo "  ✓ File permissions configured"

# Add boot parameters for better hardware compatibility
echo "→ Configuring boot parameters for VirtualBox compatibility..."
# The archiso releng profile uses GRUB for both UEFI and BIOS
# Configure GRUB with better kernel parameters
if [ -f "grub/grub.cfg" ]; then
    # Add VirtualBox-friendly kernel parameters
    sed -i "s/archisobasedir=arch/archisobasedir=arch vga=791 driver=free/" grub/grub.cfg || true
fi
echo "  ✓ Boot parameters configured"

# Customize ISO label
ISO_LABEL=$(echo "${ISO_NAME}" | tr "[:lower:]" "[:upper:]")
ISO_VER_NODOTS=$(echo "${ISO_VERSION}" | tr -d ".")
sed -i "s/ARCH_[0-9]*/${ISO_LABEL}_${ISO_VER_NODOTS}/" profiledef.sh

# Build ISO
echo ""
echo "╔════════════════════════════════════════╗"
echo "║ Building ISO (this may take 5-10 min)  ║"
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

        # Validate ISO
        echo ""
        echo "→ Validating ISO..."
        if file "$ISO_FILE" | grep -q "ISO 9660"; then
            echo "  ✓ Valid ISO format"
        else
            echo "  ✗ Warning: ISO validation failed!"
        fi

        # Check size
        ISO_SIZE_BYTES=$(stat -c%s "$ISO_FILE")
        if [ $ISO_SIZE_BYTES -lt 500000000 ]; then
            echo "  ⚠ Warning: ISO seems unusually small ($ISO_SIZE)"
        else
            echo "  ✓ ISO size: $ISO_SIZE"
        fi

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
    echo "Try running the script again. Packages are cached for faster retry."
    echo ""
    exit 1
fi
'

# Check if build succeeded (outside Docker container)
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)

    # Clean up old ISOs (keep only last 3)
    echo ""
    echo -e "${YELLOW}→${NC} Cleaning up old ISOs (keeping last 3)..."
    ls -t "$OUTPUT_DIR"/*.iso | tail -n +4 | xargs rm -f 2>/dev/null || true

    # Convert WSL path to Windows path for user convenience
    WIN_PATH=$(wslpath -w "$ISO_FILE" 2>/dev/null || echo "$ISO_FILE")

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
    echo "Performance Info:"
    if [ "$USE_CACHED_IMAGE" = "yes" ]; then
        echo -e "  ${GREEN}✓${NC} Used cached Docker image"
    else
        echo -e "  ${YELLOW}⚠${NC} Used base image (run ./build-docker-image.sh for faster builds)"
    fi
    echo -e "  ${GREEN}✓${NC} Package cache enabled at: $CACHE_DIR"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Use this ISO in VirtualBox"
    echo ""
    echo "  2. Boot the VM and run: install-arch"
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
    echo "Check the error messages above for details."
    echo ""
    exit 1
fi
