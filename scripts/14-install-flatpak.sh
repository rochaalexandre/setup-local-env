#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

if command -v flatpak >/dev/null 2>&1; then
    log_skip "Flatpak already installed"
else
    log_info "Installing Flatpak..."
    pkg_install flatpak $PKG_FLATPAK_PLUGIN \
        || { log_error "Flatpak installation failed!"; exit 1; }
fi

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
log_success "Flatpak configured"
