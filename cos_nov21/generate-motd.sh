#!/bin/bash
# Dynamic MOTD Generator for PBOS - Simple and clean version

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

# Display clean header
echo ""
echo -e "\033[1;35m         ██████╗ ██████╗  ██████╗ ███████╗"
echo -e "        ██╔══██╗██╔══██╗██╔═══██╗██╔════╝"
echo -e "        ██████╔╝██████╔╝██║   ██║███████╗"
echo -e "        ██╔═══╝ ██╔══██╗██║   ██║╚════██║"
echo -e "        ██║     ██████╔╝╚██████╔╝███████║"
echo -e "        ╚═╝     ╚═════╝  ╚═════╝ ╚══════╝\033[0m"
echo -e "\033[1;36m    Parteek Bindra Operating System • Hyprland Edition\033[0m"
echo ""

# Display random quote
echo -e "\033[1;33m💭 $QUOTE\033[0m"
echo -e "\033[0;36m   — $AUTHOR\033[0m"
echo ""

# Simple quick start
echo -e "\033[1;32m⚡ Quick Start:\033[0m"
echo -e "  \033[1;33msetup-wifi\033[0m      - Connect to WiFi"
echo -e "  \033[1;33mpartition-disk\033[0m  - Prepare disk for dual boot"
echo -e "  \033[1;33minstall-arch\033[0m    - Install PBOS"
echo ""
echo -e "\033[0;36m📂 Guides & docs: ~/custom-setup/\033[0m"
echo ""
