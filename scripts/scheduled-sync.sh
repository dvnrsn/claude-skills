#!/usr/bin/env bash
# Unattended half of the refresh. Runs on a timer (see deploy/ plist).
#
# Never touches main. It syncs onto a dated branch, and only if the scan is
# clean and something actually changed, opens a DRAFT PR for a human to look
# at. A scan failure or a push failure is left loud in the log.

set -uo pipefail
REPO="${CLAUDE_SKILLS_REPO:-$HOME/Code/claude-skills}"
cd "$REPO" || { echo "no repo at $REPO"; exit 1; }

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
log() { echo "[$(date '+%F %T')] $*"; }

git checkout -q main
git pull -q --ff-only || { log "pull failed"; exit 1; }

branch="sync/$(date +%F)"
git checkout -q -B "$branch"

if ! scripts/sync.sh > /tmp/claude-skills-sync.out 2>&1; then
  log "sync/scan FAILED — see /tmp/claude-skills-sync.out"
  osascript -e 'display notification "scan failed, no PR opened" with title "claude-skills sync"' 2>/dev/null || true
  git checkout -q main
  exit 1
fi

if git diff --cached --quiet; then
  log "no changes"
  git checkout -q main
  git branch -q -D "$branch" 2>/dev/null || true
  exit 0
fi

git commit -q -m "sync $(date +%F)"
if ! git push -q -u origin "$branch"; then
  log "push failed"
  exit 1
fi

gh pr create --draft --base main --head "$branch" \
  --title "sync $(date +%F)" \
  --body "Automated skill refresh from \`~/.claude/skills/\`. Scan passed. Review the diff before merging." \
  && log "draft PR opened for $branch" \
  && osascript -e 'display notification "draft PR opened" with title "claude-skills sync"' 2>/dev/null || true

git checkout -q main
