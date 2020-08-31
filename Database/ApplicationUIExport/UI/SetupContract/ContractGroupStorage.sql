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
		WHERE aut.application_function_id = '20008200' AND auf.application_function_id IS NULL
		UNION ALL
		SELECT 
			auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
		FROM
			application_ui_filter auf
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
		WHERE auf.application_function_id = '20008200'  AND auf.application_function_id IS NOT NULL

				
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
			WHERE aut.application_function_id = '20008200' AND auf.application_function_id IS NULL
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
			WHERE aut.application_function_id = '20008200' AND auf.application_function_id IS NOT NULL
	
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
			
		IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '20008200')
		BEGIN				
			--Store old_application_field_id from the destination and sdv.code for the UDF
			INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
			SELECT musddv.application_field_id, sdv.code
			FROM maintain_udf_static_data_detail_values musddv
			INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
			INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
			INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
			WHERE autd.application_function_id = '20008200'
				
			-- DELETE SCRIPT STARTS HERE
				
			EXEC spa_application_ui_template 'd', 20008200
				
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
		
		VALUES('20008200',
		'contract_group_storage',
		'contract_group_storage',
		'y',
		'y',
		'contract_group',
		NULL,
		'20008200',
		'20008200',
		'102808')

		DECLARE @application_ui_template_id_new INT
		SET @application_ui_template_id_new = SCOPE_IDENTITY() 
		IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '20008200') 
		BEGIN 
		
			IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
				DROP TABLE #temp_new_template_definition 
					
			CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT , field_type VARCHAR(200) COLLATE DATABASE_DEFAULT )
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','','','','settings','',' ',' ','',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','contract_id','contract_id','System ID','input','int','h','n',NULL,NULL,'y','n',NULL,'n','n',NULL,NULL,'n','y','n','y',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','source_contract_id','source_contract_id','Contract ID','input','VARCHAR','h','n',NULL,NULL,'n','y',NULL,'n','n','n',NULL,'n','n','n','n',NULL,NULL,'50')
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','source_system_id','source_system_id','Source System','combo','int','h','n','EXEC spa_source_system_description ''s''',NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','pipeline','pipeline','Counterparty','combo','int','h','n','EXEC spa_source_counterparty_maintain @flag = ''c''',NULL,'n','n',NULL,'y','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','contract_name','contract_name','Contract Name','input','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'y','n','n',NULL,'n','n','n','n',NULL,NULL,'50')
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','flow_start_date','flow_start_date','Effective Date','calendar','date','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','flow_end_date','flow_end_date','End Date','calendar','date','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','maintain_rate_schedule','maintain_rate_schedule','Rate Schedule','combo_v2','int','h','n','EXEC spa_transportation_rate_schedule ''e''',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,'20008900',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','contract_type','contract_type','Type','combo','varchar','h','y','EXEC(''SELECT ''''f'''' as Value,''''Firm Transport'''' as text UNION SELECT ''''i'''' as Value,''''Interruptible Transport'''' as text UNION SELECT ''''s'''' as Value,''''Storage'''' as text'')',NULL,'y','y','s','n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','grouping_contract','grouping_contract','Primary Contract','combo','varchar','h','y','Select contract_id, contract_name from contract_group  WHERE ISNULL(contract_type_def_id, ''1'') = ''1'' 
			OR contract_type_def_id = 38402 OR contract_type_def_id = 38404',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','contract_type_def_id','contract_type_def_id','Contract Type','input','int','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','settlement_date','settlement_date','Settlement Rule','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 20000',NULL,'n','n',NULL,'y','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','settlement_days','settlement_days','Settlement Days','input','int','h','n',NULL,NULL,'n','n',NULL,'y','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','invoice_due_date','invoice_due_date','Payment Rule','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 20000',NULL,'n','n',NULL,'y','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','payment_days','payment_days','Payment Days','input','int','h','n',NULL,NULL,'n','n',NULL,'y','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','volume_granularity','volume_granularity','Invoice Frequency','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 978',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','invoice_report_template','invoice_report_template','Invoice','combo','int','h','n','SELECT template_id, template_name FROM contract_report_template WHERE template_type = 38',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','contract_report_template','contract_report_template','Remmitance','combo','int','h','n','SELECT template_id, template_name FROM contract_report_template WHERE template_type = 38',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','netting_template','netting_template','Netting','combo','int','h','n','SELECT template_id, template_name FROM contract_report_template WHERE template_type = 38',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','contract_email_template','contract_email_template','Email','combo','int','h','n','	SELECT aec.admin_email_configuration_id, aec.template_name FROM admin_email_configuration aec
RIGHT JOIN static_data_value sdv ON sdv.value_id = aec.module_type
WHERE sdv.type_id= 17800 AND sdv.code = ''Invoice Mail''',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','create_ts','create_ts','Created Date','input','VARCHAR','h','n',NULL,NULL,'y','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','create_user','create_user','Created By','input','VARCHAR','h','n',NULL,NULL,'y','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'50')
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','update_ts','update_ts','Updated Date','input','VARCHAR','h','n',NULL,NULL,'y','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','update_user','update_user','Updated By','input','VARCHAR','h','n',NULL,NULL,'y','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'50')
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','is_active','is_active','Active','checkbox','char','h','n',NULL,NULL,'n','n','y','n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','netting_statement','netting_statement','Netting Statement','checkbox','char','h','n','',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','contract_status','contract_status','Contract Status','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 1900',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','volume_uom','volume_uom','UOM','combo','int','h','n','EXEC spa_source_uom_maintain ''s''',NULL,'n','n',NULL,'y','n','n','n','n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','commodity','commodity','Commodity','combo','int','h','n','EXEC spa_source_commodity_maintain ''a''',NULL,'n','n',NULL,'y','n','n','n','n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','currency','currency','Currency','combo','int','h','n','EXEC spa_source_currency_maintain ''p''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','sub_id','sub_id','Subsidiary','combo','int','h','n','EXEC get_subsidiaries_for_rights @function_id=''20008200''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','contract_charge_type_id','contract_charge_type_id','Contract Component Template','combo','int','h','n','EXEC spa_contract_charge_type ''s''',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','service_type','service_type','Service Type','combo','char','h','n','SELECT ''i'' as id, ''Fixed'' as value UNION SELECT ''l'' as id, ''Flex'' as value UNION SELECT ''p'' as id,''Park and Loan'' as value',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','storage_asset_id','storage_asset_id','Storage Asset','combo','int','h','n','SELECT sa.storage_asset_id, sa.asset_name FROM storage_asset AS sa ORDER BY sa.asset_name',NULL,'n','n',NULL,'y','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20008200','neting_rule','neting_rule','Neting Rule','checkbox','char','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
						
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
		SELECT 'General',NULL,'y','y','1',NULL,'1C',NULL UNION ALL SELECT 'Invoice',NULL,'y','n','3',NULL,'1C',NULL UNION ALL SELECT 'Audit',NULL,'y','n','4',NULL,'1C',NULL
				
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
		
								SELECT 7585,14860,'Invoice','Invoice Rule','','n','n','500','500','Invoice Rule',NULL,NULL,NULL,'700','1','2' UNION ALL 
								SELECT 7586,14860,'Invoice','Invoice Templates','','n','n','500','500','Invoice Templates',NULL,NULL,NULL,'700','2','2' UNION ALL 
								SELECT 7587,14860,'Invoice','Netting Settlement',NULL,'n','n','500','500','Netting',NULL,NULL,NULL,'700','3','1'
				
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
		
		SELECT 84560,14859,84060,NULL,'General','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84561,14859,84061,NULL,'General','contract_id',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84562,14859,84071,NULL,'General','contract_type_def_id',NULL,'38404',NULL,NULL,'y',NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84563,14859,84062,NULL,'General','source_contract_id',NULL,NULL,NULL,'n',NULL,NULL,'input',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84564,14859,84064,NULL,'General','pipeline',NULL,NULL,NULL,'y',NULL,NULL,'combo',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84565,14859,84065,NULL,'General','contract_name',NULL,NULL,NULL,'y',NULL,NULL,'input',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84566,14859,84066,NULL,'General','flow_start_date',NULL,NULL,NULL,'n',NULL,NULL,'calendar',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84567,14859,84067,NULL,'General','flow_end_date',NULL,NULL,NULL,'n',NULL,NULL,'calendar',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84568,14859,84068,NULL,'General','maintain_rate_schedule',NULL,NULL,NULL,NULL,NULL,NULL,'combo_v2',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84569,14859,84069,NULL,'General','contract_type',NULL,'s',NULL,NULL,'y',NULL,'combo',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84570,14859,84087,NULL,'General','contract_status',NULL,'1903',NULL,NULL,NULL,NULL,'combo',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84571,14859,84085,NULL,'General','is_active',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,'24',NULL,NULL,NULL,'label-right',NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84572,14859,84063,NULL,'General','source_system_id',NULL,'2',NULL,NULL,'y',NULL,'combo',NULL,'19',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84573,14860,84060,NULL,'Invoice','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84574,14860,84072,'7585','Invoice','settlement_date',NULL,'20003',NULL,NULL,NULL,NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84575,14860,84073,'7585','Invoice','settlement_days',NULL,'2',NULL,NULL,NULL,NULL,'input',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84576,14860,84074,'7585','Invoice','invoice_due_date',NULL,'20003',NULL,NULL,NULL,NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84577,14860,84075,'7585','Invoice','payment_days',NULL,'20',NULL,NULL,NULL,NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84578,14860,84076,'7585','Invoice','volume_granularity',NULL,'980',NULL,NULL,NULL,NULL,'combo',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84579,14860,84077,'7586','Invoice','invoice_report_template',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84580,14860,84078,'7586','Invoice','contract_report_template',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84581,14860,84079,'7586','Invoice','netting_template',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84582,14860,84080,'7586','Invoice','contract_email_template',NULL,'20003',NULL,NULL,NULL,NULL,'combo',NULL,'20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84583,14861,84060,NULL,'Audit','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84584,14861,84082,NULL,'Audit','create_user',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84585,14861,84081,NULL,'Audit','create_ts',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84586,14861,84084,NULL,'Audit','update_user',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84587,14861,84083,NULL,'Audit','update_ts',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84588,14860,84086,'7587','Invoice','netting_statement',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84589,14859,84088,NULL,'General','volume_uom',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84590,14859,84089,NULL,'General','commodity',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84591,14859,84090,NULL,'General','currency',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84592,14859,84091,NULL,'General','sub_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84593,14859,84092,NULL,'General','contract_charge_type_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84594,14859,84070,NULL,'General','grouping_contract',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84595,14859,84093,NULL,'General','service_type',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'22',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84596,14859,84094,NULL,'General','storage_asset_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 84597,14859,84095,NULL,'General','neting_rule',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,'23',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				
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
		SELECT 12672,14859,'General','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL SELECT 12673,14860,'Invoice','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL SELECT 12674,14861,'Audit','a','FORM',NULL,1,NULL,NULL,NULL,NULL
				
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
		EXEC spa_application_ui_template_audit @flag='d', @application_function_id='20008200'
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
			
	DECLARE @memcache_key			NVARCHAR(1000)
		, @db					NVARCHAR(200) = db_name()
	SELECT @memcache_key = CASE WHEN aut.is_report = 'y' 
							THEN @db + '_RptList' + ',' + @db + '_RptStd_' + '20008200'  
							ELSE @db + '_UI_' + '20008200'
						END 
	FROM application_ui_template AS aut
	WHERE aut.application_function_id = 20008200
		 	
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN
		EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key, @cmbobj_key_source = NULL, @other_key_source=NULL, @source_object = 'spa_application_ui_export'
	END
	
END