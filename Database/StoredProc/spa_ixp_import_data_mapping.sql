IF OBJECT_ID(N'[dbo].[spa_ixp_import_data_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_import_data_mapping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Used by data import module to map source column with import columns.
 
	Parameters
	@flag : Operational flag used for different purpose.
	@ixp_data_mapping_id : Identity column parameter for ixp_data_mapping table.
	@ixp_rules_id : Unique id of import rule.
	@ixp_table_id : Import table id.
	@process_id : Unique identifier of import process.
	@temp_process_table : Temp import data process table.
	@xml : Xml text variables, used for bulk insertion.
	@connection_string : Linked server name.
	@where_clause : Import data where Clause
	@repeat_number : Repeat number of import table to use.
	@row_index : Row Index
	@join_clause : Join condition for connected data.
	@ixp_import_relation_id : Unique identifier of connecte4d data
*/

CREATE PROCEDURE [dbo].[spa_ixp_import_data_mapping]   
    @flag CHAR(1),
    @ixp_data_mapping_id INT = NULL,
    @ixp_rules_id INT = NULL,
    @ixp_table_id INT = NULL,
    @process_id VARCHAR(200) = NULL,
    @temp_process_table VARCHAR(300) = NULL,
    @xml TEXT = NULL,
    @connection_string VARCHAR(3000) = NULL,
    @where_clause VARCHAR(MAX) = NULL,
    @repeat_number INT = NULL,
	@row_index INT = NULL,
	@join_clause  VARCHAR(MAX) = NULL,
	@ixp_import_relation_id INT = NULL
AS
/*
DECLARE 
@flag CHAR(1),
    @ixp_data_mapping_id INT = NULL,
    @ixp_rules_id INT = NULL,
    @ixp_table_id INT = NULL,
    @process_id VARCHAR(200) = NULL,
    @temp_process_table VARCHAR(300) = NULL,
    @xml varchar(max) = NULL,
    @connection_string VARCHAR(3000) = NULL,
    @where_clause VARCHAR(MAX) = NULL,
    @repeat_number INT = NULL,
	@row_index INT = NULL,
	@join_clause  VARCHAR(MAX) = NULL,
	@ixp_import_relation_id INT = NULL
	
select @flag='s', @ixp_table_id=2 , @process_id = '455AF846_C217_46E7_B1C6_206B5763F341' 
,@temp_process_table = 'temp_import_data_table_455AF846_C217_46E7_B1C6_206B5763F341', @ixp_rules_id=1,
@repeat_number=0, @row_index = 2
--*/
SET NOCOUNT ON

DECLARE @sql                      VARCHAR(MAX)
DECLARE @table_name               VARCHAR(200)
DECLARE @insert_process_table     VARCHAR(500)
DECLARE @user_login_id            VARCHAR(50)
DECLARE @ixp_import_data_mapping  VARCHAR(300)
DECLARE @ixp_import_data_source   VARCHAR(300)
DECLARE @ixp_import_relation      VARCHAR(300)
DECLARE @ixp_import_where_clause  VARCHAR(300)
DECLARE @DESC                     VARCHAR(500)
DECLARE @err_no                   INT
DECLARE @ixp_rules                VARCHAR(300)

IF @temp_process_table IS NULL 
	SET @temp_process_table = 'adiha_process.dbo.temp_import_data_table_' + @process_id

SELECT  @table_name = it.ixp_tables_name
FROM   ixp_tables it
WHERE  it.ixp_tables_id = @ixp_table_id

SET @user_login_id = dbo.FNADBUser()
SET @insert_process_table = dbo.FNAProcessTableName(@table_name, @user_login_id, @process_id)
SET @ixp_import_data_mapping = dbo.FNAProcessTableName('ixp_import_data_mapping', @user_login_id, @process_id)
SET @ixp_import_data_source = dbo.FNAProcessTableName('ixp_import_data_source', @user_login_id, @process_id)
SET @ixp_import_relation = dbo.FNAProcessTableName('ixp_import_relation', @user_login_id, @process_id)
SET @ixp_import_where_clause = dbo.FNAProcessTableName('ixp_import_where_clause', @user_login_id, @process_id)
SET @ixp_rules = dbo.FNAProcessTableName('ixp_rules', @user_login_id, @process_id)
--dbo.FNAProcessTableName('ixp_import_data_mapping', @user_login_id, @process_id)
--ixp_source_deal_template

IF @flag = 'g'
BEGIN
 
	IF @ixp_rules_id = 1
	BEGIN
		DECLARE @ixp_deal_table_id INT
		SELECT @ixp_deal_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_deal_template'
		
		SELECT	NULL [source_column_name],
				CAST(ic.ixp_columns_id AS VARCHAR(24))		[dest_column],
				NULL					[column_function],
				NULL					[column_aggregation],
				ic.is_required			[required],
				ic.seq seq,
				1 category 
		INTO #columns
		FROM ixp_columns ic
		WHERE ixp_table_id = @ixp_table_id 					
			AND ic.ixp_columns_name NOT LIKE 'udf_value%'
		UNION
		SELECT NULL
			, 'udf_' + CAST(field_id AS VARCHAR(24))
			, NULL
			, NULL
			, 0 
			, 99999 + ROW_NUMBER() OVER(order by udf_type desc,field_label)
		, IIF(udf_type = 'h',2,3)
		FROM user_defined_fields_template 
		WHERE udf_type in ('h','d') AND @ixp_deal_table_id = @ixp_table_id

		SELECT * FROM #columns
		ORDER BY category, [required] DESC, seq
	END
	ELSE
	BEGIN	
	
		SELECT	idm.source_column_name	[source_column_name],
				ISNULL('udf_' + CAST(idm.udf_field_id AS VARCHAR(24)), ic.ixp_columns_id)		[dest_column],
				idm.column_function		[column_function],
				idm.column_aggregation	[column_aggregation],
				ic.is_required			[required]
		FROM ixp_columns ic
		INNER JOIN ixp_import_data_mapping idm ON ic.ixp_table_id = idm.dest_table_id 
			AND ic.ixp_columns_id =  idm.dest_column
		WHERE ixp_table_id = @ixp_table_id AND ixp_rules_id = @ixp_rules_id
		ORDER BY 
			CASE WHEN ic.is_required = 1 THEN 0 ELSE 1 END, 
			CASE WHEN idm.column_function IS NOT NULL THEN 0 ELSE 1 END,
			CASE WHEN idm.column_aggregation IS NOT NULL THEN 0 ELSE 1 END,
			ISNULL(ic.seq,99999)
	END
END

IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#tmp_table_alias') IS NOT NULL
		DROP TABLE #tmp_table_alias
	CREATE TABLE #tmp_table_alias (table_alias VARCHAR(100) COLLATE DATABASE_DEFAULT , alias VARCHAR(100) COLLATE DATABASE_DEFAULT )
	
	IF @row_index IS NOT NULL
	BEGIN
		IF @row_index = 0
		BEGIN
	SET @sql = 'INSERT INTO #tmp_table_alias (table_alias, alias)
						SELECT ''temp_import_data_table_'' + data_source_alias + ''_'' + ''' + @process_id + ''', data_source_alias  FROM ' +  @ixp_import_data_source 
		END
		ELSE
		BEGIN
			SET @sql = 'INSERT INTO #tmp_table_alias (table_alias, alias)						
						SELECT ''temp_import_data_table_'' + ixp_relation_alias + ''_'' + ''' + @process_id + ''', ixp_relation_alias FROM ' + @ixp_import_relation + '
						WHERE ixp_import_relation_id = ' + CAST(@row_index AS VARCHAR(10)) 
		END
	END	
	
	EXEC(@sql)
	
	SET @sql = 'IF OBJECT_ID(''tempdb..#temp_adiha'') IS NOT NULL
					DROP TABLE #temp_adiha
				IF OBJECT_ID(''tempdb..#temp_db'') IS NOT NULL
					DROP TABLE #temp_db
	
				CREATE TABLE #temp_adiha(
					source_column_name VARCHAR(100),
					dest_column INT,
					column_function VARCHAR(500),
					column_aggregation VARCHAR(50)
				)

				CREATE TABLE #temp_db(
					source_column_name VARCHAR(100),
					dest_column INT,
					column_function VARCHAR(500),
					column_aggregation VARCHAR(50)
				)
				
				INSERT INTO #temp_adiha(source_column_name, dest_column, column_function, column_aggregation)
				SELECT ISNULL(iidm.source_column_name, tmp.alias + ''.['' + temp.COLUMN_NAME + '']'') [source_column_name],
					   iidm.dest_column,
	                   iidm.column_function,
	                   iidm.column_aggregation
                FROM   adiha_process.INFORMATION_SCHEMA.COLUMNS temp WITH(NOLOCK)
                LEFT JOIN ' + @ixp_import_data_source + ' iids ON iids.rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
                LEFT JOIN ' + @ixp_import_data_mapping + ' iidm ON iids.data_source_alias + ''.['' + temp.COLUMN_NAME + '']'' = iidm.source_column_name  AND iidm.dest_table_id = ' + CAST(@ixp_table_id AS VARCHAR(10)) + '
                INNER JOIN #tmp_table_alias tmp ON TABLE_NAME = tmp.table_alias
				WHERE (iidm.ixp_import_data_mapping_id IS NULL OR ISNULL(iidm.repeat_number, 0) = ' + CAST(@repeat_number AS VARCHAR(20)) + ')                 
                
				INSERT INTO #temp_db(source_column_name, dest_column, column_function, column_aggregation)
                SELECT iidm.source_column_name,
					   iidm.dest_column,
					   iidm.column_function,
					   iidm.column_aggregation
                FROM ' + @ixp_import_data_mapping + ' iidm
                INNER JOIN ' + @ixp_import_data_source + ' iids ON  iids.rules_id = iidm.ixp_rules_id 
                WHERE iids.rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ' AND iidm.dest_table_id = ' + CAST(@ixp_table_id AS VARCHAR(10)) + '
                
				IF EXISTS(SELECT 1 FROM #temp_adiha)
				BEGIN
					SELECT source_column_name, dest_column dest_column, MAX(column_function) column_function, MAX(column_aggregation) column_aggregation
				FROM (
						SELECT ta.* 
						FROM #temp_adiha ta 
						LEFT JOIN  #temp_db td 
							ON ta.source_column_name = td.source_column_name
						WHERE td.source_column_name IS NULL
						UNION
						SELECT ta.* 
						FROM #temp_adiha ta 
						LEFT JOIN  #temp_db td 
							ON ta.source_column_name = td.source_column_name
						WHERE td.source_column_name IS NOT NULL
						UNION
						SELECT td.* 
						FROM #temp_db td 
						LEFT JOIN #temp_adiha ta 
							ON ta.source_column_name = td.source_column_name
						WHERE ta.source_column_name IS NULL
							 AND NULLIF(td.source_column_name, '''') IS NULL
					) a GROUP BY source_column_name, dest_column
                END
				ELSE
				BEGIN
					SELECT source_column_name, dest_column dest_column, MAX(column_function) column_function, MAX(column_aggregation) column_aggregation
					FROM (
				SELECT ISNULL(iidm.source_column_name, tmp.alias + ''.['' + temp.COLUMN_NAME + '']'') [source_column_name],
					   iidm.dest_column,
	                   iidm.column_function,
	                   iidm.column_aggregation
                FROM   adiha_process.INFORMATION_SCHEMA.COLUMNS temp  WITH(NOLOCK)
                LEFT JOIN ' + @ixp_import_data_source + ' iids ON iids.rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
                LEFT JOIN ' + @ixp_import_data_mapping + ' iidm ON iids.data_source_alias + ''.['' + temp.COLUMN_NAME + '']'' = iidm.source_column_name  AND iidm.dest_table_id = ' + CAST(@ixp_table_id AS VARCHAR(10)) + '
                INNER JOIN #tmp_table_alias tmp ON TABLE_NAME = tmp.table_alias
				WHERE (iidm.ixp_import_data_mapping_id IS NULL OR ISNULL(iidm.repeat_number, 0) = ' + CAST(@repeat_number AS VARCHAR(20)) + ')                 
                UNION
                SELECT iidm.source_column_name,
					   iidm.dest_column,
					   iidm.column_function,
					   iidm.column_aggregation
                FROM ' + @ixp_import_data_mapping + ' iidm
                INNER JOIN ' + @ixp_import_data_source + ' iids ON  iids.rules_id = iidm.ixp_rules_id 
                WHERE iids.rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ' AND iidm.dest_table_id = ' + CAST(@ixp_table_id AS VARCHAR(10)) + '
                ) a GROUP BY source_column_name, dest_column
				END
                '
                
    --PRINT(@sql)
    EXEC(@sql)
END
IF @flag = 'i'
BEGIN
BEGIN TRY
	DECLARE @idoc         INT
	DECLARE @relation_id  INT
	DECLARE @row_id       INT
	--SET @xml = '
	--		<Root>
				--<PSRecordset Rules="1" Table="5" SourceColumn="source_deal_id" DestinationColumn="deal_id" Function="" Aggregation=""></PSRecordset>
				--<PSRecordset Rules="1" Table="5" SourceColumn="term_start" DestinationColumn="term_start" Function="" Aggregation=""></PSRecordset>
				--<PSRecordset Rules="1" Table="5" SourceColumn="term_end" DestinationColumn="term_end" Function="" Aggregation=""></PSRecordset>
				--<PSRecordset Rules="1" Table="5" SourceColumn="leg" DestinationColumn="Leg" Function="" Aggregation=""></PSRecordset>
	--		</Root>'
			
		--Create an internal representation of the XML document.
	EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

	-- Create temp table to store the report_name and report_hash
	IF OBJECT_ID('tempdb..#ixp_import_data_mapping') IS NOT NULL
		DROP TABLE #ixp_import_data_mapping

	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	SELECT Rules [rules_id],
		   [Table] [table_id],
		   [SourceColumn] [source_column_name],
		   [DestinationColumn] [dest_column],
		   dbo.FNADecodeXML(REPLACE(REPLACE([Function], '&add;', '+'), '&minus;', '-')) [column_function],
		   [Aggregation] [column_aggregation],
		   [JoinClause] [join_clause],
		   [RepeatNumber] [repeat_number]
	INTO #ixp_import_data_mapping
	FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
	WITH (
		Rules VARCHAR(10),
		[Table] VARCHAR(20),
		[SourceColumn] VARCHAR(100),
		[DestinationColumn] VARCHAR(100),
		[Function] VARCHAR(MAX),
		[Aggregation] VARCHAR(50),
		[JoinClause] VARCHAR(MAX),
		[RepeatNumber] VARCHAR(20)
	)

	ALTER TABLE #ixp_import_data_mapping ADD udf_field_id INT
	
	--SELECT iidm.dest_column, ic.ixp_columns_id, iidm.udf_field_id, rs.clm2 
	UPDATE iidm
	SET dest_column = ic.ixp_columns_id
		, udf_field_id = rs.clm2 
	FROM (
		SELECT ROW_NUMBER() OVER(ORDER BY dest_column ASC) row_id , iidm.rules_id, iidm.table_id, iidm.dest_column, rs_outer.clm2
		FROM #ixp_import_data_mapping iidm	
		OUTER APPLY(select clm1,clm2 from dbo.FNASplitAndTranspose(iidm.dest_column,'_') ) rs_outer
		WHERE rs_outer.clm2 is not null
	) rs
	INNER JOIN #ixp_import_data_mapping iidm ON iidm.rules_id = rs.rules_id
		AND iidm.table_id = rs.table_id
		AND iidm.dest_column = rs.dest_column
	INNER JOIN ixp_columns ic ON ic.ixp_table_id = rs.table_id and ic.ixp_columns_name = 'udf_value' + CAST(rs.row_id AS VARCHAR(8))
	
	IF OBJECT_ID('tempdb..#ixp_check_sql_syntax') IS NOT NULL
		DROP TABLE #ixp_check_sql_syntax
	CREATE TABLE #ixp_check_sql_syntax (column_function VARCHAR(5000) COLLATE DATABASE_DEFAULT , is_error INT, column_name VARCHAR(300) COLLATE DATABASE_DEFAULT )
		
	INSERT INTO #ixp_check_sql_syntax (column_function, column_name)
	SELECT iidm.[column_function], iidm.source_column_name
	FROM #ixp_import_data_mapping  iidm
	WHERE iidm.[column_function] <> ''
	
	DECLARE @return_value INT
	DECLARE @column_function VARCHAR(1000)
	DECLARE @sql_syntax VARCHAR(MAX)
	DECLARE @invalid_column_functions VARCHAR(MAX)
	
	DECLARE sql_syntax_cursor CURSOR LOCAL FOR
	SELECT DISTINCT column_function FROM #ixp_check_sql_syntax
		
	OPEN sql_syntax_cursor
	FETCH NEXT FROM sql_syntax_cursor
	INTO @column_function
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @sql_syntax = NULL
			
		SET @sql_syntax = 'SELECT ' + @column_function + ' FROM error_checker'
			
		EXEC @return_value =  spa_check_sql_syntax @sql_syntax
			
		UPDATE #ixp_check_sql_syntax
		SET is_error = @return_value
		WHERE [column_function] = @column_function
			
		FETCH NEXT FROM sql_syntax_cursor
		INTO @column_function
	END		
	CLOSE sql_syntax_cursor
	DEALLOCATE sql_syntax_cursor
		
	IF EXISTS(SELECT 1 FROM #ixp_check_sql_syntax WHERE is_error = 1)
	BEGIN
		SELECT @invalid_column_functions = COALESCE(@invalid_column_functions + ',', '') + column_name
		FROM #ixp_check_sql_syntax 
		WHERE is_error = 1
			
		SET @desc = 'Error in column function for columns :- ' + @invalid_column_functions + ' .' 
			
		EXEC spa_ErrorHandler -1,
			 'Import Export FX',
			 'spa_ixp_import_data_mapping',
			 'Error',
			 @desc,
			 ''
		RETURN
	END
	
	IF EXISTS(SELECT 1 FROM #ixp_import_data_mapping GROUP BY dest_column HAVING COUNT(*) > 1)
	BEGIN
		EXEC spa_ErrorHandler -1,
			 'Import Export FX',
			 'spa_ixp_import_data_mapping',
			 'Error',
			 'Same column has been mapped multiple times. Please check mapping columns.',
			 ''
		RETURN
	END
	ELSE
	BEGIN
		IF OBJECT_ID('tempdb..#temp_relation') IS NOT NULL
				DROP TABLE #temp_relation
		
		/* 1=2 done because we dont use data from this table */
		SELECT ROW_NUMBER() OVER(ORDER BY [join_clause]) [row_id],
		       [source_column_name],
		       [join_clause] INTO #temp_relation
		FROM   #ixp_import_data_mapping
		WHERE  1=2
		
		IF OBJECT_ID('tempdb..#relations') IS NOT NULL
				DROP TABLE #relations
		CREATE TABLE #relations ([relation_id] INT, [join_clause] VARCHAR(5000) COLLATE DATABASE_DEFAULT )
		
		DECLARE relation_cursor CURSOR LOCAL  
		FOR SELECT [row_id] FROM #temp_relation
		
		OPEN relation_cursor
		FETCH NEXT FROM relation_cursor INTO @row_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF OBJECT_ID('tempdb..#temp_joins_columns') IS NOT NULL
				DROP TABLE #temp_joins_columns	
				
			SELECT item INTO #temp_joins_columns  from dbo.FNASplit((SELECT [join_clause] FROM #temp_relation WHERE [row_id] = @row_id), '|') f
			
			INSERT INTO #relations([relation_id], [join_clause])
			SELECT SUBSTRING(LTRIM(RTRIM(item)), 1, CHARINDEX(':', LTRIM(RTRIM(item)))-1) [relation_id],
				   SUBSTRING(LTRIM(RTRIM(item)), CHARINDEX(':', LTRIM(RTRIM(item)))+1, LEN(LTRIM(RTRIM(item))) - CHARINDEX(':', LTRIM(RTRIM(item)))) [join_clause]
			FROM #temp_joins_columns
			
			FETCH NEXT FROM relation_cursor INTO @row_id
		END
		CLOSE relation_cursor
		DEALLOCATE relation_cursor
		
		IF OBJECT_ID('tempdb..#relations_final') IS NOT NULL
				DROP TABLE #relations_final
				
		SELECT out_rel.[relation_id] ,
			   STUFF (( SELECT ' AND ' + in_rel.[join_clause]
						FROM   #relations in_rel
						WHERE  in_rel.[relation_id] = out_rel.[relation_id]
						ORDER BY in_rel.[relation_id] FOR XML PATH(''), TYPE 
			   ).value('.','VARCHAR(MAX)') , 1,5,SPACE(0)
			   ) [join_clause]
		INTO #relations_final
		FROM #relations out_rel
		GROUP BY out_rel.[relation_id]
				
		SET @sql = 'DECLARE @old_rules_id INT
					SELECT @old_rules_id = ir.ixp_rules_id FROM ixp_rules ir INNER JOIN ' + @ixp_rules + ' temp_ir ON ir.ixp_rules_id = '  + CAST(@ixp_rules_id AS VARCHAR(20)) + '
					IF @old_rules_id IS NOT NULL
					BEGIN
						UPDATE iir
						SET    join_clause = ''' + @join_clause + '''
					FROM   ' + @ixp_import_relation + ' iir
						WHERE iir.ixp_import_relation_id = ''' + CAST(@ixp_import_relation_id AS VARCHAR(20)) + '''
					END
					ELSE
					BEGIN
						UPDATE iir
						SET    join_clause = REPLACE(rf.[join_clause],''' + CAST(@ixp_import_relation_id AS VARCHAR(20)) + ':'','' AND '')
						FROM   ' + @ixp_import_relation + ' iir
						INNER JOIN #relations_final rf ON  rf.[relation_id] = iir.ixp_import_relation_id
					END
				'
		--PRINT(@sql)
		EXEC(@sql)
		
		UPDATE #ixp_import_data_mapping SET [column_function] = NULL WHERE [column_function] = ''
		UPDATE #ixp_import_data_mapping SET [column_aggregation] = NULL WHERE [column_aggregation] = ''
		
		SET @sql = 'DELETE idm 
					FROM ' + @ixp_import_data_mapping + ' idm
					INNER JOIN #ixp_import_data_mapping temp_idm ON temp_idm.rules_id = idm.ixp_rules_id AND temp_idm.table_id = idm.dest_table_id AND ISNULL(idm.repeat_number, 0) = temp_idm.repeat_number 
	    
					INSERT INTO ' + @ixp_import_data_mapping + '(ixp_rules_id, dest_table_id, source_column_name, dest_column, column_function, column_aggregation, repeat_number, udf_field_id)
					SELECT [rules_id], [table_id], [source_column_name], [dest_column], [column_function], [column_aggregation], ISNULL([repeat_number],0), udf_field_id FROM #ixp_import_data_mapping
					
					DELETE iiwc
				    FROM   ' + @ixp_import_where_clause + ' iiwc
				    INNER JOIN #ixp_import_data_mapping temp_idm ON temp_idm.rules_id = iiwc.rules_id AND temp_idm.table_id = iiwc.table_id AND ISNULL(iiwc.repeat_number, 0) = temp_idm.repeat_number
					'
					
		IF @where_clause IS NOT NULL
			SET @sql = @sql + 'INSERT INTO ' + @ixp_import_where_clause + '(rules_id, table_id, ixp_import_where_clause, repeat_number)
							   SELECT TOP 1 [rules_id], [table_id], ''' + @where_clause + ''', repeat_number FROM #ixp_import_data_mapping'
		--PRINT @sql
		EXEC (@sql)

		--EXEC spa_ixp_import_data_mapping 'p', NULL, NULL, @ixp_table_id, @process_id, NULL, NULL
		EXEC spa_ErrorHandler 0,
			 'Import Export FX',
			 'spa_ixp_import_data_mapping',
			 'Success',
			 'Changes have been saved successfully.',
			 @process_id
	END
END TRY
BEGIN CATCH
	IF CURSOR_STATUS('local','sql_syntax_cursor') > = -1
	BEGIN
		DEALLOCATE sql_syntax_cursor
	END
	
	IF CURSOR_STATUS('local','relation_cursor') > = -1
	BEGIN
		DEALLOCATE relation_cursor
	END
		
	IF @@TRANCOUNT > 0
	   ROLLBACK
 
	SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
	SELECT @err_no = ERROR_NUMBER()
 
	EXEC spa_ErrorHandler @err_no,
	     'Import Export FX',
	     'spa_ixp_import_data_mapping',
	     'Error',
	     @DESC,
	     ''
END CATCH	
END
ELSE IF @flag = 'a'
BEGIN
	SET @sql = 'SELECT  CAST(ic.ixp_columns_id AS VARCHAR(24)) column_id,
			ic.ixp_columns_name column_name,
			ic.is_major,
			1 category
	FROM   ixp_columns ic
	WHERE ic.ixp_table_id = ' + CAST(@ixp_table_id AS VARCHAR(8)) 

	IF EXISTS (SELECT 1 FROM ixp_tables where ixp_tables_name = 'ixp_source_deal_template' AND ixp_tables_id = @ixp_table_id)
	SET  @sql += '
			AND ic.ixp_columns_name NOT LIKE ''udf_value%''
		UNION
		SELECT  ''udf_'' + CAST(field_id AS VARCHAR(24)),field_label + '' ['' + IIF(udf_type = ''h'',''Header UDF'',''Detail UDF'') + '']''
			,0, IIF(udf_type = ''h'',2,3)
		FROM user_defined_fields_template 
		WHERE udf_type in (''h'',''d'')
		'
	SET @sql += ' ORDER BY category,column_name'
	
	EXEC(@sql)
END
IF @flag = 'q'
BEGIN
	SET @temp_process_table = 'import_table_columns_' + @process_id
	EXEC ('IF OBJECT_ID(''adiha_process.dbo.' + @temp_process_table + ''') IS NOT NULL
		       DROP TABLE adiha_process.dbo.' + @temp_process_table)
	--PRINT('SELECT TOP 1 * INTO adiha_process.dbo.' + @temp_process_table  + ' FROM ' + @connection_string)
	-- Create temp process table only if data exists in linked server ie @connection_string
	BEGIN TRY	
		EXEC('SELECT TOP 1 * INTO adiha_process.dbo.' + @temp_process_table  + ' FROM ' + @connection_string)
	END TRY
	BEGIN CATCH
		PRINT 'Remote Server not available.'
	END CATCH
		       
	SET @sql = 'SELECT ISNULL(iidm.source_column_name, (ISNULL(iids.data_source_alias + ''.'', '''') + ''['' +  temp.COLUMN_NAME + '']'')) [source_column_name],
					   iidm.dest_column,
	                   iidm.column_function,
	                   iidm.column_aggregation
                FROM   adiha_process.INFORMATION_SCHEMA.COLUMNS temp  WITH(NOLOCK)
                LEFT JOIN ' + @ixp_import_data_source + ' iids ON iids.rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
                LEFT JOIN ' + @ixp_import_data_mapping + ' iidm ON (ISNULL(iids.data_source_alias + ''.'', '''') + ''['' +  temp.COLUMN_NAME + '']'') = ISNULL(REPLACE(iidm.source_column_name, NULLIF(SUBSTRING(iidm.source_column_name, 0, CHARINDEX(''.'', iidm.source_column_name)+1), ''''), ISNULL(iids.data_source_alias + ''.'', '''')), ISNULL(iids.data_source_alias + ''.'', '''') + ''['' + iidm.source_column_name + '']'')  AND iidm.dest_table_id = ' + CAST(@ixp_table_id AS VARCHAR(10)) + '
                WHERE  TABLE_NAME = ''' + @temp_process_table + ''' AND (iidm.ixp_import_data_mapping_id IS NULL OR ISNULL(iidm.repeat_number, 0) = ' + CAST(@repeat_number AS VARCHAR(20)) + ') 
                
                UNION
                SELECT iidm.source_column_name,
					   iidm.dest_column,
					   iidm.column_function,
					   iidm.column_aggregation
                FROM ' + @ixp_import_data_mapping + ' iidm
                INNER JOIN ' + @ixp_import_data_source + ' iids ON  iids.rules_id = iidm.ixp_rules_id 
                WHERE iids.rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
                
                '
    --PRINT(@sql)
    EXEC(@sql)
END

IF @flag = 'r'
BEGIN
	SET @temp_process_table = 'import_table_columns_' + @process_id
	EXEC ('IF OBJECT_ID(''adiha_process.dbo.' + @temp_process_table + ''') IS NOT NULL
		       DROP TABLE adiha_process.dbo.' + @temp_process_table)
	--PRINT('SELECT TOP 1 * INTO adiha_process.dbo.' + @temp_process_table  + ' FROM ' + @connection_string)
	EXEC('SELECT TOP 1 * INTO adiha_process.dbo.' + @temp_process_table  + ' FROM ' + @connection_string)
		       
	SET @sql = 'SELECT temp.COLUMN_NAME [source_column_name]
                FROM   adiha_process.INFORMATION_SCHEMA.COLUMNS temp  WITH(NOLOCK)
                WHERE  TABLE_NAME = ''' + @temp_process_table + ''''
    --PRINT(@sql)
    EXEC(@sql)
END

IF @flag = 't'
BEGIN
	SET @sql = 'SELECT temp.COLUMN_NAME [source_column_name]
                FROM   adiha_process.INFORMATION_SCHEMA.COLUMNS temp  WITH(NOLOCK)
                WHERE  TABLE_NAME = ''' + @temp_process_table + ''''
                
    --PRINT(@sql)
    EXEC(@sql)
END
