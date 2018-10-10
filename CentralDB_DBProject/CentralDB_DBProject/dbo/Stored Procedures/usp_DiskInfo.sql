
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_DiskInfo]
(
@servername varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Disk Management info
select  y.DiskName, Y.DskClusterSizeInKB, y.DskTotalSizeInGB, y.[DskFreeSpaceInGB], y.[DskUsedSpaceInGB], y.[DskPctFreeSpace]  from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[DiskInfo]
Group BY Servername) x
Join [Svr].[DiskInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName and y.ServerName =  @servername

END




