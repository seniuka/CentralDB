CREATE TABLE [Inst].[LinkedServers] (
    [ServerName]       NVARCHAR (128) NULL,
    [InstanceName]     NVARCHAR (128) NULL,
    [LinkedServerName] NVARCHAR (128) NULL,
    [ProviderName]     NVARCHAR (30)  NULL,
    [ProductName]      NVARCHAR (128) NULL,
    [ProviderString]   NVARCHAR (MAX) NULL,
    [DateLastModified] NVARCHAR (30)  NULL,
    [DataAccess]       BIT            NULL,
    [DateAdded]        SMALLDATETIME  NULL,
    [LnkID]            INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_LinkedServers]
    ON [Inst].[LinkedServers]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [LnkID] ASC) WITH (FILLFACTOR = 85);

