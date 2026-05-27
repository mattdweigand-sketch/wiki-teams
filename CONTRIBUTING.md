# Contributing to wiki-teams

Thanks for your interest in improving the template. Contributions welcome — bug fixes, documentation improvements, and new ideas.

## Repo structure reminder

This repo is a **template** — the machinery lives in `.claude/`, `commands/`, `skills/`, and `wiki/`. The goal is that everything inside those folders works for any domain after a `/setup` pass.

When evaluating a change, ask: *does this still work for a B2C SaaS, a law firm, and a research lab?* If not, it's probably a domain-specific customization, not a template improvement.

## Ways to contribute

### Bug reports
Open an issue using the **Bug report** template. Include:
- Which file(s) the bug is in
- What you expected vs. what happened
- Which agent you were using (Claude Code, Codex, Cursor, other)

### Feature requests
Open an issue using the **Feature request** template. Describe the use case, not just the feature.

### Pull requests
1. Fork the repo, create a branch off `main`.
2. Make your change. If it touches agent-instruction files (`AGENTS.md`, `CLAUDE.md`, `.claude/`, `CONTEXT.md`, workspace `CONTEXT.md`s), test it with at least one agent session.
3. Keep PRs focused — one logical change per PR.
4. Update any cross-referenced docs affected by your change.
5. Open the PR against `main` with a short description of what changed and why.

## What makes a good template change

- **Domain-agnostic.** No private-markets, SaaS, or any other domain-specific examples in shared infrastructure.
- **Agent-readable.** Instructions written for LLMs need to be clear and unambiguous — prose that's fine for a human reader can still confuse an agent.
- **Consistent.** Match the conventions already in place (kebab-case filenames, `python3` for scripts, `[[wikilinks]]` for internal references, etc.).
- **Tested.** Try the happy path in an actual agent session before opening a PR.

## Questions

Open a discussion or file an issue — either works.
