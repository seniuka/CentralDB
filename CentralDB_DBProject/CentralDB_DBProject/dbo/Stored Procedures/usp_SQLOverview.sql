-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SQLOverview]
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
from [CentralDB].[Inst].[InstanceInfo]
Group BY InstanceName) x
Join [CentralDB].[Inst].[InstanceInfo] y ON x.Rundate = y.DateAdded and X.InstanceName = y.InstanceName) z
inner join(
select Distinct ServerName, InstanceName, Environment, Description, BusinessOwner from  [CentralDB].[Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.item
inner join #SQL_Name_List as SQLList on Z.SQLVersion = SQLList.item
Order by InstanceName
END


