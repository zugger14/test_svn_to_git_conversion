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
			group_name					VARCHAR(100) COLLATE DATABASE_DEFAULT,
			user_login_id				VARCHAR(100) COLLATE DATABASE_DEFAULT,
			application_ui_filter_name	VARCHAR(100) COLLATE DATABASE_DEFAULT,
			application_function_id		INT
		)

		CREATE TABLE #temp_old_application_ui_filter_details (
			application_ui_filter_id	INT,
			application_field_id		INT,
			field_value					VARCHAR(1000) COLLATE DATABASE_DEFAULT,
			field_id					VARCHAR(100) COLLATE DATABASE_DEFAULT,
			layout_grid_id				INT,
			book_level					VARCHAR(20) COLLATE DATABASE_DEFAULT,
			group_name					VARCHAR(100) COLLATE DATABASE_DEFAULT,
			layout_cell					VARCHAR(10) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO  #temp_old_application_ui_filter (application_ui_filter_id,application_group_id,group_name,user_login_id,application_ui_filter_name,application_function_id)
		SELECT 
			auf.application_ui_filter_id,auf.application_group_id,autg.group_name,auf.user_login_id,auf.application_ui_filter_name,NULL
		FROM
			application_ui_filter auf
			INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
		WHERE aut.application_function_id = '14121400' AND auf.application_function_id IS NULL
		UNION ALL
		SELECT 
			auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
		FROM
			application_ui_filter auf
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
		WHERE auf.application_function_id = '14121400'  AND auf.application_function_id IS NOT NULL

				
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
			WHERE aut.application_function_id = '14121400' AND auf.application_function_id IS NULL
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
			WHERE aut.application_function_id = '14121400' AND auf.application_function_id IS NOT NULL
	
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
			
		IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '14121400')
		BEGIN				
			--Store old_application_field_id from the destination and sdv.code for the UDF
			INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
			SELECT musddv.application_field_id, sdv.code
			FROM maintain_udf_static_data_detail_values musddv
			INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
			INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
			INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
			WHERE autd.application_function_id = '14121400'
				
			-- DELETE SCRIPT STARTS HERE
				
			DELETE autf2 FROM application_ui_template_fieldsets AS autf2
			INNER JOIN application_ui_template_group AS autg ON autf2.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = '14121400'
				
			DELETE aufd FROM application_ui_filter_details aufd
			INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id
			WHERE auf.application_function_id = '14121400'	

			DELETE FROM application_ui_filter WHERE application_function_id = '14121400'
				
			--- START OF NEED TO DISCUSS IF WE NEED THIS SECTION 
			DELETE from application_ui_filter_details where application_ui_filter_id IN (
				SELECT  auf.application_ui_filter_id FROM application_ui_filter auf
				INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '14121400'
			)				
			
			DELETE auf FROM application_ui_filter auf
			INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = '14121400'
			--- END OF NEED TO DISCUSS IF WE NEED THIS SECTION 	

			DELETE autf FROM application_ui_template_fields AS autf
			INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = '14121400'
				
			DELETE aulg FROM application_ui_layout_grid AS aulg
			INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = '14121400'
				
			DELETE autg FROM application_ui_template_group AS autg 
			INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
			WHERE aut.application_function_id = '14121400'
				
			DELETE autd FROM application_ui_template_definition AS autd
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = autd.application_function_id
			WHERE aut.application_function_id = '14121400'
				
			DELETE FROM application_ui_template
			WHERE application_function_id = '14121400'
				
		END 

		IF OBJECT_ID('tempdb..#temp_all_grids') IS NOT NULL
			DROP TABLE #temp_all_grids

		CREATE TABLE #temp_all_grids (
			old_grid_id			INT,
			new_grid_id			INT,
			grid_name			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			fk_table			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			fk_column			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			load_sql			VARCHAR(800) COLLATE DATABASE_DEFAULT,
			grid_label			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			grid_type			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			grouping_column		VARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_new				VARCHAR(200) COLLATE DATABASE_DEFAULT,
			edit_permission		VARCHAR(200) COLLATE DATABASE_DEFAULT,
			delete_permission	VARCHAR(200) COLLATE DATABASE_DEFAULT,
			split_at			VARCHAR(200) COLLATE DATABASE_DEFAULT 
		) 
		INSERT INTO application_ui_template (application_function_id, template_name, template_description, active_flag, default_flag, table_name, is_report, edit_permission, delete_permission) 
		
		VALUES('14121400',
		'AssignUnassignTransaction',
		'AssignUnassignTransaction',
		'y',
		'y',
		NULL,
		'n',
		'',
		'')

		DECLARE @application_ui_template_id_new INT
		SET @application_ui_template_id_new = SCOPE_IDENTITY() 
		IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '14121400') 
		BEGIN 
		
			IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
				DROP TABLE #temp_new_template_definition 
					
			CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT, field_type VARCHAR(200) COLLATE DATABASE_DEFAULT)
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','','','','settings','',' ',' ','',NULL,'n','n','','n','n','n','n','n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_assignment_type','req_assignment_type','Assignment Type','combo','int','h','y','SELECT value_id,code FROM static_data_value AS sdv WHERE value_id IN (5146,5173,10013)',NULL,'n','n',NULL,'y','n','n','n','n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_program_scope','req_program_scope','Program Scope','combo','int','h','y','EXEC spa_StaticDataValues @flag=''h'', @type_id=3100',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_assigned_jurisdication','req_assigned_jurisdication','Assigned Jurisdiction','combo','int','h','y',NULL,NULL,'n','n',NULL,'y','n','n','n','n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_gen_state','req_gen_state','Generation State','combo','int','h','y','EXEC spa_staticDataValues @flag=''h'',@type_id=''10016''',NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_assignment_priority','req_assignment_priority','Assignment Priority','combo','int','h','y','EXEC spa_maintain_rec_assignment_priority_group ''b''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_compliance_year','req_compliance_year','Year','combo','int','h','y','EXEC spa_compliance_year ''1995'', 35',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_vintage_from','req_vintage_from','Vintage From','calendar','datetime','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_vintage_to','req_vintage_to','Vintage To','calendar','datetime','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_delivery_date_from','req_delivery_date_from','Delivery Date From','calendar','datetime','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_delivery_date_to','req_delivery_date_to','Delivery Date To','calendar','datetime','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_counterparty','req_counterparty','Counterparty','combo','int','h','y','EXEC spa_source_counterparty_maintain @flag=''c''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_volume_type','req_volume_type','Volume Type','combo','char','h','y','SELECT ''t'' id, ''Target'' name UNION ALL SELECT ''f'', ''Fixed'' UNION ALL SELECT ''r'', ''Requirements'' UNION ALL SELECT ''s'', ''Sales''',NULL,'n','n','t','n','n','n','n','n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_volume','req_volume','Volume','input','float','h','y',NULL,NULL,'y','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_uom','req_uom','UOM','combo','int','h','y','EXEC spa_getsourceuom ''s''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_tier_type','req_tier_type','Tier','combo','int','h','y','EXEC spa_staticDataValues @flag=''h'', @type_id=''15000''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','book_structure','book_structure','Book Structure','browser','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','y','n','y','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_deal_id','req_deal_id','Deal ID','browser','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','req_assigned_date','req_assigned_date','Assigned Date','calendar','datetime','h','y',NULL,NULL,'n','n','GETDATE()','y','n','n','n','n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','inv_sub_book','inv_sub_book','Book Structure','combo','varchar','h','n','EXEC spa_source_book_maintain @flag = ''c''',NULL,'n','n',NULL,'n','n','n','y','y','y','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','inv_env_product','inv_env_product','Environment Product','combo','int','h','y','EXEC spa_getallreccurves',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','inv_tier_type','inv_tier_type','Tier','combo','int','h','y','EXEC spa_staticDataValues @flag=''h'', @type_id=''15000''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','inv_vintage_from','inv_vintage_from','Vintage From','calendar','datetime','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','inv_vintage_to','inv_vintage_to','Vintage To','calendar','datetime','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','inv_gen_state','inv_gen_state','Generation State','combo','int','h','y','EXEC spa_staticDataValues @flag=''h'',@type_id=''10016''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','inv_certificate_no_from','inv_certificate_no_from','Certificate Number From','input','varchar','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','inv_certificate_no_to','inv_certificate_no_to','Certificate Number To','input','varchar','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('14121400','inv_counterparty','inv_counterparty','Counterparty','combo','int','h','y','EXEC spa_source_counterparty_maintain @flag=''c''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
		END 
	
		IF OBJECT_ID('tempdb..#temp_old_template_group') IS NOT NULL
			DROP TABLE #temp_old_template_group

		CREATE TABLE #temp_old_template_group (
			application_ui_template_id	INT,
			group_name					VARCHAR(200) COLLATE DATABASE_DEFAULT,
			group_description			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			active_flag					VARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_flag				VARCHAR(200) COLLATE DATABASE_DEFAULT,
			sequence					INT,
			inputWidth					INT,
			field_layout				VARCHAR(200) COLLATE DATABASE_DEFAULT,
			old_application_grid_id		INT,
			new_application_grid_id		INT
		)	
				
		INSERT INTO #temp_old_template_group(group_name, group_description, active_flag, default_flag, sequence, inputWidth, field_layout, old_application_grid_id)
		SELECT 'Requirements',NULL,'y','y',NULL,NULL,NULL,NULL UNION ALL SELECT 'Inventory',NULL,'y','n',NULL,NULL,NULL,NULL
				
		UPDATE totg
		SET totg.new_application_grid_id = tag.new_grid_id
		FROM #temp_old_template_group totg
		INNER JOIN #temp_all_grids tag
		ON tag.old_grid_id = totg.old_application_grid_id
	
		IF OBJECT_ID('tempdb..#temp_new_template_group') IS NOT NULL
			DROP TABLE #temp_new_template_group	
	
		CREATE TABLE #temp_new_template_group (new_id INT, group_name VARCHAR(200) COLLATE DATABASE_DEFAULT)
		
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
			group_name          VARCHAR(200) COLLATE DATABASE_DEFAULT,
			fieldset_name		VARCHAR(200) COLLATE DATABASE_DEFAULT,
			className			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_disable			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_hidden			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			inputLeft			INT,
			inputTop			INT,
			label				VARCHAR(200) COLLATE DATABASE_DEFAULT,
			offsetLeft			INT,
			offsetTop			INT,
			position			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			width				INT,
			sequence			INT,
			num_column			INT
		)
				
		IF OBJECT_ID('tempdb..#temp_new_template_fieldsets') IS NOT NULL
			DROP TABLE #temp_new_template_fieldsets	
	
		CREATE TABLE #temp_new_template_fieldsets (new_id INT, group_id INT, fieldset_name VARCHAR(200) COLLATE DATABASE_DEFAULT)							
				
	
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
			group_name						VARCHAR(200) COLLATE DATABASE_DEFAULT,
			ui_field_id						VARCHAR(200) COLLATE DATABASE_DEFAULT,
			field_alias						VARCHAR(200) COLLATE DATABASE_DEFAULT,
			Default_value					VARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_format					VARCHAR(200) COLLATE DATABASE_DEFAULT,
			validation_flag					VARCHAR(200) COLLATE DATABASE_DEFAULT,
			hidden							VARCHAR(200) COLLATE DATABASE_DEFAULT,
			field_size						VARCHAR(200) COLLATE DATABASE_DEFAULT,
			field_type						VARCHAR(200) COLLATE DATABASE_DEFAULT,
			field_id						VARCHAR(200) COLLATE DATABASE_DEFAULT,
			sequence						INT,
			inputHeight						VARCHAR(200) COLLATE DATABASE_DEFAULT,
			udf_template_id					INT,
			udf_field_name					INT,
			position						VARCHAR(200) COLLATE DATABASE_DEFAULT,
			dependent_field					VARCHAR(200) COLLATE DATABASE_DEFAULT,
			dependent_query					VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
			old_grid_id						VARCHAR(200) COLLATE DATABASE_DEFAULT,
			new_grid_id						VARCHAR(200) COLLATE DATABASE_DEFAULT,
			validation_message				VARCHAR(200) COLLATE DATABASE_DEFAULT
		)	
					
		IF OBJECT_ID('tempdb..#temp_new_template_fields') IS NOT NULL
			DROP TABLE #temp_new_template_fields 
					
		CREATE TABLE #temp_new_template_fields (new_field_id INT, new_definition_id INT, sdv_code varchar(200) COLLATE DATABASE_DEFAULT)	
					
		INSERT INTO #temp_old_template_fields(old_field_id, old_group_id, old_application_ui_field_id, old_fieldset_id, group_name, ui_field_id, field_alias, Default_value, default_format, validation_flag, hidden, field_size, field_type, field_id, sequence, inputHeight, udf_template_id, udf_field_name, position, dependent_field, dependent_query, old_grid_id, validation_message)
		
		SELECT 101441,28599,101221,NULL,'Requirements','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101442,28599,101222,NULL,'Requirements','req_assignment_type',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101443,28599,101223,NULL,'Requirements','req_program_scope',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101444,28599,101224,NULL,'Requirements','req_assigned_jurisdication',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,'req_program_scope','EXEC spa_assign_transaction @program_scope = <req_program_scope>',NULL,NULL UNION ALL 
		SELECT 101445,28599,101233,NULL,'Requirements','req_volume_type',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101446,28599,101234,NULL,'Requirements','req_volume',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101447,28599,101235,NULL,'Requirements','req_uom',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101448,28599,101236,NULL,'Requirements','req_tier_type',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101449,28599,101225,NULL,'Requirements','req_gen_state',NULL,NULL,NULL,NULL,'y',NULL,'combo',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101450,28599,101226,NULL,'Requirements','req_assignment_priority',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101451,28599,101227,NULL,'Requirements','req_compliance_year',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101452,28599,101228,NULL,'Requirements','req_vintage_from',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101453,28599,101229,NULL,'Requirements','req_vintage_to',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101454,28599,101230,NULL,'Requirements','req_delivery_date_from',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101455,28599,101231,NULL,'Requirements','req_delivery_date_to',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101456,28599,101232,NULL,'Requirements','req_counterparty',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101457,28599,101237,NULL,'Requirements','book_structure',NULL,NULL,NULL,NULL,'n',NULL,'browser',NULL,'16',NULL,NULL,NULL,NULL,NULL,NULL,'book',NULL UNION ALL 
		SELECT 101458,28599,101238,NULL,'Requirements','req_deal_id',NULL,NULL,NULL,NULL,'n',NULL,'browser',NULL,'17',NULL,NULL,NULL,NULL,NULL,NULL,'deal_filter',NULL UNION ALL 
		SELECT 101459,28599,101239,NULL,'Requirements','req_assigned_date',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101460,28600,101221,NULL,'Inventory','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101461,28600,101240,NULL,'Inventory','inv_sub_book',NULL,NULL,'m',NULL,'n',NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101462,28600,101241,NULL,'Inventory','inv_env_product',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101463,28600,101242,NULL,'Inventory','inv_tier_type',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101464,28600,101243,NULL,'Inventory','inv_vintage_from',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101465,28600,101244,NULL,'Inventory','inv_vintage_to',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101466,28600,101245,NULL,'Inventory','inv_gen_state',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101467,28600,101246,NULL,'Inventory','inv_certificate_no_from',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101468,28600,101247,NULL,'Inventory','inv_certificate_no_to',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 101469,28600,101248,NULL,'Inventory','inv_counterparty',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				
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
			group_name			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			layout_cell			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			old_grid_id			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			new_grid_id			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			grid_name			VARCHAR(200) COLLATE DATABASE_DEFAULT,
			sequence			INT,
			num_column			INT,
			cell_height			INT,
			grid_object_name	VARCHAR(100) COLLATE DATABASE_DEFAULT,
			grid_object_unique_column	VARCHAR(100) COLLATE DATABASE_DEFAULT
		)	
					
		INSERT INTO #temp_old_ui_layout(old_layout_grid_id, old_group_id, group_name, layout_cell, old_grid_id, grid_name, sequence, num_column, cell_height,grid_object_name,grid_object_unique_column)
		SELECT 26605,28599,'Requirements','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL SELECT 26606,28600,'Inventory','a','FORM',NULL,1,NULL,NULL,NULL,NULL
				
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
		CREATE TABLE #temp_new_layout_grid (new_layout_grid_id INT, group_id INT, layout_cell VARCHAR(200) COLLATE DATABASE_DEFAULT)	

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
			CREATE TABLE #temp_new_filter(application_ui_filter_id INT,application_ui_filter_name VARCHAR(100) COLLATE DATABASE_DEFAULT,user_login_id VARCHAR(100) COLLATE DATABASE_DEFAULT)

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