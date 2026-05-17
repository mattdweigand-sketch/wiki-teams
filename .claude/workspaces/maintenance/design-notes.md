---
title: Design Notes — Divergences from the Karpathy LLM-Wiki Pattern
type: style
sources: []
tags: [meta, design, schema, agent-context-layer]
confidence: high
---

# Design Notes

The Karpathy LLM-wiki pattern, purpose-fit to serve **downstream AI agents** (not a single human reader). Documents what was kept, what was changed, and why. Keep this when you fork — it's the rationale for several non-obvious schema choices.

---

## Background

This wiki is built on the [Karpathy LLM-wiki pattern](https://karpathy.ai/zero-to-one/) — three layers (raw / wiki / schema), a small set of operations (ingest, query, lint), and persistent compounding artifacts (index + log). The original framing is generic and deliberately abstract; Karpathy's note explicitly says "your LLM can figure out the rest" for any specific instantiation.

This file documents the rest.

---

## What was kept verbatim

| Karpathy element | What it gives us |
|---|---|
| **Three-layer architecture** (raw / wiki / schema) | Clean separation between immutable inputs and the LLM-owned synthesis |
| **Ingest / query / lint operations** | Reproducible workflows, surface in CLAUDE.md |
| **`index.md` + `log.md`** | Content catalog + chronological history; works at this scale without an embedding store |
| **Confidence tiers in frontmatter** | Lets downstream agents weight claims without re-deriving |
| **Citations on every fact** | Traceability back to raw sources |
| **Compounding** — update existing pages, don't overwrite | Knowledge graph grows in place |
| **`[[wikilink]]` cross-references** | Cheap graph structure with no infra |
| **Filing query outputs back as analyses** | Conversations become durable artifacts |

---

## Where the pattern doesn't fit a team context layer — and what was changed

The Karpathy pattern assumes a **single human** reading their own wiki. This wiki's purpose is to be a **company context layer for downstream AI agents**, distributed to a team via plugin. That shift forces several modifications.

### 1. Pages must declare what they are *for*, not just what they contain

**Problem.** A human reader browses the wiki and infers a page's relevance. A downstream agent retrieves *one* page and acts on it. Without explicit guidance, the agent either over-trusts or skips it.

**Change.** Every retrievable page carries an `agent_use_cases` frontmatter field listing the question types it is designed to answer. Pages also carry an explicit "What this page is good for" / "What this page does NOT cover" structure where appropriate.

**Excluded from this rule.** Infrastructure pages — `sources/`, `index.md`, `log.md`, `glossary.md`, and `style/` rules — are not retrievable answers and don't need `agent_use_cases`.

### 2. Sources are heterogeneous and need typed handling

**Problem.** The Karpathy pattern treats sources uniformly. The reality of any organization: you will ingest help-center docs, Slack threads, sales call transcripts, exec memos, board decks, CRM dumps, analyst reports, and competitor collateral. A blanket summary template wastes the differential signal in each.

**Change.** Source pages carry a `source_type` frontmatter field. The schema doc defines a per-type summary template — what to emphasize, what to treat with care. A `slack-thread` summary highlights who said what and open threads; a `deck` summary captures claims as bullet points; a `crm-export` summary preserves structured data.

### 3. Disagreement is the norm, not the exception

**Problem.** A personal wiki rarely sees multi-source contradiction. A company context layer ingests sales positioning, product reality, and exec narrative — these *will* disagree. Burying disagreement in page bodies makes it invisible to retrieval.

**Change.** Two additions:
- A new `confidence: contested` value, indicating active disagreement across sources. Pages with this confidence must include a "Disagreement" section naming sources on each side.
- A first-class [[contradictions]] tracker that lists every open disagreement, the sources, the affected pages, and resolution status. Lint pass updates it.

### 4. Empty entity types are the differentiating content

**Problem.** Karpathy's pattern says empty index sections "signal coverage gaps." Fine for a personal wiki. For a company context layer, the empty types — **customers, competitors, decisions, metrics, initiatives, people** — are exactly what makes this more valuable than indexed documentation. Help-center docs alone never fill them.

**Change.** A [[sourcing-queue]] page that names the artifact most likely to close each gap (CRM export → customers; win/loss interviews → competitor positioning; board deck → strategic initiatives; KPI dashboard → metrics). The queue is reprioritized after every ingest.

### 5. Decisions deserve a dedicated capture flow

**Problem.** Decisions surface organically in conversation — "we decided to do X because Y, rejected Z." Karpathy's pattern catches them only on ingest of a written source. Most decisions are never written down.

**Change.** A `capture-decision` workflow. Treats decisions as a first-class operation alongside ingest/query/lint. Captures decision + reasoning + alternatives rejected + revisit-when. Decision pages cross-link to affected products, initiatives, and metrics.

### 6. Cold-start agents need a directed entry point

**Problem.** A human has session context — they remember why they're here. A downstream agent invoked fresh has none. A flat index forces it to over-read or guess.

**Change.** A [[primer]] page: "if you have zero context, here is what to read first based on the question you're answering." Maps question types (sales discovery, product positioning, competitor framing, exec brief) to entry-page sequences.

### 7. Style rules ship with the wiki, not bolted on later

**Problem.** Karpathy lists `style/` as one of many directories. For a wiki that downstream agents *generate content on top of*, voice and naming consistency is load-bearing — not nice-to-have.

**Change.** `style/` is seeded before downstream agents run, not after. Initial pages: voice, naming conventions, citation style, structural patterns for agent-generated outputs.

### 8. We do not optimize for human-UX surfaces

**Problem.** Karpathy's "Tips and tricks" lean heavily on Obsidian (graph view, Dataview, Marp). These are human-reader features. The primary consumer here is an agent.

**Change.** No Obsidian dependency. Markdown-first, retrieval-first. If tooling is added later it should improve agent retrieval (e.g., BM25/vector search), not human browsing.

### 9. Multi-consumer distribution (team variant only)

**Problem.** A solo wiki lives in one repo on one machine. A team wiki has one maintainer producing it and many teammates consuming it — without giving them write access to the underlying corpus.

**Change.** A Cowork plugin layer (`commands/`, `skills/`, `.claude-plugin/`) so teammates can search and refresh the wiki from inside Claude Code. A pinned Drive snapshot as the distribution channel (`/publish` builds, `/<plugin>:refresh` consumes). An opt-in contribute-back flow that lets teammates submit synthesis-grade answers to the maintainer for review without granting repo write access. See `MAINTAINING.md` for the operator detail.

---

## Operational summary of additions

| Addition | Where it lives | Maintained when |
|---|---|---|
| `agent_use_cases` frontmatter | every retrievable page | created/updated |
| `source_type` frontmatter + summary templates | `wiki/sources/*` and schema doc | every source ingest |
| `confidence: contested` | any page | when sources disagree |
| [[contradictions]] tracker | `.claude/workspaces/maintenance/contradictions.md` | every ingest + lint |
| [[sourcing-queue]] | `.claude/workspaces/maintenance/sourcing-queue.md` | every ingest + `refresh-sourcing-queue` |
| `capture-decision` workflow | maintenance workspace + `wiki/decisions/*` | as decisions surface |
| [[primer]] page | `wiki/primer.md` | when entry-point structure changes |
| Seeded style rules | `wiki/style/*` | as conventions stabilize |
| Plugin distribution layer | `.claude-plugin/`, `commands/`, `skills/` | when plugin contract changes |
| Contribute-back flow | `search-team-wiki` Step 3.5 + `/review-contributions` | every review pass |

---

## What we are deliberately *not* doing

- **No embedding-based RAG infrastructure.** At ~60–500 pages, the index file is sufficient. Revisit when the index is hard to fit in a single agent context window.
- **No Obsidian, Dataview, or Marp.** Human-UX features. Add only if a clear retrieval need emerges.
- **No automatic source ingestion.** Every ingest is human-initiated and human-supervised. Compounds slower, but quality stays high and the schema co-evolves with the corpus.
- **No per-page change history beyond git.** Git is enough.
- **No teammate write access to the canonical wiki.** Contributions go through Drive review, not direct edits. Keeps the maintainer's editorial bar in place.

---

## When to revisit this document

- After a significant ingest type appears that doesn't fit the existing `source_type` taxonomy
- After downstream agents start consuming the wiki and you observe what they get wrong
- When `index.md` exceeds a comfortable single-read context (suggesting you need search infra)
- When the team contributing back grows past the maintainer's review capacity (suggesting you need stricter triggers or batched review)

---

## Related pages

- [[primer]] — cold-start guide for downstream agents
- [[sourcing-queue]] — what to ingest next
- [[contradictions]] — open disagreements across sources
- [[index]] — full catalog
- [[overview]] — company synthesis
