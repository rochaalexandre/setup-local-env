#!/bin/bash

echo "Installing Zap Plugin Manager for Zsh..."
su -c 'zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1' $(id -u -n 1000)
