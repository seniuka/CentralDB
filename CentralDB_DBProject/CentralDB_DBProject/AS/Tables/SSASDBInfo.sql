CREATE TABLE [AS].[SSASDBInfo] (
    [ServerName]         NVARCHAR (128)  NOT NULL,
    [InstanceName]       NVARCHAR (128)  NULL,
    [DBName]             NVARCHAR (128)  NULL,
    [DBSizeInMB]         DECIMAL (10, 2) NULL,
    [Collation]          NVARCHAR (30)   NULL,
    [CompatibilityLevel] NVARCHAR (30)   NULL,
    [DBCreateDate]       NVARCHAR (30)   NULL,
    [DBLastProcessed]    NVARCHAR (30)   NULL,
    [DBLastUpdated]      NVARCHAR (30)   NULL,
    [DBStorageLocation]  NVARCHAR (500)  NULL,
    [NoOfCubes]          SMALLINT        NULL,
    [NoOfDimensions]     SMALLINT        NULL,
    [ReadWriteMode]      NVARCHAR (30)   NULL,
    [StorgageEngineUsed] NVARCHAR (30)   NULL,
    [IsVisible]          BIT             NULL,
    [DateAdded]          SMALLDATETIME   NULL,
    [ASDBID]             INT             IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_SSASDBInfo]
    ON [AS].[SSASDBInfo]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [ASDBID] ASC) WITH (FILLFACTOR = 85);

