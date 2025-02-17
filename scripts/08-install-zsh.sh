#!/bin/bash

echo "Installing Zsh and Autojump..."
nala install -y zsh autojump
chsh -s $(which zsh) $(id -u -n 1000)
