IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'MaintainFieldTemplateDetail1') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'MaintainFieldTemplateDetail1' ,
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
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  1,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_maintain_field_template'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  2,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_maintain_field_template_group_template'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
							     UNION ALL 
							   SELECT @ixp_rules_id_new,
									  it.ixp_tables_id,
									  dependent_table.ixp_tables_id,
									  0,
									  3,
							          0
							    FROM ixp_tables it
								LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = 'ixp_maintain_field_deal_template'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'maintain_field_template_detail',
									    1415,
									    'mftd',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'maintain_field_template',
									    1416,
									    'mft_field_template_id',
									    1567 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'maintain_field_template_group',
									    1417,
									    'mftg_template_group_id',
									    1567 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'maintain_field_deal',
									    1418,
									    'mfd_field_id',
									    1567

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          1133,         @ixp_rules_id_new,         1416,         1415,         'field_template_id',         'field_template_id',         1416 UNION ALL          SELECT          1134,         @ixp_rules_id_new,         1417,         1415,         'field_group_id',         'field_group_id',         1417 UNION ALL          SELECT          1135,         @ixp_rules_id_new,         1418,         1415,         'field_id',         'field_id',         1418

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
								         it.ixp_tables_id, 'field_template_id', NULL, NULL, NULL, NULL, NULL, NULL, 'mft_field_template_id.[field_template_id]', 'D:\', NULL, 'y', 'field_template_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'field_group_id', NULL, NULL, NULL, NULL, NULL, NULL, 'mftg_template_group_id.[field_group_id]', 'D:\', NULL, 'y', 'field_group_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'field_id', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[field_id]', 'D:\', NULL, 'y', 'field_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'seq_no', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[seq_no]', 'D:\', NULL, 'y', 'seq_no', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_disable', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[is_disable]', 'D:\', NULL, 'y', 'is_disable', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'insert_required', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[insert_required]', 'D:\', NULL, 'y', 'insert_required', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'field_caption', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[field_caption]', 'D:\', NULL, 'y', 'field_caption', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'default_value', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[default_value]', 'D:\', NULL, 'y', 'default_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'udf_or_system', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[udf_or_system]', 'D:\', NULL, 'y', 'udf_or_system', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'min_value', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[min_value]', 'D:\', NULL, 'y', 'min_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'max_value', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[max_value]', 'D:\', NULL, 'y', 'max_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'validation_id', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[validation_id]', 'D:\', NULL, 'y', 'validation_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'data_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[data_flag]', 'D:\', NULL, 'y', 'data_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'buy_label', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[buy_label]', 'D:\', NULL, 'y', 'buy_label', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'sell_label', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[sell_label]', 'D:\', NULL, 'y', 'sell_label', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'deal_update_seq_no', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[deal_update_seq_no]', 'D:\', NULL, 'y', 'deal_update_seq_no', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'update_required', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[update_required]', 'D:\', NULL, 'y', 'update_required', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'hide_control', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[hide_control]', 'D:\', NULL, 'y', 'hide_control', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'display_format', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[display_format]', 'D:\', NULL, 'y', 'display_format', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'value_required', NULL, NULL, NULL, NULL, NULL, NULL, 'mftd.[value_required]', 'D:\', NULL, 'y', 'value_required', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_detail'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftd'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'template_name', NULL, NULL, NULL, NULL, NULL, NULL, 'mft_field_template_id.[template_name]', 'D:\', NULL, 'y', 'template_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'template_description', NULL, NULL, NULL, NULL, NULL, NULL, 'mft_field_template_id.[template_description]', 'D:\', NULL, 'y', 'template_description', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'active_inactive', NULL, NULL, NULL, NULL, NULL, NULL, 'mft_field_template_id.[active_inactive]', 'D:\', NULL, 'y', 'active_inactive', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'field_template_id', NULL, NULL, NULL, NULL, NULL, NULL, 'mft_field_template_id.[field_template_id]', 'D:\', NULL, 'y', 'field_template_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_group'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftg_template_group_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_group_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'group_name', NULL, NULL, NULL, NULL, NULL, NULL, 'mftg_template_group_id.[group_name]', 'D:\', NULL, 'y', 'group_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_group'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftg_template_group_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_group_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'seq_no', NULL, NULL, NULL, NULL, NULL, NULL, 'mftg_template_group_id.[seq_no]', 'D:\', NULL, 'y', 'seq_no', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_template_group'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mftg_template_group_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_template_group_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'field_id', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[field_id]', 'D:\', NULL, 'y', 'field_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'farrms_field_id', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[farrms_field_id]', 'D:\', NULL, 'y', 'farrms_field_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'default_label', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[default_label]', 'D:\', NULL, 'y', 'default_label', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'field_type', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[field_type]', 'D:\', NULL, 'y', 'field_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'data_type', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[data_type]', 'D:\', NULL, 'y', 'data_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'default_validation', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[default_validation]', 'D:\', NULL, 'y', 'default_validation', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'header_detail', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[header_detail]', 'D:\', NULL, 'y', 'header_detail', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'system_required', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[system_required]', 'D:\', NULL, 'y', 'system_required', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'sql_string', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[sql_string]', 'D:\', NULL, 'y', 'sql_string', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'field_size', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[field_size]', 'D:\', NULL, 'y', 'field_size', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_disable', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[is_disable]', 'D:\', NULL, 'y', 'is_disable', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'window_function_id', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[window_function_id]', 'D:\', NULL, 'y', 'window_function_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'is_hidden', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[is_hidden]', 'D:\', NULL, 'y', 'is_hidden', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'default_value', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[default_value]', 'D:\', NULL, 'y', 'default_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'insert_required', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[insert_required]', 'D:\', NULL, 'y', 'insert_required', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'data_flag', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[data_flag]', 'D:\', NULL, 'y', 'data_flag', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'update_required', NULL, NULL, NULL, NULL, NULL, NULL, 'mfd_field_id.[update_required]', 'D:\', NULL, 'y', 'update_required', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'maintain_field_deal'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'mfd_field_id'
								WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END