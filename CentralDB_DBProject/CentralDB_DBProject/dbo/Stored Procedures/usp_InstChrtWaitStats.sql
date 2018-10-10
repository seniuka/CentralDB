
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InstChrtWaitStats]
(
@InstanceName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Instance Wait Stats info
SELECT DISTINCT WaitType, COUNT(WaitType) AS count
FROM     [Inst].[WaitStats]
WHERE  (InstanceName = @InstanceName) --and (DateAdded > GETDATE() - 30) 
GROUP BY WaitType
ORDER BY count DESC
END




