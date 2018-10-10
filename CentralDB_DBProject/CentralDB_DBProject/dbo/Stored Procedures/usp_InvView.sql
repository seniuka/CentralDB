-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InvView]
(
@Environment Varchar(128),
@Domain Varchar(128),
@OSName varchar(128),
@ISVM Varchar(128),
@ISClu Varchar(128),
@ISSQLClu Varchar(128),
@SQLVersion varchar(128),
@SQLEdition varchar(128),
@ISSPUpDt varchar(128)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--Parsing values into table
Select Item
into #Environ_List
From
dbo.DelimitedSplit8K(@Environment,',')

Select Item
into #Domain_List
From
dbo.DelimitedSplit8K(@Domain,',')

SELECT Item
INTO #OS_Name_List 
FROM
dbo.DelimitedSplit8K(@OSName,',')

SELECT Item
INTO #IS_VM_List 
FROM
dbo.DelimitedSplit8K(@ISVM,',')

SELECT Item
INTO #IS_Clu_List 
FROM
dbo.DelimitedSplit8K(@ISClu,',')

SELECT Item
INTO #IS_SQLClu_List 
FROM
dbo.DelimitedSplit8K(@ISSQLClu,',')

Select Item
into #SQL_Name_List
From
dbo.DelimitedSplit8K(@SQLVersion,',')

Select Item
into #SQL_Edition_List
From
dbo.DelimitedSplit8K(@SQLEdition,',')

SELECT Item
INTO #IS_SPUpDt_List 
FROM
dbo.DelimitedSplit8K(@ISSPUpDt,',')

--Inventory Report View
SELECT Distinct z.ServerName, v.Environment, w.Domain, w.IPAddress,  z.OSName, z.OSLastRestart, z.OSTotalVisibleMemorySizeInGB AS OSMemGB, w.NumberOfProcessors, w.NumberOfCores, 
                  w.IsHyperThreaded, w.CurrentCPUSpeed, w.IsVM, w.IsClu, v.InstanceName, S.SQLVersion, S.SQLEdition, 
				  S.SQLPatchLevel, S.IsSPUpToDate, s.IsClustered, A.[ASVersion], A.[ASEdition], A.ASPatchLevel, R.[RSVersion], R.[RSEdition], v.BusinessOwner, v.Description, V.Baseline, V.SQLPing
FROM     (SELECT y.ServerName, y.OSName, y.OSLastRestart, y.OSUpTime, y.OSTotalVisibleMemorySizeInGB
                  FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                     FROM      Svr.OSInfo
                                     GROUP BY ServerName) AS x INNER JOIN
                                    Svr.OSInfo AS y ON x.Rundate = y.DateAdded AND x.ServerName = y.ServerName) AS z INNER JOIN
                      (SELECT y.ServerName, y.Domain, y.IPAddress, y.NumberOfProcessors, y.NumberOfLogicalProcessors, y.NumberOfCores, y.IsHyperThreaded, y.CurrentCPUSpeed, y.IsVM, 
                                         y.IsClu
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      Svr.ServerInfo
                                          GROUP BY ServerName) AS x_4 INNER JOIN
                                         Svr.ServerInfo AS y ON x_4.Rundate = y.DateAdded AND x_4.ServerName = y.ServerName) AS w ON z.ServerName = w.ServerName INNER JOIN
                      (SELECT DISTINCT ServerName, InstanceName, Environment, Description, BusinessOwner, Baseline, SQLPing
                       FROM      Svr.ServerList) AS v ON z.ServerName = v.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.SQLVersion, y.SQLPatchLevel, y.IsSPUpToDate, y.SQLEdition, y.SQLVersionNo, Y.IsClustered
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      Inst.InstanceInfo
                                          GROUP BY ServerName) AS x_3 INNER JOIN
                                         Inst.InstanceInfo AS y ON x_3.Rundate = y.DateAdded AND x_3.ServerName = y.ServerName) AS S ON z.ServerName = S.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.ASVersion, y.ASPatchLevel, y.IsSPUpToDateOnAS, y.ASEdition, y.ASVersionNo
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      [AS].SSASInfo
                                          GROUP BY ServerName) AS x_2 INNER JOIN
                                         [AS].SSASInfo AS y ON x_2.Rundate = y.DateAdded AND x_2.ServerName = y.ServerName) AS A ON z.ServerName = A.ServerName LEFT OUTER JOIN
                      (SELECT y.ServerName, y.RSVersion, y.RSEdition, y.RSVersionNo
                       FROM      (SELECT ServerName, MAX(DateAdded) AS Rundate
                                          FROM      RS.SSRSInfo
                                          GROUP BY ServerName) AS x_1 INNER JOIN
                                         RS.SSRSInfo AS y ON x_1.Rundate = y.DateAdded AND x_1.ServerName = y.ServerName) AS R ON z.ServerName = R.ServerName
			inner join #Environ_List as EnvironList on v.Environment = EnvironList.item
			inner join #Domain_List as DomainList on W.Domain = DomainList.item
			inner join #OS_Name_List as OSList on z.OSName = OSList.item
			inner join #IS_VM_List as ISVMList on W.ISVM = ISVMList.item
			inner join #IS_Clu_List as ISCluList on W.ISClu = ISCluList.item
			inner join #IS_SQLClu_List as ISSQLCluList on S.ISClustered = ISSQLCluList.item
			inner join #SQL_Name_List as SQLList on s.SQLVersion = SQLList.item
			inner join #SQL_Edition_List as SQLEditionList on s.SQLEdition = SQLEditionList.item  
			inner join #IS_SPUpDt_List as ISSPUpDtList on S.IsSPUpToDate = ISSPUpDtList.item

Order by z.Servername

END


