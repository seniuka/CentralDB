---
name: cdb-partition-pattern
description: The CentralDB sliding-window partitioning pattern for high-volume tables (monthly RANGE RIGHT, aligned archive table, gated slide procedure). Use from /cdb-schema and /cdb-test when a plan card calls for partitioning or retention on a log, history or trend table.
---
<!-- Name: SKILL.md (cdb-partition-pattern) | Purpose: reusable sliding-window procedure | Version: 0.1.0 | Standard: v5.0.0 (UNVERIFIED, text not in repo) | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# CentralDB sliding-window partition pattern

Use this when a plan card names a table that grows without bound (command logs, run logs, history, trend data) and needs retention. The templates are in `templates/`. Copy them to `src/sql/<schema>/`, rename the objects, and adjust from the plan card.

Tags: `VERIFIED` (checked this session, 2026-10-24), `UNVERIFIED` (not checked), `DECISION` (needs the user).

## What a sliding window is

New months arrive at the right edge of the partition function, old months leave at the left. Each cycle does three things: add a future boundary (`SPLIT RANGE`), move the oldest live month out of the live table by metadata-only `SWITCH`, and later purge archive months older than the archive window. Switching moves no rows, so the live table is locked only briefly.

## Facts that shape the design

- Table and index partitioning is available in Enterprise, Standard and Express on SQL Server 2025, `VERIFIED` on the Microsoft editions page. Availability on older versions is `UNVERIFIED` and must be checked per supported version before a Tier 0 or Tier 1 design relies on it.
- Compression, columnstore and temporal tables are also in every 2025 edition, `VERIFIED`. Standard limits batch-mode DOP to 2 and the columnstore segment cache to 32 GB, `VERIFIED`.
- The partitioning column must be in every unique index. The legacy central table `Inst.CommandLog` is not partitioned: it has a primary key on `(CommandLogID, CommandType)`, `StartTime` is `datetime`, and it sits on filegroup `[Inst]`, `VERIFIED` by reading `CreateScript-NewCentralDB-Database.sql` this session. A partitioned replacement needs the key `(StartTimeUtc, <id>)`, so any consumer that looks rows up by id alone changes. That is why the plan card must list consumers first.
- Optimized locking (SQL Server 2025 only, per database, needs accelerated database recovery) does not use lock-after-qualification on tables with a columnstore index, `VERIFIED`. Weigh that if the same table is columnstore.

## Procedure

1. Read the plan card: table, grain (monthly by default), live window, archive window, future boundaries, filegroup layout, expected rows per month.
2. Copy `templates/partitioned-table.sql` and edit the columns, boundaries and filegroup. Keep the archive table aligned (same function, same scheme, same indexes). `DECISION`: one shared function for live and archive is used here because it makes `SWITCH` trivial; the cost is that old empty boundaries are never merged automatically.
3. Copy `templates/slide-window.apply.sql`. Keep the `@Apply bit = 0` default and the `.apply.sql` suffix: the purge in step 3 of the procedure is a destructive statement, and `docs/deny-list.md` allows destructive T-SQL only in `*.apply.sql` and `*.rollback.sql` files that a wrapper refuses to run without `-Apply`.
4. Copy `templates/slide-window.rollback.sql`. Reversing a partitioning change is a restore from the runbook's backup. State that in the unit's doc.
5. Agent job: a T-SQL step calling the procedure with `@Apply = 1`, monthly, created by a report-only-by-default installer (see `cdb-collector-pattern`, section 6, for the dbatools Agent cmdlets). If the reporting database is in a contained AG, Agent jobs run on the primary replica only, `VERIFIED` on the contained AG page.
6. Migration of an existing unpartitioned table: build the partitioned copy, move data with `/cdb-migrate` (row count and checksum per month), then switch names in a change window. Never convert in place.
7. Parse-check every `.sql` file offline (`cdb-collector-pattern`, section 8). Then run `/cdb-test` against a non-production target. The templates have never been executed on any instance, so their runtime behavior is `UNVERIFIED`.

## Checks the schema reviewer applies

- Boundaries are generated ahead of time and never hard-coded past the retention window.
- A switch target partition is empty before the switch; the procedure skips and reports otherwise.
- The purge builds only an integer partition number into its statement.
- Report-only prints every action and changes nothing.
- Row counts per month before and after a cycle reconcile: live plus archive equals the earlier total, less purged rows.

## Items to verify before first use (`UNVERIFIED`)

- `ALTER TABLE ... SWITCH PARTITION <variable> TO ... PARTITION <variable>` accepts variables on every supported version.
- `TRUNCATE TABLE ... WITH (PARTITIONS (n))` exists on every supported version.
- `CREATE OR ALTER` and `DROP ... IF EXISTS` are available on every supported version (the SQL Server 2016 SP1 baseline is assumed, not checked).
- Behavior of `SPLIT RANGE` on a function shared by two tables when the new range is empty in both.
