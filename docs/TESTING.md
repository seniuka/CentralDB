# Testing CentralDB Collection Scripts

## Overview

Two test scripts live in `Tests/`:

| Script | Purpose |
|--------|---------|
| `Tests/Test-CentralDBSetup.ps1` | Validates prerequisites, connectivity, database objects, and ServerList registration before running any collection |
| `Tests/Test-CollectionScripts.ps1` | Runs each collection script against one or more real instances and validates output |

Run setup validation first, then collection testing.

---

## 1. Setup validation

`Test-CentralDBSetup.ps1` checks everything required for collections to work:

```powershell
# Windows auth only (localhost CentralDB)
.\Tests\Test-CentralDBSetup.ps1 `
    -CMSInstanceName 'localhost' `
    -CMSDatabaseName 'CentralDB'

# Mixed fleet with SQL auth for Linux targets
$saCred = Import-CliXml 'C:\Secrets\sql-sa.clixml'
.\Tests\Test-CentralDBSetup.ps1 `
    -CMSInstanceName 'localhost' `
    -CMSDatabaseName 'CentralDB' `
    -SqlCredential $saCred
```

**Checks performed:**

- dbatools >= 2.0.0 is installed
- CentralDB instance is reachable
- All three stored procedures exist (`usp_GetCollectionTargets`, `usp_SetCollectionLastRun`, `usp_GetBaselineStats`)
- `[Svr].[ServerList]` has at least one active instance registered
- Each registered instance is reachable (reports pass/warn per instance — does not stop on first failure)
- `[Svr].[ServerList]` tracking columns exist (`WaitStatLastExecDate`, etc.)

Exit codes: `0` = all pass, `1` = one or more checks failed.

---

## 2. Collection script testing

`Test-CollectionScripts.ps1` runs a real collection against test instances and validates output rows and CSV files are produced.

```powershell
$saCred = Import-CliXml 'C:\Secrets\sql-sa.clixml'

# Test all scripts against localhost and one Linux target
.\Tests\Test-CollectionScripts.ps1 `
    -SqlInstance 'localhost','10.0.1.129' `
    -CMSInstanceName 'localhost' `
    -CMSDatabaseName 'CentralDB' `
    -SqlCredential $saCred `
    -OutputPath 'C:\Temp\CentralDB\Tests' `
    -Scripts All
```

To test a single script:
```powershell
.\Tests\Test-CollectionScripts.ps1 `
    -SqlInstance 'localhost' `
    -CMSInstanceName 'localhost' `
    -CMSDatabaseName 'CentralDB' `
    -OutputPath 'C:\Temp\CentralDB\Tests' `
    -Scripts WaitStats
```

**`-Scripts` values:** `All`, `WaitStats`, `Baseline`, `Inventory`, `Blitz`

Maintenance scripts (`Backup`, `IndexOptimize`, `IntegrityCheck`) are excluded from automated testing — run those manually against a test instance to avoid unintended changes to production data.

**Validation per script:**
- Script exits without throwing
- At least one output row is emitted to the pipeline
- CSV file is written to `-OutputPath`
- At least one row appears in the target CentralDB table

---

## 3. Manual -WhatIf testing for maintenance scripts

Before running maintenance scripts against any real instance:

```powershell
# Dry-run backup - shows what would be backed up, no files written
.\Collect\Invoke-CentralBackup.ps1 `
    -SqlInstance 'localhost' `
    -CMSInstanceName 'localhost' `
    -BackupType FULL `
    -Databases USER_DATABASES `
    -Directory 'C:\Temp\Backups' `
    -OutputPath 'C:\Temp\CentralDB' `
    -WhatIf

# Dry-run index optimize
.\Collect\Invoke-CentralIndexOptimize.ps1 `
    -SqlInstance 'localhost' `
    -CMSInstanceName 'localhost' `
    -Databases USER_DATABASES `
    -OutputPath 'C:\Temp\CentralDB' `
    -WhatIf

# Dry-run integrity check
.\Collect\Invoke-CentralIntegrityCheck.ps1 `
    -SqlInstance 'localhost' `
    -CMSInstanceName 'localhost' `
    -Databases ALL_DATABASES `
    -OutputPath 'C:\Temp\CentralDB' `
    -WhatIf
```

---

## 4. CMS failure resilience test

Verify that a CentralDB outage does not abort a collection run:

```powershell
# Point at a non-existent CMS - collection should complete with WARN, not throw
.\Collect\Get-CentralWaitStats.ps1 `
    -SqlInstance 'localhost' `
    -CMSInstanceName 'DOES-NOT-EXIST' `
    -OutputPath 'C:\Temp\CentralDB' `
    -Verbose
```

Expected: script completes, CSV is written, verbose output shows `[WARN] CMS centralization failed`.

---

## 5. Linux connectivity test

```powershell
$saCred = Import-CliXml 'C:\Secrets\sql-sa.clixml'

$linuxTargets = @('10.0.1.129', '10.0.1.171', '10.0.1.196')
foreach ($t in $linuxTargets) {
    $result = Test-DbaConnection -SqlInstance $t -SqlCredential $saCred
    Write-Host "$t : ConnectSuccess=$($result.ConnectSuccess)  IsSysAdmin=$($result.IsSysAdmin)"
}
```

All three should show `ConnectSuccess=True  IsSysAdmin=True`.

---

## 6. Interpreting results

### Green — all working

```
[PASS] dbatools 2.1.13 installed
[PASS] CentralDB reachable on localhost
[PASS] usp_GetCollectionTargets exists
[PASS] usp_SetCollectionLastRun exists
[PASS] usp_GetBaselineStats exists
[PASS] ServerList has 4 active instances
[PASS] localhost reachable
[PASS] 10.0.1.129 reachable
[PASS] 10.0.1.171 reachable
[PASS] 10.0.1.196 reachable
```

### Common failures

| Message | Cause | Fix |
|---------|-------|-----|
| `dbatools not found` | Module not installed on this machine | `Install-Module dbatools -Scope AllUsers` |
| `CentralDB not reachable` | SQL Server not running or firewall | Start SQL Server, check port 1433 |
| `usp_GetCollectionTargets not found` | Stored procs not deployed | Run Step 2 from SETUP.md |
| `ServerList has 0 active instances` | No instances registered | Run Step 4 from SETUP.md |
| `10.0.1.x not reachable` | Linux VM down or SQL auth wrong | Check VM status, verify sa credential |
| `WaitStatLastExecDate column missing` | Schema not updated from v3 | Run the ALTER TABLE from SETUP.md Step 3 |
