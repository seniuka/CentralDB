

create view [Svr].[vwSvrInfo]
as
SELECT CASE WHEN Y.IsVM = 1 THEN 'Virtual' ELSE 'Physical' END AS BoxType, CASE WHEN Y.IsClu = 1 THEN 'Clustered' ELSE 'StandAlone' END AS ServerType
FROM     (SELECT ServerName, MAX(DateAdded) AS Rundate
                  FROM      Svr.ServerInfo
                  GROUP BY ServerName) AS x INNER JOIN
                  Svr.ServerInfo AS y ON x.Rundate = y.DateAdded AND x.ServerName = y.ServerName

