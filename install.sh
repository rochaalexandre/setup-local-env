#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

require_root

# Installation order. Dependencies flow top to bottom:
#   install-essential provides curl/gpg/wget/unzip for every download below
#   install-flatpak must precede install-spotify
#   finalize (cleanup) runs last
SCRIPTS=(
    update-system
    install-essential
    install-fonts
    install-ghostty
    install-chrome
    install-1password
    install-docker
    install-zsh
    install-mise
    install-starship
    install-zed
    install-flatpak
    install-spotify
    install-jetbrains-toolbox
    configure-nvidia-wayland
    finalize
)

success_count=0
fail_count=0
total_count=0

log_section "Starting installation process"
log_info "Installing for user: $USERNAME (home: $USER_HOME)"

for name in "${SCRIPTS[@]}"; do
    script="$SCRIPT_DIR/scripts/$name.sh"
    log_section "$name"

    if [ ! -f "$script" ]; then
        log_error "$name: script not found at $script"
        fail_count=$((fail_count + 1))
        total_count=$((total_count + 1))
        continue
    fi

    if bash "$script"; then
        success_count=$((success_count + 1))
        log_success "$name completed"
    else
        fail_count=$((fail_count + 1))
        log_error "$name failed"
    fi
    total_count=$((total_count + 1))
done

printf "\n📊 Results: %d/%d succeeded\n" "$success_count" "$total_count"

[ $fail_count -eq 0 ] && log_success "All done!" && exit 0
log_error "Some scripts failed. Check logs above."
exit 1
