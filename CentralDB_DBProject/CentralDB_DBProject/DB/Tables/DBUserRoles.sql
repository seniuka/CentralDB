CREATE TABLE [DB].[DBUserRoles] (
    [ServerName]   NVARCHAR (128) NULL,
    [InstanceName] NVARCHAR (128) NULL,
    [DBName]       NVARCHAR (128) NULL,
    [DBUser]       NVARCHAR (128) NULL,
    [DBRole]       VARCHAR (128)  NULL,
    [DateAdded]    SMALLDATETIME  NULL,
    [DBUsrID]      INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_DBUserRoles]
    ON [DB].[DBUserRoles]([InstanceName] ASC, [DBName] ASC, [DateAdded] ASC, [DBUsrID] ASC) WITH (FILLFACTOR = 85);

