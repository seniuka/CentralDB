CREATE TABLE [DB].[Triggers] (
    [ServerName]   NVARCHAR (128) NULL,
    [InstanceName] NVARCHAR (128) NULL,
    [DBName]       NVARCHAR (128) NULL,
    [TriggerName]  NVARCHAR (128) NULL,
    [CreateDate]   NVARCHAR (30)  NULL,
    [LastModified] NVARCHAR (30)  NULL,
    [IsEnabled]    BIT            NULL,
    [DateAdded]    SMALLDATETIME  NULL,
    [DBTrgID]      INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_DBTriggers]
    ON [DB].[Triggers]([InstanceName] ASC, [DBName] ASC, [DateAdded] ASC, [DBTrgID] ASC) WITH (FILLFACTOR = 85);

