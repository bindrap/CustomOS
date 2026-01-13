#!/bin/bash

# List QEMU Virtual Disks
# Show all virtual disks and their sizes

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISK_DIR="$SCRIPT_DIR/qemu-disks"

echo -e "${BLUE}QEMU Virtual Disks${NC}"
echo ""

# Check if disk directory exists
if [ ! -d "$DISK_DIR" ]; then
    echo -e "${GREEN}✓${NC} No virtual disks found"
    echo ""
    echo "Create a disk by running:"
    echo "  bash test-iso-qemu-install.sh"
    exit 0
fi

# Count disks
DISK_COUNT=$(find "$DISK_DIR" -name "*.qcow2" 2>/dev/null | wc -l)

if [ "$DISK_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No virtual disks found"
    exit 0
fi

echo -e "${YELLOW}Found $DISK_COUNT virtual disk(s):${NC}"
echo ""

TOTAL_SIZE=0
while IFS= read -r disk; do
    DISK_NAME=$(basename "$disk")
    DISK_SIZE=$(du -h "$disk" | cut -f1)
    DISK_SIZE_BYTES=$(du -b "$disk" | cut -f1)
    TOTAL_SIZE=$((TOTAL_SIZE + DISK_SIZE_BYTES))
    DISK_MODIFIED=$(stat -c %y "$disk" 2>/dev/null || stat -f %Sm "$disk" 2>/dev/null)

    echo "  📁 $DISK_NAME"
    echo "     Size: $DISK_SIZE"
    echo "     Modified: ${DISK_MODIFIED:0:19}"
    echo ""
done < <(find "$DISK_DIR" -name "*.qcow2" | sort)

TOTAL_SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B $TOTAL_SIZE 2>/dev/null || echo "$TOTAL_SIZE bytes")
echo -e "${YELLOW}Total: $TOTAL_SIZE_HUMAN${NC}"
echo ""
echo "To delete all disks:"
echo "  bash cleanup-qemu.sh"
