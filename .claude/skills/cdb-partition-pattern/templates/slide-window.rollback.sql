-- Name: slide-window.rollback.sql
-- Purpose: rollback for the sliding-window procedure template (removes the procedure only)
-- Version: 0.1.0
-- Standard: DBA Automation Engineering Standard v5.0.0 (UNVERIFIED, text not in repo)
-- Author: Your Friendly Neighbourhood DBA
-- Date: 2026-10-24
--
-- Executed only by a wrapper that refuses to run it without -Apply. The tables, partition function and partition scheme
-- are not dropped here: reversing a partitioning change is a restore from the backup taken by the runbook.

DROP PROCEDURE IF EXISTS Inst.usp_ExampleLog_SlideWindow;
GO
