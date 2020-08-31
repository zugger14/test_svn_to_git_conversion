/****** Object:  Table [dbo].[user_defined_deal_fields_template]    Script Date: 01/07/2009 10:10:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
DROP TABLE [dbo].[user_defined_deal_fields_template]
GO

CREATE TABLE [dbo].[user_defined_deal_fields_template](
	[udf_template_id] [int] IDENTITY(1,1) NOT NULL,
	[template_id] [int] NOT NULL,
	[field_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Field_label] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Field_type] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[data_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_required] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sql_string] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_user_defined_deal_fields_template] PRIMARY KEY CLUSTERED 
(
	[udf_template_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[user_defined_deal_fields_template]  WITH CHECK ADD  CONSTRAINT [FK_user_defined_deal_fields_template_source_deal_header_template] FOREIGN KEY([template_id])
REFERENCES [dbo].[source_deal_header_template] ([template_id])