
/****** Object:  Table [dbo].[Contract_report_template]    Script Date: 12/10/2008 17:41:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Contract_report_template](
	[template_id] [int] IDENTITY(1,1) NOT NULL,
	[template_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[template_desc] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sub_id] [int] NULL,
	[filename] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_Contract_report_template] PRIMARY KEY CLUSTERED 
(
	[template_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF