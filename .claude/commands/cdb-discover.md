---
description: Inventory current schemas, tables, views, procs, jobs, collectors and reports; write a dependency map, baseline findings and a deletion proposal
argument-hint: [all|sql|powershell|reports|jobs] [path-to-sanitised-inventory-export]
allowed-tools: Read, Grep, Glob, Write, Bash(git status *), Bash(git log *)
---
<!-- Name: cdb-discover.md | Purpose: Lock 1 discovery of the legacy estate | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-discover

Inputs: $ARGUMENTS. First word is the scope (default `all`). An optional second word is a path to a sanitised export of a live inventory. Read that file only. Never connect to an instance.

Preconditions: current branch is not `master`. The repo is the CentralDB repo. If an export path is given, it must not contain Protected C names; if it appears to, stop and ask.

Steps:

1. Schemas, tables, views, procedures: parse `CreateScript-NewCentralDB-Database.sql`, `SQL/**`, `Old_CentralDB_DDL`, `OlaHallengren/**`. List each object once as `schema.name`, kind and source file.
2. Collectors: list `Collect/*.ps1`, `CentralDB/*.ps1`, `Original/*.ps1`. For each, record the target tables it writes and the dbatools cmdlets it calls.
3. Jobs: read `docs/SQL-AGENT-JOBS.md` and list each job, schedule and script.
4. Reports: list `CentralDB_Reports/*.rdl`. For each, extract the dataset query text and the objects it reads.
5. Dependency map: write `docs/rebuild/discovery/dependency-map.md` as a table `collector -> table -> view -> report`, plus a Mermaid flowchart of the same. Mark any object with no consumer as ORPHAN.
6. Baseline findings: scan legacy files against `docs/deny-list.md` and write counts per row to `docs/rebuild/discovery/legacy-baseline.md`. Label every finding BASELINE. These do not fail any gate and are not fixed in this command.
7. Deletion proposal: write `docs/decisions/deletion-proposal.md`. Intake answer 6 says reports are archaic and views are to be cleared out and redesigned. List every `.rdl`, the report project files and every legacy view as a PROPOSED deletion with its dependents and the replacement unit. Do not delete or move anything.
8. Fact tags: mark anything inferred rather than read as UNVERIFIED.

Gate GD: print "Decision needed: approve, amend or reject each line of docs/decisions/deletion-proposal.md" and stop. This command never proceeds past it.

Exit check: the object counts in the dependency map match a fresh `Grep` count of `CREATE TABLE`, `CREATE VIEW` and `CREATE PROCEDURE` in the same files; the deletion proposal exists and every line says PROPOSED; no file outside `docs/rebuild/discovery/` and `docs/decisions/` changed (`git status`).

Next: `/cdb-plan <unit>` for the first unit in the M1 row of `docs/workflow-map.md` (proposed: `svr-core`).
