#####################################################################################################################################
# Get-OlaHallengren-Integrity (https://seniuka.github.io/CentralDB/)
# This script will execute the database integrity checks


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
    [string]$BlockSize = $null,
    [string]$BufferCount = $null,
    [string]$MaxTransferSize = $null,
    [string]$NumberOfFiles = $null,
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
    
    [string]$Updateability= 'ALL',
    [string]$LogToTable= 'Y',
	[string]$Execute= 'Y',
	[string]$LoadGUID= $null,

	[string]$OlaHallengrenPath="", #Where does OlaHallengren live... path to the .sql files
	[string]$OlaHallengrenCommandLogFilter="CommandLog.sql", #If you rename them... what are they named by default CommandLog.sql...
    [string]$OlaHallengrenCommandExecuteFilter="CommandExecute.sql", #If you rename them... what are they named by default CommandExecute.sql...
	[string]$OlaHallengrenCommandActionFilter="DatabaseBackup.sql", #If you rename them... what are they named by default DatabaseBackup.sql...

	[string]$logPath="",
	[string]$logFileName="Get-OlaHallengren-Backup_" + $env:computername + ".log"
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
            $Path = $OlaHallengrenPath
            $Filter = $OlaHallengrenFilter             

            $OlaHallengrenFiles = Get-ChildItem -LiteralPath $Path -Include @($OlaHallengrenCommandLogFilter, $OlaHallengrenCommandExecuteFilter, $OlaHallengrenCommandActionFilter) -File -Recurse
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
		    write-log -Message "$ex.Message on $inst While Create-OlaHallengren" -Path $logPath
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
           if ($BackupType -eq "FULL"){$TypeName = 'Database Backup - Full'}
           if ($BackupType -eq "LOG"){$TypeName = 'Database Backup - Transaction Log'}
           if ($BackupType -eq "DIFF"){$TypeName = 'Database Backup - Differential'}
            
            $sc = $InstanceSQLConn.CreateCommand()                    
            Write-Log -Message "### EXECUTING DatabaseBackup ############################################" -Level Info -Path $logPath			 
			$query = "EXEC dbo.[DatabaseBackup] "
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
            if (![string]::IsNullOrEmpty($BlockSize)){$query = $query + "@BlockSize = $BlockSize,"}
            if (![string]::IsNullOrEmpty($BufferCount)){$query = $query + "@BufferCount = $BufferCount,"}
            if (![string]::IsNullOrEmpty($MaxTransferSize)){$query = $query + "@MaxTransferSize = $MaxTransferSize,"}
            if (![string]::IsNullOrEmpty($NumberOfFiles)){$query = $query + "@NumberOfFiles = $NumberOfFiles,"}
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
            if (![string]::IsNullOrEmpty($Updateability)){$query = $query + "@Updateability= '$Updateability',"}
            if (![string]::IsNullOrEmpty($LogToTable)){$query = $query + "@LogToTable= '$LogToTable',"}
	        if (![string]::IsNullOrEmpty($Execute)){$query = $query + "@Execute= '$Execute',"}
	        if (![string]::IsNullOrEmpty($LoadGUID)){$query = $query + "@LoadGUID = '$LoadGUID'"}
            Write-Output $query
            $sc.CommandText = $query
			$da = new-object System.Data.SqlClient.SqlDataAdapter $sc  
            $da.SelectCommand.CommandTimeout = $CommandTimeout       
			$ds = new-object System.Data.DataSet
			$da.fill($ds) | out-null

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
                            FROM tempdb.dbo.CommandLog WHERE LoadGUID = '$LoadGUID'"
            Write-Output $query
			$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $InstanceSQLConn)
			$dt = new-object System.Data.DataTable
			$da.fill($dt) | out-null            
            Write-DataTable -ServerInstance $InstanceName -Database $DatabaseName -TableName $CITbl -Data $dt -Verbose | out-null  

            Write-Log -Message "### CLEAR LOCAL DatabaseBackup Data #########################################" -Level Info -Path $logPath
			$query = "IF OBJECT_ID (N'CommandLog', N'U') IS NOT NULL BEGIN DELETE FROM tempdb.dbo.CommandLog WHERE LoadGUID = '$LoadGUID' END"
			$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $InstanceSQLConn)
			$dt = new-object System.Data.DataTable
			$da.fill($dt) | out-null

			Write-Log -Message "Get-OlaHallengren $type on Instance $inst" -Level Info -Path $logPath
		} 
		catch 
		{ 
			$ex = $_.Exception 
		    write-log -Message "$ex.Message on $inst While Get-OlaHallengren"   -Path $logPath
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

} #Get-OlaHallengren
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
			# Calling funtion and passing server and instance parameters

            if ([string]::IsNullOrEmpty($LoadGUID)){$LoadGUID = [guid]::NewGuid().ToString()}			
            Create-OlaHallengren $server $instance $type
            Get-OlaHallengren $server $instance $type
		}
		else 
		{
 			# Let the user know we couldn't connect to the server
            if ($instance -match "\\") { $message = $instance + " did not respond. Please check connectivity and try again." } else { $message = $server + "\" +  $instance + " did not respond. Please check connectivity and try again."}	
			write-log -Message $message -Path $logPath
		}  
        
        $LoadGUID = $null
	}
	write-log -Message "Script Ended at $(get-date)"  -Path $logPath
	write-log -Message "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"  -Path $logPath
}
catch
{
	$ex = $_.Exception 
	write-log -Message "$ex.Message on $svr excuting script Get-BaselineStats.ps1" -Level Error -Path $logPath 
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
