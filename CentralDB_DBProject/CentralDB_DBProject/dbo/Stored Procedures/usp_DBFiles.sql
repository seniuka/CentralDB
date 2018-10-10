
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DBFiles]
(
@InstanceName varchar(128),
@DBName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--DB Files Info
SELECT Y.LogicalName, Y.PhysicalName, (SUBSTRING(REVERSE(Y.PhysicalName), 1, CHARINDEX('.', REVERSE(Y.PhysicalName)) - 1)) AS [File Type],
		y.SizeInMB, y.GrowthPct, y.GrowthInMB
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [DB].[DatabaseFiles]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [DB].[DatabaseFiles] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName  AND y.InstanceName = @InstanceName And  y.DBName = @DBName
END




