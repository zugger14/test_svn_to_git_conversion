/*
* sligal
* sp for storing dervied curve calculated value on table source_price_curve
* date: july 4, 2013
* purpose: To store the caculated derived curve value on table source_price_curve
* params:
	@flag			: operation flag('s' => selects data from table, 'q' => calculates value and saves its to physical table.)
	@curve_id		: derived curve id
    @curve_type		: derived curve type
    @as_of_date		: as of date
    @curve_source	: curve source
    @tenor_from		: maturity date from
    @tenor_to		: maturity date to
 	
*/

IF OBJECT_ID(N'[dbo].[spa_save_derived_curve_value]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_save_derived_curve_value]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_save_derived_curve_value]
	  @flag CHAR(1)
    , @curve_id VARCHAR(MAX)
    , @curve_type INT = NULL
    , @from_date DATETIME = NULL
    , @to_date DATETIME = NULL
    , @curve_source INT = NULL
    , @tenor_from DATETIME = NULL
    , @tenor_to DATETIME  = NULL
    --, @show_bid_ask CHAR(1) = 'n'
    , @batch_process_id VARCHAR(100) = NULL
    , @batch_report_param VARCHAR(1000)  = NULL
    , @enable_paging INT = 0  --'1' = enable, '0' = disable
	, @page_size INT = NULL
	, @page_no INT = NULL
    
AS
 
DECLARE @SQL VARCHAR(MAX), @pivot_col_list VARCHAR(500), @pivot_col_heading VARCHAR(5000)

/*******************************************1st Paging Batch START**********************************************/

DECLARE	@str_batch_table VARCHAR (8000)
		, @cursor_curve_ids VARCHAR(10)
		, @user_login_id VARCHAR (50)
		, @sql_paging VARCHAR (8000)
		, @is_batch BIT
		
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

IF @enable_paging = 1 --paging processing
BEGIN
	IF @batch_process_id IS NULL
	SET @batch_process_id = dbo.FNAGetNewID ()
	SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no)
	
--retrieve data from paging table instead of main table
	IF @page_no IS NOT NULL 
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no) 
		EXEC spa_print @sql_paging
		EXEC (@sql_paging)		 
	END
END 
/*******************************************1st Paging Batch END**********************************************/

BEGIN TRY
	IF @flag = 'c' --calculate and save derived curve value
	BEGIN
		/*CSV data supported in spa_maintain_price_curve. Using cursor to pass individual curve id was creating issue of multiple emails being sent*/
		EXEC spa_maintain_price_curve 
				  @curve_id = @curve_id
				, @curve_source = @curve_source
				, @from_date = @from_date
				, @to_date = @to_date
				, @tenor_from = @tenor_from
				, @tenor_to = @tenor_to
				, @flag = 'q'
				, @curve_type = @curve_type
				, @get_derive_value = 'y'
				, @batch_process_id = @batch_process_id

		EXEC spa_ErrorHandler 0
			, 'save_derived_curve_value'
			, 'spa_save_derived_curve_value'
			, 'Success'
			, 'Derived Curve Calculation has been completed.'
			, ''
	END
	
	/*******************************************2nd Paging Batch START**********************************************/
	 
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
	   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	   EXEC(@sql_paging)
	 
	   --TODO: modify sp and report name
	   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_save_derived_curve_value', 'Derived Curve')
	   --EXEC(@sql_paging)  
	 
	   RETURN
	END
	 
	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
	   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	   EXEC(@sql_paging)
	END
	 
	/*******************************************2nd Paging Batch END**********************************************/ 

END TRY
BEGIN CATCH
	--EXEC spa_print 'Catch Error spa_save_derived_curve_value: '-- + ERROR_MESSAGE() + '::' + CAST(ERROR_LINE() AS VARCHAR)
	EXEC spa_ErrorHandler -1
			, 'save_derived_curve_value'
			, 'spa_save_derived_curve_value'
			, 'Technical Error'
			, 'Derived Curve Calculation failed.'
			, ''
END CATCH