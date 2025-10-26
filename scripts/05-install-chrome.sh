#!/bin/bash

echo "Installing Google Chrome...\n"
cd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

if [ $? -ne 0 ]; then
    echo "❌ Failed to download Google Chrome!\n"
    exit 1
fi

apt install -y ./google-chrome-stable_current_amd64.deb

if [ $? -ne 0 ]; then
    echo "❌ Google Chrome installation failed!\n"
    exit 1
fi

rm google-chrome-stable_current_amd64.deb
echo "✅ Google Chrome installation completed!\n"
