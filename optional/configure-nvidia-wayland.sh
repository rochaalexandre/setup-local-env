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

# systemd user environment — picked up by the Wayland session at login,
# not just by shells (which is why .zshenv would not work here).
ENV_DIR="$USER_HOME/.config/environment.d"
ENV_FILE="$ENV_DIR/nvidia.conf"

run_as_user mkdir -p "$ENV_DIR"
run_as_user tee "$ENV_FILE" > /dev/null << 'EOF'
LIBVA_DRIVER_NAME=nvidia
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1
EOF

log_success "Nvidia Wayland configuration applied (relog to take effect)"
