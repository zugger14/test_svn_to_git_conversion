IF OBJECT_ID(N'[dbo].[spa_ixp_import_query_builder_import_tables]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_import_query_builder_import_tables]
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
CREATE PROCEDURE [dbo].[spa_ixp_import_query_builder_import_tables]
    @flag CHAR(1),
    @ixp_import_query_builder_import_tables_id INT = NULL,
    @ixp_rules_id INT = NULL,
    @process_id VARCHAR(100) = NULL,
    @table_id INT = NULL,
    @sequence_number INT = NULL    
AS
 
DECLARE @sql VARCHAR(MAX)
DECLARE @user_name VARCHAR(200)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT
DECLARE @column_count_r INT
DECLARE @ixp_import_query_builder_import_tables VARCHAR(600)
DECLARE @ixp_custom_import_mapping VARCHAR(600) 

SET @user_name = dbo.FNADBUser() 
SET @ixp_import_query_builder_import_tables = dbo.FNAProcessTableName('ixp_import_query_builder_import_tables', @user_name, @process_id)
SET @ixp_custom_import_mapping = dbo.FNAProcessTableName('ixp_custom_import_mapping', @user_name, @process_id)
 
IF @flag = 'i'
BEGIN
	BEGIN TRY
		CREATE TABLE #ixp_seq_check ( [counter_r] INT)
		SET @sql = 'INSERT INTO #ixp_seq_check(counter_r) 
					SELECT COUNT(*) FROM   '+ @ixp_import_query_builder_import_tables +' WHERE sequence_number = ' + CAST(@sequence_number AS VARCHAR(20)) + ' AND ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20))
		EXEC(@sql)
		
		SELECT @column_count_r = counter_r FROM #ixp_seq_check	
		IF @column_count_r IS NOT NULL AND @column_count_r > 0
		BEGIN
			EXEC spa_ErrorHandler -1, 'Import/Export Wizard', 'spa_ixp_import_query_builder_tables', 'DB Error', 'Sequence already exists.', ''
			RETURN
		END
		
		SET @sql = 'INSERT INTO ' + @ixp_import_query_builder_import_tables + ' (ixp_rules_id, table_id, sequence_number)
					SELECT ' +  CAST(@ixp_rules_id AS VARCHAR(20)) + ',' +  CAST(@table_id AS VARCHAR(20)) + ', ' +  CAST(@sequence_number AS VARCHAR(20))
					
		exec spa_print @sql
		EXEC (@sql)
		
		EXEC spa_ErrorHandler 0, 'Import/Export Wizard', 'spa_ixp_import_query_builder_import_tables', 'Success', 'Successfully saved data.', ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no, 'Import/Export Wizard', 'spa_ixp_import_query_builder_import_tables', 'Error', @desc, ''
	END CATCH 
END

IF @flag = 'd'
BEGIN
	BEGIN TRANSACTION;
		BEGIN TRY			
			SET @sql = 'DELETE FROM ' + @ixp_custom_import_mapping + '
						WHERE dest_table_id = ' + CAST(@ixp_import_query_builder_import_tables_id AS VARCHAR(20)) + ' 
						AND ixp_rules_id =' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
						
						DELETE 
						FROM   ' + @ixp_import_query_builder_import_tables + '
						WHERE ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + '
						AND ixp_import_query_builder_import_tables_id = ' + CAST(@ixp_import_query_builder_import_tables_id AS VARCHAR(20))
			exec spa_print @sql
			EXEC(@sql)	
			
			EXEC spa_ErrorHandler 0, 'Import/Export Wizard', 'spa_ixp_import_query_builder_import_tables', 'Success', 'Delete Successful.', ''	
			
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;
			EXEC spa_ErrorHandler -1, 'Import/Export Wizard', 'spa_ixp_import_query_builder_import_tables', 'Error', 'Delete Failed.', ''
		END CATCH
	COMMIT TRANSACTION;
END

IF @flag = 's'
BEGIN
	SET @sql = 'SELECT iiqbit.ixp_import_query_builder_import_tables_id [table_id],
					   iet.ixp_exportable_table_description [Table],
					   iiqbit.sequence_number [Sequence]
				FROM ' + @ixp_import_query_builder_import_tables + ' iiqbit
				INNER JOIN ixp_exportable_table iet ON iet.ixp_exportable_table_id = iiqbit.table_id
				WHERE iiqbit.ixp_rules_id = ' + CAST(@ixp_rules_id AS VARCHAR(20)) + ' ORDER BY iiqbit.sequence_number'
	EXEC(@sql)
END



