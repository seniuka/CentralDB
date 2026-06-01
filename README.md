# CentralDB

SQL Server estate management platform — collects, centralizes, and reports inventory, performance, and maintenance data across any number of instances using PowerShell and SSRS.

## What it does

CentralDB runs scheduled PowerShell collection jobs on each SQL Server instance (or fleet-wide via a CMS master job). Each script collects data, writes it to a central SQL Server database (`CentralDB`), and produces a CSV/Excel output. SSRS reports surface the collected data for compliance, performance analysis, and capacity planning.

## Architecture

```
SQL Agent (CmdExec)
    │
    ├─ Collect/Get-CentralInventory.ps1          ──► [Svr].[ServerInfo], [Inst].[*], [Db].[*], [HA].[*]
    ├─ Collect/Get-CentralWaitStats.ps1          ──► [Inst].[WaitStats]
    ├─ Collect/Get-CentralBaselineStats.ps1      ──► [Inst].[InsBaselineStats], [Svr].[SvrBaselineStats]
    ├─ Collect/Invoke-CentralBlitzCollection.ps1 ──► [FRK].[Blitz]
    ├─ Collect/Invoke-CentralBackup.ps1          ──► [Inst].[CommandLog]
    ├─ Collect/Invoke-CentralIndexOptimize.ps1   ──► [Inst].[CommandLog]
    └─ Collect/Invoke-CentralIntegrityCheck.ps1  ──► [Inst].[CommandLog]
                                    │
                              CentralDB (SQL Server)
                                    │
                          SSRS Reports (CentralDB_Reports/)
```

## Requirements

| Component | Minimum version |
|-----------|----------------|
| PowerShell | 5.1 (Windows PowerShell) |
| dbatools | 2.0.0 |
| SQL Server (collection target) | 2012+ |
| SQL Server (CentralDB host) | 2016+ recommended |

## Quick Start

### 1. Create CentralDB

Run `CreateScript-NewCentralDB-Database.sql` against your central SQL Server instance. Then deploy the stored procedures in `SQL/StoredProcedures/` against `CentralDB`:

```sql
:r SQL\StoredProcedures\Svr.usp_GetCollectionTargets.sql
:r SQL\StoredProcedures\Svr.usp_SetCollectionLastRun.sql
:r SQL\StoredProcedures\Inst.usp_GetBaselineStats.sql
```

### 2. Register target instances

```sql
INSERT INTO [Svr].[ServerList] (ServerName, InstanceName, Active, Baseline)
VALUES ('SQL-PROD-01', 'MSSQLSERVER', 1, 1),
       ('SQL-PROD-02', 'INST1',       1, 1);
```

- `Active = 1` — included in Inventory collection
- `Baseline = 1` — included in WaitStats and Baseline collections

### 3. Install dbatools

Run on every server that executes collection jobs:

```powershell
Install-Module dbatools -Scope AllUsers -MinimumVersion 2.0.0
```

### 4. Run a collection

```powershell
# Wait statistics from a single instance
.\Collect\Get-CentralWaitStats.ps1 `
    -SqlInstance 'SQL-PROD-01' `
    -CMSInstanceName 'CMS-01' `
    -OutputPath 'D:\Logs\CentralDB'

# Full inventory from all active CMS-registered instances
.\Collect\Get-CentralInventory.ps1 `
    -CMSInstanceName 'CMS-01' `
    -OutputPath 'D:\Logs\CentralDB' `
    -Sections All
```

---

## Collection Scripts

### Get-CentralInventory.ps1

Collects a full estate inventory across up to five sections. Run weekly or on-demand.

| Section | Data collected | Platform |
|---------|---------------|----------|
| `ServerOS` | OS version, patches, page file, disk space, SQL services | Windows only |
| `Instance` | SQL build/compliance, sp_configure, logins, linked servers, agent jobs | All |
| `Databases` | DB properties, files, backup history, permissions, missing indexes | All |
| `HA` | Availability groups, replicas, AG databases | All |
| `SSRS` | Reporting Services instance info | Windows only |

Use `-Sections Instance,Databases` to collect a subset rather than the full inventory.

### Get-CentralWaitStats.ps1

Collects `sys.dm_os_wait_stats` via `Get-DbaWaitStatistic`. Run every 15-30 minutes for trending.

Optional: `-IncludeSystemWaits` to capture system waits in addition to application waits.

### Get-CentralBaselineStats.ps1

Captures SQL performance counter deltas (batch requests/sec, page life expectancy, lock waits, etc.) and OS PerfMon counters (CPU%, disk latency, available memory). Run every 5-15 minutes.

Three collections per instance:
- **SQL counters** — `[Inst].[usp_GetBaselineStats]` takes two DMV snapshots 1 second apart and returns a pivoted row
- **OS baseline** — PerfMon counters via `Get-Counter` (Windows only)
- **Drive baseline** — per-physical-drive PerfMon counters (Windows only)

### Invoke-CentralBlitzCollection.ps1

Runs `sp_Blitz` (First Responder Kit) and centralizes findings into `[FRK].[Blitz]`. Run daily or weekly.

Set `-DeployFRK Y` to install or update the First Responder Kit on first run.

### Invoke-CentralBackup.ps1

Executes Ola Hallengren `DatabaseBackup` and centralizes `CommandLog` results.

| Parameter | Values | Default |
|-----------|--------|---------|
| `-BackupType` | `FULL`, `DIFF`, `LOG` | `FULL` |
| `-Databases` | `ALL_DATABASES`, `USER_DATABASES`, `SYSTEM_DATABASES`, or comma-separated list | `ALL_DATABASES` |
| `-Compress` | `Y`, `N` | `Y` |
| `-Verify` | `Y`, `N` | `Y` |
| `-CopyOnly` | `Y`, `N` | `N` |
| `-Encrypt` | `Y`, `N` | — |

Set `-DeployOla Y` to install or update Ola's solution on first run.

### Invoke-CentralIndexOptimize.ps1

Executes Ola Hallengren `IndexOptimize` and centralizes `CommandLog` results. Schedule weekly for full rebuilds and nightly for reorganizes.

Key parameters: `-FragmentationLevel1` (default 5%), `-FragmentationLevel2` (default 30%), `-TimeLimit` (seconds) to enforce a maintenance window, `-UpdateStatistics` for combined index+stats maintenance.

### Invoke-CentralIntegrityCheck.ps1

Executes Ola Hallengren `DatabaseIntegrityCheck` and centralizes `CommandLog` results.

Key parameters: `-CheckCommands` (`CHECKDB`, `CHECKFILEGROUP`, `CHECKTABLE`, `CHECKALLOC`, `CHECKCATALOG`), `-PhysicalOnly Y` (default — faster, appropriate for scheduled checks), `-LockTimeout` (default 10800s), `-DatabasesInParallel` for faster fleet-wide runs.

---

## Common Parameters

All scripts share this standard parameter set:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `-SqlInstance` | One or more target instances | — |
| `-SqlCredential` | SQL auth (PSCredential — never plaintext) | Windows auth |
| `-CMSInstanceName` | CentralDB instance for discovery + storage | — |
| `-CMSDatabaseName` | CentralDB database name | `CentralDB` |
| `-CommandTimeout` | Query timeout in seconds | 600 (or 14400 for maintenance ops) |
| `-OutputPath` | Local directory for CSV/export output | Required |
| `-OutputFormat` | `CSV`, `HTML`, `JSON`, `Excel`, `GridView` | `CSV` |
| `-RunLocally` | CMS discovery restricted to the local machine (MSX/TSX jobs) | `$false` |
| `-IntroduceDelay` | Random sleep before execution to stagger fleet writes (`Y`/`N`) | `N` |
| `-DelaySecMin` / `-DelaySecMax` | Stagger delay bounds in seconds | `1` / `300` |
| `-LoadGUID` | Correlation GUID for this run (auto-generated if omitted) | Auto |

---

## SQL Agent Job Configuration

All jobs use the **CmdExec** step type — never the PowerShell step type (CmdExec returns correct exit codes).

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
    -File "\\FILESERVER\DBATools\CentralDB\Collect\<script>.ps1"
    -CMSInstanceName "CMS-01"
    -OutputPath "D:\Logs\CentralDB"
    -RunLocally
    -IntroduceDelay Y
```

For MSX/TSX multi-server jobs, use the SQL Agent `$(ESCAPE_DQUOTE(SRVR))` token instead of `-RunLocally`:

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
    -File "\\FILESERVER\DBATools\CentralDB\Collect\Get-CentralWaitStats.ps1"
    -CMSInstanceName "CMS-01"
    -SqlInstance "$(ESCAPE_DQUOTE(SRVR))"
    -OutputPath "D:\Logs\CentralDB"
```

See [CentralDB-Ops-Runbook.md](CentralDB-Ops-Runbook.md) for full deployment steps and per-script job templates.

---

## SQL stored procedures

| Object | Purpose |
|--------|---------|
| `Svr.usp_GetCollectionTargets` | Returns active instances from `[Svr].[ServerList]` filtered by collection type and optional local-machine filter |
| `Svr.usp_SetCollectionLastRun` | Records last successful run timestamp per instance per collection type |
| `Inst.usp_GetBaselineStats` | Two-snapshot DMV capture returning a single pivoted baseline row |

---

## SSRS Reports

Deploy `CentralDB_Reports/` to SQL Server Reporting Services and point the shared data source (`SQLInventoryReports.rds`) at your CentralDB instance.

| Report | Description |
|--------|-------------|
| Inventory Overview / Detail | Estate snapshot across all registered instances |
| Instance Overview / Detail | Per-instance drill-down |
| Instance Performance Analysis | Wait stats and baseline counter trending |
| Compliance — Backup Age | Instances with backups overdue |
| Compliance — DBCC | Instances where DBCC has not run recently |
| Compliance — SQL Version Out of Date | Build-level compliance |
| Database Growth Report | File size trending |
| AlwaysOn Group / Replica / Database | AG health |
| Instance Job / Failed Job | Agent job status |
| Server Low Disk Space | Disk capacity alerts |

---

## Development Standards

All scripts follow [powershell-dba-engineer-guidelines-v4.1.0.md](powershell-dba-engineer-guidelines-v4.1.0.md).

Key requirements:
- Dual-block pattern (script `param()` + function + auto-invoke) for SQL Agent CmdExec compatibility
- dbatools >= 2.0.0 throughout — no raw `SqlClient`, no `Invoke-Sqlcmd`, no `SqlBulkCopy`
- PS 5.1 compatible — no ternary, no null-coalescing, no `ForEach-Object -Parallel`
- CMS write failures are non-fatal (WARN only) — a CMS outage never aborts collection
- Error accumulation: one instance failure is logged and skipped; remaining instances continue
- All SQL queries use `SqlParameters` — no string concatenation into query strings
