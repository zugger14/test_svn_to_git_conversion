IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Application Users') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Application Users' ,
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
								WHERE it.ixp_tables_name = 'ixp_application_users'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'time_zones',
									    2385,
									    'tz',
									    2387 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'region',
									    2386,
									    'r',
									    2387 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'application_users',
									    2387,
									    'au',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'application_users',
									    2388,
									    'au1',
									    2387 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2389,
									    'ssd',
									    2387 UNION ALL 
										SELECT @ixp_rules_id_new,
									    'static_data_value',
									    2390,
									    'ssd1',
									    2387

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          2057,         @ixp_rules_id_new,         2385,         2387,         'TIMEZONE_ID',         'timezone_id',         2385 UNION ALL          SELECT          2058,         @ixp_rules_id_new,         2386,         2387,         'region_id',         'region_id',         2386 UNION ALL          SELECT          2059,         @ixp_rules_id_new,         2388,         2387,         'user_login_id',         'reports_to_user_login_id',         2388 UNION ALL          SELECT          2060,         @ixp_rules_id_new,         2389,         2387,         'value_id',         'entity_id',         2389 UNION ALL          SELECT          2061,         @ixp_rules_id_new,         2390,         2387,         'value_id',         'state_value_id',         2390

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
								         it.ixp_tables_id, 'user_login_id', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_login_id]', '\\LHOTSE\Users\export', NULL, 'y', 'user_login_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_f_name', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_f_name]', '\\LHOTSE\Users\export', NULL, 'y', 'user_f_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_m_name', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_m_name]', '\\LHOTSE\Users\export', NULL, 'y', 'user_m_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_l_name', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_l_name]', '\\LHOTSE\Users\export', NULL, 'y', 'user_l_name', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_pwd', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_pwd]', '\\LHOTSE\Users\export', NULL, 'y', 'user_pwd', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_title', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_title]', '\\LHOTSE\Users\export', NULL, 'y', 'user_title', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'entity_id', NULL, NULL, NULL, NULL, NULL, NULL, 'ssd.[value_id]', '\\LHOTSE\Users\export', NULL, 'y', 'entity_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_address1', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_address1]', '\\LHOTSE\Users\export', NULL, 'y', 'user_address1', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_address2', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_address2]', '\\LHOTSE\Users\export', NULL, 'y', 'user_address2', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_address3', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_address3]', '\\LHOTSE\Users\export', NULL, 'y', 'user_address3', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'city_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[city_value_id]', '\\LHOTSE\Users\export', NULL, 'y', 'city_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'state_value_id', NULL, NULL, NULL, NULL, NULL, NULL, 'ssd1.[value_id]', '\\LHOTSE\Users\export', NULL, 'y', 'state_value_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_zipcode', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_zipcode]', '\\LHOTSE\Users\export', NULL, 'y', 'user_zipcode', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_off_tel', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_off_tel]', '\\LHOTSE\Users\export', NULL, 'y', 'user_off_tel', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_main_tel', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_main_tel]', '\\LHOTSE\Users\export', NULL, 'y', 'user_main_tel', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_pager_tel', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_pager_tel]', '\\LHOTSE\Users\export', NULL, 'y', 'user_pager_tel', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_mobile_tel', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_mobile_tel]', '\\LHOTSE\Users\export', NULL, 'y', 'user_mobile_tel', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_fax_tel', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_fax_tel]', '\\LHOTSE\Users\export', NULL, 'y', 'user_fax_tel', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_emal_add', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_emal_add]', '\\LHOTSE\Users\export', NULL, 'y', 'user_emal_add', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'message_refresh_time', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[message_refresh_time]', '\\LHOTSE\Users\export', NULL, 'y', 'message_refresh_time', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'region_id', NULL, NULL, NULL, NULL, NULL, NULL, 'r.[region_id]', '\\LHOTSE\Users\export', NULL, 'y', 'region_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'user_active', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[user_active]', '\\LHOTSE\Users\export', NULL, 'y', 'user_active', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'temp_pwd', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[temp_pwd]', '\\LHOTSE\Users\export', NULL, 'y', 'temp_pwd', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'expire_date', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[expire_date]', '\\LHOTSE\Users\export', NULL, 'y', 'expire_date', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'lock_account', NULL, NULL, NULL, NULL, NULL, NULL, 'au.[lock_account]', '\\LHOTSE\Users\export', NULL, 'y', 'lock_account', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'reports_to_user_login_id', NULL, NULL, NULL, NULL, NULL, NULL, 'au1.[user_login_id]', '\\LHOTSE\Users\export', NULL, 'y', 'reports_to_user_login_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'timezone_id', NULL, NULL, NULL, NULL, NULL, NULL, 'tz.[TIMEZONE_ID]', '\\LHOTSE\Users\export', NULL, 'y', 'timezone_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'application_users'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'au'
								WHERE it.ixp_tables_name = 'ixp_application_users'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END