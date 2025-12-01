# QEMU Troubleshooting Guide

## Black Screen After Login (HyDE/Hyprland)

### Problem
After logging in to QEMU, you see a black screen. Waybar may flash briefly before disappearing.

### Root Cause
The CachyOS kernel optimizations can cause compatibility issues with QEMU's graphics drivers. The heavily-optimized kernel may have different driver configurations that don't work well with certain QEMU graphics options.

### Solutions (in order of preference)

#### 1. Use QXL Graphics (Default - Already configured)
The scripts have been updated to use QXL graphics by default:
```bash
-device qxl-vga,vgamem_mb=256
-display gtk,gl=on
```

This provides better compatibility with Hyprland and the CachyOS kernel.

#### 2. If Still Having Issues - Try VirtIO without OpenGL
Edit the QEMU script and change:
```bash
# FROM:
-device qxl-vga,vgamem_mb=256 -display gtk,gl=on

# TO:
-vga virtio -display gtk,gl=off
```

#### 3. Check Hyprland Logs
After booting, press **Ctrl+Alt+F2** to switch to TTY2, login, and check:
```bash
# Check if Hyprland is running
ps aux | grep -i hyprland

# View Hyprland crash logs
cat ~/.cache/hypr/hyprland.log
cat ~/.cache/hypr/hyprland.log.old

# Try starting Hyprland manually to see errors
Hyprland
```

#### 4. Disable CachyOS Kernel (Use Standard Kernel)
If the issue persists, it may be a CachyOS kernel-specific problem. You can:

1. **At boot** - Select the standard Linux kernel instead of linux-cachyos from GRUB
2. **Or remove CachyOS kernel**:
   ```bash
   sudo pacman -R linux-cachyos linux-cachyos-headers
   sudo pacman -S linux linux-headers
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```

#### 5. Alternative Graphics Options

Try these other configurations in the QEMU scripts:

**Option A: Standard VGA**
```bash
-vga std -display gtk
```

**Option B: VMware SVGA**
```bash
-vga vmware -display gtk,gl=off
```

**Option C: Bochs VGA**
```bash
-device bochs-display -display gtk
```

### Memory Requirements
HyDE with Hyprland requires substantial memory. The scripts now allocate **8GB RAM** by default. If you're still having issues:

```bash
# Increase to 12GB if your host has enough RAM
-m 12G
```

### Testing Checklist

1. ✅ Using QXL graphics with 256MB VRAM
2. ✅ 8GB RAM allocated
3. ✅ KVM acceleration enabled (if available)
4. ✅ UEFI firmware configured
5. ⚠️  Check Hyprland logs for crashes
6. ⚠️  Consider using standard kernel if issues persist

### Quick Test Commands

After login, switch to TTY (Ctrl+Alt+F2) and run:
```bash
# Check graphics driver loaded
lsmod | grep -E 'qxl|virtio|drm'

# Check Xwayland/Wayland
echo $WAYLAND_DISPLAY
ps aux | grep -i wayland

# Test if compositor responds
hyprctl version
```

### When in Doubt
Boot with the **standard Linux kernel** from GRUB menu instead of CachyOS kernel. This will help determine if it's a kernel-specific issue.
