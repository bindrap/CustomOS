# Fixing Hyprland Core Dumps in VirtualBox

## Current Status

You're experiencing:
```
Hyprland: core dumped
Segmentation fault
```

## Root Causes

Hyprland core dumps in VirtualBox due to:
1. **VirtualBox's limited GPU support** - No proper Vulkan/OpenGL
2. **Missing critical dependencies** - polkit, portals, etc.
3. **Environment variables not set** - WLR flags
4. **Library incompatibilities** - wlroots vs VBox drivers

## What We've Tried

The `build-hyprland-iso.sh` includes:
- ✅ Software rendering flags (WLR_NO_HARDWARE_CURSORS, etc.)
- ✅ Disabled heavy effects (blur, shadows)
- ✅ All dependencies (polkit, xdg-desktop-portal-hyprland)
- ✅ VirtualBox guest additions
- ✅ Simplified animations

## If Still Core Dumping

### Step 1: Check What's Missing

Boot into the installed system and run:

```bash
# Check if Hyprland is installed
which Hyprland

# Check dependencies
pacman -Q | grep -E "polkit|portal|hyprland"

# Check VBox guest additions
lsmod | grep vbox
systemctl status vboxservice

# Try starting Hyprland manually to see error
Hyprland 2>&1 | tee /tmp/hyprland-debug.log

# Check the error
cat /tmp/hyprland-debug.log
```

### Step 2: Manual Dependency Install

If anything is missing:

```bash
# Install ALL Hyprland dependencies
sudo pacman -S --needed \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    polkit \
    polkit-gnome \
    qt5-wayland \
    qt6-wayland \
    grim \
    slurp \
    wl-clipboard \
    waybar \
    mako \
    wofi \
    kitty

# Reboot
reboot
```

### Step 3: Set Environment Variables Manually

If Hyprland still crashes, set these before starting:

```bash
# Create environment file
cat > ~/.config/hypr/env.conf << 'EOF'
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = WLR_RENDERER,pixman
env = LIBVA_DRIVER_NAME,i965
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,mesa
EOF

# Source it before starting
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_RENDERER=pixman

# Try starting
Hyprland
```

### Step 4: Try Different Rendering Backend

```bash
# Try with pixman (software renderer)
WLR_RENDERER=pixman Hyprland

# Or try vulkan
WLR_RENDERER=vulkan Hyprland

# Or try gles2
WLR_RENDERER=gles2 Hyprland
```

### Step 5: Check for Specific Errors

Common errors and fixes:

**Error: "can't open display"**
```bash
sudo pacman -S xdg-desktop-portal-hyprland
```

**Error: "failed to create backend"**
```bash
export WLR_RENDERER=pixman
export WLR_NO_HARDWARE_CURSORS=1
Hyprland
```

**Error: "segmentation fault" with no details**
```bash
# Missing polkit
sudo pacman -S polkit polkit-gnome

# Start polkit agent
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Try Hyprland again
Hyprland
```

## Alternative: Use Sway

If Hyprland absolutely won't work in VirtualBox:

```bash
# Install Sway (works perfectly in VBox)
sudo pacman -S sway swayidle swaylock

# Start Sway
sway

# Sway has similar keybindings to Hyprland
# Super + Enter = terminal
# Super + D = launcher
# etc.
```

## Rebuild ISO with More Fixes

If you want to try rebuilding with even more comprehensive fixes:

```bash
cd /mnt/c/Users/bindrap/Documents/CustomOS

# Update package creator
bash package-creator.sh

# Rebuild with latest fixes
cd cos_hypr_nov19
bash build-hyprland-iso.sh

# Test new ISO
```

## Report Specific Error

To help debug further, provide:

1. **Exact error message:**
   ```bash
   Hyprland 2>&1 | tee error.log
   cat error.log
   ```

2. **Missing packages:**
   ```bash
   pacman -Q | grep -E "hypr|wayland|portal|polkit"
   ```

3. **VirtualBox version:**
   ```bash
   VBoxManage --version
   ```

4. **VirtualBox settings:**
   - EFI enabled/disabled?
   - Graphics controller?
   - 3D acceleration enabled/disabled?
   - Video memory?

---

**The reality:** Hyprland may not work well in VirtualBox due to GPU limitations. Sway is recommended for VirtualBox as it works perfectly.

If you must have Hyprland, test on real hardware instead of VirtualBox.
