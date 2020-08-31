DECLARE @admin_user VARCHAR(100) = dbo.FNAAppAdminID(), @old_ixp_rule_id INT

			SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Strategy'

			IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Strategy') BEGIN 
			EXEC spa_ixp_rules @flag = 'f', @ixp_rules_name = 'Strategy', @show_delete_msg = 'n' END
			IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Strategy') BEGIN BEGIN TRY BEGIN TRAN 
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active)
				VALUES( 
					'Strategy' ,
					'n' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23501,
					1)
DECLARE @ixp_rules_id_new INT
				SET @ixp_rules_id_new = SCOPE_IDENTITY()
				EXEC spa_print 	@ixp_rules_id_new

				UPDATE ixp
				SET import_export_id = @ixp_rules_id_new
				FROM ipx_privileges ixp
				WHERE ixp.import_export_id = @old_ixp_rule_id
				
INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)  
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  0,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_strategy_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password)
					SELECT @ixp_rules_id_new,
						   21405,
						   '',
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release_Oct2018\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   's',
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
						   '',
						   0x01000000E12CA9D29AD15B79D57C3A8C1FDDCC747669BE2F8FAED750
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 


INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Strategy]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fas_strategy_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Subsidiary]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'parent_entity_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Accounting Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_type_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[FX Hedges for Net Investment in Foreign Operations]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fx_hedge_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Measurement Granularity]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'mes_gran_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[GL Entry Grouping]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'gl_grouping_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Only Short Term]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'no_links' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[No Link Relationship Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'no_links_fas_eff_test_profile_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Measurement Values]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'mes_cfv_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Exclude Values]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'mes_cfv_values_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Rolling Hedge Forward]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'mismatch_tenor_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Strip Transactions]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strip_trans_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Test Range From 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'test_range_from' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Test Range To 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'test_range_to' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Test Range From 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'additional_test_range_from' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Test Range To 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'additional_test_range_to' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Include Unlink Hedges]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'include_unlinked_hedges' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Include Unlink Items]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'include_unlinked_items' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[OCI Rollout]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'oci_rollout_approach_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Test Range From 3]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'additional_test_range_from2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Test Range To 3]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'additional_test_range_to2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Rollout Per Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'rollout_per_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[First Day PNL Threshold]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'first_day_pnl_threshold' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Tenor Option]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'gl_tenor_option' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Functional Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fun_cur_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 's.[Primary Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'primary_counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template'

COMMIT 

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
					
				--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
			END
		