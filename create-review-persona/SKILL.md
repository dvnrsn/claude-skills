---
name: create-review-persona
description: Build one new specialized reviewer persona for a repo's agent-based PR review pipeline, once a lane is already chosen. Use when asked to add a review persona, create a reviewer agent for a specific risk lane or failure class, or extend a review pipeline with a new dimension. If no lane is named yet, use `audit-review-personas` first to get an evidence-backed recommendation, then come back here to build it. Detects the repo's existing conventions (agent directory, grounding docs, orchestrator skill) rather than assuming a fixed layout, and walks through establishing the lane with evidence, writing the agent definition and grounding doc, and wiring it into the orchestrator (`run-review-personas`, or whatever fans reviewers out in this repo) so the panel actually picks it up.
---

# Creating a review persona

The pattern: a PR review pipeline made of several specialized agents, each owning exactly one risk lane (e.g. authorization, performance, data-migration safety, vendor/integration correctness, code-convention adherence, a specific framework's idioms, or an execution/verification pass), fanned out by an orchestrator over a changed-file set, each grounded in a doc of that lane's real idioms and failure modes rather than generic best-practice advice, and each deferring to CI for whatever it already catches mechanically. Findings get deduped and ranked, and the pipeline posts a draft review rather than auto-merging or auto-submitting. This skill builds one persona; pair it with `audit-review-personas` (recommends which lane is missing) and `run-review-personas` (fans the roster out over an actual review, selecting which personas participate).

## 0. Detect the repo's existing conventions first

Before writing anything, find out whether this repo already has a roster. Look for an agent-definitions directory (commonly `.claude/agents/*.md`), a docs directory grounding those agents (commonly `docs/review-pipeline/` or similar), and an orchestrator skill that fans multiple reviewer agents out over a PR. If one exists, read its index/README and its shared-conventions doc (severity scale, output format, report structure) before doing anything else, and match its existing file layout and naming style exactly — don't introduce a second convention alongside an established one.

If no roster exists yet, this is a bootstrap: setting up the initial roster usually means building several personas in one pass, not just one, since an evidence-based survey of a codebase's review history typically surfaces multiple orthogonal lanes at once (this is how the roster this skill family is modeled on was originally designed — one proposal, several personas, built together). Before building anything, decide with the user: where agent definitions and grounding docs will live, and what the shared-conventions doc (severity/disposition scale, output mode, report format) will say, since every persona should reference that doc rather than each reinventing its own. Stand up that shared doc once, then run steps 1 through 5 below once per persona in the initial set — each persona still gets its own lane, evidence, grounding doc, and agent definition; only the shared-conventions doc and the roster/orchestrator wiring are shared setup done a single time. After the initial roster ships, later invocations of this skill are almost always the single-persona case: add one more lane to an already-established roster.

## 1. Establish the lane before writing anything

If the lane isn't already chosen, stop and run `audit-review-personas` instead of guessing — it surveys the repo's roster and review history for evidence-backed gaps rather than inventing a lane from generic reviewer intuition.

A persona earns its place only if it catches a failure class that no existing persona already owns and no CI check already catches mechanically. The design principle: personas add only the domain-specific semantic layer on top of what a generic linter or scanner already enforces. Check the roster's index and the boundaries/deferral section of each existing persona before assuming this is new ground — a narrower slice of an existing lane usually belongs in that persona's grounding doc as another checklist item, not as a new standing persona. Keep the roster small and orthogonal; that's a deliberate design goal, not an oversight.

Ground the new lane in evidence: sample real merged-PR review comments or incidents in this lane (`gh api` search, `git log` on the relevant paths, or the team's own memory of what keeps coming up in review) so the checklist reflects what actually gets caught in practice, not generic best-practice advice a linter could already give.

If it's genuinely ambiguous whether this deserves a new persona versus an addition to an existing one, ask the user rather than guessing — it's a scope decision that's expensive to reverse once a persona is wired into the orchestrator and PRs start seeing its comments.

## 2. Decide the shape

- **Name:** match whatever naming style the roster already uses (single evocative words, human names, literal role labels — follow the established convention). If this is the first persona, pick a style and note it so future personas stay consistent.
- **Model tier:** a heavier/more capable model for lanes that need multi-file reasoning and tracing data flow across files; a lighter model for lanes that are mostly checklist application against a known rubric.
- **Trigger scope:** most personas should be path-triggered — they wake only when the PR's changed-file set matches their lane's paths. Reserve always-run for a genuinely universal lane (conventions, general correctness). Write down the actual paths/globs in this repo the new lane cares about; vague scope means either it never triggers or it triggers on everything and burns tokens for nothing. This is also exactly what `run-review-personas` needs later to compute its default selection, so be precise.
- **Tools:** default to read-only tools (file read/search/grep, shell for read-only commands). Add an integration-specific tool only when the lane genuinely needs it (e.g. pulling a linked task from a project tracker to verify a stated requirement). Reviewers never get write/edit tools — they produce findings, not patches.

## 3. Write the grounding doc

Create a grounding doc for the persona in the roster's docs location (split into multiple docs if the lane has genuinely separate knowledge bases, e.g. one doc for domain facts and another for fix idioms). Structure it around:

- Any architecture/idiom knowledge the persona needs that isn't obvious from reading the code cold.
- A **must-catch** list of concrete, specific patterns, ideally each with a real example of the bad version and why it's bad, not generic advice. Specific enough that a reviewer can pattern-match against it on sight.
- A **defers-to** list naming exactly which CI check or which sibling persona already owns adjacent ground, so the new persona doesn't re-report what's already covered.

## 4. Write the agent definition

Create the persona's agent definition file, matching the roster's existing lean style, e.g.:

```markdown
---
name: <persona>
description: <One or two sentences: what lane this reviews, which paths/files trigger it, what specific failure classes it catches>. Reviews only; never edits code. Runs standalone or as a review teammate.
tools: <read-only tools; add an integration tool only if the lane needs one>
model: <tier appropriate to the lane's reasoning depth>
---

You are <Persona>, a specialized reviewer for this codebase focused on ONE lane: <lane>. <One or two sentences of domain context if it changes how the persona should think, e.g. stack facts, scale facts>. You never modify code; you produce findings.

## First step, always

Read the shared conventions doc and your grounding doc. Apply them literally.

## What you check

- <Concrete, specific bullet rubric items, grounded in the evidence from step 1 — not generic advice>

## Boundaries

<What's yours vs. deferred to CI (name the specific tool/gate) and to which sibling persona, by name, for their lane>
```

Do not restate severity levels, disposition tiers, output-mode defaults, report format, or posted-comment conventions inline if a shared-conventions doc already covers them — that doc is the single place that gets tuned for every persona, and duplicating it in an agent file is exactly the drift it exists to prevent.

## 5. Wire it into the pipeline

Writing the agent file alone does nothing; the orchestrator and any index need to know the persona exists:

- **The roster's index/README** — add an entry (name, lane, model).
- **The orchestrator** (`run-review-personas`, or whatever fans reviewers out in this repo) — add the persona's name wherever the roster is enumerated, and add it to the trigger list (always-run or path-triggered with the actual paths from step 2).
- **Anywhere else the roster is enumerated by name** — grep for an existing persona's name across the repo before assuming the index and orchestrator are the only two places; other skills or docs may list the roster too.

## 6. Validate before calling it done

- Standalone-run the new persona against one real PR that clearly sits in its lane. Confirm the findings are genuinely net-new (not something a human or another bot already said on that PR) and that every file:line citation is actually correct.
- Run it against a PR outside its lane, or one in-lane but clean, and confirm it returns an honest clean bill instead of manufacturing a finding to justify its own existence. A wrong clean bill is worse than a missed finding — this is the false-positive discipline the rest of a mature roster should already be held to.
- Re-read the trigger paths you wrote into the orchestrator against a real PR's changed-file list and confirm they actually would have fired it; a persona with the right rubric but the wrong glob never runs.
