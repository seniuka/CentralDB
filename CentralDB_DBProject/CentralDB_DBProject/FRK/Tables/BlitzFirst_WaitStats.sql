CREATE TABLE [FRK].[BlitzFirst_WaitStats] (
    [ID]                  INT                IDENTITY (1, 1) NOT NULL,
    [ServerName]          NVARCHAR (128)     NULL,
    [CheckDate]           DATETIMEOFFSET (7) NULL,
    [wait_type]           NVARCHAR (60)      NULL,
    [wait_time_ms]        BIGINT             NULL,
    [signal_wait_time_ms] BIGINT             NULL,
    [waiting_tasks_count] BIGINT             NULL,
    CONSTRAINT [PK_BlitzFirst_WaitStats] PRIMARY KEY CLUSTERED ([ID] ASC)
);

