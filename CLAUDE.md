# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a modular dotfiles repository that uses GNU Stow for symlink-based configuration management, organized by platform. Each application is a stow package living under exactly one platform directory.

## Architecture

### Platform Directories

- `shared/` — packages used on every machine: zsh, nvim, tmux, ghostty, vscode, herdr, claude, agents
- `macos/` — macOS-only packages: aerospace, rectangle (a config *snapshot* — Rectangle reads a plist, not the dotfile; sync is via the app's Export/Import)
- `linux/` — Arch Linux + Hyprland desktop packages (hyprland, waybar, rofi, mako, wlogout, gtk, xsettingsd, xdg, ly, systemd, scripts, backgrounds) plus `linux/bootstrap/` (automated Arch installer)

### Stow-Based Package System

- Packages contain `.config` directories that mirror the target structure in `~/.config/` (or top-level dotfiles like `zsh/.zshrc`, `aerospace/.aerospace.toml`)
- `.stowrc` configures stow with `--no-folding`, `--verbose`, `--restow`, and `--target=~` — the target flag is required because packages live in subdirectories
- Install a package from the repo root with `stow -d <platform-dir> <package>`

### Profile-Based Installation

- Profiles in `profiles/` list package names (no platform prefix); `install-profile.sh` resolves each name by searching `shared/`, `macos/`, then `linux/`
- `macos.txt`: zsh, nvim, tmux, ghostty, vscode, aerospace, rectangle, herdr, claude, agents
- `arch-hyprland.txt`: full Wayland desktop with Hyprland
- `server.txt`: minimal headless setup (zsh, nvim, tmux, claude, agents)

## Common Commands

```bash
# Install dotfiles profiles (configs only); --clean avoids symlink conflicts
./install-profile.sh --clean macos
./install-profile.sh --clean arch-hyprland
./install-profile.sh --clean server

# Install/remove individual packages (from the repo root)
stow -d shared nvim
stow -d macos aerospace
stow -D -d shared nvim

# Automated Arch Linux setup (packages + dotfiles)
# Run as your normal user - it escalates with sudo itself, and makepkg/yay
# refuse to run as root.
./linux/bootstrap/arch-install.sh

# Automated macOS setup (Homebrew packages + dotfiles)
./macos/bootstrap/brew-install.sh

# Reload configs
source ~/.zshrc
tmux source ~/.config/tmux/tmux.conf
```

## Important Notes

- **Edit files in the repository**, not the symlinked copies in `~` — they are the same files, but repo paths are canonical.
- **VS Code**: `shared/vscode` stows to `~/.config/Code/User/` on every platform (VS Code's native location on Linux; on macOS, VS Code's actual config dir `~/Library/Application Support/Code/User/` is not currently wired up).
- **Package structure**: `<platform-dir>/<package>/.config/<package>/...` for `~/.config` targets, or `<platform-dir>/<package>/<dotfile>` for home-root dotfiles. `shared/claude` targets `~/.claude/` directly (Claude Code does not use `~/.config`); it holds `CLAUDE.md` (a one-line `@~/.agents/AGENTS.md` import plus any Claude-only rules), `settings.json`, `statusline.sh`, and hand-written skills under `skills/`.
- **Global agent instructions**: `shared/agents/.agents/AGENTS.md` is the single source for rules every coding agent follows. The `agents` package also holds relative symlinks to it at `.codex/AGENTS.md` and `.config/opencode/AGENTS.md`; Claude Code reads it via the import in `~/.claude/CLAUDE.md`. Edit only the source file.
- **Claude plugins**: `settings.json` (`enabledPlugins`, `extraKnownMarketplaces`) is the plugin manifest; installed files stay untracked. `scripts/claude-sync.sh` installs any missing plugins and runs automatically when a profile includes `claude`. Personal-only plugins (MCP plugins notion/figma/railway, the expo marketplace) install only on machines with an untracked `~/.config/dotfiles/personal` marker; without it (e.g. the work machine) only the other plugins install. Add any new MCP or third-party plugin to `PERSONAL_PLUGINS` in the script. Exception: `obsidian@obsidian-skills` (kepano/obsidian-skills) is approved for work machines and installs everywhere. Claude Code writes `/model`, `/plugin`, and `/config` changes straight into the tracked `settings.json`, so review that diff before pulling or committing. No `skills` CLI skills are tracked; if one is installed with `npx skills add -g`, it lives untracked in `~/.agents/`.
- **Bootstrap (Arch)**: `linux/bootstrap/arch-install.sh` installs from `pacman.txt`/`aur.txt`, configures services, then applies the arch-hyprland profile. `quick-setup.sh` is the curl-able entry point; `post-install.sh` finalizes (TPM, Ly, timers). AUR steps drop to `$SUDO_USER` via `run_as_user`, and `import_aur_signing_keys` pre-imports upstream GPG keys so `yay --noconfirm` cannot stall on an unknown key.
- **Bootstrap (macOS)**: `macos/bootstrap/brew-install.sh` installs Homebrew if missing, runs `brew bundle` against `macos/bootstrap/Brewfile`, then applies the macos profile (`CLEAN=1` to pass `--clean`).
- Specs follow the global standard in `shared/agents/.agents/AGENTS.md`: `docs/specs/<feature>.md`, one template, deleted once built and rewritten into docs.

