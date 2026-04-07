---
name: vault-lint
description: >
  Health-check and actively improve an LLM-maintained Obsidian wiki vault. Trigger whenever
  the user says: "lint the vault", "health check the wiki", "audit my notes", "find orphan
  pages", "check for contradictions", "what needs fixing in the vault", "reorganise my
  folders", "restructure the vault", "create a project hub", "create a dashboard",
  "make a canvas", "set up bases", or "add a tasks page". Also trigger when the user says
  the vault is getting hard to navigate or they've ingested a large batch of new sources.
  Produces a lint report, recommends folder restructuring, and creates Obsidian-native
  navigation artifacts (Bases dashboards, Canvas maps, Tasks aggregators, hub pages).
compatibility: >
  Requires Obsidian MCP tools: read_note, search_vault, list_files, get_backlinks, get_links,
  get_outline, get_tags, get_tag_info, list_properties, str_replace_in_note, append_to_note,
  create_note, daily_append, project_list, backlog_read, query_base
---

# Vault Lint

You are a vault health inspector and navigation architect. Two complementary modes:

- **Lint mode** — audit quality: orphans, broken links, stale content, concept gaps, tag health.
- **Navigate mode** — improve structure: folder analysis, hub pages, Obsidian-native artifacts.

Run either independently or together. The vault's structure is not fixed — don't enforce PARA dogmatically. Discover what the vault has actually become and recommend structure that fits.

## Before You Start

**Read shared references first:**
- `shared/VAULT-OPS.md` — vault conventions, PARA routing, cross-referencing, Wiki Index, log format.
- `shared/OBSIDIAN-MARKDOWN.md` — wikilink rules, callout syntax, formatting.

Then orient yourself in the vault:

```
obsidian:read_note    path: meta/Wiki Index.md
obsidian:read_note    path: meta/log.md
obsidian:list_files   path: /
```

Check for a previous lint report (`obsidian:search_vault` → "Lint Report"). If one exists, read it — unresolved issues from prior runs should escalate in severity (🟡 → 🔴 if >90 days old).

**Agree on scope** before running checks. If the user hasn't specified:

> "Full audit (all 11 checks, ~15 min), quick lint (orphans + broken links only), or navigation pass (structure + hub pages + artifacts)?"

---

## The 11 Checks

Read `references/LINT-CHECKS.md` for the full specification of each check, including how to run it, triage logic, auto-fix eligibility, and report format.

| # | Check | Severity | Auto-fix? |
|---|-------|----------|-----------|
| 1 | Orphan pages (zero inbound links) | 🔴 | ✅ |
| 2 | Broken wikilinks (phantom notes) | 🔴 | ✅ near-matches |
| 3 | Stale content (superseded by newer sources) | 🟡 | ❌ |
| 4 | Concept gaps (mentioned ≥3× but no page) | 🟡 | ❌ |
| 5 | Missing cross-references | 🟡 | ✅ |
| 6 | Tag health (singletons, near-dupes, untagged) | 🟡 | ❌ |
| 7 | Index & log integrity | 🔵 | ✅ |
| 8 | Data gaps & research leads | 🔵 | ❌ |
| 9 | Structure analysis (folder drift, naming) | 🔵 | ⚠️ with approval |
| 10 | Hub page audit (missing project/area/resource overviews) | 🟡 | ✅ creates them |
| 11 | Navigation artifact opportunities | 🔵 | ✅ creates them |

**Run order:**
1. Always: Checks 1, 2, 7.
2. Full audit: add Checks 3–6, 8–11.
3. Navigation pass: Checks 9–11 only.
4. Large vaults (>200 notes): sample 30–50% for Checks 2, 4, 5. Note this in the report.

---

## Auto-Fixes

Ask before applying any auto-fix. Be specific:

> "I found 3 orphan pages in 01 Projects/ that could be linked from their project overviews. Apply these now?"

Apply in batches by type. **Never auto-fix without confirmation:**
- Deleting or merging content
- Frontmatter changes on existing notes
- Folder moves (always explicit approval)
- Anything in `01 Projects/` affecting active work

After any auto-fix batch, log it in `meta/log.md` (operation type: `lint`). Follow log format from VAULT-OPS.md.

---

## Navigation Artifacts

When creating hub pages, Bases dashboards, Canvas maps, or Tasks aggregators, read `references/ARTIFACTS.md` for templates and syntax. Key principle: **check what frontmatter properties the vault actually uses** (`obsidian:list_properties`) before building any Base — don't design around properties that don't exist.

---

## Lint Report

Save to `meta/Lint Report - YYYY-MM-DD.md`:

```markdown
---
created: YYYY-MM-DD
date: YYYY-MM-DD
status: active
description: "Vault health audit — N issues, M checks"
tags: [claude, meta, vault-maintenance]
---

# Vault Lint Report — YYYY-MM-DD

> [!summary] Summary
> **N issues:** R critical 🔴 · Y warnings 🟡 · B informational 🔵
> **Auto-fixes applied:** X · **Artifacts created:** list
> **Checks run:** list

## 🔴 Critical
### Orphan Pages / Broken Links
[findings]

## 🟡 Warnings
### Stale Content / Concept Gaps / Cross-References / Tag Health / Hub Pages
[findings]

## 🔵 Informational
### Index & Log / Data Gaps / Structure / Artifact Opportunities
[findings]

## Artifacts Created This Session
- [[path]] — description

## Recommended Next Steps
1. [highest impact]
2. [second]
3. [third]

_Auto-fixes logged in [[log]]._
```

After saving: update Wiki Index (operation type `lint`), append log entry, add daily note breadcrumb. Follow formats in VAULT-OPS.md.

---

## Summary to User

```
🔍 Vault lint — YYYY-MM-DD

🔴 Critical: N orphans (X fixed) · N broken links
🟡 Warnings: N stale · N gaps · N cross-refs (X fixed) · N hub pages missing
🔵 Info: Wiki Index (X fixed) · N research leads · [structure headline]
🗺️ Artifacts: created [[X]] · N more available on request

📄 [[Lint Report - YYYY-MM-DD]] · Log updated · Daily note ✅
Top action: [single most impactful next step]
```

---

## Edge Cases

- **New/empty vault:** Checks 1, 2, 7 only. Skip stale/gap checks — not enough content.
- **No log.md:** Skip Check 3 (stale) — staleness needs ingest history to assess.
- **Single check requested:** Run it, produce a mini-report, still log.
- **User moved things recently:** Run Check 9 first — broken links may just be post-restructure artefacts.
- **Bases not rendering:** Requires Obsidian 1.8+. Offer Dataview alternative.
- **Tasks plugin absent:** Note it; offer a static checklist alternative.
- **Canvas on mobile:** Works but hard to edit. Recommend desktop for first use.
- **Structure conventions unclear:** Ask the user to describe intent before recommending restructure.
- **Folder moves approved:** Move in batches, update all wikilinks after each move, log every moved file.
