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
		WHERE aut.application_function_id = '10106400' AND auf.application_function_id IS NULL
		UNION ALL
		SELECT 
			auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
		FROM
			application_ui_filter auf
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
		WHERE auf.application_function_id = '10106400'  AND auf.application_function_id IS NOT NULL

				
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
			WHERE aut.application_function_id = '10106400' AND auf.application_function_id IS NULL
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
			WHERE aut.application_function_id = '10106400' AND auf.application_function_id IS NOT NULL
	
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
			
		IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '10106400')
		BEGIN				
			--Store old_application_field_id from the destination and sdv.code for the UDF
			INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
			SELECT musddv.application_field_id, sdv.code
			FROM maintain_udf_static_data_detail_values musddv
			INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
			INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
			INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
			WHERE autd.application_function_id = '10106400'
				
			-- DELETE SCRIPT STARTS HERE
				
			EXEC spa_application_ui_template 'd', 10106400
				
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
		SELECT 125,'deal_fields_mapping_locations',NULL,NULL,'EXEC spa_template_field_mapping @flag=''s'', @mapping_id=''<MAPPING_ID>'', @process_id=''<PROCESS_ID>'', @sub_flag=''l''','Location','g',NULL,'10106410','10106410',NULL UNION ALL SELECT 126,'deal_fields_mapping_contracts',NULL,NULL,'EXEC spa_template_field_mapping @flag=''s'', @mapping_id=''<MAPPING_ID>'', @process_id=''<PROCESS_ID>'', @sub_flag=''c''','Contract','g',NULL,'10106410','10106410',NULL UNION ALL SELECT 127,'deal_fields_mapping_formula_curves',NULL,NULL,'EXEC spa_template_field_mapping @flag=''s'', @mapping_id=''<MAPPING_ID>'', @process_id=''<PROCESS_ID>'', @sub_flag=''f''','Formula Curve','g',NULL,'10106410','10106410',NULL UNION ALL SELECT 128,'deal_fields_mapping_curves',NULL,NULL,'EXEC spa_template_field_mapping @flag=''s'', @mapping_id=''<MAPPING_ID>'', @process_id=''<PROCESS_ID>'', @sub_flag=''i''','Curve','g',NULL,'10106410','10106410',NULL UNION ALL SELECT 189,'deal_fields_mapping_commodity',NULL,NULL,'EXEC spa_template_field_mapping @flag=''s'', @mapping_id=''<MAPPING_ID>'', @process_id=''<PROCESS_ID>'', @sub_flag=''o''','Commodity','g',NULL,'10106410','10106410',NULL UNION ALL SELECT 283,'deal_fields_mapping_counterparty',NULL,NULL,'EXEC spa_template_field_mapping @flag=''s'', @mapping_id=''<MAPPING_ID>'', @process_id=''<PROCESS_ID>'', @sub_flag=''p''','Counterparty','g',NULL,'10106410','10106410',NULL UNION ALL SELECT 306,'deal_fields_mapping_detail_status',NULL,NULL,'EXEC spa_template_field_mapping @flag=''s'', @mapping_id=''<MAPPING_ID>'', @process_id=''<PROCESS_ID>'', @sub_flag=''r''','Deal Detail Status','g',NULL,'10106410','10106410',NULL UNION ALL SELECT 307,'deal_fields_mapping_sub_book',NULL,NULL,'EXEC spa_template_field_mapping @flag=''s'', @mapping_id=''<MAPPING_ID>'', @process_id=''<PROCESS_ID>'', @sub_flag=''t''','Sub Book','g',NULL,'10106410','10106410',NULL UNION ALL SELECT 308,'deal_fields_mapping_uom',NULL,NULL,'EXEC spa_template_field_mapping @flag=''s'', @mapping_id=''<MAPPING_ID>'', @process_id=''<PROCESS_ID>'', @sub_flag=''s''','UOM','g',NULL,'10106410','10106410',NULL UNION ALL SELECT 309,'deal_fields_mapping_trader',NULL,NULL,'EXEC spa_template_field_mapping @flag=''s'', @mapping_id=''<MAPPING_ID>'', @process_id=''<PROCESS_ID>'', @sub_flag=''q''','Trader','g',NULL,'10106410','10106410',NULL
				
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
		
		SELECT 125,'deal_fields_mapping_locations_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 125,'deal_fields_mapping_id','MappingID','ro_int',NULL,'n','n','2','y',NULL,'deal_fields_mapping_id',NULL,'100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 125,'location_id','Location Name','combo','EXEC spa_source_minor_location ''o''','y','n','5','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 126,'deal_fields_mapping_contracts_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 126,'deal_fields_mapping_id','MappingID','ro_int',NULL,'n','n','2','y',NULL,'deal_fields_mapping_id',NULL,'100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 126,'contract_id','Contract','combo','EXEC spa_contract_group ''r''','y','n','4','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 127,'deal_fields_mapping_formula_curves_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 127,'deal_fields_mapping_id','MappingID','ro_int',NULL,'n','n','2','y',NULL,'deal_fields_mapping_id',NULL,'100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 127,'formula_curve_id','Formula Curve','combo','EXEC spa_source_price_curve_def_maintain ''l''','y','n','7','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 127,'source_curve_type_value_id','Curve Type','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 575','y','n','3','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 128,'deal_fields_mapping_curves_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 128,'deal_fields_mapping_id','MappingID','ro_int',NULL,'n','n','2','y',NULL,'deal_fields_mapping_id',NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 128,'curve_id','Curve','combo','EXEC spa_source_price_curve_def_maintain ''l''','y','n','7','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 189,'deal_fields_mapping_commodity_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 189,'deal_fields_mapping_id','MappingID','ro_int',NULL,'n','n','2','y',NULL,'deal_fields_mapping_id',NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 189,'detail_commodity_id','Commodity','combo','EXEC spa_source_commodity_maintain ''a''','y','n','3','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 125,'location_group','Location Group','combo','EXEC spa_source_major_location @flag=''x''','y','n','3','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 125,'commodity_id','Commodity','combo','EXEC spa_source_commodity_maintain @flag=''a''','y','n','4','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 126,'subsidiary_id','Subsidiary','combo','EXEC get_subsidiaries_for_rights @function_id=10106400','y','n','3','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 127,'commodity_id','Commodity','combo','EXEC spa_source_commodity_maintain @flag=''a''','y','n','4','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 127,'index_group','Index Group','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 15100','y','n','5','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 127,'market','Market','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 29700','y','n','6','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 128,'source_curve_type_value_id','Curve Type','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 575','y','n','3','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 128,'commodity_id','Commodity','combo','EXEC spa_source_commodity_maintain @flag=''a''','y','n','4','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 128,'index_group','Index Group','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 15100','y','n','5','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 128,'market','Market','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 29700','y','n','6','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 283,'counterparty_id','Counterparty','combo','EXEC spa_source_counterparty_maintain @flag = ''c'', @is_active = ''y'', @int_ext_flag = ''e''','y','n','5','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 283,'entity_type','Entity Type','combo','EXEC spa_StaticDataValues ''h'', 10020','y','n','3','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 283,'counterparty_type','Counterparty Type','combo','SELECT ''b'' AS [id], ''Broker'' AS [value] UNION SELECT ''e'' AS [id], ''External'' AS [value] UNION SELECT ''i'' AS [id], ''Internal'' AS [value]','y','n','4','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 283,'deal_fields_mapping_counterparty_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 283,'deal_fields_mapping_id','MappingID','ro_int',NULL,'n','n','2','y',NULL,'deal_fields_mapping_id',NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 306,'deal_fields_mapping_detail_status_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 306,'deal_fields_mapping_id','MappingID','ro_int',NULL,'n','n','2','y',NULL,'deal_fields_mapping_id',NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 306,'detail_status_id','Detail Status','combo','EXEC spa_staticDataValues @flag = ''h'', @type_id = 25000','y','n','3','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 309,'deal_fields_mapping_trader_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 309,'deal_fields_mapping_id','MappingID','ro_int',NULL,'n','n','2','y',NULL,'deal_fields_mapping_id',NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 309,'trader_id','Trader','combo','EXEC spa_source_traders_maintain ''x''','y','n','3','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 308,'deal_fields_mapping_uom_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 308,'deal_fields_mapping_id','MappingID','ro_int',NULL,'n','n','2','y',NULL,'deal_fields_mapping_id',NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 308,'uom_id','UOM','combo','EXEC spa_source_uom_maintain ''c'', @uom_type = 44303','y','n','3','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 307,'deal_fields_mapping_sub_book_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,'y','150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 307,'deal_fields_mapping_id','MappingID','ro_int',NULL,'n','n','2','y',NULL,'deal_fields_mapping_id',NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 307,'sub_book_id','Sub Book','combo','EXEC spa_get_source_book_map @flag=''z'', @function_id=10131010','y','n','3','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL

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
		
		VALUES('10106400',
		'TemplateFieldMapping',
		'Template Field Mapping',
		'y',
		'y',
		'deal_fields_mapping',
		'n',
		'10106410',
		'10106411',
		NULL)

		DECLARE @application_ui_template_id_new INT
		SET @application_ui_template_id_new = SCOPE_IDENTITY() 
		IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '10106400') 
		BEGIN 
		
			IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
				DROP TABLE #temp_new_template_definition 
					
			CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT , field_type VARCHAR(200) COLLATE DATABASE_DEFAULT )
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
		SELECT 'Location',NULL,'y','y','6',NULL,'1C',NULL UNION ALL SELECT 'Contract',NULL,'y','n','5',NULL,'1C',NULL UNION ALL SELECT 'Formula Curve',NULL,'y','n','8',NULL,'1C',NULL UNION ALL SELECT 'Curve',NULL,'y','n','7',NULL,'1C',NULL UNION ALL SELECT 'Commodity',NULL,'y','n','2',NULL,'1C',NULL UNION ALL SELECT 'Counterparty',NULL,'y','n','4',NULL,'1C',NULL UNION ALL SELECT 'Deal Detail Status',NULL,'y','n','10',NULL,'1C',NULL UNION ALL SELECT 'Sub Book',NULL,'y','n','1',NULL,'1C',NULL UNION ALL SELECT 'Trader',NULL,'y','n','3',NULL,'1C',NULL UNION ALL SELECT 'UOM',NULL,'y','n','9',NULL,'1C',NULL
				
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
		SELECT 21884,19784,'Location','a','125','deal_fields_mapping_locations',2,NULL,NULL,NULL,NULL UNION ALL SELECT 21885,19785,'Contract','a','126','deal_fields_mapping_contracts',3,NULL,NULL,NULL,NULL UNION ALL SELECT 21886,19786,'Formula Curve','a','127','deal_fields_mapping_formula_curves',4,NULL,NULL,NULL,NULL UNION ALL SELECT 21887,19787,'Curve','a','128','deal_fields_mapping_curves',5,NULL,NULL,NULL,NULL UNION ALL SELECT 21888,19788,'Commodity','a','189','deal_fields_mapping_commodity',6,NULL,NULL,NULL,NULL UNION ALL SELECT 21889,19789,'Counterparty','a','283','deal_fields_mapping_counterparty',7,NULL,NULL,NULL,NULL UNION ALL SELECT 21890,19792,'Trader','a','309','deal_fields_mapping_trader',8,NULL,NULL,NULL,NULL UNION ALL SELECT 21891,19790,'Deal Detail Status','a','306','deal_fields_mapping_detail_status',9,NULL,NULL,NULL,NULL UNION ALL SELECT 21892,19793,'UOM','a','308','deal_fields_mapping_uom',10,NULL,NULL,NULL,NULL UNION ALL SELECT 21893,19791,'Sub Book','a','307','deal_fields_mapping_sub_book',11,NULL,NULL,NULL,NULL
				
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
		EXEC spa_application_ui_template_audit @flag='d', @application_function_id='10106400'
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
							THEN @db + '_RptList' + ',' + @db + '_RptStd_' + '10106400'  
							ELSE @db + '_UI_' + '10106400'
						END 
	FROM application_ui_template AS aut
	WHERE aut.application_function_id = 10106400
		 	
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN
		EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key, @cmbobj_key_source = NULL, @other_key_source=NULL, @source_object = 'spa_application_ui_export'
	END
	
END 