---
name: portfolio-project
description: Use when the user wants to add the current project/repo to their portfolio site, write a portfolio entry or project writeup, or generate the markdown for henryvendittelli.com/projects. Triggers on "add this to my portfolio", "write a portfolio entry", "portfolio writeup", "project writeup for the site".
---

# Portfolio project entry

Produce a portfolio entry for henryvendittelli.com from the repo you are
currently in. The portfolio renders `content/projects/*.md` files; your job is
to gather the facts, draft the writeup, and write the file.

**Portfolio repo:** `~/dev/portfolio`
(if it is missing, print the file content for the user to paste instead)

## 1. Gather evidence from the repo before asking anything

Investigate before asking anything. Read, in roughly this order:

- `AGENTS.md`: the overview, stack, conventions, and the index of every doc and spec
- Every concept doc in `docs/` (not `docs/specs/`): **the source of truth for how
  each part works.** Mechanisms, numbers, and design decisions in the writeup
  come from here, especially each doc's "Decisions and gotchas" section, which
  is the raw material for "What I tried"
- `docs/specs/` and `docs/specs/roadmap.md`: planned work only, the raw
  material for "Where it stops". Never describe a spec as built
- `README.md`: the public framing, features, and headline results
- `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod`: real dependencies
- `docker-compose.yml`, `.github/workflows/`, infra config: deployment reality
- Source entry points and directory names: architecture
- `git log --oneline | head -30` and `git log -1 --format=%cd`: activity and recency
- `git remote get-url origin`: the GitHub URL
- Any existing screenshots (`docs/`, `public/`, `assets/`, `.github/`)

Derive as much of the schema as you can from that. Only ask the user about
what you genuinely cannot determine (see step 3).

## 2. The schema

Filename is the URL slug: lowercase, hyphenated, `.md` (e.g. `clear-rag.md`
→ `/projects/clear-rag`). Keep it short and stable, because it is a public URL.

```yaml
---
# Required
title: "RAG System" # 1-2 words, shown on cards and in filters
bodyTitle: "Local RAG System" # full name, the page heading
summary: "One sentence, 15-25 words, what it does + core stack."
technologies: # see the canonical list below
  - "Python"
  - "Langchain"
order: 4 # sort position on the index, lower = earlier

# Optional
github: "https://github.com/hvenry/repo"
live: "https://example.com" # deployed URL
youtube: "https://youtu.be/..." # demo video; Loom links work too
image: "project_name.png" # public/assets/images/projects/
imageLight: "project_name_light.png" # optional light-mode variant
draft: true # hidden in production, visible in dev
---
```

**No `year` or `role` fields, and no team size or date range in the
Overview list.** The site does not show them; if an existing entry still has
them, remove them.

**Technology names are matched against the icon registry**: the `techIcons` map
in the portfolio's `components/TechBadge.tsx`. Read it for the canonical
spelling and prefer a key that already exists over a variant of it, so
`Next.js` not `NextJS` and `Node.js` not `Node`. A name with no entry still
renders, falling back to a generic code glyph, so an unregistered technology
never blocks the entry.

**Which technologies to list.** I trim every list by the same rules, so apply
them before I have to:

- **List:** languages, frameworks, datastores, infrastructure and hosted
  services (cloud, CI/CD, third-party APIs), and test frameworks (pytest,
  Vitest, Playwright).
- **Leave out:** linters, formatters and git hooks (ESLint, Prettier, Ruff,
  mypy, Husky); small utility, icon and font libraries (Lucide, Geist, drei,
  react-icons); optional providers the project merely supports (OpenAI and
  Anthropic beside a local model); and anything that belongs to another
  project. A homelab that runs an app lists the services it hosts, not that
  app's stack, which goes in the app's own writeup.
- **Icons:** for every listed technology without a `techIcons` entry, search
  `react-icons` (`node -e 'console.log(Object.keys(require("react-icons/si")).filter(k=>/name/i.test(k)))'`)
  and propose an import plus a map line. When no brand icon exists, propose a
  fitting generic one (`GiWarpPipe` for Gluetun, `MdSubtitles` for Bazarr) and
  say it is a stand-in. Verify each export exists in the installed version; a
  newer icon may need a `react-icons` upgrade.

## 3. Ask only for what the repo cannot tell you

Batch these into one question, with your best guess pre-filled:

- **Live URL**: deployed anywhere?
- **Demo video**: YouTube/Loom link?
- **Preview image**: do they have one, or should it be captured (see step 5)?
- **What was the hard or interesting part?** The one question worth asking
  even when you think you can infer it. It is what the writeup should be built
  around, and the repo often hides it.

## 4. Write the body

**Read `content/projects/_TEMPLATE.md` and two or three finished entries
(`clear-rag.md`, `hvenrylab.md`, `simple-shell.md`) in the portfolio repo before
drafting.** The template is the shape; the entries show my voice. Match them,
not this description of them.

**The personal parts are mine.** Draft the factual sections (Overview, how it
works, What I tried, Where it stops). For the opening and the closing, leave
the template's visible `**TODO (Henry):**` lines with a few bullet notes of
raw material underneath (the motivation the repo or I gave you, dates,
credits), and create the entry with `draft: true` so it cannot ship before I
write them. Never use an HTML comment as a placeholder: the renderer prints
comments as visible text.

### Goal: understood in ten seconds, explained in two minutes

A reader should know what the project is and how it works from the top of the
page without scrolling. Everything below that is optional depth. Simplify:
pick the one or two ideas that make the project interesting and cut the rest.

**Length: 500-900 words of prose** (tables and code blocks excluded). Under 500
only when there is genuinely less to say. Over 900 means it is turning into a
design doc; cut whole sections rather than trimming sentences.

### The shape

```markdown
(Henry: 1-3 short paragraphs, why it exists and the interesting problem)

## <Project> Overview

- What it does, in one line
- The core mechanism, in one line
- **Where it runs:** where it runs or is live

(one mermaid diagram of the architecture or main flow)

## How it works   <- renamed to what it contains

One sentence of setup, then 3-6 short bullets. Use `###` for genuinely
separate subsystems.

## What I tried

- **Approach:** what happened and why it was kept or dropped

## Where it stops and next steps

- 2-4 bullets: what it does not do, what the next version needs

(Henry: a closing paragraph with no heading: origin, credits, how it feels)
```

- **Short lists over paragraphs** in the sections you draft. Each bullet is one
  idea in one or two lines, starts with `-` (never `*`: mixing markers splits
  a list in two) and has no trailing period.
- **Lead with the problem**, not a feature list (globe.expert: country borders
  are flat polygons and a globe is a sphere).
- **"What I tried" holds design decisions and dead ends**: alternatives
  measured, approaches abandoned, bugs that changed the design. Skip it only
  if nothing was tried.
- Rename "How it works" to something specific (`## The loop`,
  `## How the globe does its magic`) when that reads better.
- Write the project's own name in inline code in prose (`clear-rag`,
  `globe.expert`).
- **Link other writeups relatively** (`[homelab](/projects/hvenrylab)`), never
  with `https://henryvendittelli.com/...`: a full URL renders as an external
  link and opens a new tab.

### The full markdown toolkit

The renderer does far more than plain text. Use these when they explain
something a bullet cannot: one or two diagrams per entry, tables wherever the
facts are enumerable, at most one or two code blocks, a formula only when it is
the point.

**Mermaid diagrams.** A fenced block tagged `mermaid` becomes a rendered
diagram, themed to match the site and re-rendered when the theme flips. Every
mermaid type works: `flowchart`, `sequenceDiagram`, `stateDiagram-v2`,
`erDiagram`, `gantt`. Reach for one whenever describing a pipeline, a process
interaction, or a decision. The simple shell entry uses three, and they carry
more than the prose around them:

    ```mermaid
    flowchart LR
      A["prompt<br/>read_line()"] --> B["split_line()"]
      B --> C{"builtin?"}
      C -->|yes| D["run in the shell itself"]
      C -->|no| E["fork + exec + waitpid"]
    ```

Quote every node label (`A["text"]`) so punctuation and parentheses are safe,
and use `<br/>` for line breaks inside a label. A long pipeline crushed into one
line reads badly; wrap it into rows with subgraphs (`direction LR` on top,
`direction RL` below) linked as whole subgraphs (`top --> bottom`). Linking a
node inside a subgraph to one outside makes Mermaid ignore the subgraph's
direction. `ootd.md` has a working example.

**LaTeX math.** Inline with `$...$`, display with `$$...$$` on its own lines,
rendered by KaTeX. Use it for real mathematics: projections, scoring formulas,
complexity bounds. The globe entry derives its spherical coordinate conversions
this way. Do not decorate prose with it.

**Tables** for enumerable facts: hardware and software specs, settings and
their effects, commands and what they do, options and tradeoffs, benchmark
results. Use as many as earn their place.

**Code blocks** with a language tag get syntax highlighting and a copy button.
Keep them minimal: a signature, a struct, at most ten key lines, never a whole
file.

Also available: `##`/`###` headings, inline `code`, **bold**, _italics_, links,
blockquotes, and horizontal rules.

### Voice

- First person, reflective where it is earned: "one detail took me a while to
  appreciate", "the best thing this project taught me". Humour, asides and
  exclamations belong in my parts (the opening and closing); keep your
  sections plain and factual, and do not imitate my jokes.
- **Never invent capabilities, metrics, or outcomes.** Every mechanism, number,
  and count must trace to a `docs/` concept doc, the code, a results file, or
  the user, never to memory or an older version of the entry. Where docs and
  code disagree, the code wins; say so to the user. If you want to describe a
  mechanism you cannot verify, read the source until you can, or ask.
- Explain, do not sell. No "cutting-edge", "seamless", "leveraged", "robust
  solution", "powerful", "blazing fast".
- **Punctuation.** Join clauses with a period, a comma, a colon, or
  parentheses. Write each sentence so it does not need a dash. The user reads
  every entry aloud as a first editing pass, and em dashes (`—`) break that
  read and mark the text as machine-written.

## 5. Preview image: prefer the project's OG image

**Target: 1200x630 (the Open Graph standard).** Portfolio cards render at
exactly that ratio, so an OG image fits with no letterboxing, and the card
then matches what people already see when the project is shared anywhere else.

The `image` (the dark one) also becomes the project's share card: the site
generates `/projects/<slug>/opengraph-image` from it, inside the home card's
frame with the project URL underneath. Pick a preview that still reads at
link-preview size, because it is what people see when the writeup is shared.

Look for an existing OG image first, in this order:

1. `docs/images/` in the project repo: the README standard keeps screenshots
   there, often as a dark and light pair (e.g. `dashboard.png` and
   `dashboard-light.png`)
2. `app/opengraph-image.{png,jpg}` or `app/**/opengraph-image.*` (Next.js
   file convention). Also check for `opengraph-image.tsx` (generated at
   runtime; render the deployed URL to capture it)
3. `public/og*.{png,jpg}`, `public/images/og*`, `static/og*`, `assets/og*`
4. The live site's meta tag, if deployed:
   `curl -s <url> | grep -oE '<meta property="og:image"[^>]*>'` then download it

If none exists, capture one: drive a headless browser at a **1200x630** viewport
against the running app (or a representative screen) and screenshot. For a CLI
project, a terminal screenshot cropped to 1200x630 works.

- PNG for UI and diagrams, JPG for photos, under ~500KB.
- Filename: `<slug>_project.png` or a descriptive name; copy it into the
  portfolio's `public/assets/images/projects/`.
- Off-ratio images letterbox against the theme background (black in dark, white
  in light). Acceptable, but 1200x630 is cleanest.
- No image is fine. The card and page simply render without one.
- **Check what the image shows.** The site is public: crop or recapture
  anything with private details (IP addresses, hostnames, emails, tokens,
  personal data). Prefer a project's public screenshots over a private repo's.

### Light and dark variants

**If the project has a light and a dark theme, produce both previews.** The
portfolio swaps them with its own theme toggle, so a light-themed screenshot
never sits on a black card.

1. Capture the same view twice. Force each theme rather than trusting the
   default. With a headless browser, `colorScheme: "dark"` / `"light"` on the
   context, or set whatever attribute/class the project uses (e.g.
   `document.documentElement.setAttribute("data-theme", "light")`) before the
   screenshot. If the project ships two OG images already, take both.
2. Name them as a pair and copy both into
   `public/assets/images/projects/`:
   - `<slug>_og.png`: dark
   - `<slug>_og_light.png`: light
3. Wire both into the frontmatter:
   ```yaml
   image: "<slug>_og.png" # dark (also the fallback)
   imageLight: "<slug>_og_light.png" # light
   ```

`image` alone is fine and renders in both themes. `imageLight` is purely
additive. Omit it when the project has only one look. The swap is CSS-only
(`.theme-dark-only` / `.theme-light-only` in `app/globals.css`), so it is
correct before hydration and needs no client JS.

If the project has no OG image at all, mention that adding one benefits the
project itself (link previews in Slack, iMessage, social), and offer to create
one in the same visual language.

## 6. Write the file and verify

**First check whether an entry already exists** for this project
(`content/projects/<slug>.md`, or grep the directory for the repo's GitHub URL).

### Updating an existing entry

Treat the existing frontmatter as the source of truth for anything the repo
cannot contradict:

- **Preserve `order` and image filenames** unless
  the user asks otherwise or the repo proves them wrong. Never renumber `order`
  on an update, because it silently reorders the whole index.
- Rewrite `summary` and the body when the project has moved on; refresh
  `technologies` against the current dependencies.
- **Re-verify every claim in the existing body against the current docs and
  code** before keeping it: counts, metrics, settings, diagrams, and
  mechanism descriptions drift as the project changes. Fix or cut what no
  longer holds, and list what you corrected for the user.
- If the existing entry breaks the shape or length rules in step 4, rewrite it
  to them; do not preserve structure, only the frontmatter fields above.
- Do not re-ask the questions in step 3 for values already filled in. Ask only
  about genuinely new facts, and mention what you preserved.

### Creating a new entry

1. Write to `~/dev/portfolio/content/projects/<slug>.md`
2. Copy any image into `public/assets/images/projects/` (skip if you are
   already working inside the portfolio repo)
3. Set `order` to one past the current highest, unless the user wants it ranked
   higher. Check the existing files
4. Set `draft: true`, so the entry shows only in `pnpm dev` until I have
   written my TODO parts and removed it
5. Tell the user to run the portfolio dev server and check `/projects/<slug>`

**Do not commit or push.** I handle all git operations myself.

If the portfolio repo is not on this machine, output the complete file content
in a code block plus the target path, and note where the image should go.
