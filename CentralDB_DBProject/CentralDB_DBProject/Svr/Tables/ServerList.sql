CREATE TABLE [Svr].[ServerList] (
    [ID]            INT             IDENTITY (1, 1) NOT NULL,
    [ServerName]    NVARCHAR (128)  NOT NULL,
    [InstanceName]  NVARCHAR (128)  NOT NULL,
    [Environment]   NVARCHAR (5)    NOT NULL,
    [Inventory]     BIT             NOT NULL,
    [Baseline]      BIT             NOT NULL,
    [Description]   NVARCHAR (MAX)  NULL,
    [BusinessOwner] NVARCHAR (1000) NULL,
    [DateAdded]     SMALLDATETIME   CONSTRAINT [DF_ServerList_DateAdded] DEFAULT (getdate()) NULL,
    [SQLPing]       BIT             NULL,
    [PingSnooze]    DATETIME2 (7)   NULL,
    [MaintStart]    DATETIME2 (7)   NULL,
    [MaintEnd]      DATETIME2 (7)   NULL,
    CONSTRAINT [IX_ServerList_InsName] UNIQUE NONCLUSTERED ([InstanceName] ASC) WITH (FILLFACTOR = 85)
);


GO
CREATE CLUSTERED INDEX [CI_ServerList]
    ON [Svr].[ServerList]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [ID] ASC) WITH (FILLFACTOR = 85);

