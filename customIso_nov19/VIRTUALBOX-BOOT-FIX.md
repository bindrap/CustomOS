# VirtualBox UEFI Boot Fix

## The Error

```
Failed to execute Arch Linux install medium x86_64
UEFI \arch\boot\x86_64\vmlinuz-linux ; unsupported
```

This error occurs when VirtualBox's UEFI firmware can't boot the ISO.

## Quick Fix (Try This First!)

### Disable EFI Mode in VirtualBox

1. **Shut down the VM** (if running)
2. **Open VM Settings** → **System** → **Motherboard**
3. **UNCHECK "Enable EFI (special OSes only)"**
4. **Click OK**
5. **Start the VM again**

This makes VirtualBox use **BIOS mode** instead of UEFI, which is more reliable.

## Why This Works

- VirtualBox's UEFI implementation can be problematic with some ISOs
- BIOS (Legacy) mode is more stable and widely supported
- The archiso supports both BIOS and UEFI
- Our installer works with both boot modes

## Proper VirtualBox Settings for CustomOS

### System Settings

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
  ✗ Enable EFI (special OSes only)  ← DISABLE THIS!
```

**Processor Tab:**
```
CPUs: 2 or more
Extended Features:
  ✓ Enable PAE/NX
```

### Display Settings

```
Video Memory: 128 MB
Graphics Controller: VMSVGA
✗ Enable 3D Acceleration (disable for now)
Scale Factor: 100%
```

### Storage Settings

```
Controller: IDE
  └─ ISO: Attach your custom-arch-*.iso
     ✓ Live CD/DVD
```

### Network Settings

```
Adapter 1:
  ✓ Enable Network Adapter
  Attached to: NAT
  Adapter Type: Intel PRO/1000 MT Desktop
```

## If BIOS Mode Still Doesn't Work

Try these additional steps:

### 1. Use VBoxVGA Graphics Controller

Sometimes VMSVGA has issues. Try:
- Settings → Display → Graphics Controller: **VBoxVGA**

### 2. Increase RAM

- Settings → System → Motherboard → Base Memory: **4096 MB** (4GB)

### 3. Verify ISO Integrity

Rebuild the ISO:
```bash
cd /mnt/c/Users/bindrap/Documents/CustomOS
bash package-creator.sh
cd customIso_nov19
bash build-custom-iso.sh
```

### 4. Try the Minimal ISO First

Test if the minimal ISO works:
```bash
cd Basics_Nov19
bash build-iso-minimal.sh
# Test this ISO in VirtualBox with BIOS mode
```

If the minimal ISO works but custom doesn't, there's an issue with the custom ISO build.

## Alternative: Use QEMU Instead

If VirtualBox continues to have issues, try QEMU (better Linux VM support):

```bash
# Install QEMU (on WSL)
sudo apt update
sudo apt install qemu-system-x86

# Test the ISO
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -cdrom customIso_nov19/iso-output/custom-arch-*.iso \
  -boot d
```

## Complete VirtualBox Setup Checklist

Before starting:

- [ ] VirtualBox version 6.1 or newer (7.0+ recommended)
- [ ] ISO file built successfully
- [ ] VM created with "Arch Linux (64-bit)" type

VM Settings:
- [ ] RAM: 4GB or more
- [ ] Disk: 50GB or more
- [ ] **EFI: DISABLED** ← Most important!
- [ ] Graphics: VMSVGA or VBoxVGA
- [ ] Video Memory: 128MB
- [ ] CPUs: 2 or more
- [ ] Network: NAT with Intel PRO/1000
- [ ] ISO attached to IDE controller
- [ ] Live CD/DVD checked

Boot:
- [ ] VM starts without errors
- [ ] ISO boots to live environment
- [ ] Welcome message appears
- [ ] Can run `install-arch` command

## Summary

**The #1 fix:** Disable EFI in VirtualBox settings!

This error is almost always caused by VirtualBox's UEFI firmware being incompatible with the ISO. Using BIOS (Legacy) mode solves it 99% of the time.

---

**Still having issues?** Let me know and I'll help debug further!
