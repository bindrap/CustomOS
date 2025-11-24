#!/bin/bash

# SAFE Disk Partitioning Helper for CustomOS Dual Boot
# Conservative approach to avoid data corruption

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║       SAFE Disk Partitioning Helper for CustomOS         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}✗${NC} This script must be run as root"
   exit 1
fi

# Check required tools
MISSING_TOOLS=""
for tool in parted lsblk blkid e2fsck resize2fs mkfs.ext4; do
    if ! command -v $tool &> /dev/null; then
        MISSING_TOOLS="$MISSING_TOOLS $tool"
    fi
done

if [ -n "$MISSING_TOOLS" ]; then
    echo -e "${RED}✗${NC} Missing required tools:$MISSING_TOOLS"
    echo "Please install: pacman -S parted e2fsprogs"
    exit 1
fi

echo -e "${YELLOW}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}│  IMPORTANT SAFETY WARNINGS - READ CAREFULLY           │${NC}"
echo -e "${YELLOW}│                                                        │${NC}"
echo -e "${YELLOW}│  • This script will modify disk partitions            │${NC}"
echo -e "${YELLOW}│  • BACKUP YOUR DATA before proceeding                 │${NC}"
echo -e "${YELLOW}│  • Wrong partition can destroy your system            │${NC}"
echo -e "${YELLOW}│  • Use this ONLY if you know what you're doing        │${NC}"
echo -e "${YELLOW}│                                                        │${NC}"
echo -e "${YELLOW}└────────────────────────────────────────────────────────┘${NC}"
echo ""

read -p "Do you understand the risks? (type 'I UNDERSTAND'): " RISK_ACK
if [ "$RISK_ACK" != "I UNDERSTAND" ]; then
    echo "Cancelled for safety."
    exit 0
fi

echo ""
echo "What would you like to do?"
echo "  1) View disk information only (safe - no changes)"
echo "  2) Create partition in existing free space (safest dual boot method)"
echo "  3) Manual instructions for shrinking partitions"
echo "  4) Exit"
echo ""
read -p "Select option (1-4): " OPTION

case $OPTION in
    1)
        echo ""
        echo -e "${BLUE}═══ Disk Information ═══${NC}"
        echo ""
        echo -e "${GREEN}Available disks:${NC}"
        lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
        echo ""

        echo -e "${GREEN}All partitions:${NC}"
        lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL
        echo ""

        echo -e "${GREEN}Detailed partition table:${NC}"
        for disk in /dev/sd? /dev/nvme?n?; do
            if [ -b "$disk" ]; then
                echo ""
                echo -e "${YELLOW}Disk: $disk${NC}"
                parted $disk unit GB print free 2>/dev/null || fdisk -l $disk
            fi
        done
        echo ""

        echo -e "${YELLOW}TIP:${NC} Look for 'Free Space' in the partition table"
        echo "If you see free space, use option 2 to create a partition there."
        echo ""
        ;;

    2)
        echo ""
        echo -e "${BLUE}═══ Create Partition in Free Space ═══${NC}"
        echo ""
        echo "This option creates a NEW partition in EXISTING free space."
        echo "It will NOT shrink or modify any existing partitions."
        echo ""

        echo "Available disks:"
        lsblk -d -o NAME,SIZE,TYPE | grep disk
        echo ""

        read -p "Enter disk name (e.g., sda, nvme0n1): " DISK
        DISK="/dev/$DISK"

        if [ ! -b "$DISK" ]; then
            echo -e "${RED}✗${NC} Disk $DISK not found"
            exit 1
        fi

        # Validate disk is not mounted
        if mount | grep -q "^$DISK"; then
            echo -e "${RED}✗${NC} $DISK has mounted partitions"
            echo "This operation is too risky. Please unmount first."
            exit 1
        fi

        echo ""
        echo -e "${GREEN}Current partition layout on $DISK:${NC}"
        parted $DISK unit GB print free
        echo ""

        echo -e "${YELLOW}⚠ Look at the output above.${NC}"
        echo "You need to see 'Free Space' to create a partition."
        echo ""
        read -p "Do you see Free Space listed? (yes/no): " HAS_FREE_SPACE

        if [ "$HAS_FREE_SPACE" != "yes" ]; then
            echo ""
            echo -e "${YELLOW}No free space available.${NC}"
            echo ""
            echo "You need to shrink an existing partition first."
            echo "Use option 3 for manual instructions on how to safely shrink partitions."
            echo ""
            echo "RECOMMENDED APPROACH:"
            echo "  1. Boot into the OS you want to shrink (e.g., Windows)"
            echo "  2. Use that OS's built-in disk management tool to shrink"
            echo "  3. Then come back here and create partition in free space"
            echo ""
            exit 0
        fi

        echo ""
        echo "Enter the free space boundaries for the new partition:"
        echo "(Look at the 'Start' and 'End' of the Free Space line above)"
        echo ""
        read -p "Enter start position in GB (e.g., 850): " START_GB
        read -p "Enter end position in GB (e.g., 950): " END_GB

        # Validation
        if ! [[ "$START_GB" =~ ^[0-9]+$ ]] || ! [[ "$END_GB" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}✗${NC} Invalid input. Must be numbers."
            exit 1
        fi

        if [ "$END_GB" -le "$START_GB" ]; then
            echo -e "${RED}✗${NC} End must be greater than start"
            exit 1
        fi

        SIZE_GB=$((END_GB - START_GB))

        echo ""
        echo -e "${MAGENTA}═══ PLAN SUMMARY ═══${NC}"
        echo "Disk:       $DISK"
        echo "Start:      ${START_GB}GB"
        echo "End:        ${END_GB}GB"
        echo "Size:       ${SIZE_GB}GB"
        echo "Type:       ext4 (Linux filesystem)"
        echo ""
        echo -e "${YELLOW}This will create a NEW partition WITHOUT modifying existing ones.${NC}"
        echo ""
        read -p "Proceed with partition creation? (type 'YES' to confirm): " CONFIRM

        if [ "$CONFIRM" != "YES" ]; then
            echo "Cancelled."
            exit 0
        fi

        # Create partition
        echo ""
        echo -e "${YELLOW}→${NC} Creating partition..."
        if ! parted -a optimal $DISK mkpart primary ext4 ${START_GB}GB ${END_GB}GB; then
            echo -e "${RED}✗${NC} Partition creation failed!"
            echo "Please check the error message above."
            exit 1
        fi

        # Wait for kernel to recognize new partition
        sleep 2
        partprobe $DISK 2>/dev/null || true
        sleep 1

        # Find the new partition
        NEW_PART=$(lsblk -ln -o NAME $DISK | tail -1)
        NEW_PART="/dev/$NEW_PART"

        if [ ! -b "$NEW_PART" ]; then
            echo -e "${YELLOW}!${NC} Cannot auto-detect new partition"
            echo "Please run 'lsblk' to find it, then format manually:"
            echo "  sudo mkfs.ext4 /dev/sdXN"
            exit 0
        fi

        # Format new partition
        echo ""
        echo -e "${YELLOW}→${NC} Formatting $NEW_PART as ext4..."
        if ! mkfs.ext4 -F $NEW_PART; then
            echo -e "${RED}✗${NC} Formatting failed!"
            exit 1
        fi

        echo ""
        echo -e "${GREEN}✓${NC} Partition created successfully!"
        echo ""
        echo -e "${GREEN}New partition: $NEW_PART${NC}"
        echo ""
        echo "Final layout:"
        lsblk $DISK -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
        echo ""
        echo -e "${GREEN}You can now install CustomOS to $NEW_PART${NC}"
        echo ""
        echo "Next step:"
        echo "  bash install-auto.sh"
        echo "  Select option 2 (Partition installation)"
        echo "  Use $NEW_PART as root partition"
        ;;

    3)
        echo ""
        echo -e "${BLUE}═══ Manual Instructions for Shrinking Partitions ═══${NC}"
        echo ""
        echo -e "${YELLOW}SAFEST METHOD (Recommended):${NC}"
        echo "Use the native OS tools to shrink partitions:"
        echo ""
        echo -e "${GREEN}For Windows partitions:${NC}"
        echo "  1. Boot into Windows"
        echo "  2. Press Win+X, select 'Disk Management'"
        echo "  3. Right-click partition you want to shrink"
        echo "  4. Select 'Shrink Volume'"
        echo "  5. Enter amount to shrink (in MB)"
        echo "  6. Click 'Shrink'"
        echo "  7. Reboot and run this script again (option 2)"
        echo ""
        echo -e "${GREEN}For Linux (ext4) partitions:${NC}"
        echo "  1. Boot from Live USB/ISO (NOT the installed system)"
        echo "  2. Ensure partition is UNMOUNTED"
        echo "  3. Run filesystem check:"
        echo "     sudo e2fsck -f /dev/sdXN"
        echo "  4. Resize filesystem (make it smaller):"
        echo "     sudo resize2fs /dev/sdXN 500G"
        echo "     (Replace 500G with desired size)"
        echo "  5. Use parted to resize partition:"
        echo "     sudo parted /dev/sdX"
        echo "     (parted) print        # Note partition number and boundaries"
        echo "     (parted) resizepart N 500GB   # N = partition number"
        echo "     (parted) quit"
        echo "  6. Run this script again (option 2) to create partition in free space"
        echo ""
        echo -e "${RED}CRITICAL SAFETY RULES:${NC}"
        echo "  • NEVER resize a mounted partition"
        echo "  • ALWAYS run e2fsck before resizing"
        echo "  • ALWAYS resize filesystem BEFORE resizing partition"
        echo "  • Keep backups of important data"
        echo "  • Leave some buffer space (1-2GB)"
        echo ""
        echo -e "${YELLOW}Why shrinking is dangerous:${NC}"
        echo "  • Can corrupt data if done incorrectly"
        echo "  • Requires exact size calculations"
        echo "  • Easy to make mistakes with partition numbers"
        echo "  • Native OS tools are safer and more tested"
        echo ""
        echo -e "${GREEN}Recommended workflow:${NC}"
        echo "  1. Shrink using native OS tools (Windows Disk Management, etc.)"
        echo "  2. Reboot and check everything still works"
        echo "  3. Run this script option 2 to create partition in free space"
        echo "  4. Install CustomOS to the new partition"
        echo ""
        ;;

    4)
        echo "Exiting safely."
        exit 0
        ;;

    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}Done!${NC}"
echo ""
