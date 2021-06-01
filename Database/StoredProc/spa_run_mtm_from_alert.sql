
IF OBJECT_ID(N'[dbo].[spa_run_mtm_from_alert]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_run_mtm_from_alert]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2014-01-23
-- Description: Run seperate MTM calculation for deals with different deal_date .
 
-- Params:
-- @process_table VARCHAR(500)        - process table which expects one column to be source_deal_header_id
-- ===============================================================================================================
CREATE  PROCEDURE [dbo].[spa_run_mtm_from_alert]
    @process_table VARCHAR(500),
    @calc_type CHAR(1) = NULL
AS 

/* testing
DECLARE @process_table VARCHAR(500)
SET @process_table = 'adiha_process.dbo.deals'
CREATE TABLE adiha_process.dbo.deals(source_deal_header_id INT)

INSERT INTO adiha_process.dbo.deals
SELECT TOP(10) sdh.source_deal_header_id FROM source_deal_header sdh
 EXEC spa_run_mtm_from_alert 'adiha_process.dbo.deals', 's'
*/
IF @calc_type IS NULL 
	SET @calc_type = 'm'

IF OBJECT_ID('tempdb..#temp_grouped_deals') IS NOT NULL
	DROP TABLE #temp_grouped_deals
	
CREATE TABLE #temp_grouped_deals (source_deal_header_ids VARCHAR(MAX) COLLATE DATABASE_DEFAULT, as_of_date DATETIME)
CREATE TABLE #temp_deals_settlement (source_deal_header_ids NVARCHAR(MAX) COLLATE DATABASE_DEFAULT, as_of_date DATETIME, term_start DATETIME, term_end DATETIME)

DECLARE @sql NVARCHAR(4000)

DECLARE @source_deal_header_id VARCHAR(5000)
DECLARE @as_of_date VARCHAR(10)
DECLARE @curve_as_of_date VARCHAR(10)
DECLARE @term_start VARCHAR(20)
DECLARE @term_end VARCHAR(20)
DECLARE @counterparty_ids VARCHAR(MAX)
DECLARE @user_name VARCHAR(50)
SET @user_name = dbo.FNADBUser()

IF @calc_type = 'm'
BEGIN
	SET @sql = 'INSERT INTO #temp_grouped_deals (source_deal_header_ids, as_of_date)
			SELECT  ' + CHAR(10)
         + 'STUFF(( ' + CHAR(10)
         + '    SELECT '','' + CAST(a.source_deal_header_id AS VARCHAR(MAX))  ' + CHAR(10)
         + '    FROM ' + @process_table + ' a ' + CHAR(10)
         + '    INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = a.source_deal_header_id ' + CHAR(10)
         + '    WHERE sdh.deal_date = sdh1.deal_date  ' + CHAR(10)
         + '	GROUP BY a.source_deal_header_id  ' + CHAR(10)
         + '    FOR XML PATH(''''),TYPE).value(''(./text())[1]'',''VARCHAR(MAX)'') ' + CHAR(10)
         + '  ,1,1,'''') AS NameValues, ' + CHAR(10)
         + '  sdh.deal_date ' + CHAR(10)
         + 'FROM ' + @process_table + ' b ' + CHAR(10)
         + 'INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = b.source_deal_header_id ' + CHAR(10)
         + 'GROUP BY sdh.deal_date'
	EXEC(@sql)

	SELECT @curve_as_of_date = CONVERT(VARCHAR(10), as_of_date ,120) FROM module_asofdate
	SELECT @term_start = CONVERT(VARCHAR(10), as_of_date, 120) FROM module_asofdate
	SELECT @term_end = CONVERT(VARCHAR(10), as_of_date ,120) FROM module_asofdate
	
	IF CURSOR_STATUS('local','mtm_deal_cursor') > = -1
	BEGIN
		DEALLOCATE mtm_deal_cursor
	END

	DECLARE mtm_deal_cursor CURSOR LOCAL
	FOR SELECT source_deal_header_ids, CONVERT(VARCHAR(10), as_of_date, 120) FROM #temp_grouped_deals WHERE source_deal_header_ids IS NOT NULL
	OPEN mtm_deal_cursor
	FETCH NEXT FROM mtm_deal_cursor INTO @source_deal_header_id, @as_of_date
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC spa_calc_mtm_job NULL, NULL, NULL, NULL, @source_deal_header_id, @as_of_date, 
							  4500, NULL, 'b', NULL, NULL, NULL, NULL, NULL, NULL, null, NULL, NULL, 
							  NULL, NULL, NULL, 'n', null, null, 'm', NULL, NULL, NULL, 
							  NULL, NULL, NULL, NULL, NULL
	
	
		SELECT @counterparty_ids = COALESCE(@counterparty_ids + ',', '') + CAST(sdh.counterparty_id AS VARCHAR(10))
		FROM   source_deal_header sdh
		INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON  scsv.item = sdh.source_deal_header_id
	
		EXEC spa_Calc_Credit_Netting_Exposure @as_of_date, @user_name, 4500, NULL,  NULL, NULL, 
											  @counterparty_ids, 'n', 'n', NULL, NULL, NULL, NULL, NULL

		FETCH NEXT FROM mtm_deal_cursor INTO @source_deal_header_id, @as_of_date
	END
	CLOSE mtm_deal_cursor
	DEALLOCATE mtm_deal_cursor
END
ELSE 
BEGIN
	SET @sql = 'INSERT INTO #temp_deals_settlement (source_deal_header_ids, as_of_date, term_start, term_end)
				SELECT  ' + CHAR(10)
			 + 'STUFF(( ' + CHAR(10)
			 + '    SELECT '','' + CAST(a.source_deal_header_id AS VARCHAR(MAX))  ' + CHAR(10)
			 + '    FROM ' + @process_table + ' a ' + CHAR(10)
			 + '    INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = a.source_deal_header_id ' + CHAR(10)
			 + '	GROUP BY a.source_deal_header_id  ' + CHAR(10)
			 + '    FOR XML PATH(''''),TYPE).value(''(./text())[1]'',''VARCHAR(MAX)'') ' + CHAR(10)
			 + '  ,1,1,'''') AS NameValues, ' + CHAR(10)
			 + '  dbo.FNALastDayInDate(MIN(sdd.term_start)), ' + CHAR(10)
			 + '  MIN(sdd.term_start), ' + CHAR(10)
			 + '  MAX(sdd.term_end) ' + CHAR(10)
			 + 'FROM ' + @process_table + ' b ' + CHAR(10)
			 + 'INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = b.source_deal_header_id ' + CHAR(10)
			 + 'INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id ' + CHAR(10)
			 
	EXEC(@sql)
	
	IF CURSOR_STATUS('local','settlement_deal_cursor') > = -1
	BEGIN
		DEALLOCATE settlement_deal_cursor
	END

	DECLARE settlement_deal_cursor CURSOR LOCAL
	FOR SELECT source_deal_header_ids, CONVERT(VARCHAR(10), as_of_date, 120), CONVERT(VARCHAR(10), term_start, 120), CONVERT(VARCHAR(10), term_end, 120) FROM #temp_deals_settlement WHERE source_deal_header_ids IS NOT NULL
	OPEN settlement_deal_cursor
	FETCH NEXT FROM settlement_deal_cursor INTO @source_deal_header_id, @as_of_date, @term_start, @term_end
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC spa_calc_mtm_job NULL, NULL, NULL, NULL, @source_deal_header_id, @as_of_date, 
							  4500, NULL, 'b', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
							  NULL, NULL, NULL, 'n', @term_start, @term_end, 's', NULL, NULL, NULL, 
							  NULL, NULL, NULL, NULL, NULL
		
		FETCH NEXT FROM settlement_deal_cursor INTO @source_deal_header_id, @as_of_date, @term_start, @term_end
	END
	CLOSE settlement_deal_cursor
	DEALLOCATE settlement_deal_cursor
END
