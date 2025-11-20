#!/usr/bin/env bash
set -euo pipefail

# --- Settings ---------------------------------------------------------------
# Detect this script's directory (repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACMAN_LIST="${PACMAN_LIST:-$SCRIPT_DIR/bootstrap/pacman.txt}"
AUR_LIST="${AUR_LIST:-$SCRIPT_DIR/bootstrap/aur.txt}"
PROFILE="${PROFILE:-arch-hyprland}"
DOTS_DIR="${DOTS_DIR:-$SCRIPT_DIR}"

# --- Helpers ----------------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }

need_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This step needs sudo/root. Re-running with sudo..."
    sudo -E bash -c "$*"
  else
    bash -c "$*"
  fi
}

install_yay() {
  if have yay; then
    echo "yay already installed."
    return
  fi
  echo "Installing yay (AUR helper)..."
  need_root "pacman -S --needed --noconfirm base-devel git"
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
}

install_pacman_packages() {
  [[ -f "$PACMAN_LIST" ]] || {
    echo "Missing $PACMAN_LIST"
    exit 1
  }
  echo "Installing pacman packages from $PACMAN_LIST ..."
  # strip comments/blank lines
  pkgs=$(sed -E 's/#.*$//; /^\s*$/d' "$PACMAN_LIST" | xargs)
  if [[ -z "$pkgs" ]]; then
    echo "No pacman packages to install."
    return 0
  fi
  need_root "pacman -Syu --needed --noconfirm $pkgs"
}

install_aur_packages() {
  [[ -f "$AUR_LIST" ]] || {
    echo "No $AUR_LIST found, skipping AUR."
    return 0
  }
  echo "Installing AUR packages from $AUR_LIST ..."
  # strip comments/blank lines
  aur_pkgs=$(sed -E 's/#.*$//; /^\s*$/d' "$AUR_LIST" | xargs || true)
  [[ -n "${aur_pkgs:-}" ]] || {
    echo "No AUR packages listed, skipping."
    return 0
  }
  yay -S --needed --noconfirm $aur_pkgs
}

ensure_nvidia_tweaks() {
  # Add recommended kernel params for modeset if NVIDIA driver is detected
  if lsmod | grep -q nvidia || [[ -e /proc/driver/nvidia/version ]]; then
    echo "NVIDIA detected. Ensure kernel params include: nvidia-drm.modeset=1 nvidia_drm.fbdev=1"
    echo "If you use GRUB:"
    echo "  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet nvidia-drm.modeset=1 nvidia_drm.fbdev=1\"/' /etc/default/grub"
    echo "  sudo grub-mkconfig -o /boot/grub/grub.cfg"
    echo "Reboot afterward to apply."
  fi
}

enable_services() {
  echo "Enabling user services (PipeWire/WirePlumber)..."
  # Ly is typically enabled by the package, but you can enable it manually if needed:
  # need_root "systemctl enable --now ly"
}

apply_stow_profile() {
  echo "Applying Stow profile: $PROFILE"

  # Verify stow is installed
  if ! have stow; then
    echo "Error: stow is not installed. Install it with: pacman -S stow"
    exit 1
  fi

  cd "$DOTS_DIR"

  # Verify profile file exists
  if [[ ! -f "profiles/$PROFILE.txt" ]]; then
    echo "Error: Profile file 'profiles/$PROFILE.txt' not found!"
    exit 1
  fi

  # read package names, ignoring comments/blank lines
  mapfile -t pkgs < <(sed -E 's/#.*$//; /^\s*$/d' "profiles/$PROFILE.txt")

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    echo "Error: No packages found in profile '$PROFILE'!"
    exit 1
  fi

  echo "Previewing stow actions for packages: ${pkgs[*]}"
  printf '%s\n' "${pkgs[@]}" | xargs -I{} stow -nvt "$HOME" {}

  echo "Applying stow symlinks..."
  printf '%s\n' "${pkgs[@]}" | xargs -I{} stow -vt "$HOME" {}

  # Check for host-specific package
  HOST_PACKAGE="host-$(hostname)"
  if [[ -d "$HOST_PACKAGE" ]]; then
    echo "Found host-specific package: $HOST_PACKAGE"
    stow -vt "$HOME" "$HOST_PACKAGE"
  fi
}

run_post_install() {
  local post_install_script="$SCRIPT_DIR/bootstrap/post-install.sh"
  if [[ -f "$post_install_script" ]]; then
    echo "Running post-install setup..."
    bash "$post_install_script"
  else
    echo "Warning: post-install script not found at $post_install_script"
  fi
}

main() {
  echo "=== Arch Linux + Hyprland Dotfiles Setup ==="
  echo "Repository: $DOTS_DIR"
  echo "Profile: $PROFILE"
  echo ""

  # Verify we're in the repo or it's cloned correctly
  if [[ ! -d "$DOTS_DIR/bootstrap" ]]; then
    echo "Error: This script must be run from the dotfiles repository root"
    echo "       or DOTS_DIR must be set to the repo path."
    exit 1
  fi

  install_pacman_packages
  install_yay
  install_aur_packages
  ensure_nvidia_tweaks
  enable_services
  apply_stow_profile
  run_post_install
}

main "$@"
