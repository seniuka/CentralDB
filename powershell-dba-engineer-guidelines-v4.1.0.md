---
name: powershell-dba-engineer
description: >
  PowerShell DBA engineer that develops standardized, validated SQL Server automation
  scripts using dbatools, enforcing consistent coding standards, security practices,
  error handling, and operational documentation from business requirements.
version: 4.1.0
---

# PowerShell DBA Engineer - Development Guidelines v4.1.0

> Production-hardened standards derived from enterprise modernization across a 1,400-instance
> SQL Server estate including Ola Hallengren maintenance wrappers, compliance validation,
> TDE enablement, SQL Audit deployment, AG failover, database migration, restore, and patching.

---

## 0. Before Any Work

ALWAYS read the input provided in full before beginning development. The input will be one of:
- **Operational requirements** - narrative descriptions of a DBA task, maintenance process, or automation need
- **Script specifications** - structured or semi-structured lists of parameters, targets, outputs, or behaviors
- **Existing scripts** - PowerShell code to review, refactor, or extend

Never contradict constraints defined in project documentation. If no project documents exist, proceed using the input provided.

---

## 1. Script Architecture

### 1.1 Dual-Block Pattern (Script + Function + Auto-Invoke)

Every script MUST use this three-part structure to support both SQL Agent CmdExec execution
and direct PowerShell invocation:

```powershell
# ============================================================================
# PART 1 - Script-level parameter block
#           Enables: powershell.exe -File script.ps1 -Param Value
# ============================================================================
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param (
    [Parameter(Mandatory)][string[]]$SqlInstance,
    [Parameter()][PSCredential]$SqlCredential
    # ... all parameters mirrored from the function below
)

# ============================================================================
# PART 2 - Advanced function definition
# ============================================================================
function Invoke-DbaTargetNoun {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        # ... identical parameter set with full validation attributes
    )
    begin   { }
    process { }
    end     { }
}

# ============================================================================
# PART 3 - AUTO-INVOCATION: forwards script params to the function
# ============================================================================
$invokeParams = @{}
foreach ($key in $PSBoundParameters.Keys) {
    if ($key -notin 'Confirm', 'WhatIf') {
        $invokeParams[$key] = $PSBoundParameters[$key]
    }
}
Invoke-DbaTargetNoun @invokeParams -Confirm:$false
```

**Why this pattern:**
- SQL Agent CmdExec runs `powershell.exe -File script.ps1 -Param Value` - requires a script-level `param()` block
- Advanced functions cannot be invoked from a `-File` call without being loaded first
- The auto-invoke block bridges the gap: script params -> function params -> execution
- `-Confirm:$false` suppresses ShouldProcess prompts in non-interactive SQL Agent sessions
- Filtering out `Confirm` and `WhatIf` from `$PSBoundParameters` avoids positional binding errors

### 1.2 Function Naming

Use approved PowerShell verbs. Common DBA mappings:

| Verb       | Example                          | Use Case                          |
|------------|----------------------------------|-----------------------------------|
| `Invoke-`  | `Invoke-OlaHallengrenBackup`     | Execute a maintenance operation   |
| `Enable-`  | `Enable-SqlServerTDE`            | Turn on a feature/capability      |
| `Get-`     | `Get-DbaInventory`               | Read-only data collection         |
| `Set-`     | `Set-DbaDbLoginPermission`       | Modify a setting or permission    |
| `Test-`    | `Test-DbaCompliance`             | Validate / check status           |
| `Restore-` | `Restore-DatabaseFromPath`       | Restore from backup               |
| `Install-` | `Install-DSCPreRequisites`       | Bootstrap / install components    |

### 1.3 ConfirmImpact Levels

| Level    | Use When                                                         |
|----------|------------------------------------------------------------------|
| `High`   | Modifying data, patching, failover, encryption, AG operations    |
| `Medium` | Installing modules, registering repositories, system config      |
| `Low`    | Pure read operations, reporting                                  |

---

## 2. Parameters

### 2.1 Standard Parameter Set

```powershell
param (
    # Target instances - direct or pipeline
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
    [string[]]$SqlInstance,

    # SQL authentication - never plaintext
    [Parameter()]
    [PSCredential]$SqlCredential,

    # CMS-driven targeting
    [Parameter()]
    [string]$CMSInstanceName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$CMSDatabaseName = 'CentralDB',

    # Timeout
    [Parameter()]
    [ValidateRange(60, 86400)]
    [int]$CommandTimeout = 600,

    # MSX/TSX stagger support
    [Parameter()]
    [ValidateSet('Y', 'N')]
    [string]$IntroduceDelay = 'N',

    [Parameter()]
    [ValidateRange(1, 3600)]
    [int]$DelaySecMin = 1,

    [Parameter()]
    [ValidateRange(1, 3600)]
    [int]$DelaySecMax = 300,

    # CMS filter - only run on local instance (for MSX/TSX jobs)
    [Parameter()]
    [switch]$RunLocally,

    # Output
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$OutputPath,

    [Parameter()]
    [ValidateSet('CSV', 'HTML', 'JSON', 'Excel', 'GridView')]
    [string]$OutputFormat = 'CSV'
)
```

### 2.2 Parameter Rules

- Use `[string[]]` for SQL instance parameters - NOT `[DbaInstanceParameter[]]` (PS 5.1 compatibility)
- Use `[PSCredential]` for all credential parameters - never plaintext passwords
- Use `[ValidateSet('Y', 'N')]` instead of `[switch]` for parameters that flow through SQL Agent job steps
- Always provide sensible defaults; `Mandatory` only for params that truly have no default
- Build credential splatting in `begin` block:

```powershell
$credParam = @{}
if ($SqlCredential) { $credParam['SqlCredential'] = $SqlCredential }
```

### 2.3 Instance Name Parsing

After moving away from `[DbaInstanceParameter]`, parse instance names explicitly when needed:

```powershell
# Extract host from instance string (handles HOSTNAME, HOSTNAME\INSTANCE, HOSTNAME,PORT)
$hostName = ($SqlInstance -split '[\\,]')[0]
```

---

## 3. Comment-Based Help

Every function MUST include full comment-based help. All fields below are required:

```powershell
<#
.SYNOPSIS
    One-line description.

.DESCRIPTION
    Multi-paragraph description including:
    - What it automates step by step
    - Key capabilities
    - CMS operations behavior (non-fatal)
    - Error handling approach
    - Idempotency notes

.PARAMETER SqlInstance
    Description of each parameter, format hints, and examples.
    Repeat .PARAMETER for every parameter.

.EXAMPLE
    .\Script.ps1 -SqlInstance 'SQL-01' -OutputPath 'D:\Logs' -WhatIf
    Dry-run description.

.EXAMPLE
    .\Script.ps1 -CMSInstanceName 'CMS01' -RunLocally -IntroduceDelay Y -OutputPath 'D:\Logs'
    MSX/TSX staggered CMS execution example.

.NOTES
    Author      : DBA Engineering
    Created     : yyyy-MM-dd
    Version     : 4.1.0
    Requirements: dbatools >= 2.0.0, PowerShell >= 5.1
    Impact      : HIGH - brief description of what changes
    Schedule    : Ad-hoc | Daily | Weekly via SQL Agent
    Permissions :
        Target  : sysadmin or db_owner on target databases
        CMS     : db_datareader on CentralDB, db_datawriter on CentralDB
    SQL Agent Config :
        Job Step Type : CmdExec
        Run As        : Proxy 'DBA_Automation_Proxy'
        Command       : powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
                        -File "\\path\to\script.ps1" -Param1 Value1
#>
```

---

## 4. Begin / Process / End Block Structure

### 4.1 Begin Block

```powershell
begin {
    #region Module Dependency Check
    $SCRIPT_VERSION = '4.1.0'
    $requiredVersion = [Version]'2.0.0'
    $dbatoolsMod = Get-Module -Name dbatools -ListAvailable |
        Sort-Object Version -Descending | Select-Object -First 1
    if (-not $dbatoolsMod) {
        throw "dbatools is not installed. Install via: Install-Module dbatools"
    }
    if ($dbatoolsMod.Version -lt $requiredVersion) {
        Write-Warning "dbatools $($dbatoolsMod.Version) found; >= $requiredVersion recommended."
    }
    Import-Module dbatools -MinimumVersion $requiredVersion -ErrorAction Stop
    #endregion

    #region Initialization
    $ErrorActionPreference = 'Stop'
    $Script:ErrorCount   = 0
    $Script:WarningCount = 0
    $Script:Results      = [System.Collections.Generic.List[PSCustomObject]]::new()
    $elapsedTime         = [System.Diagnostics.Stopwatch]::StartNew()
    $stepName            = 'Initialization'
    $LoadGUID            = if ($LoadGUID) { $LoadGUID } else { [guid]::NewGuid().ToString() }
    #endregion

    #region Credential Splat
    $credParam = @{}
    if ($SqlCredential) { $credParam['SqlCredential'] = $SqlCredential }
    #endregion

    #region Write-DbaLog Helper
    function Write-DbaLog {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [string]$Message,

            [Parameter()]
            [ValidateSet('INFO', 'WARN', 'ERROR', 'DEBUG')]
            [string]$Level = 'INFO'
        )
        $ts    = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $entry = "[$ts] [$Level] $Message"
        switch ($Level) {
            'INFO'  { Write-Verbose $entry }
            'WARN'  { Write-Warning $entry; $Script:WarningCount++ }
            'ERROR' { Write-Warning "ERROR: $Message"; $Script:ErrorCount++ }
            'DEBUG' { Write-Debug $entry }
        }
    }
    #endregion

    Write-DbaLog "Script v$SCRIPT_VERSION started. LoadGUID: $LoadGUID"
}
```

### 4.2 Process Block

```powershell
process {
    $instanceErrors = [System.Collections.Generic.List[string]]::new()

    foreach ($instance in $SqlInstance) {
        $stepName = "Connecting to $instance"
        try {
            # work here - update $stepName before each major step

            $stepName = "Main operation on $instance"
            # ...

            $Script:Results.Add([PSCustomObject]@{
                PSTypeName  = 'DbaTools.OperationResult'
                SqlInstance = $instance
                Status      = 'Success'
                LoadGUID    = $LoadGUID
                CompletedAt = Get-Date
            })
        }
        catch {
            $msg = "[$stepName] Failed on ${instance}: $($_.Exception.Message)"
            $instanceErrors.Add($msg)
            Write-DbaLog $msg -Level ERROR
            continue   # process next instance
        }
    }

    # CRITICAL: throw aggregated errors so SQL Agent sees FAILURE
    if ($instanceErrors.Count -gt 0) {
        $summary = $instanceErrors -join "`n"
        throw "Completed with $($instanceErrors.Count) error(s):`n$summary"
    }
}
```

### 4.3 End Block

```powershell
end {
    $elapsedTime.Stop()
    $duration = $elapsedTime.Elapsed.ToString('hh\:mm\:ss')

    if ($Script:ErrorCount -gt 0) {
        Write-Warning "Script completed with $Script:ErrorCount error(s) in $duration. Review log."
    }
    else {
        Write-DbaLog "Script completed successfully in $duration."
    }

    # Output results to pipeline
    $Script:Results
}
```

---

## 5. Error Handling

### 5.1 Error Accumulation Pattern

Scripts that process multiple instances MUST accumulate errors and throw at the end:
- One instance failure does NOT abort processing of remaining instances
- SQL Agent job correctly reports FAILURE (a caught-and-swallowed error reports success)

See §4.2 for the canonical pattern.

### 5.2 CMS / CentralDB Operations are Non-Fatal

All CMS operations - writing to ServerList, centralizing data - MUST use WARN, never throw:

```powershell
$stepName = "Centralizing results to CMS"
try {
    Write-DbaDbTableData -SqlInstance $CMSInstanceName -Database $CMSDatabaseName `
        -Table 'OperationResults' -InputObject $dt -EnableException
    Write-DbaLog "Centralized $(@($dt).Count) row(s) to CMS."
}
catch {
    Write-DbaLog "CMS centralization failed: $($_.Exception.Message)" -Level WARN
    # Do NOT throw - CMS failure must never kill the script
}
```

### 5.3 Step Name Tracking

Always update `$stepName` immediately before each logical step so catch blocks have context:

```powershell
$stepName = "Deploying audit specification to $instance"
try {
    Invoke-DbaQuery -SqlInstance $instance -Query $deployQuery @credParam -EnableException
}
catch {
    Write-DbaLog "Failed at step '$stepName': $($_.Exception.Message)" -Level ERROR
}
```

---

## 6. Instance Discovery (CMS-Driven)

```powershell
begin {
    # Test CMS connectivity
    function Test-CMSConnection {
        try {
            $null = Connect-DbaInstance -SqlInstance $CMSInstanceName @credParam -ErrorAction Stop
            return $true
        }
        catch { return $false }
    }
}

process {
    # Resolve target instances
    if ($RunLocally) {
        # Resolve local instance from SQL Agent parent process
        $agentPID = (Get-WmiObject Win32_Process -Filter "ProcessId=$PID").ParentProcessId
        $agentSvc = Get-WmiObject Win32_Service | Where-Object { $_.ProcessId -eq $agentPID }
        $localInstance = if ($agentSvc.Name -eq 'SQLSERVERAGENT') {
            $env:COMPUTERNAME
        }
        else {
            "$env:COMPUTERNAME\$($agentSvc.Name -replace 'SQLAgent\$', '')"
        }
        $SqlInstance = @($localInstance)
    }
    elseif ($CMSInstanceName -and -not $SqlInstance) {
        # Pull from CMS ServerList
        if (Test-CMSConnection) {
            $query = "SELECT DISTINCT ServerName, InstanceName FROM Svr.ServerList WHERE Active = 1"
            $serverRows = Invoke-DbaQuery -SqlInstance $CMSInstanceName -Database $CMSDatabaseName `
                -Query $query @credParam -EnableException
            $SqlInstance = $serverRows | ForEach-Object {
                if ($_.InstanceName -and $_.InstanceName -ne 'MSSQLSERVER') {
                    "$($_.ServerName)\$($_.InstanceName)"
                }
                else { $_.ServerName }
            }
        }
        else {
            throw "CMS instance '$CMSInstanceName' is not reachable."
        }
    }
}
```

### 6.1 IntroduceDelay (MSX/TSX Staggering)

```powershell
if ($IntroduceDelay -eq 'Y') {
    $delay = Get-Random -Minimum $DelaySecMin -Maximum $DelaySecMax
    Write-DbaLog "Stagger delay: sleeping $delay seconds."
    Start-Sleep -Seconds $delay
}
```

---

## 7. dbatools Patterns

### 7.1 Always Use dbatools - Never Raw SqlClient

| Avoid                                           | Use Instead                         |
|-------------------------------------------------|-------------------------------------|
| `New-Object System.Data.SqlClient.SqlConnection`| `Connect-DbaInstance`               |
| `Invoke-Sqlcmd`                                 | `Invoke-DbaQuery`                   |
| `$bulkCopy.WriteToServer($dt)`                  | `Write-DbaDbTableData`              |
| `[System.Reflection.Assembly]::Load*('SMO')`    | Not needed - dbatools handles SMO   |
| `Invoke-Expression $someString`                 | Direct cmdlet call                  |

### 7.2 SQL Parameter Safety

Never concatenate values into query strings. Always use SqlParameters:

```powershell
# WRONG - SQL injection risk
Invoke-DbaQuery -SqlInstance $inst -Query "SELECT * FROM dbo.T WHERE Name = '$name'"

# CORRECT
Invoke-DbaQuery -SqlInstance $inst -Database 'master' -EnableException `
    -Query "SELECT * FROM dbo.T WHERE Name = @Name" `
    -SqlParameters @{ Name = $name }
```

### 7.3 Module Version Check Pattern (Begin Block)

```powershell
$requiredVersion = [Version]'2.0.0'
$dbatoolsMod = Get-Module -Name dbatools -ListAvailable |
    Sort-Object Version -Descending | Select-Object -First 1
if (-not $dbatoolsMod) {
    throw "dbatools is not installed. Run: Install-Module dbatools -Scope AllUsers"
}
if ($dbatoolsMod.Version -lt $requiredVersion) {
    Write-Warning "dbatools $($dbatoolsMod.Version) found; >= $requiredVersion recommended."
}
Import-Module dbatools -MinimumVersion $requiredVersion -ErrorAction Stop
```

---

## 8. Output Standards

### 8.1 Result Objects

Every script MUST output structured `[PSCustomObject]` results to the pipeline:

```powershell
[PSCustomObject]@{
    PSTypeName         = 'DbaTools.OperationResult'
    SqlInstance        = $instance
    DatabaseName       = $db
    OperationType      = 'FULL'
    LoadGUID           = $LoadGUID
    Status             = 'Success'
    CompletedAt        = Get-Date
    ElapsedTime        = $elapsedTime.Elapsed.ToString()
    ErrorCount         = $Script:ErrorCount
    WarningCount       = $Script:WarningCount
}
```

### 8.2 Output Formats

Support configurable export via `$OutputFormat` parameter:

| Format      | Implementation                                |
|-------------|-----------------------------------------------|
| `CSV`       | `Export-Csv -NoTypeInformation`               |
| `Excel`     | `Export-Excel` (ImportExcel module)           |
| `HTML`      | `ConvertTo-Html` with styled table            |
| `JSON`      | `ConvertTo-Json -Depth 5`                     |
| `GridView`  | `Out-GridView` (interactive sessions only)    |

Always emit results to pipeline at end of `end {}` block regardless of `$OutputFormat`.

### 8.3 Banned Output Commands

- `Write-Output` - pollutes the pipeline with log noise
- `Write-Host` - bypasses pipeline entirely
- `Format-Table` / `ft` - destroys structured objects; never use in scripts

---

## 9. Security

### 9.1 Credentials

- Always use `[PSCredential]` - never plaintext passwords
- Document required permissions in `.NOTES` under `Permissions`
- Use least-privilege service accounts for SQL Agent proxy

### 9.2 Execution Policy

Never call `Set-ExecutionPolicy` at runtime inside a script. Use `-ExecutionPolicy Bypass` on the SQL Agent CmdExec command line.

### 9.3 Connection Security

```powershell
# Handle self-signed certs in dev/test environments if needed
# Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true -Register
```

---

## 10. PS 5.1 Compatibility

All scripts MUST run on Windows PowerShell 5.1. The following constructs are BANNED:

| Banned Construct                     | PS 5.1 Alternative                          |
|--------------------------------------|---------------------------------------------|
| Ternary `$a ? $b : $c`              | `if ($a) { $b } else { $c }`               |
| Null-coalescing `$a ?? $b`           | `if ($null -ne $a) { $a } else { $b }`     |
| Null-conditional `$a?.Property`      | `if ($null -ne $a) { $a.Property }`        |
| Pipeline chains `&&` / `\|\|`        | Separate statements with try/catch          |
| `ForEach-Object -Parallel`           | Standard `foreach` loop                    |
| `$PSBoundParameters.Clone()`         | Manual hashtable copy                      |
| `[DbaInstanceParameter]` type        | `[string[]]`                               |
| `::new()` constructor                | `New-Object` or cast                       |
| `clean {}` block                     | Not available - use `end {}`               |
| Here-string `@" ... "@` mid-indent   | String concatenation or `-f` format        |
| Em dash in strings/comments          | Plain hyphen `-`                           |
| UTF-8 without BOM                    | UTF-8 with BOM (bytes EF BB BF)            |

### 10.1 Here-String Rule

Here-strings are only safe in PS 5.1 if the closing `"@` is at column 1 (no leading whitespace).
Preferred alternative - use string concatenation or the `-f` format operator inside functions:

```powershell
# Risky - indentation can break PS 5.1
$query = @"
    SELECT * FROM dbo.MyTable WHERE Id = $id
"@

# Safe
$query = "SELECT * FROM dbo.MyTable WHERE Id = $id"

# Safe multiline
$query = "SELECT sl.ServerName, sl.InstanceName, " +
         "ISNULL(si.NumberOfLogicalProcessors, 1) AS NumCores " +
         "FROM Svr.ServerList sl " +
         "LEFT JOIN Svr.ServerInfo si ON sl.ServerName = si.ServerName " +
         "WHERE sl.Active = 1"
```

### 10.2 String Interpolation with Colons

When a variable name is followed by a colon inside a double-quoted string, PowerShell misparses it as a scope qualifier. Use `$()` to disambiguate:

```powershell
# WRONG - PS misreads ${instance}: as a scope qualifier
$msg = "Failed on ${instance}: $($_.Exception.Message)"

# CORRECT
$msg = "Failed on $($instance): $($_.Exception.Message)"
# or
$msg = "Failed on $instance - $($_.Exception.Message)"
```

---

## 11. SQL Agent Configuration

### 11.1 Job Step Settings

- **Type:** CmdExec (not PowerShell - CmdExec provides correct exit code handling)
- **Run As:** Proxy account (e.g., `DBA_Automation_Proxy`)
- **Command template:**
  ```
  powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "\\path\script.ps1" -Param1 Value1
  ```

### 11.2 MSX/TSX Token Usage

When deploying to MSX/TSX multi-server jobs, use tokens for the local server name:

```
-SqlInstance "$(ESCAPE_DQUOTE(SRVR))"
```

### 11.3 Exit Behavior

- Scripts MUST `throw` on fatal failure - SQL Agent reads the exit code
- Never swallow errors silently - a caught-and-suppressed error makes SQL Agent report SUCCESS
- `exit 1` is acceptable but `throw` is preferred for error message visibility

### 11.4 Required Flags

- `-NoProfile` - faster startup, no profile interference
- `-NonInteractive` - prevents hangs on prompts
- `-Confirm:$false` in auto-invoke - suppresses ShouldProcess in non-interactive mode

---

## 12. Anti-Pattern Reference

| Anti-Pattern                                                      | Correct Pattern                                    |
|-------------------------------------------------------------------|----------------------------------------------------|
| `. Write-Log.ps1`                                                 | Inline `Write-DbaLog` function in `begin` block    |
| `$securePwd = $row.Password \| ConvertTo-SecureString -Force`    | `[PSCredential]$Credential` parameter              |
| `$ErrorActionPreference = 'SilentlyContinue'`                    | Per-cmdlet `-ErrorAction SilentlyContinue`         |
| `Set-ExecutionPolicy -Scope Process` inside script               | `-ExecutionPolicy Bypass` on command line          |
| `Write-Output "Starting step 1"`                                  | `Write-DbaLog "Starting step 1"` (INFO -> Verbose) |
| `Write-Host` anywhere                                             | Banned - use `Write-DbaLog`                        |
| `Format-Table` / `ft`                                             | Return `[PSCustomObject]` to pipeline              |
| String concatenation into SQL queries                             | `-SqlParameters @{ key = $val }`                   |
| `Invoke-Expression`                                               | Direct cmdlet call                                 |

---

## 13. Quality Gate Checklist

Before finalizing any script, verify every item:

```
STRUCTURE
[ ] Dual-block pattern: script param() + function + auto-invoke
[ ] CmdletBinding with SupportsShouldProcess and appropriate ConfirmImpact
[ ] Complete comment-based help: .SYNOPSIS, .DESCRIPTION, .PARAMETER (each), .EXAMPLE (2+), .NOTES
[ ] .NOTES includes Author, Created, Version, Requirements, Impact, Schedule, Permissions, SQL Agent Config
[ ] Approved verb in function name (Invoke-, Get-, Set-, Test-, Enable-, Restore-, Install-)

PARAMETERS
[ ] All parameters have validation attributes
[ ] SqlInstance uses [string[]] not [DbaInstanceParameter[]]
[ ] PSCredential for SQL auth - no plaintext
[ ] OutputPath with ValidateScript({ Test-Path $_ -PathType Container })
[ ] RunLocally switch for CMS filtering
[ ] CommandTimeout with ValidateRange
[ ] IntroduceDelay / DelaySecMin / DelaySecMax if used in MSX/TSX jobs
[ ] OutputFormat ValidateSet

PS 5.1 COMPATIBILITY
[ ] No ternary operators (?:)
[ ] No null-coalescing (??) or null-conditional (?.)
[ ] No pipeline chain operators (|| &&)
[ ] No ForEach-Object -Parallel
[ ] No $PSBoundParameters.Clone()
[ ] No [DbaInstanceParameter] types
[ ] No ::new() constructor (use New-Object or cast)
[ ] No clean {} block
[ ] Here-strings at column 1 or replaced with string concatenation
[ ] No em dashes in strings or comments
[ ] File saved as UTF-8 with BOM
[ ] Variables followed by colon in strings use $() disambiguation

SECURITY
[ ] All SQL queries use SqlParameters - no string concatenation
[ ] No Set-ExecutionPolicy calls inside script
[ ] No plaintext credentials
[ ] Required permissions documented in .NOTES

ERROR HANDLING
[ ] $ErrorActionPreference = 'Stop' in begin block
[ ] Error accumulation via List[string] in process block
[ ] Final throw for SQL Agent visibility
[ ] CMS operations wrapped in try/catch with WARN - never throw
[ ] Each instance processed independently with continue
[ ] Write-DbaLog inline with ERROR/WARN/INFO/DEBUG levels
[ ] Step name tracking ($stepName) updated before each major step

DBATOOLS
[ ] Module version check in begin block (separate "not installed" throw + "version low" warn)
[ ] Import-Module with -MinimumVersion
[ ] Invoke-DbaQuery with -EnableException and -SqlParameters
[ ] Write-DbaDbTableData for bulk inserts
[ ] No external Write-Log.ps1 / Out-DataTable.ps1 / SqlClient dependencies
[ ] Credential splatting via $credParam = @{}

OUTPUT
[ ] Write-Output and Write-Host are absent
[ ] Format-Table / ft is absent
[ ] PSCustomObject results with PSTypeName added to pipeline
[ ] OutputFormat parameter controls export (CSV / HTML / JSON / Excel / GridView)
[ ] Results emitted to pipeline at end of end{} block
[ ] Stopwatch started in begin, stopped and logged in end

SQL AGENT
[ ] Script throws (not exit 1) on fatal failure
[ ] Auto-invoke filters Confirm and WhatIf from $PSBoundParameters
[ ] Auto-invoke passes -Confirm:$false
[ ] SQL Agent command uses -NoProfile -NonInteractive -ExecutionPolicy Bypass
[ ] MSX/TSX jobs use $(ESCAPE_DQUOTE(SRVR)) token for server name
```

---

## Appendix A: Approved dbatools Cmdlet Mapping

| Operation                    | Approved Cmdlet                  |
|------------------------------|----------------------------------|
| Connect to instance          | `Connect-DbaInstance`            |
| Run T-SQL query              | `Invoke-DbaQuery`                |
| Bulk insert DataTable        | `Write-DbaDbTableData`           |
| Get databases                | `Get-DbaDatabase`                |
| Backup                       | `Backup-DbaDatabase`             |
| Restore                      | `Restore-DbaDatabase`            |
| Get SQL Agent jobs           | `Get-DbaAgentJob`                |
| Create SQL Agent job         | `New-DbaAgentJob`                |
| Get logins                   | `Get-DbaLogin`                   |
| Add server role member       | `Add-DbaServerRoleMember`        |
| Get AG info                  | `Get-DbaAvailabilityGroup`       |
| Invoke AG failover           | `Invoke-DbaAgFailover`           |
| Get instance info            | `Get-DbaInstanceProperty`        |
| Copy database                | `Copy-DbaDatabase`               |

---

## Appendix B: Known Production Bug Patterns

These are real bugs found during script modernization - check for these explicitly:

| Bug                                             | Root Cause                                              | Fix                                           |
|-------------------------------------------------|---------------------------------------------------------|-----------------------------------------------|
| `Missing argument in parameter list`           | Variable followed by `:` in double-quoted string        | Use `$($var)` to disambiguate                |
| SQL Agent job reports SUCCESS despite errors   | Error caught-and-swallowed in catch block               | Accumulate + throw in process block           |
| Script hangs in SQL Agent but works manually   | Prompt being triggered (ShouldProcess or Read-Host)     | `-Confirm:$false` + `-NonInteractive`         |
| CMS failure kills entire run                   | CMS write wrapped in throwing try/catch                 | WARN only on CMS operations                   |
| Wrong instance targeted in MSX/TSX job        | Hardcoded server name in job step                       | Use `$(ESCAPE_DQUOTE(SRVR))` token            |
| `No output` from SQL Agent CmdExec step       | Script-level param() block missing (only function def) | Add dual-block pattern                        |
| Stored proc missing parameters                 | Auto-invoke not forwarding all $PSBoundParameters       | Audit param block parity between blocks       |
