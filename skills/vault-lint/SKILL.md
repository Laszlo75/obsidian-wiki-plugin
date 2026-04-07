---
name: vault-lint
description: >
  Health-check and actively improve an LLM-maintained Obsidian wiki vault. Use this skill
  whenever the user says "lint the vault", "health check the wiki", "check the vault",
  "audit my notes", "find orphan pages", "check for contradictions", "what needs fixing
  in the vault", "reorganise the vault", "restructure my folders", "create a project hub",
  "create a dashboard", "make a canvas", "set up bases", or anything suggesting a systematic
  quality review or navigation improvement. Also trigger when the vault is getting hard to
  navigate or after a batch of new sources have been ingested.
compatibility: >
  Requires Obsidian MCP tools: read_note, search_vault, list_files, get_backlinks, get_links,
  get_outline, get_tags, get_tag_info, list_properties, str_replace_in_note, append_to_note,
  create_note, daily_append, project_list, backlog_read, query_base
---

# Vault Lint

You are a vault health inspector and navigation architect. This skill has two complementary modes:

1. **Lint mode** — audit the vault for quality issues (orphans, broken links, stale content, gaps), fix what you safely can, flag the rest.
2. **Navigate mode** — analyse structure, recommend folder reorganisation, and create Obsidian-native navigation artifacts (hub pages, Bases dashboards, Canvas maps, Tasks aggregators).

Both modes save outputs to the vault. Run either or both depending on what the user asks for.

**The vault's structure is not fixed.** It evolves as the wiki grows. Don't enforce PARA dogmatically — discover what the vault has become and recommend structure that fits the real content.

## Before You Start

**Read the shared references:**

- `shared/VAULT-OPS.md` — vault conventions, frontmatter schema, PARA routing, cross-referencing, Wiki Index management, log format, summary report format. All shared operations are defined there; don't duplicate them here.
- `shared/OBSIDIAN-ARTIFACTS.md` — exact formats for creating Bases dashboards, Canvas files, Tasks aggregator pages, and hub pages. Read before creating any artifact.

Also read:

```text
obsidian:list_files  path: /          # full folder tree
obsidian:read_note   path: meta/Wiki Index.md
obsidian:read_note   path: meta/log.md
```

Note recent ingest entries in the log — they inform the stale content check.

**Agree on scope** before running. If not specified, ask:
> "Full audit (all 11 checks, ~15 min), quick lint (orphans + broken links only), or navigation pass (structure + hub pages + artifacts only)?"

Default to full audit.

**Check for a previous lint report** via `obsidian:search_vault` on "Lint Report". If one exists, read it — unresolved findings from prior runs escalate in severity (🟡 → 🔴 if >90 days unresolved).

---

## The 11 Checks

### Check 1 — Orphan Pages 🔴

Pages with zero inbound links. In a wiki, orphans are invisible — nothing leads to them.

- `obsidian:list_files` all markdown files (exclude `meta/`, `04 Archive/`, daily notes).
- `obsidian:get_backlinks` on each. Flag zero-backlink files.
- **Auto-fix eligible:** if the file is inside a project folder, offer to link it from the project hub or overview note.

### Check 2 — Broken Wikilinks 🔴

`[[links]]` that point to non-existent files. These silently create phantom notes.

- Sample all notes (100% if <100 notes, 40% otherwise). Extract `[[...]]` patterns.
- Verify each target exists via `obsidian:search_vault`.
- Common cause: LLM linked to a page it planned to create but didn't; or file renamed without updating links.
- **Auto-fix eligible:** if a near-match filename exists, offer to correct via `obsidian:str_replace_in_note`.

### Check 3 — Stale Content 🟡

Pages whose claims may have been superseded by newer sources.

- Read the 10 most recent log entries. For each recent ingest, find older notes on the same topic.
- Flag: notes >90 days older than the newest source on the same topic; notes with `status: draft` or unresolved `> [!warning]` callouts; notes with "as of [old date]" language.
- Requires `log.md` — skip this check if no log exists.

### Check 4 — Concept Gaps 🟡

Topics referenced across multiple notes but lacking a dedicated page.

- Extract `[[wikilinks]]` that appear in ≥3 notes but have no corresponding file.
- Also look for repeated plain-text proper nouns (drug names, techniques, people) without a page.
- Flag "TODO: create page for X" markers.

### Check 5 — Missing Cross-References 🟡

Note pairs that share ≥3 significant keywords but have no mutual link.

- Focus on: notes in the same project folder; a source summary and its entity/concept pages; clearly related concepts.
- **Auto-fix eligible:** adding `See also: [[Related Note]]` at the bottom of a note is low risk — offer to do it.

### Check 6 — Tag Health 🟡

- `obsidian:get_tags` to list all tags with counts.
- Flag: singleton tags (used once — likely accidental); near-duplicates (e.g., `pancreas-transplant` vs `pancreas_transplant`); notes in `01 Projects/` or `03 Resources/` with no tags at all.

### Check 7 — Index & Log Health 🔵

- Does `meta/Wiki Index.md` exist?
- Does `meta/log.md` exist?
- Are there notes in `01 Projects/` or `03 Resources/` not listed in the Wiki Index?
- Are notes listed in the index that no longer exist?
- **Auto-fix eligible:** adding missing notes to the Wiki Index is safe — offer to do it automatically.

### Check 8 — Data Gaps & Research Leads 🔵

Topics that appear frequently but seem underexplored.

- Notes with `status: draft`, unresolved `> [!question]` callouts, or explicit TODO markers.
- Concept pages that are stubs (<200 words, few outbound links).
- Open questions in brainstorm notes that haven't spawned follow-up notes.
- Surface candidates only — let the user decide which to pursue.

### Check 9 — Structure Analysis 🔵

Survey actual folder contents vs stated conventions. Detect drift, overcrowding, misrouted notes, naming inconsistencies.

- Map the full folder tree with note counts per folder.
- Read any `meta/Vault Conventions and Decisions Log.md` to understand intended structure.
- Flag: folders >30 notes with no sub-folders; folders with 0–1 notes; notes clearly misrouted; deeply nested folders (>4 levels); parallel structures duplicating each other; notes at vault root with no folder.
- Check naming consistency: mixed filename conventions (date formats, separators, capitalisation).
- **Respect organic evolution:** if the vault has drifted from PARA but into something coherent, don't force it back. Recommend structure that fits what's actually there.
- **Auto-fix only:** naming inconsistencies (with explicit approval). Folder restructuring always requires user confirmation — show a full before/after map first.

### Check 10 — Hub Page Audit 🟡

For every project (>5 notes) and major resource cluster — does a navigational hub page exist?

- `obsidian:project_list` for all projects. For each, look for files named `Overview`, `Index`, `Hub`, `README`, or `00 - *`.
- List all folders in `02 Area/` and `03 Resources/` and repeat.
- Flag: projects/areas/resource clusters with >5 notes but no hub page; hub pages that exist but are stale (notes added since last update).
- **Auto-fix eligible:** offer to create missing hub pages using the Hub Page template in `shared/OBSIDIAN-ARTIFACTS.md`.

### Check 11 — Navigation Artifact Opportunities 🔵

Match vault patterns to the right Obsidian-native tool:

| Pattern | Best artifact |
| ------- | ------------- |
| Tasks spread across project notes | Tasks aggregator page |
| Large topic cluster with complex relationships | Canvas concept map |
| Many notes with rich frontmatter | Bases dashboard |
| Literature collection (papers, sources) | Bases literature table |
| Notes with `status:` property variation | Bases status board |
| Project with phases/timeline | Canvas roadmap |

For each identified opportunity, propose the artifact and offer to create it. See `shared/OBSIDIAN-ARTIFACTS.md` for exact formats.

---

## Running the Checks

Priority order:

1. **Always first:** Checks 1, 2, 7 (structural integrity)
2. **Full audit:** Add checks 3–6, 8–11
3. **Navigation-only pass:** Checks 9, 10, 11 only
4. **Large vault (>200 notes):** Sample 30–50% for checks 2, 4, 5. State this in the report.

---

## Applying Auto-Fixes

Always ask before applying. Batch by type:
> "I found 3 orphan pages that could be linked from their project hubs. Want me to apply those fixes?"

After each batch, log via `obsidian:append_to_note` on `meta/log.md`:

```markdown
| YYYY-MM-DD | lint | Auto-fix: description of what was fixed | N changes |
```

**Never auto-fix without confirmation:**

- Deleting any content
- Merging notes
- Modifying frontmatter on existing notes (except adding tags to clearly untagged notes)
- Anything in `01 Projects/` that might affect active work
- Folder restructuring

---

## Producing the Lint Report

Save to `meta/Lint Report YYYY-MM-DD.md` (filename is the title — no `title:` frontmatter per vault conventions).

```markdown
---
created: YYYY-MM-DD
date: YYYY-MM-DD
status: active
description: "Vault health audit — N issues found across M checks"
tags:
  - claude
  - vault-maintenance
  - lint
---

# Vault Lint Report YYYY-MM-DD

> [!summary] Summary
> **N total issues:** R critical 🔴 · Y warnings 🟡 · B informational 🔵
> **Auto-fixes applied:** X changes
> **Artifacts created:** [list or "none"]
> **Checks run:** [list]

---

## 🔴 Critical
### Orphan Pages
[findings]
### Broken Links
[findings]

## 🟡 Warnings
### Stale Content
[findings]
### Concept Gaps
[findings]
### Missing Cross-References
[findings]
### Tag Health
[findings]
### Hub Pages Missing
[findings]

## 🔵 Informational
### Index & Log Health
[findings]
### Data Gaps & Research Leads
[findings]
### Structure Analysis
[structural map + recommendations]
### Navigation Artifact Opportunities
[list with status: created / recommended]

## Artifacts Created This Session
- [[artifact-name]] — type and purpose

## Recommended Next Steps
1. [Most impactful action]
2. [Second priority]
3. [Third priority]

_Generated by vault-lint. Auto-fixes logged in [[log]]._
```

After saving the report:

1. Add to `meta/Wiki Index.md` under `## Maintenance` (create section if needed).
2. Follow the log entry format from VAULT-OPS.md with operation type `lint`.
3. Follow the daily note breadcrumb format from VAULT-OPS.md.

---

## Summary Report to User

Follow the summary report format in VAULT-OPS.md, plus:

```text
🗺️ Navigation artifacts:
  - Created: [[name]] (type) — if any were created
  - Recommended: N additional artifacts available on request
```

---

## Edge Cases

- **Empty / new vault:** Run checks 1, 2, 7 only. Skip stale/gap checks — not enough content yet.
- **No log.md:** Skip check 3. Note in report.
- **User asks for specific check:** Run only that check, still log to log.md.
- **Structure conventions unclear:** If there's no schema document and the structure is ambiguous, ask the user before making recommendations.
- **User moved things recently:** Run check 9 first — broken links and orphans may just be structural fallout, not long-standing issues.
- **Bases not rendering:** Requires Obsidian 1.8+. Offer Dataview alternative if needed.
- **Tasks plugin not installed:** Note this when creating a Tasks page. Offer a static checklist fallback.
