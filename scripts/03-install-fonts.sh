#!/bin/bash
echo "Installing fonts...\n"

# Get main non-root username (assuming UID 1000 is the first regular user)
username=$(id -nu 1000)
font_dir="/home/$username/.fonts"

mkdir -p "$font_dir"
cd /tmp

# Define the fonts and base URL
fonts="FiraCode Meslo JetBrainsMono"
base_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3"

for font in $fonts; do
    dest_dir="$font_dir/$font"

    if [ -d "$dest_dir" ]; then
        echo "⏩ Font $font already installed, skipping..."
        continue
    fi

    echo "⬇️  Downloading $font..."
    wget -q "${base_url}/${font}.zip" -O "${font}.zip"
    unzip -oq "${font}.zip" -d "$font_dir"
    rm "${font}.zip"
done
ls
# Fix permissions
chown -R "$username:$username" "$font_dir"

# Refresh font cache
fc-cache
cd -

echo "✅ Fonts installation completed!\n"
