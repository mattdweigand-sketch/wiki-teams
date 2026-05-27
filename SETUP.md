# SETUP — First Session After Clone

**Audience: the AI agent in a freshly-cloned wiki.** A human can read this too, but the intent is that an agent picks this up automatically on first session and runs the interview itself.

---

## Trigger

At session start, the repo's map file routes you to [`wiki/domain.md`](wiki/domain.md). Which map file depends on your agent:

- **OpenAI Codex and other AGENTS-aware tools** read [`AGENTS.md`](AGENTS.md) directly.
- **Claude Code** auto-loads [`CLAUDE.md`](CLAUDE.md), a thin wrapper that imports `AGENTS.md`.
- **Cursor / other agents:** point yourself at `AGENTS.md` manually; the checklist there is agent-agnostic.

In all cases, the checklist tells you to read [`wiki/domain.md`](wiki/domain.md). If that file has `status: unconfigured` in its frontmatter, **do this before answering any other question.** Tell the user:

> "This wiki is in template state. I can interview you for ~3 minutes to configure it for your organization — or you can skip and just start dropping sources into `raw/`. Want to run setup?"

If the user declines, stop and let them proceed however they want. Don't gate other actions on setup.

If they accept, run the interview below.

---

## Interview

Ask these in order. Keep it conversational; one question at a time unless the user is rapid-firing answers.

### Part A — Domain (always asked)

1. **Organization name.** "What's the name of the organization, team, or project this wiki is about?"
2. **Domain.** "One line — what subject area does this wiki cover? (Examples: 'private-markets fintech,' 'developer tools for payments,' 'biotech research at a Series B startup.')"
3. **Entity types.** Show the user the 13 default types from [`.claude/workspaces/ingest/docs/schema.md`](.claude/workspaces/ingest/docs/schema.md) and ask which to keep. Default is all 13. Common drops: a B2C product may not need `customer` as named accounts; a research lab may not need `competitor`.
4. **Custom entity types.** "Any entity types specific to your domain that aren't in the default 13? (Examples: 'integrations' for a SaaS product, 'experiments' for a research lab, 'regulations' for a compliance team.)"
5. **Source taxonomy.** "What subfolders should exist under `raw/`? Pick categories that match where your source documents come from. (Examples: `competitive-intel`, `customer-research`, `internal-memos`, `release-notes`, `press`.)"
6. **Example queries.** "3–5 questions you want this wiki to answer well. These guide what to ingest first and what `agent_use_cases` to write into entity pages."

### Part B — Team features (team-edition only)

7. **Team distribution decision.** "Two ways to use this wiki:
   - **Solo / local-only** — you ingest, you ask questions, the wiki lives in this repo. No Drive setup needed.
   - **Team-shared** — your teammates install this as a Cowork plugin, refresh to pull your latest snapshot from Drive, and can opt-in to send synthesis answers back for you to review.
   
   Which do you want to start with? You can always add team features later."

8. **If team-shared:** "The plugin slash commands default to `/team-wiki:search` and `/team-wiki:refresh`. Want a different name (e.g., `/acme-wiki`)? Or keep `team-wiki`?"

9. **If team-shared:** *Don't try to do Drive setup yourself — it requires the user logged into Drive in a browser.* Tell them: "Drive setup is manual — full walkthrough in [`MAINTAINING.md`](MAINTAINING.md) → 'Drive setup (one-time)'. The short version: create two Drive folders (snapshot + contributions), share each with your team, paste the folder + file IDs back here. Want to do it now, or come back to it later? (If later, the placeholders in the config files are inert until you fill them.)"

---

## What to write after the interview

In order:

If any setup or finalize step rewrites the project operating map, update [`AGENTS.md`](AGENTS.md). Do not add project instructions to [`CLAUDE.md`](CLAUDE.md); it is only the Claude Code wrapper.

### 1. Fill `wiki/domain.md`

Replace the placeholder values in the frontmatter with the user's answers. Flip `status: unconfigured` → `status: configured`. Update `updated:` to today's date. If they enabled team features, set `team_features_enabled: true` and fill `plugin_name` plus the three Drive IDs (or leave the `<YOUR_*>` placeholders if they're doing Drive setup later).

### 2. Replace `<Organization>` placeholders

Four files have `<Organization>` placeholders that need the user's org name:

| File | What to replace |
|---|---|
| [`README.md`](README.md) | `<Organization> Wiki — Team Edition` → `<Their Org> Wiki — Team Edition` |
| [`AGENTS.md`](AGENTS.md) | `<Organization> Wiki - Team Edition` → `<Their Org> Wiki - Team Edition` |
| [`CONTEXT.md`](CONTEXT.md) | `<Organization> Wiki — Task Router` → `<Their Org> Wiki — Task Router` |
| [`MAINTAINING.md`](MAINTAINING.md) | `Maintaining the <Organization> Wiki` → `Maintaining the <Their Org> Wiki` |

Other framework files (`schema.md`, `classification.md`, etc.) reference [`wiki/domain.md`](wiki/domain.md) rather than hardcoding a name, so no further edits needed there.

### 3. Create raw/ subfolders

For each entry in `raw_taxonomy`, ensure `raw/<name>/` exists with a `.gitkeep` inside. The template ships with example subfolders — delete the ones the user didn't list, and create new ones for any they added.

### 4. Drop unused entity folders; add custom ones

For each of the 13 default entity types **not** in `entity_types_active`, delete the corresponding `wiki/<type>/` folder. For each entry in `entity_types_custom`, create a new `wiki/<type>/` folder with a `.gitkeep`.

If you add custom entity types, also append a row for each to the "Entity Types" table in [`.claude/workspaces/ingest/docs/schema.md`](.claude/workspaces/ingest/docs/schema.md) so the ingest workflow knows about them.

### 5. (Team features only) Rename plugin and apply Drive IDs

If the user picked a custom plugin name (Part B, question 8):

- Edit `.claude-plugin/plugin.json` (`name` field, top-level)
- Edit `.claude-plugin/marketplace.json` (top-level `name` and the nested plugin's `name`)
- Rename `skills/search-team-wiki/` → `skills/search-<new-name>/`
- Rename `skills/refresh-team-wiki/` → `skills/refresh-<new-name>/`
- Inside each renamed skill's `SKILL.md`, update the `name:` frontmatter field
- Search-and-replace `team-wiki` → `<new-name>` across `commands/search.md`, `commands/refresh.md`, `.claude/commands/publish.md`, `README.md`, `MAINTAINING.md`, `AGENTS.md`, `.claude/scripts/publish.sh`

If the user has Drive IDs ready (Part B, question 9), replace `<YOUR_SNAPSHOT_FOLDER_ID>`, `<YOUR_SNAPSHOT_FILE_ID>`, `<YOUR_CONTRIBUTIONS_FOLDER_ID>` placeholders across:

- `.claude/scripts/publish.sh`
- `skills/refresh-<plugin-name>/SKILL.md`
- `.claude/commands/review-contributions.md`
- `skills/search-<plugin-name>/SKILL.md`
- `MAINTAINING.md`

If they're doing Drive setup later, leave the placeholders alone and tell them to come back to MAINTAINING.md when ready.

### 6. Log the configuration

Append an entry to [`wiki/log.md`](wiki/log.md):

```
## 2026-MM-DD — domain configured

Org: <Org name>
Domain: <one-line summary>
Active entity types: <list>
Custom entity types: <list or "none">
Raw taxonomy: <list>
Team features: <enabled / not yet / declined>
Plugin name: <name or "default (team-wiki)">
```

### 7. Confirm with the user

Show a one-paragraph summary of what changed and what's next:

> "Configured. Drop your first source into `raw/<one of their subfolders>` and run `/ingest` (or, in non-Claude-Code agents, follow `.claude/workspaces/ingest/CONTEXT.md`). When you've ingested a few sources, just ask questions — the wiki answers conversationally."

If they enabled team features but haven't done Drive setup yet, add:

> "When you're ready to share with the team, see `MAINTAINING.md` → 'Drive setup (one-time)' and run `/publish`."

---

## What NOT to touch during setup

Hands off:

- [`.claude/commands/`](.claude/commands/) — slash command definitions and the backlink rebuild script (one exception: rename `team-wiki` references in `publish.md` if the user picked a custom plugin name)
- [`.claude/workspaces/ingest/workflows/`](.claude/workspaces/ingest/workflows/) — the 3-stage ingest pipeline (triage, extract, link)
- [`.claude/workspaces/*/CONTEXT.md`](.claude/workspaces/) — workspace task routers
- [`.claude/workspaces/maintenance/docs/`](.claude/workspaces/maintenance/docs/) — lint criteria, decision capture
- The schema's "Page Format," "Source-Type Summary Templates," and "Confidence Values" sections in [`schema.md`](.claude/workspaces/ingest/docs/schema.md) — domain-agnostic infrastructure

The only schema edit during setup is appending custom entity-type rows to the "Entity Types" table (step 4 above).

---

## Idempotency

If `wiki/domain.md` already has `status: configured`, do not re-run setup unless the user explicitly asks. If they ask for a refresh, treat the existing values as defaults in the interview and confirm each one rather than starting from scratch.
