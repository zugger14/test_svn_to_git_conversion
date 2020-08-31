IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inventory_account_type_inventory_account_type_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory_account_type]'))
ALTER TABLE [dbo].[inventory_account_type] DROP CONSTRAINT [FK_inventory_account_type_inventory_account_type_group]
GO

GO
/****** Object:  Table [dbo].[inventory_account_type]    Script Date: 10/06/2009 12:37:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[inventory_account_type]') AND type in (N'U'))
DROP TABLE [dbo].[inventory_account_type]
GO
/****** Object:  Table [dbo].[inventory_account_type_group]    Script Date: 10/06/2009 12:37:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[inventory_account_type_group]') AND type in (N'U'))
DROP TABLE [dbo].[inventory_account_type_group]
GO
/****** Object:  Table [dbo].[compliance_year]    Script Date: 10/06/2009 12:37:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[compliance_year]') AND type in (N'U'))
DROP TABLE [dbo].[compliance_year]
GO
/****** Object:  Table [dbo].[calcprocess_inventory_wght_avg_cost]    Script Date: 10/06/2009 12:37:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calcprocess_inventory_wght_avg_cost]') AND type in (N'U'))
DROP TABLE [dbo].[calcprocess_inventory_wght_avg_cost]
GO
/****** Object:  Table [dbo].[calcprocess_inventory_deals]    Script Date: 10/06/2009 12:37:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calcprocess_inventory_deals]') AND type in (N'U'))
DROP TABLE [dbo].[calcprocess_inventory_deals]
GO
/****** Object:  Table [dbo].[report_measurement_values_inventory]    Script Date: 10/06/2009 12:37:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_measurement_values_inventory]') AND type in (N'U'))
DROP TABLE [dbo].[report_measurement_values_inventory]
/****** Object:  Table [dbo].[inventory_account_type]    Script Date: 10/06/2009 12:37:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[inventory_account_type](
	[gl_account_id] [int] IDENTITY(1,1) NOT NULL,
	[group_id] [int] NULL,
	[account_type_value_id] [int] NOT NULL,
	[account_type_name] [varchar](100) NOT NULL,
	[gl_number_id] [int] NULL,
	[use_broker_fees] [char](1) NOT NULL,
	[cost_calc_type] [char](1) NOT NULL,
	[assignment_type_id] [int] NULL,
	[assignment_gl_number_id] [int] NULL,
	[sub_entity_id] [int] NULL,
	[stra_entity_id] [int] NULL,
	[book_entity_id] [int] NULL,
	[technology] [int] NULL,
	[jurisdiction] [int] NULL,
	[gen_state] [int] NULL,
	[curve_id] [int] NULL,
	[vintage] [int] NULL,
	[generator_id] [int] NULL,
	[commodity_id] [int] NULL,
 CONSTRAINT [PK_inventory_account_type] PRIMARY KEY CLUSTERED 
(
	[gl_account_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_inventory_account_type] UNIQUE NONCLUSTERED 
(
	[book_entity_id] ASC,
	[commodity_id] ASC,
	[gen_state] ASC,
	[group_id] ASC,
	[stra_entity_id] ASC,
	[sub_entity_id] ASC,
	[curve_id] ASC,
	[generator_id] ASC,
	[jurisdiction] ASC,
	[technology] ASC,
	[vintage] ASC,
	[account_type_value_id] ASC,
	[assignment_type_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[inventory_account_type_group]    Script Date: 10/06/2009 12:37:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[inventory_account_type_group](
	[group_id] [int] IDENTITY(1,1) NOT NULL,
	[group_name] [varchar](100) NULL,
	[inventory_calc_type_id] [int] NULL,
 CONSTRAINT [PK_inventory_account_type_group] PRIMARY KEY CLUSTERED 
(
	[group_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[compliance_year]    Script Date: 10/06/2009 12:37:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[compliance_year](
	[comp_year] [int] NULL,
	[comp_year_desc] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[calcprocess_inventory_wght_avg_cost]    Script Date: 10/06/2009 12:37:25 ******/
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
	[create_ts] [datetime] NULL,
	[group_id] [int] NULL,
	[gl_account_id] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[calcprocess_inventory_deals]    Script Date: 10/06/2009 12:37:25 ******/
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
/****** Object:  Table [dbo].[report_measurement_values_inventory]    Script Date: 10/06/2009 12:37:25 ******/
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
ALTER TABLE [dbo].[inventory_account_type]  WITH CHECK ADD  CONSTRAINT [FK_inventory_account_type_inventory_account_type_group] FOREIGN KEY([group_id])
REFERENCES [dbo].[inventory_account_type_group] ([group_id])
GO
ALTER TABLE [dbo].[inventory_account_type] CHECK CONSTRAINT [FK_inventory_account_type_inventory_account_type_group]