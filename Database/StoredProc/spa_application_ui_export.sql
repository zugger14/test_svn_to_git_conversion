SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].spa_application_ui_export', N'P ') IS NOT NULL 
	DROP PROCEDURE [dbo].spa_application_ui_export
GO

/**
	Used to generate application UI exports.

	Parameters
	@function_id	:	Application Function ID.
*/

CREATE PROCEDURE [dbo].[spa_application_ui_export]
	@function_id VARCHAR(MAX)
AS

DECLARE @select_statement VARCHAR(MAX)
DECLARE @VeryLongText NVARCHAR(MAX) = '';
DECLARE @xml XML
DECLARE @application_template_name varchar(2000)

SET NOCOUNT ON

BEGIN
	
	IF OBJECT_ID('tempdb..#temp_xml_output') IS NOT NULL
		DROP TABLE #temp_xml_output
	
	CREATE TABLE #temp_xml_output (template_name VARCHAR(400) COLLATE DATABASE_DEFAULT , xml_string XML)
	
	IF OBJECT_ID('tempdb..#temp_final_query') IS NOT NULL
		DROP TABLE #temp_final_query

	CREATE TABLE #temp_final_query (id INT IDENTITY(1,1), final_query VARCHAR(MAX) COLLATE DATABASE_DEFAULT )

	INSERT INTO #temp_final_query(final_query)
	SELECT '
SET NOCOUNT ON
BEGIN
	BEGIN TRY
		BEGIN TRAN			

		-- To save Old Filter values
		IF OBJECT_ID(''tempdb..#temp_old_application_ui_filter'') IS NOT NULL
			DROP TABLE #temp_old_application_ui_filter

		IF OBJECT_ID(''tempdb..#temp_old_application_ui_filter_details'') IS NOT NULL
			DROP TABLE #temp_old_application_ui_filter_details

		CREATE TABLE #temp_old_application_ui_filter (
			application_ui_filter_id	INT,
			application_group_id		INT,
			group_name					VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			user_login_id				VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			application_ui_filter_name	VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			application_function_id		INT
		)

		CREATE TABLE #temp_old_application_ui_filter_details (
			application_ui_filter_id	INT,
			application_field_id		INT,
			field_value					VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			field_id					VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			layout_grid_id				INT,
			book_level					VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			group_name					VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			layout_cell					VARCHAR(10) COLLATE DATABASE_DEFAULT 
		)

		INSERT INTO  #temp_old_application_ui_filter (application_ui_filter_id,application_group_id,group_name,user_login_id,application_ui_filter_name,application_function_id)
		SELECT 
			auf.application_ui_filter_id,auf.application_group_id,autg.group_name,auf.user_login_id,auf.application_ui_filter_name,NULL
		FROM
			application_ui_filter auf
			INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
		WHERE aut.application_function_id = ''' + @function_id + ''' AND auf.application_function_id IS NULL
		UNION ALL
		SELECT 
			auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
		FROM
			application_ui_filter auf
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
		WHERE auf.application_function_id = ''' + @function_id + '''  AND auf.application_function_id IS NOT NULL

				
		INSERT INTO  #temp_old_application_ui_filter_details(application_ui_filter_id,application_field_id,field_value,field_id, layout_grid_id, book_level, group_name, layout_cell)
		SELECT 
			aufd.application_ui_filter_id,aufd.application_field_id,aufd.field_value,autd.field_id,aufd.layout_grid_id,aufd.book_level, autg.group_name, ''''
		FROM 
			application_ui_filter_details aufd
			INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id
			LEFT JOIN application_ui_template_fields autf ON autf.application_field_id = aufd.application_field_id
			INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			LEFT JOIN application_ui_template_definition AS autd
				ON autd.application_ui_field_id = autf.application_ui_field_id
			WHERE aut.application_function_id = ''' + @function_id + ''' AND auf.application_function_id IS NULL
		UNION ALL
		SELECT 
			aufd.application_ui_filter_id,aufd.application_field_id,aufd.field_value,autd.field_id,aufd.layout_grid_id,aufd.book_level, autg.group_name, aulg.layout_cell
		FROM 
			application_ui_filter_details aufd
			INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id
			LEFT JOIN application_ui_template_fields autf ON autf.application_field_id = aufd.application_field_id
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
			LEFT JOIN application_ui_template_definition AS autd
				ON autd.application_ui_field_id = autf.application_ui_field_id
			LEFT JOIN application_ui_layout_grid aulg ON aulg.application_ui_layout_grid_id = aufd.layout_grid_id
			LEFT JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
			WHERE aut.application_function_id = ''' + @function_id + ''' AND auf.application_function_id IS NOT NULL
	
		/*
		RESOLVE UDF values
		It is assumed that sdv.code for UDF once created does not get changed. The same code is used 
		to map UDF values between old and new application_field_id
		*/		
		IF OBJECT_ID(''tempdb..#temp_old_maintain_udf_static_data_detail_values'') IS NOT NULL
			DROP TABLE #temp_old_maintain_udf_static_data_detail_values

		-- new_field_id, new_fieldset_id
		CREATE TABLE #temp_old_maintain_udf_static_data_detail_values (
			old_application_field_id		INT,
			sdv_code						VARCHAR(200) COLLATE DATABASE_DEFAULT 
		)
			
		IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = ''' + @function_id + ''')
		BEGIN				
			--Store old_application_field_id from the destination and sdv.code for the UDF
			INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
			SELECT musddv.application_field_id, sdv.code
			FROM maintain_udf_static_data_detail_values musddv
			INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
			INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
			INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
			WHERE autd.application_function_id = ''' + @function_id + '''
				
			-- DELETE SCRIPT STARTS HERE
				
			EXEC spa_application_ui_template ''d'', ' + @function_id + '
				
		END '
			
	-- adiha_grid_definition
	
	IF OBJECT_ID('tempdb..#all_grids') IS NOT NULL
		DROP TABLE #all_grids
		
	CREATE TABLE #all_grids(
		grid_id				INT,
		grid_name			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		fk_table			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		fk_column			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		load_sql			VARCHAR(800) COLLATE DATABASE_DEFAULT ,
		grid_label			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		grid_type			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		grouping_column		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		edit_permission		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		delete_permission	VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		split_at			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		enable_server_side_paging VARCHAR(1) COLLATE DATABASE_DEFAULT,
		dependent_field VARCHAR(200) COLLATE DATABASE_DEFAULT,
		dependent_query VARCHAR(1000) COLLATE DATABASE_DEFAULT	
	)

	INSERT INTO #all_grids(grid_id, grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission,split_at, enable_server_side_paging, dependent_field, dependent_query)
	SELECT agd.grid_id, agd.grid_name,agd.fk_table,agd.fk_column,agd.load_sql,agd.grid_label,agd.grid_type,agd.grouping_column, agd.edit_permission, agd.delete_permission, agd.split_at, agd.enable_server_side_paging, agd.dependent_field, agd.dependent_query
	FROM application_ui_template_fields AS autf2
	INNER JOIN application_ui_template_group autg
	ON autg.application_group_id = autf2.application_group_id
	INNER JOIN application_ui_template aut
	ON aut.application_ui_template_id = autg.application_ui_template_id
	INNER JOIN adiha_grid_definition AS agd
	ON CAST(agd.grid_id AS VARCHAR(20)) = autf2.grid_id
	WHERE aut.application_function_id = @function_id
	UNION
	SELECT agd.grid_id, agd.grid_name,agd.fk_table,agd.fk_column,agd.load_sql,agd.grid_label,agd.grid_type,agd.grouping_column, agd.edit_permission, agd.delete_permission, agd.split_at, agd.enable_server_side_paging, agd.dependent_field, agd.dependent_query
	FROM application_ui_template_group autg
	INNER JOIN application_ui_template AS aut
	ON autg.application_ui_template_id = aut.application_ui_template_id
	INNER JOIN adiha_grid_definition AS agd
	ON agd.grid_id = autg.application_grid_id
	WHERE aut.application_function_id = @function_id
	UNION
	SELECT agd.grid_id, agd.grid_name,agd.fk_table,agd.fk_column,agd.load_sql,agd.grid_label,agd.grid_type,agd.grouping_column, agd.edit_permission, agd.delete_permission, agd.split_at, agd.enable_server_side_paging, agd.dependent_field, agd.dependent_query
	FROM application_ui_layout_grid AS aulg
	INNER JOIN application_ui_template_group autg
	ON autg.application_group_id = aulg.group_id
	INNER JOIN application_ui_template aut
	ON aut.application_ui_template_id = autg.application_ui_template_id
	INNER JOIN adiha_grid_definition AS agd
	ON CAST(agd.grid_id AS VARCHAR(20)) = aulg.grid_id
	WHERE aut.application_function_id = @function_id
	
	INSERT INTO #temp_final_query(final_query)
	SELECT 
		'
		IF OBJECT_ID(''tempdb..#temp_all_grids'') IS NOT NULL
			DROP TABLE #temp_all_grids

		CREATE TABLE #temp_all_grids (
			old_grid_id			INT,
			new_grid_id			INT,
			grid_name			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			fk_table			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			fk_column			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			load_sql			VARCHAR(800) COLLATE DATABASE_DEFAULT ,
			grid_label			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			grid_type			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			grouping_column		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			is_new				VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			edit_permission		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			delete_permission	VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			split_at			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			enable_server_side_paging VARCHAR(1) COLLATE DATABASE_DEFAULT,
			dependent_field VARCHAR(200) COLLATE DATABASE_DEFAULT,
			dependent_query VARCHAR(1000) COLLATE DATABASE_DEFAULT	
		) '
	
	IF EXISTS(SELECT 1 FROM #all_grids)
	BEGIN
		
		SET @select_statement = NULL
		SELECT @select_statement = 
		COALESCE(@select_statement + ' UNION ALL ', '') + 'SELECT ' + CAST(grid_id AS VARCHAR(100)) + ',''' 
		+ grid_name + ''','
		+ ISNULL('''' + fk_table  + '''', 'NULL') + ',' 
		+ ISNULL('''' + fk_column  + '''', 'NULL') + ',' 
		+ ISNULL('''' + REPLACE(load_sql, '''', '''''') + '''', 'NULL') + ',' 
		+ ISNULL('''' + grid_label  + '''', 'NULL') + ',' 
		+ ISNULL('''' + CAST(grid_type AS VARCHAR(10)) + '''', 'NULL') + ',' 
		+ ISNULL('''' + grouping_column + '''', 'NULL') + ',' 
		+ ISNULL('''' + edit_permission + '''', 'NULL') + ','
		+ ISNULL('''' + delete_permission + '''', 'NULL') + ','
		+ ISNULL('''' + CAST(split_at AS VARCHAR(10)) + '''', 'NULL') + ','
		+ ISNULL('''' + CAST(enable_server_side_paging AS VARCHAR(10)) + '''', 'NULL') + ','
		+ ISNULL('''' + dependent_field + '''', 'NULL') + ','
		+ ISNULL('''' + REPLACE(dependent_query, '''', '''''') + '''', 'NULL') 	
		FROM #all_grids
			
		INSERT INTO #temp_final_query(final_query)
		SELECT '	
				
		INSERT INTO #temp_all_grids(old_grid_id, grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at, enable_server_side_paging, dependent_field, dependent_query)
		' + @select_statement + '
				
		UPDATE tag
		SET tag.new_grid_id = agd.grid_id
		FROM #temp_all_grids tag
		INNER JOIN adiha_grid_definition AS agd
		ON agd.grid_name = tag.grid_name
				
		UPDATE tag
		SET tag.is_new = ''y''
		FROM #temp_all_grids tag
		WHERE tag.new_grid_id IS NULL
				
		IF EXISTS(SELECT 1 FROM #temp_all_grids WHERE is_new LIKE ''y'')
		BEGIN					
			INSERT INTO adiha_grid_definition (grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at, enable_server_side_paging, dependent_field, dependent_query)
			SELECT grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at, enable_server_side_paging, dependent_field, dependent_query
			FROM #temp_all_grids
			WHERE is_new LIKE ''y''
				
		END
			
		IF EXISTS(SELECT 1 FROM #temp_all_grids WHERE is_new IS NULL)
		BEGIN				
			UPDATE agd
			SET
				grid_name = tag.grid_name,
				fk_table = tag.fk_table,
				fk_column = tag.fk_column,
				load_sql = tag.load_sql,
				grid_label = tag.grid_label,
				grid_type = tag.grid_type,
				grouping_column = tag.grouping_column,
				edit_permission = tag.edit_permission,
				delete_permission = tag.delete_permission,
				split_at = tag.split_at,
				enable_server_side_paging = tag.enable_server_side_paging,
				dependent_field = tag.dependent_field,
				dependent_query = tag.dependent_query
			FROM adiha_grid_definition AS agd
			INNER JOIN #temp_all_grids AS tag
			ON tag.new_grid_id = agd.grid_id
				
		END
					
		UPDATE tag
		SET tag.new_grid_id = agd.grid_id
		FROM #temp_all_grids tag
		INNER JOIN adiha_grid_definition AS agd
		ON agd.grid_name = tag.grid_name
					
				'
					
				IF EXISTS(SELECT 1 FROM adiha_grid_columns_definition AS agcd INNER JOIN #all_grids ag ON ag.grid_id = agcd.grid_id)
				BEGIN
						
					SET @select_statement = NULL
	
					SELECT @select_statement = 
		COALESCE(@select_statement + ' UNION ALL ', '') + '
		SELECT ' + CAST(agcd.grid_id AS VARCHAR(10)) + ','''
		+ agcd.column_name + ''',''' 
		+ agcd.column_label + ''',''' 
		+ agcd.field_type + ''',' 	
		+ ISNULL('''' + REPLACE(agcd.sql_string, '''', '''''') + '''', 'NULL') + ',''' 
		+ ISNULL(agcd.is_editable, 'n') + ''','''  
		+ ISNULL(agcd.is_required, 'y') + ''',' 
		+ ISNULL('''' + CAST(agcd.column_order AS VARCHAR(10)) + '''', 'NULL') + ',' 
		+ ISNULL('''' + CAST(agcd.is_hidden AS VARCHAR(10)) + '''', 'NULL') + ',' 
		+ ISNULL('''' + agcd.fk_table  + '''', 'NULL') + ',' 
		+ ISNULL('''' + agcd.fk_column  + '''', 'NULL') + ',' 
		+ ISNULL('''' + CAST(agcd.is_unique AS VARCHAR(10)) + '''', 'NULL') + ','
		+ ISNULL('''' + CAST(agcd.column_width AS VARCHAR(10)) + '''', 'NULL') + ',' 
		+ ISNULL('''' + agcd.sorting_preference  + '''', 'NULL') + ',' 
		+ ISNULL('''' + agcd.validation_rule  + '''', 'NULL') + ','
		+ ISNULL('''' + agcd.column_alignment  + '''', 'NULL') + ', '
		+ ISNULL('''' + CAST(agcd.order_seq_direction AS VARCHAR(10)) + '''', 'NULL') + ','
		+ ISNULL('''' + agcd.browser_grid_id + '''', 'NULL') + ','
		+ ISNULL('''' + CAST(agcd.allow_multi_select AS VARCHAR(10)) + '''', 'NULL') + ','
		+ ISNULL('''' + CAST(agcd.rounding AS VARCHAR(10)) + '''', 'NULL')
					FROM adiha_grid_columns_definition AS agcd
					INNER JOIN #all_grids ag
					ON ag.grid_id = agcd.grid_id

					INSERT INTO #temp_final_query(final_query)
					SELECT '
		IF OBJECT_ID(''tempdb..#temp_all_grids_columns'') IS NOT NULL
			DROP TABLE #temp_all_grids_columns

		CREATE TABLE #temp_all_grids_columns(
			old_grid_id		INT,
			new_grid_id		INT,
			column_name		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			column_label	VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			field_type		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			sql_string		VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
			is_editable		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			is_required		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			column_order	INT,
			is_hidden		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			fk_table		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			fk_column		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			is_unique		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			column_width	VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			sorting_preference VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			validation_rule	VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			column_alignment VARCHAR(200) COLLATE DATABASE_DEFAULT,
			order_seq_direction INT,
			browser_grid_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
			allow_multi_select VARCHAR(200) COLLATE DATABASE_DEFAULT,
			rounding VARCHAR(10) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO #temp_all_grids_columns(old_grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment, order_seq_direction, browser_grid_id, allow_multi_select, rounding)
		' + @select_statement + '

		UPDATE tagc
		SET tagc.new_grid_id = tag.new_grid_id
		FROM #temp_all_grids_columns tagc
		INNER JOIN #temp_all_grids tag
		ON tag.old_grid_id = tagc.old_grid_id
		--WHERE tag.is_new LIKE ''y'']

		DELETE agcd FROM adiha_grid_columns_definition agcd
		INNER JOIN #temp_all_grids tag
		ON agcd.grid_id = tag.new_grid_id

		INSERT INTO adiha_grid_columns_definition(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment, order_seq_direction, browser_grid_id, allow_multi_select, rounding)
		SELECT	tagc.new_grid_id,
				tagc.column_name,
				tagc.column_label,
				tagc.field_type,
				tagc.sql_string,
				tagc.is_editable,
				tagc.is_required,
				tagc.column_order,
				tagc.is_hidden,
				tagc.fk_table,
				tagc.fk_column,
				tagc.is_unique,
				tagc.column_width,
				tagc.sorting_preference,
				tagc.validation_rule,
				tagc.column_alignment,
				tagc.order_seq_direction,
				tagc.browser_grid_id,
				tagc.allow_multi_select,
				tagc.rounding
										
		FROM #temp_all_grids_columns tagc
		INNER JOIN #temp_all_grids tag
		ON tag.old_grid_id = tagc.old_grid_id
		--WHERE tag.is_new LIKE ''y''
		'
				END
					
					
			--INSERT INTO #temp_final_query(final_query)
			--SELECT 'END'
	END
	
	-- application_ui_template

	INSERT INTO #temp_final_query(final_query)
	SELECT '		INSERT INTO application_ui_template (application_function_id, template_name, template_description, active_flag, default_flag, table_name, is_report, edit_permission, delete_permission, template_type) '
	UNION ALL
	SELECT '		
		VALUES(''' + CAST(aut.application_function_id AS VARCHAR(200)) + ''',
		''' + aut.template_name + ''',
		''' + aut.template_description + ''',
		''' + ISNULL(aut.active_flag, 'y') + ''',
		''' + ISNULL(aut.default_flag, 'y') + ''',
		' + ISNULL('''' + aut.table_name + '''', 'NULL') + ',
		' + ISNULL('''' + CAST(aut.is_report AS VARCHAR(10)) + '''', 'NULL') + ',
		' + ISNULL('''' + aut.edit_permission + '''', 'NULL') + ',
		' + ISNULL('''' + aut.delete_permission + '''', 'NULL') + ',
		' + ISNULL('''' + CAST(aut.template_type AS VARCHAR(100)) + '''', 'NULL') + ')'
						
	FROM application_ui_template aut
	WHERE aut.application_function_id = @function_id

	INSERT INTO #temp_final_query(final_query)
	SELECT '
		DECLARE @application_ui_template_id_new INT
		SET @application_ui_template_id_new = SCOPE_IDENTITY() '

	-- application_ui_template_definition

	INSERT INTO #temp_final_query(final_query)
	SELECT '		IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = ''' + @function_id + ''') 
		BEGIN '

	INSERT INTO #temp_final_query(final_query)
	SELECT '		
			IF OBJECT_ID(''tempdb..#temp_new_template_definition'') IS NOT NULL
				DROP TABLE #temp_new_template_definition 
					
			CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT , field_type VARCHAR(200) COLLATE DATABASE_DEFAULT )'

	INSERT INTO #temp_final_query(final_query)
	SELECT '			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES(''' + CAST(autd.application_function_id AS VARCHAR(200)) + ''',' 
						+ ISNULL('''' + autd.field_id  + '''', 'NULL') + ','''
						 + autd.farrms_field_id + ''',''' 
						+ autd.default_label +  ''',''' 
						+ autd.field_type +  ''',''' 
						+ autd.data_type +  ''',''' 
						+ ISNULL(autd.header_detail, 'h') + ''',''' 
						+ ISNULL(autd.system_required, 'n') + ''','
						 + ISNULL('''' + REPLACE(autd.sql_string, '''', '''''') + '''', 'NULL') + ','
						 + ISNULL('''' + CAST(autd.field_size AS VARCHAR(10)) + '''', 'NULL') + ','''
						 + ISNULL(autd.is_disable, 'n') + ''',''' 
						+ ISNULL(autd.is_hidden, 'n') + ''',' 
						+ ISNULL('''' + autd.default_value  + '''', 'NULL') + ',''' 
						+ ISNULL(autd.insert_required, 'n') + ''',''' 
						+ ISNULL(autd.data_flag, 'n') + ''',' 
						+ ISNULL('''' + CAST(autd.update_required AS VARCHAR(10)) + '''', 'NULL') + ',' 
						+ ISNULL('''' + CAST(autd.has_round_option AS VARCHAR(10)) + '''', 'NULL') + ',''' 
						+ ISNULL(autd.blank_option, 'n') + ''',''' 
						+ ISNULL(autd.is_primary, 'n') + ''',''' 
						+ ISNULL(autd.is_udf, 'n') + ''',''' 
						+ ISNULL(autd.is_identity, 'n')+ ''','
						+ ISNULL('''' + CAST(autd.text_row_num AS VARCHAR(10)) + '''', 'NULL')+ ','
						+ ISNULL('''' + REPLACE(autd.hyperlink_function, '''', '''''') + '''', 'NULL')+ ','
						+ ISNULL('''' + REPLACE(autd.char_length, '''', '''''') + '''', 'NULL') + ','
						+ ISNULL('''' + REPLACE(autd.open_ui_function_id, '''', '''''') + '''', 'NULL')
						+  ')
						'
						
	FROM application_ui_template_definition AS autd
	WHERE autd.application_function_id = @function_id

	INSERT INTO #temp_final_query(final_query)
	SELECT '		END '

	-- application_ui_template_group
	
	SET @select_statement = NULL
	SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + 'SELECT ''' + autg.group_name + ''',' 
		+ ISNULL('''' + autg.group_description  + '''', 'NULL') + ',''' 
		+ ISNULL(autg.active_flag, 'y') + ''',''' 
		+ ISNULL(autg.default_flag, 'y') + ''',' 
		+ ISNULL('''' + CAST(autg.sequence AS VARCHAR(10)) + '''', 'NULL') + ',' 
		+ ISNULL('''' + CAST(autg.inputWidth AS VARCHAR(10)) + '''', 'NULL') + ',' 
		+ ISNULL('''' + CAST(autg.field_layout AS VARCHAR(10)) + '''', 'NULL') + ',' 
		+ ISNULL('''' + CAST(autg.application_grid_id AS VARCHAR(10)) + '''', 'NULL')
	FROM application_ui_template_group AS autg
	INNER JOIN application_ui_template aut
	ON aut.application_ui_template_id = autg.application_ui_template_id
	WHERE aut.application_function_id = @function_id

	INSERT INTO #temp_final_query(final_query)
	SELECT '	
		IF OBJECT_ID(''tempdb..#temp_old_template_group'') IS NOT NULL
			DROP TABLE #temp_old_template_group

		CREATE TABLE #temp_old_template_group (
			application_ui_template_id	INT,
			group_name					VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			group_description			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			active_flag					VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			default_flag				VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			sequence					INT,
			inputWidth					INT,
			field_layout				VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			old_application_grid_id		INT,
			new_application_grid_id		INT
		)	
				
		INSERT INTO #temp_old_template_group(group_name, group_description, active_flag, default_flag, sequence, inputWidth, field_layout, old_application_grid_id)
		' + @select_statement + '
				
		UPDATE totg
		SET totg.new_application_grid_id = tag.new_grid_id
		FROM #temp_old_template_group totg
		INNER JOIN #temp_all_grids tag
		ON tag.old_grid_id = totg.old_application_grid_id
	
		IF OBJECT_ID(''tempdb..#temp_new_template_group'') IS NOT NULL
			DROP TABLE #temp_new_template_group	
	
		CREATE TABLE #temp_new_template_group (new_id INT, group_name VARCHAR(200) COLLATE DATABASE_DEFAULT )'
	INSERT INTO #temp_final_query(final_query)
	SELECT '		
		INSERT INTO application_ui_template_group (application_ui_template_id, group_name, group_description, active_flag, default_flag, sequence, inputWidth, field_layout, application_grid_id) 
		OUTPUT INSERTED.application_group_id, INSERTED.group_name
		INTO #temp_new_template_group (new_id, group_name)
		SELECT @application_ui_template_id_new, 
				totg.group_name, 
				totg.group_description, 
				totg.active_flag, 
				totg.default_flag, 
				totg.sequence, 
				totg.inputWidth, 
				totg.field_layout, 
				ISNULL(totg.new_application_grid_id, NULL)			
				
	    FROM #temp_old_template_group AS totg
		'

	-- application_ui_template_fieldsets

	SET @select_statement = NULL
	SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
								SELECT ' + CAST(autfs.application_fieldset_id AS VARCHAR(100)) + ',' + CAST(autg.application_group_id AS VARCHAR(20)) + ',''' + autg.group_name + '''' + ',''' + autfs.fieldset_name + ''',' + ISNULL('''' + autfs.className  + '''', 'NULL') + ',''' + ISNULL(autfs.is_disable, 'n') + ''',''' + ISNULL(autfs.is_hidden, 'n') + ''',' + ISNULL('''' + CAST(autfs.inputLeft AS VARCHAR(10)) + '''', 'NULL') + ',' + ISNULL('''' + CAST(autfs.inputTop AS VARCHAR(10)) + '''', 'NULL') + ',''' + autfs.label + ''',' + ISNULL('''' + CAST(autfs.offsetLeft AS VARCHAR(10)) + '''', 'NULL') + ',' + ISNULL('''' + CAST(autfs.offsetTop AS VARCHAR(10)) + '''', 'NULL') + ',' + ISNULL('''' + autfs.position  + '''', 'NULL') + ',' + ISNULL('''' + CAST(autfs.width AS VARCHAR(10)) + '''', 'NULL') + ',' + ISNULL('''' + CAST(autfs.sequence AS VARCHAR(10)) + '''', 'NULL') + ',' + ISNULL('''' + CAST(autfs.num_column AS VARCHAR(10)) + '''', 'NULL')
	FROM application_ui_template aut 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id = aut.application_ui_template_id
	INNER JOIN application_ui_template_fieldsets autfs ON autfs.application_group_id = autg.application_group_id
	WHERE aut.application_function_id = @function_id
		
	INSERT INTO #temp_final_query(final_query)
	SELECT '
		IF OBJECT_ID(''tempdb..#temp_old_template_fieldsets'') IS NOT NULL
			DROP TABLE #temp_old_template_fieldsets

		CREATE TABLE #temp_old_template_fieldsets (
			old_fieldset_id		INT,
			new_fieldset_id     INT,
			old_group_id        INT,
			new_group_id        INT,
			group_name          VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			fieldset_name		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			className			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			is_disable			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			is_hidden			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			inputLeft			INT,
			inputTop			INT,
			label				VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			offsetLeft			INT,
			offsetTop			INT,
			position			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			width				INT,
			sequence			INT,
			num_column			INT
		)
				
		IF OBJECT_ID(''tempdb..#temp_new_template_fieldsets'') IS NOT NULL
			DROP TABLE #temp_new_template_fieldsets	
	
		CREATE TABLE #temp_new_template_fieldsets (new_id INT, group_id INT, fieldset_name VARCHAR(200) COLLATE DATABASE_DEFAULT )							
				'
		IF @select_statement IS NOT NULL
		BEGIN
				
			INSERT INTO #temp_final_query(final_query)
			SELECT '
				
		INSERT INTO #temp_old_template_fieldsets(old_fieldset_id, old_group_id, group_name, fieldset_name, className, is_disable, is_hidden, inputLeft, inputTop, label, offsetLeft, offsetTop, position, width, sequence, num_column)
		' + @select_statement + '
				
		UPDATE otfs
		SET otfs.new_group_id = ntg.new_id
		FROM #temp_old_template_fieldsets otfs
		INNER JOIN #temp_new_template_group ntg ON otfs.group_name = ntg.group_name
			
				
		INSERT INTO application_ui_template_fieldsets (application_group_id, fieldset_name, className, is_disable, is_hidden, inputLeft, inputTop, label, offsetLeft, offsetTop, position, width, sequence, num_column) 
		OUTPUT INSERTED.application_fieldset_id, INSERTED.application_group_id, [inserted].fieldset_name
		INTO #temp_new_template_fieldsets (new_id, group_id, fieldset_name)

		SELECT  otfs.new_group_id, 
				otfs.fieldset_name,
				otfs.className,
				otfs.is_disable,
				otfs.is_hidden,
				otfs.inputLeft,
				otfs.inputTop,
				otfs.label,
				otfs.offsetLeft,
				otfs.offsetTop,
				otfs.position,
				otfs.width,
				otfs.sequence,
				otfs.num_column
		FROM #temp_old_template_fieldsets otfs 
					
		UPDATE otfs
		SET    otfs.new_fieldset_id = ntfs.new_id
		FROM   #temp_new_template_fieldsets ntfs
				INNER JOIN #temp_old_template_fieldsets otfs
					ON  otfs.new_group_id = ntfs.group_id
					AND otfs.fieldset_name = ntfs.fieldset_name'
	END


	-- application_ui_template_fields
		
	SET @select_statement = NULL
	SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
		SELECT ' + CAST(autf.application_field_id AS VARCHAR(100)) + ',' + CAST(autg.application_group_id AS VARCHAR(20)) + ',' + CAST(autd.application_ui_field_id AS VARCHAR(20)) + ',' + ISNULL('''' + CAST(autf.application_fieldset_id AS VARCHAR(10)) + '''', 'NULL') + ',''' + autg.group_name + '''' + ',' + ISNULL('''' + CAST(autd.field_id AS VARCHAR(100)) + '''', 'NULL') + ',' + ISNULL('''' + autf.field_alias  + '''', 'NULL') + ',' + ISNULL('''' + autf.Default_value  + '''', 'NULL') + ',' + ISNULL('''' + autf.default_format  + '''', 'NULL') + ',' + ISNULL('''' + CAST(autf.validation_flag AS VARCHAR(10)) + '''', 'NULL') + ',' + ISNULL('''' + CAST(autf.hidden AS VARCHAR(10)) + '''', 'NULL') + ',' + ISNULL('''' + CAST(autf.field_size AS VARCHAR(10)) + '''', 'NULL') + ',' + ISNULL('''' + autf.field_type  + '''', 'NULL') + ',' + ISNULL('''' + autf.field_id  + '''', 'NULL') + ',' + ISNULL('''' + CAST(autf.sequence AS VARCHAR(10)) + '''', 'NULL') + ',' + ISNULL('''' + CAST(autf.inputHeight AS VARCHAR(10)) + '''', 'NULL') + ',' + ISNULL('''' + CAST(autf.udf_template_id AS VARCHAR(10)) + '''', 'NULL') + ',' + ISNULL('''' + CAST(udft.field_name AS VARCHAR(100)) + '''', 'NULL') + ',' + ISNULL('''' + autf.position  + '''', 'NULL') + ',' + ISNULL('''' + autf.dependent_field  + '''', 'NULL') + ',' + ISNULL('''' + REPLACE(autf.dependent_query, '''', '''''') + '''', 'NULL') + ',' + ISNULL('''' + autf.grid_id  + '''', 'NULL') + ',' + ISNULL('''' + CAST(autf.validation_message AS VARCHAR(200)) + '''', 'NULL') + ',' + ISNULL('''' + CAST(autf.load_child_without_parent AS VARCHAR(10)) + '''', 'NULL')
	FROM application_ui_template aut 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id = aut.application_ui_template_id
	INNER JOIN application_ui_template_fields autf ON autf.application_group_id = autg.application_group_id
	LEFT JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
	LEFT JOIN user_defined_fields_template AS udft ON autf.udf_template_id = udft.udf_template_id
	WHERE aut.application_function_id = @function_id


	IF @select_statement IS NOT NULL
	BEGIN
	
		INSERT INTO #temp_final_query(final_query)
		SELECT '	
		IF OBJECT_ID(''tempdb..#temp_old_template_fields'') IS NOT NULL
			DROP TABLE #temp_old_template_fields

		-- new_field_id, new_fieldset_id
		CREATE TABLE #temp_old_template_fields (
			old_field_id					INT,
			old_group_id					INT,
			new_group_id					INT,
			old_application_ui_field_id		INT,
			new_application_ui_field_id		INT,
			old_fieldset_id					INT,
			group_name						VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			ui_field_id						VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			field_alias						VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			Default_value					VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			default_format					VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			validation_flag					VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			hidden							VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			field_size						VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			field_type						VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			field_id						VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			sequence						INT,
			inputHeight						VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			udf_template_id					INT,
			udf_field_name					INT,
			position						VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			dependent_field					VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			dependent_query					VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			old_grid_id						VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			new_grid_id						VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			validation_message				VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			load_child_without_parent		BIT
		)	
					
		IF OBJECT_ID(''tempdb..#temp_new_template_fields'') IS NOT NULL
			DROP TABLE #temp_new_template_fields 
					
		CREATE TABLE #temp_new_template_fields (new_field_id INT, new_definition_id INT, sdv_code varchar(200) COLLATE DATABASE_DEFAULT )	
					
		INSERT INTO #temp_old_template_fields(old_field_id, old_group_id, old_application_ui_field_id, old_fieldset_id, group_name, ui_field_id, field_alias, Default_value, default_format, validation_flag, hidden, field_size, field_type, field_id, sequence, inputHeight, udf_template_id, udf_field_name, position, dependent_field, dependent_query, old_grid_id, validation_message, load_child_without_parent)
		' + @select_statement + '
				
		UPDATE otf
		SET otf.new_group_id = ntg.new_id
		FROM #temp_old_template_fields otf
		INNER JOIN #temp_new_template_group ntg ON otf.group_name = ntg.group_name
				
		UPDATE otf
		SET otf.new_application_ui_field_id = ntd.new_definition_id
		FROM #temp_old_template_fields otf
		INNER JOIN #temp_new_template_definition ntd ON otf.ui_field_id = ntd.field_id and otf.field_type = ntd.field_type
				
		UPDATE otf
		SET otf.new_grid_id = tag.new_grid_id
		FROM #temp_old_template_fields otf
		INNER JOIN #temp_all_grids tag ON otf.old_grid_id = CAST(tag.old_grid_id AS VARCHAR(20))
					
		--The commented code does not seem to be in use
		--IF EXISTS(SELECT 1 FROM #temp_old_template_fields otf WHERE otf.udf_field_name IS NOT NULL AND otf.udf_field_name > 0)
		--BEGIN
		--	UPDATE otf
		--	SET otf.udf_field_name = udft.field_name
		--	FROM #temp_old_template_fields otf
		--	INNER JOIN static_data_value AS sdv
		--		ON REPLACE(sdv.code, '' '', ''_'') = otf.ui_field_id
		--	LEFT JOIN user_defined_fields_template AS udft
		--		ON udft.field_name = sdv.value_id
		--	WHERE otf.udf_field_name IS NOT NULL AND otf.udf_field_name > 0
		--END
				
		INSERT INTO application_ui_template_fields (application_group_id, application_ui_field_id, application_fieldset_id, field_alias, Default_value, default_format, validation_flag, hidden, field_size, field_type, field_id, sequence, inputHeight, udf_template_id, position, dependent_field, dependent_query, grid_id, validation_message, load_child_without_parent) 
		OUTPUT INSERTED.application_field_id, INSERTED.application_ui_field_id
		INTO #temp_new_template_fields (new_field_id, new_definition_id)
		SELECT  otf.new_group_id,
				new_application_ui_field_id,
				ISNULL(autfs.application_fieldset_id, NULL),
				otf.field_alias,
				otf.Default_value,
				otf.default_format,
				otf.validation_flag,
				otf.hidden,
				otf.field_size,
				otf.field_type,
				otf.field_id,
				otf.sequence,
				otf.inputHeight,
				ISNULL(udft.udf_template_id, NULL),
				otf.position,
				otf.dependent_field,
				otf.dependent_query,
				ISNULL(otf.new_grid_id, otf.old_grid_id),
				otf.validation_message,
				otf.load_child_without_parent
					    
		FROM #temp_old_template_fields otf
		LEFT JOIN #temp_old_template_fieldsets otfs ON otfs.old_fieldset_id = otf.old_fieldset_id
		LEFT JOIN application_ui_template_fieldsets autfs ON autfs.application_group_id = otfs.new_group_id
				AND autfs.application_fieldset_id = otfs.new_fieldset_id
		LEFT JOIN user_defined_fields_template udft ON otf.udf_field_name = udft.field_name					
					
		-- TO RESOLVE APPLICATION_FIELD_ID IN maintain_udf_static_data_detail_values
		IF EXISTS(SELECT 1 FROM #temp_old_maintain_udf_static_data_detail_values)
		BEGIN
			--get the static data value (code) of the UDFs in the destination field. This code (assuming it is not changed)
			--will map old application_field_id with new application_field_id
			UPDATE ntf
			SET ntf.sdv_code = sdv.code
			FROM #temp_new_template_fields ntf
			INNER JOIN application_ui_template_fields autf ON autf.application_field_id = ntf.new_field_id
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
			INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
						
			UPDATE musddv
			SET musddv.application_field_id = ntf.new_field_id
			FROM maintain_udf_static_data_detail_values musddv
			INNER JOIN #temp_old_maintain_udf_static_data_detail_values omusddv
				ON omusddv.old_application_field_id = musddv.application_field_id
			INNER JOIN #temp_new_template_fields ntf
				ON ntf.sdv_code = omusddv.sdv_code
		END	
					'
	END

	-- application_ui_layout_grid
	
	SET @select_statement = NULL
	SELECT @select_statement = 
		COALESCE(@select_statement + ' UNION ALL ', '') + 'SELECT ' + CAST(aulg.application_ui_layout_grid_id AS VARCHAR(100)) + ','
		+ CAST(aulg.group_id AS VARCHAR(100)) + ',''' 
		+ autg.group_name + ''',''' 
		+ aulg.layout_cell + ''','
		+ ISNULL('''' + CAST(aulg.grid_id AS VARCHAR(10)) + '''', 'NULL') + ','
		+ ISNULL('''' + agd.grid_name + '''', 'NULL') + ','
		+ CAST(aulg.sequence AS VARCHAR(10))+ ',' 
		+ ISNULL('''' + CAST(aulg.num_column AS VARCHAR(10)) + '''', 'NULL')+ ','
		+ ISNULL('''' + CAST(aulg.cell_height AS VARCHAR(10)) + '''', 'NULL') + ','
		+ ISNULL('''' + CAST(aulg.grid_object_name AS VARCHAR(200)) + '''', 'NULL') + ','
		+ ISNULL('''' + CAST(aulg.grid_object_unique_column AS VARCHAR(200)) + '''', 'NULL')
	FROM application_ui_layout_grid AS aulg
	INNER JOIN application_ui_template_group autg
	ON autg.application_group_id = aulg.group_id
	INNER JOIN application_ui_template aut
	ON aut.application_ui_template_id = autg.application_ui_template_id
	LEFT JOIN adiha_grid_definition agd
	ON aulg.grid_id = CAST(agd.grid_id AS VARCHAR(10))
	WHERE aut.application_function_id = @function_id
	
	IF @select_statement IS NOT NULL
	BEGIN
	
		INSERT INTO #temp_final_query(final_query)
		SELECT '	
		IF OBJECT_ID(''tempdb..#temp_old_ui_layout'') IS NOT NULL
			DROP TABLE #temp_old_ui_layout

		CREATE TABLE #temp_old_ui_layout (
			old_layout_grid_id	INT,
			old_group_id		INT,
			new_group_id		INT,
			group_name			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			layout_cell			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			old_grid_id			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			new_grid_id			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			grid_name			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			sequence			INT,
			num_column			INT,
			cell_height			INT,
			grid_object_name	VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			grid_object_unique_column	VARCHAR(100) COLLATE DATABASE_DEFAULT 
		)	
					
		INSERT INTO #temp_old_ui_layout(old_layout_grid_id, old_group_id, group_name, layout_cell, old_grid_id, grid_name, sequence, num_column, cell_height,grid_object_name,grid_object_unique_column)
		' + @select_statement + '
				
		UPDATE oul
		SET oul.new_group_id = ntg.new_id
		FROM #temp_old_ui_layout oul
		INNER JOIN #temp_new_template_group ntg ON oul.group_name = ntg.group_name
				
		UPDATE oul
		SET oul.new_grid_id = tag.new_grid_id
		FROM #temp_old_ui_layout oul
		INNER JOIN #temp_all_grids tag ON tag.old_grid_id = oul.old_grid_id
		WHERE oul.old_grid_id NOT LIKE ''FORM''
				
		IF OBJECT_ID(''tempdb..#temp_new_layout_grid'') IS NOT NULL
			DROP TABLE #temp_new_layout_grid 
		CREATE TABLE #temp_new_layout_grid (new_layout_grid_id INT, group_id INT, layout_cell VARCHAR(200) COLLATE DATABASE_DEFAULT )	

		INSERT INTO application_ui_layout_grid (group_id, layout_cell, grid_id, sequence, num_column, cell_height, grid_object_name, grid_object_unique_column) 
		OUTPUT INSERTED.application_ui_layout_grid_id, INSERTED.group_id, INSERTED.layout_cell
			INTO #temp_new_layout_grid (new_layout_grid_id, group_id, layout_cell)
					
		SELECT	oul.new_group_id,
				oul.layout_cell,
				ISNULL(oul.new_grid_id, ''FORM''),
				oul.sequence,
				oul.num_column,
				oul.cell_height,
				oul.grid_object_name,
				oul.grid_object_unique_column
				
		FROM #temp_old_ui_layout oul
					'
	END
		
	DECLARE @sql VARCHAR(4000)
	SET @sql = '
		-- TO RESOLVE filter values
		IF EXISTS(SELECT 1 FROM #temp_old_application_ui_filter)
		BEGIN
			IF OBJECT_ID(''tempdb..#temp_new_filter'') IS NOT NULL
				DROP TABLE #temp_new_filter 
			CREATE TABLE #temp_new_filter(application_ui_filter_id INT,application_ui_filter_name VARCHAR(100) COLLATE DATABASE_DEFAULT ,user_login_id VARCHAR(100) COLLATE DATABASE_DEFAULT )

			INSERT INTO application_ui_filter(application_group_id,user_login_id,application_ui_filter_name,application_function_id)
			OUTPUT INSERTED.application_ui_filter_id, INSERTED.application_ui_filter_name,INSERTED.user_login_id
			INTO #temp_new_filter (application_ui_filter_id, application_ui_filter_name,user_login_id)
			SELECT 
				tntg.new_id,toduf.user_login_id,toduf.application_ui_filter_name,toduf.application_function_id
			FROM
				#temp_old_application_ui_filter toduf
				LEFT JOIN #temp_new_template_group tntg ON tntg.group_name = toduf.group_name

			INSERT INTO application_ui_filter_details(application_ui_filter_id,application_field_id,field_value,layout_grid_id,book_level)
			SELECT 
				tnf.application_ui_filter_id,tntf.new_field_id,toduf.field_value,' + CASE WHEN @select_statement IS NOT NULL THEN 'tlg.new_layout_grid_id' ELSE 'NULL' END + ',toduf.book_level
			FROM
				#temp_old_application_ui_filter_details toduf
				LEFT JOIN #temp_new_template_definition tntd ON tntd.field_id = toduf.field_id
				LEFT JOIN #temp_old_template_fields ontf ON ontf.ui_field_id  = toduf.field_id
				LEFT JOIN #temp_new_template_fields tntf ON tntf.new_definition_id = tntd.new_definition_id
				LEFT JOIN #temp_old_application_ui_filter tt ON tt.application_ui_filter_id = toduf.application_ui_filter_id
				LEFT JOIN #temp_new_filter tnf ON tnf.application_ui_filter_name = tt.application_ui_filter_name AND tnf.user_login_id = tt.user_login_id
			'
	IF @select_statement IS NOT NULL
		SET @sql += '
			LEFT JOIN #temp_old_ui_layout tolg ON tolg.group_name = toduf.group_name AND tolg.layout_cell = toduf.layout_cell
			LEFT JOIN #temp_new_layout_grid tlg ON tolg.new_group_id = tlg.group_id AND tlg.layout_cell = tolg.layout_cell
		'
	SET @sql += 'END'

	INSERT INTO #temp_final_query(final_query)
	SELECT @sql
	
	INSERT INTO #temp_final_query(final_query)
	SELECT  '
		-- To cleanup template audit logs
		EXEC spa_application_ui_template_audit @flag=''d'', @application_function_id=''' + @function_id + '''
	COMMIT 
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
			
	IF OBJECT_ID(''tempdb..#temp_xml_output'') IS NOT NULL
		DROP TABLE #temp_xml_output
			
	IF OBJECT_ID(''tempdb..#temp_final_query'') IS NOT NULL
		DROP TABLE #temp_final_query
				
	IF OBJECT_ID(''tempdb..#temp_old_application_ui_filter'') IS NOT NULL
		DROP TABLE #temp_old_application_ui_filter

	IF OBJECT_ID(''tempdb..#temp_old_application_ui_filter_details'') IS NOT NULL
		DROP TABLE #temp_old_application_ui_filter_details
				
	IF OBJECT_ID(''tempdb..#all_grids'') IS NOT NULL
		DROP TABLE #all_grids
			
	IF OBJECT_ID(''tempdb..#temp_all_grids'') IS NOT NULL
		DROP TABLE #temp_all_grids
                           
	IF OBJECT_ID(''tempdb..#temp_all_grids_columns'') IS NOT NULL
		DROP TABLE #temp_all_grids_columns
				
	IF OBJECT_ID(''tempdb..#temp_old_maintain_udf_static_data_detail_values'') IS NOT NULL
		DROP TABLE #temp_old_maintain_udf_static_data_detail_values
			
	IF OBJECT_ID(''tempdb..#temp_new_template_definition'') IS NOT NULL
		DROP TABLE #temp_new_template_definition
				
	IF OBJECT_ID(''tempdb..#temp_old_template_group'') IS NOT NULL
		DROP TABLE #temp_old_template_group
			
	IF OBJECT_ID(''tempdb..#temp_new_template_group'') IS NOT NULL
		DROP TABLE #temp_new_template_group
			
	IF OBJECT_ID(''tempdb..#temp_old_template_fieldsets'') IS NOT NULL
		DROP TABLE #temp_old_template_fieldsets
				
	IF OBJECT_ID(''tempdb..#temp_new_template_fieldsets'') IS NOT NULL
		DROP TABLE #temp_new_template_fieldsets
				
	IF OBJECT_ID(''tempdb..#temp_old_template_fields'') IS NOT NULL
		DROP TABLE #temp_old_template_fields
				
	IF OBJECT_ID(''tempdb..#temp_new_template_fields'') IS NOT NULL
		DROP TABLE #temp_new_template_fields
				
	IF OBJECT_ID(''tempdb..#temp_old_ui_layout'') IS NOT NULL
		DROP TABLE #temp_old_ui_layout

	IF OBJECT_ID(''tempdb..#temp_new_layout_grid'') IS NOT NULL
		DROP TABLE #temp_new_layout_grid
				
	IF OBJECT_ID(''tempdb..#temp_new_filter'') IS NOT NULL
		DROP TABLE #temp_new_filter
			
	DECLARE @memcache_key			NVARCHAR(1000)
		, @db					NVARCHAR(200) = db_name()
	SELECT @memcache_key = CASE WHEN aut.is_report = ''y'' 
							THEN @db + ''_RptList'' + '','' + @db + ''_RptStd_'' + ''' + @function_id + '''  
							ELSE @db + ''_UI_'' + ''' + @function_id + '''
						END 
	FROM application_ui_template AS aut
	WHERE aut.application_function_id = ' + @function_id + '
		 	
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N''[dbo].[spa_manage_memcache]'') AND TYPE IN (N''P'', N''PC''))
	BEGIN
		EXEC [spa_manage_memcache] @flag = ''d'', @key_prefix = @memcache_key, @cmbobj_key_source = NULL, @other_key_source=NULL, @source_object = ''spa_application_ui_export''
	END
	
END '
	
	SELECT @application_template_name = aut.template_name
	FROM application_ui_template AS aut
	WHERE aut.application_function_id = @function_id
	                 	
	SELECT @VeryLongText = COALESCE(@VeryLongText + CHAR(13) + CHAR(10), '') + ISNULL(final_query, '') FROM #temp_final_query ORDER BY id ASC	
						
	SELECT @xml = (SELECT @VeryLongText AS [processing-instruction(x)] FOR XML PATH(''))
			
	INSERT INTO #temp_xml_output
	SELECT @application_template_name, @xml

	SELECT template_name [Template Name], xml_string [Export Script] FROM #temp_xml_output

	--SELECT final_query FROM #temp_final_query
	--ORDER BY id
	
END
GO