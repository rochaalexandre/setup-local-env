#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

# JetBrains IDEs do not self-update on Linux. Install the Toolbox App instead —
# it manages IntelliJ (and other JetBrains IDEs) and keeps them updated.
#
# The Linux tarball is a full application tree (bin/ with a bundled JRE + libs),
# not a single binary. Unpack the whole thing; first run of ./bin/jetbrains-toolbox
# initializes ~/.local/share/JetBrains/Toolbox and creates the .desktop entry.

INSTALL_DIR="$USER_HOME/.local/jetbrains-toolbox"
BIN="$INSTALL_DIR/bin/jetbrains-toolbox"

if [ -x "$BIN" ]; then
    log_skip "JetBrains Toolbox already installed"
    exit 0
fi

log_info "Installing JetBrains Toolbox for $USERNAME..."

# Toolbox needs FUSE 2 at runtime.
case "$DISTRO" in
    ubuntu|pop|linuxmint)
        apt install -y libfuse2 || apt install -y libfuse2t64 || \
            log_error "Could not install libfuse2 — Toolbox may fail to start"
        ;;
    fedora)
        dnf install -y --skip-unavailable fuse fuse-libs
        ;;
esac

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fsSL "https://data.services.jetbrains.com/products/download?code=TBA&platform=linux" \
    | tar xz -C "$TMP_DIR" --strip 1 --exclude='._*' \
    || { log_error "JetBrains Toolbox download/extraction failed!"; exit 1; }

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cp -a "$TMP_DIR/." "$INSTALL_DIR/"
chown -R "$USERNAME:$USERNAME" "$INSTALL_DIR"

# First run self-installs Toolbox and creates its own desktop entry.
# Needs the user's graphical session; skip gracefully if not available.
USER_UID=$(id -u "$USERNAME")
if run_as_user test -S "/run/user/$USER_UID/bus"; then
    log_info "Bootstrapping Toolbox (first run)..."
    sudo -u "$USERNAME" \
        XDG_RUNTIME_DIR="/run/user/$USER_UID" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_UID/bus" \
        DISPLAY="${DISPLAY:-:0}" \
        "$BIN" --minimize >/dev/null 2>&1 &
    log_success "JetBrains Toolbox installed — sign in to install IntelliJ"
else
    log_success "JetBrains Toolbox installed — run '$BIN' after login to finish setup"
fi
