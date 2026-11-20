#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
set -eo pipefail

if [ "$(id -u)" -eq 0 ]; then
    log_error "This script must run as the regular user, not root. Run: ./optional/set-gnome-settings.sh"
    exit 1
fi

if [ "${XDG_CURRENT_DESKTOP:-}" != "GNOME" ]; then
    log_skip "Not a GNOME session (detected: ${XDG_CURRENT_DESKTOP:-unknown}), skipping..."
    exit 0
fi

# Shatter Shell 2.3.1 supports GNOME 48–51.
GNOME_MAJOR=$(gnome-shell --version | awk '{print int($3)}')
case "$GNOME_MAJOR" in
    48|49|50|51) ;;
    *)
        log_error "Shatter Shell 2.3.1 requires GNOME 48–51 (detected: $GNOME_MAJOR)"
        exit 1
        ;;
esac

# Shatter Shell is distributed through Terra or built from source, not gext.
# https://github.com/adil192/shatter-shell/blob/master_resolute/README.md
SHATTER_UUID=shatter-shell@adilhanney.com
USER_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
if [ -d "$USER_DATA_DIR/gnome-shell/extensions/$SHATTER_UUID" ] || \
   [ -d "/usr/share/gnome-shell/extensions/$SHATTER_UUID" ]; then
    log_skip "Shatter Shell already installed"
else
    log_info "Installing Shatter Shell..."
    case "$DISTRO" in
        fedora)
            sudo dnf install -y --nogpgcheck \
                --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
            sudo dnf remove -y gnome-shell-extension-pop-shell
            sudo_pkg_install gnome-shell-extension-shatter-shell
            ;;
        ubuntu|pop|linuxmint)
            sudo_pkg_install git make npm
            SHATTER_BUILD_DIR=$(mktemp -d)
            trap 'rm -rf "$SHATTER_BUILD_DIR"' EXIT
            git clone --depth 1 --branch 2.3.1 \
                https://github.com/adil192/shatter-shell.git "$SHATTER_BUILD_DIR"
            # Use the build/schema targets without upstream's interactive shortcut reset.
            # This script owns the desktop configuration below.
            make -C "$SHATTER_BUILD_DIR" install local-schema
            rm -rf "$SHATTER_BUILD_DIR"
            trap - EXIT
            ;;
    esac
fi

# GNOME loads the extension-local compiled schema even when a global schema exists.
SHATTER_EXTENSION_DIR="$USER_DATA_DIR/gnome-shell/extensions/$SHATTER_UUID"
if [ ! -d "$SHATTER_EXTENSION_DIR" ]; then
    SHATTER_EXTENSION_DIR="/usr/share/gnome-shell/extensions/$SHATTER_UUID"
fi
SHATTER_SCHEMA_DIR="$SHATTER_EXTENSION_DIR/schemas"
if [ ! -f "$SHATTER_SCHEMA_DIR/org.gnome.shell.extensions.shatter-shell.gschema.xml" ]; then
    log_error "Shatter Shell schema XML missing: $SHATTER_SCHEMA_DIR"
    exit 1
fi
log_info "Compiling Shatter Shell extension schema..."
if [ "$SHATTER_EXTENSION_DIR" = "/usr/share/gnome-shell/extensions/$SHATTER_UUID" ]; then
    sudo glib-compile-schemas --strict "$SHATTER_SCHEMA_DIR"
else
    glib-compile-schemas --strict "$SHATTER_SCHEMA_DIR"
fi

# Source installs put the schema in the user's data directory.
if [ -f "$USER_DATA_DIR/glib-2.0/schemas/org.gnome.shell.extensions.shatter-shell.gschema.xml" ]; then
    export GSETTINGS_SCHEMA_DIR="$USER_DATA_DIR/glib-2.0/schemas"
fi
SHATTER=org.gnome.shell.extensions.shatter-shell
if ! gsettings list-keys "$SHATTER" >/dev/null 2>&1; then
    log_error "Shatter Shell schema unavailable; cannot configure the default tiling setup"
    exit 1
fi

log_info "Installing GNOME extension manager..."

case "$DISTRO" in
    ubuntu|pop|linuxmint)
        sudo_pkg_install gnome-shell-extension-manager
        ;;
    fedora)
        flatpak install -y flathub com.mattjakeman.ExtensionManager
        ;;
esac

log_info "Installing pipx and gnome-extensions-cli..."
sudo_pkg_install pipx
pipx install gnome-extensions-cli --system-site-packages \
    || { log_error "Failed to install gnome-extensions-cli!"; exit 1; }

export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
# App indicator
# ---------------------------------------------------------------------------
log_info "Installing app indicator support..."
sudo_pkg_install gnome-shell-extension-appindicator

# ---------------------------------------------------------------------------
# Disable default Ubuntu extensions (no-op on Fedora)
# ---------------------------------------------------------------------------
if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "pop" || "$DISTRO" == "linuxmint" ]]; then
    log_info "Disabling default Ubuntu extensions..."
    gnome-extensions disable tiling-assistant@ubuntu.com     2>/dev/null || true
    gnome-extensions disable ubuntu-dock@ubuntu.com          2>/dev/null || true
    gnome-extensions disable ding@rastersoft.com             2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Install extensions
# ---------------------------------------------------------------------------
log_info "Installing GNOME extensions..."

extensions=(
    "dash-to-dock@micxgx.gmail.com"
    "blur-my-shell@aunetx"
    "Resource_Monitor@Ory0n"
    "no-overview@fthx"
    "places-menu@gnome-shell-extensions.gcampax.github.com"
)

for ext in "${extensions[@]}"; do
    log_info "Installing $ext..."
    if [ -d "$HOME/.local/share/gnome-shell/extensions/$ext" ] || \
       [ -d "/usr/share/gnome-shell/extensions/$ext" ]; then
        log_skip "$ext already installed"
        continue
    fi
    gext install "$ext" || { log_error "Failed to install $ext"; exit 1; }
done

# ---------------------------------------------------------------------------
# Compile gsettings schemas
# ---------------------------------------------------------------------------
log_info "Compiling gsettings schemas..."

schemas=(
    "blur-my-shell@aunetx/schemas/org.gnome.shell.extensions.blur-my-shell.gschema.xml"
    "dash-to-dock@micxgx.gmail.com/schemas/org.gnome.shell.extensions.dash-to-dock.gschema.xml"
)

EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"

for schema in "${schemas[@]}"; do
    src="$EXTENSIONS_DIR/$schema"
    dst="/usr/share/glib-2.0/schemas/$(basename "$schema")"
    if [ -f "$src" ]; then
        sudo cp "$src" "$dst"
    elif [ ! -f "$dst" ]; then
        log_error "Schema not found: $src or $dst"
        exit 1
    fi
done

sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

# ---------------------------------------------------------------------------
# Configure Blur My Shell
# ---------------------------------------------------------------------------
log_info "Configuring Blur My Shell..."
gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.lockscreen blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.screenshot blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.window-list blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.overview blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.overview pipeline 'pipeline_default'
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock brightness 0.6
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock sigma 30
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock static-blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 0


log_info "Configuring GNOME settings and keybindings..."

# General settings
gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false
gsettings set org.gnome.shell.window-switcher current-workspace-only false
gsettings set org.gnome.shell.app-switcher current-workspace-only false

# Dynamic workspaces
gsettings set org.gnome.mutter dynamic-workspaces true

# Overview: tap Super alone, or Super+W
gsettings set org.gnome.mutter overlay-key 'Super_L'
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>w']"

# ---------------------------------------------------------------------------
# Window management
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q', '<Alt>F4']"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Shift>F11']"
gsettings set org.gnome.desktop.wm.keybindings begin-resize "['<Super>BackSpace']"
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Shift><Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Shift><Super>Right']"

# Free IntelliJ change navigation; windows move between workspaces horizontally.
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "@as []"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "@as []"

# Workspace navigation
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Ctrl><Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Ctrl><Super>Right']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Shift><Super>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Shift><Super>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Shift><Super>3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Shift><Super>4']"

# App switcher — Alt+Tab
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Super><Alt>Tab']"


# Input source
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Super>i']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "@as []"

# Dock app shortcuts
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
gsettings set org.gnome.shell.keybindings switch-to-application-1 "['<Super><Alt>1']"
gsettings set org.gnome.shell.keybindings switch-to-application-2 "['<Super><Alt>2']"
gsettings set org.gnome.shell.keybindings switch-to-application-3 "['<Super><Alt>3']"
gsettings set org.gnome.shell.keybindings switch-to-application-4 "['<Super><Alt>4']"
gsettings set org.gnome.shell.keybindings switch-to-application-5 "['<Super><Alt>5']"
gsettings set org.gnome.shell.keybindings switch-to-application-6 "['<Super><Alt>6']"
gsettings set org.gnome.shell.keybindings switch-to-application-7 "['<Super><Alt>7']"
gsettings set org.gnome.shell.keybindings switch-to-application-8 "['<Super><Alt>8']"
gsettings set org.gnome.shell.keybindings switch-to-application-9 "['<Super><Alt>9']"

# Custom keybindings
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/'
]"

# Super+Space — Albert
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Albert'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'albert toggle'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>space'

# Ctrl+Print — Flameshot
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Flameshot'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'sh -c -- "flameshot gui"'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Control>Print'

# Shift+Alt+2 — novo Ghostty
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'New Ghostty Window'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'ghostty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Shift><Alt>2'

# Shift+Alt+1 — novo Chrome
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name 'New Chrome Window'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command 'google-chrome --new-window'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding '<Shift><Alt>1'

# Lock screen — Ctrl+Super+Q
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Ctrl><Super>q']"


log_info "Configuring Shatter Shell and Rectangle-style keybindings..."
gnome-extensions disable pop-shell@system76.com 2>/dev/null || true
gsettings set org.gnome.shell disable-user-extensions false
gsettings set org.gnome.mutter workspaces-only-on-primary false
gnome-extensions enable "$SHATTER_UUID" \
    || log_info "Log out and back in, then enable Shatter Shell in Extension Manager"

# Layout:
#   1. macOS-shared keys      — desktop settings above (Super+Q, Super+Tab, ...)
#   2. Rectangle layer        — Ctrl+Alt+..., same keys as Rectangle on macOS
#   3. Shatter tiling layer   — Linux-only, Super+Arrows focus / Super+Return mode

# ---------------------------------------------------------------------------
# Rectangle layer (Ctrl+Opt on macOS = Ctrl+Alt here)
# Super+Arrows are handed over to Shatter focus; Ctrl+Alt+Left/Right tile.
# Maximize and move use Super to preserve IntelliJ Ctrl+Alt+Enter and Alt+F7.
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Control><Alt>Left']"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Control><Alt>Right']"
gsettings set org.gnome.desktop.wm.keybindings maximize "@as []"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['<Super>m']"
gsettings set org.gnome.desktop.wm.keybindings begin-move "['<Super><Alt>F7']"
# Keep notifications on Super+V, freeing Super+M for maximize.
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>v']"
gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Control><Alt>BackSpace', '<Alt>F5']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Control><Alt><Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Control><Alt><Super>Right']"

# Free Ctrl+Alt+Up/Down (workspaces are switched horizontally with Ctrl+Super)
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "@as []"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "@as []"

# Free Super+o for Shatter orientation (keep the hardware rotation-lock key)
gsettings set org.gnome.settings-daemon.plugins.media-keys rotate-video-lock-static "['XF86RotationLockToggle']"

# ---------------------------------------------------------------------------
# Shatter layer
# Focus: Super+Arrows, single modifier (COSMIC-style). Drops Super+h/j/k/l so
# Super+h stays GNOME minimize.
gsettings set "$SHATTER" focus-left "['<Super>Left']"
gsettings set "$SHATTER" focus-right "['<Super>Right']"
gsettings set "$SHATTER" focus-up "['<Super>Up']"
gsettings set "$SHATTER" focus-down "['<Super>Down']"

# Window management mode: Super+Return, then Arrows / Shift+Arrows to resize,
# Ctrl+Arrows to swap, Return to apply, Esc to cancel
gsettings set "$SHATTER" tile-enter "['<Super>Return']"

# Enable tiling by default
gsettings set "$SHATTER" tile-by-default true

# Toggles
gsettings set "$SHATTER" toggle-tiling "['<Super>y']"
gsettings set "$SHATTER" toggle-floating "['<Super>g']"
gsettings set "$SHATTER" tile-orientation "['<Super>o']"

log_success "GNOME extensions, desktop settings, and Shatter Shell configured"
