---
name: portfolio-project
description: Use when the user wants to add the current project/repo to their portfolio site, write a portfolio entry or project writeup, or generate the markdown for henryvendittelli.com/projects. Triggers on "add this to my portfolio", "write a portfolio entry", "portfolio writeup", "project writeup for the site".
---

# Portfolio project entry

Produce a portfolio entry for henryvendittelli.com from the repo you are
currently in. The portfolio renders `content/projects/*.md` files; your job is
to gather the facts, draft the writeup, and write the file.

**Portfolio repo:** `/Users/hvenry/dev/henry-vendittelli-portfolio`
(if it is missing, print the file content for the user to paste instead)

## 1. Gather evidence from the repo before asking anything

Investigate before asking anything. Read, in roughly this order:

- `README.md`: the single best source for what it does and why
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
year: "2026" # or "2024 - 2025"
role: "Solo project" # or "Team of 5 - backend + ML"
featured: 1 # 1-3 = position on the home page grid
draft: true # hidden in production, visible in dev
---
```

**Technology names are matched against the icon registry**: the `techIcons` map
in the portfolio's `components/TechBadge.tsx`. Read it for the canonical
spelling and prefer a key that already exists over a variant of it, so
`Next.js` not `NextJS` and `Node.js` not `Node`. A name with no entry still
renders, falling back to a generic code glyph, so an unregistered technology
never blocks the entry. When a project's defining technology has no icon, say
so: adding one is an import plus a line in that map, from `react-icons`.

List ALL technologies present in the project (programming languages, ci/cd, cloud, third part, b2b, etc)! Do not leave out any. I will manually refine what should actually be shown.

## 3. Ask only for what the repo cannot tell you

Batch these into one question, with your best guess pre-filled:

- **Live URL**: deployed anywhere?
- **Demo video**: YouTube/Loom link?
- **Role**: solo or team? What was your part? (never guess this)
- **Year**: infer from git history, but confirm it
- **Preview image**: do they have one, or should it be captured (see step 5)?
- **What was the hard or interesting part?** The one question worth asking
  even when you think you can infer it. It is what the writeup should be built
  around, and the repo often hides it.

## 4. Write the body

**Review two existing entries before drafting.** They are the standard to match,
not this description of them:
`content/projects/globe-expert.md` and `content/projects/simple-shell.md`
in the portfolio repo.

### Depth

Write until the interesting part is actually explained, then stop. For a
project with real engineering in it that is usually **400-1200 words**; less
only when there is genuinely less to say. A thin summary of a deep project is
the failure mode to avoid. Someone who clicked into a writeup wants the
mechanism, not the elevator pitch. The card summary already did the pitch.

Lead with **the interesting problem**, not a feature list. Both reference
entries open on a difficulty:

- globe.expert: country borders are flat polygons and a globe is a sphere, so
  every fill, border, and click has to cross between the two without drifting

Then explain how it was solved, **in prose**. Bullets are for genuinely
enumerable things; paragraphs carry explanation. A column of bullets reads as
notes, not as writing.

### The full markdown toolkit

The renderer does far more than plain text. Use these when they explain
something prose cannot:

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
and use `<br/>` for line breaks inside a label.

**LaTeX math.** Inline with `$...$`, display with `$$...$$` on its own lines,
rendered by KaTeX. Use it for real mathematics: projections, scoring formulas,
complexity bounds. The globe entry derives its spherical coordinate conversions
this way. Do not decorate prose with it.

**Tables** for enumerable facts: settings and their effects, commands and what
they do, options and tradeoffs.

**Code blocks** with a language tag get syntax highlighting and a copy button.
Keep them tight: a signature, a struct, five to ten key lines, never a whole
file.

Also available: `##`/`###` headings, inline `code`, **bold**, _italics_, links,
blockquotes, and horizontal rules.

### Sections

There is no fixed outline. Name sections after what the project actually
contains. The reference entries use `## Game modes`, `## From flat geometry to
a sphere`, `## Architecture`, `## The loop`, `## fork, exec, wait`,
`## Why cd can't be a program`, `## Where it stops`, `## Background`. Use `###`
to break a long section into parts.

Two are worth including whenever they apply:

- **Limitations** (`## Where it stops`): what it does not do, and what the
  next version would need. Honesty reads as competence, and it shows you know
  where the edges are.
- **Background**: where it came from, what it was built on, credit to sources.

### Voice

- First person, reflective where it is earned: "one detail took me a while to
  appreciate", "the best thing this project taught me".
- **Never invent capabilities, metrics, or outcomes.** Everything must trace to
  the repo, the README, or the user. If you want to describe a mechanism you
  cannot verify, read the source until you can, or ask.
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

Look for an existing OG image first, in this order:

1. `app/opengraph-image.{png,jpg}` or `app/**/opengraph-image.*` (Next.js
   file convention). Also check for `opengraph-image.tsx` (generated at
   runtime; render the deployed URL to capture it)
2. `public/og*.{png,jpg}`, `public/images/og*`, `static/og*`, `assets/og*`
3. The live site's meta tag, if deployed:
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

- **Preserve `order`, `featured`, `year`, `role`, and image filenames** unless
  the user asks otherwise or the repo proves them wrong. Never renumber `order`
  on an update, because it silently reorders the whole index.
- Rewrite `summary` and the body when the project has moved on; refresh
  `technologies` against the current dependencies.
- Do not re-ask the questions in step 3 for values already filled in. Ask only
  about genuinely new facts, and mention what you preserved.

### Creating a new entry

1. Write to `/Users/hvenry/dev/henry-vendittelli-portfolio/content/projects/<slug>.md`
2. Copy any image into `public/assets/images/projects/` (skip if you are
   already working inside the portfolio repo)
3. Set `order` to one past the current highest, unless the user wants it ranked
   higher. Check the existing files
4. Tell the user to run the portfolio dev server and check `/projects/<slug>`

**Do not commit or push.** I handle all git operations themselves.

If the portfolio repo is not on this machine, output the complete file content
in a code block plus the target path, and note where the image should go.
