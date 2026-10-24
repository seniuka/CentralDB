---
description: Read the repo and report rebuild phase, open branches, failing gates and the next step; refreshes the state section of the workflow map
argument-hint: (no arguments)
allowed-tools: Read, Grep, Glob, Edit, Bash(git status *), Bash(git branch *), Bash(git log *), Bash(git diff *)
model: haiku
---
<!-- Name: cdb-status.md | Purpose: resume any session from the repo alone | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-status

Inputs: $ARGUMENTS (none expected; ignore anything supplied)

Why `model: haiku`: this command is mechanical read-and-report work, so the cheapest model is enough. DECISION: change it if the summaries are too thin.

Preconditions: the working directory is the CentralDB repo root. `docs/workflow-map.md` exists. If not, stop and say the scaffold is missing.

Steps:

1. Run `git status`, `git branch -a` and `git log -15 --oneline`. Record the current branch and any branch that is ahead of its upstream.
2. List `docs/rebuild/plans/*.md`. For each, read the `Status:` line (DRAFT or APPROVED) and the unit name.
3. For each unit, find its artifacts: `src/sql/**`, `src/powershell/**`, `src/jobs/**`, `Tests/**`, `docs/rebuild/quality/<unit>.md`, `docs/scripts/*`. Derive the Lock reached: plan card means 1, any `src/` file means 2, a test file means 3, a quality report with zero deny-list hits means 4, a changelog entry for the unit means 5, a deploy plan file means 6.
4. Read each quality report. A report with deny-list hits, or older than the newest file of its unit (compare with `git log -1 --format=%cI -- <path>`), is a failing gate.
5. Check that `docs/nonprod-targets.md` exists. If not, list it as a blocker for any command that takes a target.
6. Rewrite only the text between `<!-- CDB-STATE:BEGIN -->` and `<!-- CDB-STATE:END -->` in `docs/workflow-map.md` using the same table layout. Do not touch any other line.
7. Print a short report: phase, branch, failing gates, blockers, next command.

Choosing the next command, first match wins:

- no `docs/rebuild/discovery/dependency-map.md`: `/cdb-discover all`
- discovery exists, no plan card: `/cdb-plan <first unit in the milestone table>`
- plan card DRAFT: stop; the decision needed is G1, approve with `/cdb-plan <unit> --approve`
- plan APPROVED, no `src/` files: the Develop command that matches the unit (schema, collector, merge, views)
- `src/` files without tests: `/cdb-test <unit> <nonprod-target>`
- tests without a clean quality report: `/cdb-quality <unit>`
- clean quality report, no changelog entry: `/cdb-docs <unit>` then `/cdb-version <unit>`
- versioned and a PR is open: stop; the decision needed is G3 (PR review)
- merged: `/cdb-deploy-plan <unit> <environment>`

Exit check: `git diff -- docs/workflow-map.md` shows changes only between the two markers, and the report names exactly one next command or one human decision.

Next: the command named in step 7.
