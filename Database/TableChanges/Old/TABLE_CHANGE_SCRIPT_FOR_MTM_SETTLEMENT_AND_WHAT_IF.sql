IF OBJECT_ID(N'source_deal_settlement', N'U') IS NULL
BEGIN
	CREATE TABLE source_deal_settlement (as_of_date datetime, settlement_date datetime, payment_date datetime, source_deal_header_id int, 
		term_start datetime, term_end datetime, volume float, net_price float, settlement_amount float, settlement_currency_id int, 
		create_ts datetime, create_user varchar(50))
END
GO

----make primary key on source_deal_header_id, term_Start, term_end
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'source_deal_pnl_WhatIf', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[source_deal_pnl_WhatIf](
	[criteria_id] INT,
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
	[source_deal_pnl_WhatIf_id] [int] IDENTITY(1,1) NOT NULL,
	[und_pnl_set] [float] NULL,
	[market_value] [float] NULL,
	[contract_value] [float] NULL,
	[dis_market_value] [float] NULL,
	[dis_contract_value] [float] NULL,
	CONSTRAINT [PK_source_deal_pnl_WhatIf] PRIMARY KEY NONCLUSTERED 
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
END
GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'source_deal_pnl_detail_WhatIf', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[source_deal_pnl_detail_WhatIf](
	[criteria_id] INT,
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
	[curve_uom_conv_factor] [int] NULL,
	[curve_fx_conv_factor] [int] NULL,
	[price_fx_conv_factor] [int] NULL,
	[curve_value] [float] NULL,
	[fixed_cost] [float] NULL,
	[fixed_price] [float] NULL,
	[formula_value] [float] NULL,
	[price_adder] [float] NULL,
	[price_multiplier] [float] NULL,
	[strike_price] [float] NULL
) ON [PRIMARY]
END
GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'buy_sell_flag') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [buy_sell_flag] [varchar](1) NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.buy_sell_flag added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.buy_sell_flag already exists.'
END
GO

SET ANSI_PADDING ON

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'expired_term') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [expired_term] [varchar](1) NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.expired_term added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.expired_term already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'und_pnl_set') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [und_pnl_set] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.und_pnl_set added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.und_pnl_set already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'fixed_cost_fx_conv_factor') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [fixed_cost_fx_conv_factor] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.fixed_cost_fx_conv_factor added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.fixed_cost_fx_conv_factor already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'formula_fx_conv_factor') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [formula_fx_conv_factor] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.formula_fx_conv_factor added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.formula_fx_conv_factor already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'price_adder1_fx_conv_factor') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [price_adder1_fx_conv_factor] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.price_adder1_fx_conv_factor added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.price_adder1_fx_conv_factor already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'price_adder2_fx_conv_factor') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [price_adder2_fx_conv_factor] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.price_adder2_fx_conv_factor added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.price_adder2_fx_conv_factor already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'volume_multiplier') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [volume_multiplier] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.volume_multiplier added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.volume_multiplier already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'volume_multiplier2') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [volume_multiplier2] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.volume_multiplier2 added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.volume_multiplier2 already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'price_adder2') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [price_adder2] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.price_adder2 added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.price_adder2 already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'pay_opposite') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [pay_opposite] [varchar](1) NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.pay_opposite added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.pay_opposite already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'market_value') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [market_value] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.market_value added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.market_value already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'contract_value') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [contract_value] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.contract_value added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.contract_value already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'dis_market_value') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [dis_market_value] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.dis_market_value added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.dis_market_value already exists.'
END
GO

IF COL_LENGTH('source_deal_pnl_detail_WhatIf', 'dis_contract_value') IS NULL
BEGIN
	ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [dis_contract_value] [float] NULL
	PRINT 'Column source_deal_pnl_detail_WhatIf.dis_contract_value added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_pnl_detail_WhatIf.dis_contract_value already exists.'
END
GO

SET ANSI_PADDING OFF
GO

/*
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [buy_sell_flag] [varchar](1) NULL
SET ANSI_PADDING ON
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [expired_term] [varchar](1) NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [und_pnl_set] [float] NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [fixed_cost_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [formula_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [price_adder1_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [price_adder2_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [volume_multiplier] [float] NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [volume_multiplier2] [float] NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [price_adder2] [float] NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [pay_opposite] [varchar](1) NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [market_value] [float] NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [contract_value] [float] NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [dis_market_value] [float] NULL
ALTER TABLE [dbo].[source_deal_pnl_detail_WhatIf] ADD [dis_contract_value] [float] NULL

GO

SET ANSI_PADDING OFF
GO
*/

IF COL_LENGTH('curve_volatility', 'strike_price') IS NULL
BEGIN
	alter table curve_volatility add strike_price float
	PRINT 'Column curve_volatility.strike_price added.'
END
ELSE
BEGIN
	PRINT 'Column curve_volatility.strike_price already exists.'
END
GO

/****** Object:  Table [dbo].[source_deal_pnl_detail_options_WhatIf]    Script Date: 06/10/2011 17:57:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'source_deal_pnl_detail_options_WhatIf', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[source_deal_pnl_detail_options_WhatIf](
		[criteria_id] INT, 
		[as_of_date] [datetime] NOT NULL,
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
		[option_type] [char](1) NULL,
		[excercise_type] [char](1) NULL,
		[source_deal_type_id] [int] NULL,
		[deal_sub_type_type_id] [int] NULL,
		[internal_deal_type_value_id] [varchar](50) NULL,
		[internal_deal_subtype_value_id] [varchar](50) NULL,
		[deal_volume] [float] NULL,
		[deal_volume_frequency] [char](1) NULL,
		[deal_volume_uom_id] [int] NULL,
		[correlation] [float] NULL,
		[volatility_2] [float] NULL,
		[spot_price_2] [float] NULL,
		[deal_volume2] [float] NULL,
		[PREMIUM] [float] NULL,
		[DELTA] [float] NULL,
		[GAMMA] [float] NULL,
		[VEGA] [float] NULL,
		[THETA] [float] NULL,
		[RHO] [float] NULL,
		[DELTA2] [float] NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[pnl_source_value_id] [int] NOT NULL,
		[total_deal_volume] [float] NULL,
	) ON [PRIMARY]

END

GO

SET ANSI_PADDING OFF
GO


