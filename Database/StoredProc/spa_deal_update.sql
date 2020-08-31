
IF OBJECT_ID(N'[dbo].[spa_deal_update]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_update]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Generic Stored Procedure to update deals	
	Parameters
	@flag :  
		'h' - Returns JSON of deal header
		'd' - Returns JSON for deal detail
		'e' - TDL
		's' - Updates deal header data and inserts/updates deal detail data according to header and update XML
		't' - Returns Term start and term end data
		'l' - Returns deal lock and term lock status of a deal
		'm' - Return from date and to date of deal according to its term frequency
	@source_deal_header_id :  Source Deal Header Id
	@no_of_columns :  No Of Columns
	@header_xml :  Header Xml with all deal header data
	@detail_xml :  Detail Xml with all deal header data
	@from_date :  From Date
	@to_date :  To Date
	@view_deleted :  flag for View Deleted. 'y' for viewing deleted deals and 'n' for hiding deleted deals
*/

CREATE PROCEDURE [dbo].[spa_deal_update]
    @flag NCHAR(1),
    @source_deal_header_id INT,
    @no_of_columns INT = 50,
    @header_xml XML = NULL,
    @detail_xml XML = NULL,
    @from_date DATETIME = NULL,
    @to_date DATETIME = NULL,
    @view_deleted NCHAR(1) = 'n'
AS
SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX)
DECLARE @process_id NVARCHAR(200) = dbo.FNAGetNewId()
DECLARE @user_name NVARCHAR(100) = dbo.FNADBUser()
DECLARE @formula_present INT

DECLARE @template_id           INT,
	    @field_template_id     INT,
	    @term_frequency		   NCHAR(1)

IF @view_deleted = 'n'
BEGIN
	SELECT @template_id = sdht.template_id,
		   @field_template_id = sdht.field_template_id
	FROM source_deal_header sdh 
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id 
	WHERE sdh.source_deal_header_id = @source_deal_header_id
END	
ELSE
BEGIN
	SELECT @template_id = sdht.template_id,
		   @field_template_id = sdht.field_template_id
	FROM delete_source_deal_header sdh 
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id 
	WHERE sdh.source_deal_header_id = @source_deal_header_id
END

DECLARE @name           NVARCHAR(200),
        @sql_string     NVARCHAR(2000),
        @deal_value     NVARCHAR(2000),
        @is_required	NVARCHAR(10)

IF @flag = 'h'
BEGIN
	IF OBJECT_ID('tempdb..#temp_deal_tabs') IS NOT NULL
		DROP TABLE #temp_deal_tabs
	
	CREATE TABLE #temp_deal_tabs (id INT, [text] NVARCHAR(500) COLLATE DATABASE_DEFAULT, active NVARCHAR(20) COLLATE DATABASE_DEFAULT, seq_no INT)
	
	DECLARE @min_seq_no INT
	SELECT @min_seq_no = MIN(seq_no)
    FROM maintain_field_template_group
    WHERE field_template_id = @field_template_id
    
	INSERT INTO #temp_deal_tabs (id, [text], active, seq_no)
    SELECT field_group_id,
           group_name,
           CASE WHEN seq_no = @min_seq_no THEN 'true' ELSE NULL END,
           seq_no
    FROM maintain_field_template_group
    WHERE field_template_id = @field_template_id 
    ORDER BY seq_no 
        
    --- call from Template window then return only those fields which are in Deal Templates
	SELECT column_name INTO #temp_header FROM INFORMATION_SCHEMA.Columns WHERE TABLE_NAME = 'source_deal_header_template' 
	
	INSERT INTO #temp_header
	SELECT 'sub_book' 
	
	IF OBJECT_ID('tempdb..#temp_deal_header_fields') IS NOT NULL
		DROP TABLE #temp_deal_header_fields
	
	CREATE TABLE #temp_deal_header_fields(
		[name]               NVARCHAR(200) COLLATE DATABASE_DEFAULT,
		group_id             NVARCHAR(200) COLLATE DATABASE_DEFAULT,
		[label]              NVARCHAR(200) COLLATE DATABASE_DEFAULT,
		[type]               NVARCHAR(20) COLLATE DATABASE_DEFAULT,
		[data_type]          NVARCHAR(20) COLLATE DATABASE_DEFAULT,
		[default_validation] NVARCHAR(200) COLLATE DATABASE_DEFAULT,
		[header_detail]		 NVARCHAR(200) COLLATE DATABASE_DEFAULT,
		[required]           NVARCHAR(20) COLLATE DATABASE_DEFAULT,
		[sql_string]         NVARCHAR(2000) COLLATE DATABASE_DEFAULT,
		[dropdown_json]      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		[disabled]           NVARCHAR(20) COLLATE DATABASE_DEFAULT,
		window_function_id	 NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		[inputWidth]         NVARCHAR(20) COLLATE DATABASE_DEFAULT,
		[labelWidth]         NVARCHAR(20) COLLATE DATABASE_DEFAULT,
		[udf_or_system]      NCHAR(1) COLLATE DATABASE_DEFAULT,
		[seq_no]             INT,
		[hidden]             NVARCHAR(10) COLLATE DATABASE_DEFAULT,
		[deal_value]		 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		[field_id]			 NVARCHAR(20) COLLATE DATABASE_DEFAULT,
		[update_required]	 NVARCHAR(10) COLLATE DATABASE_DEFAULT,
		[value_required]     NVARCHAR(10) COLLATE DATABASE_DEFAULT,
		[block]				 INT
	)
	
	CREATE TABLE #temp_deal_values	 (
		sno     INT IDENTITY(1, 1),
		field_name     NVARCHAR(150) COLLATE DATABASE_DEFAULT,
		field_value  NVARCHAR(200) COLLATE DATABASE_DEFAULT
	)
	
	DECLARE @where NVARCHAR(200) SET @where = 'source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(10)) 

	IF @view_deleted = 'n'
	BEGIN
		INSERT INTO #temp_deal_values
		EXEC spa_Transpose 'source_deal_header', @where
	END
	ELSE
	BEGIN
		INSERT INTO #temp_deal_values
		EXEC spa_Transpose 'delete_source_deal_header', @where
		
		INSERT INTO #temp_deal_values(field_name, field_value)
		SELECT 'sub_book', ssbm.book_deal_type_map_id
		FROM delete_source_deal_header dsdh 
		LEFT JOIN source_system_book_map ssbm
			ON ssbm.source_system_book_id1 = dsdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = dsdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = dsdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = dsdh.source_system_book_id4
		WHERE dsdh.source_deal_header_id = @source_deal_header_id
		
	END	
		
	CREATE TABLE #temp_deal_udf_values(
		sno             INT IDENTITY(1, 1),
		field_name      NVARCHAR(150) COLLATE DATABASE_DEFAULT,
		field_value     NVARCHAR(2000) COLLATE DATABASE_DEFAULT
	)
		
	SET @sql = 'INSERT INTO #temp_deal_udf_values (field_name, field_value)
				SELECT CAST(uddf.udf_template_id AS NVARCHAR(20)), CAST(uddf.udf_value AS NVARCHAR(2000))
				FROM user_defined_deal_fields_template uddft    
				INNER JOIN ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'user_defined_deal_fields uddf
					ON  uddft.udf_template_id = uddf.udf_template_id
					AND uddf.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '
				WHERE uddft.template_id = ' + CAST(@template_id AS NVARCHAR(20))
	EXEC(@sql)
		
	SET @sql = 'INSERT INTO #temp_deal_header_fields ([name], group_id, [label], [type], [data_type], [default_validation], [header_detail], [required], [sql_string], [inputWidth], [labelWidth],  [disabled], window_function_id, [udf_or_system], [seq_no], [hidden], [deal_value], [field_id], [update_required], [value_required], [block])
				SELECT *, ROW_NUMBER() OVER(PARTITION BY field_group_id ORDER BY ISNULL(seq_no, 10000), default_label)% ' + CAST(@no_of_columns AS NVARCHAR(10)) + ' 
	            FROM   (
	                       SELECT LOWER(f.farrms_field_id) farrms_field_id,
	                              field_group_id,
	                              CASE WHEN NULLIF(f.window_function_id, '''') IS NOT NULL THEN 
										CASE WHEN d.field_caption = ''book1'' THEN ''<a id=''''''+CAST(f.window_function_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(f.window_function_id AS NVARCHAR(20))+'',this.id);''''>Group 1</a>'' 
											WHEN d.field_caption = ''book2'' THEN ''<a id=''''''+CAST(f.window_function_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(f.window_function_id AS NVARCHAR(20))+'',this.id);''''>Group 2</a>'' 
											WHEN d.field_caption = ''book3'' THEN ''<a id=''''''+CAST(f.window_function_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(f.window_function_id AS NVARCHAR(20))+'',this.id);''''>Group 3</a>'' 
											WHEN d.field_caption = ''book4'' THEN ''<a id=''''''+CAST(f.window_function_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(f.window_function_id AS NVARCHAR(20))+'',this.id);''''>Group 4</a>'' 
										ELSE
											''<a id=''''''+CAST(f.farrms_field_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(f.window_function_id AS NVARCHAR(20))+'',this.id);''''>''+ISNULL(d.field_caption, f.default_label)+''</a>'' 
										END
								   ELSE
										CASE WHEN d.field_caption = ''book1'' THEN ''Group1''
											WHEN d.field_caption = ''book2'' THEN ''Group2'' 
											WHEN d.field_caption = ''book3'' THEN ''Group3''
											WHEN d.field_caption = ''book4'' THEN ''Group4''
										  ELSE ISNULL(d.field_caption, f.default_label) 
										END
								  END default_label,
	                              ISNULL(f.field_type, ''t'') field_type,
	                              f.[data_type],
	                              f.[default_validation],
	                              f.[header_detail],
	                              ISNULL(d.value_required, ''n'') required,
	                              f.[sql_string],
	                              f.[field_size],
	                              CAST(f.[field_size] AS INT) + 10 labelWidth,
	                              COALESCE(d.is_disable, f.is_disable, ''n'') is_disable,
	                              f.window_function_id,
	                              ''s'' udf_or_system,
	                              ISNULL(d.seq_no, 1000) seq_no,
	                              ISNULL(d.hide_control, ''n'') hide_control,
	                              dv.field_value deal_value,
	                              CAST(f.field_id AS NVARCHAR) field_id,
	                              d.update_required,
	                              CASE WHEN d.value_required = ''y'' THEN ''true'' ELSE ''false'' END value_required
	                       FROM maintain_field_template_detail d
	                       INNER JOIN maintain_field_deal f ON  d.field_id = f.field_id
	                       INNER join #temp_header t on case when t.column_name=''buy_sell_flag'' then ''header_buy_sell_flag'' else t.column_name end = f.farrms_field_id
	                       INNER JOIN #temp_deal_values dv ON CASE WHEN dv.field_name = ''buy_sell_flag'' THEN ''header_buy_sell_flag'' ELSE dv.field_name END = f.farrms_field_id
	                       WHERE field_group_id IS NOT NULL 
						   AND f.header_detail=''h'' 
						   AND ISNULL(d.update_required, f.update_required) = ''y'' 
						   AND ISNULL(d.udf_or_system,''s'') = ''s'' 
						   AND d.field_template_id = ' + CAST(@field_template_id AS NVARCHAR(500))
	
	SET @sql = @sql + '	
	UNION ALL 	
	SELECT ''UDF___'' + CAST(udf_temp.udf_template_id AS NVARCHAR) udf_template_id,
	       field_group_id,
	       CASE WHEN NULLIF(udf_temp.window_id, '''') IS NOT NULL THEN 
		   ''<a id=''''UDF___''+CAST(udf_temp.udf_template_id AS NVARCHAR)+'''''' href=''''javascript:void(0);'''' onclick=''''call_TRMWinHyperlink(''+CAST(udf_temp.window_id AS NVARCHAR(20))+'',this.id);''''>''+ISNULL(mftd.field_caption, udf_temp.Field_label)+''</a>''
	       ELSE
				ISNULL(mftd.field_caption, udf_temp.Field_label) 
		   END default_label,
	       ISNULL(udf_temp.field_type, ''t'') field_type,
	       udf_temp.[data_type],
	       NULL [default_validation],
	       ''h'' header_detail,
	       ISNULL(mftd.value_required, udf_temp.is_required) required,
	       ISNULL(NULLIF(udf_temp.sql_string, ''''), uds.sql_string) sql_string,
	       udf_temp.[field_size],
	       CAST(udf_temp.[field_size] AS INT) + 10,
	       ISNULL(mftd.is_disable, ''n''),
	       udf_temp.window_id window_function_id,
	       ''u'' udf_or_system,
	       ISNULL(mftd.seq_no, 1000) seq_no,
	       ISNULL(mftd.hide_control, ''n'') hide_control,
	       CASE WHEN tduf.field_name IS NULL THEN mftd.default_value ELSE tduf.field_value END,
	       ''u--''+cast(mftd.field_id as NVARCHAR) field_id,
	        mftd.update_required,
	        CASE WHEN mftd.value_required = ''y'' THEN ''true'' ELSE ''false'' END value_required
	FROM user_defined_fields_template udf_temp
	INNER JOIN maintain_field_template_detail mftd
	    ON  udf_temp.udf_template_id = mftd.field_id 
	    AND mftd.field_template_id = ' + CAST(@field_template_id AS NVARCHAR(20)) +'
	    AND ISNULL(mftd.udf_or_system, ''s'') = ''u''
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_id = udf_temp.field_id AND uddft.template_id = ' + CAST(@template_id AS NVARCHAR(20)) + '
	LEFT JOIN #temp_deal_udf_values tduf ON uddft.udf_template_id = tduf.field_name
	LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udf_temp.data_source_type_id  	      
	WHERE field_group_id IS NOT NULL
	AND udf_temp.udf_type = ''h''
	AND ISNULL(mftd.update_required, ''n'') = ''y'''
	
	SET @sql = @sql + ') a ORDER BY field_group_id,ISNULL(a.seq_no, 10000), default_label' 
	exec spa_print @sql
	EXEC(@sql)
	
	DECLARE dropdown_cursor CURSOR FORWARD_ONLY READ_ONLY 
	FOR
		SELECT name,
			   sql_string,
			   deal_value,
			   value_required           
		FROM #temp_deal_header_fields
		WHERE [type] IN ('d', 'c') AND sql_string IS NOT NULL

	OPEN dropdown_cursor
	FETCH NEXT FROM dropdown_cursor INTO @name, @sql_string, @deal_value, @is_required                                        
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @json NVARCHAR(max)
		DECLARE @nsql NVARCHAR(MAX)	
		SET @json = NULL
		
		IF @name <> 'contract_id' AND @name <> 'counterparty_id'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_combo') IS NOT NULL
				DROP TABLE #temp_combo
	
			CREATE TABLE #temp_combo ([value] NVARCHAR(10) COLLATE DATABASE_DEFAULT, [text] NVARCHAR(1000) COLLATE DATABASE_DEFAULT, selected NVARCHAR(10) COLLATE DATABASE_DEFAULT)
			IF @is_required = 'false'
			BEGIN
				INSERT INTO #temp_combo([value], [text])
				SELECT '', ''
			END
		
			DECLARE @type NCHAR(1)
			SET @type = SUBSTRING(@sql_string, 1, 1)
		
			IF @type = '['
			BEGIN
				SET @sql_string = REPLACE(@sql_string, NCHAR(13), '')
				SET @sql_string = REPLACE(@sql_string, NCHAR(10), '')
				SET @sql_string = REPLACE(@sql_string, NCHAR(32), '')	
				SET @sql_string = [dbo].[FNAParseStringIntoTable](@sql_string)  
				EXEC('INSERT INTO #temp_combo([value], [text])
					  SELECT value_id, code from (' + @sql_string + ') a(value_id, code)');
			END 
			ELSE
			BEGIN
				INSERT INTO #temp_combo([value], [text])
				EXEC(@sql_string)
			END
	
			UPDATE #temp_combo
			SET selected = 'true'			
			WHERE value = @deal_value
		
			IF NOT EXISTS (SELECT 1 FROM #temp_combo WHERE value = @deal_value)
			BEGIN
				UPDATE #temp_deal_header_fields
				SET deal_value = NULL
				WHERE name = @name
			END			
	
			DECLARE @dropdown_xml XML
			DECLARE @param NVARCHAR(100)
			SET @param = N'@dropdown_xml XML OUTPUT';

			SET @nsql = ' SET @dropdown_xml = (SELECT [value], [text], [selected]
							FROM #temp_combo 
							FOR XML RAW (''row''), ROOT (''root''), ELEMENTS)'
	
			EXECUTE sp_executesql @nsql, @param, @dropdown_xml = @dropdown_xml OUTPUT;
	
			SET @json = dbo.FNAFlattenedJSON(@dropdown_xml)
		END
		ELSE 
		BEGIN			
			EXEC spa_deal_fields_mapping @flag='c',@deal_id=@source_deal_header_id,@deal_fields=@name,@default_value=@deal_value, @json_string = @json output
		END
		
		IF CHARINDEX('[', @json, 0) <= 0
			SET @json = '[' + @json + ']'

		UPDATE #temp_deal_header_fields
		SET dropdown_json = @json
		WHERE [name] = @name
			
		FETCH NEXT FROM dropdown_cursor INTO @name, @sql_string, @deal_value, @is_required    
	END
	CLOSE dropdown_cursor
	DEALLOCATE dropdown_cursor

	IF OBJECT_ID('tempdb..#temp_deal_header_form_json') IS NOT NULL
		DROP TABLE #temp_deal_header_form_json
	
	CREATE TABLE #temp_deal_header_form_json(
		tab_id		  NVARCHAR(10) COLLATE DATABASE_DEFAULT,
		tab_json      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		form_json     NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		tab_seq		  INT
	)
	
	DECLARE @tab_id INT, @tab_seq INT
    DECLARE tab_cursor CURSOR FORWARD_ONLY READ_ONLY 
	FOR
		SELECT id, seq_no          
		FROM #temp_deal_tabs 
		ORDER BY seq_no
	OPEN tab_cursor
	FETCH NEXT FROM tab_cursor INTO @tab_id, @tab_seq                                      
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @tab_form_json NVARCHAR(MAX) = '',
		        @tab_xml      NVARCHAR(MAX)
		
		DECLARE @setting_xml NVARCHAR(2000)
		SET @setting_xml = (
							SELECT 'settings' [type],
							       'label-top' [position],
								   '250' labelWidth,
								   '240' inputWidth
							FOR xml RAW('formxml'), ROOT('root'), ELEMENTS
		)
		SELECT @tab_form_json = '[' + dbo.FNAFlattenedJSON(@setting_xml)
		        
		SET @tab_xml = (
			SELECT [id],
				   [text],
				   active
			FROM #temp_deal_tabs
			WHERE id = @tab_id
			FOR xml RAW('tab'), ROOT('root'), ELEMENTS
		)

		DECLARE @block_id INT
		DECLARE block_cursor CURSOR FORWARD_ONLY READ_ONLY 
		FOR
			SELECT block         
			FROM #temp_deal_header_fields
			WHERE group_id = @tab_id
			GROUP BY block
			ORDER BY ISNULL(NULLIF(block, 0), 100)
		OPEN block_cursor
		FETCH NEXT FROM block_cursor INTO @block_id                                      
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @form_xml NVARCHAR(MAX)			
			DECLARE @block_json NVARCHAR(2000) = '{type:"block", blockOffset:20, list:'

			SET @form_xml = (   
							SELECT CASE [type]
										WHEN 'c' THEN 'combo'
										WHEN 'd' THEN 'combo'
										WHEN 'l' THEN 'input'
										WHEN 't' THEN 'input'
										WHEN 'a' THEN 'calendar'
										WHEN 'w' THEN 'win_link'
									END [type],
									CASE [type]
										WHEN 'c' THEN 'true'
										WHEN 'd' THEN 'true'
										ELSE NULL
									END filtering,
									CASE [type]
										WHEN 'c' THEN 'between'
										WHEN 'd' THEN 'between'
										ELSE NULL
									END filtering_mode,
									name,
									label,
									CASE 
										WHEN [required] = 'y' THEN 'true'
										ELSE 'false'
									END [required],
									dropdown_json AS [options],
									CASE 
										WHEN [disabled] = 'y' THEN 'true'
										ELSE 'false'
									END [disabled],
									inputWidth,
									labelWidth,
									CASE 
										WHEN [hidden] = 'y' THEN 'true'
										ELSE 'false'
									END [hidden],
									CASE WHEN name IN ('update_ts', 'create_ts') THEN dbo.FNAGetSQLStandardDateTime(deal_value) ELSE CASE WHEN [type] = 'a' THEN dbo.FNAGetSQLStandardDate(deal_value) ELSE deal_value END END AS [value],
									NULL [position],
									seq_no,
									CASE WHEN [type] = 'a' THEN '%Y-%m-%d' ELSE NULL END + CASE WHEN name IN ('update_ts', 'create_ts') THEN ' %H:%i:%s' ELSE '' END [serverDateFormat],
									CASE WHEN [type] = 'a' THEN COALESCE(dbo.FNAChangeDateFormat(), '%Y-%m-%d') ELSE NULL END + CASE WHEN name IN ('update_ts', 'create_ts') THEN ' %H:%i:%s' ELSE '' END [dateFormat],
									CASE WHEN value_required = 'true' THEN 'NotEmptywithSpace' ELSE NULL END + CASE WHEN data_type = 'int' THEN ',ValidInteger' WHEN data_type IN ('price','number') THEN ',ValidNumeric' ELSE '' END [validate],
									CASE WHEN value_required = 'true' THEN '{"validation_message": "Invalid data"}' ELSE NULL END [userdata]
							FROM #temp_deal_header_fields
							WHERE group_id = @tab_id
							AND block = @block_id	
							ORDER BY seq_no								
							FOR xml RAW('formxml'), ROOT('root'), ELEMENTS
			)
			
			DECLARE @temp_form_json NVARCHAR(MAX) = dbo.FNAFlattenedJSON(@form_xml)
			IF SUBSTRING(@temp_form_json, 1, 1) <> '['
			BEGIN
				SET @temp_form_json = '[' + @temp_form_json + ']'
			END
			
			SET @tab_form_json = COALESCE(@tab_form_json + ',', '') + @block_json + @temp_form_json + '},{type:"newcolumn"}'
			FETCH NEXT FROM block_cursor INTO @block_id   
		END
		CLOSE block_cursor
		DEALLOCATE block_cursor
		
		SET @tab_form_json = @tab_form_json + ']'
		
		INSERT INTO #temp_deal_header_form_json
		SELECT @tab_id, dbo.FNAFlattenedJSON(@tab_xml), @tab_form_json, @tab_seq
	FETCH NEXT FROM tab_cursor INTO @tab_id, @tab_seq   
	END
	CLOSE tab_cursor
	DEALLOCATE tab_cursor
	
	SELECT * FROM #temp_deal_header_form_json ORDER by tab_seq
END
ELSE IF @flag = 'd' OR @flag = 'e'
BEGIN
	DECLARE @buy_sell_flag_check NCHAR(1)
	
	IF @view_deleted = 'n'
	BEGIN
		SELECT @buy_sell_flag_check = buy_sell_flag FROM source_deal_detail WHERE Leg = 1 AND source_deal_header_id = @source_deal_header_id
	END
	ELSE
	BEGIN
		SELECT @buy_sell_flag_check = buy_sell_flag FROM delete_source_deal_detail WHERE Leg = 1 AND source_deal_header_id = @source_deal_header_id
	END	
	
	IF OBJECT_ID('tempdb..#field_template_collection') IS NOT NULL
		DROP TABLE #field_template_collection  
		
	CREATE TABLE #field_template_collection (
		[id]  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		default_label    NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		seq_no           INT,
		field_id         NVARCHAR(50) COLLATE DATABASE_DEFAULT,
		field_type       NVARCHAR(50) COLLATE DATABASE_DEFAULT,
		leg              INT,
		udf_or_system    NCHAR(1) COLLATE DATABASE_DEFAULT,
		hide_control     NVARCHAR(50) COLLATE DATABASE_DEFAULT,
		sql_string		 NVARCHAR(2000) COLLATE DATABASE_DEFAULT,
		json_data		 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		[disabled]		 NVARCHAR(10) COLLATE DATABASE_DEFAULT,
		deal_value		 NVARCHAR(2000) COLLATE DATABASE_DEFAULT,
		field_size		 NVARCHAR(20) COLLATE DATABASE_DEFAULT,
		data_type		 NVARCHAR(20) COLLATE DATABASE_DEFAULT,
		is_required		 NVARCHAR(10) COLLATE DATABASE_DEFAULT
	)
	
	INSERT INTO #field_template_collection([id], default_label, seq_no, field_id, field_type, leg, udf_or_system, hide_control, sql_string, [disabled], field_size, data_type, is_required)
	SELECT *
	FROM   (
			SELECT  CASE 
			             WHEN mftd.display_format = 19204 AND mftd.display_format IS NOT NULL THEN 'dbo.FNAGetDisplayFormatVolume(' + mfd.farrms_field_id + ', NULL, ' + CAST(sdht.template_id AS NVARCHAR(100)) + ', ''' + mfd.farrms_field_id + ''')'
			             ELSE mfd.farrms_field_id
			        END AS farrms_field_id,
					CASE 
					     WHEN @buy_sell_flag_check = 's' THEN ISNULL(NULLIF(mftd.sell_label, ''), mftd.field_caption)
					     WHEN @buy_sell_flag_check = 'b' THEN ISNULL(NULLIF(mftd.buy_label, ''), mftd.field_caption)
					     ELSE mftd.field_caption
					END default_label,
					ISNULL(mftd.deal_update_seq_no, seq_no) seq_no,
					CAST(mfd.field_id AS NVARCHAR) field_id,
					mfd.field_type,
					NULL AS leg,
					's' udf_or_system,
					CASE WHEN ISNULL(mftd.hide_control,'n') = 'n' THEN 'false' ELSE 'true' END hide_control,
					mfd.sql_string,
					CASE WHEN ISNULL(mftd.is_disable, mfd.is_disable) = 'y' THEN 'true' ELSE NULL END [disabled],
					mfd.field_size,
					mfd.data_type,
					CASE WHEN mftd.value_required = 'y' THEN 'true' ELSE 'false' END value_required
			FROM maintain_field_deal mfd
			INNER JOIN maintain_field_template_detail mftd ON  mftd.field_id = mfd.field_id
			INNER JOIN dbo.source_deal_header_template sdht ON sdht.field_template_id = mftd.field_template_id 
			WHERE mfd.header_detail = 'd'
				AND mftd.field_template_id = @field_template_id
				AND sdht.template_id = @template_id
				AND ISNULL(mftd.udf_or_system, 's') = 's'
				AND ISNULL(mftd.hide_control, 'n') = 'n' 
				AND ISNULL(mftd.update_required, 'n') = 'y' 
			UNION ALL 
			SELECT  'UDF___' + CAST(udft.udf_template_id AS NVARCHAR) udf_template_id,
					CASE 
					     WHEN @buy_sell_flag_check = 's' THEN ISNULL(NULLIF(mftd.sell_label, ''), mftd.field_caption)
					     WHEN @buy_sell_flag_check = 'b' THEN ISNULL(NULLIF(mftd.buy_label, ''), mftd.field_caption)
					     ELSE mftd.field_caption
					END default_label,
					ISNULL(mftd.deal_update_seq_no, seq_no) seq_no,
					CAST(udft.udf_template_id AS NVARCHAR) field_id,
					udft.field_type field_type,
					uddft.leg,
					'u' udf_or_system,
					CASE WHEN ISNULL(mftd.hide_control,'n') = 'n' THEN 'false' ELSE 'true' END hide_control,
					ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string) sql_string,
					CASE WHEN mftd.is_disable = 'y' THEN 'true' ELSE NULL END [disabled],
					udft.field_size,
					udft.data_type,
					CASE WHEN mftd.value_required = 'y' THEN 'true' ELSE 'false' END value_required
			FROM   maintain_field_template_detail mftd
			INNER JOIN user_defined_fields_template udft
				ON  mftd.field_id = udft.udf_template_id
				AND mftd.udf_or_system = 'u'
			INNER JOIN user_defined_deal_fields_template uddft
				ON  uddft.field_name = udft.field_name
				AND uddft.template_id = @template_id
			LEFT JOIN udf_data_source uds 
				ON uds.udf_data_source_id = udft.data_source_type_id
			WHERE  udft.udf_type = 'd'
					AND mftd.field_template_id = @field_template_id
					AND uddft.leg = 1
					AND ISNULL(mftd.update_required, 'n') = 'y' 
	) l 
	ORDER BY ISNULL(l.seq_no, 10000)
	
    DECLARE detail_dropdown_cursor CURSOR FORWARD_ONLY READ_ONLY 
	FOR
		SELECT [id],
			   sql_string,
			   is_required         
		FROM #field_template_collection
		WHERE field_type IN ('d', 'c') AND sql_string IS NOT NULL
	OPEN detail_dropdown_cursor
	FETCH NEXT FROM detail_dropdown_cursor INTO @name, @sql_string, @is_required                                      
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @d_json NVARCHAR(MAX)
		DECLARE @d_nsql NVARCHAR(MAX)
		SET @d_json = NULL
		
		IF @name <> 'location_id' AND @name <> 'curve_id' AND @name <> 'formula_curve_id'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_detail_combo') IS NOT NULL
				DROP TABLE #temp_detail_combo
	
			CREATE TABLE #temp_detail_combo ([value] NVARCHAR(10) COLLATE DATABASE_DEFAULT, [text] NVARCHAR(1000) COLLATE DATABASE_DEFAULT)
		
			IF @is_required = 'false'
			BEGIN
				INSERT INTO #temp_detail_combo([value], [text])
				SELECT '', ''
			END
		 
			INSERT INTO #temp_detail_combo([value], [text])
			EXEC(@sql_string)
		
			DECLARE @d_dropdown_xml XML
			DECLARE @d_param NVARCHAR(100)
		
			SET @d_param = N'@d_dropdown_xml XML OUTPUT';
			SET @d_nsql = ' SET @d_dropdown_xml = (SELECT [value], [text]
							FROM #temp_detail_combo 
							FOR XML RAW (''row''), ROOT (''root''), ELEMENTS)'
	
			EXECUTE sp_executesql @d_nsql, @d_param, @d_dropdown_xml = @d_dropdown_xml OUTPUT;
			SET @d_json = dbo.FNAFlattenedJSON(@d_dropdown_xml)
			
		END
		ELSE
		BEGIN
			EXEC spa_deal_fields_mapping @flag='c',@deal_id=@source_deal_header_id,@deal_fields=@name,@json_string = @d_json output
		END 

		IF CHARINDEX('[', @d_json, 0) <= 0
			SET @d_json = '[' + @d_json + ']'

		SET @d_json = '{"options":' + @d_json + '}' 
				
		UPDATE #field_template_collection
		SET json_data = @d_json
		WHERE [id] = @name
			
		FETCH NEXT FROM detail_dropdown_cursor INTO @name, @sql_string, @is_required  
	END
	CLOSE detail_dropdown_cursor
	DEALLOCATE detail_dropdown_cursor
	
	DECLARE @field_detail             NVARCHAR(MAX),
	        @field_temp_detail        NVARCHAR(MAX),
	        @field_process_detail     NVARCHAR(MAX),
	        @detail_grid_labels       NVARCHAR(MAX),
	        @max_detail_seq           INT,
	        @dummy_detail_value       NVARCHAR(MAX),
	        @detail_combo_list        NVARCHAR(MAX),
	        @udf_value                NVARCHAR(MAX),
	        @udf_field_id             NVARCHAR(MAX),
	        @final_select             NVARCHAR(MAX),
	        @header_menu              NVARCHAR(MAX),
	        @filter_list              NVARCHAR(MAX),
	        @validation_rule          NVARCHAR(MAX)
			
	
	SELECT @max_detail_seq = MAX(seq_no)
	FROM #field_template_collection
	
	SELECT  
	@field_detail = COALESCE(@field_detail + ',', '') + CAST(id AS NVARCHAR(150)) + ' NVARCHAR(MAX) ',
	@field_temp_detail = CASE WHEN ft.udf_or_system = 'u' THEN @field_temp_detail ELSE COALESCE(@field_temp_detail + ',', '') + 'sdd.' + id END,
	@field_process_detail = CASE WHEN ft.udf_or_system = 'u' THEN @field_process_detail ELSE COALESCE(@field_process_detail + ',', '') + id END,
	@detail_grid_labels = COALESCE(@detail_grid_labels + ',', '') + '{"id":"' + id + '", "hidden":' +  hide_control + ', "align":"left"' +
						  ',"sort":"' +  CASE WHEN field_type = 'a' THEN 'date' ELSE 'str' END + '"' +
						  ', "width":"' + CASE WHEN field_type = 'a' THEN '160' ELSE ISNULL(field_size, '150') END + '"' +
						  ', "type":"' + CASE 
											 WHEN data_type = 'price' AND ISNULL([disabled], 'false') = 'true' THEN 'ro_p'
											 WHEN data_type = 'number' AND ISNULL([disabled], 'false') = 'true' THEN 'ro_no'
											 WHEN data_type = 'price' THEN 'ed_p'
											 WHEN data_type = 'number' THEN 'ed_no'
											 ELSE  CASE field_type
														WHEN 'c' THEN CASE WHEN ISNULL([disabled], 'false') = 'true' THEN 'ro_combo' ELSE 'combo' END
														WHEN 'd' THEN CASE WHEN ISNULL([disabled], 'false') = 'true' THEN 'ro_combo' ELSE 'combo' END
														WHEN 't' THEN CASE WHEN ISNULL([disabled], 'false') = 'true' THEN 'ro' ELSE 'ed' END
														WHEN 'a' THEN CASE WHEN ISNULL([disabled], 'false') = 'true' THEN 'ro_dhxCalendarA' ELSE 'dhxCalendarA' END
														WHEN 'w' THEN CASE WHEN ISNULL([disabled], 'false') = 'true' THEN 'ro_win_link' ELSE 'win_link' END
														ELSE 'ro'
													END
										END + '"' +
						  CASE WHEN data_type IN ('price', 'number') THEN ',"format":"0,000.00" ' ELSE '' END + 
						  ', "value":"' + ft.default_label + '"' +
						  CASE WHEN field_type = 'a' THEN ', "dateFormat":"__DATEFORMAT__"' ELSE '' END +
						  + '}',
	@detail_combo_list = CASE WHEN ft.field_type IN ('d', 'c')  AND ft.json_data IS NOT NULL THEN COALESCE(@detail_combo_list + '||||', '') + ft.id + '::::' + ft.json_data ELSE @detail_combo_list END,
	@dummy_detail_value = COALESCE(@dummy_detail_value + ',', '') + '""',
	@udf_value = CASE WHEN ft.udf_or_system = 's' THEN @udf_value ELSE COALESCE(@udf_value + ', ', '') + CAST(ft.id AS NVARCHAR) + '= u.[' + CAST(ft.field_id AS NVARCHAR) + ']' END,
	@udf_field_id = CASE WHEN ft.udf_or_system = 's' THEN @udf_field_id ELSE COALESCE(@udf_field_id + ', ', '') + '[' + CAST(ft.field_id AS NVARCHAR) + ']' END,
	@final_select = COALESCE(@final_select + ',', '') + CASE WHEN field_type = 'a' THEN 'dbo.FNAGetSQLStandardDate(sdd.' + id + ')' WHEN data_type IN ('price', 'number') THEN 'dbo.FNARemoveTrailingZeroes(NULLIF(sdd.' + id + ', ''''))' ELSE 'sdd.' + id END + ' AS [' + ft.default_label + ']',
	@header_menu = COALESCE(@header_menu + ',', '') + 'true',
	@filter_list = COALESCE(@filter_list + ',', '') + CASE WHEN field_type = 'c' THEN '#combo_filter' WHEN field_type = 'a' THEN '#daterange_filter' ELSE '#text_filter' END,
	@validation_rule = COALESCE(@validation_rule + ',', '') + CASE WHEN ft.is_required = 'true' AND data_type IN ('price', 'number') THEN 'ValidNumeric' WHEN ft.is_required = 'true' THEN 'NotEmpty' ELSE CASE WHEN data_type IN ('price', 'number') THEN 'ValidNumericWithEmpty'  ELSE '' END END 
	FROM #field_template_collection ft
	WHERE id <> 'source_deal_detail_id'
	ORDER BY ft.seq_no
	
	SET @detail_grid_labels = '{"head":[{"id": "blotterleg", "align":"left", "offsetLeft":0, "hidden": true, "width": 50, "type": "ro", "value":""},{"id": "source_deal_detail_id", "align":"left", "offsetLeft":0, "hidden": true, "width": 50, "type": "ro", "value":"ID"},' + @detail_grid_labels + '],"rows":[{"id":1, "data":[' + @dummy_detail_value + ']}]}'
	SET @filter_list = '#text_filter,#text_filter,' + @filter_list
	SET @validation_rule = ',,' + @validation_rule
	DECLARE @date_format NVARCHAR(20) = COALESCE(dbo.FNAChangeDateFormat(), '%Y-%m-%d')
	
	SET @detail_grid_labels = REPLACE(@detail_grid_labels, '__DATEFORMAT__', @date_format)

	DECLARE @deal_update_detail NVARCHAR(200)
	
	IF OBJECT_ID('tempdb..#temp_uddf') IS NOT NULL
		DROP TABLE #temp_uddf
	
	CREATE TABLE #temp_uddf (
		udf_template_id INT,
		source_deal_detail_id INT,
		udf_value NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
	)
	
	SET @sql = '	INSERT INTO #temp_uddf
					SELECT udft2.udf_template_id,
						   uddf.source_deal_detail_id,
						   CASE 
								WHEN udft.Field_type = ''a'' THEN dbo.FNAGetSQLStandardDate(uddf.udf_value)
								WHEN udft.Field_type = ''c'' AND uddf.udf_value = ''y'' THEN ''Yes''
								WHEN udft.Field_type = ''c'' AND uddf.udf_value = ''n'' THEN ''No''
								ELSE uddf.udf_value
						   END udf_value 
					FROM ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'user_defined_deal_detail_fields uddf
					INNER JOIN user_defined_deal_fields_template udft ON  uddf.udf_template_id = udft.udf_template_id
					INNER JOIN source_deal_detail sdd ON  sdd.source_deal_detail_id = uddf.source_deal_detail_id
					INNER JOIN user_defined_fields_template udft2 ON udft2.field_name = udft.field_name
					WHERE sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20))
	EXEC(@sql)
	
	IF CHARINDEX('source_deal_detail_id', @field_process_detail) = 0
	BEGIN
		SET @field_detail = 'source_deal_detail_id INT, ' + @field_detail
		SET @field_process_detail =  'source_deal_detail_id,' + @field_process_detail
		SET @field_temp_detail = 'source_deal_detail_id, ' + @field_temp_detail
		SET @final_select = 'source_deal_detail_id AS [ID], ' + @final_select
	END
	
	SET @deal_update_detail = dbo.FNAProcessTableName('deal_update_detail', @user_name, @process_id)
	SET @sql = ' 
				CREATE TABLE ' + @deal_update_detail + ' (
					blotterleg INT,
					' + @field_detail + '			
				)
				
				
				INSERT INTO ' + @deal_update_detail + ' (blotterleg, ' + @field_process_detail + ')
				SELECT sdd.leg, ' + @field_temp_detail + '
				FROM ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'source_deal_header sdh 
				INNER JOIN ' + CASE WHEN @view_deleted ='y' THEN 'delete_' ELSE '' END + 'source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				WHERE sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '		
	'
	exec spa_print @sql
	EXEC(@sql)
	
	IF @udf_value IS NOT NULL
	BEGIN
		SET @sql = '
					UPDATE ' + @deal_update_detail + '
					SET    ' + @udf_value + '
					FROM   ' + @deal_update_detail + ' t
					INNER JOIN (
						SELECT *
						FROM   (
							SELECT source_deal_detail_id,
								   udf_template_id,
								   udf_value
							FROM   #temp_uddf
						) src 
						PIVOT(
							MAX(udf_value) FOR udf_template_id   
							IN (' + @udf_field_id + ')
						) AS pvt
					) u
					ON  t.source_deal_detail_id = u.source_deal_detail_id  
		'
	
		exec spa_print @sql
		EXEC(@sql)
	END
	
	DECLARE @select_statement NVARCHAR(MAX)
	SET @select_statement = 'SELECT sdd.blotterleg,  ' + @final_select + ' FROM ' + @deal_update_detail + ' sdd'
	
	SET @formula_present = COL_LENGTH(@deal_update_detail, 'formula_id')
	IF @formula_present IS NOT NULL
	BEGIN
		SET @sql = 'UPDATE temp
					SET formula_id = CAST(fe.formula_id AS NVARCHAR(200)) + ''^'' + dbo.FNAFormulaFormat(fe.formula, ''r'') 
					FROM ' + @deal_update_detail + ' temp
					INNER JOIN formula_editor fe ON CAST(fe.formula_id AS NVARCHAR(2000)) = temp.formula_id'
		EXEC(@sql)
	END
	
	IF @flag = 'd'
	BEGIN
		SELECT @detail_grid_labels [config_json], @detail_combo_list [combo_list], @filter_list [filter_list], @select_statement [data_sp], @validation_rule [validation_rule]
	END
	ELSE
	BEGIN
		EXEC(@select_statement)
	END
END
ELSE IF @flag = 's'
BEGIN
	BEGIN TRAN
	BEGIN TRY
		DECLARE @change_in_buy_sell NCHAR(1)
		
		IF @header_xml IS NOT NULL
		BEGIN
			DECLARE @header_process_table NVARCHAR(200)
			SET @header_process_table = dbo.FNAProcessTableName('header_process_table', @user_name, @process_id)
		
			EXEC spa_parse_xml_file 'b', NULL, @header_xml, @header_process_table
		
			IF OBJECT_ID('tempdb..#temp_header_columns') IS NOT NULL
				DROP TABLE #temp_header_columns
		
			IF OBJECT_ID('tempdb..#temp_sdh') IS NOT NULL
				DROP TABLE #temp_sdh
			
			CREATE TABLE #temp_header_columns (
				columns_name NVARCHAR(200) COLLATE DATABASE_DEFAULT,
				columns_value NVARCHAR(200) COLLATE DATABASE_DEFAULT
			)
			CREATE TABLE #temp_sdh(
				columns_name     NVARCHAR(200) COLLATE DATABASE_DEFAULT,
				data_type        NVARCHAR(200) COLLATE DATABASE_DEFAULT
			)
		
			DECLARE @table_name NVARCHAR(200) = REPLACE(@header_process_table, 'adiha_process.dbo.', '')
		
			INSERT INTO #temp_header_columns	
			EXEC spa_Transpose @table_name, NULL, 1
		
			INSERT INTO #temp_sdh
			SELECT column_name,
				   DATA_TYPE
			FROM INFORMATION_SCHEMA.Columns
			WHERE TABLE_NAME = 'source_deal_header'
		
			DECLARE @update_string NVARCHAR(MAX)
			DECLARE @h_udf_update_string NVARCHAR(MAX)
		
			SELECT @update_string = COALESCE(@update_string + ',', '') + tsdh.columns_name + ISNULL(' = ''' + CASE WHEN tsdh.data_type = 'datetime' THEN dbo.FNAGetSQLStandardDate(thc.columns_value) ELSE CAST(thc.columns_value AS NVARCHAR(2000)) END + '''', '= NULL')
			FROM #temp_header_columns thc
			INNER JOIN #temp_sdh tsdh ON tsdh.columns_name = thc.columns_name
			WHERE tsdh.columns_name NOT IN ('source_deal_header_id', 'update_ts', 'update_user', 'create_ts', 'create_user')
			AND thc.columns_name NOT LIKE '%UDF___%'
			
			DECLARE @prior_buy_sell NCHAR(1), @prior_sub_book INT
			SELECT @prior_buy_sell = header_buy_sell_flag,
				   @prior_sub_book = sub_book
			FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id
			
			SET @sql = '
						UPDATE sdh
						SET ' + @update_string + '
						FROM source_deal_header sdh 
						WHERE sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + '					
					   '
			exec spa_print @sql
			EXEC(@sql)
			
			DECLARE @after_buy_sell NCHAR(1), @after_sub_book INT
			SELECT @after_buy_sell = header_buy_sell_flag,
				   @after_sub_book = sub_book
			FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id
			
			IF @prior_buy_sell = @after_buy_sell
				SET @change_in_buy_sell = 'n' 
			ELSE 
				SET @change_in_buy_sell = 'y'
			
			
			IF @prior_sub_book <> @after_sub_book
			BEGIN
				UPDATE sdh
				SET source_system_book_id1 = ssbm.source_system_book_id1,
					source_system_book_id2 = ssbm.source_system_book_id2,
					source_system_book_id3 = ssbm.source_system_book_id3,
					source_system_book_id4 = ssbm.source_system_book_id4
				FROM source_deal_header sdh
				INNER JOIN source_system_book_map ssbm
					ON sdh.sub_book = ssbm.book_deal_type_map_id
				WHERE sdh.source_deal_header_id = @source_deal_header_id
			END
			-- update UDF
			UPDATE uddf
			SET udf_value = thc.columns_value
			FROM user_defined_deal_fields_template uddft
			INNER JOIN user_defined_deal_fields uddf
				ON uddft.udf_template_id = uddf.udf_template_id
				AND uddf.source_deal_header_id = @source_deal_header_id
			INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
			INNER JOIN #temp_header_columns thc ON REPLACE(thc.columns_name, 'UDF___', '') = CAST(udft.udf_template_id AS NVARCHAR(20))
			WHERE uddft.template_id = @template_id
			
			-- insert udf if not present
			INSERT INTO user_defined_deal_fields (source_deal_header_id, udf_template_id, udf_value)
			SELECT @source_deal_header_id, uddft.udf_template_id, thc.columns_value
			FROM user_defined_deal_fields_template uddft
			INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
			INNER JOIN #temp_header_columns thc ON REPLACE(thc.columns_name, 'UDF___', '') = CAST(udft.udf_template_id AS NVARCHAR(20))
			LEFT JOIN user_defined_deal_fields uddf
				ON uddft.udf_template_id = uddf.udf_template_id
				AND uddf.source_deal_header_id = @source_deal_header_id
			WHERE uddft.template_id = @template_id AND uddf.udf_deal_id IS NULL

			exec spa_print '-----header update completed'
		END
	
		IF @detail_xml IS NOT NULL
		BEGIN
			DECLARE @detail_table_schema XML 
			DECLARE @detail_table_data XML
			DECLARE @detail_process_table NVARCHAR(300)
	
			SET @detail_process_table = dbo.FNAProcessTableName('detail_process_table', @user_name, @process_id)	
	
			SELECT @detail_table_schema = CAST(col.query('.') AS NVARCHAR(MAX))
			FROM @detail_xml.nodes('/rows/head') AS xmlData(col)
	
			SELECT @detail_table_data = COALESCE(CAST(@detail_table_data AS NVARCHAR(MAX)) + '', '') + CAST(xmlData.col.query('.') AS NVARCHAR(MAX))
			FROM @detail_xml.nodes('/rows/row') AS xmlData(col)
			
			IF OBJECT_ID('tempdb..#detail_xml_columns') IS NOT NULL
				DROP TABLE #detail_xml_columns
			
			CREATE TABLE #detail_xml_columns (id int IDENTITY(1,1), column_name NVARCHAR(200) COLLATE DATABASE_DEFAULT, data_type NVARCHAR(2000) COLLATE DATABASE_DEFAULT)

			INSERT INTO #detail_xml_columns
			SELECT x.value('@id', 'sysname') AS column_name,
				   CASE x.value('@type', 'sysname')
						WHEN 'ed_no' THEN 'NUMERIC(38,20)'
						WHEN 'ed_p' THEN 'NUMERIC(38,20)'
						WHEN 'dhxCalendarA' THEN 'DATETIME'
						ELSE 'NVARCHAR(MAX)'
				   END AS data_type
			FROM @detail_table_schema.nodes('/head/column') TempXML(x)
			
			IF OBJECT_ID('tempdb..#temp_default_fields') IS NOT NULL
				DROP TABLE #temp_default_fields
			
			CREATE TABLE #temp_default_fields (
				columns_name NVARCHAR(200) COLLATE DATABASE_DEFAULT,
				columns_value NVARCHAR(200) COLLATE DATABASE_DEFAULT
			)
			
			IF OBJECT_ID('tempdb..#temp_hidden_detail_fields') IS NOT NULL
				DROP TABLE #temp_hidden_detail_fields
			
			CREATE TABLE #temp_hidden_detail_fields (
				columns_name NVARCHAR(200) COLLATE DATABASE_DEFAULT,
				columns_value NVARCHAR(200) COLLATE DATABASE_DEFAULT,
				udf_or_system NCHAR(1) COLLATE DATABASE_DEFAULT,
				field_type NVARCHAR(10) COLLATE DATABASE_DEFAULT
			)
			
			DECLARE @whr NVARCHAR(2000) = 'leg=1 AND template_id = ' + CAST(@template_id AS NVARCHAR(10))
			INSERT INTO #temp_default_fields
			EXEC spa_Transpose 'source_deal_detail_template', @whr
			
			INSERT INTO #temp_hidden_detail_fields
			SELECT [column_name], default_value, udf_or_system, field_type
			FROM (
				SELECT mfd.farrms_field_id [column_name], COALESCE(tdf.columns_value, mfd.default_value) default_value, 's' [udf_or_system], mfd.field_type
				FROM maintain_field_deal mfd
				INNER JOIN maintain_field_template_detail mftd
					ON  mftd.field_id = mfd.field_id
					AND mftd.field_template_id = @field_template_id
					AND ISNULL(mftd.udf_or_system, 's') = 's'
				INNER JOIN #temp_default_fields tdf ON tdf.columns_name = mfd.farrms_field_id
				LEFT JOIN #detail_xml_columns dxc ON dxc.column_name = tdf.columns_name
				WHERE dxc.id IS NULL
					  AND mfd.header_detail = 'd'
					  AND mfd.farrms_field_id NOT IN ('leg', 'contract_expiration_date', 'buy_sell_flag', 'update_ts', 'update_user', 'create_ts', 'create_user')
			
				UNION ALL 
			
				SELECT CAST(udft.udf_template_id AS NVARCHAR(200)) [column_name], uddft.default_value, 'u' [udf_or_system], udft.field_type
				FROM maintain_field_template_detail mftd
				INNER JOIN user_defined_fields_template udft
					ON  mftd.field_id = udft.udf_template_id
					AND mftd.udf_or_system = 'u'
				LEFT JOIN user_defined_deal_fields_template uddft
					ON  uddft.field_name = udft.field_name
				LEFT JOIN #detail_xml_columns dxc ON dxc.column_name = 'UDF___' + CAST(udft.udf_template_id AS NVARCHAR)
				WHERE  dxc.id IS NULL
						AND mftd.field_template_id = @field_template_id
						AND udft.udf_type = 'd'
						AND ISNULL(mftd.udf_or_system, 's') = 'u'
						AND uddft.template_id = @template_id
						
			) a
			
			DECLARE @detail_sql NVARCHAR(MAX) = 'SELECT '

			SELECT @detail_sql = @detail_sql + CASE data_type
			                                        WHEN 'NUMERIC(38,20)' THEN 
			                                             'CAST(NULLIF(x.value(''(cell)['  + CAST(id AS NVARCHAR) + ']'', ''NVARCHAR(500)''), '''') AS NUMERIC(38,20))'
			                                        ELSE 'NULLIF(x.value(''(cell)['  + CAST(id AS NVARCHAR(MAX)) + ']'', ''' + data_type +  '''' + '), '''')'
			                                   END + ' AS [' + column_name + '],'
			FROM #detail_xml_columns

			SET @detail_sql = LEFT(@detail_sql, LEN(@detail_sql) - 1)

			SELECT @detail_sql = @detail_sql + ' INTO ' + @detail_process_table + ' FROM @detail_table_data.nodes(''/row'') TempXML(x)'
			
			SET @formula_present = COL_LENGTH(@detail_process_table, 'formula_id')
			
			IF @formula_present IS NOT NULL
			BEGIN
				SET @sql = 'UPDATE temp
							SET formula_id = SUBSTRING(temp.formula_id, 0, CHARINDEX(''^'', temp.formula_id))
							FROM ' + @detail_process_table + ' temp'
				exec spa_print @sql
				EXEC(@sql)
			END
						
			EXEC sp_executeSQl @detail_sql, N'@detail_table_data xml', @detail_table_data = @detail_table_data
			
			DECLARE @update_list NVARCHAR(MAX),
					@insert_list NVARCHAR(MAX),
					@select_list NVARCHAR(MAX)
				
			SELECT @update_list = COALESCE(@update_list + ',', '') + column_name + ' = temp.' + column_name,
				   @select_list = COALESCE(@select_list + ',', '') + 'temp.' + column_name,
				   @insert_list = COALESCE(@insert_list + ',', '') + column_name
			FROM #detail_xml_columns
			WHERE column_name NOT IN ('blotterleg', 'source_deal_detail_id', 'leg', 'update_ts', 'update_user', 'create_ts', 'create_user')
			AND column_name NOT LIKE '%UDF___%'
			
			IF OBJECT_ID('tempdb..#temp_output_updated_detail') IS NOT NULL
				DROP TABLE #temp_output_updated_detail
			
			CREATE TABLE #temp_output_updated_detail (source_deal_detail_id INT)
			
			--Added the logic to update the cycle when updated the values of deal_volume, schedule_volume and actual_volume.
			DECLARE @update_cycle_condition NVARCHAR(MAX)

			SET @update_cycle_condition = '
					UPDATE tu
					SET tu.cycle = 41000 
					FROM ' + @detail_process_table + ' tu 
						INNER JOIN source_deal_detail sdd
							ON sdd.source_deal_detail_id = tu.source_deal_detail_id AND CAST(tu.source_deal_detail_id AS NVARCHAR(300)) NOT LIKE ''%NEW_%''
							AND sdd.location_id = tu.location_id
							AND sdd.term_start = tu.term_start
					WHERE 1 = 1
					  AND ((tu.cycle IS NULL AND ISNULL(tu.deal_volume, 1) <> ISNULL(sdd.deal_volume, 1))
						OR (tu.cycle IS NULL AND ISNULL(tu.schedule_volume, 1) <> ISNULL(sdd.schedule_volume, 1))
						OR (tu.cycle IS NULL AND ISNULL(tu.actual_volume, 1) <> ISNULL(sdd.actual_volume, 1)))

				
				'

			IF EXISTS(
				SELECT 1
				FROM source_deal_header sdh
					INNER JOIN source_deal_header_template sdht
						ON sdh.template_id = sdht.template_id
					INNER JOIN maintain_field_template_detail mftd
						ON mftd.field_template_id = sdht.field_template_id	
					INNER join maintain_field_deal mfd
						ON mfd.field_id = mftd.field_id		
					WHERE sdh.source_deal_header_id = @source_deal_header_id
						AND mfd.farrms_field_id = 'cycle'
						AND mftd.udf_or_system = 's'
			) 
			BEGIN
				EXEC(@update_cycle_condition)
			END

			SET @sql = ' UPDATE sdd 
						 SET ' + @update_list + '		
						 OUTPUT INSERTED.source_deal_detail_id INTO #temp_output_updated_detail(source_deal_detail_id)				 
						 FROM source_deal_detail sdd
						 INNER JOIN ' + @detail_process_table + ' temp ON sdd.source_deal_detail_id = temp.source_deal_detail_id
			             WHERE CAST(temp.source_deal_detail_id AS NVARCHAR(300)) NOT LIKE ''%NEW_%''
						'
			exec spa_print @sql
			EXEC(@sql)
			
			IF @change_in_buy_sell = 'y'
			BEGIN
				UPDATE sdd 
				SET buy_sell_flag = CASE WHEN sdd.buy_sell_flag = 'b' THEN 's' ELSE 'b' END				 
				FROM source_deal_detail sdd
				WHERE source_deal_header_id = @source_deal_header_id
			END
			
			DECLARE @hidden_columns NVARCHAR(MAX)
			DECLARE @hidden_values NVARCHAR(MAX)
			
			SELECT @hidden_columns = COALESCE(@hidden_columns + ',', '') + temp.columns_name,
				   @hidden_values = COALESCE(@hidden_values + ',', '') + CASE WHEN temp.columns_value IS NULL THEN 'NULL' ELSE '''' +  CASE WHEN temp.field_type = 'a' THEN dbo.FNAGetSQLStandardDate(temp.columns_value) ELSE CAST(temp.columns_value AS NVARCHAR(2000)) END + '''' END
			FROM #temp_hidden_detail_fields temp
			WHERE udf_or_system = 's'
			
			DECLARE @contract_expiration_column NVARCHAR(50)
			DECLARE @contract_expiration_value NVARCHAR(50)
			DECLARE @buy_sell_column NVARCHAR(50)
			DECLARE @buy_sell_value NVARCHAR(50)
			
			IF ISNULL(CHARINDEX('contract_expiration_date', @insert_list), 0) = 0 AND ISNULL(CHARINDEX('contract_expiration_date', @hidden_columns), 0) = 0
			BEGIN
				SET @contract_expiration_column = ', contract_expiration_date'
				SET @contract_expiration_value = ', temp.term_end'
			END
			
			IF ISNULL(CHARINDEX('buy_sell_flag', @insert_list), 0) = 0 AND ISNULL(CHARINDEX('buy_sell_flag', @hidden_columns), 0) = 0
			BEGIN
				SET @buy_sell_column = ', buy_sell_flag'
				SELECT @buy_sell_value = ',''' + header_buy_sell_flag + '''' FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id
			END
			
			IF OBJECT_ID('tempdb..#temp_old_new_deal_detail_id') IS NOT NULL
				DROP TABLE #temp_old_new_deal_detail_id
				
			CREATE TABLE #temp_old_new_deal_detail_id (
				old_source_deal_detail_id  NVARCHAR(500) COLLATE DATABASE_DEFAULT,
				new_source_deal_detail_id  INT,
				term_start DATETIME,
				term_end   DATETIME,
				leg INT
			)
			
			IF OBJECT_ID('tempdb..#temp_leg_buy_sell') IS NOT NULL
				DROP TABLE #temp_leg_buy_sell

			CREATE TABLE #temp_leg_buy_sell (
				leg INT,
				buy_sell_flag NCHAR(1) COLLATE DATABASE_DEFAULT
			)

			INSERT INTO #temp_leg_buy_sell(leg, buy_sell_flag)
			SELECT DISTINCT leg, buy_sell_flag FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id ORDER BY leg
			
			SET @sql = 'INSERT INTO source_deal_detail (source_deal_header_id, leg, ' + @insert_list 
							+ ISNULL(', ' + @hidden_columns, '') 
							+ ISNULL(@contract_expiration_column, '') 
							+ ISNULL(@buy_sell_column, '') 
						+ ')	
						OUTPUT INSERTED.source_deal_detail_id, INSERTED.term_start, INSERTED.term_end, INSERTED.leg INTO #temp_old_new_deal_detail_id(new_source_deal_detail_id, term_start, term_end, leg)
						SELECT ' + CAST(@source_deal_header_id AS NVARCHAR(20)) + ', blotterleg, ' + @select_list 
							   + ISNULL(',' + @hidden_values, '') 
							   + ISNULL(@contract_expiration_value, '')
							   + ISNULL(@buy_sell_value, '') + '
						FROM ' + @detail_process_table + ' temp
						WHERE temp.source_deal_detail_id LIKE ''%NEW_%''
						
						UPDATE sdd
						SET buy_sell_flag = t_bs.buy_sell_flag
						FROM source_deal_detail sdd 
						INNER JOIN #temp_old_new_deal_detail_id temp ON sdd.source_deal_detail_id = temp.new_source_deal_detail_id
						INNER JOIN #temp_leg_buy_sell t_bs ON t_bs.leg = sdd.leg
						
						UPDATE temp
						SET old_source_deal_detail_id = dpt.source_deal_detail_id
						FROM #temp_old_new_deal_detail_id temp
						INNER JOIN ' + @detail_process_table + ' dpt
							ON temp.term_start = dpt.term_start
							AND temp.term_end = dpt.term_end
							AND temp.leg = dpt.blotterleg

						UPDATE dpt
						SET source_deal_detail_id = temp.new_source_deal_detail_id
						FROM #temp_old_new_deal_detail_id temp
						INNER JOIN ' + @detail_process_table + ' dpt
							ON temp.old_source_deal_detail_id = dpt.source_deal_detail_id						
						'
			exec spa_print @sql
			EXEC(@sql)
				
			EXEC spa_sync_from_to_deal_volume  @detail_process_table

			IF OBJECT_ID(@detail_process_table+'_out')	IS NOT null
			BEGIN 
				set @sql='
					update 	sdd set deal_volume=los_calc.deal_volume
					from dbo.source_deal_detail sdd 
					inner join  
						( 
							select o.source_deal_detail_id,o.deal_volume from '+ @detail_process_table+'_out o left join '+@detail_process_table+' s 
							on  o.source_deal_detail_id=s.source_deal_detail_id where  s.source_deal_detail_id is null
						) los_calc on sdd.source_deal_detail_id=los_calc.source_deal_detail_id

					  '
			--	exec spa_print @sql
				EXEC(@sql)
			END 
			IF OBJECT_ID('tempdb..#udf_table') IS NOT NULL
				DROP TABLE #udf_transpose_table
				
			IF OBJECT_ID('tempdb..#udf_table') IS NOT NULL
				DROP TABLE #udf_transpose_table
					
			CREATE TABLE #udf_table(sno INT IDENTITY(1,1))
			CREATE TABLE #udf_transpose_table(
				source_deal_detail_id     NVARCHAR(500) COLLATE DATABASE_DEFAULT,
				udf_template_id           NVARCHAR(50) COLLATE DATABASE_DEFAULT,
				udf_value                 NVARCHAR(150) COLLATE DATABASE_DEFAULT
			)
			
			DECLARE @udf_field            NVARCHAR(MAX),
					@udf_xml_field        NVARCHAR(MAX), -- remove
					@udf_add_field        NVARCHAR(MAX),
					@udf_add_field_label  NVARCHAR(MAX),
					@udf_update           NVARCHAR(MAX),
					@udf_from_ut_table    NVARCHAR(MAX)

			SELECT @udf_field = COALESCE(@udf_field + ',', '') + 'UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR),
				   @udf_add_field = COALESCE(@udf_add_field + ',', '') + 'UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) + ' NVARCHAR(150)',
				   @udf_xml_field = COALESCE(@udf_xml_field + ',', '') + 'UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) + ' NVARCHAR(150) ''@udf___' + CAST(udft.udf_user_field_id AS NVARCHAR) + '''',
				   @udf_add_field_label = COALESCE(@udf_add_field_label + ',', '') + 'ISNULL([UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) + '], '''') AS [UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) + ']',
				   @udf_from_ut_table = COALESCE(@udf_from_ut_table + ',', '') + ' ut.[UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) + ']',
				   @udf_update = COALESCE(@udf_update + ',', '') + 'sddt.[UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) + '] = ut.UDF___' + CAST(udft.udf_user_field_id AS NVARCHAR) 
			FROM   maintain_field_template_detail d
			INNER JOIN user_defined_fields_template udf_temp ON  d.field_id = udf_temp.udf_template_id
			INNER JOIN user_defined_deal_fields_template udft
				ON  udft.udf_user_field_id = udf_temp.udf_template_id
				AND udft.template_id = @template_id
			INNER JOIN #detail_xml_columns dxc ON REPLACE(dxc.column_name, 'UDF___', '') = CAST(udf_temp.udf_template_id AS NVARCHAR(20))
			WHERE  udf_or_system = 'u'
				   AND udf_temp.udf_type = 'd'
				   AND field_template_id = @field_template_id
				   AND udft.leg = 1
				   
			SET @udf_field = @udf_field + ',source_deal_detail_id'
			SET @udf_add_field = @udf_add_field + ',source_deal_detail_id NVARCHAR(500)'
			SET @udf_add_field_label = @udf_add_field_label + ',source_deal_detail_id' 
			SET @udf_from_ut_table = @udf_from_ut_table + ', ut.source_deal_detail_id' 
			
			IF @udf_add_field IS NOT NULL
			BEGIN
				EXEC ('ALTER TABLE #udf_table ADD ' + @udf_add_field)
				SET @sql = '
						INSERT #udf_table (
							' + @udf_field + '
						)
						SELECT ' + @udf_add_field_label + '
						FROM   ' + @detail_process_table + '
						'
				exec spa_print @sql	 
				EXEC (@sql)
			
				DECLARE @udf_unpivot_clm NVARCHAR(MAX)
				SET @udf_unpivot_clm = REPLACE(@udf_field, ',source_deal_detail_id', '')
				SET @sql = ' INSERT #udf_transpose_table (
								 source_deal_detail_id,
								 udf_template_id,
								 udf_value
							   )
							 SELECT 
								source_deal_detail_id,
								col,
								colval
							 FROM   (
								 SELECT ' + @udf_field + '
								 FROM   #udf_table
							) p
							UNPIVOT(ColVal FOR Col IN (' + @udf_unpivot_clm + ')) AS unpvt'
				exec spa_print @sql	 
				EXEC (@sql)
			END
			
			UPDATE #udf_transpose_table
			SET udf_template_id = REPLACE(udf_template_id, 'UDF___', '')
			
			UPDATE user_defined_deal_detail_fields
			SET udf_value = CASE 
			                    WHEN uddft.Field_type = 'a' THEN dbo.FNAGetSQLStandardDate(u.udf_value)
			                    ELSE u.udf_value
			                END
			FROM user_defined_deal_detail_fields udf
			LEFT JOIN user_defined_deal_fields_template uddft ON  uddft.udf_template_id = udf.udf_template_id
			INNER JOIN #udf_transpose_table u
			    ON  u.udf_template_id = uddft.udf_user_field_id
				AND u.source_deal_detail_id = udf.source_deal_detail_id	
			WHERE CAST(u.source_deal_detail_id AS NVARCHAR(20)) NOT LIKE '%NEW_%'	
								
			INSERT INTO user_defined_deal_detail_fields (	
				source_deal_detail_id,
				udf_template_id,
				udf_value
			)
			SELECT tonddi.new_source_deal_detail_id,
				   uddft.udf_template_id,
				   NULLIF(utt.udf_value, '')
			FROM  #udf_transpose_table utt 
			LEFT JOIN user_defined_deal_detail_fields udddf ON  utt.source_deal_detail_id = CAST(udddf.source_deal_detail_id AS NVARCHAR(200))
			INNER JOIN #temp_old_new_deal_detail_id tonddi ON  tonddi.old_source_deal_detail_id = utt.source_deal_detail_id
			INNER JOIN user_defined_fields_template udft ON  udft.udf_template_id = utt.udf_template_id
			INNER JOIN user_defined_deal_fields_template uddft ON  udft.field_name = uddft.field_name
			WHERE  udddf.source_deal_detail_id IS NULL AND CAST(utt.source_deal_detail_id AS NVARCHAR(20)) LIKE '%NEW_%'
			AND uddft.template_id = @template_id
			--*/
		END
		
		IF EXISTS (	SELECT 1
					FROM   adiha_default_codes_values
					WHERE  default_code_id = 56
							AND var_value = 1)				
		BEGIN
			UPDATE sdd
			SET curve_id = sml.term_pricing_index
			FROM source_deal_detail sdd
			INNER JOIN (
				SELECT source_deal_detail_id FROM #temp_output_updated_detail
				UNION ALL 
				SELECT new_source_deal_detail_id FROM #temp_old_new_deal_detail_id
			) temp ON sdd.source_deal_detail_id = temp.source_deal_detail_id
			INNER JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id
			AND sdd.fixed_float_leg = 't' AND sdd.physical_financial_flag = 'p'
		END	
		
		-- update audit info
		UPDATE sdh
		SET update_user = dbo.FNADBUser(),
			update_ts =  GETDATE(),
			entire_term_start = t.term_start,
			entire_term_end = t.term_end
		FROM source_deal_header sdh
		OUTER APPLY (SELECT MIN(sdd.term_start) term_start, MAX(sdd.term_end) term_end FROM source_deal_detail sdd WHERE sdd.source_deal_header_id = @source_deal_header_id) t
		WHERE sdh.source_deal_header_id = @source_deal_header_id
			
		UPDATE sdd
		SET update_user = dbo.FNADBUser(),
			update_ts =  GETDATE()
		FROM source_deal_detail sdd
		INNER JOIN (
			SELECT source_deal_detail_id FROM #temp_output_updated_detail
			UNION ALL 
			SELECT new_source_deal_detail_id FROM #temp_old_new_deal_detail_id
		) temp ON sdd.source_deal_detail_id = temp.source_deal_detail_id
		
		COMMIT TRAN
		
		EXEC spa_ErrorHandler 0
			, 'source_deal_header'
		    , 'spa_deal_update'
			, 'Success' 
			, 'Changes saved successfully.'
			, ''
		
		DECLARE @after_update_process_table NVARCHAR(300), @job_name NVARCHAR(200), @job_process_id NVARCHAR(200) = dbo.FNAGETNEWID()
		SET @after_update_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
		EXEC spa_print @after_update_process_table
		IF OBJECT_ID(@after_update_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_update_process_table)
		END
				
		EXEC ('CREATE TABLE ' + @after_update_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_update_process_table + '(source_deal_header_id) 
					SELECT ' + CAST(@source_deal_header_id AS NVARCHAR(20))
		EXEC(@sql)
		
		IF EXISTS (SELECT 1 from source_deal_header sdh INNER JOIN 
					source_deal_header_template sdht ON sdh.template_id = sdht.template_id
					WHERE template_name = 'Generation Deal Template' AND sdh.source_deal_header_id = @source_deal_header_id)
		BEGIN
			DECLARE @maximum_capacity FLOAT
			SELECT @maximum_capacity = uddf.udf_value FROM user_defined_deal_fields uddf 
			INNER JOIN user_defined_deal_fields_template uddft ON uddf.udf_template_id = uddft.udf_template_id
			WHERE uddft.Field_label = 'Maximum capacity' AND uddf.source_deal_header_id = @source_deal_header_id

			UPDATE sddh
			SET sddh.volume = CASE WHEN po.[type_name] = 'o' THEN 0 WHEN po.[type_name] = 'd' THEN 
								CASE WHEN po.derate_mw IS NOT NULL THEN @maximum_capacity-po.derate_mw ELSE @maximum_capacity * (100-derate_percent)/100 END
							ELSE @maximum_capacity END 
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN source_deal_detail_hour sddh ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
			LEFT JOIN power_outage po ON sdd.location_id = po.source_generator_id AND DATEADD(hh, CAST(sddh.hr AS INT)-1,sddh.term_date) BETWEEN po.actual_start AND po.actual_end
			WHERE sdh.source_deal_header_id = @source_deal_header_id

			IF OBJECT_ID('tempdb..#temp_sddh') IS NOT NULL
				DROP TABLE #temp_sddh

			SELECT sdd.source_deal_detail_id, a.term_start INTO #temp_sddh
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			CROSS APPLY (Select * FROM dbo.FNATermBreakdown('h', sdd.term_start,DATEADD(hh,23,sdd.term_end))) a
			WHERE YEAR(a.term_start) = YEAR(sdd.term_start) AND MONTH(a.term_start) = MONTH(sdd.term_start)
			AND sdh.source_deal_header_id = @source_deal_header_id
			
			INSERT INTO source_deal_detail_hour (source_deal_detail_id, term_date, hr, is_dst, volume, granularity)
			SELECT tmp.source_deal_detail_id, CAST(tmp.term_start AS DATE), DATEPART(hh,tmp.term_start)+1, 0, @maximum_capacity, 982 FROM #temp_sddh tmp
			LEFT JOIN source_deal_detail_hour sddh ON tmp.term_start = DATEADD(hh, CAST(sddh.hr AS INT)-1, sddh.term_date) 
			AND tmp.source_deal_detail_id = sddh.source_deal_detail_id
			WHERE sddh.source_deal_detail_id IS NULL
		END
			
		SET @sql = 'spa_deal_insert_update_jobs ''u'', ''' + @after_update_process_table + ''''
		SET @job_name = 'spa_deal_insert_update_jobs_' + @job_process_id
 		
		EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name	
		
	END TRY
	BEGIN CATCH
		DECLARE @DESC NVARCHAR(500)
		DECLARE @err_no INT
 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to save Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'source_deal_header'
		   , 'spa_deal_update'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
ELSE IF @flag = 't'
BEGIN
	--EXEC spa_deal_update @flag='t', @source_deal_header_id=17389, @from_date = '2015-01-01', @to_date = '2016-01-01'
	--EXEC spa_deal_update  @flag='t',@source_deal_header_id='17389',@from_date='2015-07-01',@to_date='2015-07-31'
	SELECT @term_frequency = sdh.term_frequency
	FROM source_deal_header sdh
	WHERE sdh.source_deal_header_id = @source_deal_header_id
	
	IF OBJECT_ID('tempdb..#temp_terms') IS NOT NULL
		DROP TABLE #temp_terms
	
	CREATE TABLE #temp_terms (id INT IDENTITY(1,1), term_start DATETIME, term_end DATETIME)
	
	IF @term_frequency <> 'h'
	BEGIN
		WITH cte AS (
			SELECT @from_date [term_start], dbo.FNAGetTermEndDate(@term_frequency, @from_date, 0) [term_end]
			UNION ALL
			SELECT dbo.FNAGetTermStartDate(@term_frequency, [term_start], 1), dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAGetTermStartDate(@term_frequency, [term_start], 1), 0) 
			FROM cte WHERE dbo.FNAGetTermStartDate(@term_frequency, [term_start], 1) <= @to_date
		) 
		INSERT INTO #temp_terms(term_start, term_end)
		SELECT term_start, term_end FROM cte
		option (maxrecursion 0)
	END
	
	SELECT dbo.FNAGetSQLStandardDate(term_start) term_start, dbo.FNAGetSQLStandardDate(term_end) term_end FROM #temp_terms ORDER by term_start
END
ELSE IF @flag = 'l'
BEGIN
	DECLARE @disable_term NCHAR(1) = 'n'
	
	SELECT @disable_term = ISNULL(mftd.is_disable, 'n') 
	FROM maintain_field_template_detail mftd 
	INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
	WHERE mftd.field_template_id = @field_template_id
	AND mfd.farrms_field_id = 'term_start'
	
	IF @disable_term = 'n'
	BEGIN
		SELECT @disable_term = ISNULL(mftd.is_disable, 'n') 
		FROM maintain_field_template_detail mftd 
		INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
		WHERE mftd.field_template_id = @field_template_id
		AND mfd.farrms_field_id = 'term_end'
	END
	
	SELECT ISNULL(deal_locked, 'n')  deal_locked, @disable_term [disable_term], dbo.FNAGetSQLStandardDate(sdh.deal_date) deal_date
	FROM source_deal_header sdh WHERE sdh.source_deal_header_id = @source_deal_header_id
END
ELSE IF @flag = 'm'
BEGIN
	SELECT @term_frequency = sdh.term_frequency
	FROM source_deal_header sdh
	WHERE sdh.source_deal_header_id = @source_deal_header_id
	
	SET @from_date = dbo.FNAGetTermStartDate(@term_frequency, @from_date, 1)
	SET @to_date = dbo.FNAGetTermEndDate(@term_frequency, @from_date, 0)
	
	SELECT dbo.FNAGetSQLStandardDate(@from_date) [from_date], dbo.FNAGetSQLStandardDate(@to_date) [to_date]	
END
