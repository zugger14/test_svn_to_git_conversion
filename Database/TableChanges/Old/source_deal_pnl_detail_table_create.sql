
/****** Object:  Table [dbo].[source_deal_pnl_detail]    Script Date: 12/25/2008 11:11:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_deal_pnl_detail](
	[source_deal_header_id] [int] NOT NULL,
	[term_start] [datetime] NOT NULL,
	[term_end] [datetime] NOT NULL,
	[Leg] [int] NOT NULL,
	[pnl_as_of_date] [datetime] NOT NULL,
	[und_pnl] [float] NOT NULL,
	[und_intrinsic_pnl] [float] NOT NULL,
	[und_extrinsic_pnl] [float] NOT NULL,
	[dis_pnl] [float] NOT NULL,
	[dis_intrinsic_pnl] [float] NOT NULL,
	[dis_extrinisic_pnl] [float] NOT NULL,
	[pnl_source_value_id] [int] NOT NULL,
	[pnl_currency_id] [int] NOT NULL,
	[pnl_conversion_factor] [float] NOT NULL,
	[pnl_adjustment_value] [float] NULL,
	[deal_volume] [float] NULL,
	[curve_id] [int] NULL,
	[accrued_interest] [float] NULL,
	[price] [float] NULL,
	[discount_rate] [float] NULL,
	[no_days_left] [int] NULL,
	[days_year] [int] NULL,
	[discount_factor] [float] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
	[source_deal_pnl_id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_source_deal_pnl_detail] PRIMARY KEY NONCLUSTERED 
(
	[source_deal_header_id] ASC,
	[term_start] ASC,
	[term_end] ASC,
	[Leg] ASC,
	[pnl_as_of_date] ASC,
	[pnl_source_value_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF