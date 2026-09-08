#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

if [ "$(id -u)" -eq 0 ]; then
    log_error "This script must run as the regular user, not root. Run: ./optional/set-gnome-extensions.sh"
    exit 1
fi

if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
    log_skip "Not a GNOME session (detected: ${XDG_CURRENT_DESKTOP:-unknown}), skipping..."
    exit 0
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
#gnome-extensions disable ubuntu-appindicators@ubuntu.com 2>/dev/null || true
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
    "tactile@lundal.io"
    "Resource_Monitor@Ory0n"
    "no-overview@fthx"
    "places-menu@gnome-shell-extensions.gcampax.github.com"
)

for ext in "${extensions[@]}"; do
    log_info "Installing $ext..."
    gext install "$ext" || log_error "Failed to install $ext — skipping"
done

# ---------------------------------------------------------------------------
# Compile gsettings schemas
# ---------------------------------------------------------------------------
log_info "Compiling gsettings schemas..."

schemas=(
    "tactile@lundal.io/schemas/org.gnome.shell.extensions.tactile.gschema.xml"
    "blur-my-shell@aunetx/schemas/org.gnome.shell.extensions.blur-my-shell.gschema.xml"
)

EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"

for schema in "${schemas[@]}"; do
    src="$EXTENSIONS_DIR/$schema"
    dst="/usr/share/glib-2.0/schemas/$(basename "$schema")"
    [ -f "$src" ] && sudo cp "$src" "$dst" || log_error "Schema not found: $src"
done

sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

# ---------------------------------------------------------------------------
# Configure Tactile
# ---------------------------------------------------------------------------
log_info "Configuring Tactile..."
gsettings set org.gnome.shell.extensions.tactile col-0 1
gsettings set org.gnome.shell.extensions.tactile col-1 2
gsettings set org.gnome.shell.extensions.tactile col-2 1
gsettings set org.gnome.shell.extensions.tactile col-3 0
gsettings set org.gnome.shell.extensions.tactile row-0 1
gsettings set org.gnome.shell.extensions.tactile row-1 1
gsettings set org.gnome.shell.extensions.tactile gap-size 32

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

log_success "GNOME extensions installed and configured"
