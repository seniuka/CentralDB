# ============================================================================
# PART 1 - Script-level parameter block
# ============================================================================
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string[]]$SqlInstance,

    [Parameter(Mandatory)]
    [string]$CMSInstanceName,

    [Parameter()]
    [string]$CMSDatabaseName = 'CentralDB',

    [Parameter()]
    [PSCredential]$SqlCredential,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$OutputPath,

    [Parameter()]
    [ValidateSet('All', 'WaitStats', 'Baseline', 'Inventory', 'Blitz')]
    [string[]]$Scripts = @('All')
)

# ============================================================================
# PART 2 - Function definition
# ============================================================================
function Test-CollectionScripts {
<#
.SYNOPSIS
    Runs CentralDB collection scripts against real instances and validates output.

.DESCRIPTION
    Executes each selected collection script with -Verbose, verifies that
    pipeline output is produced, checks that a CSV file is written to
    -OutputPath, and queries CentralDB to confirm rows were centralized.

    Maintenance scripts (Backup, IndexOptimize, IntegrityCheck) are excluded
    from automated testing - run those manually with -WhatIf first.

.PARAMETER SqlInstance
    Target SQL Server instances to collect from.

.PARAMETER CMSInstanceName
    CentralDB instance for result storage.

.PARAMETER CMSDatabaseName
    CentralDB database name. Default: CentralDB.

.PARAMETER SqlCredential
    PSCredential for SQL auth (required for Linux targets).

.PARAMETER OutputPath
    Directory for CSV output from collection scripts.

.PARAMETER Scripts
    Which scripts to test. Default: All.
    Values: All, WaitStats, Baseline, Inventory, Blitz.

.EXAMPLE
    $cred = Import-CliXml 'C:\Secrets\sql-sa.clixml'
    .\Tests\Test-CollectionScripts.ps1 `
        -SqlInstance 'localhost','10.0.1.129' `
        -CMSInstanceName 'localhost' `
        -SqlCredential $cred `
        -OutputPath 'C:\Temp\CentralDB\Tests' `
        -Scripts All

.EXAMPLE
    .\Tests\Test-CollectionScripts.ps1 `
        -SqlInstance 'localhost' `
        -CMSInstanceName 'localhost' `
        -OutputPath 'C:\Temp\CentralDB\Tests' `
        -Scripts WaitStats

.NOTES
    Author      : DBA Engineering
    Version     : 4.1.0
    Requirements: dbatools >= 2.0.0, PowerShell >= 5.1
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$SqlInstance,

        [Parameter(Mandatory)]
        [string]$CMSInstanceName,

        [Parameter()]
        [string]$CMSDatabaseName = 'CentralDB',

        [Parameter()]
        [PSCredential]$SqlCredential,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$OutputPath,

        [Parameter()]
        [ValidateSet('All', 'WaitStats', 'Baseline', 'Inventory', 'Blitz')]
        [string[]]$Scripts = @('All')
    )

    begin {
        Import-Module dbatools -MinimumVersion '2.0.0' -ErrorAction Stop

        $pass    = 0
        $fail    = 0
        $results = [System.Collections.Generic.List[PSCustomObject]]::new()

        $credParam = @{}
        if ($SqlCredential) { $credParam['SqlCredential'] = $SqlCredential }

        $scriptRoot = Split-Path $PSScriptRoot -Parent
        $collectDir = Join-Path $scriptRoot 'Collect'

        function Write-TestResult {
            param(
                [string]$Test,
                [bool]$Passed,
                [string]$Detail = ''
            )
            $status = if ($Passed) { 'PASS' } else { 'FAIL' }
            $color  = if ($Passed) { 'Green' } else { 'Red' }
            $msg    = if ($Detail) { "[$status] $Test - $Detail" } else { "[$status] $Test" }
            Write-Host $msg -ForegroundColor $color

            $script:results.Add([PSCustomObject]@{
                Test   = $Test
                Status = $status
                Detail = $Detail
            })
            if ($Passed) { $script:pass++ } else { $script:fail++ }
        }

        function Invoke-CollectionTest {
            param(
                [string]$ScriptName,
                [string]$FunctionName,
                [hashtable]$ExtraParams,
                [string]$CentralDBTable,
                [string]$CentralDBOrderCol
            )

            $scriptPath = Join-Path $collectDir $ScriptName
            if (-not (Test-Path $scriptPath)) {
                Write-TestResult "$ScriptName exists" $false "Not found at $scriptPath"
                return
            }
            Write-TestResult "$ScriptName exists" $true

            $testGuid  = [guid]::NewGuid().ToString()
            $csvFile   = Join-Path $OutputPath ($ScriptName -replace '\.ps1$', "-$testGuid.csv")

            $invokeParams = @{
                SqlInstance     = $SqlInstance
                CMSInstanceName = $CMSInstanceName
                CMSDatabaseName = $CMSDatabaseName
                OutputPath      = $OutputPath
                OutputFormat    = 'CSV'
                LoadGUID        = $testGuid
            }
            if ($SqlCredential) { $invokeParams['SqlCredential'] = $SqlCredential }
            foreach ($k in $ExtraParams.Keys) { $invokeParams[$k] = $ExtraParams[$k] }

            # Run script
            $pipelineOutput = $null
            try {
                $pipelineOutput = & $scriptPath @invokeParams -Verbose 4>&1 |
                    Where-Object { $_ -is [PSCustomObject] }
                Write-TestResult "$ScriptName completed without throwing" $true
            }
            catch {
                Write-TestResult "$ScriptName completed without throwing" $false $_.Exception.Message
                return
            }

            # Pipeline output
            $rowCount = if ($pipelineOutput) { @($pipelineOutput).Count } else { 0 }
            Write-TestResult "$ScriptName emitted pipeline output" ($rowCount -gt 0) "$rowCount row(s)"

            # CSV written
            $csvExists = Test-Path (Join-Path $OutputPath "*.csv")
            Write-TestResult "$ScriptName wrote CSV to OutputPath" $csvExists

            # CentralDB rows
            if ($CentralDBTable) {
                try {
                    $dbRows = Invoke-DbaQuery -SqlInstance $CMSInstanceName @credParam `
                        -Database $CMSDatabaseName -EnableException `
                        -Query "SELECT TOP 1 1 AS HasRow FROM $CentralDBTable WHERE LoadGUID = @g ORDER BY $CentralDBOrderCol DESC" `
                        -SqlParameters @{ g = $testGuid }
                    Write-TestResult "$ScriptName wrote rows to $CentralDBTable" ($null -ne $dbRows)
                }
                catch {
                    Write-TestResult "$ScriptName wrote rows to $CentralDBTable" $false $_.Exception.Message
                }
            }
        }

        $runAll      = $Scripts -contains 'All'
        $runWait     = $runAll -or $Scripts -contains 'WaitStats'
        $runBaseline = $runAll -or $Scripts -contains 'Baseline'
        $runInv      = $runAll -or $Scripts -contains 'Inventory'
        $runBlitz    = $runAll -or $Scripts -contains 'Blitz'
    }

    process {
        Write-Host "`nCentralDB Collection Script Tests" -ForegroundColor Cyan
        Write-Host "Instances: $($SqlInstance -join ', ')" -ForegroundColor Cyan
        Write-Host ('=' * 50) -ForegroundColor Cyan

        if ($runWait) {
            Write-Host "`n-- Get-CentralWaitStats --" -ForegroundColor Cyan
            Invoke-CollectionTest `
                -ScriptName 'Get-CentralWaitStats.ps1' `
                -ExtraParams @{} `
                -CentralDBTable '[Inst].[WaitStats]' `
                -CentralDBOrderCol 'CollectedAt'
        }

        if ($runBaseline) {
            Write-Host "`n-- Get-CentralBaselineStats --" -ForegroundColor Cyan
            Invoke-CollectionTest `
                -ScriptName 'Get-CentralBaselineStats.ps1' `
                -ExtraParams @{} `
                -CentralDBTable '[Inst].[InsBaselineStats]' `
                -CentralDBOrderCol 'CollectedAt'
        }

        if ($runInv) {
            Write-Host "`n-- Get-CentralInventory (Instance section only) --" -ForegroundColor Cyan
            Invoke-CollectionTest `
                -ScriptName 'Get-CentralInventory.ps1' `
                -ExtraParams @{ Sections = @('Instance') } `
                -CentralDBTable $null `
                -CentralDBOrderCol $null
        }

        if ($runBlitz) {
            Write-Host "`n-- Invoke-CentralBlitzCollection --" -ForegroundColor Cyan
            Invoke-CollectionTest `
                -ScriptName 'Invoke-CentralBlitzCollection.ps1' `
                -ExtraParams @{ DeployFRK = 'N' } `
                -CentralDBTable '[FRK].[Blitz]' `
                -CentralDBOrderCol 'CollectedAt'
        }
    }

    end {
        Write-Host "`n$('=' * 50)" -ForegroundColor Cyan
        Write-Host "Results: $pass PASS  $fail FAIL" -ForegroundColor $(
            if ($fail -gt 0) { 'Red' } else { 'Green' }
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
Test-CollectionScripts @invokeParams
