-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_AGDatabases]
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

Select z.[AGDBName], z.[AGName], z.[PrimaryReplica], z.[AGDBCreateDate], z.[DateAdded], v.Environment from [CentralDB].[DB].[AvailDatabases]  z
inner join(
select Distinct ServerName, InstanceName, Environment from  [CentralDB].[Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName
inner join #Environ_List as EnvironList on v.Environment = EnvironList.item
WHERE DateAdded >= CAST(GETDATE() AS DATE)
Order by Z.PrimaryReplica
END


