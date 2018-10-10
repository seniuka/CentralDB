
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ASDBInfo]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--AS DB info
SELECT y.ServerName, y.InstanceName, y.DBName, y.DBSizeInMB, y.Collation, y.CompatibilityLevel, y.DBCreateDate, 
 CASE WHEN  y.DBLastProcessed = '12/30/1699 4:00:00 PM' Then 'Never'ELSE y.DBLastProcessed End as DBLastProcessed, 
y.DBLastUpdated, y.DBStorageLocation, y.NoOfCubes, y.NoOfDimensions, y.ReadWriteMode, y.StorgageEngineUsed, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [AS].SSASDBInfo
                  GROUP BY InstanceName) AS x INNER JOIN
                  [AS].SSASDBInfo AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END




