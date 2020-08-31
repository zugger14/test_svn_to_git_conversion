SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

/****** Object:  Table [dbo].[trm_sap_status_log_header]    Script Date: 07/12/2011 19:10:51 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[trm_sap_status_log_header]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[trm_sap_status_log_header](
		[header_status_id] [int] IDENTITY(1,1) NOT NULL,
		[process_id] [varchar](100) NOT NULL,
		[correlation_id] [varchar](100) NULL,
		[as_of_date] [datetime] NULL,
		[message_sent_timestamp] [datetime] NULL,
		[message_received_timestamp] [datetime] NULL,
		[status] [varchar](10) NULL,
		[message] [varchar](500) NULL,
		[create_ts] [datetime] NULL,
		[create_user] [varchar](50) NULL,
	 CONSTRAINT [PK_trm_sap_status_log] PRIMARY KEY CLUSTERED 
	(
		[header_status_id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

SET ANSI_PADDING OFF
GO


