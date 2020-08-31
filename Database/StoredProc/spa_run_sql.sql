/****** Object:  StoredProcedure [dbo].[spa_run_sql]    Script Date: 07/28/2009 09:43:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_sql]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_run_sql]
GO

/****** Object:  StoredProcedure [dbo].[spa_run_sql]    Script Date: 07/27/2009 15:04:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC spa_run_sql 2,'content_type=abc AND internal_type_value_id=21,abc=22'
-- EXEC spa_run_sql  7,'as_of_date=2007-12-28',NULL,'884934E5_ttD498_4961_B6CB_aaB57966A212EKZ',' spa_run_sql  7,''as_of_date=2007-12-28'',NULL'
-- EXEC spa_run_sql 16, 'as_of_date=2004-12-31,discount_option=u,netting_parent_group_id=1,book_id=3530_3529,strategy_id=3520,subsidiary_id=3516'
-- EXEC spa_run_sql  18,'book_id =345,stra_id=24'
CREATE PROCEDURE [dbo].[spa_run_sql]
	@report_id int,
	@criteria varchar(5000) = NULL,
	@temp_table_name varchar(100) = NULL,
	@batch_process_id varchar(50) = NULL,	
	@batch_report_param varchar(1000) = NULL
AS
-----------------------test criteria
--EXEC spa_run_sql 33,'as_of_date=2004-12-31,discount_option=''u'',netting_parent_group_id=1'
--DECLARE @report_id int
--DECLARE @criteria varchar(5000)
--DECLARE @temp_table_name varchar(100)
--DECLARE @batch_process_id varchar(50)
--DECLARE @batch_report_param varchar(1000)
--
--SET @report_id =33 -- 7
--SET @criteria = 'as_of_date=2005-12-31,discount_option=''u'',netting_parent_group_id=6,gl_account_number=1233'
--SET @temp_table_name = NULL
--SET @batch_process_id = NULL
--SET @batch_report_param = NULL
--
--SELECT * FROM Report_record where report_id=@report_id
--SELECT vw_sql FROM report_writer_table where table_name = 'Anoop'

-----------------------END of test criteria


/*
DECLARE @sql_stmt			varchar(MAX)
DECLARE @report_where		varchar(5000)
DECLARE @table_name			varchar(200)
DECLARE @as_of_date			varchar(20)
DECLARE @sql_report			varchar(1)
DECLARE @process_id			varchar(100)
DECLARE @batch_identifier	varchar(100)
DECLARE @view_identifier	varchar(100)

SET @batch_identifier = '--[__batch_report__]'
SET @view_identifier = '[view_table_detail]'

SET @process_id = REPLACE(NEWID(), '-', '_')
	
BEGIN TRY
	
	SELECT @sql_stmt = report_sql_statement, @table_name = report_tablename, @sql_report = report_sql_check 
	FROM Report_record 
	WHERE report_id = @report_id 

	IF @sql_report IS NULL 
		SET @sql_report = 'n'

	----------------------------------------Replace View name with View SQL or temp table name Started--------------------------------
	IF @sql_report = 'n'
	BEGIN
		DECLARE @vw_Sql		varchar(MAX)		
		SELECT @vw_Sql = vw_sql FROM report_writer_table WHERE table_name = @table_name

		IF @vw_Sql IS NOT NULL
		BEGIN
			--if view is a multiline statement, execute it to save result in temp table
			--and replace view identifier with that table name
			IF CHARINDEX(@view_identifier, @vw_Sql) > 1 
			BEGIN
				DECLARE @vw_batch_table varchar(5000)
				SET @vw_batch_table = dbo.FNAProcessTableName('view_report', dbo.FNADBUser(), @process_id)
				--PRINT 'vw_batch_table: ' + @vw_batch_table
				
				--Replace Params in View definition if it is multiline statement
				--otherwise it will be done later after replacing view name with view definition
				SET @vw_Sql = dbo.FNAReplaceRWParams(@vw_Sql, @criteria)
				--set @vw_Sql = REPLACE(@vw_Sql, '''''', '''')
				--PRINT 'After View Replaced: ' + @vw_Sql
			
				SET @vw_Sql = REPLACE(@vw_Sql, @view_identifier, ' INTO ' + @vw_batch_table + ' ')				
				
				--Since archived tables can contains double quotation ("), set QUOTED_IDENTIFIER OFF to make it executable
				SET @vw_Sql = 'SET QUOTED_IDENTIFIER OFF;' + CHAR(10) + @vw_Sql
				
				EXEC spa_print '****************************************View SQL Started****************************************:' 
				+ CHAR(10) + @vw_Sql + CHAR(10)
				+ '****************************************View SQL Ended****************************************:'
				
				EXEC(@vw_Sql)
				SET @sql_stmt = REPLACE(@sql_stmt, @table_name, ' ' + @vw_batch_table + ' ')
				--SET @sql_stmt = REPLACE(@sql_stmt, '''''', '''')
			END			
			ELSE
			BEGIN
				SET @sql_stmt = REPLACE(@sql_stmt, @table_name, ' (' + @vw_Sql + ') vw ')			
			END
		END	
		ELSE	
		BEGIN
			SELECT 'No report definition found to run! Please contact technical support.' Error	
			RETURN
		END
	END
	----------------------------------------Replace View name with View SQL Completed--------------------------------
	
	--Replace variables in SQL Started
	SET @sql_stmt = dbo.FNAReplaceRWParams(@sql_stmt, @criteria)
	--Since archived tables can contains double quotation ("), set QUOTED_IDENTIFIER OFF to make it executable
	SET @sql_stmt = 'SET QUOTED_IDENTIFIER OFF;' + CHAR(10) + @sql_stmt

	--SET @sql_stmt = REPLACE(@sql_stmt, '''''', '''')

	EXEC spa_print '****************************************Final SQL Started****************************************:' 
		+ CHAR(10) + @sql_Stmt + CHAR(10)
		+ '****************************************Final SQL Ended****************************************:'
		

	DECLARE @from_index int
	SET @from_index = CHARINDEX(' FROM ', @sql_stmt, 0)

	DECLARE @str_batch_table varchar(max)
	SET @str_batch_table = ''

	IF  @batch_process_id IS NULL 
	BEGIN
		--PRINT @sql_stmt
		IF @temp_table_name IS NOT NULL
			SET @sql_stmt = SUBSTRING(@sql_stmt, 0, @from_index) + ' INTO ' + @temp_table_name + ' ' + SUBSTRING(@sql_stmt, @from_index, LEN(@sql_stmt))

		EXEC(@sql_stmt)
	END
	ELSE
	BEGIN
		SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id, @batch_report_param, NULL, NULL, NULL)  
		IF @sql_report = 'y' 
		BEGIN
			DECLARE @batch_index int
			SET @batch_index = CHARINDEX(@batch_identifier, @sql_stmt)
			EXEC spa_print 'batch_index: ' + CAST(@batch_index AS varchar)
			
			IF @batch_index = 0
				RAISERROR ('Batch identifier(--[__batch_report__]) must be present in SQL to run report in batch mode.', -- Message text.
							   16, -- Severity.
							   1 -- State.
							   );
			
			SET @from_index = dbo.FNACharIndexMatchWholeWord('FROM', @sql_stmt , @batch_index)
				
			EXEC spa_print 'from_index: ' + CAST(@from_index AS varchar)
			IF @from_index = 0
				RAISERROR ('Query is malformed. A final SELECT statement must be present in SQL after batch identifier(--[__batch_report__]) to run report in batch mode.', -- Message text.
							   16, -- Severity.
							   1 -- State.
							   );
		END
		
		SET @sql_stmt = SUBSTRING(@sql_stmt, 0, @from_index) + @str_batch_table + ' ' +  SUBSTRING(@sql_stmt, @from_index, LEN(@sql_stmt))
		
		EXEC spa_print 'batch: ' + @sql_stmt 
		
		EXEC(@sql_stmt)

		--For final batch message to Message Board
		--*****************FOR BATCH PROCESSING**********************************            
		SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)         
		EXEC(@str_batch_table)        
		DECLARE @report_name varchar(100)

		SET @report_name='Run Report Writer'        
		   
		SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_run_sql', @report_name)         
		EXEC(@str_batch_table)        
	END

END TRY
BEGIN CATCH
	EXEC spa_print 'ERROR: ' + ERROR_MESSAGE()
	
	--Raise error to let the SQL Agent job that this job failed. The failed job triggers another job which updates the 
	--message board error message.
	RAISERROR ('Error executing SQL.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END CATCH

*/

DECLARE @sql nvarchar(MAX)
DECLARE @str_batch_table varchar(max)

BEGIN TRY
	
	IF NOT EXISTS(SELECT 1 FROM Report_record WHERE report_id = @report_id)	
	BEGIN
		SELECT 'No report definition found to run! Please contact technical support.' Error	
		RETURN
	END
	
	EXEC spa_build_rw_query @report_id, @criteria, @temp_table_name, @batch_process_id, @batch_report_param, NULL, NULL, @sql OUTPUT 
	
	--Since archived tables can contains double quotation ("), set QUOTED_IDENTIFIER OFF to make it executable
	SET @sql = 'SET QUOTED_IDENTIFIER OFF;' + CHAR(10) + @sql
	
	EXEC(@sql)
	
	IF @batch_process_id IS NOT NULL
	BEGIN
		--*****************FOR BATCH PROCESSING**********************************            
		SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)         
		EXEC(@str_batch_table)        
		DECLARE @report_name varchar(100)
		DECLARE @actual_report_name VARCHAR(100)
		
		SELECT @actual_report_name = rr.report_name
		FROM   Report_record rr
		WHERE  rr.report_id = @report_id
		
		SET @report_name='Report Writer - ' + ' ' + @actual_report_name        
		   
		SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_run_sql', @report_name)         
		EXEC(@str_batch_table)   
	END
END TRY
BEGIN CATCH
--	EXEC spa_print 'ERROR: ' , ERROR_MESSAGE()
	
	--Raise error to let the SQL Agent job that this job failed. The failed job triggers another job which updates the 
	--message board error message.
	RAISERROR ('Error executing SQL.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END CATCH