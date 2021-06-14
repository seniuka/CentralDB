#####################################################################################################################################
# Get-OlaHallengren-Backup (https://seniuka.github.io/CentralDB/)
# This script will execute the database backup tasks
#	1.0 Miserable failure but nessisary evil
#	1.1 Again painfully problematic but needed
#	1.3 Had issues and logging to a file helped find the problems
#	1.5 overhauled and wrote in the logging to file system
#	1.6 Found out that executing this script from the CMS is the problem, it serializes the tasks which means it takes for ever to run.
#	1.8 Found a way to execute SQL agent jobs pre-defined by the CMS and pushed out to each managed server! so now I can execute this task on each server then send back the data
#	2.0 Rewrote entire script for the OlaHallegren upgrade as well as improved performance by added local execution details
#	2.1 Minor issues tweaking
#	2.2 Fixes for powershell 1.0 (eww 2008 servers)
#	2.3 Major overhaul of how the local task is executed now without the CMS until the push of data back into the CMS, with disabling of CMS execution and multiple job execution methods.
#   Current Version
#
#                                                            This script is brand spanking new; this baby could crash your server so hard! 
#####################################################################################################################################

#####################################################################################################################################
#Parameter List
param(
	[string]$CMSInstanceName="", #CMS Server with CentralDB
	[string]$CMSDatabaseName="CentralDB", #CMS Server with CentralDB
	[string]$InstanceName="", #CMS Server with CentralDB
	[string]$DatabaseName="CentralDB", #CMS Server with CentralDB
    [string]$runLocally="true", #This flag is used to reduce the number of remote powershell calls from a single cms by executing locally 	
    [int32] $CommandTimeout= 14400,	#seconds
    [string]$DeployScripts= 'Y',
    [string]$RunAsJob= 'N',
	[string]$IntroduceDelay = 'N',
	
    [string]$Databases= 'ALL_DATABASES',
    [string]$Directory= $null,
    [string]$BackupType= $null,
    [string]$Verify= 'Y', 
    [int32]$CleanupTime = $null,
    [string]$CleanupMode = 'AFTER_BACKUP',
    [string]$Compress = $null,
    [string]$CopyOnly = 'N',
    [string]$ChangeBackupType = 'N',
    [string]$BackupSoftware = $null,
    [string]$CheckSum = 'N',
    [int32]$BlockSize = $null,
    [int32]$BufferCount = $null,
    [int32]$MaxTransferSize = $null,
    [int32]$NumberOfFiles = $null,
    [string]$CompressionLevel = $null,
    [string]$Description = $null,
    [string]$Threads = $null,
    [string]$Throttle = $null,
    [string]$Encrypt = 'N',
    [string]$EncryptionAlgorithm = $null,
    [string]$ServerCertificate = $null,
    [string]$ServerAsymmetricKey = $null,
    [string]$EncryptionKey = $null,
    [string]$ReadWriteFileGroups = 'N',
    [string]$OverrideBackupPreference = 'N',
    [string]$NoRecovery = 'N',
    [string]$URL = $null,
    [string]$Credential = $null,
    [string]$MirrorDirectory = $null,
    [string]$MirrorCleanupTime = $null,
    [string]$MirrorCleanupMode = 'AFTER_BACKUP',
    [string]$MirrorURL = $null,
    [string]$AvailabilityGroups = $null,
    [string]$Updateability = 'ALL',
    [string]$AdaptiveCompression = $null,
    [int32]$TimeSinceLastLogBackup = $null,
    [string]$DataDomainBoostHost = $null,
    [string]$DataDomainBoostUser = $null,
    [string]$DataDomainBoostDevicePath = $null,
    [string]$DataDomainBoostLockboxPath = $null,
    [string]$DirectoryStructure = '{ServerName}${InstanceName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Partial}_{CopyOnly}',
    [string]$AvailabilityGroupDirectoryStructure = '{ClusterName}${AvailabilityGroupName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Partial}_{CopyOnly}',
    [string]$FileName = '{ServerName}${InstanceName}_{DatabaseName}_{BackupType}_{Partial}_{CopyOnly}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}',
    [string]$AvailabilityGroupFileName = '{ClusterName}${AvailabilityGroupName}_{DatabaseName}_{BackupType}_{Partial}_{CopyOnly}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}',
    [string]$FileExtensionFull = $null,
    [string]$FileExtensionDiff = $null,
    [string]$FileExtensionLog =  $null,
    [string]$Init = 'N',
    [string]$DatabaseOrder = $null,
    [string]$DatabasesInParallel = 'N',    
    [int32]$ModificationLevel = $null,

    [string]$LogToTable= 'Y',
	[string]$Execute= 'Y',
	[string]$LoadGUID= $null,

	[string]$OlaHallengrenDeployDB="tempdb",
	[string]$OlaHallengrenPath="", #Where does OlaHallengren live... path to the .sql files
	[string]$OlaHallengrenFilter = "",

	[string]$logPath="",
	[string]$logFileName="",

	[int]$DelaySecMin=60,
	[int]$DelaySecMax=600
	)
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement') | out-null
#####################################################################################################################################

$scriptVersion = "2.3"
$scriptName = "Get-OlaHallengren-Backup"

#####################################################################################################################################
# Start External Scripts 
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
write-output "### Start External Scripts #############################################################################################"

$LoadExternalScript = Join-Path $ScriptDir "Get-DeployFile.ps1"
Write-Output $LoadExternalScript
. $LoadExternalScript

$LoadExternalScript = Join-Path $ScriptDir "Write-Log.ps1"
Write-Output $LoadExternalScript
. $LoadExternalScript

$LoadExternalScript = Join-Path $ScriptDir "Out-DataTable.ps1"
Write-Output $LoadExternalScript
. $LoadExternalScript

$LoadExternalScript = Join-Path $ScriptDir "Write-DataTable.ps1"
Write-Output $LoadExternalScript
. $LoadExternalScript

$LoadExternalScript = Join-Path $ScriptDir "Get-Type.ps1"
Write-Output $LoadExternalScript
. $LoadExternalScript
write-output "### Finished External Scripts #########################################################################################"
#####################################################################################################################################

#####################################################################################################################################
# DeployScripts
function DeployScripts($localSQLServerConnection) 
{
	#################################################################################################################################
	# Local Instance Connection - Connect 
	try
    {
		$responds = $false
		$localInstanceNameSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$localSQLServerConnection;Integrated Security=SSPI;Initial Catalog=" + $OlaHallengrenDeployDB + ";");
		$s = new-object (‘Microsoft.SqlServer.Management.Smo.Server’) $localInstanceNameSQLConn
		$localInstanceNameSQLConn.Open()
		$Command = New-Object System.Data.SQLClient.SQLCommand 
		$Command.Connection = $localInstanceNameSQLConn 
		if ($Command.Connection.State -eq "open") {$responds = $true}  
		else
		{
			Throw "Could not connect to the local instance $localInstanceName, please review this the connection details. (Permissions/Invalid/NotRunning)"
		}
	}
	catch
	{
		$ex = $_.Exception
		$line = $_.InvocationInfo.PositionMessage
		write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." -Level Error -Path $logPath
		throw "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." 
	}
	#################################################################################################################################
	
    
	#################################################################################################################################
	# Local Instance - Deploy Code	
	if ($responds) 
	{
		try
		{
            $VersionPattern = '--// Version:'
            $fileVersions = Get-DeployFile $localSQLServerConnection $OlaHallengrenDeployDB $OlaHallengrenPath "*.sql" $VersionPattern
            Write-Log -Message "### FILE PROCSSING ############################################" -Level Info -Path $logPath
            foreach($fileVersion in $fileVersions)
            {            
                $SQLCommandText = @(Get-Content -Path $fileVersion) 
                $message = "### LOADING FILE " + $fileVersion
				Write-Log -Message $message -Level Info -Path $logPath  
                $i = 0
                foreach($SQLString in $SQLCommandText) 
                { 
                    if($SQLString.Trim() -ne "GO") 
                    { 
                        $i = $i + 1
                        $SQLPacket += $SQLString.Trim() + "`n"        
                    } 
                    else 
                    {  
                        if($SQLPacket.Length -gt 0)
                        {
                            $message = "### Executing " + $i + " lines." 
                            Write-Log -Message $message -Level Info -Path $logPath
                            $Command.CommandText = $SQLPacket 
                            $Command.ExecuteNonQuery()  | out-null 
                            $SQLPacket = ""
                            $SQLString = ""                           
                        }                       
                        $i = 0
                    }                                                 
                                        
                    if($SQLPacket.Length -eq 0 -AND $SQLString.Length -ne 0 -AND $SQLString.Trim() -ne "GO")
                    {
                        $SQLPacket = $SQLString.Trim() + "`n" 
                        if($SQLPacket.Length -gt 0)
                        {
                            $message = "### Executing ?!?" + $i + " lines." 
                            Write-Log -Message $message -Level Info -Path $logPath
                            $Command.CommandText = $SQLPacket 
                            $Command.ExecuteNonQuery() 
                            $SQLPacket = ""
                            $SQLString = ""
                        }                       
                        $i = 0
                    }             
                }                 

            }

            if ($localInstanceNameSQLConn.State -eq "Open"){$localInstanceNameSQLConn.Close()} 
			Write-Log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Instance $localSQLServerConnection" -Level Info -Path $logPath
		} 
		catch 
		{ 
            $ex = $_.Exception
            $line = $_.InvocationInfo.PositionMessage
	        write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localSQLServerConnection executing script." -Level Error -Path $logPath
		} 
		finally
		{
   			$ErrorActionPreference = "Stop"; #Reset the error action pref to default
            $localInstanceNameSQLConn.close | Out-Null
		}
	}
	else 
	{             
		write-log -Message "SQL Server DB Engine is not Installed or Started or inaccessible on $localInstanceName" -Path $logPath
	}
	#################################################################################################################################

} #Create-OlaHallengren
######################################################################################################################################

######################################################################################################################################
# ExecuteScripts
function ExecuteScripts($localSQLServerConnection) 
{
	#################################################################################################################################
	# Local Instance Connection - Connect 
	#write-host "ExecuteScripts | Local Instance Connection - Connect $GUID"
	try
    {
		$localInstanceNameSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$localSQLServerConnection;Integrated Security=SSPI;Initial Catalog=" + $OlaHallengrenDeployDB + ";");
		$s = new-object (‘Microsoft.SqlServer.Management.Smo.Server’) $localInstanceNameSQLConn
		$localInstanceNameSQLConn.Open()
		$Command = New-Object System.Data.SQLClient.SQLCommand 
		$Command.Connection = $localInstanceNameSQLConn 
		if ($localInstanceNameSQLConn.State -ne 1)
		{
			Throw "Could not connect to the local instance $localInstanceName, please review this the connection details. (Permissions/Invalid/NotRunning)"
		}
	}
	catch
	{
		$ex = $_.Exception
		$line = $_.InvocationInfo.PositionMessage
		write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." -Level Error -Path $logPath
		throw "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." 
	}
	#################################################################################################################################
	
	#################################################################################################################################
	# Local Instance Connection - Validation 
	#write-host "ExecuteScripts | Local Instance Connection - Validation $GUID"
	$result = new-object Microsoft.SqlServer.Management.Common.ServerConnection($localSQLServerConnection)
	$responds = $false
	if ($result.ProcessID -ne $null) {$responds = $true}  
	If ($responds) 
	{	
        try
        {	
			######################################################################################################################################
			# EXECUTE Procedure 
			try
			{
				if ($BackupType -eq "FULL"){$TypeName = 'Database Backup - Full'}
				if ($BackupType -eq "LOG"){$TypeName = 'Database Backup - Transaction Log'}
				if ($BackupType -eq "DIFF"){$TypeName = 'Database Backup - Differential'}

				$sc = $localInstanceNameSQLConn.CreateCommand()                    
				Write-Log -Message "### EXECUTING Maintenance ############################################" -Level Info -Path $logPath			 
				$query = "EXEC [$OlaHallengrenDeployDB].dbo.[DatabaseBackup] "
				if (![string]::IsNullOrEmpty($Databases)){$query = $query + "@Databases = '$Databases',"}
				if (![string]::IsNullOrEmpty($Directory)){$query = $query + "@Directory = '$Directory',"}
				if (![string]::IsNullOrEmpty($BackupType)){$query = $query + "@BackupType = '$BackupType',"}
				if (![string]::IsNullOrEmpty($Verify)){$query = $query + "@Verify = '$Verify',"}
				if (![string]::IsNullOrEmpty($CleanupTime)){$query = $query + "@CleanupTime = $CleanupTime,"}
				if (![string]::IsNullOrEmpty($CleanupMode)){$query = $query + "@CleanupMode = '$CleanupMode',"}
				if (![string]::IsNullOrEmpty($Compress)){$query = $query + "@Compress = '$Compress',"}
				if (![string]::IsNullOrEmpty($CopyOnly)){$query = $query + "@CopyOnly = '$CopyOnly',"}
				if (![string]::IsNullOrEmpty($ChangeBackupType)){$query = $query + "@ChangeBackupType = '$ChangeBackupType',"}
				if (![string]::IsNullOrEmpty($BackupSoftware)){$query = $query + "@BackupSoftware = '$BackupSoftware',"}
				if (![string]::IsNullOrEmpty($CheckSum)){$query = $query + "@CheckSum = '$CheckSum',"}
				if($BlockSize){$query = $query + "@BlockSize = $BlockSize,"}
				if($BufferCount){$query = $query + "@BufferCount = $BufferCount,"}
				if($MaxTransferSize){$query = $query + "@MaxTransferSize = $MaxTransferSize,"}
				if($NumberOfFiles){$query = $query + "@NumberOfFiles = $NumberOfFiles,"}
				if (![string]::IsNullOrEmpty($CompressionLevel)){$query = $query + "@CompressionLevel = $CompressionLevel,"}
				if (![string]::IsNullOrEmpty($Description)){$query = $query + "@Description = '$Description',"}
				if (![string]::IsNullOrEmpty($Threads)){$query = $query + "@Threads = $Threads,"}
				if (![string]::IsNullOrEmpty($Throttle)){$query = $query + "@Throttle = $Throttle,"}
				if (![string]::IsNullOrEmpty($Encrypt)){$query = $query + "@Encrypt = '$Encrypt',"}
				if (![string]::IsNullOrEmpty($EncryptionAlgorithm)){$query = $query + "@EncryptionAlgorithm = '$EncryptionAlgorithm',"}
				if (![string]::IsNullOrEmpty($ServerCertificate)){$query = $query + "@ServerCertificate = '$ServerCertificate',"}
				if (![string]::IsNullOrEmpty($ServerAsymmetricKey)){$query = $query + "@ServerAsymmetricKey = '$ServerAsymmetricKey',"}
				if (![string]::IsNullOrEmpty($EncryptionKey)){$query = $query + "@EncryptionKey = '$EncryptionKey',"}
				if (![string]::IsNullOrEmpty($ReadWriteFileGroups)){$query = $query + "@ReadWriteFileGroups = '$ReadWriteFileGroups',"}
				if (![string]::IsNullOrEmpty($OverrideBackupPreference)){$query = $query + "@OverrideBackupPreference = '$OverrideBackupPreference',"}
				if (![string]::IsNullOrEmpty($NoRecovery)){$query = $query + "@NoRecovery = '$NoRecovery',"}
				if (![string]::IsNullOrEmpty($URL)){$query = $query + "@URL = '$URL',"}
				if (![string]::IsNullOrEmpty($Credential)){$query = $query + "@Credential = '$Credential',"}
				if (![string]::IsNullOrEmpty($MirrorDirectory)){$query = $query + "@MirrorDirectory = '$MirrorDirectory',"}
				if (![string]::IsNullOrEmpty($MirrorCleanupTime)){$query = $query + "@MirrorCleanupTime = $MirrorCleanupTime,"}
				if (![string]::IsNullOrEmpty($MirrorCleanupMode)){$query = $query + "@MirrorCleanupMode = '$MirrorCleanupMode',"}
				if (![string]::IsNullOrEmpty($MirrorURL)){$query = $query + "@MirrorURL = '$MirrorURL',"}
				if (![string]::IsNullOrEmpty($AvailabilityGroups)){$query = $query + "@AvailabilityGroups = '$AvailabilityGroups',"}
				if (![string]::IsNullOrEmpty($Updateability)){$query = $query + "@Updateability= '$Updateability',"}
				if (![string]::IsNullOrEmpty($AdaptiveCompression)){$query = $query + "@AdaptiveCompression= '$AdaptiveCompression',"}
				if($TimeSinceLastLogBackup){$query = $query + "@TimeSinceLastLogBackup = $TimeSinceLastLogBackup,"}
				if (![string]::IsNullOrEmpty($DataDomainBoostHost)){$query = $query + "@DataDomainBoostHost= '$DataDomainBoostHost',"}
				if (![string]::IsNullOrEmpty($DataDomainBoostUser)){$query = $query + "@DataDomainBoostUser= '$DataDomainBoostUser',"}
				if (![string]::IsNullOrEmpty($DataDomainBoostDevicePath)){$query = $query + "@DataDomainBoostDevicePath= '$DataDomainBoostDevicePath',"}
				if (![string]::IsNullOrEmpty($DataDomainBoostLockboxPath)){$query = $query + "@DataDomainBoostLockboxPath= '$DataDomainBoostLockboxPath',"}
				if (![string]::IsNullOrEmpty($DirectoryStructure)){$query = $query + "@DirectoryStructure= '$DirectoryStructure',"}
				if (![string]::IsNullOrEmpty($AvailabilityGroupDirectoryStructure)){$query = $query + "@AvailabilityGroupDirectoryStructure= '$AvailabilityGroupDirectoryStructure',"}
				if (![string]::IsNullOrEmpty($FileName)){$query = $query + "@FileName= '$FileName',"}
				if (![string]::IsNullOrEmpty($AvailabilityGroupFileName)){$query = $query + "@AvailabilityGroupFileName= '$AvailabilityGroupFileName',"}
				if (![string]::IsNullOrEmpty($FileExtensionFull)){$query = $query + "@FileExtensionFull= '$FileExtensionFull',"}
				if (![string]::IsNullOrEmpty($FileExtensionDiff)){$query = $query + "@FileExtensionDiff= '$FileExtensionDiff',"}
				if (![string]::IsNullOrEmpty($FileExtensionLog)){$query = $query + "@FileExtensionLog= '$FileExtensionLog',"}
				if (![string]::IsNullOrEmpty($Init)){$query = $query + "@Init= '$Init',"}
				if (![string]::IsNullOrEmpty($DatabaseOrder)){$query = $query + "@DatabaseOrder= '$DatabaseOrder',"}
				if (![string]::IsNullOrEmpty($DatabasesInParallel)){$query = $query + "@DatabasesInParallel= '$DatabasesInParallel',"}
				if($ModificationLevel){$query = $query + "@ModificationLevel = $ModificationLevel,"}
				if (![string]::IsNullOrEmpty($LogToTable)){$query = $query + "@LogToTable= '$LogToTable',"}
				if (![string]::IsNullOrEmpty($Execute)){$query = $query + "@Execute= '$Execute',"}
				if (![string]::IsNullOrEmpty($LoadGUID)){$query = $query + "@LoadGUID = '$LoadGUID'"}

				Write-Output $query
				$sc.CommandText = $query
				$da = new-object System.Data.SqlClient.SqlDataAdapter $sc  
				$da.SelectCommand.CommandTimeout = $CommandTimeout       
				$ds = new-object System.Data.DataSet
				$da.fill($ds) | out-null
			}
			catch
			{
				$ex = $_.Exception
				$line = $_.InvocationInfo.PositionMessage
				write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." -Level Error -Path $logPath
				throw "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." 
			}
			######################################################################################################################################

			######################################################################################################################################
			# CENTRALIZING Data 
			#write-host "ExecuteScripts | CENTRALIZING Data $GUID"
			try
			{
				if ($cn.State -ne 1)
				{
					try
					{
						$cn = new-object system.data.sqlclient.sqlconnection("server=$CMSInstanceName;database=$CMSDatabaseName;Integrated Security=true;");
						$cn.Open(); 
						$cmd = $cn.CreateCommand();
						$state = $true
					}
					catch
					{
						$ex = $_.Exception.Message
                        $state = $false
					}
				}

				if ($state)
				{
					Write-Log -Message "### CENTRALIZING DatabaseBackup Data ############################################" -Level Info -Path $logPath	
					$CITbl = "[inst].[CommandLog]"	
					$query = "SELECT  
									 replace(replace([DatabaseName], ')', ''), '(', '')
									,[SchemaName]
									,[ObjectName]
									,[ObjectType]
									,[IndexName]
									,[IndexType]
									,[StatisticsName]
									,[PartitionNumber]
									,CAST(extendedinfo as nvarchar(max))
									,[Command]
									,[CommandType]
									,[StartTime]
									,[EndTime]
									,[ErrorNumber]
									,[ErrorMessage]
									,@@SERVERNAME
									,'$TypeName'
									,CAST(LoadGUID as uniqueidentifier)
							  FROM [$OlaHallengrenDeployDB].dbo.CommandLog 
							  WHERE LoadGUID = '$LoadGUID'"
					Write-Output $query
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $localInstanceNameSQLConn)
					$dt = new-object System.Data.DataTable
					$da.fill($dt) | out-null            
					Write-DataTable -ServerInstance $CMSInstanceName -Database $CMSDatabaseName -TableName $CITbl -Data $dt -Verbose | out-null  
					$cn.close | Out-Null	
				}
				else{ Write-Log -Message "#######################################################################################
###
### WARNING Centralizing Maintenance Data incomplete 
### Unable to connect to $CMSInstanceName on $CMSDatabaseName
###
#######################################################################################" -Level Info -Path $logPath
					$query = "EXEC [$OlaHallengrenDeployDB].dbo.ErrorReturn "
					$query = $query + "@errorMessage = 'Unable to connect to $CMSInstanceName to centralize the data. Powershell Exception [$ex]'"
					$localInstanceNameSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$localSQLServerConnection;Integrated Security=SSPI;Initial Catalog=" + $OlaHallengrenDeployDB + ";");
					$s = new-object (‘Microsoft.SqlServer.Management.Smo.Server’) $localInstanceNameSQLConn
					$localInstanceNameSQLConn.Open()
					$Command = New-Object System.Data.SQLClient.SQLCommand 
					$Command.Connection = $localInstanceNameSQLConn 
					if ($localInstanceNameSQLConn.State -ne 1)
					{
						Throw "Could not connect to the local instance $localInstanceName, please review this the connection details. (Permissions/Invalid/NotRunning)"
					}					
					$sc = $localInstanceNameSQLConn.CreateCommand()                    
					Write-Log -Message "### WARNING Centralizing Maintenance Data incomplete ############################################" -Level Info -Path $logPath			 
					#$query = "EXEC dbo.ErrorReturn , @errorSeverity = 16, @errorState = 1;"
					Write-Log -Message $query -Level Info -Path $logPath
					Write-Output $query
					$sc.CommandText = $query
					$da = new-object System.Data.SqlClient.SqlDataAdapter $sc  
					$da.SelectCommand.CommandTimeout = $CommandTimeout       
					$ds = new-object System.Data.DataSet
					$da.fill($ds) #| out-null  
				   }
			}
			catch
			{
				$ex = $_.Exception
				$line = $_.InvocationInfo.PositionMessage
				write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." -Level Error -Path $logPath 
				throw "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." 
			}
			######################################################################################################################################

			######################################################################################################################################
			# CLEARING Data
			#write-host "ExecuteScripts | CLEARING Data $GUID"
            try
			{
				Write-Log -Message "### CLEAR LOCAL DatabaseBackup Data #########################################" -Level Info -Path $logPath
				$query = "IF OBJECT_ID (N'CommandLog', N'U') IS NOT NULL BEGIN DELETE FROM [$OlaHallengrenDeployDB].dbo.CommandLog WHERE LoadGUID = '$LoadGUID' END; 
						  IF OBJECT_ID (N'QueueDatabase', N'U') IS NOT NULL BEGIN DELETE FROM [$OlaHallengrenDeployDB].[dbo].[QueueDatabase] where RequestStartTime <= dateadd(day, -1, getDate()) END;
						  IF OBJECT_ID (N'Queue', N'U') IS NOT NULL BEGIN DELETE FROM [$OlaHallengrenDeployDB].[dbo].[Queue] where RequestStartTime <= dateadd(day, -1, getDate()) END;
						  IF OBJECT_ID (N'CommandLog', N'U') IS NOT NULL BEGIN DELETE FROM [$OlaHallengrenDeployDB].[dbo].[CommandLog] where [EndTime] <= dateadd(day, -1, getDate()) END;"
				#Write-Output $query
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $localInstanceNameSQLConn)
				#write-host "here1"
				$dt = new-object System.Data.DataTable
				#write-host "here2"
				$da.fill($dt) | out-null
				#write-host "here3"
			}
			catch
			{
				$ex = $_.Exception
				$line = $_.InvocationInfo.PositionMessage
				#write-host "here !"
				write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." -Level Error -Path $logPath 
				throw "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." 
			}
			######################################################################################################################################

	        ######################################################################################################################################
			# Updating Inventory Data
			#write-host "ExecuteScripts | Updating Inventory Data DateTime Executed"
            try
			{                            		
				if ($BackupType -eq "FULL"){$queryUpdate = "UPDATE [Svr].[ServerList] SET [MaintBkFullLastExecDate] = SYSDATETIME() WHERE Inventory='True' and ServerName = '$env:computername';"; $TypeName = 'Database Backup - Full'}
				if ($BackupType -eq "LOG"){$queryUpdate = "UPDATE [Svr].[ServerList] SET [MaintBkLogLastExecDate] = SYSDATETIME() WHERE Inventory='True' and ServerName = '$env:computername';"; $TypeName = 'Database Backup - Transaction Log'}
				if ($BackupType -eq "DIFF"){$queryUpdate = "UPDATE [Svr].[ServerList] SET [MaintBkDiffLastExecDate] = SYSDATETIME() WHERE Inventory='True' and ServerName = '$env:computername';"; $TypeName = 'Database Backup - Differential'}
                Write-Log -Message "### Updating Last Exec Date $TypeName #########################################" -Level Info -Path $logPath	
                $CMSServerConn = new-object system.data.sqlclient.sqlconnection("server=$CMSInstanceName;database=$CMSDatabaseName;Integrated Security=true;Pooling=True");
                $CMSServerConn.Open(); 	
				$cmdUpdate = $CMSServerConn.CreateCommand()
                $cmdUpdate.CommandText = $queryUpdate
				$adUpdate = New-Object system.data.sqlclient.sqldataadapter ($cmdUpdate.CommandText, $CMSServerConn)
			    $dsUpdate = New-Object system.data.dataset
			    $adUpdate.Fill($dsUpdate)
			    $CMSServerConn.Close()	
			}
			catch
			{
				$ex = $_.Exception
				$line = $_.InvocationInfo.PositionMessage
				#write-host "here !"
				write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." -Level Error -Path $logPath 
				throw "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." 
			}
			######################################################################################################################################
		} 
		catch 
		{ 
			$ex = $_.Exception 
			$line = $_.InvocationInfo.PositionMessage
			write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." -Level Error -Path $logPath 
		} 
		finally
		{
			$ex = $_.Exception 
			$line = $_.InvocationInfo.PositionMessage
   			$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			#throw "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." 
            $cn.close | Out-Null
		}
	}
	else 
	{             
		write-log -Message "SQL Server DB Engine is not Installed or Started or inaccessible on $localInstanceName" -Path $logPath
	}
	#################################################################################################################################

} #Get-OlaHallengren
######################################################################################################################################

######################################################################################################################################
#Execute Script
try
{
	if (![string]::IsNullOrEmpty($InstanceName)) {$CMSInstanceName = $InstanceName}
	if (![string]::IsNullOrEmpty($DatabaseName)) {$CMSDatabaseName = $DatabaseName}
	
	######################################################################################################################################
	#Prepare default values and validations of incoming values
	#	No Error logging can occur in here until after the log path and log file have been defined. 
	#	If an error occurs in here it would only be captured on logging within the powershell window.   
	if ([string]::IsNullOrEmpty($LoadGUID)){$LoadGUID = [guid]::NewGuid().ToString()}	
	#write-host "Generated GUID: $LoadGUID"

	#############################################################
	#Validate $logPath	
	#write-host "### Validate logPath" 
	try 
	{ 
		if ($logPath -notmatch '.+?\\$') { $logPath += '\' } 
		$path = Test-Path -Path $logPath
		if ($path -ne 1)
		{
			Throw "Get-OlaHallengren-Backup-$scriptVersion.ps1 | The path for logging could not be found. $logPath, please review this path. (Permissions?)"
		}
		else
		{
			if ($DatabasesInParallel -eq 'Y' -AND $RunAsJob -eq 'Y'){$logFileName = "Get-OlaHallengren-Backup-Master_" + $env:computername + ".log";}
			else{$logFileName = "Get-OlaHallengren-Backup-Job_" + $env:computername + "_" + $pid + ".log";}
			if( $debug = 'Y'){write-host "logFile:$logPath | logFileName: $logFileName"}
			$logPath = $logPath + $logFileName
		}
	}
	catch
	{
		$ex = $_.Exception
		$line = $_.InvocationInfo.PositionMessage
		write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $env:computername executing script." -Level Error -Path $logPath 
	}	
	#############################################################
	
	#############################################################
	#Validate $OlaHallengrenPath and $DeployScripts
	#write-host "### Validate OlaHallengrenPath DeployScripts" 
	if ($OlaHallengrenPath -notmatch '.+?\\$') {$OlaHallengrenPath += '\' } 	
	if ([string]::IsNullOrEmpty($DeployScripts)){$DeployScripts = 'Y'}
	if ($DeployScripts -eq 'Y')
	{
		try 
		{ 
			$path = Test-Path -Path $OlaHallengrenPath
			if ($path -ne 1)
			{
				Throw "Get-OlaHallengren-Backup-$scriptVersion.ps1 | The path for OlaHallengren could not be found. $OlaHallengrenPath, please review this path. (Permissions?)"
			}
		}
		catch
		{
			$ex = $_.Exception
			$line = $_.InvocationInfo.PositionMessage
			write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $env:computername executing script." -Level Error -Path $logPath 
		}
	}
	#############################################################
	
	######################################################################################################################################
	   		
	######################################################################################################################################
	#Starting Script
	$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()	
    write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Script Started at $(get-date)" -Path $logPath
	######################################################################################################################################

	######################################################################################################################################
	# Local Execution	
	#write-host "### runLocally" 
	if ($runLocally -eq "true")
	{
		#############################################################
		# Local Execution Loop [Instance]
		$localServerName = $env:computername	
		$localInstanceNames = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
		if($DatabasesInParallel -eq "y"){$processorCount = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors}
		write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Starting Local Execution $localServerName" -Path $logPath
		foreach ($localInstanceName in $localInstanceNames) 
		{
			### Default Instance and Service Name Lookup
			if($localInstanceName -eq "MSSQLSERVER") {$ServiceName = $localInstanceName; $localInstanceName = $localServerName;}
			### Custom Instance and Service Name Lookup	
			else {$ServiceName = 'MSSQL$' + $localInstanceName; $localInstanceName = $localServerName + '\' +  $localInstanceName;}
				
			$chkService = Get-Service -Name $ServiceName
			If ($chkService.Status -eq 'Running'){$chkServiceRunning = $true}
			Else{$chkServiceRunning = $false}

			if($chkServiceRunning -eq $true)
			{	
                
				#############################################################
				# Validate SQL Server Connection
				#write-host "### Validate SQL Server Connection" 	
				if ([string]::IsNullOrEmpty($localInstanceName)) { $localSQLServerConnection = $localServerName } 
				else {$localSQLServerConnection = $localInstanceName}
				#############################################################
                Write-Host "### Successfully connected to local instance $localSQLServerConnection #########################################"

				#############################################################
				# Deploy Scripts
				#write-host "### Deploy Scripts" 	
				if ($DeployScripts -eq 'Y'){write-log -Message "DeployScripts: $DeployScripts" -Path $logPath; DeployScripts $localSQLServerConnection}	
				#############################################################

				#############################################################
				# Execute Scripts
				#write-host "### Execute Scripts" 	
				write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Starting Execution of $LoadGUID on $localSQLServerConnection" -Path $logPath
				ExecuteScripts $localSQLServerConnection
				#############################################################
			}
			else
			{
				write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Instance $localInstanceName on $localServerName is not running."  -Path $logPath
			}
		}			
		#############################################################
	}
	######################################################################################################################################

	######################################################################################################################################
	# Remote Execution
	else
	{
		#############################################################
		# Connect to SQL Server CMS
		try 
		{ 
			$cn = new-object system.data.sqlclient.sqlconnection(“server=$CMSInstanceName;database=$CMSDatabaseName;Integrated Security=true;”);
			$cn.Open(); $cmd = $cn.CreateCommand()
		}
		catch
		{
			$ex = $_.Exception
			$line = $_.InvocationInfo.PositionMessage
			write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." -Level Error -Path $logPath 
		}
		#############################################################

		#############################################################
		# Query
		#if ($cn.State == ConnectionState.Open)
		#{
		#	$query = "SELECT DISTINCT ServerName, InstanceName, isnull(NumberOfLogicalProcessors, 1) NumberOfLogicalProcessors 
		#				FROM [CentralDB].[Svr].[ServerList] 
		#		        LEFT OUTER JOIN (SELECT DISTINCT ServerName SvrName, NumberOfLogicalProcessors 
		#								FROM [CentralDB].[Svr].[ServerInfo] 
		#								INNER JOIN (SELECT ServerName as SvrNm, MAX(SvrID) SvrID 
		#								FROM [CentralDB].[Svr].[ServerInfo] group by ServerName) svr on svr.SvrID = [ServerInfo].SvrID) svr on svr.SvrName = [ServerList].ServerName"
		#	$cmd.CommandText = $query
		#	$reader = $cmd.ExecuteReader()
		#	if($reader.HasRows)
		#	{
		#		while($reader.Read()) 
		#		{
		#			write-host "here4:"
		#			write-host "step 2:" + $LoadGUID
		#			$server = $reader['ServerName']
		#			$localInstanceName = $reader['InstanceName']  
		#			$processorCount = $reader['NumberOfLogicalProcessors']  #Processor Count for Multi 	
		
		#			if ([string]::IsNullOrEmpty($localInstanceName)) { $localSQLServerConnection = $server } 
		#			elseif ($localInstanceName -match "\\"){$localSQLServerConnection = $localInstanceName}
		#			else {$localSQLServerConnection = $server + "\" + $localInstanceName} 
        
		#			$res = new-object Microsoft.SqlServer.Management.Common.ServerConnection($localSQLServerConnection)
		#			$responds = $false            
		#			if ($res.ProcessID -ne $null){$responds = $true; $res.Disconnect()} #Verify Connectivity

		#			If ($responds) 
		#			{
		#				write-host "step 3:" + $LoadGUID
		#				if ($IntroduceDelay -eq 'Y')
		#				{                
		#					$randomNo = new-object system.random
		#					$delay = $randomNo.Next(60, 600)
		#					write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Delay process of $delay seconds" -Path $logPath
		#					Start-Sleep -seconds $delay
		#				}
			
		#				if ($DeployScripts -eq 'Y'){write-log -Message "DeployScripts: $DeployScripts" -Path $logPath; Create-OlaHallengren $localSQLServerConnection}			
		#				$i = 0     
		#				if ($DatabasesInParallel -eq 'Y' -AND $RunAsJob -eq 'Y')
		#				{
		#					write-host "step 4:" + $LoadGUID
		#					Remove-Job -State Completed 
		#					Remove-Job -State Failed
		#					write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Starting to execute multi thread" -Path $logPath
		#					$ScriptName = split-path $MyInvocation.InvocationName -Leaf
		#					$logPathCall = split-path $logPath -parent
		#					$FilePath = $MyInvocation.InvocationName
		#					$randomNo = new-object system.random
				
		#					while($i -lt $processorCount)
		#					{   
					
		#						write-host "step 5:" + $LoadGUID
		#						$delay = $randomNo.Next(10, 1000)
		#						$RunAsJob = 'N' #Set to no to actually execute process instead of generating loop with job 
		#						$IntroduceDelay = 'N' #Set to no to actually execute process instead of generating delay
		#						$DeployScripts = 'N' #Set to no because we deployed the scripts already
		#						$i = $i + 1
		#						$logFileName = "Get-OlaHallengren-Backup-Job_" + $env:computername + "_$i-of-$processorCount.log";
		#						$Name = "$ScriptName - $LoadGUID [$i of $processorCount]"   
		#						write-host $FilePath
		#						$job = Start-Job -Verbose -Name $Name -FilePath $FilePath -ArgumentList $CMSInstanceName,$CMSDatabaseName,$runLocally,$CommandTimeout,$DeployScripts,$RunAsJob,$IntroduceDelay,$Databases,$Directory,$BackupType,$Verify,$CleanupTime,$CleanupMode,$Compress,$CopyOnly,$ChangeBackupType,$BackupSoftware,$CheckSum,$BlockSize,$BufferCount,$MaxTransferSize,$NumberOfFiles,$CompressionLevel,$Description,$Threads,$Throttle,$Encrypt,$EncryptionAlgorithm,$ServerCertificate,$ServerAsymmetricKey,$EncryptionKey,$ReadWriteFileGroups,$OverrideBackupPreference,$NoRecovery,$URL,$Credential,$MirrorDirectory,$MirrorCleanupTime,$MirrorCleanupMode,$MirrorURL,$AvailabilityGroups,$Updateability,$AdaptiveCompression,$TimeSinceLastLogBackup,$DataDomainBoostHost,$DataDomainBoostUser,$DataDomainBoostDevicePath,$DataDomainBoostLockboxPath,$DirectoryStructure,$AvailabilityGroupDirectoryStructure,$FileName,$AvailabilityGroupFileName,$FileExtensionFull,$FileExtensionDiff,$FileExtensionLog,$Init,$DatabaseOrder,$DatabasesInParallel,$ModificationLevel,$LogToTable,$Execute,$LoadGUID,$OlaHallengrenDeployDB,$OlaHallengrenPath,$OlaHallengrenFilter,$logPathCall,$logFileName
		#						Receive-Job -Job $job  
		#						write-host $job
		#						write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Spooling up thread for $ScriptName $LoadGUID : $i of $processorCount" -Path $logPath
		#						Start-Sleep -Milliseconds 100
		#					}

		#					write-host "step 6:" + $LoadGUID
		#					$count = (Get-Job -Name *$LoadGUID* | Where-Object State -EQ Running | Select-Object Id | Measure).Count
		#					if ([string]::IsNullOrEmpty($count)){$count = 0}
		#					While($count -gt 0)
		#					{
		#						$count = (Get-Job -Name *$LoadGUID* | Where-Object State -EQ Running | Select-Object Id | Measure).Count
		#						if ([string]::IsNullOrEmpty($count)){$count = 0}
		#						$delay = $randomNo.Next(10, 1000)
		#						Start-Sleep -Milliseconds $delay
		#						write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Waiting for threads to finish... [$($ElapsedTime.Elapsed.ToString())]" -Path $logPath
		#						Start-Sleep -Seconds 60                    
		#					}  
                
		#					$count = (Get-Job -Name *$LoadGUID* | Where-Object State -EQ Completed | Select-Object Id | Measure).Count
		#					if($count -gt 0)
		#					{
		#						write-host "step 7:" + $LoadGUID
		#						Write-Log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | CLEAR LOCAL Jobs and Queue #########################################" -Level Info -Path $logPath
		#						Remove-Job -Name *$LoadGUID*				
										
		#						$localInstanceNameSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$localInstanceName;Integrated Security=SSPI;Initial Catalog=" + $OlaHallengrenDeployDB + ";");
		#						$s = new-object (‘Microsoft.SqlServer.Management.Smo.Server’) $localInstanceNameSQLConn
		#						$localSQLServerConnection = $localInstanceName
		#						$localInstanceNameSQLConn.Open()
		#						$Command = New-Object System.Data.SQLClient.SQLCommand 
		#						$Command.Connection = $localInstanceNameSQLConn 			
		#						$query = "IF OBJECT_ID (N'CommandLog', N'U') IS NOT NULL BEGIN DELETE FROM [" + $OlaHallengrenDeployDB + "].dbo.CommandLog WHERE LoadGUID = '$LoadGUID' END;
		#									IF OBJECT_ID (N'QueueDatabase', N'U') IS NOT NULL BEGIN DELETE FROM [" + $OlaHallengrenDeployDB + "].[dbo].[QueueDatabase] WHERE [QueueID] in (SELECT QueueID FROM [$OlaHallengrenDeployDB].[dbo].[Queue] WHERE [Parameters] like '%$LoadGUID%') END;
		#									IF OBJECT_ID (N'Queue', N'U') IS NOT NULL BEGIN DELETE FROM [" + $OlaHallengrenDeployDB + "].[dbo].[Queue] WHERE [Parameters] like '%$LoadGUID%' END;"
		#						$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $localInstanceNameSQLConn)
		#						$dt = new-object System.Data.DataTable
		#						$da.fill($dt) | out-null					
		#						#$Command.close | Out-Null
		#						#$localInstanceNameSQLConn.close | Out-Null
		#					}                              
		#				}
		#				else
		#				{
		#					write-host "step 8:" + $LoadGUID		
		#					write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Starting Execution of $LoadGUID" -Path $logPath
		#					#if ($DeployScripts -eq 'Y'){write-log -Message "DeployScripts: $DeployScripts" -Path $logPath;Create-OlaHallengren $server $localInstanceName $type;}
		#					Get-OlaHallengren $server $localInstanceName
		#				}            
		#			}
		#			else 
		#			{
  #						# Let the user know we couldn't connect to the server
		#				if ($localInstanceName -eq ""){$message = "$server did not respond. Please check connectivity and try again."} #Unnamed Instances (Default)
		#				elseif ($localInstanceName -match "\\") {$message = $localInstanceName + " did not respond. Please check connectivity and try again."} #Named Instances
		#				else {$message = $server + "\" +  $localInstanceName + " did not respond. Please check connectivity and try again."}	#Split Named Instances
		#				write-log -Message $message -Path $logPath
		#			}  
		#			#$LoadGUID = $null;
		#			write-host "step 9:" + $LoadGUID	
		#		}    
		#	}
		#	else
		#	{
  #    			write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | $env:computername was not found within the ServerList Table. Please add this and try again."  -Path $logPath  
		#	}
		#}
		#else
		#{
		#	write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Could not connect to CMS server." -Level Error -Path $logPath 	
		#}
		#####################################################################################################################################
}
	
	write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Script Ended at $(get-date)"  -Path $logPath
	write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"  -Path $logPath
}
catch
{
    $ex = $_.Exception
    $line = $_.InvocationInfo.PositionMessage
	write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $localServerName executing script." -Level Error -Path $logPath 
}
#Execute Script
######################################################################################################################################


############################################################################################################################################################
<# 
	Special thanks to Brent Ozar and Brent Ozar LTD (All of the people who created OlaHallengren) 
	for the hard work they do providing us with exceptional scripts to assist with DBA tasks.
	Please check out OlaHallengren.org to get the newest version! Also say thanks.
#>
############################################################################################################################################################
