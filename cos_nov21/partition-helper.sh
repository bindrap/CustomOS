#!/bin/bash

# Disk Partitioning Helper for CustomOS
# Helps users prepare their disk for dual boot installation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║          Disk Partitioning Helper for CustomOS            ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}✗${NC} This script must be run as root"
   exit 1
fi

echo -e "${YELLOW}This script helps you partition your disk for dual boot.${NC}"
echo ""
echo "What would you like to do?"
echo "  1) View current disk layout"
echo "  2) Shrink existing partition to make space"
echo "  3) Create new partition in free space"
echo "  4) Full guided partitioning for dual boot"
echo "  5) Manual instructions only"
echo ""
read -p "Select option (1-5): " OPTION

case $OPTION in
    1)
        echo ""
        echo -e "${BLUE}Current Disk Layout${NC}"
        echo ""
        echo "Available disks:"
        lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
        echo ""
        echo "Detailed partition info:"
        fdisk -l
        ;;

    2)
        echo ""
        echo -e "${BLUE}Shrink Existing Partition${NC}"
        echo ""
        echo "Available disks:"
        lsblk -d -o NAME,SIZE,TYPE | grep disk
        echo ""

        read -p "Enter disk name (e.g., sda): " DISK
        DISK="/dev/$DISK"

        if [ ! -b "$DISK" ]; then
            echo -e "${RED}✗${NC} Disk $DISK not found"
            exit 1
        fi

        echo ""
        echo "Current partitions on $DISK:"
        lsblk $DISK -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
        echo ""

        read -p "Enter partition number to shrink (e.g., 2 for ${DISK}2): " PART_NUM
        PARTITION="${DISK}${PART_NUM}"

        if [ ! -b "$PARTITION" ]; then
            echo -e "${RED}✗${NC} Partition $PARTITION not found"
            exit 1
        fi

        # Get partition filesystem
        FSTYPE=$(lsblk -no FSTYPE $PARTITION)

        echo ""
        echo -e "${YELLOW}Partition: $PARTITION${NC}"
        echo -e "${YELLOW}Filesystem: $FSTYPE${NC}"
        echo ""

        if [ "$FSTYPE" != "ext4" ] && [ "$FSTYPE" != "ext3" ] && [ "$FSTYPE" != "ext2" ]; then
            echo -e "${RED}WARNING:${NC} This script is designed for ext4 filesystems."
            echo "Your filesystem is: $FSTYPE"
            read -p "Continue anyway? (yes/no): " CONTINUE
            if [ "$CONTINUE" != "yes" ]; then
                exit 0
            fi
        fi

        # Check if partition is mounted and unmount it
        echo ""
        if mount | grep -q "$PARTITION"; then
            echo -e "${YELLOW}→${NC} $PARTITION is currently mounted, unmounting..."
            umount -R $PARTITION 2>/dev/null || umount $PARTITION || {
                echo -e "${RED}✗${NC} Failed to unmount $PARTITION"
                echo "Please manually unmount it first: sudo umount $PARTITION"
                exit 1
            }
            echo "  Unmounted successfully"
        fi

        # Check filesystem before resize
        echo ""
        echo -e "${YELLOW}→${NC} Checking filesystem on $PARTITION..."
        e2fsck -f $PARTITION || {
            echo -e "${RED}✗${NC} Filesystem check failed!"
            echo "Please fix filesystem errors before continuing."
            exit 1
        }

        echo ""
        echo "Current partition size:"
        parted $DISK unit GB print | grep "^ $PART_NUM"
        echo ""

        read -p "Enter new size in GB (e.g., 831 for 831GB): " NEW_SIZE
        read -p "How much space to free up in GB (e.g., 100 for 100GB): " SPACE_TO_FREE

        echo ""
        echo -e "${RED}WARNING: This will resize $PARTITION to ${NEW_SIZE}GB${NC}"
        echo -e "${RED}Make sure you have backups!${NC}"
        echo ""
        read -p "Continue? (yes/no): " CONFIRM
        if [ "$CONFIRM" != "yes" ]; then
            exit 0
        fi

        # Resize filesystem first
        echo ""
        echo -e "${YELLOW}→${NC} Resizing filesystem to ${NEW_SIZE}GB..."
        resize2fs $PARTITION ${NEW_SIZE}G || {
            echo -e "${RED}✗${NC} Filesystem resize failed!"
            exit 1
        }

        # Resize partition
        echo ""
        echo -e "${YELLOW}→${NC} Resizing partition..."
        parted $DISK resizepart $PART_NUM ${NEW_SIZE}GB || {
            echo -e "${RED}✗${NC} Partition resize failed!"
            exit 1
        }

        echo ""
        echo -e "${GREEN}✓${NC} Partition resized successfully!"
        echo ""
        echo "New layout:"
        lsblk $DISK -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
        echo ""
        echo "You now have approximately ${SPACE_TO_FREE}GB of free space."
        echo "Run this script again and select option 3 to create a new partition."
        ;;

    3)
        echo ""
        echo -e "${BLUE}Create New Partition${NC}"
        echo ""
        echo "Available disks:"
        lsblk -d -o NAME,SIZE,TYPE | grep disk
        echo ""

        read -p "Enter disk name (e.g., sda): " DISK
        DISK="/dev/$DISK"

        if [ ! -b "$DISK" ]; then
            echo -e "${RED}✗${NC} Disk $DISK not found"
            exit 1
        fi

        echo ""
        echo "Current partitions on $DISK:"
        lsblk $DISK -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
        echo ""
        parted $DISK unit GB print free
        echo ""

        read -p "Enter start position in GB (e.g., 831): " START_GB
        read -p "Enter end position in GB (e.g., 931): " END_GB

        # Calculate next partition number
        NEXT_PART=$(parted $DISK print | grep "^ " | tail -1 | awk '{print $1}')
        NEXT_PART=$((NEXT_PART + 1))

        echo ""
        echo "Will create partition ${NEXT_PART} from ${START_GB}GB to ${END_GB}GB"
        echo -e "${YELLOW}This will be ${DISK}${NEXT_PART}${NC}"
        echo ""
        read -p "Continue? (yes/no): " CONFIRM
        if [ "$CONFIRM" != "yes" ]; then
            exit 0
        fi

        echo ""
        echo -e "${YELLOW}→${NC} Creating partition..."
        parted $DISK mkpart primary ext4 ${START_GB}GB ${END_GB}GB || {
            echo -e "${RED}✗${NC} Partition creation failed!"
            exit 1
        }

        echo ""
        echo -e "${YELLOW}→${NC} Formatting partition as ext4..."
        mkfs.ext4 -F ${DISK}${NEXT_PART} || {
            echo -e "${RED}✗${NC} Formatting failed!"
            exit 1
        }

        echo ""
        echo -e "${GREEN}✓${NC} Partition created successfully!"
        echo ""
        echo "New layout:"
        lsblk $DISK -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
        echo ""
        echo -e "${GREEN}You can now install CustomOS to ${DISK}${NEXT_PART}${NC}"
        ;;

    4)
        echo ""
        echo -e "${BLUE}Guided Dual Boot Partitioning${NC}"
        echo ""
        echo "This will guide you through:"
        echo "  1. Checking current disk layout"
        echo "  2. Shrinking an existing partition"
        echo "  3. Creating a new partition for CustomOS"
        echo ""

        echo "Available disks:"
        lsblk -d -o NAME,SIZE,TYPE | grep disk
        echo ""

        read -p "Enter disk name (e.g., sda): " DISK
        DISK="/dev/$DISK"

        if [ ! -b "$DISK" ]; then
            echo -e "${RED}✗${NC} Disk $DISK not found"
            exit 1
        fi

        echo ""
        echo "Current layout:"
        lsblk $DISK -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
        echo ""
        parted $DISK unit GB print free
        echo ""

        read -p "Which partition do you want to shrink? (number): " PART_NUM
        PARTITION="${DISK}${PART_NUM}"

        if [ ! -b "$PARTITION" ]; then
            echo -e "${RED}✗${NC} Partition $PARTITION not found"
            exit 1
        fi

        echo ""
        read -p "How much space do you want for CustomOS in GB? (e.g., 100): " SPACE_FOR_CUSTOMOS

        # Get current partition end
        CURRENT_END=$(parted $DISK unit GB print | grep "^ $PART_NUM" | awk '{print $3}' | sed 's/GB//')
        NEW_END=$(echo "$CURRENT_END - $SPACE_FOR_CUSTOMOS" | bc)
        CUSTOMOS_START=$NEW_END
        CUSTOMOS_END=$CURRENT_END

        echo ""
        echo "Plan:"
        echo "  1. Shrink $PARTITION to ${NEW_END}GB"
        echo "  2. Create new partition from ${CUSTOMOS_START}GB to ${CUSTOMOS_END}GB"
        echo "  3. Format new partition as ext4"
        echo ""
        echo -e "${RED}WARNING: Make sure you have backups!${NC}"
        echo ""
        read -p "Continue with this plan? (yes/no): " CONFIRM
        if [ "$CONFIRM" != "yes" ]; then
            exit 0
        fi

        # Unmount partition if mounted
        echo ""
        if mount | grep -q "$PARTITION"; then
            echo -e "${YELLOW}→${NC} $PARTITION is currently mounted, unmounting..."
            umount -R $PARTITION 2>/dev/null || umount $PARTITION || {
                echo -e "${RED}✗${NC} Failed to unmount $PARTITION"
                echo "Please manually unmount it first: sudo umount $PARTITION"
                exit 1
            }
            echo "  Unmounted successfully"
        fi

        # Check filesystem
        echo ""
        echo -e "${YELLOW}→${NC} Checking filesystem..."
        e2fsck -f $PARTITION || {
            echo -e "${RED}✗${NC} Filesystem check failed!"
            exit 1
        }

        # Resize filesystem
        echo ""
        echo -e "${YELLOW}→${NC} Resizing filesystem..."
        resize2fs $PARTITION ${NEW_END}G || {
            echo -e "${RED}✗${NC} Filesystem resize failed!"
            exit 1
        }

        # Resize partition
        echo ""
        echo -e "${YELLOW}→${NC} Resizing partition..."
        parted $DISK resizepart $PART_NUM ${NEW_END}GB || {
            echo -e "${RED}✗${NC} Partition resize failed!"
            exit 1
        }

        # Create new partition
        NEXT_PART=$((PART_NUM + 1))
        echo ""
        echo -e "${YELLOW}→${NC} Creating new partition..."
        parted $DISK mkpart primary ext4 ${CUSTOMOS_START}GB ${CUSTOMOS_END}GB || {
            echo -e "${RED}✗${NC} Partition creation failed!"
            exit 1
        }

        # Format new partition
        echo ""
        echo -e "${YELLOW}→${NC} Formatting new partition..."
        mkfs.ext4 -F ${DISK}${NEXT_PART} || {
            echo -e "${RED}✗${NC} Formatting failed!"
            exit 1
        }

        echo ""
        echo -e "${GREEN}✓${NC} Partitioning complete!"
        echo ""
        echo "Final layout:"
        lsblk $DISK -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
        echo ""
        echo -e "${GREEN}You can now install CustomOS to ${DISK}${NEXT_PART}${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Run: bash install-auto.sh"
        echo "  2. When asked for disk, enter: $(basename ${DISK})${NEXT_PART}"
        ;;

    5)
        echo ""
        echo -e "${BLUE}Manual Partitioning Instructions${NC}"
        echo ""
        echo "To prepare your disk for dual boot:"
        echo ""
        echo -e "${YELLOW}1. View current layout:${NC}"
        echo "   lsblk"
        echo "   fdisk -l"
        echo ""
        echo -e "${YELLOW}2. Check filesystem before resizing:${NC}"
        echo "   sudo e2fsck -f /dev/sdaX"
        echo ""
        echo -e "${YELLOW}3. Resize filesystem:${NC}"
        echo "   sudo resize2fs /dev/sdaX NEW_SIZE_IN_GB"
        echo "   Example: sudo resize2fs /dev/sda2 831G"
        echo ""
        echo -e "${YELLOW}4. Use parted to resize partition:${NC}"
        echo "   sudo parted /dev/sda"
        echo "   (parted) print              # View current layout"
        echo "   (parted) resizepart 2 831GB # Resize partition 2 to 831GB"
        echo "   (parted) mkpart primary ext4 831GB 931GB  # Create new partition"
        echo "   (parted) print              # Verify"
        echo "   (parted) quit"
        echo ""
        echo -e "${YELLOW}5. Format new partition:${NC}"
        echo "   sudo mkfs.ext4 /dev/sdaX"
        echo "   Example: sudo mkfs.ext4 /dev/sda3"
        echo ""
        echo -e "${YELLOW}6. Verify:${NC}"
        echo "   lsblk"
        echo ""
        echo -e "${YELLOW}Important notes:${NC}"
        echo "  - Always check filesystem before resizing (e2fsck)"
        echo "  - Resize filesystem BEFORE resizing partition"
        echo "  - Make backups before any partition operations"
        echo "  - Free space = Current size - New size"
        echo ""
        ;;

    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
