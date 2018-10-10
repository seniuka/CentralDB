
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InstDBInfo]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance info
SELECT y.InstanceName, y.DBName, y.RecoveryModel, y.DBSizeInMB, 
CASE when y.LastBackupDate = '1/1/0001 12:00:00 AM' Then 'No Backup Taken Yet' else y.LastBackupDate End As FullBackup
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [DB].[DatabaseInfo]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [DB].[DatabaseInfo] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName

END




