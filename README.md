# Dotfiles

This is a dotfiles repo containing my configurations for certain programs, these configurations are kept in sync by using [GNU Stow](https://www.gnu.org/software/stow/), a symlink farm manager that creates symlinks from my dotfile repo to `~/`.


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
```

Install Tmux Plugin Manager (TPM) for tmux themes and plugins:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Download and install [Ghostty terminal](https://ghostty.org/) from their official website.

## Arch Setup

Install required packages:

```bash
sudo pacman -S git stow tmux fzf neovim ghostty
```

Install Tmux Plugin Manager (TPM) for tmux themes and plugins:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Installation

Clone this repository to your home directory:

```bash
cd ~
git clone git@github.com:hvenry/dotfiles.git
cd dotfiles
```

**IMPORTANT**: Remove any existing configurations before stowing to avoid conflicts:

```bash
# Remove existing configs if they exist
rm -rf ~/.config/nvim
rm -rf ~/.config/tmux
rm -rf ~/.config/ghostty
rm -f ~/.zshrc ~/.p10k.zsh
# For macOS users only - remove existing VS Code config
rm -rf ~/Library/Application\ Support/Code/User
```

## Stow Individual Packages (Configurations)

You can install specific configurations using stow:

```bash
# Install Zsh configuration
stow -t ~ zsh

# Install VS Code configuration (macOS path only)
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

## Platform-Specific Notes

### VS Code (macOS only)

The `vscode` package contains VS Code configuration files that work with macOS's default VS Code configuration location (`~/Library/Application Support/Code/User/`). After stowing with `stow -t ~ vscode`, VS Code will automatically use your dotfiles configuration.

## Additional Setup

Install tmux styling dependencies from [tokyo-night-tmux](https://github.com/janoamaral/tokyo-night-tmux).

## Sourcing Configuration Files

After stowing your configurations, source the relevant files to apply changes:

```bash
# Source zsh configuration
source ~/.zshrc

# Source tmux configuration (if tmux is running)
tmux source ~/.config/tmux/tmux.conf

# For VS Code (macOS), restart VS Code to load new settings

# For neovim, restart nvim or run :source $MYVIMRC inside nvim

# For ghostty, restart the terminal application
```

**Note**: Some configurations may require restarting the application to take full effect.
