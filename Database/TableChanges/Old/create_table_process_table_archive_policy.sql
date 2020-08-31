/****** Object:  Table [dbo].[process_table_archive_policy]    Script Date: 12/02/2008 15:29:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[process_table_archive_policy]') AND type in (N'U'))
DROP TABLE [dbo].[process_table_archive_policy]
GO

CREATE TABLE [dbo].[process_table_archive_policy](
	[RECID] [int] IDENTITY(1,1) NOT NULL,
	[tbl_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prefix_location_table] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[upto_month] [int] NULL,
	[dbase_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_process_table_archive_policy] PRIMARY KEY CLUSTERED 
(
	[RECID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF