#!/bin/bash

# Manual QEMU Boot - Direct commands for troubleshooting
# Run this to boot your installed system

set -e

DISK_DIR="$(pwd)/qemu-disks"
DISK_FILE="$DISK_DIR/hyprland-test.qcow2"

echo "╔════════════════════════════════════════════════╗"
echo "║  Manual QEMU Boot - Troubleshooting Mode      ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

if [ ! -f "$DISK_FILE" ]; then
    echo "✗ Disk not found: $DISK_FILE"
    echo "Run test-iso-qemu-install.sh first to create a disk"
    exit 1
fi

echo "Disk found: $DISK_FILE"
echo "Size: $(du -h "$DISK_FILE" | cut -f1)"
echo ""
echo "Boot modes available:"
echo "  1. Boot installed system (no ISO)"
echo "  2. Boot with ISO attached (for rescue/reinstall)"
echo "  3. Show manual commands"
echo ""
read -p "Choice (1/2/3): " CHOICE

case $CHOICE in
    1)
        echo ""
        echo "Booting installed system..."
        echo "Command:"
        echo "qemu-system-x86_64 -enable-kvm -m 4G -smp 4 \\"
        echo "  -drive file=$DISK_FILE,format=qcow2,if=virtio \\"
        echo "  -vga virtio -display sdl,gl=on \\"
        echo "  -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \\"
        echo "  -boot c"
        echo ""
        
        exec qemu-system-x86_64 -enable-kvm -m 4G -smp 4 \
            -drive "file=$DISK_FILE,format=qcow2,if=virtio" \
            -vga virtio -display sdl,gl=on \
            -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
            -boot c
        ;;
    2)
        ISO_FILE=$(ls -t iso-output/*.iso 2>/dev/null | head -1)
        if [ -z "$ISO_FILE" ]; then
            echo "✗ No ISO found"
            exit 1
        fi
        
        echo ""
        echo "Booting with ISO attached (rescue mode)..."
        echo "Command:"
        echo "qemu-system-x86_64 -enable-kvm -m 4G -smp 4 \\"
        echo "  -drive file=$DISK_FILE,format=qcow2,if=virtio \\"
        echo "  -cdrom $ISO_FILE \\"
        echo "  -vga virtio -display sdl,gl=on \\"
        echo "  -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \\"
        echo "  -boot menu=on"
        echo ""
        echo "Press ESC during boot to select boot device"
        echo ""
        
        exec qemu-system-x86_64 -enable-kvm -m 4G -smp 4 \
            -drive "file=$DISK_FILE,format=qcow2,if=virtio" \
            -cdrom "$ISO_FILE" \
            -vga virtio -display sdl,gl=on \
            -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
            -boot menu=on
        ;;
    3)
        cat << 'COMMANDS'

═══════════════════════════════════════════════════════
Manual Troubleshooting Commands
═══════════════════════════════════════════════════════

1. INSPECT THE DISK (mount and check bootloader):

sudo modprobe nbd max_part=8
sudo qemu-nbd --connect=/dev/nbd0 "$DISK_FILE"
sudo fdisk -l /dev/nbd0

# Mount root partition
sudo mkdir -p /tmp/disk-inspect
sudo mount /dev/nbd0p3 /tmp/disk-inspect
sudo mount /dev/nbd0p1 /tmp/disk-inspect/boot

# Check bootloader
sudo ls -la /tmp/disk-inspect/boot/loader/entries/
sudo cat /tmp/disk-inspect/boot/loader/loader.conf

# Check if kernel exists
sudo ls -la /tmp/disk-inspect/boot/vmlinuz-linux

# Unmount when done
sudo umount /tmp/disk-inspect/boot
sudo umount /tmp/disk-inspect
sudo qemu-nbd --disconnect /dev/nbd0

───────────────────────────────────────────────────────

2. BOOT INTO QEMU AND FIX BOOTLOADER FROM INSIDE:

# Boot with ISO attached
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 \
  -drive file="$DISK_FILE",format=qcow2,if=virtio \
  -cdrom iso-output/*.iso \
  -vga virtio -display sdl,gl=on \
  -boot menu=on

# Inside QEMU, press ESC to get boot menu
# Boot from CD-ROM
# Once in live environment:

# Mount the installed system
mount /dev/vda3 /mnt
mount /dev/vda1 /mnt/boot

# Chroot into installed system
arch-chroot /mnt

# Reinstall bootloader
bootctl install
bootctl update

# Verify boot entries
ls -la /boot/loader/entries/
cat /boot/loader/loader.conf

# Exit and reboot
exit
reboot

───────────────────────────────────────────────────────

3. SIMPLE BOOT TEST (just boot the disk):

qemu-system-x86_64 -enable-kvm -m 4G -smp 4 \
  -drive file="qemu-disks/hyprland-test.qcow2",format=qcow2 \
  -vga virtio -display sdl,gl=on \
  -boot c

───────────────────────────────────────────────────────

COMMANDS
        ;;
    *)
        echo "Cancelled"
        exit 0
        ;;
esac
