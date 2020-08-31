
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[user_application_log](
	[user_application_log_id] [int] IDENTITY(1,1) NOT NULL,
 	[user_login_id] [varchar](50)  NULL,
	[function_id] [int] NULL,
	[function_name] [varchar](100) NULL,
	[instance_name] [varchar](100)  NULL,
	[parameter_name] [varchar](5)  NULL,
	[log_date] Datetime NULL
 CONSTRAINT [PK_user_application_log] PRIMARY KEY CLUSTERED 
(
	[user_application_log_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]



