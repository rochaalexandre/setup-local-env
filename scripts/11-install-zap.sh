#!/bin/bash

echo "Installing Zap Plugin Manager for Zsh...\n"

# Get the current non-root user
username=$(logname)

# Create temporary directory for cloning
temp_dir="/tmp/zap-install"
rm -rf "$temp_dir"
mkdir -p "$temp_dir"

# Clone the Zap repository
echo "Cloning Zap repository..."
git clone https://github.com/zap-zsh/zap.git "$temp_dir"

if [ $? -ne 0 ]; then
    echo "❌ Failed to clone Zap repository!\n"
    exit 1
fi

# Run the installation script as the regular user
echo "Running Zap installation..."
sudo -u "$username" zsh "$temp_dir/install.zsh" --branch release-v1

if [ $? -ne 0 ]; then
    echo "❌ Zap installation failed!\n"
    rm -rf "$temp_dir"
    exit 1
fi

# Cleanup
rm -rf "$temp_dir"
echo "✅ Zap installation completed!\n"
