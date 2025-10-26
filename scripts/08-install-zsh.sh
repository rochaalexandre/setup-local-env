#!/bin/bash

echo "Installing Zsh and Autojump..."
apt install -y zsh autojump
chsh -s $(which zsh) $(id -u -n 1000)
