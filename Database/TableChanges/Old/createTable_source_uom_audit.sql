SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[source_uom_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[source_uom_audit]
    (
    	[audit_id]          [INT] IDENTITY(1, 1) NOT NULL,
    	[source_uom_id]     [INT] NOT NULL,
    	[source_system_id]  [INT] NOT NULL,
    	[uom_id]            [VARCHAR](50) NOT NULL,
    	[uom_name]          [VARCHAR](100) NULL,
    	[uom_desc]          [VARCHAR](250) NULL,
    	[create_user]       [VARCHAR](50) NULL,
    	[create_ts]         [DATETIME] NULL,
    	[update_user]       [VARCHAR](50) NULL,
    	[update_ts]         [DATETIME] NULL,
    	[user_action]       [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table source_uom_audit EXISTS'
END

GO

