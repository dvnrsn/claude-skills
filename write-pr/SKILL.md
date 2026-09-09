---
name: write-pr
description: >-
  Write or update a pull request description. Use whenever writing a new PR body
  (gh pr create), editing an existing one (gh pr edit --body), or drafting a PR
  description for the user to review. Encodes this user's formatting and process
  preferences for PR bodies so they don't have to be re-stated every time.
---

# Writing a PR description

## Rule one: do not hard-wrap the body

**Never insert a line break in the middle of a paragraph in a PR description.**
Write each paragraph as one continuous line of text (or one long line in the
Markdown source) and let GitHub's renderer wrap it for display. Do not break
lines at ~72 characters, at the terminal width, or at any other fixed column.

This is the opposite of commit messages: commit message **bodies** wrap at
~72 characters. PR **descriptions** never do. Don't carry the commit-wrapping
habit over into the PR body — that's exactly the mistake this rule exists to
block.

Bullet points and headers are fine and expected. The no-wrap rule is about
prose paragraphs only: don't chop a paragraph into short lines.

## Other conventions

- **State the current decision, not a rebuttal of a prior draft.** Don't write
  "the original approach was wrong" or explain why a discarded approach was
  ruled out inside the PR body. If the reasoning matters, put it in the
  Summary section on its own terms, not as a correction of an earlier version.
- **Open as a draft.** Create new PRs with `--draft` and let the user review
  before marking ready for review, unless they've said otherwise.
- **No AI co-author trailer.** Don't add a "Co-Authored-By: Claude" line to
  commits associated with the PR unless the user explicitly asks for it.
- **Update the description when scope expands.** If later commits pushed to
  an open PR add behavior beyond what the description covers (new behavior,
  a bug fix found along the way, a scope change), update the description to
  reflect it before considering the work done — don't wait to be asked.
- **Preserve any hidden marker comments.** Before replacing a PR body
  wholesale (`gh pr edit --body`), fetch the current body first and check for
  trailing HTML comments (e.g. `<!-- slack-pr-notify ... -->`) that other
  tooling depends on — a bot-posted notification reference, a review-tracking
  marker, etc. Carry them forward verbatim; a wholesale overwrite silently
  destroys them with no error. Check the repo's CLAUDE.md for anything
  specific to that project.
- **Don't narrate follow-up pushes as PR comments.** After pushing fixes in
  response to review feedback, say what changed in chat, not as a new comment
  posted on the PR.

## Structure

A `## Summary` (a few bullets or a short paragraph on what changed and why)
plus a `## Test plan` (a checklist of what was or should be verified) covers
most PRs. Add more sections only when the change needs them, e.g. a
migration/rollout note, a screenshots section for UI changes, or a callout for
anything that needs manual follow-up (repointing branch protection, rotating a
secret, running a one-off script).
