IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Alert_Reports') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Alert_Reports' ,
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
								WHERE it.ixp_tables_name = 'ixp_alert_reports'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'alert_reports',
									    1577,
									    'AR',
									    NULL

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)


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
								         it.ixp_tables_id, 'alert_sql_id', NULL, NULL, NULL, NULL, NULL, NULL, 'AR.[alert_sql_id]', '\\lhotse\users\export\', NULL, 'y', 'alert_sql_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_reports'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'AR'
								WHERE it.ixp_tables_name = 'ixp_alert_reports'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'report_writer', NULL, NULL, NULL, NULL, NULL, NULL, 'AR.[report_writer]', '\\lhotse\users\export\', NULL, 'y', 'report_writer', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_reports'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'AR'
								WHERE it.ixp_tables_name = 'ixp_alert_reports'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'paramset_hash', NULL, NULL, NULL, NULL, NULL, NULL, 'AR.[paramset_hash]', '\\lhotse\users\export\', NULL, 'y', 'paramset_hash', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_reports'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'AR'
								WHERE it.ixp_tables_name = 'ixp_alert_reports'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'report_param', NULL, NULL, NULL, NULL, NULL, NULL, 'AR.[report_param]', '\\lhotse\users\export\', NULL, 'y', 'report_param', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_reports'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'AR'
								WHERE it.ixp_tables_name = 'ixp_alert_reports'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'report_desc', NULL, NULL, NULL, NULL, NULL, NULL, 'AR.[report_desc]', '\\lhotse\users\export\', NULL, 'y', 'report_desc', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_reports'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'AR'
								WHERE it.ixp_tables_name = 'ixp_alert_reports'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'table_prefix', NULL, NULL, NULL, NULL, NULL, NULL, 'AR.[table_prefix]', '\\lhotse\users\export\', NULL, 'y', 'table_prefix', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_reports'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'AR'
								WHERE it.ixp_tables_name = 'ixp_alert_reports'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'table_postfix', NULL, NULL, NULL, NULL, NULL, NULL, 'AR.[table_postfix]', '\\lhotse\users\export\', NULL, 'y', 'table_postfix', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_reports'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'AR'
								WHERE it.ixp_tables_name = 'ixp_alert_reports'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END