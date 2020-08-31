
/****** Object:  StoredProcedure [dbo].[spa_run_wacog_report]    Script Date: 11/11/2010 13:03:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_run_wacog_report]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_wacog_report]
GO
CREATE PROC [dbo].[spa_run_wacog_report]
	@flag CHAR(1)='s',
	@sub_entity_id VARCHAR(100)=NULL,
	@strategy_entity_id  VARCHAR(100)=NULL,
	@book_entity_id  VARCHAR(100)=NULL,
 	@term_start DATETIME = NULL,
 	@term_end DATETIME = NULL,
 	@as_of_date DATETIME = NULL,
 	@include_deal_type VARCHAR(8000) = NULL,
 	@include_charge_type CHAR(1) = NULL,
 	@buy_sell_flag CHAR(1) = NULL, -- 'b' - buy, 's' - sell, 'a' - both
	
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS
SET NOCOUNT ON
/*******************************************1st Paging Batch START**********************************************/
DECLARE @sql VARCHAR(MAX) 
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
       
   END
END
 
/*******************************************1st Paging Batch END**********************************************/


--DBCC FREEPROCCACHE
--DBCC DROPCLEANBUFFERS
--BEGIN
--DECLARE	@flag CHAR(1)='s',	@sub_entity_id VARCHAR(100)='381,388,328,391,424,290,250,311,296,398,373,289,307,304,385,417,264,271,420,359,413',	@strategy_entity_id  VARCHAR(100)=NULL,	@book_entity_id  VARCHAR(100)=NULL
IF @sub_entity_id='NULL'
	SET @sub_entity_id=NULL

IF @strategy_entity_id='NULL'
	SET @strategy_entity_id=NULL

IF @book_entity_id='NULL'
	SET @book_entity_id=NULL
	
 DECLARE @sql_str VARCHAR(MAX)
--DROP TABLE  ##books
--DROP  TABLE #temp_deals
--DROP TABLE  #temp_d1
CREATE TABLE #books (fas_subsidiary_id int, fas_strategy_id int, fas_book_id int, hedge_type_value_id int, legal_entity_id int) 

BEGIN
 	SET @sql_str =        
		'INSERT INTO  #books       
		SELECT distinct stra.parent_entity_id fas_subsidiary_id, stra.entity_id fas_strategy_id, book.entity_id fas_book_id, fs.hedge_type_value_id hedge_type_value_id, legal_entity legal_entity_id
		--into ##books
		FROM portfolio_hierarchy book (nolock) INNER JOIN
				Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
				source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id LEFT OUTER JOIN
				fas_strategy fs ON fs.fas_strategy_id = book.parent_entity_id LEFT OUTER JOIN
				fas_books fb ON fb.fas_book_id = ssbm.fas_book_id
		WHERE (ssbm.fas_deal_type_value_id = 400 OR 
						(fs.hedge_type_value_id = 151 AND ssbm.fas_deal_type_value_id = 401) OR 
						ssbm.fas_deal_type_value_id = 407)
	'   
	              
	IF @sub_entity_id IS NOT NULL        
		SET @sql_str = @sql_str + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '         
	IF @strategy_entity_id IS NOT NULL        
		SET @sql_str = @sql_str + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        
	IF @book_entity_id IS NOT NULL        
		SET @sql_str = @sql_str + ' AND (book.entity_id IN(' + @book_entity_id + ')) '        
	
	EXEC (@sql_str)
	CREATE CLUSTERED INDEX idx_test1 ON #books(fas_book_id) 
	
	IF OBJECT_ID('tempdb..#temp_final_wacog') IS NOT NULL
	    DROP TABLE #temp_final_wacog
	
	IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL
	    DROP TABLE #temp_deals
	
	IF OBJECT_ID('tempdb..#temp_terms') IS NOT NULL
	    DROP TABLE #temp_terms
	    
	CREATE TABLE #temp_deals (
		id                          INT IDENTITY(1, 1),
		fas_subsidiary_id           INT,
		fas_strategy_id             INT,
		fas_book_id                 INT,
		source_deal_header_id       INT,
		term_start                  DATETIME,
		physical_financial_flag     CHAR(1) COLLATE DATABASE_DEFAULT,
		[value]                     NUMERIC(38, 20),
		[volume]                    NUMERIC(38, 20),
		buy_sell_flag				NCHAR(1) COLLATE DATABASE_DEFAULT ,
		leg							INT,
		deal_volume					NUMERIC(38, 20),
		currency_id					INT					
	)
	
	CREATE TABLE #temp_terms (
		source_deal_header_id       INT,
		term_start                  DATETIME,
		term_end					DATETIME				
	)
	
	;WITH cte_terms AS (
		SELECT source_deal_header_id, term_start, term_end, ROW_NUMBER() OVER (PARTITION BY source_deal_header_id ORDER BY as_of_date DESC) order_id 
		FROM source_deal_settlement 
		WHERE as_of_date <= @as_of_date
	)
	INSERT INTO #temp_terms (source_deal_header_id, term_start, term_end)
	SELECT source_deal_header_id, term_start, term_end FROM cte_terms WHERE order_id = 1
	
	SET @sql = 'INSERT INTO #temp_deals ( ' + char(10)
			 + '	    fas_subsidiary_id, ' + char(10)
			 + '	    fas_strategy_id, ' + char(10)
			 + '	    fas_book_id, ' + char(10)
			 + '	    source_deal_header_id, ' + char(10)
			 + '	    term_start, ' + char(10)
			 + '	    physical_financial_flag, ' + char(10)
			 + '	    [value], ' + char(10)
			 + '	    buy_sell_flag, ' + char(10)
			 + '	    leg, ' + char(10)
			 + '	    deal_volume ' + char(10)
			 + '	  ) ' + char(10)
			 + '	SELECT (book.fas_subsidiary_id)      ' + char(10)
			 + '		   , (book.fas_strategy_id)        ' + char(10)
			 + '		   , (book.fas_book_id)            ' + char(10)
			 + '		   , sdh.source_deal_header_id     ' + char(10)
			 + '		   , sdd.term_start                ' + char(10)
			 + '		   , (sdh.physical_financial_flag) ' + char(10)
			 + '		   , NULL ' + char(10)
			 + '		   , sdd.buy_sell_flag ' + char(10)
			 + '		   , sdd.leg ' + char(10)
			 + '		   , sdd.deal_volume ' + char(10)
			 + '	FROM #books book  ' + char(10)
			 + '	INNER JOIN source_system_book_map sbm ON book.fas_book_id = sbm.fas_book_id  ' + char(10)
			 + '	INNER JOIN source_deal_header sdh ON sdh.source_system_book_id1 = sbm.source_system_book_id1  ' + char(10)
			 + '		AND sdh.source_system_book_id2 = sbm.source_system_book_id2  ' + char(10)
			 + '		AND sdh.source_system_book_id3 = sbm.source_system_book_id3  ' + char(10)
			 + '		AND sdh.source_system_book_id4 = sbm.source_system_book_id4  ' + char(10)
			 + '	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id ' + char(10)
			 + '	WHERE 1 = 1'
			 + '	AND sdd.term_start >= ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''' AND sdd.term_end <= ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''''
	
	--IF @buy_sell_flag <> 'a'
	--BEGIN
	--	SET @sql = @sql	+ '	AND sdd.buy_sell_flag = ''' + @buy_sell_flag + '''' + char(10)
	--END
	
	IF @include_deal_type IS NOT NULL
	BEGIN
		SET @sql = @sql	+ '	AND sdh.source_deal_type_id IN (' + @include_deal_type + ')' + char(10)
	END
	
	--PRINT(ISNULL(@sql, 'is null'))
	EXEC(@sql)		

	CREATE CLUSTERED INDEX idx_test2 ON #temp_deals (ID)  WITH (data_COMPRESSION = PAGE)
	CREATE  INDEX idx_test3 ON #temp_deals (ID,VALUE)  WITH (data_COMPRESSION = PAGE)
	
	IF @include_charge_type = 'n'
	BEGIN
		UPDATE #temp_deals 
		SET [value] = sds.[value], [volume] = sds.[volume], currency_id = sds.currency_id
		FROM #temp_deals td 
		INNER JOIN ( 
			SELECT sd.source_deal_header_id, MAX(tt.term_start) term_start, SUM(sd.settlement_amount) [value], SUM(sd.volume) [volume], sd.leg, MAX(settlement_currency_id) currency_id
			FROM source_deal_settlement sd
			INNER JOIN #temp_terms AS tt ON tt.source_deal_header_id = sd.source_deal_header_id AND tt.term_start = sd.term_start
			GROUP BY sd.source_deal_header_id, sd.leg
		) sds ON sds.source_deal_header_id = td.source_deal_header_id
			AND td.term_start = sds.term_start
			AND td.Leg = sds.leg 
	END
	ELSE
	BEGIN
		UPDATE #temp_deals 
		SET [value] = sds.[value], [volume] = sds.[volume], currency_id = sds.currency_id
		FROM #temp_deals td 
		INNER JOIN ( 
			SELECT source_deal_header_id, term_start, SUM([value]) [value], leg, SUM([volume]) [volume], MAX(currency_id) currency_id
			FROM (
				SELECT sd.source_deal_header_id, MAX(tt.term_start) term_start, SUM(sd.settlement_amount) [value], SUM(sd.volume) [volume], sd.leg, MAX(settlement_currency_id) currency_id 
				FROM source_deal_settlement sd
				INNER JOIN #temp_terms AS tt ON tt.source_deal_header_id = sd.source_deal_header_id AND tt.term_start = sd.term_start
				GROUP BY sd.source_deal_header_id, sd.leg
				
				UNION ALL 
				
				SELECT sd.source_deal_header_id, MAX(tt.term_start) term_start, SUM(sd.value) [value], 0 [volume], sd.leg, MAX(currency_id) currency_id 
				FROM index_fees_breakdown_settlement sd
				INNER JOIN #temp_terms AS tt ON tt.source_deal_header_id = sd.source_deal_header_id AND tt.term_start = sd.term_start
				GROUP BY sd.source_deal_header_id, sd.leg
			) b
			GROUP BY source_deal_header_id, term_start, leg
		) sds ON sds.source_deal_header_id = td.source_deal_header_id
			AND td.term_start = sds.term_start
			AND td.Leg = sds.leg 		
	END

	/*
	DECLARE @id INT,@formula VARCHAR(5000),@formula_stmt VARCHAR(5000)
	
	SELECT id, formula 
		INTO #temp_d1 
	FROM #temp_deals 
	WHERE formula IS NOT NULL
	CREATE CLUSTERED INDEX idx_temp4 ON #temp_d1(id)
	
	DECLARE cur1 CURSOR FOR
		SELECT [id], formula FROM #temp_d1-- WHERE formula IS NOT NULL
	OPEN cur1
	FETCH NEXT FROM cur1 INTO @id, @formula
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @formula_stmt = 'UPDATE  #temp_deals 
							SET [Value] = (fixed_price + price_adder +  ' + @formula + ') * price_multiplier * deal_volume
							WHERE [id] = ' + CAST(@id AS VARCHAR)
		EXEC spa_print @formula_stmt
		EXEC(@formula_stmt)
		FETCH NEXT FROM cur1 INTO @id, @formula
	END
	CLOSE cur1
	DEALLOCATE cur1
	*/
	--EXEC('SELECT * FROM #temp_deals ORDER BY  buy_sell_flag')
	-- Term, Buy/Sell, Volume, Amount, WACOG, Currency
	CREATE TABLE #temp_final_wacog ([Term] DATETIME, [Buy/Sell] NVARCHAR(20) COLLATE DATABASE_DEFAULT , Volume FLOAT, Amount FLOAT, [Currency] NVARCHAR(50) COLLATE DATABASE_DEFAULT , [WACOG] FLOAT)

	SELECT @sql = ' INSERT INTO #temp_final_wacog([Term], [Buy/Sell], [Currency], [WACOG], Amount, Volume)
					SELECT settle.[term_start] [Term],
						   CASE settle.buy_sell_flag
								WHEN ''b'' THEN ''Buy''
								ELSE ''Sell''
						   END AS [Buy/Sell],
						   MAX(sc.currency_id) [Currency],
						   dbo.FNARemoveTrailingZeroes(ROUND(SUM(settle.[value])/SUM(volume.[Volume]), 4)) [WACOG],
						   dbo.FNARemoveTrailingZeroes(ROUND(SUM(settle.[value]), 4)) [Amount],
						   dbo.FNARemoveTrailingZeroes(ROUND(SUM(volume.[Volume]), 4)) [Volume]
					FROM 
					( SELECT buy_sell_flag,
					        MAX(currency_id) currency_id,
					        SUM([VALUE]) [value],
					        dbo.FNAGETContractMonth([term_start]) term_start
					  FROM #temp_deals '
	
	IF @buy_sell_flag <> 'a'
	BEGIN
		SET @sql = @sql	+ '	WHERE buy_sell_flag = ''' + @buy_sell_flag + ''''
	END				  
					  
	SET @sql = @sql	+ ' GROUP BY buy_sell_flag, dbo.FNAGETContractMonth([term_start])
						) settle
						OUTER APPLY (SELECT SUM(ABS([volume])) Volume FROM #temp_deals '
					
	SET @sql = @sql	+ '	WHERE buy_sell_flag = ''' + ISNULL(NULLIF(@buy_sell_flag, 'a'), 'b') + ''''	
	
	SET @sql = @sql	+ ' ) volume
					LEFT JOIN source_currency sc ON sc.source_currency_id = settle.currency_id
					GROUP BY settle.[term_start], settle.buy_sell_flag
					ORDER BY settle.[term_start] '
	
	--PRINT @sql
	EXEC(@sql)

	IF @buy_sell_flag = 'a'
	BEGIN
		SET @sql = ' SELECT dbo.FNADateFormat(MAX([Term])) [Term],
		                    ''Buy and Sell'' [Buy/Sell],
		                    dbo.FNAAddThousandSeparator(SUM([Amount])) [Amount],
							dbo.FNAAddThousandSeparator(MAX(Volume)) Volume,
		                    dbo.FNAAddThousandSeparator(SUM([WACOG])) [WACOG],
							MAX([Currency]) [Currency]
		             ' + @str_batch_table + '
		             FROM   #temp_final_wacog '
	    EXEC(@sql)
	END 
	ELSE
	BEGIN
		SET @sql = ' SELECT dbo.FNADateFormat([Term]) [Term],
		                    [Buy/Sell],
							dbo.FNAAddThousandSeparator([Amount]) [Amount],
							dbo.FNAAddThousandSeparator(Volume) Volume,
		                    dbo.FNAAddThousandSeparator([WACOG]) [WACOG],
							[Currency]
	             ' + @str_batch_table + '
	             FROM   #temp_final_wacog '
	    EXEC(@sql)
	END
END

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_run_wacog_report', 'WACOG Report')
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
