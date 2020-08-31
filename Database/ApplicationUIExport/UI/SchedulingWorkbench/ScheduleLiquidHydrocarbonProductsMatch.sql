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
				WHERE aut.application_function_id = '10163720' AND auf.application_function_id IS NULL
				UNION ALL
				SELECT 
					auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
				FROM
					application_ui_filter auf
					INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
				WHERE auf.application_function_id = '10163720'  AND auf.application_function_id IS NOT NULL

				
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
					WHERE aut.application_function_id = '10163720' AND auf.application_function_id IS NULL
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
					WHERE aut.application_function_id = '10163720' AND auf.application_function_id IS NOT NULL


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
			
			IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '10163720')
			BEGIN
				
				--Store old_application_field_id from the destination and sdv.code for the UDF
				INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
				SELECT musddv.application_field_id, sdv.code
				FROM maintain_udf_static_data_detail_values musddv
				INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
				INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
				INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
				INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
				WHERE autd.application_function_id = '10163720'
				
				-- DELETE SCRIPT STARTS HERE
				
				DELETE autf2 FROM application_ui_template_fieldsets AS autf2
				INNER JOIN application_ui_template_group AS autg ON autf2.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10163720'
				
				DELETE aufd FROM application_ui_filter_details aufd
				INNER JOIN application_ui_template_fields autf ON autf.application_field_id = aufd.application_field_id
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10163720'
				
				DELETE aufd FROM application_ui_filter_details aufd
				INNER JOIN application_ui_layout_grid aulg ON aufd.layout_grid_id = aulg.application_ui_layout_grid_id
				INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10163720'	

				DELETE FROM application_ui_filter WHERE application_function_id = '10163720'
				
				DELETE auf FROM application_ui_filter auf
				INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10163720'
				
				DELETE autf FROM application_ui_template_fields AS autf
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10163720'
				
				DELETE aulg FROM application_ui_layout_grid AS aulg
				INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10163720'
				
				DELETE autg FROM application_ui_template_group AS autg 
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10163720'
				
				DELETE autd FROM application_ui_template_definition AS autd
				INNER JOIN application_ui_template AS aut ON aut.application_function_id = autd.application_function_id
				WHERE aut.application_function_id = '10163720'
				
				DELETE FROM application_ui_template
				WHERE application_function_id = '10163720'
				
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
VALUES('10163720',
						'ScheduleLiquidHydrocarbonProductsMatch',
						'Schedule Liquid Hydrocarbon Products Match',
						'y',
						'y',
						NULL,
						NULL,
						NULL,
						NULL)
DECLARE @application_ui_template_id_new INT
			SET @application_ui_template_id_new = SCOPE_IDENTITY() 
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '10163720') BEGIN 
	IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
					DROP TABLE #temp_new_template_definition 
					
					CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT, field_type VARCHAR(200) COLLATE DATABASE_DEFAULT)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','group_name','group_name','Group Name','input','varchar','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','','','','settings','',' ',' ','',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','group_id','group_id','Group ID','input','int','h','n',NULL,NULL,'y','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','match_id','match_id','Match ID','input','int','h','n',NULL,NULL,'y','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','last_edited_by','last_edited_by','Last Edited By','input','int','h','n',NULL,NULL,'y','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','match_number','match_number','Match Number','input','varchar','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','comments','comments','Comments','input','varchar','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n','2',NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','po_number','po_number','PO Number','input','varchar','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','notes','notes','Notes','input','varchar','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','last_edited_on','last_edited_on','Last Edited On','calendar','datetime','h','n',NULL,NULL,'y','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','scheduled_from','scheduled_from','Scheduled From','calendar','datetime','h','n',NULL,NULL,'y','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','scheduled_to','scheduled_to','Scheduled To','calendar','datetime','h','n',NULL,NULL,'y','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','estimated_movement_date','estimated_movement_date','Estimated Movement Date','calendar','datetime','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','scheduling_period','scheduling_period','Scheduling Period','input','datetime','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','commodity','commodity','Commodity','combo','int','h','n','EXEC spa_source_commodity_maintain ''a''',NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','location','location','Location','combo','int','h','n','EXEC spa_source_minor_location ''o''',NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','pipeline_cycle','pipeline_cycle','Pipeline Cycle','combo','int','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=41000',NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','consignee','consignee','Consignee','combo','int','h','n','EXEC spa_source_counterparty_maintain @flag = ''c''',NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','carrier','carrier','Carrier','combo','int','h','n','EXEC spa_source_counterparty_maintain @flag = ''c''',NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','container','container','Container','combo','int','h','n','SELECT source_container_id, container_name FROM source_container',NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','scheduler','scheduler','Scheduler','combo','varchar','h','n','SELECT cc.counterparty_contact_id, cc.name FROM counterparty_contacts cc INNER JOIN static_data_value sdv ON cc.contact_type = sdv.value_id WHERE sdv.type_id = 32200 AND sdv.code = ''scheduler''',NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','status','status','Status','combo','int','h','n',' SELECT ''p'', ''Pre-Allocation'' UNION ALL SELECT ''a'', ''Allocation'' UNION ALL SELECT ''l'', ''Live Shipment'' UNION ALL SELECT ''c'', ''Completed''',NULL,'y','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','quantity','quantity','Quantity','input','float','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','previous_id','previous_id','previous_id','input','varchar','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','frequency','frequency','Frequency','combo','datetime','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 700, @code=''Daily, Monthly''',NULL,'n','y',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','lineup','lineup','Lineup','input','varchar','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n','2',NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','previous_commodity_id','previous_commodity_id','previous_commodity_id','input','int','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','y','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','saved_commodity_origin_id','saved_commodity_origin_id','Origin','combo','int','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','saved_commodity_form_id','saved_commodity_form_id','Form','combo','int','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','saved_commodity_form_attribute1','saved_commodity_form_attribute1','Attribute 1','combo','int','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','saved_commodity_form_attribute2','saved_commodity_form_attribute2','Attribute 2','combo','int','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','saved_commodity_form_attribute3','saved_commodity_form_attribute3','Attribute 3','combo','int','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','saved_commodity_form_attribute4','saved_commodity_form_attribute4','Attribute 4','combo','int','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','saved_commodity_form_attribute5','saved_commodity_form_attribute5','Attribute 5','combo','int','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','organic','organic','Organic','checkbox','char','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','match_group_shipment_id','match_group_shipment_id','Shipment ID','input','int','h','n',NULL,NULL,'y','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','match_group_shipment','match_group_shipment','Shipment','input','varchar','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','shipment_status','shipment_status','Shipment Status','combo','int','h','n',' SELECT ''p'', ''Pre-Allocation'' UNION ALL SELECT ''a'', ''Allocation'' UNION ALL SELECT ''l'', ''Live Shipment'' UNION ALL SELECT ''c'', ''Completed''',NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','shipment_workflow_status','shipment_workflow_status','Workflow Status','combo','int','h','n','EXEC spa_StaticDataValues @flag=''h'', @type_id=43100',NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','container_number','container_number','Container Number','input','varchar','h','n',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10163720','previous_match_group_shipment_id','previous_match_group_shipment_id','previous_match_group_shipment_id','input','int','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','y','n',NULL,NULL,NULL)
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
				
								SELECT 'Schedule Match Group',NULL,'y','y','1',NULL,'1C',NULL UNION ALL 
								SELECT 'Schedule Match Name',NULL,'y','y','1',NULL,'1C',NULL UNION ALL 
								SELECT 'Match',NULL,'y','y','1',NULL,'1C',NULL UNION ALL 
								SELECT 'Schedule Shipment','Schedule Shipment','y','y','1',NULL,'1C',NULL
				
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
					
								SELECT 73750,13553,73595,NULL,'Schedule Match Group','',NULL,NULL,NULL,NULL,'n',NULL,'settings',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73751,13553,73594,NULL,'Schedule Match Group','group_name',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73752,13553,73596,NULL,'Schedule Match Group','group_id',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73753,13554,73595,NULL,'Schedule Match Name','',NULL,NULL,NULL,NULL,'n',NULL,'settings',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73754,13554,73608,NULL,'Schedule Match Name','commodity',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73755,13554,73598,NULL,'Schedule Match Name','last_edited_by',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'23',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73756,13554,73597,NULL,'Schedule Match Name','match_id',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73757,13554,73616,NULL,'Schedule Match Name','quantity',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73758,13554,73603,NULL,'Schedule Match Name','last_edited_on',NULL,NULL,NULL,NULL,'n',NULL,'calendar',NULL,'22',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73759,13554,73614,NULL,'Schedule Match Name','scheduler',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'24',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73760,13554,73609,NULL,'Schedule Match Name','location',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73761,13554,73615,NULL,'Schedule Match Name','status',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'21',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73762,13554,73604,NULL,'Schedule Match Name','scheduled_from',NULL,NULL,NULL,NULL,'n',NULL,'calendar',NULL,'25',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73763,13554,73605,NULL,'Schedule Match Name','scheduled_to',NULL,NULL,NULL,NULL,'n',NULL,'calendar',NULL,'26',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73764,13554,73599,NULL,'Schedule Match Name','match_number',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73765,13554,73600,NULL,'Schedule Match Name','comments',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'33',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73766,13554,73610,NULL,'Schedule Match Name','pipeline_cycle',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'27',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73767,13554,73611,NULL,'Schedule Match Name','consignee',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'28',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73768,13554,73601,NULL,'Schedule Match Name','po_number',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'29',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73769,13554,73613,NULL,'Schedule Match Name','container',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'30',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73770,13553,73617,NULL,'Schedule Match Group','previous_id',NULL,NULL,NULL,NULL,'y',NULL,'input',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73771,13554,73612,NULL,'Schedule Match Name','carrier',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'31',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73772,13554,73618,NULL,'Schedule Match Name','frequency',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73773,13554,73619,NULL,'Schedule Match Name','lineup',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'32',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73774,13553,73620,NULL,'Schedule Match Group','previous_commodity_id',NULL,NULL,NULL,NULL,'y',NULL,'input',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73775,13554,73621,NULL,'Schedule Match Name','saved_commodity_origin_id',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'13',NULL,NULL,NULL,NULL,'commodity','EXEC spa_counterparty_products @flag=''o'',@dependent_id=''<commodity>''',NULL,NULL UNION ALL 
								SELECT 73776,13554,73622,NULL,'Schedule Match Name','saved_commodity_form_id',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'14',NULL,NULL,NULL,NULL,'saved_commodity_origin_id','EXEC spa_counterparty_products @flag = ''f'', @dependent_id= ''<saved_commodity_origin_id>''',NULL,NULL UNION ALL 
								SELECT 73777,13554,73623,NULL,'Schedule Match Name','saved_commodity_form_attribute1',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'15',NULL,NULL,NULL,NULL,'saved_commodity_form_id','EXEC spa_counterparty_products @flag = ''a'', @dependent_id= ''<saved_commodity_form_id>''',NULL,NULL UNION ALL 
								SELECT 73778,13554,73624,NULL,'Schedule Match Name','saved_commodity_form_attribute2',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'16',NULL,NULL,NULL,NULL,'saved_commodity_form_attribute1','EXEC spa_counterparty_products @flag = ''b'', @dependent_id= ''<saved_commodity_form_attribute1>''',NULL,NULL UNION ALL 
								SELECT 73779,13554,73625,NULL,'Schedule Match Name','saved_commodity_form_attribute3',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'17',NULL,NULL,NULL,NULL,'saved_commodity_form_attribute2','EXEC spa_counterparty_products @flag = ''c'', @dependent_id= ''<saved_commodity_form_attribute2>'' ',NULL,NULL UNION ALL 
								SELECT 73780,13554,73626,NULL,'Schedule Match Name','saved_commodity_form_attribute4',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'18',NULL,NULL,NULL,NULL,'saved_commodity_form_attribute3','EXEC spa_counterparty_products @flag = ''e'', @dependent_id= ''<saved_commodity_form_attribute3>'' ',NULL,NULL UNION ALL 
								SELECT 73781,13554,73627,NULL,'Schedule Match Name','saved_commodity_form_attribute5',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'19',NULL,NULL,NULL,NULL,'saved_commodity_form_attribute4','EXEC spa_counterparty_products @flag = ''g'', @dependent_id= ''<saved_commodity_form_attribute4>'' ',NULL,NULL UNION ALL 
								SELECT 73782,13554,73628,NULL,'Schedule Match Name','organic',NULL,NULL,NULL,NULL,'n',NULL,'checkbox',NULL,'20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73783,13556,73629,NULL,'Schedule Shipment','match_group_shipment_id',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73784,13556,73630,NULL,'Schedule Shipment','match_group_shipment',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73785,13556,73631,NULL,'Schedule Shipment','shipment_status',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'21',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73786,13556,73595,NULL,'Schedule Shipment','',NULL,NULL,NULL,NULL,'n',NULL,'settings',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73787,13556,73632,NULL,'Schedule Shipment','shipment_workflow_status',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'34',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73788,13554,73633,NULL,'Schedule Match Name','container_number',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'40',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 73789,13553,73634,NULL,'Schedule Match Group','previous_match_group_shipment_id',NULL,NULL,NULL,NULL,'y',NULL,'input',NULL,'41',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				
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
					
								SELECT 11978,13553,'Schedule Match Group','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 11979,13554,'Schedule Match Name','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 11980,13556,'Schedule Shipment','a','FORM',NULL,1,NULL,NULL,NULL,NULL
				
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