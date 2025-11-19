# cos_hypr_nov19 - Hyprland ISO for VirtualBox (Core Dump Fixed)

This folder contains a **specialized ISO builder** that fixes Hyprland core dumps in VirtualBox.

## The Problem This Solves

When running Hyprland in VirtualBox, you might see:
```
Hyprland: core dumped
Segmentation fault
```

This happens because:
1. **VirtualBox has limited Wayland support**
2. **Hardware cursor not supported**
3. **GPU acceleration issues**
4. **Missing dependencies** (polkit, xdg-desktop-portal)
5. **Heavy effects** (blur, shadows) crash on software rendering

## The Solution

This ISO includes **AGGRESSIVE** VirtualBox fixes:
- ✅ **Multi-renderer fallback system** (pixman → gles2 → vulkan)
- ✅ **Mesa software rendering libraries** (mesa, vulkan-swrast, mesa-vdpau)
- ✅ **Intelligent wrapper script** tries all renderers automatically
- ✅ **Forced software rendering** (WLR_RENDERER=pixman as default)
- ✅ **Disabled hardware cursors** (WLR_NO_HARDWARE_CURSORS=1)
- ✅ **Disabled heavy effects** (no blur, no shadows)
- ✅ **Simplified animations**
- ✅ **All required dependencies** (polkit, xdg-desktop-portal-hyprland, mesa)
- ✅ **Sway fallback** if all renderers fail
- ✅ **VirtualBox guest additions** auto-detected and installed
- ✅ **Extensive error logging** for debugging
- ✅ **VirtualBox-specific environment variables**

## Quick Start

### Step 1: Update custom-arch-setup

```bash
cd /mnt/c/Users/bindrap/Documents/CustomOS
bash package-creator.sh
```

### Step 2: Build the ISO

```bash
cd cos_hypr_nov19
bash build-hyprland-iso.sh
```

**Time:** 10-15 minutes
**Output:** `iso-output/hyprland-vbox-*.iso`

### Step 3: Configure VirtualBox

**IMPORTANT Settings:**

```
Type: Arch Linux (64-bit)
RAM: 4GB+ (8GB recommended)
Disk: 50GB+

System → Motherboard:
  ✗ Enable EFI (DISABLE - use BIOS!)

System → Processor:
  CPUs: 2+

Display:
  Video Memory: 128MB
  Graphics Controller: VMSVGA
  ✗ Enable 3D Acceleration (DISABLE!)

Network:
  Adapter 1: NAT
```

### Step 4: Install

1. Boot ISO
2. Run: `install-arch`
3. Follow prompts
4. Reboot
5. Login
6. Post-install runs automatically (with VBox fixes!)
7. Reboot
8. Hyprland starts!

## How This Fixes Core Dumps

### VirtualBox-Specific Post-Install Script

This ISO uses `post-install-vbox.sh` instead of regular `post-install.sh`.

**Key differences:**

#### 1. Mesa Software Rendering Libraries
```bash
mesa               # Base Mesa 3D Graphics Library
vulkan-swrast      # Software Vulkan renderer
glu                # OpenGL Utility Library
libglvnd           # OpenGL vendor-neutral dispatch library
libva-mesa-driver  # Video Acceleration API Mesa driver
mesa-vdpau         # Video Decode and Presentation API
```

#### 2. Environment Variables (AGGRESSIVE)
```bash
WLR_NO_HARDWARE_CURSORS=1      # Software cursor
WLR_RENDERER_ALLOW_SOFTWARE=1  # Allow software rendering
WLR_RENDERER=pixman            # Force pure software rendering
LIBVA_DRIVER_NAME=i965         # Intel VA-API driver
__GLX_VENDOR_LIBRARY_NAME=mesa # Force Mesa for OpenGL
GBM_BACKEND=nvidia-drm         # Generic Buffer Management
```

#### 3. Hyprland Config Modifications
```bash
decoration {
    blur {
        enabled = false  # Blur crashes in VBox
    }
    drop_shadow = false  # Shadows cause issues
}

animations {
    enabled = true
    # Simplified animations only
}

misc {
    vfr = true  # Variable frame rate
}
```

#### 4. Additional Packages
- `xdg-desktop-portal-hyprland` - Required for Wayland apps
- `xdg-desktop-portal-gtk` - GTK portal
- `polkit` - Authentication agent (prevents crashes)
- `polkit-gnome` - GUI for polkit
- `qt5-wayland` + `qt6-wayland` - Qt Wayland support
- `sway` - Fallback compositor
- `mesa` + software rendering libraries - For software GPU

#### 5. Intelligent Multi-Renderer Wrapper Script

**NEW!** The wrapper script (`~/.local/bin/start-hyprland.sh`) tries multiple renderers automatically:

```bash
# Tries in order:
1. WLR_RENDERER=pixman   # Pure software (CPU only)
2. WLR_RENDERER=gles2    # OpenGL ES 2.0 (if available)
3. WLR_RENDERER=vulkan   # Vulkan (if available)

# Each renderer gets 10 seconds to start
# If it crashes immediately, tries the next one
# If it runs for 10s, it's considered successful
```

#### 6. Automatic Fallback Chain
```bash
Try pixman renderer
  ↓ (if fails)
Try gles2 renderer
  ↓ (if fails)
Try vulkan renderer
  ↓ (if fails)
Show error logs
  ↓
Wait 5 seconds
  ↓
Launch Sway
```

The wrapper logs everything to `/tmp/hyprland-startup.log` for debugging!

## Differences from customIso_nov19

| Feature | customIso_nov19 | cos_hypr_nov19 |
|---------|-----------------|----------------|
| Post-Install Script | post-install.sh | post-install-vbox.sh |
| VirtualBox Optimizations | Basic | **Aggressive** |
| Software Rendering | Not configured | **Force pixman + fallbacks** |
| Mesa Libraries | mesa only | **mesa + vulkan-swrast + vdpau** |
| Renderer Fallback | None | **Multi-renderer wrapper** |
| Heavy Effects | Enabled | **Disabled** |
| Fallback Compositor | None | **Sway** |
| Environment Variables | Standard | **10+ VBox-specific** |
| Error Logging | Basic | **Extensive (2 log files)** |
| Auto-retry Logic | No | **Yes (3 renderers)** |
| Core Dump Fix | No | **Yes (multiple approaches)** |

## What Gets Installed

### Phase 1: Base System (install-arch)
- Base Arch Linux
- Bootloader with 3 entries
- NetworkManager
- User account

### Phase 2: Hyprland (post-install-vbox.sh)
**Core Compositor:**
- Hyprland (with VBox config)
- Sway (fallback)

**Required Dependencies:**
- xdg-desktop-portal-hyprland
- xdg-desktop-portal-gtk
- polkit + polkit-gnome
- qt5-wayland + qt6-wayland

**Desktop Components:**
- Waybar (3 styles)
- Kitty terminal
- Wofi launcher
- Mako notifications

**VirtualBox:**
- virtualbox-guest-utils
- vboxservice (enabled)

**Themes:**
- All 10 themes
- All 13 utility scripts

## Troubleshooting

### Hyprland Still Crashes

**FIRST: Check the logs!** The wrapper script creates detailed logs:

```bash
# Startup log shows which renderers were tried
cat /tmp/hyprland-startup.log

# Error log shows actual crash details
cat /tmp/hyprland-error.log
```

**Understanding the logs:**
```bash
# Good sign - wrapper is trying renderers:
"Attempting to start Hyprland with WLR_RENDERER=pixman..."
"Attempting to start Hyprland with WLR_RENDERER=gles2..."

# Bad sign - all renderers failed:
"ERROR: Hyprland failed with all renderers"
"Attempted renderers: pixman gles2 vulkan"
"Falling back to Sway..."
```

### Common Issues and Fixes

**1. "can't open display"**
```bash
# Missing xdg-desktop-portal
sudo pacman -S xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
```

**2. "failed to create backend"**
```bash
# Try forcing pixman renderer manually
WLR_RENDERER=pixman WLR_NO_HARDWARE_CURSORS=1 Hyprland
```

**3. "Segmentation fault" with no details**
```bash
# Missing polkit or Mesa libraries
sudo pacman -S polkit polkit-gnome mesa lib32-mesa vulkan-swrast
```

**4. Wrapper doesn't try all renderers**
```bash
# Make sure wrapper is executable
chmod +x ~/.local/bin/start-hyprland.sh

# Run it manually to see output
~/.local/bin/start-hyprland.sh
```

**5. All renderers fail but no Sway fallback**
```bash
# Sway might not be installed
sudo pacman -S sway

# Or start Sway manually
sway
```

### Fallback to Sway

If Hyprland crashes, you'll automatically get Sway:
```bash
# Sway keybindings
Super + Enter    # Terminal
Super + D        # Launcher
Super + Shift + Q # Quit Sway
```

### Manual Testing

Try starting Hyprland manually:
```bash
# From TTY or terminal
Hyprland

# If it crashes, check:
cat /tmp/hyprland-error.log

# Try Sway instead:
sway
```

### Check VirtualBox Detection

```bash
# After installation, verify VBox is detected:
lspci | grep -i virtualbox
lsmod | grep vbox

# Check services:
systemctl status vboxservice
```

## Verification Steps

After installation completes:

```bash
# 1. Check Hyprland installed
which Hyprland

# 2. Check config exists
ls ~/.config/hypr/

# 3. Check VBox config added
grep -i "WLR_NO_HARDWARE_CURSORS" ~/.config/hypr/hyprland.conf

# 4. Check Sway fallback available
which sway

# 5. Try starting Hyprland
Hyprland
# If crashes, should auto-start Sway
```

## Advanced: Manual Hyprland Fixes

If you want to manually fix an existing Hyprland installation in VirtualBox:

```bash
# 1. Add environment variables
cat >> ~/.config/hypr/hyprland.conf << EOF
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1
EOF

# 2. Disable heavy effects
# Edit ~/.config/hypr/hyprland.conf
# Set blur.enabled = false
# Set drop_shadow = false

# 3. Install missing dependencies
sudo pacman -S xdg-desktop-portal-hyprland polkit polkit-gnome

# 4. Install fallback
sudo pacman -S sway

# 5. Reboot
reboot
```

## File Structure

```
cos_hypr_nov19/
├── build-hyprland-iso.sh     # ISO builder with VBox fixes
├── README.md                 # This file
└── iso-output/               # Generated ISOs (after build)
```

## Build Process Details

When you run `build-hyprland-iso.sh`:

1. **Copies custom-arch-setup** to ISO
2. **Creates post-install-vbox.sh** with VBox optimizations
3. **Modifies install-auto.sh** to use post-install-vbox.sh
4. **Adds all required packages** to ISO
5. **Sets proper permissions**
6. **Builds bootable ISO**

The post-install-vbox.sh script:
- Installs Hyprland + all dependencies
- Applies VBox-specific config
- Sets environment variables
- Installs Sway fallback
- Configures auto-start with fallback

## Success Criteria

This ISO is successful if:
- ✅ Boots in VirtualBox (BIOS mode)
- ✅ install-arch runs successfully
- ✅ Base system installs
- ✅ Reboot works
- ✅ Post-install runs without errors
- ✅ Hyprland starts without core dump
- ✅ If Hyprland crashes, Sway starts
- ✅ Desktop is usable

## Comparison to Other Solutions

**vs. customIso_nov19:**
- This has VBox-specific fixes
- Includes Sway fallback
- Modified Hyprland config
- Better error handling

**vs. Basics_Nov19:**
- This includes full Hyprland
- VBox optimizations
- Themes and scripts
- Desktop environment

**vs. Original approach:**
- This uses dedicated VBox post-install
- Simplified for debugging
- Better error messages
- Fallback options

## Known Limitations

1. **3D Acceleration disabled** - VirtualBox limitation
2. **Some animations simplified** - Performance
3. **Blur disabled** - Crashes on software rendering
4. **Sway fallback** - Different compositor if Hyprland fails

These are VirtualBox limitations, not ISO issues. On real hardware with proper GPU, all features work.

## Next Steps After Installation

Once Hyprland is working:

```bash
# Try theme switcher
Super + Shift + T

# Try wallpaper picker
Super + Shift + W

# View all keybindings
Super + /

# If you want to go back to Sway
# Edit ~/.zprofile and change exec Hyprland to exec sway
```

## Support

If you still get core dumps:
1. Check `/tmp/hyprland-error.log`
2. Verify VBox settings (EFI disabled, 3D disabled)
3. Try Sway instead (should work perfectly)
4. Report specific error message

---

**Created:** Nov 19, 2025
**Purpose:** Fix Hyprland core dumps in VirtualBox
**Status:** Ready for testing

This ISO is specifically designed to make Hyprland work in VirtualBox where it normally crashes!
