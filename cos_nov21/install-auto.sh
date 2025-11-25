#!/bin/bash

# Auto-Detect Installation Script
# Automatically chooses online or offline mode based on internet connectivity

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

clear
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║         ██████╗ ██████╗  ██████╗  ███████╗                ║
║         ██╔══██╗██╔══██╗██╔═══██╗██╔════╝                 ║
║         ██████╔╝██████╔╝██║   ██║███████╗                 ║
║         ██╔═══╝ ██╔══██╗██║   ██║╚════██║                 ║
║         ██║     ██████╔╝╚██████╔╝███████║                 ║
║         ╚═╝     ╚═════╝  ╚═════╝ ╚══════╝                 ║
║                                                           ║
║    ॐ     Automated Arch Linux Installation      ॐ         ║
║                 By Parteek Bindra                         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}✗${NC} This script must be run as root"
   exit 1
fi

# Detect internet connectivity
echo -e "${YELLOW}→${NC} Detecting internet connectivity..."
echo "Testing connection, please wait..."
sleep 2

INSTALL_MODE="offline"

# Try ping first (most reliable)
if ping -c 1 -W 5 8.8.8.8 &>/dev/null; then
    INSTALL_MODE="online"
    echo -e "${GREEN}✓${NC} Internet detected - Using online installation"
elif ping -c 1 -W 5 1.1.1.1 &>/dev/null; then
    INSTALL_MODE="online"
    echo -e "${GREEN}✓${NC} Internet detected - Using online installation"
elif ping -c 1 -W 5 archlinux.org &>/dev/null; then
    INSTALL_MODE="online"
    echo -e "${GREEN}✓${NC} Internet detected - Using online installation"
else
    echo -e "${YELLOW}!${NC} No internet detected - Would use offline installation"
    echo ""
    echo "If you have internet, the detection may have failed."
    read -p "Do you have internet connection? (yes/no): " HAS_INTERNET
    if [ "$HAS_INTERNET" = "yes" ]; then
        INSTALL_MODE="online"
        echo -e "${GREEN}✓${NC} Manual override - Using online installation"
    else
        echo -e "${YELLOW}!${NC} Using offline installation (requires offline packages)"
    fi
fi

echo ""
echo "Installation Mode: ${INSTALL_MODE^^}"
echo ""

# Gather user input
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC} System Configuration"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Installation type selection
echo "Installation Type:"
echo "  1) Full disk installation (erases entire disk)"
echo "  2) Partition installation (dual boot - install to existing partition)"
echo ""
read -p "Select installation type (1 or 2): " INSTALL_TYPE

if [ "$INSTALL_TYPE" != "1" ] && [ "$INSTALL_TYPE" != "2" ]; then
    echo -e "${RED}✗${NC} Invalid selection"
    exit 1
fi

# Show available disks and partitions
echo ""
echo "Available disks and partitions:"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
echo ""

if [ "$INSTALL_TYPE" = "1" ]; then
    # Full disk installation
    echo -e "${YELLOW}Full Disk Installation Mode${NC}"
    echo ""
    read -p "Enter target disk (e.g., sda, nvme0n1): " DISK
    DISK="/dev/$DISK"

    if [ ! -b "$DISK" ]; then
        echo -e "${RED}✗${NC} Disk $DISK not found"
        exit 1
    fi

    echo -e "${RED}WARNING: All data on $DISK will be erased!${NC}"
    read -p "Continue? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Installation cancelled"
        exit 0
    fi

    PARTITION_MODE="full"
else
    # Partition installation for dual boot
    echo -e "${YELLOW}Partition Installation Mode (Dual Boot)${NC}"
    echo ""
    echo "You will need to specify:"
    echo "  - Root partition (where CustomOS will be installed)"
    echo "  - EFI partition (if UEFI) or disk for GRUB (if BIOS)"
    echo "  - Optional: Swap partition"
    echo ""
    echo -e "${BLUE}Note: The script will automatically unmount partitions if needed${NC}"
    echo ""

    read -p "Enter root partition (e.g., sda3, nvme0n1p3): " ROOT_PART
    ROOT_PARTITION="/dev/$ROOT_PART"

    if [ ! -b "$ROOT_PARTITION" ]; then
        echo -e "${RED}✗${NC} Partition $ROOT_PARTITION not found"
        exit 1
    fi

    # Extract disk name from partition
    if [[ $ROOT_PARTITION == *"nvme"* ]] || [[ $ROOT_PARTITION == *"mmcblk"* ]]; then
        DISK=$(echo $ROOT_PARTITION | sed 's/p[0-9]*$//')
    else
        DISK=$(echo $ROOT_PARTITION | sed 's/[0-9]*$//')
    fi

    echo ""
    echo "Root partition: $ROOT_PARTITION"
    echo "Parent disk: $DISK"
    echo ""

    # Ask about EFI partition
    read -p "Do you have an existing EFI partition to use? (yes/no): " HAS_EFI
    if [ "$HAS_EFI" = "yes" ]; then
        read -p "Enter EFI partition (e.g., sda2, nvme0n1p2): " EFI_PART
        EFI_PARTITION="/dev/$EFI_PART"

        if [ ! -b "$EFI_PARTITION" ]; then
            echo -e "${RED}✗${NC} Partition $EFI_PARTITION not found"
            exit 1
        fi
        echo "EFI partition: $EFI_PARTITION"
    else
        EFI_PARTITION=""
        echo "No EFI partition - will use GRUB on BIOS"
    fi

    # Ask about swap
    echo ""
    read -p "Do you want to use a swap partition? (yes/no): " USE_SWAP
    if [ "$USE_SWAP" = "yes" ]; then
        read -p "Enter swap partition (e.g., sda3, nvme0n1p3): " SWAP_PART
        SWAP_PARTITION="/dev/$SWAP_PART"

        if [ ! -b "$SWAP_PARTITION" ]; then
            echo -e "${RED}✗${NC} Partition $SWAP_PARTITION not found"
            exit 1
        fi
        echo "Swap partition: $SWAP_PARTITION"
    else
        SWAP_PARTITION=""
        echo "No swap partition"
    fi

    echo ""
    echo -e "${RED}WARNING: $ROOT_PARTITION will be formatted (all data lost)!${NC}"
    if [ -n "$SWAP_PARTITION" ]; then
        echo -e "${RED}WARNING: $SWAP_PARTITION will be formatted as swap!${NC}"
    fi
    echo ""
    read -p "Continue? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Installation cancelled"
        exit 0
    fi

    PARTITION_MODE="manual"
fi

read -p "Hostname: " HOSTNAME
read -p "Username: " USERNAME
read -sp "Password: " PASSWORD
echo ""
read -sp "Confirm password: " PASSWORD2
echo ""

if [ "$PASSWORD" != "$PASSWORD2" ]; then
    echo -e "${RED}✗${NC} Passwords don't match"
    exit 1
fi

# Confirm settings
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC} Installation Summary"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Mode:     $INSTALL_MODE"
if [ "$PARTITION_MODE" = "full" ]; then
    echo "Type:     Full disk installation"
    echo "Disk:     $DISK (will be erased)"
else
    echo "Type:     Partition installation (dual boot)"
    echo "Root:     $ROOT_PARTITION"
    if [ -n "$EFI_PARTITION" ]; then
        echo "EFI:      $EFI_PARTITION"
    fi
    if [ -n "$SWAP_PARTITION" ]; then
        echo "Swap:     $SWAP_PARTITION"
    fi
fi
echo "Hostname: $HOSTNAME"
echo "Username: $USERNAME"
echo ""
read -p "Proceed with installation? (yes/no): " FINAL_CONFIRM
if [ "$FINAL_CONFIRM" != "yes" ]; then
    echo "Installation cancelled"
    exit 0
fi

# Start installation
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC} Starting Installation"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Determine disk naming scheme
if [[ $DISK == *"nvme"* ]] || [[ $DISK == *"mmcblk"* ]]; then
    DISK_P="${DISK}p"
else
    DISK_P="${DISK}"
fi

if [ "$PARTITION_MODE" = "full" ]; then
    # Full disk installation - create partitions
    echo -e "${YELLOW}→${NC} Partitioning disk..."
    sgdisk -Z $DISK

    # Create partitions for both BIOS and UEFI boot support
    sgdisk -n 1:0:+1M -t 1:ef02 $DISK      # BIOS boot partition (for GRUB)
    sgdisk -n 2:0:+512M -t 2:ef00 $DISK    # EFI System Partition (for systemd-boot)
    sgdisk -n 3:0:+4G -t 3:8200 $DISK      # Swap
    sgdisk -n 4:0:0 -t 4:8300 $DISK        # Root filesystem

    echo "Partition layout:"
    echo "  1: BIOS boot (1MB) - for GRUB in BIOS mode"
    echo "  2: EFI System (512MB) - for systemd-boot in UEFI mode"
    echo "  3: Swap (4GB)"
    echo "  4: Root (remaining space)"

    # Format partitions (skip partition 1, it's used raw by GRUB)
    echo -e "${YELLOW}→${NC} Formatting partitions..."
    mkfs.fat -F32 ${DISK_P}2
    mkswap ${DISK_P}3
    swapon ${DISK_P}3
    mkfs.ext4 -F ${DISK_P}4

    # Mount filesystems
    echo -e "${YELLOW}→${NC} Mounting filesystems..."
    mount ${DISK_P}4 /mnt
    mkdir -p /mnt/boot
    mount ${DISK_P}2 /mnt/boot
else
    # Partition installation - use existing partitions

    # Unmount partitions if they're already mounted
    echo -e "${YELLOW}→${NC} Checking for mounted partitions..."

    # Check and unmount root partition
    if mount | grep -q "$ROOT_PARTITION"; then
        echo "  $ROOT_PARTITION is currently mounted, unmounting..."
        umount -R $ROOT_PARTITION 2>/dev/null || umount $ROOT_PARTITION
    fi

    # Check and unmount swap partition
    if [ -n "$SWAP_PARTITION" ]; then
        if swapon --show | grep -q "$SWAP_PARTITION"; then
            echo "  $SWAP_PARTITION is currently active as swap, deactivating..."
            swapoff $SWAP_PARTITION
        fi
        if mount | grep -q "$SWAP_PARTITION"; then
            echo "  $SWAP_PARTITION is currently mounted, unmounting..."
            umount $SWAP_PARTITION
        fi
    fi

    # Check and unmount EFI partition (but only if it's mounted somewhere other than where we need it)
    if [ -n "$EFI_PARTITION" ]; then
        if mount | grep -q "$EFI_PARTITION"; then
            echo "  $EFI_PARTITION is currently mounted, unmounting..."
            umount $EFI_PARTITION
        fi
    fi

    echo "  All partitions ready for formatting"

    # Format root partition
    echo -e "${YELLOW}→${NC} Formatting root partition..."
    mkfs.ext4 -F $ROOT_PARTITION

    # Format swap if provided
    if [ -n "$SWAP_PARTITION" ]; then
        echo -e "${YELLOW}→${NC} Formatting swap partition..."
        mkswap $SWAP_PARTITION
        swapon $SWAP_PARTITION
    fi

    # Mount filesystems
    echo -e "${YELLOW}→${NC} Mounting filesystems..."
    mount $ROOT_PARTITION /mnt

    if [ -n "$EFI_PARTITION" ]; then
        # Mount existing EFI partition (don't format it!)
        mkdir -p /mnt/boot
        mount $EFI_PARTITION /mnt/boot
        echo "Mounted existing EFI partition at /mnt/boot (not formatted)"
    else
        # No EFI partition - BIOS mode
        mkdir -p /mnt/boot
        echo "BIOS mode - /boot will be on root partition"
    fi
fi

# Install base system
echo -e "${YELLOW}→${NC} Installing base system..."
if [ "$INSTALL_MODE" = "online" ]; then
    # Online: Use pacstrap to download and install
    echo "  Downloading and installing packages from internet..."
    if ! pacstrap /mnt base base-devel linux linux-firmware \
        vim networkmanager sudo git openssh rsync; then
        echo -e "${RED}✗${NC} Failed to install packages!"
        echo "This could mean:"
        echo "  - No internet connection (try manual ping test)"
        echo "  - Package mirror is down"
        echo "  - Network issues in VM"
        echo ""
        echo "Try:"
        echo "  1. Check network: ping -c 3 archlinux.org"
        echo "  2. Restart NetworkManager: systemctl restart NetworkManager"
        echo "  3. Re-run install-arch"
        exit 1
    fi
else
    # Offline: Use local packages
    echo "  Using offline package cache..."
    if [ -d "$SCRIPT_DIR/packages" ]; then
        # Set up local repo
        mkdir -p /mnt/var/cache/pacman/pkg
        cp "$SCRIPT_DIR/packages"/*.pkg.tar.zst /mnt/var/cache/pacman/pkg/

        # Install from cache
        pacman -r /mnt -S --noconfirm --cachedir /mnt/var/cache/pacman/pkg \
            base base-devel linux linux-firmware \
            vim networkmanager sudo git openssh rsync
    else
        echo -e "${RED}✗${NC} Offline installation requires offline packages!"
        echo ""
        echo "This ISO does not include offline packages."
        echo ""
        echo "Options:"
        echo "  1. Connect to internet and re-run install-arch"
        echo "  2. Build an offline ISO with packages included"
        echo ""
        echo "To build offline ISO:"
        echo "  bash create-offline-cache.sh"
        echo "  bash package-creator.sh"
        echo "  cd customIso_nov19 && bash build-custom-iso.sh"
        echo ""
        exit 1
    fi
fi

# Generate fstab
echo -e "${YELLOW}→${NC} Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Configure system in chroot
echo -e "${YELLOW}→${NC} Configuring system..."
arch-chroot /mnt /bin/bash << CHROOT_EOF
# Timezone
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

# Root password
echo "root:$PASSWORD" | chpasswd

# Create user
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

# Enable sudo for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Detect boot mode (UEFI or BIOS)
if [ -d /sys/firmware/efi/efivars ]; then
    BOOT_MODE="UEFI"
    echo "Detected UEFI boot mode"
else
    BOOT_MODE="BIOS"
    echo "Detected BIOS boot mode"
fi

# Get root partition UUID
if [ "$PARTITION_MODE" = "full" ]; then
    ROOT_PART_DEV="${DISK_P}4"
else
    ROOT_PART_DEV="$ROOT_PARTITION"
fi

ROOT_UUID=\$(blkid -s UUID -o value \$ROOT_PART_DEV)
echo "Root partition: \$ROOT_PART_DEV"
echo "Root UUID: \$ROOT_UUID"

if [ -z "\$ROOT_UUID" ]; then
    echo "ERROR: Could not determine root partition UUID!"
    echo "Partition \$ROOT_PART_DEV may not exist or is not formatted"
    exit 1
fi

# Install bootloader based on boot mode
if [ "\$BOOT_MODE" = "UEFI" ]; then
    echo "Installing systemd-boot bootloader (UEFI)..."
    bootctl install
    if [ \$? -ne 0 ]; then
        echo "ERROR: Bootloader installation failed!"
        echo "Check if /boot is mounted correctly"
        mount | grep /boot
        exit 1
    fi

    # Create systemd-boot entries
    cat > /boot/loader/entries/arch.conf << EOF
title   CustomOS (Arch Linux)
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=\$ROOT_UUID rw quiet splash loglevel=3
EOF

    cat > /boot/loader/entries/arch-fallback.conf << EOF
title   CustomOS (Arch Linux - Fallback)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options root=UUID=\$ROOT_UUID rw
EOF

    cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 5
console-mode keep
editor no
EOF

    echo "systemd-boot installed successfully"

else
    echo "Installing GRUB bootloader (BIOS)..."
    pacman -S --needed --noconfirm grub

    # Install GRUB to MBR
    grub-install --target=i386-pc --recheck $DISK
    if [ \$? -ne 0 ]; then
        echo "ERROR: GRUB installation failed!"
        exit 1
    fi

    # Generate GRUB config
    grub-mkconfig -o /boot/grub/grub.cfg
    if [ \$? -ne 0 ]; then
        echo "ERROR: GRUB config generation failed!"
        exit 1
    fi

    echo "GRUB installed successfully"
fi

# Verify kernel is installed
if [ ! -f /boot/vmlinuz-linux ]; then
    echo "ERROR: Kernel not found in /boot!"
    exit 1
fi

echo "Bootloader installation verified"
ls -la /boot/

# Enable NetworkManager and SSH
systemctl enable NetworkManager
systemctl enable sshd

# Detect if running in VirtualBox and configure accordingly
if lspci | grep -i "virtualbox" &>/dev/null || dmesg | grep -i "vbox" &>/dev/null; then
    echo "VirtualBox detected - Will configure guest additions after reboot"
    # Mark for post-install VirtualBox setup
    touch /var/lib/vbox-detected
fi

# Install VirtualBox Guest Additions if in VirtualBox (best effort)
if [ -f /var/lib/vbox-detected ]; then
    pacman -S --needed --noconfirm virtualbox-guest-utils || true
    systemctl enable vboxservice || true
fi

CHROOT_EOF

# Copy custom setup to new system
echo -e "${YELLOW}→${NC} Copying custom setup..."
cp -r "$SCRIPT_DIR" /mnt/home/$USERNAME/custom-setup
arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME/custom-setup

# Set up auto-run on first login (use both .zprofile and .bashrc for compatibility)
cat >> /mnt/home/$USERNAME/.bash_profile << 'EOF'
# Auto-run custom setup on first login
if [ ! -f ~/.setup-complete ]; then
    if [ -f ~/custom-setup/post-install.sh ]; then
        echo "Running CustomOS setup..."
        cd ~/custom-setup
        bash post-install.sh
        touch ~/.setup-complete
    fi
fi
EOF

cat >> /mnt/home/$USERNAME/.zprofile << 'EOF'
# Auto-run custom setup on first login
if [ ! -f ~/.setup-complete ]; then
    if [ -f ~/custom-setup/post-install.sh ]; then
        echo "Running CustomOS setup..."
        cd ~/custom-setup
        bash post-install.sh
        touch ~/.setup-complete
    fi
fi
EOF

# Also create a systemd user service for more reliability
mkdir -p /mnt/home/$USERNAME/.config/systemd/user
cat > /mnt/home/$USERNAME/.config/systemd/user/customos-setup.service << 'EOF'
[Unit]
Description=CustomOS First-Time Setup
ConditionPathExists=%h/custom-setup/post-install.sh
ConditionPathExists=!%h/.setup-complete

[Service]
Type=oneshot
ExecStart=/bin/bash %h/custom-setup/post-install.sh
ExecStartPost=/usr/bin/touch %h/.setup-complete

[Install]
WantedBy=default.target
EOF

# Enable the service
arch-chroot /mnt systemctl --user --global enable customos-setup.service 2>/dev/null || true

arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME/.bash_profile /home/$USERNAME/.zprofile /home/$USERNAME/.config 2>/dev/null || true

# Unmount
echo -e "${YELLOW}→${NC} Unmounting filesystems..."
umount -R /mnt

# Done!
clear
echo -e "${GREEN}"
cat << "EOF"
╔═════════════════════════════════════════════════════════════╗
║                                                             ║
║   ███████╗██╗   ██╗ ██████╗ ██████╗███████╗███████╗███████╗ ║
║   ██╔════╝██║   ██║██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝ ║
║   ███████╗██║   ██║██║     ██║     █████╗  ███████╗███████╗ ║
║   ╚════██║██║   ██║██║     ██║     ██╔══╝  ╚════██║╚════██║ ║
║   ███████║╚██████╔╝╚██████╗╚██████╗███████╗███████║███████║ ║
║   ╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝╚══════╝╚══════╝╚══════╝ ║
║                                                             ║
║             Base Installation Complete!                     ║
║                                                             ║
╚═════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${GREEN}✓${NC} Base Arch Linux installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Remove installation media"
echo "  2. Reboot: type 'reboot'"
echo "  3. Login as: $USERNAME"
echo "  4. Custom Hyprland setup will auto-install on first login"
echo ""
echo -e "${YELLOW}If auto-install doesn't run, manually execute:${NC}"
echo -e "${GREEN}  cd ~/custom-setup && bash post-install.sh${NC}"
echo ""
echo -e "${BLUE}Press ENTER to reboot now (or Ctrl+C to stay in live environment)${NC}"
read
reboot
