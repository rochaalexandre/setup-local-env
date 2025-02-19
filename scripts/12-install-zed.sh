echo "Installing Zed..."
cd /tmp
curl -fsSL https://zed.dev/install.sh  -o zed.sh
chown $username:$username zed.sh
sh zed.sh
