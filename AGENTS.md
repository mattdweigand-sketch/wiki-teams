# AGENTS.md

This wiki's instructions live in [`CLAUDE.md`](CLAUDE.md). Read it first — same conventions apply regardless of which agent loaded this file.

The filename is duplicated so OpenAI Codex and other agents that auto-load `AGENTS.md` pick up the same map Claude Code reads from `CLAUDE.md`. The content is not maintained here; it forwards.

**First-session check:** Read [`wiki/domain.md`](wiki/domain.md). If `status: unconfigured`, route to [`SETUP.md`](SETUP.md) and run the configuration interview before answering other questions. `SETUP.md` is agent-agnostic — it works the same in Codex, Cursor, or any agent reading markdown.

**Slash commands** (`/setup`, `/ingest`, `/lint`, `/publish`, `/review-contributions`) are Claude Code's discovery convention. If your agent doesn't have them, follow the prose workflows in:

- [`.claude/workspaces/ingest/CONTEXT.md`](.claude/workspaces/ingest/CONTEXT.md) — raw → wiki pipeline (replaces `/ingest`)
- [`.claude/workspaces/maintenance/CONTEXT.md`](.claude/workspaces/maintenance/CONTEXT.md) — lint, contradictions, contribution review (replaces `/lint`, `/review-contributions`)
- [`.claude/workspaces/research/CONTEXT.md`](.claude/workspaces/research/CONTEXT.md) — answer questions with citations (no slash command needed; this is the default mode)
- [`SETUP.md`](SETUP.md) — first-session config (replaces `/setup`)
- [`MAINTAINING.md`](MAINTAINING.md) → "Publish a snapshot" (replaces `/publish`)

The prose describes the same pipelines as the slash commands. Only the trigger differs.
