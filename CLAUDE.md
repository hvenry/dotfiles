# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a modular dotfiles repository that uses GNU Stow for symlink-based configuration management. Each application has its own directory containing a `.config` subdirectory that mirrors the target structure in `~/.config/`.

## Architecture

### Stow-Based Package System

- Each top-level directory (e.g., `nvim/`, `tmux/`, `zsh/`) is a "stow package"
- Packages contain `.config` directories that mirror the target filesystem structure
- Running `stow package-name` creates symlinks from the repo to `~/`
- The `.stowrc` file configures stow with `--no-folding`, `--verbose`, and `--restow` flags

### Profile-Based Installation

- Pre-defined profiles in `profiles/` directory specify package combinations
- `macos.txt`: Core development environment (zsh, nvim, tmux, ghostty, vscode)
- `arch-hyprland.txt`: Full Wayland desktop with Hyprland window manager
- `server.txt`: Minimal headless setup (zsh, nvim, tmux)

## Common Commands

### Installation and Management

```bash
# Automated Arch Linux setup (packages + dotfiles)
./bootstrap/arch-install.sh                  # Complete Arch + Hyprland setup

# Install dotfiles profiles (configs only)
./install-profile.sh --clean macos           # macOS development setup
./install-profile.sh --clean arch-hyprland   # Arch Linux + Hyprland desktop
./install-profile.sh --clean server          # Minimal server setup

# Install individual packages
stow nvim                    # Install Neovim configuration
stow tmux                    # Install Tmux configuration
stow -D nvim                 # Remove Neovim configuration symlinks
```

### Configuration Sourcing

```bash
source ~/.zshrc
tmux source ~/.config/tmux/tmux.conf
```

## Important Notes

### Cross-Platform VS Code Handling

The `vscode` package automatically detects OS and targets the correct path:

- macOS: `~/Library/Application Support/Code/User/`
- Linux: `~/.config/Code/User/`

### Clean Installation

Always use `--clean` flag with profile installation to avoid symlink conflicts:

```bash
./install-profile.sh --clean profile-name
```

### Package Structure

Each package follows this structure:

```
package-name/
└── .config/
    └── package-name/
        └── [configuration files]
```

When modifying configurations, edit files in the repository, not the symlinked versions in `~/.config/`.

## Bootstrap System (Arch Linux)

### Automated Package Installation

The `bootstrap/` directory contains automated installation for Arch Linux:

- `bootstrap/arch-install.sh` - Complete system setup script
- `bootstrap/pacman.txt` - Core system packages (Hyprland, audio, networking, etc.)
- `bootstrap/aur.txt` - AUR packages (ghostty, fonts, development tools)

### Bootstrap Usage

```bash
# Complete Arch + Hyprland setup (fresh install)
./bootstrap/arch-install.sh

# The script will:
# 1. Install packages from pacman.txt and aur.txt
# 2. Set up system services (SDDM, PipeWire)
# 3. Configure NVIDIA if detected
# 4. Apply the arch-hyprland dotfiles profile
```

