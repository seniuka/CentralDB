-- =============================================================================
-- Current-State Views
-- =============================================================================
-- Purpose : Each view returns the most recent collection row per natural key,
--           giving a clean point-in-time snapshot without touching history.
-- Pattern : JOIN back on MAX(IdentityID) per grouping key — reliable because
--           identity values always increase with each collection run.
-- Naming  : vwGet<TableName>Current, schema-qualified to match source table.
-- =============================================================================

-- =====================================================================
-- Schema: Svr
-- =====================================================================

CREATE VIEW [Svr].[vwGetOSInfoCurrent]
AS
SELECT y.*
FROM [Svr].[OSInfo] y
INNER JOIN (
    SELECT MAX(OSInfoID) AS OSInfoID, ServerName
    FROM [Svr].[OSInfo]
    GROUP BY ServerName
) x ON x.OSInfoID = y.OSInfoID;
GO

CREATE VIEW [Svr].[vwGetServerInfoCurrent]
AS
SELECT y.*
FROM [Svr].[ServerInfo] y
INNER JOIN (
    SELECT MAX(ServerInfoID) AS ServerInfoID, ServerName
    FROM [Svr].[ServerInfo]
    GROUP BY ServerName
) x ON x.ServerInfoID = y.ServerInfoID;
GO

CREATE VIEW [Svr].[vwGetOSPatchInfoCurrent]
AS
SELECT y.*
FROM [Svr].[OSPatchInfo] y
INNER JOIN (
    SELECT MAX(OSPatchInfoID) AS OSPatchInfoID, ServerName, HotFixID
    FROM [Svr].[OSPatchInfo]
    GROUP BY ServerName, HotFixID
) x ON x.OSPatchInfoID = y.OSPatchInfoID;
GO

CREATE VIEW [Svr].[vwGetPgFileUsageCurrent]
AS
SELECT y.*
FROM [Svr].[PgFileUsage] y
INNER JOIN (
    SELECT MAX(PgFileUsageID) AS PgFileUsageID, ServerName, Name
    FROM [Svr].[PgFileUsage]
    GROUP BY ServerName, Name
) x ON x.PgFileUsageID = y.PgFileUsageID;
GO

CREATE VIEW [Svr].[vwGetDiskInfoCurrent]
AS
SELECT y.*
FROM [Svr].[DiskInfo] y
INNER JOIN (
    SELECT MAX(DiskInfoID) AS DiskInfoID, ServerName, Name
    FROM [Svr].[DiskInfo]
    GROUP BY ServerName, Name
) x ON x.DiskInfoID = y.DiskInfoID;
GO

CREATE VIEW [Svr].[vwGetSQLServicesCurrent]
AS
SELECT y.*
FROM [Svr].[SQLServices] y
INNER JOIN (
    SELECT MAX(SQLServicesID) AS SQLServicesID, ServerName, ServiceName
    FROM [Svr].[SQLServices]
    GROUP BY ServerName, ServiceName
) x ON x.SQLServicesID = y.SQLServicesID;
GO

-- =====================================================================
-- Schema: Inst
-- =====================================================================

CREATE VIEW [Inst].[vwGetBuildComplianceCurrent]
AS
SELECT y.*
FROM [Inst].[BuildCompliance] y
INNER JOIN (
    SELECT MAX(BuildComplianceID) AS BuildComplianceID, InstanceName
    FROM [Inst].[BuildCompliance]
    GROUP BY InstanceName
) x ON x.BuildComplianceID = y.BuildComplianceID;
GO

CREATE VIEW [Inst].[vwGetInstanceInfoCurrent]
AS
SELECT y.*
FROM [Inst].[InstanceInfo] y
INNER JOIN (
    SELECT MAX(InstanceInfoID) AS InstanceInfoID, InstanceName
    FROM [Inst].[InstanceInfo]
    GROUP BY InstanceName
) x ON x.InstanceInfoID = y.InstanceInfoID;
GO

CREATE VIEW [Inst].[vwGetLoginsCurrent]
AS
SELECT y.*
FROM [Inst].[Logins] y
INNER JOIN (
    SELECT MAX(LoginsID) AS LoginsID, InstanceName, Name
    FROM [Inst].[Logins]
    GROUP BY InstanceName, Name
) x ON x.LoginsID = y.LoginsID;
GO

CREATE VIEW [Inst].[vwGetInstanceRolesCurrent]
AS
SELECT y.*
FROM [Inst].[InstanceRoles] y
INNER JOIN (
    SELECT MAX(InstanceRolesID) AS InstanceRolesID, InstanceName, Role, Name
    FROM [Inst].[InstanceRoles]
    GROUP BY InstanceName, Role, Name
) x ON x.InstanceRolesID = y.InstanceRolesID;
GO

CREATE VIEW [Inst].[vwGetLinkedServersCurrent]
AS
SELECT y.*
FROM [Inst].[LinkedServers] y
INNER JOIN (
    SELECT MAX(LinkedServersID) AS LinkedServersID, InstanceName, Name
    FROM [Inst].[LinkedServers]
    GROUP BY InstanceName, Name
) x ON x.LinkedServersID = y.LinkedServersID;
GO

CREATE VIEW [Inst].[vwGetJobsCurrent]
AS
SELECT y.*
FROM [Inst].[Jobs] y
INNER JOIN (
    SELECT MAX(JobsID) AS JobsID, InstanceName, Name
    FROM [Inst].[Jobs]
    GROUP BY InstanceName, Name
) x ON x.JobsID = y.JobsID;
GO

CREATE VIEW [Inst].[vwGetJobsFailedCurrent]
AS
SELECT y.*
FROM [Inst].[JobsFailed] y
INNER JOIN (
    SELECT MAX(JobsFailedID) AS JobsFailedID, InstanceName, Name
    FROM [Inst].[JobsFailed]
    GROUP BY InstanceName, Name
) x ON x.JobsFailedID = y.JobsFailedID;
GO

CREATE VIEW [Inst].[vwGetSpConfigureCurrent]
AS
SELECT y.*
FROM [Inst].[SpConfigure] y
INNER JOIN (
    SELECT MAX(SpConfigureID) AS SpConfigureID, ServerName, ConfigName
    FROM [Inst].[SpConfigure]
    GROUP BY ServerName, ConfigName
) x ON x.SpConfigureID = y.SpConfigureID;
GO

CREATE VIEW [Inst].[vwGetInstanceTriggersCurrent]
AS
SELECT y.*
FROM [Inst].[InstanceTriggers] y
INNER JOIN (
    SELECT MAX(InstanceTriggersID) AS InstanceTriggersID, InstanceName, Name
    FROM [Inst].[InstanceTriggers]
    GROUP BY InstanceName, Name
) x ON x.InstanceTriggersID = y.InstanceTriggersID;
GO
