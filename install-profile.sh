#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_DIR="$DOTFILES_DIR/profiles"

# Function to remove existing configurations
remove_existing_configs() {
  local packages="$1"
  echo "Checking for existing configurations to remove..."
  echo ""

  for package in $packages; do
    case "$package" in
    "zsh")
      if [ -f ~/.zshrc ] || [ -L ~/.zshrc ] || [ -f ~/.p10k.zsh ] || [ -L ~/.p10k.zsh ]; then
        echo "Removing existing zsh configs..."
        rm -f ~/.zshrc ~/.p10k.zsh
      fi
      ;;
    "nvim")
      if [ -d ~/.config/nvim ]; then
        echo "Removing existing nvim config..."
        rm -rf ~/.config/nvim
      fi
      ;;
    "tmux")
      if [ -d ~/.config/tmux ] || [ -f ~/.tmux.conf ] || [ -L ~/.tmux.conf ]; then
        echo "Removing existing tmux configs..."
        rm -rf ~/.config/tmux ~/.tmux.conf
      fi
      ;;
    "ghostty")
      if [ -d ~/.config/ghostty ]; then
        echo "Removing existing ghostty config..."
        rm -rf ~/.config/ghostty
      fi
      ;;
    "vscode")
      # Cross-platform VS Code config removal
      if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if [ -d ~/Library/Application\ Support/Code/User ]; then
          echo "Removing existing VS Code config (macOS)..."
          rm -rf ~/Library/Application\ Support/Code/User
        fi
      elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if [ -d ~/.config/Code/User ]; then
          echo "Removing existing VS Code config (Linux)..."
          rm -rf ~/.config/Code/User
        fi
      else
        echo "Warning: Unknown OS type for VS Code config removal"
      fi
      ;;
    "aerospace")
      if [ -f ~/.aerospace.toml ] || [ -L ~/.aerospace.toml ]; then
        echo "Removing existing aerospace config..."
        rm -f ~/.aerospace.toml
      fi
      ;;
    "rectangle")
      if [ -d ~/.config/rectangle ]; then
        echo "Removing existing rectangle config..."
        rm -rf ~/.config/rectangle
      fi
      ;;
    "herdr")
      # Only the config file — herdr keeps logs/state in the same directory
      if [ -f ~/.config/herdr/config.toml ] || [ -L ~/.config/herdr/config.toml ]; then
        echo "Removing existing herdr config..."
        rm -f ~/.config/herdr/config.toml
      fi
      ;;
    "hyprland")
      if [ -d ~/.config/hypr ]; then
        echo "Removing existing hyprland config..."
        rm -rf ~/.config/hypr
      fi
      ;;
    "waybar")
      if [ -d ~/.config/waybar ]; then
        echo "Removing existing waybar config..."
        rm -rf ~/.config/waybar
      fi
      ;;
    "hyprlock")
      if [ -d ~/.config/hypr ] && [ -f ~/.config/hypr/hyprlock.conf ]; then
        echo "Removing existing hyprlock config..."
        rm -f ~/.config/hypr/hyprlock.conf
      fi
      ;;
    "rofi")
      if [ -d ~/.config/rofi ]; then
        echo "Removing existing rofi config..."
        rm -rf ~/.config/rofi
      fi
      if [ -d ~/.local/share/applications ]; then
        echo "Removing dangling launcher symlinks..."
        find ~/.local/share/applications -maxdepth 1 -xtype l -delete
      fi
      ;;
    "mako")
      if [ -d ~/.config/mako ]; then
        echo "Removing existing mako config..."
        rm -rf ~/.config/mako
      fi
      ;;
    "scripts")
      if [ -d ~/.config/scripts ]; then
        echo "Removing existing scripts config..."
        rm -rf ~/.config/scripts
      fi
      ;;
    "systemd")
      if [ -d ~/.config/systemd ]; then
        echo "Removing existing systemd user config..."
        rm -rf ~/.config/systemd
      fi
      ;;
    "gtk")
      if [ -d ~/.config/gtk-3.0 ] || [ -d ~/.config/gtk-4.0 ] || [ -f ~/.gtkrc-2.0 ] || [ -L ~/.gtkrc-2.0 ]; then
        echo "Removing existing GTK configs..."
        rm -rf ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.gtkrc-2.0
      fi
      ;;
    "xsettingsd")
      if [ -d ~/.config/xsettingsd ]; then
        echo "Removing existing xsettingsd config..."
        rm -rf ~/.config/xsettingsd
      fi
      ;;
    "environment")
      if [ -d ~/.config/environment.d ]; then
        echo "Removing existing environment.d config..."
        rm -rf ~/.config/environment.d
      fi
      ;;
    "xdg")
      if [ -f ~/.config/mimeapps.list ] || [ -L ~/.config/mimeapps.list ]; then
        echo "Removing existing mimeapps.list..."
        rm -f ~/.config/mimeapps.list
      fi
      ;;
    "wlogout")
      if [ -d ~/.config/wlogout ]; then
        echo "Removing existing wlogout config..."
        rm -rf ~/.config/wlogout
      fi
      ;;
    "backgrounds")
      if [ -d ~/.config/backgrounds ]; then
        echo "Removing existing backgrounds..."
        rm -rf ~/.config/backgrounds
      fi
      ;;
    "ly")
      if [ -L ~/config.ini ]; then
        echo "Removing stale ly symlink at ~/config.ini..."
        rm -f ~/config.ini
      fi
      echo "Note: Ly is a display manager and may require special handling"
      echo "Skipping automatic removal for ly - please handle manually if needed"
      ;;
    esac
  done
  echo ""
}

show_usage() {
  echo "Usage: $0 [--clean] <profile-name>"
  echo ""
  echo "Options:"
  echo "  --clean    Remove existing configurations before installing"
  echo ""
  echo "Available profiles:"
  for profile in "$PROFILES_DIR"/*.txt; do
    if [ -f "$profile" ]; then
      basename "$profile" .txt | sed 's/^/  /'
    fi
  done
  echo ""
  echo "Examples:"
  echo "  $0 macos              # Install macOS profile (keep existing configs)"
  echo "  $0 --clean macos      # Remove existing configs, then install macOS profile"
  echo "  $0 arch-hyprland      # Install Arch Linux + Hyprland profile"
  echo "  $0 server             # Install server profile"
}

if [ $# -eq 0 ]; then
  show_usage
  exit 1
fi

# Parse arguments
CLEAN_MODE=false
PROFILE_NAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
  --clean)
    CLEAN_MODE=true
    shift
    ;;
  -*)
    echo "Error: Unknown option $1"
    echo ""
    show_usage
    exit 1
    ;;
  *)
    if [ -z "$PROFILE_NAME" ]; then
      PROFILE_NAME="$1"
    else
      echo "Error: Multiple profile names provided"
      echo ""
      show_usage
      exit 1
    fi
    shift
    ;;
  esac
done

if [ -z "$PROFILE_NAME" ]; then
  echo "Error: No profile name provided"
  echo ""
  show_usage
  exit 1
fi

PROFILE_FILE="$PROFILES_DIR/$PROFILE_NAME.txt"

if [ ! -f "$PROFILE_FILE" ]; then
  echo "Error: Profile '$PROFILE_NAME' not found!"
  echo ""
  show_usage
  exit 1
fi

echo "Installing profile: $PROFILE_NAME"
echo "Profile file: $PROFILE_FILE"
echo ""

# Extract packages from profile file (ignore comments and empty lines)
PACKAGES=$(grep -v '^#' "$PROFILE_FILE" | grep -v '^$' | tr '\n' ' ')

if [ -z "$PACKAGES" ]; then
  echo "Error: No packages found in profile!"
  exit 1
fi

echo "Packages to install: $PACKAGES"
echo ""

# Remove existing configurations if --clean flag is used
if [ "$CLEAN_MODE" = true ]; then
  echo "🧹 Clean mode enabled - removing existing configurations..."
  remove_existing_configs "$PACKAGES"
fi

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# Verify stow is available
if ! command -v stow >/dev/null 2>&1; then
  echo "Error: stow is not installed"
  echo "Install with: sudo pacman -S stow (Arch) or apt-get install stow (Debian/Ubuntu)"
  exit 1
fi

# Install packages using stow
# Note: stow reads .stowrc from the current directory (sets --target=~ etc.)
echo "Installing packages using stow (reading .stowrc for options)..."
echo ""

# Each package lives under exactly one platform directory; first hit wins.
PLATFORM_DIRS="shared macos linux"

for package in $PACKAGES; do
  package_dir=""
  for dir in $PLATFORM_DIRS; do
    if [ -d "$dir/$package" ]; then
      package_dir="$dir"
      break
    fi
  done

  if [ -n "$package_dir" ]; then
    echo "Installing package: $package (from $package_dir/)"
    stow -d "$package_dir" "$package"
  else
    echo "Warning: Package '$package' not found in shared/, macos/, or linux/, skipping..."
  fi
done

echo ""
echo "Profile '$PROFILE_NAME' installed successfully!"
echo ""

# Check if this is an Arch system with Hyprland profile
if [[ "$PROFILE_NAME" == "arch-hyprland" ]]; then
  echo "Next steps for Arch + Hyprland:"
  echo "1. Reload Hyprland configuration: hyprctl reload"
  echo ""
  echo "If you haven't installed packages yet, run:"
  echo "   sudo bash $DOTFILES_DIR/linux/bootstrap/arch-install.sh"
else
  echo "Next steps:"
  echo "1. Source your shell config: source ~/.zshrc"
  echo "2. Restart your terminal or shell to load changes"
fi

echo ""
echo "For Tmux users:"
echo "  - Start tmux: tmux new-session -s main"
echo "  - Press prefix + I to install plugins (default: Ctrl+Space + I)"
echo ""
echo "For more details, see: $DOTFILES_DIR/README.md"
