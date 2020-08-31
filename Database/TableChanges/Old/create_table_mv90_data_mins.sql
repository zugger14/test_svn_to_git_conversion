/****** Object:  Table [dbo].[mv90_data_mins]    Script Date: 12/16/2008 17:21:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
DROP TABLE [dbo].[mv90_data_mins]
go

CREATE TABLE [dbo].[mv90_data_mins](
	[recorderid] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[channel] [int] NULL,
	[prod_date] [datetime] NULL,
	[Hr1_15] [float] NULL,
	[Hr1_30] [float] NULL,
	[Hr1_45] [float] NULL,
	[Hr1_60] [float] NULL,
	[Hr2_15] [float] NULL,
	[Hr2_30] [float] NULL,
	[Hr2_45] [float] NULL,
	[Hr2_60] [float] NULL,
	[Hr3_15] [float] NULL,
	[Hr3_30] [float] NULL,
	[Hr3_45] [float] NULL,
	[Hr3_60] [float] NULL,
	[Hr4_15] [float] NULL,
	[Hr4_30] [float] NULL,
	[Hr4_45] [float] NULL,
	[Hr4_60] [float] NULL,
	[Hr5_15] [float] NULL,
	[Hr5_30] [float] NULL,
	[Hr5_45] [float] NULL,
	[Hr5_60] [float] NULL,
	[Hr6_15] [float] NULL,
	[Hr6_30] [float] NULL,
	[Hr6_45] [float] NULL,
	[Hr6_60] [float] NULL,
	[Hr7_15] [float] NULL,
	[Hr7_30] [float] NULL,
	[Hr7_45] [float] NULL,
	[Hr7_60] [float] NULL,
	[Hr8_15] [float] NULL,
	[Hr8_30] [float] NULL,
	[Hr8_45] [float] NULL,
	[Hr8_60] [float] NULL,
	[Hr9_15] [float] NULL,
	[Hr9_30] [float] NULL,
	[Hr9_45] [float] NULL,
	[Hr9_60] [float] NULL,
	[Hr10_15] [float] NULL,
	[Hr10_30] [float] NULL,
	[Hr10_45] [float] NULL,
	[Hr10_60] [float] NULL,
	[Hr11_15] [float] NULL,
	[Hr11_30] [float] NULL,
	[Hr11_45] [float] NULL,
	[Hr11_60] [float] NULL,
	[Hr12_15] [float] NULL,
	[Hr12_30] [float] NULL,
	[Hr12_45] [float] NULL,
	[Hr12_60] [float] NULL,
	[Hr13_15] [float] NULL,
	[Hr13_30] [float] NULL,
	[Hr13_45] [float] NULL,
	[Hr13_60] [float] NULL,
	[Hr14_15] [float] NULL,
	[Hr14_30] [float] NULL,
	[Hr14_45] [float] NULL,
	[Hr14_60] [float] NULL,
	[Hr15_15] [float] NULL,
	[Hr15_30] [float] NULL,
	[Hr15_45] [float] NULL,
	[Hr15_60] [float] NULL,
	[Hr16_15] [float] NULL,
	[Hr16_30] [float] NULL,
	[Hr16_45] [float] NULL,
	[Hr16_60] [float] NULL,
	[Hr17_15] [float] NULL,
	[Hr17_30] [float] NULL,
	[Hr17_45] [float] NULL,
	[Hr17_60] [float] NULL,
	[Hr18_15] [float] NULL,
	[Hr18_30] [float] NULL,
	[Hr18_45] [float] NULL,
	[Hr18_60] [float] NULL,
	[Hr19_15] [float] NULL,
	[Hr19_30] [float] NULL,
	[Hr19_45] [float] NULL,
	[Hr19_60] [float] NULL,
	[Hr20_15] [float] NULL,
	[Hr20_30] [float] NULL,
	[Hr20_45] [float] NULL,
	[Hr20_60] [float] NULL,
	[Hr21_15] [float] NULL,
	[Hr21_30] [float] NULL,
	[Hr21_45] [float] NULL,
	[Hr21_60] [float] NULL,
	[Hr22_15] [float] NULL,
	[Hr22_30] [float] NULL,
	[Hr22_45] [float] NULL,
	[Hr22_60] [float] NULL,
	[Hr23_15] [float] NULL,
	[Hr23_30] [float] NULL,
	[Hr23_45] [float] NULL,
	[Hr23_60] [float] NULL,
	[Hr24_15] [float] NULL,
	[Hr24_30] [float] NULL,
	[Hr24_45] [float] NULL,
	[Hr24_60] [float] NULL,
	[uom_id] [int] NULL,
	[data_missing] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proxy_date] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF