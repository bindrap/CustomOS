#!/bin/bash
# Test dual boot setup with QEMU
# This script creates a scenario where you can test installing your OS alongside an existing system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_FILE="$SCRIPT_DIR/iso-output/pbos-hyprland-2025.12.02-x86_64.iso"
EXISTING_DISK="$SCRIPT_DIR/qemu-disks/customos-nov21.qcow2"
NEW_DISK="$SCRIPT_DIR/qemu-disks/dualboot-test.qcow2"
DISK_SIZE="20G"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== PBOS Dual Boot Test Setup ===${NC}\n"

# Check if ISO exists
if [ ! -f "$ISO_FILE" ]; then
    echo -e "${YELLOW}Error: ISO file not found at $ISO_FILE${NC}"
    exit 1
fi

# Check if existing disk exists
if [ ! -f "$EXISTING_DISK" ]; then
    echo -e "${YELLOW}Error: Existing disk not found at $EXISTING_DISK${NC}"
    exit 1
fi

# Create new disk if it doesn't exist
if [ ! -f "$NEW_DISK" ]; then
    echo -e "${GREEN}Creating new virtual disk for dual boot test (${DISK_SIZE})...${NC}"
    qemu-img create -f qcow2 "$NEW_DISK" "$DISK_SIZE"
    echo -e "${GREEN}Disk created successfully!${NC}\n"
else
    echo -e "${YELLOW}Using existing dual boot test disk${NC}\n"
fi

echo -e "${BLUE}Boot Options:${NC}"
echo "1) Boot from ISO (Fresh install - test dual boot partitioning)"
echo "2) Boot from existing disk (customos-nov21.qcow2)"
echo "3) Boot from new disk (dualboot-test.qcow2 - if already installed)"
echo "4) Delete test disk and exit"
echo ""
read -p "Select boot option (1-4): " BOOT_OPTION

case $BOOT_OPTION in
    1)
        echo -e "\n${GREEN}Booting from ISO with both disks attached...${NC}"
        echo -e "${YELLOW}You can now test installing to the second disk or setting up dual boot${NC}\n"
        qemu-system-x86_64 \
            -enable-kvm \
            -m 4096 \
            -smp 4 \
            -cpu host \
            -cdrom "$ISO_FILE" \
            -drive file="$EXISTING_DISK",format=qcow2,if=virtio \
            -drive file="$NEW_DISK",format=qcow2,if=virtio \
            -boot d \
            -vga virtio \
            -display sdl,gl=on \
            -net nic,model=virtio \
            -net user
        ;;
    2)
        echo -e "\n${GREEN}Booting from existing disk (customos-nov21.qcow2)...${NC}\n"
        qemu-system-x86_64 \
            -enable-kvm \
            -m 4096 \
            -smp 4 \
            -cpu host \
            -drive file="$EXISTING_DISK",format=qcow2,if=virtio \
            -drive file="$NEW_DISK",format=qcow2,if=virtio \
            -boot c \
            -vga virtio \
            -display sdl,gl=on \
            -net nic,model=virtio \
            -net user
        ;;
    3)
        echo -e "\n${GREEN}Booting from new disk (dualboot-test.qcow2)...${NC}\n"
        qemu-system-x86_64 \
            -enable-kvm \
            -m 4096 \
            -smp 4 \
            -cpu host \
            -drive file="$NEW_DISK",format=qcow2,if=virtio \
            -drive file="$EXISTING_DISK",format=qcow2,if=virtio \
            -boot c \
            -vga virtio \
            -display sdl,gl=on \
            -net nic,model=virtio \
            -net user
        ;;
    4)
        if [ -f "$NEW_DISK" ]; then
            echo -e "\n${YELLOW}Deleting test disk...${NC}"
            rm "$NEW_DISK"
            echo -e "${GREEN}Test disk deleted successfully!${NC}"
        else
            echo -e "${YELLOW}No test disk to delete${NC}"
        fi
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Invalid option${NC}"
        exit 1
        ;;
esac
