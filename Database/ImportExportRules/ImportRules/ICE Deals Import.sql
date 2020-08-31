BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '4236B5F9_1C09_460E_9E41_738C9C6CCA04'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'ICE Deals'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'ICE Deals' ,
					'N' ,
					NULL ,
					'IF OBJECT_ID(''tempdb..#ICE_Product_Template_Mapping'') IS NOT NULL
DROP TABLE #ICE_Product_Template_Mapping

SELECT gmv.clm1_value [ICE_Product],  sdht.template_id, sdht.template_name, sdt.source_deal_type_id, sdt.deal_type_id, sdv.code [internal_portfolio_id], cg.source_contract_id [contract_id], sdv_b.code [block_define_id]
INTO #ICE_Product_Template_Mapping
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header smh
	ON smh.mapping_table_id = gmv.mapping_table_id
LEFT JOIN source_deal_header_template sdht
	ON sdht.template_id = CAST(gmv.clm2_value AS INT)
LEFT JOIN source_deal_type sdt
	ON sdt.source_deal_type_id = CAST(gmv.clm3_value AS INT)
LEFT JOIN static_data_value sdv
	ON sdv.value_id = CAST(gmv.clm4_value AS INT) and sdv.type_id =39800
LEFT JOIN contract_group cg ON cg.contract_id = CAST(gmv.clm5_value AS INT)
LEFT JOIN static_data_value sdv_b
	ON sdv_b.value_id = CAST(gmv.clm6_value AS INT) and sdv_b.type_id =10018
WHERE smh.mapping_name = ''ICE Product Template Mapping''
IF OBJECT_ID(''tempdb..#ICE_Trader_Mapping'') IS NOT NULL
DROP TABLE #ICE_Trader_Mapping

SELECT gmv.clm1_value [ICE_Trader], st.source_trader_id, st.trader_id
INTO #ICE_Trader_Mapping
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header smh
	ON smh.mapping_table_id = gmv.mapping_table_id
LEFT JOIN source_traders st ON st.source_trader_id = CAST(gmv.clm2_value AS INT)
WHERE smh.mapping_name = ''ICE Trader Mapping''

IF OBJECT_ID(''tempdb..#ICE_Hub_Mapping'') IS NOT NULL
DROP TABLE #ICE_Hub_Mapping

SELECT gmv.clm1_value [ICE_Hub], spcd.source_curve_def_id, spcd.curve_id
INTO #ICE_Hub_Mapping
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header smh
	ON smh.mapping_table_id = gmv.mapping_table_id
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = CAST(gmv.clm2_value AS INT)
WHERE smh.mapping_name = ''ICE Hub Mapping''


UPDATE ft
SET ft.[source_deal_type_id] = ISNULL(iptm.deal_type_id,ft.[source_deal_type_id] )
	, ft.template_id = ISNULL(iptm.template_name, ft.template_id)
	, ft.internal_portfolio_id = ISNULL(iptm.internal_portfolio_id, ft.internal_portfolio_id)
	, ft.contract_id = ISNULL(iptm.contract_id, ft.contract_id)
	, ft.block_define_id = ISNULL(iptm.block_define_id, ft.block_define_id)
FROM [temp_process_table] TEMP
LEFT JOIN [final_process_table] ft ON temp.DealId = ft.deal_id
LEFT JOIN ice_security_definition isd ON isd.leg_symbol = TEMP.ProductId  OR isd.symbol = TEMP.ProductId
OUTER APPLY (
	SELECT ip.[ICE_Product]
		, ip.template_name
		, ip.deal_type_id
		, ip.internal_portfolio_id
		, ip.contract_id
		, ip.block_define_id
	FROM #ICE_Product_Template_Mapping ip
	WHERE ip.ICE_Product = ISNULL(isd.product_name,''Default'')
	) iptm


UPDATE ft
SET ft.counterparty_id = ISNULL(cpty.counterparty_id, ft.counterparty_id)
FROM [temp_process_table] temp
LEFT JOIN [final_process_table] ft ON temp.DealId = ft.deal_id
OUTER APPLY (
	SELECT gmv.clm1_value [ICE_Counterparty]
		, sc.source_counterparty_id
		, sc.counterparty_id
	FROM generic_mapping_values gmv
	INNER JOIN generic_mapping_header smh
		ON smh.mapping_table_id = gmv.mapping_table_id
	LEFT JOIN source_counterparty sc
		ON sc.source_counterparty_id = CAST(gmv.clm2_value AS INT)
	WHERE smh.mapping_name = ''ICE Counterparty Mapping'' AND gmv.clm1_value  = temp.CounterpartyId1
	) cpty

UPDATE ft
SET ft.trader_id = ISNULL(td.trader_id, ft.trader_id)
FROM [temp_process_table] temp
LEFT JOIN [final_process_table] ft ON temp.DealId = ft.deal_id
OUTER APPLY (
	SELECT st.[ICE_Trader]
		, st.source_trader_id
		, st.trader_id
	FROM #ICE_Trader_Mapping st
	WHERE st.[ICE_Trader] = TEMP.Trader
	) td

UPDATE  
 ft
SET ft.sub_book = ISNULL(ihm1.logical_name, ft.sub_book)
FROM 
[temp_process_table] temp
LEFT JOIN [final_process_table] ft ON temp.DealId = ft.deal_id
LEFT JOIN #ICE_Trader_Mapping itm ON itm.[ICE_Trader] = temp.Trader
LEFT JOIN ice_security_definition isd ON isd.leg_symbol  = temp.ProductId OR isd.symbol = temp.ProductId
LEFT JOIN #ICE_Product_Template_Mapping icptm ON icptm.ICE_Product = ISNULL(isd.product_name,''Default'')
LEFT JOIN #ICE_Hub_Mapping ihm  ON ihm.ICE_Hub = ISNULL(isd.hub_alias,''Default'')
OUTER APPLY (
SELECT gmv.clm1_value [ICE_Trader], gmv.clm2_value [ICE_Hub], ssbm.book_deal_type_map_id, ssbm.logical_name
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header smh
	ON smh.mapping_table_id = gmv.mapping_table_id
LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = CAST(gmv.clm3_value AS INT)
WHERE smh.mapping_name = ''ICE Book Mapping'' and gmv.clm1_value =itm.[ICE_Trader] AND  gmv.clm2_value = ihm.ICE_Hub

  ) ihm1


UPDATE ft
SET ft.curve_id = ISNULL(ihm.curve_id, ft.curve_id)
FROM 
[temp_process_table] temp  
LEFT JOIN [final_process_table] ft ON temp.DealId = ft.deal_id
LEFT JOIN ice_security_definition isd ON isd.leg_symbol = temp.ProductId OR isd.symbol = temp.ProductId
LEFT JOIN #ICE_Product_Template_Mapping icptm ON icptm.ICE_Product = ISNULL(isd.product_name,''Default'')
OUTER APPLY (
SELECT [ICE_Hub], source_curve_def_id, curve_id
FROM #ICE_Hub_Mapping  WHERE  ICE_Hub = ISNULL(isd.hub_alias,''Default'')
)  ihm

UPDATE ft
SET ft.commodity_id = ISNULL(NULLIF(sc.commodity_id, ''''), ft.commodity_id)
FROM [final_process_table] ft
LEFT JOIN source_price_curve_def spcd ON ft.curve_id = spcd.curve_id
LEFT JOIN source_commodity sc ON sc.source_commodity_id= spcd.commodity_id

UPDATE temp
SET temp.TradeType =NULL
FROM 
[temp_process_table] temp  WHERE temp.TradeType = ''0''


UPDATE ft
SET ft.deal_volume= ISNULL(NULLIF(temp.LegQty, ''''), NULLIF(temp.LastQty, ''''))
, ft.fixed_price =  ISNULL(NULLIF(temp.LegPrice, ''''), NULLIF(temp.LastPrice, ''''))
FROM  [final_process_table] ft 
INNER JOIN  [temp_process_table] temp on ft.deal_id  =  temp.DealId

UPDATE ft SET ft.location_id= NULL
FROM  [final_process_table] ft WHERE ft.location_id = ''Location''

UPDATE ft SET ft.internal_portfolio_id = NULL
FROM  [final_process_table] ft WHERE ft.internal_portfolio_id = ''Physial Energy''

UPDATE ft SET ft.commodity_id = NULL
FROM  [final_process_table] ft WHERE ft.commodity_id = ''Commodity''

UPDATE ft SET ft.udf_value1 = NULL,ft.udf_value3 = NULL, ft.udf_value4 = NULL
FROM  [final_process_table] ft


',
					'UPDATE sdd
SET sdd.location_id = NULL
FROM [temp_process_table] ftp
INNER JOIN source_deal_header sdh
    ON ftp.deal_id = sdh.deal_id
INNER JOIN source_deal_detail sdd
    ON sdd.source_deal_header_id = sdh.source_deal_header_id
',
					'i' ,
					'n' ,
					@admin_user ,
					23502,
					1,
					'4236B5F9_1C09_460E_9E41_738C9C6CCA04'
					 )

				SET @ixp_rules_id_new = SCOPE_IDENTITY()
				EXEC spa_print 	@ixp_rules_id_new

				UPDATE ixp
				SET import_export_id = @ixp_rules_id_new
				FROM ipx_privileges ixp
				WHERE ixp.import_export_id = @old_ixp_rule_id
		END
				
				

		ELSE 
		BEGIN
			SET @ixp_rules_id_new = @old_ixp_rule_id
			EXEC spa_print 	@ixp_rules_id_new
			
			UPDATE
			ixp_rules
			SET ixp_rules_name = 'ICE Deals'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'IF OBJECT_ID(''tempdb..#ICE_Product_Template_Mapping'') IS NOT NULL
DROP TABLE #ICE_Product_Template_Mapping

SELECT gmv.clm1_value [ICE_Product],  sdht.template_id, sdht.template_name, sdt.source_deal_type_id, sdt.deal_type_id, sdv.code [internal_portfolio_id], cg.source_contract_id [contract_id], sdv_b.code [block_define_id]
INTO #ICE_Product_Template_Mapping
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header smh
	ON smh.mapping_table_id = gmv.mapping_table_id
LEFT JOIN source_deal_header_template sdht
	ON sdht.template_id = CAST(gmv.clm2_value AS INT)
LEFT JOIN source_deal_type sdt
	ON sdt.source_deal_type_id = CAST(gmv.clm3_value AS INT)
LEFT JOIN static_data_value sdv
	ON sdv.value_id = CAST(gmv.clm4_value AS INT) and sdv.type_id =39800
LEFT JOIN contract_group cg ON cg.contract_id = CAST(gmv.clm5_value AS INT)
LEFT JOIN static_data_value sdv_b
	ON sdv_b.value_id = CAST(gmv.clm6_value AS INT) and sdv_b.type_id =10018
WHERE smh.mapping_name = ''ICE Product Template Mapping''
IF OBJECT_ID(''tempdb..#ICE_Trader_Mapping'') IS NOT NULL
DROP TABLE #ICE_Trader_Mapping

SELECT gmv.clm1_value [ICE_Trader], st.source_trader_id, st.trader_id
INTO #ICE_Trader_Mapping
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header smh
	ON smh.mapping_table_id = gmv.mapping_table_id
LEFT JOIN source_traders st ON st.source_trader_id = CAST(gmv.clm2_value AS INT)
WHERE smh.mapping_name = ''ICE Trader Mapping''

IF OBJECT_ID(''tempdb..#ICE_Hub_Mapping'') IS NOT NULL
DROP TABLE #ICE_Hub_Mapping

SELECT gmv.clm1_value [ICE_Hub], spcd.source_curve_def_id, spcd.curve_id
INTO #ICE_Hub_Mapping
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header smh
	ON smh.mapping_table_id = gmv.mapping_table_id
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = CAST(gmv.clm2_value AS INT)
WHERE smh.mapping_name = ''ICE Hub Mapping''


UPDATE ft
SET ft.[source_deal_type_id] = ISNULL(iptm.deal_type_id,ft.[source_deal_type_id] )
	, ft.template_id = ISNULL(iptm.template_name, ft.template_id)
	, ft.internal_portfolio_id = ISNULL(iptm.internal_portfolio_id, ft.internal_portfolio_id)
	, ft.contract_id = ISNULL(iptm.contract_id, ft.contract_id)
	, ft.block_define_id = ISNULL(iptm.block_define_id, ft.block_define_id)
FROM [temp_process_table] TEMP
LEFT JOIN [final_process_table] ft ON temp.DealId = ft.deal_id
LEFT JOIN ice_security_definition isd ON isd.leg_symbol = TEMP.ProductId  OR isd.symbol = TEMP.ProductId
OUTER APPLY (
	SELECT ip.[ICE_Product]
		, ip.template_name
		, ip.deal_type_id
		, ip.internal_portfolio_id
		, ip.contract_id
		, ip.block_define_id
	FROM #ICE_Product_Template_Mapping ip
	WHERE ip.ICE_Product = ISNULL(isd.product_name,''Default'')
	) iptm


UPDATE ft
SET ft.counterparty_id = ISNULL(cpty.counterparty_id, ft.counterparty_id)
FROM [temp_process_table] temp
LEFT JOIN [final_process_table] ft ON temp.DealId = ft.deal_id
OUTER APPLY (
	SELECT gmv.clm1_value [ICE_Counterparty]
		, sc.source_counterparty_id
		, sc.counterparty_id
	FROM generic_mapping_values gmv
	INNER JOIN generic_mapping_header smh
		ON smh.mapping_table_id = gmv.mapping_table_id
	LEFT JOIN source_counterparty sc
		ON sc.source_counterparty_id = CAST(gmv.clm2_value AS INT)
	WHERE smh.mapping_name = ''ICE Counterparty Mapping'' AND gmv.clm1_value  = temp.CounterpartyId1
	) cpty

UPDATE ft
SET ft.trader_id = ISNULL(td.trader_id, ft.trader_id)
FROM [temp_process_table] temp
LEFT JOIN [final_process_table] ft ON temp.DealId = ft.deal_id
OUTER APPLY (
	SELECT st.[ICE_Trader]
		, st.source_trader_id
		, st.trader_id
	FROM #ICE_Trader_Mapping st
	WHERE st.[ICE_Trader] = TEMP.Trader
	) td

UPDATE  
 ft
SET ft.sub_book = ISNULL(ihm1.logical_name, ft.sub_book)
FROM 
[temp_process_table] temp
LEFT JOIN [final_process_table] ft ON temp.DealId = ft.deal_id
LEFT JOIN #ICE_Trader_Mapping itm ON itm.[ICE_Trader] = temp.Trader
LEFT JOIN ice_security_definition isd ON isd.leg_symbol  = temp.ProductId OR isd.symbol = temp.ProductId
LEFT JOIN #ICE_Product_Template_Mapping icptm ON icptm.ICE_Product = ISNULL(isd.product_name,''Default'')
LEFT JOIN #ICE_Hub_Mapping ihm  ON ihm.ICE_Hub = ISNULL(isd.hub_alias,''Default'')
OUTER APPLY (
SELECT gmv.clm1_value [ICE_Trader], gmv.clm2_value [ICE_Hub], ssbm.book_deal_type_map_id, ssbm.logical_name
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header smh
	ON smh.mapping_table_id = gmv.mapping_table_id
LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = CAST(gmv.clm3_value AS INT)
WHERE smh.mapping_name = ''ICE Book Mapping'' and gmv.clm1_value =itm.[ICE_Trader] AND  gmv.clm2_value = ihm.ICE_Hub

  ) ihm1


UPDATE ft
SET ft.curve_id = ISNULL(ihm.curve_id, ft.curve_id)
FROM 
[temp_process_table] temp  
LEFT JOIN [final_process_table] ft ON temp.DealId = ft.deal_id
LEFT JOIN ice_security_definition isd ON isd.leg_symbol = temp.ProductId OR isd.symbol = temp.ProductId
LEFT JOIN #ICE_Product_Template_Mapping icptm ON icptm.ICE_Product = ISNULL(isd.product_name,''Default'')
OUTER APPLY (
SELECT [ICE_Hub], source_curve_def_id, curve_id
FROM #ICE_Hub_Mapping  WHERE  ICE_Hub = ISNULL(isd.hub_alias,''Default'')
)  ihm

UPDATE ft
SET ft.commodity_id = ISNULL(NULLIF(sc.commodity_id, ''''), ft.commodity_id)
FROM [final_process_table] ft
LEFT JOIN source_price_curve_def spcd ON ft.curve_id = spcd.curve_id
LEFT JOIN source_commodity sc ON sc.source_commodity_id= spcd.commodity_id

UPDATE temp
SET temp.TradeType =NULL
FROM 
[temp_process_table] temp  WHERE temp.TradeType = ''0''


UPDATE ft
SET ft.deal_volume= ISNULL(NULLIF(temp.LegQty, ''''), NULLIF(temp.LastQty, ''''))
, ft.fixed_price =  ISNULL(NULLIF(temp.LegPrice, ''''), NULLIF(temp.LastPrice, ''''))
FROM  [final_process_table] ft 
INNER JOIN  [temp_process_table] temp on ft.deal_id  =  temp.DealId

UPDATE ft SET ft.location_id= NULL
FROM  [final_process_table] ft WHERE ft.location_id = ''Location''

UPDATE ft SET ft.internal_portfolio_id = NULL
FROM  [final_process_table] ft WHERE ft.internal_portfolio_id = ''Physial Energy''

UPDATE ft SET ft.commodity_id = NULL
FROM  [final_process_table] ft WHERE ft.commodity_id = ''Commodity''

UPDATE ft SET ft.udf_value1 = NULL,ft.udf_value3 = NULL, ft.udf_value4 = NULL
FROM  [final_process_table] ft


'
				, after_insert_trigger = 'UPDATE sdd
SET sdd.location_id = NULL
FROM [temp_process_table] ftp
INNER JOIN source_deal_header sdh
    ON ftp.deal_id = sdh.deal_id
INNER JOIN source_deal_detail sdd
    ON sdd.source_deal_header_id = sdh.source_deal_header_id
'
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23502
				, is_system_import = 'n'
				, is_active = 1
			WHERE ixp_rules_id = @ixp_rules_id_new
				
		END

				
INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)  
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  0,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_source_deal_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password, clr_function_id, ws_function_name, use_sftp)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release_Sep2019\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'd',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   'Sheet1',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   '0',
						   '',
						   'kkhatiwada',
						   0x010000005B159ED0C97F0B3080BE060490F17F62AA8053542DBFFB63CEDAFA4E3AB077690FA9E7D73B292F5A,
						   icf.ixp_clr_functions_id,
						   '', 
						   '0'
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[DealID]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[TransactTime]', ic.ixp_columns_id, 'CONVERT(VARCHAR(10),STUFF(STUFF(d.[TransactTime],7,0,''-''),5,0,''-''))', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Financial''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'physical_financial_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[counterpartyId1]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Deal Type''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_deal_type_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[TradeType]', ic.ixp_columns_id, '''Real''', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_category_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Trader]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trader_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Template''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'template_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[buy_sell_flag]', ic.ixp_columns_id, 'CASE d.[buy_sell_flag] WHEN 1 THEN ''b'' ELSE ''s'' END', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'header_buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Broker]', ic.ixp_columns_id, 'REPLACE(d.[Broker],''-Broker'','''')', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'broker_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Contract''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[TradeType]', ic.ixp_columns_id, '''Deal Volume''', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_desk_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Product Group''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_portfolio_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Commodity''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'commodity_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Block Define''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'block_define_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[DealStatus]', ic.ixp_columns_id, '''New''', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_status' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[DealStatus]', ic.ixp_columns_id, '''Confirmed''', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'confirm_status_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Sub Book''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sub_book' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[TermStart]', ic.ixp_columns_id, 'STUFF(STUFF(d.[TermStart],7,0,''-''),5,0,''-'')', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_start' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[TermEND]', ic.ixp_columns_id, 'STUFF(STUFF(d.[TermEND],7,0,''-''),5,0,''-'')', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_end' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[LegSide]', ic.ixp_columns_id, '''1''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[TradeType]', ic.ixp_columns_id, '''t''', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_float_leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[buy_sell_flag]', ic.ixp_columns_id, 'CASE d.[buy_sell_flag] WHEN 1 THEN ''b'' ELSE ''s'' END', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Curve]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[LastPrice]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Currency]', ic.ixp_columns_id, '''USD''', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price_currency_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[LastQty]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[TradeType]', ic.ixp_columns_id, '''h''', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume_frequency' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[LegUnitOfMeasure]', ic.ixp_columns_id, '''MW''', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume_uom_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Location''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'location_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[DealID]', ic.ixp_columns_id, '''null''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''null''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''null''', 'Max', 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[TradeType]', ic.ixp_columns_id, '''fixed float''', NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'pricing_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template'

COMMIT 

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
				DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
				DECLARE @msg_severity INT = ERROR_SEVERITY();
				DECLARE @msg_state INT = ERROR_STATE();
					
				RAISERROR(@msg, @msg_severity, @msg_state)
			
				--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
			END