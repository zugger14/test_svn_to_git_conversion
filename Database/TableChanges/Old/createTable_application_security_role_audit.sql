SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[application_security_role_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[application_security_role_audit]
    (
    	[audit_id]               [INT] IDENTITY(1, 1) NOT NULL,
    	[role_id]                [INT] NOT NULL,
    	[role_name]              [VARCHAR](50) NOT NULL,
    	[role_description]       [VARCHAR](250) NULL,
    	[role_type_value_id]     [INT] NOT NULL,
    	[process_map_file_name]  [VARCHAR](1000) NULL,
    	[create_user]            [VARCHAR](50) NULL,
    	[create_ts]              [DATETIME] NULL,
    	[update_user]            [VARCHAR](50) NULL,
    	[update_ts]              [DATETIME] NULL,
    	[user_action] [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table application_security_role_audit EXISTS'
END

GO

