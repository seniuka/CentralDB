-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SysView]
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
from [CentralDB].[Svr].[OSInfo]
Group BY Servername) x
Join [CentralDB].[Svr].[OSInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName) z
inner join (
select  y.* from(
select ServerName, Max(DateAdded) as Rundate 
from [CentralDB].[Svr].[ServerInfo]
Group BY Servername) x
Join [CentralDB].[Svr].[ServerInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName)w ON Z.ServerName = W.ServerName and z.ServerName = @servername
--inner join(
--select Distinct ServerName, InstanceName, Environment, Description, BusinessOwner from  [CentralDB].[Svr].[ServerList]) v ON Z.ServerName = V.ServerName
END



