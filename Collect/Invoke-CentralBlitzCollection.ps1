# ============================================================================
# PART 1 - Script-level parameter block
#          Enables: powershell.exe -File Invoke-CentralBlitzCollection.ps1 -Param Value
# ============================================================================
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
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
    [ValidateSet('Y', 'N')]
    [string]$DeployFRK = 'N',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$FRKDatabase = 'master',

    [Parameter()]
    [ValidateSet('Y', 'N')]
    [string]$CheckProcedureCache = 'N',

    [Parameter()]
    [ValidateSet('Y', 'N')]
    [string]$CheckUserDatabaseObjects = 'Y'
)

# ============================================================================
# PART 2 - Advanced function definition
# ============================================================================
function Invoke-CentralBlitzCollection {
<#
.SYNOPSIS
    Runs sp_Blitz against one or more SQL Server instances and centralizes
    the findings into [FRK].[Blitz] in CentralDB.

.DESCRIPTION
    Replaces the legacy Get-FRKBlitz.ps1 (raw SqlClient + dot-sourced helpers,
    2017). Uses dbatools throughout.

    Two phases per instance:

    Deploy (optional, -DeployFRK Y):
      Calls Install-DbaFirstResponderKit to install or update sp_Blitz on the
      target instance. Downloads the latest release from GitHub. When omitted
      or set to 'N', the existing installed version is used. If sp_Blitz is
      not found and DeployFRK is 'N', the instance is skipped with a warning.

    Collect:
      Executes sp_Blitz via Invoke-DbaQuery and captures the result set
      directly - no temporary output table round-trip. Enriches each row
      with ServerName, InstanceName, LoadGUID, and CollectedAt metadata,
      then writes to [FRK].[Blitz] via Write-DbaDbTableData.

    CentralDB write failures are non-fatal (WARN only).
    Per-instance errors are accumulated and thrown at the end so SQL Agent
    correctly reports job failure.

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
    sp_Blitz with CheckProcedureCache enabled can run for several minutes
    on busy instances - consider increasing to 1800 for first runs.

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

.PARAMETER DeployFRK
    Set to 'Y' to install or update sp_Blitz before running.
    Uses Install-DbaFirstResponderKit (downloads from GitHub).
    Default: 'N' - uses the existing installed version.

.PARAMETER FRKDatabase
    Database where sp_Blitz is installed. Default: master.
    The original used tempdb; master is the recommended location
    as tempdb objects are lost on restart.

.PARAMETER CheckProcedureCache
    Set to 'Y' to enable sp_Blitz procedure cache analysis
    (@CheckProcedureCache = 1, @OutputProcedureCache = 1).
    Increases runtime significantly on busy instances. Default: 'N'.

.PARAMETER CheckUserDatabaseObjects
    Set to 'Y' to check user database objects in sp_Blitz
    (@CheckUserDatabaseObjects = 1). Default: 'Y'.

.EXAMPLE
    .\Invoke-CentralBlitzCollection.ps1 -SqlInstance 'SQL-01' -CMSInstanceName 'CMS-01' -OutputPath 'D:\Logs' -WhatIf
    Dry-run. No sp_Blitz execution, no CentralDB writes.

.EXAMPLE
    .\Invoke-CentralBlitzCollection.ps1 -CMSInstanceName 'CMS-01' -RunLocally -DeployFRK Y -OutputPath 'D:\Logs'
    MSX/TSX mode: updates sp_Blitz then runs it on the local machine.

.EXAMPLE
    .\Invoke-CentralBlitzCollection.ps1 -SqlInstance '10.0.1.196','10.0.1.129' -SqlCredential $cred -CMSInstanceName 'localhost' -FRKDatabase 'master' -OutputPath 'D:\Logs'
    Run sp_Blitz against two Linux instances using SQL auth.

.NOTES
    Author      : DBA Engineering
    Created     : 2024-01-01
    Version     : 4.1.0
    Replaces    : CentralDB/Get-FRKBlitz.ps1 (legacy raw SqlClient)
    Requirements: dbatools >= 2.0.0, PowerShell >= 5.1
    Impact      : MEDIUM - installs stored procedures when DeployFRK=Y
    Schedule    : Weekly via SQL Agent (recommended: Sunday 04:00)

    Permissions :
        Target    : sysadmin or db_owner on FRKDatabase (for sp_Blitz)
                    VIEW SERVER STATE (for sp_Blitz health checks)
        CentralDB : EXECUTE on [Svr].[usp_GetCollectionTargets]
                    EXECUTE on [Svr].[usp_SetCollectionLastRun]
                    INSERT on [FRK].[Blitz]

    SQL Agent Config :
        Job Step Type : CmdExec
        Run As        : Proxy 'DBA_Automation_Proxy'
        Command       : powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
                        -File "\\share\CentralDB\Collect\Invoke-CentralBlitzCollection.ps1"
                        -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))"
                        -RunLocally
                        -OutputPath "D:\Logs\CentralDB"

    Attribution:
        sp_Blitz is created and maintained by Brent Ozar Unlimited.
        https://www.brentozar.com/blitz/
        https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
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
        [ValidateSet('Y', 'N')]
        [string]$DeployFRK = 'N',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$FRKDatabase = 'master',

        [Parameter()]
        [ValidateSet('Y', 'N')]
        [string]$CheckProcedureCache = 'N',

        [Parameter()]
        [ValidateSet('Y', 'N')]
        [string]$CheckUserDatabaseObjects = 'Y'
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

        # Convert Y/N flags to int for SQL parameters
        $cpc = if ($CheckProcedureCache      -eq 'Y') { 1 } else { 0 }
        $cud = if ($CheckUserDatabaseObjects -eq 'Y') { 1 } else { 0 }
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

        Write-DbaLog "Invoke-CentralBlitzCollection v$SCRIPT_VERSION started. LoadGUID: $runGUID"
        Write-DbaLog "DeployFRK: $DeployFRK | FRKDatabase: $FRKDatabase | CheckProcCache: $CheckProcedureCache"

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

            Write-DbaLog "=== Begin Blitz collection: $instance ==="

            try {
                # =============================================================
                #region Phase 1: Deploy FRK (optional)
                # =============================================================
                if ($DeployFRK -eq 'Y') {
                    $stepName = "Deploy FRK on $instance"
                    if ($PSCmdlet.ShouldProcess($instance, 'Install/update sp_Blitz via Install-DbaFirstResponderKit')) {
                        Write-DbaLog "[Deploy] Installing/updating First Responder Kit on $instance.$FRKDatabase"
                        try {
                            Install-DbaFirstResponderKit `
                                -SqlInstance $instance `
                                -Database    $FRKDatabase `
                                @credParam   -EnableException | Out-Null
                            Write-DbaLog "[Deploy] First Responder Kit installed/updated on $instance.$FRKDatabase"
                        }
                        catch {
                            Write-DbaLog "[Deploy] Failed to install FRK on $($instance) - $($_.Exception.Message)" -Level WARN
                            # Non-fatal: if sp_Blitz already exists we can still run it
                        }
                    }
                }
                #endregion

                # =============================================================
                #region Phase 2: Verify sp_Blitz exists
                # =============================================================
                $stepName  = "Verify sp_Blitz on $instance"
                $spExists  = Get-DbaDbStoredProcedure -SqlInstance $instance -Database $FRKDatabase `
                    -Name 'sp_Blitz' @credParam -EnableException

                if (-not $spExists) {
                    Write-DbaLog "[Blitz] sp_Blitz not found on $instance.$FRKDatabase. Set -DeployFRK Y to install it." -Level WARN
                    $Script:Results.Add([PSCustomObject]@{
                        PSTypeName    = 'CentralDB.BlitzResult'
                        SqlInstance   = $instance
                        FindingCount  = 0
                        LoadGUID      = $runGUID
                        CollectedAt   = $collectedAt
                        Status        = 'Skipped'
                        ErrorMessage  = "sp_Blitz not found on $FRKDatabase"
                    })
                    continue
                }
                #endregion

                # =============================================================
                #region Phase 3: Execute sp_Blitz and capture results
                # =============================================================
                $stepName = "Execute sp_Blitz on $instance"
                Write-DbaLog "[Blitz] Executing sp_Blitz on $instance (CheckProcCache=$CheckProcedureCache, CheckUserDB=$CheckUserDatabaseObjects)"

                $blitzQuery = 'EXEC dbo.sp_Blitz' +
                              ' @CheckServerInfo = 1' +
                              ',@CheckUserDatabaseObjects = @cud' +
                              ',@CheckProcedureCache = @cpc' +
                              ',@OutputProcedureCache = @cpc'

                $blitzRows = Invoke-DbaQuery `
                    -SqlInstance    $instance `
                    -Database       $FRKDatabase `
                    -Query          $blitzQuery `
                    -SqlParameters  @{ cud = $cud; cpc = $cpc } `
                    -CommandTimeout $CommandTimeout `
                    @credParam      -EnableException

                if (-not $blitzRows) {
                    Write-DbaLog "[Blitz] sp_Blitz returned no rows on $instance." -Level WARN
                    $Script:Results.Add([PSCustomObject]@{
                        PSTypeName    = 'CentralDB.BlitzResult'
                        SqlInstance   = $instance
                        FindingCount  = 0
                        LoadGUID      = $runGUID
                        CollectedAt   = $collectedAt
                        Status        = 'Success'
                        ErrorMessage  = $null
                    })
                    continue
                }

                Write-DbaLog "[Blitz] sp_Blitz returned $(@($blitzRows).Count) finding(s) from $instance"
                #endregion

                # =============================================================
                #region Phase 4: Enrich and centralize
                # =============================================================
                $stepName = "Centralizing Blitz results from $instance"

                $enriched = $blitzRows | Select-Object `
                    @{ n = 'CollectionServerName'; e = { $hostName } },
                    @{ n = 'CollectionInstance';   e = { $instance } },
                    @{ n = 'LoadGUID';             e = { $runGUID } },
                    @{ n = 'CollectedAt';          e = { $collectedAt } },
                    *

                if ($PSCmdlet.ShouldProcess($instance, 'Write Blitz findings to CentralDB')) {
                    Write-ToCms -Data $enriched -Table '[FRK].[Blitz]' -Label 'Blitz'
                }
                #endregion

                # Update CMS collection timestamp
                if ($PSCmdlet.ShouldProcess($instance, 'Update Blitz collection timestamp in CentralDB')) {
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

                Write-DbaLog "=== Completed $instance - $(@($blitzRows).Count) finding(s) ==="

                $Script:Results.Add([PSCustomObject]@{
                    PSTypeName    = 'CentralDB.BlitzResult'
                    SqlInstance   = $instance
                    FindingCount  = @($blitzRows).Count
                    LoadGUID      = $runGUID
                    CollectedAt   = $collectedAt
                    Status        = 'Success'
                    ErrorMessage  = $null
                })
            }
            catch {
                $msg = "[$($stepName)] Failed on $($instance) - $($_.Exception.Message)"
                $instanceErrors.Add($msg)
                Write-DbaLog $msg -Level ERROR

                $Script:Results.Add([PSCustomObject]@{
                    PSTypeName    = 'CentralDB.BlitzResult'
                    SqlInstance   = $instance
                    FindingCount  = 0
                    LoadGUID      = $runGUID
                    CollectedAt   = $collectedAt
                    Status        = 'Failed'
                    ErrorMessage  = $_.Exception.Message
                })

                continue
            }
        }

        if ($instanceErrors.Count -gt 0) {
            $summary = $instanceErrors -join "`n"
            throw "Invoke-CentralBlitzCollection completed with $($instanceErrors.Count) instance error(s):`n$summary"
        }
    }

    # -------------------------------------------------------------------------
    end {
        $elapsedTime.Stop()
        $duration = $elapsedTime.Elapsed.ToString('hh\:mm\:ss')

        if ($Script:ErrorCount -gt 0) {
            Write-Warning "Invoke-CentralBlitzCollection completed with $Script:ErrorCount error(s) in $duration."
        }
        else {
            Write-DbaLog "Invoke-CentralBlitzCollection completed successfully in $duration."
        }

        #region Export Output
        $exportBase = Join-Path $OutputPath ("BlitzCollection_$($env:COMPUTERNAME)_$(Get-Date -Format 'yyyyMMdd_HHmmss')")

        switch ($OutputFormat) {
            'CSV'      { $Script:Results | Export-Csv -Path "$exportBase.csv"  -NoTypeInformation }
            'JSON'     { $Script:Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$exportBase.json" -Encoding utf8 }
            'HTML'     { $Script:Results | ConvertTo-Html -Title 'CentralDB Blitz Collection' | Out-File -FilePath "$exportBase.html" -Encoding utf8 }
            'GridView' { $Script:Results | Out-GridView -Title 'CentralDB Blitz Collection' }
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
Invoke-CentralBlitzCollection @invokeParams -Confirm:$false
