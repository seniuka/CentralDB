#####################################################################################################################################
# Get-FirstResponderKit (https://seniuka.github.io/CentralDB/)
# This script will collect data points from the following FirstResponderKit scripts.
# ScriptName		 Type - Description of check
# sp_Blitz:           BLZ - This script checks the health of your SQL Server and gives you a prioritized to-do list of the most urgent things you should consider fixing.
# sp_BlitzBackups:    BLB - This script checks your backups to see how much data you might lose when this server fails, and how long it might take to recover.
# sp_BlitzCache:      BZC - This script displays your most resource-intensive queries from the plan cache, and points to ways you can tune these queries to make them faster.
# sp_BlitzFirst:      BZF - This script gives you a prioritized list of why your SQL Server is slow right now.
# sp_BlitzIndex:      BZI - This script analyzes the design and performance of your indexes.
# sp_BlitzQueryStore: BQS - This script displays your most resource-intensive queries from the Query Store, and points to ways you can tune these queries to make them faster.
# sp_BlitzWho:        BZW - This script gives you a snapshot of everything currently executing on your SQL Server.
#
#                                                            This script is brand spanking new; this baby could crash your server so hard! 
#####################################################################################################################################

#####################################################################################################################################
#Parameter List
param(
	[string]$InstanceName="", #CMS Server with CentralDB
	[string]$DatabaseName="", #CMS Server with CentralDB
    [string]$runLocally="false", #This flag is used to reduce the number of remote powershell calls from a single cms
	[string]$type="", #3 Letters from the following sp_Blitz:BLZ, sp_BlitzBackups:BLB, sp_BlitzCache:BZC, p_BlitzFirst:BZF, sp_BlitzIndex:BZI, sp_BlitzQueryStore:BQS, sp_BlitzWho:BZW
	[string]$FirstResponderKitPath="", #Where does FirstResponderKit live... the sql files? So we can load the newest version.
	[string]$FirstResponderKitFilter="Install-Core-Blitz-No-Query-Store.sql", #If you rename them... what are they named by default they are sp_Blitz*.sql...
	[string]$logPath="",
	[string]$logFileName="Get-FirstResponderKit_" + $env:computername + ".log"
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
                            [Parameter()] [ValidateSet(“Error”, “Warn”, “Info”)]
                            [string] $Level = “Info”,
                            [Parameter()]
                            [Switch] $NoConsoleOut,
                            [Parameter()]
                            [String] $ConsoleForeground = 'White',
                            [Parameter()] [ValidateRange(1,30)]
                            [Int16] $Indent = 0,     
                            [Parameter()]
                            [IO.FileInfo] $Path = ”$env:temp\PowerShellLog.txt”,                           
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
                            $msg = '{0}{1} : {2} : {3}' -f (" " * $Indent), (Get-Date -Format “yyyy-MM-dd HH:mm:ss”), $Level.ToUpper(), $Message                           
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
                                            “Error” { $log.WriteEntry($Message, 'Error', $EventID) }
                                            “Warn”  { $log.WriteEntry($Message, 'Warning', $EventID) }
                                            “Info”  { $log.WriteEntry($Message, 'Information', $EventID) }
                                    }
                            }
                    } catch {
                            throw “Failed to create log entry in: ‘$Path’. The error was: ‘$_’.”
                    }
            }    
            End {}    

    } #Write-Log
#####################################################################################################################################

#####################################################################################################################################
#Create-FirstResponderKit	[Function to get Server list info]
function Create-FirstResponderKit($svr, $inst, $type) 
{
	# Create an ADO.Net connection to the instance
	$InstanceSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$inst;Integrated Security=SSPI;Initial Catalog=tempdb;");
    $sc = $InstanceSQLConn.CreateCommand()  
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
            $SQLArray = New-Object System.Collections.ArrayList
            $i = 0
            $Path = $FirstResponderKitPath
            $Filter = $FirstResponderKitFilter   
            $FirstResponderKitFiles = Get-ChildItem -LiteralPath $Path -Filter $Filter -File
			Write-Log -Message "### FILE PROCSSING ############################################" -Level Info -Path $logPath
			foreach($FirstResponderKitFile in $FirstResponderKitFiles)
			{
                $SQLCommandText = @(Get-Content -Path $FirstResponderKitFile.FullName) 
                $message = "### LOADING FILE " + $FirstResponderKitFile.FullName
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
			Write-Log -Message "Create-FirstResponderKit $type on Instance $inst" -Level Info -Path $logPath
		} 
		catch 
		{ 
			$ex = $_.Exception 
		    write-log -Message "$ex.Message on $inst While Create-FirstResponderKit" -Path $logPath
		} 
		finally
		{
   			$ErrorActionPreference = "Continue"; #Reset the error action pref to default
            $InstanceSQLConn.close | Out-Null
		}
	}
	else 
	{             
		write-log -Message "SQL Server DB Engine is not Installed or Started or inaccessible on $inst" -Path $logPath
	}
	#################################################################################################################################

} #Create-FirstResponderKit
######################################################################################################################################

#####################################################################################################################################
#Get-FirstResponderKit	[Function to get Server list info]
function Get-FirstResponderKit($svr, $inst, $type) 
{
	# Create an ADO.Net connection to the instance
	$InstanceSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$inst;Integrated Security=SSPI;Initial Catalog=tempdb;");
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
			switch($Type)
			{
				"BLZ" 
                {
                    Write-Log -Message "### CLEAR Temp Table Collection #########################################" -Level Info -Path $logPath
					$queryBLZ = "IF OBJECT_ID (N'Blitz', N'U') IS NOT NULL BEGIN DELETE FROM tempdb.dbo.Blitz END"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBLZ, $InstanceSQLConn)
					$dt = new-object System.Data.DataTable
					$da.fill($dt) | out-null

                    $sc = $InstanceSQLConn.CreateCommand()                    
                    Write-Log -Message "### EXECUTING sp_Blitz ############################################" -Level Info -Path $logPath			 
					$queryBLZ = "EXEC dbo.sp_Blitz
					 @OutputDatabaseName = 'tempdb'
					,@OutputSchemaName = 'dbo'
					,@OutputTableName = 'Blitz'
					,@CheckUserDatabaseObjects = 1
                    ,@CheckProcedureCache = 1
                    ,@OutputProcedureCache = 1
                    ,@CheckServerInfo = 1"
                    $sc.CommandText = $queryBLZ
					$da = new-object System.Data.SqlClient.SqlDataAdapter $sc             
					$ds = new-object System.Data.DataSet
					$da.fill($ds) | out-null

                    Write-Log -Message "### CENTRALIZING sp_Blitz Data ############################################" -Level Info -Path $logPath	
					$CITbl = "[FRK].[Blitz]"	
					$queryBLZ = "SELECT * FROM tempdb.dbo.Blitz"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBLZ, $InstanceSQLConn)
					$dt = new-object System.Data.DataTable
					$da.fill($dt) | out-null
					Write-DataTable -ServerInstance $InstanceName -Database $DatabaseName -TableName $CITbl -Data $dt -Verbose | out-null       

                }
				"BLB" {}
				"BZC" {}
				"BZF" 
				{		
                    Write-Log -Message "### CLEAR Temp Table Collection #########################################" -Level Info -Path $logPath
					$queryBZF = "IF OBJECT_ID (N'BlitzFirst', N'U') IS NOT NULL BEGIN DELETE FROM tempdb.dbo.BlitzFirst END"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBZF, $InstanceSQLConn)
					$dt = new-object System.Data.DataTable
					$da.fill($dt) | out-null
					$queryBZF = "IF OBJECT_ID (N'BlitzFirst_FileStats', N'U') IS NOT NULL BEGIN DELETE FROM tempdb.dbo.BlitzFirst_FileStats END"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBZF, $InstanceSQLConn) 
					$dt = new-object System.Data.DataTable 
					$da.fill($dt) | out-null 
                    $queryBZF = "IF OBJECT_ID (N'BlitzFirst_PerfmonStats', N'U') IS NOT NULL BEGIN DELETE FROM tempdb.dbo.BlitzFirst_PerfmonStats END"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBZF, $InstanceSQLConn) 
					$dt = new-object System.Data.DataTable 
					$da.fill($dt) | out-null 
                    $queryBZF = "IF OBJECT_ID (N'BlitzFirst_WaitStats', N'U') IS NOT NULL BEGIN DELETE FROM tempdb.dbo.BlitzFirst_WaitStats END"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBZF, $InstanceSQLConn) 
					$dt = new-object System.Data.DataTable 
					$da.fill($dt) | out-null 
                    $queryBZF = "IF OBJECT_ID (N'BlitzCache', N'U') IS NOT NULL BEGIN DELETE FROM tempdb.dbo.BlitzCache END"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBZF, $InstanceSQLConn) 
					$dt = new-object System.Data.DataTable 
					$da.fill($dt) | out-null 

                    $sc = $InstanceSQLConn.CreateCommand()                    
                    Write-Log -Message "### EXECUTING sp_BlitzFirst ############################################" -Level Info -Path $logPath			 
					$queryBZF = "EXEC dbo.sp_BlitzFirst
					 @OutputDatabaseName = 'tempdb'
					,@OutputSchemaName = 'dbo'
					,@OutputTableName = 'BlitzFirst'
					,@OutputTableNameFileStats = 'BlitzFirst_FileStats'
					,@OutputTableNamePerfmonStats = 'BlitzFirst_PerfmonStats'
					,@OutputTableNameWaitStats = 'BlitzFirst_WaitStats'
					,@OutputTableNameBlitzCache = 'BlitzCache'" 
                    $sc.CommandText = $queryBZF
					$da = new-object System.Data.SqlClient.SqlDataAdapter $sc             
					$ds = new-object System.Data.DataSet
					$da.fill($ds) | out-null
                    
                    Write-Log -Message "### CENTRALIZING BlitzFirst Data ############################################" -Level Info -Path $logPath					
					$CITbl = "[FRK].[BlitzFirst]"	
					$queryBZF = "SELECT * FROM tempdb.dbo.BlitzFirst"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBZF, $InstanceSQLConn)
					$dt = new-object System.Data.DataTable
					$da.fill($dt) | out-null
					Write-DataTable -ServerInstance $InstanceName -Database $DatabaseName -TableName $CITbl -Data $dt -Verbose | out-null                       

					Write-Log -Message "### CENTRALIZING BlitzFirst_FileStats Data ############################################" -Level Info -Path $logPath
					$CITbl = "[FRK].[BlitzFirst_FileStats]"	
					$queryBZF = "SELECT * FROM tempdb.dbo.BlitzFirst_FileStats"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBZF, $InstanceSQLConn) 
					$dt = new-object System.Data.DataTable 
					$da.fill($dt) | out-null 
					Write-DataTable -ServerInstance $InstanceName -Database $DatabaseName -TableName $CITbl -Data $dt -Verbose | out-null            

					Write-Log -Message "### CENTRALIZING BlitzFirst_PerfmonStats Data ############################################" -Level Info -Path $logPath
					$CITbl = "[FRK].[BlitzFirst_PerfmonStats]"	
					$queryBZF = "SELECT * FROM tempdb.dbo.BlitzFirst_PerfmonStats"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBZF, $InstanceSQLConn)
					$dt = new-object System.Data.DataTable
					$da.fill($dt) | out-null
					Write-DataTable -ServerInstance $InstanceName -Database $DatabaseName -TableName $CITbl -Data $dt -Verbose | out-null         

					Write-Log -Message "### CENTRALIZING BlitzFirst_WaitStats Data ############################################" -Level Info -Path $logPath
					$CITbl = "[FRK].[BlitzFirst_WaitStats]"	
					$queryBZF = "SELECT * FROM tempdb.dbo.BlitzFirst_WaitStats"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBZF, $InstanceSQLConn)
					$dt = new-object System.Data.DataTable
					$da.fill($dt) | out-null
					Write-DataTable -ServerInstance $InstanceName -Database $DatabaseName -TableName $CITbl -Data $dt -Verbose | out-null   

					Write-Log -Message "### CENTRALIZING BlitzCache Data ############################################" -Level Info -Path $logPath					
                    $CITbl = "[FRK].[BlitzCache]"	
					$queryBZF = "SELECT * FROM tempdb.dbo.BlitzCache"
					$da = new-object System.Data.SqlClient.SqlDataAdapter ($queryBZF, $InstanceSQLConn)
					$dt = new-object System.Data.DataTable
					$da.fill($dt) | out-null
					Write-DataTable -ServerInstance $InstanceName -Database $DatabaseName -TableName $CITbl -Data $dt -Verbose | out-null  				
				}
				"BZI" {}
				"BQS" {}
				"BZW" {}
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
		    write-log -Message "$ex.Message on $inst While Get-FirstResponderKit"   -Path $logPath
		} 
		finally
		{
   			$ErrorActionPreference = "Continue"; #Reset the error action pref to default
            $cn.close | Out-Null
		}
	}
	else 
	{             
		write-log -Message "SQL Server DB Engine is not Installed or Started or inaccessible on $inst" -Path $logPath
	}
	#################################################################################################################################

} #Get-FirstResponderKit
######################################################################################################################################

######################################################################################################################################
#Execute Script
try
{
	if ($logPath -notmatch '.+?\\$') { $logPath += '\' }  
    if ($FirstResponderKitPath -notmatch '.+?\\$') {$FirstResponderKitPath += '\' } 

	$logPath = $logPath + $logFileName
	$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
	write-log -Message "Script Started at $(get-date)"  -Clobber -Path $logPath

	$cn = new-object system.data.sqlclient.sqlconnection(“server=$InstanceName;database=$DatabaseName;Integrated Security=true;”);
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
			# Calling funtion and passing server and instance parameters
			Create-FirstResponderKit $server $instance $type
            Get-FirstResponderKit $server $instance $type
		}
		else 
		{
 			# Let the user know we couldn't connect to the server
            if ($instance -match "\\") { $message = $instance + " did not respond. Please check connectivity and try again." } else { $message = $server + "\" +  $instance + " did not respond. Please check connectivity and try again."}	
			write-log -Message $message -Path $logPath
		}  
	}
	write-log -Message "Script Ended at $(get-date)"  -Path $logPath
	write-log -Message "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"  -Path $logPath
}
catch
{
	$ex = $_.Exception 
	$line = $_.InvocationInfo.ScriptLineNumber
	write-log -Message "$ex.Message on $svr excuting script Get-BaselineStats.ps1" -Level Error -Path $logPath 
	write-log -Message "$ex.Message at line number $line in Get-BaselineStats.ps1" -Level Error -Path $logPath 
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