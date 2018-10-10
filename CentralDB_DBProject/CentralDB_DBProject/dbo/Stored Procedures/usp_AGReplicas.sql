
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_AGReplicas]
(
@ReplicaName varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--Instance Failed Jobs info
    SELECT  y.[InstanceName],y.[ReplicaName],y.[AGName], y.[Role],y.[FailoverMode], y.[AGCreateDate], y.[DateAdded]
FROM     (SELECT InstanceName, MAX(DateAdded) AS Rundate
                  FROM     [CentralDB].[DB].[AvailReplicas]
                  GROUP BY InstanceName) AS x INNER JOIN
                  [CentralDB].[DB].[AvailReplicas] AS y ON x.Rundate = y.DateAdded AND x.InstanceName = y.InstanceName AND y.ReplicaName = @ReplicaName
Order By ReplicaName
END



