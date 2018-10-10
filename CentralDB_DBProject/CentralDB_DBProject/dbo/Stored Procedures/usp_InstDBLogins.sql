
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_InstDBLogins]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance DB Login Roles info
SELECT y.DBName, Y.DBUser, Y.DBRole
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [DB].[DBUserRoles]
                  GROUP BY InstanceName) AS x INNER JOIN
                 [DB].[DBUserRoles] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName =  @InstanceName

END




