
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InstMIIdx]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Missing Indexes info
    SELECT  y.InstanceName, Y.create_index_statement,y.improvement_measure, y.unique_compiles, y.user_seeks, y.avg_total_user_cost, y.avg_user_impact, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [Inst].[MissingIndexes]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [Inst].[MissingIndexes] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName


END




