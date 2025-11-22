#!/bin/bash

# Script Validator and Fixer for CustomOS
# Tests all critical scripts and reports issues

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   CustomOS Script Validator                               ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${YELLOW}Testing all critical scripts...${NC}"
echo ""

ERRORS=0

# Test 1: Check if files exist
echo -e "${BLUE}[1/6]${NC} Checking if all files exist..."
FILES=(
    "build-iso-docker.sh"
    "custom-arch-setup/install-auto.sh"
    "custom-arch-setup/post-install.sh"
    "custom-arch-setup/dotfiles/hypr/hyprland.conf"
)

for file in "${FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file - MISSING!"
        ((ERRORS++))
    fi
done

# Test 2: Check syntax
echo ""
echo -e "${BLUE}[2/6]${NC} Checking script syntax..."
SCRIPTS=(
    "build-iso-docker.sh"
    "custom-arch-setup/install-auto.sh"
    "custom-arch-setup/post-install.sh"
)

for script in "${SCRIPTS[@]}"; do
    if bash -n "$SCRIPT_DIR/$script" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $script - syntax OK"
    else
        echo -e "  ${RED}✗${NC} $script - SYNTAX ERROR!"
        bash -n "$SCRIPT_DIR/$script" 2>&1 | head -3
        ((ERRORS++))
    fi
done

# Test 3: Check permissions
echo ""
echo -e "${BLUE}[3/6]${NC} Checking execute permissions..."
for script in "${SCRIPTS[@]}"; do
    if [ -x "$SCRIPT_DIR/$script" ]; then
        echo -e "  ${GREEN}✓${NC} $script - executable"
    else
        echo -e "  ${YELLOW}!${NC} $script - not executable (fixing...)"
        chmod +x "$SCRIPT_DIR/$script"
    fi
done

# Test 4: Check for required commands in scripts
echo ""
echo -e "${BLUE}[4/6]${NC} Checking for critical components..."

# Check install-arch command creation
if grep -q "install-arch" "$SCRIPT_DIR/build-iso-docker.sh"; then
    echo -e "  ${GREEN}✓${NC} install-arch command - configured"
else
    echo -e "  ${RED}✗${NC} install-arch command - MISSING!"
    ((ERRORS++))
fi

# Check file permissions configuration
if grep -q "file_permissions" "$SCRIPT_DIR/build-iso-docker.sh"; then
    echo -e "  ${GREEN}✓${NC} file_permissions - configured"
else
    echo -e "  ${RED}✗${NC} file_permissions - MISSING!"
    ((ERRORS++))
fi

# Check VirtualBox environment variables
if grep -q "WLR_RENDERER" "$SCRIPT_DIR/custom-arch-setup/dotfiles/hypr/hyprland.conf"; then
    echo -e "  ${GREEN}✓${NC} VirtualBox compatibility - configured"
else
    echo -e "  ${YELLOW}!${NC} VirtualBox compatibility - not configured"
fi

# Test 5: Check post-install.sh
echo ""
echo -e "${BLUE}[5/6]${NC} Checking post-install.sh configuration..."

if grep -q "INSTALL_MODE" "$SCRIPT_DIR/custom-arch-setup/post-install.sh"; then
    echo -e "  ${GREEN}✓${NC} Online/Offline mode detection - present"
else
    echo -e "  ${RED}✗${NC} Online/Offline mode detection - MISSING!"
    ((ERRORS++))
fi

if grep -q "virtualbox-guest-utils" "$SCRIPT_DIR/custom-arch-setup/post-install.sh"; then
    echo -e "  ${GREEN}✓${NC} VirtualBox guest utils - will be installed"
else
    echo -e "  ${YELLOW}!${NC} VirtualBox guest utils - not in package list"
fi

# Test 6: Check Hyprland config
echo ""
echo -e "${BLUE}[6/6]${NC} Checking Hyprland configuration..."

if [ -f "$SCRIPT_DIR/custom-arch-setup/dotfiles/hypr/hyprland.conf" ]; then
    if grep -q "WLR_NO_HARDWARE_CURSORS" "$SCRIPT_DIR/custom-arch-setup/dotfiles/hypr/hyprland.conf"; then
        echo -e "  ${GREEN}✓${NC} Hardware cursor disabled"
    else
        echo -e "  ${YELLOW}!${NC} Hardware cursor setting missing"
    fi

    if grep -q "WLR_RENDERER" "$SCRIPT_DIR/custom-arch-setup/dotfiles/hypr/hyprland.conf"; then
        echo -e "  ${GREEN}✓${NC} Software renderer configured"
    else
        echo -e "  ${YELLOW}!${NC} Software renderer not configured"
    fi
else
    echo -e "  ${RED}✗${NC} hyprland.conf - MISSING!"
    ((ERRORS++))
fi

# Summary
echo ""
echo "════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Your scripts are ready to build an ISO:"
    echo "  ${BLUE}./build-iso-docker.sh${NC}"
else
    echo -e "${RED}✗ Found $ERRORS errors!${NC}"
    echo ""
    echo "Please fix the errors above before building ISO"
fi
echo "════════════════════════════════════════"
echo ""
