BEGIN BEGIN TRY 
			 BEGIN TRAN 
			 DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
			 DECLARE @ixp_rules_id_new INT
			 

			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = '39884AE1_F628_4B18_B887_FD3D359CD8E0'

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = 'Hedging Relationship Type Header'
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				EXEC spa_ixp_rules @flag = 'f', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = 'n' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			

				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					'Hedging Relationship Type Header' ,
					'n' ,
					NULL ,
					NULL,
					NULL,
					'i' ,
					'y' ,
					@admin_user ,
					23507,
					1,
					'39884AE1_F628_4B18_B887_FD3D359CD8E0'
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
			SET ixp_rules_name = 'Hedging Relationship Type Header'
				, individuals_script_per_ojbect = 'n'
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
									WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type'
									
INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter, excel_sheet, ssis_package, soap_function_id, is_ftp, ftp_url, ftp_username, ftp_password)
					SELECT @ixp_rules_id_new,
						   21405,
						   '',
						   '\\SG-D-WEB01\shared_docs_TRMTracker_Release\temp_Note\hedge header.xlsx',
						   NULL,
						   ',',
						   2,
						   'HRT',
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
						   0x01000000798AF1AD4EC595312BB34E99F74FD121AF6984EE5495DA83
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = '' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = '' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new 


INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause )   SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Active]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'profile_active' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Approved]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'profile_approved' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Book ]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'book' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Calc at Relationship Level]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'individual_link_calc' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Convert Currency]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'convert_currency_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Convert UOM]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'convert_uom_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Counterparty]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'item_counterparty_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Curve Source]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'gen_curve_source_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Description]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'eff_test_description' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Effective End Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'effective_end_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Effective Start Date]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'effective_start_date' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Exclude Spot Forward Difference]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'ineffectiveness_in_hedge' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Externalization]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'externalization' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Force Intercept to 0]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'force_intercept_zero' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Formal Documentation]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'formal_documentation' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Hedge as Dependent Variable]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'use_hedge_as_depend_var' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Hedge Assessment Pricing Option]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_test_price_option_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Hedge Documentation]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_doc_temp' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Hedge Item Pricing Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'item_pricing_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Hedge To Item Volume Conversion Factor]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_to_item_conv_factor' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Hedge Total Fixed Price Based On]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'hedge_fixed_price_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[IN_Assessment Approach]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'init_eff_test_approach_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[IN_Assessment Curve Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'init_assmt_curve_type_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[IN_Curve Source]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'init_curve_source_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[IN_Number of Price Points]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'init_number_of_curve_points' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Inhert Assessment Value From]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'inherit_assmt_eff_test_profile_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Item Assessment Pricing Option]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'item_test_price_option_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Matching Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'matching_type' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Measurement Eff Test Approach]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'mstm_eff_test_type_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Name]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'eff_test_name' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[ON_Assessment Approach]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'on_eff_test_approach_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[ON_Assessment Curve Type]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'on_assmt_curve_type_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[ON_Curve Source]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'on_curve_source_value_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[ON_Number of Price Points]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'on_number_of_curve_points' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Risk Management Policy]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'risk_mgmt_policy' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Risk Management Strategy]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'risk_mgmt_strategy' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Strategy]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'strategy' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Subsidiary]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'subsidiary' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type' UNION ALL  SELECT @ixp_rules_id_new, it.ixp_tables_id, 'hrt.[Trader]', ic.ixp_columns_id, NULL, NULL, 0, NULL 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = 'ixp_hedge_relationship_type'
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = 'item_trader_id' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = 'NULL' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = 'ixp_hedge_relationship_type'

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