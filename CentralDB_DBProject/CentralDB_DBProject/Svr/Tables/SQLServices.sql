CREATE TABLE [Svr].[SQLServices] (
    [ServerName]  NVARCHAR (128) NOT NULL,
    [ServiceName] NVARCHAR (128) NULL,
    [DisplayName] NVARCHAR (128) NULL,
    [Started]     BIT            NULL,
    [StartMode]   NVARCHAR (30)  NULL,
    [State]       NVARCHAR (30)  NULL,
    [BinaryPath]  NVARCHAR (500) NULL,
    [LogOnAs]     NVARCHAR (128) NULL,
    [ProcessId]   INT            NULL,
    [DateAdded]   SMALLDATETIME  NULL,
    [SQLID]       INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_SQLServices]
    ON [Svr].[SQLServices]([ServerName] ASC, [DateAdded] ASC, [SQLID] ASC) WITH (FILLFACTOR = 85);

