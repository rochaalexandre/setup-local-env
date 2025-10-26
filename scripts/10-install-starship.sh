#!/bin/bash

echo "Installing Starship...\n"
curl -sS https://starship.rs/install.sh | sh -s -- -y

if [ $? -ne 0 ]; then
    echo "❌ Starship installation failed!\n"
    exit 1
fi

echo "✅ Starship installation completed!\n"
