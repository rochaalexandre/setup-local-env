#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Updating system packages..."
pkg_update || { log_error "System update failed!"; exit 1; }
log_success "System updated"
