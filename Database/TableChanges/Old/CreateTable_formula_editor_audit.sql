SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO


IF OBJECT_ID(N'[dbo].[formula_editor_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[formula_editor_audit]
	(
		[audit_id]         [INT] NOT NULL,
		[formula_id]       [INT] NOT NULL,
		[formula]          [VARCHAR](8000) NULL,
		[formula_type]     [VARCHAR](1) NULL,
		[create_user]      [VARCHAR](50) NULL,
		[create_ts]        [DATETIME] NULL,
		[update_user]      [VARCHAR](50) NULL,
		[update_ts]        [DATETIME] NULL,
		[formula_name]     [VARCHAR](200) NULL,
		[system_defined]   [CHAR](1) NULL,
		[static_value_id]  [INT] NULL,
		[istemplate]       [CHAR](1) NULL,
		[user_action]      VARCHAR(50)
	)
END
ELSE
BEGIN
    PRINT 'Table formula_editor_audit EXISTS'
END

GO

SET ANSI_PADDING OFF
GO



