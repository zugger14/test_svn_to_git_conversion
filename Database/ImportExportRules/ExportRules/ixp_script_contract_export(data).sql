IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Contract Export (Data)') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Contract Export (Data)' ,
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
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'contract_group',
									    276,
									    'CG',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_currency',
									    277,
									    'currency_id',
									    370 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_uom',
									    278,
									    'volume_UOM',
									    370 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    279,
									    'billing',
									    370 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    280,
									    'granularity',
									    370 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    281,
									    'Invoiceduedate',
									    370 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    282,
									    'contractstatus',
									    370 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    283,
									    'settlementdate',
									    370

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          214,         @ixp_rules_id_new,         277,         276,         'source_currency_id',         'currency',         277 UNION ALL          SELECT          215,         @ixp_rules_id_new,         278,         276,         'source_uom_id',         'volume_uom',         278 UNION ALL          SELECT          216,         @ixp_rules_id_new,         279,         276,         'value_id',         'billing_cycle',         279 UNION ALL          SELECT          217,         @ixp_rules_id_new,         280,         276,         'value_id',         'volume_granularity',         280 UNION ALL          SELECT          218,         @ixp_rules_id_new,         281,         276,         'value_id',         'invoice_due_date',         281 UNION ALL          SELECT          219,         @ixp_rules_id_new,         282,         276,         'value_id',         'contract_status',         282 UNION ALL          SELECT          220,         @ixp_rules_id_new,         283,         276,         'value_id',         'settlement_date',         283

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
								         it.ixp_tables_id, 'contract_id', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[contract_id]', '\\lhotse\users\export\', ',', 'n', 'contract_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'sub_id', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[sub_id]', '\\lhotse\users\export\', ',', 'n', 'sub_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_name', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[contract_name]', '\\lhotse\users\export\', ',', 'n', 'contract_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_date', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[contract_date]', '\\lhotse\users\export\', ',', 'n', 'contract_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'receive_invoice', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[receive_invoice]', '\\lhotse\users\export\', ',', 'n', 'receive_invoice', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_accountant', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[settlement_accountant]', '\\lhotse\users\export\', ',', 'n', 'settlement_accountant', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_cycle', NULL, NULL, NULL, NULL, NULL, NULL, 'billing.[code]', '\\lhotse\users\export\', ',', 'n', 'billing_cycle', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'invoice_due_date', NULL, NULL, NULL, NULL, NULL, NULL, 'Invoiceduedate.[code]', '\\lhotse\users\export\', ',', 'n', 'invoice_due_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_granularity', NULL, NULL, NULL, NULL, NULL, NULL, 'granularity.[code]', '\\lhotse\users\export\', ',', 'n', 'volume_granularity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'hourly_block', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[hourly_block]', '\\lhotse\users\export\', ',', 'n', 'hourly_block', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'currency', NULL, NULL, NULL, NULL, NULL, NULL, 'currency_id.[currency_id]', '\\lhotse\users\export\', ',', 'n', 'currency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_mult', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[volume_mult]', '\\lhotse\users\export\', ',', 'n', 'volume_mult', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'onpeak_mult', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[onpeak_mult]', '\\lhotse\users\export\', ',', 'n', 'onpeak_mult', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'offpeak_mult', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[offpeak_mult]', '\\lhotse\users\export\', ',', 'n', 'offpeak_mult', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'type', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[type]', '\\lhotse\users\export\', ',', 'n', 'type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'reverse_entries', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[reverse_entries]', '\\lhotse\users\export\', ',', 'n', 'reverse_entries', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_uom', NULL, NULL, NULL, NULL, NULL, NULL, 'volume_UOM.[uom_id]', '\\lhotse\users\export\', ',', 'n', 'volume_uom', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'rec_uom', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[rec_uom]', '\\lhotse\users\export\', ',', 'n', 'rec_uom', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_specialist', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[contract_specialist]', '\\lhotse\users\export\', ',', 'n', 'contract_specialist', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_start', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[term_start]', '\\lhotse\users\export\', ',', 'n', 'term_start', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_end', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[term_end]', '\\lhotse\users\export\', ',', 'n', 'term_end', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'name', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[name]', '\\lhotse\users\export\', ',', 'n', 'name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'company', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[company]', '\\lhotse\users\export\', ',', 'n', 'company', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'state', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[state]', '\\lhotse\users\export\', ',', 'n', 'state', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'city', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[city]', '\\lhotse\users\export\', ',', 'n', 'city', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'zip', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[zip]', '\\lhotse\users\export\', ',', 'n', 'zip', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[address]', '\\lhotse\users\export\', ',', 'n', 'address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address2', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[address2]', '\\lhotse\users\export\', ',', 'n', 'address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'telephone', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[telephone]', '\\lhotse\users\export\', ',', 'n', 'telephone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'email', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[email]', '\\lhotse\users\export\', ',', 'n', 'email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fax', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[fax]', '\\lhotse\users\export\', ',', 'n', 'fax', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'name2', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[name2]', '\\lhotse\users\export\', ',', 'n', 'name2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'company2', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[company2]', '\\lhotse\users\export\', ',', 'n', 'company2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'telephone2', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[company2]', '\\lhotse\users\export\', ',', 'n', 'telephone2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fax2', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[fax2]', '\\lhotse\users\export\', ',', 'n', 'fax2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'email2', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[email2]', '\\lhotse\users\export\', ',', 'n', 'email2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_contract_id', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[source_contract_id]', '\\lhotse\users\export\', ',', 'n', 'source_contract_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_system_id', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[source_system_id]', '\\lhotse\users\export\', ',', 'n', 'source_system_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_desc', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[contract_desc]', '\\lhotse\users\export\', ',', 'n', 'contract_desc', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'create_user', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[create_user]', '\\lhotse\users\export\', ',', 'n', 'create_user', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'create_ts', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[create_ts]', '\\lhotse\users\export\', ',', 'n', 'create_ts', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'update_user', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[update_user]', '\\lhotse\users\export\', ',', 'n', 'update_user', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'update_ts', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[update_ts]', '\\lhotse\users\export\', ',', 'n', 'update_ts', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'energy_type', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[energy_type]', '\\lhotse\users\export\', ',', 'n', 'energy_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'area_engineer', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[area_engineer]', '\\lhotse\users\export\', ',', 'n', 'area_engineer', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'metering_contract', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[metering_contract]', '\\lhotse\users\export\', ',', 'n', 'metering_contract', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'miso_queue_number', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[miso_queue_number]', '\\lhotse\users\export\', ',', 'n', 'miso_queue_number', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'substation_name', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[substation_name]', '\\lhotse\users\export\', ',', 'n', 'substation_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'project_county', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[project_county]', '\\lhotse\users\export\', ',', 'n', 'project_county', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'voltage', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[voltage]', '\\lhotse\users\export\', ',', 'n', 'voltage', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'time_zone', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[time_zone]', '\\lhotse\users\export\', ',', 'n', 'time_zone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_service_agreement_id', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[contract_service_agreement_id]', '\\lhotse\users\export\', ',', 'n', 'contract_service_agreement_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_charge_type_id', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[contract_charge_type_id]', '\\lhotse\users\export\', ',', 'n', 'contract_charge_type_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_from_date', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[billing_from_date]', '\\lhotse\users\export\', ',', 'n', 'billing_from_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_to_date', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[billing_to_date]', '\\lhotse\users\export\', ',', 'n', 'billing_to_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_report_template', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[contract_report_template]', '\\lhotse\users\export\', ',', 'n', 'contract_report_template', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Subledger_code', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[Subledger_code]', '\\lhotse\users\export\', ',', 'n', 'Subledger_code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'UD_Contract_id', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[UD_Contract_id]', '\\lhotse\users\export\', ',', 'n', 'UD_Contract_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'extension_provision_description', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[extension_provision_description]', '\\lhotse\users\export\', ',', 'n', 'extension_provision_description', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'term_name', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[term_name]', '\\lhotse\users\export\', ',', 'n', 'term_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'increment_name', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[increment_name]', '\\lhotse\users\export\', ',', 'n', 'increment_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'ferct_tarrif_reference', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[ferct_tarrif_reference]', '\\lhotse\users\export\', ',', 'n', 'ferct_tarrif_reference', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'point_of_delivery_control_area', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[point_of_delivery_control_area]', '\\lhotse\users\export\', ',', 'n', 'point_of_delivery_control_area', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'point_of_delivery_specific_location', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[point_of_delivery_specific_location]', '\\lhotse\users\export\', ',', 'n', 'point_of_delivery_specific_location', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_affiliate', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[contract_affiliate]', '\\lhotse\users\export\', ',', 'n', 'contract_affiliate', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'point_of_receipt_control_area', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[point_of_receipt_control_area]', '\\lhotse\users\export\', ',', 'n', 'point_of_receipt_control_area', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'point_of_receipt_specific_location', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[point_of_receipt_specific_location]', '\\lhotse\users\export\', ',', 'n', 'point_of_receipt_specific_location', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'no_meterdata', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[no_meterdata]', '\\lhotse\users\export\', ',', 'n', 'no_meterdata', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_start_month', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[billing_start_month]', '\\lhotse\users\export\', ',', 'n', 'billing_start_month', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'increment_period', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[increment_period]', '\\lhotse\users\export\', ',', 'n', 'increment_period', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bookout_provision', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[bookout_provision]', '\\lhotse\users\export\', ',', 'n', 'bookout_provision', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_status', NULL, NULL, NULL, NULL, NULL, NULL, 'contractstatus.[code]', '\\lhotse\users\export\', ',', 'n', 'contract_status', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'holiday_calendar_id', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[holiday_calendar_id]', '\\lhotse\users\export\', ',', 'n', 'holiday_calendar_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_from_hour', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[billing_from_hour]', '\\lhotse\users\export\', ',', 'n', 'billing_from_hour', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'billing_to_hour', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[billing_to_hour]', '\\lhotse\users\export\', ',', 'n', 'billing_to_hour', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'block_type', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[block_type]', '\\lhotse\users\export\', ',', 'n', 'block_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_active', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[is_active]', '\\lhotse\users\export\', ',', 'n', 'is_active', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_calendar', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[payment_calendar]', '\\lhotse\users\export\', ',', 'n', 'payment_calendar', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pnl_date', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[pnl_date]', '\\lhotse\users\export\', ',', 'n', 'pnl_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pnl_calendar', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[pnl_calendar]', '\\lhotse\users\export\', ',', 'n', 'pnl_calendar', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_calendar', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[settlement_calendar]', '\\lhotse\users\export\', ',', 'n', 'settlement_calendar', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_date', NULL, NULL, NULL, NULL, NULL, NULL, 'settlementdate.[code]', '\\lhotse\users\export\', ',', 'n', 'settlement_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'transportation_contract', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[transportation_contract]', '\\lhotse\users\export\', ',', 'n', 'transportation_contract', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pipeline', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[pipeline]', '\\lhotse\users\export\', ',', 'n', 'pipeline', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'flow_start_date', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[flow_start_date]', '\\lhotse\users\export\', ',', 'n', 'flow_start_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'flow_end_date', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[flow_end_date]', '\\lhotse\users\export\', ',', 'n', 'flow_end_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_rule', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[settlement_rule]', '\\lhotse\users\export\', ',', 'n', 'settlement_rule', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'path', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[path]', '\\lhotse\users\export\', ',', 'n', 'path', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'capacity_release', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[capacity_release]', '\\lhotse\users\export\', ',', 'n', 'capacity_release', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[deal]', '\\lhotse\users\export\', ',', 'n', 'deal', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'interruptible', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[interruptible]', '\\lhotse\users\export\', ',', 'n', 'interruptible', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_type', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[contract_type]', '\\lhotse\users\export\', ',', 'n', 'contract_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'maintain_rate_schedule', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[maintain_rate_schedule]', '\\lhotse\users\export\', ',', 'n', 'maintain_rate_schedule', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'standard_contract', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[standard_contract]', '\\lhotse\users\export\', ',', 'n', 'standard_contract', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'invoice_report_template', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[invoice_report_template]', '\\lhotse\users\export\', ',', 'n', 'invoice_report_template', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'neting_rule', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[neting_rule]', '\\lhotse\users\export\', ',', 'n', 'neting_rule', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_days', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[payment_days]', '\\lhotse\users\export\', ',', 'n', 'payment_days', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'settlement_days', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[settlement_days]', '\\lhotse\users\export\', ',', 'n', 'settlement_days', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'self_billing', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[self_billing]', '\\lhotse\users\export\', ',', 'n', 'self_billing', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'netting_template', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[netting_template]', '\\lhotse\users\export\', ',', 'n', 'netting_template', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = NULL
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = NULL
								WHERE it.ixp_tables_name = 'ixp_contract_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'holiday_calender_id', NULL, NULL, NULL, NULL, NULL, NULL, 'CG.[holiday_calender_id]', '\\lhotse\users\export\', ',', 'n', 'holiday_calender_id', 
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