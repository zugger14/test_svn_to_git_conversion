
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[recovery_password_log](
	[recovery_password_log_id] [int] IDENTITY(1,1) NOT NULL,
	[request_email_address] [varchar](50)  NOT NULL,
	[user_login_id] [varchar](50)  NOT NULL,
	[request_date] [datetime] NOT NULL,
	[recovery_password_confirmation_id] [varchar](100)  NOT NULL,
	[confirmation_accepted] [char](1)  NULL,
	[password_suggested] [varchar](5)  NULL,
 CONSTRAINT [PK_recovery_password_log] PRIMARY KEY CLUSTERED 
(
	[recovery_password_log_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]



