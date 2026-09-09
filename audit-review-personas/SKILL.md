---
name: audit-review-personas
description: Survey a repo's agent-based PR review pipeline and its review history to recommend which reviewer persona(s) are missing. Use when asked to audit the review roster, find gaps in review coverage, ask what review personas a codebase is missing, or "look at the repo and recommend" a new persona without a lane already named. Builds a covered-lanes baseline from the existing roster and CI, then looks for phantom persona references, demoted ideas that never got a real CI replacement, uncovered trigger paths, and recurring PR review-comment themes, and presents ranked, evidence-backed candidates rather than picking one unilaterally. Pairs with `create-review-persona` (build the recommended persona) and `run-review-personas` (choose which personas run on a given review).
---

# Auditing the review-persona roster

Recommending a new reviewer persona is a scope decision, not a style choice: every persona added becomes a recurring cost (every future PR touching its lane spends tokens reviewing it) and a recurring voice in every review from then on. Don't invent a lane from generic reviewer intuition — the entire premise of a persona-based pipeline is that each lane is mined from the codebase's own evidence, not best-practice boilerplate. This skill surveys before it recommends.

## 1. Build the "already covered" baseline

Read the roster's index/README and every existing persona's description and boundaries/deferral section — that section states explicitly what it defers, which is exactly where phantom gaps hide. Add whatever the shared-conventions doc (or each persona's grounding doc) says is already deferred to CI: linters, security scanners, migration-safety checks, type checkers, i18n/schema sync gates, whatever this repo actually runs. Anything already on this list is out of scope for a new persona; it belongs as a checklist item on an existing persona or as a CI gate, not a new standing agent.

## 2. Look for gap signals, cheapest first

- **Phantom references.** Grep the agent-definitions directory and its grounding docs for a persona name mentioned (typically in a "defers to" line) that doesn't exist in the actual roster — that's a lane someone already flagged as needed and never built.
- **Deferred or demoted ideas already on record.** If a design doc or proposal for the roster exists, re-read any "deferred" or "demoted" notes in it. An idea demoted in favor of a CI check is a live candidate again if that CI check never actually shipped — verify before recommending it back.
- **Uncovered trigger paths.** Compare the orchestrator's path-triggered list (whatever paths currently wake each persona) against the repo's real top-level structure. A directory that carries real review weight and isn't claimed by any existing persona's trigger paths or a CI gate is a candidate.
- **Recurring review-comment themes.** Spot-check a handful of recent merged PRs' review comments (`gh api repos/<owner>/<repo>/pulls?state=closed&sort=updated&per_page=20`, then `.../pulls/<n>/comments` on a few) for a recurring category that doesn't map to any existing lane. A handful of recent PRs corroborates a hypothesis, it doesn't found one on its own — treat it as a sanity check, not proof. A larger, systematic pass over review history (hundreds of PRs, labeled by category) is the gold-standard version of this signal if the repo's history is available and the gap is worth that investment.
- **Recurring human overrides of an existing persona.** If a persona's findings are frequently disputed or reclassified in one particular direction (e.g. always escalated, always dismissed for the same reason), that's a signal the lane needs splitting or the persona needs retuning, not necessarily a new persona, note this distinction when it comes up.

## 3. Rank and present, don't decide

For each candidate: name the gap, cite one or two concrete examples found (a phantom reference, a specific PR comment, a specific uncovered path), and state why it isn't already covered by an existing persona or CI. Rank by how much evidence backs it, not by novelty.

Adding a standing persona is a recurring cost, so present the ranked list and let the user pick rather than choosing unilaterally — use `AskUserQuestion` when there's more than one plausible candidate, and don't default to "the most interesting one" or "the first one found." If the survey turns up nothing with real evidence behind it, say so plainly rather than manufacturing a candidate to have something to report; a roster that's actually complete for its current scope is a valid finding.

Once a lane is chosen, hand off to `create-review-persona` to build it.
