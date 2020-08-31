SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[recovery_password_log]') AND TYPE IN (N'U'))
BEGIN
	CREATE TABLE [dbo].[recovery_password_log](
		[recovery_password_log_id] INT IDENTITY(1,1) NOT NULL,
		[request_email_address] VARCHAR(50)  NOT NULL,
		[user_login_id] VARCHAR(50)  NOT NULL,
		[request_date] DATETIME NOT NULL,
		[recovery_password_confirmation_id] VARCHAR(100)  NOT NULL,
		[confirmation_accepted] CHAR(1)  NULL
	 CONSTRAINT [PK_recovery_password_log] PRIMARY KEY CLUSTERED 
	(
		[recovery_password_log_id] ASC
	) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END