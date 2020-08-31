BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '9AFB3004_79F1_4BD2_8ACD_1A1583DF007E'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Update Monthly Volumes'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Update Monthly Volumes' ,
					'N' ,
					NULL ,
					'IF OBJECT_ID(''tempdb..#temp_data'') IS NOT NULL
	DROP TABLE #temp_data

SELECT SUM(pt.volume) vol, sdd.source_deal_detail_id
INTO #temp_data
FROM source_deal_header sdh
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
INNER JOIN [temp_process_table] pt ON CAST(pt.startTime AS DATE) = sdd.term_start 
	AND CAST(pt.endTime AS DATE) = sdd.term_end AND rg.id2 = pt.id
GROUP BY pt.id,sdd.source_deal_detail_id

UPDATE sdd
SET actual_volume = td.vol
FROM source_deal_detail sdd 
INNER JOIN #temp_data td ON td.source_deal_detail_id = sdd.source_deal_detail_id',
					NULL,
					'i' ,
					'n' ,
					@admin_user ,
					23502,
					1,
					'9AFB3004_79F1_4BD2_8ACD_1A1583DF007E'
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
			SET ixp_rules_name = 'Update Monthly Volumes'
				, individuals_script_per_ojbect = 'N'
				, limit_rows_to = NULL
				, before_insert_trigger = 'IF OBJECT_ID(''tempdb..#temp_data'') IS NOT NULL
	DROP TABLE #temp_data

SELECT SUM(pt.volume) vol, sdd.source_deal_detail_id
INTO #temp_data
FROM source_deal_header sdh
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
INNER JOIN [temp_process_table] pt ON CAST(pt.startTime AS DATE) = sdd.term_start 
	AND CAST(pt.endTime AS DATE) = sdd.term_end AND rg.id2 = pt.id
GROUP BY pt.id,sdd.source_deal_detail_id

UPDATE sdd
SET actual_volume = td.vol
FROM source_deal_detail sdd 
INNER JOIN #temp_data td ON td.source_deal_detail_id = sdd.source_deal_detail_id'
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
									WHERE it.ixp_tables_name = 'ixp_custom_tables'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password, clr_function_id, ws_function_name, use_sftp)
					SELECT @ixp_rules_id_new,
						   NULL,
						   NULL,
						   '\\APP01\shared_docs_TRMTracker_Trunk\temp_Note\0',
						   NULL,
						   ',',
						   2,
						   'umv',
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
						   '0',
						   '',
						   '',
						   0x0100000017E980B42546889E14F10B7A22675104E727172BD86A289C,
						   icf.ixp_clr_functions_id,
						   '', 
						   '0'
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = 'GetMonthlyVolumes' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 



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
	