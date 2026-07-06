# Dotfiles (chezmoi)

Personal cross-platform (macOS + Linux) bootstrap + dotfiles managed with [chezmoi](https://www.chezmoi.io/).

This repo installs core developer tooling and configures shell/runtime environment using
chezmoi run scripts. On macOS it bootstraps Homebrew and uses it as the package manager;
on Linux it auto-detects `apt`/`dnf`/`yum`/`pacman`/`zypper`/`apk`.

## What this config sets up

- Package manager: Homebrew (installed automatically on macOS)
- System essentials: `curl`, `wget`, `git`
- Zsh + Oh My Zsh, plus custom plugins (`zsh-syntax-highlighting`, `zsh-autosuggestions`, `you-should-use`)
- Docker
- Node tooling (`nvm`, `pnpm`)
- Rust (`rustup`)
- Python (`python3`, `pip3`, plus convenience symlinks)
- CLI/app tooling: `direnv`; Tabby terminal (macOS only)
- Post-apply health check for key commands

## Script layout

Chezmoi executes these scripts by name order. Bootstrap scripts are chezmoi
templates (`.sh.tmpl`); shared shell helpers live in
`.chezmoitemplates/install-helpers.sh` and are inlined into each script at apply
time via `{{ template "install-helpers.sh" . }}`.

### One-time bootstrap scripts

- `run_once_before_00-install-system-packages.sh.tmpl`
- `run_once_before_10-setup-zsh.sh.tmpl`
- `run_once_before_20-install-docker.sh.tmpl`
- `run_once_before_30-install-nvm-pnpm.sh.tmpl`
- `run_once_before_40-install-rust.sh.tmpl`
- `run_once_before_50-install-python.sh.tmpl`
- `run_once_before_60-install-tools.sh.tmpl` (direnv, Tabby)

### Re-run-on-change scripts

- `run_onchange_after_90-healthcheck.sh`

## Usage

### Initial setup

```bash
chezmoi init --apply <your-repo>
```

If already initialized:

```bash
chezmoi apply
```

### Re-run scripts manually

Run a specific script directly:

```bash
bash ~/.local/share/chezmoi/run_onchange_after_90-healthcheck.sh
```

Or ask chezmoi to apply and trigger managed scripts:

```bash
chezmoi apply
```

## Healthcheck behavior

`run_onchange_after_90-healthcheck.sh` validates command availability.

- **Required** (fails script if missing): `curl`, `git`, `zsh`, `python3`
- **Optional** (warn-only): `pip3`, `docker`, `node`, `pnpm`, `rustc`, `cargo`, `direnv`

The script exits non-zero only when required checks fail.

## Notes

- Several installers fetch remote install scripts via `curl`.
- `chsh` (default shell change) may still require user interaction depending on OS/policy; on Linux the zsh path is added to `/etc/shells` first.
- Docker: installed via Docker Desktop cask on macOS, and `get.docker.com` on Linux. Service enablement uses `systemctl` when available (Linux only).
