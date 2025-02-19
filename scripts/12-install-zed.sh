#!/bin/bash

# Get the current non-root user
username=$(logname)

echo "Installing Zed as $username..."


# Download the installation script as the regular user
sudo -u "$username" curl -fsSL https://zed.dev/install.sh -o zed.sh

# Ensure the user owns the script
chown "$username:$username" "zed.sh"
chmod +x "zed.sh"

# Run the script as the regular user
sudo -u "$username" bash "zed.sh"

rm "zed.sh"

echo "Zed installation complete!"
