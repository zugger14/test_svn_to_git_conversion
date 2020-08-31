IF OBJECT_ID(N'[dbo].[spa_deal_formula_udf]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_formula_udf]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**  
	Procedure to process Deal UDF formula fields
	
	Parameters
	
    @flag					: Operation flag that decides the action to be performed. Does not accept NULL.
    @formula_id 			: Id of the formula to be processed
    @process_id 			: Process Id used for Process tables
    @form_xml 				: Form data in XML format
    @row_id 				: Grid row Id
    @source_deal_detail_id 	: Identity of Source Deal Detail table
    @leg 					: Leg of the Deal
    @source_deal_group_id 	: Identity of Source Deal Group
*/

CREATE PROCEDURE [dbo].[spa_deal_formula_udf]
    @flag NCHAR(1),
    @formula_id INT = NULL,
    @process_id NVARCHAR(200) = NULL,
    @form_xml XML = NULL,
    @row_id NVARCHAR(20) = NULL,
    @source_deal_detail_id NVARCHAR(20) = NULL,
    @leg INT = NULL,
    @source_deal_group_id NVARCHAR(20) = NULL
AS

/*-------------Debug Section-------------
DECLARE @flag NCHAR(1),
		@formula_id INT = NULL,
		@process_id NVARCHAR(200) = NULL,
		@form_xml XML = NULL,
		@row_id NVARCHAR(20) = NULL,
		@source_deal_detail_id NVARCHAR(20) = NULL,
		@leg INT = NULL,
		@source_deal_group_id NVARCHAR(20) = NULL

SELECT @flag = 'a', 
@process_id = '95219770_A5D4_4E74_A055_7AAA3466386F',
@form_xml = '<FormXML source_deal_header_id="225637" leg="1" term_start="2019-12-01" term_end="2020-10-31"></FormXML>',
@source_deal_detail_id = 2323050
---------------------------------------*/

SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX)
DECLARE @form_xml_table NVARCHAR(200)
DECLARE @user_name NVARCHAR(100) = dbo.FNADBUser()
DECLARE @detail_formula_process_table NVARCHAR(300) = dbo.FNAProcessTableName('detail_formula_process_table', @user_name, @process_id)

IF @flag = 'z'
BEGIN
	DECLARE @temp_process_id NVARCHAR(300) = dbo.FNAGetNewId()
	DECLARE @temp_process_table	NVARCHAR(300) = dbo.FNAProcessTableName('formula_editor', @user_name, @temp_process_id)
	EXEC spa_resolve_function_parameter @flag = 's',@process_id = @temp_process_id, @formula_id = @formula_id
	SET @sql = 'SELECT fe.formula_id, ISNULL(fe.istemplate, ''n'') [is_template]
					  , temp.formula_name [formula_text]
	FROM formula_editor fe 
				INNER JOIN ' + @temp_process_table + ' temp
								ON temp.formula_id = fe.formula_id 
				WHERE fe.formula_id = ' +CAST(@formula_id AS NVARCHAR(20))
	EXEC(@sql)
	RETURN
END

IF @flag = 'y'
BEGIN	
	IF NOT EXISTS (
		SELECT 1 FROM formula_editor fe WHERE fe.formula_id = @formula_id AND fe.formula LIKE '%UDFValue%'
	)
	BEGIN
		SELECT NULL [form_json]
		RETURN
	END
	
	IF OBJECT_ID('tempdb..#detail_formula_table') IS NOT NULL
		DROP TABLE #detail_formula_table
		
	CREATE TABLE #detail_formula_table (
 		[id]                        INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
 		[row_id]				    NVARCHAR(20) COLLATE DATABASE_DEFAULT NULL,
 		[leg]						NVARCHAR(20) COLLATE DATABASE_DEFAULT NULL,
 		[source_deal_detail_id]     NVARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
 		[source_deal_group_id]      NVARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
 		[udf_template_id]           INT NULL,
 		[udf_value]                 NVARCHAR(2000) COLLATE DATABASE_DEFAULT NULL
	)
	
	SET @sql = '
		INSERT INTO #detail_formula_table (row_id, leg, source_deal_detail_id, source_deal_group_id, udf_template_id, udf_value)
		SELECT row_id, leg, source_deal_detail_id, source_deal_group_id, udf_template_id, udf_value 
		FROM ' + @detail_formula_process_table + ' t1
		WHERE t1.source_deal_group_id = ''' + @source_deal_group_id + '''
		AND t1.source_deal_detail_id = ''' + @source_deal_detail_id + '''
		AND t1.leg = ' + CAST(@leg AS NVARCHAR(20)) + '
		AND t1.row_id = ' + CAST(@row_id AS NVARCHAR(20)) + '
	'
	--PRINT(@sql)
	EXEC(@sql)
	--SELECT * FROM #detail_formula_table
	IF OBJECT_ID('tempdb..#temp_formula_fields') IS NOT NULL
		DROP TABLE #temp_formula_fields
	
	CREATE TABLE #temp_formula_fields (
 		[id]			 NVARCHAR(100) COLLATE DATABASE_DEFAULT,
 		default_label    NVARCHAR(100) COLLATE DATABASE_DEFAULT,
 		seq_no           INT,
 		field_id         NVARCHAR(50) COLLATE DATABASE_DEFAULT,
 		field_type       NVARCHAR(50) COLLATE DATABASE_DEFAULT,
 		sql_string		 NVARCHAR(2000) COLLATE DATABASE_DEFAULT,
 		json_data		 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
 		field_size		 NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 		data_type		 NVARCHAR(20) COLLATE DATABASE_DEFAULT,
 		default_value	 NVARCHAR(200) COLLATE DATABASE_DEFAULT
	)
	
	INSERT INTO #temp_formula_fields (id, default_label, seq_no, field_id, field_type, field_size, sql_string, data_type, default_value)
	SELECT 
	        'UDF___' + CAST(udft.udf_template_id AS NVARCHAR) udf_template_id,
 			MAX(udft.Field_label),
 			MIN(fb.formula_breakdown_id) seq,
 			CAST(udft.udf_template_id AS NVARCHAR(20)) field_id,
 			MAX(udft.field_type) field_type,
 			MAX(udft.field_size),
 			MAX(ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string)) sql_string,
 			MAX(udft.data_type),
 			ISNULL(MAX(t1.udf_value), MAX(udft.default_value))
	FROM formula_editor fe
	INNER JOIN formula_breakdown fb ON fb.formula_id = fe.formula_id
	INNER JOIN user_defined_fields_template udft ON udft.field_name = fb.arg1
	LEFT JOIN #detail_formula_table t1 ON t1.udf_template_id = udft.udf_template_id
	LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udft.data_source_type_id
	WHERE fe.formula_id = @formula_id AND fb.func_name LIKE '%UDFValue%'
	GROUP BY udft.udf_template_id
	ORDER BY MIN(fb.formula_breakdown_id)	
	 
	DECLARE @name           NVARCHAR(200),
			@sql_string     NVARCHAR(2000),
			@deal_value     NVARCHAR(2000)
        
	DECLARE formula_field_cursor CURSOR FORWARD_ONLY READ_ONLY 
	FOR
 		SELECT [id],
 				sql_string,
 				default_value         
 		FROM #temp_formula_fields
 		WHERE [field_type] IN ('d') AND sql_string IS NOT NULL
 
	OPEN formula_field_cursor
	FETCH NEXT FROM formula_field_cursor INTO @name, @sql_string, @deal_value                                        
	WHILE @@FETCH_STATUS = 0
	BEGIN
 		DECLARE @json NVARCHAR(max)
 		DECLARE @nsql NVARCHAR(MAX)	
 		SET @json = NULL
 		
 		IF OBJECT_ID('tempdb..#temp_combo') IS NOT NULL
 			DROP TABLE #temp_combo
 	
 		CREATE TABLE #temp_combo ([value] NVARCHAR(10) COLLATE DATABASE_DEFAULT, [text] NVARCHAR(1000) COLLATE DATABASE_DEFAULT, selected NVARCHAR(10) COLLATE DATABASE_DEFAULT, [state] NVARCHAR(10) COLLATE DATABASE_DEFAULT DEFAULT 'enable')
 		
 		INSERT INTO #temp_combo([value], [text])
 		SELECT '', ''
 		
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
 			BEGIN TRY
				SET @sql = 'INSERT INTO #temp_combo([value],[text]) ' + @sql_string
				EXEC (@sql)
			END TRY
			BEGIN CATCH
				SET @sql = 'INSERT INTO #temp_combo([value],[text],[state]) ' + @sql_string
				EXEC (@sql)
			END CATCH
 		END
 			
 		UPDATE #temp_combo
 		SET selected = 'true'			
 		WHERE value = @deal_value
 		
 		IF NOT EXISTS (SELECT 1 FROM #temp_combo WHERE value = @deal_value)
 		BEGIN
 			UPDATE #temp_formula_fields
 			SET default_value = NULL
 			WHERE [id] = @name
 		END			
 	
 		DECLARE @dropdown_xml XML
 		DECLARE @param NVARCHAR(100)
 		SET @param = N'@dropdown_xml XML OUTPUT';
 
 		SET @nsql = ' SET @dropdown_xml = (SELECT [value], [text], [selected],[state]
 						FROM #temp_combo 
 						FOR XML RAW (''row''), ROOT (''root''), ELEMENTS)'
 	
 		EXECUTE sp_executesql @nsql, @param, @dropdown_xml = @dropdown_xml OUTPUT;
		SET @dropdown_xml = REPLACE(CAST(@dropdown_xml AS NVARCHAR(MAX)), '"', '\"')
 		SET @json = dbo.FNAFlattenedJSON(@dropdown_xml)
 		
 		IF CHARINDEX('[', @json, 0) <= 0
 			SET @json = '[' + @json + ']'
		
		SET @json = '{"options":' + @json + '}'
 		UPDATE #temp_formula_fields
 		SET json_data = @json
 		WHERE [id] = @name
 			
 		FETCH NEXT FROM formula_field_cursor INTO @name, @sql_string, @deal_value    
	END
	CLOSE formula_field_cursor
	DEALLOCATE formula_field_cursor
	
	DECLARE @detail_form_json1 NVARCHAR(MAX), @detail_form_json NVARCHAR(MAX), @detail_form_final NVARCHAR(MAX)
	
	SET @detail_form_final = '[{"type":"settings","position":"label-top"}'	
	SET @detail_form_json1 = NULL
 	SET @detail_form_json1 = '{"type":"block", "blockOffset":0, "id": "formula_forms", list:['
 	SET @detail_form_json = NULL
 	
 	SELECT @detail_form_json = COALESCE(@detail_form_json + ',', '') 
 								+ '{"type":"'
 								+ CASE field_type
 										WHEN 'c' THEN 'checkbox'
 										WHEN 'd' THEN 'combo'
 										WHEN 't' THEN 'input'
 										WHEN 'a' THEN 'calendar'
 										ELSE 'input'
 									END + '"' 
 								+ ', "label":"' + ft.default_label + '"' +
 								+ ', "name":"' + ft.id + '"' +
 								+ ', "offsetLeft": "15", "inputWidth":"150"'
 								+ CASE WHEN NULLIF(ft.default_value, '') IS NOT NULL THEN ', "value":"' + ft.default_value + '"' ELSE '' END
 								+ CASE WHEN field_type = 'c' THEN ',"position":"label-right","offsetTop":"25"' ELSE '' END
 								+ CASE WHEN field_type = 'c' THEN ',"labelWidth": "120"' ELSE ',"labelWidth": "150"' END
 								+ CASE WHEN field_type IN ('d') THEN ', "filtering":"true","filtering_mode":"between"' ELSE '' END
 								+ CASE WHEN field_type IN ('d') THEN ',' + SUBSTRING(ft.json_data, 2, LEN(ft.json_data) - 2) ELSE '' END
 								+ CASE WHEN field_type = 'a' THEN ',"dateFormat":"' + COALESCE(dbo.FNAChangeDateFormat(), '%Y-%m-%d') + '", "serverDateFormat":"%Y-%m-%d"' ELSE '' END 	 								
 								+ '}'
 								+ ',{"type":"newcolumn"}' 
 	FROM #temp_formula_fields ft
 	ORDER BY ft.seq_no
 		
 	SET @detail_form_json = @detail_form_json1 + @detail_form_json + ']}'
 	
 	SET @detail_form_final = @detail_form_final + ',' + @detail_form_json
 	
	IF @detail_form_final IS NOT NULL 
	BEGIN
 		SET @detail_form_final += ']'
	END
	--SELECT @detail_form_final for xml RAW ('row'), ROOT ('root'), ELEMENTS
	SELECT @detail_form_final [form_json]
	RETURN
END

IF @flag = 'x'
BEGIN
	IF @form_xml IS NOT NULL
	BEGIN
 		SET @form_xml_table = dbo.FNAProcessTableName('form_xml_table', @user_name, @process_id)
 		
 		EXEC spa_parse_xml_file 'b', NULL, @form_xml, @form_xml_table
 		
 		IF OBJECT_ID('tempdb..#temp_detail_ids_collection') IS NOT NULL
 			DROP TABLE #temp_detail_ids_collection
 		
 		CREATE TABLE #temp_detail_ids_collection (source_deal_detail_id INT, source_deal_group_id INT)
 		
 		SET @sql = '
 			INSERT INTO #temp_detail_ids_collection (source_deal_group_id, source_deal_detail_id)
 			SELECT sdd.source_deal_detail_id, sdd.source_deal_group_id
 			FROM ' + @form_xml_table + ' temp
 			INNER JOIN source_deal_detail sdd ON CAST(sdd.source_deal_group_id AS NVARCHAR(20)) = temp.source_deal_group_id
 			WHERE temp.source_deal_detail_id IS NULL
 		'
 		
 		EXEC(@sql)
 		
 		
 		SET @sql = ' 			
 			UPDATE temp2
 			SET udf_value = temp.udf_value
 			FROM ' + @detail_formula_process_table + ' temp2
 			INNER JOIN ' + @form_xml_table + ' temp 
 				ON temp.source_deal_detail_id = temp2.source_deal_detail_id 
 				AND temp2.udf_template_id = REPLACE(temp.udf_template_id, ''UDF___'', '''')
 				AND temp2.row_id = temp.row_id
 				AND temp2.leg = temp.leg
 			WHERE temp.source_deal_detail_id IS NOT NULL
 			
 			INSERT INTO ' + @detail_formula_process_table + ' (row_id, leg, source_deal_detail_id, source_deal_group_id, udf_template_id, udf_value)
 			SELECT temp.row_id, temp.leg, temp.source_deal_detail_id, temp.source_deal_group_id, REPLACE(temp.udf_template_id, ''UDF___'', ''''), temp.udf_value
 			FROM ' + @form_xml_table + ' temp
 			LEFT JOIN ' + @detail_formula_process_table + ' temp2 
 				ON temp.source_deal_detail_id = temp2.source_deal_detail_id 
 				AND temp2.udf_template_id = REPLACE(temp.udf_template_id, ''UDF___'', '''')
 				AND temp2.row_id = temp.row_id
 				AND temp2.leg = temp.leg
 			WHERE temp.source_deal_detail_id IS NOT NULL AND temp2.id IS NULL
 		'
 		
 		EXEC(@sql)
 		
 		SET @sql = ' 			
 			UPDATE temp2
 			SET udf_value = temp.udf_value
 			FROM ' + @form_xml_table + ' temp
 			INNER JOIN #temp_detail_ids_collection temp1 ON temp1.source_deal_group_id = temp.source_deal_group_id
 			INNER JOIN ' + @detail_formula_process_table + ' temp2 
 				ON temp1.source_deal_detail_id = temp2.source_deal_detail_id 
 				AND temp2.udf_template_id = REPLACE(temp.udf_template_id, ''UDF___'', '''')
 				AND temp2.row_id = temp.row_id
 				AND temp2.leg = temp.leg
 			WHERE temp.source_deal_detail_id IS NULL
 			
 			INSERT INTO ' + @detail_formula_process_table + ' (row_id, leg, source_deal_detail_id, source_deal_group_id, udf_template_id, udf_value)
 			SELECT temp.row_id, temp.leg, temp1.source_deal_detail_id, temp.source_deal_group_id, REPLACE(temp.udf_template_id, ''UDF___'', ''''), temp.udf_value
 			FROM ' + @form_xml_table + ' temp
 			INNER JOIN #temp_detail_ids_collection temp1 ON temp1.source_deal_group_id = temp.source_deal_group_id
 			LEFT JOIN ' + @detail_formula_process_table + ' temp2 
 				ON temp1.source_deal_detail_id = temp2.source_deal_detail_id 
 				AND temp2.udf_template_id = REPLACE(temp.udf_template_id, ''UDF___'', '''')
 				AND temp2.row_id = temp.row_id
 				AND temp2.leg = temp.leg
 			WHERE temp.source_deal_detail_id IS NULL  AND temp2.id IS NULL
 		'
 		EXEC(@sql)
	END
END

IF @flag = 'a' -- Logic to apply to all in deal detail grid.
BEGIN
	DECLARE @idoc INT
 		
 	EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml

	IF OBJECT_ID ('tempdb..#form_data') IS NOT NULL
		DROP TABLE #form_data

	CREATE TABLE #form_data (
		source_deal_header_id INT,
		term_start NVARCHAR(20) COLLATE DATABASE_DEFAULT,
		term_end NVARCHAR(20) COLLATE DATABASE_DEFAULT,
		leg NVARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #form_data
	SELECT *
	FROM OPENXML(@idoc, '/FormXML', 1)
	WITH #form_data

	IF OBJECT_ID ('tempdb..#old_data') IS NOT NULL
		DROP TABLE #old_data

	CREATE TABLE #old_data (
 		[row_id] NVARCHAR(20) COLLATE DATABASE_DEFAULT NULL,
 		[leg] NVARCHAR(20) COLLATE DATABASE_DEFAULT NULL,
 		[source_deal_detail_id] NVARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
 		[source_deal_group_id] NVARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
 		[udf_template_id] INT NULL,
 		[udf_value] NVARCHAR(2000) COLLATE DATABASE_DEFAULT NULL
	)

	EXEC ('
		INSERT INTO #old_data
		SELECT row_id,
			   leg,
			   source_deal_detail_id,
			   source_deal_group_id,
			   udf_template_id, udf_value
		FROM ' + @detail_formula_process_table
	)

	DECLARE @udf_value NVARCHAR(2000),
		    @udf_template_id NVARCHAR(10)

	SELECT @udf_value = udf_value,
		   @udf_template_id = CAST(udf_template_id AS NVARCHAR(10))
	FROM #old_data
	WHERE source_deal_detail_id = @source_deal_detail_id
	
	EXEC('TRUNCATE TABLE ' + @detail_formula_process_table)

	EXEC('
		INSERT INTO ' + @detail_formula_process_table + '
		SELECT 1, sdd.leg, sdd.source_deal_detail_id, sdd.source_deal_group_id, ' + @udf_template_id + ', ' + @udf_value + '
		FROM source_deal_detail sdd 
		INNER JOIN #form_data fd ON fd.source_deal_header_id = sdd.source_deal_header_id
			AND fd.leg = sdd.leg
			AND sdd.term_start >= fd.term_start
			AND sdd.term_start <= fd.term_end
		LEFT JOIN #old_data p ON p.source_deal_detail_id = sdd.source_deal_detail_id
	')
END
