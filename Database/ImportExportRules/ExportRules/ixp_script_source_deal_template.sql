IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Source Deal Template') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Source Deal Template' ,
				'y' ,
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
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  1,
									  NULL,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'source_deal_detail_template',
									    3011,
									    'sddt',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_price_curve_def',
									    3012,
									    'formula_curve',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_minor_location',
									    3013,
									    'location',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_price_curve_def',
									    3014,
									    'curve',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3015,
									    'currency',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3016,
									    'detail_commodity',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3017,
									    'meter',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_uom',
									    3018,
									    'price_uom',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3019,
									    'category',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_currency',
									    3020,
									    'adder_currency',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_currency',
									    3021,
									    'formula_currency',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_currency',
									    3022,
									    'fixed_price_currency',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3023,
									    'status',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_uom',
									    3024,
									    'uom',
									    3050 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_header',
									    3025,
									    'deal_id',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_counterparty',
									    3026,
									    'model',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_counterparty',
									    3027,
									    'broker_id',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_counterparty',
									    3028,
									    'counterparty',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_traders',
									    3029,
									    'traders',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'contract_group',
									    3030,
									    'contract',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_commodity',
									    3031,
									    'commodity',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_type',
									    3032,
									    'internal_deal_type',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_type',
									    3033,
									    'internal_subdeal_type',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_type',
									    3034,
									    'deal_type',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_type',
									    3035,
									    'deal_sub_type',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3036,
									    'assignment',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3037,
									    'state',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3038,
									    'generator',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3039,
									    'deal_status',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3040,
									    'deal_category',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3041,
									    'product',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3042,
									    'internal_desk',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3043,
									    'block',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3044,
									    'granularity',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3045,
									    'hourly_position',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3046,
									    'deal_rules',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3047,
									    'confirm_rules',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3048,
									    'internal_portfolio',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    3049,
									    'confirm_status',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_header_template',
									    3050,
									    'sdt',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_header_template',
									    3051,
									    'sdt1',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_system_description',
									    3052,
									    'source_system',
									    2419 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'maintain_field_template_detail',
									    3053,
									    'field_template',
									    2419

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          2662,         @ixp_rules_id_new,         3011,         3050,         'template_id',         'template_id',         3011 UNION ALL          SELECT          2663,         @ixp_rules_id_new,         3012,         3011,         'source_curve_def_id',         'formula_curve_id',         3012 UNION ALL          SELECT          2664,         @ixp_rules_id_new,         3013,         3011,         'source_minor_location_id',         'location_id',         3013 UNION ALL          SELECT          2665,         @ixp_rules_id_new,         3014,         3011,         'source_curve_def_id',         'curve_id',         3014 UNION ALL          SELECT          2666,         @ixp_rules_id_new,         3015,         3011,         'value_id',         'currency_id',         3015 UNION ALL          SELECT          2667,         @ixp_rules_id_new,         3017,         3011,         'value_id',         'meter_id',         3017 UNION ALL          SELECT          2668,         @ixp_rules_id_new,         3018,         3011,         'source_uom_id',         'price_uom_id',         3018 UNION ALL          SELECT          2669,         @ixp_rules_id_new,         3019,         3011,         'value_id',         'category',         3019 UNION ALL          SELECT          2670,         @ixp_rules_id_new,         3020,         3011,         'source_currency_id',         'adder_currency_id',         3020 UNION ALL          SELECT          2671,         @ixp_rules_id_new,         3021,         3011,         'source_currency_id',         'formula_currency_id',         3021 UNION ALL          SELECT          2672,         @ixp_rules_id_new,         3022,         3011,         'source_currency_id',         'fixed_price_currency_id',         3022 UNION ALL          SELECT          2673,         @ixp_rules_id_new,         3023,         3011,         'value_id',         'status',         3023 UNION ALL          SELECT          2674,         @ixp_rules_id_new,         3024,         3011,         'source_uom_id',         'settlement_uom',         3024 UNION ALL          SELECT          2675,         @ixp_rules_id_new,         3025,         3050,         'deal_id',         'deal_id',         3025 UNION ALL          SELECT          2676,         @ixp_rules_id_new,         3026,         3050,         'source_counterparty_id',         'model_id',         3026 UNION ALL          SELECT          2677,         @ixp_rules_id_new,         3027,         3050,         'source_counterparty_id',         'broker_id',         3027 UNION ALL          SELECT          2678,         @ixp_rules_id_new,         3028,         3050,         'source_counterparty_id',         'counterparty_id',         3028 UNION ALL          SELECT          2679,         @ixp_rules_id_new,         3029,         3050,         'source_trader_id',         'trader_id',         3029 UNION ALL          SELECT          2680,         @ixp_rules_id_new,         3030,         3050,         'contract_id',         'contract_id',         3030 UNION ALL          SELECT          2681,         @ixp_rules_id_new,         3031,         3011,         'source_commodity_id',         'commodity_id',         3031 UNION ALL          SELECT          2682,         @ixp_rules_id_new,         3031,         3050,         'source_commodity_id',         'commodity_id',         3031 UNION ALL          SELECT          2683,         @ixp_rules_id_new,         3032,         3050,         'source_deal_type_id',         'internal_deal_type_value_id',         3032 UNION ALL          SELECT          2684,         @ixp_rules_id_new,         3033,         3050,         'source_deal_type_id',         'internal_deal_subtype_value_id',         3033 UNION ALL          SELECT          2685,         @ixp_rules_id_new,         3034,         3050,         'source_deal_type_id',         'source_deal_type_id',         3034 UNION ALL          SELECT          2686,         @ixp_rules_id_new,         3035,         3050,         'source_deal_type_id',         'deal_sub_type_type_id',         3035 UNION ALL          SELECT          2687,         @ixp_rules_id_new,         3036,         3050,         'value_id',         'assignment_type_value_id',         3036 UNION ALL          SELECT          2688,         @ixp_rules_id_new,         3037,         3050,         'value_id',         'status_value_id',         3037 UNION ALL          SELECT          2689,         @ixp_rules_id_new,         3038,         3050,         'value_id',         'generator_id',         3038 UNION ALL          SELECT          2690,         @ixp_rules_id_new,         3039,         3050,         'value_id',         'deal_status',         3039 UNION ALL          SELECT          2691,         @ixp_rules_id_new,         3040,         3050,         'value_id',         'deal_category_value_id',         3040 UNION ALL          SELECT          2692,         @ixp_rules_id_new,         3041,         3050,         'value_id',         'product_id',         3041 UNION ALL          SELECT          2693,         @ixp_rules_id_new,         3042,         3050,         'value_id',         'internal_desk_id',         3042 UNION ALL          SELECT          2694,         @ixp_rules_id_new,         3043,         3050,         'value_id',         'block_define_id',         3043 UNION ALL          SELECT          2695,         @ixp_rules_id_new,         3044,         3050,         'value_id',         'granularity_id',         3044 UNION ALL          SELECT          2696,         @ixp_rules_id_new,         3045,         3050,         'value_id',         'hourly_position_breakdown',         3045 UNION ALL          SELECT          2697,         @ixp_rules_id_new,         3046,         3050,         'value_id',         'deal_rules',         3046 UNION ALL          SELECT          2698,         @ixp_rules_id_new,         3047,         3050,         'value_id',         'confirm_rule',         3047 UNION ALL          SELECT          2699,         @ixp_rules_id_new,         3048,         3050,         'value_id',         'internal_portfolio_id',         3048 UNION ALL          SELECT          2700,         @ixp_rules_id_new,         3049,         3050,         'value_id',         'confirm_status_type',         3049 UNION ALL          SELECT          2701,         @ixp_rules_id_new,         3051,         3050,         'template_id',         'internal_template_id',         3051 UNION ALL          SELECT          2702,         @ixp_rules_id_new,         3052,         3050,         'source_system_id',         'source_system_id',         3052 UNION ALL          SELECT          2703,         @ixp_rules_id_new,         3053,         3050,         'field_template_detail_id',         'field_template_id',         3053

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
								         it.ixp_tables_id, 'template_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[template_id]', 'D:\', NULL, 'y', 'template_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'template_name', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[template_name]', 'D:\', NULL, 'y', 'template_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'physical_financial_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[physical_financial_flag]', 'D:\', NULL, 'y', 'physical_financial_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_frequency_value', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[term_frequency_value]', 'D:\', NULL, 'y', 'term_frequency_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_frequency_type', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[term_frequency_type]', 'D:\', NULL, 'y', 'term_frequency_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'option_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[option_flag]', 'D:\', NULL, 'y', 'option_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'option_type', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[option_type]', 'D:\', NULL, 'y', 'option_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'option_exercise_type', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[option_exercise_type]', 'D:\', NULL, 'y', 'option_exercise_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'description1', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[description1]', 'D:\', NULL, 'y', 'description1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'description2', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[description2]', 'D:\', NULL, 'y', 'description2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'description3', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[description3]', 'D:\', NULL, 'y', 'description3', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'header_buy_sell_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[header_buy_sell_flag]', 'D:\', NULL, 'y', 'header_buy_sell_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_deal_type_id', NULL, NULL, NULL, NULL, NULL, NULL, 'deal_type.[source_deal_type_id]', 'D:\', NULL, 'y', 'source_deal_type_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_sub_type_type_id', NULL, NULL, NULL, NULL, NULL, NULL, 'deal_category.[value_id]', 'D:\', NULL, 'y', 'deal_sub_type_type_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_active', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[is_active]', 'D:\', NULL, 'y', 'is_active', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[internal_flag]', 'D:\', NULL, 'y', 'internal_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_deal_type_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'internal_deal_type.[source_deal_type_id]', 'D:\', NULL, 'y', 'internal_deal_type_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_deal_subtype_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'internal_subdeal_type.[source_deal_type_id]', 'D:\', NULL, 'y', 'internal_deal_subtype_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_template_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt1.[template_id]', 'D:\', NULL, 'y', 'internal_template_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'allow_edit_term', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[allow_edit_term]', 'D:\', NULL, 'y', 'allow_edit_term', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'blotter_supported', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[blotter_supported]', 'D:\', NULL, 'y', 'blotter_supported', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'rollover_to_spot', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[rollover_to_spot]', 'D:\', NULL, 'y', 'rollover_to_spot', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'discounting_applies', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[discounting_applies]', 'D:\', NULL, 'y', 'discounting_applies', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_end_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[term_end_flag]', 'D:\', NULL, 'y', 'term_end_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_public', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[is_public]', 'D:\', NULL, 'y', 'is_public', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_status', NULL, NULL, NULL, NULL, NULL, NULL, 'deal_status.[value_id]', 'D:\', NULL, 'y', 'deal_status', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_category_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'deal_category.[value_id]', 'D:\', NULL, 'y', 'deal_category_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'legal_entity', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[legal_entity]', 'D:\', NULL, 'y', 'legal_entity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'commodity_id', NULL, NULL, NULL, NULL, NULL, NULL, 'commodity.[source_commodity_id]', 'D:\', NULL, 'y', 'commodity_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_portfolio_id', NULL, NULL, NULL, NULL, NULL, NULL, 'internal_portfolio.[value_id]', 'D:\', NULL, 'y', 'internal_portfolio_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'product_id', NULL, NULL, NULL, NULL, NULL, NULL, 'product.[value_id]', 'D:\', NULL, 'y', 'product_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_desk_id', NULL, NULL, NULL, NULL, NULL, NULL, 'internal_desk.[value_id]', 'D:\', NULL, 'y', 'internal_desk_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'block_type', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[block_type]', 'D:\', NULL, 'y', 'block_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'block_define_id', NULL, NULL, NULL, NULL, NULL, NULL, 'block.[value_id]', 'D:\', NULL, 'y', 'block_define_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'granularity_id', NULL, NULL, NULL, NULL, NULL, NULL, 'granularity.[value_id]', 'D:\', NULL, 'y', 'granularity_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Pricing', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[Pricing]', 'D:\', NULL, 'y', 'Pricing', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'make_comment_mandatory_on_save', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[make_comment_mandatory_on_save]', 'D:\', NULL, 'y', 'make_comment_mandatory_on_save', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'model_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[model_id]', 'D:\', NULL, 'y', 'model_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'comments', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[comments]', 'D:\', NULL, 'y', 'comments', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'trade_ticket_template', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[trade_ticket_template]', 'D:\', NULL, 'y', 'trade_ticket_template', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'hourly_position_breakdown', NULL, NULL, NULL, NULL, NULL, NULL, 'hourly_position.[value_id]', 'D:\', NULL, 'y', 'hourly_position_breakdown', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_id', NULL, NULL, NULL, NULL, NULL, NULL, 'contract.[contract_id]', 'D:\', NULL, 'y', 'contract_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'counterparty.[source_counterparty_id]', 'D:\', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_rules', NULL, NULL, NULL, NULL, NULL, NULL, 'deal_rules.[value_id]', 'D:\', NULL, 'y', 'deal_rules', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'confirm_rule', NULL, NULL, NULL, NULL, NULL, NULL, 'confirm_rules.[value_id]', 'D:\', NULL, 'y', 'confirm_rule', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'verified_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[verified_date]', 'D:\', NULL, 'y', 'verified_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'ext_deal_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[ext_deal_id]', 'D:\', NULL, 'y', 'ext_deal_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_frequency', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[ext_deal_id]', 'D:\', NULL, 'y', 'term_frequency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_deal_header_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[source_deal_header_id]', 'D:\', NULL, 'y', 'source_deal_header_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'back_office_sign_off_by', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[back_office_sign_off_by]', 'D:\', NULL, 'y', 'back_office_sign_off_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'field_template_id', NULL, NULL, NULL, NULL, NULL, NULL, 'field_template.[field_template_detail_id]', 'D:\', NULL, 'y', 'field_template_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'entire_term_start', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[entire_term_start]', 'D:\', NULL, 'y', 'entire_term_start', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'rolling_avg', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[rolling_avg]', 'D:\', NULL, 'y', 'rolling_avg', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'confirm_status_type', NULL, NULL, NULL, NULL, NULL, NULL, 'confirm_status.[value_id]', 'D:\', NULL, 'y', 'confirm_status_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'calculate_position_based_on_actual', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[calculate_position_based_on_actual]', 'D:\', NULL, 'y', 'calculate_position_based_on_actual', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'structured_deal_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[structured_deal_id]', 'D:\', NULL, 'y', 'structured_deal_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'compliance_year', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[compliance_year]', 'D:\', NULL, 'y', 'compliance_year', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[deal_date]', 'D:\', NULL, 'y', 'deal_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'state_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[status_value_id]', 'D:\', NULL, 'y', 'state_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'book_transfer_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[book_transfer_id]', 'D:\', NULL, 'y', 'book_transfer_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'trader_id', NULL, NULL, NULL, NULL, NULL, NULL, 'traders.[source_trader_id]', 'D:\', NULL, 'y', 'trader_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'aggregate_environment', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[aggregate_environment]', 'D:\', NULL, 'y', 'aggregate_environment', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_locked', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[deal_locked]', 'D:\', NULL, 'y', 'deal_locked', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'template_detail_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[template_detail_id]', 'D:\', NULL, 'y', 'template_detail_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'leg', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[leg]', 'D:\', NULL, 'y', 'leg', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fixed_float_leg', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[fixed_float_leg]', 'D:\', NULL, 'y', 'fixed_float_leg', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'buy_sell_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[buy_sell_flag]', 'D:\', NULL, 'y', 'buy_sell_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'curve_type', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[curve_type]', 'D:\', NULL, 'y', 'curve_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'curve_id', NULL, NULL, NULL, NULL, NULL, NULL, 'curve.[source_curve_def_id]', 'D:\', NULL, 'y', 'curve_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_volume_frequency', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[deal_volume_frequency]', 'D:\', NULL, 'y', 'deal_volume_frequency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_volume_uom_id', NULL, NULL, NULL, NULL, NULL, NULL, 'deal_category.[entity_id]', 'D:\', NULL, 'y', 'deal_volume_uom_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'currency.[value_id]', 'D:\', NULL, 'y', 'currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'block_description', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[block_description]', 'D:\', NULL, 'y', 'block_description', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'template_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[template_id]', 'D:\', NULL, 'y', 'template_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'commodity_id', NULL, NULL, NULL, NULL, NULL, NULL, 'commodity.[source_commodity_id]', 'D:\', NULL, 'y', 'commodity_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'day_count', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[day_count]', 'D:\', NULL, 'y', 'day_count', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'physical_financial_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[physical_financial_flag]', 'D:\', NULL, 'y', 'physical_financial_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'location_id', NULL, NULL, NULL, NULL, NULL, NULL, 'location.[source_minor_location_id]', 'D:\', NULL, 'y', 'location_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'meter_id', NULL, NULL, NULL, NULL, NULL, NULL, 'meter.[value_id]', 'D:\', NULL, 'y', 'meter_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'strip_months_from', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[strip_months_from]', 'D:\', NULL, 'y', 'strip_months_from', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'lag_months', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[lag_months]', 'D:\', NULL, 'y', 'lag_months', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'strip_months_to', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[strip_months_to]', 'D:\', NULL, 'y', 'strip_months_to', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'conversion_factor', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[conversion_factor]', 'D:\', NULL, 'y', 'conversion_factor', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pay_opposite', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[pay_opposite]', 'D:\', NULL, 'y', 'pay_opposite', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[formula]', 'D:\', NULL, 'y', 'formula', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_currency', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[settlement_currency]', 'D:\', NULL, 'y', 'settlement_currency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'standard_yearly_volume', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[standard_yearly_volume]', 'D:\', NULL, 'y', 'standard_yearly_volume', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'price_uom_id', NULL, NULL, NULL, NULL, NULL, NULL, 'price_uom.[source_uom_id]', 'D:\', NULL, 'y', 'price_uom_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'category', NULL, NULL, NULL, NULL, NULL, NULL, 'category.[value_id]', 'D:\', NULL, 'y', 'category', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'profile_code', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[profile_code]', 'D:\', NULL, 'y', 'profile_code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pv_party', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[pv_party]', 'D:\', NULL, 'y', 'pv_party', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'adder_currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'adder_currency.[source_currency_id]', 'D:\', NULL, 'y', 'adder_currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'booked', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[booked]', 'D:\', NULL, 'y', 'booked', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'capacity', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[capacity]', 'D:\', NULL, 'y', 'capacity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'day_count_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[day_count_id]', 'D:\', NULL, 'y', 'day_count_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_detail_description', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[deal_detail_description]', 'D:\', NULL, 'y', 'deal_detail_description', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fixed_cost', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[fixed_cost]', 'D:\', NULL, 'y', 'fixed_cost', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fixed_cost_currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'fixed_price_currency.[source_currency_id]', 'D:\', NULL, 'y', 'fixed_cost_currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula_currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'formula_currency.[source_currency_id]', 'D:\', NULL, 'y', 'formula_currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula_curve_id', NULL, NULL, NULL, NULL, NULL, NULL, 'formula_curve.[source_curve_def_id]', 'D:\', NULL, 'y', 'formula_curve_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula_id', NULL, NULL, NULL, NULL, NULL, NULL, 'field_template.[field_template_detail_id]', 'D:\', NULL, 'y', 'formula_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'multiplier', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[multiplier]', 'D:\', NULL, 'y', 'multiplier', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'option_strike_price', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[option_strike_price]', 'D:\', NULL, 'y', 'option_strike_price', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'price_adder', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[price_adder]', 'D:\', NULL, 'y', 'price_adder', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'price_adder_currency2', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[price_adder_currency2]', 'D:\', NULL, 'y', 'price_adder_currency2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'price_adder2', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[price_adder2]', 'D:\', NULL, 'y', 'price_adder2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'price_multiplier', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[price_multiplier]', 'D:\', NULL, 'y', 'price_multiplier', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'process_deal_status', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[process_deal_status]', 'D:\', NULL, 'y', 'process_deal_status', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[settlement_date]', 'D:\', NULL, 'y', 'settlement_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_uom', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[settlement_uom]', 'D:\', NULL, 'y', 'settlement_uom', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_volume', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[settlement_volume]', 'D:\', NULL, 'y', 'settlement_volume', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'total_volume', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[total_volume]', 'D:\', NULL, 'y', 'total_volume', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_left', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[volume_left]', 'D:\', NULL, 'y', 'volume_left', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_multiplier2', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[volume_multiplier2]', 'D:\', NULL, 'y', 'volume_multiplier2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_start', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[term_start]', 'D:\', NULL, 'y', 'term_start', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_end', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[term_end]', 'D:\', NULL, 'y', 'term_end', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_expiration_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[contract_expiration_date]', 'D:\', NULL, 'y', 'contract_expiration_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fixed_price', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[fixed_price]', 'D:\', NULL, 'y', 'fixed_price', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fixed_price_currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'fixed_price_currency.[source_currency_id]', 'D:\', NULL, 'y', 'fixed_price_currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_volume', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[deal_volume]', 'D:\', NULL, 'y', 'deal_volume', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'status', NULL, NULL, NULL, NULL, NULL, NULL, 'status.[value_id]', 'D:\', NULL, 'y', 'status', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'lock_deal_detail', NULL, NULL, NULL, NULL, NULL, NULL, 'sddt.[lock_deal_detail]', 'D:\', NULL, 'y', 'lock_deal_detail', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_detail_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sddt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'save_mtm_at_calculation_granularity', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[save_mtm_at_calculation_granularity]', 'D:\', NULL, 'y', 'save_mtm_at_calculation_granularity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'status_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[status_date]', 'D:\', NULL, 'y', 'status_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'risk_sign_off_by', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[risk_sign_off_by]', 'D:\', NULL, 'y', 'risk_sign_off_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'verified_by', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[verified_by]', 'D:\', NULL, 'y', 'verified_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_reference_type_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[deal_reference_type_id]', 'D:\', NULL, 'y', 'deal_reference_type_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'back_office_sign_off_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[back_office_sign_off_date]', 'D:\', NULL, 'y', 'back_office_sign_off_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'generation_source', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[generation_source]', 'D:\', NULL, 'y', 'generation_source', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'rec_price', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[rec_price]', 'D:\', NULL, 'y', 'rec_price', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'unit_fixed_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[unit_fixed_flag]', 'D:\', NULL, 'y', 'unit_fixed_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'aggregate_envrionment_comment', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[aggregate_envrionment_comment]', 'D:\', NULL, 'y', 'aggregate_envrionment_comment', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'reference', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[reference]', 'D:\', NULL, 'y', 'reference', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'broker_currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[broker_currency_id]', 'D:\', NULL, 'y', 'broker_currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'assignment_type_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'assignment.[value_id]', 'D:\', NULL, 'y', 'assignment_type_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'risk_sign_off_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[risk_sign_off_date]', 'D:\', NULL, 'y', 'risk_sign_off_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'assigned_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[assigned_date]', 'D:\', NULL, 'y', 'assigned_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'close_reference_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[close_reference_id]', 'D:\', NULL, 'y', 'close_reference_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'broker_fixed_cost', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[broker_fixed_cost]', 'D:\', NULL, 'y', 'broker_fixed_cost', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'option_excercise_type', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[option_exercise_type]', 'D:\', NULL, 'y', 'option_excercise_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'assigned_by', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[assigned_by]', 'D:\', NULL, 'y', 'assigned_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'entire_term_end', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[entire_term_end]', 'D:\', NULL, 'y', 'entire_term_end', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'status_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'state.[value_id]', 'D:\', NULL, 'y', 'status_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'generator_id', NULL, NULL, NULL, NULL, NULL, NULL, 'generator.[value_id]', 'D:\', NULL, 'y', 'generator_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_id', NULL, NULL, NULL, NULL, NULL, NULL, 'deal_id.[deal_id]', 'D:\', NULL, 'y', 'deal_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'option_settlement_date', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[option_settlement_date]', 'D:\', NULL, 'y', 'option_settlement_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'broker_unit_fees', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[broker_unit_fees]', 'D:\', NULL, 'y', 'broker_unit_fees', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'broker_id', NULL, NULL, NULL, NULL, NULL, NULL, 'broker_id.[source_counterparty_id]', 'D:\', NULL, 'y', 'broker_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_system_id', NULL, NULL, NULL, NULL, NULL, NULL, 'source_system.[source_system_id]', 'D:\', NULL, 'y', 'source_system_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_deal_header_template'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sdt'
								WHERE it.ixp_tables_name = 'ixp_source_deal_header_template'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END