#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing Spotify..."
curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg \
    | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg \
    || { log_error "Failed to add Spotify GPG key!"; exit 1; }

echo "deb [signed-by=/etc/apt/trusted.gpg.d/spotify.gpg] http://repository.spotify.com stable non-free" \
    | tee /etc/apt/sources.list.d/spotify.list

apt update -y
apt install -y spotify-client || { log_error "Spotify installation failed!"; exit 1; }
log_success "Spotify installed"
