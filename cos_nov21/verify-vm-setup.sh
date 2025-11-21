#!/bin/bash

# Verify VM Setup - Check if SSH and rsync are working
# This helps troubleshoot connection issues

VM_USER="test"
VM_HOST="localhost"
VM_PORT="2222"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=================================================="
echo "  VM Setup Verification"
echo "  Checking SSH and rsync availability"
echo -e "==================================================${NC}"
echo ""

# Check if VM is reachable
echo -e "${YELLOW}→${NC} Checking VM connectivity on port $VM_PORT..."
if ! nc -z -w 5 "$VM_HOST" "$VM_PORT" 2>/dev/null; then
    echo -e "${RED}✗${NC} Cannot connect to VM on port $VM_PORT"
    echo ""
    echo "Make sure the VM is running:"
    echo "  bash run-installed-qemu.sh"
    echo ""
    exit 1
fi
echo -e "${GREEN}✓${NC} VM is reachable on port $VM_PORT"

# Check SSH connection
echo ""
echo -e "${YELLOW}→${NC} Testing SSH connection..."
echo "    (You'll need to enter password: test)"
if ssh -p "$VM_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "$VM_USER@$VM_HOST" "echo 'SSH connection successful'" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} SSH connection works"
else
    echo -e "${RED}✗${NC} SSH connection failed"
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Make sure sshd is running in VM"
    echo "  2. Try manual SSH: ssh -p $VM_PORT $VM_USER@$VM_HOST"
    echo ""
    exit 1
fi

# Check if rsync is installed on VM
echo ""
echo -e "${YELLOW}→${NC} Checking if rsync is installed in VM..."
RSYNC_CHECK=$(ssh -p "$VM_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "$VM_USER@$VM_HOST" "which rsync 2>/dev/null" 2>/dev/null)

if [ -n "$RSYNC_CHECK" ]; then
    echo -e "${GREEN}✓${NC} rsync is installed at: $RSYNC_CHECK"

    # Get rsync version
    RSYNC_VERSION=$(ssh -p "$VM_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        "$VM_USER@$VM_HOST" "rsync --version 2>/dev/null | head -1" 2>/dev/null)
    echo "    Version: $RSYNC_VERSION"
else
    echo -e "${RED}✗${NC} rsync is NOT installed in VM"
    echo ""
    echo "Installing rsync now..."
    ssh -p "$VM_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        "$VM_USER@$VM_HOST" "sudo pacman -S --noconfirm rsync" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} rsync installed successfully"
    else
        echo -e "${RED}✗${NC} Failed to install rsync"
        echo ""
        echo "Please install manually:"
        echo "  ssh -p $VM_PORT $VM_USER@$VM_HOST"
        echo "  sudo pacman -S --noconfirm rsync"
        exit 1
    fi
fi

# Check if dotfiles directory exists
echo ""
echo -e "${YELLOW}→${NC} Checking if dotfiles directory exists in VM..."
ssh -p "$VM_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "$VM_USER@$VM_HOST" "test -d /home/$VM_USER/dotfiles" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Dotfiles directory exists: /home/$VM_USER/dotfiles"
else
    echo -e "${YELLOW}⚠${NC} Dotfiles directory does not exist"
    echo "    Creating it now..."
    ssh -p "$VM_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        "$VM_USER@$VM_HOST" "mkdir -p /home/$VM_USER/dotfiles" 2>/dev/null
    echo -e "${GREEN}✓${NC} Created dotfiles directory"
fi

# Test rsync transfer (small test)
echo ""
echo -e "${YELLOW}→${NC} Testing rsync transfer..."
echo "test" > /tmp/rsync_test_$$
if rsync -avz -e "ssh -p $VM_PORT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
    /tmp/rsync_test_$$ "$VM_USER@$VM_HOST:/tmp/" 2>&1 | grep -q "sent"; then
    echo -e "${GREEN}✓${NC} rsync transfer test successful"
    rm -f /tmp/rsync_test_$$
else
    echo -e "${RED}✗${NC} rsync transfer test failed"
    rm -f /tmp/rsync_test_$$
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}=================================================="
echo "  ✓ All checks passed!"
echo -e "==================================================${NC}"
echo ""
echo "Your VM setup is ready for dotfiles sync."
echo ""
echo "Next steps:"
echo "  1. Pull dotfiles: bash rsync-pull-dotfiles.sh"
echo "  2. Push dotfiles: bash rsync-push-dotfiles.sh"
echo ""
