# QEMU Troubleshooting Guide

## Quick Fix - Boot Your Installed System

If you just want to boot your installed system right now:

```bash
bash boot-qemu-manual.sh
```

Choose option 1 to boot the installed system.

---

## Problem: "Booting from Hard Disk" Hang

### Why This Happens

The disk has an EFI System Partition but QEMU might be booting in BIOS mode, which can't read EFI partitions.

### Solution 1: Use Manual Boot Script

```bash
bash boot-qemu-manual.sh
```

Choose option 3 to see all troubleshooting commands.

### Solution 2: Fix Bootloader From Inside QEMU

1. **Boot with ISO attached:**

```bash
bash boot-qemu-manual.sh
# Choose option 2
```

2. **Press ESC during QEMU boot** to get the boot menu

3. **Select CD-ROM** to boot from ISO

4. **Once in live environment, fix the bootloader:**

```bash
# Mount the installed system
mount /dev/vda3 /mnt
mount /dev/vda1 /mnt/boot

# Chroot into installed system
arch-chroot /mnt

# Reinstall bootloader
bootctl install
bootctl update

# Verify it worked
ls -la /boot/loader/entries/
cat /boot/loader/loader.conf
cat /boot/loader/entries/arch.conf

# Exit and reboot
exit
reboot
```

5. **Close QEMU** after "Installation complete!" message

6. **Boot normally:**

```bash
bash boot-qemu-manual.sh
# Choose option 1
```

---

## Problem: Can't See QEMU Window or Slow Performance

### Enable KVM Acceleration

```bash
# Check if KVM is available
ls -la /dev/kvm

# If it exists but you get permission errors:
sudo chmod 666 /dev/kvm
```

### Window Not Appearing

QEMU might be lagging. Wait 10-20 seconds after running the command.

### Move QEMU Window

- Use Alt+Tab to switch windows
- Or press Ctrl+Alt+G to release mouse, then use your window manager to move it

---

## Problem: Internet Detection Fails

The `install-arch` script already handles this:

1. It auto-detects internet by pinging 8.8.8.8, 1.1.1.1, and archlinux.org
2. If detection fails, it asks: "Do you have internet connection? (yes/no)"
3. Answer "yes" to use online mode
4. Answer "no" to use offline mode (requires offline packages)

### Manual Network Setup in QEMU

If you need to set up networking manually:

```bash
# Check network interfaces
ip link

# DHCP (should work automatically)
dhcpcd

# Test connection
ping -c 3 8.8.8.8
```

---

## Inspect Installed Disk

### Quick Inspection

```bash
bash inspect-qemu-disk.sh
```

### Manual Inspection

```bash
# Load NBD kernel module
sudo modprobe nbd max_part=8

# Connect disk
sudo qemu-nbd --connect=/dev/nbd0 qemu-disks/hyprland-test.qcow2

# Check partitions
sudo fdisk -l /dev/nbd0

# Mount root partition
sudo mkdir -p /tmp/disk-inspect
sudo mount /dev/nbd0p3 /tmp/disk-inspect
sudo mount /dev/nbd0p1 /tmp/disk-inspect/boot

# Check bootloader files
sudo ls -la /tmp/disk-inspect/boot/loader/entries/
sudo cat /tmp/disk-inspect/boot/loader/loader.conf
sudo cat /tmp/disk-inspect/boot/loader/entries/arch.conf

# Check kernel
sudo ls -la /tmp/disk-inspect/boot/vmlinuz-linux

# Check installed packages
sudo ls /tmp/disk-inspect/var/lib/pacman/local/ | grep hyprland

# Unmount when done
sudo umount /tmp/disk-inspect/boot
sudo umount /tmp/disk-inspect
sudo qemu-nbd --disconnect /dev/nbd0
```

---

## Start Fresh

If nothing works and you want to start over:

```bash
# Delete all virtual disks
bash cleanup-qemu.sh

# Rebuild ISO (if needed)
bash build-hyprland-iso-clean.sh

# Fresh installation
bash test-iso-qemu-install.sh
```

---

## Manual QEMU Commands

### Boot Installed System

```bash
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 \
  -drive file=qemu-disks/hyprland-test.qcow2,format=qcow2,if=virtio \
  -vga virtio -display sdl,gl=on \
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
  -boot c
```

### Boot with ISO (Rescue Mode)

```bash
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 \
  -drive file=qemu-disks/hyprland-test.qcow2,format=qcow2,if=virtio \
  -cdrom iso-output/HYPR_*.iso \
  -vga virtio -display sdl,gl=on \
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
  -boot menu=on
```

Press ESC during boot to select boot device.

---

## Common Issues

### "No space left on device" during ISO build

```bash
# Check space
df -h

# Clean Docker
docker system prune -af
```

### "Permission denied" for KVM

```bash
sudo chmod 666 /dev/kvm
```

### Disk won't boot after successful installation

This is the current issue. Try:

1. Use `boot-qemu-manual.sh` option 2 (boot with ISO)
2. Boot from CD-ROM (press ESC, select CD-ROM)
3. Mount the installed system and reinstall bootloader (see Solution 2 above)

### QEMU crashes or freezes

- Close QEMU
- Check if another QEMU instance is running: `pkill qemu`
- Try again

---

## Get Help

If you're still stuck:

1. Run `bash boot-qemu-manual.sh` and choose option 3 for manual commands
2. Run `bash inspect-qemu-disk.sh` to see what's on the disk
3. Check if bootloader files exist in `/boot/loader/`
4. Try reinstalling bootloader from inside QEMU
