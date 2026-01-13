#!/bin/bash

# Simple Installation Script for PBOS Server Edition
# Runs the automated base installer and points users to the server setup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if install-auto.sh exists
if [ -f "$SCRIPT_DIR/install-auto.sh" ]; then
    echo "Running automated installer for base system..."
    exec bash "$SCRIPT_DIR/install-auto.sh"
else
    echo "Error: install-auto.sh not found!"
    echo "Please run the installation manually using archinstall"
    echo "After the base install, run post-install.sh to set up the server environment."
    exit 1
fi
