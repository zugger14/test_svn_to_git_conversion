
IF OBJECT_ID(N'[dbo].[spa_auto_matching_batch]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_auto_matching_batch]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: nshrestha@pioneersolutionsglobal.com
-- Create date: 2011-11-02
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_auto_matching_batch]
	@sub_id VARCHAR(1000) = NULL,
	@str_id VARCHAR(1000) = NULL,
	@book_id VARCHAR(1000) = NULL,
	@as_of_date_from VARCHAR(20) = NULL,
	@as_of_date_to VARCHAR(20) = NULL,
	@fifo_lifo VARCHAR(1) = NULL,
	@slicing_first VARCHAR(1) = 'h', --h:first slicing hedge, i:first slicing item
	@perform_dicing VARCHAR(1) = 'y',
	@v_curve_id INT = NULL,
	@h_or_i VARCHAR(1) = NULL,
	@v_buy_sell VARCHAR(1) = NULL,
	@call_for_report VARCHAR(1) = NULL,
	@slice_option VARCHAR(1) = 'm', --m=multi;h=hedge one, i=item one
	@user_name VARCHAR(50) = NULL,
	@only_include_external_der VARCHAR(1) = 'n',
	@externalization VARCHAR(1) = 'n',
	@apply_limit VARCHAR(1) = 'n',
	@limit_bucketing VARCHAR(1) = NULL,
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(5000) = NULL,
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS

BEGIN
	DECLARE @sql varchar(MAX), @table VARCHAR(200), @report_name VARCHAR(100), @where VARCHAR(MAX)
			
	/*******************************************1st Paging Batch START**********************************************/
	DECLARE @str_batch_table VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @sql_paging VARCHAR(8000)
	DECLARE @is_batch bit
	SET @str_batch_table = ''
	SET @user_login_id = dbo.FNADBUser() 
	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END
	
	EXEC spa_print '@is_batch:', @is_batch
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
	SET @where = ''
	IF ISNULL(@h_or_i,'b') <> 'b'
		SET @where = @where + ' AND t.[Type] = ''' + @h_or_i + ''''

	IF ISNULL(@v_buy_sell,'a') <> 'a'
		SET @where = @where + '  AND sdd.buy_sell_flag = '''+@v_buy_sell + ''''
	
	CREATE TABLE #temp_data (
		error_code VARCHAR(20) COLLATE DATABASE_DEFAULT,
		[module] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[area] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[status] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[message] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[recommendation] VARCHAR(500) COLLATE DATABASE_DEFAULT
	)
	
	INSERT INTO #temp_data    
	EXEC spa_auto_matching_job @sub_id, @str_id, @book_id, @as_of_date_from, @as_of_date_to, @fifo_lifo, @slicing_first, @perform_dicing, @v_curve_id, @h_or_i, @v_buy_sell, @call_for_report, @slice_option, @user_name, @only_include_external_der, @externalization
	
	SELECT @table = 'adiha_process.dbo.matching_' + @user_name + '_' + recommendation FROM #temp_data
	EXEC spa_print @table
	EXEC spa_print @str_batch_table
	SET @sql = 'SELECT	eff.sno [Match]
			, t.[Deal REF ID] [Endure Deal Id]
			, t.[Deal ID]
			, t.[Type] [Hedge/Item]
			, t.[% Matched] [Perc Included]
			, t.link_effective_date
			, t.[Deal DATE]
			, MAX(sdd.Leg) AS Leg
			, MAX(dbo.FNADateFormat(t.term_start)) [Term Start]
			, MAX(dbo.FNADateFormat(t.term_end)) [Term End]
			, MAX((CASE sdd.fixed_float_leg WHEN ''f'' THEN ''Fixed'' ELSE ''Float'' END)) AS [Fixed FLOAT]
			, MAX(CASE sdd.buy_sell_flag WHEN ''b'' THEN ''Buy (Receive)'' ELSE ''Sell (Pay)'' END) AS [Buy Sell]
			, MAX(t.deal_volume) [Volume]
			, MAX(CASE sdd.deal_volume_frequency WHEN ''m'' THEN ''Monthly'' WHEN ''q'' THEN ''Quarterly'' ELSE ''Daily'' END) AS Frequency
			, MAX(t.UOM) [UOM]
			, MAX(t.[Hedged Item Product]) [Hedged Item Product]
			, dbo.FNARemoveTrailingZeroes(ROUND(AVG(CASE WHEN sdd.fixed_price=0 THEN NULL ELSE sdd.fixed_price END),3)) Price
			, dbo.FNARemoveTrailingZeroes(AVG(sdd.option_strike_price)) [Strike Price]
			, MAX(sc.currency_name) AS Currency
			, MAX(Book1.source_book_name) AS [Internal Portfolio]
			, MAX(Book2.source_book_name) AS [Counterparty Group]
			, MAX(Book3.source_book_name) AS [Instrument Type]
			, MAX(Book4.source_book_name) AS [Proj Index Group]
			, MAX(CASE sdh.option_type WHEN ''c'' THEN ''Call'' WHEN ''p'' THEN ''Put'' ELSE '''' END) AS [Option TYPE]
			, MAX(CASE sdh.option_excercise_type WHEN ''e'' THEN ''European'' WHEN ''a'' THEN ''American'' ELSE sdh.option_excercise_type END) AS [Exercise Type]
			' + @str_batch_table + '
	FROM	' + @table + ' t
			INNER JOIN source_deal_header sdh ON t.[Deal ID] = sdh.source_deal_header_id 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id AND sdd.leg = 1
			INNER JOIN source_book Book1 ON sdh.source_system_book_id1 = Book1.source_book_id 
			INNER JOIN source_book Book2 ON sdh.source_system_book_id2 = Book2.source_book_id 
			INNER JOIN source_book Book3 ON sdh.source_system_book_id3 = Book3.source_book_id 
			INNER JOIN source_book Book4 ON sdh.source_system_book_id4 = Book4.source_book_id 
			INNER JOIN source_uom ON sdd.deal_volume_uom_id = source_uom.source_uom_id 
			LEFT JOIN source_price_curve_def ON sdd.curve_id = source_price_curve_def.source_curve_def_id 
			LEFT JOIN source_currency sc ON sc.source_currency_id = sdd.fixed_price_currency_id
			LEFT JOIN  (
				SELECT  ROW_NUMBER() OVER(ORDER BY MATCH) sno
						, MATCH
						, MAX(link_effective_date) link_effective_date 
				FROM	' + @table + ' 
				WHERE	match IS NOT NULL 
				GROUP BY match 
			) eff on eff.match = t.Match
	WHERE	1 = 1 ' + @where + '
	GROUP BY eff.sno
			, t.[Deal REF ID]
			, t.[Deal ID]
			, t.[Type]
			, t.[% Matched]
			, t.link_effective_date
			, t.[Deal DATE]
	ORDER BY ISNULL(eff.sno, 999999), [Hedge/Item], t.[Deal ID]'
	
	EXEC spa_print @sql
	EXEC(@sql)
	
	
	/*******************************************2nd Paging Batch START**********************************************/
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
	   SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	   EXEC(@str_batch_table)    
	   
	   SET @report_name='Automate Matching of Hedges' 
	   
	   SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_auto_matching_batch', @report_name) --TODO: modify sp and report name
	   EXEC(@str_batch_table)  
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
