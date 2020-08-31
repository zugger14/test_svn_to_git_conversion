if OBJECT_ID('explain_mtm') is not null
drop table explain_mtm
GO

CREATE TABLE [dbo].explain_mtm(
	[as_of_date_from] datetime,
	[as_of_date_to] datetime,
	[source_deal_header_id] [int] NOT NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[hr] [tinyint] NULL,
	[market_ob_value] float NULL,
	[contract_ob_value] float NULL,
	[ob_mtm] float NULL,
	[market_new_deal] float NULL,
	[contract_new_deal] float NULL,
	[new_deal] float NULL,
	[market_modify_deal] float NULL,
	[contract_modify_deal] float NULL,
	[modify_deal] float NULL,
	[market_forecast_changed] float NULL,
	[contract_forecast_changed] float NULL,
	[forecast_changed] float NULL,
	[market_deleted] float NULL,
	[contract_deleted] float NULL,
	[deleted] float NULL,
	[market_delivered] float NULL,
	[contract_delivered] float NULL,
	[delivered] float NULL,
	[market_cb_value] float NULL,
	[contract_cb_value] float NULL,
	[cb_mtm] float NULL,
	[market_price_changed] float NULL,
	[contract_price_changed] float NULL,
	[price_changed] float NULL,
	[set_ob_value] float NULL,
	[set_new_deal] float NULL,
	[set_modify_deal] float NULL,
	[set_forecast_changed] float NULL,
	[set_deleted] float NULL,
	[set_delivered] float NULL,
	[set_price_changed] float NULL,
	[set_cb_value] float NULL,
	discount_factor float,
	currency_id int
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


