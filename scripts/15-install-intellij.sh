#!/bin/bash

echo "Installing IntelliJ IDEA...\n"

# Get the current non-root user
username=$(logname)

# Define installation path
INSTALL_DIR="/home/$username/.local/intellij"
DESKTOP_FILE="/home/$username/.local/share/applications/intellij-idea.desktop"

# Create installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download and extract IntelliJ IDEA to the specified path
echo "Downloading IntelliJ IDEA..."
curl -L "https://download.jetbrains.com/product?code=IU&latest&distribution=linux" | tar xz -C "$INSTALL_DIR" --strip 1

if [ $? -ne 0 ]; then
    echo "❌ IntelliJ IDEA download/extraction failed!\n"
    exit 1
fi

# Set proper ownership
chown -R "$username:$username" "$INSTALL_DIR"

# Create desktop entry
mkdir -p "$(dirname "$DESKTOP_FILE")"

cat > "$DESKTOP_FILE" <<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Ultimate
Exec=$INSTALL_DIR/bin/idea.sh
Icon=$INSTALL_DIR/bin/idea.png
Terminal=false
Categories=Development;IDE;
EOL

# Ensure the desktop file is executable
chmod +x "$DESKTOP_FILE"
chown "$username:$username" "$DESKTOP_FILE"

echo "✅ IntelliJ IDEA installation completed!\n"
