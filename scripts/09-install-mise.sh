#!/bin/bash

username=$(logname)
echo "Installing Mise..."

curl https://mise.run/zsh | sudo -u "$username" sh
