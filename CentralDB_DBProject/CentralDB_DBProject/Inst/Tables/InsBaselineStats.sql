CREATE TABLE [Inst].[InsBaselineStats] (
    [ServerName]       NVARCHAR (128) NULL,
    [InstanceName]     NVARCHAR (128) NULL,
    [FwdRecSec]        DECIMAL (15)   NOT NULL,
    [FlScansSec]       DECIMAL (15)   NOT NULL,
    [IdxSrchsSec]      DECIMAL (15)   NOT NULL,
    [PgSpltSec]        DECIMAL (15)   NOT NULL,
    [FreeLstStallsSec] DECIMAL (15)   NOT NULL,
    [LzyWrtsSec]       DECIMAL (15)   NOT NULL,
    [PgLifeExp]        DECIMAL (15)   NOT NULL,
    [PgRdSec]          DECIMAL (15)   NOT NULL,
    [PgWtSec]          DECIMAL (15)   NOT NULL,
    [LogGrwths]        DECIMAL (15)   NOT NULL,
    [TranSec]          DECIMAL (15)   NOT NULL,
    [BlkProcs]         DECIMAL (15)   NOT NULL,
    [UsrConns]         DECIMAL (15)   NOT NULL,
    [LatchWtsSec]      DECIMAL (15)   NOT NULL,
    [LckWtTime]        DECIMAL (15)   NOT NULL,
    [LckWtsSec]        DECIMAL (15)   NOT NULL,
    [DeadLockSec]      DECIMAL (15)   NOT NULL,
    [MemGrnts]         DECIMAL (15)   NOT NULL,
    [BatReqSec]        DECIMAL (15)   NOT NULL,
    [SQLCompSec]       DECIMAL (15)   NOT NULL,
    [SQLReCompSec]     DECIMAL (15)   NOT NULL,
    [RunDate]          SMALLDATETIME  CONSTRAINT [DF_InsStats_RunDate] DEFAULT (getdate()) NOT NULL,
    [InsBLID]          BIGINT         IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_InsBaselineStats]
    ON [Inst].[InsBaselineStats]([ServerName] ASC, [InstanceName] ASC, [RunDate] ASC, [InsBLID] ASC) WITH (FILLFACTOR = 85);

