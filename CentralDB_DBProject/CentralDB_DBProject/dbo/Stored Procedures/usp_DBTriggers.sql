
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_DBTriggers]
(
@InstanceName varchar(128),
@DBName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--DB Trigger info
SELECT y.InstanceName, y.TriggerName, y.CreateDate, y.LastModified, y.IsEnabled, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [DB].[Triggers]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [DB].[Triggers] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName And  y.DBName = @DBName
END




