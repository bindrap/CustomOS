#!/bin/bash
# Dynamic MOTD Generator for PBOS
# Displays epic ASCII art with random stoic philosophy quote

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

# Display epic ASCII art with colors
cat << "EOFMOTD"
[1;31m           ....   :+**+:   ....
       .-=.     -*#-     .=-.             [1;35m         ██████╗ ██████╗  ██████╗ ███████╗
     .-*=.      :*#:      .=*=.           [1;35m        ██╔══██╗██╔══██╗██╔═══██╗██╔════╝
   .:*#-.       :*#-       .-#*:.         [1;35m        ██████╔╝██████╔╝██║   ██║███████╗
 .:*##-.        :*#-        .-*#*:.       [1;35m        ██╔═══╝ ██╔══██╗██║   ██║╚════██║
 .-*##=.        :*#-        .=##*-.       [1;35m        ██║     ██████╔╝╚██████╔╝███████║
   .-*##+.      :*#-      .+##*-.         [1;35m        ╚═╝     ╚═════╝  ╚═════╝ ╚══════╝[0m
      -###+..   :*#-   ..+###=.
       .-*##+:. :*#- .:+##*=              [1;33m╔═══════════════════════════════════════════╗
         .-*##+::*#-:+##*-.               [1;33m║   Parteek Bindra Operating System         ║
           .-###*##*###-.                 [1;33m║   Hyprland Edition • Arch Linux Based     ║
             .-######=.                   [1;33m╚═══════════════════════════════════════════╝[0m
             .=######=.
           .=##########=.                 [1;36m         @@@@@@@@@@                  [1;32m                __..__
         .=####=-*#-=####=.               [1;36m     @@@@@@@@@@@@@@@@@@              [1;32m            _.sMSMMMMMMb.
       .-####+. :*#: .=####-.             [1;36m  @@@@@@@@@@@@@@@@@@@@@@@@           [1;32m         .-"TMMMMSMMMMMMMb.
     .-*##*=.   :*#:   .=*###-.           [1;36m@@@@@@@@       @@@@@@@@@@@           [1;32m       .'    TMMMMSMMMMMMMMb
   .-*###-..    :*#:    ..-*##*-.         [1;36m@@@@@               @@@@@@@@@        [1;32m      /       TMMMSMMMMMMSSS;
  -*###-.       :*#:       .:####-        [1;36m@@@@                    @@@@@@@      [1;32m     :        :MMMMSMMMSSMMMM;
 .-*##*:.       :*#:        .+##*-.       [1;36m@@@                      @@@@@@@     [1;32m     ;       @ MMMMSMMSMMMMMMS
   .-*##*:.     :*#:     .:+##*-.         [1;36m@@@@                         @@@@@   [1;32m    :    _,   ,P"TMSMSMMMMMMSM
    ..-###+:.   :*#:   ..+###=..          [1;36m@@@@                          @@@@   [1;32m    : .+""`,  :    `TMMMMMSSMM
        -###*.  :*#:  .*###=.             [1;36m@@@                            @@    [1;32m     ) c),     `-,-=,TSSSSMMMM
         .=###+.:*#:.+###=.               [1;36m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    [1;32m    /  `         ,-;|MMMMMMMM;
           .=###+##+###=.                 [1;36m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     [1;32m   /     _.'(o)  '-';SMSSSSSS
             .=######=.                   [1;36m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       [1;32m  (  ,   o       ,-"'`^MMMM'
               .+##+.                     [1;36m@@@@@                          @@     [1;32m   )`            :`.    .'
                 ::                       [1;36m@@@@                         @@@@     [1;32m   )-.           ;  `- /
[1;31m         BERSERK[0m                         [1;36m@@@                        @@@@@@     [1;32m   \         _.-'     :
                                          [1;36m@@                       @@@@@@      [1;32m   (     _.-"   `.     \
                                          [1;36m@@                     @@@@@@@        [1;32m    "---"--.      \     \
                                          [1;36m@@@@@@@@@@@@@@@@@@@@@@@@@@@          [1;32m        CYBERPUNK
                                          [1;36m@@@@@@@@@@@@@@@@@@@@@@@              [0m
                                          [1;36m    MONAS / ONKAR[0m

[1;35m╔════════════════════════════════════════════════════════════════════════════════╗[0m
EOFMOTD

# Display random quote
echo -e "[1;33m   💭 $QUOTE[0m"
echo -e "[1;36m                                                                  — $AUTHOR[0m"
echo -e "[1;35m╚════════════════════════════════════════════════════════════════════════════════╝[0m"
echo ""

# Display Quick Start Guide
cat << "EOFGUIDE"
[1;35m╔════════════════════════════════════════════════════════════════════════════════╗
[1;35m║                            ⚡ QUICK START GUIDE ⚡                               ║
[1;35m╚════════════════════════════════════════════════════════════════════════════════╝[0m

[1;36m    📡 CONNECT TO WiFi[0m
[1;32m    ╰─➤ setup-wifi[0m
        • Auto-detects ISO or installed environment
        • Supports both iwctl (ISO) and nmcli (installed)

[0;33m    ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄[0m

[1;35m    💾 PREPARE DISK (For Dual Boot)[0m
[1;32m    ╰─➤ partition-disk[0m
        • Safe partition creation in free space
        • View disk layout and create PBOS partition

[0;33m    ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄[0m

[1;33m    🚀 INSTALL PBOS[0m
[1;32m    ╰─➤ install-arch[0m
        • Full disk or dual boot installation
        • Auto-unmounts partitions
        • UEFI and BIOS support

[1;34m    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m

[1;32m    📋 WORKFLOW[0m  [1;36m Step 1:[0m[1;33m setup-wifi[0m  [1;36m Step 2:[0m[1;33m partition-disk[0m  [1;36m Step 3:[0m[1;33m install-arch[0m

[1;34m    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m

[1;35m    📂 FILES:[0m /root/custom-setup/  [1;31m🆘 HELP:[0m[1;33m lsblk  iwctl  less ~/custom-setup/*.md[0m

[0m
EOFGUIDE
