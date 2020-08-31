/****** Object:  Table [dbo].[var_time_bucket_mapping]    Script Date: 01/06/2009 15:11:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[var_time_bucket_mapping](
	[map_id] [int] IDENTITY(1,1) NOT NULL,
	[effective_date] [datetime] NOT NULL,
	[from_no_of_months] [int] NULL,
	[to_no_of_months] [int] NULL,
	[map_no_of_months] [int] NULL,
	[curve_id] [int] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF