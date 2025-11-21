#!/bin/bash

# Pull Dotfiles from VM to Local Machine
# Syncs dotfiles from the VM to your local development environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="$SCRIPT_DIR/rsyncDOTFILES"
VM_USER="test"
VM_HOST="localhost"
VM_PORT="2222"
VM_DIR="/home/$VM_USER/dotfiles"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=================================================="
echo "  Pull Dotfiles from VM"
echo "  VM → Local Machine"
echo -e "==================================================${NC}"
echo ""
echo "Source: $VM_USER@$VM_HOST:$VM_PORT:$VM_DIR"
echo "Dest:   $LOCAL_DIR"
echo ""

# Check if VM is accessible
echo -e "${YELLOW}→${NC} Checking VM connectivity..."
if ! nc -z -w 5 "$VM_HOST" "$VM_PORT" 2>/dev/null; then
    echo -e "${RED}✗${NC} Cannot connect to VM on port $VM_PORT"
    echo ""
    echo "Make sure the VM is running:"
    echo "  bash run-installed-qemu.sh"
    echo ""
    exit 1
fi
echo -e "${GREEN}✓${NC} VM is reachable on port $VM_PORT"

# Create local directory if it doesn't exist
mkdir -p "$LOCAL_DIR"

# Ask for confirmation
echo ""
echo -e "${YELLOW}Options:${NC}"
echo "  1. Dry run (preview changes)"
echo "  2. Pull all dotfiles"
echo "  3. Cancel"
echo ""
read -p "Choice (1/2/3): " CHOICE

case $CHOICE in
    1)
        echo ""
        echo -e "${BLUE}Dry run - showing what would be transferred:${NC}"
        echo ""
        rsync -avz --dry-run \
            -e "ssh -p $VM_PORT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
            "$VM_USER@$VM_HOST:$VM_DIR/" \
            "$LOCAL_DIR/"
        echo ""
        echo -e "${GREEN}This was a dry run. No files were changed.${NC}"
        echo "Run again and choose option 2 to actually pull files."
        ;;
    2)
        echo ""
        echo -e "${YELLOW}→${NC} Pulling dotfiles from VM..."
        rsync -avz --progress \
            -e "ssh -p $VM_PORT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
            "$VM_USER@$VM_HOST:$VM_DIR/" \
            "$LOCAL_DIR/"

        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}✓${NC} Dotfiles successfully pulled from VM!"
            echo ""
            echo "Files are now in: $LOCAL_DIR"
        else
            echo ""
            echo -e "${RED}✗${NC} Failed to pull dotfiles"
            exit 1
        fi
        ;;
    *)
        echo "Cancelled"
        exit 0
        ;;
esac
