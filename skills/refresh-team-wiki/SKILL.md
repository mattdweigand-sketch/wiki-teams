---
name: refresh-team-wiki
description: Use when the user asks to refresh or update the team wiki. Triggered by "/team-wiki:refresh", "update the wiki", "pull the latest", "get the maintainer's updates". Downloads the latest wiki snapshot from Google Drive and updates the user's local copy. Requires Google Drive connector.
---

# Refreshing the Team Wiki

## What this does

Downloads the latest wiki snapshot (a zip of all pages) from a pinned Google Drive file and replaces the user's local copy. Takes ~5–10 seconds. Run it whenever the maintainer has pushed an update.

## Where data lives

All writes go to the user overlay — never to the plugin directory (read-only on Cowork installs):

- **User overlay:** `$HOME/.team-wiki/`
- **User wiki:** `$HOME/.team-wiki/wiki/`

`<plugin-root>` is two directories above this skill file (the directory containing `.claude-plugin/plugin.json`).

## Prerequisites — fail fast

1. Confirm the Google Drive MCP connector is available (look for `download_file_content` from a Drive-style server). If not, stop: "Google Drive connector is not loaded in this session. Enable it and retry."

## Hardcoded file ID

The wiki zip lives at a single stable Drive file. Do not search — go directly to download.

```
wiki.zip  →  fileId: <YOUR_SNAPSHOT_FILE_ID>
```

This file lives in the pinned Drive folder `<YOUR_SNAPSHOT_FOLDER_ID>`. The maintainer overwrites it (same file ID) whenever they push a new snapshot — do not search Drive for alternatives. See `MAINTAINING.md` for one-time Drive setup.

**If download fails with "file not found":** the file ID may have changed (Drive reassigns IDs on delete+reupload). Stop and report: "Drive file ID is no longer valid. The maintainer needs to re-upload the wiki zip and update the file ID in `skills/refresh-team-wiki/SKILL.md`."

## Workflow

### Step 0 — Bootstrap (first run only)

If `$HOME/.team-wiki/wiki/` does not exist:

```bash
mkdir -p "$HOME/.team-wiki"
cp -R "<plugin-root>/wiki" "$HOME/.team-wiki/wiki"
```

Skip if it already exists.

### Step 1 — Download

Call `download_file_content("<YOUR_SNAPSHOT_FILE_ID>")` without `exportMimeType`. Write bytes to `$HOME/.team-wiki/wiki.zip.tmp`.

### Step 2 — Validate

Check that:
- The file is non-empty
- It is a valid zip archive
- It contains `index.md` at its root

If validation fails, delete `$HOME/.team-wiki/wiki.zip.tmp` and abort: "Downloaded file is not a valid wiki snapshot. The maintainer may need to re-upload."

### Step 3 — Atomic unpack

```bash
python3 -c "
import zipfile, shutil, os, pathlib

overlay = pathlib.Path.home() / '.team-wiki'
tmp_zip = overlay / 'wiki.zip.tmp'
tmp_dir = overlay / 'wiki.tmp'
final_dir = overlay / 'wiki'

# Unpack to temp dir
if tmp_dir.exists():
    shutil.rmtree(tmp_dir)
with zipfile.ZipFile(tmp_zip) as zf:
    zf.extractall(tmp_dir)

# Count pages
page_count = len(list(tmp_dir.rglob('*.md')))

# Atomic swap
if final_dir.exists():
    shutil.rmtree(final_dir)
tmp_dir.rename(final_dir)
tmp_zip.unlink()

print(page_count)
"
```

Capture stdout — it is the page count for the report.

### Step 4 — Report

Print:

```
Team wiki updated.
<N> pages now available locally.

Search with /team-wiki:search or just ask a question.
```

If the page count equals what was bundled with the plugin (no net change), add: "No new pages since the last refresh."

## Absolute rules

- **Never write to the plugin directory.** Always write to `$HOME/.team-wiki/`.
- **Never push to Google Drive.** Download only.
- **Always clean up `wiki.zip.tmp` and `wiki.tmp`** — delete them on success and on any failure after Step 1.
- **Never leave the wiki in a half-replaced state.** If the atomic swap fails partway through, report the error and tell the user their previous wiki copy is still intact at `$HOME/.team-wiki/wiki/`.
