
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_WaitStats]
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
--Instance stats info
SELECT DISTINCT WaitType, COUNT(WaitType) AS count
FROM     [Inst].[WaitStats]
where ServerName =  @ServerName and (DateAdded >= @StartDate) AND (DateAdded <= @EndDate)
GROUP BY WaitType
END




