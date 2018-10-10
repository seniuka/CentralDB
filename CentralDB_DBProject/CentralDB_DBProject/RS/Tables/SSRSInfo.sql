CREATE TABLE [RS].[SSRSInfo] (
    [ServerName]             NVARCHAR (128) NOT NULL,
    [InstanceName]           NVARCHAR (128) NULL,
    [RSVersion]              NVARCHAR (30)  NULL,
    [RSEdition]              NVARCHAR (128) NULL,
    [RSVersionNo]            NVARCHAR (30)  NULL,
    [IsSharePointIntegrated] BIT            NULL,
    [DateAdded]              SMALLDATETIME  NULL,
    [RSID]                   INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_SSRSInfo]
    ON [RS].[SSRSInfo]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [RSID] ASC) WITH (FILLFACTOR = 85);

