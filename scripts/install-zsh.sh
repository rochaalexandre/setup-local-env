#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Zsh..."
pkg_install zsh || { log_error "Zsh installation failed!"; exit 1; }

chsh -s "$(which zsh)" "$USERNAME"
log_success "Zsh installed and set as default shell for $USERNAME"
