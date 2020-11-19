IF OBJECT_ID(N'[dbo].[spa_change_editable_grid_value]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_change_editable_grid_value]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-06-04
-- Description: Updating a process table for 'Apply to all/even/odd' functionality in editable grid.

-- Params:
-- @process_id VARCHAR(200) - process id for a process table.
-- @column_name VARCHAR(100) - column name that is needed to be updated.
-- @column_value VARCHAR(500) - updated value for the column.
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_change_editable_grid_value]
	@flag CHAR,
	@process_id VARCHAR(200),
	@column_name VARCHAR(100) = NULL,
	@column_value VARCHAR(500)= NULL,
	@call_module VARCHAR(50) = NULL,
	@row_id INT = NULL,
	@source_deal_detail_id INT  = NULL	 
AS
	SET NOCOUNT ON
	DECLARE @table_name  VARCHAR(200),
	        @user        VARCHAR(50),
	        @sql         VARCHAR(MAX)
	
	SET @user = dbo.FNADBUser()
	--SET @table_name = 'adiha_process.dbo.paging_sourcedealtemp_' + @user + '_' + @process_id
	SET @table_name = dbo.FNAProcessTableName('paging_sourcedealtemp', @user, @process_id)
	
	--for Apply_to_all functionality
	IF @flag = 'a' OR @flag = 'o' OR @flag = 'e'
	BEGIN			
		BEGIN TRY
			SELECT @table_name
			SET @sql = 'UPDATE ' + @table_name + ' SET [' + @column_name + '] = NULLIF(''' + @column_value + ''', '''') 
			            WHERE 1 = 1 AND ISNULL(NULLIF(LTRIM(RTRIM(lock_deal_detail)), ''''), ''n'') = ''n''
						'
			
			IF @row_id IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND sno >= ' + CAST (@row_id AS VARCHAR(100))
			END
			
			IF @flag = 'o' 
			BEGIN
		 		 SET @sql = @sql + ' AND (sno%2 = 1 OR sno =' + CAST (@row_id AS VARCHAR(100)) + ')'        	
			               
			END
			
			IF @flag = 'e' 
			BEGIN
		 		 SET @sql = @sql + ' AND (sno%2 = 0 OR sno =' + CAST (@row_id AS VARCHAR(100)) + ')'          	
			               
			END	
			EXEC spa_print @sql
			EXEC (@sql)
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler 1,
				 'Temp Paging Table',
				 'spa_update_buy_sell_flag_paging',
				 'DB Error',
				 'Failed Updating record.',
				 'Failed Updating Record'
		END CATCH
	END 
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRY
			SET @sql = 'DELETE FROM ' + @table_name + ' WHERE source_deal_detail_id = ' + CAST(ISNULL(@source_deal_detail_id, -1) AS VARCHAR(10))
			EXEC spa_print @sql
			EXEC(@sql)
		END TRY 
		BEGIN CATCH
			EXEC spa_ErrorHandler 1,
				 'Temp Paging Table',
				 'spa_update_buy_sell_flag_paging',
				 'DB Error',
				 'Failed deleting record.',
				 'Failed Deleting Record'
		END CATCH
	END
	ELSE IF @flag = 'i'
	BEGIN
		BEGIN TRY
			DECLARE @cols VARCHAR(MAX)
			DECLARE @temp_source_deal_detail_id INT 
			
			--inserting unique source_deal_detail_id in staging table
			SELECT @temp_source_deal_detail_id = CONVERT(VARCHAR, DATEPART(HH, GETDATE())) +
												CONVERT(VARCHAR, DATEPART(MI, GETDATE())) +
												CONVERT(VARCHAR, DATEPART(SS, GETDATE())) +
												CONVERT(VARCHAR, DATEPART(MS, GETDATE()))
			
			SELECT @cols = COALESCE(@cols + ',', '') + c.name
			FROM   adiha_process.sys.columns c WITH(NOLOCK)
			WHERE  c.object_id = OBJECT_ID(@table_name)
			       AND c.name NOT IN ('sno', 'source_deal_detail_id')
			
			SET @sql = '
				INSERT INTO ' + @table_name + '(source_deal_detail_id, ' + @cols + ')
				SELECT ' + CAST(@temp_source_deal_detail_id * -1 AS VARCHAR) + ' ,' + @cols + ' FROM ' + @table_name + ' WHERE source_deal_detail_id = ' + CAST(ISNULL(@source_deal_detail_id, -1) AS VARCHAR(10))
			EXEC spa_print @sql
			EXEC (@sql);
		END TRY 
		BEGIN CATCH
			EXEC spa_ErrorHandler 1,
				 'Temp Paging Table',
				 'spa_update_buy_sell_flag_paging',
				 'DB Error',
				 'Failed inserting record.',
				 'Failed inserting Record'
		END CATCH
	
	END 