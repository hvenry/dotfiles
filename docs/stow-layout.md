# Stow layout

How the repo is split into GNU Stow packages and how each one maps into `~`.

## Why

Every app's config lives in the repo but must appear at its native path in `~`.
Stow does that with symlinks, so editing the repo edits the live config and `git pull` updates every machine.
Grouping packages by platform keeps macOS-only and Linux-only config off machines that cannot use it.

## How it works

- Three platform dirs: `shared/` (every machine), `macos/`, `linux/`.
- Each subdirectory is one package whose contents mirror `~`:
  - `<platform>/<pkg>/.config/<pkg>/...` for `~/.config` targets (e.g. `shared/nvim/.config/nvim/init.lua`).
  - `<platform>/<pkg>/<dotfile>` for home-root files (e.g. `shared/zsh/.zshrc`, `macos/aerospace/.aerospace.toml`).
  - `shared/claude/.claude/...` targets `~/.claude/`, since Claude Code does not use `~/.config`.
- `.stowrc` sets `--target=~`, so `stow -d <platform> <pkg>` works from the repo root for any platform dir.
- `--no-folding` makes stow link individual files, not whole directories, so apps can write their own state (logs, plugins) next to the tracked files without it landing in the repo.

## Tech

- GNU Stow, driven by `.stowrc` and `install-profile.sh`.

## Key files

- `.stowrc` - stow defaults (`--no-folding`, `--verbose`, `--restow`, `--target=~`)
- `.gitignore` - keeps TPM plugins and tool state out of the repo
- `install-profile.sh` - resolves package names to platform dirs and stows them

## Decisions and gotchas

- "existing target is not owned by stow" means a real file sits where a symlink should go.
  Diff it against the repo version before moving it aside, then re-run.
- `--restow` makes every install idempotent: stale links are removed and recreated.
- Some apps read a non-XDG path on macOS, so the stowed `~/.config` file is ignored there:
  - VS Code reads `~/Library/Application Support/Code/User/`.
  - lazygit reads `~/Library/Application Support/lazygit/` (check with `lazygit --print-config-dir`).
- `linux/ly/config.ini` sits at the package root, so stowing `ly` links it to `~/config.ini`; Ly reads `/etc/ly/config.ini`.
  `--clean` removes the stray `~/config.ini` link.

## Related

- [Install profiles](install-profiles.md)
