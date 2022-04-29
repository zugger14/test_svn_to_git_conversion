IF OBJECT_ID(N'[dbo].[spa_create_application_ui_json]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_create_application_ui_json 
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Generic SP to process data for loading application UI.
 
	Parameters
	@flag : Operation flag
		    'j' - Create application UI json.
		    'f' - Create application UI json for UDFs.
		    'a' - Select template name with permission.
		    'b' - Select dependent query for the field id provided.
		    'l' - Select sql string for the field id provided.
		    'x' - Load combo.
	@application_function_id : 'Application_function_ID defined in application_functions table.
	@template_name : Template_name defined in application_ui_template.
	@parse_xml : XML string of the Data to be inserted/updated.
	@group_name : Group_name in application_ui_template_group.
	@application_field_id : Application_field_ID in application_ui_template_fields
	@dynamic_filter_xml : Filter XML for filter params to be used as table data in spa_convert_to_form_json.
	@debug_mode : Expected: --'1' or --'0'. '1' to print.
	@template_type : Expected --'FORM' --'Filter'.
	@selected_value : Selected value of the combo.
	@is_report : -- 'n' for loading combo from sql_string of application_ui_template_definition table. 
				  'y' for loading combo from param_data_source of data_source_column table whose field id are used in report_param table. 
				  'c' for loading combo from param_data_source of data_source_column table whose fieldid are not in report.
	@parent_value : Value of dependent combo.
	@audit_id : ID of audit tables of template definations(e.g. application_ui_template_audit, application_ui_template_definition_audit).
*/

-- ===========================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2014-01-29
-- EXEC spa_create_application_ui_json 'j','10211200','contract_group',NULL, 'contract'
-- EXEC spa_create_application_ui_json @flag='j', @application_function_id='10221300', @template_name='settlement_history', @group_name='Filters'
-- EXEC spa_create_application_ui_json 'j', '10211200', 'contract_group', '<Root><PSRecordset contract_id="0"></PSRecordset></Root>'
-- EXEC spa_create_application_ui_json 'j', '10103000', 'MeterID', '<Root><PSRecordset meter_id="1422644488917"></PSRecordset></Root>'
-- Parameters:
--	@template_type = 'FORM', 'Filter' 

--===========================================================================================================

CREATE PROCEDURE [dbo].spa_create_application_ui_json 
	@flag		CHAR(1),
	@application_function_id VARCHAR(100) = NULL,
	@template_name VARCHAR(100) = NULL,
	@parse_xml NVARCHAR(MAX) = NULL,
	@group_name VARCHAR(2000) = NULL,
	@application_field_id INT = NULL,
	@dynamic_filter_xml NVARCHAR(2000) = NULL,
	@debug_mode BIT = 0,
	@template_type VARCHAR(8) = 'FORM',
	@selected_value NVARCHAR(100) = NULL,
	@is_report CHAR(1) = 'n',
	@parent_value VARCHAR(10) = NULL,
	@audit_id INT = NULL
	
AS

SET NOCOUNT ON
/**


-- --Test data
IF Object_id('tempdb..#field_values') IS NOT NULL DROP TABLE #field_values
IF Object_id('tempdb..#form_contains') IS NOT NULL DROP TABLE #form_contains
IF Object_id('tempdb..#tab_definitions') IS NOT NULL DROP TABLE #tab_definitions
IF Object_id('tempdb..#tab_grid') IS NOT NULL DROP TABLE #tab_grid


DECLARE @flag		CHAR(1),
	@application_function_id VARCHAR(100),
	@template_name VARCHAR(100) = NULL,
	@parse_xml VARCHAR(MAX) = NULL,
	@group_name VARCHAR(2000) = NULL,
	@application_field_id INT = NULL
SET @flag = 'j'
SET @application_function_id= '10103000'
SET @template_name = 'MeterID'
SET @parse_xml = '<Root><PSRecordset meter_id="210"></PSRecordset></Root>'
--*/



	DECLARE @xml XML
	DECLARE @id INT
	DECLARE @xml_table_name VARCHAR(200)
	DECLARE @sql_join VARCHAR(MAX)
	DECLARE @udf_count INT
	DECLARE @sql VARCHAR(MAX)
	DECLARE @table_name VARCHAR(200)
	DECLARE @field_list VARCHAR(MAX)
	DECLARE @primary_id VARCHAR(50)

	-- Default size
	DECLARE @default_field_size INT
			, @default_column_num_per_row INT
			, @default_offsetleft INT
			, @default_fieldset_offsettop INT
			, @default_filter_field_size INT
			, @default_fieldset_width INT =1000
	
	-- Set Default Values
	SELECT @default_field_size =  var_value 
	FROM adiha_default_codes_values 
	WHERE default_code_id = 86 AND instance_no = 1
		AND seq_no = CASE WHEN @template_type = 'FORM' THEN   1  ELSE  7 END  

	SELECT @default_column_num_per_row =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 4 AND instance_no = 1
	SELECT @default_offsetleft =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 3 AND instance_no = 1
	SELECT @default_fieldset_offsettop =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 5 AND instance_no = 1
	SELECT @default_fieldset_width =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 8 AND instance_no = 1
	

IF @flag = 'j' OR @flag = 'f'
BEGIN
	IF OBJECT_ID('tempdb..#xml_process_table_name') is not null DROP TABLE #xml_process_table_name
	IF OBJECT_ID('tempdb..#process_table') is not null DROP TABLE #process_table
	IF OBJECT_ID('tempdb..#final_sql') is not null DROP TABLE #final_sql
	IF OBJECT_ID('tempdb..#field_values') is not null DROP TABLE #field_values
	
	IF OBJECT_ID('tempdb..#group_names') is not null DROP TABLE #group_names
	
	IF OBJECT_ID('tempdb..#primary_id') is not null DROP TABLE #primary_id
	CREATE TABLE #primary_id (primary_id VARCHAR(50) COLLATE DATABASE_DEFAULT )

	CREATE TABLE #group_names(group_name VARCHAR(300) COLLATE DATABASE_DEFAULT    )
	
	INSERT INTO #group_names(group_name)
	SELECT scsv.item
	FROM dbo.SplitCommaSeperatedValues(@group_name) scsv
	DECLARE @process_id VARCHAR(100)
	DECLARE @tab_process_table VARCHAR(200)
			,@form_process_table VARCHAR(200)
			,@tab_grid_process_table VARCHAR(200)
			,@user_id VARCHAR(100)
			,@form_process_table_final VARCHAR(200)
			,@dynamic_param_table VARCHAR(200)
			, @browser_grid_process_table VARCHAR(200) = NULL
	SET @process_id = REPLACE(newid(),'-','_')
	SET @user_id = dbo.FNADBUser()

	SET @tab_process_table = dbo.FNAProcessTableName('tab', @user_id,@process_id)
	SET @form_process_table =  dbo.FNAProcessTableName('form', @user_id,@process_id)
	SET @tab_grid_process_table = dbo.FNAProcessTableName('tab_grid', @user_id,@process_id)
	SET @form_process_table_final = dbo.FNAProcessTableName('form_final', @user_id,@process_id)
	
	-- Dynamic table names
	DECLARE @template_table VARCHAR(250) = 'application_ui_template',
			@template_definition_table VARCHAR(250) = 'application_ui_template_definition', 
			@template_fields_table VARCHAR(250) = 'application_ui_template_fields', 
			@template_fieldsets_table VARCHAR(250) = 'application_ui_template_fieldsets', 
			@template_group_table VARCHAR(250) = 'application_ui_template_group',
			@template_layout_table VARCHAR(250) = 'application_ui_layout_grid',
			@grid_definition_table VARCHAR(250) = 'adiha_grid_definition',
			@grid_columns_definition_table VARCHAR(250) = 'adiha_grid_columns_definition'
	
	IF @audit_id IS NOT NULL
	BEGIN
		SET @template_table = 'application_ui_template_audit'
		SET @template_definition_table = 'application_ui_template_definition_audit'
		SET @template_fields_table = 'application_ui_template_fields_audit'
		SET @template_fieldsets_table = 'application_ui_template_fieldsets_audit'
		SET @template_group_table = 'application_ui_template_group_audit'
		SET @template_layout_table = 'application_ui_layout_grid_audit'
		SET @grid_definition_table = 'adiha_grid_definition_audit'
		SET @grid_columns_definition_table = 'adiha_grid_columns_definition_audit'
	END

	IF OBJECT_ID('tempdb..#temp_application_ui_template') IS NOT NULL
		DROP TABLE #temp_application_ui_template
	
	CREATE TABLE #temp_application_ui_template(application_ui_template_audit_id INT)
	
	IF OBJECT_ID('tempdb..#temp_ui_fields_original_label') IS NOT NULL
		DROP TABLE #temp_ui_fields_original_label
	
	CREATE TABLE #temp_ui_fields_original_label(application_field_id INT, original_label NVARCHAR(128) COLLATE DATABASE_DEFAULT)
	
	IF @flag = 'f'
	BEGIN
		SET @sql = '
			IF EXISTS(SELECT 1 FROM application_ui_template_audit WHERE application_function_id = ' + @application_function_id + ' AND template_name = ''' + @template_name + ''')
			BEGIN
				INSERT INTO #temp_application_ui_template
				SELECT TOP 1 auta.application_ui_template_audit_id
				FROM application_ui_template_audit auta
				WHERE auta.application_function_id = ' + @application_function_id + '
					 AND auta.template_name = ''' + @template_name + '''
				ORDER BY auta.application_ui_template_audit_id ASC

				INSERT INTO #temp_ui_fields_original_label(application_field_id, original_label)
				SELECT autfa.application_field_id, COALESCE(autda.default_label, autfa.field_alias)
				FROM #temp_application_ui_template taut
				INNER JOIN application_ui_template_definition_audit autda ON autda.application_ui_template_audit_id = taut.application_ui_template_audit_id
				INNER JOIN application_ui_template_fields_audit autfa ON autfa.application_ui_field_id = autda.application_ui_field_id
					AND autfa.application_ui_template_audit_id = taut.application_ui_template_audit_id
			END
		'
		EXEC(@sql)
	END

	SET @sql = '
		SELECT 
			ag.application_group_id,ISNULL(ag.field_layout,''1C'') field_layout,ag.application_grid_id,ISNULL(ag.sequence,1)  sequence, ''n'' is_udf_tab, REPLACE(ag.group_name, ''"'', ''\"'') group_name, ag.default_flag
			, IIF(a.application_ui_template_audit_id IS NOT NULL AND ISNULL(autga.application_group_id, '''') <> ag.application_group_id, ''y'', ''n'') [is_new_tab]
		INTO '+@tab_process_table+'
		FROM	' + @template_group_table + ' ag 
		INNER JOIN ' + @template_table + ' at on at.application_ui_template_id = ag.application_ui_template_id
		OUTER APPLY( SELECT application_ui_template_audit_id FROM #temp_application_ui_template) a
		LEFT JOIN application_ui_template_audit auta ON at.application_function_id = auta.application_function_id AND a.application_ui_template_audit_id = auta.application_ui_template_audit_id
		LEFT JOIN application_ui_template_group_audit autga ON autga.application_ui_template_audit_id = auta.application_ui_template_audit_id
			AND autga.application_group_id = ag.application_group_id
		'
		+ CASE WHEN @group_name IS NOT NULL THEN ' INNER JOIN #group_names gn ON gn.group_name = ag.group_name ' ELSE '' END
		+ ' WHERE at.application_function_id = '+@application_function_id +' AND at.template_name = '''+@template_name+'''  AND ag.active_flag = ''y''
		'
	IF @audit_id IS NOT NULL
		SET @sql += ' AND at.application_ui_template_audit_id = ag.application_ui_template_audit_id AND at.application_ui_template_audit_id = ' + CAST(@audit_id AS VARCHAR(10))	
	SET @sql += 'ORDER BY ag.sequence ASC '
	
	IF @flag = 'f'
	BEGIN
		DECLARE @udf_tab_id INT = @application_function_id
		SET @sql += ' DECLARE @last_seq INT 
					SELECT @last_seq = MAX(sequence) FROM ' + @tab_process_table + '
					INSERT INTO ' + @tab_process_table + ' SELECT ' + CAST(@udf_tab_id AS NVARCHAR(10))+ ', ''1C'', NULL, @last_seq + 1, ''y'' is_udf_tab, ''UDF'', ''n'', ''n''  '
	END

	EXEC(@sql)

	

	SET @sql = '
	SELECT 
		alg.layout_cell, ISNULL(agd.grid_name, alg.grid_id) grid_id, ISNULL(agd.grid_label, alg.grid_id) grid_label  , ag.application_group_id,alg.sequence, alg.cell_height layout_cell_height
	INTO '+@tab_grid_process_table+'
	FROM 
		' + @template_table + ' aut
		INNER JOIN ' + @template_group_table + ' ag ON aut.application_ui_template_id = ag.application_ui_template_id
		INNER JOIN  ' + @template_layout_table + ' alg ON alg.group_id = ag.application_group_id
		LEFT JOIN ' + @grid_definition_table + ' agd ON CAST(agd.grid_id AS VARCHAR(20)) = alg.grid_id'
	IF @audit_id IS NOT NULL
		SET @sql += '	AND aut.application_ui_template_audit_id = agd.application_ui_template_audit_id '
	SET @sql += ' WHERE
		aut.application_function_id = ' + @application_function_id + ' AND ag.active_flag = ''y'''
	IF @audit_id IS NOT NULL
		SET @sql += ' AND aut.application_ui_template_audit_id = ag.application_ui_template_audit_id AND aut.application_ui_template_audit_id = alg.application_ui_template_audit_id AND aut.application_ui_template_audit_id = ' + CAST(@audit_id AS VARCHAR(100))
	EXEC(@sql)

	CREATE TABLE #xml_process_table_name(table_name VARCHAR(200) COLLATE DATABASE_DEFAULT   )

	IF @parse_xml IS NOT NULL AND @parse_xml <> ''
	BEGIN
		INSERT INTO #xml_process_table_name EXEC spa_parse_xml_file 'b', NULL, @parse_xml
		SELECT @xml_table_name = table_name FROM #xml_process_table_name
		EXEC('INSERT INTO #primary_id (primary_id)	SELECT * FROM ' +  @xml_table_name)
		SELECT @primary_id = primary_id FROM #primary_id
	END
	ELSE
	BEGIN 
		SET @primary_id = NULL
	END
	
	
	SELECT 
		@sql_join = ISNULL(@sql_join+' AND ','') + ' CAST(s.' +QUOTENAME(c.name)+' AS NVARCHAR(500))'+' = CAST(f.' +QUOTENAME(c.name)+'  AS NVARCHAR(500))'
	FROM 
			adiha_process.dbo.sysobjects o WITH(NOLOCK)
			INNER JOIN adiha_process.dbo.syscolumns c WITH(NOLOCK) ON o.id = c.id AND o.xtype = 'U'
	WHERE     (o.name = REPLACE(@xml_table_name,'adiha_process.dbo.',''))

	IF ISNULL(@sql_join,'')<>''
		SET @sql_join=' INNER JOIN '+  @xml_table_name+ ' f ON ' +@sql_join
	
	IF OBJECT_ID('tempdb..#temp_udf_count') IS NOT NULL DROP TABLE #temp_udf_count
	CREATE TABLE #temp_udf_count(udf_count INT)
	
	DECLARE @d_sql NVARCHAR(MAX)
	
	SET @d_sql = '
		INSERT INTO #temp_udf_count(udf_count)
		SELECT 
			COUNT(af.udf_template_id)
		FROM
			' + @template_fields_table + ' af
			INNER JOIN ' + @template_group_table + ' ag ON  ag.application_group_id = af.application_group_id
			INNER JOIN ' + @template_table + ' aut ON  aut.application_ui_template_id = ag.application_ui_template_id
			LEFT JOIN ' + @template_definition_table + ' ad	ON  ad.application_ui_field_id = af.application_ui_field_id AND af.application_field_id IS NOT NULL'
	IF @audit_id IS NOT NULL
		SET @d_sql += '	AND aut.application_ui_template_audit_id = ad.application_ui_template_audit_id '
	SET @d_sql += ' LEFT JOIN user_defined_fields_template udf ON  udf.udf_template_id = af.udf_template_id
		WHERE  
			aut.application_function_id = ' + CAST(@application_function_id AS VARCHAR(20)) + ' AND aut.template_name = ''' + @template_name + '''
			AND NULLIF(ad.farrms_field_id, '''') IS NOT NULL
			AND NULLIF(ad.farrms_field_id, '''') IS NOT NULL
	'
	IF @audit_id IS NOT NULL
		SET @d_sql += ' AND aut.application_ui_template_audit_id = ag.application_ui_template_audit_id AND aut.application_ui_template_audit_id = af.application_ui_template_audit_id AND aut.application_ui_template_audit_id = ad.application_ui_template_audit_id AND aut.application_ui_template_audit_id = ' + CAST(@audit_id AS VARCHAR(100))
	EXEC(@d_sql)
	SELECT @udf_count = udf_count FROM #temp_udf_count

	IF @udf_count > 0 
	BEGIN		
		DECLARE @udft_lists_coll VARCHAR(max)
		DECLARE @sql_udf VARCHAR(max)
		DECLARE @udft_lists_table VARCHAR(1000) = dbo.FNAProcessTableName('udft_lists', dbo.FNADBUser(), dbo.FNAGetNewID())
		
		IF OBJECT_ID('tempdb..#temp_udf_col_lists') IS NOT NULL DROP TABLE #temp_udf_col_lists
		CREATE TABLE #temp_udf_col_lists(udft_lists_coll VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
		
		SET @d_sql = '
				INSERT INTO #temp_udf_col_lists(udft_lists_coll)
				SELECT STUFF((SELECT DISTINCT '','' + CAST(autd.field_id AS NVARCHAR(200)) 
									FROM ' + @template_definition_table + ' autd 
									INNER JOIN ' + @template_fields_table + ' autf ON autd.application_ui_field_id = autf.application_ui_field_id
									LEFT JOIN maintain_udf_static_data_detail_values u ON  autf.application_field_id = u.application_field_id
									WHERE application_function_id= ' + CAST(@application_function_id AS VARCHAR(20)) + '
										AND is_udf = ''y'''
		IF @audit_id IS NOT NULL
			SET @d_sql += ' AND autd.application_ui_template_audit_id =' + CAST(@audit_id AS VARCHAR(100)) + ' AND autd.application_ui_template_audit_id = autf.application_ui_template_audit_id'
										--and isnull(primary_field_object_id, @primary_id) = @primary_id
		SET @d_sql += '								FOR XML PATH('''')), 1, 1, '''')'
		
		EXEC(@d_sql)
		SELECT @udft_lists_coll = udft_lists_coll FROM #temp_udf_col_lists

		SET @sql_udf = 'SELECT primary_field_object_id, ' + @udft_lists_coll + '
							INTO ' + @udft_lists_table + ' 
						FROM (
								SELECT u.primary_field_object_id, u.static_data_udf_values static_data_udf_values, autd.field_id 
								FROM ' + @template_definition_table + ' autd 
								INNER JOIN ' + @template_fields_table + ' autf ON autd.application_ui_field_id = autf.application_ui_field_id
								LEFT JOIN maintain_udf_static_data_detail_values u ON  autf.application_field_id = u.application_field_id
								where application_function_id= ' + @application_function_id + '
									and is_udf = ''y'''
		IF @audit_id IS NOT NULL
			SET @sql_udf += ' AND autd.application_ui_template_audit_id =' + CAST(@audit_id AS VARCHAR(100)) + ' AND autd.application_ui_template_audit_id = autf.application_ui_template_audit_id'
		SET @sql_udf += '		and  primary_field_object_id = ' + @primary_id + ') up
						PIVOT (MAX(static_data_udf_values) FOR field_id IN (' + @udft_lists_coll + ')) AS pvt
						ORDER BY primary_field_object_id'
		
		--PRINT @sql_udf
		EXEC(@sql_udf)	
		
		SELECT @sql_join = @sql_join + ' LEFT JOIN ' + @udft_lists_table + ' u on CAST(u.primary_field_object_id AS NVARCHAR(500)) = CAST(f.' +QUOTENAME(c.name)+'  AS NVARCHAR(500))'
		FROM adiha_process.dbo.sysobjects o  WITH(NOLOCK)
		INNER JOIN adiha_process.dbo.syscolumns c WITH(NOLOCK) ON o.id = c.id AND o.xtype = 'U'
		WHERE (o.name = REPLACE(@xml_table_name,'adiha_process.dbo.',''))
	END
				
	IF OBJECT_ID('tempdb..#temp_table_name_field_list') IS NOT NULL DROP TABLE #temp_table_name_field_list
	CREATE TABLE #temp_table_name_field_list(table_name VARCHAR(200) COLLATE DATABASE_DEFAULT, field_list NVARCHAR(MAX) COLLATE DATABASE_DEFAULT)
	
	SET @d_sql = '
		DECLARE @table_name NVARCHAR(200), @field_list NVARCHAR(MAX)
		SELECT @table_name=aut.table_name,@field_list=isnull(@field_list +'',('''''',''('''''') + 
								CASE WHEN ISNULL(af.application_ui_field_id,'''') <>'''' THEN ad.farrms_field_id
								ELSE udf.Field_label 
								END +'''''',''+CASE WHEN ad.data_type = ''float'' OR ad.data_type = ''int'' THEN+'' 
								dbo.FNARemoveTrailingZero(LTRIM(STR('' ELSE''CAST('' END + CASE WHEN ad.data_type = ''numeric'' THEN ''[dbo].[FNARemoveTrailingZeroes]('' ELSE '''' END+ CASE WHEN ISNULL(af.udf_template_id,'''') <>'''' THEN  +''u.''+QUOTENAME(farrms_field_id) 
																			ELSE +''s.''+QUOTENAME(farrms_field_id)
																	END +
							CASE WHEN ad.data_type = ''numeric'' THEN '')'' ELSE ''''  END +CASE WHEN ad.data_type = ''float'' OR ad.data_type = ''int'' THEN '' , 38, 6))))'' ELSE '' AS NVARCHAR(MAX)))'' END
		FROM ' + @template_table + ' aut
		LEFT JOIN ' + @template_definition_table + ' ad on ad.application_function_id = aut.application_function_id
		INNER JOIN ' + @template_fields_table + ' af on af.application_ui_field_id = ad.application_ui_field_id
		INNER JOIN ' + @template_group_table + ' ag on ag.application_group_id = af.application_group_id 
		LEFT JOIN user_defined_fields_template udf on udf.udf_template_id = af.udf_template_id		
		WHERE NULLIF(ad.farrms_field_id,'''') IS NOT NULL
		AND ad.application_function_id = ' + CAST(@application_function_id AS VARCHAR(20)) + ' AND aut.template_name = ''' + @template_name + ''''
	IF @audit_id IS NOT NULL
		SET @d_sql += ' and aut.application_ui_template_audit_id = ad.application_ui_template_audit_id and aut.application_ui_template_audit_id = af.application_ui_template_audit_id AND aut.application_ui_template_audit_id = ag.application_ui_template_audit_id AND aut.application_ui_template_audit_id = ' + CAST(@audit_id AS VARCHAR(10))
	SET @d_sql += ' INSERT INTO #temp_table_name_field_list(table_name, field_list)
		SELECT @table_name, @field_list
	'
		
	EXEC(@d_sql)

	SELECT @table_name = table_name, @field_list = field_list FROM #temp_table_name_field_list
	

	CREATE TABLE #field_values (table_name VARCHAR(200) COLLATE DATABASE_DEFAULT   ,
			field_id NVARCHAR(200) COLLATE DATABASE_DEFAULT   ,
			[field_value] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT   )
	SET @sql='
			INSERT INTO #field_values	
			SELECT DISTINCT '''+@table_name+''' Table_name , x.field_id, [field_value]
			FROM '+ @table_name+' s '+ isnull(@sql_join,'') +'
			CROSS APPLY(
					VALUES 
					'  +   @field_list 
					+'
					) x
			(field_id, [field_value])
			' 
	IF @debug_mode = 1
		EXEC spa_print @sql
		
	EXEC (@sql)
	--	select * from #field_values
	
	SET @sql = '
		SELECT DISTINCT
			af.application_field_id,
			af.application_ui_field_id application_ui_field_id , --ROW_NUMBER() OVER (ORDER BY af.application_ui_field_id) id,
			IIF(ad.data_type = ''float'' OR ad.data_type = ''numeric'', ''numeric'',COALESCE(af.field_type,ad.field_type)) type,
			COALESCE(''udf_'' + CAST(ABS(field_name) AS NVARCHAR(20)),fv.field_id,af.field_id,ad.field_id) name,
			CASE WHEN ad.field_type = ''combo_tag1'' THEN COALESCE(sbmc.group1, udft.field_label, af.field_alias, ad.default_label)
				WHEN ad.field_type = ''combo_tag2'' THEN COALESCE(sbmc.group2, udft.field_label, af.field_alias, ad.default_label)
				WHEN ad.field_type = ''combo_tag3'' THEN COALESCE(sbmc.group3, udft.field_label, af.field_alias, ad.default_label) 
				WHEN ad.field_type = ''combo_tag4'' THEN COALESCE(sbmc.group4, udft.field_label, af.field_alias, ad.default_label) 
				ELSE COALESCE(af.field_alias, ad.default_label, udft.field_label) 
			END label,
			CASE WHEN COALESCE(af.hidden,ad.is_hidden,''n'') <>''y'' THEN 
			CASE
				 WHEN ad.field_type = ''dyn_calendar'' THEN ''ValidDynamicDate''
				 WHEN ad.data_type = ''int'' AND ad.field_type LIKE ''combo%'' AND af.default_format = ''m'' THEN ''''
				 WHEN ad.data_type = ''int'' THEN ''ValidInteger''
				 WHEN ad.data_type = ''float'' THEN ''ValidNumeric''
				 WHEN ad.data_type = ''numeric'' THEN ''ValidNumeric''
				 WHEN ad.data_type = ''email'' THEN ''ValidEmail''		
				WHEN COALESCE(af.validation_flag,insert_required,''n'') =''y'' THEN ''NotEmptywithSpace'' 	
			ELSE 
				'''' END ELSE '''' END
				[validate],
			CASE WHEN fv.field_id IS NOT NULL THEN  COALESCE(CAST(musddv.static_data_udf_values  AS NVARCHAR(MAX)),CAST(fv.field_value AS NVARCHAR(MAX)),CAST(''''  AS NVARCHAR(MAX))) ELSE COALESCE(CAST(af.Default_value  AS NVARCHAR(MAX)),CAST(ad.default_value  AS NVARCHAR(MAX)),CAST(''''  AS NVARCHAR(MAX))) END AS value ,
			af.default_format,
			COALESCE(af.hidden,ad.is_hidden,''n'') is_hidden
			,COALESCE(af.field_size,ad.field_size,' + CAST(@default_field_size AS CHAR(3)) + ') field_size,
			COALESCE(af.field_id,ad.field_id) field_id,
			ad.header_detail,
			ad.system_required,
			ISNULL(ad.is_disable,''n'') as [disabled],
			ad.has_round_option,
			ad.update_required,
			ad.data_flag,
			ad.insert_required,
			ag.group_name tab_name,
			ag.group_description tab_description,
			ag.default_flag tab_active_flag,
			ISNULL(ag.sequence,1) tab_sequence,
			ad.sql_string,
			afs.fieldset_name,
			afs.className,
			afs.is_disable as fieldset_is_disable,
			afs.is_hidden as fieldset_is_hidden,
			ISNULL(afs.inputLeft,0) inputLeft,
			ISNULL(afs.inputTop,0) inputTop,
			ISNULL(afs.label,''fieldset'') as fieldset_label,
			ISNULL(afs.offsetLeft,' + CAST(@default_offsetleft AS CHAR(2)) + ') offsetLeft,
			ISNULL(afs.offsetTop,' + CAST(@default_fieldset_offsettop AS CHAR(2)) + ') offsetTop,
			afs.position fieldset_position,
			ISNULL(afs.width,' + CAST(@default_fieldset_width AS CHAR(4)) + ') fieldset_width,
			afs.application_fieldset_id as fieldset_id,
			afs.sequence as fieldset_seq,
			ISNULL(ad.blank_option,''n'') as blank_option,
			ISNULL(af.inputheight,''200'') as inputHeight,
			ag.group_name,
			ag.application_group_id group_id,
			at.application_function_id,at.template_name,
			CASE WHEN COALESCE(af.field_type,ad.field_type) = ''checkbox'' THEN ''label-right'' ELSE ISNULL(af.position,''label-top'') END position,
			COALESCE(afs.num_column,aulg.num_column,' + CAST(@default_column_num_per_row AS CHAR(3)) + ') num_column,
			ISNULL(hidden,''n'') field_hidden,
			ISNULL(af.sequence, 0) field_seq,
			ad.text_row_num,
			CASE WHEN af.validation_message IS NULL THEN 
				 CASE WHEN ad.field_type = ''dyn_calendar'' THEN ''Invalid Selection''
					  WHEN ad.field_type LIKE ''combo%'' THEN ''Invalid Selection''
					  WHEN ad.data_type = ''int'' THEN ''Invalid Number''
					  WHEN ad.data_type = ''float'' THEN ''Invalid Number''
					  WHEN ad.data_type = ''numeric'' THEN ''Invalid Number''
					  WHEN ad.data_type = ''email'' THEN ''Invalid Email''
					  WHEN COALESCE(af.validation_flag,insert_required,''n'') =''y'' THEN ''Required Field'' 
			END ELSE validation_message END AS validation_message,
			ad.hyperlink_function hyperlink_function,
			ad.char_length,
			af.grid_id,
			agd_gd.grid_name,
			ad.farrms_field_id,
			CASE WHEN ad.is_udf = ''y'' THEN CAST(af.udf_template_id AS NVARCHAR(100)) ELSE '''' END [udf_template_id],
			NULLIF(af.dependent_field, '''') dependent_field,
			NULLIF(af.dependent_query, '''') dependent_query,
			af.sequence,
			tufol.original_label,
			ad.open_ui_function_id
		INTO '+@form_process_table+'
		FROM ' + @template_fields_table + '  af 
		INNER JOIN ' + @template_group_table + ' ag	ON ag.application_group_id = af.application_group_id 
				AND ag.active_flag = ''y''
		LEFT JOIN ' + @template_definition_table + ' ad on ad.application_ui_field_id = af.application_ui_field_id
		INNER JOIN ' + @template_table + ' at on at.application_ui_template_id = ag.application_ui_template_id
		LEFT JOIN ' + @template_fieldsets_table + ' afs ON afs.application_fieldset_id = af.application_fieldset_id'
	IF @audit_id IS NOT NULL
		SET @sql += ' AND at.application_ui_template_audit_id = afs.application_ui_template_audit_id'
	SET @sql += ' LEFT JOIN #temp_ui_fields_original_label tufol ON af.application_field_id = tufol.application_field_id
		LEFT JOIN user_defined_fields_template udft on udft.udf_template_id = af.udf_template_id
		OUTER APPLY source_book_mapping_clm sbmc
		LEFT JOIN #field_values	 fv ON fv.field_id = ad.farrms_field_id
		LEFT JOIN maintain_udf_static_data_detail_values musddv ON musddv.application_field_id = af.application_field_id 
			AND musddv.primary_field_object_id = ' + CASE WHEN @udf_count > 0 THEN @primary_id ELSE ' musddv.primary_field_object_id ' END +
		' LEFT JOIN ' + @template_layout_table + ' aulg ON aulg.group_id = ag.application_group_id AND aulg.grid_id = ''FORM''
		LEFT JOIN ' + @grid_definition_table + ' agd_gd ON CAST(agd_gd.grid_id AS VARCHAR(20)) = af.grid_id OR agd_gd.grid_name = af.grid_id'
		+ CASE WHEN @group_name IS NOT NULL THEN ' INNER JOIN #group_names gn ON gn.group_name = ag.group_name ' ELSE '' END
		+ ' WHERE at.application_function_id = '+@application_function_id +' AND at.template_name = '''+@template_name+''''
	IF @audit_id IS NOT NULL
		SET @sql += ' AND at.application_ui_template_audit_id = '+CAST(@audit_id AS VARCHAR(100))+' 
			AND at.application_ui_template_audit_id = ad.application_ui_template_audit_id 
			AND at.application_ui_template_audit_id = af.application_ui_template_audit_id 
			AND at.application_ui_template_audit_id = ag.application_ui_template_audit_id 
			AND at.application_ui_template_audit_id = aulg.application_ui_template_audit_id'
		-- Added udf fields for UDF tab
		IF @flag = 'f'
		BEGIN
			SET @sql += '
			UNION ALL
			SELECT udft.[field_name],
					  udft.field_name,
					  CASE WHEN udft.Field_type = ''a'' THEN ''calendar''
						   WHEN udft.Field_type = ''d'' THEN ''combo''
						   WHEN udft.Field_type = ''m'' OR udft.Field_type = ''t'' THEN ''input''
						   ELSE ''input''
					  END type,
					  udft.[field_label],
					  udft.[field_label],
					  '''',
					  '''',
					  '''',
					  CASE WHEN sub.udf_template_id IS NULL THEN ''n'' ELSE ''y'' END [is_hidden],
					  udft.[field_size],
					  udft.[field_label],
					  '''',
					  '''',
					  ''n'',
					  ''n'',
					  ''n'',
					  ''n'',
					  ''n'',
					  ''UDF'',
					  NULL,
					  ''y'',
					  1,
					  udft.sql_string [sql_string],
					  NULL [fieldset_name],
					  NULL [className],
					  NULL [fieldset_is_disable],
					  NULL [fieldset_is_hidden],
					  0 [inputLeft],
					  0 [inputTop],
					  ''fieldset'' [fieldset_label],
					  15 [offsetLeft],
					  5 [offsetTop],
					  NULL [fieldset_position],
					  1000 [fieldset_width],
					  NULL [fieldset_id],
					  NULL [fieldset_seq],
					  ''n'' [blank_option],
					  200 [inputHeight],
					  ''UDF'' [group_name],
					  ' + CAST(@udf_tab_id AS VARCHAR(10))+ ' [group_id],
					  NULL [application_function_id],
					  NULL [template_name],
					  NULL [position],
					  NULL [num_column],
					  NULL [field_hidden],
					  NULL [field_seq],
					  NULL [text_row_num],
					  NULL [validation_message],
					  NULL [hyperlink_function],
					  NULL [char_length],
					  NULL,
					  NULL,
					  udft.field_label,
					  CAST(udft.udf_template_id AS VARCHAR(100)) [udf_template_id],
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL
				FROM user_defined_fields_template udft
				LEFT JOIN (
						SELECT autf.udf_template_id 
						FROM ' + @template_fields_table + ' autf
						INNER JOIN ' + @template_definition_table + ' autd ON autd.application_ui_field_id = autf.application_ui_field_id 
						WHERE autd.application_function_id = ' + @application_function_id + ' AND autf.udf_template_id IS NOT NULL'
			IF @audit_id IS NOT NULL
				SET @sql += ' AND autd.application_ui_template_audit_id = '+CAST(@audit_id AS VARCHAR(100))+' AND autd.application_ui_template_audit_id = autf.application_ui_template_audit_id'
			SET @sql += ') sub
						ON udft.udf_template_id = sub.udf_template_id
					WHERE udft.udf_type = ''o''
                        AND udft.is_active = ''y''
			'
			SET @sql += '
			UNION ALL
			SELECT udt.[udt_id],
					  udt.udt_id,
					  ''grid'' type,
					  ''udt_'' + udt.[udt_name],
					  udt.[udt_descriptions],
					  '''',
					  '''',
					  '''',
					  cASE WHEN agd.grid_id IS NOT NULL THEN ''y'' ELSE ''n'' END [is_hidden],
					  230,
					  udt.[udt_descriptions],
					  '''',
					  '''',
					  ''n'',
					  ''n'',
					  ''n'',
					  ''n'',
					  ''n'',
					  ''UDF'',
					  NULL,
					  ''y'',
					  1,
					  NULL [sql_string],
					  NULL [fieldset_name],
					  NULL [className],
					  NULL [fieldset_is_disable],
					  NULL [fieldset_is_hidden],
					  0 [inputLeft],
					  0 [inputTop],
					  ''fieldset'' [fieldset_label],
					  15 [offsetLeft],
					  5 [offsetTop],
					  NULL [fieldset_position],
					  1000 [fieldset_width],
					  NULL [fieldset_id],
					  NULL [fieldset_seq],
					  ''n'' [blank_option],
					  200 [inputHeight],
					  ''UDF'' [group_name],
					  ' + CAST(@udf_tab_id AS VARCHAR(10))+ ' [group_id],
					  NULL [application_function_id],
					  NULL [template_name],
					  NULL [position],
					  NULL [num_column],
					  NULL [field_hidden],
					  NULL [field_seq],
					  NULL [text_row_num],
					  NULL [validation_message],
					  NULL [hyperlink_function],
					  NULL [char_length],
					  NULL,
					  NULL,
					  udt.udt_descriptions,
					  NULL [udf_template_id],
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL
				FROM user_defined_tables udt
				LEFT JOIN adiha_grid_definition agd ON agd.grid_name = ''udt_'' + udt.udt_name
				'
		END

		-- combo_tag% is used to resolve label for fields and is replaced with combo_v2 for dropdown performance enhancement				
		SET @sql = @sql + 'IF EXISTS (select 1 from '+@form_process_table+') BEGIN '+' UPDATE '+@form_process_table+' SET field_seq=-1 WHERE name=''apply_filters''' 
		+ '; UPDATE '+@form_process_table+' SET type= ''combo_v2'' WHERE type like ''combo_tag%'''+' END'
		--+ '  select * from '+@form_process_table
		+ ' SELECT application_field_id, ROW_NUMBER() OVER (ORDER BY application_ui_field_id) id, type,	name, REPLACE(label, ''"'', ''' + IIF(@flag = 'f', '\\\', '\') + '"'') label, validate, REPLACE(value, ''"'', ''' + IIF(@flag = 'f', '\\\', '\') + '"'') value, default_format, is_hidden, field_size,	field_id
					,	header_detail,	system_required,	disabled,	has_round_option,	update_required,	data_flag,	insert_required,	tab_name,	tab_description
					,	tab_active_flag, tab_sequence, ' 
					--replace <ID> field in sql string with main id					
					+ CASE WHEN NULLIF(@primary_id, '') IS NOT NULL THEN 'REPLACE(sql_string, ''<ID>'', ''' + @primary_id + ''') sql_string' ELSE 'sql_string' END 
					+ ', fieldset_name, className, fieldset_is_disable, fieldset_is_hidden, inputLeft
					,	inputTop, fieldset_label, offsetLeft, offsetTop, fieldset_position,	fieldset_width,	fieldset_id, fieldset_seq, blank_option
					,	inputHeight, group_name, group_id, application_function_id,	template_name, position, num_column, field_hidden
					,	field_seq, text_row_num, validation_message, hyperlink_function, char_length, udf_template_id, dependent_field, dependent_query, sequence, original_label, open_ui_function_id
			INTO '+ @form_process_table_final +' FROM '+@form_process_table
		--+ '  select 1 a, * from '+@form_process_table_final
	
	IF @debug_mode = 1
		exec spa_print @sql
	
	EXEC(@sql)

 
	CREATE TABLE #tmp_browser_data
	(
		farrms_field_id VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		grid_name VARCHAR(100) COLLATE DATABASE_DEFAULT 
	)

	--@browser_grid_process_table
	SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @form_process_table + ' WHERE type = ''browser'')
				BEGIN 
					INSERT INTO #tmp_browser_data
					SELECT  farrms_field_id, grid_name FROM ' + @form_process_table + ' WHERE type = ''browser''
				END
				'
	IF @debug_mode = 1
		exec spa_print @sql
	EXEC(@sql)

	IF (SELECT COUNT(1) FROM #tmp_browser_data) > 0
	BEGIN 
		SET @browser_grid_process_table = dbo.FNAProcessTableName('browser', @user_id,@process_id)
		EXEC ('SELECT * INTO ' + @browser_grid_process_table + ' FROM #tmp_browser_data')
	END 
 
	IF @dynamic_filter_xml IS NOT NULL
	BEGIN
		SET @dynamic_param_table = dbo.FNAProcessTableName('dynamic_param', @user_id,@process_id)
		
		SET @sql = '
					DECLARE @idoc INT

					EXEC sp_xml_preparedocument @idoc OUTPUT, ''' +  @dynamic_filter_xml + '''

					SELECT 
						NULLIF(field_id, '''') field_id,
						NULLIF(filter_id, '''') filter_id,
						NULLIF(value, '''') value
					INTO ' + @dynamic_param_table + '
					FROM   OPENXML (@idoc, ''/fields/field/filter'', 2)
					WITH ( 
						field_id	NVARCHAR(200)  ''../@field_id''
						,filter_id	NVARCHAR(200)	 ''@filter_id''
						,value		NVARCHAR(200)	 ''@value''					
					)x

					EXEC sp_xml_removedocument @idoc
			'
		EXEC(@sql)
	END

	DECLARE @call_from VARCHAR(50) = NULL
	IF @flag = 'f'
		SET @call_from = 'DESIGN'
	
	EXEC spa_convert_to_form_json @tab_process_table, @form_process_table_final, @tab_grid_process_table, @browser_grid_process_table, @dynamic_param_table, @call_from
END
ELSE IF @flag = 'a'
BEGIN
	DECLARE @edit_permission       CHAR(1) = 'n',
	        @delete_permission     CHAR(1) = 'n',
	        @edit_function_id VARCHAR(100),
	        @delete_function_id VARCHAR(100),
			@return_template_name VARCHAR(150),
			@primary_field VARCHAR(150)
					
	SELECT @edit_function_id = edit_permission,
	       @delete_function_id = delete_permission
	FROM   application_ui_template
	WHERE  application_function_id = @application_function_id
	
	IF @edit_function_id IS NOT NULL
		SET @edit_permission = dbo.FNACheckPermission(@edit_function_id)
	
	IF @delete_function_id IS NOT NULL
		SET @delete_permission = dbo.FNACheckPermission(@delete_function_id)
	
	SELECT @return_template_name = aut.template_name, @primary_field = autd.field_id
	FROM application_ui_template AS aut 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id = aut.application_ui_template_id
	INNER JOIN application_ui_template_fields autf ON  autf.application_group_id = autg.application_group_id 
	INNER JOIN application_ui_template_definition autd ON autd.application_ui_field_id = autf.application_ui_field_id
	WHERE autd.is_primary = 'y' AND autd.application_function_id = @application_function_id

	SELECT @return_template_name [template_name], ISNULL(NULLIF(@primary_field,''),'blank_field') [primary_field], @edit_permission edit_permission, @delete_permission delete_permission
END
ELSE IF @flag = 'b'
BEGIN
	SELECT autf.dependent_query [dropdown_sql], 
		CASE WHEN autd.blank_option = 'y' THEN 'true' ELSE 'false' END has_blank_option
	FROM   application_ui_template_fields  autf
	INNER JOIN application_ui_template_definition autd
		ON autf.application_ui_field_id = autd.application_ui_field_id
	WHERE  autf.application_field_id = @application_field_id
END
ELSE IF @flag = 'l'
BEGIN
	SELECT autd.sql_string [dropdown_sql], 
		CASE WHEN autd.blank_option = 'y' THEN 'true' ELSE 'false' END has_blank_option
	FROM   application_ui_template_fields  autf
	INNER JOIN application_ui_template_definition autd
		ON autf.application_ui_field_id = autd.application_ui_field_id
	WHERE  autf.application_field_id = @application_field_id
END
ELSE IF @flag = 'x'
BEGIN
	DECLARE @combo_sql_string VARCHAR(5000)
	DECLARE @is_required NCHAR(1) 

	SET @selected_value = NULLIF(@selected_value, '')

	IF @is_report = 'n'
	BEGIN
		SELECT @combo_sql_string = ISNULL(IIF(@parent_value IS NULL AND autf.default_format <> 'm' , NULL, REPLACE (dependent_query, '<' + dependent_field + '>',  ISNULL(@parent_value, '') )), autd.sql_string)
			 , @is_required = ISNULL(autd.blank_option, 'n')
		FROM application_ui_template_fields autf
		INNER JOIN application_ui_template_definition autd ON autd.application_ui_field_id = autf.application_ui_field_id
		WHERE autf.application_field_id = @application_field_id
	END
	ELSE IF @is_report = 'y'
	BEGIN
		SELECT @combo_sql_string = dsc.param_data_source,
			   @is_required = CASE WHEN rpm.optional = 0 THEN 'n' ELSE 'y' END
		FROM report_param rpm
		INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rpm.column_id
		WHERE rpm.report_param_id = @application_field_id
	END
	ELSE IF @is_report = 'c'
	BEGIN
		SELECT @combo_sql_string = dsc.param_data_source,
			   @is_required = 'y'
		from data_source_column dsc 
		WHERE dsc.data_source_column_id = @application_field_id
	END
	IF OBJECT_ID('tempdb..#temp_combo') IS NOT NULL
		DROP TABLE #temp_combo

	CREATE TABLE #temp_combo(
		[value]      NVARCHAR(50) COLLATE DATABASE_DEFAULT ,
		[text]       NVARCHAR(1000) COLLATE DATABASE_DEFAULT ,
		[selected]   NVARCHAR(10) COLLATE DATABASE_DEFAULT ,
		[state]      VARCHAR(10) COLLATE DATABASE_DEFAULT DEFAULT 'enable' 
	)

	IF @is_required = 'y'
	BEGIN
		INSERT INTO #temp_combo([value], [text], [state])
		SELECT '', '', ''
	END

	BEGIN TRY		
		INSERT INTO #temp_combo([value], [text], [state])
		EXEC(@combo_sql_string)
	END TRY
	BEGIN CATCH		
		INSERT INTO #temp_combo([value], [text])
		EXEC(@combo_sql_string)
	END CATCH	

	UPDATE #temp_combo
	SET [selected] = 'true'
	WHERE [value] IN (@selected_value)
	
	IF (@selected_value IS NULL AND @is_required = 'n')
	BEGIN
		UPDATE #temp_combo SET selected = 'true' WHERE value IN (SELECT TOP 1 value FROM #temp_combo)
	END

	SELECT value,
	        [text],
	        [state],
	        ISNULL(selected, 'false') selected,
			ISNULL(selected, 'false') checked
	FROM #temp_combo
END
