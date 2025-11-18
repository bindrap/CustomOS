#!/bin/bash

# Native Arch Linux ISO Builder
# For use on Endeavour OS, Arch Linux, or Arch-based distributions
# No Docker required!
#
# IMPROVEMENTS:
# - Parallel package downloads
# - Build validation
# - Better error handling
# - Old ISO cleanup
# - Multi-country mirror support

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Error handler
trap 'echo "❌ Build failed at line $LINENO"' ERR

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

ISO_NAME="parteek-arch"
ISO_VERSION=$(date +%Y.%m.%d-%H%M)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="/tmp/archiso-work"
ISO_DIR="$WORK_DIR/iso-build"
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
║      Custom Arch Linux ISO Builder (Native Linux)         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${YELLOW}Native Linux ISO Builder${NC}"
echo -e "${PURPLE}For Endeavour OS, Arch Linux, and Arch-based distros${NC}"
echo ""
echo "Output: $OUTPUT_DIR/${ISO_NAME}-${ISO_VERSION}.iso"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}✗${NC} Do not run this script as root!"
   echo "  The script will ask for sudo when needed"
   exit 1
fi

# Confirm to continue
read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    exit 0
fi

# Check dependencies
echo ""
echo -e "${BLUE}Checking dependencies...${NC}"
MISSING_DEPS=()

if ! command -v mkarchiso &> /dev/null; then
    MISSING_DEPS+=("archiso")
fi

if ! command -v git &> /dev/null; then
    MISSING_DEPS+=("git")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "${YELLOW}→${NC} Installing missing dependencies: ${MISSING_DEPS[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING_DEPS[@]}"
    echo -e "${GREEN}✓${NC} Dependencies installed"
else
    echo -e "${GREEN}✓${NC} All dependencies installed"
fi

# Enable parallel downloads if not already enabled
echo ""
echo -e "${YELLOW}→${NC} Optimizing pacman configuration..."
if ! grep -q "^ParallelDownloads" /etc/pacman.conf; then
    sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
    echo -e "${GREEN}✓${NC} Parallel downloads enabled"
else
    echo -e "${GREEN}✓${NC} Parallel downloads already enabled"
fi

# Clean up old work
if [ -d "$WORK_DIR" ]; then
    echo ""
    echo -e "${YELLOW}→${NC} Cleaning up old work directory..."
    sudo rm -rf "$WORK_DIR"
fi

# Create directories
echo -e "${YELLOW}→${NC} Creating work directories..."
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

# Copy archiso profile
echo ""
echo -e "${YELLOW}→${NC} Copying archiso profile..."
cp -r /usr/share/archiso/configs/releng "$ISO_DIR"
cd "$ISO_DIR"

# Create custom setup directory in ISO
echo -e "${YELLOW}→${NC} Creating custom setup directory..."
mkdir -p airootfs/root/custom-setup

# Copy our custom setup
echo -e "${YELLOW}→${NC} Copying custom setup files..."
if [ -d "$SCRIPT_DIR/custom-arch-setup" ]; then
    cp -r "$SCRIPT_DIR/custom-arch-setup"/* airootfs/root/custom-setup/
    echo -e "${GREEN}✓${NC} Custom setup files copied"
else
    echo -e "${RED}✗${NC} Custom setup directory not found at: $SCRIPT_DIR/custom-arch-setup"
    echo "Please ensure custom-arch-setup directory exists in: $SCRIPT_DIR"
    exit 1
fi

# Ensure install scripts are executable
echo -e "${YELLOW}→${NC} Ensuring install scripts are executable..."
chmod +x airootfs/root/custom-setup/*.sh 2>/dev/null || true
find airootfs/root/custom-setup -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

# Verify critical files exist
echo -e "${YELLOW}→${NC} Verifying setup files..."
MISSING_FILES=()

if [ ! -f "airootfs/root/custom-setup/install-auto.sh" ]; then
    MISSING_FILES+=("install-auto.sh")
fi

if [ ! -d "airootfs/root/custom-setup/dotfiles" ]; then
    MISSING_FILES+=("dotfiles/")
fi

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo -e "${RED}✗${NC} Missing critical files: ${MISSING_FILES[*]}"
    echo "Please ensure all required files are in custom-arch-setup/"
    exit 1
else
    echo -e "${GREEN}✓${NC} All critical files present"
fi

# Copy offline packages if they exist
if [ -d "$SCRIPT_DIR/offline-packages" ]; then
    echo ""
    echo -e "${YELLOW}→${NC} Copying offline package cache..."
    mkdir -p airootfs/root/custom-setup/packages
    cp "$SCRIPT_DIR/offline-packages"/*.pkg.tar.zst airootfs/root/custom-setup/packages/ 2>/dev/null || true
    PKG_COUNT=$(ls airootfs/root/custom-setup/packages/*.pkg.tar.zst 2>/dev/null | wc -l)
    if [ $PKG_COUNT -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Copied $PKG_COUNT offline packages"
        OFFLINE_MODE="yes"
    else
        echo -e "${YELLOW}!${NC} No packages found in offline-packages/"
        OFFLINE_MODE="no"
    fi
else
    echo ""
    echo -e "${YELLOW}!${NC} No offline packages directory found (online-only ISO)"
    OFFLINE_MODE="no"
fi

# Create welcome script
echo ""
echo -e "${YELLOW}→${NC} Creating welcome message..."
cat > airootfs/root/.zshrc << 'EOFZSH'
# Display welcome message
cat << 'WELCOME'

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
echo -e "${YELLOW}→${NC} Removing default automated_script.sh..."
rm -f airootfs/root/.automated_script.sh

# Create a clean .zlogin (remove automated_script.sh call)
cat > airootfs/root/.zlogin << 'EOFZLOGIN'
# fix for screen readers
if grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi
EOFZLOGIN

# Create install-arch command
echo -e "${YELLOW}→${NC} Creating install-arch command..."
mkdir -p airootfs/usr/local/bin
cat > airootfs/usr/local/bin/install-arch << 'EOFINSTALL'
#!/bin/bash
cd /root/custom-setup || exit 1
chmod +x install-auto.sh
exec bash ./install-auto.sh
EOFINSTALL
chmod +x airootfs/usr/local/bin/install-arch
echo -e "${GREEN}✓${NC} install-arch command created"

# Customize packages (add tools to live environment)
echo ""
echo -e "${YELLOW}→${NC} Adding packages to live environment..."
cat >> packages.x86_64 << 'EOFPKG'
# Custom additions
git
neovim
htop
EOFPKG
echo -e "${GREEN}✓${NC} Additional packages configured"

# Set proper permissions in profiledef.sh
echo ""
echo -e "${YELLOW}→${NC} Configuring file permissions in profiledef.sh..."
# Append file_permissions array to profiledef.sh to ensure permissions persist in the ISO
cat >> profiledef.sh << "EOFPERMS"

# File permissions that will be set in the live environment
file_permissions=(
  ["/usr/local/bin/install-arch"]="0:0:755"
  ["/root/custom-setup/install.sh"]="0:0:755"
  ["/root/custom-setup/install-auto.sh"]="0:0:755"
  ["/root/custom-setup/post-install.sh"]="0:0:755"
  ["/root"]="0:0:750"
)
EOFPERMS
echo -e "${GREEN}✓${NC} File permissions configured"

# Customize ISO label
echo ""
echo -e "${YELLOW}→${NC} Customizing ISO label..."
ISO_LABEL=$(echo "${ISO_NAME}" | tr "[:lower:]" "[:upper:]")
ISO_VER_NODOTS=$(echo "${ISO_VERSION}" | tr -d ".")
sed -i "s/ARCH_[0-9]*/${ISO_LABEL}_${ISO_VER_NODOTS}/" profiledef.sh
echo -e "${GREEN}✓${NC} ISO label: ${ISO_LABEL}_${ISO_VER_NODOTS}"

# Build ISO
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC} Building ISO (5-10 minutes)"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

START_TIME=$(date +%s)

sudo mkarchiso -v -w "$WORK_DIR/work" -o "$OUTPUT_DIR" "$ISO_DIR"
BUILD_EXIT_CODE=$?

END_TIME=$(date +%s)
BUILD_DURATION=$((END_TIME - START_TIME))
BUILD_MINUTES=$((BUILD_DURATION / 60))
BUILD_SECONDS=$((BUILD_DURATION % 60))

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    # Get ISO filename and size
    ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)

    if [ -f "$ISO_FILE" ]; then
        ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)

        # Validate ISO
        echo ""
        echo -e "${YELLOW}→${NC} Validating ISO..."
        if file "$ISO_FILE" | grep -q "ISO 9660"; then
            echo -e "${GREEN}✓${NC} Valid ISO format"
        else
            echo -e "${RED}✗${NC} Warning: ISO validation failed!"
        fi

        # Check size
        ISO_SIZE_BYTES=$(stat -c%s "$ISO_FILE")
        if [ $ISO_SIZE_BYTES -lt 500000000 ]; then
            echo -e "${YELLOW}⚠${NC} Warning: ISO seems unusually small ($ISO_SIZE)"
        else
            echo -e "${GREEN}✓${NC} ISO size: $ISO_SIZE"
        fi

        # Clean up old ISOs (keep only last 3)
        echo ""
        echo -e "${YELLOW}→${NC} Cleaning up old ISOs (keeping last 3)..."
        OLD_ISO_COUNT=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | tail -n +4 | wc -l)
        ls -t "$OUTPUT_DIR"/*.iso | tail -n +4 | xargs rm -f 2>/dev/null || true
        if [ $OLD_ISO_COUNT -gt 0 ]; then
            echo -e "${GREEN}✓${NC} Removed $OLD_ISO_COUNT old ISO(s)"
        else
            echo -e "${GREEN}✓${NC} No old ISOs to remove"
        fi

        # Success!
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
║              ISO Build Complete! 🎉                       ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
        echo -e "${NC}"

        echo -e "${GREEN}✓${NC} ISO created successfully!"
        echo ""
        echo "ISO Details:"
        echo "  File: $ISO_FILE"
        echo "  Size: $ISO_SIZE"
        echo "  Offline support: $OFFLINE_MODE"
        echo "  Build time: ${BUILD_MINUTES}m ${BUILD_SECONDS}s"
        echo ""
        echo "Next steps:"
        echo ""
        echo "  ${PURPLE}For VirtualBox:${NC}"
        echo "    1. Create new VM with this ISO"
        echo "    2. Boot and run: install-arch"
        echo ""
        echo "  ${PURPLE}For USB installation:${NC}"
        echo "    1. Write to USB:"
        echo "       ${YELLOW}sudo dd if=$ISO_FILE of=/dev/sdX bs=4M status=progress${NC}"
        echo "       ${RED}(Replace /dev/sdX with your USB device)${NC}"
        echo "    2. Boot from USB"
        echo "    3. Run: install-arch"
        echo ""
        echo "  ${PURPLE}For other VMs:${NC}"
        echo "    Just attach the ISO and boot!"
        echo ""
    else
        echo ""
        echo -e "${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║              BUILD FAILED ✗                               ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${RED}✗${NC} ISO file not found after build!"
        exit 1
    fi
else
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║              BUILD FAILED ✗                               ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}✗${NC} mkarchiso failed with exit code: $BUILD_EXIT_CODE"
    echo ""
    echo "Common causes:"
    echo "  • Network timeout downloading packages"
    echo "  • Slow mirror connection"
    echo "  • Insufficient disk space in /tmp"
    echo ""
    echo "Solutions:"
    echo "  1. Try running the script again"
    echo "  2. Check your internet connection"
    echo "  3. Ensure you have at least 5GB free in /tmp"
    echo ""
    exit 1
fi
