IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'DEAL_DETAIL_EXPORT') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'DEAL_DETAIL_EXPORT' ,
				'n' ,
				50 ,
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
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'source_counterparty',
									    2376,
									    'broker',
									    2402 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_uom',
									    2377,
									    'volume_uom',
									    2402 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_type',
									    2378,
									    'deal_sub_type',
									    2402 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_system_description',
									    2379,
									    'ssd',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2380,
									    'deal_status',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2381,
									    'confirm_status',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'meter_id',
									    2382,
									    'meter',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_price_curve_def',
									    2383,
									    'formula_curve',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_header_template',
									    2384,
									    'template',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_counterparty',
									    2385,
									    'sc',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_traders',
									    2386,
									    'st',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'contract_group',
									    2387,
									    'cg',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_book',
									    2388,
									    'sb1',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_commodity',
									    2389,
									    'commodity',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_currency',
									    2390,
									    'currency',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_type',
									    2391,
									    'deal_type',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_price_curve_def',
									    2392,
									    'price_curve',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_uom',
									    2393,
									    'uom',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_minor_location',
									    2394,
									    'location',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2395,
									    'source_static_data',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_book',
									    2396,
									    'sb2',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_book',
									    2397,
									    'sb3',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_book',
									    2398,
									    'sb4',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2399,
									    'internal_desk',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2400,
									    'product',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_minor_location',
									    2401,
									    'sl',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_detail',
									    2402,
									    'sdd',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_header',
									    2403,
									    'sdh',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_currency',
									    2404,
									    'broker_currency',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2405,
									    'block_type',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2406,
									    'block_define',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2407,
									    'granualarity',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2408,
									    'pricing',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2409,
									    'deal_category_code',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2410,
									    'deal_cat_value',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_currency',
									    2411,
									    'fixed_currency',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2412,
									    'day_count',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2413,
									    'settlement_uom',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2414,
									    'adder_currency',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2415,
									    'fixed_cost_currency',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2416,
									    'formula_currency',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2417,
									    'adder_currency2',
									    1448 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'formula_editor',
									    2418,
									    'formula',
									    1448

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          2073,         @ixp_rules_id_new,         2376,         2403,         'source_counterparty_id',         'broker_id',         2376 UNION ALL          SELECT          2074,         @ixp_rules_id_new,         2377,         2402,         'source_uom_id',         'deal_volume_uom_id',         2377 UNION ALL          SELECT          2075,         @ixp_rules_id_new,         2378,         2403,         'source_deal_type_id',         'deal_sub_type_type_id',         2378 UNION ALL          SELECT          2076,         @ixp_rules_id_new,         2379,         2403,         'source_system_id',         'source_system_id',         2379 UNION ALL          SELECT          2077,         @ixp_rules_id_new,         2380,         2403,         'value_id',         'deal_status',         2380 UNION ALL          SELECT          2078,         @ixp_rules_id_new,         2381,         2403,         'value_id',         'confirm_status_type',         2381 UNION ALL          SELECT          2079,         @ixp_rules_id_new,         2382,         2402,         'meter_id',         'meter_id',         2382 UNION ALL          SELECT          2080,         @ixp_rules_id_new,         2383,         2402,         'source_curve_def_id',         'formula_curve_id',         2383 UNION ALL          SELECT          2081,         @ixp_rules_id_new,         2384,         2403,         'template_id',         'template_id',         2384 UNION ALL          SELECT          2082,         @ixp_rules_id_new,         2385,         2403,         'source_counterparty_id',         'counterparty_id',         2385 UNION ALL          SELECT          2083,         @ixp_rules_id_new,         2386,         2403,         'source_trader_id',         'trader_id',         2386 UNION ALL          SELECT          2084,         @ixp_rules_id_new,         2387,         2403,         'contract_id',         'contract_id',         2387 UNION ALL          SELECT          2085,         @ixp_rules_id_new,         2388,         2403,         'source_book_id',         'source_system_book_id1',         2388 UNION ALL          SELECT          2086,         @ixp_rules_id_new,         2389,         2403,         'source_commodity_id',         'commodity_id',         2389 UNION ALL          SELECT          2087,         @ixp_rules_id_new,         2391,         2403,         'source_deal_type_id',         'source_deal_type_id',         2391 UNION ALL          SELECT          2088,         @ixp_rules_id_new,         2392,         2402,         'source_curve_def_id',         'curve_id',         2392 UNION ALL          SELECT          2089,         @ixp_rules_id_new,         2393,         2402,         'source_uom_id',         'settlement_uom',         2393 UNION ALL          SELECT          2090,         @ixp_rules_id_new,         2394,         2402,         'source_minor_location_id',         'location_id',         2394 UNION ALL          SELECT          2091,         @ixp_rules_id_new,         2396,         2403,         'source_book_id',         'source_system_book_id2',         2396 UNION ALL          SELECT          2092,         @ixp_rules_id_new,         2397,         2403,         'source_book_id',         'source_system_book_id3',         2397 UNION ALL          SELECT          2093,         @ixp_rules_id_new,         2398,         2403,         'source_book_id',         'source_system_book_id4',         2398 UNION ALL          SELECT          2094,         @ixp_rules_id_new,         2399,         2403,         'value_id',         'internal_desk_id',         2399 UNION ALL          SELECT          2095,         @ixp_rules_id_new,         2400,         2403,         'value_id',         'product_id',         2400 UNION ALL          SELECT          2096,         @ixp_rules_id_new,         2401,         2402,         'source_minor_location_id',         'location_id',         2401 UNION ALL          SELECT          2097,         @ixp_rules_id_new,         2403,         2402,         'source_deal_header_id',         'source_deal_header_id',         2403 UNION ALL          SELECT          2098,         @ixp_rules_id_new,         2404,         2403,         'source_currency_id',         'broker_currency_id',         2404 UNION ALL          SELECT          2099,         @ixp_rules_id_new,         2405,         2403,         'value_id',         'block_type',         2405 UNION ALL          SELECT          2100,         @ixp_rules_id_new,         2406,         2403,         'value_id',         'block_define_id',         2406 UNION ALL          SELECT          2101,         @ixp_rules_id_new,         2407,         2403,         'value_id',         'granularity_id',         2407 UNION ALL          SELECT          2102,         @ixp_rules_id_new,         2408,         2403,         'value_id',         'Pricing',         2408 UNION ALL          SELECT          2103,         @ixp_rules_id_new,         2409,         2403,         'value_id',         'deal_category_value_id',         2409 UNION ALL          SELECT          2104,         @ixp_rules_id_new,         2410,         2403,         'value_id',         'deal_category_value_id',         2410 UNION ALL          SELECT          2105,         @ixp_rules_id_new,         2411,         2402,         'source_currency_id',         'fixed_price_currency_id',         2411 UNION ALL          SELECT          2106,         @ixp_rules_id_new,         2412,         2402,         'value_id',         'day_count_id',         2412 UNION ALL          SELECT          2107,         @ixp_rules_id_new,         2413,         2402,         'value_id',         'settlement_uom',         2413 UNION ALL          SELECT          2108,         @ixp_rules_id_new,         2414,         2402,         'value_id',         'adder_currency_id',         2414 UNION ALL          SELECT          2109,         @ixp_rules_id_new,         2415,         2402,         'value_id',         'fixed_price_currency_id',         2415 UNION ALL          SELECT          2110,         @ixp_rules_id_new,         2416,         2402,         'value_id',         'formula_currency_id',         2416 UNION ALL          SELECT          2111,         @ixp_rules_id_new,         2417,         2402,         'value_id',         'price_adder_currency2',         2417 UNION ALL          SELECT          2112,         @ixp_rules_id_new,         2418,         2402,         'formula_id',         'formula_id',         2418

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
								         it.ixp_tables_id, 'deal_volume_frequency', 'dbo.FNAConvertGranularity(sdd.deal_volume_frequency)', NULL, NULL, NULL, NULL, NULL, 'sdd.[deal_volume_frequency]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_volume_frequency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_volume_uom_id', NULL, NULL, NULL, NULL, NULL, NULL, 'volume_uom.[uom_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_volume_uom_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'block_description', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[block_description]', 'D:\Import_Export\ExportScript\', ';', 'n', 'block_description', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_detail_description', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[deal_detail_description]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_detail_description', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula_id', NULL, NULL, NULL, NULL, NULL, NULL, 'formula.[formula]', 'D:\Import_Export\ExportScript\', ';', 'n', 'formula_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_left', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[volume_left]', 'D:\Import_Export\ExportScript\', ';', 'n', 'volume_left', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_volume', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[settlement_volume]', 'D:\Import_Export\ExportScript\', ';', 'n', 'settlement_volume', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_uom', NULL, NULL, NULL, NULL, NULL, NULL, 'settlement_uom.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'settlement_uom', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'price_adder', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[price_adder]', 'D:\Import_Export\ExportScript\', ';', 'n', 'price_adder', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'price_multiplier', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[price_multiplier]', 'D:\Import_Export\ExportScript\', ';', 'n', 'price_multiplier', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[settlement_date]', 'D:\Import_Export\ExportScript\', ';', 'n', 'settlement_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'day_count_id', NULL, NULL, NULL, NULL, NULL, NULL, 'day_count.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'day_count_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'location_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sl.[location_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'location_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'meter_id', NULL, NULL, NULL, NULL, NULL, NULL, 'meter.[recorderid]', 'D:\Import_Export\ExportScript\', ';', 'n', 'meter_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Booked', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[Booked]', 'D:\Import_Export\ExportScript\', ';', 'n', 'Booked', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'process_deal_status', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[process_deal_status]', 'D:\Import_Export\ExportScript\', ';', 'n', 'process_deal_status', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fixed_cost', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[fixed_cost]', 'D:\Import_Export\ExportScript\', ';', 'n', 'fixed_cost', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'multiplier', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[multiplier]', 'D:\Import_Export\ExportScript\', ';', 'n', 'multiplier', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'adder_currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'adder_currency.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'adder_currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fixed_cost_currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'fixed_cost_currency.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'fixed_cost_currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula_currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'formula_currency.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'formula_currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'price_adder2', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[price_adder2]', 'D:\Import_Export\ExportScript\', ';', 'n', 'price_adder2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_multiplier2', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[volume_multiplier2]', 'D:\Import_Export\ExportScript\', ';', 'n', 'volume_multiplier2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pay_opposite', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[pay_opposite]', 'D:\Import_Export\ExportScript\', ';', 'n', 'pay_opposite', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'capacity', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[capacity]', 'D:\Import_Export\ExportScript\', ';', 'n', 'capacity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'standard_yearly_volume', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[standard_yearly_volume]', 'D:\Import_Export\ExportScript\', ';', 'n', 'standard_yearly_volume', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula_curve_id', NULL, NULL, NULL, NULL, NULL, NULL, 'formula_curve.[curve_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'formula_curve_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'price_uom_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[price_uom_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'price_uom_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'category', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[category]', 'D:\Import_Export\ExportScript\', ';', 'n', 'category', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'profile_code', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[profile_code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'profile_code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pv_party', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[pv_party]', 'D:\Import_Export\ExportScript\', ';', 'n', 'pv_party', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_category_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'deal_cat_value.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_category_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'trader_id', NULL, NULL, NULL, NULL, NULL, NULL, 'st.[trader_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'trader_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_deal_type_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[internal_deal_type_value_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'internal_deal_type_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_deal_subtype_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[internal_deal_subtype_value_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'internal_deal_subtype_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'template_id', NULL, NULL, NULL, NULL, NULL, NULL, 'template.[template_name]', 'D:\Import_Export\ExportScript\', ';', 'n', 'template_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'header_buy_sell_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[header_buy_sell_flag]', 'D:\Import_Export\ExportScript\', ';', 'n', 'header_buy_sell_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'broker_id', NULL, NULL, NULL, NULL, NULL, NULL, 'broker.[counterparty_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'broker_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'generator_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[generator_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'generator_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'status_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[status_value_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'status_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'status_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[status_date]', 'D:\Import_Export\ExportScript\', ';', 'n', 'status_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'assignment_type_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[assignment_type_value_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'assignment_type_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'compliance_year', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[compliance_year]', 'D:\Import_Export\ExportScript\', ';', 'n', 'compliance_year', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'state_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[state_value_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'state_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'assigned_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[assigned_date]', 'D:\Import_Export\ExportScript\', ';', 'n', 'assigned_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'assigned_by', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[assigned_by]', 'D:\Import_Export\ExportScript\', ';', 'n', 'assigned_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'generation_source', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[generation_source]', 'D:\Import_Export\ExportScript\', ';', 'n', 'generation_source', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'aggregate_environment', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[aggregate_environment]', 'D:\Import_Export\ExportScript\', ';', 'n', 'aggregate_environment', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'aggregate_envrionment_comment', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[aggregate_envrionment_comment]', 'D:\Import_Export\ExportScript\', ';', 'n', 'aggregate_envrionment_comment', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'rec_price', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[rec_price]', 'D:\Import_Export\ExportScript\', ';', 'n', 'rec_price', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'rec_formula_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[rec_formula_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'rec_formula_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'rolling_avg', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[rolling_avg]', 'D:\Import_Export\ExportScript\', ';', 'n', 'rolling_avg', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[source_contract_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'contract_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_deal_header_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[source_deal_header_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'source_deal_header_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_system_id', NULL, NULL, NULL, NULL, NULL, NULL, 'ssd.[source_system_name]', 'D:\Import_Export\ExportScript\', ';', 'n', 'source_system_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[deal_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[deal_date]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'ext_deal_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[ext_deal_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'ext_deal_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'structured_deal_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[structured_deal_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'structured_deal_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[counterparty_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'entire_term_start', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[entire_term_start]', 'D:\Import_Export\ExportScript\', ';', 'n', 'entire_term_start', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'entire_term_end', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[entire_term_end]', 'D:\Import_Export\ExportScript\', ';', 'n', 'entire_term_end', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_deal_type_id', NULL, NULL, NULL, NULL, NULL, NULL, 'deal_type.[deal_type_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'source_deal_type_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_sub_type_type_id', NULL, NULL, NULL, NULL, NULL, NULL, 'deal_sub_type.[deal_type_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_sub_type_type_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'option_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[option_flag]', 'D:\Import_Export\ExportScript\', ';', 'n', 'option_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'option_type', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[option_type]', 'D:\Import_Export\ExportScript\', ';', 'n', 'option_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'option_excercise_type', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[option_excercise_type]', 'D:\Import_Export\ExportScript\', ';', 'n', 'option_excercise_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_system_book_id1', NULL, NULL, NULL, NULL, NULL, NULL, 'sb1.[source_system_book_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'source_system_book_id1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_system_book_id2', NULL, NULL, NULL, NULL, NULL, NULL, 'sb2.[source_system_book_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'source_system_book_id2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_system_book_id3', NULL, NULL, NULL, NULL, NULL, NULL, 'sb3.[source_system_book_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'source_system_book_id3', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_system_book_id4', NULL, NULL, NULL, NULL, NULL, NULL, 'sb4.[source_system_book_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'source_system_book_id4', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'description1', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[description1]', 'D:\Import_Export\ExportScript\', ';', 'n', 'description1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'description2', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[description2]', 'D:\Import_Export\ExportScript\', ';', 'n', 'description2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'description3', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[description3]', 'D:\Import_Export\ExportScript\', ';', 'n', 'description3', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_desk_id', NULL, NULL, NULL, NULL, NULL, NULL, 'internal_desk.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'internal_desk_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'product_id', NULL, NULL, NULL, NULL, NULL, NULL, 'product.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'product_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_portfolio_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[internal_portfolio_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'internal_portfolio_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'commodity_id', NULL, NULL, NULL, NULL, NULL, NULL, 'commodity.[commodity_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'commodity_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'reference', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[reference]', 'D:\Import_Export\ExportScript\', ';', 'n', 'reference', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'close_reference_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[close_reference_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'close_reference_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'block_type', NULL, NULL, NULL, NULL, NULL, NULL, 'block_type.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'block_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'block_define_id', NULL, NULL, NULL, NULL, NULL, NULL, 'block_define.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'block_define_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'granularity_id', NULL, NULL, NULL, NULL, NULL, NULL, 'granualarity.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'granularity_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Pricing', NULL, NULL, NULL, NULL, NULL, NULL, 'pricing.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'Pricing', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_reference_type_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[deal_reference_type_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_reference_type_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'unit_fixed_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[unit_fixed_flag]', 'D:\Import_Export\ExportScript\', ';', 'n', 'unit_fixed_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'broker_unit_fees', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[broker_unit_fees]', 'D:\Import_Export\ExportScript\', ';', 'n', 'broker_unit_fees', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'broker_fixed_cost', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[broker_fixed_cost]', 'D:\Import_Export\ExportScript\', ';', 'n', 'broker_fixed_cost', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'broker_currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'broker_currency.[currency_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'broker_currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_status', NULL, NULL, NULL, NULL, NULL, NULL, 'deal_status.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_status', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_frequency', 'dbo.FNAConvertGranularity(sdh.term_frequency)', NULL, NULL, NULL, NULL, NULL, 'sdh.[term_frequency]', 'D:\Import_Export\ExportScript\', ';', 'n', 'term_frequency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'option_settlement_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[option_settlement_date]', 'D:\Import_Export\ExportScript\', ';', 'n', 'option_settlement_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'confirm_status_type', NULL, NULL, NULL, NULL, NULL, NULL, 'confirm_status.[code]', 'D:\Import_Export\ExportScript\', ';', 'n', 'confirm_status_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'description4', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[description4]', 'D:\Import_Export\ExportScript\', ';', 'n', 'description4', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_start', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[term_start]', 'D:\Import_Export\ExportScript\', ';', 'n', 'term_start', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_end', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[term_end]', 'D:\Import_Export\ExportScript\', ';', 'n', 'term_end', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Leg', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[Leg]', 'D:\Import_Export\ExportScript\', ';', 'n', 'Leg', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_expiration_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[contract_expiration_date]', 'D:\Import_Export\ExportScript\', ';', 'n', 'contract_expiration_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fixed_float_leg', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[fixed_float_leg]', 'D:\Import_Export\ExportScript\', ';', 'n', 'fixed_float_leg', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'buy_sell_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[buy_sell_flag]', 'D:\Import_Export\ExportScript\', ';', 'n', 'buy_sell_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'curve_id', NULL, NULL, NULL, NULL, NULL, NULL, 'price_curve.[curve_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'curve_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fixed_price', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[fixed_price]', 'D:\Import_Export\ExportScript\', ';', 'n', 'fixed_price', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fixed_price_currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'fixed_currency.[currency_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'fixed_price_currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'option_strike_price', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[option_strike_price]', 'D:\Import_Export\ExportScript\', ';', 'n', 'option_strike_price', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_volume', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[deal_volume]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_volume', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'legal_entity', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[legal_entity]', 'D:\Import_Export\ExportScript\', ';', 'n', 'legal_entity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'sub_book', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[sub_book]', 'D:\Import_Export\ExportScript\', ';', 'n', 'sub_book', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'book_transfer_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[book_transfer_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'book_transfer_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'confirm_rule', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[confirm_rule]', 'D:\Import_Export\ExportScript\', ';', 'n', 'confirm_rule', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'total_volume', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[total_volume]', 'D:\Import_Export\ExportScript\', ';', 'n', 'total_volume', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'status', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[status]', 'D:\Import_Export\ExportScript\', ';', 'n', 'status', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_rules', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[deal_rules]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_rules', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Intrabook_deal_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[option_excercise_type]', 'D:\Import_Export\ExportScript\', ';', 'n', 'Intrabook_deal_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_locked', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[deal_locked]', 'D:\Import_Export\ExportScript\', ';', 'n', 'deal_locked', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'risk_sign_off_by', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[risk_sign_off_by]', 'D:\Import_Export\ExportScript\', ';', 'n', 'risk_sign_off_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'verified_by', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[verified_by]', 'D:\Import_Export\ExportScript\', ';', 'n', 'verified_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'back_office_sign_off_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[back_office_sign_off_date]', 'D:\Import_Export\ExportScript\', ';', 'n', 'back_office_sign_off_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'physical_financial_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[physical_financial_flag]', 'D:\Import_Export\ExportScript\', ';', 'n', 'physical_financial_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'back_office_sign_off_by', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[back_office_sign_off_by]', 'D:\Import_Export\ExportScript\', ';', 'n', 'back_office_sign_off_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'price_adder_currency2', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[price_adder_currency2]', 'D:\Import_Export\ExportScript\', ';', 'n', 'price_adder_currency2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_currency', NULL, NULL, NULL, NULL, NULL, NULL, 'settlement_uom.[type_id]', 'D:\Import_Export\ExportScript\', ';', 'n', 'settlement_currency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'lock_deal_detail', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd.[lock_deal_detail]', 'D:\Import_Export\ExportScript\', ';', 'n', 'lock_deal_detail', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'risk_sign_off_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[risk_sign_off_date]', 'D:\Import_Export\ExportScript\', ';', 'n', 'risk_sign_off_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'verified_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdh.[verified_date]', 'D:\Import_Export\ExportScript\', ';', 'n', 'verified_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_template'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END