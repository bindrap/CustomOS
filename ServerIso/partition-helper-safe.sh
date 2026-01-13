#!/bin/bash

# PBOS Partition Helper - Educational and Foolproof
# Helps users create dual boot partitions safely

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║         PBOS Dual Boot Partition Helper                  ║
║         Educational & Safe                                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}✗${NC} This script must be run as root"
   echo "Run: sudo bash $0"
   exit 1
fi

# Check required tools
MISSING_TOOLS=""
for tool in parted lsblk blkid free; do
    if ! command -v $tool &> /dev/null; then
        MISSING_TOOLS="$MISSING_TOOLS $tool"
    fi
done

if [ -n "$MISSING_TOOLS" ]; then
    echo -e "${RED}✗${NC} Missing required tools:$MISSING_TOOLS"
    echo "Please install: pacman -S parted util-linux"
    exit 1
fi

# Educational intro
show_partition_basics() {
    clear
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}       Understanding Partitions (Dual Boot 101)            ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}What you need for PBOS dual boot with Windows:${NC}"
    echo ""
    echo -e "${YELLOW}1. EFI Partition${NC} (already exists on your system!)"
    echo -e "   ${CYAN}•${NC} Size: 100-512MB"
    echo -e "   ${CYAN}•${NC} Format: FAT32"
    echo -e "   ${CYAN}•${NC} Purpose: Stores bootloaders for BOTH Windows and Linux"
    echo -e "   ${CYAN}•${NC} ${GREEN}SHARED${NC} - You DON'T create a new one, use existing!"
    echo ""
    echo -e "${YELLOW}2. Root Partition${NC} (/) - Main PBOS system"
    echo -e "   ${CYAN}•${NC} Size: 30GB minimum, 50-100GB recommended"
    echo -e "   ${CYAN}•${NC} Format: ext4 (Linux filesystem)"
    echo -e "   ${CYAN}•${NC} Purpose: All PBOS files, programs, and settings"
    echo -e "   ${CYAN}•${NC} This is what we'll create today!"
    echo ""
    echo -e "${YELLOW}3. Swap${NC} (optional but recommended)"
    echo -e "   ${CYAN}•${NC} Size: Based on your RAM (we'll calculate it)"
    echo -e "   ${CYAN}•${NC} Format: linux-swap"
    echo -e "   ${CYAN}•${NC} Purpose: Extra memory when RAM is full + hibernation"
    echo -e "   ${CYAN}•${NC} Alternative: Can use a swap file instead (easier)"
    echo ""
    echo -e "${BLUE}Example dual boot disk layout:${NC}"
    echo ""
    echo "  /dev/sda1  ${GREEN}EFI${NC}     512MB   [Windows & PBOS bootloaders]"
    echo "  /dev/sda2  ${BLUE}Windows${NC} 200GB   [Your Windows installation]"
    echo "  /dev/sda3  ${YELLOW}PBOS${NC}    60GB    [PBOS root - we create this]"
    echo "  /dev/sda4  ${MAGENTA}Swap${NC}    8GB     [Swap space - optional]"
    echo ""
    read -p "Press Enter to continue..."
}

# Detect system RAM and recommend swap size
get_swap_recommendation() {
    local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    local swap_gb

    if [ "$ram_gb" -le 4 ]; then
        swap_gb=$((ram_gb + 2))
        echo "${swap_gb}GB (you have ${ram_gb}GB RAM - recommend equal to RAM + 2GB)"
    elif [ "$ram_gb" -le 8 ]; then
        swap_gb=8
        echo "${swap_gb}GB (you have ${ram_gb}GB RAM - 8GB is sufficient)"
    elif [ "$ram_gb" -le 16 ]; then
        swap_gb=8
        echo "${swap_gb}GB (you have ${ram_gb}GB RAM - 8GB recommended)"
    else
        swap_gb=8
        echo "${swap_gb}GB (you have ${ram_gb}GB RAM - 8GB is plenty)"
    fi
}

# Detect EFI partition
detect_efi_partition() {
    echo -e "${BLUE}→${NC} Detecting existing EFI partition..."
    echo ""

    # Look for mounted EFI partitions
    local efi_mounted=$(mount | grep -i efi | head -1 | awk '{print $1}')

    # Look for FAT32 partitions that might be EFI
    local efi_parts=$(blkid | grep -i 'TYPE="vfat"' | grep -i 'PARTLABEL="EFI\|LABEL="EFI\|PARTUUID=' | cut -d':' -f1)

    if [ -n "$efi_mounted" ]; then
        echo -e "${GREEN}✓ Found EFI partition:${NC} $efi_mounted (currently mounted)"
        echo -e "  ${CYAN}You will use this existing EFI partition${NC}"
        return 0
    elif [ -n "$efi_parts" ]; then
        echo -e "${GREEN}✓ Found potential EFI partition(s):${NC}"
        for part in $efi_parts; do
            local size=$(lsblk -n -o SIZE "$part" 2>/dev/null || echo "unknown")
            echo -e "  ${YELLOW}$part${NC} - Size: $size"
        done
        echo ""
        echo -e "  ${CYAN}You will share this EFI partition with Windows${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ No obvious EFI partition detected${NC}"
        echo -e "  Checking all FAT32 partitions:"
        blkid | grep 'TYPE="vfat"' | cut -d':' -f1 | while read part; do
            local size=$(lsblk -n -o SIZE "$part" 2>/dev/null || echo "unknown")
            echo -e "    $part - Size: $size"
        done
        return 1
    fi
    echo ""
}

# Main menu
show_main_menu() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║             PBOS Partition Helper - Main Menu            ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}What would you like to do?${NC}"
    echo ""
    echo "  ${CYAN}0)${NC} Learn about partitions (recommended for beginners)"
    echo "  ${CYAN}1)${NC} View my current disk setup (safe - no changes)"
    echo "  ${CYAN}2)${NC} Analyze my system (check EFI, RAM, recommend sizes)"
    echo "  ${CYAN}3)${NC} Create PBOS partition (guided - safest method)"
    echo "  ${CYAN}4)${NC} Show manual shrinking instructions"
    echo "  ${CYAN}5)${NC} Exit"
    echo ""
}

# View disk information
view_disk_info() {
    clear
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}            Your Current Disk Setup                        ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""

    echo -e "${GREEN}▶ Available Disks:${NC}"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
    echo ""

    echo -e "${GREEN}▶ All Partitions:${NC}"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL
    echo ""

    echo -e "${GREEN}▶ Detailed Partition Tables:${NC}"
    for disk in /dev/sd? /dev/nvme?n?; do
        if [ -b "$disk" ]; then
            echo ""
            echo -e "${YELLOW}═══ Disk: $disk ═══${NC}"
            parted $disk unit GB print free 2>/dev/null || fdisk -l $disk
            echo ""
        fi
    done

    echo -e "${CYAN}TIP:${NC} Look for ${GREEN}'Free Space'${NC} in the partition table"
    echo "     If you see free space, you can create PBOS partition there."
    echo ""

    read -p "Press Enter to return to menu..."
}

# Analyze system and give recommendations
analyze_system() {
    clear
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}            System Analysis & Recommendations              ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Check RAM
    local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    local ram_mb=$(free -m | awk '/^Mem:/{print $2}')
    echo -e "${GREEN}▶ RAM Detected:${NC}"
    echo "  Total RAM: ${YELLOW}${ram_mb}MB${NC} (~${ram_gb}GB)"
    echo ""

    # Swap recommendation
    echo -e "${GREEN}▶ Swap Recommendation:${NC}"
    local swap_rec=$(get_swap_recommendation)
    echo "  Recommended swap size: ${YELLOW}$swap_rec${NC}"
    echo ""
    echo -e "${CYAN}  Note:${NC} You can create swap partition OR use a swap file later."
    echo "        Swap file is easier - you can add it after installing PBOS."
    echo ""

    # EFI detection
    echo -e "${GREEN}▶ EFI Partition Detection:${NC}"
    detect_efi_partition
    echo ""

    # Root partition recommendation
    echo -e "${GREEN}▶ Root Partition (/) Recommendation:${NC}"
    echo "  ${CYAN}Minimum:${NC}     30GB  (tight, only for testing)"
    echo "  ${YELLOW}Recommended:${NC} 50GB  (comfortable for daily use)"
    echo "  ${GREEN}Ideal:${NC}       80-100GB (plenty of space for everything)"
    echo ""

    # Total space needed
    echo -e "${GREEN}▶ Total Space Needed:${NC}"
    echo "  For PBOS only (no swap):     ${YELLOW}50-100GB${NC}"
    echo "  For PBOS + swap partition:   ${YELLOW}58-108GB${NC} (depends on RAM)"
    echo ""

    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}              What You Need To Do:                         ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "  ${GREEN}Step 1:${NC} Free up space on your disk"
    echo "          - Boot into Windows"
    echo "          - Use Disk Management to shrink Windows partition"
    echo "          - Shrink by at least 60GB (recommended 80-100GB)"
    echo ""
    echo "  ${GREEN}Step 2:${NC} Come back here and run option 3"
    echo "          - This script will create PBOS partition in the free space"
    echo ""
    echo "  ${GREEN}Step 3:${NC} Install PBOS using install-arch command"
    echo ""

    read -p "Press Enter to return to menu..."
}

# Create partition in free space
create_partition_guided() {
    clear
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}         Create PBOS Partition (Guided Mode)               ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""

    echo -e "${YELLOW}⚠ SAFETY WARNINGS:${NC}"
    echo "  • This will create a NEW partition in EXISTING free space"
    echo "  • It will NOT shrink or modify existing partitions"
    echo "  • Make sure you have already shrunk Windows (if needed)"
    echo "  • BACKUP important data before proceeding"
    echo ""
    read -p "Do you understand? (type 'yes'): " SAFETY_ACK
    if [ "$SAFETY_ACK" != "yes" ]; then
        echo "Cancelled for safety."
        return
    fi

    echo ""
    echo -e "${GREEN}Available disks:${NC}"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
    echo ""

    read -p "Enter disk name (e.g., sda, nvme0n1): " DISK
    DISK="/dev/$DISK"

    if [ ! -b "$DISK" ]; then
        echo -e "${RED}✗${NC} Disk $DISK not found"
        read -p "Press Enter to continue..."
        return
    fi

    echo ""
    echo -e "${GREEN}Current partition layout on $DISK:${NC}"
    echo ""
    parted $DISK unit GB print free
    echo ""

    echo -e "${YELLOW}⚠ LOOK CAREFULLY at the output above!${NC}"
    echo ""
    echo -e "${GREEN}What you're looking for:${NC}"
    echo "  • Lines that say '${CYAN}Free Space${NC}'"
    echo "  • Check the ${CYAN}Start${NC} and ${CYAN}End${NC} positions in GB"
    echo "  • Check the ${CYAN}Size${NC} - make sure it's enough (50GB+)"
    echo ""

    read -p "Do you see 'Free Space' in the table above? (yes/no): " HAS_FREE
    if [ "$HAS_FREE" != "yes" ]; then
        echo ""
        echo -e "${YELLOW}No free space available!${NC}"
        echo ""
        echo -e "${RED}You need to create free space first:${NC}"
        echo "  1. Boot into Windows"
        echo "  2. Press ${CYAN}Win+X${NC} and select '${CYAN}Disk Management${NC}'"
        echo "  3. Right-click your Windows partition (usually C:)"
        echo "  4. Select '${CYAN}Shrink Volume${NC}'"
        echo "  5. Enter amount to shrink (at least 60000 MB for 60GB)"
        echo "  6. Click '${CYAN}Shrink${NC}' and wait"
        echo "  7. Reboot and run this script again"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    echo ""
    echo -e "${GREEN}Great! Let's create your PBOS partition.${NC}"
    echo ""
    echo "Do you want to create a swap partition too?"
    echo ""
    local swap_rec=$(get_swap_recommendation)
    echo -e "  ${CYAN}Recommended:${NC} $swap_rec"
    echo ""
    echo "  ${YELLOW}a)${NC} Create only root partition (/) - you can add swap file later"
    echo "  ${YELLOW}b)${NC} Create root + swap partitions"
    echo ""
    read -p "Choice (a/b): " SWAP_CHOICE

    echo ""
    echo -e "${CYAN}Enter partition details:${NC}"
    echo "(Look at the 'Free Space' line above for Start and End values)"
    echo ""
    read -p "Start position in GB (e.g., 850): " START_GB
    read -p "End position in GB (e.g., 950): " END_GB

    # Validation
    if ! [[ "$START_GB" =~ ^[0-9]+$ ]] || ! [[ "$END_GB" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}✗${NC} Invalid input. Must be numbers."
        read -p "Press Enter to continue..."
        return
    fi

    if [ "$END_GB" -le "$START_GB" ]; then
        echo -e "${RED}✗${NC} End must be greater than start"
        read -p "Press Enter to continue..."
        return
    fi

    SIZE_GB=$((END_GB - START_GB))

    if [ "$SIZE_GB" -lt 30 ]; then
        echo -e "${YELLOW}⚠ Warning:${NC} ${SIZE_GB}GB is quite small for PBOS"
        echo "  Minimum is 30GB, recommended is 50GB+"
        read -p "Continue anyway? (yes/no): " CONT
        if [ "$CONT" != "yes" ]; then
            return
        fi
    fi

    # Summary
    clear
    echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║                   PARTITION PLAN                          ║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Disk:${NC}         $DISK"
    echo ""

    if [ "$SWAP_CHOICE" = "b" ]; then
        # Split space between root and swap
        local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
        local swap_gb=8
        if [ "$ram_gb" -le 8 ]; then
            swap_gb=8
        fi

        local root_end=$((END_GB - swap_gb))
        local root_size=$((root_end - START_GB))

        echo -e "${YELLOW}Partition 1: Root (/)${NC}"
        echo "  Start:      ${START_GB}GB"
        echo "  End:        ${root_end}GB"
        echo "  Size:       ${root_size}GB"
        echo "  Format:     ext4"
        echo ""
        echo -e "${YELLOW}Partition 2: Swap${NC}"
        echo "  Start:      ${root_end}GB"
        echo "  End:        ${END_GB}GB"
        echo "  Size:       ${swap_gb}GB"
        echo "  Format:     linux-swap"
    else
        echo -e "${YELLOW}Partition: Root (/)${NC}"
        echo "  Start:      ${START_GB}GB"
        echo "  End:        ${END_GB}GB"
        echo "  Size:       ${SIZE_GB}GB"
        echo "  Format:     ext4"
    fi

    echo ""
    echo -e "${CYAN}EFI Partition:${NC} Using existing (shared with Windows)"
    echo ""
    echo -e "${GREEN}This will create NEW partition(s) WITHOUT touching existing ones.${NC}"
    echo ""
    read -p "Proceed? (type 'YES' in capital letters): " FINAL_CONFIRM

    if [ "$FINAL_CONFIRM" != "YES" ]; then
        echo "Cancelled."
        read -p "Press Enter to continue..."
        return
    fi

    # Create partitions
    echo ""
    echo -e "${YELLOW}→${NC} Creating partition(s)..."

    if [ "$SWAP_CHOICE" = "b" ]; then
        # Create root + swap
        local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
        local swap_gb=8
        local root_end=$((END_GB - swap_gb))

        echo -e "${BLUE}→${NC} Creating root partition..."
        if ! parted -a optimal $DISK mkpart primary ext4 ${START_GB}GB ${root_end}GB; then
            echo -e "${RED}✗${NC} Failed!"
            read -p "Press Enter to continue..."
            return
        fi

        sleep 2
        partprobe $DISK 2>/dev/null || true
        sleep 1

        echo -e "${BLUE}→${NC} Creating swap partition..."
        if ! parted -a optimal $DISK mkpart primary linux-swap ${root_end}GB ${END_GB}GB; then
            echo -e "${RED}✗${NC} Failed!"
            read -p "Press Enter to continue..."
            return
        fi

        sleep 2
        partprobe $DISK 2>/dev/null || true
        sleep 1

        # Format partitions
        local root_part=$(lsblk -ln -o NAME $DISK | tail -2 | head -1)
        local swap_part=$(lsblk -ln -o NAME $DISK | tail -1)
        root_part="/dev/$root_part"
        swap_part="/dev/$swap_part"

        echo -e "${BLUE}→${NC} Formatting root partition..."
        mkfs.ext4 -F $root_part

        echo -e "${BLUE}→${NC} Formatting swap partition..."
        mkswap $swap_part

        echo ""
        echo -e "${GREEN}✓ Success!${NC}"
        echo ""
        echo -e "${GREEN}Created partitions:${NC}"
        echo "  Root: $root_part (mount at /)"
        echo "  Swap: $swap_part"

    else
        # Create only root
        echo -e "${BLUE}→${NC} Creating root partition..."
        if ! parted -a optimal $DISK mkpart primary ext4 ${START_GB}GB ${END_GB}GB; then
            echo -e "${RED}✗${NC} Failed!"
            read -p "Press Enter to continue..."
            return
        fi

        sleep 2
        partprobe $DISK 2>/dev/null || true
        sleep 1

        local root_part=$(lsblk -ln -o NAME $DISK | tail -1)
        root_part="/dev/$root_part"

        echo -e "${BLUE}→${NC} Formatting partition..."
        mkfs.ext4 -F $root_part

        echo ""
        echo -e "${GREEN}✓ Success!${NC}"
        echo ""
        echo -e "${GREEN}Created partition:${NC}"
        echo "  Root: $root_part (mount at /)"
        echo ""
        echo -e "${CYAN}Note:${NC} You can add a swap file later with:"
        echo "  sudo dd if=/dev/zero of=/swapfile bs=1M count=8192"
        echo "  sudo chmod 600 /swapfile"
        echo "  sudo mkswap /swapfile"
        echo "  sudo swapon /swapfile"
    fi

    echo ""
    echo -e "${GREEN}Final disk layout:${NC}"
    lsblk $DISK -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
    echo ""

    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                NEXT STEPS                                  ${NC}"
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}1.${NC} Run the installation:"
    echo "     ${CYAN}install-arch${NC}"
    echo ""
    echo -e "${GREEN}2.${NC} Select option ${CYAN}2${NC} (Partition installation for dual boot)"
    echo ""
    echo -e "${GREEN}3.${NC} When asked for EFI partition:"
    echo "     - Look for existing EFI (usually /dev/sda1 or /dev/nvme0n1p1)"
    echo "     - It's usually 100-512MB, FAT32 format"
    echo "     - ${YELLOW}DO NOT${NC} format it, just use it as-is"
    echo ""
    echo -e "${GREEN}4.${NC} When asked for root partition:"
    echo "     - Use ${CYAN}$root_part${NC}"
    echo "     - Format it as ext4"
    echo ""
    if [ "$SWAP_CHOICE" = "b" ]; then
        echo -e "${GREEN}5.${NC} When asked for swap:"
        echo "     - Use ${CYAN}$swap_part${NC}"
    fi
    echo ""

    read -p "Press Enter to continue..."
}

# Show shrinking instructions
show_shrink_instructions() {
    clear
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}     How to Shrink Partitions Safely (Create Free Space)   ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""

    echo -e "${GREEN}▶ Method 1: Shrink Windows Partition (RECOMMENDED)${NC}"
    echo ""
    echo "  ${YELLOW}Step 1:${NC} Boot into Windows"
    echo ""
    echo "  ${YELLOW}Step 2:${NC} Open Disk Management"
    echo "          - Press ${CYAN}Win + X${NC} keys together"
    echo "          - Click '${CYAN}Disk Management${NC}'"
    echo ""
    echo "  ${YELLOW}Step 3:${NC} Shrink your Windows partition (usually C:)"
    echo "          - Right-click on Windows partition (C:)"
    echo "          - Select '${CYAN}Shrink Volume${NC}'"
    echo "          - Windows will calculate available space"
    echo ""
    echo "  ${YELLOW}Step 4:${NC} Enter amount to shrink"
    echo "          - For 60GB PBOS: enter ${CYAN}61440${NC} MB (60GB + buffer)"
    echo "          - For 80GB PBOS: enter ${CYAN}81920${NC} MB (80GB + buffer)"
    echo "          - For 100GB PBOS: enter ${CYAN}102400${NC} MB (100GB + buffer)"
    echo ""
    echo "  ${YELLOW}Step 5:${NC} Click '${CYAN}Shrink${NC}' and wait (may take a while)"
    echo ""
    echo "  ${YELLOW}Step 6:${NC} You should see '${GREEN}Unallocated Space${NC}' appear"
    echo ""
    echo "  ${YELLOW}Step 7:${NC} Reboot and run this script option 3 to create PBOS partition"
    echo ""
    echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
    echo ""

    echo -e "${YELLOW}▶ Why Windows Disk Management is best:${NC}"
    echo "  ${GREEN}✓${NC} Windows knows exactly where its files are"
    echo "  ${GREEN}✓${NC} Safest method with lowest risk"
    echo "  ${GREEN}✓${NC} No command-line needed"
    echo "  ${GREEN}✓${NC} Built-in and tested by Microsoft"
    echo "  ${GREEN}✓${NC} Works even if you're a beginner"
    echo ""

    echo -e "${RED}⚠ Important Notes:${NC}"
    echo "  • Defragment Windows before shrinking (optional but helps)"
    echo "  • Disable hibernation temporarily: ${CYAN}powercfg /h off${NC}"
    echo "  • Disable page file temporarily (Advanced System Settings)"
    echo "  • Close all programs before shrinking"
    echo "  • Make sure you have at least 20% free space in Windows"
    echo ""

    read -p "Press Enter to continue..."
}

# Main program loop
while true; do
    show_main_menu
    read -p "Select option (0-5): " CHOICE

    case $CHOICE in
        0)
            show_partition_basics
            ;;
        1)
            view_disk_info
            ;;
        2)
            analyze_system
            ;;
        3)
            create_partition_guided
            ;;
        4)
            show_shrink_instructions
            ;;
        5)
            echo "Exiting safely. Good luck with PBOS!"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            ;;
    esac
done
