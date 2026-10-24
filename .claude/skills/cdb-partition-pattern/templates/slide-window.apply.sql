-- Name: slide-window.apply.sql
-- Purpose: template for the sliding-window procedure (add future boundaries, switch old months to the archive, purge and merge old archive months)
-- Version: 0.1.0
-- Standard: DBA Automation Engineering Standard v5.0.0 (UNVERIFIED, text not in repo)
-- Author: Your Friendly Neighbourhood DBA
-- Date: 2026-10-24
--
-- This file is named *.apply.sql because the procedure contains a partition-level purge. Under docs/deny-list.md the
-- purge is gated: @Apply defaults to 0 (print the plan only) and the Agent job step passes @Apply = 1 explicitly.
-- Syntax parse-checked offline with ScriptDom. Not executed on any instance: runtime behavior is UNVERIFIED until /cdb-test runs it on a non-production target.

CREATE OR ALTER PROCEDURE Inst.usp_ExampleLog_SlideWindow
    @FutureMonths  int = 3,
    @LiveMonths    int = 24,
    @ArchiveMonths int = 84,
    @Apply         bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @FutureMonths < 1 OR @LiveMonths < 1 OR @ArchiveMonths < @LiveMonths
        THROW 50001, N'Invalid window: need FutureMonths >= 1, LiveMonths >= 1 and ArchiveMonths >= LiveMonths.', 1;

    DECLARE @monthStart  date = DATEFROMPARTS(YEAR(SYSUTCDATETIME()), MONTH(SYSUTCDATETIME()), 1);
    DECLARE @addUntil    date = DATEADD(month, @FutureMonths + 1, @monthStart);
    DECLARE @liveCutoff  date = DATEADD(month, -@LiveMonths, @monthStart);
    DECLARE @archCutoff  date = DATEADD(month, -@ArchiveMonths, @monthStart);
    DECLARE @boundary    datetime2(0);
    DECLARE @partition   int;
    DECLARE @rows        bigint;
    DECLARE @sql         nvarchar(max);

    -- 1. Add future boundaries so inserts never land in the last, open-ended partition.
    SELECT @boundary = MAX(CONVERT(datetime2(0), prv.value))
    FROM sys.partition_functions AS pf
    INNER JOIN sys.partition_range_values AS prv ON prv.function_id = pf.function_id
    WHERE pf.name = N'pf_ExampleLog_Month';

    WHILE @boundary < @addUntil
    BEGIN
        SET @boundary = DATEADD(month, 1, @boundary);
        PRINT CONCAT(N'ADD BOUNDARY ', CONVERT(nvarchar(30), @boundary, 126));
        IF @Apply = 1
        BEGIN
            ALTER PARTITION SCHEME ps_ExampleLog_Month NEXT USED [PRIMARY];
            ALTER PARTITION FUNCTION pf_ExampleLog_Month() SPLIT RANGE (@boundary);
        END
    END

    -- 2. Switch live months older than the live window into the aligned archive partition.
    DECLARE live_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT CONVERT(datetime2(0), prv.value)
        FROM sys.partition_functions AS pf
        INNER JOIN sys.partition_range_values AS prv ON prv.function_id = pf.function_id
        WHERE pf.name = N'pf_ExampleLog_Month'
          AND CONVERT(datetime2(0), prv.value) < @liveCutoff
        ORDER BY prv.boundary_id;
    OPEN live_cursor;
    FETCH NEXT FROM live_cursor INTO @boundary;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @partition = $PARTITION.pf_ExampleLog_Month(@boundary);
        SELECT @rows = ISNULL(SUM(row_count), 0)
        FROM sys.dm_db_partition_stats
        WHERE object_id = OBJECT_ID(N'Inst.ExampleLog') AND index_id IN (0, 1) AND partition_number = @partition;
        IF @rows > 0
        BEGIN
            PRINT CONCAT(N'SWITCH partition ', @partition, N' (', @rows, N' rows) to archive');
            IF @Apply = 1
                ALTER TABLE Inst.ExampleLog SWITCH PARTITION @partition TO Inst.ExampleLog_Archive PARTITION @partition;
        END
        FETCH NEXT FROM live_cursor INTO @boundary;
    END
    CLOSE live_cursor;
    DEALLOCATE live_cursor;

    -- 3. Purge archive months older than the archive window. The partition number is an int built by the procedure, never user text.
    DECLARE arch_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT CONVERT(datetime2(0), prv.value)
        FROM sys.partition_functions AS pf
        INNER JOIN sys.partition_range_values AS prv ON prv.function_id = pf.function_id
        WHERE pf.name = N'pf_ExampleLog_Month'
          AND CONVERT(datetime2(0), prv.value) < @archCutoff
        ORDER BY prv.boundary_id;
    OPEN arch_cursor;
    FETCH NEXT FROM arch_cursor INTO @boundary;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @partition = $PARTITION.pf_ExampleLog_Month(@boundary);
        SELECT @rows = ISNULL(SUM(row_count), 0)
        FROM sys.dm_db_partition_stats
        WHERE object_id = OBJECT_ID(N'Inst.ExampleLog_Archive') AND index_id IN (0, 1) AND partition_number = @partition;
        IF @rows > 0
        BEGIN
            PRINT CONCAT(N'PURGE archive partition ', @partition, N' (', @rows, N' rows)');
            IF @Apply = 1
            BEGIN
                SET @sql = CONCAT(N'TRUNCATE TABLE Inst.ExampleLog_Archive WITH (PARTITIONS (', CONVERT(nvarchar(10), @partition), N'));');
                EXEC sys.sp_executesql @sql;
            END
        END
        FETCH NEXT FROM arch_cursor INTO @boundary;
    END
    CLOSE arch_cursor;
    DEALLOCATE arch_cursor;

    -- 4. Merging the oldest boundaries is optional housekeeping and is left out on purpose. MERGE RANGE acts on the shared
    --    partition function, so it is safe only when both the live and the archive table are empty in that range. Add it here
    --    only after /cdb-test has proved an empty-range check on both tables.
END
GO
