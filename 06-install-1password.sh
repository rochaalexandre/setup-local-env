#!/bin/bash

echo "Installing 1Password..."
cd /tmp
wget https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb
dpkg -i 1password-latest.deb
rm 1password-latest.deb
