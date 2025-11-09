#!/usr/bin/env bash
# Quick setup script for deploying dotfiles on a new Arch Linux machine
# Usage: bash <(curl -fsSL https://raw.github.com/user/dotfiles/master/bootstrap/quick-setup.sh)
# Or:    git clone https://github.com/user/dotfiles.git ~/dotfiles && ~/dotfiles/bootstrap/quick-setup.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_step() {
  echo -e "${GREEN}==>${NC} $1"
}

print_error() {
  echo -e "${RED}Error:${NC} $1" >&2
}

print_warning() {
  echo -e "${YELLOW}Warning:${NC} $1"
}

# Detect if running from curl or local
if [[ ! -d "$(pwd)/bootstrap" ]]; then
  print_step "Cloning dotfiles repository..."
  if ! command -v git &> /dev/null; then
    print_error "git not found. Install with: sudo pacman -S git"
    exit 1
  fi

  REPO="${REPO:-https://github.com/yourusername/dotfiles.git}"
  DOTS_DIR="${DOTS_DIR:-$HOME/dotfiles}"

  if [[ -d "$DOTS_DIR" ]]; then
    print_warning "$DOTS_DIR already exists, skipping clone"
  else
    git clone "$REPO" "$DOTS_DIR"
  fi

  cd "$DOTS_DIR"
fi

# Verify we're in the right place
if [[ ! -f "bootstrap/arch-install.sh" ]]; then
  print_error "bootstrap/arch-install.sh not found. Are you in the dotfiles directory?"
  exit 1
fi

print_step "Dotfiles directory: $(pwd)"

# Check if running with root
if [[ $EUID -eq 0 ]]; then
  print_error "Please run this script as a regular user (not root)"
  print_error "It will prompt for sudo when needed"
  exit 1
fi

# Offer setup choices
echo ""
echo "Setup Options:"
echo "1. Full Hyprland setup (packages + configs) - Recommended"
echo "2. Configs only (assumes packages already installed)"
echo "3. Show help and exit"
echo ""
read -p "Choose option [1-3]: " choice

case "$choice" in
  1)
    print_step "Starting full Hyprland bootstrap..."
    print_warning "You will be prompted for your sudo password"
    echo ""
    read -p "Press Enter to continue..."
    sudo bash bootstrap/arch-install.sh
    ;;
  2)
    print_step "Installing dotfiles only (no packages)..."
    ./install-profile.sh arch-hyprland
    ;;
  3)
    cat <<'EOF'
Quick Setup Script Usage
========================

Full Setup (Recommended):
  bash bootstrap/quick-setup.sh
  Choose option 1 (installs packages + configs)

Configs Only:
  ./install-profile.sh arch-hyprland

Manual Steps:
  1. Clone: git clone <repo> ~/dotfiles
  2. Install stow: sudo pacman -S stow
  3. Install packages: sudo bash bootstrap/arch-install.sh
  4. Or just configs: ./install-profile.sh arch-hyprland

Environment Variables:
  REPO=<url>          - Repository URL for cloning
  DOTS_DIR=<path>     - Target dotfiles directory
  PROFILE=<name>      - Profile to install (default: arch-hyprland)

More info: cat SETUP.md
EOF
    exit 0
    ;;
  *)
    print_error "Invalid option"
    exit 1
    ;;
esac

echo ""
print_step "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Reboot your machine"
echo "2. Log in with Ly display manager"
echo "3. Source your shell: source ~/.zshrc"
echo "4. Restart your terminal"
echo ""
echo "For more information, see: $(pwd)/SETUP.md"
