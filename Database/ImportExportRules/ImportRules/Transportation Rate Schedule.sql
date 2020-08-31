BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '6E8536E5_DC87_4D86_930D_CE6055BB6F62'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Transportation Rate Schedule'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Transportation Rate Schedule' ,
					'n' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23501,
					1,
					'6E8536E5_DC87_4D86_930D_CE6055BB6F62'
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
			SET ixp_rules_name = 'Transportation Rate Schedule'
				, individuals_script_per_ojbect = 'n'
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
									WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password)
					SELECT @ixp_rules_id_new,
						   21405,
						   '',
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release_Oct2018\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'trs',
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
						   0x01000000C2461005091602F45CAFBCFEE814CB61513DE0F2CD5B486D
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 


INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Transportation Rate Schedule Name]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'transportation_rate_schedule_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Description]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'description' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Rate Category]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'rate_category' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Provider]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'provider' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Charge Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'charge_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Begin Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'begin_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[End Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'end_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Rate]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'rate' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Rate Granularity]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'rate_granularity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Formula]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'formula' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'currency' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[UOM]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'uom' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Billing Frequency]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'billing_frequency' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Payment Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'payment_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Payment Calendar]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'payment_calendar' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Settlement Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'settlement_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'f.[Settlement Calendar]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'transportation_rate_schedule_rate_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'settlement_calendar' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'transportation_rate_schedule_rate_import'

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