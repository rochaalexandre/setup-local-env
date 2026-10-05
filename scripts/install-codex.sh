#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Codex for $USERNAME..."
# https://learn.chatgpt.com/docs/codex/cli
sudo -H -u "$USERNAME" bash -eo pipefail -c '
    curl -fsSL https://chatgpt.com/codex/install.sh | sh
    export PATH="$1/.local/bin:$PATH"
    codex --version
' bash "$USER_HOME" \
    || { log_error "Codex installation failed!"; exit 1; }

log_success "Codex installed — run codex as your regular user to sign in"
