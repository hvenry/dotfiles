# Global agent instructions

Shared by every coding agent on every machine. Source of truth:
`~/dotfiles/shared/agents/.agents/AGENTS.md` (stowed to `~/.agents/AGENTS.md`).
Loaded by Claude Code (`@` import in `~/.claude/CLAUDE.md`), Codex (`~/.codex/AGENTS.md`),
opencode (`~/.config/opencode/AGENTS.md`), and Gemini CLI (`~/.gemini/GEMINI.md`).

## About me

- Lead CIAM software engineer at a Canadian insurance company.
- Born 2003. Queen's University, Computing, class of 2025. Full-time software engineer.
- Mostly TypeScript and Python. I like exploring languages and picking the right
  tool for the job, so suggest something else when it fits better.
- Experienced: skip beginner explanations unless I ask.

## How I work

- I handle git commits and merges. Leave changes staged and uncommitted unless I
  explicitly ask for a commit.
- I rapidly prototype with AI agents. A feature is usually one session, a project is
  usually an afternoon to a few days.

## General Guidelines

- Terse. Lead with the answer, then only the detail I need.
- Prefer short lists and code snippets over paragraphs.
- Never use the em dash "—". Use a plain dash "-" instead.
- When writing commit messages, NEVER auto-add your agent name as co-author.
- When writing or editing long Markdown files, put each full sentence on its own line.
- Do not end with a menu of optional extras. Three suggested next steps at most.

## Programming

- When making technical decisions, do not give much weight to development cost, instead focus on long-term maintainability, performance, scalability, and correctness.
- When doing a bug fix, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it.
- When end-to-end testing always be picky about the UI and pixel perfection.
- Always hold the same high standard engineering excellence: lint, test, and document everything. Do not skip any of these steps.

## My dotfiles

- Every machine (personal macOS, work macOS, Arch) has my dotfiles repo at `~/dotfiles`, linked into `~` with GNU Stow.
- Files in `~` like `~/.zshrc` or `~/.claude/settings.json` are symlinks into the repo. Edit the repo path, never replace the symlink.
- Before changing anything there, read `~/dotfiles/CLAUDE.md` for the layout and conventions.
- Update a machine: `git -C ~/dotfiles pull --autostash`, then from `~/dotfiles` run `./install-profile.sh <profile>` (`macos`, `arch-hyprland`, or `server`). It re-links new files and installs missing Claude plugins. Safe to re-run.
- Pull or merge conflicts usually hit `shared/claude/.claude/settings.json`, because Claude Code writes `/model`, `/plugin`, and `/config` changes into it. Keep the keys from both sides, keep `"model": "opus[1m]"`, then check it parses with `jq . <file>`.
- Stow error "existing target is not owned by stow": a real file sits where a symlink should go. Show me the diff against the repo version before moving or deleting it.
- Work machine: no `~/.config/dotfiles/personal` marker. Never install MCP or third-party plugins or skills there.

## Time estimates

- Never estimate in calendar time (days, weeks, sprints, "multi-week").
- Size work by scope instead: number of steps, files, or components.
- Never pad plans with phases, milestones, or buffers I did not ask for.
