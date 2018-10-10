


create view [Svr].[vwOSName]
as
select  y.OSName from(
select ServerName, Max(DateAdded) as Rundate 
from [Svr].[OSInfo]
Group BY Servername) x
Join [Svr].[OSInfo] y ON x.Rundate = y.DateAdded and X.ServerName = y.ServerName

