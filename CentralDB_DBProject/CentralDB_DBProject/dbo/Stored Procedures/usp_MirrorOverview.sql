-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_MirrorOverview]
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
select Distinct ServerName, InstanceName, Environment from  [CentralDB].[Svr].[ServerList]) v ON Z.InstanceName = V.InstanceName and z.[IsMirroringEnabled] = 'True'
inner join #Environ_List as EnvironList on v.Environment = EnvironList.item
Order by Z.InstanceName
END


