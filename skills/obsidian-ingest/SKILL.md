---
name: obsidian-ingest
description: >
  Process raw source material from the Obsidian Inbox into structured wiki pages — the "ingest"
  operation from the LLM Wiki pattern. Reads the source, discusses key takeaways, writes a summary
  page, creates/updates entity and concept pages, updates the Wiki Index, cross-references related
  notes, and archives the original. A single source may touch 10–15 wiki pages. Trigger whenever the
  user says: "ingest this", "process this note", "process my inbox", "add this to the wiki", "file
  this article", "what's in my inbox", "integrate this into the vault", or points at a note in
  `00 Inbox/`. Also trigger when the user drops a URL or article for structured knowledge capture.
  Use aggressively whenever uncategorised content needs absorbing into the knowledge base.
compatibility: >
  Requires Obsidian MCP tools: create_note, read_note, search_vault, list_files, append_to_note,
  str_replace_in_note, daily_append, get_tag_info, get_links, get_backlinks, list_properties,
  project_list, project_context
---

# Obsidian Ingest

You are processing raw source material into structured, interlinked wiki pages in an Obsidian vault. This is the "ingest" operation from the LLM Wiki pattern: the source is read once, its knowledge is compiled into the wiki, and from then on the wiki — not the raw source — is what gets queried and built upon. Every source should make the entire vault richer, not just add another disconnected note.

The key difference from brainstorm-to-obsidian: brainstorm captures ideas from *this conversation*. Ingest processes *external source material* — articles, papers, web clippings, rough notes — and weaves their knowledge into the existing vault.

## Before You Start

**Read the shared vault operations reference** at `shared/VAULT-OPS.md` (relative to the plugin root). It contains vault conventions, PARA routing, cross-referencing, Wiki Index management, and other shared operations you'll need. For callout types, wikilink syntax, and formatting details, consult `shared/OBSIDIAN-MARKDOWN.md`.

## Workflow

### Step 1: Identify the Source

The user will either point at a specific note or ask to process inbox contents.

**If a specific note:** Read it with `obsidian:read_note`.

**If "what's in my inbox" or similar:** List contents with `obsidian:list_files` on `00 Inbox/` and `00 Inbox/Clippings/`. Present a summary and let the user pick which to process. Don't batch-ingest without asking.

**Source types you'll encounter:**
- **Web clippings** (tagged `#clippings`) — articles from Obsidian Web Clipper. Have `source` URL, sometimes `author` and `published`. Body is markdown.
- **Rough notes** — the user's own jottings, often terse. May contain multiple unrelated topics.
- **Papers/PDFs** — academic content, sometimes structured abstracts. May come from the literature-search skill.
- **Mixed notes** — a clipping with unrelated notes appended. Flag this — ask whether to split or merge.

**If the source contains multiple unrelated topics**, flag this immediately. Ask whether to split into separate ingests.

### Step 2: Read and Analyse

Read the full source. Identify:

1. **What is this?** Article, tutorial, reference, clinical paper, personal notes?
2. **Core claims and takeaways** — What does this source actually say? What's novel?
3. **Entities** — People, organisations, tools, drugs, conditions, techniques. Candidates for entity pages.
4. **Concepts** — Ideas, patterns, frameworks, methods. Candidates for concept pages.
5. **Connections** — Run `obsidian:search_vault` on 2–3 distinctive terms to find related vault notes.
6. **Contradictions** — Does this disagree with anything already in the vault? Flag it.

### Step 3: Discuss with the User

Present your analysis as a concise briefing before writing anything:

```
📄 Source: [name and type]
🔑 Key takeaways: [2–4 points, prose not fragments]
🔗 Vault connections: [existing notes this relates to]
⚡ Contradictions/updates: [anything that challenges existing vault content]
📝 Proposed actions:
  - Summary page: [proposed title and location]
  - Entity pages to create/update: [list]
  - Concept pages to create/update: [list]
  - Notes to cross-reference: [list]
```

Wait for confirmation. The user might say "just the summary" or "route it to PAVE-2." Not every source needs the full treatment.

### Step 4: Route the Summary Page

Follow the PARA routing decision tree in VAULT-OPS.md. Tell the user your decision before proceeding.

### Step 5: Write the Summary Page

The primary output — a wiki-style summary that makes the source queryable without re-reading the original.

```markdown
---
created: YYYY-MM-DD
date: YYYY-MM-DD
status: active
description: "One-sentence summary of the source content"
tags:
  - claude
  - ingest
  - topic-tag-1
  - topic-tag-2
author: "Original author if known"
source: "URL or reference"
aliases:
  - "Alternative name if the filename is a slug"
---

# Descriptive Title

## Summary

2–4 paragraphs capturing the core content in prose. Include the source's main argument,
key evidence, and why it matters. Rich enough that someone reading only this page
understands the source without needing the original.

## Key Points

Important specific claims, findings, or recommendations. Each gets a short paragraph
with context. Use verified [[wikilinks]] to connect to existing vault notes.

> [!tip] Key Insight
> The single most important takeaway, if one stands out.

## Relevance

How does this connect to existing vault knowledge? What does it add, confirm, challenge,
or extend? This is the synthesis — what makes the wiki compound.

## Entities and Concepts

Brief notes on important entities/concepts, with links to dedicated pages if they
exist or will be created next.

## Source Details

| Field | Value |
|-------|-------|
| Type | Article / Paper / Tutorial / etc. |
| Author | Name |
| Published | Date if known |
| Source | URL or reference |
| Ingested | YYYY-MM-DD |

## Related Notes

- [[Related Note]] — one-sentence context on the connection
```

**Formatting notes:**
- Tags: always `claude` + `ingest` + 2–4 topic tags (follow tag selection in VAULT-OPS.md).
- Length: 400–800 words. Longer sources get more aggressive synthesis.
- Ugly slug filenames from web clips → clean filename + slug as `alias`.

### Step 6: Create or Update Entity/Concept Pages

This is what makes ingest more than summarising. Important entities and concepts deserve pages that accumulate knowledge across sources.

**Always search first** with `obsidian:search_vault`.

#### Updating an existing page

1. Read it with `obsidian:read_note`.
2. Add new information — don't rewrite what's there.
3. Use `obsidian:append_to_note` or `obsidian:str_replace_in_note`.
4. Add a back-reference to the new summary page.
5. Flag contradictions with `> [!warning]` callouts rather than silently overwriting.

#### Creating a new page (selectively)

Not every mention deserves a page. Create when:
- The entity appears in multiple vault notes.
- It's central to the source, not passing.
- The user is likely to encounter it again.

```markdown
---
created: YYYY-MM-DD
date: YYYY-MM-DD
status: active
description: "One-sentence description"
tags:
  - claude
  - entity or concept
  - topic-tags
---

# Entity or Concept Name

## Overview

2–3 paragraphs. Synthesise from the source and existing vault knowledge.

## Key Details

For a drug: mechanism, indications, evidence. For a tool: purpose, strengths, limitations.
For a person: role, contributions, relevance.

## Sources

- [[Summary Page]] — what this source says about the entity
```

**Limit:** 3–5 new entity/concept pages per ingest. Always tell the user which you're creating.

### Step 7: Cross-Reference, Index, and Log

Execute the shared operations from VAULT-OPS.md in order:

1. **Cross-reference** — Follow bidirectional cross-referencing (3–5 related notes, contextual back-references).
2. **Wiki Index** — Add categorised entry + entity page entries + log row (operation type: `ingest`).
3. **Daily breadcrumb** — `- Source ingested: [[Summary Page]] (#claude #ingest)`

### Step 8: Archive the Original (Optional)

Ask if the user wants the source moved to `04 Archive/Ingested/`. The original is immutable source of truth — don't modify or delete it. Since Obsidian MCP lacks a move operation, tell the user to drag it in Obsidian, or offer to copy it and flag the original for manual deletion.

### Step 9: Summary Report

Follow the summary report format in VAULT-OPS.md. Include entity/concept page counts and archive status.

## Source Type Guidance

### Web Clippings (#clippings)

Most common source. Watch for: images not downloaded locally, broken web clipper formatting, paywall teasers (flag — don't summarise what isn't there).

### Academic Papers

Include structured fields: study design, population, intervention, primary outcome, key results, limitations. Check for a Research Paper Notes template via `obsidian:list_templates`. Entity pages often include: the drug/intervention, condition, key authors, trial name.

### Personal Notes / Rough Jottings

Need more interpretation. Ask for clarification if too cryptic. Your job is to expand terse notes into something future-self can understand.

### Mixed Notes (Multiple Topics)

Split into separate summary pages per topic. Confirm with user first.

## Edge Cases

- **Trivial/ephemeral source** (a to-do, a reminder) — tell the user it's not wiki material. Offer to leave in Inbox or archive.
- **Duplicates existing content** — flag, offer to merge/skip/update.
- **Very long source** (>3000 words) — summarise aggressively to 400–800 words.
- **No author or date** — leave fields blank, don't guess.
- **URL pasted in chat** — use `web_fetch`, process as clipping. Create summary directly.
- **Batch processing** — one at a time with confirmations between each.
- **ChatGPT conversation imports** (~30 in `00 Inbox/My ChatGPT Conversations/`) — triage first: flag any worth preserving, suggest archiving the rest.
