#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing 1Password..."

case "$DISTRO" in
    ubuntu|pop|linuxmint)
        curl -sS https://downloads.1password.com/linux/keys/1password.asc \
            | gpg --dearmor -o /etc/apt/trusted.gpg.d/1password.gpg
        echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/1password.gpg] \
https://downloads.1password.com/linux/debian/amd64 stable main" \
            | tee /etc/apt/sources.list.d/1password.list
        apt update
        pkg_install 1password
        ;;
    fedora)
        rpm --import https://downloads.1password.com/linux/keys/1password.asc
        cat > /etc/yum.repos.d/1password.repo << 'REPO'
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
REPO
        pkg_install 1password
        ;;
esac || { log_error "1Password installation failed!"; exit 1; }

log_success "1Password installed"
