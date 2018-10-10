
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DBGrwth]
(
@InstanceName varchar(128),
@DBName varchar(128),
@StartDate DateTime,
@EndDate DateTime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- in@InstanceNameterfering with SELECT statements.
	SET NOCOUNT ON;
--Database growth info
SELECT       InstanceName, [DBName],[DataFileInMB],[LogFileInMB], [DataFileInMB] + [LogFileInMB] as DBGrowth, DateAdded-- CONVERT(char(10), DateAdded, 101) as DateAdded
  FROM [CentralDB].[DB].[DBFileGrowth] where InstanceName = @InstanceName And DBName= @DBName and (DateAdded >= @StartDate) AND (DateAdded <= @EndDate)
END




