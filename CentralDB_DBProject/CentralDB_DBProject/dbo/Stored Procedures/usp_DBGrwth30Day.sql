
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DBGrwth30Day]
(
@InstanceName varchar(128),
@DBName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Database growth for past 30 days info
SELECT [DataFileInMB] + [LogFileInMB] as DBGrowth, DateAdded --CONVERT(char(10), DateAdded, 101) as DateAdded
  FROM [CentralDB].[DB].[DBFileGrowth] where InstanceName = @InstanceName And DBName= @DBName and DateAdded > getdate()-30
END




