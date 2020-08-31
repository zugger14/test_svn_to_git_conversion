IF OBJECT_ID(N'[dbo].[spa_power_bidding_nomination]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_power_bidding_nomination]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2012-08-10
-- Description: Calculate and reporting for power bidding and nomination
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @date_from DATETIME - Start Date
-- @date_to DATETIME - Date to
-- @show_totals CHAR - Show totals checkbox
-- @include_financial - Include Financial checkbox
-- @place_order CHAR(1) - Place Order checkbox
-- @buy_sell CHAR(1) - Buy Sell Flag
-- @grid VARCHAR(1000) - Grid IDs
  
--EXEC spa_power_bidding_nomination 's',  
--     '2012-09-01',  
--     '2012-09-22'  
--     ,  
--     'false',  
--     'false',  
--     'false',  
--     'a',  
--     '292034'  
--EXEC spa_power_bidding_nomination 's', '2012-09-16', '2012-10-23', 'true', 'false', 'true', 'a', '292034'  
  
--EXEC spa_power_bidding_nomination 'c', '2012-09-16', '2012-10-23', 'false', 'true', 'true', 'a', '292034'  
  
--EXEC spa_power_bidding_nomination 'x', '2012-09-16', '2012-10-23', 'false', 'true', 'true', 'a', '292034'  
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_power_bidding_nomination]
	@flag CHAR(1),
	@date_from DATETIME = NULL,
	@date_to DATETIME = NULL,
	@show_totals CHAR(6) = NULL,   
	@include_financial VARCHAR(6) = NULL,  
	@place_order VARCHAR(6) = NULL,  
	@buy_sell VARCHAR(10) = NULL,  
	@grid VARCHAR(1000) = NULL,
	@batch_process_id VARCHAR(50) = NULL,  
	@batch_report_param VARCHAR(1000) = NULL,  
	@enable_paging INT = 0,  --	'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS

/*******************************************1st Paging Batch START**********************************************/
DECLARE @sql VARCHAR(8000)
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @process_table_name VARCHAR(150)
DECLARE @is_batch BIT
DECLARE @sql_paging VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)

SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
SET @process_table_name = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + @process_table_name 

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

/* Drop temp table start */
  
IF OBJECT_ID(N'tempdb..#position_calc', N'U') IS NOT NULL
	DROP TABLE #position_calc	
	
IF OBJECT_ID(N'tempdb..#pivoted_position_calc', N'U') IS NOT NULL
	DROP TABLE #pivoted_position_calc		
	
IF OBJECT_ID(N'tempdb..#pivoted_position_calc_with_deal_id', N'U') IS NOT NULL
	DROP TABLE #pivoted_position_calc_with_deal_id	
/* Drop temp table end */  
	
IF @flag = 'c'
BEGIN
	CREATE TABLE #position_calc (term_start DATETIME  
		, hr1 FLOAT, hr2 FLOAT, hr3 FLOAT, hr4 FLOAT, hr5 FLOAT, hr6 FLOAT, hr7 FLOAT, hr8 FLOAT, hr9 FLOAT, hr10 FLOAT  
		, hr11 FLOAT, hr12 FLOAT, hr13 FLOAT, hr14 FLOAT, hr15 FLOAT, hr16 FLOAT, hr17 FLOAT, hr18 FLOAT, hr19 FLOAT  
		, hr20 FLOAT, hr21 FLOAT, hr22 FLOAT, hr23 FLOAT, hr24 FLOAT, hr25 FLOAT  
		, add_dst_hour INT, grid INT  
	)  
   
	SET @sql = 'INSERT INTO #position_calc (term_start  
										   , hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10  
										   , hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18, hr19  
										   , hr20, hr21, hr22, hr23, hr24, hr25   
										   , add_dst_hour, grid)  
				SELECT rhpd.term_start  
					  , SUM(rhpd.hr1), SUM(rhpd.hr2), SUM(rhpd.hr3), SUM(rhpd.hr4), SUM(rhpd.hr5)  
					  , SUM(rhpd.hr6), SUM(rhpd.hr7), SUM(rhpd.hr8), SUM(rhpd.hr9), SUM(rhpd.hr10)  
					  , SUM(rhpd.hr11), SUM(rhpd.hr12), SUM(rhpd.hr13), SUM(rhpd.hr14), SUM(rhpd.hr15)  
					  , SUM(rhpd.hr16), SUM(rhpd.hr17), SUM(rhpd.hr18), SUM(rhpd.hr19), SUM(rhpd.hr20)  
					  , SUM(rhpd.hr21), SUM(rhpd.hr22), SUM(rhpd.hr23), SUM(rhpd.hr24), SUM(rhpd.hr25)  
					  , MAX(add_dst_hour), MAX(sdv.value_id)  
				FROM report_hourly_position_deal rhpd
				OUTER APPLY(SELECT add_dst_hour 
							FROM hour_block_term hbt 
							INNER JOIN source_price_curve_def spcd ON hbt.block_define_id = spcd.block_define_id	
								AND hbt.block_type = 12000
								AND spcd.source_curve_def_id = rhpd.curve_id
							WHERE DATEADD(DAY,-1,hbt.term_date) = rhpd.term_start  
							) hbt   
				INNER JOIN source_system_book_map ssbm ON rhpd.source_system_book_id1 = ssbm.source_system_book_id1 
					AND rhpd.source_system_book_id2 = ssbm.source_system_book_id2  
					AND rhpd.source_system_book_id3 = ssbm.source_system_book_id3  
					AND rhpd.source_system_book_id4 = ssbm.source_system_book_id4 
				LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id 
				LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
				INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
					AND sub.entity_name = ''Power''  
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id = rhpd.location_id
				INNER JOIN static_data_value sdv ON sdv.value_id = sml.grid_value_id
					AND sdv.value_id IN (' + @grid + ')  
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = rhpd.curve_id
					AND spcd.curve_name IN(''vP-NL-APX'', ''vP_BE_Belpex'')  
				WHERE rhpd.physical_financial_flag = ''p''  
					AND rhpd.term_start > GETDATE()
					AND rhpd.source_deal_header_id NOT IN (SELECT source_deal_header_id FROM power_bidding_nomination_mapping)
				GROUP BY rhpd.term_start
				UNION ALL  
				SELECT	rhpp.term_start
					  , SUM(rhpp.hr1), SUM(rhpp.hr2), SUM(rhpp.hr3), SUM(rhpp.hr4), SUM(rhpp.hr5)  
					  , SUM(rhpp.hr6), SUM(rhpp.hr7), SUM(rhpp.hr8), SUM(rhpp.hr9), SUM(rhpp.hr10)  
					  , SUM(rhpp.hr11), SUM(rhpp.hr12), SUM(rhpp.hr13), SUM(rhpp.hr14), SUM(rhpp.hr15)  
					  , SUM(rhpp.hr16), SUM(rhpp.hr17), SUM(rhpp.hr18), SUM(rhpp.hr19), SUM(rhpp.hr20)  
					  , SUM(rhpp.hr21), SUM(rhpp.hr22), SUM(rhpp.hr23), SUM(rhpp.hr24), SUM(rhpp.hr25)  
					  , MAX(add_dst_hour) AS add_dst_hour, MAX(sdv.value_id) grid  
				FROM report_hourly_position_profile rhpp
				OUTER APPLY(SELECT add_dst_hour 
							FROM hour_block_term hbt 
							INNER JOIN source_price_curve_def spcd ON hbt.block_define_id = spcd.block_define_id	
								AND hbt.block_type = 12000
								AND spcd.source_curve_def_id = rhpp.curve_id
				   WHERE DATEADD(DAY,-1, hbt.term_date) = rhpp.term_start  
				   ) hbt   
				INNER JOIN source_system_book_map ssbm ON rhpp.source_system_book_id1 = ssbm.source_system_book_id1 
					AND rhpp.source_system_book_id2 = ssbm.source_system_book_id2  
					AND rhpp.source_system_book_id3 = ssbm.source_system_book_id3  
					AND rhpp.source_system_book_id4 = ssbm.source_system_book_id4 
				LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id 
				LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
				INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
					AND sub.entity_name = ''Power''  
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id = rhpp.location_id
				INNER JOIN static_data_value sdv ON sdv.value_id = sml.grid_value_id
					AND sdv.value_id IN (' + @grid + ')  
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = rhpp.curve_id
					AND spcd.curve_name IN(''vP-NL-APX'', ''vP_BE_Belpex'')  
				WHERE rhpp.physical_financial_flag = ''p''  
					AND rhpp.term_start > GETDATE()
					AND rhpp.source_deal_header_id NOT IN (SELECT source_deal_header_id FROM power_bidding_nomination_mapping)  
				GROUP BY rhpp.term_start'  
	EXEC spa_print @sql  
	EXEC(@sql)  
	--SELECT * FROM #position_calc
	
	/*Pivot table*/
	SELECT term_start, REPLACE(Hr, 'hr', '') Hr, total, add_dst_hour, grid
		INTO #pivoted_position_calc
	FROM (SELECT term_start, Hr1, Hr2, (Hr3 - ISNULL(Hr25, 0)) Hr3, Hr4
				, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10
				, Hr11, Hr12, Hr13, Hr14, Hr15
				, Hr16, Hr17, Hr18, Hr19, Hr20
				, Hr21, Hr22, Hr23, Hr24, Hr25, add_dst_hour, grid
			FROM #position_calc
		) p
		UNPIVOT
		(total FOR Hr IN (Hr1, Hr2, Hr3, Hr4, Hr5
						, Hr6, Hr7, Hr8, Hr9, Hr10
						, Hr11, Hr12, Hr13, Hr14, Hr15
						, Hr16, Hr17, Hr18, Hr19, Hr20
						, Hr21, Hr22, Hr23, Hr24, Hr25)
		) AS unpvt

	/* assign deal detail id to variables start */
	DECLARE @tennet_buy_id INT
	DECLARE @tennet_sell_id INT
	DECLARE @elia_buy_id INT
	DECLARE @elia_sell_id INT

	SELECT @tennet_buy_id = source_deal_header_id 
	FROM power_bidding_nomination_mapping  pbnm 
	INNER JOIN static_data_value sdv ON sdv.value_id = pbnm.grid 
	WHERE sdv.code = 'TenneT' AND pbnm.buy_sell_flag = 'b'

	SELECT @tennet_sell_id = source_deal_header_id 
	FROM power_bidding_nomination_mapping  pbnm 
	INNER JOIN static_data_value sdv ON sdv.value_id = pbnm.grid 
	WHERE sdv.code = 'TenneT' AND pbnm.buy_sell_flag = 's'

	SELECT @elia_buy_id = source_deal_header_id 
	FROM power_bidding_nomination_mapping  pbnm 
	INNER JOIN static_data_value sdv ON sdv.value_id = pbnm.grid 
	WHERE sdv.code = 'Elia' AND pbnm.buy_sell_flag = 'b'

	SELECT @elia_sell_id = source_deal_header_id 
	FROM power_bidding_nomination_mapping  pbnm 
	INNER JOIN static_data_value sdv ON sdv.value_id = pbnm.grid 
	WHERE sdv.code = 'Elia' AND pbnm.buy_sell_flag = 's'

	SELECT ppc.*, CASE WHEN sdv.code = 'TenneT' AND total >= 0 THEN @tennet_sell_id 
					WHEN sdv.code = 'TenneT' AND total < 0 THEN @tennet_buy_id 
					WHEN sdv.code = 'Elia' AND total < 0 THEN @elia_buy_id
					ELSE @elia_sell_id END  AS source_deal_header_id
		INTO #pivoted_position_calc_with_deal_id				
	FROM #pivoted_position_calc ppc
	INNER JOIN static_data_value sdv ON sdv.value_id = ppc.grid 

	/* assign deal detail id to variables end */

	/*delete and insert in source_deal_detail_hour start*/
	DELETE sddh FROM source_deal_detail_hour sddh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
	INNER JOIN #pivoted_position_calc_with_deal_id ppcwdi ON sdd.source_deal_header_id = ppcwdi.source_deal_header_id

	--SELECT DISTINCT source_deal_header_id FROM #pivoted_position_calc_with_deal_id
	--SELECT	sdd.source_deal_detail_id,
	--		fdc.term_start,
	--		CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN CASE WHEN mv.id IS NOT NULL THEN 3 ELSE 21 END ELSE fdc.Hr END [hr],
	--		CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN 1 ELSE 0 END AS [is_dst],
	--		SUM(fdc.total) [volume],
	--		NULL AS [price],
	--		NULL AS [formula_id]
	--FROM #pivoted_position_calc_with_deal_id fdc
	--INNER JOIN source_deal_detail sdd ON 
	--	YEAR(sdd.term_start) = YEAR(fdc.term_start)
	--	AND MONTH(sdd.term_start) = MONTH(fdc.term_start) 
	--	AND fdc.source_deal_header_id = sdd.source_deal_header_id 
	--LEFT JOIN mv90_DST mv ON mv.date = fdc.term_start	
	--	AND mv.insert_delete = 'i' 
	--LEFT JOIN mv90_DST mv1 ON mv1.date = DATEADD(DAY,1,fdc.term_start)
	--	AND mv1.insert_delete = 'i'
	--WHERE ((add_dst_hour > 0 AND fdc.Hr = 25) OR (fdc.Hr <> 25))
	--GROUP BY sdd.source_deal_detail_id,
	--		fdc.term_start,
	--		CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN CASE WHEN mv.id IS NOT NULL THEN 3 ELSE 21 END ELSE fdc.Hr END,
	--		CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN 1 ELSE 0 END
	--ORDER BY fdc.term_start	
	
	
	INSERT INTO source_deal_detail_hour(source_deal_detail_id, term_date, hr, is_dst, volume, price, formula_id)
	SELECT	sdd.source_deal_detail_id,
			fdc.term_start,
			CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN CASE WHEN mv.id IS NOT NULL THEN 3 ELSE 21 END ELSE fdc.Hr END [hr],
			CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN 1 ELSE 0 END AS [is_dst],
			SUM(fdc.total) [volume],
			NULL AS [price],
			NULL AS [formula_id]
	FROM #pivoted_position_calc_with_deal_id fdc
	INNER JOIN source_deal_detail sdd ON 
		YEAR(sdd.term_start) = YEAR(fdc.term_start)
		AND MONTH(sdd.term_start) = MONTH(fdc.term_start) 
		AND fdc.source_deal_header_id = sdd.source_deal_header_id 
	LEFT JOIN mv90_DST mv ON mv.date = fdc.term_start	
		AND mv.insert_delete = 'i' 
	LEFT JOIN mv90_DST mv1 ON mv1.date = DATEADD(DAY,1,fdc.term_start)
		AND mv1.insert_delete = 'i'
	WHERE ((add_dst_hour > 0 AND fdc.Hr = 25) OR (fdc.Hr <> 25))
	GROUP BY sdd.source_deal_detail_id,
			fdc.term_start,
			CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN CASE WHEN mv.id IS NOT NULL THEN 3 ELSE 21 END ELSE fdc.Hr END,
			CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN 1 ELSE 0 END
	ORDER BY fdc.term_start	
	/*delete and insert in source_deal_detail_hour start*/

	--######## Calculate the Position

	DECLARE @spa VARCHAR(MAX)
	DECLARE	@job_name VARCHAR(150)
	
	DECLARE	@effected_deals VARCHAR(150)
	DECLARE	@st VARCHAR(MAX)
	DECLARE	@process_id VARCHAR(100) 

	SET @user_login_id = dbo.FNADBUser()
	SET @process_id = dbo.FNAGetNewID()
	SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
	SET @st = 'CREATE TABLE ' + @effected_deals + '(source_deal_header_id INT, [action] VARCHAR(1)) '
	exec spa_print @st
	EXEC(@st)

	--Change here to select the required deals
	SET @st = 'INSERT INTO ' + @effected_deals  
				+ ' SELECT DISTINCT ppcwdid.source_deal_header_id, ''u'' 
				FROM  #pivoted_position_calc_with_deal_id ppcwdid'
	exec spa_print @st
	EXEC(@st)

	SET @job_name = 'calc_power_nomination' + @process_id
	EXEC [dbo].[spa_deal_position_breakdown] 'i', NULL, @user_login_id, @process_id
	SET @spa = 'spa_update_deal_total_volume NULL, ''' + @process_id + ''', 0, 1, ''' + @user_login_id + ''''	
	EXEC spa_print @spa
	EXEC (@spa)
END	
ELSE IF @flag = 's'
BEGIN
	DECLARE @sql_select VARCHAR(MAX)  
	
	IF @include_financial = 'true'  
	BEGIN  
		CREATE TABLE #position_calc_financial (term_start DATETIME  
				, hr1 FLOAT, hr2 FLOAT, hr3 FLOAT, hr4 FLOAT, hr5 FLOAT, hr6 FLOAT, hr7 FLOAT, hr8 FLOAT, hr9 FLOAT, hr10 FLOAT  
				, hr11 FLOAT, hr12 FLOAT, hr13 FLOAT, hr14 FLOAT, hr15 FLOAT, hr16 FLOAT, hr17 FLOAT, hr18 FLOAT, hr19 FLOAT  
				, hr20 FLOAT, hr21 FLOAT, hr22 FLOAT, hr23 FLOAT, hr24 FLOAT, hr25 FLOAT  
				, add_dst_hour INT, grid INT  
				)  
		SET @sql = 'INSERT INTO #position_calc_financial (term_start  
														, hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10  
														, hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18, hr19  
														, hr20, hr21, hr22, hr23, hr24, hr25   
														, add_dst_hour, grid)  
					 SELECT rhpd.term_start  
						   , SUM(rhpd.hr1), SUM(rhpd.hr2), SUM(rhpd.hr3), SUM(rhpd.hr4), SUM(rhpd.hr5)  
						   , SUM(rhpd.hr6), SUM(rhpd.hr7), SUM(rhpd.hr8), SUM(rhpd.hr9), SUM(rhpd.hr10)  
						   , SUM(rhpd.hr11), SUM(rhpd.hr12), SUM(rhpd.hr13), SUM(rhpd.hr14), SUM(rhpd.hr15)  
						   , SUM(rhpd.hr16), SUM(rhpd.hr17), SUM(rhpd.hr18), SUM(rhpd.hr19), SUM(rhpd.hr20)  
						   , SUM(rhpd.hr21), SUM(rhpd.hr22), SUM(rhpd.hr23), SUM(rhpd.hr24), SUM(rhpd.hr25)  
						   , MAX(add_dst_hour), MAX(sdv.value_id)  
					FROM report_hourly_position_deal rhpd 
					OUTER APPLY(SELECT add_dst_hour 
								FROM hour_block_term hbt 
								INNER JOIN source_price_curve_def spcd ON hbt.block_define_id = spcd.block_define_id	
									AND hbt.block_type = 12000
									AND spcd.source_curve_def_id = rhpd.curve_id 
								WHERE DATEADD(DAY,-1, hbt.term_date) = rhpd.term_start) hbt
					 INNER JOIN source_system_book_map ssbm ON rhpd.source_system_book_id1 = ssbm.source_system_book_id1   
						 AND rhpd.source_system_book_id2 = ssbm.source_system_book_id2    
						 AND rhpd.source_system_book_id3 = ssbm.source_system_book_id3    
						 AND rhpd.source_system_book_id4 = ssbm.source_system_book_id4   
					 LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id   
					 LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id   
					 INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id   
						AND sub.entity_name = ''Power''  
					 INNER JOIN source_minor_location sml ON sml.source_minor_location_id = rhpd.location_id  
					 INNER JOIN static_data_value sdv ON sdv.value_id = sml.grid_value_id  
						AND sdv.value_id IN (' + @grid + ')  
					 INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = rhpd.curve_id  
						AND spcd.curve_name IN(''vP-NL-APX'', ''vP_BE_Belpex'')  
					 WHERE rhpd.physical_financial_flag = ''f''  
						AND rhpd.term_start > GETDATE()  
						AND rhpd.source_deal_header_id NOT IN (SELECT source_deal_header_id FROM power_bidding_nomination_mapping)  
					 GROUP BY rhpd.term_start  
					 --UNION ALL  
					 --SELECT rhpp.term_start  
					 --  , SUM(rhpp.hr1), SUM(rhpp.hr2), SUM(rhpp.hr3), SUM(rhpp.hr4), SUM(rhpp.hr5)  
					 --  , SUM(rhpp.hr6), SUM(rhpp.hr7), SUM(rhpp.hr8), SUM(rhpp.hr9), SUM(rhpp.hr10)  
					 --  , SUM(rhpp.hr11), SUM(rhpp.hr12), SUM(rhpp.hr13), SUM(rhpp.hr14), SUM(rhpp.hr15)  
					 --  , SUM(rhpp.hr16), SUM(rhpp.hr17), SUM(rhpp.hr18), SUM(rhpp.hr19), SUM(rhpp.hr20)  
					 --  , SUM(rhpp.hr21), SUM(rhpp.hr22), SUM(rhpp.hr23), SUM(rhpp.hr24), SUM(rhpp.hr25)  
					 --  , MAX(add_dst_hour) AS add_dst_hour, MAX(sdv.value_id) grid  
					 --FROM report_hourly_position_profile rhpp  
					 --OUTER APPLY(SELECT add_dst_hour   
					 --   FROM hour_block_term hbt   
					 --   INNER JOIN source_price_curve_def spcd ON hbt.block_define_id = spcd.block_define_id   
					 --    AND hbt.block_type = 12000  AND spcd.source_curve_def_id = rhpp.curve_id
					 --   WHERE DATEADD(DAY,-1, hbt.term_date) = rhpp.term_start) hbt   
					 --INNER JOIN source_system_book_map ssbm ON rhpp.source_system_book_id1 = ssbm.source_system_book_id1   
					 -- AND rhpp.source_system_book_id2 = ssbm.source_system_book_id2    
					 -- AND rhpp.source_system_book_id3 = ssbm.source_system_book_id3    
					 -- AND rhpp.source_system_book_id4 = ssbm.source_system_book_id4   
					 --LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id   
					 --LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id   
					 --INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id   
					 -- AND sub.entity_name = ''Power''  
					 --INNER JOIN source_minor_location sml ON sml.source_minor_location_id = rhpp.location_id  
					 --INNER JOIN static_data_value sdv ON sdv.value_id = sml.grid_value_id  
					 -- AND sdv.value_id IN (' + @grid + ')  
					 --INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = rhpp.curve_id  
					 -- AND spcd.curve_name IN(''vP-NL-APX'', ''vP_BE_Belpex'')  
					 --WHERE rhpp.physical_financial_flag = ''f''  
					 -- AND rhpp.term_start > GETDATE()  
					 -- AND rhpp.source_deal_header_id NOT IN (SELECT source_deal_header_id FROM power_bidding_nomination_mapping)  
					 --GROUP BY rhpp.term_start  
					 '  
		EXEC spa_print @sql  
		EXEC(@sql)  

		SELECT term_start, REPLACE(Hr, 'hr', '') Hr, total, add_dst_hour, grid  
			INTO #pivoted_position_calc_financial  
		FROM (SELECT term_start, Hr1, Hr2, (Hr3 - ISNULL(Hr25, 0)) Hr3, Hr4  
			 , Hr5, Hr6, Hr7, Hr8, Hr9, Hr10  
			 , Hr11, Hr12, Hr13, Hr14, Hr15  
			 , Hr16, Hr17, Hr18, Hr19, Hr20  
			 , Hr21, Hr22, Hr23, Hr24, Hr25, add_dst_hour, grid  
		FROM #position_calc_financial  
		) p  
		UNPIVOT  
		(total FOR Hr IN (Hr1, Hr2, Hr3, Hr4, Hr5  
		   , Hr6, Hr7, Hr8, Hr9, Hr10  
		   , Hr11, Hr12, Hr13, Hr14, Hr15  
		   , Hr16, Hr17, Hr18, Hr19, Hr20  
		   , Hr21, Hr22, Hr23, Hr24, Hr25)  
		) AS unpvt  


		SELECT fdc.term_start,  
				CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN CASE WHEN mv.id IS NOT NULL THEN 3 ELSE 21 END ELSE fdc.Hr END [hr],  
				SUM(fdc.total) [volume]  
			INTO #position_calc_financial_final      
		FROM #pivoted_position_calc_financial fdc  
		LEFT JOIN mv90_DST mv ON mv.date = fdc.term_start   
			AND mv.insert_delete = 'i'   
		LEFT JOIN mv90_DST mv1 ON mv1.date = DATEADD(DAY,1,fdc.term_start)  
			AND mv1.insert_delete = 'i'  
		WHERE ((add_dst_hour > 0 AND fdc.Hr = 25) OR (fdc.Hr <> 25))  
		GROUP BY fdc.term_start,  
			CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN CASE WHEN mv.id IS NOT NULL THEN 3 ELSE 21 END ELSE fdc.Hr END,  
			CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN 1 ELSE 0 END  
		ORDER BY fdc.term_start  
	END   
   
	CREATE TABLE #collect_deals_from_power_bidding_nomaination (source_deal_header_id INT , term_start DATETIME  
																, hr1 FLOAT, hr2 FLOAT, hr3 FLOAT, hr4 FLOAT, hr5 FLOAT, hr6 FLOAT, hr7 FLOAT, hr8 FLOAT, hr9 FLOAT, hr10 FLOAT  
																, hr11 FLOAT, hr12 FLOAT, hr13 FLOAT, hr14 FLOAT, hr15 FLOAT, hr16 FLOAT, hr17 FLOAT, hr18 FLOAT, hr19 FLOAT  
																, hr20 FLOAT, hr21 FLOAT, hr22 FLOAT, hr23 FLOAT, hr24 FLOAT, hr25 FLOAT  
																, add_dst_hour INT)  

	SET @sql = 'INSERT INTO #collect_deals_from_power_bidding_nomaination (source_deal_header_id, term_start  
																		   , hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10  
																		   , hr11, hr12, hr13, hr14, hr15, hr16, hr17, hr18, hr19  
																		   , hr20, hr21, hr22, hr23, hr24, hr25   
																		   , add_dst_hour)  
				SELECT source_deal_header_id, rhpd.term_start  
					  , SUM(rhpd.hr1), SUM(rhpd.hr2), SUM(rhpd.hr3), SUM(rhpd.hr4), SUM(rhpd.hr5)  
					  , SUM(rhpd.hr6), SUM(rhpd.hr7), SUM(rhpd.hr8), SUM(rhpd.hr9), SUM(rhpd.hr10)  
					  , SUM(rhpd.hr11), SUM(rhpd.hr12), SUM(rhpd.hr13), SUM(rhpd.hr14), SUM(rhpd.hr15)  
					  , SUM(rhpd.hr16), SUM(rhpd.hr17), SUM(rhpd.hr18), SUM(rhpd.hr19), SUM(rhpd.hr20)  
					  , SUM(rhpd.hr21), SUM(rhpd.hr22), SUM(rhpd.hr23), SUM(rhpd.hr24), SUM(rhpd.hr25)  
					  , MAX(add_dst_hour)  
				FROM report_hourly_position_deal rhpd   
				OUTER APPLY(SELECT add_dst_hour   
							FROM hour_block_term hbt   
							INNER JOIN source_price_curve_def spcd ON hbt.block_define_id = spcd.block_define_id 
								AND hbt.block_type = 12000  
								AND spcd.source_curve_def_id = rhpd.curve_id
							WHERE DATEADD(DAY,-1, hbt.term_date) = rhpd.term_start  
							) hbt  
				WHERE 1 = 1 AND rhpd.source_deal_header_id IN (SELECT source_deal_header_id FROM power_bidding_nomination_mapping)'   
      
    IF @date_from IS NOT NULL AND @date_to IS NOT NULL  
		SET @sql = @sql + ' AND rhpd.term_start BETWEEN  ''' + CAST(@date_from AS VARCHAR(12)) + ''' AND ''' +  CAST(@date_to AS VARCHAR(12)) + ''''   
       
    SET @sql = @sql + ' GROUP BY term_start, source_deal_header_id  
						UNION ALL
						SELECT source_deal_header_id, term_start
								, SUM(hr1), SUM(hr2), SUM(hr3), SUM(hr4), SUM(hr5), SUM(hr6), SUM(hr7), SUM(hr8), SUM(hr9), SUM(hr10)
								, SUM(hr11), SUM(hr12), SUM(hr13), SUM(hr14), SUM(hr15), SUM(hr16), SUM(hr17), SUM(hr18), SUM(hr19)
								, SUM(hr20), SUM(hr21), SUM(hr22), SUM(hr23), SUM(hr24), SUM(hr25) 
								, MAX(add_dst_hour)
						FROM report_hourly_position_profile rhpp 
						OUTER APPLY(SELECT add_dst_hour 
									FROM hour_block_term hbt 
									INNER JOIN source_price_curve_def spcd ON hbt.block_define_id = spcd.block_define_id	
										AND hbt.block_type = 12000
										AND spcd.source_curve_def_id = rhpp.curve_id
						   WHERE DATEADD(DAY,-1, hbt.term_date) = rhpp.term_start  
						   ) hbt  
						WHERE rhpp.source_deal_header_id IN (SELECT source_deal_header_id FROM power_bidding_nomination_mapping)'   

	IF @date_from IS NOT NULL AND @date_to IS NOT NULL  
		SET @sql = @sql + ' AND rhpp.term_start BETWEEN  ''' + CAST(@date_from AS VARCHAR(12)) + ''' AND ''' +  CAST(@date_to AS VARCHAR(12)) + ''''   

	SET @sql = @sql + ' GROUP BY term_start, source_deal_header_id'  
	EXEC spa_print @sql  
	EXEC(@sql)  
 	
	/*Pivot the data start*/  
	SELECT term_start, REPLACE(Hr, 'hr', '') Hr, total, add_dst_hour,source_deal_header_id
		INTO #collect_deals_from_power_bidding_nomaination_pivot
	FROM (SELECT term_start, Hr1, Hr2, (Hr3 - ISNULL(Hr25, 0)) Hr3, Hr4
				, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10
				, Hr11, Hr12, Hr13, Hr14, Hr15
				, Hr16, Hr17, Hr18, Hr19, Hr20
				, Hr21, Hr22, Hr23, Hr24, Hr25, add_dst_hour, source_deal_header_id 
			FROM #collect_deals_from_power_bidding_nomaination
		) p
	UNPIVOT
		(total FOR Hr IN (Hr1, Hr2, Hr3, Hr4, Hr5
						, Hr6, Hr7, Hr8, Hr9, Hr10
						, Hr11, Hr12, Hr13, Hr14, Hr15
						, Hr16, Hr17, Hr18, Hr19, Hr20
						, Hr21, Hr22, Hr23, Hr24, Hr25)
		) AS unpvt
 	/*calc dst*/
	CREATE TABLE #collect_deals_from_power_bidding_nomaination_dst (source_deal_header_id INT , term_start DATETIME, Hr INT, volume FLOAT, grid INT)  
	SET @sql = 'INSERT INTO #collect_deals_from_power_bidding_nomaination_dst (source_deal_header_id, term_start, Hr, volume, grid)  
				SELECT fdc.source_deal_header_id,        fdc.term_start,  
						CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN CASE WHEN mv.id IS NOT NULL THEN 3 ELSE 21 END ELSE fdc.Hr END [hr],
						SUM(fdc.total) [volume], MAX(pbnm.grid) grid  
				FROM #collect_deals_from_power_bidding_nomaination_pivot fdc
				LEFT JOIN power_bidding_nomination_mapping pbnm ON pbnm.source_deal_header_id = fdc.source_deal_header_id  
				LEFT JOIN mv90_DST mv ON mv.date = fdc.term_start	
					AND mv.insert_delete = ''i''  
				LEFT JOIN mv90_DST mv1 ON mv1.date = DATEADD(DAY,1,fdc.term_start)
					AND mv1.insert_delete = ''i''  
				WHERE ((add_dst_hour > 0 AND fdc.Hr = 25) OR (fdc.Hr <> 25)) AND 1 = 1'  
   
	IF @grid IS NOT NULL  
		SET @sql = @sql + ' AND pbnm.grid = ' + @grid  

	SET @sql = @sql + ' GROUP BY fdc.source_deal_header_id,  
						fdc.term_start,
						CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN CASE WHEN mv.id IS NOT NULL THEN 3 ELSE 21 END ELSE fdc.Hr END,
						CASE WHEN add_dst_hour > 0 AND fdc.Hr = 25 AND ISNULL(mv.id,mv1.id) IS NOT NULL THEN 1 ELSE 0 END
						ORDER BY fdc.term_start '  

	EXEC spa_print @sql  
	EXEC(@sql)  

	SET @sql_select = ''  

	IF @place_order = 'true'  
		SET @sql_select = 'SELECT cdfpbnd.hr AS [APX Order]'  
	ELSE  
		SET @sql_select = 'SELECT dbo.FNAdateformat(cdfpbnd.term_start) AS [Term Start], cdfpbnd.hr AS [APX Order]'  

	IF @buy_sell = 'b'  
		SET @sql_select = @sql_select + ', MIN(ABS(ISNULL(CASE WHEN cdfpbnd.volume < 0 THEN cdfpbnd.volume END, 0.0))) AS [MW Buy], 3000 AS [Buy Price]'  
	ELSE IF @buy_sell = 's'  
		SET @sql_select = @sql_select + ', MIN(ISNULL(CASE WHEN cdfpbnd.volume > 0 THEN cdfpbnd.volume END, 0.0)) AS [MW Sell], -3000 AS [Sell Price]'  
	ELSE  
		SET @sql_select = @sql_select + ', MIN(ABS(ISNULL(CASE WHEN cdfpbnd.volume < 0 THEN cdfpbnd.volume END, 0.0))) AS [MW Buy], 3000 AS [Buy Price]  
							, MIN(ISNULL(CASE WHEN cdfpbnd.volume > 0 THEN cdfpbnd.volume END, 0.0)) AS [MW Sell], -3000 AS [Sell Price]'  

	IF @include_financial = 'true'   
		SET @sql_select = @sql_select + ', MIN(ISNULL(pcff.volume, 0.0)) AS [Financial]'  
	

	IF @show_totals = 'true'  
	BEGIN  
		IF @include_financial = 'true'  
			SET @sql_select = @sql_select + ', MIN(ABS(ISNULL(CASE WHEN cdfpbnd.volume < 0 THEN cdfpbnd.volume END, 0))) + MIN(ISNULL(CASE WHEN cdfpbnd.volume > 0 THEN cdfpbnd.volume END, 0) * -1) + MIN(ISNULL(pcff.volume, 0)) AS [Total]'  
		ELSE  
			SET @sql_select = @sql_select + ', MIN(ABS(ISNULL(CASE WHEN cdfpbnd.volume < 0 THEN cdfpbnd.volume END, 0))) + MIN(ISNULL(CASE WHEN cdfpbnd.volume > 0 THEN cdfpbnd.volume END, 0) * -1) AS [Total]'   
	END  
	
	SET @sql = @sql_select + @str_batch_table + ' FROM #collect_deals_from_power_bidding_nomaination_dst cdfpbnd'  
	  
	IF @include_financial = 'true'  
	SET @sql = @sql + ' LEFT JOIN #position_calc_financial_final pcff ON pcff.term_start = cdfpbnd.term_start  
				AND pcff.hr = cdfpbnd.hr'  
	     
	SET @sql = @sql + ' WHERE cdfpbnd.volume <> 0  
					  GROUP BY cdfpbnd.term_start, cdfpbnd.hr  
					  ORDER BY cdfpbnd.term_start, cdfpbnd.hr'  
	EXEC spa_print @sql  
	EXEC(@sql)  
END  
ELSE IF @flag = 'x' --copy  
BEGIN  
	SET @sql = 'DELETE sddh FROM source_deal_detail_hour sddh  
				INNER JOIN source_deal_detail sdd ON  sddh.source_deal_detail_id = sdd.source_deal_detail_id  
				INNER JOIN power_bidding_nomination_mapping pbnm ON sdd.source_deal_header_id = pbnm.source_deal_header_id_copy  
				AND pbnm.grid IN (' + @grid + ')  
				AND sddh.term_date BETWEEN ''' + CAST(@date_from AS VARCHAR(12)) + ''' AND ''' + CAST(@date_to AS VARCHAR(12)) + ''''   
	EXEC spa_print @sql  
	EXEC(@sql)  

	SET @sql = 'INSERT INTO source_deal_detail_hour(source_deal_detail_id, term_date, hr, is_dst, volume, price, formula_id)  
				SELECT destination_table.source_deal_detail_id, source_table.term_date, source_table.hr, source_table.is_dst, source_table.volume, NULL, NULL  
				FROM (SELECT sdd.source_deal_header_id, pbnm.source_deal_header_id_copy, sddh.source_deal_detail_id  
						, sddh.term_date, sdd.term_start, sddh.volume, sddh.hr, sddh.is_dst  
						FROM source_deal_detail_hour sddh  
						INNER JOIN source_deal_detail sdd ON  sddh.source_deal_detail_id = sdd.source_deal_detail_id  
						INNER JOIN power_bidding_nomination_mapping pbnm ON sdd.source_deal_header_id = pbnm.source_deal_header_id  
						AND pbnm.grid IN (' + @grid + ')  
						AND sddh.term_date BETWEEN ''' + CAST(@date_from AS VARCHAR(12)) + ''' AND ''' + CAST(@date_to AS VARCHAR(12)) + '''  
						) source_table   
				INNER JOIN (SELECT pbnm.source_deal_header_id, pbnm.source_deal_header_id_copy, sdd.term_start, sdd.source_deal_detail_id   
							FROM power_bidding_nomination_mapping pbnm  
							INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = pbnm.source_deal_header_id_copy  
							AND pbnm.grid IN (' + @grid + ')  
							) destination_table ON source_table.source_deal_header_id_copy = destination_table.source_deal_header_id_copy   
					AND source_table.term_start = destination_table.term_start'  

	EXEC spa_print @sql  
	EXEC(@sql)  

	SET @user_login_id = dbo.FNADBUser()  
	SET @process_id = dbo.FNAGetNewID()  
	SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)  
	SET @st = 'CREATE TABLE ' + @effected_deals + '(source_deal_header_id INT, [action] VARCHAR(1)) '  
	exec spa_print @st  
	EXEC(@st)  
	--Change here to select the required deals  
	SET @st = 'INSERT INTO ' + @effected_deals    
				+ ' SELECT source_deal_header_id_copy, ''u''  
				FROM power_bidding_nomination_mapping WHERE grid IN (' + @grid + ')'  
	exec spa_print @st  
	EXEC(@st)  

	SET @job_name = 'calc_power_nomination' + @process_id  
	EXEC [dbo].[spa_deal_position_breakdown] 'i', NULL, @user_login_id, @process_id  
	SET @spa = 'spa_update_deal_total_volume NULL, ''' + @process_id + ''', 0, 1, ''' + @user_login_id + ''''   
	EXEC spa_print @spa  
	EXEC (@spa)  
END
/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@str_batch_table)

   SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_power_bidding_nomination', '') --TODO: modify sp and report name  
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