---
description: Generate the merge process from a management server to the reporting and analytics server, with watermarks and reconciliation
argument-hint: <unit> <nonprod-management-server> <nonprod-reporting-server> [-Apply]
allowed-tools: Read, Write, Edit, Grep, Glob, Agent, Bash(git status *), Bash(git diff *)
---
<!-- Name: cdb-merge.md | Purpose: Lock 2 Tier 1 to Tier 2 merge generation | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-merge

Inputs: $ARGUMENTS. Unit name, a non-production management server, a non-production reporting server, optional `-Apply`.

Preconditions:

- The plan card is APPROVED and states the classification tier of the unit. If Protected C and Protected A/B data could meet in the reporting server, stop: that is a DECISION recorded in the card, not something to assume.
- Target guard applies to both servers: each must be in `docs/nonprod-targets.md` and must not look like a production listener. If either fails, stop and print: "Target refused. To proceed, type: CONFIRM-TARGET: <exact name>". The confirmation must be typed by the user in this session.
- The `src/sql/` objects the merge reads and writes exist on disk (from `/cdb-schema`). Otherwise stop and name `/cdb-schema <unit> ...`.

Steps:

1. Use the `cdb-merge-pattern` skill. It defines the watermark table, the idempotent upsert, per-run reconciliation and the failure model.
2. Write `src/powershell/Invoke-DbtCentralDbMerge<Domain>.ps1`: single-block, report-only by default, `[DbaInstanceParameter]` for both servers, bulk movement through `Write-DbaDbTableData` into a staging table on the reporting server followed by a set-based merge.
3. Write the reconciliation script `src/sql/<schema>/<Unit>.merge-reconcile.sql` (row counts and a deterministic checksum per batch, both sides).
4. Write the Agent job script and rollback in `src/jobs/`, report-only unless `-Apply`.
5. Contained AG note: if the reporting AG is contained, Agent jobs run on the primary replica only, and the job must connect through the listener. Tag as VERIFIED only after re-reading the current Microsoft page; otherwise UNVERIFIED.
6. Write `docs/scripts/<Name>.md` for each script. Impacted docs always include `docs/SCRIPT-REFERENCE.md`, `docs/SQL-AGENT-JOBS.md` and the `docs/schemas/<schema>.md` of every schema touched on both tiers.
7. Parse-check PowerShell on 5.1 and 7.2+ and T-SQL offline (skill `cdb-collector-pattern`, section "Parse checks").
8. Call the `dbatools-script-reviewer` agent and fix every blocking finding.
9. Without `-Apply`, nothing runs. With `-Apply` typed by the user, run one merge cycle between the two guarded servers and show the reconciliation result.

Exit check: the merge is re-runnable without duplicating rows; watermark and reconciliation exist; both scripts parse; no deny-list pattern is present; docs exist.

Next: `/cdb-test <unit> <nonprod-reporting-server>`.
