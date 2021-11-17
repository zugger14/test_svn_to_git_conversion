BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = 'DB2978E5_AA60_45B0_B7E4_64051DF5B4D3'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'ice_deal_price'
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
					'ice_deal_price' ,
					'n' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23504,
					1,
					'DB2978E5_AA60_45B0_B7E4_64051DF5B4D3'
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
			SET ixp_rules_name = 'ice_deal_price'
				, individuals_script_per_ojbect = 'n'
				, limit_rows_to = NULL
				, before_insert_trigger = NULL
				, after_insert_trigger = NULL
				, import_export_flag = 'i'
				, ixp_owner = @admin_user
				, ixp_category = 23504
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
									WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   21400,
						   '',
						   '\\PSSJCDEV01\shared_docs_TRMTracker_Trunk\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'udt',
						   '0',
						   NULL,
						   'n',
						   0,
						   '',
						   '0',
						   'n',
						   '',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   icf.ixp_clr_functions_id,
						   NULL, 
						   NULL,
						   NULL,
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
					

INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id)   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'TradeId1', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'TradeId1' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegCFICode', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegCFICode' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegContractMultiplier', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegContractMultiplier' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegCurrency', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegCurrency' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegEndDate', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegEndDate' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegExDestination', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegExDestination' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegLastPx', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegLastPx' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegMaturityDate', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegMaturityDate' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegMaturityMonthYear', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegMaturityMonthYear' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegMemoField', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegMemoField' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegNumOfCycles', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegNumOfCycles' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegNumOfLots', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegNumOfLots' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegPrice', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegPrice' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegQty', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegQty' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegRefID', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegRefID' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegSecurityAltID', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegSecurityAltID' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegSecurityAltIDSource', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegSecurityAltIDSource' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegSecurityExchange', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegSecurityExchange' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegSecurityID', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegSecurityID' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegSecuritySubType', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegSecuritySubType' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegSecurityType', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegSecurityType' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegSecurityIDSource', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegSecurityIDSource' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegSide', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegSide' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegStartDate', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegStartDate' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegStrikePrice', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegStrikePrice' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegSymbol', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegSymbol' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'LegUnitOfMeasure', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'LegUnitOfMeasure' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'TradeDate', ic.ixp_columns_id, NULL, NULL, 0, NULL, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_udt_ice_deal_price'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'TradeDate' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_udt_ice_deal_price'

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