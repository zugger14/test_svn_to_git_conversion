BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '5DFC1F5C_FD0B_4621_9249_8D743C051E90'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Nomination'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Nomination' ,
					'N' ,
					NULL ,
					'UPDATE a 
SET a.physical_financial_flag = sdht.physical_financial_flag
, a.trader_id = st.trader_id
, a.header_buy_sell_flag = sdht.header_buy_sell_flag 
, a.leg = sddt.leg
, a.fixed_float_leg = sddt.fixed_float_leg
, a.buy_sell_flag = sddt.buy_sell_flag
, a.curve_id = spcd.curve_name
, a.deal_volume_uom_id = su.uom_id
, a.physical_financial_flag_detail = sddt.physical_financial_flag
, a.position_uom = so_uo.uom_id
, a.deal_volume_frequency = sddt.deal_volume_frequency
, a.settlement_uom = sett_uom.uom_id
, a.fixed_cost_currency_id = sc.currency_id 
, a.fixed_price_currency_id = sc_price.currency_id 
, a.contract_id = ISNULL(a.contract_id, cg.contract_name)
FROM [temp_process_table] stg1
INNER JOIN [final_process_table] a ON a.ixp_source_unique_id = stg1.ixp_source_unique_id
INNER JOIN source_deal_header_template sdht ON sdht.template_name = a.template_id
INNER JOIN source_deal_detail_template sddt ON sddt.template_id = sdht.template_id
LEFT JOIN storage_asset sa ON sa.asset_name = stg1.[storage asset]
LEFT JOIN general_assest_info_virtual_storage gav ON gav.storage_asset_id = sa.storage_asset_id
LEFT JOIN source_traders st ON st.source_trader_id = sdht.trader_id AND st.source_system_id = a.source_system_id
LEFT JOIN source_currency sc ON a.source_system_id = sc.source_system_id AND ISNULL(gav.cost_currency, sddt.[fixed_cost_currency_id]) = sc.source_currency_id
LEFT JOIN source_currency sc_price ON a.source_system_id = sc_price.source_system_id AND ISNULL(gav.cost_currency, sddt.fixed_price_currency_id) = sc_price.source_currency_id
LEFT JOIN source_minor_Location sml ON sml.Location_Name = a.location_id
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sml.term_pricing_index
LEFT JOIN source_uom su ON a.source_system_id = su.source_system_id AND ISNULL(gav.volumn_uom, sddt.deal_volume_uom_id) = su.source_uom_id
LEFT JOIN source_uom so_uo ON so_uo.source_uom_id = ISNULL(gav.volumn_uom, sddt.position_uom)
LEFT JOIN source_uom sett_uom ON sett_uom.source_uom_id = ISNULL(gav.volumn_uom, sddt.settlement_uom)
LEFT JOIN contract_group cg ON cg.contract_id = gav.agreement',
					'
						',
					'i' ,
					'y' ,
					@admin_user ,
					23502,
					1,
					'5DFC1F5C_FD0B_4621_9249_8D743C051E90'
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
			SET ixp_rules_name = 'Nomination'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'UPDATE a 
SET a.physical_financial_flag = sdht.physical_financial_flag
, a.trader_id = st.trader_id
, a.header_buy_sell_flag = sdht.header_buy_sell_flag 
, a.leg = sddt.leg
, a.fixed_float_leg = sddt.fixed_float_leg
, a.buy_sell_flag = sddt.buy_sell_flag
, a.curve_id = spcd.curve_name
, a.deal_volume_uom_id = su.uom_id
, a.physical_financial_flag_detail = sddt.physical_financial_flag
, a.position_uom = so_uo.uom_id
, a.deal_volume_frequency = sddt.deal_volume_frequency
, a.settlement_uom = sett_uom.uom_id
, a.fixed_cost_currency_id = sc.currency_id 
, a.fixed_price_currency_id = sc_price.currency_id 
, a.contract_id = ISNULL(a.contract_id, cg.contract_name)
FROM [temp_process_table] stg1
INNER JOIN [final_process_table] a ON a.ixp_source_unique_id = stg1.ixp_source_unique_id
INNER JOIN source_deal_header_template sdht ON sdht.template_name = a.template_id
INNER JOIN source_deal_detail_template sddt ON sddt.template_id = sdht.template_id
LEFT JOIN storage_asset sa ON sa.asset_name = stg1.[storage asset]
LEFT JOIN general_assest_info_virtual_storage gav ON gav.storage_asset_id = sa.storage_asset_id
LEFT JOIN source_traders st ON st.source_trader_id = sdht.trader_id AND st.source_system_id = a.source_system_id
LEFT JOIN source_currency sc ON a.source_system_id = sc.source_system_id AND ISNULL(gav.cost_currency, sddt.[fixed_cost_currency_id]) = sc.source_currency_id
LEFT JOIN source_currency sc_price ON a.source_system_id = sc_price.source_system_id AND ISNULL(gav.cost_currency, sddt.fixed_price_currency_id) = sc_price.source_currency_id
LEFT JOIN source_minor_Location sml ON sml.Location_Name = a.location_id
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sml.term_pricing_index
LEFT JOIN source_uom su ON a.source_system_id = su.source_system_id AND ISNULL(gav.volumn_uom, sddt.deal_volume_uom_id) = su.source_uom_id
LEFT JOIN source_uom so_uo ON so_uo.source_uom_id = ISNULL(gav.volumn_uom, sddt.position_uom)
LEFT JOIN source_uom sett_uom ON sett_uom.source_uom_id = ISNULL(gav.volumn_uom, sddt.settlement_uom)
LEFT JOIN contract_group cg ON cg.contract_id = gav.agreement'
				, after_insert_trigger = '
						'
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23502
				, is_system_import = 'y'
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
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'di',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   'nomination newwer',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   '0',
						   '',
						   '',
						   0x01000000C690B14F417FA067C10AAAFCCDFC4FCD0F88914008A9BB59,
						   icf.ixp_clr_functions_id,
						   '', 
						   '0'
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[start date]', ic.ixp_columns_id, 'DATEADD(day, -1, di.[start date])', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''New''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_status' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Deal Volume''', 'Min', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_desk_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''Real''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_category_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[end date]', ic.ixp_columns_id, 'DATEADD(day, -1, di.[end date])', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_end' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[deal id]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[contract]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[template]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'template_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[start date]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_start' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[sub book]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sub_book' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[end date]', ic.ixp_columns_id, 'DATEADD(day, -1, di.[end date])', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'entire_term_end' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[end date]', ic.ixp_columns_id, 'DATEADD(day, -1, di.[end date])', NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_expiration_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[sub book]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_system_book_id1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[start date]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'entire_term_start' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[location]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'location_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[start time]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Start Time' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Start Time'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'di.[end time]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'End Time' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'End Time'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
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
		