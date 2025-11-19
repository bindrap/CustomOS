#!/bin/bash

# Minimal Arch Linux ISO Builder
# Barebones ISO that just boots and installs basic Arch
# No customizations - just working base system

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║  Minimal Arch Linux ISO Builder               ║
║  Barebones - No Customizations                ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

ISO_NAME="minimal-arch"
ISO_VERSION=$(date +%Y%m%d-%H%M)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/iso-output"
CACHE_DIR="$HOME/.cache/archiso-minimal"
IMAGE_NAME="archiso-builder"

echo ""
echo -e "${YELLOW}This builds a MINIMAL Arch ISO${NC}"
echo "Output: $OUTPUT_DIR/${ISO_NAME}-${ISO_VERSION}.iso"
echo ""
read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    exit 0
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗${NC} Docker not found!"
    echo "Please install Docker and try again."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}✗${NC} Docker daemon not running!"
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker is ready"

# Check for cached image
if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    echo -e "${YELLOW}⚠${NC} No cached image, will use archlinux:latest"
    DOCKER_IMAGE="archlinux:latest"
else
    echo -e "${GREEN}✓${NC} Using cached image"
    DOCKER_IMAGE="$IMAGE_NAME"
fi

mkdir -p "$OUTPUT_DIR"
mkdir -p "$CACHE_DIR"

echo ""
echo -e "${BLUE}Building minimal ISO in Docker...${NC}"
echo ""

docker run --rm --privileged \
    -v "$SCRIPT_DIR:/workspace" \
    -v "$CACHE_DIR:/var/cache/pacman/pkg" \
    -w /workspace \
    "$DOCKER_IMAGE" \
    bash -c '
set -euo pipefail

# Setup if using base image
if [ "'"$DOCKER_IMAGE"'" = "archlinux:latest" ]; then
    echo "→ Setting up Arch environment..."
    pacman -Sy --noconfirm reflector
    reflector --country US,CA --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 10/" /etc/pacman.conf
    pacman -Sy --noconfirm
    pacman -S --needed --noconfirm archiso
fi

ISO_NAME="'"$ISO_NAME"'"
ISO_VERSION="'"$ISO_VERSION"'"
WORK_DIR="/tmp/archiso-minimal"
ISO_DIR="$WORK_DIR/iso-build"
OUTPUT_DIR="/workspace/iso-output"

echo "→ Cleaning old work..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

echo "→ Copying archiso releng profile..."
cp -r /usr/share/archiso/configs/releng "$ISO_DIR"
cd "$ISO_DIR"

echo "→ Creating minimal installer..."
mkdir -p airootfs/root

# Create simple install script
cat > airootfs/root/install-minimal.sh << "EOFINSTALL"
#!/bin/bash

set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

clear
echo -e "${BLUE}"
cat << "BANNER"
╔════════════════════════════════════════════════╗
║  Minimal Arch Linux Installer                 ║
╚════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}✗${NC} This script must be run as root"
   exit 1
fi

echo ""
echo -e "${YELLOW}This installs a BASIC Arch Linux system${NC}"
echo "No desktop environment - just base system"
echo ""

# Show disks
echo "Available disks:"
lsblk -d -o NAME,SIZE,TYPE | grep disk
echo ""

read -p "Target disk (e.g., sda, vda): " DISK_NAME
DISK="/dev/$DISK_NAME"

if [ ! -b "$DISK" ]; then
    echo -e "${RED}✗${NC} Disk not found: $DISK"
    exit 1
fi

echo -e "${RED}WARNING: All data on $DISK will be ERASED!${NC}"
read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    exit 0
fi

read -p "Hostname: " HOSTNAME
read -p "Username: " USERNAME
read -sp "Password: " PASSWORD
echo ""
read -sp "Confirm password: " PASSWORD2
echo ""

if [ "$PASSWORD" != "$PASSWORD2" ]; then
    echo -e "${RED}✗${NC} Passwords do not match"
    exit 1
fi

echo ""
echo -e "${GREEN}Starting installation...${NC}"
echo ""

# Determine partition naming
if [[ $DISK == *"nvme"* ]] || [[ $DISK == *"mmcblk"* ]]; then
    PART_PREFIX="${DISK}p"
else
    PART_PREFIX="${DISK}"
fi

# Partition disk
echo -e "${YELLOW}→${NC} Partitioning $DISK..."
sgdisk -Z "$DISK"
sgdisk -n 1:0:+512M -t 1:ef00 "$DISK"  # EFI
sgdisk -n 2:0:+2G -t 2:8200 "$DISK"    # Swap
sgdisk -n 3:0:0 -t 3:8300 "$DISK"      # Root
sleep 2

# Format
echo -e "${YELLOW}→${NC} Formatting partitions..."
mkfs.fat -F32 "${PART_PREFIX}1"
mkswap "${PART_PREFIX}2"
swapon "${PART_PREFIX}2"
mkfs.ext4 -F "${PART_PREFIX}3"

# Mount
echo -e "${YELLOW}→${NC} Mounting filesystems..."
mount "${PART_PREFIX}3" /mnt
mkdir -p /mnt/boot
mount "${PART_PREFIX}1" /mnt/boot

# Install base system
echo -e "${YELLOW}→${NC} Installing base system (this takes 5-10 minutes)..."
pacstrap /mnt base linux linux-firmware vim networkmanager sudo

# Generate fstab
echo -e "${YELLOW}→${NC} Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Configure system
echo -e "${YELLOW}→${NC} Configuring system..."
arch-chroot /mnt /bin/bash << CHROOT
# Timezone
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS

# Root password
echo "root:$PASSWORD" | chpasswd

# Create user
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

# Sudo
sed -i "s/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

# Install bootloader
bootctl install

# Boot entry
ROOT_UUID=\$(blkid -s UUID -o value ${PART_PREFIX}3)
cat > /boot/loader/entries/arch.conf << BOOTENTRY
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=\$ROOT_UUID rw
BOOTENTRY

# Fallback entry
cat > /boot/loader/entries/arch-fallback.conf << BOOTENTRY
title   Arch Linux (Fallback)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options root=UUID=\$ROOT_UUID rw
BOOTENTRY

# Bootloader config
cat > /boot/loader/loader.conf << LOADERCONF
default arch.conf
timeout 5
console-mode keep
editor no
LOADERCONF

# Enable NetworkManager
systemctl enable NetworkManager

CHROOT

# Unmount
echo -e "${YELLOW}→${NC} Unmounting..."
umount -R /mnt

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Installation Complete!                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓${NC} Minimal Arch Linux installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Remove installation media"
echo "  2. Type: reboot"
echo "  3. Login as: $USERNAME"
echo "  4. Install desktop environment if desired"
echo ""
read -p "Press ENTER to reboot..."
reboot
EOFINSTALL

chmod +x airootfs/root/install-minimal.sh

# Create welcome message
cat > airootfs/root/.zshrc << "EOFZSH"
cat << "WELCOME"

╔════════════════════════════════════════════════╗
║  Minimal Arch Linux ISO                        ║
║  Barebones Installation                        ║
╠════════════════════════════════════════════════╣
║                                                ║
║  To install: install-minimal                   ║
║                                                ║
║  This installs a basic Arch Linux system:     ║
║    • Base system packages                     ║
║    • NetworkManager                           ║
║    • User account                             ║
║    • No desktop environment                   ║
║                                                ║
╚════════════════════════════════════════════════╝

WELCOME
echo ""
echo "Available disks:"
lsblk -d -o NAME,SIZE,TYPE | grep disk || true
echo ""
EOFZSH

# Clean up .zlogin
cat > airootfs/root/.zlogin << "EOFZLOGIN"
# fix for screen readers
if grep -Fqa "accessibility=" /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi
EOFZLOGIN

# Create install command
mkdir -p airootfs/usr/local/bin
cat > airootfs/usr/local/bin/install-minimal << "EOFCMD"
#!/bin/bash
exec /root/install-minimal.sh
EOFCMD
chmod +x airootfs/usr/local/bin/install-minimal

# Add minimal packages to live environment
echo "→ Adding minimal packages..."
cat >> packages.x86_64 << "EOFPKG"
# Minimal additions
vim
EOFPKG

# Set permissions
cat >> profiledef.sh << "EOFPERMS"

# File permissions
file_permissions=(
  ["/usr/local/bin/install-minimal"]="0:0:755"
  ["/root/install-minimal.sh"]="0:0:755"
  ["/root"]="0:0:750"
)
EOFPERMS

# Customize ISO label
ISO_LABEL="${ISO_NAME^^}"
ISO_VER="${ISO_VERSION//-/}"
sed -i "s/ARCH_[0-9]*/${ISO_LABEL}_${ISO_VER}/" profiledef.sh

# Build ISO
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║  Building ISO (5-10 minutes)                   ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

mkarchiso -v -w "$WORK_DIR/work" -o "$OUTPUT_DIR" "$ISO_DIR"

# Check result
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║  ISO Build Complete!                           ║"
    echo "╚════════════════════════════════════════════════╝"
    echo ""
    echo "ISO: $ISO_FILE"
    echo "Size: $ISO_SIZE"
    echo ""
else
    echo ""
    echo "✗ ISO build failed!"
    exit 1
fi
'

# Check if build succeeded
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Minimal ISO Build Complete!                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} ISO created successfully!"
    echo ""
    echo "Details:"
    echo "  File: $ISO_FILE"
    echo "  Size: $ISO_SIZE"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Test in VirtualBox:"
    echo "     - Create new VM (Type: Linux, Version: Arch Linux 64-bit)"
    echo "     - RAM: 2GB, Disk: 20GB"
    echo "     - Graphics: VMSVGA"
    echo "     - Attach this ISO"
    echo ""
    echo "  2. Boot the VM"
    echo ""
    echo "  3. Run: install-minimal"
    echo ""
    echo "  4. Follow prompts (takes 5-10 minutes)"
    echo ""
    echo "  5. Reboot and login"
    echo ""
    echo -e "${YELLOW}This is BAREBONES - no desktop, just working Arch base${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}✗ ISO build failed!${NC}"
    exit 1
fi
