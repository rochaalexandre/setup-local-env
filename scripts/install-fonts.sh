#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

FONT_DIR="$USER_HOME/.fonts"
mkdir -p "$FONT_DIR"

FONTS="FiraCode Meslo JetBrainsMono"
BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1"

for font in $FONTS; do
    dest_dir="$FONT_DIR/$font"
    if [ -d "$dest_dir" ]; then
        log_skip "Font $font already installed"
        continue
    fi
    log_info "Downloading $font..."
    wget -q "${BASE_URL}/${font}.zip" -O "/tmp/${font}.zip"
    unzip -oq "/tmp/${font}.zip" -d "$dest_dir"
    rm "/tmp/${font}.zip"
done

chown -R "$USERNAME:$USERNAME" "$FONT_DIR"
fc-cache
log_success "Fonts installed"
