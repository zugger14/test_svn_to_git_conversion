SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[formula_nested_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[formula_nested_audit]
	(
		[audit_id]  [INT] NOT NULL,
		[id]                       [INT] NOT NULL,
		[sequence_order]           [INT] NOT NULL,
		[description1]             [VARCHAR](200) NULL,
		[description2]             [VARCHAR](200) NULL,
		[formula_id]               [INT] NOT NULL,
		[formula_group_id]         [INT] NOT NULL,
		[granularity]              [INT] NULL,
		[include_item]             [CHAR](1) NULL,
		[show_value_id]            [INT] NULL,
		[uom_id]                   [INT] NULL,
		[rate_id]                  [INT] NULL,
		[total_id]                 [INT] NULL,
		[create_user]              [VARCHAR](50) NULL,
		[create_ts]                [DATETIME] NULL,
		[update_user]              [VARCHAR](50) NULL,
		[update_ts]                [DATETIME] NULL,
		[time_bucket_formula_id]   [INT] NULL,
		[user_action]              VARCHAR(50)
	) 
END
ELSE
BEGIN
    PRINT 'Table formula_nested_audit EXISTS'
END

GO
