#!/bin/bash

# VirtualBox Configuration Fixer
# This script configures your VirtualBox VM for proper Arch ISO booting

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  VirtualBox Configuration Fixer for CustomOS              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if VBoxManage is available
if ! command -v VBoxManage &> /dev/null; then
    echo "❌ VBoxManage not found!"
    echo ""
    echo "Please configure VirtualBox manually:"
    echo ""
    echo "1. Power OFF your VM completely"
    echo "2. Right-click VM → Settings"
    echo "3. System → Motherboard → UNCHECK 'Enable EFI'"
    echo "4. Display → UNCHECK '3D Acceleration'"
    echo "5. Display → Graphics Controller: VMSVGA"
    echo "6. Display → Video Memory: 128 MB"
    echo "7. Click OK"
    echo "8. Start VM"
    echo ""
    exit 1
fi

# List VMs
echo "Available VMs:"
VBoxManage list vms
echo ""

read -p "Enter VM name (exactly as shown above): " VM_NAME

if [ -z "$VM_NAME" ]; then
    echo "❌ No VM name provided"
    exit 1
fi

# Check if VM exists
if ! VBoxManage showvminfo "$VM_NAME" &>/dev/null; then
    echo "❌ VM '$VM_NAME' not found!"
    exit 1
fi

# Check if VM is running
VM_STATE=$(VBoxManage showvminfo "$VM_NAME" | grep "State:" | awk '{print $2}')
if [ "$VM_STATE" = "running" ]; then
    echo "❌ VM is running! Please power it OFF first."
    exit 1
fi

echo ""
echo "Configuring VM: $VM_NAME"
echo ""

# Disable EFI (use BIOS mode)
echo "→ Disabling EFI (using BIOS mode)..."
VBoxManage modifyvm "$VM_NAME" --firmware bios

# Configure display
echo "→ Configuring display settings..."
VBoxManage modifyvm "$VM_NAME" --graphicscontroller vmsvga
VBoxManage modifyvm "$VM_NAME" --vram 128
VBoxManage modifyvm "$VM_NAME" --accelerate3d off
VBoxManage modifyvm "$VM_NAME" --accelerate2dvideo off

# Configure system
echo "→ Configuring system settings..."
VBoxManage modifyvm "$VM_NAME" --chipset ich9
VBoxManage modifyvm "$VM_NAME" --ioapic on

# Set boot order
echo "→ Setting boot order..."
VBoxManage modifyvm "$VM_NAME" --boot1 dvd
VBoxManage modifyvm "$VM_NAME" --boot2 disk
VBoxManage modifyvm "$VM_NAME" --boot3 none
VBoxManage modifyvm "$VM_NAME" --boot4 none

echo ""
echo "✅ Configuration complete!"
echo ""
echo "Settings applied:"
echo "  ✓ Firmware: BIOS (EFI disabled)"
echo "  ✓ Graphics Controller: VMSVGA"
echo "  ✓ Video Memory: 128 MB"
echo "  ✓ 3D Acceleration: OFF"
echo "  ✓ 2D Acceleration: OFF"
echo "  ✓ Boot Order: DVD, Disk"
echo ""
echo "Next steps:"
echo "  1. Make sure ISO is mounted in VM storage settings"
echo "  2. Start the VM"
echo "  3. It should boot from the ISO"
echo ""
