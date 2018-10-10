
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InstStats]
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
SELECT ServerName, RunDate, FwdRecSec, FlScansSec, IdxSrchsSec, PgSpltSec, FreeLstStallsSec, LzyWrtsSec, PgLifeExp, PgRdSec, PgWtSec, LogGrwths, TranSec, 
                  BlkProcs, UsrConns, LatchWtsSec, LckWtTime, LckWtsSec, DeadLockSec, MemGrnts, BatReqSec, SQLCompSec, SQLReCompSec
FROM     Inst.InsBaselineStats 
where ServerName =  @ServerName and (RunDate >= @StartDate) AND (RunDate <= @EndDate)

END


