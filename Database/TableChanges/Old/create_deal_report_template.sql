/****** Object:  Table [dbo].[deal_report_template]    Script Date: 02/09/2010 16:36:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[deal_report_template]') AND type in (N'U'))
DROP TABLE [dbo].[deal_report_template]
GO
/****** Object:  Table [dbo].[deal_report_template]    Script Date: 02/09/2010 16:36:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[deal_report_template](
	[template_id] [int] IDENTITY(100,1) NOT NULL,
	[template_name] [varchar](100) NOT NULL,
	[template_type] [char](5) NULL,
	[filename] [varchar](100) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_deal_report_template] PRIMARY KEY CLUSTERED 
(
	[template_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF