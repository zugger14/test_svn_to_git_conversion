IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Contract Detail Export') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Contract Detail Export' ,
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
								WHERE it.ixp_tables_name = 'ixp_contract_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  1,
									  NULL,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'contract_group',
									    526,
									    'cg',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_book',
									    527,
									    'sb1',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_book',
									    528,
									    'sb2',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_book',
									    529,
									    'sb3',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_book',
									    530,
									    'sb4',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_currency',
									    531,
									    'sc',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_deal_type',
									    532,
									    'sdt',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_uom',
									    533,
									    'vol_uom',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_uom',
									    534,
									    'rec_uom',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    535,
									    'vg',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    536,
									    'bill_cycle',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    537,
									    'line_items',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    538,
									    'cctd_value',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    539,
									    'tou',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    540,
									    'sdv_gl',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    541,
									    'ptn',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    542,
									    'utr',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    543,
									    'eqr',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    544,
									    'pay_cal',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    545,
									    'pay_date',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    546,
									    'pnl_cal',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    547,
									    'agg_level',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    548,
									    'class_name',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    549,
									    'ipn',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    550,
									    'pay_cal_header',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    551,
									    'pay_date_header',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    552,
									    'pnl_cal_header',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    553,
									    'sdv_gl_est',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    554,
									    'group_by',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    555,
									    'vol_gran',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    556,
									    'pnl_date_header',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    557,
									    'set_cal_header',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    558,
									    'set_date_header',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    559,
									    'pnl_date',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    560,
									    'set_cal',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    561,
									    'set_date',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'formula_editor',
									    562,
									    'fe',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'formula_editor',
									    563,
									    'tb',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'contract_group_detail',
									    564,
									    'cgd',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'Contract_report_template',
									    565,
									    'crt',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'Contract_report_template',
									    566,
									    'nrt',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'Contract_report_template',
									    567,
									    'irt',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'contract_charge_type',
									    568,
									    'cct',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'contract_charge_type_detail',
									    569,
									    'cctd',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'adjustment_default_gl_codes',
									    570,
									    'adjc',
									    552 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'adjustment_default_gl_codes',
									    571,
									    'adjc_est',
									    552

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          447,         @ixp_rules_id_new,         531,         526,         'source_currency_id',         'currency',         531 UNION ALL          SELECT          448,         @ixp_rules_id_new,         533,         526,         'source_uom_id',         'volume_uom',         533 UNION ALL          SELECT          449,         @ixp_rules_id_new,         534,         526,         'source_uom_id',         'rec_uom',         534 UNION ALL          SELECT          450,         @ixp_rules_id_new,         535,         526,         'value_id',         'volume_granularity',         535 UNION ALL          SELECT          451,         @ixp_rules_id_new,         536,         526,         'value_id',         'billing_cycle',         536 UNION ALL          SELECT          452,         @ixp_rules_id_new,         550,         526,         'value_id',         'payment_calendar',         550 UNION ALL          SELECT          453,         @ixp_rules_id_new,         565,         526,         'template_id',         'contract_report_template',         565 UNION ALL          SELECT          454,         @ixp_rules_id_new,         566,         526,         'template_id',         'netting_template',         566 UNION ALL          SELECT          455,         @ixp_rules_id_new,         567,         526,         'template_id',         'invoice_report_template',         567 UNION ALL          SELECT          456,         @ixp_rules_id_new,         551,         526,         'value_id',         'payment_days',         551 UNION ALL          SELECT          457,         @ixp_rules_id_new,         552,         526,         'value_id',         'pnl_calendar',         552 UNION ALL          SELECT          458,         @ixp_rules_id_new,         556,         526,         'value_id',         'pnl_date',         556 UNION ALL          SELECT          459,         @ixp_rules_id_new,         557,         526,         'value_id',         'settlement_calendar',         557 UNION ALL          SELECT          460,         @ixp_rules_id_new,         558,         526,         'value_id',         'settlement_date',         558 UNION ALL          SELECT          461,         @ixp_rules_id_new,         564,         526,         'contract_id',         'contract_id',         564 UNION ALL          SELECT          462,         @ixp_rules_id_new,         527,         564,         'source_book_id',         'group1',         527 UNION ALL          SELECT          463,         @ixp_rules_id_new,         528,         564,         'source_book_id',         'group2',         528 UNION ALL          SELECT          464,         @ixp_rules_id_new,         529,         564,         'source_book_id',         'group3',         529 UNION ALL          SELECT          465,         @ixp_rules_id_new,         530,         564,         'source_book_id',         'group4',         530 UNION ALL          SELECT          466,         @ixp_rules_id_new,         532,         564,         'source_deal_type_id',         'deal_type',         532 UNION ALL          SELECT          467,         @ixp_rules_id_new,         537,         564,         'value_id',         'invoice_line_item_id',         537 UNION ALL          SELECT          468,         @ixp_rules_id_new,         569,         564,         'ID',         'contract_component_template',         569 UNION ALL          SELECT          469,         @ixp_rules_id_new,         570,         564,         'default_gl_id',         'default_gl_id',         570 UNION ALL          SELECT          470,         @ixp_rules_id_new,         571,         564,         'default_gl_id',         'default_gl_id_estimates',         571 UNION ALL          SELECT          471,         @ixp_rules_id_new,         555,         564,         'value_id',         'volume_granularity',         555 UNION ALL          SELECT          472,         @ixp_rules_id_new,         560,         564,         'value_id',         'settlement_calendar',         560 UNION ALL          SELECT          473,         @ixp_rules_id_new,         561,         564,         'value_id',         'settlement_date',         561 UNION ALL          SELECT          474,         @ixp_rules_id_new,         562,         564,         'formula_id',         'formula_id',         562 UNION ALL          SELECT          475,         @ixp_rules_id_new,         563,         564,         'formula_id',         'time_bucket_formula_id',         563 UNION ALL          SELECT          476,         @ixp_rules_id_new,         568,         564,         'contract_charge_type_id',         'contract_template',         568 UNION ALL          SELECT          477,         @ixp_rules_id_new,         546,         564,         'value_id',         'pnl_date',         546 UNION ALL          SELECT          478,         @ixp_rules_id_new,         546,         564,         'value_id',         'pnl_calendar',         546 UNION ALL          SELECT          479,         @ixp_rules_id_new,         547,         564,         'value_id',         'calc_aggregation',         547 UNION ALL          SELECT          480,         @ixp_rules_id_new,         548,         564,         'value_id',         'class_name',         548 UNION ALL          SELECT          481,         @ixp_rules_id_new,         549,         564,         'value_id',         'increment_peaking_name',         549 UNION ALL          SELECT          482,         @ixp_rules_id_new,         554,         564,         'value_id',         'group_by',         554 UNION ALL          SELECT          483,         @ixp_rules_id_new,         539,         564,         'value_id',         'timeofuse',         539 UNION ALL          SELECT          484,         @ixp_rules_id_new,         541,         564,         'value_id',         'product_type_name',         541 UNION ALL          SELECT          485,         @ixp_rules_id_new,         542,         564,         'value_id',         'units_for_rate',         542 UNION ALL          SELECT          486,         @ixp_rules_id_new,         543,         564,         'value_id',         'eqr_product_name',         543 UNION ALL          SELECT          487,         @ixp_rules_id_new,         544,         564,         'value_id',         'payment_calendar',         544 UNION ALL          SELECT          488,         @ixp_rules_id_new,         545,         564,         'value_id',         'payment_date',         545 UNION ALL          SELECT          489,         @ixp_rules_id_new,         538,         569,         'value_id',         'invoice_line_item_id',         538 UNION ALL          SELECT          490,         @ixp_rules_id_new,         540,         570,         'value_id',         'adjustment_type_id',         540 UNION ALL          SELECT          491,         @ixp_rules_id_new,         553,         571,         'value_id',         'adjustment_type_id',         553

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
								         it.ixp_tables_id, 'contract_name', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[contract_name]', '\\lhotse\users\export', ';', 'n', 'contract_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[contract_date]', '\\lhotse\users\export', ';', 'n', 'contract_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'receive_invoice', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[receive_invoice]', '\\lhotse\users\export', ';', 'n', 'receive_invoice', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_accountant', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[settlement_accountant]', '\\lhotse\users\export', ';', 'n', 'settlement_accountant', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_cycle', NULL, NULL, NULL, NULL, NULL, NULL, 'bill_cycle.[code]', '\\lhotse\users\export', ';', 'n', 'billing_cycle', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'invoice_due_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[invoice_due_date]', '\\lhotse\users\export', ';', 'n', 'invoice_due_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_granularity', NULL, NULL, NULL, NULL, NULL, NULL, 'vg.[code]', '\\lhotse\users\export', ';', 'n', 'volume_granularity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'hourly_block', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[hourly_block]', '\\lhotse\users\export', ';', 'n', 'hourly_block', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'currency', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[currency_id]', '\\lhotse\users\export', ';', 'n', 'currency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_mult', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[volume_mult]', '\\lhotse\users\export', ';', 'n', 'volume_mult', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'onpeak_mult', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[onpeak_mult]', '\\lhotse\users\export', ';', 'n', 'onpeak_mult', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'offpeak_mult', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[offpeak_mult]', '\\lhotse\users\export', ';', 'n', 'offpeak_mult', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'type', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[type]', '\\lhotse\users\export', ';', 'n', 'type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'reverse_entries', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[reverse_entries]', '\\lhotse\users\export', ';', 'n', 'reverse_entries', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_uom', NULL, NULL, NULL, NULL, NULL, NULL, 'vol_uom.[uom_id]', '\\lhotse\users\export', ';', 'n', 'volume_uom', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'rec_uom', NULL, NULL, NULL, NULL, NULL, NULL, 'rec_uom.[uom_id]', '\\lhotse\users\export', ';', 'n', 'rec_uom', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_specialist', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[contract_specialist]', '\\lhotse\users\export', ';', 'n', 'contract_specialist', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_start', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[term_start]', '\\lhotse\users\export', ';', 'n', 'term_start', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_end', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[term_end]', '\\lhotse\users\export', ';', 'n', 'term_end', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'name', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[name]', '\\lhotse\users\export', ';', 'n', 'name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'company', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[company]', '\\lhotse\users\export', ';', 'n', 'company', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'state', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[state]', '\\lhotse\users\export', ';', 'n', 'state', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'city', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[city]', '\\lhotse\users\export', ';', 'n', 'city', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'zip', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[zip]', '\\lhotse\users\export', ';', 'n', 'zip', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[address]', '\\lhotse\users\export', ';', 'n', 'address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address2', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[address2]', '\\lhotse\users\export', ';', 'n', 'address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'telephone', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[telephone]', '\\lhotse\users\export', ';', 'n', 'telephone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'email', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[email]', '\\lhotse\users\export', ';', 'n', 'email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fax', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[name2]', '\\lhotse\users\export', ';', 'n', 'fax', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'name2', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[company2]', '\\lhotse\users\export', ';', 'n', 'name2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'company2', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[company2]', '\\lhotse\users\export', ';', 'n', 'company2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'telephone2', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[telephone2]', '\\lhotse\users\export', ';', 'n', 'telephone2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fax2', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[fax2]', '\\lhotse\users\export', ';', 'n', 'fax2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'email2', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[email2]', '\\lhotse\users\export', ';', 'n', 'email2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_contract_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[source_contract_id]', '\\lhotse\users\export', ';', 'n', 'source_contract_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_system_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[source_system_id]', '\\lhotse\users\export', ';', 'n', 'source_system_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_desc', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[contract_desc]', '\\lhotse\users\export', ';', 'n', 'contract_desc', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'energy_type', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[energy_type]', '\\lhotse\users\export', ';', 'n', 'energy_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'area_engineer', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[area_engineer]', '\\lhotse\users\export', ';', 'n', 'area_engineer', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'metering_contract', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[metering_contract]', '\\lhotse\users\export', ';', 'n', 'metering_contract', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'miso_queue_number', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[miso_queue_number]', '\\lhotse\users\export', ';', 'n', 'miso_queue_number', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'substation_name', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[substation_name]', '\\lhotse\users\export', ';', 'n', 'substation_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'project_county', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[project_county]', '\\lhotse\users\export', ';', 'n', 'project_county', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'voltage', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[voltage]', '\\lhotse\users\export', ';', 'n', 'voltage', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'time_zone', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[time_zone]', '\\lhotse\users\export', ';', 'n', 'time_zone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_service_agreement_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[contract_service_agreement_id]', '\\lhotse\users\export', ';', 'n', 'contract_service_agreement_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_charge_type_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[contract_charge_type_id]', '\\lhotse\users\export', ';', 'n', 'contract_charge_type_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_from_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[billing_from_date]', '\\lhotse\users\export', ';', 'n', 'billing_from_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_to_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[billing_to_date]', '\\lhotse\users\export', ';', 'n', 'billing_to_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_report_template', NULL, NULL, NULL, NULL, NULL, NULL, 'crt.[template_name]', '\\lhotse\users\export', ';', 'n', 'contract_report_template', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Subledger_code', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[Subledger_code]', '\\lhotse\users\export', ';', 'n', 'Subledger_code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'UD_Contract_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[contract_name]', '\\lhotse\users\export', ';', 'n', 'UD_Contract_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'extension_provision_description', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[extension_provision_description]', '\\lhotse\users\export', ';', 'n', 'extension_provision_description', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_name', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[term_name]', '\\lhotse\users\export', ';', 'n', 'term_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'increment_name', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[increment_period]', '\\lhotse\users\export', ';', 'n', 'increment_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'ferct_tarrif_reference', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[ferct_tarrif_reference]', '\\lhotse\users\export', ';', 'n', 'ferct_tarrif_reference', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'point_of_delivery_control_area', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[point_of_delivery_control_area]', '\\lhotse\users\export', ';', 'n', 'point_of_delivery_control_area', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'point_of_delivery_specific_location', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[point_of_delivery_specific_location]', '\\lhotse\users\export', ';', 'n', 'point_of_delivery_specific_location', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_affiliate', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[contract_affiliate]', '\\lhotse\users\export', ';', 'n', 'contract_affiliate', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[contract_name]', '\\lhotse\users\export\', ';', 'n', 'contract_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'invoice_line_item_id', NULL, NULL, NULL, NULL, NULL, NULL, 'line_items.[code]', '\\lhotse\users\export\', ';', 'n', 'invoice_line_item_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'default_gl_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sdv_gl.[code]', '\\lhotse\users\export\', ';', 'n', 'default_gl_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'price', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[price]', '\\lhotse\users\export\', ';', 'n', 'price', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula_id', NULL, NULL, NULL, NULL, NULL, NULL, 'fe.[formula_id]', '\\lhotse\users\export\', ';', 'n', 'formula_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'manual', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[manual]', '\\lhotse\users\export\', ';', 'n', 'manual', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'currency', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[source_currency_id]', '\\lhotse\users\export\', ';', 'n', 'currency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Prod_type', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[Prod_type]', '\\lhotse\users\export\', ';', 'n', 'Prod_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'sequence_order', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[sequence_order]', '\\lhotse\users\export\', ';', 'n', 'sequence_order', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'inventory_item', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[inventory_item]', '\\lhotse\users\export\', ';', 'n', 'inventory_item', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'class_name', NULL, NULL, NULL, NULL, NULL, NULL, 'class_name.[code]', '\\lhotse\users\export\', ';', 'n', 'class_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'increment_peaking_name', NULL, NULL, NULL, NULL, NULL, NULL, 'ipn.[code]', '\\lhotse\users\export\', ';', 'n', 'increment_peaking_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'product_type_name', NULL, NULL, NULL, NULL, NULL, NULL, 'ptn.[code]', '\\lhotse\users\export\', ';', 'n', 'product_type_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'rate_description', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[rate_description]', '\\lhotse\users\export\', ';', 'n', 'rate_description', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'units_for_rate', NULL, NULL, NULL, NULL, NULL, NULL, 'utr.[code]', '\\lhotse\users\export\', ';', 'n', 'units_for_rate', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'begin_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[begin_date]', '\\lhotse\users\export\', ';', 'n', 'begin_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'end_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[end_date]', '\\lhotse\users\export\', ';', 'n', 'end_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'default_gl_id_estimates', NULL, NULL, NULL, NULL, NULL, NULL, 'sdv_gl_est.[code]', '\\lhotse\users\export\', ';', 'n', 'default_gl_id_estimates', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'eqr_product_name', NULL, NULL, NULL, NULL, NULL, NULL, 'eqr.[code]', '\\lhotse\users\export\', ';', 'n', 'eqr_product_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'group_by', NULL, NULL, NULL, NULL, NULL, NULL, 'group_by.[code]', '\\lhotse\users\export\', ';', 'n', 'group_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'alias', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[alias]', '\\lhotse\users\export\', ';', 'n', 'alias', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'hideInInvoice', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[hideInInvoice]', '\\lhotse\users\export\', ';', 'n', 'hideInInvoice', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'int_begin_month', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[int_begin_month]', '\\lhotse\users\export\', ';', 'n', 'int_begin_month', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'int_end_month', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[int_end_month]', '\\lhotse\users\export\', ';', 'n', 'int_end_month', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_granularity', NULL, NULL, NULL, NULL, NULL, NULL, 'vol_gran.[code]', '\\lhotse\users\export\', ';', 'n', 'volume_granularity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_type', NULL, NULL, NULL, NULL, NULL, NULL, 'sdt.[source_deal_type_name]', '\\lhotse\users\export\', ';', 'n', 'deal_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'time_bucket_formula_id', NULL, NULL, NULL, NULL, NULL, NULL, 'tb.[formula_id]', '\\lhotse\users\export\', ';', 'n', 'time_bucket_formula_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'calc_aggregation', NULL, NULL, NULL, NULL, NULL, NULL, 'agg_level.[code]', '\\lhotse\users\export\', ';', 'n', 'calc_aggregation', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_date', NULL, NULL, NULL, NULL, NULL, NULL, 'pay_date.[code]', '\\lhotse\users\export\', ';', 'n', 'payment_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_calendar', NULL, NULL, NULL, NULL, NULL, NULL, 'pay_cal.[code]', '\\lhotse\users\export\', ';', 'n', 'payment_calendar', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pnl_date', NULL, NULL, NULL, NULL, NULL, NULL, 'pay_date.[code]', '\\lhotse\users\export\', ';', 'n', 'pnl_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pnl_calendar', NULL, NULL, NULL, NULL, NULL, NULL, 'pnl_cal.[code]', '\\lhotse\users\export\', ';', 'n', 'pnl_calendar', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'timeofuse', NULL, NULL, NULL, NULL, NULL, NULL, 'tou.[code]', '\\lhotse\users\export\', ';', 'n', 'timeofuse', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'include_charges', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[include_charges]', '\\lhotse\users\export\', ';', 'n', 'include_charges', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_template', NULL, NULL, NULL, NULL, NULL, NULL, 'cct.[contract_charge_desc]', '\\lhotse\users\export\', ';', 'n', 'contract_template', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_component_template', NULL, NULL, NULL, NULL, NULL, NULL, 'cctd_value.[code]', '\\lhotse\users\export\', ';', 'n', 'contract_component_template', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'radio_automatic_manual', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[radio_automatic_manual]', '\\lhotse\users\export\', ';', 'n', 'radio_automatic_manual', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_date', NULL, NULL, NULL, NULL, NULL, NULL, 'set_date.[code]', '\\lhotse\users\export\', ';', 'n', 'settlement_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_calendar', NULL, NULL, NULL, NULL, NULL, NULL, 'set_cal.[code]', '\\lhotse\users\export\', ';', 'n', 'settlement_calendar', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'effective_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[effective_date]', '\\lhotse\users\export\', ';', 'n', 'effective_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'group1', NULL, NULL, NULL, NULL, NULL, NULL, 'sb1.[source_book_name]', '\\lhotse\users\export\', ';', 'n', 'group1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'group2', NULL, NULL, NULL, NULL, NULL, NULL, 'sb2.[source_book_name]', '\\lhotse\users\export\', ';', 'n', 'group2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'group3', NULL, NULL, NULL, NULL, NULL, NULL, 'sb3.[source_book_name]', '\\lhotse\users\export\', ';', 'n', 'group3', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'group4', NULL, NULL, NULL, NULL, NULL, NULL, 'sb4.[source_book_name]', '\\lhotse\users\export\', ';', 'n', 'group4', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'leg', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[leg]', '\\lhotse\users\export\', ';', 'n', 'leg', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'include_invoice', NULL, NULL, NULL, NULL, NULL, NULL, 'cgd.[include_invoice]', '\\lhotse\users\export\', ';', 'n', 'include_invoice', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'point_of_receipt_control_area', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[point_of_receipt_control_area]', '\\lhotse\users\export', ';', 'n', 'point_of_receipt_control_area', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'point_of_receipt_specific_location', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[point_of_receipt_specific_location]', '\\lhotse\users\export', ';', 'n', 'point_of_receipt_specific_location', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'no_meterdata', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[no_meterdata]', '\\lhotse\users\export', ';', 'n', 'no_meterdata', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_start_month', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[billing_start_month]', '\\lhotse\users\export', ';', 'n', 'billing_start_month', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'increment_period', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[increment_period]', '\\lhotse\users\export', ';', 'n', 'increment_period', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bookout_provision', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[bookout_provision]', '\\lhotse\users\export', ';', 'n', 'bookout_provision', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_status', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[contract_status]', '\\lhotse\users\export', ';', 'n', 'contract_status', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'holiday_calendar_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[holiday_calendar_id]', '\\lhotse\users\export', ';', 'n', 'holiday_calendar_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_from_hour', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[billing_from_hour]', '\\lhotse\users\export', ';', 'n', 'billing_from_hour', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_to_hour', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[billing_to_hour]', '\\lhotse\users\export', ';', 'n', 'billing_to_hour', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'block_type', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[block_type]', '\\lhotse\users\export', ';', 'n', 'block_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_active', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[is_active]', '\\lhotse\users\export', ';', 'n', 'is_active', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_calendar', NULL, NULL, NULL, NULL, NULL, NULL, 'pay_cal_header.[code]', '\\lhotse\users\export', ';', 'n', 'payment_calendar', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pnl_date', NULL, NULL, NULL, NULL, NULL, NULL, 'pnl_cal_header.[code]', '\\lhotse\users\export', ';', 'n', 'pnl_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pnl_calendar', NULL, NULL, NULL, NULL, NULL, NULL, 'pnl_cal_header.[code]', '\\lhotse\users\export', ';', 'n', 'pnl_calendar', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_calendar', NULL, NULL, NULL, NULL, NULL, NULL, 'set_cal_header.[code]', '\\lhotse\users\export', ';', 'n', 'settlement_calendar', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_date', NULL, NULL, NULL, NULL, NULL, NULL, 'set_date_header.[code]', '\\lhotse\users\export', ';', 'n', 'settlement_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'transportation_contract', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[transportation_contract]', '\\lhotse\users\export', ';', 'n', 'transportation_contract', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pipeline', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[pipeline]', '\\lhotse\users\export', ';', 'n', 'pipeline', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'flow_start_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[flow_start_date]', '\\lhotse\users\export', ';', 'n', 'flow_start_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'flow_end_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[flow_end_date]', '\\lhotse\users\export', ';', 'n', 'flow_end_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_rule', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[settlement_rule]', '\\lhotse\users\export', ';', 'n', 'settlement_rule', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'path', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[path]', '\\lhotse\users\export', ';', 'n', 'path', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'capacity_release', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[capacity_release]', '\\lhotse\users\export', ';', 'n', 'capacity_release', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[deal]', '\\lhotse\users\export', ';', 'n', 'deal', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'interruptible', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[interruptible]', '\\lhotse\users\export', ';', 'n', 'interruptible', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_type', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[contract_type]', '\\lhotse\users\export', ';', 'n', 'contract_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'maintain_rate_schedule', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[maintain_rate_schedule]', '\\lhotse\users\export', ';', 'n', 'maintain_rate_schedule', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'standard_contract', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[standard_contract]', '\\lhotse\users\export', ';', 'n', 'standard_contract', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'invoice_report_template', NULL, NULL, NULL, NULL, NULL, NULL, 'irt.[template_name]', '\\lhotse\users\export', ';', 'n', 'invoice_report_template', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'neting_rule', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[neting_rule]', '\\lhotse\users\export', ';', 'n', 'neting_rule', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_days', NULL, NULL, NULL, NULL, NULL, NULL, 'pay_date_header.[code]', '\\lhotse\users\export', ';', 'n', 'payment_days', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_days', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[settlement_days]', '\\lhotse\users\export', ';', 'n', 'settlement_days', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'self_billing', NULL, NULL, NULL, NULL, NULL, NULL, 'cg.[self_billing]', '\\lhotse\users\export', ';', 'n', 'self_billing', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'netting_template', NULL, NULL, NULL, NULL, NULL, NULL, 'nrt.[template_name]', '\\lhotse\users\export', ';', 'n', 'netting_template', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END