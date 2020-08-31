IF OBJECT_ID(N'[dbo].[spa_get_mtm_test_run_log]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_mtm_test_run_log]
GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Retrieve process status and log in the system

	Parameters : 
	@process_id : Process Id filter
	@drill_level : Drill Level
	@tbl_name : Input process table name
	@user_login_id : Runner User Login Id
	@batch_report_param: Batch report parameters 
	@enable_paging: Enable paging flag
					'1' = enable, 
					'0' = disable 
	@page_size: Page size
	@page_no: Page Number

  */

CREATE PROCEDURE [dbo].[spa_get_mtm_test_run_log]
	 @process_id varchar(50)
   , @drill_level int=0
   , @tbl_name varchar(250)=null
   , @user_login_id varchar(30)=null
   , @batch_process_id VARCHAR(250) = NULL
   , @batch_report_param VARCHAR(500) = NULL  
   , @enable_paging INT = 0  -- '1' = enable, '0' = disable 
   , @page_size INT = NULL
   , @page_no INT = NULL 
AS


DECLARE  @st VARCHAR(MAX)
        ,@user_login_id1 VARCHAR(50)
SET @user_login_id1=dbo.fnadbuser()

SET NOCOUNT ON
/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT

SET @str_batch_table = '' 

SET @user_login_id = dbo.FNADBUser()  

SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
   
IF @enable_paging = 1 -- paging processing 
BEGIN 
	IF @batch_process_id IS NULL 
		SET @batch_process_id = dbo.FNAGetNewID()

	SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no) 

	-- retrieve data from paging table instead of main table 
	IF @page_no IS NOT NULL  
	BEGIN 
		SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)  
		EXEC (@sql_paging)  
		RETURN  
	END 
END
/*******************************************1st Paging Batch END**********************************************/ 

IF ISNULL(@drill_level,0) IN (0,1)
BEGIN
	SELECT  CASE WHEN (code = 'Error') THEN '<font color="red"><b>' + code +'</b></font>'
				ELSE code
			END AS Code, [module] AS Module, [source] AS Source
		    , [type] AS [Type]
		    , CASE WHEN @drill_level=1 and code = 'Error' THEN 
				'<a target="_blank" href="./spa_html.php?__user_name__='
				+ @user_login_id1+'&spa=exec spa_get_mtm_test_run_log ''' + @process_id + ''',2,'''+[source]
				+''','''+create_user+'''">'+[description]+'</a>'
			  ELSE 
				[description] 
			  END AS [Description]
			, nextsteps AS [Next Steps]
			, process_id AS [Process ID]
	INTO #temp_mtm_test_run_log
	FROM mtm_test_run_log
	WHERE process_id = @process_id
	--GROUP BY code,module,source,type,description,nextsteps,process_id
	--ORDER bY mtm_test_run_log_id

	EXEC('SELECT * ' + @str_batch_table + ' FROM #temp_mtm_test_run_log')

END	
ELSE IF ISNULL(@drill_level,0)=2
BEGIN
	
	SELECT @user_login_id = MAX(create_user) 
	FROM mtm_test_run_log 
	WHERE process_id = @process_id
	SET @st='SELECT * ' + @str_batch_table + ' FROM '+ dbo.FNAProcessTableName(@tbl_name, @user_login_id, @process_id)
	EXEC(@st)
END

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_get_mtm_test_run_log', 'spa_get_mtm_test_run_log')
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