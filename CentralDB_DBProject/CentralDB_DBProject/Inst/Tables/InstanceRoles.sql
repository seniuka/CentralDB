CREATE TABLE [Inst].[InstanceRoles] (
    [ServerName]   NVARCHAR (128) NULL,
    [InstanceName] NVARCHAR (128) NULL,
    [LoginName]    NVARCHAR (128) NULL,
    [RoleName]     NVARCHAR (128) NULL,
    [DateAdded]    SMALLDATETIME  NULL,
    [InstRID]      INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_InstanceRoles]
    ON [Inst].[InstanceRoles]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [InstRID] ASC) WITH (FILLFACTOR = 85);

