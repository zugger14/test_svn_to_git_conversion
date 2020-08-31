
BEGIN
			BEGIN TRY
			BEGIN TRAN
			
			IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '10171300')
			BEGIN
				
				-- DELETE SCRIPT STARTS HERE
				
				DELETE autf2 FROM application_ui_template_fieldsets AS autf2
				INNER JOIN application_ui_template_group AS autg ON autf2.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10171300'
				
				DELETE aufd FROM application_ui_filter_details aufd
				INNER JOIN application_ui_template_fields autf ON autf.application_field_id = aufd.application_field_id
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10171300'
				
				DELETE FROM application_ui_filter WHERE application_function_id = '10171300'
				
				DELETE auf FROM application_ui_filter auf
				INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10171300'
				
				DELETE autf FROM application_ui_template_fields AS autf
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10171300'
				
				DELETE aulg FROM application_ui_layout_grid AS aulg
				INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10171300'
				
				DELETE autg FROM application_ui_template_group AS autg 
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10171300'
				
				DELETE autd FROM application_ui_template_definition AS autd
				INNER JOIN application_ui_template AS aut ON aut.application_function_id = autd.application_function_id
				WHERE aut.application_function_id = '10171300'
				
				DELETE FROM application_ui_template
				WHERE application_function_id = '10171300'
				
			END 

			IF OBJECT_ID('tempdb..#temp_all_grids') IS NOT NULL
				DROP TABLE #temp_all_grids

			CREATE TABLE #temp_all_grids (
				old_grid_id		INT,
				new_grid_id     INT,
				grid_name       varchar(200) COLLATE DATABASE_DEFAULT,
				fk_table		VARCHAR(200) COLLATE DATABASE_DEFAULT,
				fk_column		VARCHAR(200) COLLATE DATABASE_DEFAULT,
				load_sql		VARCHAR(800) COLLATE DATABASE_DEFAULT,
				grid_label		VARCHAR(200) COLLATE DATABASE_DEFAULT,
				grid_type		VARCHAR(200) COLLATE DATABASE_DEFAULT,
				grouping_column	VARCHAR(200) COLLATE DATABASE_DEFAULT,
				is_new			VARCHAR(200) COLLATE DATABASE_DEFAULT,
				edit_permission VARCHAR(200) COLLATE DATABASE_DEFAULT,
				delete_permission VARCHAR(200) COLLATE DATABASE_DEFAULT
			) 
INSERT INTO application_ui_template (application_function_id, template_name, template_description, active_flag, default_flag, table_name, is_report, edit_permission, delete_permission) 
VALUES('10171300',
						'Deal Confirm Report',
						'Deal Confirm Report',
						'y',
						'y',
						NULL,
						'y',
						NULL,
						NULL)
DECLARE @application_ui_template_id_new INT
			SET @application_ui_template_id_new = SCOPE_IDENTITY() 
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '10171300') BEGIN 
	IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
					DROP TABLE #temp_new_template_definition 
					
					CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT, field_type VARCHAR(200) COLLATE DATABASE_DEFAULT)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','','','','settings','','h','y',NULL,'150','n','n','y','n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','flag','flag','flag','input','char','h','n',NULL,'150','n','n','e','n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','source_system_id','source_system_id','Source System','combo','int','h','y','EXEC spa_source_system_description ''s''','200','n','n','2','n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','deal_id_from','deal_id_from','Deal ID From','input','int','h','n','','200','n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','deal_id_to','deal_id_to','Deal ID To','input','int','h','n','','200','n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','structured_deal_id','structured_deal_id','Structured Deal ID','input','int','h','n','','200','n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','deal_date_from','deal_date_from','As of Date From','calendar','date','h','y','','200','n','n','2013-06-01','y','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','deal_date_to','deal_date_to','As of Date To','calendar','date','h','y','','200','n','n','2015-06-29','y','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','entire_term_start','entire_term_start','Term Start','calendar','date','h','y','','200','n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','entire_term_end','entire_term_end','Term End','calendar','date','h','y','','200','n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','source_deal_type_id','source_deal_type_id','Deal Type','combo','int','h','y','SELECT DISTINCT 
		   d.source_deal_type_id
		  ,d.source_deal_type_name+CASE 
										WHEN ssd.source_system_id=2 THEN ''''
										ELSE ''.''+ssd.source_system_name
								   END source_system_name
	FROM   portfolio_hierarchy b
		   INNER JOIN fas_strategy c
				ON  b.parent_entity_id = c.fas_strategy_id
		   INNER JOIN source_deal_type d
				ON  d.source_system_id = c.source_system_id
					AND ISNULL(d.sub_type ,''n'') = ''n''
		   INNER JOIN source_system_description ssd
				ON  d.source_system_id = ssd.source_system_id','200','n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','deal_sub_type_type_id','deal_sub_type_type_id','Deal Sub Type','combo','int','h','n','SELECT DISTINCT 
		   d.source_deal_type_id
		  ,d.source_deal_type_name+CASE 
										WHEN ssd.source_system_id=2 THEN ''''
										ELSE ''.''+ssd.source_system_name
								   END source_system_name
	FROM   portfolio_hierarchy b
		   INNER JOIN fas_strategy c
				ON  b.parent_entity_id = c.fas_strategy_id
		   INNER JOIN source_deal_type d
				ON  d.source_system_id = c.source_system_id
					AND ISNULL(d.sub_type ,''n'') = ''y''
		   INNER JOIN source_system_description ssd
				ON  d.source_system_id = ssd.source_system_id','200','n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','deal_category_value_id','deal_category_value_id','Deal Category','combo','int','h','n','SELECT value_id, code FROM static_data_value AS sdv WHERE sdv.[type_id] = 475','200','n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','confirm_type','confirm_type','Confirmed Type','combo','int','h','n','SELECT [value_id], code AS [Code] FROM static_data_value WHERE [type_id] = 17200','200','n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','book_structure','book_structure','Book Structure','browser','varchar','h','n','','110','n','n',NULL,'y','n',NULL,NULL,'y','y','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','trader_id','trader_id','Trader','combo','int','h','n','select d.source_trader_id trader_id,
	d.trader_name + case when ssd.source_system_id=2 then '''' else ''.'' + ssd.source_system_name end  as trader_name
	from source_system_description ssd inner join source_traders d on d.source_system_id = ssd.source_system_id
	order by trader_name','200','n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','counterparty_id','counterparty_id','Counterparty','combo','int','h','n','EXEC spa_getsourcecounterparty ''s''','200','n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','description1','description1','Description 1','input','varchar','h','n','','200','n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','description2','description2','Description 2','input','varchar','h','n','','200','n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','description3','description3','Description 3','input','varchar','h','n','','200','n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','report_id','report_id','Report','input','int','h','n',NULL,'150','n','n',NULL,'n','n',NULL,NULL,'y','y','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10171300','spa_name','spa_name','Spa Name','input','varchar','h','n',NULL,'150','n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
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
				
								SELECT 'General',NULL,'y','n','1',NULL,'1C',NULL
				
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
					
					INSERT INTO #temp_old_template_fields(old_field_id, old_group_id, old_application_ui_field_id, old_fieldset_id, group_name, ui_field_id, field_alias, Default_value, default_format, validation_flag, hidden, field_size, field_type, field_id, sequence, inputHeight, udf_template_id, udf_field_name, position, dependent_field, dependent_query, old_grid_id, validation_message)
					
								SELECT 21364,3395,21348,NULL,'General','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21365,3395,21349,NULL,'General','flag',NULL,'e',NULL,NULL,'y',NULL,'input',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21366,3395,21350,NULL,'General','source_system_id',NULL,'2',NULL,NULL,'y',NULL,'combo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21367,3395,21351,NULL,'General','deal_id_from',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21368,3395,21352,NULL,'General','deal_id_to',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21369,3395,21353,NULL,'General','structured_deal_id',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21370,3395,21354,NULL,'General','deal_date_from',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21371,3395,21355,NULL,'General','deal_date_to',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21372,3395,21356,NULL,'General','entire_term_start',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21373,3395,21357,NULL,'General','entire_term_end',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21374,3395,21358,NULL,'General','source_deal_type_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21375,3395,21359,NULL,'General','deal_sub_type_type_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21376,3395,21360,NULL,'General','deal_category_value_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21377,3395,21361,NULL,'General','confirm_type',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21378,3395,21362,NULL,'General','book_structure',NULL,NULL,NULL,NULL,NULL,NULL,'browser',NULL,'0',NULL,NULL,NULL,NULL,NULL,NULL,'book',NULL UNION ALL 
								SELECT 21379,3395,21363,NULL,'General','trader_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21380,3395,21364,NULL,'General','counterparty_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21381,3395,21365,NULL,'General','description1',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21382,3395,21366,NULL,'General','description2',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21383,3395,21367,NULL,'General','description3',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21384,3395,21368,NULL,'General','report_id','','','',' ','y',NULL,'input',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 21385,3395,21369,NULL,'General','spa_name','','spa_sourcedealheader_confirm','',' ','y',NULL,'input',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				
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
				
					INSERT INTO application_ui_template_fields (application_group_id, application_ui_field_id, application_fieldset_id, field_alias, Default_value, default_format, validation_flag, hidden, field_size, field_type, field_id, sequence, inputHeight, udf_template_id, position, dependent_field, dependent_query, grid_id, validation_message) 
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
						num_column			INT
					)	
					--vivek
					INSERT INTO #temp_old_ui_layout(old_layout_grid_id, old_group_id, group_name, layout_cell, old_grid_id, grid_name, sequence, num_column)
					
								SELECT 2703,3395,'General','a','FORM',NULL,1,'3'
				
					UPDATE oul
					SET oul.new_group_id = ntg.new_id
					FROM #temp_old_ui_layout oul
					INNER JOIN #temp_new_template_group ntg ON oul.group_name = ntg.group_name
				
					UPDATE oul
					SET oul.new_grid_id = tag.new_grid_id
					FROM #temp_old_ui_layout oul
					INNER JOIN #temp_all_grids tag ON tag.old_grid_id = oul.old_grid_id
					WHERE oul.old_grid_id NOT LIKE 'FORM'
				
					INSERT INTO application_ui_layout_grid (group_id, layout_cell, grid_id, sequence, num_column) 
					SELECT	oul.new_group_id,
							oul.layout_cell,
							ISNULL(oul.new_grid_id, 'FORM'),
							oul.sequence,
							oul.num_column
				
					FROM #temp_old_ui_layout oul
COMMIT 
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
					
				PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH

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

			END
