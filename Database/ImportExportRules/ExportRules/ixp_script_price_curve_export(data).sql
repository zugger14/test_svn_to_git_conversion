IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Price Curve Export (Data)') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Price Curve Export (Data)' ,
				'n' ,
				NULL ,
				NULL,
				NULL,
				'e' ,
				'n' ,
				'farrms_admin' ,
				23500)
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
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'source_price_curve_def',
									    335,
									    'PC',
									    NULL

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)


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
								         it.ixp_tables_id, 'source_curve_def_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[source_curve_def_id]', '\\lhotse\users\export\', ',', 'n', 'source_curve_def_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_system_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[source_system_id]', '\\lhotse\users\export\', ',', 'n', 'source_system_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'curve_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[curve_id]', '\\lhotse\users\export\', ',', 'n', 'curve_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'curve_name', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[curve_name]', '\\lhotse\users\export\', ',', 'n', 'curve_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'curve_des', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[curve_des]', '\\lhotse\users\export\', ',', 'n', 'curve_des', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'commodity_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[commodity_id]', '\\lhotse\users\export\', ',', 'n', 'commodity_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'market_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[market_value_id]', '\\lhotse\users\export\', ',', 'n', 'market_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'market_value_desc', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[market_value_desc]', '\\lhotse\users\export\', ',', 'n', 'market_value_desc', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[source_currency_id]', '\\lhotse\users\export\', ',', 'n', 'source_currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_currency_to_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[source_currency_to_id]', '\\lhotse\users\export\', ',', 'n', 'source_currency_to_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_curve_type_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[source_curve_type_value_id]', '\\lhotse\users\export\', ',', 'n', 'source_curve_type_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'uom_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[uom_id]', '\\lhotse\users\export\', ',', 'n', 'uom_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'proxy_source_curve_def_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[proxy_source_curve_def_id]', '\\lhotse\users\export\', ',', 'n', 'proxy_source_curve_def_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[formula_id]', '\\lhotse\users\export\', ',', 'n', 'formula_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'obligation', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[obligation]', '\\lhotse\users\export\', ',', 'n', 'obligation', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'sort_order', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[sort_order]', '\\lhotse\users\export\', ',', 'n', 'sort_order', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fv_level', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[fv_level]', '\\lhotse\users\export\', ',', 'n', 'fv_level', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'create_user', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[create_user]', '\\lhotse\users\export\', ',', 'n', 'create_user', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'create_ts', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[create_ts]', '\\lhotse\users\export\', ',', 'n', 'create_ts', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'update_user', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[update_user]', '\\lhotse\users\export\', ',', 'n', 'update_user', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'update_ts', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[update_ts]', '\\lhotse\users\export\', ',', 'n', 'update_ts', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Granularity', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[Granularity]', '\\lhotse\users\export\', ',', 'n', 'Granularity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'exp_calendar_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[exp_calendar_id]', '\\lhotse\users\export\', ',', 'n', 'exp_calendar_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'risk_bucket_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[risk_bucket_id]', '\\lhotse\users\export\', ',', 'n', 'risk_bucket_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'reference_curve_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[reference_curve_id]', '\\lhotse\users\export\', ',', 'n', 'reference_curve_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'monthly_index', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[monthly_index]', '\\lhotse\users\export\', ',', 'n', 'monthly_index', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'program_scope_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[program_scope_value_id]', '\\lhotse\users\export\', ',', 'n', 'program_scope_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'curve_definition', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[curve_definition]', '\\lhotse\users\export\', ',', 'n', 'curve_definition', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'block_type', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[block_type]', '\\lhotse\users\export\', ',', 'n', 'block_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'block_define_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[block_define_id]', '\\lhotse\users\export\', ',', 'n', 'block_define_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'index_group', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[index_group]', '\\lhotse\users\export\', ',', 'n', 'index_group', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'display_uom_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[display_uom_id]', '\\lhotse\users\export\', ',', 'n', 'display_uom_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'proxy_curve_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[proxy_curve_id]', '\\lhotse\users\export\', ',', 'n', 'proxy_curve_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'hourly_volume_allocation', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[hourly_volume_allocation]', '\\lhotse\users\export\', ',', 'n', 'hourly_volume_allocation', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_curve_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[settlement_curve_id]', '\\lhotse\users\export\', ',', 'n', 'settlement_curve_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'time_zone', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[time_zone]', '\\lhotse\users\export\', ',', 'n', 'time_zone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'udf_block_group_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[udf_block_group_id]', '\\lhotse\users\export\', ',', 'n', 'udf_block_group_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_active', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[is_active]', '\\lhotse\users\export\', ',', 'n', 'is_active', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'ratio_option', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[ratio_option]', '\\lhotse\users\export\', ',', 'n', 'ratio_option', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'curve_tou', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[curve_tou]', '\\lhotse\users\export\', ',', 'n', 'curve_tou', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'proxy_curve_id3', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[proxy_curve_id3]', '\\lhotse\users\export\', ',', 'n', 'proxy_curve_id3', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'asofdate_current_month', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[asofdate_current_month]', '\\lhotse\users\export\', ',', 'n', 'asofdate_current_month', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'monte_carlo_model_parameter_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[monte_carlo_model_parameter_id]', '\\lhotse\users\export\', ',', 'n', 'monte_carlo_model_parameter_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PC.[contract_id]', '\\lhotse\users\export\', ',', 'n', 'contract_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END