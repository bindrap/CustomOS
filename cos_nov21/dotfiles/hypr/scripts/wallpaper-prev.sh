#!/bin/bash
# Cycle to previous wallpaper

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/wallpaper-lib.sh"

cycle_wallpaper "prev"
