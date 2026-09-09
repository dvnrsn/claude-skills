#!/usr/bin/env bash
# Refresh the published skills from the live ~/.claude/skills/ dir.
#
# Only the skills named in ALLOWLIST are copied. Each file is run through
# _local/scrub.sed (project-specific, gitignored) then scripts/scrub.sed
# (generic) on the way in, and scripts/scan.sh gates the result.
# This script does NOT push and does NOT commit on its own — it stages the
# changes and prints the diff for a human to review. The scheduled job wraps
# it to open a draft PR; it never writes to the public branch unattended.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

SRC="${CLAUDE_SKILLS_SRC:-$HOME/.claude/skills}"

[[ -f _local/scrub.sed ]] || { echo "missing _local/scrub.sed — the project-specific scrub map. Cannot sync safely."; exit 1; }

# The publish allowlist. Add a skill here only after checking it has no
# client names, personal IDs, or dependencies on unpublished skills.
ALLOWLIST=(
  audit-review-personas
  create-review-persona
  run-review-personas
  write-pr
  design-system-model
)

[[ -d "$SRC" ]] || { echo "no skills dir at $SRC (set CLAUDE_SKILLS_SRC)"; exit 1; }

for skill in "${ALLOWLIST[@]}"; do
  [[ -d "$SRC/$skill" ]] || { echo "warn: $skill not in $SRC, skipping"; continue; }
  rm -rf "./$skill"
  mkdir -p "./$skill"
  # copy tree, then scrub every text file in place
  (cd "$SRC/$skill" && tar cf - .) | (cd "./$skill" && tar xf -)
  while IFS= read -r f; do
    case "$f" in
      *.md|*.txt|*.py|*.sh|*.json|*.yml|*.yaml|*.toml)
        sed -i '' -f _local/scrub.sed -f scripts/scrub.sed "$f" 2>/dev/null \
          || sed -i -f _local/scrub.sed -f scripts/scrub.sed "$f"
        ;;
    esac
  done < <(find "./$skill" -type f)
done

git add -A "${ALLOWLIST[@]}"

echo "=== scan ==="
scripts/scan.sh --staged

echo
echo "=== staged diff ==="
git --no-pager diff --cached --stat
echo
echo "Review with: git diff --cached"
echo "Commit when satisfied:  git commit -m \"sync $(date +%F)\""
