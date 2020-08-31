IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Counterparty Export (Script)') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Counterparty Export (Script)' ,
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
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'source_counterparty',
									    88,
									    'cpty',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'source_counterparty',
									    89,
									    'netting',
									    168 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    90,
									    'state',
									    168 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    91,
									    'country',
									    168 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    92,
									    'delivery_method',
									    168 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    93,
									    'type_entity',
									    168 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    94,
									    'region',
									    168

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          61,         @ixp_rules_id_new,         90,         88,         'value_id',         'state',         NULL UNION ALL          SELECT          62,         @ixp_rules_id_new,         91,         88,         'value_id',         'country',         NULL UNION ALL          SELECT          63,         @ixp_rules_id_new,         92,         88,         'value_id',         'delivery_method',         NULL UNION ALL          SELECT          64,         @ixp_rules_id_new,         93,         88,         'value_id',         'type_of_entity',         NULL UNION ALL          SELECT          65,         @ixp_rules_id_new,         89,         88,         'source_counterparty_id',         'netting_parent_counterparty_id',         NULL UNION ALL          SELECT          66,         @ixp_rules_id_new,         94,         88,         'value_id',         'region',         NULL

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
								         it.ixp_tables_id, 'source_system_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[source_system_id]', '\\lhotse\users\export', NULL, 'y', 'source_system_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[counterparty_id]', '\\lhotse\users\export', NULL, 'y', 'counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_name', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[counterparty_name]', '\\lhotse\users\export', NULL, 'y', 'counterparty_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_desc', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[counterparty_desc]', '\\lhotse\users\export', NULL, 'y', 'counterparty_desc', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'int_ext_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[int_ext_flag]', '\\lhotse\users\export', NULL, 'y', 'int_ext_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'netting_parent_counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'netting.[source_counterparty_id]', '\\lhotse\users\export', NULL, 'y', 'netting_parent_counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'address', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[address]', '\\lhotse\users\export', NULL, 'y', 'address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'phone_no', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[phone_no]', '\\lhotse\users\export', NULL, 'y', 'phone_no', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'mailing_address', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[mailing_address]', '\\lhotse\users\export', NULL, 'y', 'mailing_address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fax', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[fax]', '\\lhotse\users\export', NULL, 'y', 'fax', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'type_of_entity', NULL, NULL, NULL, NULL, NULL, NULL, 'type_entity.[value_id]', '\\lhotse\users\export', NULL, 'y', 'type_of_entity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_name', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[contact_name]', '\\lhotse\users\export', NULL, 'y', 'contact_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_title', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[contact_title]', '\\lhotse\users\export', NULL, 'y', 'contact_title', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_address', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[contact_address]', '\\lhotse\users\export', NULL, 'y', 'contact_address', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_address2', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[contact_address2]', '\\lhotse\users\export', NULL, 'y', 'contact_address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_phone', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[contact_phone]', '\\lhotse\users\export', NULL, 'y', 'contact_phone', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_fax', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[contact_fax]', '\\lhotse\users\export', NULL, 'y', 'contact_fax', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'instruction', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[instruction]', '\\lhotse\users\export', NULL, 'y', 'instruction', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'confirm_from_text', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[confirm_from_text]', '\\lhotse\users\export', NULL, 'y', 'confirm_from_text', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'confirm_to_text', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[confirm_to_text]', '\\lhotse\users\export', NULL, 'y', 'confirm_to_text', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'confirm_instruction', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[confirm_instruction]', '\\lhotse\users\export', NULL, 'y', 'confirm_instruction', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_contact_title', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[counterparty_contact_title]', '\\lhotse\users\export', NULL, 'y', 'counterparty_contact_title', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_contact_name', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[counterparty_contact_name]', '\\lhotse\users\export', NULL, 'y', 'counterparty_contact_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'parent_counterparty_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[parent_counterparty_id]', '\\lhotse\users\export', NULL, 'y', 'parent_counterparty_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'customer_duns_number', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[customer_duns_number]', '\\lhotse\users\export', NULL, 'y', 'customer_duns_number', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_jurisdiction', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[is_jurisdiction]', '\\lhotse\users\export', NULL, 'y', 'is_jurisdiction', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'counterparty_contact_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[counterparty_contact_id]', '\\lhotse\users\export', NULL, 'y', 'counterparty_contact_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'email', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[email]', '\\lhotse\users\export', NULL, 'y', 'email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'contact_email', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[contact_email]', '\\lhotse\users\export', NULL, 'y', 'contact_email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'city', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[city]', '\\lhotse\users\export', NULL, 'y', 'city', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'state', NULL, NULL, NULL, NULL, NULL, NULL, 'state.[value_id]', '\\lhotse\users\export', NULL, 'y', 'state', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'zip', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[zip]', '\\lhotse\users\export', NULL, 'y', 'zip', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_active', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[is_active]', '\\lhotse\users\export', NULL, 'y', 'is_active', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'tax_id', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[tax_id]', '\\lhotse\users\export', NULL, 'y', 'tax_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'delivery_method', NULL, NULL, NULL, NULL, NULL, NULL, 'delivery_method.[value_id]', '\\lhotse\users\export', NULL, 'y', 'delivery_method', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'country', NULL, NULL, NULL, NULL, NULL, NULL, 'country.[value_id]', '\\lhotse\users\export', NULL, 'y', 'country', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'region', NULL, NULL, NULL, NULL, NULL, NULL, 'region.[value_id]', '\\lhotse\users\export', NULL, 'y', 'region', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'cc_email', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[cc_email]', '\\lhotse\users\export', NULL, 'y', 'cc_email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bcc_email', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[bcc_email]', '\\lhotse\users\export', NULL, 'y', 'bcc_email', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'cc_remittance', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[cc_remittance]', '\\lhotse\users\export', NULL, 'y', 'cc_remittance', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'bcc_remittance', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[cc_remittance]', '\\lhotse\users\export', NULL, 'y', 'bcc_remittance', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'email_remittance_to', NULL, NULL, NULL, NULL, NULL, NULL, 'cpty.[email_remittance_to]', '\\lhotse\users\export', NULL, 'y', 'email_remittance_to', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'source_counterparty'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'cpty'
								WHERE it.ixp_tables_name = 'ixp_source_counterparty_template'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END