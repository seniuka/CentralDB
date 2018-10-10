-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_AGGroups]
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
from [CentralDB].[DB].[AvailGroups]
Group BY  ListenerName) x
Join [CentralDB].[DB].[AvailGroups] y ON x.Rundate = y.DateAdded and X.ListenerName = y.ListenerName) z
inner join(
select Distinct ServerName, InstanceName, Environment from  [CentralDB].[Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.item
Order by Z.PrimaryReplica
END


