# ============================================================================
# PART 1 - Script-level parameter block
# ============================================================================
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$CMSInstanceName,

    [Parameter()]
    [string]$CMSDatabaseName = 'CentralDB',

    [Parameter()]
    [PSCredential]$SqlCredential
)

# ============================================================================
# PART 2 - Function definition
# ============================================================================
function Test-CentralDBSetup {
<#
.SYNOPSIS
    Validates all prerequisites for CentralDB collection scripts.

.DESCRIPTION
    Checks dbatools installation, CentralDB connectivity, required stored
    procedures, ServerList registration, and reachability of each registered
    target instance. Reports PASS/WARN/FAIL per check. Exits with code 1
    if any check fails.

.PARAMETER CMSInstanceName
    SQL Server instance hosting CentralDB.

.PARAMETER CMSDatabaseName
    CentralDB database name. Default: CentralDB.

.PARAMETER SqlCredential
    PSCredential for SQL auth. Required for Linux targets.

.EXAMPLE
    .\Tests\Test-CentralDBSetup.ps1 -CMSInstanceName 'localhost'

.EXAMPLE
    $cred = Import-CliXml 'C:\Secrets\sql-sa.clixml'
    .\Tests\Test-CentralDBSetup.ps1 -CMSInstanceName 'localhost' -SqlCredential $cred

.NOTES
    Author      : DBA Engineering
    Version     : 4.1.0
    Requirements: dbatools >= 2.0.0, PowerShell >= 5.1
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$CMSInstanceName,

        [Parameter()]
        [string]$CMSDatabaseName = 'CentralDB',

        [Parameter()]
        [PSCredential]$SqlCredential
    )

    begin {
        $pass    = 0
        $warn    = 0
        $fail    = 0
        $results = [System.Collections.Generic.List[PSCustomObject]]::new()

        function Write-Check {
            param(
                [string]$Check,
                [ValidateSet('PASS','WARN','FAIL')]
                [string]$Status,
                [string]$Detail = ''
            )
            $color = switch ($Status) {
                'PASS' { 'Green'  }
                'WARN' { 'Yellow' }
                'FAIL' { 'Red'    }
            }
            $msg = if ($Detail) { "[$Status] $Check - $Detail" } else { "[$Status] $Check" }
            Write-Host $msg -ForegroundColor $color

            $script:results.Add([PSCustomObject]@{
                Check  = $Check
                Status = $Status
                Detail = $Detail
            })

            switch ($Status) {
                'PASS' { $script:pass++ }
                'WARN' { $script:warn++ }
                'FAIL' { $script:fail++ }
            }
        }

        $credParam = @{}
        if ($SqlCredential) { $credParam['SqlCredential'] = $SqlCredential }
    }

    process {
        Write-Host "`nCentralDB Setup Validation" -ForegroundColor Cyan
        Write-Host ('=' * 50) -ForegroundColor Cyan

        # --- dbatools ---
        $mod = Get-Module -Name dbatools -ListAvailable |
            Sort-Object Version -Descending | Select-Object -First 1

        if (-not $mod) {
            Write-Check 'dbatools installed' 'FAIL' 'Not found. Run: Install-Module dbatools -Scope AllUsers'
        }
        elseif ($mod.Version -lt [Version]'2.0.0') {
            Write-Check 'dbatools version' 'WARN' "$($mod.Version) found — >= 2.0.0 required. Run: Update-Module dbatools"
        }
        else {
            Write-Check 'dbatools installed' 'PASS' "v$($mod.Version)"
        }

        Import-Module dbatools -MinimumVersion '2.0.0' -ErrorAction SilentlyContinue

        # --- CentralDB connectivity ---
        try {
            $null = Connect-DbaInstance -SqlInstance $CMSInstanceName @credParam -ErrorAction Stop
            Write-Check "CentralDB reachable ($CMSInstanceName)" 'PASS'
        }
        catch {
            Write-Check "CentralDB reachable ($CMSInstanceName)" 'FAIL' $_.Exception.Message
            Write-Host "`nCannot continue without CentralDB. Exiting." -ForegroundColor Red
            $results
            exit 1
        }

        # --- Required stored procedures ---
        $procs = @(
            @{ Schema = 'Svr';  Name = 'usp_GetCollectionTargets' }
            @{ Schema = 'Svr';  Name = 'usp_SetCollectionLastRun'  }
            @{ Schema = 'Inst'; Name = 'usp_GetBaselineStats'       }
        )

        foreach ($proc in $procs) {
            $exists = Invoke-DbaQuery -SqlInstance $CMSInstanceName @credParam `
                -Database $CMSDatabaseName -EnableException `
                -Query "SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON p.schema_id = s.schema_id WHERE s.name = @Schema AND p.name = @Name" `
                -SqlParameters @{ Schema = $proc.Schema; Name = $proc.Name }

            if ($exists) {
                Write-Check "$($proc.Schema).$($proc.Name) exists" 'PASS'
            }
            else {
                Write-Check "$($proc.Schema).$($proc.Name) exists" 'FAIL' 'Run: SQL\StoredProcedures deploy step from SETUP.md'
            }
        }

        # --- ServerList tracking columns ---
        $trackCols = @('WaitStatLastExecDate','BaselineLastExecDate','InventoryLastExecDate','LastLoadGUID','LastUpdated')
        $existingCols = Invoke-DbaQuery -SqlInstance $CMSInstanceName @credParam `
            -Database $CMSDatabaseName -EnableException `
            -Query "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Svr' AND TABLE_NAME = 'ServerList' AND COLUMN_NAME IN (@c1,@c2,@c3,@c4,@c5)" `
            -SqlParameters @{ c1=$trackCols[0]; c2=$trackCols[1]; c3=$trackCols[2]; c4=$trackCols[3]; c5=$trackCols[4] }

        $missingCols = $trackCols | Where-Object { $_ -notin $existingCols.COLUMN_NAME }
        if ($missingCols) {
            Write-Check 'ServerList tracking columns' 'WARN' "Missing: $($missingCols -join ', '). Run ALTER TABLE step from SETUP.md."
        }
        else {
            Write-Check 'ServerList tracking columns' 'PASS'
        }

        # --- Registered instances ---
        $servers = Invoke-DbaQuery -SqlInstance $CMSInstanceName @credParam `
            -Database $CMSDatabaseName -EnableException `
            -Query "SELECT ServerName, InstanceName FROM [Svr].[ServerList] WHERE Active = 1 ORDER BY ServerName"

        if (-not $servers -or @($servers).Count -eq 0) {
            Write-Check 'ServerList active instances' 'FAIL' 'No active instances registered. Run Step 4 from SETUP.md.'
        }
        else {
            Write-Check 'ServerList active instances' 'PASS' "$(@($servers).Count) registered"

            # --- Reachability per instance ---
            Write-Host "`nInstance reachability:" -ForegroundColor Cyan

            foreach ($row in $servers) {
                $fqn = if ($row.InstanceName -and $row.InstanceName -ne 'MSSQLSERVER') {
                    "$($row.ServerName)\$($row.InstanceName)"
                }
                else { $row.ServerName }

                try {
                    $null = Connect-DbaInstance -SqlInstance $fqn @credParam -ErrorAction Stop
                    Write-Check "  $fqn reachable" 'PASS'
                }
                catch {
                    Write-Check "  $fqn reachable" 'WARN' $_.Exception.Message
                }
            }
        }
    }

    end {
        Write-Host "`n$('=' * 50)" -ForegroundColor Cyan
        Write-Host "Results: $pass PASS  $warn WARN  $fail FAIL" -ForegroundColor $(
            if ($fail -gt 0) { 'Red' } elseif ($warn -gt 0) { 'Yellow' } else { 'Green' }
        )

        $results

        if ($fail -gt 0) { exit 1 }
    }
}

# ============================================================================
# PART 3 - Auto-invoke
# ============================================================================
$invokeParams = @{}
foreach ($key in $PSBoundParameters.Keys) {
    $invokeParams[$key] = $PSBoundParameters[$key]
}
Test-CentralDBSetup @invokeParams
