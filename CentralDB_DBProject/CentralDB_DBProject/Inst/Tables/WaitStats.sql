CREATE TABLE [Inst].[WaitStats] (
    [ServerName]   NVARCHAR (128)  NULL,
    [InstanceName] NVARCHAR (128)  NULL,
    [WaitType]     NVARCHAR (128)  NULL,
    [Wait_S]       DECIMAL (14, 2) NULL,
    [Resource_S]   DECIMAL (14, 2) NULL,
    [Signal_S]     DECIMAL (14, 2) NULL,
    [WaitCount]    BIGINT          NULL,
    [Percentage]   DECIMAL (4, 2)  NULL,
    [AvgWait_S]    DECIMAL (14, 2) NULL,
    [AvgRes_S]     DECIMAL (14, 2) NULL,
    [AvgSig_S]     DECIMAL (14, 2) NULL,
    [DateAdded]    SMALLDATETIME   NULL,
    [WtID]         BIGINT          IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_WaitStats]
    ON [Inst].[WaitStats]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [WtID] ASC) WITH (FILLFACTOR = 85);

