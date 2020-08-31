USE adiha_cloud
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[system_access_log]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[system_access_log](
		[system_access_log_id] [int] IDENTITY(1,1) NOT NULL,
		[user_login_id] [varchar](50) NULL,
		[access_timestamp] [datetime] NULL,
		[status] [varchar](500) NULL,
	 CONSTRAINT [PK_system_access_log] PRIMARY KEY CLUSTERED 
	(
		[system_access_log_id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END