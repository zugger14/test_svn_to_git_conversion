if OBJECT_ID('explain_position') is not null
drop TABLE dbo.explain_position
GO

CREATE TABLE [dbo].[explain_position](
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
	[ob_value] [numeric](18, 10) NULL,
	[new_deal] [numeric](18, 10) NULL,
	[modify_deal] [numeric](18, 10) NULL,
	[forecast_changed] [numeric](18, 10) NULL,
	[deleted] [numeric](18, 10) NULL,
	[delivered] [numeric](18, 10) NULL,
	[cb_value] [numeric](18, 10) NULL,
	[create_ts_deal] [datetime] NULL,
	[create_ts_position] [datetime] NULL,
	[create_ts] [datetime] NULL,
	[create_user] [varchar](30) NULL
) ON [PRIMARY]
