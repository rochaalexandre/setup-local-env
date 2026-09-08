#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Ghostty..."

case "$DISTRO" in
    ubuntu|pop|linuxmint)
        pkg_add_repo "ppa:ghostty-terminal/ghostty"
        pkg_install ghostty
        ;;
    fedora)
        # No official Ghostty RPM repo exists; scottames/ghostty COPR is the
        # community-maintained package (COPR handles its own GPG signing).
        rm -f /etc/yum.repos.d/ghostty.repo   # drop stale repo from older versions
        dnf copr enable -y scottames/ghostty
        dnf install -y ghostty
        ;;
esac || { log_error "Ghostty installation failed!"; exit 1; }

update-alternatives --set x-terminal-emulator /usr/bin/ghostty 2>/dev/null || true
log_success "Ghostty installed"
