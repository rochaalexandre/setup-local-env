#!/bin/bash

# GNOME helpers. Source common.sh first for logging.
EXTENSIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/gnome-shell/extensions"
SYSTEM_EXTENSIONS_DIR=/usr/share/gnome-shell/extensions

find_extension_dir() {
    if [ -d "$EXTENSIONS_DIR/$1" ]; then
        printf '%s\n' "$EXTENSIONS_DIR/$1"
    elif [ -d "$SYSTEM_EXTENSIONS_DIR/$1" ]; then
        printf '%s\n' "$SYSTEM_EXTENSIONS_DIR/$1"
    else
        return 1
    fi
}

extension_schema_dir() {
    local uuid="$1" schema="$2" dir

    if dir=$(find_extension_dir "$uuid"); then
        dir="$dir/schemas"
    fi

    if [ -n "$dir" ] && [ -f "$dir/$schema.gschema.xml" ]; then
        log_info "Preparing schema for $uuid..." >&2
        if [[ "$dir" == "$EXTENSIONS_DIR/"* ]]; then
            glib-compile-schemas --strict "$dir" || return 1
        elif [ ! -f "$dir/gschemas.compiled" ]; then
            sudo glib-compile-schemas --strict "$dir" || return 1
        fi
    fi

    if [ -n "$dir" ] && [ -f "$dir/gschemas.compiled" ] &&
       gsettings --schemadir "$dir" list-keys "$schema" >/dev/null 2>&1; then
        printf '%s\n' "$dir"
    elif ! gsettings list-keys "$schema" >/dev/null 2>&1; then
        log_error "Schema $schema unavailable for $uuid"
        return 1
    fi
}

extension_gsettings() {
    local dir="$1"
    shift
    if [ -n "$dir" ]; then
        gsettings --schemadir "$dir" "$@"
    else
        gsettings "$@"
    fi
}

set_custom_shortcut() {
    local schema="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
    local path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$1/"

    gsettings set "$schema:$path" name "$2" &&
        gsettings set "$schema:$path" command "$3" &&
        gsettings set "$schema:$path" binding "$4"
}
