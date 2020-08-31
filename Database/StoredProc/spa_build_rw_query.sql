IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_build_rw_query]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_build_rw_query]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================
-- Create date: 2010-01-06 14:46
-- Description:	Builds a runnable SQL query from a Report Writer Report
-- ========================================================================
CREATE PROCEDURE dbo.spa_build_rw_query
	@report_id			int,
	@criteria			varchar(5000) = NULL,
	@temp_table_name	varchar(100) = NULL,
	@batch_process_id	varchar(50) = NULL,
	@batch_report_param varchar(1000) = NULL,
	@table_name			varchar(50) = NULL,
	@sql_stmt			varchar(MAX),
	@final_sql			varchar(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @sql_report			varchar(1)
	DECLARE @from_index			int
	DECLARE @batch_index		int	
	DECLARE @batch_identifier	varchar(100)
	
	SET @batch_identifier = '--[__batch_report__]'	
	SET @final_sql = ''
	
	BEGIN TRY
	
		IF @report_id IS NOT NULL
		BEGIN
			SELECT @sql_stmt = report_sql_statement, @table_name = report_tablename, @sql_report = report_sql_check 
			FROM Report_record 
			WHERE report_id = @report_id 
		END
		ELSE
		BEGIN
			SELECT @sql_report = (CASE WHEN ISNULL(@table_name, '') = '' THEN 'y' ELSE 'n' END)
		END
		
		----------------------------------------Replace View name with View SQL or temp table name Started--------------------------------
		IF ISNULL(@sql_report, 'n') = 'n'
		BEGIN
			DECLARE @vw_Sql		varchar(MAX)
						
			SELECT @vw_Sql = vw_sql FROM report_writer_table WHERE table_name = @table_name

			SET @batch_index = CHARINDEX(@batch_identifier, @vw_Sql)
			EXEC spa_print 'View Batch Index: ', @batch_index			

			--if view is a multiline statement, execute it to save result in temp table
			--and replace view identifier with that table name
			IF @batch_index > 0
			BEGIN
				
				SET @from_index = dbo.FNACharIndexMatchWholeWord('FROM', @vw_Sql, @batch_index)
				EXEC spa_print 'View Batch Index: ', @from_index
				
				IF ISNULL(@from_index, 0) = 0
					RAISERROR ('Query is malformed. A final SELECT ... FROM ... statement must be present in SQL after batch identifier(--[__batch_report__]).', -- Message text.
								   16, -- Severity.
								   1 -- State.
								   );
				
				DECLARE @vw_batch_table varchar(5000)
				DECLARE @process_id		varchar(100)
				SET @process_id = dbo.FNAGetNewID()
				
				SET @vw_batch_table = dbo.FNAProcessTableName('view_report', dbo.FNADBUser(), @process_id)
				EXEC spa_print 'View result temp table: ', @vw_batch_table
				
				SET @vw_Sql = SUBSTRING(@vw_Sql, 0, @from_index) + ' INTO ' + @vw_batch_table + ' ' +  SUBSTRING(@vw_Sql, @from_index, LEN(@vw_Sql))
				
				--Replace Params in View definition if it is multiline statement
				--otherwise it will be done later after replacing view name with view definition
				SET @vw_Sql = dbo.FNAReplaceRWParams(@vw_Sql, @criteria)
				--set @vw_Sql = REPLACE(@vw_Sql, '''''', '''')
				
				--SET Value to ON to fix incorrect setting 'QUOTED_IDENTIFIER'
				SET @vw_Sql = 'SET QUOTED_IDENTIFIER ON;' + CHAR(10) + @vw_Sql
				
				EXEC spa_print '****************************************View SQL Started****************************************:' 
					, @vw_Sql,'****************************************View SQL Ended******************************************:'
			
				EXEC(@vw_Sql)
				SET @sql_stmt = REPLACE(@sql_stmt, @table_name, ' ' + @vw_batch_table + ' ')
				--SET @sql_stmt = REPLACE(@sql_stmt, '''''', '''')
			END			
			ELSE
			BEGIN
				SET @sql_stmt = REPLACE(@sql_stmt, @table_name, ' (' + @vw_Sql + ') vw ')			
			END
				
		END
		----------------------------------------Replace View name with View SQL Completed--------------------------------
		
		--Replace variables in SQL Started
		SET @sql_stmt = dbo.FNAReplaceRWParams(@sql_stmt, @criteria)

		--SET @sql_stmt = REPLACE(@sql_stmt, '''''', '''')

		EXEC spa_print'****************************************Final SQL Started****************************************:' 
			, @sql_stmt,
			 '****************************************Final SQL Ended******************************************:'
			
		IF @sql_report <> 'y'
		BEGIN
			--for view based report, just finding FROM is enough as there will be only one FROM in the final query
			SET @from_index = dbo.FNACharIndexMatchWholeWord('FROM', @sql_stmt, 0)
		END 
		ELSE
		BEGIN
			--for sql based reports, first try to find @batch_identifier as finding FROM after @batch_identifier
			--is sure-shot job
			SET @batch_index = CHARINDEX(@batch_identifier, @sql_stmt)
			EXEC spa_print 'Batch Index: ', @batch_index
			
			IF @batch_index > 0
			BEGIN
				SET @from_index = dbo.FNACharIndexMatchWholeWord('FROM', @sql_stmt, @batch_index)
			END
			ELSE
			BEGIN
				--if no @batch_identifier found, the only best option is trying to find FROM from the end
				SET @from_index = dbo.FNACharIndexReverseMatchWholeWord('FROM', @sql_stmt, 0)
				EXEC spa_print 'Last occurence of FROM: ', @from_index
			END
		END

		DECLARE @str_batch_table varchar(max)
		SET @str_batch_table = ''
		
		IF @batch_process_id IS NULL 
		BEGIN
			IF @temp_table_name IS NOT NULL 
				--add an auto-number column while inserting in process table. Altering process table to add sno later distorts the data order
				SET @str_batch_table = ', IDENTITY(INT, 1, 1) AS sno INTO ' + @temp_table_name 
		END
		ELSE
		BEGIN
			--add an auto-number column while inserting in process table. Altering process table to add sno later distorts the data order
			SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id, @batch_report_param, NULL, NULL, NULL)
			
			IF @sql_report = 'y' 
			BEGIN
				IF ISNULL(@batch_index, 0) = 0
					RAISERROR ('Batch identifier(--[__batch_report__]) must be present in SQL to run report in batch mode.', -- Message text.
								   16, -- Severity.
								   1 -- State.
								   );
				
				IF ISNULL(@from_index, 0) = 0
					RAISERROR ('Query is malformed. A final SELECT statement must be present in SQL after batch identifier(--[__batch_report__]) to run report in batch mode.', -- Message text.
								   16, -- Severity.
								   1 -- State.
								   );
			END
		END
		
		EXEC spa_print 'Batch table name:', @str_batch_table
		IF ISNULL(@str_batch_table, '') <> ''
			SET @sql_stmt = SUBSTRING(@sql_stmt, 0, @from_index) + @str_batch_table + ' ' +  SUBSTRING(@sql_stmt, @from_index, LEN(@sql_stmt))
		
		SET @final_sql = @sql_stmt
				
		EXEC spa_print '****************************************Final Batch SQL Started****************************************:' 
			, @final_sql, '****************************************Final Batch SQL Ended******************************************:'
			
		--SELECT 1 AS error_code, 'Report Writer query builded successfully.' AS description 

	END TRY
	BEGIN CATCH
		--EXEC spa_print 'ERROR: ' + ERROR_MESSAGE()
		DECLARE @error_msg	VARCHAR(1000)
		SET @error_msg = 'Error building Report Writer SQL.' + ERROR_MESSAGE()
		
		--Raise error to let the SQL Agent job that this job failed. The failed job triggers another job which updates the 
		--message board error message.
		RAISERROR (@error_msg, -- Message text.
				   16, -- Severity.
				   1 -- State.
               );
		
	END CATCH

END
GO
