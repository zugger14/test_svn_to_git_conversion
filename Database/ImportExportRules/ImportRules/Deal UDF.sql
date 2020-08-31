BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '4A231CBA_01DA_4F1A_9AAB_2677C249D0ED'

			if @old_ixp_rule_id IS NULL
			BEGIN
			SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Deal UDF'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Deal UDF' ,
					'N' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23502,
					1,
					'4A231CBA_01DA_4F1A_9AAB_2677C249D0ED'
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
			SET ixp_rules_name = 'Deal UDF'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = NULL
				, after_insert_trigger = NULL
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
									WHERE it.ixp_tables_name = 'ixp_deal_udf_import'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password, clr_function_id, ws_function_name, use_sftp)
					SELECT @ixp_rules_id_new,
						   21405,
						   NULL,
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Essent\temp_Note\Deal UDF Import.xlsx',
						   NULL,
						   ',',
						   2,
						   'du',
						   '0',
						   NULL,
						   'n',
						   6,
						   '',
						   '0',
						   'n',
						   'Sheet1',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   '0',
						   '',
						   '',
						   0x01000000104522CC1EF4DC4835744E81E864912BD52F294D852C9609,
						   icf.ixp_clr_functions_id,
						   '', 
						   '0'
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'du.[Deal Ref ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_udf_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_ref_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_udf_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'du.[Header Detail]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_udf_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'header_detail' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_udf_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'du.[Term]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_udf_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'term' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_udf_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'du.[Leg]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_udf_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_udf_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'du.[Name]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_udf_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_udf_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'du.[Value]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_deal_udf_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'value' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_deal_udf_import'

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
		