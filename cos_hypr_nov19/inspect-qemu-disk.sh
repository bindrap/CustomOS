#!/bin/bash

# QEMU Debug and Recovery Tool
# Helps debug installation issues and mount existing disks

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISK_DIR="$SCRIPT_DIR/qemu-disks"
DISK_FILE="$DISK_DIR/hyprland-test.qcow2"

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║  QEMU Disk Inspector                           ║
║  Debug Installation Issues                     ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if disk exists
if [ ! -f "$DISK_FILE" ]; then
    echo -e "${RED}✗${NC} No virtual disk found at: $DISK_FILE"
    exit 1
fi

echo -e "${GREEN}✓${NC} Found virtual disk: $(basename "$DISK_FILE")"
DISK_SIZE=$(du -h "$DISK_FILE" | cut -f1)
echo "  Size: $DISK_SIZE"
echo ""

# Check if qemu-nbd is available
if ! command -v qemu-nbd &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} qemu-nbd not found - cannot mount disk for inspection"
    echo ""
    echo "Install qemu-nbd:"
    echo "  Arch: sudo pacman -S qemu-tools"
    echo "  Ubuntu/Debian: sudo apt install qemu-utils"
    echo ""
    exit 1
fi

echo -e "${YELLOW}This will mount the virtual disk to inspect its contents${NC}"
echo ""
echo "You can check:"
echo "  • If bootloader is installed"
echo "  • If partitions are formatted"
echo "  • Boot configuration files"
echo ""
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    exit 0
fi

# Load nbd module
echo -e "${YELLOW}→${NC} Loading NBD kernel module..."
sudo modprobe nbd max_part=8

# Connect disk to nbd device
echo -e "${YELLOW}→${NC} Connecting disk to /dev/nbd0..."
sudo qemu-nbd --connect=/dev/nbd0 "$DISK_FILE"

# Wait for device
sleep 2

# Show partitions
echo -e "${GREEN}✓${NC} Disk connected"
echo ""
echo -e "${YELLOW}Partitions:${NC}"
sudo fdisk -l /dev/nbd0
echo ""

# Try to mount and inspect
MOUNT_DIR="/tmp/qemu-disk-inspect"
sudo mkdir -p "$MOUNT_DIR"

echo -e "${YELLOW}→${NC} Attempting to mount root partition..."
# New partition layout: p1=BIOS boot, p2=EFI/boot, p3=swap, p4=root
if sudo mount /dev/nbd0p4 "$MOUNT_DIR" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Root partition mounted at $MOUNT_DIR"
    echo ""

    # Check if boot partition is separate (partition 2 is EFI/boot)
    if sudo mount /dev/nbd0p2 "$MOUNT_DIR/boot" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Boot partition mounted"
    fi

    # Check bootloader
    echo ""
    echo -e "${YELLOW}Checking bootloader installation:${NC}"
    if [ -d "$MOUNT_DIR/boot/loader" ]; then
        echo -e "${GREEN}✓${NC} Bootloader directory exists"

        echo ""
        echo "Boot entries:"
        sudo ls -la "$MOUNT_DIR/boot/loader/entries/" 2>/dev/null || echo "  No boot entries found!"

        echo ""
        echo "Loader config:"
        sudo cat "$MOUNT_DIR/boot/loader/loader.conf" 2>/dev/null || echo "  No loader config found!"

        echo ""
        echo "Boot files:"
        sudo ls -la "$MOUNT_DIR/boot/" | grep -E "(vmlinuz|initramfs)"
    else
        echo -e "${RED}✗${NC} Bootloader NOT installed!"
        echo ""
        echo "This is why the system won't boot."
        echo "The installation didn't complete the bootloader step."
    fi

    # Unmount
    echo ""
    echo -e "${YELLOW}→${NC} Unmounting..."
    sudo umount "$MOUNT_DIR/boot" 2>/dev/null || true
    sudo umount "$MOUNT_DIR"
else
    echo -e "${RED}✗${NC} Could not mount root partition"
    echo "The disk may not be properly formatted"
fi

# Disconnect
echo -e "${YELLOW}→${NC} Disconnecting disk..."
sudo qemu-nbd --disconnect /dev/nbd0
sudo rmdir "$MOUNT_DIR" 2>/dev/null || true

echo ""
echo -e "${GREEN}✓${NC} Inspection complete"
echo ""
echo -e "${YELLOW}If bootloader is missing:${NC}"
echo "  1. Delete the disk: bash cleanup-qemu.sh"
echo "  2. Reinstall: bash test-iso-qemu-install.sh"
echo "  3. Make sure 'install-arch' completes fully"
echo "  4. Wait for 'Installation complete!' message"
