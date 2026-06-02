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
        cat > /etc/yum.repos.d/ghostty.repo << 'REPO'
[ghostty]
name=Ghostty
baseurl=https://packages.ghostty.org/rpm/fedora/$releasever/$basearch
enabled=1
gpgcheck=0
REPO
        dnf install -y --skip-unavailable ghostty
        ;;
esac || { log_error "Ghostty installation failed!"; exit 1; }

update-alternatives --set x-terminal-emulator /usr/bin/ghostty 2>/dev/null || true
log_success "Ghostty installed"
