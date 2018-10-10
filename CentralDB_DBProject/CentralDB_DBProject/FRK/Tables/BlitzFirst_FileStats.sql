CREATE TABLE [FRK].[BlitzFirst_FileStats] (
    [ID]                INT                IDENTITY (1, 1) NOT NULL,
    [ServerName]        NVARCHAR (128)     NULL,
    [CheckDate]         DATETIMEOFFSET (7) NULL,
    [DatabaseID]        INT                NOT NULL,
    [FileID]            INT                NOT NULL,
    [DatabaseName]      NVARCHAR (256)     NULL,
    [FileLogicalName]   NVARCHAR (256)     NULL,
    [TypeDesc]          NVARCHAR (60)      NULL,
    [SizeOnDiskMB]      BIGINT             NULL,
    [io_stall_read_ms]  BIGINT             NULL,
    [num_of_reads]      BIGINT             NULL,
    [bytes_read]        BIGINT             NULL,
    [io_stall_write_ms] BIGINT             NULL,
    [num_of_writes]     BIGINT             NULL,
    [bytes_written]     BIGINT             NULL,
    [PhysicalName]      NVARCHAR (520)     NULL,
    CONSTRAINT [PK_BlitzFirst_FileStats] PRIMARY KEY CLUSTERED ([ID] ASC)
);

