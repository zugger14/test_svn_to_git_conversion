
GO
/****** Object:  Table [dbo].[report_measurement_values_inventory]    Script Date: 09/24/2009 10:19:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_measurement_values_inventory]') AND type in (N'U'))
DROP TABLE [dbo].[report_measurement_values_inventory]
GO
/****** Object:  Table [dbo].[calcprocess_inventory_deals]    Script Date: 09/24/2009 10:19:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calcprocess_inventory_deals]') AND type in (N'U'))
DROP TABLE [dbo].[calcprocess_inventory_deals]
GO
/****** Object:  Table [dbo].[calcprocess_inventory_wght_avg_cost]    Script Date: 09/24/2009 10:19:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calcprocess_inventory_wght_avg_cost]') AND type in (N'U'))
DROP TABLE [dbo].[calcprocess_inventory_wght_avg_cost]
GO
/****** Object:  Table [dbo].[inventory_book_map]    Script Date: 09/24/2009 10:19:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[inventory_book_map]') AND type in (N'U'))
DROP TABLE [dbo].[inventory_book_map]
GO
/****** Object:  Table [dbo].[inventory_account_type]    Script Date: 09/24/2009 10:19:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[inventory_account_type]') AND type in (N'U'))
DROP TABLE [dbo].[inventory_account_type]
GO

GO
/****** Object:  Table [dbo].[report_measurement_values_inventory]    Script Date: 09/24/2009 10:19:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_measurement_values_inventory](
	[as_of_date] [datetime] NOT NULL,
	[sub_entity_id] [int] NOT NULL,
	[strategy_entity_id] [int] NOT NULL,
	[book_entity_id] [int] NOT NULL,
	[link_id] [int] NOT NULL,
	[term_month] [datetime] NOT NULL,
	[u_hedge_mtm] [float] NULL,
	[u_rec_mtm] [float] NULL,
	[u_hedge_st_asset] [float] NULL,
	[u_hedge_st_asset_units] [float] NULL,
	[u_hedge_st_liability] [float] NULL,
	[u_hedge_st_liability_units] [float] NULL,
	[u_pnl_settlement] [float] NULL,
	[u_pnl_settlement_units] [float] NULL,
	[u_pnl_inventory] [float] NULL,
	[u_pnl_inventory_units] [float] NULL,
	[u_sur_expense] [float] NULL,
	[u_sur_expense_units] [float] NULL,
	[u_inv_expense] [float] NULL,
	[u_inv_expense_units] [float] NULL,
	[u_exp_expense] [float] NULL,
	[u_exp_expense_units] [float] NULL,
	[u_revenue] [float] NULL,
	[u_revenue_units] [float] NULL,
	[u_liability] [float] NULL,
	[u_liability_units] [float] NULL,
	[gl_code_hedge_st_asset] [int] NULL,
	[gl_code_hedge_st_liability] [int] NULL,
	[gl_settlement] [int] NULL,
	[gl_inventory] [int] NULL,
	[gl_code_sur_expense] [int] NULL,
	[gl_code_inv_expense] [int] NULL,
	[gl_code_exp_expense] [int] NULL,
	[gl_code_u_revenue] [int] NULL,
	[gl_code_liability] [int] NULL,
	[currency_unit] [int] NOT NULL,
	[uom_id] [int] NULL,
	[u_inventory_nocost] [float] NULL,
	[u_inventory_nocost_units] [float] NULL,
	[gl_inventory_nocost] [int] NULL,
	[u_inventory_paidvalue] [float] NULL,
	[u_inventory_paidvalue_units] [float] NULL,
	[gl_inventory_paidvalue] [int] NULL,
	[u_inventory_compliance] [float] NULL,
	[u_inventory_compliance_units] [float] NULL,
	[gl_inventory_compliance] [int] NULL,
	[u_inventory_compliance_liab] [float] NULL,
	[u_inventory_compliance_liab_units] [float] NULL,
	[gl_inventory_compliance_liab] [int] NULL,
	[u_inventory_deferred_fuel] [float] NULL,
	[u_inventory_deferred_fuel_units] [float] NULL,
	[gl_inventory_deferred_fuel] [int] NULL,
	[deal_date] [datetime] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[calcprocess_inventory_deals]    Script Date: 09/24/2009 10:19:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[calcprocess_inventory_deals](
	[temp_deal_id] [int] NOT NULL,
	[as_of_date] [datetime] NULL,
	[sub_entity_id] [int] NULL,
	[strategy_entity_id] [int] NULL,
	[book_entity_id] [int] NULL,
	[source_deal_header_id] [int] NOT NULL,
	[source_system_id] [int] NOT NULL,
	[deal_id] [varchar](50) NULL,
	[deal_date] [datetime] NOT NULL,
	[ext_deal_id] [varchar](50) NULL,
	[physical_financial_flag] [char](10) NOT NULL,
	[structured_deal_id] [varchar](50) NULL,
	[counterparty_id] [int] NOT NULL,
	[entire_term_start] [datetime] NOT NULL,
	[entire_term_end] [datetime] NOT NULL,
	[source_deal_type_id] [int] NOT NULL,
	[deal_sub_type_type_id] [int] NULL,
	[option_flag] [char](1) NOT NULL,
	[option_type] [char](1) NULL,
	[option_excercise_type] [char](1) NULL,
	[source_system_book_id1] [int] NOT NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
	[description1] [varchar](100) NULL,
	[description2] [varchar](50) NULL,
	[description3] [varchar](50) NULL,
	[deal_category_value_id] [int] NOT NULL,
	[trader_id] [int] NOT NULL,
	[term_start] [datetime] NOT NULL,
	[term_end] [datetime] NOT NULL,
	[Leg] [int] NOT NULL,
	[contract_expiration_date] [datetime] NULL,
	[fixed_float_leg] [char](1) NOT NULL,
	[buy_sell_flag] [char](1) NOT NULL,
	[curve_id] [int] NULL,
	[fixed_price] [float] NULL,
	[fixed_price_currency_id] [int] NULL,
	[option_strike_price] [float] NULL,
	[deal_volume] [float] NOT NULL,
	[deal_volume_frequency] [char](1) NOT NULL,
	[deal_volume_uom_id] [int] NOT NULL,
	[block_description] [varchar](100) NULL,
	[internal_deal_type_value_id] [varchar](50) NULL,
	[internal_deal_subtype_value_id] [varchar](50) NULL,
	[deal_detail_description] [varchar](100) NULL,
	[formula] [varchar](6000) NULL,
	[formula_value] [float] NULL,
	[ARGL] [int] NULL,
	[APGL] [int] NULL,
	[InvGL] [int] NULL,
	[ExpGL] [int] NULL,
	[SExpGL] [int] NULL,
	[IExpGL] [int] NULL,
	[EExpGL] [int] NULL,
	[RevGL] [int] NULL,
	[LiabGL] [int] NULL,
	[NoCost] [int] NULL,
	[HeldForCompliance] [int] NULL,
	[InventorPaidValue] [int] NULL,
	[ComplianceLiability] [int] NULL,
	[DeferredFuel] [int] NULL,
	[expiring] [int] NULL,
	[surrender] [int] NULL,
	[current_buy_sell] [int] NULL,
	[hedge_type_value_id] [int] NULL,
	[assignment_type_value_id] [int] NULL,
	[assigned_date] [datetime] NULL,
	[adjustments] [int] NULL,
	[last_run_date] [datetime] NULL,
	[rec_formula] [varchar](6000) NULL,
	[rec_fixed_price] [float] NULL,
	[rec_formula_value] [float] NULL,
	[contract_formula_id] [int] NULL,
	[rec_formula_id] [int] NULL,
	[status_value_id] [int] NULL,
	[state_value_id] [int] NULL,
	[technology] [int] NULL,
	[cost_approach_id] [int] NULL,
	[exclude_inventory] [varchar](1) NULL,
	[jurisdiction] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[calcprocess_inventory_wght_avg_cost]    Script Date: 09/24/2009 10:19:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[calcprocess_inventory_wght_avg_cost](
	[as_of_date] [datetime] NOT NULL,
	[gl_code] [int] NULL,
	[wght_avg_cost] [float] NULL,
	[total_inventory] [float] NULL,
	[total_units] [float] NULL,
	[inventory_account_type] [varchar](100) NULL,
	[inventory_account_name] [varchar](100) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[inventory_book_map]    Script Date: 09/24/2009 10:19:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[inventory_book_map](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[book_id] [int] NOT NULL,
	[group_name] [varchar](100) NULL,
	[seq_number] [int] NOT NULL,
	[table_name] [varchar](100) NULL,
	[column_name] [varchar](50) NULL,
	[criteria] [varchar](500) NULL,
 CONSTRAINT [PK_inventory_book_map_detail] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[inventory_account_type]    Script Date: 09/24/2009 10:19:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[inventory_account_type](
	[gl_account_id] [int] IDENTITY(1,1) NOT NULL,
	[book_entity_id] [int] NULL,
	[account_type_value_id] [int] NULL,
	[account_type_name] [varchar](100) NULL,
	[gl_number_id] [int] NULL,
	[assignment_type_id] [int] NULL,
	[assignment_gl_number_id] [int] NULL,
	[column_map_id1] [int] NULL,
	[value_id1] [int] NULL,
	[column_map_id2] [int] NULL,
	[value_id2] [int] NULL,
	[column_map_id3] [int] NULL,
	[value_id3] [int] NULL,
	[column_map_id4] [int] NULL,
	[value_id4] [int] NULL,
	[column_map_id5] [int] NULL,
	[value_id5] [int] NULL,
	[column_map_id6] [int] NULL,
	[value_id6] [int] NULL,
	[column_map_id7] [int] NULL,
	[value_id7] [int] NULL,
	[column_map_id8] [int] NULL,
	[value_id8] [int] NULL,
	[column_map_id9] [int] NULL,
	[value_id9] [int] NULL,
	[column_map_id10] [int] NULL,
	[value_id10] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF