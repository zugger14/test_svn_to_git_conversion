SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[alert_workflows]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[alert_workflows](
		[alert_workflows_id] INT IDENTITY NOT NULL,
		[alert_sql_id] [int] NOT NULL, --FK to sql logic
		[workflow_id] [int] NOT NULL, --fk TO workflow activity
		[create_ts] [datetime] NULL,
		[create_user] [varchar] (50) NULL
		
	) ON [PRIMARY]
END
ELSE
BEGIN
	PRINT 'Table alert_workflows EXISTS'
END
GO
SET ANSI_PADDING OFF
GO

