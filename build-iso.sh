#!/bin/bash

# Custom Arch Linux ISO Builder
# Creates bootable ISO with automated installation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ISO_NAME="parteek-arch"
ISO_VERSION=$(date +%Y.%m.%d)
WORK_DIR="$HOME/archiso-work"
ISO_DIR="$WORK_DIR/iso-build"
OUTPUT_DIR="$HOME/iso-output"

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
║           Custom Arch Linux ISO Builder                   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${YELLOW}This script will create a custom Arch Linux ISO${NC}"
echo "Output: $OUTPUT_DIR/${ISO_NAME}-${ISO_VERSION}.iso"
echo ""
read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    exit 0
fi

# Check dependencies
echo ""
echo -e "${BLUE}Checking dependencies...${NC}"
if ! command -v archiso &> /dev/null; then
    echo -e "${YELLOW}→${NC} Installing archiso..."
    sudo pacman -S --needed --noconfirm archiso
fi

# Clean up old work
if [ -d "$WORK_DIR" ]; then
    echo -e "${YELLOW}→${NC} Cleaning up old work directory..."
    sudo rm -rf "$WORK_DIR"
fi

# Create directories
echo -e "${YELLOW}→${NC} Creating work directories..."
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

# Copy archiso profile
echo -e "${YELLOW}→${NC} Copying archiso profile..."
cp -r /usr/share/archiso/configs/releng "$ISO_DIR"
cd "$ISO_DIR"

# Create custom setup directory in ISO
echo -e "${YELLOW}→${NC} Creating custom setup directory..."
mkdir -p airootfs/root/custom-setup

# Copy our custom setup
echo -e "${YELLOW}→${NC} Copying custom setup files..."
if [ -d "$HOME/custom-arch-setup" ]; then
    cp -r "$HOME/custom-arch-setup"/* airootfs/root/custom-setup/
else
    echo -e "${RED}✗${NC} Custom setup not found!"
    echo "Please run package-creator.sh first"
    exit 1
fi

# Copy install scripts
echo -e "${YELLOW}→${NC} Copying installation scripts..."
cp "$HOME/install.sh" airootfs/root/custom-setup/ 2>/dev/null || true
cp "$HOME/install-auto.sh" airootfs/root/custom-setup/ 2>/dev/null || true
chmod +x airootfs/root/custom-setup/*.sh

# Copy offline packages if they exist
if [ -d "$HOME/offline-packages" ]; then
    echo -e "${YELLOW}→${NC} Copying offline package cache..."
    mkdir -p airootfs/root/custom-setup/packages
    cp "$HOME/offline-packages"/*.pkg.tar.zst airootfs/root/custom-setup/packages/ 2>/dev/null || true
    OFFLINE_MODE="yes"
else
    echo -e "${YELLOW}!${NC} No offline packages found (online-only ISO)"
    OFFLINE_MODE="no"
fi

# Create welcome script
echo -e "${YELLOW}→${NC} Creating welcome message..."
cat > airootfs/root/.zshrc << 'EOF'
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
EOF

# Create install-arch command (symlink to auto installer)
cat > airootfs/usr/local/bin/install-arch << 'EOF'
#!/bin/bash
cd /root/custom-setup
exec ./install-auto.sh
EOF
chmod +x airootfs/usr/local/bin/install-arch

# Customize packages (add a few tools to live environment)
echo -e "${YELLOW}→${NC} Adding packages to live environment..."
cat >> packages.x86_64 << 'EOF'
# Custom additions
git
neovim
htop
EOF

# Customize ISO label
sed -i "s/ARCH_.*/${ISO_NAME^^}_${ISO_VERSION//.}/" profiledef.sh

# Build ISO
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC} Building ISO (this may take 10-15 min)"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

sudo mkarchiso -v -w "$WORK_DIR/work" -o "$OUTPUT_DIR" "$ISO_DIR"

# Get ISO filename
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso | head -1)
ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)

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
echo ""
echo "Next steps:"
echo ""
echo "  1. Write to USB:"
echo "     sudo dd if=$ISO_FILE of=/dev/sdX bs=4M status=progress"
echo "     (Replace /dev/sdX with your USB device)"
echo ""
echo "  2. Boot from USB"
echo ""
echo "  3. Run: install-arch"
echo ""
echo "  4. Answer a few questions and wait 15-20 minutes"
echo ""
echo "  5. Reboot into your fully configured Arch Linux!"
echo ""
