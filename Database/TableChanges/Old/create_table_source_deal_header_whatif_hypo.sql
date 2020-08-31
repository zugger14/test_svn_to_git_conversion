/****** Object:  Table [dbo].[source_deal_header_whatif_hypo]    Script Date: 08/23/2012 10:14:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[source_deal_header_whatif_hypo]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[source_deal_header_whatif_hypo](
	[source_deal_header_id] [int] NOT NULL,
	[source_system_id] [int] NOT NULL,
	[deal_id] [varchar](50) NOT NULL,
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
	[internal_deal_type_value_id] [int] NULL,
	[internal_deal_subtype_value_id] [int] NULL,
	[template_id] [int] NULL,
	[header_buy_sell_flag] [varchar](1) NULL,
	[broker_id] [int] NULL,
	[generator_id] [int] NULL,
	[status_value_id] [int] NULL,
	[status_date] [datetime] NULL,
	[assignment_type_value_id] [int] NULL,
	[compliance_year] [int] NULL,
	[state_value_id] [int] NULL,
	[assigned_date] [datetime] NULL,
	[assigned_by] [varchar](50) NULL,
	[generation_source] [varchar](250) NULL,
	[aggregate_environment] [varchar](1) NULL,
	[aggregate_envrionment_comment] [varchar](250) NULL,
	[rec_price] [float] NULL,
	[rec_formula_id] [int] NULL,
	[rolling_avg] [char](1) NULL,
	[contract_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[legal_entity] [int] NULL,
	[internal_desk_id] [int] NULL,
	[product_id] [int] NULL,
	[internal_portfolio_id] [int] NULL,
	[commodity_id] [int] NULL,
	[reference] [varchar](250) NULL,
	[deal_locked] [char](1) NULL,
	[close_reference_id] [int] NULL,
	[block_type] [int] NULL,
	[block_define_id] [int] NULL,
	[granularity_id] [int] NULL,
	[Pricing] [int] NULL,
	[deal_reference_type_id] [int] NULL,
	[unit_fixed_flag] [char](1) NULL,
	[broker_unit_fees] [float] NULL,
	[broker_fixed_cost] [float] NULL,
	[broker_currency_id] [int] NULL,
	[deal_status] [int] NULL,
	[term_frequency] [char](1) NULL,
	[option_settlement_date] [datetime] NULL,
	[verified_by] [varchar](50) NULL,
	[verified_date] [datetime] NULL,
	[risk_sign_off_by] [varchar](50) NULL,
	[risk_sign_off_date] [datetime] NULL,
	[back_office_sign_off_by] [varchar](50) NULL,
	[back_office_sign_off_date] [datetime] NULL,
	[book_transfer_id] [int] NULL,
	[confirm_status_type] [int] NULL
) 
END
ELSE
	BEGIN
		PRINT 'Table source_deal_header_whatif_hypo EXISTS'
	END
GO

IF NOT EXISTS(SELECT * FROM source_deal_header_whatif_hypo)
BEGIN
	INSERT INTO [dbo].[source_deal_header_whatif_hypo]([source_deal_header_id], [source_system_id], [deal_id], [deal_date], [ext_deal_id], [physical_financial_flag], [structured_deal_id], [counterparty_id], [entire_term_start], [entire_term_end], [source_deal_type_id], [deal_sub_type_type_id], [option_flag], [option_type], [option_excercise_type], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4], [description1], [description2], [description3], [deal_category_value_id], [trader_id], [internal_deal_type_value_id], [internal_deal_subtype_value_id], [template_id], [header_buy_sell_flag], [broker_id], [generator_id], [status_value_id], [status_date], [assignment_type_value_id], [compliance_year], [state_value_id], [assigned_date], [assigned_by], [generation_source], [aggregate_environment], [aggregate_envrionment_comment], [rec_price], [rec_formula_id], [rolling_avg], [contract_id], [create_user], [create_ts], [update_user], [update_ts], [legal_entity], [internal_desk_id], [product_id], [internal_portfolio_id], [commodity_id], [reference], [deal_locked], [close_reference_id], [block_type], [block_define_id], [granularity_id], [Pricing], [deal_reference_type_id], [unit_fixed_flag], [broker_unit_fees], [broker_fixed_cost], [broker_currency_id], [deal_status], [term_frequency], [option_settlement_date], [verified_by], [verified_date], [risk_sign_off_by], [risk_sign_off_date], [back_office_sign_off_by], [back_office_sign_off_date], [book_transfer_id], [confirm_status_type])
	SELECT 2, 2, N'GEE02736','20100709 00:00:00.000', NULL, N'f', NULL, 1,'20120101 00:00:00.000', '20120131 00:00:00.000', 8, 3, N'n', NULL, NULL, 171, 168, 169, -4, NULL, NULL, NULL, 476, 1, 1, 1, -1, N'b', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'n', NULL, 0, NULL, NULL, NULL, N'mrutgers', '20120612 13:36:01.010', N'farrms_admin', '20120823 11:09:36.350', NULL, 17300, NULL, NULL, NULL, NULL, N'n', NULL, NULL, NULL, NULL, NULL, NULL, N'u', NULL, NULL, NULL, 5605, N'm', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 17200 
	UNION ALL  
	SELECT 1, 2, N'156086-farrms','20120723 00:00:00.000', NULL, N'f', NULL, 33,'20120801 00:00:00.000', '20120831 00:00:00.000', 8, 3, N'n', NULL, NULL, 171, 168, 169, -4, NULL, NULL, NULL, 475, 1, 1, 1, -1, N's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'n', NULL, 0, NULL, NULL, 7, N'mrutgers', '20120726 13:57:25.577', N'mrutgers', '20120726 13:57:53.327', NULL, 17300, NULL, NULL, 11, NULL, N'n', NULL, NULL, NULL, NULL, 1601, NULL, N'u', NULL, NULL, NULL, 5605, N'm', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 17200
END	
UPDATE source_deal_header_whatif_hypo SET deal_category_value_id = 475 WHERE source_deal_header_id = 2