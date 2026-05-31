#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Zed for $USERNAME..."
run_as_user bash -c 'curl -fsSL https://zed.dev/install.sh | bash' \
    || { log_error "Zed installation failed!"; exit 1; }

log_success "Zed installed"
