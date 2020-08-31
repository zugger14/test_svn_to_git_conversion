if OBJECT_ID('source_deal_pnl_whatif') is not null
drop table [source_deal_pnl_whatif]

GO

CREATE TABLE [dbo].[source_deal_pnl_whatif](
	criteria_id int,
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
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[source_deal_pnl_id] [int] IDENTITY(1,1) NOT NULL,
	[und_pnl_set] [float] NULL,
	[market_value] [float] NULL,
	[contract_value] [float] NULL,
	[dis_market_value] [float] NULL,
	[dis_contract_value] [float] NULL,
 CONSTRAINT [PK_source_deal_pnl_whatif] PRIMARY KEY NONCLUSTERED 
(
	[criteria_id] ASC,
	[source_deal_header_id] ASC,
	[term_start] ASC,
	[term_end] ASC,
	[Leg] ASC,
	[pnl_as_of_date] ASC,
	[pnl_source_value_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
