
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_InstWaitStats]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Wait Stats info
SELECT y.InstanceName,y.WaitType, y.WaitCount, Y.Percentage,Y.AvgWait_S, Y.AvgRes_S, AvgSig_S, Y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [Inst].[WaitStats]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [Inst].[WaitStats] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END




