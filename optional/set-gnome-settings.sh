#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
. "$SCRIPT_DIR/lib/gnome.sh"
set -eo pipefail

if [ "$(id -u)" -eq 0 ]; then
    log_error "This script must run as the regular user, not root. Run: ./optional/set-gnome-settings.sh"
    exit 1
fi

if [ "${XDG_CURRENT_DESKTOP:-}" != "GNOME" ]; then
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

# App indicator
log_info "Installing app indicator support..."
sudo_pkg_install gnome-shell-extension-appindicator

# Disable default Ubuntu extensions (no-op on Fedora)
if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "pop" || "$DISTRO" == "linuxmint" ]]; then
    log_info "Disabling default Ubuntu extensions..."
    gnome-extensions disable tiling-assistant@ubuntu.com     2>/dev/null || true
    gnome-extensions disable ubuntu-dock@ubuntu.com          2>/dev/null || true
    gnome-extensions disable ding@rastersoft.com             2>/dev/null || true
fi

# Install extensions
log_info "Installing GNOME extensions..."

extensions=(
    "dash-to-dock@micxgx.gmail.com"
    "blur-my-shell@aunetx"
    "system-monitor-panel@naimur"
    "no-overview@fthx"
    "places-menu@gnome-shell-extensions.gcampax.github.com"
)

for ext in "${extensions[@]}"; do
    log_info "Installing $ext..."
    if find_extension_dir "$ext" >/dev/null; then
        log_skip "$ext already installed"
        continue
    fi
    gext install "$ext" || { log_error "Failed to install $ext"; exit 1; }
done

# Prepare extension schemas
BLUR_SCHEMA_DIR=$(extension_schema_dir blur-my-shell@aunetx org.gnome.shell.extensions.blur-my-shell)
DOCK_SCHEMA_DIR=$(extension_schema_dir dash-to-dock@micxgx.gmail.com org.gnome.shell.extensions.dash-to-dock)
MONITOR_SCHEMA=org.gnome.shell.extensions.system-monitor-panel
MONITOR_SCHEMA_DIR=$(extension_schema_dir system-monitor-panel@naimur "$MONITOR_SCHEMA")

# Configure Blur My Shell
log_info "Configuring Blur My Shell..."
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.appfolder blur false
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.lockscreen blur false
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.screenshot blur false
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.window-list blur false
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.panel blur true
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.overview blur true
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.overview pipeline 'pipeline_default'
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur false
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.dash-to-dock brightness 0.6
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.dash-to-dock sigma 30
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.dash-to-dock static-blur true
extension_gsettings "$BLUR_SCHEMA_DIR" set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 0

# Configure System Monitor
log_info "Configuring System Monitor..."
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" panel-position 'left'
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" panel-order "['memory', 'cpu', 'gpu', 'disk', 'temperature', 'network']"
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" refresh-interval 30
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" temperature-unit 'celsius'
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" network-unit 'bytes'
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-icons true
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-memory true
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-cpu true
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-gpu true
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-disk false
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-temperature true
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-network false
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-memory-card true
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-cpu-card true
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-gpu-card false
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-disk-card true
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-temperature-card true
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-network-card true
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" show-external-disks true
extension_gsettings "$MONITOR_SCHEMA_DIR" set "$MONITOR_SCHEMA" system-monitor-app "''"

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
extension_gsettings "$DOCK_SCHEMA_DIR" set org.gnome.shell.extensions.dash-to-dock hot-keys false
for app in {1..9}; do
    gsettings set org.gnome.shell.keybindings "switch-to-application-$app" "['<Super><Alt>$app']"
done

# Custom keybindings
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/'
]"

# Super+Space — Albert
set_custom_shortcut 0 'Albert' 'albert toggle' '<Super>space'

# Ctrl+Print — Flameshot
set_custom_shortcut 1 'Flameshot' 'sh -c -- "flameshot gui"' '<Control>Print'

# Shift+Alt+2 — novo Ghostty
set_custom_shortcut 2 'New Ghostty Window' 'ghostty' '<Shift><Alt>2'

# Shift+Alt+1 — novo Chrome
set_custom_shortcut 3 'New Chrome Window' 'google-chrome --new-window' '<Shift><Alt>1'

# Lock screen — Ctrl+Super+Q
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Ctrl><Super>q']"

# Rectangle-style keybindings
# Maximize and move use Super to preserve IntelliJ Ctrl+Alt+Enter and Alt+F7.
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Control><Alt>Left']"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Control><Alt>Right']"
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

gsettings set org.gnome.shell disable-user-extensions false

log_success "GNOME extensions and desktop settings configured. Reboot to finish setup."
