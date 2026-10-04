# Dotfiles

Config for every machine I use (personal macOS, work macOS, Arch + Hyprland, headless servers).
Each app is a GNU Stow package under one platform directory, symlinked into `~`.
Profiles pick which packages a machine gets; one installer sets up a new machine and re-syncs an old one.
It is also the single source of the global instructions every coding agent reads.
Stack: Bash, GNU Stow, Homebrew, pacman + yay, zsh, Neovim (Lua), tmux, Hyprland (Lua), Claude Code.

## Commands

```bash
./install-profile.sh --clean macos       # link a profile, removing conflicting configs first
./install-profile.sh macos               # re-link and sync plugins on an existing machine; safe to re-run
stow -d shared nvim                      # link one package from its platform dir
stow -D -d shared nvim                   # unlink one package
./macos/bootstrap/brew-install.sh        # new Mac: Homebrew, Brewfile, then the macos profile
./linux/bootstrap/arch-install.sh        # new Arch box: packages, services, profile, post-install
./scripts/claude-sync.sh                 # install missing Claude Code plugins from settings.json
jq . shared/claude/.claude/settings.json # check settings.json still parses after a merge
```

No test suite or linter yet: verify a change by running the installer for the affected profile.

## Repo map

```
shared/            packages for every machine (zsh, nvim, tmux, ghostty, vscode, herdr, lazygit, lazydocker, claude, agents)
macos/             macOS packages (aerospace, rectangle) and bootstrap/ (Brewfile installer)
linux/             Arch + Hyprland packages and bootstrap/ (pacman/AUR installer, post-install)
profiles/          package lists per machine type
scripts/           claude-sync.sh (plugin manifest installer)
install-profile.sh resolves and stows a profile, seeds machine-local files, installs TPM and plugins
docs/              concept docs; docs/specs/ for planned work
```

## Conventions

- **Edit repo paths, never the symlinks' targets in `~`.** Replacing a symlink with a real file silently forks the config and makes stow fail with "existing target is not owned by stow".
- **A package lives under exactly one platform dir.** The installer takes the first match in `shared/`, `macos/`, `linux/`; a duplicate is never linked.
- **New packages get a `--clean` case in `install-profile.sh`.** Without one, `--clean` leaves the old config in place and stow conflicts.
- **Machine-specific values go in gitignored `local.*` files seeded from `machines/` templates.** Tracking them breaks the other machines' monitors.
- **New MCP or third-party plugins go in `PERSONAL_PLUGINS` in `scripts/claude-sync.sh`.** Otherwise they install on the work machine.
- **Keep `"model": "opus[1m]"` and both sides' keys when merging `settings.json`.** Claude Code rewrites it on `/model`, `/plugin` and `/config`, so conflicts are routine.
- **Edit only `shared/agents/.agents/AGENTS.md` for global agent rules.** The other paths are relative symlinks to it.

## Docs

- Before adding or moving a package, read `docs/stow-layout.md`.
- Before changing profiles or `install-profile.sh`, read `docs/install-profiles.md`.
- Before changing the macOS bootstrap or Brewfile, read `docs/macos-setup.md`.
- Before changing the Arch bootstrap or package lists, read `docs/arch-setup.md`.
- Before changing Hyprland, Waybar or per-machine monitor config, read `docs/hyprland-desktop.md`.
- Before changing Claude Code settings, plugins or the status line, read `docs/claude-code.md`.
- Before changing global agent instructions or adding an agent, read `docs/agent-instructions.md`.
