#####################################################################################################################################
# Get-FirstResponderKit (https://seniuka.github.io/CentralDB/)
# This script will collect data points from the following FirstResponderKit scripts.
# ScriptName   Type - Description of check
# Blitz:       This script checks the health of your SQL Server and gives you a prioritized to-do list of the most urgent things you should consider fixing.
#
# Assumptions: 
#    This script will be executed by a service account with sysadmin or elevated privleges to the database server.
#    This script uses intergrated authentication to insert data into the central management db, this service account will need permissions to insert data.
#
#                                                       This script is brand spanking new; this baby could crash your server so hard! 
#####################################################################################################################################

#####################################################################################################################################
#Parameter List
param(
	[string]$InstanceName="", #CMS Server with CentralDB
	[string]$DatabaseName="CentralDB", #CMS Server with CentralDB
    [string]$runLocally="true", #This flag is used to reduce the number of remote powershell calls from a single cms by executing locally 	
    [int32] $CommandTimeout= 14400,	#seconds
    [string]$DeployScripts= 'Y',
	[string]$LoadGUID= $null,
	[string]$FirstResponderKitDeployDB="tempdb",
	[string]$FirstResponderKitPath="", #Where does FirstResponderKit live... the sql files? So we can load the newest version.
	[string]$FirstResponderKitFilter="Install-Core-Blitz-No-Query-Store.sql", #If you rename them... what are they named by default they are.
	[string]$logPath="",
	[string]$logFileName="Get-FirstResponderKit_" + $env:computername + ".log"
	)
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement') | out-null
#####################################################################################################################################

### Start External Scripts ##########################################################################################################
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
write-output "### Start External Scripts ############################################################################################"

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
#Create-FirstResponderKit	[Function to get Server list info]
function Create-FirstResponderKit($SQLServerConnection) 
{
	### Connect to SQL Instance Executing Script ######################################################################################
	write-host "step 3.1: Connect to SQL Instance Executing Script" + $LoadGUID
	$InstanceSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$SQLServerConnection;Integrated Security=SSPI;Initial Catalog=" + $FirstResponderKitDeployDB + ";");
    $InstanceSQLConn.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand 
    $Command.Connection = $InstanceSQLConn 
    
	### Create Object Deploy Code #####################################################################################################	
	write-host "step 3.2: Create Object Deploy Code" + $LoadGUID
	#$result = new-object Microsoft.SqlServer.Management.Common.ServerConnection($SQLServerConnection)
	$responds = $false
	if ($Command.Connection.State -eq "open") {$responds = $true}  
	If ($responds) 
	{
		try
		{
            $VersionPattern = '@VersionDate'
            $fileVersions = Get-DeployFile $SQLServerConnection $FirstResponderKitDeployDB $FirstResponderKitPath $FirstResponderKitFilter $VersionPattern
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
			Write-Log -Message "Get-FirstResponderKit-$scriptVersion.ps1 | Instance $SQLServerConnection" -Level Info -Path $logPath
		} 
		catch 
		{ 
            $ex = $_.Exception
            $line = $_.InvocationInfo.PositionMessage
	        write-log -Message "Get-FirstResponderKit-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $SQLServerConnection executing script." -Level Error -Path $logPath
		} 
		finally
		{
   			$ErrorActionPreference = "Stop"; #Reset the error action pref to default
            $InstanceSQLConn.close | Out-Null
		}
	}
	else 
	{             
		write-log -Message "SQL Server is not Installed or Started or inaccessible on $inst" -Path $logPath
	}
	#################################################################################################################################

} #Create-FirstResponderKit
#####################################################################################################################################

#####################################################################################################################################
#Get-FirstResponderKit	[Function to get Server list info]
function Get-FirstResponderKit($SQLServerConnection, $Type) 
{
	
	try
    {
        ### Create an ado.net connection to the instance ################################################################################
        $InstanceSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$SQLServerConnection;Integrated Security=SSPI;Initial Catalog=" + $FirstResponderKitDeployDB + ";");
        $InstanceSQLConn.Open()
        $Command = New-Object System.Data.SQLClient.SQLCommand 
        $Command.Connection = $InstanceSQLConn 
	    #################################################################################################################################
   
	    ### Get First Responder Kit #####################################################################################################	
        $result = new-object Microsoft.SqlServer.Management.Common.ServerConnection($SQLServerConnection)
        if ($InstanceSQLConn.State -eq 'Open')
	    {	
            try
            {	
			    switch($Type)
			    {
				    "Blitz" 
                    {
                        Write-Log -Message "### CLEAR LOCAL Blitz Data #########################################" -Level Info -Path $logPath
					    $query = "IF OBJECT_ID (N'Blitz', N'U') IS NOT NULL BEGIN TRUNCATE TABLE $FirstResponderKitDeployDB.dbo.Blitz END"
					    $da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $InstanceSQLConn)
					    $dt = new-object System.Data.DataTable
					    $da.fill($dt) | out-null

                        $sc = $InstanceSQLConn.CreateCommand()                    
                        Write-Log -Message "### EXECUTING Blitz ############################################" -Level Info -Path $logPath			 
					    $query = "EXEC dbo.sp_Blitz
					     @OutputDatabaseName = '$FirstResponderKitDeployDB'
					    ,@OutputSchemaName = 'dbo'
					    ,@OutputTableName = 'Blitz'
					    ,@CheckUserDatabaseObjects = 1
                        ,@CheckProcedureCache = 1
                        ,@OutputProcedureCache = 1
                        ,@CheckServerInfo = 1"
                        $sc.CommandText = $query
                        $sc.CommandTimeout = 600 #10 Minutes
					    $da = new-object System.Data.SqlClient.SqlDataAdapter $sc             
					    $ds = new-object System.Data.DataSet
					    $da.fill($ds) | out-null

                        Write-Log -Message "### CENTRALIZING Blitz Data ############################################" -Level Info -Path $logPath	
					    $CITbl = "[FRK].[Blitz]"	
					    $query = "SELECT * FROM $FirstResponderKitDeployDB.dbo.Blitz"
					    #Write-Log -Message "Here 0" -Level Info -Path $logPath	
						$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $InstanceSQLConn)
					    #Write-Log -Message "Here 1" -Level Info -Path $logPath	
						$dt = new-object System.Data.DataTable
					    #Write-Log -Message "Here 2" -Level Info -Path $logPath	
						$da.fill($dt) | out-null
						#Write-Log -Message "Here 3" -Level Info -Path $logPath	
					    Write-DataTable -ServerInstance $InstanceName -Database $DatabaseName -TableName $CITbl -Data $dt -Verbose #| out-null  
						#Write-Log -Message "Here 4" -Level Info -Path $logPath	

                        Write-Log -Message "### CLEAR LOCAL Blitz Data #########################################" -Level Info -Path $logPath
                        $query = "IF OBJECT_ID (N'Blitz', N'U') IS NOT NULL BEGIN TRUNCATE TABLE $FirstResponderKitDeployDB.dbo.Blitz END"
			            $da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $InstanceSQLConn)
			            $dt = new-object System.Data.DataTable
			            $da.fill($dt) | out-null
     

                    }
				    else 
                    {
                        Write-Log -Message "Get-FirstResponderKit $type is not a valid type; Please enter in a valid type." -Level Error -Path $logPath  
                    }
			    }

			    Write-Log -Message "Get-FirstResponderKit $type on Instance $inst" -Level Info -Path $logPath
		    } 
		    catch 
		    { 
                $ex = $_.Exception
                $line = $_.InvocationInfo.PositionMessage
	            write-log -Message "Get-FirstResponderKit-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $SQLServerConnection executing script." -Level Error -Path $logPath
		    } 
		    finally
		    {
   			    $ErrorActionPreference = "Stop"; #Reset the error action pref to default
                $cn.close | Out-Null
		    }
	    }
	    else 
	    {             
		    write-log -Message "Get-FirstResponderKit-$scriptVersion.ps1 | SQL Server DB Engine is not Installed or Started or inaccessible on $SQLServerConnection executing script."  -Level Error -Path $logPath
	    }

    }
	catch 
	{ 
        $ex = $_.Exception
        $line = $_.InvocationInfo.PositionMessage
	    write-log -Message "Get-FirstResponderKit-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $SQLServerConnection executing script." -Level Error -Path $logPath
        $ErrorActionPreference = "Stop"; #Reset the error action pref to default
	} 
	#################################################################################################################################

} #Get-FirstResponderKit
######################################################################################################################################

######################################################################################################################################
#Execute Script
try
{
    $scriptVersion = "2.0"

	if ($logPath -notmatch '.+?\\$') { $logPath += '\' }  
    if ($OlaHallengrenPath -notmatch '.+?\\$') {$OlaHallengrenPath += '\' } 	
	if ([string]::IsNullOrEmpty($LoadGUID)){$LoadGUID = [guid]::NewGuid().ToString()}	
	write-output "step 1:" + $LoadGUID
	if ([string]::IsNullOrEmpty($DeployScripts)){$DeployScripts = 'Y'}
	$logFileName = "Get-FirstResponderKit-Blitz_" + $env:computername + "_" + $pid + ".log";
	
	write-host "logFile:" + $logPath
	write-host "logFileName:" + $logFileName
		
	$logPath = $logPath + $logFileName
	$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()	
    write-log -Message "Get-FirstResponderKit-Blitz-$scriptVersion.ps1 | Script Started at $(get-date)" -Path $logPath


	$cn = new-object system.data.sqlclient.sqlconnection(“server=$InstanceName;database=$DatabaseName;Integrated Security=true;”);
	$cn.Open(); $cmd = $cn.CreateCommand()
	if ($runLocally -eq "true")
	{
		$query = "Select Distinct ServerName, InstanceName from [Svr].[ServerList] where baseline = 'True' and ServerName = '$env:computername';"
	}
	else
	{
		$query = "Select Distinct ServerName, InstanceName from [Svr].[ServerList] where baseline ='True';"
	}
	$cmd.CommandText = $query
	$reader = $cmd.ExecuteReader()
    
    if($reader.HasRows)
    {
	    while($reader.Read()) 
	    {
		    $server = $reader['ServerName']
		    $instance = $reader['InstanceName']   

            if ($instance -eq ""){$SQLServerConnection = $server} #Unnamed Instances (Default)
            elseif ($instance -match "\\") {$SQLServerConnection = $instance} #Named Instances
            else {$SQLServerConnection = $server + "\" + $instance}	#Split Named Instances
            Write-Output $SQLServerConnection
            Write-Output $env:UserName

            $InstanceSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$SQLServerConnection;Integrated Security=SSPI;Initial Catalog=" + $FirstResponderKitDeployDB + ";");
            $InstanceSQLConn.Open()
		    if ($InstanceSQLConn.State -eq 'Open')
	        {     
			    $InstanceSQLConn.Close()
                # Calling funtion and passing server and instance parameters
			    if ($DeployScripts -eq 'Y'){write-log -Message "DeployScripts: $DeployScripts" -Path $logPath; Create-FirstResponderKit $SQLServerConnection 'Blitz'}
                Get-FirstResponderKit $SQLServerConnection 'Blitz'
		    }
		    else 
		    {
                write-log -Message "Get-FirstResponderKit-Blitz-$scriptVersion.ps1 | $SQLServerConnection did not respond. Please check connectivity and try again." -Level Error  -Path $logPath  
		    }  
	    }
    }
    else 
    {
      	write-log -Message "Get-FirstResponderKit-Blitz-$scriptVersion.ps1 | $env:computername was not found within the ServerList Table. Please add this and try again." -Level Error  -Path $logPath  
    }
	write-log -Message "Get-FirstResponderKit-Blitz-$scriptVersion.ps1 | Script Ended at $(get-date)"  -Path $logPath
	write-log -Message "Get-FirstResponderKit-Blitz-$scriptVersion.ps1 | Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"  -Path $logPath
}
catch
{
    $ex = $_.Exception
    $line = $_.InvocationInfo.PositionMessage
	write-log -Message "Get-FirstResponderKit-Blitz-$scriptVersion.ps1 | Catch Message: $ex.Message ($line) on $svr executing script." -Level Error -Path $logPath 
}
#Execute Script
######################################################################################################################################

############################################################################################################################################################
<# 
	Special thanks to Brent Ozar and Brent Ozar LTD (All of the people who created FirstResponderKit) 
	for the hard work they do providing us with exceptional scripts to assist with DBA tasks.
	Please check out FirstResponderKit.org to get the newest version! Also say thanks.
#>
############################################################################################################################################################