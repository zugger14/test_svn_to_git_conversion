BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'E7E770A4_F8BB_415A_BD7E_5A16C761CD3A'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Hedging Relationship Type Detail'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Hedging Relationship Type Detail' ,
					'N' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23507,
					1,
					'E7E770A4_F8BB_415A_BD7E_5A16C761CD3A'
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
			SET ixp_rules_name = 'Hedging Relationship Type Detail'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = NULL
				, after_insert_trigger = NULL
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23507
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
									WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password)
					SELECT @ixp_rules_id_new,
						   21405,
						   '',
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'HRTD',
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
						   0x0100000089FA8FC32E581BDDF78894DBF8B4099D25E3576786F58A8E
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 


INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Subsidiary]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'sub_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[SBM]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book_deal_type_map_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Tag 1]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_system_book_id1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Tag 2]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_system_book_id2' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Tag 3]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_system_book_id3' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Tag 4]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_system_book_id4' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Inter Book Transfer]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_xfer_source_book_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Hedge/Item]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_or_item' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Buy/Sell]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'buy_sell_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Fixed/Float]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'fixed_float_flag' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Index]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_curve_def_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Leg]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'leg' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Deal Sequence]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_sequence_number' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Month From]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strip_month_from' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Month To]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strip_month_to' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Deal Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'source_deal_type_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Deal Sub Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'deal_sub_type_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Volume Mix Percentage]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'volume_mix_percentage' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[UOM Conversion Factor]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'uom_conversion_factor' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Price Adder]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'price_adder' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Price Multiplier]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'price_multiplier' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Hedge Strip Months]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strip_months' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Lag Months]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strip_year_overlap' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Item Strip Months]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'roll_forward_year' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Volume Round]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'volume_round' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Price Round]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'price_round' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'HRTD.[Name ]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'eff_test_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
INSERT INTO ixp_import_where_clause(rules_id, table_id, ixp_import_where_clause, repeat_number)  
										SELECT @ixp_rules_id_new,
										it.ixp_tables_id,
										NULL,
										0
										FROM ixp_tables it 
										WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type_detail'
										
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