/****** Object:  Table [dbo].[source_deal_detail_whatif_hypo]    Script Date: 08/23/2012 10:15:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[source_deal_detail_whatif_hypo]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[source_deal_detail_whatif_hypo](
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
	[settlement_volume] [float] NULL,
	[settlement_uom] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[price_adder] [numeric](38, 20) NULL,
	[price_multiplier] [numeric](38, 20) NULL,
	[settlement_date] [datetime] NULL,
	[day_count_id] [int] NULL,
	[location_id] [int] NULL,
	[meter_id] [int] NULL,
	[physical_financial_flag] [char](1) NULL,
	[Booked] [char](1) NULL,
	[process_deal_status] [int] NULL,
	[fixed_cost] [numeric](38, 20) NULL,
	[multiplier] [numeric](38, 20) NULL,
	[adder_currency_id] [int] NULL,
	[fixed_cost_currency_id] [int] NULL,
	[formula_currency_id] [int] NULL,
	[price_adder2] [numeric](38, 20) NULL,
	[price_adder_currency2] [int] NULL,
	[volume_multiplier2] [numeric](38, 20) NULL,
	[total_volume] [numeric](38, 20) NULL,
	[pay_opposite] [varchar](1) NULL,
	[capacity] [numeric](38, 20) NULL,
	[settlement_currency] [int] NULL,
	[standard_yearly_volume] [numeric](22, 8) NULL,
	[formula_curve_id] [int] NULL,
	[price_uom_id] [int] NULL,
	[category] [int] NULL,
	[profile_code] [int] NULL,
	[pv_party] [int] NULL,
)
END
	ELSE
	BEGIN
		PRINT 'Table source_deal_detail_whatif_hypo EXISTS'
	END
GO

IF NOT EXISTS(SELECT * FROM source_deal_detail_whatif_hypo)
BEGIN
INSERT INTO [dbo].[source_deal_detail_whatif_hypo]([source_deal_detail_id], [source_deal_header_id], [term_start], [term_end], [Leg], [contract_expiration_date], [fixed_float_leg], [buy_sell_flag], [curve_id], [fixed_price], [fixed_price_currency_id], [option_strike_price], [deal_volume], [deal_volume_frequency], [deal_volume_uom_id], [block_description], [deal_detail_description], [formula_id], [volume_left], [settlement_volume], [settlement_uom], [create_user], [create_ts], [update_user], [update_ts], [price_adder], [price_multiplier], [settlement_date], [day_count_id], [location_id], [meter_id], [physical_financial_flag], [Booked], [process_deal_status], [fixed_cost], [multiplier], [adder_currency_id], [fixed_cost_currency_id], [formula_currency_id], [price_adder2], [price_adder_currency2], [volume_multiplier2], [total_volume], [pay_opposite], [capacity], [settlement_currency], [standard_yearly_volume], [formula_curve_id], [price_uom_id], [category], [profile_code], [pv_party])
	SELECT 2, 2, '20120101 00:00:00.000', '20120131 00:00:00.000', 1, '20120131 00:00:00.000', N't', N's', 5, NULL, 2, NULL, 1000.00000000000000000000, N'm', 20, NULL, NULL, NULL, 1000.00000000000000000000, NULL, NULL, N'mrutgers', '20120612 13:36:01.667', N'farrms_admin', '20120823 11:09:35.117', NULL, 1.00000000000000000000, '20120131 00:00:00.000', NULL, 4, 0, N'f', NULL, NULL, NULL, 1.00000000000000000000, NULL, NULL, NULL, NULL, NULL, 1.00000000000000000000, 1000.00000000000000000000, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 292065 
	UNION ALL
	SELECT 3, 2, '20120101 00:00:00.000', '20120131 00:00:00.000', 2, '20120131 00:00:00.000', N't', N'b', 5, NULL, 2, NULL, 1000.00000000000000000000, N'm', 20, NULL, NULL, NULL, 1000.00000000000000000000, NULL, NULL, N'mrutgers', '20120612 13:36:01.783', N'farrms_admin', '20120823 11:09:35.117', NULL, 1.00000000000000000000, '20120131 00:00:00.000', NULL, 125871, 0, N'f', NULL, NULL, NULL, 1.00000000000000000000, NULL, NULL, NULL, NULL, NULL, 1.00000000000000000000, 1000.00000000000000000000, N'N', 25000.00000000000000000000, NULL, NULL, NULL, NULL, NULL, NULL, 292065 
	UNION ALL
	SELECT 1, 1, '20120801 00:00:00.000', '20120831 00:00:00.000', 1, '20120801 00:00:00.000', N't', N's', 92, 735.48000000000000000000, 2, NULL, 2450.00000000000000000000, N'm', 14, NULL, NULL, NULL, 2450.00000000000000000000, NULL, NULL, N'mrutgers', '20120726 13:57:25.777', N'mrutgers', '20120726 13:57:25.777', NULL, 1.00000000000000000000, '20120801 00:00:00.000', NULL, NULL, 0, N'f', NULL, NULL, NULL, 1.00000000000000000000, NULL, NULL, NULL, NULL, NULL, 1.00000000000000000000, 2450.00000000000000000000, N'Y', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
END