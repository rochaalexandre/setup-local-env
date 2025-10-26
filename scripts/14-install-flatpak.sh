#!/bin/bash
echo "Installing Flatpak...\n"
apt install -y flatpak
apt install -y gnome-software-plugin-flatpak

if [ $? -ne 0 ]; then
    echo "❌ Flatpak installation failed!\n"
    exit 1
fi

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo "✅ Flatpak installation completed!\n"
