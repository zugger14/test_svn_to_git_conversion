SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/*
* Created date - 2013-03-21
* Template Table for Deal.
* ixp_source_deal_template
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_source_deal_template]', N'U') IS NOT NULL
BEGIN
	DROP TABLE ixp_source_deal_template
END
IF OBJECT_ID(N'[dbo].[ixp_source_deal_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_source_deal_template] (
    	[deal_id]                         VARCHAR(250),
    	[physical_financial_flag]         VARCHAR(250),
    	[counterparty_id]                 VARCHAR(250),
    	[source_deal_type_id]             VARCHAR(250),
    	[source_deal_sub_type_id]         VARCHAR(250),
    	[option_flag]                     VARCHAR(250),
    	[option_type]                     VARCHAR(250),
    	[option_excercise_type]           VARCHAR(250),
    	[broker_id]                       VARCHAR(250),
    	[unit_fixed_flag]                 VARCHAR(250),
    	[broker_unit_fees]                VARCHAR(250),
    	[broker_fixed_cost]               VARCHAR(250),
    	[broker_currency_id]              VARCHAR(250),
    	[term_frequency]                  VARCHAR(250),
    	[option_settlement_date]          VARCHAR(250),
    	[ext_deal_id]                     VARCHAR(250),
    	[source_system_book_id1]          VARCHAR(250),
    	[source_system_book_id2]          VARCHAR(250),
    	[source_system_book_id3]          VARCHAR(250),
    	[source_system_book_id4]          VARCHAR(250),
    	[description1]                    VARCHAR(260),
    	[description2]                    VARCHAR(260),
    	[description3]                    VARCHAR(260),
    	[deal_category_value_id]          VARCHAR(250),
    	[trader_id]                       VARCHAR(250),
    	[header_buy_sell_flag]            VARCHAR(250),
    	[contract_id]                     VARCHAR(250),
    	[legal_entity]                    VARCHAR(250),
    	[internal_desk_id]                VARCHAR(250),
    	[product_id]                      VARCHAR(250),
    	[internal_portfolio_id]           VARCHAR(250),
    	[commodity_id]                    VARCHAR(250),
    	[reference]                       VARCHAR(250),
    	[block_type]                      VARCHAR(250),
    	[close_reference_id]              VARCHAR(250),
    	[block_define_id]                 VARCHAR(250),
    	[granularity_id]                  VARCHAR(250),
    	[Pricing]                         VARCHAR(250),
    	[deal_status]                     VARCHAR(250),
    	[block_description]               VARCHAR(260),
    	[structured_deal_id]              VARCHAR(250),
    	[template]                        VARCHAR(250),
    	[deal_date]                       VARCHAR(250),
    	[term_start]                      VARCHAR(250),
    	[term_end]                        VARCHAR(250),
    	[Leg]                             VARCHAR(250),
    	[contract_expiration_date]        VARCHAR(250),
    	[fixed_float_leg]                 VARCHAR(250),
    	[buy_sell_flag]                   VARCHAR(250),
    	[curve_id]                        VARCHAR(250),
    	[fixed_price]                     VARCHAR(250),
    	[fixed_price_currency_id]         VARCHAR(250),
    	[option_strike_price]             VARCHAR(250),
    	[deal_volume]                     VARCHAR(250),
    	[deal_volume_frequency]           VARCHAR(250),
    	[deal_volume_uom_id]              VARCHAR(250),
    	[deal_detail_description]         VARCHAR(260),
    	[formula_id]                      VARCHAR(250),
    	[price_adder]                     VARCHAR(250),
    	[price_multiplier]                VARCHAR(250),
    	[settlement_volume]               VARCHAR(250),
    	[settlement_uom]                  VARCHAR(250),
    	[settlement_date]                 VARCHAR(250),
    	[day_count_id]                    VARCHAR(250),
    	[location_id]                     VARCHAR(250),
    	[meter_id]                        VARCHAR(250),
    	[physical_financial_flag_detail]  VARCHAR(250),
    	[fixed_cost]                      VARCHAR(250),
    	[multiplier]                      VARCHAR(250),
    	[adder_currency_id]               VARCHAR(250),
    	[fixed_cost_currency_id]          VARCHAR(250),
    	[formula_currency_id]             VARCHAR(250),
    	[price_adder2]                    VARCHAR(250),
    	[price_adder_currency2]           VARCHAR(250),
    	[volume_multiplier2]              VARCHAR(250),
    	[pay_opposite]                    VARCHAR(200),
    	[capacity]                        VARCHAR(250),
    	[settlement_currency]             VARCHAR(250),
    	[standard_yearly_volume]          VARCHAR(250),
    	[price_uom_id]                    VARCHAR(250),
    	[category]                        VARCHAR(250),
    	[profile_code]                    VARCHAR(250),
    	[pv_party]                        VARCHAR(250),
    	[Intrabook_deal_flag]             CHAR(2),
    	[deal_seperator_id]               VARCHAR(250)
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_source_deal_template EXISTS'
END
 
