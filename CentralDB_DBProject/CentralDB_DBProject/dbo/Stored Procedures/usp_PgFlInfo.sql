
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_PgFlInfo]
(
@servername varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Page File info
select  Y.PgFileLocation, y.PgAllocBaseSzInGB, y.pgcurrUsageInGB, Y.pgpeakusageInGB from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[PgFileUsage]
Group BY Servername) x
Join [Svr].[PgFileUsage] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName and y.ServerName = @servername

END




