#!/bin/bash

# ---------------------------------------------------------------------------
# Resolve the real (non-root) username reliably.
# SUDO_USER is set by sudo and is the most reliable source.
# Falls back to logname, then to the first UID-1000 user.
# ---------------------------------------------------------------------------
resolve_username() {
    if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
        echo "$SUDO_USER"
        return
    fi

    local logged_in
    logged_in=$(logname 2>/dev/null)
    if [ -n "$logged_in" ] && [ "$logged_in" != "root" ]; then
        echo "$logged_in"
        return
    fi

    id -nu 1000 2>/dev/null
}

USERNAME=$(resolve_username)
USER_HOME=$(eval echo "~$USERNAME")

export USERNAME
export USER_HOME

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
log_info()    { printf "  %s\n" "$*"; }
log_success() { printf "✅ %s\n" "$*"; }
log_error()   { printf "❌ %s\n" "$*" >&2; }
log_skip()    { printf "⏩ %s\n" "$*"; }
log_section() { printf "\n==========================================\n📦 %s\n==========================================\n" "$*"; }

# ---------------------------------------------------------------------------
# Ensure script is running as root
# ---------------------------------------------------------------------------
require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_error "This script must be run as root. Use: sudo $0"
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Run a command as the real user
# ---------------------------------------------------------------------------
run_as_user() {
    sudo -u "$USERNAME" "$@"
}
