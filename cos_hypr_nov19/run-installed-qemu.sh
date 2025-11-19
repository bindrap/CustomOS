#!/bin/bash

# Quick Boot Script - Boot Installed System
# Simple wrapper to boot the installed Hyprland system

set -e

DISK_DIR="$(pwd)/qemu-disks"
DISK_FILE="$DISK_DIR/hyprland-test.qcow2"

echo "╔════════════════════════════════════════════════╗"
echo "║  Boot Installed Hyprland System                ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

if [ ! -f "$DISK_FILE" ]; then
    echo "✗ No installed system found!"
    echo ""
    echo "Run installation first:"
    echo "  bash test-iso-qemu-install.sh"
    echo ""
    exit 1
fi

echo "✓ Found installed system: $(du -h "$DISK_FILE" | cut -f1)"
echo ""
echo "Starting QEMU..."
echo "Tip: Press Ctrl+Alt+G to release mouse/keyboard"
echo ""

# Check KVM
KVM_ARGS=""
if [ -e /dev/kvm ] && [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    KVM_ARGS="-enable-kvm"
    echo "✓ KVM acceleration enabled"
else
    echo "⚠ KVM not available (slower performance)"
    echo "  Fix: sudo chmod 666 /dev/kvm"
fi

echo ""

# Boot the installed system
exec qemu-system-x86_64 $KVM_ARGS -m 4G -smp 4 \
    -drive "file=$DISK_FILE,format=qcow2,if=virtio" \
    -vga virtio -display sdl,gl=on \
    -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
    -name "Hyprland - Installed System" \
    -boot c
