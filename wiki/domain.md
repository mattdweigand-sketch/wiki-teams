---
title: Domain Config
type: domain
created: 2026-05-17
updated: 2026-05-17
status: unconfigured
org: <Organization name>
domain: <One-line domain summary, e.g. "developer tools for payments">
entity_types_active:
  - source
  - product
  - feature
  - persona
  - customer
  - competitor
  - concept
  - initiative
  - decision
  - metric
  - person
  - analysis
  - style
entity_types_custom: []
raw_taxonomy: []
example_queries: []
team_features_enabled: false
plugin_name: team-wiki
drive_snapshot_folder_id: <YOUR_SNAPSHOT_FOLDER_ID>
drive_snapshot_file_id: <YOUR_SNAPSHOT_FILE_ID>
drive_contributions_folder_id: <YOUR_CONTRIBUTIONS_FOLDER_ID>
---

# Domain Config

Single source of truth for **who this wiki is about** and **whether team-plugin features are enabled**. Framework files defer to this page instead of hardcoding values.

## Status

When `status: unconfigured` (the default for a fresh clone), this wiki is a blank template. An agent in a new session should notice this flag and route to [`../SETUP.md`](../SETUP.md), which walks the user through an interview to fill this file out.

When `status: configured`, the wiki is ready to ingest sources and answer questions.

## Fields

### Domain identity

| Field | Meaning |
|---|---|
| `org` | The organization (company, team, project) this wiki is about |
| `domain` | One-line description of the subject area |
| `entity_types_active` | Subset of the 13 entity types from [`schema.md`](../.claude/workspaces/ingest/docs/schema.md) that this wiki uses. Drop any that don't fit your domain. |
| `entity_types_custom` | Any new entity types this domain needs that aren't in the default 13 |
| `raw_taxonomy` | Subfolder names that should exist under `raw/` for source-document organization |
| `example_queries` | 3–5 questions the wiki should answer well — useful for sanity-checking coverage |

### Team-plugin features (team-edition only)

| Field | Meaning |
|---|---|
| `team_features_enabled` | `true` if you've set up Drive snapshot/contributions folders and want teammates to install this as a Cowork plugin. `false` if you're using the wiki solo or haven't done Drive setup yet. |
| `plugin_name` | Default `team-wiki`. Determines slash commands (`/team-wiki:search`, `/team-wiki:refresh`) and skill folder names. |
| `drive_snapshot_folder_id` | Drive folder ID where `wiki.zip` lives. Used by `.claude/scripts/publish.sh`. |
| `drive_snapshot_file_id` | Drive file ID of the pinned `wiki.zip`. Used by `skills/refresh-team-wiki/SKILL.md`. |
| `drive_contributions_folder_id` | Drive folder ID where teammate contribution drafts land. Used by `.claude/commands/review-contributions.md` and `skills/search-team-wiki/SKILL.md`. |

If `team_features_enabled: false`, the `<YOUR_*>` placeholders in the four plugin-config files are inert — the wiki still works locally for the maintainer; teammates just can't refresh or contribute back.

## After configuration

The agent updates this file's `status:` to `configured`, replaces `<Organization>` placeholders in the framework files (see [`../SETUP.md`](../SETUP.md) for the exact list), and appends a log entry to [`log.md`](log.md). If setup rewrites the project operating map, update [`../AGENTS.md`](../AGENTS.md). [`../CLAUDE.md`](../CLAUDE.md) is only a Claude Code wrapper.
