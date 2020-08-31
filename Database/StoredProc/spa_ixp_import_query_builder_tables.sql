
IF OBJECT_ID(N'[dbo].[spa_ixp_import_query_builder_tables]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_import_query_builder_tables]
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
CREATE PROCEDURE [dbo].[spa_ixp_import_query_builder_tables]
    @flag CHAR(1),
    @ixp_import_query_builder_tables_id INT = NULL,
    @ixp_rules_id INT = NULL,
    @process_id VARCHAR(500) = NULL,
    @table_name VARCHAR(500) = NULL,
    @root_table_id VARCHAR(500) = NULL,
    @table_alias VARCHAR(100) = NULL
AS
 
DECLARE @sql VARCHAR(MAX)
DECLARE @user_name VARCHAR(200)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT
DECLARE @ixp_import_query_builder_tables VARCHAR(600)
DECLARE @ixp_import_query_builder_relation VARCHAR(600)
DECLARE @ixp_custom_import_mapping VARCHAR(600)

SET @user_name = dbo.FNADBUser() 
SET @ixp_import_query_builder_tables = dbo.FNAProcessTableName('ixp_import_query_builder_tables', @user_name, @process_id)
SET @ixp_import_query_builder_relation = dbo.FNAProcessTableName('ixp_import_query_builder_relation', @user_name, @process_id) 
SET @ixp_custom_import_mapping = dbo.FNAProcessTableName('ixp_custom_import_mapping', @user_name, @process_id)

 
IF @flag = 'r'
BEGIN
	BEGIN TRY
		CREATE TABLE #ixp_alias_check ( [counter_r] INT)
		DECLARE @column_count_r INT
		SET @sql = 'INSERT INTO #ixp_alias_check(counter_r) 
					SELECT COUNT(*) FROM   '+ @ixp_import_query_builder_tables +' WHERE  table_alias = '''+ @table_alias +''' AND ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
		EXEC(@sql)
		
		SELECT @column_count_r = counter_r FROM #ixp_alias_check	
		IF @column_count_r IS NOT NULL AND @column_count_r > 0
		BEGIN
			EXEC spa_ErrorHandler -1, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'DB Error', 'Alias already exists.', ''
			RETURN
		END
		
		SET @sql = 'INSERT INTO ' + @ixp_import_query_builder_tables + '(ixp_rules_id, tables_name, root_table_id, table_alias)
					VALUES(
						' + CAST(@ixp_rules_id AS VARCHAR(10)) + ',					
						''' + @table_name + ''',
						' + CAST(@root_table_id AS VARCHAR(10)) + ',
						''' + @table_alias + '''
					 )'
		exec spa_print @sql
		EXEC (@sql)
		
		EXEC spa_ErrorHandler 0, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'Success', 'Successfully saved data.', ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'Error', @desc, ''
	END CATCH
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
			CREATE TABLE #ixp_alias_check1 ( [counter_r] INT)
			SET @sql = 'INSERT INTO #ixp_alias_check1(counter_r) 
						SELECT COUNT(*) FROM   '+ @ixp_import_query_builder_tables +' WHERE  table_alias = '''+ @table_alias +''' AND ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ' AND ixp_import_query_builder_tables_id <> ' + CAST(@ixp_import_query_builder_tables_id AS VARCHAR(20)) 
			EXEC(@sql)
			
			SELECT @column_count_r = counter_r FROM #ixp_alias_check1	
			IF @column_count_r IS NOT NULL AND @column_count_r > 0
			BEGIN
				EXEC spa_ErrorHandler -1, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'DB Error', 'Alias already exists.', ''
				RETURN
			END
			
			SET @sql = 'UPDATE ' + @ixp_import_query_builder_tables + '
						SET ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ',					
							tables_name = ''' + @table_name + ''',
							table_alias = ''' + @table_alias + '''
			            WHERE ixp_import_query_builder_tables_id = ' + CAST(@ixp_import_query_builder_tables_id AS VARCHAR(20))
			exec spa_print @sql
			EXEC (@sql)
		
		EXEC spa_ErrorHandler 0, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'Success', 'Successfully saved data.', @ixp_import_query_builder_tables_id
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'Error', @desc, ''
	END CATCH
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
			CREATE TABLE #ixp_alias_check2 ( [counter_r] INT)
			SET @sql = 'INSERT INTO #ixp_alias_check2(counter_r) 
						SELECT COUNT(*) FROM   '+ @ixp_import_query_builder_tables +' WHERE  table_alias = '''+ @table_alias +''' AND ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
			EXEC(@sql)
			
			SELECT @column_count_r = counter_r FROM #ixp_alias_check2	
			IF @column_count_r IS NOT NULL AND @column_count_r > 0
			BEGIN
				EXEC spa_ErrorHandler -1, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'DB Error', 'Alias already exists.', ''
				RETURN
			END
			
			SET @sql = 'INSERT INTO ' + @ixp_import_query_builder_tables + '(ixp_rules_id, tables_name, table_alias)
						VALUES(
							' + CAST(@ixp_rules_id AS VARCHAR(10)) + ',					
							''' + @table_name + ''',
							''' + @table_alias + '''
						 )'
			EXEC (@sql)
			
			SET @ixp_import_query_builder_tables_id = IDENT_CURRENT(@ixp_import_query_builder_tables)
		
		EXEC spa_ErrorHandler 0, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'Success', 'Successfully saved data.', @ixp_import_query_builder_tables_id
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'Error', @desc, ''
	END CATCH
END

IF @flag = 's'
BEGIN
	SET @sql = 'SELECT iiqbt.ixp_import_query_builder_tables_id,
					   iiqbt.tables_name [Table],
					   iiqbt.table_alias [Alias]
				FROM ' + @ixp_import_query_builder_tables + ' iiqbt
				WHERE iiqbt.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
	EXEC(@sql)	
END

IF @flag = 'd'
BEGIN
	BEGIN TRANSACTION;
		BEGIN TRY
			CREATE TABLE #is_root (is_root CHAR(1) COLLATE DATABASE_DEFAULT)
			
			SET @sql = 'INSERT INTO #is_root (is_root)
						SELECT CASE WHEN root_table_id IS NULL THEN ''y'' ELSE ''n'' END
						FROM   ' + @ixp_import_query_builder_tables + '
						WHERE  ixp_import_query_builder_tables_id = ' + CAST(@ixp_import_query_builder_tables_id AS VARCHAR(20)) + '
			
						DELETE FROM ' + @ixp_import_query_builder_relation + '
						WHERE (from_table_id = ' + CAST(@ixp_import_query_builder_tables_id AS VARCHAR(20)) + ' 
								OR to_table_id = ' + CAST(@ixp_import_query_builder_tables_id AS VARCHAR(20)) + ') 
						AND ixp_rules_id =' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
						
						UPDATE ' + @ixp_custom_import_mapping + '
						SET source_table_id = NULL, source_column = NULL
						WHERE source_table_id = ' + CAST(@ixp_import_query_builder_tables_id AS VARCHAR(20)) + '
						AND ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
						
						DELETE 
						FROM   ' + @ixp_import_query_builder_tables + '
						WHERE ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
						AND ixp_import_query_builder_tables_id = ' + CAST(@ixp_import_query_builder_tables_id AS VARCHAR(20))
			exec spa_print @sql
			EXEC(@sql)	
			
			IF EXISTS(SELECT 1 FROM #is_root WHERE is_root = 'y')
			BEGIN
				EXEC spa_ErrorHandler 0, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'Success', 'Delete Successful.', ''	
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 0, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'Success', 'Delete Successful.', @ixp_import_query_builder_tables_id
			END
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;
			EXEC spa_ErrorHandler -1, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'Error', 'Delete Failed.', @ixp_import_query_builder_tables_id
		END CATCH
	COMMIT TRANSACTION;
END
IF @flag = 'a'
BEGIN
	SELECT iiqbt.ixp_import_query_builder_tables_id,
	       it.ixp_tables_id [Table],
	       iiqbt.table_alias [Alias]
	FROM   ixp_import_query_builder_tables iiqbt
	INNER JOIN ixp_tables it ON  iiqbt.tables_name = it.ixp_tables_description
	WHERE  iiqbt.root_table_id IS NULL AND iiqbt.ixp_rules_id = @ixp_rules_id	
END
