-- ============================================================================
-- Object   : [Svr].[usp_SetCollectionLastRun]
-- Schema   : Svr
-- Author   : DBA Engineering
-- Created  : 2024-01-01
-- Version  : 4.1.0
-- Purpose  : Records the timestamp of the most recent successful collection
--            run against a given instance. Called after each successful
--            collection by the PowerShell scripts.
--
-- Parameters:
--   @CollectionType  - The type of collection just completed.
--                      Supported values: 'WaitStats', 'Baseline', 'Inventory'
--   @ServerName      - The server hostname collected from.
--   @InstanceName    - The SQL instance name collected from.
--   @LoadGUID        - Correlation GUID from the calling script run.
--
-- Notes:
--   Non-throwing - unknown ServerName/InstanceName combinations are silently
--   ignored so that a missing registration never kills a collection run.
-- ============================================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [Svr].[usp_SetCollectionLastRun]
    @CollectionType     NVARCHAR(50),
    @ServerName         NVARCHAR(255),
    @InstanceName       NVARCHAR(255),
    @LoadGUID           NVARCHAR(36) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @CollectionType IS NULL OR LEN(LTRIM(RTRIM(@CollectionType))) = 0
        THROW 50001, '@CollectionType is required.', 1;

    IF @ServerName IS NULL OR LEN(LTRIM(RTRIM(@ServerName))) = 0
        THROW 50002, '@ServerName is required.', 1;

    IF @InstanceName IS NULL OR LEN(LTRIM(RTRIM(@InstanceName))) = 0
        THROW 50003, '@InstanceName is required.', 1;

    UPDATE [Svr].[ServerList]
    SET
        WaitStatLastExecDate  = CASE WHEN @CollectionType = 'WaitStats'  THEN SYSDATETIME() ELSE WaitStatLastExecDate  END,
        BaselineLastExecDate  = CASE WHEN @CollectionType = 'Baseline'   THEN SYSDATETIME() ELSE BaselineLastExecDate  END,
        InventoryLastExecDate = CASE WHEN @CollectionType = 'Inventory'  THEN SYSDATETIME() ELSE InventoryLastExecDate END,
        LastLoadGUID          = ISNULL(@LoadGUID, LastLoadGUID),
        LastUpdated           = SYSDATETIME()
    WHERE
        ServerName   = @ServerName
    AND InstanceName = @InstanceName;

    -- Non-throwing: if no rows updated, the server simply wasn't registered
END;
GO
