---
name: brainstorm-to-obsidian
description: >
  Capture brainstorming sessions from Claude conversations and save them as structured notes in Obsidian.
  Trigger this whenever you hear: "save this brainstorm", "capture this session", "summarise this to Obsidian",
  "write this up in Obsidian", "we're done brainstorming", or "create a note from this conversation". The skill
  automatically routes notes to the correct PARA folder, checks vault conventions, extracts action items for
  project backlogs, cross-references related notes, and maintains the vault-wide Wiki Index. Built for surgeons
  and researchers who need quick, reliable idea capture without friction.
compatibility: >
  Requires Obsidian MCP tools: create_note, search_vault, list_files, project_list, project_context,
  daily_append, list_properties, get_tag_info, get_links, append_to_note, str_replace_in_note,
  list_templates, read_note, get_backlinks
---

# Brainstorm-to-Obsidian

You are capturing output from a brainstorming session in this Claude conversation and producing a structured Obsidian note that preserves reasoning and context. The goal is to save ideas with enough detail that the user can act on them weeks later without re-reading the original conversation.

## Before You Start

**Read the shared vault operations reference** at `shared/VAULT-OPS.md` (relative to the plugin root). It contains vault conventions, PARA routing, cross-referencing, Wiki Index management, and other shared operations you'll need. For callout types, wikilink syntax, and formatting details, consult `shared/OBSIDIAN-MARKDOWN.md`.

Additionally, check for a **Brainstorm template** via `obsidian:list_templates`. The vault has one in `meta/templates/` — use it as the base via the `template` parameter on `create_note`.

## Workflow

### Step 1: Analyse the Conversation

Identify:
- **Topic** — Distil a clear, searchable title (e.g., "Brainstorm - PAVE-2 Endpoint Selection" not "Discussion").
- **Context** — Why did this brainstorm happen? What prompted it?
- **Key ideas** — Capture reasoning, not just conclusions. Why did an idea matter?
- **Decisions made** — Anything the user agreed to or resolved.
- **Open questions** — Unresolved threads for future investigation.
- **Action items** — Concrete next steps with enough context to be actionable later.
- **Related notes** — Which existing vault notes does this brainstorm connect to? (Used in Step 5.)

**Ask for clarification** if the conversation is ambiguous or covers multiple disconnected topics. It's better to ask now than produce an unfocused note.

### Step 2: Determine Tags

Always include baseline tags: `brainstorming`, `claude`.

Then add 2–4 topic-specific tags following the tag selection process in VAULT-OPS.md (search existing tags first, reuse before creating).

### Step 3: Route to the Correct Location

Follow the PARA routing decision tree in VAULT-OPS.md. Tell the user your routing decision and why before saving.

### Step 4: Compose the Note

Use this structure:

```markdown
---
created: YYYY-MM-DD
date: YYYY-MM-DD
tags:
  - brainstorming
  - claude
  - topic-tag-1
  - topic-tag-2
status: active
description: "One-sentence summary of what was brainstormed"
---

# Title

## Context

Why did this brainstorm happen? What problem or opportunity prompted it?
1–3 paragraphs providing enough background that future-you understands the significance.

## Key Ideas

For each major idea, write a short paragraph capturing the idea AND the reasoning.

> [!tip] Key Insight
> The most important realisation from this session.

Use [[wikilinks]] to connect to vault notes — but ONLY after verifying they exist
(see wikilink rules in VAULT-OPS.md).

## Decisions

> [!success] Decisions Made
> - Decision one with brief rationale
> - Decision two with brief rationale

(Omit if nothing was explicitly decided.)

## Open Questions

> [!question] To Investigate
> - Question framed as an actual question
> - Include context about why this matters

## Action Items

- [ ] Action item with enough context to be actionable weeks later
- [ ] Link to [[relevant note]] if one exists

## Session Notes

Raw notes, links, code snippets, or tangential ideas. Omit if nothing to add.
```

**Key formatting principles:**
- Write in **detailed prose** for Key Ideas and Context, not terse bullets.
- Include **code snippets, URLs, or technical details** in fenced code blocks with language identifiers.
- Keep notes to **500–800 words** for optimal Obsidian discoverability.

### Step 5: Save and Integrate

This step uses shared operations from VAULT-OPS.md. Execute them in order:

#### 5a. Save the Note

Use `obsidian:create_note` with:
- `name`: Clean, descriptive title (no date prefix; the `created` property handles dating)
- `path`: Full vault-relative path including folder
- `template`: Brainstorm template name if it exists
- `content`: Full markdown with YAML frontmatter
- `overwrite: false` (unless updating an existing note)

After saving, verify links via `obsidian:get_links` on the new note. Report any broken references.

#### 5b. Cross-Reference Related Notes

Follow the bidirectional cross-referencing process in VAULT-OPS.md. Identify 3–5 related notes and add contextual back-references.

#### 5c. Update the Wiki Index

Follow the Wiki Index management process in VAULT-OPS.md. Add a categorised entry and a log row with operation type `brainstorm`.

#### 5d. Daily Note Breadcrumb

Log via `obsidian:daily_append`:
```
- Brainstorm captured: [[Brainstorm - Topic Name]] (#claude #brainstorming)
```

### Step 6: Handle Action Items & Project Routing

If action items emerged and the brainstorm routed to a project:

1. Offer to add action items to the project backlog via `obsidian:backlog_add`:
   ```
   obsidian:backlog_add
     project: "ProjectName"
     item: "Action item description"
     priority: "high" or "medium" or "low"
   ```

2. Mention that a **Tasks page** (e.g., `01 Projects/Tasks.md`) can aggregate `- [ ]` items from across projects and areas via an Obsidian Base.

### Step 7: Check for Existing Notes

Follow the "Handling Existing Notes" process in VAULT-OPS.md. Search before creating. Offer to append, link, or merge if a note on the same topic exists.

### Step 8: Summary Report

Follow the summary report format in VAULT-OPS.md.

## Edge Cases

- **Very short conversation** — Skip sections that don't apply. Still capture reasoning.
- **Multiple topics** — Ask: one combined note or separate notes per topic? If separate, run Steps 5a–5c for each.
- **User provides a title** — Use it. Otherwise, generate one that's descriptive and searchable.
- **Technical brainstorms** — Include code blocks, Mermaid diagrams, architecture sketches in Session Notes.
- **Follow-up sessions** — Search for existing brainstorm notes on same topic. Offer to append or create a linked follow-up.
- **Multiple brainstorms in one session** — Update the Wiki Index for each. Cross-reference between them if related.
