/****** Object:  Table [dbo].[publish_activity_table]    Script Date: 04/12/2009 20:33:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[publish_activity_table]') AND type in (N'U'))
DROP TABLE [dbo].[publish_activity_table]
/****** Object:  Table [dbo].[publish_activity_table]    Script Date: 04/12/2009 20:33:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[publish_activity_table](
	[publish_table_id] [int] IDENTITY(1,1) NOT NULL,
	[table_name] [nvarchar](50) NULL,
	[table_alias] [nvarchar](50) NULL,
	[value_column] [nvarchar](50) NULL,
	[label_column] [nvarchar](50) NULL,
 CONSTRAINT [PK_publish_activity_table] PRIMARY KEY CLUSTERED 
(
	[publish_table_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
