/****** Object:  Table [dbo].[explain_modified_mtm]    Script Date: 04/04/2012 13:51:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[explain_modified_mtm]') AND type in (N'U'))
DROP TABLE [dbo].[explain_modified_mtm]
GO


/****** Object:  Table [dbo].[explain_modified_mtm]    Script Date: 04/04/2012 13:45:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[explain_modified_mtm](
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
	[source_deal_pnl_id] [int] IDENTITY(1,1) NOT NULL,
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
	[strike_price] [float] NULL
)
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[explain_modified_mtm] ADD [buy_sell_flag] [varchar](1) NULL
SET ANSI_PADDING ON
ALTER TABLE [dbo].[explain_modified_mtm] ADD [expired_term] [varchar](1) NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [und_pnl_set] [float] NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [fixed_cost_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [formula_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [price_adder1_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [price_adder2_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [volume_multiplier] [float] NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [volume_multiplier2] [float] NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [price_adder2] [float] NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [pay_opposite] [varchar](1) NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [market_value] [float] NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [contract_value] [float] NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [dis_market_value] [float] NULL
ALTER TABLE [dbo].[explain_modified_mtm] ADD [dis_contract_value] [float] NULL
GO

SET ANSI_PADDING OFF
GO


