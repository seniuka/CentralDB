-- ============================================================================
-- Object   : [Inst].[usp_GetBaselineStats]
-- Schema   : Inst
-- Author   : DBA Engineering
-- Created  : 2024-01-01
-- Version  : 4.1.0
-- Purpose  : Captures a point-in-time SQL Server performance counter baseline
--            by taking two snapshots of sys.dm_os_performance_counters one
--            second apart, computing per-second delta rates, and returning a
--            single pivoted row per call.
--
--            Replaces the inline T-SQL in Get-BaselineStats.ps1 which embedded
--            the full two-snapshot PIVOT logic as a string in PowerShell with
--            string-interpolated server/instance names (SQL injection risk).
--
-- Parameters:
--   @ServerName   - Hostname for the ServerName column in results
--   @InstanceName - Instance identifier for the InstanceName column
--
-- Returns:
--   Single row with one column per counter, suitable for direct bulk insert
--   into [Inst].[InsBaselineStats] via Write-DbaDbTableData.
--
-- Notes:
--   WAITFOR DELAY '00:00:01' is intentional - required for delta counters.
--   Buffer/Procedure cache percentages use the standard ratio formula
--   (value / base * 100.0), correcting the original script which erroneously
--   added 100 to both calculations.
-- ============================================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [Inst].[usp_GetBaselineStats]
    @ServerName   NVARCHAR(255),
    @InstanceName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @ServerName IS NULL OR LEN(LTRIM(RTRIM(@ServerName))) = 0
        THROW 50001, '@ServerName is required.', 1;

    IF @InstanceName IS NULL OR LEN(LTRIM(RTRIM(@InstanceName))) = 0
        THROW 50002, '@InstanceName is required.', 1;

    DECLARE @CounterPrefix NVARCHAR(30);
    SET @CounterPrefix = CASE
        WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'SQLServer:'
        ELSE 'MSSQL$' + @@SERVICENAME + ':'
    END;

    -- Snapshot 1
    SELECT
        CAST(1 AS INT)          AS collection_instance,
        [object_name],
        counter_name,
        instance_name,
        cntr_value,
        cntr_type,
        CURRENT_TIMESTAMP       AS collection_time
    INTO #perf_counters_init
    FROM sys.dm_os_performance_counters
    WHERE
        (
               (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Page life expectancy')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Lazy writes/sec')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Page reads/sec')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Page writes/sec')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Readahead pages/sec')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Checkpoint pages/sec')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Free list stalls/sec')
            OR (object_name = @CounterPrefix + 'Databases'         AND counter_name = 'Log Growths')
            OR (object_name = @CounterPrefix + 'Databases'         AND counter_name = 'Transactions/sec')
            OR (object_name = @CounterPrefix + 'General Statistics'AND counter_name = 'User Connections')
            OR (object_name = @CounterPrefix + 'General Statistics'AND counter_name = 'Processes blocked')
            OR (object_name = @CounterPrefix + 'Locks'             AND counter_name = 'Lock Waits/sec')
            OR (object_name = @CounterPrefix + 'Locks'             AND counter_name = 'Number of Deadlocks/sec')
            OR (object_name = @CounterPrefix + 'Locks'             AND counter_name = 'Lock Wait Time (ms)')
            OR (object_name = @CounterPrefix + 'Access Methods'    AND counter_name = 'Forwarded Records/sec')
            OR (object_name = @CounterPrefix + 'Access Methods'    AND counter_name = 'Index Searches/sec')
            OR (object_name = @CounterPrefix + 'Access Methods'    AND counter_name = 'Full Scans/sec')
            OR (object_name = @CounterPrefix + 'Access Methods'    AND counter_name = 'Page Splits/sec')
            OR (object_name = @CounterPrefix + 'SQL Statistics'    AND counter_name = 'Batch Requests/sec')
            OR (object_name = @CounterPrefix + 'SQL Statistics'    AND counter_name = 'SQL Compilations/sec')
            OR (object_name = @CounterPrefix + 'SQL Statistics'    AND counter_name = 'SQL Re-Compilations/sec')
            OR (object_name = @CounterPrefix + 'Latches'           AND counter_name = 'Latch Waits/sec')
            OR (object_name = @CounterPrefix + 'Memory Manager'    AND counter_name = 'Memory Grants Pending')
            OR (object_name = @CounterPrefix + 'Workload Group Stats' AND counter_name = 'CPU usage %')
            OR (object_name = @CounterPrefix + 'Workload Group Stats' AND counter_name = 'CPU usage % base')
        )
    AND (instance_name = '' OR instance_name = '_Total' OR instance_name = 'default');

    WAITFOR DELAY '00:00:01';

    -- Snapshot 2
    SELECT
        CAST(2 AS INT)          AS collection_instance,
        [object_name],
        counter_name,
        instance_name,
        cntr_value,
        cntr_type,
        CURRENT_TIMESTAMP       AS collection_time
    INTO #perf_counters_second
    FROM sys.dm_os_performance_counters
    WHERE
        (
               (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Page life expectancy')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Lazy writes/sec')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Page reads/sec')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Page writes/sec')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Readahead pages/sec')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Checkpoint pages/sec')
            OR (object_name = @CounterPrefix + 'Buffer Manager'    AND counter_name = 'Free list stalls/sec')
            OR (object_name = @CounterPrefix + 'Databases'         AND counter_name = 'Log Growths')
            OR (object_name = @CounterPrefix + 'Databases'         AND counter_name = 'Transactions/sec')
            OR (object_name = @CounterPrefix + 'General Statistics'AND counter_name = 'User Connections')
            OR (object_name = @CounterPrefix + 'General Statistics'AND counter_name = 'Processes blocked')
            OR (object_name = @CounterPrefix + 'Locks'             AND counter_name = 'Lock Waits/sec')
            OR (object_name = @CounterPrefix + 'Locks'             AND counter_name = 'Number of Deadlocks/sec')
            OR (object_name = @CounterPrefix + 'Locks'             AND counter_name = 'Lock Wait Time (ms)')
            OR (object_name = @CounterPrefix + 'Access Methods'    AND counter_name = 'Forwarded Records/sec')
            OR (object_name = @CounterPrefix + 'Access Methods'    AND counter_name = 'Index Searches/sec')
            OR (object_name = @CounterPrefix + 'Access Methods'    AND counter_name = 'Full Scans/sec')
            OR (object_name = @CounterPrefix + 'Access Methods'    AND counter_name = 'Page Splits/sec')
            OR (object_name = @CounterPrefix + 'SQL Statistics'    AND counter_name = 'Batch Requests/sec')
            OR (object_name = @CounterPrefix + 'SQL Statistics'    AND counter_name = 'SQL Compilations/sec')
            OR (object_name = @CounterPrefix + 'SQL Statistics'    AND counter_name = 'SQL Re-Compilations/sec')
            OR (object_name = @CounterPrefix + 'Latches'           AND counter_name = 'Latch Waits/sec')
            OR (object_name = @CounterPrefix + 'Memory Manager'    AND counter_name = 'Memory Grants Pending')
            OR (object_name = @CounterPrefix + 'Workload Group Stats' AND counter_name = 'CPU usage %')
            OR (object_name = @CounterPrefix + 'Workload Group Stats' AND counter_name = 'CPU usage % base')
        )
    AND (instance_name = '' OR instance_name = '_Total' OR instance_name = 'default');

    -- Buffer cache hit ratio (corrected: value/base*100, not 100+(delta/base*100))
    DECLARE @BufferCachePct   DECIMAL(8, 2);
    DECLARE @ProcedureCachePct DECIMAL(8, 2);

    SELECT @BufferCachePct =
        CAST(c.cntr_value AS FLOAT) / NULLIF(CAST(b.cntr_value AS FLOAT), 0) * 100.0
    FROM sys.dm_os_performance_counters AS c
    CROSS JOIN sys.dm_os_performance_counters AS b
    WHERE c.object_name = @CounterPrefix + 'Buffer Manager'
      AND c.counter_name = 'Buffer cache hit ratio'
      AND b.object_name  = @CounterPrefix + 'Buffer Manager'
      AND b.counter_name = 'Buffer cache hit ratio base';

    SELECT @ProcedureCachePct =
        CAST(c.cntr_value AS FLOAT) / NULLIF(CAST(b.cntr_value AS FLOAT), 0) * 100.0
    FROM sys.dm_os_performance_counters AS c
    CROSS JOIN sys.dm_os_performance_counters AS b
    WHERE c.instance_name = '_Total'
      AND c.object_name   = @CounterPrefix + 'Plan Cache'
      AND c.counter_name  = 'Cache Hit Ratio'
      AND b.instance_name = '_Total'
      AND b.object_name   = @CounterPrefix + 'Plan Cache'
      AND b.counter_name  = 'Cache Hit Ratio Base';

    -- Delta calculation and PIVOT
    SELECT
        @ServerName             AS ServerName,
        @InstanceName           AS InstanceName,
        GETDATE()               AS CollectedAt,
        [Forwarded Records/sec] AS FwdRecSec,
        [Full Scans/sec]        AS FlScansSec,
        [Index Searches/sec]    AS IdxSrchsSec,
        [Page Splits/sec]       AS PgSpltSec,
        [Free list stalls/sec]  AS FreeLstStallsSec,
        [Lazy writes/sec]       AS LzyWrtsSec,
        [Page life expectancy]  AS PgLifeExp,
        [Page reads/sec]        AS PgRdSec,
        [Page writes/sec]       AS PgWtSec,
        [Log Growths]           AS LogGrwths,
        [Transactions/sec]      AS TranSec,
        [Processes blocked]     AS BlkProcs,
        [User Connections]      AS UsrConns,
        [Latch Waits/sec]       AS LatchWtsSec,
        [Lock Wait Time (ms)]   AS LckWtTime,
        [Lock Waits/sec]        AS LckWtsSec,
        [Number of Deadlocks/sec] AS DeadLockSec,
        [Memory Grants Pending] AS MemGrnts,
        [Batch Requests/sec]    AS BatReqSec,
        [SQL Compilations/sec]  AS SQLCompSec,
        [SQL Re-Compilations/sec] AS SQLReCompSec,
        [Readahead pages/sec]   AS ReadAheadReadsSec,
        [Checkpoint pages/sec]  AS CheckpointWritesSec,
        @BufferCachePct         AS BufferCachePercentage,
        @ProcedureCachePct      AS ProcedureCachePercentage
    FROM (
        SELECT
            s.counter_name,
            CASE
                WHEN i.cntr_type = 272696576 THEN s.cntr_value - i.cntr_value   -- per-sec delta
                WHEN i.cntr_type = 65792     THEN s.cntr_value                  -- point-in-time
                ELSE i.cntr_value
            END AS cntr_value
        FROM #perf_counters_init    AS i
        JOIN #perf_counters_second  AS s
            ON  i.collection_instance + 1 = s.collection_instance
            AND i.object_name             = s.object_name
            AND i.counter_name            = s.counter_name
            AND i.instance_name           = s.instance_name
    ) AS src
    PIVOT (
        MAX(cntr_value)
        FOR counter_name IN (
            [Forwarded Records/sec],
            [Full Scans/sec],
            [Index Searches/sec],
            [Page Splits/sec],
            [Free list stalls/sec],
            [Lazy writes/sec],
            [Page life expectancy],
            [Page reads/sec],
            [Page writes/sec],
            [Log Growths],
            [Transactions/sec],
            [Processes blocked],
            [User Connections],
            [Latch Waits/sec],
            [Lock Wait Time (ms)],
            [Lock Waits/sec],
            [Number of Deadlocks/sec],
            [Memory Grants Pending],
            [Batch Requests/sec],
            [SQL Compilations/sec],
            [SQL Re-Compilations/sec],
            [Readahead pages/sec],
            [Checkpoint pages/sec]
        )
    ) AS pvt;

    DROP TABLE #perf_counters_init;
    DROP TABLE #perf_counters_second;
END;
GO
