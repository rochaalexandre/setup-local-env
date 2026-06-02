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

loginctl enable-linger "$USERNAME"

run_as_user dockerd-rootless-setuptool.sh install \
    || { log_error "Docker rootless setup failed!"; exit 1; }

DOCKER_ENV="export DOCKER_HOST=unix:///run/user/$(id -u $USERNAME)/docker.sock"
ZSHENV="$USER_HOME/.zshenv"
grep -qF "DOCKER_HOST" "$ZSHENV" 2>/dev/null || echo "$DOCKER_ENV" >> "$ZSHENV"

log_success "Docker installed (rootless)"
