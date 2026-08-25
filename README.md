# dotfiles

Personal Linux (sway/Debian) dotfiles. Unifies what used to be split across
two repos (`.config` and `dotfiles`).

## Fresh machine setup

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rogalik27/dotfiles/main/install.sh)"
```

This clones the repo to `~/dotfiles`, installs the apt packages this config
depends on, installs atuin/gh/lazygit/tpm if missing, and symlinks everything
into place. Anything already present at a target path is moved into
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
- The [`worktime`](https://github.com/TheSyscall/worktime) CLI (`wt`) is a
  separate project/repo and isn't vendored here — build/install it on its
  own.
- Secrets, credentials, machine-specific caches (`.docker/`, browser
  profiles, `gh/hosts.yml`, shell history, `dconf`, certs, etc.) are
  intentionally excluded.
