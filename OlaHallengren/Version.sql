SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Version]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Version](
  [VersionID] [int] IDENTITY(1,1) NOT NULL,
  [VersionDate] [datetime] NULL,
 CONSTRAINT [PK_Version] PRIMARY KEY CLUSTERED
(
  [VersionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
END
GO
IF (SELECT COUNT(*) FROM [dbo].[Version]) > 0
BEGIN
	UPDATE [dbo].[Version] SET VersionDate = '2018-06-27 20:44:12' WHERE VersionDate is not null or VersionDate != '2018-06-27 20:44:12'
END
ELSE
BEGIN
	INSERT INTO [dbo].[Version] (VersionDate) VALUES ('2018-06-27 20:44:12')
END
