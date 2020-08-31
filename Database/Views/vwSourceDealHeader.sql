IF OBJECT_ID ('vwSourceDealHeader', 'V') IS NOT NULL
	DROP VIEW vwSourceDealHeader;
GO

-- ===============================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2016-07-01
-- Modified date: 2016-07-01
-- Description: View to be used in workflow and alert 
-- ===============================================================================================================
CREATE VIEW [dbo].[vwSourceDealHeader]
AS 

SELECT	sdh.source_deal_header_id,
		sdh.source_system_id,
		sdh.deal_id,
		sdh.deal_date,
		sdh.ext_deal_id,
		sdh.physical_financial_flag,
		sdh.structured_deal_id,
		sdh.counterparty_id,
		sdh.entire_term_start,
		sdh.entire_term_end,
		sdh.source_deal_type_id,
		sdh.deal_sub_type_type_id,
		sdh.option_flag,
		sdh.option_type,
		sdh.option_excercise_type,
		sdh.source_system_book_id1,
		sdh.source_system_book_id2,
		sdh.source_system_book_id3,
		sdh.source_system_book_id4,
		sdh.description1,
		sdh.description2,
		sdh.description3,
		sdh.deal_category_value_id,
		sdh.trader_id,
		sdh.internal_deal_type_value_id,
		sdh.internal_deal_subtype_value_id,
		sdh.template_id,
		sdh.header_buy_sell_flag,
		sdh.broker_id,
		sdh.generator_id,
		sdh.status_value_id,
		sdh.status_date,
		sdh.assignment_type_value_id,
		sdh.compliance_year,
		sdh.state_value_id,
		sdh.assigned_date,
		sdh.assigned_by,
		sdh.generation_source,
		sdh.aggregate_environment,
		sdh.aggregate_envrionment_comment,
		sdh.rec_price,
		sdh.rec_formula_id,
		sdh.rolling_avg,
		sdh.contract_id,
		sdh.create_user,
		sdh.create_ts,
		sdh.update_user,
		sdh.update_ts,
		sdh.legal_entity,
		sdh.internal_desk_id,
		sdh.product_id,
		sdh.internal_portfolio_id,
		sdh.commodity_id,
		sdh.reference,
		sdh.deal_locked,
		sdh.close_reference_id,
		sdh.block_type,
		sdh.block_define_id,
		sdh.granularity_id,
		sdh.Pricing,
		sdh.deal_reference_type_id,
		sdh.unit_fixed_flag,
		sdh.broker_unit_fees,
		sdh.broker_fixed_cost,
		sdh.broker_currency_id,
		sdh.deal_status,
		sdh.term_frequency,
		sdh.option_settlement_date,
		sdh.verified_by,
		sdh.verified_date,
		sdh.risk_sign_off_by,
		sdh.risk_sign_off_date,
		sdh.back_office_sign_off_by,
		sdh.back_office_sign_off_date,
		sdh.book_transfer_id,
		sdh.confirm_status_type,
		sdh.sub_book,
		sdh.deal_rules,
		sdh.confirm_rule,
		sdh.description4,
		sdh.timezone_id,
		sdh.reference_detail_id,
		sdh.counterparty_trader,
		sdh.internal_counterparty,
		sdh.settlement_vol_type,
		sdh.counterparty_id2,
		sdh.trader_id2,
		sdh.inco_terms,
		sdh.scheduler,
		sdh.sample_control,
		sdh.payment_term,
		sdh.payment_days,
		sdh.governing_law,
		aud.deal_status [recent_deal_status], 
		aud.confirm_status_type [recent_confirm_status],
		stra.parent_entity_id [subsidiary],
		stra.[entity_id] [strategy],
		book.[entity_id] [book],
		DATEDIFF(DAY,sdh.deal_date,sdh.entire_term_end) [deal_date_term_difference], 
		CASE WHEN gmv.generic_mapping_values_id IS NULL THEN 'n' ELSE 'y' END [valid_template]
FROM source_deal_header sdh
LEFT JOIN source_deal_header_audit_view aud ON sdh.source_deal_header_id = aud.source_deal_header_id
LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = sdh.sub_book
LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
LEFT JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id
LEFT JOIN generic_mapping_values gmv ON gmv.clm1_value = CAST(sdh.template_id AS VARCHAR) AND gmv.mapping_table_id = (SELECT mapping_table_id  FROM generic_mapping_header  WHERE mapping_name = 'Valid Templates')
 
GO


