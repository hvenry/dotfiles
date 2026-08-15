# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a modular dotfiles repository that uses GNU Stow for symlink-based configuration management, organized by platform. Each application is a stow package living under exactly one platform directory.

## Architecture

### Platform Directories

- `shared/` — packages used on every machine: zsh, nvim, tmux, ghostty, vscode
- `macos/` — macOS-only packages: aerospace, rectangle (a config *snapshot* — Rectangle reads a plist, not the dotfile; sync is via the app's Export/Import)
- `linux/` — Arch Linux + Hyprland desktop packages (hyprland, waybar, rofi, mako, wlogout, gtk, xsettingsd, xdg, ly, systemd, scripts, backgrounds) plus `linux/bootstrap/` (automated Arch installer)

### Stow-Based Package System

- Packages contain `.config` directories that mirror the target structure in `~/.config/` (or top-level dotfiles like `zsh/.zshrc`, `aerospace/.aerospace.toml`)
- `.stowrc` configures stow with `--no-folding`, `--verbose`, `--restow`, and `--target=~` — the target flag is required because packages live in subdirectories
- Install a package from the repo root with `stow -d <platform-dir> <package>`

### Profile-Based Installation

- Profiles in `profiles/` list package names (no platform prefix); `install-profile.sh` resolves each name by searching `shared/`, `macos/`, then `linux/`
- `macos.txt`: zsh, nvim, tmux, ghostty, vscode, aerospace, rectangle
- `arch-hyprland.txt`: full Wayland desktop with Hyprland
- `server.txt`: minimal headless setup (zsh, nvim, tmux)

## Common Commands

```bash
# Install dotfiles profiles (configs only); --clean avoids symlink conflicts
./install-profile.sh --clean macos
./install-profile.sh --clean arch-hyprland
./install-profile.sh --clean server

# Install/remove individual packages (from the repo root)
stow -d shared nvim
stow -d macos aerospace
stow -D -d shared nvim

# Automated Arch Linux setup (packages + dotfiles)
sudo ./linux/bootstrap/arch-install.sh

# Reload configs
source ~/.zshrc
tmux source ~/.config/tmux/tmux.conf
```

## Important Notes

- **Edit files in the repository**, not the symlinked copies in `~` — they are the same files, but repo paths are canonical.
- **VS Code**: `shared/vscode` stows to `~/.config/Code/User/` on every platform (VS Code's native location on Linux; on macOS, VS Code's actual config dir `~/Library/Application Support/Code/User/` is not currently wired up).
- **Package structure**: `<platform-dir>/<package>/.config/<package>/...` for `~/.config` targets, or `<platform-dir>/<package>/<dotfile>` for home-root dotfiles.
- **Bootstrap (Arch)**: `linux/bootstrap/arch-install.sh` installs from `pacman.txt`/`aur.txt`, configures services, then applies the arch-hyprland profile. `quick-setup.sh` is the curl-able entry point; `post-install.sh` finalizes (TPM, Ly, timers).
- Design specs and implementation plans live in `docs/superpowers/`.

