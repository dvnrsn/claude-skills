# claude-skills

Personal [Claude Code](https://claude.com/claude-code) skills I use day to day. Each directory is one skill: a `SKILL.md` with YAML frontmatter (`name`, `description`) and a body Claude loads when the task matches.

Drop any of these into `~/.claude/skills/<name>/` to use it.

## Skills

### Code review pipeline

A small roster of single-purpose reviewer agents, each owning one risk lane, fanned out over a diff and reconciled into one report rather than N opinions.

- **`audit-review-personas`** — survey a repo's existing review roster and PR history, then recommend which reviewer lane is actually missing (evidence-backed, not generic best-practice intuition).
- **`create-review-persona`** — build one new reviewer persona once a lane is chosen: establish it with evidence, write the agent definition and grounding doc, wire it into the orchestrator.
- **`run-review-personas`** — run a review with the roster: pick which personas apply to the changed files, fan them out, verify and dedupe findings, rank by severity.

### Authoring

- **`write-pr`** — PR description conventions: no hard-wrapped prose, state the current decision (not a rebuttal of a prior draft), open as draft, keep the description current as scope grows, preserve hidden marker comments.

### Design systems

- **`design-system-model`** — a provider-neutral way to reason about any design system: the four-layer structure (foundations/tokens → components → patterns → guidelines & governance) that the major published systems converge on, what belongs in each layer, and the canonical references behind them.

## Publishing safety

This repo is public and mirrors a larger private set. A few guards keep personal and client detail out:

- **`scripts/scan.sh`** — greps tracked (or staged) content against regex patterns and exits non-zero on any hit. Patterns are merged from `scripts/patterns.txt` (committed: generic credential/secret regexes) and `_local/patterns.txt` (gitignored: this machine's client names, user IDs, private repo names, email). The project-specific list is never committed — publishing a blocklist would publish the very identifiers it hides. Anyone committing here keeps a real `_local/patterns.txt`; the pre-commit hook is the full gate, CI runs the generic patterns as a backstop.
- **`.githooks/pre-commit`** runs the scan against staged content (`git config core.hooksPath .githooks` to enable); **`.github/workflows/scan.yml`** runs it on every push and PR.
- **`scripts/sync.sh`** refreshes the skills from a local `~/.claude/skills/`, only the ones on an explicit allowlist, each passed through `_local/scrub.sed` then `scripts/scrub.sed` on the way in. It stages and prints a diff; it never commits or pushes on its own.
- **`_local/`** is gitignored. It holds `patterns.txt` and `scrub.sed` — the project-specific half of both mechanisms.
