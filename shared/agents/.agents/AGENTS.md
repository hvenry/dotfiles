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
- Project instructions live in `AGENTS.md` at the repo root, so every agent reads them.
  `CLAUDE.md` is a one-line `@AGENTS.md` import, plus Claude-only rules if any.
- When creating or initializing project instructions (e.g. Claude Code's `/init`), read the code first, then write:
  - `AGENTS.md`, kept short (~60 lines): one-paragraph overview, commands, repo map, repo conventions, and the docs index.
  - `docs/<concept>.md` for each real concept (data flow, auth, database, CI/CD, styling...), following Project docs below.
    Architecture detail goes in these docs, not in `AGENTS.md`.
  - `CLAUDE.md` as the one-line import.
- If a repo has a full `CLAUDE.md` and no `AGENTS.md`, migrate it the same way:
  split its content into `AGENTS.md` and `docs/`, verify every claim against the code, and drop what is stale.

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

## Project docs

- Docs live in `docs/`, one concept per file, named in lowercase kebab-case (`docs/auth-flow.md`).
  Only `README.md`, `AGENTS.md`, and `CLAUDE.md` keep tool-mandated caps names.
- Overviews, not long form: aim for ~100 lines max. If a doc outgrows that, split it into
  concept docs and link them under Related.
- Reference code by path; do not paste large code blocks.
- Update the doc in the same change as the code it describes.
- The repo's `AGENTS.md` is the docs index: list each doc with a when-to-read trigger
  (e.g. "Before changing auth, read `docs/auth-flow.md`") rather than importing it.
- Plans and specs are working documents, not reference docs, and are exempt from this format.
- Every doc follows this template (drop Tech or Decisions and gotchas if empty):

```markdown
# <Concept>

<One sentence: what this is.>

## Why
The problem it solves and its impact. What breaks or gets harder without it.

## How it works
Short overview of the flow or design. A Mermaid diagram if it helps.

## Tech
Libraries, services, and protocols involved.

## Key files
- `path/to/file.ts` - one-line role

## Decisions and gotchas
Non-obvious choices and why, known limits.

## Related
- [Other concept](other-concept.md)
```

## My dotfiles

- Every machine (personal macOS, work macOS, Arch) has my dotfiles repo at `~/dotfiles`, linked into `~` with GNU Stow.
- Files in `~` like `~/.zshrc` or `~/.claude/settings.json` are symlinks into the repo. Edit the repo path, never replace the symlink.
- Before changing anything there, read `~/dotfiles/CLAUDE.md` for the layout and conventions.
- Update a machine: `git -C ~/dotfiles pull --autostash`, then from `~/dotfiles` run `./install-profile.sh <profile>` (`macos`, `arch-hyprland`, or `server`). It re-links new files and installs missing Claude plugins. Safe to re-run.
- Pull or merge conflicts usually hit `shared/claude/.claude/settings.json`, because Claude Code writes `/model`, `/plugin`, and `/config` changes into it. Keep the keys from both sides, keep `"model": "opus[1m]"`, then check it parses with `jq . <file>`.
- Stow error "existing target is not owned by stow": a real file sits where a symlink should go. Show me the diff against the repo version before moving or deleting it.
- Work machine: no `~/.config/dotfiles/personal` marker. Never install MCP or third-party plugins or skills there, except the approved `obsidian@obsidian-skills` plugin.

## Time estimates

- Never estimate in calendar time (days, weeks, sprints, "multi-week").
- Size work by scope instead: number of steps, files, or components.
- Never pad plans with phases, milestones, or buffers I did not ask for.
