# PBOS Swap Setup Guide

## What is Swap?

**Swap** is like extra memory on your hard drive that your system uses when RAM gets full.

Think of it like this:
- **RAM** = Your desk (fast, but limited space)
- **Swap** = File cabinet next to desk (slower, but much more space)

When your desk (RAM) gets full, you move less-used papers to the cabinet (swap) to make room.

## Why You Need Swap

1. **Prevents crashes** when RAM runs out
2. **Enables hibernation** (save session to disk and power off)
3. **Better multitasking** with many programs open
4. **Safety net** for memory-intensive tasks

## Two Ways to Set Up Swap

### Option 1: Swap File (RECOMMENDED for most users)

✅ **Advantages:**
- Easy to create and remove
- Can resize anytime
- No partitioning needed
- Easier to manage

❌ **Disadvantages:**
- Slightly slower than partition (usually negligible)
- May not work with some advanced features

### Option 2: Swap Partition

✅ **Advantages:**
- Slightly faster performance
- Traditional method
- Works with all features

❌ **Disadvantages:**
- Must create during installation
- Hard to resize later
- Takes up a fixed partition slot

## How Much Swap Do You Need?

| Your RAM | Recommended Swap | Why |
|----------|------------------|-----|
| 2-4 GB   | 6-8 GB          | RAM + 2-4GB for hibernation |
| 8 GB     | 8 GB            | Equal to RAM for hibernation |
| 16 GB    | 8 GB            | Don't need more |
| 32 GB+   | 4-8 GB          | Just a safety net |

**Rule of thumb:** If you want hibernation, use swap = RAM. Otherwise, 8GB is plenty.

---

## Method 1: Create Swap File (After Installing PBOS)

This is the easiest method! Do this AFTER you've installed PBOS and rebooted into your system.

### Step 1: Create swap file

```bash
# Create 8GB swap file
sudo dd if=/dev/zero of=/swapfile bs=1M count=8192 status=progress

# For different sizes:
# 4GB:  count=4096
# 8GB:  count=8192
# 16GB: count=16384
```

### Step 2: Set permissions

```bash
sudo chmod 600 /swapfile
```

### Step 3: Format as swap

```bash
sudo mkswap /swapfile
```

### Step 4: Enable swap

```bash
sudo swapon /swapfile
```

### Step 5: Verify it's working

```bash
sudo swapon --show
free -h
```

You should see your swap file listed!

### Step 6: Make it permanent

Add to `/etc/fstab` so swap activates on every boot:

```bash
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Done! ✓

Your swap file is now active and will load automatically on boot.

---

## Method 2: Create Swap Partition (During Partitioning)

Use this method when running `partition-disk` command.

### Step 1: Run partition helper

```bash
partition-disk
```

### Step 2: Select option 2 (Analyze system)

This will show you recommended swap size based on your RAM.

### Step 3: Select option 3 (Create partition)

When asked "Do you want to create a swap partition too?", choose:
- **Option b** - Create root + swap partitions

The script will automatically:
- Calculate optimal swap size based on your RAM
- Split your free space between root and swap
- Format swap partition correctly

### Step 4: During installation

When running `install-arch`, the installer will:
- Automatically detect your swap partition
- Ask if you want to use it
- Enable it automatically

---

## Checking Swap Status

### See if swap is active

```bash
swapon --show
```

Output example:
```
NAME      TYPE SIZE USED PRIO
/swapfile file   8G   0B   -2
```

### See total memory (RAM + swap)

```bash
free -h
```

Output example:
```
              total        used        free      shared  buff/cache   available
Mem:           15Gi       2.0Gi        11Gi       150Mi       2.5Gi        13Gi
Swap:          8.0Gi          0B       8.0Gi
```

---

## Managing Swap

### Temporarily disable swap

```bash
sudo swapoff /swapfile
```

### Re-enable swap

```bash
sudo swapon /swapfile
```

### Remove swap file permanently

```bash
# Disable swap
sudo swapoff /swapfile

# Remove from fstab
sudo sed -i '/swapfile/d' /etc/fstab

# Delete file
sudo rm /swapfile
```

### Resize swap file

```bash
# Disable current swap
sudo swapoff /swapfile

# Remove old file
sudo rm /swapfile

# Create new size (example: 16GB)
sudo dd if=/dev/zero of=/swapfile bs=1M count=16384 status=progress
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## FAQ

### Q: Do I really need swap if I have 32GB RAM?

**A:** Technically no, but it's still recommended as a safety net. Even with lots of RAM, some programs might leak memory, or you might open 100 browser tabs. 4-8GB swap is cheap insurance.

### Q: Can I use both swap file AND swap partition?

**A:** Yes! Linux will use both. It prioritizes based on "priority" values.

### Q: Does swap slow down my system?

**A:** Only if RAM fills up and system starts using swap heavily. With enough RAM, swap just sits there unused. It's free insurance.

### Q: Swap file or partition for gaming?

**A:** For gaming, either works fine. Swap file is easier to manage. Performance difference is negligible on modern SSDs.

### Q: My swap shows 0B used, is it working?

**A:** Yes! That means your RAM hasn't filled up yet. Swap only gets used when needed. It's normal to see 0B used most of the time.

### Q: Should swap be on SSD or HDD?

**A:** SSD if possible (faster), but HDD works too. If you have both, put PBOS and swap on SSD for best performance.

---

## Quick Reference Commands

```bash
# Check swap status
swapon --show
free -h

# Create 8GB swap file
sudo dd if=/dev/zero of=/swapfile bs=1M count=8192
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Remove swap
sudo swapoff /swapfile
sudo rm /swapfile
sudo sed -i '/swapfile/d' /etc/fstab
```

---

## Recommendation for PBOS

**For most users:** Use a **swap file** after installation
- Easier to set up
- Easier to modify
- No partitioning complexity
- Perfectly fine for daily use

**For power users:** Use a **swap partition** if you want:
- Maximum performance
- Hibernation support guaranteed
- Traditional setup

Either way, **8GB swap is plenty** for most systems!

---

*Need help? See other guides in ~/custom-setup/ or run `partition-disk` for guided setup.*
