#!/usr/bin/env bash
set -euo pipefail

# --- Settings ---------------------------------------------------------------
PACMAN_LIST="${PACMAN_LIST:-bootstrap/pacman.txt}"
AUR_LIST="${AUR_LIST:-bootstrap/aur.txt}"
PROFILE="${PROFILE:-arch-hyprland}"
DOTS_DIR="${DOTS_DIR:-$HOME/dotfiles}"

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
  echo "Enabling user services (PipeWire/WirePlumber via system packages is usually enough)..."
  # SDDM likely already enabled by KDE install; uncomment if needed:
  # need_root "systemctl enable --now sddm"
}

apply_stow_profile() {
  echo "Applying Stow profile: $PROFILE"
  cd "$DOTS_DIR"

  # ensure local ignore exists
  [[ -f ".stow-local-ignore" ]] || cat >.stow-local-ignore <<'EOF'
^(\.git|README\.md|profiles|bootstrap|scripts|\.stow.*)$
EOF

  # read package names, ignoring comments/blank lines
  mapfile -t pkgs < <(sed -E 's/#.*$//; /^\s*$/d' "profiles/$PROFILE.txt")

  echo "Previewing stow actions:"
  printf '%s\n' "${pkgs[@]}" | xargs -I{} stow -nvt "$HOME" {}

  printf '%s\n' "${pkgs[@]}" | xargs -I{} stow -vt "$HOME" {}

  HOST_PACKAGE="host-$(hostname)"
  [[ -d "$HOST_PACKAGE" ]] && stow -vt "$HOME" "$HOST_PACKAGE"
}

post_install_hints() {
  cat <<'EOF'

Done ✔

Next steps:
1) Log out to SDDM and select the "Hyprland" session.
2) Ensure your Hyprland config autostarts:
     exec-once = waybar
     exec-once = polkit-kde-agent
   and sets a terminal bind, e.g.:
     bind = SUPER, Return, exec, ghostty
3) NVIDIA users: after editing GRUB kernel params, reboot.
4) Test: waybar, wofi (--show drun), wl-clipboard

Troubleshooting:
- Hyprland log:  journalctl --user -b -u hyprland
- Cursor glitches on NVIDIA? In hyprland.conf add:
    env = WLR_NO_HARDWARE_CURSORS,1
    env = LIBVA_DRIVER_NAME,nvidia
    env = GBM_BACKEND,nvidia-drm
    env = __GLX_VENDOR_LIBRARY_NAME,nvidia

EOF
}

main() {
  install_pacman_packages
  install_yay
  install_aur_packages
  ensure_nvidia_tweaks
  enable_services
  apply_stow_profile
  post_install_hints
}

main "$@"
