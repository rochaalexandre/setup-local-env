#!/bin/bash

# Check if script is run as root
is_not_user_root () { [ "${EUID:-$(id -u)}" -ne 0 ]; }

if is_not_user_root; then
    echo "You must be a root user to run this script. Please use: sudo ./install.sh" 2>&1
    exit 1
fi

# Run each script in the scripts directory
for script in ./scripts/*.sh; do
    bash "$script"
done

echo "Installation completed!"
