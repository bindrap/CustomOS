#!/bin/bash
# PBOS Animated ASCII Art
# Cool animations for login screen

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Hide cursor
tput civis

# DNA Helix Animation
dna_helix() {
    local frames=15
    local frame=0

    while [ $frame -lt $frames ]; do
        clear
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║                                                            ║${NC}"
        echo -e "${CYAN}║     ${MAGENTA}Welcome to Banknote Bindrap OS - Loading...${CYAN}      ║${NC}"
        echo -e "${CYAN}║                                                            ║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""

        # DNA strands
        local offset=$((frame % 8))

        for i in {0..12}; do
            local pos=$(( (i + offset) % 8 ))
            case $pos in
                0|4) echo -e "            ${GREEN}●${NC}═══════════════════════${GREEN}●${NC}" ;;
                1|5) echo -e "           ${GREEN}●${NC} ╲               ╱ ${GREEN}●${NC}" ;;
                2|6) echo -e "          ${GREEN}●${NC}   ╲           ╱   ${GREEN}●${NC}" ;;
                3|7) echo -e "         ${GREEN}●${NC}     ╲       ╱     ${GREEN}●${NC}" ;;
            esac
        done

        echo ""
        echo -e "       ${CYAN}Initializing Banknote Bindrap OS...${NC}"

        sleep 0.08
        ((frame++))
    done
}

# Binary Matrix Rain
binary_rain() {
    local duration=2
    local columns=60
    local rows=15

    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                            ║${NC}"
    echo -e "${CYAN}║          ${MAGENTA}Welcome to PBOS - Loading System...${CYAN}            ║${NC}"
    echo -e "${CYAN}║                                                            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    local frames=$((duration * 10))
    for ((f=0; f<$frames; f++)); do
        # Move cursor to start of matrix area
        tput cup 7 0

        for ((r=0; r<$rows; r++)); do
            echo -n "    "
            for ((c=0; c<$columns; c++)); do
                if [ $((RANDOM % 3)) -eq 0 ]; then
                    if [ $((RANDOM % 10)) -eq 0 ]; then
                        echo -ne "${WHITE}$((RANDOM % 2))${NC}"
                    else
                        echo -ne "${GREEN}$((RANDOM % 2))${NC}"
                    fi
                else
                    echo -n " "
                fi
            done
            echo ""
        done

        echo ""
        echo -e "       ${CYAN}Initializing Banknote Bindrap OS...${NC}"

        sleep 0.1
    done
}

# Star Field Animation
star_field() {
    local frames=20

    for ((f=0; f<$frames; f++)); do
        clear
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║                                                            ║${NC}"
        echo -e "${CYAN}║     ${MAGENTA}Welcome to Banknote Bindrap OS - Loading...${CYAN}      ║${NC}"
        echo -e "${CYAN}║                                                            ║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""

        # Draw random stars
        for i in {1..15}; do
            local x=$((RANDOM % 60))
            local y=$((RANDOM % 12))

            # Position cursor and draw star
            tput cup $((y + 7)) $x

            if [ $((RANDOM % 5)) -eq 0 ]; then
                echo -ne "${YELLOW}★${NC}"
            elif [ $((RANDOM % 3)) -eq 0 ]; then
                echo -ne "${WHITE}*${NC}"
            else
                echo -ne "${CYAN}·${NC}"
            fi
        done

        # Draw moving comet
        local comet_x=$((f * 3))
        local comet_y=$((5 + (f % 6)))
        if [ $comet_x -lt 60 ]; then
            tput cup $((comet_y + 7)) $comet_x
            echo -ne "${YELLOW}☄${NC}"
        fi

        tput cup 20 0
        echo -e "       ${CYAN}Initializing Banknote Bindrap OS...${NC}"

        sleep 0.1
    done
}

# Spinning Arch Logo
spinning_arch() {
    local frames=16

    for ((f=0; f<$frames; f++)); do
        clear
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║                                                            ║${NC}"
        echo -e "${CYAN}║     ${MAGENTA}Welcome to Banknote Bindrap OS - Loading...${CYAN}      ║${NC}"
        echo -e "${CYAN}║                                                            ║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""

        local phase=$((f % 4))
        case $phase in
            0)
                echo -e "                      ${CYAN}      /\\${NC}"
                echo -e "                      ${CYAN}     /  \\${NC}"
                echo -e "                      ${CYAN}    /    \\${NC}"
                echo -e "                      ${CYAN}   /  __  \\${NC}"
                echo -e "                      ${CYAN}  /  (  )  \\${NC}"
                echo -e "                      ${CYAN} / .'    '. \\${NC}"
                echo -e "                      ${CYAN}/.'        '.\\${NC}"
                ;;
            1)
                echo -e "                      ${MAGENTA}     ┌─┐${NC}"
                echo -e "                      ${MAGENTA}    /   \\${NC}"
                echo -e "                      ${MAGENTA}   │ /\\ │${NC}"
                echo -e "                      ${MAGENTA}   │/  \\│${NC}"
                echo -e "                      ${MAGENTA}    \\  /${NC}"
                echo -e "                      ${MAGENTA}     \\//${NC}"
                echo -e "                      ${MAGENTA}     └┘${NC}"
                ;;
            2)
                echo -e "                      ${YELLOW}      __${NC}"
                echo -e "                      ${YELLOW}     /  \\${NC}"
                echo -e "                      ${YELLOW}    │ /\\ │${NC}"
                echo -e "                      ${YELLOW}    │/  \\│${NC}"
                echo -e "                      ${YELLOW}    │    │${NC}"
                echo -e "                      ${YELLOW}     \\__/${NC}"
                echo -e "                      ${YELLOW}${NC}"
                ;;
            3)
                echo -e "                      ${BLUE}      /\\${NC}"
                echo -e "                      ${BLUE}     │  │${NC}"
                echo -e "                      ${BLUE}     │  │${NC}"
                echo -e "                      ${BLUE}    /│  │\\${NC}"
                echo -e "                      ${BLUE}   / │  │ \\${NC}"
                echo -e "                      ${BLUE}  /  │  │  \\${NC}"
                echo -e "                      ${BLUE} └───┘  └───┘${NC}"
                ;;
        esac

        echo ""
        echo ""
        echo -e "       ${CYAN}Initializing Banknote Bindrap OS...${NC}"

        sleep 0.12
    done
}

# Wave Animation
wave_animation() {
    local frames=20

    for ((f=0; f<$frames; f++)); do
        clear
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║                                                            ║${NC}"
        echo -e "${CYAN}║     ${MAGENTA}Welcome to Banknote Bindrap OS - Loading...${CYAN}      ║${NC}"
        echo -e "${CYAN}║                                                            ║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""

        for row in {0..10}; do
            echo -n "    "
            for col in {0..50}; do
                local wave=$(echo "scale=2; s(($col + $f) * 0.3 + $row * 0.5)" | bc -l 2>/dev/null || echo "0")
                if (( $(echo "$wave > 0.5" | bc -l 2>/dev/null || echo "0") )); then
                    echo -ne "${CYAN}~${NC}"
                elif (( $(echo "$wave > 0" | bc -l 2>/dev/null || echo "0") )); then
                    echo -ne "${BLUE}~${NC}"
                else
                    echo -n " "
                fi
            done
            echo ""
        done

        echo ""
        echo -e "       ${CYAN}Initializing Banknote Bindrap OS...${NC}"

        sleep 0.08
    done
}

# Main - randomly pick an animation
animations=(dna_helix binary_rain star_field spinning_arch)
random_animation=${animations[$RANDOM % ${#animations[@]}]}

# Run the animation
$random_animation

# Show cursor again
tput cnorm

clear
