#!/bin/bash

echo "Installing fonts..."
username=$(id -u -n 1000)
mkdir -p /home/$username/.fonts

cd /tmp
for font in "FiraCode" "Meslo" "JetBrainsMono"; do
    wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/${font}.zip"
    unzip "${font}.zip" -d "/home/$username/.fonts"
    rm "${font}.zip"
done

chown -R $username:$username /home/$username/.fonts
fc-cache -vf
