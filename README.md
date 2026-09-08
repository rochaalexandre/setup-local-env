# Setup Local Environment

Scripts to provision a fresh Linux development machine: system packages, dev
tools, applications, terminal/shell, and optional GNOME desktop tweaks.

## Supported distros

- Fedora
- Ubuntu (and derivatives: Pop!_OS, Linux Mint)

Distro is detected from `/etc/os-release`. Package names and repo setup are
mapped per distro in `lib/packages.sh` / `lib/common.sh`.

## Prerequisites

- Root/sudo access
- Internet connection
- Being logged into a desktop session (for the rootless Docker and optional
  GNOME steps)

## Usage

```bash
git clone <repository-url>
cd setup-local-env

# 1. Core install — run as root
sudo ./install.sh

# 2. Optional GNOME tweaks — run as your regular user, NOT sudo
./optional/install.sh
```

`install.sh` runs each script in `scripts/` in the order listed in its
`SCRIPTS=()` array. A failing script is logged and the run continues; a summary
is printed at the end.

## What gets installed

### System

| Script | Purpose |
| --- | --- |
| `update-system` | Update + upgrade all system packages |
| `install-essential` | Build toolchain, dev libraries (openssl, readline, sqlite, pg, mysql, ...), CLI utils (curl, wget, unzip, gpg, neofetch/fastfetch, flameshot, autojump, redis-cli, mupdf) |
| `install-fonts` | Nerd Fonts: FiraCode, Meslo, JetBrainsMono → `~/.fonts` |

### Applications

| Script | Purpose |
| --- | --- |
| `install-ghostty` | Ghostty terminal (PPA on Ubuntu, RPM repo on Fedora); set as `x-terminal-emulator` |
| `install-chrome` | Google Chrome (official Google repo) |
| `install-1password` | 1Password (official 1Password repo) |
| `install-flatpak` | Flatpak + Flathub remote |
| `install-spotify` | Spotify via Flathub (`com.spotify.Client`) |
| `install-jetbrains-toolbox` | JetBrains Toolbox App (JetBrains IDEs don't self-update on Linux); launch it and sign in to install IntelliJ |

### Development tools

| Script | Purpose |
| --- | --- |
| `install-docker` | Docker via `get.docker.com`, then rootless mode for the user; selects the `rootless` docker context (no shell env changes) |
| `install-zed` | Zed editor (per-user install via `zed.dev/install.sh`) |
| `install-mise` | Mise version manager (per-user install via `mise.run`) |

### Terminal & shell

| Script | Purpose |
| --- | --- |
| `install-zsh` | Install Zsh, set as the user's default shell |
| `install-starship` | Starship prompt → `/usr/local/bin` |

> Shell configuration (`.zshrc` etc.) is **not** managed here — it lives in a
> separate dotfiles repo.

### Desktop

| Script | Purpose |
| --- | --- |
| `configure-nvidia-wayland` | If an Nvidia GPU is present: prompt, install drivers, write Wayland env vars to `~/.config/environment.d/nvidia.conf` |
| `finalize` | Package cache cleanup / autoremove |

### Optional (`optional/install.sh`, run as user)

| Script | Purpose |
| --- | --- |
| `set-gnome-extensions` | Extension manager, `gnome-extensions-cli`, install + configure dash-to-dock, blur-my-shell, tactile, resource monitor, etc. |
| `set-gnome-settings` | GNOME keybindings and desktop settings (workspaces, window management, custom shortcuts) |

`set-gnome-extensions` must run before `set-gnome-settings` (the latter
configures extensions the former installs). Both are skipped on non-GNOME
sessions.

## Layout

```
install.sh              # core installer (root) — SCRIPTS=() array defines order
lib/
  common.sh             # distro detection, pkg_* helpers, logging, user resolution
  packages.sh           # per-distro package name map
scripts/                # individual install steps (unnumbered; order lives in install.sh)
optional/
  install.sh            # optional installer (regular user)
  set-gnome-extensions.sh
  set-gnome-settings.sh
```

## Adding a step

1. Add `scripts/<name>.sh` (source `lib/common.sh`, call `require_root`).
2. Add `<name>` to the `SCRIPTS=()` array in `install.sh` at the right position.

Use the `pkg_install` / `pkg_update` / `pkg_add_repo` helpers and the `PKG_*`
variables so both distros stay supported.
