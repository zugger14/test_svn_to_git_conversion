IF OBJECT_ID(N'[dbo].[spa_get_alert_report_output]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_get_alert_report_output]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Displays Report while clicking hyperlink in Alert Window

	Parameters
	@alert_reports_id : Id of Alert Report 
	@alert_id : Id of Alert
	@process_table : Process table name for inserting data FROM Report process table 
	@source_id : Id of the source which may be message board, counterparty, deals
	@batch_process_id : Process Id for Batch and paging 
	@batch_report_param : Parameters for Batch 
	@enable_paging : Set value for paging '1' = enable, '0' = disable
	@page_size : Number of Rows per page
	@page_no : Page number	
*/
 
-- EXEC  spa_get_alert_report_output 2, 1
 -- select * from alert_reports
CREATE PROCEDURE [dbo].[spa_get_alert_report_output]
	@alert_reports_id INT,
	@alert_id INT,
	@process_table NVARCHAR(300) = NULL,
	@source_id NVARCHAR(200) = NULL,
	@batch_process_id NVARCHAR(250) = NULL,
	@batch_report_param NVARCHAR(500) = NULL,
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS
SET NOCOUNT ON 

--DECLARE
--	@alert_reports_id INT = 420,
--	@alert_id INT = 56635,
--	@process_table NVARCHAR(300) = NULL,
--	@source_id NVARCHAR(200) = NULL,
--	@batch_process_id NVARCHAR(250) = NULL,
--	@batch_report_param NVARCHAR(500) = NULL,
--	@enable_paging INT = 0,		--'1' = enable, '0' = disable
--	@page_size INT = NULL,
--	@page_no INT = NULL
-------------------------------- 1st batch and paging start------------------
DECLARE @str_batch_table NVARCHAR (MAX) 
DECLARE @user_login_id NVARCHAR (50) 
DECLARE @sql_paging NVARCHAR (MAX) 
DECLARE @is_batch BIT 
SET @str_batch_table = '' 
SET @user_login_id = dbo.FNADBUser()  
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 

DECLARE @table_name  NVARCHAR(500),
	    @process_id  NVARCHAR(150),
		@where_clause NVARCHAR(MAX),
		@report_writer NCHAR(1)
	
SELECT @process_id = process_id
FROM   alert_output_status
WHERE  alert_id = @alert_id
	
SELECT @table_name = 'adiha_process.dbo.' + table_prefix + @process_id + table_postfix,
		@where_clause = ISNULL(' WHERE ' + NULLIF(REPLACE(report_where_clause, '@_source_id', @source_id),''), ''),
		@report_writer = report_writer
FROM   alert_reports
WHERE  alert_reports_id = @alert_reports_id
	
IF @report_writer = 'a'
BEGIN
	SET @table_name = 'adiha_process.dbo.nested_alert_workflow_report_'+ @process_id +'_na'
	EXEC ('SELECT * FROM '  +  @table_name)
	RETURN
END

IF @is_batch = 1
BEGIN 
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id) 
END

IF @enable_paging = 1 --paging processing 
BEGIN 
	IF @batch_process_id IS NULL 
	BEGIN
 		SET @batch_process_id = dbo.FNAGetNewID()
	END
	SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no)	 
	--retrieve data from paging table instead of main table 
	IF @page_no IS NOT NULL  
	BEGIN 
		SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no)  
		EXEC (@sql_paging)  
		RETURN  
	END 
END
-------------------------------- 1st batch and paging end------------------
BEGIN
	IF @table_name IS NOT NULL
	BEGIN
		IF OBJECT_ID('tempdb..#result_alert_report_output') IS NOT NULL 
			DROP TABLE #result_alert_report_output
		CREATE TABLE #result_alert_report_output(dummy_column INT)

		DECLARE @total_columns INT
		DECLARE @query_str VARCHAR(500) =  'SELECT * FROM '+ @table_name
		
		EXEC spa_get_output_schema_or_data @sql_query = @query_str
		,@process_table_name = '#result_alert_report_output'
		,@data_output_col_count = @total_columns OUTPUT
		,@flag = 'schema'

		SELECT @col_list_str = COALESCE(@col_list_str + ', ' ,'') + IIF( ro.[DataTypeName] IN ('FLOAT','Numeric'), 'dbo.FNANumberFormat(['+ro.[ColumnName]+'],''n'') AS ['+ro.[ColumnName]+']', '['+ro.[ColumnName] +']') FROM #result_alert_report_output ro

		IF @process_table IS NOT NULL
		BEGIN
			EXEC ('SELECT ' + @col_list_str + ' INTO ' + @process_table + ' FROM ' + @table_name + @where_clause)
		END 
		ELSE 
		BEGIN
			EXEC ('SELECT ' + @col_list_str + ' ' + @str_batch_table + ' FROM '  +  @table_name + @where_clause)
		END
	END	    
	ELSE
	BEGIN
	    SELECT 'No Report Table Found' [Error]
	END
END

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board

IF @is_batch = 1
 
BEGIN
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 

	EXEC (@str_batch_table)

	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_get_alert_report_output', 'Alert Report') 

	EXEC (@str_batch_table)
 
	RETURN
 
END

IF @enable_paging = 1 AND @page_no IS NULL 
BEGIN 
	SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no) 
	EXEC (@sql_paging) 
END

/*******************************************2nd Paging Batch END**********************************************/
