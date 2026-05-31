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
# Required packages for rootless
apt install -y uidmap dbus-user-session

# Enable lingering so user services survive logout
loginctl enable-linger "$USERNAME"

# Setup rootless docker as the real user
run_as_user dockerd-rootless-setuptool.sh install \
    || { log_error "Docker rootless setup failed!"; exit 1; }

# Configure environment for rootless docker
DOCKER_ENV="export DOCKER_HOST=unix:///run/user/$(id -u $USERNAME)/docker.sock"
PROFILE="$USER_HOME/.profile"
grep -qF "DOCKER_HOST" "$PROFILE" 2>/dev/null || echo "$DOCKER_ENV" >> "$PROFILE"

log_success "Docker installed (rootless)"
