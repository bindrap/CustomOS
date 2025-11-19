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

# Find UEFI firmware (optional, improves compatibility)
OVMF_CODE=""
for code_path in \
    "/usr/share/OVMF/OVMF_CODE.fd" \
    "/usr/share/ovmf/OVMF.fd" \
    "/usr/share/ovmf/x64/OVMF_CODE.fd" \
    "/usr/share/edk2-ovmf/x64/OVMF_CODE.fd" \
    "/usr/share/qemu/ovmf-x86_64-code.bin"; do
    if [ -f "$code_path" ]; then
        OVMF_CODE="$code_path"
        break
    fi
done

OVMF_VARS=""
if [ -n "$OVMF_CODE" ]; then
    OVMF_VARS="$DISK_DIR/OVMF_VARS.fd"
    if [ -f "$OVMF_VARS" ]; then
        echo "✓ Using UEFI firmware"
    else
        echo "⚠ UEFI firmware found but variables missing (using BIOS)"
        OVMF_CODE=""
    fi
else
    echo "⚠ Using BIOS mode (UEFI firmware not found)"
fi

echo ""

# Build QEMU command
QEMU_ARGS=()

# Add KVM
if [ -n "$KVM_ARGS" ]; then
    QEMU_ARGS+=($KVM_ARGS)
fi

# Add resources
QEMU_ARGS+=(-m 4G -smp 4)

# Add UEFI if available
if [ -n "$OVMF_CODE" ] && [ -n "$OVMF_VARS" ]; then
    QEMU_ARGS+=(
        -drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE"
        -drive "if=pflash,format=raw,file=$OVMF_VARS"
    )
fi

# Add disk and devices
QEMU_ARGS+=(
    -drive "file=$DISK_FILE,format=qcow2,if=virtio"
    -vga virtio -display sdl,gl=on
    -netdev user,id=net0 -device virtio-net-pci,netdev=net0
    -name "Hyprland - Installed System"
    -boot c
)

# Boot the installed system
exec qemu-system-x86_64 "${QEMU_ARGS[@]}"
