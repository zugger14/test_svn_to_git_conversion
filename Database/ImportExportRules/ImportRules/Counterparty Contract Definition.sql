BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'E6587B61_0758_4117_93AD_B431774E1C48'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Counterparty Contract Definition'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Counterparty Contract Definition' ,
					'N' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23501,
					1,
					'E6587B61_0758_4117_93AD_B431774E1C48'
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
			SET ixp_rules_name = 'Counterparty Contract Definition'
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
									WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password)
					SELECT @ixp_rules_id_new,
						   21405,
						   '',
						   '\\SG-D-WEB01\shared_docs_TRMTracker_DEV\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'con',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   'Counterparty Contract Definition',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   '0',
						   '',
						   '',
						   0x0100000018D9F5D8C55140F9E89B917AC8F8B7448AB363FF97FE54D1
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 


INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[contract]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Counterparty ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[contract start date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_start_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[contract end date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_end_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[apply netting]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'apply_netting_rule' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[contract date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[contract status]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_status' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[is active]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_active' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[bill start month]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'billing_start_month' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Internal Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[rounding]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'rounding' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[margin provisions]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'margin_provision' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Timezone]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'time_zone' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[interest rate]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'interest_rate' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[interest method]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'interest_method' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[counterparty trigger]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_trigger' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[company trigger]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'company_trigger' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[payment rule]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'invoice_due_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[payment days]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'payment_days' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[holiday calendar]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'holiday_calendar_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Receivables]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'receivables' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Payables]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'payables' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Confirmations]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'confirmation' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Offset Method]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'offset_method' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Threshold Provided]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'threshold_provided' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Threshold Received]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'threshold_received' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Analyst]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'analyst' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Secondary Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'secondary_counterparty' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[comments]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'comments' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'con.[Minimum Transfer amount]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_contract_address_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'min_transfer_amount' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
INSERT INTO ixp_import_where_clause(rules_id, table_id, ixp_import_where_clause, repeat_number)  
										SELECT @ixp_rules_id_new,
										it.ixp_tables_id,
										NULL,
										0
										FROM ixp_tables it 
										WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
										
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