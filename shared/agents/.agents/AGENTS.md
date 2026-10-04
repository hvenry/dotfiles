# Global agent instructions

Shared by every coding agent on every machine. Source of truth:
`~/dotfiles/shared/agents/.agents/AGENTS.md` (stowed to `~/.agents/AGENTS.md`).
Loaded by Claude Code (`@` import in `~/.claude/CLAUDE.md`), Codex (`~/.codex/AGENTS.md`),
and opencode (`~/.config/opencode/AGENTS.md`).

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
- Bug fixes: reproduce first, as close to how the user hit it as possible (E2E where you can),
  and capture the reproduction as a failing test before changing code. The fix is done when that
  test passes; it stays in the suite as a regression test.
- When end-to-end testing always be picky about the UI and pixel perfection.
- Always hold the same high standard engineering excellence: lint, test, and document everything. Do not skip any of these steps.

## Project instructions and docs

Every repo has four kinds of Markdown, each with one fixed template so any repo reads the same:
- **`AGENTS.md`** at the repo root: how to work in the repo, and the index of everything below.
- **Docs** (`docs/*.md`) describe what is built. Reference material, kept true to the code.
- **Specs** (`docs/specs/*.md`) describe what is planned. Working documents that disappear once built.
- **`README.md`** at the repo root: the front page for people arriving at the repo.

### AGENTS.md

- `CLAUDE.md` is a one-line `@AGENTS.md` import, plus Claude-only rules if any.
- When creating or initializing project instructions (e.g. Claude Code's `/init`), read the code first, then write
  `AGENTS.md` from the template below, a doc per real concept (data flow, auth, database, CI/CD, styling...),
  and `CLAUDE.md` as the import. Architecture detail goes in docs, not in `AGENTS.md`.
- If a repo has a full `CLAUDE.md` and no `AGENTS.md`, migrate it the same way:
  split its content into `AGENTS.md` and `docs/`, verify every claim against the code, and drop what is stale.
- Keep it short (~60 lines). Use exactly these headings, in this order; drop Planned if there are no specs.
- Commands: one per line, each with a comment. Never `a | b | c` shorthand; it reads like a shell pipe.
  Always include how to run a single test.
- No test suite yet is a known gap, not a state: say so under Commands and link the spec that adds one.
- No version numbers in prose; versions live in the package manifest. The only exception is a pin that is
  itself a rule, stated with its reason.
- Conventions are rules with their reason (what breaks without it), not descriptions of the code.
- Docs triggers follow the order of work in the repo; once there are more than ~10, group them under short
  labels. Planned triggers are alphabetical, because build order lives only in `docs/specs/roadmap.md`.

````markdown
# <Project>

<What it is and why, 2-4 sentences, one per line.>
Stack: <languages, frameworks, services>.

## Commands
```bash
pnpm dev                          # one command per line, each with a comment
pnpm test path/to/file.test.ts    # how to run a single test
```

## Repo map
```
src/<area>/   one-line role
```

## Conventions
- **<Rule>.** Why, or what breaks without it.

## Docs
- Before <task>, read `docs/<concept>.md`.

## Planned
Build order: `docs/specs/roadmap.md`.
- Before implementing <feature>, read `docs/specs/<feature>.md`.
````

### README

- `README.md` is for people arriving at the repo (GitHub, a recruiter, future you):
  what it is, what it does, how to see it running, and where to read more.
- Keep it short (~100 lines). How a part works belongs in a `docs/` concept doc, linked from the README.
- Never duplicate a doc or `AGENTS.md`: summarise in a sentence and link. Quick start is the minimum
  to see it running, not the full command list.
- Link only the docs a newcomer needs (~5), not every doc; `AGENTS.md` is the full index.
- Images use Markdown image syntax (`![alt](path)`), never HTML `<img>`/`<picture>`, and point to either
  a file in `docs/images/` or a live URL (e.g. the deployed site's Open Graph image). Never reference other
  repo paths (`public/`, `app/`, `screenshots/`) or GitHub-only suffixes like `?raw=true`, so images render
  on GitHub and anywhere `docs/` is mirrored (e.g. an Obsidian vault).
- Every README follows this template (drop Results or Status if empty):

````markdown
# <Project>

<One sentence: what it is.>

<Screenshot, demo GIF, or live link.>

## Features
3-6 bullets: what it does and what makes it different.

## Results
Headline numbers or outcomes, if the project has them (e.g. benchmark tables).

## Quick start
```bash
<the minimum to see it running>
```

## Docs
- [Concept](docs/concept.md) - one line

## Status
Active, paused, or archived, plus anything a visitor should know (e.g. "local only").
````

### Docs

- Docs live in `docs/`, one concept per file, named in lowercase kebab-case (`docs/auth-flow.md`).
  Only `README.md`, `AGENTS.md`, and `CLAUDE.md` keep tool-mandated caps names.
- Overviews, not long form: aim for ~100 lines max. If a doc outgrows that, split it into
  concept docs and link them under Related.
- Reference code by path; do not paste large code blocks.
- Update the doc in the same change as the code it describes.
- The repo's `AGENTS.md` is the docs index: list each doc with a when-to-read trigger
  (e.g. "Before changing auth, read `docs/auth-flow.md`") rather than importing it.
- Never describe unbuilt work in a doc; that is a spec.
- No decisions log (`decisions.md`, ADR folders): a decision goes in the Decisions and gotchas section
  of the concept doc it affects.
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

### Specs

- Specs live in `docs/specs/`, one feature per file, lowercase kebab-case, no numeric prefixes
  (`docs/specs/wear-log.md`). Never use `TODO-` prefixes, `docs/features/`, top-level `specs/`,
  or tool-specific planning folders; planning tools and plugins write their specs and plans here,
  in this template.
- Build order lives in one place, `docs/specs/roadmap.md`: an ordered list of spec links with one
  line each. Create it once a repo has more than one spec; reorder lines, never rename files.
- Aim for ~150 lines max. If a spec outgrows that, split the feature into smaller specs.
- Keep `Status` current (`draft` -> `ready` -> `in progress`) and tick Tasks as they land.
- List specs in the repo's `AGENTS.md` under a separate "Planned" heading with a trigger
  (e.g. "Before implementing the wear log, read `docs/specs/wear-log.md`").
- Small todos don't get a spec; a spec is for work that needs a design before code.
- Completing a spec, in the same change as the code that meets its Done when:
  1. Rewrite what was built into docs using the docs template: new concept docs or updates to
     existing ones. Describe the result, not the plan; carry lasting choices into Decisions and gotchas.
  2. Delete the spec (git history keeps it) and remove it from `roadmap.md` and the "Planned" index.
  3. Add or update the docs' triggers in `AGENTS.md`.
- Every spec follows this template (drop Open questions if empty):

```markdown
# <Feature>

**Status:** draft | ready | in progress

<One sentence: what this adds, from the user's point of view.>

## Goal
The problem it solves and the outcome. How we will know it worked.

## Scope
- In: what this spec covers
- Out: explicit non-goals

## Design
The approach: data model, flow, UI, APIs. A Mermaid diagram if it helps.
Link existing docs for context instead of repeating them.

## Tasks
- [ ] Ordered steps, each one verifiable on its own

## Done when
- [ ] Testable acceptance criteria, including docs written and this spec removed

## Open questions
- Unresolved decisions, each with an owner or a default.

## Related
- [Concept doc](../concept.md)
- [Other spec](other-feature.md)
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
