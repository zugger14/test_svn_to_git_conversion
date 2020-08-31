BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'D9ADF2CD_B175_465D_A03A_B93EB7C85E46'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Price Curve Definition'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				-- Added to preserve rule detail like folder location, File endpoint details.
				IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
					DROP TABLE #pre_ixp_import_data_source

				SELECT rules_id
					, folder_location
					, file_transfer_endpoint_id
					, remote_directory 
				INTO #pre_ixp_import_data_source
				FROM ixp_import_data_source 
				WHERE rules_id = @old_ixp_rule_id

				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Price Curve Definition' ,
					'N' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23501,
					1,
					'D9ADF2CD_B175_465D_A03A_B93EB7C85E46'
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
			SET ixp_rules_name = 'Price Curve Definition'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = NULL
				, after_insert_trigger = NULL
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23501
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
									WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'p',
						   '0',
						   NULL,
						   'n',
						   0,
						   '\\fs01\Import\New Folder',
						   '0',
						   'n',
						   'Sheet1',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   icf.ixp_clr_functions_id,
						   'PriceCurveDefinition', 
						   '0',
						   '0',
						   NULL,
						   NULL
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new
						IF OBJECT_ID('tempdb..#pre_ixp_import_data_source') IS NOT NULL
						BEGIN
							UPDATE iids
							SET folder_location = piids.folder_location
								, file_transfer_endpoint_id = piids.file_transfer_endpoint_id
								, remote_directory = piids.remote_directory
							FROM ixp_import_data_source iids
							INNER JOIN #pre_ixp_import_data_source piids 
							ON iids.rules_id = piids.rules_id
						END
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Curve ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Name]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Description]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_des' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Commodity]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'commodity_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Market Value ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'market_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Market Description]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'market_value_desc' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_currency_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Currency To]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_currency_to_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Curve Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_curve_type_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[UOM]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'uom_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Proxy Curve1]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'proxy_source_curve_def_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Environmental Product]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'obligation' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Granularity]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Granularity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Expiration Calendar]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'exp_calendar_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Proxy Curve2]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'monthly_index' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Long Description]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_definition' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Block Definition]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'block_define_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Index Group]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'index_group' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Reporting UOM]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'display_uom_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Reporting Curve]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'proxy_curve_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Financial Breakdown]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hourly_volume_allocation' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Settlement Curve]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'settlement_curve_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Timezone]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'time_zone' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[TOU Group]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_block_group_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Proxy Curve3]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'proxy_curve_id3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Forward/Settlement]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Forward_Settle' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Holiday Calendar]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'holiday_calendar_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Multiplier]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'liquidation_multiplier' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Effective Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'effective_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[RTC Curve 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'rtc_curve_1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[RTC Curve 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'rtc_curve_2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[RTC Curve 3]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'rtc_curve_3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[RTC Curve 4]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'rtc_curve_4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Time of Use]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_tou' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'p.[Location]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_price_curve_def_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'location_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'

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
