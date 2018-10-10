-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ReplOverview]
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
from [CentralDB].[Inst].[Replication]
Group BY InstanceName) x
Join [CentralDB].[Inst].[Replication] y ON x.Rundate = y.DateAdded and X.InstanceName = y.InstanceName) z
inner join(
select Distinct ServerName, InstanceName, Environment from  [CentralDB].[Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.item
Order by Z.Publisher
END


