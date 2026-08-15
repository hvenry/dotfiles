# Dotfiles

My configurations, managed with [GNU Stow](https://www.gnu.org/software/stow/) and organized by platform. Stow creates symlinks from this repo into `~/`.

## Repository Structure

Every stow package lives under exactly one platform directory:

```
dotfiles/
├── shared/              # Used on every machine
│   ├── zsh/  nvim/  tmux/  ghostty/  vscode/
├── macos/               # macOS only
│   └── aerospace/
├── linux/               # Arch Linux + Hyprland desktop
│   ├── bootstrap/       # Automated Arch installer (packages + services)
│   ├── hyprland/  waybar/  rofi/  mako/  wlogout/
│   ├── gtk/  xsettingsd/  xdg/  ly/  systemd/
│   └── scripts/  backgrounds/
├── profiles/            # Package lists for common setups
├── install-profile.sh   # Profile installer
└── .stowrc              # Stow defaults (--target=~, --restow, --no-folding)
```

## Quick Start

```bash
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles

# Install a complete profile (--clean removes existing configs first)
./install-profile.sh --clean <profile-name>
```

### Profiles

- **`macos`**: Core development environment (zsh, nvim, tmux, ghostty, vscode, aerospace)
- **`arch-hyprland`**: Full Wayland desktop (shared tools + Hyprland, Waybar, Rofi, and friends)
- **`server`**: Minimal headless setup (zsh, nvim, tmux)

The installer resolves each package name by searching `shared/`, `macos/`, then `linux/`. Packages that can't be found are skipped with a warning.

### Upgrading from the flat layout

On a machine that last installed the old flat layout, run `./install-profile.sh --clean <profile-name>` once — `--clean` also removes the old layout's now-dangling symlinks. If stow still reports `existing target is not owned by stow`, delete the path it names and re-run.

## Installing Individual Packages

Run stow from the repo root, pointing `-d` at the platform directory:

```bash
stow -d shared nvim         # install one package
stow -d macos aerospace
stow -D -d shared nvim      # remove a package's symlinks
```

`.stowrc` sets the target to `~`, so this works from the repo root for any platform directory.

## macOS Setup

First, install [Homebrew](https://brew.sh/) (if not already installed):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install essential tools and dependencies:

```bash
# Install git and stow for dotfiles management
brew install git stow

# Install core applications
brew install tmux fzf neovim

# Terminal emulator
brew install --cask ghostty

# Window management (workspaces + snapping)
brew install --cask nikitabobko/tap/aerospace
brew install --cask rectangle
```

Install Tmux Plugin Manager (TPM) for tmux themes and plugins:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

Then install the profile:

```bash
./install-profile.sh --clean macos
```

Good to go!

## Arch Linux Setup

For a fresh Arch system, the automated bootstrap installer handles everything:

```bash
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles

# Run the complete setup (requires sudo)
sudo ./linux/bootstrap/arch-install.sh
```

This script will:

- Install all core system packages from `linux/bootstrap/pacman.txt`
- Install yay (AUR helper) if not present
- Install all AUR packages from `linux/bootstrap/aur.txt`
- Set up Ly as the primary display manager
- Create symlinks for all dotfiles configurations
- Run the post-install script to finalize configuration

### Post-Install Setup

```bash
bash linux/bootstrap/post-install.sh
```

The post-install script installs TPM, sources zsh, enables the Ly display manager and systemd timers, installs global npm packages, and prints next steps.

### Configure Hyprland and Waybar (REQUIRED)

These steps are required before your first boot to avoid errors:

```bash
# 1. Hyprland monitor configuration
cp ~/.config/hypr/machines/laptop.conf ~/.config/hypr/local.conf   # or desktop.conf

# 2. Waybar primary monitor
cp ~/.config/waybar/.local.example ~/.config/waybar/.local
# Edit ~/.config/waybar/.local and set PRIMARY_MONITOR (run 'hyprctl monitors' after first boot)
```

The post-install script warns you if these are missing.

## Platform-Specific Notes

### VS Code

The `shared/vscode` package stows settings to `~/.config/Code/User/` on every platform — VS Code's native location on Linux. On macOS, VS Code reads `~/Library/Application Support/Code/User/`, which this repo does not currently wire up.

### Rectangle (macOS)

Rectangle can't read its config live from a dotfile (its source of truth is a macOS preferences plist), so `macos/rectangle` versions a **snapshot**: `RectangleConfig.json`, symlinked to `~/.config/rectangle/`.

- **After changing bindings**: Rectangle Settings → Export, save over `macos/rectangle/.config/rectangle/RectangleConfig.json` (the repo file, not the symlink), then commit.
- **On a new machine**: Rectangle Settings → Import, pick that file.

## Post Installation

```bash
# 1. Source your shell
source ~/.zshrc

# 2. Tmux plugins: start tmux, then press prefix + I
tmux new-session -s main

# 3. Neovim: launch nvim, run :Mason for language servers
```

## References

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Ghostty](https://ghostty.org/)
- [neovim](https://neovim.io/)
- [tmux](https://github.com/tmux/tmux/wiki)
- [tpm](https://github.com/tmux-plugins/tpm)
- [AeroSpace](https://github.com/nikitabobko/AeroSpace)

Arch specific:

- [Pacman](https://wiki.archlinux.org/title/Pacman)
- [Hyprland](https://wiki.hypr.land/)
- [Rofi](https://github.com/davatorium/rofi)
- [Waybar](https://github.com/Alexays/Waybar)
- [Ly](https://github.com/fairyglade/ly)
- [systemd](https://github.com/systemd/systemd)
