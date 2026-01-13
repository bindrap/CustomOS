#!/bin/bash
# Generate /etc/issue for login screen with PBOS branding and philosophy
# This displays BEFORE the login prompt

# Colors for terminal (using ANSI codes that work in /etc/issue)
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
GRAY='\033[0;37m'
NC='\033[0m'

# Pick random quote (try multiple locations)
QUOTES_FILE=""
for location in "/usr/share/pbos/stoic-quotes.txt" "/root/custom-setup/stoic-quotes.txt"; do
    if [ -f "$location" ]; then
        QUOTES_FILE="$location"
        break
    fi
done

if [ -n "$QUOTES_FILE" ]; then
    QUOTE_LINE=$(shuf -n 1 "$QUOTES_FILE")
    QUOTE=$(echo "$QUOTE_LINE" | cut -d'|' -f1)
    AUTHOR=$(echo "$QUOTE_LINE" | cut -d'|' -f2)
else
    QUOTE="You have power over your mind - not outside events. Realize this, and you will find strength."
    AUTHOR="Marcus Aurelius"
fi

# Generate issue file
cat > /etc/issue << EOF

${MAGENTA}╔══════════════════════════════════════════════════════════════════════════╗${NC}
${MAGENTA}║${NC}                                                                          ${MAGENTA}║${NC}
${MAGENTA}║${NC}   ${CYAN}██████╗   ██████╗   ██████╗   ██████╗${NC}                        ${MAGENTA}║${NC}
${MAGENTA}║${NC}   ${CYAN}██╔══██╗  ██╔══██╗ ██╔═══██╗ ██╔══██╗${NC}                        ${MAGENTA}║${NC}
${MAGENTA}║${NC}   ${CYAN}██████╔╝  ██████╔╝ ██║   ██║ ╚█████╔╝${NC}                        ${MAGENTA}║${NC}
${MAGENTA}║${NC}   ${CYAN}██╔═══╝   ██╔══██╗ ██║   ██║  ██╔══██╗${NC}                       ${MAGENTA}║${NC}
${MAGENTA}║${NC}   ${CYAN}██║       ██████╔╝ ╚██████╔╝  ██████╔╝${NC}                       ${MAGENTA}║${NC}
${MAGENTA}║${NC}   ${CYAN}╚═╝       ╚═════╝   ╚═════╝   ╚═════╝ ${NC}                       ${MAGENTA}║${NC}
${MAGENTA}║${NC}                                                                          ${MAGENTA}║${NC}
${MAGENTA}║${NC}        ${WHITE}Parteek Bindra Operating System${NC}                         ${MAGENTA}║${NC}
${MAGENTA}║${NC}          ${GRAY}Terminus Ut Exordium.${NC}                                   ${MAGENTA}║${NC}
${MAGENTA}║${NC}                                                                          ${MAGENTA}║${NC}
${MAGENTA}╚══════════════════════════════════════════════════════════════════════════╝${NC}

${YELLOW}╔══════════════════════════════════════════════════════════════════════════╗${NC}
${YELLOW}║${NC}                         ${CYAN}💭 DAILY WISDOM 💭${NC}                              ${YELLOW}║${NC}
${YELLOW}╚══════════════════════════════════════════════════════════════════════════╝${NC}

${WHITE}"$QUOTE"${NC}
${CYAN}                                                    — $AUTHOR${NC}

${GRAY}────────────────────────────────────────────────────────────────────────────${NC}

EOF

echo "✓ /etc/issue generated with PBOS branding and philosophy"
