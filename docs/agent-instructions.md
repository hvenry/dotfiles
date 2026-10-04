# Agent instructions

One global instructions file shared by every coding agent on every machine.

## Why

Claude Code, Codex and opencode each read global instructions from a different path.
Keeping one source and linking it everywhere means a rule changes once and every agent on every machine follows it.

## How it works

- Source: `shared/agents/.agents/AGENTS.md`, stowed to `~/.agents/AGENTS.md`.
- The `agents` package also contains relative symlinks to the source, which stow links into place:
  - `~/.codex/AGENTS.md` for Codex.
  - `~/.config/opencode/AGENTS.md` for opencode.
- Claude Code reads it through the `@~/.agents/AGENTS.md` import in `~/.claude/CLAUDE.md`, from the `claude` package.
- Every profile includes `agents`.

## Key files

- `shared/agents/.agents/AGENTS.md` - the global instructions
- `shared/agents/.codex/AGENTS.md` - symlink for Codex
- `shared/agents/.config/opencode/AGENTS.md` - symlink for opencode
- `shared/claude/.claude/CLAUDE.md` - Claude Code import, plus any Claude-only rules

## Decisions and gotchas

- Symlinks are relative so they resolve inside the repo and through the stowed paths.
- Claude-only rules go below the import in `shared/claude/.claude/CLAUDE.md`, never in the shared file.
- Adding an agent: add a relative symlink at its global instructions path inside `shared/agents/`.

## Related

- [Claude Code](claude-code.md)
- [Stow layout](stow-layout.md)
