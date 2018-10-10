CREATE TABLE [DB].[DatabaseBackups] (
    [ServerName]           NVARCHAR (128)   NOT NULL,
    [InstanceName]         NVARCHAR (128)   NOT NULL,
    [DBName]               NVARCHAR (128)   NULL,
    [BackupSetGUID]        UNIQUEIDENTIFIER NULL,
    [BackupTypeCode]       NVARCHAR (3)     NULL,
    [BackupTypeDesciption] NVARCHAR (256)   NULL,
    [BackupStartDate]      DATETIME         NULL,
    [BackupFinishDate]     DATETIME         NULL,
    [BackupDurationMS]     INT              NULL,
    [ExpirationDate]       SMALLDATETIME    NULL,
    [BackupSize]           DECIMAL (18, 2)  NULL,
    [CompressedBackupSize] DECIMAL (18, 2)  NULL,
    [PhysicalDeviceName]   NVARCHAR (500)   NULL,
    [Description]          NVARCHAR (256)   NULL,
    [RecoveryModel]        NVARCHAR (60)    NULL,
    [IsCopyOnly]           TINYINT          NULL,
    [IsPasswordProtected]  TINYINT          NULL,
    [HasbackupChecksums]   TINYINT          NULL,
    [DateAdded]            SMALLDATETIME    CONSTRAINT [DF_DatabaseBackups_DateAdded] DEFAULT (getdate()) NULL,
    [DBID]                 INT              IDENTITY (1, 1) NOT NULL,
    [BackupHash]           AS               (hashbytes('SHA1',((((((([ServerName]+'|')+[InstanceName])+'|')+[DBName])+'|')+[BackupTypeCode])+'|')+CONVERT([nvarchar](10),[BackupStartDate],(120)))) PERSISTED,
    [BackupServerHash]     AS               (hashbytes('SHA1',((((([ServerName]+'|')+[InstanceName])+'|')+[DBName])+'|')+CONVERT([nvarchar](10),[BackupStartDate],(120)))) PERSISTED
);


GO
CREATE CLUSTERED INDEX [CI_DatabaseBackups]
    ON [DB].[DatabaseBackups]([InstanceName] ASC, [DBName] ASC, [DateAdded] ASC, [DBID] ASC) WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

