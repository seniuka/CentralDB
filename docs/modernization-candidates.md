# CentralDB modernization candidates

> **Name:** modernization-candidates.md · **Purpose:** scored list of modern features to consider for the CentralDB rebuild (proposals only, nothing implemented) · **Version:** 0.1.0 · **Standard:** DBA Automation Engineering Standard v5.0.0 (UNVERIFIED, text not in repo) · **Author:** Your Friendly Neighbourhood DBA · **Date:** 2026-10-24

Tags: `VERIFIED <date>` (checked against the named source on that date), `UNVERIFIED` (not checked), `DECISION` (needs your call). `/cdb-modernize-audit` keeps this file current.

## 1. How to read this

**Tiers** (ADR-0001). Tier 2, the reporting and analytics server, is a SQL Server 2025 AG pair, so 2025 features are eligible there. Tier 1 management servers are standalone and their SQL Server version is not stated, and Tier 0 targets span every supported version. Code and schema on Tier 1 and Tier 0 use only features present on every supported version; anything newer is version-gated and tagged.

**Supported SQL Server versions** `VERIFIED 2026-10-24` against Microsoft Lifecycle pages: 2016 extended support ended 2026-07-15 (Extended Security Updates year 1 runs to 2027-07-13); 2017 ends 2027-10-13; 2019 ends 2030-01-09; 2022 ends 2033-01-12. SQL Server 2025 dates were not checked `UNVERIFIED`.

**Scoring.** Benefit (1 to 5) plus Fit to this estate (1 to 5) minus Risk (1 to 5, higher is worse) gives a score from -3 to 9. Effort is S (days), M (weeks), L (months), a judgment, not measured.

**Recommendation rule.** `adopt` needs a score of 6 or more and no unresolved blocker. `pilot` is a score of 3 to 5, or a high score with an open blocker, tried in one unit on a non-production pair. `defer` means the requirement is not confirmed. `reject` means it conflicts with a constraint (air-gapped, team scope, security baseline). A feature that is in preview is never `adopt`.

## 2. Premises I could not confirm in this repo

The brief refers to objects that are not in `seniuka/CentralDB` as cloned on 2026-10-24. If an internal copy exists, point me at it and I will re-run discovery.

| Premise | What I found | Tag |
|---|---|---|
| Sliding-window partitioning "already used for `Inst.CommandLog`" | `Inst.CommandLog` is a plain table: primary key `(CommandLogID, CommandType)`, `StartTime datetime`, filegroup `[Inst]`, no partition function | `VERIFIED 2026-10-24` (read `CreateScript-NewCentralDB-Database.sql`) |
| `cache.JsonStore`, `cache.QueryRegistry` | zero matches in the repo | `VERIFIED 2026-10-24` (repo search) |
| `vwGETAGReplicasInfoCurrent` | zero matches (case-insensitive). `vwGetInstanceInfoCurrent` exists as `dbo.vwGETInstanceInfoCurrent` on `master`, and as `Inst.vwGetInstanceInfoCurrent` on the unmerged `feature/current-state-views` branch | `VERIFIED 2026-10-24` |
| Schemas `AG`, `Backup`, `Security`, `Audit`, `cache` | not in the create script (schemas present: `AS`, `DB`, `FRK`, `IS`, `Inst`, `RS`, `Svr`, `Tbl`, plus `dbo`) | `VERIFIED 2026-10-24` |

## 3. Database engine candidates

| ID | Candidate | Replaces | Benefit | Risk | Effort | Prerequisites | Score | Recommendation |
|---|---|---|---|---|---|---|---|---|
| E1 | Partitioning and sliding window, extended to high-volume tables | Unbounded log, history and trend tables; ad hoc purge jobs | Bounded table size, metadata-only retention, short locks | Primary key changes (partition column must be in unique keys); consumers that look up by id alone | M | Consumer list in the plan card; filegroup layout `DECISION`; `cdb-partition-pattern` skill | 4+5-2 = 7 | adopt (M2 pilot on `inst-commandlog`) |
| E2 | System-versioned temporal tables for audit and change control, with retention | Hand-rolled `DateModified` columns, history tables and triggers | Point-in-time queries and automatic history | History growth; temporal history is not tamper-evident (see E8); each history table needs its own index and, with RLS, its own policy | M | Retention requirement per domain; history-table index design | 4+4-3 = 5 | pilot on Tier 2 audit domain |
| E3 | Native JSON and the JSON query cache design | `nvarchar(max)` JSON text, parse-on-read | Native binary storage, JSON indexes | Tier 2 only; the `cache` design is not in this repo; `json` columns are excluded from the optimized-locking skip-index optimization | M | The `cache` design and its schema ADR; Tier 2 compatibility level; consumer review | 3+3-3 = 3 | pilot (Tier 2 only, after the design exists); defer on Tier 1 |
| E4 | Dynamic Data Masking and row-level security for report consumers, scoped `UNMASK` | Folder-level report security, broad `db_datareader` grants | Scope data by role, zone and classification at the database | Masking is not a security boundary against ad hoc queries; RLS has side-channel risks; both need testing against each view | M | Audience matrix per view; RLS predicate design (inline, schema-bound); audit enabled | 4+4-3 = 5 | pilot RLS on Tier 2 reporting views; adopt DDM as convenience only, never as the only control |
| E5 | Columnstore for history and trend tables | Rowstore history tables with large scans | Compression, fast aggregates | If Standard edition: batch-mode DOP limited to 2 and a 32 GB segment cache; optimized locking does not use lock-after-qualification on tables with columnstore | S | Edition `DECISION`; table list from discovery | 4+4-2 = 6 | adopt for history and trend on Tier 2 |
| E6 | Query Store and Intelligent Query Processing on the central database | Ad hoc plan-cache analysis | Regression visibility, plan forcing, automatic improvements | Several IQP features are Enterprise only; Query Store on secondaries is Enterprise only | S | Edition `DECISION`; capture mode and size settings | 3+4-1 = 6 | adopt Query Store; pilot Enterprise-only IQP features |
| E7 | Contained availability group and AG design for the central databases | Manual copying of logins, jobs and settings between replicas | Logins, permissions and Agent jobs travel with the AG | Enterprise only; jobs run on the primary only; no SSIS or maintenance plans; replication not supported; TDE needs the master key in the contained master; connection must use the listener | L | Edition `DECISION`; listener and routing design; backup and restore runbook | 4+4-3 = 5 | pilot (adopt if the pair is Enterprise) |
| E8 | Ledger tables for tamper-evident audit data | Trust-based audit tables | Cryptographic tamper evidence | Digests must go to immutable external storage; air-gapped estate means on-premises WORM storage, not Azure; updatable ledger tables are system-versioned tables | L | Requirement `DECISION`: is tamper evidence required; WORM target; digest process | 2+2-3 = 1 | defer until the requirement is confirmed |
| E9 | Optimized locking and other version-only features | Lock escalation and blocking workarounds | Less lock memory, no escalation, fewer deadlocks on Tier 2 write-heavy tables | 2025 only; per database; needs accelerated database recovery; the lock-after-qualification part needs RCSI and is skipped for `MERGE`, columnstore tables and statements with variable assignment or `OUTPUT` | S | RCSI and ADR on the reporting database; verify on the non-production pair | 3+3-3 = 3 | pilot on Tier 2 staging and merge tables |

### Version-only features (flag by version)

| Feature | Minimum version | Edition | Status | Relevance | Recommendation |
|---|---|---|---|---|---|
| Native `json` type and JSON indexes | 2025 | all | generally available | E3 | pilot (Tier 2) |
| Optimized locking | 2025 | Enterprise and Standard | generally available, off by default | E9 | pilot (Tier 2) |
| Resource governor | 2025 for Standard (Enterprise earlier) | Standard from 2025 | generally available | Protects the merge window on a Standard pair | pilot |
| Full and differential backup on secondary replicas | 2025 | AG pair | generally available | Offloads backups from the primary | pilot |
| ZSTD backup compression | 2025 | not stated | generally available | Backup size and speed | defer to the `backup` unit |
| Regular expression functions | 2025 | all | listed without a preview label | Validation of inventory text | defer, no current need |
| Vector data type | 2025 | all | listed without a preview label; the vector index is preview | None for inventory | reject (out of team scope) |
| Fuzzy string matching, change event streaming | 2025 | all | preview, need the `PREVIEW_FEATURES` setting | None | reject while in preview |
| External REST endpoint invocation, Fabric mirroring | 2025 | all | listed in What's New | Conflicts with the air-gapped deployment | reject |
| Contained AG | 2022 | Enterprise | generally available | E7 | pilot |
| Granular `UNMASK` (database, schema, table, column) | 2022 | all | generally available | E4 | pilot |
| Ledger | 2022 | all (2025 table) | generally available | E8 | defer |

Evidence for E1 to E9 and the table above is in section 7.

## 4. dbatools and automation candidates

| ID | Candidate | Replaces | Benefit | Risk | Effort | Prerequisites | Score | Recommendation |
|---|---|---|---|---|---|---|---|---|
| A1 | Collectors built on `Connect-DbaInstance`, `Invoke-DbaQuery`, `Write-DbaDbTableData` | Hand-rolled loops and helper scripts (`Out-DataTable.ps1`, `Write-DataTable.ps1` in `CentralDB/`) | Less code, bulk write-back, one pattern | Behavior with arrays of custom objects not yet tested on a non-production target | M | `cdb-collector-pattern` skill; `/cdb-test` run | 5+5-2 = 8 | adopt |
| A2 | CentralDB inventory as the single source of target lists (CMS as an optional feeder) | Duplicated server lists in CMS, `Svr.ServerList` and job definitions | One list, no drift | Inventory must be trusted and complete before collectors depend on it | M | `svr-core` unit; ownership of the list | 4+5-2 = 7 | adopt |
| A3 | Parallel collection with throttling, a single result contract and per-instance error capture into a run-log table | Sequential loops; failures that stop a run | Faster runs; one failed instance does not stop the rest | Parallel path is PowerShell 7 only; 5.1 runs sequentially | M | `run-log` unit; the staging and run-log schema ADR | 4+5-2 = 7 | adopt |
| A4 | Idempotent, `-Apply`-gated setup of the Agent jobs that run the collectors | Hand-run `sp_add_job` scripts in `docs/SQL-AGENT-JOBS.md` | Repeatable, reviewable job setup | Token syntax in the job step needs checking against current docs | S | Job installer from the skill; `/cdb-test` | 4+5-1 = 8 | adopt |
| A5 | Pester tests and a repeatable synthetic dataset | Two manual test scripts in `Tests/` | Regression safety; no real inventory in fixtures | Only Pester 3.4.0 is installed on the author's workstation; Pester 5 must come from the UNC PSRepository | M | Pester 5 `DECISION`; synthetic data generator | 4+5-2 = 7 | adopt after Pester 5 is supplied |
| A6 | Azure Arc SQL extension state and gMSA state as inventoried attributes | No record of either today | Shows readiness for Entra authentication and managed-identity backups (both need Arc) | Method to collect the state is not chosen | S | Attribute design in `inst-core`; collection method | 3+3-1 = 5 | pilot |
| A7 | Reporting layer: versioned views contract for SSRS and the web reporting app | The 42 legacy `dbo` views and 41 `.rdl` reports (deletion proposed, not done) | Stable, documented consumer contract | Report tooling choice is open | M | `/cdb-views`; consumer list; reporting-tool `DECISION` | 5+5-2 = 8 | adopt |

## 5. Claude Code workflow candidates

| ID | Candidate | Replaces | Benefit | Risk | Effort | Prerequisites | Score | Recommendation |
|---|---|---|---|---|---|---|---|---|
| C1 | Hooks that run the deny-list scan and a PowerShell parse check before file writes or commits | Remembering to run `/cdb-quality` | The gate runs without being asked | A hook that fails open on Windows weakens the gate; needs a committed scan script | M | Claude Code 2.1.310 or later on Windows; a `tools/` scan script (the one used in this pass lives in a scratch directory and is not committed) | 4+4-3 = 5 | pilot |
| C2 | Subagents for read-only review | Reviewing in the main session | Smaller main context, enforced read-only | None significant | S | Done in this pass: three agents with `tools: Read, Grep, Glob` | 4+5-1 = 8 | adopt (done) |
| C3 | Skills for the collector, partition and merge patterns | Long instructions repeated in commands | Short commands, reusable patterns | Templates are not yet run on an instance | S | Done in this pass: three skills | 4+5-1 = 8 | adopt (done) |
| C4 | `/cdb-status` that works from the repo alone | Rediscovering state in each session | Any session can resume | Cannot see pull request state without GitHub access | S | Done in this pass | 4+5-1 = 8 | adopt (done) |

## 6. Platform candidate

| ID | Candidate | Replaces | Benefit | Risk | Effort | Prerequisites | Score | Recommendation |
|---|---|---|---|---|---|---|---|---|
| P1 | PostgreSQL and Oracle collector adapters under the same worker contract | Nothing (new capability) | One inventory across platforms | dbatools covers SQL Server only; a driver is a new dependency and, if it needs stored credentials, a deny-list R3 exception | L | Driver `DECISION`; platform-neutral inventory design in `inst-core`; UNC PSRepository packaging | 4+3-4 = 3 | pilot after the driver decision (M3) |

## 7. Evidence and tags

Sources: Microsoft Learn pages "What's new in SQL Server 2025", "Editions and supported features of SQL Server 2025", the lifecycle pages for SQL Server 2016, 2017, 2019 and 2022, and the topic pages named below, all read on 2026-10-24. dbatools claims are against the installed module, version 2.8.2.

**E1 partitioning.** Table and index partitioning is in Enterprise, Standard and Express on SQL Server 2025 `VERIFIED 2026-10-24` (editions page). Availability on older versions `UNVERIFIED`. Template runtime behavior `UNVERIFIED` (parse-checked only).

**E2 temporal.** Temporal tables apply to SQL Server 2016 and later, and the history table pairs with a current table `VERIFIED 2026-10-24` (temporal overview). Retention period behavior, history-table limits and the version that introduced retention `UNVERIFIED`. Temporal tables are in every 2025 edition `VERIFIED`.

**E3 JSON.** JSON functions need database compatibility level 130 or higher and apply to SQL Server 2016 and later; the `json` type and JSON indexes are generally available in SQL Server 2025 `VERIFIED 2026-10-24` (JSON overview). Skip-index-locks is not used when the modified row has LOB columns such as `json` `VERIFIED` (optimized locking page).

**E4 DDM and RLS.** DDM is SQL Server 2016 and later and is not designed to stop users who can run ad hoc queries from inferring values; granular `UNMASK` arrived in SQL Server 2022 `VERIFIED 2026-10-24` (DDM page). RLS is SQL Server 2016 and later; it has side-channel risks, indexed views cannot be built on tables with a security policy, and a temporal history table needs its own predicate `VERIFIED 2026-10-24` (RLS page).

**E5 columnstore.** Columnstore is in every 2025 edition; Standard limits batch-mode DOP to 2 and the columnstore segment cache to 32 GB; online nonclustered columnstore rebuild is Enterprise only `VERIFIED 2026-10-24` (editions page). Ordered nonclustered columnstore indexes are new in 2025 `VERIFIED` (What's New).

**E6 Query Store and IQP.** Query Store, Query Store hints and "on by default for new databases" are in all 2025 editions; Query Store on secondary replicas is Enterprise only; CE feedback, DOP feedback and memory grant feedback are Enterprise only; parameter sensitive plan optimization, optional parameter plan optimization and optimized plan forcing are in all editions `VERIFIED 2026-10-24` (editions page). Query Store for readable secondaries and DOP feedback are on by default in 2025 `VERIFIED` (What's New).

**E7 contained AG.** Introduced in SQL Server 2022; each contained AG has its own `master` and `msdb`; jobs run on the primary only; you must connect through the contained AG listener; SSIS packages and maintenance plans are not supported; replication is not supported; TDE needs the database master key in the contained master; distributed AG support for contained AGs is new in 2025 `VERIFIED 2026-10-24` (contained AG overview). Contained and distributed AGs are Enterprise only; Standard has Basic AGs: two replicas, one database `VERIFIED` (editions page). Edition of the reporting pair: `DECISION`.

**E8 ledger.** Ledger applies to SQL Server 2022 and later; updatable ledger tables are system-versioned with a history table; append-only tables block updates and deletes; database digests are meant to go to immutable storage, Azure Confidential Ledger or on-premises WORM storage; verification compares digests with recomputed hashes `VERIFIED 2026-10-24` (ledger overview). Ledger is in every 2025 edition `VERIFIED` (editions page).

**E9 optimized locking.** SQL Server 2025 only, off by default, enabled per database with `ALTER DATABASE ... SET OPTIMIZED_LOCKING = ON`, needs accelerated database recovery, lock-after-qualification needs RCSI; not used with conflicting lock hints, non-`READ COMMITTED` isolation, columnstore tables, variable assignment, `OUTPUT` to a table variable or result set, or `MERGE`; not used on read-only secondaries or for tempdb objects `VERIFIED 2026-10-24` (optimized locking page). Optimized locking is in Enterprise and Standard `VERIFIED` (editions page).

**Version-only table.** Resource governor in Standard from 2025, full and differential backups on secondary replicas, ZSTD, regular expressions, vector type and preview index, fuzzy matching and change event streaming (preview), external REST invocation and Fabric mirroring `VERIFIED 2026-10-24` (What's New). Reporting Services consolidated under Power BI Report Server in 2025 `VERIFIED` (What's New). Whether the existing `.rdl` files load in Power BI Report Server `UNVERIFIED`.

**A1 to A5.** Cmdlets and parameters exist in dbatools 2.8.2 `VERIFIED 2026-10-24` with `Get-Command`: `Connect-DbaInstance` (`-ClientName`, `-ConnectTimeout`, `-TrustServerCertificate`, `-EncryptConnection`), `Invoke-DbaQuery` (`-As`, `-SqlParameter`, `-EnableException`), `Write-DbaDbTableData` (`-Schema`, `-Table`, `-InputObject`, `-BatchSize`), `Get-DbaRegServer`, `New-DbaAgentJob`, `New-DbaAgentJobStep`, `New-DbaAgentSchedule`, `Get-DbaAgentJob`, `Remove-DbaAgentJob`, `Disconnect-DbaInstance`. `SqlInstance` parameters are `DbaInstanceParameter`. dbatools 2.8.2 defaults: encrypt on, trust certificate off `VERIFIED` (`Get-DbatoolsConfig sql.connection.*`). `ForEach-Object -Parallel` rejects a script block passed with `$using:`, `VERIFIED` on PowerShell 7.6.8. Script-level `[DbaInstanceParameter]` fails under `powershell.exe -File` ("Unable to find type"), `VERIFIED` on 5.1.26100. Pester: only 3.4.0 installed `VERIFIED`; PSScriptAnalyzer is not installed `VERIFIED`.

**A6 Arc.** Microsoft Entra authentication, managed identity and backup to URL with managed identity need SQL Server enabled by Azure Arc `VERIFIED 2026-10-24` (What's New, editions page). How to inventory Arc and gMSA state `UNVERIFIED`.

**C1 to C4.** Hook schema, exit code 2 blocking, matcher syntax, the absence of a commit event (match `Bash` with `if: "Bash(git commit *)"`), and Windows hook fixes in Claude Code 2.1.309 and 2.1.310 `VERIFIED 2026-10-24` against the Claude Code docs through the claude-code-guide agent. Read-only agents are built with a `tools` allowlist `VERIFIED`. Commands and skills are merged: a file in `.claude/commands/` and a skill with the same name both create the command `VERIFIED`.

**P1 drivers.** The Oracle Managed Data Access package states .NET Framework 4.6.2 and later in its 19.23.0 release notes, per a search result summary: `UNVERIFIED` against the primary page. Whether a current Npgsql build loads in Windows PowerShell 5.1 `UNVERIFIED`; test before relying on it.

## 8. Open DECISIONs from this list

1. Edition of the reporting AG pair (Enterprise or Standard). It decides E6, E7, E9 and parts of E5.
2. Whether tamper evidence is a requirement (E8).
3. The `cache` design (E3) and whether an internal copy of the project has it.
4. Pester 5 source on the UNC PSRepository (A5).
5. PostgreSQL and Oracle driver choice and its authentication model (P1).
6. Reporting tool for the new views contract (A7).
7. Whether Protected A/B and Protected C data share the reporting pair.

## 9. Audit log

| Date | By | Change |
|---|---|---|
| 2026-10-24 | scaffold pass | First version. All claims tagged against sources read that day. |
