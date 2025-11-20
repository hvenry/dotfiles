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

  if [[ -d ~/.config/tmux/plugins/tpm ]]; then
    echo "TPM already installed at ~/.config/tmux/plugins/tpm"
    return
  fi

  echo "Installing TPM..."
  mkdir -p ~/.config/tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

  echo "✓ TPM installed"
  echo "Note: Start a tmux session and press prefix+I to install plugins (default: Ctrl+Space + I)"
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
setup_systemd_timers() {
  echo "=== Setting up systemd user timers ==="

  if [[ ! -f ~/.config/systemd/user/yay-update.timer ]]; then
    echo "Systemd timer files not found. They should have been installed with stow."
    echo "Skipping systemd timer setup."
    return
  fi

  echo "Enabling yay-update timer..."
  systemctl --user daemon-reload
  systemctl --user enable yay-update.timer
  systemctl --user start yay-update.timer

  echo "✓ Yay update timer enabled"
  echo "  Timer will run daily at 2 AM and on boot (5 min delay)"
  echo "  Check status: systemctl --user status yay-update.timer"
  echo "  View logs: journalctl --user -u yay-update.service"
}

setup_symlinks() {
  echo "=== Setting up convenience symlinks ==="

  # Create ~/.config if it doesn't exist
  mkdir -p ~/.config

  echo "✓ Config directories verified"
}

# --- Validation checks -------------------------------------------------------
validate_dependencies() {
  echo "=== Validating critical dependencies ==="
  local missing=()

  if ! have fzf; then
    missing+=("fzf")
  fi

  if ! have gettext; then
    missing+=("gettext")
  fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "⚠️  Warning: Missing packages detected:"
    for pkg in "${missing[@]}"; do
      echo "   - $pkg"
    done
    echo "Install with: sudo pacman -S ${missing[*]}"
  else
    echo "✓ All critical dependencies found"
  fi
}

validate_manual_configs() {
  echo "=== Checking for manual configuration requirements ==="

  if [[ ! -f ~/.config/hypr/local.conf ]]; then
    echo "⚠️  Hyprland: ~/.config/hypr/local.conf not found"
    echo "   You must configure monitor settings. Copy one of:"
    echo "   - cp ~/.config/hypr/machines/laptop.conf ~/.config/hypr/local.conf"
    echo "   - cp ~/.config/hypr/machines/desktop.conf ~/.config/hypr/local.conf"
    echo "   Or create a custom local.conf with your monitor configuration"
  else
    echo "✓ Hyprland local.conf found"
  fi

  if [[ ! -f ~/.config/waybar/.local ]]; then
    echo "⚠️  Waybar: ~/.config/waybar/.local not found"
    echo "   You must configure the primary monitor. Run:"
    echo "   - cp ~/.config/waybar/.local.example ~/.config/waybar/.local"
    echo "   - Edit ~/.config/waybar/.local and set PRIMARY_MONITOR (e.g., DP-4)"
  else
    echo "✓ Waybar .local found"
  fi
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
   - Press prefix + I to install tmux plugins (default: Ctrl+Space + I)

3. DISPLAY MANAGER:
   - A display manager was configured above
   - Reboot to apply changes: sudo reboot

4. NEOVIM:
   - Launch neovim: nvim
   - Run :Mason to install language servers
   - LSP servers will auto-install on first use

5. AUTOMATIC PACKAGE UPDATES (AUR):
   - Systemd timer is enabled to check for updates daily at 2 AM
   - Also runs 5 minutes after boot
   - To manually check for updates: yay -Syu
   - Check timer status: systemctl --user status yay-update.timer
   - View update logs: journalctl --user -u yay-update.service
   - Discord and other AUR packages will stay current

6. REQUIRED CONFIGURATIONS (BEFORE FIRST BOOT):
   - HYPRLAND: Create ~/.config/hypr/local.conf
     cp ~/.config/hypr/machines/laptop.conf ~/.config/hypr/local.conf
     (Or use desktop.conf, or create custom for your monitors)
   - WAYBAR: Create ~/.config/waybar/.local
     cp ~/.config/waybar/.local.example ~/.config/waybar/.local
     Edit it to set PRIMARY_MONITOR (check 'hyprctl monitors' after boot)

7. OPTIONAL CUSTOMIZATIONS:
   - Advanced Hyprland tweaks: ~/.config/hypr/hyprland.conf
   - Waybar styling: ~/.config/waybar/style.css
   - Rofi customizations: ~/.config/rofi/config.rasi
   - Check ~/.config for other application configs

8. NVIDIA USERS:
   - If using NVIDIA GPU, ensure kernel params are set:
     sudo cat /etc/default/grub | grep nvidia
   - Add if missing: nvidia-drm.modeset=1

9. FIRST REBOOT:
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

  setup_systemd_timers
  echo ""

  setup_npm_globals
  echo ""

  setup_python
  echo ""

  setup_symlinks
  echo ""

  validate_dependencies
  echo ""

  validate_manual_configs
  echo ""

  print_next_steps
}

main "$@"
