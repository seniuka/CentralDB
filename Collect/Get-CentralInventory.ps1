# ============================================================================
# PART 1 - Script-level parameter block
#          Enables: powershell.exe -File Get-CentralInventory.ps1 -Param Value
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
    [ValidateSet('All', 'ServerOS', 'Instance', 'Databases', 'HA', 'SSRS')]
    [string[]]$Sections = @('All')
)

# ============================================================================
# PART 2 - Advanced function definition
# ============================================================================
function Get-CentralInventory {
<#
.SYNOPSIS
    Collects a full SQL Server estate inventory and centralizes results
    into CentralDB across six sections: ServerOS, Instance, Databases,
    HA, and SSRS.

.DESCRIPTION
    Replaces the legacy Get-Inventory.ps1 (WMI + SMO, 2017).
    Uses dbatools throughout and supports both Windows and Linux instances.

    Sections collected per instance:
    - ServerOS   : OS info, patch history, page file, disk space, SQL services
                   (Windows instances only - skipped gracefully for Linux)
    - Instance   : SQL build/compliance, instance properties, sp_configure,
                   logins, linked servers, instance-level triggers,
                   agent jobs, failed jobs
    - Databases  : Database properties, files, file growth events,
                   backup history, DB role members, user permissions,
                   missing indexes, last good DBCC
    - HA         : Availability groups, AG databases, AG replicas
    - SSRS       : Reporting Services instance info
                   (Windows instances only)

    Each section has independent error handling - a failure in one section
    does not stop collection of subsequent sections for that instance.
    CentralDB write failures are non-fatal (WARN only).

.PARAMETER SqlInstance
    One or more SQL Server instance names. Accepts hostname,
    hostname\instance, or hostname,port. Accepts pipeline input.
    If omitted, CMS discovery via -CMSInstanceName is used.

.PARAMETER SqlCredential
    PSCredential for SQL Server authentication on target instances.
    Required for Linux targets and SQL-auth-only environments.

.PARAMETER CMSInstanceName
    The CentralDB SQL Server instance used to resolve the target list
    and as the destination for centralized inventory data.

.PARAMETER CMSDatabaseName
    The CentralDB database name. Default: CentralDB.

.PARAMETER CommandTimeout
    Query timeout in seconds. Default: 600. Range: 60-86400.

.PARAMETER IntroduceDelay
    Set to 'Y' to sleep a random interval before processing.
    Use in MSX/TSX jobs to stagger simultaneous CentralDB writes.

.PARAMETER DelaySecMin
    Minimum stagger delay in seconds. Default: 1.

.PARAMETER DelaySecMax
    Maximum stagger delay in seconds. Default: 300.

.PARAMETER RunLocally
    Restricts CMS discovery to the local machine. Use in MSX/TSX
    SQL Agent jobs so each server collects its own inventory only.

.PARAMETER OutputPath
    Directory for exported output files. Must already exist.

.PARAMETER OutputFormat
    Output format. Default: CSV.
    Supported: CSV, HTML, JSON, Excel, GridView.

.PARAMETER LoadGUID
    Correlation GUID for this collection run. A new GUID is generated
    when omitted. Pass the same GUID across all collection scripts in
    a scheduled run to correlate results in CentralDB.

.PARAMETER Sections
    Restrict collection to specific sections. Default: All.
    Values: All, ServerOS, Instance, Databases, HA, SSRS.
    Example: -Sections Instance,Databases

.EXAMPLE
    .\Get-CentralInventory.ps1 -SqlInstance 'SQL-01' -CMSInstanceName 'CMS-01' -OutputPath 'D:\Logs' -WhatIf
    Dry-run against a single instance. Nothing is written.

.EXAMPLE
    .\Get-CentralInventory.ps1 -CMSInstanceName 'CMS-01' -RunLocally -OutputPath 'D:\Logs'
    MSX/TSX mode: discovers instances from CentralDB filtered to local machine.

.EXAMPLE
    .\Get-CentralInventory.ps1 -SqlInstance '10.0.1.129' -SqlCredential $cred -CMSInstanceName 'localhost' -Sections Instance,Databases -OutputPath 'D:\Logs'
    Collect only Instance and Database sections from a Linux target.

.NOTES
    Author      : DBA Engineering
    Created     : 2024-01-01
    Version     : 4.1.0
    Replaces    : CentralDB/Get-Inventory.ps1 (legacy WMI + SMO)
    Requirements: dbatools >= 2.0.0, PowerShell >= 5.1
    Impact      : LOW - read-only on targets, INSERT on CentralDB
    Schedule    : Weekly via SQL Agent (recommended: Sunday 02:00)

    Permissions :
        Target    : VIEW SERVER STATE, VIEW ANY DATABASE
                    db_datareader on msdb
        CentralDB : EXECUTE on [Svr].[usp_GetCollectionTargets]
                    EXECUTE on [Svr].[usp_SetCollectionLastRun]
                    INSERT on [Svr].*, [Inst].*, [DB].*, [RS].*

    SQL Agent Config :
        Job Step Type : CmdExec
        Run As        : Proxy 'DBA_Automation_Proxy'
        Command       : powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
                        -File "\\share\CentralDB\Collect\Get-CentralInventory.ps1"
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
        [ValidateSet('All', 'ServerOS', 'Instance', 'Databases', 'HA', 'SSRS')]
        [string[]]$Sections = @('All')
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

        $runAll = $Sections -contains 'All'
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

        #region Write-Tocms Helper
        function Write-ToCms {
            param (
                [Parameter(Mandatory)][object]$Data,
                [Parameter(Mandatory)][string]$Table,
                [Parameter(Mandatory)][string]$Section
            )
            try {
                $Data | Write-DbaDbTableData `
                    -SqlInstance $CMSInstanceName `
                    -Database    $CMSDatabaseName `
                    -Table       $Table `
                    -AutoCreateTable `
                    @cmsCredParam `
                    -EnableException
                Write-DbaLog "[$Section] Wrote $(@($Data).Count) row(s) to $Table"
            }
            catch {
                Write-DbaLog "[$Section] CMS write to $Table failed - $($_.Exception.Message)" -Level WARN
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

        Write-DbaLog "Get-CentralInventory v$SCRIPT_VERSION started. LoadGUID: $runGUID"
        Write-DbaLog "Sections: $($Sections -join ', ')"

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
                -SqlParameters  @{ ct = 'Inventory'; sn = $localHost } `
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
                -SqlParameters  @{ ct = 'Inventory' } `
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
            $sectionsDone = New-Object 'System.Collections.Generic.List[string]'
            $sectionsFailed = New-Object 'System.Collections.Generic.List[string]'

            Write-DbaLog "=== Begin inventory: $instance ==="

            # Detect platform - Linux targets skip WMI-based sections gracefully
            $stepName  = "Detecting platform for $instance"
            $isWindows = $true
            try {
                # No SqlParameters needed - query is a pure literal with no user input
                $platResult = Invoke-DbaQuery `
                    -SqlInstance    $instance `
                    -Query          "SELECT CAST(SERVERPROPERTY('EngineEdition') AS INT) AS EngEd, @@VERSION AS Ver" `
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

            # =================================================================
            #region Section: ServerOS
            # =================================================================
            if ($runAll -or $Sections -contains 'ServerOS') {
                $stepName = "ServerOS - $instance"

                if (-not $isWindows) {
                    Write-DbaLog "[ServerOS] Skipped for Linux instance $instance." -Level WARN
                }
                else {
                    # -- OS Info -----------------------------------------------
                    try {
                        $osData = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $hostName -ErrorAction Stop
                        $lastBoot = New-TimeSpan -Start ($osData.LastBootUpTime) -End (Get-Date)
                        $uptime   = '{0} Days, {1} Hrs' -f $lastBoot.Days, $lastBoot.Hours

                        $osRows = $osData | Select-Object `
                            @{ n = 'ServerName';   e = { $hostName } },
                            @{ n = 'OSName';       e = { $_.Caption } },
                            @{ n = 'OSVersion';    e = { $_.Version } },
                            @{ n = 'OSBuildNo';    e = { $_.BuildNumber } },
                            @{ n = 'ServicePack';  e = { $_.ServicePackMajorVersion } },
                            @{ n = 'OSArchitect';  e = { $_.OSArchitecture } },
                            @{ n = 'UpTimeHrs';    e = { $uptime } },
                            @{ n = 'LastBootTime'; e = { $_.LastBootUpTime } },
                            @{ n = 'LoadGUID';     e = { $runGUID } },
                            @{ n = 'CollectedAt';  e = { $collectedAt } }

                        Write-ToCms -Data $osRows -Table '[Svr].[OSInfo]' -Section 'ServerOS'
                    }
                    catch {
                        Write-DbaLog "[ServerOS][OSInfo] $($instance) - $($_.Exception.Message)" -Level WARN
                    }

                    # -- OS Patches -------------------------------------------
                    try {
                        $patches = Get-CimInstance -ClassName Win32_QuickFixEngineering -ComputerName $hostName -ErrorAction Stop
                        $patchRows = $patches | Select-Object `
                            @{ n = 'ServerName';  e = { $hostName } },
                            Caption, Description, HotFixID, InstalledBy, InstalledOn,
                            @{ n = 'LoadGUID';    e = { $runGUID } },
                            @{ n = 'CollectedAt'; e = { $collectedAt } }

                        Write-ToCms -Data $patchRows -Table '[Svr].[OSPatchInfo]' -Section 'ServerOS'
                    }
                    catch {
                        Write-DbaLog "[ServerOS][OSPatchInfo] $($instance) - $($_.Exception.Message)" -Level WARN
                    }

                    # -- Page File --------------------------------------------
                    try {
                        $pgFile = Get-CimInstance -ClassName Win32_PageFileUsage -ComputerName $hostName -ErrorAction Stop
                        $pgRows = $pgFile | Select-Object `
                            @{ n = 'ServerName';          e = { $hostName } },
                            Name,
                            @{ n = 'PgAllocBaseSzInGB';   e = { [math]::Round($_.AllocatedBaseSize / 1024, 2) } },
                            @{ n = 'PgCurrUsageInGB';     e = { [math]::Round($_.CurrentUsage     / 1024, 2) } },
                            @{ n = 'PgPeakUsageInGB';     e = { [math]::Round($_.PeakUsage        / 1024, 2) } },
                            @{ n = 'LoadGUID';            e = { $runGUID } },
                            @{ n = 'CollectedAt';         e = { $collectedAt } }

                        Write-ToCms -Data $pgRows -Table '[Svr].[PgFileUsage]' -Section 'ServerOS'
                    }
                    catch {
                        Write-DbaLog "[ServerOS][PgFileUsage] $($instance) - $($_.Exception.Message)" -Level WARN
                    }

                    # -- Server / Hardware ------------------------------------
                    try {
                        $compSys  = Get-DbaComputerSystem -ComputerName $hostName -EnableException
                        $srvRows  = $compSys | Select-Object `
                            @{ n = 'ServerName';                  e = { $hostName } },
                            @{ n = 'Model';                       e = { $_.Model } },
                            @{ n = 'Manufacturer';                e = { $_.Manufacturer } },
                            @{ n = 'Domain';                      e = { $_.Domain } },
                            @{ n = 'TotalPhysicalMemoryInGB';     e = { [math]::Round($_.TotalPhysicalMemory / 1GB, 2) } },
                            @{ n = 'NumberOfProcessors';          e = { $_.NumberOfProcessors } },
                            @{ n = 'NumberOfLogicalProcessors';   e = { $_.NumberOfLogicalProcessors } },
                            @{ n = 'IsVM';                        e = { $_.Model -match 'Virtual' } },
                            @{ n = 'LoadGUID';                    e = { $runGUID } },
                            @{ n = 'CollectedAt';                 e = { $collectedAt } }

                        Write-ToCms -Data $srvRows -Table '[Svr].[ServerInfo]' -Section 'ServerOS'
                    }
                    catch {
                        Write-DbaLog "[ServerOS][ServerInfo] $($instance) - $($_.Exception.Message)" -Level WARN
                    }

                    # -- Disk Space -------------------------------------------
                    try {
                        $disks    = Get-DbaDiskSpace -ComputerName $hostName -EnableException
                        $diskRows = $disks | Select-Object `
                            @{ n = 'ServerName';        e = { $hostName } },
                            @{ n = 'Name';              e = { $_.Name } },
                            @{ n = 'Label';             e = { $_.Label } },
                            @{ n = 'FileSystem';        e = { $_.FileSystem } },
                            @{ n = 'DskTotalSizeInGB';  e = { [math]::Round($_.Capacity  / 1GB, 2) } },
                            @{ n = 'DskFreeSpaceInGB';  e = { [math]::Round($_.Free      / 1GB, 2) } },
                            @{ n = 'DskUsedSpaceInGB';  e = { [math]::Round(($_.Capacity - $_.Free) / 1GB, 2) } },
                            @{ n = 'DskPctFree';        e = { if ($_.Capacity -gt 0) { [math]::Round(($_.Free / $_.Capacity) * 100, 2) } else { 0 } } },
                            @{ n = 'BlockSizeInKB';     e = { $_.BlockSize / 1KB } },
                            @{ n = 'IsSqlDisk';         e = { $_.IsSqlDisk } },
                            @{ n = 'LoadGUID';          e = { $runGUID } },
                            @{ n = 'CollectedAt';       e = { $collectedAt } }

                        Write-ToCms -Data $diskRows -Table '[Svr].[DiskInfo]' -Section 'ServerOS'
                    }
                    catch {
                        Write-DbaLog "[ServerOS][DiskInfo] $($instance) - $($_.Exception.Message)" -Level WARN
                    }

                    # -- SQL Services -----------------------------------------
                    try {
                        $services = Get-DbaService -ComputerName $hostName -EnableException
                        $svcRows  = $services | Select-Object `
                            @{ n = 'ServerName';    e = { $hostName } },
                            ServiceName, DisplayName, State, StartMode,
                            @{ n = 'ServiceAccount'; e = { $_.StartName } },
                            @{ n = 'ProcessId';      e = { $_.ProcessId } },
                            @{ n = 'LoadGUID';       e = { $runGUID } },
                            @{ n = 'CollectedAt';    e = { $collectedAt } }

                        Write-ToCms -Data $svcRows -Table '[Svr].[SQLServices]' -Section 'ServerOS'
                    }
                    catch {
                        Write-DbaLog "[ServerOS][SQLServices] $($instance) - $($_.Exception.Message)" -Level WARN
                    }
                }
                $sectionsDone.Add('ServerOS')
            }
            #endregion ServerOS

            # =================================================================
            #region Section: Instance
            # =================================================================
            if ($runAll -or $Sections -contains 'Instance') {
                $stepName = "Instance - $instance"

                # -- Build Compliance -----------------------------------------
                try {
                    $buildInfo = Test-DbaBuild -SqlInstance $instance @credParam -Latest -EnableException
                    $buildRows = $buildInfo | Select-Object `
                        @{ n = 'ServerName';    e = { $hostName } },
                        @{ n = 'InstanceName';  e = { $instance } },
                        @{ n = 'SQLVersion';    e = { $_.NameLevel } },
                        @{ n = 'Build';         e = { $_.Build } },
                        @{ n = 'BuildTarget';   e = { $_.BuildTarget } },
                        @{ n = 'Compliant';     e = { $_.Compliant } },
                        @{ n = 'SPLevel';       e = { $_.SPLevel } },
                        @{ n = 'CULevel';       e = { $_.CULevel } },
                        @{ n = 'SupportedUntil';e = { $_.SupportedUntil } },
                        @{ n = 'LoadGUID';      e = { $runGUID } },
                        @{ n = 'CollectedAt';   e = { $collectedAt } }

                    Write-ToCms -Data $buildRows -Table '[Inst].[BuildCompliance]' -Section 'Instance'
                }
                catch {
                    Write-DbaLog "[Instance][BuildCompliance] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                # -- Instance Properties --------------------------------------
                try {
                    $instProps = Get-DbaInstanceProperty -SqlInstance $instance @credParam -EnableException
                    # Pivot key properties to a single row per instance
                    $propHash = @{}
                    foreach ($p in $instProps) { $propHash[$p.Name] = $p.Value }

                    $instRow = [PSCustomObject]@{
                        ServerName              = $hostName
                        InstanceName            = $instance
                        Edition                 = if ($propHash['Edition'])             { $propHash['Edition'] }             else { $null }
                        ProductVersion          = if ($propHash['ProductVersion'])       { $propHash['ProductVersion'] }       else { $null }
                        ProductLevel            = if ($propHash['ProductLevel'])         { $propHash['ProductLevel'] }         else { $null }
                        ProductUpdateLevel      = if ($propHash['ProductUpdateLevel'])   { $propHash['ProductUpdateLevel'] }   else { $null }
                        Collation               = if ($propHash['Collation'])            { $propHash['Collation'] }            else { $null }
                        MaxServerMemoryMB       = if ($propHash['MaxServerMemory'])      { $propHash['MaxServerMemory'] }      else { $null }
                        MinServerMemoryMB       = if ($propHash['MinServerMemory'])      { $propHash['MinServerMemory'] }      else { $null }
                        MaxDOP                  = if ($propHash['MaxDegreeOfParallelism']){ $propHash['MaxDegreeOfParallelism'] } else { $null }
                        CostThresholdParallel   = if ($propHash['CostThresholdForParallelism']) { $propHash['CostThresholdForParallelism'] } else { $null }
                        IsHadrEnabled           = if ($propHash['IsHadrEnabled'])        { $propHash['IsHadrEnabled'] }        else { $null }
                        IsClustered             = if ($propHash['IsClustered'])           { $propHash['IsClustered'] }          else { $null }
                        NumLogicalProcessors    = if ($propHash['ProcessorCount'])       { $propHash['ProcessorCount'] }       else { $null }
                        LoadGUID                = $runGUID
                        CollectedAt             = $collectedAt
                    }

                    Write-ToCms -Data $instRow -Table '[Inst].[InstanceInfo]' -Section 'Instance'
                }
                catch {
                    Write-DbaLog "[Instance][InstanceInfo] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                # -- Logins ---------------------------------------------------
                try {
                    $logins   = Get-DbaLogin -SqlInstance $instance @credParam -EnableException
                    $loginRows = $logins | Select-Object `
                        @{ n = 'ServerName';    e = { $hostName } },
                        @{ n = 'InstanceName';  e = { $instance } },
                        Name, LoginType, IsDisabled, IsLocked, MustChangePassword,
                        CreateDate, DateLastModified,
                        @{ n = 'DefaultDatabase'; e = { $_.DefaultDatabase } },
                        @{ n = 'HasAccess';       e = { $_.HasAccess } },
                        @{ n = 'LoadGUID';        e = { $runGUID } },
                        @{ n = 'CollectedAt';     e = { $collectedAt } }

                    Write-ToCms -Data $loginRows -Table '[Inst].[Logins]' -Section 'Instance'
                }
                catch {
                    Write-DbaLog "[Instance][Logins] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                # -- Server Role Members --------------------------------------
                try {
                    $srvRoles = Get-DbaServerRoleMember -SqlInstance $instance @credParam -EnableException
                    $roleRows = $srvRoles | Select-Object `
                        @{ n = 'ServerName';   e = { $hostName } },
                        @{ n = 'InstanceName'; e = { $instance } },
                        Role, Name,
                        @{ n = 'LoginType';    e = { $_.MemberLoginType } },
                        @{ n = 'LoadGUID';     e = { $runGUID } },
                        @{ n = 'CollectedAt';  e = { $collectedAt } }

                    Write-ToCms -Data $roleRows -Table '[Inst].[InstanceRoles]' -Section 'Instance'
                }
                catch {
                    Write-DbaLog "[Instance][InstanceRoles] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                # -- Linked Servers -------------------------------------------
                try {
                    $linked    = Get-DbaLinkedServer -SqlInstance $instance @credParam -EnableException
                    $lsRows    = $linked | Select-Object `
                        @{ n = 'ServerName';    e = { $hostName } },
                        @{ n = 'InstanceName';  e = { $instance } },
                        Name,
                        @{ n = 'DataSource';    e = { $_.DataSource } },
                        @{ n = 'ProviderName';  e = { $_.ProviderName } },
                        @{ n = 'ProductName';   e = { $_.ProductName } },
                        @{ n = 'Collation';     e = { $_.Collation } },
                        CreateDate,
                        @{ n = 'LoadGUID';      e = { $runGUID } },
                        @{ n = 'CollectedAt';   e = { $collectedAt } }

                    Write-ToCms -Data $lsRows -Table '[Inst].[LinkedServers]' -Section 'Instance'
                }
                catch {
                    Write-DbaLog "[Instance][LinkedServers] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                # -- Agent Jobs -----------------------------------------------
                try {
                    $jobs    = Get-DbaAgentJob -SqlInstance $instance @credParam -EnableException
                    $jobRows = $jobs | Select-Object `
                        @{ n = 'ServerName';      e = { $hostName } },
                        @{ n = 'InstanceName';    e = { $instance } },
                        Name, Category, IsEnabled,
                        @{ n = 'OwnerLoginName';  e = { $_.OwnerLoginName } },
                        @{ n = 'LastRunDate';     e = { $_.LastRunDate } },
                        @{ n = 'LastRunOutcome';  e = { $_.LastRunOutcome } },
                        @{ n = 'HasSchedule';     e = { $_.HasSchedule } },
                        @{ n = 'LoadGUID';        e = { $runGUID } },
                        @{ n = 'CollectedAt';     e = { $collectedAt } }

                    Write-ToCms -Data $jobRows -Table '[Inst].[Jobs]' -Section 'Instance'

                    $failedRows = $jobs | Where-Object { $_.LastRunOutcome -eq 'Failed' } |
                        Select-Object `
                            @{ n = 'ServerName';     e = { $hostName } },
                            @{ n = 'InstanceName';   e = { $instance } },
                            Name, Category,
                            @{ n = 'LastRunDate';    e = { $_.LastRunDate } },
                            @{ n = 'LoadGUID';       e = { $runGUID } },
                            @{ n = 'CollectedAt';    e = { $collectedAt } }

                    if ($failedRows) {
                        Write-ToCms -Data $failedRows -Table '[Inst].[JobsFailed]' -Section 'Instance'
                    }
                }
                catch {
                    Write-DbaLog "[Instance][Jobs] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                $sectionsDone.Add('Instance')
            }
            #endregion Instance

            # =================================================================
            #region Section: Databases
            # =================================================================
            if ($runAll -or $Sections -contains 'Databases') {
                $stepName = "Databases - $instance"

                # -- Database Properties --------------------------------------
                try {
                    $databases = Get-DbaDatabase -SqlInstance $instance @credParam -EnableException
                    $dbRows    = $databases | Select-Object `
                        @{ n = 'ServerName';                    e = { $hostName } },
                        @{ n = 'InstanceName';                  e = { $instance } },
                        Name, Status, Owner, CreateDate,
                        @{ n = 'SizeInMB';                      e = { $_.Size } },
                        @{ n = 'SpaceAvailableInMB';            e = { [math]::Round($_.SpaceAvailable / 1024, 2) } },
                        @{ n = 'PctFreeSpace';                  e = { if ($_.Size -gt 0) { [math]::Round(($_.SpaceAvailable / 1024) / $_.Size * 100, 2) } else { 0 } } },
                        RecoveryModel, CompatibilityLevel, Collation,
                        LastBackupDate, LastDifferentialBackupDate, LastLogBackupDate,
                        @{ n = 'IsReadCommittedSnapshotOn';     e = { $_.IsReadCommittedSnapshotOn } },
                        @{ n = 'IsEncrypted';                   e = { $_.EncryptionEnabled } },
                        @{ n = 'IsMirroringEnabled';            e = { $_.IsMirroringEnabled } },
                        @{ n = 'AvailabilityGroupName';         e = { $_.AvailabilityGroupName } },
                        @{ n = 'IsReadOnly';                    e = { $_.ReadOnly } },
                        AutoShrink,
                        @{ n = 'BrokerEnabled';                 e = { $_.BrokerEnabled } },
                        @{ n = 'ChangeTrackingEnabled';         e = { $_.ChangeTrackingEnabled } },
                        @{ n = 'ActiveConnections';             e = { $_.ActiveConnections } },
                        @{ n = 'LoadGUID';                      e = { $runGUID } },
                        @{ n = 'CollectedAt';                   e = { $collectedAt } }

                    Write-ToCms -Data $dbRows -Table '[DB].[DatabaseInfo]' -Section 'Databases'
                }
                catch {
                    Write-DbaLog "[Databases][DatabaseInfo] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                # -- Last Good DBCC -------------------------------------------
                try {
                    $dbccInfo = Get-DbaLastGoodCheckDb -SqlInstance $instance @credParam -EnableException
                    $dbccRows = $dbccInfo | Select-Object `
                        @{ n = 'ServerName';         e = { $hostName } },
                        @{ n = 'InstanceName';       e = { $instance } },
                        @{ n = 'DatabaseName';       e = { $_.Database } },
                        @{ n = 'LastGoodDBCC';       e = { $_.LastGoodCheckDb } },
                        @{ n = 'DaysSinceLastDBCC';  e = { $_.DaysSinceLastGoodCheckDb } },
                        @{ n = 'Status';             e = { $_.Status } },
                        @{ n = 'LoadGUID';           e = { $runGUID } },
                        @{ n = 'CollectedAt';        e = { $collectedAt } }

                    Write-ToCms -Data $dbccRows -Table '[DB].[LastGoodDBCC]' -Section 'Databases'
                }
                catch {
                    Write-DbaLog "[Databases][LastGoodDBCC] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                # -- Database Files -------------------------------------------
                try {
                    $dbFiles  = Get-DbaDbFile -SqlInstance $instance @credParam -EnableException
                    $fileRows = $dbFiles | Select-Object `
                        @{ n = 'ServerName';     e = { $hostName } },
                        @{ n = 'InstanceName';   e = { $instance } },
                        Database, FileGroupName, LogicalName, PhysicalName,
                        TypeDescription, FileId,
                        @{ n = 'SizeInMB';       e = { [math]::Round($_.Size.Megabyte, 2) } },
                        @{ n = 'UsedInMB';       e = { [math]::Round($_.UsedSpace.Megabyte, 2) } },
                        @{ n = 'GrowthInMB';     e = { if ($_.GrowthType -eq 'KB') { [math]::Round($_.Growth / 1024, 2) } else { $null } } },
                        @{ n = 'GrowthPct';      e = { if ($_.GrowthType -eq 'Percent') { $_.Growth } else { $null } } },
                        @{ n = 'GrowthType';     e = { $_.GrowthType } },
                        @{ n = 'LoadGUID';       e = { $runGUID } },
                        @{ n = 'CollectedAt';    e = { $collectedAt } }

                    Write-ToCms -Data $fileRows -Table '[DB].[DatabaseFiles]' -Section 'Databases'
                }
                catch {
                    Write-DbaLog "[Databases][DatabaseFiles] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                # -- Backup History -------------------------------------------
                try {
                    $backups  = Get-DbaDbBackupHistory -SqlInstance $instance @credParam -Last -EnableException
                    $bakRows  = $backups | Select-Object `
                        @{ n = 'ServerName';           e = { $hostName } },
                        @{ n = 'InstanceName';         e = { $instance } },
                        @{ n = 'DBName';               e = { $_.Database } },
                        @{ n = 'BackupType';           e = { $_.Type } },
                        @{ n = 'BackupStartDate';      e = { $_.Start } },
                        @{ n = 'BackupFinishDate';     e = { $_.End } },
                        @{ n = 'BackupDurationSec';    e = { $_.Duration.TotalSeconds } },
                        @{ n = 'BackupSizeGB';         e = { [math]::Round($_.TotalSize / 1GB, 4) } },
                        @{ n = 'CompressedSizeGB';     e = { [math]::Round($_.CompressedBackupSize / 1GB, 4) } },
                        @{ n = 'PhysicalDeviceName';   e = { $_.Path } },
                        @{ n = 'IsCopyOnly';           e = { $_.IsCopyOnly } },
                        @{ n = 'RecoveryModel';        e = { $_.RecoveryModel } },
                        @{ n = 'LoadGUID';             e = { $runGUID } },
                        @{ n = 'CollectedAt';          e = { $collectedAt } }

                    Write-ToCms -Data $bakRows -Table '[DB].[DatabaseBackups]' -Section 'Databases'
                }
                catch {
                    Write-DbaLog "[Databases][DatabaseBackups] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                # -- Database Role Members ------------------------------------
                try {
                    $roleMembers = Get-DbaDbRoleMember -SqlInstance $instance @credParam -EnableException
                    $roleRows    = $roleMembers | Select-Object `
                        @{ n = 'ServerName';   e = { $hostName } },
                        @{ n = 'InstanceName'; e = { $instance } },
                        Database, Role, UserName, Login,
                        @{ n = 'LoadGUID';     e = { $runGUID } },
                        @{ n = 'CollectedAt';  e = { $collectedAt } }

                    Write-ToCms -Data $roleRows -Table '[DB].[DBUserRoles]' -Section 'Databases'
                }
                catch {
                    Write-DbaLog "[Databases][DBUserRoles] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                # -- User Permissions -----------------------------------------
                try {
                    $perms    = Get-DbaUserPermission -SqlInstance $instance @credParam -EnableException
                    $permRows = $perms | Select-Object `
                        @{ n = 'ServerName';   e = { $hostName } },
                        @{ n = 'InstanceName'; e = { $instance } },
                        Database, Object, Type, Member, RoleSecurableClass,
                        PermissionName, PermissionState,
                        @{ n = 'LoadGUID';     e = { $runGUID } },
                        @{ n = 'CollectedAt';  e = { $collectedAt } }

                    Write-ToCms -Data $permRows -Table '[Tbl].[TblPermissions]' -Section 'Databases'
                }
                catch {
                    Write-DbaLog "[Databases][TblPermissions] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                # -- Missing Indexes ------------------------------------------
                # Get-DbaDbMissingIndex does not exist in dbatools.
                # Query sys.dm_db_missing_index_* DMVs directly via Invoke-DbaQuery.
                try {
                    $missingIdxQuery =
                        "SELECT DB_NAME(mid.database_id) AS DatabaseName, " +
                        "OBJECT_SCHEMA_NAME(mid.object_id, mid.database_id) AS SchemaName, " +
                        "OBJECT_NAME(mid.object_id, mid.database_id) AS TableName, " +
                        "mid.equality_columns AS EqualityColumns, " +
                        "mid.inequality_columns AS InequalityColumns, " +
                        "mid.included_columns AS IncludedColumns, " +
                        "CAST(migs.avg_user_impact AS DECIMAL(5,2)) AS AvgUserImpact, " +
                        "migs.user_seeks AS UserSeeks, " +
                        "migs.user_scans AS UserScans, " +
                        "migs.last_user_seek AS LastUserSeek " +
                        "FROM sys.dm_db_missing_index_details mid " +
                        "JOIN sys.dm_db_missing_index_groups mig " +
                        "    ON mid.index_handle = mig.index_handle " +
                        "JOIN sys.dm_db_missing_index_group_stats migs " +
                        "    ON mig.index_group_handle = migs.group_handle " +
                        "WHERE mid.database_id > 4 " +
                        "ORDER BY migs.avg_user_impact DESC"

                    $missingIdx = Invoke-DbaQuery -SqlInstance $instance -Database master @credParam `
                        -Query $missingIdxQuery -CommandTimeout $CommandTimeout -EnableException

                    $idxRows = $missingIdx | Select-Object `
                        @{ n = 'ServerName';      e = { $hostName } },
                        @{ n = 'InstanceName';    e = { $instance } },
                        @{ n = 'DatabaseName';    e = { $_.DatabaseName } },
                        @{ n = 'SchemaName';      e = { $_.SchemaName } },
                        @{ n = 'TableName';       e = { $_.TableName } },
                        @{ n = 'EqualityColumns'; e = { $_.EqualityColumns } },
                        @{ n = 'InEqualColumns';  e = { $_.InequalityColumns } },
                        @{ n = 'IncludedColumns'; e = { $_.IncludedColumns } },
                        @{ n = 'AvgUserImpact';   e = { $_.AvgUserImpact } },
                        @{ n = 'UserSeeks';       e = { $_.UserSeeks } },
                        @{ n = 'UserScans';       e = { $_.UserScans } },
                        @{ n = 'LastUserSeek';    e = { $_.LastUserSeek } },
                        @{ n = 'LoadGUID';        e = { $runGUID } },
                        @{ n = 'CollectedAt';     e = { $collectedAt } }

                    Write-ToCms -Data $idxRows -Table '[Inst].[MissingIndexes]' -Section 'Databases'
                }
                catch {
                    Write-DbaLog "[Databases][MissingIndexes] $($instance) - $($_.Exception.Message)" -Level WARN
                }

                $sectionsDone.Add('Databases')
            }
            #endregion Databases

            # =================================================================
            #region Section: HA
            # =================================================================
            if ($runAll -or $Sections -contains 'HA') {
                $stepName = "HA - $instance"
                try {
                    $agGroups = Get-DbaAvailabilityGroup -SqlInstance $instance @credParam -EnableException

                    if ($agGroups) {
                        # AG Groups
                        $agRows = $agGroups | Select-Object `
                            @{ n = 'ServerName';        e = { $hostName } },
                            @{ n = 'InstanceName';      e = { $instance } },
                            @{ n = 'AGName';            e = { $_.Name } },
                            @{ n = 'PrimaryReplica';    e = { $_.PrimaryReplicaServerName } },
                            @{ n = 'SyncHealth';        e = { $_.SynchronizationHealth } },
                            @{ n = 'BackupPreference';  e = { $_.AutomatedBackupPreference } },
                            @{ n = 'FailoverMode';      e = { $_.FailureConditionLevel } },
                            @{ n = 'LoadGUID';          e = { $runGUID } },
                            @{ n = 'CollectedAt';       e = { $collectedAt } }

                        Write-ToCms -Data $agRows -Table '[DB].[AvailGroups]' -Section 'HA'

                        # AG Replicas
                        $repRows = $agGroups | ForEach-Object {
                            $agName = $_.Name
                            $_.AvailabilityReplicas | Select-Object `
                                @{ n = 'ServerName';         e = { $hostName } },
                                @{ n = 'InstanceName';       e = { $instance } },
                                @{ n = 'AGName';             e = { $agName } },
                                @{ n = 'ReplicaName';        e = { $_.Name } },
                                @{ n = 'AvailabilityMode';   e = { $_.AvailabilityMode } },
                                @{ n = 'FailoverMode';       e = { $_.FailoverMode } },
                                @{ n = 'ConnectionModeInPrimary';   e = { $_.ConnectionModeInPrimaryRole } },
                                @{ n = 'ConnectionModeInSecondary'; e = { $_.ConnectionModeInSecondaryRole } },
                                @{ n = 'BackupPriority';     e = { $_.BackupPriority } },
                                @{ n = 'EndpointUrl';        e = { $_.EndpointUrl } },
                                @{ n = 'LoadGUID';           e = { $runGUID } },
                                @{ n = 'CollectedAt';        e = { $collectedAt } }
                        }

                        Write-ToCms -Data $repRows -Table '[DB].[AvailReplicas]' -Section 'HA'

                        # AG Databases
                        $agDbRows = $agGroups | ForEach-Object {
                            $agName = $_.Name
                            $_.AvailabilityDatabases | Select-Object `
                                @{ n = 'ServerName';       e = { $hostName } },
                                @{ n = 'InstanceName';     e = { $instance } },
                                @{ n = 'AGName';           e = { $agName } },
                                @{ n = 'DBName';           e = { $_.Name } },
                                @{ n = 'SyncState';        e = { $_.SynchronizationState } },
                                @{ n = 'SyncHealth';       e = { $_.SynchronizationHealth } },
                                @{ n = 'IsSuspended';      e = { $_.IsSuspended } },
                                @{ n = 'LoadGUID';         e = { $runGUID } },
                                @{ n = 'CollectedAt';      e = { $collectedAt } }
                        }

                        Write-ToCms -Data $agDbRows -Table '[DB].[AvailDatabases]' -Section 'HA'
                    }
                    else {
                        Write-DbaLog "[HA] No Availability Groups found on $instance."
                    }
                    $sectionsDone.Add('HA')
                }
                catch {
                    Write-DbaLog "[HA] $($instance) - $($_.Exception.Message)" -Level WARN
                    $sectionsFailed.Add('HA')
                }
            }
            #endregion HA

            # =================================================================
            #region Section: SSRS
            # =================================================================
            if ($runAll -or $Sections -contains 'SSRS') {
                $stepName = "SSRS - $instance"

                if (-not $isWindows) {
                    Write-DbaLog "[SSRS] Skipped for Linux instance $instance." -Level WARN
                }
                else {
                    try {
                        # Get-DbaReportingService does not exist in dbatools.
                        # Use Get-DbaService -Type SSRS (ValidateSet value is 'SSRS').
                        $ssrsInfo = Get-DbaService -ComputerName $hostName -Type SSRS -EnableException
                        if ($ssrsInfo) {
                            $ssrsRows = $ssrsInfo | Select-Object `
                                @{ n = 'ServerName';          e = { $hostName } },
                                @{ n = 'InstanceName';        e = { $instance } },
                                ServiceName, DisplayName, State, StartMode,
                                @{ n = 'ServiceAccount';      e = { $_.StartName } },
                                @{ n = 'LoadGUID';            e = { $runGUID } },
                                @{ n = 'CollectedAt';         e = { $collectedAt } }

                            Write-ToCms -Data $ssrsRows -Table '[RS].[SSRSInfo]' -Section 'SSRS'
                        }
                        $sectionsDone.Add('SSRS')
                    }
                    catch {
                        Write-DbaLog "[SSRS] $($instance) - $($_.Exception.Message)" -Level WARN
                        $sectionsFailed.Add('SSRS')
                    }
                }
            }
            #endregion SSRS

            # =================================================================
            # Update CMS collection timestamp
            # =================================================================
            if ($PSCmdlet.ShouldProcess($instance, 'Update inventory collection timestamp in CentralDB')) {
                try {
                    Invoke-DbaQuery `
                        -SqlInstance    $CMSInstanceName `
                        -Database       $CMSDatabaseName `
                        -Query          'EXEC [Svr].[usp_SetCollectionLastRun] @CollectionType = @ct, @ServerName = @sv, @InstanceName = @in, @LoadGUID = @lg' `
                        -SqlParameters  @{ ct = 'Inventory'; sv = $hostName; in = $instancePart; lg = $runGUID } `
                        -CommandTimeout $CommandTimeout `
                        @cmsCredParam   -EnableException
                }
                catch {
                    Write-DbaLog "Failed to update collection timestamp for $($instance) - $($_.Exception.Message)" -Level WARN
                }
            }

            Write-DbaLog "=== Completed $instance. Sections done: $($sectionsDone -join ', '). Failed: $($sectionsFailed -join ', ') ==="

            $Script:Results.Add([PSCustomObject]@{
                PSTypeName       = 'CentralDB.InventoryResult'
                SqlInstance      = $instance
                SectionsDone     = $sectionsDone -join ', '
                SectionsFailed   = $sectionsFailed -join ', '
                LoadGUID         = $runGUID
                CollectedAt      = $collectedAt
                Status           = if ($sectionsFailed.Count -eq 0) { 'Success' } else { 'PartialSuccess' }
                ErrorMessage     = $null
            })
        }

        if ($instanceErrors.Count -gt 0) {
            $summary = $instanceErrors -join "`n"
            throw "Get-CentralInventory completed with $($instanceErrors.Count) instance error(s):`n$summary"
        }
    }

    # -------------------------------------------------------------------------
    end {
        $elapsedTime.Stop()
        $duration = $elapsedTime.Elapsed.ToString('hh\:mm\:ss')

        if ($Script:ErrorCount -gt 0) {
            Write-Warning "Get-CentralInventory completed with $Script:ErrorCount error(s) in $duration."
        }
        else {
            Write-DbaLog "Get-CentralInventory completed successfully in $duration."
        }

        #region Export Output
        $exportBase = Join-Path $OutputPath ("Inventory_$($env:COMPUTERNAME)_$(Get-Date -Format 'yyyyMMdd_HHmmss')")

        switch ($OutputFormat) {
            'CSV'      { $Script:Results | Export-Csv -Path "$exportBase.csv"  -NoTypeInformation }
            'JSON'     { $Script:Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$exportBase.json" -Encoding utf8 }
            'HTML'     { $Script:Results | ConvertTo-Html -Title 'CentralDB Inventory' | Out-File -FilePath "$exportBase.html" -Encoding utf8 }
            'GridView' { $Script:Results | Out-GridView -Title 'CentralDB Inventory' }
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
Get-CentralInventory @invokeParams -Confirm:$false
