CREATE TABLE [Svr].[SvrBaselineStats] (
    [ServerName]   NVARCHAR (128)  NULL,
    [InstanceName] NVARCHAR (128)  NULL,
    [RunDate]      SMALLDATETIME   NOT NULL,
    [PctProcTm]    DECIMAL (10, 5) NOT NULL,
    [ProcQLen]     INT             NOT NULL,
    [AvDskRd]      DECIMAL (10, 5) NOT NULL,
    [AvDskWt]      DECIMAL (10, 5) NOT NULL,
    [AvDskQLen]    DECIMAL (10, 5) NOT NULL,
    [AvailMB]      BIGINT          NOT NULL,
    [PgFlUsg]      DECIMAL (10, 5) NOT NULL,
    [SvrBLID]      BIGINT          IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_SvrBaselineStats]
    ON [Svr].[SvrBaselineStats]([ServerName] ASC, [InstanceName] ASC, [RunDate] ASC, [SvrBLID] ASC) WITH (FILLFACTOR = 85);

