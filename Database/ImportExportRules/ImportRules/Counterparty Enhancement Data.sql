BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'EA989B42_97FE_4AFA_8805_1CA3A0F38F40'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Counterparty Enhancement Data'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Counterparty Enhancement Data' ,
					'N' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23505,
					1,
					'EA989B42_97FE_4AFA_8805_1CA3A0F38F40'
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
			SET ixp_rules_name = 'Counterparty Enhancement Data'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = NULL
				, after_insert_trigger = NULL
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23505
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
									WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password)
					SELECT @ixp_rules_id_new,
						   21405,
						   '',
						   '\\SG-D-WEB01\shared_docs_TRMTracker_DEV\temp_Note\Copy of Counterparty Enhancement Data New.xlsx',
						   NULL,
						   ',',
						   2,
						   'CounterpartyEnhance',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   'Counterparty Ehnancement',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   '0',
						   '',
						   '',
						   0x01000000AE43198F4B62AAEC879B672EADED983206B913C77EECB3B5
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 


INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Approved By]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'approved_by' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Autorenewal]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'auto_renewal' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Blocked]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'blocked' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Collateral Status]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'collateral_status' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Comments]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'comment' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Guarantee Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'guarantee_counterparty' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Primary]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'is_primary' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Transfer]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'transferred' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Counterparty ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'counterparty_credit_info_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Enhancement Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'enhance_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Amount]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'amount' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'currency_code' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Effective Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'eff_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Receive]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'margin' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Expiration Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'expiration_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Do Not Use as Credit Collateral]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'exclude_collateral' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Contract]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'contract_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Internal Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'internal_counterparty' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'CounterpartyEnhance.[Deal ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
INSERT INTO ixp_import_where_clause(rules_id, table_id, ixp_import_where_clause, repeat_number)  
										SELECT @ixp_rules_id_new,
										it.ixp_tables_id,
										NULL,
										0
										FROM ixp_tables it 
										WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
										
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