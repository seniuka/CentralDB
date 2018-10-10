CREATE TABLE [Inst].[Jobs] (
    [ServerName]             NVARCHAR (128) NOT NULL,
    [InstanceName]           NVARCHAR (128) NOT NULL,
    [JobName]                NVARCHAR (128) NULL,
    [JobDescription]         NVARCHAR (MAX) NULL,
    [JobOwner]               NVARCHAR (128) NULL,
    [IsEnabled]              BIT            NULL,
    [category]               NVARCHAR (128) NULL,
    [JobCreatedDate]         NVARCHAR (30)  NULL,
    [JobLastModified]        NVARCHAR (30)  NULL,
    [LastRunDate]            NVARCHAR (30)  NULL,
    [NextRunDate]            NVARCHAR (30)  NULL,
    [LastRunOutcome]         NVARCHAR (30)  NULL,
    [CurrentRunRetryAttempt] SMALLINT       NULL,
    [OperatorToEmail]        NVARCHAR (128) NULL,
    [OperatorToPage]         NVARCHAR (128) NULL,
    [HasSchedule]            BIT            NULL,
    [DateAdded]              SMALLDATETIME  NULL,
    [JobID]                  INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_Jobs]
    ON [Inst].[Jobs]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [JobID] ASC) WITH (FILLFACTOR = 85);

