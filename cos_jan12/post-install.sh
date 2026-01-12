#!/bin/bash

# CustomOS Jan12 Post-Installation Script
# Lightweight XFCE setup optimized for 4GB RAM laptops

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
MAGENTA="\033[0;35m"
NC="\033[0m"

clear
echo -e "${MAGENTA}"
cat << 'EOF_BANNER'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ██████╗ ██████╗  ██████╗ ███████╗                      ║
║   ██╔══██╗██╔══██╗██╔═══██╗██╔════╝                      ║
║   ██████╔╝██████╔╝██║   ██║███████╗                      ║
║   ██╔═══╝ ██╔══██╗██║   ██║╚════██║                      ║
║   ██║     ██████╔╝╚██████╔╝███████║                      ║
║   ╚═╝     ╚═════╝  ╚═════╝ ╚══════╝                      ║
║                                                           ║
║           Lightweight XFCE Edition                        ║
║        Optimized for 4GB RAM Laptops                      ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF_BANNER

echo -e "${NC}"

echo ""
echo -e "${GREEN}Installing lightweight XFCE desktop environment...${NC}"
echo -e "${YELLOW}Optimized for low-spec hardware and light gaming.${NC}"
echo ""
read -p "Press ENTER to continue..."

# Check internet
require_internet() {
    echo ""
    echo -e "${YELLOW}→${NC} Checking internet connectivity..."

    local attempts=3
    local delay=5
    local urls=("https://archlinux.org" "https://github.com" "http://1.1.1.1")

    for attempt in $(seq 1 "$attempts"); do
        echo -e "${BLUE}Attempt ${attempt}/${attempts}...${NC}"

        if command -v curl &>/dev/null; then
            for url in "${urls[@]}"; do
                if curl --silent --head --fail --connect-timeout 5 --max-time 10 "$url" >/dev/null; then
                    echo -e "${GREEN}✓${NC} Internet connection detected"
                    return 0
                fi
            done
        fi

        if command -v ping &>/dev/null; then
            if ping -c 1 -W 3 archlinux.org &>/dev/null || ping -c 1 -W 3 1.1.1.1 &>/dev/null; then
                echo -e "${GREEN}✓${NC} Internet connection detected"
                return 0
            fi
        fi

        if [ "$attempt" -lt "$attempts" ]; then
            echo -e "${YELLOW}No connection detected yet. Retrying in ${delay}s...${NC}"
            sleep "$delay"
        fi
    done

    echo -e "${RED}✗${NC} No internet connection after ${attempts} attempts!"
    echo -e "${YELLOW}Installation requires internet. Please connect and rerun.${NC}"
    exit 1
}

require_internet

# Update system
echo ""
echo -e "${YELLOW}→${NC} Updating system packages..."
sudo pacman -Syu --noconfirm

# Install XFCE and essential components
echo ""
echo -e "${YELLOW}→${NC} Installing XFCE desktop environment..."
sudo pacman -S --needed --noconfirm \
    xfce4 \
    xfce4-goodies \
    xorg-server \
    xorg-xinit \
    lightdm \
    lightdm-gtk-greeter \
    lightdm-gtk-greeter-settings

# Install essential applications
echo ""
echo -e "${YELLOW}→${NC} Installing essential applications..."
sudo pacman -S --needed --noconfirm \
    firefox \
    thunar \
    thunar-archive-plugin \
    thunar-media-tags-plugin \
    file-roller \
    xarchiver \
    gvfs \
    gvfs-mtp \
    network-manager-applet \
    pavucontrol \
    pulseaudio \
    pulseaudio-alsa \
    alsa-utils \
    mousepad \
    xfce4-terminal \
    xfce4-screenshooter \
    xfce4-taskmanager \
    xfce4-notifyd \
    xfce4-power-manager

# Install lightweight system tools
echo ""
echo -e "${YELLOW}→${NC} Installing system utilities..."
sudo pacman -S --needed --noconfirm \
    git \
    vim \
    neovim \
    htop \
    btop \
    fastfetch \
    wget \
    curl \
    unzip \
    zip \
    p7zip \
    rsync \
    nano

# Install fonts
echo ""
echo -e "${YELLOW}→${NC} Installing fonts..."
sudo pacman -S --needed --noconfirm \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts \
    noto-fonts-emoji \
    ttf-jetbrains-mono \
    ttf-font-awesome

# Enable multilib repository for 32-bit support (needed for Steam and gaming)
echo ""
echo -e "${YELLOW}→${NC} Enabling multilib repository for gaming support..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo -e "${BLUE}Adding multilib repository...${NC}"
    sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    sudo pacman -Sy --noconfirm
    echo -e "${GREEN}✓${NC} Multilib repository enabled"
else
    echo -e "${GREEN}✓${NC} Multilib repository already enabled"
fi

# Gaming essentials (lightweight)
echo ""
echo -e "${YELLOW}→${NC} Installing gaming support..."
sudo pacman -S --needed --noconfirm \
    steam \
    prismlauncher \
    jre-openjdk \
    wine \
    wine-mono \
    wine-gecko \
    lib32-mesa \
    vulkan-icd-loader \
    lib32-vulkan-icd-loader \
    mesa-utils \
    gamemode \
    lib32-gamemode

# Performance optimizations for low RAM
echo ""
echo -e "${YELLOW}→${NC} Enabling zram swap for better performance..."
sudo pacman -S --needed --noconfirm zram-generator
sudo mkdir -p /etc/systemd
sudo tee /etc/systemd/zram-generator.conf >/dev/null <<'EOF_ZRAM'
[zram0]
zram-size = min(ram, 4096)
compression-algorithm = zstd
EOF_ZRAM
sudo systemctl daemon-reload
sudo systemctl enable --now systemd-zram-setup@zram0.service

# Configure XFCE for low memory usage
echo ""
echo -e "${YELLOW}→${NC} Configuring XFCE for optimal performance..."

# Disable compositor for better performance
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml << 'EOF_XFWM4'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="use_compositing" type="bool" value="false"/>
    <property name="theme" type="string" value="Default"/>
    <property name="title_font" type="string" value="Sans Bold 9"/>
    <property name="button_layout" type="string" value="O|SHMC"/>
    <property name="click_to_focus" type="bool" value="true"/>
    <property name="focus_delay" type="int" value="250"/>
    <property name="raise_delay" type="int" value="250"/>
    <property name="raise_on_focus" type="bool" value="false"/>
    <property name="raise_on_click" type="bool" value="true"/>
  </property>
</channel>
EOF_XFWM4

# Optimize Firefox for low RAM systems
echo ""
echo -e "${YELLOW}→${NC} Configuring Firefox for low RAM optimization..."
mkdir -p ~/.mozilla/firefox
cat > ~/.mozilla/firefox/profiles.ini << 'EOF_PROFILE'
[Install4F96D1932A9F858E]
Default=pbos.default
Locked=1

[Profile0]
Name=default
IsRelative=1
Path=pbos.default
Default=1

[General]
StartWithLastProfile=1
Version=2
EOF_PROFILE

mkdir -p ~/.mozilla/firefox/pbos.default
cat > ~/.mozilla/firefox/pbos.default/user.js << 'EOF_USERJS'
// PBOS Firefox Optimizations for 4GB RAM Systems
// Hardware Acceleration
user_pref("layers.acceleration.force-enabled", true);
user_pref("gfx.webrender.all", true);
user_pref("media.ffmpeg.vaapi.enabled", true);

// Memory Management - Reduce content processes
user_pref("dom.ipc.processCount", 2);
user_pref("dom.ipc.processCount.webIsolated", 1);

// Reduce RAM usage
user_pref("browser.sessionstore.interval", 60000);
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.memory.enable", true);
user_pref("browser.cache.memory.capacity", 51200);

// Disable prefetching to save RAM
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.predictor.enabled", false);

// Reduce animations for better performance
user_pref("ui.prefersReducedMotion", 1);

// Faster page loading
user_pref("nglayout.initialpaint.delay", 0);
user_pref("nglayout.initialpaint.delay_in_oopif", 0);

// Keep less history to save RAM
user_pref("places.history.expiration.max_pages", 20000);

// Disable telemetry to save resources
user_pref("toolkit.telemetry.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);

// Performance tweaks
user_pref("content.notify.interval", 100000);
user_pref("content.notify.ontimer", true);
user_pref("content.switch.threshold", 250000);
EOF_USERJS

echo -e "${GREEN}✓${NC} Firefox optimized for low RAM (2 content processes, hardware acceleration enabled)"

# Enable LightDM
echo ""
echo -e "${YELLOW}→${NC} Enabling display manager..."
sudo systemctl enable lightdm

# Enable NetworkManager
echo ""
echo -e "${YELLOW}→${NC} Enabling NetworkManager..."
sudo systemctl enable NetworkManager

# Install and enable Tailscale
echo ""
echo -e "${YELLOW}→${NC} Installing Tailscale VPN..."
sudo pacman -S --needed --noconfirm tailscale
sudo systemctl enable --now tailscaled
echo -e "${GREEN}✓${NC} Tailscale installed and enabled"
echo -e "${BLUE}Info:${NC} Run 'sudo tailscale up' after reboot to connect"

# Create .xinitrc for manual startx (backup option)
echo ""
echo -e "${YELLOW}→${NC} Creating .xinitrc..."
cat > ~/.xinitrc << 'EOF_XINITRC'
#!/bin/sh
# Start XFCE
exec startxfce4
EOF_XINITRC
chmod +x ~/.xinitrc

# Create performance tuning script
echo ""
echo -e "${YELLOW}→${NC} Creating performance optimization script..."
sudo tee /usr/local/bin/pbos-optimize << 'EOF_OPTIMIZE' >/dev/null
#!/bin/bash
# PBOS Performance Optimizer for Low-Spec Systems

echo "Applying performance optimizations..."

# Reduce swappiness for better RAM usage
echo 10 | sudo tee /proc/sys/vm/swappiness

# Clear cache
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

echo "Optimizations applied!"
EOF_OPTIMIZE
sudo chmod +x /usr/local/bin/pbos-optimize

# Create gaming mode script
echo ""
echo -e "${YELLOW}→${NC} Creating gaming optimization script..."
sudo tee /usr/local/bin/gaming-mode << 'EOF_GAMING' >/dev/null
#!/bin/bash
# Enhanced gaming mode for PBOS

echo "Activating gaming mode..."

# Stop unnecessary services
sudo systemctl stop bluetooth 2>/dev/null || true

# Apply CPU governor
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null || true

# Reduce swappiness
echo 10 | sudo tee /proc/sys/vm/swappiness

# Clear cache
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

echo "Gaming mode activated! Run 'gaming-mode-off' when done."
EOF_GAMING
sudo chmod +x /usr/local/bin/gaming-mode

sudo tee /usr/local/bin/gaming-mode-off << 'EOF_GAMING_OFF' >/dev/null
#!/bin/bash
# Disable gaming mode

echo "Deactivating gaming mode..."

# Restart services
sudo systemctl start bluetooth 2>/dev/null || true

# Reset CPU governor
echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null || true

# Reset swappiness
echo 60 | sudo tee /proc/sys/vm/swappiness

echo "Gaming mode deactivated!"
EOF_GAMING_OFF
sudo chmod +x /usr/local/bin/gaming-mode-off

cd "$SCRIPT_DIR"

clear
echo -e "${MAGENTA}"
cat << 'EOF_DONE'
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║            ✨ XFCE Setup Complete! ✨                 ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
EOF_DONE
echo -e "${NC}"

echo ""
echo -e "${GREEN}✓${NC} XFCE installation complete!"
echo ""

# Mark setup as complete
touch ~/.setup-complete

echo -e "${YELLOW}Installed features:${NC}"
echo -e "  ${GREEN}✓${NC} XFCE Desktop Environment"
echo -e "  ${GREEN}✓${NC} Firefox (optimized for low RAM - 2 processes max)"
echo -e "  ${GREEN}✓${NC} Gaming Support (Steam, PrismLauncher, Wine, GameMode)"
echo -e "  ${GREEN}✓${NC} Java Runtime (for Minecraft)"
echo -e "  ${GREEN}✓${NC} Tailscale VPN (secure networking)"
echo -e "  ${GREEN}✓${NC} Zram Swap (optimized for 4GB RAM)"
echo -e "  ${GREEN}✓${NC} Performance Tools"
echo ""

echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  ${GREEN}pbos-optimize${NC}      - Apply performance optimizations"
echo -e "  ${GREEN}gaming-mode${NC}        - Enable gaming mode (better FPS)"
echo -e "  ${GREEN}gaming-mode-off${NC}    - Disable gaming mode"
echo -e "  ${GREEN}sudo tailscale up${NC}  - Connect to Tailscale VPN"
echo -e "  ${GREEN}htop${NC} / ${GREEN}btop${NC}         - System monitor"
echo ""

echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Type ${GREEN}reboot${NC} to restart"
echo -e "  2. Log in and enjoy your lightweight desktop"
echo -e "  3. Run ${GREEN}gaming-mode${NC} before gaming for best performance"
echo ""
echo -e "${BLUE}Note:${NC} If you need to re-run this script, just execute:"
echo -e "  ${GREEN}cd ~/custom-setup && bash post-install.sh${NC}"
echo ""
