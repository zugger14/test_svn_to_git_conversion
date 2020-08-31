

IF OBJECT_ID(N'dbo.spa_calculate_line_item', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_calculate_line_item]
GO 

CREATE PROCEDURE [dbo].[spa_calculate_line_item]
	@as_of_date DATETIME, --'2012-05-31'
	@item_filter INT = NULL, -- null: all, 1: rsr, 2: open position, 3: premium, 4: fee
	@counterparty_id INT = NULL,
	@book_id VARCHAR(MAX) = NULL,
	@tou INT = NULL,
	@subsidiary VARCHAR(MAX) = NULL,
	@strategy VARCHAR(MAX) = NULL,
	@run_mode TINYINT = 0, -- 0: select, 1: calc and select
	@is_batch INT = 1,
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(1000) = NULL
AS

DECLARE @str_batch_table VARCHAR(MAX), @sql VARCHAR(MAX), @book VARCHAR(MAX)
CREATE table #books(book_id INT)

set @sql = 'insert into #books select book.entity_id FROM portfolio_hierarchy sub INNER JOIN portfolio_hierarchy stra ON sub.entity_id = stra.parent_entity_id
INNER JOIN portfolio_hierarchy book ON stra.entity_id = book.parent_entity_id where 1=1'

IF ISNULL(RTRIM(LTRIM(@subsidiary)), '') <> '' 
	set @sql = @sql + ' and sub.entity_id IN ( ' + @subsidiary + ')'
IF ISNULL(RTRIM(LTRIM(@strategy)), '') <> ''
	SET @sql = @sql + ' and stra.entity_id in ( ' + @strategy + ' )'
IF ISNULL(RTRIM(LTRIM(@book_id)), '') <> ''
	SET @sql = @sql + ' and book.entity_id in ( ' + @book_id + ')'
	
EXEC spa_print @sql
EXEC(@sql)

SELECT @book = COALESCE(@book + ',' ,'') + cast(book_id as varchar) FROM #books

SET @str_batch_table = ''

IF @batch_process_id IS NOT NULL  
BEGIN      
	SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id, @batch_report_param, NULL, NULL, NULL)   
	SET @str_batch_table = @str_batch_table
END

	-- item_type: premium, fees, rsr, open_pos
	--CREATE TABLE #line_item(item_type VARCHAR(32) COLLATE DATABASE_DEFAULT, term DATETIME, book_id INT, counterparty_id INT, tou INT, line_item VARCHAR(128) COLLATE DATABASE_DEFAULT, [value] NUMERIC(38,20), line_item_type VARCHAR(250) COLLATE DATABASE_DEFAULT)

IF @run_mode = 1
BEGIN
	BEGIN TRAN
	
	-- get residue shaped risk
	IF @item_filter IS NULL OR @item_filter = 1 
	BEGIN
		
		DELETE FROM position_line_items WHERE item_type = 20301 AND  as_of_date = @as_of_date
		
		INSERT INTO position_line_items(item_type, as_of_date, term, book_id, counterparty_id, tou, line_item, [value], line_item_type)
		EXEC [spa_calc_rsr_openposition] @as_of_date ,1, @counterparty_id, @book, @tou
	END
	
	IF @item_filter IS NULL OR @item_filter = 2 
	BEGIN
		
		DELETE FROM position_line_items WHERE item_type = 20302 AND  as_of_date = @as_of_date

		-- get open position
		INSERT INTO position_line_items(item_type, as_of_date, term, book_id, counterparty_id, tou, line_item, [value], line_item_type)
		EXEC [spa_calc_rsr_openposition] @as_of_date ,2, @counterparty_id, @book, @tou
	END
	
	IF @item_filter IS NULL OR @item_filter = 3 
	BEGIN
		DELETE FROM position_line_items WHERE item_type = 20303 AND  as_of_date = @as_of_date

		--get Premium
		INSERT INTO position_line_items(item_type, as_of_date, term, book_id, counterparty_id, tou, line_item, [value], line_item_type)
		EXEC [spa_calculate_premium_fees] @as_of_date, 1, @counterparty_id, @book
	END
	
	IF @item_filter IS NULL OR @item_filter = 4 
	BEGIN
		DELETE FROM position_line_items WHERE item_type = 20304 AND  as_of_date = @as_of_date

		--get Fee
		INSERT INTO position_line_items(item_type, as_of_date, term, book_id, counterparty_id, tou, line_item, [value], line_item_type)
		EXEC [spa_calculate_premium_fees] @as_of_date, 2, @counterparty_id, @book
	END

	COMMIT
END	
	

SET @sql = 'SELECT dbo.FNADateFormat(term) Term,
                   sub.entity_name + '' / '' + stra.entity_name + '' / '' + book.entity_name Book,
                   counterparty_name Counterparty,
                   btg.block_name ToU,
                   line_item [Line Items],
                   MAX([value]) VALUE,
                   line_item_type [Line Items Type] ' + @str_batch_table + '
            FROM   position_line_items li
                   LEFT JOIN source_counterparty sc ON  li.counterparty_id = sc.source_counterparty_id
                   LEFT JOIN portfolio_hierarchy book ON  book.entity_id = li.book_id
                   INNER JOIN portfolio_hierarchy stra ON  stra.entity_id = book.parent_entity_id
                   INNER JOIN portfolio_hierarchy sub ON  sub.entity_id = stra.parent_entity_id
                   LEFT JOIN [block_type_group] btg ON  li.tou = btg.hourly_block_id
WHERE as_of_date = ''' + CONVERT(VARCHAR(10),@as_of_date, 126)  + ''' ' +
CASE 
     WHEN @item_filter IS NULL THEN ''
     ELSE 'AND li.item_type = ' + CASE @item_filter
                                       WHEN 1 THEN '20301'
                                       WHEN 2 THEN '20302'
                                       WHEN 3 THEN '20303'
                                       WHEN 4 THEN '20304'
                                  END
END + 
CASE 
     WHEN @counterparty_id IS NULL THEN ''
     ELSE ' AND sc.source_counterparty_id = ' + CAST(@counterparty_id AS VARCHAR)
END + 
CASE 
     WHEN @tou IS NULL THEN ''
     ELSE ' AND btg.hourly_block_id = ' + CAST(@tou AS VARCHAR)
END + 
CASE 
     WHEN @book IS NULL THEN ''
     ELSE ' AND book.entity_id IN (' + @book + ')'
END + 
' GROUP BY Term, sub.entity_name, stra.entity_name, book.entity_name, counterparty_name, btg.block_name, line_item, line_item_type '

EXEC spa_print @sql
EXEC(@sql)


-- ***************** FOR BATCH PROCESSING **********************************    
 
IF  @batch_process_id IS NOT NULL AND @is_batch = 1   
BEGIN        
	 SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)         
	 EXEC(@str_batch_table)        
	 DECLARE @report_name VARCHAR(100)        

	 SET @report_name = 'Run Index Position Report'        
	        
	 SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_calculate_line_item', @report_name)         
	 EXEC(@str_batch_table)        
	        
END        
-- ********************************************************************  
