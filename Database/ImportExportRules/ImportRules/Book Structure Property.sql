BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'AA7F37BB_B32A_46A0_85CF_07DF79E6E612'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Book Structure Property'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Book Structure Property' ,
					'n' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23501,
					1,
					'AA7F37BB_B32A_46A0_85CF_07DF79E6E612'
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
			SET ixp_rules_name = 'Book Structure Property'
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
									WHERE it.ixp_tables_name = 'ixp_subsidiary_template'
									 UNION ALL 
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  1,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_strategy_template'
									 UNION ALL 
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  2,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_book_template'
									 UNION ALL 
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  3,
										  0,
										  0
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
									WHERE it.ixp_tables_name = 'ixp_sub_book_template'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password)
					SELECT @ixp_rules_id_new,
						   21405,
						   '',
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release_Oct2018\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'bs',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   'Subsidiary',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   '0',
						   '',
						   '',
						   0x010000008ABCA7C06F0C6E4809CD8E20580828CB55E9E52ABD3B822B
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 

INSERT INTO ixp_import_relation (ixp_rules_id, ixp_relation_alias, relation_source_type, connection_string, relation_location, join_clause, delimiter,excel_sheet )  
									   SELECT @ixp_rules_id_new,
											  'bs_rs1', 
											  21405,
											  NULL,
											  'Book Structure.xlsx',
											  'bs.[Subsidiary]=bs_rs1.[Subsidiary]',
											  ',',
											  'Strategy' UNION ALL 
									   SELECT @ixp_rules_id_new,
											  'bs_rs2', 
											  21405,
											  NULL,
											  'Book Structure.xlsx',
											  'bs.[Subsidiary]=bs_rs2.[Subsidiary] AND bs_rs1.[Strategy]=bs_rs2.[Strategy]',
											  ',',
											  'Book' UNION ALL 
									   SELECT @ixp_rules_id_new,
											  'bs_rs3', 
											  21405,
											  NULL,
											  'Book Structure.xlsx',
											  'bs.[Subsidiary]=bs_rs3.[Subsidiary] AND bs_rs1.[Strategy]=bs_rs3.[Strategy] AND bs_rs2.[Book]=bs_rs3.[Book]',
											  ',',
											  'Sub Book'
INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Percentage Included]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'percentage_included' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Primary Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'primary_counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Strategy]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Strategy' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Subsidiary]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'Subsidiary' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Tag 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_system_book_id1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Tag 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_system_book_id2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Tag 3]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_system_book_id3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Tag 4]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_system_book_id4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Transaction Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fas_deal_type_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Logical Name]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'logical_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Group 4]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sub_book_group4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Group 3]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sub_book_group3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Group 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sub_book_group2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Group 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sub_book_group1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[End Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'end_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Effective Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'effective_start_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs3.[Book]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_sub_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_sub_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Discount Parameter]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'discount_param' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Source of Discount Values]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_discount_values' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Subsidiary]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Tax Percentage]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'tax_percentage' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Time Zone]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'timezone' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Subsidiary]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'parent_entity_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Strategy]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fas_strategy_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Discount Rate]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'discount_rate' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Discount Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'discount_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Accounting Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_type_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[FX Hedges for Net Investment in Foreign Operations]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fx_hedge_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Entity Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'entity_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Functional Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'functional_currency' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Measurement Granularity]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'mes_gran_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[GL Entry Grouping]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'gl_grouping_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[FX Conversion Market]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fx_conversion_market' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Long Term Months]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'long_term_months' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Only Short Term]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'no_links' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Primary Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'primary_counterparty' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs.[Risk Free Interest Rate Curve]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_subsidiary_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'risk_free_interest_rate_curve' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_subsidiary_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Measurement Values]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'mes_cfv_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Exclude Values]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'mes_cfv_values_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Rolling Hedge Forward]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'mismatch_tenor_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Strip Transactions]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strip_trans_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Test Range From 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'test_range_from' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Test Range To 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'test_range_to' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Test Range From 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'additional_test_range_from' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Test Range To 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'additional_test_range_to' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Include Unlink Hedges]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'include_unlinked_hedges' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Include Unlink Items]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'include_unlinked_items' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[OCI Rollout]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'oci_rollout_approach_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Accounting Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'accounting_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Book]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Cash Approach]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'cost_approach_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Convert UOM]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'convert_uom_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Functional Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fun_cur_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Hedge and Item Same Sign]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_item_same_sign' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Hypothetical]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'no_link' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Legal Entity]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'legal_entity' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[No Link Relationship Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'no_links_fas_eff_test_profile_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Primary Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'primary_counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Strategy]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strategy_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Subsidiary]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'parent_entity_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs2.[Tax Percentage]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_book_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'tax_perc' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_book_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Test Range From 3]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'additional_test_range_from2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Test Range To 3]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'additional_test_range_to2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[No Link Relationship Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'no_links_fas_eff_test_profile_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Rollout Per Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'rollout_per_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[First Day PNL Threshold]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'first_day_pnl_threshold' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Tenor Option]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'gl_tenor_option' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Functional Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fun_cur_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'bs_rs1.[Primary Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_strategy_template'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'primary_counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_strategy_template'

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