
IF OBJECT_ID(N'[dbo].[spa_create_json_parameters]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_create_json_parameters]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**  
	Different data processing for EPEX Web Service

	Parameters
	@flag				: Unique identifier for different operation
	@rule_id			: ID of import rule
	@data_source_type   : Type of Data source, SSIS or CLR
*/

CREATE PROCEDURE [dbo].[spa_create_json_parameters]
	@flag CHAR(1) = NULL,
	@rule_id INT = NULL,
	@data_source_type INT 
AS

/**
DECLARE @flag CHAR(1), @rule_id INT
SET @flag='f'
SET @rule_id=4921
--*/

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
DECLARE @tab_process_table VARCHAR(300)
DECLARE @form_process_table VARCHAR(300)
DECLARE @grid_name_process_table VARCHAR(300)
DECLARE @process_id VARCHAR(300) = REPLACE(newid(),'-','_')
DECLARE @process_id2 VARCHAR(300) = REPLACE(newid(),'-','_')
DECLARE @process_id3 VARCHAR(300) = REPLACE(newid(),'-','_')
DECLARE @application_group_id INT

IF @flag = 'f'
BEGIN
	SET @tab_process_table = dbo.FNAProcessTableName('tab_process_table', @user_name, @process_id2)
	SET @form_process_table = dbo.FNAProcessTableName('form_process_table', @user_name, @process_id)
	SET @grid_name_process_table = dbo.FNAProcessTableName('grid_name_process_table', @user_name, @process_id3)
	
	SET @sql = '
			SELECT 
				application_group_id,ISNULL(field_layout,''1C'') field_layout,application_grid_id,ISNULL(sequence,1)  sequence, ''n'' is_udf_tab, REPLACE(ag.group_name, ''"'', ''\"'') group_name, ag.default_flag, ''n'' is_new_tab
			INTO '+@tab_process_table+'
			FROM	application_ui_template_group ag 
					INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
			WHERE 
				application_function_id = 10104819 AND at.template_name = ''parameters''
			ORDER BY ag.sequence asc '
	EXEC(@sql)

	SELECT @application_group_id = application_group_id
	FROM application_ui_template_group ag 
	INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
	WHERE application_function_id = 10104819 AND at.template_name = 'parameters'

	IF OBJECT_ID('tempdb..#parameters_process_table_columns') IS NOT NULL
		DROP TABLE #parameters_process_table_columns

	CREATE TABLE #parameters_process_table_columns
	(
		application_field_id varchar(200) COLLATE DATABASE_DEFAULT,
		id INT,
		[type] varchar(200) COLLATE DATABASE_DEFAULT,
		name varchar(200) COLLATE DATABASE_DEFAULT,
		label varchar(200) COLLATE DATABASE_DEFAULT,
		[validate] varchar(200) COLLATE DATABASE_DEFAULT,
		[value] VARCHAR(200) COLLATE DATABASE_DEFAULT,
		default_format varchar(200) COLLATE DATABASE_DEFAULT,
		is_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		field_size varchar(200) COLLATE DATABASE_DEFAULT,
		field_id varchar(200) COLLATE DATABASE_DEFAULT,
		header_detail varchar(200) COLLATE DATABASE_DEFAULT,
		system_required varchar(200) COLLATE DATABASE_DEFAULT,
		[disabled] varchar(200) COLLATE DATABASE_DEFAULT,
		has_round_option varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		update_required varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		data_flag varchar(200) COLLATE DATABASE_DEFAULT,
		insert_required varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		tab_name varchar(200) COLLATE DATABASE_DEFAULT,
		tab_description varchar(200) COLLATE DATABASE_DEFAULT,
		tab_active_flag varchar(200) COLLATE DATABASE_DEFAULT,
		tab_sequence varchar(200) COLLATE DATABASE_DEFAULT,
		sql_string varchar(max) COLLATE DATABASE_DEFAULT,
		fieldset_name varchar(200) COLLATE DATABASE_DEFAULT,
		className varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_is_disable varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_is_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		inputLeft varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		inputTop varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		fieldset_label varchar(200) COLLATE DATABASE_DEFAULT,
		offsetLeft varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		offsetTop varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		fieldset_position varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_width varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_id varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_seq varchar(200) COLLATE DATABASE_DEFAULT,
		blank_option varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'y',
		inputHeight varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 200,
		group_name varchar(200) COLLATE DATABASE_DEFAULT,
		group_id varchar(200) COLLATE DATABASE_DEFAULT,
		application_function_id varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 10104819,
		template_name varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'Parameters',
		position varchar(200) COLLATE DATABASE_DEFAULT,
		num_column varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 3,
		field_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		field_seq VARCHAR(200) COLLATE DATABASE_DEFAULT,
		text_row_num INT, 
		validation_message VARCHAR(200) COLLATE DATABASE_DEFAULT, 
		hyperlink_function VARCHAR(200) COLLATE DATABASE_DEFAULT,
		char_length INT,
		udf_template_id VARCHAR(10) COLLATE DATABASE_DEFAULT,
		dependent_field VARCHAR(200) COLLATE DATABASE_DEFAULT,
		dependent_query VARCHAR(200) COLLATE DATABASE_DEFAULT,
		sequence		INT,
		original_label	VARCHAR(128) COLLATE DATABASE_DEFAULT,
		open_ui_function_id INT
	)

	INSERT INTO #parameters_process_table_columns
	(
		application_field_id,
		id,
		field_id,
		[name],
		label,
		VALUE,
		sql_string,
		validate,
		[type],
		is_hidden,
		field_size,
		header_detail,
		system_required,
		[disabled],
		data_flag,
		tab_name,
		tab_active_flag,
		tab_sequence,
		fieldset_label,
		fieldset_position,
		group_name,
		group_id,
		position,
		field_hidden,
		validation_message,
		field_seq,
		udf_template_id,
		insert_required,
		default_format
	)
	SELECT	ixp_parameters_id AS [application_field_id],
			ROW_NUMBER() over (order by ixp_parameters_id) AS [id], 
			parameter_name AS [field_id], 
			parameter_name AS [name], 
			REPLACE(parameter_label, '"', '\"') AS [label], 
			--CASE WHEN field_type = 'a' 
			--	THEN CASE WHEN default_value = 19400 THEN GETDATE() -- Current day
			--		 WHEN default_value = 19401 THEN DATEADD(DAY, 1, GETDATE()) -- Next Day
			--		 WHEN default_value = 19402 THEN DATEADD(MONTH, 1, GETDATE()) --Next Month
			--		 WHEN default_value = 19407 THEN DATEADD(YEAR, 1, GETDATE()) --Next Year
			--	 ELSE default_value END
			--ELSE default_value END AS [value], 
			REPLACE(default_value, '"', '\"')  AS [value],
			[sql_string] AS [sql_string], 
			NULL AS [validate], 
			field_type AS [type], 
			'n' AS [is_hidden], 
			'150' AS [field_size], 
			'h' AS [header_detail], 
			'n' AS [system_required], 
			'n' AS [disabled], 
			'n' AS [data_flag], 
			'Parameters' as [tab_name], 
			'y' AS [tab_active_flag], 
			'1' AS [tab_sequence], 
			'fieldset' AS [fieldset_lable],
			NULL AS [fieldset_position], 
			'General' AS [group_name], 
			CAST(@application_group_id AS VARCHAR) AS [group_id], 
			'label-top' AS position, 
			'n' AS [field_hidden], 
			isp.validation_message AS [validation_message],
			ROW_NUMBER() over (order by ixp_parameters_id) AS [field_seq],
			'' [udf_template_id]
			,isp.insert_required
			,isp.default_format
	FROM ixp_parameters isp
	INNER JOIN 	ixp_import_data_source iids
		ON IIF(@data_source_type = 21403, ISNULL(iids.ssis_package, -1),ISNULL(iids.clr_function_id, -1)) 
		 = IIF(@data_source_type = 21403,ISNULL(isp.ssis_package, -1), ISNULL(isp.clr_function_id, -1))
	WHERE iids.rules_id = @rule_id

	DECLARE @max INT
	SELECT @max = MAX(id) FROM #parameters_process_table_columns

	INSERT INTO #parameters_process_table_columns
		VALUES (NULL,@max + 1,'settings',NULL,NULL,NULL,NULL,NULL,'n',250,NULL,NULL,NULL,'n','n','n','n','n','Parameters',NULL,'y',1,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10104819,'Parameters','label-top',3,'n',@max, NULL, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL)

	EXEC ('SELECT * INTO ' + @form_process_table + ' FROM #parameters_process_table_columns')

	IF OBJECT_ID('tempdb..#tmp_browser') IS NOT NULL
		DROP TABLE #tmp_browser

	CREATE TABLE #tmp_browser
	(
		farrms_field_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
		grid_name VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #tmp_browser (farrms_field_id, grid_name)
	SELECT parameter_name, grid_name
	FROM  ixp_parameters isp
	INNER JOIN 	ixp_import_data_source iids
		ON IIF(@data_source_type = 21403, ISNULL(iids.ssis_package, -1),ISNULL(iids.clr_function_id, -1)) 
		 = IIF(@data_source_type = 21403,ISNULL(isp.ssis_package, -1), ISNULL(isp.clr_function_id, -1))
	WHERE iids.rules_id = @rule_id AND NULLIF(isp.grid_name, '') IS NOT NULL
	
	DROP TABLE #parameters_process_table_columns
	
	EXEC ('select * into ' + @grid_name_process_table + ' FROM #tmp_browser')

	IF ((SELECT COUNT(*) FROM #tmp_browser) = 0) 
		SET @grid_name_process_table = NULL

	EXEC spa_convert_to_form_json @tab_process_table, @form_process_table, NULL, @grid_name_process_table
END
