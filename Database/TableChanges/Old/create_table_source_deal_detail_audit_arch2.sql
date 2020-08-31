SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[source_deal_detail_audit_arch2]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[source_deal_detail_audit_arch2](
		[source_deal_detail_id] [int] NOT NULL,
		[source_deal_header_id] [int] NOT NULL,
		[term_start] [datetime] NOT NULL,
		[term_end] [datetime] NOT NULL,
		[Leg] [int] NOT NULL,
		[contract_expiration_date] [datetime] NOT NULL,
		[fixed_float_leg] [char](1) NOT NULL,
		[buy_sell_flag] [char](1) NOT NULL,
		[curve_id] [int] NULL,
		[fixed_price] [numeric](38, 20) NULL,
		[fixed_price_currency_id] [int] NULL,
		[option_strike_price] [numeric](38, 20) NULL,
		[deal_volume] [numeric](38, 20) NULL,
		[deal_volume_frequency] [char](1) NOT NULL,
		[deal_volume_uom_id] [int] NOT NULL,
		[block_description] [varchar](100) NULL,
		[deal_detail_description] [varchar](100) NULL,
		[formula_id] [int] NULL,
		[volume_left] [numeric](38, 20) NULL,
		[settlement_volume] [numeric](38, 20) NULL,
		[settlement_uom] [int] NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL,
		[user_action] [varchar](50) NULL,
		[price_adder] [numeric](38, 20) NULL,
		[price_multiplier] [numeric](38, 20) NULL,
		[settlement_date] [datetime] NULL,
		[day_count_id] [int] NULL,
		[location_id] [int] NULL,
		[physical_financial_flag] [char](1) NULL,
		[Booked] [char](1) NULL,
		[fixed_cost] [numeric](38, 20) NULL,
		[header_audit_id] [int] NULL,
		[multiplier] [numeric](38, 20) NULL,
		[adder_currency_id] [int] NULL,
		[fixed_cost_currency_id] [int] NULL,
		[formula_currency_id] [int] NULL,
		[price_adder2] [numeric](38, 20) NULL,
		[price_adder_currency2] [int] NULL,
		[volume_multiplier2] [numeric](38, 20) NULL,
		[total_volume] [numeric](38, 20) NULL,
		[pay_opposite] [varchar](1) NULL,
		[formula_text] [varchar](max) NULL,
		[capacity] [numeric](38, 20) NULL,
		[meter_id] [int] NULL,
		[settlement_currency] [int] NULL,
		[standard_yearly_volume] [numeric](38, 20) NULL,
		[price_uom_id] [int] NULL,
		[category] [int] NULL,
		[profile_code] [int] NULL,
		[pv_party] [int] NULL
	)
END
ELSE
BEGIN
    PRINT 'Table table_name EXISTS'
END

SET ANSI_PADDING OFF
GO