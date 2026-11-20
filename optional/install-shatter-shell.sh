#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
. "$SCRIPT_DIR/lib/gnome.sh"
set -eo pipefail

if [ "$DISTRO" != fedora ]; then
    log_skip "Shatter Shell setup is only available on Fedora"
    exit 0
fi

if [ "$(id -u)" -eq 0 ]; then
    log_error "This script must run as the regular user, not root. Run: ./optional/install-shatter-shell.sh"
    exit 1
fi

if [ "${XDG_CURRENT_DESKTOP:-}" != "GNOME" ]; then
    log_skip "Not a GNOME session (detected: ${XDG_CURRENT_DESKTOP:-unknown}), skipping..."
    exit 0
fi

GNOME_MAJOR=$(gnome-shell --version | awk '{print int($3)}')
case "$GNOME_MAJOR" in
    48|49|50|51) ;;
    *)
        log_error "This Shatter Shell setup supports GNOME 48–51 (detected: $GNOME_MAJOR)"
        exit 1
        ;;
esac

SHATTER_UUID=shatter-shell@adilhanney.com
SHATTER=org.gnome.shell.extensions.shatter-shell

if ! find_extension_dir "$SHATTER_UUID" >/dev/null; then
    log_info "Installing Shatter Shell from Terra..."
    if ! rpm -q terra-release >/dev/null 2>&1; then
        sudo dnf install -y --nogpgcheck \
            --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
    fi
    sudo dnf install -y gnome-shell-extension-shatter-shell
fi

SHATTER_SCHEMA_DIR=$(extension_schema_dir "$SHATTER_UUID" "$SHATTER")

log_info "Configuring Shatter Shell and its shortcuts..."
gsettings set org.gnome.shell disable-user-extensions false
gsettings set org.gnome.mutter workspaces-only-on-primary false

# Give Super+Up to Shatter Shell focus navigation.
gsettings set org.gnome.desktop.wm.keybindings maximize "@as []"
# Free Super+o for Shatter orientation (keep the hardware rotation-lock key)
gsettings set org.gnome.settings-daemon.plugins.media-keys rotate-video-lock-static "['XF86RotationLockToggle']"

# Shatter layer
# Focus: Super+Arrows, single modifier (COSMIC-style). Drops Super+h/j/k/l so
# Super+h stays GNOME minimize.
extension_gsettings "$SHATTER_SCHEMA_DIR" set "$SHATTER" focus-left "['<Super>Left']"
extension_gsettings "$SHATTER_SCHEMA_DIR" set "$SHATTER" focus-right "['<Super>Right']"
extension_gsettings "$SHATTER_SCHEMA_DIR" set "$SHATTER" focus-up "['<Super>Up']"
extension_gsettings "$SHATTER_SCHEMA_DIR" set "$SHATTER" focus-down "['<Super>Down']"

# Window management mode: Super+Return, then Arrows / Shift+Arrows to resize,
# Ctrl+Arrows to swap, Return to apply, Esc to cancel
extension_gsettings "$SHATTER_SCHEMA_DIR" set "$SHATTER" tile-enter "['<Super>Return']"

# Enable tiling by default
extension_gsettings "$SHATTER_SCHEMA_DIR" set "$SHATTER" tile-by-default true

# Toggles
extension_gsettings "$SHATTER_SCHEMA_DIR" set "$SHATTER" toggle-tiling "['<Super>y']"
extension_gsettings "$SHATTER_SCHEMA_DIR" set "$SHATTER" toggle-floating "['<Super>g']"
extension_gsettings "$SHATTER_SCHEMA_DIR" set "$SHATTER" tile-orientation "['<Super>o']"

# Remove existing Pop Shell installations after configuring Shatter Shell.
POP_SHELL_UUID=pop-shell@system76.com
if find_extension_dir "$POP_SHELL_UUID" >/dev/null; then
    gnome-extensions disable "$POP_SHELL_UUID" 2>/dev/null || true
fi
if [ -e "$EXTENSIONS_DIR/$POP_SHELL_UUID" ] || [ -L "$EXTENSIONS_DIR/$POP_SHELL_UUID" ]; then
    rm -rf -- "$EXTENSIONS_DIR/$POP_SHELL_UUID"
fi
if rpm -q gnome-shell-extension-pop-shell >/dev/null 2>&1; then
    sudo dnf remove -y gnome-shell-extension-pop-shell
fi

log_success "Shatter Shell configured. Reboot to finish setup."
