# ============================================================================
# PART 1 - Script-level parameter block
#          Enables: powershell.exe -File Get-CentralWaitStats.ps1 -Param Value
# ============================================================================
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
param (
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
    [string[]]$SqlInstance,

    [Parameter()]
    [PSCredential]$SqlCredential,

    [Parameter()]
    [string]$CMSInstanceName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$CMSDatabaseName = 'CentralDB',

    [Parameter()]
    [ValidateRange(60, 86400)]
    [int]$CommandTimeout = 600,

    [Parameter()]
    [ValidateSet('Y', 'N')]
    [string]$IntroduceDelay = 'N',

    [Parameter()]
    [ValidateRange(1, 3600)]
    [int]$DelaySecMin = 1,

    [Parameter()]
    [ValidateRange(1, 3600)]
    [int]$DelaySecMax = 300,

    [Parameter()]
    [switch]$RunLocally,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$OutputPath,

    [Parameter()]
    [ValidateSet('CSV', 'HTML', 'JSON', 'Excel', 'GridView')]
    [string]$OutputFormat = 'CSV',

    [Parameter()]
    [string]$LoadGUID,

    [Parameter()]
    [switch]$IncludeSystemWaits
)

# ============================================================================
# PART 2 - Advanced function definition
# ============================================================================
function Get-CentralWaitStats {
<#
.SYNOPSIS
    Collects wait statistics from one or more SQL Server instances and
    centralizes the results into [Inst].[WaitStats] in CentralDB.

.DESCRIPTION
    Replaces the legacy Get-WaitStats.ps1 (SMO + SqlBulkCopy, 2017).
    Uses dbatools Get-DbaWaitStatistic for collection and Write-DbaDbTableData
    for centralization.

    Collection behavior:
    - If -SqlInstance is provided, collects from those instances directly.
    - If -CMSInstanceName is provided without -SqlInstance, queries
      [Svr].[usp_GetCollectionTargets] to resolve the target list.
    - If -RunLocally is specified, restricts CMS discovery to the local
      machine only (for use in MSX/TSX SQL Agent deployments).

    After each successful collection, calls [Svr].[usp_SetCollectionLastRun]
    on CentralDB to record the run timestamp. CentralDB write failures are
    non-fatal (WARN only) and never abort instance processing.

    Each instance is processed independently. A failure on one instance is
    logged and accumulated; processing continues on remaining instances.
    The final throw ensures SQL Agent correctly reports job failure.

.PARAMETER SqlInstance
    One or more SQL Server instance names to collect from.
    Accepts hostname, hostname\instance, or hostname,port formats.
    Accepts pipeline input. If omitted, CMS discovery is used.

.PARAMETER SqlCredential
    PSCredential for SQL Server authentication on target instances.
    When omitted, Windows authentication is used.

.PARAMETER CMSInstanceName
    The CentralDB SQL Server instance. Used to resolve the target server
    list via [Svr].[usp_GetCollectionTargets] when -SqlInstance is not
    provided. Also the destination for centralized results.

.PARAMETER CMSDatabaseName
    The CentralDB database name. Default: CentralDB.

.PARAMETER CommandTimeout
    Query timeout in seconds applied to all dbatools calls. Default: 600.
    Valid range: 60 - 86400.

.PARAMETER IntroduceDelay
    Set to 'Y' to introduce a random delay before processing begins.
    Intended for MSX/TSX jobs where multiple servers run the same job
    simultaneously and you want to stagger CentralDB writes.

.PARAMETER DelaySecMin
    Minimum delay in seconds when IntroduceDelay is 'Y'. Default: 1.

.PARAMETER DelaySecMax
    Maximum delay in seconds when IntroduceDelay is 'Y'. Default: 300.

.PARAMETER RunLocally
    Restricts CMS discovery to the local machine only. Use this when
    the script is deployed as a SQL Agent job via MSX/TSX so each target
    server collects only its own data.

.PARAMETER OutputPath
    Directory path where the CSV/HTML/JSON output file is written.
    Must exist before the script runs.

.PARAMETER OutputFormat
    Format for the output file. Default: CSV.
    Supported: CSV, HTML, JSON, Excel, GridView.

.PARAMETER LoadGUID
    Optional correlation GUID. If omitted, a new GUID is generated.
    Pass the same GUID across multiple collection scripts in a single
    scheduled run to correlate results in CentralDB.

.PARAMETER IncludeSystemWaits
    When specified, includes all wait types including typically benign
    system waits. By default, dbatools filters these out.

.EXAMPLE
    .\Get-CentralWaitStats.ps1 -SqlInstance 'SQL-01' -CMSInstanceName 'CMS-01' -OutputPath 'D:\Logs' -WhatIf
    Dry-run against a single instance. No data is collected or written.

.EXAMPLE
    .\Get-CentralWaitStats.ps1 -CMSInstanceName 'CMS-01' -RunLocally -OutputPath 'D:\Logs'
    MSX/TSX mode: resolves instances from CentralDB, restricts to local
    machine, collects wait stats and centralizes to CMS-01.CentralDB.

.EXAMPLE
    .\Get-CentralWaitStats.ps1 -CMSInstanceName 'CMS-01' -IntroduceDelay Y -DelaySecMin 5 -DelaySecMax 60 -OutputPath 'D:\Logs'
    Fleet collection with staggered start to reduce simultaneous CentralDB writes.

.NOTES
    Author      : DBA Engineering
    Created     : 2024-01-01
    Version     : 4.1.0
    Replaces    : CentralDB/Get-WaitStats.ps1 (legacy SMO + SqlBulkCopy)
    Requirements: dbatools >= 2.0.0, PowerShell >= 5.1
    Impact      : LOW - read-only on target instances, INSERT on CentralDB
    Schedule    : Daily via SQL Agent (recommended: 06:00 local time)

    Permissions :
        Target    : VIEW SERVER STATE on each collected instance
        CentralDB : EXECUTE on [Svr].[usp_GetCollectionTargets]
                    EXECUTE on [Svr].[usp_SetCollectionLastRun]
                    INSERT on [Inst].[WaitStats]

    SQL Agent Config :
        Job Step Type : CmdExec
        Run As        : Proxy 'DBA_Automation_Proxy'
        Command       : powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
                        -File "\\share\CentralDB\Collect\Get-CentralWaitStats.ps1"
                        -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))"
                        -RunLocally
                        -OutputPath "D:\Logs\CentralDB"
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [string[]]$SqlInstance,

        [Parameter()]
        [PSCredential]$SqlCredential,

        [Parameter()]
        [string]$CMSInstanceName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$CMSDatabaseName = 'CentralDB',

        [Parameter()]
        [ValidateRange(60, 86400)]
        [int]$CommandTimeout = 600,

        [Parameter()]
        [ValidateSet('Y', 'N')]
        [string]$IntroduceDelay = 'N',

        [Parameter()]
        [ValidateRange(1, 3600)]
        [int]$DelaySecMin = 1,

        [Parameter()]
        [ValidateRange(1, 3600)]
        [int]$DelaySecMax = 300,

        [Parameter()]
        [switch]$RunLocally,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$OutputPath,

        [Parameter()]
        [ValidateSet('CSV', 'HTML', 'JSON', 'Excel', 'GridView')]
        [string]$OutputFormat = 'CSV',

        [Parameter()]
        [string]$LoadGUID,

        [Parameter()]
        [switch]$IncludeSystemWaits
    )

    # -------------------------------------------------------------------------
    begin {
        #region Module Dependency Check
        $SCRIPT_VERSION  = '4.1.0'
        $requiredVersion = [Version]'2.0.0'
        $dbatoolsMod     = Get-Module -Name dbatools -ListAvailable |
                               Sort-Object Version -Descending |
                               Select-Object -First 1
        if (-not $dbatoolsMod) {
            throw 'dbatools is not installed. Run: Install-Module dbatools -Scope AllUsers'
        }
        if ($dbatoolsMod.Version -lt $requiredVersion) {
            Write-Warning "dbatools $($dbatoolsMod.Version) found; >= $requiredVersion recommended."
        }
        Import-Module dbatools -MinimumVersion $requiredVersion -ErrorAction Stop
        #endregion

        #region Initialization
        $ErrorActionPreference = 'Stop'
        $Script:ErrorCount     = 0
        $Script:WarningCount   = 0
        $Script:Results        = New-Object 'System.Collections.Generic.List[PSCustomObject]'
        $elapsedTime           = [System.Diagnostics.Stopwatch]::StartNew()
        $stepName              = 'Initialization'
        $collectedAt           = Get-Date

        if ($LoadGUID) {
            $runGUID = $LoadGUID
        }
        else {
            $runGUID = [guid]::NewGuid().ToString()
        }
        #endregion

        #region Credential Splat
        $credParam = @{}
        if ($SqlCredential) { $credParam['SqlCredential'] = $SqlCredential }

        $cmsCredParam = @{}
        if ($SqlCredential) { $cmsCredParam['SqlCredential'] = $SqlCredential }
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

        #region CMS Connection Test
        function Test-CMSConnection {
            try {
                $null = Connect-DbaInstance -SqlInstance $CMSInstanceName @cmsCredParam -ErrorAction Stop
                return $true
            }
            catch {
                return $false
            }
        }
        #endregion

        Write-DbaLog "Get-CentralWaitStats v$SCRIPT_VERSION started. LoadGUID: $runGUID"

        #region Stagger Delay
        if ($IntroduceDelay -eq 'Y') {
            $delay = Get-Random -Minimum $DelaySecMin -Maximum $DelaySecMax
            Write-DbaLog "Stagger delay: sleeping $delay seconds."
            Start-Sleep -Seconds $delay
        }
        #endregion

        #region Instance Discovery
        $stepName = 'Instance Discovery'
        if ($RunLocally) {
            Write-DbaLog 'RunLocally specified - resolving local instance from CMS.'

            if (-not $CMSInstanceName) {
                throw '-CMSInstanceName is required when -RunLocally is specified.'
            }

            if (-not (Test-CMSConnection)) {
                throw "CMS instance '$CMSInstanceName' is not reachable."
            }

            $localHost  = $env:COMPUTERNAME
            $targetRows = Invoke-DbaQuery `
                -SqlInstance $CMSInstanceName `
                -Database    $CMSDatabaseName `
                -Query       'EXEC [Svr].[usp_GetCollectionTargets] @CollectionType = @ct, @RunLocally = 1, @LocalServerName = @sn' `
                -SqlParameters @{ ct = 'WaitStats'; sn = $localHost } `
                -CommandTimeout $CommandTimeout `
                @cmsCredParam `
                -EnableException

            $SqlInstance = @($targetRows | ForEach-Object {
                $sv = $_.ServerName
                $in = $_.InstanceName
                if ($in -and $in -ne 'MSSQLSERVER') {
                    "$sv\$in"
                }
                else {
                    $sv
                }
            })
            Write-DbaLog "RunLocally resolved $($SqlInstance.Count) instance(s) for $localHost."
        }
        elseif ($CMSInstanceName -and (-not $SqlInstance)) {
            Write-DbaLog "No -SqlInstance provided - resolving from CMS '$CMSInstanceName'."

            if (-not (Test-CMSConnection)) {
                throw "CMS instance '$CMSInstanceName' is not reachable."
            }

            $targetRows = Invoke-DbaQuery `
                -SqlInstance $CMSInstanceName `
                -Database    $CMSDatabaseName `
                -Query       'EXEC [Svr].[usp_GetCollectionTargets] @CollectionType = @ct' `
                -SqlParameters @{ ct = 'WaitStats' } `
                -CommandTimeout $CommandTimeout `
                @cmsCredParam `
                -EnableException

            $SqlInstance = @($targetRows | ForEach-Object {
                $sv = $_.ServerName
                $in = $_.InstanceName
                if ($in -and $in -ne 'MSSQLSERVER') {
                    "$sv\$in"
                }
                else {
                    $sv
                }
            })
            Write-DbaLog "CMS discovery resolved $($SqlInstance.Count) instance(s)."
        }

        if (-not $SqlInstance -or $SqlInstance.Count -eq 0) {
            throw 'No target instances resolved. Provide -SqlInstance or configure -CMSInstanceName with registered servers.'
        }
        #endregion
    }

    # -------------------------------------------------------------------------
    process {
        $instanceErrors = New-Object 'System.Collections.Generic.List[string]'

        foreach ($instance in $SqlInstance) {

            # Extract hostname for stored proc calls
            $hostName = ($instance -split '[\\,]')[0]

            $stepName = "Connecting to $instance"
            Write-DbaLog "Processing $instance"

            try {
                # ------------------------------------------------------------------
                $stepName = "Collecting wait statistics from $instance"

                $waitParams = @{
                    SqlInstance     = $instance
                    CommandTimeout  = $CommandTimeout
                    EnableException = $true
                }
                if ($SqlCredential)      { $waitParams['SqlCredential']         = $SqlCredential }
                if ($IncludeSystemWaits) { $waitParams['IncludeIgnorable']      = $true }

                $waitData = Get-DbaWaitStatistic @waitParams

                if (-not $waitData) {
                    Write-DbaLog "No wait statistics returned from $instance - skipping." -Level WARN
                    continue
                }

                # Enrich with metadata required by [Inst].[WaitStats]
                $enriched = $waitData | Select-Object `
                    @{ n = 'ServerName';              e = { $hostName } },
                    @{ n = 'InstanceName';            e = { $instance } },
                    @{ n = 'WaitType';                e = { $_.WaitType } },
                    @{ n = 'Category';                e = { $_.Category } },
                    @{ n = 'Wait_S';                  e = { $_.WaitSeconds } },
                    @{ n = 'Resource_S';              e = { $_.ResourceSeconds } },
                    @{ n = 'Signal_S';                e = { $_.SignalSeconds } },
                    @{ n = 'WaitCount';               e = { $_.WaitCount } },
                    @{ n = 'Percentage';              e = { $_.Percentage } },
                    @{ n = 'AvgWait_S';               e = { $_.AverageWaitSeconds } },
                    @{ n = 'AvgRes_S';                e = { $_.AverageResourceSeconds } },
                    @{ n = 'AvgSig_S';                e = { $_.AverageSignalSeconds } },
                    @{ n = 'LoadGUID';                e = { $runGUID } },
                    @{ n = 'CollectedAt';             e = { $collectedAt } }

                Write-DbaLog "Collected $(@($enriched).Count) wait type(s) from $instance."

                # ------------------------------------------------------------------
                if ($PSCmdlet.ShouldProcess($instance, 'Write wait statistics to CentralDB')) {

                    $stepName = "Writing wait statistics from $instance to CentralDB"
                    try {
                        $enriched | Write-DbaDbTableData `
                            -SqlInstance $CMSInstanceName `
                            -Database    $CMSDatabaseName `
                            -Table       '[Inst].[WaitStats]' `
                            -AutoCreateTable `
                            @cmsCredParam `
                            -EnableException

                        Write-DbaLog "Centralized $(@($enriched).Count) row(s) from $instance."
                    }
                    catch {
                        Write-DbaLog "CMS write failed for $instance - $($_.Exception.Message)" -Level WARN
                        # Non-fatal: CMS failure must never kill the script
                    }

                    # ------------------------------------------------------------------
                    $stepName = "Updating collection timestamp for $instance in CentralDB"
                    try {
                        $instPart = if ($instance -match '\\') { ($instance -split '\\')[1] } else { 'MSSQLSERVER' }

                        Invoke-DbaQuery `
                            -SqlInstance $CMSInstanceName `
                            -Database    $CMSDatabaseName `
                            -Query       'EXEC [Svr].[usp_SetCollectionLastRun] @CollectionType = @ct, @ServerName = @sv, @InstanceName = @in, @LoadGUID = @lg' `
                            -SqlParameters @{
                                ct = 'WaitStats'
                                sv = $hostName
                                in = $instPart
                                lg = $runGUID
                            } `
                            -CommandTimeout $CommandTimeout `
                            @cmsCredParam `
                            -EnableException
                    }
                    catch {
                        Write-DbaLog "Failed to update collection timestamp for $instance - $($_.Exception.Message)" -Level WARN
                        # Non-fatal
                    }
                }

                # ------------------------------------------------------------------
                $Script:Results.Add([PSCustomObject]@{
                    PSTypeName      = 'CentralDB.WaitStatsResult'
                    SqlInstance     = $instance
                    RowsCollected   = @($enriched).Count
                    LoadGUID        = $runGUID
                    CollectedAt     = $collectedAt
                    Status          = 'Success'
                    ErrorMessage    = $null
                })

            }
            catch {
                $msg = "[$($stepName)] Failed on $($instance) - $($_.Exception.Message)"
                $instanceErrors.Add($msg)
                Write-DbaLog $msg -Level ERROR

                $Script:Results.Add([PSCustomObject]@{
                    PSTypeName      = 'CentralDB.WaitStatsResult'
                    SqlInstance     = $instance
                    RowsCollected   = 0
                    LoadGUID        = $runGUID
                    CollectedAt     = $collectedAt
                    Status          = 'Failed'
                    ErrorMessage    = $_.Exception.Message
                })

                continue
            }
        }

        # CRITICAL: throw aggregated errors so SQL Agent sees FAILURE
        if ($instanceErrors.Count -gt 0) {
            $summary = $instanceErrors -join "`n"
            throw "Get-CentralWaitStats completed with $($instanceErrors.Count) error(s):`n$summary"
        }
    }

    # -------------------------------------------------------------------------
    end {
        $elapsedTime.Stop()
        $duration = $elapsedTime.Elapsed.ToString('hh\:mm\:ss')

        if ($Script:ErrorCount -gt 0) {
            Write-Warning "Get-CentralWaitStats completed with $Script:ErrorCount error(s) in $duration. Review log."
        }
        else {
            Write-DbaLog "Get-CentralWaitStats completed successfully in $duration."
        }

        #region Export Output
        $exportFile = Join-Path $OutputPath ("WaitStats_$($env:COMPUTERNAME)_$(Get-Date -Format 'yyyyMMdd_HHmmss').$($OutputFormat.ToLower())")

        switch ($OutputFormat) {
            'CSV'      {
                $Script:Results | Export-Csv -Path $exportFile -NoTypeInformation
            }
            'JSON'     {
                $Script:Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $exportFile -Encoding utf8
            }
            'HTML'     {
                $Script:Results |
                    ConvertTo-Html -Title 'CentralDB Wait Stats Collection' |
                    Out-File -FilePath $exportFile -Encoding utf8
            }
            'GridView' {
                $Script:Results | Out-GridView -Title 'CentralDB Wait Stats Collection'
            }
            'Excel'    {
                if (Get-Module -Name ImportExcel -ListAvailable) {
                    $Script:Results | Export-Excel -Path $exportFile -AutoSize -FreezeTopRow
                }
                else {
                    Write-DbaLog 'ImportExcel module not found - falling back to CSV.' -Level WARN
                    $Script:Results | Export-Csv -Path ($exportFile -replace '\.excel$', '.csv') -NoTypeInformation
                }
            }
        }

        Write-DbaLog "Output written to $exportFile"
        #endregion

        # Emit results to pipeline
        $Script:Results
    }
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
Get-CentralWaitStats @invokeParams -Confirm:$false
