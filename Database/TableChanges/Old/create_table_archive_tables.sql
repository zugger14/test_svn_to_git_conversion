/****** Object:  Table [dbo].[archive_tables]    Script Date: 12/24/2008 09:56:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

DROP TABLE [dbo].[archive_tables]
GO

CREATE TABLE [dbo].[archive_tables](
	[tbl_name] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[datefield] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_archive_tables] PRIMARY KEY CLUSTERED 
(
	[tbl_name] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF