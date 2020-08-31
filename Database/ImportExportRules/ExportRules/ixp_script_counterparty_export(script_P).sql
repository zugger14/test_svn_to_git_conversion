IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Insert Script Counterparty') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Insert Script Counterparty' ,
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
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  1,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  2,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  3,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_limit_available_template'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  4,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_counterparty_epa_account_template'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  5,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  6,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  7,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_counterparty_credit_block_trading_template'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  8,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_counterparty_limit_calc_result_template'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  9,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_counterparty_limits_template'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'counterparty_credit_block_trading',
									    1079,
									    'ccbt',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_limit_calc_result',
									    1080,
									    'clcr',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_limits',
									    1081,
									    'cl',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_bank_info',
									    1082,
									    'cbi',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_credit_enhancements',
									    1083,
									    'cce',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_epa_account',
									    1084,
									    'cea',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_credit_info',
									    1085,
									    'cci',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'limit_available',
									    1086,
									    'la',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_contract_address',
									    1087,
									    'cca',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_counterparty',
									    1088,
									    'sc',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1089,
									    'ssd',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1090,
									    'ssd1',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1091,
									    'ssd2',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1092,
									    'ssd3',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1093,
									    'ssd4',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1094,
									    'sdd5',
									    1088 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1095,
									    'ssd6',
									    1088

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          813,         @ixp_rules_id_new,         1079,         1085,         'counterparty_credit_info_id',         'counterparty_credit_info_id',         1079 UNION ALL          SELECT          814,         @ixp_rules_id_new,         1083,         1085,         'counterparty_credit_info_id',         'counterparty_credit_info_id',         1083 UNION ALL          SELECT          815,         @ixp_rules_id_new,         1080,         1088,         'counterparty_id',         'source_counterparty_id',         1080 UNION ALL          SELECT          816,         @ixp_rules_id_new,         1081,         1088,         'counterparty_id',         'source_counterparty_id',         1081 UNION ALL          SELECT          817,         @ixp_rules_id_new,         1082,         1088,         'counterparty_id',         'source_counterparty_id',         1082 UNION ALL          SELECT          818,         @ixp_rules_id_new,         1084,         1088,         'counterparty_id',         'source_counterparty_id',         1084 UNION ALL          SELECT          819,         @ixp_rules_id_new,         1085,         1088,         'Counterparty_id',         'source_counterparty_id',         1085 UNION ALL          SELECT          820,         @ixp_rules_id_new,         1086,         1088,         'limit_id',         'source_counterparty_id',         1086 UNION ALL          SELECT          821,         @ixp_rules_id_new,         1094,         1088,         'value_id',         'region',         1094 UNION ALL          SELECT          822,         @ixp_rules_id_new,         1087,         1088,         'counterparty_id',         'source_counterparty_id',         1087 UNION ALL          SELECT          823,         @ixp_rules_id_new,         1089,         1088,         'value_id',         'state',         1089 UNION ALL          SELECT          824,         @ixp_rules_id_new,         1090,         1088,         'value_id',         'country',         1090 UNION ALL          SELECT          825,         @ixp_rules_id_new,         1091,         1088,         'value_id',         'delivery_method',         1091 UNION ALL          SELECT          826,         @ixp_rules_id_new,         1092,         1088,         'value_id',         'type_of_entity',         1092 UNION ALL          SELECT          827,         @ixp_rules_id_new,         1093,         1088,         'value_id',         'netting_parent_counterparty_id',         1093

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
								         it.ixp_tables_id, 'limit_type', NULL, NULL, NULL, NULL, NULL, NULL, 'cl.[limit_type]', 'C:\CSV', NULL, 'y', 'limit_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'applies_to', NULL, NULL, NULL, NULL, NULL, NULL, 'cl.[applies_to]', 'C:\CSV', NULL, 'y', 'applies_to', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'C:\CSV', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_rating_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cl.[internal_rating_id]', 'C:\CSV', NULL, 'y', 'internal_rating_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_limit_type', NULL, NULL, NULL, NULL, NULL, NULL, 'cl.[internal_rating_id]', 'C:\CSV', NULL, 'y', 'volume_limit_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'limit_value', NULL, NULL, NULL, NULL, NULL, NULL, 'cl.[limit_type]', 'C:\CSV', NULL, 'y', 'limit_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'uom_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cl.[uom_id]', 'C:\CSV', NULL, 'y', 'uom_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cl.[formula_id]', 'C:\CSV', NULL, 'y', 'formula_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'currency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cl.[currency_id]', 'C:\CSV', NULL, 'y', 'currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bucket_detail_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cl.[bucket_detail_id]', 'C:\CSV', NULL, 'y', 'bucket_detail_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_credit_info_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[counterparty_credit_info_id]', 'c:\csv', NULL, 'y', 'counterparty_credit_info_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_block_trading'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ccbt'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_block_trading_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'comodity_id', NULL, NULL, NULL, NULL, NULL, NULL, 'ccbt.[comodity_id]', 'c:\csv', NULL, 'y', 'comodity_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_block_trading'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ccbt'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_block_trading_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_type_id', NULL, NULL, NULL, NULL, NULL, NULL, 'ccbt.[deal_type_id]', 'c:\csv', NULL, 'y', 'deal_type_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_block_trading'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ccbt'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_block_trading_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract', NULL, NULL, NULL, NULL, NULL, NULL, 'ccbt.[contract]', 'c:\csv', NULL, 'y', 'contract', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_block_trading'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ccbt'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_block_trading_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'active', NULL, NULL, NULL, NULL, NULL, NULL, 'ccbt.[active]', 'c:\csv', NULL, 'y', 'active', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_block_trading'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ccbt'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_block_trading_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'buysell_allow', NULL, NULL, NULL, NULL, NULL, NULL, 'ccbt.[buysell_allow]', 'c:\csv', NULL, 'y', 'buysell_allow', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_block_trading'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ccbt'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_block_trading_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'as_of_date', NULL, NULL, NULL, NULL, NULL, NULL, 'clcr.[as_of_date]', 'c:\csv', NULL, 'y', 'as_of_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limit_calc_result'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'clcr'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limit_calc_result_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_limit_id', NULL, NULL, NULL, NULL, NULL, NULL, 'clcr.[counterparty_limit_id]', 'c:\csv', NULL, 'y', 'counterparty_limit_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limit_calc_result'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'clcr'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limit_calc_result_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\csv', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limit_calc_result'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'clcr'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limit_calc_result_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_rating', NULL, NULL, NULL, NULL, NULL, NULL, 'clcr.[internal_rating]', 'c:\csv', NULL, 'y', 'internal_rating', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limit_calc_result'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'clcr'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limit_calc_result_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'limit_type', NULL, NULL, NULL, NULL, NULL, NULL, 'clcr.[limit_type]', 'c:\csv', NULL, 'y', 'limit_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limit_calc_result'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'clcr'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limit_calc_result_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'buck_id', NULL, NULL, NULL, NULL, NULL, NULL, 'clcr.[buck_id]', 'c:\csv', NULL, 'y', 'buck_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limit_calc_result'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'clcr'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limit_calc_result_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'purchase_sales', NULL, NULL, NULL, NULL, NULL, NULL, 'clcr.[purchase_sales]', 'c:\csv', NULL, 'y', 'purchase_sales', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limit_calc_result'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'clcr'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limit_calc_result_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'credit_available', NULL, NULL, NULL, NULL, NULL, NULL, 'clcr.[credit_available]', 'c:\csv', NULL, 'y', 'credit_available', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limit_calc_result'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'clcr'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limit_calc_result_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\CSV', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bank_name', NULL, NULL, NULL, NULL, NULL, NULL, 'cbi.[bank_name]', 'c:\CSV', NULL, 'y', 'bank_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'wire_ABA', NULL, NULL, NULL, NULL, NULL, NULL, 'cbi.[wire_ABA]', 'c:\CSV', NULL, 'y', 'wire_ABA', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'ACH_ABA', NULL, NULL, NULL, NULL, NULL, NULL, 'cbi.[ACH_ABA]', 'c:\CSV', NULL, 'y', 'ACH_ABA', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Account_no', NULL, NULL, NULL, NULL, NULL, NULL, 'cbi.[Account_no]', 'c:\CSV', NULL, 'y', 'Account_no', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Address1', NULL, NULL, NULL, NULL, NULL, NULL, 'cbi.[Address1]', 'c:\CSV', NULL, 'y', 'Address1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Address2', NULL, NULL, NULL, NULL, NULL, NULL, 'cbi.[Address2]', 'c:\CSV', NULL, 'y', 'Address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'accountname', NULL, NULL, NULL, NULL, NULL, NULL, 'cbi.[accountname]', 'c:\CSV', NULL, 'y', 'accountname', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'reference', NULL, NULL, NULL, NULL, NULL, NULL, 'cbi.[reference]', 'c:\CSV', NULL, 'y', 'reference', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'currency', NULL, NULL, NULL, NULL, NULL, NULL, 'cbi.[currency]', 'c:\CSV', NULL, 'y', 'currency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_credit_info_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[counterparty_credit_info_id]', 'C:\csv', NULL, 'y', 'counterparty_credit_info_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'enhance_type', NULL, NULL, NULL, NULL, NULL, NULL, 'cce.[enhance_type]', 'C:\csv', NULL, 'y', 'enhance_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'guarantee_counterparty', NULL, NULL, NULL, NULL, NULL, NULL, 'cce.[guarantee_counterparty]', 'C:\csv', NULL, 'y', 'guarantee_counterparty', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'comment', NULL, NULL, NULL, NULL, NULL, NULL, 'cce.[comment]', 'C:\csv', NULL, 'y', 'comment', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'amount', NULL, NULL, NULL, NULL, NULL, NULL, 'cce.[amount]', 'C:\csv', NULL, 'y', 'amount', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'currency_code', NULL, NULL, NULL, NULL, NULL, NULL, 'cce.[currency_code]', 'C:\csv', NULL, 'y', 'currency_code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'eff_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cce.[eff_date]', 'C:\csv', NULL, 'y', 'eff_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'margin', NULL, NULL, NULL, NULL, NULL, NULL, 'cce.[margin]', 'C:\csv', NULL, 'y', 'margin', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'rely_self', NULL, NULL, NULL, NULL, NULL, NULL, 'cce.[rely_self]', 'C:\csv', NULL, 'y', 'rely_self', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'approved_by', NULL, NULL, NULL, NULL, NULL, NULL, 'cce.[approved_by]', 'C:\csv', NULL, 'y', 'approved_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'expiration_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cce.[expiration_date]', 'C:\csv', NULL, 'y', 'expiration_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'exclude_collateral', NULL, NULL, NULL, NULL, NULL, NULL, 'cce.[exclude_collateral]', 'C:\csv', NULL, 'y', 'exclude_collateral', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_enhancements'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cce'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\csv', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_epa_account'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cea'
								WHERE it.ixp_tables_name = 'ixp_counterparty_epa_account_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'external_type_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cea.[external_type_id]', 'c:\csv', NULL, 'y', 'external_type_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_epa_account'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cea'
								WHERE it.ixp_tables_name = 'ixp_counterparty_epa_account_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'external_value', NULL, NULL, NULL, NULL, NULL, NULL, 'cea.[external_value]', 'c:\csv', NULL, 'y', 'external_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_epa_account'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cea'
								WHERE it.ixp_tables_name = 'ixp_counterparty_epa_account_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'C:\CSV', NULL, 'y', 'Counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'account_status', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[account_status]', 'C:\CSV', NULL, 'y', 'account_status', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'limit_expiration', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[limit_expiration]', 'C:\CSV', NULL, 'y', 'limit_expiration', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'credit_limit', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[credit_limit]', 'C:\CSV', NULL, 'y', 'credit_limit', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'curreny_code', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[curreny_code]', 'C:\CSV', NULL, 'y', 'curreny_code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Tenor_limit', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Tenor_limit]', 'C:\CSV', NULL, 'y', 'Tenor_limit', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Industry_type1', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Industry_type1]', 'C:\CSV', NULL, 'y', 'Industry_type1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Industry_type2', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Industry_type2]', 'C:\CSV', NULL, 'y', 'Industry_type2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'SIC_Code', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[SIC_Code]', 'C:\CSV', NULL, 'y', 'SIC_Code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Duns_No', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Duns_No]', 'C:\CSV', NULL, 'y', 'Duns_No', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Risk_rating', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Risk_rating]', 'C:\CSV', NULL, 'y', 'Risk_rating', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Debt_rating', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Debt_rating]', 'C:\CSV', NULL, 'y', 'Debt_rating', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Ticker_symbol', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Ticker_symbol]', 'C:\CSV', NULL, 'y', 'Ticker_symbol', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Date_established', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Date_established]', 'C:\CSV', NULL, 'y', 'Date_established', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Next_review_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Next_review_date]', 'C:\CSV', NULL, 'y', 'Next_review_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Last_review_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Last_review_date]', 'C:\CSV', NULL, 'y', 'Last_review_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Customer_since', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Customer_since]', 'C:\CSV', NULL, 'y', 'Customer_since', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Approved_by', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Approved_by]', 'C:\CSV', NULL, 'y', 'Approved_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Watch_list', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Watch_list]', 'C:\CSV', NULL, 'y', 'Watch_list', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Settlement_contact_name', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Settlement_contact_name]', 'C:\CSV', NULL, 'y', 'Settlement_contact_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Settlement_contact_address', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Settlement_contact_address]', 'C:\CSV', NULL, 'y', 'Settlement_contact_address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Settlement_contact_address2', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Settlement_contact_address2]', 'C:\CSV', NULL, 'y', 'Settlement_contact_address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Settlement_contact_phone', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Settlement_contact_phone]', 'C:\CSV', NULL, 'y', 'Settlement_contact_phone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Settlement_contact_email', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Settlement_contact_email]', 'C:\CSV', NULL, 'y', 'Settlement_contact_email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_contact_name', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[payment_contact_name]', 'C:\CSV', NULL, 'y', 'payment_contact_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_contact_address', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[payment_contact_address]', 'C:\CSV', NULL, 'y', 'payment_contact_address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contactfax', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[contactfax]', 'C:\CSV', NULL, 'y', 'contactfax', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_contact_phone', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[payment_contact_phone]', 'C:\CSV', NULL, 'y', 'payment_contact_phone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_contact_email', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[payment_contact_address]', 'C:\CSV', NULL, 'y', 'payment_contact_email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Debt_Rating2', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Debt_Rating2]', 'C:\CSV', NULL, 'y', 'Debt_Rating2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Debt_Rating3', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Debt_Rating3]', 'C:\CSV', NULL, 'y', 'Debt_Rating3', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Debt_Rating4', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Debt_Rating4]', 'C:\CSV', NULL, 'y', 'Debt_Rating4', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Debt_Rating5', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[Debt_Rating5]', 'C:\CSV', NULL, 'y', 'Debt_Rating5', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'credit_limit_from', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[credit_limit_from]', 'C:\CSV', NULL, 'y', 'credit_limit_from', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_contact_address2', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[payment_contact_address]', 'C:\CSV', NULL, 'y', 'payment_contact_address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'max_threshold', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[max_threshold]', 'C:\CSV', NULL, 'y', 'max_threshold', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'min_threshold', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[min_threshold]', 'C:\CSV', NULL, 'y', 'min_threshold', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'check_apply', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[check_apply]', 'C:\CSV', NULL, 'y', 'check_apply', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'cva_data', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[cva_data]', 'C:\CSV', NULL, 'y', 'cva_data', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pfe_criteria', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[pfe_criteria]', 'C:\CSV', NULL, 'y', 'pfe_criteria', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'exclude_exposure_after', NULL, NULL, NULL, NULL, NULL, NULL, 'cci.[exclude_exposure_after]', 'C:\CSV', NULL, 'y', 'exclude_exposure_after', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'limit_id', NULL, NULL, NULL, NULL, NULL, NULL, 'la.[limit_id]', 'c:\csv', NULL, 'y', 'limit_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'limit_available'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'la'
								WHERE it.ixp_tables_name = 'ixp_limit_available_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\csv', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'limit_available'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'la'
								WHERE it.ixp_tables_name = 'ixp_limit_available_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'effective_date', NULL, NULL, NULL, NULL, NULL, NULL, 'la.[effective_date]', 'c:\csv', NULL, 'y', 'effective_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'limit_available'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'la'
								WHERE it.ixp_tables_name = 'ixp_limit_available_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'limit_type', NULL, NULL, NULL, NULL, NULL, NULL, 'la.[limit_type]', 'c:\csv', NULL, 'y', 'limit_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'limit_available'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'la'
								WHERE it.ixp_tables_name = 'ixp_limit_available_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'limit_available', NULL, NULL, NULL, NULL, NULL, NULL, 'la.[limit_available]', 'c:\csv', NULL, 'y', 'limit_available', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'limit_available'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'la'
								WHERE it.ixp_tables_name = 'ixp_limit_available_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'currency', NULL, NULL, NULL, NULL, NULL, NULL, 'la.[currency]', 'c:\csv', NULL, 'y', 'currency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'limit_available'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'la'
								WHERE it.ixp_tables_name = 'ixp_limit_available_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'comment', NULL, NULL, NULL, NULL, NULL, NULL, 'la.[currency]', 'c:\csv', NULL, 'y', 'comment', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'limit_available'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'la'
								WHERE it.ixp_tables_name = 'ixp_limit_available_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_contract_address_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[counterparty_contract_address_id]', 'c:\csv', NULL, 'y', 'counterparty_contract_address_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address1', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[address1]', 'c:\csv', NULL, 'y', 'address1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address2', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[address2]', 'c:\csv', NULL, 'y', 'address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address3', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[address3]', 'c:\csv', NULL, 'y', 'address3', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address4', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[address4]', 'c:\csv', NULL, 'y', 'address4', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[contract_id]', 'c:\csv', NULL, 'y', 'contract_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'email', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[email]', 'c:\csv', NULL, 'y', 'email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fax', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[fax]', 'c:\csv', NULL, 'y', 'fax', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\csv', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_full_name', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[counterparty_full_name]', 'c:\csv', NULL, 'y', 'counterparty_full_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_start_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[contract_start_date]', 'c:\csv', NULL, 'y', 'contract_start_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_end_date', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[contract_end_date]', 'c:\csv', NULL, 'y', 'contract_end_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'apply_netting_rule', NULL, NULL, NULL, NULL, NULL, NULL, 'cca.[apply_netting_rule]', 'c:\csv', NULL, 'y', 'apply_netting_rule', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_system_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[source_system_id]', 'c:\csv', NULL, 'y', 'source_system_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[counterparty_id]', 'c:\csv', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_name', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[counterparty_name]', 'c:\csv', NULL, 'y', 'counterparty_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_desc', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[counterparty_desc]', 'c:\csv', NULL, 'y', 'counterparty_desc', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'int_ext_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[int_ext_flag]', 'c:\csv', NULL, 'y', 'int_ext_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'netting_parent_counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'ssd4.[value_id]', 'c:\csv', NULL, 'y', 'netting_parent_counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[address]', 'c:\csv', NULL, 'y', 'address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'phone_no', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[phone_no]', 'c:\csv', NULL, 'y', 'phone_no', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'mailing_address', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[mailing_address]', 'c:\csv', NULL, 'y', 'mailing_address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fax', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[fax]', 'c:\csv', NULL, 'y', 'fax', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'type_of_entity', NULL, NULL, NULL, NULL, NULL, NULL, 'ssd3.[value_id]', 'c:\csv', NULL, 'y', 'type_of_entity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_name', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[contact_name]', 'c:\csv', NULL, 'y', 'contact_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_title', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[contact_title]', 'c:\csv', NULL, 'y', 'contact_title', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_address', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[contact_address]', 'c:\csv', NULL, 'y', 'contact_address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_address2', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[contact_address2]', 'c:\csv', NULL, 'y', 'contact_address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_phone', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[contact_phone]', 'c:\csv', NULL, 'y', 'contact_phone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_fax', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[contact_fax]', 'c:\csv', NULL, 'y', 'contact_fax', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'instruction', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[instruction]', 'c:\csv', NULL, 'y', 'instruction', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'confirm_from_text', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[confirm_from_text]', 'c:\csv', NULL, 'y', 'confirm_from_text', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'confirm_to_text', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[confirm_to_text]', 'c:\csv', NULL, 'y', 'confirm_to_text', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'confirm_instruction', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[confirm_instruction]', 'c:\csv', NULL, 'y', 'confirm_instruction', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_contact_title', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[counterparty_contact_title]', 'c:\csv', NULL, 'y', 'counterparty_contact_title', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_contact_name', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[counterparty_contact_name]', 'c:\csv', NULL, 'y', 'counterparty_contact_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'create_user', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[create_user]', 'c:\csv', NULL, 'y', 'create_user', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'create_ts', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[create_ts]', 'c:\csv', NULL, 'y', 'create_ts', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'update_user', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[update_user]', 'c:\csv', NULL, 'y', 'update_user', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'update_ts', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[update_ts]', 'c:\csv', NULL, 'y', 'update_ts', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'parent_counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[parent_counterparty_id]', 'c:\csv', NULL, 'y', 'parent_counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'customer_duns_number', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[customer_duns_number]', 'c:\csv', NULL, 'y', 'customer_duns_number', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_jurisdiction', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[is_jurisdiction]', 'c:\csv', NULL, 'y', 'is_jurisdiction', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_contact_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[counterparty_contact_id]', 'c:\csv', NULL, 'y', 'counterparty_contact_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'email', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[email]', 'c:\csv', NULL, 'y', 'email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_email', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[contact_email]', 'c:\csv', NULL, 'y', 'contact_email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'city', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[city]', 'c:\csv', NULL, 'y', 'city', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'state', NULL, NULL, NULL, NULL, NULL, NULL, 'ssd.[value_id]', 'c:\csv', NULL, 'y', 'state', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'zip', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[zip]', 'c:\csv', NULL, 'y', 'zip', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_active', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[is_active]', 'c:\csv', NULL, 'y', 'is_active', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'tax_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[tax_id]', 'c:\csv', NULL, 'y', 'tax_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'delivery_method', NULL, NULL, NULL, NULL, NULL, NULL, 'ssd2.[value_id]', 'c:\csv', NULL, 'y', 'delivery_method', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'country', NULL, NULL, NULL, NULL, NULL, NULL, 'ssd1.[value_id]', 'c:\csv', NULL, 'y', 'country', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'region', NULL, NULL, NULL, NULL, NULL, NULL, 'sdd5.[value_id]', 'c:\csv', NULL, 'y', 'region', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'cc_email', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[cc_email]', 'c:\csv', NULL, 'y', 'cc_email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bcc_email', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[bcc_email]', 'c:\csv', NULL, 'y', 'bcc_email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'cc_remittance', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[cc_remittance]', 'c:\csv', NULL, 'y', 'cc_remittance', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bcc_remittance', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[bcc_remittance]', 'c:\csv', NULL, 'y', 'bcc_remittance', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'email_remittance_to', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[email_remittance_to]', 'c:\csv', NULL, 'y', 'email_remittance_to', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END