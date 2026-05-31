#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

require_root

success_count=0
fail_count=0
total_count=0

log_section "Starting installation process"
log_info "Installing for user: $USERNAME (home: $USER_HOME)"

for script in "$SCRIPT_DIR"/scripts/*.sh; do
    script_name=$(basename "$script")
    log_section "$script_name"

    if bash "$script"; then
        success_count=$((success_count + 1))
        log_success "$script_name completed"
    else
        fail_count=$((fail_count + 1))
        log_error "$script_name failed"
    fi
    total_count=$((total_count + 1))
done

printf "\n📊 Results: %d/%d succeeded\n" "$success_count" "$total_count"

[ $fail_count -eq 0 ] && log_success "All done!" && exit 0
log_error "Some scripts failed. Check logs above."
exit 1
