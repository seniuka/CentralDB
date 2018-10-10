CREATE TABLE [Inst].[Replication] (
    [ServerName]           NVARCHAR (128) NOT NULL,
    [InstanceName]         NVARCHAR (128) NOT NULL,
    [IsPublisher]          BIT            NULL,
    [IsDistributor]        BIT            NULL,
    [DistributorAvailable] BIT            NULL,
    [Publisher]            NVARCHAR (128) NULL,
    [Distributor]          NVARCHAR (128) NULL,
    [Subscribers]          NVARCHAR (MAX) NULL,
    [ReplPubDBs]           NVARCHAR (MAX) NULL,
    [DistDB]               NVARCHAR (128) NULL,
    [DateAdded]            SMALLDATETIME  NULL,
    [RID]                  INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_ReplInfo]
    ON [Inst].[Replication]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [RID] ASC) WITH (FILLFACTOR = 85);

