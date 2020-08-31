SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[alert_output_status]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[alert_output_status](
	[alert_id] [int] IDENTITY(1,1) NOT NULL,
	[alert_sql_id] [int] NOT NULL,  ---FK to alert_sql
	[process_id] [varchar] (150) NOT NULL, 
	[published] [varchar](1) NOT NULL, --'y' for Yes or 'n' for no
	[message] VARCHAR(500) NULL, --message that overrides the other message
	[trader_user_id] VARCHAR(50) NULL, --provision to send notification to trader automatically
	[current_user_id] VARCHAR(50) NULL, --provision to send the current user running process
	[create_ts] [datetime] NULL,
	[create_user] [varchar] (50) NULL
	
) ON [PRIMARY]
END
ELSE
BEGIN
	PRINT 'Table alert_output_status EXISTS'
END
GO
SET ANSI_PADDING OFF
GO
