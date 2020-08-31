
/****** Object:  Table [dbo].[recorder_generator_map_submeter]    Script Date: 12/11/2008 16:31:11 Generator:Bikash Subba******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[recorder_generator_map_submeter](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[generator_id] [int] NOT NULL,
	[recorderid] [varchar](100) NOT NULL,
	[allocation_per] [float] NULL,
	[from_vol] [float] NULL,
	[to_vol] [float] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_recorder_generator_map_submeter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF