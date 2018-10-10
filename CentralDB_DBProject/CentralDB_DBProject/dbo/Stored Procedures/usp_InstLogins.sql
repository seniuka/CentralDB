
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_InstLogins]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Logins info
SELECT y.InstanceName, y.LoginName, y.LoginType, y.LoginCreateDate, y.LoginLastModified, y.IsDisabled, y.IsLocked, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      Inst.Logins
                  GROUP BY InstanceName) AS x INNER JOIN
                  Inst.Logins AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END




