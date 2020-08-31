IF OBJECT_ID(N'[dbo].[spa_convert_xml]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_convert_xml]
GO

CREATE PROCEDURE [dbo].[spa_convert_xml]
	@sub_id VARCHAR(1000) = NULL,
	@stra_id VARCHAR(1000) = NULL,
	@book_id VARCHAR(1000) = NULL,
	@sub_book_id VARCHAR(1000) = NULL,
	@Delivery_Start_Date VARCHAR(100) = NULL,
	@Delivery_End_Date VARCHAR(100) = NULL,
	@process_id VARCHAR(1000) = NULL,
	@report_type INT = NULL,
	@mirror_reporting BIT = NULL,
	@intragroup BIT = NULL,
	@as_of_date DATETIME = NULL,
	@generate_uti BIT = 0,
	@batch_process_id VARCHAR(50)=NULL,
	@batch_report_param VARCHAR(1000)=NULL,
	@enable_paging INT = 0,
	@page_size INT = NULL,
	@page_no INT = NULL,
	@call_from_export BIT = NULL,
	@xml_out VARCHAR(MAX) = NULL OUTPUT
AS
/*----------------Debug Section---------------
DECLARE @sub_id VARCHAR(1000) = NULL,
		@stra_id VARCHAR(1000) = NULL,
		@book_id VARCHAR(1000) = NULL,
		@sub_book_id VARCHAR(1000) = NULL,
		@Delivery_Start_Date VARCHAR(100) = NULL,
		@Delivery_End_Date VARCHAR(100) = NULL,
		@process_id VARCHAR(1000) = null,
		@report_type INT = 39401,
		@mirror_reporting BIT = NULL,
		@intragroup BIT = NULL,
		@as_of_date DATETIME = NULL,
		@generate_uti BIT = null,
		@batch_process_id VARCHAR(50)=NULL,
		@batch_report_param VARCHAR(1000)=NULL,
		@enable_paging INT = null,
		@page_size INT = NULL,
		@page_no INT = NULL,
		@call_from_export BIT = NULL,
		@xml_out VARCHAR(MAX) = NULL 

SELECT @process_id = '6a42c66a-70c8-4f77-84d1-b285fb49e0b3',
	   @report_type = null,
	   @mirror_reporting = null,
	   @intragroup = null,
	   @call_from_export = null
--------------------------------------------*/
SET NOCOUNT ON
DECLARE @str_batch_table VARCHAR(8000),
		@is_batch BIT,
		@sql_paging VARCHAR(8000),
		@user_login_id VARCHAR(50),
		@sql VARCHAR(MAX),
		@source XML,
		@batch_table_name VARCHAR(1000),
		@phy_remit_table_name VARCHAR(25),
		@report_code VARCHAR(100)

SELECT @report_code = code
FROM static_data_value
where value_id = @report_type
AND type_id = 39400

SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 

SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

IF @is_batch = 1
BEGIN
	SET @batch_table_name = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	IF OBJECT_ID(@batch_table_name) IS NOT NULL
			EXEC('DROP TABLE ' + @batch_table_name)
	SET @str_batch_table = ' INTO ' + @batch_table_name
END
	

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

EXEC spa_remit @Delivery_Start_Date, @Delivery_End_Date, 1,
			   @generate_uti, @report_type, @process_id, 'i', NULL, NULL, @source OUTPUT,
			   @mirror_reporting, @intragroup, @as_of_date

IF @call_from_export = 1
BEGIN
	SET @xml_out = CAST(@source AS VARCHAR(MAX))
	RETURN
END

IF @source IS NOT NULL
BEGIN
	IF OBJECT_ID('tempdb..#store_xml') IS NOT NULL
		DROP TABLE #store_xml

	CREATE TABLE #store_xml(
		[source] XML
	)

	INSERT INTO #store_xml([source])
	SELECT @source

	SET @sql = 'SELECT  ''<?xml version="1.0" encoding="UTF-8"?>'' + CAST(source AS VARCHAR(MAX)) as source ' + @str_batch_table +   ' from #store_xml'
	EXEC(@sql)
END
ELSE
BEGIN
	EXEC spa_message_board 'u', @user_login_id, NULL, 'Export XML', 'There are some errors in this report. Please check in excel details.', NULL, NULL, 's', 'ECM Xml Export', NULL, @batch_process_id
	RETURN			
END
/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, @as_of_date, NULL, NULL)   
	EXEC(@str_batch_table)                   
	
	DECLARE @msg VARCHAR(100)
	SET @msg = IIF(@report_type IS NOT NULL, 'Remit ' + @report_code + ' Report', 'ECM XML Report')

	SELECT @str_batch_table = dbo.FNABatchProcess('x', @batch_process_id, @batch_report_param, @as_of_date, 'spa_convert_xml', @msg)   
	EXEC (@str_batch_table)     
	RETURN
END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/
GO