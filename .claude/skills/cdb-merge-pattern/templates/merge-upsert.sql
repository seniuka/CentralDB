-- Name: merge-upsert.sql
-- Purpose: template for the reporting-server side of the management-to-reporting merge (watermark table, staging table, target table, merge procedure)
-- Version: 0.1.0
-- Standard: DBA Automation Engineering Standard v5.0.0 (UNVERIFIED, text not in repo)
-- Author: Your Friendly Neighbourhood DBA
-- Date: 2026-10-24
--
-- Runs on the reporting server (Tier 2, SQL Server 2025 AG pair, connect through the listener).
-- Schemas stg, ops and the target schema are DECISIONs: new schemas need an ADR before use. Names here are placeholders.
-- Uses UPDATE and INSERT, not MERGE: the MERGE statement has no lock-after-qualification under optimized locking (VERIFIED, Microsoft Learn,
-- 2026-10-24) and has a history of edge-case bugs (UNVERIFIED claim, not checked this session).
-- Syntax parse-checked offline with ScriptDom. Not executed on any instance: runtime behavior is UNVERIFIED until /cdb-test runs it on a non-production target.

IF OBJECT_ID(N'ops.MergeWatermark', N'U') IS NULL
BEGIN
    CREATE TABLE ops.MergeWatermark
    (
        SourceServer    sysname          NOT NULL,
        Domain          sysname          NOT NULL,
        LastModifiedUtc datetime2(3)     NOT NULL,
        LastRunId       uniqueidentifier NULL,
        UpdatedUtc      datetime2(3)     NOT NULL CONSTRAINT DF_MergeWatermark_UpdatedUtc DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_MergeWatermark PRIMARY KEY CLUSTERED (SourceServer, Domain)
    );
END
GO

IF OBJECT_ID(N'stg.ExampleDomain_In', N'U') IS NULL
BEGIN
    CREATE TABLE stg.ExampleDomain_In
    (
        RunId          uniqueidentifier NOT NULL,
        SourceServer   sysname          NOT NULL,
        InstanceKey    nvarchar(256)    NOT NULL,
        ModifiedAtUtc  datetime2(3)     NOT NULL,
        IsDeleted      bit              NOT NULL,
        ProductVersion nvarchar(128)    NULL,
        Edition        nvarchar(128)    NULL,
        CONSTRAINT PK_ExampleDomain_In PRIMARY KEY CLUSTERED (RunId, SourceServer, InstanceKey)
    );
END
GO

IF OBJECT_ID(N'Inst.ExampleDomain', N'U') IS NULL
BEGIN
    CREATE TABLE Inst.ExampleDomain
    (
        SourceServer   sysname       NOT NULL,
        InstanceKey    nvarchar(256) NOT NULL,
        ModifiedAtUtc  datetime2(3)  NOT NULL,
        IsDeleted      bit           NOT NULL,
        ProductVersion nvarchar(128) NULL,
        Edition        nvarchar(128) NULL,
        CONSTRAINT PK_ExampleDomain PRIMARY KEY CLUSTERED (SourceServer, InstanceKey)
    );
END
GO

CREATE OR ALTER PROCEDURE ops.usp_ExampleDomain_Merge
    @SourceServer sysname,
    @RunId        uniqueidentifier,
    @Apply        bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @staged      bigint;
    DECLARE @updated     bigint = 0;
    DECLARE @inserted    bigint = 0;
    DECLARE @reconciled  bigint;
    DECLARE @maxModified datetime2(3);

    SELECT @staged = COUNT_BIG(*), @maxModified = MAX(ModifiedAtUtc)
    FROM stg.ExampleDomain_In
    WHERE RunId = @RunId AND SourceServer = @SourceServer;

    IF @Apply = 0
    BEGIN
        -- Report-only: say what would happen and change nothing.
        SELECT
            @staged AS StagedRows,
            (SELECT COUNT_BIG(*)
             FROM stg.ExampleDomain_In AS s
             INNER JOIN Inst.ExampleDomain AS t ON t.SourceServer = s.SourceServer AND t.InstanceKey = s.InstanceKey
             WHERE s.RunId = @RunId AND s.SourceServer = @SourceServer AND s.ModifiedAtUtc > t.ModifiedAtUtc) AS WouldUpdate,
            (SELECT COUNT_BIG(*)
             FROM stg.ExampleDomain_In AS s
             WHERE s.RunId = @RunId AND s.SourceServer = @SourceServer
               AND NOT EXISTS (SELECT 1 FROM Inst.ExampleDomain AS t WHERE t.SourceServer = s.SourceServer AND t.InstanceKey = s.InstanceKey)) AS WouldInsert;
        RETURN;
    END

    IF @staged = 0
        RETURN;

    BEGIN TRANSACTION;

    UPDATE t
    SET t.ModifiedAtUtc  = s.ModifiedAtUtc,
        t.IsDeleted      = s.IsDeleted,
        t.ProductVersion = s.ProductVersion,
        t.Edition        = s.Edition
    FROM Inst.ExampleDomain AS t
    INNER JOIN stg.ExampleDomain_In AS s ON s.SourceServer = t.SourceServer AND s.InstanceKey = t.InstanceKey
    WHERE s.RunId = @RunId AND s.SourceServer = @SourceServer AND s.ModifiedAtUtc > t.ModifiedAtUtc;
    SET @updated = @@ROWCOUNT;

    INSERT INTO Inst.ExampleDomain (SourceServer, InstanceKey, ModifiedAtUtc, IsDeleted, ProductVersion, Edition)
    SELECT s.SourceServer, s.InstanceKey, s.ModifiedAtUtc, s.IsDeleted, s.ProductVersion, s.Edition
    FROM stg.ExampleDomain_In AS s
    WHERE s.RunId = @RunId AND s.SourceServer = @SourceServer
      AND NOT EXISTS (SELECT 1 FROM Inst.ExampleDomain AS t WHERE t.SourceServer = s.SourceServer AND t.InstanceKey = s.InstanceKey);
    SET @inserted = @@ROWCOUNT;

    -- Reconciliation: every staged row must now be present in the target at the same version or a newer one.
    SELECT @reconciled = COUNT_BIG(*)
    FROM stg.ExampleDomain_In AS s
    INNER JOIN Inst.ExampleDomain AS t ON t.SourceServer = s.SourceServer AND t.InstanceKey = s.InstanceKey
    WHERE s.RunId = @RunId AND s.SourceServer = @SourceServer AND t.ModifiedAtUtc >= s.ModifiedAtUtc;

    IF @reconciled <> @staged
        THROW 50010, N'Reconciliation failed: staged rows are not all present in the target. The transaction is rolled back and the watermark is unchanged.', 1;

    UPDATE ops.MergeWatermark
    SET LastModifiedUtc = @maxModified, LastRunId = @RunId, UpdatedUtc = SYSUTCDATETIME()
    WHERE SourceServer = @SourceServer AND Domain = N'ExampleDomain' AND LastModifiedUtc < @maxModified;

    IF NOT EXISTS (SELECT 1 FROM ops.MergeWatermark WHERE SourceServer = @SourceServer AND Domain = N'ExampleDomain')
        INSERT INTO ops.MergeWatermark (SourceServer, Domain, LastModifiedUtc, LastRunId)
        VALUES (@SourceServer, N'ExampleDomain', @maxModified, @RunId);

    -- Remove this run's staged rows. The predicate is the run and the source, never the whole table.
    DELETE FROM stg.ExampleDomain_In
    WHERE RunId = @RunId AND SourceServer = @SourceServer;

    COMMIT TRANSACTION;

    SELECT @staged AS StagedRows, @updated AS UpdatedRows, @inserted AS InsertedRows, @reconciled AS ReconciledRows;
END
GO
