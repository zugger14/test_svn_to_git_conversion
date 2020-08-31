--select * from source_deal_header
--select * from source_deal_detail
TRUNCATE TABLE master_deal_view

SELECT  uddf.source_deal_header_id [Id],
        (sdv.code + ': ''' + uddf.udf_value) + '''' [udf]
INTO #temp       
FROM   source_deal_header sdh
       INNER JOIN user_defined_deal_fields uddf ON  uddf.source_deal_header_id = sdh.source_deal_header_id
       INNER JOIN user_defined_deal_fields_template udft ON  udft.udf_template_id = uddf.udf_template_id
       INNER JOIN static_data_value sdv ON  sdv.value_id = udft.field_name
     
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
              FROM   #temp t
              WHERE  t.id = tt.id
              ORDER BY t.id
              FOR XML PATH('')
			) [fld]
        FROM   #temp tt
        ) [Main]
WHERE Main.fld IS NOT NULL  

	INSERT INTO master_deal_view
	SELECT --top 1
		sdh.source_deal_header_id,
		sdh.source_system_id,
		sdh.deal_id,
		sdh.deal_date,
		sdh.ext_deal_id,
		CASE WHEN sdh.physical_financial_flag ='p' THEN 'Physical' ELSE 'Financial' END physical_financial,
		sdh.structured_deal_id,
		sc.counterparty_name counterparty,
		sc_p.counterparty_name parent_counterparty,	
		sdh.entire_term_start,
		sdh.entire_term_end,
		sdt.source_deal_type_name deal_type,
		sdt1.source_deal_type_name deal_sub_type,
		[dbo].FNAGetAbbreviationDef(sdh.option_flag) As option_flag,
		[dbo].FNAGetAbbreviationDef(sdh.option_type) As option_type, 
		[dbo].FNAGetAbbreviationDef(sdh.option_excercise_type) As option_excercise_type,
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
		au_cr.user_f_name+' '+au_cr.user_l_name [create_user],
		sdh.create_ts,
		au_upd.user_f_name+' '+au_upd.user_l_name [update_user],
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
		sdv_status.code	deal_status,
		sdv_cst.code confirm_status_type,
		MIN(sdd.term_start) term_start,
		MAX(sdd.term_end) term_start,
		MAX(sdd.contract_expiration_date)contract_expiration_date,
		CASE WHEN sdd.fixed_float_leg = 't' THEN 'Float' ELSE 'Fixed' END fixed_float,
		CASE WHEN sdd.buy_sell_flag = 'b' THEN 'Buy' ELSE 'Sell' END buy_sell,
		spcd.curve_name index_name,
		price_com.commodity_name index_commodity,
		price_cur.currency_name index_currency,
		price_uom.uom_name index_uom,
		spcd_proxy1.curve_name index_proxy1,
		spcd_proxy2.curve_name index_proxy2,
		NULL index_proxy3,--spcd_proxy3.curve_name index_proxy3,
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
		udf_table.udf UDF,
		CONVERT(VARCHAR(100), sdh.deal_date, 120) deal_date_varchar,
		CONVERT(VARCHAR(100), sdh.entire_term_start, 120) entire_term_start_varchar,
		CONVERT(VARCHAR(100), sdh.entire_term_end, 120) entire_term_end_varchar
	FROM 
		source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id=sdh.counterparty_id
		LEFT JOIN source_counterparty sc_p ON sc_p.source_counterparty_id=sc.parent_counterparty_id
		LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id= sdh.source_deal_type_id
		LEFT JOIN source_deal_type sdt1 ON sdt1.source_deal_type_id= sdh.deal_sub_type_type_id
		LEFT OUTER JOIN source_book sb1 ON sdh.source_system_book_id1 = sb1.source_book_id 
		LEFT OUTER JOIN source_book sb2 ON sdh.source_system_book_id2 = sb2.source_book_id 
		LEFT OUTER JOIN source_book sb3 ON sdh.source_system_book_id3 = sb3.source_book_id 
		LEFT OUTER JOIN source_book sb4 ON sdh.source_system_book_id4 = sb4.source_book_id 
		LEFT JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2 
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4 
		LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id=	ssbm.fas_book_id AND ph1.hierarchy_level=0
		LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id=	ph1.parent_entity_id AND ph2.hierarchy_level=1
		LEFT JOIN portfolio_hierarchy ph3 ON ph3.entity_id=	ph2.parent_entity_id AND ph3.hierarchy_level=2
		LEFT JOIN static_data_value sdv_dealcategory On sdv_dealcategory.value_id =sdh.deal_category_value_id
		LEFT JOIN source_traders st ON st.source_trader_id = sdh.trader_id
		LEFT JOIN internal_deal_type_subtype_types idtst ON idtst.internal_deal_type_subtype_id=sdh.internal_deal_type_value_id
		LEFT JOIN internal_deal_type_subtype_types idtst1 ON idtst1.internal_deal_type_subtype_id=sdh.internal_deal_subtype_value_id
		LEFT JOIN source_deal_header_template sdht ON sdht.template_id=sdh.template_id
		LEFT JOIN source_brokers sb ON sb.source_broker_id=sdh.broker_id
		LEFT JOIN rec_generator rg ON rg.generator_id=sdh.generator_id 
		LEFT JOIN static_data_value sdv_assignment On sdv_assignment.value_id=sdh.assignment_type_value_id
		LEFT JOIN static_data_value sdv_state On sdv_state.value_id=sdh.state_value_id
		LEFT JOIN contract_group cg On cg.contract_id=sdh.contract_id
		LEFT JOIN application_users au_cr On au_cr.user_login_id=sdh.create_user
		LEFT JOIN application_users au_upd On au_upd.user_login_id=sdh.update_user
		LEFT JOIN application_users au1 On au1.user_login_id=sdh.update_user
		LEFT JOIN static_data_value sdv_le On sdv_le.value_id=sdh.legal_entity
		LEFT JOIN static_data_value sdv_id On sdv_id.value_id=sdh.internal_desk_id
		LEFT JOIN static_data_value sdv_product On sdv_product.value_id=sdh.product_id
		LEFT JOIN static_data_value sdv_ipi On sdv_ipi.value_id=sdh.internal_portfolio_id
		LEFT JOIN source_commodity s_com ON s_com.source_commodity_id=sdh.commodity_id
		LEFT JOIN static_data_value sdv_block On sdv_block.value_id=sdh.block_type
		LEFT JOIN static_data_value sdv_block_definition On sdv_block_definition.value_id=sdh.block_define_id
		LEFT JOIN static_data_value sdv_gran On sdv_gran.value_id=sdh.granularity_id
		LEFT JOIN static_data_value sdv_pricing On sdv_pricing.value_id=sdh.Pricing
		LEFT JOIN static_data_value sdv_ref_type On sdv_ref_type.value_id=sdh.deal_reference_type_id
		LEFT JOIN static_data_value sdv_status On sdv_status.value_id=sdh.deal_status
		LEFT JOIN static_data_value sdv_cst On sdv_status.value_id=sdh.confirm_status_type		
		LEFT JOIN source_price_curve_def spcd On spcd.source_curve_def_id=sdd.curve_id
		LEFT JOIN source_commodity price_com ON price_com.source_commodity_id=spcd.commodity_id
		LEFT JOIN source_currency price_cur ON price_cur.source_currency_id=spcd.source_currency_id
		LEFT JOIN source_uom price_uom ON price_uom.source_uom_id=spcd.uom_id
		LEFT JOIN source_price_curve_def spcd_proxy1 ON spcd_proxy1.source_curve_def_id=spcd.proxy_source_curve_def_id
		LEFT JOIN source_price_curve_def spcd_proxy2 ON spcd_proxy2.source_curve_def_id=spcd.monthly_index
		--LEFT JOIN source_price_curve_def spcd_proxy3 ON spcd_proxy3.source_curve_def_id=spcd.proxy_curve_id3
		LEFT JOIN source_price_curve_def spcd_sett ON spcd_sett.source_curve_def_id=spcd.settlement_curve_id
		LEFT JOIN static_data_value sdv_exp_calen ON sdv_exp_calen.value_id=spcd.exp_calendar_id
		LEFT JOIN formula_editor fe ON fe.formula_id=sdd.formula_id
		LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id
		LEFT JOIN static_data_value loc_region ON loc_region.value_id=sml.region
		LEFT JOIN static_data_value loc_grid ON loc_grid.value_id=sml.grid_value_id
		LEFT JOIN static_data_value loc_country ON loc_country.value_id=sml.country
		LEFT JOIN source_major_location smj ON smj.source_major_location_ID=sml.source_major_location_ID
		LEFT JOIN forecast_profile fp ON fp.profile_id=sml.profile_id
		LEFT JOIN forecast_profile fp1 ON fp1.profile_id=sml.proxy_profile_id
		LEFT JOIN static_data_value sdv_profile_type ON sdv_profile_type.value_id=fp.profile_type
		LEFT JOIN static_data_value sdv_proxy_profile_type ON sdv_proxy_profile_type.value_id=fp1.profile_type
		LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id=sml.source_minor_location_id
		LEFT JOIN meter_id mi ON mi.meter_id=smlm.meter_id
		LEFT JOIN static_data_value sdv_prof_code ON sdv_prof_code.value_id=sdd.profile_code
		LEFT JOIN static_data_value sdv_pvparty ON sdv_pvparty.value_id=sdd.pv_party
		LEFT JOIN #udf_table udf_table ON udf_table.id = sdh.source_deal_header_id
	GROUP BY 
		sdh.source_deal_header_id,
		sdh.source_system_id,
		sdh.deal_id,
		sdh.deal_date,
		sdh.ext_deal_id,
		sdh.physical_financial_flag,
		sdh.structured_deal_id,
		sc.counterparty_name ,
		sc_p.counterparty_name ,	
		sdh.entire_term_start,
		sdh.entire_term_end,
		sdt.source_deal_type_name ,
		sdt1.source_deal_type_name ,
		[dbo].FNAGetAbbreviationDef(sdh.option_flag)  ,
		[dbo].FNAGetAbbreviationDef(sdh.option_type)  , 
		[dbo].FNAGetAbbreviationDef(sdh.option_excercise_type),
		sb1.source_book_name ,
		sb2.source_book_name ,
		sb3.source_book_name ,
		sb4.source_book_name ,
		ph3.entity_name ,
		ph2.entity_name ,
		ph1.entity_name ,
		sdh.description1,
		sdh.description2,
		sdh.description3,
		sdv_dealcategory.code ,
		st.trader_name ,
		idtst.internal_deal_type_subtype_type ,
		idtst1.internal_deal_type_subtype_type ,
		sdht.template_name ,
		sb.broker_name ,
		rg.name ,
		sdh.status_date ,
		sdv_assignment.code ,
		sdh.compliance_year,
		sdv_state.code ,
		sdh.assigned_date,
		sdh.assigned_by ,
		cg.contract_name ,
		au_cr.user_f_name+' '+au_cr.user_l_name ,
		sdh.create_ts,
		au_upd.user_f_name+' '+au_upd.user_l_name ,
		sdh.update_ts,
		sdv_le.code ,
		sdv_id.code ,
		sdv_product.code ,
		sdv_ipi.code ,
		s_com.commodity_name ,
		sdh.reference,
		sdh.deal_locked ,
		sdh.close_reference_id,
		sdv_block.code ,
		sdv_block_definition.code ,
		sdv_gran.code ,
		sdv_pricing.code ,
		sdv_ref_type.value_id ,
		sdv_status.code	,
		sdv_cst.code ,
		sdd.fixed_float_leg ,
		sdd.buy_sell_flag ,
		spcd.curve_name ,
		price_com.commodity_name ,
		price_cur.currency_name ,
		price_uom.uom_name ,
		spcd_proxy1.curve_name ,
		spcd_proxy2.curve_name ,
		--spcd_proxy3.curve_name ,
		spcd_sett.curve_name ,
		sdv_exp_calen.code ,
		fe.formula ,
		sml.Location_Name ,
		loc_region.code ,
		loc_grid.code ,
		loc_country.code ,
		smj.location_name ,
		fp.external_id ,
		fp1.external_id ,
		sdv_profile_type.code ,
		sdv_proxy_profile_type.code ,
		mi.recorderid,
		sdv_prof_code.code,
		sdv_pvparty.code,
		udf_table.udf
		
		
DROP TABLE #temp
DROP TABLE #udf_table		