/****** Object:  Table [dbo].[user_defined_deal_fields]    Script Date: 01/07/2009 10:10:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
DROP TABLE [dbo].[user_defined_deal_fields]
GO

CREATE TABLE [dbo].[user_defined_deal_fields](
	[udf_deal_id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NULL,
	[udf_template_id] [int] NULL,
	[udf_value] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_user_defined_deal_fields] PRIMARY KEY CLUSTERED 
(
	[udf_deal_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[user_defined_deal_fields]  WITH CHECK ADD  CONSTRAINT [FK_user_defined_deal_fields_source_deal_header] FOREIGN KEY([source_deal_header_id])
REFERENCES [dbo].[source_deal_header] ([source_deal_header_id])
GO
ALTER TABLE [dbo].[user_defined_deal_fields]  WITH CHECK ADD  CONSTRAINT [FK_user_defined_deal_fields_user_defined_deal_fields_template] FOREIGN KEY([udf_template_id])
REFERENCES [dbo].[user_defined_deal_fields_template] ([udf_template_id])