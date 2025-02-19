#!/bin/bash

# Define installation path
INSTALL_DIR="/home/$username/.local/intellij"

# Create installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download and extract IntelliJ IDEA to the specified path
echo "Downloading IntelliJ IDEA..."
curl -L "https://download.jetbrains.com/product?code=IU&latest&distribution=linux" | tar xvz -C "$INSTALL_DIR" --strip 1

echo "Installation complete. Run IntelliJ IDEA with: $INSTALL_DIR/bin/idea.sh"
