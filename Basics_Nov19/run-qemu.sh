#!/bin/bash
# QEMU launcher for Arch Linux ISO
# This script runs the ISO in QEMU with VirtIO and KVM acceleration
# Usage: ./run-qemu.sh [path-to-iso]

set -e

# Default ISO path if none provided
DEFAULT_ISO="iso-output/archlinux-2025.11.18-x86_64.iso"
ISO_PATH="${1:-$DEFAULT_ISO}"

if [ ! -f "$ISO_PATH" ]; then
    echo "Error: ISO not found at $ISO_PATH"
    echo "Usage: $0 [path-to-iso]"
    echo "Example: $0 iso-output/archlinux-2025.11.18-x86_64.iso"
    exit 1
fi

echo "Starting QEMU with ISO: $ISO_PATH"
echo "Press Ctrl+Alt+G to release mouse/keyboard from QEMU window"
echo "Press Ctrl+Alt+F to toggle fullscreen"
echo ""

# Run QEMU with:
# - 4GB RAM
# - 4 CPU cores
# - KVM acceleration (if available)
# - VirtIO graphics
# - UEFI boot (OVMF)
# - Sound support
# - USB tablet for better mouse support

qemu-system-x86_64 \
    -cdrom "$ISO_PATH" \
    -m 4G \
    -smp 4 \
    -enable-kvm \
    -cpu host \
    -vga virtio \
    -display sdl,gl=on \
    -device intel-hda \
    -device hda-duplex \
    -usb \
    -device usb-tablet \
    -boot d \
    -name "Arch Linux Live ISO"
