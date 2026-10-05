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

# 2. Optional tweaks — run individually, only the ones you want
./optional/set-gnome-settings.sh            # as your regular user, NOT sudo
sudo ./optional/configure-nvidia-wayland.sh # needs root; only if on Nvidia
```

`install.sh` runs each script in `scripts/` in the order listed in its
`SCRIPTS=()` array. A failing script is logged and the run continues; a summary
is printed at the end. Scripts in `optional/` are standalone — run whichever
you want. The GNOME script installs extensions before applying their configuration.

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
| `install-claude-code` | Claude Code CLI (per-user native install via `claude.ai/install.sh`) |
| `install-codex` | Codex CLI (per-user standalone install via `chatgpt.com/codex/install.sh`) |

The AI CLIs use standalone installers and do not require Node.js. After setup,
run `claude` and `codex` as your regular user to sign in. Ensure `~/.local/bin`
is on your PATH in your dotfiles.

### Terminal & shell

| Script | Purpose |
| --- | --- |
| `install-zsh` | Install Zsh, set as the user's default shell |
| `install-starship` | Starship prompt → `/usr/local/bin` |

> Shell configuration (`.zshrc` etc.) is **not** managed here — it lives in a
> separate dotfiles repo.

### Cleanup

| Script | Purpose |
| --- | --- |
| `finalize` | Package cache cleanup / autoremove |

### `optional/` — run individually, not part of `install.sh`

| Script | Run as | Purpose |
| --- | --- | --- |
| `set-gnome-settings` | user | Install GNOME extensions and configure desktop settings, shortcuts, and Shatter Shell as the default tiling setup |
| `configure-nvidia-wayland` | root | Nvidia only: prompt, install drivers, write Wayland env vars to `~/.config/environment.d/nvidia.conf`. Skip if Nouveau works for you. |

`set-gnome-settings` installs extensions, prepares their schemas, and applies
settings in one run. Existing extensions are reused. Shatter Shell handles tiling
and Super+Arrow focus; Ctrl+Alt shortcuts handle snapping and maximizing.
Shatter Shell requires GNOME 48–51. On Fedora, the script adds the Terra community
repository, removes the Pop Shell package, and installs Shatter Shell. On Ubuntu
and derivatives with a compatible GNOME version, it builds release 2.3.1 from
source using git, make, and npm. Older GNOME versions are rejected before changes.
See the [upstream installation instructions](https://github.com/adil192/shatter-shell#installation).
Log out and back in after installing; enable Shatter Shell in Extension Manager
if it could not be enabled during the run.
The GNOME script skips on non-GNOME sessions; the Nvidia script skips if no
Nvidia GPU is detected.

## Layout

```
install.sh              # core installer (root) — SCRIPTS=() array defines order
lib/
  common.sh             # distro detection, pkg_* helpers, logging, user resolution
  packages.sh           # per-distro package name map
scripts/                # steps run by install.sh (unnumbered; order lives in install.sh)
optional/               # standalone extras — run individually, pick what you want
  set-gnome-settings.sh
  configure-nvidia-wayland.sh
```

## Adding a step

1. Add `scripts/<name>.sh` (source `lib/common.sh`, call `require_root`).
2. Add `<name>` to the `SCRIPTS=()` array in `install.sh` at the right position.

Use the `pkg_install` / `pkg_update` / `pkg_add_repo` helpers and the `PKG_*`
variables so both distros stay supported.
