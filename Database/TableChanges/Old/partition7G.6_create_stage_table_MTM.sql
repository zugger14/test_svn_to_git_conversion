
/****** Object:  Table [dbo].[stage_source_deal_pnl]    Script Date: 06/22/2012 12:14:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO


CREATE TABLE [dbo].[stage_source_deal_pnl](
	[source_deal_header_id]			[int] NOT NULL,
	[term_start]					[datetime] NOT NULL,
	[term_end]						[datetime] NOT NULL,
	[Leg]							[int] NOT NULL,
	[pnl_as_of_date]				[datetime] NOT NULL,
	[und_pnl]						[float] NOT NULL,
	[und_intrinsic_pnl]				[float] NOT NULL,
	[und_extrinsic_pnl]				[float] NOT NULL,
	[dis_pnl]						[float] NOT NULL,
	[dis_intrinsic_pnl]				[float] NOT NULL,
	[dis_extrinisic_pnl]			[float] NOT NULL,
	[pnl_source_value_id]			[int] NOT NULL,
	[pnl_currency_id]				[int] NOT NULL,
	[pnl_conversion_factor]			[float] NOT NULL,
	[pnl_adjustment_value]			[float] NULL,
	[deal_volume]					[float] NULL,
	[create_user]					[varchar](50) NULL,
	[create_ts]						[datetime] NULL,
	[update_user]					[varchar](50) NULL,
	[update_ts]						[datetime] NULL,
	[source_deal_pnl_id]			[int] IDENTITY(1,1) NOT NULL,
	[und_pnl_set]					[float] NULL,
	[market_value]					[float] NULL,
	[contract_value]				[float] NULL,
	[dis_market_value]				[float] NULL,
	[dis_contract_value]			[float] NULL
) ON PS_MTM_deal_pnl(pnl_as_of_date)

GO

SET ANSI_PADDING OFF
GO




-------- stage_source_deal_pnl_detail 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[stage_source_deal_pnl_detail](
	[source_deal_header_id]			[int] NOT NULL,
	[term_start]					[datetime] NOT NULL,
	[term_end]						[datetime] NOT NULL,
	[Leg]							[int] NOT NULL,
	[pnl_as_of_date]				[datetime] NOT NULL,
	[und_pnl]						[float] NOT NULL,
	[und_intrinsic_pnl]				[float] NOT NULL,
	[und_extrinsic_pnl]				[float] NOT NULL,
	[dis_pnl]						[float] NOT NULL,
	[dis_intrinsic_pnl]				[float] NOT NULL,
	[dis_extrinisic_pnl]			[float] NOT NULL,
	[pnl_source_value_id]			[int] NOT NULL,
	[pnl_currency_id]				[int] NOT NULL,
	[pnl_conversion_factor]			[float] NOT NULL,
	[pnl_adjustment_value]			[float] NULL,
	[deal_volume]					[float] NULL,
	[curve_id]						[int] NULL,
	[accrued_interest]				[float] NULL,
	[price]							[float] NULL,
	[discount_rate]					[float] NULL,
	[no_days_left]					[int] NULL,
	[days_year]						[int] NULL,
	[discount_factor]				[float] NULL,
	[create_user]					[varchar](50) NULL,
	[create_ts]						[datetime] NULL,
	[update_user]					[varchar](50) NULL,
	[update_ts]						[datetime] NULL,
	[source_deal_pnl_id]			[int] IDENTITY(1,1) NOT NULL,
	[curve_as_of_date]				[datetime] NULL,
	[internal_deal_type_value_id]	[int] NULL,
	[internal_deal_subtype_value_id] [int] NULL,
	[curve_uom_conv_factor]			[float] NULL,
	[curve_fx_conv_factor]			[float] NULL,
	[price_fx_conv_factor]			[float] NULL,
	[curve_value]					[float] NULL,
	[fixed_cost]					[float] NULL,
	[fixed_price]					[float] NULL,
	[formula_value]					[float] NULL,
	[price_adder]					[float] NULL,
	[price_multiplier]				[float] NULL,
	[strike_price]					[float] NULL
) ON PS_MTM_deal_pnl_detail(pnl_as_of_date)

SET ANSI_PADDING OFF
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [buy_sell_flag] [varchar](1) NULL
SET ANSI_PADDING ON
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [expired_term] [varchar](1) NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [und_pnl_set] [float] NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [fixed_cost_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [formula_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [price_adder1_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [price_adder2_fx_conv_factor] [float] NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [volume_multiplier] [float] NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [volume_multiplier2] [float] NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [price_adder2] [float] NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [pay_opposite] [varchar](1) NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [market_value] [float] NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [contract_value] [float] NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [dis_market_value] [float] NULL
ALTER TABLE [dbo].[stage_source_deal_pnl_detail] ADD [dis_contract_value] [float] NULL

GO

SET ANSI_PADDING OFF
GO

GO
----------------Index_fee_breakdown 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO



CREATE TABLE [dbo].[stage_index_fees_breakdown](
	[index_fees_id]			[int] IDENTITY(1,1) NOT NULL,
	[as_of_date]			[datetime] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[leg]					[int] NOT NULL,
	[term_start]			[datetime] NOT NULL,
	[term_end]				[datetime] NOT NULL,
	[field_id]				[int] NOT NULL,
	[field_name]			[varchar](100) NOT NULL,
	[price]					[float] NULL,
	[total_price]			[float] NULL,
	[volume]				[float] NULL,
	[value]					[float] NULL,
	[contract_value]		[float] NULL,
	[internal_type]			[int] NULL,
	[tab_group_name]		[int] NULL,
	[udf_group_name]		[int] NULL,
	[sequence]				[int] NULL,
	[fee_currency_id]		[int] NULL,
	[currency_id]			[int] NULL,
	[create_user]			[varchar](50) NULL,
	[create_ts]				[datetime] NULL,
	[contract_mkt_flag]		[char](1) NULL
) ON PS_MTM_index_fees(as_of_date)

GO


SET ANSI_PADDING OFF
GO

