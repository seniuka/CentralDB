
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SvrStats]
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
SELECT ServerName,  RunDate, PctProcTm, ProcQLen, AvDskRd, AvDskWt, AvDskQLen, AvailMB, PgFlUsg
FROM     Svr.SvrBaselineStats
where ServerName =  @ServerName and (RunDate >= @StartDate) AND (RunDate <= @EndDate)

END




