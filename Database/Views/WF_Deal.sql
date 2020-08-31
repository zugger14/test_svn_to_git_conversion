IF OBJECT_ID ('WF_Deal', 'V') IS NOT NULL
	DROP VIEW WF_Deal;
GO

-- ===============================================================================================================
-- Author: ryadav@pioneersolutionsglobal.com
-- Create date: 2018-08-14
-- Modified Date: 2019-01-18
-- Description: creates view for portfolio hierarchy, deal header, deal detail and deal audit information
-- ===============================================================================================================

CREATE VIEW [dbo].[WF_Deal]
AS  

	WITH cte AS (
		SELECT sdh.*, ROW_NUMBER() OVER (PARTITION BY sdh.source_deal_header_id ORDER BY sdh.audit_id DESC) row_no
		FROM source_deal_header_audit sdh
	), cte_previous AS (
		SELECT * FROM cte WHERE row_no = 2
	), sdh_compare AS (
			SELECT 
				--portfolio hierarchy columns
				  stra.parent_entity_id [subsidiary]
				, stra.[entity_id] [strategy]
				, book.[entity_id] [book]
				-- Deal header columns
				, sdh.source_deal_header_id
				, sdh.deal_id
				, sdh.deal_date
				, sdh.physical_financial_flag [physical_financial_flag_header]
				, sdh.structured_deal_id
				, sdh.counterparty_id
				, sdh.entire_term_start
				, sdh.entire_term_end
				, sdh.source_deal_type_id
				, sdh.deal_sub_type_type_id
				, sdh.option_flag
				, sdh.option_type
				, sdh.option_excercise_type
				, sdh.description1
				, sdh.description2
				, sdh.description3
				, sdh.deal_category_value_id
				, sdh.trader_id
				, sdh.internal_deal_type_value_id
				, sdh.internal_deal_subtype_value_id
				, sdh.template_id
				, sdh.header_buy_sell_flag
				, sdh.broker_id
				, sdh.generator_id
				, sdh.assignment_type_value_id
				, sdh.compliance_year
				, sdh.state_value_id
				, sdh.assigned_date
				, sdh.assigned_by
				, sdh.contract_id
				, sdh.create_user
				, sdh.create_ts
				, sdh.update_user
				, sdh.update_ts
				, sdh.legal_entity
				, sdh.internal_desk_id
				, sdh.product_id
				, sdh.internal_portfolio_id
				, sdh.commodity_id
				, sdh.deal_locked
				, sdh.close_reference_id
				, sdh.block_define_id
				, sdh.Pricing
				, sdh.deal_status
				, sdh.option_settlement_date
				, sdh.confirm_status_type
				, sdh.sub_book 
				, sdh.description4
				, sdh.timezone_id
				, sdh.counterparty_trader
				, sdh.internal_counterparty
				, sdh.counterparty_id2
				, sdh.trader_id2
				, sdh.inco_terms
				, sdh.scheduler
				, sdh.counterparty2_trader
				, sdh.clearing_counterparty_id
				, sdh.pricing_type [pricing_type_header]
				, sdh.confirmation_type
				, sdh.tier_value_id
				, sdh.holiday_calendar  
				-- Deal detail columns
				, sdd.source_deal_detail_id
				, sdd.term_start
				, sdd.term_end
				, sdd.Leg
				, sdd.contract_expiration_date
				, sdd.fixed_float_leg
				, sdd.buy_sell_flag
				, sdd.curve_id
				, sdd.fixed_price
				, sdd.option_strike_price
				, sdd.deal_volume
				, sdd.volume_left
				, sdd.settlement_volume
				, sdd.settlement_date
				, sdd.location_id
				, sdd.meter_id
				, sdd.physical_financial_flag
				, sdd.total_volume
				, sdd.pay_opposite
				, sdd.capacity
				, sdd.category
				, sdd.[status]
				, sdd.lock_deal_detail
				, sdd.pricing_type
				, sdd.pricing_period
				, sdd.contractual_volume
				, sdd.actual_volume
				, sdd.detail_commodity_id
				, sdd.detail_pricing
				, sdd.upstream_counterparty
				, sdd.upstream_contract
				, sdd.vintage
				--Audit Deal Columns
			    , cp.deal_status [recent_deal_status]
				, cp.confirm_status_type [recent_confirm_status]
			    , IIF(NULLIF(dt.template_id, '') IS NOT NULL, 'y', 'n') is_valid_template
				, ISNULL(dc_rule.r_exists, 'n') is_confirmation_required
				, sdd.price_adder
				, DATEDIFF(MONTH, sdh.entire_term_start, sdh.entire_term_end) + 1 [tenor_month]
				, sdh.source_system_book_id1
				, sdh.source_system_book_id2
				, sdh.source_system_book_id3
				, sdh.source_system_book_id4
				, cca.is_prepay_deal [is_prepay_deal]
			FROM source_deal_header sdh  
			LEFT JOIN cte_previous cp ON sdh.source_deal_header_id = cp.source_deal_header_id
			LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = sdh.sub_book
			LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
			LEFT JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id 
			OUTER APPLY (
				SELECT gmv.clm1_value [template_id]
				FROM generic_mapping_header gmh
				INNER JOIN generic_mapping_values gmv
				ON gmh.mapping_table_id = gmv.mapping_table_id 
					AND ISNULL(NULLIF(gmv.clm1_value, ''), -1) = CAST(ISNULL(NULLIF(sdh.template_id,''),-1) AS VARCHAR(20))
                    AND  ISNULL(ISNULL(gmv.clm2_value, sdh.commodity_id), -1)  = CAST(ISNULL(NULLIF(sdh.commodity_id, ''),-1) AS VARCHAR(20))
                    AND ISNULL(ISNULL(gmv.clm3_value,sdh.source_deal_type_id), -1)  = CAST(ISNULL(NULLIF(sdh.source_deal_type_id,''),-1) AS VARCHAR(20))
                    AND ISNULL(ISNULL(gmv.clm4_value, sdh.deal_sub_type_type_id), -1)  = CAST(ISNULL(NULLIF(sdh.deal_sub_type_type_id, ''),-1) AS VARCHAR(20))
                    AND ISNULL(ISNULL(gmv.clm5_value, sdh.pricing_type), -1) = CAST(ISNULL(NULLIF(sdh.pricing_type,''),-1) AS VARCHAR(20))
				WHERE mapping_name = 'Valid Templates' 
			) dt
			OUTER APPLY (
				SELECT 'y' r_exists FROM deal_confirmation_rule dcr 
				WHERE ISNULL(ISNULL(dcr.counterparty_id, sdh.counterparty_id), 1) = ISNULL(sdh.counterparty_id, 1)
				AND ISNULL(ISNULL(dcr.deal_type_id, sdh.source_deal_type_id),1) = ISNULL(sdh.source_deal_type_id,1)
				AND ISNULL(ISNULL(dcr.deal_sub_type, sdh.deal_sub_type_type_id),1) = ISNULL(sdh.deal_sub_type_type_id,1)
				AND COALESCE(dcr.buy_sell_flag, sdh.header_buy_sell_flag, '1') = CASE WHEN dcr.buy_sell_flag = 'a' THEN 'a' ELSE COALESCE(sdh.header_buy_sell_flag, '1') END
				AND ISNULL(dcr.deal_template_id, sdh.template_id) = sdh.template_id
				------ISNULL(ISNULL(dcr.origin, sdd.origin), 1) = ISNULL(sdd.origin, 1)
				AND ISNULL(ISNULL(dcr.commodity_id, sdh.commodity_id), 1) = ISNULL(sdh.commodity_id, 1)  
				AND ISNULL(ISNULL(dcr.contract_id, sdh.contract_id), 1) = ISNULL(sdh.contract_id,1)
				AND ISNULL(ISNULL(dcr.confirm_status, sdh.confirm_status_type),1) = ISNULL(sdh.confirm_status_type,1)
				AND ISNULL(ISNULL(dcr.deal_status, sdh.deal_status),1) = ISNULL(sdh.deal_status,1)
				--AND ISNULL(ISNULL(dcr.book, sdh.sub_book), 1) = ISNULL(sdh.sub_book, 1)
				AND ISNULL(ISNULL(dcr.[location], sdd.location_id), 1) = ISNULL(sdd.location_id, 1)
				------AND ISNULL(ISNULL(dcr.[location_group], sdd.loc_group), 1) = ISNULL(sdd.loc_group, 1)
				AND ISNULL(ISNULL(dcr.index_id, sdd.curve_id), 1) = ISNULL(sdd.curve_id, 1)
				--	----AND ISNULL(ISNULL(dcr.index_group, sdd.ind_group), 1) = ISNULL(sdd.ind_group, 1)
			) dc_rule
			OUTER APPLY(
				SELECT ISNULL(MAX(prepay), 'n') is_prepay_deal FROM counterparty_contract_address cca WHERE cca.counterparty_id = sdh.counterparty_id AND cca.contract_id = sdh.contract_id
			) cca
	) 

	SELECT * FROM sdh_compare
			
