USE [master]
GO

/****** Object:  Database [CentralDB]    Script Date: 7/26/2021 8:43:03 AM ******/
CREATE DATABASE [CentralDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CentralDB', FILENAME = N'{PATH_TO_DATAFILE}CentralDB_Primary.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB ), 
 FILEGROUP [DB] 
( NAME = N'DB', FILENAME = N'{PATH_TO_DATAFILE}CentralDB_DB.mdf' , SIZE = 1024KB , MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB ), 
 FILEGROUP [FRK] 
( NAME = N'FRK', FILENAME = N'{PATH_TO_DATAFILE}CentralDB_FRK.mdf' , SIZE = 1024KB , MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB ), 
 FILEGROUP [Inst] 
( NAME = N'Inst', FILENAME = N'{PATH_TO_DATAFILE}CentralDB_Inst.mdf' , SIZE = 263168KB , MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB ), 
 FILEGROUP [Svr] 
( NAME = N'Svr', FILENAME = N'{PATH_TO_DATAFILE}CentralDB_Svr.mdf' , SIZE = 1024KB , MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB )
 LOG ON 
( NAME = N'CentralDB_log', FILENAME = N'{PATH_TO_DATAFILE}CentralDB_Primary.ldf' , SIZE = 263168KB , MAXSIZE = 2048GB , FILEGROWTH = 262144KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CentralDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [CentralDB] SET ANSI_NULL_DEFAULT ON 
GO

ALTER DATABASE [CentralDB] SET ANSI_NULLS ON 
GO

ALTER DATABASE [CentralDB] SET ANSI_PADDING ON 
GO

ALTER DATABASE [CentralDB] SET ANSI_WARNINGS ON 
GO

ALTER DATABASE [CentralDB] SET ARITHABORT ON 
GO

ALTER DATABASE [CentralDB] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [CentralDB] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [CentralDB] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [CentralDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [CentralDB] SET CURSOR_DEFAULT  LOCAL 
GO

ALTER DATABASE [CentralDB] SET CONCAT_NULL_YIELDS_NULL ON 
GO

ALTER DATABASE [CentralDB] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [CentralDB] SET QUOTED_IDENTIFIER ON 
GO

ALTER DATABASE [CentralDB] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [CentralDB] SET  DISABLE_BROKER 
GO

ALTER DATABASE [CentralDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [CentralDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [CentralDB] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [CentralDB] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO

ALTER DATABASE [CentralDB] SET PARAMETERIZATION FORCED 
GO

ALTER DATABASE [CentralDB] SET READ_COMMITTED_SNAPSHOT ON 
GO

ALTER DATABASE [CentralDB] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [CentralDB] SET RECOVERY FULL 
GO

ALTER DATABASE [CentralDB] SET  MULTI_USER 
GO

ALTER DATABASE [CentralDB] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [CentralDB] SET DB_CHAINING OFF 
GO

ALTER DATABASE [CentralDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [CentralDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO

ALTER DATABASE [CentralDB] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [CentralDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO

ALTER DATABASE [CentralDB] SET QUERY_STORE = ON
GO

ALTER DATABASE [CentralDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 31), DATA_FLUSH_INTERVAL_SECONDS = 3600, INTERVAL_LENGTH_MINUTES = 15, MAX_STORAGE_SIZE_MB = 1024, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO

ALTER DATABASE [CentralDB] SET  READ_WRITE 
GO

USE [CentralDB]
GO
/****** Object:  Schema [AS]    Script Date: 7/26/2021 8:40:10 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'AS')
EXEC sys.sp_executesql N'CREATE SCHEMA [AS]'
GO
/****** Object:  Schema [DB]    Script Date: 7/26/2021 8:40:10 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'DB')
EXEC sys.sp_executesql N'CREATE SCHEMA [DB]'
GO
/****** Object:  Schema [FRK]    Script Date: 7/26/2021 8:40:10 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'FRK')
EXEC sys.sp_executesql N'CREATE SCHEMA [FRK]'
GO
/****** Object:  Schema [Inst]    Script Date: 7/26/2021 8:40:10 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Inst')
EXEC sys.sp_executesql N'CREATE SCHEMA [Inst]'
GO
/****** Object:  Schema [IS]    Script Date: 7/26/2021 8:40:10 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'IS')
EXEC sys.sp_executesql N'CREATE SCHEMA [IS]'
GO
/****** Object:  Schema [RS]    Script Date: 7/26/2021 8:40:10 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'RS')
EXEC sys.sp_executesql N'CREATE SCHEMA [RS]'
GO
/****** Object:  Schema [Svr]    Script Date: 7/26/2021 8:40:10 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Svr')
EXEC sys.sp_executesql N'CREATE SCHEMA [Svr]'
GO
/****** Object:  Schema [Tbl]    Script Date: 7/26/2021 8:40:10 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Tbl')
EXEC sys.sp_executesql N'CREATE SCHEMA [Tbl]'
GO
/****** Object:  UserDefinedFunction [dbo].[fGETFRKVulnerabilityRank]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fGETFRKVulnerabilityRank]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[fGETFRKVulnerabilityRank]
(
	 @Finding		nvarchar(200)
	,@FindingsGroup	nvarchar(50)
	,@Details		nvarchar(4000)
	,@Priority		tinyint
)
RETURNS int
AS
BEGIN
DECLARE @Vulnerability	int
set @Vulnerability = @Priority 
RETURN @Vulnerability

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fGETFRKVulnerabilityStatus]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fGETFRKVulnerabilityStatus]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

CREATE FUNCTION [dbo].[fGETFRKVulnerabilityStatus]
(
	 @Finding		nvarchar(200)
	,@FindingsGroup	nvarchar(50)
	,@Details		nvarchar(4000)
	,@Priority		tinyint
)
RETURNS nvarchar(30)
AS
BEGIN
DECLARE @COUNT			int
DECLARE @Status			nvarchar(30)
DECLARE @Vulnerability	int

SET @Vulnerability = [dbo].[fGETFRKVulnerabilityRank](@Finding,@FindingsGroup,@Details,@Priority)  

SET @Status =
	CASE 
	WHEN @Vulnerability <= 5 THEN ''Informational''
	WHEN @Vulnerability BETWEEN 6 AND 128 THEN ''Low''
	WHEN @Vulnerability BETWEEN 129 AND 256 THEN ''Moderate'' 
	WHEN @Vulnerability BETWEEN 257 AND 512 THEN ''Severe''
	ELSE ''Critical'' 
	END

RETURN @Status

END
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetPercentageGrowthOverXMonths]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnGetPercentageGrowthOverXMonths]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

CREATE function [dbo].[fnGetPercentageGrowthOverXMonths]
(
	@ServerName		nvarchar(255),
	@InstanceName	nvarchar(255), 
	@DBName			nvarchar(255),
	@NumMonths		int	= 6
)
RETURNS decimal(7, 2)
BEGIN
	declare @percentageGrowth	decimal(14, 2)
	declare @minDateSummary		varchar(7)
	declare @maxDateSummary		varchar(7)
	
	SELECT @minDateSummary = min(DateSummary) FROM dbo.vwGETDatabaseAvgSizePerMonth where DateSummary >= convert(varchar(7), dateadd(month, @NumMonths * -1, getDate()), 120) and ServerName = @ServerName and InstanceName = @InstanceName and DBName = @DBName
	SELECT @maxDateSummary = max(DateSummary) FROM dbo.vwGETDatabaseAvgSizePerMonth where DateSummary >= convert(varchar(7), dateadd(month, @NumMonths * -1, getDate()), 120) and ServerName = @ServerName and InstanceName = @InstanceName and DBName = @DBName
	
	declare @divideNum1			decimal(20, 4)
	declare @divideNum2			decimal(20, 4)

	set @divideNum1 = (SELECT UsedSpaceInMB FROM dbo.vwGETDatabaseAvgSizePerMonth WHERE ServerName = @ServerName and InstanceName = @InstanceName and DBName = @DBName and DateSummary = @maxDateSummary GROUP BY UsedSpaceInMB) - (SELECT UsedSpaceInMB FROM dbo.vwGETDatabaseAvgSizePerMonth WHERE ServerName = @ServerName and InstanceName = @InstanceName and DBName = @DBName and DateSummary = @minDateSummary GROUP BY UsedSpaceInMB)
	if @divideNum1 = 0 set @divideNum1 = 0.0001

	set @divideNum2 = (SELECT UsedSpaceInMB FROM dbo.vwGETDatabaseAvgSizePerMonth WHERE ServerName = @ServerName and InstanceName = @InstanceName and DBName = @DBName and DateSummary = @maxDateSummary GROUP BY UsedSpaceInMB) + (SELECT UsedSpaceInMB FROM dbo.vwGETDatabaseAvgSizePerMonth WHERE ServerName = @ServerName and InstanceName = @InstanceName and DBName = @DBName and DateSummary = @minDateSummary GROUP BY UsedSpaceInMB)
	if @divideNum2 = 0 set @divideNum2 = 0.0001
	
	SELECT @percentageGrowth = 
	(		
		(
			@divideNum1
		)
		/ 
		(
			(
				@divideNum2
			) 
			/ 2.0
		) 
		* 100.0
	 )
	
	RETURN @percentageGrowth 
END
' 
END
GO
/****** Object:  Table [dbo].[SqlServerVersionDetails]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SqlServerVersionDetails]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SqlServerVersionDetails](
	[Path] [nvarchar](255) NOT NULL,
	[Binary] [nvarchar](255) NOT NULL,
	[Url] [varchar](99) NOT NULL,
	[BinaryFlags] [nvarchar](255) NOT NULL,
	[DateAdded] [datetime] NOT NULL,
 CONSTRAINT [PK_SqlServerVersionDetails] PRIMARY KEY CLUSTERED 
(
	[Url] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[SqlServerVersions]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SqlServerVersions]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SqlServerVersions](
	[MajorVersionNumber] [tinyint] NOT NULL,
	[MinorVersionNumber] [smallint] NOT NULL,
	[Branch] [varchar](34) NOT NULL,
	[Url] [varchar](99) NOT NULL,
	[ReleaseDate] [date] NOT NULL,
	[MainstreamSupportEndDate] [date] NOT NULL,
	[ExtendedSupportEndDate] [date] NOT NULL,
	[MajorVersionName] [varchar](19) NOT NULL,
	[MinorVersionName] [varchar](67) NOT NULL,
 CONSTRAINT [PK_SqlServerVersions] PRIMARY KEY CLUSTERED 
(
	[MajorVersionNumber] ASC,
	[MinorVersionNumber] ASC,
	[ReleaseDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  View [dbo].[vwSQLServerUpdates]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSQLServerUpdates]'))
EXEC dbo.sp_executesql @statement = N'


CREATE VIEW [dbo].[vwSQLServerUpdates]
AS
SELECT 
	   sv.[MajorVersionNumber]
      ,sv.[MinorVersionNumber]
      ,sv.[Branch]
      ,sv.[ReleaseDate]
      ,sv.[MainstreamSupportEndDate]
      ,sv.[ExtendedSupportEndDate]
      ,sv.[MajorVersionName]
      ,sv.[MinorVersionName] + 
		CASE
			WHEN sv.[ExtendedSupportEndDate] < getDate() then char(10)+char(13)+''*** No longer supported by Microsoft. *** ''
			WHEN sv.[MainstreamSupportEndDate] < getDate() then char(10)+char(13)+''*** Entering extended support. *** ''
			ELSE '''' END as [MinorVersionName]
      ,sv.[Url]
	  ,replace(right((sv.URL) , charindex(''/'', REVERSE(sv.URL))), ''/'', ''KB'') KBNumber
	  ,datediff(day, sv.[ReleaseDate], getDate()) NumberOfDaysOld
	  ,CONVERT(nvarchar(10), [ExtendedSupportEndDate], 120) + '' ('' + cast(datediff(day, sv.[ExtendedSupportEndDate], getDate()) as varchar(10)) + '' Days Old)'' ExtendedSupportEndDateDisplay
	  ,CONVERT(nvarchar(10), [MainstreamSupportEndDate], 120) + '' ('' + cast(datediff(day, sv.[MainstreamSupportEndDate], getDate()) as varchar(10)) + '' Days Old)'' MainstreamSupportEndDateDisplay
	  ,case when y.MajorVersionNumber is not null then ''*'' else '''' end as LatestRelease
	  ,case when x.MajorVersionNumber is not null then ''*'' else '''' end as UpdateToThisVersion
	  ,svd.Path
	  ,svd.Binary
	  ,svd.BinaryFlags
  FROM 
	   [dbo].[SqlServerVersions] sv
  LEFT OUTER JOIN 
		[dbo].[SqlServerVersionDetails] svd
		on svd.Url = sv.Url
  LEFT OUTER JOIN
  (
	SELECT
		 MajorVersionNumber
		,max(MinorVersionNumber)	MinorVersionNumber
		,max(ReleaseDate)			ReleaseDate
		,MajorVersionName
	FROM 
		[dbo].[SqlServerVersions]
	WHERE 
		ReleaseDate <= DateAdd( day, -28, getDate())
	GROUP BY 
		MajorVersionNumber
		,MajorVersionName
  ) x on  x.MajorVersionName = sv.MajorVersionName
	  and x.MajorVersionNumber = sv.MajorVersionNumber
	  and x.MinorVersionNumber = sv.MinorVersionNumber
	  and x.ReleaseDate = sv.ReleaseDate
  LEFT OUTER JOIN
  (
	SELECT
		 MajorVersionNumber
		,max(MinorVersionNumber)	MinorVersionNumber
		,max(ReleaseDate)			ReleaseDate
		,MajorVersionName
	FROM 
		[dbo].[SqlServerVersions]
	GROUP BY 
		MajorVersionNumber
		,MajorVersionName
  ) y on  y.MajorVersionName = sv.MajorVersionName
	  and y.MajorVersionNumber = sv.MajorVersionNumber
	  and y.MinorVersionNumber = sv.MinorVersionNumber
	  and y.ReleaseDate = sv.ReleaseDate

' 
GO
/****** Object:  Table [Inst].[InstanceInfo]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[InstanceInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[InstanceInfo](
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NOT NULL,
	[IPAddress] [nvarchar](50) NULL,
	[Port] [nvarchar](30) NULL,
	[SQLVersion] [nvarchar](30) NULL,
	[SQLPatchLevel] [nvarchar](30) NULL,
	[IsSPUpToDate] [bit] NULL,
	[SQLEdition] [nvarchar](30) NULL,
	[SQLVersionNo] [nvarchar](50) NULL,
	[Collation] [nvarchar](50) NULL,
	[RootDirectory] [nvarchar](256) NULL,
	[DefaultDataPath] [nvarchar](256) NULL,
	[DefaultLogPath] [nvarchar](256) NULL,
	[ErrorLogPath] [nvarchar](256) NULL,
	[IsCaseSensitive] [bit] NULL,
	[IsClustered] [bit] NULL,
	[IsFullTextInstalled] [bit] NULL,
	[IsSingleUser] [bit] NULL,
	[IsAlwaysOnEnabled] [bit] NULL,
	[TCPEnabled] [bit] NULL,
	[NamedPipesEnabled] [bit] NULL,
	[ClusterName] [nvarchar](128) NULL,
	[ClusterQuorumState] [nvarchar](128) NULL,
	[ClusterQuorumType] [nvarchar](128) NULL,
	[AlwaysOnStatus] [nvarchar](50) NULL,
	[MaxMemInMB] [int] NULL,
	[MinMemInMB] [int] NULL,
	[MaxDOP] [tinyint] NULL,
	[NoOfUsrDBs] [smallint] NULL,
	[NoOfJobs] [smallint] NULL,
	[NoOfLnkSvrs] [smallint] NULL,
	[NoOfLogins] [smallint] NULL,
	[NoOfRoles] [tinyint] NULL,
	[NoOfTriggers] [tinyint] NULL,
	[NoOfAvailGrps] [tinyint] NULL,
	[AvailGrps] [nvarchar](max) NULL,
	[IsXTPSupported] [bit] NULL,
	[FilFactor] [tinyint] NULL,
	[ProcessorUsage] [int] NULL,
	[ActiveNode] [nvarchar](128) NULL,
	[ClusterNodeNames] [nvarchar](max) NULL,
	[DateAdded] [smalldatetime] NULL,
	[InstID] [int] IDENTITY(1,1) NOT NULL
) ON [Inst] TEXTIMAGE_ON [Inst]
END
GO
/****** Object:  Table [Svr].[ServerList]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Svr].[ServerList]') AND type in (N'U'))
BEGIN
CREATE TABLE [Svr].[ServerList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NOT NULL,
	[Environment] [nvarchar](128) NOT NULL,
	[VNNName] [nvarchar](128) NULL,
	[Inventory] [bit] NOT NULL,
	[Baseline] [bit] NOT NULL,
	[WaitStat] [bit] NOT NULL,
	[Vulnerability] [bit] NOT NULL,
	[MaintBackup] [bit] NOT NULL,
	[MaintDBCC] [bit] NOT NULL,
	[MaintIndex] [bit] NOT NULL,
	[SQLPing] [bit] NOT NULL,
	[Decomissioned] [bit] NOT NULL,
	[SQLLicenseType] [nvarchar](128) NULL,
	[Sector] [nvarchar](512) NULL,
	[Ministry] [nvarchar](512) NULL,
	[Division] [nvarchar](512) NULL,
	[Branch] [nvarchar](512) NULL,
	[Description] [nvarchar](max) NULL,
	[BusinessOwner] [nvarchar](512) NULL,
	[BusinessOwner2] [nvarchar](512) NULL,
	[TechnicalOwner] [nvarchar](512) NULL,
	[TechnicalOwner2] [nvarchar](512) NULL,
	[InventoryLastExecDate] [datetime2](7) NULL,
	[BaselineLastExecDate] [datetime2](7) NULL,
	[WaitStatLastExecDate] [datetime2](7) NULL,
	[VulnerabilityLastExecDate] [datetime2](7) NULL,
	[MaintBkFullLastExecDate] [datetime2](7) NULL,
	[MaintBkLogLastExecDate] [datetime2](7) NULL,
	[MaintIndexLastExecDate] [datetime2](7) NULL,
	[MaintIndexStatsLastExecDate] [datetime2](7) NULL,
	[MaintDBCCLastExecDate] [datetime2](7) NULL,
	[DateAdded] [smalldatetime] NOT NULL,
	[AddedBy] [nvarchar](255) NULL,
	[DateModified] [smalldatetime] NOT NULL,
	[ModifiedBy] [nvarchar](255) NULL,
 CONSTRAINT [PK_ServerList] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[ServerName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Svr]
) ON [Svr] TEXTIMAGE_ON [Svr]
END
GO
/****** Object:  View [dbo].[vwSQLVersionReview]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSQLVersionReview]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwSQLVersionReview]
as
SELECT 

	  ii.ServerName
	, replace(ii.InstanceName, ''<DOMAIN>'', '''') InstanceName
	, sl.Environment
	, ii.SQLVersion
	, ii.SQLVersionNo + '' ['' + isnull(sv.Branch, ''-unknown-'') + '']''			as CurrentVersion
	, ii.SQLVersionNo as CurrentVersionNo

	, sv.MinorVersionName	as CurrentUpdateLevel
	, sv.ReleaseDate	as CurrentReleaseDate
	, sv.MainstreamSupportEndDate	as CurrentMainstreamSupportEndDate
	, sv.ExtendedSupportEndDate		as CurrentExtendedSupportEndDate
	, sv.KBNumber					as CurrentKBNumber
	, sv.Url						as CurrentURL

	, y.MajorMinorVersion + '' ['' + y.Branch + '']''		as LatestVersion
	, y.MajorMinorVersion as LatestVersionNo

	, y.MinorVersionName	as LatestUpdateLevel
	, y.LastReleaseDate		as LatestReleaseDate
	, y.MainstreamSupportEndDate	as LatestMainstreamSupportEndDate
	, y.ExtendedSupportEndDate		as LatestExtendedSupportEndDate
	, y.KBNumber					as LatestKBNumber
	, y.Url							as LatestURL

,case when y.ExtendedSupportEndDate < getDate() and ii.SQLVersionNo = y.MajorMinorVersion THEN ''Please consider updating this version of SQL Server to a newer version.''
	  when y.LatestServerVersion > right(ii.SQLVersionNo, 4) then y.LatestDetail
	  when right(ii.SQLVersionNo, 4) >= y.LatestServerVersion and sv.ReleaseDate <= DateAdd(day, -28, getDate()) then ''You are upto date!''
	  when right(ii.SQLVersionNo, 4) >= y.LatestServerVersion and sv.ReleaseDate >= DateAdd(day, -28, getDate()) then ''You are upto date! This release is really new, under 28 days old.''
	  when y.LatestServerVersion < right(ii.SQLVersionNo, 4) then ''You are upto date!''
	  when datediff(day, y.LastReleaseDate, getDate()) > 30 THEN y.LatestDetail
	  else ''You are upto date!''
	  END as DetailInfo,
case when y.ExtendedSupportEndDate < getDate() and ii.SQLVersionNo = y.MajorMinorVersion THEN 0
	  when y.LatestServerVersion > right(ii.SQLVersionNo, 4) then 0
	  when right(ii.SQLVersionNo, 4) >= y.LatestServerVersion and sv.ReleaseDate <= DateAdd(day, -28, getDate()) then 1
	  when right(ii.SQLVersionNo, 4) >= y.LatestServerVersion and sv.ReleaseDate >= DateAdd(day, -28, getDate()) then 2
	  when y.LatestServerVersion < right(ii.SQLVersionNo, 4) then 1
	  when datediff(day, y.LastReleaseDate, getDate()) > 30 THEN 0
	  else 1
	  END as UpToDate
FROM Inst.InstanceInfo ii
inner join 
(
	SELECT ServerName, InstanceName, Max(DateAdded) LastDateAdded  
	FROM Inst.InstanceInfo
	GROUP BY ServerName, InstanceName
) x on x.servername = ii.servername and x.instancename = ii.instancename and x.LastDateAdded = ii.DateAdded
left outer join svr.ServerList sl on sl.ServerName = ii.ServerName and case when len(isnull(sl.InstanceName, '''')) = 0 THEN sl.ServerName ELSE sl.InstanceName END = ii.InstanceName 
left outer join dbo.vwSQLServerUpdates sv on sv.MajorVersionName = ii.SQLVersion and sv.MinorVersionNumber = right(ii.SQLVersionNo, 4)
left outer join
(
	SELECT x.*, ''Please update to '' + x.MajorVersionName + '' ['' + x.MajorMinorVersion + ''] | '' + sv.Branch as LatestDetail, sv.MainstreamSupportEndDate, sv.ExtendedSupportEndDate, sv.Branch, sv.MinorVersionName, sv.KBNumber, sv.Url
	FROM
	(
	SELECT  MajorVersionName, MajorVersionNumber, max(MinorVersionNumber) LatestServerVersion, Max(ReleaseDate) LastReleaseDate,
	CASE WHEN MajorVersionName = ''SQL Server 2008 R2'' then CONCAT(MajorVersionNumber ,''.50.'' , max(MinorVersionNumber) )
		 ELSE Concat(MajorVersionNumber, ''.0.'', max(MinorVersionNumber) )
		 END as MajorMinorVersion
	FROM dbo.vwSQLServerUpdates
	WHERE ReleaseDate <= DateAdd(day, -28, getDate())											 
	GROUP BY MajorVersionName, MajorVersionNumber
	) x 
	left outer join dbo.vwSQLServerUpdates sv on (x.MajorVersionName = sv.MajorVersionName and x.LatestServerVersion = sv.MinorVersionNumber and ReleaseDate <= DateAdd(day, -28, getDate()))
												 or 
												 (x.MajorVersionName = sv.MajorVersionName and x.LatestServerVersion = sv.MinorVersionNumber)
) y on y.MajorVersionName = ii.SQLVersion
WHERE sl.Decomissioned = 0
' 
GO
/****** Object:  View [dbo].[vwSQLServerUpdateDBAInstance]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSQLServerUpdateDBAInstance]'))
EXEC dbo.sp_executesql @statement = N'CREATE view [dbo].[vwSQLServerUpdateDBAInstance]
as
SELECT sl.environment, svr.ServerName, svr.InstanceName, svr.LatestURL, ''Update-DbaInstance -ComputerName ''+ Svr.ServerName+'' -Path '''''' + svd.Path + '''''' -KB '' + replace(svr.LatestKBNumber, ''KB'', '''') + '' -ArgumentList ''''/quiet /IAcceptSQLServerLicenseTerms /Action=Patch /AllInstances'''' -Confirm:$false'' UpgradePSExecute
FROM 
	dbo.vwSQLVersionReview svr
INNER JOIN
	dbo.SqlServerVersionDetails svd on svd.Url = svr.LatestURL
INNER JOIN
	svr.ServerList sl on sl.ServerName = svr.ServerName and case when len(sl.InstanceName) = 0 then sl.ServerName else sl.InstanceName end = svr.InstanceName
WHERE 
	UpToDate = 0
	and 
	sl.Decomissioned = 0
' 
GO
/****** Object:  View [Inst].[vwInstanceInfo]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[Inst].[vwInstanceInfo]'))
EXEC dbo.sp_executesql @statement = N'

CREATE view [Inst].[vwInstanceInfo]
as
select case when Y.SQLVersion = ''SQL Server 2000'' then ''2000''
	when Y.SQLVersion = ''SQL Server 2005'' then ''2005''
	when Y.SQLVersion = ''SQL Server 2008'' then ''2008'' 
	when y.SQLVersion = ''SQL Server 2008 R2'' then ''2008 R2''
	when y.SQLVersion = ''SQL Server 2012'' then ''2012''
	when y.SQLVersion = ''SQL Server 2014'' then ''2014''
	when y.SQLVersion = ''SQL Server 2016'' then ''2016''
	when y.SQLVersion = ''SQL Server 2017'' then ''2017''
	when y.SQLVersion = ''SQL Server 2019'' then ''2019''
	else  y.SQLVersion END As SQLVersion, 
case when y.SQLEdition = ''Desktop Edition'' then ''Desktop'' 
	when y.SQLEdition = ''Standard Edition'' then ''Standard''
	when y.SQLEdition = ''Express Edition'' then ''Express'' 
	when y.SQLEdition = ''Developer Edition'' then ''Developer''
	when y.SQLEdition = ''Enterprise Edition'' then ''Enterprise'' 
	when y.SQLEdition = ''Web Edition'' then ''Web''
	when y.SQLEdition = ''BI Edition'' then ''BI''
	when y.SQLEdition = ''Workgroup Edition'' then ''Workgroup''
	when y.SQLEdition = ''Evaluation Edition'' then ''Evaluation''
	else ''Unknown'' END As SQLEdition
 from( select ServerName, InstanceName, Max(DateAdded) as Rundate 
from [Inst].[InstanceInfo]
Group BY ServerName, InstanceName) x
Join [Inst].[InstanceInfo] y ON x.Rundate = y.DateAdded 
and X.InstanceName = y.InstanceName
and x.ServerName = y.ServerName
' 
GO
/****** Object:  Table [dbo].[SQLServerVersionEnvrionments]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SQLServerVersionEnvrionments]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SQLServerVersionEnvrionments](
	[Environment] [nvarchar](128) NOT NULL,
	[EmailNotification] [nvarchar](255) NULL,
	[StartTime] [time](7) NOT NULL,
	[DayOfWeek] [int] NOT NULL,
	[WeekInMonth] [int] NOT NULL,
 CONSTRAINT [PK_SqlServerVersionEnvironments] PRIMARY KEY CLUSTERED 
(
	[Environment] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  View [dbo].[vwSQLServerUpdateInstance]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSQLServerUpdateInstance]'))
EXEC dbo.sp_executesql @statement = N'

create view [dbo].[vwSQLServerUpdateInstance]
as
SELECT svr.ServerName, svr.InstanceName, svr.LatestURL, sve.EmailNotification, sve.StartTime, sve.DayOfWeek, sve.WeekInMonth, ''Update-DbaInstance -ComputerName ''+ Svr.ServerName+'' -Path '''''' + svd.Path + '''''' -KB '' + replace(svr.LatestKBNumber, ''KB'', '''') + '' -ArgumentList ''''/quiet /IAcceptSQLServerLicenseTerms /Action=Patch /AllInstances'''' -Confirm:$false'' UpgradePSExecute
FROM 
	dbo.vwSQLVersionReview svr
INNER JOIN
	dbo.SqlServerVersionDetails svd on svd.Url = svr.LatestURL
INNER JOIN 
	dbo.SQLServerVersionEnvrionments sve on sve.Environment = svr.Environment 
WHERE 
	UpToDate = 0
' 
GO
/****** Object:  Table [Svr].[ServerInfo]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Svr].[ServerInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [Svr].[ServerInfo](
	[ServerName] [nvarchar](128) NOT NULL,
	[IPAddress] [nvarchar](50) NULL,
	[Model] [nvarchar](128) NULL,
	[Manufacturer] [nvarchar](128) NULL,
	[Description] [nvarchar](128) NULL,
	[SystemType] [nvarchar](128) NULL,
	[ActiveNodeName] [nvarchar](128) NULL,
	[Domain] [nvarchar](128) NULL,
	[DomainRole] [nvarchar](128) NULL,
	[PartOfDomain] [bit] NULL,
	[NumberOfProcessors] [int] NULL,
	[NumberOfLogicalProcessors] [int] NULL,
	[NumberOfCores] [int] NULL,
	[IsHyperThreaded] [bit] NULL,
	[CurrentCPUSpeed] [int] NULL,
	[MaxCPUSpeed] [int] NULL,
	[IsPowerSavingModeON] [bit] NULL,
	[TotalPhysicalMemoryInGB] [decimal](10, 2) NULL,
	[IsPagefileManagedBySystem] [bit] NULL,
	[IsVM] [bit] NULL,
	[IsClu] [bit] NULL,
	[DateAdded] [smalldatetime] NULL,
	[SvrID] [int] IDENTITY(1,1) NOT NULL
) ON [Svr]
END
GO
/****** Object:  View [Svr].[vwSvrInfo]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[Svr].[vwSvrInfo]'))
EXEC dbo.sp_executesql @statement = N'

create view [Svr].[vwSvrInfo]
as
SELECT CASE WHEN Y.IsVM = 1 THEN ''Virtual'' ELSE ''Physical'' END AS BoxType, CASE WHEN Y.IsClu = 1 THEN ''Clustered'' ELSE ''StandAlone'' END AS ServerType
FROM     (SELECT ServerName, MAX(DateAdded) AS Rundate
                  FROM      Svr.ServerInfo
                  GROUP BY ServerName) AS x INNER JOIN
                  Svr.ServerInfo AS y ON x.Rundate = y.DateAdded AND x.ServerName = y.ServerName
' 
GO
/****** Object:  Table [Svr].[OSInfo]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Svr].[OSInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [Svr].[OSInfo](
	[ServerName] [nvarchar](128) NOT NULL,
	[OSName] [nvarchar](128) NULL,
	[OSArchitecture] [nvarchar](30) NULL,
	[OSVersion] [nvarchar](20) NULL,
	[OSServicePack] [nvarchar](50) NULL,
	[OSInstallDate] [smalldatetime] NULL,
	[OSLastRestart] [smalldatetime] NULL,
	[OSUpTime] [nvarchar](128) NULL,
	[OSTotalVisibleMemorySizeInGB] [decimal](10, 2) NULL,
	[OSFreePhysicalMemoryInGB] [decimal](10, 2) NULL,
	[OSTotalVirtualMemorySizeInGB] [decimal](10, 2) NULL,
	[OSFreeVirtualMemoryInGB] [decimal](10, 2) NULL,
	[OSFreeSpaceInPagingFilesInGB] [decimal](10, 2) NULL,
	[DateAdded] [smalldatetime] NULL,
	[OSID] [int] IDENTITY(1,1) NOT NULL
) ON [Svr]
END
GO
/****** Object:  View [Svr].[vwOSName]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[Svr].[vwOSName]'))
EXEC dbo.sp_executesql @statement = N'


create view [Svr].[vwOSName]
as
select  y.OSName from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[OSInfo]
Group BY Servername) x
Join [Svr].[OSInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName
' 
GO
/****** Object:  Table [DB].[DatabaseBackups]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DB].[DatabaseBackups]') AND type in (N'U'))
BEGIN
CREATE TABLE [DB].[DatabaseBackups](
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NOT NULL,
	[DBName] [nvarchar](128) NULL,
	[BackupSetGUID] [uniqueidentifier] NULL,
	[BackupTypeCode] [nvarchar](3) NULL,
	[BackupTypeDesciption] [nvarchar](256) NULL,
	[BackupStartDate] [datetime] NULL,
	[BackupFinishDate] [datetime] NULL,
	[BackupDurationMS] [int] NULL,
	[ExpirationDate] [smalldatetime] NULL,
	[BackupSize] [decimal](18, 2) NULL,
	[CompressedBackupSize] [decimal](18, 2) NULL,
	[PhysicalDeviceName] [nvarchar](500) NULL,
	[Description] [nvarchar](256) NULL,
	[RecoveryModel] [nvarchar](60) NULL,
	[IsCopyOnly] [tinyint] NULL,
	[IsPasswordProtected] [tinyint] NULL,
	[HasbackupChecksums] [tinyint] NULL,
	[DateAdded] [smalldatetime] NULL,
	[DBID] [int] IDENTITY(1,1) NOT NULL,
	[BackupDate]  AS (CONVERT([nvarchar](10),[BackupStartDate],(120))) PERSISTED,
	[FileName]  AS (reverse(substring(reverse([PhysicalDeviceName]),(0),charindex('\',reverse([PhysicalDeviceName]))))) PERSISTED,
	[Directory]  AS (reverse(substring(reverse([PhysicalDeviceName]),charindex('\',reverse([PhysicalDeviceName]))+(1),len(reverse([PhysicalDeviceName]))))) PERSISTED,
 CONSTRAINT [PK_DatabaseBackups] PRIMARY KEY NONCLUSTERED 
(
	[DBID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [DB]
) ON [DB]
END
GO
/****** Object:  View [dbo].[vw_DB_DatabaseBackups]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_DB_DatabaseBackups]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vw_DB_DatabaseBackups]
as
SELECT 
	ServerName, 
	InstanceName, 
	CAST(BackupStartDate as DATE) BackupDate, 
	[BackupTypeDesciption],
	COUNT([BackupTypeDesciption]) CountBackupType,
	CONVERT(nvarchar(50), SUM(ROUND(CAST(CompressedBackupSize AS Money)/1024/1024, 2))) + '' MB'' SUMCompressedBackupSizeMB,
	SUM(ROUND(CAST(CompressedBackupSize AS Money)/1024/1024, 2)) SUMCompressedBackupSize
FROM 
	[DB].[DatabaseBackups]
GROUP BY 
	ServerName, 
	InstanceName, 
	[BackupTypeDesciption],
	CAST(BackupStartDate as DATE) --, 

' 
GO
/****** Object:  Table [Inst].[JobHistory]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[JobHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[JobHistory](
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NOT NULL,
	[JobName] [nvarchar](128) NULL,
	[JobID] [uniqueidentifier] NULL,
	[StepID] [int] NULL,
	[StepName] [nvarchar](128) NULL,
	[Message] [nvarchar](4000) NULL,
	[RunStatus] [int] NULL,
	[RunDate] [datetime2](7) NULL,
	[RunDurationMS] [int] NULL,
	[OperatorIDEmailed] [nvarchar](256) NULL,
	[OperatorIDNetSent] [nvarchar](256) NULL,
	[OperatorIDPaged] [nvarchar](256) NULL,
	[RetriesAttempted] [int] NULL,
	[DateAdded] [smalldatetime] NULL,
	[JobHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[BinaryCheckSum]  AS (binary_checksum([ServerName],[InstanceName],[JobName],[JobID],[StepID],[StepName],[Message],[RunStatus],[RunDate],[RunDurationMS],[OperatorIDEmailed],[OperatorIDNetSent],[OperatorIDPaged],[RetriesAttempted])),
 CONSTRAINT [PK_JobHistory] PRIMARY KEY CLUSTERED 
(
	[JobHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Inst]
) ON [Inst]
END
GO
/****** Object:  View [dbo].[vwCTEGetAgentJobHistoryRaw]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetAgentJobHistoryRaw]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCTEGetAgentJobHistoryRaw]
as
SELECT
	   [ServerName]
      ,[InstanceName]
      ,[JobName]
	  ,[JobID]
	  ,[StepName]
	  ,[StepID]
	  ,[RunStatus]
	  ,CASE 
			WHEN patindex(''%Exception%'', [Message]) > 0 and (patindex(''%--->%'', [Message])  - patindex(''%Exception%'', [Message])) > 0 THEN ''Severe''
			WHEN [RunStatus] = 0 THEN ''Critical''
			WHEN [RunStatus] = 1 THEN ''Informational''
			WHEN [RunStatus] = 2 THEN ''Moderate'' 
			WHEN [RunStatus] = 3 THEN ''Low''			
			WHEN [RunStatus] = 4 THEN ''Informational''
			ELSE ''Critical''
		END as Status
	  ,CASE 
			WHEN patindex(''%Exception%'', [Message]) > 0 and (patindex(''%--->%'', [Message])  - patindex(''%Exception%'', [Message])) > 0 THEN ''#F0C6AA''
			WHEN [RunStatus] = 0 THEN ''Critical''
			WHEN [RunStatus] = 1 THEN ''WhiteSmoke''
			WHEN [RunStatus] = 2 THEN ''#F9E79F''	
			WHEN [RunStatus] = 3 THEN ''#A9DFBF''				
			WHEN [RunStatus] = 4 THEN ''WhiteSmoke''	
			ELSE ''#E6B0AA''
		END as StatusColor
      ,[Message]	as Details   
      ,[RunDate]
      ,[RunDurationMS] * 1000 as [RunDurationMS]
	  ,CASE 
			WHEN [RunStatus] = 0 THEN ''Failed, please review the logs to see what error has occurred.''
			WHEN [RunStatus] = 2 THEN ''Failed and a retry attempt has been made.'' 
			WHEN [RunStatus] = 3 THEN ''Manually cancelled please review the logs and see who cancelled it.''
			WHEN patindex(''%Exception%'', [Message]) > 0 and (patindex(''%--->%'', [Message])  - patindex(''%Exception%'', [Message])) > 0 THEN substring([Message], patindex(''%Exception%'', [Message]), (patindex(''%--->%'', [Message])  - patindex(''%Exception%'', [Message])))
			ELSE NULL
		END as ErrorDetail
  FROM [Inst].[JobHistory]
' 
GO
/****** Object:  View [dbo].[vwCTEGetAgentJobHistoryStepCount]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetAgentJobHistoryStepCount]'))
EXEC dbo.sp_executesql @statement = N'  CREATE VIEW [dbo].[vwCTEGetAgentJobHistoryStepCount]
  as
  SELECT ajh.ServerName, ajh.InstanceName, ajh.JobName, ajh.JobID, ajh.Status, ajh.[RunDate], isnull(x.CountTotalSteps, 0) as CountTotalSteps, isnull(x.CountSuccessfulSteps,0) as CountSuccessfulSteps, isnull(x.CountFailedSteps,0) as CountFailedSteps
  FROM vwCTEGetAgentJobHistoryRaw ajh
  LEFT OUTER JOIN
  (
	SELECT COUNT(StepID) CountTotalSteps, SUM(case when Status = ''Informational'' then 1 else 0 end) as CountSuccessfulSteps, SUM(CASE WHEN [Status] != ''Informational'' THEN 1 ELSE 0 END) as CountFailedSteps, ServerName, InstanceName, JobID, RunDate
	FROM vwCTEGetAgentJobHistoryRaw x 
	WHERE x.StepID != 0
	GROUP BY ServerName, InstanceName, JobID, RunDate 
  ) x on x.ServerName = ajh.ServerName and  x.InstanceName = ajh.InstanceName and x.JobID = ajh.JobID and x.[RunDate] = ajh.[RunDate]
  WHERE ajh.StepID = 0
' 
GO
/****** Object:  View [dbo].[vwCTEGetBackup14DayList]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetBackup14DayList]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCTEGetBackup14DayList]
as
    SELECT BackupDate, InstanceName, DBName, BackupTypeDesciption, COUNT(DISTINCT BackupSetGUID) as CountBackup,
  (CASE WHEN BackupTypeDesciption = ''Log'' THEN 96
		WHEN BackupTypeDesciption = ''Full Database'' THEN 1
		ELSE 96 END - COUNT(DISTINCT BackupSetGUID)) * -1 as MissingCount
  FROM DB.DatabaseBackups 
  WHERE BackupDate between dateadd(day, -8, getDate()) and  dateadd(day, -1, getDate()) 
  GROUP BY BackupDate, InstanceName, DBName, BackupTypeDesciption
' 
GO
/****** Object:  View [dbo].[vwCTEGetBackupDatabaseListByDatabase]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetBackupDatabaseListByDatabase]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCTEGetBackupDatabaseListByDatabase]
as
  SELECT BackupDate, replace(InstanceName, ''\'', ''\'') as InstanceName
  , DBName
  , RecoveryModel
  , BackupTypeDesciption
  , COUNT(DISTINCT BackupSetGUID) CountBackup 
  , CASE 
	WHEN RecoveryModel = ''FULL'' and BackupTypeDesciption = ''Full Database'' THEN 1
	WHEN RecoveryModel = ''FULL'' and BackupTypeDesciption = ''Log'' THEN 96
	WHEN RecoveryModel = ''BULK-LOGGED'' and BackupTypeDesciption = ''Full Database'' THEN 1
	WHEN RecoveryModel = ''BULK-LOGGED'' and BackupTypeDesciption = ''Log'' THEN 96
	WHEN RecoveryModel = ''SIMPLE'' and BackupTypeDesciption = ''Full Database'' THEN 1
	WHEN RecoveryModel = ''SIMPLE'' and BackupTypeDesciption = ''Log'' THEN 0
	end - COUNT(DISTINCT BackupSetGUID) as MissingCount
  ,SUM(CompressedBackupSize)/1024.0/1024.0 * 1.0 SumCompressedBackupSizeMB
  ,SUM(BackupSize)/1024.0/1024.0  * 1.0			 SumUncompressedBackupSizeMB
  ,ROUND(((SUM(BackupSize) - SUM(CompressedBackupSize)) / SUM(BackupSize)) * 100.0, 2) PercentageBackupSaved
  FROM DB.DatabaseBackups  
  WHERE BackupDate between dateadd(day, -15, getDate()) and  dateadd(day, -1, getDate()) 
  GROUP BY BackupDate, InstanceName, DBName, RecoveryModel, BackupTypeDesciption
' 
GO
/****** Object:  Table [DB].[DatabaseInfo]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DB].[DatabaseInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [DB].[DatabaseInfo](
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NOT NULL,
	[DBName] [nvarchar](128) NULL,
	[DBStatus] [nvarchar](20) NULL,
	[DBOwner] [nvarchar](128) NULL,
	[DBCreateDate] [smalldatetime] NULL,
	[DBSizeInMB] [decimal](10, 2) NULL,
	[DBSpaceAvailableInMB] [decimal](10, 2) NULL,
	[DBUsedSpaceInMB] [decimal](10, 2) NULL,
	[DBPctFreeSpace] [nvarchar](10) NULL,
	[DBDataSpaceUsageInMB] [decimal](10, 2) NULL,
	[DBIndexSpaceUsageInMB] [decimal](10, 2) NULL,
	[ActiveConnections] [int] NULL,
	[Collation] [nvarchar](30) NULL,
	[RecoveryModel] [nvarchar](10) NULL,
	[CompatibilityLevel] [nvarchar](30) NULL,
	[PrimaryFilePath] [nvarchar](256) NULL,
	[LastBackupDate] [nvarchar](128) NULL,
	[LastDifferentialBackupDate] [nvarchar](128) NULL,
	[LastLogBackupDate] [nvarchar](128) NULL,
	[AutoShrink] [bit] NULL,
	[AutoUpdateStatisticsEnabled] [bit] NULL,
	[IsReadCommittedSnapshotOn] [bit] NULL,
	[IsFullTextEnabled] [bit] NULL,
	[BrokerEnabled] [bit] NULL,
	[ReadOnly] [bit] NULL,
	[EncryptionEnabled] [bit] NULL,
	[IsDatabaseSnapshot] [bit] NULL,
	[ChangeTrackingEnabled] [bit] NULL,
	[IsMirroringEnabled] [bit] NULL,
	[MirroringPartnerInstance] [nvarchar](128) NULL,
	[MirroringStatus] [nvarchar](30) NULL,
	[MirroringSafetyLevel] [nvarchar](30) NULL,
	[ReplicationOptions] [nvarchar](30) NULL,
	[AvailabilityGroupName] [nvarchar](128) NULL,
	[NoOfTbls] [int] NULL,
	[NoOfViews] [smallint] NULL,
	[NoOfStoredProcs] [smallint] NULL,
	[NoOfUDFs] [smallint] NULL,
	[NoOfLogFiles] [tinyint] NULL,
	[NoOfFileGroups] [tinyint] NULL,
	[NoOfUsers] [smallint] NULL,
	[NoOfDBTriggers] [tinyint] NULL,
	[LastGoodDBCCCheckDB] [nvarchar](128) NULL,
	[AutoClose] [bit] NULL,
	[HasFileInCloud] [bit] NULL,
	[HasMemoryOptimizedObjects] [bit] NULL,
	[MemoryAllocatedToMemoryOptimizedObjectsInKB] [decimal](20, 2) NULL,
	[MemoryUsedByMemoryOptimizedObjectsInKB] [decimal](20, 2) NULL,
	[DateAdded] [smalldatetime] NULL,
	[DBID] [int] IDENTITY(1,1) NOT NULL
) ON [DB]
END
GO
/****** Object:  View [dbo].[vwCTEGetDatabaseList]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetDatabaseList]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwCTEGetDatabaseList]
as
with CTEGetDatabaseList
as
(
SELECT 
	  ServerName
	, REPLACE(InstanceName, '''', '''') as InstanceName 
	, DBName
	, MAX(DateAdded) LastUpdatedDate
FROM 
	db.DatabaseInfo 
WHERE 
	DateAdded >= dateadd(day, -15, getDate()) --LAST 16 Days
	and 
	DBName != ''tempdb''
GROUP By 
	  ServerName
	, InstanceName
	, DBName
)
SELECT cdl.*, di.RecoveryModel FROM CTEGetDatabaseList cdl
INNER JOIN DB.DatabaseInfo di on di.DateAdded = cdl.LastUpdatedDate and di.DBName = cdl.DBName and di.ServerName = cdl.ServerName
' 
GO
/****** Object:  View [dbo].[vwCTEGetDatabaseLogBackupHealth]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetDatabaseLogBackupHealth]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwCTEGetDatabaseLogBackupHealth]
as
SELECT vwCTEGetDatabaseList.*, --COUNT(BackupStartDate), dateadd(hour, -24, vwCTEGetDatabaseList.LastUpdatedDate), --CAST(BackupStartDate as DATE),
	CASE WHEN COUNT(BackupStartDate) >= 96 THEN ''Healthy''
		 WHEN COUNT(BackupStartDate) BETWEEN 92 and 96 THEN ''UnHealthy''
		 WHEN COUNT(BackupStartDate) BETWEEN 80 and 92 THEN ''Warning''
		 ELSE ''Error''
		 END as HealthLevel
	,CASE WHEN COUNT(BackupStartDate) >= 96 THEN ''''
		 WHEN COUNT(BackupStartDate) BETWEEN 92 and 96 THEN ''UnHealthy | Up to an hour we are missing; we are missing up to 4 log files.''
		 WHEN COUNT(BackupStartDate) BETWEEN 80 and 92 THEN ''Warning |  Up to 4 hours we are missing; we are missing up to 16 log files.''
		 ELSE ''Error | More than 4 hours are missing; we are missing more then 16 log files.''
		 END as HealthDetail
FROM vwCTEGetDatabaseList
LEFT OUTER JOIN DB.DatabaseBackups 
	ON vwCTEGetDatabaseList.InstanceName = DB.DatabaseBackups.InstanceName
	AND vwCTEGetDatabaseList.DBName = DB.DatabaseBackups.DBName
	AND DB.DatabaseBackups.BackupTypeCode = ''L'' 
	AND DB.DatabaseBackups.BackupStartDate > dateadd(hour, -24, vwCTEGetDatabaseList.LastUpdatedDate) --LAST 24 Hours
WHERE
	vwCTEGetDatabaseList.RecoveryModel != ''SIMPLE''
GROUP BY 	  
  vwCTEGetDatabaseList.ServerName
, vwCTEGetDatabaseList.InstanceName
, vwCTEGetDatabaseList.DBName
, vwCTEGetDatabaseList.RecoveryModel
, vwCTEGetDatabaseList.LastUpdatedDate
' 
GO
/****** Object:  Table [FRK].[Blitz]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FRK].[Blitz]') AND type in (N'U'))
BEGIN
CREATE TABLE [FRK].[Blitz](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[Priority] [tinyint] NULL,
	[FindingsGroup] [varchar](50) NULL,
	[Finding] [varchar](200) NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[URL] [varchar](200) NULL,
	[Details] [nvarchar](4000) NULL,
	[QueryPlan] [xml] NULL,
	[QueryPlanFiltered] [nvarchar](max) NULL,
	[CheckID] [int] NULL,
	[VulnerabilityStatus] [nvarchar](30) NULL,
	[VulnerabilityRank] [int] NULL,
 CONSTRAINT [PK_Blitz] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FRK]
) ON [FRK] TEXTIMAGE_ON [FRK]
END
GO
/****** Object:  View [dbo].[vwCTEGetFRKBlitzHeatMap]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKBlitzHeatMap]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwCTEGetFRKBlitzHeatMap]
as
SELECT
	 b1.ServerName
	--,SUM(ABS(255 - b1.Priority)) TotalPriority
	,SUM(b1.Priority/2.0) TotalPriority
FROM
	[FRK].[Blitz] b1
INNER JOIN
(
SELECT 
	 ServerName
	,MAX(CheckDate) MaxCheckDate
FROM 
	[FRK].[Blitz]
GROUP BY
	 ServerName
) b2 on b2.ServerName = b1.ServerName 
	and b2.MaxCheckDate = b1.CheckDate 
WHERE
	b1.CheckID not in (156, -1, 1031, 1073, 1072, 1071, 1049, 1057)
	and
	b1.FindingsGroup not in (''Server Info'', ''Monitoring'')
	and
	b1.Finding not in (''No Significant Waits Detected'')
	and
	b1.Details not in 
	(
		''This sp_configure option has been changed.  Its default value is 5 and it has been set to 50.'',
		''Trace flag 3226 is enabled globally.'',
		''Trace flag 1117 is enabled globally.'',
		''Trace flag 1118 is enabled globally.'',
		''Trace flag 2371 is enabled globally.'',
		''This sp_configure option has been changed.  Its default value is 10 and it has been set to 60.'',
		''Collation differences between user databases and tempdb can cause conflicts especially when comparing string values''
	)
GROUP BY
	b1.ServerName
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKBlitzHeatMapDetails]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKBlitzHeatMapDetails]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwCTEGetFRKBlitzHeatMapDetails]
as
SELECT
	 b1.*
	,(ABS(255 - b1.Priority)) InvertedPriority
FROM
	[FRK].[Blitz] b1
INNER JOIN
(
SELECT 
	 ServerName
	,MAX(CheckDate) MaxCheckDate
FROM 
	[FRK].[Blitz]
GROUP BY
	 ServerName

) b2 on b2.ServerName = b1.ServerName 
	and b2.MaxCheckDate = b1.CheckDate 
WHERE
	b1.CheckID not in (156, -1, 1031, 1073, 1072, 1071, 1049, 1057) 
	and
	b1.FindingsGroup not in (''Server Info'', ''Monitoring'')
	and
	b1.Finding not in (''No Significant Waits Detected'')
	and
	b1.Details not in 
	(
		''This sp_configure option has been changed.  Its default value is 5 and it has been set to 50.'',
		''Trace flag 3226 is enabled globally.'',
		''Trace flag 1117 is enabled globally.'',
		''Trace flag 1118 is enabled globally.'',
		''Trace flag 2371 is enabled globally.'',
		''This sp_configure option has been changed.  Its default value is 10 and it has been set to 60.'',
		''Collation differences between user databases and tempdb can cause conflicts especially when comparing string values''
	)
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKFindingsSQLVersionInfo]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKFindingsSQLVersionInfo]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCTEGetFRKFindingsSQLVersionInfo]
as
SELECT ii.InstanceName, ii.SQLVersion + '' ('' + ii.SQLVersionNo + '')'' + char(10) + ii.SQLEdition SQLVersionInfo, b.Finding
FROM
(
	SELECT ii.SQLVersion, ii.SQLEdition, ii.SQLVersionNo, CASE WHEN sl.InstanceName = '''' then sl.ServerName ELSE sl.InstanceName END InstanceName
	FROM
		Inst.InstanceInfo ii 
	INNER JOIN
		(SELECT ServerName, MAX(dateadded) DateAdded FROM Inst.InstanceInfo GROUP BY ServerName) y 
		ON y.DateAdded = ii.DateAdded and y.ServerName = ii.ServerName
	INNER JOIN
		Svr.ServerList sl on sl.ServerName = ii.ServerName
) ii 
LEFT OUTER JOIN 
(
	SELECT b.ServerName, b.Finding 
	FROM [FRK].[Blitz] b
	INNER JOIN
	(SELECT ServerName, MAX(CheckDate) CheckDate FROM [FRK].[Blitz] GROUP BY ServerName) x 
	on x.ServerName = b.ServerName and b.CheckDate = x.CheckDate
	WHERE b.Finding like ''%Unsupported%''
) b on ii.InstanceName = b.ServerName
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKVulnerabilityRaw]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKVulnerabilityRaw]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCTEGetFRKVulnerabilityRaw]
as
SELECT
	VulnerabilityStatus as Status,

CASE 
	WHEN VulnerabilityRank <= 5 THEN ''WhiteSmoke''
	WHEN VulnerabilityRank Between 6 and 128 THEN ''#A9DFBF''
	WHEN VulnerabilityRank Between 129 and 256 THEN ''#F9E79F''
	WHEN VulnerabilityRank Between 257 and 512 THEN ''#F0C6AA''
	ELSE ''#E6B0AA''
END as StatusColor, 
	b.ServerName, FindingsGroup, Finding, DatabaseName, Details, VulnerabilityRank as Priority, CheckID, b.CheckDate
FROM FRK.Blitz b
' 
GO
/****** Object:  View [dbo].[vwDatabaseBackupSize]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDatabaseBackupSize]'))
EXEC dbo.sp_executesql @statement = N'create view [dbo].[vwDatabaseBackupSize]
as
SELECT 
	 ServerName
	,InstanceName
	,DBName
	,BackupSize
	,BackupTypeCode
	,[BackupStartDate]
	,CompressedBackupSize
	,BackupDurationMS
	,DateAdded
	,count([BackupSetGUID]) FileCount
	,(CompressedBackupSize)/1024.0/1024.0 BackupSizeMB
FROM
	[DB].[DatabaseBackups] y
WHERE
	DBID in
(
	SELECT
		DBID
	FROM
		[DB].[DatabaseBackups] y
	INNER JOIN
	(
	SELECT 
		InstanceName, 
		DBName, 
		Max(DateAdded)  as MaxDateAdded
	FROM [DB].[DatabaseBackups] 
	GROUP BY 
		InstanceName, 
		DBName
	) x on x.InstanceName = y.InstanceName
		and
		x.DBName = y.DBName
		and
		x.MaxDateAdded = y.DateAdded
)
group by
	 ServerName
	,InstanceName
	,DBName
	,BackupSize
	,BackupTypeCode
	,[BackupStartDate]
	,CompressedBackupSize
	,BackupDurationMS
	,DateAdded
' 
GO
/****** Object:  View [dbo].[vwFRKBlitzLatestCollectionByServerName]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwFRKBlitzLatestCollectionByServerName]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwFRKBlitzLatestCollectionByServerName]
WITH SCHEMABINDING
AS 
SELECT ServerName, MAX(CheckDate) CheckDate 
FROM [FRK].[Blitz] 
GROUP BY ServerName
' 
GO
/****** Object:  View [dbo].[vwGETBlitzCurrent]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGETBlitzCurrent]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwGETBlitzCurrent]
as
SELECT y.* FROM FRK.Blitz y
INNER JOIN (SELECT MAX(CheckDate) MaxCheckDate, ServerName FROM FRK.Blitz GROUP BY ServerName) x 
on x.ServerName = y.ServerName and x.MaxCheckDate = y.CheckDate
' 
GO
/****** Object:  View [dbo].[vwGETDatabaseAvgSizePerMonth]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGETDatabaseAvgSizePerMonth]'))
EXEC dbo.sp_executesql @statement = N'
create view [dbo].[vwGETDatabaseAvgSizePerMonth]
as
SELECT ServerName, InstanceName, DBName, AVG(DBSizeInMB) AllocatedSpaceInMB, AVG(DBUsedSpaceInMB) UsedSpaceInMB, convert(varchar(7), DateAdded, 120) as DateSummary
FROM db.DatabaseInfo di
GROUP BY ServerName, InstanceName, DBName, convert(varchar(7), DateAdded, 120)
' 
GO
/****** Object:  View [dbo].[vwGETDatabaseInfoCurrent]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGETDatabaseInfoCurrent]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwGETDatabaseInfoCurrent]
as
SELECT y.* FROM DB.DatabaseInfo y
INNER JOIN (SELECT MAX(DateAdded) MaxDateAdded, ServerName, InstanceName FROM DB.DatabaseInfo GROUP BY ServerName, InstanceName) x 
on x.InstanceName = y.InstanceName and x.ServerName = y.ServerName and x.MaxDateAdded = y.DateAdded
' 
GO
/****** Object:  View [dbo].[vwGetFRKDataCenterSQLServerCounts]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGetFRKDataCenterSQLServerCounts]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwGetFRKDataCenterSQLServerCounts]
as
SELECT
  COUNT(DBName) DatabaseCount,
  COUNT(DISTINCT di.ServerName) ServerName,
  SUM(DBSizeInMB)/1024.0 TotalGBDBSize,
  SUM(DBUsedSpaceInMB)/1024.0 TotalGBDBUsedSize
FROM db.DatabaseInfo di
INNER JOIN
(
	SELECT ServerName, Max(DateAdded) DateAdded
	FROM db.DatabaseInfo 
	GROUP BY ServerName
) x on x.ServerName = di.ServerName and x.DateAdded = di.DateAdded and x.DateAdded > dateadd(day, -1, getdate())
INNER JOIN
svr.ServerList sl on sl.ServerName = di.ServerName
' 
GO
/****** Object:  View [dbo].[vwSVRServerListActiveOnly]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSVRServerListActiveOnly]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwSVRServerListActiveOnly]
as
SELECT 
		ServerName
	  , CASE WHEN len(InstanceName) = 0 THEN ServerName ELSE InstanceName END As InstanceName 
	  ,[Environment]
      ,[VNNName]
      ,[Inventory]
      ,[Baseline]
      ,[WaitStat]
      ,[Vulnerability]
      ,[MaintBackup]
      ,[MaintDBCC]
      ,[MaintIndex]
      ,[SQLPing]
      ,[Decomissioned]
      ,[SQLLicenseType]
      ,[Sector]
      ,[Ministry]
      ,[Division]
      ,[Branch]
      ,[Description]
      ,[BusinessOwner]
      ,[BusinessOwner2]
      ,[TechnicalOwner]
      ,[TechnicalOwner2]
      ,[InventoryLastExecDate]
      ,[BaselineLastExecDate]
      ,[WaitStatLastExecDate]
      ,[VulnerabilityLastExecDate]
      ,[MaintBkFullLastExecDate]
      ,[MaintBkLogLastExecDate]
      ,[MaintIndexLastExecDate]
      ,[MaintIndexStatsLastExecDate]
      ,[MaintDBCCLastExecDate]
      ,[DateAdded]
      ,[AddedBy]
      ,[DateModified]
      ,[ModifiedBy]
FROM [svr].ServerList
WHERE Decomissioned = 0
' 
GO
/****** Object:  View [dbo].[vwGetFRKDataCenterSQLServerCountsHistory]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGetFRKDataCenterSQLServerCountsHistory]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwGetFRKDataCenterSQLServerCountsHistory]
as
SELECT TOP 100 PERCENT COUNT(DISTINCT ServerName) ServerNameCount, COUNT(DBName) DatabaseCount,  SUM(TotalGBDBSize) TotalGBDBSize,  SUM(TotalGBDBUsedSize) TotalGBDBUsedSize, DateAdded
FROM
(
SELECT ServerName, DBName, round(DBSizeInMB/1024.0, 2) TotalGBDBSize, round(DBUsedSpaceInMB/1024.0, 2) TotalGBDBUsedSize, CAST(DateAdded as DATE) DateAdded, ROW_NUMBER() over (partition by ServerName, DBName, CAST(DateAdded as DATE) ORDER BY DateAdded desc) RowID
FROM db.DatabaseInfo 
WHERE DateAdded >= dateadd(day, -14, getdate())
) x 
WHERE RowID = 1
GROUP BY CAST(DateAdded as DATE)
ORDER BY DateAdded
' 
GO
/****** Object:  View [dbo].[vwGETFRKSecurityFindingsRaw]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGETFRKSecurityFindingsRaw]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwGETFRKSecurityFindingsRaw]
AS
SELECT 
	Status, StatusColor, ServerName, FindingsGroup, Finding, DatabaseName, Details, Priority, CheckID, CheckDate 
FROM 
	[dbo].[vwCTEGetFRKVulnerabilityRaw]
WHERE 
	FindingsGroup = ''Security''
' 
GO
/****** Object:  View [dbo].[vwGetFRKVulnerabilityHistory]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGetFRKVulnerabilityHistory]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwGetFRKVulnerabilityHistory]
as
SELECT TOP 100 PERCENT
	 SUM(CASE WHEN [Status] = ''Critical'' THEN 1 ELSE 0 END) Critical
	,SUM(CASE WHEN [Status] = ''Severe'' THEN 1 ELSE 0 END) Severe
	,SUM(CASE WHEN [Status] = ''Moderate'' THEN 1 ELSE 0 END) Moderate
	,SUM(CASE WHEN [Status] = ''Low'' THEN 1 ELSE 0 END) Low
	,SUM(CASE WHEN [Status] = ''Informational'' THEN 1 ELSE 0 END) Informational
	,CAST(CheckDate as DATE) CheckDate
FROM [dbo].[vwCTEGetFRKVulnerabilityRaw]
WHERE CAST(CheckDate as DATE) >= dateadd(day, -14, getdate())
GROUP BY CAST(CheckDate as DATE)
ORDER BY CheckDate
' 
GO
/****** Object:  View [dbo].[vwGETInstanceInfoCurrent]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGETInstanceInfoCurrent]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwGETInstanceInfoCurrent]
as
SELECT y.* FROM Inst.InstanceInfo y
INNER JOIN (SELECT MAX(DateAdded) MaxDateAdded, ServerName, InstanceName FROM Inst.InstanceInfo GROUP BY ServerName, InstanceName) x 
on x.InstanceName = y.InstanceName and x.ServerName = y.ServerName and x.MaxDateAdded = y.DateAdded
' 
GO
/****** Object:  Table [Inst].[CommandLog]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[CommandLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[CommandLog](
	[DatabaseName] [sysname] NULL,
	[SchemaName] [sysname] NULL,
	[ObjectName] [sysname] NULL,
	[ObjectType] [char](2) NULL,
	[IndexName] [sysname] NULL,
	[IndexType] [tinyint] NULL,
	[StatisticsName] [sysname] NULL,
	[PartitionNumber] [int] NULL,
	[ExtendedInfo] [nvarchar](max) NULL,
	[Command] [nvarchar](max) NOT NULL,
	[CommandType] [nvarchar](60) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[ErrorNumber] [int] NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[ServerName] [sysname] NULL,
	[Type] [varchar](255) NULL,
	[BatchGUID] [uniqueidentifier] NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateModified] [datetime] NOT NULL,
	[TimeTakenMS]  AS (datediff(millisecond,[StartTime],[EndTime])) PERSISTED,
	[TimeTaken]  AS (CONVERT([varchar],dateadd(millisecond,datediff(millisecond,[StartTime],[EndTime]),(0)),(114))) PERSISTED,
	[CommandLogID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_CommandLog_ID] PRIMARY KEY CLUSTERED 
(
	[CommandLogID] ASC,
	[CommandType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Inst]
) ON [Inst] TEXTIMAGE_ON [Inst]
END
GO
/****** Object:  View [dbo].[vwGetInstCommandLogDetails]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGetInstCommandLogDetails]'))
EXEC dbo.sp_executesql @statement = N'/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[vwGetInstCommandLogDetails]
as
SELECT *
  FROM [Inst].[CommandLog]
' 
GO
/****** Object:  View [dbo].[vwGETOSInfoCurrent]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGETOSInfoCurrent]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwGETOSInfoCurrent]
as
SELECT y.* FROM Svr.OSInfo y
INNER JOIN (SELECT MAX(DateAdded) MaxDateAdded, ServerName FROM Svr.OSInfo GROUP BY ServerName) x 
on x.ServerName = y.ServerName and x.MaxDateAdded = y.DateAdded
' 
GO
/****** Object:  View [dbo].[vwGETServerInfoCurrent]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGETServerInfoCurrent]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwGETServerInfoCurrent]
as
SELECT y.* FROM Svr.ServerInfo y
INNER JOIN (SELECT MAX(DateAdded) MaxDateAdded, ServerName FROM Svr.ServerInfo GROUP BY ServerName) x 
on x.ServerName = y.ServerName and x.MaxDateAdded = y.DateAdded
' 
GO
/****** Object:  Table [Inst].[Logins]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[Logins]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[Logins](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[LoginName] [nvarchar](128) NULL,
	[LoginType] [nvarchar](20) NULL,
	[LoginCreateDate] [nvarchar](50) NULL,
	[LoginLastModified] [nvarchar](50) NULL,
	[IsDisabled] [bit] NULL,
	[IsLocked] [bit] NULL,
	[DateAdded] [smalldatetime] NULL,
	[LoginID] [int] IDENTITY(1,1) NOT NULL
) ON [Inst]
END
GO
/****** Object:  Table [Inst].[InstanceRoles]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[InstanceRoles]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[InstanceRoles](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[LoginName] [nvarchar](128) NULL,
	[RoleName] [nvarchar](128) NULL,
	[DateAdded] [smalldatetime] NULL,
	[InstRID] [int] IDENTITY(1,1) NOT NULL
) ON [Inst]
END
GO
/****** Object:  View [dbo].[vwInstanceLoginAndRoleList]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInstanceLoginAndRoleList]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwInstanceLoginAndRoleList]
AS
SELECT DISTINCT
	 ir.InstanceName
	,ir.RoleName
	,l.LoginName
	,l.LoginType
	,isnull(l.IsLocked, 0) IsLocked
	,l.IsDisabled
	,sl.Environment
FROM Inst.InstanceRoles ir
INNER JOIN Inst.Logins l ON l.LoginName = ir.LoginName and l.InstanceName = ir.InstanceName and l.DateAdded = ir.DateAdded
INNER JOIN Svr.ServerList sl on sl.InstanceName = ir.InstanceName
WHERE 
 ir.DateAdded in (SELECT DISTINCT MaxDateAdded FROM (SELECT MAX(ir.DateAdded) MaxDateAdded, ir.LoginName FROM inst.InstanceRoles ir GROUP BY ir.LoginName) x)
' 
GO
/****** Object:  View [dbo].[vwSQLServerCountBackupsPerDayByHour]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSQLServerCountBackupsPerDayByHour]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwSQLServerCountBackupsPerDayByHour]
as
WITH 
cteLast14Days
as
(
	SELECT CAST(dateadd(day, -1, getDate()) as DATE) as DateRange, -1 as DateAddVal
	union all
	SELECT dateadd(day, -1, DateRange), DateAddVal - 1 FROM cteLast14Days
	WHERE
		DateAddVal > -15
)
,Pivoted
AS
(
    SELECT *
    FROM
    (
		SELECT DISTINCT
			 ServerName	
			,InstanceName	
			,DBName
			,BackupTypeDesciption	
			,BackupStartDate	
			,RIGHT (''00'' + lTRIM(STR(DATEPART(HH, BackupStartDate))), 2) AS BackupHour
			,BackupSize
		FROM 
			db.DatabaseBackups
		WHERE 
			CONVERT(DATE, BackupStartDate) in (SELECT DateRange FROM cteLast14Days)
    ) a
    PIVOT 
	(
       COUNT(BackupHour)
       FOR BackupHour IN ([00],[01],[02],[03],[04],[05],[06], [07], [08],[09],[10],[11],[12],[13], [14],[15],[16],[17],[18],[19],[20],[21],[22],[23])
    ) bkups
)
 SELECT
    ServerName,
	InstanceName,
    DBName,
    BackupTypeDesciption,
	CONVERT(DATE, BackupStartDate) as BackupDate,
    COUNT(1) AS TotalBackupCount,
    SUM(DISTINCT BackupSize)/1024/1024 AS Total_Size_MB,
    SUM([00]) AS [00], SUM([01]) AS [01], SUM([02]) AS [02], SUM([03]) AS [03], SUM([04]) AS [04], SUM([05]) AS [05],
    SUM([06]) AS [06], SUM([07]) AS [07], SUM([08]) AS [08], SUM([09]) AS [09], SUM([10]) AS [10], SUM([11]) AS [11],
    SUM([12]) AS [12], SUM([13]) AS [13], SUM([14]) AS [14], SUM([15]) AS [15], SUM([16]) AS [16], SUM([17]) AS [17],
    SUM([18]) AS [18], SUM([19]) AS [19], SUM([20]) AS [20], SUM([21]) AS [21], SUM([22]) AS [22], SUM([23]) AS [23]
FROM Pivoted
GROUP BY
	ServerName,
	InstanceName,
	DBName,
	BackupTypeDesciption,
	CONVERT(DATE, BackupStartDate)
--ORDER BY
--	ServerName,
--	InstanceName,
--	DBName,
--	BackupTypeDesciption,
--    BackupDate DESC
' 
GO
/****** Object:  View [dbo].[vwCTEGetDatabaseFullBackupHealth]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetDatabaseFullBackupHealth]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwCTEGetDatabaseFullBackupHealth]
as
SELECT vwCTEGetDatabaseList.*,
	CASE WHEN datediff(hour, vwCTEGetDatabaseList.LastUpdatedDate, MAX(BackupStartDate)) <= 24 THEN ''Healthy''
		 WHEN datediff(hour, vwCTEGetDatabaseList.LastUpdatedDate, MAX(BackupStartDate)) BETWEEN 24 and 48 THEN ''UnHealthy''
		 WHEN datediff(hour, vwCTEGetDatabaseList.LastUpdatedDate, MAX(BackupStartDate)) BETWEEN 48 and 72 THEN ''Warning''
		 ELSE ''Error''
		 END as HealthLevel
	,CASE WHEN datediff(hour, vwCTEGetDatabaseList.LastUpdatedDate, MAX(BackupStartDate)) <= 24 THEN ''''
		 WHEN datediff(hour, vwCTEGetDatabaseList.LastUpdatedDate, MAX(BackupStartDate)) BETWEEN 24 and 48 THEN ''UnHealthy | Up to 48 hours of data loss could occur.''
		 WHEN datediff(hour, vwCTEGetDatabaseList.LastUpdatedDate, MAX(BackupStartDate)) BETWEEN 80 and 92 THEN ''Warning | Up to 72 hours of data loss could occur.''
		 ELSE ''Error | Up to '' + isnull(CAST(datediff(hour, vwCTEGetDatabaseList.LastUpdatedDate, MAX(BackupStartDate)) as varchar(3)), ''UNKNOWN'') + '' hours of data loss could occur.'' 
		 END as HealthDetail
FROM vwCTEGetDatabaseList
LEFT OUTER JOIN DB.DatabaseBackups 
	ON vwCTEGetDatabaseList.InstanceName = DB.DatabaseBackups.InstanceName
	AND vwCTEGetDatabaseList.DBName = DB.DatabaseBackups.DBName
	AND DB.DatabaseBackups.BackupTypeCode = ''D'' 
	AND DB.DatabaseBackups.BackupStartDate > dateadd(hour, -168, vwCTEGetDatabaseList.LastUpdatedDate) --LAST 24 Hours
GROUP BY 	  
  vwCTEGetDatabaseList.ServerName
, vwCTEGetDatabaseList.InstanceName
, vwCTEGetDatabaseList.DBName
, vwCTEGetDatabaseList.RecoveryModel
, vwCTEGetDatabaseList.LastUpdatedDate
' 
GO
/****** Object:  Table [DB].[AvailReplicas]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DB].[AvailReplicas]') AND type in (N'U'))
BEGIN
CREATE TABLE [DB].[AvailReplicas](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[ReplicaName] [nvarchar](128) NULL,
	[AGName] [nvarchar](128) NULL,
	[Role] [nvarchar](60) NULL,
	[AvailabilityMode] [nvarchar](60) NULL,
	[FailoverMode] [nvarchar](60) NULL,
	[SessionTimeout] [int] NULL,
	[ConnectionsInPrimaryRole] [nvarchar](60) NULL,
	[ReadableSecondary] [nvarchar](60) NULL,
	[EndpointUrl] [nvarchar](128) NULL,
	[BackupPriority] [int] NULL,
	[AGCreateDate] [smalldatetime] NULL,
	[AGModifyDate] [smalldatetime] NULL,
	[DateAdded] [smalldatetime] NULL,
	[AGRPID] [int] IDENTITY(1,1) NOT NULL
) ON [DB]
END
GO
/****** Object:  Table [DB].[AvailDatabases]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DB].[AvailDatabases]') AND type in (N'U'))
BEGIN
CREATE TABLE [DB].[AvailDatabases](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[AGDBName] [nvarchar](128) NULL,
	[AGName] [nvarchar](128) NULL,
	[PrimaryReplica] [nvarchar](128) NULL,
	[SyncState] [nvarchar](60) NULL,
	[SyncHealth] [nvarchar](60) NULL,
	[DBState] [nvarchar](60) NULL,
	[IsSuspended] [bit] NULL,
	[SuspendReason] [nvarchar](60) NULL,
	[AGDBCreateDate] [smalldatetime] NULL,
	[DateAdded] [smalldatetime] NULL,
	[AGDBID] [int] IDENTITY(1,1) NOT NULL
) ON [DB]
END
GO
/****** Object:  View [dbo].[vwCTEGetDatabaseFullBackupHealth14Days]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetDatabaseFullBackupHealth14Days]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwCTEGetDatabaseFullBackupHealth14Days]
as
SELECT 
	vwCTEGetDatabaseList.ServerName, 
	vwCTEGetDatabaseList.InstanceName, 
	vwCTEGetDatabaseList.DBName, 
	vwCTEGetDatabaseList.RecoveryModel, 
	vwCTEGetDatabaseList.LastUpdatedDate, 
	CASE WHEN COUNT(DISTINCT DB.DatabaseBackups.BackupSetGUID) >= 13 THEN ''Healthy''
		 WHEN AON.Role = ''SECONDARY'' THEN ''Healthy''
		 WHEN COUNT(DISTINCT DB.DatabaseBackups.BackupSetGUID) BETWEEN 11 and 13 THEN ''UnHealthy''
		 WHEN datediff(hour, vwCTEGetDatabaseList.LastUpdatedDate, GETDATE()) > 24 THEN ''UnHealthy''	
		 WHEN COUNT(DISTINCT DB.DatabaseBackups.BackupSetGUID) BETWEEN 8 and 11 THEN ''Warning''		 	 
		 ELSE ''Error''
		 END as HealthLevel
	,CASE WHEN COUNT(DISTINCT DB.DatabaseBackups.BackupSetGUID) >= 13 THEN ''''
		  WHEN AON.Role = ''SECONDARY'' THEN ''Secondary role detected in AlwaysOn; Primary usually handle full backups.''
		  WHEN datediff(hour, vwCTEGetDatabaseList.LastUpdatedDate, GETDATE()) > 24 THEN ''CentralDB inventory collection has not run recently, last run was '' + ISNULL(CONVERT(VARCHAR(30), MAX(LastUpdatedDate), 120), ''never'') + ''.''
		  WHEN COUNT(DISTINCT DB.DatabaseBackups.BackupSetGUID) BETWEEN 11 and 13 THEN ''Last successful backup was '' + ISNULL(CONVERT(VARCHAR(30), MAX(BackupStartDate), 120), ''never'') + '', up to 3 days of data loss could occur.''
		  WHEN COUNT(DISTINCT DB.DatabaseBackups.BackupSetGUID) BETWEEN 8 and 11 THEN ''Last successful backup was '' + ISNULL(CONVERT(VARCHAR(30), MAX(BackupStartDate), 120), ''never'') + '', up to 7 days of data loss could occur.''
		  ELSE ''Last successful backup was '' + ISNULL(CONVERT(VARCHAR(30), MAX(BackupStartDate), 120), ''never'') + '', data loss could occur.''		   
		  END as HealthDetail
FROM vwCTEGetDatabaseList
LEFT OUTER JOIN DB.DatabaseBackups 
	ON vwCTEGetDatabaseList.InstanceName = DB.DatabaseBackups.InstanceName
	AND vwCTEGetDatabaseList.DBName = DB.DatabaseBackups.DBName
	AND DB.DatabaseBackups.BackupTypeCode = ''D'' 
	AND DB.DatabaseBackups.BackupStartDate >= dateadd(hour, -360, vwCTEGetDatabaseList.LastUpdatedDate) --LAST 14 Days
LEFT OUTER JOIN 
(
	SELECT DB.AvailReplicas.ReplicaName, DB.AvailDatabases.AGDBName, DB.AvailReplicas.Role, MAX(db.AvailReplicas.DateAdded)  as DateAdded
	FROM DB.AvailDatabases
	inner join DB.AvailReplicas on DB.AvailDatabases.AGName = DB.AvailReplicas.AGName and DB.AvailDatabases.DateAdded = DB.AvailReplicas.DateAdded
	WHERE Role != ''PRIMARY''
	group by ReplicaName, AGDBName, Role
) AON ON AON.ReplicaName = vwCTEGetDatabaseList.InstanceName
	AND AON.AGDBName = vwCTEGetDatabaseList.DBName
	AND AON.DateAdded = vwCTEGetDatabaseList.LastUpdatedDate
GROUP BY 
	vwCTEGetDatabaseList.ServerName, 
	vwCTEGetDatabaseList.InstanceName, 
	vwCTEGetDatabaseList.DBName, 
	vwCTEGetDatabaseList.RecoveryModel, 
	vwCTEGetDatabaseList.LastUpdatedDate,
	AON.Role
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKConfigurationFindingsRaw]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKConfigurationFindingsRaw]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwCTEGetFRKConfigurationFindingsRaw]
as
SELECT 
	Status, StatusColor, ServerName, FindingsGroup, Finding, DatabaseName, Details, Priority, CheckID, CheckDate 
FROM 
	[dbo].[vwCTEGetFRKVulnerabilityRaw]
WHERE 
	FindingsGroup in (''Informational'', ''Server Info'', ''File Configuration'', ''Non-Active Server Config'', ''Non-Default Database Config'', ''Non-Default Database Scoped Config'', ''Non-Default Server Config'')
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsRaw]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsRaw]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsRaw]
as
SELECT 
	Status, StatusColor, ServerName, FindingsGroup, Finding, DatabaseName, Details, Priority, CheckID, CheckDate 
FROM 
	[dbo].[vwCTEGetFRKVulnerabilityRaw]
WHERE 
	FindingsGroup in (''Performance'', ''Reliability'', ''Wait Stats'', ''Backup'', ''Corruption'', ''Monitoring'', ''DBCC Events'', ''Query Plans'')
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKVulnerabilityList]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKVulnerabilityList]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCTEGetFRKVulnerabilityList]
as
SELECT
	VulnerabilityStatus as Status,

CASE 
	WHEN VulnerabilityRank <= 5 THEN ''WhiteSmoke''
	WHEN VulnerabilityRank Between 6 and 128 THEN ''#A9DFBF''
	WHEN VulnerabilityRank Between 129 and 256 THEN ''#F9E79F''
	WHEN VulnerabilityRank Between 257 and 512 THEN ''#F0C6AA''
	ELSE ''#E6B0AA''
END as StatusColor, 
	b.ServerName, FindingsGroup, Finding, DatabaseName, Details, VulnerabilityRank as Priority, CheckID, b.CheckDate
FROM FRK.Blitz b
INNER JOIN 
	[dbo].[vwFRKBlitzLatestCollectionByServerName] x
	ON 
	x.CheckDate = b.CheckDate
	and
	x.ServerName = b.ServerName
' 
GO
/****** Object:  View [dbo].[vwGetFRKVulnerabilityCurrent]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGetFRKVulnerabilityCurrent]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwGetFRKVulnerabilityCurrent]
as
SELECT [Critical], [Severe], [Moderate], [Low], [Informational]
FROM
(
SELECT Count(*) Count, Status FROM [dbo].[vwCTEGetFRKVulnerabilityList] GROUP BY Status 
) AS SourceTable
PIVOT
(
 SUM(Count)
 FOR Status IN ([Critical], [Severe], [Moderate], [Low], [Informational])
) AS PivotTable;
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKConfigurationFindingsList]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKConfigurationFindingsList]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCTEGetFRKConfigurationFindingsList]
as
SELECT
	Status, StatusColor, ServerName, FindingsGroup, Finding, DatabaseName, Details, Priority, CheckID, CheckDate
FROM dbo.[vwCTEGetFRKVulnerabilityList]
WHERE (FindingsGroup in (''Informational'', ''Server Info'', ''File Configuration'', ''Non-Active Server Config'', ''Non-Default Database Config'', ''Non-Default Database Scoped Config'', ''Non-Default Server Config''))
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsList]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsList]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsList]
as
SELECT
	Status, StatusColor, ServerName, FindingsGroup, Finding, DatabaseName, Details, Priority, CheckID, CheckDate
FROM dbo.[vwCTEGetFRKVulnerabilityList]
WHERE (FindingsGroup in (''Performance'', ''Reliability'', ''Wait Stats'', ''Backup'', ''Corruption'', ''Monitoring'', ''DBCC Events'', ''Query Plans''))
union all
SELECT 
CASE WHEN DetailInfo = ''You are upto date!'' then ''Informational'' else ''Severe'' end as Status, 
CASE WHEN DetailInfo = ''You are upto date!'' then ''WhiteSmoke'' else ''#F0C6AA'' end as StatusColor, InstanceName as ServerName, ''Reliability'' as FindingsGroup, ''Patching Information'' as Finding, null as DatabaseName, DetailInfo as Details, 
CASE WHEN DetailInfo = ''You are upto date!'' then -1 else 512 end as Priority, 666 as CheckID, getDate() as CheckDate
FROM [dbo].[vwSQLVersionReview]
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKSecurityFindingsList]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKSecurityFindingsList]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCTEGetFRKSecurityFindingsList]
as
SELECT
	Status, StatusColor, ServerName, FindingsGroup, Finding, DatabaseName, Details, Priority, CheckID, CheckDate
FROM dbo.[vwCTEGetFRKVulnerabilityList]
WHERE FindingsGroup in (''Security'')
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKConfigurationFindingsGrade]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKConfigurationFindingsGrade]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwCTEGetFRKConfigurationFindingsGrade]
as
with cteActualServerValues
as
(
	SELECT 0 TotalAvgPriorityAll, COUNT(Status) CountChecks, SUM(Priority) SumPriority,  SUM(Priority)/COUNT(CheckID) TotalAvgPriority, ServerName
	FROM [dbo].[vwCTEGetFRKConfigurationFindingsList]
	GROUP BY Status, ServerName, Status
)
SELECT TotalAvgPriorityAll, SUM(CountChecks) as CountChecks, SUM(SumPriority) as SumPriority, ServerName, 
SUM(SumPriority) as GradeValue, 
CASE 
	WHEN SUM(SumPriority) <= 1024	THEN ''A''
	WHEN SUM(SumPriority) <= 2048	THEN ''B''
	WHEN SUM(SumPriority) <= 4096	THEN ''C''
	WHEN SUM(SumPriority) <= 8192	THEN ''D''
	WHEN SUM(SumPriority) >  8192	THEN ''F''
	END GradeLevel,
CASE 
	WHEN SUM(SumPriority) <= 1024	THEN ''100''
	WHEN SUM(SumPriority) <= 2048	THEN ''80''
	WHEN SUM(SumPriority) <= 4096	THEN ''60''
	WHEN SUM(SumPriority) <= 8192	THEN ''40''
	WHEN SUM(SumPriority) >  8192	THEN ''20''
	END IndicatorColor
FROM
(
SELECT * FROM cteActualServerValues
) x
GROUP BY TotalAvgPriorityAll, ServerName
--ORDER BY SumPriority DESC
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsGrade]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsGrade]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsGrade]
as
with cteActualServerValues
as
(
	SELECT 0 TotalAvgPriorityAll, COUNT(Status) CountChecks, SUM(Priority) SumPriority,  SUM(Priority)/COUNT(CheckID) TotalAvgPriority, ServerName
	FROM [dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsList]
	GROUP BY Status, ServerName, Status
)
SELECT TotalAvgPriorityAll, SUM(CountChecks) as CountChecks, SUM(SumPriority) as SumPriority, ServerName, 
SUM(SumPriority) as GradeValue, 
CASE 
	WHEN SUM(SumPriority) <= 1024	THEN ''A''
	WHEN SUM(SumPriority) <= 2048	THEN ''B''
	WHEN SUM(SumPriority) <= 4096	THEN ''C''
	WHEN SUM(SumPriority) <= 8192	THEN ''D''
	WHEN SUM(SumPriority) >  8192	THEN ''F''
	END GradeLevel,
CASE 
	WHEN SUM(SumPriority) <= 1024	THEN ''100''
	WHEN SUM(SumPriority) <= 2048	THEN ''80''
	WHEN SUM(SumPriority) <= 4096	THEN ''60''
	WHEN SUM(SumPriority) <= 8192	THEN ''40''
	WHEN SUM(SumPriority) >  8192	THEN ''20''
	END IndicatorColor
FROM
(
SELECT * FROM cteActualServerValues
) x
GROUP BY TotalAvgPriorityAll, ServerName
--ORDER BY SumPriority DESC
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKSecurityFindingsGrade]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKSecurityFindingsGrade]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwCTEGetFRKSecurityFindingsGrade]
as
with cteActualServerValues
as
(
	SELECT 0 TotalAvgPriorityAll, COUNT(Status) CountChecks, SUM(Priority) SumPriority,  SUM(Priority)/COUNT(CheckID) TotalAvgPriority, ServerName
	FROM [dbo].[vwCTEGetFRKSecurityFindingsList]
	GROUP BY Status, ServerName, Status
)
SELECT TotalAvgPriorityAll, SUM(CountChecks) as CountChecks, SUM(SumPriority) as SumPriority, ServerName, 
SUM(SumPriority) as GradeValue, 
CASE 
	WHEN SUM(SumPriority) <= 1024	THEN ''A''
	WHEN SUM(SumPriority) <= 2048	THEN ''B''
	WHEN SUM(SumPriority) <= 4096	THEN ''C''
	WHEN SUM(SumPriority) <= 8192	THEN ''D''
	WHEN SUM(SumPriority) >  8192	THEN ''F''
	END GradeLevel,
CASE 
	WHEN SUM(SumPriority) <= 1024	THEN ''100''
	WHEN SUM(SumPriority) <= 2048	THEN ''80''
	WHEN SUM(SumPriority) <= 4096	THEN ''60''
	WHEN SUM(SumPriority) <= 8192	THEN ''40''
	WHEN SUM(SumPriority) >  8192	THEN ''20''
	END IndicatorColor
FROM
(
SELECT * FROM cteActualServerValues
) x
GROUP BY TotalAvgPriorityAll, ServerName
--ORDER BY SumPriority DESC
' 
GO
/****** Object:  View [dbo].[vwCTEGetFRKFindingsGrade]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCTEGetFRKFindingsGrade]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCTEGetFRKFindingsGrade]
as
SELECT
	CASE
	WHEN SumPriorityStatus <= 1024	THEN ''A'' --0 to 1024
	WHEN SumPriorityStatus <= 4096	THEN ''B'' --1025 to 4096
	WHEN SumPriorityStatus <= 8192	THEN ''C'' --4097 to 8192
	WHEN SumPriorityStatus <= 16384	THEN ''D'' --8193 to 16384
	WHEN SumPriorityStatus >  16385	THEN ''F'' --16385 +
	END GradeLevel
	,CASE 
	WHEN SumPriorityStatus <= 1024	THEN ''100''
	WHEN SumPriorityStatus <= 4096	THEN ''80''
	WHEN SumPriorityStatus <= 8192	THEN ''60''
	WHEN SumPriorityStatus <= 16384	THEN ''40''
	WHEN SumPriorityStatus >  16385	THEN ''20''
	END IndicatorColor
	,SumPriorityStatus GradeValue
	,ServerName
FROM
(
SELECT Count(ServerName) CountServerName, SUM(GradeValue)*1.0/COUNT(ServerName)*1.0 SumPriorityStatus, ServerName, Sum(CountChecks) SumCountChecks, SUM(GradeValue)/ Sum(CountChecks) as AvgPointsPerCheck
FROM
(
SELECT ServerName, GradeValue, CountChecks FROM [dbo].[vwCTEGetFRKSecurityFindingsGrade]
union all
SELECT ServerName, GradeValue, CountChecks FROM [dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsGrade]
union all
SELECT ServerName, GradeValue, CountChecks FROM [dbo].[vwCTEGetFRKConfigurationFindingsGrade]
) x
GROUP BY ServerName
) y
' 
GO
/****** Object:  View [dbo].[vwGetFRKTotalFindingsGradeList]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGetFRKTotalFindingsGradeList]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwGetFRKTotalFindingsGradeList]
as
SELECT 
	 fg.ServerName
	,fg.GradeLevel	TotalGradeLevel
	,fg.GradeValue	TotalGradeValue
	,fg.IndicatorColor	TotalGradeIndicatorColor

	,sfg.CountChecks	SecCountChecks
	,sfg.GradeLevel		SecGradeLevel
	,sfg.GradeValue		SecGradeValue
	,sfg.IndicatorColor	SecGradeIndicatorColor

	,cfg.CountChecks	ConfCountChecks
	,cfg.GradeLevel		ConfGradeLevel
	,cfg.GradeValue		ConfGradeValue
	,cfg.IndicatorColor	ConfGradeIndicatorColor

	,rfg.CountChecks	PaRCountChecks
	,rfg.GradeLevel		PaRGradeLevel
	,rfg.GradeValue		PaRGradeValue
	,rfg.IndicatorColor	PaRGradeIndicatorColor
	 
FROM [dbo].[vwCTEGetFRKFindingsGrade] fg
inner join [dbo].[vwCTEGetFRKSecurityFindingsGrade] sfg on sfg.ServerName = fg.ServerName
inner join [dbo].[vwCTEGetFRKConfigurationFindingsGrade] cfg on cfg.ServerName = fg.ServerName
inner join [dbo].[vwCTEGetFRKPerformanceandReliabilityFindingsGrade] rfg on rfg.ServerName = fg.ServerName
' 
GO
/****** Object:  View [dbo].[vwGETDatabaseReportingOverview]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGETDatabaseReportingOverview]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwGETDatabaseReportingOverview]
as
SELECT
	 sl.[Sector]        
    ,sl.[Ministry]       
    ,sl.[Division]       
    ,sl.[Branch]         
    ,sl.[Description]    
    ,sl.[BusinessOwner]  
    ,sl.[BusinessOwner2] 
    ,sl.[TechnicalOwner] 
    ,sl.[TechnicalOwner2]
	,dic.ServerName
	,dic.InstanceName
	,dic.DBName
	,dic.DBSizeInMB as CurrentDBSizeInMB
	--,dbo.fnGetPercentageGrowthOverXMonths(dic.ServerName, dic.InstanceName, dic.DBName, 3) PercentageGrowthOverThreeMonths
	,dbo.fnGetPercentageGrowthOverXMonths(dic.ServerName, dic.InstanceName, dic.DBName, 6) PercentageGrowthOverSixMonths	
	,dbo.fnGetPercentageGrowthOverXMonths(dic.ServerName, dic.InstanceName, dic.DBName, 12) PercentageGrowthOverTwelveMonths
FROM [dbo].[vwGETDatabaseInfoCurrent] dic
INNER JOIN [Svr].ServerList sl on sl.ServerName = dic.[ServerName] and  sl.Decomissioned = 0
' 
GO
/****** Object:  Table [dbo].[TinyNumbers]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TinyNumbers]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TinyNumbers](
	[Number] [tinyint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetWindowsSID]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetWindowsSID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[GetWindowsSID]
(
  @sid VARBINARY(85)
)
RETURNS TABLE
WITH SCHEMABINDING
AS
  RETURN 
  (
    SELECT ADsid = STUFF((SELECT ''-'' + part FROM 
    (
      SELECT Number = -1, part = ''S-'' 
        + CONVERT(VARCHAR(30),CONVERT(TINYINT,CONVERT(VARBINARY(30),LEFT(@sid,1)))) 
        + ''-'' 
        + CONVERT(VARCHAR(30),CONVERT(INT,CONVERT(VARBINARY(30),SUBSTRING(@sid,3,6))))
      UNION ALL
      SELECT TOP ((LEN(@sid)-5)/4) Number, 
     part = CONVERT(VARCHAR(30),CONVERT(BIGINT,CONVERT(VARBINARY(30), 
  REVERSE(CONVERT(VARBINARY(30),SUBSTRING(@sid,9+Number*4,4)))))) 
      FROM dbo.TinyNumbers ORDER BY Number
    ) AS x ORDER BY Number
    FOR XML PATH(''''), TYPE).value(N''.[1]'',''nvarchar(max)''),1,1,'''')
  );
' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[DelimitedSplit8K]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DelimitedSplit8K]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'--http://www.mssqltips.com/sqlservertip/2866/sql-server-reporting-services-using-multivalue-parameters/
--http://www.sqlservercentral.com/articles/Tally+Table/72993/
CREATE FUNCTION [dbo].[DelimitedSplit8K]
--===== Define I/O parameters
        (@pString VARCHAR(8000), @pDelimiter CHAR(1))
--WARNING!!! DO NOT USE MAX DATA-TYPES HERE!  IT WILL KILL PERFORMANCE!
RETURNS TABLE WITH SCHEMABINDING AS
 RETURN
--===== "Inline" CTE Driven "Tally Table" produces values from 1 up to 10,000...
     -- enough to cover VARCHAR(8000)
  WITH E1(N) AS (
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
                ),                          --10E+1 or 10 rows
       E2(N) AS (SELECT 1 FROM E1 a, E1 b), --10E+2 or 100 rows
       E4(N) AS (SELECT 1 FROM E2 a, E2 b), --10E+4 or 10,000 rows max
 cteTally(N) AS (--==== This provides the "base" CTE and limits the number of rows right up front
                     -- for both a performance gain and prevention of accidental "overruns"
                 SELECT TOP (ISNULL(DATALENGTH(@pString),0)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4
                ),
cteStart(N1) AS (--==== This returns N+1 (starting position of each "element" just once for each delimiter)
                 SELECT 1 UNION ALL
                 SELECT t.N+1 FROM cteTally t WHERE SUBSTRING(@pString,t.N,1) = @pDelimiter
                ),
cteLen(N1,L1) AS(--==== Return start and length (for use in substring)
                 SELECT s.N1,
                        ISNULL(NULLIF(CHARINDEX(@pDelimiter,@pString,s.N1),0)-s.N1,8000)
                   FROM cteStart s
                )
--===== Do the actual split. The ISNULL/NULLIF combo handles the length for the final element when no delimiter is found.
 SELECT ItemNumber = ROW_NUMBER() OVER(ORDER BY l.N1),
        Item       = SUBSTRING(@pString, l.N1, l.L1)
   FROM cteLen l
;
' 
END
GO
/****** Object:  Table [AS].[SSASDBInfo]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AS].[SSASDBInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [AS].[SSASDBInfo](
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NULL,
	[DBName] [nvarchar](128) NULL,
	[DBSizeInMB] [decimal](10, 2) NULL,
	[Collation] [nvarchar](30) NULL,
	[CompatibilityLevel] [nvarchar](30) NULL,
	[DBCreateDate] [nvarchar](30) NULL,
	[DBLastProcessed] [nvarchar](30) NULL,
	[DBLastUpdated] [nvarchar](30) NULL,
	[DBStorageLocation] [nvarchar](500) NULL,
	[NoOfCubes] [smallint] NULL,
	[NoOfDimensions] [smallint] NULL,
	[ReadWriteMode] [nvarchar](30) NULL,
	[StorgageEngineUsed] [nvarchar](30) NULL,
	[IsVisible] [bit] NULL,
	[DateAdded] [smalldatetime] NULL,
	[ASDBID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [AS].[SSASInfo]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AS].[SSASInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [AS].[SSASInfo](
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NULL,
	[ProductName] [nvarchar](128) NULL,
	[ASVersion] [nvarchar](30) NULL,
	[ASPatchLevel] [nvarchar](10) NULL,
	[IsSPUpToDateOnAS] [bit] NULL,
	[ASEdition] [nvarchar](30) NULL,
	[ASVersionNo] [nvarchar](30) NULL,
	[NoOfDBs] [smallint] NULL,
	[LastSchemaUpdate] [nvarchar](30) NULL,
	[IsConnected] [bit] NULL,
	[IsMajorObjLoaded] [bit] NULL,
	[DateAdded] [smalldatetime] NULL,
	[ASID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [DB].[AvailGroups]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DB].[AvailGroups]') AND type in (N'U'))
BEGIN
CREATE TABLE [DB].[AvailGroups](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[AGName] [nvarchar](128) NULL,
	[PrimaryReplica] [nvarchar](128) NULL,
	[SyncHealth] [nvarchar](60) NULL,
	[BackupPreference] [nvarchar](60) NULL,
	[Failoverlevel] [int] NULL,
	[HealthChkTimeout] [int] NULL,
	[ListenerName] [nvarchar](128) NULL,
	[ListenerIP] [nvarchar](50) NULL,
	[ListenerPort] [nvarchar](30) NULL,
	[DateAdded] [smalldatetime] NULL,
	[AGID] [int] IDENTITY(1,1) NOT NULL
) ON [DB]
END
GO
/****** Object:  Table [DB].[DatabaseFiles]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DB].[DatabaseFiles]') AND type in (N'U'))
BEGIN
CREATE TABLE [DB].[DatabaseFiles](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[DBName] [nvarchar](128) NOT NULL,
	[FileID] [int] NULL,
	[TypeDesc] [nvarchar](60) NULL,
	[LogicalName] [nvarchar](128) NULL,
	[PhysicalName] [nvarchar](260) NULL,
	[SizeInMB] [int] NULL,
	[GrowthPct] [int] NULL,
	[GrowthInMB] [int] NULL,
	[DateAdded] [smalldatetime] NULL,
	[DBFlID] [int] IDENTITY(1,1) NOT NULL
) ON [DB]
END
GO
/****** Object:  Table [DB].[DBFileGrowth]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DB].[DBFileGrowth]') AND type in (N'U'))
BEGIN
CREATE TABLE [DB].[DBFileGrowth](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[DBName] [nvarchar](128) NULL,
	[DataFileInMB] [int] NULL,
	[LogFileInMB] [int] NULL,
	[DateAdded] [smalldatetime] NULL,
	[DBFGID] [int] IDENTITY(1,1) NOT NULL
) ON [DB]
END
GO
/****** Object:  Table [DB].[DBUserRoles]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DB].[DBUserRoles]') AND type in (N'U'))
BEGIN
CREATE TABLE [DB].[DBUserRoles](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[DBName] [nvarchar](128) NULL,
	[DBUser] [nvarchar](128) NULL,
	[DBRole] [varchar](128) NULL,
	[DateAdded] [smalldatetime] NULL,
	[DBUsrID] [int] IDENTITY(1,1) NOT NULL
) ON [DB]
END
GO
/****** Object:  Table [DB].[DBUserRolesDescription]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DB].[DBUserRolesDescription]') AND type in (N'U'))
BEGIN
CREATE TABLE [DB].[DBUserRolesDescription](
	[DBRole] [varchar](128) NULL,
	[Description] [varchar](4000) NULL,
	[DateAdded] [smalldatetime] NULL,
	[DBUserRolesID] [int] IDENTITY(1,1) NOT NULL
) ON [DB]
END
GO
/****** Object:  Table [DB].[Triggers]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DB].[Triggers]') AND type in (N'U'))
BEGIN
CREATE TABLE [DB].[Triggers](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[DBName] [nvarchar](128) NULL,
	[TriggerName] [nvarchar](128) NULL,
	[CreateDate] [nvarchar](30) NULL,
	[LastModified] [nvarchar](30) NULL,
	[IsEnabled] [bit] NULL,
	[DateAdded] [smalldatetime] NULL,
	[DBTrgID] [int] IDENTITY(1,1) NOT NULL
) ON [DB]
END
GO
/****** Object:  Table [FRK].[BlitzCache]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FRK].[BlitzCache]') AND type in (N'U'))
BEGIN
CREATE TABLE [FRK].[BlitzCache](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](256) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[Version] [nvarchar](256) NULL,
	[QueryType] [nvarchar](256) NULL,
	[Warnings] [varchar](max) NULL,
	[DatabaseName] [sysname] NOT NULL,
	[SerialDesiredMemory] [float] NULL,
	[SerialRequiredMemory] [float] NULL,
	[AverageCPU] [bigint] NULL,
	[TotalCPU] [bigint] NULL,
	[PercentCPUByType] [money] NULL,
	[CPUWeight] [money] NULL,
	[AverageDuration] [bigint] NULL,
	[TotalDuration] [bigint] NULL,
	[DurationWeight] [money] NULL,
	[PercentDurationByType] [money] NULL,
	[AverageReads] [bigint] NULL,
	[TotalReads] [bigint] NULL,
	[ReadWeight] [money] NULL,
	[PercentReadsByType] [money] NULL,
	[AverageWrites] [bigint] NULL,
	[TotalWrites] [bigint] NULL,
	[WriteWeight] [money] NULL,
	[PercentWritesByType] [money] NULL,
	[ExecutionCount] [bigint] NULL,
	[ExecutionWeight] [money] NULL,
	[PercentExecutionsByType] [money] NULL,
	[ExecutionsPerMinute] [money] NULL,
	[PlanCreationTime] [datetime] NULL,
	[PlanCreationTimeHours] [int] NULL,
	[LastExecutionTime] [datetime] NULL,
	[PlanHandle] [varbinary](64) NULL,
	[Remove Plan Handle From Cache] [varchar](max) NULL,
	[SqlHandle] [varbinary](64) NULL,
	[Remove SQL Handle From Cache] [varchar](max) NULL,
	[SQL Handle More Info] [varchar](max) NULL,
	[QueryHash] [binary](8) NULL,
	[Query Hash More Info] [varchar](max) NULL,
	[QueryPlanHash] [binary](8) NULL,
	[StatementStartOffset] [int] NULL,
	[StatementEndOffset] [int] NULL,
	[MinReturnedRows] [bigint] NULL,
	[MaxReturnedRows] [bigint] NULL,
	[AverageReturnedRows] [money] NULL,
	[TotalReturnedRows] [bigint] NULL,
	[QueryText] [nvarchar](max) NULL,
	[QueryPlan] [xml] NULL,
	[NumberOfPlans] [int] NULL,
	[NumberOfDistinctPlans] [int] NULL,
	[MinGrantKB] [bigint] NULL,
	[MaxGrantKB] [bigint] NULL,
	[MinUsedGrantKB] [bigint] NULL,
	[MaxUsedGrantKB] [bigint] NULL,
	[PercentMemoryGrantUsed] [money] NULL,
	[AvgMaxMemoryGrant] [money] NULL,
	[QueryPlanCost] [float] NULL,
 CONSTRAINT [PK_BlitzCache] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FRK]
) ON [FRK] TEXTIMAGE_ON [FRK]
END
GO
/****** Object:  Table [FRK].[BlitzFirst]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FRK].[BlitzFirst]') AND type in (N'U'))
BEGIN
CREATE TABLE [FRK].[BlitzFirst](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[CheckID] [int] NOT NULL,
	[Priority] [tinyint] NOT NULL,
	[FindingsGroup] [varchar](50) NOT NULL,
	[Finding] [varchar](200) NOT NULL,
	[URL] [varchar](200) NOT NULL,
	[Details] [nvarchar](4000) NULL,
	[HowToStopIt] [xml] NULL,
	[QueryPlan] [xml] NULL,
	[QueryText] [nvarchar](max) NULL,
	[StartTime] [datetimeoffset](7) NULL,
	[LoginName] [nvarchar](128) NULL,
	[NTUserName] [nvarchar](128) NULL,
	[OriginalLoginName] [nvarchar](128) NULL,
	[ProgramName] [nvarchar](128) NULL,
	[HostName] [nvarchar](128) NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[OpenTransactionCount] [int] NULL,
	[DetailsInt] [int] NULL,
 CONSTRAINT [PK_BlitzFirst] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FRK]
) ON [FRK] TEXTIMAGE_ON [FRK]
END
GO
/****** Object:  Table [FRK].[BlitzFirst_FileStats]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FRK].[BlitzFirst_FileStats]') AND type in (N'U'))
BEGIN
CREATE TABLE [FRK].[BlitzFirst_FileStats](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[DatabaseID] [int] NOT NULL,
	[FileID] [int] NOT NULL,
	[DatabaseName] [nvarchar](256) NULL,
	[FileLogicalName] [nvarchar](256) NULL,
	[TypeDesc] [nvarchar](60) NULL,
	[SizeOnDiskMB] [bigint] NULL,
	[io_stall_read_ms] [bigint] NULL,
	[num_of_reads] [bigint] NULL,
	[bytes_read] [bigint] NULL,
	[io_stall_write_ms] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[bytes_written] [bigint] NULL,
	[PhysicalName] [nvarchar](520) NULL,
 CONSTRAINT [PK_BlitzFirst_FileStats] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FRK]
) ON [FRK]
END
GO
/****** Object:  Table [FRK].[BlitzFirst_PerfmonStats]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FRK].[BlitzFirst_PerfmonStats]') AND type in (N'U'))
BEGIN
CREATE TABLE [FRK].[BlitzFirst_PerfmonStats](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[object_name] [nvarchar](128) NOT NULL,
	[counter_name] [nvarchar](128) NOT NULL,
	[instance_name] [nvarchar](128) NULL,
	[cntr_value] [bigint] NULL,
	[cntr_type] [int] NOT NULL,
	[value_delta] [bigint] NULL,
	[value_per_second] [decimal](18, 2) NULL,
 CONSTRAINT [PK_BlitzFirst_PerfmonStats] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FRK]
) ON [FRK]
END
GO
/****** Object:  Table [FRK].[BlitzFirst_WaitStats]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FRK].[BlitzFirst_WaitStats]') AND type in (N'U'))
BEGIN
CREATE TABLE [FRK].[BlitzFirst_WaitStats](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[wait_type] [nvarchar](60) NULL,
	[wait_time_ms] [bigint] NULL,
	[signal_wait_time_ms] [bigint] NULL,
	[waiting_tasks_count] [bigint] NULL,
 CONSTRAINT [PK_BlitzFirst_WaitStats] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FRK]
) ON [FRK]
END
GO
/****** Object:  Table [Inst].[ADGroupMembership]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[ADGroupMembership]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[ADGroupMembership](
	[ServerName] [nvarchar](256) NOT NULL,
	[InstanceName] [nvarchar](256) NOT NULL,
	[UserName] [nvarchar](256) NULL,
	[AccountType] [varchar](8) NULL,
	[GroupName] [nvarchar](256) NULL,
	[DateAdded] [smalldatetime] NOT NULL,
	[ADGroupMembershipID] [int] IDENTITY(1,1) NOT NULL
) ON [Inst]
END
GO
/****** Object:  Table [Inst].[BackupStage]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[BackupStage]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[BackupStage](
	[FullPath] [nvarchar](4000) NULL,
	[Directory] [nvarchar](1000) NULL,
	[FileName] [nvarchar](700) NULL,
	[FileSize] [bigint] NULL,
	[FileCreatedDate] [datetime] NOT NULL,
	[FileLastModifiedDate] [datetime] NOT NULL,
	[bsID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_BackupStage] PRIMARY KEY CLUSTERED 
(
	[bsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Inst]
) ON [Inst]
END
GO
/****** Object:  Table [Inst].[CommandLogArchive]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[CommandLogArchive]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[CommandLogArchive](
	[DatabaseName] [sysname] NULL,
	[SchemaName] [sysname] NULL,
	[ObjectName] [sysname] NULL,
	[ObjectType] [char](2) NULL,
	[IndexName] [sysname] NULL,
	[IndexType] [tinyint] NULL,
	[StatisticsName] [sysname] NULL,
	[PartitionNumber] [int] NULL,
	[ExtendedInfo] [nvarchar](max) NULL,
	[Command] [nvarchar](max) NOT NULL,
	[CommandType] [nvarchar](60) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[ErrorNumber] [int] NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[ServerName] [sysname] NULL,
	[Type] [varchar](255) NULL,
	[BatchGUID] [uniqueidentifier] NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateModified] [datetime] NOT NULL,
	[CommandLogID] [int] NOT NULL,
	[TimeTakenMS]  AS (datediff(millisecond,[StartTime],[EndTime])),
	[CommandLogArchiveID] [int] IDENTITY(1,1) NOT NULL,
	[TimeTaken]  AS (CONVERT([varchar],dateadd(millisecond,datediff(millisecond,[StartTime],[EndTime]),(0)),(114))) PERSISTED,
 CONSTRAINT [PK_CommandLogArchive_ID] PRIMARY KEY CLUSTERED 
(
	[CommandLogArchiveID] ASC,
	[CommandLogID] ASC,
	[CommandType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Inst]
) ON [Inst] TEXTIMAGE_ON [Inst]
END
GO
/****** Object:  Table [Inst].[InsBaselineStats]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[InsBaselineStats]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[InsBaselineStats](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[FwdRecSec] [decimal](15, 0) NOT NULL,
	[FlScansSec] [decimal](15, 0) NOT NULL,
	[IdxSrchsSec] [decimal](15, 0) NOT NULL,
	[PgSpltSec] [decimal](15, 0) NOT NULL,
	[FreeLstStallsSec] [decimal](15, 0) NOT NULL,
	[LzyWrtsSec] [decimal](15, 0) NOT NULL,
	[PgLifeExp] [decimal](15, 0) NOT NULL,
	[PgRdSec] [decimal](15, 0) NOT NULL,
	[PgWtSec] [decimal](15, 0) NOT NULL,
	[LogGrwths] [decimal](15, 0) NOT NULL,
	[TranSec] [decimal](15, 0) NOT NULL,
	[BlkProcs] [decimal](15, 0) NOT NULL,
	[UsrConns] [decimal](15, 0) NOT NULL,
	[LatchWtsSec] [decimal](15, 0) NOT NULL,
	[LckWtTime] [decimal](15, 0) NOT NULL,
	[LckWtsSec] [decimal](15, 0) NOT NULL,
	[DeadLockSec] [decimal](15, 0) NOT NULL,
	[MemGrnts] [decimal](15, 0) NOT NULL,
	[BatReqSec] [decimal](15, 0) NOT NULL,
	[SQLCompSec] [decimal](15, 0) NOT NULL,
	[SQLReCompSec] [decimal](15, 0) NOT NULL,
	[SQLProcessorUsage] [decimal](15, 2) NOT NULL,
	[SQLProcessorUsageBase] [decimal](15, 2) NOT NULL,
	[SQLBufferCachePercent] [decimal](15, 2) NOT NULL,
	[SQLProcedureCachePercent] [decimal](15, 2) NOT NULL,
	[ReadAheadReadsSec] [decimal](15, 0) NOT NULL,
	[CheckpointWritesSec] [decimal](15, 0) NOT NULL,
	[RunDate] [smalldatetime] NOT NULL,
	[InsBLID] [bigint] IDENTITY(1,1) NOT NULL
) ON [Inst]
END
GO
/****** Object:  Table [Inst].[InstanceRolesDescription]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[InstanceRolesDescription]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[InstanceRolesDescription](
	[RoleName] [nvarchar](128) NULL,
	[Description] [varchar](4000) NULL,
	[DateAdded] [smalldatetime] NULL,
	[InstanceRolesDescriptionID] [int] IDENTITY(1,1) NOT NULL
) ON [Inst]
END
GO
/****** Object:  Table [Inst].[InsTriggers]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[InsTriggers]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[InsTriggers](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[TriggerName] [nvarchar](128) NULL,
	[CreateDate] [nvarchar](30) NULL,
	[LastModified] [nvarchar](30) NULL,
	[IsEnabled] [bit] NULL,
	[DateAdded] [smalldatetime] NULL,
	[InsTrgID] [int] IDENTITY(1,1) NOT NULL
) ON [Inst]
END
GO
/****** Object:  Table [Inst].[Jobs]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[Jobs]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[Jobs](
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NOT NULL,
	[JobName] [nvarchar](128) NULL,
	[JobDescription] [nvarchar](max) NULL,
	[JobOwner] [nvarchar](128) NULL,
	[IsEnabled] [bit] NULL,
	[category] [nvarchar](128) NULL,
	[JobCreatedDate] [nvarchar](30) NULL,
	[JobLastModified] [nvarchar](30) NULL,
	[LastRunDate] [nvarchar](30) NULL,
	[NextRunDate] [nvarchar](30) NULL,
	[LastRunOutcome] [nvarchar](30) NULL,
	[CurrentRunRetryAttempt] [smallint] NULL,
	[OperatorToEmail] [nvarchar](128) NULL,
	[OperatorToPage] [nvarchar](128) NULL,
	[HasSchedule] [bit] NULL,
	[DateAdded] [smalldatetime] NULL,
	[JobID] [int] IDENTITY(1,1) NOT NULL
) ON [Inst] TEXTIMAGE_ON [Inst]
END
GO
/****** Object:  Table [Inst].[JobsFailed]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[JobsFailed]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[JobsFailed](
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NOT NULL,
	[JobName] [nvarchar](128) NULL,
	[StepID] [int] NULL,
	[StepName] [nvarchar](128) NULL,
	[ErrMsg] [nvarchar](max) NULL,
	[JobRunDate] [smalldatetime] NULL,
	[DateAdded] [smalldatetime] NULL,
	[JFID] [int] IDENTITY(1,1) NOT NULL
) ON [Inst] TEXTIMAGE_ON [Inst]
END
GO
/****** Object:  Table [Inst].[LinkedServers]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[LinkedServers]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[LinkedServers](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[LinkedServerName] [nvarchar](128) NULL,
	[ProviderName] [nvarchar](30) NULL,
	[ProductName] [nvarchar](128) NULL,
	[ProviderString] [nvarchar](max) NULL,
	[DateLastModified] [nvarchar](30) NULL,
	[DataAccess] [bit] NULL,
	[DateAdded] [smalldatetime] NULL,
	[LnkID] [int] IDENTITY(1,1) NOT NULL
) ON [Inst] TEXTIMAGE_ON [Inst]
END
GO
/****** Object:  Table [Inst].[LoginGroupMembers]    Script Date: 7/26/2021 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[LoginGroupMembers]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[LoginGroupMembers](
	[ServerName] [nvarchar](256) NOT NULL,
	[InstanceName] [nvarchar](256) NOT NULL,
	[LoginName] [nvarchar](256) NULL,
	[LoginType] [varchar](20) NULL,
	[LoginPrivilege] [varchar](20) NULL,
	[MappedLoginName] [nvarchar](256) NULL,
	[PermissionPath] [nvarchar](256) NULL,
	[GroupName] [nvarchar](256) NULL,
	[DateAdded] [smalldatetime] NOT NULL,
	[LoginGroupMembersID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_LoginGroupMembers] PRIMARY KEY NONCLUSTERED 
(
	[LoginGroupMembersID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Inst]
) ON [Inst]
END
GO
/****** Object:  Table [Inst].[MissingIndexes]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[MissingIndexes]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[MissingIndexes](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[DBName] [nvarchar](128) NULL,
	[SchemaName] [nvarchar](30) NULL,
	[MITable] [nvarchar](128) NULL,
	[improvement_measure] [nvarchar](30) NULL,
	[create_index_statement] [nvarchar](max) NULL,
	[group_handle] [int] NULL,
	[unique_compiles] [int] NULL,
	[user_seeks] [int] NULL,
	[last_user_seek] [smalldatetime] NULL,
	[avg_total_user_cost] [nvarchar](30) NULL,
	[avg_user_impact] [nvarchar](6) NULL,
	[DateAdded] [smalldatetime] NULL,
	[MIID] [int] IDENTITY(1,1) NOT NULL
) ON [Inst] TEXTIMAGE_ON [Inst]
END
GO
/****** Object:  Table [Inst].[Replication]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[Replication]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[Replication](
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NOT NULL,
	[IsPublisher] [bit] NULL,
	[IsDistributor] [bit] NULL,
	[DistributorAvailable] [bit] NULL,
	[Publisher] [nvarchar](128) NULL,
	[Distributor] [nvarchar](128) NULL,
	[Subscribers] [nvarchar](max) NULL,
	[ReplPubDBs] [nvarchar](max) NULL,
	[DistDB] [nvarchar](128) NULL,
	[DateAdded] [smalldatetime] NULL,
	[RID] [int] IDENTITY(1,1) NOT NULL
) ON [Inst] TEXTIMAGE_ON [Inst]
END
GO
/****** Object:  Table [Inst].[WaitStats]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[WaitStats]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[WaitStats](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[WaitType] [nvarchar](128) NULL,
	[Wait_S] [decimal](14, 2) NULL,
	[Resource_S] [decimal](14, 2) NULL,
	[Signal_S] [decimal](14, 2) NULL,
	[WaitCount] [bigint] NULL,
	[Percentage] [decimal](4, 2) NULL,
	[AvgWait_S] [decimal](14, 2) NULL,
	[AvgRes_S] [decimal](14, 2) NULL,
	[AvgSig_S] [decimal](14, 2) NULL,
	[DateAdded] [smalldatetime] NULL,
	[WtID] [bigint] IDENTITY(1,1) NOT NULL
) ON [Inst]
END
GO
/****** Object:  Table [Inst].[WaitStatsDaily]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[WaitStatsDaily]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[WaitStatsDaily](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[WaitType] [nvarchar](128) NULL,
	[Wait_S] [decimal](14, 2) NULL,
	[Resource_S] [decimal](14, 2) NULL,
	[Signal_S] [decimal](14, 2) NULL,
	[WaitCount] [bigint] NULL,
	[Percentage] [decimal](4, 2) NULL,
	[RecordCount] [int] NULL,
	[DateAdded] [date] NULL,
	[WtID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_WaitStatsDaily] PRIMARY KEY CLUSTERED 
(
	[WtID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Inst]
) ON [Inst]
END
GO
/****** Object:  Table [Inst].[WaitStatsHourly]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[WaitStatsHourly]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[WaitStatsHourly](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[WaitType] [nvarchar](128) NULL,
	[Wait_S] [decimal](14, 2) NULL,
	[Resource_S] [decimal](14, 2) NULL,
	[Signal_S] [decimal](14, 2) NULL,
	[WaitCount] [bigint] NULL,
	[Percentage] [decimal](4, 2) NULL,
	[RecordCount] [int] NULL,
	[DateAdded] [date] NULL,
	[DateAddedHour] [smallint] NULL,
	[WtID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_WaitStatsHourly] PRIMARY KEY CLUSTERED 
(
	[WtID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Inst]
) ON [Inst]
END
GO
/****** Object:  Table [Inst].[WaitStatsMonthly]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Inst].[WaitStatsMonthly]') AND type in (N'U'))
BEGIN
CREATE TABLE [Inst].[WaitStatsMonthly](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[WaitType] [nvarchar](128) NULL,
	[Wait_S] [decimal](14, 2) NULL,
	[Resource_S] [decimal](14, 2) NULL,
	[Signal_S] [decimal](14, 2) NULL,
	[WaitCount] [bigint] NULL,
	[Percentage] [decimal](4, 2) NULL,
	[RecordCount] [int] NULL,
	[DateAddedMonth] [smallint] NULL,
	[DateAddedYear] [smallint] NULL,
	[WtID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_WaitStatsMonthly] PRIMARY KEY CLUSTERED 
(
	[WtID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Inst]
) ON [Inst]
END
GO
/****** Object:  Table [RS].[SSRSConfig]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RS].[SSRSConfig]') AND type in (N'U'))
BEGIN
CREATE TABLE [RS].[SSRSConfig](
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NULL,
	[DatabaseServerName] [nvarchar](128) NULL,
	[IsDefaultInstance] [nvarchar](128) NULL,
	[PathName] [nvarchar](256) NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[DatabaseLogonAccount] [nvarchar](128) NULL,
	[DatabaseLogonTimeout] [smallint] NULL,
	[DatabaseQueryTimeout] [smallint] NULL,
	[ConnectionPoolSize] [smallint] NULL,
	[IsInitialized] [bit] NULL,
	[IsReportManagerEnabled] [bit] NULL,
	[IsSharePointIntegrated] [bit] NULL,
	[IsWebServiceEnabled] [bit] NULL,
	[IsWindowsServiceEnabled] [bit] NULL,
	[SecureConnectionLevel] [smallint] NULL,
	[SendUsingSMTPServer] [bit] NULL,
	[SMTPServer] [nvarchar](128) NULL,
	[SenderEmailAddress] [nvarchar](128) NULL,
	[UnattendedExecutionAccount] [nvarchar](128) NULL,
	[ServiceName] [nvarchar](128) NULL,
	[WindowsServiceIdentityActual] [nvarchar](128) NULL,
	[DateAdded] [smalldatetime] NULL,
	[RSCID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [RS].[SSRSInfo]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RS].[SSRSInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [RS].[SSRSInfo](
	[ServerName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NULL,
	[RSVersion] [nvarchar](30) NULL,
	[RSEdition] [nvarchar](128) NULL,
	[RSVersionNo] [nvarchar](30) NULL,
	[IsSharePointIntegrated] [bit] NULL,
	[DateAdded] [smalldatetime] NULL,
	[RSID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [Svr].[DiskInfo]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Svr].[DiskInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [Svr].[DiskInfo](
	[ServerName] [nvarchar](128) NOT NULL,
	[DiskName] [nvarchar](128) NULL,
	[Label] [nvarchar](128) NULL,
	[FileSystem] [nvarchar](30) NULL,
	[DskClusterSizeInKB] [int] NULL,
	[DskTotalSizeInGB] [decimal](10, 2) NULL,
	[DskFreeSpaceInGB] [decimal](10, 2) NULL,
	[DskUsedSpaceInGB] [decimal](10, 2) NULL,
	[DskPctFreeSpace] [nvarchar](10) NULL,
	[DateAdded] [smalldatetime] NULL,
	[DiskID] [int] IDENTITY(1,1) NOT NULL
) ON [Svr]
END
GO
/****** Object:  Table [Svr].[OSPatchInfo]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Svr].[OSPatchInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [Svr].[OSPatchInfo](
	[ServerName] [nvarchar](128) NOT NULL,
	[Caption] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[HotFixID] [nvarchar](260) NOT NULL,
	[InstalledBy] [nvarchar](255) NULL,
	[InstalledOn] [smalldatetime] NULL,
	[DateAdded] [smalldatetime] NOT NULL,
	[OSPatchInfoID] [int] IDENTITY(1,1) NOT NULL
) ON [Svr]
END
GO
/****** Object:  Table [Svr].[OSVulnerabilities]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Svr].[OSVulnerabilities]') AND type in (N'U'))
BEGIN
CREATE TABLE [Svr].[OSVulnerabilities](
	[Asset_IP_Address] [varchar](max) NULL,
	[Asset_Names] [varchar](max) NULL,
	[Asset_OS_Name] [varchar](max) NULL,
	[Month] [varchar](max) NULL,
	[Risk_Rating] [varchar](max) NULL,
	[Service_Name] [varchar](max) NULL,
	[Service_Port] [varchar](max) NULL,
	[Severity_Level] [varchar](max) NULL,
	[Site Name] [varchar](max) NULL,
	[Vulnerability_CVE_IDs] [varchar](max) NULL,
	[Vulnerability_CVSS_Score] [varchar](max) NULL,
	[Vulnerability_ID] [varchar](max) NULL,
	[Vulnerability_Test_Result_Code] [varchar](max) NULL,
	[Vulnerability_Title] [varchar](max) NULL,
	[Zone] [varchar](max) NULL,
	[ip_address] [varchar](max) NULL,
	[Sector] [varchar](max) NULL,
	[primary_contact] [varchar](max) NULL,
	[additional_contact] [varchar](max) NULL,
	[zone_name] [varchar](max) NULL,
	[alias] [varchar](max) NULL,
	[description] [varchar](max) NULL,
	[fullname] [varchar](max) NULL,
	[hostname] [varchar](max) NULL,
	[location] [varchar](max) NULL,
	[managed_by_name] [varchar](max) NULL,
	[name] [varchar](max) NULL,
	[notes] [varchar](max) NULL,
	[OS] [varchar](max) NULL,
	[site_name] [varchar](max) NULL,
	[status_name] [varchar](max) NULL,
	[decommission_date] [varchar](max) NULL,
	[decommission_ticket] [varchar](max) NULL,
	[CGI_reportzone] [varchar](max) NULL,
	[OSVulnerabilitiesID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_OSVulnerabilities] PRIMARY KEY CLUSTERED 
(
	[OSVulnerabilitiesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Svr]
) ON [Svr] TEXTIMAGE_ON [Svr]
END
GO
/****** Object:  Table [Svr].[PgFileUsage]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Svr].[PgFileUsage]') AND type in (N'U'))
BEGIN
CREATE TABLE [Svr].[PgFileUsage](
	[ServerName] [nvarchar](128) NOT NULL,
	[PgFileLocation] [nvarchar](128) NULL,
	[PgAllocBaseSzInGB] [decimal](10, 2) NULL,
	[PgCurrUsageInGB] [decimal](10, 2) NULL,
	[PgPeakUsageInGB] [decimal](10, 2) NULL,
	[DateAdded] [smalldatetime] NULL,
	[PFID] [int] IDENTITY(1,1) NOT NULL
) ON [Svr]
END
GO
/****** Object:  Table [Svr].[ServerLocalGroupMembers]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Svr].[ServerLocalGroupMembers]') AND type in (N'U'))
BEGIN
CREATE TABLE [Svr].[ServerLocalGroupMembers](
	[ServerName] [nvarchar](128) NOT NULL,
	[LocalGroupName] [nvarchar](128) NOT NULL,
	[Status] [nvarchar](30) NOT NULL,
	[MemberType] [nvarchar](50) NOT NULL,
	[MemberDomain] [nvarchar](128) NOT NULL,
	[MemberName] [nvarchar](255) NOT NULL,
	[DateAdded] [smalldatetime] NULL,
	[SvrID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_ServerLocalGroupMembers] PRIMARY KEY CLUSTERED 
(
	[SvrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Svr]
) ON [Svr]
END
GO
/****** Object:  Table [Svr].[SQLServices]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Svr].[SQLServices]') AND type in (N'U'))
BEGIN
CREATE TABLE [Svr].[SQLServices](
	[ServerName] [nvarchar](128) NOT NULL,
	[ServiceName] [nvarchar](128) NULL,
	[DisplayName] [nvarchar](128) NULL,
	[Started] [bit] NULL,
	[StartMode] [nvarchar](30) NULL,
	[State] [nvarchar](30) NULL,
	[BinaryPath] [nvarchar](500) NULL,
	[LogOnAs] [nvarchar](128) NULL,
	[ProcessId] [int] NULL,
	[DateAdded] [smalldatetime] NULL,
	[SQLID] [int] IDENTITY(1,1) NOT NULL
) ON [Svr]
END
GO
/****** Object:  Table [Svr].[SvrBaselineDriveStats]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Svr].[SvrBaselineDriveStats]') AND type in (N'U'))
BEGIN
CREATE TABLE [Svr].[SvrBaselineDriveStats](
	[ServerName] [nvarchar](128) NOT NULL,
	[Drive] [nvarchar](128) NOT NULL,
	[CounterType] [nvarchar](128) NOT NULL,
	[Value] [decimal](10, 5) NOT NULL,
	[RunDate] [smalldatetime] NOT NULL,
	[SvrDBLID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_SvrBaselineDriveStats] PRIMARY KEY CLUSTERED 
(
	[SvrDBLID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Svr]
) ON [Svr]
END
GO
/****** Object:  Table [Svr].[SvrBaselineStats]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Svr].[SvrBaselineStats]') AND type in (N'U'))
BEGIN
CREATE TABLE [Svr].[SvrBaselineStats](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[RunDate] [smalldatetime] NOT NULL,
	[PctProcTm] [decimal](10, 5) NOT NULL,
	[ProcQLen] [int] NOT NULL,
	[AvDskRd] [decimal](10, 5) NOT NULL,
	[AvDskWt] [decimal](10, 5) NOT NULL,
	[AvDskQLen] [decimal](10, 5) NOT NULL,
	[AvailMB] [bigint] NOT NULL,
	[PgFlUsg] [decimal](10, 5) NOT NULL,
	[SvrBLID] [bigint] IDENTITY(1,1) NOT NULL
) ON [Svr]
END
GO
/****** Object:  Table [Tbl].[HekatonTbls]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Tbl].[HekatonTbls]') AND type in (N'U'))
BEGIN
CREATE TABLE [Tbl].[HekatonTbls](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[DBName] [nvarchar](128) NULL,
	[TblName] [nvarchar](128) NULL,
	[IsMemoryOptimized] [bit] NULL,
	[Durability] [tinyint] NULL,
	[DurabilityDesc] [nvarchar](60) NULL,
	[MemAllocForIdxInKB] [bigint] NULL,
	[MemAllocForTblInKB] [bigint] NULL,
	[MemUsdByIdxInKB] [bigint] NULL,
	[MemUsdByTblInKB] [bigint] NULL,
	[DateAdded] [smalldatetime] NULL,
	[HID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [Tbl].[TblPermissions]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Tbl].[TblPermissions]') AND type in (N'U'))
BEGIN
CREATE TABLE [Tbl].[TblPermissions](
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[DBName] [nvarchar](128) NULL,
	[UserName] [nvarchar](128) NULL,
	[ClassDesc] [nvarchar](60) NULL,
	[ObjName] [nvarchar](128) NULL,
	[PermName] [nvarchar](60) NULL,
	[PermState] [nvarchar](60) NULL,
	[DateAdded] [smalldatetime] NULL,
	[TBLID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
END
GO
/****** Object:  StoredProcedure [dbo].[pBILoginNameData]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pBILoginNameData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pBILoginNameData] AS' 
END
GO

ALTER PROCEDURE [dbo].[pBILoginNameData]
(	
	 @LoginName	nvarchar(4000)	= NULL
	 ,@BIType	nvarchar(50) = null
)
as
BEGIN

	IF @BIType = 'BI'
	BEGIN
		-- Individual with specific grants on the instance
		SELECT	DISTINCT 
			 ir2.RoleName
			,'server' as RoleType
			,'individual' as AccountType
			,COUNT(ir2.RoleName) as RoleCount
		FROM		
			[Inst].[Logins] ir1
		INNER JOIN  
		(	
			SELECT		InstanceName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[Logins]
			GROUP BY	InstanceName
		) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.DateAdded = ir1.DateAdded
		inner join
			[Inst].[InstanceRoles] ir2 on ir2.InstanceName = ir1.InstanceName and ir2.LoginName = ir1.LoginName
		INNER JOIN  
		(	
			SELECT		InstanceName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[InstanceRoles]
			GROUP BY	InstanceName
		) cteNewestData2 on cteNewestData2.InstanceName = ir2.InstanceName and cteNewestData2.DateAdded = ir2.DateAdded
		WHERE ir1.LoginName like @LoginName
		GROUP BY ir2.RoleName
		union all
		-- Group that has a specific individual with specific grants on the instance
		SELECT DISTINCT
			 ir2.RoleName
			 ,'server' as RoleType
			,'group' as AccountType
			,COUNT(ir2.RoleName) as RoleCount
		FROM 
			[Inst].LoginGroupMembers ir1 
		INNER JOIN  
		(	
			SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].LoginGroupMembers 
			GROUP BY	InstanceName, GroupName
		) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
		inner join
			[Inst].[InstanceRoles] ir2 on ir2.InstanceName = ir1.InstanceName and ir2.LoginName = ir1.GroupName
		INNER JOIN  
		(	
			SELECT		InstanceName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[InstanceRoles] 
			GROUP BY	InstanceName
		) cteNewestData2 on cteNewestData2.InstanceName = ir2.InstanceName and cteNewestData2.DateAdded = ir2.DateAdded
		WHERE ir1.LoginName like @LoginName
		GROUP BY ir2.RoleName
union all
		SELECT DISTINCT
			 DBRole			as RoleName
			 ,'db' as RoleType
			 ,'individual' as AccountType	
			,COUNT(DBRole)	as RoleCount
		FROM 
			[DB].[DBUserRoles] ir3 
		INNER JOIN  
		(	
			SELECT		[InstanceName], DBName, DBUser, MAX(DateAdded) AS DateAdded
			FROM		[DB].[DBUserRoles] 
			GROUP BY	[InstanceName], DBName, DBUser
		) cteNewestData2 on cteNewestData2.InstanceName = ir3.InstanceName and cteNewestData2.DBName = ir3.DBName and cteNewestData2.DBUser = ir3.DBUser and cteNewestData2.DateAdded = ir3.DateAdded			 
		WHERE ir3.DBUser like @LoginName
		GROUP BY DBRole
		union all
		SELECT DISTINCT 
			 DBRole			as RoleName
			 ,'db' as RoleType	
			 ,'group' as AccountType
			,COUNT(DBRole)	as RoleCount
		FROM 
			[Inst].[LoginGroupMembers] ir1 
		INNER JOIN  
		(	
			SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[LoginGroupMembers] 
			GROUP BY	InstanceName, GroupName
		) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
		INNER JOIN 
			[DB].[DBUserRoles] ir3 ON ir3.InstanceName = ir1.InstanceName and ir3.DBUser = ir1.GroupName
		INNER JOIN  
		(	
			SELECT		[InstanceName], DBName, DBUser, MAX(DateAdded) AS DateAdded
			FROM		[DB].[DBUserRoles] 
			GROUP BY	[InstanceName], DBName, DBUser
		) cteNewestData2 on cteNewestData2.InstanceName = ir3.InstanceName and cteNewestData2.DBName = ir3.DBName and cteNewestData2.DBUser = ir3.DBUser and cteNewestData2.DateAdded = ir3.DateAdded			 
		WHERE ir1.LoginName like @LoginName
		GROUP BY DBRole
		order by 1
	END

	IF @BIType = 'RoleType'
	BEGIN
		SELECT count(RoleType) CountRoleType, RoleType
		from
		(
		-- Individual with specific grants on the instance
		SELECT	DISTINCT 
			 ir2.RoleName
			,'server' as RoleType
			,'individual' as AccountType
			,COUNT(ir2.RoleName) as RoleCount
		FROM		
			[Inst].[Logins] ir1
		INNER JOIN  
		(	
			SELECT		InstanceName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[Logins]
			GROUP BY	InstanceName
		) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.DateAdded = ir1.DateAdded
		inner join
			[Inst].[InstanceRoles] ir2 on ir2.InstanceName = ir1.InstanceName and ir2.LoginName = ir1.LoginName
		INNER JOIN  
		(	
			SELECT		InstanceName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[InstanceRoles]
			GROUP BY	InstanceName
		) cteNewestData2 on cteNewestData2.InstanceName = ir2.InstanceName and cteNewestData2.DateAdded = ir2.DateAdded
		WHERE ir1.LoginName like @LoginName
		GROUP BY ir2.RoleName
		union all
		-- Group that has a specific individual with specific grants on the instance
		SELECT DISTINCT
			 ir2.RoleName
			 ,'server' as RoleType
			,'group' as AccountType
			,COUNT(ir2.RoleName) as RoleCount
		FROM 
			[Inst].LoginGroupMembers ir1 
		INNER JOIN  
		(	
			SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].LoginGroupMembers
			GROUP BY	InstanceName, GroupName
		) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
		inner join
			[Inst].[InstanceRoles] ir2 on ir2.InstanceName = ir1.InstanceName and ir2.LoginName = ir1.GroupName
		INNER JOIN  
		(	
			SELECT		InstanceName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[InstanceRoles] 
			GROUP BY	InstanceName
		) cteNewestData2 on cteNewestData2.InstanceName = ir2.InstanceName and cteNewestData2.DateAdded = ir2.DateAdded
		WHERE ir1.LoginName like @LoginName
		GROUP BY ir2.RoleName

union all


		SELECT DISTINCT
			 DBRole			as RoleName
			 ,'db' as RoleType
			 ,'individual' as AccountType	
			,COUNT(DBRole)	as RoleCount
		FROM 
			[DB].[DBUserRoles] ir3 
		INNER JOIN  
		(	
			SELECT		[InstanceName], DBName, DBUser, MAX(DateAdded) AS DateAdded
			FROM		[DB].[DBUserRoles] 
			GROUP BY	[InstanceName], DBName, DBUser
		) cteNewestData2 on cteNewestData2.InstanceName = ir3.InstanceName and cteNewestData2.DBName = ir3.DBName and cteNewestData2.DBUser = ir3.DBUser and cteNewestData2.DateAdded = ir3.DateAdded			 
		WHERE ir3.DBUser like @LoginName
		GROUP BY DBRole
		union all
		SELECT DISTINCT 
			 DBRole			as RoleName
			 ,'db' as RoleType	
			 ,'group' as AccountType
			,COUNT(DBRole)	as RoleCount
		FROM 
			[Inst].[LoginGroupMembers] ir1 
		INNER JOIN  
		(	
			SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[LoginGroupMembers] 
			GROUP BY	InstanceName, GroupName
		) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
		INNER JOIN 
			[DB].[DBUserRoles] ir3 ON ir3.InstanceName = ir1.InstanceName and ir3.DBUser = ir1.GroupName
		INNER JOIN  
		(	
			SELECT		[InstanceName], DBName, DBUser, MAX(DateAdded) AS DateAdded
			FROM		[DB].[DBUserRoles] 
			GROUP BY	[InstanceName], DBName, DBUser
		) cteNewestData2 on cteNewestData2.InstanceName = ir3.InstanceName and cteNewestData2.DBName = ir3.DBName and cteNewestData2.DBUser = ir3.DBUser and cteNewestData2.DateAdded = ir3.DateAdded			 
		WHERE ir1.LoginName like @LoginName
		GROUP BY DBRole
) x 
group by RoleType
	END

	IF @BIType = 'AccountType'
	BEGIN
		SELECT count(AccountType) CountAccountType, AccountType
		from
		(

		-- Individual with specific grants on the instance
		SELECT	DISTINCT 
			 ir2.RoleName
			,'server' as RoleType
			,'individual' as AccountType
			,COUNT(ir2.RoleName) as RoleCount
		FROM		
			[Inst].[Logins] ir1
		INNER JOIN  
		(	
			SELECT		InstanceName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[Logins]
			GROUP BY	InstanceName
		) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.DateAdded = ir1.DateAdded
		inner join
			[Inst].[InstanceRoles] ir2 on ir2.InstanceName = ir1.InstanceName and ir2.LoginName = ir1.LoginName
		INNER JOIN  
		(	
			SELECT		InstanceName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[InstanceRoles]
			GROUP BY	InstanceName
		) cteNewestData2 on cteNewestData2.InstanceName = ir2.InstanceName and cteNewestData2.DateAdded = ir2.DateAdded
		WHERE ir1.LoginName like @LoginName
		GROUP BY ir2.RoleName
		union all
		-- Group that has a specific individual with specific grants on the instance
		SELECT DISTINCT
			 ir2.RoleName
			 ,'server' as RoleType
			,'group' as AccountType
			,COUNT(ir2.RoleName) as RoleCount
		FROM 
			[Inst].LoginGroupMembers ir1 
		INNER JOIN  
		(	
			SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].LoginGroupMembers 
			GROUP BY	InstanceName, GroupName
		) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
		inner join
			[Inst].[InstanceRoles] ir2 on ir2.InstanceName = ir1.InstanceName and ir2.LoginName = ir1.GroupName
		INNER JOIN  
		(	
			SELECT		InstanceName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[InstanceRoles]
			GROUP BY	InstanceName
		) cteNewestData2 on cteNewestData2.InstanceName = ir2.InstanceName and cteNewestData2.DateAdded = ir2.DateAdded
		WHERE ir1.LoginName like @LoginName
		GROUP BY ir2.RoleName
		union all
				SELECT DISTINCT
					 DBRole			as RoleName
					 ,'db' as RoleType
					 ,'individual' as AccountType	
					,COUNT(DBRole)	as RoleCount
				FROM 
					[DB].[DBUserRoles] ir3 
				INNER JOIN  
				(	
					SELECT		[InstanceName], DBName, DBUser, MAX(DateAdded) AS DateAdded
					FROM		[DB].[DBUserRoles] 
					GROUP BY	[InstanceName], DBName, DBUser
				) cteNewestData2 on cteNewestData2.InstanceName = ir3.InstanceName and cteNewestData2.DBName = ir3.DBName and cteNewestData2.DBUser = ir3.DBUser and cteNewestData2.DateAdded = ir3.DateAdded			 
				WHERE ir3.DBUser like @LoginName
				GROUP BY DBRole
				union all
				SELECT DISTINCT 
					 DBRole			as RoleName
					 ,'db' as RoleType	
					 ,'group' as AccountType
					,COUNT(DBRole)	as RoleCount
				FROM 
					[Inst].[LoginGroupMembers] ir1 
				INNER JOIN  
				(	
					SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
					FROM		[Inst].[LoginGroupMembers] 
					GROUP BY	InstanceName, GroupName
				) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
				INNER JOIN 
					[DB].[DBUserRoles] ir3 ON ir3.InstanceName = ir1.InstanceName and ir3.DBUser = ir1.GroupName
				INNER JOIN  
				(	
					SELECT		[InstanceName], DBName, DBUser, MAX(DateAdded) AS DateAdded
					FROM		[DB].[DBUserRoles] 
					GROUP BY	[InstanceName], DBName, DBUser
				) cteNewestData2 on cteNewestData2.InstanceName = ir3.InstanceName and cteNewestData2.DBName = ir3.DBName and cteNewestData2.DBUser = ir3.DBUser and cteNewestData2.DateAdded = ir3.DateAdded			 
				WHERE ir1.LoginName like @LoginName
				GROUP BY DBRole
		) x 
		group by AccountType
	END

	IF @BIType = 'AccessLevel'
	BEGIN
		SELECT count(x.RoleName) CountRoleName, case when y.AccessLevel is null then 'Custom' else y.AccessLevel end as AccessLevel
		from
		(
				-- Individual with specific grants on the instance
				SELECT	DISTINCT 
					 ir2.RoleName
					,'server' as RoleType
					,'individual' as AccountType
					,COUNT(ir2.RoleName) as RoleCount
				FROM		
					[Inst].[Logins] ir1
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[Inst].[Logins]
					GROUP BY	InstanceName
				) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.DateAdded = ir1.DateAdded
				inner join
					[Inst].[InstanceRoles] ir2 on ir2.InstanceName = ir1.InstanceName and ir2.LoginName = ir1.LoginName
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[Inst].[InstanceRoles]
					GROUP BY	InstanceName
				) cteNewestData2 on cteNewestData2.InstanceName = ir2.InstanceName and cteNewestData2.DateAdded = ir2.DateAdded
				WHERE ir1.LoginName like @LoginName
				GROUP BY ir2.RoleName
				union all
				-- Group that has a specific individual with specific grants on the instance
				SELECT DISTINCT
					 ir2.RoleName
					 ,'server' as RoleType
					,'group' as AccountType
					,COUNT(ir2.RoleName) as RoleCount
				FROM 
					[Inst].LoginGroupMembers ir1 
				INNER JOIN  
				(	
					SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
					FROM		[Inst].LoginGroupMembers 
					GROUP BY	InstanceName, GroupName
				) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
				inner join
					[Inst].[InstanceRoles] ir2 on ir2.InstanceName = ir1.InstanceName and ir2.LoginName = ir1.GroupName
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[Inst].[InstanceRoles] 
					GROUP BY	InstanceName
				) cteNewestData2 on cteNewestData2.InstanceName = ir2.InstanceName and cteNewestData2.DateAdded = ir2.DateAdded
				WHERE ir1.LoginName like @LoginName
				GROUP BY ir2.RoleName

		union all


				SELECT DISTINCT
					 DBRole			as RoleName
					 ,'db' as RoleType
					 ,'individual' as AccountType	
					,COUNT(DBRole)	as RoleCount
				FROM 
					[DB].[DBUserRoles] ir3 
				INNER JOIN  
				(	
					SELECT		[InstanceName], DBName, DBUser, MAX(DateAdded) AS DateAdded
					FROM		[DB].[DBUserRoles] 
					GROUP BY	[InstanceName], DBName, DBUser
				) cteNewestData2 on cteNewestData2.InstanceName = ir3.InstanceName and cteNewestData2.DBName = ir3.DBName and cteNewestData2.DBUser = ir3.DBUser and cteNewestData2.DateAdded = ir3.DateAdded			 
				WHERE ir3.DBUser like @LoginName
				GROUP BY DBRole
				union all
				SELECT DISTINCT 
					 DBRole			as RoleName
					 ,'db' as RoleType	
					 ,'group' as AccountType
					,COUNT(DBRole)	as RoleCount
				FROM 
					[Inst].[LoginGroupMembers] ir1 
				INNER JOIN  
				(	
					SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
					FROM		[Inst].[LoginGroupMembers] 
					GROUP BY	InstanceName, GroupName
				) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
				INNER JOIN 
					[DB].[DBUserRoles] ir3  ON ir3.InstanceName = ir1.InstanceName and ir3.DBUser = ir1.GroupName
				INNER JOIN  
				(	
					SELECT		[InstanceName], DBName, DBUser, MAX(DateAdded) AS DateAdded
					FROM		[DB].[DBUserRoles] 
					GROUP BY	[InstanceName], DBName, DBUser
				) cteNewestData2 on cteNewestData2.InstanceName = ir3.InstanceName and cteNewestData2.DBName = ir3.DBName and cteNewestData2.DBUser = ir3.DBUser and cteNewestData2.DateAdded = ir3.DateAdded			 
				WHERE ir1.LoginName like @LoginName
				GROUP BY DBRole
		) x 
		left outer join
		(
		select DBRole as RoleName, case when DBRole = 'db_owner' then 'Elevated'
		when DBRole = 'db_securityadmin' then 'Elevated'
		when DBRole = 'db_ddladmin' then 'Elevated'
		when DBRole = 'db_accessadmin' then 'Elevated'
		else 'Non-Elevated' end as AccessLevel
			from [DB].[DBUserRolesDescription]
		union all
		select RoleName, case when RoleName = 'dbcreator' then 'Elevated'
		when RoleName = 'diskadmin' then 'Elevated'
		when RoleName = 'processadmin' then 'Elevated'
		when RoleName = 'securityadmin' then 'Elevated'
		when RoleName = 'serveradmin' then 'Elevated'
		when RoleName = 'sysadmin' then 'Elevated'
		else 'Non-Elevated' end as AccessLevel
			from [Inst].[InstanceRolesDescription]
		) y on 
		x.RoleName = y.RoleName
		group by y.AccessLevel
	END

	IF @BIType = 'OrphanUser'
	BEGIN
		SELECT
			z.Status, COUNT(z.Status) CountStatus
		FROM
		(
			SELECT 
				CASE WHEN x.LoginName is null THEN 'Orphaned' ELSE 'Linked' END as Status, y.DBUser as LoginName
			FROM
			(
			SELECT DISTINCT ir1.InstanceName, ir1.DBUser
			FROM [DB].[DBUserRoles] ir1
			INNER JOIN  
			(	
				SELECT		InstanceName, MAX(DateAdded) AS DateAdded
				FROM		[DB].[DBUserRoles]
				GROUP BY	InstanceName
			) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.DateAdded = ir1.DateAdded
			WHERE ir1.DBUser like @LoginName
			) y
			left outer join 
			(		
				SELECT	 
					DISTINCT ir1.InstanceName, ir1.LoginName
				FROM		
					[Inst].[Logins] ir1
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[Inst].[Logins]
					GROUP BY	InstanceName
				) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.DateAdded = ir1.DateAdded
				WHERE ir1.LoginName like @LoginName
			) x on x.LoginName = y.DBUser and x.InstanceName = y.InstanceName
		) z
		group by z.Status
	END

END
GO
/****** Object:  StoredProcedure [dbo].[pCleanupData]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pCleanupData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pCleanupData] AS' 
END
GO
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[pCleanupData]
(
	  @DelInv		smallint = -30,		-- 1 Month
	  @DelGrwth		smallint = -90,	    -- 3 Months
	  @DelStats		smallint = -365,	-- 12 Months
      @DelCntr		smallint = -180,	-- 6 Months
	  @DelFRKDate	smallint = -180,	-- 6 Months
	  @ServerName	nvarchar(255) = null

)
AS
BEGIN

SET NOCOUNT ON;

/*### [Inst] ##################################################################################*/
DELETE FROM [Inst].[CommandLog]				WHERE DateCreated < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[CommandLogArchive]		WHERE DateCreated < dateadd(day, @DelCntr, getdate());
DELETE FROM [Inst].[InsBaselineStats]		WHERE RunDate   < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[InstanceInfo]			WHERE DateAdded < dateadd(day, @DelCntr, getdate());
DELETE FROM [Inst].[InstanceRoles]			WHERE DateAdded < dateadd(day, @DelCntr, getdate());
DELETE FROM [Inst].[InsTriggers]			WHERE DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[Jobs]					WHERE DateAdded < dateadd(day, @DelCntr, getdate());
DELETE FROM [Inst].[JobsFailed]				WHERE DateAdded < dateadd(day, @DelCntr, getdate());
DELETE FROM [Inst].[LinkedServers]			WHERE DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[Logins]					WHERE DateAdded < dateadd(day, @DelCntr, getdate());
DELETE FROM [Inst].[MissingIndexes]			WHERE DateAdded < dateadd(day, @DelGrwth, getdate());
DELETE FROM [Inst].[Replication]			WHERE DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[WaitStats]				WHERE DateAdded < dateadd(day, @DelGrwth, getdate());
/*### [Inst] ##################################################################################*/

/*### [Svr] ##################################################################################*/
DELETE FROM [Svr].[DiskInfo]				Where  DateAdded < dateadd(day, @DelCntr, getdate());
DELETE FROM [Svr].[OSInfo]					WHERE  DateAdded < dateadd(day, @DelGrwth, getdate());
DELETE FROM [Svr].[PgFileUsage]				WHERE  DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Svr].[ServerInfo]				WHERE  DateAdded < dateadd(day, @DelCntr, getdate());
DELETE FROM [Svr].[SQLServices]				WHERE  DateAdded < dateadd(day, @DelGrwth, getdate());
DELETE FROM [Svr].[SvrBaselineStats]		Where  RunDate < dateadd(day, @DelInv, getdate());
DELETE FROM [Svr].[OSPatchInfo]				Where  DateAdded < dateadd(day, @DelCntr, getdate());
/*### [Svr] ######################################################*/

/*### [DB] ######################################################*/
DELETE FROM [DB].[AvailDatabases]			WHERE  DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [DB].[AvailGroups]				WHERE  DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [DB].[AvailReplicas]			WHERE  DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [DB].[DatabaseBackups]			WHERE  DateAdded < dateadd(day, @DelCntr, getdate());
DELETE FROM [DB].[DatabaseFiles]			WHERE  DateAdded < dateadd(day, @DelGrwth, getdate());
DELETE FROM [DB].[DatabaseInfo]				WHERE  DateAdded < dateadd(day, @DelCntr, getdate());
DELETE FROM [DB].[DBFileGrowth]				WHERE  DateAdded < dateadd(day, @DelGrwth, getdate());
DELETE FROM [DB].[DBUserRoles]				WHERE  DateAdded < dateadd(day, @DelCntr, getdate());
DELETE FROM [DB].[Triggers]					WHERE  DateAdded < dateadd(day, @DelInv, getdate());
/*### [DB] ######################################################*/

/*### [TBL] ######################################################*/
DELETE FROM [Tbl].[HekatonTbls]				WHERE  DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Tbl].[TblPermissions]			WHERE  DateAdded < dateadd(day, @DelInv, getdate());
/*### [TBL] ######################################################*/

/*### [AS] ######################################################*/
DELETE FROM [AS].[SSASDBInfo]				WHERE  DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [AS].[SSASInfo]					WHERE  DateAdded < dateadd(day, @DelInv, getdate());
/*### [AS] ######################################################*/

/*### [RS] ######################################################*/
DELETE FROM [RS].[SSRSConfig]				WHERE  DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [RS].[SSRSInfo]					WHERE  DateAdded < dateadd(day, @DelInv, getdate());
/*### [RS] ######################################################*/

/*### [FRK] ######################################################*/
DELETE FROM [FRK].[Blitz]					WHERE  [CheckDate] < dateadd(day, @DelFRKDate, getdate());
DELETE FROM [FRK].[BlitzCache]				WHERE  [CheckDate] < dateadd(day, @DelFRKDate, getdate());
DELETE FROM [FRK].[BlitzFirst]				WHERE  [CheckDate] < dateadd(day, @DelFRKDate, getdate());
DELETE FROM [FRK].[BlitzFirst_FileStats]	WHERE  [CheckDate] < dateadd(day, @DelFRKDate, getdate());
DELETE FROM [FRK].[BlitzFirst_PerfmonStats] WHERE  [CheckDate] < dateadd(day, @DelFRKDate, getdate());
DELETE FROM [FRK].[BlitzFirst_WaitStats]	WHERE  [CheckDate] < dateadd(day, @DelFRKDate, getdate());
/*### [FRK] ######################################################*/

END
GO
/****** Object:  StoredProcedure [dbo].[pCleanupDataByServer]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pCleanupDataByServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pCleanupDataByServer] AS' 
END
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[pCleanupDataByServer]
(
	  @DelInv		smallint = -30,		-- 1 Month
	  @DelGrwth		smallint = -90,	    -- 3 Months
	  @DelStats		smallint = -365,	-- 12 Months
      @DelCntr		smallint = -180,	-- 6 Months
	  @DelFRKDate	smallint = -180,	-- 6 Months
	  @ServerName	nvarchar(255) = null

)
AS
BEGIN

SET NOCOUNT ON;

/*### [Inst] ##################################################################################*/
DELETE FROM [Inst].[CommandLog]				WHERE ServerName = @ServerName AND DateCreated < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[CommandLogArchive]		WHERE ServerName = @ServerName AND DateCreated < dateadd(day, @DelCntr, getdate());
DELETE FROM [Inst].[InsBaselineStats]		WHERE ServerName = @ServerName AND RunDate   < dateadd(day, @DelCntr, getdate());
DELETE FROM [Inst].[InstanceInfo]			WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[InstanceRoles]			WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[InsTriggers]			WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[Jobs]					WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[JobsFailed]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[LinkedServers]			WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[Logins]					WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[MissingIndexes]			WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelStats, getdate());
DELETE FROM [Inst].[Replication]			WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Inst].[WaitStats]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelStats, getdate());
/*### [Inst] ##################################################################################*/

/*### [Svr] ##################################################################################*/
DELETE FROM [Svr].[DiskInfo]				Where ServerName = @ServerName AND DateAdded < dateadd(day, @DelGrwth, getdate());
DELETE FROM [Svr].[OSInfo]					WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Svr].[PgFileUsage]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Svr].[ServerInfo]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Svr].[SQLServices]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Svr].[SvrBaselineStats]		Where ServerName = @ServerName AND RunDate < dateadd(day, @DelCntr, getdate());
DELETE FROM [Svr].[OSPatchInfo]				Where ServerName = @ServerName AND DateAdded < dateadd(day, @DelCntr, getdate());
/*### [Svr] ##################################################################################*/

/*### [DB] ##################################################################################*/
DELETE FROM [DB].[AvailDatabases]			WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [DB].[AvailGroups]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [DB].[AvailReplicas]			WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [DB].[DatabaseBackups]			WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelCntr, getdate());
DELETE FROM [DB].[DatabaseFiles]			WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [DB].[DatabaseInfo]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [DB].[DBFileGrowth]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelGrwth, getdate());
DELETE FROM [DB].[DBUserRoles]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [DB].[Triggers]					WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
/*### [DB] ##################################################################################*/

/*### [TBL] ##################################################################################*/
DELETE FROM [Tbl].[HekatonTbls]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [Tbl].[TblPermissions]			WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
/*### [TBL] ##################################################################################*/

/*### [AS] ##################################################################################*/
DELETE FROM [AS].[SSASDBInfo]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [AS].[SSASInfo]					WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
/*### [AS] ##################################################################################*/

/*### [RS] ##################################################################################*/
DELETE FROM [RS].[SSRSConfig]				WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
DELETE FROM [RS].[SSRSInfo]					WHERE ServerName = @ServerName AND DateAdded < dateadd(day, @DelInv, getdate());
/*### [RS] ##################################################################################*/

/*### [FRK] ##################################################################################*/
DELETE FROM [FRK].[Blitz]					WHERE ServerName = @ServerName AND [CheckDate] < dateadd(day, @DelFRKDate, getdate());
DELETE FROM [FRK].[BlitzCache]				WHERE ServerName = @ServerName AND [CheckDate] < dateadd(day, @DelFRKDate, getdate());
DELETE FROM [FRK].[BlitzFirst]				WHERE ServerName = @ServerName AND [CheckDate] < dateadd(day, @DelFRKDate, getdate());
DELETE FROM [FRK].[BlitzFirst_FileStats]	WHERE ServerName = @ServerName AND [CheckDate] < dateadd(day, @DelFRKDate, getdate());
DELETE FROM [FRK].[BlitzFirst_PerfmonStats] WHERE ServerName = @ServerName AND [CheckDate] < dateadd(day, @DelFRKDate, getdate());
DELETE FROM [FRK].[BlitzFirst_WaitStats]	WHERE ServerName = @ServerName AND [CheckDate] < dateadd(day, @DelFRKDate, getdate());
/*### [FRK] ##################################################################################*/

END
GO
/****** Object:  StoredProcedure [dbo].[pCollectSQLUpdateVersionDetails]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pCollectSQLUpdateVersionDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pCollectSQLUpdateVersionDetails] AS' 
END
GO


  ALTER PROCEDURE [dbo].[pCollectSQLUpdateVersionDetails]
  (
	 @KBNumber	nvarchar(12)
   , @Path		nvarchar(255)
   , @Binary	nvarchar(255)
  )
  AS
  BEGIN
  
  DECLARE 
	  @URL varchar(99)
	 ,@ErrorMessage varchar(max)



	BEGIN TRY   

		IF len(isnull(@KBNumber, '')) = 0
		BEGIN
			SET @ErrorMessage = isnull(@KBNumber, '') + ' Not Found'; RAISERROR (@ErrorMessage,1,1); 
		END

		SELECT @URL = URL FROM dbo.vwSQLServerUpdates WHERE [KBNumber] = @KBNumber
	
		IF @URL is not null and EXISTS(SELECT 1 FROM [dbo].[SqlServerVersionDetails] WHERE [URL] = @URL)
		BEGIN
			UPDATE [dbo].[SqlServerVersionDetails] 
			SET 
			     [Path]		 = @Path
				,[Binary]	 = @Binary
				,[DateAdded] = GetDate()
			WHERE
				[URL]		 = @URL
		END
		ELSE IF @URL is not null
		BEGIN
			INSERT INTO  [dbo].[SqlServerVersionDetails] ([URL], [Path], [Binary])
			VALUES(@URL, @Path, @Binary)
		END
		ELSE
		BEGIN
			SET @ErrorMessage = @KBNumber + ' Not Found'
			RAISERROR (@ErrorMessage,16,1); 
		END

	END TRY
	BEGIN CATCH
		set @ErrorMessage = ERROR_MESSAGE();
		RAISERROR (@ErrorMessage,16,1);
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[pCompareOSPatches]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pCompareOSPatches]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pCompareOSPatches] AS' 
END
GO


ALTER PROCEDURE [dbo].[pCompareOSPatches]
(	
	 @Server1	nvarchar(255)	= NULL
	,@Server2	nvarchar(255)	= NULL
	,@VerifyOS	bit = 1
)
as
BEGIN

DECLARE @count int
SELECT TOP 1 @Count = COUNT(OSName) FROM svr.OSInfo si
INNER JOIN (SELECT ServerName, Max(DateAdded) DateAdded From Svr.OSInfo GROUP BY ServerName) x on x.DateAdded = si.DateAdded and x.ServerName = si.ServerName
WHERE si.ServerName in (@Server1, @Server2)
GROUP BY OSName

IF @count = 2
BEGIN
	;with cteServer1
	as
	(
	SELECT pi.ServerName, pi.Caption, pi.Description, pi.HotFixID, pi.InstalledBy, pi.InstalledOn  FROM svr.OSPatchInfo pi
	INNER JOIN (SELECT ServerName, Max(DateAdded) DateAdded From Svr.OSPatchInfo GROUP BY ServerName) x on x.DateAdded = pi.DateAdded and x.ServerName = pi.ServerName
	WHERE pi.ServerName = @Server1
	)
	,cteServer2
	as
	(
	SELECT pi.ServerName, pi.Caption, pi.Description, pi.HotFixID, pi.InstalledBy, pi.InstalledOn FROM svr.OSPatchInfo pi
	INNER JOIN (SELECT ServerName, Max(DateAdded) DateAdded From Svr.OSPatchInfo GROUP BY ServerName) x on x.DateAdded = pi.DateAdded and x.ServerName = pi.ServerName
	WHERE pi.ServerName = @Server2
	)

	SELECT isnull(a.ServerName, '') as ServerNameA, isnull(a.Caption, '') as CaptionA, isnull(a.Description, '') as DescriptionA, isnull(a.HotFixID, '') as HotFixIDA, isnull(a.InstalledBy, '') as InstalledByA, isnull(a.InstalledOn, '') as InstalledOnA,
		   isnull(b.ServerName, '') as ServerNameB, isnull(b.Caption, '') as CaptionB, isnull(b.Description, '') as DescriptionB, isnull(b.HotFixID, '') as HotFixIDB, isnull(b.InstalledBy, '') as InstalledByB, isnull(b.InstalledOn, '') as InstalledOnB
	FROM cteServer1 a
	full outer join cteServer2 b on b.HotFixID = a.HotFixID 
	order by isnull(a.InstalledOn, b.InstalledOn) DESC, isnull(a.HotFixID, b.HotFixID) ASC
END
ELSE
BEGIN

	SELECT a.ServerName as ServerNameA, a.Caption as CaptionA, a.Description as DescriptionA, a.HotFixID as HotFixIDA, a.InstalledBy as InstalledByA, a.InstalledOn as InstalledOnA,
		   b.ServerName as ServerNameB, b.Caption as CaptionB, b.Description as DescriptionB, b.HotFixID as HotFixIDB, b.InstalledBy as InstalledByB, b.InstalledOn as InstalledOnB
	FROM
	(SELECT TOP 1 si.ServerName, si.OSName as Caption, 'The OS versions do not match.' as Description, '' as HotFixID, '' as InstalledBy, '' as InstalledOn FROM svr.OSInfo si INNER JOIN (SELECT ServerName, Max(DateAdded) DateAdded From Svr.OSInfo GROUP BY ServerName) x on x.DateAdded = si.DateAdded and x.ServerName = si.ServerName WHERE si.ServerName in (@Server1)) a
	cross apply 
	(SELECT TOP 1 si.ServerName, si.OSName as Caption, 'The OS versions do not match.' as Description, '' as HotFixID, '' as InstalledBy, '' as InstalledOn FROM svr.OSInfo si INNER JOIN (SELECT ServerName, Max(DateAdded) DateAdded From Svr.OSInfo GROUP BY ServerName) x on x.DateAdded = si.DateAdded and x.ServerName = si.ServerName WHERE si.ServerName in (@Server2)) b
END

	Return
END
GO
/****** Object:  StoredProcedure [dbo].[pSQLServerUpdates]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pSQLServerUpdates]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pSQLServerUpdates] AS' 
END
GO


ALTER PROCEDURE [dbo].[pSQLServerUpdates]
(	
	  @LatestVersionOnly	bit	= 1
	 ,@MajorVersionName		nvarchar(255) = '-'
	 ,@ListMajorVersionName	bit = 0
)
AS
BEGIN

	IF @ListMajorVersionName = 1
	BEGIN
		
		SELECT 'SQL Server All' as Display, '-' as Value
		union
		SELECT 
			MajorVersionName	as Display, MajorVersionName as Value			
		FROM [dbo].[vwSQLServerUpdates] 
		GROUP BY 
			MajorVersionName
		ORDER BY 
			Display DESC
	END
	ELSE
	BEGIN

		if @MajorVersionName = '-' set @MajorVersionName = null

		IF @LatestVersionOnly = 1 
		BEGIN
			SELECT 
				  MajorVersionName
				, MinorVersionName
				, KBNumber
				, URL as GoToURL
				, cast(MajorVersionNumber as nvarchar(3)) + CASE WHEN MajorVersionName = 'SQL Server 2008 R2' THEN '.50.' ELSE '.0.' END + cast(MinorVersionNumber as nvarchar(5)) SQLBuildNumber
				, CONVERT(nvarchar(10), ReleaseDate, 120) + ' (' + cast(NumberOfDaysOld as varchar(10)) + ' Days Old)' ReleaseDate
				, UpdateToThisVersion
				, LatestRelease
			FROM [dbo].[vwSQLServerUpdates] 
			WHERE 
				UpdateToThisVersion = '*' 
				and (@MajorVersionName is null or @MajorVersionName = MajorVersionName)
			ORDER BY
				  MajorVersionNumber DESC
				, SQLBuildNumber DESC
				, ReleaseDate DESC
		END
		ELSE
		BEGIN
	
			SELECT 
				  MajorVersionName
				, MinorVersionName
				, KBNumber
				, URL as GoToURL
				, cast(MajorVersionNumber as nvarchar(3)) + CASE WHEN MajorVersionName = 'SQL Server 2008 R2' THEN '.50.' ELSE '.0.' END + cast(MinorVersionNumber as nvarchar(5)) SQLBuildNumber
				, CONVERT(nvarchar(10), ReleaseDate, 120) + ' (' + cast(NumberOfDaysOld as varchar(10)) + ' Days Old)' ReleaseDate
				, UpdateToThisVersion
				, LatestRelease
			FROM [dbo].[vwSQLServerUpdates] 
			WHERE (@MajorVersionName is null or @MajorVersionName = MajorVersionName)
			ORDER BY
				  MajorVersionNumber DESC
				, SQLBuildNumber DESC
				, ReleaseDate DESC
	
		END
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_AGDatabases]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_AGDatabases]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_AGDatabases] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_AGDatabases]
(
@Environment Varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Parsing values into table
Select Item
into #Environ_List
From
dbo.DelimitedSplit8K(@Environment,',')

--Serverinfo View

Select z.[AGDBName], z.[AGName], z.[PrimaryReplica], z.[AGDBCreateDate], z.[DateAdded], v.Environment from [DB].[AvailDatabases]  z
inner join(
select Distinct ServerName, InstanceName, Environment from  [Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.Item
WHERE DateAdded >= CAST(GETDATE() AS DATE)
Order by Z.PrimaryReplica
END
GO
/****** Object:  StoredProcedure [dbo].[usp_AGGroups]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_AGGroups]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_AGGroups] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_AGGroups]
(
@Environment Varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Parsing values into table
Select Item
into #Environ_List
From
dbo.DelimitedSplit8K(@Environment,',')

--Serverinfo View

Select distinct z.[AGName], z.[PrimaryReplica], z.[SyncHealth], z.[BackupPreference], z.[ListenerName], z.[DateAdded], v.Environment from (
select  y.* from(
select ListenerName,  Max(DateAdded) as Rundate 
from [DB].[AvailGroups]
Group BY  ListenerName) x
Join [DB].[AvailGroups] y ON x.Rundate = y.DateAdded and X.ListenerName = y.ListenerName) z
inner join(
select Distinct ServerName, InstanceName, Environment from  [Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.Item
Order by Z.PrimaryReplica
END
GO
/****** Object:  StoredProcedure [dbo].[usp_AGReplicas]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_AGReplicas]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_AGReplicas] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_AGReplicas]
(
@ReplicaName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--Instance Failed Jobs info
    SELECT  y.[InstanceName],y.[ReplicaName],y.[AGName], y.[Role],y.[FailoverMode], y.[AGCreateDate], y.[DateAdded]
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM     [DB].[AvailReplicas]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [DB].[AvailReplicas] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.ReplicaName = @ReplicaName
Order By ReplicaName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_ASDBInfo]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ASDBInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_ASDBInfo] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_ASDBInfo]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--AS DB info
SELECT y.ServerName, y.InstanceName, y.DBName, y.DBSizeInMB, y.Collation, y.CompatibilityLevel, y.DBCreateDate, 
 CASE WHEN  y.DBLastProcessed = '12/30/1699 4:00:00 PM' Then 'Never'ELSE y.DBLastProcessed End as DBLastProcessed, 
y.DBLastUpdated, y.DBStorageLocation, y.NoOfCubes, y.NoOfDimensions, y.ReadWriteMode, y.StorgageEngineUsed, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [AS].SSASDBInfo
                  GROUP BY InstanceName) AS x INNER JOIN
                  [AS].SSASDBInfo AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_ASInfo]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ASInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_ASInfo] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_ASInfo]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--AS Instance info
  SELECT y.ServerName, y.InstanceName, y.ASVersion, Y.ASPatchLevel, Y.ASEdition, Y.ASVersionNo, Y.NoOfDBs, Y.LastSchemaUpdate, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [AS].[SSASInfo]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [AS].[SSASInfo] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_ASOverview]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ASOverview]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_ASOverview] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_ASOverview]
(
@Environment Varchar(128),
@ASVersion varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Parsing values into table
Select Item
into #Environ_List
From
dbo.DelimitedSplit8K(@Environment,',')

Select Item
into #SQL_Name_List
From
dbo.DelimitedSplit8K(@ASVersion,',')


--Serverinfo View
Select z.InstanceName, z.ASVersion, z.ASPatchLevel, z.IsSPUpToDateOnAS,z.ASEdition, z.NoOfDBs, v.Environment from (
select  y.* from(
select InstanceName, Max(DateAdded) as Rundate 
from [AS].[SSASInfo]
Group BY InstanceName) x
Join [AS].[SSASInfo] y ON x.Rundate = y.DateAdded and X.InstanceName = y.InstanceName) z
inner join(
select Distinct ServerName, InstanceName, Environment, Description, BusinessOwner from  [Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.item
inner join #SQL_Name_List as SQLList on Z.ASVersion = SQLList.item
Order by InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DailyPurgeData]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DailyPurgeData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_DailyPurgeData] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_DailyPurgeData]
(

--DECLARE
	  @DelInv		smallint = -30,		-- 1 Month
	  @DelGrwth		smallint = -90,	    -- 3 Months
	  @DelStats		smallint = -365,	-- 12 Months
      @DelCntr		smallint = -180,	-- 6 Months
	  @DelFRKDate	smallint = -180,	-- 6 Months
	  @Top			int		 = 100
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tableList table
	(
		TableName	nvarchar(255),
		WhereClause	nvarchar(1000),
		TableListID int identity (1,1)
	)

	DECLARE @dynamicSQL nvarchar(max)
	DECLARE @tableName nvarchar(255)
	DECLARE @i int = 0, @c int = 0		--outerloop (per table)
	DECLARE @ii int = 0, @cc int = 0	--innerloop (per 1000 record loop)

/*### [LOAD Tables] #############################################################################*/
insert into @tableList (TableName, WhereClause)
values 
 ('[Inst].[CommandLog]'					,'WHERE [DateCreated] < dateadd(day, @DelInv, getdate());')
,('[Inst].[CommandLogArchive]'			,'WHERE [DateCreated] < dateadd(day, @DelCntr, getdate());')
,('[Inst].[InsBaselineStats]'			,'WHERE [RunDate]   < dateadd(day, @DelInv, getdate());')
,('[Inst].[InstanceInfo]'				,'WHERE [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[Inst].[InstanceRoles]'				,'WHERE [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[Inst].[InsTriggers]'				,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[Inst].[Jobs]'						,'WHERE [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[Inst].[JobsFailed]'					,'WHERE [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[Inst].[JobHistory]'					,'WHERE [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[Inst].[LinkedServers]'				,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[Inst].[Logins]'						,'WHERE [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[Inst].[MissingIndexes]'				,'WHERE [DateAdded] < dateadd(day, @DelGrwth, getdate());')
,('[Inst].[Replication]'				,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[Inst].[WaitStats]'					,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[Svr].[DiskInfo]'					,'Where [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[Svr].[OSInfo]'						,'WHERE [DateAdded] < dateadd(day, @DelGrwth, getdate());')
,('[Svr].[OSPatchInfo]'					,'WHERE [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[Svr].[PgFileUsage]'					,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[Svr].[ServerInfo]'					,'WHERE [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[Svr].[SQLServices]'					,'WHERE [DateAdded] < dateadd(day, @DelGrwth, getdate());')
,('[Svr].[SvrBaselineStats]'			,'Where [RunDate] < dateadd(day, @DelInv, getdate());')
,('[DB].[AvailDatabases]'				,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[DB].[AvailGroups]'					,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[DB].[AvailReplicas]'				,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[DB].[DatabaseBackups]'				,'WHERE [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[DB].[DatabaseFiles]'				,'WHERE [DateAdded] < dateadd(day, @DelGrwth, getdate());')
,('[DB].[DatabaseInfo]'					,'WHERE [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[DB].[DBFileGrowth]'					,'WHERE [DateAdded] < dateadd(day, @DelGrwth, getdate());')
,('[DB].[DBUserRoles]'					,'WHERE [DateAdded] < dateadd(day, @DelCntr, getdate());')
,('[DB].[Triggers]'						,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[Tbl].[HekatonTbls]'					,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[Tbl].[TblPermissions]'				,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[AS].[SSASDBInfo]'					,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[AS].[SSASInfo]'						,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[RS].[SSRSConfig]'					,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[RS].[SSRSInfo]'						,'WHERE [DateAdded] < dateadd(day, @DelInv, getdate());')
,('[FRK].[Blitz]'						,'WHERE [CheckDate] < dateadd(day, @DelFRKDate, getdate());')		
,('[FRK].[BlitzCache]'					,'WHERE [CheckDate] < dateadd(day, @DelFRKDate, getdate());')
,('[FRK].[BlitzFirst]'					,'WHERE [CheckDate] < dateadd(day, @DelFRKDate, getdate());')
,('[FRK].[BlitzFirst_FileStats]'		,'WHERE [CheckDate] < dateadd(day, @DelFRKDate, getdate());')
,('[FRK].[BlitzFirst_PerfmonStats]'		,'WHERE [CheckDate] < dateadd(day, @DelFRKDate, getdate());')
,('[FRK].[BlitzFirst_WaitStats]'		,'WHERE [CheckDate] < dateadd(day, @DelFRKDate, getdate());')

/*### [OUTER LOOP] #############################################################################*/
SELECT @c = MAX(TableListID) FROM @tableList
WHILE @i <= @c
BEGIN
	SET @i = @i + 1
	SELECT @ii = 0, @cc = 0, @dynamicSQL = null
	SELECT @tableName = TableName, @dynamicSQL = 'SELECT @cc = CEILING(COUNT(*)*1.0/@Top * 1.0) FROM ' + TableName + ' ' + WhereClause FROM @tableList WHERE TableListID = @i
	print 'Starting on ' + @tableName
	--print @dynamicSQL
	EXECUTE sp_executesql  @dynamicSQL, N'@Top int,@cc varchar(50) output,@DelInv smallint,@DelGrwth smallint,@DelStats smallint,@DelCntr smallint,@DelFRKDate smallint', @top = @Top,@cc=@cc output, @DelInv = @DelInv, @DelGrwth = @DelGrwth, @DelStats = @DelStats, @DelCntr = @DelStats, @DelFRKDate = @DelFRKDate;
		
	/*### [INNER LOOP] #############################################################################*/
	WHILE @ii <= @cc
	BEGIN		
		
		SELECT @dynamicSQL = 'DELETE TOP(@TOP) FROM ' + TableName + ' ' + WhereClause FROM @tableList WHERE TableListID = @i
		--print @dynamicSQL
		EXECUTE sp_executesql  @dynamicSQL, N'@Top int,@DelInv smallint,@DelGrwth smallint,@DelStats smallint,@DelCntr smallint,@DelFRKDate smallint', @top = @Top,@DelInv = @DelInv, @DelGrwth = @DelGrwth, @DelStats = @DelStats, @DelCntr = @DelStats, @DelFRKDate = @DelFRKDate;
		print @tableName + ': ' + cast(@ii as varchar(20)) + ' of ' +  cast(@cc as varchar(20))
		SET @ii = @ii + 1
	END
	/*#############################################################################################*/

END
/*#############################################################################################*/

END
GO
/****** Object:  StoredProcedure [dbo].[usp_DBFiles]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DBFiles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_DBFiles] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_DBFiles]
(
@InstanceName varchar(128),
@DBName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--DB Files Info
SELECT Y.LogicalName, Y.PhysicalName, (SUBSTRING(REVERSE(Y.PhysicalName), 1, CHARINDEX('.', REVERSE(Y.PhysicalName)) - 1)) AS [File Type],
		y.SizeInMB, y.GrowthPct, y.GrowthInMB
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [DB].[DatabaseFiles]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [DB].[DatabaseFiles] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName  AND y.InstanceName = @InstanceName And  y.DBName = @DBName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DBGrwth]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DBGrwth]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_DBGrwth] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_DBGrwth]
(
@InstanceName varchar(128),
@DBName varchar(128),
@StartDate DateTime,
@EndDate DateTime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- in@InstanceNameterfering with SELECT statements.
	SET NOCOUNT ON;
--Database growth info
SELECT       InstanceName, [DBName],[DataFileInMB],[LogFileInMB], [DataFileInMB] + [LogFileInMB] as DBGrowth, DateAdded-- CONVERT(char(10), DateAdded, 101) as DateAdded
  FROM [DB].[DBFileGrowth] where InstanceName = @InstanceName And DBName= @DBName and (DateAdded >= @StartDate) AND (DateAdded <= @EndDate)
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DBGrwth30Day]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DBGrwth30Day]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_DBGrwth30Day] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_DBGrwth30Day]
(
@InstanceName varchar(128),
@DBName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Database growth for past 30 days info
SELECT [DataFileInMB] + [LogFileInMB] as DBGrowth, DateAdded --CONVERT(char(10), DateAdded, 101) as DateAdded
  FROM [DB].[DBFileGrowth] where InstanceName = @InstanceName And DBName= @DBName and DateAdded > getdate()-30
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DBInfo]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DBInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_DBInfo] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_DBInfo]
(
@InstanceName varchar(128),
@DBName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance info
SELECT y.InstanceName, y.DBName, y.DBStatus, y.DBOwner, y.DBCreateDate, y.DBSizeInMB, y.DBSpaceAvailableInMB, y.DBUsedSpaceInMB, y.DBPctFreeSpace, 
                  y.DBDataSpaceUsageInMB, y.DBIndexSpaceUsageInMB, y.Collation, y.RecoveryModel, y.CompatibilityLevel,  
				  y.AutoShrink, y.AutoUpdateStatisticsEnabled, y.IsReadCommittedSnapshotOn, y.IsFullTextEnabled, y.BrokerEnabled, 
                  y.ReadOnly, y.IsDatabaseSnapshot,  y.IsMirroringEnabled, y.MirroringPartnerInstance, y.MirroringStatus, y.[HasFileInCloud],
                  y.MirroringSafetyLevel, y.ReplicationOptions, y.AvailabilityGroupName, y.NoOfTbls, y.NoOfViews, y.NoOfStoredProcs, y.NoOfUDFs, y.NoOfLogFiles, y.NoOfFileGroups, 
                  y.NoOfUsers, y.NoOfDBTriggers, y.DateAdded, y.[AutoClose],y.[HasMemoryOptimizedObjects], y.[MemoryAllocatedToMemoryOptimizedObjectsInKB], y.[MemoryUsedByMemoryOptimizedObjectsInKB], 
                  CASE WHEN y.LastBackupDate = '1/1/0001 12:00:00 AM' THEN 'No Full Backup Taken Yet' ELSE y.LastBackupDate END AS FullBackup, 
				  CASE WHEN y.LastDifferentialBackupDate = '1/1/0001 12:00:00 AM' THEN 'No Diff Backup Taken Yet' ELSE y.LastDifferentialBackupDate END AS DiffBackup, 
				  CASE WHEN y.LastLogBackupDate = '1/1/0001 12:00:00 AM' THEN 'No Log Backup Taken Yet' ELSE y.LastLogBackupDate END AS LogBackup ,
				  CASE WHEN y.LastGoodDBCCCheckDB = '1900-01-01 00:00:00.000' THEN 'DBCC Not Run Yet' ELSE y.LastGoodDBCCCheckDB END AS LastGoodDBCCCheckDB 
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      DB.DatabaseInfo
                  GROUP BY InstanceName) AS x INNER JOIN
                  DB.DatabaseInfo AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName And  y.DBName = @DBName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DBLoginsandGroupsWithRoles]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DBLoginsandGroupsWithRoles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_DBLoginsandGroupsWithRoles] AS' 
END
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_DBLoginsandGroupsWithRoles]
(
@LoginName		nvarchar(255) = '',
@Domain			nvarchar(255) = '<DOMAIN>\',
@WildCardLookup bit			  = 0 
)
AS
BEGIN
	
	BEGIN TRY
	
		if @WildCardLookup = 1 
		begin
			if right(@LoginName, 1) != '%'
			begin 
				set @LoginName = @LoginName + '%'
			end
		end

		if @LoginName not like @Domain + '%' 
		begin
			set @LoginName = @Domain + @LoginName
		end

	-- Individual that has specific grants on the database
		SELECT DISTINCT
			 ir3.[InstanceName]   as InstanceName	
			,ir3.DBName			  as DatabaseName
			,ir3.DBUser		      as LoginName	
			,NULL				  as GroupedUser
			,SUBSTRING((SELECT DISTINCT ',{' + DBRole + '}' AS 'data()' FROM [DB].[DBUserRoles] ir2  with (index(NCI_DBUserRoles_InstanceName_DBName_DBUser_DateAdded)) WHERE ir2.InstanceName = ir3.InstanceName and ir2.DBName = ir3.DBName and replace(ir2.DBUser, @Domain, '') = replace(ir3.DBUser, @Domain, '') and ir2.DateAdded = ir3.DateAdded  FOR XML PATH('')), 2 , 9999) As RoleName		
			,ir3.[DateAdded] as DateAdded
		FROM 
			[DB].[DBUserRoles] ir3 with (index(NCI_DBUserRoles_InstanceName_DBName_DBUser_DateAdded))
		INNER JOIN  
		(	
			SELECT		[InstanceName], DBName, DBUser, MAX(DateAdded) AS DateAdded
			FROM		[DB].[DBUserRoles] with (index(NCI_DBUserRoles_InstanceName_DBName_DBUser_DateAdded))
			GROUP BY	[InstanceName], DBName, DBUser
		) cteNewestData2 on cteNewestData2.InstanceName = ir3.InstanceName and cteNewestData2.DBName = ir3.DBName and cteNewestData2.DBUser = ir3.DBUser and cteNewestData2.DateAdded = ir3.DateAdded			 
		WHERE ir3.DBUser like @LoginName
		union all
		-- Group that has a specific individual with specific grants on the database
		SELECT DISTINCT 
			 ir1.[InstanceName]		as InstanceName	
			,ir3.DBName 			as DatabaseName
			,ir1.[GroupName]		as LoginName
			,ir1.LoginName			as GroupedUser
			, SUBSTRING((SELECT DISTINCT ',{' + DBRole + '}' AS 'data()' 
						 FROM [DB].[DBUserRoles] ir2 with (index(NCI_DBUserRoles_InstanceName_DBName_DBUser_DateAdded)) 
						 INNER JOIN  
							(	
								SELECT		[InstanceName], DBName, DBUser, MAX(DateAdded) AS DateAdded
								FROM		[DB].[DBUserRoles] with (index(NCI_DBUserRoles_InstanceName_DBName_DBUser_DateAdded))
								GROUP BY	[InstanceName], DBName, DBUser
							) cteNewestData2 on cteNewestData2.InstanceName = ir2.InstanceName and cteNewestData2.DBName = ir2.DBName and cteNewestData2.DBUser = ir2.DBUser and cteNewestData2.DateAdded = ir2.DateAdded	
						 WHERE ir2.InstanceName = ir3.InstanceName and ir2.DBName = ir3.DBName and ir2.DBUser = ir3.DBUser
						 FOR XML PATH('')), 2 , 9999) As RoleName	
			,ir3.[DateAdded] as DateAdded	
		FROM 
			[Inst].[LoginGroupMembers] ir1 --with (index(NCI_ADGroupMembership_InstanceName_GroupName_DateAdded))
		INNER JOIN  
		(	
			SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[LoginGroupMembers] --with (index(NCI_ADGroupMembership_InstanceName_GroupName_DateAdded))
			GROUP BY	InstanceName, GroupName
		) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
		INNER JOIN 
			[DB].[DBUserRoles] ir3 with (index(NCI_DBUserRoles_InstanceName_DBUser)) ON ir3.InstanceName = ir1.InstanceName and ir3.DBUser = ir1.GroupName
		INNER JOIN  
		(	
			SELECT		[InstanceName], DBName, DBUser, MAX(DateAdded) AS DateAdded
			FROM		[DB].[DBUserRoles] with (index(NCI_DBUserRoles_InstanceName_DBName_DBUser_DateAdded))
			GROUP BY	[InstanceName], DBName, DBUser
		) cteNewestData2 on cteNewestData2.InstanceName = ir3.InstanceName and cteNewestData2.DBName = ir3.DBName and cteNewestData2.DBUser = ir3.DBUser and cteNewestData2.DateAdded = ir3.DateAdded			 
		WHERE ir1.LoginName like @LoginName
		order by 1
		--SELECT DBRole as RoleName, Description FROM [DB].[DBUserRolesDescription]

	END TRY

	BEGIN CATCH

		DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  
  
			SELECT   
				@ErrorMessage = ERROR_MESSAGE(),  
				@ErrorSeverity = ERROR_SEVERITY(),  
				@ErrorState = ERROR_STATE();  
  
			-- Use RAISERROR inside the CATCH block to return error  
			-- information about the original error that caused  
			-- execution to jump to the CATCH block.  
			RAISERROR (@ErrorMessage, -- Message text.  
					   @ErrorSeverity, -- Severity.  
					   @ErrorState -- State.  
					   );  
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[usp_DBTriggers]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DBTriggers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_DBTriggers] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_DBTriggers]
(
@InstanceName varchar(128),
@DBName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--DB Trigger info
SELECT y.InstanceName, y.TriggerName, y.CreateDate, y.LastModified, y.IsEnabled, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [DB].[Triggers]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [DB].[Triggers] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName And  y.DBName = @DBName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DelData]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DelData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_DelData] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_DelData]
(
	  @DelInv SMALLINT,
	  @DelGrwth SMALLINT,
	  @DelStats SMALLINT,
      @DelCntr SMALLINT

)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Delete Old Data
Delete From [AS].[SSASDBInfo] Where DateAdded < GETDATE()- @DelInv;
Delete From [AS].[SSASInfo] Where DateAdded < GETDATE()- @DelInv;
Delete From [DB].[AvailDatabases] Where DateAdded < GETDATE()- @DelInv;
Delete From [DB].[AvailGroups] Where DateAdded < GETDATE()- @DelInv;
Delete From [DB].[AvailReplicas] Where DateAdded < GETDATE()- @DelInv;
Delete From [DB].[DatabaseFiles] Where DateAdded < GETDATE()- @DelInv;
Delete From [DB].[DatabaseInfo] Where DateAdded < GETDATE()- @DelInv;
Delete From [DB].[DBFileGrowth] Where DateAdded < GETDATE()- @DelGrwth;
Delete From [DB].[DBUserRoles] Where DateAdded < GETDATE()- @DelInv;
Delete From [DB].[Triggers] Where DateAdded < GETDATE()- @DelInv;
Delete From [Inst].[InsBaselineStats] Where RunDate < GETDATE()- @DelCntr;
Delete From [Inst].[InstanceInfo] Where DateAdded < GETDATE()- @DelInv;
Delete From [Inst].[InstanceRoles] Where DateAdded < GETDATE()- @DelInv;
Delete From [Inst].[InsTriggers] Where DateAdded < GETDATE()- @DelInv;
Delete From [Inst].[Jobs] Where DateAdded < GETDATE()- @DelInv;
Delete From [Inst].[JobsFailed] Where DateAdded < GETDATE()- @DelInv;
Delete From [Inst].[LinkedServers] Where DateAdded < GETDATE()- @DelInv;
Delete From [Inst].[Logins] Where DateAdded < GETDATE()- @DelInv;
Delete From [Inst].[MissingIndexes] Where DateAdded < GETDATE()- @DelStats;
Delete From [Inst].[Replication] Where DateAdded < GETDATE()- @DelInv;
Delete From [Inst].[WaitStats] Where DateAdded < GETDATE()- @DelStats;
Delete From [RS].[SSRSConfig] Where DateAdded < GETDATE()- @DelInv;
Delete From [RS].[SSRSInfo] Where DateAdded < GETDATE()- @DelInv;
Delete From [Svr].[DiskInfo] Where DateAdded < GETDATE()- @DelGrwth;
Delete From [Svr].[OSInfo] Where DateAdded < GETDATE()- @DelInv;
Delete From [Svr].[PgFileUsage] Where DateAdded < GETDATE()- @DelInv;
Delete From [Svr].[ServerInfo] Where DateAdded < GETDATE()- @DelInv;
Delete From [Svr].[SQLServices] Where DateAdded < GETDATE()- @DelInv;
Delete From [Svr].[SvrBaselineStats] Where RunDate < GETDATE()- @DelCntr;
Delete From [Tbl].[HekatonTbls] Where DateAdded < GETDATE()- @DelInv;
Delete From [Tbl].[TblPermissions] Where DateAdded < GETDATE()- @DelInv;
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DelDecomSvrData]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DelDecomSvrData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_DelDecomSvrData] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_DelDecomSvrData]
(
	  @SvrName nVarChar(128),
	  @InstName nVarChar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Delete Decomissioned Server Data
Delete From [AS].[SSASDBInfo] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [AS].[SSASInfo] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [DB].[AvailDatabases] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [DB].[AvailGroups] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [DB].[AvailReplicas] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [DB].[DatabaseFiles] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [DB].[DatabaseInfo] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [DB].[DBFileGrowth] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [DB].[DBUserRoles] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [DB].[Triggers] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Inst].[InsBaselineStats] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Inst].[InstanceInfo] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Inst].[InstanceRoles] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Inst].[InsTriggers] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Inst].[Jobs] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Inst].[JobsFailed] Where  ServerName=@SvrName and InstanceName= @InstName;
Delete From [Inst].[LinkedServers] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Inst].[Logins] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Inst].[MissingIndexes] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Inst].[Replication] Where  ServerName=@SvrName and InstanceName= @InstName;
Delete From [Inst].[WaitStats] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [RS].[SSRSConfig] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [RS].[SSRSInfo] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Svr].[DiskInfo] Where ServerName=@SvrName;
Delete From [Svr].[OSInfo] Where ServerName=@SvrName;
Delete From [Svr].[PgFileUsage] Where ServerName=@SvrName;
Delete From [Svr].[ServerInfo] Where ServerName=@SvrName;
Delete From [Svr].[ServerList] Where ServerName=@SvrName;
Delete From [Svr].[SQLServices] Where ServerName=@SvrName;
Delete From [Svr].[SvrBaselineStats] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Tbl].[HekatonTbls] Where ServerName=@SvrName and InstanceName= @InstName;
Delete From [Tbl].[TblPermissions] Where ServerName=@SvrName and InstanceName= @InstName;
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DiskGrwth]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DiskGrwth]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_DiskGrwth] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_DiskGrwth]
(
@ServerName varchar(128),
@StartDate DateTime,
@EndDate DateTime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Disk Growth info
select  ServerName, DiskName, DskTotalSizeInGB as TotalSizeInGB, [DskUsedSpaceInGB] as UsedSpaceInGB, DateAdded from [Svr].[DiskInfo] 
where ServerName =  @ServerName and (DateAdded >= @StartDate) AND (DateAdded <= @EndDate)

END
GO
/****** Object:  StoredProcedure [dbo].[usp_DiskInfo]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DiskInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_DiskInfo] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_DiskInfo]
(
@servername varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Disk Management info
select  y.DiskName, Y.DskClusterSizeInKB, y.DskTotalSizeInGB, y.[DskFreeSpaceInGB], y.[DskUsedSpaceInGB], y.[DskPctFreeSpace]  from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[DiskInfo]
Group BY Servername) x
Join [Svr].[DiskInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName and y.ServerName =  @servername

END
GO
/****** Object:  StoredProcedure [dbo].[usp_GroupsMembershipWithRoles]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GroupsMembershipWithRoles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_GroupsMembershipWithRoles] AS' 
END
GO
ALTER PROCEDURE [dbo].[usp_GroupsMembershipWithRoles]
(
@LoginName		nvarchar(255) = null,
@Domain			nvarchar(255) = '',
@WildCardLookup bit			  = 0, 
@returnList		bit			  = 0,
@returnBI		tinyint		  = 0
)
AS
BEGIN
	
	BEGIN TRY
	
		if @returnList = 0 and @returnBI = 0
		begin
			if @WildCardLookup = 1 
			begin
				if right(@LoginName, 1) != '%'
				begin 
					set @LoginName = @LoginName + '%'
				end
			end

			if @LoginName not like @Domain + '%' 
			begin
				set @LoginName = @Domain + @LoginName
			end
		end

		if @LoginName is null and @returnList = 1 and @returnBI = 0
		begin
			--return group list
			SELECT ir1.GroupName 
			FROM Inst.LoginGroupMembers ir1
			INNER JOIN  
			(	
				SELECT		GroupName, MAX(DateAdded) AS DateAdded
				FROM		[Inst].LoginGroupMembers --with (index(NCI_LoginGroupMembers_InstanceName_GroupName_DateAdded))
				GROUP BY	GroupName
			) cteNewestData on cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
			GROUP BY ir1.GroupName
		end
		else if @LoginName is not null and @returnBI = 0 and @returnList = 0
		begin
			SELECT ir1.LoginName 
			FROM Inst.LoginGroupMembers ir1
			INNER JOIN  
			(	
				SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
				FROM		[Inst].LoginGroupMembers --with (index(NCI_LoginGroupMembers_InstanceName_GroupName_DateAdded))
				GROUP BY	InstanceName, GroupName
			) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
			left outer join
			(
				SELECT DISTINCT ir2.RoleName, ir2.LoginName, ir2.InstanceName
				FROM [Inst].[InstanceRoles] ir2 
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[Inst].[InstanceRoles]
					GROUP BY	InstanceName
				) cteNewestData on cteNewestData.InstanceName = ir2.InstanceName and cteNewestData.DateAdded = ir2.DateAdded
				union all			
				SELECT DISTINCT ir2.DBRole as RoleName, ir2.DBUser as LoginName, ir2.InstanceName
				FROM [DB].[DBUserRoles] ir2 
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[DB].[DBUserRoles] ir2 
					GROUP BY	InstanceName
				) cteNewestData on cteNewestData.InstanceName = ir2.InstanceName and cteNewestData.DateAdded = ir2.DateAdded
			) x on x.LoginName = ir1.GroupName and x.InstanceName = ir1.InstanceName
			WHERE ir1.GroupName like @LoginName
			group by ir1.LoginName
		end
		else if @LoginName is not null and @returnBI = 1
		begin

			SELECT ir1.GroupName, isnull(x.RoleName, 'public') as RoleName
			FROM Inst.LoginGroupMembers ir1
			INNER JOIN  
			(	
				SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
				FROM		[Inst].LoginGroupMembers --with (index(NCI_LoginGroupMembers_InstanceName_GroupName_DateAdded))
				GROUP BY	InstanceName, GroupName
			) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
			left outer join
			(
				SELECT DISTINCT ir2.RoleName, ir2.LoginName, ir2.InstanceName
				FROM [Inst].[InstanceRoles] ir2 
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[Inst].[InstanceRoles]
					GROUP BY	InstanceName
				) cteNewestData on cteNewestData.InstanceName = ir2.InstanceName and cteNewestData.DateAdded = ir2.DateAdded
				union all			
				SELECT DISTINCT ir2.DBRole as RoleName, ir2.DBUser as LoginName, ir2.InstanceName
				FROM [DB].[DBUserRoles] ir2 
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[DB].[DBUserRoles] ir2 
					GROUP BY	InstanceName
				) cteNewestData on cteNewestData.InstanceName = ir2.InstanceName and cteNewestData.DateAdded = ir2.DateAdded
			) x on x.LoginName = ir1.GroupName and x.InstanceName = ir1.InstanceName
			WHERE ir1.GroupName like @LoginName
			group by ir1.GroupName, x.RoleName

		end
		else if @LoginName is not null and @returnBI = 2
		begin

			SELECT ir1.GroupName, ir1.LoginName
			FROM Inst.LoginGroupMembers ir1
			INNER JOIN  
			(	
				SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
				FROM		[Inst].LoginGroupMembers --with (index(NCI_LoginGroupMembers_InstanceName_GroupName_DateAdded))
				GROUP BY	InstanceName, GroupName
			) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
			left outer join
			(
				SELECT DISTINCT ir2.RoleName, ir2.LoginName, ir2.InstanceName
				FROM [Inst].[InstanceRoles] ir2 
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[Inst].[InstanceRoles]
					GROUP BY	InstanceName
				) cteNewestData on cteNewestData.InstanceName = ir2.InstanceName and cteNewestData.DateAdded = ir2.DateAdded
				union all			
				SELECT DISTINCT ir2.DBRole as RoleName, ir2.DBUser as LoginName, ir2.InstanceName
				FROM [DB].[DBUserRoles] ir2 
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[DB].[DBUserRoles] ir2 
					GROUP BY	InstanceName
				) cteNewestData on cteNewestData.InstanceName = ir2.InstanceName and cteNewestData.DateAdded = ir2.DateAdded
			) x on x.LoginName = ir1.GroupName and x.InstanceName = ir1.InstanceName
			WHERE ir1.GroupName like @LoginName
			group by ir1.GroupName, ir1.LoginName

		end
		else if @LoginName is not null and @returnBI = 3
		begin

			SELECT ir1.GroupName, ir1.InstanceName
			FROM Inst.LoginGroupMembers ir1
			INNER JOIN  
			(	
				SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
				FROM		[Inst].LoginGroupMembers --with (index(NCI_LoginGroupMembers_InstanceName_GroupName_DateAdded))
				GROUP BY	InstanceName, GroupName
			) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
			left outer join
			(
				SELECT DISTINCT ir2.RoleName, ir2.LoginName, ir2.InstanceName
				FROM [Inst].[InstanceRoles] ir2 
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[Inst].[InstanceRoles]
					GROUP BY	InstanceName
				) cteNewestData on cteNewestData.InstanceName = ir2.InstanceName and cteNewestData.DateAdded = ir2.DateAdded
				union all			
				SELECT DISTINCT ir2.DBRole as RoleName, ir2.DBUser as LoginName, ir2.InstanceName
				FROM [DB].[DBUserRoles] ir2 
				INNER JOIN  
				(	
					SELECT		InstanceName, MAX(DateAdded) AS DateAdded
					FROM		[DB].[DBUserRoles] ir2 
					GROUP BY	InstanceName
				) cteNewestData on cteNewestData.InstanceName = ir2.InstanceName and cteNewestData.DateAdded = ir2.DateAdded
			) x on x.LoginName = ir1.GroupName and x.InstanceName = ir1.InstanceName
			WHERE ir1.GroupName like @LoginName
			group by ir1.GroupName, ir1.InstanceName

		end
	

	END TRY

	BEGIN CATCH

		DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  
  
			SELECT   
				@ErrorMessage = ERROR_MESSAGE(),  
				@ErrorSeverity = ERROR_SEVERITY(),  
				@ErrorState = ERROR_STATE();  
  
			-- Use RAISERROR inside the CATCH block to return error  
			-- information about the original error that caused  
			-- execution to jump to the CATCH block.  
			RAISERROR (@ErrorMessage, -- Message text.  
					   @ErrorSeverity, -- Severity.  
					   @ErrorState -- State.  
					   );  
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[usp_HekatonOverview]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_HekatonOverview]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_HekatonOverview] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_HekatonOverview]
(
@Environment Varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Parsing values into table
Select Item
into #Environ_List
From
dbo.DelimitedSplit8K(@Environment,',')

--Serverinfo View

  Select Z.[InstanceName], Z.[DBName], Z.[TblName], Z.[IsMemoryOptimized], Z.[DurabilityDesc], Z.[DateAdded], v.Environment from (
select  y.* from(
select InstanceName, Max(DateAdded) as Rundate 
from [Tbl].[HekatonTbls]
Group BY InstanceName) x
Join [Tbl].[HekatonTbls] y ON x.Rundate = y.DateAdded and X.InstanceName = y.InstanceName) z
inner join(
select Distinct ServerName, InstanceName, Environment from  [Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName and z.[IsMemoryOptimized] = 'True'
inner join #Environ_List as EnvironList on v.Environment = EnvironList.Item
Order by Z.InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InsertAuditReport]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InsertAuditReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InsertAuditReport] AS' 
END
GO


ALTER PROCEDURE [dbo].[usp_InsertAuditReport]
(
	  @UserID			nvarchar(255),
	  @ReportName		nvarchar(255),
	  @ReportURL		nvarchar(1000),
      @RunDate			datetime = NULL
)
AS
BEGIN

	SET @RunDate = ISNULL(@RunDate, GETDATE())

	INSERT INTO [dbo].[ReportAudit]
    (		[UserID]
           ,[ReportName]
           ,[ReportURL]
           ,[RunDate]
	)
     VALUES
	(		@UserID
           ,@ReportName
           ,@ReportURL
           ,@RunDate
	)

END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstChrtWaitStats]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstChrtWaitStats]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstChrtWaitStats] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstChrtWaitStats]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Wait Stats info
SELECT DISTINCT WaitType, COUNT(WaitType) AS count
FROM     [Inst].[WaitStats]
WHERE  (InstanceName = @InstanceName) --and (DateAdded > GETDATE() - 30) 
GROUP BY WaitType
ORDER BY count DESC
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstDBInfo]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstDBInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstDBInfo] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstDBInfo]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance info
SELECT y.InstanceName, y.DBName, y.RecoveryModel, y.DBSizeInMB, 
CASE when y.LastBackupDate = '1/1/0001 12:00:00 AM' Then 'No Backup Taken Yet' else y.LastBackupDate End As FullBackup
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [DB].[DatabaseInfo]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [DB].[DatabaseInfo] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName

END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstDBLogins]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstDBLogins]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstDBLogins] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstDBLogins]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--Instance DB Login Roles info
	with cteNewestData
	as
	(
	SELECT		InstanceName, MAX(DateAdded) AS DateAdded
	FROM		[DB].[DBUserRoles]
	GROUP BY	InstanceName
	)
	,	cteDBUserRoles
	as
	(
	SELECT		DISTINCT ir1.InstanceName, ir1.DBName, ir1.DBUser, l.logintype as DBLoginType, SUBSTRING((SELECT ',' + DBRole AS 'data()' FROM [DB].[DBUserRoles] ir2 WHERE ir1.InstanceName = ir2.InstanceName and ir1.DBName = ir2.DBName and ir1.DBUser = ir2.DBUser and ir1.DateAdded = ir2.DateAdded FOR XML PATH('')), 2 , 9999) As DBRole, cteNewestData.DateAdded
	FROM		[DB].[DBUserRoles] ir1
	INNER JOIN  cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.DateAdded = ir1.DateAdded
	LEFT OUTER JOIN Inst.Logins l on l.InstanceName = ir1.InstanceName and ir1.DBUser = l.loginname and cteNewestData.DateAdded = l.DateAdded
	WHERE		ir1.InstanceName = @InstanceName
	)

	SELECT		InstanceName, DBName, DBUser, DBLoginType, DBRole, DateAdded
	FROM		cteDBUserRoles
	WHERE DBUser != 'dbo'
	GROUP BY	InstanceName, DBName, DBUser, DBLoginType, DBRole, DateAdded
	ORDER BY	DBName, DBUser
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstInfo]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstInfo] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstInfo]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance info
SELECT y.ServerName, y.InstanceName, y.IPAddress, y.Port, y.SQLVersion, y.SQLPatchLevel, y.SQLEdition, y.SQLVersionNo, y.Collation, y.RootDirectory, 
                  y.DefaultDataPath, y.DefaultLogPath, y.ErrorLogPath, y.IsClustered,  y.IsSingleUser, y.IsAlwaysOnEnabled, y.TCPEnabled, 
                  y.NamedPipesEnabled, y.AlwaysOnStatus, y.MaxMemInMB, y.MinMemInMB, y.MaxDOP, y.NoOfUsrDBs, y.NoOfJobs, y.NoOfLnkSvrs, y.NoOfLogins, 
				  y.NoOfTriggers, y.NoOfAvailGrps, y.[AvailGrps], y.[IsXTPSupported], y.[FilFactor],  y.[ActiveNode], y.[ClusterNodeNames], y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      Inst.InstanceInfo
                  GROUP BY InstanceName) AS x INNER JOIN
                  Inst.InstanceInfo AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName

END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstJobs]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstJobs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstJobs] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstJobs]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Jobs info
    SELECT y.InstanceName, y.JobName, Y.IsEnabled, 
	CASE when Y.LastRunDate = '1/1/0001 12:00:00 AM' Then 'Never' else Y.LastRunDate End As LastRunDate, 
	y.LastRunOutcome, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [Inst].[Jobs]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [Inst].[Jobs] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstJobsFailed]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstJobsFailed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstJobsFailed] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstJobsFailed]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--Instance Failed Jobs info
    SELECT y.[InstanceName], y.[JobName], y.[StepID], y.[StepName], y.[ErrMsg], y.[JobRunDate], y.[DateAdded]
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM     [Inst].[JobsFailed]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [Inst].[JobsFailed] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstLnkSvrs]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstLnkSvrs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstLnkSvrs] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstLnkSvrs]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Linked Servers info
SELECT y.InstanceName, y.LinkedServerName,Y.ProviderName, Y.ProductName, Y.DateLastModified, Y.DataAccess, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [Inst].[LinkedServers]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [Inst].[LinkedServers] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstLoginRoles]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstLoginRoles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstLoginRoles] AS' 
END
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstLoginRoles]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	with cteNewestData
	as
	(
	SELECT		InstanceName, MAX(DateAdded) AS DateAdded
	FROM		[Inst].[InstanceRoles]
	GROUP BY	InstanceName
	)

	SELECT		DISTINCT ir1.InstanceName, LoginName, SUBSTRING((SELECT ',' + RoleName AS 'data()' FROM [Inst].[InstanceRoles] ir2 WHERE ir1.InstanceName = ir2.InstanceName and ir1.LoginName = ir2.LoginName and ir1.DateAdded = ir2.DateAdded FOR XML PATH('')), 2 , 9999) As RoleName, cteNewestData.DateAdded
	FROM		[Inst].[InstanceRoles] ir1
	INNER JOIN  cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.DateAdded = ir1.DateAdded
	WHERE  ir1.InstanceName = @InstanceName
	ORDER BY	ir1.LoginName 

END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstLogins]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstLogins]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstLogins] AS' 
END
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstLogins]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Logins info
SELECT
	y.InstanceName
	, y.LoginName
	, y.LoginType
	,SUBSTRING((SELECT ',' + RoleName AS 'data()' FROM [Inst].[InstanceRoles] ir2 WHERE y.InstanceName = ir2.InstanceName and y.LoginName = ir2.LoginName and y.DateAdded = ir2.DateAdded FOR XML PATH('')), 2 , 9999) As RoleName
	, y.LoginCreateDate
	, y.LoginLastModified
	, isnull(cast(y.IsDisabled as tinyint), 2) IsDisabled
	, isnull(cast(y.IsLocked as tinyint), 2) IsLocked
	, y.DateAdded
FROM     
(
	SELECT InstanceName, MAX(DateAdded) AS Rundate
    FROM      Inst.Logins
    GROUP BY InstanceName
) AS x 
INNER JOIN
	Inst.Logins AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstLoginsandGroupsWithRoles]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstLoginsandGroupsWithRoles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstLoginsandGroupsWithRoles] AS' 
END
GO

--exec  [dbo].[usp_InstLoginsandGroupsWithRoles] @LoginName = 'GOA\adam.seniuk'

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstLoginsandGroupsWithRoles]
(
@LoginName		nvarchar(255) = '',
@Domain			nvarchar(255) = '',
@WildCardLookup bit			  = 0 
)
AS
BEGIN
	
	BEGIN TRY
	
		if @WildCardLookup = 1 
		begin
			if right(@LoginName, 1) != '%'
			begin 
				set @LoginName = @LoginName + '%'
			end
		end

		if @LoginName not like @Domain + '%' 
		begin
			set @LoginName = @Domain + @LoginName
		end

		-- Individual with specific grants on the instance
		SELECT	DISTINCT 
			 ir1.InstanceName
			,'{whole server}' as DatabaseName
			,ir1.LoginName as LoginName
			,NULL as GroupedUser
			,isnull(SUBSTRING((SELECT DISTINCT ',{' + RoleName + '}' AS 'data()' 
							   FROM [Inst].[InstanceRoles] ir2 							   
							   INNER JOIN  
								(	
									SELECT		InstanceName, MAX(DateAdded) AS DateAdded
									FROM		[Inst].[InstanceRoles]
									GROUP BY	InstanceName
								) cteNewestData on cteNewestData.InstanceName = ir2.InstanceName and cteNewestData.DateAdded = ir2.DateAdded
							   WHERE ir1.InstanceName = ir2.InstanceName and ir1.LoginName = ir2.LoginName /*and ir1.DateAdded = ir2.DateAdded*/ 
							   FOR XML PATH('')), 2 , 9999), '{public}') As RoleName
			,cteNewestData.DateAdded
		FROM		
			[Inst].[Logins] ir1
		INNER JOIN  
		(	
			SELECT		InstanceName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].[InstanceRoles]
			GROUP BY	InstanceName
		) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.DateAdded = ir1.DateAdded
		WHERE ir1.LoginName like @LoginName
		--ORDER BY	ir1.InstanceName 
		union all
		-- Group that has a specific individual with specific grants on the instance
		SELECT DISTINCT
			 ir1.[InstanceName]		as InstanceName	
			,'{whole server}'		as DatabaseName
			,ir1.[GroupName]		as LoginName
			,ir1.LoginName			as GroupedUser
			,isnull(SUBSTRING((SELECT DISTINCT ',{' + ir2.RoleName + '}' AS 'data()' 
							   FROM [Inst].[InstanceRoles] ir2 
							    INNER JOIN  
								(	
									SELECT		InstanceName, MAX(DateAdded) AS DateAdded
									FROM		[Inst].[InstanceRoles]
									GROUP BY	InstanceName
								) cteNewestData on cteNewestData.InstanceName = ir2.InstanceName and cteNewestData.DateAdded = ir2.DateAdded
							   WHERE ir2.InstanceName = ir1.InstanceName and ir2.LoginName = ir1.GroupName
			 FOR XML PATH('')), 2 , 9999), '{public}') As RoleName
			,ir1.DateAdded
		FROM 
			[Inst].LoginGroupMembers ir1 --with (index(NCI_LoginGroupMembers_InstanceName_GroupName_DateAdded))
		INNER JOIN  
		(	
			SELECT		InstanceName, GroupName, MAX(DateAdded) AS DateAdded
			FROM		[Inst].LoginGroupMembers --with (index(NCI_LoginGroupMembers_InstanceName_GroupName_DateAdded))
			GROUP BY	InstanceName, GroupName
		) cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.GroupName = ir1.GroupName and cteNewestData.DateAdded = ir1.DateAdded
		WHERE ir1.LoginName like @LoginName
		order by 1
		--SELECT RoleName, Description FROM [Inst].[InstanceRolesDescription]

	END TRY

	BEGIN CATCH

		DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  
  
			SELECT   
				@ErrorMessage = ERROR_MESSAGE(),  
				@ErrorSeverity = ERROR_SEVERITY(),  
				@ErrorState = ERROR_STATE();  
  
			-- Use RAISERROR inside the CATCH block to return error  
			-- information about the original error that caused  
			-- execution to jump to the CATCH block.  
			RAISERROR (@ErrorMessage, -- Message text.  
					   @ErrorSeverity, -- Severity.  
					   @ErrorState -- State.  
					   );  
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstMIIdx]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstMIIdx]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstMIIdx] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstMIIdx]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Missing Indexes info
    SELECT  y.InstanceName, Y.create_index_statement,y.improvement_measure, y.unique_compiles, y.user_seeks, y.avg_total_user_cost, y.avg_user_impact, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [Inst].[MissingIndexes]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [Inst].[MissingIndexes] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName


END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstStats]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstStats]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstStats] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstStats]
(
@ServerName varchar(128),
@StartDate DateTime,
@EndDate DateTime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance stats info
SELECT ServerName, RunDate, FwdRecSec, FlScansSec, IdxSrchsSec, PgSpltSec, FreeLstStallsSec, LzyWrtsSec, PgLifeExp, PgRdSec, PgWtSec, LogGrwths, TranSec, 
                  BlkProcs, UsrConns, LatchWtsSec, LckWtTime, LckWtsSec, DeadLockSec, MemGrnts, BatReqSec, SQLCompSec, SQLReCompSec
FROM     Inst.InsBaselineStats 
where ServerName =  @ServerName and (RunDate >= @StartDate) AND (RunDate <= @EndDate)

END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstTriggers]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstTriggers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstTriggers] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstTriggers]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Triggers info
SELECT y.InstanceName, y.TriggerName, y.CreateDate, y.LastModified, y.IsEnabled, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [Inst].[InsTriggers]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [Inst].[InsTriggers] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InstWaitStats]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InstWaitStats]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InstWaitStats] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InstWaitStats]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Wait Stats info
SELECT y.InstanceName,y.WaitType, y.WaitCount, Y.Percentage,Y.AvgWait_S, Y.AvgRes_S, AvgSig_S, Y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [Inst].[WaitStats]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [Inst].[WaitStats] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InvRpt]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InvRpt]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InvRpt] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InvRpt]
(
@Environment Varchar(128),
@OSName varchar(128),
@SQLVersion varchar(128),
@ASVersion varchar(128),
@RSVersion varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Inventory Report View
SELECT z.ServerName, v.Environment, w.IPAddress, z.OSName, z.OSUpTime, z.OSTotalVisibleMemorySizeInGB AS OSMemGB, w.NumberOfProcessors, w.NumberOfCores, 
                  w.IsHyperThreaded, w.CurrentCPUSpeed, w.IsVM, w.IsClu, v.InstanceName, S.SQLVersion, S.SQLEdition, S.SQLPatchLevel, S.IsSPUpToDate, A.ASVersion, A.ASEdition, 
                  A.ASPatchLevel, R.RSVersion, R.RSEdition, v.Description
FROM     (SELECT y.ServerName, y.OSName, y.OSLastRestart, y.OSUpTime, y.OSTotalVisibleMemorySizeInGB
                  FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                     FROM      Svr.OSInfo
                                     GROUP BY ServerName) AS x INNER JOIN
                                    Svr.OSInfo AS y ON x.Rundate = y.DateAdded AND x.ServerName = y.ServerName) AS z INNER JOIN
                      (SELECT y.ServerName, y.IPAddress, y.NumberOfProcessors, y.NumberOfLogicalProcessors, y.NumberOfCores, y.IsHyperThreaded, y.CurrentCPUSpeed, y.IsVM, 
                                         y.IsClu
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      Svr.ServerInfo
                                          GROUP BY ServerName) AS x_4 INNER JOIN
                                         Svr.ServerInfo AS y ON x_4.Rundate = y.DateAdded AND x_4.ServerName = y.ServerName) AS w ON z.ServerName = w.ServerName INNER JOIN
                      (SELECT DISTINCT ServerName, InstanceName, Environment, Description
                       FROM      Svr.ServerList) AS v ON z.ServerName = v.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.SQLVersion, y.SQLPatchLevel, y.IsSPUpToDate, y.SQLEdition, y.SQLVersionNo
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      Inst.InstanceInfo
                                          GROUP BY ServerName) AS x_3 INNER JOIN
                                         Inst.InstanceInfo AS y ON x_3.Rundate = y.DateAdded AND x_3.ServerName = y.ServerName) AS S ON z.ServerName = S.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.ASVersion, y.ASPatchLevel, y.IsSPUpToDateOnAS, y.ASEdition, y.ASVersionNo
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      [AS].SSASInfo
                                          GROUP BY ServerName) AS x_2 INNER JOIN
                                         [AS].SSASInfo AS y ON x_2.Rundate = y.DateAdded AND x_2.ServerName = y.ServerName) AS A ON z.ServerName = A.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.RSVersion, y.RSEdition, y.RSVersionNo
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      RS.SSRSInfo
                                          GROUP BY ServerName) AS x_1 INNER JOIN
                                         RS.SSRSInfo AS y ON x_1.Rundate = y.DateAdded AND x_1.ServerName = y.ServerName) AS R ON z.ServerName = R.ServerName
Where V.Environment = @Environment and Z.OSName= @OSName and S.SQLVersion = @SQLVersion and A.ASVersion = @ASVersion and R.RsVersion= @RSVersion
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InvView]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InvView]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_InvView] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_InvView]
(
@Environment Varchar(128),
@Domain Varchar(128),
@OSName varchar(128),
@ISVM Varchar(128),
@ISClu Varchar(128),
@ISSQLClu Varchar(128),
@SQLVersion varchar(128),
@SQLEdition varchar(128),
@ISSPUpDt varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--Parsing values into table
Select Item
into #Environ_List
From
dbo.DelimitedSplit8K(@Environment,',')

Select Item
into #Domain_List
From
dbo.DelimitedSplit8K(@Domain,',')

SELECT Item
INTO #OS_Name_List 
FROM
dbo.DelimitedSplit8K(@OSName,',')

SELECT Item
INTO #IS_VM_List 
FROM
dbo.DelimitedSplit8K(@ISVM,',')

SELECT Item
INTO #IS_Clu_List 
FROM
dbo.DelimitedSplit8K(@ISClu,',')

SELECT Item
INTO #IS_SQLClu_List 
FROM
dbo.DelimitedSplit8K(@ISSQLClu,',')

Select Item
into #SQL_Name_List
From
dbo.DelimitedSplit8K(@SQLVersion,',')

Select Item
into #SQL_Edition_List
From
dbo.DelimitedSplit8K(@SQLEdition,',')

SELECT Item
INTO #IS_SPUpDt_List 
FROM
dbo.DelimitedSplit8K(@ISSPUpDt,',')

--Inventory Report View
SELECT Distinct z.ServerName, v.Environment, w.Domain, w.IPAddress,  z.OSName, z.OSLastRestart, z.OSTotalVisibleMemorySizeInGB AS OSMemGB, w.NumberOfProcessors, w.NumberOfCores, 
                  w.IsHyperThreaded, w.CurrentCPUSpeed, w.IsVM, w.IsClu, v.InstanceName, S.SQLVersion, S.SQLEdition, 
				  S.SQLPatchLevel, S.IsSPUpToDate, s.IsClustered, A.[ASVersion], A.[ASEdition], A.ASPatchLevel, R.[RSVersion], R.[RSEdition], v.BusinessOwner, v.Description, V.Baseline, V.SQLPing
FROM     (SELECT y.ServerName, y.OSName, y.OSLastRestart, y.OSUpTime, y.OSTotalVisibleMemorySizeInGB
                  FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                     FROM      Svr.OSInfo
                                     GROUP BY ServerName) AS x INNER JOIN
                                    Svr.OSInfo AS y ON x.Rundate = y.DateAdded AND x.ServerName = y.ServerName) AS z INNER JOIN
                      (SELECT y.ServerName, y.Domain, y.IPAddress, y.NumberOfProcessors, y.NumberOfLogicalProcessors, y.NumberOfCores, y.IsHyperThreaded, y.CurrentCPUSpeed, y.IsVM, 
                                         y.IsClu
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      Svr.ServerInfo
                                          GROUP BY ServerName) AS x_4 INNER JOIN
                                         Svr.ServerInfo AS y ON x_4.Rundate = y.DateAdded AND x_4.ServerName = y.ServerName) AS w ON z.ServerName = w.ServerName INNER JOIN
                      (SELECT DISTINCT ServerName, InstanceName, Environment, Description, BusinessOwner, Baseline, SQLPing
                       FROM      Svr.ServerList) AS v ON z.ServerName = v.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.SQLVersion, y.SQLPatchLevel, y.IsSPUpToDate, y.SQLEdition, y.SQLVersionNo, Y.IsClustered
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      Inst.InstanceInfo
                                          GROUP BY ServerName) AS x_3 INNER JOIN
                                         Inst.InstanceInfo AS y ON x_3.Rundate = y.DateAdded AND x_3.ServerName = y.ServerName) AS S ON z.ServerName = S.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.ASVersion, y.ASPatchLevel, y.IsSPUpToDateOnAS, y.ASEdition, y.ASVersionNo
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      [AS].SSASInfo
                                          GROUP BY ServerName) AS x_2 INNER JOIN
                                         [AS].SSASInfo AS y ON x_2.Rundate = y.DateAdded AND x_2.ServerName = y.ServerName) AS A ON z.ServerName = A.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.RSVersion, y.RSEdition, y.RSVersionNo
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      RS.SSRSInfo
                                          GROUP BY ServerName) AS x_1 INNER JOIN
                                         RS.SSRSInfo AS y ON x_1.Rundate = y.DateAdded AND x_1.ServerName = y.ServerName) AS R ON z.ServerName = R.ServerName
			inner join #Environ_List as EnvironList on v.Environment = EnvironList.Item
			inner join #Domain_List as DomainList on W.Domain = DomainList.Item
			inner join #OS_Name_List as OSList on z.OSName = OSList.Item
			inner join #IS_VM_List as ISVMList on W.ISVM = ISVMList.Item
			inner join #IS_Clu_List as ISCluList on W.ISClu = ISCluList.Item
			inner join #IS_SQLClu_List as ISSQLCluList on S.ISClustered = ISSQLCluList.Item
			inner join #SQL_Name_List as SQLList on s.SQLVersion = SQLList.Item
			inner join #SQL_Edition_List as SQLEditionList on s.SQLEdition = SQLEditionList.Item  
			inner join #IS_SPUpDt_List as ISSPUpDtList on S.IsSPUpToDate = ISSPUpDtList.Item

Order by z.Servername

END
GO
/****** Object:  StoredProcedure [dbo].[usp_LoginRolesbyInst]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_LoginRolesbyInst]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_LoginRolesbyInst] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_LoginRolesbyInst]
(
@LoginName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	with cteNewestData
	as
	(
	SELECT		InstanceName, MAX(DateAdded) AS DateAdded
	FROM		[Inst].[InstanceRoles]
	GROUP BY	InstanceName
	)

	SELECT		DISTINCT ir1.InstanceName, SUBSTRING((SELECT ',' + RoleName AS 'data()' FROM [Inst].[InstanceRoles] ir2 WHERE ir1.InstanceName = ir2.InstanceName and ir1.LoginName = ir2.LoginName and ir1.DateAdded = ir2.DateAdded FOR XML PATH('')), 2 , 9999) As RoleName, cteNewestData.DateAdded
	FROM		[Inst].[Logins] ir1
	INNER JOIN  cteNewestData on cteNewestData.InstanceName = ir1.InstanceName and cteNewestData.DateAdded = ir1.DateAdded
	WHERE  ir1.LoginName = @LoginName
	ORDER BY	ir1.InstanceName 

END
GO
/****** Object:  StoredProcedure [dbo].[usp_MirrorOverview]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_MirrorOverview]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_MirrorOverview] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_MirrorOverview]
(
@Environment Varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Parsing values into table
Select Item
into #Environ_List
From
dbo.DelimitedSplit8K(@Environment,',')

--DB Mirro View

Select Z.InstanceName, Z.DBName,  Z.MirroringPartnerInstance, Z.MirroringStatus,
                  Z.MirroringSafetyLevel, Z. DateAdded
FROM  (select  y.* from    (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      DB.DatabaseInfo
                  GROUP BY InstanceName) AS x INNER JOIN
                  DB.DatabaseInfo AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName)z
inner join(
select Distinct ServerName, InstanceName, Environment from  [Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName and z.[IsMirroringEnabled] = 'True'
inner join #Environ_List as EnvironList on v.Environment = EnvironList.Item
Order by Z.InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_PgFlInfo]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_PgFlInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_PgFlInfo] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_PgFlInfo]
(
@servername varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Page File info
select  Y.PgFileLocation, y.PgAllocBaseSzInGB, y.PgCurrUsageInGB, Y.PgPeakUsageInGB from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[PgFileUsage]
Group BY Servername) x
Join [Svr].[PgFileUsage] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName and y.ServerName = @servername

END
GO
/****** Object:  StoredProcedure [dbo].[usp_ReplOverview]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ReplOverview]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_ReplOverview] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_ReplOverview]
(
@Environment Varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Parsing values into table
Select Item
into #Environ_List
From
dbo.DelimitedSplit8K(@Environment,',')

--Serverinfo View

  Select z.Publisher, z.Distributor, z.Subscribers, z.ReplPubDBs, z.DistDB, Z.DateAdded, v.Environment from (
select  y.* from(
select InstanceName, Max(DateAdded) as Rundate 
from [Inst].[Replication]
Group BY InstanceName) x
Join [Inst].[Replication] y ON x.Rundate = y.DateAdded and X.InstanceName = y.InstanceName) z
inner join(
select Distinct ServerName, InstanceName, Environment from  [Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.Item
Order by Z.Publisher
END
GO
/****** Object:  StoredProcedure [dbo].[usp_RSOverview]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_RSOverview]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_RSOverview] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_RSOverview]
(
@Environment Varchar(128),
@RSVersion varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

--Parsing values into table
Select Item
into #Environ_List
From
dbo.DelimitedSplit8K(@Environment,',')

Select Item
into #SQL_Name_List
From
dbo.DelimitedSplit8K(@RSVersion,',')

--Serverinfo View
Select z.InstanceName, z.RSVersion, z.RSEdition, z.IsSharePointIntegrated, v.Environment from (
select  y.* from(
select InstanceName, Max(DateAdded) as Rundate 
from [RS].[SSRSInfo]
Group BY InstanceName) x
Join [RS].[SSRSInfo] y ON x.Rundate = y.DateAdded and X.InstanceName = y.InstanceName) z
inner join(
select Distinct ServerName, InstanceName, Environment, Description, BusinessOwner from  [Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.Item
inner join #SQL_Name_List as SQLList on Z.RSVersion = SQLList.Item
Order by InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_SQLOverview]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SQLOverview]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_SQLOverview] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_SQLOverview]
(
@Environment Varchar(128),
@SQLVersion varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Parsing values into table
Select Item
into #Environ_List
From
dbo.DelimitedSplit8K(@Environment,',')

Select Item
into #SQL_Name_List
From
dbo.DelimitedSplit8K(@SQLVersion,',')

--Serverinfo View
Select z.InstanceName, z.SQLVersion, z.SQLPatchLevel, z.IsSPUpToDate, z.SQLEdition, Z.NoOfUsrDBs, v.Environment from (
select  y.* from(
select InstanceName, Max(DateAdded) as Rundate 
from [Inst].[InstanceInfo]
Group BY InstanceName) x
Join [Inst].[InstanceInfo] y ON x.Rundate = y.DateAdded and X.InstanceName = y.InstanceName) z
inner join(
select Distinct ServerName, InstanceName, Environment, Description, BusinessOwner from  [Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.item
inner join #SQL_Name_List as SQLList on Z.SQLVersion = SQLList.item
Order by InstanceName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_SQLSvcs]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SQLSvcs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_SQLSvcs] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_SQLSvcs]
(
@servername varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--SQL Services info
select  y.DisplayName, Y.Started, Y.StartMode, Y.LogonAs, Y. ProcessId from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[SQLServices]
Group BY Servername) x
Join [Svr].[SQLServices] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName and y.ServerName =  @servername

END
GO
/****** Object:  StoredProcedure [dbo].[usp_SvrOverview]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SvrOverview]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_SvrOverview] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_SvrOverview]
(
@Environment Varchar(128),
@OSName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Serverinfo View
--Parsing values into table
Select Item
into #Environ_List
From
dbo.DelimitedSplit8K(@Environment,',')

SELECT Item
INTO #OS_Name_List 
FROM
dbo.DelimitedSplit8K(@OSName,',')

Select z.ServerName, z.OSName, w.NumberOfProcessors,  w.NumberOfCores, w.IsVM, w.IsClu, w.TotalPhysicalMemoryInGB--, v.Environment
				  from (
select  y.* from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[OSInfo]
Group BY ServerName) x
Join [Svr].[OSInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName) z

inner join (SELECT DISTINCT ServerName, InstanceName, Environment, Description, BusinessOwner, Baseline, SQLPing
                       FROM      Svr.ServerList) AS v ON z.ServerName = v.ServerName
inner join (
select  y.* from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[ServerInfo]
Group BY ServerName) x
Join [Svr].[ServerInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName)w ON Z.ServerName = W.ServerName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.Item
inner join #OS_Name_List as OSList on z.OSName = OSList.Item
Order by z.ServerName

--inner join(
--select Distinct ServerName, InstanceName, Environment, Description, BusinessOwner from  [Svr].[ServerList]) v ON Z.ServerName = V.ServerName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_SvrStats]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SvrStats]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_SvrStats] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_SvrStats]
(
@ServerName varchar(128),
@StartDate DateTime,
@EndDate DateTime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance stats info
SELECT ServerName,  RunDate, PctProcTm, ProcQLen, AvDskRd, AvDskWt, AvDskQLen, AvailMB, PgFlUsg
FROM     Svr.SvrBaselineStats
where ServerName =  @ServerName and (RunDate >= @StartDate) AND (RunDate <= @EndDate)

END
GO
/****** Object:  StoredProcedure [dbo].[usp_SysView]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SysView]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_SysView] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_SysView]
(
@servername varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Serverinfo View
Select z.ServerName, z.OSName, z.OSArchitecture, z.OSVersion, z.OSServicePack, z.OSInstallDate, z.OSLastRestart, z.OSUpTime, z.OSTotalVisibleMemorySizeInGB, 
                  z.OSFreePhysicalMemoryInGB, z.OSTotalVirtualMemorySizeInGB, z.OSFreeVirtualMemoryInGB, z.OSFreeSpaceInPagingFilesInGB, W.IPAddress, w.Model, w.Manufacturer, w.Description, 
                  w.SystemType, w.ActiveNodeName, w.Domain, w.DomainRole, w.PartOfDomain, w.NumberOfProcessors, w.NumberOfLogicalProcessors, w.NumberOfCores, 
                  w.IsHyperThreaded, w.CurrentCPUSpeed, w.MaxCPUSpeed, w.IsPowerSavingModeON, w.TotalPhysicalMemoryInGB, w.IsPagefileManagedBySystem, w.IsVM, w.IsClu, 
                  w.DateAdded--, v.Environment, v.Description, v.BusinessOwner, V.InstanceName
				  from (
select  y.* from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[OSInfo]
Group BY Servername) x
Join [Svr].[OSInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName) z
inner join (
select  y.* from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[ServerInfo]
Group BY Servername) x
Join [Svr].[ServerInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName)w ON Z.ServerName = W.ServerName and z.ServerName = @servername
--inner join(
--select Distinct ServerName, InstanceName, Environment, Description, BusinessOwner from  [Svr].[ServerList]) v ON Z.ServerName = V.ServerName
END
GO
/****** Object:  StoredProcedure [dbo].[usp_TblPerms]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_TblPerms]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_TblPerms] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_TblPerms]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Table level permissions info
SELECT y.[InstanceName], y.[DBName], y.[UserName], y.[ObjName], y.[PermName], y.[PermState], y.[DateAdded]
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [Tbl].[TblPermissions]
                  GROUP BY InstanceName) AS x INNER JOIN
                 [Tbl].[TblPermissions] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName =  @InstanceName

END
GO
/****** Object:  StoredProcedure [dbo].[usp_WaitStats]    Script Date: 7/26/2021 8:40:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_WaitStats]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_WaitStats] AS' 
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_WaitStats]
(
@ServerName varchar(128),
@StartDate DateTime,
@EndDate DateTime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance stats info
SELECT DISTINCT WaitType, COUNT(WaitType) AS count
FROM     [Inst].[WaitStats]
where ServerName =  @ServerName and (DateAdded >= @StartDate) AND (DateAdded <= @EndDate)
GROUP BY WaitType
END
GO

USE [CentralDB]
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1600, N'RTM ', N'', CAST(N'2008-08-06' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008', N'RTM ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1600, N'RTM ', N'', CAST(N'2010-05-10' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1617, N'RTM MS11-049: GDR Security Update', N'https://support.microsoft.com/en-us/help/2494088', CAST(N'2011-06-14' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM MS11-049: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1702, N'RTM CU1', N'https://support.microsoft.com/en-us/help/981355', CAST(N'2010-05-18' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1720, N'RTM CU2', N'https://support.microsoft.com/en-us/help/2072493', CAST(N'2010-06-21' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1734, N'RTM CU3', N'https://support.microsoft.com/en-us/help/2261464', CAST(N'2010-08-16' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1746, N'RTM CU4', N'https://support.microsoft.com/en-us/help/2345451', CAST(N'2010-10-18' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1753, N'RTM CU5', N'https://support.microsoft.com/en-us/help/2438347', CAST(N'2010-12-20' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1763, N'RTM CU1', N'https://support.microsoft.com/en-us/help/956717', CAST(N'2008-09-22' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008', N'RTM Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1765, N'RTM CU6', N'https://support.microsoft.com/en-us/help/2489376', CAST(N'2011-02-21' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1777, N'RTM CU7', N'https://support.microsoft.com/en-us/help/2507770', CAST(N'2011-04-18' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1779, N'RTM CU2', N'https://support.microsoft.com/en-us/help/958186', CAST(N'2008-11-19' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008', N'RTM Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1787, N'RTM CU3', N'https://support.microsoft.com/en-us/help/960484', CAST(N'2009-01-19' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008', N'RTM Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1790, N'RTM MS11-049: QFE Security Update', N'https://support.microsoft.com/en-us/help/2494086', CAST(N'2011-06-14' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM MS11-049: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1797, N'RTM CU8', N'https://support.microsoft.com/en-us/help/2534352', CAST(N'2011-06-20' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1798, N'RTM CU4', N'https://support.microsoft.com/en-us/help/963036', CAST(N'2009-03-16' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008', N'RTM Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1804, N'RTM CU9', N'https://support.microsoft.com/en-us/help/2567713', CAST(N'2011-08-15' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1806, N'RTM CU5', N'https://support.microsoft.com/en-us/help/969531', CAST(N'2009-05-18' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008', N'RTM Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1807, N'RTM CU10', N'https://support.microsoft.com/en-us/help/2591746', CAST(N'2011-10-17' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1809, N'RTM CU11', N'https://support.microsoft.com/en-us/help/2633145', CAST(N'2011-12-19' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1810, N'RTM CU12', N'https://support.microsoft.com/en-us/help/2659692', CAST(N'2012-02-21' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1812, N'RTM CU6', N'https://support.microsoft.com/en-us/help/971490', CAST(N'2009-07-20' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008', N'RTM Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1815, N'RTM CU13', N'https://support.microsoft.com/en-us/help/2679366', CAST(N'2012-04-16' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'RTM Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1818, N'RTM CU7', N'https://support.microsoft.com/en-us/help/973601', CAST(N'2009-09-21' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008', N'RTM Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1823, N'RTM CU8', N'https://support.microsoft.com/en-us/help/975976', CAST(N'2009-11-16' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008', N'RTM Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1828, N'RTM CU9', N'https://support.microsoft.com/en-us/help/977444', CAST(N'2010-01-18' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008', N'RTM Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 1835, N'RTM CU10', N'https://support.microsoft.com/en-us/help/979064', CAST(N'2010-03-15' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008', N'RTM Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2500, N'SP1 ', N'https://support.microsoft.com/en-us/help/2528583', CAST(N'2011-07-12' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2531, N'SP1 ', N'', CAST(N'2009-04-01' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2550, N'SP1 MS12-070: GDR Security Update', N'https://support.microsoft.com/en-us/help/2754849', CAST(N'2012-10-09' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 MS12-070: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2573, N'SP1 MS11-049: GDR Security update', N'https://support.microsoft.com/en-us/help/2494096', CAST(N'2011-06-14' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 MS11-049: GDR Security update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2710, N'SP1 CU1', N'https://support.microsoft.com/en-us/help/969099', CAST(N'2009-04-16' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2714, N'SP1 CU2', N'https://support.microsoft.com/en-us/help/970315', CAST(N'2009-05-18' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2723, N'SP1 CU3', N'https://support.microsoft.com/en-us/help/971491', CAST(N'2009-07-20' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2734, N'SP1 CU4', N'https://support.microsoft.com/en-us/help/973602', CAST(N'2009-09-21' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2746, N'SP1 CU5', N'https://support.microsoft.com/en-us/help/975977', CAST(N'2009-11-16' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2757, N'SP1 CU6', N'https://support.microsoft.com/en-us/help/977443', CAST(N'2010-01-18' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2766, N'SP1 CU7', N'https://support.microsoft.com/en-us/help/979065', CAST(N'2010-03-26' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2769, N'SP1 CU1', N'https://support.microsoft.com/en-us/help/2544793', CAST(N'2011-07-18' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2772, N'SP1 CU2', N'https://support.microsoft.com/en-us/help/2567714', CAST(N'2011-08-15' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2775, N'SP1 CU8', N'https://support.microsoft.com/en-us/help/981702', CAST(N'2010-05-17' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2789, N'SP1 CU9', N'https://support.microsoft.com/en-us/help/2083921', CAST(N'2010-07-19' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2789, N'SP1 CU3', N'https://support.microsoft.com/en-us/help/2591748', CAST(N'2011-10-17' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2796, N'SP1 CU4', N'https://support.microsoft.com/en-us/help/2633146', CAST(N'2011-12-19' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2799, N'SP1 CU10', N'https://support.microsoft.com/en-us/help/2279604', CAST(N'2010-09-20' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2804, N'SP1 CU11', N'https://support.microsoft.com/en-us/help/2413738', CAST(N'2010-11-15' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2806, N'SP1 CU5', N'https://support.microsoft.com/en-us/help/2659694', CAST(N'2012-02-22' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2808, N'SP1 CU12', N'https://support.microsoft.com/en-us/help/2467236', CAST(N'2011-01-17' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2811, N'SP1 CU6', N'https://support.microsoft.com/en-us/help/2679367', CAST(N'2012-04-16' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2816, N'SP1 CU13', N'https://support.microsoft.com/en-us/help/2497673', CAST(N'2011-03-17' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2817, N'SP1 CU7', N'https://support.microsoft.com/en-us/help/2703282', CAST(N'2012-06-18' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2821, N'SP1 CU14', N'https://support.microsoft.com/en-us/help/2527187', CAST(N'2011-05-16' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 14')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2822, N'SP1 CU8', N'https://support.microsoft.com/en-us/help/2723743', CAST(N'2012-08-31' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2841, N'SP1 MS11-049: QFE Security Update', N'https://support.microsoft.com/en-us/help/2494100', CAST(N'2011-06-14' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 MS11-049: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2847, N'SP1 CU15', N'https://support.microsoft.com/en-us/help/2555406', CAST(N'2011-07-18' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 15')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2850, N'SP1 CU16', N'https://support.microsoft.com/en-us/help/2582282', CAST(N'2011-09-19' AS Date), CAST(N'2011-10-11' AS Date), CAST(N'2011-10-11' AS Date), N'SQL Server 2008', N'Service Pack 1 Cumulative Update 16')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2861, N'SP1 MS12-070: QFE Security Update', N'https://support.microsoft.com/en-us/help/2716439', CAST(N'2012-10-09' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 MS12-070: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2866, N'SP1 CU9', N'https://support.microsoft.com/en-us/help/2756574', CAST(N'2012-10-15' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2868, N'SP1 CU10', N'https://support.microsoft.com/en-us/help/2783135', CAST(N'2012-12-17' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2869, N'SP1 CU11', N'https://support.microsoft.com/en-us/help/2812683', CAST(N'2013-02-18' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2874, N'SP1 CU12', N'https://support.microsoft.com/en-us/help/2828727', CAST(N'2013-04-15' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2876, N'SP1 CU13', N'https://support.microsoft.com/en-us/help/2855792', CAST(N'2013-06-17' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 2881, N'SP1 CU14', N'https://support.microsoft.com/en-us/help/2868244', CAST(N'2013-08-08' AS Date), CAST(N'2013-10-08' AS Date), CAST(N'2013-10-08' AS Date), N'SQL Server 2008 R2', N'Service Pack 1 Cumulative Update 14')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4000, N'SP2 ', N'https://support.microsoft.com/en-us/help/2285068', CAST(N'2010-09-29' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4000, N'SP2 ', N'https://support.microsoft.com/en-us/help/2630458', CAST(N'2012-07-26' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4033, N'SP2 MS14-044: GDR Security Update', N'https://support.microsoft.com/en-us/help/2977320', CAST(N'2014-08-12' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 MS14-044: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4042, N'SP2 MS15-058: GDR Security Update', N'https://support.microsoft.com/en-us/help/3045313', CAST(N'2015-07-14' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 MS15-058: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4064, N'SP2 MS11-049: GDR Security Update', N'https://support.microsoft.com/en-us/help/2494089', CAST(N'2011-06-14' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 MS11-049: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4067, N'SP2 MS12-070: GDR Security Update', N'https://support.microsoft.com/en-us/help/2716434', CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 MS12-070: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4260, N'SP2 CU1', N'https://support.microsoft.com/en-us/help/2720425', CAST(N'2012-07-24' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4263, N'SP2 CU2', N'https://support.microsoft.com/en-us/help/2740411', CAST(N'2012-08-31' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4266, N'SP2 CU1', N'https://support.microsoft.com/en-us/help/2289254', CAST(N'2010-11-15' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4266, N'SP2 CU3', N'https://support.microsoft.com/en-us/help/2754552', CAST(N'2012-10-15' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4270, N'SP2 CU4', N'https://support.microsoft.com/en-us/help/2777358', CAST(N'2012-12-17' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4272, N'SP2 CU2', N'https://support.microsoft.com/en-us/help/2467239', CAST(N'2011-01-17' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4276, N'SP2 CU5', N'https://support.microsoft.com/en-us/help/2797460', CAST(N'2013-02-18' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4279, N'SP2 CU3', N'https://support.microsoft.com/en-us/help/2498535', CAST(N'2011-03-17' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4279, N'SP2 CU6', N'https://support.microsoft.com/en-us/help/2830140', CAST(N'2013-04-15' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4285, N'SP2 CU4', N'https://support.microsoft.com/en-us/help/2527180', CAST(N'2011-05-16' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4285, N'SP2 CU7', N'https://support.microsoft.com/en-us/help/2844090', CAST(N'2013-06-17' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4290, N'SP2 CU8', N'https://support.microsoft.com/en-us/help/2871401', CAST(N'2013-08-22' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4295, N'SP2 CU9', N'https://support.microsoft.com/en-us/help/2887606', CAST(N'2013-10-28' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4297, N'SP2 CU10', N'https://support.microsoft.com/en-us/help/2908087', CAST(N'2013-12-17' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4302, N'SP2 CU11', N'https://support.microsoft.com/en-us/help/2926028', CAST(N'2014-02-18' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4305, N'SP2 CU12', N'https://support.microsoft.com/en-us/help/2938478', CAST(N'2014-04-21' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4311, N'SP2 MS11-049: QFE Security Update', N'https://support.microsoft.com/en-us/help/2494094', CAST(N'2011-06-14' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 MS11-049: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4316, N'SP2 CU5', N'https://support.microsoft.com/en-us/help/2555408', CAST(N'2011-07-18' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4319, N'SP2 CU13', N'https://support.microsoft.com/en-us/help/2967540', CAST(N'2014-06-30' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4321, N'SP2 CU6', N'https://support.microsoft.com/en-us/help/2582285', CAST(N'2011-09-19' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4321, N'SP2 MS14-044: QFE Security Update', N'https://support.microsoft.com/en-us/help/2977319', CAST(N'2014-08-14' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 MS14-044: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4323, N'SP2 CU7', N'https://support.microsoft.com/en-us/help/2617148', CAST(N'2011-11-21' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4326, N'SP2 CU8', N'https://support.microsoft.com/en-us/help/2648096', CAST(N'2012-01-16' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4330, N'SP2 CU9', N'https://support.microsoft.com/en-us/help/2673382', CAST(N'2012-03-19' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4332, N'SP2 CU10', N'https://support.microsoft.com/en-us/help/2696625', CAST(N'2012-05-21' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4333, N'SP2 CU11', N'https://support.microsoft.com/en-us/help/2715951', CAST(N'2012-07-16' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4339, N'SP2 MS15-058: QFE Security Update', N'https://support.microsoft.com/en-us/help/3045312', CAST(N'2015-07-14' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008 R2', N'Service Pack 2 MS15-058: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 4371, N'SP2 MS12-070: QFE Security Update', N'https://support.microsoft.com/en-us/help/2716433', CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), CAST(N'2012-10-09' AS Date), N'SQL Server 2008', N'Service Pack 2 MS12-070: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5500, N'SP3 ', N'https://support.microsoft.com/en-us/help/2546951', CAST(N'2011-10-06' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5512, N'SP3 MS12-070: GDR Security Update', N'https://support.microsoft.com/en-us/help/2716436', CAST(N'2012-10-09' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 MS12-070: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5520, N'SP3 MS14-044: GDR Security Update', N'https://support.microsoft.com/en-us/help/2977321', CAST(N'2014-08-12' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 MS14-044: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5538, N'SP3 MS15-058: GDR Security Update', N'https://support.microsoft.com/en-us/help/3045305', CAST(N'2015-07-14' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 MS15-058: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5766, N'SP3 CU1', N'https://support.microsoft.com/en-us/help/2617146', CAST(N'2011-10-17' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5768, N'SP3 CU2', N'https://support.microsoft.com/en-us/help/2633143', CAST(N'2011-11-21' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5770, N'SP3 CU3', N'https://support.microsoft.com/en-us/help/2648098', CAST(N'2012-01-16' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5775, N'SP3 CU4', N'https://support.microsoft.com/en-us/help/2673383', CAST(N'2012-03-19' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5785, N'SP3 CU5', N'https://support.microsoft.com/en-us/help/2696626', CAST(N'2012-05-21' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5788, N'SP3 CU6', N'https://support.microsoft.com/en-us/help/2715953', CAST(N'2012-07-16' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5794, N'SP3 CU7', N'https://support.microsoft.com/en-us/help/2738350', CAST(N'2012-09-17' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5826, N'SP3 MS12-070: QFE Security Update', N'https://support.microsoft.com/en-us/help/2716435', CAST(N'2012-10-09' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 MS12-070: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5828, N'SP3 CU8', N'https://support.microsoft.com/en-us/help/2771833', CAST(N'2012-11-19' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5829, N'SP3 CU9', N'https://support.microsoft.com/en-us/help/2799883', CAST(N'2013-01-21' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5835, N'SP3 CU10', N'https://support.microsoft.com/en-us/help/2814783', CAST(N'2013-03-18' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5840, N'SP3 CU11', N'https://support.microsoft.com/en-us/help/2834048', CAST(N'2013-05-20' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5844, N'SP3 CU12', N'https://support.microsoft.com/en-us/help/2863205', CAST(N'2013-07-15' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5846, N'SP3 CU13', N'https://support.microsoft.com/en-us/help/2880350', CAST(N'2013-09-16' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5848, N'SP3 CU14', N'https://support.microsoft.com/en-us/help/2893410', CAST(N'2013-11-18' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 14')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5850, N'SP3 CU15', N'https://support.microsoft.com/en-us/help/2923520', CAST(N'2014-01-20' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 15')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5852, N'SP3 CU16', N'https://support.microsoft.com/en-us/help/2936421', CAST(N'2014-03-17' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 16')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5861, N'SP3 CU17', N'https://support.microsoft.com/en-us/help/2958696', CAST(N'2014-05-19' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 Cumulative Update 17')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5869, N'SP3 MS14-044: QFE Security Update', N'https://support.microsoft.com/en-us/help/2984340, https://support.microsoft.com/en-us/help/2977322', CAST(N'2014-08-12' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 MS14-044: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 5890, N'SP3 MS15-058: QFE Security Update', N'https://support.microsoft.com/en-us/help/3045303', CAST(N'2015-07-14' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 MS15-058: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 6000, N'SP3 ', N'https://support.microsoft.com/en-us/help/2979597', CAST(N'2014-09-26' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'Service Pack 3 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 6220, N'SP3 MS15-058: QFE Security Update', N'https://support.microsoft.com/en-us/help/3045316', CAST(N'2015-07-14' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'Service Pack 3 MS15-058: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 6241, N'SP3 MS15-058: GDR Security Update', N'https://support.microsoft.com/en-us/help/3045311', CAST(N'2015-07-14' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 MS15-058: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 6529, N'SP3 MS15-058: QFE Security Update', N'https://support.microsoft.com/en-us/help/3045314', CAST(N'2015-07-14' AS Date), CAST(N'2014-07-08' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2008 R2', N'Service Pack 3 MS15-058: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (10, 6535, N'SP3 MS15-058: QFE Security Update', N'https://support.microsoft.com/en-us/help/3045308', CAST(N'2015-07-14' AS Date), CAST(N'2015-10-13' AS Date), CAST(N'2015-10-13' AS Date), N'SQL Server 2008', N'Service Pack 3 MS15-058: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2100, N'RTM ', N'', CAST(N'2012-03-06' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2218, N'RTM MS12-070: GDR Security Update', N'https://support.microsoft.com/en-us/help/2716442', CAST(N'2012-10-09' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM MS12-070: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2316, N'RTM CU1', N'https://support.microsoft.com/en-us/help/2679368', CAST(N'2012-04-12' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2325, N'RTM CU2', N'https://support.microsoft.com/en-us/help/2703275', CAST(N'2012-06-18' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2332, N'RTM CU3', N'https://support.microsoft.com/en-us/help/2723749', CAST(N'2012-08-31' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2376, N'RTM MS12-070: QFE Security Update', N'https://support.microsoft.com/en-us/help/2716441', CAST(N'2012-10-09' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM MS12-070: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2383, N'RTM CU4', N'https://support.microsoft.com/en-us/help/2758687', CAST(N'2012-10-15' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2395, N'RTM CU5', N'https://support.microsoft.com/en-us/help/2777772', CAST(N'2012-12-17' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2401, N'RTM CU6', N'https://support.microsoft.com/en-us/help/2728897', CAST(N'2013-02-18' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2405, N'RTM CU7', N'https://support.microsoft.com/en-us/help/2823247', CAST(N'2013-04-15' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2410, N'RTM CU8', N'https://support.microsoft.com/en-us/help/2844205', CAST(N'2013-06-17' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2419, N'RTM CU9', N'https://support.microsoft.com/en-us/help/2867319', CAST(N'2013-08-20' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2420, N'RTM CU10', N'https://support.microsoft.com/en-us/help/2891666', CAST(N'2013-10-21' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 2424, N'RTM CU11', N'https://support.microsoft.com/en-us/help/2908007', CAST(N'2013-12-16' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'RTM Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3000, N'SP1 ', N'https://support.microsoft.com/en-us/help/2674319', CAST(N'2012-11-07' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3153, N'SP1 MS14-044: GDR Security Update', N'https://support.microsoft.com/en-us/help/2977326', CAST(N'2014-08-12' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 MS14-044: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3156, N'SP1 MS15-058: GDR Security Update', N'https://support.microsoft.com/en-us/help/3045318', CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 MS15-058: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3321, N'SP1 CU1', N'https://support.microsoft.com/en-us/help/2765331', CAST(N'2012-11-20' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3339, N'SP1 CU2', N'https://support.microsoft.com/en-us/help/2790947', CAST(N'2013-01-21' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3349, N'SP1 CU3', N'https://support.microsoft.com/en-us/help/2812412', CAST(N'2013-03-18' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3368, N'SP1 CU4', N'https://support.microsoft.com/en-us/help/2833645', CAST(N'2013-05-30' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3373, N'SP1 CU5', N'https://support.microsoft.com/en-us/help/2861107', CAST(N'2013-07-15' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3381, N'SP1 CU6', N'https://support.microsoft.com/en-us/help/2874879', CAST(N'2013-09-16' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3393, N'SP1 CU7', N'https://support.microsoft.com/en-us/help/2894115', CAST(N'2013-11-18' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3401, N'SP1 CU8', N'https://support.microsoft.com/en-us/help/2917531', CAST(N'2014-01-20' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3412, N'SP1 CU9', N'https://support.microsoft.com/en-us/help/2931078', CAST(N'2014-03-17' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3431, N'SP1 CU10', N'https://support.microsoft.com/en-us/help/2954099', CAST(N'2014-05-19' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3449, N'SP1 CU11', N'https://support.microsoft.com/en-us/help/2975396', CAST(N'2014-07-21' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3460, N'SP1 MS14-044: QFE Security Update ', N'https://support.microsoft.com/en-us/help/2977325', CAST(N'2014-08-12' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 MS14-044: QFE Security Update ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3470, N'SP1 CU12', N'https://support.microsoft.com/en-us/help/2991533', CAST(N'2014-09-15' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3482, N'SP1 CU13', N'https://support.microsoft.com/en-us/help/3002044', CAST(N'2014-11-17' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 3513, N'SP1 MS15-058: QFE Security Update', N'https://support.microsoft.com/en-us/help/3045317', CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), CAST(N'2015-07-14' AS Date), N'SQL Server 2012', N'Service Pack 1 MS15-058: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5058, N'SP2 ', N'https://support.microsoft.com/en-us/help/2958429', CAST(N'2014-06-10' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5343, N'SP2 MS15-058: GDR Security Update', N'https://support.microsoft.com/en-us/help/3045321', CAST(N'2015-07-14' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 MS15-058: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5532, N'SP2 CU1', N'https://support.microsoft.com/en-us/help/2976982', CAST(N'2014-07-23' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5548, N'SP2 CU2', N'https://support.microsoft.com/en-us/help/2983175', CAST(N'2014-09-15' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5556, N'SP2 CU3', N'https://support.microsoft.com/en-us/help/3002049', CAST(N'2014-11-17' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5569, N'SP2 CU4', N'https://support.microsoft.com/en-us/help/3007556', CAST(N'2015-01-19' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5582, N'SP2 CU5', N'https://support.microsoft.com/en-us/help/3037255', CAST(N'2015-03-16' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5592, N'SP2 CU6', N'https://support.microsoft.com/en-us/help/3052468', CAST(N'2015-05-18' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5613, N'SP2 MS15-058: QFE Security Update', N'https://support.microsoft.com/en-us/help/3045319', CAST(N'2015-07-14' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 MS15-058: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5623, N'SP2 CU7', N'https://support.microsoft.com/en-us/help/3072100', CAST(N'2015-07-20' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5634, N'SP2 CU8', N'https://support.microsoft.com/en-us/help/3082561', CAST(N'2015-09-21' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5641, N'SP2 CU9', N'https://support.microsoft.com/en-us/help/3098512', CAST(N'2015-11-16' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5644, N'SP2 CU10', N'https://support.microsoft.com/en-us/help/3120313', CAST(N'2016-01-19' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5646, N'SP2 CU11', N'https://support.microsoft.com/en-us/help/3137745', CAST(N'2016-03-21' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5649, N'SP2 CU12', N'https://support.microsoft.com/en-us/help/3152637 ', CAST(N'2016-05-16' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5655, N'SP2 CU13', N'https://support.microsoft.com/en-us/help/3165266 ', CAST(N'2016-07-18' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5657, N'SP2 CU14', N'https://support.microsoft.com/en-us/help/3180914 ', CAST(N'2016-09-19' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 14')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5676, N'SP2 CU15', N'https://support.microsoft.com/en-us/help/3205416 ', CAST(N'2016-11-17' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 15')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 5678, N'SP2 CU16', N'https://support.microsoft.com/en-us/help/3205416 ', CAST(N'2016-11-17' AS Date), CAST(N'2017-01-10' AS Date), CAST(N'2017-01-10' AS Date), N'SQL Server 2012', N'Service Pack 2 Cumulative Update 16')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 6020, N'SP3 ', N'https://support.microsoft.com/en-us/help/3072779', CAST(N'2015-11-20' AS Date), CAST(N'2018-10-09' AS Date), CAST(N'2018-10-09' AS Date), N'SQL Server 2012', N'Service Pack 3 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 6518, N'SP3 CU1', N'https://support.microsoft.com/en-us/help/3123299', CAST(N'2016-01-19' AS Date), CAST(N'2018-10-09' AS Date), CAST(N'2018-10-09' AS Date), N'SQL Server 2012', N'Service Pack 3 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 6523, N'SP3 CU2', N'https://support.microsoft.com/en-us/help/3137746', CAST(N'2016-03-21' AS Date), CAST(N'2018-10-09' AS Date), CAST(N'2018-10-09' AS Date), N'SQL Server 2012', N'Service Pack 3 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 6537, N'SP3 CU3', N'https://support.microsoft.com/en-us/help/3152635 ', CAST(N'2016-05-16' AS Date), CAST(N'2018-10-09' AS Date), CAST(N'2018-10-09' AS Date), N'SQL Server 2012', N'Service Pack 3 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 6540, N'SP3 CU4', N'https://support.microsoft.com/en-us/help/3165264 ', CAST(N'2016-07-18' AS Date), CAST(N'2018-10-09' AS Date), CAST(N'2018-10-09' AS Date), N'SQL Server 2012', N'Service Pack 3 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 6544, N'SP3 CU5', N'https://support.microsoft.com/en-us/help/3180915 ', CAST(N'2016-09-19' AS Date), CAST(N'2018-10-09' AS Date), CAST(N'2018-10-09' AS Date), N'SQL Server 2012', N'Service Pack 3 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 6567, N'SP3 CU6', N'https://support.microsoft.com/en-us/help/3194992 ', CAST(N'2016-11-17' AS Date), CAST(N'2018-10-09' AS Date), CAST(N'2018-10-09' AS Date), N'SQL Server 2012', N'Service Pack 3 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 6579, N'SP3 CU7', N'https://support.microsoft.com/en-us/help/3205051 ', CAST(N'2017-01-17' AS Date), CAST(N'2018-10-09' AS Date), CAST(N'2018-10-09' AS Date), N'SQL Server 2012', N'Service Pack 3 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 6594, N'SP3 CU8', N'https://support.microsoft.com/en-us/help/3205051 ', CAST(N'2017-03-20' AS Date), CAST(N'2018-10-09' AS Date), CAST(N'2018-10-09' AS Date), N'SQL Server 2012', N'Service Pack 3 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 6598, N'SP3 CU9', N'https://support.microsoft.com/en-us/help/4016762', CAST(N'2017-05-15' AS Date), CAST(N'2018-10-09' AS Date), CAST(N'2018-10-09' AS Date), N'SQL Server 2012', N'Service Pack 3 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 6607, N'SP3 CU10', N'https://support.microsoft.com/en-us/help/4025925', CAST(N'2017-08-08' AS Date), CAST(N'2018-10-09' AS Date), CAST(N'2018-10-09' AS Date), N'SQL Server 2012', N'Service Pack 3 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 7001, N'SP4 ', N'https://support.microsoft.com/en-us/help/4018073', CAST(N'2017-10-02' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'Service Pack 4 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 7462, N'SP4 ADV180002: GDR Security Update', N'https://support.microsoft.com/en-us/help/4057116', CAST(N'2018-01-12' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'Service Pack 4 ADV180002: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 7469, N'SP4 On-Demand Hotfix Update', N'https://support.microsoft.com/en-us/help/4091266', CAST(N'2018-03-28' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'Service Pack 4 SP4 On-Demand Hotfix Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 7493, N'SP4 GDR Security Update', N'https://support.microsoft.com/en-us/help/4532098', CAST(N'2020-02-11' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'Service Pack 4 GDR Security Update for CVE-2020-0618')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (11, 7507, N'SP4 GDR Security Update', N'https://support.microsoft.com/en-us/help/4583465', CAST(N'2021-01-12' AS Date), CAST(N'2017-07-11' AS Date), CAST(N'2022-07-12' AS Date), N'SQL Server 2012', N'Service Pack 4 GDR Security Update for CVE-2021-1636')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2000, N'RTM ', N'', CAST(N'2014-04-01' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2254, N'RTM MS14-044: GDR Security Update', N'https://support.microsoft.com/en-us/help/2977315', CAST(N'2014-08-12' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM MS14-044: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2269, N'RTM MS15-058: GDR Security Update ', N'https://support.microsoft.com/en-us/help/3045324', CAST(N'2015-07-14' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM MS15-058: GDR Security Update ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2342, N'RTM CU1', N'https://support.microsoft.com/en-us/help/2931693', CAST(N'2014-04-21' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2370, N'RTM CU2', N'https://support.microsoft.com/en-us/help/2967546', CAST(N'2014-06-27' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2381, N'RTM MS14-044: QFE Security Update', N'https://support.microsoft.com/en-us/help/2977316', CAST(N'2014-08-12' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM MS14-044: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2402, N'RTM CU3', N'https://support.microsoft.com/en-us/help/2984923', CAST(N'2014-08-18' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2430, N'RTM CU4', N'https://support.microsoft.com/en-us/help/2999197', CAST(N'2014-10-21' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2456, N'RTM CU5', N'https://support.microsoft.com/en-us/help/3011055', CAST(N'2014-12-17' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2480, N'RTM CU6', N'https://support.microsoft.com/en-us/help/3031047', CAST(N'2015-02-16' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2495, N'RTM CU7', N'https://support.microsoft.com/en-us/help/3046038', CAST(N'2015-04-20' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2546, N'RTM CU8', N'https://support.microsoft.com/en-us/help/3067836', CAST(N'2015-06-19' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2548, N'RTM MS15-058: QFE Security Update', N'https://support.microsoft.com/en-us/help/3045323', CAST(N'2015-07-14' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM MS15-058: QFE Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2553, N'RTM CU9', N'https://support.microsoft.com/en-us/help/3075949', CAST(N'2015-08-17' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2556, N'RTM CU10', N'https://support.microsoft.com/en-us/help/3094220', CAST(N'2015-10-19' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2560, N'RTM CU11', N'https://support.microsoft.com/en-us/help/3106659', CAST(N'2015-12-21' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2564, N'RTM CU12', N'https://support.microsoft.com/en-us/help/3130923', CAST(N'2016-02-22' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2568, N'RTM CU13', N'https://support.microsoft.com/en-us/help/3144517', CAST(N'2016-04-18' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 2569, N'RTM CU14', N'https://support.microsoft.com/en-us/help/3158271 ', CAST(N'2016-06-20' AS Date), CAST(N'2016-07-12' AS Date), CAST(N'2016-07-12' AS Date), N'SQL Server 2014', N'RTM Cumulative Update 14')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4100, N'SP1 ', N'https://support.microsoft.com/en-us/help/3058865', CAST(N'2015-05-04' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4213, N'SP1 MS15-058: GDR Security Update', N'https://support.microsoft.com/en-us/help/3070446', CAST(N'2015-07-14' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 MS15-058: GDR Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4416, N'SP1 CU1', N'https://support.microsoft.com/en-us/help/3067839', CAST(N'2015-06-19' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4422, N'SP1 CU2', N'https://support.microsoft.com/en-us/help/3075950', CAST(N'2015-08-17' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4427, N'SP1 CU3', N'https://support.microsoft.com/en-us/help/3094221', CAST(N'2015-10-19' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4436, N'SP1 CU4', N'https://support.microsoft.com/en-us/help/3106660', CAST(N'2015-12-21' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4438, N'SP1 CU5', N'https://support.microsoft.com/en-us/help/3130926', CAST(N'2016-02-22' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4449, N'SP1 CU6', N'https://support.microsoft.com/en-us/help/3144524', CAST(N'2016-04-18' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4457, N'SP1 CU6', N'https://support.microsoft.com/en-us/help/3167392 ', CAST(N'2016-05-30' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4459, N'SP1 CU7', N'https://support.microsoft.com/en-us/help/3162659 ', CAST(N'2016-06-20' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4468, N'SP1 CU8', N'https://support.microsoft.com/en-us/help/3174038 ', CAST(N'2016-08-15' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4474, N'SP1 CU9', N'https://support.microsoft.com/en-us/help/3186964 ', CAST(N'2016-10-17' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4491, N'SP1 CU10', N'https://support.microsoft.com/en-us/help/3204399 ', CAST(N'2016-12-19' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4502, N'SP1 CU11', N'https://support.microsoft.com/en-us/help/4010392', CAST(N'2017-02-21' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4511, N'SP1 CU12', N'https://support.microsoft.com/en-us/help/4017793', CAST(N'2017-04-17' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 4522, N'SP1 CU13', N'https://support.microsoft.com/en-us/help/4019099', CAST(N'2017-08-08' AS Date), CAST(N'2017-10-10' AS Date), CAST(N'2017-10-10' AS Date), N'SQL Server 2014', N'Service Pack 1 Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5000, N'SP2 ', N'https://support.microsoft.com/en-us/help/3171021 ', CAST(N'2016-07-11' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5511, N'SP2 CU1', N'https://support.microsoft.com/en-us/help/3178925 ', CAST(N'2016-08-25' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5522, N'SP2 CU2', N'https://support.microsoft.com/en-us/help/3188778 ', CAST(N'2016-10-17' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5538, N'SP2 CU3', N'https://support.microsoft.com/en-us/help/3204388 ', CAST(N'2016-12-19' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5540, N'SP2 CU4', N'https://support.microsoft.com/en-us/help/4010394', CAST(N'2017-02-21' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5546, N'SP2 CU5', N'https://support.microsoft.com/en-us/help/4013098', CAST(N'2017-04-17' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5553, N'SP2 CU6', N'https://support.microsoft.com/en-us/help/4019094', CAST(N'2017-08-08' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5556, N'SP2 CU7', N'https://support.microsoft.com/en-us/help/4032541', CAST(N'2017-08-28' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5557, N'SP2 CU8', N'https://support.microsoft.com/en-us/help/4037356', CAST(N'2017-10-16' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5563, N'SP2 CU9', N'https://support.microsoft.com/en-us/help/4055557', CAST(N'2017-12-18' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5571, N'SP2 CU10', N'https://support.microsoft.com/en-us/help/4052725', CAST(N'2018-01-16' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5579, N'SP2 CU11', N'https://support.microsoft.com/en-us/help/4077063', CAST(N'2018-03-19' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5589, N'SP2 CU12', N'https://support.microsoft.com/en-us/help/4130489', CAST(N'2018-06-18' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5590, N'SP2 CU13', N'https://support.microsoft.com/en-us/help/4456287', CAST(N'2018-08-27' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5600, N'SP2 CU14', N'https://support.microsoft.com/en-us/help/4459860', CAST(N'2018-10-15' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 14')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5605, N'SP2 CU15', N'https://support.microsoft.com/en-us/help/4469137', CAST(N'2018-12-12' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 15')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5626, N'SP2 CU16', N'https://support.microsoft.com/en-us/help/4482967', CAST(N'2019-02-19' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 16')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5632, N'SP2 CU17', N'https://support.microsoft.com/en-us/help/4491540', CAST(N'2019-04-16' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 17')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 5687, N'SP2 CU18', N'https://support.microsoft.com/en-us/help/4500180', CAST(N'2019-07-29' AS Date), CAST(N'2020-01-14' AS Date), CAST(N'2020-01-14' AS Date), N'SQL Server 2014', N'Service Pack 2 Cumulative Update 18')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 6024, N'SP3 ', N'https://support.microsoft.com/en-us/help/4022619', CAST(N'2018-10-30' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2024-07-09' AS Date), N'SQL Server 2014', N'Service Pack 3 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 6164, N'SP3 GDR', N'https://support.microsoft.com/en-us/help/4583463', CAST(N'2021-01-12' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2024-07-09' AS Date), N'SQL Server 2014', N'Service Pack 3 GDR')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 6205, N'SP3 CU1', N'https://support.microsoft.com/en-us/help/4470220', CAST(N'2018-12-12' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2024-07-09' AS Date), N'SQL Server 2014', N'Service Pack 3 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 6214, N'SP3 CU2', N'https://support.microsoft.com/en-us/help/4482960', CAST(N'2019-02-19' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2024-07-09' AS Date), N'SQL Server 2014', N'Service Pack 3 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 6259, N'SP3 CU3', N'https://support.microsoft.com/en-us/help/4491539', CAST(N'2019-04-16' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2024-07-09' AS Date), N'SQL Server 2014', N'Service Pack 3 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 6329, N'SP3 CU4', N'https://support.microsoft.com/en-us/help/4500181', CAST(N'2019-07-29' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2024-07-09' AS Date), N'SQL Server 2014', N'Service Pack 3 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 6372, N'SP3 CU4 GDR', N'https://support.microsoft.com/en-us/help/4535288', CAST(N'2020-02-11' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2024-07-09' AS Date), N'SQL Server 2014', N'Service Pack 3 Cumulative Update 4 GDR')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (12, 6433, N'SP3 CU4 GDR', N'https://support.microsoft.com/en-us/help/4583462', CAST(N'2021-01-12' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2024-07-09' AS Date), N'SQL Server 2014', N'Service Pack 3 Cumulative Update 4 GDR')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 1601, N'RTM ', N'', CAST(N'2016-06-01' AS Date), CAST(N'2019-01-09' AS Date), CAST(N'2019-01-09' AS Date), N'SQL Server 2016', N'RTM ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 2149, N'RTM CU1', N'https://support.microsoft.com/en-us/help/3164674 ', CAST(N'2016-07-25' AS Date), CAST(N'2018-01-09' AS Date), CAST(N'2018-01-09' AS Date), N'SQL Server 2016', N'RTM Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 2164, N'RTM CU2', N'https://support.microsoft.com/en-us/help/3182270 ', CAST(N'2016-09-22' AS Date), CAST(N'2018-01-09' AS Date), CAST(N'2018-01-09' AS Date), N'SQL Server 2016', N'RTM Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 2186, N'RTM CU3', N'https://support.microsoft.com/en-us/help/3205413 ', CAST(N'2016-11-16' AS Date), CAST(N'2018-01-09' AS Date), CAST(N'2018-01-09' AS Date), N'SQL Server 2016', N'RTM Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 2193, N'RTM CU4', N'https://support.microsoft.com/en-us/help/3205052 ', CAST(N'2017-01-17' AS Date), CAST(N'2018-01-09' AS Date), CAST(N'2018-01-09' AS Date), N'SQL Server 2016', N'RTM Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 2197, N'RTM CU5', N'https://support.microsoft.com/en-us/help/4013105', CAST(N'2017-03-20' AS Date), CAST(N'2018-01-09' AS Date), CAST(N'2018-01-09' AS Date), N'SQL Server 2016', N'RTM Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 2204, N'RTM CU6', N'https://support.microsoft.com/en-us/help/4019914', CAST(N'2017-05-15' AS Date), CAST(N'2018-01-09' AS Date), CAST(N'2018-01-09' AS Date), N'SQL Server 2016', N'RTM Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 2210, N'RTM CU7', N'https://support.microsoft.com/en-us/help/4024304', CAST(N'2017-08-08' AS Date), CAST(N'2018-01-09' AS Date), CAST(N'2018-01-09' AS Date), N'SQL Server 2016', N'RTM Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 2213, N'RTM CU8', N'https://support.microsoft.com/en-us/help/4024304', CAST(N'2017-09-18' AS Date), CAST(N'2018-01-09' AS Date), CAST(N'2018-01-09' AS Date), N'SQL Server 2016', N'RTM Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 2216, N'RTM CU9', N'https://support.microsoft.com/en-us/help/4037357', CAST(N'2017-11-20' AS Date), CAST(N'2018-01-09' AS Date), CAST(N'2018-01-09' AS Date), N'SQL Server 2016', N'RTM Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4001, N'SP1 ', N'https://support.microsoft.com/en-us/help/3182545 ', CAST(N'2016-11-16' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4224, N'SP1 CU10 + Security Update', N'https://support.microsoft.com/en-us/help/4458842', CAST(N'2018-08-22' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 10 + Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4411, N'SP1 CU1', N'https://support.microsoft.com/en-us/help/3208177', CAST(N'2017-01-17' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4422, N'SP1 CU2', N'https://support.microsoft.com/en-us/help/4013106', CAST(N'2017-03-20' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4435, N'SP1 CU3', N'https://support.microsoft.com/en-us/help/4019916', CAST(N'2017-05-15' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4446, N'SP1 CU4', N'https://support.microsoft.com/en-us/help/4024305', CAST(N'2017-08-08' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4451, N'SP1 CU5', N'https://support.microsoft.com/en-us/help/4024305', CAST(N'2017-09-18' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4457, N'SP1 CU6', N'https://support.microsoft.com/en-us/help/4037354', CAST(N'2017-11-20' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4466, N'SP1 CU7', N'https://support.microsoft.com/en-us/help/4057119', CAST(N'2018-01-04' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4474, N'SP1 CU8', N'https://support.microsoft.com/en-us/help/4077064', CAST(N'2018-03-19' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4502, N'SP1 CU9', N'https://support.microsoft.com/en-us/help/4100997', CAST(N'2018-05-30' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4514, N'SP1 CU10', N'https://support.microsoft.com/en-us/help/4341569', CAST(N'2018-07-16' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4528, N'SP1 CU11', N'https://support.microsoft.com/en-us/help/4459676', CAST(N'2018-09-17' AS Date), CAST(N'2019-07-09' AS Date), CAST(N'2019-07-09' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4541, N'SP1 CU12', N'https://support.microsoft.com/en-us/help/4464343', CAST(N'2018-11-13' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4550, N'SP1 CU13', N'https://support.microsoft.com/en-us/help/4475775', CAST(N'2019-01-23' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4560, N'SP1 CU14', N'https://support.microsoft.com/en-us/help/4488535', CAST(N'2019-03-19' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 14')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 4574, N'SP1 CU15', N'https://support.microsoft.com/en-us/help/4495257', CAST(N'2019-05-16' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 1 Cumulative Update 15')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5026, N'SP2 ', N'https://support.microsoft.com/en-us/help/4052908', CAST(N'2018-04-24' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5103, N'SP2 GDR', N'https://support.microsoft.com/en-us/help/4583460', CAST(N'2021-01-12' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 GDR')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5149, N'SP2 CU1', N'https://support.microsoft.com/en-us/help/4135048', CAST(N'2018-05-30' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5153, N'SP2 CU2', N'https://support.microsoft.com/en-us/help/4340355', CAST(N'2018-07-16' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5201, N'SP2 CU2 + Security Update', N'https://support.microsoft.com/en-us/help/4458621', CAST(N'2018-08-21' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 2 + Security Update')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5216, N'SP2 CU3', N'https://support.microsoft.com/en-us/help/4458871', CAST(N'2018-09-20' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5233, N'SP2 CU4', N'https://support.microsoft.com/en-us/help/4464106', CAST(N'2018-11-13' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5264, N'SP2 CU5', N'https://support.microsoft.com/en-us/help/4475776', CAST(N'2019-01-23' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5292, N'SP2 CU6', N'https://support.microsoft.com/en-us/help/4488536', CAST(N'2019-03-19' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5337, N'SP2 CU7', N'https://support.microsoft.com/en-us/help/4495256', CAST(N'2019-05-23' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5426, N'SP2 CU8', N'https://support.microsoft.com/en-us/help/4505830', CAST(N'2019-07-31' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5479, N'SP2 CU9', N'https://support.microsoft.com/en-us/help/4505830', CAST(N'2019-09-30' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5492, N'SP2 CU10', N'https://support.microsoft.com/en-us/help/4505830', CAST(N'2019-10-08' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5598, N'SP2 CU11', N'https://support.microsoft.com/en-us/help/4527378', CAST(N'2019-12-09' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5698, N'SP2 CU12', N'https://support.microsoft.com/en-us/help/4536648', CAST(N'2020-02-25' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5820, N'SP2 CU13', N'https://support.microsoft.com/en-us/help/4549825', CAST(N'2020-05-28' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5830, N'SP2 CU14', N'https://support.microsoft.com/en-us/help/4564903', CAST(N'2020-08-06' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 14')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5850, N'SP2 CU15', N'https://support.microsoft.com/en-us/help/4577775', CAST(N'2020-09-28' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 15')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5865, N'SP2 CU15 GDR', N'https://support.microsoft.com/en-us/help/4583461', CAST(N'2021-01-12' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 15 GDR')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5882, N'SP2 CU16', N'https://support.microsoft.com/en-us/help/5000645', CAST(N'2021-02-11' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 16')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (13, 5888, N'SP2 CU17', N'https://support.microsoft.com/en-us/help/5001092', CAST(N'2021-03-29' AS Date), CAST(N'2021-07-13' AS Date), CAST(N'2026-07-14' AS Date), N'SQL Server 2016', N'Service Pack 2 Cumulative Update 17')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 1000, N'RTM ', N'', CAST(N'2017-10-02' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3006, N'RTM CU1', N'https://support.microsoft.com/en-us/help/4038634', CAST(N'2017-10-24' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 1')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3008, N'RTM CU2', N'https://support.microsoft.com/en-us/help/4052574', CAST(N'2017-11-28' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 2')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3015, N'RTM CU3', N'https://support.microsoft.com/en-us/help/4052987', CAST(N'2018-01-04' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 3')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3022, N'RTM CU4', N'https://support.microsoft.com/en-us/help/4056498', CAST(N'2018-02-20' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 4')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3023, N'RTM CU5', N'https://support.microsoft.com/en-us/help/4092643', CAST(N'2018-03-20' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 5')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3025, N'RTM CU6', N'https://support.microsoft.com/en-us/help/4101464', CAST(N'2018-04-17' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 6')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3026, N'RTM CU7', N'https://support.microsoft.com/en-us/help/4229789', CAST(N'2018-05-23' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 7')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3029, N'RTM CU8', N'https://support.microsoft.com/en-us/help/4338363', CAST(N'2018-06-21' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 8')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3030, N'RTM CU9', N'https://support.microsoft.com/en-us/help/4515435', CAST(N'2018-07-18' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 9')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3037, N'RTM CU10', N'https://support.microsoft.com/en-us/help/4524334', CAST(N'2018-08-27' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3038, N'RTM CU11', N'https://support.microsoft.com/en-us/help/4462262', CAST(N'2018-09-20' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 11')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3045, N'RTM CU12', N'https://support.microsoft.com/en-us/help/4464082', CAST(N'2018-10-24' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 12')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3048, N'RTM CU13', N'https://support.microsoft.com/en-us/help/4466404', CAST(N'2018-12-18' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 13')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3076, N'RTM CU14', N'https://support.microsoft.com/en-us/help/4484710', CAST(N'2019-03-25' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 14')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3162, N'RTM CU15', N'https://support.microsoft.com/en-us/help/4498951', CAST(N'2019-05-24' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 15')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3223, N'RTM CU16', N'https://support.microsoft.com/en-us/help/4508218', CAST(N'2019-08-01' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 16')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3238, N'RTM CU17', N'https://support.microsoft.com/en-us/help/4515579', CAST(N'2019-10-08' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 17')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3257, N'RTM CU18', N'https://support.microsoft.com/en-us/help/4527377', CAST(N'2019-12-09' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 18')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3257, N'RTM CU19', N'https://support.microsoft.com/en-us/help/4535007', CAST(N'2020-02-05' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 19')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3294, N'RTM CU20', N'https://support.microsoft.com/en-us/help/4541283', CAST(N'2020-04-07' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 20')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3335, N'RTM CU21', N'https://support.microsoft.com/en-us/help/4557397', CAST(N'2020-07-01' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 21')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3356, N'RTM CU22', N'https://support.microsoft.com/en-us/help/4577467', CAST(N'2020-09-10' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 22')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3370, N'RTM CU22 GDR', N'https://support.microsoft.com/en-us/help/4583457', CAST(N'2021-01-12' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 22 GDR')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3381, N'RTM CU23', N'https://support.microsoft.com/en-us/help/5000685', CAST(N'2021-02-25' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 23')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3391, N'RTM CU24', N'https://support.microsoft.com/en-us/help/5001228', CAST(N'2021-05-10' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 24')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (14, 3410, N'RTM CU25', N'https://support.microsoft.com/en-us/help/5003830', CAST(N'2021-07-12' AS Date), CAST(N'2022-10-11' AS Date), CAST(N'2027-10-12' AS Date), N'SQL Server 2017', N'RTM Cumulative Update 25')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 2000, N'RTM ', N'', CAST(N'2019-11-04' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'RTM ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 2070, N'GDR', N'https://support.microsoft.com/en-us/help/4517790', CAST(N'2019-11-04' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'RTM GDR ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4003, N'CU1', N'https://support.microsoft.com/en-us/help/4527376', CAST(N'2020-01-07' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 1 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4013, N'CU2', N'https://support.microsoft.com/en-us/help/4536075', CAST(N'2020-02-13' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 2 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4023, N'CU3', N'https://support.microsoft.com/en-us/help/4538853', CAST(N'2020-03-12' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 3 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4033, N'CU4', N'https://support.microsoft.com/en-us/help/4548597', CAST(N'2020-03-31' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 4 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4043, N'CU5', N'https://support.microsoft.com/en-us/help/4548597', CAST(N'2020-06-22' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 5 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4053, N'CU6', N'https://support.microsoft.com/en-us/help/4563110', CAST(N'2020-08-04' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 6 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4063, N'CU7', N'https://support.microsoft.com/en-us/help/4570012', CAST(N'2020-09-02' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 7 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4073, N'CU8', N'https://support.microsoft.com/en-us/help/4577194', CAST(N'2020-10-01' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 8 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4073, N'CU8 GDR', N'https://support.microsoft.com/en-us/help/4583459', CAST(N'2021-01-12' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 8 GDR ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4102, N'CU9', N'https://support.microsoft.com/en-us/help/5000642', CAST(N'2021-02-11' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 9 ')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4123, N'CU10', N'https://support.microsoft.com/en-us/help/5001090', CAST(N'2021-04-06' AS Date), CAST(N'2025-01-07' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 10')
GO
INSERT [dbo].[SqlServerVersions] ([MajorVersionNumber], [MinorVersionNumber], [Branch], [Url], [ReleaseDate], [MainstreamSupportEndDate], [ExtendedSupportEndDate], [MajorVersionName], [MinorVersionName]) VALUES (15, 4138, N'CU11', N'https://support.microsoft.com/en-us/help/5003249', CAST(N'2021-06-10' AS Date), CAST(N'2025-01-01' AS Date), CAST(N'2030-01-08' AS Date), N'SQL Server 2019', N'Cumulative Update 11')
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (0)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (1)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (2)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (3)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (4)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (5)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (6)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (7)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (8)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (9)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (10)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (11)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (12)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (13)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (14)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (15)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (16)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (17)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (18)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (19)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (20)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (21)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (22)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (23)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (24)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (25)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (26)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (27)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (28)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (29)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (30)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (31)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (32)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (33)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (34)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (35)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (36)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (37)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (38)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (39)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (40)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (41)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (42)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (43)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (44)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (45)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (46)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (47)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (48)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (49)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (50)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (51)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (52)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (53)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (54)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (55)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (56)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (57)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (58)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (59)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (60)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (61)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (62)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (63)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (64)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (65)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (66)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (67)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (68)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (69)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (70)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (71)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (72)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (73)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (74)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (75)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (76)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (77)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (78)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (79)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (80)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (81)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (82)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (83)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (84)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (85)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (86)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (87)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (88)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (89)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (90)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (91)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (92)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (93)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (94)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (95)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (96)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (97)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (98)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (99)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (100)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (101)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (102)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (103)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (104)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (105)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (106)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (107)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (108)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (109)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (110)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (111)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (112)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (113)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (114)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (115)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (116)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (117)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (118)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (119)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (120)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (121)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (122)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (123)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (124)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (125)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (126)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (127)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (128)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (129)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (130)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (131)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (132)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (133)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (134)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (135)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (136)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (137)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (138)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (139)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (140)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (141)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (142)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (143)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (144)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (145)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (146)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (147)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (148)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (149)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (150)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (151)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (152)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (153)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (154)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (155)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (156)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (157)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (158)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (159)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (160)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (161)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (162)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (163)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (164)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (165)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (166)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (167)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (168)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (169)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (170)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (171)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (172)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (173)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (174)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (175)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (176)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (177)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (178)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (179)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (180)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (181)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (182)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (183)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (184)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (185)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (186)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (187)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (188)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (189)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (190)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (191)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (192)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (193)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (194)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (195)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (196)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (197)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (198)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (199)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (200)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (201)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (202)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (203)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (204)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (205)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (206)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (207)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (208)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (209)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (210)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (211)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (212)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (213)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (214)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (215)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (216)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (217)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (218)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (219)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (220)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (221)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (222)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (223)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (224)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (225)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (226)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (227)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (228)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (229)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (230)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (231)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (232)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (233)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (234)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (235)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (236)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (237)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (238)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (239)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (240)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (241)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (242)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (243)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (244)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (245)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (246)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (247)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (248)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (249)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (250)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (251)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (252)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (253)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (254)
GO
INSERT [dbo].[TinyNumbers] ([Number]) VALUES (255)
GO
