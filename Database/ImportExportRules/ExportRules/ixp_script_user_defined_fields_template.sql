IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'UserDefinedFieldsTemplate') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'UserDefinedFieldsTemplate' ,
				'n' ,
				NULL ,
				NULL,
				NULL,
				'e' ,
				'n' ,
				'farrms_admin' ,
				NULL)
DECLARE @ixp_rules_id_new INT
			SET @ixp_rules_id_new = SCOPE_IDENTITY()
INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number)  
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  NULL,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'user_defined_fields_template',
									    1534,
									    'udft',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1535,
									    'sdv_field_name',
									    1534 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1536,
									    'sdv_field_id',
									    1534 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1537,
									    'sdv_currency_field',
									    1534 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1538,
									    'sdv_internal_field_type',
									    1534 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'formula_editor',
									    1539,
									    'fe',
									    1534

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          1266,         @ixp_rules_id_new,         1535,         1534,         'value_id',         'field_name',         1535 UNION ALL          SELECT          1267,         @ixp_rules_id_new,         1536,         1534,         'value_id',         'field_id',         1536 UNION ALL          SELECT          1268,         @ixp_rules_id_new,         1537,         1534,         'value_id',         'currency_field_id',         1537 UNION ALL          SELECT          1269,         @ixp_rules_id_new,         1538,         1534,         'value_id',         'internal_field_type',         1538 UNION ALL          SELECT          1270,         @ixp_rules_id_new,         1539,         1534,         'formula_id',         'formula_id',         1539

		INSERT INTO ixp_export_relation (from_data_source, to_data_source, from_column, to_column, ixp_rules_id, data_source)
    	SELECT new_from.ixp_export_data_source_id,
				new_to.ixp_export_data_source_id,
				a.from_column,
				a.to_column,
				@ixp_rules_id_new,
				new_from.ixp_export_data_source_id
    	FROM #old_relation a 
    	INNER JOIN #old_ixp_export_data_source b_from ON b_from.ixp_export_data_source_id = a.from_data_source
    	INNER JOIN #old_ixp_export_data_source b_to ON b_to.ixp_export_data_source_id = a.to_data_source
    	LEFT JOIN ixp_exportable_table iet_from ON b_from.export_table_name = iet_from.ixp_exportable_table_name
    	LEFT JOIN ixp_exportable_table iet_to ON b_to.export_table_name = iet_to.ixp_exportable_table_name
    	LEFT JOIN ixp_export_data_source new_from ON new_from.export_table = iet_from.ixp_exportable_table_id AND new_from.export_table_alias = b_from.export_table_alias 
    	LEFT JOIN ixp_export_data_source new_to ON new_to.export_table = iet_to.ixp_exportable_table_id AND new_to.export_table_alias = b_to.export_table_alias
    	WHERE new_from.ixp_rules_id = @ixp_rules_id_new AND new_to.ixp_rules_id = @ixp_rules_id_new
		
 INSERT INTO ixp_data_mapping (ixp_rules_id, table_id, column_name, column_function, column_aggregation, column_filter, insert_type, enable_identity_insert, create_destination_table, source_column, export_folder, export_delim, generate_script, column_alias, main_table )  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'field_name', NULL, NULL, NULL, NULL, NULL, NULL, 'sdv_field_name.[value_id]', 'D:\', NULL, 'y', 'field_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Field_label', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[Field_label]', 'D:\', NULL, 'y', 'Field_label', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Field_type', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[Field_type]', 'D:\', NULL, 'y', 'Field_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'data_type', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[data_type]', 'D:\', NULL, 'y', 'data_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_required', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[is_required]', 'D:\', NULL, 'y', 'is_required', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'sql_string', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[sql_string]', 'D:\', NULL, 'y', 'sql_string', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'udf_type', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[udf_type]', 'D:\', NULL, 'y', 'udf_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'sequence', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[sequence]', 'D:\', NULL, 'y', 'sequence', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'field_size', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[field_size]', 'D:\', NULL, 'y', 'field_size', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'field_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdv_field_id.[value_id]', 'D:\', NULL, 'y', 'field_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'default_value', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[default_value]', 'D:\', NULL, 'y', 'default_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'book_id', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[book_id]', 'D:\', NULL, 'y', 'book_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'udf_group', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[udf_group]', 'D:\', NULL, 'y', 'udf_group', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'udf_tabgroup', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[udf_tabgroup]', 'D:\', NULL, 'y', 'udf_tabgroup', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula_id', NULL, NULL, NULL, NULL, NULL, NULL, 'fe.[formula_id]', 'D:\', NULL, 'y', 'formula_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_field_type', NULL, NULL, NULL, NULL, NULL, NULL, 'sdv_internal_field_type.[value_id]', 'D:\', NULL, 'y', 'internal_field_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'currency_field_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdv_currency_field.[value_id]', 'D:\', NULL, 'y', 'currency_field_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'window_id', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[window_id]', 'D:\', NULL, 'y', 'window_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'leg', NULL, NULL, NULL, NULL, NULL, NULL, 'udft.[leg]', 'D:\', NULL, 'y', 'leg', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'user_defined_fields_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'udft'
								WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END