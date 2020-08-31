IF OBJECT_ID(N'[dbo].[spa_get_import_process_status_detail]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_import_process_status_detail]
GO 

/**
	Stored procedure for import drilldown.

	Parameters
	@process_id: Process id
	@source: Source
	@type_error: Type Error
	@import_from: Import From
	@batch_process_id: Batch process ID

	@batch_report_param: Batch report parameters 
	@enable_paging: Enable paging flag
					'1' = enable, 
					'0' = disable 
	@page_size: Page size
	@page_no: Page Number
*/

CREATE PROCEDURE [dbo].[spa_get_import_process_status_detail]
	@process_id NVARCHAR(50)
	, @source NVARCHAR(50) = NULL
	, @type_error NVARCHAR(500) = NULL
	, @import_from NVARCHAR(500) = NULL
	, @batch_process_id NVARCHAR(250) = NULL 

	, @batch_report_param NVARCHAR(500) = NULL  
	, @enable_paging INT = 0  -- '1' = enable, '0' = disable 
	, @page_size INT = NULL
	, @page_no INT = NULL 
AS

SET ANSI_NULLS ON 
SET ANSI_WARNINGS ON
SET NOCOUNT ON

/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table NVARCHAR(MAX)
DECLARE @user_login_id NVARCHAR(50)
DECLARE @sql_paging NVARCHAR(MAX)
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

DECLARE @sql NVARCHAR(MAX)

IF @source = 'Schedule_log' --designed for zainet
BEGIN
	DECLARE @dt1 NVARCHAR(10)
	DECLARE @dt2 NVARCHAR(10)
	DECLARE @dt DATETIME
	DECLARE @link_server_name NVARCHAR(50)
    
	SET @link_server_name = 'zainet'
    
	SELECT @dt = MAX(create_ts)
	FROM source_system_data_import_status_detail
	WHERE process_id = @process_id
		AND source = @source

	SET @dt1 = CAST(DATEPART(yy, @dt) AS NVARCHAR) + '-' + CAST(MONTH(@dt) AS NVARCHAR) + '-' + CAST(DATEPART(d, @dt) AS NVARCHAR)
	SET @dt = CAST(CAST(@dt AS INT) -3 AS DATETIME)
	SET @dt2 = CAST(DATEPART(yy, @dt) AS NVARCHAR) + '-' + CAST(MONTH(@dt) AS NVARCHAR)+ '-' + CAST(DATEPART(d, @dt) AS NVARCHAR)
    
	EXEC spa_print '
		SELECT * FROM OPENQUERY(
			', @link_server_name, '
			,''
				SELECT * 
				FROM zainet.zfastracker_log 
				WHERE C2_STARTDATE between to_date(''''', @dt2, ''''',''''yyyy-mm-dd'''')
					AND to_date(''''', @dt1, ''''',''''yyyy-mm-dd'''') 
				ORDER BY c2_startdate, c3_start
			''
		)
	'
	
	SET @sql = CAST('' AS NVARCHAR(MAX)) + 
		'
		SELECT * ' + @str_batch_table + ' FROM OPENQUERY(
			' + @link_server_name + '
			,''
				SELECT * 
				FROM zainet.zfastracker_log 
				WHERE C2_STARTDATE BETWEEN to_date(''''' + @dt2 + ''''',''''yyyy-mm-dd'''')
					AND to_date(''''' + @dt1 + ''''',''''yyyy-mm-dd'''')
				ORDER BY c2_startdate, c3_start
			''
		)
	'
	
	EXEC(@sql)

	RETURN
END

ELSE IF @source = 'Non-Existing Deal List'
BEGIN
	DECLARE	@process_table NVARCHAR(MAX)
		
	SET @process_table = dbo.FNAProcessTableName('ixp_rec_inventory', 'missing_deals', @process_id)
    
	IF OBJECT_ID (@process_table, N'U') IS NOT NULL 
		SET @sql = 'SELECT * ' + @str_batch_table + '  FROM ' + @process_table

	EXEC(@sql)

	IF @enable_paging = 0
		RETURN
END

ELSE
BEGIN
	
	IF OBJECT_ID('tempdb..#final_table') IS NOT NULL
		DROP TABLE #final_table

	CREATE TABLE #final_table(
		[status] NVARCHAR(500) COLLATE DATABASE_DEFAULT,
		[source] NVARCHAR(500) COLLATE DATABASE_DEFAULT,
		[type]	NVARCHAR(500)  COLLATE DATABASE_DEFAULT,
		[Description] NVARCHAR(500) COLLATE DATABASE_DEFAULT,
		[Created Time] NVARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	SET @sql = CAST('' AS NVARCHAR(MAX)) +  '
		INSERT INTO #final_table ([status], [source], [type], [Description]' + 
			CASE @source 
				WHEN 'EDI File' THEN ', [Created Time]'
				ELSE '' 
			END + ')
		SELECT DISTINCT 
			ssd.type_error [Status], 
			COALESCE(adi.attachment_file_name, REPLACE(RIGHT(ssd.import_file_name,  CHARINDEX(''\'', REVERSE(ssd.import_file_name), 1)), ''\'', ''''), ssd.source) AS [Source],
			ssd.type AS [Type],
			ssd.[description] AS [Description]' + 
			CASE @source 
				WHEN 'EDI File' THEN ', ssd.create_ts [Created Time]'
				ELSE '' 
			END + '
		FROM source_system_data_import_status_detail ssd
		LEFT JOIN attachment_detail_info adi 
			ON ISNULL(REPLACE(RIGHT(ssd.import_file_name, CHARINDEX(''\'', REVERSE(ssd.import_file_name), 1)), ''\'', ''''), -1) = ISNULL(REPLACE(RIGHT(adi.attachment_file_path,  CHARINDEX(''/'', REVERSE(adi.attachment_file_path), 1)), ''/'', ''''), -1)
		WHERE ssd.process_id=''' + @process_id + ''''
    
	--@type_error can contain descriptive messages having single quotes (') as well, which needs to be escaped
	SET @type_error = REPLACE(@type_error, '''', '''''')
	
	IF @type_error IS NOT NULL
		SET @sql = @sql + ' AND ssd.type_error=''' + @type_error + ''''
    
	IF @source IS NOT NULL
		SET @sql = @sql + ' AND ssd.source=''' + @source + ''''
    
	IF @import_from IS NOT NULL
		SET @sql = @sql + ' AND ssd.[type]=''' + @import_from + ''''
    
	SET @sql = @sql + '
		UNION ALL 
		SELECT [type] [status], source, type
		, ''Data mismatch for '' + 
		CASE 
			WHEN book.source_book_desc IS NULL THEN '''' 
			ELSE '', Book:'' + book.source_book_desc 
		END +
		CASE 
			WHEN com.commodity_desc IS NULL THEN '''' 
			ELSE ''   Commodity:'' + com.commodity_desc 
		END +
		'' ('' +
		CAST(vol.volumn_from AS NVARCHAR) + '' data imported Successfully out of '' + CAST(vol.volumn_to AS NVARCHAR) + '') [No. of Records:'' + CAST(vol.no_recs AS NVARCHAR) + ''].''' + 
		CASE @source 
			WHEN 'EDI File' THEN ', vol.create_ts [Created Time]' 
			ELSE '' 
		END + '
		FROM source_system_data_import_status_vol_detail vol
		LEFT JOIN source_book book 
			ON vol.book_id = book.source_book_id
		LEFT JOIN source_commodity com 
			ON vol.commodity = com.source_commodity_id
		WHERE process_id = ''' + @process_id + ''''
    
	IF @source IS NOT NULL
		SET @sql = @sql + ' AND vol.source=''' + @source + ''''
    
	-- exec spa_print @sql
	IF @import_from IS NOT NULL
		SET @sql = @sql + ' AND [type]=''' + @import_from + ''''

	IF ISNULL(@source, '') = 'EDI File'
		SET @sql = @sql + ' ORDER BY [Created Time] ASC'

	--SELECT @sql
	EXEC(@sql)

	EXEC ('
		SELECT [status]
			, [source]
			, [type]
			, [Description]
			, [Created Time]
			' + @str_batch_table + '
		FROM #final_table
	')
END

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_get_import_process_status_detail', 'spa_get_import_process_status_detail')
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
 
GO