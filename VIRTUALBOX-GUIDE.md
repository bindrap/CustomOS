# CustomOS VirtualBox Installation Guide

Complete guide for testing and using CustomOS in VirtualBox.

---

## 📋 Table of Contents

1. [VirtualBox Setup](#virtualbox-setup)
2. [Creating the VM](#creating-the-vm)
3. [VM Configuration](#vm-configuration)
4. [Installing CustomOS](#installing-customos)
5. [Post-Installation](#post-installation)
6. [Troubleshooting](#troubleshooting)

---

## 🖥️ VirtualBox Setup

### Prerequisites

- **VirtualBox**: Version 6.1 or later (7.0+ recommended)
- **CustomOS ISO**: Built using `build-iso-docker.sh` or `build-iso.sh`
- **Host Requirements**:
  - 8GB+ RAM (so you can allocate 4GB to VM)
  - 40GB+ free disk space
  - CPU with virtualization enabled (VT-x/AMD-V)

### Enable Virtualization

**Check if virtualization is enabled:**

```bash
# On Linux
egrep -c '(vmx|svm)' /proc/cpuinfo
# If output is > 0, virtualization is enabled

# On Windows (PowerShell as Admin)
systeminfo | findstr /C:"Virtualization"
```

**If disabled, enable in BIOS:**
1. Restart computer
2. Enter BIOS (usually F2, F10, Del, or Esc during boot)
3. Find "Virtualization Technology", "VT-x", or "AMD-V"
4. Enable it
5. Save and exit

---

## 🚀 Creating the VM

### Step 1: Create New Virtual Machine

1. **Open VirtualBox**
2. Click **"New"** button
3. Configure:
   ```
   Name: CustomOS
   Type: Linux
   Version: Arch Linux (64-bit)
   ```
4. Click **Next**

### Step 2: Memory (RAM) Allocation

**Recommended settings:**
- Minimum: 2048 MB (2 GB)
- Recommended: 4096 MB (4 GB)
- Optimal: 8192 MB (8 GB)

**Note:** Don't allocate more than 50% of your host RAM.

### Step 3: Hard Disk

1. Select **"Create a virtual hard disk now"**
2. Click **Create**
3. Choose **VDI (VirtualBox Disk Image)**
4. Select **Dynamically allocated**
5. Set size:
   - Minimum: 30 GB
   - Recommended: 50 GB
   - Optimal: 100 GB

---

## ⚙️ VM Configuration

Before starting the VM, configure these important settings:

### 1. General Settings

1. Right-click VM → **Settings** → **General** → **Advanced**
2. Set:
   ```
   Shared Clipboard: Bidirectional
   Drag'n'Drop: Bidirectional
   ```

### 2. System Settings

**Motherboard Tab:**
```
Boot Order:
  ✓ Optical (first)
  ✓ Hard Disk (second)
  ✗ Floppy
  ✗ Network

Chipset: ICH9
Extended Features:
  ✓ Enable I/O APIC
  ✓ Hardware Clock in UTC Time
```

**Processor Tab:**
```
CPUs: 2 or more (use 50% of your host CPUs)
Extended Features:
  ✓ Enable PAE/NX
```

**Acceleration Tab:**
```
Paravirtualization Interface: Default
✓ Enable VT-x/AMD-V
✓ Enable Nested Paging
```

### 3. Display Settings

```
Video Memory: 128 MB (maximum)
Graphics Controller: VMSVGA (or VBoxVGA)
✓ Enable 3D Acceleration
Scale Factor: 100%
```

**Important for Hyprland:**
- Do NOT use "VBoxSVGA" - it has issues with Wayland
- VMSVGA works best with CustomOS

### 4. Storage Settings

**Attach the ISO:**
1. Click on **"Empty"** under Controller: IDE
2. Click disk icon on right → **"Choose a disk file"**
3. Select your CustomOS ISO file
4. Check **"Live CD/DVD"**

### 5. Audio Settings

```
✓ Enable Audio
Audio Controller: Intel HD Audio
Audio Driver: PulseAudio (Linux) / DirectSound (Windows)
```

### 6. Network Settings

```
Adapter 1:
  ✓ Enable Network Adapter
  Attached to: NAT
  Advanced → Adapter Type: Intel PRO/1000 MT Desktop
```

**For better network performance:**
- Use "Bridged Adapter" if you want the VM to be on same network as host
- Use "NAT Network" if you want multiple VMs to communicate

### 7. USB Settings

```
✓ Enable USB Controller
USB 2.0 (EHCI) Controller
```

---

## 💿 Installing CustomOS

### Step 1: Start the VM

1. Select your CustomOS VM
2. Click **Start**
3. The ISO should boot automatically

**If it doesn't boot:**
- Check that ISO is attached in Storage settings
- Check boot order in System settings

### Step 2: Boot Menu

You'll see the CustomOS boot screen with options:
- **CustomOS (default)** - Normal boot
- **CustomOS (Safe Mode)** - If normal boot fails

Select the default and press Enter.

### Step 3: Wait for Live Environment

The live environment will load (30-60 seconds). You'll see the CustomOS welcome message.

### Step 4: Run Installer

At the terminal prompt, type:
```bash
install-arch
```

Press Enter.

### Step 5: Follow Installation Prompts

The installer will ask you:

**1. Disk Selection:**
```
Enter target disk: sda
```
Type `sda` (this is your virtual disk)

**2. Confirmation:**
```
WARNING: All data on /dev/sda will be erased!
Continue? (yes/no):
```
Type `yes`

**3. Hostname:**
```
Hostname: customos-vm
```
Choose any name (e.g., `customos-vm`)

**4. Username:**
```
Username: myuser
```
Choose your username

**5. Password:**
```
Password: ********
Confirm password: ********
```
Choose a strong password

**6. Final Confirmation:**
```
Proceed with installation? (yes/no):
```
Type `yes`

### Step 6: Installation Process

The installer will:
1. Partition the disk (10 seconds)
2. Format partitions (5 seconds)
3. Install base system (3-10 minutes, depending on online/offline)
4. Configure bootloader
5. Set up users

Total time: **10-20 minutes** (online) or **5-10 minutes** (offline ISO)

### Step 7: Complete Installation

When you see:
```
Base Installation Complete!
```

1. Press Enter to reboot
2. VirtualBox will ask to remove installation media
3. Press Enter again

**Or manually:**
```bash
# Remove ISO from storage settings
# Then reboot:
reboot
```

---

## 🎨 Post-Installation

### First Boot

1. VM will boot to login screen
2. Login with your username and password
3. The post-install script will **automatically run**
4. This installs Hyprland, themes, and all customizations
5. Takes 5-10 minutes

**If auto-install doesn't run:**
```bash
cd ~/custom-setup
bash post-install.sh
```

### Install VirtualBox Guest Additions

**Good news:** CustomOS automatically detects VirtualBox and installs guest additions!

**To verify:**
```bash
lsmod | grep vbox
systemctl status vboxservice
```

**Manual installation if needed:**
```bash
sudo pacman -S virtualbox-guest-utils
sudo systemctl enable vboxservice
sudo systemctl start vboxservice
reboot
```

### Enable Shared Folders (Optional)

**On host:**
1. VM Settings → Shared Folders
2. Click "+" icon
3. Choose folder path
4. Name: `shared`
5. Check "Auto-mount" and "Make Permanent"

**In CustomOS:**
```bash
# Add your user to vboxsf group
sudo usermod -aG vboxsf $USER

# Reboot
reboot

# Access shared folder
ls /media/sf_shared/
```

### Configure Display Resolution

**Method 1: Automatic (with Guest Additions)**
- Resize VirtualBox window
- Display should auto-resize

**Method 2: Manual**
```bash
# List available resolutions
xrandr

# Set resolution
xrandr --output Virtual-1 --mode 1920x1080
```

**Method 3: In Hyprland Config**
Edit `~/.config/hypr/hyprland.conf`:
```
monitor=Virtual-1,1920x1080@60,0x0,1
```

---

## 🔧 Troubleshooting

### Issue: VM Won't Boot ISO

**Solutions:**
1. Check ISO is attached: VM Settings → Storage
2. Check boot order: VM Settings → System → Boot Order
3. Try different graphics controller: VM Settings → Display
4. Enable EFI: VM Settings → System → Enable EFI
5. Re-download ISO if corrupted

### Issue: Black Screen After Boot

**Try booting in Safe Mode:**
1. Restart VM
2. At boot menu, select "CustomOS (Safe Mode)"
3. This disables GPU acceleration

**Or add kernel parameter:**
1. At boot menu, press 'e'
2. Add `nomodeset` to kernel line
3. Press Enter

### Issue: Display Resolution Stuck at 1024x768

**Install/reinstall Guest Additions:**
```bash
sudo pacman -S virtualbox-guest-utils
sudo systemctl enable vboxservice
sudo systemctl start vboxservice
reboot
```

**Check if modules loaded:**
```bash
lsmod | grep vbox
# Should see: vboxguest, vboxsf, vboxvideo
```

### Issue: No Internet in VM

**Check network adapter:**
```bash
ip link show
# Should see enp0s3 or similar

# If down, bring it up:
sudo ip link set enp0s3 up
sudo systemctl restart NetworkManager
```

**VM Settings:**
- Settings → Network → Adapter 1
- Enable Network Adapter
- Attached to: NAT
- Adapter Type: Intel PRO/1000 MT Desktop

### Issue: Slow Performance

**Increase resources:**
- RAM: Allocate at least 4GB
- CPUs: Allocate at least 2 cores
- Video Memory: Set to 128MB
- Enable 3D Acceleration

**Enable KVM (Linux hosts only):**
```bash
# Check if KVM available
lsmod | grep kvm

# VirtualBox should auto-detect and use KVM
```

### Issue: Hyprland Crashes or Won't Start

**Check logs:**
```bash
cat ~/.hyprland.log
journalctl --user -u hyprland
```

**Try fallback:**
```bash
# Use Xorg session instead
startx
```

**Reinstall Hyprland:**
```bash
sudo pacman -S hyprland
```

### Issue: Clipboard Sharing Not Working

**Install Guest Additions properly:**
```bash
sudo pacman -S virtualbox-guest-utils
sudo systemctl enable vboxservice
reboot
```

**Check VirtualBox settings:**
- General → Advanced → Shared Clipboard: Bidirectional

### Issue: Sound Not Working

**Check audio settings:**
```bash
# List audio devices
pactl list short sinks

# Set default
pactl set-default-sink <sink-name>
```

**VM Settings:**
- Settings → Audio → Enable Audio
- Audio Controller: Intel HD Audio
- Audio Driver: PulseAudio (Linux) / DirectSound (Windows)

**Restart audio:**
```bash
systemctl --user restart pipewire
systemctl --user restart wireplumber
```

---

## 📊 Optimal VM Settings Summary

| Setting | Value |
|---------|-------|
| RAM | 4-8 GB |
| CPUs | 2-4 cores |
| Video Memory | 128 MB |
| Graphics Controller | VMSVGA |
| 3D Acceleration | Enabled |
| Disk Size | 50+ GB |
| Network | NAT (Intel PRO/1000) |
| Audio | Intel HD Audio |
| Shared Clipboard | Bidirectional |

---

## 🎯 Quick Reference

### Essential Commands

```bash
# Check VirtualBox Guest Additions
lsmod | grep vbox

# Check display
xrandr

# Check network
ip addr show

# Check audio
pactl list short sinks

# Update system
sudo pacman -Syu

# Switch theme
Super + Shift + T

# Show keybindings
Super + /
```

### VirtualBox Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Right Ctrl | Host Key (release mouse) |
| Host + F | Toggle fullscreen |
| Host + C | Toggle scale mode |
| Host + Home | Show VirtualBox menu |
| Host + Q | Close VM menu |

---

## 📝 Notes

- **Host Key:** Usually Right Ctrl, shown in bottom-right of VM window
- **Fullscreen:** Press Host+F for immersive experience
- **Snapshots:** Take snapshots before major changes (Snapshots menu)
- **Export VM:** File → Export Appliance (to share or backup)
- **Performance:** VirtualBox + Wayland (Hyprland) works but has limitations
- **3D Support:** Limited in VirtualBox, but sufficient for CustomOS

---

## 🎓 Advanced Topics

### Using QEMU/KVM Instead (Better Performance on Linux)

If you're on Linux, consider using QEMU/KVM for better performance:

```bash
# Install QEMU
sudo pacman -S qemu virt-manager

# Create VM
virt-manager
```

### Automated Installation (No Prompts)

Create a preseed configuration or use the automated installer with environment variables.

### Nested Virtualization

Enable nested virtualization if you want to run VMs inside your VM:

```bash
# VM Settings → System → Processor → Enable Nested VT-x/AMD-V
```

---

**Need help?** Open an issue on GitHub or check the main README.md for more information.

**CustomOS VirtualBox Guide** - *Test your custom OS safely!*
