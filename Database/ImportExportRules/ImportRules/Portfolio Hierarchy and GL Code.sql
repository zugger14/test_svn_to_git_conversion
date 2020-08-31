BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '57CEA52D_741D_413B_81C5_4B02DC3BA1A1'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Portfolio Hierarchy and GL Code'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Portfolio Hierarchy and GL Code' ,
					'n' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23501,
					1,
					'57CEA52D_741D_413B_81C5_4B02DC3BA1A1'
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
			SET ixp_rules_name = 'Portfolio Hierarchy and GL Code'
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
									WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password)
					SELECT @ixp_rules_id_new,
						   21405,
						   '',
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release_Oct2018\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'sbmgl',
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
						   0x010000006A334600952BF98A1873E37258332D29E0F334ADFA8398D2
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 


INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Source System ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_system_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Subsidiary]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'subsidiary_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Strategy]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strategy_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Book]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Tag 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book_identifier1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Tag 1 ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book_identifier_id1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Tag 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book_identifier2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Tag 2 ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book_identifier_id2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Tag 3]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book_identifier3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Tag 3 ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book_identifier_id3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Tag 4]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book_identifier4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Tag 4 ID]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book_identifier_id4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Transaction Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'accounting_treatment' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Hedge ST Asset]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_st_asset' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Hedge LT Asset]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_lt_asset' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Hedge ST Liab]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_st_liab' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Hedge LT Liab]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_lt_liab' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Item ST Asset]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'item_st_asset' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Item ST Liab]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'item_st_liab' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Item LT Asset]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'item_lt_asset' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Item LT Liab]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'item_lt_liab' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[AOCI/Hedge Reserve]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'AOCI/Hedge_Reserve' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Unrealized Earnings]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'unrealized_earnings' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[earnings]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'earnings' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[cash]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'cash' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[inventory]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'inventory' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[expense]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'expense' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Gross Settlement]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'gross_settlement' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[amortization]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'amortization' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[interest]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'interest' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[First Day PNL]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'first_day_pnl' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[ST Tax Asset]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'st_tax_asset' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[ST Tax Liab]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'st_tax_liab' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[LT Tax Asset]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'lt_tax_asset' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[LT Tax Liab]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'lt_tax_liab' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Tax Reserve]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'tax_reserve' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Unhedged ST Asset]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'unhedged_st_asset' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Unhedged LT Asset]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'unhedged_lt_asset' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Unhedged ST Liab]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'unhedged_st_liab' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Unhedged LT Liab]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'unhedged_lt_liab' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[A/C Description1]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'A/C_Description1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[A/C Description2]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'A/C_Description2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Table Code]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'table_code' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[Logical Name]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'logical_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'sbmgl.[level]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_source_book_gl_codes_import'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'level' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import'

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