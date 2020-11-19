SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[spa_setup_deal_template]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_setup_deal_template]
GO

/**
	Generic Stored Procedure to insert update copy and return deal and field template

	Parameters 
	@flag : 
			- s - Returns info of deal and field template
			- f - Returns info of field template name and id
			- o - Returns json for the SQL string passed to be useded to populate combo
			- p - Returns all system fields, UDF fields and UDT
			- j - Returns tab_json, form_json and grid_json 
			- i - Inserts new field template
			- d - Deletes field template and its dependent data
			- c - Copies  field template
			- g - Returns columns info of all system and UDF fields
			- u - Inserts role and priviledge of deal template 
			- l - Returns info of deal template and its priviledge

	@field_template_id : Field Template Id
	@header_detail : Flag for Header or Detail
	@sql_string : Sql String of combo
	@xml : Xml string for template info
	@column_ids : It is not in used
	@deal_template_id : Deal Template Id
	@del_field_template_ids : List of Field Template Ids need to be deleted
*/


CREATE PROC [dbo].[spa_setup_deal_template]
	@flag CHAR(1),
	@field_template_id INT = NULL,
	@header_detail CHAR(1) = 'h',
	@sql_string NVARCHAR(1000) = NULL,
	@xml XML = NULL,
	@column_ids VARCHAR(4000) = NULL,
	@deal_template_id INT = NULL,
	@del_field_template_ids VARCHAR(MAX) = NULL

AS
SET NOCOUNT ON

/*
DECLARE	@flag CHAR(1),
	@field_template_id INT = NULL,
	@header_detail CHAR(1) = 'b',
	@sql_string VARCHAR(1000) = NULL,
	@xml XML = NULL,
	@column_ids VARCHAR(4000) = NULL,
	@deal_template_id INT = NULL,
	@del_field_template_ids VARCHAR(MAX) = NULL

	SELECT @flag = 'p', @field_template_id = NULL
--*/
DECLARE @sql VARCHAR(MAX)
DECLARE @idoc INT
DECLARE @sql_version INT = dbo.FNAGetMSSQLVersion()
DECLARE @db_user VARCHAR(MAX)
SET @db_user = dbo.FNADBUser()
DECLARE @check_admin_role INT
SELECT @check_admin_role = ISNULL(dbo.FNAAppAdminRoleCheck(dbo.FNADBUser()), 0)

IF @flag = 's'
BEGIN
	SET @sql = '
		SELECT DISTINCT sdht.template_id,
			sdht.template_name,
			sdht.field_template_id,
			mft.template_name [field_template_name],
			mft.template_description [field_template_description],
			sdt.source_deal_type_name,
			sdst.source_deal_type_name [sub_deal_type],
			IIF(sdht.is_active = ''y'', ''Yes'', ''No'') is_active,
			IIF(mft.is_mobile = ''y'', ''Yes'', ''No'') is_mobile
	FROM source_deal_header_template sdht
	INNER JOIN maintain_field_template mft ON mft.field_template_id = sdht.field_template_id
		LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdht.source_deal_type_id AND sdt.sub_type = ''n''
		LEFT JOIN source_deal_type sdst ON sdst.source_deal_type_id = sdht.source_deal_type_id AND sdst.sub_type = ''y''
	'

	IF @check_admin_role <> 1 -- does not have admin role
	BEGIN
		SET @sql = @sql + '
			INNER JOIN template_mapping tm ON tm.template_id = sdht.template_id
			LEFT JOIN template_mapping_privilege tmp ON tmp.template_mapping_id = tm.template_mapping_id
				AND (tmp.[user_id] = ''' + @db_user + ''' OR tmp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(''' + @db_user + ''') fur))
			WHERE tmp.template_mapping_privilege_id IS NOT NULL
		'
	END

	SET @sql = @sql + '
		ORDER BY sdht.template_name'

	EXEC (@sql)
END
ELSE IF @flag = 'f'
BEGIN
	SELECT	field_template_id [value],
			template_name [text]
	FROM maintain_field_template
	ORDER BY template_name
END
ELSE IF @flag = 'o'
BEGIN
	DECLARE @dropdown_options_xml NVARCHAR(MAX)
	IF OBJECT_ID(N'tempdb..#combo_options ') IS NOT NULL
		DROP TABLE #combo_options

	CREATE TABLE #combo_options (
		[text]      Nvarchar(200) COLLATE DATABASE_DEFAULT ,
		[value]     Nvarchar(500) COLLATE DATABASE_DEFAULT ,
		[state]		VARCHAR(10) COLLATE DATABASE_DEFAULT DEFAULT 'enable'
	)

	DECLARE @type CHAR(1)
	SET @sql_string = NULLIF(@sql_string, 'NULL')
 	SET @type = SUBSTRING(@sql_string, 1, 1)
	
 	IF @type = '['
 	BEGIN
 		SET @sql_string = REPLACE(@sql_string, CHAR(13), '')
 		SET @sql_string = REPLACE(@sql_string, CHAR(10), '')
 		SET @sql_string = REPLACE(@sql_string, CHAR(32), '')	
 		SET @sql_string = [dbo].[FNAParseStringIntoTable](@sql_string)  
 		EXEC('INSERT INTO #combo_options([value], [text])
 				SELECT value_id, code from (' + @sql_string + ') a(value_id, code)');

 	END 
 	ELSE
 	BEGIN
		BEGIN TRY
			INSERT INTO #combo_options([value], [text])
			EXEC(@sql_string)
		END TRY
		BEGIN CATCH
			INSERT INTO #combo_options([value], [text], [state])
			EXEC(@sql_string)
		END CATCH
	END

	IF @sql_version >= 13
	BEGIN
		--SQL 2016 onwards supports 'FOR JSON' to convert SQL resultset into JSON
		SET @dropdown_options_xml = ' SET @dropdown_options_xml = (SELECT *
 									FROM #combo_options 
 									FOR JSON AUTO
									)'
		EXECUTE sp_executesql @dropdown_options_xml,  N'@dropdown_options_xml NVARCHAR(MAX) OUTPUT', @dropdown_options_xml = @dropdown_options_xml OUTPUT
		SELECT @dropdown_options_xml
	END
	ELSE
	BEGIN
		SET @dropdown_options_xml = (
			SELECT *
			FROM #combo_options
 			FOR XML RAW('formxml'), ROOT('root'), ELEMENTS
 		)

		SET @dropdown_options_xml = REPLACE(CAST(@dropdown_options_xml AS NVARCHAR(MAX)), '"', '\"')

		SELECT dbo.FNAFlattenedJSON(@dropdown_options_xml) dropdown_options
	END
END
ELSE IF @flag = 'p'
BEGIN
	DROP TABLE IF EXISTS #temp_deal_udt_lists
	CREATE TABLE #temp_deal_udt_lists(id INT, [name] VARCHAR(200) COLLATE DATABASE_DEFAULT)

	IF @header_detail = 'h' OR @header_detail = 'b'
	BEGIN
		INSERT INTO #temp_deal_udt_lists
		SELECT c1.udt_id, t.udt_name
		FROM user_defined_tables t
		INNER JOIN user_defined_tables_metadata c ON c.udt_id = t.udt_id AND c.column_name = 'deal_id'
		INNER JOIN user_defined_tables_metadata c1 ON c1.udt_id = c.udt_id
		WHERE c1.column_name IN ('deal_id', 'term_start', 'leg')
		GROUP BY c1.udt_id, t.udt_name
		HAVING COUNT(c1.udt_id) < 3
	END
	IF @header_detail = 'd' OR @header_detail = 'b'
	BEGIN
		INSERT INTO #temp_deal_udt_lists
		SELECT c.udt_id, t.udt_name
		FROM user_defined_tables t
		INNER JOIN user_defined_tables_metadata c ON c.udt_id = t.udt_id
		WHERE c.column_name IN ('deal_id', 'term_start', 'leg')
		GROUP BY c.udt_id, t.udt_name
		HAVING COUNT(c.udt_id) = 3
	END

	DROP TABLE IF EXISTS #value_required_columns
	
	SELECT 'sub_book' col
	INTO #value_required_columns
	UNION
	SELECT 'counterparty_id'
	UNION
	SELECT 'deal_date'
	UNION
	SELECT 'physical_financial_flag'
	UNION
	SELECT 'counterparty_id'
	UNION
	SELECT 'source_deal_type_id'
	UNION
	SELECT 'trader_id'
	UNION
	SELECT 'template_id'
	UNION
	SELECT 'header_buy_sell_flag'
	UNION
	SELECT 'contract_id'
	UNION
	SELECT 'internal_desk_id'
	UNION
	SELECT 'term_start'
	UNION
	SELECT 'term_end'
	UNION
	SELECT 'contract_expiration_date'
	UNION
	SELECT 'deal_volume'
	UNION
	SELECT 'deal_volume_frequency'
	UNION
	SELECT 'location_id'
	UNION
	SELECT 'commodity_id'
	UNION
	SELECT 'source_system_id'
	UNION
	SELECT 'fixed_float_leg'
	UNION
	SELECT 'curve_id'
	UNION
	SELECT 'deal_volume_uom_id'

	SET @sql = '

	IF OBJECT_ID(''tempdb..#temp_fields_pool'') IS NOT NULL
 		DROP TABLE #temp_fields_pool

	SELECT
		''System'' field_template_type,
		LOWER(mfd.farrms_field_id) farrms_field_id,
		(
			CASE
				WHEN mfd.default_label = ''book1'' OR mftd.field_id = 19 THEN ISNULL(sbmc.group1, ''Group1'')
				WHEN mfd.default_label = ''book2'' OR mftd.field_id = 20 THEN ISNULL(sbmc.group2, ''Group2'')
				WHEN mfd.default_label = ''book3'' OR mftd.field_id = 21 THEN ISNULL(sbmc.group3, ''Group3'')
				WHEN mfd.default_label = ''book4'' OR mftd.field_id = 22 THEN ISNULL(sbmc.group4, ''Group4'')
				WHEN mfd.farrms_field_id = ''reporting_group1'' THEN COALESCE(mftd.field_caption, sbmc.reporting_group1, ''Reporting Group 1'')
				WHEN mfd.farrms_field_id = ''reporting_group2'' THEN COALESCE(mftd.field_caption, sbmc.reporting_group2, ''Reporting Group 2'')
				WHEN mfd.farrms_field_id = ''reporting_group3'' THEN COALESCE(mftd.field_caption, sbmc.reporting_group3, ''Reporting Group 3'')
				WHEN mfd.farrms_field_id = ''reporting_group4'' THEN COALESCE(mftd.field_caption, sbmc.reporting_group4, ''Reporting Group 4'')
				WHEN mfd.farrms_field_id = ''reporting_group5'' THEN COALESCE(mftd.field_caption, sbmc.reporting_group5, ''Reporting Group 5'')
				ELSE ISNULL(mftd.field_caption, mfd.default_label)
			END
		) default_label,
		ISNULL(mfd.field_type, ''t'') field_type,
		mfd.[header_detail],
		mfd.[system_required],
		mfd.[sql_string],
		''s'' udf_or_system,
		ISNULL(' + IIF(@field_template_id IS NULL, 'mfd.is_disable', 'mftd.is_disable') + ', ''n'') [is_disable],
		ISNULL(' + IIF(@field_template_id IS NULL, 'mfd.insert_required', 'mftd.insert_required') + ', ''n'') [insert_required],
		ISNULL(' + IIF(@field_template_id IS NULL, 'mfd.is_hidden', 'mftd.hide_control') + ', ''n'') [hide_control],
		--ISNULL(mftd.insert_required, mfd.insert_required) [insert_required],
		--COALESCE(mftd.hide_control, mfd.is_hidden, ''n'') hide_control,
		ISNULL(CASE
			WHEN mfd.field_type = ''a'' THEN dbo.FNADateFormat(mftd.default_value)
			ELSE 
			' + IIF(@field_template_id IS NULL, 'mfd.default_value', 'mftd.default_value') + '
			--ISNULL(mftd.default_value, mfd.default_value)
		END, '''') default_value,
		ISNULL(' + IIF(@field_template_id IS NULL, 'mfd.update_required', 'mftd.update_required') + ', ''n'') [update_required],
		--ISNULL(mftd.update_required, mfd.update_required) [update_required],
		IIF(vrc.col IS NULL OR ''1'' = ' + IIF(@field_template_id IS NULL, '-1', '1') + ', ISNULL(mftd.value_required, ''n''), ''y'') [value_required],
		mftd.seq_no field_seq,
		ISNULL(field_group_id,-1) field_group_id,
		field_template_detail_id,
		'''' [dropdown_json],
		CASE
			WHEN mfd.default_label = ''book1'' OR mftd.field_id = 19 THEN ISNULL(sbmc.group1, ''Group1'')
			WHEN mfd.default_label = ''book2'' OR mftd.field_id = 20 THEN ISNULL(sbmc.group2, ''Group2'')
			WHEN mfd.default_label = ''book3'' OR mftd.field_id = 21 THEN ISNULL(sbmc.group3, ''Group3'')
			WHEN mfd.default_label = ''book4'' OR mftd.field_id = 22 THEN ISNULL(sbmc.group4, ''Group4'')
			WHEN mfd.farrms_field_id = ''reporting_group1'' THEN ISNULL(sbmc.reporting_group1, ''Reporting Group 1'')
			WHEN mfd.farrms_field_id = ''reporting_group2'' THEN ISNULL(sbmc.reporting_group2, ''Reporting Group 2'')
			WHEN mfd.farrms_field_id = ''reporting_group3'' THEN ISNULL(sbmc.reporting_group3, ''Reporting Group 3'')
			WHEN mfd.farrms_field_id = ''reporting_group4'' THEN ISNULL(sbmc.reporting_group4, ''Reporting Group 4'')
			WHEN mfd.farrms_field_id = ''reporting_group5'' THEN ISNULL(sbmc.reporting_group5, ''Reporting Group 5'')
			ELSE mfd.default_label
		END [org_label],
		ISNULL(mftd.show_in_form, ''n'') [show_in_form]
	INTO #temp_fields_pool
	FROM maintain_field_deal mfd
	LEFT JOIN #value_required_columns vrc
		ON vrc.col = LOWER(mfd.farrms_field_id)
	LEFT JOIN maintain_field_template_detail mftd
		ON mftd.field_id = mfd.field_id
			AND mftd.field_template_id = ' + IIF(@field_template_id IS NULL, 'mftd.field_template_id',  CAST(@field_template_id AS VARCHAR(20))) + '
			AND ISNULL(mftd.udf_or_system, ''s'') = ''s'''

	IF @field_template_id IS NULL
		SET @sql += ' AND mftd.field_template_detail_id IS NULL'

	SET @sql += ' OUTER APPLY source_book_mapping_clm sbmc'
	IF @header_detail = 'b'
		SET @sql += ' WHERE ISNULL(mfd.system_required, '''') = ' + IIF(@field_template_id IS NULL, '''y''', 'ISNULL(mfd.system_required, '''')')
	ELSE IF @header_detail <> 'b' AND @field_template_id IS NULL
		SET @sql += ' WHERE ISNULL(mfd.system_required, ''n'') = ''n'''
	
	IF @field_template_id IS NOT NULL OR @header_detail <> 'b'
	BEGIN
		SET @sql += '
	UNION ALL
	SELECT  ''UDF'' field_template_type,
			''UDF___'' + CAST(udf_template_id AS VARCHAR) udf_template_id,
			ISNULL(mftd.field_caption, udf_temp.Field_label) default_label,
			ISNULL(udf_temp.field_type, ''t'') field_type,
			udf_temp.udf_type,
			''n'' [system_required],
			ISNULL(NULLIF(udf_temp.sql_string, ''''), uds.sql_string) [sql_string],
			''u'' udf_or_system,
			mftd.is_disable,
			mftd.insert_required,
			ISNULL(mftd.hide_control, ''n'') hide_control,
			ISNULL(' + IIF(@field_template_id IS NULL OR @header_detail <> 'b', 'udf_temp.default_value', 'mftd.default_value') + ', '''') default_value,
			mftd.update_required,
			mftd.value_required,
			mftd.seq_no,
			ISNULL(field_group_id,-1) field_group_id,
			ISNULL(field_template_detail_id, -1),
			'''',
			udf_temp.Field_label,
			ISNULL(mftd.show_in_form, ''n'') [show_in_form]
	FROM user_defined_fields_template udf_temp
	LEFT JOIN udf_data_source uds
		ON uds.udf_data_source_id = udf_temp.data_source_type_id
	LEFT JOIN maintain_field_template_detail mftd
		ON mftd.field_id = udf_temp.udf_template_id
			AND mftd.field_template_id = ' + IIF(@field_template_id IS NULL, 'mftd.field_template_id',  CAST(@field_template_id AS NVARCHAR(20))) + '
			AND ISNULL(mftd.udf_or_system, ''s'') = ''u'''
	IF @field_template_id IS NULL
		SET @sql += ' AND mftd.field_template_detail_id IS NULL'
	END

	SET @sql += '
		UNION ALL
		SELECT	''UDT'' field_template_type,
				CAST(udt_id AS VARCHAR) udt_id,
				ISNULL(udt_descriptions, udt_name) default_label,
				'''' field_type,
				''' + IIF(@header_detail = 'b', 'h', @header_detail) + ''' [header_detail],--TODO: find h/d checking columns
				''n'' [system_required],
				NULL [sql_string],
				''t'' udf_or_system,
				NULL is_disable,
				NULL insert_required,
				''n'' hide_control,
				'''' default_value,
				NULL update_required,
				NULL value_required,
				NULL seq_no,
				' + IIF(@field_template_id IS NULL, '-1', 'COALESCE(mftd.field_group_id, mftd.detail_group_id, -1)') + ' field_group_id,
				' + IIF(@field_template_id IS NULL, '-1', 'ISNULL(mftd.field_template_detail_id, -1)') + ',
				'''',
				ISNULL(udt_descriptions, udt_name),
				ISNULL(mftd.show_in_form, ''n'') [show_in_form]
		FROM user_defined_tables udt
		INNER JOIN #temp_deal_udt_lists tdul ON tdul.id = udt.udt_id
		LEFT JOIN adiha_grid_definition agd ON agd.grid_name = ''udt_'' + udt.udt_name
		LEFT JOIN maintain_field_template_detail mftd ON mftd.field_id = agd.grid_id
			AND mftd.field_template_id = ' + IIF(@field_template_id IS NULL, 'mftd.field_template_id',  CAST(@field_template_id AS VARCHAR(20))) + '
			AND ISNULL(mftd.udf_or_system, ''s'') = ''t''
	'

	-- Add Empty UDT node in pool tree if no UDT available to add
	IF (NOT EXISTS(
		SELECT * 
		FROM #temp_deal_udt_lists tdul
		INNER JOIN adiha_grid_definition agd ON agd.grid_name = 'udt_' + tdul.[name]
		LEFT JOIN maintain_field_template_detail mftd ON mftd.field_id = agd.grid_id
			AND mftd.field_template_id = @field_template_id AND ISNULL(mftd.udf_or_system, 's') = 't'
		WHERE mftd.field_template_detail_id IS NULL
	) OR @field_template_id IS NULL) AND @header_detail IN('h','d')
	BEGIN
		SET @sql += ' UNION ALL
					  SELECT ''UDT'', '''', '''', '''', ''' + @header_detail + ''', '''', NULL, '''', NULL, NULL, '''', '''', NULL, NULL, NULL, -1, -1, '''', '''', ''''
		'
	END

	SET @sql += ' SELECT * FROM #temp_fields_pool WHERE'
	IF @header_detail = 'b' AND @field_template_id IS NOT NULL
		SET @sql += ' NULLIF(field_template_detail_id, -1) IS NOT NULL'
	ELSE
		SET @sql += ' ISNULL(field_template_detail_id, -1) = -1'

	IF @header_detail = 'b' SET @sql += ''
	ELSE
		SET @sql += ' AND header_detail = ''' + @header_detail + ''' ORDER BY field_template_type, field_seq, default_label'
	--PRINT @sql
	EXEC(@sql)



END
ELSE IF @flag = 'j'
BEGIN
	--##Tab Details
	IF OBJECT_ID('tempdb..#temp_deal_tabs') IS NOT NULL
 		DROP TABLE #temp_deal_tabs
 	
	CREATE TABLE #temp_deal_tabs (
			id VARCHAR(200),
			[text] VARCHAR(200) COLLATE DATABASE_DEFAULT,
			active VARCHAR(20) COLLATE DATABASE_DEFAULT,
			seq_no INT,
			default_tab INT,
			header_detail CHAR(1)
		)

	DECLARE @min_seq_no INT
	SELECT @min_seq_no = MIN(seq_no) FROM maintain_field_template_group WHERE field_template_id = @field_template_id

	INSERT INTO #temp_deal_tabs (id, [text], active, seq_no, default_tab, header_detail)
    SELECT CAST(field_group_id AS NVARCHAR),
        group_name,
        CASE WHEN seq_no = @min_seq_no THEN 'true' ELSE NULL END,
        seq_no,
        default_tab,
		'h'
    FROM maintain_field_template_group
    WHERE field_template_id = @field_template_id
    --ORDER BY seq_no
	UNION ALL
	SELECT 'template_detail_n', 'General', 'true', 99999, NULL, 'd'
	
	-- Add Detail UDT tabs
	INSERT INTO #temp_deal_tabs(id, [text], active, seq_no, default_tab, header_detail)
	SELECT group_id, group_name, NULL, 99999 + seq_no, default_tab, 'd'
	FROM maintain_field_template_group_detail
	WHERE field_template_id = @field_template_id

	IF @field_template_id IS NULL
	BEGIN
		INSERT INTO #temp_deal_tabs (id, [text], active, seq_no, default_tab, header_detail)
		SELECT CAST(-1 AS VARCHAR),
			'General',
			'true',
			1,
			1,
			'h'
	END

	--## Form Field Details
	IF OBJECT_ID('tempdb..#temp_deal_header_fields') IS NOT NULL
 		DROP TABLE #temp_deal_header_fields
 	
	CREATE TABLE #temp_deal_header_fields(
		[field_template_type] VARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[id]               VARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[label]              VARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[field_type]               VARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[header_detail]		 VARCHAR(200) COLLATE DATABASE_DEFAULT,
 		[system_required]           VARCHAR(20) COLLATE DATABASE_DEFAULT,
 		[sql_string]         VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		[udf_or_system]      CHAR(1) COLLATE DATABASE_DEFAULT,
 		[disabled]           CHAR(1) COLLATE DATABASE_DEFAULT,
		[insert_required]	 VARCHAR(10) COLLATE DATABASE_DEFAULT,
		[hide_control]	 VARCHAR(10) COLLATE DATABASE_DEFAULT,
		[default_value]		 VARCHAR(5000) COLLATE DATABASE_DEFAULT,
 		[update_required]	 VARCHAR(10) COLLATE DATABASE_DEFAULT,
 		[value_required]     VARCHAR(10) COLLATE DATABASE_DEFAULT,
		[field_seq]	INT,
		[field_group_id] VARCHAR(200) COLLATE DATABASE_DEFAULT,
		[field_template_detail_id] INT,
		[dropdown_json]      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		[org_label]			VARCHAR(200) COLLATE DATABASE_DEFAULT,
		[show_in_form]			CHAR(1) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #temp_deal_header_fields
	EXEC spa_setup_deal_template @flag = 'p', @field_template_id = @field_template_id, @header_detail = 'b'
	
	UPDATE tdhf
		SET tdhf.field_group_id = IIF(tdhf.header_detail = 'h', tdhf.field_group_id, 'template_detail_n'),
			tdhf.label = REPLACE(tdhf.label, '"', '\"'),
			tdhf.default_value = REPLACE(tdhf.default_value, '"', '\"'),
			tdhf.org_label = REPLACE(tdhf.org_label, '"', '\"')
	FROM #temp_deal_header_fields tdhf

	IF OBJECT_ID('tempdb..#temp_deal_header_form_json') IS NOT NULL
 		DROP TABLE #temp_deal_header_form_json
 	
	CREATE TABLE #temp_deal_header_form_json(
 		tab_id		  NVARCHAR(50) COLLATE DATABASE_DEFAULT,
 		tab_json      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
 		form_json     NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		seq_no		  INT,
		grid_json     NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		header_detail CHAR(1)
	)


	DECLARE @tab_id NVARCHAR(200), @seq_no INT, @header_or_detail CHAR(1)
	DECLARE tab_cursor CURSOR FORWARD_ONLY READ_ONLY 
	FOR
 		SELECT id, seq_no, header_detail         
 		FROM #temp_deal_tabs 
 		ORDER BY seq_no
	OPEN tab_cursor
	FETCH NEXT FROM tab_cursor INTO @tab_id, @seq_no, @header_or_detail
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @tab_form_json VARCHAR(MAX) = '', @tab_xml NVARCHAR(MAX), @form_xml NVARCHAR(MAX), @grid_xml NVARCHAR(MAX)
		
		IF @sql_version >= 13
		BEGIN
			--SQL 2016 onwards supports 'FOR JSON' to convert SQL resultset into JSON
			SET @tab_xml = ' SET @tab_xml = (SELECT [id],[text],[active]
 										FROM #temp_deal_tabs
										WHERE id = ''' + @tab_id + '''
 										FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
										)'
			EXECUTE sp_executesql @tab_xml,  N'@tab_xml NVARCHAR(MAX) OUTPUT', @tab_xml = @tab_form_json OUTPUT
		END
		ELSE
		BEGIN
			SET @tab_xml = (
 				SELECT [id],
 						[text],
 						active
 				FROM #temp_deal_tabs
 				WHERE id = @tab_id
 				FOR xml RAW('tab'), ROOT('root'), ELEMENTS
 			)
		END

		-- Resolve Dropdown json
		DECLARE @field_name NVARCHAR(100)
		DECLARE dropdown_cursor CURSOR FORWARD_ONLY READ_ONLY
		FOR
			SELECT id, sql_string
			FROM #temp_deal_header_fields
			WHERE field_group_id = @tab_id AND (field_type = 'd' OR field_type = 'c')
 			ORDER BY field_seq
		OPEN dropdown_cursor
		FETCH NEXT FROM dropdown_cursor INTO @field_name, @sql_string
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @dropdown_xml NVARCHAR(MAX)
			DECLARE @temp_dropdown_json NVARCHAR(MAX)

			IF OBJECT_ID(N'tempdb..#combo_items ') IS NOT NULL
				DROP TABLE #combo_items

			CREATE TABLE #combo_items (
				[text]      Nvarchar(200) COLLATE DATABASE_DEFAULT ,
				[value]     Nvarchar(500) COLLATE DATABASE_DEFAULT ,
				[state]		VARCHAR(10) COLLATE DATABASE_DEFAULT DEFAULT 'enable'
			)

			DECLARE @dropdown_type CHAR(1)
			SET @sql_string = NULLIF(@sql_string, 'NULL')
 			SET @dropdown_type = SUBSTRING(@sql_string, 1, 1)
	
 			IF @dropdown_type = '['
 			BEGIN
 				SET @sql_string = REPLACE(@sql_string, CHAR(13), '')
 				SET @sql_string = REPLACE(@sql_string, CHAR(10), '')
 				SET @sql_string = REPLACE(@sql_string, CHAR(32), '')	
 				SET @sql_string = [dbo].[FNAParseStringIntoTable](@sql_string)  
 				EXEC('INSERT INTO #combo_items([value], [text])
 						SELECT value_id, code from (' + @sql_string + ') a(value_id, code)');
 			END 
 			ELSE
 			BEGIN
				BEGIN TRY
					INSERT INTO #combo_items([value], [text])
					EXEC(@sql_string)
				END TRY
				BEGIN CATCH
					INSERT INTO #combo_items([value], [text], [state])
					EXEC(@sql_string)
				END CATCH
			END
			
			IF @sql_version >= 13
			BEGIN
				--SQL 2016 onwards supports 'FOR JSON' to convert SQL resultset into JSON
				SET @dropdown_xml = ' SET @dropdown_xml = (SELECT *
 											FROM #combo_items 
 											FOR JSON AUTO
											)'
				EXECUTE sp_executesql @dropdown_xml,  N'@dropdown_xml NVARCHAR(MAX) OUTPUT', @dropdown_xml = @temp_dropdown_json OUTPUT
			END
			ELSE
			BEGIN
				SET @dropdown_xml = (
					SELECT *
					FROM #combo_items
 					FOR XML RAW('formxml'), ROOT('root'), ELEMENTS
 				)

				SET @dropdown_xml = REPLACE(CAST(@dropdown_xml AS NVARCHAR(MAX)), '"', '\"')

				SET @temp_dropdown_json = dbo.FNAFlattenedJSON(@dropdown_xml)
			END
			
			UPDATE tdhf
				SET tdhf.dropdown_json = IIF(CHARINDEX('[', @temp_dropdown_json, 0) = 1, @temp_dropdown_json, '[' + @temp_dropdown_json + ']')
			FROM #temp_deal_header_fields tdhf
			WHERE tdhf.field_group_id = @tab_id AND tdhf.id = @field_name

			FETCH NEXT FROM dropdown_cursor INTO @field_name, @sql_string
		END
		CLOSE dropdown_cursor
		DEALLOCATE dropdown_cursor

		DECLARE @temp_form_json NVARCHAR(MAX)

		IF @sql_version >= 13
		BEGIN
			SET @form_xml = ' SET @form_xml = (SELECT *
 											FROM #temp_deal_header_fields
 											WHERE field_group_id = ''' + @tab_id + ''' AND udf_or_system IN (''u'', ''s'')
 											ORDER BY field_seq
 											FOR JSON AUTO
											)'
			EXECUTE sp_executesql @form_xml,  N'@form_xml NVARCHAR(MAX) OUTPUT', @form_xml = @temp_form_json OUTPUT
		END
		ELSE
		BEGIN
			SET @form_xml = (
				SELECT *
				FROM #temp_deal_header_fields
 				WHERE field_group_id = @tab_id AND udf_or_system IN ('u', 's')
 				ORDER BY field_seq
 				FOR XML RAW('formxml'), ROOT('root'), ELEMENTS
 			)

			SET @temp_form_json = dbo.FNAFlattenedJSON(@form_xml)

			SET @tab_xml = REPLACE(CAST(@tab_xml AS NVARCHAR(MAX)), '"', '\"')
			SET @tab_form_json = dbo.FNAFlattenedJSON(@tab_xml)
		END
		
		SET @grid_xml = (
			SELECT id, label, 'udt_' + udt_name name, tdhf.show_in_form
			FROM #temp_deal_header_fields tdhf
			INNER JOIN user_defined_tables udt ON udt.udt_id = tdhf.id
 			WHERE tdhf.field_group_id = @tab_id AND tdhf.udf_or_system = 't'
 			ORDER BY field_seq
 			FOR XML RAW('formxml'), ROOT('root'), ELEMENTS
 		)
		SET @grid_xml = REPLACE(CAST(@grid_xml AS NVARCHAR(MAX)), '"', '\"')
		
		DECLARE @temp_grid_json VARCHAR(MAX) = dbo.FNAFlattenedJSON(@grid_xml)
		
		INSERT INTO #temp_deal_header_form_json
 		SELECT @tab_id, @tab_form_json, @temp_form_json, @seq_no, @temp_grid_json, @header_or_detail
		
		FETCH NEXT FROM tab_cursor INTO @tab_id, @seq_no, @header_or_detail
	END
	CLOSE tab_cursor
	DEALLOCATE tab_cursor

	SELECT tab_id, tab_json, form_json, grid_json, header_detail FROM #temp_deal_header_form_json ORDER BY seq_no
END
ELSE IF @flag = 'i'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	IF OBJECT_ID('tempdb..#temp_template_detail') IS NOT NULL
		DROP TABLE #temp_template_detail
	IF OBJECT_ID('tempdb..#temp_template_group_detail') IS NOT NULL
		DROP TABLE #temp_template_group_detail
	IF OBJECT_ID('tempdb..#temp_template_header_fields') IS NOT NULL
		DROP TABLE #temp_template_header_fields
	IF OBJECT_ID('tempdb..#temp_template_header_options') IS NOT NULL
		DROP TABLE #temp_template_header_options
	IF OBJECT_ID('tempdb..#temp_template_detail_fields') IS NOT NULL
		DROP TABLE #temp_template_detail_fields
	IF OBJECT_ID('tempdb..#temp_template_detail_deleted') IS NOT NULL
		DROP TABLE #temp_template_detail_deleted
	IF OBJECT_ID('tempdb..#temp_grid_detail') IS NOT NULL
		DROP TABLE #temp_grid_detail
	IF OBJECT_ID('tempdb..#temp_detail_udt_group') IS NOT NULL
		DROP TABLE #temp_detail_udt_group
	IF OBJECT_ID('tempdb..#temp_detail_udt_grid') IS NOT NULL
		DROP TABLE #temp_detail_udt_grid

	SELECT
			NULLIF(deal_template_id, '') deal_template_id,
			deal_template_name,
			deal_template_description,
			is_active,
			is_mobile,
			show_cost_tab,
			show_detail_cost_tab,
			show_udf_tab
	INTO #temp_template_detail
	FROM OPENXML(@idoc, '/Root', 1)
	WITH (
		deal_template_id INT,
		deal_template_name VARCHAR(100),
		deal_template_description VARCHAR(200),
		is_active CHAR(1),
		is_mobile CHAR(1),
		show_cost_tab CHAR(1),
		show_detail_cost_tab CHAR(1),
		show_udf_tab CHAR(1)
	)

	SELECT
			NULLIF(id, '') group_id,
			[name] group_name,
			[seq] group_seq,
			[show_in_form]
	INTO #temp_template_group_detail
	FROM OPENXML(@idoc, '/Root/TemplateGroup/Group', 1)
	WITH (
		id BIGINT,
		[name] VARCHAR(100),
		seq INT,
		show_in_form CHAR(1)
	)

	SELECT
			id,
			header_detail,
			udf_or_system ,
			NULLIF([disabled], '') [disabled],
			NULLIF(insert_required, '') insert_required,
			NULLIF(hide_control, '') hide_control,
			NULLIF(default_value, '') default_value,
			NULLIF(update_required, '') update_required,
			NULLIF(value_required, '') value_required,
			field_seq,
			field_group_id,
			field_template_detail_id,
			label [field_caption]
	INTO #temp_template_header_fields
	FROM OPENXML(@idoc, '/Root/TemplateHeader/Field', 1)
	WITH (
		id VARCHAR(128),
		header_detail CHAR(1),
		udf_or_system CHAR(1),
		[disabled] CHAR(1),
		insert_required CHAR(1),
		hide_control CHAR(1),
		default_value VARCHAR(200),
		update_required CHAR(1),
		value_required CHAR(1),
		field_seq INT,
		field_group_id VARCHAR(200),
		field_template_detail_id INT,
		label VARCHAR(256)
	)

	SELECT id,
		column_name,
		is_hidden,
		seq,
		grid_id,
		tab_id
	INTO #temp_grid_detail
	FROM   OPENXML(@idoc, '/Root/TemplateHeaderGrid/Grid/GridCol', 1)
	WITH (
		id VARCHAR(100) '@id',
		column_name VARCHAR(100) '@name',
		is_hidden CHAR(1) '@is_hidden',
		seq INT '@seq',
		grid_id VARCHAR(100) '../@id',
		tab_id VARCHAR(100) '../@tab_id'
	)

	SELECT
			field_id,
			NULLIF(field_value, '') field_value
	INTO #temp_template_header_options
	FROM OPENXML(@idoc, '/Root/TemplateOptions/Field', 1)
	WITH (
		field_id VARCHAR(100),
		field_value VARCHAR(100)
	)

	SELECT
			id,
			header_detail,
			udf_or_system ,
			NULLIF([disabled], '') [disabled],
			NULLIF(insert_required, '') insert_required,
			NULLIF(hide_control, '') hide_control,
			NULLIF(default_value, '') default_value,
			NULLIF(update_required, '') update_required,
			NULLIF(value_required, '') value_required,
			field_seq,
			field_group_id,
			field_template_detail_id,
			label [field_caption],
			NULLIF(show_in_form, '') show_in_form
	INTO #temp_template_detail_fields
	FROM OPENXML(@idoc, '/Root/TemplateDetail/Field', 1)
	WITH (
		id VARCHAR(128),
		header_detail CHAR(1),
		udf_or_system CHAR(1),
		[disabled] CHAR(1),
		insert_required CHAR(1),
		hide_control CHAR(1),
		default_value VARCHAR(200),
		update_required CHAR(1),
		value_required CHAR(1),
		field_seq INT,
		field_group_id VARCHAR(200),
		field_template_detail_id INT,
		label VARCHAR(256),
		show_in_form CHAR(1)
	)

	SELECT
			NULLIF(id, '') group_id,
			[name] group_name,
			[seq] group_seq
	INTO #temp_detail_udt_group
	FROM OPENXML(@idoc, '/Root/DetailUdtGroup/Group', 1)
	WITH (
		id BIGINT,
		[name] VARCHAR(100),
		seq INT
	)

	SELECT id,
		column_name,
		is_hidden,
		seq,
		grid_id,
		tab_id
	INTO #temp_detail_udt_grid
	FROM OPENXML(@idoc, '/Root/DetailUdtGrid/Grid/GridCol', 1)
	WITH (
		id VARCHAR(100) '@id',
		column_name VARCHAR(100) '@name',
		is_hidden CHAR(1) '@is_hidden',
		seq INT '@seq',
		grid_id VARCHAR(100) '../@id',
		tab_id VARCHAR(100) '../@tab_id'
	)

	DECLARE @temp_deal_template_id INT = NULL, @temp_deal_template_name VARCHAR(256), @new_field_template_id INT, @show_cost_tab NCHAR(1) = NULL, @show_detail_cost_tab NCHAR(1) = NULL
	SELECT @temp_deal_template_id = deal_template_id, @temp_deal_template_name = deal_template_name, @show_cost_tab = show_cost_tab, @show_detail_cost_tab = show_detail_cost_tab FROM #temp_template_detail
	
	DECLARE @detail_grid_xml VARCHAR(MAX), @detail_grid_xml_table_name VARCHAR(200)
	SELECT @detail_grid_xml = '<Root>' + CAST(col.query('.') AS VARCHAR(MAX)) + '</Root>'
	FROM @xml.nodes('/Root/DetailGrid') AS xmlData(col)
	
	IF @detail_grid_xml <> '<Root><DetailGrid/></Root>'
	BEGIN
		IF OBJECT_ID('tempdb..#grid_xml_process_table_name') IS NOT NULL
			DROP TABLE #grid_xml_process_table_name

		CREATE TABLE #grid_xml_process_table_name(table_name VARCHAR(200) COLLATE DATABASE_DEFAULT  )
		INSERT INTO #grid_xml_process_table_name EXEC spa_parse_xml_file 'b', NULL, @detail_grid_xml
		SELECT @detail_grid_xml_table_name = table_name FROM #grid_xml_process_table_name
	END

	SELECT
			source_deal_detail_id
	INTO #temp_template_detail_deleted
	FROM OPENXML(@idoc, '/Root/DeletedDetail/GridRow', 1)
	WITH (
		source_deal_detail_id INT
	)
	
	--## Deal Template Name Duplicate Validation
	SELECT @field_template_id = field_template_id FROM source_deal_header_template WHERE template_id = @temp_deal_template_id

	IF EXISTS(SELECT 1 FROM maintain_field_template WHERE template_name = @temp_deal_template_name AND field_template_id <> @field_template_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
			 'Setup Deal Template',
			 'spa_setup_deal_template',
			 'Error',
			 'Deal Template with this name already exists.',
			 ''
		RETURN
	END

	BEGIN TRY
		BEGIN TRAN
		
		IF OBJECT_ID('tempdb..#temp_temp_header_data') IS NOT NULL
			DROP TABLE #temp_temp_header_data

		SELECT id,
			CAST(default_value AS VARCHAR(100)) default_value,
			udf_or_system [udf_system]
		INTO #temp_temp_header_data FROM #temp_template_header_fields WHERE id <> 'sub_book' AND id <> 'template_id'
		UNION ALL
		SELECT 'template_name', @temp_deal_template_name, 's'
		UNION ALL
		SELECT field_id, field_value, 's' FROM #temp_template_header_options
		
		DECLARE @inserted_group TABLE(new_group_id INT, group_name VARCHAR(256))
		IF OBJECT_ID('tempdb..#values_to_update') IS NOT NULL
			DROP TABLE #values_to_update

		CREATE TABLE #values_to_update(field_value VARCHAR(100) COLLATE DATABASE_DEFAULT, field_name VARCHAR(100) COLLATE DATABASE_DEFAULT, leg INT)
		
		IF @temp_deal_template_id IS NULL
		BEGIN
			INSERT INTO maintain_field_template(template_name, template_description, active_inactive, is_mobile, show_cost_tab, show_detail_cost_tab, show_udf_tab)
			SELECT deal_template_name, deal_template_description, is_active, is_mobile, show_cost_tab, show_detail_cost_tab, show_udf_tab FROM #temp_template_detail

			SET @new_field_template_id = SCOPE_IDENTITY()
			
			INSERT INTO maintain_field_template_group(field_template_id, group_name, seq_no)
			OUTPUT INSERTED.field_group_id, INSERTED.group_name
			INTO @inserted_group
			SELECT @new_field_template_id, group_name, group_seq FROM #temp_template_group_detail

			IF @show_cost_tab = 'y'
			 BEGIN
			 	INSERT maintain_field_template_group (
					field_template_id,
					group_name,
					seq_no,
					default_tab
				
			 	)
			 	SELECT @new_field_template_id, 'Cost', 2, 1	
			 END		 
		 
			INSERT INTO maintain_field_template_detail(field_template_id, field_group_id, field_id, seq_no, is_disable, insert_required, field_caption, default_value, udf_or_system, update_required, hide_control, value_required, show_in_form)
			SELECT @new_field_template_id, ig.new_group_id, COALESCE(mfd.field_id, udft.udf_template_id), tthf.field_seq, tthf.disabled, tthf.insert_required, tthf.field_caption, tthf.default_value, tthf.udf_or_system, tthf.update_required, tthf.hide_control, tthf.value_required, NULL
			FROM #temp_template_header_fields tthf
			LEFT JOIN maintain_field_deal mfd ON mfd.farrms_field_id = tthf.id AND tthf.udf_or_system = 's' AND mfd.header_detail = 'h'
			LEFT JOIN user_defined_fields_template udft ON 'UDF___' + CAST(udft.udf_template_id AS VARCHAR(20)) = tthf.id AND tthf.udf_or_system = 'u'
			LEFT JOIN #temp_template_group_detail ttgd ON ttgd.group_id = tthf.field_group_id
			INNER JOIN @inserted_group ig ON ig.group_name = ttgd.group_name
			UNION ALL
			SELECT @new_field_template_id, NULL, COALESCE(mfd.field_id, udft.udf_template_id), ttdf.field_seq, ttdf.disabled, ttdf.insert_required, ttdf.field_caption, ttdf.default_value, ttdf.udf_or_system, ttdf.update_required, ttdf.hide_control, ttdf.value_required, ttdf.show_in_form
			FROM #temp_template_detail_fields ttdf
			LEFT JOIN maintain_field_deal mfd ON mfd.farrms_field_id = ttdf.id AND ttdf.udf_or_system = 's' AND mfd.header_detail = 'd'
			LEFT JOIN user_defined_fields_template udft ON 'UDF___' + CAST(udft.udf_template_id AS VARCHAR(20)) = ttdf.id AND ttdf.udf_or_system = 'u'
			
			INSERT INTO #temp_temp_header_data(id, default_value, udf_system)
			SELECT 'field_template_id', CAST(@new_field_template_id AS VARCHAR(100)), 's'
			
			DECLARE @col_id_string VARCHAR(MAX),@deal_header_template_id INT
			DECLARE @template_update_list VARCHAR(MAX)
			SELECT @template_update_list = ISNULL(@template_update_list + ',', '' ) + CASE WHEN a.id = 'attribute_type' THEN 
						'CASE WHEN ISNULL(' + a.id + ', '''') = 45902 THEN ''a'' WHEN ISNULL(' + a.id + ', '''') = 45901 THEN ''f'' ELSE ISNULL(' + a.id + ', '''') END'
					ELSE a.id END,
				   @col_id_string = ISNULL(@col_id_string + ',', '' )  + a.id 
			FROM #temp_temp_header_data a
			WHERE a.udf_system = 's'
				AND a.id NOT IN ('source_system_book_id1', 'source_system_book_id2', 'source_system_book_id3', 'source_system_book_id4')

			IF OBJECT_ID('tempdb..#temp_inserted_sdth') IS NOT NULL
				DROP TABLE #temp_inserted_sdth

			CREATE TABLE #temp_inserted_sdth(template_id INT)

			SET @sql = '
				INSERT INTO source_deal_header_template(' + @col_id_string + ')
				OUTPUT INSERTED.template_id
				INTO #temp_inserted_sdth
				SELECT ' + @template_update_list + ' FROM #temp_temp_header_data
				PIVOT (MAX (default_value) FOR id IN (' + @col_id_string + ')) AS default_value
				WHERE udf_system = ''s''
			'
			EXEC(@sql)
			
			SELECT @deal_header_template_id = template_id FROM #temp_inserted_sdth

			INSERT INTO [user_defined_deal_fields_template_main]
			(
				template_id,
				field_name,
				Field_label,
				Field_type,
				data_type,
				is_required,
				sql_string,
				udf_type,
				sequence,
				field_size,
				field_id,	    
				book_id,
				udf_group,
				udf_tabgroup,
				formula_id,
				internal_field_type,
				currency_field_id,
				udf_user_field_id,
				leg,
				default_value
			)
			SELECT sdht.template_id,
				   udft.field_name,
				   udft.field_label,
				   udft.field_type,
				   udft.data_type,
				   udft.is_required,
				   ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string) sql_string,
				   udft.udf_type,
				   udft.sequence,
				   udft.field_size,
				   udft.field_id,
				   udft.book_id,
				   udft.udf_group,
				   udft.udf_tabgroup,
				   udft.formula_id,
				   udft.internal_field_type,
				   NULL currency_field_id,
				   udft.udf_template_id udf_user_field_id,	       
				   udft.leg leg,
				   udft.default_value
			FROM #temp_temp_header_data s
			INNER JOIN user_defined_fields_template udft
				ON  s.id = 'UDF___' + CAST(udft.udf_template_id AS VARCHAR)
			CROSS JOIN source_deal_header_template sdht
			LEFT JOIN udf_data_source uds
				ON uds.udf_data_source_id = udft.data_source_type_id
			WHERE s.udf_system = 'u' AND sdht.field_template_id = @new_field_template_id AND udft.udf_type = 'h'

			-- UDF Fields in Deal Template Detail Start
			SET @sql = '
			INSERT INTO [user_defined_deal_fields_template_main]
			(
				template_id,
				field_name,
				Field_label,
				Field_type,
				data_type,
				is_required,
				sql_string,
				udf_type,
				sequence,
				field_size,
				field_id,	    
				book_id,
				udf_group,
				udf_tabgroup,
				formula_id,
				internal_field_type,
				currency_field_id,
				udf_user_field_id,
				leg,
				default_value
			)
			SELECT ' + CAST(@deal_header_template_id AS VARCHAR(100)) + ',
				   udft.field_name,
				   udft.field_label,
				   udft.field_type,
				   udft.data_type,
				   udft.is_required,
				   ISNULL(NULLIF(udft.sql_string, ''''), uds.sql_string) sql_string,
				   udft.udf_type,
				   udft.sequence,
				   udft.field_size,
				   udft.field_id,
				   udft.book_id,
				   udft.udf_group,
				   udft.udf_tabgroup,
				   udft.formula_id,
				   udft.internal_field_type,
				   NULL currency_field_id,
				   udft.udf_template_id udf_user_field_id,	       
				   NULL leg, --detail_leg.leg leg,
				   udft.default_value
			FROM #temp_template_detail_fields a
			LEFT JOIN user_defined_fields_template udft
				ON  a.id = ''UDF___'' + CAST(udft.udf_template_id AS VARCHAR)
			LEFT JOIN user_defined_deal_fields_template_main uddft
				ON  uddft.udf_user_field_id = udft.udf_template_id AND uddft.template_id = ' + CAST(@deal_header_template_id AS VARCHAR(100))  + '
			LEFT JOIN udf_data_source uds
				ON uds.udf_data_source_id = udft.data_source_type_id
			--CROSS JOIN (SELECT leg FROM ' + @detail_grid_xml_table_name + ') detail_leg
			WHERE a.udf_or_system = ''u'' AND uddft.udf_template_id IS NULL
			'
			EXEC(@sql)
			
			SET @col_id_string = NULL
			SELECT @col_id_string = COALESCE(@col_id_string+N',', N'') + QUOTENAME(c.name)
				FROM adiha_process.dbo.sysobjects o WITH(NOLOCK)
				INNER JOIN adiha_process.dbo.syscolumns c WITH(NOLOCK) ON o.id = c.id AND o.xtype = 'U'
				WHERE (o.name = REPLACE(@detail_grid_xml_table_name, 'adiha_process.dbo.', '')) AND c.name <> 'source_deal_detail_id' AND c.name <> 'leg'
					AND c.name LIKE 'UDF[_][_][_]%'
			
			SET @sql = '
				INSERT INTO #values_to_update
				SELECT a, b, leg
				FROM   
					(SELECT *
					FROM  ' + @detail_grid_xml_table_name + ') a  
				UNPIVOT  
					(a FOR b IN   
						(' + @col_id_string + ')
				)AS unpvt;
			'
			EXEC(@sql)
			
			UPDATE uddft
				SET uddft.default_value = a.field_value
			FROM #values_to_update a
			LEFT JOIN user_defined_fields_template udft
				ON  a.field_name = 'UDF___' + CAST(udft.udf_template_id AS VARCHAR)
			LEFT JOIN user_defined_deal_fields_template_main uddft
				ON  uddft.udf_user_field_id = udft.udf_template_id AND uddft.leg = a.leg
			WHERE uddft.template_id = @deal_header_template_id AND uddft.udf_template_id IS NOT NULL
			-- UDF Fields in Deal Template Detail End

			IF @detail_grid_xml IS NOT NULL
			BEGIN
				SET @sql = 'ALTER TABLE ' + @detail_grid_xml_table_name + ' ADD template_id VARCHAR(MAX)'
				EXEC(@sql)
				SET @sql = 'UPDATE ' + @detail_grid_xml_table_name + ' SET template_id = ' + CAST(@deal_header_template_id AS VARCHAR(10))
				EXEC(@sql)
				
				SET @col_id_string = NULL
				DECLARE @select_list VARCHAR(MAX)
				SELECT @col_id_string = COALESCE(@col_id_string+N',', N'') + QUOTENAME(c.name),
						@select_list = COALESCE(@select_list+N',', N'') +  'NULLIF(NULLIF(a.'+ c.name +',''NULL''),'''')' 
				FROM adiha_process.dbo.sysobjects o WITH(NOLOCK)
				INNER JOIN adiha_process.dbo.syscolumns c WITH(NOLOCK) ON o.id = c.id AND o.xtype = 'U'
				WHERE (o.name = REPLACE(@detail_grid_xml_table_name, 'adiha_process.dbo.', '')) AND c.name <> 'source_deal_detail_id'
					AND c.name NOT LIKE 'UDF[_][_][_]%'
				
				SET @sql = '
					INSERT INTO source_deal_detail_template(' + @col_id_string + ')
					SELECT ' + @select_list + ' FROM ' + @detail_grid_xml_table_name + ' a'
				EXEC(@sql)
			END
		END
		ELSE
		BEGIN
			SET @deal_header_template_id = @temp_deal_template_id
			
			UPDATE mft
				SET mft.template_name = ttd.deal_template_name,
					mft.template_description = ttd.deal_template_description,
					mft.active_inactive = ttd.is_active,
					mft.is_mobile = ttd.is_mobile,
					mft.show_cost_tab = ttd.show_cost_tab,
					mft.show_detail_cost_tab = ttd.show_detail_cost_tab,
					mft.show_udf_tab = ttd.show_udf_tab
			FROM maintain_field_template mft
			INNER JOIN source_deal_header_template sdht ON sdht.field_template_id = mft.field_template_id
			INNER JOIN #temp_template_detail ttd ON ttd.deal_template_id = sdht.template_id

			DECLARE @deleted_group_id VARCHAR(4000) = NULL
			SELECT @deleted_group_id = ISNULL(@deleted_group_id + ',', '') + CAST(mftg.field_group_id AS VARCHAR(10))
			FROM maintain_field_template_group mftg
			LEFT JOIN #temp_template_group_detail ttgd ON mftg.field_group_id = ttgd.group_id
			WHERE mftg.field_template_id = @field_template_id AND ttgd.group_id IS NULL

			IF OBJECT_ID('tempdb..#grid_id_to_delete') IS NOT NULL
				DROP TABLE #grid_id_to_delete
		
			SELECT mftd.field_id [grid_id]
			INTO #grid_id_to_delete
			FROM maintain_field_template_detail mftd
			INNER JOIN SplitCommaSeperatedValues(@deleted_group_id) d ON d.item = mftd.field_group_id
			OUTER APPLY (
				SELECT field_id
				FROM maintain_field_template_detail mftd1
				WHERE mftd.field_id = mftd1.field_id AND mftd1.udf_or_system = 't' AND mftd.field_group_id <> mftd1.field_group_id
			) a
			WHERE a.field_id IS NULL AND mftd.udf_or_system = 't'

			DECLARE @deleted_detail_group_id VARCHAR(1000) = NULL
			SELECT @deleted_detail_group_id = ISNULL(@deleted_detail_group_id + ',', '') + CAST(mftgd.group_id AS VARCHAR(10))
			FROM maintain_field_template_group_detail mftgd
			LEFT JOIN #temp_detail_udt_group tdug ON mftgd.group_id = tdug.group_id
			WHERE mftgd.field_template_id = @field_template_id AND tdug.group_id IS NULL

			INSERT INTO #grid_id_to_delete
			SELECT mftd.field_id [grid_id]
			FROM maintain_field_template_detail mftd
			INNER JOIN SplitCommaSeperatedValues(@deleted_detail_group_id) d ON d.item = mftd.detail_group_id
			OUTER APPLY (
				SELECT field_id
				FROM maintain_field_template_detail mftd1
				WHERE mftd.field_id = mftd1.field_id AND mftd1.udf_or_system = 't' AND mftd.detail_group_id <> mftd1.detail_group_id
			) a
			WHERE a.field_id IS NULL AND mftd.udf_or_system = 't'

			DELETE mftd
			FROM maintain_field_template_detail mftd
			INNER JOIN SplitCommaSeperatedValues(@deleted_group_id) d ON d.item = mftd.field_group_id

			DELETE mftg
			FROM maintain_field_template_group mftg
			INNER JOIN SplitCommaSeperatedValues(@deleted_group_id) d ON d.item = mftg.field_group_id

			UPDATE mftg
				SET mftg.group_name = ttgd.group_name,
					mftg.seq_no = ttgd.group_seq
			FROM #temp_template_group_detail ttgd
			INNER JOIN maintain_field_template_group mftg ON mftg.field_group_id = ttgd.group_id

			UPDATE mftd
				SET mftd.show_in_form = ttgd.show_in_form
			FROM #temp_template_group_detail ttgd
			INNER JOIN maintain_field_template_detail mftd ON mftd.field_group_id = ttgd.group_id

			IF @show_cost_tab = 'y'
			BEGIN
				DECLARE @max_seq_id INT			
				IF NOT EXISTS (SELECT 1 FROM maintain_field_template_group WHERE default_tab = 1 AND field_template_id = @field_template_id)
				BEGIN
					SELECT @max_seq_id = MAX(seq_no) FROM maintain_field_template_group WHERE field_template_id = @field_template_id
					IF NOT EXISTS(SELECT 1 FROM maintain_field_template_group WHERE group_name = 'Costs' AND field_template_id = @field_template_id)
					BEGIN
						INSERT maintain_field_template_group (
							field_template_id,
							group_name,
							seq_no,
							default_tab
			 			)
			 			SELECT @field_template_id, 'Costs', @max_seq_id + 1, 1
					END
				END			
			END
			
			INSERT INTO maintain_field_template_group(field_template_id, group_name, seq_no)
			OUTPUT INSERTED.field_group_id, INSERTED.group_name
			INTO @inserted_group
			SELECT @field_template_id, ttgd.group_name, ttgd.group_seq
			FROM #temp_template_group_detail ttgd
			LEFT JOIN maintain_field_template_group mftg ON mftg.field_group_id = ttgd.group_id
			WHERE mftg.field_group_id IS NULL
			
			-- Delete Header fields
			DELETE mftd
			FROM maintain_field_template_detail mftd
			LEFT JOIN #temp_template_header_fields tthf ON mftd.field_template_detail_id = tthf.field_template_detail_id
			WHERE mftd.field_template_id = @field_template_id AND mftd.field_group_id IS NOT NULL AND tthf.id IS NULL AND mftd.udf_or_system IN ('s', 'u')

			INSERT INTO maintain_field_template_detail(field_template_id, field_group_id, field_id, seq_no, is_disable, insert_required, field_caption, default_value, udf_or_system, update_required, hide_control, value_required)
			SELECT @field_template_id, ISNULL(ig.new_group_id, tthf.field_group_id), COALESCE(mfd.field_id, udft.udf_template_id), tthf.field_seq, tthf.disabled, tthf.insert_required, tthf.field_caption, tthf.default_value, tthf.udf_or_system, tthf.update_required, tthf.hide_control, tthf.value_required
			FROM #temp_template_header_fields tthf
			LEFT JOIN maintain_field_deal mfd ON mfd.farrms_field_id = tthf.id AND tthf.udf_or_system = 's' AND mfd.header_detail = 'h'
			LEFT JOIN user_defined_fields_template udft ON 'UDF___' + CAST(udft.udf_template_id AS VARCHAR(20)) = tthf.id AND tthf.udf_or_system = 'u'
			LEFT JOIN #temp_template_group_detail ttgd ON ttgd.group_id = tthf.field_group_id
			LEFT JOIN @inserted_group ig ON ig.group_name = ttgd.group_name
			WHERE tthf.field_template_detail_id IS NULL

			UPDATE mftd
				SET mftd.field_group_id = ISNULL(ig.new_group_id, tthf.field_group_id),
					mftd.seq_no = tthf.field_seq,
					mftd.is_disable = tthf.disabled,
					mftd.insert_required = tthf.insert_required,
					mftd.field_caption = tthf.field_caption,
					mftd.default_value = tthf.default_value,
					mftd.update_required = tthf.update_required,
					mftd.hide_control = tthf.hide_control,
					mftd.value_required = tthf.value_required
			FROM #temp_template_header_fields tthf
			LEFT JOIN #temp_template_group_detail ttgd ON ttgd.group_id = tthf.field_group_id
			LEFT JOIN @inserted_group ig ON ig.group_name = ttgd.group_name
			INNER JOIN maintain_field_template_detail mftd ON mftd.field_template_detail_id = tthf.field_template_detail_id
			WHERE tthf.field_template_detail_id IS NOT NULL

			UPDATE sdht
				SET sdht.template_name = ttd.deal_template_name,
					sdht.is_active = ttd.is_active
			FROM source_deal_header_template sdht
			INNER JOIN #temp_template_detail ttd ON ttd.deal_template_id = sdht.template_id
			
			SELECT @template_update_list = ISNULL(@template_update_list + ',', '' ) + 'b.' + a.id + ' = NULLIF(NULLIF('''+ 
					CASE WHEN a.id = 'attribute_type' THEN 
						CASE WHEN ISNULL(a.default_value, '') = 45902 THEN 'a' WHEN ISNULL(a.default_value, '') = 45901 THEN 'f' ELSE ISNULL(a.default_value, '') END
					ELSE ISNULL(a.default_value, '') END + ''',''NULL''),'''')',
					@col_id_string = ISNULL(@col_id_string + ',', '' ) + a.id
			FROM #temp_temp_header_data a
			WHERE a.udf_system = 's'
				AND a.id NOT IN ('source_system_book_id1', 'source_system_book_id2', 'source_system_book_id3', 'source_system_book_id4')
			
			SET @sql = '	
							SELECT *
							INTO #temp_header_template
							FROM #temp_temp_header_data
							PIVOT (MAX (default_value) FOR id IN (' + @col_id_string + ')) AS default_value
							WHERE udf_system = ''s''
							
							UPDATE b
								SET ' + @template_update_list + '
							FROM #temp_header_template a
							CROSS JOIN source_deal_header_template b
							WHERE b.template_id = ' + CAST(@deal_header_template_id AS VARCHAR(100))
			EXEC(@sql)
			
			-- UDF Fields in Deal Template Header Start
			DELETE uddft
			FROM user_defined_deal_fields_template_main uddft
			LEFT JOIN user_defined_fields_template udft
				ON  uddft.udf_user_field_id = udft.udf_template_id
			LEFT JOIN #temp_temp_header_data a
				ON  a.id = 'UDF___' + CAST(udft.udf_template_id AS VARCHAR) AND a.udf_system = 'u'
			WHERE a.id IS NULL AND uddft.template_id = @deal_header_template_id AND uddft.udf_type = 'h'

			INSERT INTO [user_defined_deal_fields_template_main]
			(
				template_id,
				field_name,
				Field_label,
				Field_type,
				data_type,
				is_required,
				sql_string,
				udf_type,
				sequence,
				field_size,
				field_id,	    
				book_id,
				udf_group,
				udf_tabgroup,
				formula_id,
				internal_field_type,
				currency_field_id,
				udf_user_field_id,
				leg,
				default_value
			)
			SELECT @deal_header_template_id,
				   udft.field_name,
				   udft.field_label,
				   udft.field_type,
				   udft.data_type,
				   udft.is_required,
				   ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string) sql_string,
				   udft.udf_type,
				   udft.sequence,
				   udft.field_size,
				   udft.field_id,
				   udft.book_id,
				   udft.udf_group,
				   udft.udf_tabgroup,
				   udft.formula_id,
				   udft.internal_field_type,
				   NULL currency_field_id,
				   udft.udf_template_id udf_user_field_id,	       
				   udft.leg leg,
				   udft.default_value
			FROM #temp_temp_header_data a
			LEFT JOIN user_defined_fields_template udft
				ON  a.id = 'UDF___' + CAST(udft.udf_template_id AS VARCHAR)
			LEFT JOIN user_defined_deal_fields_template_main uddft
				ON  uddft.udf_user_field_id = udft.udf_template_id AND uddft.template_id = @deal_header_template_id 
			LEFT JOIN udf_data_source uds
				ON uds.udf_data_source_id = udft.data_source_type_id
			WHERE a.udf_system = 'u' AND uddft.udf_template_id IS NULL

			UPDATE uddft
				SET uddft.default_value = a.default_value
			FROM #temp_temp_header_data a
			LEFT JOIN user_defined_fields_template udft
				ON  a.id = 'UDF___' + CAST(udft.udf_template_id AS VARCHAR)
			LEFT JOIN user_defined_deal_fields_template_main uddft
				ON  uddft.udf_user_field_id = udft.udf_template_id
			WHERE uddft.template_id = @deal_header_template_id AND a.udf_system = 'u' AND uddft.udf_template_id IS NOT NULL
			-- UDF Fields in Deal Template Header End
			-- UDF Fields in Deal Template Detail Start
			DELETE uddft
			FROM user_defined_deal_fields_template_main uddft
			LEFT JOIN user_defined_fields_template udft
				ON  uddft.udf_user_field_id = udft.udf_template_id
			LEFT JOIN #temp_template_detail_fields a
				ON  a.id = 'UDF___' + CAST(udft.udf_template_id AS VARCHAR) AND a.udf_or_system = 'u'
			WHERE a.id IS NULL AND uddft.template_id = @deal_header_template_id AND uddft.udf_type = 'd'

			SET @sql = '
			INSERT INTO [user_defined_deal_fields_template_main]
			(
				template_id,
				field_name,
				Field_label,
				Field_type,
				data_type,
				is_required,
				sql_string,
				udf_type,
				sequence,
				field_size,
				field_id,	    
				book_id,
				udf_group,
				udf_tabgroup,
				formula_id,
				internal_field_type,
				currency_field_id,
				udf_user_field_id,
				leg,
				default_value
			)
			SELECT ' + CAST(@deal_header_template_id AS VARCHAR(100)) + ',
				   udft.field_name,
				   udft.field_label,
				   udft.field_type,
				   udft.data_type,
				   udft.is_required,
				   ISNULL(NULLIF(udft.sql_string, ''''), uds.sql_string) sql_string,
				   udft.udf_type,
				   udft.sequence,
				   udft.field_size,
				   udft.field_id,
				   udft.book_id,
				   udft.udf_group,
				   udft.udf_tabgroup,
				   udft.formula_id,
				   udft.internal_field_type,
				   NULL currency_field_id,
				   udft.udf_template_id udf_user_field_id,	       
				   NULL leg, --detail_leg.leg leg,
				   udft.default_value
			FROM #temp_template_detail_fields a
			LEFT JOIN user_defined_fields_template udft
				ON  a.id = ''UDF___'' + CAST(udft.udf_template_id AS VARCHAR)
			LEFT JOIN user_defined_deal_fields_template_main uddft
				ON  uddft.udf_user_field_id = udft.udf_template_id AND uddft.template_id = ' + CAST(@deal_header_template_id AS VARCHAR(100))  + '
			LEFT JOIN udf_data_source uds
				ON uds.udf_data_source_id = udft.data_source_type_id
			--CROSS JOIN (SELECT leg FROM ' + @detail_grid_xml_table_name + ') detail_leg
			WHERE a.udf_or_system = ''u'' AND uddft.udf_template_id IS NULL
			'
			EXEC(@sql)
			
			SET @col_id_string = NULL
			SELECT @col_id_string = COALESCE(@col_id_string+N',', N'') + QUOTENAME(c.name)
				FROM adiha_process.dbo.sysobjects o WITH(NOLOCK)
				INNER JOIN adiha_process.dbo.syscolumns c WITH(NOLOCK) ON o.id = c.id AND o.xtype = 'U'
				WHERE (o.name = REPLACE(@detail_grid_xml_table_name, 'adiha_process.dbo.', '')) AND c.name <> 'source_deal_detail_id' AND c.name <> 'leg'
					AND c.name LIKE 'UDF[_][_][_]%'
			
			SET @sql = '
				INSERT INTO #values_to_update
				SELECT a, b, leg
				FROM   
					(SELECT *
					FROM  ' + @detail_grid_xml_table_name + ') a  
				UNPIVOT  
					(a FOR b IN   
						(' + @col_id_string + ')
				)AS unpvt;
			'
			EXEC(@sql)
			
			UPDATE uddft
				SET uddft.default_value = a.field_value
			FROM #values_to_update a
			LEFT JOIN user_defined_fields_template udft
				ON  a.field_name = 'UDF___' + CAST(udft.udf_template_id AS VARCHAR)
			LEFT JOIN user_defined_deal_fields_template_main uddft
				ON  uddft.udf_user_field_id = udft.udf_template_id AND uddft.leg = a.leg
			WHERE uddft.template_id = @deal_header_template_id AND uddft.udf_template_id IS NOT NULL
			-- UDF Fields in Deal Template Detail End
			
			--Insert added header udf in all previous deals
			INSERT INTO user_defined_deal_fields(source_deal_header_id, udf_template_id)
			SELECT DISTINCT sdh.source_deal_header_id, uddft.udf_template_id
			FROM user_defined_deal_fields_template_main uddft
			LEFT JOIN user_defined_deal_fields uddf
				ON uddf.udf_template_id = uddft.udf_template_id
			LEFT JOIN source_deal_header sdh
				ON sdh.template_id = uddft.template_id
			WHERE uddft.udf_type = 'h' AND uddf.udf_template_id IS NULL AND sdh.template_id = @deal_header_template_id
			--Insert added detail udf in all previous deals
			INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id, udf_template_id)
			SELECT DISTINCT sdd.source_deal_detail_id, uddft.udf_template_id
			FROM user_defined_deal_fields_template_main uddft
			LEFT JOIN user_defined_deal_detail_fields udddf
				ON udddf.udf_template_id = uddft.udf_template_id
			LEFT JOIN source_deal_header sdh
				ON sdh.template_id = uddft.template_id
			LEFT JOIN source_deal_detail sdd
				ON sdh.source_deal_header_id = sdd.source_deal_header_id
			WHERE uddft.udf_type = 'd' AND udddf.udf_template_id IS NULL AND sdh.template_id = @deal_header_template_id

			--## Delete Detail Grid Column/Fields and also deleted the row added for UDT to show in detail
			DELETE mftd
			FROM maintain_field_template_detail mftd
			LEFT JOIN #temp_template_detail_fields ttdf ON ttdf.field_template_detail_id = mftd.field_template_detail_id
			WHERE mftd.field_template_id = @field_template_id
				AND mftd.field_group_id IS NULL AND ttdf.field_template_detail_id IS NULL

			--## Update
			UPDATE mftd
			SET	mftd.is_disable = ttdf.disabled,
				mftd.insert_required = ttdf.insert_required,
				mftd.hide_control = ttdf.hide_control,
				mftd.default_value = ttdf.default_value,
				mftd.update_required = ttdf.update_required,
				mftd.value_required = ttdf.value_required,
				mftd.seq_no = ttdf.field_seq,
				mftd.field_caption = ttdf.field_caption
				, mftd.show_in_form = ttdf.show_in_form
			FROM #temp_template_detail_fields ttdf
			INNER JOIN maintain_field_template_detail mftd ON mftd.field_template_detail_id = ttdf.field_template_detail_id
			WHERE ttdf.field_template_detail_id IS NOT NULL

			--## Insert
			INSERT INTO maintain_field_template_detail(field_template_id, field_group_id, field_id, seq_no, is_disable, insert_required, field_caption, default_value, udf_or_system, update_required, hide_control, value_required, show_in_form)
			SELECT @field_template_id, NULL, COALESCE(mfd.field_id, udft.udf_template_id), ttdf.field_seq, ttdf.disabled, ttdf.insert_required, ttdf.field_caption, ttdf.default_value, ttdf.udf_or_system, ttdf.update_required, ttdf.hide_control, ttdf.value_required, ttdf.show_in_form
			FROM #temp_template_detail_fields ttdf
			LEFT JOIN maintain_field_deal mfd ON mfd.farrms_field_id = ttdf.id AND ttdf.udf_or_system = 's' AND mfd.header_detail = 'd'
			LEFT JOIN user_defined_fields_template udft ON 'UDF___' + CAST(udft.udf_template_id AS VARCHAR(20)) = ttdf.id AND ttdf.udf_or_system = 'u'
			WHERE ttdf.field_template_detail_id IS NULL

			--## Delete Grid if UDT tab removed starts
			IF NOT EXISTS (
				SELECT 1
				FROM maintain_field_template_detail mftd
				INNER JOIN #grid_id_to_delete gitd
					ON gitd.grid_id = mftd.field_id AND udf_or_system = 't'
			)
			BEGIN
				DELETE agcd
				FROM adiha_grid_columns_definition AS agcd
				INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
				INNER JOIN #grid_id_to_delete gitd ON gitd.grid_id = agd.grid_id
			
				DELETE agd
				FROM adiha_grid_definition agd
				INNER JOIN #grid_id_to_delete gitd ON gitd.grid_id = agd.grid_id
			END
			--## Delete Grid if UDT tab removed ends
			
			--##Delete Detail
			DELETE sddt
			FROM #temp_template_detail_deleted ttdd
			INNER JOIN source_deal_detail_template sddt ON sddt.template_detail_id = ttdd.source_deal_detail_id
			
			IF @detail_grid_xml IS NOT NULL
			BEGIN
				SET @sql = 'ALTER TABLE ' + @detail_grid_xml_table_name + ' ADD template_id VARCHAR(MAX)'
				EXEC(@sql)
				SET @sql = 'UPDATE ' + @detail_grid_xml_table_name + ' SET template_id = ' + CAST(@deal_header_template_id AS VARCHAR(10))
				EXEC(@sql)
				
				SET @col_id_string = NULL
				DECLARE @update_list VARCHAR(MAX)
				SELECT @col_id_string = COALESCE(@col_id_string+N',', N'') + QUOTENAME(c.name),
						@select_list = COALESCE(@select_list+N',', N'') +  'NULLIF(NULLIF(a.'+ c.name +',''NULL''),'''')',
						@update_list = COALESCE(@update_list + N', ', N'') + 'b.' + c.name + ' = NULLIF(NULLIF(a.'+ c.name +',''NULL''),'''')'
				FROM adiha_process.dbo.sysobjects o WITH(NOLOCK)
				INNER JOIN adiha_process.dbo.syscolumns c WITH(NOLOCK) ON o.id = c.id AND o.xtype = 'U'
				WHERE (o.name = REPLACE(@detail_grid_xml_table_name, 'adiha_process.dbo.', '')) AND c.name <> 'source_deal_detail_id'
					AND c.name NOT LIKE 'UDF[_][_][_]%'
			
				--##Update Detail
				SET @sql = 'UPDATE b
							SET ' + @update_list + ' FROM ' + @detail_grid_xml_table_name + ' a
							INNER JOIN source_deal_detail_template b ON b.template_detail_id = a.source_deal_detail_id
							WHERE NULLIF(a.source_deal_detail_id, '''') IS NOT NULL'
				EXEC(@sql)
			
				--##Insert Detail
				SET @sql = '
					INSERT INTO source_deal_detail_template(' + @col_id_string + ')
					SELECT ' + @select_list + ' FROM ' + @detail_grid_xml_table_name + ' a WHERE NULLIF(a.source_deal_detail_id, '''') IS NULL'
				EXEC(@sql)
			END
		END
		
		SET @field_template_id = ISNULL(@field_template_id, @new_field_template_id)

		DELETE mftgd
		FROM maintain_field_template_group_detail mftgd
		WHERE mftgd.field_template_id = @field_template_id

		-- UDT Grid Starts
		/**
		 * Create Grid if doesn't exists or update if already exists
		 * Add Grid id in maintain_field_template_detail
		 */
		IF OBJECT_ID('tempdb..#temp_pre_existing_grid_id') IS NOT NULL
			DROP TABLE #temp_pre_existing_grid_id

		IF OBJECT_ID('tempdb..#temp_pre_insert_grid_id') IS NOT NULL
			DROP TABLE #temp_pre_insert_grid_id
		
		IF OBJECT_ID('tempdb..#temp_inserted_grid_detail') IS NOT NULL
			DROP TABLE #temp_inserted_grid_detail
		
		CREATE TABLE #temp_inserted_grid_detail(grid_id INT, grid_name VARCHAR(100) COLLATE DATABASE_DEFAULT)
		
		DROP TABLE IF EXISTS #temp_inserted_detail_group
		CREATE TABLE #temp_inserted_detail_group(group_id INT, group_name VARCHAR(100) COLLATE DATABASE_DEFAULT)
		
		-- ## Update udt_id passed as grid_id with actual grid name
		UPDATE tgd
		SET tgd.grid_id = 'udt_' + udt.udt_name
		FROM #temp_grid_detail tgd
		INNER JOIN user_defined_tables udt ON udt.udt_id = tgd.grid_id

		UPDATE tdug
		SET tdug.grid_id = 'udt_' + udt.udt_name
		FROM #temp_detail_udt_grid tdug
		INNER JOIN user_defined_tables udt ON udt.udt_id = tdug.grid_id

		--Header Grid to insert
		SELECT DISTINCT tgd.grid_id, tgd.tab_id, 'h' [header_detail]
		INTO #temp_pre_insert_grid_id
		FROM #temp_grid_detail tgd
		LEFT JOIN adiha_grid_definition agd ON agd.grid_name = tgd.grid_id
		WHERE agd.grid_id IS NULL
		--Header Grid already existed
		SELECT DISTINCT agd.grid_id, tgd.tab_id, 'h' [header_detail]
		INTO #temp_pre_existing_grid_id
		FROM #temp_grid_detail tgd
		LEFT JOIN adiha_grid_definition agd ON agd.grid_name = tgd.grid_id
		WHERE agd.grid_id IS NOT NULL

		--Detail Grid to insert
		INSERT INTO #temp_pre_insert_grid_id
		SELECT DISTINCT tdug.grid_id, tdug.tab_id, 'd' [header_detail]
		FROM #temp_detail_udt_grid tdug
		LEFT JOIN adiha_grid_definition agd ON agd.grid_name = tdug.grid_id
		WHERE agd.grid_id IS NULL
		--Detail Grid already existed
		INSERT INTO #temp_pre_existing_grid_id
		SELECT DISTINCT agd.grid_id, tdug.tab_id, 'd' [header_detail]
		FROM #temp_detail_udt_grid tdug
		LEFT JOIN adiha_grid_definition agd ON agd.grid_name = tdug.grid_id
		WHERE agd.grid_id IS NOT NULL

		-- Insert UDT Detail Group
		INSERT INTO maintain_field_template_group_detail(group_name, field_template_id, seq_no, default_tab)
		OUTPUT inserted.group_id, inserted.group_name INTO #temp_inserted_detail_group(group_id, group_name)
		SELECT tdugg.group_name, @field_template_id, tdugg.group_seq, NULL
		FROM #temp_detail_udt_group tdugg

		IF EXISTS(SELECT 1 FROM #temp_pre_insert_grid_id)
		BEGIN
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
					FOR XML PATH('')), 1, 1, '') + IIF(tigi.header_detail = 'h', ' = ''<ID>''', ' = <ID>'), ''),
				udt.udt_descriptions, 'g', 10131010, 10131010
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
				CASE WHEN udtm.reference_column = 1 THEN 'source_deal_header' ELSE NULL END [fk_table],
				CASE WHEN udtm.reference_column = 1 THEN 'deal_id' ELSE NULL END [fk_column],
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

			INSERT INTO maintain_field_template_detail(field_template_id, field_group_id, field_id, udf_or_system, show_in_form)
			SELECT @field_template_id, ig.new_group_id, tigd.grid_id, 't', ttgd.show_in_form
			FROM #temp_pre_insert_grid_id tpigi
			INNER JOIN #temp_inserted_grid_detail tigd ON tigd.grid_name = tpigi.grid_id
			LEFT JOIN #temp_template_group_detail ttgd ON ttgd.group_id = tpigi.tab_id
			INNER JOIN @inserted_group ig ON ig.group_name = ttgd.[group_name]
			INNER JOIN maintain_field_template_group mftg ON mftg.field_group_id = ig.new_group_id
			WHERE tpigi.header_detail = 'h'

			INSERT INTO maintain_field_template_detail(field_template_id, detail_group_id, field_id, field_caption, udf_or_system)
			SELECT @field_template_id, tidg.group_id, tigd.grid_id, tigd.grid_id, 't'
			FROM #temp_pre_insert_grid_id tpigi
			INNER JOIN #temp_inserted_grid_detail tigd ON tigd.grid_name = tpigi.grid_id
			LEFT JOIN #temp_detail_udt_group tdug ON tdug.group_id = tpigi.tab_id
			INNER JOIN #temp_inserted_detail_group tidg ON tidg.group_name = tdug.[group_name]
			WHERE tpigi.header_detail = 'd'
		END

		IF EXISTS(SELECT 1 FROM #temp_pre_existing_grid_id)
		BEGIN
			INSERT INTO maintain_field_template_detail(field_template_id, field_group_id, field_id, udf_or_system, show_in_form)
			SELECT @field_template_id, ig.new_group_id, tpigi.grid_id, 't', ttgd.show_in_form
			FROM #temp_pre_existing_grid_id tpigi
			LEFT JOIN #temp_template_group_detail ttgd ON ttgd.group_id = tpigi.tab_id
			INNER JOIN @inserted_group ig ON ig.group_name = ttgd.[group_name]
			INNER JOIN maintain_field_template_group mftg ON mftg.field_group_id = ig.new_group_id
			WHERE tpigi.header_detail = 'h'

			INSERT INTO maintain_field_template_detail(field_template_id, detail_group_id, field_id, field_caption, udf_or_system)
			SELECT @field_template_id, tidg.group_id, tpigi.grid_id, tpigi.grid_id, 't'
			FROM #temp_pre_existing_grid_id tpigi
			LEFT JOIN #temp_detail_udt_group tdug ON tdug.group_id = tpigi.tab_id
			INNER JOIN #temp_inserted_detail_group tidg ON tidg.group_name = tdug.[group_name]
			WHERE tpigi.header_detail = 'd'
		END

		--## Update grid columns info (Header)
		UPDATE agcd
			SET agcd.column_label = tgd.column_name,
				agcd.is_hidden = tgd.is_hidden,
				agcd.column_order = tgd.seq
		FROM adiha_grid_columns_definition agcd
		INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
		INNER JOIN #temp_grid_detail tgd ON tgd.id = agcd.column_name
			AND agd.grid_name = tgd.grid_id

		--## Update grid columns info (Detail)
		UPDATE agcd
			SET agcd.column_label = tgd.column_name,
				agcd.is_hidden = tgd.is_hidden,
				agcd.column_order = tgd.seq
		FROM adiha_grid_columns_definition agcd
		INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
		INNER JOIN #temp_detail_udt_grid tgd ON tgd.id = agcd.column_name
			AND agd.grid_name = tgd.grid_id
		-- UDT Grid Ends
		
		COMMIT
		
		EXEC spa_ErrorHandler @@ERROR,
			'Setup Deal Template',
			'spa_setup_deal_template',
			'Success',
			'Changes have been saved successfully.',
			@deal_header_template_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
			
		EXEC spa_ErrorHandler -1,
			 'Setup Deal Template',
			 'spa_setup_deal_template',
			 'Error',
			 'Failed to save data.',
			 ''
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	DECLARE @del_deal_template_ids VARCHAR(MAX)

	SELECT @del_deal_template_ids = CONCAT(@del_deal_template_ids, template_id, ',')
	FROM source_deal_header_template sdht
	INNER JOIN dbo.FNASplit(@del_field_template_ids, ',') di ON di.item = sdht.field_template_id

	IF EXISTS (
		SELECT 1
		FROM source_deal_header sdh
		INNER JOIN dbo.FNASplit(@del_deal_template_ids, ',') di ON di.item = sdh.template_id
	)
	BEGIN
		EXEC spa_ErrorHandler - 1
			,'Setup Deal Template'
			,'spa_setup_deal_template'
			,'Error'
			,'Template is used in deal.'
			,''

		RETURN
	END
	ELSE
	BEGIN
		BEGIN TRY
		BEGIN TRAN
			DELETE dtpm
			FROM deal_type_pricing_maping dtpm
			INNER JOIN dbo.FNASplit(@del_deal_template_ids, ',') di ON di.item = dtpm.template_id
			
			DELETE uddftm
			FROM user_defined_deal_fields_template_main uddftm
			INNER JOIN dbo.FNASplit(@del_deal_template_ids, ',') di ON di.item = uddftm.template_id
			
			DELETE sddt
			FROM source_deal_detail_template sddt
			INNER JOIN dbo.FNASplit(@del_deal_template_ids, ',') di ON di.item = sddt.template_id


			DELETE dfm
			FROM deal_fields_mapping dfm
			INNER JOIN dbo.FNASplit(@del_deal_template_ids, ',') di ON di.item = dfm.template_id

 			--DELETE FROM deal_transfer_mapping WHERE template_id = @deal_template_id
 			DELETE sdht
			FROM source_deal_header_template sdht
			INNER JOIN dbo.FNASplit(@del_deal_template_ids, ',') di ON di.item = sdht.template_id
			
			IF NOT EXISTS(
				SELECT 1
				FROM source_deal_header_template sdht
				INNER JOIN dbo.FNASplit(@del_field_template_ids, ',') di ON di.item = sdht.field_template_id
			)
			BEGIN
				--## Delete Grid if UDT tab exists starts
				IF OBJECT_ID('tempdb..#grid_to_delete') IS NOT NULL
					DROP TABLE #grid_to_delete
				
				SELECT mftd.field_id [grid_id]
				INTO #grid_to_delete
				FROM maintain_field_template_detail mftd
				OUTER APPLY (
					SELECT field_id
					FROM maintain_field_template_detail mftd1
					WHERE mftd.field_id = mftd1.field_id AND mftd1.udf_or_system = 't' AND mftd.field_group_id <> mftd1.field_group_id
				) a
				WHERE mftd.field_template_id = @field_template_id AND mftd.udf_or_system = 't' AND a.field_id IS NULL
		
				DELETE agcd
				FROM adiha_grid_columns_definition AS agcd
				INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
				INNER JOIN #grid_to_delete gitd ON gitd.grid_id = agd.grid_id
			
				DELETE agd
				FROM adiha_grid_definition agd
				INNER JOIN #grid_to_delete gitd ON gitd.grid_id = agd.grid_id
				--## Delete Grid if UDT tab exists ends

				DELETE mftd
				FROM maintain_field_template_detail mftd
				INNER JOIN dbo.FNASplit(@del_field_template_ids, ',') di ON di.item = mftd.field_template_id

				DELETE mftg
				FROM maintain_field_template_group mftg
				INNER JOIN dbo.FNASplit(@del_field_template_ids, ',') di ON di.item = mftg.field_template_id

				DELETE mftgd
				FROM maintain_field_template_group_detail mftgd
				INNER JOIN dbo.FNASplit(@del_field_template_ids, ',') di ON di.item = mftgd.field_template_id

				DELETE mft
				FROM maintain_field_template mft
				INNER JOIN dbo.FNASplit(@del_field_template_ids, ',') di ON di.item = mft.field_template_id
			END

			COMMIT

			EXEC spa_ErrorHandler 0
			,'Source Deal Template'
			,'spa_setup_deal_template'
			,'Success'
			,'Changes have been saved successfully.'
			,@del_field_template_ids

		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK
			
			DECLARE @error_message VARCHAR(4000)
			SELECT @error_message = ERROR_MESSAGE()
			EXEC spa_ErrorHandler -1,
				 'Setup Deal Template',
				 'spa_setup_deal_template',
				 'Error',
				 @error_message,
				 ''
		END CATCH
	END
END
ELSE IF @flag = 'c'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		
		CREATE TABLE #tmp_table_fields_templates(
			 org_fields_templates_id INT, 
			 copied_fields_templates_id INT 
		)

		INSERT INTO maintain_field_template(template_name, template_description, active_inactive, is_mobile, show_cost_tab, show_detail_cost_tab, show_udf_tab)
		OUTPUT INSERTED.template_name, INSERTED.field_template_id INTO #tmp_table_fields_templates
		SELECT field_template_id, template_description, active_inactive, is_mobile, show_cost_tab, show_detail_cost_tab, show_udf_tab
		FROM maintain_field_template WHERE field_template_id = @field_template_id

		UPDATE mft
		SET template_name = temp_cnt.new_temp_name
		FROM maintain_field_template mft
		INNER JOIN #tmp_table_fields_templates ttft
		    ON mft.field_template_id = ttft.copied_fields_templates_id
		INNER JOIN maintain_field_template mft_org
		    ON ttft.org_fields_templates_id = mft_org.field_template_id
		CROSS APPLY(
		    SELECT '(' + CAST(COUNT(template_name) + 01 AS VARCHAR(10)) + 
		           ') Copy of ' + mft_org.template_name new_temp_name
		    FROM   maintain_field_template
		    WHERE  template_name LIKE '(_) Copy of ' + mft_org.template_name
		           OR  template_name LIKE '(__) Copy of ' + mft_org.template_name
		           OR  template_name LIKE '(___) Copy of ' + mft_org.template_name
		) temp_cnt

		SELECT @new_field_template_id = copied_fields_templates_id FROM #tmp_table_fields_templates
		
		INSERT INTO maintain_field_template_group(field_template_id, group_name, seq_no, default_tab)
		OUTPUT INSERTED.field_group_id, INSERTED.group_name
		INTO @inserted_group
		SELECT @new_field_template_id, group_name, seq_no, default_tab
		FROM maintain_field_template_group WHERE field_template_id = @field_template_id
		
		IF OBJECT_ID('tempdb..#temp_new_group_mapping') IS NOT NULL
			DROP TABLE #temp_new_group_mapping
		
		SELECT mftg.field_group_id, ig.new_group_id, ig.group_name
		INTO #temp_new_group_mapping
		FROM maintain_field_template_group mftg
		INNER JOIN @inserted_group ig ON ig.group_name = mftg.group_name
		WHERE mftg.field_template_id = @field_template_id
		
		INSERT INTO maintain_field_template_detail(field_template_id, field_group_id, field_id, seq_no, is_disable, insert_required, field_caption, default_value, udf_or_system, update_required, hide_control, display_format, value_required, show_in_form, detail_group_id, round_value)
		SELECT @new_field_template_id, tngm.new_group_id, field_id, seq_no, is_disable, insert_required, field_caption, default_value, udf_or_system, update_required, hide_control, display_format, value_required, show_in_form, detail_group_id, round_value
		FROM maintain_field_template_detail mftd
		LEFT JOIN #temp_new_group_mapping tngm ON tngm.field_group_id = mftd.field_group_id
		WHERE field_template_id = @field_template_id
		
		SET @col_id_string = NULL
		SET @select_list = NULL
		SELECT @col_id_string = COALESCE(@col_id_string + N',', N'') + QUOTENAME(c.name),
			   @select_list = COALESCE(@select_list + N',', N'') + IIF(c.name = 'template_name', CAST(@deal_template_id AS VARCHAR(10)), QUOTENAME(c.name))
		FROM dbo.sysobjects o WITH(NOLOCK)
		INNER JOIN dbo.syscolumns c WITH(NOLOCK) ON o.id = c.id AND o.xtype = 'U'
		WHERE (o.name = 'source_deal_header_template') AND c.name <> 'template_id'
		
		IF OBJECT_ID('tempdb..#temp_inserted_sdth_copy') IS NOT NULL
			DROP TABLE #temp_inserted_sdth_copy

		CREATE TABLE #temp_inserted_sdth_copy(template_id INT, org_template_id INT)

		SET @sql = '
			INSERT INTO source_deal_header_template(' + @col_id_string + ')
			OUTPUT INSERTED.template_id, INSERTED.template_name INTO #temp_inserted_sdth_copy
			SELECT ' + @select_list + ' FROM source_deal_header_template WHERE template_id = ' + CAST(@deal_template_id AS VARCHAR(10))
		EXEC(@sql)

		UPDATE sdht
		SET template_name = temp_cnt.new_temp_name
		FROM source_deal_header_template sdht
		INNER JOIN #temp_inserted_sdth_copy ttft
		    ON sdht.template_id = ttft.template_id
		INNER JOIN source_deal_header_template mft_org
		    ON ttft.org_template_id = mft_org.template_id
		CROSS APPLY(
		    SELECT '(' + CAST(COUNT(template_name) + 01 AS VARCHAR(10)) + 
		           ') Copy of ' + mft_org.template_name new_temp_name
		    FROM   source_deal_header_template
		    WHERE  template_name LIKE '(_) Copy of ' + mft_org.template_name
		           OR  template_name LIKE '(__) Copy of ' + mft_org.template_name
		           OR  template_name LIKE '(___) Copy of ' + mft_org.template_name
		) temp_cnt

		SELECT @deal_header_template_id = template_id FROM #temp_inserted_sdth_copy
		-- Update Deal Template with new Deal Field Template
		UPDATE source_deal_header_template SET field_template_id = @new_field_template_id WHERE template_id = @deal_header_template_id
		
		SET @col_id_string = NULL
		SET @select_list = NULL
		SELECT @col_id_string = COALESCE(@col_id_string + N',', N'') + QUOTENAME(c.name),
			   @select_list = COALESCE(@select_list + N',', N'') + IIF(c.name = 'template_id', CAST(@deal_header_template_id AS VARCHAR(10)), QUOTENAME(c.name))
		FROM dbo.sysobjects o WITH(NOLOCK)
		INNER JOIN dbo.syscolumns c WITH(NOLOCK) ON o.id = c.id AND o.xtype = 'U'
		WHERE (o.name = 'source_deal_detail_template') AND c.name <> 'template_detail_id'
		
		SET @sql = '
			INSERT INTO source_deal_detail_template(' + @col_id_string + ')
			SELECT ' + @select_list + ' FROM source_deal_detail_template WHERE template_id = ' + CAST(@deal_template_id AS VARCHAR(10))
		EXEC(@sql)
		
		INSERT INTO [user_defined_deal_fields_template_main](template_id, field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id, book_id, udf_group, udf_tabgroup, formula_id, internal_field_type, currency_field_id, udf_user_field_id, leg, default_value)
		SELECT @deal_header_template_id, field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id, book_id, udf_group, udf_tabgroup, formula_id, internal_field_type, currency_field_id, udf_user_field_id, leg, default_value
		FROM user_defined_deal_fields_template_main WHERE template_id = @deal_template_id

		COMMIT

		EXEC spa_ErrorHandler 0
			,'Source Deal Template'
			,'spa_setup_deal_template'
			,'Success'
			,'Changes have been saved successfully.'
			,''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
			
		EXEC spa_ErrorHandler -1,
			 'Setup Deal Template',
			 'spa_setup_deal_template',
			 'Error',
			 'Failed to save data.',
			 ''
	END CATCH
END
ELSE IF @flag = 'g'
BEGIN
	SELECT @field_template_id = field_template_id FROM source_deal_header_template WHERE template_id = @deal_template_id 

	SELECT *
	INTO #tempDeal
	FROM source_deal_detail_template sddt
	WHERE sddt.template_id = @deal_template_id

	DECLARE @udf_field VARCHAR(5000) = ''
	DECLARE @update_field VARCHAR(5000) = ''

	SELECT @udf_field = @udf_field + ' UDF___' + CAST(udf_template_id AS VARCHAR) + ' VARCHAR(100),'
	FROM maintain_field_template_detail d
	LEFT JOIN user_defined_fields_template udf_temp
		ON d.field_id = udf_temp.udf_template_id
	WHERE udf_or_system = 'u' AND udf_temp.udf_type = 'd' AND d.field_template_id = @field_template_id
 
	--need to confirm : Think not req as UDF columns are not yet added in the temp #tempdeal table
	--SELECT @update_field = @update_field + 'UPDATE #tempdeal SET UDF___' + CAST(udf_user_field_id AS VARCHAR) 
	--       + ' = ' + CASE 
	--                      WHEN (uddft.data_type IN ('int', 'float')) THEN CAST(ISNULL(uddft.default_value, d.default_value) AS VARCHAR)
	--                      WHEN uddft.Field_type = 'a' THEN '''' + CAST(
	--                               dbo.FNADateFormat(ISNULL(uddft.default_value, d.default_value)) AS VARCHAR
	--                           ) + ''''
	--                      ELSE '''' + CAST(ISNULL(uddft.default_value, d.default_value) AS VARCHAR) + ''''
	--                 END
	--       + ' WHERE leg = ' + CAST(uddft.leg AS VARCHAR(10)) + '; '
	--FROM   maintain_field_template_detail d
	--INNER JOIN user_defined_deal_fields_template_main uddft
	--    ON  d.field_id = uddft.udf_user_field_id
	--WHERE  udf_or_system = 'u' AND uddft.udf_type = 'd' AND d.field_template_id = @field_template_id
	--       AND uddft.template_id = @deal_template_id AND ISNULL(uddft.default_value, '') <> ''
 
	IF LEN(@udf_field) > 1
	BEGIN
		SET @udf_field = LEFT(@udf_field, LEN(@udf_field) -1)  

		EXEC('ALTER TABLE #tempDeal add ' + @udf_field) 
	  
		IF NULLIF(@update_field, '') IS NOT NULL
		BEGIN
			EXEC spa_print @update_field   
			EXEC(@update_field)
		END
	END

	SELECT column_name INTO #temp_field_detail FROM INFORMATION_SCHEMA.Columns WHERE TABLE_NAME = 'source_deal_detail_template'   
   
	DECLARE @sql_pre          VARCHAR(MAX),
			@farrms_field_id  VARCHAR(100),
			@default_label    VARCHAR(100)
  
	SET @sql_pre = ''

	DECLARE dealCur CURSOR FORWARD_ONLY READ_ONLY
	FOR
    SELECT ISNULL(farrms_field_id, t.column_name) farrms_field_id, default_label
    FROM (
            SELECT f.farrms_field_id,
                ISNULL(d.field_caption, f.default_label) default_label,
                d.seq_no
            FROM maintain_field_template_detail d
                JOIN maintain_field_deal f
                        ON d.field_id = f.field_id
            WHERE f.header_detail = 'd'
                AND d.field_template_id = @field_template_id
                AND ISNULL(d.udf_or_system, 's') = 's'
            UNION ALL
            SELECT 'UDF___' + CAST(udf_template_id AS VARCHAR),
                ISNULL(d.field_caption, f.Field_label) default_label,
                d.seq_no
            FROM maintain_field_template_detail d
                JOIN user_defined_fields_template f
                        ON d.field_id = f.udf_template_id
            WHERE d.field_template_id = @field_template_id
                AND f.udf_type = 'd'
                AND d.udf_or_system = 'u'
    ) l
    LEFT OUTER JOIN #temp_field_detail t ON  l.farrms_field_id = t.column_name
    WHERE l.farrms_field_id NOT IN ('source_deal_header_id', 'source_deal_detail_id')
    ORDER BY l.seq_no
	
	OPEN dealCur
	FETCH NEXT FROM dealCur INTO @farrms_field_id, @default_label
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @sql_pre = @sql_pre + ' ' + @farrms_field_id + ' AS [' + @default_label + '],'
		FETCH NEXT FROM dealCur INTO @farrms_field_id, @default_label
	END
	CLOSE dealCur
	DEALLOCATE dealCur

	IF LEN(@sql_pre) > 1
	BEGIN
		SET @sql_pre = LEFT(@sql_pre, LEN(@sql_pre) -1)
	END
	
	EXEC spa_print 'SELECT template_detail_id ID, ', @sql_pre, ' FROM #tempDeal'
    
	EXEC('SELECT template_detail_id ID, ' + @sql_pre + ' FROM #tempDeal')
END
ELSE IF @flag = 'u'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	CREATE TABLE #tmp_deal_privileges (
		template_id INT,
		[user_ids] VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		[role_ids] VARCHAR(MAX) COLLATE DATABASE_DEFAULT
	)

	DECLARE @template_ids VARCHAR(MAX)

	BEGIN TRY
		BEGIN TRAN
			INSERT INTO #tmp_deal_privileges (
				template_id,
				[user_ids],
				[role_ids]
			)
			SELECT 
				template_id,
				[user_ids] ,
				[role_ids]
			FROM OPENXML (@idoc, '/Root/GridXML/GridRow', 1)
				 WITH ( 
						template_id INT	'@template_id',
						user_ids  VARCHAR(MAX) '@user',
						role_ids VARCHAR(MAX) '@role'
					)
			--SELECT * FROM  #tmp_deal_privileges
			SELECT @template_ids =  STUFF((
						SELECT ',' + CAST(tdp.template_id AS VARCHAR(10)) 
						FROM #tmp_deal_privileges tdp FOR XML PATH('')
					), 1, 1, '')
					 
			
			DELETE dtp
			--SELECT * 
			FROM deal_template_privilages dtp 
			INNER JOIN dbo.FNASplit(@template_ids, ',') template_ids ON template_ids.item = dtp.deal_template_id
			
			--insert user privileges
			INSERT INTO deal_template_privilages (deal_template_id,[user_id])
			SELECT template_id, user_ids.item
			FROM #tmp_deal_privileges 
			CROSS APPLY dbo.FNASplit(user_ids, ',') user_ids
			
			--insert role privileges
			INSERT INTO deal_template_privilages (deal_template_id,[role_id])
			SELECT template_id, aru.role_id
			FROM #tmp_deal_privileges 
			CROSS APPLY dbo.FNASplit(role_ids, ',') [role_ids]
			INNER JOIN application_security_role aru ON RTRIM(LTRIM(aru.role_name)) =  [role_ids].item 
			
		COMMIT TRAN
		
		EXEC spa_ErrorHandler 0
			, 'Setup Deal Template'
			, 'spa_setup_deal_template'
			, 'Success'
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH
		ROLLBACK
		IF @@ERROR <> 0
			BEGIN 
				EXEC spa_ErrorHandler @@ERROR
					, 'Setup Deal Template'
					, 'spa_setup_deal_template'
					, 'Error'
					, 'Failed to save data.'
					, ''
			END
		RETURN
	END CATCH
END
ELSE IF @flag = 'l'
BEGIN
	SELECT sdht.template_id,
	    sdht.template_name [Template Name],
		STUFF((SELECT ',' + [User_id]
					FROM deal_template_privilages
					WHERE template_id = dtp.deal_template_id
					FOR XML PATH ('')), 1, 1, '') AS [User],
		STUFF((SELECT ',' + CAST([Role_name] AS VARCHAR(100))
					FROM deal_template_privilages role_privilege
					LEFT JOIN application_security_role asr ON  asr.role_id = role_privilege.role_id
					WHERE template_id = dtp.deal_template_id
					FOR XML PATH ('')), 1, 1, '') AS [Role],
		'<a href="javascript:void(0);" onclick="add_edit_privilege()">Edit</a>' [Action]
	FROM source_deal_header_template sdht
	LEFT JOIN deal_template_privilages dtp ON  dtp.deal_template_id = sdht.template_id
	INNER JOIN dbo.FNASplit(@deal_template_id, ',') deal_template_id ON  deal_template_id.item = sdht.template_id
	GROUP BY dtp.deal_template_id, sdht.template_id, sdht.template_name
END