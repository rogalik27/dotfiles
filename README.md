# dotfiles

Personal Linux (sway/Debian) dotfiles. Unifies what used to be split across
two repos (`.config` and `dotfiles`).

## Fresh machine setup

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rogalik27/dotfiles/main/install.sh)"
```

This clones the repo to `~/dotfiles`, installs the apt packages this config
depends on, installs atuin/gh/lazygit/tpm if missing, builds the `wt`
(worktime) CLI from source, and symlinks everything into place. Anything
already present at a target path is moved into
`~/.dotfiles-backup-<timestamp>/` first, not overwritten.

Re-running `install.sh` is safe — it only backs up files that aren't already
the expected symlink.

## Layout

- `.bashrc`, `.bash_aliases`, `.tmux.conf` — shell
- `.config/` — sway, waybar, mako, rofi, swaync, i3, alacritty, kitty,
  lazygit, nvim, fish, nushell, htop, mc, atuin, gh, git, opencode,
  libinput-gestures
- `bin/` — small wrapper scripts (swayfx-session, swaysettings,
  sway-wallpaper, stickynotes, wifi-hotspot-toggle.sh), symlinked
  individually into `~/.local/bin`

## Notes

- tmux plugins are managed by [TPM](https://github.com/tmux-plugins/tpm),
  not vendored here. `install.sh` clones TPM; press `prefix+I` inside tmux
  once to fetch the plugins listed in `.tmux.conf`.
- `.config/opencode/opencode.jsonc` is installed by **copy**, not symlink,
  and only if it doesn't already exist locally — so a real API key you fill
  in later never gets written back into this repo. Set the `NWS_AI_API_KEY`
  env var for the NWS provider, or edit the file directly after install.
- The [`worktime`](https://github.com/TheSyscall/worktime) CLI is a separate
  project/repo, not vendored here. `install.sh` clones it into a temp dir,
  runs `go build`, and installs the resulting binary as `~/.local/bin/wt`
  (installing `golang-go` via apt first if needed).
- `wayfreeze` isn't packaged for Debian — `install.sh` installs a Rust
  toolchain via rustup if needed and `cargo install`s it.
- [AirStatus](https://github.com/delphiki/AirStatus) (AirPods battery reader)
  is cloned by `install.sh` into `~/.local/share/AirStatus`, same pattern as
  worktime — separate upstream project, not vendored.
- `.config/systemd/user/` only tracks the two units we actually author
  (`airstatus.service`, `bt-battery-daemon.service`). Everything else under
  `~/.config/systemd/user` on this machine is a symlink created by other
  packages (pipewire, wireplumber, gnome-keyring) and gets recreated
  automatically when those packages are installed/enabled.
- Secrets, credentials, machine-specific caches (`.docker/`, browser
  profiles, `gh/hosts.yml`, shell history, `dconf`, certs, etc.) are
  intentionally excluded.
