---
name: search-team-wiki
description: Use when someone asks any question that your team wiki might cover — products, features, competitors, personas, strategy, domain terminology, customers, initiatives, or decisions. Also triggered by "check the wiki", "what do we know about X", "how do we compete with Y", "what's our positioning on Z". Read-only — never writes to the wiki.
---

# Answering from the Team Wiki

## Mental model

The wiki is **silent context**. The user wants a direct, knowledgeable answer — not a tour of the file system. Answer the way a well-briefed colleague would answer in Slack: specific, integrated, confident.

**Never expose:** file paths, entity-type folder names (competitors/, features/, etc.), page slugs, or confidence ratings in the answer prose. Those are your internal navigation tools, not the user's concern.

## Step 0 — Resolve the wiki root

Check in this order:

1. **User overlay (preferred):** `$HOME/.team-wiki/wiki/` — present after the user has run `/team-wiki:refresh`. Always freshest.
2. **Bundled snapshot (fallback):** `<plugin-root>/wiki/` — ships with the plugin. Always present.

Let `WIKI_ROOT` be whichever exists. Check for `$HOME/.team-wiki/wiki/index.md` — if present, use it. Otherwise use the plugin's bundled `wiki/`.

`<plugin-root>` is two directories above this skill file (the directory containing `.claude-plugin/plugin.json`).

## Step 1 — Orient

Read `WIKI_ROOT/index.md`. It is the master catalog of every page, grouped by entity type with one-line summaries and confidence ratings. Skim it to identify which entity types and specific pages are relevant to the question.

For fuzzy or broad questions, also read `WIKI_ROOT/primer.md` — it maps question types to entry pages.

## Step 2 — Pull relevant pages

Open the 3–8 pages most relevant to the question. Before relying on a page, check its `agent_use_cases` frontmatter to confirm it actually covers what you need — the title alone is not enough.

Trust `confidence: high` directly. Treat `confidence: medium` as probable. Flag `confidence: low` or `contested` as uncertain — check `WIKI_ROOT/contradictions.md` if a topic is marked `contested`.

Do not load the full wiki. Pull only what the question needs.

## Step 3 — Synthesize

Write the answer in natural prose. Integrate across pages into one coherent response. Think: how would you explain this to a teammate who just asked?

- Specific and concrete — quote numbers, rules, steps when the pages have them
- Integrated — if 4 pages contribute, give one answer, not 4 summaries
- Cite sources internally as `(source: [[page-slug]])` — but only in writing delivered back to the wiki (analyses). In a conversational answer, cite only if the user asks where something came from
- Mark inferences: prefix with `Inference:` if the wiki implies something but doesn't state it directly
- If the wiki doesn't cover it, say so plainly: "The wiki doesn't document that specifically." Then offer what's adjacent

## Step 3.5 — Contribute back (when criteria met)

If your answer met **all three** of these criteria:

1. Synthesized **3+ wiki pages** (not a single-page lookup)
2. Ran **>300 words**
3. Answered a substantive question about your team's domain (products, customers, competitors, strategy, decisions, metrics, etc.)

…then after the answer, append a one-line prompt on its own line:

> *This answer synthesized [N] pages — analysis-worthy. Want me to send it to the maintainer as a contribution to the wiki?*

### If the user says yes

**Before generating anything, check for an existing merged analysis.** Slug the question into kebab-case from the key terms and check whether `WIKI_ROOT/analyses/<slug>.md` already exists. If it does, tell the user:

> *Heads up — there's already a merged analysis on this question (your answer likely drew from it). I won't send a duplicate. If you think your angle adds something new, ping the maintainer directly.*

Then skip the rest of this flow — do not proceed to email, generate, or upload.

Otherwise:

1. **Get the contributor's email prefix** (for attribution and dedupe):
   - Check `$HOME/.team-wiki/.user-email` — if it exists, use it.
   - Otherwise ask once: "What's your work email prefix (e.g., `sarah` from `sarah@<YOUR_DOMAIN>`)?" — save the answer to that file so you never ask again.

2. **Generate the analysis markdown** using the template in [`../../.claude/workspaces/research/docs/analysis-template.md`](../../.claude/workspaces/research/docs/analysis-template.md) (if present in the bundled snapshot) or this structure:

   ```markdown
   ---
   title: <Question as a statement, title-cased>
   type: analysis
   created: <today as YYYY-MM-DD>
   sources: [<list of wiki page slugs you drew from>]
   tags: [<topical tags>]
   confidence: <your honest assessment: high | medium | low>
   agent_use_cases:
     - <one-line use case for this analysis>
   contributor: <email prefix>
   ---

   # <Title>

   ## Summary
   <One-paragraph bottom line.>

   ## Question
   <Restate the original question.>

   ## Key Findings
   - <Finding> (source: [[page-slug]])
   - <Finding> (source: [[page-slug]])

   ## <Body sections as needed>

   ## Open Questions / Gaps
   - <What you couldn't answer from the wiki>

   ## Related Pages
   - [[<page-slug>]]
   ```

3. **Slug the filename:** `{YYYY-MM-DD}-{email-prefix}-{question-slug}.md` (e.g., `2026-05-16-sarah-vendor-x-vs-vendor-y.md`). The date+prefix gives the maintainer provenance and prevents collisions.

4. **Upload to the contributions Drive folder.** Folder ID: `<YOUR_CONTRIBUTIONS_FOLDER_ID>` (the `team-wiki-contributions` folder the maintainer owns — see `MAINTAINING.md` for setup). Use whatever upload tool the Drive MCP exposes (commonly `create_file`, `upload_file`, or `gdrive_upload` — pass `name`, `parents=["<YOUR_CONTRIBUTIONS_FOLDER_ID>"]`, and `content`).

5. **On success:** confirm in one line: *"Sent — the maintainer will review and merge if useful. Thanks for contributing."*

6. **On failure** (no Drive write tool, no folder access, upload errors): fall back to local save. Write to `$HOME/.team-wiki/contributions/<slug>.md` (create the directory if missing) and tell the user: *"Couldn't upload to Drive — saved at `~/.team-wiki/contributions/<slug>.md`. Forward this file to the maintainer directly."*

### If the user says no or doesn't respond

Drop it. Don't push. Move to Step 4.

## Step 4 — Follow-up

End with one concrete continuation prompt. Examples:
- "Want me to pull the comparison with [related entity] side by side?"
- "Should I check what the [adjacent perspective] looks like — it differs?"
- "Want me to draft the customer-facing version of this?"
- "Need the specific steps for [sub-task]?"

## When to break the defaults — ONLY on explicit request

**Source attribution** ("where did that come from", "what page", "show me the source"): name the wiki page(s) you drew from.

**Full page text** ("show me the full page on X", "paste the article"): read the file, paste verbatim.

**Confidence caveat** ("how reliable is this", "is this up to date"): surface the `confidence` rating and note what it means.

## If the wiki can't answer

Say so plainly. No apology. Offer what's adjacent if anything. Then: "If you know the answer, let the maintainer know and they can add it to the wiki."

## Absolute rules

- **Never write to the wiki itself.** Read-only. The only allowed write is uploading a contribution draft to the `team-wiki-contributions` Drive folder, and only with explicit user consent per Step 3.5.
- **Never invent content.** If the wiki doesn't say it, you don't know it — say so.
- **Never expose file paths or folder structure** in a conversational answer.
- **`confidence: low` or `contested` pages** must be flagged as uncertain in your answer. Don't present them as fact.
- **Glossary first for domain terms.** Check `WIKI_ROOT/glossary.md` before paraphrasing any term — domain terms are precise and often legally or technically loaded.
- **Contribute-back is opt-in only.** Never auto-upload. The user must explicitly approve before a draft is sent to Drive.
