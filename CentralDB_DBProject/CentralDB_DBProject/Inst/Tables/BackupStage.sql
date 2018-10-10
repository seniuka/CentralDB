CREATE TABLE [Inst].[BackupStage] (
    [Directory]         NVARCHAR (4000) NULL,
    [FileName]          NVARCHAR (4000) NULL,
    [FileSize]          NVARCHAR (4000) NULL,
    [FileDate]          NVARCHAR (4000) NULL,
    [DateAdded]         SMALLDATETIME   NULL,
    [bsID]              BIGINT          IDENTITY (1, 1) NOT NULL,
    [FileNameCheckSum]  AS              (binary_checksum([FileName])) PERSISTED,
    [FileNameHashBytes] AS              (hashbytes('SHA1',[FileName])) PERSISTED,
    CONSTRAINT [PK_BackupStage] PRIMARY KEY CLUSTERED ([bsID] ASC)
);

