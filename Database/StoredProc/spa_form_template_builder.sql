IF OBJECT_ID(N'[dbo].[spa_form_template_builder]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_form_template_builder
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: achyut@pioneersolutionsglobal.com
-- Created date: 2016-01-05
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_form_template_builder
	@flag CHAR(1),
	@process_table VARCHAR(100) = NULL,
	@xml TEXT = NULL,
	@application_function_id INT = NULL,
	@application_ui_template_audit_id INT = NULL
AS
SET NOCOUNT ON

/*
DECLARE
	@flag CHAR(1),
	@process_table VARCHAR(100) = NULL,
	@xml VARCHAR(MAX) = NULL,
	@application_function_id INT = NULL,
	@application_ui_template_audit_id INT = NULL

SELECT
	@flag = 'u',
	@xml = '<Root function_id="10102800" remarks="dddd"><FormXML><Field id="59475" name="Profile ID" default_value="" hidden="y" disable="y" seq="1" group_id="8853" fieldset_id="" udf_template_id=""></Field><Field id="59476" name="Profile Name" default_value="" hidden="n" disable="n" seq="2" group_id="8853" fieldset_id="" udf_template_id=""></Field><Field id="59477" name="Profile Code" default_value="" hidden="n" disable="n" seq="3" group_id="8853" fieldset_id="" udf_template_id=""></Field><Field id="59478" name="Profile Type" default_value="17500" hidden="n" disable="n" seq="4" group_id="8853" fieldset_id="" udf_template_id=""></Field><Field id="59479" name="UOM" default_value="" hidden="n" disable="n" seq="5" group_id="8853" fieldset_id="" udf_template_id=""></Field><Field id="59480" name="Granularity" default_value="" hidden="n" disable="n" seq="1" group_id="1518036298994" fieldset_id="" udf_template_id=""></Field></FormXML><FieldsetXML></FieldsetXML><GridGroup></GridGroup><TabXML><Tab id="8853" name="General" hidden="" seq="1"></Tab><Tab id="1518036298994" name="New Tab" hidden="" seq="2"></Tab></TabXML></Root>'
--*/

DECLARE @sql VARCHAR(2000)
 
IF @flag = 'a' -- Grid Data
BEGIN
	SELECT DISTINCT 
		aut.application_function_id [application_function_id]
		, ISNULL(sm.display_name, aut.template_description) [template_description]
		, aut.template_name	[template_name]
		, IIF(ISNULL(autd.farrms_field_id,'') = '', 'blank_field', autd.farrms_field_id) [farrms_field_id]
	FROM application_ui_template aut
	LEFT JOIN application_ui_template_definition autd 
		ON autd.application_function_id = aut.application_function_id AND autd.is_primary = 'y'
	LEFT JOIN setup_menu sm
		ON sm.function_id = aut.application_function_id
	WHERE ISNULL(aut.is_report, 'n') = 'n' AND aut.active_flag = 'y'
		--AND ISNULL(aut.template_type, 0) IN (102800, 102801, 102802, 102803, 102804, 102805, 102806, 102808, 102809, 102810, 102811, 102812, 102813, 102814, 102815, 102816) -- Template Type couldn't support all required templates
		AND ISNULL(sm.product_category, 10000000) = 10000000 
		AND aut.application_function_id IN (10102600, 10102500, 10103000, 10103300, 10103400, 10104300, 10111100, 10211200, 10101182, 10105800, 10101122, 10102800, 10211300, 10211400, 20008200, 10105815, 10105830, 10181313, 10101125)
	ORDER BY [template_description]
END
ELSE IF @flag = 'b' -- Reset Revision Remarks
BEGIN
	SELECT application_ui_template_audit_id, ISNULL(remarks, '') [remarks]
	FROM application_ui_template_audit 
	WHERE application_ui_template_audit_id = @application_ui_template_audit_id
END
ELSE IF @flag = 'r' -- Reset Revision Dropdown
BEGIN
	SELECT application_ui_template_audit_id [value], dbo.FNADateTimeFormat(create_ts, 2) [text]
	FROM application_ui_template_audit 
	WHERE application_function_id = @application_function_id
	ORDER BY application_ui_template_audit_id DESC, dbo.FNADateTimeFormat(create_ts, 2) DESC
END
ELSE IF @flag = 'u' -- Update Template Changes
BEGIN
	BEGIN TRY
		DECLARE @idoc INT, @function_id INT, @remarks VARCHAR(1000)
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
		IF OBJECT_ID('tempdb..#temp_form_detail') IS NOT NULL
			DROP TABLE #temp_form_detail
		
		IF OBJECT_ID('tempdb..#temp_tab_detail') IS NOT NULL
			DROP TABLE #temp_tab_detail

		IF OBJECT_ID('tempdb..#temp_fieldset_detail') IS NOT NULL
			DROP TABLE #temp_fieldset_detail

		IF OBJECT_ID('tempdb..#temp_grid_detail') IS NOT NULL
			DROP TABLE #temp_grid_detail
		
		IF OBJECT_ID('tempdb..#temp_inserted_tab_detail') IS NOT NULL
			DROP TABLE #temp_inserted_tab_detail

		IF OBJECT_ID('tempdb..#temp_deleted_tab_detail') IS NOT NULL
			DROP TABLE #temp_deleted_tab_detail

		CREATE TABLE #temp_inserted_tab_detail(application_group_id INT, group_name VARCHAR(100) COLLATE DATABASE_DEFAULT)

		SELECT
			@function_id = function_id,
			@remarks = remarks
		FROM OPENXML(@idoc, '/Root', 1)
		WITH (
			function_id INT,
			remarks VARCHAR(1000)
		)

		SELECT
				id,
				[hidden],
				[name],
				seq ,
				[disable],
				default_value,
				group_id,
				NULLIF(fieldset_id, 0) fieldset_id,
				udf_template_id,
				insert_required
		INTO #temp_form_detail
		FROM OPENXML(@idoc, '/Root/FormXML/Field', 1)
		WITH (
			id BIGINT,
			[hidden] CHAR,
			[name] VARCHAR(100),
			seq INT,
			[disable] CHAR,
			default_value VARCHAR(200),
			group_id BIGINT,
			fieldset_id INT,
			udf_template_id VARCHAR(100),
			insert_required CHAR
		)

		SELECT id,
			column_name,
			is_hidden,
			seq,
			grid_id,
			tab_id
		INTO #temp_grid_detail
		FROM   OPENXML(@idoc, '/Root/GridGroup/Grid/GridCol', 1)
		WITH (
			id VARCHAR(100) '@id',
			column_name VARCHAR(100) '@name',
			is_hidden CHAR(1) '@is_hidden',
			seq INT '@seq',
			grid_id VARCHAR(100) '../@id',
			tab_id VARCHAR(100) '../@tab_id'
		)
		
		SELECT
				id,
				[hidden],
				[name],
				seq 
		INTO #temp_tab_detail
		FROM OPENXML(@idoc, '/Root/TabXML/Tab', 1)
		WITH (
			id BIGINT,
			[hidden] CHAR,
			[name] VARCHAR(100),
			seq INT
		)

		SELECT
				id,
				[name]
		INTO #temp_fieldset_detail
		FROM OPENXML(@idoc, '/Root/FieldsetXML/Fieldset', 1)
		WITH (
			id INT,
			[name] VARCHAR(100)
		)
		
		BEGIN TRAN
		
		IF NOT EXISTS(SELECT 1 FROM application_ui_template_audit WHERE application_function_id = @function_id)
		BEGIN
			-- Keep Initial Audit if no audit found for the specified template
			UPDATE application_ui_template
				SET remarks = 'Original'
			WHERE application_function_id = @function_id

			EXEC spa_application_ui_template_audit @flag = 'i', @application_function_id = @function_id
		END

		UPDATE application_ui_template
			SET remarks = @remarks
		WHERE application_function_id = @function_id

		DECLARE @application_ui_template_id INT
		SELECT @application_ui_template_id = application_ui_template_id 
		FROM application_ui_template 
		WHERE application_function_id = @function_id
		
		--## Rename Tab Name
		UPDATE autg
			SET autg.group_name = ttd.[name]
		FROM #temp_tab_detail ttd
		LEFT JOIN application_ui_template_group autg ON autg.application_group_id = ttd.id
		WHERE autg.application_group_id IS NOT NULL
		--## If new tab is added add group in group table, settings in fields table and group in layout table

		DECLARE @max_sequence INT, @no_of_active INT
		SELECT @max_sequence = MAX([sequence]), @no_of_active = COUNT(active_flag) FROM application_ui_template_group WHERE application_ui_template_id = @application_ui_template_id AND active_flag = 'y'

		INSERT INTO application_ui_template_group(application_ui_template_id, group_name, active_flag, default_flag, [sequence], field_layout)
		OUTPUT INSERTED.application_group_id, INSERTED.group_name INTO #temp_inserted_tab_detail(application_group_id, group_name)
		SELECT @application_ui_template_id, ttd.[name], 'y', 'n', @max_sequence + ttd.seq - @no_of_active, '1C'
		FROM #temp_tab_detail ttd
		LEFT JOIN application_ui_template_group autg ON autg.application_group_id = ttd.id
		WHERE autg.application_group_id IS NULL
		
		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, field_type)
		SELECT a.application_group_id, application_ui_field_id, field_type 
		FROM application_ui_template_definition autd
		CROSS APPLY (SELECT application_group_id FROM #temp_inserted_tab_detail) a
		WHERE application_function_id = @function_id AND field_type = 'settings'
		
		INSERT INTO application_ui_layout_grid(group_id, layout_cell, grid_id, sequence) 
		SELECT DISTINCT titd.application_group_id, 'a', 'FORM', 1 
		FROM #temp_inserted_tab_detail titd
		INNER JOIN #temp_tab_detail ttd ON ttd.[name] = titd.group_name
		INNER JOIN #temp_form_detail tfd ON tfd.group_id = ttd.id

		--## Move fields between tabs
		UPDATE tfd
			SET tfd.group_id = titd.application_group_id
		FROM #temp_inserted_tab_detail titd 
		INNER JOIN #temp_tab_detail ttd ON ttd.name = titd.group_name
		INNER JOIN #temp_form_detail tfd ON ttd.id = tfd.group_id
		
		--## Tab Delete Starts
		--## Delete group, settings from fields, layout grid -- 5230
		SELECT autg.application_group_id
		INTO #temp_deleted_tab_detail
		FROM application_ui_template_group autg
		LEFT JOIN #temp_tab_detail ttd ON ttd.id = autg.application_group_id
		LEFT JOIN #temp_inserted_tab_detail titd ON titd.application_group_id = autg.application_group_id
		INNER JOIN application_ui_template aut ON aut.application_ui_template_id = autg.application_ui_template_id
		WHERE ttd.id IS NULL AND autg.application_group_id IS NOT NULL AND titd.application_group_id IS NULL
			AND aut.application_function_id = @function_id AND autg.active_flag = 'y'
		
		IF OBJECT_ID('tempdb..#grid_id_to_delete') IS NOT NULL
			DROP TABLE #grid_id_to_delete
		
		SELECT aulg.grid_id
		INTO #grid_id_to_delete
		FROM #temp_deleted_tab_detail tdtd
		INNER JOIN application_ui_layout_grid aulg ON aulg.group_id = tdtd.application_group_id
		WHERE aulg.grid_id <> 'FORM'
		
		DELETE agcd
		FROM adiha_grid_columns_definition AS agcd
		INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
		INNER JOIN #grid_id_to_delete gitd ON gitd.grid_id = agd.grid_id
			
		DELETE agd
		FROM adiha_grid_definition agd
		INNER JOIN #grid_id_to_delete gitd ON gitd.grid_id = agd.grid_id

		DELETE aulg
		FROM #temp_deleted_tab_detail tdtd
		INNER JOIN application_ui_layout_grid aulg ON aulg.group_id = tdtd.application_group_id
		
		DELETE autf
		FROM #temp_deleted_tab_detail tdtd
		INNER JOIN application_ui_template_fields autf ON autf.application_group_id = tdtd.application_group_id
			AND autf.field_type = 'settings'
		
		DELETE autg
		FROM #temp_deleted_tab_detail tdtd
		LEFT JOIN application_ui_template_group autg ON autg.application_group_id = tdtd.application_group_id
		--## Tab Delete Ends

		--## Create grid if grid doesn't exists else update the columns info
		IF OBJECT_ID('tempdb..#temp_pre_insert_grid_id') IS NOT NULL
			DROP TABLE #temp_pre_insert_grid_id
		
		IF OBJECT_ID('tempdb..#temp_inserted_grid_detail') IS NOT NULL
			DROP TABLE #temp_inserted_grid_detail

		CREATE TABLE #temp_inserted_grid_detail(grid_id INT, grid_name VARCHAR(100))
		
		SELECT DISTINCT tgd.grid_id, tgd.tab_id
		INTO #temp_pre_insert_grid_id
		FROM #temp_grid_detail tgd
		LEFT JOIN adiha_grid_definition agd ON agd.grid_name = tgd.grid_id
		WHERE agd.grid_id IS NULL
		
		IF EXISTS(SELECT 1 FROM #temp_pre_insert_grid_id)
		BEGIN
			DECLARE @template_edit_permisstion INT = NULL, @template_table_name VARCHAR(100), @template_table_primary_column VARCHAR(100)
			SELECT @template_edit_permisstion = edit_permission, @template_table_name = table_name FROM application_ui_template WHERE application_function_id = @function_id
			SELECT @template_table_primary_column = column_name
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
			INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KU
				ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY' AND
					TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME AND 
					KU.table_name = @template_table_name
			ORDER BY KU.TABLE_NAME, KU.ORDINAL_POSITION

			INSERT INTO adiha_grid_definition(grid_name, load_sql, grid_label, grid_type, edit_permission, delete_permission)
			OUTPUT INSERTED.grid_id, INSERTED.grid_name INTO #temp_inserted_grid_detail(grid_id, grid_name)
			SELECT tigi.grid_id, 'SELECT ' + STUFF(
				(SELECT ',' + column_name
				FROM user_defined_tables_metadata
				WHERE udt_id = udt.udt_id ORDER BY sequence_no ASC
				FOR XML PATH(''))
				, 1, 1, '') + ' FROM ' + tigi.grid_id + ISNULL(' WHERE ' + STUFF(
					(SELECT ',' + column_name 
					FROM user_defined_tables_metadata
					WHERE udt_id = udt.udt_id AND reference_column = 1
					FOR XML PATH('')), 1, 1, '') + ' = <ID>', ''),
				udt.udt_descriptions, 'g', @template_edit_permisstion, @template_edit_permisstion
			FROM #temp_pre_insert_grid_id tigi
			INNER JOIN user_defined_tables udt ON 'udt_' + udt.udt_name = tigi.grid_id
			
			INSERT INTO adiha_grid_columns_definition(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, fk_table, fk_column, is_unique, column_order, is_hidden, column_width, sorting_preference, validation_rule, column_alignment)
			SELECT tigd.grid_id, udtm.column_name, udtm.column_descriptions,
				CASE WHEN udtm.is_identity = 1 THEN 'ro'
				WHEN udtm.static_data_type_id IS NOT NULL THEN 'combo'
				WHEN udtm.column_type = 104304 THEN 'dhxCalendarA'
				ELSE 'ed'END [field_type],
				CASE WHEN udtm.static_data_type_id IS NOT NULL THEN 
					CASE WHEN udtm.static_data_type_id = -1 THEN 'EXEC spa_source_counterparty_maintain @flag = ''c'''
						WHEN udtm.static_data_type_id = -2 THEN 'EXEC spa_source_minor_location @flag = ''o'''
						WHEN udtm.static_data_type_id = -3 THEN 'EXEC spa_source_currency_maintain @flag = ''p'''
						WHEN udtm.static_data_type_id = -4 THEN 'EXEC spa_getsourceuom @flag = ''s'''
						WHEN udtm.static_data_type_id = -5 THEN 'EXEC spa_source_book_maintain @flag = ''c'''
					ELSE 'EXEC spa_StaticDataValues ''h'',' + CAST(udtm.static_data_type_id AS VARCHAR(10)) END
				ELSE NULL END [sql_string],
				'y' [is_editable],
				CASE WHEN udtm.column_nullable = 0 THEN 'y' ELSE 'n' END [is_required],
				CASE WHEN udtm.reference_column = 1 THEN @template_table_name ELSE NULL END [fk_table],
				CASE WHEN udtm.reference_column = 1 THEN @template_table_primary_column ELSE NULL END [fk_column],
				CASE WHEN udtm.is_primary = 1 THEN 'y' ELSE 'n' END [is_unique],
				udtm.sequence_no,
				CASE WHEN udtm.is_identity = 1 THEN 'y' WHEN udtm.reference_column = 1 THEN 'y' ELSE 'n' END [is_hidden],
				150 [column_width],
				CASE udtm.column_type WHEN 104302 THEN 'int' WHEN 104303 THEN 'int' WHEN 104304 THEN 'datetime' ELSE 'str' END,
				CASE WHEN udtm.is_identity = 1 THEN NULL WHEN udtm.reference_column = 1 THEN NULL WHEN udtm.column_nullable = 0 THEN 'NotEmpty' ELSE NULL END [validation_rule],
				'left'
			FROM #temp_inserted_grid_detail tigd
			INNER JOIN user_defined_tables udt ON 'udt_' + udt.udt_name = tigd.grid_name
			INNER JOIN user_defined_tables_metadata udtm ON udtm.udt_id = udt.udt_id
			ORDER BY udtm.sequence_no ASC
			
			INSERT INTO application_ui_layout_grid(group_id, layout_cell, grid_id, sequence) 
			SELECT titd.application_group_id, 'a', tigd.grid_id, 1
			FROM #temp_pre_insert_grid_id tpigi
			INNER JOIN #temp_inserted_grid_detail tigd ON tigd.grid_name = tpigi.grid_id
			INNER JOIN #temp_tab_detail tdd ON tdd.id = tpigi.tab_id
			INNER JOIN #temp_inserted_tab_detail titd ON titd.group_name = tdd.[name]
			INNER JOIN application_ui_template_group autg ON autg.application_group_id = titd.application_group_id
		END
		
		--## Update grid columns info
		UPDATE agcd
			SET agcd.column_label = tgd.column_name,
				agcd.is_hidden = tgd.is_hidden,
				agcd.column_order = tgd.seq
		FROM adiha_grid_columns_definition agcd
		INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
		INNER JOIN #temp_grid_detail tgd ON tgd.id = agcd.column_name
			AND agd.grid_name = tgd.grid_id
		
		DELETE autf
		FROM  application_ui_template_fields autf
		LEFT JOIN #temp_form_detail tfd  ON autf.application_field_id = tfd.id
		LEFT JOIN application_ui_template_definition autd ON autd.application_ui_field_id = autf.application_ui_field_id
		WHERE autd.application_function_id = @function_id
		AND tfd.id IS NULL AND autd.field_type <> 'settings'
		
		DELETE autd
		FROM  application_ui_template_definition autd
		LEFT JOIN application_ui_template_fields autf ON autd.application_ui_field_id = autf.application_ui_field_id
		LEFT JOIN #temp_form_detail tfd  ON autf.application_field_id = tfd.id
		WHERE autd.application_function_id = @function_id
		AND tfd.id IS NULL AND autd.field_type <> 'settings'

		INSERT INTO application_ui_template_definition(application_function_id, field_id, farrms_field_id, default_label, field_type, data_type, 
				header_detail, system_required, sql_string,insert_required,data_flag,update_required,
				has_round_option,blank_option,is_primary,is_udf,is_identity, is_disable, text_row_num)
		SELECT @function_id, LOWER(REPLACE(tfd.[name], ' ', '_')), LOWER(REPLACE(tfd.[name], ' ', '_')), tfd.[name], 
			CASE WHEN udft.Field_type = 'a' THEN 'calendar'
				 WHEN udft.Field_type = 'd' THEN 'combo'
				 WHEN udft.Field_type = 'm' OR udft.Field_type = 't' THEN 'input'
				 ELSE 'input'
			END field_type, 
			udft.data_type, 'h', 'n', ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string) sql_string, tfd.insert_required, 'n', 'n', 'n', 'n', 'n', 'y', 'n', tfd.[disable],
			CASE WHEN udft.field_type = 'm' THEN 3 ELSE NULL END text_num_row
		FROM  #temp_form_detail tfd 
		LEFT JOIN application_ui_template_fields autf ON autf.application_field_id = tfd.id
		LEFT JOIN user_defined_fields_template udft ON  udft.udf_template_id = tfd.udf_template_id
		LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udft.data_source_type_id
		WHERE autf.application_field_id IS NULL

		INSERT INTO application_ui_template_fields(application_group_id, application_ui_field_id, application_fieldset_id,field_type,udf_template_id, hidden, sequence, Default_value)
		SELECT tfd.group_id, autd.application_ui_field_id, tfd.fieldset_id, autd.field_type, tfd.udf_template_id, tfd.[hidden], tfd.seq, tfd.default_value
		FROM #temp_form_detail tfd
		LEFT JOIN application_ui_template_definition autd  ON LOWER(REPLACE(tfd.[name], ' ', '_')) = autd.field_id
		LEFT JOIN application_ui_template_fields autf ON autf.application_field_id = tfd.id 
		WHERE autd.application_function_id = @function_id AND autf.application_field_id IS NULL

		UPDATE autd
			SET autd.default_label = tfd.[name],
				autd.is_disable = tfd.[disable],
				autd.default_value = tfd.default_value,
				autd.insert_required = tfd.insert_required
		FROM  #temp_form_detail tfd 
		INNER JOIN application_ui_template_fields autf ON autf.application_field_id = tfd.id
		INNER JOIN application_ui_template_definition autd ON autd.application_ui_field_id = autf.application_ui_field_id
		WHERE autd.application_function_id = @function_id

		UPDATE autf
			SET autf.hidden = tfd.hidden,
				autf.sequence = tfd.seq,
				autf.default_value = tfd.default_value,
				autf.application_group_id = tfd.group_id,
				autf.application_fieldset_id = tfd.fieldset_id
		FROM  #temp_form_detail tfd 
		INNER JOIN application_ui_template_fields autf ON autf.application_field_id = tfd.id
		INNER JOIN application_ui_template_definition autd ON autd.application_ui_field_id = autf.application_ui_field_id
		WHERE autd.application_function_id = @function_id
		
		/*
		UPDATE autg
			SET autg.group_name = ttd.name,
				autg.active_flag = ttd.hidden,
				autg.sequence = ttd.seq
		FROM #temp_tab_detail ttd
		INNER JOIN application_ui_template_group autg ON autg.application_group_id = ttd.id
		WHERE application_ui_template_id = @application_ui_template_id
		*/
		UPDATE autf
			SET autf.label = tfd.[name]
		FROM #temp_fieldset_detail tfd
		INNER JOIN application_ui_template_fieldsets autf ON autf.application_fieldset_id = tfd.id
		
		-- Keep Recent Audit for the specified template
		EXEC spa_application_ui_template_audit @flag = 'i', @application_function_id = @function_id

		COMMIT

		EXEC spa_ErrorHandler @@ERROR,
							'Form Template Builder',
							'spa_form_template_builder',
							'Success',
							'Changes have been saved successfully.',
							@function_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
			
		EXEC spa_ErrorHandler -1
			, 'Form Template Builder'
			, 'spa_form_template_builder'
			, 'Error'
			, 'Failed to save data.'
			, ''
	END CATCH
END