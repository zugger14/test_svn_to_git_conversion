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
				WHERE aut.application_function_id = '20007903' AND auf.application_function_id IS NULL
				UNION ALL
				SELECT 
					auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
				FROM
					application_ui_filter auf
					INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
				WHERE auf.application_function_id = '20007903'  AND auf.application_function_id IS NOT NULL

				
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
					WHERE aut.application_function_id = '20007903' AND auf.application_function_id IS NULL
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
					WHERE aut.application_function_id = '20007903' AND auf.application_function_id IS NOT NULL


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
			
			IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '20007903')
			BEGIN
				
				--Store old_application_field_id from the destination and sdv.code for the UDF
				INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
				SELECT musddv.application_field_id, sdv.code
				FROM maintain_udf_static_data_detail_values musddv
				INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
				INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
				INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
				INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
				WHERE autd.application_function_id = '20007903'
				
				-- DELETE SCRIPT STARTS HERE
				
				DELETE autf2 FROM application_ui_template_fieldsets AS autf2
				INNER JOIN application_ui_template_group AS autg ON autf2.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '20007903'
				
				DELETE aufd FROM application_ui_filter_details aufd
				INNER JOIN application_ui_template_fields autf ON autf.application_field_id = aufd.application_field_id
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '20007903'
				
				DELETE aufd FROM application_ui_filter_details aufd
				INNER JOIN application_ui_layout_grid aulg ON aufd.layout_grid_id = aulg.application_ui_layout_grid_id
				INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '20007903'	

				DELETE FROM application_ui_filter WHERE application_function_id = '20007903'
				
				DELETE auf FROM application_ui_filter auf
				INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '20007903'
				
				DELETE autf FROM application_ui_template_fields AS autf
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '20007903'
				
				DELETE aulg FROM application_ui_layout_grid AS aulg
				INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '20007903'
				
				DELETE autg FROM application_ui_template_group AS autg 
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '20007903'
				
				DELETE autd FROM application_ui_template_definition AS autd
				INNER JOIN application_ui_template AS aut ON aut.application_function_id = autd.application_function_id
				WHERE aut.application_function_id = '20007903'
				
				DELETE FROM application_ui_template
				WHERE application_function_id = '20007903'
				
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
VALUES('20007903',
						'BuySellMatchFilter1',
						'Buy Sell Match Filter1',
						'y',
						'y',
						NULL,
						'n',
						'20007901',
						'20007902')
DECLARE @application_ui_template_id_new INT
			SET @application_ui_template_id_new = SCOPE_IDENTITY() 
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '20007903') BEGIN 
	IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
					DROP TABLE #temp_new_template_definition 
					
					CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT, field_type VARCHAR(200) COLLATE DATABASE_DEFAULT)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','','','','settings','',' ',' ','','250','n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	
	
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)				
				VALUES('20007903','delivery_date_from','delivery_date_from','Delivery Date From','calendar','datetime','h','y',NULL,'150','n','n','GETDATE() - 7','y','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)				
				VALUES('20007903','delivery_date_to','delivery_date_to','Delivery Date To','calendar','datetime','h','y',NULL,'150','n','n','GETDATE()','y','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','product_classification','product_classification','Product Classification','combo','varchar','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 107400','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','term_start','term_start','Vintage Start','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','term_end','term_end','Vintage End','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','counterparty_id','counterparty_id','Counterparty','combo','int','h','n','EXEC spa_getsourcecounterparty ''s''','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','vintage_year','vintage_year','Vintage Year','combo','varchar','h','n','EXEC spa_compliance_year ''1995''','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','region_id','region_id','Region','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 11150','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','not_region_id','not_region_id','Not Region','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 11150','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','jurisdiction','jurisdiction','Jurisdiction','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10002','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','not_jurisdiction','not_jurisdiction','Not Jurisdiction','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10002','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','technology','technology','Technology','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10009','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','not_technology','not_technology','Not Technology','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10009','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','tier_type','tier_type','Tier','combo','varchar','h','n','EXEC spa_staticDataValues @flag=''h'', @type_id=''15000''','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','nottier_type','nottier_type','Not Tier','combo','varchar','h','n','EXEC spa_staticDataValues @flag=''h'', @type_id=''15000''','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','deal_detail_status','deal_detail_status','REC Status','combo','int','h','n','EXEC spa_staticDataValues @flag=''h'', @type_id=''25000'', @license_not_to_static_value_id = ''25001,25005,25007,25009,25010,25011,25000,25012''','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','description','description','Description','input','varchar','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','deal_date_from','deal_date_from','Deal Date From','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','deal_date_to','deal_date_to','Deal Date To','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','create_ts_from','create_ts_from','Create Date From','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','create_ts_to','create_ts_to','Create Date To','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('20007903','book_structure_1','book_structure_1','Book Structure','browser','varchar','h','y',NULL,'150','n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)

						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','effective_date_2','effective_date_2','Effective Date','calendar','datetime','h','y',NULL,'150','n','n','GETDATE()','y','n','y','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','term_start_2','term_start_2','Vintage Start','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','term_end_2','term_end_2','Vintage End','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','counterparty_id_2','counterparty_id_2','Counterparty','combo','int','h','n','EXEC spa_getsourcecounterparty ''s''','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','vintage_year_2','vintage_year_2','Vintage Year','combo','int','h','n','EXEC spa_compliance_year ''1995''','150','y','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','region_id_2','region_id_2','Region','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 11150','150','y','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','not_region_id_2','not_region_id_2','Not Region','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 11150','150','y','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','jurisdiction_2','jurisdiction_2','Jurisdiction','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10002','150','y','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','not_jurisdiction_2','not_jurisdiction_2','Not Jurisdiction','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10002','150','y','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','technology_2','technology_2','Technology','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10009','150','y','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','not_technology_2','not_technology_2','Not Technology','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10009','150','y','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','tier_type_2','tier_type_2','Tier','combo','int','h','n','EXEC spa_staticDataValues @flag=''h'', @type_id=''15000''','150','y','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','nottier_type_2','nottier_type_2','Not Tier','combo','int','h','n','EXEC spa_staticDataValues @flag=''h'', @type_id=''15000''','150','y','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','deal_detail_status_2','deal_detail_status_2','REC Status','combo','int','h','n','EXEC spa_staticDataValues @flag=''h'', @type_id=''25000'', @license_not_to_static_value_id = ''25001,25005,25007,25009,25010,25011,25000,25012''','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
					
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','description_2','description_2','Description','input','varchar','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','deal_date_from_2','deal_date_from_2','Deal Date From','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','deal_date_to_2','deal_date_to_2','Deal Date To','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','create_ts_from_2','create_ts_from_2','Create Date From','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','create_ts_to_2','create_ts_to_2','Create Date To','calendar','datetime','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
										
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','generator_id_2','generator_id_2','Generator','combo','varchar','h','n','EXEC(''SELECT generator_id AS [value], name AS [label] FROM rec_generator'')','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','include_expired_deals_2','include_expired_deals_2','Include Expired Deals','checkbox','varchar','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','book_structure','book_structure','Book Structure','browser','varchar','h','y',NULL,'300','n','n',NULL,'y','n','n','n','n','n','n','n',NULL,NULL,NULL)

	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','volume_match','volume_match','Volume Match','combo','varchar','h','y','EXEC(''SELECT ''''p'''' [value], ''''Partial Volume Match'''' [label] UNION SELECT ''''c'''' [value], ''''Perfect Volume Match'''' [label]'')','150','n','n',NULL,'n','n','n','n','n','y','n','y',NULL,NULL,NULL)
						
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('20007903','show_all_deals','show_all_deals','Show All Deals','checkbox','varchar','h','y',NULL,'150','n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
						

	/*	--- Commented becasue they are not needed for now 
		INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
					OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
					INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
					VALUES('20007903','commodity_id','commodity_id','Commodity','combo','int','h','n','EXEC spa_source_commodity_maintain ''a''','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
		INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
					OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
					INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
					VALUES('20007903','buy_sell_id','buy_sell_id','Buy/Sell','combo','varchar','h','n','EXEC(''SELECT ''''b'''' [value], ''''Buy'''' [label] UNION SELECT ''''s'''' [value], ''''Sell'''' [label]'')','150','y','n','b','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
		INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
					OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
					INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
					VALUES('20007903','curve_id','curve_id','Product','combo','int','h','n','EXEC spa_source_price_curve_def_maintain ''l''','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
		INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
					OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
					INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
					VALUES('20007903','deal_volume_uom_id','deal_volume_uom_id','UOM','combo','int','h','n','EXEC spa_getsourceuom @flag = ''s''','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)	
		INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
					OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
					INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
					VALUES('20007903','volume_min','volume_min','Volume Min','input','int','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
		INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
					OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
					INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
					VALUES('20007903','volume_max','volume_max','Volume Max','input','int','h','n',NULL,'150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)	
		INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
					OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
					INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
					VALUES('20007903','label','label','Label','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 101100','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)	
		INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
					OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
					INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
					VALUES('20007903','sort_type','sort_type','Sort Type','combo','varchar','h','n','EXEC(''SELECT ''''l'''' [value], ''''LIFO'''' [label] UNION SELECT ''''f'''' [value], ''''FIFO'''' [label]'')','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)	
		INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
					OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
					INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
					VALUES('20007903','currency','currency','Currency','combo','int','h','n','EXEC(''SELECT source_currency_id, currency_name FROM source_currency'')','150','n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	-------------*/
	
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
				
								SELECT 'Dealset1Filter',NULL,'y','y','3',NULL,'1C',NULL UNION ALL
								SELECT 'MatchCriteria',NULL,'y','y','2',NULL,'1C',NULL 
				
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
					
					SELECT 5978,1639,'Dealset1Filter','fieldset1','','n','n','500','500','Sell Deal',NULL,NULL,NULL,'400',NULL,NULL UNION ALL
					SELECT 5979,1639,'Dealset1Filter','fieldset2','','n','n','500','500','Buy Deal',NULL,NULL,NULL,'400',NULL,NULL UNION ALL
					SELECT 5980,1640,'MatchCriteria','general',NULL,'n','n','300','300','Match Criteria',NULL,NULL,NULL,'400',NULL,NULL
					
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
					
					SELECT 7322,1639,7223,5978,'Dealset1Filter','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,'0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7323,1639,7224,5978,'Dealset1Filter','delivery_date_from',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7323,1639,7224,5978,'Dealset1Filter','delivery_date_to',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
					SELECT 7323,1639,7224,5978,'Dealset1Filter','product_classification',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7323,1639,7224,5978,'Dealset1Filter','term_start',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7323,1639,7224,5978,'Dealset1Filter','term_end',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7324,1639,7225,5978,'Dealset1Filter','counterparty_id',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7347,1639,7248,5978,'Dealset1Filter','vintage_year',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7349,1639,7250,5978,'Dealset1Filter','region_id',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7350,1639,7251,5978,'Dealset1Filter','not_region_id',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
					SELECT 7340,1639,7241,5978,'Dealset1Filter','jurisdiction',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7341,1639,7242,5978,'Dealset1Filter','not_jurisdiction',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7345,1639,7246,5978,'Dealset1Filter','tier_type',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7346,1639,7247,5978,'Dealset1Filter','nottier_type',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7338,1639,7239,5978,'Dealset1Filter','technology',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7339,1639,7240,5978,'Dealset1Filter','not_technology',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 								
					SELECT 7343,1639,7244,5978,'Dealset1Filter','deal_detail_status',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
					SELECT 7343,1639,7244,5978,'Dealset1Filter','description',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
					SELECT 7326,1639,7227,5978,'Dealset1Filter','deal_date_from',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'19',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
					SELECT 7327,1639,7228,5978,'Dealset1Filter','deal_date_to',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
					SELECT 7330,1639,7231,5978,'Dealset1Filter','create_ts_from',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'21',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
					SELECT 7331,1639,7232,5978,'Dealset1Filter','create_ts_to',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'22',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL

					SELECT 7323,1639,7224,5979,'Dealset1Filter','book_structure_1',NULL,NULL,NULL,NULL,NULL,NULL,'browser',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,'book_structure',NULL UNION ALL 
					SELECT 7332,1639,7233,5979,'Dealset1Filter','effective_date_2',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
					SELECT 7334,1639,7235,5979,'Dealset1Filter','term_start_2',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7335,1639,7236,5979,'Dealset1Filter','term_end_2',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7336,1639,7237,5979,'Dealset1Filter','counterparty_id_2',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7337,1639,7238,5979,'Dealset1Filter','vintage_year_2',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7338,1639,7239,5979,'Dealset1Filter','region_id_2',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7339,1639,7240,5979,'Dealset1Filter','not_region_id_2',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7340,1639,7241,5979,'Dealset1Filter','jurisdiction_2',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7341,1639,7242,5979,'Dealset1Filter','not_jurisdiction_2',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7243,5979,'Dealset1Filter','tier_type_2',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7244,5979,'Dealset1Filter','nottier_type_2',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7245,5979,'Dealset1Filter','technology_2',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7246,5979,'Dealset1Filter','not_technology_2',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7247,5979,'Dealset1Filter','deal_detail_status_2',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7248,5979,'Dealset1Filter','description_2',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7249,5979,'Dealset1Filter','deal_date_from_2',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7250,5979,'Dealset1Filter','deal_date_to_2',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7251,5979,'Dealset1Filter','create_ts_from_2',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'19',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7252,5979,'Dealset1Filter','create_ts_to_2',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7254,5979,'Dealset1Filter','generator_id_2',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'21',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1639,7255,5979,'Dealset1Filter','include_expired_deals_2',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,'22',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL

					SELECT 7331,1640,7256,NULL,'MatchCriteria','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,'0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1640,7257,NULL,'MatchCriteria','book_structure',NULL,NULL,NULL,NULL,NULL,NULL,'browser',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,'book',NULL UNION ALL
					SELECT 7331,1640,7258,5980,'MatchCriteria','volume_match',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
					SELECT 7331,1640,7259,5980,'MatchCriteria','show_all_deals',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
					/* ------------ Commented because they are not needed now.
						SELECT 7325,1639,7226,NULL,'Dealset1Filter','commodity_id',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
						SELECT 7344,1639,7245,NULL,'Dealset1Filter','sort_type',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
						SELECT 7332,1639,7233,NULL,'Dealset1Filter','buy_sell_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
						SELECT 7333,1639,7234,NULL,'Dealset1Filter','curve_id',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
						SELECT 7334,1639,7235,NULL,'Dealset1Filter','deal_volume_uom_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL									
						SELECT 7336,1639,7237,NULL,'Dealset1Filter','volume_min',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
						SELECT 7337,1639,7238,NULL,'Dealset1Filter','volume_max',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
						SELECT 7342,1639,7243,NULL,'Dealset1Filter','label',NULL,NULL,'m',NULL,NULL,NULL,'combo',NULL,'20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
						SELECT 7348,1639,7249,NULL,'Dealset1Filter','currency',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'27',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
					*/

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
					
								SELECT 1510,1639,'Dealset1Filter','b','FORM',NULL,3,NULL,NULL,NULL,NULL UNION ALL
								SELECT 1510,1640,'MatchCriteria','a','FORM',NULL,2,NULL,NULL,NULL,NULL 
				
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