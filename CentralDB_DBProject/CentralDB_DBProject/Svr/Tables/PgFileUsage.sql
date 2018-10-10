CREATE TABLE [Svr].[PgFileUsage] (
    [ServerName]        NVARCHAR (128)  NOT NULL,
    [PgFileLocation]    NVARCHAR (128)  NULL,
    [PgAllocBaseSzInGB] DECIMAL (10, 2) NULL,
    [PgCurrUsageInGB]   DECIMAL (10, 2) NULL,
    [PgPeakUsageInGB]   DECIMAL (10, 2) NULL,
    [DateAdded]         SMALLDATETIME   NULL,
    [PFID]              INT             IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_PgFileUsage]
    ON [Svr].[PgFileUsage]([ServerName] ASC, [DateAdded] ASC, [PFID] ASC) WITH (FILLFACTOR = 85);

