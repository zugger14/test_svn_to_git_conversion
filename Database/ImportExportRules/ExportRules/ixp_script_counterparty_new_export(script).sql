IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Counterparty_export script') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Counterparty_export script' ,
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
									  1,
									  NULL,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  2,
									  NULL,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  3,
									  NULL,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
								WHERE it.ixp_tables_name = 'ixp_counterparty_epa_account_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  4,
									  NULL,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  5,
									  NULL,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  6,
									  NULL,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
								WHERE it.ixp_tables_name = 'ixp_counterparty_confirm_info_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  7,
									  NULL,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = NULL
								WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'counterparty_confirm_info',
									    1848,
									    'ccoi',
									    1850 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_invoice_info',
									    1849,
									    'cii',
									    1850 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_counterparty',
									    1850,
									    'sc',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_bank_info',
									    1851,
									    'cbi',
									    1850 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_contract_address',
									    1852,
									    'cca',
									    1850 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_epa_account',
									    1853,
									    'cea',
									    1850 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_credit_info',
									    1854,
									    'cci',
									    1850 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'counterparty_limits',
									    1855,
									    'cl',
									    1850

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          1550,         @ixp_rules_id_new,         1848,         1850,         'counterparty_id',         'source_counterparty_id',         1848 UNION ALL          SELECT          1551,         @ixp_rules_id_new,         1849,         1850,         'source_counterparty_id',         'source_counterparty_id',         1849 UNION ALL          SELECT          1552,         @ixp_rules_id_new,         1851,         1850,         'counterparty_id',         'source_counterparty_id',         1851 UNION ALL          SELECT          1553,         @ixp_rules_id_new,         1852,         1850,         'counterparty_id',         'source_counterparty_id',         1852 UNION ALL          SELECT          1554,         @ixp_rules_id_new,         1853,         1850,         'counterparty_id',         'source_counterparty_id',         1853 UNION ALL          SELECT          1555,         @ixp_rules_id_new,         1854,         1850,         'Counterparty_id',         'source_counterparty_id',         1854 UNION ALL          SELECT          1556,         @ixp_rules_id_new,         1855,         1850,         'counterparty_limit_id',         'source_counterparty_id',         1855

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
								         it.ixp_tables_id, 'source_counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\csv', NULL, 'y', 'source_counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
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
								         it.ixp_tables_id, 'netting_parent_counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[netting_parent_counterparty_id]', 'c:\csv', NULL, 'y', 'netting_parent_counterparty_id', 
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
								         it.ixp_tables_id, 'type_of_entity', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[type_of_entity]', 'c:\csv', NULL, 'y', 'type_of_entity', 
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
								         it.ixp_tables_id, 'state', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[state]', 'c:\csv', NULL, 'y', 'state', 
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
								         it.ixp_tables_id, 'delivery_method', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[delivery_method]', 'c:\csv', NULL, 'y', 'delivery_method', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'country', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[country]', 'c:\csv', NULL, 'y', 'country', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'sc'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'region', NULL, NULL, NULL, NULL, NULL, NULL, 'sc.[region]', 'c:\csv', NULL, 'y', 'region', 
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
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Counterparty_id', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'C:\CSV', NULL, 'y', 'Counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'account_status', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[account_status]', 'C:\CSV', NULL, 'y', 'account_status', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'limit_expiration', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[limit_expiration]', 'C:\CSV', NULL, 'y', 'limit_expiration', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'credit_limit', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[credit_limit]', 'C:\CSV', NULL, 'y', 'credit_limit', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'curreny_code', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[curreny_code]', 'C:\CSV', NULL, 'y', 'curreny_code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Tenor_limit', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Tenor_limit]', 'C:\CSV', NULL, 'y', 'Tenor_limit', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Industry_type1', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Industry_type1]', 'C:\CSV', NULL, 'y', 'Industry_type1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Industry_type2', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Industry_type2]', 'C:\CSV', NULL, 'y', 'Industry_type2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'SIC_Code', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[SIC_Code]', 'C:\CSV', NULL, 'y', 'SIC_Code', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Duns_No', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Duns_No]', 'C:\CSV', NULL, 'y', 'Duns_No', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Risk_rating', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Risk_rating]', 'C:\CSV', NULL, 'y', 'Risk_rating', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Debt_rating', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Debt_rating]', 'C:\CSV', NULL, 'y', 'Debt_rating', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Ticker_symbol', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Ticker_symbol]', 'C:\CSV', NULL, 'y', 'Ticker_symbol', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Date_established', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Date_established]', 'C:\CSV', NULL, 'y', 'Date_established', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Next_review_date', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Next_review_date]', 'C:\CSV', NULL, 'y', 'Next_review_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Last_review_date', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Last_review_date]', 'C:\CSV', NULL, 'y', 'Last_review_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Customer_since', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Customer_since]', 'C:\CSV', NULL, 'y', 'Customer_since', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Approved_by', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Approved_by]', 'C:\CSV', NULL, 'y', 'Approved_by', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Watch_list', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Watch_list]', 'C:\CSV', NULL, 'y', 'Watch_list', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address1', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[address1]', 'c:\csv', NULL, 'y', 'address1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address2', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[address2]', 'c:\csv', NULL, 'y', 'address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address3', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[address3]', 'c:\csv', NULL, 'y', 'address3', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address4', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[address4]', 'c:\csv', NULL, 'y', 'address4', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_id', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[contract_id]', 'c:\csv', NULL, 'y', 'contract_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'email', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[email]', 'c:\csv', NULL, 'y', 'email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fax', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[fax]', 'c:\csv', NULL, 'y', 'fax', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'telephone', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[telephone]', 'c:\csv', NULL, 'y', 'telephone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\csv', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_full_name', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[counterparty_full_name]', 'c:\csv', NULL, 'y', 'counterparty_full_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_start_date', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[contract_start_date]', 'c:\csv', NULL, 'y', 'contract_start_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contract_end_date', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[contract_end_date]', 'c:\csv', NULL, 'y', 'contract_end_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'apply_netting_rule', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[apply_netting_rule]', 'c:\csv', NULL, 'y', 'apply_netting_rule', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'cc_mail', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[cc_mail]', 'c:\csv', NULL, 'y', 'cc_mail', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bcc_mail', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[bcc_mail]', 'c:\csv', NULL, 'y', 'bcc_mail', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'remittance_to', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[remittance_to]', 'c:\csv', NULL, 'y', 'remittance_to', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'cc_remittance', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[remittance_to]', 'c:\csv', NULL, 'y', 'cc_remittance', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bcc_remittance', NULL, NULL, 'cca.counterparty_id is not null', NULL, NULL, NULL, 'cca.[bcc_remittance]', 'c:\csv', NULL, 'y', 'bcc_remittance', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_contract_address'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cca'
								WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, 'cea.counterparty_id is not null', NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\csv', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_epa_account'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cea'
								WHERE it.ixp_tables_name = 'ixp_counterparty_epa_account_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'external_type_id', NULL, NULL, 'cea.counterparty_id is not null', NULL, NULL, NULL, 'cea.[external_type_id]', 'c:\csv', NULL, 'y', 'external_type_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_epa_account'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cea'
								WHERE it.ixp_tables_name = 'ixp_counterparty_epa_account_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'external_value', NULL, NULL, 'cea.counterparty_id is not null', NULL, NULL, NULL, 'cea.[external_value]', 'c:\csv', NULL, 'y', 'external_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_epa_account'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cea'
								WHERE it.ixp_tables_name = 'ixp_counterparty_epa_account_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Settlement_contact_name', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Settlement_contact_name]', 'C:\CSV', NULL, 'y', 'Settlement_contact_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Settlement_contact_address', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Settlement_contact_address]', 'C:\CSV', NULL, 'y', 'Settlement_contact_address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Settlement_contact_address2', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Settlement_contact_address2]', 'C:\CSV', NULL, 'y', 'Settlement_contact_address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Settlement_contact_phone', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Settlement_contact_phone]', 'C:\CSV', NULL, 'y', 'Settlement_contact_phone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Settlement_contact_email', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[payment_contact_name]', 'C:\CSV', NULL, 'y', 'Settlement_contact_email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_contact_name', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[payment_contact_name]', 'C:\CSV', NULL, 'y', 'payment_contact_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_contact_address', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[payment_contact_address]', 'C:\CSV', NULL, 'y', 'payment_contact_address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contactfax', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[contactfax]', 'C:\CSV', NULL, 'y', 'contactfax', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_contact_phone', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[payment_contact_phone]', 'C:\CSV', NULL, 'y', 'payment_contact_phone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_contact_email', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[payment_contact_email]', 'C:\CSV', NULL, 'y', 'payment_contact_email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Debt_Rating2', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Debt_Rating2]', 'C:\CSV', NULL, 'y', 'Debt_Rating2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Debt_Rating3', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Debt_Rating3]', 'C:\CSV', NULL, 'y', 'Debt_Rating3', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Debt_Rating4', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Debt_Rating4]', 'C:\CSV', NULL, 'y', 'Debt_Rating4', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Debt_Rating5', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[Debt_Rating5]', 'C:\CSV', NULL, 'y', 'Debt_Rating5', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'credit_limit_from', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[credit_limit_from]', 'C:\CSV', NULL, 'y', 'credit_limit_from', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'payment_contact_address2', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[payment_contact_address2]', 'C:\CSV', NULL, 'y', 'payment_contact_address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'max_threshold', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[max_threshold]', 'C:\CSV', NULL, 'y', 'max_threshold', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'min_threshold', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[min_threshold]', 'C:\CSV', NULL, 'y', 'min_threshold', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'check_apply', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[check_apply]', 'C:\CSV', NULL, 'y', 'check_apply', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'cva_data', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[cva_data]', 'C:\CSV', NULL, 'y', 'cva_data', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pfe_criteria', NULL, NULL, 'cci.Counterparty_id IS NOT NULL', NULL, NULL, NULL, 'cci.[pfe_criteria]', 'C:\CSV', NULL, 'y', 'pfe_criteria', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_credit_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cci'
								WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'source_counterparty_id', NULL, NULL, 'cii.source_counterparty_id is not null', NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\csv', NULL, 'y', 'source_counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_invoice_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cii'
								WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'pre_text', NULL, NULL, 'cii.source_counterparty_id is not null', NULL, NULL, NULL, 'cii.[pre_text]', 'c:\csv', NULL, 'y', 'pre_text', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_invoice_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cii'
								WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'post_text', NULL, NULL, 'cii.source_counterparty_id is not null', NULL, NULL, NULL, 'cii.[post_text]', 'c:\csv', NULL, 'y', 'post_text', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_invoice_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cii'
								WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bill_to', NULL, NULL, 'cii.source_counterparty_id is not null', NULL, NULL, NULL, 'cii.[bill_to]', 'c:\csv', NULL, 'y', 'bill_to', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_invoice_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cii'
								WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bill_from', NULL, NULL, 'cii.source_counterparty_id is not null', NULL, NULL, NULL, 'cii.[bill_from]', 'c:\csv', NULL, 'y', 'bill_from', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_invoice_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cii'
								WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'instruction1', NULL, NULL, 'cii.source_counterparty_id is not null', NULL, NULL, NULL, 'cii.[instruction1]', 'c:\csv', NULL, 'y', 'instruction1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_invoice_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cii'
								WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'instruction2', NULL, NULL, 'cii.source_counterparty_id is not null', NULL, NULL, NULL, 'cii.[instruction2]', 'c:\csv', NULL, 'y', 'instruction2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_invoice_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cii'
								WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'instruction3', NULL, NULL, 'cii.source_counterparty_id is not null', NULL, NULL, NULL, 'cii.[instruction3]', 'c:\csv', NULL, 'y', 'instruction3', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_invoice_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cii'
								WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'instruction4', NULL, NULL, 'cii.source_counterparty_id is not null', NULL, NULL, NULL, 'cii.[instruction4]', 'c:\csv', NULL, 'y', 'instruction4', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_invoice_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cii'
								WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'instruction5', NULL, NULL, 'cii.source_counterparty_id is not null', NULL, NULL, NULL, 'cii.[instruction5]', 'c:\csv', NULL, 'y', 'instruction5', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_invoice_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cii'
								WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, 'cbi.counterparty_id is not null', NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\CSV', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bank_name', NULL, NULL, 'cbi.counterparty_id is not null', NULL, NULL, NULL, 'cbi.[bank_name]', 'c:\CSV', NULL, 'y', 'bank_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'wire_ABA', NULL, NULL, 'cbi.counterparty_id is not null', NULL, NULL, NULL, 'cbi.[wire_ABA]', 'c:\CSV', NULL, 'y', 'wire_ABA', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'ACH_ABA', NULL, NULL, 'cbi.counterparty_id is not null', NULL, NULL, NULL, 'cbi.[ACH_ABA]', 'c:\CSV', NULL, 'y', 'ACH_ABA', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Account_no', NULL, NULL, 'cbi.counterparty_id is not null', NULL, NULL, NULL, 'cbi.[Account_no]', 'c:\CSV', NULL, 'y', 'Account_no', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Address1', NULL, NULL, 'cbi.counterparty_id is not null', NULL, NULL, NULL, 'cbi.[Address1]', 'c:\CSV', NULL, 'y', 'Address1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'Address2', NULL, NULL, 'cbi.counterparty_id is not null', NULL, NULL, NULL, 'cbi.[Address2]', 'c:\CSV', NULL, 'y', 'Address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'accountname', NULL, NULL, 'cbi.counterparty_id is not null', NULL, NULL, NULL, 'cbi.[accountname]', 'c:\CSV', NULL, 'y', 'accountname', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'reference', NULL, NULL, 'cbi.counterparty_id is not null', NULL, NULL, NULL, 'cbi.[reference]', 'c:\CSV', NULL, 'y', 'reference', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'currency', NULL, NULL, 'cbi.counterparty_id is not null', NULL, NULL, NULL, 'cbi.[currency]', 'c:\CSV', NULL, 'y', 'currency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_bank_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cbi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'limit_type', NULL, NULL, 'cl.counterparty_id is not null', NULL, NULL, NULL, 'cl.[limit_type]', 'c:\CSV', NULL, 'y', 'limit_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'applies_to', NULL, NULL, 'cl.counterparty_id is not null', NULL, NULL, NULL, 'cl.[applies_to]', 'c:\CSV', NULL, 'y', 'applies_to', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, 'cl.counterparty_id is not null', NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\CSV', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_rating_id', NULL, NULL, 'cl.counterparty_id is not null', NULL, NULL, NULL, 'cl.[internal_rating_id]', 'c:\CSV', NULL, 'y', 'internal_rating_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'volume_limit_type', NULL, NULL, 'cl.counterparty_id is not null', NULL, NULL, NULL, 'cl.[volume_limit_type]', 'c:\CSV', NULL, 'y', 'volume_limit_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'limit_value', NULL, NULL, 'cl.counterparty_id is not null', NULL, NULL, NULL, 'cl.[limit_type]', 'c:\CSV', NULL, 'y', 'limit_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'uom_id', NULL, NULL, 'cl.counterparty_id is not null', NULL, NULL, NULL, 'cl.[uom_id]', 'c:\CSV', NULL, 'y', 'uom_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'formula_id', NULL, NULL, 'cl.counterparty_id is not null', NULL, NULL, NULL, 'cl.[formula_id]', 'c:\CSV', NULL, 'y', 'formula_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'currency_id', NULL, NULL, 'cl.counterparty_id is not null', NULL, NULL, NULL, 'cl.[currency_id]', 'c:\CSV', NULL, 'y', 'currency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bucket_detail_id', NULL, NULL, 'cl.counterparty_id is not null', NULL, NULL, NULL, 'cl.[bucket_detail_id]', 'c:\CSV', NULL, 'y', 'bucket_detail_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_limits'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cl'
								WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, 'ccoi.counterparty_id is not null', NULL, NULL, NULL, 'sc.[source_counterparty_id]', 'c:\csv', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_confirm_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ccoi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_confirm_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'from_text', NULL, NULL, 'ccoi.counterparty_id is not null', NULL, NULL, NULL, 'ccoi.[from_text]', 'c:\csv', NULL, 'y', 'from_text', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_confirm_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ccoi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_confirm_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'to_text', NULL, NULL, 'ccoi.counterparty_id is not null', NULL, NULL, NULL, 'ccoi.[to_text]', 'c:\csv', NULL, 'y', 'to_text', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_confirm_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ccoi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_confirm_info_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'instruction', NULL, NULL, 'ccoi.counterparty_id is not null', NULL, NULL, NULL, 'ccoi.[instruction]', 'c:\csv', NULL, 'y', 'instruction', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'counterparty_confirm_info'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ccoi'
								WHERE it.ixp_tables_name = 'ixp_counterparty_confirm_info_template'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END