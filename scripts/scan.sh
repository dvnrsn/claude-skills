#!/usr/bin/env bash
# Secret / PII gate for the public claude-skills repo.
#
# Scans tracked files (or, with --staged, the staged content) against a set of
# regexes and exits 1 on any hit. Wired as a pre-commit hook and run in CI.
#
# Patterns come from two files, merged:
#   scripts/patterns.txt   committed  - generic credential/secret regexes
#   _local/patterns.txt    gitignored - this person's client names, user IDs,
#                                       private repo names, email, etc.
# The project-specific list is deliberately NOT committed: publishing the
# blocklist would publish exactly the identifiers it exists to hide. Keep a
# real _local/patterns.txt on every machine that commits here.
#
# One extended-regex per line. Whole-line comments (optionally indented) and
# blank lines are ignored; there are NO inline comments (a pattern may contain #).
#
#   scripts/scan.sh            # scan all tracked files
#   scripts/scan.sh --staged   # scan staged blobs only (used by the hook)

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# The pattern files hold the literal strings; scanning them would always trip.
skip="scripts/patterns.txt _local/patterns.txt"

patterns=()
while IFS= read -r line; do
  case "$line" in ""|\#*|[[:space:]]*\#*) continue ;; esac
  patterns+=("$line")
done < <(cat scripts/patterns.txt _local/patterns.txt 2>/dev/null)

if [[ ${#patterns[@]} -eq 0 ]]; then
  echo "scan: no patterns loaded (scripts/patterns.txt missing?)" >&2
  exit 2
fi

if [[ ! -f _local/patterns.txt ]]; then
  echo "scan: WARNING - _local/patterns.txt not found; running generic patterns only" >&2
fi

if [[ "${1:-}" == "--staged" ]]; then
  files=$(git diff --cached --name-only --diff-filter=ACM)
  get() { git show ":$1"; }
else
  files=$(git ls-files)
  get() { cat "$1"; }
fi

hits=0
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  case " $skip " in *" $f "*) continue ;; esac
  content=$(get "$f")
  for p in "${patterns[@]}"; do
    if match=$(printf '%s' "$content" | grep -nEi -e "$p" || true); [[ -n "$match" ]]; then
      echo "BLOCKED  $f"
      echo "  pattern: /$p/i"
      printf '%s\n' "$match" | sed 's/^/  /'
      hits=$((hits + 1))
    fi
  done
done <<< "$files"

if [[ "$hits" -gt 0 ]]; then
  echo
  echo "$hits sensitive match(es). Nothing committed. Scrub or remove, then retry."
  exit 1
fi

echo "scan: clean ($(printf '%s\n' "$files" | grep -c . ) files, ${#patterns[@]} patterns)"
