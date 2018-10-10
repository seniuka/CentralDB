
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_SQLSvcs]
(
@servername varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--SQL Services info
select  y.DisplayName, Y.Started, Y.StartMode, Y.LogonAs, Y. ProcessId from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[SQLServices]
Group BY Servername) x
Join [Svr].[SQLServices] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName and y.ServerName =  @servername

END




