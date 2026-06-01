# CentralDB Operations Runbook

Step-by-step guide for deploying, configuring, scheduling, and troubleshooting the CentralDB v4 collection scripts.

## Contents

1. [Prerequisites](#1-prerequisites)
2. [First-Time Deployment](#2-first-time-deployment)
3. [SQL Agent Job Configuration](#3-sql-agent-job-configuration)
4. [Recommended Schedule](#4-recommended-schedule)
5. [Adding a New Instance](#5-adding-a-new-instance)
6. [Removing an Instance](#6-removing-an-instance)
7. [Upgrading dbatools](#7-upgrading-dbatools)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Prerequisites

### CentralDB server

| Requirement | Detail |
|-------------|--------|
| SQL Server | 2016+ recommended, 2012+ minimum |
| Database | `CentralDB` created from `CreateScript-NewCentralDB-Database.sql` |
| Service account | Domain account used as SQL Agent proxy (e.g. `DOMAIN\svc_dba_automation`) |

### Each collection server (SQL Agent host)

| Requirement | Detail |
|-------------|--------|
| PowerShell | 5.1 (Windows PowerShell — not PowerShell Core / `pwsh`) |
| dbatools | >= 2.0.0, installed with `-Scope AllUsers` |
| Script share | UNC path readable by the SQL Agent proxy account |
| Output path | Local directory writable by the SQL Agent proxy account |
| Network | Proxy account must be able to connect to CentralDB and all target instances |

Install dbatools on every server that runs collection jobs:

```powershell
Install-Module dbatools -Scope AllUsers -MinimumVersion 2.0.0
```

Verify the installed version:

```powershell
Get-Module dbatools -ListAvailable | Select-Object Name, Version
```

---

## 2. First-Time Deployment

### Step 1 — Create the CentralDB database

In SSMS with SQLCMD mode enabled, run against your central SQL Server:

```sql
:r CreateScript-NewCentralDB-Database.sql
```

### Step 2 — Deploy stored procedures

Run the following against the `CentralDB` database. These procedures are used by all collection scripts for instance discovery, run tracking, and baseline data collection:

```sql
-- Instance discovery (reads [Svr].[ServerList])
:r SQL\StoredProcedures\Svr.usp_GetCollectionTargets.sql

-- Run timestamp recording (updates [Svr].[ServerList])
:r SQL\StoredProcedures\Svr.usp_SetCollectionLastRun.sql

-- SQL performance counter baseline (two-snapshot DMV PIVOT)
:r SQL\StoredProcedures\Inst.usp_GetBaselineStats.sql
```

### Step 3 — Verify ServerList schema

The v4 scripts write to columns that may not exist in databases upgraded from earlier versions. Run against `CentralDB` and add any missing columns:

```sql
-- Check whether the tracking columns exist
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Svr'
  AND TABLE_NAME   = 'ServerList'
  AND COLUMN_NAME IN ('WaitStatLastExecDate','BaselineLastExecDate',
                      'InventoryLastExecDate','LastLoadGUID','LastUpdated');

-- Add missing columns if needed
ALTER TABLE [Svr].[ServerList]
    ADD WaitStatLastExecDate  DATETIME2 NULL,
        BaselineLastExecDate  DATETIME2 NULL,
        InventoryLastExecDate DATETIME2 NULL,
        LastLoadGUID          NVARCHAR(36)  NULL,
        LastUpdated           DATETIME2 NULL;
```

### Step 4 — Register target instances

```sql
INSERT INTO [Svr].[ServerList] (ServerName, InstanceName, Active, Baseline)
VALUES
    ('SQL-PROD-01', 'MSSQLSERVER', 1, 1),
    ('SQL-PROD-02', 'MSSQLSERVER', 1, 1),
    ('SQL-PROD-03', 'INST1',       1, 1);
```

| Column | Effect |
|--------|--------|
| `Active = 1` | Included in Inventory collection |
| `Baseline = 1` | Included in WaitStats and BaselineStats collections |

### Step 5 — Copy scripts to a network share

Place the `Collect\` folder on a UNC share accessible by all SQL Agent proxy accounts:

```
\\FILESERVER\DBATools\CentralDB\Collect\
```

Verify the proxy account can read the scripts:

```powershell
# Run as the proxy account (or use PsExec / runas)
Get-ChildItem \\FILESERVER\DBATools\CentralDB\Collect\
```

### Step 6 — Create the SQL Agent proxy

1. In SSMS, expand **Security > Credentials**. Create a new credential for the domain service account (`DOMAIN\svc_dba_automation`).
2. Expand **SQL Server Agent > Proxies > CmdExec**. Create proxy `DBA_Automation_Proxy` using that credential.
3. Grant the proxy to the operators/logins that own the collection jobs.

### Step 7 — Verify end-to-end connectivity

Run a test collection manually before creating SQL Agent jobs:

```powershell
.\Collect\Get-CentralWaitStats.ps1 `
    -SqlInstance 'SQL-PROD-01' `
    -CMSInstanceName 'CMS-01' `
    -CMSDatabaseName 'CentralDB' `
    -OutputPath 'C:\Temp\CentralDB' `
    -Verbose
```

Confirm data arrived:

```sql
SELECT TOP 10 * FROM [Inst].[WaitStats]
WHERE ServerName = 'SQL-PROD-01'
ORDER BY CollectedAt DESC;
```

---

## 3. SQL Agent Job Configuration

### Step type

Always use **CmdExec** — never the "PowerShell" step type. PowerShell steps do not return correct exit codes to SQL Agent, so failed runs may be reported as success.

### Run As

Set every job step to run as `DBA_Automation_Proxy`.

### Command template

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "\\FILESERVER\DBATools\CentralDB\Collect\<script>.ps1" [parameters]
```

- `-NoProfile` — faster startup, no profile interference
- `-NonInteractive` — prevents hangs on prompts
- `-ExecutionPolicy Bypass` — avoids policy blocks without changing system policy
- Do not use `Set-ExecutionPolicy` inside scripts

### Per-script commands

#### Get-CentralInventory

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
  -File "\\FILESERVER\DBATools\CentralDB\Collect\Get-CentralInventory.ps1"
  -CMSInstanceName "CMS-01"
  -CMSDatabaseName "CentralDB"
  -OutputPath "D:\Logs\CentralDB"
  -Sections All
  -RunLocally
  -IntroduceDelay Y
```

To collect only specific sections (faster, useful for incremental refreshes):
```
  -Sections Instance,Databases
```

#### Get-CentralWaitStats

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
  -File "\\FILESERVER\DBATools\CentralDB\Collect\Get-CentralWaitStats.ps1"
  -CMSInstanceName "CMS-01"
  -CMSDatabaseName "CentralDB"
  -OutputPath "D:\Logs\CentralDB"
  -RunLocally
  -IntroduceDelay Y
```

#### Get-CentralBaselineStats

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
  -File "\\FILESERVER\DBATools\CentralDB\Collect\Get-CentralBaselineStats.ps1"
  -CMSInstanceName "CMS-01"
  -CMSDatabaseName "CentralDB"
  -OutputPath "D:\Logs\CentralDB"
  -RunLocally
  -IntroduceDelay Y
```

#### Invoke-CentralBlitzCollection

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
  -File "\\FILESERVER\DBATools\CentralDB\Collect\Invoke-CentralBlitzCollection.ps1"
  -CMSInstanceName "CMS-01"
  -CMSDatabaseName "CentralDB"
  -OutputPath "D:\Logs\CentralDB"
  -RunLocally
  -IntroduceDelay Y
  -DeployFRK N
```

To install/update First Responder Kit on first run: change `-DeployFRK N` to `-DeployFRK Y`, run once, then revert to `N`.

#### Invoke-CentralBackup — FULL

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
  -File "\\FILESERVER\DBATools\CentralDB\Collect\Invoke-CentralBackup.ps1"
  -CMSInstanceName "CMS-01"
  -CMSDatabaseName "CentralDB"
  -OutputPath "D:\Logs\CentralDB"
  -RunLocally
  -IntroduceDelay Y
  -BackupType FULL
  -Databases ALL_DATABASES
  -Directory "\\BACKUPSERVER\Backups"
  -Compress Y
  -Verify Y
  -CleanupTime 72
  -DeployOla N
```

#### Invoke-CentralBackup — DIFF

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
  -File "\\FILESERVER\DBATools\CentralDB\Collect\Invoke-CentralBackup.ps1"
  -CMSInstanceName "CMS-01"
  -CMSDatabaseName "CentralDB"
  -OutputPath "D:\Logs\CentralDB"
  -RunLocally
  -IntroduceDelay Y
  -BackupType DIFF
  -Databases USER_DATABASES
  -Directory "\\BACKUPSERVER\Backups"
  -Compress Y
  -CleanupTime 48
  -DeployOla N
```

#### Invoke-CentralBackup — LOG

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
  -File "\\FILESERVER\DBATools\CentralDB\Collect\Invoke-CentralBackup.ps1"
  -CMSInstanceName "CMS-01"
  -CMSDatabaseName "CentralDB"
  -OutputPath "D:\Logs\CentralDB"
  -RunLocally
  -IntroduceDelay Y
  -BackupType LOG
  -Databases ALL_DATABASES
  -Directory "\\BACKUPSERVER\Backups"
  -Compress Y
  -CleanupTime 48
  -DeployOla N
```

#### Invoke-CentralIndexOptimize

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
  -File "\\FILESERVER\DBATools\CentralDB\Collect\Invoke-CentralIndexOptimize.ps1"
  -CMSInstanceName "CMS-01"
  -CMSDatabaseName "CentralDB"
  -OutputPath "D:\Logs\CentralDB"
  -RunLocally
  -IntroduceDelay Y
  -Databases USER_DATABASES
  -FragmentationLevel1 5
  -FragmentationLevel2 30
  -SortInTempdb Y
  -TimeLimit 14400
  -DeployOla N
```

Remove `-TimeLimit` if you want unconstrained maintenance windows.

#### Invoke-CentralIntegrityCheck

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
  -File "\\FILESERVER\DBATools\CentralDB\Collect\Invoke-CentralIntegrityCheck.ps1"
  -CMSInstanceName "CMS-01"
  -CMSDatabaseName "CentralDB"
  -OutputPath "D:\Logs\CentralDB"
  -RunLocally
  -IntroduceDelay Y
  -Databases ALL_DATABASES
  -CheckCommands CHECKDB
  -PhysicalOnly Y
  -LockTimeout 10800
  -TimeLimit 14400
  -DeployOla N
```

### MSX/TSX variant (multi-server jobs)

Replace `-RunLocally` with `-SqlInstance "$(ESCAPE_DQUOTE(SRVR))"` when enrolling instances as MSX targets:

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
  -File "\\FILESERVER\DBATools\CentralDB\Collect\Get-CentralWaitStats.ps1"
  -CMSInstanceName "CMS-01"
  -CMSDatabaseName "CentralDB"
  -SqlInstance "$(ESCAPE_DQUOTE(SRVR))"
  -OutputPath "D:\Logs\CentralDB"
  -IntroduceDelay Y
```

---

## 4. Recommended Schedule

| Job | Frequency | Notes |
|-----|-----------|-------|
| Get-CentralInventory | Weekly, Sunday 02:00 | Full inventory is the heaviest job — run off-peak |
| Get-CentralWaitStats | Every 30 minutes | Reduce to 15 min on high-churn instances |
| Get-CentralBaselineStats | Every 15 minutes | 1-second DMV snapshot + PerfMon |
| Invoke-CentralBlitzCollection | Daily, 06:00 | Before business hours — findings are point-in-time |
| Invoke-CentralBackup (FULL) | Weekly, Saturday 22:00 | Adjust per backup SLA |
| Invoke-CentralBackup (DIFF) | Weekdays, 22:00 | Adjust per backup SLA |
| Invoke-CentralBackup (LOG) | Every 15-30 minutes | FULL recovery databases only |
| Invoke-CentralIndexOptimize | Weekly, Saturday 01:00 | Use `-TimeLimit` to enforce maintenance window |
| Invoke-CentralIntegrityCheck | Weekly, Sunday 00:00 | Use `-TimeLimit` to enforce maintenance window |

**IntroduceDelay guidance**: On fleets larger than ~20 instances, use `-IntroduceDelay Y` on all jobs. The default range is 1-300 seconds; adjust `-DelaySecMax` to `$fleet_size * 10` to spread CentralDB writes across a reasonable window.

---

## 5. Adding a New Instance

1. **Register the instance** in CentralDB:

```sql
INSERT INTO [Svr].[ServerList] (ServerName, InstanceName, Active, Baseline)
VALUES ('NEW-SERVER', 'MSSQLSERVER', 1, 1);
```

2. **Verify connectivity** from the CMS server (using the proxy credential):

```powershell
$cred = Get-Credential  # or use the proxy credential
Connect-DbaInstance -SqlInstance 'NEW-SERVER' -SqlCredential $cred
```

3. **If using MSX/TSX jobs**: enlist the new server in each multi-server job:

```sql
EXEC msdb.dbo.sp_add_jobserver
    @job_name   = 'CentralDB - WaitStats',
    @server_name = 'NEW-SERVER';
```

4. **If using CMS-driven (non-MSX) jobs**: no SQL Agent changes needed. The scripts read `[Svr].[ServerList]` at each run.

5. **Validate the first collection**:

```sql
-- Wait stats
SELECT TOP 10 * FROM [Inst].[WaitStats]
WHERE ServerName = 'NEW-SERVER'
ORDER BY CollectedAt DESC;

-- Inventory
SELECT TOP 1 * FROM [Svr].[ServerInfo]
WHERE ServerName = 'NEW-SERVER'
ORDER BY CollectedAt DESC;
```

---

## 6. Removing an Instance

Set `Active = 0` — do **not** delete the row, as historical data in all collection tables references it.

```sql
UPDATE [Svr].[ServerList]
SET    Active      = 0,
       LastUpdated = SYSDATETIME()
WHERE  ServerName   = 'DECOM-SERVER'
AND    InstanceName = 'MSSQLSERVER';
```

If using MSX/TSX jobs, also remove the server from each multi-server job:

```sql
EXEC msdb.dbo.sp_delete_jobserver
    @job_name   = 'CentralDB - WaitStats',
    @server_name = 'DECOM-SERVER';
```

---

## 7. Upgrading dbatools

dbatools releases frequently. Test upgrades in a non-production environment first.

```powershell
# Check current version on a server
Get-Module dbatools -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

# Update (run as admin)
Update-Module dbatools -Scope AllUsers

# Verify after update
Get-Module dbatools -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
```

After upgrading, run each collection script manually with `-Verbose` against a test instance to confirm no breaking changes.

The scripts require dbatools >= 2.0.0 and will throw on startup if the minimum version is not met.

---

## 8. Troubleshooting

### Job reports SUCCESS but no data in CentralDB

CMS write failures are non-fatal by design — a CentralDB outage never aborts a collection run. The script logs a WARN and continues.

**Diagnose**:

```powershell
.\Collect\Get-CentralWaitStats.ps1 `
    -SqlInstance 'SQL-01' `
    -CMSInstanceName 'CMS-01' `
    -OutputPath 'D:\Temp' `
    -Verbose
```

Look for: `[WARN] CMS centralization failed: ...`

Also check the CSV output in `-OutputPath`. If rows are there but not in CentralDB, the collection succeeded and only the write failed. Common causes:

- Proxy account lacks INSERT on the target table in CentralDB
- CentralDB was unavailable during the run
- Table schema mismatch (run the stored procedure scripts again)

### Job reports FAILURE on one instance but others succeed

Each instance is processed independently. The script accumulates errors and throws a summary at the end. The SQL Agent job history message will show:

```
Completed with 1 error(s):
[Connecting to SQL-03] Failed on SQL-03: A network-related or instance-specific error...
```

The `[step name]` prefix identifies exactly which phase failed. Common step names:
- `Connecting to <instance>` — network or auth problem
- `Executing WaitStats on <instance>` — permission or timeout
- `Centralizing results to CMS` — CentralDB write (WARN only, not a failure step)

### Script hangs in SQL Agent but works manually

**Cause**: A confirmation prompt is being triggered (ShouldProcess, a first-run module prompt, or a credential popup).

**Fix**:
1. Verify the job step includes `-NonInteractive`.
2. Verify dbatools is installed with `-Scope AllUsers` so the proxy account has access without a first-run module initialization prompt.
3. Run `Import-Module dbatools` once as the proxy account to complete any one-time initialization.

### "dbatools is not installed" error

```
dbatools is not installed. Install via: Install-Module dbatools
```

Install on the affected server as an administrator:

```powershell
Install-Module dbatools -Scope AllUsers -MinimumVersion 2.0.0 -Force
```

### "dbatools version X found; >= 2.0.0 recommended" warning

This is a warning, not a failure. The script will continue. Upgrade when convenient:

```powershell
Update-Module dbatools -Scope AllUsers
```

### "Ola stored proc not found — skipping" warning

```
[WARN] [Inst.usp_GetBaselineStats not found on SQL-01] Skipping baseline collection.
```

Scripts emit a warning and skip rather than failing if a required stored procedure is missing. Deploy the solution:

```powershell
# Ola Hallengren maintenance solution
Install-DbaMaintenanceSolution -SqlInstance 'SQL-01' -Database 'master' -ReplaceExisting

# First Responder Kit (for Invoke-CentralBlitzCollection)
Install-DbaFirstResponderKit -SqlInstance 'SQL-01' -Database 'master' -Force
```

Or set `-DeployOla Y` / `-DeployFRK Y` in the job step to deploy automatically on each run (not recommended for production — prefer a separate one-time deploy job).

### Baseline percentages show values over 100%

This indicates the old `Get-BaselineStats.ps1` stored proc is still deployed. The legacy script had a calculation bug: it used `100 + (delta/base * 100)` instead of the correct `value / base * 100`. Redeploy `Inst.usp_GetBaselineStats.sql` from this branch to correct it.

### CommandLog rows not appearing in [Inst].[CommandLog] after maintenance

1. Verify `CommandLog` table exists in the Ola database (`master` by default):
   ```sql
   SELECT TOP 1 * FROM master.dbo.CommandLog;
   ```
2. Verify the proxy account has `SELECT` and `DELETE` on `[dbo].[CommandLog]` on the target.
3. Verify the proxy account has `INSERT` on `[Inst].[CommandLog]` in CentralDB.
4. Check the SQL Agent job history for WARN messages about centralization failures.

### IntroduceDelay not spreading fleet writes

- Confirm `-IntroduceDelay Y` is in the job step command.
- Confirm `-DelaySecMax` is wide enough. For 50 instances, a max of 300 seconds means up to ~6 writes per second on CentralDB — increase to 600 if contention is observed.
- The delay is applied once per script execution (before the first instance), not per instance.

### WhatIf dry-run shows unexpected operations

Scripts use `SupportsShouldProcess`. To preview what will execute without making changes:

```powershell
.\Collect\Invoke-CentralBackup.ps1 `
    -SqlInstance 'SQL-01' `
    -BackupType FULL `
    -Databases USER_DATABASES `
    -Directory '\\BACKUPSERVER\Backups' `
    -OutputPath 'D:\Temp' `
    -WhatIf
```

`WhatIf` is filtered from the auto-invoke block and will not cause parameter binding errors.

### Checking what was collected in a specific run

Every collection emits a `LoadGUID`. Pass `-LoadGUID` to correlate a specific run across tables:

```sql
-- Find all WaitStats rows from a specific run
SELECT * FROM [Inst].[WaitStats]
WHERE LoadGUID = '3f2e1a00-...'
ORDER BY CollectedAt;

-- Find the CommandLog entries for a maintenance run
SELECT * FROM [Inst].[CommandLog]
WHERE LoadGUID = '3f2e1a00-...'
ORDER BY StartTime;
```

The LoadGUID is also printed in the `[INFO]` verbose output at script start:

```
[2026-05-31 22:00:01] [INFO] Script v4.1.0 started. LoadGUID: 3f2e1a00-...
```
