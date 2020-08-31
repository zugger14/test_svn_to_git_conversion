IF OBJECT_ID('spa_view_dedesignation_criteria') IS NOT NULL
DROP PROC dbo.spa_view_dedesignation_criteria
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: display dedesignation criteria detail

-- Params:
-- @flag CHAR(1) - Operation flag
-- @sub_id - subsidiary id
-- @str_id - strategy id
-- @book_id - book id
-- @as_of_date - as of date
-- @dedesignation_criteria_id - dedesignation criteria id

-- ===========================================================================================================	

CREATE PROC [dbo].spa_view_dedesignation_criteria	
 		@sub_id VARCHAR(1000) = NULL,
		@str_id VARCHAR(1000) = NULL,
		@book_id VARCHAR(1000) = NULL,
		@as_of_date DATETIME = NULL,
		@flag CHAR(1) = NULL,
		@dedesignation_criteria_id INT = NULL,
		@batch_process_id VARCHAR(250) = NULL,
		@batch_report_param VARCHAR(500) = NULL, 
		@enable_paging INT = 0,  --'1' = enable, '0' = disable
		@page_size INT = NULL,
		@page_no INT = NULL		
AS
DECLARE @sql VARCHAR(MAX)
IF @flag = 's'
BEGIN
	/*******************************************1st Paging Batch START**********************************************/
	DECLARE @str_batch_table VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @sql_paging VARCHAR(8000)
	DECLARE @is_batch bit


	SET @str_batch_table = ''
	SET @user_login_id = dbo.FNADBUser() 
	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 

	IF @is_batch = 1
	   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

	IF @enable_paging = 1 --paging processing
	BEGIN
	   IF @batch_process_id IS NULL
		  SET @batch_process_id = dbo.FNAGetNewID()

	   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

	   --retrieve data from paging table instead of main table
	   IF @page_no IS NOT NULL 
	   BEGIN
		  SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
		  EXEC (@sql_paging) 
		  RETURN 
	   END
	END

	/*******************************************1st Paging Batch END**********************************************/

	SET @sql = '
		SELECT	dedesignation_criteria_id AS [Dedesignation Criteria ID],
				fas_sub_id AS [Sub ID],
				fas_stra_id AS [Strategy ID],
				fas_book_id AS [Book ID],
				dbo.FNADateFormat(run_date) AS [Run Date],
				curve_id AS [Curve ID],
				dbo.FNADateFormat(term_start) AS [Term Start],
				dbo.FNADateFormat(term_end) AS [Term End],
				CASE WHEN term_match_criteria = ''p'' THEN ''Perfect'' ELSE ''Within'' END AS [Term Match Criteria],
				dbo.FNADateFormat(dedesignate_date) AS [Dedesignate Date],
				dedesignate_volume AS [Dedesignate Volume],
				uom_id AS [Uom ID],
				CASE WHEN dedesignate_frequency = ''m'' THEN ''Term'' ELSE ''Total'' END AS [Dedesignate Frequency],
				CASE WHEN sort_order = ''l'' THEN ''Lifo'' ELSE ''Fifo'' END AS [Sort Order],
				dedesignate_type AS [Dedesignate Type],
				CASE WHEN dedesignate_look_in = ''h'' THEN ''Hedge'' else ''Item'' END AS [Dedesignate Look In],
				CASE WHEN volume_split  = ''y'' THEN ''Yes'' else ''No'' END AS [Volume Split],
				create_user AS [Create User],
				create_ts  AS [Create TS]
		' + @str_batch_table + '
		FROM dedesignation_criteria dc left join 
		(
			select distinct dedesignation_criteria_id c_id from dedesignation_criteria_result where isnull(process_status,''n'')=''n'' 
		) dcr on dc.dedesignation_criteria_id=dcr.c_id
		WHERE  dcr.c_id is not null and fas_sub_id IN ( ' + @sub_id + ') AND dedesignate_date = ''' + CONVERT(VARCHAR(30), dbo.FNAStdDate(@as_of_date)) + ''''
			+ CASE WHEN @str_id IS NOT NULL THEN ' AND fas_stra_id IN ( ' + CAST(@str_id AS VARCHAR(50)) + ')' ELSE '' END
			+ CASE WHEN @book_id IS NOT NULL THEN ' AND fas_book_id IN ( ' + CAST(@book_id AS VARCHAR(50)) + ')' ELSE '' END + '
		'	
	EXEC spa_print @sql
	EXEC(@sql)
	
	/*******************************************2nd Paging Batch START**********************************************/
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
	   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	   EXEC(@sql_paging)

	   --TODO: modify sp and report name
	   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_view_dedesignation_criteria', 'De-Designation Criteria Report')
	   EXEC(@sql_paging)  

	   RETURN
	END

	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
	   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	   EXEC(@sql_paging)
	END
	/*******************************************2nd Paging Batch END**********************************************/
END
ELSE IF @flag = 'd'
BEGIN
	DELETE FROM dedesignation_criteria_result WHERE dedesignation_criteria_id = @dedesignation_criteria_id
	DELETE FROM dedesignation_criteria WHERE dedesignation_criteria_id  = @dedesignation_criteria_id
END