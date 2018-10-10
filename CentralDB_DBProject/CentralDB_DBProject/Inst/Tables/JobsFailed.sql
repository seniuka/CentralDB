CREATE TABLE [Inst].[JobsFailed] (
    [ServerName]   NVARCHAR (128) NOT NULL,
    [InstanceName] NVARCHAR (128) NOT NULL,
    [JobName]      NVARCHAR (128) NULL,
    [StepID]       INT            NULL,
    [StepName]     NVARCHAR (128) NULL,
    [ErrMsg]       NVARCHAR (MAX) NULL,
    [JobRunDate]   SMALLDATETIME  NULL,
    [DateAdded]    SMALLDATETIME  NULL,
    [JFID]         INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_JobFailInfo]
    ON [Inst].[JobsFailed]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [JFID] ASC) WITH (FILLFACTOR = 85);

