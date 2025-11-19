#!/bin/bash

# QEMU Cleanup Script
# Delete virtual disks and test artifacts

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISK_DIR="$SCRIPT_DIR/qemu-disks"

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║  QEMU Cleanup Tool                             ║
║  Delete Virtual Disks and Test Artifacts      ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if disk directory exists
if [ ! -d "$DISK_DIR" ]; then
    echo -e "${GREEN}✓${NC} No virtual disks found - nothing to clean up"
    exit 0
fi

# List existing disks and UEFI vars
DISK_COUNT=$(find "$DISK_DIR" -name "*.qcow2" 2>/dev/null | wc -l)
VARS_COUNT=$(find "$DISK_DIR" -name "OVMF_VARS.fd" 2>/dev/null | wc -l)

if [ "$DISK_COUNT" -eq 0 ] && [ "$VARS_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No virtual disks found"

    # Check if empty directory exists
    if [ -d "$DISK_DIR" ]; then
        echo -e "${YELLOW}→${NC} Removing empty disk directory..."
        rm -rf "$DISK_DIR"
        echo -e "${GREEN}✓${NC} Cleanup complete"
    fi
    exit 0
fi

echo -e "${YELLOW}Found files to delete:${NC}"
echo ""

TOTAL_SIZE=0
while IFS= read -r disk; do
    DISK_NAME=$(basename "$disk")
    DISK_SIZE=$(du -h "$disk" | cut -f1)
    DISK_SIZE_BYTES=$(du -b "$disk" | cut -f1)
    TOTAL_SIZE=$((TOTAL_SIZE + DISK_SIZE_BYTES))

    echo "  • $DISK_NAME ($DISK_SIZE)"
done < <(find "$DISK_DIR" -name "*.qcow2" -o -name "OVMF_VARS.fd")

TOTAL_SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B $TOTAL_SIZE)
echo ""
echo -e "${YELLOW}Total disk space used: $TOTAL_SIZE_HUMAN${NC}"
echo ""

echo "This will delete:"
echo "  - All virtual disk files (*.qcow2)"
echo "  - UEFI firmware variables (OVMF_VARS.fd)"
echo "  - The qemu-disks directory"
echo ""
echo -e "${RED}⚠ WARNING: This cannot be undone!${NC}"
echo ""

read -p "Delete all virtual disks? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}→${NC} Deleting virtual disks and UEFI variables..."

# Delete all qcow2 files and UEFI vars
find "$DISK_DIR" -name "*.qcow2" -delete
find "$DISK_DIR" -name "OVMF_VARS.fd" -delete

echo -e "${GREEN}✓${NC} Virtual disks and UEFI variables deleted"

# Remove directory
echo -e "${YELLOW}→${NC} Removing disk directory..."
rm -rf "$DISK_DIR"

echo -e "${GREEN}✓${NC} Cleanup complete!"
echo ""
echo "Freed up: $TOTAL_SIZE_HUMAN"
