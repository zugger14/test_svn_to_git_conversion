IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Process_Risk_Controls') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Process_Risk_Controls' ,
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
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1599,
									    'SSD_activity_category_id',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1600,
									    'SSD_activity_who_for_id',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1601,
									    'SSD_where_id',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1602,
									    'SSD_activity_area_id',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1603,
									    'SSD_activity_sub_area_id',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1604,
									    'SSD_activity_action_id',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1605,
									    'SSD_monetary_value_frequency_id',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    1606,
									    'SSD_working_days_value_id',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'process_risk_controls',
									    1607,
									    'PRC',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'process_risk_controls',
									    1608,
									    'PRC_mitigationActivity',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'process_risk_controls',
									    1609,
									    'PRC_triggerActivity',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'portfolio_hierarchy',
									    1610,
									    'PH_fas_book_id',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'application_users',
									    1611,
									    'AU_approve_user',
									    6 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'application_users',
									    1612,
									    'AU_perform_user',
									    6

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          1294,         @ixp_rules_id_new,         1599,         1607,         'value_id',         'activity_category_id',         1599 UNION ALL          SELECT          1295,         @ixp_rules_id_new,         1600,         1607,         'value_id',         'activity_who_for_id',         1600 UNION ALL          SELECT          1296,         @ixp_rules_id_new,         1601,         1607,         'value_id',         'where_id',         1601 UNION ALL          SELECT          1297,         @ixp_rules_id_new,         1602,         1607,         'value_id',         'activity_area_id',         1602 UNION ALL          SELECT          1298,         @ixp_rules_id_new,         1603,         1607,         'value_id',         'activity_sub_area_id',         1603 UNION ALL          SELECT          1299,         @ixp_rules_id_new,         1604,         1607,         'value_id',         'activity_action_id',         1604 UNION ALL          SELECT          1300,         @ixp_rules_id_new,         1612,         1607,         'user_login_id',         'perform_user',         1612 UNION ALL          SELECT          1301,         @ixp_rules_id_new,         1605,         1607,         'value_id',         'monetary_value_frequency_id',         1605 UNION ALL          SELECT          1302,         @ixp_rules_id_new,         1606,         1607,         'value_id',         'working_days_value_id',         1606 UNION ALL          SELECT          1303,         @ixp_rules_id_new,         1608,         1607,         'risk_control_id',         'mitigationActivity',         1608 UNION ALL          SELECT          1304,         @ixp_rules_id_new,         1609,         1607,         'risk_control_id',         'triggerActivity',         1609 UNION ALL          SELECT          1305,         @ixp_rules_id_new,         1610,         1607,         'entity_id',         'fas_book_id',         1610 UNION ALL          SELECT          1306,         @ixp_rules_id_new,         1611,         1607,         'user_login_id',         'approve_user',         1611

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
								         it.ixp_tables_id, 'risk_description_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[risk_description_id]', '\\lhotse\users\export\', NULL, 'y', 'risk_description_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'risk_control_description', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[risk_control_description]', '\\lhotse\users\export\', NULL, 'y', 'risk_control_description', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'perform_role', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[perform_role]', '\\lhotse\users\export\', NULL, 'y', 'perform_role', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'approve_role', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[approve_role]', '\\lhotse\users\export\', NULL, 'y', 'approve_role', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'run_frequency', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[run_frequency]', '\\lhotse\users\export\', NULL, 'y', 'run_frequency', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'control_type', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[control_type]', '\\lhotse\users\export\', NULL, 'y', 'control_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'threshold_days', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[threshold_days]', '\\lhotse\users\export\', NULL, 'y', 'threshold_days', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'requires_approval', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[requires_approval]', '\\lhotse\users\export\', NULL, 'y', 'requires_approval', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'requires_proof', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[requires_proof]', '\\lhotse\users\export\', NULL, 'y', 'requires_proof', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'control_objective', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[control_objective]', '\\lhotse\users\export\', NULL, 'y', 'control_objective', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'internal_function_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[internal_function_id]', '\\lhotse\users\export\', NULL, 'y', 'internal_function_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'where_id', NULL, NULL, NULL, NULL, NULL, NULL, 'SSD_where_id.[value_id]', '\\lhotse\users\export\', NULL, 'y', 'where_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'activity_area_id', NULL, NULL, NULL, NULL, NULL, NULL, 'SSD_activity_area_id.[value_id]', '\\lhotse\users\export\', NULL, 'y', 'activity_area_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'activity_sub_area_id', NULL, NULL, NULL, NULL, NULL, NULL, 'SSD_activity_sub_area_id.[value_id]', '\\lhotse\users\export\', NULL, 'y', 'activity_sub_area_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'activity_action_id', NULL, NULL, NULL, NULL, NULL, NULL, 'SSD_activity_action_id.[value_id]', '\\lhotse\users\export\', NULL, 'y', 'activity_action_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'activity_category_id', NULL, NULL, NULL, NULL, NULL, NULL, 'SSD_activity_category_id.[value_id]', '\\lhotse\users\export\', NULL, 'y', 'activity_category_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'activity_who_for_id', NULL, NULL, NULL, NULL, NULL, NULL, 'SSD_activity_who_for_id.[value_id]', '\\lhotse\users\export\', NULL, 'y', 'activity_who_for_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'monetary_value_frequency_id', NULL, NULL, NULL, NULL, NULL, NULL, 'SSD_monetary_value_frequency_id.[value_id]', '\\lhotse\users\export\', NULL, 'y', 'monetary_value_frequency_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'fas_book_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PH_fas_book_id.[entity_id]', '\\lhotse\users\export\', NULL, 'y', 'fas_book_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'requirements_revision_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[requirements_revision_id]', '\\lhotse\users\export\', NULL, 'y', 'requirements_revision_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'run_effective_date', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[run_effective_date]', '\\lhotse\users\export\', NULL, 'y', 'run_effective_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'run_end_date', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[run_end_date]', '\\lhotse\users\export\', NULL, 'y', 'run_end_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'run_date', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[run_date]', '\\lhotse\users\export\', NULL, 'y', 'run_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'monetary_value', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[monetary_value]', '\\lhotse\users\export\', NULL, 'y', 'monetary_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'monetary_value_changes', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[monetary_value_changes]', '\\lhotse\users\export\', NULL, 'y', 'monetary_value_changes', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'requires_approval_for_late', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[requires_approval_for_late]', '\\lhotse\users\export\', NULL, 'y', 'requires_approval_for_late', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'mitigation_plan_required', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[mitigation_plan_required]', '\\lhotse\users\export\', NULL, 'y', 'mitigation_plan_required', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'triggerExists', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[triggerExists]', '\\lhotse\users\export\', NULL, 'y', 'triggerExists', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'triggerActivity', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC_triggerActivity.[risk_control_id]', '\\lhotse\users\export\', NULL, 'y', 'triggerActivity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'mitigationActivity', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC_mitigationActivity.[risk_control_id]', '\\lhotse\users\export\', NULL, 'y', 'mitigationActivity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'notificationOnly', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[notificationOnly]', '\\lhotse\users\export\', NULL, 'y', 'notificationOnly', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'frequency_type', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[frequency_type]', '\\lhotse\users\export\', NULL, 'y', 'frequency_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'perform_user', NULL, NULL, NULL, NULL, NULL, NULL, 'AU_perform_user.[user_login_id]', '\\lhotse\users\export\', NULL, 'y', 'perform_user', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'approve_user', NULL, NULL, NULL, NULL, NULL, NULL, 'AU_approve_user.[user_login_id]', '\\lhotse\users\export\', NULL, 'y', 'approve_user', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'working_days_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'SSD_working_days_value_id.[value_id]', '\\lhotse\users\export\', NULL, 'y', 'working_days_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'holiday_calendar_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[holiday_calendar_value_id]', '\\lhotse\users\export\', NULL, 'y', 'holiday_calendar_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'perform_activity', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[perform_activity]', '\\lhotse\users\export\', NULL, 'y', 'perform_activity', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'no_of_days', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[no_of_days]', '\\lhotse\users\export\', NULL, 'y', 'no_of_days', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'days_start_from', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[days_start_from]', '\\lhotse\users\export\', NULL, 'y', 'days_start_from', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'activity_type', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[activity_type]', '\\lhotse\users\export\', NULL, 'y', 'activity_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'action_type_on_approve', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[action_type_on_approve]', '\\lhotse\users\export\', NULL, 'y', 'action_type_on_approve', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'action_label_on_approve', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[action_label_on_approve]', '\\lhotse\users\export\', NULL, 'y', 'action_label_on_approve', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'action_type_on_complete', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[action_type_on_complete]', '\\lhotse\users\export\', NULL, 'y', 'action_type_on_complete', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'action_label_on_complete', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[action_label_on_complete]', '\\lhotse\users\export\', NULL, 'y', 'action_label_on_complete', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'action_type_secondary', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[action_type_secondary]', '\\lhotse\users\export\', NULL, 'y', 'action_type_secondary', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'action_label_secondary', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[action_label_secondary]', '\\lhotse\users\export\', NULL, 'y', 'action_label_secondary', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'document_template', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[document_template]', '\\lhotse\users\export\', NULL, 'y', 'document_template', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'trigger_primary', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[trigger_primary]', '\\lhotse\users\export\', NULL, 'y', 'trigger_primary', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'trigger_secondary', NULL, NULL, NULL, NULL, NULL, NULL, 'PRC.[trigger_secondary]', '\\lhotse\users\export\', NULL, 'y', 'trigger_secondary', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'process_risk_controls'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'PRC'
								WHERE it.ixp_tables_name = 'ixp_process_risk_controls'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END