CREATE TABLE [DB].[DBFileGrowth] (
    [ServerName]   NVARCHAR (128) NULL,
    [InstanceName] NVARCHAR (128) NULL,
    [DBName]       NVARCHAR (128) NULL,
    [DataFileInMB] INT            NULL,
    [LogFileInMB]  INT            NULL,
    [DateAdded]    SMALLDATETIME  NULL,
    [DBFGID]       INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_DBFileGrowth]
    ON [DB].[DBFileGrowth]([InstanceName] ASC, [DBName] ASC, [DateAdded] ASC, [DBFGID] ASC) WITH (FILLFACTOR = 85);

