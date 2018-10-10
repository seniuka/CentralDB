CREATE TABLE [Inst].[Logins] (
    [ServerName]        NVARCHAR (128) NULL,
    [InstanceName]      NVARCHAR (128) NULL,
    [LoginName]         NVARCHAR (128) NULL,
    [LoginType]         NVARCHAR (20)  NULL,
    [LoginCreateDate]   NVARCHAR (50)  NULL,
    [LoginLastModified] NVARCHAR (50)  NULL,
    [IsDisabled]        BIT            NULL,
    [IsLocked]          BIT            NULL,
    [DateAdded]         SMALLDATETIME  NULL,
    [LoginID]           INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_Logins]
    ON [Inst].[Logins]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [LoginID] ASC) WITH (FILLFACTOR = 85);

