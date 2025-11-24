# Safe Dual Boot Setup Guide for CustomOS

This guide explains the **SAFEST** way to set up dual boot without risking data corruption or system damage.

## ⚠️ Important Safety Warning

**DO NOT** use automated partition shrinking scripts on your main system. Always use the native OS tools for shrinking partitions, as they are tested and safer.

## Prerequisites

1. **Backup your data** - Cannot stress this enough
2. At least 50-100GB free space on your disk (depends on your needs)
3. Windows 10/11 or another OS already installed (for dual boot)
4. CustomOS ISO on USB drive

## Safe Dual Boot Workflow

### Phase 1: Shrink Existing Partition (Use Native OS Tools)

#### If you have Windows:

1. **Boot into Windows**
2. Press `Win + X` and select **Disk Management**
3. Right-click on the partition you want to shrink (usually C: drive)
4. Select **"Shrink Volume..."**
5. Enter the amount to shrink:
   - For 100GB CustomOS installation, enter: `102400` MB
   - For 50GB, enter: `51200` MB
6. Click **"Shrink"**
7. You'll now see "Unallocated Space" in Disk Management
8. **Reboot and verify Windows still works**

**Screenshot locations in Disk Management:**
- Start → Right-click "This PC" → Manage → Disk Management
- Or: `diskmgmt.msc`

#### If you have Linux:

1. **Boot from Live USB** (do NOT shrink from running system!)
2. Use **GParted** (graphical) or follow manual instructions below
3. With GParted:
   - Select partition to shrink
   - Right-click → Resize/Move
   - Drag to shrink partition
   - Click Apply (green checkmark)
   - Wait for completion
4. Reboot and verify your Linux still works

### Phase 2: Connect to WiFi

**On Arch ISO (Pre-installation):**

```bash
bash wifi-setup.sh
# Choose option 1 for quick setup
# Enter your WiFi SSID and password
```

**After base install (Post-install but before Hyprland):**

```bash
# NetworkManager will be available
bash wifi-setup.sh
# Script auto-detects and uses nmcli
```

**Manual WiFi (ISO environment):**
```bash
iwctl --passphrase "YOUR_PASSWORD" station wlan0 connect "YOUR_SSID"
```

**Manual WiFi (Post-install):**
```bash
nmcli device wifi list
nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"
```

### Phase 3: Verify Free Space

Boot from CustomOS ISO and run:

```bash
bash partition-helper-safe.sh
# Select option 1 to view disk information
```

Look for "Free Space" in the output. You should see the unallocated space you created.

Example output:
```
Number  Start   End     Size    File system  Name     Flags
 1      1.05MB  106MB   105MB   fat32        EFI      boot, esp
 2      106MB   850GB   850GB   ntfs         Windows  msftdata
        850GB   950GB   100GB   Free Space
```

### Phase 4: Create Partition in Free Space

```bash
bash partition-helper-safe.sh
# Select option 2
```

Follow prompts:
- Enter disk: `sda` (or your disk name)
- Confirm you see free space: `yes`
- Enter start position: `850` (from the Free Space line)
- Enter end position: `950` (from the Free Space line)
- Confirm: `YES`

This creates a **NEW** partition without touching existing ones.

### Phase 5: Install CustomOS

```bash
bash install-auto.sh
```

Setup:
1. Select installation type: **2** (Partition installation - dual boot)
2. Enter root partition: `sda3` (or whatever was just created)
3. Existing EFI partition: **yes**
4. Enter EFI partition: `sda1` (usually the small FAT32 partition)
5. Use swap: **no** (or yes if you have a swap partition)
6. Enter hostname, username, password
7. Confirm and install

### Phase 6: Post-Installation

1. Remove installation media
2. Reboot
3. You should see boot menu with:
   - CustomOS (Arch Linux)
   - Windows Boot Manager (or other OS)
4. Select CustomOS
5. Login with your username
6. Hyprland will auto-install on first login

## Troubleshooting

### "No free space" in partition-helper-safe.sh

- You didn't shrink the partition yet
- Use Windows Disk Management or GParted to shrink first
- Reboot after shrinking and try again

### WiFi not working in ISO

```bash
# Check if wireless device exists
ip link show

# If you see wlan0 or wlp2s0, etc:
bash wifi-setup.sh

# Try manual method:
iwctl
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "YOUR_SSID"
exit
```

### WiFi not working after install (before Hyprland)

```bash
# Start NetworkManager if not running
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager

# Then connect
nmcli device wifi list
nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"

# Or use the script
bash ~/custom-setup/wifi-setup.sh
```

### Partition creation fails

- Ensure you're using the FREE SPACE boundaries
- Check start < end
- Make sure values match what `parted print free` shows
- Don't use partition numbers that already exist

### Boot into Windows instead of boot menu

- Enter BIOS/UEFI settings (F2, F12, DEL during boot)
- Change boot order to prioritize CustomOS/Linux
- Or set Linux bootloader as default

### Can't find EFI partition

```bash
# List all partitions
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT

# Look for small (100-512MB) partition with FSTYPE=vfat
# Usually sda1 or nvme0n1p1
```

## Why This Method is Safe

1. **Uses native OS tools** - Windows Disk Management is tested by millions
2. **No automated shrinking** - Avoids calculation errors
3. **Creates partition in free space** - Doesn't modify existing partitions
4. **Validates free space exists** - Won't proceed if no free space
5. **Multiple confirmation steps** - Prevents accidents

## What NOT to Do

❌ **Don't** use automated partition shrinking scripts from unknown sources
❌ **Don't** shrink partitions while they're mounted
❌ **Don't** skip the filesystem check (e2fsck) when shrinking manually
❌ **Don't** guess partition boundaries - use exact values from `parted`
❌ **Don't** format the EFI partition - share it with existing OS
❌ **Don't** proceed if you don't understand what's happening - ask for help!

## Quick Reference Commands

**View disk layout:**
```bash
lsblk
sudo parted /dev/sda print free
```

**Connect WiFi (ISO):**
```bash
iwctl --passphrase "PASS" station wlan0 connect "SSID"
```

**Connect WiFi (Post-install):**
```bash
nmcli device wifi connect "SSID" password "PASS"
```

**Check WiFi status:**
```bash
nmcli device status
ip addr show
ping -c 3 google.com
```

## Example Complete Workflow

```bash
# 1. In Windows: Shrink C: drive by 100GB using Disk Management
# 2. Reboot, boot from CustomOS ISO

# 3. Connect to WiFi
bash wifi-setup.sh
# Option 1, enter SSID and password

# 4. Check free space
bash partition-helper-safe.sh
# Option 1 - verify you see 100GB free space

# 5. Create partition
bash partition-helper-safe.sh
# Option 2 - create partition in free space
# Start: 850, End: 950 (example values)

# 6. Install CustomOS
bash install-auto.sh
# Option 2 - partition install
# Root: sda3 (newly created)
# EFI: sda1 (existing)
# No swap

# 7. Reboot, select CustomOS, login
# 8. Hyprland installs automatically
```

## Need Help?

If you run into issues:
1. **Stop immediately** - Don't proceed if you're unsure
2. Take a screenshot of the error
3. Run `lsblk` and `sudo parted /dev/sda print free`
4. Note which step you're on
5. Ask for help with the specific error message

Remember: **It's better to ask than to break your system!**
