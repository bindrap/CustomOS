# VM File Sharing Guide

Multiple ways to copy files in/out of your QEMU VM for easy customization.

## Method 1: Shared Folder (Easiest - Real-time)

### From Host (WSL):
```bash
cd /home/user/CustomOS/cos_hypr_nov20

# Put files you want to share in this folder:
echo "test content" > vm-shared/test.txt

# The vm-shared folder is auto-created when you run the VM
```

### In VM (once booted):
```bash
# Mount the shared folder
sudo mkdir -p /mnt/shared
sudo mount -t 9p -o trans=virtio shared /mnt/shared

# Access files
ls /mnt/shared
cat /mnt/shared/test.txt

# Copy files from VM to host
cp ~/.config/hypr/hyprland.conf /mnt/shared/

# Copy files from host to VM
cp /mnt/shared/hyprland.conf ~/.config/hypr/
```

### Auto-mount on boot (in VM):
```bash
# Add to /etc/fstab
echo "shared  /mnt/shared  9p  trans=virtio,version=9p2000.L  0  0" | sudo tee -a /etc/fstab
sudo mkdir -p /mnt/shared
sudo mount -a
```

---

## Method 2: SSH/SCP (Best for remote editing)

### Setup SSH in VM (one-time):
```bash
# In VM terminal
sudo pacman -S openssh
sudo systemctl enable sshd
sudo systemctl start sshd

# Set password if needed
passwd
```

### From Host (WSL):
```bash
# SSH into VM
ssh -p 2222 username@localhost

# Copy file TO VM
scp -P 2222 hyprland.conf username@localhost:~/.config/hypr/

# Copy file FROM VM
scp -P 2222 username@localhost:~/.config/hypr/hyprland.conf ./

# Edit files directly with VSCode remote
code --remote ssh-remote+username@localhost:2222 ~/.config/hypr/
```

---

## Method 3: Mount VM Disk (When VM is OFF)

### Use the inspect script:
```bash
cd /home/user/CustomOS/cos_hypr_nov20

# Stop VM first
./cleanup-qemu.sh

# Mount the disk
./inspect-qemu-disk.sh

# The script will tell you where it's mounted, e.g.:
# Mounted at: /tmp/qemu-mount-xxxxx

# Edit files directly
nvim /tmp/qemu-mount-xxxxx/home/username/.config/hypr/hyprland.conf

# Unmount when done (script does this automatically on Ctrl+C)
```

---

## Quick Examples

### Share your working Hyprland config:
```bash
# Host: Put your config in shared folder
cp ~/my-working-config.conf cos_hypr_nov20/vm-shared/hyprland.conf

# VM: Copy it in
sudo mount -t 9p -o trans=virtio shared /mnt/shared
cp /mnt/shared/hyprland.conf ~/.config/hypr/
hyprctl reload
```

### Extract VM config to customize ISO:
```bash
# VM: Copy current config to shared folder
cp ~/.config/hypr/hyprland.conf /mnt/shared/

# Host: Update source files
cp cos_hypr_nov20/vm-shared/hyprland.conf custom-arch-setup/dotfiles/hypr/

# Rebuild ISO with new config
cd cos_hypr_nov20
./build-hyprland-iso-clean.sh
```

### Edit files with your favorite editor:
```bash
# Host: Use SSH to edit with VSCode/nvim
ssh -p 2222 user@localhost "nvim ~/.config/hypr/hyprland.conf"

# Or mount and edit directly
./cleanup-qemu.sh  # Stop VM
./inspect-qemu-disk.sh  # Mount disk
nvim /tmp/qemu-mount-*/home/user/.config/hypr/hyprland.conf
# Ctrl+C to unmount
./run-installed-qemu.sh  # Start VM with changes
```

---

## Tips

1. **Shared folder is fastest** for iterative testing - no copying needed
2. **SSH is best** for live editing while VM runs
3. **Disk mount is safest** for critical config changes

## Common Workflow

1. Boot VM: `./run-installed-qemu.sh`
2. In VM: `sudo mount -t 9p -o trans=virtio shared /mnt/shared`
3. On host: Edit files in `cos_hypr_nov20/vm-shared/`
4. In VM: Copy and test configs
5. Once working: Copy to `custom-arch-setup/` and rebuild ISO
