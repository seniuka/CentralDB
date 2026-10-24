---
name: cdb-collector-pattern
description: The CentralDB dbatools collector pattern. Function and worker shape, result contract, throttled parallel dual-path, staging write-back, SQL Agent CmdExec wrapper and job script, platform adapters, and the offline parse checks. Use from /cdb-collector, /cdb-merge, /cdb-schema, /cdb-test and /cdb-migrate.
---
<!-- Name: SKILL.md (cdb-collector-pattern) | Purpose: reusable collector procedure | Version: 0.1.0 | Standard: v5.0.0 (UNVERIFIED, text not in repo) | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# CentralDB collector pattern

Use this when a command needs to write a collector, a worker, a job wrapper, an Agent job script, or run the parse checks. The code below is a template for one example domain, `InstanceInfo`. Replace the domain name, the query and the staging table from the approved plan card.

Tags: `VERIFIED` (checked this session, 2026-10-24), `UNVERIFIED` (not checked), `DECISION` (needs the user).

## 1. Layout and naming

| Piece | File | Notes |
|---|---|---|
| Collector | `src/powershell/Get-DbtCentralDb<Domain>.ps1` | One function per file. Single-block shape |
| Worker | `src/powershell/Invoke-DbtCentralDb<Domain>Worker.ps1` | One function. Runs once per target. Dot-sourced |
| CmdExec wrapper | `src/jobs/Invoke-DbtCentralDb<Domain>Job.ps1` | The only dual-block file |
| Job installer | `src/jobs/New-DbtCentralDb<Domain>Job.ps1` | Report-only unless `-Apply` |
| Job rollback | `src/jobs/Remove-DbtCentralDb<Domain>Job.ps1` | Report-only unless `-Apply` |
| Doc | `docs/scripts/<Name>.md` | One per script, with the impacted-docs list |

Every script starts with a header comment: name, purpose, version, standard version (v5.0.0), author "Your Friendly Neighbourhood DBA", date.

## 2. Why the worker is a separate file

`ForEach-Object -Parallel` runs each item in a new runspace. Two facts, `VERIFIED` on PowerShell 7.6.8 in this session:

- A script block passed with `$using:` is rejected ("variable cannot be a script block").
- Dot-sourcing a worker file by path inside the parallel block works.

So the collector pipes small work items (target, run id, worker path) and each runspace dot-sources the worker file. The Windows PowerShell 5.1 fallback dot-sources the same file once and loops. One worker, two execution paths, no duplicated logic. The 7.2 floor itself is `UNVERIFIED` (only 7.6.8 is installed here).

## 3. Collector template

```powershell
function Get-DbtCentralDbInstanceInfo {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [DbaInstanceParameter[]]$SqlInstance,

        [Parameter(Mandatory = $true)]
        [DbaInstanceParameter]$CentralInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CentralDatabase,

        # Schema-qualified inventory view that returns a column named SqlInstance. Name comes from the plan card.
        [ValidatePattern('^[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*$')]
        [string]$TargetView,

        # DECISION: staging schema name pending its ADR (proposed: stg)
        [ValidateNotNullOrEmpty()]
        [string]$StagingSchema = 'stg',

        [ValidateRange(1, 32)]
        [int]$ThrottleLimit = 4,

        [string]$WorkerPath = (Join-Path $PSScriptRoot 'Invoke-DbtCentralDbInstanceInfoWorker.ps1'),

        [switch]$Apply
    )
    begin {
        $pending = New-Object System.Collections.Generic.List[string]
    }
    process {
        foreach ($item in $SqlInstance) { $pending.Add($item.FullSmoName) }
    }
    end {
        if ($pending.Count -eq 0) {
            if (-not $TargetView) { throw 'Supply the SqlInstance parameter or the TargetView parameter.' }
            $targetQuery = 'SELECT SqlInstance FROM ' + $TargetView
            $rows = Invoke-DbaQuery -SqlInstance $CentralInstance -Database $CentralDatabase -Query $targetQuery -As PSObject -EnableException
            foreach ($row in $rows) { $pending.Add([string]$row.SqlInstance) }
        }
        if ($pending.Count -eq 0) { Write-Warning 'No targets found.'; return }
        if (-not (Test-Path -LiteralPath $WorkerPath)) { throw "Worker not found: $WorkerPath" }

        $runId = [guid]::NewGuid()
        $work = foreach ($target in $pending) {
            [pscustomobject]@{ Target = $target; RunId = $runId; WorkerPath = $WorkerPath }
        }

        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $results = @($work | ForEach-Object -Parallel {
                    . $_.WorkerPath
                    Invoke-DbtCentralDbInstanceInfoWorker -Target $_.Target -RunId $_.RunId
                } -ThrottleLimit $ThrottleLimit)
        }
        else {
            . $WorkerPath
            $results = @(foreach ($w in $work) {
                    Invoke-DbtCentralDbInstanceInfoWorker -Target $w.Target -RunId $w.RunId
                })
        }

        $logRows = @($results | ForEach-Object {
                [pscustomobject]@{
                    RunId      = $_.RunId
                    Domain     = $_.Domain
                    Instance   = $_.Instance
                    StartedUtc = $_.StartedUtc
                    DurationMs = $_.DurationMs
                    Success    = $_.Success
                    ErrorText  = $_.ErrorText
                }
            })
        $dataRows = @($results | Where-Object { $_.Success } | ForEach-Object { $_.Rows })

        if ($Apply) {
            $what = 'Write {0} data rows and {1} run-log rows to {2}.{3}' -f $dataRows.Count, $logRows.Count, $CentralDatabase, $StagingSchema
            if ($PSCmdlet.ShouldProcess($CentralInstance.FullSmoName, $what)) {
                if ($dataRows.Count -gt 0) {
                    Write-DbaDbTableData -SqlInstance $CentralInstance -Database $CentralDatabase -Schema $StagingSchema -Table 'InstanceInfo' -InputObject $dataRows -BatchSize 5000 -EnableException
                }
                Write-DbaDbTableData -SqlInstance $CentralInstance -Database $CentralDatabase -Schema $StagingSchema -Table 'RunLog' -InputObject $logRows -BatchSize 5000 -EnableException
            }
        }
        else {
            Write-Verbose 'Report-only: nothing was written. Use -Apply to write to staging.'
        }
        $results
    }
}
```

Notes:

- Report-only is the default. Without `-Apply` the function reads the targets and emits results. It writes nothing to the central database.
- The central write is one bulk call per table after the parallel phase, not one write per instance.
- Targets come from the inventory view. There is no server list in code.
- The cmdlets and parameters above exist in dbatools 2.8.2, `VERIFIED` with `Get-Command` on this workstation: `Connect-DbaInstance`, `Invoke-DbaQuery` (`-As`, `-EnableException`), `Write-DbaDbTableData` (`-Schema`, `-Table`, `-InputObject`, `-BatchSize`, `-EnableException`). Behavior of `Write-DbaDbTableData` with an array of custom objects is `UNVERIFIED` until `/cdb-test` runs it against a non-production target.
- `SqlInstance` types are `Dataplat.Dbatools.Parameter.DbaInstanceParameter`, `VERIFIED`. The class exposes `FullSmoName`, `VERIFIED`.

## 4. Worker template

```powershell
function Invoke-DbtCentralDbInstanceInfoWorker {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][guid]$RunId
    )
    $startedUtc = [DateTime]::UtcNow
    $watch = [System.Diagnostics.Stopwatch]::StartNew()
    $rows = @()
    $errorText = $null
    $success = $false
    $connection = $null
    try {
        Import-Module dbatools -ErrorAction Stop
        $connection = Connect-DbaInstance -SqlInstance $Target -ClientName 'CentralDB collector' -ConnectTimeout 15
        $query = @'
SELECT
    CAST(SERVERPROPERTY('MachineName')    AS nvarchar(128)) AS MachineName,
    CAST(SERVERPROPERTY('InstanceName')   AS nvarchar(128)) AS InstanceName,
    CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(128)) AS ProductVersion,
    CAST(SERVERPROPERTY('ProductLevel')   AS nvarchar(128)) AS ProductLevel,
    CAST(SERVERPROPERTY('Edition')        AS nvarchar(128)) AS Edition,
    CAST(SERVERPROPERTY('EngineEdition')  AS int)           AS EngineEdition,
    CAST(SERVERPROPERTY('Collation')      AS nvarchar(128)) AS Collation,
    CAST(SERVERPROPERTY('IsClustered')    AS int)           AS IsClustered,
    CAST(SERVERPROPERTY('IsHadrEnabled')  AS int)           AS IsHadrEnabled
'@
        $collectedUtc = [DateTime]::UtcNow
        $rows = @(Invoke-DbaQuery -SqlInstance $connection -Query $query -As PSObject -EnableException | ForEach-Object {
                [pscustomobject]@{
                    RunId          = $RunId
                    Instance       = $Target
                    CollectedAtUtc = $collectedUtc
                    MachineName    = $_.MachineName
                    InstanceName   = $_.InstanceName
                    ProductVersion = $_.ProductVersion
                    ProductLevel   = $_.ProductLevel
                    Edition        = $_.Edition
                    EngineEdition  = $_.EngineEdition
                    Collation      = $_.Collation
                    IsClustered    = $_.IsClustered
                    IsHadrEnabled  = $_.IsHadrEnabled
                }
            })
        $success = $true
    }
    catch {
        $errorText = $_.Exception.Message
        if ($errorText.Length -gt 4000) { $errorText = $errorText.Substring(0, 4000) }
    }
    finally {
        if ($connection) { $null = Disconnect-DbaInstance -InputObject $connection -ErrorAction SilentlyContinue }
        $watch.Stop()
    }
    [pscustomobject]@{
        RunId      = $RunId
        Platform   = 'SqlServer'
        Domain     = 'InstanceInfo'
        Instance   = $Target
        StartedUtc = $startedUtc
        DurationMs = [int]$watch.ElapsedMilliseconds
        Success    = $success
        ErrorText  = $errorText
        Rows       = $rows
    }
}
```

The `SERVERPROPERTY` names are `VERIFIED` against Microsoft Learn on 2026-10-24: `MachineName`, `InstanceName` (NULL for a default instance), `ProductVersion`, `ProductLevel`, `Edition`, `EngineEdition`, `Collation`, `IsClustered`, `IsHadrEnabled`. `ServerName` changed case behavior across SQL Server 2019 cumulative updates, so do not use it as a join key.

Result contract, one object per target: `RunId`, `Platform`, `Domain`, `Instance`, `StartedUtc`, `DurationMs`, `Success`, `ErrorText`, `Rows`. A failure on one target is captured in `ErrorText` and never stops the run. The worker never writes anything to the target.

## 5. SQL Agent CmdExec wrapper (the only dual-block file)

Why script-level parameters are plain strings: `powershell.exe -File` binds script parameters before any module loads. A script-level `[DbaInstanceParameter]` fails with "Unable to find type", `VERIFIED` on Windows PowerShell 5.1 in this session. The repo's v4.1.0 standard (section 2.2) says the same. The function inside the file uses the real type.

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$CentralInstance,
    [Parameter(Mandatory = $true)][string]$CentralDatabase,
    [string[]]$SqlInstance,
    [string]$TargetView,
    [ValidateRange(1, 32)][int]$ThrottleLimit = 4,
    [ValidateSet('Y', 'N')][string]$Apply = 'N'
)

function Invoke-DbtCentralDbInstanceInfoJob {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$CentralInstance,
        [Parameter(Mandatory = $true)][string]$CentralDatabase,
        [string[]]$SqlInstance,
        [string]$TargetView,
        [int]$ThrottleLimit,
        [string]$Apply
    )
    Import-Module dbatools -ErrorAction Stop
    . (Join-Path $PSScriptRoot '..\powershell\Get-DbtCentralDbInstanceInfo.ps1')
    $splat = @{
        CentralInstance = $CentralInstance
        CentralDatabase = $CentralDatabase
        ThrottleLimit   = $ThrottleLimit
    }
    if ($SqlInstance) { $splat['SqlInstance'] = $SqlInstance }
    if ($TargetView) { $splat['TargetView'] = $TargetView }
    if ($Apply -eq 'Y') { $splat['Apply'] = $true }

    $results = @(Get-DbtCentralDbInstanceInfo @splat -Confirm:$false)
    $failed = @($results | Where-Object { -not $_.Success })
    Write-Output ('Targets: {0}  Failed: {1}' -f $results.Count, $failed.Count)
    foreach ($f in $failed) { Write-Output ('FAILED {0}: {1}' -f $f.Instance, $f.ErrorText) }
    if ($results.Count -gt 0 -and $failed.Count -eq $results.Count) { exit 1 }
}

Invoke-DbtCentralDbInstanceInfoJob -CentralInstance $CentralInstance -CentralDatabase $CentralDatabase -SqlInstance $SqlInstance -TargetView $TargetView -ThrottleLimit $ThrottleLimit -Apply $Apply
```

`DECISION`: the step fails (exit 1) only when every target failed. Partial failures are in the run log and the job output. Say if one failure should fail the step.

Two modes from one wrapper, chosen by the job command:

- Push (a job on each target): `-SqlInstance "<token for this server>" -CentralInstance "<management server>" -CentralDatabase "<db>" -Apply Y`.
- Pull (a job on the management server): `-CentralInstance "<token for this server>" -CentralDatabase "<db>" -TargetView "<inventory view>" -Apply Y`.

## 6. Agent job installer and rollback

dbatools parameters below are `VERIFIED` with `Get-Command` against 2.8.2: `Get-DbaAgentJob -Job`, `New-DbaAgentJob -Job -Description`, `New-DbaAgentJobStep -Job -StepName -Subsystem -Command -OnSuccessAction -OnFailAction`, `New-DbaAgentSchedule -Job -Schedule -FrequencyType -FrequencyInterval -StartTime`, `Remove-DbaAgentJob -Job`. Valid `-Subsystem` values include `CmdExec`. Valid `-OnFailAction` values are `QuitWithFailure`, `QuitWithSuccess`, `GoToNextStep`, `GoToStep`. For a `Daily` schedule, `-FrequencyInterval` takes `EveryDay` or 1 to 365.

```powershell
function New-DbtCentralDbInstanceInfoJob {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)][DbaInstanceParameter]$SqlInstance,
        [Parameter(Mandatory = $true)][ValidateSet('Push', 'Pull')][string]$Mode,
        [Parameter(Mandatory = $true)][string]$ScriptPath,
        [Parameter(Mandatory = $true)][string]$CentralDatabase,
        [string]$ManagementInstance,
        [string]$TargetView,
        [string]$JobName = 'CentralDB - Collect InstanceInfo',
        # DECISION: execution policy for the Agent step; RemoteSigned assumed
        [string]$ExecutionPolicy = 'RemoteSigned',
        [string]$StartTime = '060000',
        [switch]$Apply
    )
    $thisServerToken = '$(ESCAPE_DQUOTE(SRVR))'
    if ($Mode -eq 'Push') {
        if (-not $ManagementInstance) { throw 'Push mode needs -ManagementInstance.' }
        $arguments = '-SqlInstance "{0}" -CentralInstance "{1}" -CentralDatabase "{2}" -Apply Y' -f $thisServerToken, $ManagementInstance, $CentralDatabase
    }
    else {
        if (-not $TargetView) { throw 'Pull mode needs -TargetView.' }
        $arguments = '-CentralInstance "{0}" -CentralDatabase "{1}" -TargetView "{2}" -Apply Y' -f $thisServerToken, $CentralDatabase, $TargetView
    }
    $command = 'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy {0} -File "{1}" {2}' -f $ExecutionPolicy, $ScriptPath, $arguments

    $existing = Get-DbaAgentJob -SqlInstance $SqlInstance -Job $JobName
    if ($existing) {
        Write-Output ('Job already exists, nothing to do: {0}' -f $JobName)
        return
    }
    if (-not $Apply) {
        Write-Output ('Report-only. Would create job "{0}" with command: {1}' -f $JobName, $command)
        return
    }
    if ($PSCmdlet.ShouldProcess($SqlInstance.FullSmoName, "Create Agent job $JobName")) {
        $null = New-DbaAgentJob -SqlInstance $SqlInstance -Job $JobName -Description 'CentralDB collector (generated)' -EnableException
        $null = New-DbaAgentJobStep -SqlInstance $SqlInstance -Job $JobName -StepName 'Collect' -Subsystem CmdExec -Command $command -OnSuccessAction QuitWithSuccess -OnFailAction QuitWithFailure -EnableException
        $null = New-DbaAgentSchedule -SqlInstance $SqlInstance -Job $JobName -Schedule 'CentralDB daily' -FrequencyType Daily -FrequencyInterval EveryDay -StartTime $StartTime -EnableException
    }
}

function Remove-DbtCentralDbInstanceInfoJob {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)][DbaInstanceParameter]$SqlInstance,
        [string]$JobName = 'CentralDB - Collect InstanceInfo',
        [switch]$Apply
    )
    $existing = Get-DbaAgentJob -SqlInstance $SqlInstance -Job $JobName
    if (-not $existing) { Write-Output ('No such job: {0}' -f $JobName); return }
    if (-not $Apply) { Write-Output ('Report-only. Would remove job "{0}".' -f $JobName); return }
    if ($PSCmdlet.ShouldProcess($SqlInstance.FullSmoName, "Remove Agent job $JobName")) {
        Remove-DbaAgentJob -SqlInstance $SqlInstance -Job $JobName -EnableException
    }
}
```

The `$(ESCAPE_DQUOTE(SRVR))` job-step token is the one the repo's `docs/SQL-AGENT-JOBS.md` already uses. Its current syntax in Microsoft docs is `UNVERIFIED`. The token sits in a single-quoted string on purpose so PowerShell does not evaluate it.

In the file set above, put each function in its own file. They are shown together here only for reading.

## 7. Platform adapters (PostgreSQL, Oracle)

dbatools covers SQL Server only. An adapter must honor the same worker contract (same parameters, same result object, `Platform` set to `PostgreSql` or `Oracle`). Rules:

- A new driver or module is a proposal. Do not add one without the user's approval (`DECISION`, tracked in `docs/modernization-candidates.md`).
- Drivers load from the approved UNC location only. No `Install-Module`, no package download at runtime.
- Prefer integrated or Kerberos-style authentication. If the platform needs a stored credential, that is a deny-list row R3 exception and needs an ADR.
- Oracle's managed driver package states .NET Framework 4.6.2 and later (19.23.0 release notes). Whether the current Npgsql build loads in Windows PowerShell 5.1 is `UNVERIFIED`: test before relying on it.
- Use `Rows` with the same column names as the SQL Server domain where the data means the same thing, plus `Platform`.

## 8. Parse checks

Run the PowerShell check once under `powershell.exe` (5.1) and once under `pwsh` (7.x). It reads files and executes none of them. Installed here: 5.1.26100 and 7.6.8, so 7.2 itself is `UNVERIFIED`.

```powershell
$files = Get-ChildItem -Path $Path -Filter *.ps1 -Recurse
foreach ($file in $files) {
    $tokens = $null
    $parseErrors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)
    foreach ($e in $parseErrors) {
        [pscustomobject]@{ File = $file.Name; Line = $e.Extent.StartLineNumber; Message = $e.Message }
    }
}
```

T-SQL parse, offline, no server connection. `Microsoft.SqlServer.TransactSql.ScriptDom.dll` ships with `dbatools.library` (2025.12.28 here, `desktop` folder for 5.1, `core` folder for 7), `VERIFIED`. The library contains `TSql160Parser` and `TSql170Parser`, `VERIFIED`. Which parser version equals which SQL Server release is `UNVERIFIED`. Split batches on `GO` lines first.

```powershell
$lib = (Get-Module -ListAvailable dbatools.library | Select-Object -First 1).ModuleBase
$flavor = if ($PSVersionTable.PSEdition -eq 'Core') { 'core' } else { 'desktop' }
Add-Type -Path (Join-Path $lib "$flavor\lib\Microsoft.SqlServer.TransactSql.ScriptDom.dll")
$parser = New-Object Microsoft.SqlServer.TransactSql.ScriptDom.TSql160Parser($true)
foreach ($file in Get-ChildItem -Path $Path -Filter *.sql -Recurse) {
    $batches = (Get-Content -LiteralPath $file.FullName -Raw) -split '(?im)^\s*GO\s*$'
    $n = 0
    foreach ($batch in $batches) {
        $n++
        $errors = $null
        $null = $parser.Parse((New-Object System.IO.StringReader($batch)), [ref]$errors)
        foreach ($e in $errors) {
            [pscustomobject]@{ File = $file.Name; Batch = $n; Line = $e.Line; Message = $e.Message }
        }
    }
}
```

Use `TSql170Parser` for the version-gated SQL Server 2025 files.

## 9. Before you hand back

1. Header present on every file. No em dashes. No server names in code or docs.
2. `-Apply` absent means nothing is written or changed. Read the code and confirm.
3. Parse checks clean on both hosts.
4. The deny-list scanner reports zero hits (`docs/deny-list.md`).
5. Impacted docs listed in each script's doc.
6. Every dbatools parameter used was checked with `Get-Command`, or is tagged `UNVERIFIED`.
