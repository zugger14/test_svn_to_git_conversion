IF OBJECT_ID('source_deal_pnl_detail_options') IS NOT NULL 
DROP TABLE source_deal_pnl_detail_options
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_deal_pnl_detail_options](
	[as_of_date] [datetime] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[term_start] [datetime] NOT NULL,
	[curve_1] [int] NULL,
	[curve_2] [int] NULL,
	[option_premium] [float] NULL,
	[strike_price] [float] NULL,
	[spot_price_1] [float] NULL,
	[days_expiry] [float] NULL,
	[volatility_1] [float] NULL,
	[discount_rate] [float] NULL,
	[option_type] [char](1) NULL,
	[excercise_type] [char](1) NULL,
	[source_deal_type_id] [int] NULL,
	[deal_sub_type_type_id] [int] NULL,
	[internal_deal_type_value_id] [varchar](50) NULL,
	[internal_deal_subtype_value_id] [varchar](50) NULL,
	[deal_volume] [float] NULL,
	[deal_volume_frequency] [char](1) NULL,
	[deal_volume_uom_id] [int] NULL,
	[correlation] [float] NULL,
	[volatility_2] [float] NULL,
	[spot_price_2] [float] NULL,
	[deal_volume2] [float] NULL,
	[PREMIUM] [float] NULL,
	[DELTA] [float] NULL,
	[GAMMA] [float] NULL,
	[VEGA] [float] NULL,
	[THETA] [float] NULL,
	[RHO] [float] NULL,
	[DELTA2] [float] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[pnl_source_value_id] [int] NOT NULL,
 CONSTRAINT [PK_source_deal_pnl_detail_option1] PRIMARY KEY CLUSTERED 
(
	[as_of_date] ASC,
	[source_deal_header_id] ASC,
	[term_start] ASC,
	[pnl_source_value_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[source_deal_pnl_detail_options]  WITH CHECK ADD  CONSTRAINT [FK_source_deal_pnl_detail_options_static_data_value] FOREIGN KEY([pnl_source_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[source_deal_pnl_detail_options] CHECK CONSTRAINT [FK_source_deal_pnl_detail_options_static_data_value]