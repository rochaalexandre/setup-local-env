#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Claude Code for $USERNAME..."
# https://code.claude.com/docs/en/setup
sudo -H -u "$USERNAME" bash -eo pipefail -c '
    curl -fsSL https://claude.ai/install.sh | bash
    export PATH="$1/.local/bin:$PATH"
    claude --version
' bash "$USER_HOME" \
    || { log_error "Claude Code installation failed!"; exit 1; }

log_success "Claude Code installed — run claude as your regular user to sign in"
