# Claude Code

How the `claude` package tracks Claude Code settings and rebuilds plugins on each machine.

## Why

Claude Code settings, the status line and plugins should match on every machine, but installed plugins are state, not files.
Tracking the manifest and syncing from it gives the same setup everywhere, while keeping personal MCP plugins off the work machine.

## How it works

- `shared/claude/.claude/` stows to `~/.claude/`: `settings.json`, `statusline.sh`, `CLAUDE.md` and hand-written skills under `skills/`.
- `settings.json` is the plugin manifest: `enabledPlugins` and `extraKnownMarketplaces`.
- `scripts/claude-sync.sh` runs whenever a profile includes `claude`:
  1. Adds any missing GitHub marketplaces.
  2. Installs any enabled plugin that is not installed.
  3. Skips `PERSONAL_PLUGINS` and `PERSONAL_MARKETPLACES` unless `~/.config/dotfiles/personal` exists.
- Without `claude` or `jq` on `PATH` it exits cleanly, so a server without Claude Code still installs.

## Tech

- Claude Code CLI (`claude plugin`), jq, Bash.

## Key files

- `shared/claude/.claude/settings.json` - settings and plugin manifest
- `shared/claude/.claude/statusline.sh` - status line (directory, model, context use, lines changed)
- `shared/claude/.claude/CLAUDE.md` - imports the global agent instructions
- `shared/claude/.claude/skills/` - tracked hand-written skills
- `scripts/claude-sync.sh` - plugin installer

## Decisions and gotchas

- Personal-only means the MCP plugins (Notion, Figma, Railway) and the Expo marketplace.
  On a machine without the marker they stay uninstalled, and `/plugin` shows them as "not cached".
- `obsidian@obsidian-skills` is approved for work machines and installs everywhere.
- Claude Code writes `/model`, `/plugin` and `/config` changes straight into the tracked `settings.json`.
  Review that diff before committing or pulling; on conflicts keep both sides' keys and `"model": "opus[1m]"`, then run `jq .` on the file.
- `npx skills add -g` skills are not tracked; they live in `~/.agents/` on the machine that installed them.

## Related

- [Agent instructions](agent-instructions.md)
- [Install profiles](install-profiles.md)
