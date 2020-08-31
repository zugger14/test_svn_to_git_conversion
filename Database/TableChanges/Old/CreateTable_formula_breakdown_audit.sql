SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[formula_breakdown_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[formula_breakdown_audit]
	(
		[audit_id]  [INT] NOT NULL,
		[formula_breakdown_id]        [INT] NOT NULL,
		[formula_id]                  [INT] NOT NULL,
		[nested_id]                   [INT] NULL,
		[formula_level]               [INT] NULL,
		[func_name]                   [VARCHAR](100) NULL,
		[arg_no_for_next_func]        [TINYINT] NULL,
		[parent_nested_id]            [INT] NULL,
		[level_func_sno]              [TINYINT] NULL,
		[parent_level_func_sno]       [TINYINT] NULL,
		[arg1]                        [VARCHAR](50) NULL,
		[arg2]                        [VARCHAR](50) NULL,
		[arg3]                        [VARCHAR](50) NULL,
		[arg4]                        [VARCHAR](50) NULL,
		[arg5]                        [VARCHAR](50) NULL,
		[arg6]                        [VARCHAR](50) NULL,
		[arg7]                        [VARCHAR](50) NULL,
		[arg8]                        [VARCHAR](50) NULL,
		[arg9]                        [VARCHAR](50) NULL,
		[arg10]                       [VARCHAR](50) NULL,
		[arg11]                       [VARCHAR](50) NULL,
		[arg12]                       [VARCHAR](50) NULL,
		[eval_value]                  [FLOAT] NULL,
		[create_user]                 [VARCHAR](100) NULL,
		[create_ts]                   [DATETIME] NULL,
		[update_user]                 [VARCHAR](100) NULL,
		[update_ts]                   [DATETIME] NULL,
		[formula_nested_id]           [INT] NULL,
		[user_action]                 VARCHAR(50)
	) 
END
ELSE
BEGIN
    PRINT 'Table formula_breakdown_audit EXISTS'
END


GO






