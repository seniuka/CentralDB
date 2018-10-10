CREATE TABLE [FRK].[Blitz] (
    [ID]                INT                IDENTITY (1, 1) NOT NULL,
    [ServerName]        NVARCHAR (128)     NULL,
    [CheckDate]         DATETIMEOFFSET (7) NULL,
    [Priority]          TINYINT            NULL,
    [FindingsGroup]     VARCHAR (50)       NULL,
    [Finding]           VARCHAR (200)      NULL,
    [DatabaseName]      NVARCHAR (128)     NULL,
    [URL]               VARCHAR (200)      NULL,
    [Details]           NVARCHAR (4000)    NULL,
    [QueryPlan]         XML                NULL,
    [QueryPlanFiltered] NVARCHAR (MAX)     NULL,
    [CheckID]           INT                NULL,
    CONSTRAINT [PK_Blitz] PRIMARY KEY CLUSTERED ([ID] ASC)
);

