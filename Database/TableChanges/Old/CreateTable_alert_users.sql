SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[alert_users]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[alert_users](
		[alert_users_id] INT IDENTITY NOT NULL,
		[alert_sql_id] [int] NOT NULL, --FK to sql alert
		[role_user] [varchar] (1) NOT NULL, --'r' for role and 'u' for users
		[role_id] [int] NULL, -- FK to user application_roles.role_id
		[user_login_id] [varchar] (50) NULL, -- FK to user login id
		[create_ts] [datetime] NULL,
		[create_user] [varchar] (50) NULL
		
	) ON [PRIMARY]
END
ELSE
BEGIN
	PRINT 'Table alert_users EXISTS'
END
GO
SET ANSI_PADDING OFF
GO

