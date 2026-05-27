# Maintaining the <Organization> Wiki

For the maintainer(s) of the wiki. [`README.md`](README.md) is for consumers, [`AGENTS.md`](AGENTS.md) is the canonical architecture map, and [`CLAUDE.md`](CLAUDE.md) is only a Claude Code wrapper. This is the operator's manual for keeping the wiki healthy and distributing it to the team.

---

## Drive setup (one-time)

The team variant uses two Google Drive folders:

1. **Snapshot folder** — holds `wiki.zip`. Teammates' `/team-wiki:refresh` downloads from a pinned file in this folder.
2. **Contributions folder** — where teammates' opt-in synthesis drafts land for you to review via `/review-contributions`.

### Step 1 — Create the snapshot folder

1. Create a Drive folder named something like `team-wiki-snapshots` in your or your team's Drive.
2. Share it with your team group / domain with **Viewer** access (link-shared).
3. Upload a placeholder `wiki.zip` (the first real one will come from your first `/publish`).
4. Copy the **folder ID** (the long string in the URL after `/folders/`) — paste it as `<YOUR_SNAPSHOT_FOLDER_ID>` in:
   - [`.claude/scripts/publish.sh`](.claude/scripts/publish.sh)
5. Once you've uploaded a `wiki.zip`, right-click → "Get link" or "Share" to get the **file ID** for that specific file. Paste it as `<YOUR_SNAPSHOT_FILE_ID>` in:
   - [`skills/refresh-team-wiki/SKILL.md`](skills/refresh-team-wiki/SKILL.md) (two occurrences — search for the placeholder)

Keep the file ID stable forever by always **overwriting** `wiki.zip` on subsequent publishes (drag in → "Replace existing file"). Never delete-and-reupload — that gives the file a new ID and breaks every teammate's `/team-wiki:refresh`.

### Step 2 — Create the contributions folder

1. Create a Drive folder named something like `team-wiki-contributions`.
2. Share it with your team group → **Editor** access, with "Must have link to access" enabled. Editor is the only role that allows file uploads in a My Drive folder — Viewer and Commenter both block file creation.
   - **Tradeoff:** Editors can rename or delete files in the folder, including your archive. For a small trusted team this is fine; accidental deletes are recoverable from Drive trash for 30 days. If you ever need true "upload only, no delete" semantics, migrate the folder into a Shared Drive (Shared Drives expose a proper Contributor role).
3. Copy the **folder ID** and paste it as `<YOUR_CONTRIBUTIONS_FOLDER_ID>` in:
   - [`.claude/commands/review-contributions.md`](.claude/commands/review-contributions.md)
   - [`skills/search-team-wiki/SKILL.md`](skills/search-team-wiki/SKILL.md) (Step 3.5 — two occurrences)

The `archive/` and `archive/rejected/` subfolders inside contributions are lazy-created on first use — no manual setup needed.

### Step 3 — Quick checklist

- [ ] `.claude/scripts/publish.sh` has `<YOUR_SNAPSHOT_FOLDER_ID>` replaced
- [ ] `skills/refresh-team-wiki/SKILL.md` has `<YOUR_SNAPSHOT_FILE_ID>` and `<YOUR_SNAPSHOT_FOLDER_ID>` replaced
- [ ] `.claude/commands/review-contributions.md` has `<YOUR_CONTRIBUTIONS_FOLDER_ID>` replaced
- [ ] `skills/search-team-wiki/SKILL.md` has `<YOUR_CONTRIBUTIONS_FOLDER_ID>` replaced
- [ ] `.claude-plugin/marketplace.json` has `<YOUR_NAME>` and `<YOUR_EMAIL>` replaced
- [ ] `.claude-plugin/plugin.json` has `<YOUR_NAME>` replaced in `author.name`

Confirm with: `grep -rn "<YOUR_" .` — should return zero hits after setup.

---

## Routine workflows

Four slash commands cover ~90% of maintenance. Run from inside Claude Code at the repo root.

### `/ingest` — add or update content from a raw source

1. Drop the source file into the appropriate `raw/<source-type>/` subfolder.
2. Run `/ingest`. The 3-stage pipeline (triage → extract → link) decides whether to create new pages or update existing ones, then rebuilds backlinks and appends to [`wiki/log.md`](wiki/log.md).
3. **Skim the new/changed pages before publishing.** The pipeline is good but not infallible — watch for:
   - Low-confidence pages that should be high (or vice versa)
   - A new page created where an existing one should have been updated
   - Citation links pointing at the wrong source page

Schema and templates: [`.claude/workspaces/ingest/docs/schema.md`](.claude/workspaces/ingest/docs/schema.md).

### `/lint` — periodic hygiene pass

Run before `/publish` if it's been more than a week, or after a large ingest. Checks for:

- Contradictions across sources
- Stale claims (decisions past their revisit date)
- Orphan pages with no inbound links
- Missing cross-references
- Terminology drift from the glossary
- Confidence miscalibration

Reports findings, asks which to apply, applies approved fixes. Logs the pass to `wiki/log.md`.

Lint criteria detail: [`.claude/workspaces/maintenance/docs/lint-criteria.md`](.claude/workspaces/maintenance/docs/lint-criteria.md).

### `/review-contributions` — process teammate-submitted drafts

Teammates can opt in to send synthesis-grade answers back to you as draft analyses (the user-facing flow is in [`README.md`](README.md)). Drafts land as `.md` files in your contributions Drive folder, named `{date}-{contributor-prefix}-{slug}.md`.

Run weekly (or whenever the queue feels heavy):

```
/review-contributions
```

For each pending draft, the command shows the filename, frontmatter, and full body, then asks **Accept / Edit / Reject**:

- **Accept** writes the draft to `wiki/analyses/<slug>.md` (stripping the date+contributor prefix) and moves the Drive original to `archive/`.
- **Edit** lets you revise the draft in chat, writes the revised version to `wiki/analyses/`, archives the original.
- **Reject** moves the file to `archive/rejected/` (recoverable if you change your mind).

After processing, the command runs `rebuild_referenced_by.py` for any accepted files and reminds you to `/lint` then `/publish` so teammates pick up the new analyses.

**Tuning if it gets noisy:** if the queue exceeds ~10/week or you're rejecting >85%, raise the trigger threshold in [`skills/search-team-wiki/SKILL.md`](skills/search-team-wiki/SKILL.md) Step 3.5 (currently 3+ pages, 300+ words). The duplicate-analysis guard already prevents the most common noise source (multiple teammates asking the same question that's already been merged).

**Retiring the feature:** removal is low-friction — delete Step 3.5 from the skill, delete [`.claude/commands/review-contributions.md`](.claude/commands/review-contributions.md), bump the plugin version, re-publish. Optionally delete the Drive folder (or leave it as a graveyard — older plugin versions will gracefully fall back to local save).

### `/publish` — distribute the snapshot to the team

After any meaningful change set, publish so teammates running `/team-wiki:refresh` pick it up.

```
/publish
```

Or from a terminal: `.claude/scripts/publish.sh`.

The script rebuilds `wiki.zip` from `wiki/`, prints page count + size, and opens the snapshot Drive folder in your browser. **Drag `wiki.zip` into the folder and click "Replace existing file"** when prompted. The file ID stays stable — that's how teammates' `/team-wiki:refresh` keeps working without any plugin update.

> ⚠️ **If you delete + reupload instead of overwriting, the file gets a new ID and every teammate's `/team-wiki:refresh` breaks.** Always overwrite. If it does happen, follow the recovery steps below.

#### Recovering if the file ID changes

If the Drive file gets a new ID (someone deleted + reuploaded instead of overwriting), every teammate's `/team-wiki:refresh` starts failing. To fix:

1. Get the new file ID from Drive.
2. Update both occurrences in [`skills/refresh-team-wiki/SKILL.md`](skills/refresh-team-wiki/SKILL.md).
3. Commit and push to GitHub.
4. Tell teammates to run `/plugin update team-wiki@team-wiki` (or however your plugin is named).

Avoid this by always **overwriting**, never deleting + reuploading.

---

## Less common maintenance

For these, describe the task in chat — the agent routes through the maintenance workspace.

| Task | What happens |
|---|---|
| **Capture a decision** | Uses the template in [`maintenance/docs/decision-capture.md`](.claude/workspaces/maintenance/docs/decision-capture.md), writes to `wiki/decisions/`, links from affected pages. |
| **Resolve a contradiction** | Read [`maintenance/contradictions.md`](.claude/workspaces/maintenance/contradictions.md), confirm which source wins (or that both coexist), update affected pages, mark resolved. |
| **Refresh the sourcing queue** | Open [`maintenance/sourcing-queue.md`](.claude/workspaces/maintenance/sourcing-queue.md), add new asks or remove items now sourced. |
| **Manually edit a page** | Fine — pages are plain markdown, edit directly. Caveat: if the change is a substantive fact update, prefer re-ingesting from the underlying source so `wiki/log.md` reflects it. Manual edits don't get logged. |

---

## Gotchas

- **Never edit `raw/`.** It's append-only. If a source has updated content, drop the new version with a new filename and re-ingest — don't overwrite the old file.
- **`raw/`, `deliverables/`, and `wiki.zip` are gitignored** but live in the repo locally. `wiki.zip` is a build artifact regenerated by `/publish`; `deliverables/` is your scratchpad and never ships in the plugin.
- **Plugin version bumps:** if you change the plugin contract (anything under `skills/`, `commands/`, or `.claude-plugin/plugin.json`), bump `version` in both [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) and [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json) so teammates' plugin managers know to update. Snapshot content changes (wiki/) don't need a bump — `/team-wiki:refresh` handles those.
- **Auto-filed analyses accumulate.** Anything the research workspace files to `wiki/analyses/` is opt-out — skim periodically and delete the ones that didn't earn their keep. Deletion is cheaper than recall.

---

## Pointers

- **Architecture & conventions** → [`AGENTS.md`](AGENTS.md) (folder map, hard rules, naming, citation rules)
- **Task router** → [`CONTEXT.md`](CONTEXT.md) (which workspace for which task)
- **For consumers** → [`README.md`](README.md) (what the plugin does, how teammates use it)
- **Activity log** → [`wiki/log.md`](wiki/log.md) (append-only history of every ingest, lint, decision, merged contribution)
