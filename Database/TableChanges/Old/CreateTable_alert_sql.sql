SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

-- This table defines SQL Logic saved by sql_id
IF OBJECT_ID(N'[dbo].[alert_sql]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[alert_sql](
		[alert_sql_id] INT IDENTITY NOT NULL,
		[sql_id] [int] NOT NULL, --FK to sql logic
		[workflow_only] varchar(1) NOT NULL, --if 'y' then only workflows no messaging...
		[message] VARCHAR(500) NULL,
		[notification_type] INT NOT NULL, --message board vs. email static data value
		[create_ts] [datetime] NULL,
		[create_user] [varchar] (50) NULL
		
	) ON [PRIMARY]
END
ELSE
BEGIN
	PRINT 'Table alert_sql EXISTS'
END
GO

SET ANSI_PADDING OFF
GO

