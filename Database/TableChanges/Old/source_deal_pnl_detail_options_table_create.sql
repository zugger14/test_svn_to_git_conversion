
/****** Object:  Table [dbo].[source_deal_pnl_detail_options]    Script Date: 12/25/2008 11:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_deal_pnl_detail_options](
	[as_of_date] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
	[option_type] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[excercise_type] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[source_deal_type_id] [int] NULL,
	[deal_sub_type_type_id] [int] NULL,
	[internal_deal_type_value_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[internal_deal_subtype_value_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[deal_volume] [float] NULL,
	[deal_volume_frequency] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[deal_volume_uom_id] [int] NULL,
	[PREMIUM] [float] NULL,
	[DELTA] [float] NULL,
	[GAMMA] [float] NULL,
	[VEGA] [float] NULL,
	[THETA] [float] NULL,
	[RHO] [float] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
 CONSTRAINT [PK_source_deal_pnl_detail_options] PRIMARY KEY CLUSTERED 
(
	[as_of_date] ASC,
	[source_deal_header_id] ASC,
	[term_start] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF