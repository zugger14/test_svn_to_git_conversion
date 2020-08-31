/****** Object:  Table [dbo].[dashboardReportTemplate]    Script Date: 09/14/2009 14:15:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dashboardReportTemplate]') AND type in (N'U'))
DROP TABLE [dbo].[dashboardReportTemplate]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dashboardReportName]') AND type in (N'U'))
DROP TABLE [dbo].[dashboardReportName]
GO
CREATE TABLE [dbo].[dashboardReportName](
	[template_id] [int] NOT NULL,
	[report_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[instance_name] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[report_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_dashboardReportName] PRIMARY KEY CLUSTERED 
(
	[template_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
