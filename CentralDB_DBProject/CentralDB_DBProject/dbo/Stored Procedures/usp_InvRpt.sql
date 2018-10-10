-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_InvRpt]
(
@Environment Varchar(128),
@OSName varchar(128),
@SQLVersion varchar(128),
@ASVersion varchar(128),
@RSVersion varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Inventory Report View
SELECT z.ServerName, v.Environment, w.IPAddress, z.OSName, z.OSUpTime, z.OSTotalVisibleMemorySizeInGB AS OSMemGB, w.NumberOfProcessors, w.NumberOfCores, 
                  w.IsHyperThreaded, w.CurrentCPUSpeed, w.IsVM, w.IsClu, v.InstanceName, S.SQLVersion, S.SQLEdition, S.SQLPatchLevel, S.IsSPUpToDate, A.ASVersion, A.ASEdition, 
                  A.ASPatchLevel, R.RSVersion, R.RSEdition, v.Description
FROM     (SELECT y.ServerName, y.OSName, y.OSLastRestart, y.OSUpTime, y.OSTotalVisibleMemorySizeInGB
                  FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                     FROM      Svr.OSInfo
                                     GROUP BY ServerName) AS x INNER JOIN
                                    Svr.OSInfo AS y ON x.Rundate = y.DateAdded AND x.ServerName = y.ServerName) AS z INNER JOIN
                      (SELECT y.ServerName, y.IPAddress, y.NumberOfProcessors, y.NumberOfLogicalProcessors, y.NumberOfCores, y.IsHyperThreaded, y.CurrentCPUSpeed, y.IsVM, 
                                         y.IsClu
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      Svr.ServerInfo
                                          GROUP BY ServerName) AS x_4 INNER JOIN
                                         Svr.ServerInfo AS y ON x_4.Rundate = y.DateAdded AND x_4.ServerName = y.ServerName) AS w ON z.ServerName = w.ServerName INNER JOIN
                      (SELECT DISTINCT ServerName, InstanceName, Environment, Description
                       FROM      Svr.ServerList) AS v ON z.ServerName = v.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.SQLVersion, y.SQLPatchLevel, y.IsSPUpToDate, y.SQLEdition, y.SQLVersionNo
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      Inst.InstanceInfo
                                          GROUP BY ServerName) AS x_3 INNER JOIN
                                         Inst.InstanceInfo AS y ON x_3.Rundate = y.DateAdded AND x_3.ServerName = y.ServerName) AS S ON z.ServerName = S.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.ASVersion, y.ASPatchLevel, y.IsSPUpToDateOnAS, y.ASEdition, y.ASVersionNo
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      [AS].SSASInfo
                                          GROUP BY ServerName) AS x_2 INNER JOIN
                                         [AS].SSASInfo AS y ON x_2.Rundate = y.DateAdded AND x_2.ServerName = y.ServerName) AS A ON z.ServerName = A.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.RSVersion, y.RSEdition, y.RSVersionNo
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      RS.SSRSInfo
                                          GROUP BY ServerName) AS x_1 INNER JOIN
                                         RS.SSRSInfo AS y ON x_1.Rundate = y.DateAdded AND x_1.ServerName = y.ServerName) AS R ON z.ServerName = R.ServerName
Where V.Environment = @Environment and Z.OSName= @OSName and S.SQLVersion = @SQLVersion and A.ASVersion = @ASVersion and R.RsVersion= @RSVersion
END



