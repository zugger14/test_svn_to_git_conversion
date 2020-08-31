/****** Object:  StoredProcedure [dbo].[spa_source_deal_header_template]    Script Date: 01/17/2012 11:30:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[spa_source_deal_header_template_paging]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_source_deal_header_template_paging]
GO


/**
	Wrapper Stored Procedure for spa_source_deal_header_template to enable paging

	Parameters 
	@flag : Flag
	@template_id : Template Id
	@template_name : Template Name
	@physical_financial_flag : Physical Financial Flag
	@term_frequency_value : Term Frequency Value
	@term_frequency_type : Term Frequency Type
	@option_flag : Option Flag
	@option_type : Option Type
	@option_exercise_type : Option Exercise Type
	@description1 : Description1
	@description2 : Description2
	@description3 : Description3
	@buy_sell_flag : Buy Sell Flag
	@source_deal_type_id : Source Deal Type Id
	@deal_sub_type_type_id : Deal Sub Type Type Id
	@is_active : Is Active
	@internal_flag : Internal Flag
	@internal_deal_type_value_id : Internal Deal Type Value Id
	@internal_deal_subtype_value_id : Internal Deal Subtype Value Id
	@allow_edit_term : Allow Edit Term
	@blotter_support : Blotter Support
	@rollover_to_spot : Rollover To Spot
	@discounting_applies : Discounting Applies
	@term_end_flag : Term End Flag
	@is_public : Is Public
	@deal_status : Deal Status
	@deal_category_value_id : Deal Category Value Id
	@legal_entity : Legal Entity
	@commodity_id : Commodity Id
	@internal_portfolio_id : Internal Portfolio Id
	@product_id : Product Id
	@internal_desk_id : Internal Desk Id
	@blocktypecombo : Blocktypecombo
	@blockdefinitioncombo : Blockdefinitioncombo
	@granularitycombo : Granularitycombo
	@price : Price
	@model_id : Model Id
	@comments : Comments
	@trade_ticket_template : Trade Ticket Template
	@hourly_position_breakdown : Hourly Position Breakdown
	@counterparty_id : Counterparty Id
	@contract_id : Contract Id
	@fieldTemplateId : FieldTemplateId
	@trader_id : Trader Id
	@source_deal_header_id : Source Deal Header Id
	@source_system_id : Source System Id
	@deal_id : Deal Id
	@deal_date : Deal Date
	@ext_deal_id : Ext Deal Id
	@structured_deal_id : Structured Deal Id
	@entire_term_start : Entire Term Start
	@entire_term_end : Entire Term End
	@option_excercise_type : Option Excercise Type
	@broker_id : Broker Id
	@generator_id : Generator Id
	@status_value_id : Status Value Id
	@status_date : Status Date
	@assignment_type_value_id : Assignment Type Value Id
	@compliance_year : Compliance Year
	@state_value_id : State Value Id
	@assigned_date : Assigned Date
	@assigned_by : Assigned By
	@generation_source : Generation Source
	@aggregate_environment : Aggregate Environment
	@aggregate_envrionment_comment : Aggregate Envrionment Comment
	@rec_price : Rec Price
	@rec_formula_id : Rec Formula Id
	@rolling_avg : Rolling Avg
	@reference : Reference
	@deal_locked : Deal Locked
	@close_reference_id : Close Reference Id
	@deal_reference_type_id : Deal Reference Type Id
	@unit_fixed_flag : Unit Fixed Flag
	@broker_unit_fees : Broker Unit Fees
	@broker_fixed_cost : Broker Fixed Cost
	@broker_currency_id : Broker Currency Id
	@term_frequency : Term Frequency
	@option_settlement_date : Option Settlement Date
	@verified_by : Verified By
	@verified_date : Verified Date
	@risk_sign_off_by : Risk Sign Off By
	@risk_sign_off_date : Risk Sign Off Date
	@back_office_sign_off_by : Back Office Sign Off By
	@back_office_sign_off_date : Back Office Sign Off Date
	@book_transfer_id : Book Transfer Id
	@confirm_status_type : Confirm Status Type
	@udf_field : Udf Field
	@udf_value : Udf Value
	@deal_rules : Deal Rules
	@confirm_rule : Confirm Rule
	@role_id : Role Id
	@batch_process_id : Batch Process Id
	@page_size : Page Size
	@page_no : Page No
	@calculate_position_based_on_actual : Calculate Position Based On Actual
	@save_mtm_at_calculation_granularity : Save Mtm At Calculation Granularity
	@timezone_id : Timezone Id
	@ignore_bom : Ignore Bom
	@year : Year
	@month : Month
	@certificate : Certificate
	@counterparty_id2 : Counterparty Id2
	@trader_id2 : Trader Id2
	@scheduler : Scheduler
	@inco_terms : Inco Terms
	@governing_law : Governing Law
	@sample_control : Sample Control
	@payment_term : Payment Term
	@payment_days : Payment Days
	@arbitration : Arbitration
	@counterparty2_trader : Counterparty2 Trader
	@options_calc_method : Options Calc Method
	@attribute_type : Attribute Type
	@pricing_type : Pricing Type
	@clearing_counterparty_id : Clearing Counterparty Id
	@underlying_options : Underlying Options
	@confirmation_type : Confirmation Type
	@confirmation_template : Confirmation Template
	@sdr : Sdr
	@tier_value_id : Tier Value Id
	@fx_conversion_market : Fx Conversion Market
	@bid_n_ask_price : Bid N Ask Price
	@holiday_calendar : Holiday Calendar
	@collateral_amount : Collateral Amount
	@collateral_req_per : Collateral Req Per
	@collateral_months : Collateral Months
	@match_type : Match Type
	@product_classification : Product Classification
	@fas_deal_type_value_id : Fas Deal Type Value Id
	@reporting_tier_id : Reporting Tier Id
	@reporting_jurisdiction_id : Reporting Jurisdiction Id
	@reporting_group1 : Reporting Group 1
	@reporting_group2 : Reporting Group 2
	@reporting_group3 : Reporting Group 3
	@reporting_group4 : Reporting Group 4
	@reporting_group5 : Reporting Group 5
*/

CREATE PROC [dbo].[spa_source_deal_header_template_paging]
		@flag NCHAR(1),
		@template_id INT = NULL,
		@template_name AS NVARCHAR(50)= NULL,
		@physical_financial_flag AS NCHAR(1)=NULL,
		@term_frequency_value AS NCHAR(1) =NULL,
		@term_frequency_type AS NCHAR(1) =NULL,
		@option_flag AS NCHAR(1)  =NULL,
		@option_type AS NCHAR(1)  =NULL,
		@option_exercise_type AS NCHAR(1)  =NULL,
		@description1 NVARCHAR(50) = NULL,
		@description2 NVARCHAR(50) = NULL,
		@description3 NVARCHAR(50) = NULL,
		@buy_sell_flag NCHAR(1)  =NULL,
		@source_deal_type_id INT  =NULL,
		@deal_sub_type_type_id INT  =NULL,
		@is_active NCHAR(1) =NULL,
		@internal_flag NCHAR(1)=NULL,
		@internal_deal_type_value_id INT=NULL,
		@internal_deal_subtype_value_id INT=NULL,
		@allow_edit_term NCHAR(1)=NULL,
		@blotter_support NCHAR(1)=NULL,
		@rollover_to_spot NCHAR(1)=NULL,
		@discounting_applies NCHAR(1)=NULL,
		@term_end_flag NCHAR(1)=NULL,
		@is_public NCHAR(1) =NULL,
		@deal_status INT=NULL,
		@deal_category_value_id INT=NULL,
		@legal_entity INT=NULL,
		@commodity_id INT=NULL,
		@internal_portfolio_id INT=NULL,
		@product_id INT=NULL,
		@internal_desk_id INT=NULL,
		@blocktypecombo INT=NULL,
		@blockdefinitioncombo INT=NULL,
		@granularitycombo INT=NULL,
		@price INT=NULL,
		@model_id INT=NULL,
		@comments NCHAR(1)=NULL,
		@trade_ticket_template NCHAR(1) = NULL,
		@hourly_position_breakdown NVARCHAR(10) = NULL,
		@counterparty_id INT = NULL,
		@contract_id INT = NULL,
		@fieldTemplateId INT = NULL,
		@trader_id INT=NULL,
		@source_deal_header_id INT = NULL,
		@source_system_id INT = NULL,
		@deal_id NVARCHAR(50) = NULL,
		@deal_date DATETIME = NULL,
		@ext_deal_id NVARCHAR(50) = NULL,
		@structured_deal_id NVARCHAR(50) = NULL,
		@entire_term_start DATETIME = NULL,
		@entire_term_end DATETIME = NULL,
		@option_excercise_type NCHAR(1) = NULL,		
		@broker_id INT = NULL,
		@generator_id INT = NULL,
		@status_value_id INT = NULL,
		@status_date DATETIME = NULL,
		@assignment_type_value_id INT = NULL,
		@compliance_year INT = NULL,
		@state_value_id INT = NULL,
		@assigned_date DATETIME = NULL,
		@assigned_by NVARCHAR(50) = NULL,
		@generation_source NVARCHAR(250) = NULL,
		@aggregate_environment NVARCHAR(1) = NULL,
		@aggregate_envrionment_comment NVARCHAR(250) = NULL,
		@rec_price FLOAT = NULL,
		@rec_formula_id INT = NULL,
		@rolling_avg NCHAR(1) = NULL,
		@reference NVARCHAR(250) = NULL,
		@deal_locked NCHAR(1) = NULL,
		@close_reference_id INT = NULL,
		@deal_reference_type_id INT = NULL,
		@unit_fixed_flag NCHAR = NULL,
		@broker_unit_fees FLOAT = NULL,
		@broker_fixed_cost FLOAT = NULL,
		@broker_currency_id INT = NULL,
		@term_frequency NCHAR(1) = NULL,
		@option_settlement_date DATETIME = NULL,
		@verified_by NVARCHAR(50) = NULL,
		@verified_date DATETIME = NULL,
		@risk_sign_off_by NVARCHAR(50) = NULL,
		@risk_sign_off_date DATETIME = NULL,
		@back_office_sign_off_by NVARCHAR(50) = NULL,
		@back_office_sign_off_date DATETIME = NULL,
		@book_transfer_id INT = NULL,
		@confirm_status_type INT = NULL,
		@udf_field NVARCHAR(max) = NULL,
		@udf_value NVARCHAR(max) = NULL,
		@deal_rules INT = NULL,
		@confirm_rule INT = NULL,
		@role_id INT = NULL  ,
		@batch_process_id NVARCHAR(250) = NULL,
		@page_size INT = NULL,
		@page_no INT = NULL,
		@calculate_position_based_on_actual NCHAR(1) = NULL,
		@save_mtm_at_calculation_granularity INT = NULL,
		@timezone_id INT = NULL,
		@ignore_bom NCHAR(1) = null,
		@year INT = null,
		@month INT = null,
        @certificate NCHAR(1) = NULL,
        @counterparty_id2 INT = NULL,
        @trader_id2 INT = NULL,
		@scheduler INT = NULL,
		@inco_terms  INT = NULL,
		@governing_law  INT = NULL,
		@sample_control  NCHAR(1) = NULL,
		@payment_term  INT = NULL,
		@payment_days  INT = NULL,
		@arbitration INT = NULL,
		@counterparty2_trader INT = NULL,
		@options_calc_method INT = NULL,
		@attribute_type INT = NULL,
		@pricing_type INT = NULL,
		@clearing_counterparty_id INT = NULL,
		@underlying_options INT = NULL,
		@confirmation_type INT = NULL,
		@confirmation_template INT = NULL,
		@sdr NCHAR(1) = NULL,
		@tier_value_id INT = NULL,
		@fx_conversion_market INT = NULL,
		@bid_n_ask_price NCHAR(1) = NULL,
		@holiday_calendar INT = NULL,
		@collateral_amount NUMERIC(38, 20) = NULL,
		@collateral_req_per FLOAT = NULL,
		@collateral_months INT = NULL,
		@match_type NCHAR(1) = NULL,
		@product_classification INT = NULL,
		@fas_deal_type_value_id INT = NULL,
		@reporting_tier_id INT = NULL,
		@reporting_jurisdiction_id INT = NULL,
		@reporting_group1 NVARCHAR(1000) = NULL, 
		@reporting_group2 NVARCHAR(1000) = NULL, 
		@reporting_group3 NVARCHAR(1000) = NULL, 
		@reporting_group4 NVARCHAR(1000) = NULL, 
		@reporting_group5 NVARCHAR(1000) = NULL 
AS
EXEC spa_source_deal_header_template
		@flag ,
		@template_id ,
		@template_name ,
		@physical_financial_flag ,
		@term_frequency_value,
		@term_frequency_type ,
		@option_flag ,
		@option_type ,
		@option_exercise_type ,
		@description1 ,
		@description2 ,
		@description3 ,
		@buy_sell_flag ,
		@source_deal_type_id ,
		@deal_sub_type_type_id ,
		@is_active,
		@internal_flag,
		@internal_deal_type_value_id ,
		@internal_deal_subtype_value_id ,
		@allow_edit_term,
		@blotter_support,
		@rollover_to_spot,
		@discounting_applies,
		@term_end_flag,
		@is_public,
		@deal_status ,
		@deal_category_value_id ,
		@legal_entity ,
		@commodity_id ,
		@internal_portfolio_id ,
		@product_id ,
		@internal_desk_id ,
		@blocktypecombo ,
		@blockdefinitioncombo ,
		@granularitycombo ,
		@price ,
		@model_id ,
		@comments,
		@trade_ticket_template ,
		@hourly_position_breakdown ,
		@counterparty_id ,
		@contract_id ,
		@fieldTemplateId ,
		@trader_id ,
		@source_deal_header_id ,
		@source_system_id ,
		@deal_id  ,
		@deal_date  ,
		@ext_deal_id  ,
		@structured_deal_id  ,
		@entire_term_start  ,
		@entire_term_end  ,
		@option_excercise_type ,		
		@broker_id ,
		@generator_id ,
		@status_value_id ,
		@status_date  ,
		@assignment_type_value_id ,
		@compliance_year ,
		@state_value_id ,
		@assigned_date  ,
		@assigned_by  ,
		@generation_source  ,
		@aggregate_environment  ,
		@aggregate_envrionment_comment  ,
		@rec_price  ,
		@rec_formula_id ,
		@rolling_avg ,
		@reference  ,
		@deal_locked ,
		@close_reference_id ,
		@deal_reference_type_id ,
		@unit_fixed_flag  ,
		@broker_unit_fees  ,
		@broker_fixed_cost  ,
		@broker_currency_id ,
		@term_frequency ,
		@option_settlement_date  ,
		@verified_by  ,
		@verified_date  ,
		@risk_sign_off_by  ,
		@risk_sign_off_date  ,
		@back_office_sign_off_by  ,
		@back_office_sign_off_date  ,
		@book_transfer_id ,
		@confirm_status_type ,
		@udf_field  ,
		@udf_value  ,
		@deal_rules ,
		@confirm_rule ,
		@role_id  ,
		@batch_process_id  ,
		NULL,
		1,
		@page_size ,
		@page_no,
		@calculate_position_based_on_actual,
		@save_mtm_at_calculation_granularity,
		@timezone_id,
		@ignore_bom,
		@year,
		@month,
        @certificate,
        @counterparty_id2,
        @trader_id2,
        @scheduler,
		@inco_terms,
		@governing_law,
		@sample_control,
		@payment_term,
		@payment_days,
		@arbitration,
		@counterparty2_trader
		,@options_calc_method
		,@attribute_type,
		@pricing_type,
		@clearing_counterparty_id,
		@underlying_options,
		@confirmation_type,
		@confirmation_template,
		@sdr,
		@tier_value_id,
		@fx_conversion_market,
		@bid_n_ask_price,
		@holiday_calendar,
		@collateral_amount,
		@collateral_req_per,
		@collateral_months,
		@match_type,
		@product_classification,
		@fas_deal_type_value_id,
		@reporting_tier_id,
		@reporting_jurisdiction_id,
		@reporting_group1, 
		@reporting_group2, 
		@reporting_group3, 
		@reporting_group4, 
		@reporting_group5 

		