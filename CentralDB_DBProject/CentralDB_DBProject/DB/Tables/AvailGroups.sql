CREATE TABLE [DB].[AvailGroups] (
    [ServerName]       NVARCHAR (128) NULL,
    [InstanceName]     NVARCHAR (128) NULL,
    [AGName]           NVARCHAR (128) NULL,
    [PrimaryReplica]   NVARCHAR (128) NULL,
    [SyncHealth]       NVARCHAR (60)  NULL,
    [BackupPreference] NVARCHAR (60)  NULL,
    [Failoverlevel]    INT            NULL,
    [HealthChkTimeout] INT            NULL,
    [ListenerName]     NVARCHAR (128) NULL,
    [ListenerIP]       NVARCHAR (50)  NULL,
    [ListenerPort]     NVARCHAR (30)  NULL,
    [DateAdded]        SMALLDATETIME  NULL,
    [AGID]             INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_AGInfo]
    ON [DB].[AvailGroups]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [AGID] ASC) WITH (FILLFACTOR = 85);

