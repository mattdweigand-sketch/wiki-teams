# <Organization> Wiki - Team Edition

Shared project instructions for `<Organization> Wiki - Team Edition`.

`AGENTS.md` is canonical. Codex and other AGENTS-aware tools read it directly. Claude Code reads
it through the thin `CLAUDE.md` wrapper.

## What this project is

This is a clonable, agent-readable team wiki template. It creates a company-context layer for the organization defined in [`wiki/domain.md`](wiki/domain.md), so downstream agents can answer questions from curated wiki pages instead of re-deriving context from raw source documents.

The team edition can ship as a Cowork plugin. The maintainer publishes wiki snapshots, teammates refresh them, and optional contribution review lets useful teammate analyses flow back into the source wiki.

## How to work in this repo

At the start of every session:

1. Read this file.
2. Read [`wiki/domain.md`](wiki/domain.md). If `status: unconfigured`, route to [`SETUP.md`](SETUP.md) and run the configuration interview before anything else.
3. Read [`CONTEXT.md`](CONTEXT.md) to find the right workspace.
4. Read that workspace's `CONTEXT.md`.
5. Skim the last 5 entries in [`wiki/log.md`](wiki/log.md) for recent activity.
6. Load only the docs the workspace `CONTEXT.md` tells you to load.

Default task routing:

| Task | Start here |
|---|---|
| Ingest a new source file | [`.claude/workspaces/ingest/CONTEXT.md`](.claude/workspaces/ingest/CONTEXT.md) |
| Answer a wiki question | [`.claude/workspaces/research/CONTEXT.md`](.claude/workspaces/research/CONTEXT.md) |
| Compare entities | [`.claude/workspaces/research/CONTEXT.md`](.claude/workspaces/research/CONTEXT.md) |
| Capture a decision | [`.claude/workspaces/maintenance/CONTEXT.md`](.claude/workspaces/maintenance/CONTEXT.md) |
| Lint the wiki or check contradictions | [`.claude/workspaces/maintenance/CONTEXT.md`](.claude/workspaces/maintenance/CONTEXT.md) |
| Publish a snapshot or review contributions | [`MAINTAINING.md`](MAINTAINING.md) |

Claude Code slash commands (`/setup`, `/ingest`, `/lint`, `/publish`, `/review-contributions`) are shortcuts. Non-Claude agents should follow the prose workflows linked above.

## Project structure

- `AGENTS.md` - canonical project operating map. Update this file for future instruction rewrites.
- `CLAUDE.md` - thin Claude Code wrapper that imports `AGENTS.md`.
- `CONTEXT.md` - task router. Read after `AGENTS.md`.
- `SETUP.md` - first-session configuration workflow when `wiki/domain.md` is unconfigured.
- `MAINTAINING.md` - maintainer playbook for ingest, lint, publish, and contribution review.
- `raw/` - immutable source documents. Gitignored.
- `wiki/` - knowledge layer: entity pages, indexes, domain config, activity log.
- `deliverables/` - maintainer scratchpad for one-off outputs. Gitignored.
- `.claude/` - workspace routing, maintainer commands, and helper scripts.
- `.claude-plugin/` - Cowork plugin manifest.
- `commands/` - plugin slash commands.
- `skills/` - plugin skills.

## Conventions

- Keep `AGENTS.md` canonical. `CLAUDE.md` must stay wrapper-only.
- If setup or any future finalize step rewrites the project operating map, rewrite `AGENTS.md`, not `CLAUDE.md`.
- Filenames are kebab-case with no extension prefix, for example `acme-battlecard.md`.
- Use wiki links for cross-references: `[[page-name-without-extension]]`.
- Cite specific facts with `(source: [[source-page]])`.
- Prefix opinions or unsourced reasoning with `Inference:` or `Hypothesis:`.
- Use confidence values consistently: `high`, `medium`, `low`, `contested`.
- Add new precise domain terms to [`wiki/glossary.md`](wiki/glossary.md).
- Update existing wiki pages when content fits. Do not fragment the wiki with near-duplicate pages.
- Workspaces are siloed. Load the workspace docs for the current task, not every workflow in the repo.

### Auto-file rule

After answering a domain question that meets all three criteria below, file the answer to `wiki/analyses/<slug>.md` using the [analysis template](.claude/workspaces/research/docs/analysis-template.md). Do not ask first. Notify in one line after filing: `Filed as analyses/<slug>.md - delete if not useful.` Then append a `query` entry to [`wiki/log.md`](wiki/log.md) and run `python3 .claude/commands/rebuild_referenced_by.py`.

Criteria:

1. The response synthesized 3+ wiki pages.
2. The response is more than 300 words.
3. The response answers a substantive domain question about products, customers, competitors, strategy, decisions, metrics, or similar domain content.

If any criterion fails, answer in chat only.

## Do not do without asking

- Do not modify files in `raw/`.
- Do not silently overwrite contradictions. Log them in [`.claude/workspaces/maintenance/contradictions.md`](.claude/workspaces/maintenance/contradictions.md).
- Do not delete wiki pages, entity folders, plugin commands, Drive-linked files, or contribution drafts unless the workflow explicitly calls for it and the user confirms.
- Do not publish, overwrite Drive snapshots, or change plugin version/configuration without maintainer intent.
- Do not rerun first-session setup when `wiki/domain.md` is already configured unless the user asks.

## Deeper context

- [`wiki/domain.md`](wiki/domain.md) - read at session start for org scope, active entity types, and setup status.
- [`CONTEXT.md`](CONTEXT.md) - read after `AGENTS.md` to route the task.
- [`.claude/workspaces/ingest/CONTEXT.md`](.claude/workspaces/ingest/CONTEXT.md) - read for raw-to-wiki ingestion.
- [`.claude/workspaces/ingest/docs/schema.md`](.claude/workspaces/ingest/docs/schema.md) - read when authoring or auditing entity pages.
- [`.claude/workspaces/research/CONTEXT.md`](.claude/workspaces/research/CONTEXT.md) - read for wiki-backed answers and analysis filing.
- [`.claude/workspaces/maintenance/CONTEXT.md`](.claude/workspaces/maintenance/CONTEXT.md) - read for lint, contradiction, sourcing queue, and decision work.
- [`MAINTAINING.md`](MAINTAINING.md) - read for publish, Drive setup, and contribution review.
- [`wiki/index.md`](wiki/index.md) - read to browse known pages.
- [`wiki/primer.md`](wiki/primer.md) - read to find entry points by question type.
- [`wiki/log.md`](wiki/log.md) - read for recent activity.
