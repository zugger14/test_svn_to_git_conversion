IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Implied Volatility Run Param') BEGIN 
			EXEC spa_ixp_rules @flag = 'd', @ixp_rules_name = 'Implied Volatility Run Param', @show_delete_msg = 'n' END
			IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Implied Volatility Run Param') BEGIN BEGIN TRY BEGIN TRAN 
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active, ixp_rule_hash)
				VALUES( 
					'Implied Volatility Run Param' ,
					'n' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'n' ,
					'snakarmi' ,
					23500,
					1,
					'3092CEBA_5F0E_4D30_9093_E9B22BE98BD7')
DECLARE @ixp_rules_id_new INT
				SET @ixp_rules_id_new = SCOPE_IDENTITY()
				EXEC spa_print 	@ixp_rules_id_new 
				
INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)  
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  0,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_implied_volatility_run_param'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password)
					SELECT @ixp_rules_id_new,
						   21400,
						   '',
						   '\\US-D-DEMO01\shared_docs_TRMTracker_Master_Demo4\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'i',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   '',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   '0',
						   '',
						   '',
						   0x01000000E49067E0E449880AB673BD74E82964C1AAC792561D3854F7
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 


INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'i.[options]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_implied_volatility_run_param'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'options' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_implied_volatility_run_param' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'i.[exercise type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_implied_volatility_run_param'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'exercise Type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_implied_volatility_run_param' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'i.[commodity]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_implied_volatility_run_param'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'commodity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_implied_volatility_run_param' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'i.[index]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_implied_volatility_run_param'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'index' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_implied_volatility_run_param' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'i.[term]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_implied_volatility_run_param'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_implied_volatility_run_param' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'i.[expiration]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_implied_volatility_run_param'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'expiration' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_implied_volatility_run_param' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'i.[strike]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_implied_volatility_run_param'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strike' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_implied_volatility_run_param' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'i.[premium]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_implied_volatility_run_param'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'premium' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_implied_volatility_run_param' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'i.[seed]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_implied_volatility_run_param'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'seed' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_implied_volatility_run_param'

COMMIT 

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;

				--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
			END