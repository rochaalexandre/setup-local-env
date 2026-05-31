#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Zap plugin manager for $USERNAME..."

TEMP_DIR="/tmp/zap-install"
rm -rf "$TEMP_DIR"
git clone https://github.com/zap-zsh/zap.git "$TEMP_DIR" \
    || { log_error "Failed to clone Zap!"; exit 1; }

run_as_user zsh "$TEMP_DIR/install.zsh" --branch release-v1 \
    || { log_error "Zap installation failed!"; rm -rf "$TEMP_DIR"; exit 1; }

rm -rf "$TEMP_DIR"
log_success "Zap installed"
