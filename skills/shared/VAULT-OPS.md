# Vault Operations Reference

Shared conventions and operations used by all Obsidian vault skills (brainstorm-to-obsidian, obsidian-ingest, vault-lint, etc.). This file is the single source of truth — when vault structure or conventions change, update here and all skills stay in sync.

## Vault Structure

The vault uses PARA (Tiago Forte):

| Folder | Purpose |
|---|---|
| `00 Inbox/` | Unsorted captures, triage queue. Web clips land in `00 Inbox/Clippings/`. |
| `01 Projects/` | Active work with defined outcomes |
| `02 Area/` | Ongoing responsibilities (`Work/`, `Personal/`) |
| `03 Resources/` | Reference material by topic |
| `04 Archive/` | Completed or inactive material. Ingested sources go to `04 Archive/Ingested/`. |
| `meta/` | Templates, Wiki Index, vault infrastructure |

## The Wiki Index Is Your Router — Read It First

Before searching the vault, **read `meta/Wiki Index.md` once.** It is a curated catalogue of every Claude-maintained note and is designed to answer most "where does this go / what's already here / what can I link to" questions from a single read — instead of a cascade of live `search_vault`, `get_tag_info`, and `read_note` round-trips.

Each index entry carries enough to route, tag, and link without re-querying the vault:

```markdown
- [[note-filename]] · `type` · #tag1 #tag2 — One-sentence description (YYYY-MM-DD)
```

- **The wikilink uses the note's filename**, so the index doubles as the **link-target registry** — verify a candidate `[[link]]` by checking it appears here, no search needed.
- **The `type` and folder section** tell you the routing landscape (which projects/areas/resource clusters exist) without `project_list`/`project_context`.
- **The inline `#tags`** across entries are your **working tag vocabulary** — reuse from here instead of probing `get_tag_info` for every candidate.

**Fall back to live tools only for what the index can't answer:** a topic that may exist but predates the index, disambiguating a near-duplicate filename, or confirming a tag's exact spelling/count before creating a new one. When you do search, **batch the independent searches in a single turn** rather than firing them sequentially.

If the index is missing, stale, or thin, degrade gracefully to the live-search workflow below — and flag it so vault-lint can backfill `type`/`tags` on its next run.

## Vault Conventions

These are documented in `meta/Vault Conventions and Decisions Log.md`. If in doubt, read that note for the full rationale.

### Filename = Title

No `title` frontmatter property on new notes. The filename is the title. Use `aliases` for cases where a note needs alternative names for link resolution (e.g., web-clipped articles with ugly slugs).

### Frontmatter Schema

All property keys are lowercase. The core properties are:

| Property | Type | Usage |
|---|---|---|
| `created` | date | When the note was created (YYYY-MM-DD) |
| `date` | date | Primary date for sorting/filtering |
| `type` | text | Kind of note: `brainstorm`, `summary`, `entity`, `concept`, `hub`, `report`. Drives Wiki Index routing, Bases filtering, and aligns with the OKF `type` convention. |
| `status` | text | `active`, `draft`, `complete`, `archived` |
| `description` | text | One-sentence summary for search and Bases |
| `tags` | list | Topic tags |
| `author` | text | Author of source material (not the note creator) |
| `source` | text | URL or reference for clipped/imported content |
| `aliases` | list | Alternative names for link resolution |

Notes created by Claude always include `#claude` in tags.

### Wikilink Rules

Obsidian resolves wikilinks by **filename**, not by the `title` frontmatter property. This matters because getting it wrong creates phantom empty notes.

**Before including any `[[wikilink]]`:**
1. **Check the Wiki Index first** — if the target appears there, its entry already gives you the correct filename; no search needed.
2. Only if it's *not* in the index, search with `obsidian:search_vault` to confirm the note exists, and use `obsidian:read_note` on the candidate to check the actual **file path**.
3. The wikilink uses the filename (without `.md`), not any title or heading.

**Example:** If a note's file path is `03 Resources/Claude/claude-code-obsidian-ai-knowledge-base.md`, the correct link is `[[claude-code-obsidian-ai-knowledge-base]]` — never `[[Using Claude Code and Obsidian for AI-Assisted Knowledge Management]]`.

A broken link is worse than no link. When in doubt, omit it.

## Tag Selection

The vault has 185+ tags. Reusing existing tags matters more than inventing the perfect taxonomy.

1. Start with baseline tags for the operation (e.g., `claude` + `brainstorming` for brainstorms, `claude` + `ingest` for ingested sources).
2. Add 2–4 topic-specific tags **from the tag vocabulary already visible in the Wiki Index** (the inline `#tags` on related entries). Reuse beats inventing.
3. Reuse existing vault tags where they fit (e.g., `#research`, `#transplant`, `#r`, `#medlit`).
4. **Only call `obsidian:get_tag_info`** (with `verbose: true`) when the index doesn't show a fitting tag and you need to confirm an existing tag's exact spelling/count before reusing — or before creating a new tag. Create a new tag only if nothing in the existing taxonomy covers the topic.

## PARA Routing

When deciding where to place a new note, work through this decision tree:

### 1. Active Project?

First check the **Wiki Index** — its Projects section shows the active projects and what's in them. If a project is the obvious home, route there. Only call `obsidian:project_context` to load overview/sessions/backlog when you actually need that detail (e.g., the note adds to an in-flight workstream); fall back to `obsidian:project_list` only if the index is missing or stale.

Example: A paper about pancreas preservation → `01 Projects/Research/PAVE-2/`

### 2. New Project?

If the note is clearly about an active initiative (defined goal, clear scope) but no project folder exists, **ask the user before creating**. Propose a name and location.

### 3. Area of Responsibility?

Ongoing responsibilities without project scope:
- `02 Area/Work/` — clinical, professional
- `02 Area/Personal/` — personal

### 4. Reference Material?

Exploratory or reference content without a deadline. Route by topic subfolder:
- `03 Resources/Transplant Surgery/` — clinical, surgical
- `03 Resources/R/` or `03 Resources/Data Science/` — stats, coding, data
- `03 Resources/Claude/` — AI tools, Claude, LLMs
- `03 Resources/Obsidian/` — vault and PKM
- Create a new subfolder if nothing fits, but tell the user first.

### 5. Fallback

If routing is genuinely unclear, ask the user. Don't silently dump into `00 Inbox/`.

**Always tell the user your routing decision and why before saving.** Let them redirect if they disagree.

## Bidirectional Cross-Referencing

A note that only links outward is half-connected. The vault becomes a true wiki when related notes also link back. After saving any new note, do the following:

### 1. Identify Related Notes

Build a candidate list, cheapest channel first:
- **Wiki Index scan** — entries sharing your note's `type`/`#tags` or with related descriptions are candidates you can spot without any search call. Start here.
- **Wikilinks in the new note** — every `[[note]]` included is a candidate.
- **Search hits (only if the index is thin on this topic)** — run `obsidian:search_vault` on the 2–3 most distinctive terms, batched in one turn. Any clearly-related note that wasn't linked is a candidate.
- **Tag neighbours** — if you used a specific tag (e.g., `#pancreas-transplant`) and the index doesn't already list its members, check via `obsidian:get_tag_info`.

Filter down to **3–5 most relevant** notes. Don't spam every tangentially related page.

### 2. Read and Update Each Related Note

For each candidate:

1. **Read the note** via `obsidian:read_note` to understand its structure and check whether it already references the new note.
2. **Skip if already linked** — if the note already contains a `[[wikilink]]` to the new note, do nothing.
3. **Determine where to add the back-reference.** Look for an existing section:
   - A `## Related` or `## See Also` or `## Related Notes` section → append there.
   - A `## Session Notes` or `## References` section → append there.
   - If no suitable section exists, append a `## Related Notes` section at the end.
4. **Write a contextual back-reference** using `obsidian:append_to_note` or `obsidian:str_replace_in_note`:
   ```markdown
   - [[New Note Name]] — one-sentence summary of why this is relevant (YYYY-MM-DD)
   ```
   The date and context sentence are essential — a bare `[[link]]` without context is useless months later.

### 3. Rules

- **Never modify frontmatter** of other notes — only append content.
- **Never restructure** existing notes — only add to them.
- **Maximum 5 notes updated** per operation to avoid excessive vault churn.
- **Always tell the user** which notes were updated and what was added, so they can review.
- **If unsure** whether a note is related enough, skip it. False connections are worse than missing ones.

## Wiki Index Management

The vault maintains a **Wiki Index** at `meta/Wiki Index.md`. This catalogues all Claude-generated notes by PARA category, plus a chronological log table. It is the router described at the top of this file, so every entry must carry the fields that make routing/tagging/linking possible without re-searching.

### Entry Format

Each entry uses the **filename** in the wikilink and carries `type` + `tags` inline:

```markdown
- [[note-filename]] · `type` · #tag1 #tag2 — One-sentence description (YYYY-MM-DD)
```

If you read the index and find older entries in the bare `- [[Note]] — description` form, that's fine — they still work; enrich them opportunistically when you touch them, and let vault-lint backfill the rest.

### Updating the Index

After saving a new note:

1. **Read it** via `obsidian:read_note` with `path: meta/Wiki Index.md` (you likely already read it as the router at the start of the operation — reuse that).
2. **Find the correct category section** (Projects, Areas, Resources, Evidence Summaries) based on where the note was routed.
3. **Append a new entry** in the format above using `obsidian:str_replace_in_note`. Use the note's filename, its `type`, and the tags you applied.
4. **Keep entries sorted** within each section by date (newest first).

### Log Entry

Always append a log entry to the `## Log` table at the bottom:
```markdown
| YYYY-MM-DD | operation-type | [[Note Name]] | One-sentence summary |
```
Valid operation types: `brainstorm`, `brainstorm-update`, `ingest`, `lint`, `convention`, `triage`.

### If the Wiki Index Does Not Exist

Create it via `obsidian:create_note` at `meta/Wiki Index.md` with sections for Projects, Areas, Resources, Evidence Summaries, and a Log table. See the brainstorm-to-obsidian skill for the full scaffold template.

## Daily Note Breadcrumb

After every vault operation, log a breadcrumb in today's daily note via `obsidian:daily_append`:
```markdown
- Operation description: [[Note Name]] (#claude #operation-tag)
```
This ties the operation back to daily context without duplicating content.

## Summary Report

After all steps in any vault operation, give the user a concise audit showing:
- Note saved (title and wikilink)
- Location (PARA path)
- Tags applied
- Notes cross-referenced (with what was added)
- Wiki Index status
- Daily note status
- Any pending actions (e.g., "move original to Archive?")

Use emoji prefixes for scannability: ✅ 📂 🏷️ 🔗 📋 📅 📦

## Handling Existing Notes

**Search first.** Before creating any new note, run `obsidian:search_vault` on the topic.

- **Note on same topic exists?** Mention it to the user. Offer to:
  - Append via `obsidian:append_to_note` (for follow-up content)
  - Surgical update via `obsidian:str_replace_in_note` (e.g., adding items to an existing section)
  - Create a new linked note (e.g., "Topic - Session 2") with `[[back to original]]`
  - Replace the old note with a merged version (with user confirmation)

- **Note length check:** If appending to an existing note, check if it's past ~1500 words. If so, suggest splitting into separate notes with a parent index linking them.

## Note Length and Style

- **Detailed prose** for substantive sections (Summary, Key Ideas, Context). Not terse bullets.
- **Obsidian-native syntax:** `[[wikilinks]]`, `> [!type]` callouts, `==highlights==`, `- [ ]` tasks.
- **Code snippets** in fenced code blocks with language identifiers.
- **Target length:** 400–800 words for most notes. If a note grows beyond ~1500 words across sessions, suggest splitting.
- Always use `status: active` on new notes.
