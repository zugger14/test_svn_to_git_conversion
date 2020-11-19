IF OBJECT_ID(N'[dbo].[spa_ixp_import_relation]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_import_relation]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_ixp_import_relation]   
    @flag CHAR(1),
    @process_id VARCHAR(400) = NULL,
    @relation_id INT = NULL,
    @rules_id INT = NULL,
    @relation_alias VARCHAR(100) = NULL,
    @connection_string VARCHAR(5000) = NULL,
    @relation_location VARCHAR(5000) = NULL,
    @relation_source_type INT = NULL,
    @delimiter VARCHAR(20) = NULL,
	@excel_sheet VARCHAR(100) = NULL,
	@table_id INT = NULL,
	@row_index INT = NULL
AS
SET NOCOUNT ON
DECLARE @sql                     VARCHAR(MAX)
DECLARE @ixp_import_relation     VARCHAR(400)
DECLARE @ixp_import_data_source  VARCHAR(200)
DECLARE @user_name               VARCHAR(100)
DECLARE @DESC                    VARCHAR(500)
DECLARE @err_no                  INT
SET @user_name = dbo.FNADBUser()

SET @ixp_import_relation = dbo.FNAProcessTableName('ixp_import_relation', @user_name, @process_id)
SET @ixp_import_data_source = dbo.FNAProcessTableName('ixp_import_data_source', @user_name, @process_id) 

IF @process_id IS NULL 
	SET @process_id = dbo.FNAGetNewID()
	
IF @flag = 's'
BEGIN
	SET @sql = 'SELECT iir.ixp_import_relation_id,
					   LTRIM(RTRIM(REPLACE(ISNULL(iir.connection_string, iir.relation_location), ''\'', ''\\''))) [Relation],
	                   iir.ixp_relation_alias [Alias],
	                   iir.relation_source_type [Type]
	            FROM ' + @ixp_import_relation + ' iir
	            WHERE  iir.ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20)) 	
	IF @row_index IS NOT NULL AND @row_index <> 0
	BEGIN
		SET @sql += 'AND ixp_import_relation_id < ' + CAST(@row_index AS VARCHAR(20))
	END
	SET @sql += ' UNION ALL
				SELECT iir.ixp_import_data_source_id,
									RIGHT(iir.data_source_location, CHARINDEX(''.xlsx'',iir.data_source_location) - CHARINDEX(''temp_Note\'', iir.data_source_location) -5 ),
					                   iir.data_source_alias [Alias],
					                   iir.data_source_type [Type]
				FROM ' + @ixp_import_data_source + ' iir
				WHERE  iir.rules_id = ' + CAST(@rules_id AS VARCHAR(20))
	IF @row_index = 0 OR @row_index IS NULL 
	BEGIN
		SET @sql += 'AND 1 = 2'
	END
					--PRINT(@sql)
	EXEC(@sql)
END
IF @flag = 'w'
BEGIN
	SET @sql = 'SELECT iir.ixp_import_relation_id,
					   LTRIM(RTRIM(REPLACE(ISNULL(iir.connection_string, iir.relation_location), ''\'', ''\\''))) [Relation],
	                   --iir.ixp_relation_alias [Alias],
					   a.alias [Alias],
	                   iir.relation_source_type [Type]
	            FROM ' + @ixp_import_relation + ' iir
				OUTER APPLY (
					SELECT  DISTINCT LEFT(imdm.source_column_name, CHARINDEX(''['',imdm.source_column_name) - 2) alias
					FROM  ixp_import_data_mapping imdm 		
					WHERE imdm.ixp_rules_id  = ' + CAST(@rules_id AS VARCHAR(20)) 
	IF @table_id IS NOT NULL					
		SET @sql +=' AND imdm.dest_table_id < ' + CAST(@table_id AS VARCHAR(20)) 
	
	SET @sql +=') a				
	            WHERE  iir.ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20)) + '
				AND a.alias = iir.ixp_relation_alias 
				--AND iir.join_clause IS NOT NULL'

	SET @sql += '
				UNION ALL
				SELECT  DISTINCT iir.ixp_import_relation_id,
						LTRIM(RTRIM(REPLACE(ISNULL(iir.connection_string, iir.relation_location), ''\'', ''\\''))) [Relation],		
						LEFT(imdm.source_column_name, CHARINDEX(''['',imdm.source_column_name) - 2) [Alias],
						iir.relation_source_type [Type]
				FROM  ixp_import_data_mapping imdm 	
				LEFT JOIN ' + @ixp_import_relation + ' iir
					ON iir.ixp_relation_alias = LEFT(imdm.source_column_name, CHARINDEX(''['',imdm.source_column_name) - 2)
				WHERE iir.ixp_import_relation_id IS NULL
					AND imdm.ixp_rules_id  = ' + CAST(@rules_id AS VARCHAR(20))  

	IF @table_id IS NOT NULL					
		SET @sql +=' AND imdm.dest_table_id < ' + CAST(@table_id AS VARCHAR(20)) 
	
	--PRINT(@sql)
	EXEC(@sql)
END
IF @flag = 'z'
BEGIN
	SET @sql  = 'SELECT DISTINCT imdm.source_column_name [column_name] FROM (
					SELECT iir.ixp_import_relation_id,
						   LTRIM(RTRIM(REPLACE(ISNULL(iir.connection_string, iir.relation_location), ''\'', ''\\''))) [Relation],
					       --iir.ixp_relation_alias [Alias],
						   a.alias [Alias],
					       iir.relation_source_type [Type]
					FROM ' + @ixp_import_relation + ' iir
					OUTER APPLY (
						SELECT  DISTINCT LEFT(imdm.source_column_name, CHARINDEX(''['',imdm.source_column_name) - 2) alias
						FROM  ixp_import_data_mapping imdm 		
						WHERE imdm.ixp_rules_id  = ' + CAST(@rules_id AS VARCHAR(20)) + '
							AND imdm.dest_table_id <> ' + CAST(@table_id AS VARCHAR(20)) + ' 
					) a				
				WHERE iir.ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20)) + ' 
				AND iir.join_clause IS NOT NULL
				)b
				INNER JOIN ixp_import_data_mapping imdm
					ON LEFT(imdm.source_column_name, CHARINDEX(''['',imdm.source_column_name) - 2)  = b.alias
					AND b.alias = ''' + @relation_alias + '''
					AND imdm.ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20)) + '  
					AND imdm.source_column_name  <> '''''	
	EXEC(@sql)
END

IF @flag = 'a'
BEGIN
	SET @sql = 'SELECT iir.ixp_import_relation_id,
					   iir.ixp_relation_alias [Alias],
	                   LTRIM(RTRIM(REPLACE(ISNULL(iir.connection_string, iir.relation_location), ''\'', ''\\''))) [Relation],
	                   iir.relation_source_type [Source],
	                   iir.delimiter,
					   iir.excel_sheet
	            FROM ' + @ixp_import_relation + ' iir
	            WHERE  iir.ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20)) + '
	                   AND iir.ixp_import_relation_id = ' + CAST(@relation_id AS VARCHAR(20))
	--PRINT(@sql)
	EXEC(@sql)
END
IF @flag = 'i'
BEGIN
	BEGIN TRY
		CREATE TABLE #temp_alias_exist ([data_exist] TINYINT)
		SET @sql =  'INSERT INTO #temp_alias_exist ([data_exist]) SELECT 1 FROM ' + @ixp_import_relation + ' WHERE ixp_relation_alias = ''' + @relation_alias + ''' AND ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20))
		--PRINT(@sql)
		EXEC(@sql)
		
		SET @sql =  'INSERT INTO #temp_alias_exist ([data_exist]) SELECT 1 FROM ' + @ixp_import_data_source + ' WHERE data_source_alias = ''' + @relation_alias + ''' AND rules_id = ' + CAST(@rules_id AS VARCHAR(20))
		--PRINT(@sql)
		EXEC(@sql)
		
		IF EXISTS (SELECT 1 FROM #temp_alias_exist)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'ixp_import_relation',
				 'spa_ixp_import_relation',
				 'DB Error',
				 'Relation alias name already used.',
				 ''
			RETURN
		END
		
		SET @sql = 'INSERT INTO ' + @ixp_import_relation + ' (ixp_rules_id, ixp_relation_alias, connection_string, relation_location, relation_source_type, delimiter, excel_sheet)
					SELECT ' + CAST(@rules_id AS VARCHAR(20)) + ',
					       ''' + @relation_alias + ''',
					       ' + ISNULL('''' + LTRIM(RTRIM(@connection_string)) + '''', 'NULL') + ',
					       ' + ISNULL('''' + LTRIM(RTRIM(@relation_location)) + '''', 'NULL') + ',
					       ' + CAST(@relation_source_type AS VARCHAR(20)) + ',
					       ' + ISNULL('''' + @delimiter + '''', 'NULL') + ',
					       ' + ISNULL('''' + @excel_sheet + '''', 'NULL') + '' 
		
		--PRINT(@sql)
		EXEC(@sql)
		
		EXEC spa_ErrorHandler 0
			, 'ixp_import_relation'
			, 'spa_ixp_import_relation'
			, 'Success' 
			, 'Successfully saved data.'
			, ''
	END TRY
	BEGIN CATCH	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'ixp_import_relation'
		   , 'spa_ixp_import_relation'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
IF @flag = 'u'
BEGIN
	BEGIN TRY
		CREATE TABLE #temp_alias_exist_update ([data_exist] TINYINT)
		SET @sql =  'INSERT INTO #temp_alias_exist_update ([data_exist]) SELECT 1 FROM ' + @ixp_import_relation + ' WHERE ixp_relation_alias = ''' + @relation_alias + ''' AND ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20)) + ' AND ixp_import_relation_id <> ' + CAST(@relation_id AS VARCHAR(20))
		--PRINT(@sql)
		EXEC(@sql)
		
		SET @sql =  'INSERT INTO #temp_alias_exist_update ([data_exist]) SELECT 1 FROM ' + @ixp_import_data_source + ' WHERE data_source_alias = ''' + @relation_alias + ''' AND rules_id = ' + CAST(@rules_id AS VARCHAR(20))
		--PRINT(@sql)
		EXEC(@sql)
		
		IF EXISTS (SELECT 1 FROM #temp_alias_exist_update)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'ixp_import_relation',
				 'spa_ixp_import_relation',
				 'DB Error',
				 'Relation alias name already exists.',
				 ''
			RETURN
		END
		
		SET @sql = 'UPDATE ' + @ixp_import_relation + '
		            SET    ixp_relation_alias = ''' + @relation_alias + ''',
		                   connection_string = ' + ISNULL('''' + LTRIM(RTRIM(@connection_string)) + '''', 'NULL') + ',
		                   relation_location = ' + ISNULL('''' + LTRIM(RTRIM(@relation_location)) + '''', 'NULL') + ',
		                   relation_source_type = ' + CAST(@relation_source_type AS VARCHAR(20)) + ',
		                   delimiter = ' + ISNULL('''' + @delimiter + '''', 'NULL') + ',
		                   excel_sheet = ' + ISNULL('''' + @excel_sheet + '''', 'NULL') + '
		            WHERE ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20)) + ' AND ixp_import_relation_id = ' + CAST(@relation_id AS VARCHAR(20)) + ''
		
		--PRINT(@sql)
		EXEC(@sql)
		
		EXEC spa_ErrorHandler 0
			, 'ixp_import_relation'
			, 'spa_ixp_import_relation'
			, 'Success' 
			, 'Successfully saved data.'
			, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'ixp_import_relation'
		   , 'spa_ixp_import_relation'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
IF @flag = 'd'
BEGIN
	BEGIN TRY
		SET @sql = 'DELETE FROM  ' + @ixp_import_relation + '
		            WHERE ixp_import_relation_id = ' + CAST(@relation_id AS VARCHAR(20)) + ''
		
		--PRINT(@sql)
		EXEC(@sql)		
		
		EXEC spa_ErrorHandler 0
			, 'ixp_import_relation'
			, 'spa_ixp_import_relation'
			, 'Success' 
			, 'Successfully deleted data.'
			, ''
	END TRY
	BEGIN CATCH	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
			   , 'ixp_import_relation'
			   , 'spa_ixp_import_relation'
			   , 'Error'
			   , @DESC
			   , ''
	END CATCH	
END
IF @flag = 'x'
BEGIN
	DECLARE @temp_process_table VARCHAR(200)
	SET @temp_process_table = 'import_linked_table_columns_' + @process_id
	EXEC ('IF OBJECT_ID(''adiha_process.dbo.' + @temp_process_table + ''') IS NOT NULL 
			DROP TABLE adiha_process.dbo.' + @temp_process_table)
		       
	--PRINT('SELECT TOP 1 * INTO adiha_process.dbo.' + @temp_process_table  + ' FROM ' + @connection_string)
	EXEC('SELECT TOP 1 * INTO adiha_process.dbo.' + @temp_process_table  + ' FROM ' + @connection_string)
	
	SET @sql = 'SELECT ''' + ISNULL(cast(@relation_alias as varchar(10)) + ''' +''.', '' ) + ''' + ''['' + COLUMN_NAME + '']'' [column_name]
                FROM   adiha_process.INFORMATION_SCHEMA.COLUMNS  WITH(NOLOCK)              
                WHERE  TABLE_NAME = ''' + @temp_process_table + ''' ORDER BY COLUMN_NAME'
    --PRINT(@sql)
    EXEC(@sql)
END
IF @flag = 'y'
BEGIN
	SET @sql  = 'DECLARE @join_clause VARCHAR(MAX)
				 SELECT @join_clause = COALESCE(@join_clause + ''AND '', '''') + join_clause FROM ' + @ixp_import_relation + ' WHERE ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20)) + '
				 
				 SELECT * INTO #temp_relation FROM dbo.FNASplit(@join_clause, ''AND'') 
				 
				 SELECT LTRIM(RTRIM(SUBSTRING(item, 0, CHARINDEX(''='', item)))) AS source_column,
					    LTRIM(RTRIM(SUBSTRING(item, (CHARINDEX(''='', item) + 1), LEN(item)))) AS join_column
				 FROM #temp_relation'
	--PRINT(@sql)
    EXEC(@sql)
END

--exec spa_ixp_import_relation 'x',NULL, 46, NULL, NULL, 'LS_ADIHA_PROCESS.adiha_process.dbo.[ST_SD_LOCATION]'

IF @flag = 'q'
BEGIN
	SET @sql  = '
				SELECT ixp_import_relation_id,join_clause
				FROM ( SELECT ixp_import_relation_id,join_clause,ROW_NUMBER() OVER(PARTITION BY ixp_rules_id ORDER BY ixp_import_relation_id) table_order  
						FROM ' + @ixp_import_relation + ' 
						where ixp_rules_id = ' + CAST(@rules_id AS VARCHAR(20)) + '
				) tbl
				WHERE tbl.table_order = ' + CAST(@row_index AS VARCHAR(20)) + '
				'
    EXEC(@sql)
END
