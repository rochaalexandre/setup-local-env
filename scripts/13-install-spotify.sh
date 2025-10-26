#!/bin/bash
# Stream music using https://spotify.com
echo "Installing Spotify..."
curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg

if [ $? -ne 0 ]; then
    echo "❌ Failed to add Spotify GPG key!\n"
    exit 1
fi

echo "deb [signed-by=/etc/apt/trusted.gpg.d/spotify.gpg] http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list
apt update -y
apt install -y spotify-client

if [ $? -ne 0 ]; then
    echo "❌ Spotify installation failed!\n"
    exit 1
fi

echo "✅ Spotify installation completed!\n"
