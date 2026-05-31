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
    [Parameter()][string]$Databases = 'ALL_DATABASES',
    [Parameter()][ValidateSet('CHECKDB', 'CHECKFILEGROUP', 'CHECKTABLE', 'CHECKALLOC', 'CHECKCATALOG')][string]$CheckCommands = 'CHECKDB',
    [Parameter()][ValidateSet('Y', 'N')][string]$PhysicalOnly = 'Y',
    [Parameter()][ValidateSet('Y', 'N')][string]$NoIndex = 'N',
    [Parameter()][ValidateSet('Y', 'N')][string]$ExtendedLogicalChecks = 'N',
    [Parameter()][ValidateSet('Y', 'N')][string]$TabLock = 'N',
    [Parameter()][int]$MaxDOP,
    [Parameter()][string]$AvailabilityGroups,
    [Parameter()][ValidateSet('ALL', 'PRIMARY', 'SECONDARY', 'PREFERRED_BACKUP_REPLICA')][string]$AvailabilityGroupReplicas = 'ALL',
    [Parameter()][ValidateSet('ALL', 'READ_WRITE', 'READ_ONLY')][string]$Updateability = 'ALL',
    [Parameter()][int]$TimeLimit,
    [Parameter()][int]$LockTimeout = 10800,
    [Parameter()][ValidateSet('Y', 'N')][string]$DatabasesInParallel = 'N'
)

# ============================================================================
# PART 2 - Advanced function definition
# ============================================================================
function Invoke-CentralIntegrityCheck {
<#
.SYNOPSIS
    Executes Ola Hallengren DatabaseIntegrityCheck against one or more SQL
    Server instances and centralizes the CommandLog results into CentralDB.

.DESCRIPTION
    Replaces the legacy Get-OlaHallengren-Integrity.ps1 (raw SqlClient, 2017).

    Two phases per instance:

    Deploy (optional, -DeployOla Y):
      Calls Install-DbaMaintenanceSolution to install/update Ola's solution.

    Execute and Collect:
      Calls DatabaseIntegrityCheck via Invoke-DbaQuery with @LogToTable = 'Y'.
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
    Ola @Databases parameter. Default: ALL_DATABASES.

.PARAMETER CheckCommands
    DBCC command to run. Default: CHECKDB.
    Options: CHECKDB, CHECKFILEGROUP, CHECKTABLE, CHECKALLOC, CHECKCATALOG.

.PARAMETER PhysicalOnly
    Limit check to physical structure. Y or N. Default: Y.

.PARAMETER NoIndex
    Skip non-clustered index checks. Y or N. Default: N.

.PARAMETER ExtendedLogicalChecks
    Run extended logical checks. Y or N. Default: N.

.PARAMETER TabLock
    Use table locks during check. Y or N. Default: N.

.PARAMETER MaxDOP
    Max degree of parallelism for CHECKDB.

.PARAMETER AvailabilityGroups
    Ola @AvailabilityGroups filter.

.PARAMETER AvailabilityGroupReplicas
    Which AG replicas to check. Default: ALL.

.PARAMETER Updateability
    ALL, READ_WRITE, or READ_ONLY. Default: ALL.

.PARAMETER TimeLimit
    Maximum runtime in seconds.

.PARAMETER LockTimeout
    Lock wait timeout in seconds. Default: 10800 (3 hours).

.PARAMETER DatabasesInParallel
    Run checks on multiple databases in parallel. Y or N. Default: N.

.EXAMPLE
    .\Invoke-CentralIntegrityCheck.ps1 -SqlInstance 'SQL-01' -CMSInstanceName 'CMS-01' -OutputPath 'D:\Logs' -WhatIf
    Dry-run. No DBCC commands are executed.

.EXAMPLE
    .\Invoke-CentralIntegrityCheck.ps1 -CMSInstanceName 'CMS-01' -RunLocally -OutputPath 'D:\Logs'
    MSX/TSX mode: CHECKDB on all databases on the local instance.

.NOTES
    Author      : DBA Engineering
    Created     : 2024-01-01
    Version     : 4.1.0
    Replaces    : CentralDB/Get-OlaHallengren-Integrity.ps1
    Requirements: dbatools >= 2.0.0, PowerShell >= 5.1
                  Ola Hallengren maintenance solution (or -DeployOla Y)
    Impact      : HIGH - runs DBCC CHECKDB, generates I/O load
    Schedule    : Weekly via SQL Agent (recommended: off-peak weekend)

    Permissions :
        Target    : db_owner on checked databases, VIEW SERVER STATE
        CentralDB : EXECUTE on [Svr].[usp_GetCollectionTargets]
                    EXECUTE on [Svr].[usp_SetCollectionLastRun]
                    INSERT on [Inst].[CommandLog]

    SQL Agent Config :
        Job Step Type : CmdExec
        Run As        : Proxy 'DBA_Automation_Proxy'
        Command       : powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
                        -File "\\share\CentralDB\Collect\Invoke-CentralIntegrityCheck.ps1"
                        -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))"
                        -RunLocally
                        -OutputPath "D:\Logs\CentralDB"

    Attribution:
        DatabaseIntegrityCheck is created and maintained by Ola Hallengren.
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
        [Parameter()][string]$Databases = 'ALL_DATABASES',
        [Parameter()][ValidateSet('CHECKDB', 'CHECKFILEGROUP', 'CHECKTABLE', 'CHECKALLOC', 'CHECKCATALOG')][string]$CheckCommands = 'CHECKDB',
        [Parameter()][ValidateSet('Y', 'N')][string]$PhysicalOnly = 'Y',
        [Parameter()][ValidateSet('Y', 'N')][string]$NoIndex = 'N',
        [Parameter()][ValidateSet('Y', 'N')][string]$ExtendedLogicalChecks = 'N',
        [Parameter()][ValidateSet('Y', 'N')][string]$TabLock = 'N',
        [Parameter()][int]$MaxDOP,
        [Parameter()][string]$AvailabilityGroups,
        [Parameter()][ValidateSet('ALL', 'PRIMARY', 'SECONDARY', 'PREFERRED_BACKUP_REPLICA')][string]$AvailabilityGroupReplicas = 'ALL',
        [Parameter()][ValidateSet('ALL', 'READ_WRITE', 'READ_ONLY')][string]$Updateability = 'ALL',
        [Parameter()][int]$TimeLimit,
        [Parameter()][int]$LockTimeout = 10800,
        [Parameter()][ValidateSet('Y', 'N')][string]$DatabasesInParallel = 'N'
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

        Write-DbaLog "Invoke-CentralIntegrityCheck v$SCRIPT_VERSION started. LoadGUID: $runGUID | Command: $CheckCommands"

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
            Write-DbaLog "=== Begin integrity check: $instance ($CheckCommands) ==="

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

                # Phase 2: Verify DatabaseIntegrityCheck exists
                $stepName  = "Verify DatabaseIntegrityCheck on $instance"
                $procCheck = Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                    -Query "SELECT COUNT(1) AS Cnt FROM sys.objects WHERE name = 'DatabaseIntegrityCheck' AND type = 'P'" `
                    -CommandTimeout 60 @credParam -EnableException
                if ($procCheck.Cnt -eq 0) {
                    Write-DbaLog "[Integrity] DatabaseIntegrityCheck not found on $instance.$OlaDatabase. Use -DeployOla Y." -Level WARN
                    $Script:Results.Add([PSCustomObject]@{ PSTypeName='CentralDB.IntegrityResult'; SqlInstance=$instance; RowsCollected=0; LoadGUID=$runGUID; CollectedAt=$collectedAt; Status='Skipped'; ErrorMessage="DatabaseIntegrityCheck not found on $OlaDatabase" })
                    continue
                }

                # Phase 3: Build and execute DatabaseIntegrityCheck
                $stepName = "Execute DatabaseIntegrityCheck on $instance"
                if ($PSCmdlet.ShouldProcess($instance, "Execute $CheckCommands on $Databases")) {

                    $olaParams  = "@Databases = '$Databases', @CheckCommands = '$CheckCommands', @LogToTable = 'Y', @Execute = 'Y'"
                    $olaParams += ", @LoadGUID = '$runGUID'"
                    $olaParams += ", @PhysicalOnly = '$PhysicalOnly'"
                    $olaParams += ", @NoIndex = '$NoIndex'"
                    $olaParams += ", @ExtendedLogicalChecks = '$ExtendedLogicalChecks'"
                    $olaParams += ", @TabLock = '$TabLock'"
                    $olaParams += ", @AvailabilityGroupReplicas = '$AvailabilityGroupReplicas'"
                    $olaParams += ", @Updateability = '$Updateability'"
                    $olaParams += ", @LockTimeout = $LockTimeout"
                    $olaParams += ", @DatabasesInParallel = '$DatabasesInParallel'"
                    if ($MaxDOP)             { $olaParams += ", @MaxDOP = $MaxDOP" }
                    if ($AvailabilityGroups) { $olaParams += ", @AvailabilityGroups = '$AvailabilityGroups'" }
                    if ($TimeLimit)          { $olaParams += ", @TimeLimit = $TimeLimit" }

                    Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                        -Query "EXEC dbo.DatabaseIntegrityCheck $olaParams" `
                        -CommandTimeout $CommandTimeout @credParam -EnableException | Out-Null
                    Write-DbaLog "[Integrity] DatabaseIntegrityCheck completed on $instance"

                    # Collect and centralize
                    $logRows = Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                        -Query 'SELECT * FROM dbo.CommandLog WHERE LoadGUID = @lg' `
                        -SqlParameters @{ lg = $runGUID } -CommandTimeout 60 @credParam -EnableException
                    if ($logRows) {
                        $enriched = $logRows | Select-Object @{ n='CollectionServerName'; e={ $hostName } }, @{ n='CollectionInstance'; e={ $instance } }, @{ n='LoadGUID'; e={ $runGUID } }, @{ n='CollectedAt'; e={ $collectedAt } }, *
                        Write-ToCms -Data $enriched -Table '[Inst].[CommandLog]' -Label 'Integrity'
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
                    catch { Write-DbaLog "[Integrity] CommandLog cleanup failed on $($instance) - $($_.Exception.Message)" -Level WARN }

                    $Script:Results.Add([PSCustomObject]@{ PSTypeName='CentralDB.IntegrityResult'; SqlInstance=$instance; CheckCommands=$CheckCommands; RowsCollected=@($logRows).Count; LoadGUID=$runGUID; CollectedAt=$collectedAt; Status='Success'; ErrorMessage=$null })
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
                $Script:Results.Add([PSCustomObject]@{ PSTypeName='CentralDB.IntegrityResult'; SqlInstance=$instance; CheckCommands=$CheckCommands; RowsCollected=0; LoadGUID=$runGUID; CollectedAt=$collectedAt; Status='Failed'; ErrorMessage=$_.Exception.Message })
                continue
            }
        }

        if ($instanceErrors.Count -gt 0) {
            throw "Invoke-CentralIntegrityCheck completed with $($instanceErrors.Count) instance error(s):`n$($instanceErrors -join "`n")"
        }
    }

    end {
        $elapsedTime.Stop()
        $duration = $elapsedTime.Elapsed.ToString('hh\:mm\:ss')
        if ($Script:ErrorCount -gt 0) { Write-Warning "Invoke-CentralIntegrityCheck completed with $Script:ErrorCount error(s) in $duration." }
        else { Write-DbaLog "Invoke-CentralIntegrityCheck completed successfully in $duration." }
        $exportBase = Join-Path $OutputPath ("IntegrityCheck_$($env:COMPUTERNAME)_$(Get-Date -Format 'yyyyMMdd_HHmmss')")
        switch ($OutputFormat) {
            'CSV'      { $Script:Results | Export-Csv -Path "$exportBase.csv" -NoTypeInformation }
            'JSON'     { $Script:Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$exportBase.json" -Encoding utf8 }
            'HTML'     { $Script:Results | ConvertTo-Html -Title 'CentralDB Integrity Check' | Out-File -FilePath "$exportBase.html" -Encoding utf8 }
            'GridView' { $Script:Results | Out-GridView -Title 'CentralDB Integrity Check' }
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
Invoke-CentralIntegrityCheck @invokeParams -Confirm:$false
