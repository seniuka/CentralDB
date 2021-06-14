#####################################################################################################################################
# Get-OlaHallengren-Integrity (https://seniuka.github.io/CentralDB/)
# This script will execute the database integrity checks
#
# Assumptions: 
#    This script will be executed by a service account with sysadmin or elevated privleges to the database server.
#    This script uses intergrated authentication to insert data into the central management db, this service account will need permissions to insert data.
#
#                                                            This script is brand spanking new; this baby could crash your server so hard! 
#####################################################################################################################################

#####################################################################################################################################
#Parameter List
param(
	[string]$InstanceName="", #CMS Server with CentralDB
	[string]$DatabaseName="CentralDB", #CMS Server with CentralDB
    [string]$runLocally="true", #This flag is used to reduce the number of remote powershell calls from a single cms by executing locally 	
    [int32] $CommandTimeout= 14400,	#seconds
    [string]$DeployScripts= 'Y',
    [string]$RunAsJob= 'N',
    [string]$IntroduceDelay = 'N',
	
    [string]$Databases = 'ALL_DATABASES',
    [string]$CheckCommands = 'CHECKDB',
    [string]$PhysicalOnly = 'Y',
    [string]$NoIndex = 'N',
    [string]$ExtendedLogicalChecks = 'N',
    [string]$TabLock = 'N',
    [string]$FileGroups = $null,
    [string]$Objects = $null,
    [int32] $MaxDOP = $null,
    [string]$AvailabilityGroups = $null,
    [string]$AvailabilityGroupReplicas = 'ALL',
    [string]$Updateability = 'ALL',
    [int32] $TimeLimit = $null,
    [int32] $LockMessageSeverity = 16,
    [string]$DatabaseOrder = $null,
    [string]$DatabasesInParallel = 'N',
    [int32] $LockTimeout = 10800, #seconds
    [string]$LogToTable = 'Y',
	[string]$Execute = 'Y',
	[string]$LoadGUID = $null,

	[string]$OlaHallengrenDeployDB = "tempdb",
	[string]$OlaHallengrenPath = "", #Where does OlaHallengren live... path to the .sql files
	[string]$OlaHallengrenFilter = "", #"CommandExecute.sql|DatabaseIntegrityCheck.sql|Queue.sql|QueueDatabase.sql|Version.sql"

	[string]$logPath="",
	[string]$logFileName=""
	)
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement') | out-null
#####################################################################################################################################

### Start External Scripts ##########################################################################################################
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
#Create-OlaHallengren	[Function to get Server list info]
function Create-OlaHallengren($svr, $inst) 
{

    if ([string]::IsNullOrEmpty($inst))
    { $ServerInstance = $svr } else { $ServerInstance = $inst } 

	### Connect to SQL Instance Executing Script ######################################################################################
	write-host "step 3.1: Connect to SQL Instance Executing Script" + $LoadGUID
	$InstanceSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$inst;Integrated Security=SSPI;Initial Catalog=" + $OlaHallengrenDeployDB + ";");
    $sc = $InstanceSQLConn.CreateCommand()  
    $s = new-object (‘Microsoft.SqlServer.Management.Smo.Server’) $InstanceSQLConn
	$SQLServerConnection = $inst
    $InstanceSQLConn.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand 
    $Command.Connection = $InstanceSQLConn 

	### Create Object Deploy Code #####################################################################################################	
	write-host "step 3.2: Create Object Deploy Code" + $LoadGUID
	$result = new-object Microsoft.SqlServer.Management.Common.ServerConnection($SQLServerConnection)
	$responds = $false
	if ($result.ProcessID -ne $null) {$responds = $true}  
	If ($responds) 
	{
		try
		{
            #$VersionPath = $OlaHallengrenPath + "*.sql"
            $VersionPattern = '--// Version:'
            $fileVersions = Get-DeployFile  $ServerInstance $OlaHallengrenDeployDB $OlaHallengrenPath "*.sql" $VersionPattern
            $fileversions 
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

            if ($InstanceSQLConn.State -eq "Open"){$InstanceSQLConn.Close()} 
			Write-Log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Instance $inst" -Level Info -Path $logPath
		} 
		catch 
		{ 
            $ex = $_.Exception
            $line = $_.InvocationInfo.PositionMessage
	        write-log -Message "Get-OlaHallengren-Backup-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $svr executing script." -Level Error -Path $logPath
		} 
		finally
		{
   			$ErrorActionPreference = "Stop"; #Reset the error action pref to default
            $InstanceSQLConn.close | Out-Null
		}
	}
	else 
	{             
		write-log -Message "SQL Server DB Engine is not Installed or Started or inaccessible on $inst" -Path $logPath
	}
	#################################################################################################################################

} #Create-OlaHallengren
######################################################################################################################################

#####################################################################################################################################
#Get-OlaHallengren	[Function to get Server list info]
function Get-OlaHallengren($svr, $inst) 
{
	# Create an ADO.Net connection to the instance
    $InstanceSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$inst;Integrated Security=SSPI;Initial Catalog=" + $OlaHallengrenDeployDB + ";");
    $s = new-object (‘Microsoft.SqlServer.Management.Smo.Server’) $InstanceSQLConn
	$SQLServerConnection = $inst
    $InstanceSQLConn.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand 
    $Command.Connection = $InstanceSQLConn 

	### Instance Baseline Stats #####################################################################################################	
	$result = new-object Microsoft.SqlServer.Management.Common.ServerConnection($SQLServerConnection)
	$responds = $false
	if ($result.ProcessID -ne $null) {$responds = $true}  
	If ($responds) 
	{	
        try
        {
            $TypeName = "Database Integrity Check"
            $sc = $InstanceSQLConn.CreateCommand()                    
            Write-Log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | ### EXECUTING DatabaseIntegrityCheck ############################################" -Level Info -Path $logPath			 
			$query = "EXEC dbo.[DatabaseIntegrityCheck] "
            if (![string]::IsNullOrEmpty($Databases)){$query = $query + "@Databases= '$Databases',"}
            if (![string]::IsNullOrEmpty($CheckCommands)){$query = $query + "@CheckCommands= '$CheckCommands',"}
            if (![string]::IsNullOrEmpty($PhysicalOnly)){$query = $query + "@PhysicalOnly= '$PhysicalOnly',"}
            if (![string]::IsNullOrEmpty($NoIndex)){$query = $query + "@NoIndex= '$NoIndex',"}
            if (![string]::IsNullOrEmpty($ExtendedLogicalChecks)){$query = $query + "@ExtendedLogicalChecks= '$ExtendedLogicalChecks',"}
            if (![string]::IsNullOrEmpty($TabLock)){$query = $query + "@TabLock= '$TabLock',"}
            if (![string]::IsNullOrEmpty($FileGroups)){$query = $query + "@FileGroups= '$FileGroups',"}
            if (![string]::IsNullOrEmpty($Objects)){$query = $query + "@Objects= '$Objects',"}
            if($MaxDOP){$query = $query + "@MaxDOP = $MaxDOP,"} else {$query = $query + "@MaxDOP=NULL,"}
            if (![string]::IsNullOrEmpty($AvailabilityGroups)){$query = $query + "@AvailabilityGroups= '$AvailabilityGroups',"}
            if (![string]::IsNullOrEmpty($AvailabilityGroupReplicas)){$query = $query + "@AvailabilityGroupReplicas= '$AvailabilityGroupReplicas',"}
            if (![string]::IsNullOrEmpty($Updateability)){$query = $query + "@Updateability= '$Updateability',"}
            if($TimeLimit){$query = $query + "@TimeLimit = $TimeLimit,"} else {$query = $query + "@TimeLimit=NULL,"}
            if($LockMessageSeverity){$query = $query + "@LockMessageSeverity = $LockMessageSeverity,"} else {$query = $query + "@LockMessageSeverity=NULL,"}
            if (![string]::IsNullOrEmpty($DatabaseOrder)){$query = $query + "@DatabaseOrder= $DatabaseOrder,"}
            if (![string]::IsNullOrEmpty($DatabasesInParallel)){$query = $query + "@DatabasesInParallel= $DatabasesInParallel,"}
            if (![string]::IsNullOrEmpty($LockTimeout)){$query = $query + "@LockTimeout= $LockTimeout,"}
            if (![string]::IsNullOrEmpty($LogToTable)){$query = $query + "@LogToTable= '$LogToTable',"}
	        if (![string]::IsNullOrEmpty($Execute)){$query = $query + "@Execute= '$Execute',"}
	        if (![string]::IsNullOrEmpty($LoadGUID)){$query = $query + "@LoadGUID = '$LoadGUID'"}
            Write-Output $query
            $sc.CommandText = $query
			$da = new-object System.Data.SqlClient.SqlDataAdapter $sc  
            $da.SelectCommand.CommandTimeout = $CommandTimeout       
			$ds = new-object System.Data.DataSet
			$da.fill($ds) | out-null

            Write-Log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | ### CENTRALIZING DatabaseIntegrityCheck Data ############################################" -Level Info -Path $logPath	
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
                            FROM [" + $OlaHallengrenDeployDB + "].[dbo].[CommandLog] 
							WHERE LoadGUID = '$LoadGUID'"
            #Write-Output $query
			$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $InstanceSQLConn)
			$dt = new-object System.Data.DataTable
			$da.fill($dt) | out-null            
            Write-DataTable -ServerInstance $InstanceName -Database $DatabaseName -TableName $CITbl -Data $dt -Verbose | out-null  

            Write-Log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | ### CLEAR LOCAL DatabaseIntegrityCheck Data #########################################" -Level Info -Path $logPath
            $query = "IF OBJECT_ID (N'CommandLog', N'U') IS NOT NULL BEGIN DELETE FROM [" + $OlaHallengrenDeployDB + "].[dbo].[CommandLog] WHERE LoadGUID = '$LoadGUID' END; 
                      IF OBJECT_ID (N'QueueDatabase', N'U') IS NOT NULL BEGIN DELETE FROM [" + $OlaHallengrenDeployDB + "].[dbo].[QueueDatabase] where RequestStartTime <= dateadd(day, -1, getDate()) END;
                      IF OBJECT_ID (N'Queue', N'U') IS NOT NULL BEGIN DELETE FROM [" + $OlaHallengrenDeployDB + "].[dbo].[Queue] where RequestStartTime <= dateadd(day, -1, getDate()) END;
                      IF OBJECT_ID (N'CommandLog', N'U') IS NOT NULL BEGIN DELETE FROM [" + $OlaHallengrenDeployDB + "].[dbo].[CommandLog] where [EndTime] <= dateadd(day, -1, getDate()) END;"
			$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $InstanceSQLConn)
			$dt = new-object System.Data.DataTable
			$da.fill($dt) | out-null

			Write-Log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | Instance $inst" -Level Info -Path $logPath
		} 
		catch 
		{ 
			$ex = $_.Exception 
		    write-log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | $ex.Message on $inst"   -Path $logPath
		} 
		finally
		{
   			$ErrorActionPreference = "Stop"; #Reset the error action pref to default
            $cn.close | Out-Null
		}
	}
	else 
	{             
		write-log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | SQL Server DB Engine is not Installed or Started or inaccessible on $inst" -Path $logPath
	}
	#################################################################################################################################

} #Get-OlaHallengren
######################################################################################################################################

######################################################################################################################################
#Execute Script
try
{
	if ($logPath -notmatch '.+?\\$') { $logPath += '\' }  
    if ($OlaHallengrenPath -notmatch '.+?\\$') {$OlaHallengrenPath += '\' } 	
	if ([string]::IsNullOrEmpty($LoadGUID)){$LoadGUID = [guid]::NewGuid().ToString()}	
	write-output "step 1:" + $LoadGUID
	if ([string]::IsNullOrEmpty($DeployScripts)){$DeployScripts = 'Y'}
	if ($DatabasesInParallel -eq 'Y' -AND $RunAsJob -eq 'Y'){$logFileName = "Get-OlaHallengren-Integrity-Master_" + $env:computername + ".log";}
	else{$logFileName = "Get-OlaHallengren-Integrity-Job_" + $env:computername + ".log";}
	
	$logPath = $logPath + $logFileName
	$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()	
    write-log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | Script Started at $(get-date)" -Path $logPath
	$cn = new-object system.data.sqlclient.sqlconnection(“server=$InstanceName;database=$DatabaseName;Integrated Security=true;”);
	$cn.Open(); $cmd = $cn.CreateCommand()
	if ($runLocally -eq "true")
	{
		$query = "SELECT DISTINCT ServerName, InstanceName, isnull(NumberOfLogicalProcessors, 1) NumberOfLogicalProcessors 
                  FROM [CentralDB].[Svr].[ServerList] LEFT OUTER JOIN (SELECT DISTINCT ServerName SvrName, NumberOfLogicalProcessors FROM [CentralDB].[Svr].[ServerInfo] INNER JOIN (SELECT ServerName as SvrNm, MAX(SvrID) SvrID FROM [CentralDB].[Svr].[ServerInfo] group by ServerName) svr on svr.SvrID = [ServerInfo].SvrID) svr on svr.SvrName = [ServerList].ServerName
                  WHERE [ServerList].ServerName = '$env:computername';"
	}
	else
	{
		$query = "SELECT DISTINCT ServerName, InstanceName, isnull(NumberOfLogicalProcessors, 1) NumberOfLogicalProcessors 
                  FROM [CentralDB].[Svr].[ServerList] LEFT OUTER JOIN (SELECT DISTINCT ServerName SvrName, NumberOfLogicalProcessors FROM [CentralDB].[Svr].[ServerInfo] INNER JOIN (SELECT ServerName as SvrNm, MAX(SvrID) SvrID FROM [CentralDB].[Svr].[ServerInfo] group by ServerName) svr on svr.SvrID = [ServerInfo].SvrID) svr on svr.SvrName = [ServerList].ServerName"
	}
	$cmd.CommandText = $query
	$reader = $cmd.ExecuteReader()
	while($reader.Read()) 
	{
	write-host "step 2:" + $LoadGUID
		$server = $reader['ServerName']
		$instance = $reader['InstanceName']  
        $processorCount = $reader['NumberOfLogicalProcessors']  #Processor Count for Multi 	
		
        if ($instance -eq ""){$SQLServerConnection = $server} #Unnamed Instances (Default)
        elseif ($instance -match "\\") {$SQLServerConnection = $instance} #Named Instances
        else {$SQLServerConnection = $server + "\" + $instance}	#Split Named Instances
		$res = new-object Microsoft.SqlServer.Management.Common.ServerConnection($SQLServerConnection)
		$responds = $false            
		if ($res.ProcessID -ne $null){$responds = $true; $res.Disconnect()} #Verify Connectivity

		If ($responds) 
		{
	write-host "step 3:" + $LoadGUID
            if ($IntroduceDelay -eq 'Y')
            {                
                $randomNo = new-object system.random
                $delay = $randomNo.Next(60, 600)
                write-log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | Delay process of $delay seconds" -Path $logPath
                Start-Sleep -seconds $delay
            }
			
			if ($DeployScripts -eq 'Y'){write-log -Message "DeployScripts: $DeployScripts" -Path $logPath; Create-OlaHallengren $server $instance}			
			$i = 0     
            if ($DatabasesInParallel -eq 'Y' -AND $RunAsJob -eq 'Y')
            {
	write-host "step 4:" + $LoadGUID
                Remove-Job -State Completed 
				Remove-Job -State Failed
                write-log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | Starting to execute multi thread" -Path $logPath
                $ScriptName = split-path $MyInvocation.InvocationName -Leaf
                $logPathCall = split-path $logPath -parent
                $FilePath = $MyInvocation.InvocationName
                $randomNo = new-object system.random
				
				while($i -lt $processorCount)
                {   
					
	write-host "step 5:" + $LoadGUID
					$delay = $randomNo.Next(10, 1000)
                    $RunAsJob = 'N' #Set to no to actually execute process instead of generating loop with job 
                    $IntroduceDelay = 'N' #Set to no to actually execute process instead of generating delay
                    $DeployScripts = 'N' #Set to no because we deployed the scripts already
					$i = $i + 1
					$logFileName = "Get-OlaHallengren-Integrity-Job_" + $env:computername + "_$i-of-$processorCount.log";
                    $Name = "$ScriptName - $LoadGUID [$i of $processorCount]"   
	write-host $FilePath
					$job = Start-Job -Verbose -Name $Name -FilePath $FilePath -ArgumentList $InstanceName,$DatabaseName,$runLocally,$CommandTimeout,$DeployScripts,$RunAsJob,$IntroduceDelay,$Databases,$CheckCommands,$PhysicalOnly,$NoIndex,$ExtendedLogicalChecks,$TabLock,$FileGroups,$Objects,$MaxDOP,$AvailabilityGroups,$AvailabilityGroupReplicas,$Updateability,$TimeLimit,$LockMessageSeverity,$DatabaseOrder,$DatabasesInParallel,$LockTimeout,$LogToTable,$Execute,$LoadGUID,$OlaHallengrenDeployDB,$OlaHallengrenPath,$OlaHallengrenFilter,$logPathCall,$logFileName
					Receive-Job -Job $job  
					write-host $job
                    write-log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | Spooling up thread for $ScriptName $LoadGUID : $i of $processorCount" -Path $logPath
					Start-Sleep -Milliseconds 100
				}

	write-host "step 6:" + $LoadGUID
                $count = (Get-Job -Name *$LoadGUID* | Where-Object State -EQ Running | Select-Object Id | Measure).Count
                if ([string]::IsNullOrEmpty($count)){$count = 0}
                While($count -gt 0)
                {
                    $count = (Get-Job -Name *$LoadGUID* | Where-Object State -EQ Running | Select-Object Id | Measure).Count
                    if ([string]::IsNullOrEmpty($count)){$count = 0}
					$delay = $randomNo.Next(10, 1000)
					Start-Sleep -Milliseconds $delay
                    write-log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | Waiting for threads to finish... [$($ElapsedTime.Elapsed.ToString())]" -Path $logPath
                    Start-Sleep -Seconds 60                    
                }  
                
                $count = (Get-Job -Name *$LoadGUID* | Where-Object State -EQ Completed | Select-Object Id | Measure).Count
                if($count -gt 0)
                {
	write-host "step 7:" + $LoadGUID
					Write-Log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | CLEAR LOCAL Jobs and Queue #########################################" -Level Info -Path $logPath
                    Remove-Job -Name *$LoadGUID*				
										
					$InstanceSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$instance;Integrated Security=SSPI;Initial Catalog=" + $OlaHallengrenDeployDB + ";");
					$s = new-object (‘Microsoft.SqlServer.Management.Smo.Server’) $InstanceSQLConn
					$SQLServerConnection = $instance
					$InstanceSQLConn.Open()
					$Command = New-Object System.Data.SQLClient.SQLCommand 
					$Command.Connection = $InstanceSQLConn 			
					$query = "IF OBJECT_ID (N'CommandLog', N'U') IS NOT NULL BEGIN DELETE FROM [" + $OlaHallengrenDeployDB + "].dbo.CommandLog WHERE LoadGUID = '$LoadGUID' END;
							  IF OBJECT_ID (N'QueueDatabase', N'U') IS NOT NULL BEGIN DELETE FROM [" + $OlaHallengrenDeployDB + "].[dbo].[QueueDatabase] WHERE [QueueID] in (SELECT QueueID FROM [msdb].[dbo].[Queue] WHERE [Parameters] like '%$LoadGUID%') END;
							  IF OBJECT_ID (N'Queue', N'U') IS NOT NULL BEGIN DELETE FROM [" + $OlaHallengrenDeployDB + "].[dbo].[Queue] WHERE [Parameters] like '%$LoadGUID%' END;"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $InstanceSQLConn)
					$dt = new-object System.Data.DataTable
					$da.fill($dt) | out-null					
					#$Command.close | Out-Null
					#$InstanceSQLConn.close | Out-Null
                }                              
            }
            else
            {
	write-host "step 8:" + $LoadGUID		
                write-log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | Starting Execution of $LoadGUID" -Path $logPath
                #if ($DeployScripts -eq 'Y'){write-log -Message "DeployScripts: $DeployScripts" -Path $logPath;Create-OlaHallengren $server $instance $type;}
                Get-OlaHallengren $server $instance
            }            
		}
		else 
		{
  			# Let the user know we couldn't connect to the server
            if ($instance -eq ""){$message = "$server did not respond. Please check connectivity and try again."} #Unnamed Instances (Default)
            elseif ($instance -match "\\") {$message = $instance + " did not respond. Please check connectivity and try again."} #Named Instances
            else {$message = $server + "\" +  $instance + " did not respond. Please check connectivity and try again."}	#Split Named Instances
            write-log -Message $message -Path $logPath
		}  
        #$LoadGUID = $null;
	write-host "step 9:" + $LoadGUID	
	}
	write-log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | Script Ended at $(get-date)"  -Path $logPath
	write-log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"  -Path $logPath
}
catch
{
    $ex = $_.Exception
    $line = $_.InvocationInfo.PositionMessage
	write-log -Message "Get-OlaHallengren-Integrity-2.0.ps1 | Catch Message: $ex.Message ($line) on $svr executing script." -Level Error -Path $logPath 
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
