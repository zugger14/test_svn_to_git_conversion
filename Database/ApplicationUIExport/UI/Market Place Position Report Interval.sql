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
						group_name					VARCHAR(100),
						user_login_id				VARCHAR(100),
						application_ui_filter_name	VARCHAR(100),
						application_function_id		INT
						)

			CREATE TABLE #temp_old_application_ui_filter_details (
						application_ui_filter_id	INT,
						application_field_id		INT,
						field_value					VARCHAR(1000),
						field_id					VARCHAR(100)
						)
			INSERT INTO  #temp_old_application_ui_filter (application_ui_filter_id,application_group_id,group_name,user_login_id,application_ui_filter_name,application_function_id)
				SELECT 
					auf.application_ui_filter_id,auf.application_group_id,autg.group_name,auf.user_login_id,auf.application_ui_filter_name,NULL
				FROM
					application_ui_filter auf
					INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
					INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10202120' AND auf.application_function_id IS NULL
				UNION ALL
				SELECT 
					auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
				FROM
					application_ui_filter auf
					INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
				WHERE auf.application_function_id = '10202120'  AND auf.application_function_id IS NOT NULL

				
				INSERT INTO  #temp_old_application_ui_filter_details(application_ui_filter_id,application_field_id,field_value,field_id)
				SELECT 
					aufd.application_ui_filter_id,aufd.application_field_id,aufd.field_value,autd.field_id
				FROM 
					application_ui_filter_details aufd
					INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id
					INNER JOIN application_ui_template_fields autf ON autf.application_field_id = aufd.application_field_id
					INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
					INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
					INNER JOIN application_ui_template_definition AS autd
						ON autd.application_ui_field_id = autf.application_ui_field_id
					WHERE aut.application_function_id = '10202120' AND auf.application_function_id IS NULL
				UNION ALL
				SELECT 
					aufd.application_ui_filter_id,aufd.application_field_id,aufd.field_value,autd.field_id
				FROM 
					application_ui_filter_details aufd
					INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id
					INNER JOIN application_ui_template_fields autf ON autf.application_field_id = aufd.application_field_id
					INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
					INNER JOIN application_ui_template_definition AS autd
						ON autd.application_ui_field_id = autf.application_ui_field_id
					WHERE aut.application_function_id = '10202120' AND auf.application_function_id IS NOT NULL


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
						sdv_code						VARCHAR(200)
					)
			
			IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '10202120')
			BEGIN
				
				--Store old_application_field_id from the destination and sdv.code for the UDF
				INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
				SELECT musddv.application_field_id, sdv.code
				FROM maintain_udf_static_data_detail_values musddv
				INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
				INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
				INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
				INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
				WHERE autd.application_function_id = '10202120'
				
				-- DELETE SCRIPT STARTS HERE
				
				DELETE autf2 FROM application_ui_template_fieldsets AS autf2
				INNER JOIN application_ui_template_group AS autg ON autf2.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10202120'
				
				DELETE aufd FROM application_ui_filter_details aufd
				INNER JOIN application_ui_template_fields autf ON autf.application_field_id = aufd.application_field_id
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10202120'
				
				DELETE FROM application_ui_filter WHERE application_function_id = '10202120'
				
				DELETE auf FROM application_ui_filter auf
				INNER JOIN application_ui_template_group AS autg ON auf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10202120'
				
				DELETE autf FROM application_ui_template_fields AS autf
				INNER JOIN application_ui_template_group AS autg ON autf.application_group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10202120'
				
				DELETE aulg FROM application_ui_layout_grid AS aulg
				INNER JOIN application_ui_template_group AS autg ON aulg.group_id = autg.application_group_id
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10202120'
				
				DELETE autg FROM application_ui_template_group AS autg 
				INNER JOIN application_ui_template AS aut ON aut.application_ui_template_id = autg.application_ui_template_id
				WHERE aut.application_function_id = '10202120'
				
				DELETE autd FROM application_ui_template_definition AS autd
				INNER JOIN application_ui_template AS aut ON aut.application_function_id = autd.application_function_id
				WHERE aut.application_function_id = '10202120'
				
				DELETE FROM application_ui_template
				WHERE application_function_id = '10202120'
				
			END 

			IF OBJECT_ID('tempdb..#temp_all_grids') IS NOT NULL
				DROP TABLE #temp_all_grids

			CREATE TABLE #temp_all_grids (
				old_grid_id		INT,
				new_grid_id     INT,
				grid_name       varchar(200),
				fk_table		VARCHAR(200),
				fk_column		VARCHAR(200),
				load_sql		VARCHAR(800),
				grid_label		VARCHAR(200),
				grid_type		VARCHAR(200),
				grouping_column	VARCHAR(200),
				is_new			VARCHAR(200),
				edit_permission VARCHAR(200),
				delete_permission VARCHAR(200)
			) 
INSERT INTO application_ui_template (application_function_id, template_name, template_description, active_flag, default_flag, table_name, is_report, edit_permission, delete_permission) 
VALUES('10202120',
						'Market Place Position Report Interval',
						'Market Place Position Report Interval',
						'y',
						'y',
						NULL,
						'y',
						NULL,
						NULL)
DECLARE @application_ui_template_id_new INT
			SET @application_ui_template_id_new = SCOPE_IDENTITY() 
	IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '10202120') BEGIN 
	IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
					DROP TABLE #temp_new_template_definition 
					
					CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200), field_type VARCHAR(200))
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10202120','','','','settings','','h','y',NULL,'150','n','n','y','n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10202120','flag','flag','flag','input','char','h','n',NULL,'150','n','n','e','n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10202120','book_structure','book_structure','Book Structure','browser','varchar','h','n','','110','n','n',NULL,'n','n',NULL,NULL,'y','y','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10202120','report_id','report_id','Report','input','int','h','n',NULL,'150','n','n',NULL,'n','n',NULL,NULL,'y','y','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10202120','spa_name','spa_name','Spa Name','input','varchar','h','n',NULL,'150','n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL)
	INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length) 
				OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
				INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
				VALUES('10202120','enable_paging','enable_paging','Apply Paging','checkbox','boolean','h','n',NULL,'100','n','n',NULL,'n','n',NULL,NULL,'y','y','n','n',NULL,NULL,NULL)
 END 
	
				IF OBJECT_ID('tempdb..#temp_old_template_group') IS NOT NULL
					DROP TABLE #temp_old_template_group

				CREATE TABLE #temp_old_template_group (
					application_ui_template_id	INT,
					group_name					VARCHAR(200),
					group_description			VARCHAR(200),
					active_flag					VARCHAR(200),
					default_flag				VARCHAR(200),
					sequence					INT,
					inputWidth					INT,
					field_layout				VARCHAR(200),
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
	
				CREATE TABLE #temp_new_template_group (new_id INT, group_name VARCHAR(200))
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
					group_name          VARCHAR(200),
					fieldset_name		VARCHAR(200),
					className			VARCHAR(200),
					is_disable			VARCHAR(200),
					is_hidden			VARCHAR(200),
					inputLeft			INT,
					inputTop			INT,
					label				VARCHAR(200),
					offsetLeft			INT,
					offsetTop			INT,
					position			VARCHAR(200),
					width				INT,
					sequence			INT,
					num_column			INT
				)
				
				IF OBJECT_ID('tempdb..#temp_new_template_fieldsets') IS NOT NULL
					DROP TABLE #temp_new_template_fieldsets	
	
				CREATE TABLE #temp_new_template_fieldsets (new_id INT, group_id INT, fieldset_name VARCHAR(200))							
				
	
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
						group_name						VARCHAR(200),
						ui_field_id						VARCHAR(200),
						field_alias						VARCHAR(200),
						Default_value					VARCHAR(200),
						default_format					VARCHAR(200),
						validation_flag					VARCHAR(200),
						hidden							VARCHAR(200),
						field_size						VARCHAR(200),
						field_type						VARCHAR(200),
						field_id						VARCHAR(200),
						sequence						INT,
						inputHeight						VARCHAR(200),
						udf_template_id					INT,
						udf_field_name					INT,
						position						VARCHAR(200),
						dependent_field					VARCHAR(200),
						dependent_query					VARCHAR(MAX),
						old_grid_id						VARCHAR(200),
						new_grid_id						VARCHAR(200),
						validation_message				VARCHAR(200)
					)	
					
					IF OBJECT_ID('tempdb..#temp_new_template_fields') IS NOT NULL
						DROP TABLE #temp_new_template_fields 
					
					CREATE TABLE #temp_new_template_fields (new_field_id INT, new_definition_id INT, sdv_code varchar(200))	
					
					INSERT INTO #temp_old_template_fields(old_field_id, old_group_id, old_application_ui_field_id, old_fieldset_id, group_name, ui_field_id, field_alias, Default_value, default_format, validation_flag, hidden, field_size, field_type, field_id, sequence, inputHeight, udf_template_id, udf_field_name, position, dependent_field, dependent_query, old_grid_id, validation_message)
					
								SELECT 30007,5252,29932,NULL,'General','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 30008,5252,29933,NULL,'General','flag',NULL,'r',NULL,NULL,'y',NULL,'input',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 30009,5252,29934,NULL,'General','book_structure',NULL,NULL,NULL,NULL,NULL,NULL,'browser',NULL,'0',NULL,NULL,NULL,NULL,NULL,NULL,'book',NULL UNION ALL 
								SELECT 30010,5252,29935,NULL,'General','report_id','','','',' ','y',NULL,'input',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 30011,5252,29936,NULL,'General','spa_name','','spa_import_northpool_deals','',' ','y',NULL,'input',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
								SELECT 30012,5252,29937,NULL,'General','enable_paging',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				
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
						CREATE TABLE #temp_new_filter(application_ui_filter_id INT,application_ui_filter_name VARCHAR(100))

						INSERT INTO application_ui_filter(application_group_id,user_login_id,application_ui_filter_name,application_function_id)
						OUTPUT INSERTED.application_ui_filter_id, INSERTED.application_ui_filter_name
						INTO #temp_new_filter (application_ui_filter_id, application_ui_filter_name)
						SELECT 
							tntg.new_id,toduf.user_login_id,toduf.application_ui_filter_name,toduf.application_function_id
						FROM
							#temp_old_application_ui_filter toduf
							LEFT JOIN #temp_new_template_group tntg ON tntg.group_name = toduf.group_name

						INSERT INTO application_ui_filter_details(application_ui_filter_id,application_field_id,field_value)
						SELECT 
							tnf.application_ui_filter_id,tntf.new_field_id,toduf.field_value
						FROM
							#temp_old_application_ui_filter_details toduf
							LEFT JOIN #temp_new_template_definition tntd ON tntd.field_id = toduf.field_id
							LEFT JOIN #temp_old_template_fields ontf ON ontf.ui_field_id  = toduf.field_id
							LEFT JOIN #temp_new_template_fields tntf ON tntf.new_definition_id = tntd.new_definition_id
							LEFT JOIN #temp_old_application_ui_filter tt ON tt.application_ui_filter_id = toduf.application_ui_filter_id
							LEFT JOIN #temp_new_filter tnf ON tnf.application_ui_filter_name = tt.application_ui_filter_name

					END
						
					
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