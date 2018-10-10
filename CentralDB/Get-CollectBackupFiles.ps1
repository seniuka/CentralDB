###################################################################################################################################
<# Based on Allen White, Collen Morrow, Erin Stellato's and Jonathan Kehayias Scripts for SQL Inventory and Baselining
https://www.simple-talk.com/sql/database-administration/let-powershell-do-an-inventory-of-your-servers/
http://colleenmorrow.com/2012/04/23/the-importance-of-a-sql-server-inventory/
http://www.sqlservercentral.com/articles/baselines/94657/ 
https://www.simple-talk.com/sql/performance/a-performance-troubleshooting-methodology-for-sql-server/#>
###################################################################################################################################
param(
    [String]$Type,
	[string]$SQLInst="",
	[string]$Centraldb="CentralDB",	
    [int32]$CommandTimeout=7200,
    [string]$BackupPath    = "\\" + ((ipconfig | select-string -notmatch "169.254" | select-string -notmatch "169.168" | select-string -notmatch "255.255" | select-string -notmatch "192.168" | findstr [0-9].\.)[0].Split()[-1]).ToString().Remove(((ipconfig | findstr [0-9].\.)[0].Split()[-1]).ToString().LastIndexOf(".")) + ".195" + "\SQL_NASBackup",
    [string]$LogPath = "\\" + ((ipconfig | select-string -notmatch "169.254" | select-string -notmatch "169.168" | select-string -notmatch "255.255" | select-string -notmatch "192.168" | findstr [0-9].\.)[0].Split()[-1]).ToString().Remove(((ipconfig | findstr [0-9].\.)[0].Split()[-1]).ToString().LastIndexOf('.')) + ".195" + "\SQL_NASBackup\_CentralDB\Errorlog\"
	)
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement') | out-null
#####################################################################################################################################
<#Author: Chad Miller http://Sev17.com
Write-DataTable Function: http://gallery.technet.microsoft.com/scriptcenter/2fdeaf8d-b164-411c-9483-99413d6053ae
Out-DataTable Function: http://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd #>
#####################################################################################################################################
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
        #$bulkCopy
        #write-log -Message "connectionString" -Path $LogPath
        $bulkCopy.DestinationTableName = $tableName 
        #write-log -Message "TableName $tableName" -Path $LogPath
        $bulkCopy.BatchSize = $BatchSize 
        $bulkCopy.BulkCopyTimeout = $QueryTimeOut 
        $bulkCopy.WriteToServer($Data) 
        #write-log -Message "write to server" -Path $LogPath
        $conn.Close() 
    } 
    Catch [System.Management.Automation.MethodInvocationException]
    {
	$ex = $_.Exception 
	write-log -Message "$ex.Message on $svr" -Level Error  -Path $LogPath
    }
    catch 
    { 
        $ex = $_.Exception 
        write-log -Message "$ex.Message on $svr"  -Level Error  -Path $LogPath
    } 
} #Write-DataTable
###########################################################################################################################
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
##########################################logging####################################################################################
#http://poshcode.org/2813
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
                            throw “Failed to create log entry in: ‘$BackupPath’. The error was: ‘$_’.”
                    }
            }    
            End {}    
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
    }
	
######################################################################################################################################
#Fucntion to CollectBackupFileData
function CollectBackupFileData
{
    Param
    (
        [string] $Type,
        [string] $BackupPath
    )
	# Create an ADO.Net connection to the instance
    #$cn = new-object system.data.SqlClient.SqlConnection("Data Source=$inst;Integrated Security=SSPI;Initial Catalog=tempdb");
    #$s = new-object (‘Microsoft.SqlServer.Management.Smo.Server’) $cn
	#$RunDt = Get-Date -format G
################################################## Load Command Log #################################################################
try 
    { 	
		$ErrorActionPreference = "Stop"; #Make all errors terminating

        write-log -Message "$Type | Start Path $BackupPath Processing"
        cd C:\
        $Files = cmd.exe /c "dir $BackupPath /a-d /-c /s"
        write-log -Message "$Type | Finished Path $BackupPath Processing"
        return ,$Files
    }    
catch 
	{ 
        $ex = $_.Exception 
	    write-log -Message "$Type | Generated this exception [$ex] while collecting backup file data" -Path $LogPath
	} 
finally{
   		$ErrorActionPreference = "Stop"; #Reset the error action pref to default
	}
}
######################################################################################################################################

######################################################################################################################################
#Fucntion to StageBackupFileData
function StageBackupFileData
{
    Param
    (
        [string] $Type,
        [string[]] $Files,
        [guid] $GUID
    )
	# Create an ADO.Net connection to the instance
    #$cn = new-object system.data.SqlClient.SqlConnection("Data Source=$inst;Integrated Security=SSPI;Initial Catalog=tempdb");
    #$s = new-object (‘Microsoft.SqlServer.Management.Smo.Server’) $cn
	$RunDt = Get-Date -format G
################################################## Load Command Log #################################################################
try 
    { 
        
        $ErrorActionPreference = "Stop";
        $CITbl = “[Inst].[BackupStage]”
        $DateAdded = $(get-date)

        $dt = new-object System.Data.DataTable "FileArray"
        $colDir = new-object System.Data.DataColumn Directory,([string])
        $colFile = new-object System.Data.DataColumn FileName,([string])
        $colSize = new-object System.Data.DataColumn FileSize,([string])
        $colDate = new-object System.Data.DataColumn FileDate,([string])
        $colDateAdded = new-object System.Data.DataColumn DateAdded,([string])
        $dt.Columns.Add($colDir)
        $dt.Columns.Add($colFile)
        $dt.Columns.Add($colSize)
        $dt.Columns.Add($colDate)
        $dt.Columns.Add($colDateAdded)

        write-log -Message "$Type | Starting DataTable Processing" -Path $LogPath      
        ForEach ($File in $Files)
        {   
            If ($File -match "Directory of (?<Folder>.*)")
            {   
                $CurrentDir = $Matches.Folder
            }
            ElseIf ($File -match "(?<Date>.* [a|p]m) +(?<Size>.*?) (?<Name>.*)")
            {   
                $Name = $Matches.Name
                $Size = $Matches.Size
                $Date = $Matches.Date

                $row = $dt.NewRow()
                $row.Directory = $CurrentDir
                $row.FileName = $Name
                $row.FileSize = $Size
                $row.FileDate = $Date
                $row.DateAdded = $DateAdded
                $dt.rows.add($row)
            }
        }
        write-log -Message "$Type | Finished DataTable Processing" -Path $LogPath   

        $RowCount = $dt.Rows.Count.ToString()
        #write-log -Message "RowCount $RowCount"  -Path $LogPath
        if($dt.Rows.Count -gt "0")
        {
            write-log -Message "$Type | Starting Bulk Load to $SQLInst on $Centraldb in $CITbl" -Path $LogPath 
            Write-DataTable -ServerInstance $SQLInst -Database $Centraldb -TableName $CITbl -Data $dt
            write-log -Message "$Type | Finished Bulk Load to $SQLInst on $Centraldb in $CITbl" -Path $LogPath            
        }
        else
        {
            write-log -Message "$Type | On $SQLInst, there are no rows in the table or table does not exist."  -Path $LogPath
        }
    }    
catch 
	{ 
        $ex = $_.Exception 
	    write-log -Message "$Type | $ex.Message on $server While executing maintenance solution"  -Path $LogPath
	} 
finally
    {
   		$ErrorActionPreference = "Continue"; #Reset the error action pref to default
	}
}
######################################################################################################################################
 
#Fucntion to PublishBackupFileData
function PublishBackupFileData
{
    Param
    (
        [string] $Type
    )
	# Create an ADO.Net connection to the instance
    $cn = new-object system.data.SqlClient.SqlConnection("Data Source=$SQLInst;Integrated Security=SSPI;Initial Catalog=$Centraldb");
    $s = new-object (‘Microsoft.SqlServer.Management.Smo.Server’) $cn
	$RunDt = Get-Date -format G
################################################## Load Command Log #################################################################
try 
    { 
        
        $ErrorActionPreference = "Stop";
        $CITbl = “[Inst].[BackupStage]”
        $DateAdded = $(get-date)
        
        

        $RowCount = $dt.Rows.Count.ToString()
        #write-log -Message "RowCount $RowCount"  -Path $LogPath
        if($dt.Rows.Count -gt "0")
        {
            write-log -Message "$Type | Starting Bulk Load to $SQLInst on $Centraldb in $CITbl" -Path $LogPath 
            Write-DataTable -ServerInstance $SQLInst -Database $Centraldb -TableName $CITbl -Data $dt
            write-log -Message "$Type | Finished Bulk Load to $SQLInst on $Centraldb in $CITbl" -Path $LogPath            
        }
        else
        {
            write-log -Message "$Type | On $SQLInst, there are no rows in the table or table does not exist."  -Path $LogPath
        }
    }    
catch 
	{ 
        $ex = $_.Exception 
	    write-log -Message "$Type | $ex.Message on $server While executing maintenance solution"  -Path $LogPath
	} 
finally
    {
   		$ErrorActionPreference = "Continue"; #Reset the error action pref to default
	}
}
######################################################################################################################################
 

 $origErrorPath = $LogPath
 $LogPath = $LogPath  + "CollectBackupFileData.log"
 if($Type.Length -ne 0)
 {  
    $server = $env:computername
	$LogPath = $origErrorPath  +  $server + "_CollectBackupFileData.log"
	$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
		
	write-log -Message "$Type | Script Started at $(get-date)" -Path $LogPath

    # Calling funtion and pass type and path
	$GUID = [guid]::NewGuid().Tostring()
	$Files = CollectBackupFileData $Type $BackupPath
    if ($Files -ne $null)
    {
    	StageBackupFileData $Type $Files $GUID
    }
    #PublishBackupFileData $Type $Files $GUID
 }

write-log -Message "$Type | Script Ended at $(get-date)"  -Path $LogPath
write-log -Message "$Type | Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"  -Path $LogPath
write-log -Message "----------------------------------" -Path $LogPath	