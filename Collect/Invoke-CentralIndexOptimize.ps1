# ============================================================================
# PART 1 - Script-level parameter block
# ============================================================================
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param (
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
    [string[]]$SqlInstance,
    [Parameter()][PSCredential]$SqlCredential,
    [Parameter()][string]$CMSInstanceName,
    [Parameter()][ValidateNotNullOrEmpty()][string]$CMSDatabaseName = 'CentralDB',
    [Parameter()][ValidateRange(60, 86400)][int]$CommandTimeout = 14400,
    [Parameter()][ValidateSet('Y', 'N')][string]$IntroduceDelay = 'N',
    [Parameter()][ValidateRange(1, 3600)][int]$DelaySecMin = 1,
    [Parameter()][ValidateRange(1, 3600)][int]$DelaySecMax = 300,
    [Parameter()][switch]$RunLocally,
    [Parameter(Mandatory)][ValidateScript({ Test-Path $_ -PathType Container })][string]$OutputPath,
    [Parameter()][ValidateSet('CSV', 'HTML', 'JSON', 'Excel', 'GridView')][string]$OutputFormat = 'CSV',
    [Parameter()][string]$LoadGUID,
    [Parameter()][ValidateSet('Y', 'N')][string]$DeployOla = 'N',
    [Parameter()][ValidateNotNullOrEmpty()][string]$OlaDatabase = 'master',
    [Parameter()][string]$Databases = 'USER_DATABASES',
    [Parameter()][string]$FragmentationLow = $null,
    [Parameter()][string]$FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
    [Parameter()][string]$FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
    [Parameter()][int]$FragmentationLevel1 = 5,
    [Parameter()][int]$FragmentationLevel2 = 30,
    [Parameter()][int]$PageCountLevel,
    [Parameter()][ValidateSet('Y', 'N')][string]$SortInTempdb = 'Y',
    [Parameter()][int]$MaxDOP,
    [Parameter()][ValidateSet('Y', 'N')][string]$LOBCompaction = 'Y',
    [Parameter()][ValidateSet('ALL', 'COLUMNS', 'INDEX')][string]$UpdateStatistics,
    [Parameter()][ValidateSet('Y', 'N')][string]$OnlyModifiedStatistics = 'N',
    [Parameter()][string]$Indexes,
    [Parameter()][int]$TimeLimit,
    [Parameter()][string]$AvailabilityGroups,
    [Parameter()][ValidateSet('ALL', 'PRIMARY', 'SECONDARY', 'PREFERRED_BACKUP_REPLICA')][string]$Updateability = 'ALL'
)

# ============================================================================
# PART 2 - Advanced function definition
# ============================================================================
function Invoke-CentralIndexOptimize {
<#
.SYNOPSIS
    Executes Ola Hallengren IndexOptimize against one or more SQL Server
    instances and centralizes the CommandLog results into CentralDB.

.DESCRIPTION
    Replaces the legacy Get-OlaHallengren-Index.ps1 (raw SqlClient, 2017).

    Two phases per instance:

    Deploy (optional, -DeployOla Y):
      Calls Install-DbaMaintenanceSolution to install/update Ola's solution.

    Execute and Collect:
      Calls IndexOptimize via Invoke-DbaQuery with @LogToTable = 'Y'.
      Queries CommandLog filtered by LoadGUID, centralizes to CentralDB,
      then cleans up local CommandLog rows.

    CentralDB write failures are non-fatal (WARN only).

.PARAMETER SqlInstance
    Target SQL Server instances. Accepts pipeline input.

.PARAMETER SqlCredential
    PSCredential for SQL Server authentication.

.PARAMETER CMSInstanceName
    CentralDB instance for target discovery and result storage.

.PARAMETER CMSDatabaseName
    CentralDB database name. Default: CentralDB.

.PARAMETER CommandTimeout
    Query timeout in seconds. Default: 14400 (4 hours).

.PARAMETER IntroduceDelay
    Set to 'Y' to sleep a random interval before processing.

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

.PARAMETER DeployOla
    Set to 'Y' to install/update Ola's solution before running. Default: 'N'.

.PARAMETER OlaDatabase
    Database where Ola's solution is installed. Default: master.

.PARAMETER Databases
    Ola @Databases parameter. Default: USER_DATABASES.

.PARAMETER FragmentationLow
    Action for indexes with fragmentation below FragmentationLevel1.

.PARAMETER FragmentationMedium
    Action for indexes between levels 1 and 2.
    Default: INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE.

.PARAMETER FragmentationHigh
    Action for indexes above FragmentationLevel2.
    Default: INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE.

.PARAMETER FragmentationLevel1
    Lower fragmentation threshold %. Default: 5.

.PARAMETER FragmentationLevel2
    Upper fragmentation threshold %. Default: 30.

.PARAMETER PageCountLevel
    Minimum page count for an index to be considered. Default: Ola default.

.PARAMETER SortInTempdb
    Sort intermediate results in tempdb. Y or N. Default: Y.

.PARAMETER MaxDOP
    Max degree of parallelism for the operation.

.PARAMETER LOBCompaction
    Compact LOB pages during REORGANIZE. Y or N. Default: Y.

.PARAMETER UpdateStatistics
    Update statistics. ALL, COLUMNS, or INDEX.

.PARAMETER OnlyModifiedStatistics
    Only update statistics that have been modified. Y or N. Default: N.

.PARAMETER Indexes
    Comma-separated list of specific indexes to process.

.PARAMETER TimeLimit
    Maximum runtime in seconds.

.PARAMETER AvailabilityGroups
    Ola @AvailabilityGroups filter.

.PARAMETER Updateability
    Which AG replicas to process. Default: ALL.

.EXAMPLE
    .\Invoke-CentralIndexOptimize.ps1 -SqlInstance 'SQL-01' -CMSInstanceName 'CMS-01' -OutputPath 'D:\Logs' -WhatIf
    Dry-run. No index operations are performed.

.EXAMPLE
    .\Invoke-CentralIndexOptimize.ps1 -CMSInstanceName 'CMS-01' -RunLocally -OutputPath 'D:\Logs'
    MSX/TSX mode: index optimize on local machine user databases.

.NOTES
    Author      : DBA Engineering
    Created     : 2024-01-01
    Version     : 4.1.0
    Replaces    : CentralDB/Get-OlaHallengren-Index.ps1
    Requirements: dbatools >= 2.0.0, PowerShell >= 5.1
                  Ola Hallengren maintenance solution (or -DeployOla Y)
    Impact      : HIGH - rebuilds/reorganizes indexes
    Schedule    : Weekly via SQL Agent

    Permissions :
        Target    : db_owner on user databases
        CentralDB : EXECUTE on [Svr].[usp_GetCollectionTargets]
                    EXECUTE on [Svr].[usp_SetCollectionLastRun]
                    INSERT on [Inst].[CommandLog]

    SQL Agent Config :
        Job Step Type : CmdExec
        Run As        : Proxy 'DBA_Automation_Proxy'
        Command       : powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
                        -File "\\share\CentralDB\Collect\Invoke-CentralIndexOptimize.ps1"
                        -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))"
                        -RunLocally
                        -OutputPath "D:\Logs\CentralDB"

    Attribution:
        IndexOptimize is created and maintained by Ola Hallengren.
        https://ola.hallengren.com
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [string[]]$SqlInstance,
        [Parameter()][PSCredential]$SqlCredential,
        [Parameter()][string]$CMSInstanceName,
        [Parameter()][ValidateNotNullOrEmpty()][string]$CMSDatabaseName = 'CentralDB',
        [Parameter()][ValidateRange(60, 86400)][int]$CommandTimeout = 14400,
        [Parameter()][ValidateSet('Y', 'N')][string]$IntroduceDelay = 'N',
        [Parameter()][ValidateRange(1, 3600)][int]$DelaySecMin = 1,
        [Parameter()][ValidateRange(1, 3600)][int]$DelaySecMax = 300,
        [Parameter()][switch]$RunLocally,
        [Parameter(Mandatory)][ValidateScript({ Test-Path $_ -PathType Container })][string]$OutputPath,
        [Parameter()][ValidateSet('CSV', 'HTML', 'JSON', 'Excel', 'GridView')][string]$OutputFormat = 'CSV',
        [Parameter()][string]$LoadGUID,
        [Parameter()][ValidateSet('Y', 'N')][string]$DeployOla = 'N',
        [Parameter()][ValidateNotNullOrEmpty()][string]$OlaDatabase = 'master',
        [Parameter()][string]$Databases = 'USER_DATABASES',
        [Parameter()][string]$FragmentationLow = $null,
        [Parameter()][string]$FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
        [Parameter()][string]$FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
        [Parameter()][int]$FragmentationLevel1 = 5,
        [Parameter()][int]$FragmentationLevel2 = 30,
        [Parameter()][int]$PageCountLevel,
        [Parameter()][ValidateSet('Y', 'N')][string]$SortInTempdb = 'Y',
        [Parameter()][int]$MaxDOP,
        [Parameter()][ValidateSet('Y', 'N')][string]$LOBCompaction = 'Y',
        [Parameter()][ValidateSet('ALL', 'COLUMNS', 'INDEX')][string]$UpdateStatistics,
        [Parameter()][ValidateSet('Y', 'N')][string]$OnlyModifiedStatistics = 'N',
        [Parameter()][string]$Indexes,
        [Parameter()][int]$TimeLimit,
        [Parameter()][string]$AvailabilityGroups,
        [Parameter()][ValidateSet('ALL', 'PRIMARY', 'SECONDARY', 'PREFERRED_BACKUP_REPLICA')][string]$Updateability = 'ALL'
    )

    begin {
        #region Module Check
        $SCRIPT_VERSION  = '4.1.0'
        $requiredVersion = [Version]'2.0.0'
        $dbatoolsMod     = Get-Module -Name dbatools -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
        if (-not $dbatoolsMod)                        { throw 'dbatools is not installed. Run: Install-Module dbatools -Scope AllUsers' }
        if ($dbatoolsMod.Version -lt $requiredVersion){ Write-Warning "dbatools $($dbatoolsMod.Version) found; >= $requiredVersion recommended." }
        Import-Module dbatools -MinimumVersion $requiredVersion -ErrorAction Stop
        #endregion

        #region Init
        $ErrorActionPreference = 'Stop'
        $Script:ErrorCount     = 0
        $Script:WarningCount   = 0
        $Script:Results        = New-Object 'System.Collections.Generic.List[PSCustomObject]'
        $elapsedTime           = [System.Diagnostics.Stopwatch]::StartNew()
        $stepName              = 'Initialization'
        $collectedAt           = Get-Date
        if ($LoadGUID) { $runGUID = $LoadGUID } else { $runGUID = [guid]::NewGuid().ToString() }
        $credParam    = @{}; if ($SqlCredential) { $credParam['SqlCredential']    = $SqlCredential }
        $cmsCredParam = @{}; if ($SqlCredential) { $cmsCredParam['SqlCredential'] = $SqlCredential }
        #endregion

        #region Helpers
        function Write-DbaLog {
            param([Parameter(Mandatory)][string]$Message, [ValidateSet('INFO','WARN','ERROR','DEBUG')][string]$Level = 'INFO')
            $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            switch ($Level) {
                'INFO'  { Write-Verbose  "[$ts] [INFO]  $Message" }
                'WARN'  { Write-Warning  "[$ts] [WARN]  $Message"; $Script:WarningCount++ }
                'ERROR' { Write-Warning  "[$ts] [ERROR] $Message"; $Script:ErrorCount++ }
                'DEBUG' { Write-Debug    "[$ts] [DEBUG] $Message" }
            }
        }
        function Write-ToCms {
            param([Parameter(Mandatory)][object]$Data, [Parameter(Mandatory)][string]$Table, [Parameter(Mandatory)][string]$Label)
            try {
                $Data | Write-DbaDbTableData -SqlInstance $CMSInstanceName -Database $CMSDatabaseName -Table $Table -AutoCreateTable @cmsCredParam -EnableException
                Write-DbaLog "[$Label] Wrote $(@($Data).Count) row(s) to $Table"
            }
            catch { Write-DbaLog "[$Label] CMS write to $Table failed - $($_.Exception.Message)" -Level WARN } # Non-fatal
        }
        function Test-CMSConnection {
            try { $null = Connect-DbaInstance -SqlInstance $CMSInstanceName @cmsCredParam -ErrorAction Stop; return $true }
            catch { return $false }
        }
        #endregion

        Write-DbaLog "Invoke-CentralIndexOptimize v$SCRIPT_VERSION started. LoadGUID: $runGUID"

        if ($IntroduceDelay -eq 'Y') {
            $delay = Get-Random -Minimum $DelaySecMin -Maximum $DelaySecMax
            Write-DbaLog "Stagger delay: $delay seconds."; Start-Sleep -Seconds $delay
        }

        #region Instance Discovery
        $stepName = 'Instance Discovery'
        if ($RunLocally) {
            if (-not $CMSInstanceName) { throw '-CMSInstanceName is required when -RunLocally is specified.' }
            if (-not (Test-CMSConnection)) { throw "CMS instance '$CMSInstanceName' is not reachable." }
            $localHost = $env:COMPUTERNAME
            $rows = Invoke-DbaQuery -SqlInstance $CMSInstanceName -Database $CMSDatabaseName `
                -Query 'EXEC [Svr].[usp_GetCollectionTargets] @CollectionType = @ct, @RunLocally = 1, @LocalServerName = @sn' `
                -SqlParameters @{ ct = 'Baseline'; sn = $localHost } -CommandTimeout $CommandTimeout @cmsCredParam -EnableException
            $SqlInstance = @($rows | ForEach-Object { $sv=$_.ServerName; $in=$_.InstanceName; if ($in -and $in -ne 'MSSQLSERVER') { "$sv\$in" } else { $sv } })
        }
        elseif ($CMSInstanceName -and (-not $SqlInstance)) {
            if (-not (Test-CMSConnection)) { throw "CMS instance '$CMSInstanceName' is not reachable." }
            $rows = Invoke-DbaQuery -SqlInstance $CMSInstanceName -Database $CMSDatabaseName `
                -Query 'EXEC [Svr].[usp_GetCollectionTargets] @CollectionType = @ct' `
                -SqlParameters @{ ct = 'Baseline' } -CommandTimeout $CommandTimeout @cmsCredParam -EnableException
            $SqlInstance = @($rows | ForEach-Object { $sv=$_.ServerName; $in=$_.InstanceName; if ($in -and $in -ne 'MSSQLSERVER') { "$sv\$in" } else { $sv } })
        }
        if (-not $SqlInstance -or $SqlInstance.Count -eq 0) { throw 'No target instances resolved.' }
        #endregion
    }

    process {
        $instanceErrors = New-Object 'System.Collections.Generic.List[string]'

        foreach ($instance in $SqlInstance) {
            $hostName     = ($instance -split '[\\,]')[0]
            $instancePart = if ($instance -match '\\') { ($instance -split '\\')[1] } else { 'MSSQLSERVER' }
            Write-DbaLog "=== Begin index optimize: $instance ==="

            try {
                # Phase 1: Optional deploy
                if ($DeployOla -eq 'Y') {
                    $stepName = "Deploy Ola on $instance"
                    if ($PSCmdlet.ShouldProcess($instance, 'Install/update Ola Hallengren maintenance solution')) {
                        try {
                            Install-DbaMaintenanceSolution -SqlInstance $instance -Database $OlaDatabase @credParam -EnableException | Out-Null
                            Write-DbaLog "[Deploy] Ola installed/updated on $instance.$OlaDatabase"
                        }
                        catch { Write-DbaLog "[Deploy] Failed on $($instance) - $($_.Exception.Message)" -Level WARN }
                    }
                }

                # Phase 2: Verify IndexOptimize exists
                $stepName  = "Verify IndexOptimize on $instance"
                $procCheck = Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                    -Query "SELECT COUNT(1) AS Cnt FROM sys.objects WHERE name = 'IndexOptimize' AND type = 'P'" `
                    -CommandTimeout 60 @credParam -EnableException
                if ($procCheck.Cnt -eq 0) {
                    Write-DbaLog "[Index] IndexOptimize not found on $instance.$OlaDatabase. Use -DeployOla Y." -Level WARN
                    $Script:Results.Add([PSCustomObject]@{ PSTypeName='CentralDB.IndexResult'; SqlInstance=$instance; RowsCollected=0; LoadGUID=$runGUID; CollectedAt=$collectedAt; Status='Skipped'; ErrorMessage="IndexOptimize not found on $OlaDatabase" })
                    continue
                }

                # Phase 3: Build and execute IndexOptimize
                $stepName = "Execute IndexOptimize on $instance"
                if ($PSCmdlet.ShouldProcess($instance, "Execute IndexOptimize ($Databases)")) {

                    $olaParams  = "@Databases = '$Databases', @LogToTable = 'Y', @Execute = 'Y'"
                    $olaParams += ", @LoadGUID = '$runGUID'"
                    $olaParams += ", @FragmentationLevel1 = $FragmentationLevel1"
                    $olaParams += ", @FragmentationLevel2 = $FragmentationLevel2"
                    $olaParams += ", @SortInTempdb = '$SortInTempdb'"
                    $olaParams += ", @LOBCompaction = '$LOBCompaction'"
                    $olaParams += ", @OnlyModifiedStatistics = '$OnlyModifiedStatistics'"
                    $olaParams += ", @Updateability = '$Updateability'"
                    if ($FragmentationLow)    { $olaParams += ", @FragmentationLow = '$FragmentationLow'" }
                    if ($FragmentationMedium) { $olaParams += ", @FragmentationMedium = '$FragmentationMedium'" }
                    if ($FragmentationHigh)   { $olaParams += ", @FragmentationHigh = '$FragmentationHigh'" }
                    if ($PageCountLevel)      { $olaParams += ", @PageCountLevel = $PageCountLevel" }
                    if ($MaxDOP)              { $olaParams += ", @MaxDOP = $MaxDOP" }
                    if ($UpdateStatistics)    { $olaParams += ", @UpdateStatistics = '$UpdateStatistics'" }
                    if ($Indexes)             { $olaParams += ", @Indexes = '$Indexes'" }
                    if ($TimeLimit)           { $olaParams += ", @TimeLimit = $TimeLimit" }
                    if ($AvailabilityGroups)  { $olaParams += ", @AvailabilityGroups = '$AvailabilityGroups'" }

                    Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                        -Query "EXEC dbo.IndexOptimize $olaParams" `
                        -CommandTimeout $CommandTimeout @credParam -EnableException | Out-Null
                    Write-DbaLog "[Index] IndexOptimize completed on $instance"

                    # Collect and centralize
                    $logRows = Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                        -Query 'SELECT * FROM dbo.CommandLog WHERE LoadGUID = @lg' `
                        -SqlParameters @{ lg = $runGUID } -CommandTimeout 60 @credParam -EnableException
                    if ($logRows) {
                        $enriched = $logRows | Select-Object @{ n='CollectionServerName'; e={ $hostName } }, @{ n='CollectionInstance'; e={ $instance } }, @{ n='LoadGUID'; e={ $runGUID } }, @{ n='CollectedAt'; e={ $collectedAt } }, *
                        Write-ToCms -Data $enriched -Table '[Inst].[CommandLog]' -Label 'Index'
                    }

                    # Cleanup
                    try {
                        Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                            -Query 'DELETE FROM dbo.CommandLog WHERE LoadGUID = @lg' `
                            -SqlParameters @{ lg = $runGUID } -CommandTimeout 60 @credParam -EnableException | Out-Null
                        Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                            -Query 'DELETE FROM dbo.CommandLog WHERE EndTime <= DATEADD(DAY, -1, GETDATE())' `
                            -CommandTimeout 60 @credParam -EnableException | Out-Null
                    }
                    catch { Write-DbaLog "[Index] CommandLog cleanup failed on $($instance) - $($_.Exception.Message)" -Level WARN }

                    $Script:Results.Add([PSCustomObject]@{ PSTypeName='CentralDB.IndexResult'; SqlInstance=$instance; RowsCollected=@($logRows).Count; LoadGUID=$runGUID; CollectedAt=$collectedAt; Status='Success'; ErrorMessage=$null })
                }

                try {
                    Invoke-DbaQuery -SqlInstance $CMSInstanceName -Database $CMSDatabaseName `
                        -Query 'EXEC [Svr].[usp_SetCollectionLastRun] @CollectionType = @ct, @ServerName = @sv, @InstanceName = @in, @LoadGUID = @lg' `
                        -SqlParameters @{ ct='Baseline'; sv=$hostName; in=$instancePart; lg=$runGUID } `
                        -CommandTimeout $CommandTimeout @cmsCredParam -EnableException
                }
                catch { Write-DbaLog "Failed to update collection timestamp for $($instance) - $($_.Exception.Message)" -Level WARN }

                Write-DbaLog "=== Completed $instance ==="
            }
            catch {
                $msg = "[$($stepName)] Failed on $($instance) - $($_.Exception.Message)"
                $instanceErrors.Add($msg)
                Write-DbaLog $msg -Level ERROR
                $Script:Results.Add([PSCustomObject]@{ PSTypeName='CentralDB.IndexResult'; SqlInstance=$instance; RowsCollected=0; LoadGUID=$runGUID; CollectedAt=$collectedAt; Status='Failed'; ErrorMessage=$_.Exception.Message })
                continue
            }
        }

        if ($instanceErrors.Count -gt 0) {
            throw "Invoke-CentralIndexOptimize completed with $($instanceErrors.Count) instance error(s):`n$($instanceErrors -join "`n")"
        }
    }

    end {
        $elapsedTime.Stop()
        $duration = $elapsedTime.Elapsed.ToString('hh\:mm\:ss')
        if ($Script:ErrorCount -gt 0) { Write-Warning "Invoke-CentralIndexOptimize completed with $Script:ErrorCount error(s) in $duration." }
        else { Write-DbaLog "Invoke-CentralIndexOptimize completed successfully in $duration." }
        $exportBase = Join-Path $OutputPath ("IndexOptimize_$($env:COMPUTERNAME)_$(Get-Date -Format 'yyyyMMdd_HHmmss')")
        switch ($OutputFormat) {
            'CSV'      { $Script:Results | Export-Csv -Path "$exportBase.csv" -NoTypeInformation }
            'JSON'     { $Script:Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$exportBase.json" -Encoding utf8 }
            'HTML'     { $Script:Results | ConvertTo-Html -Title 'CentralDB Index Optimize' | Out-File -FilePath "$exportBase.html" -Encoding utf8 }
            'GridView' { $Script:Results | Out-GridView -Title 'CentralDB Index Optimize' }
            'Excel'    {
                if (Get-Module -Name ImportExcel -ListAvailable) { $Script:Results | Export-Excel -Path "$exportBase.xlsx" -AutoSize -FreezeTopRow }
                else { Write-DbaLog 'ImportExcel not found - falling back to CSV.' -Level WARN; $Script:Results | Export-Csv -Path "$exportBase.csv" -NoTypeInformation }
            }
        }
        Write-DbaLog "Output written to $exportBase.$($OutputFormat.ToLower())"
        $Script:Results
    }
}

# ============================================================================
# PART 3 - AUTO-INVOCATION
# ============================================================================
$invokeParams = @{}
foreach ($key in $PSBoundParameters.Keys) {
    if ($key -notin 'Confirm', 'WhatIf') { $invokeParams[$key] = $PSBoundParameters[$key] }
}
Invoke-CentralIndexOptimize @invokeParams -Confirm:$false
