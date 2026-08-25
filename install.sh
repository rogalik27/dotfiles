#!/usr/bin/env bash
# Bootstrap a fresh Debian-based Linux install with this dotfiles repo.
#
# One-liner usage on a new machine:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/rogalik27/dotfiles/main/install.sh)"
set -euo pipefail

REPO_URL="https://github.com/rogalik27/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

log() { printf '\033[1;32m==>\033[0m %s\n' "$1"; }

# ---------------------------------------------------------------------------
# 1. Get the repo onto disk
# ---------------------------------------------------------------------------
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  log "Cloning dotfiles into $DOTFILES_DIR"
  git clone "$REPO_URL" "$DOTFILES_DIR"
else
  log "Repo already present at $DOTFILES_DIR, pulling latest"
  git -C "$DOTFILES_DIR" pull --ff-only
fi

# ---------------------------------------------------------------------------
# 2. Install packages this config depends on
# ---------------------------------------------------------------------------
PACKAGES=(
  sway swaync waybar mako rofi alacritty kitty tmux neovim
  i3 htop mc git curl fish nushell libinput-tools
  grim slurp swappy wl-clipboard libnotify-bin cliphist
  swayidle swaylock brightnessctl pulseaudio-utils network-manager
  dbus polkitd lxpolkit jq playerctl python3 chafa
)

if command -v apt >/dev/null 2>&1; then
  log "Installing packages via apt (sudo required)"
  sudo apt update
  sudo apt install -y "${PACKAGES[@]}" || log "Some packages failed to install (check names for this distro release), continuing"
else
  log "No apt found, skipping package install — install manually: ${PACKAGES[*]}"
fi

if ! command -v gh >/dev/null 2>&1 && command -v apt >/dev/null 2>&1; then
  log "Installing GitHub CLI (gh)"
  (type -p wget >/dev/null || sudo apt install -y wget) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null \
    && sudo apt update && sudo apt install -y gh
fi

if ! command -v atuin >/dev/null 2>&1; then
  log "Installing atuin (shell history sync)"
  curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | bash
fi

if ! command -v lazygit >/dev/null 2>&1; then
  log "Installing lazygit"
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin
fi

# tmux plugin manager (plugins are fetched by TPM itself, never vendored here)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  log "Installing tmux plugin manager"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# wayfreeze (used by bin/screenshot-edit.sh) — not packaged for Debian, built via cargo
if ! command -v wayfreeze >/dev/null 2>&1 && ! [ -x "$HOME/.cargo/bin/wayfreeze" ]; then
  if ! command -v cargo >/dev/null 2>&1; then
    log "Installing Rust toolchain (needed to build wayfreeze)"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck disable=SC1091
    . "$HOME/.cargo/env"
  fi
  log "Building wayfreeze"
  cargo install wayfreeze
fi

# AirStatus (AirPods battery reader backing the airstatus.service unit)
if [ ! -d "$HOME/.local/share/AirStatus/.git" ]; then
  log "Cloning AirStatus"
  git clone https://github.com/delphiki/AirStatus "$HOME/.local/share/AirStatus"
  if command -v pip3 >/dev/null 2>&1; then
    pip3 install --user -r "$HOME/.local/share/AirStatus/requirements.txt" --break-system-packages 2>/dev/null \
      || pip3 install --user -r "$HOME/.local/share/AirStatus/requirements.txt"
  fi
fi

# worktime (the `wt` CLI time tracker) — separate repo, built from source
if ! command -v wt >/dev/null 2>&1 && ! [ -x "$HOME/.local/bin/wt" ]; then
  if ! command -v go >/dev/null 2>&1 && command -v apt >/dev/null 2>&1; then
    log "Installing Go (needed to build worktime)"
    sudo apt install -y golang-go
  fi
  if command -v go >/dev/null 2>&1; then
    log "Building worktime (wt)"
    WORKTIME_SRC="$(mktemp -d)"
    git clone https://github.com/TheSyscall/worktime "$WORKTIME_SRC"
    (cd "$WORKTIME_SRC" && go build -o "$HOME/.local/bin/wt" .)
    rm -rf "$WORKTIME_SRC"
    chmod +x "$HOME/.local/bin/wt"
  else
    log "No Go toolchain available, skipping worktime build — install manually: https://github.com/TheSyscall/worktime"
  fi
fi

# ---------------------------------------------------------------------------
# 3. Symlink dotfiles into place
# ---------------------------------------------------------------------------
link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${dest#"$HOME"/}")"
    log "Backing up existing $dest -> $BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/${dest#"$HOME"/}"
  fi
  ln -s "$src" "$dest"
  log "Linked $dest -> $src"
}

link "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
link "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES_DIR"/bin/*; do
  link "$script" "$HOME/.local/bin/$(basename "$script")"
done

for entry in "$DOTFILES_DIR"/.config/*; do
  name="$(basename "$entry")"
  # opencode.jsonc holds a secret placeholder: copy once instead of symlinking
  # so a locally-filled-in API key never lands back in this git repo.
  if [ "$name" = "opencode" ]; then
    mkdir -p "$HOME/.config/opencode"
    for f in "$entry"/*; do
      target="$HOME/.config/opencode/$(basename "$f")"
      [ -e "$target" ] || cp "$f" "$target"
    done
    continue
  fi
  # gh keeps a local, untracked hosts.yml (auth token) alongside config.yml.
  # Symlink only what's tracked so hosts.yml is never displaced.
  if [ "$name" = "gh" ]; then
    mkdir -p "$HOME/.config/gh"
    for f in "$entry"/*; do
      link "$f" "$HOME/.config/gh/$(basename "$f")"
    done
    continue
  fi
  # systemd user units: the rest of ~/.config/systemd/user is package-managed
  # symlinks (pipewire, wireplumber, gnome-keyring...) recreated by their own
  # packages — only link the units we actually author ourselves.
  if [ "$name" = "systemd" ]; then
    mkdir -p "$HOME/.config/systemd/user"
    for f in "$entry"/user/*; do
      link "$f" "$HOME/.config/systemd/user/$(basename "$f")"
    done
    continue
  fi
  link "$entry" "$HOME/.config/$name"
done

if systemctl --user status >/dev/null 2>&1; then
  log "Enabling airstatus + bt-battery-daemon user services"
  systemctl --user daemon-reload
  systemctl --user enable --now airstatus.service bt-battery-daemon.service
else
  log "No systemd user session available — enable airstatus/bt-battery-daemon manually later:"
  log "  systemctl --user enable --now airstatus.service bt-battery-daemon.service"
fi

log "Done. Start a new shell, then inside tmux press prefix+I to fetch plugins."
log "Set NWS_AI_API_KEY in your environment (or edit ~/.config/opencode/opencode.jsonc) for opencode's NWS provider."
