#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Google Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb \
    || { log_error "Failed to download Google Chrome!"; exit 1; }

apt install -y /tmp/chrome.deb || { log_error "Google Chrome installation failed!"; exit 1; }
rm /tmp/chrome.deb
log_success "Google Chrome installed"
