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

**Read the references** (in this skill's own `references/` folder):

- `references/VAULT-OPS.md` — vault conventions, frontmatter schema, PARA routing, cross-referencing, Wiki Index management, log format, summary report format. All shared operations are defined there; don't duplicate them here.
- `references/LINT-CHECKS.md` — the detailed procedure, triage rules, and report snippet for each of the 12 checks. Read the relevant section before running a check.
- `references/OBSIDIAN-ARTIFACTS.md` — exact formats for Bases dashboards, Canvas files, Tasks aggregator pages, and hub pages. Read before creating any artifact.

Also read the vault's current state:

```text
obsidian:list_files  path: /          # full folder tree
obsidian:read_note   path: meta/Wiki Index.md
obsidian:read_note   path: meta/log.md
```

Note recent ingest entries in the log — they inform the stale content check.

**vault-lint is the keeper of the index layer.** The global `meta/Wiki Index.md` is the canonical router every skill reads first (see VAULT-OPS.md). The other skills keep it roughly current on each save; vault-lint is what makes it *trustworthy* — backfilling `type`/`tags` on bare entries (Check 7), sweeping up `status: draft` fast-captures and wiring their backlinks (Check 7), and regenerating per-folder hub-page `## Index` sections from it (Check 10). When you read the Wiki Index here, you read it as both auditor and generator.

**Agree on scope** before running. If not specified, ask:
> "Full audit (all 12 checks, ~15 min), quick lint (orphans + broken links only), or navigation pass (structure + hub pages + artifacts only)?"

Default to full audit.

**Check for a previous lint report** via `obsidian:search_vault` on "Lint Report". If one exists, read it — unresolved findings from prior runs escalate in severity (🟡 → 🔴 if >90 days unresolved).

---

## The 12 Checks

This table is the index. Each check has a severity (🔴 critical · 🟡 warning · 🔵 informational) and a full procedure, triage rules, and report snippet in `references/LINT-CHECKS.md`. **Read the relevant section there before running a check** — don't rely on this table alone.

| # | Check | Severity | What it finds |
|---|-------|----------|---------------|
| 1 | Orphan pages | 🔴 | Notes with zero inbound links — invisible when navigating by links |
| 2 | Broken wikilinks | 🔴 | `[[links]]` to non-existent files — silently create phantom notes |
| 3 | Stale content | 🟡 | Notes whose claims may be superseded by newer sources (needs `log.md`) |
| 4 | Concept gaps | 🟡 | Topics referenced in ≥3 notes with no dedicated page |
| 5 | Missing cross-references | 🟡 | Related note pairs (≥3 shared keywords) with no mutual link |
| 6 | Tag health | 🟡 | Singleton tags, near-duplicates, untagged project/resource notes |
| 7 | Index & log health | 🔵 | Wiki Index / log integrity; enrich bare entries with `type`/`tags`; sweep `status: draft` fast-captures |
| 8 | Data gaps & research leads | 🔵 | Stubs, unresolved questions, underexplored topics |
| 9 | Structure analysis | 🔵 | Folder drift, overcrowding, misrouting, naming inconsistency |
| 10 | Hub page audit & per-folder index | 🟡 | Projects/clusters (>5 notes) lacking a hub page; regenerate its `## Index` block |
| 11 | Navigation artifact opportunities | 🔵 | Where a Bases / Canvas / Tasks artifact would improve navigability |
| 12 | OKF conformance | 🔵 | Every note has a non-empty `type`; reserved files well-formed; `okf_version` present |

**Auto-fix eligible** (always with confirmation): orphan linking (1), near-match link correction (2), "See also" cross-refs (5), adding missing notes to and enriching the Wiki Index (7), creating missing hub pages and regenerating their `## Index` blocks (10), backfilling `type` / `okf_version` (12). Full triage rules and the exact report snippet for each check live in `references/LINT-CHECKS.md`.

---

## Running the Checks

Priority order:

1. **Always first:** Checks 1, 2, 7 (structural integrity)
2. **Full audit:** Add checks 3–6, 8–12
3. **Navigation-only pass:** Checks 9, 10, 11 only
4. **Large vault (>200 notes):** Sample 30–50% for checks 2, 4, 5. State this in the report.
5. **OKF conformance (Check 12):** cheap; fold into any full audit, or run standalone when prepping an export.

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
type: report
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
### OKF Conformance
[notes missing `type`, reserved-file issues, off-vocabulary types — or "conformant"]

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
