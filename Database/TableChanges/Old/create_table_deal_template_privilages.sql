SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[deal_template_privilages]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].deal_template_privilages
		(
		[deal_template_privilages_id] INT IDENTITY(1, 1) NOT NULL,
		[user_id] VARCHAR(500) NULL, 
		[role_id] INT NULL,
		[deal_template_id] INT NULL,
		[create_user]    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]      DATETIME NULL DEFAULT GETDATE(),
		[update_user]    VARCHAR(50) NULL,
		[update_ts]      DATETIME NULL
		)
END
ELSE
BEGIN
    PRINT 'Table table_name EXISTS'
END

GO