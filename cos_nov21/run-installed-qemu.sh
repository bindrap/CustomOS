#!/bin/bash

# Quick Boot Script - Boot Installed System
# Enhanced with file sharing capabilities

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISK_DIR="$SCRIPT_DIR/qemu-disks"
DISK_FILE="$DISK_DIR/customos-nov21.qcow2"
SHARED_DIR="$SCRIPT_DIR/vm-shared"

echo "=================================================="
echo "  Boot Installed CustomOS Nov21 System"
echo "  With SSH (port 2222) & Shared Folder"
echo "=================================================="
echo ""

if [ ! -f "$DISK_FILE" ]; then
    echo "✗ No installed system found!"
    echo ""
    echo "Run installation first:"
    echo "  bash test-iso-qemu-install.sh"
    echo ""
    exit 1
fi

# Create shared directory
mkdir -p "$SHARED_DIR"
echo "✓ Shared folder: $SHARED_DIR"

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
echo "=================================================="
echo "  File Sharing Enabled:"
echo ""
echo "  SSH:     ssh -p 2222 user@localhost"
echo "  SCP:     scp -P 2222 file user@localhost:~"
echo ""
echo "  Shared Folder (in VM):"
echo "    sudo mount -t 9p -o trans=virtio shared /mnt"
echo "    # Files in $SHARED_DIR"
echo "=================================================="
echo ""

# Build QEMU command
QEMU_ARGS=()

# Add KVM
if [ -n "$KVM_ARGS" ]; then
    QEMU_ARGS+=($KVM_ARGS)
fi

# Add resources (8GB for HyDE/Hyprland performance)
QEMU_ARGS+=(-m 8G -smp 4)

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
    # QXL graphics for better compatibility with CachyOS kernel and Hyprland
    -device qxl-vga,vgamem_mb=256 -display gtk,gl=on
    -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=net0
    -virtfs local,path="$SHARED_DIR",mount_tag=shared,security_model=passthrough,id=shared0
    -name "CustomOS Nov21 - Installed System"
    -boot c
)

# Boot the installed system
exec qemu-system-x86_64 "${QEMU_ARGS[@]}"
