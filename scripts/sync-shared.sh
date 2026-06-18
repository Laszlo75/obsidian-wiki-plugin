#!/usr/bin/env bash
#
# sync-shared.sh
# Propagate the canonical shared references into each skill's references/ folder.
#
# WHY THIS EXISTS
# ---------------
# shared/ is the single source of truth for vault conventions and Obsidian
# formats. But skills must load their references from their OWN references/
# folder (a sibling of SKILL.md), because the skill packaging / mount only
# carries a skill's own directory -- plugin-root siblings like shared/ do NOT
# travel with it when a skill is loaded in a sandboxed environment.
#
# This script bridges that gap: edit shared/, run this, then commit the
# regenerated references/ folders so a plain `git clone` install works
# out of the box.
#
# USAGE
# -----
#   bash scripts/sync-shared.sh
#
# It copies every file in shared/ into each skill's references/ folder.
# Skill-owned reference files (e.g. vault-lint's LINT-CHECKS.md) are left
# untouched -- only the shared filenames are overwritten.
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS="$ROOT/skills"
SHARED="$SKILLS/shared"

[ -d "$SHARED" ] || { echo "error: shared/ not found at $SHARED" >&2; exit 1; }
[ -d "$SKILLS" ] || { echo "error: skills/ not found at $SKILLS" >&2; exit 1; }

echo "Syncing shared references from: $SHARED"

for skill in "$SKILLS"/*/; do
  [ -f "${skill}SKILL.md" ] || continue
  name="$(basename "$skill")"
  [ "$name" = "shared" ] && continue
  refs="${skill}references"
  mkdir -p "$refs"

  # One-time legacy cleanup: earlier builds shipped a divergent, misnamed copy
  # at references/ARTIFACTS.md (it used a non-existent `title` property in its
  # Bases templates). The canonical file is shared/OBSIDIAN-ARTIFACTS.md.
  rm -f "${refs}/ARTIFACTS.md"

  n=0
  for f in "$SHARED"/*.md; do
    cp "$f" "$refs/"
    n=$((n + 1))
  done
  echo "  ${name}: synced ${n} shared file(s) -> ${refs#$ROOT/}"
done

echo "Done. Review with 'git status' / 'git diff', then commit the references/ folders."
