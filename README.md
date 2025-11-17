# Dotfiles

This is a dotfiles repo containing my configurations for certain programs. These configurations are kept in sync by using [GNU Stow](https://www.gnu.org/software/stow/), a symlink farm manager that creates symlinks from my dotfile repo to `~/`.

### Quick Start with Profiles

This repository includes profile-based installation for common setups:

```bash
# Clone the repository
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles

# Install a complete profile
./install-profile.sh <profile_name>
```

#### Available Profiles

- **`macos`**: Core development environment for macOS (zsh, nvim, tmux, ghostty, vscode).
- **`arch-hyprland`**: Full Wayland desktop with Hyprland (includes all desktop components).
- **`server`**: Minimal headless server setup (zsh, nvim, tmux).

#### Additional Notes

- **Missing packages**: If a profile references packages that don't exist in your dotfiles, they're skipped with warnings.
- **Clean mode**: Use `--clean` flag to remove existing configurations before installation.
- **Cross-platform**: All scripts work on both macOS and Linux.

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
```

Install Tmux Plugin Manager (TPM) for tmux themes and plugins:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Good to go!

## Arch Linux Setup

For a fresh Arch system, the automated bootstrap installer handles everything:

```bash
# Clone the repository
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles

# Run the complete setup (requires sudo)
sudo ./bootstrap/arch-install.sh
```

This comprehensive script will:

- Install all core system packages from `bootstrap/pacman.txt`
- Install yay (AUR helper) if not present
- Install all AUR packages from `bootstrap/aur.txt`
- Set up Ly as the primary display manager
- Create symlinks for all dotfiles configurations
- Run post-install setup script to finalize configuration

### Configure Display Manager\*\*

```bash
# Set Ly as primary display manager
sudo systemctl disable sddm
sudo systemctl enable ly
```

### Run Post-Install Setup\*\*

```bash
# This handles additional configuration
bash bootstrap/post-install.sh
```

The post-install script:

- Installs Tmux Plugin Manager (TPM)
- Sources your zsh configuration
- Enables Ly display manager
- Installs global npm packages (neovim)
- Sets up Python environment
- Provides next steps guidance

### Configure Hyprland and Waybar (REQUIRED)

These steps are required before your first boot to avoid errors:

#### 1. Hyprland Monitor Configuration

Create `~/.config/hypr/local.conf` with your monitor settings:

```bash
# Option A: Copy a preset configuration
cp ~/.config/hypr/machines/laptop.conf ~/.config/hypr/local.conf
# OR
cp ~/.config/hypr/machines/desktop.conf ~/.config/hypr/local.conf

# Option B: Create a custom configuration
# See ~/.config/hypr/machines/*.conf for examples
```

#### 2. Waybar Monitor Configuration

Configure the status bar for your primary monitor:

```bash
# Copy the example configuration
cp ~/.config/waybar/.local.example ~/.config/waybar/.local

# Edit to set your primary monitor
# Example: PRIMARY_MONITOR=DP-4 or PRIMARY_MONITOR=eDP-1
# Run 'hyprctl monitors' after first boot to see available monitors
```

**Note**: The post-install script will warn you if these configurations are missing.

## Platform-Specific Notes

### VS Code (Cross-Platform)

The `vscode` package contains VS Code configuration files that work across platforms:

- **macOS**: `~/Library/Application Support/Code/User/`
- **Linux**: `~/.config/Code/User/`

The install script automatically detects your OS and uses the correct path.

## Post Installation

After your installation completes, these are the immediate next steps:

### 1. Source Your Shell

```bash
source ~/.zshrc
```

### 2. Set Up Tmux Plugins (if using tmux)

```bash
# Start a new tmux session
tmux new-session -s main

# Inside tmux, press Ctrl+b (or your prefix) then I to install plugins
# The TPM script should have been installed by post-install.sh
```

### 3. Configure Neovim

- Launch neovim: `nvim`
- On first launch, run `:Mason` to install language servers
- LSP servers will auto-install on first file type detection

## Refrences

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Ghostty](https://ghostty.org/)
- [neovim](https://neovim.io/)
- [tmux](https://github.com/tmux/tmux/wiki)
- [tpm](https://github.com/tmux-plugins/tpm)

Arch Specific:

- [Pacman](https://wiki.archlinux.org/title/Pacman)
- [Hyprland](https://wiki.hypr.land/)
- [Rofi](https://github.com/davatorium/rofi)
- [Waybar](https://github.com/Alexays/Waybar)
- [Ly](https://github.com/fairyglade/ly)
- [systemd](https://github.com/systemd/systemd)
