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
		WHERE aut.application_function_id = '10211300' AND auf.application_function_id IS NULL
		UNION ALL
		SELECT 
			auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
		FROM
			application_ui_filter auf
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
		WHERE auf.application_function_id = '10211300'  AND auf.application_function_id IS NOT NULL

				
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
			WHERE aut.application_function_id = '10211300' AND auf.application_function_id IS NULL
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
			WHERE aut.application_function_id = '10211300' AND auf.application_function_id IS NOT NULL
	
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
			
		IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '10211300')
		BEGIN				
			--Store old_application_field_id from the destination and sdv.code for the UDF
			INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
			SELECT musddv.application_field_id, sdv.code
			FROM maintain_udf_static_data_detail_values musddv
			INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
			INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
			INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
			WHERE autd.application_function_id = '10211300'
				
			-- DELETE SCRIPT STARTS HERE
				
			EXEC spa_application_ui_template 'd', 10211300
				
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
		SELECT 290,'contract_price','contract_group','contract_id','SELECT	ID, contract_id,product,curve_id, [description],adder,fix_price,effective_date FROM contract_price WHERE contract_id = <ID>','Price','g',NULL,'10211310','10211311',NULL UNION ALL SELECT 291,'contract_fees','contract_group','contract_id','SELECT contract_fees_id, contract_id, product_type, charges, effective_date, [value] FROM contract_fees WHERE contract_id = <ID>','Contract Fees','g',NULL,'10211310','10211311',NULL
				
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
		
		SELECT 290,'curve_id','Index Price','combo','SELECT source_curve_def_id, curve_name FROM source_price_curve_def','n','n','4','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 290,'product','Product Type','combo','SELECT value_id, code FROM static_data_value WHERE type_id = 101100','n','n','3','n',NULL,NULL,NULL,'180','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 290,'effective_date','Effective Date','dhxCalendarA',NULL,'n','n','8','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 290,'description','Description','ed',NULL,'n','n','5','y',NULL,NULL,NULL,'240','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 290,'adder','Adder','ed',NULL,'n','n','6','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 290,'fix_price','Fixed Price','ed_p',NULL,'n','n','7','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 290,'contract_id','Contract ID','ro',NULL,'n','n','2','y','contract_group','contract_id',NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 290,'ID','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','230','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 291,'product_type','Product Type','combo','SELECT value_id, code FROM static_data_value WHERE type_id = 101100','n','n','3','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 291,'charges','Charges','combo','SELECT field_name, Field_label FROM user_defined_fields_template WHERE internal_field_type = 18730','n','n','4','n',NULL,NULL,NULL,'180','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 291,'effective_date','Effective Date','dhxCalendarA',NULL,'n','n','5','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 291,'value','Value','ed_no',NULL,'n','n','6','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 291,'contract_fees_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','230','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 291,'contract_id','Contract ID','ro_int',NULL,'n','n','2','y','contract_group','contract_id',NULL,'230','int',NULL,'left', NULL,'n',NULL

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
		
		VALUES('10211300',
		'contract_group_non_standard',
		'Non Standard Contract',
		'y',
		'y',
		'contract_group',
		NULL,
		'10211310',
		'10211311',
		'102808')

		DECLARE @application_ui_template_id_new INT
		SET @application_ui_template_id_new = SCOPE_IDENTITY() 
		IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '10211300') 
		BEGIN 
		
			IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
				DROP TABLE #temp_new_template_definition 
					
			CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT , field_type VARCHAR(200) COLLATE DATABASE_DEFAULT )
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','','','','settings','',' ',' ','',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','contract_id','contract_id','System ID','input','int','h','n',NULL,NULL,'y','n',NULL,'n','n',NULL,NULL,'n','y','n','y',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','contract_name','contract_name','Contract Name','input','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'y','n','n',NULL,'n','n','n','n',NULL,NULL,'150',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','contract_desc','contract_desc','Contract Description','input','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'150',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','source_contract_id','source_contract_id','Contract ID','input','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'n','n','n',NULL,'n','n','n','n',NULL,NULL,'150',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','volume_granularity','volume_granularity','Invoice Frequency','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 978,@license_not_to_static_value_id=''982,987,989,994,995''',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','currency','currency','Currency','combo','int','h','n','EXEC spa_source_currency_maintain ''b''',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','volume_uom','volume_uom','UOM','combo','int','h','n','EXEC spa_source_uom_maintain ''c''',NULL,'n','n','1117','y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','commodity','commodity','Commodity','combo','int','h','n','EXEC spa_source_commodity_maintain ''a''',NULL,'n','n',NULL,'n','n','n',NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','contract_status','contract_status','Contract Status','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 1900',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','contract_type_def_id','contract_type_def_id','Contract Type','input','int','h','n',NULL,NULL,'n','y',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','contract_date','contract_date','Contract Date','calendar','date','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','term_start','term_start','Start Date','calendar','date','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','term_end','term_end','End Date','calendar','date','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','source_system_id','source_system_id','Source System','combo','int','h','n','EXEC spa_source_system_description ''s''',NULL,'n','y',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','sub_id','sub_id','Subsidiary','combo','int','h','n','EXEC get_subsidiaries_for_rights @function_id=''10211300''',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','is_active','is_active','Active','checkbox','char','h','n',NULL,NULL,'n','n','y','n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','pre_pay','pre_pay','Pre Pay','checkbox','char','h','n',NULL,NULL,'n','n','n','n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','create_ts','create_ts','Created Date','input','VARCHAR','h','n',NULL,NULL,'y','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','create_user','create_user','Created By','input','VARCHAR','h','n',NULL,NULL,'y','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'50',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','update_ts','update_ts','Updated Date','input','VARCHAR','h','n',NULL,NULL,'y','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','update_user','update_user','Updated By','input','VARCHAR','h','n',NULL,NULL,'y','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'50',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','name','name','Contact Name','input','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'50',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','company','company','Company Name','input','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'100',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','address','address','Address 1','input','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n','5',NULL,'200',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','address2','address2','Address 2','input','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n','5',NULL,'200',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','city','city','City','input','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'50',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','STATE','STATE','State','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 10016',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','zip','zip','ZIP','input','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'50',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','telephone','telephone','Telephone','phone','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'50',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','fax','fax','Fax','phone','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'50',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','email','email','Email','input','email','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','Subledger_code','Subledger_code','Subledger Code','input','VARCHAR','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,'20',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','settlement_accountant','settlement_accountant','Settlement Accountant','combo','varchar','h','n','EXEC spa_get_user_name',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','contract_specialist','contract_specialist','Settlement Specialist','combo','varchar','h','n','EXEC spa_get_user_name',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','billing_cycle','billing_cycle','Billing Cycle','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 17900',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','billing_from_date','billing_from_date','Billing From Date','combo','int','h','n','SELECT TOP 31 t.a AS [value id], t.a AS code
from (
SELECT Row_Number() OVER (order by grid_id) AS a
FROM adiha_grid_columns_definition
)t',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','billing_to_date','billing_to_date','Billing To Date','combo','int','h','n','SELECT TOP 31 t.a AS [value id], t.a AS code
from (
SELECT Row_Number() OVER (order by grid_id) AS a
FROM adiha_grid_columns_definition
)t',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','billing_from_hour','billing_from_hour','Billing From Hour','combo','int','h','n','SELECT TOP 24 t.a AS [value id], t.a AS code
from (
SELECT Row_Number() OVER (order by grid_id) AS a
FROM adiha_grid_columns_definition
)t',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','billing_start_month','billing_start_month','Billing Start Month','combo','int','h','n','SELECT TOP 12 t.a AS [value id], t.a AS code
from (
SELECT Row_Number() OVER (order by grid_id) AS a
FROM adiha_grid_columns_definition
)t',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','billing_to_hour','billing_to_hour','Billing To Hour','combo','int','h','n','SELECT TOP 24 t.a AS [value id], t.a AS code
from (
SELECT Row_Number() OVER (order by grid_id) AS a
FROM adiha_grid_columns_definition
)t',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','invoice_due_date','invoice_due_date','Payment Rule','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 20000',NULL,'n','n',NULL,'y','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','payment_days','payment_days','Payment Days','input','int','h','n',NULL,NULL,'n','n',NULL,'y','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','payment_calendar','payment_calendar','Payment Calendar','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 10017',NULL,'n','n',NULL,'y','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','settlement_date','settlement_date','Settlement Rule','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 20000',NULL,'n','n',NULL,'y','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','settlement_calendar','settlement_calendar','Settlement Calendar','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 10017',NULL,'n','n',NULL,'y','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','settlement_days','settlement_days','Settlement Days','input','int','h','n',NULL,NULL,'n','n',NULL,'y','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','pnl_date','pnl_date','PNL Rule','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 20000',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','pnl_calendar','pnl_calendar','PNL Calendar','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 10017',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','holiday_calendar_id','holiday_calendar_id','Holiday Calendar','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 10017',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','invoice_report_template','invoice_report_template','Invoice','combo','int','h','n','SELECT template_id, template_name FROM contract_report_template WHERE template_type = 38',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','contract_report_template','contract_report_template','Remittance','combo','int','h','n','SELECT template_id, template_name FROM contract_report_template WHERE template_type = 38',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','netting_template','netting_template','Netting','combo','int','h','n','SELECT template_id, template_name FROM contract_report_template WHERE template_type = 38',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','contract_email_template','contract_email_template','Email','combo','int','h','n','	SELECT aec.admin_email_configuration_id, aec.template_name FROM admin_email_configuration aec
RIGHT JOIN static_data_value sdv ON sdv.value_id = aec.module_type
WHERE sdv.type_id= 17800 AND sdv.code = ''Invoice Mail''',NULL,'n','n',NULL,'y','n','y',NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','contract_charge_type_id','contract_charge_type_id','Contract Component Template','combo','int','h','n','EXEC spa_contract_charge_type ''s''',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','self_billing','self_billing','Self Billing','checkbox','char','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','neting_rule','neting_rule','Buy/Sell Netting','checkbox','char','h','n',NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','netting_statement','netting_statement','Netting Statement','checkbox','char','h','n','',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','is_lock','is_lock','Locked','checkbox','char','h','n','',NULL,'y','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','type','type','Document Type','combo','char','h','n','SELECT ''i'',''Invoice'' UNION SELECT ''r'',''Remittance''',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','generic_mapping_link','',' ','template','varchar','h','n','',NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,'open_generic_mapping_hyperlink',NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','time_zone','time_zone','Time Zone','combo','int','h','n','select TIMEZONE_ID,TIMEZONE_NAME from time_zones',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10211300','hourly_block','hourly_block','Block Definition','combo','int','h','n','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 10018 ',NULL,'n','n',NULL,'n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
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
		SELECT 'General',NULL,'y','y','1',NULL,'1C',NULL UNION ALL SELECT 'Contact',NULL,'n','n','2',NULL,'1C',NULL UNION ALL SELECT 'Invoice',NULL,'y','n','3',NULL,'1C',NULL UNION ALL SELECT 'Audit',NULL,'y','n','6',NULL,'1C',NULL UNION ALL SELECT 'Price',NULL,'y','n','4',NULL,'1C',NULL UNION ALL SELECT 'Fees',NULL,'y','n','5',NULL,'1C',NULL
				
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
		
								SELECT 9769,20219,'Invoice','Billing Option','','n','n','500','500','Billing Option',NULL,NULL,NULL,NULL,'1',NULL UNION ALL 
								SELECT 9770,20219,'Invoice','Invoice Rule','','n','n','500','500','Invoice Rule',NULL,NULL,NULL,NULL,'2',NULL UNION ALL 
								SELECT 9771,20219,'Invoice','Invoice Templates','','n','n','500','500','Invoice Templates',NULL,NULL,NULL,NULL,'3',NULL UNION ALL 
								SELECT 9772,20219,'Invoice','Netting  Settlement',NULL,'n','n','500','500','Netting',NULL,NULL,NULL,NULL,'3','3'
				
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
		
		SELECT 116303,20217,115092,NULL,'General','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116304,20217,115093,NULL,'General','contract_id',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116305,20217,115094,NULL,'General','contract_name',NULL,NULL,NULL,'y',NULL,NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116306,20217,115095,NULL,'General','contract_desc',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116307,20217,115096,NULL,'General','source_contract_id',NULL,NULL,NULL,'n',NULL,NULL,'input',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116308,20217,115098,NULL,'General','currency',NULL,'60',NULL,NULL,NULL,NULL,'combo',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116309,20217,115099,NULL,'General','volume_uom',NULL,'1117',NULL,NULL,NULL,NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116310,20217,115100,NULL,'General','commodity',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116311,20217,115101,NULL,'General','contract_status',NULL,'1903',NULL,NULL,NULL,NULL,'combo',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116312,20217,115102,NULL,'General','contract_type_def_id',NULL,'38401',NULL,NULL,'y',NULL,'input',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116313,20217,115103,NULL,'General','contract_date',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116314,20217,115104,NULL,'General','term_start',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116315,20217,115105,NULL,'General','term_end',NULL,NULL,NULL,NULL,NULL,NULL,'calendar',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116316,20217,115106,NULL,'General','source_system_id',NULL,'2',NULL,NULL,'y',NULL,'combo',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116317,20217,115107,NULL,'General','sub_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116318,20217,115146,NULL,'General','contract_charge_type_id',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116319,20217,115153,NULL,'General','time_zone',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116320,20217,115125,NULL,'General','settlement_accountant',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116321,20217,115126,NULL,'General','contract_specialist',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116322,20217,115151,NULL,'General','type',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'19',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116323,20217,115154,NULL,'General','hourly_block',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116324,20217,115108,NULL,'General','is_active',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,'21',NULL,NULL,NULL,'label-right',NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116325,20217,115109,NULL,'General','pre_pay',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,'25',NULL,NULL,NULL,'label-right',NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116326,20217,115150,NULL,'General','is_lock',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,'24',NULL,NULL,NULL,'label-right',NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116327,20217,115147,NULL,'General','self_billing',NULL,NULL,NULL,NULL,'y',NULL,'checkbox',NULL,'22',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116328,20217,115152,NULL,'General','generic_mapping_link',NULL,NULL,NULL,NULL,'y',NULL,'template',NULL,'23',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116329,20220,115092,NULL,'Audit','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116330,20220,115111,NULL,'Audit','create_user',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116331,20220,115110,NULL,'Audit','create_ts',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116332,20220,115113,NULL,'Audit','update_user',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116333,20220,115112,NULL,'Audit','update_ts',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116334,20218,115092,NULL,'Contact','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116335,20218,115114,NULL,'Contact','name',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116336,20218,115115,NULL,'Contact','company',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116337,20218,115116,NULL,'Contact','address',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116338,20218,115117,NULL,'Contact','address2',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116339,20218,115118,NULL,'Contact','city',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116340,20218,115119,NULL,'Contact','STATE',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116341,20218,115120,NULL,'Contact','zip',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116342,20218,115121,NULL,'Contact','telephone',NULL,NULL,NULL,NULL,NULL,NULL,'phone',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116343,20218,115122,NULL,'Contact','fax',NULL,NULL,NULL,NULL,NULL,NULL,'phone',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116344,20218,115123,NULL,'Contact','email',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116345,20218,115124,NULL,'Contact','Subledger_code',NULL,NULL,NULL,NULL,NULL,NULL,'input',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116346,20219,115092,NULL,'Invoice','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116347,20219,115127,NULL,'Invoice','billing_cycle',NULL,'17900',NULL,NULL,'y',NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116348,20219,115128,NULL,'Invoice','billing_from_date',NULL,NULL,NULL,NULL,'y',NULL,'combo',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116349,20219,115130,NULL,'Invoice','billing_from_hour',NULL,NULL,NULL,NULL,'y',NULL,'combo',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116350,20219,115131,NULL,'Invoice','billing_start_month',NULL,NULL,NULL,NULL,'y',NULL,'combo',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116351,20219,115129,NULL,'Invoice','billing_to_date',NULL,NULL,NULL,NULL,'y',NULL,'combo',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116352,20219,115132,NULL,'Invoice','billing_to_hour',NULL,NULL,NULL,NULL,'y',NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116353,20219,115133,NULL,'Invoice','invoice_due_date',NULL,'20003',NULL,NULL,NULL,NULL,'combo',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116354,20219,115134,NULL,'Invoice','payment_days',NULL,'20',NULL,NULL,NULL,NULL,'input',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116355,20219,115135,NULL,'Invoice','payment_calendar',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116356,20219,115136,NULL,'Invoice','settlement_date',NULL,'20003',NULL,NULL,NULL,NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116357,20219,115137,NULL,'Invoice','settlement_calendar',NULL,'2',NULL,NULL,NULL,NULL,'combo',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116358,20219,115138,NULL,'Invoice','settlement_days',NULL,'2',NULL,NULL,NULL,NULL,'input',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116359,20219,115139,NULL,'Invoice','pnl_date',NULL,NULL,NULL,NULL,'y',NULL,'combo',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116360,20219,115140,NULL,'Invoice','pnl_calendar',NULL,NULL,NULL,NULL,'y',NULL,'combo',NULL,'14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116361,20219,115141,NULL,'Invoice','holiday_calendar_id',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116362,20219,115097,NULL,'Invoice','volume_granularity',NULL,'980',NULL,NULL,NULL,NULL,'combo',NULL,'16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116363,20219,115142,NULL,'Invoice','invoice_report_template',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116364,20219,115143,NULL,'Invoice','contract_report_template',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116365,20219,115144,NULL,'Invoice','netting_template',NULL,NULL,NULL,NULL,NULL,NULL,'combo',NULL,'19',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116366,20219,115145,NULL,'Invoice','contract_email_template',NULL,'20003',NULL,NULL,NULL,NULL,'combo',NULL,'20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116367,20219,115148,NULL,'Invoice','neting_rule',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,'23',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116368,20219,115149,NULL,'Invoice','netting_statement',NULL,NULL,NULL,NULL,NULL,NULL,'checkbox',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				
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
		SELECT 22306,20217,'General','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL SELECT 22307,20219,'Invoice','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL SELECT 22308,20221,'Price','a','290','contract_price',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22309,20222,'Fees','a','291','contract_fees',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22310,20220,'Audit','a','FORM',NULL,1,NULL,NULL,NULL,NULL
				
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
		EXEC spa_application_ui_template_audit @flag='d', @application_function_id='10211300'
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
							THEN @db + '_RptList' + ',' + @db + '_RptStd_' + '10211300'  
							ELSE @db + '_UI_' + '10211300'
						END 
	FROM application_ui_template AS aut
	WHERE aut.application_function_id = 10211300
		 	
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN
		EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key, @cmbobj_key_source = NULL, @other_key_source=NULL, @source_object = 'spa_application_ui_export'
	END
	
END 