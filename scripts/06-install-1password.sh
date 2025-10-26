#!/bin/bash

echo "Installing 1Password...\n"
cd /tmp
wget https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb

if [ $? -ne 0 ]; then
    echo "❌ Failed to download 1Password!\n"
    exit 1
fi

apt install -y ./1password-latest.deb

if [ $? -ne 0 ]; then
    echo "❌ 1Password installation failed!\n"
    exit 1
fi

rm 1password-latest.deb
echo "✅ 1Password installation completed!\n"
