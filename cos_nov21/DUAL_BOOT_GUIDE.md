# CustomOS Dual Boot Installation Guide

This guide explains how to install CustomOS alongside another operating system (dual boot).

## New Features

CustomOS now includes:
1. **WiFi Setup Script** - Easy WiFi connection during installation
2. **Partition Helper** - Tool to prepare your disk for dual boot
3. **Dual Boot Installer** - Install to a specific partition without wiping the disk

## Quick Start for Dual Boot Installation

### Step 1: Connect to WiFi (Optional)

If you need internet during installation:

```bash
bash wifi-setup.sh
```

Or use the one-liner:
```bash
iwctl --passphrase YOUR_PASSWORD station wlan0 connect YOUR_SSID
```

### Step 2: Prepare Your Disk

Use the partition helper to create space for CustomOS:

```bash
bash partition-helper.sh
```

Select option 4 for **Guided Dual Boot Partitioning**.

This will:
- Show your current disk layout
- Help you shrink an existing partition
- Create a new partition for CustomOS
- Format the new partition as ext4

**Example:**
- Current: `/dev/sda2` is 931GB with Windows
- Shrink to: 831GB (frees up 100GB)
- Create: `/dev/sda3` as 100GB for CustomOS

### Step 3: Install CustomOS

Run the installer:

```bash
bash install-auto.sh
```

When prompted:
1. Select **Option 2** (Partition installation for dual boot)
2. Enter your root partition (e.g., `sda3`)
3. Enter existing EFI partition if you have one (e.g., `sda2` for UEFI systems)
4. Optionally configure swap
5. Follow the prompts to complete installation

## Detailed Instructions

### WiFi Setup Options

The `wifi-setup.sh` script provides three methods:

1. **Quick Setup** - Automated connection with SSID and password
2. **Interactive Setup** - Step-by-step guided process
3. **Manual Instructions** - Shows commands for manual setup

### Partition Helper Options

The `partition-helper.sh` script provides:

1. **View disk layout** - Shows current partitions
2. **Shrink partition** - Reduce size of existing partition
3. **Create partition** - Make new partition in free space
4. **Guided partitioning** - Complete dual boot setup
5. **Manual instructions** - Commands for advanced users

### Installation Types

The installer now supports two modes:

#### Full Disk Installation (Option 1)
- Erases entire disk
- Creates new partition table
- Partitions: BIOS boot (1MB), EFI (512MB), Swap (4GB), Root (remaining)
- Use this for dedicated CustomOS machines

#### Partition Installation (Option 2)
- Installs to existing partition
- Preserves other partitions and operating systems
- Can share EFI partition with existing OS
- Use this for dual boot setups

## Example Dual Boot Setup

### Scenario: Install CustomOS alongside Windows

1. **Current Setup:**
   ```
   /dev/sda1 - EFI System (100MB) - Windows bootloader
   /dev/sda2 - Windows (931GB)
   ```

2. **Prepare Disk:**
   ```bash
   bash partition-helper.sh
   # Select option 4 (Guided)
   # Choose sda
   # Select partition 2 to shrink
   # Allocate 100GB for CustomOS
   ```

3. **After Partitioning:**
   ```
   /dev/sda1 - EFI System (100MB) - Shared
   /dev/sda2 - Windows (831GB) - Resized
   /dev/sda3 - CustomOS (100GB) - New
   ```

4. **Install CustomOS:**
   ```bash
   bash install-auto.sh
   # Select option 2 (Partition installation)
   # Root partition: sda3
   # EFI partition: sda1 (share with Windows)
   # No swap or create separate if desired
   ```

5. **Result:**
   - CustomOS bootloader (systemd-boot or GRUB) installed
   - Boot menu shows both Windows and CustomOS
   - Both systems coexist peacefully

## Manual Partitioning with parted

For advanced users who prefer manual control:

```bash
# 1. Check current layout
lsblk
sudo parted /dev/sda print free

# 2. Check filesystem
sudo e2fsck -f /dev/sda2

# 3. Resize filesystem
sudo resize2fs /dev/sda2 831G

# 4. Resize and create partition
sudo parted /dev/sda
(parted) print
(parted) resizepart 2 831GB
(parted) mkpart primary ext4 831GB 931GB
(parted) print
(parted) quit

# 5. Format new partition
sudo mkfs.ext4 /dev/sda3

# 6. Verify
lsblk
```

## WiFi Manual Setup

For reference, here are the manual WiFi commands:

```bash
# Interactive method
iwctl
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect YOUR_SSID
exit

# One-liner method
iwctl --passphrase YOUR_PASSWORD station wlan0 connect YOUR_SSID

# Verify connection
ping -c 3 google.com
```

## Troubleshooting

### WiFi Issues
- If `wlan0` doesn't exist, check `iwctl device list` for your device name
- Some devices are named `wlp2s0`, `wlp3s0`, etc.
- SSID is case-sensitive
- Use quotes if SSID or password contains spaces

### Partitioning Issues
- Always backup important data before resizing
- Run `e2fsck` before resizing ext4 partitions
- Make sure to resize filesystem before resizing partition
- Leave some free space (1-2GB) as buffer

### Installation Issues
- For dual boot, ensure you have an existing EFI partition (UEFI systems)
- BIOS systems can use GRUB without EFI partition
- Make sure target partition is large enough (minimum 20GB recommended)
- Verify partitions exist with `lsblk` before installation

## Important Notes

1. **Backups:** Always backup important data before partitioning
2. **EFI Partition:** Can be shared between multiple operating systems
3. **Boot Order:** May need to configure UEFI boot order in BIOS
4. **Swap:** Optional but recommended for systems with <8GB RAM
5. **Disk Names:**
   - SATA/SSD: `/dev/sda`, `/dev/sdb`, etc.
   - NVMe: `/dev/nvme0n1`, `/dev/nvme0n2`, etc.
   - Partitions: Add number (sda1, sda2) or `p` + number (nvme0n1p1, nvme0n1p2)

## Post-Installation

After installation:
1. Remove installation media
2. Reboot system
3. Select CustomOS from boot menu
4. Login with your created user
5. Hyprland desktop environment will auto-install on first login

## Support

For issues or questions:
- Check the main README.md for general information
- Review OPTIMIZATIONS.md for system tuning
- Examine the scripts for detailed implementation
