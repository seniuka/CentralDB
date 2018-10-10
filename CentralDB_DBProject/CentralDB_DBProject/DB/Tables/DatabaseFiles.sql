CREATE TABLE [DB].[DatabaseFiles] (
    [ServerName]   NVARCHAR (128) NULL,
    [InstanceName] NVARCHAR (128) NULL,
    [DBName]       NVARCHAR (128) NOT NULL,
    [FileID]       INT            NULL,
    [TypeDesc]     NVARCHAR (60)  NULL,
    [LogicalName]  NVARCHAR (128) NULL,
    [PhysicalName] NVARCHAR (260) NULL,
    [SizeInMB]     INT            NULL,
    [GrowthPct]    INT            NULL,
    [GrowthInMB]   INT            NULL,
    [DateAdded]    SMALLDATETIME  NULL,
    [DBFlID]       INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_DatabaseFiles]
    ON [DB].[DatabaseFiles]([ServerName] ASC, [InstanceName] ASC, [DBName] ASC, [DateAdded] ASC, [DBFlID] ASC) WITH (FILLFACTOR = 85);

