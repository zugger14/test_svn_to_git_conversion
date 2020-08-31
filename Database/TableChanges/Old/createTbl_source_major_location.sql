/****** Object:  Table [dbo].[source_major_location]    Script Date: 01/07/2009 12:40:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_major_location]') AND type in (N'U'))
DROP TABLE [dbo].[source_major_location]

Go
/****** Object:  Table [dbo].[source_major_location]    Script Date: 01/07/2009 12:39:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_major_location](
	[source_major_location_ID] [int] IDENTITY(1,1) NOT NULL,
	[source_system_id] [int] NOT NULL,
	[major_location_ID] [varchar](100) NOT NULL,
	[location_name] [varchar](100) NOT NULL,
	[location_description] [varchar](255) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_source_major_location] PRIMARY KEY CLUSTERED 
(
	[source_major_location_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF