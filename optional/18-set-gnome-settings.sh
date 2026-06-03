#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

# This script must run as the real user, not root
if [ "$(id -u)" -eq 0 ]; then
    log_error "This script must run as the regular user, not root. Run: ./18-set-gnome-settings.sh"
    exit 1
fi

# Check if running GNOME
if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
    log_skip "Not a GNOME session (detected: ${XDG_CURRENT_DESKTOP:-unknown}), skipping..."
    exit 0
fi

log_info "Configuring GNOME settings and keybindings..."

# ---------------------------------------------------------------------------
# General settings
# ---------------------------------------------------------------------------
gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false

# Dynamic workspaces
gsettings set org.gnome.mutter dynamic-workspaces true

# Disable Super overlay key so Vicinae can use it
#gsettings set org.gnome.mutter overlay-key ''

# ---------------------------------------------------------------------------
# Window management
# ---------------------------------------------------------------------------
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q', '<Alt>F4']"
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Shift>F11']"
gsettings set org.gnome.desktop.wm.keybindings begin-resize "['<Super>BackSpace']"
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"

# Tiling left/right
gsettings set org.gnome.desktop.wm.keybindings tile-left "['<Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings tile-right "['<Super>Right']"

# ---------------------------------------------------------------------------
# Workspace navigation
# ---------------------------------------------------------------------------
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Ctrl><Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Ctrl><Alt>Right']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"

# Move app to workspace
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Shift><Super>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Shift><Super>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Shift><Super>3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Shift><Super>4']"

# ---------------------------------------------------------------------------
# Input source
# ---------------------------------------------------------------------------
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Super>i']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "@as []"

# ---------------------------------------------------------------------------
# Dock app shortcuts
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Custom keybindings
# ---------------------------------------------------------------------------
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/',
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/'
]"

# Super+Space — Vicinae
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Vicinae'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'vicinae toggle'
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

log_success "GNOME settings configured"
