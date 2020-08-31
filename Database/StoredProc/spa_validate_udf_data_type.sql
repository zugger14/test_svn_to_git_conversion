IF OBJECT_ID(N'spa_validate_udf_data_type', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_validate_udf_data_type
GO 
/**
	Description: Validate UDF data according to field type defined in user_defined_fields_template.

	Parameters
	@flag					:	Operation flag. 'data_validate' used for UDF data type validation according to column definition.			
	@process_id				:	Unique identifier of import process.		
	@validate_table_name	:	Table with data to validate.
	@rules_id				:	Import rule id.
**/

CREATE PROC [dbo].[spa_validate_udf_data_type] 
	@flag					NCHAR(50) = 'data_validate',
	@process_id				NVARCHAR(50),
	@validate_table_name	NVARCHAR(150),
	@rules_id				INT = NULL
AS 
/** * DEBUG QUERY START *
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'farrms_admin';		
DECLARE @process_id			NVARCHAR(50)= 'A397A316_2C9A_4949_9B33_936FF6017A56',
	@validate_table_name	NVARCHAR(150)= 'adiha_process.dbo.ixp_source_deal_template_0_farrms_admin_A397A316_2C9A_4949_9B33_936FF6017A56',
	@rules_id				INT = 14148,
	@flag					NCHAR(1)= 'data_validate'
	
	select @process_id= '9B4E7306_C8AC_48FA_B4AA_F7F8457D0FF1'
	, @validate_table_name = 'adiha_process.dbo.ixp_source_deal_template_0_farrms_admin_9B4E7306_C8AC_48FA_B4AA_F7F8457D0FF1'
	, @rules_id				= 12962
	, @flag					= 'data_validate'
	
EXEC spa_drop_all_temp_table		
--drop table #import_status_pre
--drop table #error_status_pre
--drop table #collect_error_data
--drop table  #ixp_import_data_mapping
-- * DEBUG QUERY END **/
DECLARE @tablename		NVARCHAR(200)
DECLARE @sql				NVARCHAR(MAX)
DECLARE @source_desc		NVARCHAR(50) = ''

SELECT TOP 1 @tablename = it.ixp_tables_name
FROM ixp_import_data_mapping iidm
INNER JOIN ixp_tables it ON it.ixp_tables_id = iidm.dest_table_id
WHERE iidm.ixp_rules_id = @rules_id

CREATE TABLE #import_status_pre (
	temp_id			INT,
	process_id		NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	ErrorCode		NVARCHAR(50) COLLATE DATABASE_DEFAULT,
	MODULE			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	[Source]		NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	[TYPE]			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	[description]	NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
	[nextstep]		NVARCHAR(250) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #error_status_pre (temp_id INT
	, error_no INT
	, template_values NVARCHAR(2000) COLLATE DATABASE_DEFAULT
	)

CREATE TABLE #collect_error_data (temp_id INT
	, error_no INT
	, column_name NVARCHAR(200) COLLATE DATABASE_DEFAULT
	, column_value NVARCHAR(2000) COLLATE DATABASE_DEFAULT
	)

DECLARE
	@validate_field			NVARCHAR(50),
	@fld_type				NVARCHAR(30),
	@fld_length				INT
	, @user_login_id NVARCHAR(50) = dbo.FNADBUser()
	
DECLARE @tbl_ixp_columns NVARCHAR(200) = dbo.FNAProcessTableName('dyn_ixp_columns', @user_login_id, @process_id)
	, @tbl_ixp_import_data_mapping NVARCHAR(200) = dbo.FNAProcessTableName('dyn_ixp_import_data_mapping', @user_login_id, @process_id)
	, @source_ixp_column_mapping NVARCHAR(200) = dbo.FNAProcessTableName('source_ixp_column_mapping', @user_login_id, @process_id)

IF OBJECT_ID(@tbl_ixp_import_data_mapping) IS NULL
BEGIN
	SET @sql = 'SELECT iidm.*
		,IIF(iidm.source_column_name = '''',ic.ixp_columns_name,IIF(CHARINDEX(''['', iidm.source_column_name) > 0,SUBSTRING(iidm.source_column_name, CHARINDEX(''['', iidm.source_column_name) + 1, CHARINDEX('']'', iidm.source_column_name) - CHARINDEX(''['', iidm.source_column_name) - 1 ),iidm.source_column_name))
		valid_column_name 
		INTO ' + @tbl_ixp_import_data_mapping + ' 
		FROM ixp_rules ir
		INNER JOIN ixp_import_data_mapping iidm ON ir.ixp_rules_id = iidm.ixp_rules_id
		INNER JOIN ixp_tables it  ON iidm.dest_table_id = it.ixp_tables_id 
			AND it.ixp_tables_name = ''' + @tablename + '''
		INNER JOIN ixp_columns ic ON ic.ixp_table_id = it.ixp_tables_id
			AND ic.ixp_columns_id = iidm.dest_column
		WHERE iidm.ixp_rules_id = ' + CAST(@rules_id AS NVARCHAR(20))
	
		EXEC(@sql)
END

IF OBJECT_ID(@tbl_ixp_columns) IS NULL
BEGIN
	EXEC('SELECT ic.ixp_columns_id
			, ic.ixp_table_id
			, ic.ixp_columns_name
			, ic.column_datatype
			, ic.is_major
			, ic.header_detail
			, ic.seq
			, ic.datatype
			, ic.is_required
		INTO ' + @tbl_ixp_columns + '
		FROM ixp_tables it				
		INNER JOIN ixp_columns ic ON ic.ixp_table_id = it.ixp_tables_id
		WHERE it.ixp_tables_name = ''' + @tablename + '''')
END

-- Data Repetition Validation Starts
EXEC('
	DECLARE @column_name_list NVARCHAR(MAX) = NULL
		, @join_clause  NVARCHAR(MAX) = NULL
		, @des_column_name  NVARCHAR(MAX) = NULL
		, @des_column_value  NVARCHAR(MAX) = NULL
		, @sql  NVARCHAR(MAX) = NULL
	SELECT @column_name_list = COALESCE(@column_name_list + '', '' ,'''') + iidm.valid_column_name,
		@des_column_name = COALESCE(@des_column_name + '', '' ,'''') + ic.ixp_columns_name,
		@des_column_value = COALESCE(@des_column_value + '' + '''', '''' + '','''') + ''ISNULL(a.['' + ic.ixp_columns_name + ''], ''''NULL'''')'',
		@join_clause = COALESCE(@join_clause +'' AND '' ,'''') + ''ISNULL(a.['' + ic.ixp_columns_name + ''], -1) = ISNULL(b.['' + ic.ixp_columns_name + ''], -1)''
	FROM ' + @tbl_ixp_import_data_mapping + ' iidm
	INNER JOIN ' + @tbl_ixp_columns + ' ic ON ic.ixp_columns_id = iidm.dest_column
	WHERE ic.is_major = 1
	ORDER BY ic.seq ASC


	SET @sql = ''
		INSERT INTO #error_status_pre (temp_id, error_no, template_values)
		SELECT a.temp_id,
			10007,
			''''{
				"column_name"		: "'' +  @column_name_list + ''",
				"column_value"		: "'''' +'' +  @des_column_value + '' + ''''",
				"repetition_count"	: "'''' + CAST(b.notimes AS NVARCHAR) + ''''"
			}''''
		FROM ' + @validate_table_name + ' a
		LEFT JOIN #error_status_pre es ON a.temp_id = es.temp_id
		INNER JOIN (
			SELECT '' + @des_column_name + '', COUNT(1) notimes
			FROM ' + @validate_table_name + '
			GROUP BY '' + @des_column_name + ''
			HAVING COUNT(1) > 1
		) b ON 1 = 1
			AND es.temp_id IS NULL
			AND (
				''
				+ ISNULL(@join_clause, '' 1 = 1'') + ''
			)''

	EXEC spa_print ''Repeated source column name :- '', @column_name_list
	EXEC spa_print  ''Data Repetition script :- '', @sql
	EXEC(@sql)
')
---- Data Repetition Validation Ends

--UDF data type
IF OBJECT_ID('tempdb..#validate_udf_data_type') is not null DROP TABLE #validate_udf_data_type
CREATE TABLE #validate_udf_data_type(ixp_columns_name NVARCHAR(20) COLLATE DATABASE_DEFAULT
	, data_type NVARCHAR(100) COLLATE DATABASE_DEFAULT
	, data_length NVARCHAR(20) COLLATE DATABASE_DEFAULT
	, sql_string NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
	, field_id INT
	, field_type NVARCHAR(20) COLLATE DATABASE_DEFAULT
	, seq INT
	, is_required BIT
)
SET @sql = '
	INSERT INTO #validate_udf_data_type(ixp_columns_name, data_type, data_length, sql_string,field_id, field_type,seq,is_required)
	SELECT DISTINCT ic.ixp_columns_name
			, i.clm1 data_type
			, IIF(i.clm1 = ''numeric'',38,IIF(REPLACE(i.clm2,'')'','''')=''max'',-1,REPLACE(i.clm2,'')'',''''))) data_length
			, IIF(CHARINDEX(''sp'', LTRIM(udft.sql_string)) = 1, ''EXEC '' + udft.sql_string, NULLIF(udft.sql_string,'''')) sql_string
			, udft.field_id
			, udft.field_type
			, ic.seq
			, ic.is_required
	FROM ' + @tbl_ixp_import_data_mapping + ' iidm 
	INNER JOIN ' + @tbl_ixp_columns + ' ic ON ic.ixp_columns_id = iidm.dest_column
	INNER JOIN ' + @source_ixp_column_mapping + ' s1 ON s1.ixp_column_name = ic.ixp_columns_name
	INNER JOIN user_defined_fields_template udft ON udft.field_id = iidm.udf_field_id	
	OUTER APPLY(SELECT clm1,clm2 FROM dbo.FNASplitAndTranspose(udft.data_type,''('')) i
	WHERE 1 = 1
		AND NULLIF(iidm.udf_field_id, '''') IS NOT NULL
	'

EXEC(@sql)

DECLARE @field_id INT,@field_type NCHAR(1), @cmb_sql_string NVARCHAR(MAX), @cmb_pre_sql_string  NVARCHAR(MAX) = '', @is_required BIT

IF OBJECT_ID (N'tempdb..#udf_code_value_pair') IS NOT NULL
DROP TABLE #udf_code_value_pair

CREATE TABLE #udf_code_value_pair ([id] NVARCHAR(50) COLLATE DATABASE_DEFAULT 
	, [code] NVARCHAR(500) COLLATE DATABASE_DEFAULT 
	, [state] NVARCHAR(10) COLLATE DATABASE_DEFAULT DEFAULT 'enable')

BEGIN TRY
	IF CURSOR_STATUS('global','deal_udf_list') >= -1
	BEGIN
		IF CURSOR_STATUS('global','deal_udf_list') > -1
		BEGIN
			CLOSE deal_udf_list
		END
		DEALLOCATE deal_udf_list
	END
	
	-- Below logic is used to validate source_data type with table column definitions. This includes required, data type. datalength.
	DECLARE deal_udf_list CURSOR FOR
	SELECT ixp_columns_name, data_type, data_length, sql_string,field_id, field_type, is_required FROM #validate_udf_data_type ORDER BY seq
	OPEN deal_udf_list
	FETCH NEXT FROM deal_udf_list INTO @validate_field, @fld_type, @fld_length,@cmb_sql_string,@field_id,@field_type, @is_required
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		
		--Prevents same query execution.
		IF @field_type IN ('c','d') AND NULLIF(@cmb_sql_string,'') IS NOT NULL
		BEGIN
			IF @cmb_pre_sql_string <> @cmb_sql_string
			BEGIN					
				TRUNCATE TABLE #udf_code_value_pair
				BEGIN TRY					
					EXEC ('INSERT INTO #udf_code_value_pair([id],[code]) ' + @cmb_sql_string)
				END TRY
				BEGIN CATCH
					EXEC ('INSERT INTO #udf_code_value_pair([id],[code],[state]) ' + @cmb_sql_string)
				END CATCH					 
			END
			SET @cmb_pre_sql_string = @cmb_sql_string
		END

		--Mandatory Validation
		IF @is_required = 1
		BEGIN
			SET @sql = 'INSERT INTO #collect_error_data (temp_id, error_no, column_name, column_value)
						SELECT DISTINCT a.temp_id, 10001, udft.field_label, ISNULL(a.' + @validate_field + ','''')
						FROM ' + @validate_table_name + ' a						
						CROSS APPLY (SELECT field_label,field_id FROM user_defined_fields_template WHERE field_id = ' + CAST(@field_id AS NVARCHAR(20)) + ') udft
						LEFT JOIN #error_status_pre es ON es.temp_id = a.temp_id
						WHERE es.temp_id IS NULL
							AND  a.' + @validate_field + ' IS NULL						
						'
			EXEC(@sql)
		END
		
		IF @field_type IN ('c','d') AND NULLIF(@cmb_sql_string,'') IS NOT NULL
		BEGIN
			--Validate duplicate UDF value in system. This validation is required to as same code with different id can exists. If such data found exclude from import logic.
			SET @sql = '
				INSERT INTO #error_status_pre (temp_id, error_no, template_values)
				SELECT DISTINCT a.temp_id,
					10022,
					''{
						"column_name"		: "'' + udft.field_label + ''",
						"column_value"		: "'' + b.code + ''",
						"repetition_count"	: "'' + CAST(b.notimes AS NVARCHAR) + ''"
					}''
				FROM ' + @validate_table_name + ' a
				CROSS APPLY (SELECT field_label,field_id FROM user_defined_fields_template WHERE field_id = ' + CAST(@field_id AS NVARCHAR(20)) + ') udft
				LEFT JOIN #error_status_pre es ON es.temp_id = a.temp_id
				OUTER APPLY (
					SELECT ucv.code, COUNT(1) notimes
					FROM #udf_code_value_pair ucv 
					WHERE ucv.code = a.' + @validate_field + '
					GROUP BY  ucv.code
					HAVING COUNT(1) > 1
				) b 
				WHERE 1 = 1
					AND b.code IS NOT NULL
					AND es.temp_id IS NULL
					'

			EXEC(@sql)
								
			SET @sql = 'INSERT INTO #collect_error_data (temp_id, error_no, column_name, column_value)
					SELECT DISTINCT a.temp_id, ' + CAST(IIF(@is_required = 1,10002,10013) AS NVARCHAR(8)) + ', udft.field_label, a.' + @validate_field + '
					FROM ' + @validate_table_name + ' a						
					CROSS APPLY (SELECT field_label,field_id FROM user_defined_fields_template WHERE field_id = ' + CAST(@field_id AS NVARCHAR(20)) + ') udft
					LEFT JOIN #udf_code_value_pair ucv ON ucv.code = a.' + @validate_field + '
					LEFT JOIN #error_status_pre es ON es.temp_id = a.temp_id
					WHERE es.temp_id IS NULL
						AND  a.' + @validate_field + ' IS NOT NULL
						AND ucv.id IS NULL
					'
			EXEC(@sql)

			--Check if exists in system
			SET @sql = 'INSERT INTO #collect_error_data (temp_id, error_no, column_name, column_value)
					SELECT DISTINCT a.temp_id, ' + CAST(IIF(@is_required = 1,10002,10013) AS NVARCHAR(8)) + ', udft.field_label, a.' + @validate_field + '
					FROM ' + @validate_table_name + ' a						
					CROSS APPLY (SELECT field_label,field_id FROM user_defined_fields_template WHERE field_id = ' + CAST(@field_id AS NVARCHAR(20)) + ') udft
					LEFT JOIN #udf_code_value_pair ucv ON ucv.code = a.' + @validate_field + '
					LEFT JOIN #error_status_pre es ON es.temp_id = a.temp_id
					WHERE es.temp_id IS NULL
						AND  a.' + @validate_field + ' IS NOT NULL
						AND ucv.id IS NULL
					'
					
		EXEC(@sql)
		END			
			
		
		--Data type
		IF @fld_type IN ('date', 'datetime', 'smalldatetime') AND @field_type NOT IN ('c','d')
		BEGIN
			--Convert user to sql date.
			
			EXEC('UPDATE a 
			SET a.' + @validate_field + ' = dt.sql_date_string
			FROM ' + @validate_table_name + ' a	
			INNER JOIN  vw_date_details dt ON dt.user_date = a.' + @validate_field )

			SET @sql = 'INSERT INTO #collect_error_data (temp_id, error_no, column_name, column_value)
					SELECT a.temp_id, 10004, ''' + @validate_field + ''', a.' + @validate_field + '
					FROM ' + @validate_table_name + ' a		
					LEFT JOIN #error_status_pre es ON es.temp_id = a.temp_id
					WHERE es.temp_id IS NULL
						AND ISDATE(RTRIM(ISNULL(a.'+@validate_field+', GETDATE()))) = 0
						
					'
					
			EXEC(@sql)
		END
		ELSE IF @fld_type IN ('int','bigint','smallint','tinyint','float','real','decimal','numeric','money','smallmoney','bit') AND @field_type NOT IN ('c','d')
		BEGIN
			SET @sql = 'INSERT INTO #collect_error_data (temp_id, error_no, column_name, column_value)
					SELECT a.temp_id, 10004, ''' + @validate_field + ''', a.' + @validate_field + '
					FROM ' + @validate_table_name + ' a
					LEFT JOIN #error_status_pre es ON es.temp_id = a.temp_id
					WHERE es.temp_id IS NULL
						AND TRY_CAST(CASE WHEN RTRIM(ISNULL(a.' + @validate_field + ',''''))='''' THEN ''0'' ELSE RTRIM(a.' + @validate_field + ') END AS NUMERIC(38,20)) IS  NULL'

					
			EXEC(@sql)
		END
		ELSE IF @fld_type IN ('CHAR','NCHAR','VARCHAR','NVARCHAR')  AND @field_type NOT IN ('c','d') AND @fld_length > -1
		BEGIN
			SET @sql = 'INSERT INTO #collect_error_data (temp_id, error_no, column_name, column_value)
					SELECT a.temp_id, 10008, ''' + @validate_field + ''', a.' + @validate_field + '
					FROM ' + @validate_table_name + ' a
					LEFT JOIN #error_status_pre es ON es.temp_id = a.temp_id
					WHERE es.temp_id IS NULL
						AND  LEN(RTRIM(CASE WHEN a.' + @validate_field + ' IS NULL OR a.' + @validate_field + '=''NULL'' THEN '''' ELSE a.' + @validate_field + ' END))>' + CAST(@fld_length AS NVARCHAR) 
			EXEC(@sql)
		END
		
		FETCH NEXT FROM deal_udf_list INTO @validate_field,@fld_type,@fld_length,@cmb_sql_string,@field_id,@field_type,@is_required
	END
	CLOSE deal_udf_list
	DEALLOCATE deal_udf_list
	
	SET @sql = 'INSERT INTO #error_status_pre (temp_id, error_no, template_values)
				SELECT t1.temp_id,
					t1.error_no,
					''
						{"column_name": "'' + STUFF(
													 (SELECT DISTINCT '', '' + column_name
													  FROM #collect_error_data  t2
													  where t1.temp_id = t2.temp_id AND t1.error_no = t2.error_no
													  FOR XML PATH (''''))
													  , 1, 1, '''') + ''",
							"column_value": "'' + STUFF(
													 (SELECT DISTINCT'', '' + column_value
													  FROM #collect_error_data  t2
													  where t1.temp_id = t2.temp_id AND t1.error_no = t2.error_no
													  FOR XML PATH (''''))
													  , 1, 1, '''') + ''"}
					''
 				FROM #collect_error_data t1
				GROUP BY t1.temp_id, t1.error_no '
	
	EXEC (@sql)
	
	EXEC('
		INSERT INTO #import_status_pre (temp_id, process_id, ErrorCode, MODULE, [TYPE], [description], [nextstep])
		SELECT es.temp_id, ''' + @process_id + ''', elt.message_status, ''Import Data'', message_type [type]
		, dbo.FNAReplaceEmailTemplateParams(elt.message, es.template_values), dbo.FNAReplaceEmailTemplateParams(elt.recommendation, es.template_values)
		FROM #error_status_pre es
		INNER JOIN message_log_template elt ON elt.message_number = es.error_no
		')
		
	SET @sql = '
			INSERT INTO source_system_data_import_status_detail(process_id, source, [TYPE], [description], type_error,import_file_name)
			SELECT ''' + @process_id + ''',
				''' + @tablename + ''',
				a.[TYPE],
				a.[description],
				a.ErrorCode,
				s.import_file_name
			FROM #import_status_pre a
			INNER JOIN ' + @validate_table_name + ' s ON a.temp_id = s.temp_id
			WHERE process_id = ''' + @process_id + ''''

	EXEC(@sql)

	EXEC('
		DELETE a
		FROM #import_status_pre
		INNER JOIN ' + @validate_table_name + ' a ON #import_status_pre.temp_id = a.temp_id AND ErrorCode = ''Error''
	')

	TRUNCATE TABLE #import_status_pre

END TRY
BEGIN CATCH	
	IF CURSOR_STATUS('global','deal_udf_list') >= -1
	BEGIN
		IF CURSOR_STATUS('global','deal_udf_list') > -1
		BEGIN
			CLOSE deal_udf_list
		END
		DEALLOCATE deal_udf_list
	END 

	DECLARE @err_msg NVARCHAR(MAX) = ERROR_MESSAGE()
	EXEC spa_print @err_msg

	INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,[TYPE],[description],recommendation) 
	SELECT @process_id,'Error','Import Data','UDF Data Validation','Data Error','Error in UDF TABLE ' + '('+ERROR_MESSAGE()+')','Please verify data in each source fields.'

	INSERT INTO source_system_data_import_status_detail(process_id, source, [TYPE],[description]) 
	SELECT @process_id,'Import Data','Data Error','Error in UDF TABLE ' + '(' + ERROR_MESSAGE() + ')'+'(' + ERROR_MESSAGE() + ')'
END CATCH
