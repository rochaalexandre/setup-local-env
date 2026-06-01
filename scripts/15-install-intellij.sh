#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

INSTALL_DIR="$USER_HOME/.local/intellij"
DESKTOP_FILE="$USER_HOME/.local/share/applications/intellij-idea.desktop"

log_info "Installing IntelliJ IDEA for $USERNAME..."
mkdir -p "$INSTALL_DIR"

## to use download the toolbox, just change IU (Intellij Ultimate) for TB
curl -L "https://download.jetbrains.com/product?code=IU&latest&distribution=linux" \
    | tar xz -C "$INSTALL_DIR" --strip 1 \
    || { log_error "IntelliJ IDEA download/extraction failed!"; exit 1; }

chown -R "$USERNAME:$USERNAME" "$INSTALL_DIR"

mkdir -p "$(dirname "$DESKTOP_FILE")"
cat > "$DESKTOP_FILE" << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Ultimate
Exec=$INSTALL_DIR/bin/idea.sh
Icon=$INSTALL_DIR/bin/idea.png
Terminal=false
Categories=Development;IDE;
EOL

chmod +x "$DESKTOP_FILE"
chown "$USERNAME:$USERNAME" "$DESKTOP_FILE"
log_success "IntelliJ IDEA installed"
