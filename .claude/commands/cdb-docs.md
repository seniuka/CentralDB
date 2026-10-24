---
description: Regenerate per-script documentation and flag every impacted doc file; proposes removals, never deletes
argument-hint: <unit|all>
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(git status *), Bash(git diff *), Bash(git log *)
---
<!-- Name: cdb-docs.md | Purpose: Lock 5 documentation set | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-docs

Inputs: $ARGUMENTS. A unit name or `all`.

Preconditions: a PASS quality report exists for the unit (`docs/rebuild/quality/<unit>.md`). Otherwise stop and name `/cdb-quality <unit>`.

Steps:

1. List the unit's scripts under `src/powershell/`, `src/jobs/` and `src/sql/`.
2. For each, rewrite `docs/scripts/<Name>.md` from the script itself: file header block, purpose, parameters from the `param` block (name, type, default, mandatory), report-only and `-Apply` behavior, target guard, result contract, examples with placeholder names only (no real server names), rollback, version, and the impacted-docs list. Do not invent behavior the script does not have.
3. For each schema in `src/sql/`, refresh `docs/schemas/<schema>.md` (objects, columns, retention, partitioning, masking, permissions).
4. Impact analysis: for every script, check these files and list each one that must change, with the reason: `docs/SCRIPT-REFERENCE.md`, `docs/SQL-AGENT-JOBS.md` (Agent job), `docs/TESTING.md` (tests), `README.md` and `CentralDB-Ops-Runbook.md` (architecture or operations change), `docs/schemas/*.md` for every schema touched on either tier, and the plan card. Write the result to `docs/rebuild/impact/<unit>.md` and apply the edits that are additions. Anything that would remove or rename existing text is listed as PROPOSED for approval (gate GD).
5. Stale docs: list docs that describe objects no longer in `src/` as PROPOSED removals in `docs/decisions/deletion-proposal.md`. Do not delete.
6. Classification check: no Protected C name, host or count appears in any doc or example.
7. Tag any unchecked statement UNVERIFIED.

Exit check: every script under the unit has a doc; every doc has a header; `docs/rebuild/impact/<unit>.md` lists each impacted file with a reason; `git status` shows no deleted file.

Next: `/cdb-version <unit>`.
