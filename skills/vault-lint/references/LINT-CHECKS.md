# Lint Checks Reference

Detailed specification for each of the 11 vault-lint checks. Read the relevant section before running a check.

---

## Check 1 — Orphan Pages

**What:** Pages with zero inbound links. Invisible to anyone navigating by links.

**How:**
1. `obsidian:list_files` to enumerate all markdown files.
2. `obsidian:get_backlinks` for each. Record zero-backlink files.
3. Skip: `meta/`, `raw/`, `04 Archive/`, daily notes (`YYYY-MM-DD.md`), Wiki Index, log.

**Triage:**
- `01 Projects/` orphan → likely needs linking from project overview or Wiki Index.
- `03 Resources/` orphan, created <30 days ago → acceptable, flag for later.
- `03 Resources/` orphan, >30 days → flag.

**Auto-fix:** If file has a clear parent folder, offer to link it from the folder's hub/overview note.

```
🔴 ORPHAN PAGES (N)
- [[Note]] — 01 Projects/X/, no inbound links, created YYYY-MM-DD
  → Suggested: link from [[X Overview]]
```

---

## Check 2 — Broken Wikilinks

**What:** `[[links]]` pointing to non-existent files — silently create phantom notes in Obsidian.

**How:**
1. Read notes (all if <100; random 30% if larger). Extract all `[[...]]` patterns.
2. Verify each target via `obsidian:search_vault`. Flag zero-result targets.

**Common causes:** Renamed files with stale links; LLM linked a page it intended to create; `title` frontmatter used instead of filename.

**Auto-fix:** If a near-match filename exists, offer to correct via `obsidian:str_replace_in_note`.

```
🔴 BROKEN LINKS (N)
- [[Missing Page]] — linked from [[Source Note]], target does not exist
  → Suggested: create stub or correct to [[Actual Filename]]
```

---

## Check 3 — Stale Content

**What:** Pages whose claims may be superseded by more recently ingested sources.

**How:**
1. Read `meta/log.md` — get the 10 most recent ingest entries.
2. For each recent ingest, read its summary page.
3. Search vault for older notes on the same topic.
4. Flag notes with `created` date >90 days older than the newest source on the same topic.

**Staleness signals:** Hedging language ("as of [old date]", "preliminary"); `status: draft` or `status: stale`; explicit "TODO: update" markers.

```
🟡 STALE (N)
- [[Old Note]] — created 2025-01-10, but [[New Source]] may contradict its findings on X
  → Recommended: re-read both, update if needed
```

---

## Check 4 — Concept Gaps

**What:** Topics referenced across multiple notes but lacking their own page — missing encyclopaedia entries.

**How:**
1. For a sample of notes, extract all `[[wikilinks]]`.
2. Cross-reference against existing files.
3. Flag links appearing ≥3 times with no corresponding file.
4. Also flag: repeated plain-text mentions of a proper noun across notes; "see also / TODO: create page for X" fragments.

```
🟡 CONCEPT GAPS (N)
- "Delayed Graft Function" — mentioned in 5 notes, no dedicated page
  → Suggested: create stub with definition and cross-references
- [[PAVE-2]] — linked from 4 notes, file does not exist
  → Suggested: create project overview
```

---

## Check 5 — Missing Cross-References

**What:** Note pairs that discuss related content but don't link to each other.

**How:**
1. Identify thematically similar note pairs using shared tags and keywords.
2. For candidates, check mutual links via `obsidian:get_links`.
3. Flag pairs sharing ≥3 significant keywords with no mutual link.

**Focus on:** Notes in the same project folder; a source summary and entity/concept page on the same topic; related concept pages.

**Auto-fix:** Adding `See also: [[Related Note]]` at the bottom — low risk, offer to apply.

```
🟡 MISSING CROSS-REFS (N)
- [[Warm Ischaemia]] ↔ [[Preservation Injury]] — 6 shared keywords, no link
  → Auto-fix: add "See also" to both
```

---

## Check 6 — Tag Health

**What:** Orphan tags (used once), near-duplicates, untagged notes.

**How:**
1. `obsidian:get_tags` — all tags with counts.
2. Flag tags used once — likely accidents.
3. Flag near-duplicates (different separators, pluralisation, abbreviation).
4. List notes in `01 Projects/` and `03 Resources/` with no tags.

```
🟡 TAG HEALTH
Singletons (likely accidents):
  - #pave2-study (1) → did you mean #pave-2?

Near-duplicates:
  - #pancreas-transplant (12) and #pancreas_transplant (2) → merge?

Untagged notes (N):
  - [[Note]] — in 01 Projects/, no tags
```

---

## Check 7 — Index & Log Integrity

**What:** Validates the vault's navigational infrastructure.

The Wiki Index is the router every skill reads first (see VAULT-OPS.md), so its quality is load-bearing — this check keeps it trustworthy, not just present.

**Checks:**
- `meta/Wiki Index.md` exists?
- `meta/log.md` exists?
- Notes in `01 Projects/` or `03 Resources/` not listed in the Wiki Index?
- Notes listed in the Wiki Index that no longer exist?
- Log last entry within 30 days of the last ingest?
- **Bare entries:** index lines still in the old `- [[Note]] — description` form, missing the `type`/`#tags` that make the index usable as a router.
- **Fast-capture drafts:** notes with `status: draft` (often carrying a `> [!todo] Pending integration` marker) left by brainstorm fast-capture, still unlinked.

**Enrich bare entries:** read the note's frontmatter and rewrite its index line as `- [[filename]] · \`type\` · #tags — description (date)`.

**Draft sweep:** for each fast-capture draft, run the deferred integration the fast path skipped — bidirectional cross-referencing per VAULT-OPS.md — then flip `status: draft` → `active`. Without this, fast-captures pile up unlinked; this is the back half of that workflow.

**Auto-fix:** adding missing notes, removing dead entries, enriching bare entries, and integrating drafts are all safe. Backfilling `type`/`tags` onto a note's own frontmatter is the allowed "adding tags to clearly untagged notes" exception.

```
🔵 INDEX & LOG HEALTH
Wiki Index: ✅  |  Log: ✅ last entry 2026-03-28

Missing from Wiki Index (N):
  - [[New Note]] — in 03 Resources/, not indexed → auto-fix available

Dead Wiki Index entries (N):
  - [[Old Note]] — listed but file not found → remove

Bare entries to enrich (N):
  - [[Note]] — missing type/tags → auto-fix available

Fast-capture drafts to integrate (N):
  - [[Brainstorm - Topic]] — status: draft, pending integration → cross-ref + activate
```

---

## Check 8 — Data Gaps & Research Leads

**What:** Underexplored topics — frequent mentions but thin coverage, or flagged open questions.

**How:**
1. Find notes with `status: draft`, unresolved `> [!question]` callouts, or "TODO" markers.
2. Find concept pages <200 words with few outbound links.
3. Find unanswered questions in "Open Questions" sections of brainstorm notes.

Surface candidates; let the user decide which to pursue.

```
🔵 DATA GAPS (N)
- [[DGF Risk Factors]] — stub, 85 words, no sources
  → Suggested: literature search or web search
- [[Brainstorm - PAVE-2 Endpoints]] open question: "What did EMPACTA trial show?"
  → Not answered anywhere in vault
```

---

## Check 9 — Structure Analysis

**What:** The vault's folder structure should serve navigation, not the other way around. Detect drift from conventions; recommend structure that fits the actual content — not an imposed ideal.

**How:**
1. `obsidian:list_files` recursively → map the full folder tree with note counts per folder.
2. Read any `meta/Vault Conventions and Decisions Log.md` or `meta/schema.md` for intended structure.
3. Compare intended vs actual.

**Drift signals:**
- Folders with >30 notes and no sub-folders — overcrowded.
- Folders with 0–1 notes — stubs or merge candidates.
- Misrouted notes (e.g., clinical paper in `02 Area/`).
- Nesting >4 levels deep.
- Parallel structures covering overlapping content.
- Notes at root level with no folder.

**Naming consistency:**
- Mixed naming conventions (spaces vs underscores, capitalisation).
- Inconsistent prefixes (some projects have `00 - Overview`, some don't).

**Respect organic evolution:** If folder names don't match PARA labels but clearly reflect the user's mental model, note this as correctly evolved — don't rename. If a folder has grown beyond original scope into a coherent sub-domain, suggest splitting rather than collapsing.

**Auto-fix:** Naming inconsistencies only (with approval). Folder restructuring always requires explicit confirmation.

```
🔵 STRUCTURE ANALYSIS

Current layout:
  00 Inbox/          8 notes   ← growing; schedule processing pass
  01 Projects/      47 notes
    ├─ Research/    31 notes   ← ⚠️ overcrowded; consider sub-folders by study
    ├─ Clinical/     9 notes
    └─ Admin/        7 notes
  03 Resources/     68 notes   ← ⚠️ flat; 68 notes with no sub-folders

Recommendations:
  1. 03 Resources/ → split by topic (Transplant Surgery ~25, Data Science ~18, Claude & AI ~15)
  2. 01 Projects/Research/ → sub-folders per study
  3. 00 Inbox/ has 8 notes, some >14 days old → process soon

Naming inconsistencies:
  - 3 notes use DD-MM-YYYY dates; rest use YYYY-MM-DD → standardise
  - 5 notes use underscores; rest use spaces → standardise to spaces

Correctly evolved (keep): meta/ folder, "Brainstorm - " prefix ✅
```

---

## Check 10 — Hub Page Audit & Per-Folder Index

**What:** Human-readable entry points into projects, areas, and major resource clusters. The global Wiki Index is LLM-optimised; hub pages are human-optimised — and they double as the folder's **per-folder index** (OKF progressive disclosure). Each hub page has a curated zone (human-edited) plus a generated `## Index` block that this check owns.

**Hub page types:**

| Type | Where | Purpose |
|------|--------|---------|
| Project Hub | `01 Projects/X/00 - X Overview.md` | Status, key notes, open tasks, recent activity |
| Area Overview | `02 Area/X/Overview.md` | Responsibilities, related notes, key resources |
| Resource Index | `03 Resources/X/Index.md` | Curated entry into a topic cluster |

**How:**
1. `obsidian:project_list` — list all projects.
2. For each: check for files named `Overview`, `Index`, `Hub`, `README`, or `00 - *`.
3. List all folders in `02 Area/` and `03 Resources/`. Repeat.
4. Flag any project/area/cluster with >5 notes but no hub page; flag hub pages whose curated sections are stale.

When offering to create a missing hub page, read `references/OBSIDIAN-ARTIFACTS.md` → Hub Page section.

**Regenerate the `## Index` block:** for each hub page, rebuild the content between the `<!-- BEGIN GENERATED INDEX -->` / `<!-- END GENERATED INDEX -->` markers from the global Wiki Index — one enriched line per note in that folder (`- [[filename]] · \`type\` · #tags — description (date)`). Only touch content between the markers; never disturb the curated zone above. The global Wiki Index stays canonical; these blocks are always derived from it, never the reverse.

**Progressive disclosure:** when a folder passes ~20–30 notes, collapse its entry in the global Wiki Index to a pointer (`FOLDER — N notes → [[hub page]]`) so the router read stays small. Reverse it if the folder shrinks below the threshold.

**Auto-fix:** creating missing hub pages, regenerating `## Index` blocks, and collapsing/expanding global pointers are all safe — offer them.

```
🟡 HUB PAGE AUDIT
Projects missing hub pages (N):
  - PAVE-2 (14 notes) — no overview
    → Create: 01 Projects/Research/PAVE-2/00 - PAVE-2 Overview.md

Resource clusters missing indexes (N):
  - 03 Resources/Transplant Surgery/ (25 notes) — no index

Stale ## Index blocks (N):
  - [[PAVE-2 Overview]] — 8 notes added since last regen → auto-fix available

Folders to collapse to a pointer (N):
  - 03 Resources/Transplant Surgery/ (34 notes) → point Wiki Index at [[Transplant Surgery Index]]
```

---

## Check 11 — Navigation Artifact Opportunities

**What:** Identify where Obsidian-native tools (Bases, Canvas, Tasks) would dramatically improve navigability.

**Pattern matching:**

| Vault pattern | Best artifact |
|--------------|---------------|
| Tasks spread across many project notes | Tasks aggregator page |
| Large topic cluster with complex relationships | Canvas concept map |
| Many notes with rich frontmatter (dates, status, authors) | Bases dashboard |
| Literature collection with author/date/journal | Bases literature table |
| Notes with varied `status:` values | Bases status board |
| Project with phases/dependencies | Canvas roadmap |

**How:**
1. `obsidian:list_properties` — identify which frontmatter properties are actually used.
2. Scan project notes for `- [ ]` task density.
3. Identify topic clusters with >15 notes and rich interlinking.

Always verify properties exist before designing a Base around them.

When creating artifacts, read `references/OBSIDIAN-ARTIFACTS.md`.

```
🔵 ARTIFACT OPPORTUNITIES
1. 📊 Bases: "Research Projects Dashboard"
   Rationale: 14 project notes have status/date frontmatter
   → Create at: meta/dashboards/Research Projects.md

2. 🗺️ Canvas: "Transplant Surgery Concept Map"
   Rationale: 31 notes with rich cross-references
   → Create at: meta/maps/Transplant Surgery.canvas

3. ✅ Tasks: "Active Project Tasks"
   Rationale: Open tasks found across 8 project notes
   → Create at: meta/Active Tasks.md
```

---

## Check 12 — OKF Conformance

**What:** Verify the vault still reads as a valid [Open Knowledge Format](https://github.com/GoogleCloudPlatform/knowledge-catalog) bundle (see OKF Compatibility in `references/VAULT-OPS.md`). Fast — mostly overlaps with the frontmatter reads in Checks 6 and 7.

**Checks:**
- **`type` present:** every Claude-created concept note has parseable YAML frontmatter with a non-empty `type` (the one OKF-required field).
- **Reserved files well-formed:** `meta/Wiki Index.md` carries `okf_version: "0.1"`; `meta/log.md` is chronological.
- **`type` vocab sanity:** flag notes whose `type` is outside the known set (`brainstorm`/`summary`/`entity`/`concept`/`hub`/`report`) — not an error (OKF allows open types), just a consistency nudge.

Do **not** flag broken wikilinks here — OKF consumers must tolerate them; that's Check 2's job under our stricter maintenance stance.

**Auto-fix:** backfilling `type` from the note's role (the untagged-frontmatter exception) and adding the `okf_version` marker are safe — offer them.

```
🔵 OKF CONFORMANCE
okf_version: ✅  |  log.md chronological: ✅

Notes missing `type` (N):
  - [[Some Note]] — no type → backfill as `concept`? (auto-fix available)

Off-vocabulary `type` values (N):
  - [[Other Note]] — type: "summary-note" → did you mean `summary`?
```
