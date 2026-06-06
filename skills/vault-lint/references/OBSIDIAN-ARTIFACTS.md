# Obsidian Artifacts Reference

Formats for creating Obsidian-native navigation artifacts: hub pages, Bases dashboards, Canvas files, and Tasks aggregator pages. Used by the vault-lint skill; may be consulted by other skills when creating navigation infrastructure.

**Always check `obsidian:list_properties` before creating a Bases dashboard** — Bases only works over properties that actually exist in your notes' frontmatter. Build filters around what's actually there.

**Vault frontmatter convention:** No `title:` property — the filename IS the title. Core properties are: `created`, `date`, `status`, `description`, `tags`, `author`, `source`, `aliases`. See VAULT-OPS.md for the full schema.

---

## Hub Page (Structured Note)

A human-readable entry point into a project or topic cluster. The Wiki Index is optimised for LLM navigation; hub pages are optimised for humans — they're richer, more contextual, and scannably structured.

**Save at:** `01 Projects/X/00 - X Overview.md` (projects), `02 Area/X/Overview.md` (areas), `03 Resources/X/Index.md` (resource clusters)

```markdown
---
created: YYYY-MM-DD
date: YYYY-MM-DD
status: active
description: "Central navigation page for PROJECT NAME"
tags:
  - claude
  - hub
  - project-or-topic-tag
---

# PROJECT NAME

> [!info] About This Project
> One paragraph: what this project is, why it matters, current status.

## Status

| Item | Detail |
|------|--------|
| Status | 🟢 Active / 🟡 On hold / 🔴 Blocked |
| Started | YYYY-MM-DD |
| Key question | What is this project trying to answer? |

## Key Notes

_Curated entry points — not every note, just the most important ones._

- [[Note Name]] — one-line description of what this note covers
- [[Source Summary Name]] — key findings from this source

## Recent Activity

_3–5 most recently added notes, newest first._

- [[Recent Note]] — added YYYY-MM-DD

## Open Questions & Tasks

- [ ] Task with enough context to be actionable weeks later
- [ ] [[relevant note]] if a note provides context

## Related

- [[Related Project or Area]] — brief note on the connection
```

---

## Bases Dashboard

Obsidian Bases creates live filtered tables over vault notes using frontmatter properties. Requires Obsidian 1.8+. Embedded in a markdown note using a `base` fenced code block.

**Save at:** `meta/dashboards/DASHBOARD NAME.md`

```markdown
---
created: YYYY-MM-DD
date: YYYY-MM-DD
status: active
description: "Live dashboard description"
tags:
  - claude
  - dashboard
---

# Dashboard Name

Brief description of what this dashboard shows and who it's for.

```base
filters:
  - property: tags
    operator: contains
    value: research
  - property: status
    operator: is not
    value: archived
properties:
  - property: file.name
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
```
```

**Common Base patterns:**

*Research projects table* — filter by tag, show status + date:
```yaml
filters:
  - property: tags
    operator: contains
    value: research
properties:
  - property: file.name
  - property: status
  - property: date
  - property: description
sort:
  - property: date
    direction: desc
```

*Literature table* — for notes tagged `#medlit`:
```yaml
filters:
  - property: tags
    operator: contains
    value: medlit
properties:
  - property: file.name
  - property: author
  - property: date
  - property: source
  - property: description
sort:
  - property: date
    direction: desc
```

*Brainstorm tracker* — all brainstorm notes:
```yaml
filters:
  - property: tags
    operator: contains
    value: brainstorming
properties:
  - property: file.name
  - property: date
  - property: description
  - property: status
sort:
  - property: date
    direction: desc
```

*Status board* — all active notes in a topic:
```yaml
filters:
  - property: status
    operator: is
    value: active
  - property: tags
    operator: contains
    value: transplant
properties:
  - property: file.name
  - property: status
  - property: created
  - property: description
```

---

## Canvas (Concept Map / Roadmap)

Canvas files are JSON with a `.canvas` extension. Each file has `nodes` (cards) and `edges` (connections). Nodes can be vault notes (`type: file`), freestanding text (`type: text`), or groups (`type: group`).

**Save at:** `meta/maps/CANVAS NAME.canvas`

Create via `obsidian:create_note` with path ending in `.canvas` and the JSON below as content.

```json
{
  "nodes": [
    {
      "id": "centre",
      "type": "text",
      "text": "# TOPIC NAME\nCentral concept",
      "x": 0, "y": 0, "width": 200, "height": 80,
      "color": "1"
    },
    {
      "id": "note1",
      "type": "file",
      "file": "03 Resources/Transplant Surgery/DGF Risk Factors.md",
      "x": -420, "y": -200, "width": 280, "height": 120
    },
    {
      "id": "note2",
      "type": "file",
      "file": "03 Resources/Transplant Surgery/Preservation Injury.md",
      "x": 250, "y": -200, "width": 280, "height": 120
    },
    {
      "id": "group1",
      "type": "group",
      "label": "Ischaemia-Reperfusion",
      "x": -480, "y": -280, "width": 850, "height": 480,
      "color": "5"
    }
  ],
  "edges": [
    {
      "id": "e1",
      "fromNode": "centre", "fromSide": "left",
      "toNode": "note1",   "toSide": "right",
      "label": "causes"
    },
    {
      "id": "e2",
      "fromNode": "centre", "fromSide": "right",
      "toNode": "note2",   "toSide": "left",
      "label": "related to"
    }
  ]
}
```

**Colour codes** (Obsidian built-in): `1`=red · `2`=orange · `3`=yellow · `4`=green · `5`=cyan · `6`=purple. Use colours to group by theme or status.

**Layout principles:**
- Concept map: central concept at 0,0, radiate outward by theme. Use groups to cluster sub-topics.
- Project roadmap: left-to-right layout (earlier phases left, later right).
- Literature map: columns by theme, rows by date (oldest top).
- Keep text card content short — they are labels. All detail lives in the linked vault files.
- Typical node spacing: 350–450px horizontally, 200–300px vertically.

---

## Tasks Aggregator Page

Uses the Obsidian Tasks community plugin to dynamically pull open tasks from across the vault. Requires the Tasks plugin to be installed and enabled.

**Save at:** `meta/Active Tasks.md` (general) or `meta/dashboards/PROJECT Tasks.md` (project-specific)

````markdown
---
created: YYYY-MM-DD
date: YYYY-MM-DD
status: active
description: "Live aggregator of open tasks across active projects"
tags:
  - claude
  - dashboard
  - tasks
---

# Active Tasks

> [!info]
> Tasks are pulled live from notes across the vault. Check them off here or in the source note.

## 📁 By Project

```tasks
not done
path includes 01 Projects
group by filename
sort by created
```

## 🧪 Research

```tasks
not done
path includes 01 Projects/Research
group by filename
```

## 📥 Inbox

```tasks
not done
path includes 00 Inbox
```

## ✅ Recently Completed (last 7 days)

```tasks
done
done after {{date-7d}}
sort by done
limit 20
```
````

**Useful Tasks query options:**
- `not done` / `done` — completion status
- `path includes FOLDER` — filter by folder
- `tags include #tag` — filter by tag
- `group by filename` / `group by path` / `group by tags` — grouping
- `sort by created` / `sort by due` / `sort by priority` — ordering
- `due before {{date+7d}}` — due date relative filters
- `limit N` — cap result count
- `short mode` — compact one-line display

**If Tasks plugin is not installed:** offer to create a static checklist note instead, assembled from manually searched tasks across the vault.
