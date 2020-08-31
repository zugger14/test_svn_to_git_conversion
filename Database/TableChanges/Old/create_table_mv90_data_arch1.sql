SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

IF OBJECT_ID('[dbo].[mv90_data_arch1]','u') IS NOT NULL
DROP TABLE [dbo].[mv90_data_arch1]
GO

CREATE TABLE [dbo].[mv90_data_arch1](
	[RecorderId] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[gen_date] [datetime] NOT NULL,
	[from_date] [datetime] NOT NULL,
	[to_date] [datetime] NOT NULL,
	[channel] [int] NOT NULL,
	[volume] [float] NULL,
	[uom_id] [int] NULL,
	[descriptions] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF