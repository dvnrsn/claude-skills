---
name: run-review-personas
description: Run a PR or diff review using a repo's agent-based reviewer roster, choosing which persona(s) participate. Use when asked to run a code review, review a PR with the review pipeline/roster, do a "trusted" or "full" review, or explicitly choose which specialized reviewer agents run on a change (e.g. "just run the security one", "which personas apply here"). Defaults to auto-selecting every persona whose trigger paths match the changed files, plus any always-run persona, but an explicit request for specific persona(s) overrides that default, and the skill asks when the choice is genuinely ambiguous. Fans the selected personas out in parallel, verifies findings, dedupes, ranks by severity, and reports human-review items first.
---

# Running the review-persona roster

This orchestrates whichever specialized reviewer personas a repo already has (see `create-review-persona` and `audit-review-personas` if the roster doesn't exist yet or needs a new lane) over one PR or diff. The two things this skill owns that a single generic review pass doesn't: **selecting which personas actually run**, and **reconciling their findings into one trustworthy report** instead of N separate opinions.

## 0. Detect the roster and its conventions

Find the agent-definitions directory, the grounding docs, the shared-conventions doc, and the roster's index/README. Read the index and every persona's description before selecting anything — the description is where trigger paths, always-run status, and lane boundaries are documented.

## 1. Resolve the target and its changed-file set

Input is a PR number/URL/branch, or a local diff. For a PR, get the authoritative changed-file list with pagination (a naive `gh pr view --json files` or similar commonly caps around 100 files; use the paginated files endpoint instead) — an uncovered file past a pagination cap is a silent coverage gap, not a clean bill. For a local diff, use the actual diff against the right base, not an assumption about what changed.

## 2. Select which personas run

This is the step this skill exists for. Three cases, in priority order:

1. **Explicit selection.** If the user named specific persona(s) ("just run the security one", "skip the frontend pass", "only X and Y"), run exactly that set. An explicit request always overrides the default — don't second-guess it by adding personas the user didn't ask for, and don't silently drop one they did ask for even if its trigger paths don't match the diff (an explicit ask means run it regardless).
2. **Sane default (no selection given).** Auto-select every persona whose documented trigger paths match the changed-file set, plus every persona marked always-run (typically a conventions/simplicity lane and a general-correctness safety net). Compute this from what each persona's own description/frontmatter says triggers it — don't hand-wave "the obviously relevant ones," compute the match against the real path list. State which personas were selected and why (which path matched), and which existing personas were skipped and why (no path in their lane matched), so the selection is auditable, not implicit.
3. **Ambiguous or exploratory ask.** If asked "which personas should run" or "help me pick" without either a concrete selection or a diff to compute a default from, present the roster with each persona's lane and ask via `AskUserQuestion` (multi-select) rather than guessing.

After selecting, do the coverage cross-check: every changed file should fall under at least one selected persona's lane or a deliberate skip (a file type genuinely outside the roster's scope, e.g. a lockfile). A changed file matched by no persona and no explicit skip is a gap — note it rather than silently letting it go unreviewed.

## 3. Calibrate effort to the change (if the repo doesn't already define this)

Not every review needs full depth. A small, low-risk diff (docs, copy, a narrow test-only change) gets a lighter single pass; a diff that's large or touches a lane's own declared risk paths (authorization, migrations, anything comp/PII/security-adjacent, an integration boundary) earns full depth regardless of size, since risk overrides size. If the repo's orchestrator conventions already define a tiering scheme, use it instead of inventing a second one.

## 4. Fan out the selected personas

Spawn each selected persona in parallel, not sequentially — give each the whole diff and the full changed-file list, not a curated subset (fencing a persona to a pre-filtered file list silently drops files no persona then covers). Hand each the shared context once (PR body, diff, existing review comments, resolved-thread state) rather than letting each persona re-fetch and re-summarize it; that's both the biggest redundant-cost multiplier on a multi-persona run and where a lossy per-persona summary can quietly drop a real finding. Instruct each persona to dedupe against what's already been said (by humans, by other bots, by the author's own stated TODOs) — a well-reviewed PR's value from any one persona is the net-new delta, not a restatement.

## 5. Verify, if the roster has a verification persona

If the roster includes a persona whose job is confirming findings by execution (running the code, probing a claim) rather than by re-reading it, hand it the other personas' Blocker/Recommendation-tier findings before finalizing. A finding a verifier can neither confirm nor refute against the actual PR-head code (not the working tree, not main) stays unverified rather than being silently dropped or silently promoted.

## 6. Aggregate, dedupe, and rank

Merge all findings across personas. Where two personas flag the same line, keep the more specific/owning lane's version and note the corroboration rather than posting both. Resolve any cross-lane handoff a persona explicitly noted. Rank by severity. Split the output into what's settleable (concrete, verified, actionable) versus what needs a human's judgment call (posture questions, ambiguous requirements, anything the personas flagged as "worth a second opinion" rather than a definite finding) — the human-judgment bucket goes first in the report, not buried under the settled findings.

## 7. Report

Follow whatever posting mechanism the repo's roster already uses (a draft/pending review, inline comments, a terminal report) — don't invent a new one. Lead with: which personas ran and which were skipped (and why), the human-judgment items, then the ranked settleable findings, then counts. Never auto-submit or auto-merge; the pipeline informs, a human decides.
