IF OBJECT_ID('[dbo].[source_deal_detail_lagging]') IS NOT NULL
DROP TABLE [dbo].[source_deal_detail_lagging]
go
/****** Object:  Table [dbo].[source_deal_detail_lagging]    Script Date: 05/29/2009 10:23:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_deal_detail_lagging](
	[source_deal_header_id] [int] NOT NULL,
	[leg] [int] NOT NULL,
	[term_start] [datetime] NOT NULL,
	[term_start_leg1] [datetime] NOT NULL,
	[term_end_leg1] [datetime] NOT NULL,
	[strip_month_from] [int] NOT NULL,
	[lag_months] [int] NOT NULL,
	[strip_month_to] [int] NOT NULL,
	[conv_factor] [float] NOT NULL,
	[per_allocation] [float] NOT NULL,
	[volume_allocation] [float] NOT NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
 CONSTRAINT [PK_source_deal_detail_lagging] PRIMARY KEY CLUSTERED 
(
	[source_deal_header_id] ASC,
	[leg] ASC,
	[term_start] ASC,
	[term_start_leg1] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
USE [TRMTracker]
GO
ALTER TABLE [dbo].[source_deal_detail_lagging]  WITH CHECK ADD  CONSTRAINT [FK_source_deal_detail_lagging_source_deal_header] FOREIGN KEY([source_deal_header_id])
REFERENCES [dbo].[source_deal_header] ([source_deal_header_id])