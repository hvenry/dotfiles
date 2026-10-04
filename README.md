# Dotfiles

My config for macOS, Arch + Hyprland and headless servers, symlinked into `~` with GNU Stow.

## Features

- One command sets up a new machine and re-syncs an existing one
- Profiles for macOS, an Arch + Hyprland desktop, and headless servers
- Bootstrap scripts install the apps too: Homebrew on macOS, pacman and AUR on Arch
- Per-machine monitor setup for Hyprland, seeded automatically from tracked templates
- Claude Code settings and plugins sync everywhere, with personal plugins kept off work machines
- One set of global instructions shared by Claude Code, Codex and opencode

## Quick start

```bash
git clone git@github.com:hvenry/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install-profile.sh --clean macos    # or arch-hyprland, or server
```

On a fresh machine, run `./macos/bootstrap/brew-install.sh` or `./linux/bootstrap/arch-install.sh` instead to install the apps as well.

## Docs

- [Install profiles](docs/install-profiles.md) - what each profile installs and how to update a machine
- [Stow layout](docs/stow-layout.md) - how packages map into `~` and how to add one
- [macOS setup](docs/macos-setup.md) - Homebrew bootstrap, AeroSpace and Rectangle
- [Arch setup](docs/arch-setup.md) - automated Arch install and post-install steps
- [Hyprland desktop](docs/hyprland-desktop.md) - Wayland desktop and per-machine monitor config
