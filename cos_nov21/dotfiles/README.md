# CustomOS Dotfiles - Hyde-style Configuration

This directory contains a Hyde-style Hyprland configuration with wallpaper pickers, theme switchers, and comprehensive customization tools.

## 🎨 Hyde Features

### Quick Access
- **ALT + C** - Hyde Menu (access all customization options)
- **ALT + H** - Show keybindings help

### Wallpaper Management
- **ALT + SHIFT + W** - Wallpaper Picker (interactive selection)
- **ALT + CTRL + Right** - Next Wallpaper
- **ALT + CTRL + Left** - Previous Wallpaper
- **ALT + CTRL + Up** - Random Wallpaper

### Theme Switching
- **ALT + SHIFT + T** - Theme Selector (choose from 10 themes)
- Themes automatically apply to: Hyprland, Waybar, Kitty, Wofi, Mako
- Themes can have dedicated wallpaper directories

### Available Themes
1. Catppuccin Mocha (default)
2. Dracula
3. Gruvbox Dark
4. Nord
5. Tokyo Night
6. Solarized Dark
7. Rose Pine
8. Everforest
9. Decay Green
10. OneDark

### Setup Wallpapers
```bash
# Create wallpaper directory
mkdir -p ~/Pictures/Wallpapers

# Optional: Create theme-specific directories
mkdir -p ~/Pictures/Wallpapers/catppuccin-mocha
mkdir -p ~/Pictures/Wallpapers/dracula
# etc...

# Add your wallpapers
cp /path/to/wallpapers/* ~/Pictures/Wallpapers/
```

## 📁 Dotfiles Sync

This directory is used to sync dotfiles between your VM and local machine.

## Directory Structure

```
VM:     /home/test/dotfiles
Local:  cos_nov21/rsyncDOTFILES
```

## Usage

### Pull Dotfiles from VM to Local

```bash
bash rsync-pull-dotfiles.sh
```

This will:
- Download dotfiles from the VM to your local machine
- Store them in `cos_nov21/rsyncDOTFILES/`
- Allow you to edit them locally with your preferred editor

### Push Dotfiles from Local to VM

```bash
bash rsync-push-dotfiles.sh
```

This will:
- Upload dotfiles from your local machine to the VM
- Store them in `/home/test/dotfiles` in the VM
- **Automatically ask if you want to apply them to ~/.config/**
- Apply your local changes to the VM instantly

## Workflow

### Initial Setup

1. Start your VM:
   ```bash
   bash run-installed-qemu.sh
   ```

2. Create the dotfiles directory in the VM (SSH into it):
   ```bash
   ssh -p 2222 test@localhost
   mkdir -p ~/dotfiles
   ```

3. Copy your current configs to the dotfiles directory in the VM:
   ```bash
   # Inside the VM
   cp -r ~/.config/hypr ~/dotfiles/
   cp -r ~/.config/waybar ~/dotfiles/
   cp -r ~/.config/kitty ~/dotfiles/
   cp -r ~/.config/wofi ~/dotfiles/
   cp -r ~/.config/mako ~/dotfiles/
   cp ~/.zshrc ~/dotfiles/ 2>/dev/null || true
   cp ~/.bashrc ~/dotfiles/ 2>/dev/null || true
   ```

4. Pull the dotfiles to your local machine:
   ```bash
   bash rsync-pull-dotfiles.sh
   ```

### Development Workflow

1. **Edit locally**: Edit files in `rsyncDOTFILES/` with your favorite editor
2. **Push to VM**: Run `bash rsync-push-dotfiles.sh`
3. **Auto-apply**: Script will ask if you want to apply configs (say yes!)
4. **Reload services**: Restart waybar/kitty to see changes
5. **Iterate**: Repeat as needed

### Applying Changes

The push script **automatically applies configs** after upload if you choose "yes" when prompted.

To see the changes take effect:

1. **Reload services**:
   ```bash
   # For Waybar (via SSH or in VM terminal)
   killall waybar && waybar &

   # For Kitty
   # Open new terminal or press Ctrl+Shift+F5

   # For Hyprland
   # SUPER + Shift + M, then log back in
   ```

2. **Manual application** (if you skipped auto-apply):
   ```bash
   ssh -p 2222 test@localhost
   cp -r ~/dotfiles/* ~/.config/
   ```

## Tips

- Always use **dry run** first (option 1) to see what will be changed
- The scripts use SSH on port 2222 (configured in `run-installed-qemu.sh`)
- Changes are synced incrementally - only modified files are transferred
- Use version control (git) in `rsyncDOTFILES/` to track your changes locally

## Common Commands

```bash
# Preview what would be pulled
bash rsync-pull-dotfiles.sh  # Choose option 1

# Actually pull from VM
bash rsync-pull-dotfiles.sh  # Choose option 2

# Preview what would be pushed
bash rsync-push-dotfiles.sh  # Choose option 1

# Actually push to VM
bash rsync-push-dotfiles.sh  # Choose option 2
```

## Troubleshooting

**VM not reachable:**
- Make sure VM is running: `bash run-installed-qemu.sh`
- Check SSH is working: `ssh -p 2222 test@localhost`

**Permission denied:**
- Make sure scripts are executable: `chmod +x rsync-*.sh`
- Check VM user/password is correct (default: test/test)

**Directory not found:**
- Create the directory in VM: `ssh -p 2222 test@localhost mkdir -p ~/dotfiles`
