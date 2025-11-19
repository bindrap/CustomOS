#!/bin/bash

# QEMU Full Installation Test Script
# Creates a virtual disk and tests full installation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_DIR="$SCRIPT_DIR/iso-output"
DISK_DIR="$SCRIPT_DIR/qemu-disks"
DISK_FILE="$DISK_DIR/hyprland-test.qcow2"
DISK_SIZE="50G"

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║  QEMU Installation Tester                      ║
║  Test Full Installation to Virtual Disk        ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if QEMU is installed
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo -e "${RED}✗${NC} QEMU not found!"
    exit 1
fi

if ! command -v qemu-img &> /dev/null; then
    echo -e "${RED}✗${NC} qemu-img not found!"
    exit 1
fi

echo -e "${GREEN}✓${NC} QEMU found: $(qemu-system-x86_64 --version | head -1)"

# Find the ISO file
ISO_FILE=$(ls -t "$ISO_DIR"/*.iso 2>/dev/null | head -1)

if [ -z "$ISO_FILE" ]; then
    echo -e "${RED}✗${NC} No ISO file found in $ISO_DIR"
    exit 1
fi

ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
echo -e "${GREEN}✓${NC} Found ISO: $(basename "$ISO_FILE") ($ISO_SIZE)"

# Check if disk already exists
mkdir -p "$DISK_DIR"

if [ -f "$DISK_FILE" ]; then
    echo -e "${YELLOW}⚠${NC} Virtual disk already exists: $DISK_FILE"
    DISK_EXISTS=$(du -h "$DISK_FILE" | cut -f1)
    echo "  Size: $DISK_EXISTS"
    echo ""
    echo "Options:"
    echo "  1. Use existing disk (boot installed system)"
    echo "  2. Delete and create new disk (fresh install)"
    echo "  3. Delete disk and exit (cleanup)"
    echo "  4. Cancel"
    echo ""
    read -p "Choice (1/2/3/4): " CHOICE

    case $CHOICE in
        1)
            echo -e "${GREEN}→${NC} Using existing disk"
            BOOT_MODE="disk"
            ;;
        2)
            echo -e "${YELLOW}→${NC} Deleting old disk..."
            rm -f "$DISK_FILE"
            BOOT_MODE="cdrom"
            ;;
        3)
            echo -e "${YELLOW}→${NC} Deleting disk..."
            rm -f "$DISK_FILE"
            echo -e "${GREEN}✓${NC} Disk deleted"

            # Check if directory is empty and remove it
            if [ -z "$(ls -A "$DISK_DIR" 2>/dev/null)" ]; then
                rm -rf "$DISK_DIR"
                echo -e "${GREEN}✓${NC} Disk directory removed"
            fi

            echo ""
            echo "Use ${BLUE}bash cleanup-qemu.sh${NC} to delete all virtual disks"
            exit 0
            ;;
        *)
            exit 0
            ;;
    esac
else
    BOOT_MODE="cdrom"
fi

# Create new disk if needed
if [ "$BOOT_MODE" = "cdrom" ]; then
    echo ""
    echo -e "${YELLOW}→${NC} Creating virtual disk ($DISK_SIZE)..."
    qemu-img create -f qcow2 "$DISK_FILE" "$DISK_SIZE"
    echo -e "${GREEN}✓${NC} Virtual disk created"
fi

# Check KVM support
KVM_AVAILABLE=0
if [ -e /dev/kvm ]; then
    if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
        KVM_AVAILABLE=1
        echo -e "${GREEN}✓${NC} KVM acceleration available"
    else
        echo -e "${YELLOW}⚠${NC} KVM device exists but not accessible"
    fi
else
    echo -e "${YELLOW}⚠${NC} KVM not available (will be slower)"
fi

echo ""
echo -e "${YELLOW}QEMU Configuration:${NC}"
echo "  Memory: 4GB"
echo "  CPUs: 2 cores"
echo "  Disk: $DISK_SIZE (qcow2)"
echo "  Graphics: virtio-gpu (hardware acceleration)"
echo "  Display: SDL with OpenGL"
echo "  KVM: $([ $KVM_AVAILABLE -eq 1 ] && echo 'Enabled' || echo 'Disabled')"
echo "  Boot: $([ "$BOOT_MODE" = "cdrom" ] && echo 'CD-ROM (install mode)' || echo 'Disk (installed system)')"
echo ""

if [ "$BOOT_MODE" = "cdrom" ]; then
    echo -e "${CYAN}Installation Steps:${NC}"
    echo "  1. QEMU will boot from ISO"
    echo "  2. Run: install-arch"
    echo "  3. Follow installation prompts"
    echo "  4. After install completes, close QEMU"
    echo "  5. Run this script again to boot installed system"
    echo ""
fi

# Ask for confirmation
read -p "Start QEMU? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    exit 0
fi

echo ""
echo -e "${BLUE}Starting QEMU...${NC}"
echo -e "${YELLOW}Tip: Press Ctrl+Alt+G to release mouse/keyboard${NC}"
echo ""

# Build QEMU command
QEMU_CMD="qemu-system-x86_64"
QEMU_ARGS=(
    -m 4G
    -smp 2
    -drive "file=$DISK_FILE,format=qcow2,if=virtio"
    -vga virtio
    -display sdl,gl=on
    -netdev user,id=net0
    -device virtio-net-pci,netdev=net0
)

# Add CD-ROM if installing
if [ "$BOOT_MODE" = "cdrom" ]; then
    QEMU_ARGS+=(-cdrom "$ISO_FILE" -boot d)
fi

# Add KVM if available
if [ $KVM_AVAILABLE -eq 1 ]; then
    QEMU_ARGS=(-enable-kvm "${QEMU_ARGS[@]}")
fi

# Run QEMU
echo -e "${GREEN}Running:${NC} $QEMU_CMD"
echo ""

exec $QEMU_CMD "${QEMU_ARGS[@]}"
