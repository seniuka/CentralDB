#####################################################################################################################################
# Get-WaitStats (https://seniuka.github.io/CentralDB/)
# This script will collect local group membership from the selected servers.
#
# Assumptions: 
#    This script will be executed by a service account with local server admin.
#    This script uses intergrated authentication to insert data into the central management db, this service account will need permissions to insert data.
#
#                                                            This script has been added from https://github.com/CrazyDBA/CentralDB
#####################################################################################################################################

#####################################################################################################################################
#Parameter List
param(
	[string]$InstanceName="",
	[string]$DatabaseName="",
    [string]$runLocally="false",    #This flag is used to reduce the number of remote powershell calls from a single cms.
	[string]$groupName="", 			#Use this to identify the group you want to find the members of.
	[string]$logPath="",
	[string]$logFileName="Get-LocalGroupMembers" + $env:computername + ".log"
	)
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement') | out-null
#####################################################################################################################################

#####################################################################################################################################
#Get-Type
function Get-Type 
{ 
    param($type) 
 $types = @( 
'System.Boolean', 
'System.Byte[]', 
'System.Byte', 
'System.Char', 
'System.Datetime', 
'System.Decimal', 
'System.Double', 
'System.Guid', 
'System.Int16', 
'System.Int32', 
'System.Int64', 
'System.Single', 
'System.UInt16', 
'System.UInt32', 
'System.UInt64') 
 if ( $types -contains $type ) { 
        Write-Output "$type" 
    } 
    else { 
        Write-Output 'System.String'      
    } 
} #Get-Type 
#####################################################################################################################################

#####################################################################################################################################
#Write-DataTable 
<# Author: Chad Miller http://Sev17.com Write-DataTable Function: http://gallery.technet.microsoft.com/scriptcenter/2fdeaf8d-b164-411c-9483-99413d6053ae #>
<# 
.SYNOPSIS 
Writes data only to SQL Server tables. 
.DESCRIPTION 
Writes data only to SQL Server tables. However, the data source is not limited to SQL Server; any data source can be used, as long as the data can be loaded to a DataTable instance or read with a IDataReader instance. 
.INPUTS 
None 
    You cannot pipe objects to Write-DataTable 
.OUTPUTS 
None 
    Produces no output 
.EXAMPLE 
$dt = Invoke-Sqlcmd2 -ServerInstance "Z003\R2" -Database pubs "select *  from authors" 
Write-DataTable -ServerInstance "Z003\R2" -Database pubscopy -TableName authors -Data $dt 
This example loads a variable dt of type DataTable from query and write the datatable to another database 
.NOTES 
Write-DataTable uses the SqlBulkCopy class see links for additional information on this class. 
Version History 
v1.0   - Chad Miller - Initial release 
v1.1   - Chad Miller - Fixed error message 
.LINK 
http://msdn.microsoft.com/en-us/library/30c3y597%28v=VS.90%29.aspx 
#> 
function Write-DataTable 
{ 
    [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Database, 
    [Parameter(Position=2, Mandatory=$true)] [string]$TableName, 
    [Parameter(Position=3, Mandatory=$true)] $Data, 
    [Parameter(Position=4, Mandatory=$false)] [string]$Username, 
    [Parameter(Position=5, Mandatory=$false)] [string]$Password, 
    [Parameter(Position=6, Mandatory=$false)] [Int32]$BatchSize=50000, 
    [Parameter(Position=7, Mandatory=$false)] [Int32]$QueryTimeout=0, 
    [Parameter(Position=8, Mandatory=$false)] [Int32]$ConnectionTimeout=30 
    ) 
	
	#write-output $ServerInstance
	#write-output $Data
     $conn=new-object System.Data.SqlClient.SQLConnection  
    if ($Username) 
    { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout } 
    else 
    { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout } 
    $conn.ConnectionString=$ConnectionString 
   try 
    { 
        $conn.Open() 
        $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString 
        $bulkCopy.DestinationTableName = $tableName 
        $bulkCopy.BatchSize = $BatchSize 
        $bulkCopy.BulkCopyTimeout = $QueryTimeOut 
        $bulkCopy.WriteToServer($Data) 
        $conn.Close() 
    } 
    Catch [System.Management.Automation.MethodInvocationException]
    {
		#write-output $ServerInstance
	write-output $Data
	$ex = $_.Exception 
	write-log -Message "$ex.Message on $svr" -Level Error -NoConsoleOut -Path $logPath
    }
    catch 
    { 
        $ex = $_.Exception 
        write-log -Message "$ex.Message on $svr"  -Level Error -NoConsoleOut -Path $logPath
    } 
} #Write-DataTable
#####################################################################################################################################

#####################################################################################################################################
#Out-DataTable
<# Author: Chad Miller http://Sev17.com Out-DataTable Function: http://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd #>
<# 
.SYNOPSIS 
Creates a DataTable for an object 
.DESCRIPTION 
Creates a DataTable based on an objects properties. 
.INPUTS 
Object 
    Any object can be piped to Out-DataTable 
.OUTPUTS 
   System.Data.DataTable 
.EXAMPLE 
$dt = Get-psdrive| Out-DataTable 
This example creates a DataTable from the properties of Get-psdrive and assigns output to $dt variable 
.NOTES 
Adapted from script by Marc van Orsouw see link 
Version History 
v1.0  - Chad Miller - Initial Release 
v1.1  - Chad Miller - Fixed Issue with Properties 
v1.2  - Chad Miller - Added setting column datatype by property as suggested by emp0 
v1.3  - Chad Miller - Corrected issue with setting datatype on empty properties 
v1.4  - Chad Miller - Corrected issue with DBNull 
v1.5  - Chad Miller - Updated example 
v1.6  - Chad Miller - Added column datatype logic with default to string 
v1.7 - Chad Miller - Fixed issue with IsArray 
.LINK 
http://thepowershellguy.com/blogs/posh/archive/2007/01/21/powershell-gui-scripblock-monitor-script.aspx 
#> 
function Out-DataTable 
{ 
    [CmdletBinding()] 
    param([Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)] [PSObject[]]$InputObject) 
    Begin 
    { 
        $dt = new-object Data.datatable   
        $First = $true  
    } 
    Process 
    { 
        foreach ($object in $InputObject) 
        { 
            $DR = $DT.NewRow()   
            foreach($property in $object.PsObject.get_properties()) 
            {   
                if ($first) 
                {   
                    $Col =  new-object Data.DataColumn   
                    $Col.ColumnName = $property.Name.ToString()   
                    if ($property.value) 
                    { 
                        if ($property.value -isnot [System.DBNull]) { $Col.DataType = [System.Type]::GetType("$(Get-Type $property.TypeNameOfValue)")} 
                    } 
                    $DT.Columns.Add($Col) 
                }   
                if ($property.Gettype().IsArray) { 
                    $DR.Item($property.Name) =$property.value | ConvertTo-XML -AS String -NoTypeInformation -Depth 1 
                }   
               else { 
                    $DR.Item($property.Name) = $property.value 
                } 
            }   
            $DT.Rows.Add($DR)   
            $First = $false 
        } 
    }      
    End 
    {     
        Write-Output @(,($dt)) 
    } 
} #Out-DataTable
#####################################################################################################################################

#####################################################################################################################################
#Write-Log
<#
        .SYNOPSIS
                Writes logging information to screen and log file simultaneously.    
        .DESCRIPTION
                Writes logging information to screen and log file simultaneously. Supports multiple log levels.     
        .PARAMETER Message
                The message to be logged.     
        .PARAMETER Level
                The type of message to be logged.                         
        .PARAMETER NoConsoleOut
                Specifies to not display the message to the console.                        
        .PARAMETER ConsoleForeground
                Specifies what color the text should be be displayed on the console. Ignored when switch 'NoConsoleOut' is specified.                  
        .PARAMETER Indent
                The number of spaces to indent the line in the log file.     
        .PARAMETER Path
                The log file path.                  
        .PARAMETER Clobber
                Existing log file is deleted when this is specified.                   
        .PARAMETER EventLogName
                The name of the system event log, e.g. 'Application'.                   
        .PARAMETER EventSource
                The name to appear as the source attribute for the system event log entry. This is ignored unless 'EventLogName' is specified.                   
        .PARAMETER EventID
                The ID to appear as the event ID attribute for the system event log entry. This is ignored unless 'EventLogName' is specified.     
        .EXAMPLE
                PS H:\Temp\> Write-Log -Message "It's all good!" -Path H:\Temp\MyLog.log -Clobber -EventLogName 'Application'     
        .EXAMPLE
                PS H:\Temp\> Write-Log -Message "Oops, not so good!" -Level Error -EventID 3 -Indent 2 -EventLogName 'Application' -EventSource "My Script"     
        .INPUTS
                System.String     
        .OUTPUTS
                No output.                           
        .NOTES
                Revision History:
                        2011-03-10 : Andy Arismendi - Created.
                        2011-07-23 : Will Steele - Updated.
#>
function Write-Log 
{   
            #region Parameters
                    [cmdletbinding()]
                    Param(
                            [Parameter(ValueFromPipeline=$true,Mandatory=$true)] [ValidateNotNullOrEmpty()]
                            [string] $Message,
                            [Parameter()] [ValidateSet("Error", "Warn", "Info")]
                            [string] $Level = "Info",
                            [Parameter()]
                            [Switch] $NoConsoleOut,
                            [Parameter()]
                            [String] $ConsoleForeground = 'White',
                            [Parameter()] [ValidateRange(1,30)]
                            [Int16] $Indent = 0,     
                            [Parameter()]
                            [IO.FileInfo] $Path = "$env:temp\PowerShellLog.txt",                           
                            [Parameter()]
                            [Switch] $Clobber,                          
                            [Parameter()]
                            [String] $EventLogName,                          
                            [Parameter()]
                            [String] $EventSource,                         
                            [Parameter()]
                            [Int32] $EventID = 1,
                            [Parameter()]
                            [String] $LogEncoding = "ASCII"                         
                    )                   
            #endregion
            Begin {}
            Process {
                    try {                  
                            $msg = '{0}{1} : {2} : {3}' -f (" " * $Indent), (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level.ToUpper(), $Message                           
                            if ($NoConsoleOut -eq $false) {
                                    switch ($Level) {
                                            'Error' { Write-Error $Message }
                                            'Warn' { Write-Warning $Message }
                                            'Info' { Write-Host ('{0}{1}' -f (" " * $Indent), $Message) -ForegroundColor $ConsoleForeground}
                                    }
                            }
                            if ($Clobber) {
                                    $msg | Out-File -FilePath $Path -Encoding $LogEncoding -Force
                            } else {
                                    $msg | Out-File -FilePath $Path -Encoding $LogEncoding -Append
                            }
                            if ($EventLogName) {
                           
                                    if (-not $EventSource) {
                                            $EventSource = ([IO.FileInfo] $MyInvocation.ScriptName).Name
                                    }
                           
                                    if(-not [Diagnostics.EventLog]::SourceExists($EventSource)) {
                                            [Diagnostics.EventLog]::CreateEventSource($EventSource, $EventLogName)
                            }
                                $log = New-Object System.Diagnostics.EventLog  
                                $log.set_log($EventLogName)  
                                $log.set_source($EventSource)                       
                                    switch ($Level) {
                                            "Error" { $log.WriteEntry($Message, 'Error', $EventID) }
                                            "Warn"  { $log.WriteEntry($Message, 'Warning', $EventID) }
                                            "Info"  { $log.WriteEntry($Message, 'Information', $EventID) }
                                    }
                            }
                    } catch {
                            throw "Failed to create log entry in: '$Path'. The error was: '$_'."
                    }
            }    
            End {}    
    } #Write-Log
#####################################################################################################################################

######################################################################################################################################
#Function to get Server Membership
function GetServerListInfo($svr, $instance, $groupName) 
{
	$cn = new-object system.data.SqlClient.SqlConnection("Data Source=$InstanceName;Integrated Security=SSPI;Initial Catalog=tempdb");
	$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $cn
	$RunDt = Get-Date -format G

	### Get Local Group Members #####################################################################################################
	try
	{
		$ErrorActionPreference = "Stop"; #Make all errors terminating
		$CITbl = "[Svr].[ServerLocalGroupMembers]"	
		
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

######################################################################################################################################
#Execute Script
try
{
	if ($logPath -notmatch '.+?\\$') { $logPath += '\' } 
	$logPath = $logPath + $logFileName
	$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
	write-log -Message "Script Started at $(get-date)"  -Clobber -Path $logPath

	$cn = new-object system.data.sqlclient.sqlconnection("server=$InstanceName;database=$DatabaseName;Integrated Security=true;");
	$cn.Open()
	$cmd = $cn.CreateCommand()
	if ($runLocally -eq "true")
	{
		$query = "Select Distinct ServerName, InstanceName from [Svr].[ServerList] where Baseline='True' and ServerName = '$env:computername';"
	}
	else
	{
		$query = "Select Distinct ServerName, InstanceName from [Svr].[ServerList] where Baseline='True';"
	}
	$cmd.CommandText = $query
	$reader = $cmd.ExecuteReader()
	while($reader.Read()) 
	{
		$server = $reader['ServerName']
		$instance = $reader['InstanceName']    	
		if ($instance -match "\\") {$SQLServerConnection = $instance} else {$SQLServerConnection = $server + "\" +  $instance}	
		$res = new-object Microsoft.SqlServer.Management.Common.ServerConnection($SQLServerConnection)
		$responds = $false            
		if ($res.ProcessID -ne $null) 
		{
			$responds = $true
			$res.Disconnect()
		}

		If ($responds) 
		{
			# Calling function and passing server and instance parameters
			GetServerListInfo $server $instance $groupName 
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
