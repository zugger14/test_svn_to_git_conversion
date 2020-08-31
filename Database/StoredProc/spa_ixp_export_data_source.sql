
IF OBJECT_ID(N'[dbo].[spa_ixp_export_data_source]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_export_data_source]
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
CREATE PROCEDURE [dbo].[spa_ixp_export_data_source]
    @flag CHAR(1) = NULL,
    @ixp_export_data_source_id INT = NULL,
    @ixp_rules_id INT = NULL,
    @process_id VARCHAR(1000) = NULL,
    @table_id VARCHAR(500) = NULL,
    @table_alias VARCHAR(500) = NULL,
    @root_table_id INT = NULL
AS
 
DECLARE @sql VARCHAR(MAX)
DECLARE @ixp_export_data_source VARCHAR(600) 
DECLARE @ixp_export_relation VARCHAR(600)
DECLARE @user_name VARCHAR(200)
DECLARE @ixp_new_export_data_source_id INT
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT

SET @user_name = dbo.FNADBUser() 
SET @ixp_export_data_source = dbo.FNAProcessTableName('ixp_export_data_source', @user_name, @process_id) 
SET @ixp_export_relation = dbo.FNAProcessTableName('ixp_export_relation', @user_name, @process_id) 


IF OBJECT_ID('tempdb..#temp_export_alias_exist') IS NOT NULL
	DROP TABLE #temp_export_alias_exist
	
CREATE TABLE #temp_export_alias_exist ([data_exist] TINYINT)

IF @flag = 'i' -- insert into ixp_export_data_source
BEGIN
	BEGIN TRY
		SET @sql =  'INSERT INTO #temp_export_alias_exist ([data_exist]) SELECT 1 FROM ' + @ixp_export_data_source + ' WHERE export_table_alias = ''' + @table_alias + ''' AND ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
		exec spa_print @sql
		EXEC(@sql)
		
		IF EXISTS (SELECT 1 FROM #temp_export_alias_exist)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'ixp_export_data_source',
				 'spa_ixp_export_data_source',
				 'DB Error',
				 'Relation alias name already used.',
				 ''
			RETURN
		END
	
	
		SET @sql = 'INSERT INTO ' + @ixp_export_data_source + ' (ixp_rules_id, export_table, export_table_alias)
					VALUES(' + CAST(@ixp_rules_id AS VARCHAR(20)) + ' ,''' + @table_id + ''', ''' + @table_alias + ''')'
		
		EXEC(@sql)
		
		SET @ixp_new_export_data_source_id = IDENT_CURRENT(@ixp_export_data_source)
		
		EXEC spa_ErrorHandler 0
			, 'ixp_export_data_source'
			, 'spa_ixp_export_data_source'
			, 'Success' 
			, 'Successfully saved data.'
			, @ixp_new_export_data_source_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'ixp_export_data_source'
		   , 'spa_ixp_export_data_source'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH	
END
IF @flag = 'x' -- insert into ixp_export_data_source
BEGIN
	BEGIN TRY
		SET @sql =  'INSERT INTO #temp_export_alias_exist ([data_exist]) SELECT 1 FROM ' + @ixp_export_data_source + ' WHERE export_table_alias = ''' + @table_alias + ''' AND ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
		exec spa_print @sql
		EXEC(@sql)
		
		IF EXISTS (SELECT 1 FROM #temp_export_alias_exist)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'ixp_export_data_source',
				 'spa_ixp_export_data_source',
				 'DB Error',
				 'Relation alias name already used.',
				 ''
			RETURN
		END
	
	
		SET @sql = 'INSERT INTO ' + @ixp_export_data_source + ' (ixp_rules_id, export_table, export_table_alias, root_table_id)
					VALUES(' + CAST(@ixp_rules_id AS VARCHAR(20)) + ' ,''' + @table_id + ''', ''' + @table_alias + ''',' +  CAST(@root_table_id AS VARCHAR(20)) + ')'
		
		EXEC(@sql)
				
		EXEC spa_ErrorHandler 0
			, 'ixp_export_data_source'
			, 'spa_ixp_export_data_source'
			, 'Success' 
			, 'Successfully saved data.'
			, @root_table_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'ixp_export_data_source'
		   , 'spa_ixp_export_data_source'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH	
END
ELSE IF @flag = 'u' -- insert into ixp_export_data_source
BEGIN
	BEGIN TRY
		SET @sql = 'UPDATE ' + @ixp_export_data_source + '
		            SET    export_table = ''' + @table_id + ''',
		                   export_table_alias = ''' + @table_alias + '''
		            WHERE  ixp_export_data_source_id = ' + CAST(@ixp_export_data_source_id AS VARCHAR(20)) + '
		            AND ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
		
		exec spa_print @sql
		EXEC(@sql)
		
		EXEC spa_ErrorHandler 0
			, 'ixp_export_data_source'
			, 'spa_ixp_export_data_source'
			, 'Success' 
			, 'Successfully saved data.'
			, @ixp_export_data_source_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'ixp_export_data_source'
		   , 'spa_ixp_export_data_source'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH	
END
ELSE IF @flag = 's'
BEGIN
	SET @sql = 'SELECT ieds.ixp_export_data_source_id,
	                   iet.ixp_exportable_table_description [Table],
	                   ieds.export_table_alias [Alias]
	            FROM   ' + @ixp_export_data_source + ' ieds
	            INNER JOIN ixp_exportable_table iet ON ieds.export_table = iet.ixp_exportable_table_id
	            WHERE  ieds.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
	exec spa_print @sql
	EXEC(@sql)	
END
ELSE IF @flag = 'p' -- list all export data source
BEGIN
	SET @sql = 'SELECT ieds.ixp_export_data_source_id [source_id],
	                   ieds.export_table_alias + ''.['' + iet.ixp_exportable_table_description + '']'' [Table]	                   
	            FROM   ' + @ixp_export_data_source + ' ieds
	            INNER JOIN ixp_exportable_table iet ON ieds.export_table = iet.ixp_exportable_table_id
	            WHERE  ieds.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
	EXEC(@sql)	
END
ELSE IF @flag = 't' -- list all export data source
BEGIN
	SET @sql = 'SELECT ieds.ixp_export_data_source_id [source_id],
	                   ieds.export_table_alias + ''.['' + iet.ixp_exportable_table_description + '']'' [Table]
	            FROM   ' + @ixp_export_data_source + ' ieds
	            INNER JOIN ixp_exportable_table iet ON ieds.export_table = iet.ixp_exportable_table_id
	            WHERE ieds.root_table_id IS NOT NULL AND ieds.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ''
	EXEC(@sql)	
END
ELSE IF @flag = 'q' -- list all columns for export data source
BEGIN
	SET @sql = 'SELECT ieds.ixp_export_data_source_id [source_id],
	                   c.name  [Column]
	            FROM   ' + @ixp_export_data_source + ' ieds
	            INNER JOIN ixp_exportable_table iet ON ieds.export_table = iet.ixp_exportable_table_id
	            INNER JOIN sys.columns c ON c.object_id = OBJECT_ID(iet.ixp_exportable_table_name)
	            WHERE  ieds.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ' ORDER BY ieds.export_table_alias '
	exec spa_print @sql
	EXEC(@sql)	
END
ELSE IF @flag = 'v' -- list all columns for export data source
BEGIN
	SET @sql = 'SELECT ieds.ixp_export_data_source_id [source_id],
				ieds.export_table_alias + ''.['' + c.name + '']'' [Column]
	            FROM   ' + @ixp_export_data_source + ' ieds
	            INNER JOIN ixp_exportable_table iet ON ieds.export_table = iet.ixp_exportable_table_id
	            INNER JOIN sys.columns c ON c.object_id = OBJECT_ID(iet.ixp_exportable_table_name)
	            WHERE  ieds.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ' ORDER BY ieds.export_table_alias '
	exec spa_print @sql
	EXEC(@sql)	
END
ELSE IF @flag = 'r' -- list all export data source
BEGIN
	SELECT iet.ixp_exportable_table_id,
	       iet.ixp_exportable_table_description
	FROM   ixp_exportable_table iet	
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRANSACTION;
		DECLARE @is_root CHAR(1)
		
		IF OBJECT_ID('tempdb..#is_root') IS NOT NULL
			DROP TABLE #is_root
		CREATE TABLE #is_root (is_root_table CHAR(1) COLLATE DATABASE_DEFAULT )
		
		SET @sql = 'INSERT INTO #is_root (is_root_table)
					SELECT CASE WHEN root_table_id IS NULL THEN ''y'' ELSE ''n'' END 
		            FROM   ' + @ixp_export_data_source + '
					WHERE ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
					AND ixp_export_data_source_id = ' + CAST(@ixp_export_data_source_id AS VARCHAR(20))
		exec spa_print @sql
		EXEC(@sql)
		
		SELECT @is_root = is_root_table FROM #is_root		
		SET @sql = 'DELETE FROM ' + @ixp_export_relation + '
					WHERE (from_data_source = ' + CAST(@ixp_export_data_source_id AS VARCHAR(20)) + ' 
							OR to_data_source = ' + CAST(@ixp_export_data_source_id AS VARCHAR(20)) + ') 
					AND ixp_rules_id =' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
					
					DELETE 
					FROM   ' + @ixp_export_data_source + '
					WHERE ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
					AND ixp_export_data_source_id = ' + CAST(@ixp_export_data_source_id AS VARCHAR(20))
		exec spa_print @sql
		EXEC(@sql)	
		
		EXEC spa_ErrorHandler 0
		   , 'ixp_export_data_source'
		   , 'spa_ixp_export_data_source'
		   , 'Error'
		   , 'Delete Sucessfully'
		   , @is_root
		   
	COMMIT TRANSACTION;
END
ELSE IF @flag = 'y'
BEGIN
	SELECT ieds.ixp_export_data_source_id,
		   ieds.export_table,
	       ieds.export_table_alias
	FROM   ixp_export_data_source ieds
	WHERE  ieds.root_table_id IS NULL
	AND ieds.ixp_rules_id = @ixp_rules_id
END

--SELECT rd.[report_dataset_id],
--       dsc.[data_source_column_id],
--       rd.[alias] + ''.'' + dsc.[name] AS [name], 
--       dsc.alias
--FROM   ' + @rfx_report_dataset + ' rd
--JOIN data_source ds ON  rd.source_id = ds.data_source_id
--JOIN data_source_column dsc ON  dsc.source_id = ds.data_source_id
--WHERE  rd.report_id = ' + CAST(@report_id AS VARCHAR(10)) + '
--ORDER BY dsc.alias, rd.root_dataset_id ASC
