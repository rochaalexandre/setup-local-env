#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Google Chrome..."

case "$DISTRO" in
    ubuntu|pop|linuxmint)
        curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
            | gpg --dearmor -o /etc/apt/trusted.gpg.d/google-chrome.gpg
        echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/google-chrome.gpg] \
http://dl.google.com/linux/chrome/deb/ stable main" \
            | tee /etc/apt/sources.list.d/google-chrome.list
        apt update
        pkg_install google-chrome-stable
        ;;
    fedora)
        dnf config-manager --set-enabled google-chrome 2>/dev/null || \
        cat > /etc/yum.repos.d/google-chrome.repo << 'REPO'
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
REPO
        pkg_install google-chrome-stable
        ;;
esac || { log_error "Google Chrome installation failed!"; exit 1; }

log_success "Google Chrome installed"
