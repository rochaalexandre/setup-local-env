#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing 1Password..."
wget -q https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb -O /tmp/1password.deb \
    || { log_error "Failed to download 1Password!"; exit 1; }

apt install -y /tmp/1password.deb || { log_error "1Password installation failed!"; exit 1; }
rm /tmp/1password.deb
log_success "1Password installed"
