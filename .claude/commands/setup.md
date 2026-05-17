---
description: First-run setup for a freshly forked wiki-teams template. Walks the maintainer through naming the org, seeding the overview, deciding on team-plugin features, and confirming they're ready to ingest.
---

# Setup

You are walking the user (the wiki maintainer) through first-time customization of a freshly forked `wiki-teams` template. The user has just cloned this repo, opened it in Claude Code, and run `/setup`. Your job is to make it feel like a conversation, not a checklist.

## Goal

By the end of this session, the user should have:

1. Replaced the generic "your organization" placeholder text with real names.
2. Seeded `wiki/overview.md` with a real one-paragraph company / team summary.
3. Made an explicit decision about the team-plugin features (use them and configure Drive, or skip for now and just use the wiki locally).
4. Confirmed that `raw/` subfolders fit their domain (rename or accept defaults).
5. Optionally set the plugin command prefix (default: `team-wiki`).
6. Heard the one-line "you're ready — drop files in raw/<category>/ and run /ingest" closer.

Don't dump the whole flow at once. Ask one or two questions at a time, apply edits as you go, narrate what you changed in one line each.

## Steps

### Step 1 — Confirm this is a fresh template

Read [`wiki/overview.md`](wiki/overview.md). If it still contains the phrase *"Write a paragraph or two about your company here"* (the placeholder seed), this is a fresh template and `/setup` is the right command. If it's already been customized, ask the user: *"This wiki looks like it's already been set up. Did you want to re-run setup anyway?"* Wait for confirmation before proceeding.

### Step 2 — Get the org / team name and one-line description

Ask:

> *"What should I call your organization or team in the wiki? (e.g., 'Acme Corp', 'the platform team', 'Acme Research Lab')"*

Then:

> *"And in one sentence, what does it do? This goes in `wiki/overview.md` as a seed for downstream agents."*

### Step 3 — Apply the name edits

Edit these files to replace the generic placeholder phrasing with the user's org/team name:

1. **[`CLAUDE.md`](CLAUDE.md)** — the "Purpose" section currently reads *"The context layer for your organization's AI infrastructure..."*. Replace `your organization` with the user's name. Keep the rest of the paragraph.
2. **[`wiki/overview.md`](wiki/overview.md)** — replace the entire placeholder body with a real first draft using the user's one-line description. Use this template:

   ```markdown
   ---
   title: Company Overview
   type: overview
   confidence: medium
   agent_use_cases:
     - First read when an agent needs broad context about the company.
     - One-paragraph summary for downstream agents that don't have time to read the full wiki.
   ---

   # Company Overview

   <One-paragraph summary of what the org does, who it serves, and what stage it's at.>

   The ingest agent will expand this as it processes sources.
   ```

3. **[`README.md`](README.md)** — leave alone. It's the public-facing template guide and the placeholder phrasing is intentional for downstream forkers reading the repo on GitHub.

Narrate each edit in one line: *"Updated CLAUDE.md Purpose. ✓ Seeded wiki/overview.md. ✓"*

### Step 4 — Decide on team-plugin features

Ask:

> *"Two ways to use this wiki:*
>
> *1. Solo / local-only — you ingest, you ask questions, the wiki lives in this repo. No Drive setup needed. Easiest to start.*
>
> *2. Team-shared — your teammates install this as a Cowork plugin, refresh to pull your latest snapshot from Drive, and can opt-in to send synthesis answers back for you to review.*
>
> *Which do you want to start with? You can always add team features later."*

#### If they pick solo:

Reassure them: *"Great. The `<YOUR_*>` placeholders in plugin config files are harmless when you're not using team features — just ignore them. If you change your mind later, run `/setup` again and pick team-shared, or follow `MAINTAINING.md` → Drive setup."*

Skip to Step 5.

#### If they pick team-shared:

Don't try to create the Drive folders yourself — Drive setup is manual and lives in [`MAINTAINING.md`](MAINTAINING.md). Tell them:

> *"Drive setup is a one-time manual flow. Here's the short version:*
>
> *1. Create two Drive folders — one for the wiki snapshot (`team-wiki-snapshots`), one for teammate contributions (`team-wiki-contributions`).*
> *2. Share each with your team (snapshot → Viewer; contributions → Editor).*
> *3. Copy the folder IDs and the snapshot's `wiki.zip` file ID into 4 files in this repo.*
>
> *Full walkthrough with the file paths is in [`MAINTAINING.md`](MAINTAINING.md) under 'Drive setup (one-time)'. Want me to open it and read it back to you, or are you good to do that on your own when you're ready?"*

If they ask for help, read MAINTAINING.md's Drive setup section back to them and offer to do the file edits once they have the IDs in hand. If not, move on.

### Step 5 — Optional: rename the plugin

If team-shared, ask:

> *"The plugin slash commands are `/team-wiki:search` and `/team-wiki:refresh` by default. Want to rename it to something more specific to your org (e.g., `/acme-wiki`, `/platform-wiki`)? Or keep `team-wiki`?"*

If they want a rename:
- Edit `.claude-plugin/plugin.json` (`name` field, top-level)
- Edit `.claude-plugin/marketplace.json` (top-level `name` and the nested plugin's `name`)
- Rename `skills/search-team-wiki/` → `skills/search-<new-name>/`
- Rename `skills/refresh-team-wiki/` → `skills/refresh-<new-name>/`
- Inside each renamed skill's `SKILL.md`, update the `name:` frontmatter field
- Search-and-replace `team-wiki` → `<new-name>` across:
  - `commands/search.md`, `commands/refresh.md`
  - `.claude/commands/publish.md`
  - `README.md`, `MAINTAINING.md`, `CLAUDE.md`
  - `.claude/scripts/publish.sh`

Confirm: *"Renamed plugin to `<new-name>`. ✓"*

If solo, skip this step entirely.

### Step 6 — Sanity-check the raw/ subfolders

Run `ls raw/` and show the user the list. Ask:

> *"These are the example `raw/` source categories that ship with the template:*
>
> *[list]*
>
> *Do they fit your domain, or should I rename/remove some? (If you're not sure, leave them — they're just folders, and you can rearrange anytime.)"*

If they want changes, apply them. If they want to keep defaults, move on.

### Step 7 — Closer

Print this exactly:

```
You're set up.

Next:
  1. Drop source files into raw/<category>/
  2. Run /ingest
  3. Ask questions — just type them, no command needed

The wiki starts empty. After a few ingests you'll have real entity pages.
After ~10 you'll start to see the wiki answer cross-page questions on its own.

For maintainer routines (lint, publish, review contributions), see MAINTAINING.md.
```

Don't ask follow-up questions after this. End the session.

## Rules

- **Be conversational, not robotic.** Ask one or two questions at a time. Apply edits as you go. Narrate in single lines.
- **Don't read all the workspace docs.** They auto-load when the user actually runs `/ingest`, `/lint`, etc. Stick to the files you're editing.
- **Don't try to do Drive setup yourself.** It requires the user to be logged into Drive in a browser. You can only help with the file edits *after* they have the IDs in hand.
- **Skip steps the user doesn't need.** If they pick solo, skip team-features and plugin-rename steps entirely.
- **One file edit per step.** Don't batch multiple file edits into one narrate-and-confirm cycle — it makes it harder for the user to spot mistakes.
