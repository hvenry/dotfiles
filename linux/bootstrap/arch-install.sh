#!/usr/bin/env bash
set -euo pipefail

# --- Settings ---------------------------------------------------------------
# Detect the repo root (this script lives in linux/bootstrap/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACMAN_LIST="${PACMAN_LIST:-$SCRIPT_DIR/linux/bootstrap/pacman.txt}"
AUR_LIST="${AUR_LIST:-$SCRIPT_DIR/linux/bootstrap/aur.txt}"
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

# Home directory of the user the dotfiles belong to. Under sudo, $HOME is
# root's, which would stow every symlink into /root.
target_home() {
  if [[ $EUID -eq 0 && -n "${SUDO_USER:-}" ]]; then
    getent passwd "$SUDO_USER" | cut -d: -f6
  else
    printf '%s' "$HOME"
  fi
}

# Run a command as the invoking user, even when this script runs under sudo.
# makepkg and yay both refuse to run as root. HOME is set through `env` rather
# than `sudo VAR=val` so a restrictive sudoers setenv policy cannot silently
# leave it pointing at /root.
run_as_user() {
  if [[ $EUID -eq 0 && -n "${SUDO_USER:-}" ]]; then
    sudo -u "$SUDO_USER" env "HOME=$(target_home)" "$@"
  else
    "$@"
  fi
}

# makepkg and yay must run as a normal user. When this script is run under
# sudo we drop back to $SUDO_USER; with no such user there is nobody to build
# as, so fail early and loudly instead of midway through the install.
require_build_user() {
  if [[ $EUID -eq 0 && -z "${SUDO_USER:-}" ]]; then
    echo "Error: makepkg and yay refuse to run as root, and SUDO_USER is unset,"
    echo "       so there is no unprivileged user to build AUR packages as."
    echo "       Re-run as your normal user (the script sudo's when it needs to):"
    echo "         ./linux/bootstrap/arch-install.sh"
    exit 1
  fi
}

install_yay() {
  if have yay; then
    echo "yay already installed."
    return
  fi
  require_build_user
  echo "Installing yay (AUR helper)..."
  need_root "pacman -S --needed --noconfirm base-devel git"
  # Build as the invoking user - makepkg aborts when run as root.
  tmp=$(run_as_user mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  run_as_user git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  run_as_user bash -c 'cd "$1" && makepkg -si --noconfirm' _ "$tmp/yay-bin"
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
  require_build_user
  # yay refuses to run as root ("Avoid running yay as root/sudo."), so drop
  # to the invoking user. Unquoted on purpose: the list must word-split.
  run_as_user yay -S --needed --noconfirm $aur_pkgs
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

# Stow each named package from whichever platform dir contains it.
# First arg: extra stow flags ("-n" for preview, "" for apply); rest: package names.
stow_each() {
  local extra_flags="$1"
  shift
  local pkg dir found
  for pkg in "$@"; do
    found=""
    for dir in shared macos linux; do
      if [[ -d "$dir/$pkg" ]]; then
        # $extra_flags intentionally unquoted: "" must expand to zero args
        stow $extra_flags -vt "$HOME" -d "$dir" "$pkg"
        found=1
        break
      fi
    done
    [[ -n "$found" ]] || echo "Warning: package '$pkg' not found in shared/, macos/, or linux/ — skipping"
  done
}

# `hostname` is NOT installed by default on Arch (it ships in inetutils, which
# this repo never installs). Under `set -e` a failing command substitution
# aborts the whole script, so resolve the host name without external commands.
get_hostname() {
  local h="${HOSTNAME:-}"
  [[ -n "$h" ]] || h="$(cat /etc/hostname 2>/dev/null || true)"
  [[ -n "$h" ]] || h="$(uname -n 2>/dev/null || true)"
  printf '%s' "$h"
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
  stow_each "-n" "${pkgs[@]}"

  echo "Applying stow symlinks..."
  stow_each "" "${pkgs[@]}"

  # Check for host-specific package
  local host
  host="$(get_hostname)"
  if [[ -n "$host" && -d "host-$host" ]]; then
    echo "Found host-specific package: host-$host"
    run_as_user stow -vt "$(target_home)" "host-$host"
  fi
}

run_post_install() {
  local post_install_script="$SCRIPT_DIR/linux/bootstrap/post-install.sh"
  if [[ -f "$post_install_script" ]]; then
    echo "Running post-install setup..."
    # post-install.sh is entirely user-level (~/.config, ~/.zshrc,
    # `systemctl --user`), so it must not run as root.
    run_as_user bash "$post_install_script"
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
  if [[ ! -d "$DOTS_DIR/linux/bootstrap" ]]; then
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
