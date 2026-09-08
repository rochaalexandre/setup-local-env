#!/bin/bash

# ---------------------------------------------------------------------------
# Detect distro
# ---------------------------------------------------------------------------
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="${ID:-unknown}"
else
    DISTRO="unknown"
fi
export DISTRO

# ---------------------------------------------------------------------------
# Resolve the real (non-root) username reliably.
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
# Package manager abstraction
# ---------------------------------------------------------------------------
pkg_install() {
    # Filter out empty package names (distros that don't have a package)
    local pkgs=""
    for p in "$@"; do
        [ -n "$p" ] && pkgs="$pkgs $p"
    done
    [ -z "$pkgs" ] && return 0

    case "$DISTRO" in
        ubuntu|pop|linuxmint) apt install -y $pkgs ;;
        fedora)               dnf install -y --skip-unavailable $pkgs ;;
        *) log_error "Unsupported distro: $DISTRO"; exit 1 ;;
    esac
}

# Same as pkg_install but for scripts running as the regular user
sudo_pkg_install() {
    case "$DISTRO" in
        ubuntu|pop|linuxmint) sudo apt install -y "$@" ;;
        fedora)               sudo dnf install -y --skip-unavailable "$@" ;;
        *) log_error "Unsupported distro: $DISTRO"; exit 1 ;;
    esac
}

pkg_update() {
    case "$DISTRO" in
        ubuntu|pop|linuxmint) apt update && apt upgrade -y ;;
        fedora)               dnf upgrade -y ;;
        *) log_error "Unsupported distro: $DISTRO"; exit 1 ;;
    esac
}

pkg_cleanup() {
    case "$DISTRO" in
        ubuntu|pop|linuxmint) apt autoremove -y && apt autoclean ;;
        fedora)               dnf autoremove -y ;;
        *) log_error "Unsupported distro: $DISTRO"; exit 1 ;;
    esac
}

pkg_add_repo() {
    # Usage: pkg_add_repo <ubuntu-ppa> <fedora-copr>
    local ppa="$1"
    local copr="$2"
    case "$DISTRO" in
        ubuntu|pop|linuxmint)
            pkg_install software-properties-common
            add-apt-repository -y "$ppa"
            apt update
            ;;
        fedora)
            dnf copr enable -y "$copr"
            ;;
    esac
}

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

# ---------------------------------------------------------------------------
# Load package mappings
# ---------------------------------------------------------------------------
SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
. "$SCRIPT_ROOT/lib/packages.sh"
