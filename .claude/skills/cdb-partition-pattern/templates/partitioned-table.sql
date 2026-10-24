-- Name: partitioned-table.sql
-- Purpose: template for a monthly RANGE RIGHT partitioned live table and an aligned archive table
-- Version: 0.1.0
-- Standard: DBA Automation Engineering Standard v5.0.0 (UNVERIFIED, text not in repo)
-- Author: Your Friendly Neighbourhood DBA
-- Date: 2026-10-24
--
-- Replace Inst.ExampleLog, the column list, the filegroup and the boundary dates from the approved plan card.
-- Syntax parse-checked offline with ScriptDom. Not executed on any instance: runtime behavior is UNVERIFIED until /cdb-test runs it on a non-production target.

IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = N'pf_ExampleLog_Month')
BEGIN
    CREATE PARTITION FUNCTION pf_ExampleLog_Month (datetime2(0))
    AS RANGE RIGHT FOR VALUES (N'2026-01-01T00:00:00', N'2026-02-01T00:00:00', N'2026-03-01T00:00:00');
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = N'ps_ExampleLog_Month')
BEGIN
    -- DECISION: filegroup layout. ALL TO a single filegroup keeps the template simple.
    CREATE PARTITION SCHEME ps_ExampleLog_Month
    AS PARTITION pf_ExampleLog_Month ALL TO ([PRIMARY]);
END
GO

-- The partitioning column must be part of every unique index, so the primary key is (StartTimeUtc, ExampleLogId).
IF OBJECT_ID(N'Inst.ExampleLog', N'U') IS NULL
BEGIN
    CREATE TABLE Inst.ExampleLog
    (
        ExampleLogId  bigint IDENTITY(1, 1) NOT NULL,
        StartTimeUtc  datetime2(0)          NOT NULL,
        EndTimeUtc    datetime2(0)          NULL,
        ServerName    sysname               NOT NULL,
        CommandType   nvarchar(60)          NOT NULL,
        ErrorNumber   int                   NULL,
        CONSTRAINT PK_ExampleLog PRIMARY KEY CLUSTERED (StartTimeUtc, ExampleLogId)
    ) ON ps_ExampleLog_Month (StartTimeUtc);
END
GO

-- Archive table: same columns, same indexes, same partition scheme. Required so that
-- ALTER TABLE ... SWITCH PARTITION n has an identical, empty target partition n.
-- IDENTITY is omitted because switched-in rows keep their original ids.
IF OBJECT_ID(N'Inst.ExampleLog_Archive', N'U') IS NULL
BEGIN
    CREATE TABLE Inst.ExampleLog_Archive
    (
        ExampleLogId  bigint       NOT NULL,
        StartTimeUtc  datetime2(0) NOT NULL,
        EndTimeUtc    datetime2(0) NULL,
        ServerName    sysname      NOT NULL,
        CommandType   nvarchar(60) NOT NULL,
        ErrorNumber   int          NULL,
        CONSTRAINT PK_ExampleLog_Archive PRIMARY KEY CLUSTERED (StartTimeUtc, ExampleLogId)
    ) ON ps_ExampleLog_Month (StartTimeUtc);
END
GO
