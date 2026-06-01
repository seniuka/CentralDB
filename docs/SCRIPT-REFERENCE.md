# Script Reference

Complete parameter reference for all CentralDB collection scripts.

---

## Common parameters

All seven scripts share this base parameter set.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `-SqlInstance` | `string[]` | No* | — | One or more target SQL Server instances. Accepts pipeline input. Format: `HOSTNAME`, `HOSTNAME\INSTANCE`, or `HOSTNAME,PORT`. |
| `-SqlCredential` | `PSCredential` | No | Windows auth | SQL Server credential. Required for Linux targets. Never plaintext. |
| `-CMSInstanceName` | `string` | No* | — | SQL Server instance hosting CentralDB. Used for instance discovery and result storage. |
| `-CMSDatabaseName` | `string` | No | `CentralDB` | CentralDB database name. |
| `-CommandTimeout` | `int` | No | 600 | Query timeout in seconds. Range: 60–86400. Maintenance scripts default to 14400 (4 hours). |
| `-IntroduceDelay` | `string` | No | `N` | `Y` to sleep a random interval before execution. Use in MSX/TSX fleet jobs to stagger CentralDB writes. |
| `-DelaySecMin` | `int` | No | `1` | Minimum stagger delay in seconds. Range: 1–3600. |
| `-DelaySecMax` | `int` | No | `300` | Maximum stagger delay in seconds. Range: 1–3600. |
| `-RunLocally` | `switch` | No | `$false` | Restrict CMS instance discovery to the local machine. Use in MSX/TSX SQL Agent jobs combined with `-CMSInstanceName`. |
| `-OutputPath` | `string` | **Yes** | — | Directory for CSV/export output. Must exist. |
| `-OutputFormat` | `string` | No | `CSV` | Export format: `CSV`, `HTML`, `JSON`, `Excel`, `GridView`. Results are always emitted to the pipeline regardless of this setting. |
| `-LoadGUID` | `string` | No | Auto-generated | Correlation GUID for this run. Threads through collection tables and CommandLog for end-to-end traceability. |

\* At least one of `-SqlInstance` or `-CMSInstanceName` must be provided.

---

## Get-CentralInventory.ps1

Collects a full SQL Server estate inventory. Replaces legacy `CentralDB/Get-Inventory.ps1`.

**ConfirmImpact:** Low (read-only)

### Additional parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Sections` | `string[]` | `All` | Which sections to collect. Values: `All`, `ServerOS`, `Instance`, `Databases`, `HA`, `SSRS`. Accepts multiple values: `-Sections Instance,Databases`. |

### Sections detail

| Section | dbatools cmdlets used | Windows only |
|---------|----------------------|:------------:|
| `ServerOS` | `Get-DbaComputerSystem`, `Get-DbaHotfix`, `Get-DbaDiskSpace`, `Get-DbaService` | Yes |
| `Instance` | `Test-DbaBuild`, `Get-DbaInstanceProperty`, `Get-DbaSpConfigure`, `Get-DbaLogin`, `Get-DbaServerRole`, `Get-DbaLinkedServer`, `Get-DbaAgentJob` | No |
| `Databases` | `Get-DbaDatabase`, `Get-DbaLastGoodCheckDb`, `Get-DbaDbFile`, `Get-DbaBackupHistory`, `Get-DbaDbRoleMember`, `Get-DbaUserPermission`, `Get-DbaDbMissingIndex` | No |
| `HA` | `Get-DbaAvailabilityGroup` | No |
| `SSRS` | `Get-DbaReportingService` | Yes |

### Example

```powershell
# Full inventory, all sections
.\Collect\Get-CentralInventory.ps1 `
    -CMSInstanceName 'localhost' `
    -OutputPath 'D:\Logs\CentralDB' `
    -Sections All

# Fast refresh - instance and database info only
.\Collect\Get-CentralInventory.ps1 `
    -SqlInstance 'SQL-01','SQL-02' `
    -CMSInstanceName 'localhost' `
    -OutputPath 'D:\Logs\CentralDB' `
    -Sections Instance,Databases
```

---

## Get-CentralWaitStats.ps1

Collects wait statistics from `sys.dm_os_wait_stats`. Replaces legacy `CentralDB/Get-WaitStats.ps1`.

**ConfirmImpact:** Low (read-only)

### Additional parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-IncludeSystemWaits` | `switch` | `$false` | Include system/benign wait types in addition to application waits. |

### Target table

`[Inst].[WaitStats]`

### Example

```powershell
.\Collect\Get-CentralWaitStats.ps1 `
    -CMSInstanceName 'localhost' `
    -OutputPath 'D:\Logs\CentralDB' `
    -RunLocally `
    -IntroduceDelay Y
```

---

## Get-CentralBaselineStats.ps1

Captures SQL Server performance counter deltas and OS PerfMon counters. Replaces legacy `CentralDB/Get-BaselineStats.ps1`.

**ConfirmImpact:** Low (read-only)

No additional parameters beyond the common set.

### Collections per instance

| Collection | Target table | Platform |
|------------|-------------|----------|
| SQL counters (DMV two-snapshot PIVOT via `Inst.usp_GetBaselineStats`) | `[Inst].[InsBaselineStats]` | All |
| OS PerfMon (CPU, disk, memory via `Get-Counter`) | `[Svr].[SvrBaselineStats]` | Windows only |
| Drive PerfMon (per-physical-drive counters via `Get-Counter`) | `[Svr].[SvrBaselineDriveStats]` | Windows only |

### Example

```powershell
.\Collect\Get-CentralBaselineStats.ps1 `
    -CMSInstanceName 'localhost' `
    -OutputPath 'D:\Logs\CentralDB' `
    -RunLocally `
    -IntroduceDelay Y
```

---

## Invoke-CentralBlitzCollection.ps1

Runs `sp_Blitz` and centralizes findings. Replaces legacy `CentralDB/Get-FRKBlitz.ps1`.

**ConfirmImpact:** Medium (deploy phase modifies target)

### Additional parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-DeployFRK` | `string` | `N` | `Y` to run `Install-DbaFirstResponderKit` before collection. Set once to install, then revert to `N`. |
| `-FRKDatabase` | `string` | `master` | Database to install First Responder Kit into. |
| `-CheckProcedureCache` | `string` | `N` | `Y` to pass `@CheckProcedureCache = 1` to `sp_Blitz`. |
| `-CheckUserDatabaseObjects` | `string` | `Y` | `Y` to pass `@CheckUserDatabaseObjects = 1` to `sp_Blitz`. |

### Target table

`[FRK].[Blitz]`

### Example

```powershell
# First run — deploy FRK then collect
.\Collect\Invoke-CentralBlitzCollection.ps1 `
    -SqlInstance 'localhost' `
    -CMSInstanceName 'localhost' `
    -OutputPath 'D:\Logs\CentralDB' `
    -DeployFRK Y

# Subsequent runs
.\Collect\Invoke-CentralBlitzCollection.ps1 `
    -CMSInstanceName 'localhost' `
    -OutputPath 'D:\Logs\CentralDB' `
    -RunLocally `
    -IntroduceDelay Y `
    -DeployFRK N
```

---

## Invoke-CentralBackup.ps1

Executes Ola Hallengren `DatabaseBackup`. Replaces legacy `CentralDB/Get-OlaHallengren-Backup.ps1`.

**ConfirmImpact:** High (writes backup files)

### Additional parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-DeployOla` | `string` | `N` | `Y` to run `Install-DbaMaintenanceSolution` before backup. |
| `-OlaDatabase` | `string` | `master` | Database containing Ola's stored procedures. |
| `-BackupType` | `string` | `FULL` | `FULL`, `DIFF`, or `LOG`. |
| `-Databases` | `string` | `ALL_DATABASES` | Ola database filter. `ALL_DATABASES`, `USER_DATABASES`, `SYSTEM_DATABASES`, or comma-separated list. |
| `-Directory` | `string` | — | Backup destination path. |
| `-Verify` | `string` | `Y` | `Y` to verify each backup after completion. |
| `-CleanupTime` | `int` | — | Hours after which old backup files are deleted. |
| `-Compress` | `string` | `Y` | `Y` to enable backup compression. |
| `-CopyOnly` | `string` | `N` | `Y` for copy-only backups (does not break differential chain). |
| `-Encrypt` | `string` | — | `Y` to encrypt backups. Requires `-ServerCertificate`. |
| `-EncryptionAlgorithm` | `string` | — | `AES128`, `AES192`, `AES256`, `TRIPLE_DES_3KEY`. |
| `-ServerCertificate` | `string` | — | Certificate name for backup encryption. |
| `-AvailabilityGroups` | `string` | — | Comma-separated AG names to filter. |
| `-Updateability` | `string` | `ALL` | `ALL`, `PRIMARY`, `SECONDARY`, `PREFERRED_BACKUP_REPLICA`. |

### Target table

`[Inst].[CommandLog]`

### Example

```powershell
# Full backup with 72-hour retention
.\Collect\Invoke-CentralBackup.ps1 `
    -SqlInstance 'localhost' `
    -CMSInstanceName 'localhost' `
    -BackupType FULL `
    -Databases USER_DATABASES `
    -Directory '\\BACKUPSERVER\Backups' `
    -Compress Y -Verify Y -CleanupTime 72 `
    -OutputPath 'D:\Logs\CentralDB'

# Log backup every 15 minutes
.\Collect\Invoke-CentralBackup.ps1 `
    -CMSInstanceName 'localhost' `
    -BackupType LOG `
    -Databases ALL_DATABASES `
    -Directory '\\BACKUPSERVER\Backups' `
    -CleanupTime 48 `
    -OutputPath 'D:\Logs\CentralDB' `
    -RunLocally -IntroduceDelay Y
```

---

## Invoke-CentralIndexOptimize.ps1

Executes Ola Hallengren `IndexOptimize`. Replaces legacy `CentralDB/Get-OlaHallengren-Index.ps1`.

**ConfirmImpact:** High (rebuilds/reorganizes indexes)

### Additional parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-DeployOla` | `string` | `N` | `Y` to install/update Ola's solution before running. |
| `-OlaDatabase` | `string` | `master` | Database containing Ola's stored procedures. |
| `-Databases` | `string` | `USER_DATABASES` | Ola database filter. |
| `-FragmentationLow` | `string` | `$null` | Action for fragmentation below Level1. Leave null to skip. |
| `-FragmentationMedium` | `string` | `INDEX_REORGANIZE,...` | Action for fragmentation between Level1 and Level2. |
| `-FragmentationHigh` | `string` | `INDEX_REBUILD_ONLINE,...` | Action for fragmentation above Level2. |
| `-FragmentationLevel1` | `int` | `5` | Lower fragmentation threshold (%). |
| `-FragmentationLevel2` | `int` | `30` | Upper fragmentation threshold (%). |
| `-PageCountLevel` | `int` | — | Minimum page count to consider for optimization. |
| `-SortInTempdb` | `string` | `Y` | `Y` to sort index pages in tempdb (faster, uses more tempdb space). |
| `-MaxDOP` | `int` | — | Max degree of parallelism for rebuild operations. |
| `-LOBCompaction` | `string` | `Y` | `Y` to compact LOB data during index rebuild. |
| `-UpdateStatistics` | `string` | — | `ALL`, `COLUMNS`, or `INDEX` — run statistics update in addition to index work. |
| `-OnlyModifiedStatistics` | `string` | `N` | `Y` to update only statistics with modifications since last update. |
| `-Indexes` | `string` | — | Comma-separated index filter. |
| `-TimeLimit` | `int` | — | Maximum run time in seconds. Ola stops starting new operations after this limit. |
| `-AvailabilityGroups` | `string` | — | AG name filter. |
| `-Updateability` | `string` | `ALL` | `ALL`, `PRIMARY`, `SECONDARY`, `PREFERRED_BACKUP_REPLICA`. |

### Target table

`[Inst].[CommandLog]`

### Example

```powershell
.\Collect\Invoke-CentralIndexOptimize.ps1 `
    -SqlInstance 'localhost' `
    -CMSInstanceName 'localhost' `
    -Databases USER_DATABASES `
    -FragmentationLevel1 5 `
    -FragmentationLevel2 30 `
    -SortInTempdb Y `
    -TimeLimit 14400 `
    -OutputPath 'D:\Logs\CentralDB'
```

---

## Invoke-CentralIntegrityCheck.ps1

Executes Ola Hallengren `DatabaseIntegrityCheck`. Replaces legacy `CentralDB/Get-OlaHallengren-Integrity.ps1`.

**ConfirmImpact:** High (runs DBCC against databases)

### Additional parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-DeployOla` | `string` | `N` | `Y` to install/update Ola's solution before running. |
| `-OlaDatabase` | `string` | `master` | Database containing Ola's stored procedures. |
| `-Databases` | `string` | `ALL_DATABASES` | Ola database filter. |
| `-CheckCommands` | `string` | `CHECKDB` | `CHECKDB`, `CHECKFILEGROUP`, `CHECKTABLE`, `CHECKALLOC`, or `CHECKCATALOG`. |
| `-PhysicalOnly` | `string` | `Y` | `Y` for physical-only check (faster — skips logical consistency). |
| `-NoIndex` | `string` | `N` | `Y` to skip non-clustered index checks. |
| `-ExtendedLogicalChecks` | `string` | `N` | `Y` to run extended logical checks (slower). |
| `-TabLock` | `string` | `N` | `Y` to use table locks instead of row locks. |
| `-MaxDOP` | `int` | — | Max degree of parallelism for DBCC operations. |
| `-AvailabilityGroups` | `string` | — | AG name filter. |
| `-AvailabilityGroupReplicas` | `string` | `ALL` | `ALL`, `PRIMARY`, `SECONDARY`, `PREFERRED_BACKUP_REPLICA`. |
| `-Updateability` | `string` | `ALL` | `ALL`, `READ_WRITE`, `READ_ONLY`. |
| `-TimeLimit` | `int` | — | Maximum run time in seconds. |
| `-LockTimeout` | `int` | `10800` | Lock wait timeout in seconds (prevents long blocking on busy systems). |
| `-DatabasesInParallel` | `string` | `N` | `Y` to check multiple databases in parallel (uses more resources). |

### Target table

`[Inst].[CommandLog]`

### Example

```powershell
.\Collect\Invoke-CentralIntegrityCheck.ps1 `
    -SqlInstance 'localhost' `
    -CMSInstanceName 'localhost' `
    -Databases ALL_DATABASES `
    -CheckCommands CHECKDB `
    -PhysicalOnly Y `
    -LockTimeout 10800 `
    -TimeLimit 14400 `
    -OutputPath 'D:\Logs\CentralDB'
```

---

## SQL Agent token reference

When building MSX/TSX job steps, use these tokens:

| Token | Resolves to |
|-------|------------|
| `$(ESCAPE_DQUOTE(SRVR))` | Local server name (safe for double-quoted strings) |
| `$(ESCAPE_DQUOTE(INST))` | Local instance name |
| `$(ESCAPE_DQUOTE(JOBID))` | Job GUID |
| `$(ESCAPE_DQUOTE(STEPID))` | Step number |
| `$(ESCAPE_DQUOTE(DATE))` | Run date as `YYYYMMDD` |
| `$(ESCAPE_DQUOTE(TIME))` | Run time as `HHMMSS` |
