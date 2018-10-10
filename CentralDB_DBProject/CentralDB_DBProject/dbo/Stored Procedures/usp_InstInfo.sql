
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InstInfo]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance info
SELECT y.ServerName, y.InstanceName, y.IPAddress, y.Port, y.SQLVersion, y.SQLPatchLevel, y.SQLEdition, y.SQLVersionNo, y.Collation, y.RootDirectory, 
                  y.DefaultDataPath, y.DefaultLogPath, y.ErrorLogPath, y.IsClustered,  y.IsSingleUser, y.IsAlwaysOnEnabled, y.TCPEnabled, 
                  y.NamedPipesEnabled, y.AlwaysOnStatus, y.MaxMemInMB, y.MinMemInMB, y.MaxDOP, y.NoOfUsrDBs, y.NoOfJobs, y.NoOfLnkSvrs, y.NoOfLogins, 
				  y.NoOfTriggers, y.NoOfAvailGrps, y.[AvailGrps], y.[IsXTPSupported], y.[FilFactor],  y.[ActiveNode], y.[ClusterNodeNames], y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      Inst.InstanceInfo
                  GROUP BY InstanceName) AS x INNER JOIN
                  Inst.InstanceInfo AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName

END



