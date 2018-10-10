-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DelDecomSvrData]
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

