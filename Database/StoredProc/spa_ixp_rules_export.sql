IF OBJECT_ID(N'[dbo].[spa_ixp_rules_export]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_ixp_rules_export]
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Generates import/Export rule script. Multiple rule export feature is out this scope. Supports multiple import copy feature.

	Parameters 
	@flag : Operation flag
			 'c' : copies import rule.
	@ixp_export_id : ixp_rules_id of the report to be exported or copied.
	

*/


CREATE PROCEDURE [dbo].[spa_ixp_rules_export]
	@ixp_export_id VARCHAR(MAX),
	@flag CHAR(1)=NULL
AS
/*
DECLARE @ixp_export_id VARCHAR(MAX) =1689,
	@flag CHAR(1)=NULL
	set @flag='c'
	set @ixp_export_id='14167'
--1689	UOM Definition
--*/


SET NOCOUNT ON
BEGIN	
	DECLARE @valueList varchar(MAX)
	DECLARE @pos INT
	DECLARE @len INT
	DECLARE @value varchar(MAX)
	DEclare @copynumber varchar(20)


	SET @valueList =@ixp_export_id+',';

	SET @pos = 0
	SET @len = 0

	IF OBJECT_ID('tempdb..#temp_xml_output') IS NOT NULL
		DROP TABLE #temp_xml_output
		
	CREATE TABLE #temp_xml_output (rules_name VARCHAR(400) COLLATE DATABASE_DEFAULT , xml_string XML)

	WHILE CHARINDEX(',', @valueList, @pos+1) > 0
	BEGIN
		SET @len = CHARINDEX(',', @valueList, @pos+1) - @pos
		SET @value = SUBSTRING(@valueList, @pos, @len)

		SET @ixp_export_id=@value;
   		IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_id = @ixp_export_id)
		BEGIN
			EXEC spa_print 'Import id ', @ixp_export_id, ' is not present.'
			RETURN
		END
		
		DECLARE @import_export_flag CHAR, @custom_import CHAR, @ixp_rules_name VARCHAR(300),@ixp_rule_hash VARCHAR(50)
		SELECT @import_export_flag = ir.import_export_flag, @ixp_rules_name = ir.ixp_rules_name,@ixp_rule_hash = NULLIF(ixp_rule_hash,'')
		  FROM ixp_rules ir
		WHERE ir.ixp_rules_id = @ixp_export_id
		
		SET @ixp_rule_hash  = ISNULL(@ixp_rule_hash, dbo.FNAGETNEWID())

		IF @flag='c'
		BEGIN
			SET @ixp_rules_name='Copy of '+@ixp_rules_name
		END
		
		IF OBJECT_ID('tempdb..#import_final_query') IS NOT NULL
			DROP TABLE #import_final_query

		CREATE TABLE #import_final_query
		(
			row_id      INT IDENTITY(1, 1),
			line_query  VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
		)
		IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name like '%'+@ixp_rules_name+'%')
			SET @copynumber=''
		ElSE
			SET @copynumber=(SELECT COUNT(*) FROM ixp_rules ir WHERE ir.ixp_rules_name like '%'+@ixp_rules_name+'%')+1

		DECLARE @select_statement VARCHAR(MAX)
		
			INSERT INTO #import_final_query(line_query)
			--SELECT 'IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = ''' + @ixp_rules_name + ''') BEGIN BEGIN TRY BEGIN TRAN' 
			SELECT 'BEGIN 
	BEGIN TRY 
		BEGIN TRAN 
		DECLARE @admin_user VARCHAR(100) =  dbo.FNAAppAdminID(), @old_ixp_rule_id INT
		DECLARE @ixp_rules_id_new INT
			 '

		IF @flag  = 'c'  
		BEGIN
			INSERT INTO #import_final_query(line_query)
			--SELECT 'IF NOT EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = ''' + @ixp_rules_name + ''') BEGIN BEGIN TRY BEGIN TRAN' 
			SELECT '
			 IF @old_ixp_rule_id IS NULL   
				BEGIN 
			 '
		END
		ELSE 
		BEGIN
			INSERT INTO #import_final_query(line_query)
			SELECT '
			
			SELECT @old_ixp_rule_id = ixp_rules_id FROM ixp_rules ir 
			WHERE ixp_rule_hash = ''' + ISNULL(ir.ixp_rule_hash,-1)  + '''

			if @old_ixp_rule_id IS NULL
			BEGIN
				SELECT @old_ixp_rule_id = ixp_rules_id
			FROM ixp_rules ir
			WHERE ir.ixp_rules_name = ''' + @ixp_rules_name + '''
			END

			 
			IF @old_ixp_rule_id IS NOT NULL 
			BEGIN 
				-- Added to preserve rule detail like folder location, File endpoint details.
				IF OBJECT_ID(''tempdb..#pre_ixp_import_data_source'') IS NOT NULL
					DROP TABLE #pre_ixp_import_data_source

				SELECT rules_id
					, folder_location
					, file_transfer_endpoint_id
					, remote_directory 
				INTO #pre_ixp_import_data_source
				FROM ixp_import_data_source 
				WHERE rules_id = @old_ixp_rule_id

				EXEC spa_ixp_rules @flag = ''f'', @ixp_rules_id = @old_ixp_rule_id, @show_delete_msg = ''n'' 
		END
		 

			IF @old_ixp_rule_id IS NULL   
			BEGIN
			'
			FROM ixp_rules ir 
		WHERE ir.ixp_rules_id = CAST(@ixp_export_id AS VARCHAR(20))
		END
		 
		INSERT INTO #import_final_query(line_query)
		SELECT '
				INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, limit_rows_to, before_insert_trigger, after_insert_trigger, import_export_flag, is_system_import, ixp_owner, ixp_category, is_active,ixp_rule_hash)
				VALUES( 
					''' + 
					CASE WHEN @flag  = 'c' THEN  'Copy of ' + ir.ixp_rules_name+' '+ @copynumber ELSE ir.ixp_rules_name END 
					
					 + ''' ,
					''' + ir.individuals_script_per_ojbect + ''' ,
					' + ISNULL(CAST(ir.limit_rows_to AS VARCHAR(200)), 'NULL') + ' ,
					' + ISNULL('''' + REPLACE(ir.before_insert_trigger, '''', '''''') + '''' , 'NULL') + ',
					' + ISNULL('''' + REPLACE(ir.after_insert_trigger, '''', '''''') + '''' , 'NULL') + ',
					''' + ir.import_export_flag + ''' ,
					''' + CASE WHEN @flag  = 'c' THEN 'n' ELSE ISNULL(ir.is_system_import, 'n')  END + ''' ,
					' + CASE WHEN @flag  = 'c' THEN '''' + dbo.FNADBUser() + '''' ELSE '@admin_user' END  + ' ,
					' + ISNULL(CAST(ir.ixp_category AS VARCHAR(200)), 'NULL') + ',
					' + CAST(ISNULL(ir.is_active, 1) AS VARCHAR(5)) + ',
					''' + 
					CASE WHEN @flag  = 'c' THEN  dbo.FNAGETNEWID() ELSE ISNULL(@ixp_rule_hash,'') END 
					
					 + '''
					 )'
		FROM ixp_rules ir 
		WHERE ir.ixp_rules_id = CAST(@ixp_export_id AS VARCHAR(20))
		
		INSERT INTO #import_final_query(line_query)
		SELECT '
				SET @ixp_rules_id_new = SCOPE_IDENTITY()
				EXEC spa_print 	@ixp_rules_id_new

				UPDATE ixp
				SET import_export_id = @ixp_rules_id_new
				FROM ipx_privileges ixp
				WHERE ixp.import_export_id = @old_ixp_rule_id
		END
				
				'
		INSERT INTO #import_final_query(line_query)
		SELECT '
		ELSE 
		BEGIN
			SET @ixp_rules_id_new = @old_ixp_rule_id
			EXEC spa_print 	@ixp_rules_id_new
			
			UPDATE
			ixp_rules
			SET ixp_rules_name = ''' + ir.ixp_rules_name + '''
				, individuals_script_per_ojbect = ''' + ir.individuals_script_per_ojbect + '''
				, limit_rows_to = ' + ISNULL(CAST(ir.limit_rows_to AS VARCHAR(200)), 'NULL') + '
				, before_insert_trigger = ' + ISNULL('''' + REPLACE(ir.before_insert_trigger, '''', '''''') + '''' , 'NULL') + '
				, after_insert_trigger = ' + ISNULL('''' + REPLACE(ir.after_insert_trigger, '''', '''''') + '''' , 'NULL') + '
				, import_export_flag = ''' + ir.import_export_flag + '''
				, ixp_owner = @admin_user
				, ixp_category = ' + ISNULL(CAST(ir.ixp_category AS VARCHAR(200)), 'NULL') + '
				, is_system_import = ''' + ISNULL(ir.is_system_import, 'n') + '''
				, is_active = ' + CAST(ISNULL(ir.is_active, 1) AS VARCHAR(5)) + '
			WHERE ixp_rules_id = @ixp_rules_id_new
				
		END

				'
				FROM ixp_rules ir
				WHERE ir.ixp_rules_id = @ixp_export_id
		/* for ixp_export_tables */
		SET @select_statement = NULL
		SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
								   SELECT @ixp_rules_id_new,
										  it.ixp_tables_id,
										  dependent_table.ixp_tables_id,
										  ' + ISNULL(CAST(sequence_number AS VARCHAR(20)), 'NULL') + ',
										  ' + ISNULL(CAST(dependent_table_order AS VARCHAR(20)), 'NULL') + ',
										  ' + ISNULL(CAST(repeat_number AS VARCHAR(20)), 'NULL') + '
									FROM ixp_tables it
									LEFT JOIN ixp_tables dependent_table ON dependent_table.ixp_tables_name = ' + ISNULL('''' + dep_it.ixp_tables_name + '''', 'NULL') + '
									WHERE it.ixp_tables_name = ''' + it.ixp_tables_name + '''
									'
		FROM ixp_export_tables iet
		INNER JOIN ixp_tables it ON it.ixp_tables_id = iet.table_id
		LEFT JOIN ixp_tables dep_it ON dep_it.ixp_tables_id = iet.dependent_table_id
		WHERE iet.ixp_rules_id =  CAST(@ixp_export_id AS VARCHAR(10)) 
		
		/* for ixp_export_tables */
		INSERT INTO #import_final_query(line_query)
		SELECT 'INSERT INTO ixp_export_tables (ixp_rules_id, table_id, dependent_table_id, sequence_number, dependent_table_order, repeat_number) ' + ' ' + @select_statement

		IF @import_export_flag = 'i'
		BEGIN
			INSERT INTO #import_final_query(line_query)
			SELECT 'INSERT INTO ixp_import_data_source (rules_id, data_source_type, connection_string, data_source_location, destination_table, delimiter, source_system_id, data_source_alias, is_customized, customizing_query, is_header_less, no_of_columns, folder_location, custom_import, use_parameter
					, excel_sheet, ssis_package, soap_function_id, clr_function_id, ws_function_name, enable_email_import
					, send_email_import_reply, file_transfer_endpoint_id, remote_directory)
					SELECT @ixp_rules_id_new,
						   ' + ISNULL(CAST(iids.data_source_type AS VARCHAR(20)), 'NULL') + ',
						   ' + ISNULL('''' + iids.connection_string + '''' , 'NULL') + ',
						   ' + ISNULL('''' + iids.data_source_location + '''' , 'NULL') + ',
						   ' + ISNULL(CAST(iids.destination_table AS VARCHAR(20)), 'NULL') + ',
						   ' + ISNULL('''' + iids.delimiter + '''' , 'NULL') + ',
						   ' + ISNULL(CAST(source_system_id AS VARCHAR(20)), 'NULL') + ',
						   ' + ISNULL('''' + data_source_alias + '''' , 'NULL') + ',
						   ' + ISNULL('''' + is_customized + '''' , 'NULL') + ',
						   ' + ISNULL('''' + REPLACE(customizing_query, '''', '''''') + '''' , 'NULL') + ',
						   ' + ISNULL('''' + CAST(is_header_less AS VARCHAR(10)) + '''' , 'NULL') + ',
						   ' + ISNULL(CAST(no_of_columns AS VARCHAR(20)), 'NULL') + ',
						   ' + ISNULL('''' + folder_location + '''' , 'NULL') + ',
						   ' + ISNULL('''' + custom_import + '''' , 'NULL') + ',
						   ' + COALESCE('''' + use_parameter + '''' , 'NULL') + ',
						   ' + COALESCE('''' + excel_sheet + '''' , 'NULL') + ',
						   isc.ixp_ssis_configurations_id,
						   isf.ixp_soap_functions_id,
						   icf.ixp_clr_functions_id,
						   ' + ISNULL('''' + CASE WHEN @flag = 'c' THEN '' ELSE iids.ws_function_name END + '''' , 'NULL')  + ', 
						   ' + ISNULL('''' + CAST(iids.enable_email_import AS VARCHAR(20)) + '''' , 'NULL') + ',
						   ' + ISNULL('''' + CAST(iids.send_email_import_reply AS VARCHAR(20)) + '''' , 'NULL') + ',
						   ' + ISNULL('''' + CAST(iids.file_transfer_endpoint_id AS VARCHAR(20)) + '''' , 'NULL') + ',
						   ' + ISNULL('''' + iids.remote_directory + '''' , 'NULL') + '
					FROM ixp_rules ir 
					LEFT JOIN ixp_ssis_configurations isc ON isc.package_name = ''' + ISNULL(isc.package_name, '') + ''' 
					LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_name = ''' + ISNULL(isf.ixp_soap_functions_name, '') + ''' 
					LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_name = ''' + ISNULL(icf.ixp_clr_functions_name, '') + ''' 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new'
					+ CASE WHEN @flag IS NULL THEN
					'
						IF OBJECT_ID(''tempdb..#pre_ixp_import_data_source'') IS NOT NULL
						BEGIN
							UPDATE iids
							SET folder_location = piids.folder_location
								, file_transfer_endpoint_id = piids.file_transfer_endpoint_id
								, remote_directory = piids.remote_directory
							FROM ixp_import_data_source iids
							INNER JOIN #pre_ixp_import_data_source piids 
							ON iids.rules_id = piids.rules_id
						END
					'
					ELSE '' END 
			FROM ixp_import_data_source iids
			LEFT JOIN ixp_ssis_configurations isc ON isc.ixp_ssis_configurations_id = iids.ssis_package
			LEFT JOIN ixp_soap_functions isf ON isf.ixp_soap_functions_id = iids.soap_function_id
			LEFT JOIN ixp_clr_functions icf ON icf.ixp_clr_functions_id = iids.clr_function_id
			WHERE  rules_id = CAST(@ixp_export_id AS VARCHAR(20))
			
			/* ixp_ssis_parameters */
			--SET @select_statement = NULL
			--SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
			--						   SELECT @ixp_rules_id_new, 
			--								  ' + ISNULL('''' + isp.parameter_name + '''', 'NULL') + ', 
			--								  ' + ISNULL('''' + isp.parameter_label + '''', 'NULL') + ',
			--								  ' + ISNULL(CAST(isp.operator_id AS VARCHAR(5)), 'NULL') + ',
			--								  ' + ISNULL('''' + CAST(isp.field_type AS VARCHAR(10)) + '''', 'NULL') + ',
			--								  ' + ISNULL('''' + isp.default_value + '''', 'NULL') + ',
			--								  ' + ISNULL('''' + isp.default_value2 + '''', 'NULL') + ',
			--								  ' + ISNULL('''' + isp.grid_name + '''', 'NULL') + ''
			--FROM ixp_parameters isp
			--INNER JOIN ixp_rules ir ON isp.ixp_rules_id = ir.ixp_rules_id
			--WHERE ir.ixp_rules_id = CAST(@ixp_export_id AS VARCHAR(20))
			
			--INSERT INTO #import_final_query(line_query)
			--SELECT ISNULL('INSERT INTO ixp_parameters (ixp_rules_id, parameter_name, parameter_label, operator_id, field_type, default_value, default_value2, grid_name)' + ' ' + @select_statement, '')
			
			INSERT INTO #import_final_query(line_query)
			SELECT 'INSERT INTO ixp_import_filter (ixp_rules_id,filter_group,filter_id,filter_value,ixp_import_data_source)
					SELECT @ixp_rules_id_new,
						   ' + ISNULL('''' + ixf.filter_group + '''' , 'NULL') + ',
						   ' + ISNULL(CAST(ixf.filter_id AS VARCHAR(20)), 'NULL') + ',
						   ' + ISNULL('''' + ixf.filter_value + '''' , 'NULL') + ',
						   ' + ISNULL(CAST(ixf.ixp_import_data_source AS VARCHAR(20)), 'NULL') + '
					FROM ixp_rules ir 
					WHERE ir.ixp_rules_id = @ixp_rules_id_new '
			FROM ixp_import_filter ixf
			WHERE  ixp_rules_id = CAST(@ixp_export_id AS VARCHAR(20))
			
			SET @select_statement = NULL
			SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
									   SELECT @ixp_rules_id_new,
											  ' + ISNULL('''' + ixp_relation_alias + '''' , 'NULL') + ', 
											  ' + ISNULL(CAST(relation_source_type AS VARCHAR(20)), 'NULL') + ',
											  ' + ISNULL('''' + connection_string + '''' , 'NULL') + ',
											  ' + ISNULL('''' + relation_location + '''' , 'NULL') + ',
											  ' + ISNULL('''' + join_clause + '''' , 'NULL') + ',
											  ' + ISNULL('''' + delimiter + '''' , 'NULL') + ',
											  ' + ISNULL('''' + excel_sheet + '''' , 'NULL') + ''
			FROM ixp_import_relation iir
			INNER JOIN ixp_rules ir ON ir.ixp_rules_id = iir.ixp_rules_id
			WHERE iir.ixp_rules_id =  CAST(@ixp_export_id AS VARCHAR(10))
			
			INSERT INTO #import_final_query(line_query)
			SELECT ISNULL('INSERT INTO ixp_import_relation (ixp_rules_id, ixp_relation_alias, relation_source_type, connection_string, relation_location, join_clause, delimiter,excel_sheet ) ' + ' ' + @select_statement, '')
			
			SET @select_statement = NULL
			SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') 
				+ ' SELECT @ixp_rules_id_new, it.ixp_tables_id, ' + ISNULL('''' + source_column_name + '''' , 'NULL') 
				+ ', ic.ixp_columns_id, ' + ISNULL('''' + REPLACE(column_function, '''', '''''') + '''', 'NULL') + ', ' + ISNULL('''' + column_aggregation + '''' , 'NULL') + ', ' + ISNULL(CAST(repeat_number AS VARCHAR(20)), 'NULL') 
					+ ', ' + ISNULL('''' + where_clause + '''' , 'NULL') 
					+ ', NULL'
					+ ' 
									   FROM ixp_tables it 
									   INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = ''' + it2.ixp_tables_name + '''
									   INNER JOIN ixp_columns ic ON ic.ixp_columns_name = ''' + ic.ixp_columns_name + ''' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = ''' + COALESCE('' + ic.header_detail + '', 'NULL') + ''' OR ic.header_detail IS NULL)
									   WHERE it.ixp_tables_name = ''' + it.ixp_tables_name + ''''
			FROM ixp_import_data_mapping iids
			INNER JOIN ixp_tables it ON it.ixp_tables_id = iids.dest_table_id
			INNER JOIN ixp_columns ic ON ic.ixp_columns_id = iids.dest_column
			INNER JOIN ixp_tables it2 ON ic.ixp_table_id = it2.ixp_tables_id
			WHERE iids.ixp_rules_id = CAST(@ixp_export_id AS VARCHAR(20)) 
				AND NULLIF(iids.udf_field_id,'') is null

			SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') 
				+ ' SELECT @ixp_rules_id_new, it.ixp_tables_id, ' + ISNULL('''' + source_column_name + '''' , 'NULL') 
				+ ', ic.ixp_columns_id, ' + ISNULL('''' + REPLACE(column_function, '''', '''''') + '''', 'NULL') + ', ' + ISNULL('''' + column_aggregation + '''' , 'NULL') + ', ' + ISNULL(CAST(repeat_number AS VARCHAR(20)), 'NULL') 
					+ ', ' + ISNULL('''' + where_clause + '''' , 'NULL') 
					+ ', ISNULL(CAST(sdv.value_id AS VARCHAR(200)),''Missing udf - '''''' + ''' + sdv.code + ''' + '''''''') '
					+ ' 
				FROM ixp_tables it 
				INNER JOIN ixp_tables it2 ON it2.ixp_tables_name = ''' + it2.ixp_tables_name + '''
				INNER JOIN ixp_columns ic ON ic.ixp_columns_name = ''' + ic.ixp_columns_name + ''' AND ic.ixp_table_id = it2.ixp_tables_id AND (ic.header_detail = ''' + COALESCE('' + ic.header_detail + '', 'NULL') + ''' OR ic.header_detail IS NULL)
				LEFT JOIN static_data_value sdv ON sdv.type_id = 5500 AND sdv.code =  ''' + sdv.code + '''									   
				LEFT JOIN user_defined_fields_template udft ON udft.field_id = sdv.value_id
				WHERE it.ixp_tables_name = ''' + it.ixp_tables_name + ''''
			FROM ixp_import_data_mapping iids
			INNER JOIN ixp_tables it ON it.ixp_tables_id = iids.dest_table_id
			INNER JOIN ixp_columns ic ON ic.ixp_columns_id = iids.dest_column
			INNER JOIN ixp_tables it2 ON ic.ixp_table_id = it2.ixp_tables_id
			INNER JOIN static_data_value sdv ON sdv.value_id = iids.udf_field_id
			WHERE iids.ixp_rules_id = CAST(@ixp_export_id AS VARCHAR(20)) 
				AND NULLIF(iids.udf_field_id,'') IS NOT NULL
			
			/* for ixp_import_data_mapping */
			INSERT INTO #import_final_query(line_query)
			SELECT 'INSERT INTO ixp_import_data_mapping(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, where_clause ,udf_field_id) ' + ' ' + @select_statement
			
			/* for ixp_import_where_clause */
			SET @select_statement = NULL
			SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
										SELECT @ixp_rules_id_new,
										it.ixp_tables_id,
										' + ISNULL('''' + REPLACE(ixp_import_where_clause, '''', '''''') + '''' , 'NULL') + ',
										' + ISNULL(cast(repeat_number AS VARCHAR(20)), 'NULL') + '
										FROM ixp_tables it 
										WHERE it.ixp_tables_name = ''' + it.ixp_tables_name + '''
										'
			FROM ixp_import_where_clause iiwc
			INNER JOIN ixp_tables it ON it.ixp_tables_id = iiwc.table_id
			WHERE rules_id = CAST(@ixp_export_id AS VARCHAR(20))
					
			INSERT INTO #import_final_query(line_query)
			SELECT ISNULL('INSERT INTO ixp_import_where_clause(rules_id, table_id, ixp_import_where_clause, repeat_number) ' + ' ' + @select_statement, '')
					
			SELECT @custom_import = custom_import FROM ixp_import_data_source WHERE rules_id = CAST(@ixp_export_id AS VARCHAR(20))
			
			IF @custom_import = 'y'
			BEGIN
				INSERT INTO #import_final_query(line_query)
				SELECT ' IF OBJECT_ID(''tempdb..#old_ixp_import_query_builder_tables'') IS NOT NULL DROP TABLE #old_ixp_import_query_builder_tables '
				UNION ALL
				SELECT ' IF OBJECT_ID(''tempdb..#old_ixp_import_query_builder_relation'') IS NOT NULL DROP TABLE #old_ixp_import_query_builder_relation '
				UNION ALL
				SELECT ' IF OBJECT_ID(''tempdb..#original_ixp_import_query_builder_tables'') IS NOT NULL DROP TABLE #original_ixp_import_query_builder_tables '
				UNION ALL
				SELECT ' IF OBJECT_ID(''tempdb..#old_ixp_import_query_builder_import_tables'') IS NOT NULL DROP TABLE #old_ixp_import_query_builder_import_tables '			
				UNION ALL
				SELECT ' IF OBJECT_ID(''tempdb..#orginal_ixp_import_query_builder_import_tables'') IS NOT NULL DROP TABLE #orginal_ixp_import_query_builder_import_tables '
				UNION ALL
				SELECT ' IF OBJECT_ID(''tempdb..#old_ixp_custom_import_mapping'') IS NOT NULL DROP TABLE #old_ixp_custom_import_mapping '
				
				/* for ixp_import_query_builder_tables */
				INSERT INTO #import_final_query(line_query)
				SELECT ' CREATE TABLE #old_ixp_import_query_builder_tables (old_id INT, new_id INT, ixp_rules_id INT, tables_name VARCHAR(200) COLLATE DATABASE_DEFAULT , root_table_id INT, table_alias VARCHAR(50) COLLATE DATABASE_DEFAULT )'
				
				SET @select_statement = NULL
				SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
											SELECT @ixp_rules_id_new,
										   ' + ISNULL('''' + tables_name + '''' , 'NULL') + ',
										   ' + ISNULL(CAST(root_table_id AS VARCHAR(20)), 'NULL') + ',
										   ' + ISNULL('''' + table_alias + '''' , 'NULL') + ''
				FROM   ixp_import_query_builder_tables iiqbt1
				WHERE iiqbt1.ixp_rules_id = CAST(@ixp_export_id AS VARCHAR(20))
				
				INSERT INTO #import_final_query (line_query)
				SELECT ' 
				INSERT INTO ixp_import_query_builder_tables (ixp_rules_id, tables_name, root_table_id, table_alias)
				OUTPUT INSERTED.ixp_import_query_builder_tables_id, INSERTED.tables_name, INSERTED.table_alias, INSERTED.root_table_id
				INTO #old_ixp_import_query_builder_tables(new_id, tables_name, table_alias, root_table_id)  
				' + ' ' + @select_statement					
				
				INSERT INTO #import_final_query (line_query)
				SELECT 'DECLARE @root_id INT  
				SELECT @root_id = ixp_import_query_builder_tables_id
				FROM ixp_import_query_builder_tables 
				WHERE  root_table_id IS NULL AND ixp_rules_id = @ixp_rules_id_new
				
				UPDATE iiqbt
				SET root_table_id = @root_id
				FROM ixp_import_query_builder_tables iiqbt
				INNER JOIN #old_ixp_import_query_builder_tables oiiqbt ON iiqbt.tables_name = oiiqbt.tables_name AND iiqbt.table_alias = oiiqbt.table_alias
				WHERE oiiqbt.root_table_id IS NOT NULL
				'
							
				/* for ixp_import_query_builder_relation */
				INSERT INTO #import_final_query (line_query)
				SELECT 'SELECT @ixp_rules_id_new [rules_id],
						' + ISNULL(CAST(from_table_id AS VARCHAR(20)), 'NULL') + ' [from_table_id],
						' + ISNULL('''' + from_column + '''' , 'NULL') + ' [from_column],
						' + ISNULL(CAST(to_table_id AS VARCHAR(20)), 'NULL') + ' [to_table_id],
						' + ISNULL('''' + to_column + '''' , 'NULL') + ' [to_column] 
				INTO #old_ixp_import_query_builder_relation '
				FROM  ixp_import_query_builder_relation iiqbr
				WHERE from_table_id IS NOT NULL AND iiqbr.ixp_rules_id = @ixp_export_id
		       
				INSERT INTO #import_final_query (line_query)
				SELECT 'CREATE TABLE #original_ixp_import_query_builder_tables(ixp_import_query_builder_tables_id int , ixp_rules_id int , tables_name varchar(500) COLLATE DATABASE_DEFAULT , root_table_id int , table_alias varchar(500) COLLATE DATABASE_DEFAULT ) '  
		       
				SET @select_statement = NULL
				SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
											SELECT 
											' + ISNULL(CAST(iiqbr.ixp_import_query_builder_tables_id AS VARCHAR(20)), 'NULL') + ' [ixp_import_query_builder_tables_id],
											' + ISNULL(CAST(iiqbr.ixp_rules_id AS VARCHAR(20)), 'NULL') + ' [ixp_rules_id],	
											' + ISNULL('''' + tables_name + '''', 'NULL') + ' [tables_name],
											' + ISNULL(CAST(root_table_id AS VARCHAR(20)) , 'NULL') + ' [root_table_id],
											' + ISNULL('''' + table_alias + '''', 'NULL') + ' [table_alias] '
				FROM  ixp_import_query_builder_tables iiqbr
				INNER JOIN ixp_rules ir ON ir.ixp_rules_id = iiqbr.ixp_rules_id 
				WHERE iiqbr.ixp_rules_id = @ixp_export_id
				
				INSERT INTO #import_final_query (line_query)
				SELECT ISNULL(' INSERT INTO #original_ixp_import_query_builder_tables (ixp_import_query_builder_tables_id, ixp_rules_id, tables_name, root_table_id, table_alias) ' + ' ' + @select_statement, '')
		       
				INSERT INTO #import_final_query (line_query)
				SELECT 'INSERT INTO ixp_import_query_builder_relation (ixp_rules_id, from_table_id, from_column, to_table_id, to_column)
				SELECT @ixp_rules_id_new, new_from.ixp_import_query_builder_tables_id, a.from_column, new_to.ixp_import_query_builder_tables_id, a.to_column
				FROM #old_ixp_import_query_builder_relation a 
				INNER JOIN #original_ixp_import_query_builder_tables b_from ON b_from.ixp_import_query_builder_tables_id = a.from_table_id
				INNER JOIN #original_ixp_import_query_builder_tables b_to ON b_to.ixp_import_query_builder_tables_id = a.to_table_id
				INNER JOIN ixp_import_query_builder_tables new_from ON new_from.tables_name = b_from.tables_name
				INNER JOIN ixp_import_query_builder_tables new_to ON new_to.tables_name = b_to.tables_name
				WHERE new_from.ixp_rules_id = @ixp_rules_id_new AND new_to.ixp_rules_id = @ixp_rules_id_new
				'
				
				/* for ixp_import_query_builder_import_tables */
				INSERT INTO #import_final_query (line_query)
				SELECT 'CREATE TABLE #old_ixp_import_query_builder_import_tables (new_id INT , ixp_rules_id INT , table_id INT, sequence_number INT)'
				
				INSERT INTO #import_final_query(line_query)
				SELECT 'INSERT INTO ixp_import_query_builder_import_tables (ixp_rules_id, table_id, sequence_number)
						OUTPUT INSERTED.ixp_import_query_builder_import_tables_id, INSERTED.table_id, INSERTED.sequence_number
    					INTO #old_ixp_import_query_builder_import_tables(new_id, table_id, sequence_number)
						SELECT @ixp_rules_id_new, 
								' + ISNULL(CAST(ir.ixp_tables_id AS VARCHAR(20)), 'NULL') + ',
								' + ISNULL(CAST(sequence_number AS VARCHAR(20)), 'NULL') + '
						'
				FROM   ixp_import_query_builder_import_tables iiqbit
				INNER JOIN ixp_tables ir ON  ir.ixp_tables_id = iiqbit.table_id
				WHERE  iiqbit.ixp_rules_id =  CAST(@ixp_export_id AS VARCHAR(10))
				
				
				INSERT INTO #import_final_query(line_query)
				SELECT 'CREATE TABLE #orginal_ixp_import_query_builder_import_tables (ixp_import_query_builder_import_tables_id int , ixp_rules_id int, table_id int , sequence_number int)'
				
				SET @select_statement = NULL
				SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
											SELECT 
											' + ISNULL(CAST(ixp_import_query_builder_import_tables_id AS VARCHAR(20)), 'NULL') + ' [ixp_import_query_builder_import_tables_id],
    										' + ISNULL(CAST(iiqbmr.ixp_rules_id AS VARCHAR(20)), 'NULL') + ' [ixp_rules_id],
    										' + ISNULL(CAST(table_id AS VARCHAR(20)), 'NULL') + ' [table_id],
    										' + ISNULL(CAST(sequence_number AS VARCHAR(20)), 'NULL') + ' [sequence_number] '
				FROM   ixp_import_query_builder_import_tables iiqbmr
				INNER JOIN ixp_rules ir ON ir.ixp_rules_id = iiqbmr.ixp_rules_id 
				WHERE iiqbmr.ixp_rules_id = @ixp_export_id
				
				INSERT INTO #import_final_query (line_query)
				SELECT ' 
				INSERT INTO #orginal_ixp_import_query_builder_import_tables (ixp_import_query_builder_import_tables_id, ixp_rules_id, table_id, sequence_number) ' + ' ' + @select_statement
				
				/* for ixp_custom_import_mapping */
				INSERT INTO #import_final_query (line_query)
				SELECT ' CREATE TABLE #old_ixp_custom_import_mapping (ixp_rules_id int , dest_table_id int,  destination_column varchar(500) COLLATE DATABASE_DEFAULT , source_table_id int, source_column varchar(500) COLLATE DATABASE_DEFAULT , filter varchar(200) COLLATE DATABASE_DEFAULT , default_value varchar(2000) COLLATE DATABASE_DEFAULT ) '
				
				SET @select_statement = NULL
				SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
										   SELECT @ixp_rules_id_new [ixp_rules_id],
										   ' + ISNULL(CAST(dest_table_id AS VARCHAR(20)), 'NULL') + ' [dest_table_id],
										   ' + ISNULL('''' + destination_column + '''' , 'NULL') + ' [destination_column],
										   ' + ISNULL(CAST(source_table_id AS VARCHAR(20)), 'NULL') + ' [source_table_id],
										   ' + ISNULL('''' + source_column + '''' , 'NULL') + ' [source_column],
										   ' + ISNULL('''' + filter + '''' , 'NULL') + ' [filter],
										   ' + ISNULL('''' + REPLACE(default_value, '''', '''''') + '''', 'NULL') + ' [default_value]'
				FROM   ixp_custom_import_mapping WHERE  ixp_rules_id = CAST(@ixp_export_id AS VARCHAR(10))
				
				INSERT INTO #import_final_query (line_query)
				SELECT ' 
				INSERT INTO #old_ixp_custom_import_mapping (ixp_rules_id , dest_table_id ,  destination_column , source_table_id , source_column, filter, default_value) 
				' + ' ' + @select_statement	
				
				INSERT INTO #import_final_query (line_query)
				SELECT ' INSERT INTO ixp_custom_import_mapping (ixp_rules_id, dest_table_id, destination_column, source_table_id, source_column, filter, default_value)
				SELECT @ixp_rules_id_new, t5.new_id, t1.destination_column, t2.new_id, t1.source_column, t1.filter, t1.default_value
    			FROM #old_ixp_import_query_builder_tables t2
    			INNER JOIN #original_ixp_import_query_builder_tables t3 ON t2.tables_name = t3.tables_name AND t2.table_alias = t3.table_alias  
    			INNER join #old_ixp_custom_import_mapping t1 ON t1.source_table_id = t3.ixp_import_query_builder_tables_id
    			INNER JOIN #orginal_ixp_import_query_builder_import_tables t4 ON t4.ixp_rules_id = t3.ixp_rules_id
    			INNER JOIN #old_ixp_import_query_builder_import_tables t5 ON t5.table_id = t4.table_id AND t4.sequence_number = t5.sequence_number 
    			'
			END
		END	
		ELSE
		BEGIN		
			/* for ixp_export_tables */
			INSERT INTO #import_final_query(line_query)
			SELECT ' IF OBJECT_ID(''tempdb..#old_ixp_export_data_source'') IS NOT NULL DROP TABLE #old_ixp_export_data_source '

			INSERT INTO #import_final_query(line_query)
			SELECT 'CREATE TABLE #old_ixp_export_data_source(ixp_rules_id INT, export_table_name VARCHAR(1000) COLLATE DATABASE_DEFAULT , ixp_export_data_source_id INT, export_table_alias VARCHAR(200) COLLATE DATABASE_DEFAULT , root_table_id INT ) '
			
			SET @select_statement = NULL
			SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
											SELECT @ixp_rules_id_new,
											' + ISNULL('''' + CAST(iet.ixp_exportable_table_name AS VARCHAR(500)) + '''', 'NULL') + ',
											' + ISNULL(CAST(iids.ixp_export_data_source_id AS VARCHAR(20)), 'NULL') + ',
											' + ISNULL('''' + iids.export_table_alias + '''' , 'NULL') + ',
											' + ISNULL(CAST(iids.root_table_id AS VARCHAR(20)), 'NULL') + '' --added the root_table_id as it is present in master_branch		
			FROM ixp_export_data_source iids
			INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_id = iids.export_table
			WHERE iids.ixp_rules_id = @ixp_export_id
			
			/* for ixp_export_data_source */
			INSERT INTO #import_final_query(line_query)
			SELECT 'INSERT INTO #old_ixp_export_data_source(ixp_rules_id, export_table_name, ixp_export_data_source_id, export_table_alias, root_table_id) ' + ' ' + @select_statement
			UNION ALL		
			SELECT '
			INSERT INTO ixp_export_data_source (ixp_rules_id, export_table, export_table_alias, root_table_id)
			SELECT @ixp_rules_id_new, iet.ixp_exportable_table_id, old.export_table_alias, old.root_table_id
			FROM #old_ixp_export_data_source old 
			INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = old.export_table_name
			'
			INSERT INTO #import_final_query(line_query)
			SELECT ' IF OBJECT_ID(''tempdb..#old_relation'') IS NOT NULL DROP TABLE #old_relation '
			
			/* for ixp_export_relation */
			INSERT INTO #import_final_query(line_query)
			SELECT 'CREATE TABLE #old_relation (ixp_export_relation_id INT, ixp_rules_id INT, from_data_source INT, to_data_source INT, from_column VARCHAR(1000) COLLATE DATABASE_DEFAULT , to_column varchar(1000) COLLATE DATABASE_DEFAULT , data_source INT)'
			
			SET @select_statement = NULL
			SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + REPLACE(REPLACE(REPLACE('
										SELECT 
										' + ISNULL(CAST(ixp_export_relation_id AS VARCHAR(20)), 'NULL') + ',
										@ixp_rules_id_new,
										' + ISNULL(CAST(from_data_source AS VARCHAR(20)), 'NULL') + ',
										' + ISNULL(CAST(to_data_source AS VARCHAR(20)), 'NULL') + ',
										' + ISNULL('''' + from_column + '''' , 'NULL') + ',
										' + ISNULL('''' + to_column + '''' , 'NULL') + ',
										' + ISNULL(CAST(data_source AS VARCHAR(20)), 'NULL') + '', CHAR(10), ''), CHAR(13), ''), CHAR(9), ' ')		
			FROM ixp_export_relation ier
			WHERE ier.ixp_rules_id = @ixp_export_id
			
			INSERT INTO #import_final_query(line_query)
			SELECT 'INSERT INTO #old_relation(ixp_export_relation_id, ixp_rules_id, from_data_source, to_data_source, from_column, to_column, data_source) ' + '' + @select_statement 
			
			INSERT INTO #import_final_query(line_query)
			SELECT ISNULL('
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
			', '')
			
			/* for ixp_data_mapping */
			SET @select_statement = NULL
			SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + 
									' SELECT @ixp_rules_id_new, 
											 it.ixp_tables_id, ' +
											ISNULL('''' + idm.column_name + '''' , 'NULL') + ', ' +
											ISNULL('''' + REPLACE(idm.column_function, '''', '''''') + '''' , 'NULL') + ', ' +
											ISNULL('''' + idm.column_aggregation + '''' , 'NULL') + ', ' +
											ISNULL('''' + idm.column_filter + '''' , 'NULL') + ', ' +
											ISNULL('''' + CAST(idm.insert_type AS VARCHAR(10))  + '''' , 'NULL')+ ', ' + 
											ISNULL('''' + CAST(idm.enable_identity_insert AS VARCHAR(10)) + '''' , 'NULL')+ ', ' + 
											ISNULL('''' + CAST(idm.create_destination_table AS VARCHAR(20)) + '''' , 'NULL')+ ', ' + 
											ISNULL('''' + idm.source_column + '''' , 'NULL') + ', ' +
											ISNULL('''' + idm.export_folder + '''' , 'NULL') + ', ' +
											ISNULL('''' + CAST(idm.export_delim  AS VARCHAR(10)) + '''' , 'NULL') + ', ' + 
											ISNULL('''' + CAST(idm.generate_script  AS VARCHAR(10)) + '''' , 'NULL') + ', ' + 
											ISNULL('''' + idm.column_alias + '''' , 'NULL') + ', 
											ieds.ixp_export_data_source_id
									FROM ixp_tables it
									LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_name = ' + ISNULL('''' + iet.ixp_exportable_table_name + '''', 'NULL') + '
									LEFT JOIN ixp_export_data_source ieds ON ieds.export_table = iet.ixp_exportable_table_id AND ieds.ixp_rules_id = @ixp_rules_id_new AND ieds.export_table_alias = ' + ISNULL('''' + ieds.export_table_alias + '''', 'NULL') + '
									WHERE it.ixp_tables_name = ''' + it.ixp_tables_name + '''
									'
			FROM ixp_data_mapping idm
			INNER JOIN ixp_tables it ON idm.table_id = it.ixp_tables_id
			LEFT JOIN ixp_export_data_source ieds ON ieds.ixp_export_data_source_id = idm.main_table
			LEFT JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_id = ieds.export_table 
			WHERE idm.ixp_rules_id = @ixp_export_id
			
			INSERT INTO #import_final_query (line_query)
			SELECT ' INSERT INTO ixp_data_mapping (ixp_rules_id, table_id, column_name, column_function, column_aggregation, column_filter, insert_type, enable_identity_insert, create_destination_table, source_column, export_folder, export_delim, generate_script, column_alias, main_table )' + ' ' + @select_statement
		END
		
		INSERT INTO #import_final_query(line_query)
		SELECT 'COMMIT ' + CHAR(10) + '
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
				DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
				DECLARE @msg_severity INT = ERROR_SEVERITY();
				DECLARE @msg_state INT = ERROR_STATE();
					
				RAISERROR(@msg, @msg_severity, @msg_state)
			
				--EXEC spa_print ''Error ('' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '') at Line#'' + CAST(ERROR_LINE() AS VARCHAR(10)) + '':'' + ERROR_MESSAGE() + ''''
			END CATCH
END
		'

		IF @import_export_flag = 'i' AND @custom_import = 'y'
		BEGIN
			INSERT INTO #import_final_query(line_query)
			SELECT ' IF OBJECT_ID(''tempdb..#old_ixp_import_query_builder_tables'') IS NOT NULL DROP TABLE #old_ixp_import_query_builder_tables '
			UNION ALL
			SELECT ' IF OBJECT_ID(''tempdb..#old_ixp_import_query_builder_relation'') IS NOT NULL DROP TABLE #old_ixp_import_query_builder_relation '
			UNION ALL
			SELECT ' IF OBJECT_ID(''tempdb..#original_ixp_import_query_builder_tables'') IS NOT NULL DROP TABLE #original_ixp_import_query_builder_tables '
			UNION ALL
			SELECT ' IF OBJECT_ID(''tempdb..#old_ixp_import_query_builder_import_tables'') IS NOT NULL DROP TABLE #old_ixp_import_query_builder_import_tables '			
			UNION ALL
			SELECT ' IF OBJECT_ID(''tempdb..#orginal_ixp_import_query_builder_import_tables'') IS NOT NULL DROP TABLE #orginal_ixp_import_query_builder_import_tables '
			UNION ALL
			SELECT ' IF OBJECT_ID(''tempdb..#old_ixp_custom_import_mapping'') IS NOT NULL DROP TABLE #old_ixp_custom_import_mapping '	
		END
		ELSE IF @import_export_flag = 'e'
		BEGIN
			INSERT INTO #import_final_query(line_query)
			SELECT ' IF OBJECT_ID(''tempdb..#old_relation'') IS NOT NULL DROP TABLE #old_relation '
		END
		
		/* Modified By - Rajiv
		* There is limitation is SSMS which do not allow to paste more than 43679 characters from a column in Grid Mode.
		* The maximum characters retrieved in Grid Mode for non XML data should be 65535 characters.
		* Best solution to display such data is using XML.
		* Result will be displayed as a link. Clicking on link will open XML file, from where query needs to be copied.
		*/
		DECLARE @VeryLongText NVARCHAR(MAX) = '';		
		IF @flag= 'c'	
		BEGIN
		 
			SELECT @VeryLongText = COALESCE(@VeryLongText + CHAR(13) + CHAR(10), '') + ISNULL(line_query, '') FROM  #import_final_query ORDER BY row_id ASC	
									
			exec spa_print @VeryLongText	
			EXEC (@VeryLongText)
			DROP TABLE #import_final_query;
			IF @@ERROR <> 0
				EXEC spa_ErrorHandler @@ERROR,
					 "report",
					 "spa_rfx_export_report",
					 "DB Error",
					 "Error on Inserting on Report paramset.",
					 ''
			ELSE
				EXEC spa_ErrorHandler 0,
					 "report",
					 "spa_rfx_export_report",
					 "Success",
					 "Changes have been saved successfully.",
					 ''
		END
		ELSE  
		BEGIN 
			DECLARE @xml XML
			SET @VeryLongText = NULL                     	
			SELECT @VeryLongText = COALESCE(@VeryLongText + CHAR(13) + CHAR(10), '') + ISNULL(line_query, '') FROM #import_final_query ORDER BY row_id ASC	
						
			SELECT @xml = (SELECT @VeryLongText AS [processing-instruction(x)] FOR XML PATH(''))
			
			INSERT INTO #temp_xml_output
			SELECT @ixp_rules_name, @xml
		END
		
		SET @pos = CHARINDEX(',', @valueList, @pos+@len) +1
	END

	IF ISNULL(@flag, 'e') <> 'c'
	BEGIN
		SELECT rules_name [Rule Name], xml_string [Export Script] FROM #temp_xml_output
	END
END
 
