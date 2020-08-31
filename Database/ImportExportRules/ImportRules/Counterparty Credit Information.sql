BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '317FEB49_0FB3_4653_B689_779F0CEFE180'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Counterparty Credit Information'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Counterparty Credit Information' ,
					'N' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23505,
					1,
					'317FEB49_0FB3_4653_B689_779F0CEFE180'
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
			SET ixp_rules_name = 'Counterparty Credit Information'
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
									WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password, clr_function_id, ws_function_name)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release\temp_Note\Counterparty Credit Information.xlsx',
						   NULL,
						   ',',
						   2,
						   'cptycrinfo',
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
						   'Credit Value Adjustment Report',
						   0x010000007CEDB60C3A5673E3849FFD4D9118F9C8EDC6948947F33AC345D1C23742370EE1D311CAF29E67E432,
						   icf.ixp_clr_functions_id,
						   'CounterpartyCreditInformation'
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Counterparty ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Account Status]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'account_status' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'curreny_code' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Industry Type 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Industry_type1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Industry Type 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Industry_type2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[SIC Code]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'SIC_Code' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Duns Number]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Duns_No' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Risk Rating]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Risk_rating' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[SNP]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Debt_rating' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Ticker Symbol]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Ticker_symbol' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Date Established]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Date_established' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[New Review Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Next_review_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Last Review Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Last_review_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Customer Since]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Customer_since' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Approved By]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Approved_by' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Watch List]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Watch_list' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Moodys]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Debt_Rating2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Fitch]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Debt_Rating3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[DnB]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Debt_Rating4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Debt Rating 5]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Debt_Rating5' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Do Not Calculate Credit Exposure]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'check_apply' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Exclude Expsoure After Months]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'exclude_exposure_after' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Analyst]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'analyst' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Rating Outlook]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'rating_outlook' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Qualitative Rating]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'qualitative_rating' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Buy Notional Month]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'buy_notional_month' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'cptycrinfo.[Sell Notional Month]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_counterparty_credit_info_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sell_notional_month' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'

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