#!/bin/bash

echo "Installing Zsh and Autojump...\n"
apt install -y zsh autojump

if [ $? -ne 0 ]; then
    echo "❌ Zsh installation failed!\n"
    exit 1
fi

chsh -s $(which zsh) $(id -u -n 1000)
echo "✅ Zsh installation completed!\n"
