CREATE TABLE [Tbl].[HekatonTbls] (
    [ServerName]         NVARCHAR (128) NULL,
    [InstanceName]       NVARCHAR (128) NULL,
    [DBName]             NVARCHAR (128) NULL,
    [TblName]            NVARCHAR (128) NULL,
    [IsMemoryOptimized]  BIT            NULL,
    [Durability]         TINYINT        NULL,
    [DurabilityDesc]     NVARCHAR (60)  NULL,
    [MemAllocForIdxInKB] BIGINT         NULL,
    [MemAllocForTblInKB] BIGINT         NULL,
    [MemUsdByIdxInKB]    BIGINT         NULL,
    [MemUsdByTblInKB]    BIGINT         NULL,
    [DateAdded]          SMALLDATETIME  NULL,
    [HID]                INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_HekatonInfo]
    ON [Tbl].[HekatonTbls]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [HID] ASC) WITH (FILLFACTOR = 85);

