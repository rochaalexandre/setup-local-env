#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y \
    || { log_error "Starship installation failed!"; exit 1; }

log_success "Starship installed"
