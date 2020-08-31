IF OBJECT_ID(N'[dbo].[spa_calc_margin]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_calc_margin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Author: Runaj Khatiwada
-- Create date: 2016-09-21
-- Description: This proc will be used to perform insert in source_counterparty_margin table.
-- Params:
-- @flag CHAR(1) - Operation flag 
--		flags used:	'i'	--> 
-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_calc_margin]
    @flag CHAR(1),
	@counterparty_id INT ,
	@contract_id INT ,
	@product_id INT ,
	@as_of_date DATETIME,
	@batch_process_id	VARCHAR(120) = NULL, 
	@batch_report_param	VARCHAR(5000) = NULL

/**
-- FOR DEBUGGING
DECLARE 
	@flag CHAR(1) = 'i',
	@counterparty_id INT = 4236 ,
	@contract_id INT = 9927 ,
	@product_id INT = 50000536,
	@as_of_date DATETIME = '2018-07-02'
	--@as_of_date_to DATETIME = '2018-07-02'
	

	IF OBJECT_ID('tempdb..#collect_deals') IS NOT NULL
		DROP TABLE #collect_deals

	IF OBJECT_ID('tempdb..#collect_margin_process_header') IS NOT NULL
		DROP TABLE #collect_margin_process_header

	IF OBJECT_ID('tempdb..#temp_calc_1') IS NOT NULL
		DROP TABLE #temp_calc_1

	IF OBJECT_ID('tempdb..#temp_calc_2') IS NOT NULL
		DROP TABLE #temp_calc_2
	
	IF OBJECT_ID('tempdb..#temp_calc_3') IS NOT NULL
		DROP TABLE #temp_calc_3

	IF OBJECT_ID('tempdb..#temp_calc_4') IS NOT NULL
		DROP TABLE #temp_calc_4

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp

	IF OBJECT_ID('tempdb..#temp_d') IS NOT NULL
		DROP TABLE #temp_d

--**/
		
AS
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX) = NULL
	   , @user_login_id VARCHAR(100)
	   , @end_time_sec INT 
	   , @Conv_time_min_sec  VARCHAR(100)
	   , @desc VARCHAR(500)
	   , @begin_time DATETIME

	SET @begin_time = GETDATE()
	IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
	BEGIN
		DECLARE @str_batch_table VARCHAR(MAX) = ''
		   , @temp_table_name VARCHAR(200) = ''
		   , @job_name VARCHAR(100)

		IF (@batch_process_id IS NULL)
		 SET @batch_process_id = REPLACE(NEWID(), '-', '_')
	END

IF @flag = 'i'
BEGIN

	--
	CREATE TABLE #collect_deals
	(
		source_deal_header_id INT 
	)
	-- Collect deals 
	INSERT INTO  #collect_deals
	SELECT uddf.source_deal_header_id
		FROM user_defined_deal_fields_template_main udftm
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.field_name = udftm.field_name
		INNER JOIN user_defined_deal_fields uddf
			ON udftm.udf_template_id = uddft.udf_template_id
				AND udftm.Field_label = 'Margin Product'
		INNER JOIN source_deal_header sdh  ON sdh.source_deal_header_id = uddf.source_deal_header_id
	WHERE uddf.udf_value = CAST(@product_id AS VARCHAR(50))
	AND sdh.counterparty_id = @counterparty_id and sdh.contract_id = @contract_id 
	GROUP BY uddf.source_deal_header_id

 	
	CREATE TABLE #collect_margin_process_header (
		process_margin_header_id INT
		, counterparty_id INT
		, contract_id INT
		, product_id INT
	)	
	
	-- Collect margin process header info
	INSERT INTO #collect_margin_process_header
	SELECT process_margin_header_id
		, counterparty_id
		, contract_id
		, product_id
		FROM process_margin_header pmh 
		WHERE  pmh.counterparty_id = @counterparty_id
		    AND pmh.contract_id = @contract_id 
	
	CREATE TABLE #temp_d
	(
		dt DATETIME 
	)

    -- Collect  as of date passed
    INSERT INTO #temp_d (dt) VALUES(@as_of_date) 

	
	CREATE TABLE #temp
	(
		dt DATETIME ,
		source_deal_header_id INT 
	)

    -- Collects date with its deals
	INSERT INTO #temp 
	SELECT td1.dt, cd.source_deal_header_id FROM #collect_deals cd 
	CROSS APPLY 
	 ( 
		SELECT * FROM #temp_d td 
	  
	 ) td1

	
	--SELECT @as_of_date 
	--SELECT DATEADD(DAY, n-2 , @as_of_date) dt INTO #temp
	--FROM seq
	--WHERE  DATEADD(DAY, n-1 , @as_of_date) <= @as_of_date+ 1

	
	CREATE TABLE #temp_calc_1 (
		  id INT IDENTITY(1,1)
		, as_of_date	datetime
		, clearing_counterparty_id	int
		, margin_contract_id	int
		, margin_account	NUMERIC(38,17)
		, mtmt_t0	NUMERIC(38,17)
		, mtmt_t1	NUMERIC(38,17)
		, delta_mtm	NUMERIC(38,17)
		, margin_call_price	NUMERIC(38,17)
		, maintenance_margin_amount	NUMERIC(38,17)
		, additional_margin	NUMERIC(38,17)
		, current_portfolio_value	NUMERIC(38,17)
		, maintenance_margin_required	NUMERIC(38,17)
		, margin_call_amt	NUMERIC(38,17) 
		, margin_excess	NUMERIC(38,17)
		, deal_volume	NUMERIC(38,17)
		, total_initial_margin	NUMERIC(38,17)
		, total_maintenance_margin	NUMERIC(38,17)
		, deal_price	NUMERIC(38,17)
		, curve_value1	NUMERIC(38,17)
		, curve_value2	NUMERIC(38,17)
		, source_deal_header_id	INT
		, product_id int
		, margin_account_balc NUMERIC(38, 17) 
		, beg_balc NUMERIC(38, 17) 
		, end_balc NUMERIC(38, 17) 
		, previous_as_of_date DATETIME

	)
	
  INSERT INTO #temp_calc_1  
	SELECT 
		   mtm.as_of_date
		  , pmd.counterparty_id
		  , pmd.contract_id
		  , NULL margin_account
		  , mtm.mtm_t0
		  , mtm.mtm_t1
		  , mtm.delta_mtm
		  , NULL margin_call_price
		  , NULL maintenance_margin_amount
		  , NULL  additional_margin 
		  , ABS(mtm.contract_value) [notional_amount] -- current_portfolio_value
		  , NULL maintenance_margin_required
		  , NULL margin_call_amt
		  , NULL margin_excess
		  , ABS(mtm.deal_volume) deal_volume -- deal Volume
		  , CASE 
				WHEN pmd.initial_margin_per IS NULL 
					THEN (mtm.deal_volume / pmd.lot_size) * pmd.initial_margin 
					ELSE (ABS(mtm.contract_value) * pmd.initial_margin_per) 
			END [total_intial_margin] 
		  , CASE 
				WHEN pmd.maintenance_margin_per IS NULL 
					THEN (mtm.deal_volume / pmd.lot_size) * pmd.maintenance_margin 
						ELSE (
						CASE
							WHEN pmd.initial_margin_per IS NULL 
								THEN (mtm.deal_volume / pmd.lot_size) * pmd.initial_margin 
							ELSE (ABS(mtm.contract_value) * pmd.initial_margin_per) 
						END * pmd.maintenance_margin_per)
		    END total_maintenance_margin
			, (mtm.fixed_price + mtm.formula_value1 + mtm.price_adder) * mtm.price_multiplier [deal_price]
			, mtm.curve_value1
			, mtm.curve_value2
			, mtm.source_deal_header_id
			, pmd.product_id
			, NULL margin_account_balc
			, NULL beg_balc
			, NULL end_balc
			, mtm.previous_as_of_date
	FROM   (
			   SELECT dt.dt  as_of_date
					  , ISNULL(t0.mtm_t0, 0) mtm_t0
					  , ISNULL(t1.mtm_t1, 0) mtm_t1
					  , (ISNULL(t1.mtm_t1, 0) - ISNULL(t0.mtm_t0, 0)) AS delta_mtm
					  , ISNULL(sdp_pnl.contract_value, 0) [contract_value]
					  , ISNULL(sdp_pnl1.deal_volume,0) deal_volume
					  , ISNULL(sdpd_pnl.fixed_price, 0) [fixed_price]
					  , ISNULL(sdpd_pnl.price_adder, 0) price_adder
					  , ISNULL(sdpd_pnl.price_multiplier, 0) price_multiplier
					  , ISNULL(cur1.formula_value1, 0) [formula_value1]
					  , ISNULL(cur2.formula_value2, 0) [formula_value2]
					  , ISNULL(cur1.curve_value1, 0) [curve_value1] 
					  , ISNUll(cur2.curve_value2, 0) [Curve_value2]
					  , cd.source_deal_header_id
					  , dt.dt-1 [previous_as_of_date]
			   FROM   #temp dt
			   CROSS APPLY(
				   SELECT SUM(und_pnl) mtm_t0
				   FROM   source_deal_pnl sdp
						  INNER JOIN #collect_deals di
							   ON  di.source_deal_header_id = sdp.source_deal_header_id
				   WHERE  sdp.pnl_as_of_date = dt.dt-1  AND sdp.source_deal_header_id = dt.source_deal_header_id
			   ) t0
			   CROSS APPLY(
				   SELECT SUM(und_pnl) mtm_t1
				   FROM   source_deal_pnl sdp
						  INNER JOIN #collect_deals di
							   ON  di.source_deal_header_id = sdp.source_deal_header_id
				   WHERE  sdp.pnl_as_of_date = dt.dt AND sdp.source_deal_header_id = dt.source_deal_header_id
			   )   t1
			    CROSS APPLY(
				   SELECT  SUM(sdp.contract_value) contract_value
				   FROM   source_deal_pnl sdp
						  INNER JOIN #collect_deals di
							   ON  di.source_deal_header_id = sdp.source_deal_header_id
				   WHERE  sdp.pnl_as_of_date = dt.dt AND sdp.source_deal_header_id = dt.source_deal_header_id
			   )   sdp_pnl
			    CROSS APPLY(
				   SELECT SUM(sdp1.deal_volume) deal_volume
				   FROM   source_deal_pnl sdp1
						  INNER JOIN #collect_deals di
							   ON  di.source_deal_header_id = sdp1.source_deal_header_id
				   WHERE  sdp1.pnl_as_of_date = dt.dt AND sdp1.source_deal_header_id = dt.source_deal_header_id
			   )   sdp_pnl1
			   CROSS APPLY (
				  SELECT  sdpd.fixed_price, sdpd.price_adder, sdpd.price_multiplier
				  FROM  source_deal_pnl_detail sdpd
						INNER JOIN #collect_deals di
						ON  di.source_deal_header_id = sdpd.source_deal_header_id
						 WHERE  sdpd.pnl_as_of_date = dt.dt AND sdpd.source_deal_header_id = dt.source_deal_header_id
			   ) sdpd_pnl
			   CROSS APPLY (
				  SELECT  sdpd.curve_value [curve_value1],  sdpd.formula_value [formula_value1]
				  FROM  source_deal_pnl_detail sdpd
						INNER JOIN #collect_deals di
						ON  di.source_deal_header_id = sdpd.source_deal_header_id
						WHERE  sdpd.pnl_as_of_date = dt.dt-1 AND sdpd.source_deal_header_id = dt.source_deal_header_id
			   ) cur1
			    CROSS APPLY (
				  SELECT  sdpd.curve_value [curve_value2], sdpd.formula_value [formula_value2]
				  FROM  source_deal_pnl_detail sdpd
						INNER JOIN #collect_deals di
						ON  di.source_deal_header_id = sdpd.source_deal_header_id
						 WHERE  sdpd.pnl_as_of_date = dt.dt AND sdpd.source_deal_header_id = dt.source_deal_header_id
			   ) cur2
			CROSS APPLY ( 
				SELECT sdh.source_deal_header_id 
					FROM source_deal_header sdh 
					INNER JOIN #collect_deals cd 
					ON sdh.source_deal_header_id = cd.source_deal_header_id
					WHERE  sdh.source_deal_header_id = dt.source_deal_header_id
					GROUP BY sdh.source_deal_header_id 
		      ) cd
			
		   ) mtm
		   CROSS APPLY (
				SELECT TOP 1
					 (pmd1.effective_date) effective_date
					, (pmd1.initial_margin) initial_margin
					, (pmd1.initial_margin_per) initial_margin_per
					, (pmd1.maintenance_margin) maintenance_margin
					, (pmd1.maintenance_margin_per) maintenance_margin_per
					, (pmd1.currency_id) currency_id
					, (pmd1.lot_size) lot_size
					, (pmd1.uom_id) uom_id
					, (pmd1.post_rec_threshold) post_rec_threshold
		            , (cmph.counterparty_id) counterparty_id
					, (cmph.contract_id) contract_id
					, (cmph.product_id) product_id
					, (pmd1.rounding) rounding
				FROM   process_margin_detail pmd1 
				INNER JOIN #collect_margin_process_header cmph 
					ON cmph.process_margin_header_id  = pmd1.process_margin_header_id 
						WHERE  pmd1.effective_date < mtm.as_of_date ORDER BY pmd1.effective_date DESC
			) pmd 
		
		
	
	SELECT id = IDENTITY(INT, 1, 1),
		  as_of_date	
		, clearing_counterparty_id	
		, margin_contract_id	
		, margin_account	
		, mtmt_t0	
		, mtmt_t1	
		, delta_mtm	
		, margin_call_price	
		, maintenance_margin_amount	
		, additional_margin	
		, current_portfolio_value	
		, maintenance_margin_required	
		, margin_call_amt	 
		, margin_excess	
		, deal_volume	
		, total_initial_margin	
		, total_maintenance_margin	
		, deal_price	
		, curve_value1	
		, curve_value2	
		, source_deal_header_id	
		, product_id 
		, delta_mtm [margin_account_balc]
		, total_initial_margin [beg_balc]  
		, end_balc 
		, previous_as_of_date
		INTO #temp_calc_2
	FROM #temp_calc_1 t1

	

	SELECT id = IDENTITY(INT, 1, 1),
		  t2.as_of_date	
		, t2.clearing_counterparty_id	
		, t2.margin_contract_id	
		, t2.margin_account
		, t2.mtmt_t0	
		, t2.mtmt_t1	
		, t2.delta_mtm	
		, t2.margin_call_price	
		, t2.maintenance_margin_amount	
		, t2.additional_margin	
		, t2.current_portfolio_value	
		, t2.maintenance_margin_required	
		--, CASE WHEN ([beg_balc] + delta_mtm) > total_maintenance_margin  THEN  ([beg_balc] + delta_mtm) - (total_initial_margin) ELSE 0 END  [margin_call_amt]	
		--,CASE 
		--	WHEN ([beg_balc] + delta_mtm) > total_maintenance_margin
		--		THEN CASE 
		--				WHEN total_initial_margin > ([beg_balc] + delta_mtm)
		--					AND ([beg_balc] + delta_mtm) > total_maintenance_margin
		--					THEN 0
		--				ELSE ([beg_balc] + delta_mtm) - (total_initial_margin)
		--				END
		--	ELSE (-1*(total_initial_margin - ([beg_balc] + delta_mtm)))
		-- END [margin_call_amt]	
		, CASE 
			WHEN (ISNULL(scm.end_balc,t2.beg_balc)  + t2.delta_mtm) > t2.total_maintenance_margin
				AND (ISNULL(scm.end_balc,t2.beg_balc)  + t2.delta_mtm) < t2.total_initial_margin
				THEN 0
			ELSE (ISNULL(scm.end_balc,t2.beg_balc)  + t2.delta_mtm) - t2.total_initial_margin 
		 END [margin_call_amt]
		, t2.margin_excess	
		, t2.deal_volume	
		, t2.total_initial_margin	
		, t2.total_maintenance_margin	
		, t2.deal_price	
		, t2.curve_value1	
		, t2.curve_value2	
		, t2.source_deal_header_id	
		, t2.product_id 
		, t2.margin_account_balc
		, ISNULL(scm.end_balc,t2.beg_balc) beg_balc 
		, ISNULL(scm.end_balc,t2.beg_balc) + t2.delta_mtm end_balc 
		, t2.previous_as_of_date
		INTO #temp_calc_3
	FROM #temp_calc_2 t2 LEFT JOIN source_counterparty_margin scm 
	ON t2.source_deal_header_id = scm.source_deal_header_id AND t2.previous_as_of_date = scm.as_of_date


	SELECT id = IDENTITY(INT, 1, 1),
	      t3.as_of_date	
		, t3.clearing_counterparty_id	
		, t3.margin_contract_id	
		, t3.margin_account
		, t3.mtmt_t0	
		, t3.mtmt_t1	
		, t3.delta_mtm	
		, t3.margin_call_price	
		, t3.maintenance_margin_amount	
		, t3.additional_margin	
		, t3.current_portfolio_value	
		, t3.maintenance_margin_required	
		 --,CASE WHEN ABS(t3.end_balc) < pmd.post_rec_threshold THEN 0 ELSE ROUND(t3.margin_call_amt, pmd.rounding)  END  margin_call_amt
		, t3.margin_call_amt
		, t3.margin_excess	
		, t3.deal_volume	
		, t3.total_initial_margin	
		, t3.total_maintenance_margin	
		, t3.deal_price	
		, t3.curve_value1	
		, t3.curve_value2	
		, t3.source_deal_header_id	
		, t3.product_id 
		, t3.margin_account_balc
		, t3.[beg_balc]
		, t3.[end_balc]  -- CASE WHEN t3.[end_balc] >  t3.total_initial_margin THEN t3.total_initial_margin ELSE t3.[end_balc] END [end_balc] 
		, t3.previous_as_of_date
		INTO #temp_calc_4
	FROM #temp_calc_3 t3
	--CROSS APPLY(
	--	SELECT SUM([end_balc]) [end_balc] from #temp_calc_3  GROUP BY  margin_contract_id ,margin_contract_id, product_id, as_of_date
	-- ) ebalc
     
 
	BEGIN TRY
	IF EXISTS (SELECT 1
				   FROM   source_counterparty_margin scm INNER JOIN #temp tp  ON scm.as_of_date = tp.dt AND scm.source_deal_header_id = tp.source_deal_header_id
				   WHERE scm.clearing_counterparty_id = @counterparty_id AND scm.margin_contract_id = @contract_id  AND scm.product_id = @product_id
				   
		)

	BEGIN
		DELETE scm
				FROM   source_counterparty_margin scm inner join #temp tp  ON scm.as_of_date = tp.dt AND scm.source_deal_header_id = tp.source_deal_header_id
				WHERE scm.clearing_counterparty_id = @counterparty_id AND scm.margin_contract_id = @contract_id  AND scm.product_id = @product_id
	END
	
	--Inserted calculate value into final table  	
	INSERT INTO source_counterparty_margin (as_of_date
		, clearing_counterparty_id
		, margin_contract_id
		, margin_account
		, mtmt_t0
		, mtmt_t1
		, delta_mtm
		, margin_call_price
		, maintenance_margin_amount
		, additional_margin
		, current_portfolio_value
		, maintenance_margin_required
		, margin_call_amt
		, margin_excess
		, deal_volume
		, total_initial_margin
		, total_maintenance_margin
		, deal_price
		, curve_value1
		, curve_value2
		, source_deal_header_id
		, product_id
		, margin_account_balc
		, beg_balc
		, end_balc
		, previous_as_of_date
	)

		SELECT 	
	      t4.as_of_date	
		, t4.clearing_counterparty_id	
		, t4.margin_contract_id	
		, t4.margin_account
		, t4.mtmt_t0	
		, t4.mtmt_t1	
		, t4.delta_mtm	
		, t4.margin_call_price	
		, t4.maintenance_margin_amount	
		, t4.additional_margin	
		, t4.current_portfolio_value	
		, t4.maintenance_margin_required	
		, CASE 
			WHEN (ISNULL(scm.end_balc, t4.beg_balc) + t4.delta_mtm) > t4.total_initial_margin
				THEN CASE 
				WHEN ABS((ISNULL(scm.end_balc, t4.beg_balc) + t4.delta_mtm) - t4.total_initial_margin) < pmd.post_rec_threshold
				THEN 0 ELSE ROUND(((ISNULL(scm.end_balc, t4.beg_balc) + t4.delta_mtm) - t4.total_initial_margin)/isnull(pmd.rounding,1),0 )* isnull(pmd.rounding,1) END 
			ELSE CASE WHEN ABS(t4.margin_call_amt) < pmd.post_rec_threshold THEN 0  ELSE  ROUND(t4.margin_call_amt/ISNULL(pmd.rounding,1),0)*ISNULL(pmd.rounding,1) END 
			END [margin_call_amt]
		, t4.margin_excess	
		, t4.deal_volume	
		, t4.total_initial_margin	
		, t4.total_maintenance_margin	
		, t4.deal_price	
		, t4.curve_value1	
		, t4.curve_value2	
		, t4.source_deal_header_id	
		, t4.product_id 
		, t4.margin_account_balc
		, ISNULL(scm.end_balc, t4.beg_balc) [beg_balc]
		, CASE 
			WHEN (ISNULL(ISNULL(scm.end_balc, t4.beg_balc) - scm.margin_call_amt, ISNULL(scm.end_balc, t4.beg_balc)) + t4.delta_mtm) > t4.total_initial_margin
				THEN t4.total_initial_margin
			ELSE t4.end_balc - t4.margin_call_amt
			END [end_balc]
		, t4.previous_as_of_date
	FROM #temp_calc_4 t4 
	LEFT JOIN source_counterparty_margin scm
	ON scm.clearing_counterparty_id = t4.clearing_counterparty_id
		AND scm.margin_contract_id = t4.margin_contract_id
		AND scm.product_id = t4.product_id
		AND scm.as_of_date = t4.previous_as_of_date
		AND scm.source_deal_header_id = t4.source_deal_header_id
	CROSS APPLY(
		 SELECT top 1 pmd1.post_rec_threshold, pmd1.rounding
		 FROM   process_margin_detail pmd1 
					INNER JOIN #collect_margin_process_header cmph 
						ON cmph.process_margin_header_id  = pmd1.process_margin_header_id 
							WHERE pmd1.effective_date < t4.as_of_date ORDER BY pmd1.effective_date DESC
	) pmd

	EXEC spa_ErrorHandler 0
				, ''
				, 'spa_calc_margin'
				, 'Success'
				, 'Changes have been saved successfully.'
				, ''        
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		EXEC spa_ErrorHandler -1
				, ''
				, 'spa_calc_margin'
				, 'DBError'
				, 'Data calculation failed.'
				, '' 
	END CATCH
		
END

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
	BEGIN
		SET @user_login_id= dbo.FNADBUser()
		SET @job_name = 'report_batch_' + @batch_process_id
		SET @end_time_sec = DATEDIFF(ss,@begin_time,GETDATE())
		SET @Conv_time_min_sec = CAST(CAST(@end_time_sec/60 as int) AS VARCHAR) + ' Mins ' + CAST(@end_time_sec - CAST(@end_time_sec/60 AS INT) * 60 AS VARCHAR) + ' Secs'
		SET @desc = 'Batch process completed for run margin analysis.' + ' [Elapse time: ' + ISNULL(@Conv_time_min_sec, '') + ']'
   
		EXEC spa_message_board 'u', @user_login_id, NULL, 'Margin Analysis', @desc, '', '', 's', @job_name, NULL, @batch_process_id, NULL, NULL, '', 'y', '', @batch_report_param , NULL, NULL,NULL, ''
		RETURN
END

GO
