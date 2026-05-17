# Agent Conventions

This repo's conventions live in [`CLAUDE.md`](CLAUDE.md) — folder map, entity types, citation rules, hard rules, session-start checklist. Read it first; it's the single source of truth.

Task routing: [`CONTEXT.md`](CONTEXT.md) → workspace `CONTEXT.md`.
Maintainer routines (ingest, lint, publish, contribute-back): [`MAINTAINING.md`](MAINTAINING.md).

Slash commands (`/setup`, `/ingest`, `/lint`, `/publish`, `/review-contributions`) are Claude Code-specific. In other agents, route to the workspace `CONTEXT.md` files manually — they describe the same pipelines as prose, with no slash-command dependency.
