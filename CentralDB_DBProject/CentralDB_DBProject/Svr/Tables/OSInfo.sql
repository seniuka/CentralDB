CREATE TABLE [Svr].[OSInfo] (
    [ServerName]                   NVARCHAR (128)  NOT NULL,
    [OSName]                       NVARCHAR (128)  NULL,
    [OSArchitecture]               NVARCHAR (30)   NULL,
    [OSVersion]                    NVARCHAR (20)   NULL,
    [OSServicePack]                NVARCHAR (50)   NULL,
    [OSInstallDate]                SMALLDATETIME   NULL,
    [OSLastRestart]                SMALLDATETIME   NULL,
    [OSUpTime]                     NVARCHAR (128)  NULL,
    [OSTotalVisibleMemorySizeInGB] DECIMAL (10, 2) NULL,
    [OSFreePhysicalMemoryInGB]     DECIMAL (10, 2) NULL,
    [OSTotalVirtualMemorySizeInGB] DECIMAL (10, 2) NULL,
    [OSFreeVirtualMemoryInGB]      DECIMAL (10, 2) NULL,
    [OSFreeSpaceInPagingFilesInGB] DECIMAL (10, 2) NULL,
    [DateAdded]                    SMALLDATETIME   NULL,
    [OSID]                         INT             IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_OSInfo]
    ON [Svr].[OSInfo]([ServerName] ASC, [DateAdded] ASC, [OSID] ASC) WITH (FILLFACTOR = 85);

