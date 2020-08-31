IF OBJECT_ID(N'spa_gen_transaction', N'P') IS NOT NULL
	DROP PROC dbo.spa_gen_transaction
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
 This procedure creates a forecasted transaction and automatically links them
 The transactions created by this procedure will later be either approved or
 deleted. IF approved, the forecasted transaction (items) can be moved to the
 source (i.e., risk) system.
 Parameters: 
	@gen_hedge_group_id  	: required field that indicates a gen group id
	@eff_test_profile_id  	: NULL -- optional hedging relationship profile that will be used for item generation
								IF passed NULL, this proc will find a matching one.
	@user_login_id 			: Username
	@global_process_id		: Unique and Parent process id for over all process

*/

CREATE PROCEDURE [dbo].[spa_gen_transaction]	
	@gen_hedge_group_id INT,
	@eff_test_profile_id INT,
	@user_login_id VARCHAR(50),
	@global_process_id VARCHAR(200) = NULL
	--,
	--@is_script CHAR(1) = 'n'

AS

SET NOCOUNT ON
/*
-- EXEC spa_gen_transaction 508, 74, 'urbaral' 
--SELECT * FROM #run_status

DECLARE 	@gen_hedge_group_id INT,
 		@eff_test_profile_id INT,
 		@user_login_id VARCHAR(50),@global_process_id VARCHAR(200)='cccc'
 
 SET @gen_hedge_group_id = 261929
 SET @eff_test_profile_id = 62
 SET @user_login_id = 'gkoju'
 DROP TABLE #fas_eff_hedge_rel_type
 DROP TABLE #gen_deal
 DROP TABLE #gen_deal_volume
 DROP TABLE #gen_min_hedge_volume
 DROP TABLE #matched_rel_type
 DROP TABLE #gen_deal_header
 DROP TABLE #gen_deal_detail
 DROP TABLE #hedge_fixed_prices
 DROP TABLE #item_prices
 DROP TABLE #hedge_prices
 DROP TABLE #run_status
 drop table #temp_f_price
 drop table #temp_f_price1
 drop table #tempMonths
 drop table #tempMonthsItems
 drop table #tempMonthsHedges
 drop table #hedge_price_t1
 drop table #hedge_price_t
 
--*/

--- TO TEST USE A gen headge group with hedge effective date = 
---- gen hedge detail with deal header id = 3 and % = 0.4

----EXEC spa_genhedgegroup 'd', 14
----GO
-- INSERT INTO gen_hedge_group
-- SELECT 'Deal Id 3 (1103)', 450, '1/5/2003', NULL, 'n', NULL, NULL, NULL, NULL
-- -- ----EXEC spa_genhedgegroup 'i',NULL, 'Deal Id 3 (1103)','1/5/2003', 450, NULL, 'n'
-- GO
-- DECLARE @gen_hedge_group_id INT
-- SET @gen_hedge_group_id = SCOPE_IDENTITY()
-- --SELECT @gen_hedge_group_id
-- INSERT INTO gen_hedge_group_detail
-- SELECT    @gen_hedge_group_id , 3, 0.4, NULL, NULL, NULL, NULL
-- GO
-- -- ----EXEC spa_genhedgegroupdetail 'i', NULL, @gen_hedge_group_id, 3, 0.4
-- SELECT top 1 'New ID for Test: ' + CAST(gen_hedge_group_id AS VARCHAR) FROM gen_hedge_group order by gen_hedge_group_id desc
-- GO
---------END OF THEST DATA  ----------------------------------------------------------
--------------------------------------------------------------------------------------
--This in input
-- DROP TABLE #fas_eff_hedge_rel_type
-- DROP TABLE #gen_deal
-- DROP TABLE #gen_deal_volume
-- DROP TABLE #gen_min_hedge_volume
-- DROP TABLE #matched_rel_type
-- DROP TABLE #gen_deal_header
-- DROP TABLE #gen_deal_detail
-- DROP TABLE #hedge_fixed_prices
-- DROP TABLE #item_prices
-- DROP TABLE #hedge_prices
-- DROP TABLE #run_status
-- drop table #temp_f_price
-- drop table #temp_f_price1
-- drop table #tempMonths
-- drop table #tempMonthsItems
-- drop table #tempMonthsHedges
-- drop table #hedge_price_t1
-- drop table #hedge_price_t
-- -- -- -- -- -- GO
-- -- -- -- -- -- 
-- DECLARE @gen_hedge_group_id INT 
-- DECLARE @eff_test_profile_id INT
-- DECLARE @user_login_id VARCHAR(20)
-- 
-- SET @gen_hedge_group_id = 191
-- SET @eff_test_profile_id = 35
-- SET @user_login_id = 'urbaral'
--SET @debug = 1
---- END OF INPUT

EXEC spa_print 'start [spa_gen_transaction]'
BEGIN TRY
	DECLARE @debug AS INT
	DECLARE @process_id VARCHAR(200)
	DECLARE @source_system_id INT
	SET @source_system_id = 2
	SET @debug = 1

	DECLARE @reprice_items_id INT 
	DECLARE @tenor_from VARCHAR(10)
	DECLARE @tenor_to VARCHAR(10)
	DECLARE @link_type_value_id INT
	DECLARE @check_for_rel_type_while_gen INT
	DECLARE @auto_finalize_gen_trans INT

	SET @process_id = REPLACE(NEWID(),'-','_')

	DECLARE @alert_process_table VARCHAR(300)
	DECLARE @sql VARCHAR(MAX)

	SET @alert_process_table = 'adiha_process.dbo.alert_auto_forecasted_trans_' + @process_id + '_af'

	SET @sql = '
		IF OBJECT_ID(''' + @alert_process_table + ''') IS NOT NULL
			DROP TABLE ' + @alert_process_table + '

		CREATE TABLE ' + @alert_process_table + ' (
			fas_book_id  INT,
			gen_link_id INT,
			curve_id INT
		)
	'

	EXEC (@sql)

	--IF @auto_finalize_gen_trans is 1 THEN auto approve will occur so that transaction  can be finalized after this step
	SELECT @auto_finalize_gen_trans = var_value
	FROM adiha_default_codes_values
	WHERE (default_code_id = 18) 
		AND (seq_no = 1) 
		AND (instance_no = '1')		 

	--======ADD THESE VARIABLES IN  THE DEFAULT PARAMETER LISTS
	DECLARE @use_min_or_max_vol_generation VARCHAR(1)
	DECLARE @volume_mismatch_continue VARCHAR(1)

	--use MAX volume when 1 for two deal types like nymex and basis swap
	SET @use_min_or_max_vol_generation = '1'
	--when 'y' mismatch volume is allowed. Continue with min or  MAX logic on  volume of multiple deal type
	SET @volume_mismatch_continue = 'y'

	--SELECT @auto_finalize_gen_trans, @auto_finalize_gen_mtm_trans

	SELECT @reprice_items_id = reprice_items_id,
		@tenor_from = dbo.FNAGetContractMonth(tenor_from),
		@tenor_to = dbo.FNAGetContractMonth(tenor_to),
		@link_type_value_id = link_type_value_id
	FROM gen_hedge_group
	WHERE gen_hedge_group_id = @gen_hedge_group_id

	--donot run this section when we're repricing the items
	SELECT @check_for_rel_type_while_gen = var_value
	FROM adiha_default_codes_values
	WHERE (instance_no = '1') 
		AND (seq_no = 1) 
		AND (default_code_id = 17)

	CREATE TABLE #run_status(
		[ErrorCode] VARCHAR(50) COLLATE DATABASE_DEFAULT,
		[Module] VARCHAR(50) COLLATE DATABASE_DEFAULT,
		[Area] VARCHAR(50) COLLATE DATABASE_DEFAULT,
		[Status] VARCHAR(50) COLLATE DATABASE_DEFAULT,
		[Message] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[Recommendation] VARCHAR(250) COLLATE DATABASE_DEFAULT)

	DECLARE @total_rel_types INT
	DECLARE @gen_hedge_group_desc VARCHAR(100)
	SET @total_rel_types = 0


	DECLARE @perfect_hedge CHAR
	DECLARE @past_perfect_hedge CHAR
	DECLARE @hedge_or_item CHAR
	DECLARE @gen_hedge_group_name VARCHAR(100)
	SET @gen_hedge_group_name = NULL
	SET @hedge_or_item = 'i'

	--First check IF it is a valid gen group
	SELECT 	@perfect_hedge = perfect_hedge,
		@gen_hedge_group_name = gen_hedge_group_name
	FROM gen_hedge_group WHERE gen_hedge_group_id = @gen_hedge_group_id
 
	IF @gen_hedge_group_name IS NULL 
	BEGIN
		INSERT INTO gen_transaction_status
		SELECT @process_id
			, @gen_hedge_group_id
			, 'Error' 
			, 'Transaction Generation' 
			, 'spa_gen_transaction' 
			, 'Application Error' 
			, 'Invalid generation group Id: ' + CAST(@gen_hedge_group_id AS VARCHAR) + ' supplied.'
			, 'Please contact technical support.'
			, @user_login_id
			, NULL	
		RETURN
	END

	-- IF repriced THEN track the past perfect hedge cause we have to hedge info now and not item
	-- and make it non-perfect now as tenor differs
	-- @past_perfect_hedge should  be no for regular gen
	SET @past_perfect_hedge  = 'n'
	IF @reprice_items_id IS NOT NULL AND @perfect_hedge = 'y'
	BEGIN
		SET @perfect_hedge = 'n'	
		--SET @hedge_or_item = 'h'
		SET @past_perfect_hedge  = 'y'
		SET @reprice_items_id = NULL
	END

	--Now check IF the gen group has already been processed (i.e, item already created)
	DECLARE @gen_already_created INT 
	SET @gen_already_created = NULL
	SELECT @gen_already_created = COUNT (*) FROM
	(SELECT  gen_fas_link_header.gen_link_id AS gen_link_id, 
		gen_hedge_group.gen_hedge_group_id, gen_hedge_group.gen_hedge_group_name, 
			gen_hedge_group.link_type_value_id
	FROM    gen_hedge_group LEFT OUTER JOIN
			gen_fas_link_header ON gen_hedge_group.gen_hedge_group_id = gen_fas_link_header.gen_hedge_group_id
	WHERE   gen_fas_link_header.gen_link_id IS NOT NULL AND
		gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id) gen_already_processed

	IF @gen_already_created > 0
	BEGIN
		INSERT INTO gen_transaction_status
		SELECT @process_id
			, @gen_hedge_group_id
			, 'Error' 
			, 'Transaction Generation' 
			, 'spa_gen_transaction' 
			, 'Application Error' 
			, 'Transaction already generated for generation group Id: ' + CAST(@gen_hedge_group_id AS VARCHAR)
			, 'Please contact technical support.'
			, @user_login_id
			, NULL
		RETURN
	END

	IF @reprice_items_id IS NULL AND (@eff_test_profile_id IS NULL OR @check_for_rel_type_while_gen = 1)
	BEGIN
		-- Step 1: Find a  relationship that matches hedges profile IF a relationship type id is not assigned.
		--	   IF a relationship id is assigned check to make sure it fits the profile. IF the return
		-- 	   result SET (returns relationship id) is only one THEN it is fine. 0 means no found and
		-- 	   >1 row means duplicate types found.

		-- 1.a -> Find hedges and group by the rules columns 
		SELECT 		source_deal_header.source_deal_header_id, source_system_book_map.fas_book_id, 
				source_system_book_map.book_deal_type_map_id, 
				--ignoring compare these fields IF it is perfect match
				CASE WHEN ISNULL(gen_hedge_group.perfect_hedge,'n') = 'y' THEN -1 ELSE  source_deal_header.source_deal_type_id end source_deal_type_id, 
				CASE WHEN ISNULL(gen_hedge_group.perfect_hedge,'n') = 'y' THEN -1 ELSE  ISNULL(source_deal_header.deal_sub_type_type_id, -1) end deal_sub_type_type_id, 
				CASE WHEN ISNULL(gen_hedge_group.perfect_hedge,'n') = 'y' THEN 'a' ELSE  source_deal_detail.fixed_float_leg end fixed_float_leg, 
				source_deal_detail.Leg, source_deal_detail.buy_sell_flag, 
				ISNULL(source_deal_detail.curve_id, -1) as curve_id
		INTO 		#gen_deal 
		FROM    	gen_hedge_group_detail INNER JOIN gen_hedge_group on gen_hedge_group_detail.gen_hedge_group_id=gen_hedge_group.gen_hedge_group_id
				   INNER JOIN source_deal_header ON source_deal_header.source_deal_header_id = gen_hedge_group_detail.source_deal_header_id INNER JOIN
	        		source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id INNER JOIN
					source_system_book_map ON source_deal_header.source_system_book_id1 = source_system_book_map.source_system_book_id1 AND 
	        		source_deal_header.source_system_book_id2 = source_system_book_map.source_system_book_id2 AND 
					source_deal_header.source_system_book_id3 = source_system_book_map.source_system_book_id3 AND 
	        		source_deal_header.source_system_book_id4 = source_system_book_map.source_system_book_id4
	        		WHERE source_deal_detail.Leg=1
		GROUP BY 	source_deal_header.source_deal_header_id, gen_hedge_group_detail.gen_hedge_group_id, source_system_book_map.fas_book_id, 
	        		source_system_book_map.book_deal_type_map_id, source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
					gen_hedge_group.perfect_hedge,
						source_deal_detail.fixed_float_leg, source_deal_detail.Leg, source_deal_detail.buy_sell_flag, source_deal_detail.curve_id
		HAVING      	gen_hedge_group_detail.gen_hedge_group_id = @gen_hedge_group_id
		ORDER BY 	source_system_book_map.fas_book_id, source_system_book_map.book_deal_type_map_id, source_deal_header.source_deal_type_id, 
						source_deal_header.deal_sub_type_type_id, source_deal_detail.fixed_float_leg, source_deal_detail.Leg, source_deal_detail.buy_sell_flag, 
						source_deal_detail.curve_id

		-- 1.b -> Find rules
		SELECT  	fas_eff_hedge_rel_type.eff_test_profile_id, fas_eff_hedge_rel_type.fas_book_id, 
				fas_eff_hedge_rel_type.eff_test_name, fas_eff_hedge_rel_type_detail.book_deal_type_map_id, 
				--ignoring compare these fields IF it is perfect match
				case when ISNULL(fas_eff_hedge_rel_type.matching_type,'n')='p' THEN -1 ELSE  fas_eff_hedge_rel_type_detail.source_deal_type_id end source_deal_type_id, 
				case when ISNULL(fas_eff_hedge_rel_type.matching_type,'n')='p' THEN -1 ELSE  ISNULL(fas_eff_hedge_rel_type_detail.deal_sub_type_id, -1) end deal_sub_type_id, 
				case when ISNULL(fas_eff_hedge_rel_type.matching_type,'n')='p' THEN 'a' ELSE  fas_eff_hedge_rel_type_detail.fixed_float_flag end fixed_float_flag , 
					fas_eff_hedge_rel_type_detail.leg, 
	        		fas_eff_hedge_rel_type_detail.buy_sell_flag, ISNULL(fas_eff_hedge_rel_type_detail.source_curve_def_id, -1) as source_curve_def_id
		INTO 		#fas_eff_hedge_rel_type
		FROM         	fas_eff_hedge_rel_type INNER JOIN
	             		fas_eff_hedge_rel_type_detail ON fas_eff_hedge_rel_type.eff_test_profile_id = fas_eff_hedge_rel_type_detail.eff_test_profile_id 
		  --      INNER JOIN
				--(SELECT     TOP 1 source_system_book_map.fas_book_id
				-- FROM         gen_hedge_group_detail INNER JOIN
		  --               source_deal_header ON gen_hedge_group_detail.source_deal_header_id = source_deal_header.source_deal_header_id INNER JOIN
		  --               source_system_book_map ON source_deal_header.source_system_book_id1 = source_system_book_map.source_system_book_id1 AND 
		  --               source_deal_header.source_system_book_id2 = source_system_book_map.source_system_book_id2 AND 
		  --               source_deal_header.source_system_book_id3 = source_system_book_map.source_system_book_id3 AND 
		  --               source_deal_header.source_system_book_id4 = source_system_book_map.source_system_book_id4
				-- WHERE     gen_hedge_group_detail.gen_hedge_group_id = @gen_hedge_group_id) book_id on book_id.fas_book_id = fas_eff_hedge_rel_type.fas_book_id
		WHERE     	fas_eff_hedge_rel_type_detail.hedge_or_item = 'h' 
				AND fas_eff_hedge_rel_type.eff_test_profile_id = ISNULL(@eff_test_profile_id, fas_eff_hedge_rel_type.eff_test_profile_id)
		ORDER BY 	fas_eff_hedge_rel_type.fas_book_id, fas_eff_hedge_rel_type_detail.book_deal_type_map_id, fas_eff_hedge_rel_type_detail.source_deal_type_id, 
						fas_eff_hedge_rel_type_detail.deal_sub_type_id, fas_eff_hedge_rel_type_detail.fixed_float_flag, fas_eff_hedge_rel_type_detail.leg, 
						fas_eff_hedge_rel_type_detail.buy_sell_flag, fas_eff_hedge_rel_type_detail.source_curve_def_id
	
		--SELECT * from #fas_eff_hedge_rel_type
	
		-- 1.c  -> gives total COUNT of matching relationship IF > 1 THEN duplicate and IF < 1 no match
		SELECT  DISTINCT #fas_eff_hedge_rel_type.eff_test_profile_id as eff_test_profile_id
		INTO #matched_rel_type
		FROM #gen_deal INNER JOIN
			#fas_eff_hedge_rel_type
		ON 		--#fas_eff_hedge_rel_type.fas_book_id = #gen_deal.fas_book_id AND
			ISNULL(#fas_eff_hedge_rel_type.book_deal_type_map_id,#gen_deal.book_deal_type_map_id) = #gen_deal.book_deal_type_map_id AND
			#fas_eff_hedge_rel_type.source_deal_type_id = #gen_deal.source_deal_type_id AND
	        	#fas_eff_hedge_rel_type.deal_sub_type_id = #gen_deal.deal_sub_type_type_id AND
			#fas_eff_hedge_rel_type.fixed_float_flag = #gen_deal.fixed_float_leg 
			AND #fas_eff_hedge_rel_type.source_curve_def_id = #gen_deal.curve_id
	
		SELECT 	@total_rel_types = COUNT(eff_test_profile_id)
		FROM #matched_rel_type

		-- Check for duplicate types found or a type not found at all
		IF @total_rel_types = 0 
		--**ERROR**
		BEGIN
			IF @eff_test_profile_id IS NULL
				INSERT INTO #run_status
				SELECT 	'Error' ErrorCode, 'Transaction Generation' Module, 'spa_gen_transaction' Area, 
					'Application Error' Status, 
					'Relationship to generate items not found for selected hedges in generation group id: ' + CAST(@gen_hedge_group_id AS VARCHAR) Message, 
					'Please define a relationship for transaction generation.' Recommendation
			ELSE
				INSERT INTO #run_status
				SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'spa_gen_transaction' Area, 
					'Application Error' Status, 
					'Assigned relationship does not match define hedge profile in Relationship id: ' + CAST(@eff_test_profile_id AS VARCHAR) Message, 
					'Please check the relationship for transaction generation. Generation group id: ' + CAST(@gen_hedge_group_id AS VARCHAR) Recommendation
	
		END
		ELSE IF @total_rel_types > 1
		--**ERROR**
		BEGIN 
			INSERT INTO #run_status
			SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'spa_gen_transaction' Area, 
				'Application Error' Status, 
				'Multiple relationships to generate items found for selected hedges in generation group id: ' + CAST(@gen_hedge_group_id AS VARCHAR) Message, 
				'Please check the relationship for transaction generation.' Recommendation
		END

		--This is the @eff_test_profile_id to use 
		IF @eff_test_profile_id IS NULL 
		BEGIN
			SELECT @eff_test_profile_id  = eff_test_profile_id
			FROM #matched_rel_type
		END
	END -- ends the IF statement to test @reprice_items_items IS NULL (REGULAR GEN AND NOT REPRICING)

	IF @debug = 1
		EXEC spa_print 'After matching eff test profile id: ', @eff_test_profile_id

	--IF @eff_test_profile_id  is still NULL abort
	IF @eff_test_profile_id IS NULL 
	BEGIN
		INSERT INTO gen_transaction_status
		SELECT @process_id, @gen_hedge_group_id, 
			'Error' , 'Transaction Generation' , 'spa_gen_transaction' , 
			'Application Error' , 
			'Transaction Generation failed since a matching hedging relationship could not be found for generation group Id: ' + CAST(@gen_hedge_group_id AS VARCHAR), 
			'Please SELECT a valid hedging relationship type for generation group id: ' + CAST(@gen_hedge_group_id AS VARCHAR),
			@user_login_id, NULL
	-- 	Return
	END

	-- SELECT @eff_test_profile_id
	-- SELECT @gen_hedge_group_id

	 IF @reprice_items_id IS NULL
		SET @gen_hedge_group_desc = ' Gen Group Id: ' + CAST(@gen_hedge_group_id AS VARCHAR) + ' (' +
					ISNULL(@gen_hedge_group_name, 'NOT FOUND') + ')' + 
					' using Hedge Relationship Id: ' + ISNULL(CAST(@eff_test_profile_id AS VARCHAR), 'NOT FOUND') 
	ELSE
		SET @gen_hedge_group_desc = ' (Repricing of Hedged Item) Gen Group Id: ' + CAST(@gen_hedge_group_id AS VARCHAR) + ' (' +
					ISNULL(@gen_hedge_group_name, 'NOT FOUND') + ')' + 
					' using Hedge Relationship Id: ' + ISNULL(CAST(@eff_test_profile_id AS VARCHAR), 'NOT FOUND') 

	-- SELECT * FROM #gen_deal
	-- SELECT * FROM #fas_eff_hedge_rel_type
	-- SELECT * FROM #matched_rel_type
	-- RETURN
	-- SELECT @gen_hedge_group_desc
	---------------------------------------------------------------------------------------------------
	-----------------End of Step 1
	---------------------------------------------------------------------------------------------------
	/*
	IF OBJECT_ID('tempdb..#deal_header_info') IS NOT NULL 
		DROP TABLE #deal_header_info

	SELECT MAX(sdh.source_deal_type_id) source_deal_type_id
		, LOWER(CAST(DATENAME(MONTH, MIN(sdd.term_start)) AS VARCHAR(3))) strip_month_from
		, LOWER(CAST(DATENAME(MONTH, MAX(sdd.term_end)) AS VARCHAR(3))) strip_month_to
		, MAX(sdd.curve_id) source_curve_def_id
		, MAX(sdh.header_buy_sell_flag) buy_sell_flag
		, sdh.source_deal_header_id
		, MAX(sdh.trader_id) trader_id
		, MAX(sdh.counterparty_id) counterparty_id
		INTO #deal_header_info
	FROM gen_hedge_group ghg
	INNER JOIN gen_hedge_group_detail ghgd ON  ghg.gen_hedge_group_id =  ghgd.gen_hedge_group_id
	INNER JOIN source_deal_header sdh On sdh.source_deal_header_id = ghgd.source_deal_header_id
 	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE 1 = 1
		AND ghg.gen_hedge_group_id = @gen_hedge_group_id
		AND sdd.leg = 1
	GROUP BY sdh.source_deal_header_id 
	*/
	IF @reprice_items_id IS NULL
	BEGIN	
		IF @perfect_hedge = 'n'
		BEGIN
			---------------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------------
			-- Step 2: Find the volume for hedges
			DECLARE @uom_count INT
			DECLARE @vol_frequency_count INT
		
			SET @uom_count = 0 
			SET @vol_frequency_count = 0
	
			-- 2.a --> This SELECT statment sums all volumes by the hedge rules and start term and end term
			-- For example, 2 nymex swaps will be summed by each contract month
			-- Nymex and basis swap will be summed by each deal category by each contract month
			SELECT 
				--*
				ssbm.fas_book_id, 
					ssbm.book_deal_type_map_id, sdh.source_deal_type_id, 
					ISNULL(sdh.deal_sub_type_type_id, -1) as deal_sub_type_type_id, 
					sdd.fixed_float_leg, 
					sdd.Leg, sdd.buy_sell_flag, 
					ISNULL(sdd.curve_id, -1) as curve_id,
					dbo.FNAGetSQLStandardDate(sdd.term_start) as term_start, 
					dbo.FNAGetSQLStandardDate(sdd.term_end) as term_end,
					sdd.deal_volume_frequency,
					sdd.deal_volume_uom_id,
					--Metal Changes
					sum(sdd.deal_volume * ISNULL(sdd.multiplier, 1) * ISNULL(ghgd.percentage_use, 1) *
							ISNULL(rel.volume_mix_percentage, 1) * ISNULL(rel.uom_conversion_factor, 1)) as deal_volume,
					--sum(sdd.deal_volume * ghgd.percentage_use) as deal_volume			
					CASE WHEN (sdd.buy_sell_flag <> MAX(rel.buy_sell_flag)) THEN 1 ELSE 0 end oppositve_buy_sell
				INTO #gen_deal_volume 
			FROM gen_hedge_group_detail ghgd
			--INNER JOIN #deal_header_info dhi ON dhi.source_deal_header_id = ghgd.source_deal_header_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ghgd.source_deal_header_id 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
				AND sdh.source_system_book_id2 = ssbm.source_system_book_id2 
				AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 
				AND sdh.source_system_book_id4 = ssbm.source_system_book_id4 
			INNER JOIN (SELECT * FROM fas_eff_hedge_rel_type_detail WHERE eff_test_profile_id = @eff_test_profile_id and hedge_or_item = 'h') 
				rel ON ISNULL(sdd.curve_id, -1) = ISNULL(rel.source_curve_def_id, -1) 
				AND sdd.leg = rel.leg 
				--AND dhi.source_deal_type_id = rel.source_deal_type_id
				--AND dhi.strip_month_from  = rel.strip_month_from
				--AND dhi.strip_month_to = rel.strip_month_to
				--AND dhi.source_curve_def_id = rel.source_curve_def_id
			GROUP BY ghgd.gen_hedge_group_id, 
					 ssbm.fas_book_id, 
		        	 ssbm.book_deal_type_map_id, sdh.source_deal_type_id, 
					 sdh.deal_sub_type_type_id, 
					 sdd.fixed_float_leg, sdd.Leg, 
					 sdd.buy_sell_flag, sdd.curve_id,
					 sdd.term_start, sdd.term_end,
					 sdd.deal_volume_frequency,
					 sdd.deal_volume_uom_id
			HAVING   sdd.Leg = 1 AND ghgd.gen_hedge_group_id = @gen_hedge_group_id
		
			-- IF for the same type different deal_volumen_frequency and deal_volume_uom_id give error for conversion		
			SELECT @uom_count = COUNT(DISTINCT deal_volume_uom_id) FROM #gen_deal_volume
	
			--SELECT @uom_count
			--**ERROR**
			IF @uom_count > 1 
			BEGIN
				INSERT INTO #run_status
				SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'spa_gen_transaction' Area, 
								'Application Error' Status, 
					'Transaction Generation does not support multiple units of measure in the same generation group. ' + @gen_hedge_group_desc Message, 
					'Please SELECT only deal(s) with same volume units of measure in generation group id: ' + CAST(@gen_hedge_group_id AS VARCHAR) Recommendation
			END 

			SELECT @vol_frequency_count  = COUNT(DISTINCT deal_volume_frequency) FROM #gen_deal_volume 
			--**ERROR**
			IF @vol_frequency_count > 1
			BEGIN 
				INSERT INTO #run_status
				SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'spa_gen_transaction' Area, 
								'Application Error' Status, 
					'Transaction Generation does not support multiple volume frequency in the same generation group. ' + @gen_hedge_group_desc Message, 
					'Please SELECT only deal(s) with same volume frequency of measure in generation group id: ' + CAST(@gen_hedge_group_id AS VARCHAR) Recommendation
			END
	
			SELECT 	'Success' as ErrorCode, @eff_test_profile_id as eff_test_profile_id,term_start, term_end, 
				MIN(deal_volume_frequency) as deal_volume_frequency, 
				MIN(deal_volume_uom_id) as deal_volume_uom_id, 
				case when (@use_min_or_max_vol_generation = '0')  THEN MIN(deal_volume) 
					ELSE MAX(deal_volume) end as deal_volume,
				MAX(oppositve_buy_sell) oppositve_buy_sell
				INTO #gen_min_hedge_volume
			FROM #gen_deal_volume
			GROUP BY term_start, term_end
			ORDER BY term_start, term_end
	
 			--SELECT * FROM #gen_deal_volume
		
			---- Ensure that when different deal types are involved (i.e. Nymex and Basis Swaps) make sure that
			---- the volumes are  the same
			DECLARE @gen_min_hedge_volume_count INT
			DECLARE @gen_max_hedge_volume_count INT
			SET @gen_min_hedge_volume_count = 0
			SET @gen_max_hedge_volume_count = 0
	
			SELECT @gen_min_hedge_volume_count = COUNT(*) FROM #gen_min_hedge_volume
			SELECT @gen_max_hedge_volume_count = COUNT(*) FROM 
			(SELECT DISTINCT deal_volume_frequency, deal_volume_uom_id, 
					CASE WHEN (@volume_mismatch_continue = 'y') THEN 1 ELSE deal_volume END AS deal_volume, 
					term_start, term_end
			FROM #gen_deal_volume) volume_unique_comb
	
			IF @gen_min_hedge_volume_count <> @gen_max_hedge_volume_count
			BEGIN
				INSERT INTO #run_status
				SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
								'Application Error' Status, 
					'Transaction Generation does not support multiple deal types to have different volume, volume frequency or volume units of mesures.' + @gen_hedge_group_desc Message, 
					'Please SELECT multiple deals with the same volume, volume frequency and volume units of measures.generation group id: ' + CAST(@gen_hedge_group_id AS VARCHAR) Recommendation
		
			END
		-- SELECT 'Min COUNT = ' + CAST(@gen_min_hedge_volume_count AS VARCHAR)
		-- SELECT 'MAX COUNT = ' + CAST(@gen_max_hedge_volume_count AS VARCHAR)
		END 
	END--end of IF @reprice_items_id IS NULL

	--SELECT * from #gen_deal_volume
	--return 
	---------------------------------------------------------------------------------------------------
	-----------------End of Step 2
	---------------------------------------------------------------------------------------------------
	-- Step 3: Create deal detail(s)

	CREATE TABLE [dbo].[#gen_deal_detail] (
		[deal_sequence_number] [INT] NULL,
		[gen_deal_header_id] [INT] NULL,
		[term_start] [DATETIME] NOT NULL,
		[term_end] [DATETIME] NOT NULL,
		[Leg] [INT] NOT NULL,
		[contract_expiration_date] [DATETIME] NULL,
		[fixed_float_leg] [char] (1) NOT NULL,
		[buy_sell_flag] [char] (1)   NOT NULL,
		[curve_id] [VARCHAR] (50) COLLATE DATABASE_DEFAULT NULL,
		[fixed_price] [FLOAT] NULL ,
		[fixed_price_currency_id] [INT] NULL ,
		[option_strike_price] [FLOAT] NULL ,
		[deal_volume] [FLOAT] NOT NULL ,
		[deal_volume_frequency] [CHAR](1) COLLATE DATABASE_DEFAULT NOT NULL ,
		[deal_volume_uom_id] [VARCHAR] (50) COLLATE DATABASE_DEFAULT NULL,
		[block_description] [VARCHAR] (100) COLLATE DATABASE_DEFAULT NULL ,
		[internal_deal_type_value_id] [VARCHAR] (50) NULL ,
		[internal_deal_subtype_value_id] [VARCHAR] (50) COLLATE DATABASE_DEFAULT NULL ,
		[deal_detail_description] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
		[hedge_term_start] DATETIME NOT NULL,
		[price_adder] FLOAT NULL,
		[price_multiplier] FLOAT NULL 
	) ON [PRIMARY]

	-- SELECT * FROM #gen_deal_volume
	--
	DECLARE @total_legs INT

	SET @total_legs = 0

	SELECT @total_legs = MAX(leg) FROM fas_eff_hedge_rel_type_detail 
	WHERE eff_test_profile_id = @eff_test_profile_id and hedge_or_item = 'i' 

	IF @total_legs IS NULL 
		SET @total_legs = 1
	 	
	IF @reprice_items_id IS NULL AND LOWER(@perfect_hedge) = 'n'
	BEGIN
		IF @total_legs > 2
		BEGIN
			INSERT INTO #gen_deal_detail
			SELECT 
				rel.deal_sequence_number, 
				NULL AS gen_deal_header_id, 
				gd.term_start AS term_start, 
				gd.term_end AS term_end, 
				rel.leg AS Leg, 
				gd.term_end AS contract_expiration_date, 
				rel.fixed_float_flag AS fixed_float_flag, 
				rel.buy_sell_flag, 
				rel.source_curve_def_id AS curve_id, 
				NULL AS fixed_price, 
				NULL AS fixed_price_currency_id,
				NULL AS option_strike_price, 
				gd.deal_volume AS deal_volume, 
				gd.deal_volume_frequency AS deal_volume_frequency, 
				gd.deal_volume_uom_id AS deal_volume_uom_id, 
				' ' AS block_description, 
				NULL AS internal_deal_type_value_id, NULL AS internal_deal_subtype_value_id, 
				@gen_hedge_group_desc AS deal_detail_description,
				'1990-01-01'  as  hedge_term_start, -- **UPDATE this later
				ISNULL(rel.price_adder, 0) price_adder,
				ISNULL(rel.price_multiplier, 1) price_multiplier
				FROM 
				(SELECT source_system_book_map.fas_book_id, 
				source_system_book_map.book_deal_type_map_id, source_deal_header.source_deal_type_id, 
				ISNULL(source_deal_header.deal_sub_type_type_id, -1) as deal_sub_type_type_id, 
				source_deal_detail.fixed_float_leg, 
				source_deal_detail.Leg, source_deal_detail.buy_sell_flag, 
				ISNULL(source_deal_detail.curve_id, -1) as curve_id,
				dbo.FNAGetSQLStandardDate(source_deal_detail.term_start) as term_start, 
				dbo.FNAGetSQLStandardDate(source_deal_detail.term_end) as term_end,
				source_deal_detail.deal_volume_frequency,
				source_deal_detail.deal_volume_uom_id,
				sum(source_deal_detail.deal_volume  * gen_hedge_group_detail.percentage_use) as deal_volume
			FROM    	gen_hedge_group_detail INNER JOIN
					source_deal_header ON source_deal_header.source_deal_header_id = gen_hedge_group_detail.source_deal_header_id INNER JOIN
				source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id INNER JOIN
					source_system_book_map ON source_deal_header.source_system_book_id1 = source_system_book_map.source_system_book_id1 AND 
				source_deal_header.source_system_book_id2 = source_system_book_map.source_system_book_id2 AND 
					source_deal_header.source_system_book_id3 = source_system_book_map.source_system_book_id3 AND 
				source_deal_header.source_system_book_id4 = source_system_book_map.source_system_book_id4
			GROUP BY 	gen_hedge_group_detail.gen_hedge_group_id, 
				source_system_book_map.fas_book_id, 
				source_system_book_map.book_deal_type_map_id, source_deal_header.source_deal_type_id, 
				source_deal_header.deal_sub_type_type_id, 
					source_deal_detail.fixed_float_leg, source_deal_detail.Leg, 
				source_deal_detail.buy_sell_flag, source_deal_detail.curve_id,
				source_deal_detail.term_start, source_deal_detail.term_end,
				source_deal_detail.deal_volume_frequency,
				source_deal_detail.deal_volume_uom_id
			HAVING      	source_deal_detail.curve_id IS NOT NULL AND gen_hedge_group_detail.gen_hedge_group_id = @gen_hedge_group_id
			) gd inner join
			(SELECT * FROM fas_eff_hedge_rel_type_detail WHERE eff_test_profile_id = @eff_test_profile_id and hedge_or_item = 'i' and leg > 1) rel on
			gd.curve_id = rel.source_curve_def_id
		
			UNION
		
			SELECT 
			rel.deal_sequence_number, 
			NULL AS gen_deal_header_id, 
			DATEADD(mm, roll_months + next_month, gd.term_start) AS term_start, 
			dbo.FNALastDayInDate(DATEADD(mm, roll_months + next_month, gd.term_start)) AS term_end, 
			rel.leg AS Leg, 
			dbo.FNALastDayInDate(DATEADD(mm, roll_months + next_month, gd.term_start)) AS contract_expiration_date, 
			rel.fixed_float_flag AS fixed_float_flag, 
			rel.buy_sell_flag, 
			rel.source_curve_def_id AS curve_id, 
			NULL AS fixed_price, 
			NULL AS fixed_price_currency_id,
			NULL AS option_strike_price, 
			gd.deal_volume/(conv_factor * gd.strip_months) AS deal_volume, 
			gd.frequency AS deal_volume_frequency, 
			rel.uom_id AS deal_volume_uom_id, 
			' ' AS block_description, 
			NULL AS internal_deal_type_value_id, NULL AS internal_deal_subtype_value_id, 
			@gen_hedge_group_desc AS deal_detail_description,
			'1990-01-01'  as  hedge_term_start, -- **UPDATE this later
			ISNULL(rel.price_adder, 0) price_adder,
			ISNULL(rel.price_multiplier, 1) price_multiplier
		 
			FROM 
			(SELECT top 1 @eff_test_profile_id eff_test_profile_id,
				ISNULL(source_deal_detail.curve_id, -1) as curve_id,
				dbo.FNAGetSQLStandardDate(MAX(source_deal_detail.term_start)) as term_start, 
				dbo.FNAGetSQLStandardDate(MAX(source_deal_detail.term_end)) as term_end,
				MAX(strip_year_overlap) strip_months,
				MAX(roll_forward_year) roll_months,
				MAX(volume_mix_percentage) mix_per,
				MAX(uom_conversion_factor) conv_factor,
				MAX(deal_volume_frequency) frequency,
				sum(source_deal_detail.deal_volume * gen_hedge_group_detail.percentage_use) as deal_volume
			FROM    gen_hedge_group_detail INNER JOIN
					source_deal_header ON source_deal_header.source_deal_header_id = gen_hedge_group_detail.source_deal_header_id INNER JOIN
				source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id INNER JOIN
					source_system_book_map ON source_deal_header.source_system_book_id1 = source_system_book_map.source_system_book_id1 AND 
				source_deal_header.source_system_book_id2 = source_system_book_map.source_system_book_id2 AND 
					source_deal_header.source_system_book_id3 = source_system_book_map.source_system_book_id3 AND 
				source_deal_header.source_system_book_id4 = source_system_book_map.source_system_book_id4 inner join
				fas_eff_hedge_rel_type_detail reld on reld.source_curve_def_id = ISNULL(source_deal_detail.curve_id, -1) and
				reld.hedge_or_item = 'h' and reld.eff_test_profile_id = @eff_test_profile_id 
			
			WHERE gen_hedge_group_detail.gen_hedge_group_id = @gen_hedge_group_id
			GROUP BY eff_test_profile_id, source_deal_detail.curve_id
			HAVING  source_deal_detail.curve_id IS NOT NULL ) gd inner join
			strip_months_def smd on smd.strip_months = gd.strip_months inner join
			(SELECT fehr.*, spcd.uom_id FROM fas_eff_hedge_rel_type_detail fehr inner join
			source_price_curve_def spcd on spcd.source_curve_def_id = fehr.source_curve_def_id
			WHERE eff_test_profile_id = @eff_test_profile_id and hedge_or_item = 'i' and leg = 1  ) AS rel on
			rel.eff_test_profile_id = gd.eff_test_profile_id
		END

		ELSE
		BEGIN

			/*
			--script join
						--INNER JOIN #deal_header_info dhi ON 1 = 1 '
			--+ CASE WHEN @is_script = 'y' THEN ' 
			
			--	AND dhi.source_deal_type_id = fehrtd.source_deal_type_id	 
			--	AND dhi.strip_month_from	= fehrtd.strip_month_from		 
			--	AND dhi.strip_month_to		= fehrtd.strip_month_to			 
			--	AND dhi.source_curve_def_id = fehrtd.source_curve_def_id	 
			--	AND dhi.trader_id			= fehrt.item_trader_id			 
			--	AND dhi.counterparty_id		= fehrt.item_counterparty_id 
			--	'
			--ELSE '
			--	AND dhi.strip_month_from	= fehrtd.strip_month_from		 
			--	AND dhi.strip_month_to		= fehrtd.strip_month_to	' END + 
			--'

			*/
			SET @sql = '
			INSERT INTO #gen_deal_detail
			SELECT fehrtd.deal_sequence_number, 
				NULL AS gen_deal_header_id, 
				DATEADD(yy, hedge_item_month_diff.roll_forward_year,
					DATEADD(mm, hedge_item_month_diff.month_diff, #gen_min_hedge_volume.term_start)) AS term_start, 
				DBO.FNALastDayInDate(DATEADD(yy, hedge_item_month_diff.roll_forward_year,
					DATEADD(mm, hedge_item_month_diff.month_diff, #gen_min_hedge_volume.term_end))) AS term_end, 
				fehrtd.leg AS Leg, 
				dbo.FNALastDayInDate(DATEADD(yy, hedge_item_month_diff.roll_forward_year,
					DATEADD(mm, hedge_item_month_diff.month_diff, #gen_min_hedge_volume.term_end))) AS contract_expiration_date, 
				fehrtd.fixed_float_flag AS fixed_float_flag, 	
				-- automatic handling buy/sell rel type.. IF setup for der buy it can handle sell
				CASE WHEN (#gen_min_hedge_volume.oppositve_buy_sell = 1) THEN
					CASE WHEN (fehrtd.buy_sell_flag = ''b'') THEN ''s''
					ELSE ''b'' END		
				ELSE
					fehrtd.buy_sell_flag
				END buy_sell_flag,
					fehrtd.source_curve_def_id AS curve_id, 
				NULL AS fixed_price, 
				NULL AS fixed_price_currency_id,
				NULL AS option_strike_price, 
				round((#gen_min_hedge_volume.deal_volume * fehrt.hedge_to_item_conv_factor * 
					fehrtd.uom_conversion_factor * 
					fehrtd.volume_mix_percentage), ISNULL(fehrtd.volume_round, 0)) AS deal_volume, 
				#gen_min_hedge_volume.deal_volume_frequency AS deal_volume_frequency, 
				NULL AS deal_volume_uom_id, 
				'' '' AS block_description, NULL 
					AS internal_deal_type_value_id, NULL AS internal_deal_subtype_value_id, 
				''' + @gen_hedge_group_desc + ''' AS deal_detail_description,
				''1990-01-01''  as  hedge_term_start,  
				ISNULL(fehrtd.price_adder, 0) price_adder,
				ISNULL(fehrtd.price_multiplier, 1) price_multiplier
				--, fehrtd.strip_month_from
				--, fehrtd.strip_month_to
				--, hedge_item_month_diff.*
			FROM  fas_eff_hedge_rel_type fehrt
			INNER JOIN fas_eff_hedge_rel_type_detail fehrtd ON fehrt.eff_test_profile_id = fehrtd.eff_test_profile_id
			INNER JOIN fas_books ON fehrt.fas_book_id = fas_books.fas_book_id 
			INNER JOIN portfolio_hierarchy ON fas_books.fas_book_id = portfolio_hierarchy.entity_id 
			INNER JOIN fas_strategy ON portfolio_hierarchy.parent_entity_id = fas_strategy.fas_strategy_id
			INNER JOIN source_system_book_map ON fehrtd.book_deal_type_map_id = source_system_book_map.book_deal_type_map_id
			INNER JOIN #gen_min_hedge_volume ON #gen_min_hedge_volume.eff_test_profile_id = fehrtd.eff_test_profile_id
			INNER JOIN (SELECT 	(dbo.FNAGetMonthAsInt(item_tenor.item_strip_month_from) -  
							dbo.FNAGetMonthAsInt(hedge_tenor.hedge_strip_month_from)) As month_diff,
						hedge_tenor.hedge_strip_month_from, 
						item_tenor.item_strip_month_from, 
						item_tenor.roll_forward_year,
						hedge_tenor.eff_test_profile_id as eff_test_profile_id
						FROM 
							(SELECT	MIN(strip_month_from) As hedge_strip_month_from, 
								' + CAST(@eff_test_profile_id AS VARCHAR(100)) + ' as eff_test_profile_id 
							FROM    fas_eff_hedge_rel_type_detail
							WHERE   eff_test_profile_id = ' + CAST(@eff_test_profile_id AS VARCHAR(100)) + ' AND hedge_or_item = ''h'') hedge_tenor 
							INNER JOIN (SELECT	MIN(strip_month_from) As item_strip_month_from, 
										MIN(roll_forward_year) AS roll_forward_year, 
										' + CAST(@eff_test_profile_id AS VARCHAR(100)) + ' as eff_test_profile_id
										FROM    fas_eff_hedge_rel_type_detail
							WHERE   eff_test_profile_id = ' + CAST(@eff_test_profile_id AS VARCHAR(100)) + ' AND hedge_or_item = ''i'') item_tenor ON
								hedge_tenor.eff_test_profile_id = item_tenor.eff_test_profile_id) hedge_item_month_diff
				ON 	hedge_item_month_diff.eff_test_profile_id = fehrt.eff_test_profile_id
			WHERE  fehrtd.hedge_or_item = ''i'''
			
			EXEC spa_print @sql 
			EXEC(@sql)

		END
	END
	ELSE 
	BEGIN
		--Get the items to be generated
		INSERT INTO #gen_deal_detail
		SELECT     fas_link_detail.source_deal_header_id, NULL AS gen_deal_header_id, source_deal_detail.term_start, source_deal_detail.term_end, 
				   source_deal_detail.Leg, source_deal_detail.contract_expiration_date, source_deal_detail.fixed_float_leg, source_deal_detail.buy_sell_flag, 
				   source_deal_detail.curve_id, NULL as fixed_price, source_deal_detail.fixed_price_currency_id, source_deal_detail.option_strike_price, 
				   source_deal_detail.deal_volume , 
				   source_deal_detail.deal_volume_frequency, source_deal_detail.deal_volume_uom_id, 
				   source_deal_detail.block_description, NULL AS internal_deal_type_value_id, NULL AS internal_deal_subtype_value_id, 
				   source_deal_detail.deal_detail_description,
				   '1990-01-01'  as  hedge_term_start, -- **UPDATE this later
					0 price_adder,
					1 price_multiplier
		FROM       fas_link_detail 
		INNER JOIN source_deal_header ON fas_link_detail.source_deal_header_id = source_deal_header.source_deal_header_id 
		INNER JOIN source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id
		WHERE     (fas_link_detail.link_id = @reprice_items_id) AND (fas_link_detail.hedge_or_item = @hedge_or_item) AND (fas_link_detail.percentage_included <> 0)

	END

	--add source_deal_header_id to check onpeak off peak
	ALTER TABLE #gen_deal_detail ADD source_deal_header_id INT
	
	UPDATE #gen_deal_detail 
	SET source_deal_header_id = SUBSTRING(@gen_hedge_group_name, CHARINDEX(':', @gen_hedge_group_name) + 1,CHARINDEX('(', @gen_hedge_group_name)-CHARINDEX(':', @gen_hedge_group_name) - 1)  -- trim header id FROM @gen_hedge_group_name and UPDATE to table
	FROM #gen_deal_detail

	--SELECT * , sdd.fixed_price
	UPDATE gdd
	SET gdd.fixed_price = CASE WHEN gdd.fixed_price IS NULL THEN sdd.fixed_price ELSE gdd.fixed_price END
		, gdd.fixed_price_currency_id = CASE WHEN gdd.fixed_price_currency_id IS NULL THEN sdd.fixed_price_currency_id ELSE gdd.fixed_price_currency_id END 
		, gdd.deal_volume_uom_id = CASE WHEN gdd.deal_volume_uom_id IS NULL THEN sdd.deal_volume_uom_id ELSE gdd.deal_volume_uom_id END 
	FROM #gen_deal_detail gdd
	INNER JOIN source_deal_detail sdd ON gdd.source_deal_header_id = sdd.source_deal_header_id
		AND gdd.term_start = sdd.term_start

	--SELECT * from #gen_deal_detail
	--return 

	---------- ================TENOR MATCH LOGIC for REPRICING ONLY
	----------------------------------------------------------------
	IF @reprice_items_id IS NOT NULL OR (@past_perfect_hedge = 'y')
	BEGIN
		CREATE TABLE #tempMonths (
			[id] [INT] IDENTITY (1, 1) NOT NULL ,
			[term_start] [DATETIME] NULL ,
			[tenor_from] [DATETIME] NULL ,
			[tenor_to] [DATETIME] NULL
		) ON [PRIMARY]

		INSERT INTO #tempMonths (term_start)
		SELECT DISTINCT term_start FROM #gen_deal_detail(NOLOCK)
		ORDER BY term_start

		--SET @tenor_from = '2005-07-01'
		--SET @tenor_to = '2005-09-01'
		-- SELECT * FROM  #gen_deal_detail
	
		DECLARE @no_of_month INT
		SET @no_of_month = (SELECT DATEPART(mm,@tenor_to)-DATEPART(mm,@tenor_from) )

		IF (SELECT COUNT(*) FROM #tempMonths) <> (@no_of_month + 1)
		BEGIN 
			INSERT INTO #run_status
			SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'spa_gen_transaction' Area, 
							'Application Error' Status, 
				'The no of contract months do not match with  the number of current hedged items.' ,'Please change the tenor from and to to  match the number of current contract months.'
			--RETURN
		END
	
		DECLARE @counter INT
		SET @counter = 1
		DECLARE @maxCounter INT
		SET @maxCounter = (SELECT MAX(id) from #tempMonths)
		WHILE	@counter <= @maxCounter
			BEGIN
				UPDATE #tempMonths
				SET tenor_from =dbo.FNAGetContractMonth(@tenor_from) ,
					tenor_to =  dbo.FNALastDayInDate(@tenor_from)
				WHERE id = @counter
			
				SET @tenor_from = dbo.FNAGetSQLStandardDate(DATEADD(mm, 1, @tenor_from ))

				SET @counter = @counter+1
			END

		UPDATE A
		SET A.term_start = B.tenor_from, A.term_end = B.tenor_to, A.contract_expiration_date = B.tenor_to
		FROM #gen_deal_detail  A (NOLOCK) INNER JOIN
				#tempMonths B(NOLOCK)
		ON A.term_start = B.term_start
		
	END

	IF @debug = 1
		EXEC spa_print 'After inserting #gen_detail'

	--------------- FOR ROLL FORWARD HEDGES match new  items term month with hedges ------------------
	-----------------------------------------------------------------------------------------------------
	IF @perfect_hedge = 'n' AND @total_legs < 3
	BEGIN
		CREATE TABLE #tempMonthsItems (
			[id] [INT] IDENTITY (1, 1) NOT NULL ,
			[term_start] [DATETIME] NULL ,
		) ON [PRIMARY]
	
		CREATE TABLE #tempMonthsHedges (
			[id] [INT] IDENTITY (1, 1) NOT NULL ,
			[term_start] [DATETIME] NULL ,
		) ON [PRIMARY]
	
		INSERT INTO #tempMonthsItems (term_start)
		SELECT DISTINCT term_start FROM #gen_deal_detail(NOLOCK)
		ORDER BY term_start
	
		IF @reprice_items_id IS NULL
		BEGIN
			INSERT INTO #tempMonthsHedges (term_start)
			SELECT DISTINCT sdd.term_start FROM 
			gen_hedge_group_detail fld INNER JOIN
			source_deal_detail sdd ON sdd.source_deal_header_id = fld.source_deal_header_id
			WHERE fld.gen_hedge_group_id = @gen_hedge_group_id 
			ORDER BY sdd.term_start

		END
		ELSE
		BEGIN
			INSERT INTO #tempMonthsHedges (term_start)
			SELECT DISTINCT sdd.term_start FROM 
			fas_link_detail fld INNER JOIN
			source_deal_detail sdd ON sdd.source_deal_header_id = fld.source_deal_header_id
			WHERE fld.link_id = @reprice_items_id and fld.hedge_or_item = 'h'
			ORDER BY sdd.term_start
		END
	
		IF (SELECT COUNT(*) FROM #tempMonthsItems) <> (SELECT COUNT(*) FROM #tempMonthsHedges)
		BEGIN 
			INSERT INTO #run_status
			SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'spa_gen_transaction' Area, 
							'Application Error' Status, 
				'The no of contract months do not match with  the number of current hedged items.' ,'Please change the tenor from and to to  match the number of current contract months.'
			--RETURN
		END
	
		UPDATE   A SET A.hedge_term_start = C.term_start
		FROM #gen_deal_detail  A (NOLOCK) INNER JOIN
		#tempMonthsItems B ON A.term_start = B.term_start INNER JOIN
		#tempMonthsHedges C ON C.id = B.id
	END
	--SELECT * FROM #gen_deal_detail 

	IF @debug = 1
		EXEC spa_print 'After fixing roll forward tenor'

	--------------- END OF FOR ROLL FORWARD HEDGES match new  items term month with hedges ------------------
	-----------------------------------------------------------------------------------------------------

	--RETURN 
	--SELECT * FROM #gen_deal_detail
	-----------------------------------------------------------------------------------------------------
	-----------------End of Step 3
	---------------------------------------------------------------------------------------------------

	CREATE TABLE #gen_deal_header(
		deal_sequence_number INT, 
		gen_deal_header_id INT NULL, 
		source_system_id INT NULL, 
		gen_status CHAR(1) COLLATE DATABASE_DEFAULT NULL, 
		number_attempts INT NULL, 
		deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT NULL, 
		deal_date DATETIME NULL, 
		physical_financial_flag CHAR(10) COLLATE DATABASE_DEFAULT NULL, 
		trader_id VARCHAR(50) COLLATE DATABASE_DEFAULT NULL, 
		counterparty_id VARCHAR(50) COLLATE DATABASE_DEFAULT NULL, 
		entire_term_start DATETIME NULL, 
		entire_term_end DATETIME NULL, 
		source_deal_type_id VARCHAR(50) COLLATE DATABASE_DEFAULT NULL, 
		deal_sub_type_type_id VARCHAR(50) COLLATE DATABASE_DEFAULT NULL, 
		option_flag CHAR(1) COLLATE DATABASE_DEFAULT NULL, 
		option_type CHAR(1) COLLATE DATABASE_DEFAULT NULL, 
		option_excercise_type CHAR(1) COLLATE DATABASE_DEFAULT NULL, 
		source_system_book_id1 VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL, 
		source_system_book_id2 VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL, 
		source_system_book_id3 VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL, 
		source_system_book_id4 VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL, 
		description1 VARCHAR(100) COLLATE DATABASE_DEFAULT NULL, 
		description2 VARCHAR(50) COLLATE DATABASE_DEFAULT NULL, 
		description3 VARCHAR(50) COLLATE DATABASE_DEFAULT NULL, 
		deal_category_value_id INT NULL,
		process_id VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
		recid INT IDENTITY(1,1)
	)
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	-- Step 4: Create deal header(s)
	IF @perfect_hedge = 'n'
	BEGIN
		IF @reprice_items_id IS NULL 
		BEGIN
			INSERT INTO  #gen_deal_header
			SELECT  fas_eff_hedge_rel_type_detail.deal_sequence_number
				, NULL AS gen_deal_header_id
				, @source_system_id AS source_system_id
				, 'a' AS gen_status
				, 0 AS number_attempts
				, NULL AS deal_id
				, (SELECT dbo.FNAGetSQLStandardDate(hedge_effective_date) FROM gen_hedge_group WHERE gen_hedge_group_id = @gen_hedge_group_id) AS deal_date
				, 'f' AS physical_financial_flag
				, fas_eff_hedge_rel_type.item_trader_id AS trader_id
				, fas_eff_hedge_rel_type.item_counterparty_id AS counterparty_id
				, calc_terms.term_start AS entire_term_start
				, calc_terms.term_end AS entire_term_end
				, fas_eff_hedge_rel_type_detail.source_deal_type_id AS source_deal_type_id
				, fas_eff_hedge_rel_type_detail.deal_sub_type_id AS deal_sub_type_type_id
				, 'n' AS option_flag, NULL AS option_type
				, NULL AS option_excercise_type
				, source_system_book_map.source_system_book_id1 AS source_system_book_id1
				, source_system_book_map.source_system_book_id2 AS source_system_book_id2
				, source_system_book_map.source_system_book_id3 AS source_system_book_id3
				, source_system_book_map.source_system_book_id4 AS source_system_book_id4
				, @gen_hedge_group_desc AS description1
				, ' ' description2
				, ' ' description3
				, 476 deal_category_value_id
				, @process_id as process_id
			FROM fas_eff_hedge_rel_type 
			INNER JOIN fas_eff_hedge_rel_type_detail ON fas_eff_hedge_rel_type.eff_test_profile_id = fas_eff_hedge_rel_type_detail.eff_test_profile_id 
			INNER JOIN fas_books ON fas_eff_hedge_rel_type.fas_book_id = fas_books.fas_book_id 
			INNER JOIN portfolio_hierarchy ON fas_books.fas_book_id = portfolio_hierarchy.entity_id 
			INNER JOIN fas_strategy ON portfolio_hierarchy.parent_entity_id = fas_strategy.fas_strategy_id 
			INNER JOIN source_system_book_map ON fas_eff_hedge_rel_type_detail.book_deal_type_map_id = source_system_book_map.book_deal_type_map_id 
			INNER JOIN (SELECT deal_sequence_number 
						, min(term_start) term_start
						, MAX(term_end) term_end 
						FROM #gen_deal_detail GROUP BY deal_sequence_number) calc_terms 
						ON calc_terms.deal_sequence_number = fas_eff_hedge_rel_type_detail.deal_sequence_number	
			WHERE 1 = 1
				AND fas_eff_hedge_rel_type_detail.hedge_or_item = 'i' 
				AND fas_eff_hedge_rel_type_detail.eff_test_profile_id = @eff_test_profile_id 
				AND fas_eff_hedge_rel_type_detail.leg = 1
		END
		ELSE
		BEGIN
			IF @debug = 1
			EXEC spa_print 'Before #gen_header insert'
	
			INSERT INTO #gen_deal_header
			SELECT  ggd.source_deal_header_id, NULL AS gen_deal_header_id, 
				--sdd.source_system_id 
				@source_system_id AS source_system_id
				, 'a' AS gen_status, 
				0 AS number_attempts, NULL AS deal_id, 
				(SELECT dbo.FNAGetSQLStandardDate(hedge_effective_date) FROM gen_hedge_group WHERE gen_hedge_group_id = @gen_hedge_group_id) AS deal_date, 
				'f' AS physical_financial_flag, sdd.trader_id AS trader_id, 
					sdd.counterparty_id AS counterparty_id, 
				calc_terms.term_start AS entire_term_start, 
				calc_terms.term_end AS entire_term_end, 
					sdd.source_deal_type_id AS source_deal_type_id, 
					sdd.deal_sub_type_type_id AS deal_sub_type_type_id, 
				'n' AS option_flag, NULL AS option_type, NULL AS option_excercise_type, 
					sdd.source_system_book_id1 AS source_system_book_id1, 
					sdd.source_system_book_id2 AS source_system_book_id2, 
					sdd.source_system_book_id3 AS source_system_book_id3, 
					sdd.source_system_book_id4 AS source_system_book_id4, 
				@gen_hedge_group_desc AS description1, 
				' ' AS description2, ' ' AS description3, 
					476 AS deal_category_value_id,
				@process_id as process_id
			FROM    gen_hedge_group_detail ggd INNER JOIN
					source_deal_header sdd ON sdd.source_deal_header_id = ggd.source_deal_header_id INNER JOIN
				(SELECT deal_sequence_number , min(term_start) term_start, 
				MAX(term_end) term_end FROM #gen_deal_detail group by deal_sequence_number
				) calc_terms ON calc_terms.deal_sequence_number = ggd.source_deal_header_id	
			WHERE   ggd.gen_hedge_group_id = @gen_hedge_group_id
	
		IF @debug = 1
			EXEC spa_print 'Right after #gen_header insert'
	
		END
	END

	--SELECT * FROM #gen_deal_header
	--return 
	-----------------End of Step 4
	IF @debug = 1
		EXEC spa_print 'After inserting #gen_header'

	--- Step 5
	-- Calculate item pricing
	--item prices
	-- getting hedges fixed prices for intraday adjustments
	DECLARE @buy_sell_flag CHAR(1)
	DECLARE @item_pricing_value_id INT
	DECLARE @curve_source_value_id INT
	DECLARE @hedge_effective_date DATETIME
	SET @item_pricing_value_id = NULL
	SET @buy_sell_flag = NULL
	SET @curve_source_value_id = NULL

	SELECT @buy_sell_flag = CASE WHEN hedge_fixed_price_value_id = 550 THEN NULL 
					 WHEN hedge_fixed_price_value_id = 551 THEN 'b'
					 ELSE 's' END,
		@item_pricing_value_id = item_pricing_value_id,
		@curve_source_value_id = gen_curve_source_value_id
	FROM  fas_eff_hedge_rel_type
	WHERE fas_eff_hedge_rel_type.eff_test_profile_id = @eff_test_profile_id

	--**ERROR**
	IF @item_pricing_value_id IS NULL OR @curve_source_value_id IS NULL
	BEGIN
		INSERT INTO #run_status
		SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
						'Application Error' Status, 
			'Selected relationship type required for item generation not found in the database. ' + @gen_hedge_group_desc Message, 
			'Please contact technical support.' Recommendation
	END

	--SET @item_pricing_value_id = 430
	 --Get items EOD item prices
	IF @perfect_hedge = 'n'
	BEGIN
		CREATE TABLE #item_prices (
								deal_sequence_number	INT
								, source_curve_def_id	INT
								, source_currency_id	INT
								, uom_id				INT
								, maturity_date			DATETIME	
								, curve_value			NUMERIC(38,10)
								, avg_curve_value		NUMERIC(38,10)
								, hedge_term_start		DATETIME	
								, item_deal_date		DATETIME)

		INSERT INTO #item_prices (				
								deal_sequence_number	
								, source_curve_def_id	
								, source_currency_id	
								, uom_id				
								, maturity_date			
								, curve_value			
								, avg_curve_value		
								, hedge_term_start		
								, item_deal_date)
 		SELECT 	#gen_deal_detail.deal_sequence_number, 
			source_price_curve_def.source_curve_def_id, 
			source_price_curve_def.source_currency_id,
			source_price_curve_def.uom_id,
			dbo.FNAGetSQLStandardDate(source_price_curve.maturity_date) as maturity_date, 
			source_price_curve.curve_value, avg_price.avg_curve_value,
			#gen_deal_detail.hedge_term_start,
			gen_hedge_group.hedge_effective_date item_deal_date 
		FROM source_price_curve_def 
		INNER JOIN source_price_curve ON source_price_curve.source_curve_def_id = source_price_curve_def.source_curve_def_id  
		INNER JOIN gen_hedge_group  ON source_price_curve.as_of_date = gen_hedge_group.hedge_effective_date 
		INNER JOIN #gen_deal_detail ON  #gen_deal_detail.curve_id = source_price_curve_def.source_curve_def_id 
			AND #gen_deal_detail.term_start = source_price_curve.maturity_date 
		INNER JOIN
			( 
				SELECT 	#gen_deal_detail.deal_sequence_number,
					AVG(source_price_curve.curve_value) as avg_curve_value 
				FROM source_price_curve_def 
				INNER JOIN source_price_curve ON source_price_curve.source_curve_def_id = source_price_curve_def.source_curve_def_id  
				INNER JOIN gen_hedge_group  ON source_price_curve.as_of_date = gen_hedge_group.hedge_effective_date 
				INNER JOIN #gen_deal_detail ON  #gen_deal_detail.curve_id = source_price_curve_def.source_curve_def_id 
					AND #gen_deal_detail.term_start = source_price_curve.maturity_date
				WHERE 	gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id 
					AND source_price_curve.assessment_curve_type_value_id = 77 
					AND source_price_curve.curve_source_value_id = @curve_source_value_id 
					AND source_price_curve.maturity_date in (SELECT DISTINCT term_start FROM #gen_deal_detail) 
					AND source_price_curve.source_curve_def_id in  (SELECT DISTINCT curve_id FROM #gen_deal_detail WHERE curve_id IS NOT NULL)
				group by #gen_deal_detail.deal_sequence_number
		) avg_price ON avg_price.deal_sequence_number = #gen_deal_detail.deal_sequence_number		
		WHERE  	gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id 
			AND source_price_curve.assessment_curve_type_value_id = 77 
			AND source_price_curve.curve_source_value_id = @curve_source_value_id
			AND source_price_curve.maturity_date in  (SELECT DISTINCT term_start FROM #gen_deal_detail) 
			AND source_price_curve.source_curve_def_id in (SELECT DISTINCT curve_id FROM #gen_deal_detail WHERE curve_id IS NOT NULL)
	
		CREATE TABLE #rtc_curves(source_curve_def_id INT, term_start DATETIME, deal_sequence_number INT, hedge_term_start DATETIME, main_curve_id INT)

		-- check IF rtc curves are mapped 
		IF EXISTS(SELECT TOP 1 rspc.rtc_curve_def_id
				FROM #gen_deal_detail ipp
				INNER JOIN rtc_source_price_curve rspc ON ipp.curve_id = rspc.rtc_curve_def_id)
		BEGIN 
			--IF main is missing add frm rtc curves -- also check block defination FROM main deal header 
			IF NOT EXISTS(SELECT TOP 1 source_curve_def_id FROM #item_prices)
			BEGIN
				INSERT INTO #rtc_curves(source_curve_def_id, term_start, deal_sequence_number, hedge_term_start, main_curve_id)
				SELECT rspc.rtc_curve, ipp.term_start, ipp.deal_sequence_number, ipp.hedge_term_start, ipp.curve_id 
				FROM #gen_deal_detail ipp
				INNER JOIN rtc_source_price_curve rspc ON ipp.curve_id = rspc.rtc_curve_def_id
				INNER JOIN source_deal_header sdh On sdh.source_deal_header_id = ipp.source_deal_header_id
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = rspc.rtc_curve	
					AND spcd.block_define_id = CASE WHEN sdh.block_define_id = 10000134 THEN 50000342 
													WHEN sdh.block_define_id = 10000135 THEN 50000341 
												ELSE sdh.block_define_id END

				INSERT INTO #item_prices (				
								deal_sequence_number	
								, source_curve_def_id	
								, source_currency_id	
								, uom_id				
								, maturity_date			
								, curve_value			
								, avg_curve_value		
								, hedge_term_start		
								, item_deal_date)
				SELECT 	rc.deal_sequence_number, 
						rc.main_curve_id, 
						spcd.source_currency_id,
						spcd.uom_id,
						dbo.FNAGetSQLStandardDate(spc.maturity_date) as maturity_date, 
						spc.curve_value, avg_price.avg_curve_value,
						rc.hedge_term_start,
						gen_hedge_group.hedge_effective_date item_deal_date 
				FROM source_price_curve_def spcd
				INNER JOIN #rtc_curves rc ON rc.source_curve_def_id = spcd.source_curve_def_id  
				INNER JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id  
					AND rc.term_start = spc.maturity_date 
				INNER JOIN gen_hedge_group ON spc.as_of_date = gen_hedge_group.hedge_effective_date 
				INNER JOIN
					(
						SELECT 	rc_inner.deal_sequence_number,
							AVG(spc_inner.curve_value) as avg_curve_value 
						FROM source_price_curve_def spcd_in
						INNER JOIN #rtc_curves rc_inner ON rc_inner.source_curve_def_id = spcd_in.source_curve_def_id  
						INNER JOIN source_price_curve spc_inner ON spc_inner.source_curve_def_id = spcd_in.source_curve_def_id 
							AND rc_inner.term_start = spc_inner.maturity_date 
						INNER JOIN gen_hedge_group  ON spc_inner.as_of_date = gen_hedge_group.hedge_effective_date 
						--INNER JOIN #gen_deal_detail ON  #gen_deal_detail.curve_id = spcd_in.source_curve_def_id 
						WHERE 	gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id 
							AND spc_inner.assessment_curve_type_value_id = 77 
							AND spc_inner.curve_source_value_id = @curve_source_value_id 
							AND spc_inner.maturity_date IN (SELECT DISTINCT term_start FROM #gen_deal_detail) 
							AND spc_inner.source_curve_def_id IN  (SELECT DISTINCT source_curve_def_id FROM #rtc_curves WHERE curve_id IS NOT NULL)
						group by rc_inner.deal_sequence_number
				) avg_price ON avg_price.deal_sequence_number = rc.deal_sequence_number		
				WHERE  	gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id 
					AND spc.assessment_curve_type_value_id = 77 
					AND spc.curve_source_value_id = @curve_source_value_id
					AND spc.maturity_date IN  (SELECT DISTINCT term_start FROM #gen_deal_detail) 
					AND spc.source_curve_def_id IN (SELECT DISTINCT source_curve_def_id FROM #rtc_curves WHERE curve_id IS NOT NULL)
			END

			IF NOT EXISTS(SELECT TOP 1 source_curve_def_id FROM #item_prices)
			BEGIN
				DELETE FROM #rtc_curves

				INSERT INTO #rtc_curves(source_curve_def_id, term_start, deal_sequence_number, hedge_term_start, main_curve_id)			 
				SELECT COALESCE(spcd.proxy_source_curve_def_id, spcd.monthly_index, spcd.proxy_curve_id3) source_curve_def_id
					, ipp.term_start, ipp.deal_sequence_number, ipp.hedge_term_start, ipp.curve_id--, sdh.block_define_id , spcd.block_define_id
				FROM #gen_deal_detail ipp
				INNER JOIN rtc_source_price_curve rspc ON ipp.curve_id = rspc.rtc_curve_def_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ipp.source_deal_header_id
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = rspc.rtc_curve	
					AND spcd.block_define_id = CASE WHEN sdh.block_define_id = 10000134 THEN 50000342 
													WHEN sdh.block_define_id = 10000135 THEN 50000341 
												ELSE sdh.block_define_id END

				INSERT INTO #item_prices (				
								deal_sequence_number	
								, source_curve_def_id	
								, source_currency_id	
								, uom_id				
								, maturity_date			
								, curve_value			
								, avg_curve_value		
								, hedge_term_start		
								, item_deal_date)
				SELECT 	rc.deal_sequence_number, 
						rc.main_curve_id, 
						spcd.source_currency_id,
						spcd.uom_id,
						dbo.FNAGetSQLStandardDate(spc.maturity_date) as maturity_date, 
						spc.curve_value, avg_price.avg_curve_value,
						rc.hedge_term_start,
						gen_hedge_group.hedge_effective_date item_deal_date 
				FROM source_price_curve_def spcd
				INNER JOIN #rtc_curves rc ON rc.source_curve_def_id = spcd.source_curve_def_id  
				INNER JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id  
					AND rc.term_start = spc.maturity_date 
				INNER JOIN gen_hedge_group ON spc.as_of_date = gen_hedge_group.hedge_effective_date 
				INNER JOIN
					(
						SELECT 	rc_inner.deal_sequence_number,
							AVG(spc_inner.curve_value) as avg_curve_value 
						FROM source_price_curve_def spcd_in
						INNER JOIN #rtc_curves rc_inner ON rc_inner.source_curve_def_id = spcd_in.source_curve_def_id  
						INNER JOIN source_price_curve spc_inner ON spc_inner.source_curve_def_id = spcd_in.source_curve_def_id 
							AND rc_inner.term_start = spc_inner.maturity_date 
						INNER JOIN gen_hedge_group  ON spc_inner.as_of_date = gen_hedge_group.hedge_effective_date 
						--INNER JOIN #gen_deal_detail ON  #gen_deal_detail.curve_id = spcd_in.source_curve_def_id 
						WHERE 	gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id 
							AND spc_inner.assessment_curve_type_value_id = 77 
							AND spc_inner.curve_source_value_id = @curve_source_value_id 
							AND spc_inner.maturity_date IN (SELECT DISTINCT term_start FROM #gen_deal_detail) 
							AND spc_inner.source_curve_def_id IN  (SELECT DISTINCT source_curve_def_id FROM #rtc_curves WHERE curve_id IS NOT NULL)
						group by rc_inner.deal_sequence_number
				) avg_price ON avg_price.deal_sequence_number = rc.deal_sequence_number		
				WHERE  	gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id 
					AND spc.assessment_curve_type_value_id = 77 
					AND spc.curve_source_value_id = @curve_source_value_id
					AND spc.maturity_date IN  (SELECT DISTINCT term_start FROM #gen_deal_detail) 
					AND spc.source_curve_def_id IN (SELECT DISTINCT source_curve_def_id FROM #rtc_curves WHERE curve_id IS NOT NULL)
			END		
		END

		--IF main and rtc value is missing add from main curve's proxy curves
		IF NOT EXISTS(SELECT TOP 1 source_curve_def_id FROM #item_prices)
		BEGIN
			DELETE FROM #rtc_curves

			INSERT INTO #rtc_curves(source_curve_def_id, term_start, deal_sequence_number, hedge_term_start, main_curve_id)
			SELECT  COALESCE(spcd.proxy_source_curve_def_id, spcd.monthly_index, spcd.proxy_curve_id3) source_curve_def_id
				, ipp.term_start, ipp.deal_sequence_number, ipp.hedge_term_start, ipp.curve_id  
			FROM #gen_deal_detail ipp
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = ipp.curve_id  	
		
			INSERT INTO #item_prices (				
								deal_sequence_number	
								, source_curve_def_id	
								, source_currency_id	
								, uom_id				
								, maturity_date			
								, curve_value			
								, avg_curve_value		
								, hedge_term_start		
								, item_deal_date)
			SELECT 	rc.deal_sequence_number, 
					spcd.source_curve_def_id, 
					rc.main_curve_id,
					spcd.uom_id,
					dbo.FNAGetSQLStandardDate(spc.maturity_date) as maturity_date, 
					spc.curve_value, avg_price.avg_curve_value,
					rc.hedge_term_start,
					gen_hedge_group.hedge_effective_date item_deal_date 
			FROM source_price_curve_def spcd
			INNER JOIN #rtc_curves rc ON rc.source_curve_def_id = spcd.source_curve_def_id  
			INNER JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id  
				AND rc.term_start = spc.maturity_date 
			INNER JOIN gen_hedge_group ON spc.as_of_date = gen_hedge_group.hedge_effective_date 
			INNER JOIN
				(
					SELECT 	rc_inner.deal_sequence_number,
						AVG(spc_inner.curve_value) as avg_curve_value 
					FROM source_price_curve_def spcd_in
					INNER JOIN #rtc_curves rc_inner ON rc_inner.source_curve_def_id = spcd_in.source_curve_def_id  
					INNER JOIN source_price_curve spc_inner ON spc_inner.source_curve_def_id = spcd_in.source_curve_def_id 
						AND rc_inner.term_start = spc_inner.maturity_date 
					INNER JOIN gen_hedge_group  ON spc_inner.as_of_date = gen_hedge_group.hedge_effective_date 
					--INNER JOIN #gen_deal_detail ON  #gen_deal_detail.curve_id = spcd_in.source_curve_def_id 
					WHERE 	gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id 
						AND spc_inner.assessment_curve_type_value_id = 77 
						AND spc_inner.curve_source_value_id = @curve_source_value_id 
						AND spc_inner.maturity_date IN (SELECT DISTINCT term_start FROM #gen_deal_detail) 
						AND spc_inner.source_curve_def_id IN  (SELECT DISTINCT source_curve_def_id FROM #rtc_curves WHERE curve_id IS NOT NULL)
					group by rc_inner.deal_sequence_number
			) avg_price ON avg_price.deal_sequence_number = rc.deal_sequence_number		
			WHERE  	gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id 
				AND spc.assessment_curve_type_value_id = 77 
				AND spc.curve_source_value_id = @curve_source_value_id
				AND spc.maturity_date IN  (SELECT DISTINCT term_start FROM #gen_deal_detail) 
				AND spc.source_curve_def_id IN (SELECT DISTINCT source_curve_def_id FROM #rtc_curves WHERE curve_id IS NOT NULL)	
		END

		--logic changed --> IF item curve prices are not avaiable, take deal price of hedge.
		IF NOT EXISTS(SELECT TOP 1 source_curve_def_id FROM #item_prices)
		BEGIN
			DECLARE @new_item_deal_date DATETIME
			SELECT @new_item_deal_date = hedge_effective_date FROM gen_hedge_group WHERE gen_hedge_group_id = @gen_hedge_group_id

			INSERT INTO #item_prices (				
								deal_sequence_number	
								, source_curve_def_id	
								, source_currency_id	
								, uom_id				
								, maturity_date			
								, curve_value			
								, avg_curve_value		
								, hedge_term_start		
								, item_deal_date)
			SELECT deal_sequence_number, curve_id, fixed_price_currency_id
				, deal_volume_uom_id
				, term_start, fixed_price, fixed_price, term_start, @new_item_deal_date
			FROM #gen_deal_detail
		END
		
		--/*
		DECLARE @item_prices_count INT
		SET @item_prices_count  = 0
	
		SELECT @item_prices_count = COUNT(*) FROM #item_prices
		IF @item_prices_count IS NULL OR @item_prices_count = 0
		BEGIN
			--**ERROR**
			INSERT INTO #run_status
			SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
							'Application Error' Status, 
				'End of Day prices not found for items for as of date ' + dbo.FNADateFormat(gen_hedge_group.hedge_effective_date) + '. ' + @gen_hedge_group_desc Message, 
				'Please input end of day prices for items.' Recommendation
			FROM gen_hedge_group
			WHERE gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id 
		END
		--*/
	
		IF @debug = 1
			EXEC spa_print 'After getting item eod'
	END

	--**ERROR**
	--Check IF multiple currency unit found. IF so need to give error...	

	CREATE TABLE #hedge_prices
	(--source_deal_header_id INT, 
	--source_curve_def_id INT, 
	source_currency_id INT,
	uom_id INT,
	maturity_date DATETIME, 
	curve_value FLOAT, 
	hedge_deal_date DATETIME,
	avg_curve_value FLOAT)

	CREATE TABLE #hedge_fixed_prices
	(term_start DATETIME, 
	term_end DATETIME, 
	fixed_price_currency_id INT, 
	fixed_price FLOAT,
	avg_fixed_price FLOAT
	)

	-- get hedges fixed prices ONLY IF intra day adjustment is called for				 
	IF @item_pricing_value_id in (427, 428, 429, 430) AND @perfect_hedge = 'n'
	BEGIN
		IF @reprice_items_id IS NULL --Biren
		BEGIN
			SELECT 		term_start, term_end, 
					fixed_price_currency_id, 
					sum(fixed_price) as fixed_price
			INTO  #temp_f_price
			FROM(
			SELECT term_start, term_end, 
					fixed_price_currency_id, 
					source_deal_type_id,
					ISNULL(deal_sub_type_type_id, -1) deal_sub_type_type_id,
					sum(ISNULL(fixed_price, 0)) as fixed_price 
			FROM
			(
			SELECT 		source_deal_detail.term_start, source_deal_detail.term_end, 
					source_deal_detail.fixed_price_currency_id, 
					source_deal_header.source_deal_type_id,
					ISNULL(source_deal_header.deal_sub_type_type_id, -1) deal_sub_type_type_id,
					avg(ISNULL(source_deal_detail.fixed_price, 0)) as fixed_price 
			FROM    	gen_hedge_group_detail INNER JOIN
						source_deal_header ON source_deal_header.source_deal_header_id = gen_hedge_group_detail.source_deal_header_id INNER JOIN
		        		source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id 
			WHERE       	gen_hedge_group_detail.gen_hedge_group_id = @gen_hedge_group_id AND
					source_deal_detail.buy_sell_flag = ISNULL(@buy_sell_flag, source_deal_detail.buy_sell_flag)
					AND source_deal_detail.fixed_price IS NOT NULL
			GROUP BY 	source_deal_detail.term_start, source_deal_detail.term_end,
					source_deal_detail.fixed_price_currency_id ,
					source_deal_header.source_deal_type_id,
					ISNULL(source_deal_header.deal_sub_type_type_id, -1)
			) xx
			GROUP BY 	term_start, term_end,
					fixed_price_currency_id ,
					source_deal_type_id,
					ISNULL(deal_sub_type_type_id, -1)
			) yy
			GROUP  BY 	term_start, term_end, 
					fixed_price_currency_id
		
			INSERT INTO #hedge_fixed_prices
			SELECT *, (SELECT avg(fixed_price) FROM  (SELECT * FROM #temp_f_price) yy) avg_price
			FROM #temp_f_price 	

	-- 		SELECT 		source_deal_detail.term_start, source_deal_detail.term_end, 
	-- 				source_deal_detail.fixed_price_currency_id, 
	-- 				sum(ISNULL(source_deal_detail.fixed_price, 0)) as fixed_price,
	-- 				MAX(avg_price.avg_fixed_price) as avg_fixed_price
	-- 		--INTO 		#hedge_fixed_prices
	-- 		FROM    	gen_hedge_group_detail INNER JOIN
	-- 			        source_deal_header ON source_deal_header.source_deal_header_id = gen_hedge_group_detail.source_deal_header_id INNER JOIN
	-- 		        	source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id INNER JOIN
	-- 				(SELECT 	source_deal_detail.fixed_price_currency_id, 
	-- 						avg(ISNULL(source_deal_detail.fixed_price, 0)) as avg_fixed_price
	-- 				FROM    	gen_hedge_group_detail INNER JOIN
	-- 					        source_deal_header ON source_deal_header.source_deal_header_id = gen_hedge_group_detail.source_deal_header_id INNER JOIN
	-- 				        	source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id
	-- 				WHERE       	gen_hedge_group_detail.gen_hedge_group_id = @gen_hedge_group_id AND
	-- 						source_deal_detail.buy_sell_flag = ISNULL(@buy_sell_flag, source_deal_detail.buy_sell_flag)
	-- 
	-- 						and source_deal_detail.fixed_price IS NOT NULL AND source_deal_detail.fixed_price <> 0
	-- 				GROUP BY 	source_deal_detail.fixed_price_currency_id
	-- 				) avg_price ON avg_price.fixed_price_currency_id = source_deal_detail.fixed_price_currency_id
	-- 		WHERE       	gen_hedge_group_detail.gen_hedge_group_id = @gen_hedge_group_id AND
	-- 				source_deal_detail.buy_sell_flag = ISNULL(@buy_sell_flag, source_deal_detail.buy_sell_flag)
	-- 		GROUP BY 	source_deal_detail.term_start, source_deal_detail.term_end,
	-- 				source_deal_detail.fixed_price_currency_id
		END
		ELSE
		BEGIN
			SELECT 		term_start, term_end, 
					fixed_price_currency_id, 
					sum(fixed_price) as fixed_price
			INTO  #temp_f_price1
			FROM(
			SELECT term_start, term_end, 
					fixed_price_currency_id, 
					source_deal_type_id,
					ISNULL(deal_sub_type_type_id, -1) deal_sub_type_type_id,
					sum(ISNULL(fixed_price, 0)) as fixed_price 
			FROM
			(
			SELECT 		source_deal_detail.term_start, source_deal_detail.term_end, 
					source_deal_detail.fixed_price_currency_id, 
					source_deal_header.source_deal_type_id,
					ISNULL(source_deal_header.deal_sub_type_type_id, -1) deal_sub_type_type_id,
					avg(ISNULL(source_deal_detail.fixed_price, 0)) as fixed_price 
			FROM    	gen_hedge_group INNER JOIN
					fas_link_detail ON gen_hedge_group.reprice_items_id = fas_link_detail.link_id AND
							fas_link_detail.hedge_or_item = 'h' INNER JOIN
						source_deal_header ON source_deal_header.source_deal_header_id = fas_link_detail.source_deal_header_id INNER JOIN
		        		source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id 
			WHERE       	gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id AND
					source_deal_detail.buy_sell_flag = ISNULL(@buy_sell_flag, source_deal_detail.buy_sell_flag)
					AND source_deal_detail.fixed_price IS NOT NULL
			GROUP BY 	source_deal_detail.term_start, source_deal_detail.term_end,
					source_deal_detail.fixed_price_currency_id ,
					source_deal_header.source_deal_type_id,
					ISNULL(source_deal_header.deal_sub_type_type_id, -1)
			) xx
			GROUP BY 	term_start, term_end,
					fixed_price_currency_id ,
					source_deal_type_id,
					ISNULL(deal_sub_type_type_id, -1)
			) yy
			GROUP  BY 	term_start, term_end, 
					fixed_price_currency_id
		
			INSERT INTO #hedge_fixed_prices
			SELECT *, (SELECT avg(fixed_price) FROM  (SELECT * FROM #temp_f_price1) yy) avg_price
			FROM #temp_f_price1 

		END
	--	SELECT * FROM  #hedge_fixed_prices

		DECLARE @hedge_fixed_prices_count INT
		SET @hedge_fixed_prices_count  = 0
	
		SELECT @hedge_fixed_prices_count = COUNT(*) FROM #hedge_fixed_prices
		IF @hedge_fixed_prices_count IS NULL OR @hedge_fixed_prices_count = 0
		BEGIN
			--**ERROR**
			INSERT INTO #run_status
			SELECT 	'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
							'Application Error' Status, 
				'Could not find hedge fixed price in order to make intraday adjustments. ' + @gen_hedge_group_desc Message, 
				'Please contact technical support.' Recommendation
		
		END

		DECLARE @hedge_cur_units INT
		DECLARE @items_cur_units INT
		DECLARE @unique_hedge_item_cur_count INT
		SET	@hedge_cur_units = NULL
		SET	@items_cur_units = NULL
		SET @unique_hedge_item_cur_count = NULL
	
		SELECT @hedge_cur_units = COUNT(DISTINCT fixed_price_currency_id) FROM #hedge_fixed_prices
	
		-- IF heges prices are to be used for intraday adjustment THEN hedge currency should be unique
		--**ERROR**
		IF @hedge_cur_units > 1 OR @hedge_cur_units IS NULL
		BEGIN
			INSERT INTO #run_status
			SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'spa_gen_transaction' Area, 
							'Application Error' Status, 
				'Transaction Generation does not support intra-day pricing adjustments while hedges have multiple currency units in the same generation group.' Message, 
				'Please SELECT only hedge deal(s) with same currency units in generation group id: ' + CAST(@gen_hedge_group_id AS VARCHAR) Recommendation
		END 

		SELECT @items_cur_units = COUNT(DISTINCT source_currency_id) FROM #item_prices

		-- IF heges prices are to be used for intraday adjustment THEN item currency should be unique
		--**ERROR**
		IF @items_cur_units > 1 OR @items_cur_units IS NULL
		BEGIN
			INSERT INTO #run_status
			SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
							'Application Error' Status, 
				'Transaction Generation does not support intra-day pricing adjustments while items have multiple currency units in the same generation group.' + @gen_hedge_group_desc Message, 
				'For intra-day pricing adjustments ensure that hedge relationship Id: ' + CAST(@eff_test_profile_id AS VARCHAR) + ' has unique currency ids in generation group id: ' + CAST(@gen_hedge_group_id AS VARCHAR) Recommendation
		END 

		IF @hedge_cur_units = 1 AND @items_cur_units = 1 
		BEGIN				
			SELECT @unique_hedge_item_cur_count = COUNT(currency_id )
			FROM (SELECT DISTINCT fixed_price_currency_id as currency_id FROM #hedge_fixed_prices
				union
				SELECT DISTINCT source_currency_id as currency_id FROM #item_prices) unique_cur_id
			--SELECT @unique_hedge_item_cur_count

	-- 		SELECT @unique_hedge_cur_id = DISTINCT fixed_price_currency_id FROM #hedge_fixed_prices
	-- 		SELECT @unique_item_cur_id = DISTINCT source_currency_id FROM #item_prices
			-- IF heges prices are to be used for intraday adjustment THEN hedge and item currency should be the same
			--**ERROR**
			IF @unique_hedge_item_cur_count > 1
			BEGIN
				INSERT INTO #run_status
				SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
								'Application Error' Status, 
					'Transaction Generation does not support intra-day pricing adjustments while items and hedges have different currency units in the same generation group.' + @gen_hedge_group_desc Message, 
					'For intra-day pricing adjustments ensure that hedge relationship Id: ' + CAST(@eff_test_profile_id AS VARCHAR) + ' has hedge and items have the same currency ids in generation group id: ' + CAST(@gen_hedge_group_id AS VARCHAR) Recommendation
			END 
		END		

		--Get hedges EOD hedge prices
		IF @reprice_items_id IS NULL
		BEGIN
			SELECT 	source_currency_id,
				uom_id,
				maturity_date, 
				abs(sum(CASE when (buy_sell_flag = 's') THEN -1 ELSE +1 end * curve_value)) as curve_value,
				MAX(price_curves.deal_date) hedge_deal_date
			INTO #hedge_price_t
			FROM
			(SELECT DISTINCT source_deal_type_id,
				ISNULL(deal_sub_type_type_id, -1) deal_sub_type_type_id,
				buy_sell_flag, curve_id,  term_start
			FROM 	gen_hedge_group_detail  inner join 
				source_deal_detail on gen_hedge_group_detail.source_deal_header_id =  source_deal_detail.source_deal_header_id	
					AND source_deal_detail.curve_id IS NOT NULL INNER  JOIN	
				source_deal_header ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id 
			WHERE   gen_hedge_group_detail.gen_hedge_group_id = @gen_hedge_group_id) price_required INNER JOIN
			(SELECT 	source_price_curve_def.source_currency_id,
				source_price_curve_def.uom_id,
				maturity_date, source_price_curve.source_curve_def_id, curve_value, get_curves.deal_date
			FROM source_price_curve INNER JOIN
			source_price_curve_def ON source_price_curve_def.source_curve_def_id = source_price_curve.source_curve_def_id INNER JOIN
			(
			SELECT DISTINCT deal_date, curve_id, term_start
			FROM 	gen_hedge_group_detail  inner join 
				source_deal_detail on gen_hedge_group_detail.source_deal_header_id =  source_deal_detail.source_deal_header_id	
					AND source_deal_detail.curve_id IS NOT NULL INNER  JOIN	
				source_deal_header ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id 
			WHERE   	gen_hedge_group_detail.gen_hedge_group_id = @gen_hedge_group_id) get_curves ON
				get_curves.deal_date = source_price_curve.as_of_date AND
				get_curves.term_start = source_price_curve.maturity_date AND
				get_curves.curve_id = source_price_curve.source_curve_def_id AND
				source_price_curve.assessment_curve_type_value_id = 77 AND
				source_price_curve.curve_source_value_id = @curve_source_value_id) price_curves 
			ON 	price_required.curve_id = price_curves.source_curve_def_id AND
				price_required.term_start = price_curves.maturity_date 
			GROUP BY source_currency_id, uom_id, maturity_date
		
			INSERT INTO #hedge_prices
			SELECT *, (SELECT avg(curve_value) FROM  (SELECT * FROM #hedge_price_t) yy) as avg_curve_value
			FROM  #hedge_price_t	
		END
		ELSE
		BEGIN
			SELECT 	source_currency_id,
				uom_id,
				maturity_date, 
				abs(sum(CASE when (buy_sell_flag = 's') THEN -1 ELSE +1 end * curve_value)) as curve_value,
				MAX(price_curves.deal_date) hedge_deal_date
			INTO #hedge_price_t1
			FROM
			(SELECT DISTINCT source_deal_type_id,
				ISNULL(deal_sub_type_type_id, -1) deal_sub_type_type_id,
				buy_sell_flag, curve_id,  term_start
			FROM 	gen_hedge_group INNER JOIN
				fas_link_detail ON gen_hedge_group.reprice_items_id = fas_link_detail.link_id AND
					fas_link_detail.hedge_or_item = 'h' INNER JOIN
				source_deal_header ON source_deal_header.source_deal_header_id = fas_link_detail.source_deal_header_id INNER JOIN
				source_deal_detail on source_deal_header.source_deal_header_id =  source_deal_detail.source_deal_header_id	
					AND source_deal_detail.curve_id IS NOT NULL 
			WHERE   gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id) price_required INNER JOIN
			(SELECT 	source_price_curve_def.source_currency_id,
				source_price_curve_def.uom_id,
				maturity_date, source_price_curve.source_curve_def_id, curve_value, get_curves.deal_date
			FROM source_price_curve INNER JOIN
			source_price_curve_def ON source_price_curve_def.source_curve_def_id = source_price_curve.source_curve_def_id INNER JOIN
			(
			SELECT DISTINCT deal_date, curve_id, term_start
			FROM    gen_hedge_group INNER JOIN
				fas_link_detail ON gen_hedge_group.reprice_items_id = fas_link_detail.link_id AND
					fas_link_detail.hedge_or_item = 'h' INNER JOIN
				source_deal_header ON source_deal_header.source_deal_header_id = fas_link_detail.source_deal_header_id INNER JOIN
				source_deal_detail on source_deal_header.source_deal_header_id =  source_deal_detail.source_deal_header_id	
					AND source_deal_detail.curve_id IS NOT NULL 
			WHERE   	gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id) get_curves ON
				get_curves.deal_date = source_price_curve.as_of_date AND
				get_curves.term_start = source_price_curve.maturity_date AND
				get_curves.curve_id = source_price_curve.source_curve_def_id AND
				source_price_curve.assessment_curve_type_value_id = 77 AND
				source_price_curve.curve_source_value_id = @curve_source_value_id) price_curves 
			ON 	price_required.curve_id = price_curves.source_curve_def_id AND
				price_required.term_start = price_curves.maturity_date 
			GROUP BY source_currency_id, uom_id, maturity_date
		
			INSERT INTO #hedge_prices	
			SELECT *, (SELECT avg(curve_value) FROM  (SELECT * FROM #hedge_price_t1) yy) as avg_curve_value
			FROM  #hedge_price_t1

		--	SELECT * FROM #hedge_prices
		END	

		DECLARE @hedge_prices_count INT
		SET @hedge_prices_count  = 0
	
		SELECT @hedge_prices_count = COUNT(*) FROM #hedge_prices
		IF @hedge_prices_count IS NULL OR @hedge_prices_count = 0
		BEGIN
			--**ERROR**
			INSERT INTO #run_status
			SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
							'Application Error' Status, 
				'End of Day hedge prices not found for respective hedge deal date in order to make intraday adjustments. ' + @gen_hedge_group_desc Message, 
				'Please input end of day prices for hedges as of repsective hedge deal date.' Recommendation
		
		END

		SELECT @hedge_prices_count = COUNT(*) FROM (SELECT DISTINCT source_currency_id, uom_id
										FROM #hedge_prices) xx
	
		IF  @hedge_prices_count > 1
		BEGIN
			INSERT INTO #run_status
			SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
							'Application Error' Status, 
				'Transaction Generation does not support multiple currency units or volume unit of measures on hedges while adjusting intra-day price adjustments. ' + @gen_hedge_group_desc Message, 
				'You must SELECT end of day prices for hedged items: ' + CAST(@gen_hedge_group_id AS VARCHAR) Recommendation	
		END
	END

	IF @debug = 1
		EXEC spa_print 'After adjusting to hedge price movement'
	--SELECT @item_pricing_value_id

	--UPDATE volume units of items based on curve definition
	IF @perfect_hedge = 'n' AND @total_legs < 3
	BEGIN
		UPDATE #gen_deal_detail 
		SET 	#gen_deal_detail.deal_volume_uom_id = #item_prices.uom_id
		FROM 	#gen_deal_detail LEFT OUTER JOIN
			#item_prices ON #item_prices.deal_sequence_number = #gen_deal_detail.deal_sequence_number 
	
		--SELECT * FROM static_data_value WHERE value_id=426
		--UPDATE item prices and currency units 

		UPDATE #gen_deal_detail 
		SET 	#gen_deal_detail.fixed_price_currency_id = #item_prices.source_currency_id,
			#gen_deal_detail.fixed_price = round (CASE 	WHEN @item_pricing_value_id = 425 THEN
					#item_prices.avg_curve_value
				WHEN @item_pricing_value_id = 426 THEN
					#item_prices.curve_value
				WHEN @item_pricing_value_id = 427 THEN
					CASE WHEN (hedge_deal_date = item_deal_date) THEN
						#item_prices.avg_curve_value + (#hedge_fixed_prices.avg_fixed_price - #hedge_prices.avg_curve_value)
					ELSE #item_prices.avg_curve_value END
				WHEN @item_pricing_value_id = 428 THEN
					CASE WHEN (hedge_deal_date = item_deal_date) THEN
						#item_prices.curve_value + (#hedge_fixed_prices.fixed_price - #hedge_prices.curve_value)
					ELSE #item_prices.curve_value END
				WHEN @item_pricing_value_id = 429 THEN
					-- IF hedge moved up by X% THEN item deal price = item end of day price/(1-X%)
					CASE WHEN (hedge_deal_date = item_deal_date) THEN
						#item_prices.avg_curve_value / (1 - (#hedge_fixed_prices.avg_fixed_price - #hedge_prices.avg_curve_value)/#hedge_fixed_prices.avg_fixed_price)
					ELSE #item_prices.avg_curve_value END 
				WHEN @item_pricing_value_id = 430 THEN
					CASE WHEN (hedge_deal_date = item_deal_date) THEN
						#item_prices.curve_value / (1 - (#hedge_fixed_prices.fixed_price - #hedge_prices.curve_value)/#hedge_fixed_prices.fixed_price)
					ELSE #item_prices.curve_value END
				ELSE NULL
			End, 4) 
		FROM 	#gen_deal_detail LEFT OUTER JOIN
			
			#item_prices ON #item_prices.deal_sequence_number = #gen_deal_detail.deal_sequence_number AND
			#item_prices.hedge_term_start =  #gen_deal_detail.hedge_term_start LEFT OUTER JOIN --INNER JOIN
			#hedge_prices ON #hedge_prices.maturity_date = #item_prices.hedge_term_start LEFT OUTER JOIN --INNER JOIN
			#hedge_fixed_prices ON #hedge_fixed_prices.term_start = #gen_deal_detail.hedge_term_start AND 
			#item_prices.hedge_term_start = #hedge_fixed_prices.term_start
		WHERE (#gen_deal_detail.curve_id IS NULL AND @total_legs > 1) OR (@total_legs = 1)

		 --SELECT * FROM #gen_deal_detail
		 --SELECT * FROM #item_prices
		 --SELECT * FROM #hedge_prices
		-- SELECT * FROM #hedge_fixed_prices
		-- SELECT * FROM #run_status
		--Check IF price, currency unit, and uom got updated without errors (it would be NULL IF failed)
		DECLARE @total_null_rows INT
		SET @total_null_rows  = NULL
	
		SELECT 	@total_null_rows = COUNT(*)
		FROM 	#gen_deal_detail 
		WHERE 	#gen_deal_detail.curve_id IS NULL 
			OR (#gen_deal_detail.fixed_price_currency_id IS NULL OR
			#gen_deal_detail.fixed_price IS NULL OR #gen_deal_detail.deal_volume_uom_id IS NULL)
	
		--SELECT * FROM #gen_deal_detail
		--SELECT * FROM #gen_deal_header
		--SELECT @total_null_rows
		IF @total_null_rows IS NULL OR @total_null_rows > 0
		BEGIN
			--**ERROR**
			INSERT INTO #run_status
			SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
							'Application Error' Status, 
				'Failed to calculate either fixed price, currency unit, or volume unit for the item forecasted transactions for gen hedge group. ' + 
					@gen_hedge_group_desc + ' (Index:' + ISNULL(spcd.curve_name, 'NULL') + '/Term:' + dbo.FNADateFormat(term_start) + '/Price:' + ISNULL(CAST(fixed_price  AS VARCHAR), 'NULL') 
					+ '/UOM:' + ISNULL(su.uom_name, 'NULL') + '/Currency:' + ISNULL(sc.currency_name, 'NULL') + ')' [Message], 
				'Please check the error message above to resolve the generation issues.' Recommendation
			FROM #gen_deal_detail left outer join
			source_price_curve_def spcd ON spcd.source_curve_def_id = #gen_deal_detail.curve_id left outer join
			source_currency sc ON sc.source_currency_id = #gen_deal_detail.fixed_price_currency_id left outer join
			source_uom su ON su.source_uom_id = #gen_deal_detail.deal_volume_uom_id
			WHERE 	#gen_deal_detail.curve_id IS NULL 
			OR (#gen_deal_detail.fixed_price_currency_id IS NULL OR
			#gen_deal_detail.fixed_price IS NULL OR #gen_deal_detail.deal_volume_uom_id IS NULL)
		
		END
	END

	---------------------------------------------------------------------------------------------------
	-----------------End of Step 5
	---------------------------------------------------------------------------------------------------
	-- SELECT * FROM  #gen_deal_header
	-- SELECT * FROM  #gen_deal_detail
	-- SELECT * FROM #item_prices
	-- SELECT * FROM #hedge_prices
	-- SELECT * FROM #hedge_fixed_prices
	-- SELECT * FROM #run_status
	-- RETURN

	---------------------------------------------------------------------------------------------------
	---------------- Step 6: Check for erros. IF no errors found create deals and links
	---------------------------------------------------------------------------------------------------

	DECLARE @total_errors INT
	SET @total_errors  = NULL

	SELECT @total_errors = COUNT(*) FROM #run_status
	IF @total_errors IS NULL 
		SET @total_errors = 0
	IF @total_errors IS NULL OR @total_errors > 0
	BEGIN
		--**ERROR**
		INSERT INTO #run_status
		SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
						'Application Error' Status, 
			'Failed to generate an item forecasted transactions for gen hedge group. ' + 
				@gen_hedge_group_desc Message, 
			'Please check the error message above to resolve the generation issues.' Recommendation
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION

		IF OBJECT_ID('tempdb..#inserted_final_gen_links') IS NOT NULL
			DROP TABLE #inserted_final_gen_links
			
		CREATE TABLE #inserted_final_gen_links(fas_book_id INT, gen_link_id INT, curve_id INT)

		-- Create link header
		INSERT INTO gen_fas_link_header
		OUTPUT INSERTED.fas_book_id, INSERTED.gen_link_id INTO #inserted_final_gen_links (fas_book_id, gen_link_id)
		SELECT gen_hedge_group.gen_hedge_group_id, 
			CASE WHEN (@auto_finalize_gen_trans = 1 AND @total_errors=0) THEN 'y' ELSE 'n' END AS gen_approved, 
			@eff_test_profile_id AS used_ass_profile_id, 
			fas_eff_hedge_rel_type.fas_book_id AS fas_book_id, 
			gen_hedge_group.perfect_hedge AS perfect_hedge, 
			@gen_hedge_group_desc AS link_description, 
			@eff_test_profile_id AS eff_test_profile_id, 
			gen_hedge_group.hedge_effective_date AS link_effective_date, 
			gen_hedge_group.link_type_value_id AS link_type_value_id, 
			NULL AS link_id, 
			'a' AS gen_status, 
			@global_process_id AS process_id, 
			@user_login_id, 
			NULL, 
			NULL
		FROM gen_hedge_group 
		INNER JOIN fas_eff_hedge_rel_type ON fas_eff_hedge_rel_type.eff_test_profile_id = gen_hedge_group.eff_test_profile_id
		WHERE gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id
			AND fas_eff_hedge_rel_type.eff_test_profile_id = @eff_test_profile_id

		IF @@ERROR <> 0
		BEGIN
			--**ERROR**
			INSERT INTO #run_status
			SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
							'Application Error' Status, 
				'Failed to insert hedging relationship for the gen hedge group. ' + 
					@gen_hedge_group_desc Message, 
				'Please contact technical support.' Recommendation
			ROLLBACK
		END
		ELSE
		BEGIN
			--insert item deal header and detail
			IF @perfect_hedge = 'n' 
			BEGIN
				INSERT INTO gen_deal_header
		      		SELECT    g.source_system_id, g.gen_status, g.number_attempts, 
					g.recid deal_id, g.deal_date, g.physical_financial_flag, 
					ISNULL(g.trader_id,sdh.trader_id), ISNULL(g.counterparty_id,sdh.counterparty_id), g.entire_term_start, 
					g.entire_term_end, ISNULL(g.source_deal_type_id,sdh.source_deal_type_id), 
					ISNULL(g.deal_sub_type_type_id,sdh.deal_sub_type_type_id), ISNULL(g.option_flag,sdh.option_flag), 
					ISNULL(g.option_type,sdh.option_type), ISNULL(g.option_excercise_type,sdh.option_excercise_type), 
					ISNULL(g.source_system_book_id1,sdh.source_system_book_id1), ISNULL(g.source_system_book_id2,sdh.source_system_book_id2), 
					ISNULL(g.source_system_book_id3,sdh.source_system_book_id3), ISNULL(g.source_system_book_id4,sdh.source_system_book_id4), 
                      			g.description1, g.description2, g.description3, 
					ISNULL(g.deal_category_value_id,sdh.deal_category_value_id), g.process_id, g.deal_sequence_number,
					@user_login_id, NULL,@gen_hedge_group_id
				FROM  #gen_deal_header g left join source_deal_header sdh on g.gen_deal_header_id=sdh.source_deal_header_id
			
				UPDATE gen_deal_header SET deal_id =CAST(s.gen_deal_header_id AS VARCHAR) + '-' + CONVERT(VARCHAR(10),GETDATE(),120)
				FROM gen_deal_header s INNER JOIN #gen_deal_header t ON ISNUMERIC(s.deal_id) = 1 AND CAST(s.deal_id AS INT)=t.recid 
			
				IF @debug = 1
					EXEC spa_print 'After inserting gen_header'

				IF @@ERROR <> 0
				BEGIN
					--**ERROR**
					INSERT INTO #run_status
					SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
									'Application Error' Status, 
						'Failed to insert item deal header for the gen hedge group. ' + 
							@gen_hedge_group_desc Message, 
						'Please contact technical support.' Recommendation
					ROLLBACK
				END
				ELSE
				BEGIN
					INSERT INTO gen_deal_detail
					SELECT  gen_deal_header.gen_deal_header_id, gdd.term_start, 
						gdd.term_end, gdd.Leg, 
							gdd.contract_expiration_date, 
						gdd.fixed_float_leg, gdd.buy_sell_flag, 
						gdd.curve_id, 
							gdd.fixed_price, gdd.fixed_price_currency_id, 
						gdd.option_strike_price, gdd.deal_volume, 
							gdd.deal_volume_frequency, 
						gdd.deal_volume_uom_id, gdd.block_description, 
							gdd.internal_deal_type_value_id, 
						gdd.internal_deal_subtype_value_id, 
						gdd.deal_detail_description, @user_login_id, NULL,
						gdd.price_adder,
						gdd.price_multiplier
					FROM    #gen_deal_detail gdd INNER JOIN
							gen_deal_header ON gen_deal_header.deal_sequence_number = gdd.deal_sequence_number AND
								   gen_deal_header.process_id = @process_id

					IF @debug = 1
						EXEC spa_print 'After inserting gen_detail'

					IF @@ERROR <> 0
					BEGIN
					EXEC spa_print 'aaaaa'
						--**ERROR** SELECT * FROM #run_status 
						INSERT INTO #run_status
						SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
										'Application Error' Status, 
							'Failed to insert item deal detail for the gen hedge group. ' + 
								@gen_hedge_group_desc Message, 
							'Please contact technical support.' Recommendation
						ROLLBACK
					END
					ELSE
					BEGIN
						EXEC spa_print 'bbbb'

						IF @reprice_items_id IS NULL
						BEGIN
							INSERT INTO gen_fas_link_detail
							([gen_link_id]
						   , [deal_number]
						   , [hedge_or_item]
						   , [percentage_included]
						   , [create_user]
						   , [create_ts]
						   , [effective_date],deal_id_source) 
							SELECT	gfas.gen_link_id, ghg.gen_deal_header_id, 
								'i' AS hedge_or_item, 1.0 AS percentage_included, @user_login_id, NULL, NULL effective_date,'f'
							FROM    gen_deal_header ghg
							INNER JOIN gen_fas_link_header gfas ON gfas.gen_hedge_group_id = @gen_hedge_group_id
								AND ghg.gen_hedge_group_id = gfas.gen_hedge_group_id
								AND ghg.process_id = @process_id
						END
						ELSE
						BEGIN
							INSERT INTO gen_fas_link_detail
							([gen_link_id]
						   , [deal_number]
						   , [hedge_or_item]
						   , [percentage_included]
						   , [create_user]
						   , [create_ts]
						   , [effective_date],deal_id_source) 
							SELECT	gen_fas_link_header.gen_link_id, ghg.gen_deal_header_id, 
								'i' AS hedge_or_item, gen_hedge_group_detail.percentage_use AS percentage_included, @user_login_id, NULL, NULL effective_date,'f'
							FROM    gen_deal_header ghg
							INNER JOIN gen_fas_link_header ON gen_fas_link_header.gen_hedge_group_id = @gen_hedge_group_id
								AND ghg.gen_hedge_group_id = gen_fas_link_header.gen_hedge_group_id
								AND ghg.process_id = @process_id 
							INNER JOIN gen_hedge_group_detail ON gen_hedge_group_detail.source_deal_header_id = ghg.deal_sequence_number 
								AND gen_hedge_group_detail.gen_hedge_group_id = @gen_hedge_group_id
						END				
						        
						IF @@ERROR <> 0
						BEGIN
							--**ERROR**
							INSERT INTO #run_status
							SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
											'Application Error' Status, 
								'Failed to insert item link detail for the gen hedge group. ' + 
									@gen_hedge_group_desc Message, 
								'Please contact technical support.' Recommendation
							ROLLBACK
						END
					END
				END			
			END	
			--insert deals in link detai for hedges
			IF @reprice_items_id IS NULL AND @past_perfect_hedge  = 'n'
			BEGIN
				INSERT INTO gen_fas_link_detail
							([gen_link_id]
						   , [deal_number]
						   , [hedge_or_item]
						   , [percentage_included]
						   , [create_user]
						   , [create_ts]
						   , [effective_date],deal_id_source) 
				SELECT	gfas.gen_link_id, ghgd.source_deal_header_id, 
					'h' AS hedge_or_item, ghgd.percentage_use AS percentage_included,
					@user_login_id, NULL, NULL effective_date,'s'					  
				FROM gen_hedge_group_detail ghgd
				INNER JOIN gen_fas_link_header gfas ON gfas.gen_hedge_group_id = ghgd.gen_hedge_group_id 
				WHERE ghgd.gen_hedge_group_id = @gen_hedge_group_id				

				UPDATE ifgl
				SET curve_id = gdd.curve_id
				-- SELECT *
				FROM #inserted_final_gen_links ifgl
				INNER JOIN gen_fas_link_detail gfld ON gfld.gen_link_id = ifgl.gen_link_id
				INNER JOIN gen_deal_detail gdd ON gdd.gen_deal_header_id = gfld.deal_number
				        
				IF @@ERROR <> 0
				BEGIN
					--**ERROR**
					INSERT INTO #run_status
					SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
									'Application Error' Status, 
						'Failed to insert hedges in link detail for the gen hedge group. ' + 
							@gen_hedge_group_desc Message, 
						'Please contact technical support.' Recommendation
					ROLLBACK
				END
			END
		END
	END
	
	--IF there are no error status record in #run_status THEN it was successfull
	SELECT @total_errors = COUNT(*) FROM #run_status
	IF @total_errors IS NULL OR (@total_errors = 0 AND @@ERROR = 0)
	BEGIN

		DECLARE @gen_over_hedge_capacity INT
		SELECT     @gen_over_hedge_capacity = var_value
		FROM         adiha_default_codes_values
		WHERE     (instance_no = '1') AND (default_code_id = 19) AND (seq_no = 1)

		DECLARE @exceptions_count INT, @exceptions_url VARCHAR(MAX) 
		SET @exceptions_count = 0
		SET @exceptions_url = ''
		IF @gen_over_hedge_capacity > 0 
		BEGIN
			--SELECT @gen_hedge_group_id,@gen_over_hedge_capacity
			EXEC spa_is_there_capacity_exception_after_gen @gen_hedge_group_id, @exceptions_count OUTPUT, @exceptions_url OUTPUT
		END

		--SELECT @exceptions_count, @gen_over_hedge_capacity, @reprice_items_id
		IF @exceptions_count = 0 OR (@gen_over_hedge_capacity = 1 AND @reprice_items_id IS NOT NULL)
		BEGIN
			SET @sql = '
				INSERT INTO ' + @alert_process_table + '(fas_book_id, gen_link_id, curve_id)
				SELECT ifg.fas_book_id, ifg.gen_link_id, MAX(ifg.curve_id)
				FROM #inserted_final_gen_links ifg
				INNER JOIN gen_fas_link_header gas ON gas.gen_link_id = ifg.gen_link_id
				INNER JOIN fas_eff_hedge_rel_type fes  ON fes.eff_test_profile_id = gas.eff_test_profile_id
				--WHERE ISNULL(fes.apply_limit, ''n'') = ''y''
				GROUP BY ifg.fas_book_id, ifg.gen_link_id
			'

			EXEC(@sql)
			
			INSERT INTO #run_status
			SELECT 'Success' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
							'Transaction Generated' Status, 
				'Item forecasted transaction and hedging relationship created for gen hedge group. ' + 
					@gen_hedge_group_desc Message, 
				'Please review the details of items created before approving transactions.' Recommendation

			--For repricing log warning inmsg box
			IF @exceptions_count > 0
			BEGIN 
				DECLARE @desc VARCHAR(8000)
				SET @desc = 'Warning found while Item forecasted transaction being re-priced for hedging relationship ID: ' + CAST(@reprice_items_id AS VARCHAR)
						+ ' (' + replace (@exceptions_url, './spa_html.php?', './dev/spa_html.php?') + ')'
				EXEC  spa_message_board 'i', @user_login_id,
						NULL, 'Repricing',
						@desc, 
						'', '', 'w', NULL
			END
		END
		ELSE
		BEGIN
			IF @gen_over_hedge_capacity = 1
			BEGIN
				INSERT INTO #run_status
				SELECT 'Warning' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
								'Transaction Generated' Status, 
					'Warning found while Item forecasted transaction and hedging relationship being created for gen hedge group. ' + 
						@gen_hedge_group_desc + ' (' + @exceptions_url + ')' Message, 
					'Please fix the over hedge exception before proceeding.' Recommendation
			END
			ELSE
			BEGIN
				--SELECT @exceptions_count, @exceptions_url
				INSERT INTO #run_status
				SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
								'Transaction Not Generated' Status, 
					'Error found while Item forecasted transaction and hedging relationship being created for gen hedge group. ' + 
						@gen_hedge_group_desc + ' (' + @exceptions_url + ')' Message, 
					'Please fix the over hedge exception before proceeding.' Recommendation

				--Unapprove it IF  it was approved before			
				IF (@auto_finalize_gen_trans = 1 )
					UPDATE gen_fas_link_header SET gen_approved = 'n' 
					WHERE  gen_hedge_group_id = @gen_hedge_group_id
			END
		END
		--Commit all inserts above....
		COMMIT
		EXEC spa_register_event 20631, 10000316, @alert_process_table, 1, @process_id
	END

	--for apply limit to the @global_process_id
	UPDATE gen_deal_header SET process_id=ISNULL(@global_process_id,@process_id) WHERE process_id=@process_id
	UPDATE gen_deal_header SET process_id=ISNULL(@global_process_id,@process_id) WHERE process_id=@process_id

	INSERT INTO gen_transaction_status
	SELECT ISNULL(@global_process_id,@process_id), @gen_hedge_group_id, #run_status.*, @user_login_id, NULL
	FROM #run_status

	IF @reprice_items_id IS NOT NULL OR @past_perfect_hedge  = 'y'
		SELECT * FROM #run_status 
	-----------------End of Step 6
	EXEC spa_print 'end [spa_gen_transaction]'
END TRY
BEGIN CATCH
	--EXEC spa_print 'Error Found in Catch: ' + ERROR_MESSAGE()
	IF @@TRANCOUNT>0
		ROLLBACK

	INSERT INTO #run_status
	SELECT 'Error' ErrorCode, 'Transaction Generation' Module, 'gen_transaction' Area, 
					'Transaction Not Generated' Status, 
		'SQL Error found for gen hedge group ' +  @gen_hedge_group_desc + ': ' + ERROR_MESSAGE() Message, 
		'Please contact support.' Recommendation

	INSERT INTO gen_transaction_status
	SELECT ISNULL(@global_process_id,@process_id), @gen_hedge_group_id, #run_status.*, @user_login_id, NULL
	FROM #run_status			
END CATCH

GO