#####################################################################################################################################
# Get-ADGroupMembers (https://seniuka.github.io/CentralDB/)
# This script will collect AD user group membership.
#
# Assumptions: 
#    This script will be executed by a service account with local admin server.
#    This script uses intergrated authentication to insert data into the central management db, this service account will need permissions to insert data.
#
#                                                            This script has been added from https://github.com/CrazyDBA/CentralDB
#####################################################################################################################################

#####################################################################################################################################
#Parameter List
param(
	[string]$cmsInstanceName="",
	[string]$cmsDatabaseName="",
	[string]$cmsLogin="",
	[string]$cmsPassword="",
    [string]$runLocally="false", #runs locally only transmits data to CMS if accessible
	[string]$logPath="",
	[string]$logFileName="Get-ADUserGroupMembers_" + $env:computername + ".log"
)
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | out-null
#[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement') | out-null
#[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ManagedDTS') | out-null
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices") | out-null
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.RMO") | Out-Null
#####################################################################################################################################

### Start External Scripts ##########################################################################################################
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
write-output "### Start External Scripts #############################################################################################"

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


######################################################################################################################################
#Function to get Server Membership
function Get-ADUserGroupMembership($SQLServerName, $SQLInstanceName, $ADGroupName) 
{
	$cn = new-object system.data.SqlClient.SqlConnection("Data Source=$SQLInstanceName;Integrated Security=SSPI;Initial Catalog=tempdb");
	$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $cn
	$RunDt = Get-Date -format G

	### Get Local Group Members #####################################################################################################
	try
	{
		$ErrorActionPreference = "Stop"; #Make all errors terminating
		$CITbl = "[Inst].[LoginGroupMembers]"	
		
		$dt = new-object System.Data.DataTable "LocalGroupMembers"
        $colComputer = new-object System.Data.DataColumn Computer,([string])
        $colGroupName = new-object System.Data.DataColumn GroupName,([string])
        $colStatus = new-object System.Data.DataColumn Status,([string])
        $colMemberType = new-object System.Data.DataColumn MemberType,([string])
		$colMemberDomain = new-object System.Data.DataColumn MemberDomain,([string])
		$colMemberName = new-object System.Data.DataColumn MemberName,([string])
		$dt.Columns.Add($colComputer)
		$dt.Columns.Add($colGroupName)
        $dt.Columns.Add($colStatus)
        $dt.Columns.Add($colMemberType)
        $dt.Columns.Add($colMemberDomain)
        $dt.Columns.Add($colMemberName)
		
		ForEach($Computer in $svr) 
		{
			write-log -Message "Collecting Local Group Members on $Computer" -Level Info -Path $logPath
			If(!(Test-Connection -ComputerName $Computer -Count 1 -Quiet)) 
			{
				write-log -Message "$Computer appears to be off-line." -Level Info -Path $logPath				
				Continue
			} 
			else 
			{
				write-log -Message "Processing $computer" -Path $LogPath 	
				try {
					$group = [ADSI]"WinNT://$Computer/$groupName"
					$members = @($group.Invoke("Members"))
					write-log -Message "Successfully queried the members of $computer" -Path $LogPath 	
					if(!$members) {
						write-log -Message "No members found in the group" -Path $LogPath 	
						continue
					}
				}        
				catch {
					write-log -Message "Failed to query the members of $Computer" -Path $LogPath 			
					Continue
				}
				foreach($member in $members) 
				{
					try 
					{
						$MemberName = $member.GetType().Invokemember("Name","GetProperty",$null,$member,$null)
						$MemberType = $member.GetType().Invokemember("Class","GetProperty",$null,$member,$null)
						$MemberPath = $member.GetType().Invokemember("ADSPath","GetProperty",$null,$member,$null)
						$MemberDomain = $null
						if($MemberPath -match "^Winnt\:\/\/(?<domainName>\S+)\/(?<CompName>\S+)\/") 
						{
							if($MemberType -eq "User") 
							{
								$MemberType = "LocalUser"
							} 
							elseif($MemberType -eq "Group")
							{
								$MemberType = "LocalGroup"
							}
							$MemberDomain = $matches["CompName"]	 
						} 
						elseif($MemberPath -match "^WinNT\:\/\/(?<domainname>\S+)/") 
						{
							if($MemberType -eq "User") 
							{
								$MemberType = "DomainUser"
							} 
							elseif($MemberType -eq "Group")
							{
								$MemberType = "DomainGroup"
							}
							$MemberDomain = $matches["domainname"]	 
						} 
						else 
						{
							$MemberType = "Unknown"
							$MemberDomain = "Unknown"
						}
						
						$row = $dt.NewRow()
						$row.Computer = $Computer
						$row.GroupName = $GroupName
						$row.Status = "Success"
						$row.MemberType = $MemberType
						$row.MemberDomain = $MemberDomain
						$row.MemberName = $MemberName
						$dt.rows.add($row)						
					} 
					catch 
					{
						write-log -Message "failed to query details of a member. Details $_" -Path $LogPath 
					}	 
				} 
			} 
		}
		
	    $RowCount = $dt.Rows.Count.ToString()
        if($dt.Rows.Count -gt "0")
        {
            write-log -Message "Starting Bulk Load to $InstanceName on $DatabaseName in $CITbl" -Path $LogPath 
            Write-DataTable -ServerInstance $InstanceName -Database $DatabaseName -TableName $CITbl -Data $dt
            write-log -Message "Finished Bulk Load to $InstanceName on $DatabaseName in $CITbl" -Path $LogPath            
        }
        else
        {
            write-log -Message "On $InstanceName, there are no rows in the table or table does not exist."  -Path $LogPath
        }	
				
		write-log -Message "Collecting Local Group Members" -Level Info -Path $logPath
	}    
	catch 
	{ 
		$ex = $_.Exception 
		write-log -Message "$ex.Message on $Svr While collecting local group members"   -Path $logPath 
	} 
	finally
	{
   			$ErrorActionPreference = "Continue"; #Reset the error action pref to default
	}
	#################################################################################################################################
}
#####################################################################################################################################

#Function to get instance login groups
function Get-InstanceLoginGroups 
{
    Param
    (
        [string] $getServerName,
        [string] $getInstanceName
    )
    try 
    {
        write-output "Executing Get-InstanceLoginGroups"
        ## Login parameters will need to be defined
	    $gilg_cn = new-object system.data.sqlclient.sqlconnection("server=$getInstanceName;database=master;Integrated Security=true;");
	    $gilg_cn.Open(); $gilg_cmd = $gilg_cn.CreateCommand()    
        $gilg_query = "SELECT replace(name, 'GOA\', '') as GroupName FROM sys.server_principals where type ='G'"
	    Write-Host $gilg_query
        $gilg_cmd.CommandText = $gilg_query
	    $gilg_reader = $gilg_cmd.ExecuteReader()
        write-output "Executing Query"
	    while($gilg_reader.Read()) 
	    {       
            $getGroupName = $gilg_reader['GroupName']
            write-output "Found Group... [$getGroupName]"
            # Calling function and passing server and instance parameters
            Get-ADGroupMembers $getServerName $getInstanceName $getGroupName 
        }
        $gilg_cn.Close()
   }    
    catch 
    { 
        $ex = $_.Exception 
	    write-log -Message "$ex.Message on $server While AD group membership information"  -Path $LogPath
    } 
    finally
    {
   	    $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
} #Function to Get-InstanceLoginGroups 
###########################################################################################################################

######################################################################################################################################
#Function to get AD Group Members
function Get-ADGroupMembers 
{
    Param
    (
        [string] $getServerName,
        [string] $getInstanceName,
        [string] $AdGroupName
    )
    try 
    {
        if ($AdGroupName.Length -gt 0)
        {
            write-output "Execute Get-ADGroupMembers with [$AdGroupName]"
            $RunDt = Get-Date -format G
            Write-Log -Message "Collect AD group membership information" -Level Info -Path $logPath   
	        $ErrorActionPreference = "Stop";
	        $CITbl="[Inst].[ADGroupMembership]"
            $dt = Get-ADGroupMember -Identity "$AdGroupName" | SELECT @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}}, @{n="UserName";e={$_.SamAccountName}}, @{n="AccountType";e={$_.ObjectClass}}, @{n="GroupName";e={$AdGroupName}}, @{n="DateAdded";e={$RunDt}} | out-datatable
	        write-output "Execute Get-ADGroupMember with [$AdGroupName]"
            Write-DataTable -ServerInstance $cmsInstanceName -Database $cmsDatabaseName -TableName $CITbl -Data $dt
            Write-Log -Message "Completed Get-ADGroupMembers with [$AdGroupName]" -Level Info -Path $logPath
        }
        else
        {
            Write-Log -Message "Error Get-ADGroupMembers with an invalid GroupName" -Level Info -Path $logPath
        }
    }    
    catch 
    { 
        $ex = $_.Exception 
	    write-log -Message "$ex.Message on $server While executing Get-ADGroupMembers with [$AdGroupName]"  -Path $LogPath
    } 
    finally
    {
   	    $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
} #Function to CollectADGroupMembers
###########################################################################################################################


######################################################################################################################################
#Execute Script
try
{
	if ($logPath -notmatch '.+?\\$') { $logPath += '\' } 
	$logPath = $logPath + $logFileName
	$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
	write-log -Message "Script Started at $(get-date)"  -Clobber -Path $logPath

	$cn = new-object system.data.sqlclient.sqlconnection("server=$cmsInstanceName;database=$cmsDatabaseName;Integrated Security=true;");
	$cn.Open()
	$cmd = $cn.CreateCommand()
	$query = "SELECT DISTINCT ServerName, InstanceName FROM [Svr].[ServerList] WHERE Inventory='True';"
	
    $cmd.CommandText = $query
	$reader = $cmd.ExecuteReader()
	while($reader.Read()) 
	{
		$getServerName = $reader['ServerName']
		$getInstanceName = $reader['InstanceName']    	
        if ($getInstanceName -match "\\") {$SQLServerConnection = $getInstanceName} 
        elseif ($getInstanceName.length -eq 0) {$SQLServerConnection = $getServerName; $getInstanceName = $getServerName}
        else {$SQLServerConnection = $getServerName + "\" +  $getInstanceName}	
		$res = new-object Microsoft.SqlServer.Management.Common.ServerConnection($SQLServerConnection)
		$responds = $false            
		if ($res.ProcessID -ne $null) 
		{
			$responds = $true
			$res.Disconnect()
		}

		If ($responds) 
		{
            Write-Output "Calling Get-InstanceLoginGroups"
			Get-InstanceLoginGroups $getServerName $getInstanceName
		}
		else 
		{
 			# Let the user know we couldn't connect to the server
			write-log -Message "$server Server did not respond" -Path $logPath
		}  
	}
	write-log -Message "Script Ended at $(get-date)"  -Path $logPath
	write-log -Message "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"  -Path $logPath
}
catch
{
	$ex = $_.Exception 
	write-log -Message "$ex.Message on $svr executing script Get-LocalGroupMembers.ps1" -Level Error -Path $logPath 
}
#Execute Script
######################################################################################################################################

######################################################################################################################################

######################################################################################################################################
