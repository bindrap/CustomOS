# Basics_Nov19 - Minimal Working Arch ISO

This folder contains a **completely barebones** Arch Linux ISO builder that is guaranteed to work in VirtualBox.

## Philosophy

Start simple. Get it working. Then add features.

This ISO:
- ✅ Boots in VirtualBox (and any hardware)
- ✅ Has a simple installer
- ✅ Installs basic Arch Linux
- ❌ No desktop environment
- ❌ No Hyprland
- ❌ No themes
- ❌ No customizations

**Once this works**, we can incrementally add features.

## Quick Start

### 1. Build the ISO

```bash
cd Basics_Nov19
bash build-iso-minimal.sh
```

**Time:** 5-10 minutes
**Output:** `../iso-output/minimal-arch-YYYYMMDD-HHMM.iso`

### 2. Test in VirtualBox

**Create VM:**
- Name: MinimalArch
- Type: Linux
- Version: Arch Linux (64-bit)
- RAM: 2GB (minimum)
- Disk: 20GB (minimum)
- Graphics Controller: VMSVGA

**Settings:**
- System → Motherboard → Enable EFI: ✓
- Display → Video Memory: 128MB
- Storage → Attach the ISO

### 3. Boot and Install

1. Start the VM
2. Wait for live environment to boot
3. At the prompt, type: `install-minimal`
4. Follow the prompts:
   - Disk: `sda` (VirtualBox virtual disk)
   - Confirm: `yes`
   - Hostname: anything (e.g., `archvm`)
   - Username: anything (e.g., `user`)
   - Password: choose a password
5. Wait 5-10 minutes
6. Reboot

### 4. Login

After reboot:
- Login with your username and password
- You'll be at a command prompt
- NetworkManager is enabled (will auto-connect)

## What Gets Installed

### Base System
- Linux kernel
- Base packages
- Vim text editor
- NetworkManager
- Sudo

### Boot
- systemd-boot bootloader
- UEFI boot (BIOS also works)
- Two boot entries: normal and fallback

### No Desktop
- No graphical environment
- No Wayland/X11
- Just terminal

## Verification Steps

Once installed and rebooted:

```bash
# Check network
ip addr
ping -c 3 archlinux.org

# Check user
whoami
groups

# Check sudo
sudo pacman -Syu

# Check boot entries
bootctl list

# Install something
sudo pacman -S htop
htop
```

## Next Steps (After This Works)

Once you verify this minimal ISO works perfectly:

### Phase 1: Add Basic GUI
- Add Xorg
- Add a simple window manager (i3 or openbox)
- Verify it works

### Phase 2: Add Wayland
- Add Wayland
- Add sway or cage
- Verify it works

### Phase 3: Add Hyprland
- Add Hyprland
- Add basic Hyprland config
- Verify it works

### Phase 4: Add Customizations
- Add themes
- Add scripts
- Add full Hyde-inspired system

## Troubleshooting

### ISO won't boot in VirtualBox

**Try:**
1. Settings → System → Enable EFI
2. Settings → Display → Graphics Controller: VMSVGA
3. Increase RAM to 4GB
4. Use VirtualBox 7.0+

### Install fails

**Check:**
1. Disk name is correct (`sda` for VirtualBox)
2. VM has internet connection (NAT network)
3. Enough disk space (20GB minimum)

### Can't login after install

**Verify:**
1. Using correct username (not root)
2. Using correct password
3. Caps Lock is off

## File Structure

```
Basics_Nov19/
├── README.md                  # This file
└── build-iso-minimal.sh       # ISO builder
```

## Technical Details

### ISO Builder
- Uses standard archiso releng profile
- Minimal modifications
- Single installer script
- No external dependencies
- ~700MB ISO size

### Installer
- Simple bash script
- GPT partitioning (UEFI-first)
- Three partitions: EFI, Swap, Root
- systemd-boot bootloader
- NetworkManager for networking

### Live Environment
- Runs from RAM
- Minimal packages
- Simple welcome message
- `install-minimal` command

## Why This Approach?

The previous ISO had too many moving parts:
- Multiple scripts
- Package creator
- Custom setup directory
- Offline packages
- VirtualBox detection
- Theme system
- Customizations

**Result:** Hard to debug when something breaks.

This minimal ISO has:
- One script to build
- One script to install
- No external files
- No dependencies
- Easy to understand
- Easy to debug

**Result:** Easy to verify what works and what doesn't.

## Building on This

Once this minimal ISO works in your VirtualBox:

1. **Test thoroughly** - make sure base system is solid
2. **Add ONE feature** at a time
3. **Test after each addition**
4. **Don't add next feature until current one works**

Example progression:
```
Minimal ISO (working)
  → Add Xorg (test)
    → Add window manager (test)
      → Add Wayland (test)
        → Add Hyprland (test)
          → Add one theme (test)
            → Add theme switcher (test)
              → Add all themes (test)
                → Add scripts (test)
                  → Full system ✓
```

## Success Criteria

This ISO is successful if:
- ✅ Boots in VirtualBox without errors
- ✅ Installer runs without errors
- ✅ System boots after installation
- ✅ User can login
- ✅ Network works
- ✅ Can install packages with pacman

**That's it.** Nothing fancy. Just a working foundation.

---

**Created:** Nov 19, 2025
**Purpose:** Get back to basics - build a working foundation first
