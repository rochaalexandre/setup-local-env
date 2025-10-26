#!/bin/bash

# Get the current non-root user
username=$(logname)

echo "Installing Zed as $username...\n"

# Download the installation script as the regular user
sudo -u "$username" curl -fsSL https://zed.dev/install.sh -o zed.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to download Zed installation script!"
    exit 1
fi

# Ensure the user owns the script
chown "$username:$username" "zed.sh"
chmod +x "zed.sh"

# Run the script as the regular user
sudo -u "$username" bash "zed.sh"

if [ $? -ne 0 ]; then
    echo "❌ Zed installation failed!\n"
    exit 1
fi

rm "zed.sh"
echo "✅ Zed installation completed!\n"
