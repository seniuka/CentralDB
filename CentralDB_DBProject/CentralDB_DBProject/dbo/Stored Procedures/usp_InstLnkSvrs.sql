
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_InstLnkSvrs]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Linked Servers info
SELECT y.InstanceName, y.LinkedServerName,Y.ProviderName, Y.ProductName, Y.DateLastModified, Y.DataAccess, y.DateAdded
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM      [Inst].[LinkedServers]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [Inst].[LinkedServers] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.InstanceName = @InstanceName
END




