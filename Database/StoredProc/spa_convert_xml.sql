IF OBJECT_ID(N'[dbo].[spa_convert_xml]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_convert_xml]
GO

/**
	Used to generated xml for regulatory reporting (remit,ecm)

	Parameters
	@sub_id				 : Subsidiay ID
	@stra_id			 : Strategy ID
	@book_id			 : Book ID
	@sub_book_id		 : Sub Book ID
	@Delivery_Start_Date : Delivery Start Date
	@Delivery_End_Date	 : Delivery End Date
	@process_id			 : Process ID
	@report_type		 : Report Type
	@mirror_reporting	 : 1 for enabling mirror reporting
	@intragroup			 : Intra Group
	@as_of_date			 : As of Date
	@generate_uti		 : 1 for generating UTI
	@batch_process_id	 : Batch Process ID
	@batch_report_param  : Batch Report Param
	@enable_paging		 : Enable Paging
	@page_size			 : Page Size
	@page_no			 : Page Number
	@call_from_export	 : Call from export
	@xml_out             : Generated xml
*/

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
	@xml_out VARCHAR(MAX) = NULL OUTPUT,
	@file_transfer_endpoint_name NVARCHAR(2000) = NULL
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
		@report_code VARCHAR(100),
		@file_transfer_endpoint_id INT,
		@remote_directory NVARCHAR(2000),
		@batch_notification_process_id NVARCHAR(40)

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

IF NULLIF(@file_transfer_endpoint_name,'') IS NULL AND @batch_process_id IS NOT NULL
BEGIN
	SET @batch_notification_process_id = RIGHT(@batch_process_id, 13)
	SELECT @file_transfer_endpoint_id = file_transfer_endpoint_id
		 , @remote_directory = ftp_folder_path
	FROM batch_process_notifications
	WHERE process_id = @batch_notification_process_id

	SELECT @remote_directory = COALESCE(@remote_directory,remote_directory)
	FROM file_transfer_endpoint
	WHERE file_transfer_endpoint_id = @file_transfer_endpoint_id
	
	UPDATE batch_process_notifications
		SET file_transfer_endpoint_id = NULL
		   ,ftp_folder_path = NULL
	WHERE process_id = @batch_notification_process_id
END
ELSE
BEGIN
	SELECT @file_transfer_endpoint_id = file_transfer_endpoint_id
	      ,@remote_directory = remote_directory
	FROM file_transfer_endpoint
	WHERE [name] = @file_transfer_endpoint_name	
END

EXEC spa_remit @create_date_from = @Delivery_Start_Date
			  , @create_date_to = @Delivery_End_Date
			  , @generate_xml =  1
			  , @generate_uti =  @generate_uti
			  , @report_type = @report_type
			  , @process_id = @process_id
			  , @flag = 'i'
			  , @batch_unique_id = NULL
			  , @cancellation = NULL
			  , @source = @source OUTPUT
			  , @mirror_reporting = @mirror_reporting
			  , @intragroup = @intragroup
			  , @as_of_date = @as_of_date
			  , @file_transfer_endpoint_id = @file_transfer_endpoint_id
			  , @remote_directory = @remote_directory

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

	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, @as_of_date, 'spa_convert_xml', @msg)   
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