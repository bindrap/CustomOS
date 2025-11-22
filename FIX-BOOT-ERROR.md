# Fix: "Failed to execute Arch Linux install medium - Unsupported"

**Error seen:**
```
../systemd/src/boot/boot.c:2714@call_image_start: Failed to execute Arch Linux install medium (x86_64, UEFI)
(\arch\boot\x86_64\vmlinuz-linux): Unsupported
```

This is a **VirtualBox configuration issue**, not an ISO problem.

---

## 🔧 Solution: Fix VirtualBox Settings

### Step 1: Power OFF the VM

**IMPORTANT:** VM must be completely powered off (not saved state).

---

### Step 2: Configure System Settings

**Right-click VM → Settings → System**

#### Motherboard Tab:
- [ ] **Boot Order:**
  - ✅ Optical (move to top)
  - ✅ Hard Disk
  - ❌ Floppy (uncheck)
  - ❌ Network (uncheck)

- [ ] **Chipset:** ICH9
- [ ] **Pointing Device:** PS/2 Mouse
- [ ] **Extended Features:**
  - [ ] **UNCHECK "Enable EFI (special OSes only)"** ← KEY FIX!
  - OR if you want UEFI:
  - [ ] **CHECK "Enable EFI"** but also:
    - Go to Settings → System → Motherboard → **UNCHECK "Secure Boot"**

#### Processor Tab:
- [ ] **CPUs:** 2 or more
- [ ] **Execution Cap:** 100%
- [ ] **PAE/NX:** Enabled

---

### Step 3: Configure Display Settings

**Settings → Display**

- [ ] **Video Memory:** 128 MB
- [ ] **Graphics Controller:** VMSVGA
- [ ] **UNCHECK "Enable 3D Acceleration"** ← CRITICAL!
- [ ] **UNCHECK "Enable 2D Video Acceleration"**

---

### Step 4: Configure Storage

**Settings → Storage**

#### Controller: IDE or SATA
- [ ] Click on **Empty** CD/DVD device
- [ ] Click the CD icon on the right
- [ ] Choose **"Choose a disk file..."**
- [ ] Select: `iso-output/archlinux-2025.11.18-x86_64.iso`
- [ ] **Type:** should show "CD/DVD"

**Controller: SATA** (for hard disk):
- [ ] Hard disk should be attached
- [ ] Type: SATA
- [ ] Size: At least 25GB

---

## 🎯 Recommended Configuration (BIOS Mode - Easier)

This is the SIMPLEST and MOST COMPATIBLE option:

### Complete Settings:

**System → Motherboard:**
- Optical at top of boot order
- Chipset: ICH9
- **UNCHECK "Enable EFI"**

**System → Processor:**
- CPUs: 2
- PAE/NX: Enabled

**Display:**
- Video Memory: 128 MB
- Graphics Controller: VMSVGA
- **3D Acceleration: OFF**

**Storage:**
- IDE/SATA Controller with ISO mounted
- SATA Controller with hard disk (25GB+)

---

## 🎯 Alternative: UEFI Mode (Advanced)

If you specifically need UEFI:

**System → Motherboard:**
- **CHECK "Enable EFI"**
- **UNCHECK "Secure Boot"** ← CRITICAL!
- Optical at top of boot order
- Chipset: ICH9

**All other settings same as above**

---

## ✅ Quick Fix Steps

1. **Power OFF VM**
2. **Settings → System → Motherboard**
3. **Option A (Recommended):** UNCHECK "Enable EFI"
4. **Option B (Advanced):** CHECK "Enable EFI" + UNCHECK "Secure Boot"
5. **Settings → Display**
6. **UNCHECK "3D Acceleration"**
7. **Set Graphics Controller:** VMSVGA
8. **Set Video Memory:** 128 MB
9. **Click OK**
10. **Start VM**

---

## 🔍 Verification

After changing settings and starting VM:

### Should See:
1. VirtualBox logo
2. ISO boots
3. Arch Linux boot menu appears
4. System loads into live environment
5. Welcome message appears

### Should NOT See:
- "Unsupported" error
- "No bootable option" error
- Black screen with blinking cursor
- UEFI shell

---

## 📋 Checklist Before Starting VM

- [ ] VM is powered OFF (not saved)
- [ ] EFI setting configured (disabled for BIOS, or enabled with Secure Boot OFF for UEFI)
- [ ] 3D Acceleration is UNCHECKED
- [ ] Video Memory is 128 MB
- [ ] Graphics Controller is VMSVGA
- [ ] ISO is mounted in optical drive
- [ ] Optical is first in boot order
- [ ] Hard disk exists (25GB+)

---

## 🐛 If Still Not Working

### Try This Exact Configuration:

```
VM Settings:
├── System
│   ├── Motherboard
│   │   ├── Base Memory: 4096 MB
│   │   ├── Boot Order: Optical (first), Hard Disk (second)
│   │   ├── Chipset: ICH9
│   │   ├── Pointing Device: PS/2 Mouse
│   │   └── Extended Features
│   │       ├── Enable I/O APIC: ✓
│   │       ├── Hardware Clock in UTC Time: ✓
│   │       └── Enable EFI: ✗ (UNCHECKED)
│   └── Processor
│       ├── CPUs: 2
│       └── Enable PAE/NX: ✓
│
├── Display
│   ├── Video Memory: 128 MB
│   ├── Monitor Count: 1
│   ├── Graphics Controller: VMSVGA
│   ├── Enable 3D Acceleration: ✗ (UNCHECKED)
│   └── Enable 2D Acceleration: ✗ (UNCHECKED)
│
└── Storage
    ├── Controller: IDE or SATA
    │   └── Optical Drive: archlinux-2025.11.18-x86_64.iso
    └── Controller: SATA
        └── Hard Disk: 25GB+ (VDI, Dynamically allocated)
```

---

## 🔄 Alternative: Create New VM

If problems persist, create a fresh VM:

### Quick VM Creation:

1. **New** → Name: CustomOS-Test
2. **Type:** Linux
3. **Version:** Arch Linux (64-bit)
4. **Memory:** 4096 MB
5. **Hard Disk:** Create virtual hard disk
   - Type: VDI
   - Storage: Dynamically allocated
   - Size: 25 GB
6. **After creation:**
   - Settings → Display → 3D Accel OFF, VMSVGA, 128MB
   - Settings → System → Motherboard → EFI OFF (or ON with Secure Boot OFF)
   - Settings → Storage → Mount ISO
7. **Start VM**

---

## 📝 Summary

**The error is caused by VirtualBox settings, NOT the ISO.**

**Most common causes:**
1. ❌ Secure Boot enabled (in EFI mode)
2. ❌ Wrong firmware type configuration
3. ❌ 3D acceleration enabled

**Quick fix:**
- Disable EFI (use BIOS mode), OR
- Keep EFI but disable Secure Boot
- Always disable 3D acceleration

---

## ✅ Expected Result

After correct configuration:

1. VM boots from ISO
2. Arch Linux boot menu appears
3. System loads
4. Welcome banner shows
5. Can run `install-arch`

---

**Try the BIOS mode (EFI disabled) first - it's simpler and more compatible!**
