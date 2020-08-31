SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

IF OBJECT_ID('[dbo].[mv90_data_hour_arch1]','u') IS NOT NULL
DROP TABLE [dbo].[mv90_data_hour_arch1]
GO

CREATE TABLE [dbo].[mv90_data_hour_arch1](
	[recorderid] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[channel] [int] NULL,
	[prod_date] [datetime] NULL,
	[Hr1] [float] NULL,
	[Hr2] [float] NULL,
	[Hr3] [float] NULL,
	[Hr4] [float] NULL,
	[Hr5] [float] NULL,
	[Hr6] [float] NULL,
	[Hr7] [float] NULL,
	[Hr8] [float] NULL,
	[Hr9] [float] NULL,
	[Hr10] [float] NULL,
	[Hr11] [float] NULL,
	[Hr12] [float] NULL,
	[Hr13] [float] NULL,
	[Hr14] [float] NULL,
	[Hr15] [float] NULL,
	[Hr16] [float] NULL,
	[Hr17] [float] NULL,
	[Hr18] [float] NULL,
	[Hr19] [float] NULL,
	[Hr20] [float] NULL,
	[Hr21] [float] NULL,
	[Hr22] [float] NULL,
	[Hr23] [float] NULL,
	[Hr24] [float] NULL,
	[uom_id] [int] NULL,
	[data_missing] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proxy_date] [datetime] NULL,
	[RecID] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF