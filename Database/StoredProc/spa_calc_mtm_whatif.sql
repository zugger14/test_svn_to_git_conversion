IF OBJECT_ID('spa_calc_mtm_whatif') IS NOT NULL
DROP PROC [dbo].[spa_calc_mtm_whatif]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 /**
	Whatif Calculation of mtm,settlement and position.


	Parameters : 
	@flag : Whatif calculation type
						 - 'c' - MTM 
						 - 'p' - Position 
	@as_of_date : Date for whatif processing
	@user_name : User name of runner
	@whatif_criteria_id : WHATIF parameter changed criteria ID.
	@criteria_group : Group of whatif criteria
	@batch_process_id : process id when run through batch
	@batch_report_param : paramater to run through barch

  */

CREATE PROCEDURE [dbo].[spa_calc_mtm_whatif]
	@flag					CHAR(1) = 'c', -- p = position while calling from hourly position.
	@as_of_date				VARCHAR(100),
	@whatif_criteria_id		VARCHAR(1000),
	@criteria_group			INT = NULL,
	@user_name				VARCHAR(50) = NULL,
	@process_id				VARCHAR(50) = NULL,
	@show_output            BIT = 0,
	@trigger_workflow		NCHAR(1) = 'y',
	@batch_process_id		VARCHAR(50) = NULL,
	@batch_report_param		VARCHAR(5000) = NULL
AS
/*
* To execute this sp
* EXEC spa_calc_mtm_whatif '2012-04-12',8,'farrms_admin', NULL, NULL, NULL
*/
	
	DECLARE @scenario_id					INT
	DECLARE @curve_source_value_id			INT
	DECLARE @shift_val						FLOAT
	DECLARE @shift_by						CHAR(1)
	DECLARE	@use_existing_values			CHAR(1)
	DECLARE @mtm							CHAR(1)
    DECLARE	@position						CHAR(1)
	DECLARE @var							CHAR(1)
	DECLARE @credit							CHAR(1)
	DECLARE @cfar							CHAR(1)
	DECLARE @ear							CHAR(1)
	DECLARE @pfe							CHAR(1)
	DECLARE @Gmar							CHAR(1)
	DECLARE @std_deal_table					VARCHAR(250)
	DECLARE @curve_table					VARCHAR(128)
	DECLARE @sql_stmt						VARCHAR(8000)
	DECLARE @param_def						NVARCHAR(3000)
	DECLARE @curve_process_id				VARCHAR(50)
	DECLARE @create_user					VARCHAR(50)
	DECLARE @create_ts						DATETIME
	
	DECLARE @term_start	DATETIME, @term_end DATETIME, @tenor_from INT, @tenor_to INT
	
	
	DECLARE @criteria_id VARCHAR(10), @criteria_name VARCHAR(500), @criteria_description VARCHAR(500)
	DECLARE @calc_process_deals VARCHAR(250), @i INT, @mtm_process_id VARCHAR(200)
	DECLARE @measurement_approach INT, @confidence_interval INT, @holding_period INT, @run_var BIT, @no_of_simulation INT
	DECLARE @temptablequery VARCHAR(500)
	
	--For hypothetical information
	DECLARE @hypo_deal_header VARCHAR(250), @hypo_deal_detail VARCHAR(250), @revaluation CHAR(10)
	--For shift values
	DECLARE @formula_nested VARCHAR(100), @formula_breakdown VARCHAR(100) 
	DECLARE @whatif_shift VARCHAR(250), @curve_shift_val FLOAT, @curve_shift_per FLOAT, @whatif_shift_new VARCHAR(250)
	DECLARE @sim_process_id VARCHAR(100), @sim_whatif_shift VARCHAR(250), @sim_whatif_shift_new VARCHAR(250)
	
	--,@at_risk_criteria INT,@measure INT
	SET @user_name = dbo.fnadbuser()
	DECLARE @url VARCHAR(500)
	DECLARE @desc VARCHAR(500)
	DECLARE @errorMsg VARCHAR(200)
	DECLARE @errorcode VARCHAR(1)
	DECLARE @url_desc VARCHAR(500)
	DECLARE @module VARCHAR(100)
	DECLARE @source_value VARCHAR(100)
	SET @source_value = 'What-If Calculation'
	SET @module = 'What-If Calculation'
	SET @url = ''
	SET @desc = ''
	SET @errorMsg = ''
	SET @errorcode = 'e'
	SET @url_desc = ''

	SET @i = 1
	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()
		
	IF @user_name IS NULL
		SET @user_name = dbo.FNADBUser()
	
	SET @sim_process_id = dbo.FNAGetNewID()
	
	IF OBJECT_ID('tempdb..#tmp_rec_exist') IS NOT NULL
		DROP TABLE #tmp_rec_exist	
			
	CREATE TABLE #tmp_rec_exist (no_rec INT)			
-- collect deals for the scenario group
BEGIN TRY
	
	--if criteria group is given take criteria ids from that group
	
	IF @criteria_group IS NOT NULL AND @whatif_criteria_id IS NULL
	BEGIN
		SET @whatif_criteria_id = NULL
		SELECT @whatif_criteria_id = COALESCE(@whatif_criteria_id + ',', '') + cast(mwc.criteria_id AS VARCHAR) 
		FROM maintain_whatif_criteria mwc
		WHERE mwc.scenario_criteria_group = @criteria_group    
	END
	

	SET	@mtm_process_id = @process_id-- + '_' + CAST(@i AS VARCHAR)
	
	SET @std_deal_table = dbo.FNAProcessTableName('std_whatif_deals', @user_name, @mtm_process_id)
	SET @calc_process_deals = dbo.FNAProcessTableName('calc_process_deals', @user_name, @mtm_process_id)
	SET @hypo_deal_header = dbo.FNAProcessTableName('hypo_deal_header', @user_name, @mtm_process_id)
	SET @hypo_deal_detail = dbo.FNAProcessTableName('hypo_deal_detail', @user_name, @mtm_process_id)
	SET @whatif_shift = dbo.FNAProcessTableName('whatif_shift', @user_name,@mtm_process_id)
	SET @whatif_shift_new = dbo.FNAProcessTableName('whatif_shift_new', @user_name,@mtm_process_id)
	
	SET @sim_whatif_shift = dbo.FNAProcessTableName('whatif_shift', @user_name,@sim_process_id)
	SET @sim_whatif_shift_new = dbo.FNAProcessTableName('whatif_shift_new', @user_name,@sim_process_id)

	SET @sql_stmt='
		DECLARE cur_whatif_criteria CURSOR FOR
			SELECT	criteria_id, criteria_name, criteria_description FROM maintain_whatif_criteria 
			WHERE criteria_id in ('+@whatif_criteria_id+')'
	
	EXEC(@sql_stmt)
	
	--to do: logic to collect curve ids wrt scenarios mapped on criteria.(11/27/2013)
	IF OBJECT_ID('tempdb..#tmp_scenario_mapped_curve_info') IS NOT NULL
		DROP TABLE #tmp_scenario_mapped_curve_info
			
	CREATE TABLE #tmp_scenario_mapped_curve_info(
		curve_id INT NULL
		, shift_by CHAR(1) COLLATE DATABASE_DEFAULT NULL
		, shift_value FLOAT NULL
		, shift_group INT NULL
		, shift_item INT NULL
		, row_no INT
		, use_existing_values CHAR(1) COLLATE DATABASE_DEFAULT
	)
	
	OPEN cur_whatif_criteria
	FETCH NEXT FROM cur_whatif_criteria INTO @criteria_id, @criteria_name, @criteria_description
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF OBJECT_ID(@whatif_shift) IS NOT NULL
			EXEC('DROP TABLE ' + @whatif_shift)
		
		IF OBJECT_ID(@whatif_shift_new) IS NOT NULL
			EXEC('DROP TABLE ' + @whatif_shift_new)
			
		IF OBJECT_ID(@std_deal_table) IS NOT NULL
			EXEC('DROP TABLE ' + @std_deal_table)
		
		EXEC('CREATE TABLE ' + @whatif_shift + '(curve_id INT, curve_shift_val FLOAT, curve_shift_per FLOAT, shift_by CHAR(1))')
		EXEC('CREATE TABLE ' + @whatif_shift_new + '(curve_id INT, curve_shift_val FLOAT, curve_shift_per FLOAT, shift_by CHAR(1))')
		--EXEC('CREATE TABLE ' + @std_deal_table + '(source_deal_header_id INT, real_deal VARCHAR(1), counterparty INT')
			
		IF OBJECT_ID(@calc_process_deals) is not null
			EXEC('DROP TABLE '+ @calc_process_deals)
			
		IF OBJECT_ID(@hypo_deal_header) is not null
			EXEC('DROP TABLE '+ @hypo_deal_header)

		IF OBJECT_ID(@hypo_deal_detail) is not null
			EXEC('DROP TABLE '+ @hypo_deal_detail)

		--For hypothetical information
		IF OBJECT_ID('tempdb..#tmp_others') IS not NULL
			DROP TABLE #tmp_others
		
		CREATE TABLE #tmp_others (
			whatif_criteria_other_id INT, 
			criteria_id INT, 
			counterparty INT,
			buy_sell CHAR(1) COLLATE DATABASE_DEFAULT, 
			leg INT, 
			curve_id INT, 
			fixed_price NUMERIC(20,13),
			deal_volume NUMERIC(20,13),
			uom_id INT, 
			term_start DATETIME, 
			term_end DATETIME ,
			deal_id INT,
			currency INT,
			template_id INT,
			sub_book_id INT,
			pricing_index INT
			)
		
		SET @sql_stmt = '
			INSERT INTO #tmp_others (
			whatif_criteria_other_id, 
			criteria_id, 
			counterparty, 
			buy_sell,
			leg, 
			curve_id, 
			fixed_price,
			deal_volume,
			uom_id, 
			term_start, 
			term_end,
			deal_id,
			currency,
			template_id,
			sub_book_id,
			pricing_index
			) 
		SELECT 
			pmo.portfolio_mapping_other_id,
			pms.mapping_source_usage_id,
			pmo.counterparty,
			CASE WHEN pmo.buy = ''y'' THEN ''b'' ELSE ''s'' END buy_sell,
			1 leg,
			pmo.buy_index curve_id,
			pmo.buy_price fixed_price,
			pmo.buy_total_volume deal_volume,
			pmo.buy_uom uom_id,
			pmo.buy_term_start term_start,
			pmo.buy_term_end term_end,
			CASE WHEN pmo.buy = ''y'' AND sell = ''y'' THEN 2 ELSE 1 END deal_id,
			pmo.buy_currency currency,
			pmo.template_id,
			pmo.sub_book_id,
			pmo.buy_pricing_index
		FROM portfolio_mapping_source pms
		INNER JOIN portfolio_mapping_other pmo ON pms.portfolio_mapping_source_id = pmo.portfolio_mapping_source_id
			AND pmo.buy = ''y'' 
		WHERE 1 = 1
			AND pms.mapping_source_value_id = 23201
			AND pms.mapping_source_usage_id = ' + @criteria_id + '  
		UNION ALL
		SELECT 
			pmo.portfolio_mapping_other_id,
			pms.mapping_source_usage_id,
			counterparty,
			CASE WHEN pmo.sell = ''y'' THEN ''s'' ELSE ''b'' END buy_sell,
			CASE WHEN pmo.buy = ''y'' THEN 2 ELSE 1 END leg,	
			pmo.sell_index,
			pmo.sell_price,
			pmo.sell_total_volume,
			pmo.sell_uom,
			pmo.sell_term_start,
			pmo.sell_term_end,
			CASE WHEN pmo.buy = ''y'' AND sell = ''y'' THEN 2 ELSE 1 END deal_id,
			pmo.sell_currency,
			pmo.template_id,
			pmo.sub_book_id,
			pmo.sell_pricing_index
		FROM portfolio_mapping_source pms
		INNER JOIN portfolio_mapping_other pmo ON pms.portfolio_mapping_source_id = pmo.portfolio_mapping_source_id
			AND pmo.sell = ''y'' 
		WHERE 1 = 1
			AND pms.mapping_source_value_id = 23201
			AND pms.mapping_source_usage_id = ' + @criteria_id + ''

		exec spa_print @sql_stmt
		EXEC(@sql_stmt)

		--Creating table @hypo_deal_header
		/* 1- We are replacing source_deal_header table with below process table in spa_calc_mtm_job to run WhatIf calculation using the value of process table but if we add new column in the source_deal_header and use that in the calculation then logic expect the same column from this process table also so we copy the whole structure of main table to avoid such an issue and inserting data in the required columns only..
		  2- UNION ALL is used to avoid the identity property of column source_deal_header while creating this process table because we are inserting data in the column externally. We can do the same, using other approaches like 'drop and create column' or using 'IDENTITY_INSERT' but this way is better.
		*/
		EXEC('SELECT * INTO ' + @hypo_deal_header + ' FROM source_deal_header WHERE 1 = 2
			UNION ALL
			SELECT * FROM source_deal_header WHERE 1 = 2')
			
		--Inserting data into table @hypo_deal_header	
		SET @sql_stmt = 'INSERT INTO ' + @hypo_deal_header + ' (
			source_deal_header_id,
			source_system_id,
			sdhwh.deal_id,
			deal_date,
			ext_deal_id,
			physical_financial_flag,
			structured_deal_id,
			counterparty_id,
			entire_term_start,
			entire_term_end,
			source_deal_type_id,
			deal_sub_type_type_id,
			option_flag,
			option_type,
			option_excercise_type,
			source_system_book_id1,
			source_system_book_id2,
			source_system_book_id3,
			source_system_book_id4,
			description1,
			description2,
			description3,
			deal_category_value_id,
			trader_id,	
			internal_deal_type_value_id,
			internal_deal_subtype_value_id,
			template_id,
			header_buy_sell_flag,
			broker_id,
			generator_id,
			status_value_id,
			status_date,
			assignment_type_value_id,
			compliance_year,
			state_value_id,
			assigned_date,
			assigned_by,
			generation_source,
			aggregate_environment,
			aggregate_envrionment_comment,
			rec_price,
			rec_formula_id,
			rolling_avg,
			contract_id,
			create_user,
			create_ts,
			update_user,
			update_ts,
			legal_entity,
			internal_desk_id,
			product_id,	
			internal_portfolio_id,	
			commodity_id,	
			reference,	
			deal_locked,
			close_reference_id,
			block_type,	
			block_define_id,	
			granularity_id,	
			Pricing,
			deal_reference_type_id,	
			unit_fixed_flag,
			broker_unit_fees,
			broker_fixed_cost,
			broker_currency_id,
			deal_status,
			term_frequency,
			option_settlement_date,
			verified_by,
			verified_date,
			risk_sign_off_by,
			risk_sign_off_date,
			back_office_sign_off_by,
			back_office_sign_off_date,
			book_transfer_id,
			confirm_status_type
		)
		SELECT 
			(others.whatif_criteria_other_id*-1) source_deal_header_id,
			source_system_id,
			others.deal_id,
			''' + @as_of_date + ''',
			ext_deal_id,
			physical_financial_flag,
			structured_deal_id,
			others.counterparty,
			others.term_start,
			others.term_end,
			source_deal_type_id,
			deal_sub_type_type_id,
			option_flag,
			option_type,
			option_excercise_type,
			source_system_book_id1,
			source_system_book_id2,
			source_system_book_id3,
			source_system_book_id4,
			description1,
			description2,
			description3,
			deal_category_value_id,
			ISNULL(trader_id, 1) trader_id,	
			internal_deal_type_value_id,
			internal_deal_subtype_value_id,
			others.template_id,
			header_buy_sell_flag,
			broker_id,
			generator_id,
			status_value_id,
			status_date,
			assignment_type_value_id,
			compliance_year,
			state_value_id,
			assigned_date,
			assigned_by,
			generation_source,
			aggregate_environment,
			aggregate_envrionment_comment,
			rec_price,
			rec_formula_id,
			rolling_avg,
			contract_id,
			sdht.create_user,
			sdht.create_ts,
			sdht.update_user,
			sdht.update_ts,
			legal_entity,
			internal_desk_id,
			product_id,	
			internal_portfolio_id,	
			commodity_id,	
			reference,	
			deal_locked,
			close_reference_id,
			block_type,	
			block_define_id,	
			granularity_id,	
			CASE WHEN others.fixed_price IS NULL THEN ISNULL(Pricing, 1600) ELSE NULL END,
			deal_reference_type_id,	
			unit_fixed_flag,
			broker_unit_fees,
			broker_fixed_cost,
			broker_currency_id,
			deal_status,
			term_frequency,
			option_settlement_date,
			verified_by,
			verified_date,
			risk_sign_off_by,
			risk_sign_off_date,
			back_office_sign_off_by,
			back_office_sign_off_date,
			book_transfer_id,
			confirm_status_type
		FROM (
				SELECT
					whatif_criteria_other_id, 
					deal_id,
					MAX(term_start) term_start, 
					MAX(term_end) term_end,
					SUM(fixed_price) fixed_price,
					counterparty,
					template_id,
					sub_book_id
				FROM
					#tmp_others
				GROUP BY whatif_criteria_other_id,deal_id,counterparty,template_id, sub_book_id
				) others
		INNER JOIN source_deal_header_template sdht ON sdht.template_id = others.template_id
		INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = others.sub_book_id'
		
		exec spa_print @sql_stmt
		EXEC(@sql_stmt)

		--Creating table @hypo_deal_detail
		/* 1- We are replacing source_deal_detail table with below process table in spa_calc_mtm_job to run WhatIf calculation using the value of process table but if we add new column in the source_deal_detail and use that in the calculation then logic expect the same column from this process table also so we copy the whole structure of main table to avoid such an issue and inserting data in the required columns only. */
		
		EXEC('SELECT * INTO ' + @hypo_deal_detail + ' FROM source_deal_detail WHERE 1 = 2')

		--Inserting data into table @hypo_deal_detail	
		SET @sql_stmt = 'INSERT INTO ' + @hypo_deal_detail + ' (
			source_deal_header_id,
			term_start,
			term_end,
			Leg,
			contract_expiration_date,
			fixed_float_leg,
			buy_sell_flag,
			curve_id,
			fixed_price,
			fixed_price_currency_id,
			option_strike_price,
			deal_volume,
			deal_volume_frequency,
			deal_volume_uom_id,	
			block_description,	
			deal_detail_description,	
			formula_id,	
			volume_left,	
			settlement_volume,	
			settlement_uom,	
			create_user,	
			create_ts,	
			update_user,	
			update_ts,	
			price_adder,	
			price_multiplier,	
			settlement_date,	
			day_count_id,	
			location_id,	
			meter_id,	
			physical_financial_flag,	
			Booked,	process_deal_status,	
			fixed_cost,	
			multiplier,	
			adder_currency_id,	
			fixed_cost_currency_id,	
			formula_currency_id,	
			price_adder2,	
			price_adder_currency2,	
			volume_multiplier2,	
			total_volume,	
			pay_opposite,	
			capacity,	
			settlement_currency,	
			standard_yearly_volume,	
			formula_curve_id,	
			price_uom_id,	
			category,	
			profile_code,	
			pv_party,
			actual_volume,
			schedule_volume
		)
		SELECT 
			(others.whatif_criteria_other_id*-1) source_deal_header_id,
			t.term_start,
			t.term_end,
			others.Leg,
			t.term_end contract_expiration_date,
			fixed_float_leg,
			others.buy_sell,
			others.curve_id,
			others.fixed_price,
			others.currency,
			option_strike_price,
			(others.deal_volume/tot.total) deal_volume,
			''t'',
			others.uom_id,	
			block_description,	
			deal_detail_description,	
			formula_id,	
			(others.deal_volume/tot.total) deal_volume,	
			settlement_volume,	
			settlement_uom,	
			sddt.create_user,	
			sddt.create_ts,	
			sddt.update_user,	
			sddt.update_ts,	
			price_adder,	
			price_multiplier,	
			t.term_end settlement_date,	
			day_count_id,	
			location_id,	
			meter_id,	
			sddt.physical_financial_flag,	
			Booked,	
			process_deal_status,	
			fixed_cost,	
			multiplier,	
			adder_currency_id,	
			fixed_cost_currency_id,	
			formula_currency_id,	
			price_adder2,	
			price_adder_currency2,	
			volume_multiplier2,	
			(others.deal_volume/tot.total) deal_volume,	
			pay_opposite,	
			capacity,	
			settlement_currency,	
			standard_yearly_volume,	
			CASE WHEN others.fixed_price IS NULL THEN others.pricing_index ELSE NULL END,	
			price_uom_id,	
			category,	
			profile_code,	
			pv_party,
			actual_volume,
			schedule_volume
		FROM #tmp_others others
		INNER JOIN source_deal_header_template sdht ON sdht.template_id = others.template_id
		INNER JOIN source_deal_detail_template sddt ON sddt.template_id = sdht.template_id
			--AND sddt.leg = others.leg
		INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = others.sub_book_id
		CROSS APPLY	[dbo].[FNATermBreakdown] (''m'', others.term_start, others.term_end) t
		OUTER APPLY	(SELECT COUNT(*) total FROM  [dbo].[FNATermBreakdown] (''m'',others.term_start, others.term_end)) tot'
		
		exec spa_print @sql_stmt
		EXEC(@sql_stmt)
				
		--End of hypothetical information collection process
		EXEC spa_collect_mapping_deals @as_of_date, 23201, @criteria_id, @std_deal_table

		IF OBJECT_ID(@std_deal_table) IS NOT NULL
		BEGIN
			EXEC ('ALTER TABLE ' + @std_deal_table + ' ADD counterparty INT')
		END

		--Added logic, not to process the deals those position is 0 or not available
		EXEC('DELETE td
		FROM ' + @std_deal_table + ' td
		OUTER APPLY (SELECT DISTINCT source_deal_header_id 
					FROM source_deal_detail 
					WHERE source_deal_header_id =  td.source_deal_header_id AND NULLIF(total_volume, 0) IS NOT NULL) sdd
		WHERE sdd.source_deal_header_id IS NULL')
			
		IF @flag = 'p'
			RETURN

		--For Testing
		IF OBJECT_ID('tempdb..#tmp_all_deal') IS NOT NULL 
		DROP TABLE #tmp_all_deal
		
		CREATE TABLE #tmp_all_deal ( deal_id INT ) 
		SET @sql_stmt = 'INSERT INTO #tmp_all_deal SELECT source_deal_header_id FROM ' + @std_deal_table
		EXEC(@sql_stmt)
		
		IF NOT EXISTS (SELECT deal_id FROM #tmp_all_deal) AND NOT EXISTS(SELECT whatif_criteria_other_id FROM #tmp_others)
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
				SELECT  @process_id, 'Error', @module, @source_value, 'no_rec', 'The deals are not found for '
				+ CASE WHEN @criteria_name IS NULL THEN '' ELSE 'Criteria: ' + dbo.FNAHyperLinkText(10183410, @criteria_name, @criteria_id) + ';'
				END + ' As_of_Date:' + dbo.FNADateFormat(@as_of_date) + '; Criteria:' + ISNULL(@criteria_name, '') + '.','Please check data.'
			
			RAISERROR ('CatchError', 16, 1)
		END
		
		SET @sql_stmt='SELECT std.* INTO ' + @calc_process_deals + ' 
		               FROM source_deal_pnl sdp 
		               RIGHT JOIN ' + @std_deal_table + ' std ON sdp.source_deal_header_id = std.source_deal_header_id 
							AND sdp.[pnl_as_of_date] = ''' + CAST(@as_of_date AS VARCHAR) + ''' 
		               WHERE sdp.source_deal_header_id  IS NULL '
		               
		exec spa_print @sql_stmt
		EXEC(@sql_stmt)
		
		TRUNCATE TABLE #tmp_rec_exist
		EXEC('INSERT INTO #tmp_rec_exist(no_rec) SELECT COUNT(1) FROM ' + @calc_process_deals)
						
		--to do: logic to collect curve ids wrt scenarios mapped on criteria.(11/27/2013)
		TRUNCATE TABLE #tmp_scenario_mapped_curve_info
		
		INSERT INTO #tmp_scenario_mapped_curve_info(curve_id, shift_by, shift_value, shift_group, shift_item, row_no, use_existing_values)
		SELECT source_curve_def_id, shift_by,shift_value, shift_group, shift_item, row_no, use_existing_values
		FROM (
			SELECT DISTINCT spcd_indx.source_curve_def_id, wcs.shift_by, wcs.shift_value, shift_group, wcs.shift_item
					, ROW_NUMBER () OVER ( PARTITION BY source_curve_def_id ORDER BY 
						CASE shift_group WHEN 24001 THEN 1 WHEN 24002 THEN 2 WHEN 24003 THEN 3 END) [row_no],
					CASE WHEN ISNULL(wcs.use_existing_values, 0) = 0 THEN 'n' ELSE 'Y' END	use_existing_values
			FROM whatif_criteria_scenario wcs
			LEFT JOIN source_price_curve_def spcd_indx 
				ON wcs.shift_item = CASE wcs.shift_group WHEN 24001 THEN spcd_indx.source_curve_def_id 
										 WHEN 24002 THEN spcd_indx.index_group
										 WHEN 24003 THEN spcd_indx.commodity_id
										 ELSE 0
									END
			WHERE wcs.criteria_id = @criteria_id --AND wcs.scenario_type = 'i' --AND wcs.use_existing_values <> 'y' 
		) scenario_cr WHERE scenario_cr.row_no < 2

		
		INSERT INTO #tmp_scenario_mapped_curve_info(curve_id, shift_by, shift_value, shift_group, shift_item, row_no, use_existing_values)
		SELECT source_curve_def_id, shift_by,shift_value, shift_group, shift_item, row_no, use_existing_values
		FROM (
			SELECT DISTINCT source_curve_def_id,shift_by, shift_value, shift_group, shift_item
					, ROW_NUMBER () OVER (PARTITION BY source_curve_def_id ORDER BY 
						CASE shift_group WHEN 24001 THEN 1 WHEN 24002 THEN 2 WHEN 24003 THEN 3 END) [row_no]
					,CASE WHEN ISNULL(ms.use_existing_values, 0) = 0 THEN 'n' ELSE 'Y' END	use_existing_values	
			FROM maintain_whatif_criteria mwc
			INNER JOIN maintain_scenario ms ON ms.scenario_group_id = mwc.scenario_group_id
			LEFT JOIN source_price_curve_def spcd 
				ON ms.shift_item = CASE ms.shift_group WHEN 24001 THEN spcd.source_curve_def_id 
										 WHEN 24002 THEN spcd.index_group
										 WHEN 24003 THEN spcd.commodity_id
										 ELSE 0
								   END
			WHERE mwc.criteria_id = @criteria_id -- AND ms.scenario_type = 'i'--AND ms.use_existing_values <> 'y'
		) scenario_gr 
		WHERE scenario_gr.row_no < 2
			AND NOT EXISTS(SELECT curve_id FROM #tmp_scenario_mapped_curve_info WHERE source_curve_def_id = curve_id)
		
		IF EXISTS(SELECT TOP 1 1 FROM #tmp_scenario_mapped_curve_info WHERE curve_id IS NULL)
		BEGIN
			SELECT @shift_by = shift_by, @shift_val = shift_value FROM #tmp_scenario_mapped_curve_info WHERE curve_id IS NULL
			
			SET @sql_stmt = 'INSERT INTO #tmp_scenario_mapped_curve_info(curve_id, shift_by, shift_value, use_existing_values)  
			SELECT DISTINCT spcd.source_curve_def_id, ''' + @shift_by + ''',' + CAST(@shift_val AS VARCHAR) + ', ''n''
			FROM source_price_curve_def spcd
			EXCEPT 
			SELECT DISTINCT curve_id, ''' + @shift_by + ''',' + CAST(@shift_val AS VARCHAR) + ', ''n'' FROM #tmp_scenario_mapped_curve_info'	
			
			exec spa_print @sql_stmt
			EXEC(@sql_stmt)
		END
		
		EXEC('TRUNCATE TABLE ' + @whatif_shift )
		EXEC('TRUNCATE TABLE ' + @whatif_shift_new)
					
		SET @sql_stmt = '
		INSERT INTO ' + @whatif_shift + ' (
			curve_id,
			curve_shift_val, 
			curve_shift_per,
			shift_by
		)
		SELECT curve_id,  
		CASE shift_by WHEN ''p'' THEN 0 WHEN ''c'' THEN shift_value ELSE ISNULL(shift_value, 0) END, 
		CASE shift_by WHEN ''v'' THEN 1 WHEN ''u'' THEN shift_value ELSE ISNULL(1 + shift_value/100, 1) END,
		shift_by
		FROM #tmp_scenario_mapped_curve_info 
		WHERE use_existing_values = ''n''
			AND curve_id IS NOT NULL' 
		
		exec spa_print @sql_stmt
		EXEC(@sql_stmt)	
		
		EXEC('INSERT INTO ' + @whatif_shift_new + ' SELECT * FROM ' + @whatif_shift + ' WHERE shift_by IN(''c'',''u'')')
		EXEC('DELETE FROM ' + @whatif_shift + ' WHERE shift_by IN(''c'',''u'')')
		
		SET @use_existing_values = 'n'

		IF NOT EXISTS(SELECT TOP 1 1 FROM #tmp_scenario_mapped_curve_info WHERE use_existing_values <> 'y')
		BEGIN
			SET @use_existing_values = 'y'
		END
		
		--to do: logic to collect curve ids wrt scenarios mapped on criteria.(11/27/2013)
		
		
		-- run mtm calc for each scenario
		SELECT @mtm = wcm.MTM, 
			@position = wcm.position, 
			@var = wcm.[Var],
			@credit = wcm.credit, 
			@cfar = wcm.Cfar, 
			@ear = wcm.Ear,
			@pfe = wcm.PFE,
			@Gmar = wcm.Gmar, 
			@measurement_approach = wcm.var_approach, 
			@confidence_interval = wcm.confidence_interval, 
			@holding_period = ISNULL(wcm.holding_days, 1),
			@curve_source_value_id = ISNULL(ISNULL(mwc.source, msg.source), 4500),
			@no_of_simulation = wcm.no_of_simulations,
			@revaluation = mwc.revaluation
		FROM maintain_whatif_criteria mwc	
		INNER JOIN whatif_criteria_measure wcm ON wcm.criteria_id = mwc.criteria_id
		LEFT JOIN maintain_scenario_group msg ON mwc.scenario_group_id = msg.scenario_group_id
		WHERE wcm.criteria_id = @criteria_id		
		
		DECLARE @scenario_type CHAR(1)
		SELECT @scenario_type = COALESCE(mcs.scenario_type, ms.scenario_type, 'i')
		FROM maintain_whatif_criteria mwc
		LEFT JOIN whatif_criteria_scenario mcs ON mcs.criteria_id = mwc.criteria_id
			AND mcs.scenario_type = 'm'
		LEFT JOIN maintain_scenario ms ON ms.scenario_group_id = mwc.scenario_group_id
			AND ms.scenario_type = 'm'
		WHERE mwc.criteria_id = @criteria_id
		
		SELECT 
			@term_start = pmt.term_start,
			@term_end = pmt.term_end,
			@tenor_from = pmt.starting_month,
			@tenor_to = pmt.no_of_month
		FROM portfolio_mapping_source pms
		INNER JOIN portfolio_mapping_tenor pmt ON pmt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
		WHERE pms.mapping_source_usage_id = @criteria_id
			AND pms.mapping_source_value_id = 23201
			
		SET @term_start = dbo.FNAGetContractMonth(ISNULL(@term_start, DATEADD (MONTH, CAST(@tenor_from AS INT), @as_of_date)))
		SET @term_end = dbo.FNALastDayInDate(ISNULL(@term_end, DATEADD (MONTH, CAST(@tenor_to AS INT), @as_of_date)))

		IF @scenario_type = 'm'
		BEGIN
			--Multiple Scenario Shifting Logic Starts Here
			EXEC dbo.spa_shift_multiple_scenario
				@as_of_date = @as_of_date
				, @criteria_id = @criteria_id
				, @term_start = @term_start
				, @term_end = @term_end
				, @delta = 'y'
				, @purge = 'n'
				, @process_id = @process_id
		END
		ELSE
		BEGIN
			-------------Revaluation Changes starts here----------------------------
			-------------Revaluation means to run the whole process and that includes price,mtm simulation and continue with other process---------------
			IF @revaluation = 'y' AND COALESCE(NULLIF(@var, 'n'),NULLIF(@cfar, 'n'),NULLIF(@ear, 'n'),NULLIF(@pfe, 'n')) IS NOT NULL
			BEGIN
				DECLARE @curve_ids VARCHAR(1000) = NULL, @source_deal_header_id VARCHAR(1000) = NULL

				IF OBJECT_ID('tempdb..#curve_ids') IS NOT NULL
				DROP TABLE #curve_ids

				CREATE TABLE #curve_ids(curve_id INT, term_start DATETIME, term_end DATETIME)
				EXEC('INSERT INTO #curve_ids SELECT DISTINCT curve_id, term_start, term_end FROM ' + @hypo_deal_detail)

				INSERT INTO #curve_ids
				SELECT DISTINCT sdd.curve_id, sdd.term_start, sdd.term_end
				FROM #tmp_all_deal tad
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tad.deal_id
				UNION
				SELECT DISTINCT sdd.formula_curve_id, sdd.term_start, sdd.term_end
				FROM #tmp_all_deal tad
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tad.deal_id
				WHERE sdd.formula_curve_id IS NOT NULL
 
				SELECT @curve_ids = COALESCE(@curve_ids + ',', '') + CAST(curve_id AS VARCHAR)
				FROM #curve_ids
				GROUP BY curve_id

				SELECT @term_start = ISNULL(@term_start, MIN(term_start)), 
					@term_end = ISNULL(@term_end, MAX(term_end)) 
				FROM #curve_ids

				IF OBJECT_ID(@sim_whatif_shift) IS NOT NULL EXEC('DROP TABLE ' + @sim_whatif_shift)
				IF OBJECT_ID(@sim_whatif_shift_new) IS NOT NULL EXEC('DROP TABLE ' + @sim_whatif_shift_new)

				EXEC('SELECT * INTO ' + @sim_whatif_shift + ' FROM ' + @whatif_shift)
				EXEC('SELECT * INTO ' + @sim_whatif_shift_new + ' FROM ' + @whatif_shift_new)

				EXEC spa_monte_carlo_simulation
					@as_of_date = @as_of_date,
					@term_start = @term_start,
					@term_end = @term_end,
					@no_simulation = @no_of_simulation,
					@model_id = NULL,
					@risk_ids = @curve_ids,
					@all_risk = NULL,
					@purge = 'y',
					@run_cor_decom = 'y',
					@criteria_id = @criteria_id,
					@batch_process_id = @sim_process_id
				
				--To check the status of monte carlo simulation job whether it's completed or not
				confirmStatus:
				
				IF EXISTS(SELECT sims_status FROM tbl_sims_status WHERE process_id = @sim_process_id AND sims_status = 'R')
					GOTO confirmStatus
				
				IF EXISTS(SELECT 1 FROM #tmp_all_deal)
				EXEC spa_calc_mtm_job_wrapper
					@calc_type = 'y',
					@as_of_date = @as_of_date,
					@deal_list_table = @std_deal_table,
					@curve_source_value_id = 4500,
					@pnl_source_value_id = NULL,
					@portfolio_group_id = NULL,
					@transaction_type_id = '400,401',
					@purge = 'y',
					@criteria_id = @criteria_id
			END		
			----------------Revaluation Changes ends here-------------------------
			
			EXEC spa_print 'Deleting previous MTM'

			SET @sql_stmt = 'DELETE stpw
				FROM [source_deal_pnl_detail_options_WhatIf] stpw
				WHERE stpw.as_of_date = ''' + @as_of_date + '''
					  AND stpw.criteria_id = ' + CAST(@criteria_id AS VARCHAR(50))
			EXEC spa_print @sql_stmt
			EXEC(@sql_stmt)		
	
			SET @sql_stmt = 'DELETE stpw
				FROM source_deal_pnl_detail_whatif stpw
				WHERE stpw.pnl_as_of_date = ''' + @as_of_date + '''
					  AND stpw.criteria_id = ' + CAST(@criteria_id AS VARCHAR(50))
			EXEC spa_print @sql_stmt
			EXEC(@sql_stmt)

			SET @sql_stmt = 'DELETE stpw
				FROM source_deal_pnl_whatif stpw
				WHERE stpw.pnl_as_of_date = ''' + @as_of_date + '''
					  AND stpw.criteria_id = ' + CAST(@criteria_id AS VARCHAR(50))
			EXEC spa_print @sql_stmt
			EXEC(@sql_stmt)
			
			SET	@mtm_process_id = @process_id 
			SET @i = @i + 1
			
			IF @use_existing_values = 'y'
			BEGIN
				EXEC spa_print 'Use Existing MTM'

				SET @sql_stmt = '
					INSERT INTO [dbo].[source_deal_pnl_WhatIf]
					([criteria_id], [source_deal_header_id], [term_start], [term_end], [Leg], [pnl_as_of_date], [und_pnl]
					,[und_intrinsic_pnl], [und_extrinsic_pnl], [dis_pnl],[dis_intrinsic_pnl], [dis_extrinisic_pnl]
					,[pnl_source_value_id], [pnl_currency_id], [pnl_conversion_factor], [pnl_adjustment_value]
					,[deal_volume], [create_user], [create_ts], [update_user], [update_ts], [und_pnl_set], [market_value], [contract_value], [dis_market_value],[dis_contract_value] )
					SELECT 
					' + CAST(@criteria_id AS VARCHAR) + ' [criteria_id],sdp.[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl]
					,[und_intrinsic_pnl],[und_extrinsic_pnl],[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl]
					,[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor],[pnl_adjustment_value]
					,[deal_volume],[create_user],[create_ts],[update_user],[update_ts],[und_pnl_set],[market_value], [contract_value], [dis_market_value], [dis_contract_value]
					FROM source_deal_pnl sdp INNER JOIN ' + @std_deal_table + ' std ON sdp.source_deal_header_id = std.source_deal_header_id AND [pnl_as_of_date] = ''' + CAST(@as_of_date AS VARCHAR) + '''
					WHERE sdp.pnl_source_value_id = ''' + CAST(@curve_source_value_id AS VARCHAR) + ''''
				exec spa_print @sql_stmt
				EXEC(@sql_stmt)

				SET @sql_stmt = '
					INSERT INTO [dbo].[source_deal_pnl_detail_WhatIf]
					([criteria_id],[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl],[dis_pnl],[dis_intrinsic_pnl]
					,[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor],[pnl_adjustment_value],[deal_volume],[curve_id],[accrued_interest],[price],[discount_rate],[no_days_left]
					,[days_year],[discount_factor],[create_user],[create_ts],[update_user],[update_ts],[curve_as_of_date],[internal_deal_type_value_id]
					,[internal_deal_subtype_value_id],[curve_uom_conv_factor],[curve_fx_conv_factor],[price_fx_conv_factor],[curve_value]
					,[fixed_cost],[fixed_price],[formula_value],[price_adder],[price_multiplier],[strike_price],[buy_sell_flag],[expired_term]
					,[und_pnl_set],[fixed_cost_fx_conv_factor],[formula_fx_conv_factor],[price_adder1_fx_conv_factor],[price_adder2_fx_conv_factor]
					,[volume_multiplier],[volume_multiplier2],[price_adder2],[pay_opposite],[market_value],[contract_value],[dis_market_value],[dis_contract_value])
					SELECT 
					' + CAST(@criteria_id AS VARCHAR) + ' [criteria_id],sdpd.[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl],[dis_pnl],[dis_intrinsic_pnl]
					,[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor],[pnl_adjustment_value],[deal_volume],[curve_id],[accrued_interest],[price],[discount_rate],[no_days_left]
					,[days_year],[discount_factor],[create_user],[create_ts],[update_user],[update_ts],[curve_as_of_date],[internal_deal_type_value_id]
					,[internal_deal_subtype_value_id],[curve_uom_conv_factor],[curve_fx_conv_factor],[price_fx_conv_factor],[curve_value]
					,[fixed_cost],[fixed_price],[formula_value],[price_adder],[price_multiplier],[strike_price],[buy_sell_flag],[expired_term]
					,[und_pnl_set],[fixed_cost_fx_conv_factor],[formula_fx_conv_factor],[price_adder1_fx_conv_factor],[price_adder2_fx_conv_factor]
					,[volume_multiplier],[volume_multiplier2],[price_adder2],[pay_opposite],[market_value],[contract_value],[dis_market_value],[dis_contract_value]
					FROM source_deal_pnl_detail sdpd INNER JOIN ' + @std_deal_table + ' std ON sdpd.source_deal_header_id = std.source_deal_header_id AND [pnl_as_of_date] = ''' + CAST(@as_of_date AS VARCHAR) + '''
					WHERE sdpd.pnl_source_value_id = ''' + CAST(@curve_source_value_id AS VARCHAR) + ''''
				exec spa_print @sql_stmt
				EXEC(@sql_stmt)

				SET @sql_stmt = '
					INSERT INTO [dbo].[source_deal_pnl_detail_options_WhatIf]
					([criteria_id],[as_of_date],[source_deal_header_id],[term_start],[curve_1],[curve_2],[option_premium]
					,[strike_price],[spot_price_1],[days_expiry],[volatility_1],[discount_rate],[option_type],[excercise_type]
					,[source_deal_type_id],[deal_sub_type_type_id],[internal_deal_type_value_id],[internal_deal_subtype_value_id]
					,[deal_volume],[deal_volume_frequency],[deal_volume_uom_id],[correlation],[volatility_2],[spot_price_2],[deal_volume2]
					,[PREMIUM],[DELTA],[GAMMA],[VEGA],[THETA],[RHO],[DELTA2],[create_user],[create_ts],[pnl_source_value_id],[total_deal_volume])
					SELECT 
					' + CAST(@criteria_id AS VARCHAR) + ' [criteria_id]
					,[as_of_date],sdpdo.[source_deal_header_id],[term_start],[curve_1],[curve_2],[option_premium]
					,[strike_price],[spot_price_1],[days_expiry],[volatility_1],[discount_rate],[option_type],[excercise_type]
					,[source_deal_type_id],[deal_sub_type_type_id],[internal_deal_type_value_id],[internal_deal_subtype_value_id]
					,[deal_volume],[deal_volume_frequency],[deal_volume_uom_id],[correlation],[volatility_2],[spot_price_2],[deal_volume2]
					,[PREMIUM],[DELTA],[GAMMA],[VEGA],[THETA],[RHO],[DELTA2],[create_user],[create_ts],[pnl_source_value_id],[total_deal_volume]
					FROM [source_deal_pnl_detail_options] sdpdo INNER JOIN ' + @std_deal_table + ' std ON sdpdo.source_deal_header_id = std.source_deal_header_id AND [as_of_date] = ''' + CAST(@as_of_date AS VARCHAR) + '''
					WHERE sdpdo.pnl_source_value_id = ''' + CAST(@curve_source_value_id AS VARCHAR) + ''''
				exec spa_print @sql_stmt
				EXEC(@sql_stmt)
				
				IF EXISTS (SELECT whatif_criteria_other_id FROM #tmp_others)
				BEGIN
					SET @sql_stmt = '
					EXEC [dbo].[spa_calc_mtm_job] 
						@sub_id = NULL, 
						@strategy_id = NULL, 
						@book_id = NULL, 
						@source_book_mapping_id = NULL, 
						@source_deal_header_id = NULL, 
						@as_of_date = ''' + @as_of_date + ''', 
						@curve_source_value_id = ' + ISNULL(CAST(@curve_source_value_id AS VARCHAR), NULL) + ', 
						@pnl_source_value_id = ' + ISNULL(CAST(@curve_source_value_id AS VARCHAR), NULL) + ',
						@hedge_or_item = NULL, 
						@process_id = ''' + @mtm_process_id + ''',
						@job_name = NULL,
						@user_id = ''' + ISNULL(@user_name, NULL) + ''',
						@assessment_curve_type_value_id = 77,
						@table_name = NULL,
						@print_diagnostic = NULL,
						@curve_as_of_date = NULL,
						@tenor_option = NULL,
						@summary_detail = NULL,
						@options_only = NULL,
						@trader_id = NULL,
						@status_table_name = NULL,
						@run_incremental = NULL,
						@term_start = ''' + @as_of_date + ''',
						@term_end = ''' + @as_of_date + ''',
						@calc_type = ''w'',
						@curve_shift_val = NULL,
						@curve_shift_per = NULL, 
						@deal_list_table = NULL,
						@criteria_id = ' + CAST(@criteria_id AS VARCHAR) + ''
						
					exec spa_print @sql_stmt
					EXEC(@sql_stmt)	
				END
			END
			ELSE
			BEGIN
				EXEC spa_print 'Calculating new MTM (without using existing)'
				-- calculate mtm for each scenario
				
				SET @sql_stmt = '
					EXEC [dbo].[spa_calc_mtm_job] 
						@sub_id = NULL, 
						@strategy_id = NULL, 
						@book_id = NULL, 
						@source_book_mapping_id = NULL, 
						@source_deal_header_id = NULL, 
						@as_of_date = ''' + @as_of_date + ''', 
						@curve_source_value_id = ' + ISNULL(CAST(@curve_source_value_id AS VARCHAR), NULL) + ', 
						@pnl_source_value_id = ' + ISNULL(CAST(@curve_source_value_id AS VARCHAR), NULL) + ',
						@hedge_or_item = NULL, 
						@process_id = ''' + @mtm_process_id + ''',
						@job_name = NULL,
						@user_id = ''' + ISNULL(@user_name, NULL) + ''',
						@assessment_curve_type_value_id = 77,
						@table_name = NULL,
						@print_diagnostic = NULL,
						@curve_as_of_date = NULL,
						@tenor_option = NULL,
						@summary_detail = NULL,
						@options_only = NULL,
						@trader_id = NULL,
						@status_table_name = NULL,
						@run_incremental = NULL,
						@term_start = ''' + @as_of_date + ''',
						@term_end = ''' + @as_of_date + ''',
						@calc_type = ''w'',
						@curve_shift_val = NULL,
						@curve_shift_per = NULL, 
						@deal_list_table = ''' + @std_deal_table + ''',
						@criteria_id = ' + CAST(@criteria_id AS VARCHAR) + ''
						
				exec spa_print @sql_stmt
				EXEC(@sql_stmt)
					
			END
		 
			--select @measure
		END
			IF EXISTS(SELECT 1 FROM MTM_TEST_RUN_LOG WHERE process_id=@process_id) AND NOT EXISTS(SELECT 1 FROM MTM_TEST_RUN_LOG WHERE code IN ('Success', 'Warning') and process_id=@process_id)
			BEGIN 
			
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
				SELECT  @process_id, 'Error', @module, @source_value, 'mtm_err', 'Error found for the '
				+ CASE WHEN @criteria_name IS NULL THEN '' ELSE 'Criteria: ' + dbo.FNAHyperLinkText(10183410, @criteria_name, @criteria_id) + ' while calculating MTM on '
				END +  dbo.FNADateFormat(@as_of_date) + '.','Please check data.'
			END
			ELSE
			BEGIN
				SET @sql_stmt = 'INSERT INTO ' + @std_deal_table + ' (source_deal_header_id, real_deal, counterparty)
						SELECT DISTINCT (whatif_criteria_other_id * -1) deal_id, ''n'',	counterparty FROM #tmp_others '
					
				exec spa_print @sql_stmt
				EXEC(@sql_stmt)	
				
				IF @var = 'y' --var	
				BEGIN
					IF @measurement_approach = '1520'
					BEGIN
						SET @sql_stmt = '
						EXEC [dbo].spa_calc_VAR_job 
								@as_of_date = ''' + @as_of_date + ''',  
								@var_criteria_id = -1, 
								@term_start = NULL, 
								@term_end = NULL, 
								@whatif_criteria_id = ' + @criteria_id + ', 
								@calc_type = ''w'', 
								@tbl_name = ''' + @std_deal_table + ''',
								@measurement_approach = ' + CAST(@measurement_approach AS VARCHAR) + ',
								@conf_interval = ''' + CAST(@confidence_interval AS VARCHAR) + ''', 
								@hold_period = ' + CAST(@holding_period AS VARCHAR) + ', 
								@process_id = ''' + @process_id + ''''
								
						exec spa_print @sql_stmt
						EXEC(@sql_stmt) 
					END
					
					IF @measurement_approach = '1522'
					BEGIN
						SET @sql_stmt = '
						EXEC [dbo].spa_calc_VAR_Simulation_job
								@as_of_date = ''' + @as_of_date + ''',
								@var_criteria_id = -' + @criteria_id + ',
								@term_start = NULL,
								@term_end = NULL,
								@whatif_criteria_id = ' + @criteria_id + ',
								@calc_type = ''w'',
								@tbl_name = ''' + @std_deal_table + ''',
								@measurement_approach = ' + CAST(@measurement_approach AS VARCHAR) + ',
								@conf_interval = ''' + CAST(@confidence_interval AS VARCHAR) + ''', 
								@hold_period = ' + CAST(@holding_period AS VARCHAR) + ',
								@process_id = ''' + @mtm_process_id + ''',
								@measure = 17351'
								
						exec spa_print @sql_stmt
						EXEC(@sql_stmt) 			
					END
					
					IF @measurement_approach = '1521'
					BEGIN
						SET @sql_stmt = '
						EXEC [dbo].spa_calc_VAR_Simulation_job
								@as_of_date = ''' + @as_of_date + ''',
								@var_criteria_id = 0,
								@term_start = NULL,
								@term_end = NULL,
								@whatif_criteria_id = ' + @criteria_id + ',
								@calc_type = ''w'',
								@tbl_name = ''' + @std_deal_table + ''',
								@measurement_approach = ' + CAST(@measurement_approach AS VARCHAR) + ',
								@conf_interval = ''' + CAST(@confidence_interval AS VARCHAR) + ''', 
								@hold_period = ' + CAST(@holding_period AS VARCHAR) + ',
								@process_id = ''' + @mtm_process_id + ''',
								@measure = 17351'
								
						exec spa_print @sql_stmt
						EXEC(@sql_stmt) 			
					END
				
				END
				
				IF @credit = 'y' --Credit Exposure Calculation for WhatIf
				BEGIN
					DECLARE @counterparty_list_real VARCHAR(500), @counterparty_list_hypo VARCHAR(500)
					
					SELECT @counterparty_list_real = COALESCE(@counterparty_list_real + ',', '') + CAST(a.counterparty_id AS VARCHAR)
					FROM (SELECT DISTINCT sdh.counterparty_id FROM #tmp_all_deal td
							INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.deal_id) a
							
					SELECT @counterparty_list_hypo = COALESCE(@counterparty_list_hypo + ',', '') + CAST(td.counterparty AS VARCHAR)
					FROM (SELECT DISTINCT counterparty FROM #tmp_others) td
					
					SET @sql_stmt = '[dbo].[spa_Calc_Credit_Netting_Exposure] 
						@as_of_date = ''' + @as_of_date + ''',
						@curve_source_value_id = ''' + CAST(@curve_source_value_id AS VARCHAR) + ''',
						@counterparty_id = ''' + @counterparty_list_real + ''',
						@what_if_group = NULL,
						@simulation = NULL,
						@batch_process_id = ''' + @mtm_process_id + ''',
						@purge_all = ''n'',
						@calc_type = ''m'',
						@criteria_id = ' + @criteria_id + ',
						@trigger_workflow =  ''' + @trigger_workflow + ''''
					
					exec spa_print @sql_stmt
					EXEC(@sql_stmt)
					
					----It is commented because we can't call SP twice both real and hypothetical deal's exposure should be calculated from the above call, so it will be reviewed later.
					--IF @counterparty_list_hypo IS NOT NULL
					--BEGIN
					--	--Calculating exposure for hypothetical deals: credit_exposure_detail	
					--	SET @sql_stmt = '[dbo].[spa_Calc_Credit_Netting_Exposure] 
					--		@as_of_date = ''' + @as_of_date + ''',
					--		@curve_source_value_id = ''' + CAST(@curve_source_value_id AS VARCHAR) + ''',
					--		@counterparty_id = ''' + @counterparty_list_hypo + ''',
					--		@what_if_group = NULL,
					--		@simulation = NULL,
					--		@batch_process_id = ''' + @mtm_process_id + ''',
					--		@purge_all = ''n'',
					--		@calc_type = ''m''
					--		@criteria_id = -' + @criteria_id
						
					--	--PRINT(@sql_stmt)
					--	EXEC(@sql_stmt)
					--END
				END
				
				IF @Gmar = 'y'
				BEGIN
					SET @sql_stmt = '
						EXEC [dbo].spa_calc_VAR_Simulation_job
								@as_of_date = ''' + @as_of_date + ''',
								@var_criteria_id = 0,
								@term_start = NULL,
								@term_end = NULL,
								@whatif_criteria_id = ' + @criteria_id + ',
								@calc_type = ''w'',
								@tbl_name = ''' + @std_deal_table + ''',
								@measurement_approach = ' + CAST(@measurement_approach AS VARCHAR) + ',
								@conf_interval = ''' + CAST(@confidence_interval AS VARCHAR) + ''', 
								@hold_period = ' + CAST(@holding_period AS VARCHAR) + ',
								@process_id = ''' + @mtm_process_id + ''',
								@measure = 17357'
								
						--PRINT(@sql_stmt)
						EXEC(@sql_stmt) 
				END
				
				IF @cfar = 'y' --CFaR
				BEGIN
					SET @sql_stmt = '
					EXEC [dbo].spa_calc_VAR_Simulation_job
							@as_of_date = ''' + @as_of_date + ''',
							@var_criteria_id = -' + @criteria_id + ',
							@term_start = NULL,
							@term_end = NULL,
							@whatif_criteria_id = ' + @criteria_id + ',
							@calc_type = ''w'',
							@tbl_name = ''' + @std_deal_table + ''',
							@measurement_approach = 1522,
							@conf_interval = ''' + CAST(@confidence_interval AS VARCHAR) + ''', 
							@hold_period = ' + CAST(@holding_period AS VARCHAR) + ',
							@process_id = ''' + @mtm_process_id + ''',
							@measure = 17352'
							
					exec spa_print @sql_stmt
					EXEC(@sql_stmt)	
				END
				IF @ear = 'y' --EaR
				BEGIN
					SET @sql_stmt = '
					EXEC [dbo].spa_calc_VAR_Simulation_job
							@as_of_date = ''' + @as_of_date + ''',
							@var_criteria_id = -' + @criteria_id + ',
							@term_start = NULL,
							@term_end = NULL,
							@whatif_criteria_id = ' + @criteria_id + ',
							@calc_type = ''w'',
							@tbl_name = ''' + @std_deal_table + ''',
							@measurement_approach = 1522,
							@conf_interval = ''' + CAST(@confidence_interval AS VARCHAR) + ''', 
							@hold_period = ' + CAST(@holding_period AS VARCHAR) + ',
							@process_id = ''' + @mtm_process_id + ''',
							@measure = 17353'
							
					exec spa_print @sql_stmt
					EXEC(@sql_stmt)	
				END
				IF @pfe = 'y' --PFE
				BEGIN
					SET @sql_stmt = '
					EXEC [dbo].spa_calc_VAR_Simulation_job
							@as_of_date = ''' + @as_of_date + ''',
							@var_criteria_id = -' + @criteria_id + ',
							@term_start = NULL,
							@term_end = NULL,
							@whatif_criteria_id = ' + @criteria_id + ',
							@calc_type = ''w'',
							@tbl_name = ''' + @std_deal_table + ''',
							@measurement_approach = 1522,
							@conf_interval = ''' + CAST(@confidence_interval AS VARCHAR) + ''', 
							@hold_period = ' + CAST(@holding_period AS VARCHAR) + ',
							@process_id = ''' + @mtm_process_id + ''',
							@measure = 17355'

					exec spa_print @sql_stmt
					EXEC(@sql_stmt)	
				END
			END
			
			
		exec spa_print '-----------------------------------------------------------------	end loop senario---------------------------------------'	
		EXEC spa_print 'scenario_detail_id:', @criteria_id, '  ;@shift_val:', @shift_val
		
		exec spa_print '------------------------------------------------------------------------	end loop criteria---------------------------------------'	
		EXEC spa_print '@criteria_id:', @criteria_id, '  ;@criteria_name:', @criteria_name


		FETCH NEXT FROM cur_whatif_criteria INTO @criteria_id, @criteria_name, @criteria_description
	END
	
	EXEC spa_print 'Finish Whatif Calculation'
	-- select dbo.FNAUserDateFormat(@as_of_date, @user_name) ,@as_of_date, @user_name
	EXEC spa_print @errorcode
	EXEC spa_print @process_id
	
	IF EXISTS( SELECT 1 FROM fas_eff_ass_test_run_log WHERE process_id = @process_id AND code = 'Error' AND module <> 'PFE Simulation Calculation')
	BEGIN
		SET @desc='Whatif Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + ' (ERRORS found).'		
		SET @errorcode = 'e'
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name +  
				'&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''

		SET @temptablequery ='exec '+DB_NAME()+'.dbo.spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''
	END
	ELSE IF NOT EXISTS( SELECT 1 FROM fas_eff_ass_test_run_log WHERE process_id = @process_id AND module = 'PFE Simulation Calculation' AND code IN ('Warning','Success')) AND @pfe = 'y'
	BEGIN
		SET @desc='Whatif Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + ' (ERRORS found).'		
		SET @errorcode = 'e'
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name +  
				'&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''

		SET @temptablequery ='exec '+DB_NAME()+'.dbo.spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''
	END
	ELSE 
	BEGIN
		SET @desc = 'Whatif Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + '.'
		SET @errorcode = 's'
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
					'&spa=exec spa_run_whatif_scenario_report  ''' + @as_of_date + ''',''m'',''' + CAST(@whatif_criteria_id AS VARCHAR)+''',''y'''
		SET @temptablequery = 'exec '+DB_NAME()+'.dbo.spa_run_whatif_scenario_report  ''' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + ''',''m'',' + CAST(@criteria_id AS VARCHAR)+ ',''y'''

	END

	CLOSE cur_whatif_criteria
	DEALLOCATE cur_whatif_criteria
	
	IF @show_output = 1 
	BEGIN
		IF OBJECT_ID('tempdb..#tmp_result_calc_mtm_whatif') IS NOT NULL
		BEGIN
			INSERT INTO #tmp_result_calc_mtm_whatif (ErrorCode, Module, Area, Status, Message, Recommendation) 
			SELECT 'Success', 'Run Whatif', 'spa_calc_mtm_whatif', 'Success', @desc, ''
		END
	END
	
-------------------End error Trapping--------------------------------------------------------------------------
END TRY

BEGIN CATCH
	EXEC spa_print 'Catch Error'
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC spa_print @process_id
	SET @errorcode = 'e'
	--EXEC spa_print  ERROR_LINE ()
	IF ERROR_MESSAGE() = 'CatchError'
	BEGIN
		SET @desc = 'Whatif Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + ' (ERRORS found).'
		EXEC spa_print @desc
	END
	ELSE
	BEGIN
		SET @desc = 'Whatif Calculation critical error found ( Errr Description:' +  ERROR_MESSAGE() + '; Line no: ' + CAST(ERROR_LINE() AS VARCHAR) + ').'
		EXEC spa_print @desc
	END

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
				'&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''

	SET @temptablequery = 'exec '+DB_NAME()+'.dbo.spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''

	IF @show_output = 1
	BEGIN
		IF OBJECT_ID('tempdb..#tmp_result_calc_mtm_whatif') IS NOT NULL
		BEGIN
			INSERT INTO #tmp_result_calc_mtm_whatif (ErrorCode, Module, Area, Status, Message, Recommendation) 
			SELECT 'Techinical Error', 'Run Whatif', 'spa_calc_mtm_whatif', 'Techinical Error', @desc, ''
		END
	END
END CATCH

IF NOT EXISTS(SELECT 1 FROM message_board WHERE process_id = @process_id AND source = 'What-If MTM Value Calculation')	
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'

--DECLARE @source VARCHAR(5000)
--SELECT @source = './dev/spa_html.php?__user_name__=' + @user_name + 
--					'&spa=exec spa_run_whatif_scenario_report  ''' + @as_of_date + ''',''v'','+ CAST(@criteria_id AS VARCHAR)+',''y'''
--SELECT @source = @desc+ '<a target="_blank" href="' + @source + '">  [Whatif Result]</a>'

EXEC  spa_message_board 'i', @user_name,
			NULL, 'Whatif Analysis',
			@desc, '', '', @errorcode, @process_id, NULL, @process_id, NULL,'n', @temptablequery, 'y' 
