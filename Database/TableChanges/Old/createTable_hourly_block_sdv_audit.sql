SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[hourly_block_sdv_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[hourly_block_sdv_audit]
    (
    	[audit_id]       [INT] IDENTITY(1, 1) NOT NULL,
    	[value_id]       [INT] NOT NULL,
    	[type_id]        [INT] NOT NULL,
    	[code]           [VARCHAR](500) NULL,
    	[description]    [VARCHAR](500) NULL,
    	[entity_id]      [INT] NULL,
    	[xref_value_id]  [VARCHAR](50) NULL,
    	[xref_value]     [VARCHAR](250) NULL,
    	[category_id]    [INT] NULL,
    	[create_user]    [VARCHAR](50) NULL,
    	[create_ts]      [DATETIME] NULL,
    	[update_user]    [VARCHAR](50) NULL,
    	[update_ts]      [DATETIME] NULL,
    	[user_action]    [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table hourly_block_sdv_audit EXISTS'
END

GO

