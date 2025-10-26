#!/bin/bash

username=$(logname)
echo "Installing Mise...\n"

curl https://mise.run/zsh | sudo -u "$username" sh

if [ $? -ne 0 ]; then
    echo "❌ Mise installation failed!\n"
    exit 1
fi

echo "✅ Mise installation completed!\n"
