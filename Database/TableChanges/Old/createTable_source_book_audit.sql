SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[source_book_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[source_book_audit]
    (
    	[audit_id]                          [INT] IDENTITY(1, 1) NOT NULL,
    	[source_book_id]                    [INT] NOT NULL,
    	[source_system_id]                  [INT] NOT NULL,
    	[source_system_book_id]             [VARCHAR](50) NOT NULL,
    	[source_system_book_type_value_id]  [INT] NOT NULL,
    	[source_book_name]                  [VARCHAR](50) NOT NULL,
    	[source_book_desc]                  [VARCHAR](100) NULL,
    	[source_parent_book_id]             [VARCHAR](50) NULL,
    	[source_parent_type]                [VARCHAR](100) NULL,
    	[create_user]                       [VARCHAR](50) NULL, --DEFAULT dbo.FNADBUser(),
    	[create_ts]                         [DATETIME] NULL,-- DEFAULT GETDATE(),
    	[update_user]                       [VARCHAR](50) NULL,
    	[update_ts]                         [DATETIME] NULL,
    	[user_action]                       [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table source_book_audit EXISTS'
END

GO

