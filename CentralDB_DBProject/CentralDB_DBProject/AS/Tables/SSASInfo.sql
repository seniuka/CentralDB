CREATE TABLE [AS].[SSASInfo] (
    [ServerName]       NVARCHAR (128) NOT NULL,
    [InstanceName]     NVARCHAR (128) NULL,
    [ProductName]      NVARCHAR (128) NULL,
    [ASVersion]        NVARCHAR (30)  NULL,
    [ASPatchLevel]     NVARCHAR (10)  NULL,
    [IsSPUpToDateOnAS] BIT            NULL,
    [ASEdition]        NVARCHAR (30)  NULL,
    [ASVersionNo]      NVARCHAR (30)  NULL,
    [NoOfDBs]          SMALLINT       NULL,
    [LastSchemaUpdate] NVARCHAR (30)  NULL,
    [IsConnected]      BIT            NULL,
    [IsMajorObjLoaded] BIT            NULL,
    [DateAdded]        SMALLDATETIME  NULL,
    [ASID]             INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_SSASInfo]
    ON [AS].[SSASInfo]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [ASID] ASC) WITH (FILLFACTOR = 85);

