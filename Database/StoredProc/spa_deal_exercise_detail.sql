IF OBJECT_ID(N'[dbo].[spa_deal_exercise_detail]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_exercise_detail]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2016-11-15
-- Description: Deal Exercise logic
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_deal_exercise_detail]
    @flag CHAR(1),
    @source_deal_detail_id INT = NULL,
    @source_deal_header_id INT = NULL,
	@source_deal_group_id INT = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@exercise_date DATETIME = NULL
    
AS
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT

IF OBJECT_ID('tempdb..#temp_deal_group') IS NOT NULL
	DROP TABLE #temp_deal_group
CREATE TABLE #temp_deal_group (detail_id INT)

IF @source_deal_detail_id IS NOT NULL
BEGIN
	INSERT INTO #temp_deal_group(detail_id)
	SELECT @source_deal_detail_id
END
ELSE
BEGIN
	INSERT INTO #temp_deal_group(detail_id)			
	SELECT sdd.source_deal_detail_id
	FROM source_deal_detail sdd
	WHERE sdd.source_deal_group_id = @source_deal_group_id
END

 
IF @flag = 'i'
BEGIN
	BEGIN TRY
		IF @source_deal_group_id IS NOT NULL AND @source_deal_detail_id IS NULL
		BEGIN
			SELECT @source_deal_detail_id = MIN(source_deal_detail_id) 
			FROM source_deal_detail 
			WHERE source_deal_header_id = @source_deal_header_id 
			AND source_deal_group_id = @source_deal_group_id
		END
		
		IF EXISTS(
			SELECT 1 
			FROM deal_exercise_detail ded 
			INNER JOIN #temp_deal_group temp ON temp.detail_id = ded.source_deal_detail_id
			AND ded.term_start >= @term_start and ded.term_end <= @term_start
		)
		BEGIN
			EXEC spa_ErrorHandler -1
			     , 'deal_exercise_detail'
			     , 'spa_deal_exercise_detail'
			     , 'DB Error'
			     , 'Exercise deal already present for selected detail and terms.'
			     , ''  
			RETURN
		END

		DECLARE @contract_expiration_date DATETIME
		SELECT TOP(1) @contract_expiration_date = sdd.contract_expiration_date
		FROM source_deal_detail sdd
		INNER JOIN #temp_deal_group temp ON temp.detail_id = sdd.source_deal_detail_id

		IF EXISTS(
			SELECT 1 
			FROM source_deal_detail ded 
			INNER JOIN #temp_deal_group temp ON temp.detail_id = ded.source_deal_detail_id
			WHERE contract_expiration_date <> @contract_expiration_date
		)
		BEGIN
			EXEC spa_ErrorHandler -1
			     , 'deal_exercise_detail'
			     , 'spa_deal_exercise_detail'
			     , 'DB Error'
			     , 'Cannot exercise deal. Some of the selected detail have different expiration date.'
			     , ''  
			RETURN
		END

		IF OBJECT_ID('tempdb..#temp_exercise_deal_header') IS NOT NULL 
			DROP TABLE #temp_exercise_deal_header
		
		IF OBJECT_ID('tempdb..#temp_exercise_deal_group') IS NOT NULL 
			DROP TABLE #temp_exercise_deal_group
	
		IF OBJECT_ID('tempdb..#temp_exercise_deal_detail') IS NOT NULL 
			DROP TABLE #temp_exercise_deal_detail
	
		IF OBJECT_ID('tempdb..#temp_inserted_detail') IS NOT NULL 
			DROP TABLE #temp_inserted_detail

		CREATE TABLE #temp_exercise_deal_group (group_id INT)
		CREATE TABLE #temp_inserted_detail (detail_id INT)
	
		DECLARE @physical_financial_flag     CHAR(1),
				@option_type				 CHAR(1),
				@fixed_price				 FLOAT,
				@internal_deal_sub_type_id   INT,
				@buy_sell_flag				 CHAR(1),
				@template_id				 INT,
				@reference_id				 VARCHAR(200),
				@user_name					 VARCHAR(100) = dbo.FNADBUser(),
				@original_template_id		 INT
            
		SELECT * INTO #temp_exercise_deal_header FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id
		SELECT * INTO #temp_exercise_deal_detail FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id
    
		SELECT @contract_expiration_date = sdd.contract_expiration_date,
			   @physical_financial_flag = sdd.physical_financial_flag,
			   @option_type = sdh.option_type,
			   @fixed_price = sdd.option_strike_price,
			   @internal_deal_sub_type_id = sdh.internal_deal_type_value_id,
			   @buy_sell_flag = CASE 
									 WHEN sdh.option_type = 'c' THEN sdh.header_buy_sell_flag
									 WHEN sdh.option_type = 'p' THEN CASE WHEN sdh.header_buy_sell_flag = 's' THEN 'b' ELSE 's' END
								END,
				@reference_id = CAST(sdh.source_deal_header_id AS VARCHAR(20)) + '_Options',
				@original_template_id = sdh.template_id   
		FROM source_deal_detail sdd
		INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = sdd.source_deal_header_id
		WHERE source_deal_detail_id = @source_deal_detail_id
    
		SELECT @template_id = ddpv.template_id
		FROM default_deal_post_values ddpv
		WHERE ddpv.original_template_id = @original_template_id
		
		IF @template_id IS NULL
		BEGIN     
			EXEC spa_ErrorHandler -1
			     , 'deal_exercise_detail'
			     , 'spa_deal_exercise_detail'
			     , 'DB Error'
			     , 'Incomplete setup. Template mapping is not present.'
			     , ''  
			RETURN
		END
    
		UPDATE temp
		SET template_id = @template_id
			,deal_id = @reference_id
			,header_buy_sell_flag = @buy_sell_flag
			,deal_locked = 'n'															-- deal unlocked
			,deal_status = ISNULL(sdht.deal_status, 5604)								-- New
			,confirm_status_type = ISNULL(sdht.confirm_status_type, 17210)				-- Initial
			,term_frequency = COALESCE(sdht.term_frequency_type, temp.term_frequency, 't')
			,source_deal_type_id = sdht.source_deal_type_id
			,deal_sub_type_type_id = sdht.deal_sub_type_type_id
			,internal_deal_type_value_id = sdht.internal_deal_type_value_id
			,internal_deal_subtype_value_id = sdht.internal_deal_subtype_value_id
			,option_excercise_type = sdht.option_excercise_type
			,option_type = sdht.option_type
			,option_flag = sdht.option_flag
		FROM #temp_exercise_deal_header temp
		OUTER APPLY (SELECT * FROM source_deal_header_template WHERE template_id = @template_id) sdht

		DECLARE @term_frequency CHAR(1)
		SELECT @term_frequency = ISNULL(term_frequency_type, 't')
		FROM source_deal_header_template 
		WHERE template_id = @template_id

		IF OBJECT_ID('tempdb..#temp_deal_breakdown') IS NOT NULL
			DROP TABLE #temp_deal_breakdown

		CREATE TABLE #temp_deal_breakdown (term_start DATETIME, term_end DATETIME, leg INT)

		IF @term_frequency <> 'h'
		BEGIN
			IF @term_frequency = 't'
			BEGIN
				INSERT INTO #temp_deal_breakdown(term_start, term_end, leg)
				SELECT @term_start [term_start], @term_end [term_end], leg
				FROM #temp_exercise_deal_detail
			END
			ELSE
			BEGIN
				;WITH cte_terms AS (
					SELECT @term_start [term_start], CASE WHEN @term_end < dbo.FNAGetTermEndDate(@term_frequency, @term_start, 0) THEN @term_end ELSE dbo.FNAGetTermEndDate(@term_frequency, @term_start, 0) END [term_end], leg
					FROM source_deal_detail_template 
					WHERE template_id = @template_id
					UNION ALL
					SELECT dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), CASE WHEN @term_end < dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), 0) THEN @term_end ELSE dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), 0) END, cte.leg
					FROM cte_terms cte 
					WHERE dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1) <= @term_end
				) 
				INSERT INTO #temp_deal_breakdown(term_start, term_end, leg)
				SELECT [term_start], [term_end], leg
				FROM cte_terms
				option (maxrecursion 0)
			END
		END

		BEGIN TRAN
		
		INSERT INTO source_deal_header (
			source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id, counterparty_id,
			entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, 
			source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, description1, description2, 
			description3, deal_category_value_id, trader_id, internal_deal_type_value_id, internal_deal_subtype_value_id, 
			template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id, status_date, assignment_type_value_id, 
			compliance_year, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment, 
			aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id, 
			legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, [reference], 
			deal_locked, close_reference_id, block_type, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, 
			broker_unit_fees, broker_fixed_cost, broker_currency_id, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, 
			risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, confirm_status_type, sub_book, 
			deal_rules, confirm_rule, description4, timezone_id, reference_detail_id, counterparty_trader, internal_counterparty, settlement_vol_type, 
			counterparty_id2, trader_id2
			--, scheduler, sample_control, payment_term, payment_days, inco_terms, governing_law, arbitration, counterparty2_trader
		)	
		SELECT source_system_id, deal_id, @exercise_date, ext_deal_id, physical_financial_flag, structured_deal_id, counterparty_id,
			entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, 
			source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, description1, description2, 
			description3, deal_category_value_id, trader_id, internal_deal_type_value_id, internal_deal_subtype_value_id, 
			template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id, status_date, assignment_type_value_id, 
			compliance_year, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment, 
			aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id, 
			legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, [reference], 
			deal_locked, close_reference_id, block_type, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, 
			broker_unit_fees, broker_fixed_cost, broker_currency_id, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, 
			risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, confirm_status_type, sub_book, 
			deal_rules, confirm_rule, description4, timezone_id, reference_detail_id, counterparty_trader, internal_counterparty, settlement_vol_type, 
			counterparty_id2, trader_id2
			--, scheduler, sample_control, payment_term, payment_days, inco_terms, governing_law, arbitration, counterparty2_trader
		FROM #temp_exercise_deal_header
	
		DECLARE @new_deal_id INT
		SET @new_deal_id = SCOPE_IDENTITY()
	
		INSERT INTO source_deal_groups (		
			source_deal_header_id,
			detail_flag,
			term_from,
			term_to,
			leg,
			location_id,
			curve_id
		)
		OUTPUT INSERTED.source_deal_groups_id INTO #temp_exercise_deal_group(group_id)
		SELECT @new_deal_id, 0, @term_start, @term_end, 1, location_id, CASE WHEN location_id IS NULL THEN curve_id ELSE NULL END
		FROM #temp_exercise_deal_detail temp
	
		UPDATE temp
		SET fixed_price = @fixed_price,
			buy_sell_flag = @buy_sell_flag,
			source_deal_group_id = grp.group_id
		FROM #temp_exercise_deal_detail temp
		OUTER APPLY (SELECT group_id FROM #temp_exercise_deal_group) grp
	
		INSERT INTO source_deal_detail (
			source_deal_header_id, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price, 
			fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, 
			formula_id, volume_left, settlement_volume, settlement_uom, price_adder, price_multiplier, 
			settlement_date, day_count_id, location_id, meter_id, physical_financial_flag, Booked, process_deal_status, fixed_cost, multiplier, 
			adder_currency_id, fixed_cost_currency_id, formula_currency_id, price_adder2, price_adder_currency2, volume_multiplier2, --total_volume, 
			pay_opposite, capacity, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code, pv_party, 
			status, lock_deal_detail, pricing_type, pricing_period, event_defination, apply_to_all_legs, contractual_volume, contractual_uom_id, 
			source_deal_group_id, actual_volume, detail_commodity_id, detail_pricing, pricing_start, pricing_end, schedule_volume, cycle, origin, form, 
			organic, attribute1, attribute2, attribute3, attribute4, attribute5, position_uom
			--, detail_sample_control, lot, detail_inco_terms, crop_year, buyer_seller_option, batch_id, product_description
		)
		OUTPUT INSERTED.source_deal_detail_id INTO #temp_inserted_detail(detail_id)
		SELECT 
			@new_deal_id, tdt.term_start, tdt.term_end, tdt.leg, tdt.term_end, fixed_float_leg, buy_sell_flag, curve_id, fixed_price, 
			fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, 
			formula_id, volume_left, settlement_volume, settlement_uom, price_adder, price_multiplier, 
			settlement_date, day_count_id, location_id, meter_id, physical_financial_flag, Booked, process_deal_status, fixed_cost, multiplier, 
			adder_currency_id, fixed_cost_currency_id, formula_currency_id, price_adder2, price_adder_currency2, volume_multiplier2, --total_volume, 
			pay_opposite, capacity, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code, pv_party, 
			status, lock_deal_detail, pricing_type, pricing_period, event_defination, apply_to_all_legs, contractual_volume, contractual_uom_id, 
			source_deal_group_id, actual_volume, detail_commodity_id, detail_pricing, pricing_start, pricing_end, schedule_volume, cycle, origin, form, 
			organic, attribute1, attribute2, attribute3, attribute4, attribute5, position_uom
			--, detail_sample_control, lot, detail_inco_terms, crop_year, buyer_seller_option, batch_id, product_description
		FROM #temp_exercise_deal_detail
		OUTER APPLY (SELECT term_start, term_end, leg FROM #temp_deal_breakdown) tdt
    
		INSERT INTO deal_exercise_detail (
    		source_deal_detail_id,
    		exercise_date,
    		term_start,
    		term_end,
    		exercise_deal_id
		)
		SELECT t1.detail_id, @exercise_date, @term_start, @term_end, @new_deal_id
		FROM #temp_deal_group t1
		GROUP BY detail_id
		
		-- update audit info
		UPDATE sdh
		SET create_ts = GETDATE(),
			create_user = @user_name,
			deal_id = deal_id + '_' + CAST(@new_deal_id AS VARCHAR(20))
		FROM source_deal_header sdh
		WHERE sdh.source_deal_header_id = @new_deal_id
			
		UPDATE sdd
		SET create_ts = GETDATE(),
			create_user = @user_name
		FROM source_deal_detail sdd
		INNER JOIN #temp_inserted_detail temp ON sdd.source_deal_detail_id = temp.detail_id
				
		COMMIT TRAN
		
		DECLARE @return_val VARCHAR(100) 
		SET @return_val = CASE WHEN @source_deal_group_id IS NOT NULL THEN 'GRP-' + CAST(@source_deal_group_id AS VARCHAR(20)) ELSE CAST(@source_deal_detail_id AS VARCHAR(20)) END
		
		EXEC spa_ErrorHandler 0
			, 'deal_exercise_detail'
			, 'spa_deal_exercise_detail'
			, 'Success' 
			, 'Successfully saved data.'
			, @return_val

		DECLARE @after_insert_process_table VARCHAR(300), @job_name VARCHAR(200), @job_process_id VARCHAR(200) = dbo.FNAGETNEWID()
		SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
		IF OBJECT_ID(@after_insert_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_insert_process_table)
		END
				
		EXEC ('CREATE TABLE ' + @after_insert_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
					SELECT ' + CAST(@new_deal_id AS VARCHAR(20))
		EXEC(@sql)
			
		SET @sql = 'spa_deal_insert_update_jobs ''i'', ''' + @after_insert_process_table + ''''
		SET @job_name = 'spa_deal_insert_update_jobs_' + @job_process_id
 		
		EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'deal_exercise_detail'
		   , 'spa_deal_exercise_detail'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH	
END
ELSE IF @flag = 's'
BEGIN
	SELECT dbo.FNATRMWinHyperlink('i', 10131010, exercise_deal_id, exercise_deal_id, 'n', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 0) [deal_id],
	       dbo.FNADateFormat(term_start) term_start,
	       dbo.FNADateFormat(term_end) term_end,
	       dbo.FNADateFormat(exercise_date) exercise_date
	FROM deal_exercise_detail ded
	INNER JOIN #temp_deal_group t1 ON t1.detail_id = ded.source_deal_detail_id
	GROUP BY exercise_deal_id, term_start, term_end, exercise_date
END
ELSE IF @flag = 'e'
BEGIN
	SELECT CONVERT(VARCHAR(10), MIN(contract_expiration_date), 120) exercise_date
	FROM source_deal_detail sdd
	INNER JOIN #temp_deal_group t1 ON t1.detail_id = sdd.source_deal_detail_id
END