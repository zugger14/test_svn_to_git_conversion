
/****** Object:  Table [dbo].[maintain_field_template_detail]    Script Date: 09/18/2011 16:04:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[maintain_field_template_detail]') AND type in (N'U'))
DROP TABLE [dbo].[maintain_field_template_detail]
GO


/****** Object:  Table [dbo].[maintain_field_template_detail]    Script Date: 09/18/2011 16:04:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[maintain_field_template_detail](
	[field_template_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[field_template_id] [int] NULL,
	[field_group_id] [int] NULL,
	[field_id] [int] NULL,
	[seq_no] [int] NULL,
	[enable_disable] [char](1) NULL,
	[insert_required] [char](1) NULL,
	[field_caption] [varchar](50) NULL,
	[default_value] [varchar](150) NULL,
	[udf_of_system] [char](1) NULL,
	[min_value] [float] NULL,
	[max_value] [float] NULL,
	[validation_id] [int] NULL,
 CONSTRAINT [PK_MaintainFieldTemplateDetail] PRIMARY KEY CLUSTERED 
(
	[field_template_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


