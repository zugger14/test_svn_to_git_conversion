SET NOCOUNT ON
BEGIN
	BEGIN TRY
		BEGIN TRAN			

		-- To save Old Filter values
		IF OBJECT_ID('tempdb..#temp_old_application_ui_filter') IS NOT NULL
			DROP TABLE #temp_old_application_ui_filter

		IF OBJECT_ID('tempdb..#temp_old_application_ui_filter_details') IS NOT NULL
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
			field_value					VARCHAR(1000) COLLATE DATABASE_DEFAULT ,
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
		WHERE aut.application_function_id = '10101300' AND auf.application_function_id IS NULL
		UNION ALL
		SELECT 
			auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
		FROM
			application_ui_filter auf
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
		WHERE auf.application_function_id = '10101300'  AND auf.application_function_id IS NOT NULL

				
		INSERT INTO  #temp_old_application_ui_filter_details(application_ui_filter_id,application_field_id,field_value,field_id, layout_grid_id, book_level, group_name, layout_cell)
		SELECT 
			aufd.application_ui_filter_id,aufd.application_field_id,aufd.field_value,autd.field_id,aufd.layout_grid_id,aufd.book_level, autg.group_name, ''
		FROM 
			application_ui_filter_details aufd
			INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id
			LEFT JOIN application_ui_template_fields autf ON autf.application_field_id = aufd.application_field_id
			INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			LEFT JOIN application_ui_template_definition AS autd
				ON autd.application_ui_field_id = autf.application_ui_field_id
			WHERE aut.application_function_id = '10101300' AND auf.application_function_id IS NULL
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
			WHERE aut.application_function_id = '10101300' AND auf.application_function_id IS NOT NULL
	
		/*
		RESOLVE UDF values
		It is assumed that sdv.code for UDF once created does not get changed. The same code is used 
		to map UDF values between old and new application_field_id
		*/		
		IF OBJECT_ID('tempdb..#temp_old_maintain_udf_static_data_detail_values') IS NOT NULL
			DROP TABLE #temp_old_maintain_udf_static_data_detail_values

		-- new_field_id, new_fieldset_id
		CREATE TABLE #temp_old_maintain_udf_static_data_detail_values (
			old_application_field_id		INT,
			sdv_code						VARCHAR(200) COLLATE DATABASE_DEFAULT 
		)
			
		IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '10101300')
		BEGIN				
			--Store old_application_field_id from the destination and sdv.code for the UDF
			INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
			SELECT musddv.application_field_id, sdv.code
			FROM maintain_udf_static_data_detail_values musddv
			INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
			INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
			INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
			WHERE autd.application_function_id = '10101300'
				
			-- DELETE SCRIPT STARTS HERE
				
			DELETE autf2 FROM application_ui_template_fieldsets AS autf2
			INNER JOIN application_ui_template_group AS autg ON autf2.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = '10101300'
				
			DELETE aufd FROM application_ui_filter_details aufd
			INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id
			WHERE auf.application_function_id = '10101300'	

			DELETE FROM application_ui_filter WHERE application_function_id = '10101300'
				
			--- START OF NEED TO DISCUSS IF WE NEED THIS SECTION 
			DELETE from application_ui_filter_details where application_ui_filter_id IN (
				SELECT  auf.application_ui_filter_id FROM application_ui_filter auf
				INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10101300'
			)				
			
			DELETE auf FROM application_ui_filter auf
			INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = '10101300'
			--- END OF NEED TO DISCUSS IF WE NEED THIS SECTION 	

			DELETE autf FROM application_ui_template_fields AS autf
			INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = '10101300'
				
			DELETE aulg FROM application_ui_layout_grid AS aulg
			INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = '10101300'
				
			DELETE autg FROM application_ui_template_group AS autg 
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = '10101300'
				
			DELETE autd FROM application_ui_template_definition AS autd
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = autd.application_function_id
			WHERE aut.application_function_id = '10101300'
				
			DELETE FROM application_ui_template
			WHERE application_function_id = '10101300'
				
		END 

		IF OBJECT_ID('tempdb..#temp_all_grids') IS NOT NULL
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
			split_at			VARCHAR(200) COLLATE DATABASE_DEFAULT  
		) 
		INSERT INTO application_ui_template (application_function_id, template_name, template_description, active_flag, default_flag, table_name, is_report, edit_permission, delete_permission, template_type) 
		
		VALUES('10101300',
		'gl_system_mapping',
		'gl_system_mapping',
		'y',
		'y',
		'gl_system_mapping',
		'n',
		'10101310',
		'10101311',
		'102808')

		DECLARE @application_ui_template_id_new INT
		SET @application_ui_template_id_new = SCOPE_IDENTITY() 
		IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '10101300') 
		BEGIN 
		
			IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
				DROP TABLE #temp_new_template_definition 
					
			CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT , field_type VARCHAR(200) COLLATE DATABASE_DEFAULT )
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','','','','settings','',' ',' ','',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_number_id','gl_number_id','GL Number ID','input','int','h','n',NULL,NULL,'y','n','','n','n','y','n','y','y','n','y',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','chart_of_account_name','chart_of_account_name','Account','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=30900',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','chart_of_account_type','chart_of_account_type','Account Type','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=30800',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code_1','gl_code_1','GL Code 1','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=29800',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code_2','gl_code_2','GL Code 2','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=29900',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code_3','gl_code_3','GL Code 3','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=30000',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code_4','gl_code_4','GL Code 4','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=30100',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code_5','gl_code_5','GL Code 5','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=30200',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code_6','gl_code_6','GL Code 6','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=30300',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code_7','gl_code_7','GL Code 7','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=30400',NULL,'n','y','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code_8','gl_code_8','GL Code 8','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=30500',NULL,'n','y','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code_9','gl_code_9','GL Code 9','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=30600',NULL,'n','y','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code_10','gl_code_10','GL Code 10','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=30700',NULL,'n','y','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_account_number','gl_account_number','Account Number','input','varchar','h','n','',NULL,'y','n','','n','n','n','n','y','n','n','n',NULL,NULL,'250')
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_account_name','gl_account_name','Account Name','input','varchar','h','n','',NULL,'n','n','','y','n','n','n','y','n','n','n',NULL,NULL,'250')
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_account_desc1','gl_account_desc1','Description 1','input','varchar','h','n','',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,'250')
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_account_desc2','gl_account_desc2','Description 2','input','varchar','h','n','',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,'250')
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','estimated_actual','estimated_actual','GL Type','combo','varchar','h','n','SELECT ''a'', ''Actual'' UNION ALL SELECT ''e'', ''Estimate'' UNION ALL SELECT ''c'', ''Cash Applied''',NULL,'n','n','e','y','n','n','n','n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','fas_subsidiary_id','fas_subsidiary_id','Subsidiary','combo','varchar','h','n','EXEC get_subsidiaries_for_rights @function_id=10101300',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','is_reversal','is_reversal','Reversal','checkbox','varchar','h','n',NULL,NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','is_active','is_active','Active','checkbox','varchar','h','n',NULL,NULL,'n','n','y','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code1_value_id','gl_code1_value_id','Category 1','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=10004',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code2_value_id','gl_code2_value_id','Category 2','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=10005',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10101300','gl_code3_value_id','gl_code3_value_id','Category 3','combo','varchar','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=10006',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
		END 
	
		IF OBJECT_ID('tempdb..#temp_old_template_group') IS NOT NULL
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
		SELECT 'General',NULL,'y','y','1',NULL,'1C',NULL UNION ALL SELECT 'Details',NULL,'y','n','2',NULL,'1C',NULL
				
		UPDATE totg
		SET totg.new_application_grid_id = tag.new_grid_id
		FROM #temp_old_template_group totg
		INNER JOIN #temp_all_grids tag
		ON tag.old_grid_id = totg.old_application_grid_id
	
		IF OBJECT_ID('tempdb..#temp_new_template_group') IS NOT NULL
			DROP TABLE #temp_new_template_group	
	
		CREATE TABLE #temp_new_template_group (new_id INT, group_name VARCHAR(200) COLLATE DATABASE_DEFAULT )
		
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
		

		IF OBJECT_ID('tempdb..#temp_old_template_fieldsets') IS NOT NULL
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
				
		IF OBJECT_ID('tempdb..#temp_new_template_fieldsets') IS NOT NULL
			DROP TABLE #temp_new_template_fieldsets	
	
		CREATE TABLE #temp_new_template_fieldsets (new_id INT, group_id INT, fieldset_name VARCHAR(200) COLLATE DATABASE_DEFAULT )							
				

				
		INSERT INTO #temp_old_template_fieldsets(old_fieldset_id, old_group_id, group_name, fieldset_name, className, is_disable, is_hidden, inputLeft, inputTop, label, offsetLeft, offsetTop, position, width, sequence, num_column)
		
								SELECT 4599,18237,'General','Chart_of_Account',NULL,'n','n','500','500','Chart of Account',NULL,NULL,NULL,'750','1','3' UNION ALL 
								SELECT 4600,18237,'General','Hierarchy',NULL,'n','n','500','500','Hierarchy',NULL,NULL,NULL,'750','2','3' UNION ALL 
								SELECT 4601,18237,'General','Account',NULL,'n','n','500','500','Account Details',NULL,NULL,NULL,'750','3','3'
				
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
					AND otfs.fieldset_name = ntfs.fieldset_name
	
		IF OBJECT_ID('tempdb..#temp_old_template_fields') IS NOT NULL
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
			validation_message				VARCHAR(200) COLLATE DATABASE_DEFAULT 
		)	
					
		IF OBJECT_ID('tempdb..#temp_new_template_fields') IS NOT NULL
			DROP TABLE #temp_new_template_fields 
					
		CREATE TABLE #temp_new_template_fields (new_field_id INT, new_definition_id INT, sdv_code varchar(200) COLLATE DATABASE_DEFAULT )	
					
		INSERT INTO #temp_old_template_fields(old_field_id, old_group_id, old_application_ui_field_id, old_fieldset_id, group_name, ui_field_id, field_alias, Default_value, default_format, validation_flag, hidden, field_size, field_type, field_id, sequence, inputHeight, udf_template_id, udf_field_name, position, dependent_field, dependent_query, old_grid_id, validation_message)
		
		SELECT 71758,18237,69165,NULL,'General','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71759,18237,69166,NULL,'General','gl_number_id',NULL,'',NULL,NULL,'y',NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71760,18237,69167,'4599','General','chart_of_account_name',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,'chart_of_account_type','EXEC spa_StaticDataValues @flag=''h'', @type_id=30900, @category_id=<chart_of_account_type>',NULL,NULL UNION ALL 
		SELECT 71761,18237,69168,'4599','General','chart_of_account_type',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71762,18237,69169,'4600','General','gl_code_1',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71763,18237,69170,'4600','General','gl_code_2',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71764,18237,69171,'4600','General','gl_code_3',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71765,18237,69172,'4600','General','gl_code_4',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71766,18237,69173,'4600','General','gl_code_5',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71767,18237,69174,'4600','General','gl_code_6',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71768,18237,69175,'4600','General','gl_code_7',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71769,18237,69176,'4600','General','gl_code_8',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71770,18237,69177,'4600','General','gl_code_9',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71771,18237,69178,'4600','General','gl_code_10',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71772,18237,69179,'4601','General','gl_account_number',NULL,'',NULL,NULL,'n',NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Required Field' UNION ALL 
		SELECT 71773,18237,69180,'4601','General','gl_account_name',NULL,'',NULL,NULL,'n',NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Required Field' UNION ALL 
		SELECT 71774,18237,69181,'4601','General','gl_account_desc1',NULL,'',NULL,NULL,'n',NULL,'input',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71775,18237,69182,'4601','General','gl_account_desc2',NULL,'',NULL,NULL,'n',NULL,'input',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71776,18237,69183,'4601','General','estimated_actual',NULL,'e',NULL,NULL,'n',NULL,'combo',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71777,18237,69184,'4601','General','fas_subsidiary_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Required Field' UNION ALL 
		SELECT 71778,18237,69185,'4601','General','is_reversal',NULL,'',NULL,NULL,'n',NULL,'checkbox',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71779,18237,69186,'4601','General','is_active',NULL,'y',NULL,NULL,'n',NULL,'checkbox',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71780,18238,69165,NULL,'Details','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71781,18238,69187,NULL,'Details','gl_code1_value_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71782,18238,69188,NULL,'Details','gl_code2_value_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 71783,18238,69189,NULL,'Details','gl_code3_value_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				
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
		--		ON REPLACE(sdv.code, ' ', '_') = otf.ui_field_id
		--	LEFT JOIN user_defined_fields_template AS udft
		--		ON udft.field_name = sdv.value_id
		--	WHERE otf.udf_field_name IS NOT NULL AND otf.udf_field_name > 0
		--END
				
		INSERT INTO application_ui_template_fields (application_group_id, application_ui_field_id, application_fieldset_id, field_alias, Default_value, default_format, validation_flag, hidden, field_size, field_type, field_id, sequence, inputHeight, udf_template_id, position, dependent_field, dependent_query, grid_id, validation_message) 
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
				otf.validation_message
					    
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
					
	
		IF OBJECT_ID('tempdb..#temp_old_ui_layout') IS NOT NULL
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
		SELECT 15648,18237,'General','a','FORM',NULL,1,'3',NULL,NULL,NULL UNION ALL SELECT 15649,18238,'Details','a','FORM',NULL,1,'3',NULL,NULL,NULL
				
		UPDATE oul
		SET oul.new_group_id = ntg.new_id
		FROM #temp_old_ui_layout oul
		INNER JOIN #temp_new_template_group ntg ON oul.group_name = ntg.group_name
				
		UPDATE oul
		SET oul.new_grid_id = tag.new_grid_id
		FROM #temp_old_ui_layout oul
		INNER JOIN #temp_all_grids tag ON tag.old_grid_id = oul.old_grid_id
		WHERE oul.old_grid_id NOT LIKE 'FORM'
				
		IF OBJECT_ID('tempdb..#temp_new_layout_grid') IS NOT NULL
			DROP TABLE #temp_new_layout_grid 
		CREATE TABLE #temp_new_layout_grid (new_layout_grid_id INT, group_id INT, layout_cell VARCHAR(200) COLLATE DATABASE_DEFAULT )	

		INSERT INTO application_ui_layout_grid (group_id, layout_cell, grid_id, sequence, num_column, cell_height, grid_object_name, grid_object_unique_column) 
		OUTPUT INSERTED.application_ui_layout_grid_id, INSERTED.group_id, INSERTED.layout_cell
			INTO #temp_new_layout_grid (new_layout_grid_id, group_id, layout_cell)
					
		SELECT	oul.new_group_id,
				oul.layout_cell,
				ISNULL(oul.new_grid_id, 'FORM'),
				oul.sequence,
				oul.num_column,
				oul.cell_height,
				oul.grid_object_name,
				oul.grid_object_unique_column
				
		FROM #temp_old_ui_layout oul
					

		-- TO RESOLVE filter values
		IF EXISTS(SELECT 1 FROM #temp_old_application_ui_filter)
		BEGIN
			IF OBJECT_ID('tempdb..#temp_new_filter') IS NOT NULL
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
				tnf.application_ui_filter_id,tntf.new_field_id,toduf.field_value,tlg.new_layout_grid_id,toduf.book_level
			FROM
				#temp_old_application_ui_filter_details toduf
				LEFT JOIN #temp_new_template_definition tntd ON tntd.field_id = toduf.field_id
				LEFT JOIN #temp_old_template_fields ontf ON ontf.ui_field_id  = toduf.field_id
				LEFT JOIN #temp_new_template_fields tntf ON tntf.new_definition_id = tntd.new_definition_id
				LEFT JOIN #temp_old_application_ui_filter tt ON tt.application_ui_filter_id = toduf.application_ui_filter_id
				LEFT JOIN #temp_new_filter tnf ON tnf.application_ui_filter_name = tt.application_ui_filter_name AND tnf.user_login_id = tt.user_login_id
			
			LEFT JOIN #temp_old_ui_layout tolg ON tolg.group_name = toduf.group_name AND tolg.layout_cell = toduf.layout_cell
			LEFT JOIN #temp_new_layout_grid tlg ON tolg.new_group_id = tlg.group_id AND tlg.layout_cell = tolg.layout_cell
		END

		-- To cleanup template audit logs
		EXEC spa_application_ui_template_audit @flag='d', @application_function_id='10101300'
	COMMIT 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
				
		DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @msg_severity INT = ERROR_SEVERITY();
		DECLARE @msg_state INT = ERROR_STATE();

		RAISERROR(@msg, @msg_severity, @msg_state)
					
		--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
	END CATCH
			
	IF OBJECT_ID('tempdb..#temp_xml_output') IS NOT NULL
		DROP TABLE #temp_xml_output
			
	IF OBJECT_ID('tempdb..#temp_final_query') IS NOT NULL
		DROP TABLE #temp_final_query
				
	IF OBJECT_ID('tempdb..#temp_old_application_ui_filter') IS NOT NULL
		DROP TABLE #temp_old_application_ui_filter

	IF OBJECT_ID('tempdb..#temp_old_application_ui_filter_details') IS NOT NULL
		DROP TABLE #temp_old_application_ui_filter_details
				
	IF OBJECT_ID('tempdb..#all_grids') IS NOT NULL
		DROP TABLE #all_grids
			
	IF OBJECT_ID('tempdb..#temp_all_grids') IS NOT NULL
		DROP TABLE #temp_all_grids
                           
	IF OBJECT_ID('tempdb..#temp_all_grids_columns') IS NOT NULL
		DROP TABLE #temp_all_grids_columns
				
	IF OBJECT_ID('tempdb..#temp_old_maintain_udf_static_data_detail_values') IS NOT NULL
		DROP TABLE #temp_old_maintain_udf_static_data_detail_values
			
	IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
		DROP TABLE #temp_new_template_definition
				
	IF OBJECT_ID('tempdb..#temp_old_template_group') IS NOT NULL
		DROP TABLE #temp_old_template_group
			
	IF OBJECT_ID('tempdb..#temp_new_template_group') IS NOT NULL
		DROP TABLE #temp_new_template_group
			
	IF OBJECT_ID('tempdb..#temp_old_template_fieldsets') IS NOT NULL
		DROP TABLE #temp_old_template_fieldsets
				
	IF OBJECT_ID('tempdb..#temp_new_template_fieldsets') IS NOT NULL
		DROP TABLE #temp_new_template_fieldsets
				
	IF OBJECT_ID('tempdb..#temp_old_template_fields') IS NOT NULL
		DROP TABLE #temp_old_template_fields
				
	IF OBJECT_ID('tempdb..#temp_new_template_fields') IS NOT NULL
		DROP TABLE #temp_new_template_fields
				
	IF OBJECT_ID('tempdb..#temp_old_ui_layout') IS NOT NULL
		DROP TABLE #temp_old_ui_layout

	IF OBJECT_ID('tempdb..#temp_new_layout_grid') IS NOT NULL
		DROP TABLE #temp_new_layout_grid
				
	IF OBJECT_ID('tempdb..#temp_new_filter') IS NOT NULL
		DROP TABLE #temp_new_filter
			
END