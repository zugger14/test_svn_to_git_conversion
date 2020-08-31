IF OBJECT_ID(N'[dbo].[spa_view_report_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_view_report_dhx]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	View report operations. used for preview mode. currently not in use except preview.
	Parameters
	@flag : Flag
	@report_name : Report Name
	@report_id : Report Id
	@report_type : Report Type
	@process_id : Process Id
	@report_param_id : Report Param Id
*/
CREATE PROCEDURE [dbo].[spa_view_report_dhx]
	@flag CHAR(1) = NULL,
	@report_name VARCHAR(200) = NULL,
	@report_id VARCHAR(200) = NULL,
	@report_type INT = NULL,
	@process_id VARCHAR(50) = NULL,
	@report_param_id int = null
AS
/*
declare @flag CHAR(1) = NULL,
	@report_name VARCHAR(200) = NULL,
	@report_id VARCHAR(200) = NULL,
	@report_type INT = NULL,
	@process_id VARCHAR(50) = NULL,
	@report_param_id int = null

	select @flag='c',@report_id='40485',@process_id='0EBA698D_E826_48AA_B184_88809174B5BD',@report_param_id='42841'
--*/
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX), @sqln NVARCHAR(MAX)
DECLARE @is_admin INT
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
DECLARE @tab_process_table VARCHAR(300)
DECLARE @report_process_table VARCHAR(7000)

DECLARE @process_id2 VARCHAR(300) = REPLACE(NEWID(),'-','_')

DECLARE @application_group_id INT
--DECLARE @report_param_id INT
declare @report_page_id INT
DECLARE @max_id INT
DECLARE @items_combined VARCHAR(5000)
DECLARE @column_id VARCHAR(25)
DECLARE @operator VARCHAR(25)
DECLARE @id INT = 1
DECLARE @row_count INT = 0
DECLARE @report_path VARCHAR(250)
DECLARE @paramset_hash VARCHAR(250)

DECLARE @rfx_report VARCHAR(200) = dbo.FNAProcessTableName('report', @user_name, @process_id)
DECLARE @rfx_report_page VARCHAR(200) = dbo.FNAProcessTableName('report_page', @user_name, @process_id)
DECLARE @rfx_report_paramset VARCHAR(200) = dbo.FNAProcessTableName('report_paramset', @user_name, @process_id)
DECLARE @rfx_report_dataset_paramset VARCHAR(200) = dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
DECLARE @rfx_report_param VARCHAR(200) = dbo.FNAProcessTableName('report_param', @user_name, @process_id)
DECLARE @rfx_report_page_tablix VARCHAR(200) = dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
DECLARE @rfx_report_page_chart VARCHAR(200) = dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
DECLARE @rfx_report_page_gauge VARCHAR(200) = dbo.FNAProcessTableName('report_page_gauge', @user_name, @process_id)
DECLARE @process_tbl_browse VARCHAR(200) = dbo.FNAProcessTableName('process_tbl_browse', @user_name, @process_id)


SELECT @is_admin = dbo.FNAIsUserOnAdminGroup(@user_name, 1)


-- Returns the JSON to create the parameter criteria for Custom Report.
IF @flag = 'c'
BEGIN
	
	SET @tab_process_table = dbo.FNAProcessTableName('tab_process_table', @user_name, @process_id2)
	SET @report_process_table = dbo.FNAProcessTableName('report_process_table', @user_name, @process_id)
		
	SET @sql = '
			SELECT 
				application_group_id,ISNULL(field_layout,''1C'') field_layout,application_grid_id,ISNULL(sequence,1)  sequence, ''n'' is_udf_tab, REPLACE(ag.group_name, ''"'', ''\"'') group_name, ag.default_flag, ''n'' is_new_tab
			INTO '+@tab_process_table+'
			FROM	application_ui_template_group ag 
					INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
			WHERE 
				application_function_id = 10202200 AND at.template_name = ''report template''
			ORDER BY ag.sequence asc '
	EXEC(@sql)
	
	SELECT @application_group_id = application_group_id
	FROM application_ui_template_group ag 
	INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
	WHERE application_function_id = 10202200 AND at.template_name = 'report template'
	
	SET @sqln = '
	SELECT @report_page_id = rp.report_page_id
	FROM ' + @rfx_report + ' r 
	INNER JOIN ' + @rfx_report_page + ' rp ON  rp.report_id = r.report_id
	INNER JOIN ' + @rfx_report_paramset + ' rps ON  rps.page_id = rp.report_page_id
	WHERE rps.report_paramset_id = ' + CAST(@report_param_id AS VARCHAR(10))+ '
	'
	EXEC sp_executesql @sqln, N'@report_page_id INT OUTPUT', @report_page_id OUT
	
	--SET @sqln = '
	--SELECT @items_combined = dbo.FNARFXGenerateReportItemsCombinedDhx(MAX(rp.report_page_id), ''' + @process_id + ''')
	--FROM ' + @rfx_report + ' r 
	--INNER JOIN ' + @rfx_report_page + ' rp ON rp.report_id = r.report_id
	--WHERE r.report_id = ' + @report_id + '
	--'
	--EXEC sp_executesql @sqln, N'@items_combined VARCHAR(250) OUTPUT', @items_combined OUT
	SET @sqln = '
	SELECT @items_combined = 
		STUFF(
				( 
					--TODO: For now only space is removed, later all other special characters	 
					SELECT '',ITEM_'' + REPLACE(page_rd.name, '' '', '''') + '':'' + CAST(page_rd.component_id AS VARCHAR(10))
					FROM (
						SELECT rpt.report_page_tablix_id component_id, rpt.name FROM ' + @rfx_report_page_tablix + ' rpt WHERE rpt.page_id = ' + CAST(@report_page_id AS VARCHAR(10))+ '						
						UNION 
						SELECT rpc.report_page_chart_id component_id, rpc.name FROM ' + @rfx_report_page_chart + ' rpc WHERE rpc.page_id  = ' + CAST(@report_page_id AS VARCHAR(10))+ '
						UNION 
						SELECT rpg.report_page_gauge_id component_id, rpg.name FROM ' + @rfx_report_page_gauge + ' rpg WHERE rpg.page_id  = ' + CAST(@report_page_id AS VARCHAR(10))+ '
					) page_rd
					FOR XML PATH(''''), TYPE
				).value(''.[1]'', ''VARCHAR(8000)''), 1, 1, '''') 
	'
	EXEC sp_executesql @sqln, N'@items_combined VARCHAR(8000) OUTPUT', @items_combined OUT

	SET @sqln = '
	SELECT @report_name =  r.[name] + ''_preview''
	FROM ' + @rfx_report + ' r
	INNER JOIN ' + @rfx_report_page + ' rp ON  rp.report_id = r.report_id
	WHERE r.report_id = ' + @report_id + '
	'
	EXEC sp_executesql @sqln, N'@report_name VARCHAR(250) OUTPUT', @report_name OUT

	SET @sqln = '
	SELECT @paramset_hash = rps.paramset_hash
	FROM ' + @rfx_report_paramset + ' rps 
	WHERE rps.report_paramset_id = ' + CAST(@report_param_id AS VARCHAR(10)) +'
	'
	EXEC sp_executesql @sqln, N'@paramset_hash VARCHAR(250) OUTPUT', @paramset_hash OUT

	SET @sqln = '
	SELECT @report_path = r.name
	FROM ' + @rfx_report + ' r 
	INNER JOIN ' + @rfx_report_page + ' rp ON  rp.report_id = r.report_id
	INNER JOIN ' + @rfx_report_paramset + ' rps ON  rps.page_id = rp.report_page_id
	WHERE r.report_id = ' + @report_id + '
	'
	EXEC sp_executesql @sqln, N'@report_path VARCHAR(250) OUTPUT', @report_path OUT

	/* extract default field size properties for form */
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
		AND seq_no = 1

	SELECT @default_column_num_per_row =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 4 AND instance_no = 1
	SELECT @default_offsetleft =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 3 AND instance_no = 1
	SELECT @default_fieldset_offsettop =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 5 AND instance_no = 1
	SELECT @default_fieldset_width =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 8 AND instance_no = 1
	/* extract default field size properties for form */
	

	IF OBJECT_ID('tempdb..#report_criteria') IS NOT NULL
		DROP TABLE #report_criteria
	IF OBJECT_ID('tempdb..#report_criteria_process_table_columns') IS NOT NULL
		DROP TABLE #report_criteria_process_table_columns
	
	CREATE TABLE #report_criteria_process_table_columns
	(
		application_field_id varchar(200) COLLATE DATABASE_DEFAULT ,
		id INT,
		[type] varchar(200) COLLATE DATABASE_DEFAULT,
		name varchar(200) COLLATE DATABASE_DEFAULT,
		label varchar(200) COLLATE DATABASE_DEFAULT,
		[validate] varchar(200) COLLATE DATABASE_DEFAULT,
		[value] VARCHAR(max) COLLATE DATABASE_DEFAULT,
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
		application_function_id varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 10202200,
		template_name varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'report criteria',
		position varchar(200) COLLATE DATABASE_DEFAULT,
		num_column varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 3,
		field_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		field_seq VARCHAR(200) COLLATE DATABASE_DEFAULT,
		text_row_num INT, 
		validation_message VARCHAR(200) COLLATE DATABASE_DEFAULT , 
		hyperlink_function VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		char_length INT,
		udf_template_id VARCHAR(10) COLLATE DATABASE_DEFAULT,
		dependent_field varchar(200) COLLATE DATABASE_DEFAULT,
		dependent_query varchar(200) COLLATE DATABASE_DEFAULT,
		[sequence]		int,
		original_label VARCHAR(128) COLLATE DATABASE_DEFAULT,
		open_ui_function_id INT
	)

	CREATE TABLE #report_criteria
	(
		report_param_id INT,
		column_id INT,
		column_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
		column_alias VARCHAR(200) COLLATE DATABASE_DEFAULT,
		operator VARCHAR(200) COLLATE DATABASE_DEFAULT,
		initial_value VARCHAR(max) COLLATE DATABASE_DEFAULT NULL,
		initial_value2 VARCHAR(max) COLLATE DATABASE_DEFAULT NULL,
		param_data_source VARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
		param_default_value VARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
		optional VARCHAR(2000) COLLATE DATABASE_DEFAULT,
		widget_id INT,
		datatype_id INT,
		source_id INT,
		datatype_name VARCHAR(25) COLLATE DATABASE_DEFAULT ,
		report_paramset_id INT,
		widget_type VARCHAR(25) COLLATE DATABASE_DEFAULT ,
		label VARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,	
		param_order INT,
		data_source_type INT,
		is_hidden VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 'n',
		field_size VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT '150',
		header_detail VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 'h',
		system_required VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 'n',
		[disabled] VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 'n',
		data_flag VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 'n',
		tab_name VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 'Report Criteria',
		tab_active_flag VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 'y',
		tab_sequence VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT '1',
		fieldset_label VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 'fieldset',
		fieldset_position VARCHAR(25) COLLATE DATABASE_DEFAULT ,
		group_name VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 'General',
		group_id VARCHAR(25) COLLATE DATABASE_DEFAULT ,
		position VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 'label-top',
		field_hidden VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 'n',
		field_seq VARCHAR(25) COLLATE DATABASE_DEFAULT  DEFAULT 0
	)

	
	
		
	--EXEC spa_rfx_report_record_dhx @flag='a', @report_paramset_id=@report_param_id, NULL, NULL, NULL, NULL
	DECLARE @rfx_secondary_filters_info VARCHAR(500) = dbo.FNAProcessTableName('rfx_secondary_filters_info', @user_name , @process_id)
	SET @sql = '

	--DUMP ALL COLS GIVING RANK WITH PARTITION OF ALIAS AND NAME
	if object_id(''tempdb..#tmp_ranked_cols'') is not null
		drop table #tmp_ranked_cols

	select * 
	into #tmp_ranked_cols 
	from (
		select 
			row_number() over(partition by COALESCE(rpm.label, dsc.alias, dsc.name)
					order by 
					case dsc.widget_id 
						when 7 then 1 
						when 2 then 2 
						when 6 then 3 
					else 4 end, rpm.param_order asc) drank_ref_alias
			, row_number() over(partition by dsc.name
				order by 
				case dsc.widget_id 
					when 7 then 1 
					when 2 then 2 
					when 6 then 3 
				else 4 end, rpm.param_order asc) drank_ref_name
			, rpm.report_param_id
			, rpm.column_id
			, dsc.name column_name
			, COALESCE(rpm.label, dsc.alias, dsc.name) column_alias
			, rpm.operator
			, rpm.initial_value
			, rpm.initial_value2
			, dsc.param_data_source
			, dsc.param_default_value
			, rpm.optional
			, dsc.widget_id
			, dsc.datatype_id
			, dsc.source_id
			, rdt.name datatype_name
			, rps.report_paramset_id
			, rwt.[name] widget_type
			, rpm.label
			, rpm.param_order
			, ds.type_id data_source_type

		from ' + @rfx_report_param + ' rpm
		inner join ' + @rfx_report_dataset_paramset + ' rdp on rdp.report_dataset_paramset_id = rpm.dataset_paramset_id
		inner join ' + @rfx_report_paramset + ' rps on rps.report_paramset_id = rdp.paramset_id
		inner join data_source_column dsc on dsc.data_source_column_id = rpm.column_id
		inner join report_datatype rdt ON rdt.report_datatype_id = dsc.datatype_id
		inner join report_widget rwt ON rwt.report_widget_id = dsc.widget_id
		inner JOIN data_source ds on ds.data_source_id = dsc.source_id

		where rps.report_paramset_id = ' + CAST(@report_param_id AS VARCHAR(10)) + '
			and rpm.hidden <> 1
		--order by column_alias asc
	) a
	
	--DUMP ONLY SECONDARY COLS THAT ARE EXCLUDED BEING DUPLICATE COLS
	if object_id(''tempdb..#tmp_secondary_cols'') is not null
		drop table #tmp_secondary_cols
	select trc.column_name [col_name]
		, trc.column_alias
		, ca_org_col.column_name [filter_col]
		, null [filter_value]
	into #tmp_secondary_cols
	from #tmp_ranked_cols trc
	cross apply (
		select trc1.column_name
		from #tmp_ranked_cols trc1
		where trc1.column_alias = trc.column_alias and trc1.column_name <> trc.column_name
	) ca_org_col
	where trc.drank_ref_alias > 1 and trc.drank_ref_name = 1
	
	
	if object_id(''' + @rfx_secondary_filters_info + ''') is not null
		drop table ' + @rfx_secondary_filters_info + '

	select * into ' + @rfx_secondary_filters_info + ' 
	from #tmp_secondary_cols
	

	INSERT INTO #report_criteria
	(
		report_param_id,
		column_id,
		column_name,
		column_alias,
		operator,
		initial_value,
		initial_value2,
		param_data_source,
		param_default_value,
		optional,
		widget_id,
		datatype_id,
		source_id,
		datatype_name,
		report_paramset_id,
		widget_type,
		label,
		param_order,
		data_source_type,
		field_seq
	)
	--SELECT DISTINCT 
 --      MAX(rpm.report_param_id) report_param_id,
 --      MAX(rpm.column_id) column_id,
 --      dsc.name column_name,
 --      MAX(COALESCE(rpm.label, dsc.alias, dsc.name)) column_alias, 
 --      MAX(rpm.operator) operator, 
 --      MAX(rpm.initial_value) initial_value,
 --      MAX(rpm.initial_value2) initial_value2,
 --      MAX(dsc.param_data_source) param_data_source,
 --      MAX(dsc.param_default_value) param_default_value,
 --      MIN(rpm.optional + 0) optional, -- + 0 added since MIN function is not allowed for BIT data type.
 --      MAX(dsc.widget_id) widget_id,
 --      MAX(dsc.datatype_id) datatype_id,
 --      MAX(dsc.source_id) source_id,
	--   MAX(rdt.name) datatype_name,
	--   MAX(rps.report_paramset_id) report_paramset_id,
	--   MAX(rwt.[name]) widget_type,
	--   MAX(rpm.label) label, 
	--   MIN(rpm.param_order) param_order
	--   , MAX(ds.type_id) data_source_type
	--   , MIN(rpm.param_order) [field_seq]
	--FROM ' + @rfx_report + ' r 
	--INNER JOIN ' + @rfx_report_page + ' rp ON  rp.report_id = r.report_id
	--INNER JOIN ' + @rfx_report_paramset + ' rps ON  rps.page_id = rp.report_page_id
	--INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.paramset_id = rps.report_paramset_id
	--INNER JOIN ' + @rfx_report_param + ' rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
	--LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rpm.column_id
	--LEFT JOIN report_datatype rdt ON rdt.report_datatype_id = dsc.datatype_id
	--LEFT JOIN report_widget rwt ON rwt.report_widget_id = dsc.widget_id
	--LEFT JOIN data_source ds on ds.data_source_id = dsc.source_id	
	--WHERE rps.report_paramset_id = ' + CAST(@report_param_id AS VARCHAR(10)) + '
	--	AND rpm.hidden <> 1
	--GROUP BY dsc.name
	--ORDER BY param_order

	select trc.report_param_id
			, trc.column_id
			, trc.column_name
			, trc.column_alias
			, trc.operator
			, trc.initial_value
			, trc.initial_value2
			, trc.param_data_source
			, trc.param_default_value
			, isnull(ca_ins_req.optional, trc.optional) optional
			, trc.widget_id
			, trc.datatype_id
			, trc.source_id
			, trc.datatype_name
			, trc.report_paramset_id
			, trc.widget_type
			, trc.label
			, trc.param_order
			, trc.data_source_type
			, trc.param_order
	from #tmp_ranked_cols trc
	outer apply (
		select top 1 trc1.optional
		from #tmp_ranked_cols trc1
		where trc1.label = trc.label 
			and trc1.optional = 0
	) ca_ins_req
	where trc.drank_ref_alias = 1 and trc.drank_ref_name = 1
	'
	EXEC(@sql)

	--select * from #report_criteria
	--return
	
	DECLARE @subbook_id VARCHAR(max)
	SELECT @subbook_id = initial_value FROM #report_criteria 
	WHERE widget_type = 'BSTREE-SubBook'

	UPDATE #report_criteria
	SET initial_value = @subbook_id
	WHERE widget_type = 'BSTREE-Subsidiary'

	DECLARE db_cursor CURSOR FOR  
	SELECT column_id, operator
	FROM #report_criteria
	ORDER BY param_order ASC
	--WHERE operator = '8'

	OPEN db_cursor  
	FETCH NEXT FROM db_cursor INTO @column_id, @operator

	WHILE @@FETCH_STATUS = 0  
	BEGIN
		SET @row_count = @row_count + 1
		INSERT INTO #report_criteria_process_table_columns
		(
			application_field_id,
			id,
			field_id,
			[name],
			label,
			default_format, -- Added this to support checkbox in dropdown
			VALUE,
			sql_string,
			validate,
			--application_function_id,
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
			dependent_field,
			dependent_query,
			[sequence],
			original_label
		)
		SELECT
			report_param_id,
				@row_count,
			CASE
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'book_structure' ELSE column_name
			END 
			column_name,
			CASE
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'book_structure' ELSE column_name
			END 
			column_name,
			REPLACE(CASE
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'Book Structure' ELSE isnull(nullif(column_alias,''),replace(column_name,'_',' '))
			END, '"', '\"') 
			column_alias,
			-- Here 'm' means multiple. Every Combo are multiple checkbox combo.
			CASE
				WHEN widget_type = 'DROPDOWN' THEN 'm' ELSE NULL
			END default_format,
			REPLACE(ISNULL(NULLIF(initial_value,''), initial_value2), '"', '\"'),
			param_data_source,
			CASE
				WHEN optional = '0' THEN 'NotEmpty'
				WHEN optional = '1' THEN ''
			END
			optional,
			--report_paramset_id,
			CASE
				WHEN widget_type = 'DATETIME' THEN 'calendar'
				WHEN widget_type = 'DROPDOWN' THEN 'combo'
				WHEN widget_type = 'TEXTBOX' THEN 'input'
				WHEN widget_type = 'DataBrowser' THEN 'browser'
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'browser'
			END 
			widget_type,
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
			ISNULL(group_id, @application_group_id),
			position,
			field_hidden,
			CASE
				WHEN optional = '0' THEN CASE WHEN widget_type = 'DROPDOWN' THEN 'Invalid Selection' ELSE 'Required Field' END
				WHEN optional = '1' THEN ''
			END,
			field_seq,
			'',
			null,
			null,
			null,
			NULL
		FROM #report_criteria
		WHERE column_id = @column_id

		--select @column_id
		
		IF (@operator = '8')
		BEGIN
			INSERT INTO #report_criteria_process_table_columns
			(
				application_field_id,
				id,
				field_id,
				[name],
				label,
				default_format,
				VALUE,
				sql_string,
				validate,
				--application_function_id,
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
				dependent_field,
				dependent_query,
				[sequence],
				original_label
			)
			SELECT
				rcp.application_field_id,
				rcp.id + 1,
				rcp.field_id,
				'2_' + rcp.[name],
				'and',
				CASE
					WHEN widget_type = 'DROPDOWN' THEN 'm' ELSE NULL
				END default_format,
				REPLACE(ISNULL(NULLIF(rc.initial_value2,''), rc.initial_value), '"', '\"'),
				rcp.sql_string,
				rcp.validate,
				--application_function_id,
				rcp.[type],
				rcp.is_hidden,
				rcp.field_size,
				rcp.header_detail,
				rcp.system_required,
				rcp.[disabled],
				rcp.data_flag,
				rcp.tab_name,
				rcp.tab_active_flag,
				rcp.tab_sequence,
				rcp.fieldset_label,
				rcp.fieldset_position,
				rcp.group_name,
				rcp.group_id,
				rcp.position,
				rcp.field_hidden,
				rcp.validation_message,
				rcp.field_seq,
				'',
				null,
				null,
				null,
				NULL
			FROM #report_criteria_process_table_columns rcp
				CROSS JOIN #report_criteria rc
			WHERE rcp.id = @row_count AND rc.column_id = @column_id

			
			SET @row_count = @row_count + 1
			
		END
		
		SET @id = @id + 1
		
		FETCH NEXT FROM db_cursor INTO @column_id, @operator
	END

	CLOSE db_cursor  
	DEALLOCATE db_cursor
	
	SELECT @max_id = MAX(CAST(id AS INT))
	FROM #report_criteria_process_table_columns
	
	SET @max_id = ISNULL(@max_id, 0)

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+1,'input','report_name','Report Name',NULL,@report_name,NULL,'n',250,'report_name',NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+2,'input','report_paramset_id','Report Paramset ID',NULL,@report_param_id,NULL,'n',250,'report_paramset_id',NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+3,'input','items_combined','Items Combined',NULL,@items_combined,NULL,'n',250,'items_combined',NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+4,'settings',NULL,NULL,NULL,NULL,NULL,'n',250,NULL,NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'n',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+5,'input','paramset_hash','Paramset Hash',NULL,@paramset_hash,NULL,'n',250,'paramset_hash',NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+6,'input','report_path','Report Path',NULL,@report_path,NULL,'n',250,'report_path',NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	--SELECT * FROM #report_criteria_process_table_columns
	--RETURN

	UPDATE #report_criteria_process_table_columns
	SET field_size = @default_field_size,
		offsetLeft = @default_offsetleft,
		offsetTop = @default_fieldset_offsettop,
		fieldset_width = @default_fieldset_width,
		num_column = @default_column_num_per_row

	SET @sql = ' 
	IF OBJECT_ID(''' + @report_process_table + ''') IS NOT NULL 
		DROP TABLE ' + @report_process_table + '
	
	SELECT * INTO ' + @report_process_table + ' FROM #report_criteria_process_table_columns
	'
	exec(@sql)

	IF OBJECT_ID('tempdb..#tmp_browser') IS NOT NULL
		DROP TABLE #tmp_browser

	CREATE TABLE #tmp_browser
	(
		farrms_field_id VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		grid_name VARCHAR(100) COLLATE DATABASE_DEFAULT 
	)

	INSERT INTO #tmp_browser (farrms_field_id, grid_name)
	SELECT rcp.name, dsc.param_data_source
	FROM data_source_column dsc
	inner JOIN #report_criteria rc ON dsc.data_source_column_id = rc.column_id
	inner join #report_criteria_process_table_columns rcp on rcp.application_field_id = rc.report_param_id
	WHERE NULLIF(dsc.param_data_source, '') IS NOT NULL AND dsc.widget_id IN (7,3)
	
	--select * from #report_criteria
	--return

	IF ((SELECT COUNT(*) FROM #tmp_browser) = 0) 
		SET @process_tbl_browse = NULL
	 
	SET @sql = ' 
	IF OBJECT_ID(''' + @process_tbl_browse + ''') IS NOT NULL 
		DROP TABLE ' + @process_tbl_browse + '
	
	SELECT * INTO ' + @process_tbl_browse + ' FROM #tmp_browser
	'
	EXEC(@sql)

	--DROP TABLE #report_criteria_process_table_columns
	--DROP TABLE #report_criteria

	--EXEC ('SELECT * FROM ' + @report_process_table)
	
	--EXEC ('SELECT * FROM ' + @process_tbl_browse)
	--select @tab_process_table, @report_process_table, NULL, @process_tbl_browse
	EXEC spa_convert_to_form_json @tab_process_table, @report_process_table, NULL, @process_tbl_browse, NUll, @is_report = 'y'
	
END

GO
