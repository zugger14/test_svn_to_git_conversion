IF OBJECT_ID(N'sp_validate_data_type', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sp_validate_data_type
GO 

/**
	Validate source_data type with table column definitions. Mandatory and data repetition also validated if defiend in ixp_columns.
 Parameters
	@flag : Operation flag optional
			a - handles all Datetime, Data Repetition & mandatory field validation.  
			d - handles Datetime.
			r - handles Data Repetition.
			m - handles mandatory field to show missing value.
			l - handles lookup data validation.
	@process_id : Import process id.
	@field_compare_table : Process table with import data and destination table,columns detail.
	@validate_table_name : Second staging table used by import process where source data are populated into process table as per mapped in column mapping  .
	@tablename	: Import table name.
	@rules_id	: Import rule id.

*/

CREATE PROC [dbo].[sp_validate_data_type] 
	@process_id				NVARCHAR(50),
	@field_compare_table	NVARCHAR(150) = NULL,
	@validate_table_name	NVARCHAR(150),
	@tablename				NVARCHAR(500)=NULL,
	@rules_id				INT = NULL,
	@flag					NCHAR(1) = NULL
AS 
/** * DEBUG QUERY START *
		
DECLARE @process_id			NVARCHAR(50)= 'EC041CD1_C7EA_41F6_A0D2_53BED695EED0',
	@field_compare_table	NVARCHAR(150)= 'adiha_process.dbo.fieldsixp_rec_certified_volume_bkarki_6FED7A0D68EC',
	@validate_table_name	NVARCHAR(150)= 'adiha_process.dbo.ixp_rec_certified_volume_0_bkarki_EC041CD1_C7EA_41F6_A0D2_53BED695EED0',
	@tablename				NVARCHAR(500)='ixp_rec_certified_volume',
	@rules_id				INT = 12349,
	@flag					NCHAR(1)= 'a',
	@user_login_id			NVARCHAR(100)= 'bkarki'
		
IF OBJECT_ID('tempdb..#import_status_pre') IS NOT NULL
	DROP table #import_status_pre
IF OBJECT_ID('tempdb..#error_status_pre') IS NOT NULL
	DROP table #error_status_pre

	
-- * DEBUG QUERY END **/

DECLARE @unique_field		NVARCHAR(50)
DECLARE @unique_field_v		NVARCHAR(50)
DECLARE @sql_st				NVARCHAR(MAX)
DECLARE @source_desc		NVARCHAR(50) = ''
	, @user_login_id		NVARCHAR(100)= dbo.FNADBUser()
DECLARE @look_up_tables NVARCHAR(500)
SET @look_up_tables = dbo.FNAProcessTableName('lookup_validation_' + ISNULL(@tablename, 'temp_table'), @user_login_id, @process_id)

CREATE TABLE #import_status_pre (
	temp_id			INT,
	process_id		NVARCHAR(100)	COLLATE DATABASE_DEFAULT,
	ErrorCode		NVARCHAR(50)	COLLATE DATABASE_DEFAULT,
	MODULE			NVARCHAR(100)	COLLATE DATABASE_DEFAULT,
	[Source]		NVARCHAR(100)	COLLATE DATABASE_DEFAULT,
	[TYPE]			NVARCHAR(100)	COLLATE DATABASE_DEFAULT,
	[description]	NVARCHAR(1000)	COLLATE DATABASE_DEFAULT,
	[nextstep]		NVARCHAR(250)	COLLATE DATABASE_DEFAULT
)

CREATE TABLE #error_status_pre (temp_id INT
	, [error_number] INT
	, template_values NVARCHAR(2000) COLLATE DATABASE_DEFAULT
	)

--EXEC('ALTER TABLE ' + @validate_table_name + ' ADD temp_id INT IDENTITY')
IF @@ERROR <> 0
BEGIN
	INSERT INTO #import_status_pre
	SELECT 1,
		@process_id,
		'Error',
		'Import Data',
		@validate_table_name,
		'Data Error',
		'It is possible that the file format may be incorrect',
		'Please Check your file format'

	GOTO FinalStep
END

--exec('select o.name,c.name colname,comp.validate_field,t.name type,c.length,c.isnullable from sysobjects o 
--inner join syscolumns c on o.id=c.id inner join systypes t on c.xtype=t.xtype
--inner join '+@field_compare_table+ ' comp on o.name=comp.ref_table_name and c.name=comp.ref_field
--')

DECLARE @ref_tbl_name		NVARCHAR(150), 
	@ref_fld_name			NVARCHAR(50),
	@validate_field			NVARCHAR(50),
	@fld_type				NVARCHAR(30),
	@fld_length				INT,
	@isnullable				INT,
	@source_column_name		NVARCHAR(MAX),
	@des_column_value		NVARCHAR(MAX),
	@des_column_name		NVARCHAR(MAX),
	@join_clause			NVARCHAR(MAX),
	@column_name_list		NVARCHAR(MAX),
	@sql					NVARCHAR(MAX),
	@column_value_list		NVARCHAR(MAX),
	@translate_language	BIT = 0

	SELECT @translate_language = ISNULL(translate_language, 0) FROM import_process_info WHERE process_id = @process_id AND ixp_rule_id = @rules_id

SET @unique_field = ''
SET @unique_field_v = ''

IF OBJECT_ID('tempdb..#vaidate_ixp_import_data_mapping') IS NOT NULL
 	DROP TABLE #vaidate_ixp_import_data_mapping


SELECT rule_id	ixp_rules_id			
	, ixp_tables_id dest_table_id		
	, ixp_columns_id dest_column		
	, ixp_columns_name	
	, source_column_name	
	, seq					
	, is_major
INTO #vaidate_ixp_import_data_mapping
FROM dbo.FNAGetIXPSourceColumn(@rules_id,@tablename,@translate_language,0)

IF OBJECT_ID('tempdb..#validate_major_row_values') IS NOT NULL
 	DROP TABLE #validate_major_row_values

CREATE TABLE #validate_major_row_values (temp_id INT
	, major_row_values NVARCHAR(2000) COLLATE DATABASE_DEFAULT
	)

DECLARE @major_row NVARCHAR(MAX) = '', @major_row_select NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #vaidate_ixp_import_data_mapping WHERE is_major =1)
BEGIN
	SELECT	@major_row = CASE WHEN @major_row = '' THEN @major_row ELSE @major_row + ' / ' END + source_column_name,
			@major_row_select = CASE WHEN @major_row_select = '' THEN @major_row_select ELSE @major_row_select + '+'' / ''+' END + 'ISNULL(CAST(tmp.' + ixp_columns_name + ' AS NVARCHAR),'''')'
	FROM #vaidate_ixp_import_data_mapping 
	WHERE is_major = 1

	SET @sql = '
		INSERT INTO #validate_major_row_values (temp_id, major_row_values) 
		SELECT temp_id, N''' + @major_row + ' : '' + ' +  @major_row_select + ' FROM ' + @validate_table_name + ' tmp'
	EXEC(@sql)

END

-- DATETIME validation starts
IF @flag IN ('a', 'd')
BEGIN
	--TODO check if date update step can be fit here.
	SELECT @column_name_list = COALESCE(@column_name_list + ' + ' , '') + 'CASE WHEN ISDATE(ISNULL(a.' + ic.ixp_columns_name + ',''1990-1-1'')) = 0 THEN '', ' + iidm.source_column_name	+ ''' ELSE '''' END ',
		@column_value_list = COALESCE(@column_value_list + ' + ' , '') + 'CASE WHEN ISDATE(ISNULL(a.' + ic.ixp_columns_name + ',''1990-1-1'')) = 0 THEN '',''+ a.' + ic.ixp_columns_name + ' + '''' ELSE '''' END ',
		@join_clause = COALESCE(@join_clause + ' OR ' ,'') + 'ISDATE(ISNULL(a.' + ic.ixp_columns_name + ',''1990-1-1'')) = 0'	
	FROM #vaidate_ixp_import_data_mapping iidm
	INNER JOIN ixp_columns ic ON ic.ixp_columns_id = iidm.dest_column
	WHERE ic.datatype = '[datetime]'
	
	SET @sql = '
		INSERT INTO #error_status_pre (temp_id, error_number, template_values)
		SELECT a.temp_id,
			10004,
			N''{
				"column_name": "'' + STUFF('+ REPLACE(@column_name_list, '"', '\"') +', 1, 2, '''') + ''",
				"column_value": "'' + STUFF('+ @column_value_list +', 1, 1, '''') + ''"
			}''
		FROM ' + @validate_table_name + ' a
		WHERE 1 = 1 
			AND (
				'
				+ ISNULL(@join_clause, ' 1 = 1') + '
			)'
	EXEC(@sql)
END
-- DATETIME validation ends

-- Data Repetition Validation Starts
IF @flag IN ('a', 'r')
BEGIN
	SET @join_clause = NULL

	SELECT @source_column_name = COALESCE(@source_column_name +', ' ,'') + iidm.source_column_name,
		@des_column_name = COALESCE(@des_column_name + ', ' ,'') + ic.ixp_columns_name,
		@des_column_value = COALESCE(@des_column_value + ' + '', '' + ','') + 
			CASE 
				WHEN ic.datatype = '[datetime]' THEN 'ISNULL(dbo.FNADateFormat(a.[' + ic.ixp_columns_name + ']), ''NULL'')'
				ELSE 'ISNULL(a.[' + ic.ixp_columns_name + '], ''NULL'')'
			END,
		@join_clause = COALESCE(@join_clause +' AND ' ,'') + 'ISNULL(a.[' + ic.ixp_columns_name + '], -1) = ISNULL(b.[' + ic.ixp_columns_name + '], -1)'
	FROM #vaidate_ixp_import_data_mapping iidm
	INNER JOIN ixp_columns ic ON ic.ixp_columns_id = iidm.dest_column
	WHERE ic.is_major = 1
	ORDER BY ic.seq ASC
	
	SET @sql = '
		INSERT INTO #error_status_pre (temp_id, error_number, template_values)
		SELECT a.temp_id,
			10007,
			N''{
				"column_name"		: "' +  REPLACE(@source_column_name, '"', '\"') + '",
				"column_value"		: "'' +' +  @des_column_value + ' + ''",
				"repetition_count"	: "'' + CAST(b.notimes AS NVARCHAR) + ''"
			}''
		FROM ' + @validate_table_name + ' a
		LEFT JOIN #error_status_pre ON a.temp_id = #error_status_pre.temp_id
		INNER JOIN (
			SELECT ' + @des_column_name + ', COUNT(1) notimes
			FROM ' + @validate_table_name + '
			GROUP BY ' + @des_column_name + '
			HAVING COUNT(1) > 1
		) b ON 1 = 1
			AND #error_status_pre.temp_id IS NULL
			AND (
				'
				+ ISNULL(@join_clause, ' 1 = 1') + '
			)'
	EXEC(@sql)
END
-- Data Repetition Validation Ends

-- Mandatory Data Validation Starts
IF @flag IN ('a', 'm')
BEGIN
	SET @column_name_list = NULL
	SET @join_clause = NULL

	SELECT @column_name_list = COALESCE(@column_name_list + ' + ' , '') + 'CASE WHEN a.' + ic.ixp_columns_name + ' IS NULL THEN N'', [' + REPLACE(iidm.source_column_name,'''','''''') + ']'' ELSE '''' END ',
		@join_clause = COALESCE(@join_clause +' OR ' ,'') + 'a.' + ic.ixp_columns_name + ' IS NULL'
	FROM #vaidate_ixp_import_data_mapping iidm
	INNER JOIN ixp_columns ic ON ic.ixp_columns_id = iidm.dest_column
	WHERE ic.is_required = 1
		--todo need to replace " for proper json format.	
	SET @sql = '
		INSERT INTO #error_status_pre (temp_id, error_number, template_values)
		SELECT a.temp_id,
			10001,
			N''{
				"column_name": "'' + STUFF('+ REPLACE(@column_name_list,'"','\"') +', 1, 2, '''') + ''"
			}''
		FROM ' + @validate_table_name + ' a
		LEFT JOIN #error_status_pre ON a.temp_id = #error_status_pre.temp_id
		WHERE 1 = 1
			AND #error_status_pre.temp_id IS NULL
			AND (
				'
				+ ISNULL(@join_clause, ' 1 = 1') + '
			)'
			
	EXEC(@sql)
END
-- Mandatory Data Validation Ends

----- look validation starts
IF @flag IN ('a', 'l') AND OBJECT_ID(@look_up_tables) IS NOT NULL
BEGIN
	DECLARE @sql_lookup NVARCHAR(MAX)
	SET @sql_lookup = '
		DECLARE @sql NVARCHAR(MAX)
		SELECT  @sql = COALESCE(@sql + '' UNION ALL '' , '''') + ''
			SELECT a.temp_id
				, '' + CAST(CASE WHEN l.flag = ''w'' THEN 10013 ELSE 10002 END AS NVARCHAR(10)) + ''
				, N''''
					{
						"column_name": "'' + REPLACE(iidm.source_column_name, ''"'', ''\"'') + ''",
						"column_value": "'''' + REPLACE(a.'' + l.referring_clm_name + '', ''''"'''', ''''\"'''') + ''''"'''' + ''''
					}
				''''
			
			FROM ' + @validate_table_name + ' a
			LEFT JOIN #error_status_pre es ON a.temp_id = es.temp_id
			WHERE 1 = 1 
				AND es.temp_id IS NULL
				AND a.'' + l.referring_clm_name + '' IS NOT NULL 
				AND NOT EXISTS (
					SELECT 1 FROM '' + l.referred_table + '' b WHERE '' + l.filters + ''
				)
		''
		FROM #vaidate_ixp_import_data_mapping iidm 
		INNER JOIN ' + @look_up_tables + ' l ON l.referring_clm_name = iidm.ixp_columns_name

		SET @sql = ''INSERT INTO #error_status_pre (temp_id, error_number, template_values) '' + 	@sql
		EXEC(@sql)
		'	
		EXEC(@sql_lookup)
	END
---------lookup validation ends

--*/
IF OBJECT_ID(@field_compare_table) IS NOT NULL
BEGIN
	BEGIN TRY
		-- Below logic is used to validate source_data type with table column definitions. This includes not null, data type. datalength.
		EXEC('
			IF CURSOR_STATUS(''global'',''list_compare'') >= -1
			BEGIN
				IF CURSOR_STATUS(''global'',''list_compare'') > -1
				BEGIN
					CLOSE list_compare
				END
				DEALLOCATE list_compare
			END
			DECLARE list_compare CURSOR FOR
			SELECT o.name,
				c.name colname,
				comp.validate_field,
				t.name type,
				c.length,
				c.isnullable
			FROM sysobjects o
			INNER JOIN syscolumns c ON o.id=c.id
			INNER JOIN systypes t ON c.xtype=t.xtype
			INNER JOIN ' + @field_compare_table +  ' comp ON o.name = comp.ref_table_name AND c.name = comp.ref_field
			FOR READ ONLY'
		)
		OPEN list_compare
		FETCH NEXT FROM list_compare INTO @ref_tbl_name, @ref_fld_name, @validate_field, @fld_type, @fld_length, @isnullable
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @source_desc = ISNULL([description],'') FROM static_data_value WHERE code = @ref_tbl_name
			-- PRINT @validate_field
			IF SUBSTRING(@validate_field, 1, 3) = 'C0_'
			BEGIN
				SET @unique_field = @ref_fld_name 
				SET @unique_field_v = @validate_field
			END

			IF ISNULL(@unique_field, '') = '' --if column having prefix C0_ is not inserted in @field_compare_table
			BEGIN
				SET @unique_field = @ref_fld_name 
				SET @unique_field_v = @validate_field
			END

			IF @isnullable = 0 
			BEGIN
				----PRINT'required'
				SET @sql_st ='
 					INSERT INTO #error_status_pre (temp_id, error_number, template_values)
					SELECT a.temp_id,
							10001,
							N''{
								"column_name": "'' + REPLACE(iidm.source_column_name,''"'',''\"'') + ''"
							}''
 					FROM ' + @validate_table_name + ' a
					CROSS APPLY (
						SELECT ixp_table_id, ixp_columns_id
						FROM ixp_columns ic
						WHERE ic.ixp_columns_name = ''' + @validate_field + '''
					) b
					--INNER JOIN ixp_tables it ON b.ixp_table_id = it.ixp_tables_id
					INNER JOIN #vaidate_ixp_import_data_mapping iidm ON iidm.dest_column = b.ixp_columns_id
					LEFT JOIN #error_status_pre esp ON esp.temp_id = a.temp_id --AND esp.error_number = 10001
					WHERE ISNULL(RTRIM(a.' + @validate_field + '), '''') = ''''
						AND esp.temp_id IS NULL 
				'

				EXEC(@sql_st)
			END
			ELSE IF @fld_type IN ('date', 'datetime', 'smalldatetime')
			BEGIN
				SET @sql_st = '
 					INSERT INTO #error_status_pre (temp_id, error_number, template_values)
					SELECT a.temp_id,
							10004,
							N''{
								"column_name": "'' + REPLACE(iidm.source_column_name,''"'',''\"'') + ''",
								"column_value": "'' + a.' + @validate_field + ' + ''"
							}''
 					FROM ' + @validate_table_name + ' a
					CROSS APPLY (
						SELECT ixp_table_id, ixp_columns_id  
						FROM ixp_columns ic 
						WHERE ic.ixp_columns_name = ''' + @validate_field + '''
					) b
					--INNER JOIN ixp_tables it ON b.ixp_table_id = it.ixp_tables_id
					INNER JOIN #vaidate_ixp_import_data_mapping iidm ON iidm.dest_column = b.ixp_columns_id
					LEFT JOIN #error_status_pre esp ON esp.temp_id = a.temp_id
					WHERE ISDATE(RTRIM(ISNULL(a.'+@validate_field+', GETDATE()))) = 0
						AND esp.temp_id IS NULL
				'
			
				EXEC(@sql_st)
			END
			ELSE IF @fld_type IN ('int','bigint','smallint','tinyint','float','real','decimal','numeric','money','smallmoney','bit')  
			BEGIN			
				SET @sql_st ='
 					INSERT INTO #error_status_pre (temp_id, error_number, template_values)
					SELECT a.temp_id,
						10004,
						N''{
							"column_name": "'' + REPLACE(iidm.source_column_name,''"'',''\"'') + ''",
							"column_value": "'' + CAST(a.' + @validate_field + ' AS NVARCHAR(MAX)) + ''"
						}''
 					FROM ' + @validate_table_name + ' a
					CROSS APPLY (
						SELECT ixp_table_id, ixp_columns_id  
						FROM ixp_columns ic 
						WHERE ic.ixp_columns_name = ''' + @validate_field + '''
					) b
					--INNER JOIN ixp_tables it ON b.ixp_table_id = it.ixp_tables_id
					INNER JOIN #vaidate_ixp_import_data_mapping iidm ON iidm.dest_column = b.ixp_columns_id
					WHERE TRY_CAST(CASE WHEN RTRIM(ISNULL(a.' + @validate_field + ',''''))='''' THEN ''0'' ELSE RTRIM(a.' + @validate_field + ') END AS NUMERIC(38,20)) IS  NULL'


				EXEC(@sql_st)
			END
			ELSE IF @fld_type IN ('CHAR', 'NCHAR', 'VARCHAR', 'NVARCHAR') AND @fld_length > -1 -- Bypassed validation having column length -1
			BEGIN
				SET @sql_st ='
 					INSERT INTO #error_status_pre (temp_id, error_number, template_values)
					SELECT a.temp_id,
						10008,
						N''
							{
								"column_name": "'' + REPLACE(iidm.source_column_name,''"'',''\"'') + ''",
								"column_length": "'' + CAST(' + CAST(@fld_length AS NVARCHAR) + ' AS NVARCHAR) + ''"
							}
						''
 					FROM ' + @validate_table_name + ' a
					CROSS APPLY (
						SELECT ixp_table_id, ixp_columns_id  
						FROM ixp_columns ic 
						WHERE ic.ixp_columns_name = ''' + @validate_field + '''
					) b
					--INNER JOIN ixp_tables it ON b.ixp_table_id = it.ixp_tables_id
					INNER JOIN #vaidate_ixp_import_data_mapping iidm ON iidm.dest_column = b.ixp_columns_id
					WHERE LEN(RTRIM(CASE WHEN a.' + @validate_field + ' IS NULL OR a.' + @validate_field + '=''NULL'' THEN '''' ELSE a.' + @validate_field + ' END))>' + CAST(@fld_length AS NVARCHAR) + ''


				EXEC(@sql_st)
			END

			FETCH NEXT FROM list_compare INTO @ref_tbl_name,@ref_fld_name,@validate_field,@fld_type,@fld_length,@isnullable
		END
		CLOSE list_compare
		DEALLOCATE list_compare

	END TRY
	--loop level ******************************************************************************************************************************************************
	BEGIN CATCH
		----PRINT'lllll'
		INSERT INTO source_system_data_import_status(process_id,code,MODULE,source,[TYPE],[description],recommendation) 
		SELECT @process_id,'Error','Import Data','Data Validation','Data Error','Error in TABLE :'+ISNULL(@ref_tbl_name,'')+' => '+ISNULL(@ref_fld_name,'')+'('+ERROR_MESSAGE()+')','Please verify data in each source fields.'

		INSERT INTO source_system_data_import_status_detail(process_id, source, [TYPE],[description]) 
		SELECT @process_id,'Import Data','Data Error','Error in TABLE :'+ISNULL(@ref_tbl_name,'')+' => '+ISNULL(@ref_fld_name,'')+'('+ERROR_MESSAGE()+')'

		-- INSERT INTO source_system_data_import_status(process_id, code, module, source, type, [description], recommendation)
		-- SELECT @process_id, 'Error', 'Import Data', 'Interface Adaptor', 'Adaptor Error', 'Error in TABLE NO:' + SUBSTRING(@job_name, 1, 4) + ', ERROR NO:' + CAST(ERROR_NUMBER() AS NVARCHAR)+ '; DESCRIPTION:'+ERROR_MESSAGE()+')','Please varify zainet staging tables and its fields.'
	END CATCH
END

FinalStep:
	EXEC('
	INSERT INTO #import_status_pre (temp_id, process_id, ErrorCode, MODULE, Source, [TYPE], [description], [nextstep])
	SELECT es.temp_id, ''' + @process_id + ''', elt.message_status, ''Import Data'', ''' + @source_desc + ''' [source], message_type [type]
	, dbo.FNAReplaceEmailTemplateParams(elt.message, es.template_values), dbo.FNAReplaceEmailTemplateParams(elt.recommendation, es.template_values)
	FROM #error_status_pre es
	INNER JOIN message_log_template elt ON elt.message_number = es.error_number
	')


IF ISNULL(@tablename, '') = 'source_price_curve'
BEGIN
	SET @sql_st = '
		INSERT INTO source_system_data_import_status_detail(process_id, source, [TYPE], [description], type_error,import_file_name)
		SELECT ''' + @process_id + ''',
			curv.market_value_id,
			a.[TYPE],
			a.[description],
			curv.curve_id+''___''+CONVERT(NVARCHAR(10),CAST(s.as_of_date AS DATETIME),120)+''___''+ curv.market_value_id,
			s.import_file_name
		FROM #import_status_pre a
		INNER JOIN ' + @validate_table_name + ' s ON a.temp_id = s.temp_id
		INNER JOIN source_price_curve_def curv ON s.source_curve_def_id = curv.curve_id
		WHERE process_id = ''' + @process_id + ''''
END
ELSE
BEGIN
	SET @sql_st = '
		INSERT INTO source_system_data_import_status_detail(process_id, source, [TYPE], [description], type_error,import_file_name)
		SELECT DISTINCT ''' + @process_id + ''',
			COALESCE(''' + @tablename + ''', b.code),
			a.[TYPE],
			ISNULL(tmp.major_row_values + '' - '','''') +  a.[description],
			a.ErrorCode,
			s.import_file_name
		FROM #import_status_pre a
		INNER JOIN ' + @validate_table_name + ' s ON a.temp_id = s.temp_id
		INNER JOIN static_data_value b ON a.Source = b.description
		LEFT JOIN #validate_major_row_values tmp ON tmp.temp_id = a.temp_id
		WHERE process_id = ''' + @process_id + ''''
END

EXEC(@sql_st)

EXEC('
	DELETE a
	FROM #import_status_pre
	INNER JOIN ' + @validate_table_name + ' a ON #import_status_pre.temp_id = a.temp_id AND ErrorCode = ''Error''
')

TRUNCATE TABLE #import_status_pre

GO