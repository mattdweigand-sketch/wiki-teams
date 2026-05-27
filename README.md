# <Organization> Wiki - Team Edition

A clonable, agent-readable wiki template — the team edition. The company context layer for AI agents at the organization defined in [`wiki/domain.md`](wiki/domain.md), distributable to teammates as a [Cowork](https://github.com/anthropics/cowork) plugin with opt-in contribute-back review.

A self-maintaining, LLM-readable knowledge base. Downstream agents (sales, product, customer success) read from it instead of re-deriving context from raw documents. Built on the [Karpathy LLM-wiki pattern](https://karpathy.ai/zero-to-one/).

> **Just cloned this?** See [`SETUP.md`](SETUP.md). On first session, an agent that reads [`AGENTS.md`](AGENTS.md) will notice the unconfigured domain file and offer to interview you for ~3 minutes.

> Looking for the solo version? See [wiki-solo](https://github.com/mattdweigand-sketch/wiki-solo) — same machinery, no plugin or team-distribution layer.

## Solo vs. Team — which should you use?

| | [wiki-solo](https://github.com/mattdweigand-sketch/wiki-solo) | wiki-teams (this repo) |
|---|---|---|
| **Who maintains the wiki** | You | You (the maintainer) |
| **Who reads the wiki** | You | You + your whole team |
| **Distribution** | Local only | Cowork plugin, synced via Google Drive |
| **Team search** | — | `/team-wiki:search <question>` |
| **Snapshot refresh** | — | `/team-wiki:refresh` |
| **Contribute-back flow** | — | Teammates submit; you review and merge |
| **Drive setup required** | No | Yes (one-time, ~10 min) |
| **Right choice if…** | You’re the only consumer | Others need to query your wiki |

## How to use it

Three modes of use.

### Agent startup

[`AGENTS.md`](AGENTS.md) is the canonical project instruction file. OpenAI Codex and other AGENTS-aware tools read it directly. Claude Code reads [`CLAUDE.md`](CLAUDE.md), a thin wrapper that imports `AGENTS.md`.

If your agent does not auto-load either file, point it at `AGENTS.md` first.

### 1. Ask a question (default)

Just ask. The agent follows [`CONTEXT.md`](CONTEXT.md) into the [research workspace](.claude/workspaces/research/CONTEXT.md), which tells it how to find the right pages, cite sources, and respect confidence ratings. No command needed.

Example question shapes (fill in your own domain):
- "How does `<our product>` compare to `<competitor>`?"
- "What's our positioning on `<market shift or theme>`?"
- "What's our GTM strategy for `<segment>`?"

The agent answers with citations like `(source: [[sources/<source-slug>]])` so you can trace any claim back to its source.

**Meaningful answers are auto-filed.** When an answer synthesizes 3+ wiki pages and runs >300 words, the agent saves it to [`wiki/analyses/`](wiki/analyses/) automatically and tells you in one line (*"Filed as `analyses/<slug>.md` — delete if not useful."*). This is how the wiki compounds — good answers don't disappear into chat history. Deletion is cheaper than re-asking the same question next month.

### 2. Add a new source

Drop the file into the appropriate `raw/` subfolder, then run:

```
/ingest
```

This runs the 3-stage ingest pipeline (triage → extract → link), creates or updates the relevant entity pages, rebuilds backlinks, and appends a log entry.

> **No slash commands?** `/ingest` and `/lint` are Claude Code shortcuts. On Codex or any other agent, point it at [`.claude/workspaces/ingest/CONTEXT.md`](.claude/workspaces/ingest/CONTEXT.md) and ask it to follow the pipeline — the prose workflow is the same.

### 3. Maintain the wiki

```
/lint
```

Checks for contradictions, stale claims, orphan pages, missing cross-references, terminology drift, and confidence miscalibration. Reports findings, asks which to apply, then applies approved fixes.

For decisions, contradictions, or sourcing-queue updates, just describe the task — the agent routes through the [maintenance workspace](.claude/workspaces/maintenance/CONTEXT.md).

### Browsing manually

Start at [`wiki/index.md`](wiki/index.md) — the master catalog of every page, grouped by entity type with one-line summaries and confidence ratings.

## Sharing the wiki with your team (the plugin)

The wiki is also a Cowork plugin. Once the maintainer has published a snapshot, teammates install the plugin from this repo and get two commands:

| Command | What it does |
|---|---|
| `/team-wiki:search <question>` | Conversational answer drawn from the wiki, with citations. Read-only. |
| `/team-wiki:refresh` | Pulls the latest snapshot from the maintainer's pinned Drive file (~5–10s). |

Teammates can also just ask questions in natural language — the `search-team-wiki` skill auto-triggers on wiki-relevant queries.

**Maintainer setup is one-time.** See [`MAINTAINING.md`](MAINTAINING.md) → "Drive setup" — you create two Drive folders (one for the snapshot, one for contributions), paste the IDs into a handful of files, and you're done.

## Contribute-back flow

When a teammate's question pulls together 3+ wiki pages into a substantive answer, the agent offers to send the synthesized answer back as a wiki contribution:

> *This answer synthesized 5 pages — analysis-worthy. Want me to send it to the maintainer as a contribution to the wiki?*

If they say yes, the agent drafts a structured analysis (with full citations) and uploads it to a shared Drive folder. The maintainer reviews via:

```
/review-contributions
```

…which walks pending drafts one at a time with **Accept / Edit / Reject**. Accepted drafts land in `wiki/analyses/` and ship with the next `/publish` snapshot.

This turns passive consumers into curators without diluting maintainer control. Every merge is explicit, every reject is recoverable, and a built-in dedup guard prevents the same question from being submitted twice. Full operator detail in [`MAINTAINING.md`](MAINTAINING.md).

## Repo structure

```
<wiki-root>/
├── AGENTS.md       Canonical project operating map. Read by Codex and other AGENTS-aware tools.
├── CLAUDE.md       Thin Claude Code wrapper that imports AGENTS.md.
├── CONTEXT.md      Task router.
├── SETUP.md        First-session config (when wiki/domain.md is unconfigured).
├── README.md       This file.
├── MAINTAINING.md  Operator playbook (ingest, lint, publish, review-contributions).
│
├── raw/            Source documents. Immutable — never edited. Gitignored.
├── wiki/           Knowledge layer. All entity pages + domain.md config.
├── deliverables/   Maintainer scratchpad — one-off outputs. Gitignored.
├── .claude/        Maintainer machinery: workspaces, commands, scripts.
│
├── .claude-plugin/ Cowork plugin manifest (marketplace.json, plugin.json).
├── commands/       Plugin slash commands (/team-wiki:search, /team-wiki:refresh).
└── skills/         Plugin skills (search-team-wiki, refresh-team-wiki).
```

## Entity types

13 entity types ship out of the box. Each lives in its own folder under `wiki/`. Add, remove, or rename to fit your domain.

| Type | Folder | Purpose |
|---|---|---|
| Source | `wiki/sources/` | Summary of a raw document — facts, quotes, metadata |
| Product | `wiki/products/` | A product: positioning, users, core jobs |
| Feature | `wiki/features/` | A specific feature: what it does, who uses it |
| Persona | `wiki/personas/` | A user/buyer type: role, goals, pain, objections |
| Customer | `wiki/customers/` | A named customer or segment |
| Competitor | `wiki/competitors/` | A competing vendor: positioning, where they win/lose |
| Concept | `wiki/concepts/` | A domain idea or canonical definition |
| Initiative | `wiki/initiatives/` | A strategic bet, launch, or program |
| Decision | `wiki/decisions/` | A decision, reasoning, alternatives, revisit date |
| Metric | `wiki/metrics/` | A KPI or North Star: definition, formula, target |
| Person/Team | `wiki/people/` | A role, team, or stakeholder |
| Analysis | `wiki/analyses/` | Synthesized output: comparison, brief, gap analysis |
| Style Rule | `wiki/style/` | Writing/naming convention for agent-generated content |

Full schema in [`.claude/workspaces/ingest/docs/schema.md`](.claude/workspaces/ingest/docs/schema.md).

## How agents consume it

Four files cover most queries:

1. [`wiki/domain.md`](wiki/domain.md) — org name, scope, active entity types, team-feature config
2. [`wiki/index.md`](wiki/index.md) — master catalog
3. [`wiki/overview.md`](wiki/overview.md) — synthesis of the organization
4. [`wiki/glossary.md`](wiki/glossary.md) — canonical terminology

Each page carries a `confidence:` rating in its frontmatter:

| Rating | Meaning |
|---|---|
| `high` | Sourced from authoritative document |
| `medium` | Probable; may rest on a single source |
| `low` | Hypothesis; treat as a starting point |
| `contested` | Sources disagree — see [`contradictions.md`](.claude/workspaces/maintenance/contradictions.md) |

Every factual claim cites its source as `(source: [[source-slug]])`. Inferences are prefixed `Inference:` or `Hypothesis:`.

## Conventions

- **Filenames:** kebab-case, no prefix (`acme-battlecard.md`)
- **Internal links:** `[[page-name]]` (no folder, no extension)
- **`raw/` is immutable** — source files are never edited; new sources are appended
- **Cite the wiki page**, not the raw source, in agent-to-human output

## Workspaces

Three workspaces govern how work happens. Each has its own `CONTEXT.md` with task-specific instructions.

| Workspace | Purpose |
|---|---|
| [`ingest/`](.claude/workspaces/ingest/CONTEXT.md) | Raw source → structured wiki page(s) |
| [`research/`](.claude/workspaces/research/CONTEXT.md) | Wiki → synthesized answer with citations |
| [`maintenance/`](.claude/workspaces/maintenance/CONTEXT.md) | Lint, contradictions, sourcing queue, decision capture |

## Why a wiki instead of RAG

RAG does one thing: at query time, embed the question, retrieve chunks from source docs, and stuff them into context. It front-loads nothing and compounds nothing.

The wiki front-loads the hard work at ingest time and makes every session cheaper and more reliable:

1. **Distillation, not retrieval.** The wiki reads each source once and distills it into structured entity pages. The query agent starts from signal, not raw chunks.
2. **Explicit contradiction handling.** When sources disagree, the wiki flags it and marks pages `confidence: contested`. RAG retrieves both and lets the LLM guess.
3. **Typed, navigable relationships.** Entity types, frontmatter, and `[[wikilinks]]` route agents directly to the right pages. No chunk-hunting.
4. **Compounding knowledge.** Good answers get filed back into `wiki/analyses/` as citable pages. RAG accumulates source documents; the wiki accumulates understanding.
5. **Scoped agent context.** Ingest, research, and maintenance agents each load only what they need. Smaller context, lower hallucination risk.
6. **Domain-locked terminology.** The glossary prevents paraphrase drift on precise terms.

## Activity

See [`wiki/log.md`](wiki/log.md) for the append-only history of every ingest, lint, decision capture, and merged contribution.

## Customizing for your domain

The agent-driven path is `/setup` (Claude Code) or just opening the repo in any agent that reads `AGENTS.md` — it'll see [`wiki/domain.md`](wiki/domain.md) with `status: unconfigured` and walk you through [`SETUP.md`](SETUP.md). That interview handles all of the below.

If you'd rather customize manually:

1. **Fill in [`wiki/domain.md`](wiki/domain.md)** — set `org`, `domain`, `entity_types_active`, `raw_taxonomy`, `example_queries`. Flip `status: unconfigured` → `status: configured`.
2. **Replace `<Organization>` placeholders** in `AGENTS.md`, `CONTEXT.md`, `README.md`, `MAINTAINING.md`.
3. **Rename `raw/` subfolders** to match your `raw_taxonomy`.
4. **Drop unused entity-type folders** under `wiki/` for any type you removed from `entity_types_active`. Add new folders for any custom types.
5. **Seed [`wiki/overview.md`](wiki/overview.md)** with a paragraph or two about your organization. The ingest agent will expand it.
6. **Set the plugin name** in [`wiki/domain.md`](wiki/domain.md) → `plugin_name` and propagate it. Default is `team-wiki`.
7. **Configure Drive** when you're ready for team distribution — see [`MAINTAINING.md`](MAINTAINING.md) → "Drive setup (one-time)" and set `team_features_enabled: true` in `wiki/domain.md`.

The harness in `.claude/` and the plugin in `commands/`/`skills/` are domain-agnostic — they work on any corpus.
