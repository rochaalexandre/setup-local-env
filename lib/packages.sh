#!/bin/bash
# ---------------------------------------------------------------------------
# Package name mapping per distro.
# Scripts should reference these variables instead of hardcoded package names.
# ---------------------------------------------------------------------------

case "$DISTRO" in
    ubuntu|pop|linuxmint)
        # Build tools
        PKG_BUILD_ESSENTIAL="build-essential"
        PKG_PKG_CONFIG="pkg-config"
        PKG_CLANG="clang"
        PKG_RUSTC="rustc"
        PKG_BISON="bison"
        PKG_AUTOCONF="autoconf"

        # Libs
        PKG_OPENSSL_DEV="libssl-dev"
        PKG_READLINE_DEV="libreadline-dev"
        PKG_ZLIB_DEV="zlib1g-dev"
        PKG_YAML_DEV="libyaml-dev"
        PKG_NCURSES_DEV="libncurses5-dev"
        PKG_FFI_DEV="libffi-dev"
        PKG_GDBM_DEV="libgdbm-dev"
        PKG_JEMALLOC="libjemalloc2"
        PKG_X11_DEV="libx11-dev"
        PKG_XFT_DEV="libxft-dev"
        PKG_XINERAMA_DEV="libxinerama-dev"
        PKG_VIPS="libvips"
        PKG_MAGICKWAND="libmagickwand-dev"
        PKG_SQLITE3="sqlite3 libsqlite3-0"
        PKG_SQLITE3_DEV="libsqlite3-dev"
        PKG_MYSQL_DEV="libmysqlclient-dev"
        PKG_PG_DEV="libpq-dev"
        PKG_PG_CLIENT="postgresql-client postgresql-client-common"

        # Tools
        PKG_CURL="curl"
        PKG_WGET="wget"
        PKG_UNZIP="unzip"
        PKG_GPG="gpg"
        PKG_UIDMAP="uidmap"
        PKG_MUPDF="mupdf mupdf-tools"
        PKG_GIR_GTOP="gir1.2-gtop-2.0"
        PKG_GIR_CLUTTER="gir1.2-clutter-1.0"
        PKG_REDIS_CLI="redis-tools"
        PKG_NEOFETCH="neofetch"
        PKG_FLAMESHOT="flameshot"
        PKG_AUTOJUMP="autojump"
        PKG_APT_TRANSPORT="apt-transport-https"
        PKG_SOFTWARE_PROPS="software-properties-common"
        PKG_FLATPAK_PLUGIN="gnome-software-plugin-flatpak"
        PKG_DBUS_USER="dbus-user-session"
        ;;

    fedora)
        # Build tools
        PKG_BUILD_ESSENTIAL="@development-tools"
        PKG_PKG_CONFIG="pkgconf-pkg-config"
        PKG_CLANG="clang"
        PKG_RUSTC="rust"
        PKG_BISON="bison"
        PKG_AUTOCONF="autoconf"

        # Libs
        PKG_OPENSSL_DEV="openssl-devel"
        PKG_READLINE_DEV="readline-devel"
        PKG_ZLIB_DEV="zlib-devel"
        PKG_YAML_DEV="libyaml-devel"
        PKG_NCURSES_DEV="ncurses-devel"
        PKG_FFI_DEV="libffi-devel"
        PKG_GDBM_DEV="gdbm-devel"
        PKG_JEMALLOC="jemalloc"
        PKG_X11_DEV="libX11-devel"
        PKG_XFT_DEV="libXft-devel"
        PKG_XINERAMA_DEV="libXinerama-devel"
        PKG_VIPS="vips"
        PKG_MAGICKWAND="ImageMagick-devel"
        PKG_SQLITE3="sqlite"
        PKG_SQLITE3_DEV="sqlite-devel"
        PKG_MYSQL_DEV="mysql-devel"
        PKG_PG_DEV="libpq-devel"
        PKG_PG_CLIENT="postgresql"

        # Tools
        PKG_CURL="curl"
        PKG_WGET="wget"
        PKG_UNZIP="unzip"
        PKG_GPG="gnupg2"
        PKG_UIDMAP="shadow-utils"  # uidmap is included in shadow-utils on Fedora
        PKG_MUPDF="mupdf"
        PKG_GIR_GTOP="libgtop2-devel"
        PKG_GIR_CLUTTER=""  # not available on Fedora, skipped
        PKG_REDIS_CLI="redis"
        PKG_NEOFETCH="fastfetch"
        PKG_FLAMESHOT="flameshot"
        PKG_AUTOJUMP="autojump"
        PKG_APT_TRANSPORT=""        # apt-specific, not needed
        PKG_SOFTWARE_PROPS=""       # apt-specific, not needed
        PKG_FLATPAK_PLUGIN="gnome-software"
        PKG_DBUS_USER="dbus-daemon"
        ;;

    *)
        echo "Unsupported distro: $DISTRO"
        exit 1
        ;;
esac
