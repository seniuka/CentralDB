
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DBInfo]
(
@InstanceName varchar(128),
@DBName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance info
SELECT y.InstanceName, y.DBName, y.DBStatus, y.DBOwner, y.DBCreateDate, y.DBSizeInMB, y.DBSpaceAvailableInMB, y.DBUsedSpaceInMB, y.DBPctFreeSpace, 
                  y.DBDataSpaceUsageInMB, y.DBIndexSpaceUsageInMB, y.Collation, y.RecoveryModel, y.CompatibilityLevel,  
				  y.AutoShrink, y.AutoUpdateStatisticsEnabled, y.IsReadCommittedSnapshotOn, y.IsFullTextEnabled, y.BrokerEnabled, 
                  y.ReadOnly, y.IsDatabaseSnapshot,  y.IsMirroringEnabled, y.MirroringPartnerInstance, y.MirroringStatus, y.[HasFileInCloud],
                  y.MirroringSafetyLevel, y.ReplicationOptions, y.AvailabilityGroupName, y.NoOfTbls, y.NoOfViews, y.NoOfStoredProcs, y.NoOfUDFs, y.NoOfLogFiles, y.NoOfFileGroups, 
                  y.NoOfUsers, y.NoOfDBTriggers, y.DateAdded, y.[AutoClose],y.[HasMemoryOptimizedObjects], y.[MemoryAllocatedToMemoryOptimizedObjectsInKB], y.[MemoryUsedByMemoryOptimizedObjectsInKB], 
                  CASE WHEN y.LastBackupDate = '1/1/0001 12:00:00 AM' THEN 'No Full Backup Taken Yet' ELSE y.LastBackupDate END AS FullBackup, 
				  CASE WHEN y.LastDifferentialBackupDate = '1/1/0001 12:00:00 AM' THEN 'No Diff Backup Taken Yet' ELSE y.LastDifferentialBackupDate END AS DiffBackup, 
				  CASE WHEN y.LastLogBackupDate = '1/1/0001 12:00:00 AM' THEN 'No Log Backup Taken Yet' ELSE y.LastLogBackupDate END AS LogBackup ,
				  CASE WHEN y.LastGoodDBCCCheckDB = '1900-01-01 00:00:00.000' THEN 'DBCC Not Run Yet' ELSE y.LastGoodDBCCCheckDB END AS LastGoodDBCCCheckDB 
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      DB.DatabaseInfo
                  GROUP BY InstanceName) AS x INNER JOIN
                  DB.DatabaseInfo AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName And  y.DBName = @DBName
END


      
