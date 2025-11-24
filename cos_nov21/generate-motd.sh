#!/bin/bash
# Dynamic MOTD Generator for PBOS - System Info Edition
# Shows Arch logo, system stats, PBOS branding, and philosophy quotes

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m'

# Get system information
get_hostname() {
    hostname
}

get_os() {
    echo "Arch Linux (PBOS)"
}

get_kernel() {
    uname -r
}

get_uptime() {
    uptime -p | sed 's/up //'
}

get_cpu() {
    grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//' | sed 's/(R)//' | sed 's/(TM)//' | sed 's/CPU//' | cut -c1-40
}

get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
}

get_ram() {
    free -h | awk '/^Mem:/ {print $3 "/" $2}'
}

get_ram_percent() {
    free | awk '/^Mem:/ {printf("%.1f"), $3/$2 * 100}'
}

get_temp() {
    # Try different temperature sources
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        echo "$((temp / 1000))°C"
    elif command -v sensors &> /dev/null; then
        sensors | grep "Package id 0:" | awk '{print $4}' | sed 's/+//'
    else
        echo "N/A"
    fi
}

get_shell() {
    basename "$SHELL"
}

get_packages() {
    if command -v pacman &> /dev/null; then
        pacman -Q | wc -l
    else
        echo "N/A"
    fi
}

# Collect info
HOSTNAME=$(get_hostname)
OS=$(get_os)
KERNEL=$(get_kernel)
UPTIME=$(get_uptime)
CPU=$(get_cpu)
CPU_USAGE=$(get_cpu_usage)
RAM=$(get_ram)
RAM_PERCENT=$(get_ram_percent)
TEMP=$(get_temp)
SHELL=$(get_shell)
PACKAGES=$(get_packages)

# Pick random quote
QUOTES_FILE="/root/custom-setup/stoic-quotes.txt"
if [ -f "$QUOTES_FILE" ]; then
    QUOTE_LINE=$(shuf -n 1 "$QUOTES_FILE")
    QUOTE=$(echo "$QUOTE_LINE" | cut -d'|' -f1)
    AUTHOR=$(echo "$QUOTE_LINE" | cut -d'|' -f2)
else
    QUOTE="You have power over your mind - not outside events. Realize this, and you will find strength."
    AUTHOR="Marcus Aurelius"
fi

clear

# Display with Arch logo and system info side by side
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                                        ║${NC}"
echo -e "${CYAN}║${NC}  ${CYAN}                 ${MAGENTA}██████╗ ██████╗  ██████╗ ███████╗                 ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${CYAN}      /\\        ${MAGENTA}██╔══██╗██╔══██╗██╔═══██╗██╔════╝                 ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${CYAN}     /  \\       ${MAGENTA}██████╔╝██████╔╝██║   ██║███████╗                 ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${CYAN}    /\\   \\      ${MAGENTA}██╔═══╝ ██╔══██╗██║   ██║╚════██║                 ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${CYAN}   /  __  \\     ${MAGENTA}██║     ██████╔╝╚██████╔╝███████║                 ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${CYAN}  / .'  '. \\    ${MAGENTA}╚═╝     ╚═════╝  ╚═════╝ ╚══════╝                 ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${CYAN} /.'      '.\\   ${WHITE}Parteek Bindra Operating System                  ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${CYAN}            \\   ${GRAY}Hyprland Edition • Arch Linux Based               ${CYAN}║${NC}"
echo -e "${CYAN}║                                                                        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# System Information
echo -e "${MAGENTA}┌─────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${MAGENTA}│${NC}                         ${CYAN}⚡ SYSTEM INFORMATION ⚡${NC}                      ${MAGENTA}│${NC}"
echo -e "${MAGENTA}└─────────────────────────────────────────────────────────────────────┘${NC}"
echo ""

# Two column layout
echo -e "${GREEN} 󰌢 Hostname    ${NC} $HOSTNAME              ${GREEN} 󰍛 CPU Usage   ${NC} ${CPU_USAGE}%"
echo -e "${GREEN}  OS          ${NC} $OS              ${GREEN} 󰘚 Memory      ${NC} $RAM (${RAM_PERCENT}%)"
echo -e "${GREEN}  Kernel      ${NC} $KERNEL              ${GREEN} 🌡  Temperature ${NC} $TEMP"
echo -e "${GREEN}  Uptime      ${NC} $UPTIME              ${GREEN}  Shell       ${NC} $SHELL"
echo -e "${GREEN}  CPU         ${NC} $CPU"
echo -e "${GREEN} 󰏖 Packages    ${NC} $PACKAGES packages installed"
echo ""

# Philosophy Quote
echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}│${NC}                          ${CYAN}💭 DAILY WISDOM 💭${NC}                          ${YELLOW}│${NC}"
echo -e "${YELLOW}└─────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${WHITE}  \"$QUOTE\"${NC}"
echo -e "${CYAN}                                                    — $AUTHOR${NC}"
echo ""

# Quick Start (minimal for post-install)
if [ -f "/root/custom-setup/install-auto.sh" ] || [ -f "$HOME/custom-setup/install-auto.sh" ]; then
    # We're in ISO environment
    echo -e "${GREEN}┌─────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│${NC}                          ${YELLOW}⚡ QUICK START ⚡${NC}                           ${GREEN}│${NC}"
    echo -e "${GREEN}└─────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${CYAN}setup-wifi${NC}       - Connect to WiFi"
    echo -e "  ${CYAN}partition-disk${NC}   - Prepare disk for dual boot"
    echo -e "  ${CYAN}install-arch${NC}     - Install PBOS"
    echo ""
    echo -e "  ${GRAY}Guides & docs: ~/custom-setup/${NC}"
    echo ""
fi
