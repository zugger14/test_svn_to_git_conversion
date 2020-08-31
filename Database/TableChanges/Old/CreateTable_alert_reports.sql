SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[alert_reports]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[alert_reports](
	[alert_reports_id] INT IDENTITY NOT NULL,
	[alert_sql_id] [int] NOT NULL, --FK to sql logic
	[report_writer] [varchar] (1) NOT NULL, -- 'y' for yes and 'n' for no
	[report_writer_id] [int] NULL, --unqiue report writer report id if report_writer='y'
	[report_param] [varchar](1000) NULL, -- required report parameter for report writer report
	[report_desc] [varchar] (500) NULL, 
	[table_prefix] [varchar] (50) NULL, --adiha_proces.dbo.
	[table_postfix] [varchar] (50) NULL, -- temp_cmd 
	[create_ts] [datetime] NULL,
	[create_user] [varchar] (50) NULL
		
) ON [PRIMARY]
END
ELSE
BEGIN
	PRINT 'Table alert_reports EXISTS'
END
GO

SET ANSI_PADDING OFF
GO

