---
description: Review pending team-wiki contributions submitted by teammates via the search-team-wiki skill. Lists drafts in the `team-wiki-contributions` Drive folder, lets you accept (move to wiki/analyses/), edit, or reject each one. Archives processed files in Drive so the queue stays clean.
---

# Review Team Wiki Contributions

Pulls drafts from the contributions Drive folder one at a time, asks you to accept / edit / reject, and handles the bookkeeping (writing to `wiki/analyses/`, moving Drive files to archive, rebuilding backlinks).

## Folder layout in Drive

```
team-wiki-contributions/        (parent, owned by the maintainer)
├── <pending drafts as flat .md files>
└── archive/                    (lazy-created on first accept/reject)
    ├── <accepted drafts, after merge>
    └── rejected/               (lazy-created on first reject)
        └── <rejected drafts, kept for audit>
```

**Parent folder ID:** `<YOUR_CONTRIBUTIONS_FOLDER_ID>` — paste yours here. See `MAINTAINING.md` for one-time Drive setup.

Archive subfolders are **not** hardcoded — discover them by listing the parent folder for child folders named `archive` and `archive/rejected`. If they don't exist, create them via the Drive MCP's create-folder tool the first time you need to write to them.

## Workflow

### Step 0 — Prereqs

Confirm the Google Drive MCP connector is loaded. If not, stop with: "Google Drive connector required for review-contributions."

### Step 1 — Discover folders and list pending

1. List the children of folder `<YOUR_CONTRIBUTIONS_FOLDER_ID>`.
2. Find or create the `archive/` subfolder (look for a child folder named `archive`; if absent, create it and cache its ID for this session).
3. Find or create the `archive/rejected/` subfolder inside `archive/` (same pattern).
4. The pending queue is every `.md` file in the parent folder (top-level, not inside `archive/`). Each follows the naming pattern `{date}-{contributor}-{slug}.md`.

If empty: report "No pending contributions." and stop.

If 10+: list filenames with one-line summaries first, then ask which to review (in order, batch, or specific picks). Don't review 10 cold without orientation.

### Step 2 — Per-file review

For each contribution:

1. **Download** the file content via `download_file_content(file_id)`.
2. **Show:**
   - Filename (gives date + contributor + topic at a glance)
   - Frontmatter block (`sources`, `confidence`, `tags`, `agent_use_cases`, `contributor`)
   - Full body
3. **Ask:** "Accept, edit, or reject?"

**Accept:**
- Strip the `{date}-{contributor}-` prefix from the filename → final slug is `{question-slug}.md`.
- Write to `wiki/analyses/<question-slug>.md`. Preserve frontmatter and body as-is.
- Move the Drive file to the `archive/` subfolder discovered in Step 1 (use the Drive MCP's move/update tool — typically `update_file(file_id, parents=[archive_folder_id], remove_parents=[parent_folder_id])`).

**Edit:**
- Show the content in chat as a markdown block for the maintainer to revise inline, OR ask the maintainer to paste the edited version back.
- Save the revised version to `wiki/analyses/<question-slug>.md`.
- Move the original Drive file to `archive/` (the version in `wiki/analyses/` is the canonical edited one; the Drive original is preserved for audit).

**Reject:**
- Move the Drive file to `archive/rejected/` discovered in Step 1.
- Optionally ask the maintainer for a one-line reason and prepend it to the file as an HTML comment before moving (so the rejection rationale is recoverable).

### Step 3 — Wrap up

After all files processed:

1. If any were accepted or edited, run:
   ```bash
   python3 .claude/commands/rebuild_referenced_by.py
   ```
   to refresh backlinks across the wiki.

2. Print a summary:
   ```
   Reviewed: N
   • Accepted: M
   • Edited:   P
   • Rejected: Q
   ```

3. If any were accepted or edited, remind: "Run `/lint` to check the new pages, then `/publish` to push to teammates."

## Notes

- Never auto-merge. Every contribution gets explicit Accept/Edit/Reject from you.
- The `wiki/log.md` should get an entry per merge — append a `contribution-merged` entry with date, contributor, slug.
- If a contribution duplicates an existing analysis (same slug already in `wiki/analyses/`), surface that to the maintainer before writing. Options: (a) reject as dup, (b) merge contributor's content into the existing page as an update, (c) rename the contribution's slug if it's actually a different angle.
