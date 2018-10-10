
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InstLoginRoles]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Login Roles info
SELECT y.InstanceName, y.LoginName, Y.RoleName, Y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [Inst].[InstanceRoles]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [Inst].[InstanceRoles] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName =  @InstanceName

END




