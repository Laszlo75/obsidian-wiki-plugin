# Obsidian Wiki Plugin

A Claude plugin for building and maintaining a compounding personal knowledge base in Obsidian, based on [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## What it does

Instead of treating your Obsidian vault as a static collection of notes, this plugin turns Claude into a wiki maintainer. You provide sources (articles, papers, web clippings, brainstorm sessions) and Claude processes them into structured, interlinked wiki pages — updating cross-references, maintaining a Wiki Index, and keeping the vault healthy as it grows.

The key insight: **knowledge compounds when the LLM does the bookkeeping.** Every source you add makes the entire vault richer, not just adds another disconnected note.

## Skills

### brainstorm-to-obsidian

Captures ideas from Claude conversations into structured Obsidian notes. Analyses the conversation, routes the note to the correct PARA folder, writes it with full context and reasoning, cross-references related notes, and updates the Wiki Index.

**Trigger phrases:** "save this brainstorm", "capture this session", "write this up in Obsidian", "we're done brainstorming"

### obsidian-ingest

Processes external source material (web clippings, articles, papers, rough notes) from the Inbox into structured wiki pages. Reads the source, discusses key takeaways, writes a summary page, creates entity/concept pages, cross-references related notes, updates the Wiki Index, and archives the original. A single ingest can touch 10–15 pages.

**Trigger phrases:** "ingest this", "process this note", "what's in my inbox", "add this to the wiki", "file this article"

## Shared references

Both skills draw from shared references in `shared/`:

- **VAULT-OPS.md** — Vault conventions, PARA routing, cross-referencing, Wiki Index management, tag selection, daily breadcrumbs, summary reports
- **OBSIDIAN-MARKDOWN.md** — Obsidian-flavoured markdown syntax: wikilinks, callouts, embedding, formatting, frontmatter properties

When vault conventions change, update the shared files and both skills stay in sync.

## Requirements

- Obsidian MCP tools connected (create_note, read_note, search_vault, list_files, append_to_note, str_replace_in_note, daily_append, get_tag_info, get_links, get_backlinks, list_properties, project_list, project_context)
- A vault using PARA structure (00 Inbox, 01 Projects, 02 Area, 03 Resources, 04 Archive, meta)

## Vault setup

The plugin expects:

- `00 Inbox/Clippings/` — where web clips land (via Obsidian Web Clipper)
- `meta/Wiki Index.md` — the index of all Claude-generated content (created automatically on first use)
- `meta/Vault Conventions and Decisions Log.md` — living record of vault conventions

## Adding new skills

To add a new skill (e.g., vault-lint), create a folder under `skills/` with a `SKILL.md` that references `shared/VAULT-OPS.md` for vault operations. The shared layer means zero duplication.
