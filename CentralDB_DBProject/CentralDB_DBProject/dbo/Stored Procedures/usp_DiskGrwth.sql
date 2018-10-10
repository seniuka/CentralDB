
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DiskGrwth]
(
@ServerName varchar(128),
@StartDate DateTime,
@EndDate DateTime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Disk Growth info
select  ServerName, DiskName, DskTotalSizeInGB as TotalSizeInGB, [DskUsedSpaceInGB] as UsedSpaceInGB, DateAdded from [Svr].[DiskInfo] 
where ServerName =  @ServerName and (DateAdded >= @StartDate) AND (DateAdded <= @EndDate)

END




