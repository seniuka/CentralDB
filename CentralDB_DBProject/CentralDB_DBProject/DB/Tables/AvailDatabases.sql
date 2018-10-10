CREATE TABLE [DB].[AvailDatabases] (
    [ServerName]     NVARCHAR (128) NULL,
    [InstanceName]   NVARCHAR (128) NULL,
    [AGDBName]       NVARCHAR (128) NULL,
    [AGName]         NVARCHAR (128) NULL,
    [PrimaryReplica] NVARCHAR (128) NULL,
    [SyncState]      NVARCHAR (60)  NULL,
    [SyncHealth]     NVARCHAR (60)  NULL,
    [DBState]        NVARCHAR (60)  NULL,
    [IsSuspended]    BIT            NULL,
    [SuspendReason]  NVARCHAR (60)  NULL,
    [AGDBCreateDate] SMALLDATETIME  NULL,
    [DateAdded]      SMALLDATETIME  NULL,
    [AGDBID]         INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_AGDBInfo]
    ON [DB].[AvailDatabases]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [AGDBID] ASC) WITH (FILLFACTOR = 85);

