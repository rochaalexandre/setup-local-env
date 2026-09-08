#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing essential packages..."
pkg_install \
    $PKG_BUILD_ESSENTIAL $PKG_PKG_CONFIG $PKG_CLANG $PKG_RUSTC $PKG_BISON $PKG_AUTOCONF \
    $PKG_OPENSSL_DEV $PKG_READLINE_DEV $PKG_ZLIB_DEV $PKG_YAML_DEV $PKG_NCURSES_DEV \
    $PKG_FFI_DEV $PKG_GDBM_DEV $PKG_JEMALLOC \
    $PKG_X11_DEV $PKG_XFT_DEV $PKG_XINERAMA_DEV \
    $PKG_VIPS $PKG_MAGICKWAND $PKG_MUPDF \
    $PKG_GIR_GTOP $PKG_GIR_CLUTTER \
    $PKG_SQLITE3 $PKG_SQLITE3_DEV $PKG_MYSQL_DEV $PKG_PG_DEV $PKG_PG_CLIENT \
    $PKG_REDIS_CLI $PKG_CURL $PKG_WGET $PKG_UNZIP $PKG_GPG $PKG_UIDMAP \
    $PKG_NEOFETCH $PKG_FLAMESHOT $PKG_AUTOJUMP $PKG_APT_TRANSPORT \
    || { log_error "Essential packages installation failed!"; exit 1; }

log_success "Essential packages installed"
