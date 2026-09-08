#!/bin/bash
# Optional GNOME desktop tweaks. Run as your regular user (NOT root, NOT sudo):
#   ./optional/install.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../lib/common.sh"

if [ "$(id -u)" -eq 0 ]; then
    log_error "Run as your regular user, not root: ./optional/install.sh"
    exit 1
fi

# set-gnome-extensions installs dash-to-dock etc. that set-gnome-settings configures
SCRIPTS=(
    set-gnome-extensions
    set-gnome-settings
)

for name in "${SCRIPTS[@]}"; do
    log_section "$name"
    bash "$SCRIPT_DIR/$name.sh" && log_success "$name completed" || log_error "$name failed"
done
