-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_HekatonOverview]
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
from [CentralDB].[Tbl].[HekatonTbls]
Group BY InstanceName) x
Join [CentralDB].[Tbl].[HekatonTbls] y ON x.Rundate = y.DateAdded and X.InstanceName = y.InstanceName) z
inner join(
select Distinct ServerName, InstanceName, Environment from  [CentralDB].[Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName and z.[IsMemoryOptimized] = 'True'
inner join #Environ_List as EnvironList on v.Environment = EnvironList.item
Order by Z.InstanceName
END


