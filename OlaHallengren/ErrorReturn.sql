SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ErrorReturn]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[ErrorReturn] AS'
END
GO
ALTER PROCEDURE [dbo].[ErrorReturn]
@ErrorMessage nvarchar(2048) = NULL,
@ErrorSeverity int = 16,
@ErrorState int = 1
WITH RECOMPILE
AS
BEGIN

  ----------------------------------------------------------------------------------------------------
  --// Source:  https://ola.hallengren.com                                                        //--
  --// License: https://ola.hallengren.com/license.html                                           //--
  --// GitHub:  https://github.com/olahallengren/sql-server-maintenance-solution                  //--
  --// Version: 2020-11-09 15:15:00                                                               //--
  ----------------------------------------------------------------------------------------------------

  SET NOCOUNT ON
  DECLARE @@ErrorMessage nvarchar(2048) = @ErrorMessage
  EXEC xp_logevent 65535, @@ErrorMessage, error

END
