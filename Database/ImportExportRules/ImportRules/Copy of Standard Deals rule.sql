BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '0AFF493D_7F85_432E_88B0_D033DA2D63EE'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Copy of Standard Deals rule'
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
					'Copy of Standard Deals rule' ,
					'N' ,
					NULL ,
					'UPDATE [temp_process_table]
SET [Deal Status] = ''New''	
, [Confirm Status] = ''Confirmed''',
					NULL,
					'i' ,
					'n' ,
					@admin_user ,
					23502,
					1,
					'0AFF493D_7F85_432E_88B0_D033DA2D63EE'
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
			SET ixp_rules_name = 'Copy of Standard Deals rule'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'UPDATE [temp_process_table]
SET [Deal Status] = ''New''	
, [Confirm Status] = ''Confirmed'''
				, after_insert_trigger = NULL
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
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\EU-D-SQL01\shared_docs_TRMTracker_Enercity\temp_Note\0',
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
						   'Deals',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   icf.ixp_clr_functions_id,
						   '', 
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
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Deal ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Deal Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Ext Deal ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'ext_deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Physical Financial]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'physical_financial_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Deal Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_deal_type_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Deal Sub Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_sub_type_type_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Option Flag]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'option_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Option Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'option_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Option Exercise Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'option_excercise_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Description1]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Description2]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Description3]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Category]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_category_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Trader]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trader_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Template]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'template_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Header Buy/Sell]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'header_buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Broker]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'broker_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, '', ic.ixp_columns_id, '''farrms_admin''', 'Max', 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'assigned_by' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Contract]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Profile]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_desk_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Fixation]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'product_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Product Group]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_portfolio_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Commodity]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'commodity_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Reference Deal]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'close_reference_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Block Definition]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'block_define_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Deal Status]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_status' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Confirm Status]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'confirm_status_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Subbook]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sub_book' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Description4]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Term Start]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_start' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Term End]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term_end' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Leg]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Expiration Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_expiration_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Fixed Float]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_float_leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Buy Sell]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Market Index]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curve_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Fixed Price]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_price_currency_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Option Strike Price]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'option_strike_price' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Deal Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Volume Frequency]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume_frequency' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Volume UOM]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_volume_uom_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Formula]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'formula_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Addon]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'price_adder' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Location]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'location_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Meter ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'meter_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Fixed Cost]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_cost' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Volume Multiplier]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'multiplier' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Adder Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'adder_currency_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Fixed Cost Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_cost_currency_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Formula Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'formula_currency_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Volume Multiplier 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'volume_multiplier2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[SYV]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'standard_yearly_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Index On]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'formula_curve_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Detail Physical Financial]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'physical_financial_flag_detail' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Deal Detail Status]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'status' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Timezone]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'timezone_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Counterparty Trader]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_trader' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Internal Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_counterparty' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Counterparty 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_id2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Trader 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'trader_id2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Pricing Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'pricing_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Contractual Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contractual_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Actual Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'actual_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Schedule Volume]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'schedule_volume' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Position UOM]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'position_uom' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Detail Profile]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'profile_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Transaction Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fas_deal_type_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Profile Granularity]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'profile_granularity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Fx Conversion Market]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fx_conversion_market' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Fx Rounding]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fx_rounding' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Fx Option]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fx_option' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Fx Conversion Rate]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fx_conversion_rate' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Upstream Contract]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'upstream_contract' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Upstream Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'upstream_counterparty' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Strike Granularity]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strike_granularity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[No of Strike]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'no_of_strikes' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Payment Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'payment_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Counterparty2 Trader]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty2_trader' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Clearing Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'clearing_counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Shipper Code 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'shipper_code1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Shipper Code 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'shipper_code2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'd' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Reporting Group 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reporting_group1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Reporting Group 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reporting_group2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Reporting Group 3]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reporting_group3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Reporting Group 4]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reporting_group4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Reporting Group 5]', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'reporting_group5' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'h' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Premium Fees]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Premium' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Premium'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Broker Fees]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Broker Fee' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Broker Fee'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Clearing Fees]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Clearing Fees' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Clearing Fees'									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = 'ixp_source_deal_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'd.[Trans Fees]', ic.ixp_columns_id, NULL, NULL, 0, NULL, ISNULL(CAST(sdv.value_id AS VARCHAR(200)),'Missing udf - ''' + 'Trans Fees' + '''')  
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_deal_template'
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'udf_value4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  'Trans Fees'									   
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