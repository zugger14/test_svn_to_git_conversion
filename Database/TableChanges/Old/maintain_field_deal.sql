
/****** Object:  Table [dbo].[maintain_field_deal]    Script Date: 09/18/2011 16:03:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[maintain_field_deal]') AND type in (N'U'))
DROP TABLE [dbo].[maintain_field_deal]
GO


/****** Object:  Table [dbo].[maintain_field_deal]    Script Date: 09/18/2011 16:03:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[maintain_field_deal](
	[field_id] [int] IDENTITY(1,1) NOT NULL,
	[farrms_field_id] [varchar](50) NULL,
	[default_label] [varchar](150) NULL,
	[field_type] [char](1) NULL,
	[data_type] [varchar](50) NULL,
	[default_validation] [int] NULL,
	[header_detail] [char](1) NULL,
	[system_required] [char](1) NULL,
 CONSTRAINT [PK_maintain_field_deal] PRIMARY KEY CLUSTERED 
(
	[field_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


