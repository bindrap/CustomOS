#!/bin/bash

# CustomOS Package Manager
# Easy package management for your ISO

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PACKAGE_FILE="packages.conf"

clear
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗
║   ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔════╝ ██╔════╝
║   ██████╔╝███████║██║     █████╔╝ ███████║██║  ███╗█████╗
║   ██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══██║██║   ██║██╔══╝
║   ██║     ██║  ██║╚██████╗██║  ██╗██║  ██║╚██████╔╝███████╗
║   ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
║                                                           ║
║              CustomOS Package Manager                     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if packages.conf exists
if [ ! -f "$PACKAGE_FILE" ]; then
    echo -e "${RED}✗${NC} Package file not found: $PACKAGE_FILE"
    exit 1
fi

# Function to count packages
count_packages() {
    grep -v '^#' "$PACKAGE_FILE" | grep -v '^$' | wc -l
}

# Function to list all packages
list_packages() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}Current Packages ($(count_packages) total)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""

    local current_section=""
    while IFS= read -r line; do
        # Section headers
        if [[ $line =~ ^#.*═ ]]; then
            current_section=$(echo "$line" | sed 's/^# *//' | sed 's/ *═.*//')
            echo -e "${BLUE}▼ $current_section${NC}"
        # Active packages
        elif [[ ! $line =~ ^# ]] && [[ -n $line ]]; then
            echo -e "  ${GREEN}✓${NC} $line"
        # Commented packages
        elif [[ $line =~ ^#[^=] ]] && [[ ! $line =~ Optional ]] && [[ ! $line =~ ═ ]]; then
            pkg=$(echo "$line" | sed 's/^# *//')
            if [ -n "$pkg" ]; then
                echo -e "  ${YELLOW}○${NC} $pkg ${YELLOW}(disabled)${NC}"
            fi
        fi
    done < "$PACKAGE_FILE"
    echo ""
}

# Function to search packages
search_package() {
    local query="$1"
    echo -e "${YELLOW}→${NC} Searching for: $query"
    echo ""

    pacman -Ss "$query" | head -20

    echo ""
    echo -e "${CYAN}To add a package:${NC}"
    echo "  1. Edit packages.conf"
    echo "  2. Add package name to appropriate section"
    echo "  3. Run: bash manage-packages.sh rebuild"
}

# Function to add package
add_package() {
    local package="$1"

    # Check if package exists in repos
    if ! pacman -Ss "^$package$" &>/dev/null; then
        echo -e "${YELLOW}⚠${NC}  Package not found in repos: $package"
        echo -e "${YELLOW}→${NC} Searching for similar packages..."
        pacman -Ss "$package" | head -10
        echo ""
        read -p "Add anyway? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            echo "Cancelled."
            return
        fi
    fi

    # Check if already in file
    if grep -q "^$package$" "$PACKAGE_FILE"; then
        echo -e "${GREEN}✓${NC} Package already active: $package"
        return
    fi

    # Check if commented out
    if grep -q "^# *$package" "$PACKAGE_FILE"; then
        # Uncomment it
        sed -i "s/^# *$package$/$package/" "$PACKAGE_FILE"
        echo -e "${GREEN}✓${NC} Enabled package: $package"
    else
        # Add to custom section
        if ! grep -q "CUSTOM ADDITIONS" "$PACKAGE_FILE"; then
            echo "" >> "$PACKAGE_FILE"
            echo "# ═══════════════════════════════════════════════════════════════" >> "$PACKAGE_FILE"
            echo "# CUSTOM ADDITIONS" >> "$PACKAGE_FILE"
            echo "# ═══════════════════════════════════════════════════════════════" >> "$PACKAGE_FILE"
            echo "" >> "$PACKAGE_FILE"
        fi
        echo "$package" >> "$PACKAGE_FILE"
        echo -e "${GREEN}✓${NC} Added package: $package"
    fi
}

# Function to remove package
remove_package() {
    local package="$1"

    # Check if in file
    if ! grep -q "^$package$" "$PACKAGE_FILE"; then
        echo -e "${RED}✗${NC} Package not found in active packages: $package"
        return
    fi

    # Comment it out (don't delete, so user can re-enable easily)
    sed -i "s/^$package$/# $package/" "$PACKAGE_FILE"
    echo -e "${GREEN}✓${NC} Disabled package: $package"
}

# Function to rebuild cache and ISO
rebuild() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} Rebuilding Package Cache and ISO"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    # Ask for confirmation
    local pkg_count=$(count_packages)
    echo "Current package count: $pkg_count"
    echo ""
    echo "This will:"
    echo "  1. Download all packages (~2-3GB, 30-60 min)"
    echo "  2. Create deployment package"
    echo "  3. Build bootable ISO (10-15 min)"
    echo ""
    read -p "Continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        return
    fi

    # Run build scripts
    echo ""
    echo -e "${YELLOW}→${NC} Step 1/3: Downloading packages..."
    bash create-offline-cache.sh || {
        echo -e "${RED}✗${NC} Failed to download packages"
        return 1
    }

    echo ""
    echo -e "${YELLOW}→${NC} Step 2/3: Creating deployment package..."
    bash package-creator.sh || {
        echo -e "${RED}✗${NC} Failed to create package"
        return 1
    }

    echo ""
    echo -e "${YELLOW}→${NC} Step 3/3: Building ISO..."
    bash build-iso.sh || {
        echo -e "${RED}✗${NC} Failed to build ISO"
        return 1
    }

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC} ✓ Build Complete!"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Your ISO is ready:"
    ls -lh ~/iso-output/*.iso 2>/dev/null | tail -1
}

# Function to show package info
info_package() {
    local package="$1"
    pacman -Si "$package" 2>/dev/null || pacman -Ss "$package"
}

# Function to show presets
show_presets() {
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} Available Package Presets"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${GREEN}1. Minimal${NC} (Default)"
    echo "   Base Hyprland + essentials (~80 packages)"
    echo ""

    echo -e "${GREEN}2. Gaming${NC}"
    echo "   + Steam, Lutris, Wine, GameMode"
    echo ""

    echo -e "${GREEN}3. Development${NC}"
    echo "   + VS Code, Rust, Go, GCC, Clang"
    echo ""

    echo -e "${GREEN}4. Content Creation${NC}"
    echo "   + GIMP, Inkscape, Blender, Kdenlive"
    echo ""

    echo -e "${GREEN}5. Office${NC}"
    echo "   + LibreOffice, Thunderbird"
    echo ""

    echo -e "${GREEN}6. Full${NC}"
    echo "   Everything included (large ISO)"
    echo ""

    read -p "Apply preset? (1-6 or n): " choice

    case $choice in
        1) echo "Already using minimal preset!" ;;
        2) apply_preset_gaming ;;
        3) apply_preset_dev ;;
        4) apply_preset_creative ;;
        5) apply_preset_office ;;
        6) apply_preset_full ;;
        *) echo "Cancelled." ;;
    esac
}

apply_preset_gaming() {
    echo -e "${YELLOW}→${NC} Applying gaming preset..."
    sed -i 's/^# steam$/steam/' "$PACKAGE_FILE"
    sed -i 's/^# lutris$/lutris/' "$PACKAGE_FILE"
    sed -i 's/^# wine$/wine/' "$PACKAGE_FILE"
    sed -i 's/^# gamemode$/gamemode/' "$PACKAGE_FILE"
    echo -e "${GREEN}✓${NC} Gaming packages enabled"
}

apply_preset_dev() {
    echo -e "${YELLOW}→${NC} Applying development preset..."
    sed -i 's/^# code$/code/' "$PACKAGE_FILE"
    sed -i 's/^# rust$/rust/' "$PACKAGE_FILE"
    sed -i 's/^# go$/go/' "$PACKAGE_FILE"
    sed -i 's/^# gcc$/gcc/' "$PACKAGE_FILE"
    sed -i 's/^# clang$/clang/' "$PACKAGE_FILE"
    echo -e "${GREEN}✓${NC} Development packages enabled"
}

apply_preset_creative() {
    echo -e "${YELLOW}→${NC} Applying content creation preset..."
    sed -i 's/^# gimp$/gimp/' "$PACKAGE_FILE"
    sed -i 's/^# inkscape$/inkscape/' "$PACKAGE_FILE"
    sed -i 's/^# blender$/blender/' "$PACKAGE_FILE"
    sed -i 's/^# krita$/krita/' "$PACKAGE_FILE"
    echo -e "${GREEN}✓${NC} Creative packages enabled"
}

apply_preset_office() {
    echo -e "${YELLOW}→${NC} Applying office preset..."
    sed -i 's/^# libreoffice-fresh$/libreoffice-fresh/' "$PACKAGE_FILE"
    echo -e "${GREEN}✓${NC} Office packages enabled"
}

apply_preset_full() {
    echo -e "${YELLOW}→${NC} Applying full preset (enabling all optional packages)..."
    # Uncomment all commented packages (except section headers)
    sed -i 's/^# \([a-z]\)/\1/' "$PACKAGE_FILE"
    echo -e "${GREEN}✓${NC} All packages enabled"
    echo -e "${YELLOW}⚠${NC}  Warning: This will create a very large ISO!"
}

# Main menu
show_menu() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}Package Management Menu${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    echo "1. List all packages"
    echo "2. Search packages"
    echo "3. Add package"
    echo "4. Remove package"
    echo "5. Package info"
    echo "6. Show presets"
    echo "7. Edit packages.conf"
    echo "8. Rebuild cache & ISO"
    echo "9. Quick rebuild (skip cache)"
    echo "0. Exit"
    echo ""
    read -p "Choice: " choice

    case $choice in
        1) list_packages; read -p "Press enter to continue..."; show_menu ;;
        2) read -p "Search query: " query; search_package "$query"; read -p "Press enter..."; show_menu ;;
        3) read -p "Package name: " pkg; add_package "$pkg"; read -p "Press enter..."; show_menu ;;
        4) read -p "Package name: " pkg; remove_package "$pkg"; read -p "Press enter..."; show_menu ;;
        5) read -p "Package name: " pkg; info_package "$pkg"; read -p "Press enter..."; show_menu ;;
        6) show_presets; read -p "Press enter..."; show_menu ;;
        7) ${EDITOR:-vim} "$PACKAGE_FILE"; show_menu ;;
        8) rebuild ;;
        9) bash package-creator.sh && bash build-iso.sh ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid choice"; sleep 1; show_menu ;;
    esac
}

# Handle command line arguments
case "${1:-}" in
    list) list_packages ;;
    search) search_package "$2" ;;
    add) add_package "$2" ;;
    remove) remove_package "$2" ;;
    info) info_package "$2" ;;
    rebuild) rebuild ;;
    presets) show_presets ;;
    edit) ${EDITOR:-vim} "$PACKAGE_FILE" ;;
    *) show_menu ;;
esac
