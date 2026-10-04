# macOS setup

How a new Mac goes from nothing to the `macos` profile.

## Why

The dotfiles only configure apps; something has to install them first.
`brew-install.sh` is the macOS counterpart to the Arch bootstrap, so a fresh Mac needs one command.

## How it works

1. `macos/bootstrap/brew-install.sh` refuses to run off macOS.
2. It finds Homebrew at `/opt/homebrew` or `/usr/local`, installing it only if neither exists.
3. `brew bundle` installs everything in `macos/bootstrap/Brewfile`.
4. It runs `install-profile.sh macos`, with `--clean` when `CLEAN=1` is set.
5. It prints the steps that cannot be scripted: 1Password sign-in and SSH agent, AeroSpace Accessibility permission, Rectangle import.

`PROFILE`, `BREWFILE` and `DOTS_DIR` env vars override the defaults.

## Tech

- Homebrew and Homebrew Bundle, GNU Stow.
- AeroSpace (tiling workspaces) and Rectangle (snapping) for window management.

## Key files

- `macos/bootstrap/brew-install.sh` - bootstrap script
- `macos/bootstrap/Brewfile` - apps and CLI tools the profile configures
- `macos/aerospace/.aerospace.toml` - AeroSpace config
- `macos/rectangle/.config/rectangle/RectangleConfig.json` - Rectangle snapshot

## Decisions and gotchas

- Homebrew prefixes are probed before installing, because a fresh shell has brew on disk but not on `PATH`, and re-running the installer over it can fail.
- Rectangle reads a plist, not a dotfile, so the JSON is a snapshot.
  After changing bindings, Settings > Export over the repo file and commit it.
  On a new Mac, Settings > Import and pick it.
- VS Code and lazygit read `~/Library/Application Support/`, not `~/.config`, so their stowed configs are not used on macOS yet.

## Related

- [Install profiles](install-profiles.md)
- [Stow layout](stow-layout.md)
- [Arch setup](arch-setup.md)
