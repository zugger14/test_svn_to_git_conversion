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
				WHERE aut.application_function_id = '12101721' AND auf.application_function_id IS NULL
				UNION ALL
				SELECT 
					auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
				FROM
					application_ui_filter auf
					INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
				WHERE auf.application_function_id = '12101721'  AND auf.application_function_id IS NOT NULL

				
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
					WHERE aut.application_function_id = '12101721' AND auf.application_function_id IS NULL
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
					WHERE aut.application_function_id = '12101721' AND auf.application_function_id IS NOT NULL


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
			
			IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '12101721')
			BEGIN
				
				--Store old_application_field_id from the destination and sdv.code for the UDF
				INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
				SELECT musddv.application_field_id, sdv.code
				FROM maintain_udf_static_data_detail_values musddv
				INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
				INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
				INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
				INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
				WHERE autd.application_function_id = '12101721'
				
				-- DELETE SCRIPT STARTS HERE
				
				DELETE autf2 FROM application_ui_template_fieldsets AS autf2
				INNER JOIN application_ui_template_group AS autg ON autf2.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '12101721'
				
				DELETE aufd FROM application_ui_filter_details aufd
				INNER JOIN application_ui_template_fields autf ON autf.application_field_id = aufd.application_field_id
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '12101721'
				
				DELETE aufd FROM application_ui_filter_details aufd
				INNER JOIN application_ui_layout_grid aulg ON aufd.layout_grid_id = aulg.application_ui_layout_grid_id
				INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '12101721'	

				DELETE FROM application_ui_filter WHERE application_function_id = '12101721'
				
				DELETE auf FROM application_ui_filter auf
				INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '12101721'
				
				DELETE autf FROM application_ui_template_fields AS autf
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '12101721'
				
				DELETE aulg FROM application_ui_layout_grid AS aulg
				INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '12101721'
				
				DELETE autg FROM application_ui_template_group AS autg 
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '12101721'
				
				DELETE autd FROM application_ui_template_definition AS autd
				INNER JOIN application_ui_template AS aut ON aut.application_function_id = autd.application_function_id
				WHERE aut.application_function_id = '12101721'
				
				DELETE FROM application_ui_template
				WHERE application_function_id = '12101721'
				
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
VALUES('12101721',
						'AssignmentFormDetails',
						'Assignment Form Details',
						'y',
						'y',
						NULL,
						NULL,
						NULL,
						NULL)
DECLARE @application_ui_template_id_new INT
			SET @application_ui_template_id_new = SCOPE_IDENTITY() 
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '12101721') BEGIN 
	IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
					DROP TABLE #temp_new_template_definition 
					
					CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT, field_type VARCHAR(200) COLLATE DATABASE_DEFAULT)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','','','','settings','',' ',' ','',NULL,'n','n','','n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','generator_assignment_id','generator_assignment_id','Assignment ID','input','varchar','h','n',NULL,NULL,'y','y',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','allocation','allocation','Allocation','combo','varchar','h','n','EXEC spa_GetAllSourceBookMapping @hedge_rel_type_flag=''y''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','offset','offset','Offset','combo','varchar','h','n','EXEC spa_GetAllSourceBookMapping @hedge_rel_type_flag=''y''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','term_start','term_start','Term Start','calendar','varchar','h','n',NULL,NULL,'n','n',NULL,'y','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','term_end','term_end','Term End','calendar','varchar','h','n',NULL,NULL,'n','n',NULL,'y','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','assignment_type','assignment_type','Assignment Type','combo','varchar','h','n','EXEC spa_staticDataValues @flag=''h'', @type_id=10013',NULL,'n','n',NULL,'y','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','assignment_percent','assignment_percent','Assignment Percent','input','float','h','n',NULL,NULL,'n','n',NULL,'y','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','max_volume_assign','max_volume_assign','Max Volume Assign','input','float','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','frequency','frequency','Frequency','combo','varchar','h','n','EXEC spa_staticDataValues @flag=''h'', @type_id=700',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','uom','uom','UOM','combo','varchar','h','n','EXEC spa_source_uom_maintain @flag=''s''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','trader','trader','Trader','combo','varchar','h','n','EXEC spa_source_traders_maintain ''y''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','assigned_counterparty','assigned_counterparty','Assigned Counterparty','combo','varchar','h','n','EXEC spa_source_counterparty_maintain @flag = ''c'', @is_active = ''y'', @not_int_ext_flag = ''b''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','sold_price','sold_price','Sold Price','input','float','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','contract','contract','Contract','combo','varchar','h','n','EXEC spa_contract_group ''r''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','use_market_price','use_market_price','Use Market Price','checkbox','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','exclude_from_inventory','exclude_from_inventory','Exclude From Inventory','checkbox','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('12101721','use_deal_price','use_deal_price','Use Deal Price','checkbox','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
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
				
								SELECT 'General',NULL,'y','y','1',NULL,'1C',NULL
				
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
				

				
					INSERT INTO #temp_old_template_fieldsets(old_fieldset_id, old_group_id, group_name, fieldset_name, className, is_disable, is_hidden, inputLeft, inputTop, label, offsetLeft, offsetTop, position, width, sequence, num_column)
					
								SELECT 8170,17246,'General','source_book_mapping',NULL,'n','n','500','500','Source Book Mapping',NULL,NULL,NULL,'700','1','3'
				
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
					
								SELECT 82501,17246,82204,NULL,'General','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82502,17246,82205,NULL,'General','generator_assignment_id',NULL,NULL,NULL,NULL,'y',NULL,'input',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82503,17246,82206,'8170','General','allocation',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82504,17246,82207,'8170','General','offset',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82505,17246,82208,NULL,'General','term_start',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82506,17246,82209,NULL,'General','term_end',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82507,17246,82210,NULL,'General','assignment_type',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82508,17246,82211,NULL,'General','assignment_percent',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82509,17246,82212,NULL,'General','max_volume_assign',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82510,17246,82213,NULL,'General','frequency',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82511,17246,82214,NULL,'General','uom',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82512,17246,82215,NULL,'General','trader',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82513,17246,82216,NULL,'General','assigned_counterparty',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82514,17246,82217,NULL,'General','sold_price',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82515,17246,82218,NULL,'General','contract',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82516,17246,82219,NULL,'General','use_market_price',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82517,17246,82220,NULL,'General','exclude_from_inventory',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 82518,17246,82221,NULL,'General','use_deal_price',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				
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
					tnf.application_ui_filter_id,tntf.new_field_id,toduf.field_value,NULL,toduf.book_level
				FROM
					#temp_old_application_ui_filter_details toduf
					LEFT JOIN #temp_new_template_definition tntd ON tntd.field_id = toduf.field_id
					LEFT JOIN #temp_old_template_fields ontf ON ontf.ui_field_id  = toduf.field_id
					LEFT JOIN #temp_new_template_fields tntf ON tntf.new_definition_id = tntd.new_definition_id
					LEFT JOIN #temp_old_application_ui_filter tt ON tt.application_ui_filter_id = toduf.application_ui_filter_id
					LEFT JOIN #temp_new_filter tnf ON tnf.application_ui_filter_name = tt.application_ui_filter_name AND tnf.user_login_id = tt.user_login_id
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