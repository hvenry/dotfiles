#!/usr/bin/env bash
set -euo pipefail

# macOS counterpart to linux/bootstrap/arch-install.sh: installs the apps the
# macos profile configures, then stows the dotfiles.

# Detect the repo root (this script lives in macos/bootstrap/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BREWFILE="${BREWFILE:-$SCRIPT_DIR/macos/bootstrap/Brewfile}"
PROFILE="${PROFILE:-macos}"
DOTS_DIR="${DOTS_DIR:-$SCRIPT_DIR}"

have() { command -v "$1" >/dev/null 2>&1; }

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: this script is for macOS."
    echo "       On Arch, use linux/bootstrap/arch-install.sh instead."
    exit 1
  fi
}

install_homebrew() {
  if have brew; then
    echo "Homebrew already installed."
  else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # A fresh install is not on PATH yet. Cover Apple Silicon and Intel prefixes.
  if ! have brew; then
    local brew_bin
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      if [[ -x "$brew_bin" ]]; then
        eval "$("$brew_bin" shellenv)"
        break
      fi
    done
  fi

  if ! have brew; then
    echo "Error: brew is still not on PATH after installation."
    echo "       Open a new shell and re-run this script."
    exit 1
  fi
}

install_packages() {
  [[ -f "$BREWFILE" ]] || {
    echo "Missing $BREWFILE"
    exit 1
  }
  echo "Installing packages from $BREWFILE ..."
  brew bundle --file "$BREWFILE"
}

apply_stow_profile() {
  echo "Applying profile: $PROFILE"

  if ! have stow; then
    echo "Error: stow is not installed. It should have come from the Brewfile."
    exit 1
  fi

  if [[ ! -f "$DOTS_DIR/profiles/$PROFILE.txt" ]]; then
    echo "Error: Profile file 'profiles/$PROFILE.txt' not found!"
    exit 1
  fi

  # install-profile.sh also bootstraps TPM and the tmux plugins.
  # Pass --clean via CLEAN=1 to remove conflicting configs first.
  if [[ "${CLEAN:-0}" == "1" ]]; then
    "$DOTS_DIR/install-profile.sh" --clean "$PROFILE"
  else
    "$DOTS_DIR/install-profile.sh" "$PROFILE"
  fi
}

main() {
  echo "=== macOS Dotfiles Setup ==="
  echo "Repository: $DOTS_DIR"
  echo "Profile: $PROFILE"
  echo ""

  if [[ ! -d "$DOTS_DIR/macos/bootstrap" ]]; then
    echo "Error: This script must be run from the dotfiles repository root"
    echo "       or DOTS_DIR must be set to the repo path."
    exit 1
  fi

  require_macos
  install_homebrew
  install_packages
  apply_stow_profile

  echo ""
  echo "=== Done ==="
  echo "Follow-ups that cannot be scripted:"
  echo "  - 1Password: sign in, then enable Settings > Developer > SSH agent if you want it"
  echo "  - AeroSpace: grant Accessibility permission on first launch"
  echo "  - Rectangle: Settings > Import, choose"
  echo "      macos/rectangle/.config/rectangle/RectangleConfig.json"
  echo "    (Rectangle reads a plist, so the dotfile is a snapshot - see README)"
}

main "$@"
