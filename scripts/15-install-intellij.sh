#!/bin/bash

# Define installation path
INSTALL_DIR="/home/$username/.local/intellij"
DESKTOP_FILE="/home/$username/.local/share/applications/intellij-idea.desktop"

# Create installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download and extract IntelliJ IDEA to the specified path
echo "Downloading IntelliJ IDEA..."
curl -L "https://download.jetbrains.com/product?code=IU&latest&distribution=linux" | tar xvz -C "$INSTALL_DIR" --strip 1
"$INSTALL_DIR/bin/idea.sh" > /dev/null 2>&1 &

echo "Installation complete. Run IntelliJ IDEA with: $INSTALL_DIR/bin/idea.sh"

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

echo "Desktop shortcut created at $DESKTOP_FILE"
