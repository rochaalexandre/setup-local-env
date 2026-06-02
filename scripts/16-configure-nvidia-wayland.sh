#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

if ! lspci | grep -qi nvidia; then
    log_skip "No Nvidia GPU detected, skipping..."
    exit 0
fi

printf "Nvidia GPU detected. Configure Wayland environment? [y/N] "
read -r answer
case "$answer" in
    [yY]) ;;
    *) log_skip "Skipping Nvidia Wayland configuration."; exit 0 ;;
esac

log_info "Installing drivers and configuring Wayland..."

case "$DISTRO" in
    ubuntu|pop|linuxmint)
        pkg_install nvidia-driver-open
        ;;
    fedora)
        dnf install -y \
            akmod-nvidia \
            xorg-x11-drv-nvidia-cuda \
            || { log_error "Nvidia drivers installation failed!"; exit 1; }
        ;;
esac

log_info "Configuring Wayland environment for $USERNAME..."

ZSHENV="$USER_HOME/.zshenv"

vars=(
    "export LIBVA_DRIVER_NAME=nvidia"
    "export XDG_SESSION_TYPE=wayland"
    "export GBM_BACKEND=nvidia-drm"
    "export __GLX_VENDOR_LIBRARY_NAME=nvidia"
    "export WLR_NO_HARDWARE_CURSORS=1"
)

for var in "${vars[@]}"; do
    key=$(echo "$var" | cut -d= -f1 | sed 's/export //')
    grep -qF "$key" "$ZSHENV" 2>/dev/null || echo "$var" >> "$ZSHENV"
done

chown "$USERNAME:$USERNAME" "$ZSHENV"
log_success "Nvidia Wayland configuration applied"
