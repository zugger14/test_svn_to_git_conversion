/****** Object:  Table [dbo].[ownership_details]    Script Date: 04/08/2010 16:37:00 ******/

/****** Object:  Table [dbo].[ownership_details]    Script Date: 04/08/2010 16:36:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ownership_details_wellhead_details]') AND parent_object_id = OBJECT_ID(N'[dbo].[ownership_details]'))
ALTER TABLE [dbo].[ownership_details] DROP CONSTRAINT [FK_ownership_details_wellhead_details]
GO

/****** Object:  Table [dbo].[ownership_details]    Script Date: 04/08/2010 17:32:34 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ownership_details]') AND type in (N'U'))

CREATE TABLE [dbo].[ownership_details](
	[owner_id] [int] IDENTITY(1,1) NOT NULL,
	[owner] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ownership_interest] [int] NULL,
	[effective_date] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[short_id] [varchar](20) NOT NULL,
 CONSTRAINT [PK_ownership_details] PRIMARY KEY CLUSTERED 
(
	[owner_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ownership_details]  WITH CHECK ADD  CONSTRAINT [FK_ownership_details_wellhead_details] FOREIGN KEY([short_id])
REFERENCES [dbo].[wellhead_details] ([short_id])