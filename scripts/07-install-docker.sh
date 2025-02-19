#!/bin/bash

echo "Installing Docker..."
cd /tmp
curl -fsSL https://get.docker.com -o install-docker.sh
chown $username:$username install-docker.sh
sh install-docker.sh


echo "Setting up Docker rootless mode..."
nala install -y uidmap
su -c 'dockerd-rootless-setuptool.sh install' $(id -u -n 1000)

rm install-docker.sh
