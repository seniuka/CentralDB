CREATE TABLE [Tbl].[TblPermissions] (
    [ServerName]   NVARCHAR (128) NULL,
    [InstanceName] NVARCHAR (128) NULL,
    [DBName]       NVARCHAR (128) NULL,
    [UserName]     NVARCHAR (128) NULL,
    [ClassDesc]    NVARCHAR (60)  NULL,
    [ObjName]      NVARCHAR (128) NULL,
    [PermName]     NVARCHAR (60)  NULL,
    [PermState]    NVARCHAR (60)  NULL,
    [DateAdded]    SMALLDATETIME  NULL,
    [TBLID]        INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_TblPermsInfo]
    ON [Tbl].[TblPermissions]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [TBLID] ASC) WITH (FILLFACTOR = 85);

