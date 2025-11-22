# EMERGENCY FIX - Hyprland Core Dump

If Hyprland is still crashing, follow these steps **in order**.

---

## 🚨 CRITICAL: Check VirtualBox Settings FIRST!

**90% of core dumps are caused by this:**

### In VirtualBox (VM must be powered OFF):

1. **Right-click your VM → Settings**
2. **Go to Display**
3. **UNCHECK "Enable 3D Acceleration"** ← MOST IMPORTANT!
4. **Set Video Memory to 128MB**
5. **Graphics Controller: VMSVGA**
6. **Click OK**
7. **Start VM**

**If 3D acceleration is enabled, Hyprland WILL crash no matter what!**

---

## 🔧 In the VM - Manual Fix

If it's still crashing after disabling 3D acceleration:

### Step 1: Set Environment Variables

**In your terminal, run these commands:**

```bash
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_RENDERER=pixman
export LIBVA_DRIVER_NAME=""
export __GLX_VENDOR_LIBRARY_NAME=""

# Now try:
Hyprland
```

---

### Step 2: Create Emergency Starter Script

If that works, make it permanent:

```bash
cat > ~/hypr-emergency.sh << 'EOF'
#!/bin/bash
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_RENDERER=pixman
export LIBVA_DRIVER_NAME=""
export __GLX_VENDOR_LIBRARY_NAME=""
export GBM_BACKEND=dummy
export WLR_LIBINPUT_NO_DEVICES=1

echo "Starting Hyprland with VirtualBox compatibility..."
exec Hyprland
EOF

chmod +x ~/hypr-emergency.sh
~/hypr-emergency.sh
```

---

### Step 3: Check What's Actually Set

Before starting Hyprland, verify environment:

```bash
# Check if variables are set:
env | grep WLR

# Should show:
# WLR_NO_HARDWARE_CURSORS=1
# WLR_RENDERER_ALLOW_SOFTWARE=1
# WLR_RENDERER=pixman
```

---

### Step 4: Add to Shell RC File

Make it permanent in your shell:

```bash
# Add to .zshrc
cat >> ~/.zshrc << 'EOF'

# VirtualBox Hyprland compatibility
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_RENDERER=pixman
EOF

# Reload shell
source ~/.zshrc

# Try again
Hyprland
```

---

## 🔍 Diagnostic Commands

### Check VirtualBox Detection:

```bash
# Should return results if in VirtualBox:
lspci | grep -i virtualbox
systemd-detect-virt

# Check graphics:
lspci | grep VGA
```

### Check Hyprland Config:

```bash
# Check if env vars are in config:
grep WLR ~/.config/hypr/hyprland.conf

# Should show:
# env = WLR_NO_HARDWARE_CURSORS,1
# env = WLR_RENDERER_ALLOW_SOFTWARE,1
# env = WLR_RENDERER,pixman
```

### Check for Errors:

```bash
# Try to start and capture error:
Hyprland 2>&1 | tee hyprland-error.log

# View the log:
cat hyprland-error.log
```

---

## 🎯 Alternative: Use Xorg Instead (Temporary)

If Hyprland absolutely won't work, use Xorg temporarily:

```bash
# Install a simple window manager
sudo pacman -S xorg-server xorg-xinit i3-wm

# Create .xinitrc
echo "exec i3" > ~/.xinitrc

# Start X
startx
```

This at least gets you a GUI while we debug Hyprland.

---

## 📝 Gather Debug Info

If still crashing, gather this info:

```bash
# 1. VirtualBox info
lspci | grep VGA

# 2. Graphics driver
lsmod | grep drm

# 3. Wayland capabilities
ls -la /usr/bin/Hyprland

# 4. Environment
env | grep -E "WLR|DISPLAY|WAYLAND"

# 5. Try with debug output
WLR_DRM_NO_ATOMIC=1 Hyprland 2>&1 | head -50
```

---

## 🆘 Last Resort Options

### Option 1: Reinstall VirtualBox Guest Utils

```bash
sudo pacman -S --needed virtualbox-guest-utils
sudo systemctl enable vboxservice
sudo systemctl start vboxservice
reboot
```

### Option 2: Use Different Renderer

Try different renderers:

```bash
# Try vulkan
export WLR_RENDERER=vulkan
Hyprland

# Or try gles2
export WLR_RENDERER=gles2
Hyprland
```

### Option 3: Nuclear Option - Force Software Everything

```bash
export WLR_RENDERER=pixman
export WLR_NO_HARDWARE_CURSORS=1
export LIBGL_ALWAYS_SOFTWARE=1
export GALLIUM_DRIVER=llvmpipe
export WLR_DRM_NO_ATOMIC=1
export WLR_DRM_NO_MODIFIERS=1

Hyprland
```

---

## ✅ Final Checklist

Before trying to start Hyprland:

- [ ] VirtualBox 3D acceleration is **DISABLED**
- [ ] Video Memory set to 128MB
- [ ] Graphics Controller is VMSVGA
- [ ] VM is fully rebooted after settings change
- [ ] Environment variables are set
- [ ] Guest additions are installed

---

## 🔄 Complete Reset Procedure

If nothing works, start fresh:

```bash
# 1. Power off VM completely
# 2. Check VirtualBox settings (3D OFF!)
# 3. Start VM
# 4. Login

# 5. Set environment
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_RENDERER=pixman

# 6. Check Hyprland config
cat ~/.config/hypr/hyprland.conf | grep -A3 "ENVIRONMENT"

# 7. If env vars not in config, add them:
cat >> ~/.config/hypr/hyprland.conf << 'EOF'

env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = WLR_RENDERER,pixman
EOF

# 8. Try starting
Hyprland
```

---

## 📞 If Still Failing

**Check these specific things:**

1. **Is this a fresh install from the new ISO?**
   - Old ISOs don't have the fixes

2. **Did you rebuild the ISO after the fixes?**
   ```bash
   ./build-iso-docker.sh
   ```

3. **Are you running on Windows with WSL building the ISO?**
   - The fixes should be in the ISO automatically

4. **Can you send the exact error message?**
   - The core dump might have specific errors

---

## 🎯 Quick Test Script

Run this to test everything:

```bash
cat > ~/test-hypr.sh << 'TESTEOF'
#!/bin/bash
echo "=== Hyprland Environment Test ==="
echo ""
echo "1. Checking VirtualBox:"
lspci | grep -i virtualbox || echo "Not detected"
echo ""
echo "2. Checking virtualization:"
systemd-detect-virt
echo ""
echo "3. Setting environment:"
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_RENDERER=pixman
echo ""
echo "4. Environment set:"
env | grep WLR
echo ""
echo "5. Starting Hyprland in 3 seconds..."
echo "   (Press Ctrl+C to cancel)"
sleep 3
exec Hyprland
TESTEOF

chmod +x ~/test-hypr.sh
~/test-hypr.sh
```

---

**The #1 cause is 3D acceleration being enabled in VirtualBox!**

Check VM Settings → Display → 3D Acceleration must be **UNCHECKED**! ❌
