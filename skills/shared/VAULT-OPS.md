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
1. Search with `obsidian:search_vault` to confirm the note exists.
2. If found, use `obsidian:read_note` on the candidate to check the actual **file path**.
3. The wikilink uses the filename (without `.md`), not any title or heading.

**Example:** If a note's file path is `03 Resources/Claude/claude-code-obsidian-ai-knowledge-base.md`, the correct link is `[[claude-code-obsidian-ai-knowledge-base]]` — never `[[Using Claude Code and Obsidian for AI-Assisted Knowledge Management]]`.

A broken link is worse than no link. When in doubt, omit it.

## Tag Selection

The vault has 185+ tags. Reusing existing tags matters more than inventing the perfect taxonomy.

1. Start with baseline tags for the operation (e.g., `claude` + `brainstorming` for brainstorms, `claude` + `ingest` for ingested sources).
2. Add 2–4 topic-specific tags by running `obsidian:get_tag_info` (with `verbose: true`) on candidate tags to see which files use them.
3. Reuse existing vault tags where they fit (e.g., `#research`, `#transplant`, `#r`, `#medlit`).
4. Create a new tag only if nothing in the existing taxonomy covers the topic.

## PARA Routing

When deciding where to place a new note, work through this decision tree:

### 1. Active Project?

Use `obsidian:project_list` to list all projects under `01 Projects/`. If the note supports an active project, run `obsidian:project_context` to load overview, sessions, and backlog. Route there if it's a clear fit.

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

Build a candidate list from three channels:
- **Wikilinks in the new note** — every `[[note]]` included is a candidate.
- **Search hits** — run `obsidian:search_vault` on the 2–3 most distinctive terms from the note's topic. Any existing note that's clearly related but wasn't linked is a candidate.
- **Tag neighbours** — if you used a specific tag (e.g., `#pancreas-transplant`), check via `obsidian:get_tag_info` what other notes share it.

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

The vault maintains a **Wiki Index** at `meta/Wiki Index.md`. This catalogues all Claude-generated notes by PARA category with one-line summaries, plus a chronological log table.

### Updating the Index

After saving a new note:

1. **Read it** via `obsidian:read_note` with `path: meta/Wiki Index.md`.
2. **Find the correct category section** (Projects, Areas, Resources, Evidence Summaries) based on where the note was routed.
3. **Append a new entry** under that section using `obsidian:str_replace_in_note`:
   ```markdown
   - [[Note Name]] — One-sentence description (YYYY-MM-DD)
   ```
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
