#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Docker..."
curl -fsSL https://get.docker.com -o /tmp/install-docker.sh \
    || { log_error "Failed to download Docker installation script!"; exit 1; }

sh /tmp/install-docker.sh || { log_error "Docker installation failed!"; exit 1; }
rm /tmp/install-docker.sh

log_info "Configuring Docker rootless mode for $USERNAME..."
pkg_install $PKG_UIDMAP $PKG_DBUS_USER

# get.docker.com enables the rootful system daemon. We only want rootless —
# stop and disable it so there's a single daemon / socket.
systemctl disable --now docker.service docker.socket 2>/dev/null || true

loginctl enable-linger "$USERNAME"

USER_UID=$(id -u "$USERNAME")
sudo -u "$USERNAME" \
    XDG_RUNTIME_DIR="/run/user/$USER_UID" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_UID/bus" \
    PATH="/usr/bin:/usr/sbin:/bin:/sbin:$USER_HOME/.local/bin" \
    dockerd-rootless-setuptool.sh install \
    || { log_error "Docker rootless setup failed!"; exit 1; }

sudo -u "$USERNAME" \
    XDG_RUNTIME_DIR="/run/user/$USER_UID" \
    docker context use rootless 2>/dev/null \
    || log_info "Set DOCKER_HOST or run 'docker context use rootless' manually"

log_success "Docker installed (rootless)"
