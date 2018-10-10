
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InstJobs]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Jobs info
    SELECT y.InstanceName, y.JobName, Y.IsEnabled, 
	CASE when Y.LastRunDate = '1/1/0001 12:00:00 AM' Then 'Never' else Y.LastRunDate End As LastRunDate, 
	y.LastRunOutcome, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [Inst].[Jobs]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [Inst].[Jobs] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END



