#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Spotify via Flatpak..."

# Ensure flatpak is available
if ! command -v flatpak &>/dev/null; then
    log_error "Flatpak not found. Run 14-install-flatpak.sh first."
    exit 1
fi

flatpak install -y flathub com.spotify.Client \
    || { log_error "Spotify installation failed!"; exit 1; }

log_success "Spotify installed"
