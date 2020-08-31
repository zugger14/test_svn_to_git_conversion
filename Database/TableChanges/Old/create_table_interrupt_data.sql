/****** Object:  Table [dbo].[interrupt_data]    Script Date: 12/26/2008 13:10:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
DROP TABLE [dbo].[interrupt_data]
GO

CREATE TABLE [dbo].[interrupt_data](
	[interrupt_id] [int] IDENTITY(1,1) NOT NULL,
	[contract_id] [int] NOT NULL,
	[prod_date] [datetime] NOT NULL,
	[hr_begin] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[min_begin] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_interrupt_data_min_begin]  DEFAULT ((0)),
	[hr_begin_proxy] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[min_begin_proxy] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[hr_end] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[min_end] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_interrupt_data_min_end]  DEFAULT ((0)),
	[hr_end_proxy] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[min_end_proxy] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[type] [nchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[comment] [nchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[hr_begin_proxy2] [int] NULL,
	[min_begin_proxy2] [int] NULL,
	[hr_end_proxy2] [int] NULL,
	[min_end_proxy2] [int] NULL,
	[clq_demand] [float] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF