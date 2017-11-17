#####################################################################################################################################
# Check-SQLRURunning (https://seniuka.github.io/CentralDB/)
# This script will verify if SQL server is running from connecting to each server in the server list table.
# It will email you if any do not reply, if you supply an email address. Otherwise it will log successful and unsuccessful connections
# to the log filename and log path
#
#															This script has been branched from https://github.com/CrazyDBA/CentralDB
#####################################################################################################################################

#####################################################################################################################################
#Parameter List
param(
	[string]$InstanceName="",
	[string]$DatabaseName="",
    [string]$runLocally="false", #This flag is used to reduce the number of remote powershell calls from a single central management server.
	[string]$logPath="",
	[string]$logFileName="Check-SQLRURunning_" + $env:computername + ".log",
	[string]$SmtpServer="",
	[string]$To="",
	[string]$From=""
	)
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement') | out-null
#####################################################################################################################################

#####################################################################################################################################
#Execute Script
try
{
	if ($logPath -notmatch '.+?\\$') { $logPath += '\' } 
	$logPath = $logPath + $logFileName
	$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
	write-log -Message "Script Started at $(get-date)"  -Clobber -Path $logPath

	$cn = new-object system.data.sqlclient.sqlconnection(“server=$SQLInst;database=$CentralDB;Integrated Security=true;”);
	$cn.Open()
	$cmd = $cn.CreateCommand()
	# Fetch Server list into the Data source from Srv.ServerList Table from CentralDB
	$query = "SELECT DISTINCT ServerName, InstanceName 
			  FROM [Svr].[ServerList] 
			  WHERE SQLPing = 'True' AND (PingSnooze IS NULL OR PingSnooze <= GETDATE()) AND ((MaintStart IS NULL) or (MaintEnd IS NULL) or (GETDATE() NOT BETWEEN MaintStart AND MaintEnd ))"
	$cmd.CommandText = $query
	$reader = $cmd.ExecuteReader()
	while($reader.Read()) 
	{
   		# Get ServerName and InstanceName from CentralDB
		$server = $reader['ServerName']
		$instance = $reader['InstanceName']
		#Increase the Count if you are having timeout and getting false positives
		if(test-connection -computername $Server -count 3 -delay 1 -quiet)
		{
			#Connect to SQLServer
			$res = new-object Microsoft.SqlServer.Management.Common.ServerConnection($instance)
			$resp = $false

			#If ProcessID is not null then it must have connected
			if ($res.ProcessID -ne $null) 
			{
				$resp = $true
    		}

			#If response is null then send mail message
    		if (!$resp) 
			{
				$date = Get-Date -format "yyyy.MM.dd HH:mm:ss"
				$Subject = "Check-SQLRURunning: Unable to connect instance $instance [$date]"
				$Body = "Unable to connect to $instance Instance. Please make sure that you are able to connect to the box and Check SQL Services."
				Send-MailMessage -To $To -From $From -SmtpServer $SmtpServer -Subject $Subject -Body $Body
			}

		}
		# ELSE Ping to server failed
		else 
		{
			$date = Get-Date -format "yyyy.MM.dd HH:mm:ss"
			$Subject = "Check-SQLRURunning: Unable to ping server $server [$date]"
			$Body = "Unable to ping $server Server. Please make sure that you are able to RDP to the box."
			Send-MailMessage -To $To -From $From -SmtpServer $SmtpServer -Subject $Subject -Body $Body
		}  	
	}
	write-log -Message "Script Ended at $(get-date)"  -Path $logPath
	write-log -Message "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"  -Path $logPath
}
catch
{
	$ex = $_.Exception 
	write-log -Message "$ex.Message on $svr excuting script Check-SQLRURunning" -Level Error -Path $logPath 
}
#Execute Script
#####################################################################################################################################

