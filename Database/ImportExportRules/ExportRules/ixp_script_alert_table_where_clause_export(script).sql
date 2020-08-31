IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Alert_Table_Where_Clause') BEGIN BEGIN TRY BEGIN TRAN
INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category)
	        VALUES( 
				'Alert_Table_Where_Clause' ,
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
								WHERE it.ixp_tables_name = 'ixp_alert_table_where_clause'
							    
 IF OBJECT_ID('tempdb..#old_ixp_export_data_source') IS NOT NULL DROP TABLE #old_ixp_export_data_source 
CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000), ixp_export_data_source_id INT, export_table_alias VARCHAR(200), root_table_id INT ) 
INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id)  
										SELECT @ixp_rules_id_new,
									    'alert_table_where_clause',
									    1589,
									    'ATWC',
									    NULL UNION ALL 
										SELECT @ixp_rules_id_new,
									    'alert_conditions',
									    1590,
									    'AC',
									    1589

		INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
		SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
		FROM #old_ixp_export_data_source old 
		INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
		
 IF OBJECT_ID('tempdb..#old_relation') IS NOT NULL DROP TABLE #old_relation 
CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000), to_column varchar(1000), data_source INT)
INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source)          SELECT          1289,         @ixp_rules_id_new,         1590,         1589,         'alert_conditions_id',         'condition_id',         1590

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
								         it.ixp_tables_id, 'alert_id', NULL, NULL, NULL, NULL, NULL, NULL, 'ATWC.[alert_id]', '\\lhotse\users\export\', NULL, 'y', 'alert_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_table_where_clause'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ATWC'
								WHERE it.ixp_tables_name = 'ixp_alert_table_where_clause'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'clause_type', NULL, NULL, NULL, NULL, NULL, NULL, 'ATWC.[clause_type]', '\\lhotse\users\export\', NULL, 'y', 'clause_type', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_table_where_clause'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ATWC'
								WHERE it.ixp_tables_name = 'ixp_alert_table_where_clause'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'column_id', NULL, NULL, NULL, NULL, NULL, NULL, 'ATWC.[column_id]', '\\lhotse\users\export\', NULL, 'y', 'column_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_table_where_clause'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ATWC'
								WHERE it.ixp_tables_name = 'ixp_alert_table_where_clause'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'operator_id', NULL, NULL, NULL, NULL, NULL, NULL, 'ATWC.[operator_id]', '\\lhotse\users\export\', NULL, 'y', 'operator_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_table_where_clause'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ATWC'
								WHERE it.ixp_tables_name = 'ixp_alert_table_where_clause'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'column_value', NULL, NULL, NULL, NULL, NULL, NULL, 'ATWC.[column_value]', '\\lhotse\users\export\', NULL, 'y', 'column_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_table_where_clause'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ATWC'
								WHERE it.ixp_tables_name = 'ixp_alert_table_where_clause'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'second_value', NULL, NULL, NULL, NULL, NULL, NULL, 'ATWC.[second_value]', '\\lhotse\users\export\', NULL, 'y', 'second_value', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_table_where_clause'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ATWC'
								WHERE it.ixp_tables_name = 'ixp_alert_table_where_clause'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'table_id', NULL, NULL, NULL, NULL, NULL, NULL, 'ATWC.[table_id]', '\\lhotse\users\export\', NULL, 'y', 'table_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_table_where_clause'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ATWC'
								WHERE it.ixp_tables_name = 'ixp_alert_table_where_clause'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'column_function', NULL, NULL, NULL, NULL, NULL, NULL, 'ATWC.[column_function]', '\\lhotse\users\export\', NULL, 'y', 'column_function', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_table_where_clause'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ATWC'
								WHERE it.ixp_tables_name = 'ixp_alert_table_where_clause'
								 UNION ALL  SELECT @ixp_rules_id_new, 
								         it.ixp_tables_id, 'condition_id', NULL, NULL, NULL, NULL, NULL, NULL, 'AC.[alert_conditions_id]', '\\lhotse\users\export\', NULL, 'y', 'condition_id', 
										ieds.ixp_export_data_source_id
								FROM ixp_tables it
								LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = 'alert_table_where_clause'
								LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = 'ATWC'
								WHERE it.ixp_tables_name = 'ixp_alert_table_where_clause'
								
COMMIT 

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
				
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
		END