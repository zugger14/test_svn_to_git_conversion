/****** Object:  Table [dbo].[maintain_field_template_group]    Script Date: 09/18/2011 16:05:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[maintain_field_template_group]') AND type in (N'U'))
DROP TABLE [dbo].[maintain_field_template_group]
GO

/****** Object:  Table [dbo].[maintain_field_template_group]    Script Date: 09/18/2011 16:05:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[maintain_field_template_group](
	[field_group_id] [int] IDENTITY(1,1) NOT NULL,
	[field_template_id] [int] NULL,
	[group_name] [varchar](150) NULL,
	[seq_no] [int] NULL,
 CONSTRAINT [PK_MaintainFieldTemplateGroup] PRIMARY KEY CLUSTERED 
(
	[field_group_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


