# Deletion proposal: legacy reports and views

> **Name:** deletion-proposal.md · **Purpose:** list of legacy items proposed for removal, awaiting your approval (gate GD) · **Version:** 0.1.0 · **Standard:** DBA Automation Engineering Standard v5.0.0 (UNVERIFIED, text not in repo) · **Author:** Your Friendly Neighbourhood DBA · **Date:** 2026-10-24

**Status: PENDING. Nothing in this list has been deleted, moved or edited.**

Why this list exists: intake answer 6 says the reports are old and archaic and the views are to be cleared out and redesigned. The working rules say Claude does not delete; it proposes. `/cdb-discover` refreshes this file with dependents once it has run.

How to respond: reply with `APPROVE`, `AMEND <id>: <change>` or `REJECT <id>`, per section or per row. After approval, removal is done on a branch with `git rm`, so it stays reversible through git history. Tags: `VERIFIED` (read this session), `UNVERIFIED` (not checked), `DECISION` (needs you).

Scope of the facts below `VERIFIED 2026-10-24`: files tracked on `origin/master` of `seniuka/CentralDB`. The 15 `*Current` views in `SQL/Views/CurrentState.Views.sql` live on the unmerged branch `feature/current-state-views` and are not listed because they are not on this branch. `DECISION`: say whether that branch should be abandoned, which also retires those views.

## A. SSRS reports (folder `CentralDB_Reports/`)

Replacement: the versioned reporting-view contract from unit `rpt-views-v1` (`/cdb-views`). The reporting tool is an open `DECISION` (SQL Server 2025 consolidates Reporting Services under Power BI Report Server, `VERIFIED` on Microsoft's What's New page).

| ID | File | Kind | Reason | Retire when | Status |
|---|---|---|---|---|---|

| A01 | `Compliance Database Owner Not SA.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A02 | `Compliance Instance DBCC Not Run Recently.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A03 | `Compliance Instance Database Backups Not Run Recently.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A04 | `Compliance Instance Failed Job Report.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A05 | `Compliance Instance Job Owner Not SA Report.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A06 | `Compliance Instance SQL Server Version Out of Date.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A07 | `Database Detail.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A08 | `Database Growth Report.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A09 | `Instance AlwaysOn Database List.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A10 | `Instance AlwaysOn Group List.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A11 | `Instance AlwaysOn Replica List.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A12 | `Instance DBCC Results.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A13 | `Instance Database Mirroring.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A14 | `Instance Database Triggers.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A15 | `Instance Detail.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A16 | `Instance Job Failed Report.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A17 | `Instance Job Report.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A18 | `Instance Linked Servers.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A19 | `Instance Login Report.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A20 | `Instance Login Roles.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A21 | `Instance Memory Tables.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A22 | `Instance Miscellaneous Report.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A23 | `Instance Missing Indexes.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A24 | `Instance Overview.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A25 | `Instance Performance Analysis.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A26 | `Instance Report Server Overview.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A27 | `Instance Triggers.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A28 | `Instance User Table Permissions.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A29 | `Instance Wait Statistics.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A30 | `Inventory Detail.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A31 | `Inventory Overview.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A32 | `Inventory_Overview - Backup.rdl` | report (backup copy) | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A33 | `SQL_Report_Replication - Backup.rdl` | report (backup copy) | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A34 | `SQL_Report_Replication.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A35 | `SSAS_Overview - Backup.rdl` | report (backup copy) | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A36 | `SSAS_Overview.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A37 | `SSAS_Report.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A38 | `Server Detail.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A39 | `Server Low Disk Space Report.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A40 | `Servers Disk Growth Report.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A41 | `Servers Overview.rdl` | report | Legacy report, intake answer 6 | Replacement view or report exists and is accepted | PROPOSED |
| A42 | `CentralDB_Reports.rptproj` | project file | Project file for the reports above; CentralDB.sln also references it and needs an edit, not a deletion | With the last report that uses it | PROPOSED |
| A43 | `CentralDB_Reports.rptproj.rsuser` | project file | Per-user project settings; should not be tracked | With the last report that uses it | PROPOSED |
| A44 | `SQLInventoryReports.rds` | project file | Shared data source for the reports above (integrated security, no stored credentials: VERIFIED) | With the last report that uses it | PROPOSED |

## B. Legacy views (defined in `CreateScript-NewCentralDB-Database.sql`)

These are objects in the create script, not separate files, so there is no file to remove. The proposal: do not carry them into the rebuilt schemas, keep the create script as the legacy baseline, and retire the objects in each database with a reviewed script (`-Apply` gated, under `src/`) at the cutover of the domain that replaces them. `DECISION`: confirm this approach.

| ID | View | Reason | Retire when | Status |
|---|---|---|---|---|

| B01 | `dbo.vw_DB_DatabaseBackups` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B02 | `dbo.vwCTEGetAgentJobHistoryRaw` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B03 | `dbo.vwCTEGetAgentJobHistoryStepCount` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B04 | `dbo.vwCTEGetBackup14DayList` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B05 | `dbo.vwCTEGetBackupDatabaseListByDatabase` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B06 | `dbo.vwCTEGetDatabaseFullBackupHealth` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B07 | `dbo.vwCTEGetDatabaseFullBackupHealth14Days` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B08 | `dbo.vwCTEGetDatabaseList` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B09 | `dbo.vwCTEGetDatabaseLogBackupHealth` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B10 | `dbo.vwCTEGetFRKBlitzHeatMap` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B11 | `dbo.vwCTEGetFRKBlitzHeatMapDetails` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B12 | `dbo.vwCTEGetFRKConfigurationFindingsGrade` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B13 | `dbo.vwCTEGetFRKConfigurationFindingsList` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B14 | `dbo.vwCTEGetFRKConfigurationFindingsRaw` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B15 | `dbo.vwCTEGetFRKFindingsGrade` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B16 | `dbo.vwCTEGetFRKFindingsSQLVersionInfo` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B17 | `dbo.vwCTEGetFRKPerformanceandReliabilityFindingsGrade` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B18 | `dbo.vwCTEGetFRKPerformanceandReliabilityFindingsList` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B19 | `dbo.vwCTEGetFRKPerformanceandReliabilityFindingsRaw` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B20 | `dbo.vwCTEGetFRKSecurityFindingsGrade` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B21 | `dbo.vwCTEGetFRKSecurityFindingsList` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B22 | `dbo.vwCTEGetFRKVulnerabilityList` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B23 | `dbo.vwCTEGetFRKVulnerabilityRaw` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B24 | `dbo.vwFRKBlitzLatestCollectionByServerName` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B25 | `dbo.vwGETBlitzCurrent` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B26 | `dbo.vwGETDatabaseInfoCurrent` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B27 | `dbo.vwGETDatabaseReportingOverview` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B28 | `dbo.vwGetFRKDataCenterSQLServerCounts` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B29 | `dbo.vwGetFRKDataCenterSQLServerCountsHistory` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B30 | `dbo.vwGETFRKSecurityFindingsRaw` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B31 | `dbo.vwGetFRKTotalFindingsGradeList` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B32 | `dbo.vwGetFRKVulnerabilityCurrent` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B33 | `dbo.vwGetFRKVulnerabilityHistory` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B34 | `dbo.vwGETInstanceInfoCurrent` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B35 | `dbo.vwGetInstCommandLogDetails` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B36 | `dbo.vwGETOSInfoCurrent` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B37 | `dbo.vwGETServerInfoCurrent` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B38 | `dbo.vwInstanceLoginAndRoleList` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B39 | `dbo.vwSQLServerCountBackupsPerDayByHour` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B40 | `dbo.vwSQLServerUpdates` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B41 | `dbo.vwSQLVersionReview` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |
| B42 | `dbo.vwSVRServerListActiveOnly` | Redesign, intake answer 6 | Its domain is cut over to the versioned `rpt` views | PROPOSED |

## C. Not proposed, listed for context

You asked only about reports and views. These legacy items are untouched and are not proposed for removal here. `/cdb-discover` will assess them and add proposals if they turn out to be duplicates.

- `Original/` (4 older collector scripts), `CentralDB/` (older collector scripts and an `OlaHallengren/` copy), root-level `OlaHallengren/`, and `Old_CentralDB_DDL`.
- `Collect/` and `SQL/StoredProcedures/` (the v4 collectors and procedures), until the rebuilt equivalents are cut over.
- Legacy docs (`docs/SETUP.md`, `docs/SQL-AGENT-JOBS.md`, `docs/TESTING.md`, `docs/SCRIPT-REFERENCE.md`, `CentralDB-Ops-Runbook.md`, `powershell-dba-engineer-guidelines-v4.1.0.md`), which describe the v4 design and stay as reference.

## D. Totals

See the row counts in sections A and B. Section A lists every tracked file in `CentralDB_Reports/`; section B lists every `CREATE VIEW` in the create script.

