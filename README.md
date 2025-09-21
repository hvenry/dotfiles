# Dotfiles

This is a dotfiles repo containing my configurations for certain programs. These configurations are kept in sync by using [GNU Stow](https://www.gnu.org/software/stow/), a symlink farm manager that creates symlinks from my dotfile repo to `~/`.

## Important Distinction

This repository manages **configuration files only**, not software installation. You need to:

1. **First**: Install the actual software using your system's package manager
2. **Then**: Use this repository to install/sync the configuration files

For example:
- Install `neovim` using `brew install neovim` (macOS) or `sudo pacman -S neovim` (Arch)
- Then use this repo to install the Neovim configuration files

## Quick Start with Profiles

This repository includes profile-based installation for common setups:

```bash
# Clone the repository
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles

# Install a complete profile (configs only - see software installation below)
./scripts/install-profile.sh macos           # macOS development setup
./scripts/install-profile.sh arch-hyprland   # Arch Linux + Hyprland desktop
./scripts/install-profile.sh server          # Minimal server setup
```

## Available Profiles

- **`macos`**: Core development environment for macOS (zsh, nvim, tmux, ghostty, vscode)
- **`arch-hyprland`**: Full Wayland desktop with Hyprland (includes all desktop components)
- **`server`**: Minimal headless server setup (zsh, nvim, tmux)

## Software Installation (Required First)

**You must install the actual software before using the configuration files.**

### macOS Setup

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

# VS Code (optional, for macOS profile)
brew install --cask visual-studio-code
```

Install Tmux Plugin Manager (TPM) for tmux themes and plugins:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Arch Linux Setup

Install required packages:

```bash
# Core packages
sudo pacman -S git stow tmux fzf neovim ghostty

# VS Code (optional, for desktop setups)
yay -S visual-studio-code-bin
# OR from official repos:
sudo pacman -S code

# For Hyprland desktop environment (if using arch-hyprland profile):
sudo pacman -S hyprland waybar wofi eww mako swww sddm
```

Install Tmux Plugin Manager (TPM) for tmux themes and plugins:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Configuration Installation

**After installing the software above**, clone this repository and install configurations:

Clone this repository to your home directory:

```bash
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles
```

### Option 1: Profile-Based Installation (Recommended)

Use the profile installer to automatically install configurations for your environment:

```bash
# Choose one based on your system:
./scripts/install-profile.sh macos           # macOS development setup
./scripts/install-profile.sh arch-hyprland   # Arch Linux + Hyprland desktop  
./scripts/install-profile.sh server          # Minimal server setup

# Clean install (removes existing configs first):
./scripts/install-profile.sh --clean macos

# See all available profiles and options:
./scripts/install-profile.sh
```

**Profile Options:**
- **No flags**: Keeps existing configurations, may cause conflicts
- **`--clean`**: Removes existing configurations before installing (recommended)

### Option 2: Manual Installation

**IMPORTANT**: Remove any existing configurations before stowing to avoid conflicts:

```bash
# Remove existing configs if they exist
rm -rf ~/.config/nvim
rm -rf ~/.config/tmux
rm -rf ~/.config/ghostty
rm -f ~/.zshrc ~/.p10k.zsh

# Remove VS Code configs (cross-platform)
# macOS:
rm -rf ~/Library/Application\ Support/Code/User
# Linux:
rm -rf ~/.config/Code/User
```

#### Stow Individual Packages (Sync Configurations)

You can install specific configurations using stow:

```bash
# Install Zsh configuration
stow -t ~ zsh

# Install VS Code configuration (cross-platform)
stow -t ~ vscode

# Install Neovim configuration
stow -t ~ nvim

# Install Ghostty terminal configuration  
stow -t ~ ghostty

# Install Tmux configuration
stow -t ~ tmux

# Install all configurations at once
stow -t ~ .
```

## What Each Profile Installs

### macOS Profile
- **zsh**: Shell configuration with Oh My Zsh and Powerlevel10k
- **nvim**: Neovim configuration  
- **tmux**: Terminal multiplexer configuration
- **ghostty**: Terminal emulator configuration
- **vscode**: VS Code settings and keybindings

### Arch Hyprland Profile  
- **Core tools**: zsh, nvim, tmux, ghostty
- **Desktop environment**: hyprland, waybar, wofi, eww, mako, swww, sddm

**Note**: Only packages with existing configuration folders will be installed. Missing packages are skipped with warnings.

### Server Profile
- **zsh**: Shell configuration
- **nvim**: Neovim configuration
- **tmux**: Terminal multiplexer configuration

## Platform-Specific Notes

### VS Code (Cross-Platform)

The `vscode` package contains VS Code configuration files that work across platforms:
- **macOS**: `~/Library/Application Support/Code/User/`
- **Linux**: `~/.config/Code/User/`

The install script automatically detects your OS and uses the correct path.

### Profile Installation Safety

- **Missing packages**: If a profile references packages that don't exist in your dotfiles, they're skipped with warnings
- **Clean mode**: Use `--clean` flag to remove existing configurations before installation
- **Cross-platform**: All scripts work on both macOS and Linux

## Sourcing Configuration Files

After stowing your configurations, source the relevant files to apply changes:

### Zsh

Source the zsh config:
```bash
source ~/.zshrc
```

### Tmux

With an instance of tmux running, source the tmux configuration with:

```bash
tmux source ~/.config/tmux/tmux.conf
```

Then, install the packages with `prefix` + `I` in tmux to install custom plugins.

### Neovim

For neovim, restart nvim or run `:source $MYVIMRC` inside nvim.

### VS Code

Restart VS Code to load new settings (works on both macOS and Linux).

### Ghostty

Simply restart the terminal application.

## Complete Setup Examples

### macOS Setup
```bash
# 1. Install software
brew install git stow tmux fzf neovim
brew install --cask ghostty visual-studio-code

# 2. Install TPM for tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 3. Clone and install dotfiles
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles
./scripts/install-profile.sh --clean macos

# 4. Source configurations
source ~/.zshrc
```

### Arch Linux Setup (Server)
```bash
# 1. Install software
sudo pacman -S git stow tmux fzf neovim

# 2. Install TPM for tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 3. Clone and install dotfiles
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles
./scripts/install-profile.sh --clean server

# 4. Source configurations
source ~/.zshrc
```

### Arch Linux Setup (Hyprland Desktop)
```bash
# 1. Install software
sudo pacman -S git stow tmux fzf neovim ghostty
sudo pacman -S hyprland waybar wofi eww mako swww sddm

# 2. Install TPM for tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 3. Clone and install dotfiles
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles
./scripts/install-profile.sh --clean arch-hyprland

# 4. Source configurations
source ~/.zshrc
```