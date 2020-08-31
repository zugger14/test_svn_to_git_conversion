SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[source_deal_pnl_detail_arch2]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[source_deal_pnl_detail_arch2](
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
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL,
		[source_deal_pnl_id] [int] NULL,
		[curve_as_of_date] [datetime] NULL,
		[internal_deal_type_value_id] [int] NULL,
		[internal_deal_subtype_value_id] [int] NULL,
		[curve_uom_conv_factor] [float] NULL,
		[curve_fx_conv_factor] [float] NULL,
		[price_fx_conv_factor] [float] NULL,
		[curve_value] [float] NULL,
		[fixed_cost] [float] NULL,
		[fixed_price] [float] NULL,
		[formula_value] [float] NULL,
		[price_adder] [float] NULL,
		[price_multiplier] [float] NULL,
		[strike_price] [float] NULL,
		[buy_sell_flag] [varchar](1) NULL,
		[expired_term] [varchar](1) NULL,
		[und_pnl_set] [float] NULL,
		[fixed_cost_fx_conv_factor] [float] NULL,
		[formula_fx_conv_factor] [float] NULL,
		[price_adder1_fx_conv_factor] [float] NULL,
		[price_adder2_fx_conv_factor] [float] NULL,
		[volume_multiplier] [float] NULL,
		[volume_multiplier2] [float] NULL,
		[price_adder2] [float] NULL,
		[pay_opposite] [varchar](1) NULL,
		[market_value] [float] NULL,
		[contract_value] [float] NULL,
		[dis_market_value] [float] NULL,
		[dis_contract_value] [float] NULL
		
	)
END
ELSE
BEGIN
    PRINT 'Table table_name EXISTS'
END

SET ANSI_PADDING OFF
GO


