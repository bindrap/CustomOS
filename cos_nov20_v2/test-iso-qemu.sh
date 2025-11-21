#!/bin/bash

# QEMU Test Script for Hyprland ISO
# Tests the built ISO in QEMU with proper GPU acceleration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_DIR="$SCRIPT_DIR/iso-output"

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║  QEMU ISO Tester                               ║
║  Test Hyprland ISO with Hardware Acceleration  ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if QEMU is installed
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo -e "${RED}✗${NC} QEMU not found!"
    echo ""
    echo "Install QEMU:"
    echo "  Ubuntu/Debian: sudo apt install qemu-system-x86"
    echo "  Arch: sudo pacman -S qemu-full"
    echo "  macOS: brew install qemu"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓${NC} QEMU found: $(qemu-system-x86_64 --version | head -1)"

# Find the ISO file
ISO_FILE=$(ls -t "$ISO_DIR"/*.iso 2>/dev/null | head -1)

if [ -z "$ISO_FILE" ]; then
    echo -e "${RED}✗${NC} No ISO file found in $ISO_DIR"
    echo ""
    echo "Build an ISO first:"
    echo "  bash build-hyprland-iso-clean.sh"
    echo ""
    exit 1
fi

ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
echo -e "${GREEN}✓${NC} Found ISO: $(basename "$ISO_FILE") ($ISO_SIZE)"

# Check KVM support
KVM_AVAILABLE=0
if [ -e /dev/kvm ]; then
    if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
        KVM_AVAILABLE=1
        echo -e "${GREEN}✓${NC} KVM acceleration available"
    else
        echo -e "${YELLOW}⚠${NC} KVM device exists but not accessible"
        echo "  Run: sudo chmod 666 /dev/kvm"
    fi
else
    echo -e "${YELLOW}⚠${NC} KVM not available (will be slower)"
fi

echo ""
echo -e "${YELLOW}QEMU Configuration:${NC}"
echo "  Memory: 4GB"
echo "  CPUs: 4 cores"
echo "  Graphics: virtio-gpu (hardware acceleration)"
echo "  Display: SDL with OpenGL"
echo "  KVM: $([ $KVM_AVAILABLE -eq 1 ] && echo 'Enabled' || echo 'Disabled')"
echo ""

# Ask for confirmation
read -p "Start QEMU? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    exit 0
fi

echo ""
echo -e "${BLUE}Starting QEMU...${NC}"
echo -e "${YELLOW}Tip: Press Ctrl+Alt+G to release mouse/keyboard${NC}"
echo ""

# Find UEFI firmware (optional for live ISO boot)
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

USE_UEFI=0
if [ -n "$OVMF_CODE" ]; then
    echo -e "${GREEN}✓${NC} UEFI firmware found"
    USE_UEFI=1
else
    echo -e "${YELLOW}⚠${NC} UEFI firmware not found - using BIOS mode"
    echo "  For UEFI support, install: sudo apt install ovmf"
fi

# Build QEMU command
QEMU_CMD="qemu-system-x86_64"
QEMU_ARGS=(
    -m 4G
    -smp 4
)

# Add UEFI if available (read-only, no vars needed for live boot)
if [ $USE_UEFI -eq 1 ]; then
    QEMU_ARGS+=(-drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE")
fi

# Add CD-ROM and devices
QEMU_ARGS+=(
    -cdrom "$ISO_FILE"
    -boot d
    -vga virtio
    -display sdl,gl=on
    -name "Hyprland ISO - Quick Test"
)

# Add KVM if available
if [ $KVM_AVAILABLE -eq 1 ]; then
    QEMU_ARGS=(-enable-kvm "${QEMU_ARGS[@]}")
fi

# Run QEMU
echo -e "${GREEN}Running:${NC} $QEMU_CMD ${QEMU_ARGS[*]}"
echo ""

exec $QEMU_CMD "${QEMU_ARGS[@]}"
