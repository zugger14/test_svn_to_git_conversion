SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[portfolio_hierarchy_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[portfolio_hierarchy_audit]
    (
    	[audit_id]              [INT] IDENTITY(1, 1) NOT NULL,
    	[entity_id]             [INT] NOT NULL,
    	[entity_name]           [VARCHAR](100) NOT NULL,
    	[entity_type_value_id]  [INT] NOT NULL,
    	[hierarchy_level]       [INT] NOT NULL,
    	[parent_entity_id]      [INT] NULL,
    	[create_user]           [VARCHAR](50) NULL,
    	[create_ts]             [DATETIME] NULL,
    	[update_user]           [VARCHAR](50) NULL,
    	[update_ts]             [DATETIME] NULL,
    	[user_action]           [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table portfolio_hierarchy_audit EXISTS'
END

GO

