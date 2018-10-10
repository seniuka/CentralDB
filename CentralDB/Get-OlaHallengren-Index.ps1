#####################################################################################################################################
# Get-OlaHallengren-Index (https://seniuka.github.io/CentralDB/)
# This script will execute database index reorg/rebuild or statistics rebuild
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
     
    [string]$Databases= 'ALL_DATABASES',    
    [string]$FragmentationLow = $null,
    [string]$FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
    [string]$FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
    [int32] $FragmentationLevel1 = 5,
    [int32] $FragmentationLevel2 = 30,
    [int32] $PageCountLevel = 1000,
    [string]$SortInTempdb = 'N',
    [int32] $MaxDOP = $null,
    [int32] $MaxNumberOfPages = $null,
    [string]$FillFactor = $null,
    [string]$PadIndex = $null,
    [string]$LOBCompaction = 'Y',
    [string]$UpdateStatistics = $null,
    [string]$OnlyModifiedStatistics = 'N',
    [int32] $StatisticsModificationLevel = $null,
    [string]$StatisticsSample = $null,
    [string]$StatisticsResample = 'N',
    [string]$PartitionLevel = 'Y',
    [string]$MSShippedObjects = 'N',
    [string]$Resumable = 'N',
    [string]$Indexes = $null,
    [string]$TimeLimit = $null,
    [string]$Delay = $null,
    [string]$WaitAtLowPriorityMaxDuration = $null,
    [string]$WaitAtLowPriorityAbortAfterWait = $null,
    [string]$AvailabilityGroups= $null,
    [int32] $LockMessageSeverity = 16,
    [string]$DatabaseOrder = $null,
    [string]$DatabasesInParallel = 'N',
    [int32] $LockTimeout= 10800, #seconds
    [string]$LogToTable= 'Y',
	[string]$Execute= 'Y',
	[string]$LoadGUID= $null,

	[string]$OlaHallengrenDeployDB="TempDB",
	[string]$OlaHallengrenPath="", #Where does OlaHallengren live... path to the .sql files
	[string]$OlaHallengrenFilter = "CommandExecute.sql|IndexOptimize.sql|Queue.sql|QueueDatabase.sql|Version.sql",

	[string]$logPath="",
	[string]$logFileName="Get-OlaHallengren-Index_" + $env:computername + ".log"
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
#Create-OlaHallengren	[Function to get Server list info]
function Create-OlaHallengren($svr, $inst, $type) 
{

	# Create an ADO.Net connection to the instance
	$InstanceSQLConn = new-object system.data.SqlClient.SqlConnection("Data Source=$inst;Integrated Security=SSPI;Initial Catalog=" + $OlaHallengrenDeployDB + ";");
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
            $Path = $OlaHallengrenPath
            $Filter = $OlaHallengrenFilter             

            $OlaHallengrenFiles = Get-ChildItem -LiteralPath $Path | Where-Object {$_.Name -match $OlaHallengrenFilter}
			Write-Log -Message "### FILE PROCSSING ############################################" -Level Info -Path $logPath
			foreach($OlaHallengrenFile in $OlaHallengrenFiles)
			{
                $SQLCommandText = @(Get-Content -Path $OlaHallengrenFile.FullName) 
                $message = "### LOADING FILE " + $OlaHallengrenFile.FullName
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
			Write-Log -Message "Create-OlaHallengren $type on Instance $inst" -Level Info -Path $logPath
		} 
		catch 
		{ 
            $ex = $_.Exception
            $line = $_.InvocationInfo.PositionMessage
	        write-log -Message "Get-OlaHallengren-Index.ps1 | Catch Message: $ex.Message ($line) on $svr executing script." -Level Error -Path $logPath
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
function Get-OlaHallengren($svr, $inst, $type) 
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
            $TypeName = "Database Index Optimize"
            $sc = $InstanceSQLConn.CreateCommand()                    
            Write-Log -Message "Get-OlaHallengren-Index.ps1 | EXECUTING Index Optimize ############################################" -Level Info -Path $logPath			 
			$query = "EXEC dbo.[IndexOptimize] "   
            if (![string]::IsNullOrEmpty($Databases)){$query = $query + "@Databases= '$Databases',"}           
			if (![string]::IsNullOrEmpty($FragmentationLow)){$query = $query + "@FragmentationLow= '$FragmentationLow',"} else {$query = $query + "@FragmentationLow=NULL,"}			
			if (![string]::IsNullOrEmpty($FragmentationMedium)){$query = $query + "@FragmentationMedium= '$FragmentationMedium',"} else {$query = $query + "@FragmentationMedium=NULL,"}			
			if (![string]::IsNullOrEmpty($FragmentationHigh)){$query = $query + "@FragmentationHigh= '$FragmentationHigh',"} else {$query = $query + "@FragmentationHigh=NULL,"}			
			if (![string]::IsNullOrEmpty($FragmentationLevel1)){$query = $query + "@FragmentationLevel1= $FragmentationLevel1,"}
            if (![string]::IsNullOrEmpty($FragmentationLevel2)){$query = $query + "@FragmentationLevel2= $FragmentationLevel2,"}
            ##if (![string]::IsNullOrEmpty($PageCountLevel)){$query = $query + "@PageCountLevel= $PageCountLevel,"}
            if (![string]::IsNullOrEmpty($SortInTempdb)){$query = $query + "@SortInTempdb= '$SortInTempdb',"}
            if (![string]::IsNullOrEmpty($MaxDOP)){$query = $query + "@MaxDOP= $MaxDOP,"} else {$query = $query + "@MaxDOP= $NULL,"}
            if($MaxNumberOfPages){$query = $query + "@MaxNumberOfPages = $MaxNumberOfPages,"} else {$query = $query + "@MaxNumberOfPages=NULL,"}
            if (![string]::IsNullOrEmpty($FillFactor)){$query = $query + "@FillFactor= '$FillFactor',"}
            if (![string]::IsNullOrEmpty($PadIndex)){$query = $query + "@PadIndex= '$PadIndex',"}
            if (![string]::IsNullOrEmpty($LOBCompaction)){$query = $query + "@LOBCompaction= '$LOBCompaction',"}
            if (![string]::IsNullOrEmpty($UpdateStatistics)){$query = $query + "@UpdateStatistics= '$UpdateStatistics',"}
            if (![string]::IsNullOrEmpty($OnlyModifiedStatistics)){$query = $query + "@OnlyModifiedStatistics= '$OnlyModifiedStatistics',"}  
            if($StatisticsModificationLevel){$query = $query + "@StatisticsModificationLevel = $StatisticsModificationLevel,"} else {$query = $query + "@StatisticsModificationLevel=NULL,"}
            if (![string]::IsNullOrEmpty($StatisticsSample)){$query = $query + "@StatisticsSample= '$StatisticsSample',"}
            if (![string]::IsNullOrEmpty($StatisticsResample)){$query = $query + "@StatisticsResample= '$StatisticsResample',"}
            if (![string]::IsNullOrEmpty($PartitionLevel)){$query = $query + "@PartitionLevel= '$PartitionLevel',"}
            if (![string]::IsNullOrEmpty($MSShippedObjects)){$query = $query + "@MSShippedObjects= '$MSShippedObjects',"}
            if (![string]::IsNullOrEmpty($Resumable)){$query = $query + "@Resumable= '$Resumable',"}
            if (![string]::IsNullOrEmpty($Indexes)){$query = $query + "@Indexes= '$Indexes',"}
            if (![string]::IsNullOrEmpty($TimeLimit)){$query = $query + "@TimeLimit= $TimeLimit,"}
            if (![string]::IsNullOrEmpty($Delay)){$query = $query + "@Delay= $Delay,"}
            if (![string]::IsNullOrEmpty($WaitAtLowPriorityMaxDuration)){$query = $query + "@WaitAtLowPriorityMaxDuration= '$WaitAtLowPriorityMaxDuration',"}
            if (![string]::IsNullOrEmpty($WaitAtLowPriorityAbortAfterWait)){$query = $query + "@WaitAtLowPriorityAbortAfterWait= '$WaitAtLowPriorityAbortAfterWait',"}
            if (![string]::IsNullOrEmpty($AvailabilityGroups)){$query = $query + "@AvailabilityGroups= '$AvailabilityGroups',"}
            if($LockMessageSeverity){$query = $query + "@LockMessageSeverity = $LockMessageSeverity,"} else {$query = $query + "@LockMessageSeverity=NULL,"}
            if (![string]::IsNullOrEmpty($DatabaseOrder)){$query = $query + "@DatabaseOrder= '$DatabaseOrder',"}
            if (![string]::IsNullOrEmpty($DatabasesInParallel)){$query = $query + "@DatabasesInParallel= '$DatabasesInParallel',"}
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

            Write-Log -Message "Get-OlaHallengren-Index.ps1 | CENTRALIZING Index Optimize Data ############################################" -Level Info -Path $logPath	
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
                            FROM tempdb.dbo.CommandLog WHERE LoadGUID = '$LoadGUID'"
            Write-Output $query
			$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $InstanceSQLConn)
			$dt = new-object System.Data.DataTable
			$da.fill($dt) | out-null            
            Write-DataTable -ServerInstance $InstanceName -Database $DatabaseName -TableName $CITbl -Data $dt -Verbose | out-null  

            Write-Log -Message "Get-OlaHallengren-Index.ps1 | CLEAR LOCAL Index Optimize Data #########################################" -Level Info -Path $logPath
            $query = "IF OBJECT_ID (N'CommandLog', N'U') IS NOT NULL BEGIN DELETE FROM tempdb.dbo.CommandLog WHERE LoadGUID = '$LoadGUID' END; 
                      IF OBJECT_ID (N'QueueDatabase', N'U') IS NOT NULL BEGIN DELETE FROM [tempdb].[dbo].[QueueDatabase] where RequestStartTime <= dateadd(day, -1, getDate()) END;
                      IF OBJECT_ID (N'Queue', N'U') IS NOT NULL BEGIN DELETE FROM [tempdb].[dbo].[Queue] where RequestStartTime <= dateadd(day, -1, getDate()) END;
                      IF OBJECT_ID (N'CommandLog', N'U') IS NOT NULL BEGIN DELETE FROM [tempdb].[dbo].[CommandLog] where [EndTime] <= dateadd(day, -1, getDate()) END;"
			$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $InstanceSQLConn)
			$dt = new-object System.Data.DataTable
			$da.fill($dt) | out-null

			Write-Log -Message "Get-OlaHallengren-Index.ps1 | Completed Execution On Instance $inst" -Level Info -Path $logPath
		} 
        catch
        {
            $ex = $_.Exception
            $line = $_.InvocationInfo.PositionMessage
	        write-log -Message "Get-OlaHallengren-Index.ps1 | Catch Message: $ex.Message ($line) on $svr executing script." -Level Error -Path $logPath 
        }
		finally
		{
   			$ErrorActionPreference = "Stop"; #Reset the error action pref to default
            $cn.close | Out-Null
		}
	}
	else 
	{             
		Throw "SQL Server DB Engine is not Installed or Started or inaccessible on $inst"
	}
	#################################################################################################################################

} #Get-OlaHallengren-Index
######################################################################################################################################

######################################################################################################################################
#Execute Script
try
{
	if ($logPath -notmatch '.+?\\$') { $logPath += '\' }  
    if ($OlaHallengrenPath -notmatch '.+?\\$') {$OlaHallengrenPath += '\' } 

	$logPath = $logPath + $logFileName
	$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
	write-log -Message "Script Started at $(get-date)"  -Clobber -Path $logPath

	$cn = new-object system.data.sqlclient.sqlconnection(“server=$InstanceName;database=$DatabaseName;Integrated Security=true;”);
	$cn.Open()
	$cmd = $cn.CreateCommand()
	if ($runLocally -eq "true")
	{
		$query = "Select Distinct ServerName, InstanceName from [Svr].[ServerList] where ServerName = '$env:computername';"
	}
	else
	{
		$query = "Select Distinct ServerName, InstanceName from [Svr].[ServerList];"
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
            write-log -Message "DeployScripts: $DeployScripts"  -Path $logPath
            if ([string]::IsNullOrEmpty($LoadGUID)){$LoadGUID = [guid]::NewGuid().ToString()}			
            if ([string]::IsNullOrEmpty($DeployScripts)){$DeployScripts = 'Y'}
            if ($DeployScripts -eq 'Y'){Create-OlaHallengren $server $instance $type}
            Get-OlaHallengren $server $instance $type
		}
		else 
		{
 			# Let the user know we couldn't connect to the server
            if ($instance -match "\\") { $message = $instance + " did not respond. Please check connectivity and try again." } else { $message = $server + "\" +  $instance + " did not respond. Please check connectivity and try again."}	
			write-log -Message $message -Path $logPath
		}  
        $LoadGUID = $null;
	}
	write-log -Message "Get-OlaHallengren-Index.ps1 | Script Ended at $(get-date)"  -Path $logPath
	write-log -Message "Get-OlaHallengren-Index.ps1 | Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"  -Path $logPath
}
catch
{
    $ex = $_.Exception
    $line = $_.InvocationInfo.PositionMessage
	write-log -Message "Get-OlaHallengren-Index.ps1 | Catch Message: $ex.Message ($line) on $svr executing script." -Level Error -Path $logPath 
}
#Execute Script
######################################################################################################################################

############################################################################################################################################################
<# 
	Special thanks to Ola Hallengren (All of the people who contribute to the Ola Hallengren Maintenance Scripts) 
	for the hard work he does providing us with exceptional scripts to assist with DBA tasks.
	Please check out OlaHallengren.org to get the newest version! Also say thanks.
#>
############################################################################################################################################################
