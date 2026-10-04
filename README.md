# Dotfiles

My config for every machine I use (personal macOS, work macOS, Arch + Hyprland, headless servers), symlinked into `~` with [GNU Stow](https://www.gnu.org/software/stow/).

## Why

One repo keeps the shell, editor, terminal, window manager, and coding-agent setup identical across machines.
Packages are grouped by platform (`shared/`, `macos/`, `linux/`) and profiles pick which ones a machine gets, so one command sets up a new machine and re-running it updates an old one.
It also holds the global instructions every coding agent (Claude Code, Codex, opencode) reads, so they all behave the same everywhere.

## Quick start

```bash
git clone git@github.com:hvenry/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install-profile.sh --clean macos    # or arch-hyprland, or server
```

`--clean` removes existing configs that would block the symlinks.
The installer also installs TPM and the tmux plugins, and any missing Claude Code plugins.

## Profiles

| Profile | Packages |
| --- | --- |
| `macos` | zsh, nvim, tmux, ghostty, lazygit, lazydocker, vscode, aerospace, rectangle, herdr, claude, agents |
| `arch-hyprland` | core tools plus Hyprland, Waybar, Rofi, Mako, Ly, wlogout, GTK theming, systemd timers |
| `server` | zsh, nvim, tmux, claude, agents |

Each name in `profiles/<profile>.txt` resolves by searching `shared/`, `macos/`, then `linux/`.
Install or remove one package by hand from the repo root:

```bash
stow -d shared nvim        # link one package
stow -D -d shared nvim     # unlink it
```

## New machine

### macOS

```bash
./macos/bootstrap/brew-install.sh          # Homebrew (if missing), Brewfile, then the macos profile
CLEAN=1 ./macos/bootstrap/brew-install.sh  # same, passing --clean to the profile
```

Rectangle reads a plist, not a dotfile, so `macos/rectangle` is a snapshot.
On a new machine, Rectangle Settings > Import and pick `macos/rectangle/.config/rectangle/RectangleConfig.json`.
After changing bindings, Export over that repo file and commit it.

### Arch Linux + Hyprland

Run as your normal user; the script escalates with `sudo` itself.

```bash
./linux/bootstrap/arch-install.sh   # pacman + AUR packages, services, arch-hyprland profile, post-install
```

On a bare system, `linux/bootstrap/quick-setup.sh` clones the repo first and then runs the same steps.
Before the first Hyprland boot, set the per-machine files (post-install warns if they are missing):

```bash
cp ~/.config/hypr/machines/laptop.lua ~/.config/hypr/local.lua     # or desktop.*
cp ~/.config/hypr/machines/laptop.conf ~/.config/hypr/local.conf   # hyprlock/hyprpaper
cp ~/.config/waybar/.local.example ~/.config/waybar/.local         # then set PRIMARY_MONITOR
```

### Personal vs work machines

Personal-only Claude Code plugins (MCP plugins and third-party marketplaces) install only on machines with this marker:

```bash
mkdir -p ~/.config/dotfiles && touch ~/.config/dotfiles/personal
```

Leave it off work machines.
`scripts/claude-sync.sh` holds the personal list and reruns safely at any time.

## Updating a machine

```bash
git -C ~/dotfiles pull --autostash
./install-profile.sh macos   # re-link new files and install missing plugins; safe to re-run
```

Conflicts usually land in `shared/claude/.claude/settings.json`, because Claude Code writes `/model`, `/plugin`, and `/config` changes into it.
Keep keys from both sides, then check it with `jq . shared/claude/.claude/settings.json`.

If stow reports `existing target is not owned by stow`, a real file sits where a symlink should go.
Diff it against the repo version, then move it aside and re-run.

## Agent instructions

`shared/agents/.agents/AGENTS.md` is the single source of global rules for every coding agent.
The `agents` package links it to `~/.agents/AGENTS.md`, `~/.codex/AGENTS.md`, and `~/.config/opencode/AGENTS.md`; Claude Code imports it from `~/.claude/CLAUDE.md`.
Edit only the source file.

## Docs

- [CLAUDE.md](CLAUDE.md) - repo layout, conventions, and how packages and profiles fit together
- [Global agent instructions](shared/agents/.agents/AGENTS.md) - rules every coding agent follows
- [Hyprland machine configs](linux/hyprland/.config/hypr/machines/README.md) - per-machine monitor setup

## Status

Active, used daily on every machine.
VS Code config stows to `~/.config/Code/User/`, which is only wired up on Linux; macOS VS Code reads `~/Library/Application Support/Code/User/`.
