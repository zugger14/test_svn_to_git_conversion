IF OBJECT_ID(N'[dbo].[spa_calc_dynamic_limit]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_calc_dynamic_limit]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: Calculate dynamic limit

-- Params:
-- @run_date datetime --Run date 
-- @flag CHAR flag to indicate calc or show report
-- @source_updated_deal_ids VARCHAR updated source_deal_header ids
-- @source_updated_deal_table VARCHAR process table
-- @batch_process_id VARCHAR batch process id
-- @batch_report_param VARCHAR batch report parameters
-- EXEC spa_calc_dynamic_limit '2011-12-12', 'c', '478918,478919,478927'
-- EXEC spa_calc_dynamic_limit	'2011-12-20 11:17:49.157','c','574450' 
-- EXEC spa_calc_dynamic_limit '2012-01-10', 'c', NULL, NULL, '3,2', NULL, NULL, '93,53', '406', 'l', '451', 'l', DEFAULT, DEFAULT, 'i', DEFAULT, 'i', DEFAULT, DEFAULT, DEFAULT,'h'

-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_calc_dynamic_limit]
	@run_date VARCHAR(30) = NULL
	, @flag CHAR(1)
	, @source_updated_deal_ids VARCHAR(MAX) = NULL
    , @source_updated_deal_table VARCHAR(150) = NULL
    , @sub_ids VARCHAR(MAX) = NULL
    , @stra_ids VARCHAR(MAX) = NULL
    , @book_ids VARCHAR(MAX) = NULL
    , @counterparty_ids VARCHAR(MAX) = NULL
    , @trans_ids VARCHAR(MAX) = NULL
    
    , @sort_order VARCHAR(1) = 'l'
    , @dedesignate_type INT = 451
    , @FIFO_LIFO VARCHAR(1) = 'l'
	
	, @slicing_first VARCHAR(1) = 'i' --h:first slicing hedge, i:first slicing item
	, @perform_dicing VARCHAR(1) = 'n' 
	
	, @h_or_i VARCHAR(1) = 'b'
	, @v_buy_sell VARCHAR(1) = 'a'
	
	, @slice_option VARCHAR(1) = 'i' --m=multi;h=hedge one, i=item one
	, @only_include_external_der VARCHAR(1) = 'y' 
	, @externalization VARCHAR(1) = 'n'
	, @book_map_ids VARCHAR(MAX) = NULL
	, @deal_dt_option VARCHAR(1) = 'h' --i: i_dt>=h_dt;  h:h_dt>=i_dt;  a: not apply filter or ignor deal date filter
	, @internalPortfolio VARCHAR(MAX) = NULL
    , @instrumentType VARCHAR(MAX) = NULL
    , @projectionIndex VARCHAR(MAX) = NULL
    
    , @batch_process_id VARCHAR(250) = NULL
    , @batch_report_param VARCHAR(500) = NULL
    , @user_login_id VARCHAR(100) = NULL
	
AS

/*
* Test Data
DECLARE 
	@run_date VARCHAR(10),
    @flag CHAR(1),
    @source_updated_deal_ids VARCHAR(MAX),
    @source_updated_deal_table VARCHAR(150),
    @batch_process_id VARCHAR(250),
	@batch_report_param VARCHAR(500),
	@sub_ids VARCHAR(MAX) = NULL,
    @stra_ids VARCHAR(MAX) = NULL,
    @book_ids VARCHAR(MAX) = NULL
	
SET @run_date = '2011-12-12'
SET @flag = 'c'
--SET @sub_ids = '1'
SET @source_updated_deal_ids = '478918,478919,478927'


IF OBJECT_ID(N'tempdb..#expected_position', N'U') IS NOT NULL
	DROP TABLE #expected_position

IF OBJECT_ID(N'tempdb..#temp_date_for_updated_deals', N'U') IS NOT NULL
	DROP TABLE #temp_date_for_updated_deals

IF OBJECT_ID(N'tempdb..#net_retail_physical_sales', N'U') IS NOT NULL
	DROP TABLE #net_retail_physical_sales
	
IF OBJECT_ID(N'tempdb..#tbl_after_dynamic_calc', N'U') IS NOT NULL
	DROP TABLE #tbl_after_dynamic_calc

IF OBJECT_ID(N'tempdb..#temp', N'U') IS NOT NULL
	DROP TABLE #temp

IF OBJECT_ID(N'tempdb..#tmp_sub', N'U') IS NOT NULL
	DROP TABLE #tmp_sub
IF OBJECT_ID(N'tempdb..#DE_expected_to_occur_deal', N'U') IS NOT NULL
	DROP TABLE #DE_expected_to_occur_deal
IF OBJECT_ID(N'tempdb..#DE_net_physical_retail_sales', N'U') IS NOT NULL
	DROP TABLE #DE_net_physical_retail_sales
IF OBJECT_ID(N'tempdb..#DE_participating_subsidiaries', N'U') IS NOT NULL
	DROP TABLE #DE_participating_subsidiaries
	
	
	
--*/
	
--DECLARE @user_login_id VARCHAR(150)
SET @user_login_id = ISNULL(@user_login_id , dbo.FNADBUser())

DECLARE @sql VARCHAR(MAX)
DECLARE @LIMIT_DEAL_ID VARCHAR(150)
DECLARE @process_table_yes_no BIT = 0
SET @LIMIT_DEAL_ID = 'Limit deal'

IF @source_updated_deal_ids IS NOT NULL OR @source_updated_deal_table IS NOT NULL
	SET @process_table_yes_no = 1

IF @flag = 'c'
BEGIN
	DECLARE @DE_expected_to_occur_deal VARCHAR(150)	,@DE_net_physical_retail_sales VARCHAR(150)	 ,@DE_participating_subsidiaries   VARCHAR(150)
	SET @DE_expected_to_occur_deal = 'DE Expected to Occur Deal'
	set @DE_net_physical_retail_sales='DE Net Physical Retail Sales'
	set @DE_participating_subsidiaries='DE Participating Subsidiaries'

	DECLARE @CURVE_ID VARCHAR(150)
	DECLARE @COUNTERPARTY_ID VARCHAR(500)
	
	DECLARE @desc VARCHAR(MAX)
	DECLARE @curve_value FLOAT
	DECLARE @url VARCHAR(MAX)

	
	--TODO: change

SELECT	cast([clm1_value] as int) AS [sb1]
			, cast([clm2_value] as int) AS [sb2]
			,cast( [clm3_value] as int) AS [sb3]
			,cast( [clm4_value] as int) AS [sb4]
			, cast([clm5_value] as int) AS [transaction_type] 
	INTO #DE_expected_to_occur_deal
	FROM generic_mapping_values  v INNER JOIN dbo.generic_mapping_header h ON  v.mapping_table_id=h.mapping_table_id
	WHERE h.mapping_name = @DE_expected_to_occur_deal
	
	SELECT	cast([clm1_value] as int) AS [internal_portfolio]
			, cast([clm2_value] as int) AS [instrument_type]
			, cast([clm3_value] as int) AS [Curve]
			, cast([clm4_value] as int) AS [include_exclude] 
	INTO #DE_net_physical_retail_sales
	FROM generic_mapping_values  v INNER JOIN dbo.generic_mapping_header h ON  v.mapping_table_id=h.mapping_table_id
	WHERE h.mapping_name = @DE_net_physical_retail_sales




	SELECT	cast([clm1_value] as int) AS sub_id   
	INTO #DE_participating_subsidiaries
	FROM generic_mapping_values  v INNER JOIN dbo.generic_mapping_header h ON  v.mapping_table_id=h.mapping_table_id
	WHERE h.mapping_name = @DE_participating_subsidiaries
	 

	SET @CURVE_ID = 'Markdown %'
	
	BEGIN TRY
		--DECLARE @COUNTERPARTY_ID VARCHAR(500)
		--568	20	20227	MORGAN US BU	MORGAN US BU	e
		
		IF @counterparty_ids IS NOT NULL
		BEGIN
			SELECT counterparty_id INTO #temp_counterparty
			FROM source_counterparty sc 
			INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_ids) scsv ON scsv.item = sc.source_counterparty_id
			SET @COUNTERPARTY_ID = STUFF((
											SELECT ',' + CAST(counterparty_id AS VARCHAR(10)) from #temp_counterparty FOR XML PATH('')
										), 1, 1, '')

		END
		ELSE
		BEGIN
			CREATE TABLE #temp(counterparty_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT   )
			INSERT INTO #temp(counterparty_id) EXEC spa_StaticDataValues z, 19100
			SELECT @COUNTERPARTY_ID = counterparty_id FROM #temp
	    END
		
		--calc expected to occur position
		CREATE TABLE #expected_position(source_deal_header_id INT, deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT  , term_start DATETIME, term_end DATETIME, deal_volume NUMERIC)
		
		INSERT INTO #expected_position (source_deal_header_id, deal_id, term_start, term_end, deal_volume)
		SELECT sdd.source_deal_header_id, sdh.deal_id, sdd.term_start, sdd.term_end, 
			CASE WHEN sdd.buy_sell_flag = 'b' THEN sdd.deal_volume ELSE (-1 * sdd.deal_volume) END 
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		inner join #DE_expected_to_occur_deal bk on bk.sb1=sdh.source_system_book_id1  and bk.sb2=sdh.source_system_book_id2
			and bk.sb3=sdh.source_system_book_id3 and bk.sb4=sdh.source_system_book_id4
		inner join source_system_book_map ssbm on ssbm.fas_deal_type_value_id= bk.[transaction_type]
			and  bk.sb1=ssbm.source_system_book_id1  and bk.sb2=ssbm.source_system_book_id2
			and bk.sb3=ssbm.source_system_book_id3 and bk.sb4=ssbm.source_system_book_id4

		--SELECT * FROM  #expected_position			
		
		--markdown%
   		SELECT @curve_value = spc.curve_value 
		FROM source_price_curve spc
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = spc.source_curve_def_id
		WHERE spcd.curve_id = @CURVE_ID
		
		--IF @internalPortfolio IS NULL
		--BEGIN
		--	SELECT @internalPortfolio = STUFF((
		--										SELECT ',' + CAST([internal_portfolio] AS VARCHAR(10)) 
		--										FROM #DE_net_physical_retail_sales sb WHERE sb.source_system_book_type_value_id = 50 AND sb.source_book_name <> 'v8_CCX_BB_RWE_ENERGY'
		--										FOR XML PATH('')
		--									), 1, 1, '') 
		--END
		
		--IF @instrumentType IS NULL
		--BEGIN
		--	SELECT @instrumentType = STUFF((
		--										SELECT ',' + CAST(sb.source_book_id AS VARCHAR(10)) 
		--										FROM source_book sb WHERE sb.source_system_book_type_value_id = 52 AND sb.source_book_name = 'PWR-PHYS'
		--										FOR XML PATH('')
		--									), 1, 1, '') 
		--END
		
		
		--IF @projectionIndex IS NULL
		--BEGIN
		--	SELECT @projectionIndex = STUFF((
		--										SELECT ',' + CAST(spcd.source_curve_def_id AS VARCHAR(10)) 
		--										FROM source_price_curve_def spcd WHERE spcd.curve_name= 'v8_EIS_valuation'
		--										FOR XML PATH('')
		--									), 1, 1, '') 

		--END
		---------------------End default book identifiers
		
		
		--table to get term start and term end for updated deals
		IF @source_updated_deal_ids IS NOT NULL 
		BEGIN
			EXEC spa_print 'Trigger parts'
			DECLARE @process_id VARCHAR(150)
			SET @process_id = dbo.FNAGetNewID()
			SET @source_updated_deal_table = dbo.FNAProcessTableName('deal_header_id', 'farrms_admin', @process_id)
			
			SET @sql = 'CREATE TABLE ' + @source_updated_deal_table + ' (source_deal_header_id INT, term_start DATETIME, term_end DATETIME)'
			EXEC(@sql)
			
			SET @sql = '
						INSERT INTO ' + @source_updated_deal_table	 + ' (source_deal_header_id, term_start, term_end) 
						SELECT sdhid.item, sdd.term_start, sdd.term_end 
						FROM dbo.SplitCommaSeperatedValues(''' + @source_updated_deal_ids + ''') sdhid
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdhid.item
						'
			EXEC spa_print @sql
			EXEC(@sql)
			
		END
		
		--calc net_retail_physical_sales
		CREATE TABLE #net_retail_physical_sales(deal_volume NUMERIC(38, 20), term_start DATETIME, term_end DATETIME)
		SET @sql  = '
					INSERT INTO #net_retail_physical_sales(deal_volume, term_start, term_end)
					SELECT ABS(SUM(CASE WHEN sdd.buy_sell_flag = ''b'' THEN sdd.deal_volume ELSE (-1 * sdd.deal_volume) END)) deal_volume
					, sdd.term_start, sdd.term_end
					FROM source_deal_header sdh
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
						AND sdd.Leg = 1
					INNER JOIN source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
					INNER JOIN dbo.SplitCommaSeperatedValues(''' + @COUNTERPARTY_ID + ''') scsv ON scsv.Item = sc.counterparty_id 
					INNER JOIN source_system_book_map ssbm 
					ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4'
						+ CASE WHEN @trans_ids IS NULL THEN ' AND isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = 410' 
						ELSE ' AND isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) IN (' + CAST(@trans_ids AS VARCHAR(500))+ ')' END + '
					LEFT JOIN portfolio_hierarchy AS book ON book.entity_id = ssbm.fas_book_id 
					LEFT JOIN portfolio_hierarchy AS stra ON stra.entity_id = book.parent_entity_id 
					LEFT JOIN portfolio_hierarchy AS sub ON sub.entity_id = stra.parent_entity_id 
					INNER JOIN #DE_participating_subsidiaries scsv_sub ON scsv_sub.sub_id = sub.entity_id 
					cross apply
					( select top(1) 1 b from  #DE_net_physical_retail_sales where  sdh.source_system_book_id1=isnull([internal_portfolio],sdh.source_system_book_id1)
					   and sdh.source_system_book_id3=isnull([instrument_type],sdh.source_system_book_id3) and sdd.curve_id=isnull([Curve],sdd.curve_id) and [include_exclude]=1
					)  flt
					cross apply
					( select top(1) 1 a from  #DE_net_physical_retail_sales where sdh.source_system_book_id1<>isnull([internal_portfolio],-1)
					   and sdh.source_system_book_id3<>isnull([instrument_type],-1) and sdd.curve_id<>isnull([Curve],-1) and [include_exclude]=2
					
					) flt2 					'
					+ CASE WHEN ISNULL(@stra_ids, '') <> '' THEN '
					INNER JOIN dbo.SplitCommaSeperatedValues(''' + @stra_ids + ''') scsv_stra ON scsv_stra.Item = stra.entity_id ' ELSE '' END
					+ CASE WHEN ISNULL(@book_ids, '') <> '' THEN '
					INNER JOIN dbo.SplitCommaSeperatedValues(''' + @book_ids + ''') scsv_book ON scsv_book.Item = book.entity_id ' ELSE '' END
					+ CASE WHEN @process_table_yes_no = 1 THEN 
					' INNER JOIN ' + @source_updated_deal_table + ' sudt ON sudt.term_start = sdd.term_start AND sudt.term_end = sdd.term_end' ELSE '' END  
					+ '
					WHERE 1 = 1 AND sdh.deal_status IN (5605, 5632) 
					GROUP BY sdd.term_start, sdd.term_end
					'		
		EXEC spa_print @sql
		
		EXEC(@sql)
				

		--SELECT *  FROM #net_retail_physical_sales
	END TRY
	BEGIN CATCH
		--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at ' + CAST(ERROR_LINE() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE()
		SET @desc = 'Error while calculating dynamic limit.'
		EXEC spa_message_board 'i', @user_login_id, NULL, 'Dynamic Limit', @desc, '', '', 'c', @process_id
		--EXEC spa_print 'Error Found in Catch: ' + ERROR_MESSAGE()
	END CATCH			
			
	--SELECT * FROM #net_retail_physical_sales
	--calculation
	--SELECT	((1 - ' + CAST(@curve_value AS VARCHAR(50)) + ') * (ISNULL(ep.deal_volume, 0) - ISNULL(nrps.deal_volume, 0))) AS [to_update_volume], ' +  
	--					CAST(@curve_value AS VARCHAR(50)) + ', ISNULL(ep.deal_volume, 0) AS ep, ISNULL(nrps.deal_volume, 0) AS nrps, sdh.deal_id, sdd.term_start, sdd.term_end
	--UPDATE source_deal_detail 
	--				SET deal_volume = ABS(((1 - ' + CAST(@curve_value AS VARCHAR(50)) + ') * (ISNULL(ep.deal_volume, 0) - ISNULL(nrps.deal_volume, 0))))
	
	CREATE TABLE #tbl_after_dynamic_calc(to_update_volume NUMERIC(38, 20), term_start DATETIME, term_end DATETIME, source_deal_header_id INT)
	
	SET @sql = 'INSERT INTO #tbl_after_dynamic_calc(to_update_volume, term_start, term_end, source_deal_header_id)
				SELECT	(1 - ' + CAST(@curve_value AS VARCHAR(50)) + ') * ISNULL(ep.deal_volume, 0) - ABS(ISNULL(nrps.deal_volume, 0)) AS [to_update_volume], 
						sdd.term_start term_start, sdd.term_end term_end, sdd.source_deal_header_id
				FROM source_deal_detail sdd
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id 
					AND sdh.deal_id = ''' + @LIMIT_DEAL_ID + '''
				LEFT JOIN #expected_position ep ON ep.term_start = sdd.term_start 
					AND ep.term_end = sdd.term_end
				LEFT JOIN #net_retail_physical_sales nrps ON nrps.term_start = sdd.term_start 
					AND nrps.term_end = sdd.term_end
				'
	EXEC spa_print @sql
	EXEC(@sql)
	
	
	
	UPDATE sdd
		SET sdd.deal_volume = tadc.to_update_volume 
	FROM source_deal_detail sdd 
	INNER JOIN #tbl_after_dynamic_calc  tadc ON tadc.term_start = sdd.term_start AND tadc.term_end = sdd.term_end 
	WHERE tadc.to_update_volume <> 0.0
		AND sdd.source_deal_header_id = tadc.source_deal_header_id 
	
	--Update message board
	SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_calc_dynamic_limit ''' + @run_date + ''', ''r'''
	SET @desc = 'Calculation of ''''High Probable Hedge Limit'''' has been completed, Please <a target="_blank" href="' + @url + '">click here </a>to check final limit.'
	EXEC spa_message_board 'i', @user_login_id, NULL, 'Dynamic Limit', @desc, '', '', 'c', @batch_process_id
	
	
	--DECLARE @final_sub_ids VARCHAR(MAX)
	--SELECT @final_sub_ids = STUFF((
	--			SELECT ',' + CAST(sub_id AS VARCHAR(10)) FROM #tmp_sub FOR XML PATH('')
	--		), 1, 1, '')
	
	--PRINT '@final_sub_ids:' + ISNULL(@final_sub_ids, 'NULL')


	if @sub_ids is null
		SELECT	@sub_ids=isnull(@sub_ids+',','')+ cast(sub_id as varchar) from  #DE_participating_subsidiaries


	EXEC spa_print '@sub_ids:', @sub_ids

	-- SELECT @sub_ids
	
	--SELECT 'EXEC spa_calc_process_dynamic_limit', @final_sub_ids, @run_date, @sort_order, @dedesignate_type, @FIFO_LIFO, @slicing_first, @perform_dicing, @h_or_i, @v_buy_sell, @slice_option, @only_include_external_der, @externalization, @book_map_ids, @deal_dt_option
	EXEC spa_calc_process_dynamic_limit @sub_ids, @run_date, @sort_order, @dedesignate_type, @FIFO_LIFO, @slicing_first, @perform_dicing, @h_or_i, @v_buy_sell, @slice_option, @only_include_external_der, @externalization, @book_map_ids, @deal_dt_option, @user_login_id,null,'DE'

END	
ELSE IF @flag = 'r'
BEGIN
	SET @sql = '
				SELECT 
					sdh.source_deal_header_id AS [Deal Id],
					sdh.deal_id AS [Deal Ref Id],
					dbo.FNADateFormat(sdd.term_start) AS [Term Start],
					dbo.FNADateFormat(sdd.term_end) AS [Term End],
					sdd.Leg AS [Leg],
					CASE WHEN sdd.fixed_float_leg = ''t'' THEN ''Fixed'' ELSE ''Float'' END AS [Fixed/Float],
					CASE WHEN sdd.buy_sell_flag = ''b'' THEN ''Buy'' ELSE ''Sell'' END AS [Buy/Sell],
					CASE WHEN sdd.physical_financial_flag = ''p'' THEN ''Physical'' ELSE ''Financial'' END AS [Physical/Financial],
					dbo.FNAAddThousandSeparator(sdd.deal_volume) [Deal Volume],
					sml.Location_Name AS [Location],
					spcd.curve_name,
					sdd.deal_volume_frequency AS [Frequency],
					su.uom_name [Uom],
					sc.currency_name AS [Currency] 
				FROM source_deal_header sdh
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_currency sc ON sc.source_currency_id = sdd.fixed_price_currency_id
				INNER JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
				WHERE sdh.deal_id = ''' + CAST(@LIMIT_DEAL_ID AS VARCHAR(100)) + '''
				ORDER BY sdd.term_start
			'
	EXEC spa_print @sql
	EXEC(@sql)
END
