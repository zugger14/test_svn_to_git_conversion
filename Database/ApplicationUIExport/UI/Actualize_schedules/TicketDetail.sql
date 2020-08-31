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
				WHERE aut.application_function_id = '10166612' AND auf.application_function_id IS NULL
				UNION ALL
				SELECT 
					auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
				FROM
					application_ui_filter auf
					INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
				WHERE auf.application_function_id = '10166612'  AND auf.application_function_id IS NOT NULL

				
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
					WHERE aut.application_function_id = '10166612' AND auf.application_function_id IS NULL
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
					WHERE aut.application_function_id = '10166612' AND auf.application_function_id IS NOT NULL


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
			
			IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '10166612')
			BEGIN
				
				--Store old_application_field_id from the destination and sdv.code for the UDF
				INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
				SELECT musddv.application_field_id, sdv.code
				FROM maintain_udf_static_data_detail_values musddv
				INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
				INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
				INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
				INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
				WHERE autd.application_function_id = '10166612'
				
				-- DELETE SCRIPT STARTS HERE
				
				DELETE autf2 FROM application_ui_template_fieldsets AS autf2
				INNER JOIN application_ui_template_group AS autg ON autf2.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10166612'
				
				DELETE aufd FROM application_ui_filter_details aufd
				INNER JOIN application_ui_template_fields autf ON autf.application_field_id = aufd.application_field_id
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10166612'
				
				DELETE aufd FROM application_ui_filter_details aufd
				INNER JOIN application_ui_layout_grid aulg ON aufd.layout_grid_id = aulg.application_ui_layout_grid_id
				INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10166612'	

				DELETE FROM application_ui_filter WHERE application_function_id = '10166612'
				
				DELETE auf FROM application_ui_filter auf
				INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10166612'
				
				DELETE autf FROM application_ui_template_fields AS autf
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10166612'
				
				DELETE aulg FROM application_ui_layout_grid AS aulg
				INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10166612'
				
				DELETE autg FROM application_ui_template_group AS autg 
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10166612'
				
				DELETE autd FROM application_ui_template_definition AS autd
				INNER JOIN application_ui_template AS aut ON aut.application_function_id = autd.application_function_id
				WHERE aut.application_function_id = '10166612'
				
				DELETE FROM application_ui_template
				WHERE application_function_id = '10166612'
				
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
	
				
			INSERT INTO #temp_all_grids(old_grid_id, grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at)
			
									SELECT 190,'ticket_quality',NULL,NULL,'EXEC [spa_ticket] @flag=''q'', @ticket_detail_ids=<ID>','Ticket Quality','g',NULL,NULL,NULL,NULL
				
			UPDATE tag
			SET tag.new_grid_id = agd.grid_id
			FROM #temp_all_grids tag
			INNER JOIN adiha_grid_definition AS agd
			ON agd.grid_name = tag.grid_name
				
			UPDATE tag
			SET tag.is_new = 'y'
			FROM #temp_all_grids tag
			WHERE tag.new_grid_id IS NULL
				
			IF EXISTS(SELECT 1 FROM #temp_all_grids WHERE is_new LIKE 'y')
			BEGIN
					
				INSERT INTO adiha_grid_definition (grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at)
				SELECT grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at
				FROM #temp_all_grids
				WHERE is_new LIKE 'y'
				
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
					split_at = tag.split_at
				FROM adiha_grid_definition AS agd
				INNER JOIN #temp_all_grids AS tag
				ON tag.new_grid_id = agd.grid_id
				
			END
					
				UPDATE tag
				SET tag.new_grid_id = agd.grid_id
				FROM #temp_all_grids tag
				INNER JOIN adiha_grid_definition AS agd
				ON agd.grid_name = tag.grid_name
					
				

							IF OBJECT_ID('tempdb..#temp_all_grids_columns') IS NOT NULL
								DROP TABLE #temp_all_grids_columns

							CREATE TABLE #temp_all_grids_columns(
								old_grid_id		INT,
								new_grid_id		INT,
								column_name		VARCHAR(200) COLLATE DATABASE_DEFAULT,
								column_label	VARCHAR(200) COLLATE DATABASE_DEFAULT,
								field_type		VARCHAR(200) COLLATE DATABASE_DEFAULT,
								sql_string		VARCHAR(5000) COLLATE DATABASE_DEFAULT,
								is_editable		VARCHAR(200) COLLATE DATABASE_DEFAULT,
								is_required		VARCHAR(200) COLLATE DATABASE_DEFAULT,
								column_order	INT,
								is_hidden		VARCHAR(200) COLLATE DATABASE_DEFAULT,
								fk_table		VARCHAR(200) COLLATE DATABASE_DEFAULT,
								fk_column		VARCHAR(200) COLLATE DATABASE_DEFAULT,
								is_unique		VARCHAR(200) COLLATE DATABASE_DEFAULT,
								column_width	VARCHAR(200) COLLATE DATABASE_DEFAULT,
								sorting_preference VARCHAR(200) COLLATE DATABASE_DEFAULT,
								validation_rule	VARCHAR(200) COLLATE DATABASE_DEFAULT,
								column_alignment VARCHAR(200) COLLATE DATABASE_DEFAULT
							)	
				
							INSERT INTO #temp_all_grids_columns(old_grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment)
							
												SELECT 190,'ticket_quality_id','ID','ro',NULL,'n','n',NULL,'y',NULL,NULL,NULL,'150',NULL,NULL,'left' UNION ALL 
												SELECT 190,'ticket_detail_id','Ticket Detail ID','ro',NULL,'n','n',NULL,'y',NULL,NULL,NULL,'150',NULL,NULL,'left' UNION ALL 
												SELECT 190,'quality','Quality','combo','select value_id, code from static_data_value where type_id = 29600','y','y',NULL,'n',NULL,NULL,NULL,'150',NULL,NULL,'left' UNION ALL 
												SELECT 190,'type','Type','ro',NULL,'n','n',NULL,'n',NULL,NULL,NULL,'150',NULL,NULL,'left' UNION ALL 
												SELECT 190,'value','Value','ed',NULL,'y','n',NULL,'n',NULL,NULL,NULL,'150',NULL,NULL,'left' UNION ALL 
												SELECT 190,'company','Company','combo','EXEC spa_getsourcecounterparty ''s''','y','n',NULL,'n',NULL,NULL,NULL,'150',NULL,NULL,'left' UNION ALL 
												SELECT 190,'is_average','Average','combo','SELECT ''y'' value, ''Yes'' UNION ALL SELECT ''N'' value, ''No''','y','n',NULL,'n',NULL,NULL,NULL,'150',NULL,NULL,'left'
						
							UPDATE tagc
							SET tagc.new_grid_id = tag.new_grid_id
							FROM #temp_all_grids_columns tagc
							INNER JOIN #temp_all_grids tag
							ON tag.old_grid_id = tagc.old_grid_id
							--WHERE tag.is_new LIKE 'y']
							
							DELETE agcd FROM adiha_grid_columns_definition agcd
							INNER JOIN #temp_all_grids tag
							ON agcd.grid_id = tag.new_grid_id
								
							INSERT INTO adiha_grid_columns_definition(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment)
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
									tagc.column_alignment
										
							FROM #temp_all_grids_columns tagc
							INNER JOIN #temp_all_grids tag
							ON tag.old_grid_id = tagc.old_grid_id
							--WHERE tag.is_new LIKE 'y'
					
INSERT INTO application_ui_template (application_function_id, template_name, template_description, active_flag, default_flag, table_name, is_report, edit_permission, delete_permission) 
VALUES('10166612',
						'TicketDetail',
						'TicketDetail',
						'y',
						'y',
						'ticket_detail',
						'n',
						'10102801',
						'10102802')
DECLARE @application_ui_template_id_new INT
			SET @application_ui_template_id_new = SCOPE_IDENTITY() 
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '10166612') BEGIN 
	IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
					DROP TABLE #temp_new_template_definition 
					
					CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT, field_type VARCHAR(200) COLLATE DATABASE_DEFAULT)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','','','','settings','',' ',' ','',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','ticket_detail_id','ticket_detail_id','ID','input','INT','h','n',NULL,NULL,'y','n',NULL,'n','n','n','n','n','y','n','y',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','line_item','line_item','Line Item','input','INT','h','y',NULL,NULL,'y','n',NULL,'y','n','n','n','n','y','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','location_id','location_id','Movement Location','combo','int','h','y','EXEC spa_source_minor_location ''o'', @is_active = ''y''',NULL,'n','n',NULL,'y','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','movement_date_time','movement_date_time','Movement Date/Time','calendar','datetime','h','y','select 1 value, ''container1'' text ',NULL,'n','n',NULL,'y','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','automatch_status','automatch_status','Automatch Status','combo','char','h','y','SELECT ''a'' AS value, ''Automate'' AS text union all SELECT ''d'', ''Do not Automate'' union all select ''e'', ''Error'' ',NULL,'n','n',NULL,'y','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','gross_quantity','gross_quantity','Gross Quantity','input','numeric','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','net_quantity','net_quantity','Net Quantity','input','numeric','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','quantity_uom','quantity_uom','Quantity UOM','combo','int','h','n','exec spa_getsourceuom @flag=''s'', @uom_type = 44303',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','gross_weight','gross_weight','Gross Weight','input','float','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','term_start','term_start','Term Start','calendar','datetime','h','y',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','term_end','term_end','Term End','calendar','datetime','h','y',NULL,NULL,'n','y',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','carrier','carrier','Carrier','combo','int','h','y','SELECT 1, ''Carrier 1''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','vessel','vessel','Vessel','combo','int','h','y','select 1 value, ''container1'' text ',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','container_number','container_number','Container Number','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','origin','origin','Origin','combo','int','h','y','EXEC spa_source_minor_location ''o'', @is_active = ''y''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','destination','destination','Destination','combo','int','h','y','EXEC spa_source_minor_location ''o'', @is_active = ''y''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','temperature','temperature','Temperature','input','int','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','temp_scale_f_c','temp_scale_f_c','Temperature Scale F/C','combo','char','h','y','select ''c'' value, ''Celcius'' text UNION ALL select ''f'' value, ''Farenheit'' text',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','api_gravity','api_gravity','API Gravity','input','float','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','specific_gravity','specific_gravity','Specific Gravity','input','float','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','shipper','shipper','Shipper','combo','int','h','y','EXEC spa_source_counterparty_maintain ''c''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','consginee','consginee','Consginee','combo','int','h','y','EXEC spa_source_counterparty_maintain ''c''',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','ticket_matching_no','ticket_matching_no','Ticket Matching No','input','int','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','lot','lot','System Lot','input','int','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','Batch_id','Batch_id','Production Batch ID','input','varchar','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','crop_year','crop_year','Crop Year','combo','int','h','y','SELECT n + 1999 , n + 1999 FROM seq WHERE n < 102',NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','incoterm','incoterm','INCOterm','combo','int','h','y','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 40200',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','density','density','Density','input','float','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','density_uom','density_uom','Density UOM','combo','int','h','y','exec spa_getsourceuom @flag=''s'', @uom_type = 44305',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','weight_uom','weight_uom','Weight UOM','combo','int','h','y','exec spa_getsourceuom @flag=''s'', @uom_type = 44304',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','net_weight','net_weight','Net Weight','input','float','h','y','EXEC [spa_source_uom_maintain] ''s''',NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','bsw','bsw','BSW','input','numeric','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','lease_measurement','lease_measurement','Lease Measurement','combo','int','h','y','SELECT 1 , ''LACT'' UNION ALL SELECT 2, ''Gauge'' UNION ALL SELECT 3, ''Meter'' ORDER BY 2',NULL,'n','n',NULL,'n','n','n','n','y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','product_commodity','product_commodity','Commodity','combo','int','h','y','EXEC spa_source_commodity_maintain ''a''',NULL,'n','n',NULL,'y','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','product_origin','product_origin','Product Origin','combo','int','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','form','form','Form','combo','int','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','organic','organic','Organic','checkbox','char','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','attribute1','attribute1','Attribute 1','combo','int','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','attribute2','attribute2','Attribute 2','combo','int','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','attribute3','attribute3','Attribute 3','combo','int','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','attribute4','attribute4','Attribute 4','combo','int','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10166612','attribute5','attribute5','Attribute 5','combo','int','h','y',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL)
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
				
								SELECT 'Detail',NULL,'y','y','1',NULL,NULL,NULL UNION ALL 
								SELECT 'Additional',NULL,'y','n','2',NULL,NULL,NULL UNION ALL 
								SELECT 'Product',NULL,'y','n','3',NULL,NULL,NULL UNION ALL 
								SELECT 'Quality',NULL,'y','n','4',NULL,NULL,NULL
				
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
					
								SELECT 72848,13443,72599,NULL,'Detail','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72849,13443,72600,NULL,'Detail','ticket_detail_id',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72850,13443,72601,NULL,'Detail','line_item',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72851,13443,72602,NULL,'Detail','location_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72852,13443,72626,NULL,'Detail','incoterm',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72853,13443,72603,NULL,'Detail','movement_date_time',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72854,13443,72604,NULL,'Detail','automatch_status',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72855,13443,72605,NULL,'Detail','gross_quantity',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72856,13443,72606,NULL,'Detail','net_quantity',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72857,13443,72607,NULL,'Detail','quantity_uom',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72858,13443,72608,NULL,'Detail','gross_weight',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72859,13443,72630,NULL,'Detail','net_weight',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72860,13443,72629,NULL,'Detail','weight_uom',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72861,13444,72599,NULL,'Additional','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72862,13444,72614,NULL,'Additional','origin',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72863,13444,72615,NULL,'Additional','destination',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72864,13444,72616,NULL,'Additional','temperature',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72865,13444,72617,NULL,'Additional','temp_scale_f_c',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72866,13444,72618,NULL,'Additional','api_gravity',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72867,13444,72619,NULL,'Additional','specific_gravity',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72868,13444,72628,NULL,'Additional','density_uom',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72869,13444,72620,NULL,'Additional','shipper',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72870,13444,72621,NULL,'Additional','consginee',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72871,13444,72622,NULL,'Additional','ticket_matching_no',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72872,13444,72631,NULL,'Additional','bsw',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72873,13444,72632,NULL,'Additional','lease_measurement',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72874,13444,72611,NULL,'Additional','carrier',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72875,13444,72612,NULL,'Additional','vessel',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72876,13444,72613,NULL,'Additional','container_number',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72877,13445,72599,NULL,'Product','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72878,13445,72633,NULL,'Product','product_commodity',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'23',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72879,13445,72634,NULL,'Product','product_origin',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'24',NULL,NULL,NULL,NULL,'product_commodity','EXEC spa_counterparty_products @flag=''o'',@dependent_id=''<product_commodity>''',NULL,NULL UNION ALL 
								SELECT 72880,13445,72636,NULL,'Product','organic',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,'24',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72881,13445,72635,NULL,'Product','form',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'25',NULL,NULL,NULL,NULL,'product_origin','EXEC spa_counterparty_products @flag=''f'',@dependent_id=''<product_origin>''',NULL,NULL UNION ALL 
								SELECT 72882,13445,72637,NULL,'Product','attribute1',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'26',NULL,NULL,NULL,NULL,'form','EXEC spa_counterparty_products @flag=''a'',@dependent_id=''<form>''',NULL,NULL UNION ALL 
								SELECT 72883,13445,72638,NULL,'Product','attribute2',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'27',NULL,NULL,NULL,NULL,'attribute1','EXEC spa_counterparty_products @flag=''b'',@dependent_id=''<attribute1>''',NULL,NULL UNION ALL 
								SELECT 72884,13445,72639,NULL,'Product','attribute3',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'28',NULL,NULL,NULL,NULL,'attribute2','EXEC spa_counterparty_products @flag=''c'',@dependent_id=''<attribute2>''',NULL,NULL UNION ALL 
								SELECT 72885,13445,72640,NULL,'Product','attribute4',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'29',NULL,NULL,NULL,NULL,'attribute3','EXEC spa_counterparty_products @flag=''e'',@dependent_id=''<attribute3>''',NULL,NULL UNION ALL 
								SELECT 72886,13445,72641,NULL,'Product','attribute5',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'30',NULL,NULL,NULL,NULL,'attribute4','EXEC spa_counterparty_products @flag=''g'',@dependent_id=''<attribute4>''',NULL,NULL UNION ALL 
								SELECT 72887,13445,72625,NULL,'Product','crop_year',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'31',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72888,13445,72623,NULL,'Product','lot',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'32',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 72889,13445,72624,NULL,'Product','Batch_id',NULL,NULL,'SQL:NULLIF(value, -1)',NULL,NULL,NULL,'input',NULL,'33',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				
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
					
								SELECT 11902,13443,'Detail','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 11903,13444,'Additional','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 11904,13445,'Product','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 11905,13446,'Quality','a','190','ticket_quality',1,'2',NULL,NULL,NULL
				
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
							LEFT JOIn #temp_old_ui_layout tolg ON tolg.group_name = toduf.group_name AND tolg.layout_cell = toduf.layout_cell
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