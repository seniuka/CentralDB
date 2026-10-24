---
name: cdb-merge-pattern
description: The CentralDB management-server to reporting-server merge pattern. Watermark per source and domain, bulk load to staging, idempotent UPDATE and INSERT, per-batch reconciliation, failure model. Use from /cdb-merge, /cdb-test and /cdb-deploy-plan.
---
<!-- Name: SKILL.md (cdb-merge-pattern) | Purpose: reusable merge procedure for Tier 1 to Tier 2 | Version: 0.1.0 | Standard: v5.0.0 (UNVERIFIED, text not in repo) | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# CentralDB merge pattern (Tier 1 to Tier 2)

Topology from the intake (ADR-0001): standalone management servers collect inventory; a merge process moves it to the reporting and analytics server, a SQL Server 2025 AG pair. This skill covers that merge. Use `cdb-collector-pattern` for Tier 0 to Tier 1.

Tags: `VERIFIED` (checked this session, 2026-10-24), `UNVERIFIED` (not checked), `DECISION` (needs the user).

## Design rules

1. One source, one domain, one watermark. The watermark lives on the reporting server (`ops.MergeWatermark`, template in `templates/merge-upsert.sql`). Several management servers can merge into the same tables because the target key starts with `SourceServer`.
2. Pull rows where `ModifiedAtUtc >= watermark` and `ModifiedAtUtc <= now - lag`. The lag keeps in-flight transactions out of the batch. Using `>=` on the lower bound re-reads the boundary rows; that is safe because the apply step is idempotent.
3. Load the batch into a staging table with `Write-DbaDbTableData`, then run one set-based procedure. No row-by-row writes.
4. The procedure uses `UPDATE ... WHERE incoming is newer` and `INSERT ... WHERE NOT EXISTS`. It does not use `MERGE`: under optimized locking the `MERGE` statement does not get lock-after-qualification, `VERIFIED` on the Microsoft optimized-locking page.
5. Source deletes arrive as `IsDeleted = 1` rows (soft delete). The merge never deletes target rows. `DECISION`: confirm soft delete is acceptable for each domain in its plan card.
6. Reconciliation inside the transaction: every staged row must exist in the target at the same version or newer. A mismatch throws, rolls back, and leaves the watermark unchanged. The caller also compares the pulled row count with the procedure's `StagedRows`.
7. Failure model: each (source, domain) run is its own transaction. A failure is written to the run log and does not stop other domains or sources. The next run repeats the same window.
8. Classification: one merge job moves one classification tier. `DECISION`: whether Protected A/B and Protected C share a reporting AG pair is open (workflow map, section 2). Do not design a merge that mixes tiers until it is answered.
9. Cross-version: management servers have an unknown SQL Server version. The pull query uses only basic T-SQL (explicit column list, parameters). The reporting side may use SQL Server 2025 features, `VERIFIED` that the reporting tier is a 2025 AG pair from the intake.
10. Availability groups: connect to the listener. If the reporting AG is contained, jobs run on the primary replica only and sessions must use the contained AG listener, `VERIFIED` on the contained AG page. Contained AGs are Enterprise only, and Basic AGs (Standard) allow two replicas and one database, `VERIFIED` on the 2025 editions page. `DECISION`: the edition of the reporting pair.

## PowerShell merge function (template)

```powershell
function Invoke-DbtCentralDbMergeExampleDomain {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true)][DbaInstanceParameter]$ManagementInstance,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ManagementDatabase,
        [Parameter(Mandatory = $true)][DbaInstanceParameter]$ReportingInstance,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ReportingDatabase,
        [ValidateRange(0, 3600)][int]$LagSeconds = 60,
        [ValidateRange(1000, 200000)][int]$BatchSize = 50000,
        [switch]$Apply
    )
    $domain = 'ExampleDomain'
    $runId = [guid]::NewGuid()

    $sourceServer = Invoke-DbaQuery -SqlInstance $ManagementInstance -Database $ManagementDatabase -Query 'SELECT @@SERVERNAME AS SourceServer' -As SingleValue -EnableException

    $watermarkQuery = 'SELECT LastModifiedUtc FROM ops.MergeWatermark WHERE SourceServer = @SourceServer AND Domain = @Domain'
    $watermark = Invoke-DbaQuery -SqlInstance $ReportingInstance -Database $ReportingDatabase -Query $watermarkQuery -SqlParameter @{ SourceServer = $sourceServer; Domain = $domain } -As SingleValue -EnableException
    if (-not $watermark) { $watermark = [DateTime]'1900-01-01' }
    $upper = [DateTime]::UtcNow.AddSeconds(-$LagSeconds)

    $pullQuery = @'
SELECT InstanceKey, ModifiedAtUtc, IsDeleted, ProductVersion, Edition
FROM Inst.ExampleDomain
WHERE ModifiedAtUtc >= @Lower AND ModifiedAtUtc <= @Upper
ORDER BY ModifiedAtUtc
'@
    $pulled = @(Invoke-DbaQuery -SqlInstance $ManagementInstance -Database $ManagementDatabase -Query $pullQuery -SqlParameter @{ Lower = $watermark; Upper = $upper } -As PSObject -EnableException)

    $summary = [pscustomobject]@{
        RunId        = $runId
        Domain       = $domain
        SourceServer = $sourceServer
        Watermark    = $watermark
        UpperBound   = $upper
        PulledRows   = $pulled.Count
        Applied      = $false
        StagedRows   = $null
        UpdatedRows  = $null
        InsertedRows = $null
        Reconciled   = $null
    }
    if (-not $Apply) {
        Write-Verbose 'Report-only: nothing was written to the reporting server.'
        return $summary
    }
    if ($pulled.Count -eq 0) { return $summary }

    $what = 'Merge {0} rows from {1} into {2}' -f $pulled.Count, $sourceServer, $ReportingDatabase
    if ($PSCmdlet.ShouldProcess($ReportingInstance.FullSmoName, $what)) {
        $staged = @($pulled | ForEach-Object {
                [pscustomobject]@{
                    RunId          = $runId
                    SourceServer   = $sourceServer
                    InstanceKey    = $_.InstanceKey
                    ModifiedAtUtc  = $_.ModifiedAtUtc
                    IsDeleted      = $_.IsDeleted
                    ProductVersion = $_.ProductVersion
                    Edition        = $_.Edition
                }
            })
        Write-DbaDbTableData -SqlInstance $ReportingInstance -Database $ReportingDatabase -Schema 'stg' -Table 'ExampleDomain_In' -InputObject $staged -BatchSize $BatchSize -EnableException

        $mergeQuery = 'EXEC ops.usp_ExampleDomain_Merge @SourceServer = @SourceServer, @RunId = @RunId, @Apply = 1'
        $result = Invoke-DbaQuery -SqlInstance $ReportingInstance -Database $ReportingDatabase -Query $mergeQuery -SqlParameter @{ SourceServer = $sourceServer; RunId = $runId } -As PSObject -EnableException

        $summary.Applied = $true
        $summary.StagedRows = $result.StagedRows
        $summary.UpdatedRows = $result.UpdatedRows
        $summary.InsertedRows = $result.InsertedRows
        $summary.Reconciled = ([int64]$result.StagedRows -eq $pulled.Count)
    }
    $summary
}
```

Notes:

- `-As SingleValue`, `-As PSObject` and `-SqlParameter` (hashtable) exist on `Invoke-DbaQuery` in dbatools 2.8.2, `VERIFIED` with `Get-Help` and `Get-Command`. How `Write-DbaDbTableData` treats an array of custom objects and how dates round-trip through hashtable parameters are `UNVERIFIED` until `/cdb-test` runs them on a non-production pair.
- The function does not loop over domains or sources. The Agent job runs one call per domain, so one failure is one failed step with its own log line. Order of domains inside a job is a plan-card item.
- `$domain`, schema names and the proc name are examples. A new schema (`stg`, `ops`) needs its ADR first.
- Do not hard-code the management or reporting names. The job script receives them as parameters, the same way as in `cdb-collector-pattern`.

## What `/cdb-merge` produces from this skill

1. Reporting-side DDL from `templates/merge-upsert.sql`, one block per domain, plus a rollback file that removes only the procedure and leaves the tables (data restore is from backup).
2. The merge function and, for Agent runs, the dual-block wrapper and installer described in `cdb-collector-pattern` sections 5 and 6.
3. `Tests/Sql/<Unit>.merge-reconcile.sql` that compares row counts and a checksum per batch on both sides, using explicit columns. `CHECKSUM_AGG(CHECKSUM(...))` can collide; say so in the test doc and use a per-row hash for critical domains.
4. The doc with the impacted-docs list (script doc, both tiers' schema docs, `docs/SCRIPT-REFERENCE.md`, `docs/SQL-AGENT-JOBS.md`, `docs/TESTING.md`).

## Items to verify before first use (`UNVERIFIED`)

- Runtime behavior of every template: they are parse-checked only.
- That `@@SERVERNAME` is the right stable key for a management server (it can differ from the machine name after a rename). The alternative is a registered source id table.
- Lock behavior of the apply step under optimized locking with RCSI on the reporting database.
- Whether the staging table needs a cleanup job for runs that failed before the delete.
