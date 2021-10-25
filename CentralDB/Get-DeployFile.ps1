function Get-DeployFile
{ 
    #[OutputType([System.Collections.Generic.List[string]])]
    [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Database, 
    [Parameter(Position=2, Mandatory=$true)] [string]$FilePath, 
    [Parameter(Position=3, Mandatory=$true)] [string]$FileFilter, 
    [Parameter(Position=4, Mandatory=$true)] [string]$VersionPattern, 

    [Parameter(Position=5, Mandatory=$false)] [string]$Username, 
    [Parameter(Position=6, Mandatory=$false)] [string]$Password, 
    [Parameter(Position=7, Mandatory=$false)] [Int32]$BatchSize=50000, 
    [Parameter(Position=8, Mandatory=$false)] [Int32]$QueryTimeout=0, 
    [Parameter(Position=9, Mandatory=$false)] [Int32]$ConnectionTimeout=30 
    ) 

    #$outputFileList = [System.Collections.Generic.List[string]]::new()
    $outputFileList = @()
    
	### Get Child Items #####################################################################################################	
	#write-host "step 3.1.1: Get Source Child Items"
    $files = Get-ChildItem -Path $FilePath -Filter $FileFilter
    foreach($file in $files)
    {
	    ### Loop Through Child Items #####################################################################################################	
	    #write-host "step 3.1.2: Loop Through Source Child Items $file.FullName"
        $sourceFullPath = $file.FullName
        $sourceFileName = $file.Name
        $sourceFileVersion = ""
        $sourceObjectName = $sourceFileName.Replace($FileFilter.Replace("*",""), "")
        $i = 0
        ### SOURCE CHECK ##############################################################
        $fileVersions = SELECT-String -Path $sourceFullPath -Pattern $VersionPattern -CaseSensitive | select-object -First 1
        foreach($fileVersion in $fileVersions)
        {
            $i = $i + 1
            if (![string]::IsNullOrWhiteSpace($fileVersions) -and $i -eq 1)
            {
                $sourceFileVersion = (($fileVersion.Line.Replace($VersionPattern, "")).Replace("//--", "")).Trim()
                $sourceFileVersionBak = $sourceFileVersion
                #write-host "sourceFileVersion: $sourceFileVersion"
            }
            elseif([string]::IsNullOrWhiteSpace($fileVersions) -and $i -eq 1) 
            {
                $sourceFileVersion = "EXISTS"
            }
            #write-host "loop $i"

        }
        #$sourceVersion

        ### If no version is given, write exists. IF the other side has an exists then we must assume it is the same version. 
      
        #write-host "sourceFullPath: $sourceFullPath; sourceFileName: $sourceFileName; sourceFileVersion: $sourceFileVersion; sourceObjectName: $sourceObjectName;"
  

	    ### Get Child Items #####################################################################################################	
	    #write-host "step 3.1.3: Get Destination Child Items"
        if ($Username) 
        { $ConnectionString = "Data Source={0};Initial Catalog={1};User ID={2};Password={3};Connect Timeout={4}" -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout } 
        else 
        { $ConnectionString = "Data Source={0};Initial Catalog={1};Integrated Security=SSPI;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout }      
        $InstanceSQLConn = new-object system.data.SqlClient.SqlConnection($ConnectionString);
        #$sc = $InstanceSQLConn.CreateCommand()  
        $InstanceSQLConn.Open()
        $Command = New-Object System.Data.SQLClient.SQLCommand 
        $Command.Connection = $InstanceSQLConn 
        $query = "DECLARE @VersionKeyword nvarchar(max) = '$VersionPattern'
        SELECT 
        sys.objects.[name] AS ObjectName,
        db_name() + '.' + sys.schemas.[name] + '.' + sys.objects.[name] as ObjectFullName,
        CASE WHEN CHARINDEX(@VersionKeyword,OBJECT_DEFINITION(sys.objects.[object_id])) > 0 THEN SUBSTRING(OBJECT_DEFINITION(sys.objects.[object_id]),CHARINDEX(@VersionKeyword,OBJECT_DEFINITION(sys.objects.[object_id])) + LEN(@VersionKeyword) + 1, 19) ELSE 'EXISTS' END AS [Version],
        CAST(CHECKSUM(CAST(OBJECT_DEFINITION(sys.objects.[object_id]) AS nvarchar(max)) COLLATE SQL_Latin1_General_CP1_CI_AS) AS bigint) AS [Checksum]
        FROM sys.objects
        INNER JOIN sys.schemas ON sys.objects.[schema_id] = sys.schemas.[schema_id]
        WHERE sys.schemas.[name] = 'dbo'
        AND sys.objects.[name] = '" + $sourceObjectName + "'
        ORDER BY sys.schemas.[name] ASC, sys.objects.[name] ASC"   
        $Command.CommandText = $query 
        $Reader = $Command.ExecuteReader()
        while($Reader.Read()) 
        {
	        ### Loop Through Child Items #####################################################################################################
            $destinationFullPath = $Reader['ObjectFullName']        
            $destinationFileName = $Reader['ObjectName']
            $destinationFileVersion = $Reader['Version']  
            $destinationObjectName = $Reader['ObjectName']
            #write-host "destinationFullPath: $destinationFullPath; destinationFileName: $destinationFileName; destinationFileVersion: $destinationFileVersion; destinationObjectName: $destinationObjectName;"
         }
         $Reader.Close()

         if ($sourceObjectName -eq $destinationObjectName)
         { 
            if ($destinationFileVersion -eq "EXISTS")
            {
                $deploy = 0
                write-host "### Do not deploy destinationObjectName: $destinationObjectName it already exists."
            }
            elseif ($sourceFileVersionBak -eq $destinationFileVersion)
            {
                $deploy = 0
                 write-host "### Do not deploy destinationObjectName: $destinationObjectName it already exists at the same version."
            }
            else
            {
                $deploy = 1
                write-host "### Do deploy Version sourceFileVersion: $sourceFileVersionBak | destinationFileVersion: $destinationFileVersion mismatch."
                $outputFileList += $sourceFullPath
            }
         }
         else
         {
            $deploy = 1
            write-host "### Do deploy destinationObjectName: $sourceFullPath does not exist."
            $outputFileList += $sourceFullPath
         }
    }
    return $outputFileList
}