#!/usr/bin/env bash
set -euo pipefail

# Post-installation setup script for Arch Linux + Hyprland dotfiles
# This script handles configuration that doesn't fit into package installation

# --- Helpers ----------------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }

prompt_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  local response

  while true; do
    read -p "$prompt (y/n) [${default}]: " -r response
    response=${response:-$default}
    case "$response" in
      [Yy]) return 0 ;;
      [Nn]) return 1 ;;
      *) echo "Please answer y or n" ;;
    esac
  done
}

# --- Setup Tmux Plugin Manager -----------------------------------------------
setup_tpm() {
  echo "=== Setting up Tmux Plugin Manager (TPM) ==="

  if [[ -d ~/.tmux/plugins/tpm ]]; then
    echo "TPM already installed at ~/.tmux/plugins/tpm"
    return
  fi

  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  echo "✓ TPM installed"
  echo "Note: Start a tmux session and press prefix+I to install plugins"
}

# --- Setup Zsh Environment ---------------------------------------------------
setup_zsh() {
  echo "=== Setting up Zsh environment ==="

  # Source zshrc to apply configurations
  if [[ -f ~/.zshrc ]]; then
    echo "Sourcing ~/.zshrc..."
    source ~/.zshrc || true
    echo "✓ Zsh configuration loaded"
  else
    echo "Warning: ~/.zshrc not found. Did you run the dotfiles installation?"
  fi
}

# --- Display Manager Setup ---------------------------------------------------
setup_display_manager() {
  echo "=== Display Manager Setup ==="

  if ! have ly; then
    echo "Ly display manager not installed. Install with: sudo pacman -S ly"
    return
  fi

  echo "Setting up Ly as the primary display manager..."
  sudo systemctl disable --now sddm 2>/dev/null || true
  sudo systemctl enable --now ly
  echo "✓ Ly enabled as primary display manager"
  echo "Note: Reboot to apply changes"
}

# --- Install Global NPM Packages ---------------------------------------------
setup_npm_globals() {
  echo "=== Setting up global NPM packages ==="

  if ! have npm; then
    echo "npm not found, skipping NPM setup"
    return
  fi

  if prompt_yes_no "Install neovim npm package for LSP support?" "y"; then
    echo "Installing neovim npm package..."
    sudo npm install -g neovim
    echo "✓ npm neovim package installed"
  fi
}

# --- Setup Python Tools ------------------------------------------------------
setup_python() {
  echo "=== Setting up Python environment ==="

  if ! have python; then
    echo "python not found, skipping Python setup"
    return
  fi

  if prompt_yes_no "Upgrade pip?" "y"; then
    echo "Upgrading pip..."
    python -m pip install --upgrade pip
    echo "✓ pip upgraded"
  fi
}

# --- Create symlinks for convenience -----------------------------------------
setup_symlinks() {
  echo "=== Setting up convenience symlinks ==="

  # Create ~/.config if it doesn't exist
  mkdir -p ~/.config

  echo "✓ Config directories verified"
}

# --- Post-install hints and next steps ---------------------------------------
print_next_steps() {
  cat <<'EOF'

========================================
✓ Post-installation setup complete!
========================================

Next steps:

1. IMMEDIATE:
   - Source your shell: source ~/.zshrc
   - Review your shell configuration

2. TMUX:
   - Start a new tmux session: tmux new-session -s main
   - Press Ctrl+b (or your prefix) + I to install tmux plugins

3. DISPLAY MANAGER:
   - A display manager was configured above
   - Reboot to apply changes: sudo reboot

4. NEOVIM:
   - Launch neovim: nvim
   - Run :Mason to install language servers
   - LSP servers will auto-install on first use

5. OPTIONAL CONFIGURATIONS:
   - Check ~/.config for application configs
   - Customize Hyprland at ~/.config/hypr/hyprland.conf
   - Customize Waybar at ~/.config/waybar/
   - Customize rofi at ~/.config/rofi/

6. NVIDIA USERS:
   - If using NVIDIA GPU, ensure kernel params are set:
     sudo cat /etc/default/grub | grep nvidia
   - Add if missing: nvidia-drm.modeset=1

7. FIRST REBOOT:
   - Log in with the configured display manager
   - Hyprland should auto-detect and start
   - If issues, check: journalctl --user -xe

Troubleshooting resources:
- Hyprland:  ~/.config/hypr/hyprland.conf
- Waybar:    ~/.config/waybar/config.json
- Zsh:       ~/.zshrc
- Neovim:    ~/.config/nvim/init.lua

For more help, see the README.md in your dotfiles directory.

EOF
}

# --- Main -------------------------------------------------------------------
main() {
  echo "╔════════════════════════════════════════════╗"
  echo "║  Arch Linux + Hyprland Post-Install Setup  ║"
  echo "╚════════════════════════════════════════════╝"
  echo ""

  setup_tpm
  echo ""

  setup_zsh
  echo ""

  setup_display_manager
  echo ""

  setup_npm_globals
  echo ""

  setup_python
  echo ""

  setup_symlinks
  echo ""

  print_next_steps
}

main "$@"
