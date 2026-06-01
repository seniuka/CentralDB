# ============================================================================
# PART 1 - Script-level parameter block
#          Enables: powershell.exe -File Get-CentralBaselineStats.ps1 -Param Value
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
    [string]$LoadGUID
)

# ============================================================================
# PART 2 - Advanced function definition
# ============================================================================
function Get-CentralBaselineStats {
<#
.SYNOPSIS
    Collects SQL Server and OS baseline performance statistics and
    centralizes results into CentralDB.

.DESCRIPTION
    Replaces the legacy Get-BaselineStats.ps1 (SMO + SqlBulkCopy, 2017).

    Three collections per instance:

    SQL Instance Counters ([Inst].[InsBaselineStats]):
      Calls [Inst].[usp_GetBaselineStats] which takes two snapshots of
      sys.dm_os_performance_counters one second apart, calculates per-second
      delta rates, and returns a single pivoted row. Works on both Windows
      and Linux instances.

    Server OS Baseline ([Svr].[SvrBaselineStats]):
      Collects CPU %, Processor Queue Length, Avg Disk sec/Read and Write,
      Avg Disk Queue Length, Available MB, and Paging File % Usage via
      Get-Counter. Windows instances only - skipped gracefully for Linux.

    Server Drive Baseline ([Svr].[SvrBaselineDriveStats]):
      Per-physical-drive counters: % disk time, avg disk queue, avg disk
      read/write latency via Get-Counter. Windows instances only.

    Each collection has independent error handling. A failure in one
    section does not abort the remaining sections for that instance.
    CentralDB write failures are non-fatal (WARN only).

.PARAMETER SqlInstance
    One or more SQL Server instance names. Accepts pipeline input.
    If omitted, CMS discovery via -CMSInstanceName is used.

.PARAMETER SqlCredential
    PSCredential for SQL Server authentication. Required for Linux targets.

.PARAMETER CMSInstanceName
    The CentralDB instance. Used for target discovery and result storage.

.PARAMETER CMSDatabaseName
    CentralDB database name. Default: CentralDB.

.PARAMETER CommandTimeout
    Query timeout in seconds. Default: 600. Range: 60-86400.
    Note: [Inst].[usp_GetBaselineStats] includes a 1-second WAITFOR DELAY.
    Set CommandTimeout >= 10 to avoid false timeouts.

.PARAMETER IntroduceDelay
    Set to 'Y' to sleep a random interval before processing.
    Use in MSX/TSX jobs to stagger simultaneous CentralDB writes.

.PARAMETER DelaySecMin
    Minimum stagger delay in seconds. Default: 1.

.PARAMETER DelaySecMax
    Maximum stagger delay in seconds. Default: 300.

.PARAMETER RunLocally
    Restricts CMS discovery to the local machine only.

.PARAMETER OutputPath
    Directory for exported output files. Must already exist.

.PARAMETER OutputFormat
    Output format. Default: CSV.

.PARAMETER LoadGUID
    Correlation GUID. Generated automatically when omitted.

.EXAMPLE
    .\Get-CentralBaselineStats.ps1 -SqlInstance 'SQL-01' -CMSInstanceName 'CMS-01' -OutputPath 'D:\Logs' -WhatIf
    Dry-run against a single instance.

.EXAMPLE
    .\Get-CentralBaselineStats.ps1 -CMSInstanceName 'CMS-01' -RunLocally -OutputPath 'D:\Logs'
    MSX/TSX mode: collects only the local machine.

.EXAMPLE
    .\Get-CentralBaselineStats.ps1 -SqlInstance '10.0.1.196' -SqlCredential $cred -CMSInstanceName 'localhost' -OutputPath 'D:\Logs'
    Collect SQL counter baseline from a Linux target (OS section skipped automatically).

.NOTES
    Author      : DBA Engineering
    Created     : 2024-01-01
    Version     : 4.1.0
    Replaces    : CentralDB/Get-BaselineStats.ps1 (legacy SMO + SqlBulkCopy)
    Requirements: dbatools >= 2.0.0, PowerShell >= 5.1
    Impact      : LOW - read-only on targets, INSERT on CentralDB
    Schedule    : Every 15 minutes via SQL Agent

    Permissions :
        Target    : VIEW SERVER STATE (for sys.dm_os_performance_counters)
                    EXECUTE on [Inst].[usp_GetBaselineStats]
        CentralDB : EXECUTE on [Svr].[usp_GetCollectionTargets]
                    EXECUTE on [Svr].[usp_SetCollectionLastRun]
                    INSERT on [Inst].[InsBaselineStats]
                    INSERT on [Svr].[SvrBaselineStats]
                    INSERT on [Svr].[SvrBaselineDriveStats]

    SQL Agent Config :
        Job Step Type : CmdExec
        Run As        : Proxy 'DBA_Automation_Proxy'
        Command       : powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
                        -File "\\share\CentralDB\Collect\Get-CentralBaselineStats.ps1"
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
        [string]$LoadGUID
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

        if ($LoadGUID) { $runGUID = $LoadGUID }
        else           { $runGUID = [guid]::NewGuid().ToString() }
        #endregion

        #region Credential Splats
        $credParam = @{}
        if ($SqlCredential) { $credParam['SqlCredential'] = $SqlCredential }

        $cmsCredParam = @{}
        if ($SqlCredential) { $cmsCredParam['SqlCredential'] = $SqlCredential }
        #endregion

        #region Write-DbaLog Helper
        function Write-DbaLog {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory)][string]$Message,
                [Parameter()][ValidateSet('INFO','WARN','ERROR','DEBUG')][string]$Level = 'INFO'
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

        #region Write-ToCms Helper
        function Write-ToCms {
            param (
                [Parameter(Mandatory)][object]$Data,
                [Parameter(Mandatory)][string]$Table,
                [Parameter(Mandatory)][string]$Label
            )
            try {
                $Data | Write-DbaDbTableData `
                    -SqlInstance $CMSInstanceName `
                    -Database    $CMSDatabaseName `
                    -Table       $Table `
                    -AutoCreateTable `
                    @cmsCredParam `
                    -EnableException
                Write-DbaLog "[$Label] Wrote $(@($Data).Count) row(s) to $Table"
            }
            catch {
                Write-DbaLog "[$Label] CMS write to $Table failed - $($_.Exception.Message)" -Level WARN
                # Non-fatal: CMS failure must never kill collection
            }
        }
        #endregion

        #region CMS Connection Test
        function Test-CMSConnection {
            try {
                $null = Connect-DbaInstance -SqlInstance $CMSInstanceName @cmsCredParam -ErrorAction Stop
                return $true
            }
            catch { return $false }
        }
        #endregion

        Write-DbaLog "Get-CentralBaselineStats v$SCRIPT_VERSION started. LoadGUID: $runGUID"

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
            if (-not $CMSInstanceName) {
                throw '-CMSInstanceName is required when -RunLocally is specified.'
            }
            if (-not (Test-CMSConnection)) {
                throw "CMS instance '$CMSInstanceName' is not reachable."
            }
            $localHost  = $env:COMPUTERNAME
            $targetRows = Invoke-DbaQuery `
                -SqlInstance    $CMSInstanceName `
                -Database       $CMSDatabaseName `
                -Query          'EXEC [Svr].[usp_GetCollectionTargets] @CollectionType = @ct, @RunLocally = 1, @LocalServerName = @sn' `
                -SqlParameters  @{ ct = 'Baseline'; sn = $localHost } `
                -CommandTimeout $CommandTimeout `
                @cmsCredParam   -EnableException
            $SqlInstance = @($targetRows | ForEach-Object {
                $sv = $_.ServerName; $in = $_.InstanceName
                if ($in -and $in -ne 'MSSQLSERVER') { "$sv\$in" } else { $sv }
            })
            Write-DbaLog "RunLocally resolved $($SqlInstance.Count) instance(s) for $localHost."
        }
        elseif ($CMSInstanceName -and (-not $SqlInstance)) {
            if (-not (Test-CMSConnection)) {
                throw "CMS instance '$CMSInstanceName' is not reachable."
            }
            $targetRows = Invoke-DbaQuery `
                -SqlInstance    $CMSInstanceName `
                -Database       $CMSDatabaseName `
                -Query          'EXEC [Svr].[usp_GetCollectionTargets] @CollectionType = @ct' `
                -SqlParameters  @{ ct = 'Baseline' } `
                -CommandTimeout $CommandTimeout `
                @cmsCredParam   -EnableException
            $SqlInstance = @($targetRows | ForEach-Object {
                $sv = $_.ServerName; $in = $_.InstanceName
                if ($in -and $in -ne 'MSSQLSERVER') { "$sv\$in" } else { $sv }
            })
            Write-DbaLog "CMS discovery resolved $($SqlInstance.Count) instance(s)."
        }

        if (-not $SqlInstance -or $SqlInstance.Count -eq 0) {
            throw 'No target instances resolved. Provide -SqlInstance or configure -CMSInstanceName.'
        }
        #endregion
    }

    # -------------------------------------------------------------------------
    process {
        $instanceErrors = New-Object 'System.Collections.Generic.List[string]'

        foreach ($instance in $SqlInstance) {

            $hostName     = ($instance -split '[\\,]')[0]
            $instancePart = if ($instance -match '\\') { ($instance -split '\\')[1] } else { 'MSSQLSERVER' }

            Write-DbaLog "=== Begin baseline collection: $instance ==="

            # Detect platform
            $isWindows = $true
            try {
                $stepName   = "Platform detection for $instance"
                # No SqlParameters needed - pure literal query, no user input
                $platResult = Invoke-DbaQuery `
                    -SqlInstance    $instance `
                    -Query          "SELECT @@VERSION AS Ver" `
                    -CommandTimeout $CommandTimeout `
                    @credParam      -EnableException
                if ($platResult.Ver -match 'Linux') { $isWindows = $false }
                Write-DbaLog "Platform: $($isWindows ? 'Windows' : 'Linux')"
            }
            catch {
                $msg = "Platform detection failed for $($instance) - $($_.Exception.Message)"
                $instanceErrors.Add($msg)
                Write-DbaLog $msg -Level ERROR
                continue
            }

            $instanceSuccess = $true

            # =================================================================
            #region Collection 1: SQL Instance Counters (all platforms)
            # =================================================================
            $stepName = "SQL instance counters - $instance"
            try {
                Write-DbaLog "[SQLCounters] Collecting via [Inst].[usp_GetBaselineStats] on $instance"
                $sqlCounters = Invoke-DbaQuery `
                    -SqlInstance    $instance `
                    -Query          'EXEC [Inst].[usp_GetBaselineStats] @ServerName = @sv, @InstanceName = @in' `
                    -SqlParameters  @{ sv = $hostName; in = $instancePart } `
                    -CommandTimeout $CommandTimeout `
                    @credParam      -EnableException

                if ($sqlCounters) {
                    if ($PSCmdlet.ShouldProcess($instance, 'Write SQL counter baseline to CentralDB')) {
                        Write-ToCms -Data $sqlCounters -Table '[Inst].[InsBaselineStats]' -Label 'SQLCounters'
                    }
                }
                else {
                    Write-DbaLog '[SQLCounters] No rows returned from stored procedure.' -Level WARN
                }
            }
            catch {
                $instanceSuccess = $false
                Write-DbaLog "[SQLCounters] $($instance) - $($_.Exception.Message)" -Level ERROR
            }
            #endregion

            # =================================================================
            #region Collection 2: Server OS Baseline (Windows only)
            # =================================================================
            $stepName = "Server OS baseline - $instance"
            if (-not $isWindows) {
                Write-DbaLog '[SvrBaseline] Skipped - Linux instance.' -Level WARN
            }
            else {
                try {
                    Write-DbaLog "[SvrBaseline] Collecting PerfMon counters from $hostName"

                    # Processor counters
                    $procTotal = Get-Counter -Counter '\Processor(_total)\% Processor Time' `
                                             -ComputerName $hostName -ErrorAction Stop
                    $pctProcTm = $procTotal.CounterSamples[0].CookedValue

                    $procQueue = Get-Counter -Counter '\System\Processor Queue Length' `
                                             -ComputerName $hostName -ErrorAction Stop
                    $procQLen  = $procQueue.CounterSamples[0].CookedValue

                    # Disk counters
                    $dskRd    = Get-Counter -Counter '\PhysicalDisk(_total)\Avg. Disk sec/Read' `
                                            -ComputerName $hostName -ErrorAction Stop
                    $avDskRd  = $dskRd.CounterSamples[0].CookedValue

                    $dskWt    = Get-Counter -Counter '\PhysicalDisk(_total)\Avg. Disk sec/Write' `
                                            -ComputerName $hostName -ErrorAction Stop
                    $avDskWt  = $dskWt.CounterSamples[0].CookedValue

                    $dskQ     = Get-Counter -Counter '\PhysicalDisk(_total)\Avg. Disk Queue Length' `
                                            -ComputerName $hostName -ErrorAction Stop
                    $avDskQLen = $dskQ.CounterSamples[0].CookedValue

                    # Memory counters
                    $avlMB    = Get-Counter -Counter '\Memory\Available MBytes' `
                                            -ComputerName $hostName -ErrorAction Stop
                    $availMB  = $avlMB.CounterSamples[0].CookedValue

                    $pgFile   = Get-Counter -Counter '\Paging File(_total)\% Usage' `
                                            -ComputerName $hostName -ErrorAction Stop
                    $pgFlUsg  = $pgFile.CounterSamples[0].CookedValue

                    $svrRow = [PSCustomObject]@{
                        ServerName   = $hostName
                        InstanceName = $instance
                        PctProcTm    = [math]::Round($pctProcTm,  2)
                        ProcQLen     = [math]::Round($procQLen,    0)
                        AvDskRd      = [math]::Round($avDskRd,     6)
                        AvDskWt      = [math]::Round($avDskWt,     6)
                        AvDskQLen    = [math]::Round($avDskQLen,   2)
                        AvailMB      = [math]::Round($availMB,     0)
                        PgFlUsg      = [math]::Round($pgFlUsg,     2)
                        LoadGUID     = $runGUID
                        CollectedAt  = $collectedAt
                    }

                    if ($PSCmdlet.ShouldProcess($instance, 'Write server OS baseline to CentralDB')) {
                        Write-ToCms -Data $svrRow -Table '[Svr].[SvrBaselineStats]' -Label 'SvrBaseline'
                    }
                }
                catch {
                    Write-DbaLog "[SvrBaseline] $($instance) - $($_.Exception.Message)" -Level WARN
                    # Non-fatal: OS counter failure does not fail the instance
                }
            }
            #endregion

            # =================================================================
            #region Collection 3: Per-Drive Baseline (Windows only)
            # =================================================================
            $stepName = "Drive baseline - $instance"
            if (-not $isWindows) {
                Write-DbaLog '[DriveBaseline] Skipped - Linux instance.' -Level WARN
            }
            else {
                try {
                    Write-DbaLog "[DriveBaseline] Collecting per-drive counters from $hostName"

                    $driveCounters = @(
                        '\PhysicalDisk(*)\% Disk Time',
                        '\PhysicalDisk(*)\Avg. Disk Queue Length',
                        '\PhysicalDisk(*)\Avg. Disk sec/Read',
                        '\PhysicalDisk(*)\Avg. Disk sec/Write'
                    )

                    $rawCounters = Get-Counter -Counter $driveCounters `
                                               -ComputerName $hostName -ErrorAction Stop

                    $driveRows = $rawCounters.CounterSamples | Select-Object `
                        @{ n = 'ServerName';   e = { $hostName } },
                        @{ n = 'Drive';        e = {
                            if ($_.InstanceName -eq '_total') { 'Total' }
                            else {
                                $clean = $_.InstanceName.ToUpper() -replace '_', ''
                                if ($clean.Length -ge 2) { $clean.Substring($clean.Length - 2, 2) }
                                else { $clean }
                            }
                        }},
                        @{ n = 'CounterType';  e = { $_.Path.Substring($_.Path.LastIndexOf('\') + 1) } },
                        @{ n = 'Value';        e = { [math]::Round($_.CookedValue, 6) } },
                        @{ n = 'LoadGUID';     e = { $runGUID } },
                        @{ n = 'CollectedAt';  e = { $collectedAt } }

                    if ($PSCmdlet.ShouldProcess($instance, 'Write drive baseline to CentralDB')) {
                        Write-ToCms -Data $driveRows -Table '[Svr].[SvrBaselineDriveStats]' -Label 'DriveBaseline'
                    }
                }
                catch {
                    Write-DbaLog "[DriveBaseline] $($instance) - $($_.Exception.Message)" -Level WARN
                    # Non-fatal: drive counter failure does not fail the instance
                }
            }
            #endregion

            # =================================================================
            # Update CMS collection timestamp
            # =================================================================
            if ($PSCmdlet.ShouldProcess($instance, 'Update baseline collection timestamp in CentralDB')) {
                try {
                    Invoke-DbaQuery `
                        -SqlInstance    $CMSInstanceName `
                        -Database       $CMSDatabaseName `
                        -Query          'EXEC [Svr].[usp_SetCollectionLastRun] @CollectionType = @ct, @ServerName = @sv, @InstanceName = @in, @LoadGUID = @lg' `
                        -SqlParameters  @{ ct = 'Baseline'; sv = $hostName; in = $instancePart; lg = $runGUID } `
                        -CommandTimeout $CommandTimeout `
                        @cmsCredParam   -EnableException
                }
                catch {
                    Write-DbaLog "Failed to update collection timestamp for $($instance) - $($_.Exception.Message)" -Level WARN
                }
            }

            Write-DbaLog "=== Completed $instance ==="

            $Script:Results.Add([PSCustomObject]@{
                PSTypeName   = 'CentralDB.BaselineStatsResult'
                SqlInstance  = $instance
                IsWindows    = $isWindows
                LoadGUID     = $runGUID
                CollectedAt  = $collectedAt
                Status       = if ($instanceSuccess) { 'Success' } else { 'PartialSuccess' }
                ErrorMessage = $null
            })
        }

        if ($instanceErrors.Count -gt 0) {
            $summary = $instanceErrors -join "`n"
            throw "Get-CentralBaselineStats completed with $($instanceErrors.Count) instance error(s):`n$summary"
        }
    }

    # -------------------------------------------------------------------------
    end {
        $elapsedTime.Stop()
        $duration = $elapsedTime.Elapsed.ToString('hh\:mm\:ss')

        if ($Script:ErrorCount -gt 0) {
            Write-Warning "Get-CentralBaselineStats completed with $Script:ErrorCount error(s) in $duration."
        }
        else {
            Write-DbaLog "Get-CentralBaselineStats completed successfully in $duration."
        }

        #region Export Output
        $exportBase = Join-Path $OutputPath ("BaselineStats_$($env:COMPUTERNAME)_$(Get-Date -Format 'yyyyMMdd_HHmmss')")

        switch ($OutputFormat) {
            'CSV'      { $Script:Results | Export-Csv -Path "$exportBase.csv"  -NoTypeInformation }
            'JSON'     { $Script:Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$exportBase.json" -Encoding utf8 }
            'HTML'     { $Script:Results | ConvertTo-Html -Title 'CentralDB Baseline Stats' | Out-File -FilePath "$exportBase.html" -Encoding utf8 }
            'GridView' { $Script:Results | Out-GridView -Title 'CentralDB Baseline Stats' }
            'Excel'    {
                if (Get-Module -Name ImportExcel -ListAvailable) {
                    $Script:Results | Export-Excel -Path "$exportBase.xlsx" -AutoSize -FreezeTopRow
                }
                else {
                    Write-DbaLog 'ImportExcel not found - falling back to CSV.' -Level WARN
                    $Script:Results | Export-Csv -Path "$exportBase.csv" -NoTypeInformation
                }
            }
        }

        Write-DbaLog "Output written to $exportBase.$($OutputFormat.ToLower())"
        #endregion

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
Get-CentralBaselineStats @invokeParams -Confirm:$false
