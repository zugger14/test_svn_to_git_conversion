
IF OBJECT_ID(N'[dbo].[spa_run_purge_process]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_run_purge_process]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: padhikari@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: CRUD operations for table time_zone
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_run_purge_process]
	@date_from DATETIME,
	@date_to DATETIME,
	@purge_type CHAR(1),
	@sub_book VARCHAR(100) = NULL,

	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS
 /*
DECLARE @date_from DATETIME = '2010-1-1'
DECLARE @date_to DATETIME  = '2016-1-1'
DECLARE @purge_type CHAR(1) = 'a'
DECLARE @sub_book VARCHAR(100) = NULL
-- */

/*******************************************1st Paging Batch START**********************************************/
DECLARE @sql VARCHAR(1000)
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT
 
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

BEGIN

	IF OBJECT_ID('tempdb..#temp_sub_book') IS NOT NULL
		DROP TABLE #temp_sub_book
	
	CREATE TABLE #temp_sub_book([type] CHAR(1) COLLATE DATABASE_DEFAULT,sub_book INT)
	INSERT INTO #temp_sub_book([type],sub_book)
	select 'a' as [Type], CAST(clm2_value AS INT) FROM generic_mapping_header gmh 
	INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
	WHERE mapping_name = 'Nomination Mapping' AND (@purge_type = 'a' OR @purge_type = 'b')
	UNION ALL
	select 'o' as [Type], CAST(clm2_value AS INT) FROM generic_mapping_header gmh 
	INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
	WHERE mapping_name IN('Flow Optimization Mapping') AND (@purge_type = 'o' OR @purge_type = 'b')
	UNION ALL
	select 'o' as [Type], CAST(clm4_value AS INT) FROM generic_mapping_header gmh 
	INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
	WHERE mapping_name IN('Storage Book Mapping') AND (@purge_type = 'o' OR @purge_type = 'b')


	IF OBJECT_ID(N'tempdb..#tmp_deals') IS NOT NULL
		DROP TABLE #tmp_deals

	CREATE TABLE #tmp_deals (row_id INT, source_deal_header_id INT NULL)

	INSERT INTO #tmp_deals (row_id, source_deal_header_id)
	SELECT  ROW_NUMBER() OVER(ORDER BY sdh.source_deal_header_id), sdh.source_deal_header_id 
	FROM source_deal_header sdh 
	INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		AND sdh.entire_term_start BETWEEN @date_from AND @date_to
	INNER JOIN #temp_sub_book scsv ON scsv.sub_book = ssbm.book_deal_type_map_id

	IF EXISTS(SELECT TOP 1 1 FROM #tmp_deals)
	BEGIN
		DECLARE @process_id VARCHAR(200)

		SET @user_login_id = dbo.FNADBUser()
		SET @process_id = dbo.FNAGetNewID()

		DECLARE @delete_deals_table VARCHAR(100)
		SET @delete_deals_table = dbo.FNAProcessTableName('delete_deals', @user_login_id, @process_id)

		EXEC('CREATE TABLE ' + @delete_deals_table + '(source_deal_header_id INT, status VARCHAR(20), description VARCHAR(500))')
		EXEC('INSERT INTO ' + @delete_deals_table +  ' (source_deal_header_id) SELECT source_deal_header_id FROM #tmp_deals')

		EXEC spa_sourcedealheader 'd', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @process_id, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'y' 
	END

	IF OBJECT_ID('tempdb..#tmp_result') IS NOT NULL
		DROP TABLE #tmp_result
	
	CREATE TABLE #tmp_result ([status] VARCHAR(500) COLLATE DATABASE_DEFAULT, date_from DATETIME, date_to DATETIME, purge_type VARCHAR(50) COLLATE DATABASE_DEFAULT)

	INSERT INTO #tmp_result([status], date_from, date_to, purge_type)
	SELECT 
	'Purge Process Completed' [Status], 
	dbo.FNADateFormat(@date_from) date_from,
	dbo.FNADateFormat(@date_to) date_to,
	@purge_type [purge_type]

	SET @sql = 'SELECT [status] [Status]
				, dbo.FNADateFormat(date_from) [Date From]
				, dbo.FNADateFormat(date_to) [Date To]
				, purge_type [Purge Type]
				'  + @str_batch_table + '
				FROM #tmp_result'

	EXEC(@sql)

	DECLARE @desc VARCHAR(MAX)
	DECLARE @job_name VARCHAR(200)
	--Update message board
	SET @desc = 'Calculation of ''''Run Purge Process'''' has been completed.'
	SET @job_name = 'batch_' + @batch_process_id


	EXEC spa_message_board 'u', @user_login_id, NULL, 'Run Purge Process', @desc, '', '', 'c', @job_name, NULL, @batch_process_id
 
END

