
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_TblPerms]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Table level permissions info
SELECT y.[InstanceName], y.[DBName], y.[UserName], y.[ObjName], y.[PermName], y.[PermState], y.[DateAdded]
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [CentralDB].[Tbl].[TblPermissions]
                  GROUP BY InstanceName) AS x INNER JOIN
                 [CentralDB].[Tbl].[TblPermissions] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName =  @InstanceName

END



