---
description: Generate DDL for a rebuild unit (tables, keys, partitioning, temporal, masking, indexes) with a rollback script and a gated deploy wrapper
argument-hint: <unit> <nonprod-target-instance> [-Apply]
allowed-tools: Read, Write, Edit, Grep, Glob, Agent, Bash(git status *), Bash(git diff *)
---
<!-- Name: cdb-schema.md | Purpose: Lock 2 DDL generation | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-schema

Inputs: $ARGUMENTS. Unit name, a non-production target instance, optional `-Apply`.

Preconditions:

- `docs/rebuild/plans/<unit>.md` exists and says `Status: APPROVED`. Otherwise stop and name `/cdb-plan <unit> --approve`.
- Target guard: the instance must be listed in `docs/nonprod-targets.md` and must not look like a production listener (names containing PRD, PROD or a listener suffix). If the check fails, stop and print: "Target refused. To proceed, type: CONFIRM-TARGET: <exact name>". A confirmation counts only if the user typed it in this session.
- Any new schema in the plan has an ADR with `Status: Accepted`. If one is only Proposed, this is gate G2: print the decision needed and end.

Steps:

1. Read the plan card. Take tier, supported versions, partitioning and retention needs from it.
2. Write `src/sql/<schema>/<Unit>.schema.sql`: idempotent (`IF NOT EXISTS` guards), explicit column lists, primary and foreign keys, indexes, and the features the plan names. Follow the `cdb-partition-pattern` skill for sliding-window partitioning. Use system-versioned temporal tables for audit history with a retention period, dynamic data masking for sensitive columns with `UNMASK` granted by scope, and clustered columnstore for history tables where the plan says so.
3. Version gating: Tier 1 and Tier 0 objects use only features present on every supported version. Features that need SQL Server 2022 or 2025 go in a separate `<Unit>.schema.t2-2025.sql` for the Tier 2 AG pair. Tag every feature claim VERIFIED or UNVERIFIED with the doc used.
4. Write `src/sql/<schema>/<Unit>.schema.rollback.sql`. Drops live only here.
5. Write `src/powershell/Install-DbtCentralDbSchema<Unit>.ps1`: report-only by default (prints the batches and the target), executes only with `-Apply` through `Invoke-DbaQuery`, runs `*.rollback.sql` and `*.apply.sql` files only with `-Apply`, uses `[DbaInstanceParameter]`. The wrapper does not embed the non-production allow-list: this command enforces the target guard, and approved production runs happen through the runbook.
6. Write `docs/schemas/<schema>.md` and `docs/scripts/Install-DbtCentralDbSchema<Unit>.md`, each with the standard file header, and list every impacted doc.
7. Parse-check every `.sql` file with the offline parser in the `cdb-collector-pattern` skill (section "Parse checks"). Split on `GO` lines first. This needs no server.
8. Call the `cdb-schema-reviewer` agent on the new files and fix every blocking finding.
9. Without `-Apply`, nothing runs against any instance. With `-Apply` typed by the user, run the install wrapper once against the guarded target, then show the result.

Exit check: all `.sql` files parse; a rollback file exists; the wrapper is report-only by default; `cdb-schema-reviewer` reports no blocking finding; docs exist; no deny-list pattern is present in the new files.

Next: `/cdb-views <unit>` if the plan lists consumers, otherwise `/cdb-test <unit> <nonprod-target>`.
