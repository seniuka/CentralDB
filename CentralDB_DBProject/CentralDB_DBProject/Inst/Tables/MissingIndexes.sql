CREATE TABLE [Inst].[MissingIndexes] (
    [ServerName]             NVARCHAR (128) NULL,
    [InstanceName]           NVARCHAR (128) NULL,
    [DBName]                 NVARCHAR (128) NULL,
    [SchemaName]             NVARCHAR (30)  NULL,
    [MITable]                NVARCHAR (128) NULL,
    [improvement_measure]    NVARCHAR (30)  NULL,
    [create_index_statement] NVARCHAR (MAX) NULL,
    [group_handle]           INT            NULL,
    [unique_compiles]        INT            NULL,
    [user_seeks]             INT            NULL,
    [last_user_seek]         SMALLDATETIME  NULL,
    [avg_total_user_cost]    NVARCHAR (30)  NULL,
    [avg_user_impact]        NVARCHAR (6)   NULL,
    [DateAdded]              SMALLDATETIME  NULL,
    [MIID]                   INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_MissingIndexes]
    ON [Inst].[MissingIndexes]([ServerName] ASC, [InstanceName] ASC, [DBName] ASC, [DateAdded] ASC, [MIID] ASC) WITH (FILLFACTOR = 85);

