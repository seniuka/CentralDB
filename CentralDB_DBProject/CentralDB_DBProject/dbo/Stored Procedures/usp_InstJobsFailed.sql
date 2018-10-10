
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_InstJobsFailed]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--Instance Failed Jobs info
    SELECT y.[InstanceName], y.[JobName], y.[StepID], y.[StepName], y.[ErrMsg], y.[JobRunDate], y.[DateAdded]
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM     [CentralDB].[Inst].[JobsFailed]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [CentralDB].[Inst].[JobsFailed] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END



