#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Flatpak..."
apt install -y flatpak gnome-software-plugin-flatpak \
    || { log_error "Flatpak installation failed!"; exit 1; }

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
log_success "Flatpak installed"
