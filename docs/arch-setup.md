# Arch setup

How a fresh Arch install becomes the full Hyprland desktop.

## Why

A Hyprland desktop needs system packages, AUR packages, a display manager and user services, not just config files.
Scripting all of it makes a reinstall one command instead of an afternoon.

## How it works

`linux/bootstrap/arch-install.sh`, run as the normal user (it escalates with `sudo` itself):

1. Installs `linux/bootstrap/pacman.txt` with pacman.
2. Installs `yay-bin` from the AUR if yay is missing.
3. Pre-imports upstream GPG signing keys for AUR packages.
4. Installs `linux/bootstrap/aur.txt` with yay.
5. Prints NVIDIA kernel params if an NVIDIA driver is detected.
6. Runs `install-profile.sh arch-hyprland` (`CLEAN=1` passes `--clean`), then stows a `host-<hostname>` package if one exists.
7. Runs `post-install.sh`: TPM, zsh, switches the display manager to Ly, optional npm `neovim` package, enables the `yay-update.timer` user timer, and checks the manual configs.

`quick-setup.sh` is the curl-able entry point: it clones the repo if needed, then runs `arch-install.sh`.

## Tech

- pacman, yay, makepkg, GPG, systemd (system and `--user`), Ly.

## Key files

- `linux/bootstrap/arch-install.sh` - main installer
- `linux/bootstrap/quick-setup.sh` - clone-and-run entry point
- `linux/bootstrap/post-install.sh` - user-level finishing steps
- `linux/bootstrap/pacman.txt` - official packages
- `linux/bootstrap/aur.txt` - AUR packages
- `linux/systemd/.config/systemd/user/yay-update.timer` - scheduled package updates

## Decisions and gotchas

- AUR steps drop to `$SUDO_USER` via `run_as_user`, because makepkg and yay refuse to run as root.
- Signing keys are imported up front so `yay --noconfirm` cannot stall on an unknown-key prompt.
- `post-install.sh` is entirely user-level, so it also runs through `run_as_user`.
- `hostname` is not installed on base Arch (it ships in inetutils), so the host name comes from `$HOSTNAME`, `/etc/hostname` or `uname -n`.

## Related

- [Hyprland desktop](hyprland-desktop.md)
- [Install profiles](install-profiles.md)
- [macOS setup](macos-setup.md)
