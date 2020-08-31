SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[message_board_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[message_board_audit] (
    	[message_board_audit_id] INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[message_id] [int] NOT NULL,
		[user_login_id] [varchar](50) NOT NULL,
		[source] [varchar](50) NOT NULL,
		[description] [varchar](8000) NOT NULL,
		[url_desc] [varchar](8000) NULL,
		[url] [varchar](500) NULL,
		[type] [char](1) NOT NULL,
		[job_name] [varchar](100) NULL,
		[as_of_date] [datetime] NULL,
		[create_ts] [datetime] NULL,
		[create_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[process_id] [varchar](50) NULL,
		[process_type] [char](1) NULL,
		[reminderDate] [varchar](8000) NULL,
		[source_id] [varchar](100) NULL,
		[delActive] [char](1) NULL,
		[message_attachment] [varchar](1000) NULL,
		[is_alert] [char](1) NULL,
		[is_alert_processed] [char](1) NULL,
		[user_action] VARCHAR(50) NULL
    )
END
ELSE
BEGIN
    PRINT 'Table message_board_audit EXISTS'
END
 
GO
