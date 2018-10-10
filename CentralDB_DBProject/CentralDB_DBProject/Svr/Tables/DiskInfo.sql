CREATE TABLE [Svr].[DiskInfo] (
    [ServerName]         NVARCHAR (128)  NOT NULL,
    [DiskName]           NVARCHAR (128)  NULL,
    [Label]              NVARCHAR (128)  NULL,
    [FileSystem]         NVARCHAR (30)   NULL,
    [DskClusterSizeInKB] INT             NULL,
    [DskTotalSizeInGB]   DECIMAL (10, 2) NULL,
    [DskFreeSpaceInGB]   DECIMAL (10, 2) NULL,
    [DskUsedSpaceInGB]   DECIMAL (10, 2) NULL,
    [DskPctFreeSpace]    NVARCHAR (10)   NULL,
    [DateAdded]          SMALLDATETIME   NULL,
    [DiskID]             INT             IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_DiskInfo]
    ON [Svr].[DiskInfo]([ServerName] ASC, [DateAdded] ASC, [DiskID] ASC) WITH (FILLFACTOR = 85);

