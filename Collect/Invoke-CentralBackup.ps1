# ============================================================================
# PART 1 - Script-level parameter block
# ============================================================================
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
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
    [int]$CommandTimeout = 14400,

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
    [ValidateSet('Y', 'N')]
    [string]$DeployOla = 'N',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$OlaDatabase = 'master',

    [Parameter()]
    [ValidateSet('FULL', 'DIFF', 'LOG')]
    [string]$BackupType = 'FULL',

    [Parameter()]
    [string]$Databases = 'ALL_DATABASES',

    [Parameter()]
    [string]$Directory,

    [Parameter()]
    [ValidateSet('Y', 'N')]
    [string]$Verify = 'Y',

    [Parameter()]
    [int]$CleanupTime,

    [Parameter()]
    [ValidateSet('Y', 'N')]
    [string]$Compress = 'Y',

    [Parameter()]
    [ValidateSet('Y', 'N')]
    [string]$CopyOnly = 'N',

    [Parameter()]
    [ValidateSet('Y', 'N')]
    [string]$CheckSum = 'N',

    [Parameter()]
    [ValidateSet('Y', 'N')]
    [string]$Encrypt = 'N',

    [Parameter()]
    [ValidateSet('AES128', 'AES192', 'AES256', 'TRIPLE_DES_3KEY')]
    [string]$EncryptionAlgorithm,

    [Parameter()]
    [string]$ServerCertificate,

    [Parameter()]
    [string]$AvailabilityGroups,

    [Parameter()]
    [ValidateSet('ALL', 'PRIMARY', 'SECONDARY', 'PREFERRED_BACKUP_REPLICA')]
    [string]$Updateability = 'ALL'
)

# ============================================================================
# PART 2 - Advanced function definition
# ============================================================================
function Invoke-CentralBackup {
<#
.SYNOPSIS
    Executes Ola Hallengren DatabaseBackup against one or more SQL Server
    instances and centralizes the CommandLog results into CentralDB.

.DESCRIPTION
    Replaces the legacy Get-OlaHallengren-Backup.ps1 (raw SqlClient, 2017).

    Two phases per instance:

    Deploy (optional, -DeployOla Y):
      Calls Install-DbaMaintenanceSolution to install or update Ola
      Hallengren's maintenance solution. Downloads from GitHub.

    Execute and Collect:
      Calls Ola's DatabaseBackup stored procedure via Invoke-DbaQuery
      with @LogToTable = 'Y'. After execution, queries the CommandLog
      table filtered by LoadGUID, centralizes results to [Inst].[CommandLog]
      in CentralDB, then cleans up the local CommandLog rows.

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
    Query timeout in seconds. Default: 14400 (4 hours). Backups can run
    for a long time on large databases.

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

.PARAMETER BackupType
    Backup type: FULL, DIFF, or LOG. Default: FULL.

.PARAMETER Databases
    Ola @Databases parameter. Default: ALL_DATABASES.
    Supports: ALL_DATABASES, USER_DATABASES, SYSTEM_DATABASES, or a
    comma-separated list of database names.

.PARAMETER Directory
    Backup destination directory. Passed to Ola @Directory.

.PARAMETER Verify
    Verify backup after completion. Y or N. Default: Y.

.PARAMETER CleanupTime
    Hours after which old backup files are deleted. Passed to Ola @CleanupTime.

.PARAMETER Compress
    Enable backup compression. Y or N. Default: Y.

.PARAMETER CopyOnly
    Take a copy-only backup. Y or N. Default: N.

.PARAMETER CheckSum
    Enable backup checksum. Y or N. Default: N.

.PARAMETER Encrypt
    Enable backup encryption. Y or N. Default: N.

.PARAMETER EncryptionAlgorithm
    Encryption algorithm when Encrypt = Y. Options: AES128, AES192, AES256,
    TRIPLE_DES_3KEY.

.PARAMETER ServerCertificate
    Server certificate name for encryption.

.PARAMETER AvailabilityGroups
    Ola @AvailabilityGroups filter.

.PARAMETER Updateability
    Which AG replicas to back up. Default: ALL.

.EXAMPLE
    .\Invoke-CentralBackup.ps1 -SqlInstance 'SQL-01' -BackupType FULL -Directory 'E:\Backups' -CMSInstanceName 'CMS-01' -OutputPath 'D:\Logs' -WhatIf
    Dry-run of a full backup. No backup is taken.

.EXAMPLE
    .\Invoke-CentralBackup.ps1 -CMSInstanceName 'CMS-01' -RunLocally -BackupType FULL -Directory 'E:\Backups' -OutputPath 'D:\Logs'
    MSX/TSX mode: full backup of all databases on the local instance.

.NOTES
    Author      : DBA Engineering
    Created     : 2024-01-01
    Version     : 4.1.0
    Replaces    : CentralDB/Get-OlaHallengren-Backup.ps1
    Requirements: dbatools >= 2.0.0, PowerShell >= 5.1
                  Ola Hallengren maintenance solution (or -DeployOla Y)
    Impact      : HIGH - executes database backups
    Schedule    : Daily via SQL Agent

    Permissions :
        Target    : sysadmin or db_backupoperator + VIEW SERVER STATE
        CentralDB : EXECUTE on [Svr].[usp_GetCollectionTargets]
                    EXECUTE on [Svr].[usp_SetCollectionLastRun]
                    INSERT on [Inst].[CommandLog]

    SQL Agent Config :
        Job Step Type : CmdExec
        Run As        : Proxy 'DBA_Automation_Proxy'
        Command       : powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
                        -File "\\share\CentralDB\Collect\Invoke-CentralBackup.ps1"
                        -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))"
                        -RunLocally -BackupType FULL -Directory "E:\Backups"
                        -OutputPath "D:\Logs\CentralDB"

    Attribution:
        DatabaseBackup is created and maintained by Ola Hallengren.
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
        [Parameter()][ValidateSet('FULL', 'DIFF', 'LOG')][string]$BackupType = 'FULL',
        [Parameter()][string]$Databases = 'ALL_DATABASES',
        [Parameter()][string]$Directory,
        [Parameter()][ValidateSet('Y', 'N')][string]$Verify = 'Y',
        [Parameter()][int]$CleanupTime,
        [Parameter()][ValidateSet('Y', 'N')][string]$Compress = 'Y',
        [Parameter()][ValidateSet('Y', 'N')][string]$CopyOnly = 'N',
        [Parameter()][ValidateSet('Y', 'N')][string]$CheckSum = 'N',
        [Parameter()][ValidateSet('Y', 'N')][string]$Encrypt = 'N',
        [Parameter()][ValidateSet('AES128', 'AES192', 'AES256', 'TRIPLE_DES_3KEY')][string]$EncryptionAlgorithm,
        [Parameter()][string]$ServerCertificate,
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

        Write-DbaLog "Invoke-CentralBackup v$SCRIPT_VERSION started. LoadGUID: $runGUID | Type: $BackupType"

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
            Write-DbaLog "=== Begin backup: $instance ($BackupType) ==="

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

                # Phase 2: Verify DatabaseBackup exists
                $stepName = "Verify DatabaseBackup on $instance"
                $procCheck = Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                    -Query "SELECT COUNT(1) AS Cnt FROM sys.objects WHERE name = 'DatabaseBackup' AND type = 'P'" `
                    -CommandTimeout 60 @credParam -EnableException
                if ($procCheck.Cnt -eq 0) {
                    Write-DbaLog "[Backup] DatabaseBackup proc not found on $instance.$OlaDatabase. Use -DeployOla Y." -Level WARN
                    $Script:Results.Add([PSCustomObject]@{ PSTypeName='CentralDB.BackupResult'; SqlInstance=$instance; BackupType=$BackupType; RowsCollected=0; LoadGUID=$runGUID; CollectedAt=$collectedAt; Status='Skipped'; ErrorMessage="DatabaseBackup not found on $OlaDatabase" })
                    continue
                }

                # Phase 3: Build and execute DatabaseBackup
                $stepName = "Execute DatabaseBackup on $instance"
                if ($PSCmdlet.ShouldProcess($instance, "Execute DatabaseBackup ($BackupType, $Databases)")) {

                    # Build parameter string - only include non-null/non-default values
                    $olaParams  = "@Databases = '$Databases', @BackupType = '$BackupType', @LogToTable = 'Y', @Execute = 'Y'"
                    $olaParams += ", @LoadGUID = '$runGUID'"
                    if ($Directory)            { $olaParams += ", @Directory = '$Directory'" }
                    if ($Verify)               { $olaParams += ", @Verify = '$Verify'" }
                    if ($CleanupTime)          { $olaParams += ", @CleanupTime = $CleanupTime" }
                    if ($Compress)             { $olaParams += ", @Compress = '$Compress'" }
                    if ($CopyOnly -eq 'Y')     { $olaParams += ", @CopyOnly = 'Y'" }
                    if ($CheckSum -eq 'Y')     { $olaParams += ", @CheckSum = 'Y'" }
                    if ($Encrypt -eq 'Y')      { $olaParams += ", @Encrypt = 'Y'" }
                    if ($EncryptionAlgorithm)  { $olaParams += ", @EncryptionAlgorithm = '$EncryptionAlgorithm'" }
                    if ($ServerCertificate)    { $olaParams += ", @ServerCertificate = '$ServerCertificate'" }
                    if ($AvailabilityGroups)   { $olaParams += ", @AvailabilityGroups = '$AvailabilityGroups'" }
                    if ($Updateability -ne 'ALL') { $olaParams += ", @Updateability = '$Updateability'" }

                    # No SqlParameters here - Ola proc has its own param parsing for the @Databases syntax
                    # which cannot be passed through sp_executesql parameters
                    Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                        -Query "EXEC dbo.DatabaseBackup $olaParams" `
                        -CommandTimeout $CommandTimeout @credParam -EnableException | Out-Null
                    Write-DbaLog "[Backup] DatabaseBackup completed on $instance"

                    # Phase 4: Collect CommandLog and centralize
                    $stepName = "Collect CommandLog from $instance"
                    $logRows = Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                        -Query 'SELECT * FROM dbo.CommandLog WHERE LoadGUID = @lg' `
                        -SqlParameters @{ lg = $runGUID } `
                        -CommandTimeout 60 @credParam -EnableException

                    if ($logRows) {
                        $enriched = $logRows | Select-Object `
                            @{ n='CollectionServerName'; e={ $hostName } },
                            @{ n='CollectionInstance';   e={ $instance } },
                            @{ n='LoadGUID';             e={ $runGUID } },
                            @{ n='CollectedAt';          e={ $collectedAt } },
                            *
                        Write-ToCms -Data $enriched -Table '[Inst].[CommandLog]' -Label 'Backup'
                    }

                    # Phase 5: Clean up local CommandLog
                    $stepName = "Clean up CommandLog on $instance"
                    try {
                        Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                            -Query 'DELETE FROM dbo.CommandLog WHERE LoadGUID = @lg' `
                            -SqlParameters @{ lg = $runGUID } `
                            -CommandTimeout 60 @credParam -EnableException | Out-Null
                        Invoke-DbaQuery -SqlInstance $instance -Database $OlaDatabase `
                            -Query 'DELETE FROM dbo.CommandLog WHERE EndTime <= DATEADD(DAY, -1, GETDATE())' `
                            -CommandTimeout 60 @credParam -EnableException | Out-Null
                    }
                    catch { Write-DbaLog "[Backup] CommandLog cleanup failed on $($instance) - $($_.Exception.Message)" -Level WARN }

                    $Script:Results.Add([PSCustomObject]@{ PSTypeName='CentralDB.BackupResult'; SqlInstance=$instance; BackupType=$BackupType; RowsCollected=@($logRows).Count; LoadGUID=$runGUID; CollectedAt=$collectedAt; Status='Success'; ErrorMessage=$null })
                }

                # Update CMS timestamp
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
                $Script:Results.Add([PSCustomObject]@{ PSTypeName='CentralDB.BackupResult'; SqlInstance=$instance; BackupType=$BackupType; RowsCollected=0; LoadGUID=$runGUID; CollectedAt=$collectedAt; Status='Failed'; ErrorMessage=$_.Exception.Message })
                continue
            }
        }

        if ($instanceErrors.Count -gt 0) {
            throw "Invoke-CentralBackup completed with $($instanceErrors.Count) instance error(s):`n$($instanceErrors -join "`n")"
        }
    }

    end {
        $elapsedTime.Stop()
        $duration = $elapsedTime.Elapsed.ToString('hh\:mm\:ss')
        if ($Script:ErrorCount -gt 0) { Write-Warning "Invoke-CentralBackup completed with $Script:ErrorCount error(s) in $duration." }
        else { Write-DbaLog "Invoke-CentralBackup completed successfully in $duration." }

        $exportBase = Join-Path $OutputPath ("Backup_$($env:COMPUTERNAME)_$(Get-Date -Format 'yyyyMMdd_HHmmss')")
        switch ($OutputFormat) {
            'CSV'      { $Script:Results | Export-Csv -Path "$exportBase.csv" -NoTypeInformation }
            'JSON'     { $Script:Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$exportBase.json" -Encoding utf8 }
            'HTML'     { $Script:Results | ConvertTo-Html -Title 'CentralDB Backup' | Out-File -FilePath "$exportBase.html" -Encoding utf8 }
            'GridView' { $Script:Results | Out-GridView -Title 'CentralDB Backup' }
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
Invoke-CentralBackup @invokeParams -Confirm:$false
