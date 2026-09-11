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
        echo "Removing existing tmux configs (keeping plugins/)..."
        # Keep ~/.config/tmux/plugins: TPM and every installed plugin live there.
        # Wiping them means a re-clone of each plugin on every --clean run.
        if [ -d ~/.config/tmux ]; then
          find ~/.config/tmux -mindepth 1 -maxdepth 1 ! -name plugins -exec rm -rf {} + || true
        fi
        rm -f ~/.tmux.conf
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

# Install TPM and every plugin listed in tmux.conf.
#
# tmux.conf ends with `run '~/.config/tmux/plugins/tpm/tpm'`, which fails
# SILENTLY when TPM is absent: keybindings still work (they are plain config),
# but no plugin and no theme ever loads. TPM is deliberately untracked here
# (see .gitignore - we do not want a nested git repo), so every fresh clone of
# these dotfiles hits this. Bootstrap it instead of leaving it to the reader.
setup_tmux_plugins() {
  local tpm_dir="$HOME/.config/tmux/plugins/tpm"

  echo "Setting up tmux plugins (TPM)..."

  if ! command -v tmux >/dev/null 2>&1; then
    echo "  tmux is not installed - skipping plugin setup"
    echo "  After installing tmux, re-run: $0 $PROFILE_NAME"
    return 0
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "  git is not installed - skipping plugin setup"
    return 0
  fi

  if [ -d "$tpm_dir" ]; then
    echo "  TPM already installed"
  else
    echo "  Cloning TPM..."
    if ! git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir" >/dev/null 2>&1; then
      echo "  Failed to clone TPM (no network?). Retry with:"
      echo "    git clone https://github.com/tmux-plugins/tpm $tpm_dir"
      echo "    $tpm_dir/bin/install_plugins"
      return 0
    fi
  fi

  # install_plugins is idempotent and, per TPM's own docs, does not need a
  # running tmux server - so this is safe during a headless/first-boot install.
  local output
  if output="$("$tpm_dir/bin/install_plugins" 2>&1)"; then
    echo "$output" | sed 's/^/  /'
  else
    echo "$output" | sed 's/^/  /'
    echo "  Some plugins failed to install. Retry with:"
    echo "    $tpm_dir/bin/install_plugins"
  fi

  # Pick up the new config/plugins in an already-running server, if there is one.
  if tmux list-sessions >/dev/null 2>&1; then
    tmux source-file "$HOME/.config/tmux/tmux.conf" >/dev/null 2>&1 || true
    echo "  Reloaded config in the running tmux server"
  fi
}

# Create the machine-specific config files that are deliberately untracked.
#
# hypr/local.lua + local.conf and waybar/.local hold per-machine monitor names,
# so they are gitignored - which means a FRESH CLONE has none of them and stow
# silently links nothing. Hyprland then starts with no monitor/workspace rules,
# and waybar's launch.sh fails to source $PRIMARY_MONITOR. Seed them from
# machines/<machine>.{lua,conf}. Runs before stow so the new files get linked
# in the same pass. Never overwrites an existing file - those are hand-tuned.
setup_machine_local_configs() {
  local hypr_dir="$DOTFILES_DIR/linux/hyprland/.config/hypr"
  local waybar_dir="$DOTFILES_DIR/linux/waybar/.config/waybar"
  local machine host

  echo "Checking machine-specific configuration..."

  # Prefer a template named after this host, otherwise guess the form factor.
  host="${HOSTNAME:-$(cat /etc/hostname 2>/dev/null)}"
  if [ -n "$host" ] && [ -f "$hypr_dir/machines/$host.lua" ]; then
    machine="$host"
  elif [ "$(hostnamectl chassis 2>/dev/null)" = "laptop" ] ||
    compgen -G "/sys/class/power_supply/BAT*" >/dev/null 2>&1; then
    machine="laptop"
  else
    machine="desktop"
  fi
  echo "  Detected machine: $machine"

  case " $PACKAGES " in
  *" hyprland "*)
    local ext target template
    for ext in lua conf; do
      target="$hypr_dir/local.$ext"
      template="$hypr_dir/machines/$machine.$ext"
      if [ -e "$target" ]; then
        echo "  hypr/local.$ext exists - keeping it"
      elif [ -f "$template" ]; then
        cp "$template" "$target"
        echo "  Created hypr/local.$ext from machines/$machine.$ext"
        echo "    Check monitor names/resolutions against: hyprctl monitors"
      else
        echo "  No template machines/$machine.$ext - create hypr/local.$ext by hand"
        echo "    Available templates: $(ls "$hypr_dir/machines/" 2>/dev/null | tr '\n' ' ')"
      fi
    done
    ;;
  esac

  case " $PACKAGES " in
  *" waybar "*)
    local waybar_local="$waybar_dir/.local"
    if [ -e "$waybar_local" ]; then
      echo "  waybar/.local exists - keeping it"
    else
      # The machine template is the curated answer; fall back to the live
      # session only when no template matched (first monitor may be wrong
      # on a multi-monitor box, so we always print what we picked).
      local primary=""
      if [ -f "$hypr_dir/machines/$machine.lua" ]; then
        primary="$(sed -n 's/^local primary[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' \
          "$hypr_dir/machines/$machine.lua" | head -1)"
      fi
      if [ -z "$primary" ] && command -v hyprctl >/dev/null 2>&1; then
        primary="$(hyprctl monitors 2>/dev/null | awk '/^Monitor /{print $2; exit}')"
      fi
      if [ -n "$primary" ]; then
        printf 'PRIMARY_MONITOR=%s\n' "$primary" >"$waybar_local"
        echo "  Created waybar/.local with PRIMARY_MONITOR=$primary"
      else
        echo "  Could not determine the primary monitor."
        echo "    Create it by hand (see waybar/.local.example and hyprctl monitors):"
        echo "      echo 'PRIMARY_MONITOR=<name>' > $waybar_local"
      fi
    fi
    ;;
  esac
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

# Seed untracked machine-specific files before stow, so they get linked too.
case " $PACKAGES " in
*" hyprland "* | *" waybar "*)
  setup_machine_local_configs
  echo ""
  ;;
esac

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

# Post-stow setup for packages that need more than a symlink.
case " $PACKAGES " in
*" tmux "*)
  setup_tmux_plugins
  echo ""
  ;;
esac

echo "Profile '$PROFILE_NAME' installed successfully!"
echo ""

# Check if this is an Arch system with Hyprland profile
if [[ "$PROFILE_NAME" == "arch-hyprland" ]]; then
  echo "Next steps for Arch + Hyprland:"
  echo "1. Reload Hyprland configuration: hyprctl reload"
  echo "   NOTE: 'hyprctl reload' cannot switch config formats. If the running"
  echo "   session started from an older .conf setup, it stays on hyprlang and"
  echo "   ignores hyprland.lua - log out and back in to pick it up."
  echo "   Check with: hyprctl systeminfo | grep configProvider"
  echo ""
  echo "If you haven't installed packages yet, run:"
  echo "   bash $DOTFILES_DIR/linux/bootstrap/arch-install.sh"
else
  echo "Next steps:"
  echo "1. Source your shell config: source ~/.zshrc"
  echo "2. Restart your terminal or shell to load changes"
fi

echo ""
echo "For Tmux users (prefix is Ctrl+Space):"
echo "  - Start tmux: tmux new-session -s main"
echo "  - Reload config from inside tmux:  prefix + ,"
echo "  - Reload config from a shell:      tmux source-file ~/.config/tmux/tmux.conf"
echo "  - Install plugins added later:     prefix + I"
echo "  - Reinstall all plugins:           ~/.config/tmux/plugins/tpm/bin/install_plugins"
echo "  - If the theme is missing, the plugins did not load - reinstall them with"
echo "    the command above, then reload."
echo ""
echo "For more details, see: $DOTFILES_DIR/README.md"
