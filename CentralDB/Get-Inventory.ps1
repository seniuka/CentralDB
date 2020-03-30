#####################################################################################################################################
# Get-Inventory (https://seniuka.github.io/CentralDB/)
# This script will collect SQL server inventory details.
# Operating System Info
# Page File Usage Info 
# Server Info
# Disk and MountPoint Info
# SQL Services Info
# SQL Server DB Engine Info
# Reporting Services Info
# Analysis Services Info 
#
#                                                            This script has been branched from https://github.com/CrazyDBA/CentralDB
#####################################################################################################################################

#####################################################################################################################################
#Parameter List
param(
	[string]$cmsInstanceName="",
	[string]$cmsDatabaseName="",
	[string]$cmsLogin="",
	[string]$cmsPassword="",
    [string]$runLocally="true", #runs locally only transmits data to CMS if accessible
	[string]$logPath="",
	[string]$logFileName="Get-Inventory_" + $env:computername + ".log"
)
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ManagedDTS') | out-null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices") | out-null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.RMO") | Out-Null
#####################################################################################################################################

#####################################################################################################################################
#DisplayProgress
function DisplayProgress ($TotalSteps, $CurrentStep, $Activity, $StepText, $Task)
{
	# Progress Bar Default Variables
	$Id                   = 1

	# Progress Bar Pause Variables
	$ProgressBarWait      = 1500 # Set the pause length for operations in the main script
	$ProgressBarWaitGroup = 250 # Set the pause length for operations while processing groups
	$ProgressBarWaitUser  = 50 # Set the pause length for operations while processing users
	$AddPauses            = $true # Set to $true to add pauses that help highlight progress bar functionality

	$TotalSteps           = $TotalSteps # Manually count the total number of steps in the script
	$Step                 = $CurrentStep # Set this at the beginning of each step
	$StepText             = $StepText # Set this at the beginning of each step
	$StatusText           = '"Step $($Step.ToString().PadLeft($TotalSteps.Count.ToString().Length)) of $TotalSteps | $StepText"' # Single quotes need to be on the outside
	$StatusBlock          = [ScriptBlock]::Create($StatusText) # This script block allows the string above to use the current values of embedded values each time it's run	
	Write-Progress -Id $Id -Activity $Activity -Status (& $StatusBlock) -CurrentOperation $Task -PercentComplete ($Step / $TotalSteps * 100)
	$logText			  = "Step $($Step.ToString().PadLeft($TotalSteps.Count.ToString().Length)) of $TotalSteps | $StepText | $Task"
	Write-Log -Message $logText -Level Info -Path $logPath
	if ($AddPauses) { Start-Sleep -Milliseconds $ProgressBarWait }	
}
#DisplayProgress
#####################################################################################################################################

#####################################################################################################################################
#GetVersion
function GetVersion ($Version)
{ 
    $SQLVersion = 'Unknown'
    if($Version -Like '8.*')  { $SQLVersion = 'SQL Server 2000' } 
    if($Version -Like '9.*')  { $SQLVersion = 'SQL Server 2005'} 
    if($Version -Like '10.5*'){ $SQLVersion = 'SQL Server 2008 R2' } 
    if($Version -Like '10.0*'){ $SQLVersion = 'SQL Server 2008' } 
    if($Version -Like '11.0*'){ $SQLVersion = 'SQL Server 2012'} 
    if($Version -Like '12.0*'){ $SQLVersion = 'SQL Server 2014'} 
    if($Version -Like '13.0*'){ $SQLVersion = 'SQL Server 2016'} 
	if($Version -Like '14.0*'){ $SQLVersion = 'SQL Server 2017'}
	if($Version -Like '15.0*'){ $SQLVersion = 'SQL Server 2019'}
    return $SQLVersion
} 
#GetVersion
#####################################################################################################################################

#####################################################################################################################################
#GetRSNameSpace
function GetRSNameSpace ($RSVersion, $getInstanceName)
{ 
	if($RSVersion -Like '9.*'){ $rs_namespace = 'root\Microsoft\SqlServer\ReportServer\v9' } 
	elseif ($RSVersion -Like '10.*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v10" }
	elseif ($RSVersion -Like '11.0*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v11" }
	elseif ($RSVersion -Like '12.0*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v12" }
	elseif ($RSVersion -Like '13.0*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v13" }
	elseif ($RSVersion -Like '14.0*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v14" }
	elseif ($RSVersion -Like '15.0*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v15" }	
    return $rs_namespace
} #GetRSNameSpace
#####################################################################################################################################

#####################################################################################################################################
#GetRSNameSpaceAdmin
function GetRSNameSpaceAdmin ($RSVersion, $getInstanceName)
{ 
	if($RSVersion -Like '9.*'){ $rs_namespace = 'root\Microsoft\SqlServer\ReportServer\v9\Admin' } 
	elseif ($RSVersion -Like '10.*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v10\Admin" }
	elseif ($RSVersion -Like '11.0*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v11\Admin" }
	elseif ($RSVersion -Like '12.0*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v12\Admin" }
	elseif ($RSVersion -Like '13.0*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v13\Admin" }
	elseif ($RSVersion -Like '14.0*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v14\Admin" }
	elseif ($RSVersion -Like '15.0*') { $rs_namespace = "root\Microsoft\SqlServer\ReportServer\RS_" + $getInstanceName + "\v15\Admin" }	
    return $rs_namespace
} #GetRSNameSpaceAdmin
#####################################################################################################################################

#####################################################################################################################################
#GetOSVersion
function GetOSVersion ($OSVersion)
{ 
	$OSName = 'Unknown'
	if($OSVersion -Like '*XP*'){$OSName = 'Windows XP'} 
	elseif($OSVersion -Like '*Windows 8.1*'){$OSName = 'Windows 8.1'} 
	elseif($OSVersion -Like '*Windows 8*'){$OSName = 'Windows 8'} 
	elseif($OSVersion -Like '*Windows 10*'){$OSName = 'Windows 10'} 
	elseif($OSVersion -Like '*Windows 7*'){$OSName = 'Windows 7'} 
	elseif($OSVersion -Like '*Vista*'){$OSName = 'Windows Vista'} 
	elseif($OSVersion -Like '*2000*'){$OSName = 'Windows Server 2000'} 
	elseif($OSVersion -Like '*2003*'){$OSName = 'Windows Server 2003'} 
	elseif($OSVersion -Like '*2008 R2*'){$OSName = 'Windows Server 2008 R2'}
	elseif($OSVersion  -Like '*2008*'){$OSName = 'Windows Server 2008'} 
	elseif($OSVersion -Like '*2012 R2*'){$OSName = 'Windows Server 2012 R2'} 
	elseif($OSVersion -Like '*2012*'){$OSName = 'Windows Server 2012'} 
	elseif($OSVersion -Like '*2016*'){$OSName = 'Windows Server 2016'} 
	elseif($OSVersion -Like '*2019*'){$OSName = 'Windows Server 2019'} 	
	return $OSName
} 
#GetOSVersion
#####################################################################################################################################

#####################################################################################################################################
#GetEdition
function GetEdition ($Edition)
{ 
    $SQLEdition = 'Unknown'
	if($Edition -Like'*Developer*'){ $SQLEdition = 'Developer Edition'} 
	elseif($Edition -Like'*Enterprise*'){ $SQLEdition = 'Enterprise Edition'} 
	elseif($Edition -Like'*Standard*'){ $SQLEdition = 'Standard Edition'} 
	elseif($Edition -Like'*Express*'){ $SQLEdition = 'Express Edition'} 
	elseif($Edition -Like'*Web*'){ $SQLEdition = 'Web Edition'} 
	elseif($Edition -Like'*Business*'){ $SQLEdition = 'BI Edition'} 
	elseif($Edition -Like'*Workgroup*'){ $SQLEdition = 'Workgroup Edition'} 
	elseif($Edition -Like'*Evaluation*'){ $SQLEdition = 'Evaluation Edition'} 
	elseif($Edition -Like'*Desktop*'){ $SQLEdition = 'Desktop Edition'} 
    return $SQLEdition
} 
#GetEdition
#####################################################################################################################################

#####################################################################################################################################
#GetIsUpToDate -- modify to use SQLVersion table from brent ozar?
function GetIsUpToDate ($Version)
{ 
    $IsUpToDate = 'False'
    if ($Version -Like '10.0.6*')  {$IsUpToDate = 'True'}
    if ($Version -Like '10.50.6*') {$IsUpToDate = 'True'}
    if ($Version -Like '11.0.7*')  {$IsUpToDate = 'True'}
    if ($Version -Like '12.0.6*')  {$IsUpToDate = 'True'}
    if ($Version -Like '13.0.5*')  {$IsUpToDate = 'True'}
	if ($Version -Like '14.0.3*')  {$IsUpToDate = 'True'}
	if ($Version -Like '15.0.4*')  {$IsUpToDate = 'True'}	
    return $IsUpToDate;
} 
#GetIsUpToDate
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
} #
Get-Type 
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
    [Parameter(Position=0, Mandatory=$true)] [string]$InstanceName, 
    [Parameter(Position=1, Mandatory=$true)] [string]$DatabaseName, 
    [Parameter(Position=2, Mandatory=$true)] [string]$TableName, 
    [Parameter(Position=3, Mandatory=$true)] $Data, 
    [Parameter(Position=4, Mandatory=$false)] [string]$Username, 
    [Parameter(Position=5, Mandatory=$false)] [string]$Password, 
    [Parameter(Position=6, Mandatory=$false)] [Int32]$BatchSize=50000, 
    [Parameter(Position=7, Mandatory=$false)] [Int32]$QueryTimeout=0, 
    [Parameter(Position=8, Mandatory=$false)] [Int32]$ConnectionTimeout=300
    ) 
	
	#write-output $ServerInstance
	#write-output $Data
     $conn=new-object System.Data.SqlClient.SQLConnection  
    if ($Username) 
    { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $InstanceName,$DatabaseName,$Username,$Password,$ConnectionTimeout } 
    else 
    { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $InstanceName,$DatabaseName,$ConnectionTimeout } 
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
	    $ex = $_.Exception 
	    write-log -Message "$ex.Message on $env:computername" -Level Error -Path $logPath
    }
    catch 
    { 
        $ex = $_.Exception 
        write-log -Message "$ex.Message on $env:computername"  -Level Error -Path $logPath
    } 
} 
#Write-DataTable
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
} 
#Out-DataTable
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

    } 
#Write-Log
#####################################################################################################################################

#####################################################################################################################################
#getTcpPort
#http://www.databasejournal.com/features/mssql/article.php/3764516/Discover-SQL-Server-TCP-Port.htm
function getTcpPort([String] $pHostName, [String] $pInstanceName)
{
	$strTcpPort=""
	$reg = [WMIClass]"\\$pHostName\root\default:stdRegProv"
	$HKEY_LOCAL_MACHINE = 2147483650
	#SQL Server 2000 or SQL Server 2005/2008 resides on the same host as SQL Server 2000
	# Default instance
	if ($pInstanceName -eq 'MSSQLSERVER') {
		$strKeyPath = "SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp"
		$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
		if ($strTcpPort) {
			return $strTcpPort
		}		
	}
	# Named instance
	else {
		$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\$pInstanceName\MSSQLServer\SuperSocketNetLib\Tcp"
		$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
		if ($strTcpPort) {
			return $strTcpPort
		}
	}
	#SQL Server 2005
	for ($i=1; $i -le 50; $i++) {
		$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL.$i"
		$strInstanceName=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"").svalue			
		if ($strInstanceName -eq $pInstanceName) {
			$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL.$i\MSSQLServer\SuperSocketNetLib\tcp\IPAll"
			$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
			return $strTcpPort	
		}
	}
	#SQL Server 2008
	$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL10.$pInstanceName\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
	$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
	if ($strTcpPort) {
		return $strTcpPort
	}
	#SQL Server 2008 R2
	$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL10_50.$pInstanceName\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
	$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
	if ($strTcpPort) {
		return $strTcpPort
	}
	#SQL Server 2012
	$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL11.$pInstanceName\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
	$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
	if ($strTcpPort) {
		return $strTcpPort
	}	
    #SQL Server 2014
	$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL12.$pInstanceName\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
	$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
	if ($strTcpPort) {
		return $strTcpPort
	}	
    #SQL Server 2016
	$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.$pInstanceName\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
	$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
	if ($strTcpPort) {
		return $strTcpPort
	}	
    #SQL Server 2017
	$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.$pInstanceName\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
	$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
	if ($strTcpPort) {
		return $strTcpPort
	}	
    #SQL Server 2019
	$strKeyPath = "SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.$pInstanceName\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
	$strTcpPort=$reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TcpPort").svalue
	if ($strTcpPort) {
		return $strTcpPort
	}		
	return ""
} 
#getTcpPort
#####################################################################################################################################

#####################################################################################################################################
#GetServerListInfo
function GetServerListInfo($getServerName, $getInstanceName, $getDatabaseName) 
{
	$CurrentStep = 5;$StepText = "Begin Collecting CentralDB data"; $Task = "Ooo, ooo, I found it.";
	DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
	
	$RunDt = Get-Date -format G
	### Connect To Instance #####################################################################################################
	$cn = new-object system.data.SqlClient.SqlConnection("Data Source=$getInstanceName;Integrated Security=SSPI;Initial Catalog=$getDatabaseName");
	$s = new-object ("Microsoft.SqlServer.Management.Smo.Server") $cn		
	#############################################################################################################################

	### Operating System Info ###################################################################################################
	try 
	{
		$CurrentStep = 6;$StepText = "Collecting Operating System Info"; $Task = "Tasty OS Flavor.";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
		
		$ErrorActionPreference = "Stop"; #Make all errors terminating
		$CITbl="[Svr].[OSInfo]"

		$a=Get-WmiObject -ComputerName $getServerName -Class Win32_OperatingSystem
		$b = $a.convertToDateTime($a.Lastbootuptime)
		[TimeSpan]$LastBoot = New-TimeSpan $b $(Get-Date)
		$OSUpTime = ("{0} Days, {1} Hrs" -f $LastBoot.Days,$lastboot.Hours) 
		$OSName = GetOSVersion ($a.Caption)
		$dt=Get-WMIObject Win32_OperatingSystem -computername $getServerName | select @{n="ServerName";e={$getServerName}}, @{n="OSName";e={$OSName}},
			OSArchitecture, Version, @{n="OSServicePack";e={$_.CSDVersion}}, @{n="OSInstallDate";e={$_.ConvertToDateTime($_.InstallDate)}}, 
			@{n="OSLastRestart";e={$_.ConvertToDateTime($_.LastBootUpTime)}}, @{n="OSUpTime";e={$OSUpTime}},
			@{Name="OSTotalVisibleMemorySizeInGB";Expression={[math]::round(($_.TotalVisibleMemorySize / 1024 / 1024), 2)}}, 
			@{Name="OSFreePhysicalMemoryInGB";Expression={[math]::round(($_.FreePhysicalMemory / 1024 / 1024), 2)}}, 
			@{Name="OSTotalVirtualMemorySizeInGB";Expression={[math]::round(($_.TotalVirtualMemorySize / 1024 / 1024), 2)}},
			@{Name="OSFreeVirtualMemoryInGB";Expression={[math]::round(($_.FreeVirtualMemory / 1024 / 1024), 2)}}, 
			@{Name="OSFreeSpaceInPagingFilesInGB";Expression={[math]::round(($_.FreeSpaceInPagingFiles / 1024 / 1024), 2)}}, @{n="DateAdded";e={$RunDt}} | out-datatable
		Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
		#Write-Log -Message "Collecting Operating System Info" -Level Info -Path $logPath
		#Write-Log -Message "Collecting Operating System Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath
		
		$CurrentStep = 6;$StepText = "Collecting Operating System Info"; $Task = "Oh wow I finished a box of OS.";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
	}
	catch 
	{ 
		$ex = $_.Exception 
		write-log -Message "$ex.Message on $getServerName while collecting Operating System Info" -Level Error -NoConsoleOut -Path $logPath 
	}
	finally
	{
		$ErrorActionPreference = "Stop"; #Reset the error action pref to default
	}
	#############################################################################################################################

	### Page File Usage Info  ###################################################################################################
	try 
	{
		$CurrentStep = 7;$StepText = "Collecting Page File Usage Info"; $Task = "The tenderness of the page file is making me drool.";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
			
		$ErrorActionPreference = "Stop"; #Make all errors terminating
		$CITbl="[Svr].[PgFileUsage]"
		$dt= Get-WMIObject -query "select * from Win32_PageFileUsage" -computername $getServerName | select @{n="ServerName";e={$getServerName}}, Name, 
				@{n="PgAllocBaseSzInGB";e={[math]::round(($_.AllocatedBaseSize / 1024), 2)}},
				@{n="PgCurrUsageInGB";e={[math]::round(($_.CurrentUsage / 1024), 2)}},
				@{n="PgPeakUsageInGB";e={[math]::round(($_.PeakUsage / 1024), 2)}}, @{n="DateAdded";e={$RunDt}}  | out-datatable
		Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
		#Write-Log -Message "Collecting Page File Usage Info" -Level Info -Path $logPath
		#Write-Log -Message "Collecting Page File Usage Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath
		
		$CurrentStep = 7;$StepText = "Collecting Page File Usage Info"; $Task = "Slow cooked to perfection.";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
				
	}
	catch 
	{ 
		$ex = $_.Exception 
		write-log -Message "$ex.Message on $getServerName while collecting Page File Usage Info" -Level Error -NoConsoleOut -Path $logPath
	}
	finally
	{
		$ErrorActionPreference = "Stop"; #Reset the error action pref to default
	}
	#############################################################################################################################

	### Server Info #############################################################################################################
	try 
	{
		$CurrentStep = 8;$StepText = "Collecting Server Info"; $Task = "Mmmm delicious meaty flavor.";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
		
		$ErrorActionPreference = "Stop"; #Make all errors terminating
		$CITbl ="[Svr].[ServerInfo]"

		$processors = get-wmiobject -computername $getServerName win32_processor
			if (@($processors)[0].NumberOfCores)
			{
				$cores = @($processors).count * @($processors)[0].NumberOfCores
				$Logical = @($processors).count * @($processors)[0].NumberOfLogicalProcessors
			}
			else
			{
				$cores = @($processors).count
			}
				
		$sockets = @(@($processors) | % {$_.SocketDesignation} |select-object -unique).count;
		$CurrentCPUSpeed = ($Processors | Measure-Object CurrentClockSpeed -max).Maximum
		$MaxCPUSpeed  =  ($Processors | Measure-Object MaxClockSpeed -max).Maximum
		$z = Get-WmiObject -Class Win32_SystemServices -ComputerName $getServerName
		$ip = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $getServerName | Where {$_.IPAddress } | SELECT IPAddress

$domrole = DATA {
ConvertFrom-StringData -StringData @'
0 = Standalone Workstation 
1 = Member Workstation 
2 = Standalone Server 
3 = Member Server 
4 = Backup Domain Controller 
5 = Primary Domain Controller
'@
}
		
		$dt=Get-WMIObject -query "select * from Win32_ComputerSystem" -computername $getServerName | select @{n="ServerName";e={$getServerName}}, @{n="IPAddress";e={$ip}}, Model, Manufacturer, Description, 
			SystemType, @{n="ActiveNodeName";e={$_.DNSHostName.ToUpper()}}, Domain, @{n="DomainRole"; e={$domrole["$($_.DomainRole)"]}}, PartOfDomain, @{n="NumberofProcessors";e={$sockets}},
			@{n="NumberofLogicalProcessors";e={$Logical}}, @{n="NumberofCores";e={$cores}}, @{n="IsHyperThreaded";e={if($cores -le $Logical) {'True'} Else {'False'}}}, 
			@{n="CurrentCPUSpeed";e={$CurrentCPUSpeed}}, @{n="MaxCPUSpeed";e={$MaxCPUSpeed}}, @{n="IsPowerSavingModeON";e={if($CurrentCPUSpeed -ne $MaxCPUSpeed) {'True'} Else {'False'}}},
			@{Expression={$_.TotalPhysicalMemory / 1GB};Label="TotalPhysicalMemoryInGB"}, AutomaticManagedPagefile, @{n="IsVM";e={if($_.Model -Like '*Virtual*') {'True'} else {'False'}}},
			@{n="IsClu";e={if ($Z | select PartComponent | where {$_ -like "*ClusSvc*"}) {'True'} else {'False'}}}, @{n="DateAdded";e={$RunDt}} | out-datatable
			Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
		#Write-Log -Message "Collecting Server Info" -Level Info -Path $logPath
		#Write-Log -Message "Collecting Server Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath
		
		$CurrentStep = 8;$StepText = "Collecting Server Info"; $Task = "Perfectly completed.";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task		
	}
	catch 
	{ 
		$ex = $_.Exception 
		write-log -Message "$ex.Message on $getServerName while collecting Server Info" -Level Error -NoConsoleOut -Path $logPath
	}
	finally
	{
		$ErrorActionPreference = "Stop"; #Reset the error action pref to default
	}
	#############################################################################################################################

	### Disk and MountPoint Info  ###############################################################################################		
	try 
	{
		$CurrentStep = 9;$StepText = "Collecting Disk and Mountpoint Info"; $Task = "Poor more gravy on it!";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
		
		#Convert Size in GB: http://learn-powershell.net/2010/08/29/convert-bytes-to-highest-available-unit/
		$ErrorActionPreference = "Stop"; #Make all errors terminating
		$CITbl="[Svr].[DiskInfo]"
		$dt=Get-WMIObject -query "select * from Win32_Volume where DriveType=3 and not name like '%?%'" -computername $getServerName |select @{n="ServerName";e={$getServerName}},
			Name, Label, FileSystem, @{e={($_.BlockSize /1KB) -as [int]};n="DskClusterSizeInKB"},  @{e={"{0:N2}" -f ($_.Capacity / 1GB)};n="DskTotalSizeInGB"},  
			@{e={"{0:N2}" -f ($_.Freespace /1GB)};n="DskFreeSpaceInGB"}, @{e={"{0:N2}" -f (($_.Capacity-$_.Freespace) /1GB)};n="DskUsedSpaceInGB"}, 
			@{e={"{0:P2}" -f ($_.Freespace/$_.Capacity)};n="DskPctFreeSpace"}, @{n="DateAdded";e={$RunDt}} | out-datatable
		Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
		#Write-Log -Message "Collecting Disk and Mountpoint Info" -Level Info -Path $logPath
		#Write-Log -Message "Collecting Disk and Mountpoint Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath
		
		$CurrentStep = 9;$StepText = "Collecting Disk and Mountpoint Info"; $Task = "It looks like a gravy lake.";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
	}
	catch 
	{ 
		$ex = $_.Exception 
		write-log -Message "$ex.Message on $getServerName while collecting Disk and Mountpoint Info" -Level Error -NoConsoleOut -Path $logPath
	}
	finally
	{
		$ErrorActionPreference = "Stop"; #Reset the error action pref to default
	}
	#############################################################################################################################

	### SQL Services Info  ######################################################################################################
	try 
	{		
		$CurrentStep = 9;$StepText = "Collecting SQL Services Info"; $Task = "Mmmm, a whole bowl of stuffing.";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
		
		$ErrorActionPreference = "Stop"; #Make all errors terminating
		#http://msdn.microsoft.com/en-us/library/windows/desktop/aa394418%28v=vs.85%29.aspx
		#http://www.sqlmusings.com/2009/05/23/how-to-list-sql-server-services-using-powershell/
		$CITbl="[Svr].[SQLServices]"
		$dt= Get-WMIObject -query "select * from win32_service where name like 'SQLSERVERAGENT' or name like 'MSSQL%' or name like 'MsDts%' or name like 'ReportServer%' or name like 'SQLBrowser'" `
			-computername $getServerName  | select @{n="ServerName";e={$getServerName}}, Name, DisplayName, Started, StartMode, State, PathName, StartName, ProcessId, @{n="DateAdded";e={$RunDt}}  | out-datatable
		Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
		#Write-Log -Message "Collecting SQL Services Info" -Level Info -Path $logPath
		#Write-Log -Message "Collecting SQL Services Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath	
		
		$CurrentStep = 9;$StepText = "Collecting SQL Services Info"; $Task = "There was a whole bowl of stuffing.";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task		
	}
	catch 
	{ 
		$ex = $_.Exception 
		write-log -Message "$ex.Message on $getServerName while collecting SQL Services Info" -Level Error -NoConsoleOut -Path $logPath
	}
	finally
	{
		$ErrorActionPreference = "Stop"; #Reset the error action pref to default
	}
	#############################################################################################################################

	### SQL Server DB Engine Info ###############################################################################################
	#http://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.database.isaccessible.aspx
	$result = new-object Microsoft.SqlServer.Management.Common.ServerConnection($getInstanceName)
	$responds = $false
	if ($result.ProcessID -ne $null)
	{
		$responds = $true
	}  
	else
	{
		$CurrentStep = 23;$StepText = "Collecting Instance Info"; $Task = "Oh dear, someone dropped the turkey.";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
	}
	
	If ($responds) 
	{
			### Instance Info ###########################################################################################################
			#http://msdn.microsoft.com/en-us/library/ms220267.aspx
			#http://www.youdidwhatwithtsql.com/auditing-your-sql-server-with-powershell/133/
			#http://www.mikefal.net/2013/04/17/server-inventories/
			#Chris Stewart and Jeremiah Nellis
			try 
			{
                # write-output "getInstanceName"
                #write-output $getInstanceName

				$CurrentStep = 10;$StepText = "Collecting Instance Info"; $Task = "Oh that turkey looks delicious.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
		
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[Inst].[InstanceInfo]"

				$Task           = "1.Collect Instance Info [Connection]" 
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
                $s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $getInstanceName				
				
                $Task           = "2.Collecting Instance Info [Instance Name]" 
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
				$name = $getInstanceName.Split("\")
				if ($name.count -gt 1){ $CurrentInstanceName = $name[1]}
								
                $Task           = "3.Collecting Instance Info [Port]" 
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task				
				$port = getTcpPort $getServerName $getInstanceName
				
				$Task           = "4.Collecting Instance Info [IP]"
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task		
				$ip = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration | where {$_.DefaultIPGateway -ne $null}).IPAddress -join ','
                #$ip = (Get-NetIPConfiguration -ComputerName $getServerName).IPv4Address.IPAddress -join ','

                write-host "here is the failure"				

				$Task           = "5.Collecting Instance Info [Version]"
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task					
				$SQLVersion = GetVersion($s.Version)
						
				$Task           = "6.Collecting Instance Info [Patched]"
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task					
				$IsSPUpToDate = GetIsUpToDate($s.Version)
				
				$Task           = "7.Collecting Instance Info [Edition]"
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task					
				$SQLEdition = GetEdition($s.Edition)
				
				$Task           = "8.Collecting Instance Info [Detail]" 
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task					

				$dt= $s | Select @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}},  @{n="IPAddress";e={$ip}}, @{n="Port";e={$port}}, @{n="SQLVersion";e={$SQLVersion}},
					ProductLevel,@{n="IsSPUpToDate";e={$IsSPUpToDate}}, @{n="SQLEdition";e={$SQLEdition}}, Version, Collation, RootDirectory, 
					@{n="DefaultFile";e={$s.DefaultFile}}, 
					@{n="DefaultLog";e={$s.DefaultLog}},
					ErrorLogPath, IsCaseSensitive, IsClustered, IsFullTextInstalled, IsSingleUser, IsHadrEnabled, TcpEnabled, NamedPipesEnabled, ClusterName, ClusterQuorumState, 
					ClusterQuorumType, HadrManagerStatus,@{n="MaxMemory";e={$_.Configuration.MaxServerMemory.ConfigValue}}, @{n="MinMemory";e={$_.Configuration.MinServerMemory.ConfigValue}}, 
					@{n="MaxDOP";e={$_.Configuration.MaxDegreeOfParallelism.ConfigValue}}, @{n="NoOfUsrDBs";e={($_.Databases.Count)-4}}, @{n="NoOfJobs";e={$_.JobServer.Jobs.Count}}, 
					@{n="NoOfLnkSvrs";e={$_.LinkedServers.Count}}, @{n="NoOfLogins";e={$_.Logins.Count}}, @{n="NoOfRoles";e={$_.Roles.Count}}, @{n="NoOfTriggers";e={$_.Triggers.Count}},
					@{n="NoOfAvailGroups";e={$_.AvailabilityGroups.Count}}, @{n="AvailGrps"; e={if($_.IsHadrEnabled){($_| select -expand AvailabilityGroups) -join ', '}}},  
					IsXTPSupported, @{n="FilFactor";e={$_.Configuration.FillFactor.ConfigValue}}, ProcessorUsage, @{n="ActiveNode"; e={if($_.IsClustered){$_.ComputerNamePhysicalNetBIOS}}},
					@{n="ClusterNodeNames"; e={if($_.IsClustered){($_.Databases["master"].ExecuteWithResults("select NodeName from sys.dm_os_cluster_nodes").Tables[0] | select -expand NodeName) -Join ', '}}},
					@{n="DateAdded";e={$RunDt}} | out-datatable
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Instance Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Instance Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath			

				$CurrentStep = 10;$StepText = "Collecting Instance Info"; $Task = "<Hic> That turkey was delicious.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task

			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName while collecting Instance Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

			### Job Info ################################################################################################################
			#http://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.job%28v=sql.110%29.aspx
			try 
			{
				$CurrentStep = 11;$StepText = "Collecting SQL Agent Job Info"; $Task = "Is that yams?";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
				
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[Inst].[Jobs]"
				$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $getInstanceName
				$dbs=$s.jobserver.jobs
				$dt= $dbs | select @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}}, name, Description, OwnerLoginName, IsEnabled, category, DateCreated, DateLastModified,  LastRunDate, NextRunDate, LastRunOutcome, CurrentRunRetryAttempt, OperatorToEmail, OperatorToPage, HasSchedule, @{n="DateAdded";e={$RunDt}} | out-datatable
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting SQL Agent Job Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting SQL Agent Job Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath					

				$CurrentStep = 11;$StepText = "Collecting SQL Agent Job"; $Task = "Tasty Yams.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task				
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Job Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

			### Job Failure Info ########################################################################################################
			#http://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.jobhistoryfilter_properties%28v=sql.110%29.aspx
			try 
			{
				$CurrentStep = 12;$StepText = "Collecting Failed SQL Agent Job Info"; $Task = "Burnt potatoes, hrm";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[Inst].[JobsFailed]"
				$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $getInstanceName
				$jobserver = $s.JobServer
				$jobHistoryFilter = New-Object Microsoft.SqlServer.Management.Smo.Agent.JobHistoryFilter
				$jobHistoryFilter.OutComeTypes = 'Failed'
				$dt= $jobserver.EnumJobHistory($jobHistoryFilter) | Where {$_.RunDate -gt ((Get-Date).AddDays(-1)) -and $_.SqlMessageID -ne 0} | select @{n="ServerName";e={$getServerName}},
				@{n="InstanceName";e={$getInstanceName}}, JobName,StepID,StepName,Message, RunDate, @{n="DateAdded";e={$RunDt}} | out-datatable
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Failed SQL Agent Job Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Failed SQL Agent Job Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath
				
				$CurrentStep = 12;$StepText = "Collecting Failed SQL Agent Job Info"; $Task = "Um, I will pass on that";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task					
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Failed Jobs  Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################
	
			###  Login Info #############################################################################################################
			#http://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.login.aspx
			try 
			{				
				$CurrentStep = 13;$StepText = "Collecting Login Info"; $Task = "Who was invited to this party?";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[Inst].[Logins]"
				$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $getInstanceName
				$dbs=$s.Logins
				$dt= $dbs | SELECT @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}}, Name, LoginType, CreateDate, DateLastModified, IsDisabled, IsLocked, @{n="DateAdded";e={$RunDt}} |out-datatable
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Login Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Login Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath	

				$tempTableName = "tempdb.dbo.[tmpGroupCollection]" #(new-guid).tostring()
				$query= "SET NOCOUNT ON; 				
				DECLARE @ErrorRecap TABLE
				  (
					 ID           INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
					 AccountName  NVARCHAR(256),
					 ErrorMessage NVARCHAR(256)
				  ) 
				IF OBJECT_ID('" + $tempTableName + "') IS NOT NULL
				  EXEC('DROP TABLE " + $tempTableName + "')

				EXEC ('CREATE TABLE " + $tempTableName + " ( 
				[LoginName]			Sysname			NULL ,
				[LoginType]         VARCHAR(8)		NULL ,
				[LoginPrivilege]    VARCHAR(9)		NULL ,
				[MappedLoginName]	Sysname			NULL ,
				[PermissionPath]	Sysname	        NULL ,
				[GroupName]			Sysname	        NULL)')

				 DECLARE @groupname Sysname
				 DECLARE c1 cursor LOCAL FORWARD_ONLY STATIC READ_ONLY for
				   SELECT name FROM master.sys.server_principals WHERE type_desc =  'WINDOWS_GROUP' 
				  OPEN c1
				  FETCH NEXT FROM c1 INTO @groupname
				  WHILE @@FETCH_STATUS <> -1
					BEGIN
					  BEGIN TRY
						EXEC('
						INSERT INTO " + $tempTableName + " ([LoginName],[LoginType],[LoginPrivilege],[MappedLoginName],[PermissionPath])
						  EXEC master..xp_logininfo @acctname = '''+ @groupname + ''',@option = ''members''    
						  UPDATE " + $tempTableName + " SET [GroupName] = '''+ @groupname + ''' WHERE [GroupName] IS NULL')
						  SET @groupname = NULL 
					  END TRY
					  BEGIN CATCH

						DECLARE @ErrorSeverity INT, 
								@ErrorNumber INT, 
								@ErrorMessage NVARCHAR(4000), 
								@ErrorState INT
						SET @ErrorSeverity = ERROR_SEVERITY()
						SET @ErrorNumber = ERROR_NUMBER()
						SET @ErrorMessage = ERROR_MESSAGE()
						SET @ErrorState = ERROR_STATE()

						INSERT INTO @ErrorRecap(AccountName,ErrorMessage) SELECT @groupname,@ErrorMessage						
						PRINT 'Msg ' + convert(varchar,@ErrorNumber) + ' Level ' + convert(varchar,@ErrorSeverity) + ' State ' + Convert(varchar,@ErrorState)
						PRINT @ErrorMessage
					END CATCH
					FETCH NEXT FROM c1 INTO @groupname
					END
				  CLOSE c1
				  DEALLOCATE c1
				--EXEC('SELECT * FROM dbo.[##tmp_' + @guid + ']')
				--IF (SELECT COUNT(*) FROM @ErrorRecap) > 1 BEGIN SELECT * FROM @ErrorRecap END"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
								
				$CITbl = "[Inst].[LoginGroupMembers]"
				$query = "SET NOCOUNT ON; SELECT ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, [LoginName],[LoginType],[LoginPrivilege],[MappedLoginName],[PermissionPath], [GroupName], ('$RunDt') as DateAdded FROM " + $tempTableName + "; DROP TABLE " + $tempTableName + ""
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
							
				$CurrentStep = 13;$StepText = "Collecting Login Info"; $Task = "That weird uncle too?";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task				
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Login Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

			### Instance Roles ##########################################################################################################
			try 
			{
				$CurrentStep = 14;$StepText = "Collecting Instance Roles Info"; $Task = "This was a pot luck?";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
								
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[Inst].[InstanceRoles]"
				$query ="select ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, m.name as LoginName, r.name as RoleName, ('$RunDt') as DateAdded from sys.server_principals r join sys.server_role_members rm on r.principal_id = rm.role_principal_id join sys.server_principals m on m.principal_id = rm.member_principal_id"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Instance Roles Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Instance Roles Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath	
			
				$CurrentStep = 14;$StepText = "Collecting Instance Roles Info"; $Task = "I brought the pop...";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task									
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Instance Roles Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

			###  Linked Servers Info ####################################################################################################
			#http://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.login.aspx
			try 
			{
				$CurrentStep = 15;$StepText = "Collecting Linked Servers Info"; $Task = "karaoke, yay!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
							
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[Inst].[LinkedServers]"
				$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $getInstanceName
				$dbs=$s.linkedservers
				$dt= $dbs | SELECT @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}}, Name, ProviderName, ProductName, ProviderString, DateLastModified, DataAccess, @{n="DateAdded";e={$RunDt}} |out-datatable
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Linked Servers Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Linked Servers Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath		

				$CurrentStep = 15;$StepText = "Collecting Linked Servers Info"; $Task = "I hit some pretty high notes.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task				
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Linked Servers Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

			### Instance Level Triggers #################################################################################################
			try 
			{
				$CurrentStep = 16;$StepText = "Collecting Instance Level Triggers Info"; $Task = "Wait a minute, Whose house is this?!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
								
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[Inst].[InsTriggers]"
				$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $getInstanceName
				$dt = $s.Triggers | select @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}}, Name, createdate, datelastmodified, IsEnabled, @{n="DateAdded";e={$RunDt}} |out-datatable
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Instance Level Triggers Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Instance Level Triggers Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath	
				
				$CurrentStep = 16;$StepText = "Collecting Instance Level Triggers Info"; $Task = "Oh dear, am I at the wrong house... nope!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task					
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Instance Level Triggers Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################
			
			### Replication Publisher Info ##############################################################################################
			#http://msdn.microsoft.com/en-us/library/ms146869.aspx
			#http://stackoverflow.com/questions/27092339/how-to-join-the-output-of-object-array-to-a-string-in-powershell?answertab=votes#tab-top
			try 
			{
				$CurrentStep = 17;$StepText = "Collecting Replication Publisher Info"; $Task = "Why, Why... am, am... I, I... saying everything twice?";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[Inst].[Replication]"
				[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.RMO") | Out-Null
				$repsvr=New-Object "Microsoft.SqlServer.Replication.ReplicationServer" $SQLServerConnection

				if($repsvr.IsPublisher -eq $true)
				{
					$dt = $repsvr | select @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}}, IsPublisher, IsDistributor, DistributorAvailable, @{n="Publisher"; e={$_.SQLServerName}}, 
					@{n="Distributor";e={$_.DistributionServer}}, @{n="Subscriber"; e={($_| select -expand RegisteredSubscribers | %{$_.Name}) -join ', '}}, 
					@{n="ReplPubDBs";e={($_| select -expand ReplicationDatabases | where {$_.HasPublications -eq 1} | %{$_.Name}) -join ', '}},
					@{n="DistDB";e={$_.DistributionDatabase}}, @{n="DateAdded";e={$RunDt}} | out-datatable
				}

				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Replication Publisher Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Replication Publisher Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath	
				
				$CurrentStep = 17;$StepText = "Collecting Replication Publisher Info"; $Task = "Strong eggnog, that is why.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
									
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Replication Publisher Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

			### Database Info ###########################################################################################################
			#http://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.database.aspx
			#http://stackoverflow.com/questions/17807932/expandproperty-not-showing-other-properties-with-select-object
			try 
			{
				$CurrentStep = 18;$StepText = "Collecting Database Info"; $Task = "Let us look over this huge feast";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[DB].[DatabaseInfo]"
				$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $getInstanceName
				$s
				foreach ($db in $s.Databases) 
				{
					if ($db.IsAccessible -eq $True) 
					{						
						$dt= $db | Select @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}}, Name, Status, Owner, CreateDate, Size, 
						@{n="DBSpaceAvailableInMB";e={[math]::round(($_.SpaceAvailable / 1024), 2)}},
						@{e={"{0:N2}" -f ($_.Size-($_.SpaceAvailable / 1024))};n="DBUsedSpaceInMB"}, 
						@{e={"{0:P2}" -f (($_.SpaceAvailable / 1024)/$_.Size)};n="DBPctFreeSpace"},
						@{n="DBDataSpaceUsageInMB";e={[math]::round(($_.DataSpaceUsage / 1024), 2)}},
						@{n="DBIndexSpaceUsageInMB";e={[math]::round(($_.IndexSpaceUsage / 1024), 2)}},
						ActiveConnections, Collation, RecoveryModel, CompatibilityLevel, PrimaryFilePath,
						LastBackupDate, LastDifferentialBackupDate, LastLogBackupDate, AutoShrink, AutoUpdateStatisticsEnabled,IsReadCommittedSnapshotOn,
						IsFullTextEnabled, BrokerEnabled, ReadOnly, EncryptionEnabled, IsDatabaseSnapshot, ChangeTrackingEnabled, 
						IsMirroringEnabled, MirroringPartnerInstance, MirroringStatus, MirroringSafetyLevel, ReplicationOptions,  AvailabilityGroupName,
						@{n="NoOfTbls";e={$_.Tables.Count}}, @{n="NoOfViews";e={$_.Views.Count}}, @{n="NoOfStoredProcs";e={$_.StoredProcedures.Count}}, 
						@{n="NoOfUDFs";e={$_.UserDefinedFunctions.Count}}, @{n="NoOfLogFiles";e={$_.LogFiles.Count}}, @{n="NoOfFileGroups";e={$_.FileGroups.Count}}, 
						@{n="NoOfUsers";e={$_.Users.Count}}, @{n="NoOfDBTriggers";e={$_.Triggers.Count}}, 
						@{n="LastGoodDBCCChecKDB"; e={$($_.ExecuteWithResults("dbcc dbinfo() with tableresults").Tables[0] | where {$_.Field -eq "dbi_dbccLastKnownGood"}|  Select Value).Value}},
						AutoClose,  HasFileInCloud, HasMemoryOptimizedObjects, MemoryAllocatedToMemoryOptimizedObjectsInKB, MemoryUsedByMemoryOptimizedObjectsInKB, 
						@{n="DateAdded";e={$RunDt}}  | out-datatable	
						Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName "[DB].[DatabaseInfo]" -Data $dt
						
						[string]$nm = $db.Name
						$dt = $db.Triggers | select @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}}, @{Name="Database"; Expression = {$nm}}, Name, 
						createdate, datelastmodified, IsEnabled, @{n="DateAdded";e={$RunDt}} |out-datatable
						Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName "[DB].[Triggers]" -Data $dt
						
						#Write-Log -Message "Collecting Database Info $db" -Level Info -Path $logPath
						#Write-Log -Message "Collecting Database Info $db Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath	
					}
					
					$CurrentStep = 18;$StepText = "Collecting Database Info $db Info"; $Task = "So many good looking dishes.";
					DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				}#end foreach
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Database Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################
			
			
			### Database Information #####################################################################################################
			try 
			{
				$CurrentStep = 19;$StepText = "Collecting Detailed Database Information"; $Task = "So many good looking dishes.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
					
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				
				$query= "SET NOCOUNT ON; 
				declare @db nvarchar(255), @sqlstmtdbroles nvarchar(4000), @sqlstmttmpuserperm nvarchar(4000), @sqlstmttmpHekaton nvarchar(4000) 
				create table tmpdbroles(DBName varchar(100) default db_name(), DBUser varchar(200), DBRole varchar(100));
				create table tmpuserperm(DBName SYSNAME, UserName nvarchar(128), ClassDesc nvarchar(60), ObjName sysname, PermName nvarchar(128), PermStat nvarchar(60));					
				IF SERVERPROPERTY ('IsXTPSupported') = 1 BEGIN create table tmpHekaton(DBName SYSNAME, tblName SYSNAME, IsMemOptimized bit, Durability tinyint, DurabilityDesc nvarchar(60), MemAllocForIdxInKB bigint, MemAllocForTblInKB bigint, MemUsdByIdxInKB bigint, MemUsdByTblInKB bigint); END

				DECLARE dbs CURSOR FAST_FORWARD FOR SELECT name FROM sys.databases WHERE database_id > 4 and state = 0
				OPEN dbs FETCH dbs INTO @db
				WHILE @@FETCH_STATUS = 0
				BEGIN
					set @sqlstmtdbroles = N'USE ['+ @db +']; ' + ' insert into tempdb..tmpdbroles select (DB_NAME()) as DBname, m.name as DBuser, r.name as DBRole FROM sys.database_principals r JOIN sys.database_role_members rm on r.principal_id = rm.role_principal_id JOIN sys.database_principals m on m.principal_id = rm.member_principal_id'
					exec sp_executesql @sqlstmtdbroles
										
					set @sqlstmttmpuserperm = N'USE ['+ @db +']; ' + ' insert into tempdb..tmpuserperm select (DB_NAME()) as DBname, USER_NAME(p.grantee_principal_id) AS principal_name, p.class_desc,ObjectName = case p.class when 1 then case when p.minor_id=0 then object_name(p.major_id) else object_name(p.major_id)+''->''+ col_name(p.major_id,p.minor_id) end else ''N/A'' end, p.permission_name, p.state_desc AS permission_state from sys.database_permissions p inner JOIN sys.database_principals dp on p.grantee_principal_id = dp.principal_id where dp.type in (''U'',''S'',''G'')'
					exec sp_executesql @sqlstmttmpuserperm
					
					IF SERVERPROPERTY ('IsXTPSupported') = 1 
					BEGIN 
						set @sqlstmttmpHekaton = N'USE ['+ @db +']; ' + ' insert into tempdb..tmpHekaton select (DB_NAME()) as DBname, t.name as HekatonTblName, t.Is_memory_optimized as IsMemOptimized, t.durability as Durability, t.durability_desc as DurabilityDesc, x.memory_allocated_for_indexes_kb as MemAllocForIdxInKB, x.memory_allocated_for_table_kb as MemAllocForTblInKB, x.memory_used_by_indexes_kb as MemUsdByIdxInKB, x.memory_used_by_table_KB as MemUsdByTblInKB from Sys.tables t inner join sys.dm_db_xtp_table_memory_stats x on t.object_id= x.object_id and is_memory_optimized =1'
						exec sp_executesql @sqlstmttmpHekaton
					END
														
				FETCH dbs INTO @db
				END
				CLOSE dbs
				DEALLOCATE dbs"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
								
				$CurrentStep = 19;$StepText = "Collecting Detailed Database Information"; $Task = "Mmm, Roles!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				$CITbl = "[DB].[DBUserRoles]"
				$query = "SET NOCOUNT ON; SELECT ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, DBname, DBuser,  DBRole, ('$RunDt') as DateAdded FROM tempdb..tmpdbroles; DROP TABLE tempdb..tmpdbroles"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				
				$CurrentStep = 19;$StepText = "Collecting Detailed Database Information"; $Task = "Hey you do not have permission to touch the food!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				$CITbl = "[Tbl].[TblPermissions]"
				$query = "SET NOCOUNT ON; SELECT ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, *, ('$RunDt') as DateAdded FROM tempdb..tmpuserperm ORDER BY dbname; DROP TABLE tempdb..tmpuserperm"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				
				$CurrentStep = 19;$StepText = "Collecting Detailed Database Information"; $Task = "I can remember, I have good a memory!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				$CITbl = "[Tbl].[HekatonTbls]"
				$query = "SET NOCOUNT ON; SELECT ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, *, ('$RunDt') as DateAdded FROM tempdb..tmpHekaton ORDER BY dbname; DROP TABLE tempdb..tmpHekaton"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				
				#Write-Log -Message "Collecting DB user roles Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting DB user roles Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath						
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting DB user roles Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

			
			### Database User Roles #####################################################################################################
		#	try 
		#	{
		#	
		#		$ErrorActionPreference = "Stop"; #Make all errors terminating
		#		$CITbl = "[DB].[DBUserRoles]"
		#		$query= "declare @db varchar(200), @sqlstmt nvarchar(4000)
    	#				SET NOCOUNT ON   
    	#				create table ##dbroles(
    	#				DBName    varchar(100) default db_name(), DBUser    varchar(200), DBRole    varchar(100));
		#			DECLARE dbs CURSOR FOR
		#			SELECT name FROM sys.databases WHERE database_id > 4 and state = 0
		#			OPEN dbs
		#			FETCH dbs INTO @db
		#			WHILE @@FETCH_STATUS = 0
		#			BEGIN
       	#				set @sqlstmt = N'USE ['+ @db +']; ' + ' insert into ##dbroles
		#						select DB_NAME() as DBname, m.name as DBuser, r.name as DBRole 
		#						from sys.database_principals r join sys.database_role_members rm on r.principal_id = rm.role_principal_id
		#						join sys.database_principals m on m.principal_id = rm.member_principal_id'
		#			exec sp_executesql @sqlstmt
		#			
		#			
		#			FETCH dbs INTO @db
   		#			END
		#			CLOSE dbs
		#			DEALLOCATE dbs
		#			SELECT ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, DBname, DBuser,  DBRole, ('$RunDt') as DateAdded FROM ##dbroles
		#			DROP TABLE ##dbroles"
		#		$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
		#		$dt = new-object System.Data.DataTable
		#		$da.fill($dt) | out-null
		#		Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
		#		#Write-Log -Message "Collecting DB user roles Info" -Level Info -Path $logPath
		#		Write-Log -Message "Collecting DB user roles Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath	
		#				
		#		$Task           = "Collecting DB user roles Info"
		#		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task							
		#	}
		#	catch 
		#	{ 
		#		$ex = $_.Exception 
		#		write-log -Message "$ex.Message on $getServerName While Collecting DB user roles Info" -Level Error -NoConsoleOut -Path $logPath
		#	}
		#	finally
		#	{
		#		$ErrorActionPreference = "Stop"; #Reset the error action pref to default
		#	}
			#############################################################################################################################

			### Database Backups ########################################################################################################
			try 
			{
				$CurrentStep = 20;$StepText = "Collecting Database Backup Information"; $Task = "<beep>... <beep>... Back that up!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[DB].[DatabaseBackups]"
				$query= "SELECT   
					 ('$getServerName') as ServerName, 
                    ('$getInstanceName') as InstanceName,
					bs.database_name as DBName, 
					bs.backup_set_uuid as BackupSetGUID,
					bs.type as BackupTypeCode, 
					CASE bs.type
						WHEN 'D' THEN 'Full Database'
						WHEN 'I' THEN 'Differential Database'
						WHEN 'L' THEN 'Log'
						WHEN 'F' THEN 'File/Filegroup'
						WHEN 'G' THEN 'Differential file'
						WHEN 'P' THEN 'Partial'
						WHEN 'Q' THEN 'Partial Differential'
						ELSE 'Unknown'
					END as BackupTypeDesciption,
					bs.backup_start_date,  
					bs.backup_finish_date, 
					datediff(ms, bs.backup_start_date, bs.backup_finish_date) backup_duration_ms,
					bs.expiration_date, 
					bs.backup_size, 
					bs.compressed_backup_size,  
					bmf.physical_device_name,   
					bs.description, 
					bs.recovery_model,
					bs.is_copy_only,
					bs.is_password_protected,
					bs.has_backup_checksums,
					('$RunDt') as DateAdded
				FROM   msdb.dbo.backupmediafamily   bmf
				INNER JOIN msdb.dbo.backupset bs ON bmf.media_set_id = bs.media_set_id  
				where isnull(bs.name, '0') != '1';"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Database Backup Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Database Backup Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath

				$CurrentStep = 20;$StepText = "Collecting Database Backup Information"; $Task = "Hey it was backed up.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
				#$cn = new-object system.data.SqlClient.SqlConnection("server=$getInstanceName;database=$DatabaseName;Integrated Security=true;");
				$cn.Open()
				$cmd = $cn.CreateCommand()
				$query = "set nocount on; update msdb.dbo.backupset set [name] = '1' where isnull([name], '0') != '1';"
				$cmd.CommandText = $query
				$rowsAffected = $cmd.ExecuteNonQuery()
				#write-log -Message "Collecting Database Backupsets Number of Rows Affected ($rowsAffected)" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Database Backupsets Number of Rows Affected ($rowsAffected) Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath

				$CurrentStep = 20;$StepText = "Collecting Database Backup Information"; $Task = "Lets mark that down.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task													
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Database Backup Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

			### Database Files ##########################################################################################################
			try 
			{
				$CurrentStep = 21;$StepText = "Collecting Database File Information"; $Task = "Let us file who came.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[DB].[DatabaseFiles]"
				$query= "select ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, DB_Name(database_id) as DBName, file_id, type_desc, name as LogicalName, physical_name, (size)*8/1024 as SizeInMB
						,case (is_percent_growth) WHEN 1 THEN growth ELSE 0 END  as GrowthPct
						,case (is_percent_growth) WHEN 0 THEN growth*8/1024 ELSE 0 END  as GrowthInMB, ('$RunDt') as DateAdded
						from sys.master_files
						WHERE type in (0, 1);"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Database Files Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Database Files Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath			

				$CurrentStep = 21;$StepText = "Collecting Database File Information"; $Task = "Hey I think that was everyone.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
						
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting DB Files Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

			### Database Growth #########################################################################################################
			try 
			{
				$CurrentStep = 22;$StepText = "Collecting Database Growth Information"; $Task = "Oh, if I do not stop eating my pants will not fit!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[DB].[DBFileGrowth]"
				$query= "select ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, DB_Name(database_id) as DBName, SUM(case when type_desc = 'ROWS' then ((size)*8/1024) else 0 end) as DataFileInMB
					, SUM(case when type_desc = 'LOG' then ((size)*8/1024) else 0 end) as LogFileInMB, ('$RunDt') as DateAdded
						from sys.master_files
						WHERE type in (0, 1)
					Group By DB_Name(database_id);"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Database Growth Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Database Growth Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath

				$CurrentStep = 22;$StepText = "Collecting Database Growth Information"; $Task = "<pop> Oh dear a button!!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task								
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting DB Growth Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

            ### Missing Indexes #############################################################################################################
	        try 
   	        { 
                $CurrentStep = 23;$StepText = "Collecting Missing Index Information"; $Task = "Oh YES! I left room for dessert!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
		        $ErrorActionPreference = "Stop"; #Make all errors terminating
		        $CITbl = "[Inst].[MissingIndexes]"
		        $query= "Select ('$Svr') as ServerName, ('$inst') as InstanceName, DB_Name(mid.database_id) as DBName, OBJECT_SCHEMA_NAME(mid.[object_id], mid.database_id) as SchemaName, 
			        mid.statement as MITable,migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure, 
		            'CREATE INDEX [IDX'
		            + '_' + LEFT (PARSENAME(mid.statement, 1), 32) + ']'
		            + ' ON ' + mid.statement 
		            + ' (' + ISNULL (mid.equality_columns,'') 
			        + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END 
			        + ISNULL (mid.inequality_columns, '')
		            + ')' 
		            + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement,
		            migs.group_handle, migs.unique_compiles, migs.user_seeks, migs.last_user_seek, migs.avg_total_user_cost, migs.avg_user_impact, ('$RunDt') as DateAdded
		        FROM sys.dm_db_missing_index_groups mig
		        INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
		        INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
		        WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 100000
		        ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC"

		        $da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
		        $dt = new-object System.Data.DataTable
		        $da.fill($dt) | out-null
		        Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
		        #write-log -Message "Collecting Missing Index Info" -Level Info -Path $logPath
                
                $CurrentStep = 23;$StepText = "Collecting Missing Index Information"; $Task = "I think I am sweating?!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task			
	        }    
	        catch 
	        { 
		        $ex = $_.Exception 
		        write-log -Message "$ex.Message on $Svr While Collecting Missing Index Info" -Level Warn -Path $logPath 
	        } 
	        finally
	        {
   		        $ErrorActionPreference = "Stop"; #Reset the error action pref to default
	        }
	        #################################################################################################################################

			### Table Permissions info ##################################################################################################
			try 
			{
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[Tbl].[TblPermissions]"
				$query= "declare @db varchar(200), @sqlstmt nvarchar(4000)
    						SET NOCOUNT ON   
    						create table #tmpuserperm(DBName SYSNAME, UserName nvarchar(128), ClassDesc nvarchar(60),
						ObjName sysname, PermName nvarchar(128), PermStat nvarchar(60));
						DECLARE dbs CURSOR FOR
						SELECT name FROM sys.databases WHERE name not in('msdb','tempdb', 'model')
						OPEN dbs
						FETCH dbs INTO @db
						WHILE @@FETCH_STATUS = 0
						BEGIN
       						set @sqlstmt = N'USE ['+ @db +']; ' + ' insert into #tmpuserperm
									select DB_NAME() as DBname, USER_NAME(p.grantee_principal_id) AS principal_name, p.class_desc,ObjectName = case p.class
									when 1 then case when p.minor_id=0 then object_name(p.major_id) else object_name(p.major_id)+''->''+ col_name(p.major_id,p.minor_id) end
									else ''N/A'' end, p.permission_name, p.state_desc AS permission_state from sys.database_permissions p 
									inner JOIN sys.database_principals dp on p.grantee_principal_id = dp.principal_id where dp.type in (''U'',''S'',''G'')'
						exec sp_executesql @sqlstmt
						FETCH dbs INTO @db
   						END
						CLOSE dbs
						DEALLOCATE dbs
						SELECT ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, *, ('$RunDt') as DateAdded FROM #tmpuserperm ORDER BY dbname
						DROP TABLE #tmpuserperm"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Table Permissions Info" -Level Info -Path $logPath
				Write-Log -Message "Collecting Table Permissions Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath		
        
				$Task           = "Collecting Table Permissions Info"
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task					
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Table Permissions Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
		#	#############################################################################################################################
			
			### Memory (Hekaton) Table info #############################################################################################
			try 
			{
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[Tbl].[HekatonTbls]"
				$query= "IF SERVERPROPERTY ('IsXTPSupported') = 1
					BEGIN
					declare @db varchar(200), @sqlstmt nvarchar(4000)
    					SET NOCOUNT ON   
    					create table ##tmpHekaton(DBName SYSNAME, tblName SYSNAME, IsMemOptimized bit, Durability tinyint, 
						DurabilityDesc nvarchar(60), MemAllocForIdxInKB bigint, MemAllocForTblInKB bigint, MemUsdByIdxInKB bigint,
						MemUsdByTblInKB bigint);
					DECLARE dbs CURSOR FOR
					SELECT name FROM sys.databases --WHERE database_id > 4 and state = 0
					OPEN dbs
					FETCH dbs INTO @db
					WHILE @@FETCH_STATUS = 0
					BEGIN
       					set @sqlstmt = N'USE ['+ @db +']; ' + ' insert into ##tmpHekaton
								select DB_NAME() as DBname, t.name as HekatonTblName, t.Is_memory_optimized as IsMemOptimized, t.durability as Durability, t.durability_desc as DurabilityDesc,
								x.memory_allocated_for_indexes_kb as MemAllocForIdxInKB, x.memory_allocated_for_table_kb as MemAllocForTblInKB,
								x.memory_used_by_indexes_kb as MemUsdByIdxInKB, x.memory_used_by_table_KB as MemUsdByTblInKB from Sys.tables t 
								inner join sys.dm_db_xtp_table_memory_stats x on t.object_id= x.object_id and is_memory_optimized =1'
					exec sp_executesql @sqlstmt
					FETCH dbs INTO @db
   					END
					CLOSE dbs
					DEALLOCATE dbs
					SELECT ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, *, ('$RunDt') as DateAdded FROM ##tmpHekaton ORDER BY dbname
					DROP TABLE ##tmpHekaton
					END"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting InMemory (Hekaton) Tables Info" -Level Info -Path $logPath
				Write-Log -Message "Collecting InMemory (Hekaton) Tables Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath		
        
				$Task           = "Collecting InMemory (Hekaton) Tables Info"
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task					
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Memory (Hekaton) Tables Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################
			
			### DB Level Triggers Info ##################################################################################################
			#http://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.databaseddltrigger.aspx
			try 
			{
				$CurrentStep = 21;$StepText = "Collecting Availability Replicas Info"; $Task = "Who wants a copy of this family picture?";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[DB].[Triggers]"
				$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $getInstanceName
				foreach ($db in $s.Databases) 
				{
					if ($db.IsAccessible -eq $True) 
					{
						[string]$nm = $db.Name
						$dt = $db.Triggers | select @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}}, @{Name="Database"; Expression = {$nm}}, Name, 
						createdate, datelastmodified, IsEnabled, @{n="DateAdded";e={$RunDt}} |out-datatable
						Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
						#Write-Log -Message "Collecting DB Level Trigger Info $db" -Level Info -Path $logPath
						Write-Log -Message "Collecting DB Level Trigger Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath
						
						$Task           = "Collecting DB Level Trigger Info $db"
						DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task							
					}#end if
				}#end foreach
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting DB Level Trigger Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################
			
			### Availability Groups Info ################################################################################################
			#http://msdn.microsoft.com/en-us/library/ff878305%28SQL.110%29.aspx
			try 
			{
				$CurrentStep = 24;$StepText = "Collecting Availability Groups Info"; $Task = "Lets smoosh together and take a family photo";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[DB].[AvailGroups]"
				$query= "IF SERVERPROPERTY ('IsHadrEnabled') = 1
					BEGIN
					Select ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, Ag.name as AGName, AGS.Primary_Replica as PrimaryReplica, AGS.Synchronization_Health_desc as SyncHealth, 
					AG.automated_backup_preference_desc as BackupPreference, AG.failure_condition_level as Failoverlevel, 
					AG.Health_check_timeout as HealthChkTimeout, AGL.dns_name as ListenerName, AGLIP.ip_address as ListenerIP,
					AGL.Port as ListenerPort, ('$RunDt') as DateAdded from sys.availability_groups AG 
					Inner Join sys.dm_hadr_availability_group_states AGS on ag.group_id = ags.group_id 
					Inner Join sys.dm_hadr_availability_replica_states ARS on ARS.Group_id = Ag.Group_id 
					Inner Join sys.availability_group_listeners AGL on AGL.Group_id = AG.Group_id
					Inner Join sys.availability_group_listener_ip_addresses AGLIP on AGL.listener_id = AGLIP.listener_id
					Where ARS.Role_Desc ='Primary'
					END"
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Availability Groups Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Availability Groups Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath	

				$CurrentStep = 24;$StepText = "Collecting Availability Groups Info"; $Task = "Say CHEESE!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task					
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Availability Groups Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

			### Availability Databases Info #############################################################################################
			try 
			{
				$CurrentStep = 25;$StepText = "Collecting Availability Databases Info"; $Task = "Ok, ok, this time no one close their eyes.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[DB].[AvailDatabases]"
				$query= "IF SERVERPROPERTY ('IsHadrEnabled') = 1
						BEGIN
						Select ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, SD.name as AGDBName, AG.Name as AGName, AGS.Primary_Replica as PrimaryReplica, 
						DRS.Synchronization_state_desc as SyncState, DRS.Synchronization_health_desc as SyncHealth, 
						DRS.database_state_desc as DBState,DRS.is_suspended as IsSuspended, DRS.suspend_reason_desc as SuspendReason,
						SD.create_Date as AGDBCreateDate, ('$RunDt') as DateAdded from sys.dm_hadr_database_replica_states DRS
						Inner Join Sys.databases as SD on SD.database_id= DRS.database_id
						Inner Join sys.dm_hadr_availability_group_states AGS on DRS.group_id = ags.group_id 
						Inner Join sys.availability_groups AG on DRS.group_id = ag.group_id 
						Inner Join sys.dm_hadr_availability_replica_states ARS on ARS.Group_id = Ag.Group_id 
						where ARS.Role_Desc ='Primary' and DRS.database_state_desc = 'Online'
						END"	
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null
				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Availability Databases Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Availability Databases Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath	

				$CurrentStep = 25;$StepText = "Collecting Availability Databases Info"; $Task = "<FLASH> Ooo we look good.";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task					
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Availability Databases Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			#############################################################################################################################

			### Availability Replicas Info ##############################################################################################
			try 
			{
				$CurrentStep = 26;$StepText = "Collecting Availability Replicas Info"; $Task = "Who wants a copy of this family picture?";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
							
				$ErrorActionPreference = "Stop"; #Make all errors terminating
				$CITbl = "[DB].[AvailReplicas]"
				$query= "IF SERVERPROPERTY ('IsHadrEnabled') = 1
						BEGIN
						Select  ('$getServerName') as ServerName, ('$getInstanceName') as InstanceName, Ar.replica_server_name as ReplicaName, AG.name as AGName, ARS.Role_desc as Role,
						AR.Availability_mode_desc as AvailabilityMode, AR.Failover_mode_desc as FailoverMode, AR.session_timeout as SessionTimeout, 
						AR.Primary_role_allow_connections_desc as ConnectionsInPrimaryRole, AR.Secondary_role_allow_connections_desc as ReadableSecondary, 
						AR.endpoint_url as EndpointUrl, AR.Backup_priority as BackupPriority, AR.create_date as AGCreateDate, AR.Modify_date as AGModifyDate, 
						('$RunDt') as DateAdded from Sys.availability_replicas AR 
						Inner Join sys.availability_groups AG on AR.group_id=AG.Group_id
						Inner Join sys.dm_hadr_availability_replica_states ARS on ARS.replica_id = AR.replica_id
						Where Ar.Replica_server_name = @@ServerName
						END"	
				$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
				$dt = new-object System.Data.DataTable
				$da.fill($dt) | out-null

				Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
				#Write-Log -Message "Collecting Availability Replicas Info" -Level Info -Path $logPath
				#Write-Log -Message "Collecting Availability Replicas Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath

				$CurrentStep = 26;$StepText = "Collecting Availability Replicas Info"; $Task = "Everyone!";
				DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task			
			}
			catch 
			{ 
				$ex = $_.Exception 
				write-log -Message "$ex.Message on $getServerName While Collecting Availability Replicas Info" -Level Error -NoConsoleOut -Path $logPath
			}
			finally
			{
				$ErrorActionPreference = "Stop"; #Reset the error action pref to default
			}
			############################################################################################################################
	}
	else 
	{
		write-log -Message "SQL Server DB Engine is not Installed or Started or inaccessible on $getInstanceName"  -NoConsoleOut -Path $logPath
	}
	#############################################################################################################################

	### Reporting Services Info  ################################################################################################
	#http://msdn.microsoft.com/en-us/library/ms152836.aspx
	#http://serverfault.com/questions/28857/how-to-use-powershell-2-get-wmiobject-to-find-an-instance-of-sql-server-reportin
	try 
	{	
		$CurrentStep = 27;$StepText = "Collecting Reporting Server Information"; $Task = "Ooo dessert!!";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
				
		$ErrorActionPreference = "Stop"; #Make all errors terminating
		$results = gwmi -query "select * from win32_service where name like 'ReportServer%' and started = 1" -computername $getServerName 
		$responds = $false
		if ($results.ProcessID -ne $null) { $responds = $true }
		if ($responds) 
		{
			$CITbl="[RS].[SSRSInfo]"
			$name = $getInstanceName.Split("\")
			if ($name.Length -eq 1) { $getInstanceName = "MSSQLSERVER" } else { $getInstanceName = $name[1]}			
			$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $getInstanceName
			
			$rs_namespace = GetRSNameSpace $s.Version $getInstanceName
			$version = GetVersion($s.Version)
			$edition = GetEdition($s.EditionName)

			$dt = Get-WmiObject -class MSReportServer_Instance -namespace $rs_namespace -computername $getServerName | select @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}}, 
				@{n="RSVersion";e={$version}}, 
				@{n="RSEdition";e={$edition}},
				@{n="RSVersionNo";e={if($_.Version -eq $null) {'9.0'} else { $_.Version }}}, 
				IsSharePointIntegrated, @{n="DateAdded";e={$RunDt}} | out-datatable
			Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
			#Write-Log -Message "Collecting Reporting server Info" -Level Info -Path $logPath
			#Write-Log -Message "Collecting Reporting server Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath	

			$CurrentStep = 26;$StepText = "Collecting Reporting Server Information"; $Task = "Pumpkin Pie, is so good.";
			DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
		
			$CITbl="[RS].[SSRSConfig]"
			$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $getInstanceName
			$rs_namespace = GetRSNameSpaceAdmin $s.Version $getInstanceName
			$dt = Get-WmiObject -class MSReportServer_ConfigurationSetting -namespace $rs_namespace -computername $getServerName | select @{n="ServerName";e={$getServerName}}, @{n="InstanceName1";e={$getInstanceName}}, 
				DatabaseServerName, InstanceName, PathName, DatabaseName, DatabaseLogonAccount, DatabaseLogonTimeout,
				DatabaseQueryTimeout, ConnectionPoolSize,  IsInitialized, IsReportManagerEnabled, IsSharePointIntegrated, 
				IsWebServiceEnabled, IsWindowsServiceEnabled, SecureConnectionLevel, SendUsingSMTPServer,SMTPServer, 
				SenderEmailAddress, UnattendedExecutionAccount, ServiceName, WindowsServiceIdentityActual, @{n="DateAdded";e={$RunDt}} | out-datatable
			Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
			#Write-Log -Message "Collecting Reporting server Config Info" -Level Info -Path $logPath
			#Write-Log -Message "Collecting Reporting server config Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath

			$CurrentStep = 27;$StepText = "Collecting Reporting Server Configuration Information"; $Task = "Brownies, are also so good.";
			DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task					
		}
		else
		{
			Write-log -Message "Reporting Services is not Installed or Started or inaccessible on $getInstanceName"  -NoConsoleOut -Path $logPath
		}
	}
	catch 
	{ 
		$ex = $_.Exception 
		write-log -Message "$ex.Message on $getServerName While Collecting RS Info" -Level Error -NoConsoleOut -Path $logPath
	}
	finally
	{
		$ErrorActionPreference = "Stop"; #Reset the error action pref to default
	}
	#############################################################################################################################

	### Analysis Services Info  #################################################################################################
	try 
	{
		$CurrentStep = 28;$StepText = "Collecting Analysis Server Information"; $Task = "An after dinner aperitif.";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
					
		$ErrorActionPreference = "Stop"; #Make all errors terminating
		$results = gwmi -query "select * from win32_service where name like 'MSSQLServerOLAPService%' and started = 1" -computername $getServerName 
		$responds = $false
		if ($results.ProcessID -ne $null) { $responds = $true }
		if ($responds) 
		{
			$S = New-Object ('Microsoft.AnalysisServices.Server')
			$s.connect("$SQLServerConnection")			

			$SQLVersion = GetVersion($s.Version)
			$IsSPUpToDate = GetIsUpToDate($s.Version)
			$SQLASEdition = GetEdition($s.edition)

			$CITbl="[AS].[SSASInfo]"
			$dt =  $s | Select @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}}, ProductName, @{n="SQLASVersion";e={$SQLASVersion}}, ProductLevel, @{n="IsSPUpToDateOnAS";e={$IsSPUpToDateOnAS}},@{n="SQLASEdition";e={$SQLASEdition}}, Version, @{n="NoOfDBs";e={($_.Databases.Count)}}, LastSchemaUpdate, Connected, IsLoaded, @{n="DateAdded";e={$RunDt}} | out-datatable
			Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
			#Write-Log -Message "Collecting Analysis server Info" -Level Info -Path $logPath
			#Write-Log -Message "Collecting Analysis server Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath

			$CurrentStep = 27;$StepText = "Collecting Analysis Server Information"; $Task = "Dessert wine!";
			DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
			
			$CITbl="[AS].[SSASDBInfo]"
			$dt =  $s.Databases | Select @{n="ServerName";e={$getServerName}}, @{n="InstanceName";e={$getInstanceName}},  Name, @{Expression={$_.EstimatedSize / 1MB};Label="DBSizeInMB"}, Collation, CompatibilityLevel, CreatedTimestamp, LastProcessed, LastUpdate, DBStorageLocation, @{n="NoOfCubes";e={($_.Cubes.Count)}},  @{n="NoOfDimensions";e={($_.Dimensions.Count)}}, ReadWriteMode, StorageEngineUsed, Visible, @{n="DateAdded";e={$RunDt}} | out-datatable
			Write-DataTable -InstanceName $cmsInstanceName -DatabaseName $cmsDatabaseName -TableName $CITbl -Data $dt
			#Write-Log -Message "Collecting Analysis server database Info" -Level Info -Path $logPath
			#Write-Log -Message "Collecting Analysis server database Info Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -Path $logPath

			$CurrentStep = 28;$StepText = "Collecting Analysis Server Database Information"; $Task = "A nice cognac, to finish the night off.";
			DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task			
		}
		else
		{
			Write-log -Message "Analysis Services is not Installed or Started or inaccessible on $getServerName" -NoConsoleOut -Path $logPath
		}
	}
	catch 
	{ 
		$ex = $_.Exception 
		write-log -Message "$ex.Message on $getServerName While Collecting AS Info" -Level Error -NoConsoleOut -Path $logPath
	}
	finally
	{
		$ErrorActionPreference = "Stop"; #Reset the error action pref to default
	}
	#############################################################################################################################
}
#GetServerListInfo
######################################################################################################################################

######################################################################################################################################
#Execute Script
try
{ 

	if ($logPath -notmatch '.+?\\$') { $logPath += '\' } 
	$logPath = $logPath + $logFileName
	$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
	write-log -Message "Script Started at $(get-date)" -Clobber -Path $logPath
	
	# Progress Bar Variables
	$Activity		= "Get CentralDB Inventory"
	$TotalSteps		= 30
	$CurrentStep	= 1	
	$StepText       = "Preparing the scripts"
	$Task           = "Getting things ready for the party..."
	DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task

	# Getting the Server List Data
	$CurrentStep = 2;$StepText = "Gathering Server List Data"; $Task = "Finding the punch bowl...";
	DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
	## Login parameters will need to be defined
	$cn = new-object system.data.sqlclient.sqlconnection("server=$cmsInstanceName;database=$cmsDatabaseName;Integrated Security=true;");
	$cn.Open(); $cmd = $cn.CreateCommand()	
	
	##This needs to be updated to no longer connect to server list table... if it is locally run.
	if ($runLocally -eq "true"){$query = "Select Distinct ServerName, InstanceName from [Svr].[ServerList] where Inventory='True' and ServerName = '$env:computername';"}
	else {$query = "Select Distinct ServerName, InstanceName from [Svr].[ServerList] where Inventory='True';"}
	Write-Host $query
    $cmd.CommandText = $query
	$reader = $cmd.ExecuteReader()
	while($reader.Read()) 
	{ 
		# Parsing the Server and Instance Name
		$CurrentStep = 3;$StepText = "Parsing the Server and Instance Name"; $Task = "Topping the charts...";
		DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
		
   		# Get ServerName, InstanceName and DatabaseName
		$getServerName = $reader['ServerName']
		$getInstanceName = $reader['InstanceName']    
		$getDatabaseName = 'tempdb'
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
			# Calling the GetServerListInfo Function
			$CurrentStep = 4;$StepText = "Calling the GetServerListInfo Function"; $Task = "Spinning up the DJ...";
			DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task
				
			# Calling function and passing server and instance parameters
			GetServerListInfo $getServerName $getInstanceName $getDatabaseName
			
			$cnUpdate = new-object system.data.sqlclient.sqlconnection("server=$cmsInstanceName;database=$cmsDatabaseName;Integrated Security=true;");
			$cnUpdate.Open()
			$cmdUpdate = $cnUpdate.CreateCommand()
			$queryUpdate = "UPDATE [Svr].[ServerList] SET [InventoryLastExecDate] = SYSDATETIME() WHERE Inventory='True' and ServerName = '$env:computername';"
			$cmdUpdate.CommandText = $queryUpdate
			$adUpdate = New-Object system.data.sqlclient.sqldataadapter ($cmdUpdate.CommandText, $cnUpdate)
			$dsUpdate = New-Object system.data.dataset
			$adUpdate.Fill($dsUpdate)
			$cnUpdate.Close()		
		}
		else 
		{
 			# Let the user know we couldn't connect to the server
			write-log -Message "$getServerName Server did not respond" -NoConsoleOut -Path $logPath
		} 
	}	
	###################################################################Delete old data#################################################################
	if ($runLocally -ne "true")
	{
		$cn = new-object system.data.SqlClient.SqlConnection("server=$cmsInstanceName;database=$cmsDatabaseName;Integrated Security=true;");
		$cn.Open()
		$cmd = $cn.CreateCommand()
		$q = "exec [dbo].[usp_DelData]"
		$cmd.CommandText = $q
		$null = $cmd.ExecuteNonQuery()
		$cn.Close()
	}
	
	
	$CurrentStep = 29;$StepText = "Finishing Get Inventory"; $Task = "That was a nice dinner, see you next time.";
	DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task	
		
	$CurrentStep = 30;$StepText = "Finishing Get Inventory"; $Task =  "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())";
	DisplayProgress -TotalSteps $TotalSteps -CurrentStep $CurrentStep -Activity $Activity -StepText $StepText -Task $Task			

	Write-Progress -Id ($Id+1) -Activity $Activity -Completed
	if ($AddPauses) { Start-Sleep -Milliseconds $ProgressBarWait }	
}
catch
{
	$ex = $_.Exception 
	write-log -Message "$ex.Message on $getServerName excuting script Get-Inventory.ps1" -Level Error -Path $logPath 
}
#Execute Script
######################################################################################################################################

###################################################################################################################################
<# Based on Allen White, Colleen Morrow and Erin Stellato's Scripts for SQL Inventory and Baselining
https://www.simple-talk.com/sql/database-administration/let-powershell-do-an-inventory-of-your-servers/
http://colleenmorrow.com/2012/04/23/the-importance-of-a-sql-server-inventory/
http://www.sqlservercentral.com/articles/baselines/94657/ #>
###################################################################################################################################
