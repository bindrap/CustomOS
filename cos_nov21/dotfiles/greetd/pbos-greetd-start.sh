#!/bin/bash
# PBOS greetd wrapper: show animated intro, brand greeting + quote, then start tuigreet
set -euo pipefail

# Run animated intro (non-blocking after completion)
if [ -x /usr/local/bin/animated-intro ]; then
    /usr/local/bin/animated-intro || true
fi

# Pick a quote
QUOTE="You have power over your mind - not outside events. Realize this, and you will find strength."
AUTHOR="Marcus Aurelius"
if [ -f /usr/share/pbos/stoic-quotes.txt ]; then
    LINE=$(shuf -n 1 /usr/share/pbos/stoic-quotes.txt)
    QUOTE=$(echo "$LINE" | cut -d'|' -f1)
    AUTHOR=$(echo "$LINE" | cut -d'|' -f2)
fi

# PBOS mark (ANSI stripped by tuigreet; keep plain ASCII and centered-ish)
read -r -d '' GREETING_FMT <<'EOF' || true
   ██████╗ ██████╗  ██████╗ ███████╗
   ██╔══██╗██╔══██╗██╔═══██╗██╔════╝
   ██████╔╝██████╔╝██║   ██║███████╗
   ██╔═══╝ ██╔══██╗██║   ██║╚════██║
   ██║     ██████╔╝╚██████╔╝███████║
   ╚═╝     ╚═════╝  ╚═════╝ ╚══════╝
    Parteek Bindra Operating System
        Terminus Ut Exordium.
     "%s"    — %s
EOF

FILLED=$(printf "$GREETING_FMT" "$QUOTE" "$AUTHOR")
GREET="$FILLED"

exec tuigreet --time --remember --remember-session \
    --greeting "$GREET" \
    --cmd /usr/local/bin/launch-hyprland
