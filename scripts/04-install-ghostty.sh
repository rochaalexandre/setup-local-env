#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Ghostty..."

# Add Ghostty PPA and install
apt install -y software-properties-common
add-apt-repository -y ppa:ghostty-terminal/ghostty
apt update
apt install -y ghostty || { log_error "Ghostty installation failed!"; exit 1; }

# Set as default terminal emulator
update-alternatives --set x-terminal-emulator /usr/bin/ghostty 2>/dev/null || true

log_success "Ghostty installed"
