IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Location (Data)') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Location (Data)' ,
				'n' ,
				NULL ,
				NULL,
				NULL,
				'e' ,
				'y' ,
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
								WHERE it.ixp_tables_name = 'ixp_location_template'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'source_minor_location',
									    165,
									    'Location',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    166,
									    'type',
									    402 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    167,
									    'region',
									    402 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    168,
									    'bid',
									    402 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    169,
									    'profile',
									    402 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    170,
									    'country',
									    402 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    171,
									    'grid',
									    402

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          111,         @ixp_rules_id_new,         166,         165,         'value_id',         'location_type',         166 UNION ALL          SELECT          112,         @ixp_rules_id_new,         167,         165,         'value_id',         'region',         167 UNION ALL          SELECT          113,         @ixp_rules_id_new,         168,         165,         'value_id',         'bid_offer_formulator_id',         168 UNION ALL          SELECT          114,         @ixp_rules_id_new,         169,         165,         'value_id',         'profile_id',         169 UNION ALL          SELECT          115,         @ixp_rules_id_new,         170,         165,         'value_id',         'country',         170 UNION ALL          SELECT          116,         @ixp_rules_id_new,         171,         165,         'value_id',         'grid_value_id',         171

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
								         it.ixp_tables_id, 'source_minor_location_id', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[source_minor_location_id]', '\\lhotse\users\export\', ';', 'n', 'source_minor_location_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_system_id', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[source_system_id]', '\\lhotse\users\export\', ';', 'n', 'source_system_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_major_location_ID', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[source_major_location_ID]', '\\lhotse\users\export\', ';', 'n', 'source_major_location_ID', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Location_Name', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[Location_Name]', '\\lhotse\users\export\', ';', 'n', 'Location_Name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Location_Description', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[Location_Description]', '\\lhotse\users\export\', ';', 'n', 'Location_Description', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Meter_ID', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[Meter_ID]', '\\lhotse\users\export\', ';', 'n', 'Meter_ID', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Pricing_Index', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[Pricing_Index]', '\\lhotse\users\export\', ';', 'n', 'Pricing_Index', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Commodity_id', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[Commodity_id]', '\\lhotse\users\export\', ';', 'n', 'Commodity_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'create_user', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[create_user]', '\\lhotse\users\export\', ';', 'n', 'create_user', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'create_ts', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[create_ts]', '\\lhotse\users\export\', ';', 'n', 'create_ts', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'update_user', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[update_user]', '\\lhotse\users\export\', ';', 'n', 'update_user', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'update_ts', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[update_ts]', '\\lhotse\users\export\', ';', 'n', 'update_ts', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'location_type', NULL, NULL, NULL, NULL, NULL, NULL, 'type.[code]', '\\lhotse\users\export\', ';', 'n', 'location_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'time_zone', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[time_zone]', '\\lhotse\users\export\', ';', 'n', 'time_zone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'x_position', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[x_position]', '\\lhotse\users\export\', ';', 'n', 'x_position', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'y_position', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[y_position]', '\\lhotse\users\export\', ';', 'n', 'y_position', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'region', NULL, NULL, NULL, NULL, NULL, NULL, 'region.[code]', '\\lhotse\users\export\', ';', 'n', 'region', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_pool', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[is_pool]', '\\lhotse\users\export\', ';', 'n', 'is_pool', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_pricing_index', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[term_pricing_index]', '\\lhotse\users\export\', ';', 'n', 'term_pricing_index', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'owner', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[owner]', '\\lhotse\users\export\', ';', 'n', 'owner', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'operator', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[operator]', '\\lhotse\users\export\', ';', 'n', 'operator', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[contract]', '\\lhotse\users\export\', ';', 'n', 'contract', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[volume]', '\\lhotse\users\export\', ';', 'n', 'volume', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'uom', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[uom]', '\\lhotse\users\export\', ';', 'n', 'uom', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bid_offer_formulator_id', NULL, NULL, NULL, NULL, NULL, NULL, 'bid.[code]', '\\lhotse\users\export\', ';', 'n', 'bid_offer_formulator_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'proxy_location_id', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[proxy_location_id]', '\\lhotse\users\export\', ';', 'n', 'proxy_location_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'external_identification_number', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[external_identification_number]', '\\lhotse\users\export\', ';', 'n', 'external_identification_number', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'profile_id', NULL, NULL, NULL, NULL, NULL, NULL, 'profile.[code]', '\\lhotse\users\export\', ';', 'n', 'profile_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'proxy_profile_id', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[proxy_profile_id]', '\\lhotse\users\export\', ';', 'n', 'proxy_profile_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'grid_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'grid.[code]', '\\lhotse\users\export\', ';', 'n', 'grid_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'country', NULL, NULL, NULL, NULL, NULL, NULL, 'country.[code]', '\\lhotse\users\export\', ';', 'n', 'country', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_active', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[is_active]', '\\lhotse\users\export\', ';', 'n', 'is_active', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'postal_code', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[postal_code]', '\\lhotse\users\export\', ';', 'n', 'postal_code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'province', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[province]', '\\lhotse\users\export\', ';', 'n', 'province', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'physical_shipper', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[physical_shipper]', '\\lhotse\users\export\', ';', 'n', 'physical_shipper', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'sicc_code', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[sicc_code]', '\\lhotse\users\export\', ';', 'n', 'sicc_code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'profile_code', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[profile_code]', '\\lhotse\users\export\', ';', 'n', 'profile_code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'nominatorsapcode', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[nominatorsapcode]', '\\lhotse\users\export\', ';', 'n', 'nominatorsapcode', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'forecast_needed', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[forecast_needed]', '\\lhotse\users\export\', ';', 'n', 'forecast_needed', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'forecasting_group', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[forecasting_group]', '\\lhotse\users\export\', ';', 'n', 'forecasting_group', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'external_profile', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[external_profile]', '\\lhotse\users\export\', ';', 'n', 'external_profile', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'calculation_method', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[calculation_method]', '\\lhotse\users\export\', ';', 'n', 'calculation_method', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'profile_additional', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[profile_additional]', '\\lhotse\users\export\', ';', 'n', 'profile_additional', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'location_id', NULL, NULL, NULL, NULL, NULL, NULL, 'Location.[location_id]', '\\lhotse\users\export\', ';', 'n', 'location_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_location_template'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END