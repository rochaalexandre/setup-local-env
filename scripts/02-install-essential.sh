#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
require_root

log_info "Installing essential packages..."
apt install -y \
    unzip wget curl gpg uidmap \
    build-essential pkg-config autoconf bison clang rustc \
    libssl-dev libreadline-dev zlib1g-dev libyaml-dev libncurses5-dev \
    libffi-dev libgdbm-dev libjemalloc2 \
    libx11-dev libxft-dev libxinerama-dev \
    libvips libmagickwand-dev mupdf mupdf-tools \
    gir1.2-gtop-2.0 gir1.2-clutter-1.0 \
    redis-tools sqlite3 libsqlite3-0 \
    libmysqlclient-dev libpq-dev postgresql-client \
    apt-transport-https neofetch flameshot autojump \
    || { log_error "Essential packages installation failed!"; exit 1; }

log_success "Essential packages installed"
