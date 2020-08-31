/****** Object:  Table [dbo].[maintain_field_template]    Script Date: 09/18/2011 16:05:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[maintain_field_template]') AND type in (N'U'))
DROP TABLE [dbo].[maintain_field_template]
GO

/****** Object:  Table [dbo].[maintain_field_template]    Script Date: 09/18/2011 16:05:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[maintain_field_template](
	[field_template_id] [int] IDENTITY(1,1) NOT NULL,
	[template_name] [varchar](50) NULL,
	[template_description] [varchar](150) NULL,
	[active_inactive] [char](1) NULL,
 CONSTRAINT [PK_MaintainFieldTemplate] PRIMARY KEY CLUSTERED 
(
	[field_template_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


