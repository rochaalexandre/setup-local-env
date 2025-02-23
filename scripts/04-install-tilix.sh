#!/bin/bash

echo "Installing Tilix..."
nala install -y tilix

echo "Downloading Tilix Dracula theme..."
mkdir -p ~/.config/tilix/schemes
cd /tmp
wget https://github.com/dracula/tilix/archive/master.zip
unzip master.zip
mv tilix-master/Dracula.json ~/.config/tilix/schemes/
rm -r tilix-master master.zip

# Set Tilix as the default terminal emulator
echo "Setting Tilix as the default terminal..."
update-alternatives --set x-terminal-emulator /usr/bin/tilix
