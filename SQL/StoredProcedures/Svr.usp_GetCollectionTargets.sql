-- ============================================================================
-- Object   : [Svr].[usp_GetCollectionTargets]
-- Schema   : Svr
-- Author   : DBA Engineering
-- Created  : 2024-01-01
-- Version  : 4.1.0
-- Purpose  : Returns the list of SQL Server instances to collect data from.
--            Replaces all inline SELECT queries from [Svr].[ServerList] that
--            were previously embedded in PowerShell collection scripts.
--
-- Parameters:
--   @CollectionType  - Filter by collection flag column.
--                      Supported values: 'WaitStats', 'Baseline', 'Inventory'
--   @RunLocally      - 1 = restrict to @LocalServerName only (MSX/TSX jobs)
--   @LocalServerName - The hostname to filter on when @RunLocally = 1
--
-- Result set: ServerName, InstanceName
-- ============================================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [Svr].[usp_GetCollectionTargets]
    @CollectionType     NVARCHAR(50),
    @RunLocally         BIT           = 0,
    @LocalServerName    NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @CollectionType IS NULL OR LEN(LTRIM(RTRIM(@CollectionType))) = 0
        THROW 50001, '@CollectionType is required.', 1;

    IF @RunLocally = 1 AND (@LocalServerName IS NULL OR LEN(LTRIM(RTRIM(@LocalServerName))) = 0)
        THROW 50002, '@LocalServerName is required when @RunLocally = 1.', 1;

    SELECT DISTINCT
        sl.ServerName,
        sl.InstanceName
    FROM [Svr].[ServerList] AS sl
    WHERE sl.Active       = 1
    AND   (
              (@CollectionType = 'WaitStats'  AND sl.Baseline    = 1)
           OR (@CollectionType = 'Baseline'   AND sl.Baseline    = 1)
           OR (@CollectionType = 'Inventory'  AND sl.Active      = 1)
          )
    AND   (@RunLocally = 0 OR sl.ServerName = @LocalServerName)
    ORDER BY
        sl.ServerName,
        sl.InstanceName;
END;
GO
