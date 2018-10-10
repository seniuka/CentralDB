CREATE TABLE [Svr].[ServerInfo] (
    [ServerName]                NVARCHAR (128)  NOT NULL,
    [IPAddress]                 NVARCHAR (50)   NULL,
    [Model]                     NVARCHAR (128)  NULL,
    [Manufacturer]              NVARCHAR (128)  NULL,
    [Description]               NVARCHAR (128)  NULL,
    [SystemType]                NVARCHAR (128)  NULL,
    [ActiveNodeName]            NVARCHAR (128)  NULL,
    [Domain]                    NVARCHAR (128)  NULL,
    [DomainRole]                NVARCHAR (128)  NULL,
    [PartOfDomain]              BIT             NULL,
    [NumberOfProcessors]        INT             NULL,
    [NumberOfLogicalProcessors] INT             NULL,
    [NumberOfCores]             INT             NULL,
    [IsHyperThreaded]           BIT             NULL,
    [CurrentCPUSpeed]           INT             NULL,
    [MaxCPUSpeed]               INT             NULL,
    [IsPowerSavingModeON]       BIT             NULL,
    [TotalPhysicalMemoryInGB]   DECIMAL (10, 2) NULL,
    [IsPagefileManagedBySystem] BIT             NULL,
    [IsVM]                      BIT             NULL,
    [IsClu]                     BIT             NULL,
    [DateAdded]                 SMALLDATETIME   NULL,
    [SvrID]                     INT             IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_ServerInfo]
    ON [Svr].[ServerInfo]([ServerName] ASC, [DateAdded] ASC, [SvrID] ASC) WITH (FILLFACTOR = 85);

