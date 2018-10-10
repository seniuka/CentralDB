-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DelData]
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



