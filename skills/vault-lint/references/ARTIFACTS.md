# Navigation Artifacts Reference

Templates and syntax for Obsidian-native navigation artifacts. Read the relevant section before creating an artifact. Always check `obsidian:list_properties` first to see which frontmatter properties the vault actually uses.

---

## Hub Page (Structured Note)

Human-readable entry point into a project or area. Use where a Bases dashboard would be overkill or where the user needs a curated narrative overview.

```markdown
---
created: YYYY-MM-DD
date: YYYY-MM-DD
status: active
description: "Central navigation page for PROJECT NAME"
tags: [claude, hub, project-tag]
---

# PROJECT NAME

> [!info] Project Summary
> What this project is, why it matters, current status. 1–3 sentences.

## Status

| Item | Detail |
|------|--------|
| Status | 🟢 Active / 🟡 On hold / 🔴 Blocked |
| Started | YYYY-MM-DD |
| Key question | What is this trying to answer? |

## Key Notes

_Curated, not exhaustive — the 5–8 most important pages in this cluster._

- [[Note 1]] — one-line description
- [[Source Summary - X]] — key findings

## Recent Activity

_3–5 most recent notes, newest first._

- [[Recent Note]] — added YYYY-MM-DD

## Open Tasks

- [ ] Task with enough context to be actionable later
- [ ] Link to [[relevant note]] if one exists

## Related

- [[Related Project]] — brief connection note
- [[Related Area]] — brief connection note
```

**Save at:** `01 Projects/X/00 - X Overview.md` for projects; `02 Area/X/Overview.md` for areas; `03 Resources/X/Index.md` for resource clusters.

---

## Bases Dashboard

Obsidian Bases creates live filtered tables over vault notes using frontmatter properties. Requires Obsidian 1.8+.

Create a note and embed a `base` code block. The filter/property keys must match actual frontmatter keys in the vault (verify with `obsidian:list_properties`).

**Save at:** `meta/dashboards/DASHBOARD NAME.md`

### Research Projects Dashboard

```markdown
---
created: YYYY-MM-DD
tags: [claude, meta, dashboard]
description: "Live view of all research project notes by status and date"
---

# Research Projects Dashboard

` ```base
filters:
  - property: tags
    operator: contains
    value: research
  - property: status
    operator: is not
    value: archived
properties:
  - property: title
    label: Note
  - property: status
    label: Status
  - property: date
    label: Date
  - property: description
    label: Summary
sort:
  - property: date
    direction: desc
` ```
```

### Literature Table

For notes tagged `#medlit` with author/date/source frontmatter:

```yaml
filters:
  - property: tags
    operator: contains
    value: medlit
properties:
  - property: title
  - property: author
  - property: date
  - property: source
  - property: status
sort:
  - property: date
    direction: desc
```

### Brainstorm Tracker

```yaml
filters:
  - property: tags
    operator: contains
    value: brainstorming
properties:
  - property: title
  - property: date
  - property: description
  - property: status
sort:
  - property: date
    direction: desc
```

### Active Notes Board

```yaml
filters:
  - property: status
    operator: is
    value: active
properties:
  - property: title
  - property: status
  - property: created
  - property: description
```

**Fallback:** If Bases is unavailable, offer a Dataview alternative (requires Dataview community plugin):

```dataview
TABLE description, status, date
FROM #research
WHERE status != "archived"
SORT date DESC
```

---

## Canvas

Canvas files are JSON with `.canvas` extension. Save via `obsidian:create_note` with path ending in `.canvas`.

**Save at:** `meta/maps/NAME.canvas`

### Concept Map Template

Radial layout: central concept at origin, related notes radiating outward, groups clustering sub-topics.

```json
{
  "nodes": [
    {
      "id": "centre",
      "type": "text",
      "text": "# TOPIC\nCentral concept",
      "x": 0, "y": 0, "width": 220, "height": 80,
      "color": "4"
    },
    {
      "id": "n1",
      "type": "file",
      "file": "03 Resources/Topic/Note One.md",
      "x": -420, "y": -180, "width": 280, "height": 120
    },
    {
      "id": "n2",
      "type": "file",
      "file": "03 Resources/Topic/Note Two.md",
      "x": 220, "y": -180, "width": 280, "height": 120
    },
    {
      "id": "g1",
      "type": "group",
      "label": "Sub-topic Cluster",
      "x": -480, "y": -260, "width": 820, "height": 480,
      "color": "5"
    }
  ],
  "edges": [
    {
      "id": "e1",
      "fromNode": "centre", "fromSide": "left",
      "toNode": "n1", "toSide": "right",
      "label": "causes"
    },
    {
      "id": "e2",
      "fromNode": "centre", "fromSide": "right",
      "toNode": "n2", "toSide": "left",
      "label": "related to"
    }
  ]
}
```

### Project Roadmap Template

Left-to-right layout by phase. Replace `type: file` with `type: text` for milestone cards without notes yet.

```json
{
  "nodes": [
    {
      "id": "phase1",
      "type": "group",
      "label": "Phase 1 — Setup",
      "x": -600, "y": -200, "width": 340, "height": 400,
      "color": "3"
    },
    {
      "id": "phase2",
      "type": "group",
      "label": "Phase 2 — Execution",
      "x": -160, "y": -200, "width": 340, "height": 400,
      "color": "4"
    },
    {
      "id": "m1",
      "type": "file",
      "file": "01 Projects/X/Milestone One.md",
      "x": -580, "y": -160, "width": 300, "height": 100
    },
    {
      "id": "m2",
      "type": "text",
      "text": "**Milestone Two**\nNot yet created",
      "x": -140, "y": -160, "width": 300, "height": 100
    }
  ],
  "edges": [
    {
      "id": "e1",
      "fromNode": "m1", "fromSide": "right",
      "toNode": "m2", "toSide": "left"
    }
  ]
}
```

**Colour codes:** `1`=red · `2`=orange · `3`=yellow · `4`=green · `5`=cyan · `6`=purple. Use consistently: green for active phases, yellow for planned, red for blocked.

**Layout principles:**
- Concept maps: radial, centre at `x:0, y:0`.
- Roadmaps: left-to-right by phase.
- Literature maps: top-to-bottom by date, concepts in columns.
- Keep text cards short — they're labels. Link to vault notes for detail.

**Note:** Canvas works on Obsidian mobile but is hard to edit there. Recommend desktop for first use.

---

## Tasks Aggregator

Requires the Tasks community plugin. Create a note with embedded Tasks query blocks.

**Save at:** `meta/Active Tasks.md`

```markdown
---
created: YYYY-MM-DD
tags: [claude, meta, tasks]
description: "Live aggregator of open tasks across active projects"
---

# Active Tasks

> [!info]
> Pulled live via the Tasks plugin. Check off here or in the source note — both work.

## By Project

` ```tasks
not done
path includes 01 Projects
group by filename
sort by created
` ```

## Research

` ```tasks
not done
path includes 01 Projects/Research
group by filename
` ```

## Inbox

` ```tasks
not done
path includes 00 Inbox
` ```

## Recently Completed

` ```tasks
done
done after {{date-7d}}
sort by done
limit 20
` ```
```

**Key query options:**
- `not done` / `done` — completion filter
- `path includes FOLDER` — folder scope
- `tags include #tag` — tag filter
- `group by filename` / `group by path` / `group by tags`
- `sort by created` / `sort by due` / `sort by priority`
- `due before {{date+7d}}` — relative date
- `limit N` — cap results
- `short mode` — compact display

**Fallback:** If the Tasks plugin isn't installed, offer a static checklist compiled by searching all notes for `- [ ]` items via `obsidian:search_vault`.
