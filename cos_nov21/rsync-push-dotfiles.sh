#!/bin/bash

# Push Dotfiles from Local Machine to VM
# Syncs dotfiles from your local development environment to the VM

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
echo "  Push Dotfiles to VM"
echo "  Local Machine → VM"
echo -e "==================================================${NC}"
echo ""
echo "Source: $LOCAL_DIR"
echo "Dest:   $VM_USER@$VM_HOST:$VM_PORT:$VM_DIR"
echo ""

# Check if local directory exists
if [ ! -d "$LOCAL_DIR" ]; then
    echo -e "${RED}✗${NC} Local dotfiles directory not found: $LOCAL_DIR"
    echo ""
    echo "Create it first, or pull from VM:"
    echo "  mkdir -p $LOCAL_DIR"
    echo "  bash rsync-pull-dotfiles.sh"
    echo ""
    exit 1
fi

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

# Create VM directory if it doesn't exist
echo -e "${YELLOW}→${NC} Ensuring VM dotfiles directory exists..."
ssh -p "$VM_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "$VM_USER@$VM_HOST" "mkdir -p $VM_DIR" 2>/dev/null || true
echo -e "${GREEN}✓${NC} VM directory ready"

# Ask for confirmation
echo ""
echo -e "${YELLOW}Options:${NC}"
echo "  1. Dry run (preview changes)"
echo "  2. Push all dotfiles"
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
            "$LOCAL_DIR/" \
            "$VM_USER@$VM_HOST:$VM_DIR/"
        echo ""
        echo -e "${GREEN}This was a dry run. No files were changed.${NC}"
        echo "Run again and choose option 2 to actually push files."
        ;;
    2)
        echo ""
        echo -e "${YELLOW}→${NC} Pushing dotfiles to VM..."
        rsync -avz --progress \
            -e "ssh -p $VM_PORT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
            "$LOCAL_DIR/" \
            "$VM_USER@$VM_HOST:$VM_DIR/"

        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}✓${NC} Dotfiles successfully pushed to VM!"
            echo ""
            echo "Files are now in VM at: $VM_DIR"

            # Ask if user wants to apply the configs automatically
            echo ""
            echo -e "${YELLOW}Apply configs to ~/.config/ now?${NC}"
            echo "  This will run: cp -r ~/dotfiles/* ~/.config/"
            read -p "Apply configs? (yes/no): " APPLY_CONFIGS

            if [ "$APPLY_CONFIGS" = "yes" ]; then
                echo ""
                echo -e "${YELLOW}→${NC} Applying configs to ~/.config/..."

                # Copy dotfiles to actual config locations
                ssh -p "$VM_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                    "$VM_USER@$VM_HOST" "cp -r $VM_DIR/* ~/.config/" 2>/dev/null

                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✓${NC} Configs applied successfully!"
                    echo ""
                    echo -e "${BLUE}Restart services to see changes:${NC}"
                    echo "  • Waybar: killall waybar && waybar &"
                    echo "  • Hyprland: SUPER + Shift + M, then log back in"
                    echo "  • Kitty: Open new terminal or Ctrl+Shift+F5"
                else
                    echo -e "${YELLOW}⚠${NC} Some files may not have copied (this is often normal)"
                    echo "    Non-existent directories are skipped automatically"
                fi
            else
                echo ""
                echo -e "${BLUE}Skipped config application.${NC}"
                echo "To apply manually, SSH into VM and run:"
                echo "  ssh -p $VM_PORT $VM_USER@$VM_HOST"
                echo "  cp -r ~/dotfiles/* ~/.config/"
            fi
        else
            echo ""
            echo -e "${RED}✗${NC} Failed to push dotfiles"
            exit 1
        fi
        ;;
    *)
        echo "Cancelled"
        exit 0
        ;;
esac
