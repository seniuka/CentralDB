---
description: Generate data migration scripts from old to new objects with row-count and checksum reconciliation; report-only unless -Apply
argument-hint: <unit> <old-schema> <new-schema> <nonprod-target-instance> [-Apply]
allowed-tools: Read, Write, Edit, Grep, Glob, Agent, Bash(git status *), Bash(git diff *)
---
<!-- Name: cdb-migrate.md | Purpose: Lock 2 old-to-new data migration | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-migrate

Inputs: $ARGUMENTS. Unit name, source schema, destination schema, a non-production target instance, optional `-Apply`.

Preconditions:

- The plan card is APPROVED and says which legacy data is worth keeping. Intake answer 6 clears out the old reports and views; tables with history may still need migrating. If the card does not say, stop and ask.
- Target guard: the instance must be in `docs/nonprod-targets.md` and must not look like a production listener. If the check fails, stop and print: "Target refused. To proceed, type: CONFIRM-TARGET: <exact name>". The confirmation must be typed by the user in this session.
- New objects exist in `src/sql/`.

Steps:

1. Write `src/powershell/Invoke-DbtCentralDbMigrate<Unit>.ps1`: single-block, report-only by default. Report mode reads both sides and prints the planned row counts per table. `-Apply` copies in batches inside transactions per batch.
2. Reconciliation: after each table, compare row counts and a deterministic checksum over the business columns, both sides. Any mismatch fails the run and leaves the source untouched. The script never deletes source rows.
3. Idempotent: re-running does not duplicate rows (key-based insert of missing rows, or truncate-free staging then merge).
4. Classification: test data and fixtures are synthetic. Never copy Protected C rows into a Protected A/B location.
5. Write `docs/scripts/Invoke-DbtCentralDbMigrate<Unit>.md` with rollback guidance (restore from backup taken by the runbook, since the script deletes nothing). List impacted docs.
6. Parse-check (skill `cdb-collector-pattern`, section "Parse checks"), then call the `dbatools-script-reviewer` agent.
7. Without `-Apply`, nothing runs against any instance. With `-Apply` typed by the user, run once against the guarded target and show the reconciliation output.

Exit check: report-only default confirmed by reading the param block; reconciliation present for every table; no `DELETE`, `TRUNCATE` or `DROP` outside an `-Apply` block; script parses.

Next: `/cdb-test <unit> <nonprod-target>`.
