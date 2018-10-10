-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SvrOverview]
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
from [CentralDB].[Svr].[OSInfo]
Group BY Servername) x
Join [CentralDB].[Svr].[OSInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName) z

inner join (SELECT DISTINCT ServerName, InstanceName, Environment, Description, BusinessOwner, Baseline, SQLPing
                       FROM      Svr.ServerList) AS v ON z.ServerName = v.ServerName
inner join (
select  y.* from(
select ServerName, Max(DateAdded) as Rundate 
from [CentralDB].[Svr].[ServerInfo]
Group BY Servername) x
Join [CentralDB].[Svr].[ServerInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName)w ON Z.ServerName = W.ServerName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.item
inner join #OS_Name_List as OSList on z.OSName = OSList.item
Order by z.Servername

--inner join(
--select Distinct ServerName, InstanceName, Environment, Description, BusinessOwner from  [CentralDB].[Svr].[ServerList]) v ON Z.ServerName = V.ServerName
END


