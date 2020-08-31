if OBJECT_ID('explain_mtm') is not null
drop TABLE dbo.explain_mtm
GO

CREATE TABLE [dbo].[explain_mtm](
	[as_of_date_from] [date] NULL,
	[as_of_date_to] [date] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [date] NULL,
	expiration_date [date] NULL,
	[hr] [tinyint] NULL,
	book_deal_type_map_id int,broker_id int ,profile_id int ,deal_type_id int ,trader_id int ,contract_id int ,
	product_id int ,template_id int ,deal_status_id int ,counterparty_id int,
	index_id int,pvparty_id int,uom_id int
	,physical_financial_flag [varchar](1),buy_sell_Flag [varchar](1)
	,Category_id int,user_toublock_id int ,toublock_id int ,

	[market_ob_value] [float] NULL,
	[contract_ob_value] [float] NULL,
	[ob_mtm] [float] NULL,
	[market_new_deal] [float] NULL,
	[contract_new_deal] [float] NULL,
	[new_deal] [float] NULL,
	[market_other_modify] [float] NULL,
	[contract_other_modify] [float] NULL,
	[other_modify] [float] NULL,
	[market_forecast_changed] [float] NULL,
	[contract_forecast_changed] [float] NULL,
	[forecast_changed] [float] NULL,
	[market_deleted] [float] NULL,
	[contract_deleted] [float] NULL,
	[deleted] [float] NULL,
	[market_delivered] [float] NULL,
	[contract_delivered] [float] NULL,
	[delivered] [float] NULL,
	[market_cb_value] [float] NULL,
	[contract_cb_value] [float] NULL,
	[cb_mtm] [float] NULL,
	[price_changed] [float] NULL,
	[discount_factor] [float] NULL,
	[currency_id] [int] NULL,
	[create_ts] [datetime] NULL,
	[create_user] [varchar](30) NULL
) ON [PRIMARY]



