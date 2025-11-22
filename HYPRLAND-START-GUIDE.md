# Hyprland Start Guide - Fix Core Dumps

Quick guide to starting Hyprland without crashes in VirtualBox.

---

## ✅ The Fix

Hyprland core dumps are caused by missing VirtualBox compatibility settings.

**Solution: Use the wrapper script instead of running `Hyprland` directly!**

---

## 🚀 How to Start Hyprland (3 Ways)

### Method 1: Auto-start on Login (Recommended)

After installation, just **login** and Hyprland will start automatically!

```
Username: parteek  (or whatever you set)
Password: (your password)

# Hyprland starts automatically!
```

---

### Method 2: Manual Start (Safe Method)

If auto-start doesn't work, use the wrapper script:

```bash
# After logging in:
start-hyprland
```

This script:
- ✅ Detects VirtualBox
- ✅ Sets environment variables
- ✅ Starts Hyprland without crashing

---

### Method 3: Quick Start Script

There's also a script in your home directory:

```bash
~/start-hypr.sh
```

Both `start-hyprland` and `~/start-hypr.sh` do the same thing!

---

## ❌ DON'T Do This

**Never run `Hyprland` directly!**

```bash
# DON'T DO THIS in VirtualBox:
Hyprland    # ← Will core dump!
```

**Why?** The command bypasses environment setup and tries to use hardware acceleration that VirtualBox doesn't support.

---

## 🔧 What the Wrapper Does

The wrapper script (`start-hyprland`) automatically:

1. **Detects VirtualBox:**
   ```bash
   lspci | grep -i "virtualbox"
   systemd-detect-virt
   ```

2. **Sets critical environment variables:**
   ```bash
   export WLR_NO_HARDWARE_CURSORS=1
   export WLR_RENDERER_ALLOW_SOFTWARE=1
   export WLR_RENDERER=pixman
   ```

3. **Starts Hyprland** with proper settings

---

## 🎯 Troubleshooting

### Problem: Still getting core dump

**Check environment variables are set:**
```bash
# Before starting Hyprland, check:
echo $WLR_RENDERER
# Should show: pixman

# If empty, run:
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_RENDERER=pixman

# Then start:
start-hyprland
```

---

### Problem: Command not found: start-hyprland

**Rebuild your ISO** with the latest scripts:
```bash
./build-iso-docker.sh
```

**Or create it manually (temporary fix):**
```bash
cat > ~/start-hypr.sh << 'EOF'
#!/bin/bash
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_RENDERER=pixman
exec Hyprland
EOF

chmod +x ~/start-hypr.sh
~/start-hypr.sh
```

---

### Problem: Auto-start doesn't work

**Manually start once:**
```bash
start-hyprland
```

**Check .zprofile exists:**
```bash
cat ~/.zprofile
# Should contain start-hyprland command
```

**If missing, recreate it:**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
echo 'if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then' >> ~/.zprofile
echo '    exec start-hyprland' >> ~/.zprofile
echo 'fi' >> ~/.zprofile
```

---

## ⚙️ VirtualBox Settings (Critical!)

Make sure these are correct:

1. **3D Acceleration: OFF** ❌
   - VM Settings → Display
   - **Uncheck** "Enable 3D Acceleration"
   - This is the #1 cause of crashes!

2. **Video Memory: 128MB**
   - VM Settings → Display
   - Set to maximum (128MB)

3. **Graphics Controller: VMSVGA**
   - VM Settings → Display
   - Select VMSVGA or VBoxVGA

---

## 📝 Quick Reference

| Command | Purpose |
|---------|---------|
| `start-hyprland` | Safe way to start Hyprland |
| `~/start-hypr.sh` | Alternative starter script |
| `Hyprland` | ❌ Don't use directly in VBox |
| `exit` | Exit Hyprland back to terminal |

---

## ✅ Correct Startup Flow

```
1. Boot ISO
   ↓
2. Run: install-arch
   ↓
3. Wait for installation
   ↓
4. Reboot
   ↓
5. Login
   ↓
6. Hyprland auto-starts! ✓
```

If auto-start fails:
```bash
start-hyprland
```

---

## 🎉 After Hyprland Starts

You should see:
- Waybar at the top
- Your wallpaper
- Cursor working
- No crashes!

**Try these keybindings:**
- `Super + T` - Terminal
- `Super + A` - App launcher
- `Super + Shift + T` - Theme selector
- `Super + Q` - Close window
- `Super + L` - Lock screen

---

## 🔄 For Real Hardware (Not VirtualBox)

On real hardware, you can use `Hyprland` directly:

```bash
# On real hardware:
Hyprland    # ← Works fine!
```

The wrapper scripts detect VirtualBox and only apply compatibility settings when needed.

---

## 📦 Summary

**In VirtualBox:**
- ✅ Use: `start-hyprland`
- ❌ Don't use: `Hyprland`
- ✅ Disable 3D acceleration
- ✅ Auto-start works after reboot

**On Real Hardware:**
- ✅ Both work fine
- ✅ Better performance
- ✅ Full hardware acceleration

---

**Remember:** The core dump happens because VirtualBox can't handle Hyprland's default renderer. The wrapper script fixes this by forcing software rendering!

Build a new ISO and the wrapper will be included automatically! 🚀

```bash
./build-iso-docker.sh
```
