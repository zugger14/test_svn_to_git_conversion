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
		WHERE aut.application_function_id = '10102600' AND auf.application_function_id IS NULL
		UNION ALL
		SELECT 
			auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
		FROM
			application_ui_filter auf
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
		WHERE auf.application_function_id = '10102600'  AND auf.application_function_id IS NOT NULL

				
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
			WHERE aut.application_function_id = '10102600' AND auf.application_function_id IS NULL
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
			WHERE aut.application_function_id = '10102600' AND auf.application_function_id IS NOT NULL
	
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
			
		IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '10102600')
		BEGIN				
			--Store old_application_field_id from the destination and sdv.code for the UDF
			INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
			SELECT musddv.application_field_id, sdv.code
			FROM maintain_udf_static_data_detail_values musddv
			INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
			INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
			INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
			WHERE autd.application_function_id = '10102600'
				
			-- DELETE SCRIPT STARTS HERE
				
			EXEC spa_application_ui_template 'd', 10102600
				
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
	
				
		INSERT INTO #temp_all_grids(old_grid_id, grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at)
		SELECT 78,'var_time_bucket_mapping',NULL,NULL,'EXEC spa_var_time_bucket_mapping @flag=''g'',@curve_id =<ID>','Risk Bucketing','g',NULL,'10102600','10102600',NULL UNION ALL SELECT 79,'price_curve_fv_mapping',NULL,NULL,'EXEC spa_fair_value_reporting_group @flag = ''g'', @source_curve_def_id = <ID>','Fair Value Reporting','g',NULL,'10102600','10102600',NULL UNION ALL SELECT 407,'rtc_source_price_curve',NULL,NULL,'EXEC spa_rtc_price_curve @flag = ''s'', @source_curve_def_id = <ID>','RTC Price Curve','g',NULL,'10102600','10102600',NULL
				
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
			browser_grid_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
			allow_multi_select VARCHAR(200) COLLATE DATABASE_DEFAULT,
			rounding VARCHAR(10) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO #temp_all_grids_columns(old_grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment, browser_grid_id, allow_multi_select, rounding)
		
		SELECT 78,'map_id','Bucket ID','ro_int',NULL,'n','y','1','y',NULL,NULL,'y','100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 78,'effective_date','Effective Date','dhxCalendarA',NULL,'y','y','2','n',NULL,NULL,NULL,'200','date',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 78,'from_no_of_months','From No. of Months','ed_int',NULL,'y','y','3','n',NULL,NULL,NULL,'200','int','NotEmpty','left', NULL,'n',NULL UNION ALL 
		SELECT 78,'to_no_of_months','To No. of Months','ed_int',NULL,'y','y','4','n',NULL,NULL,NULL,'200','int','NotEmpty','left', NULL,'n',NULL UNION ALL 
		SELECT 78,'map_no_of_months','Map No. of Months','ed_int',NULL,'y','y','5','n',NULL,NULL,NULL,'200','int','NotEmpty','left', NULL,'n',NULL UNION ALL 
		SELECT 78,'risk_bucket','Risk Bucket','combo','EXEC spa_source_price_curve_def_maintain ''l''','y','y','6','n',NULL,NULL,NULL,'200','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 78,'shift_by','Shift By','combo','SELECT ''1'' AS [id], ''Value'' AS [code] UNION ALL SELECT  ''2'' AS [id], ''Percentage'' AS [code]','y','y','7','n',NULL,NULL,NULL,'200','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 78,'shift_value','Shift Value','ed',NULL,'y','y','8','n',NULL,NULL,NULL,'200','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 78,'curve_id','Curve ID','ro_int',NULL,'n','y','9','y','source_price_curve_def','source_curve_def_id',NULL,'200','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 79,'effective_date','Effective Date','dhxCalendarA',NULL,'y','y','2','n',NULL,NULL,NULL,'200','date',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 79,'from_no_of_months','Month From','ed_int',NULL,'y','y','3','n',NULL,NULL,NULL,'200','int','NotEmpty','left', NULL,'n',NULL UNION ALL 
		SELECT 79,'to_no_of_months','Month To','ed_int',NULL,'y','y','4','n',NULL,NULL,NULL,'200','int','NotEmpty','left', NULL,'n',NULL UNION ALL 
		SELECT 79,'fv_reporting_group_id','Fair Value Reporting Group','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10094','n','y','5','n',NULL,NULL,NULL,'200','str','ValidInteger','left', NULL,'n',NULL UNION ALL 
		SELECT 79,'source_curve_def_id','ID','ro_int',NULL,'n','y','6','y','source_price_curve_def','source_curve_def_id',NULL,'100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 79,'spc_fv_id','Fair Value ID','ro_int',NULL,'n','y','1','y',NULL,NULL,'y','100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 407,'rtc_curve_id','RTC ID','ro',NULL,'n','n','1','y',NULL,NULL,'y','100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 407,'rtc_curve_def_id','Curve ID','ro_int',NULL,'n','n','2','y','source_price_curve_def','source_curve_def_id',NULL,'100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 407,'rtc_curve','RTC Price Curve','combo','EXEC spa_source_price_curve_def_maintain ''l''','y','y','3','n',NULL,NULL,NULL,'200','str',NULL,'left', NULL,'n',NULL

		UPDATE tagc
		SET tagc.new_grid_id = tag.new_grid_id
		FROM #temp_all_grids_columns tagc
		INNER JOIN #temp_all_grids tag
		ON tag.old_grid_id = tagc.old_grid_id
		--WHERE tag.is_new LIKE 'y']

		DELETE agcd FROM adiha_grid_columns_definition agcd
		INNER JOIN #temp_all_grids tag
		ON agcd.grid_id = tag.new_grid_id

		INSERT INTO adiha_grid_columns_definition(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment, browser_grid_id, allow_multi_select, rounding)
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
				tagc.browser_grid_id,
				tagc.allow_multi_select,
				tagc.rounding
										
		FROM #temp_all_grids_columns tagc
		INNER JOIN #temp_all_grids tag
		ON tag.old_grid_id = tagc.old_grid_id
		--WHERE tag.is_new LIKE 'y'
		
		INSERT INTO application_ui_template (application_function_id, template_name, template_description, active_flag, default_flag, table_name, is_report, edit_permission, delete_permission, template_type) 
		
		VALUES('10102600',
		'SetupPriceCurves',
		'Setup Price Curves',
		'y',
		'y',
		'source_price_curve_def',
		NULL,
		'10102610',
		'10102611',
		'102812')

		DECLARE @application_ui_template_id_new INT
		SET @application_ui_template_id_new = SCOPE_IDENTITY() 
		IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '10102600') 
		BEGIN 
		
			IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
				DROP TABLE #temp_new_template_definition 
					
			CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT , field_type VARCHAR(200) COLLATE DATABASE_DEFAULT )
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','','','','settings','',' ',' ','',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','source_curve_def_id','source_curve_def_id','System ID','input','int','h','n',NULL,NULL,'y','n','','n','n','n','y','n','y','n','y',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','source_system_id','source_system_id','Source System','combo','int','h','n','EXEC spa_source_system_description ''s''',NULL,'n','y','2','y','n','n','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','source_curve_type_value_id','source_curve_type_value_id','Curve Type','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 575',NULL,'n','n','','y','n','y','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','curve_name','curve_name','Name','input','varchar','h','n',NULL,NULL,'n','n','','y','n','y','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','curve_des','curve_des','Remit Description','input','varchar','h','n',NULL,NULL,'n','n','','n','n','n','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','curve_id','curve_id','Curve ID','input','varchar','h','n',NULL,NULL,'n','n','','n','n','n','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','granularity','granularity','Granularity','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 978',NULL,'n','n','','y','n','y','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','source_currency_id','source_currency_id','Currency','combo','int','h','n','EXEC spa_source_currency_maintain ''p''',NULL,'n','n','','y','n','y','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','source_currency_to_id','source_currency_to_id','Currency To','combo','int','h','n','EXEC spa_source_currency_maintain ''p''',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','uom_id','uom_id','UOM','combo','int','h','n','EXEC spa_source_uom_maintain ''c''',NULL,'n','n','','y','n','y','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','commodity_id','commodity_id','Commodity','combo','int','h','n','EXEC spa_source_commodity_maintain ''a''',NULL,'n','n','','y','n','y','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','market_value_desc','market_value_desc','Market','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 29700',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','index_group','index_group','Index Group','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 15100',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','is_active','is_active','Active','checkbox','char','h','n',NULL,NULL,'n','n','y','n','n','n','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','formula_id','formula_id','Formula','browser','int','h','n',NULL,NULL,'n','n','','n','n','n','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','curve_tou','curve_tou','Time of Use','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 18900',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','udf_block_group_id','udf_block_group_id','TOU Group','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 15001',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','block_define_id','block_define_id','Block Definition','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10018',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,'10101000',NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','exp_calendar_id','exp_calendar_id','Expiration Calender','combo','int','h','n','SELECT value_id, code FROM static_data_value WHERE [type_id] = 10017 AND category_id = 38701',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,'10101000',NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','holiday_calendar_id','holiday_calendar_id','Holiday Calender','combo','int','h','n','SELECT value_id, code FROM static_data_value WHERE [type_id] = 10017 AND category_id = 38700',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,'10101000',NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','time_zone','time_zone','Timezone','combo','int','h','n','SELECT TIMEZONE_ID, TIMEZONE_NAME FROM time_zones',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','obligation','obligation','Environment Product','checkbox','varchar','h','n',NULL,NULL,'n','n','','n','n','n','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','curve_definition','curve_definition','Long Description','input','varchar','h','n',NULL,NULL,'n','n','','n','n','n','y','n','n','n','n','5',NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','risk_bucket_id','risk_bucket_id','Risk Bucket','combo','int','h','n','EXEC spa_source_price_curve_def_maintain ''l''',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','monte_carlo_model_parameter_id','monte_carlo_model_parameter_id','Risk Factor Model','combo','int','h','n','SELECT monte_carlo_model_parameter_id, monte_carlo_model_parameter_name FROM monte_carlo_model_parameter',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','fv_level','fv_level','Fair Value Reporting Group','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10094',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','proxy_curve_id','proxy_curve_id','Reporting Curves','combo','int','h','n','EXEC spa_source_price_curve_def_maintain ''l''',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','display_uom_id','display_uom_id','Reporting UOM','combo','int','h','n','EXEC spa_source_uom_maintain ''c''',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','derive_on_calculation','derive_on_calculation','Derive on calculation','checkbox','varchar','h','n',NULL,NULL,'n','n','','n','n','n','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','hourly_volume_allocation','hourly_volume_allocation','Financial Break Down','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 17600',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','ratio_option','ratio_option','Ratio Option','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 18800',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','asofdate_current_month','asofdate_current_month','Always use As of Date in Current Month','checkbox','varchar','h','n',NULL,'245','n','n','','n','n','n','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','proxy_source_curve_def_id','proxy_source_curve_def_id','Proxy Curve 1','combo','int','h','n','EXEC spa_source_price_curve_def_maintain ''l''',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','monthly_index','monthly_index','Proxy Curve 2','combo','int','h','n','EXEC spa_source_price_curve_def_maintain ''l''',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','proxy_curve_id3','proxy_curve_id3','Proxy Curve 3','combo','int','h','n','EXEC spa_source_price_curve_def_maintain ''l''',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','settlement_curve_id','settlement_curve_id','Settlement Curve','combo','int','h','n','EXEC spa_source_price_curve_def_maintain ''l''',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','forward_settle','forward_settle','Forward/Settlement','combo','char','h','n','SELECT ''f'' as value_id,''Forward'' as code  UNION SELECT ''s''as value_id,''Settlement'' as code',NULL,'n','n','','n','n','n','y','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','market_value_id','market_value_id','Market Value ID','input','varchar','h','n',NULL,NULL,'n','n','','n','n','n','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','liquidation_multiplier','liquidation_multiplier','Multiplier','browser','int','h','n',NULL,NULL,'n','n','','n','n','n','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','effective_date','effective_date','Effective Date','checkbox','char','h','n',NULL,NULL,'n','n','','n','n','n','y','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','conversion_value_id','conversion_value_id','Conversion Name','combo','int','h','n','EXEC spa_staticDataValues @flag=''h'', @type_id =112400',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10102600','location_id','location_id','Location Name','combo','int','h','n',' EXEC spa_source_minor_location @flag = ''o''',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
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
		SELECT 'General',NULL,'y','y','1',NULL,'1C',NULL UNION ALL SELECT 'Additional',NULL,'y','n','2',NULL,'2E',NULL UNION ALL SELECT 'Risk Bucketing',NULL,'y','n','3',NULL,'2E',NULL UNION ALL SELECT 'Fair Value Reporting',NULL,'y','n','4',NULL,'2E',NULL UNION ALL SELECT 'Valuation',NULL,'y','n','5',NULL,'1C',NULL
				
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
		
								SELECT 9782,20263,'Valuation','position',NULL,'n','n','500','500','Position',NULL,NULL,NULL,'800','1','3' UNION ALL 
								SELECT 9783,20263,'Valuation','forward_proxy_curves',NULL,'n','n','500','500','Forward Proxy Curves',NULL,NULL,NULL,'800','2','3' UNION ALL 
								SELECT 9784,20263,'Valuation','settlement_curve',NULL,'n','n','500','500','Settlement',NULL,NULL,NULL,'800','3','3'
				
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
			validation_message				VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			load_child_without_parent		BIT
		)	
					
		IF OBJECT_ID('tempdb..#temp_new_template_fields') IS NOT NULL
			DROP TABLE #temp_new_template_fields 
					
		CREATE TABLE #temp_new_template_fields (new_field_id INT, new_definition_id INT, sdv_code varchar(200) COLLATE DATABASE_DEFAULT )	
					
		INSERT INTO #temp_old_template_fields(old_field_id, old_group_id, old_application_ui_field_id, old_fieldset_id, group_name, ui_field_id, field_alias, Default_value, default_format, validation_flag, hidden, field_size, field_type, field_id, sequence, inputHeight, udf_template_id, udf_field_name, position, dependent_field, dependent_query, old_grid_id, validation_message, load_child_without_parent)
		
		SELECT 116539,20259,115323,NULL,'General','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116540,20259,115324,NULL,'General','source_curve_def_id',NULL,'',NULL,NULL,'n',NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116541,20259,115325,NULL,'General','source_system_id',NULL,'2',NULL,NULL,'y',NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116542,20259,115326,NULL,'General','source_curve_type_value_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116543,20259,115327,NULL,'General','curve_name',NULL,'',NULL,NULL,'n',NULL,'input',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116544,20259,115328,NULL,'General','curve_des',NULL,'',NULL,NULL,'n',NULL,'input',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116545,20259,115329,NULL,'General','curve_id',NULL,'',NULL,NULL,'n',NULL,'input',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116546,20259,115330,NULL,'General','granularity',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116547,20259,115331,NULL,'General','source_currency_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116548,20259,115332,NULL,'General','source_currency_to_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116549,20259,115333,NULL,'General','uom_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116550,20259,115334,NULL,'General','commodity_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116551,20259,115335,NULL,'General','market_value_desc',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116552,20259,115336,NULL,'General','index_group',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116553,20259,115337,NULL,'General','is_active',NULL,'y',NULL,NULL,'n',NULL,'checkbox',NULL,'19',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116554,20259,115362,NULL,'General','liquidation_multiplier',NULL,'',NULL,NULL,'n',NULL,'browser',NULL,'16',NULL,NULL,NULL,NULL,NULL,NULL,'browse_curve',NULL,NULL UNION ALL 
		SELECT 116555,20259,115365,NULL,'General','location_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116556,20259,115364,NULL,'General','conversion_value_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116557,20259,115363,NULL,'General','effective_date',NULL,'',NULL,NULL,'n',NULL,'checkbox',NULL,'18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116558,20260,115323,NULL,'Additional','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116559,20260,115338,NULL,'Additional','formula_id',NULL,'',NULL,NULL,'n',NULL,'browser',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,'formula',NULL,NULL UNION ALL 
		SELECT 116560,20260,115339,NULL,'Additional','curve_tou',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116561,20260,115340,NULL,'Additional','udf_block_group_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116562,20260,115341,NULL,'Additional','block_define_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116563,20260,115342,NULL,'Additional','exp_calendar_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116564,20260,115343,NULL,'Additional','holiday_calendar_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116565,20260,115344,NULL,'Additional','time_zone',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116566,20260,115345,NULL,'Additional','obligation',NULL,'',NULL,NULL,'n',NULL,'checkbox',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116567,20261,115323,NULL,'Risk Bucketing','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116568,20261,115347,NULL,'Risk Bucketing','risk_bucket_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116569,20261,115348,NULL,'Risk Bucketing','monte_carlo_model_parameter_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116570,20262,115323,NULL,'Fair Value Reporting','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116571,20262,115349,NULL,'Fair Value Reporting','fv_level',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116572,20263,115323,'9782','Valuation','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116573,20263,115353,'9782','Valuation','hourly_volume_allocation',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116574,20263,115354,'9782','Valuation','ratio_option',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116575,20263,115355,'9782','Valuation','asofdate_current_month',NULL,'',NULL,NULL,'n',NULL,'checkbox',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116576,20263,115356,'9783','Valuation','proxy_source_curve_def_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116577,20263,115357,'9783','Valuation','monthly_index',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116578,20263,115358,'9783','Valuation','proxy_curve_id3',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116579,20263,115359,'9784','Valuation','settlement_curve_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116580,20263,115350,'9782','Valuation','proxy_curve_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116581,20263,115351,'9782','Valuation','display_uom_id',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116582,20263,115352,NULL,'Valuation','derive_on_calculation',NULL,'',NULL,NULL,'n',NULL,'checkbox',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116583,20260,115360,NULL,'Additional','forward_settle',NULL,'',NULL,NULL,'n',NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116584,20260,115346,NULL,'Additional','curve_definition',NULL,'',NULL,NULL,'n',NULL,'input',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116585,20259,115361,NULL,'General','market_value_id',NULL,'',NULL,NULL,'n',NULL,'input',NULL,'14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				
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
		SELECT 22349,20259,'General','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL SELECT 22350,20260,'Additional','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL SELECT 22351,20260,'Additional','b','407','rtc_source_price_curve',2,NULL,'500',NULL,NULL UNION ALL SELECT 22352,20261,'Risk Bucketing','b','78','var_time_bucket_mapping',2,NULL,'500',NULL,NULL UNION ALL SELECT 22353,20261,'Risk Bucketing','a','FORM',NULL,1,NULL,'100',NULL,NULL UNION ALL SELECT 22354,20262,'Fair Value Reporting','b','79','price_curve_fv_mapping',2,NULL,NULL,NULL,NULL UNION ALL SELECT 22355,20262,'Fair Value Reporting','a','FORM',NULL,1,NULL,'100',NULL,NULL UNION ALL SELECT 22356,20263,'Valuation','a','FORM',NULL,1,NULL,NULL,NULL,NULL
				
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
		EXEC spa_application_ui_template_audit @flag='d', @application_function_id='10102600'
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
							THEN @db + '_RptList' + ',' + @db + '_RptStd_' + '10102600'  
							ELSE @db + '_UI_' + '10102600'
						END 
	FROM application_ui_template AS aut
	WHERE aut.application_function_id = 10102600
		 	
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN
		EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key, @cmbobj_key_source = NULL, @other_key_source=NULL, @source_object = 'spa_application_ui_export'
	END
	
END 