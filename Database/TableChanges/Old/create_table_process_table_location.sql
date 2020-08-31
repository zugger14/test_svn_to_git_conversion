/****** Object:  Table [dbo].[process_table_location]    Script Date: 12/02/2008 15:33:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

/****** Object:  Table [dbo].[process_table_location]    Script Date: 12/02/2008 15:34:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[process_table_location]') AND type in (N'U'))
DROP TABLE [dbo].[process_table_location]
GO

CREATE TABLE [dbo].[process_table_location](
	[RECID] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NULL,
	[prefix_location_table] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dbase_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tbl_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_process_table_location] PRIMARY KEY CLUSTERED 
(
	[RECID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF