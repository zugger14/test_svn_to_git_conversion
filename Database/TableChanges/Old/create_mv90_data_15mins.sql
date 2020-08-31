IF OBJECT_ID('mv90_data_15mins', 'U') IS NOT NULL 
	DROP TABLE mv90_data_15mins 
	
GO
/****** Object:  Table [dbo].[mv90_data_15mins]    Script Date: 11/02/2009 17:33:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mv90_data_15mins](
	[recorderid] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[channel] [int] NULL,
	[prod_date] [datetime] NULL,
	[Hr] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[min] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[value] [float] NULL,
	[30min] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[uom_id] [int] NULL,
	[data_missing] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proxy_date] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF