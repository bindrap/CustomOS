#!/bin/bash

# Simple Installation Script for CustomOS
# This is a placeholder - install-auto.sh is the main installer

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if install-auto.sh exists
if [ -f "$SCRIPT_DIR/install-auto.sh" ]; then
    echo "Running automated installer..."
    exec bash "$SCRIPT_DIR/install-auto.sh"
else
    echo "Error: install-auto.sh not found!"
    echo "Please run the installation manually using archinstall"
    exit 1
fi
