IF OBJECT_ID(N'[dbo].[spa_generic_mapping_export_import]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_generic_mapping_export_import
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
    SP Description

    Parameters 
    @flag : Flag Description
    @p1 : Parameter1 Description
    @p2 : Parameter2 Description
    @p3 : Parameter3 Description

 

*/
CREATE PROCEDURE [dbo].spa_generic_mapping_export_import
	@flag					VARCHAR(200),
 	@generic_mapping_ids	VARCHAR(MAX) = NULL,
	@import_file_name		VARCHAR(MAX) = NULL,
	@copy_as				VARCHAR(MAX) = NULL		

AS
SET NOCOUNT ON

/*

DECLARE @flag			VARCHAR(200) = NULL
DECLARE @generic_mapping_ids		VARCHAR(MAX) = NULL
DECLARE @import_file VARCHAR(MAX) 
DECLARE @copy_as VARCHAR(MAX)
  
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
SELECT * FROM generic_mapping_header		WHERE mapping_table_id = 47
SELECT * FROM generic_mapping_definition	WHERE mapping_table_id = 47
SELECT * FROM generic_mapping_values	WHERE mapping_table_id = 47
--return 
-- */

IF OBJECT_ID('tempdb..#generic_mapping_name') IS NOT NULL 
	DROP TABLE #generic_mapping_name

CREATE TABLE #generic_mapping_name(mapping_name VARCHAR(1000), mapping_table_id INT)

DECLARE @sql VARCHAR(MAX)
DECLARE @process_id VARCHAR(100) = dbo.FNAGetNewID()
DECLARE @json_output NVARCHAR(MAX)
DECLARE @json_final_output NVARCHAR(MAX) = '{'
DECLARE @user_name VARCHAR(1000)
DECLARE @generic_mapping_header			VARCHAR(1000)
DECLARE @generic_mapping_definition		VARCHAR(1000)
DECLARE @generic_mapping_values			VARCHAR(1000)
DECLARE @static_data_value				VARCHAR(1000)		
DECLARE @user_defined_fields_template	VARCHAR(1000)	

DECLARE @import_string	NVARCHAR(MAX) = NULL
DECLARE @to_import_generic_mapping_id INT = NULL
DECLARE @import_file VARCHAR(5000)

SELECT @import_file = document_path + '\temp_Note\' + @import_file_name
FROM connection_string

IF OBJECT_ID('tempdb..#sql_query_data_col') IS NOT NULL 
		DROP TABLE #sql_query_data_col

IF OBJECT_ID('tempdb..#sql_query_data_col_final') IS NOT NULL 
	DROP TABLE #sql_query_data_col_final

IF OBJECT_ID('tempdb..#sql_query_data_col_exec') IS NOT NULL 
	DROP TABLE #sql_query_data_col_exec

IF OBJECT_ID('tempdb..#sql_query_data_col_exec3') IS NOT NULL 
	DROP TABLE #sql_query_data_col_exec3

IF OBJECT_ID('tempdb..#generic_values') IS NOT NULL 
	DROP TABLE #generic_values

CREATE TABLE #sql_query_data_col(static_data_code VARCHAR(1000) COLLATE DATABASE_DEFAULT
								, col_order INT
								, [code] VARCHAR(1000) COLLATE DATABASE_DEFAULT
								, primary_id VARCHAR(1000) COLLATE DATABASE_DEFAULT
								, orginal_code VARCHAR(1000) COLLATE DATABASE_DEFAULT
								)
CREATE TABLE #sql_query_data_col_exec (primary_id VARCHAR(1000) COLLATE DATABASE_DEFAULT, [code] VARCHAR(1000) COLLATE DATABASE_DEFAULT)
		
CREATE TABLE #sql_query_data_col_exec3 ( primary_id VARCHAR(1000) COLLATE DATABASE_DEFAULT
								, [code] VARCHAR(1000) COLLATE DATABASE_DEFAULT
								, [state] VARCHAR(1000) COLLATE DATABASE_DEFAULT
								)
CREATE TABLE #generic_values(value VARCHAR(1000), col_names VARCHAR(100), col_order INT, generic_mapping_values_id INT)

IF @flag IN('export_rule', 'export_rule_copy_as')
BEGIN
	SET @sql = ''
	DECLARE @cnt INT = 0
	DECLARE @column_definition INT
	DECLARE @getcolumn_definition CURSOR
	SET @getcolumn_definition = CURSOR FOR
	SELECT n 
	FROM dbo.seq
	WHERE n <= 20
	OPEN @getcolumn_definition
	FETCH NEXT
	FROM @getcolumn_definition INTO @column_definition
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @cnt = @cnt+ 1	
			 
		SET @sql = @sql 
				+ ' SELECT clm' + CAST( @column_definition AS VARCHAR(5)) + '_label udf_column, clm' + CAST( @column_definition AS VARCHAR(5)) + '_udf_id udf_id
					, ' + CAST(@cnt AS VARCHAR(5)) + ' col_order 
				FROM generic_mapping_definition WHERE mapping_table_id =  ' + @generic_mapping_ids + CASE WHEN CAST(@cnt AS VARCHAR(5)) = '20' THEN ' ' ELSE ' UNION ALL' END
	FETCH NEXT
	FROM @getcolumn_definition INTO @column_definition
	END
	CLOSE @getcolumn_definition
	DEALLOCATE @getcolumn_definition
		
	IF OBJECT_ID('tempdb..#udf_static_data_mappping') IS NOT NULL 
		DROP TABLE #udf_static_data_mappping
		
	CREATE TABLE #udf_static_data_mappping(static_data_code VARCHAR(1000), col_order INT, udf_id INT, orginal_code VARCHAR(1000))

	SET @sql = 'INSERT INTO #udf_static_data_mappping(static_data_code, col_order, udf_id)
				SELECT udf_column, col_order, udf_id FROM ( ' + @sql + ') z WHERE z.udf_column <> '''''
	EXEC spa_print @sql 
	EXEC( @sql)

	UPDATE usdm
	SET orginal_code = udft.Field_label
	FROM #udf_static_data_mappping usdm
	INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = usdm.udf_id
 
 	DECLARE @sql_static_data_code VARCHAR(1000)
	DECLARE @sql_col_order INT
	DECLARE @sql_query VARCHAR(5000)
	DECLARE @orginal_code VARCHAR(1000)
	DECLARE @getsql_query CURSOR
	SET @getsql_query = CURSOR FOR
	SELECT static_data_code, col_order, sql_string, orginal_code
	FROM #udf_static_data_mappping usdm 
	INNER JOIN user_defined_fields_template uddft ON uddft.Field_label = usdm.orginal_code
	WHERE sql_string <> ''
	OPEN @getsql_query
	FETCH NEXT
	FROM @getsql_query INTO @sql_static_data_code, @sql_col_order, @sql_query, @orginal_code
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @sql = 'INSERT INTO #generic_values
					SELECT clm' + CAST(@sql_col_order AS VARCHAR(10))  + '_value
						,  ''clm' + CAST(@sql_col_order AS VARCHAR(10))  + '_value''
						, ' + CAST(@sql_col_order AS VARCHAR(10)) + '
						, generic_mapping_values_id
					FROM generic_mapping_values WHERE mapping_table_id = ' + @generic_mapping_ids
				
		EXEC spa_print @sql 
		EXEC(@sql)

		IF CHARINDEX('FROM', @sql_query) > 0
		BEGIN
			SET @sql = 'INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)' 
				+ SUBSTRING(@sql_query, 0, CHARINDEX('FROM',  @sql_query)) + ', ''' + @sql_static_data_code + ''', ' + CAST(@sql_col_order AS VARCHAR(10)) 
				+ ', ''' + @orginal_code + ''' ' + SUBSTRING(@sql_query, CHARINDEX('FROM',  @sql_query), LEN(@sql_query))  

			EXEC spa_print @sql 
			EXEC(@sql)					
		END 

		IF CHARINDEX('UNION', @sql_query) > 0
		BEGIN
 
			SET @sql = 'INSERT INTO #sql_query_data_col_exec
						' + @sql_query 

			EXEC spa_print @sql 
			EXEC(@sql)
			
			INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)
			SELECT primary_id, [code], @sql_static_data_code , @sql_col_order, @orginal_code FROM #sql_query_data_col_exec
		END 

		IF CHARINDEX('EXEC', @sql_query) > 0
		BEGIN
			BEGIN TRY
				SET @sql = 'INSERT INTO #sql_query_data_col_exec
						' + @sql_query 

				EXEC spa_print @sql 
				EXEC(@sql)

				IF EXISTS(SELECT 1 FROM #sql_query_data_col_exec)
				BEGIN
				INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)
				SELECT primary_id, [code], @sql_static_data_code , @sql_col_order, @orginal_code FROM #sql_query_data_col_exec
				END
				ELSE 
				BEGIN 
					INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)
					SELECT NULL primary_id, @sql_static_data_code [code], @sql_static_data_code , @sql_col_order, @orginal_code  
				END
			END TRY
			BEGIN CATCH
				SET @sql = 'INSERT INTO #sql_query_data_col_exec3
						' + @sql_query 
				
				EXEC spa_print @sql 
				EXEC(@sql)

				IF EXISTS(SELECT 1 FROM #sql_query_data_col_exec3)
				BEGIN
				INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)
				SELECT primary_id, [code], @sql_static_data_code , @sql_col_order, @orginal_code FROM #sql_query_data_col_exec3
				END
				ELSE 
				BEGIN 
					INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)
					SELECT NULL primary_id, @sql_static_data_code [code], @sql_static_data_code , @sql_col_order, @orginal_code  

				END
			END CATCH			 
		END
	FETCH NEXT
	FROM @getsql_query INTO @sql_static_data_code, @sql_col_order, @sql_query, @orginal_code
	END
	CLOSE @getsql_query
	DEALLOCATE @getsql_query	
	  
	SELECT sqd.*, gv.value , gv.col_names, generic_mapping_values_id, uddft.sql_string
	INTO #sql_query_data_col_final
	FROM #generic_values gv 
	INNER JOIN #sql_query_data_col sqd ON sqd.col_order = gv.col_order  
		AND ISNULL(sqd.primary_id, '') = ISNULL(gv.[value], '')
	INNER JOIN user_defined_fields_template uddft ON uddft.Field_label = sqd.orginal_code
		  
	DECLARE @non_combo CURSOR
	SET @non_combo = CURSOR FOR
	SELECT static_data_code, col_order
	FROM #udf_static_data_mappping usdm 
	INNER JOIN user_defined_fields_template uddft ON uddft.Field_label = usdm.orginal_code
	WHERE sql_string IS NULL OR sql_string = ''
	OPEN @non_combo
	FETCH NEXT
	FROM @non_combo INTO @sql_static_data_code, @sql_col_order 
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @sql = '
					INSERT INTO #sql_query_data_col_final (
							static_data_code	
						, col_order	
						, code	
						, primary_id	
						, orginal_code	
						, value	
						, col_names	
						, generic_mapping_values_id)
					SELECT  '''+ @sql_static_data_code + ''' static_data_code, ' + CAST (@sql_col_order AS VARCHAR(100)) 
						+ ' col_order
						, clm' + CAST (@sql_col_order AS VARCHAR(100)) + '_value code
						, clm' + CAST (@sql_col_order AS VARCHAR(100)) + '_value primary_id
						, '''+ @sql_static_data_code + ''' orginal_code
						, clm' + CAST (@sql_col_order AS VARCHAR(100)) + '_value value
						, ''clm' + CAST (@sql_col_order AS VARCHAR(100)) + '_value'' col_names
						, generic_mapping_values_id
					FROM generic_mapping_values WHERE mapping_table_id = ' + @generic_mapping_ids

		EXEC(@sql)
	FETCH NEXT
	FROM @non_combo INTO @sql_static_data_code, @sql_col_order 
	END
	CLOSE @non_combo
	DEALLOCATE @non_combo	
		
	DECLARE @max_cnt INT
	SELECT @max_cnt = MAX(col_order) FROM #sql_query_data_col_final

	BEGIN TRY 
	BEGIN TRAN
		SET @sql = 'SELECT 
						 isp.[mapping_table_id]
						, ' + CASE WHEN @flag = 'export_rule_copy_as' THEN + '''' + @copy_as + '''' ELSE 'isp.[mapping_name]' END + ' [mapping_name]
						, isp.[total_columns_used]
						, isp.[system_defined]
						, isp.[function_ids]
					FROM generic_mapping_header isp				 
					INNER JOIN dbo.FNASplit(''' + @generic_mapping_ids + ''', '','') itm ON itm.item = isp.mapping_table_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
	  
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ' "generic_mapping_header":' +  @json_output

		SET @sql = 'SELECT 
						 isp.generic_mapping_definition_id
						, isp.[mapping_table_id]
						, isp.[clm1_label]
						, isp.[clm1_udf_id]
						, isp.[clm2_label]
						, isp.[clm2_udf_id]
						, isp.[clm3_label]
						, isp.[clm3_udf_id]
						, isp.[clm4_label]
						, isp.[clm4_udf_id]
						, isp.[clm5_label]
						, isp.[clm5_udf_id]
						, isp.[clm6_label]
						, isp.[clm6_udf_id]
						, isp.[clm7_label]
						, isp.[clm7_udf_id]
						, isp.[clm8_label]
						, isp.[clm8_udf_id]
						, isp.[clm9_label]
						, isp.[clm9_udf_id]
						, isp.[clm10_label]
						, isp.[clm10_udf_id]
						, isp.[clm11_label]
						, isp.[clm11_udf_id]
						, isp.[clm12_label]
						, isp.[clm12_udf_id]
						, isp.[clm13_label]
						, isp.[clm13_udf_id]
						, isp.[clm14_label]
						, isp.[clm14_udf_id]
						, isp.[clm15_label]
						, isp.[clm15_udf_id]
						, isp.[clm16_label]
						, isp.[clm16_udf_id]
						, isp.[clm17_label]
						, isp.[clm17_udf_id]
						, isp.[clm18_label]
						, isp.[clm18_udf_id]
						, isp.[clm19_label]
						, isp.[clm19_udf_id]
						, isp.[clm20_label]
						, isp.[clm20_udf_id]
						, isp.[unique_columns_index]
						, isp.[required_columns_index]
						, isp.[primary_column_index]
					FROM generic_mapping_definition isp				 
					INNER JOIN dbo.FNASplit(''' + @generic_mapping_ids + ''', '','') itm ON itm.item = isp.mapping_table_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
	  
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "generic_mapping_definition":' +  @json_output

		SET @sql = 'SELECT 
						isp.[generic_mapping_values_id]
						, isp.[mapping_table_id]						 
						, static_data_code	
						, col_order	
						, code	
						, primary_id	
						, orginal_code	
						, value	
						, col_names			
						, sql_string
 					FROM generic_mapping_values isp		
					INNER JOIN #sql_query_data_col_final sqd ON sqd.generic_mapping_values_id = isp.generic_mapping_values_id
					INNER JOIN dbo.FNASplit(''' + @generic_mapping_ids + ''', '','') itm ON itm.item = isp.mapping_table_id '
		EXEC spa_print @sql 
		--EXEC(@sql)
		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "generic_mapping_values":' +  @json_output

		SET @sql = 'SELECT sdv.[type_id], sdv.[value_id], sdv.[code], sdv.[description]
					FROM #udf_static_data_mappping usdm 
					INNER JOIN static_data_value sdv ON sdv.code = usdm.orginal_code
					WHERE sdv.[type_id] IN (5500, 110300)'
		EXEC spa_print @sql 
		--EXEC(@sql)

		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "static_data_value":' +  @json_output

		SET @sql = '
				SELECT  uddft.[field_name]
						, usdm.orginal_code [Field_label]
						, uddft.[Field_type]
						, uddft.[data_type]
						, uddft.[is_required]
						, uddft.[sql_string]
						, uddft.[udf_type]
						, uddft.[sequence]
						, uddft.[field_size]
						, uddft.[field_id]
						, usdm.col_order
				FROM #udf_static_data_mappping usdm 
				INNER JOIN user_defined_fields_template uddft ON uddft.Field_label = usdm.orginal_code'
		 
		EXEC spa_print @sql 
		--EXEC(@sql)

		EXEC spa_build_json @sql, '', @json_output OUTPUT
		SET @json_final_output = @json_final_output + ', "user_defined_fields_template":' +  @json_output
		
		
		SET @json_final_output = @json_final_output + '}'

		DECLARE @export_file_name VARCHAR(MAX)
		SELECT @export_file_name = mapping_name FROM generic_mapping_header WHERE mapping_table_id = @generic_mapping_ids

		SELECT REPLACE(REPLACE(@json_final_output, CHAR(13), ''), CHAR(10), '')  [json_output]
			, CASE WHEN @flag = 'export_rule_copy_as' THEN @copy_as ELSE @export_file_name END export_file_name
	COMMIT TRAN 
	END TRY 
	BEGIN CATCH 
		--SELECT ERROR_MESSAGE()
		IF @@TRANCOUNT > 0
		   ROLLBACK  
		EXEC spa_ErrorHandler -1
		   , 'Import/Export FX'
		   , 'spa_generic_mapping'
		   , 'Error'
		   , 'Error Exporting Rule'
		   , 'Contact Technical Suporrt.'   		 
	END CATCH
END 
ELSE IF @flag = 'import_generic_data_mapping'
BEGIN 	
	IF @import_file_name IS NOT NULL
	BEGIN
		SET @import_string = dbo.FNAReadFileContents(@import_file);			 
	END
	
	IF OBJECT_ID('tempdb..#gmv_pre_mapping') IS NOT NULL 
		DROP TABLE #gmv_pre_mapping

 	CREATE TABLE #gmv_pre_mapping(
		code							VARCHAR(1000)
		, col_names						VARCHAR(1000)
		, col_order						VARCHAR(1000)
		, generic_mapping_values_id		VARCHAR(1000)
		, mapping_table_id				VARCHAR(1000)
		, orginal_code					VARCHAR(1000)
		, primary_id					VARCHAR(1000)
		, sql_string					VARCHAR(1000)
		, static_data_code				VARCHAR(1000)
		, [value]						VARCHAR(1000)
		, is_value_missing				VARCHAR(1000)
	)

	SET @process_id = dbo.FNAGETNEWID()
	SET @user_name = dbo.FNADBUser() 
	SET @generic_mapping_header			= dbo.FNAProcessTableName('generic_mapping_header', @user_name, @process_id)
	SET @generic_mapping_definition		= dbo.FNAProcessTableName('generic_mapping_definition', @user_name, @process_id)
	SET @generic_mapping_values			= dbo.FNAProcessTableName('generic_mapping_values', @user_name, @process_id)
	SET @static_data_value				= dbo.FNAProcessTableName('static_data_value', @user_name, @process_id)
	SET @user_defined_fields_template	= dbo.FNAProcessTableName('user_defined_fields_template', @user_name, @process_id)
 
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'generic_mapping_header', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @generic_mapping_header, @return_output = 0 
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'generic_mapping_definition', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @generic_mapping_definition, @return_output = 0 
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'generic_mapping_values', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @generic_mapping_values, @return_output = 0 
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'static_data_value', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @static_data_value, @return_output = 0 
	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'user_defined_fields_template', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @user_defined_fields_template, @return_output = 0 
 
	SET @sql = 	'IF OBJECT_ID(''' + @generic_mapping_header + ''') IS NULL SELECT *  INTO ' + @generic_mapping_header + ' FROM generic_mapping_header WHERE 1 = 2'
	SET @sql = @sql + 'IF OBJECT_ID(''' + @generic_mapping_definition + ''') IS NULL SELECT *  INTO ' + @generic_mapping_definition + ' FROM generic_mapping_definition WHERE 1 = 2'
	SET @sql = @sql + 'IF OBJECT_ID(''' + @generic_mapping_values + ''') IS NULL SELECT *  INTO ' + @generic_mapping_values + ' FROM #gmv_pre_mapping WHERE 1 = 2'
	SET @sql = @sql + 'IF OBJECT_ID(''' + @static_data_value + ''') IS NULL SELECT *  INTO ' + @static_data_value + ' FROM static_data_value WHERE 1 = 2'
	SET @sql = @sql + 'IF OBJECT_ID(''' + @user_defined_fields_template + ''') IS NULL SELECT *  INTO ' + @user_defined_fields_template + ' FROM user_defined_fields_template WHERE 1 = 2'

	EXEC spa_print @sql
	EXEC(@sql)
		
	CREATE TABLE #mappind_ids( mapping_table_id INT)

	IF @copy_as IS NOT NULL 
	BEGIN 
		SET @sql = 'UPDATE ' + @generic_mapping_header + ' SET mapping_name = ''' + @copy_as + ''''
		EXEC spa_print @sql
		EXEC(@sql) 
	END

	SET @sql = 'INSERT INTO #mappind_ids 
				SELECT DISTINCT generic_mapping_values_id
				FROM ' + @generic_mapping_values

	EXEC spa_print @sql
	EXEC(@sql) 

	SET @sql = 'INSERT INTO #gmv_pre_mapping(	
					code							
					, col_names						
					, col_order						
					, generic_mapping_values_id		
					, mapping_table_id				
					, orginal_code					
					, primary_id					
					, sql_string					
					, static_data_code				
					, [value])
				SELECT code							
					, col_names						
					, col_order						
					, generic_mapping_values_id		
					, mapping_table_id				
					, orginal_code					
					, primary_id					
					, sql_string					
					, static_data_code				
					, [value] 
				FROM ' + @generic_mapping_values	 
	EXEC spa_print @sql
	EXEC(@sql) 

	DECLARE @missing_static_data_values VARCHAR(1000)
	--select * from #gmv_pre_mapping
	--static_data_missing
	IF EXISTS(SELECT 1 FROM #gmv_pre_mapping gpm
			LEFT JOIN static_data_value sdv ON sdv.code = gpm.orginal_code
				AND sdv.type_id IN (5500, 110300)
				WHERE sdv.value_id IS NULL)
	BEGIN 	
		SELECT @missing_static_data_values = STUFF(( SELECT DISTINCT ',' +  gpm.orginal_code
												FROM #gmv_pre_mapping gpm
												LEFT JOIN static_data_value sdv ON sdv.code = gpm.orginal_code
													AND sdv.type_id IN (5500, 110300)
												WHERE sdv.value_id IS NULL
												FOR XML PATH('')
												), 1, 1, '')

		SET @missing_static_data_values = 'Following Static Data Values are missing in the system (' + @missing_static_data_values + '). Please add the Static Data Values.'	
		
		EXEC spa_ErrorHandler -1
		   , 'Import/Export Rules'
		   , 'spa_generic_mapping'
		   , 'Error'
		   , @missing_static_data_values
		   , 'Contact Technical Support.'   
		RETURN
	END

	DECLARE @_code VARCHAR(1000)
	DECLARE @sql_string VARCHAR(1000)
	DECLARE @_col_order INT
	DECLARE @_orginal_code VARCHAR(1000)
	DECLARE @getsql_query_export CURSOR
	SET @getsql_query_export = CURSOR FOR
	SELECT DISTINCT col_order, sql_string, orginal_code
	FROM #gmv_pre_mapping		
	WHERE sql_string <> ''
	OPEN @getsql_query_export
	FETCH NEXT
	FROM @getsql_query_export INTO  @_col_order, @sql_string, @_orginal_code
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF CHARINDEX('FROM', @sql_string) > 0
		BEGIN
			SET @sql = 'INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)' 
				+ SUBSTRING(@sql_string, 0, CHARINDEX('FROM',  @sql_string)) + ', ''' + @_orginal_code + ''', ' + CAST(@_col_order AS VARCHAR(10)) 
				+ ', ''' + @_orginal_code + ''' ' + SUBSTRING(@sql_string, CHARINDEX('FROM',  @sql_string), LEN(@sql_string))  

			EXEC spa_print @sql 
			EXEC(@sql)					
		END 

		IF CHARINDEX('UNION', @sql_string) > 0
		BEGIN
			SET @sql = 'INSERT INTO #sql_query_data_col_exec
						' + @sql_string 

			EXEC spa_print @sql 
			EXEC(@sql)
			
			INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)
			SELECT primary_id, [code], @_orginal_code , @_col_order, @_orginal_code FROM #sql_query_data_col_exec
		END 

		IF CHARINDEX('EXEC', @sql_string) > 0
		BEGIN
			BEGIN TRY
				SET @sql = 'INSERT INTO #sql_query_data_col_exec
						' + @sql_string 

				EXEC spa_print @sql 
				EXEC(@sql)

				IF EXISTS(SELECT 1 FROM #sql_query_data_col_exec)
				BEGIN
				INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)
				SELECT primary_id, [code], @_orginal_code , @_col_order, @_orginal_code FROM #sql_query_data_col_exec
				END
				ELSE 
				BEGIN 
					INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)
					SELECT NULL primary_id, @_orginal_code [code], @_orginal_code , @_col_order, @_orginal_code  
				END
			END TRY
			BEGIN CATCH
				SET @sql = 'INSERT INTO #sql_query_data_col_exec3
						' + @sql_string 
			
				EXEC spa_print @sql 
				EXEC(@sql)

				IF EXISTS(SELECT 1 FROM #sql_query_data_col_exec3)
				BEGIN
				INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)
				SELECT primary_id, [code], @_orginal_code , @_col_order, @_orginal_code FROM #sql_query_data_col_exec3
				END
				ELSE 
				BEGIN 
					INSERT INTO #sql_query_data_col(primary_id, [code], static_data_code, col_order, orginal_code)
					SELECT NULL primary_id, @_orginal_code [code], @_orginal_code , @_col_order, @_orginal_code  
				END
			END CATCH			 
		END
	FETCH NEXT
	FROM @getsql_query_export INTO @_col_order, @sql_string, @_orginal_code
	END
	CLOSE @getsql_query_export
	DEALLOCATE @getsql_query_export	

	--remapping ids for generic mappign values for combo
	UPDATE gmv
	SET gmv.primary_id = sqd.primary_id
		, gmv.value = sqd.primary_id
		, gmv.is_value_missing = CASE WHEN sqd.primary_id IS NULL THEN CASE WHEN ISNULL(gmv.value, '') = ISNULL(sqd.primary_id, '') THEN 'n' ELSE 'y' END ELSE 'n' END
	FROM #gmv_pre_mapping gmv 
	LEFT JOIN #sql_query_data_col sqd ON sqd.code = gmv.code 
		AND gmv.col_order = sqd.col_order
	WHERE gmv.sql_string <> ''


	DECLARE @missing_mapped VARCHAR(1000) = NULL
 	 
	IF EXISTS(SELECT 1 FROM #gmv_pre_mapping WHERE is_value_missing = 'y')
	BEGIN 	
		SELECT @missing_mapped = STUFF(( SELECT DISTINCT ',' +  static_data_code
										FROM #gmv_pre_mapping
										WHERE is_value_missing = 'y'
										FOR XML PATH('')
										), 1, 1, '')

		SET @missing_mapped = 'One or more values are missing for following (' + @missing_mapped + '). Please check the imported mapping.'
	
		--select @missing_mapped
		 
	END

	BEGIN TRY 
	BEGIN TRAN 
		SET @sql = 'INSERT INTO #generic_mapping_name(mapping_name, mapping_table_id)
					SELECT ir.mapping_name, ir.mapping_table_id 
					FROM ' + @generic_mapping_header + ' a
					INNER JOIN generic_mapping_header ir ON ir.mapping_name = a.mapping_name 
					WHERE 1 = 1'

		EXEC spa_print @sql
 		EXEC(@sql)

		IF EXISTS(SELECT 1 FROM #generic_mapping_name)
		BEGIN
			SELECT @to_import_generic_mapping_id = mapping_table_id FROM #generic_mapping_name
		END 
		ELSE
		BEGIN 
			SELECT @to_import_generic_mapping_id = -1		
		END 

		IF OBJECT_ID('tempdb..#static_data_value') IS NOT NULL
			DROP TABLE #static_data_value
		
		CREATE TABLE #static_data_value ([code] VARCHAR(MAX) COLLATE DATABASE_DEFAULT, [description] VARCHAR(MAX) COLLATE DATABASE_DEFAULT, [type_id] INT, [value_id] INT)

		SET @sql  = 'INSERT INTO #static_data_value ([code], [description], [type_id], [value_id])
					SELECT [code], [description], [type_id], [value_id] FROM ' + @static_data_value
		EXEC spa_print @sql
		EXEC(@sql) 

		SET @sql = ''
		DECLARE @code VARCHAR(1000)
		DECLARE @description VARCHAR(1000)
		DECLARE @type_id INT
		DECLARE @value_id INT

		IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
			DROP TABLE #insert_output_sdv_external
	 
		CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

 		DECLARE @static_getcolumn_definition CURSOR
		SET @static_getcolumn_definition = CURSOR FOR
		SELECT [code], [description], [type_id], [value_id]
		FROM #static_data_value
		OPEN @static_getcolumn_definition
		FETCH NEXT
		FROM @static_getcolumn_definition INTO @code, @description, @type_id, @value_id 
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sql = @sql +  ' INSERT INTO #insert_output_sdv_external 
								SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = ''' + @code + ''' AND TYPE_ID IN (5500, 110300)
						'
		FETCH NEXT
		FROM @static_getcolumn_definition INTO @code, @description, @type_id, @value_id 
		END
		CLOSE @static_getcolumn_definition
		DEALLOCATE @static_getcolumn_definition

		EXEC spa_print @sql
		EXEC(@sql) 

		CREATE TABLE #temp_user_defined_fields_template(udf_template_id INT
														, field_name VARCHAR(1000)
														, Field_label VARCHAR(MAX))
		--INSERT INTO user_defined_fields_template
		SET @sql = 'MERGE user_defined_fields_template AS stm
					USING (SELECT 
								a.value_id field_name
							, udft.Field_label
							, udft.Field_type
							, udft.data_type
							, udft.is_required
							, udft.sql_string
							, udft.udf_type
							, udft.sequence
							, udft.field_size
							, a.value_id field_id	 								
						FROM ' + @user_defined_fields_template + ' udft 
					INNER JOIN #insert_output_sdv_external a ON a.type_name = udft.field_label) AS sd
					ON stm.Field_label = sd.Field_label
 					WHEN MATCHED THEN UPDATE
					SET
						stm.field_name		= sd.field_name
						, stm.Field_type	= sd.Field_type
						, stm.data_type		= sd.data_type
						, stm.is_required	= sd.is_required
						, stm.sql_string	= sd.sql_string
						, stm.udf_type		= sd.udf_type
						, stm.sequence		= sd.sequence
						, stm.field_size	= sd.field_size
						, stm.field_id		= sd.field_id		
					WHEN NOT MATCHED THEN
					INSERT(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)						 
					VALUES(field_name, sd.Field_label, sd.Field_type, sd.data_type, sd.is_required, sd.sql_string, sd.udf_type, sd.sequence, sd.field_size, sd.field_id)
					OUTPUT INSERTED.udf_template_id, INSERTED.field_name, INSERTED.Field_label INTO #temp_user_defined_fields_template ;		  
		'		 
		EXEC spa_print @sql
		EXEC(@sql) 

		SET @sql = ' 
					MERGE generic_mapping_header AS stm
					USING (SELECT function_ids
							, mapping_name
							, mapping_table_id	
							, system_defined	
							, total_columns_used
					FROM ' + @generic_mapping_header + ') AS sd ON stm.mapping_name = sd.mapping_name
 					WHEN MATCHED THEN UPDATE
					SET 
						stm.function_ids		 = sd.function_ids					 
						, stm.system_defined	 = sd.system_defined	 
						, stm.total_columns_used = sd.total_columns_used 
					WHEN NOT MATCHED THEN
					INSERT(function_ids
							, mapping_name
							, system_defined	
							, total_columns_used)
					VALUES(sd.function_ids
							, sd.mapping_name
							, sd.system_defined	
							, sd.total_columns_used);
					'
		EXEC spa_print @sql
		EXEC(@sql) 

		DECLARE @system_generic_mapping_id INT 

		IF OBJECT_ID('tempdb..#system_generic_mapping_id') IS NOT NULL
			DROP TABLE #system_generic_mapping_id 

		CREATE TABLE #system_generic_mapping_id(system_generic_mapping_id INT) 

		SET @sql = 'INSERT INTO #system_generic_mapping_id
					SELECT b.mapping_table_id								 
					FROM ' + @generic_mapping_header + '  a
					INNER JOIN generic_mapping_header b ON a.mapping_name = b.mapping_name
					'
		EXEC spa_print @sql
		EXEC(@sql)

		SELECT @system_generic_mapping_id = system_generic_mapping_id FROM #system_generic_mapping_id
		
		IF OBJECT_ID('tempdb..#generic_definition_mapping') IS NOT NULL
			DROP TABLE #generic_definition_mapping

 		CREATE TABLE #generic_definition_mapping(col_order  INT 
											, Field_label VARCHAR(1000) COLLATE DATABASE_DEFAULT 
											, udf_template_id INT )
											 
		SET @sql = 'INSERT INTO #generic_definition_mapping
					SELECT DISTINCT udft_temp.col_order, ISNULL(static_data_code, udft_temp.field_label) Field_label, udft.udf_template_id	
					FROM ' + @user_defined_fields_template + ' udft_temp 
					INNER JOIN #insert_output_sdv_external a ON a.type_name = udft_temp.field_label 
					INNER JOIN user_defined_fields_template udft ON udft.field_label = udft_temp.field_label 
					LEFT JOIN ' + @generic_mapping_values + ' stt ON stt.orginal_code = udft.Field_label
					'
		EXEC spa_print @sql
		EXEC(@sql)
			
		SET @sql = ''
		DECLARE @value VARCHAR(MAX) = ''
 
		DECLARE @col_order 			VARCHAR(100)
		DECLARE @field_label		VARCHAR(100)
		DECLARE @udf_template_id	VARCHAR(100) 	

		DECLARE @getcolumn_definition_export CURSOR
		SET @getcolumn_definition_export = CURSOR FOR
		SELECT col_order, Field_label, udf_template_id	 
		FROM #generic_definition_mapping
	
		OPEN @getcolumn_definition_export
		FETCH NEXT
		FROM @getcolumn_definition_export INTO @col_order, @field_label, @udf_template_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sql = @sql + ', clm' + CAST( @col_order AS VARCHAR(5)) + '_label, clm' + CAST( @col_order AS VARCHAR(5)) + '_udf_id'
			SET @value = @value + ', ''' + @field_label + ''' AS clm' + CAST( @col_order AS VARCHAR(5)) + '_label, ' + @udf_template_id +  ' AS clm' 
						+ CAST( @col_order AS VARCHAR(5)) + '_udf_id'
		FETCH NEXT
		FROM @getcolumn_definition_export INTO @col_order, @field_label, @udf_template_id
		END
		CLOSE @getcolumn_definition_export
		DEALLOCATE @getcolumn_definition_export

		DELETE FROM generic_mapping_values WHERE mapping_table_id = @system_generic_mapping_id
		DELETE FROM generic_mapping_definition WHERE mapping_table_id = @system_generic_mapping_id
		--/*		

		DECLARE @final_sql VARCHAR(MAX)

		SET @final_sql = 'INSERT INTO generic_mapping_definition(mapping_table_id, [unique_columns_index], [required_columns_index], [primary_column_index]' + @sql + ')' + '
						SELECT ' + CAST(@system_generic_mapping_id AS VARCHAR(100))  + ' mapping_table_id, [unique_columns_index], [required_columns_index], [primary_column_index]' 
						+ @value + ' FROM ' + @generic_mapping_definition 
 
		EXEC spa_print @final_sql
		EXEC(@final_sql)
		
		DECLARE @gmv_ins VARCHAR(MAX)
		DECLARE @gmv_final VARCHAR(MAX)
		DECLARE @sql_data VARCHAR(MAX)
 
		DECLARE @gmv INT
		DECLARE @getgmv CURSOR
		SET @getgmv = CURSOR FOR
		SELECT mapping_table_id  
		FROM #mappind_ids 
		OPEN @getgmv
		FETCH NEXT
		FROM @getgmv INTO @gmv
		WHILE @@FETCH_STATUS = 0
		BEGIN	 
			SELECT @gmv_ins = STUFF(( SELECT ',' + col_names 
							FROM #gmv_pre_mapping
							WHERE generic_mapping_values_id = CAST(@gmv AS VARCHAR(100))
							FOR XML PATH('')
							), 1, 1, '')
			 
 			SELECT @sql_data = STUFF(( SELECT ',''' + ISNULL([value], '') + ''' ' + col_names 
							FROM #gmv_pre_mapping
							WHERE generic_mapping_values_id = CAST(@gmv AS VARCHAR(100)) 
							FOR XML PATH('')
							), 1, 1, '')

			SET @gmv_final = ' 
							INSERT INTO generic_mapping_values (mapping_table_id, ' + @gmv_ins + ')
							SELECT ' + CAST(@system_generic_mapping_id AS VARCHAR(100))  + ' mapping_table_id, ' + @sql_data
								
			EXEC spa_print @gmv_final
			EXEC (@gmv_final)
		FETCH NEXT
		FROM @getgmv INTO @gmv
		END
		CLOSE @getgmv
		DEALLOCATE @getgmv

		EXEC spa_ErrorHandler 0
			, 'Import/Export Rules'
			, 'spa_generic_mapping'
			, 'Success'
			, 'Changes has been saved successfully.'
			, @missing_mapped

		--EXEC('SELECT * FROM ' + @generic_mapping_header		)
		--EXEC('SELECT * FROM ' + @generic_mapping_definition		)
		--EXEC('SELECT * FROM ' + @generic_mapping_values		)
		
		--ROLLBACK TRAN RETURN 
		COMMIT TRAN 
	END TRY 
	BEGIN CATCH 
		--SELECT ERROR_MESSAGE()
		IF @@TRANCOUNT > 0
		   ROLLBACK TRAN
		EXEC spa_ErrorHandler -1
		   , 'Import/Export Rules'
		   , 'spa_generic_mapping'
		   , 'Error'
		   , 'Error Importing Generic Mapping'
		   , 'Contact Technical Suporrt.'   
		 
	END CATCH
END 
ELSE IF @flag = 'confirm_override'
BEGIN 
	IF @import_file_name IS NOT NULL
	BEGIN
		SET @import_string = dbo.FNAReadFileContents(@import_file);	
	END
		
	SET @process_id = dbo.FNAGETNEWID()
	SET @user_name = dbo.FNADBUser() 

	SET @generic_mapping_header = dbo.FNAProcessTableName('generic_mapping_header', @user_name, @process_id)

	EXEC spa_parse_json @flag = 'simple_parse', @filter_tag = 'generic_mapping_header', @json_string = @import_string, @json_full_path=@import_file, @output_process_table = @generic_mapping_header, @return_output = 0 
	
	SET @sql = 'INSERT INTO #generic_mapping_name(mapping_name, mapping_table_id)
				SELECT ir.mapping_name, ir.mapping_table_id 
				FROM ' + @generic_mapping_header + ' a
				INNER JOIN generic_mapping_header ir ON ir.mapping_name = ' + CASE WHEN @copy_as IS NULL THEN 'a.mapping_name ' ELSE '''' + @copy_as + '''' END + '
				WHERE 1 = 1'

	EXEC spa_print @sql
 	EXEC(@sql)

	IF EXISTS(SELECT 1 FROM #generic_mapping_name)
	BEGIN 
		SELECT 'r' confirm_override, @import_file_name import_file_name, @copy_as copy_as --confirmation requried
	END 
	ELSE 
	BEGIN 
		SELECT 'n' confirm_override, @import_file_name import_file_name, @copy_as copy_as --confirmation not requried
	END
END


GO


