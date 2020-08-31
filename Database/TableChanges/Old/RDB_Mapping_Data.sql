/****** Object:  Table [dbo].[RDB_Mapping_Data]    Script Date: 07/18/2011 23:27:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RDB_Mapping_Data]') AND type in (N'U'))
DROP TABLE [dbo].[RDB_Mapping_Data]
GO

/****** Object:  Table [dbo].[RDB_Mapping_Data]    Script Date: 07/18/2011 23:27:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RDB_Mapping_Data](
	[rdb_map_id] [int] IDENTITY(1,1) NOT NULL,
	[map_value_id] [int] NULL,
	[rdb_output_value] [varchar](150) NULL,
	[map_value_type] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


