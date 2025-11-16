# Complete Guide: Creating Your Reusable Custom Arch Linux ISO

This guide shows you how to create a custom Arch Linux ISO that installs your complete setup with one command.

## 🎯 Goal

Create a bootable USB/ISO that:
1. Installs base Arch Linux
2. Automatically installs your custom Hyprland setup
3. Boots into a fully configured system
4. Can be used on any new computer

## 📋 Quick Summary

```
Package everything → Create ISO → Boot on new PC → One command → Done!
```

---

## Part 1: Package Your Custom Setup

### Step 1: Run the Package Creator

```bash
# Make the script executable
chmod +x /home/claude/package-creator.sh

# Run it
bash /home/claude/package-creator.sh
```

This creates:
- `custom-arch-setup/` - Full directory with all configs
- `parteek-custom-arch.tar.gz` - Compressed package

### Step 2: Add Your Wallpapers

```bash
# Add your wallpapers to the package
cp ~/Pictures/wallpapers/* custom-arch-setup/wallpapers/
```

### Step 3: Test the Package (Recommended)

```bash
# Extract to a test location
mkdir ~/test-install
cd ~/test-install
tar -xzf ~/parteek-custom-arch.tar.gz
cd custom-arch-setup

# Verify all files are there
ls -la
ls -la dotfiles/hypr/
ls -la dotfiles/waybar/
```

---

## Part 2: Choose Your Deployment Method

You have 3 options:

### 🔷 Option A: GitHub Repository (Easiest to Update)

**Best for:** Regular updates, multiple machines, version control

```bash
cd ~/custom-arch-setup

# Initialize git
git init
git add .
git commit -m "Initial commit: Custom Arch setup"

# Create repo on GitHub, then:
git remote add origin https://github.com/yourusername/custom-arch-setup.git
git push -u origin main
```

**Deploy on new machine:**
```bash
# After base Arch install
git clone https://github.com/yourusername/custom-arch-setup.git
cd custom-arch-setup
./install.sh
```

**One-liner install:**
```bash
curl -sL https://raw.githubusercontent.com/yourusername/custom-arch-setup/main/install.sh | bash
```

---

### 🔷 Option B: USB Drive (No Internet Needed)

**Best for:** Offline installs, local deployment

```bash
# Copy tarball to USB
cp ~/parteek-custom-arch.tar.gz /path/to/usb/

# Or copy entire directory
cp -r ~/custom-arch-setup /path/to/usb/
```

**Deploy on new machine:**
```bash
# After base Arch install
mount /dev/sdb1 /mnt/usb
cp /mnt/usb/parteek-custom-arch.tar.gz ~
cd ~
tar -xzf parteek-custom-arch.tar.gz
cd custom-arch-setup
./install.sh
```

---

### 🔷 Option C: Custom Arch ISO (Most Automated)

**Best for:** Complete automation, professional deployment

This creates a bootable ISO with your setup pre-loaded.

#### Step 1: Install archiso

```bash
sudo pacman -S archiso
```

#### Step 2: Copy and Customize Profile

```bash
# Copy the releng profile
cp -r /usr/share/archiso/configs/releng ~/archlive
cd ~/archlive
```

#### Step 3: Add Your Setup to ISO

```bash
# Create directory in the ISO
mkdir -p airootfs/root/custom-setup

# Copy your package
cp -r ~/custom-arch-setup/* airootfs/root/custom-setup/
```

#### Step 4: Customize Welcome Message

```bash
# Create custom .zshrc for live environment
cat > airootfs/root/.zshrc << 'EOF'
# Custom welcome message
cat << 'WELCOME'
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   ██████╗  █████╗ ██████╗ ████████╗███████╗███████╗██╗  ║
║   ██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔════╝██║  ║
║   ██████╔╝███████║██████╔╝   ██║   █████╗  █████╗  ██║  ║
║   ██╔═══╝ ██╔══██║██╔══██╗   ██║   ██╔══╝  ██╔══╝  ██║  ║
║   ██║     ██║  ██║██║  ██║   ██║   ███████╗███████╗██║  ║
║   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ║
║                                                          ║
║        Custom Arch Linux - Hyprland Edition              ║
║                    By Parteek                            ║
║                                                          ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  INSTALLATION STEPS:                                     ║
║                                                          ║
║  1. Install base Arch (use archinstall or manual)       ║
║  2. After first boot, run:                               ║
║                                                          ║
║     cd /root/custom-setup                                ║
║     ./install.sh                                         ║
║                                                          ║
║  3. Reboot and enjoy!                                    ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
WELCOME

# Auto-show disk info
lsblk
echo ""
echo "Ready to install Arch Linux!"
echo "Type 'archinstall' for guided installation"
EOF
```

#### Step 5: Add Custom Packages (Optional)

```bash
# Edit packages list
vim airootfs/root/packages.x86_64

# Add these to the file:
# hyprland
# waybar
# kitty
# wofi
# etc.
```

#### Step 6: Build the ISO

```bash
# Build ISO (requires ~10GB space)
sudo mkarchiso -v -w work -o out ~/archlive

# ISO will be created in ~/archlive/out/
```

#### Step 7: Write ISO to USB

```bash
# Find your USB device
lsblk

# Write ISO (replace /dev/sdX with your USB)
sudo dd if=~/archlive/out/archlinux-*.iso of=/dev/sdX bs=4M status=progress
sudo sync
```

---

## Part 3: Complete Installation Workflow

### For GitHub Method:

```bash
# 1. Boot Arch ISO (standard)
# 2. Install base Arch (your base install script or archinstall)
# 3. Reboot into new system
# 4. Run:

git clone https://github.com/yourusername/custom-arch-setup.git
cd custom-arch-setup
./install.sh

# 5. Reboot
# 6. Done! Hyprland starts automatically
```

### For Custom ISO Method:

```bash
# 1. Boot your custom ISO
# 2. Install base Arch
# 3. Reboot
# 4. Run:

cd /root/custom-setup
./install.sh

# 5. Reboot
# 6. Done!
```

---

## Part 4: Integrated Installation Script

Create a complete automation script that does base install + custom setup:

```bash
#!/bin/bash
# complete-install.sh
# Complete Arch installation with custom Hyprland setup

echo "Part 1: Base Arch Installation"
# Your base install script here (from earlier)
# ... partition, format, pacstrap, etc. ...

echo "Part 2: Copying custom setup"
# Copy custom setup to new system
cp -r /root/custom-setup /mnt/home/parteek/

echo "Part 3: Auto-run setup on first boot"
# Make it run automatically
cat >> /mnt/home/parteek/.zprofile << 'EOF'
if [ ! -f ~/.setup-complete ]; then
    cd ~/custom-setup
    ./install.sh
    touch ~/.setup-complete
fi
EOF

# Fix permissions
arch-chroot /mnt chown -R parteek:parteek /home/parteek/custom-setup

echo "Installation complete! Reboot now."
```

---

## Part 5: Maintenance & Updates

### Update Your Setup

When you make changes to your live system:

```bash
# 1. Update package
cd ~/custom-arch-setup

# 2. Copy new configs
cp ~/.config/hypr/hyprland.conf dotfiles/hypr/
cp ~/.config/waybar/config dotfiles/waybar/
# etc...

# 3. If using GitHub:
git add .
git commit -m "Updated configs"
git push

# 4. If using USB:
tar -czf parteek-custom-arch.tar.gz custom-arch-setup/
cp parteek-custom-arch.tar.gz /path/to/usb/

# 5. If using ISO:
# Rebuild ISO with updated files
```

### Pull Updates on Other Machines

```bash
# If using GitHub:
cd ~/custom-arch-setup
git pull
./install.sh  # Re-run to update

# If using USB:
# Just copy new tarball and extract
```

---

## Part 6: Advanced: Auto-Install Everything

Create a fully automated installer that needs zero interaction:

```bash
#!/bin/bash
# zero-touch-install.sh

# Automated base Arch install
# Set these variables first:
DISK="/dev/sda"
HOSTNAME="arch-custom"
USERNAME="parteek"

# Auto-partition
sgdisk -Z $DISK
sgdisk -n 1:0:+512M -t 1:ef00 $DISK
sgdisk -n 2:0:+4G -t 2:8200 $DISK
sgdisk -n 3:0:0 -t 3:8300 $DISK

# Auto-format
mkfs.fat -F32 ${DISK}1
mkswap ${DISK}2
swapon ${DISK}2
mkfs.ext4 ${DISK}3

# Auto-mount
mount ${DISK}3 /mnt
mkdir -p /mnt/boot
mount ${DISK}1 /mnt/boot

# Install base
pacstrap /mnt base base-devel linux linux-firmware \
    vim networkmanager sudo git

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Configure system
arch-chroot /mnt /bin/bash << 'CHROOT'
# Timezone
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "$HOSTNAME" > /etc/hostname

# Users
echo "root:root" | chpasswd
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:password" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Bootloader
bootctl install
cat > /boot/loader/entries/arch.conf << 'EOF'
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$(blkid -s UUID -o value ${DISK}3) rw
EOF

# Enable services
systemctl enable NetworkManager
CHROOT

# Copy custom setup
cp -r /root/custom-setup /mnt/home/$USERNAME/

# Auto-run on first boot
cat >> /mnt/home/$USERNAME/.zprofile << 'EOF'
if [ ! -f ~/.setup-complete ]; then
    cd ~/custom-setup && ./install.sh
    touch ~/.setup-complete
fi
EOF

arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME

# Done
umount -R /mnt
echo "Reboot now!"
```

---

## Summary: Recommended Workflow

### For Personal Use:
1. ✅ Use **GitHub method**
2. ✅ Store dotfiles in git repo
3. ✅ Clone and run install.sh on new machines
4. ✅ Total time: ~15 minutes after base install

### For Multiple Deployments:
1. ✅ Create **custom ISO** with setup included
2. ✅ Boot ISO → Install base → Run setup
3. ✅ Total time: ~45 minutes total

### For Maximum Automation:
1. ✅ Combine base install + custom setup in one script
2. ✅ Include in custom ISO
3. ✅ Zero-touch installation
4. ✅ Total time: ~30 minutes, no interaction needed

---

## Files Reference

All these files are in `/home/claude/`:
- `install.sh` - Main installation script
- `package-creator.sh` - Creates the deployable package
- `hyprland.conf` - Hyprland config
- `waybar-config.json` - Waybar modules
- `waybar-style.css` - Waybar styling
- `power-menu.sh` - Power menu script
- `weather.sh` - Weather module
- `ISO-PACKAGING-GUIDE.md` - This guide

---

## Next Steps

1. **Run package creator:**
   ```bash
   bash /home/claude/package-creator.sh
   ```

2. **Choose deployment method:**
   - GitHub (easiest)
   - USB (offline)
   - Custom ISO (full automation)

3. **Test in VM first!**

4. **Deploy to real hardware**

Your custom OS is now fully packaged and ready to deploy anywhere! 🚀
