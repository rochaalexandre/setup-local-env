#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Cleaning up..."
apt autoremove -y && apt autoclean || { log_error "Cleanup failed!"; exit 1; }
log_success "Done! 🏁"
