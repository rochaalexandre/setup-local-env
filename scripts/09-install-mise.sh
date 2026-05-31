#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Mise for $USERNAME..."
run_as_user bash -c 'curl https://mise.run | sh' \
    || { log_error "Mise installation failed!"; exit 1; }

log_success "Mise installed"
