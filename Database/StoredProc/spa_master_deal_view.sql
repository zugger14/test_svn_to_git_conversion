IF OBJECT_ID(N'[dbo].[spa_master_deal_view]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_master_deal_view]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
Used for CRUD operation for master_deal_view table
Parameters:
	@flag					 : 'i' insert data
								'd' delete data
	@source_deal_header_id	 : Source Deal Header IDs
	@deal_process_table		 : Process table name
*/
CREATE PROCEDURE [dbo].[spa_master_deal_view]
    @flag CHAR(1),
    @source_deal_header_id VARCHAR(MAX) = NULL,
    @deal_process_table VARCHAR(400) = NULL
AS
SET NOCOUNT ON
/*
declare @flag CHAR(1)='i',
    @source_deal_header_id VARCHAR(MAX) = NULL,
    @deal_process_table VARCHAR(400) = 'adiha_process.dbo.search_table_farrms_admin_229DA65D_D16D_4540_973B_0E696D5391FE'
--*/
IF OBJECT_ID('tempdb..#temp_search_deal') IS NOT NULL
	DROP TABLE #temp_search_deal	
CREATE TABLE #temp_search_deal (source_deal_header_id INT)
	
IF @source_deal_header_id IS NOT NULL
BEGIN
	INSERT INTO #temp_search_deal (source_deal_header_id)
	SELECT scsv.item FROM dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
END
ELSE IF @deal_process_table IS NOT NULL
BEGIN
	DECLARE @sql VARCHAR(MAX)
	SET @sql = 'INSERT INTO #temp_search_deal (source_deal_header_id)
				SELECT DISTINCT source_deal_header_id FROM ' + @deal_process_table
	EXEC(@sql)
END

IF @flag = 'i'
BEGIN
	IF OBJECT_ID('tempdb..#temp_master_deal_view') is not null
		DROP TABLE #temp_master_deal_view

	SELECT uddf.source_deal_header_id [Id],
	       (sdv.code + ': ''' + uddf.udf_value) + '''' [udf]
	INTO #temp_master_deal_view
	FROM   source_deal_header sdh
	INNER JOIN #temp_search_deal temp_deal ON temp_deal.source_deal_header_id = sdh.source_deal_header_id       
	INNER JOIN user_defined_deal_fields_template udft ON  udft.template_id = sdh.template_id
		INNER JOIN user_defined_deal_fields uddf ON  uddf.source_deal_header_id = sdh.source_deal_header_id AND uddf.udf_template_id = udft.udf_template_id
	INNER JOIN static_data_value sdv ON  sdv.value_id = udft.field_name
     
	IF OBJECT_ID('tempdb..#udf_table') is not null
		DROP TABLE #udf_table 
		  
	SELECT Main.id,
		   LEFT(
			   Main.fld,
			   CASE 
					WHEN LEN(Main.fld) -1 > 0 THEN LEN(Main.fld) -1
					ELSE 0
			   END
		   ) AS [udf]
	INTO #udf_table       
	FROM   (SELECT DISTINCT tt.id,
				(
				  SELECT ISNULL(udf, NULL) + ', ' AS [text()]
				  FROM   #temp_master_deal_view t
				  WHERE  t.id = tt.id
				  ORDER BY t.id
				  FOR XML PATH('')
				) [fld]
			FROM   #temp_master_deal_view tt
			) [Main]
	WHERE Main.fld IS NOT NULL

	--collect PGS ids
	SELECT ca.commodity_attribute_id
			, ca.commodity_name
			, caf.commodity_attribute_form_id
			, caf.commodity_form_name
			, caf.commodity_attribute_value
		INTO #commodity_attribute_form_detail
	FROM commodity_attribute ca
	INNER JOIN commodity_attribute_form caf ON caf.commodity_attribute_id = ca.commodity_attribute_id


	
	INSERT INTO master_deal_view (
		 source_deal_header_id
		, source_system_id
		, deal_id
		, deal_date
		, ext_deal_id
		, physical_financial
		, structured_deal_id
		, counterparty
		, parent_counterparty
		, entire_term_start
		, entire_term_end
		, deal_type
		, deal_sub_type
		, option_flag
		, option_type
		, option_excercise_type
		, source_system_book_id1
		, source_system_book_id2
		, source_system_book_id3
		, source_system_book_id4
		, subsidiary
		, strategy
		, Book
		, description1
		, description2
		, description3
		, deal_category
		, trader
		, internal_deal_type
		, internal_deal_subtype
		, template
		, broker
		, generator
		, deal_status_date
		, assignment_type
		, compliance_year
		, state_value
		, assigned_date
		, assigned_user
		, contract
		, create_user
		, create_ts
		, update_user
		, update_ts
		, legal_entity
		, deal_profile
		, fixation_type
		, internal_portfolio
		, commodity
		, reference
		, locked_deal
		, close_reference_id
		, block_type
		, block_definition
		, granularity
		, pricing
		, deal_reference_type
		, deal_status
		, confirm_status_type
		, term_start
		, term_end
		, contract_expiration_date
		, fixed_float
		, buy_sell
		, index_name
		, index_commodity
		, index_currency
		, index_uom
		, index_proxy1
		, index_proxy2
		, index_proxy3
		, index_settlement
		, expiration_calendar
		, deal_formula
		, location
		, location_region
		, location_grid
		, location_country
		, location_group
		, forecast_profile
		, forecast_proxy_profile
		, profile_type
		, proxy_profile_type
		, meter
		, profile_code
		, Pr_party
		, UDF
		, deal_date_varchar
		, entire_term_start_varchar
		, entire_term_end_varchar
		, scheduler
		, inco_terms
		, detail_inco_terms
		, trader2
		, counterparty2
		, origin
		, form
		, organic
		, attribute1
		, attribute2
		, attribute3
		, attribute4
		, attribute5
		, governing_law
		, payment_term
		, arbitration
		, counterparty2_trader
		, counterparty_trader
		, batch_id
		, buyer_seller_option
		, crop_year
		, product_description
		, reporting_group1
		, reporting_group2
		, reporting_group3
		, reporting_group4
		, reporting_group5
		
		)
	SELECT sdh.source_deal_header_id,
		sdh.source_system_id,
		sdh.deal_id,
		sdh.deal_date,
		sdh.ext_deal_id,
		CASE 
			WHEN sdh.physical_financial_flag = 'p' THEN 'Physical'
			ELSE 'Financial'
		END physical_financial,
		sdh.structured_deal_id,
		sc.counterparty_name counterparty,
		sc_p.counterparty_name parent_counterparty,
		sdh.entire_term_start,
		sdh.entire_term_end,
		sdt.source_deal_type_name deal_type,
		sdt1.source_deal_type_name deal_sub_type,
		[dbo].FNAGetAbbreviationDef(sdh.option_flag) AS option_flag,
		[dbo].FNAGetAbbreviationDef(sdh.option_type) AS option_type,
		[dbo].FNAGetAbbreviationDef(sdh.option_excercise_type) AS option_excercise_type,
		sb1.source_book_name source_system_book_id1,
		sb2.source_book_name source_system_book_id2,
		sb3.source_book_name source_system_book_id3,
		sb4.source_book_name source_system_book_id4,
		ph3.entity_name subsidiary,
		ph2.entity_name strategy,
		ph1.entity_name Book,
		sdh.description1,
		sdh.description2,
		sdh.description3,
		sdv_dealcategory.code deal_category,
		st.trader_name trader,
		idtst.internal_deal_type_subtype_type internal_deal_type,
		idtst1.internal_deal_type_subtype_type internal_deal_subtype,
		sdht.template_name [template],
		sb.broker_name [broker],
		rg.name generator,
		sdh.status_date deal_status_date,
		sdv_assignment.code assignment_type,
		sdh.compliance_year,
		sdv_state.code state_value,
		sdh.assigned_date,
		sdh.assigned_by assigned_user,
		cg.contract_name [contract],
		au_cr.user_f_name + ' ' + au_cr.user_l_name [create_user],
		sdh.create_ts,
		au_upd.user_f_name + ' ' + au_upd.user_l_name [update_user],
		sdh.update_ts,
		sdv_le.code legal_entity,
		sdv_id.code deal_profile,
		sdv_product.code fixation_type,
		sdv_ipi.code internal_portfolio,
		s_com.commodity_name commodity,
		sdh.reference,
		sdh.deal_locked locked_deal,
		sdh.close_reference_id,
		sdv_block.code block_type,
		sdv_block_definition.code block_definition,
		sdv_gran.code granularity,
		sdv_pricing.code pricing,
		sdv_ref_type.value_id deal_reference_type,
		sdv_status.code deal_status,
		sdv_cst.code confirm_status_type,
		MIN(sdd.term_start) term_start,
		MAX(sdd.term_end) term_end,
		MAX(sdd.contract_expiration_date)contract_expiration_date,
		CASE 
			WHEN sdd.fixed_float_leg = 't' THEN 'Float'
			ELSE 'Fixed'
		END fixed_float,
		CASE 
			WHEN sdd.buy_sell_flag = 'b' THEN 'Buy'
			ELSE 'Sell'
		END buy_sell,
		spcd.curve_name index_name,
		price_com.commodity_name index_commodity,
		price_cur.currency_name index_currency,
		price_uom.uom_name index_uom,
		spcd_proxy1.curve_name index_proxy1,
		spcd_proxy2.curve_name index_proxy2,
		NULL index_proxy3,	--spcd_proxy3.curve_name index_proxy3,
		spcd_sett.curve_name index_settlement,
		sdv_exp_calen.code expiration_calendar,
		fe.formula deal_formula,
		sml.Location_Name location,
		loc_region.code location_region,
		loc_grid.code location_grid,
		loc_country.code location_country,
		smj.location_name location_group,
		fp.external_id forecast_profile,
		fp1.external_id forecast_proxy_profile,
		sdv_profile_type.code profile_type,
		sdv_proxy_profile_type.code proxy_profile_type,
		mi.recorderid meter,
		sdv_prof_code.code profile_code,
		sdv_pvparty.code Pr_party,
		t.udf [UDF],
		CONVERT(VARCHAR(100), sdh.deal_date, 120) [deal_date_varchar],
		CONVERT(VARCHAR(100), sdh.entire_term_start, 120) [entire_term_start_varchar],
		CONVERT(VARCHAR(100), sdh.entire_term_end, 120) [entire_term_end_varchar],
		cc_scheduler.name [scheduler],
		sdv_it.code [inco_terms],
		sdv_it2.code [detail_inco_terms],
		sc2.trader_name [trader2],
		sco2.counterparty_name [counterparty2],
		sdv_origin.code origin,

		cfn.code form,

		CASE WHEN sdd.organic = 'y' THEN 'Yes' ELSE 'No' END [organic],
		sdv1.code [attribute1],
		sdv2.code [attribute2],
		sdv3.code [attribute3],
		sdv4.code [attribute4],
		sdv5.code [attribute5],
		sdv_gov_law.code [governing_law],
		sdv_payment_term.code [payment_term],
		sdv_arbitration.code [arbitration],
		counterparty2_trader.name [counterparty2_trader],
		counterparty_trader.name [counterparty_trader],
		sdd.batch_id [batch_id],
		sdv_buyer_seller_option.code [buyer_seller_option],
		sdv_crop_year.code [crop_year],
		sdd.product_description [product_description],
		reporting_group1.code reporting_group1,
		reporting_group2.code reporting_group2,
		reporting_group3.code reporting_group3,
		reporting_group4.code reporting_group4,
		reporting_group5.code reporting_group5
	FROM   source_deal_header sdh
	INNER JOIN #temp_search_deal temp_deal ON temp_deal.source_deal_header_id = sdh.source_deal_header_id	
	INNER JOIN source_deal_detail sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN source_counterparty sc ON  sc.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN source_counterparty sc_p ON sc_p.source_counterparty_id = sc.parent_counterparty_id
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	LEFT JOIN source_deal_type sdt1 ON sdt1.source_deal_type_id = sdh.deal_sub_type_type_id
	LEFT OUTER JOIN source_book sb1 ON sdh.source_system_book_id1 = sb1.source_book_id
	LEFT OUTER JOIN source_book sb2 ON sdh.source_system_book_id2 = sb2.source_book_id
	LEFT OUTER JOIN source_book sb3 ON sdh.source_system_book_id3 = sb3.source_book_id
	LEFT OUTER JOIN source_book sb4 ON sdh.source_system_book_id4 = sb4.source_book_id
	LEFT JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
	    AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
	    AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
	    AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
	LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id = ssbm.fas_book_id
	    AND ph1.hierarchy_level = 0
	LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id = ph1.parent_entity_id
	    AND ph2.hierarchy_level = 1
	LEFT JOIN portfolio_hierarchy ph3 ON ph3.entity_id = ph2.parent_entity_id
	    AND ph3.hierarchy_level = 2
	LEFT JOIN static_data_value sdv_dealcategory ON sdv_dealcategory.value_id = sdh.deal_category_value_id
	LEFT JOIN source_traders st ON st.source_trader_id = sdh.trader_id
	LEFT JOIN internal_deal_type_subtype_types idtst ON idtst.internal_deal_type_subtype_id = sdh.internal_deal_type_value_id
	LEFT JOIN internal_deal_type_subtype_types idtst1 ON idtst1.internal_deal_type_subtype_id = sdh.internal_deal_subtype_value_id
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	LEFT JOIN source_brokers sb ON sb.source_broker_id = sdh.broker_id
	LEFT JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	LEFT JOIN static_data_value sdv_assignment ON sdv_assignment.value_id = sdh.assignment_type_value_id
	LEFT JOIN static_data_value sdv_state ON sdv_state.value_id = sdh.state_value_id
	LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
	LEFT JOIN application_users au_cr ON au_cr.user_login_id = sdh.create_user
	LEFT JOIN application_users au_upd ON au_upd.user_login_id = sdh.update_user
	LEFT JOIN application_users au1 ON au1.user_login_id = sdh.update_user
	LEFT JOIN static_data_value sdv_le ON sdv_le.value_id = sdh.legal_entity
	LEFT JOIN static_data_value sdv_id ON sdv_id.value_id = sdh.internal_desk_id
	LEFT JOIN static_data_value sdv_product ON sdv_product.value_id = sdh.product_id
	LEFT JOIN static_data_value sdv_ipi ON sdv_ipi.value_id = sdh.internal_portfolio_id
	LEFT JOIN source_commodity s_com ON s_com.source_commodity_id = sdh.commodity_id
	LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = sdh.block_type
	LEFT JOIN static_data_value sdv_block_definition ON sdv_block_definition.value_id = sdh.block_define_id
	LEFT JOIN static_data_value sdv_gran ON sdv_gran.value_id = sdh.granularity_id
	LEFT JOIN static_data_value sdv_pricing ON sdv_pricing.value_id = sdh.Pricing
	LEFT JOIN static_data_value sdv_ref_type ON sdv_ref_type.value_id = sdh.deal_reference_type_id
	LEFT JOIN static_data_value sdv_status ON sdv_status.value_id = sdh.deal_status
	LEFT JOIN static_data_value sdv_cst ON sdv_cst.value_id = sdh.confirm_status_type
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
	LEFT JOIN source_commodity price_com ON price_com.source_commodity_id = spcd.commodity_id
	LEFT JOIN source_currency price_cur ON price_cur.source_currency_id = spcd.source_currency_id
	LEFT JOIN source_uom price_uom ON price_uom.source_uom_id = spcd.uom_id
	LEFT JOIN source_price_curve_def spcd_proxy1 ON spcd_proxy1.source_curve_def_id = spcd.proxy_source_curve_def_id
	LEFT JOIN source_price_curve_def spcd_proxy2 ON spcd_proxy2.source_curve_def_id = spcd.monthly_index
	--LEFT JOIN source_price_curve_def spcd_proxy3 ON spcd_proxy3.source_curve_def_id=spcd.proxy_curve_id3
	LEFT JOIN source_price_curve_def spcd_sett ON spcd_sett.source_curve_def_id = spcd.settlement_curve_id
	LEFT JOIN static_data_value sdv_exp_calen ON sdv_exp_calen.value_id = spcd.exp_calendar_id
	LEFT JOIN formula_editor fe ON fe.formula_id = sdd.formula_id
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
	LEFT JOIN static_data_value loc_region ON loc_region.value_id = sml.region
	LEFT JOIN static_data_value loc_grid ON loc_grid.value_id = sml.grid_value_id
	LEFT JOIN static_data_value loc_country ON loc_country.value_id = sml.country
	LEFT JOIN source_major_location smj ON smj.source_major_location_ID = sml.source_major_location_ID
	LEFT JOIN forecast_profile fp ON fp.profile_id = sml.profile_id
	LEFT JOIN forecast_profile fp1 ON fp1.profile_id = sml.proxy_profile_id
	LEFT JOIN static_data_value sdv_profile_type ON sdv_profile_type.value_id = fp.profile_type
	LEFT JOIN static_data_value sdv_proxy_profile_type ON sdv_proxy_profile_type.value_id = fp1.profile_type
	LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sml.source_minor_location_id
	LEFT JOIN meter_id mi ON mi.meter_id = smlm.meter_id
	LEFT JOIN static_data_value sdv_prof_code ON sdv_prof_code.value_id = sdd.profile_code
	LEFT JOIN static_data_value sdv_pvparty ON sdv_pvparty.value_id = sdd.pv_party
	LEFT JOIN counterparty_contacts cc_scheduler ON cc_scheduler.counterparty_contact_id = sdh.scheduler AND cc_scheduler.contact_type = -32300
	LEFT JOIN source_traders sc2 ON sc2.source_trader_id = sdh.trader_id2
	LEFT JOIN source_counterparty sco2 ON  sco2.source_counterparty_id = sdh.counterparty_id2


	LEFT JOIN commodity_origin co ON co.commodity_origin_id = sdd.origin
	LEFT JOIN static_data_value sdv_origin ON sdv_origin.value_id = co.origin	
	       
	--LEFT JOIN commodity_form cf ON cf.commodity_form_id = sdd.[form]
	--LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = cf.[form]
	LEFT JOIN commodity_form cf ON cf.commodity_form_id = sdd.form
	LEFT JOIN commodity_type_form commodity_form ON commodity_form.commodity_type_form_id = cf.form
	LEFT JOIN static_data_value cfn ON cfn.value_id = commodity_form.commodity_form_value


	--LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = sdd.attribute1
	--LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
	--LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id = sdd.attribute2
	--LEFT JOIN commodity_attribute_form caf2 on caf2.commodity_attribute_form_id = cfa2.attribute_form_id	       
	--LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = sdd.attribute3
	--LEFT JOIN commodity_attribute_form caf3 on caf3.commodity_attribute_form_id = cfa3.attribute_form_id	       
	--LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = sdd.attribute4
	--LEFT JOIN commodity_attribute_form caf4 on caf4.commodity_attribute_form_id = cfa4.attribute_form_id	       
	--LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = sdd.attribute5
	--LEFT JOIN commodity_attribute_form caf5 on caf5.commodity_attribute_form_id = cfa5.attribute_form_id


	LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = sdd.attribute1
	LEFT JOIN #commodity_attribute_form_detail cafd1 ON cafd1.commodity_attribute_id = cfa1.attribute_id
		AND cafd1.commodity_attribute_form_id = cfa1.attribute_form_id
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cafd1.commodity_attribute_value
				
	LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id = sdd.attribute2
	LEFT JOIN #commodity_attribute_form_detail cafd2 ON cafd2.commodity_attribute_id = cfa2.attribute_id
		AND cafd2.commodity_attribute_form_id = cfa2.attribute_form_id
	LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cafd2.commodity_attribute_value

	LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = sdd.attribute3
	LEFT JOIN #commodity_attribute_form_detail cafd3 ON cafd3.commodity_attribute_id = cfa3.attribute_id
		AND cafd3.commodity_attribute_form_id = cfa3.attribute_form_id
	LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cafd3.commodity_attribute_value

	LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = sdd.attribute4
	LEFT JOIN #commodity_attribute_form_detail cafd4 ON cafd4.commodity_attribute_id = cfa4.attribute_id
		AND cafd4.commodity_attribute_form_id = cfa4.attribute_form_id
	LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cafd4.commodity_attribute_value

	LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = sdd.attribute5
	LEFT JOIN #commodity_attribute_form_detail cafd5 ON cafd5.commodity_attribute_id = cfa5.attribute_id
		AND cafd5.commodity_attribute_form_id = cfa5.attribute_form_id
	LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cafd5.commodity_attribute_value

	LEFT JOIN static_data_value sdv_it ON sdv_it.value_id = sdh.inco_terms AND sdv_it.[type_id] = 40200
	LEFT JOIN static_data_value sdv_it2 ON sdv_it2.value_id = sdd.detail_inco_terms AND sdv_it2.[type_id] = 40200
	LEFT JOIN #udf_table t ON  t.id = sdh.source_deal_header_id

	LEFT JOIN static_data_value sdv_gov_law ON sdv_gov_law.value_id = sdh.governing_law AND sdv_gov_law.[type_id] = 40300
	LEFT JOIN static_data_value sdv_payment_term ON sdv_payment_term.value_id = sdh.payment_term AND sdv_payment_term.[type_id] = 20000
	LEFT JOIN static_data_value sdv_arbitration ON sdv_arbitration.value_id = sdh.arbitration AND sdv_arbitration.[type_id] = 42300
	LEFT JOIN counterparty_contacts counterparty2_trader ON counterparty2_trader.counterparty_contact_id = sdh.counterparty2_trader
	LEFT JOIN counterparty_contacts counterparty_trader ON counterparty_trader.counterparty_contact_id = sdh.counterparty_trader
	LEFT JOIN static_data_value sdv_buyer_seller_option ON sdv_buyer_seller_option.value_id = sdd.buyer_seller_option AND sdv_buyer_seller_option.[type_id] = 40400
	LEFT JOIN static_data_value sdv_crop_year ON sdv_crop_year.value_id = sdd.crop_year AND sdv_crop_year.[type_id] = 10092
	LEFT JOIN static_data_value reporting_group1 ON reporting_group1.value_id = sdh.[reporting_group1] AND reporting_group1.type_id = 113000
	LEFT JOIN static_data_value reporting_group2 ON reporting_group2.value_id = sdh.[reporting_group2] AND reporting_group2.type_id = 113100
	LEFT JOIN static_data_value reporting_group3 ON reporting_group3.value_id = sdh.[reporting_group3] AND reporting_group3.type_id = 113200
	LEFT JOIN static_data_value reporting_group4 ON reporting_group4.value_id = sdh.[reporting_group4] AND reporting_group4.type_id = 113300
	LEFT JOIN static_data_value reporting_group5 ON reporting_group5.value_id = sdh.[reporting_group5] AND reporting_group5.type_id = 113400
	
	GROUP BY sdh.source_deal_header_id,
	    sdh.source_system_id,
	    sdh.deal_id,
	    sdh.deal_date,
	    sdh.ext_deal_id,
	    sdh.physical_financial_flag,
	    sdh.structured_deal_id,
	    sc.counterparty_name,
	    sc_p.counterparty_name,
	    sdh.entire_term_start,
	    sdh.entire_term_end,
	    sdt.source_deal_type_name,
	    sdt1.source_deal_type_name,
	    [dbo].FNAGetAbbreviationDef(sdh.option_flag),
	    [dbo].FNAGetAbbreviationDef(sdh.option_type),
	    [dbo].FNAGetAbbreviationDef(sdh.option_excercise_type),
	    sb1.source_book_name,
	    sb2.source_book_name,
	    sb3.source_book_name,
	    sb4.source_book_name,
	    ph3.entity_name,
	    ph2.entity_name,
	    ph1.entity_name,
	    sdh.description1,
	    sdh.description2,
	    sdh.description3,
	    sdv_dealcategory.code,
	    st.trader_name,
	    idtst.internal_deal_type_subtype_type,
	    idtst1.internal_deal_type_subtype_type,
	    sdht.template_name,
	    sb.broker_name,
	    rg.name,
	    sdh.status_date,
	    sdv_assignment.code,
	    sdh.compliance_year,
	    sdv_state.code,
	    sdh.assigned_date,
	    sdh.assigned_by,
	    cg.contract_name,
	    au_cr.user_f_name + ' ' + au_cr.user_l_name,
	    sdh.create_ts,
	    au_upd.user_f_name + ' ' + au_upd.user_l_name,
	    sdh.update_ts,
	    sdv_le.code,
	    sdv_id.code,
	    sdv_product.code,
	    sdv_ipi.code,
	    s_com.commodity_name,
	    sdh.reference,
	    sdh.deal_locked,
	    sdh.close_reference_id,
	    sdv_block.code,
	    sdv_block_definition.code,
	    sdv_gran.code,
	    sdv_pricing.code,
	    sdv_ref_type.value_id,
	    sdv_status.code,
	    sdv_cst.code,
	    sdd.fixed_float_leg,
	    sdd.buy_sell_flag,
	    spcd.curve_name,
	    price_com.commodity_name,
	    price_cur.currency_name,
	    price_uom.uom_name,
	    spcd_proxy1.curve_name,
	    spcd_proxy2.curve_name,
	    --spcd_proxy3.curve_name ,
	    spcd_sett.curve_name,
	    sdv_exp_calen.code,
	    fe.formula,
	    sml.Location_Name,
	    loc_region.code,
	    loc_grid.code,
	    loc_country.code,
	    smj.location_name,
	    fp.external_id,
	    fp1.external_id,
	    sdv_profile_type.code,
	    sdv_proxy_profile_type.code,
	    mi.recorderid,
	    sdv_prof_code.code,
	    sdv_pvparty.code,
	    t.udf,
	    cc_scheduler.name,
	    sc2.trader_name,
	    sco2.counterparty_name,
	    sdv_origin.code,
	    cfn.code,
	    sdd.organic,
	    sdv1.code,
	    sdv2.code,
	    sdv3.code,
	    sdv4.code,
	    sdv5.code,
	    sdv_it.code,
	    sdv_it2.code,
		sdv_gov_law.code,
		sdv_payment_term.code ,
		sdv_arbitration.code ,
		counterparty2_trader.name,
		counterparty_trader.name,
		sdd.batch_id,
		sdv_buyer_seller_option.code,
		sdv_crop_year.code,
		sdd.product_description,
		reporting_group1.code,
		reporting_group2.code,
		reporting_group3.code,
		reporting_group4.code,
		reporting_group5.code
	DROP TABLE #temp_master_deal_view
	DROP TABLE #udf_table	       
END
ELSE IF @flag = 'd'
BEGIN
	DELETE FROM master_deal_view WHERE source_deal_header_id IN (SELECT source_deal_header_id FROM delete_source_deal_header)	
END
ELSE IF @flag = 'u'
BEGIN
	DELETE master_deal_view
	FROM #temp_search_deal temp_deal
	INNER JOIN master_deal_view mdv ON mdv.source_deal_header_id = temp_deal.source_deal_header_id
	
	IF @source_deal_header_id IS NOT NULL
		EXEC spa_master_deal_view 'i', @source_deal_header_id, NULL
	
	IF @deal_process_table IS NOT NULL
		EXEC spa_master_deal_view 'i', NULL, @deal_process_table	
END