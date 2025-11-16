# Dotfiles

This is a dotfiles repo containing my configurations for certain programs. These configurations are kept in sync by using [GNU Stow](https://www.gnu.org/software/stow/), a symlink farm manager that creates symlinks from my dotfile repo to `~/`.

## Quick Start with Profiles

This repository includes profile-based installation for common setups:

```bash
# Clone the repository
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles

# Install a complete profile
./install-profile.sh <profile_name>
```

### Available Profiles

- **`macos`**: Core development environment for macOS (zsh, nvim, tmux, ghostty, vscode)
- **`arch-hyprland`**: Full Wayland desktop with Hyprland (includes all desktop components)
- **`server`**: Minimal headless server setup (zsh, nvim, tmux)

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

## Arch Linux Setup

### Option 1: Fully Automated Bootstrap (Recommended for Fresh Systems)

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

### Option 2: Step-by-Step Manual Installation

If you prefer more control, follow these steps:

**2a. Install Stow (Dotfiles Manager)**

```bash
sudo pacman -S stow git
```

**2b. Clone the Dotfiles Repository**

```bash
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles
```

**2c. Install Pacman Packages**

```bash
# View all packages that will be installed
cat bootstrap/pacman.txt

# Install them
sudo pacman -Syu --needed --noconfirm $(cat bootstrap/pacman.txt | grep -v '^#' | grep -v '^$' | tr '\n' ' ')
```

The pacman packages include:

- **Core tools**: git, stow, zsh, neovim, tmux
- **Terminal utilities**: less, ripgrep, fd, bat, exa, jq, imagemagick, wget
- **Development environments**: Go, Rust, Ruby, PHP, Node.js, Python, Lua, Julia, JDK
- **Hyprland ecosystem**: hyprland, waybar, rofi, swaync, hyprpaper, hypridle, hyprlock
- **Audio**: pipewire, wireplumber, playerctl
- **System tools**: networkmanager, polkit-kde-agent, brightnessctl, wl-clipboard
- **Display manager**: Ly
- **GUI toolkits**: GTK3/4, Qt6
- **File managers**: Thunar

**2d. Install Yay (AUR Helper)**

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin
makepkg -si --noconfirm
```

**2e. Install AUR Packages**

```bash
# View AUR packages
cat bootstrap/aur.txt

# Install them
yay -S --needed --noconfirm $(cat bootstrap/aur.txt | grep -v '^#' | grep -v '^$' | tr '\n' ' ')
```

The AUR packages include:

- **Terminal**: ghostty
- **Development**: claude-code, visual-studio-code-bin, goimports
- **Fonts and themes**: various fonts, bibata-cursor-theme
- **GUI utilities**: hyprshot

**2f. Clone/Reinstall Dotfiles**

```bash
cd ~/dotfiles

# Install the arch-hyprland profile (creates symlinks)
./install-profile.sh --clean arch-hyprland
```

**2g. Configure Display Manager**

```bash
# Set Ly as primary display manager
sudo systemctl disable sddm
sudo systemctl enable ly
```

**2h. Run Post-Install Setup**

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

### 4. Test Your Desktop (Arch Hyprland)

```bash
# Reboot to apply all settings
sudo reboot

# Log in with Ly
# Hyprland should auto-start
# Test with: Super+Return to open terminal, Super+D to open rofi
```
