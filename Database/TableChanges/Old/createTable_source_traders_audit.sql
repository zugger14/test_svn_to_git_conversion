SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[source_traders_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[source_traders_audit]
    (
    	[audit_id]          [INT] IDENTITY(1, 1) NOT NULL,
    	[source_trader_id]  [int] NOT NULL,
    	[source_system_id]  [int] NOT NULL,
    	[trader_id]         [varchar](50) NOT NULL,
    	[trader_name]       [varchar](100) NULL,
    	[trader_desc]       [varchar](100) NULL,
    	[create_user]       [varchar](50) NULL,
    	[create_ts]         [datetime] NULL,
    	[update_user]       [varchar](50) NULL,
    	[update_ts]         [datetime] NULL,
    	[user_login_id]     [varchar](50) NULL,
    	[user_action]       [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table source_traders_audit EXISTS'
END

GO

