
CREATE VIEW vwInstanceLoginAndRoleList
AS
SELECT DISTINCT
	 ir.InstanceName
	,ir.RoleName
	,l.LoginName
	,l.LoginType
	,isnull(l.IsLocked, 0) IsLocked
	,l.IsDisabled
	,sl.Environment
FROM inst.InstanceRoles ir
INNER JOIN inst.Logins l ON l.LoginName = ir.LoginName and l.InstanceName = ir.InstanceName and l.DateAdded = ir.DateAdded
INNER JOIN svr.ServerList sl on sl.InstanceName = ir.InstanceName
WHERE 
 ir.DateAdded in (SELECT DISTINCT MaxDateAdded FROM (SELECT MAX(ir.DateAdded) MaxDateAdded, ir.LoginName FROM inst.InstanceRoles ir GROUP BY ir.LoginName) x)
