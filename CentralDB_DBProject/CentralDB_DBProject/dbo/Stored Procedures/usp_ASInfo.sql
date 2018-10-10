
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_ASInfo]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--AS Instance info
  SELECT y.ServerName, y.InstanceName, y.ASVersion, Y.ASPatchLevel, Y.ASEdition, Y.ASVersionNo, Y.NoOfDBs, Y.LastSchemaUpdate, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [AS].[SSASInfo]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [AS].[SSASInfo] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END




