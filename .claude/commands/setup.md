---
description: First-run setup for a freshly cloned wiki-teams template. Routes to root-level SETUP.md and runs the configuration interview.
---

# Setup

Follow the workflow in [`SETUP.md`](../../SETUP.md) at the repo root.

`SETUP.md` is the canonical setup playbook — agent-agnostic, runnable by Claude Code, Codex, or any agent that reads markdown. This slash command is a Claude Code-specific shortcut that triggers the same flow.

Steps you'll follow there:

1. Read `wiki/domain.md`. If `status: unconfigured`, run the interview in `SETUP.md`.
2. Replace `<Organization>` placeholders across the framework files.
3. Configure `raw/` taxonomy and entity types per the user's domain.
4. Optionally configure team-plugin features (plugin name + Drive folder IDs).
5. Log the configuration to `wiki/log.md`.
6. Confirm with the user and explain what's next (drop files into `raw/`, run `/ingest`).

Don't duplicate the interview here — `SETUP.md` is the source of truth so the same flow works for non-Claude-Code agents.
