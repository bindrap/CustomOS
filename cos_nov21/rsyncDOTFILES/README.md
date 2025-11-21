# Dotfiles Sync Directory

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
- Apply your local changes to the VM

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
3. **Test in VM**: See your changes in the VM
4. **Iterate**: Repeat as needed

### Applying Changes in the VM

After pushing dotfiles, you may need to:

1. **Copy to actual config locations**:
   ```bash
   # SSH into VM
   ssh -p 2222 test@localhost

   # Copy dotfiles to their actual locations
   cp -r ~/dotfiles/hypr/* ~/.config/hypr/
   cp -r ~/dotfiles/waybar/* ~/.config/waybar/
   # etc...
   ```

2. **Reload the window manager**:
   - For Hyprland: `SUPER + Shift + R` or restart Hyprland
   - For Waybar: `killall waybar && waybar &`

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
