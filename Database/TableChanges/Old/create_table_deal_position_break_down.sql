
/****** Object:  Table [dbo].[deal_position_break_down]    Script Date: 11/23/2010 15:28:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[deal_position_break_down](
	[breakdown_id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[source_deal_detail_id] [int] NOT NULL,
	[leg] [int] NOT NULL,
	[strip_from] [int] NOT NULL,
	[lag] [int] NOT NULL,
	[strip_to] [int] NOT NULL,
	[curve_id] [int] NOT NULL,
	[prior_year] [int] NOT NULL,
	[multiplier] [float] NOT NULL,
	[create_ts] [datetime] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_deal_position_break_down] PRIMARY KEY CLUSTERED 
(
	[breakdown_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[deal_position_break_down]  WITH CHECK ADD  CONSTRAINT [FK_deal_position_break_down_source_deal_detail] FOREIGN KEY([source_deal_detail_id])
REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id])
GO
ALTER TABLE [dbo].[deal_position_break_down]  WITH CHECK ADD  CONSTRAINT [FK_deal_position_break_down_source_deal_header] FOREIGN KEY([source_deal_header_id])
REFERENCES [dbo].[source_deal_header] ([source_deal_header_id])
GO
ALTER TABLE [dbo].[deal_position_break_down]  WITH CHECK ADD  CONSTRAINT [FK_deal_position_break_down_source_price_curve_def] FOREIGN KEY([curve_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])