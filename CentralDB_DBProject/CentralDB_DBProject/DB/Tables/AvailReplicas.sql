CREATE TABLE [DB].[AvailReplicas] (
    [ServerName]               NVARCHAR (128) NULL,
    [InstanceName]             NVARCHAR (128) NULL,
    [ReplicaName]              NVARCHAR (128) NULL,
    [AGName]                   NVARCHAR (128) NULL,
    [Role]                     NVARCHAR (60)  NULL,
    [AvailabilityMode]         NVARCHAR (60)  NULL,
    [FailoverMode]             NVARCHAR (60)  NULL,
    [SessionTimeout]           INT            NULL,
    [ConnectionsInPrimaryRole] NVARCHAR (60)  NULL,
    [ReadableSecondary]        NVARCHAR (60)  NULL,
    [EndpointUrl]              NVARCHAR (128) NULL,
    [BackupPriority]           INT            NULL,
    [AGCreateDate]             SMALLDATETIME  NULL,
    [AGModifyDate]             SMALLDATETIME  NULL,
    [DateAdded]                SMALLDATETIME  NULL,
    [AGRPID]                   INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_AGReplInfo]
    ON [DB].[AvailReplicas]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [AGRPID] ASC) WITH (FILLFACTOR = 85);

