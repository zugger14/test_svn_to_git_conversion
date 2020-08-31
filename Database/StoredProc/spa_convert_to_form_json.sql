IF OBJECT_ID(N'[dbo].[spa_convert_to_form_json]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].spa_convert_to_form_json

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Converts UI Templates to JSON

	Parameters
	@tab_process_table : Process table with tabbar information
	@form_process_table : Process table with form fields information
	@tab_grid_process_table : Process table with layout/grid/form positioning information
	@browser_grid_process_table : Process table with browser grid information
	@dynamic_filter_table : Filter fields
	@call_from : Flag
				 'mobile' -- Mobile application
				 'DESIGN' -- Form Builder (Internally)
	@is_report : If template is for the report
	@regg_process_id : Regression process id
*/
CREATE PROCEDURE [dbo].spa_convert_to_form_json
	@tab_process_table VARCHAR(500),
	@form_process_table VARCHAR(500),
	@tab_grid_process_table VARCHAR(500),
	@browser_grid_process_table VARCHAR(500) = NULL,
	@dynamic_filter_table VARCHAR(500) = NULL,
	@call_from VARCHAR(20) = NULL,
	@is_report CHAR(1) = 'n',
	@regg_process_id VARCHAR(200) = NULL
AS
SET NOCOUNT ON
/*-----------------Debug Section--------------------

IF OBJECT_ID('tempdb..#field_values') IS NOT NULL
	DROP TABLE #field_values
IF OBJECT_ID('tempdb..#form_contains') IS NOT NULL
	DROP TABLE #form_contains
IF OBJECT_ID('tempdb..#tab_definitions') IS NOT NULL
	DROP TABLE #tab_definitions
IF OBJECT_ID('tempdb..#tab_grid') IS NOT NULL
	DROP TABLE #tab_grid
 
DECLARE @tab_process_table varchar(500) = 'adiha_process.dbo.tab_dev_admin_A6D3C6EB_C548_427D_B359_B51C59A513AD',
		@form_process_table varchar(500) = 'adiha_process.dbo.form_final_dev_admin_A6D3C6EB_C548_427D_B359_B51C59A513AD',
		@tab_grid_process_table varchar(500) = 'adiha_process.dbo.tab_grid_dev_admin_A6D3C6EB_C548_427D_B359_B51C59A513AD',
		@browser_grid_process_table varchar(500) = 'adiha_process.dbo.browser_dev_admin_A6D3C6EB_C548_427D_B359_B51C59A513AD',
		@dynamic_filter_table VARCHAR(500) = NULL,
		@call_from VARCHAR(20) = NULL,
		@is_report CHAR(1) = 'n',
		@regg_process_id VARCHAR(200) = NULL
-------------------------------------------------------*/

SET @is_report = ISNULL(NULLIF(@is_report, ''), 'n')

DECLARE @default_offsetleft INT
DECLARE @default_blockoffset INT
DECLARE @default_checkbox_offsettop INT
DECLARE @default_browse_clear_offsettop INT
DECLARE @default_browse_clear_offsetleft INT

DECLARE @tab_xml xml
DECLARE @tab_grid nvarchar(max)
DECLARE @tab nvarchar(max)
DECLARE @tab_name varchar(50)
DECLARE @setting_xml xml
DECLARE @setting varchar(max)
DECLARE @type varchar(50)
DECLARE @name nvarchar(500)
DECLARE @label nvarchar(500)
DECLARE @is_hidden char(1)
DECLARE @is_header char(1)
DECLARE @sql_string nvarchar(max)
DECLARE @xml_string varchar(max)
DECLARE @field_string nvarchar(max)
	
DECLARE @param nvarchar(100)
DECLARE @json_combo_value nvarchar(max)
DECLARE @json_radio nvarchar(max)
DECLARE @json_block nvarchar(max)
DECLARE @xml xml
DECLARE @id int
DECLARE @application_field_id int
	
DECLARE @fieldset varchar(50)
DECLARE @json_field_block varchar(max)
DECLARE @count_fieldset int
DECLARE @block nvarchar(max)
DECLARE @blank_option char(1)
DECLARE @group_id varchar(100)
DECLARE @tab_block varchar(max) = ''
DECLARE @sql nvarchar(max)
DECLARE @table_name varchar(200)
DECLARE @sql_join varchar(max)
DECLARE @field_list varchar(max)
DECLARE @default_format varchar(1000),
	    @field_size int
	
DECLARE @field_xml varchar(max) = ''
DECLARE @fieldset_id int
DECLARE @fieldset_name varchar(max)
DECLARE @value varchar(100)
DECLARE @num_column int = 0
DECLARE @layout varchar(100)
DECLARE @grid_id nvarchar(max)
DECLARE @tab_id int
DECLARE @manage_sequence int
DECLARE @fieldset_label varchar(200)
DECLARE @fieldset_seq int
DECLARE @row_number int
DECLARE @field_json nvarchar(max)
DECLARE @block_json nvarchar(max)
DECLARE @fieldset_json nvarchar(max)
DECLARE @offset_left varchar(100)
DECLARE @offset_top varchar(100)
DECLARE @input_left varchar(100)
DECLARE @input_top varchar(100)
DECLARE @fieldset_width varchar(100)
DECLARE @fieldset_position varchar(100)
DECLARE @position varchar(100)
DECLARE @group_name varchar(100)
DECLARE @upload_json VARCHAR(5000)
DECLARE @text_row_num varchar(100)
DECLARE @time_part VARCHAR(15)
DECLARE @is_dependent BIT;
DECLARE @is_udf_tab CHAR(1),
		@is_new_tab CHAR(1)
DECLARE @is_required VARCHAR(10)

SET @is_dependent = 0;	
DECLARE @is_book varchar(100)
DECLARE @grid_name varchar(100)
DECLARE @grid_label varchar(100)
DECLARE @enable_single_select CHAR(1)

DECLARE @parent_value VARCHAR(10)

DECLARE @unique_id VARCHAR(1000)
DECLARE @user_login_id VARCHAR(200) = dbo.FNADBUser()
SET @xml_string = ''
SET @json_field_block = ''

-- Set Default Values
SELECT @default_blockoffset =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 2 AND instance_no = 1
SELECT @default_offsetleft =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 3 AND instance_no = 1
SELECT @default_checkbox_offsettop =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 6 AND instance_no = 1
SELECT @default_browse_clear_offsettop =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 9 AND instance_no = 1
SELECT @default_browse_clear_offsetleft =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 10 AND instance_no = 1

IF OBJECT_ID('tempdb..#store_result') IS NOT NULL
	DROP TABLE #store_result
IF OBJECT_ID('tempdb..#dependent_combo') IS NOT NULL
	DROP TABLE #dependent_combo
    
CREATE TABLE #dependent_combo(
	tab_id VARCHAR(20) COLLATE DATABASE_DEFAULT,
	dependent_combo VARCHAR(max) COLLATE DATABASE_DEFAULT
)
  
CREATE TABLE #store_result (
	tab_id             VARCHAR(20) COLLATE DATABASE_DEFAULT,
	tab_json           nvarchar(max) COLLATE DATABASE_DEFAULT ,
	form_json          nvarchar(max) COLLATE DATABASE_DEFAULT ,
	layout_pattern     varchar(10) COLLATE DATABASE_DEFAULT ,
	grid_json          varchar(8000) COLLATE DATABASE_DEFAULT ,
	seq                int,
	filter_status      char(1) COLLATE DATABASE_DEFAULT 
)
  
IF OBJECT_ID('tempdb..#tab_grid') IS NOT NULL
	DROP TABLE #tab_grid
  
IF OBJECT_ID('tempdb..#tab_definitions') IS NOT NULL
	DROP TABLE #tab_definitions
  
IF OBJECT_ID('tempdb..#form_contains') IS NOT NULL
	DROP TABLE #form_contains
  
CREATE TABLE #tab_definitions (
application_group_id     int,
field_layout             varchar(100) COLLATE DATABASE_DEFAULT ,
application_grid_id      int,
sequence                 int,
is_udf_tab				 CHAR(1) COLLATE DATABASE_DEFAULT,
group_name				 VARCHAR(100) COLLATE DATABASE_DEFAULT,
default_flag             CHAR(1) COLLATE DATABASE_DEFAULT,
is_new_tab				 CHAR(1) COLLATE DATABASE_DEFAULT
)

IF @tab_process_table IS NOT NULL
	EXEC ('INSERT INTO #tab_definitions SELECT application_group_id,field_layout,application_grid_id,sequence, is_udf_tab, group_name, default_flag, is_new_tab FROM ' + @tab_process_table)

CREATE TABLE #tab_grid (
	layout_cell     varchar(10) COLLATE DATABASE_DEFAULT ,
	grid_id         varchar(500) COLLATE DATABASE_DEFAULT ,
	grid_label      varchar(500) COLLATE DATABASE_DEFAULT ,
	group_id        int,
	sequence        int,
	layout_cell_height int
)

IF @tab_grid_process_table IS NOT NULL
	EXEC ('INSERT INTO #tab_grid SELECT layout_cell,grid_id,grid_label,application_group_id,sequence,layout_cell_height FROM ' + @tab_grid_process_table)

CREATE TABLE #form_contains (
	[application_field_id]        int,
	[id]                          int,
	[type]                        varchar(100) COLLATE DATABASE_DEFAULT ,
	[name]                        varchar(100) COLLATE DATABASE_DEFAULT ,
	[label]                       nvarchar(100) COLLATE DATABASE_DEFAULT ,
	[validate]                    varchar(50) COLLATE DATABASE_DEFAULT ,
	[value]                       nvarchar(max) COLLATE DATABASE_DEFAULT ,
	[default_format]              varchar(200) COLLATE DATABASE_DEFAULT ,
	[is_hidden]                   char(1) COLLATE DATABASE_DEFAULT ,
	[field_size]                  varchar(200) COLLATE DATABASE_DEFAULT ,
	[field_id]                    varchar(200) COLLATE DATABASE_DEFAULT ,
	[header_detail]               char(1) COLLATE DATABASE_DEFAULT ,
	[system_required]             char(1) COLLATE DATABASE_DEFAULT ,
	[disabled]                    char(1) COLLATE DATABASE_DEFAULT ,
	[has_round_option]            char(1) COLLATE DATABASE_DEFAULT ,
	[update_required]             char(1) COLLATE DATABASE_DEFAULT ,
	[data_flag]                   char(1) COLLATE DATABASE_DEFAULT ,
	[insert_required]             char(1) COLLATE DATABASE_DEFAULT ,
	[tab_name]                    varchar(100) COLLATE DATABASE_DEFAULT ,
	[tab_description]             varchar(200) COLLATE DATABASE_DEFAULT ,
	[tab_active_flag]             char(1) COLLATE DATABASE_DEFAULT ,
	[tab_sequence]                int,
	[sql_string]                  nvarchar(max) COLLATE DATABASE_DEFAULT ,
	[fieldset_name]               varchar(50) COLLATE DATABASE_DEFAULT ,
	[className]                   varchar(50) COLLATE DATABASE_DEFAULT ,
	[fieldset_is_disable]         char(1) COLLATE DATABASE_DEFAULT ,
	[fieldset_is_hidden]          char(1) COLLATE DATABASE_DEFAULT ,
	[inputLeft]                   int,
	[inputTop]                    int,
	[fieldset_label]              char(100) COLLATE DATABASE_DEFAULT ,
	[offsetLeft]                  int,
	[offsetTop]                   int,
	[fieldset_position]           varchar(50) COLLATE DATABASE_DEFAULT ,
	[fieldset_width]              int,
	[fieldset_id]                 int,
	[fieldset_seq]                int,
	[blank_option]                char(1) COLLATE DATABASE_DEFAULT ,
	[inputHeight]                 int,
	[group_name]                  varchar(200) COLLATE DATABASE_DEFAULT ,
	[group_id]                    int,
	[application_function_id]     int,
	[template_name]               varchar(100) COLLATE DATABASE_DEFAULT ,
	[position]                    varchar(50) COLLATE DATABASE_DEFAULT ,
	[num_column]                  int,
	[field_hidden]                char(1) COLLATE DATABASE_DEFAULT ,
	[field_seq]                   int,
	[text_row_num]				  INT,
	[validation_message]		  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	[hyperlink_function]		  VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	[char_length]				  INT,
	[udf_template_id]			  VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[dependent_field]			  VARCHAR(200) COLLATE DATABASE_DEFAULT,
	[dependent_query]			  NVARCHAR(200) COLLATE DATABASE_DEFAULT,
	[sequence]					  INT,
	[original_label]			  NVARCHAR(128) COLLATE DATABASE_DEFAULT,
	[open_ui_function_id]		  INT
)


IF @form_process_table IS NOT NULL
BEGIN

	IF @dynamic_filter_table IS NOT NULL
	BEGIN
		SET @sql = '
					DECLARE @field_id VARCHAR(100), @filter_id VARCHAR(100), @value VARCHAR(MAX)
					
					DECLARE db_cursor CURSOR FOR  
					SELECT d.field_id, d.filter_id, d.value
					FROM ' + @form_process_table + ' f
						INNER JOIN ' + @dynamic_filter_table + ' d
							ON f.name = d.field_id
					OPEN db_cursor   
					FETCH NEXT FROM db_cursor INTO @field_id, @filter_id, @value

					WHILE @@FETCH_STATUS = 0   
					BEGIN   
						UPDATE  ' + @form_process_table + ' 
							SET sql_string = REPLACE(sql_string, ''<'' + @filter_id + ''>'', @value)
						WHERE name = @field_id
		

						FETCH NEXT FROM db_cursor INTO @field_id, @filter_id, @value
					END   

					CLOSE db_cursor   
					DEALLOCATE db_cursor'

			--print @sql;
			EXEC(@sql)
	END

	EXEC ('INSERT INTO #form_contains
	       SELECT [application_field_id],
	              [id],
	              [type],
	              [name],
	              [label],
	              [validate],
	              [value],
	              [default_format],
	              [is_hidden],
	              [field_size],
	              [field_id],
	              [header_detail],
	              [system_required],
	              [disabled],
	              [has_round_option],
	              [update_required],
	              [data_flag],
	              [insert_required],
	              [tab_name],
	              [tab_description],
	              [tab_active_flag],
	              [tab_sequence],
	              [sql_string],
	              [fieldset_name],
	              [className],
	              [fieldset_is_disable],
	              [fieldset_is_hidden],
	              [inputLeft],
	              [inputTop],
	              [fieldset_label],
	              [offsetLeft],
	              [offsetTop],
	              [fieldset_position],
	              [fieldset_width],
	              [fieldset_id],
	              [fieldset_seq],
	              [blank_option],
	              [inputHeight],
	              [group_name],
	              [group_id],
	              [application_function_id],
	              [template_name],
	              [position],
	              [num_column],
	              [field_hidden],
	              [field_seq],
				  [text_row_num],
				  [validation_message],
				  [hyperlink_function],
				  [char_length],
				  [udf_template_id],
				  [dependent_field],
				  [dependent_query],
				  [sequence],
				  [original_label],
				  [open_ui_function_id]
	       FROM   ' + @form_process_table + ' WHERE [type] <> ''browser_label''' 
	) 
	
	--exec('select * from ' + @form_process_table)
END



--select a.id
--	, a.type field_type
--	,  a.field_id
--	, a.name farrms_field_id
--	, a.label field_label
--	, CASE 
--		WHEN a.field_id = 'source_minor_location_id' THEN 'source_minor_location'
--		WHEN a.field_id = 'contract_id' THEN 'contract_group'
--		WHEN a.field_id = 'source_counterparty_id' THEN 'source_counterparty'
--	  ELSE '' 
--	  END phy_table
--	, a.value field_value 
--from #form_contains a
--inner join application_ui_template_fields autf ON autf.application_field_id = a.application_field_id
--where a.type = 'browser' and autf.grid_id <> 'book'
/* special case handled for book structure */

DECLARE @call_from_design VARCHAR(10) = 'DESIGN' --Form Builder

IF ISNULL(@call_from, '') <> @call_from_design
BEGIN
	-----------------------------START evalute default date value-----------
	IF OBJECT_ID('tempdb..#evaluate_date_value') IS NOT NULL
		DROP TABLE #evaluate_date_value

	SELECT application_field_id, value 
	INTO #evaluate_date_value 
	FROM #form_contains WHERE [type] = 'calendar' and CHARINDEX('(', value) > 0 and CHARINDEX(')', value) > 0

	--select * from #evaluate_date_value

	DECLARE @date varchar(200), @update_application_field_id VARCHAR(10) 
	DECLARE @update_value CURSOR
	SET @update_value = CURSOR FOR
		SELECT application_field_id, value
		FROM #evaluate_date_value
	OPEN @update_value
	FETCH NEXT
	FROM @update_value INTO @update_application_field_id, @date
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC ('
		DECLARE @evaluated_date VARCHAR(20)
		SELECT @evaluated_date = ' + @date + '
		UPDATE #evaluate_date_value SET value = dbo.FNAGetSQLStandardDate(@evaluated_date) WHERE application_field_id = ' +  @update_application_field_id ) 
		FETCH NEXT
		FROM @update_value INTO @update_application_field_id, @date
	END

	CLOSE @update_value
	DEALLOCATE @update_value

	--select * from #evaluate_date_value 

	UPDATE fc SET fc.value = edv.value FROM 
	#form_contains fc INNER JOIN  #evaluate_date_value edv ON edv.application_field_id = fc.application_field_id

	-----------------------------END evalute default date value-----------

	declare @field_id varchar(50)
		, @field_value varchar(max) 
		, @book_structure varchar(max)   = ''
		, @subsidiary_id varchar(max)  = ''
		, @strategy_id varchar(max)   = ''
		, @book_id varchar(max)  = ''
		, @subbook_id varchar(max)  = ''
		
	select @field_id = a.field_id, @field_value = a.value 
	--select *
	from #form_contains a --inner join data_source_column dsc on dsc.data_source_column_id=a.application_field_id
	LEFT join application_ui_template_fields autf ON autf.application_field_id = a.application_field_id
	where a.type = 'browser' and (autf.grid_id = 'book' OR autf.grid_id IS NULL or @is_report in ('y','c')) and a.field_id in ('book_structure', 'book_id', 'subbook_id') 

	--select @field_id, @field_value
	--return

	IF @field_id = 'book_id'
	BEGIN
		select @book_structure = sub.entity_name + '|' + stra.entity_name + '|' + book.entity_name + '|NULL' 
			, @subsidiary_id = sub.entity_id
			, @strategy_id = stra.entity_id
			, @book_id = book.entity_id
		FROM portfolio_hierarchy book
		INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
		WHERE book.entity_id = @field_value AND book.hierarchy_level = 0	
	END
	ELSE if @field_id = 'subbook_id' OR @field_id = 'book_structure'
	BEGIN
		/*
		select @book_structure = sub.entity_name + '|' + stra.entity_name + '|' + book.entity_name + '|' + ssbm.logical_name 
			, @subsidiary_id = sub.entity_id
			, @strategy_id = stra.entity_id
			, @book_id = book.entity_id
			, @subbook_id = ssbm.book_deal_type_map_id
			--select *
		FROM source_system_book_map ssbm
		INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id AND book.hierarchy_level = 0
		INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
		--where ssbm.book_deal_type_map_id= ''
		WHERE ssbm.book_deal_type_map_id = @field_value
		--*/
		
		--logic rebuild when multiple sub book id is selected (field_value = 281,282)
		--/*
		if OBJECT_ID('tempdb..#tmp_book_str') is not null drop table #tmp_book_str
		select  subsidiary_id = sub.entity_id
				, strategy_id = stra.entity_id
				, book_id = book.entity_id
				, subbook_id = ssbm.book_deal_type_map_id
				, subsidiary = sub.entity_name, strategy = stra.entity_name, book = book.entity_name, logical_name = ssbm.logical_name
		into #tmp_book_str --select * from #tmp_book_str
		--select *
		FROM source_system_book_map ssbm
			INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id AND book.hierarchy_level = 0
			INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
			INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
			INNER JOIN dbo.SplitCommaSeperatedValues(REPLACE(@field_value, '!', ',')) scsv on scsv.item = ssbm.book_deal_type_map_id -- replace to support reports param for pivot feature
			
		select @subsidiary_id = isnull(subsidiary_id.subsidiary_id, '')
			, @strategy_id = isnull(strategy_id.strategy_id, '')
			, @book_id = isnull(book_id.book_id, '')
			, @subbook_id = isnull(sub_book_id.sub_book_id, '')
			, @book_structure = isnull(subsidiary.subsidiary + '|' + strategy.strategy + '|' + book.book + '|' + logical_name.logical_name, '')
		from (
		SELECT STUFF(
			(SELECT distinct ','  + cast(m.subsidiary_id AS varchar(100))
			from #tmp_book_str m
			FOR XML PATH(''))
		, 1, 1, '') subsidiary_id
		) subsidiary_id
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + cast(m.strategy_id AS varchar(100))
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') strategy_id
		) strategy_id
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + cast(m.book_id AS varchar(100))
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') book_id
		) book_id
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + cast(m.subbook_id AS varchar(100))
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') sub_book_id
		) sub_book_id
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + m.subsidiary
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') subsidiary
		) subsidiary
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + strategy
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') strategy
		) strategy
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + m.book
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') book
		) book
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + m.logical_name
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') logical_name
		) logical_name
		--*/
	END
END
--select @book_structure value for xml path('')
--return
--select * from #form_contains

DECLARE @dependemt_combos nvarchar(max)
DECLARE @filter_status char(1)
DECLARE @first_tab_seq_no INT
-- To handle active tab where form is generated using certain group names only , e.g. Setup Counterparty
SELECT @first_tab_seq_no = MIN([sequence])
FROM #tab_definitions

SET @param = N'@xml XML OUTPUT';

DECLARE tab_cursor CURSOR FOR
SELECT application_group_id,
	    field_layout,
	    application_grid_id,
	    sequence,
	    is_udf_tab,
		is_new_tab
FROM #tab_definitions

-- tab cursor
OPEN tab_cursor
FETCH NEXT FROM tab_cursor
INTO @tab_id, @layout, @grid_id, @manage_sequence, @is_udf_tab, @is_new_tab
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @table_name = ''
	SET @field_list = NULL
	SET @sql_join = NULL
	SET @tab_block = ''
	SET @setting_xml = ''
	SET @setting = ''
	SET @dependemt_combos = NULL
	SET @filter_status = 'n'
	
	--DECLARE @dependemt_combos VARCHAR(100)
	SELECT @dependemt_combos = ISNULL(@dependemt_combos + '~', '') + 
								autf.dependent_field + '->' + 
								fc.name + '->' + 
								ISNULL(fc_p.default_format, '') + '->' + 
								ISNULL(fc.value, '') + '->' + 
								ISNULL(fc.default_format, '') + '->' + 
								ISNULL(CAST(autf.load_child_without_parent AS VARCHAR(1)), '0')
	FROM   #form_contains fc
		INNER JOIN application_ui_template_fields autf 
			ON  autf.application_field_id = fc.application_field_id
		INNER JOIN #form_contains fc_p
			ON autf.dependent_field = fc_p.field_id 
	WHERE  autf.dependent_field IS NOT NULL
		    AND autf.dependent_query IS NOT NULL
		    AND fc.group_id = @tab_id
	ORDER BY autf.sequence

	INSERT INTO #dependent_combo (tab_id,dependent_combo)
	SELECT CAST(@tab_id AS VARCHAR(20)) + IIF(@call_from = @call_from_design, '_' + CAST(@is_new_tab AS VARCHAR(1)), ''), @dependemt_combos

	DECLARE @count_value int = 0

	
	-- GENERATE TABs JSON 
	SET @tab_xml = ''
	--## For form builder add UDF tab
	--## A character y/n is added with _ (underscore) in group id (tab id)
	--## To later use to know if a tab can be deleted/renamed or not only in form builder
	IF @call_from = @call_from_design AND @is_udf_tab = 'y'
	BEGIN
		SET @tab_xml = (
				SELECT 'detail_tab_' + CAST(@tab_id AS VARCHAR(20)) + '_n'
						[id],
						'UDF' [text],
						'n' [active]
				FOR XML RAW('tab'), ROOT('root'), ELEMENTS
			)
	END
	ELSE
	BEGIN
		SET @tab_xml = (
			    SELECT 'detail_tab_' + CAST(application_group_id AS VARCHAR(20)) + IIF(@call_from = @call_from_design, '_' + CAST(@is_new_tab AS VARCHAR(20)), '')
			            [id],
			            IIF(@call_from = @call_from_design, group_name, dbo.FNAGetLocaleValue(group_name)) [text],
			            CASE WHEN ag.default_flag = 'y' OR ag.[sequence] = 1 OR ag.[sequence] = @first_tab_seq_no THEN 'true'
							ELSE 'false'
						END [active]
			    FROM #tab_definitions ag
			    WHERE ag.application_group_id = @tab_id
			    ORDER BY ag.sequence
			    FOR XML RAW('tab'), ROOT('root'), ELEMENTS
			)
	END

	SELECT @tab = dbo.FNAFlattenedJSON(@tab_xml)
	SET @setting_xml = (
			SELECT [type],
					position
			FROM   #form_contains
			WHERE  type = 'settings'
					AND group_id = @tab_id
			FOR xml RAW('tab'), ROOT('root'), ELEMENTS
		)
	
	SELECT @setting = dbo.FNAFlattenedJSON(@setting_xml)	
	SET @fieldset_json = ''
	DECLARE @field_seq INT
	DECLARE @to_resolve_value VARCHAR(max)
	DECLARE fieldset_cursor CURSOR  
	FOR
		SELECT DISTINCT
				ISNULL(fieldset_id, -1),
				fieldset_name,
				fieldset_label,
				fieldset_seq,
				num_column,
				offsetLeft,
				offsetTop,
				inputLeft,
				inputTop,
				fieldset_width,
				fieldset_position
		FROM   #form_contains
		WHERE  group_id = @tab_id
		ORDER BY fieldset_seq
	OPEN fieldset_cursor
	FETCH NEXT FROM fieldset_cursor INTO @fieldset_id, @fieldset_name, @fieldset_label, @fieldset_seq, @num_column, @offset_left, @offset_top, @input_left, @input_top, @fieldset_width, @fieldset_position
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @row_number = 0
		SET @block_json = ''
		SET @field_json = ''
				
		DECLARE fields_cursor CURSOR FOR
		SELECT [application_field_id],
				[id],
				[type],
				NAME,
				label,
				is_hidden,
				field_size,
				header_detail,
				sql_string,
				tab_name,
				fieldset_label,
				blank_option,
				default_format,
				group_id,
				fieldset_id,
				value,
				position,
				group_name,
				text_row_num,
				CASE WHEN default_format = 't' THEN ' %H:%i' ELSE '' END time_part,
				field_seq,
				''  unique_id, --Commented to bypass combov2 data caching without reverting all changes done for data caching for july release.
				--CASE WHEN TYPE = 'combo_v2' THEN (dbo.FNAGetUniqueSQLKey(sql_string,'cmbv2') + '_' + @user_login_id) ELSE '' END unique_id
				CASE WHEN is_hidden <> 'y' THEN CASE WHEN insert_required = 'y' OR update_required = 'y' OR validate LIKE '%NotEmpty%' THEN 'true' ELSE 'false' END ELSE 'false' END is_required
		FROM   #form_contains
		WHERE  TYPE NOT IN ('settings', 'fieldset')
				AND ISNULL(fieldset_id, -1) = @fieldset_id
				AND group_id = @tab_id
		ORDER BY  
		   field_seq asc
		  -- CASE WHEN @call_from = 'mobile' THEN field_seq --, is_hidden
				--ELSE CASE WHEN name = 'book_structure' THEN 0 ELSE field_seq END 
		  -- END

		OPEN fields_cursor
		FETCH NEXT FROM fields_cursor INTO @application_field_id, @id, @type, @name, @label, @is_hidden, @field_size, @is_header, @sql_string, @tab_name, @fieldset, @blank_option, @default_format, @group_id, @fieldset_id, @value, @position, @group_name,@text_row_num,  @time_part,@field_seq,@unique_id, @is_required
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @combo_process_table VARCHAR(300)
			DECLARE @combo_process_id VARCHAR(100) = dbo.FNAGETNEWID()
			DECLARE @combo_user_name VARCHAR(50) = dbo.FNADBUser()
			SET @combo_process_table = NULL
			
			SET @json_combo_value = NULL
			IF @type IN ('combo_v2', 'combo', 'multiselect', 'select', 'radio', 'upload')
			BEGIN
				IF OBJECT_ID(N'tempdb..#combo_items ') IS NOT NULL
					DROP TABLE #combo_items
			
				--Logic for Filter combo i.e. apply_filter field where replacing the ID to the group id
				IF ((SELECT CHARINDEX('spa_application_ui_filter', @sql_string)) > 0 )
				BEGIN
					SELECT @sql_string = REPLACE(@sql_string, '<ID>', @tab_id)
				END
				ELSE IF ((SELECT CHARINDEX('spa_application_security_role', @sql_string)) > 0)
				BEGIN	
					
					Declare @login_id VARCHAR(50)
					SELECT @login_id = value FROM #form_contains where name = 'user_login_id'
					IF @login_id IS NOT NULL
						SELECT @sql_string = REPLACE(@sql_string, '<ID>', @login_id)
				END
				
				--## Pass filter value for combo v2 in case of default value to get only required options
				--## If no default value and required, it should be handled in respective dropdown query (default value -1)
				IF ((SELECT CHARINDEX('<FILTER_VALUE>', @sql_string)) > 0)
				BEGIN
					IF NULLIF(@value, '') IS NOT NULL 
						SELECT @sql_string = REPLACE(@sql_string, '<FILTER_VALUE>', @value)
					ELSE IF @is_required = 'true' -- If required and default value none pass -1 as default value to get one default option
						SELECT @sql_string = REPLACE(@sql_string, '<FILTER_VALUE>', '-1')
				END
				
				CREATE TABLE #combo_items (
					[text]      NVARCHAR(1000) COLLATE DATABASE_DEFAULT ,
					[value]     NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
					[state]		NVARCHAR(10) DEFAULT 'enable' COLLATE DATABASE_DEFAULT
				)
          
				IF (NULLIF(@sql_string, 'NULL') <> '' AND (NULLIF(@value, '') IS NOT NULL OR @is_required = 'true' OR @type <> 'combo_v2'))
				BEGIN
					DECLARE @drop_down_start_character NCHAR(1)
 					SET @drop_down_start_character = SUBSTRING(@sql_string, 1, 1)
 			
 					IF @drop_down_start_character = '['
 					BEGIN
						SET @sql_string = REPLACE(@sql_string, NCHAR(13), '')
 						SET @sql_string = REPLACE(@sql_string, NCHAR(10), '')
 						SET @sql_string = REPLACE(@sql_string, NCHAR(32), '')
 						SET @sql_string = [dbo].[FNAParseStringIntoTable](@sql_string)

 						EXEC('INSERT INTO #combo_items([value], [text])
 								SELECT [value], [text] FROM (' + @sql_string + ') a ([value], [text])');
					END
					ELSE
					BEGIN
						BEGIN TRY
							SET @sql = 'INSERT INTO #combo_items([value],[text]) ' + @sql_string
							EXEC (@sql)
						END TRY
						BEGIN CATCH
							SET @sql = 'INSERT INTO #combo_items([value],[text],[state]) ' + @sql_string
							EXEC (@sql)
						END CATCH
					END
				END

				SET @sql_string = 'SELECT [value],[text],[state] FROM #combo_items'
				
				IF @type = 'radio'
				BEGIN
					SET @sql_string = 'SELECT ''radio'' AS type, value, dbo.FNAGetLocaleValue(text) AS label, ''' + @name + ''' AS name,'''+@position +''' AS position, CASE WHEN value = ''' + CAST(ISNULL(@value, '''''''') AS nvarchar(100)) + ''' THEN ''true'' ELSE ''false'' END [checked]  FROM (' + @sql_string + ') a '
					SET @field_string = ' SET @xml = (' + @sql_string + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'
			
					EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
			
					SELECT @json_radio = dbo.FNAFlattenedJSON(@xml)
				END
				ELSE IF @type = 'upload'
				BEGIN
					SET @field_string = ' SET @xml = (SELECT type AS [type], name AS name, value, validate, field_size AS inputWidth, ''__UPLOAD_FILE_PATH__'' AS [url], ''html5'' AS [mode]
 														FROM  #form_contains WHERE [id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'

					EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
            
					SET @upload_json = NULL            
					SELECT @upload_json = dbo.FNAFlattenedJSON(@xml)        
					SET @upload_json = '[' + @upload_json + ']'    
				END
				ELSE
				BEGIN
					-- Added form Mobile App since js_dropdown_connector_v2_url cannot be used.
					IF @call_from = 'mobile' OR @call_from = @call_from_design OR @type IN ('combo', 'multiselect') OR (@type = 'combo_v2' AND NULLIF(@value, '') IS NOT NULL)
					BEGIN
						IF OBJECT_ID('tempdb..#temp_combo') IS NOT NULL
							DROP TABLE #temp_combo
	
						CREATE TABLE #temp_combo (
							[value] NVARCHAR(500) COLLATE DATABASE_DEFAULT , 
							[text] NVARCHAR(1000) COLLATE DATABASE_DEFAULT , 
							[selected] NVARCHAR(10) COLLATE DATABASE_DEFAULT ,
							[state] NVARCHAR(10) COLLATE DATABASE_DEFAULT
						)

						IF @blank_option = 'y'
						BEGIN
							INSERT INTO #temp_combo([value], [text], [state])
							SELECT '', '', ''
						END
	
						INSERT INTO #temp_combo([value], [text], [state])
						EXEC(@sql_string)
						
						--## IF combo_v2 field is required but no default value then set one option by default
						-- Backward Compatibility if filter value method not implemented in dropdown query starts
						-- /*
						IF @type = 'combo_v2'
						BEGIN
							IF @is_required = 'true' AND NULLIF(@value, '') IS NULL
							BEGIN
								SELECT TOP 1 @value = [value]
								FROM #temp_combo
								WHERE NULLIF([value], '') IS NOT NULL
								ORDER BY [text]
							END

							DELETE tc
							FROM #temp_combo tc
							LEFT JOIN dbo.SplitCommaSeperatedValues(@value) s ON s.item = tc.[value]
							WHERE s.item IS NULL
						END
						-- Backward Compatibility if filter value method not implemented in dropdown query ends */

						UPDATE #temp_combo
						SET [selected] = 'true'
						-- Added below case to support multiple value coming from multiselect combo.
						WHERE [value] IN (SELECT item FROM dbo.SplitCommaSeperatedValues(CAST(@value AS NVARCHAR(50))))

						--DECLARE @xml XML
						DECLARE @nsql NVARCHAR(4000)
						SET @param = N'@xml XML OUTPUT';
					
						SET @nsql = ' SET @xml = (SELECT [value], [text], [selected] ' + CASE WHEN @is_report = 'y' AND @type = 'combo' AND @default_format = 'm' THEN ', selected as [checked]' ELSE '' END + ', [state]
									 FROM #temp_combo 
									 ORDER BY (CASE 
													WHEN [text] IN (''-'',''+'',''.'','','',''$'',''/'',''\'') THEN  CAST(-99999999999999999999999999999999999999 AS NUMERIC(38, 0))
													WHEN NULLIF([text], '''') IS NULL THEN CAST(-99999999999999999999999999999999999999 AS NUMERIC(38, 0))		--blank option should be shown first 
													WHEN ISNUMERIC(text) = 1 AND TRY_CAST([text] AS NUMERIC(38, 0)) IS NOT NULL THEN CAST([text] AS NUMERIC(38, 0))
													ELSE CAST(99999999999999999999999999999999999999 AS NUMERIC(38, 0)) END
											) , [text]
									 FOR XML RAW (''row''), ROOT (''root''), ELEMENTS)'
					
						--PRINT @nsql
						EXECUTE sp_executesql @nsql, @param,  @xml = @xml OUTPUT;
								 
						

						IF (@call_from = 'DESIGN')
						BEGIN
							SET @xml = REPLACE(CAST(@xml AS NVARCHAR(MAX)), '"', '\\"')
						END
						ELSE 
						BEGIN
							SET @xml = REPLACE(CAST(@xml AS NVARCHAR(MAX)), '"', '\"')
						END
					
						SELECT @json_combo_value = dbo.FNAFlattenedJSON(@xml)
					
						IF LEFT(LTRIM(@json_combo_value), 1) <> '['
							SET @json_combo_value = '[' + @json_combo_value + ']'
					END
				END
			END

			--DECLARE @user_data_json VARCHAR(500)
			--SET @user_data_json = '{application_field_id:' + @application_field_id+ '}'

			DECLARE @field_json_temp nvarchar(max)

			--BROWSER ADDED FOR CONTRACT AND COUNTERPARTY

			IF @call_from = @call_from_design
			BEGIN
				SET @field_string = ' SET @xml = (SELECT application_field_id, id, type, name, label, value, is_hidden, disabled, tab_name, fieldset_name, fieldset_label, fieldset_id, CAST(group_id AS VARCHAR(10)) + ''' + '_' + CAST(@is_new_tab AS VARCHAR(10)) + ''' [group_id], id [field_seq], insert_required, udf_template_id, ISNULL(original_label, label) [original_label]'
										+ CASE WHEN @type <> 'checkbox' AND @json_combo_value IS NOT NULL THEN ', CAST(N''' + REPLACE(@json_combo_value, '''', CAST('''''' AS NVARCHAR(MAX)))  + ''' AS NVARCHAR(MAX)) AS options' ELSE '' END 
										+ CASE WHEN @type = 'radio' THEN ',''' + @json_radio + '''  AS list' ELSE '' END +
										+ '  
												FROM  #form_contains WHERE [id]=' +  CAST(@id AS VARCHAR) + 
        						' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'
				--print @field_string
				EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
        		--SET @field_xml = CAST(@xml AS VARCHAR(MAX))	
        	
        		SELECT @field_json = dbo.FNAFlattenedJSON(@xml)
  
        		--SET @field_json = REPLACE(@field_json, '__DATEFORMAT__', COALESCE(dbo.FNAChangeDateFormat(), '%Y-%m-%d'))
        		SET @field_json = REPLACE(@field_json, '"__UPLOAD_FILE_PATH__"', 'js_file_uploader_url')
				SET @field_json = REPLACE(@field_json, '\\\', '\');
			END
			ELSE
			BEGIN
			IF (@type = 'browser')
			BEGIN
				SET @is_book = NULL
				SET	@grid_name = NULL
				SET	@grid_label = NULL
				SET @enable_single_select = NULL

				SELECT @is_book = grid_id,
						@enable_single_select = isnull(enable_single_select, 0) 	
				FROM   application_ui_template_fields
				WHERE  application_field_id = iif( @is_report in ('y','c'), application_field_id, @application_field_id)
				
				IF @browser_grid_process_table IS NOT NULL AND ISNULL(@is_book, '') NOT IN ('existing_formula','deal_filter', 'formula', 'sub_book_mapping', 'source_group','report_filter')
				BEGIN
					IF OBJECT_ID('tempdb..#tmp_grid_browser') IS NOT NULL
						DROP TABLE #tmp_grid_browser
					CREATE TABLE #tmp_grid_browser
					(
						farrms_field_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
						grid_name VARCHAR(100) COLLATE DATABASE_DEFAULT
					)

					DECLARE @b_sql VARCHAR(2000)
						
					SET @b_sql = '  INSERT INTO #tmp_grid_browser (farrms_field_id, grid_name)
									SELECT * FROM ' + @browser_grid_process_table
					EXEC(@b_sql)	 

					SELECT  @grid_name		= bg.grid_name,
							@grid_label		= agd.grid_label,
							@is_book		= agd.grid_id,
							@to_resolve_value = NULLIF(fc.value,'')

					FROM #tmp_grid_browser bg
					INNER JOIN #form_contains fc ON bg.farrms_field_id = fc.[name]
					LEFT JOIN adiha_grid_definition agd ON bg.grid_name = agd.grid_name
					WHERE fc.application_field_id = @application_field_id
				END

 				IF (@is_book = 'book' OR @is_book IS NULL)
				BEGIN
 					SET @field_string = ' SET @xml = (SELECT ''input'' AS [type], ''book_structure'' AS name,dbo.FNAGetLocaleValue(label) AS label,validate,''' + ISNULL(replace(@book_structure,'''',''''''), '') + ''' value,''browse_label'' AS ''className'',position, field_size AS inputWidth,  '  + CAST(@default_offsetleft AS CHAR(2))  + ' AS offsetLeft, field_size AS labelWidth,
																CASE WHEN   ISNULL(field_hidden,''n'') = ''y'' THEN ''true'' ELSE ''false'' END hidden
																,CASE WHEN   ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled --Added to include disabled attribute for browser fields json
																,''true'' AS readonly
																,CASE WHEN is_hidden <>''y'' THEN CASE WHEN insert_required = ''y'' OR update_required = ''y'' OR validate LIKE ''%NotEmpty%'' THEN ''true'' ELSE ''false'' END ELSE ''false'' END required,
																''{"grid_name":"book", "grid_label": "Portfolio Hierarchy","validation_message":"''+ISNULL(validation_message, '''') +''"}''AS userdata
 															FROM  #form_contains WHERE [id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'

					EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
					SELECT @field_json_temp = dbo.FNAFlattenedJSON(@xml)
					IF @call_from = 'mobile'
						SET @field_json = LEFT(@field_json_temp, LEN(@field_json_temp) - 1) + '}'
					ELSE
						SET @field_json = '{"type": "block", "blockOffset": '  + CAST(@default_blockoffset AS CHAR(2))  + ', "list": [' + LEFT(@field_json_temp, LEN(@field_json_temp) - 1) + '}'
						


					SET @field_string = ' SET @xml = (SELECT ''input'' AS [type], ''subsidiary_id'' AS name, label,validate,''' + ISNULL(@subsidiary_id, '') + ''' value,position, 0 AS inputWidth,  '  + CAST(@default_offsetleft AS CHAR(2))  + ' AS offsetLeft, 0 AS labelWidth, 
																''true''AS hidden,CASE WHEN   ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled
 															FROM  #form_contains WHERE [id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'

					EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
					SELECT @field_json_temp = dbo.FNAFlattenedJSON(@xml)
					SET @field_json = @field_json + ',{"type":"newcolumn"},' + @field_json_temp

					SET @field_string = ' SET @xml = (SELECT ''input'' AS [type], ''strategy_id'' AS name,label,validate,''' + ISNULL(@strategy_id, '''') + ''' value,position, 0 AS inputWidth,  '  + CAST(@default_offsetleft AS CHAR(2))  + ' AS offsetLeft, 0 AS labelWidth, 
																''true''AS hidden,CASE WHEN   ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled
 															FROM  #form_contains WHERE [id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'

					EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
					SELECT @field_json_temp = dbo.FNAFlattenedJSON(@xml)
					SET @field_json = @field_json + ',{"type":"newcolumn"},' + @field_json_temp

					SET @field_string = ' SET @xml = (SELECT ''input'' AS [type], ''book_id'' AS name,label,validate,''' + ISNULL(@book_id, '') + ''' value,position, 0 AS inputWidth,  '  + CAST(@default_offsetleft AS CHAR(2))  + ' AS offsetLeft, 0 AS labelWidth, 
																''true''AS hidden,CASE WHEN   ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled
 															FROM  #form_contains WHERE [id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'

					EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
					SELECT @field_json_temp = dbo.FNAFlattenedJSON(@xml)
					SET @field_json = @field_json + ',{"type":"newcolumn"},' + @field_json_temp
					--set validate for subbok_id as blank since fastracker_rwe has no subbook set as configured, so no subbook is listed for selection on mandatory book field which was giving form validation error for 'NoNEmpty' subbook_id. Even when subbook is enabled on configuration the blank validate column value on subbok_id will not affect because mandatory book means user will select atleast one entity and afterall subbook gets selected. (2018-05-20 NPT)
					SET @field_string = ' SET @xml = (SELECT ''input'' AS [type], ''subbook_id'' AS name,label,'''',''' + ISNULL(@subbook_id, '') + ''' value,position, 0 AS inputWidth,  '  + CAST(@default_offsetleft AS CHAR(2))  + ' AS offsetLeft, 0 AS labelWidth, 
																''true''AS hidden,CASE WHEN   ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled
 															FROM  #form_contains WHERE [id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'

					EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
					SELECT @field_json_temp = dbo.FNAFlattenedJSON(@xml)
					SET @field_json = @field_json + ',{"type":"newcolumn"},' + @field_json_temp
					
					IF @call_from = 'mobile'
					BEGIN
						SET @field_string = ' SET @xml = (SELECT ''button'' AS [type], ''browse_book_structure'' AS name,'''' AS value,''Browse'' AS ''tooltip'',position,''test'' AS ''cssName'',''browse_open'' AS ''className'', 0 AS inputWidth, 0 AS offsetLeft, 25 AS offsetTop, 0 AS labelWidth, 
																CASE WHEN   ISNULL(field_hidden,''n'') = ''y'' THEN ''true'' ELSE ''false'' END hidden,CASE WHEN   ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled
 															FROM  #form_contains WHERE [id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'

						EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
						SELECT @field_json_temp = dbo.FNAFlattenedJSON(@xml)

						SET @field_json = @field_json + ',{"type":"newcolumn"},' + @field_json_temp
					END

					SET @field_string = ' SET @xml = (SELECT ''button'' AS [type], ''clear_book_structure''AS name,'''' AS value,dbo.FNAGetLocaleValue(''Clear'') AS ''tooltip'',''browse_clear'' AS ''className'',position, 0 AS inputWidth, '  + CAST(@default_browse_clear_offsetleft AS CHAR(3))  + ' AS offsetLeft, '  + CAST(@default_browse_clear_offsettop AS CHAR(2))  + ' AS offsetTop, 0 AS labelWidth, 
															CASE WHEN   ISNULL(field_hidden,''n'') = ''y'' THEN ''true'' ELSE ''true'' END hidden,CASE WHEN   ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled
 													FROM  #form_contains WHERE [id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'

					EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
					SELECT @field_json_temp = dbo.FNAFlattenedJSON(@xml)
					IF @call_from = 'mobile'
						SET @field_json = @field_json + ',{"type":"newcolumn"},' + @field_json_temp
					ELSE
						SET @field_json = @field_json + ',{"type":"newcolumn"},' + @field_json_temp + ']},'
				END
				ELSE
				BEGIN
					SET @field_string = ' SET @xml = (SELECT ''input'' AS [type],name,label,validate,ISNULL(value,'''') value,position, 0 AS inputWidth,  '  + CAST(@default_offsetleft AS CHAR(2))  + ' AS offsetLeft, 0 AS labelWidth, 
																''true''AS hidden,CASE WHEN   ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled
 														FROM  #form_contains WHERE [id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'

					EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
					SELECT @field_json_temp = dbo.FNAFlattenedJSON(@xml)

					DECLARE  @grid_sql	VARCHAR(500)
						, @grid_cols NVARCHAR(MAX)
						, @grid_col_label NVARCHAR(500)
						, @grid_col1	NVARCHAR(50)
						, @grid_col2	NVARCHAR(50)
            
					DECLARE @tbl VARCHAR(255);
					SET @tbl = dbo.FNAProcessTableName('grid_data', @user_login_id, dbo.FNAGetNewID())
					EXEC ('CREATE TABLE ' + @tbl + '(id NVARCHAR(max) COLLATE DATABASE_DEFAULT , value NVARCHAR(max) COLLATE DATABASE_DEFAULT)')
					
					IF (ISNUMERIC(@is_book) = 1 AND @browser_grid_process_table IS NULL)
					BEGIN
 						SELECT
						  @grid_name	= agd.grid_name,
						  @grid_label	= agd.grid_label,
						  @grid_sql		= agd.load_sql,
						  @grid_cols	= COALESCE(@grid_cols + ', ', '') + CAST(agc.column_name AS VARCHAR(50)) + ' NVARCHAR(500) COLLATE DATABASE_DEFAULT '						 
						FROM application_ui_template_fields autf
						INNER JOIN adiha_grid_definition agd
						  ON CAST(autf.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
						INNER JOIN adiha_grid_columns_definition agc on CAST(agc.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
						WHERE autf.application_field_id = @application_field_id
													
						select @grid_col1 = c1.column_name
						FROM (SELECT ROW_NUMBER() 
								OVER (ORDER BY agc.column_order) AS Row,  agc.column_name
						FROM application_ui_template_fields autf
						INNER JOIN adiha_grid_definition agd
						  ON autf.grid_id = agd.grid_id
						INNER JOIN adiha_grid_columns_definition agc on agc.grid_id = agd.grid_id
						WHERE autf.application_field_id = @application_field_id) c1 WHERE c1.row = 1
						
						select @grid_col2 = c2.column_name
						FROM (SELECT ROW_NUMBER() 
								OVER (ORDER BY agc.column_order) AS Row,  agc.column_name
						FROM application_ui_template_fields autf
						INNER JOIN adiha_grid_definition agd
						  ON autf.grid_id = agd.grid_id
						INNER JOIN adiha_grid_columns_definition agc on agc.grid_id = agd.grid_id
						WHERE autf.application_field_id = @application_field_id) c2 WHERE c2.row = 2
										
						
						SET @sql = 'CREATE TABLE #grid_data' + '(row_id INT IDENTITY(1,1),' + @grid_cols + ')
						INSERT INTO #grid_data
						EXEC(''' + REPLACE(REPLACE(REPLACE(@grid_sql,'''',''''''), '<ID>', 'NULL'),'<application_field_id>','NULL')  + ''')						
						INSERT INTO ' + @tbl + '(id,value)
						SELECT ' + @grid_col1 +','+@grid_col2 + ' FROM #grid_data
						--DROP TABLE #grid_data
										
						'
						--print @sql
						EXEC(@sql)			 
					END
					ELSE IF (ISNUMERIC(@is_book) = 1 AND @browser_grid_process_table IS NOT NULL AND @to_resolve_value IS NOT NULL)
					BEGIN
						SELECT  @grid_name = agd.grid_name,
								@grid_label = agd.grid_label,
								@grid_sql = agd.load_sql,
								@grid_cols = COALESCE(@grid_cols + ', ', '') + CAST(agc.column_name AS NVARCHAR(50)) + ' NVARCHAR(500) COLLATE DATABASE_DEFAULT '
						FROM #tmp_grid_browser bg
						INNER JOIN #form_contains fc ON bg.farrms_field_id = fc.[name]
						INNER JOIN adiha_grid_definition agd ON bg.grid_name = agd.grid_name
						INNER JOIN adiha_grid_columns_definition agc on CAST(agc.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
						WHERE fc.application_field_id = @application_field_id
						ORDER BY agc.column_order
 
 						SELECT @grid_col1 = c1.column_name
						FROM (SELECT ROW_NUMBER() 
								OVER (ORDER BY agc.column_order) AS Row,  agc.column_name
						FROM #tmp_grid_browser bg
						INNER JOIN #form_contains fc ON bg.farrms_field_id = fc.[name]
						INNER JOIN adiha_grid_definition agd ON bg.grid_name = agd.grid_name
						INNER JOIN adiha_grid_columns_definition agc on CAST(agc.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
						WHERE fc.application_field_id = @application_field_id) c1 WHERE c1.row = 1
						
						SELECT @grid_col2 = c2.column_name
						FROM (SELECT ROW_NUMBER() 
								OVER (ORDER BY agc.column_order) AS Row,  agc.column_name
						FROM #tmp_grid_browser bg
						INNER JOIN #form_contains fc ON bg.farrms_field_id = fc.[name]
						INNER JOIN adiha_grid_definition agd ON bg.grid_name = agd.grid_name
						INNER JOIN adiha_grid_columns_definition agc on CAST(agc.grid_id AS VARCHAR) = CAST(agd.grid_id AS VARCHAR)
						WHERE fc.application_field_id = @application_field_id) c2 WHERE c2.row = 2
										
						
						SET @sql = 'CREATE TABLE #grid_data' + '(row_id INT IDENTITY(1,1),' + @grid_cols + ')
						INSERT INTO #grid_data
						EXEC(''' + REPLACE(REPLACE(REPLACE(REPLACE(@grid_sql,'''',''''''),'<FILTER_VALUE>', @to_resolve_value), '<ID>', 'NULL'),'<application_field_id>','NULL')  + ''')						
						
						INSERT INTO ' + @tbl + '(id,value)
						SELECT ''' + @to_resolve_value +''',STUFF((
																SELECT '','' + ' + @grid_col2 + ' FROM #grid_data WHERE '+ @grid_col1+' IN (' + @to_resolve_value + ')  FOR XML PATH('''')
																), 1, 1, '''')
						--DROP TABLE #grid_data
						--select * from #grid_data	
						'
						
						--print @sql
						EXEC(@sql)
					END
					ELSE IF (ISNUMERIC(@is_book) = 1 AND @browser_grid_process_table IS NOT NULL AND @to_resolve_value IS NULL)
					BEGIN
						SET @sql = '
							INSERT INTO ' + @tbl + '(id, value)
							SELECT ''' + @to_resolve_value +''',NULL'
						EXEC(@sql)
					END
					ELSE
					BEGIN		
						SET @grid_name = @is_book
						SET @grid_label = @is_book
					END

					--Added to resolve formula name
					IF @is_book = 'formula'
					BEGIN
						SET @sql = '
							INSERT INTO ' + @tbl + '
							SELECT fe.formula_id, ISNULL(NULLIF(fe.formula_name, ''''), dbo.FNAFormulaFormatMaxString(fe.formula, ''r'')) formula
							FROM formula_editor fe
							WHERE CAST(fe.formula_id AS VARCHAR(10)) = ' + ISNULL(NULLIF(@value, ''), '''''') + '								
						'
						EXEC (@sql)
					END
					--dynamically built variable is reset to null
					SET @grid_cols = NULL
						
					SET @field_json = LEFT(@field_json_temp, LEN(@field_json_temp) - 1) + ',"userdata":{"application_field_id":"' + CAST(@application_field_id as VARCHAR) + '","grid_name":"' + @grid_name + '", "grid_label": "' + ISNULL(@grid_label, @grid_name) + '", "enable_single_select" : "' + @enable_single_select + '"}}'
					
					SET @field_string = ' SET @xml = (SELECT ''input'' AS [type]
															,''label_'' + name  AS name
															,dbo.FNAGetLocaleValue(label) label
															--,validate
															,REPLACE(COALESCE(dbo.FNADecodeXML(tbl.value), fc.value, ''''), ''"'', ''\"'') AS value
															,''browse_label'' AS className
															,position
															,field_size AS inputWidth
															, '  + CAST(@default_offsetleft AS CHAR(2))  + ' AS offsetLeft
															,field_size AS labelWidth
															,CASE WHEN   ISNULL(field_hidden,''n'') = ''y'' THEN ''true'' ELSE ''false'' END hidden
															,CASE WHEN   ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled --Added to include disabled attribute for browser fields json
															,''true'' AS readonly
															,CASE WHEN is_hidden <>''y'' THEN CASE WHEN insert_required = ''y'' OR update_required = ''y'' OR validate LIKE ''%NotEmpty%'' THEN ''true'' ELSE ''false'' END ELSE ''false'' END required
															,''{"validation_message":"''+ISNULL(validation_message, '''') +''"}''AS userdata
														FROM  #form_contains fc
 														left join ' + @tbl + ' tbl on tbl.id = fc.value
 														WHERE fc.[id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'

					EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
					SELECT @field_json_temp = dbo.FNAFlattenedJSON(@xml)

					IF @call_from = 'mobile'
					BEGIN
						SET @field_json = @field_json + ',{"type":"newcolumn"},' + @field_json_temp
						SET @field_string = ' SET @xml = (SELECT ''button'' AS [type], ''browse_'' + name AS name,'''' AS value,''Browse'' AS ''tooltip'',''browse_clear'' AS ''className'',position, 0 AS inputWidth, '  + CAST(@default_browse_clear_offsetleft AS CHAR(3))  + ' AS offsetLeft, '  + CAST(@default_browse_clear_offsettop AS CHAR(2))  + ' AS offsetTop, 0 AS labelWidth, 
																CASE WHEN   ISNULL(field_hidden,''n'') = ''y'' THEN ''true'' ELSE ''false'' END hidden,CASE WHEN   ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled
 														FROM  #form_contains WHERE [id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'
					END
					ELSE
					BEGIN
						SET @field_json = @field_json + ',{"type":"newcolumn"},' + '{"type": "block", "blockOffset": '  + CAST(@default_blockoffset AS CHAR(2))  + ', "list": [' + @field_json_temp
						SET @field_string = ' SET @xml = (SELECT ''button'' AS [type], ''clear_'' + name AS name,'''' AS value,dbo.FNAGetLocaleValue(''Clear'') AS ''tooltip'',''browse_clear'' AS ''className'',position, 0 AS inputWidth, '  + CAST(@default_browse_clear_offsetleft AS CHAR(3))  + ' AS offsetLeft, '  + CAST(@default_browse_clear_offsettop AS CHAR(2))  + ' AS offsetTop, 0 AS labelWidth, 
																CASE WHEN   ISNULL(field_hidden,''n'') = ''y'' THEN ''true'' ELSE ''true'' END hidden,CASE WHEN   ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled
 														FROM  #form_contains WHERE [id]=' + CAST(@id AS varchar) + ' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'
					END
					
					EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
					SELECT @field_json_temp = dbo.FNAFlattenedJSON(@xml)
					IF @call_from = 'mobile'
						SET @field_json = @field_json + ',{"type":"newcolumn"},' + @field_json_temp
					ELSE
						SET @field_json = @field_json + ',{"type":"newcolumn"},' + @field_json_temp + ']},'
				END
			END
			ELSE
			BEGIN
				IF EXISTS( SELECT  1
							FROM   application_ui_template_fields autf
								WHERE  autf.dependent_field IS NOT NULL
										AND autf.dependent_query IS NOT NULL
										AND application_field_id = iif( @is_report in ('y','c'), null, @application_field_id)
						) 
				BEGIN
					SET @is_dependent = 1;
				END
				ELSE
				BEGIN
					SET @is_dependent = 0;
				END

				DECLARE @combo_url NVARCHAR(2000)
				SET @combo_url = NULL
				IF @type = 'combo_v2'
				BEGIN
					SET @parent_value = NULL
					SELECT @parent_value = value
					FROM #form_contains fc
						INNER JOIN (
							SELECT dependent_field
							FROM application_ui_template_fields 
							WHERE application_field_id = @application_field_id
						) a
						ON fc.name = a.dependent_field
					--Donot cache combov2 data if default value or parent value is defined.
					SET @unique_id = CASE WHEN NULLIF(@parent_value,'') IS NOT NULL OR NULLIF(@value,'') IS NOT NULL THEN '' ELSE @unique_id END

					SET @combo_url = 'js_dropdown_connector_v2_url+"&application_field_id=' + CAST(@application_field_id AS VARCHAR(20)) 
										+ '&default_value=' + CAST(@value AS NVARCHAR(50)) 
										+ CASE WHEN @parent_value IS NOT NULL THEN '&parent_value=' + CAST(@parent_value AS VARCHAR(50))  ELSE '' END
										+ '&is_report=' + @is_report 
										+ '&unique_id=' + @unique_id + '"'

			
				END
				
        		SET @field_string = N' SET @xml = (SELECT ' + CASE WHEN @type IN ('radio', 'upload') THEN '''fieldset'' AS [type], field_size width, dbo.FNAGetLocaleValue(label) label,  '  + CAST(@default_offsetleft AS NCHAR(2))  + ' AS offsetLeft ' 
        														ELSE CASE WHEN @type = 'combo_v2' THEN '''combo'' AS [type]' ELSE ' [type] ' END + ',
        															name,
        															'
																	+ CASE WHEN @type <> 'template' THEN 
																			'
																			CASE WHEN NULLIF(hyperlink_function, '''') IS NOT NULL THEN 
																				''<a id=''''''+field_id+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+hyperlink_function+'',this.id);''''>''+dbo.FNAGetLocaleValue(label)+''</a>'' 
																			ELSE
																				dbo.FNAGetLocaleValue(label) 
																			END 
																			'
																		ELSE  
																			'ISNULL(value, '''')' 
																		END +
																	
																	' label,
																	validate,  
        															CASE WHEN ISNULL(field_hidden,''n'') = ''y'' THEN ''true'' ELSE ''false'' END hidden,
																	--CASE WHEN ISNULL([disabled],''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled,
																	CASE WHEN ISNULL(nullif([disabled],''r''),''n'') = ''y'' THEN ''true'' ELSE ''false'' END disabled,
																	iif([disabled]=''r'',''true'', ''false'') [readonly],
																	'
																	+ 
										   							CASE WHEN LEFT(@default_format, 4) = 'SQL:' THEN
																		RIGHT(@default_format, LEN(@default_format) - 4)
																	ELSE																	
																		CASE WHEN @type = 'calendar' THEN 
																				'
																				CASE WHEN NULLIF(value, '''') IS NULL THEN 
																					'''' 
																				ELSE ' + 

																						CASE WHEN @default_format = 't' THEN  
																							' dbo.FNAGetSQLStandardDateTime(value)' 
																						ELSE 
																							' dbo.FNAGetSQLStandardDate(value)'
																						END
																					+ '
																				END 
																				'
																			WHEN @type = 'password' THEN
																				+ ''''' AS '
																			ELSE  
																				'ISNULL(value, '''')' 
																			END 
																	END
																	+
																	
																	'value,''{"application_field_id":'' + CAST(application_field_id AS VARCHAR(50)) + '',"default_format":"'' + ISNULL(default_format, '''') + ''","is_dependent":"' + CAST(@is_dependent AS NVARCHAR(10)) + '","validation_message":"''+ISNULL(validation_message, '''') +''"'' + IIF(open_ui_function_id IS NOT NULL, '',"data_window_info":"''+ af.file_path +''"'', '''') + ''}''AS userdata,
																	position,
																	 '  + CAST(@default_offsetleft AS NCHAR(2))  + ' AS offsetLeft, 
																	''auto'' AS labelWidth, 
        															field_size AS inputWidth,
        															dbo.FNAGetLocaleValue(label) [tooltip]	,
																	CASE WHEN is_hidden <>''y'' THEN CASE WHEN insert_required = ''y'' OR update_required = ''y'' OR validate LIKE ''%NotEmpty%'' THEN ''true'' ELSE ''false'' END ELSE ''false'' END required,
																	char_length AS maxLength
																	' 
        														END
        													+ CASE WHEN @type = 'template' THEN ',ISNULL([hyperlink_function],'''') AS format ' ELSE '' END +
															+ CASE WHEN @type = 'input' AND @text_row_num IS NOT NULL THEN ','+@text_row_num + ' AS rows ' ELSE '' END +
															+ CASE WHEN @type = 'calendar' OR @type = 'dyn_calendar' THEN ',  ''' + COALESCE(dbo.FNAChangeDateFormat() + @time_part, '%Y-%m-%d' + @time_part) + ''' AS dateFormat,  
															''%Y-%m-%d' + @time_part + ''' AS serverDateFormat, ''bottom'' AS calendarPosition ' ELSE '' END +
        													+ CASE WHEN @type = 'calendar' AND @default_format = 't' THEN ',''true'' AS enableTime' ELSE '' END +
        													+ CASE WHEN @type IN('combo', 'combo_v2', 'multiselect') AND @default_format = 'm' THEN ',''custom_checkbox'' AS [comboType], ''true'' AS [filtering] ' WHEN @type IN('combo', 'combo_v2') THEN ' , ''true'' AS [filtering] ' ELSE '' END +
															+ CASE WHEN @type IN('combo', 'combo_v2', 'multiselect') AND @default_format = 'c' THEN ',''custom_checkbox'' AS [comboType] ' ELSE '' END +
        													+ CASE WHEN @type IN('combo', 'combo_v2', 'multiselect')  THEN ',''between'' AS [filtering_mode] ' ELSE '' END +
															+ CASE WHEN @type = 'editor' THEN ',inputHeight,' ELSE '' END +
        													+ CASE WHEN @type = 'radio' THEN ', N''' + @json_radio + '''  AS list' ELSE '' END +
        													+ CASE WHEN @type = 'upload' THEN ', N''' + @upload_json + ''' AS list' ELSE '' END +
        													+ CASE WHEN @type = 'checkbox' THEN ', CASE WHEN value IN(''y'',''1'') THEN ''true'' ELSE ''false'' END AS checked, '  + CAST(@default_checkbox_offsettop AS NCHAR(2))  + ' AS offsetTop , field_size AS labelWidth' ELSE '' END
        													+ CASE WHEN @type <> 'checkbox' AND @json_combo_value IS NOT NULL THEN ', CAST(N''' + REPLACE(@json_combo_value, '''', CAST('''''' AS NVARCHAR(MAX)))  + ''' AS NVARCHAR(MAX)) AS options' ELSE '' END 
        													+ CASE WHEN @type = 'combo_v2' AND @combo_url IS NOT NULL THEN ',''' + @combo_url + ''' AS connector' ELSE '' END
        													+ CASE WHEN @type = 'dyn_calendar' THEN ', ''0'' AS dynamicValue, ''0'' AS dayAdjustment' ELSE '' END +
															+ '  
													FROM  #form_contains
													LEFT JOIN application_functions af ON af.function_id = open_ui_function_id 
													WHERE [id]=' +  CAST(@id AS varchar) + 
        							' FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'        	
        		
				
        		EXECUTE sp_executesql @field_string, @param, @xml = @xml OUTPUT
        		--SET @field_xml = CAST(@xml AS VARCHAR(MAX))	
        	
        		SELECT @field_json = dbo.FNAFlattenedJSON(@xml)
  
        		--SET @field_json = REPLACE(@field_json, '__DATEFORMAT__', COALESCE(dbo.FNAChangeDateFormat(), '%Y-%m-%d'))
        		SET @field_json = REPLACE(@field_json, '"__UPLOAD_FILE_PATH__"', 'js_file_uploader_url')
				SET @field_json = REPLACE(@field_json, '\\\', '\');
				--select @field_json
			END
			END
			IF (@name = 'apply_filters')
			BEGIN
				SET @row_number = -1
				SET @filter_status = 'y'
			END
			IF @call_from = @call_from_design
			BEGIN
				SET @block_json = @block_json + ',' + @field_json
			END
			ELSE BEGIN
			IF @row_number = -1
			BEGIN
				SET @block_json = '{"type": "block", "blockOffset": '  + CAST(@default_blockoffset AS CHAR(2))  + ', "list": [' + @field_json + ',{"type":"newcolumn"},{"type": "button", name: "btn_filter_save", value: "", tooltip: dbo.FNAGetLocaleValue("Save Filter"),offsetTop:"22", className: "filter_save"},{"type":"newcolumn"},{"type": "button", name: "btn_filter_delete", value: "", tooltip: dbo.FNAGetLocaleValue("Delete Filter"),offsetTop:"22", className: "filter_delete"},{"type":"newcolumn"}' + ']},'
			END

			ELSE
			IF @row_number = 0
			BEGIN
				IF (@block_json != '')
				BEGIN
					SET @block_json = @block_json + '{"type": "block", "blockOffset": '  + CAST(@default_blockoffset AS CHAR(2))  + ', "list": [' + @field_json + ',{"type":"newcolumn"}'
				END
				ELSE
				BEGIN
					SET @block_json = '{"type": "block", "blockOffset": '  + CAST(@default_blockoffset AS CHAR(2))  + ', "list": [' + @field_json + ',{"type":"newcolumn"}'
				END
			END
			ELSE IF @row_number = @num_column
			BEGIN
				SET @block_json = @block_json + ']},{"type": "block", "blockOffset": '  + CAST(@default_blockoffset AS CHAR(2))  + ', "list": [' + @field_json + ',{"type":"newcolumn"}'
				SET @row_number = 0
			END
			ELSE
			BEGIN
				SET @block_json = @block_json + ',' + @field_json + ',{"type":"newcolumn"}'
			END
			END
			SET @row_number = @row_number + 1
			FETCH NEXT FROM fields_cursor INTO @application_field_id, @id, @type, @name, @label, @is_hidden, @field_size, @is_header, @sql_string, @tab_name, @fieldset, @blank_option, @default_format, @group_id, @fieldset_id, @value, @position, @group_name,@text_row_num, @time_part,@field_seq,@unique_id,@is_required
		END
		CLOSE fields_cursor
		DEALLOCATE fields_cursor

		IF @call_from = @call_from_design
		BEGIN
			SELECT @fieldset_json = @fieldset_json + ISNULL('' + NULLIF(@block_json, ''), '')
		END
		ELSE BEGIN
		IF @fieldset_id <> -1
		BEGIN
			SELECT @fieldset_json = ISNULL(NULLIF(@fieldset_json, '') + ',', '') + '{"type":"newcolumn"},{"type":"fieldset","label":"' + dbo.FNAGetLocaleValue(RTRIM(LTRIM(@fieldset_label))) + '","offsetLeft":"' + @offset_left + '","offsetTop":"' + @offset_top + '","inputLeft ":"' + @input_left + '","inputTop":"' + @input_top + '",'
									+ CASE WHEN @fieldset_width IS NOT NULL THEN '"width":"' + @fieldset_width + '",' ELSE '' END
									+ CASE WHEN @fieldset_position IS NOT NULL THEN '"position":"' + @fieldset_position + '",' ELSE '' END
									+ '"list":    [' + @block_json + ']}]}'
		END		
		ELSE
		BEGIN
    		SELECT @fieldset_json = @fieldset_json + ISNULL('' + NULLIF(@block_json, '') + ']}', '')
		END
		END
		FETCH NEXT FROM fieldset_cursor
		INTO @fieldset_id, @fieldset_name, @fieldset_label, @fieldset_seq, @num_column, @offset_left, @offset_top, @input_left, @input_top, @fieldset_width, @fieldset_position
	END
	CLOSE fieldset_cursor
	DEALLOCATE fieldset_cursor


	--SELECT @fieldset_json
	SET @tab_grid = ' SET @xml = (SELECT layout_cell, grid_id, grid_label, layout_cell_height  
											FROM #tab_grid
											WHERE group_id = ' + CAST(@tab_id AS varchar) + ' ORDER BY sequence
											FOR XML RAW(''row''), ROOT (''root''),ELEMENTS)'

	EXECUTE sp_executesql @tab_grid, @param, @xml = @xml OUTPUT
	SELECT @grid_id = dbo.FNAFlattenedJSON(@xml)
	
	INSERT INTO #store_result (tab_id, tab_json, form_json, layout_pattern, grid_json, seq, filter_status)
	SELECT CAST(@tab_id AS VARCHAR(20)) + IIF(@call_from = @call_from_design, '_' + CAST(@is_new_tab AS VARCHAR(1)), ''),  
			@tab, 
			CASE WHEN @call_from = @call_from_design THEN '[' + SUBSTRING(NULLIF(@fieldset_json, ''), 2, LEN(@fieldset_json)) + ']' ELSE '[' + @setting + ',' + NULLIF(@fieldset_json, '') + ']' END,
			@layout,
			IIF(@is_udf_tab = 'y' AND @call_from = @call_from_design, '{"layout_cell":"a","grid_id":"FORM","grid_label":"FORM"}', @grid_id),
			@manage_sequence,
			@filter_status
			   
	FETCH NEXT FROM tab_cursor
	INTO @tab_id, @layout, @grid_id, @manage_sequence, @is_udf_tab, @is_new_tab
END
CLOSE tab_cursor
DEALLOCATE tab_cursor
SET @sql = ''
IF @call_from = 'regression_testing'
BEGIN
DECLARE @filter_table_name VARCHAR(200) = dbo.FNAProcessTableName('form_data', dbo.FNADBUser(), @regg_process_id)
		IF OBJECT_ID(@filter_table_name) IS NULL
			EXEC('CREATE TABLE ' + @filter_table_name + '(tab_id INT, tab_json VARCHAR(MAX), form_json VARCHAR(MAX), layout_pattern VARCHAR(500), grid_json VARCHAR(MAX), seq INT, dependent_combo INT, filter_status VARCHAR(1))') 

		SET @sql += ' INSERT INTO  ' + @filter_table_name
END

SET @sql += ' SELECT sr.tab_id,
	    RTRIM(LTRIM(tab_json))      tab_json,
				RTRIM(LTRIM(REPLACE(form_json, '',,{"type"'', '',{"type"'')))     form_json,
				iif( ''' + @is_report  + ''' in (''y'',''c''),right( ''' + @form_process_table + ''' ,36),layout_pattern) [layout_pattern],
	    grid_json,
	    seq,
	    dc.dependent_combo,
				''' + @filter_status + ''' [filter_status]
FROM   #store_result sr INNER JOIN #dependent_combo dc ON dc.tab_id = sr.tab_id
		ORDER BY seq'
	
EXEC(@sql)
	
SET @sql = dbo.FNAProcessDeleteTableSql(@tab_process_table)
EXEC (@sql)
SET @sql = dbo.FNAProcessDeleteTableSql(@form_process_table)
EXEC (@sql)
SET @sql = dbo.FNAProcessDeleteTableSql(@tab_grid_process_table)
EXEC (@sql)
