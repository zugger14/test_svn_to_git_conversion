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
		WHERE aut.application_function_id = '10105800' AND auf.application_function_id IS NULL
		UNION ALL
		SELECT 
			auf.application_ui_filter_id,auf.application_group_id,NULL,auf.user_login_id,auf.application_ui_filter_name,auf.application_function_id
		FROM
			application_ui_filter auf
			INNER JOIN application_ui_template AS aut ON aut.application_function_id = auf.application_function_id
		WHERE auf.application_function_id = '10105800'  AND auf.application_function_id IS NOT NULL

				
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
			WHERE aut.application_function_id = '10105800' AND auf.application_function_id IS NULL
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
			WHERE aut.application_function_id = '10105800' AND auf.application_function_id IS NOT NULL
	
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
			
		IF EXISTS(SELECT 1 FROM application_ui_template aut WHERE aut.application_function_id = '10105800')
		BEGIN				
			--Store old_application_field_id from the destination and sdv.code for the UDF
			INSERT INTO #temp_old_maintain_udf_static_data_detail_values (old_application_field_id, sdv_code)
			SELECT musddv.application_field_id, sdv.code
			FROM maintain_udf_static_data_detail_values musddv
			INNER JOIN application_ui_template_fields AS autf ON autf.application_field_id = musddv.application_field_id
			INNER JOIN application_ui_template_definition AS autd ON autd.application_ui_field_id = autf.application_ui_field_id
			INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
			INNER JOIN static_data_value AS sdv ON sdv.value_id = udft.field_name
			WHERE autd.application_function_id = '10105800'
				
			-- DELETE SCRIPT STARTS HERE
				
			EXEC spa_application_ui_template 'd', 10105800
				
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
		SELECT 51,'grid_contract_mapping',NULL,NULL,'EXEC spa_counterparty_contract_address @flag = ''m'', @counterparty_id = ''<ID>''','Contracts','t','internal_counterparty,contract_name',NULL,NULL,NULL UNION ALL SELECT 52,'counterparty_epa_account',NULL,NULL,'EXEC spa_counterparty_epa_account @flag=''s'', @counterparty_id=<ID>','External ID','g',NULL,NULL,NULL,NULL UNION ALL SELECT 53,'grid_bank_info',NULL,NULL,'EXEC spa_counterparty_bank_info ''t'', @counterparty_id = ''<ID>''','Bank Information','g',NULL,NULL,NULL,NULL UNION ALL SELECT 60,'counterparty_contacts',NULL,NULL,'EXEC spa_counterparty_contacts @flag=''s'', @counterparty_id=<ID>','Contacts','g',NULL,NULL,NULL,NULL UNION ALL SELECT 83,'broker_fees',NULL,NULL,'EXEC spa_broker_fees @flag=''t'',@counterparty_id=<ID>','Broker Fees','g',NULL,NULL,NULL,NULL UNION ALL SELECT 134,'counterparty_broker_fees',NULL,NULL,'EXEC spa_broker_fees ''g'', @counterparty_id=<ID>',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL SELECT 173,'ContractMeterAllocation',NULL,NULL,'SELECT rg.generator_id,cg.contract_name,mi.recorderid + '' - '' + mi.description 
		FROM rec_generator rg
		LEFT JOIN recorder_generator_map rgm ON rg.generator_id = rgm.generator_id
		LEFT JOIN contract_group cg ON rg.ppa_contract_id = cg.contract_id
		LEFT JOIN meter_id mi ON mi.meter_id = rgm.meter_id
		WHERE rg.ppa_counterparty_id = ''<ID>''','Contract Allocation','g',NULL,NULL,NULL,NULL UNION ALL SELECT 192,'counterparty_certificate',NULL,NULL,'EXEC spa_counterparty_certificate @flag=''s'', @counterparty_id=<ID>',NULL,'g',NULL,NULL,NULL,NULL UNION ALL SELECT 193,'counterparty_products',NULL,NULL,'EXEC spa_counterparty_products ''s'', @dependent_id = <ID>','Product','g',NULL,NULL,NULL,NULL UNION ALL SELECT 214,'approved_counterparty',NULL,NULL,'EXEC spa_approved_counterparty ''s'', @counterparty_id=<ID>','Approved Counterparty','t',NULL,NULL,NULL,NULL UNION ALL SELECT 228,'CounterPartyHistory',NULL,NULL,'EXEC spa_counterparty_history ''s'', @source_counterparty_id=<ID>','Counterparty History','g',NULL,NULL,NULL,NULL UNION ALL SELECT 272,'browse_CounterpartyContactsPayables',NULL,NULL,'EXEC spa_counterparty_contacts @flag=''p'', @counterparty_id=<ID>,@application_field_id =<application_field_id>,@filter_value = ''<FILTER_VALUE>''','Contacts','g',NULL,NULL,NULL,NULL UNION ALL SELECT 442,'shipper_info',NULL,NULL,'EXEC spa_counterparty_shipper_info ''s'', @source_counterparty_id=<ID>','Shipper Info','g',NULL,NULL,NULL,NULL
				
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
		
		SELECT 134,'unit_price','Unit Price','ed_p',NULL,'y','n',NULL,'n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 134,'fixed_price','Fixed Price','ed_p',NULL,'y','n',NULL,'n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 134,'currency','Currency','combo','EXEC spa_source_currency_maintain ''p''','y','n',NULL,'n',NULL,NULL,NULL,'150','str',NULL,'right', NULL,'n',NULL UNION ALL 
		SELECT 51,'contract_name','Internal Counterparty/Contract','tree',NULL,'n','n','1','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'counterparty_contract_address_id','ID','ro_int',NULL,'n','n','3','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'contract_date','Contract Date','ro',NULL,'n','n','4','n',NULL,NULL,NULL,'150','date',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'contract_start_date','Contract Start Date','ro',NULL,'n','n','5','n',NULL,NULL,NULL,'150','date',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'contract_end_date','Contract End Date','ro',NULL,'n','n','6','n',NULL,NULL,NULL,'150','date',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'contract_status','Contract Status','ro',NULL,'n','n','7','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'contract_active','Active','ro',NULL,'n','n','8','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'apply_netting_rule','Apply Netting','ro',NULL,'n','n','9','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'rounding','Rounding','ro_int',NULL,'n','y','10','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'time_zone','Timezone','ro',NULL,'n','y','11','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 52,'counterparty_epa_account_id','ID','ro_int',NULL,'n','y','1','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 52,'counterparty_id','Counterparty','ro',NULL,'n','y','2','y',NULL,NULL,NULL,'158','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 52,'external_type_id','External Type ID','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id =2200','n','y','3','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 52,'external_value','Value','ed',NULL,'n','y','4','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'counterparty_product_id','ID','ro_int',NULL,'n','n','1','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'product','Product','ro',NULL,'n','n','1','y',NULL,NULL,NULL,'350','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'buy_sell','Buy/Sell','ro',NULL,'n','n','2','n',NULL,NULL,NULL,'110','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'commodity_id','Commodity','ro',NULL,'n','n','3','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'commodity_origin_id','Origin','ro',NULL,'n','n','4','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'is_organic','Organic','ro',NULL,'n','n','5','n',NULL,NULL,NULL,'90','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'commodity_form_id','Form','ro',NULL,'n','n','6','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'commodity_form_attribute1','Attribute 1','ro',NULL,'n','n','7','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'commodity_form_attribute2','Attribute 2','ro',NULL,'n','n','8','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'commodity_form_attribute3','Attribute 3','ro',NULL,'n','n','10','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'commodity_form_attribute4','Attribute 4','ro',NULL,'n','n','11','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'commodity_form_attribute5','Attribute 5','ro',NULL,'n','n','12','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'trader_id','Contact','ro',NULL,'n','n','13','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 193,'attachment','Product Spec','ro',NULL,'n','n','14','n',NULL,NULL,NULL,'300','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 442,'counterparty_shipper_info_id','Shipper Info Id','ro_int',NULL,'n','y','0','y',NULL,NULL,'y','150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 442,'source_counterparty_id','Source Counterparty Id','ro_int',NULL,'n','y','1','y',NULL,NULL,'n','150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 442,'location','Location','combo','EXEC spa_source_minor_location @flag = ''o''','n','y','2','n',NULL,NULL,NULL,'150','str','ValidInteger','left', NULL,'n',NULL UNION ALL 
		SELECT 442,'commodity','Commodity','combo','EXEC spa_source_commodity_maintain @flag=''b''','n','y','3','n',NULL,NULL,NULL,'150','str','ValidInteger','left', NULL,'n',NULL UNION ALL 
		SELECT 442,'effective_date','Effective Date','dhxCalendarA',NULL,'n','y','4','n',NULL,NULL,NULL,'150','date','NotEmpty','left', NULL,'n',NULL UNION ALL 
		SELECT 442,'shipper_code','Shipper Code','ed',NULL,'n','y','5','n',NULL,NULL,NULL,'150','str','NotEmpty','left', NULL,'n',NULL UNION ALL 
		SELECT 214,'approved_counterparty','Approved Counterparty','tree',NULL,'n','n','1','n',NULL,NULL,NULL,'350','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'buy_sell','Buy/Sell','ro',NULL,'n','n','2','n',NULL,NULL,NULL,'110','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'commodity_id','Commodity','ro',NULL,'n','n','3','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'commodity_origin_id','Origin','ro',NULL,'n','n','4','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'is_organic','Organic','ro',NULL,'n','n','5','n',NULL,NULL,NULL,'90','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'commodity_form_id','Form','ro',NULL,'n','n','6','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'commodity_form_attribute1','Attribute 1','ro',NULL,'n','n','7','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'commodity_form_attribute2','Attribute 2','ro',NULL,'n','n','8','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'commodity_form_attribute3','Attribute 3','ro',NULL,'n','n','10','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'commodity_form_attribute4','Attribute 4','ro',NULL,'n','n','11','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'commodity_form_attribute5','Attribute 5','ro',NULL,'n','n','12','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'trader_id','Contact','ro',NULL,'n','n','13','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'attachment','Questionnaire','ro',NULL,'n','n','14','n',NULL,NULL,NULL,'350','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'approved_counterparty_id','Counterparty ID','ro_int',NULL,'n','n','15','y',NULL,NULL,NULL,'100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 214,'approved_product_id','Product ID','ro_int',NULL,'n','n','16','y',NULL,NULL,NULL,'100','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 192,'counterparty_certificate_id','ID','ro_int',NULL,'n','y','1','y',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 192,'counterparty_id','Counterparty ID','ro',NULL,'n','y','2','y',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 192,'effective_date','Effective Date','dhxCalendarA',NULL,'y','n','5','n',NULL,NULL,NULL,'150','date',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 192,'certificate_id','Certificate','combo','SELECT document_id, document_name FROM documents_type WHERE document_type_id = 42001','y','y','4','n',NULL,NULL,NULL,'150','str','ValidInteger','left', NULL,'n',NULL UNION ALL 
		SELECT 192,'available_reqd','Available/Requires','combo','SELECT ''a'', ''Available'' UNION SELECT ''b'', ''Requires''','y','y','3','n',NULL,NULL,NULL,'150','str','NotEmpty','left', NULL,'n',NULL UNION ALL 
		SELECT 192,'expiration_date','Expiration Date','dhxCalendarA',NULL,'y','n','6','n',NULL,NULL,NULL,'150','date',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 192,'comments','Comments','txttxt',NULL,'y','y','7','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 192,'attachment','Certificate','ro',NULL,'y','y','8','n',NULL,NULL,NULL,'300','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 173,'generator_id','Generator ID','ro',NULL,'n','n','1','y',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 173,'contract_name','Contract','ro',NULL,'n','n','2','n',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 173,'meter_name','Meter','ro',NULL,'n','n','3','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 228,'counterparty_history_id','History Id','ro_int',NULL,'n','y','0','y',NULL,NULL,'y','158','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 228,'effective_date','Effective Date','dhxCalendarA',NULL,'n','y','1','n',NULL,NULL,'n','158','date','NotEmpty','left', NULL,'n',NULL UNION ALL 
		SELECT 228,'source_counterparty_id','Source Counterparty Id','ro_int',NULL,'n','y','2','y',NULL,NULL,'n','158','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 228,'counterparty_name','Counterparty Name','ed',NULL,'n','n','3','n',NULL,NULL,'n','158','str','NotEmpty','left', NULL,'n',NULL UNION ALL 
		SELECT 228,'counterparty_desc','Counterparty Description','ed',NULL,'n','n','5','n',NULL,NULL,'n','158','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 228,'parent_counterparty','Parent Counterparty','combo','EXEC spa_source_counterparty_maintain ''c''','n','n','6','n',NULL,NULL,'n','158','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 228,'counterparty_id','Counterparty ID','ed',NULL,'n','y','4','n',NULL,NULL,'y','158','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 228,'type','Type','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id =105900','n','n','2','n',NULL,NULL,'n','158','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 228,'counterparty','Counterparty','combo','EXEC spa_getsourcecounterparty ''s''','n','n','6','n',NULL,NULL,'n','158','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'counterparty_contact_id','ID','ro',NULL,'n','n','1','y',NULL,NULL,NULL,'60','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'contact_type','Contact Type','ro',NULL,'n','n','2','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'title','Title','ro',NULL,'n','n','3','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'name','Name','ro',NULL,'n','n','4','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'id','Contact ID','ro',NULL,'n','n','5','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'address1','Address 1','ro',NULL,'n','n','6','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'address2','Address 2','ro',NULL,'n','n','7','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'city','City','ro',NULL,'n','n','8','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'state','State','ro',NULL,'n','n','9','n',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'zip','ZIP','ro',NULL,'n','n','10','n',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'phone_no','Phone Number','ro_phone',NULL,'n','n','11','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'cell_no','Cell Number','ro_phone',NULL,'n','n','12','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'fax','Fax','ro_phone',NULL,'n','n','13','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'email','E-mail','ro',NULL,'n','n','14','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'email_cc','E-mail CC','ro',NULL,'n','n','15','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'email_bcc','E-mail BCC','ro',NULL,'n','n','16','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'country','Country','ro',NULL,'n','n','17','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'region','Region','ro',NULL,'n','n','18','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'comment','Comment','ro',NULL,'n','n','19','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'is_active','Active','ro',NULL,'n','n','20','n',NULL,NULL,NULL,'80','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 60,'is_primary','Primary','ro',NULL,'n','n','21','n',NULL,NULL,NULL,'80','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 53,'bank_id','Bank ID','ro',NULL,'n','y','0','y',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 53,'Address2','Address 2','ed',NULL,'n','y','8','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 53,'accountname','Account Name','ro',NULL,'n','y','1','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 53,'Account_no','Account Number','ro',NULL,'n','y','2','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 53,'currency','Currency','ro',NULL,'n','y','3','n',NULL,NULL,NULL,'150','str',NULL,'right', NULL,'n',NULL UNION ALL 
		SELECT 53,'wire_ABA','ABA Number','ro',NULL,'n','y','4','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 53,'ACH_ABA','Swift Number','ro',NULL,'n','y','5','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 53,'bank_name','Bank Name','ro',NULL,'n','y','6','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 53,'Address1','Address 1','ro',NULL,'n','y','7','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 53,'reference','Reference','ro',NULL,'n','y','9','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 83,'broker_fees_id','Broker Fees ID','ro_int',NULL,'n','y','1','y',NULL,NULL,'y','150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 83,'effective_date','Effective Date','dhxCalendar',NULL,'y','y','2','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 83,'broker_contract','Broker Contract','combo',' EXEC spa_contract_group ''r''','y','y','3','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 83,'deal_type','Deal Type','combo','Exec spa_source_deal_type_maintain ''y''','y','n','4','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 83,'commodity','Commodity','combo','EXEC spa_source_commodity_maintain ''b''','y','n','5','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 83,'product','Product','combo','EXEC spa_source_price_curve_def_maintain ''m''','y','n','6','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 134,'broker_fees_id','Broker Fees ID','ro_int',NULL,'n','n',NULL,'y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 134,'effective_date','Effective Date','dhxCalendar',NULL,'y','n',NULL,'n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 134,'deal_type','Deal Type','combo','EXEC spa_getsourcedealtype @flag=''l''','y','n',NULL,'n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 134,'commodity','Commodity','combo','EXEC spa_source_commodity_maintain @flag=''c''','y','n',NULL,'n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 134,'product','Product','combo','exec spa_GetAllPriceCurveDefinitions ''Z''','y','n',NULL,'n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'amendment_date','Amendment Date','ro',NULL,'n','y','12','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'amendment_description','Amendment Description','ro',NULL,'n','y','13','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 51,'external_counterparty_id','External Counterparty Id','ro',NULL,'n','y','14','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'counterparty_contact_id','ID','ro',NULL,'n','n','1','y',NULL,NULL,NULL,'60','int',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'contact_type','Contact Type','ro',NULL,'n','n','4','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'title','Title','ro',NULL,'n','n','5','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'name','Name','ro',NULL,'n','n','3','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'id','Contact ID','ro',NULL,'n','n','2','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'address1','Address 1','ro',NULL,'n','n','6','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'address2','Address 2','ro',NULL,'n','n','7','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'city','City','ro',NULL,'n','n','8','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'state','State','ro',NULL,'n','n','9','n',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'zip','ZIP','ro',NULL,'n','n','10','n',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'phone_no','Phone Number','ro_phone',NULL,'n','n','11','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'cell_no','Cell Number','ro_phone',NULL,'n','n','12','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'fax','Fax','ro_phone',NULL,'n','n','13','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'email','E-mail','ro',NULL,'n','n','14','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'email_cc','E-mail CC','ro',NULL,'n','n','15','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'email_bcc','E-mail BCC','ro',NULL,'n','n','16','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'country','Country','ro',NULL,'n','n','17','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'region','Region','ro',NULL,'n','n','18','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'comment','Comment','ro',NULL,'n','n','19','n',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'is_active','Active','ro',NULL,'n','n','20','n',NULL,NULL,NULL,'80','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'is_primary','Primary','ro',NULL,'n','n','21','n',NULL,NULL,NULL,'80','str',NULL,'left', NULL,'n',NULL UNION ALL 
		SELECT 272,'counterparty_id','Counterparty ID','ro',NULL,'n','n','22','n',NULL,NULL,NULL,'80','str',NULL,'left', NULL,'n',NULL

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
		
		VALUES('10105800',
		'SetupCounterparty',
		'SetupCounterparty',
		'y',
		'y',
		'source_counterparty',
		NULL,
		'10105810',
		'10105811',
		'102808')

		DECLARE @application_ui_template_id_new INT
		SET @application_ui_template_id_new = SCOPE_IDENTITY() 
		IF NOT EXISTS(SELECT 1 FROM application_ui_template_definition autd WHERE autd.application_function_id = '10105800') 
		BEGIN 
		
			IF OBJECT_ID('tempdb..#temp_new_template_definition') IS NOT NULL
				DROP TABLE #temp_new_template_definition 
					
			CREATE TABLE #temp_new_template_definition (new_definition_id INT, field_id VARCHAR(200) COLLATE DATABASE_DEFAULT , field_type VARCHAR(200) COLLATE DATABASE_DEFAULT )
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','','','','settings','',' ',' ','',NULL,'n','n','','n','n','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','source_counterparty_id','source_counterparty_id','System ID','input','int','h','n',NULL,NULL,'y','n',NULL,'n','n','n','n','y','y','n','y',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','source_system_id','source_system_id','Source System','combo','int','h','n','EXEC spa_source_system_description ''s'' ',NULL,'n','y','2','n','y','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','counterparty_id','counterparty_id','Counterparty ID','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','counterparty_name','counterparty_name','Name','input','varchar','h','n',NULL,NULL,'n','n',NULL,'y','y','y','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','counterparty_desc','counterparty_desc','Description','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','int_ext_flag','int_ext_flag','Counterparty Type','combo','char','h','n','SELECT ''i'' id, ''Internal'' value UNION SELECT ''e'', ''External'' UNION SELECT ''b'', ''Broker'' UNION SELECT ''c'', ''Clearing'' ',NULL,'n','y','e','y','y','y','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','netting_parent_counterparty_id','netting_parent_counterparty_id','Netting CounterpartyID','input','int','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','address','address','Address 1','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','phone_no','phone_no','Phone','phone','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','mailing_address','mailing_address','Adress 2','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','fax','fax','Fax','phone','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','type_of_entity','type_of_entity','Entity Type','combo','int','h','n','EXEC spa_StaticDataValues ''h'', 10020',NULL,'n','n','293357','n','y','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','confirm_from_text','confirm_from_text','Confirm From_','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','confirm_to_text','confirm_to_text','Confirm To','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','confirm_instruction','confirm_instruction','Confirm Instruction','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','counterparty_contact_title','counterparty_contact_title','Title','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','counterparty_contact_name','counterparty_contact_name','Name','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','create_user','create_user','Created By','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','create_ts','create_ts','Create Time stamp','input','datetime','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','update_user','update_user','Updated By','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','update_ts','update_ts','Update Timestamp','input','datetime','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','parent_counterparty_id','parent_counterparty_id','Parent Counterparty','combo','int','h','n','EXEC spa_source_counterparty_maintain ''c''',NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','customer_duns_number','customer_duns_number','Customer Duns Number','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','is_jurisdiction','is_jurisdiction','Jurisdiction','input','char','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','counterparty_contact_id','counterparty_contact_id','Counterparty Contact ID','input','int','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','email','email','Email','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,'100',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','city','city','City','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','state','state','State','combo','int','h','n','EXEC spa_StaticDataValues ''h'', 10016',NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','zip','zip','Zip','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','is_active','is_active','Active','checkbox','char','h','n',NULL,NULL,'n','n','y','n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','tax_id','tax_id','Tax ID','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','counterparty_contact_notes','counterparty_contact_notes','Notes','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','y','n','n','n','n','n','n','5',NULL,'250',NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','country','country','Country','combo','varchar','h','n','EXEC spa_StaticDataValues ''h'', 14000',NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','region','region','Region','combo','int','h','n','EXEC spa_StaticDataValues ''h'', 11150',NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','acer','acer','Acer','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','bic','bic','BIC','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','lei','lei','LEI','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','eic','eic','EIC','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','TSO_Gas','TSO_Gas','TSO Gas','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','TSO_Power','TSO_Power','TSO Power','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','PRP_Code_Power','PRP_Code_Power','PRP Code Power','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','PRP_Code_Gas','PRP_Code_Gas','PRP Code Gas','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','EAN_Code_Power','EAN_Code_Power','EAN Code Power','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','EAN_Code_Gas','EAN_Code_Gas','EAN Code Gas','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','receivables','receivables','Receivables','browser','int','h','n',NULL,NULL,'n','n','','n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','payables','payables','Payables','browser','int','h','n',NULL,NULL,'n','n','','n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','confirmation','confirmation','Confirmation','browser','int','h','n',NULL,NULL,'n','n','','n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','Credit ','Credit ','Credit','browser','varchar','h','n',NULL,NULL,'n','n','','n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','CSA_Reportable_Trade','CSA_Reportable_Trade','CSA Reportable Trade','combo','varchar','h','n','SELECT ''Y'' id, ''Y'' value UNION ALL SELECT ''N'' id, ''N'' value ORDER BY value',NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','delivery_method','delivery_method','Delivery Method','combo','int','h','n','EXEC spa_StaticDataValues ''h'', 21300',NULL,'n','n','21305','n','y','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','accounting_code','accounting_code','Accounting Code','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','n','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','financial_non_financial','financial_non_financial','Financial/Non-Financial','combo','varchar','h','n','SELECT ''F'' id, ''Financial'' code UNION ALL SELECT ''N'', ''Non-Financial'' UNION ALL SELECT ''C'', ''Central Counterparty'' UNION ALL SELECT ''O'', ''Other''',NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','eea','eea','EEA','combo','varchar','h','n','SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''No''',NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','commercial_treasury','commercial_treasury','Commercial/Treasury','combo','varchar','h','n','SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''No''',NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','corporate_sector','corporate_sector','Corporate Sector','input','varchar','h','n','',NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','collateralization','collateralization','Collateralization','combo','varchar','h','n','SELECT ''U '' id, ''Uncollateralised'' code UNION ALL SELECT ''PC'', ''Partially Collateralised'' UNION ALL SELECT ''OC'', ''One Way Collateralised'' UNION ALL SELECT ''FC'', ''Fully Collateralised''',NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','counterparty_status','counterparty_status','Counterparty Status','combo','int','h','n','EXEC spa_StaticDataValues ''h'', 101500',NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','analyst','analyst','Analyst','combo','varchar','h','n','EXEC spa_application_users  @flag = ''a''',NULL,'n','n','1','n','n','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','liquidation_loc_id','liquidation_loc_id','Liquidation Location','combo','int','h','n','EXEC spa_source_minor_location @flag = ''o''',NULL,'n','n',NULL,'n','y','n','n','y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','country_submission','country_submission','Country','combo','varchar','h','n','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 14000',NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','collateral_portfolio_code','collateral_portfolio_code','Collateral Portfolio Code','input','varchar','h','n',NULL,NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','broker_relevant','broker_relevant','Broker Relevant','combo','varchar','h','n','SELECT ''y'' id, ''Yes'' value UNION ALL SELECT ''n'' id, ''No'' value ',NULL,'n','n',NULL,'n','y','n','n','n','n','y','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','netting','netting','Netting','browser','int','h','n',NULL,NULL,'n','n','','n','n',NULL,NULL,'y','n','n','n',NULL,NULL,NULL,NULL)
						
			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','ecm_reportable','ecm_reportable','ECM Reportable','combo','varchar','h','n','SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''No''',NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)

			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','reporting_on_behalf','reporting_on_behalf','Reporting On Behalf','combo','varchar','h','n','SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''No''',NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)

			INSERT INTO application_ui_template_definition (application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, sql_string, field_size, is_disable, is_hidden, default_value, insert_required, data_flag, update_required, has_round_option, blank_option, is_primary, is_udf, is_identity, text_row_num, hyperlink_function, char_length, open_ui_function_id) 
			OUTPUT INSERTED.application_ui_field_id, INSERTED.field_id, INSERTED.field_type
			INTO #temp_new_template_definition (new_definition_id, field_id, field_type)
			VALUES('10105800','delegation_reporting','delegation_reporting','Delegation Reporting','combo','varchar','h','n','SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''No''',NULL,'n','n',NULL,'n','n','n','n','y','n','y','n',NULL,NULL,NULL,NULL)
						
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
		SELECT 'General',NULL,'y','y','1',NULL,'1C',NULL UNION ALL SELECT 'Address',NULL,'y','n','2',NULL,'1C',NULL UNION ALL SELECT 'Additional',NULL,'y','n','3',NULL,'1C',NULL UNION ALL SELECT 'Contact Info',NULL,'n','n','4',NULL,'1C',NULL UNION ALL SELECT 'Submission','Submission','y','n','5',NULL,'1C',NULL UNION ALL SELECT 'Contacts',NULL,'y','n','6',NULL,'1C',NULL UNION ALL SELECT 'Bank Information',NULL,'y','n','7',NULL,'1C',NULL UNION ALL SELECT 'Contracts',NULL,'y','n','8',NULL,'1C',NULL UNION ALL SELECT 'External ID',NULL,'y','n','9',NULL,'1C',NULL UNION ALL SELECT 'Broker Fees',NULL,'y','n','10',NULL,'1C',NULL UNION ALL SELECT 'Fees',NULL,'n','n','11',NULL,'1C',NULL UNION ALL SELECT 'Meter',NULL,'n','n','12',NULL,'1C',NULL UNION ALL SELECT 'Product',NULL,'n','n','13',NULL,'1C',NULL UNION ALL SELECT 'Certificate',NULL,'n','n','14',NULL,'1C',NULL UNION ALL SELECT 'Approved Counterparty',NULL,'n','n','15',NULL,'1C',NULL UNION ALL SELECT 'History',NULL,'y','n','16',NULL,NULL,NULL UNION ALL SELECT 'Shipper Info',NULL,'y','n','17',NULL,NULL,NULL
				
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
		
								SELECT 9776,20231,'Address','Contact Detail',NULL,'n','n','500','500','Payment Contact Detail',NULL,NULL,NULL,NULL,'3','2'
				
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
		
		SELECT 116409,20230,115193,NULL,'General','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116410,20230,115194,NULL,'General','source_counterparty_id',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116411,20230,115195,NULL,'General','source_system_id',NULL,NULL,NULL,NULL,'y',NULL,'combo',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116412,20230,115197,NULL,'General','counterparty_name',NULL,NULL,NULL,'y','n',NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116413,20230,115198,NULL,'General','counterparty_desc',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116414,20230,115196,NULL,'General','counterparty_id',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116415,20230,115205,NULL,'General','type_of_entity',NULL,NULL,'293357',NULL,'n',NULL,'combo',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116416,20230,115199,NULL,'General','int_ext_flag',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116417,20230,115250,NULL,'General','counterparty_status',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116418,20230,115251,NULL,'General','analyst',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116419,20232,115216,NULL,'Additional','customer_duns_number',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116420,20232,115224,NULL,'Additional','tax_id',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116421,20232,115244,NULL,'Additional','accounting_code',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116422,20230,115223,NULL,'General','is_active',NULL,NULL,NULL,NULL,'n',NULL,'checkbox',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116423,20230,115215,NULL,'General','parent_counterparty_id',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116424,20233,115193,NULL,'Contact Info','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116425,20233,115209,NULL,'Contact Info','counterparty_contact_title',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116426,20233,115210,NULL,'Contact Info','counterparty_contact_name',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116427,20233,115202,NULL,'Contact Info','phone_no',NULL,NULL,NULL,NULL,'n',NULL,'phone',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116428,20233,115204,NULL,'Contact Info','fax',NULL,NULL,NULL,NULL,'n',NULL,'phone',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116429,20233,115201,NULL,'Contact Info','address',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116430,20233,115203,NULL,'Contact Info','mailing_address',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116431,20233,115220,NULL,'Contact Info','city',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116432,20233,115221,NULL,'Contact Info','state',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116433,20233,115227,NULL,'Contact Info','region',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116434,20233,115226,NULL,'Contact Info','country',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116435,20233,115222,NULL,'Contact Info','zip',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116436,20231,115193,NULL,'Address','',NULL,NULL,NULL,NULL,NULL,NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116437,20232,115193,NULL,'Additional','',NULL,NULL,NULL,NULL,'n',NULL,'settings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116438,20230,115225,NULL,'General','counterparty_contact_notes',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116439,20231,115238,NULL,'Address','receivables',NULL,NULL,NULL,NULL,'n',NULL,'browser',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,'272',NULL,NULL UNION ALL 
		SELECT 116440,20231,115239,NULL,'Address','payables',NULL,NULL,NULL,NULL,'n',NULL,'browser',NULL,'2',NULL,NULL,NULL,NULL,NULL,NULL,'272',NULL,NULL UNION ALL 
		SELECT 116441,20231,115240,NULL,'Address','confirmation',NULL,NULL,NULL,NULL,'n',NULL,'browser',NULL,'3',NULL,NULL,NULL,NULL,NULL,NULL,'272',NULL,NULL UNION ALL 
		SELECT 116442,20231,115241,NULL,'Address','Credit ',NULL,NULL,NULL,NULL,'n',NULL,'browser',NULL,'4',NULL,NULL,NULL,NULL,NULL,NULL,'272',NULL,NULL UNION ALL 
		SELECT 116443,20230,115242,NULL,'General','CSA_Reportable_Trade',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'10',NULL,'1615','-5743',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116444,20232,115243,NULL,'Additional','delivery_method',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116445,20234,115228,NULL,'Submission','acer',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'7',NULL,'1578','-5615',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116446,20234,115229,NULL,'Submission','bic',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'8',NULL,'1531','-5691',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116447,20234,115230,NULL,'Submission','lei',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'9',NULL,'1588','-5693',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116448,20234,115231,NULL,'Submission','eic',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'10',NULL,'1587','-5692',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116449,20234,115232,NULL,'Submission','TSO_Gas',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'6',NULL,'1589','-5694',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116450,20234,115233,NULL,'Submission','TSO_Power',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'5',NULL,'1590','-5695',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116451,20234,115234,NULL,'Submission','PRP_Code_Power',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'1',NULL,'1580','-5620',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116452,20234,115236,NULL,'Submission','EAN_Code_Power',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'3',NULL,'1582','-5622',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116453,20234,115235,NULL,'Submission','PRP_Code_Gas',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'2',NULL,'1581','-5621',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116454,20234,115237,NULL,'Submission','EAN_Code_Gas',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'4',NULL,'1583','-5623',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116455,20234,115193,NULL,'Submission','',NULL,NULL,NULL,NULL,'n',NULL,'settings',NULL,'1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116456,20234,115245,NULL,'Submission','financial_non_financial',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'11',NULL,'1616','-10000019',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116457,20234,115246,NULL,'Submission','eea',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'12',NULL,'1618','-10000020',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116458,20234,115247,NULL,'Submission','commercial_treasury',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'13',NULL,'1617','-10000021',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116459,20234,115248,NULL,'Submission','corporate_sector',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'14',NULL,'1689','-10000023',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116460,20234,115249,NULL,'Submission','collateralization',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'13',NULL,'3302','-10000025',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116461,20230,115252,NULL,'General','liquidation_loc_id',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116462,20234,115253,NULL,'Submission','country_submission',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'15',NULL,'1538','309214',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116463,20234,115254,NULL,'Submission','collateral_portfolio_code',NULL,NULL,NULL,NULL,'n',NULL,'input',NULL,'16',NULL,'3140','-10000052',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116464,20232,115255,NULL,'Additional','broker_relevant',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'14',NULL,'3357','-10000341',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL 
		SELECT 116465,20231,115256,NULL,'Address','netting',NULL,NULL,NULL,NULL,'n',NULL,'browser',NULL,'5',NULL,NULL,NULL,NULL,NULL,NULL,'272',NULL,NULL UNION ALL 
		SELECT 116466,20234,115257,NULL,'Submission','ecm_reportable',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'17',NULL,'3417','-10000344',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
		SELECT 116467,20234,115258,NULL,'Submission','reporting_on_behalf',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'18',NULL,'2008','-10000355',NULL,NULL,NULL,NULL,NULL,NULL UNION ALL
		SELECT 116468,20234,115259,NULL,'Submission','delegation_reporting',NULL,NULL,NULL,NULL,'n',NULL,'combo',NULL,'19',NULL,'2009','-10000356',NULL,NULL,NULL,NULL,NULL,NULL

				
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
		SELECT 22318,20230,'General','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL SELECT 22319,20231,'Address','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL SELECT 22320,20234,'Submission','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL SELECT 22321,20238,'External ID','a','52','counterparty_epa_account',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22322,20236,'Bank Information','a','53','grid_bank_info',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22323,20235,'Contacts','a','60','counterparty_contacts',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22324,20237,'Contracts','a','51','grid_contract_mapping',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22325,20239,'Broker Fees','a','83','broker_fees',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22326,20240,'Fees','a','134','counterparty_broker_fees',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22327,20241,'Meter','a','173','ContractMeterAllocation',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22328,20243,'Certificate','a','192','counterparty_certificate',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22329,20242,'Product','a','193','counterparty_products',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22330,20244,'Approved Counterparty','a','214','approved_counterparty',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22331,20232,'Additional','a','FORM',NULL,1,NULL,NULL,NULL,NULL UNION ALL SELECT 22332,20245,'History','a','228','CounterPartyHistory',1,NULL,NULL,NULL,NULL UNION ALL SELECT 22333,20246,'Shipper Info','a','442','shipper_info',1,NULL,NULL,NULL,NULL
				
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
		EXEC spa_application_ui_template_audit @flag='d', @application_function_id='10105800'
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
							THEN @db + '_RptList' + ',' + @db + '_RptStd_' + '10105800'  
							ELSE @db + '_UI_' + '10105800'
						END 
	FROM application_ui_template AS aut
	WHERE aut.application_function_id = 10105800
		 	
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN
		EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key, @cmbobj_key_source = NULL, @other_key_source=NULL, @source_object = 'spa_application_ui_export'
	END	   
	
END 