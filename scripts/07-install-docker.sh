#!/bin/bash

echo "Installing Docker...\n"
cd /tmp
curl -fsSL https://get.docker.com -o install-docker.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to download Docker installation script!"
    exit 1
fi

chown $username:$username install-docker.sh
sh install-docker.sh

if [ $? -ne 0 ]; then
    echo "❌ Docker installation failed!\n"
    exit 1
fi

echo "Setting up Docker rootless mode...\n"
su -c 'dockerd-rootless-setuptool.sh install' $(id -u -n 1000)

rm install-docker.sh
echo "✅ Docker installation completed!\n"
