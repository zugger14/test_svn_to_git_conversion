
IF OBJECT_ID('dbo.spa_calc_VAR_Simulation_job') IS NOT NULL
DROP PROC [dbo].[spa_calc_VAR_Simulation_job]
GO
/**
	Calculate Cash Flow at Risk(CFaR), Earning at Risk(EaR), Gross Marging at Risk(GMaR), Potential Futuer Exposure(PFE), Value at Risk(VaR) using Monte Carlo Simulation approach

	Parameters :
	@as_of_date : Date for processing
	@var_criteria_id : Criteria ID to process the calculation
	@term_start : Term Start filter to process 
	@term_end : Term End filter to process
	@whatif_criteria_id : WhatIf Criteria ID to process the calculation
	@calc_type : Calculation Type - 'r' - 'At Risk', 'w' - 'What If' 
	@tbl_name : Provide table which holds deals to process
	@measurement_approach : Approach to use in the calculation as defined in the static data
								1522 - Monte Carlo Simulation
	@conf_interval : Percentage for the calculation as defined in the static data
						1502 - 99%, 1503 - 90%, 1504 - 95%
	@hold_period : Integer value to multiply processed value using square root 
	@counterparty_id : Counterparty filter to process
	@process_id : To run calculation using provided process id
	@job_name : Job name to Create
	@measure : Measures to calculate as defined in the static data
						17352 - CFaR, 17353 - EaR, 17357 - GMaR, 17355 - PFE, 17351 - VaR
	@batch_process_id : Process id when run through batch
	@batch_report_param	: Paramater to run through batch

**/
CREATE PROC [dbo].[spa_calc_VAR_Simulation_job] 
@as_of_date DATETIME,
@var_criteria_id INT,
@term_start VARCHAR(25)= NULL,
@term_end VARCHAR(25)= NULL,
@whatif_criteria_id INT = NULL,
@calc_type VARCHAR(1) = 'r',
@tbl_name VARCHAR(200) = NULL,
@measurement_approach INT = NULL,
@conf_interval INT = NULL,
@hold_period INT = NULL,
@counterparty_id INT = NULL,
@process_id VARCHAR(50)= NULL,
@job_name VARCHAR(100)= NULL,
@measure INT = 17351, --VaR
@batch_process_id VARCHAR(50) = NULL,
@batch_report_param	VARCHAR(5000) = NULL
AS

-------------------------Test Start------------------------------------------------
/*
DECLARE @as_of_date DATETIME = '2019-04-30',
	@var_criteria_id INT = 2,
	@term_start VARCHAR(25)= NULL,
	@term_end VARCHAR(25)= NULL,
	@whatif_criteria_id INT = NULL,
	@calc_type VARCHAR(1) = 'r',
	@tbl_name VARCHAR(200) = NULL,
	@measurement_approach INT = NULL,
	@conf_interval INT = NULL,
	@hold_period INT = NULL,
	@counterparty_id INT = NULL,
	@process_id VARCHAR(50)= NULL,
	@job_name VARCHAR(100)= NULL,
	@measure INT = 17351, --VaR
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param	VARCHAR(5000) = NULL

	DROP TABLE #tmp_term
	DROP TABLE #tmp_book
	DROP TABLE #as_of_date_point
	DROP TABLE #ranked_mtm
	DROP TABLE #tmp_err
	DROP TABLE #tmp_data
	DROP TABLE #tmp_err1
	DROP TABLE #deal_not_found
	DROP TABLE #tmp_curse
	DROP TABLE #tmp_pfe_avg
	DROP TABLE #tmp_summary_mtm
	DROP TABLE #tmp_deal
	DROP TABLE #tmp_cid
	DROP TABLE #tmp_cid_ts
	DROP TABLE #tmp_cci
--*/
--------------------------end test--------------------------------------------------------
DECLARE @st_where_book VARCHAR(1000),@source_book_mapping_id INT, @source_deal_header_id VARCHAR (5000), @curve_as_of_date DATETIME
DECLARE @st_stmt VARCHAR(8000),@st_where VARCHAR(8000),@module VARCHAR(100),@source VARCHAR(100), @type VARCHAR(100), @run_date DATETIME, @calc_for VARCHAR(100),
@total_available_date INT, @total_count INT, @source_counterparty_id VARCHAR(MAX), @call_to NCHAR(1)

SET @call_to = 'n' --o -> from old, n->from new

DECLARE @no_days_yr INT
SET @no_days_yr = 252

DECLARE @user_name VARCHAR(50)
SET @user_name = dbo.fnadbuser()
DECLARE @url VARCHAR(500)
DECLARE @desc VARCHAR(500)
DECLARE @errorMsg VARCHAR(200)
DECLARE @msg_desc VARCHAR(200)
DECLARE @errorcode VARCHAR(1)
DECLARE @warningcode VARCHAR(1) = NULL
DECLARE @url_desc VARCHAR(500),@desc1 VARCHAR(1000)
DECLARE @Monte_Carlo_Curve_Source INT
--SET @Monte_Carlo_Curve_Source = 4505
DECLARE @as_of_date_start DATETIME
SET @as_of_date_start = '1900-1-1'
DECLARE @is_warning CHAR(1) = 'n'

SET @url = ''
SET @desc = ''
SET @errorMsg = ''
SET @errorcode = 'e'
SET @url_desc = ''
SET @desc1 = ''
IF @process_id IS NULL
	SET @process_id = REPLACE(NEWID(), '-', '_')

DECLARE @st_sql VARCHAR(MAX), @mtm_process VARCHAR(100), @tenor_type CHAR(1)

DECLARE @MTMProcessTableName VARCHAR(200)
DECLARE @MTMProcessTableNameNew VARCHAR(200)
DECLARE @PFEProcessTableName VARCHAR(200)
DECLARE @PFEProcessTableNameNew VARCHAR(200)
DECLARE @tmp_deals_process_table VARCHAR(200)
DECLARE @as_of_date_point_process_table VARCHAR(200)
DECLARE @hypo_deal_detail VARCHAR(250), @hypo_deal_header VARCHAR(250), @whatif_shift VARCHAR(250) 

DECLARE @random_no VARCHAR(128)

SET @MTMProcessTableName = dbo.FNAProcessTableName('MTM_sim', @user_name, @process_id)
SET @MTMProcessTableNameNew = dbo.FNAProcessTableName('MTM_sim_new', @user_name, @process_id)
SET @PFEProcessTableName = dbo.FNAProcessTableName('PFE_sim', @user_name, @process_id)
SET @PFEProcessTableNameNew = dbo.FNAProcessTableName('PFE_sim_new', @user_name, @process_id)
SET @tmp_deals_process_table = dbo.FNAProcessTableName('tmp_deals', @user_name, @process_id)
SET @as_of_date_point_process_table = dbo.FNAProcessTableName('as_of_date_point', @user_name, @process_id)
SET @hypo_deal_detail = dbo.FNAProcessTableName('hypo_deal_detail', @user_name, @process_id)
SET @hypo_deal_header = dbo.FNAProcessTableName('hypo_deal_header', @user_name, @process_id)
SET @whatif_shift = dbo.FNAProcessTableName('whatif_shift', @user_name,@process_id)
IF OBJECT_ID(@whatif_shift) IS NULL
	EXEC('CREATE TABLE ' + @whatif_shift + '(curve_id int, curve_shift_val FLOAT, curve_shift_per FLOAT)')
		
	
IF ISNULL(@tbl_name,'') = ''
SET @tbl_name = dbo.FNAProcessTableName('std_deals', @user_name, @process_id)

SET @random_no = dbo.FNAProcessTableName('RAND', @user_name, @process_id)

EXEC('IF OBJECT_ID(''' + @MTMProcessTableName + ''') IS NOT NULL
	DROP TABLE ' + @MTMProcessTableName)

EXEC('IF OBJECT_ID(''' + @MTMProcessTableNameNew + ''') IS NOT NULL
	DROP TABLE ' + @MTMProcessTableNameNew)
	
EXEC('IF OBJECT_ID(''' + @tmp_deals_process_table + ''') IS NOT NULL
	DROP TABLE ' + @tmp_deals_process_table)
	
EXEC('IF OBJECT_ID(''' + @as_of_date_point_process_table + ''') IS NOT NULL
	DROP TABLE ' + @as_of_date_point_process_table)		
	
EXEC('if object_id(''' + @PFEProcessTableName + ''') is not null
	drop table ' + @PFEProcessTableName)
	
EXEC('if object_id(''' + @PFEProcessTableNameNew + ''') is not null
	drop table ' + @PFEProcessTableNameNew)	
	
	SET @st_sql = '
		CREATE TABLE ' + @PFEProcessTableName + '(
		[pnl_as_of_date] [datetime],
		[curve_source_value_id] [int],
		[Source_Deal_Header_ID] [int],
		[term_start] [datetime],
		[exp_type_id] [varchar](10),
		[netting_counterparty_id] [int],
		[counterparty_name] [varchar](250),
		[currency_name] [varchar](50),
		[net_exposure_to_us] [float],
		[term_end] [datetime]
		)'

	EXEC(@st_sql)

--IF OBJECT_ID(@tbl_name) IS NULL 
--BEGIN
--SET @st_sql = 'CREATE TABLE ' + @tbl_name 
--		+ '(
--			real_deal VARCHAR(1), 
--			source_deal_header_id INT, 
--			counterparty INT,
--			buy_index INT, 
--			buy_price FLOAT,
--			buy_volume FLOAT,
--			buy_UOM INT, 
--			buy_term_start DATETIME,
--			buy_term_end DATETIME,
--			sell_index INT, 
--			sell_price FLOAT,
--			sell_volume FLOAT,
--			sell_UOM INT, 
--			sell_term_start DATETIME,
--			sell_term_end DATETIME
--			)'

--	EXEC(@st_sql)
--END

BEGIN TRY

-- var Criteria
	DECLARE @name VARCHAR(200),
		@category  INT ,
		@source_system_book_id1  INT ,
		@source_system_book_id2  INT ,
		@source_system_book_id3  INT ,
		@source_system_book_id4  INT ,
		@trader  INT ,
		@include_options_delta  VARCHAR(1) ,
		@include_options_notional  VARCHAR(1) ,
		@market_credit_correlation  FLOAT ,
		@var_approach  INT ,
		@start_date  DATETIME ,
		@simulation_days  INT ,
		@confidence_interval  INT ,
		@holding_period  INT ,
		@price_curve_source  INT ,
		@daily_return_data_series  INT ,
		@data_points  INT ,
		@active  VARCHAR(1) ,
		@vol_cor  VARCHAR(1),
		@fas_book_id VARCHAR(500),
		@calc_vol_cor VARCHAR(1),
		@calc_price_curve  VARCHAR(1),
		--to store shift value of whatif analysis	
		@shift_val FLOAT = 0,
		@shift_by CHAR(1) = 'v',
		@hold_to_maturity CHAR(1) = 'N',
		--@measure INT = 17351  --ie. 17351=>VaR, 17353=>EaR, 17352=> CFaR
		@tenor_from VARCHAR(10) = NULL, 
		@tenor_to VARCHAR(10) = NULL,
		@use_dis_val CHAR(1) = NULL,
		@revaluation CHAR(1) = NULL
		
	SET @calc_type = ISNULL(@calc_type, 'm')
	
	--Storing criteria name by using @calc_type and @criteria_id
	DECLARE @criteria_name AS VARCHAR(200)
	IF @calc_type ='w' 
	SELECT  @criteria_name = criteria_name FROM maintain_whatif_criteria WHERE criteria_id = @whatif_criteria_id
	ELSE
	SELECT  @criteria_name = name FROM var_measurement_criteria_detail WHERE id = @var_criteria_id
	
	
	IF @calc_type = 'w'
	BEGIN
		IF @whatif_criteria_id IS NOT NULL
	    BEGIN
	    	SELECT
	    		@name = criteria_name, 
	    		@price_curve_source = ISNULL(ISNULL(mwc.source, msg.source), 4500),
	    		@simulation_days = isnull(wcm.no_of_simulations, 1),
	    		@confidence_interval = @conf_interval,
	    		@holding_period = @hold_period,
	    		@var_approach = @measurement_approach,
	    		@tenor_type = CASE WHEN pmt.fixed_term = 1 THEN 'f' WHEN pmt.relative_term = 1 THEN 'r' ELSE 'f' END,
	    		@tenor_from = pmt.starting_month,
	    		@tenor_to = pmt.no_of_month,
	    		@hold_to_maturity = ISNULL(hold_to_maturity, 'N'),
	    		@term_start = pmt.term_start,
	    		@term_end = pmt.term_end,
	    		@use_dis_val = ISNULL(mwc.use_discounted_value, 'n'),
				@revaluation = ISNULL(mwc.revaluation, 'n')
	    	FROM maintain_whatif_criteria mwc
	    	INNER JOIN whatif_criteria_measure wcm ON mwc.criteria_id = wcm.criteria_id
			LEFT JOIN whatif_criteria_scenario wcs ON mwc.criteria_id = wcs.criteria_id
			LEFT JOIN maintain_scenario_group msg ON mwc.scenario_group_id = msg.scenario_group_id
			LEFT JOIN portfolio_mapping_source pms ON pms.mapping_source_usage_id = mwc.criteria_id
				AND pms.mapping_source_value_id = 23201
			LEFT JOIN portfolio_mapping_tenor pmt ON pmt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id 
			WHERE mwc.criteria_id = @whatif_criteria_id	
	    END		
	END
	ELSE
	BEGIN
		IF @var_criteria_id IS NOT NULL
		BEGIN
			SELECT 
				@name = [name]
				,@category = category
				,@trader = trader
				,@include_options_delta = include_options_delta
				,@include_options_notional = include_options_notional
				,@market_credit_correlation = market_credit_correlation
				,@var_approach = var_approach
				,@simulation_days = simulation_days
				,@confidence_interval = confidence_interval
				,@holding_period = ISNULL(holding_period, 1)
				,@price_curve_source = price_curve_source
				,@daily_return_data_series = daily_return_data_series
				,@active = active
				,@vol_cor = vol_cor
				,@measure = measure
	    		,@tenor_type = CASE WHEN pmt.fixed_term = 1 THEN 'f' WHEN pmt.relative_term = 1 THEN 'r' ELSE 'f' END
	    		,@tenor_from = pmt.starting_month
	    		,@tenor_to = pmt.no_of_month
	    		,@hold_to_maturity = ISNULL(hold_to_maturity, 'N')
	    		,@term_start = pmt.term_start
	    		,@term_end = pmt.term_end
	    		,@use_dis_val = ISNULL(vmcd.use_discounted_value, 'n')
			FROM [dbo].[var_measurement_criteria_detail] vmcd
			LEFT JOIN portfolio_mapping_source pms ON pms.mapping_source_usage_id = vmcd.id
				AND pms.mapping_source_value_id = 23203
			LEFT JOIN portfolio_mapping_tenor pmt ON pmt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
			WHERE id = @var_criteria_id
		END
	END	

	SET @Monte_Carlo_Curve_Source = CASE WHEN @var_approach = 1521 THEN 10639 ELSE 4505 END

	-- setting term_start, term_end (priority 1: fixed tenor, priority 2: relative tenor) and relative tenor conversion on reference with as of date
	SET @term_start = dbo.FNAGetContractMonth(ISNULL(@term_start, DATEADD (MONTH, CAST(@tenor_from AS INT), @as_of_date)))
	SET @term_end = dbo.FNALastDayInDate(ISNULL(@term_end, DATEADD (MONTH, CAST(@tenor_to AS INT), @as_of_date)))
		
	--Collecting All deals from different sources	
	DECLARE @str_and VARCHAR(100)
	DECLARE @str_union VARCHAR(200)

	DECLARE @st_hypo VARCHAR(2000) --to address hypothetical deals in #tmp_term
	SET @str_and = ''
	SET @str_union = ''
	
	CREATE TABLE #as_of_date_point(Row_id SMALLINT IDENTITY(1, 1), as_of_date DATETIME)
	
	--Storing mesage based on measure to be used in validation
	IF @measure = 17352
	BEGIN
		SET @source = 'CFaR Simulation Calculation'
		SET @module = 'CFaR Simulation Calculation'
		SET @msg_desc = 'CFaR Simulation Calculation'
		SET @type = 'CFaR simulation'
		SET @calc_for = 'CFaR'
	END
	ELSE IF @measure = 17353
	BEGIN
		SET @source = 'EaR Simulation Calculation'
		SET @module = 'EaR Simulation Calculation'
		SET @msg_desc = 'EaR Simulation Calculation'
		SET @type = 'EaR simulation'
		SET @calc_for = 'EaR'
	END		
	ELSE IF @measure = 17355
	BEGIN
		SET @source = 'PFE Simulation Calculation'
		SET @module = 'PFE Simulation Calculation'
		SET @msg_desc = 'PFE Simulation Calculation'
		SET @type = 'PFE simulation'
		SET @calc_for = 'PFE'
	END	
	ELSE IF @measure = 17351
	BEGIN
		SET @source = 'VaR Simulation Calculation'
		SET @module = 'VaR Simulation Calculation'
		SET @msg_desc = 'VaR Simulation Calculation'
		SET @type = 'VAR simulation'
		SET @calc_for = 'VaR'
	END	
	ELSE IF @measure = 17357
	BEGIN
		SET @source = 'GMaR Simulation Calculation'
		SET @module = 'GMaR Simulation Calculation'
		SET @msg_desc = 'GMaR Simulation Calculation'
		SET @type = 'GMaR simulation'
		SET @calc_for = 'GMaR'
	END
		
	CREATE TABLE #tmp_curse(
		as_of_date DATETIME,
		und_pnl FLOAT,
		counterparty_id INT	
		)
		
	IF @calc_type <> 'w'
	BEGIN
		--IF @trader IS NOT NULL
		--	SET @str_and = @str_and + 'AND sdh.trader_id = ''' + CAST(@trader AS VARCHAR) + ''''
			
		--IF NOT EXISTS(SELECT * FROM var_measurement_criteria WHERE var_criteria_id = @var_criteria_id) AND @trader IS NOT NULL
		--	SET @str_union = 
		--		@str_union + 'UNION ALL
		--			SELECT DISTINCT source_deal_header_id deal_id,''y'' FROM source_deal_header 
		--			WHERE trader_id = ''' + CAST(@trader AS VARCHAR) + ''''
			                                       	
		--SET @st_sql = '
		--	INSERT INTO ' + @tbl_name + '([source_deal_header_id],real_deal)
		--	SELECT DISTINCT sdh.source_deal_header_id deal_id, ''y'' 
		--	FROM dbo.source_system_book_map ssbm 
		--	INNER JOIN var_measurement_criteria vmc ON ssbm.fas_book_id = vmc.book_id 
		--		AND vmc.var_criteria_id = ''' + CAST(@var_criteria_id AS VARCHAR) + '''
		--	INNER JOIN source_deal_header sdh ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
		--		AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
		--		AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
		--		AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		--		' + @str_and + '
		--	UNION
		--	SELECT DISTINCT 
		--		deal_id, ''y'' 
		--	FROM dbo.var_measurement_deal 
		--	WHERE var_criteria_id = ''' + CAST(@var_criteria_id AS VARCHAR) + '''
		--	' + @str_union + ''
			
		--exec spa_print @st_sql
		--EXEC (@st_sql)
		
		EXEC spa_collect_mapping_deals @as_of_date, 23203, @var_criteria_id, @tbl_name
		
		IF OBJECT_ID(@tbl_name) IS NOT NULL
			EXEC ('ALTER TABLE ' + @tbl_name + ' ADD counterparty INT')
		
	END

	--Added logic, not to process the deals those position is 0 or not available
	EXEC('DELETE td
    FROM ' + @tbl_name + ' td
    OUTER APPLY (SELECT DISTINCT source_deal_header_id FROM source_deal_detail WHERE source_deal_header_id =  td.source_deal_header_id AND NULLIF(total_volume, 0) IS NOT NULL) sdd
    --INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = td.source_deal_header_id
    --AND NULLIF(sdd.total_volume, 0) IS NULL
    WHERE sdd.source_deal_header_id IS NULL'
    )

	--Storing deal ids from process table to temporary table to execute dynamic query below
	CREATE TABLE #tmp_deal(deal_id INT, counterparty_id INT) 
	SET @st_stmt = 'INSERT INTO #tmp_deal(deal_id, counterparty_id) SELECT source_deal_header_id, counterparty FROM ' + @tbl_name
	exec spa_print @st_stmt
	EXEC(@st_stmt)
		
	--###############################--
		--@measure <> 17355 --PFE--
	--###############################--	
	DECLARE @hyperlinktext_function_id VARCHAR(10), @hyperlinktext_label VARCHAR(50), @hyperlinktext_arg VARCHAR(10), @hyperlink VARCHAR(500)
	SET @hyperlinktext_function_id = CASE @calc_type WHEN 'w' THEN '10183400' ELSE '10181200' END
	SET @hyperlinktext_label = CASE @calc_type WHEN 'w' THEN @criteria_name ELSE @name END
	SET @hyperlinktext_arg = CASE @calc_type WHEN 'w' THEN @whatif_criteria_id ELSE @var_criteria_id END
	SET @hyperlink = @hyperlinktext_label --dbo.FNATRMWinHyperlink('a', @hyperlinktext_function_id, @hyperlinktext_label, @hyperlinktext_arg,null,null,null,null,null,null,null,null,null,null,null,0)
	
	
	IF @measure <> 17355 --PFE
	BEGIN
		IF (NOT EXISTS(SELECT TOP 1 deal_id FROM #tmp_deal) AND (@calc_type <> 'w')) 
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT  @process_id, 'Error', @module, @source, 'no_rec', 'The deals are not found for '
			+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink + ';'
			END + ' As of Date:' + convert(varchar(10),@as_of_date,120) + '; Criteria:' + ISNULL(@name, '') + '.','Please check data.'
			
			RAISERROR ('CatchError', 16, 1)
		END

		SET @start_date = @as_of_date + 1
		IF @confidence_interval IS NULL
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT @process_id,'Error', 'VAR Calculation', 'VAR Calculation', 'confidence_interval', 'Confidence interval is not found ' + 
			CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink + ';' END + ' 
			for Criteria ID:' + CAST(@hyperlinktext_arg AS VARCHAR) + '; Name:'+ @hyperlinktext_label + '.' , 'Please check data.'
			
			RAISERROR ('CatchError', 16, 1)
		END

		IF @var_approach IS NULL
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT @process_id, 'Error', 'VAR Calculation', 'VAR Calculation', 'var_approach', 'VaR approach is not defined for ' + 
			CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink  END + '.' , 
			'Please check data.'
			
			RAISERROR ('CatchError', 16, 1)
		END
		
		SET @holding_period = ISNULL(@holding_period, DATEDIFF(DAY, @start_date, @as_of_date))
		SET @st_where_book = ''
	    
		CREATE TABLE #tmp_term(
			map_months INT,
			term_start DATETIME,
			map_term_start DATETIME,
			curve_id INT,
			debt_rating INT,
			MTM FLOAT,
			MTMC FLOAT,
			MTMI FLOAT,
			source_deal_header_id INT,
			deal_id VARCHAR(400) COLLATE DATABASE_DEFAULT ,
			counterparty_id INT,
			und_pnl_set FLOAT,
			leg INT
		)
		
		SET @price_curve_source = ISNULL(@price_curve_source, 4500)
		SET @st_where = ''
		SET @st_hypo = ''

		IF @term_start IS NOT NULL 
			SET @st_where = @st_where + ' AND sdd.term_start >= '''	+ @term_start + ''''
		IF @term_end IS NOT NULL 
			SET @st_where = @st_where + ' AND sdd.term_end <= ''' + @term_end + ''''
		
		IF OBJECT_ID('tempdb..#pt_temp1') IS NOT NULL
		 DROP TABLE #pt_temp1
		SELECT counterparty_id,max(debt_rating) debt_rating into #pt_temp1 FROM counterparty_credit_info GROUP BY counterparty_id
		create index ix_pt_temp_1 on #pt_temp1(counterparty_id, debt_rating)

		SET @st_hypo = @st_hypo + '
			UNION ALL
				SELECT sdpdw.term_start, sdpdw.term_start map_term_start, sdpdw.curve_id curve_id,
					scp.debt_rating, 
					' + CASE WHEN @use_dis_val = 'y' THEN ' sdpdw.dis_pnl' ELSE ' sdpdw.und_pnl' END + ' AS MTM, 
					CAST(wif.source_deal_header_id AS VARCHAR) source_deal_header_id,
					''Hypothetical '' + CAST(wif.source_deal_header_id AS VARCHAR) deal_id, wif.counterparty, sdpdw.und_pnl_set, sdpdw.leg
				FROM source_deal_pnl_detail_whatif sdpdw 
				INNER JOIN ' + @tbl_name + ' wif ON sdpdw.source_deal_header_id = wif.source_deal_header_id
					AND wif.real_deal = ''n''
				LEFT JOIN #pt_temp1 scp ON wif.counterparty = scp.counterparty_id
				WHERE sdpdw.pnl_source_value_id = 4500 
					AND sdpdw.criteria_id= ' + CAST(@whatif_criteria_id AS VARCHAR) + '
					AND pnl_as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''	
			
		SET @st_stmt = '
			INSERT INTO #tmp_term (term_start, map_term_start, curve_id, debt_rating, MTM, source_deal_header_id, deal_id, counterparty_id, und_pnl_set, leg)
			SELECT DISTINCT
				CASE WHEN sdh.term_frequency = ''m'' THEN
					CONVERT(VARCHAR(7), sdd.term_start, 120) + ''-01''
				ELSE						
					sdd.term_start
				END	 
			   term_start,
			   sdd.term_start map_term_start,
			   ISNULL(spcd.risk_bucket_id, spcd.source_curve_def_id) curve_id,
			   scp.debt_rating, 
			   ' + CASE WHEN @use_dis_val = 'y' THEN ' sdpd.dis_pnl' ELSE ' sdpd.und_pnl' END + ' AS MTM,
			   sdh.source_deal_header_id, 
			   sdh.deal_id, 
			   sdh.counterparty_id,
			   sdpd.und_pnl_set und_pnl_set,
			   sdpd.leg
			FROM source_deal_header sdh'
			+ CASE WHEN ISNULL(@calc_type, 'r') = 'w' THEN ' 
			INNER JOIN ' + @tbl_name + ' wif ON sdh.source_deal_header_id = wif.source_deal_header_id AND real_deal = ''y'''
			ELSE ' 
			INNER JOIN ' + @tbl_name + ' sdt ON sdt.source_deal_header_id = sdh.source_deal_header_id'  END + ' 	
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
				AND sdh.deal_date <= ''' + CAST(@as_of_date AS VARCHAR)+ '''
				AND sdd.contract_expiration_date > ''' + CAST(@as_of_date AS VARCHAR)	+ '''
				AND sdd.term_start >= 
					CASE WHEN sdh.term_frequency = ''m'' THEN
						''' + CONVERT(VARCHAR(7), @as_of_date, 120) + '-01' + '''
					ELSE						
						''' + CAST(@as_of_date AS VARCHAR)+ '''
					END
				--AND dbo.FNALastDayInMonth(sdd.term_start) <> DATEPART(DAY, ''' + CAST(@as_of_date AS VARCHAR)+ ''') 		
				AND sdd.term_end > ''' + CAST(@as_of_date AS VARCHAR)+ '''	
				AND sdd.curve_id IS NOT NULL ' + @st_where + '
			INNER JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id
			LEFT JOIN source_deal_pnl_detail' + CASE WHEN ISNULL(@calc_type, 'r') = 'w' THEN '_whatif'  ELSE ''  END + ' sdpd ON sdd.source_deal_header_id = sdpd.source_deal_header_id 
				AND sdd.term_start = sdpd.term_start 
				AND sdd.term_end = sdpd.term_end 
				AND sdd.leg = sdpd.leg
				AND pnl_as_of_date = ''' + CAST(@as_of_date AS VARCHAR)	+ '''
				AND sdpd.pnl_source_value_id = 4500 ' +
				CASE WHEN ISNULL(@calc_type, 'r') = 'w' THEN ' 
				AND sdpd.criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) ELSE '' END + '
			LEFT JOIN #pt_temp1 scp ON sdh.counterparty_id = scp.counterparty_id
			LEFT JOIN source_price_curve_def risk_spcd ON spcd.risk_bucket_id = risk_spcd.source_curve_def_id 
				AND spcd.risk_bucket_id IS NOT NULL'
			+ CASE WHEN ISNULL(@calc_type, 'r') = 'w' THEN @st_hypo ELSE '' END	 		 
				
		EXEC spa_print @st_stmt
		EXEC (@st_stmt)

		IF NOT EXISTS(SELECT TOP 1 1 FROM #tmp_term) 
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT  @process_id, 'Error', @module, @source, 'MTM_Value', 'MTM Value is not found for '
				+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink+ ';'
				END + ' As of Date:' + convert(varchar(10),@as_of_date,120)+ '; Deal ID:' + CAST(deal_id AS VARCHAR) + '.','Please check data.' 
			FROM #tmp_deal
			 
			RAISERROR ('CatchError', 16, 1)
		END
		
		IF EXISTS(SELECT TOP 1 deal_id FROM #tmp_term WHERE MTM IS NULL) 
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT  @process_id, 'Error', @module, @source, 'MTM_Value', 'MTM Value is not found for '
				+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink+ ';'
				END + ' As of Date:' + convert(varchar(10),@as_of_date,120)+ '; Deal ID:' + deal_id+ '; Term_Start: ' + convert(varchar(10),term_start,120) + '.',
				'Please check data.' 
			FROM #tmp_term 
			WHERE MTM IS NULL
			ORDER BY deal_id
			
			RAISERROR ('CatchError', 16, 1)
		END
		
		IF EXISTS(SELECT TOP 1 deal_id FROM #tmp_term WHERE counterparty_id IS NULL) 
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT  @process_id, 'Error', @module, @source, 'Counterparty', 'Counterparty is not found for '
				+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink + ';'
				END + ' Deal ID:' + deal_id + '.', 'Please check data.'
			FROM #tmp_term
			WHERE counterparty_id IS NULL
			
			RAISERROR ('CatchError', 16, 1)
		END

		IF EXISTS(SELECT TOP 1 deal_id FROM #tmp_term WHERE debt_rating IS NULL) 
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT DISTINCT @process_id,'Warning',@module,@source,'Debt_Rating','Debt Rating is not found for '
				+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: '+ @hyperlink+ ';'
				END + ' Counterparty: ' + sc.counterparty_id + '.', 'Please check data.'
			FROM #tmp_term tt
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = tt.counterparty_id
			WHERE debt_rating IS NULL
			
			SET @warningcode = 'e'
			--RAISERROR ('CatchError', 16, 1)
		END

		UPDATE  #tmp_term SET map_months = dbo.FNAGetMapMonthNo(curve_id, term_start,@as_of_date)
		UPDATE  #tmp_term SET  MTMC = MTM * dbo.FNAGetProbabilityDefault(debt_rating, map_months, @as_of_date)
				* ( 1 - dbo.FNAGetRecoveryRate(debt_rating, map_months, @as_of_date)),
				MTMI = MTM * (1 + dbo.FNAGetProbabilityDefault(debt_rating, map_months, @as_of_date))

		IF EXISTS(SELECT TOP 1 deal_id FROM #tmp_term WHERE mtmc IS NULL) 
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT DISTINCT @process_id,'Warning',@module,@source,'Default_Recovery','Default Probability/Recoverary Rate is not found '
				+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: '+ @hyperlink+ ';'
				END + ' for Rating:' + s.code+ '; As of Date:'+ convert(varchar(10),@as_of_date,120)+ '; No of Month(s):'
				+ CAST(map_months AS VARCHAR)+ '; Deal ID:' + deal_id + '.','Please check data.'
			FROM #tmp_term t 
			INNER JOIN static_data_value s ON t.debt_rating = s.value_id 
			WHERE mtmc IS NULL

			SET @warningcode = 'e'
					
			--RAISERROR ('CatchError', 16, 1)
		END
	        
		IF EXISTS(SELECT TOP 1 deal_id FROM #tmp_term WHERE mtmi IS NULL) 
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT DISTINCT @process_id, 'Warning', @module, @source, 'Probability', 'Default Probability is not found '
				+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink+ ';'
				END + ' for Rating:' + s.code + '; As of Date:' + convert(varchar(10),@as_of_date,120) + '; Deal ID:' + deal_id + '.', 
				'Please check data.'
			FROM #tmp_term t 
			JOIN static_data_value s ON t.debt_rating = s.value_id WHERE mtmi IS NULL

			SET @warningcode = 'e'
			--RAISERROR ('CatchError', 16, 1)
		END
		
		--SET @data_points = ISNULL(@data_points, 30)
		--IF EXISTS(SELECT TOP 1 1 FROM #tmp_term WHERE source_deal_header_id < 0)
		--	SET @call_to = 'o'
		--Most Recent available date to retrieve simulation data
			IF @call_to = 'o'
				SELECT TOP 1 
					@run_date = run_date,
					@total_available_date = COUNT(DISTINCT(pnl_as_of_date))
				FROM var_simulation_data 
				WHERE run_date <= CAST(@as_of_date AS VARCHAR)
				GROUP BY run_date 
				ORDER BY run_date DESC
			ELSE
				IF @revaluation = 'y'
					SELECT TOP 1 
						@run_date = run_date,
						@total_available_date = COUNT(DISTINCT(as_of_date))
					FROM source_deal_delta_value_whatif 
					WHERE run_date <= CAST(@as_of_date AS VARCHAR)
						AND criteria_id = @whatif_criteria_id
						AND pnl_source_value_id = @Monte_Carlo_Curve_Source
					GROUP BY run_date 
					ORDER BY run_date DESC
				ELSE
					SELECT TOP 1 
						@run_date = run_date,
						@total_available_date = COUNT(DISTINCT(as_of_date))
					FROM source_deal_delta_value 
					WHERE run_date <= CAST(@as_of_date AS VARCHAR)
					AND pnl_source_value_id = @Monte_Carlo_Curve_Source
					GROUP BY run_date
					ORDER BY run_date DESC
					
			
			SET @run_date = ISNULL(@run_date, @as_of_date)
			SET @total_available_date = ISNULL(@total_available_date, 0)
		
		IF  @var_approach IN (1521, 1522) --Monte Carlo Simulation
		BEGIN
			---------------------------------------------------------------------
			--generating price curve and saving it in source_price_curve
			-----------------------------------------------------------------------
			SELECT DISTINCT curve_id INTO #tmp_cid FROM  #tmp_term
			SELECT DISTINCT curve_id,term_start INTO #tmp_cid_ts FROM  #tmp_term
			CREATE INDEX ix_pt_tmp_cid ON #tmp_cid (curve_id)
			CREATE INDEX ix_pt_tmp_cid_ts ON #tmp_cid_ts (curve_id,term_start)
			
			
			IF @calc_price_curve = 'y'
			BEGIN
				EXEC spa_print 'generating price curve and saving it in source_price_curve'

				DECLARE @c_ids VARCHAR(1000)
				
				SELECT @c_ids = ISNULL(','+@c_ids,'') + CAST(curve_id AS VARCHAR) FROM #tmp_cid a
				
				SELECT @term_start = MIN(term_start), @term_end=MAX(term_start)  FROM #tmp_term
				
				 EXEC dbo.spa_monte_carlo_simulation  
					@as_of_date, 
					@term_start, 
					@term_end, 
					@simulation_days,
					NULL,
					@c_ids,
					'n',
					NULL,
					@process_id 
			END
			
			IF @call_to = 'o'	
				SET @st_sql = '
					INSERT INTO #as_of_date_point 
					SELECT DISTINCT TOP ' + CAST(@simulation_days AS VARCHAR) + ' vsd.pnl_as_of_date as_of_date 
					FROM #tmp_term mtm
					INNER JOIN var_simulation_data vsd ON mtm.source_deal_header_id = vsd.source_deal_header_id   
						AND mtm.term_start = vsd.term_start
						AND vsd.pnl.as_of_date IS NOT NULL
						AND vsd.pnl_as_of_date >= ''' + CAST(@as_of_date_start AS VARCHAR) + '''
						AND vsd.pnl_as_of_date <> ''' + CAST(@run_date AS VARCHAR) + '''
						AND vsd.pnl_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND vsd.run_date = ''' + CAST(@run_date AS VARCHAR) + '''
					ORDER BY vsd.pnl_as_of_date
					'
			ELSE
			BEGIN
				SET @st_sql = '
					INSERT INTO #as_of_date_point 
					SELECT DISTINCT TOP ' + CAST(@simulation_days AS VARCHAR) + ' vsd.as_of_date as_of_date 
					FROM #tmp_term mtm
					INNER JOIN source_deal_delta_value' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + ' vsd ON mtm.source_deal_header_id = vsd.source_deal_header_id   
						AND mtm.term_start = vsd.term_start
						AND vsd.as_of_date IS NOT NULL
						AND vsd.as_of_date >= ''' + CAST(@as_of_date_start AS VARCHAR) + '''
						AND vsd.as_of_date <> ''' + CAST(@run_date AS VARCHAR) + '''
						AND vsd.pnl_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND vsd.run_date = ''' + CAST(@run_date AS VARCHAR) + '''' +
						CASE WHEN @revaluation = 'y' THEN ' AND vsd.criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END + '
					ORDER BY vsd.as_of_date
					'	
						
				exec spa_print @st_sql
				EXEC(@st_sql)

				IF NOT EXISTS(SELECT TOP 1 1 FROM #as_of_date_point) AND EXISTS(SELECT TOP 1 1 FROM #tmp_term WHERE source_deal_header_id < 0)
				WITH user_rec(as_of_date, cnt)AS
				(
					SELECT CAST(@as_of_date_start AS DATE) , 0 AS cnt
					UNION ALL 
					SELECT DATEADD(DAY, (cnt+1), CAST(@as_of_date_start AS DATE)), cnt + 1 FROM user_rec r 
					WHERE cnt + 1 < @simulation_days --no of simulations
				)
				INSERT INTO #as_of_date_point (as_of_date)
				SELECT as_of_date FROM user_rec
				OPTION (MAXRECURSION 0)
			END
		END
				--------------------------------------------
		-------------------------------------------------------------
		ELSE  ---Historical Simulation
		BEGIN
			
			CREATE TABLE #tmp_err
			(
			  curve_id INT,
			  term_start DATETIME,
			  curve_source_value_id INT
			)
	        
			 SET @st_stmt = '
				INSERT INTO #tmp_err (curve_id,term_start,curve_source_value_id)
				SELECT t.curve_id, t.term_start, ' + CAST(@price_curve_source AS VARCHAR) + '   
				FROM #tmp_cid_ts t 
				LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = t.curve_id
				LEFT JOIN source_price_curve_def spcd1 ON spcd.proxy_source_curve_def_id = spcd1.source_curve_def_id	
				LEFT JOIN source_price_curve_def spcd2 ON spcd.monthly_index = spcd2.source_curve_def_id
				LEFT JOIN source_price_curve_def spcd3 ON spcd.proxy_curve_id3 = spcd3.source_curve_def_id
				LEFT JOIN source_price_curve spc ON spcd.source_curve_def_id = spc.source_curve_def_id   
					AND t.term_start=spc.maturity_date
					AND spc.as_of_date ' + CASE WHEN  @var_approach IN (1521, 1522) THEN ' = ''' ELSE ' <= ''' END + CAST(@as_of_date AS VARCHAR) + '''
					AND spc.curve_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + '
				LEFT JOIN source_price_curve spc1 ON spcd1.source_curve_def_id = spc1.source_curve_def_id
					AND t.term_start = spc1.maturity_date
					AND spc1.as_of_date ' + CASE WHEN  @var_approach IN (1521, 1522) THEN ' = ''' ELSE ' <= ''' END + CAST(@as_of_date AS VARCHAR) + '''
					AND spc1.curve_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + '
				LEFT JOIN source_price_curve spc2 ON spcd2.source_curve_def_id = spc2.source_curve_def_id
					AND t.term_start = spc2.maturity_date
					AND spc2.as_of_date ' + CASE WHEN  @var_approach IN (1521, 1522) THEN ' = ''' ELSE ' <= ''' END + CAST(@as_of_date AS VARCHAR) + '''
					AND spc2.curve_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + '
				LEFT JOIN source_price_curve spc3 ON spcd3.source_curve_def_id = spc3.source_curve_def_id
					AND t.term_start = spc3.maturity_date
					AND spc3.as_of_date ' + CASE WHEN  @var_approach IN (1521, 1522) THEN ' = ''' ELSE ' <= ''' END + CAST(@as_of_date AS VARCHAR) + '''
					AND spc3.curve_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + '	
				 WHERE COALESCE (spc.curve_source_value_id, spc1.curve_source_value_id, spc2.curve_source_value_id, spc3.curve_source_value_id) IS NULL
				 '
		    
			exec spa_print @st_stmt   
			EXEC(@st_stmt)

			IF EXISTS(SELECT TOP 1 curve_id FROM #tmp_err) 
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
				SELECT DISTINCT @process_id,'Error',@module,@source,'Price_Curve_Maturity_Date','Price Curve is not found for '
					+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink+ ';'
					END + ' As of Date:'+ convert(varchar(10),@as_of_date,120)+ '; Curve_ID:'+ spcd.curve_id+ '; Maturity Date: '
					+ convert(varchar(10),term_start,120)+ '; Curve Price Source:'+ s.code + '.','Please check data.'
				FROM #tmp_err t
				INNER JOIN source_price_curve_def spcd ON t.curve_id = spcd.source_curve_def_id
				INNER JOIN static_data_value s ON s.value_id = t.curve_source_value_id
				
				RAISERROR ('CatchError', 16, 1)
			END
		
			SET @st_sql = '
				INSERT INTO #as_of_date_point select * FROM (
				SELECT TOP ' + CAST(@simulation_days AS VARCHAR) + ' as_of_date FROM (
					SELECT DISTINCT COALESCE(spc.as_of_date, spc1.as_of_date, spc2.as_of_date, spc3.as_of_date) as_of_date 
					FROM #tmp_cid_ts mtm
					LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = mtm.curve_id
					LEFT JOIN source_price_curve_def spcd1 ON spcd.proxy_source_curve_def_id=spcd1.source_curve_def_id	
					LEFT JOIN source_price_curve_def spcd2 ON spcd.monthly_index=spcd2.source_curve_def_id
					LEFT JOIN source_price_curve_def spcd3 ON spcd.proxy_curve_id3=spcd3.source_curve_def_id
					LEFT JOIN source_price_curve spc ON spcd.source_curve_def_id = spc.source_curve_def_id   
						AND mtm.term_start=spc.maturity_date
						AND spc.as_of_date < ''' + CAST(@as_of_date AS VARCHAR) + ''' 
						AND spc.curve_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + '
					LEFT JOIN source_price_curve spc1 ON spcd1.source_curve_def_id=spc1.source_curve_def_id
						AND mtm.term_start=spc1.maturity_date
						AND spc1.as_of_date < ''' + CAST(@as_of_date AS VARCHAR) + ''' 
						AND spc1.curve_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + '
					LEFT JOIN source_price_curve spc2 ON spcd2.source_curve_def_id=spc2.source_curve_def_id
						AND mtm.term_start=spc2.maturity_date
						AND spc2.as_of_date < ''' + CAST(@as_of_date AS VARCHAR) + ''' 
						AND spc2.curve_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + '
					LEFT JOIN source_price_curve spc3 ON spcd3.source_curve_def_id=spc3.source_curve_def_id
						AND mtm.term_start=spc3.maturity_date
						AND spc3.as_of_date < ''' + CAST(@as_of_date AS VARCHAR) + ''' 
						AND spc3.curve_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + '
					GROUP BY COALESCE(spc.as_of_date, spc1.as_of_date, spc2.as_of_date, spc3.as_of_date)
					HAVING count(distinct(mtm.curve_id)) = (SELECT COUNT(*) total FROM #tmp_cid)
				) a ORDER BY a.as_of_date desc
			 ) b ORDER BY b.as_of_date'
				 
			exec spa_print @st_sql
			EXEC(@st_sql)
			
			CREATE TABLE #tmp_data(curve_id INT, term_start DATETIME, as_of_date DATETIME)

			INSERT INTO #tmp_data (curve_id, term_start, as_of_date)
			SELECT curve_id,term_start,as_of_date 
			FROM 
				#tmp_cid_ts t
				 CROSS JOIN #as_of_date_point

			
			CREATE TABLE #tmp_err1(curve_id INT, term_start DATETIME, as_of_date DATETIME)	
			SET @st_sql = '
			SELECT  d.curve_id,
					d.term_start,
					d.as_of_date
			INTO    #tmp_err1
			FROM    #tmp_data d ' +
			CASE WHEN @var_approach IN (1521, 1522) THEN
			'LEFT JOIN source_price_curve_simulation spcs ON spcs.source_curve_def_id = d.curve_id
				AND d.term_start = spcs.maturity_date
				AND d.as_of_date = spcs.as_of_date
			WHERE spc.source_curve_def_id IS NULL'
			ELSE
			'LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = d.curve_id
				AND d.term_start = spc.maturity_date
				AND d.as_of_date = spc.as_of_date
			WHERE spc.source_curve_def_id IS NULL'
			END
			
			IF EXISTS(SELECT TOP 1 1 FROM #tmp_err1) 
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
				SELECT DISTINCT
					@process_id,'Error',@module,@source,'Price_Curve_Risk_As_of_Date','Price Curve value is not found '
					+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: '+ @hyperlink+ ';'
						END + ' for As of Date:'+ convert(varchar(10),as_of_date,120)+ '; Curve_ID:' + spcd.curve_id+ '; Maturity Date: '
					+ convert(varchar(10),term_start,120) + '.','Please check data.'
				FROM    #tmp_err1 t
				INNER JOIN source_price_curve_def spcd ON t.curve_id = spcd.source_curve_def_id
				
				RAISERROR ('CatchError', 16, 1)
		   END
			
		END
	
		IF NOT EXISTS (SELECT TOP 1 1 FROM #as_of_date_point) OR EXISTS (SELECT TOP 1 1 FROM #as_of_date_point WHERE as_of_date IS NULL) 
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			VALUES  (
				@process_id,'Error',@module,@source,'Simulated Data','Simulated data is not found for '
				+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: '+ @hyperlink+ ';'
				END + ' As of Date:'+ convert(varchar(10),@as_of_date,120) + '.','Please check data.'
			)
		
		RAISERROR ('CatchError', 16, 1)
		END
	
	--begin tran
		EXEC('SELECT DISTINCT source_deal_header_id, ''y'' real_deal, leg INTO ' + @tmp_deals_process_table + ' FROM #tmp_term')
		EXEC('SELECT as_of_date INTO ' + @as_of_date_point_process_table + ' FROM #as_of_date_point')
	
	exec spa_print 'MTM Calculation for each historical simulation as_of_date'
-------------------------------------------------------------------------------------------------------
----------MTM Calculation for each historical simulation as_of_date
-------------------------------------------------------------------------------------------------------
	SELECT @source_book_mapping_id = book_deal_type_map_id 
	FROM 
		dbo.source_system_book_map
	WHERE 1 = 1
		AND source_system_book_id1 = @source_system_book_id1 
		AND source_system_book_id2 = @source_system_book_id2 
		AND source_system_book_id3 = @source_system_book_id3 
		AND source_system_book_id4 = @source_system_book_id4 
	
	SET @source_deal_header_id = ''
	SELECT @source_deal_header_id = @source_deal_header_id + CAST([deal_id] AS VARCHAR) + ',' FROM #tmp_deal
	IF @source_deal_header_id = ''
		SET @source_deal_header_id = NULL
	ELSE
		SET  @source_deal_header_id = LEFT(@source_deal_header_id, LEN(@source_deal_header_id) - 1)

		--############################################--
				----Monte Carlo Simulation--
		--############################################--		
		IF @var_approach IN (1521, 1522)
		BEGIN
			IF @calc_type = 'w'
			BEGIN
				--Deleting simulation of hypothetical deals
				SET @st_sql = '
				DELETE vsd 
				FROM ' + CASE WHEN @call_to = 'o' THEN 'var_simulation_data'  ELSE 'source_deal_delta_value' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + ''  END + ' vsd
				INNER JOIN (SELECT source_deal_header_id FROM ' + @tbl_name + ' WHERE real_deal = ''n'') t ON vsd.source_deal_header_id = t.source_deal_header_id
				AND vsd.pnl_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '' +
				CASE WHEN @revaluation = 'y' THEN ' AND vsd.criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END
				
				exec spa_print @st_sql
				EXEC(@st_sql)
				
				--Simulation of hypothetical deals using old method
				IF @call_to = 'o'
					SET @st_sql = '
					INSERT INTO var_simulation_data(
						run_date,
						source_deal_header_id,
						term_start,
						term_end,
						Leg,
						pnl_as_of_date,
						und_pnl,
						und_intrinsic_pnl,
						und_extrinsic_pnl,
						dis_pnl,
						dis_intrinsic_pnl,
						dis_extrinisic_pnl,
						pnl_source_value_id,
						pnl_currency_id,
						pnl_conversion_factor,
						pnl_adjustment_value,
						deal_volume,
						create_user,
						create_ts,
						und_pnl_set,
						market_value,
						contract_value,
						dis_market_value,
						dis_contract_value)
					SELECT 
						''' + CAST(@run_date AS VARCHAR) + ''', 
						sdd.source_deal_header_id, 
						sdd.term_start, 
						sdd.term_end, 
						sdd.leg, 
						a.as_of_date, 
						ISNULL(CASE WHEN sdd.buy_sell_flag = ''s'' THEN ''-1'' ELSE ''1'' END *
							(sdd.total_volume *
							(COALESCE(spcm.curve_value, spcm1.curve_value, spcm2.curve_value, spcm3.curve_value)
							' + CASE WHEN @shift_by = 'v' THEN ' + ' + CAST(@shift_val AS VARCHAR) ELSE ' * ' + CAST((1 + @shift_val / 100) AS VARCHAR) END + ')
							), 0) + 
						ISNULL(CASE WHEN sdd.pay_opposite = ''y'' AND sdd.buy_sell_flag = ''b''	THEN -1 ELSE 1 END *
							(sdd.total_volume * ISNULL(sdd.fixed_price, 0)), 0) und_pnl,
						0 und_intrinsic_pnl,
						0 und_extrinsic_pnl,
						0 dis_pnl,
						0 dis_intrinsic_pnl,
						0 dis_extrinisic_pnl,
						' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + ',  
						sdd.fixed_price_currency_id,
						0 pnl_conversion_factor,
						0 pnl_adjustment_value,
						sdd.total_volume,
						''' + @user_name + ''',
						GETDATE(),
						ISNULL(CASE WHEN sdd.buy_sell_flag = ''s'' THEN ''-1'' ELSE ''1'' END *
							(sdd.total_volume * 
							(COALESCE(spcm.curve_value, spcm1.curve_value, spcm2.curve_value, spcm3.curve_value)
							' + CASE WHEN @shift_by = 'v' THEN ' + ' + CAST(@shift_val AS VARCHAR) ELSE ' * ' + CAST((1 + @shift_val / 100) AS VARCHAR) END + ')
							), 0) + 
						ISNULL(CASE WHEN sdd.pay_opposite = ''y'' AND sdd.buy_sell_flag = ''b''	THEN -1 ELSE 1 END *
							(sdd.total_volume * ISNULL(sdd.fixed_price, 0)), 0) und_pnl_set,
						CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END *
						(sdd.total_volume * 
							(COALESCE(spcm.curve_value, spcm1.curve_value, spcm2.curve_value, spcm3.curve_value)
							' + CASE WHEN @shift_by = 'v' THEN ' + ' + CAST(@shift_val AS VARCHAR) ELSE ' * ' + CAST((1 + @shift_val / 100) AS VARCHAR) END + ')
							)  market_value,
						CASE WHEN sdd.buy_sell_flag = ''b'' THEN -1 ELSE 1 END *
						(sdd.total_volume * ISNULL(sdd.fixed_price, 0)) contract_value, 
						NULL dis_market_value,
						NULL dis_contract_value
					FROM ' + @hypo_deal_detail + ' sdd 
					INNER JOIN (SELECT source_deal_header_id FROM ' + @tbl_name + ' WHERE real_deal = ''n'') t ON sdd.source_deal_header_id = t.source_deal_header_id
					CROSS JOIN #as_of_date_point a
					LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
					LEFT JOIN source_price_curve_def spcd1 ON spcd.proxy_source_curve_def_id = spcd1.source_curve_def_id	
					LEFT JOIN source_price_curve_def spcd2 ON spcd.monthly_index = spcd2.source_curve_def_id
					LEFT JOIN source_price_curve_def spcd3 ON spcd.proxy_curve_id3 = spcd3.source_curve_def_id
					LEFT JOIN source_price_curve_simulation spcm ON spcd.source_curve_def_id = spcm.source_curve_def_id   
						AND spcm.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm.as_of_date = a.as_of_date
						AND spcm.maturity_date = sdd.term_start
						AND spcm.run_date = ''' + CAST(@run_date AS VARCHAR) + '''
					LEFT JOIN source_price_curve_simulation spcm1 ON spcd1.source_curve_def_id = spcm1.source_curve_def_id
						AND spcm1.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm1.as_of_date = a.as_of_date
						AND spcm1.maturity_date = sdd.term_start
						AND spcm1.run_date = ''' + CAST(@run_date AS VARCHAR) + '''
					LEFT JOIN source_price_curve_simulation spcm2 ON spcd2.source_curve_def_id = spcm2.source_curve_def_id
						AND spcm2.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm2.as_of_date = a.as_of_date
						AND spcm2.maturity_date = sdd.term_start
						AND spcm2.run_date = ''' + CAST(@run_date AS VARCHAR) + '''
					LEFT JOIN source_price_curve_simulation spcm3 ON spcd3.source_curve_def_id = spcm3.source_curve_def_id
						AND spcm3.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm3.as_of_date = a.as_of_date
						AND spcm3.maturity_date = sdd.term_start
						AND spcm3.run_date = ''' + CAST(@run_date AS VARCHAR) + ''''
				ELSE --Simulation of hypothetical deals using new method
					SET @st_sql = '
					INSERT INTO source_deal_delta_value' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + '(
						' + CASE WHEN @revaluation = 'y' THEN 'criteria_id,' ELSE '' END + '
						run_date,
						source_deal_header_id,
						term_start,
						term_end,
						as_of_date,
						delta_value,
						pnl_source_value_id,
						currency_id,
						Position,
						avg_delta_value,
						market_value_delta,
						contract_value_delta,
						counterparty_id,
						curve_id,
						leg)
					SELECT 
						' + CASE WHEN @revaluation = 'y' THEN CAST(@whatif_criteria_id AS VARCHAR)+',' ELSE '' END + '
						''' + CAST(@run_date AS VARCHAR) + ''', 
						sdd.source_deal_header_id, 
						sdd.term_start, 
						sdd.term_end, 
						a.as_of_date, 
						ISNULL(CASE WHEN sdd.buy_sell_flag = ''s'' THEN ''-1'' ELSE ''1'' END *
							(sdd.total_volume * 
							(COALESCE(spcm.curve_value_delta, spcm1.curve_value_delta, spcm2.curve_value_delta, spcm3.curve_value_delta) 
							)), 0) und_pnl,
						' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + ',  
						sdd.fixed_price_currency_id,
						sdd.total_volume,
						ISNULL(CASE WHEN sdd.buy_sell_flag = ''s'' THEN ''-1'' ELSE ''1'' END *
							(sdd.total_volume * 
							(COALESCE(spcm.curve_value_avg_delta, spcm1.curve_value_avg_delta, spcm2.curve_value_avg_delta, spcm3.curve_value_avg_delta) 
							)), 0) und_pnl_set,
						CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END *
						(sdd.total_volume * 
							(COALESCE(spcm.curve_value_delta, spcm1.curve_value_delta, spcm2.curve_value_delta, spcm3.curve_value_delta) 
							))  market_value,
						CASE WHEN sdd.buy_sell_flag = ''s'' THEN 1 ELSE -1 END *
						(sdd.total_volume * 
							(COALESCE(spcm4.curve_value_delta, spcm5.curve_value_delta, spcm6.curve_value_delta, spcm7.curve_value_delta) 
							))  contract_value,
						t.counterparty,
						sdd.curve_id,
						sdd.leg	
					FROM ' + @hypo_deal_detail + ' sdd 
					INNER JOIN (SELECT source_deal_header_id, counterparty FROM ' + @tbl_name + ' WHERE real_deal = ''n'') t ON sdd.source_deal_header_id = t.source_deal_header_id
					CROSS JOIN #as_of_date_point a
					LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
					LEFT JOIN source_price_curve_def spcd1 ON spcd.proxy_source_curve_def_id = spcd1.source_curve_def_id	
					LEFT JOIN source_price_curve_def spcd2 ON spcd.monthly_index = spcd2.source_curve_def_id
					LEFT JOIN source_price_curve_def spcd3 ON spcd.proxy_curve_id3 = spcd3.source_curve_def_id
					LEFT JOIN source_price_simulation_delta' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + ' spcm ON spcd.source_curve_def_id = spcm.source_curve_def_id					' + CASE WHEN @revaluation = 'y' THEN ' AND spcm.criteria_id =  ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END + '
						AND spcm.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm.as_of_date = a.as_of_date
						AND spcm.maturity_date = sdd.term_start
						AND spcm.run_date = ''' + CAST(@run_date AS VARCHAR) + '''
					LEFT JOIN source_price_simulation_delta' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + ' spcm1 ON spcd1.source_curve_def_id = spcm1.source_curve_def_id
					' + CASE WHEN @revaluation = 'y' THEN ' AND spcm1.criteria_id =  ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END + '
						AND spcm1.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm1.as_of_date = a.as_of_date
						AND spcm1.maturity_date = sdd.term_start
						AND spcm1.run_date = ''' + CAST(@run_date AS VARCHAR) + '''
					LEFT JOIN source_price_simulation_delta' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + ' spcm2 ON spcd2.source_curve_def_id = spcm2.source_curve_def_id
					' + CASE WHEN @revaluation = 'y' THEN ' AND spcm2.criteria_id =  ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END + '
						AND spcm2.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm2.as_of_date = a.as_of_date
						AND spcm2.maturity_date = sdd.term_start
						AND spcm2.run_date = ''' + CAST(@run_date AS VARCHAR) + '''
					LEFT JOIN source_price_simulation_delta' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + ' spcm3 ON spcd3.source_curve_def_id = spcm3.source_curve_def_id
					' + CASE WHEN @revaluation = 'y' THEN ' AND spcm3.criteria_id =  ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END + '
						AND spcm3.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm3.as_of_date = a.as_of_date
						AND spcm3.maturity_date = sdd.term_start
						AND spcm3.run_date = ''' + CAST(@run_date AS VARCHAR) + '''

					LEFT JOIN source_price_curve_def spcd4 ON spcd4.source_curve_def_id = sdd.formula_curve_id
					LEFT JOIN source_price_curve_def spcd5 ON spcd4.proxy_source_curve_def_id = spcd5.source_curve_def_id	
					LEFT JOIN source_price_curve_def spcd6 ON spcd4.monthly_index = spcd6.source_curve_def_id
					LEFT JOIN source_price_curve_def spcd7 ON spcd4.proxy_curve_id3 = spcd7.source_curve_def_id
					LEFT JOIN source_price_simulation_delta spcm4 ON spcd4.source_curve_def_id = spcm4.source_curve_def_id   
						AND spcm4.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm4.as_of_date = a.as_of_date
						AND spcm4.maturity_date = sdd.term_start
						AND spcm4.run_date = ''' + CAST(@run_date AS VARCHAR) + '''
					LEFT JOIN source_price_simulation_delta spcm5 ON spcd5.source_curve_def_id = spcm5.source_curve_def_id
						AND spcm5.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm5.as_of_date = a.as_of_date
						AND spcm5.maturity_date = sdd.term_start
						AND spcm5.run_date = ''' + CAST(@run_date AS VARCHAR) + '''
					LEFT JOIN source_price_simulation_delta spcm6 ON spcd6.source_curve_def_id = spcm6.source_curve_def_id
						AND spcm6.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm6.as_of_date = a.as_of_date
						AND spcm6.maturity_date = sdd.term_start
						AND spcm6.run_date = ''' + CAST(@run_date AS VARCHAR) + '''
					LEFT JOIN source_price_simulation_delta spcm7 ON spcd7.source_curve_def_id = spcm7.source_curve_def_id
						AND spcm7.curve_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						AND spcm7.as_of_date = a.as_of_date
						AND spcm7.maturity_date = sdd.term_start
						AND spcm7.run_date = ''' + CAST(@run_date AS VARCHAR) + ''''
				
				exec spa_print @st_sql
				EXEC(@st_sql)
			END 
			--Common Validation for Monte Carlo VaR, EaR, CFaR
			--Checking available deal's simulation exist or not
			CREATE TABLE #deal_not_found (source_deal_header_id INT, deal_id VARCHAR(100) COLLATE DATABASE_DEFAULT )
			IF @call_to = 'o'
				SET @st_sql = '
				INSERT INTO #deal_not_found (source_deal_header_id, deal_id)
				SELECT DISTINCT
					t.source_deal_header_id,
					sdh.deal_id 
				FROM #tmp_term t
				INNER JOIN source_deal_header sdh ON t.source_deal_header_id = sdh.source_deal_header_id
					AND NOT EXISTS (
						SELECT DISTINCT source_deal_header_id 
						FROM var_simulation_data vsd
						WHERE vsd.source_deal_header_id = t.source_deal_header_id 
							AND run_date = ''' + CAST(@run_date AS VARCHAR) + ''')'
			ELSE
				SET @st_sql = '
				INSERT INTO #deal_not_found (source_deal_header_id, deal_id)
				SELECT DISTINCT
					t.source_deal_header_id,
					sdh.deal_id 
				FROM #tmp_term t
				INNER JOIN source_deal_header sdh ON t.source_deal_header_id = sdh.source_deal_header_id
					AND NOT EXISTS (
						SELECT DISTINCT source_deal_header_id 
						FROM source_deal_delta_value' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + ' vsd
						WHERE vsd.source_deal_header_id = t.source_deal_header_id 
						    AND vsd.pnl_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
							AND run_date = ''' + CAST(@run_date AS VARCHAR) + '''' +
						CASE WHEN @revaluation = 'y' THEN ' AND vsd.criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END	+ ')'			
					
				exec spa_print @st_sql
				EXEC(@st_sql)
				
				--Checking available hypothetical deal's simulation exist or not
				IF EXISTS(SELECT TOP 1 1 FROM #tmp_term WHERE source_deal_header_id < 0)
				BEGIN
					IF @call_to = 'o'
						SET @st_sql = '
						INSERT INTO #deal_not_found (source_deal_header_id, deal_id)
						SELECT DISTINCT
							t.source_deal_header_id,
							sdh.deal_id 
						FROM #tmp_term t
						INNER JOIN ' + @hypo_deal_header + ' sdh ON t.source_deal_header_id = sdh.source_deal_header_id
							AND NOT EXISTS (
								SELECT DISTINCT source_deal_header_id 
								FROM var_simulation_data vsd
								WHERE vsd.source_deal_header_id = t.source_deal_header_id 
									AND run_date = ''' + CAST(@run_date AS VARCHAR) + ''')'
					ELSE
						SET @st_sql = '
						INSERT INTO #deal_not_found (source_deal_header_id, deal_id)
						SELECT DISTINCT
							t.source_deal_header_id,
							sdh.deal_id 
						FROM #tmp_term t
						INNER JOIN ' + @hypo_deal_header + ' sdh ON t.source_deal_header_id = sdh.source_deal_header_id
							AND NOT EXISTS (
								SELECT DISTINCT source_deal_header_id 
								FROM source_deal_delta_value' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + ' vsd
								WHERE vsd.source_deal_header_id = t.source_deal_header_id
									AND vsd.pnl_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + ' 
									AND run_date = ''' + CAST(@run_date AS VARCHAR) + '''' +
								CASE WHEN @revaluation = 'y' THEN ' AND vsd.criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END + ')'
							
					exec spa_print @st_sql
					EXEC(@st_sql)
				END
				
				IF EXISTS(SELECT TOP 1 1 FROM #deal_not_found)
				BEGIN
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps)
					SELECT @process_id, 'Error', @module, @source, @type, 'MTM simulation value not found for Deal ID: '
					+ CONVERT(VARCHAR(10), ABS(source_deal_header_id)) + ' (' + dbo.FNATRMWinHyperlink('a', CASE WHEN source_deal_header_id < 0 THEN 10183400 ELSE 10131000 END, deal_id, ABS(source_deal_header_id),null,null,null,null,null,null,null,null,null,null,null,0) + ') for as of date: ' +
					convert(varchar(10),@as_of_date,120), 'Please Run MTM simulation' 
					FROM #deal_not_found 
					
					RAISERROR ('CatchError', 16, 1)
				END
				--Total number of un-available as_of_date in simulated data
				SET @total_count = ABS(@simulation_days - @total_available_date)
				
				--Total available date should equal to @simulation_days
				IF (@total_available_date < @simulation_days)
				BEGIN
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
					SELECT @process_id,'Error',@module, @source, @type, CAST(@total_count AS VARCHAR) + ' MTM simulation value not found for '
					+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: '+ @hyperlink+ ';'
					END + ' As of Date:'+ convert(varchar(10),@as_of_date,120) + '.','Please check data.'
						
					RAISERROR ('CatchError', 16, 1)
				END
			
			--Gathering simulation for available deals for VaR
			IF  @measure IN(17351, 17357) 
			BEGIN
				IF @call_to = 'o'
					SET @st_sql = '
					SELECT
						''-1'' criteria_id,
						vsd.source_deal_header_id,
						vsd.term_start,
						term_end,
						Leg,
						pnl_as_of_date,
						und_pnl,
						und_intrinsic_pnl,
						und_extrinsic_pnl,
						dis_pnl,
						dis_intrinsic_pnl,
						dis_extrinisic_pnl,
						pnl_source_value_id,
						pnl_currency_id,
						pnl_conversion_factor,
						pnl_adjustment_value,
						deal_volume,
						create_user,
						create_ts,
						update_user,
						update_ts,
						vsd.und_pnl_set,
						market_value,
						contract_value,
						dis_market_value,
						dis_contract_value
						INTO ' + @MTMProcessTableName + '
					FROM var_simulation_data vsd
					INNER JOIN ' + @tmp_deals_process_table + ' tt ON vsd.source_deal_header_id = tt.source_deal_header_id
					INNER JOIN ' + @as_of_date_point_process_table + ' aodp ON vsd.pnl_as_of_date = aodp.as_of_date
					WHERE vsd.run_date = ''' + CAST(@run_date AS VARCHAR) + ''''
				ELSE
				BEGIN
					--Shift Enhancement starts here
					DECLARE @whatif_shift_new varchar(250)
					SET @whatif_shift_new = dbo.FNAProcessTableName('whatif_shift_new', @user_name,@process_id)
					
					IF @curve_as_of_date IS NULL
						SET @curve_as_of_date = CONVERT(VARCHAR(10), @as_of_date, 120)
						
					IF OBJECT_ID('tempdb..#source_deal_delta_value') IS NOT NULL DROP TABLE #source_deal_delta_value
						
					CREATE TABLE #source_deal_delta_value(
						run_date datetime NULL,
						as_of_date datetime NULL,
						curve_id int NULL,
						source_deal_header_id int NULL,
						term_start datetime NOT NULL,
						term_end datetime NULL,
						currency_id int NULL,
						contract_value_delta float NULL,
						market_value_delta float NULL,
						curve_value float NULL,
						formula_curve_value float NULL,
						formula_curve_id int NULL,
						physical_financial_flag CHAR(1) COLLATE DATABASE_DEFAULT,
						leg int
					)
					
					SET @st_sql = 'INSERT INTO #source_deal_delta_value
						SELECT
							vsd.run_date,
							vsd.as_of_date,
							vsd.curve_id,
							vsd.source_deal_header_id,
							vsd.term_start,
							vsd.term_end,
							vsd.currency_id,' + 
							CASE WHEN @use_dis_val = 'y' THEN '
							vsd.dis_contract_value_delta,
							vsd.dis_market_value_delta,	'
							ELSE '
							vsd.contract_value_delta,
							vsd.market_value_delta, '
							END + '
							vsd.curve_value,
							vsd.formula_curve_value,
							vsd.formula_curve_id,
							vsd.physical_financial_flag,
							vsd.leg
						FROM source_deal_delta_value' + CASE WHEN @revaluation = 'y' THEN '_whatif' ElSE '' END + ' vsd
						INNER JOIN ' + @tmp_deals_process_table + ' tt ON tt.source_deal_header_id = vsd.source_deal_header_id
							AND tt.leg = vsd.leg
							AND vsd.pnl_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
						INNER JOIN ' + @as_of_date_point_process_table + ' aodp ON aodp.as_of_date = vsd.as_of_date
						WHERE vsd.run_date = ''' + CAST(@run_date AS VARCHAR) + '''' +
						CASE WHEN @revaluation = 'y' THEN ' AND vsd.criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END +
						CASE WHEN @term_start IS NOT NULL THEN ' AND vsd.term_start >= '''	+ CAST(@term_start AS VARCHAR) + '''' ELSE '' END +
						CASE WHEN @term_end IS NOT NULL THEN ' AND vsd.term_end <= ''' + CAST(@term_end AS VARCHAR) + '''' ELSE '' END
					
					exec spa_print @st_sql
					EXEC(@st_sql)

					IF @measure = 17357 --For GMaR
					BEGIN						
						UPDATE sddv SET market_value_delta = CASE WHEN physical_financial_flag = 'p' THEN 0 ELSE market_value_delta END
						FROM #source_deal_delta_value sddv
					END

					--IF @revaluation = 'y' AND EXISTS(SELECT 1 FROM #source_deal_delta_value WHERE source_deal_header_id < 1)
					--BEGIN
					--	SET @st_sql = '
					--		UPDATE vsd SET 
					--			vsd.market_value_delta = 
					--				CASE WHEN ISNULL(wis.curve_shift_per, 1) <> 1 THEN 
					--					(market_value_delta * wis.curve_shift_per) 
					--				ELSE CASE WHEN ISNULL(wis.curve_shift_val, 0) <> 0 THEN (market_value_delta * ((wis.curve_shift_val/curve_value)+1)) ELSE market_value_delta END 
					--				END,
					--			vsd.contract_value_delta = 
					--				CASE WHEN ISNULL(wis1.curve_shift_per, 1) <> 1 THEN 
					--					(contract_value_delta * wis1.curve_shift_per) 
					--				ELSE CASE WHEN ISNULL(wis1.curve_shift_val, 0) <> 0 THEN (contract_value_delta * ((wis1.curve_shift_val/formula_curve_value)+1)) ELSE contract_value_delta END 
					--				END
					--		FROM #source_deal_delta_value vsd
					--		LEFT JOIN ' + @whatif_shift + ' wis ON wis.curve_id = vsd.curve_id
					--		LEFT JOIN ' + @whatif_shift + ' wis1 ON wis1.curve_id = vsd.formula_curve_id
					--		WHERE vsd.run_date = ''' + CAST(@run_date AS VARCHAR) + '''
					--			AND vsd.source_deal_header_id < 0'
						
					--	exec spa_print @st_sql
					--	EXEC(@st_sql)
					--END
					
					IF @revaluation <> 'y'
					BEGIN
						IF OBJECT_ID('tempdb..#whatif_shift_mtm_new') IS NOT NULL DROP TABLE #whatif_shift_mtm_new
						CREATE TABLE #whatif_shift_mtm_new(curve_id INT, curve_shift_val FLOAT, curve_shift_per FLOAT, shift_by CHAR(1) COLLATE DATABASE_DEFAULT )
					
						IF OBJECT_ID(@whatif_shift_new) IS NOT NULL
						EXEC('INSERT INTO #whatif_shift_mtm_new (curve_id, curve_shift_val, curve_shift_per, shift_by) SELECT curve_id, curve_shift_val, curve_shift_per, shift_by FROM ' + @whatif_shift_new)
					
						IF OBJECT_ID('tempdb..#tmp_as_of_date') IS NOT NULL 
						DROP TABLE #tmp_as_of_date
					
						SELECT 
							spc.source_curve_def_id,
							MAX(spc.as_of_date) as_of_date
						INTO #tmp_as_of_date
						FROM source_price_curve spc
						INNER JOIN #whatif_shift_mtm_new wsmn ON wsmn.curve_shift_val = spc.source_curve_def_id
						WHERE as_of_date <= @curve_as_of_date AND curve_source_value_id = 4500
						GROUP BY spc.source_curve_def_id

						IF OBJECT_ID('tempdb..#source_price_curve') IS NOT NULL 
						DROP TABLE #source_price_curve
					
						SELECT  
							DATEDIFF(MM, taod.as_of_date, maturity_date) id, 
							wsm.curve_id source_curve_def_id, 
							spc.as_of_date,
							spc.curve_source_value_id, 
							spc.maturity_date, 
							spc.curve_value,
							spcd.Granularity
						INTO #source_price_curve	 
						FROM source_price_curve spc
						INNER JOIN #tmp_as_of_date taod ON taod.source_curve_def_id = spc.source_curve_def_id
							AND taod.as_of_date = spc.as_of_date
						INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = spc.source_curve_def_id
							AND spcd.Granularity = 980
						INNER JOIN #whatif_shift_mtm_new wsm ON wsm.curve_shift_val = spcd.source_curve_def_id
						WHERE spc.curve_source_value_id	= 4500
							AND DATEDIFF(MM, taod.as_of_date, maturity_date) >= 0
						ORDER BY spc.maturity_date	
					
						IF OBJECT_ID('tempdb..#min_id') IS NOT NULL 
						DROP TABLE #min_id
						
						SELECT
							source_curve_def_id, 
							MIN(id) min_id
						INTO #min_id	
						FROM #source_price_curve GROUP BY source_curve_def_id	
					
						--dfrtretergdfgdrg
						IF OBJECT_ID('tempdb..#source_deal_delta_value_one') IS NOT NULL 
						DROP TABLE #source_deal_delta_value_one
					
						SELECT 
							CASE WHEN mi.min_id >= DATEDIFF(MM, tc.run_date, tc.term_start) THEN mi.min_id ELSE DATEDIFF(MM, tc.run_date, tc.term_start) END id, 
							tc.*
						INTO #source_deal_delta_value_one 
						FROM #source_deal_delta_value tc
						INNER JOIN #whatif_shift_mtm_new wsm ON wsm.curve_id = tc.curve_id
						INNER JOIN #tmp_as_of_date taod ON taod.source_curve_def_id = wsm.curve_shift_val
							AND DATEDIFF(MM, tc.run_date, tc.term_start) >= 0
						LEFT JOIN #min_id mi ON mi.source_curve_def_id = tc.curve_id
						ORDER BY CONVERT(VARCHAR(7), tc.term_start, 120)
					
						INSERT INTO #source_deal_delta_value_one(id,
							run_date,
							as_of_date,
							curve_id,
							source_deal_header_id,
							term_start,
							term_end,
							currency_id,
							contract_value_delta,
							market_value_delta,
							curve_value,
							formula_curve_value,
							formula_curve_id, 
							physical_financial_flag,
							leg)
						SELECT 
							CASE WHEN mi.min_id >= DATEDIFF(MM, tc.run_date, tc.term_start) THEN mi.min_id ELSE DATEDIFF(MM, tc.run_date, tc.term_start) END id, 
							tc.* 
						FROM #source_deal_delta_value tc
						INNER JOIN #whatif_shift_mtm_new wsm ON wsm.curve_id = tc.formula_curve_id
						INNER JOIN #tmp_as_of_date taod ON taod.source_curve_def_id = wsm.curve_shift_val
							AND DATEDIFF(MM, tc.run_date, tc.term_start) >= 0
						LEFT JOIN #min_id mi ON mi.source_curve_def_id = tc.formula_curve_id
						WHERE NOT EXISTS(SELECT * FROM #source_deal_delta_value_one spco WHERE spco.curve_id = tc.curve_id AND spco.formula_curve_id = tc.formula_curve_id)
						ORDER BY CONVERT(VARCHAR(7), tc.term_start, 120)

						DELETE tc  FROM #source_deal_delta_value tc
						INNER JOIN #source_deal_delta_value_one wsm ON wsm.curve_id = tc.curve_id
			
						UPDATE tco SET market_value_delta = 
							CASE wsm.shift_by WHEN 'c' THEN 
								tco.market_value_delta*(1+spc.curve_value/100) 
							ELSE 
								(tco.market_value_delta * ((spc.curve_value/tco.curve_value)+1)) 
							END
						FROM #source_deal_delta_value_one tco
						INNER JOIN #source_price_curve spc ON spc.id = tco.id
							AND spc.source_curve_def_id = tco.curve_id
						INNER JOIN #whatif_shift_mtm_new wsm ON wsm.curve_id = spc.source_curve_def_id
					
						UPDATE tco SET contract_value_delta = 
							CASE wsm.shift_by WHEN 'c' THEN 
								tco.contract_value_delta*(1+spc.curve_value/100) 
							ELSE 
								(tco.contract_value_delta * ((spc.curve_value/tco.formula_curve_value)+1)) 
							END
						FROM #source_deal_delta_value_one tco
						INNER JOIN #source_price_curve spc ON spc.id = tco.id
							AND spc.source_curve_def_id = tco.formula_curve_id
						INNER JOIN #whatif_shift_mtm_new wsm ON wsm.curve_id = spc.source_curve_def_id
					
						INSERT INTO #source_deal_delta_value
						SELECT
							run_date,
							as_of_date,
							curve_id,
							source_deal_header_id,
							term_start,
							term_end,
							currency_id,
							contract_value_delta,
							market_value_delta,
							curve_value,
							formula_curve_value,
							formula_curve_id,
							physical_financial_flag,
							leg
						FROM #source_deal_delta_value_one				
					
						SET @st_sql = '
							UPDATE vsd SET 
								vsd.market_value_delta = 
									CASE WHEN ISNULL(wis.curve_shift_per, 1) <> 1 THEN 
										(market_value_delta * wis.curve_shift_per) 
									ELSE CASE WHEN ISNULL(wis.curve_shift_val, 0) <> 0 THEN 
										(market_value_delta * ((wis.curve_shift_val/curve_value)+1)) ELSE market_value_delta END 
									END,
								vsd.contract_value_delta = 
									CASE WHEN ISNULL(wis1.curve_shift_per, 1) <> 1 THEN 
										(contract_value_delta * wis1.curve_shift_per) 
									ELSE CASE WHEN ISNULL(wis1.curve_shift_val, 0) <> 0 THEN 
										(contract_value_delta * ((wis1.curve_shift_val/formula_curve_value)+1)) ELSE contract_value_delta END 
									END
							FROM #source_deal_delta_value vsd
							--INNER JOIN ' + @tmp_deals_process_table + ' tt ON tt.source_deal_header_id = vsd.source_deal_header_id
							--	AND tt.curve_id = vsd.curve_id
							--INNER JOIN ' + @as_of_date_point_process_table + ' aodp ON aodp.as_of_date = vsd.as_of_date
							LEFT JOIN ' + @whatif_shift + ' wis ON wis.curve_id = vsd.curve_id
							LEFT JOIN ' + @whatif_shift + ' wis1 ON wis1.curve_id = vsd.formula_curve_id
							WHERE vsd.run_date = ''' + CAST(@run_date AS VARCHAR) + ''''
						
						exec spa_print @st_sql
						EXEC(@st_sql)					
					END
					--Shift Enhancement end here
					
					SET @st_sql = '
						SELECT
							''-1'' criteria_id,
							vsd.source_deal_header_id,
							vsd.term_start,
							term_end,
							Leg,
							vsd.as_of_date pnl_as_of_date,
							(ISNULL(market_value_delta, 0) + ISNULL(contract_value_delta, 0)) und_pnl,
							NULL und_intrinsic_pnl,
							NULL und_extrinsic_pnl,
							NULL dis_pnl,
							NULL dis_intrinsic_pnl,
							NULL dis_extrinisic_pnl,
							4505 pnl_source_value_id,
							vsd.currency_id pnl_currency_id,
							1 pnl_conversion_factor,
							NULL pnl_adjustment_value,
							NULL deal_volume,
							dbo.FNADBUser() create_user,
							getdate() create_ts,
							dbo.FNADBUser() update_user,
							getdate() update_ts,
							contract_value_delta und_pnl_set,
							market_value_delta market_value,
							contract_value_delta contract_value,
							NULL dis_market_value,
							NULL dis_contract_value,
							curve_id
						INTO ' + @MTMProcessTableName + '
						FROM #source_deal_delta_value vsd'
						
					exec spa_print @st_sql
					EXEC(@st_sql)
				END	
			END
			ELSE IF @measure IN(17352, 17353) 
			BEGIN
				SET @st_sql = '[dbo].[spa_Create_MTM_Period_Report_TRM_wrapper] 
					@as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''',
					@sub_entity_id = NULL,
					@discount_option = ''u'',
					@settlement_option = NULL,
					@report_type = ' + CASE WHEN @measure = '17353' THEN 'e' ELSE 'c' END + ',
					@summary_option = ''15'',
					@include_item = NULL,
					@show_firstday_gain_loss = NULL,
					@transaction_type = ''401,402,400'', 
					@show_prior_processed_values = ''n'',
					@exceed_threshold_value = ''n'',
					@show_only_for_deal_date = NULL,
					@use_create_date = ''n'',
					@round_value = ''6'',
					@counterparty = ''a'',
					@mapped = ''m'',
					@match_id = ''n'',
					@curve_source_id =  ''4505'',
					@deal_sub_type = NULL,
					@phy_fin = ''b'',
					@period_report = ''n'',
					@settlement_only = ''n'',
					@source_deal_header_list = ''' + @tmp_deals_process_table + ''',
					@process_table = ''' + @MTMProcessTableName + ''',
					@run_date = ''' + CAST(@run_date AS VARCHAR) + ''',
					@batch_process_id = ''' + CAST(@process_id AS VARCHAR(50)) + ''',
					@calc_type = ''' + @calc_type + ''',
					@call_to = ''' + @call_to + ''''
					
				IF @term_start IS NOT NULL 
					SET @st_sql = @st_sql + ', @tenor_from = '''	+ CAST(@term_start AS VARCHAR) + ''''
				IF @term_end IS NOT NULL 
					SET @st_sql = @st_sql + ', @tenor_to = ''' + CAST(@term_end AS VARCHAR) + '''' 
				IF @whatif_criteria_id IS NOT NULL 
					SET @st_sql = @st_sql + ', @criteria_id = '''	+ CAST(@whatif_criteria_id AS VARCHAR) + ''''
					 
				exec spa_print @st_sql
				EXEC(@st_sql)
				
				IF @calc_type = 'w' AND @revaluation <> 'y'
				BEGIN
					SET @st_sql = 'UPDATE ' + @MTMProcessTableName + ' SET 
						und_pnl = mtm.und_pnl * CASE WHEN wis.curve_shift_per IS NOT NULL THEN  wis.curve_shift_per ELSE ''1'' END 
					FROM ' + @MTMProcessTableName + ' mtm
					LEFT JOIN ' + @whatif_shift + ' wis ON mtm.curve_id = wis.curve_id
					WHERE mtm.pnl_as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + ''''
				
					exec spa_print @st_sql
					EXEC(@st_sql)		
				END
			END
		END	
		ELSE --Historical Simulation
		BEGIN
			DECLARE @mtm_job VARCHAR(100), @mtm_as_of_date VARCHAR(100)
			SET @mtm_as_of_date = CONVERT(VARCHAR(10), @as_of_date, 120)
			DECLARE b_cursor CURSOR FOR
				SELECT as_of_date FROM #as_of_date_point	
			OPEN b_cursor
			FETCH NEXT FROM b_cursor INTO @curve_as_of_date
			WHILE @@FETCH_STATUS = 0   
			BEGIN 
				SET @mtm_process = @process_id
				SET @mtm_job = 'mtm_' + @mtm_process
				
				SET @st_sql = '[dbo].[spa_calc_mtm_job] 
					@sub_id = NULL,
					@strategy_id = NULL,
					@book_id = NULL,
					@source_book_mapping_id = NULL,
					@source_deal_header_id  = NULL,
					@as_of_date = ''' + @mtm_as_of_date +''',
					@curve_source_value_id = ' + CAST(CASE WHEN @var_approach IN (1521, 1522) THEN @Monte_Carlo_Curve_Source ELSE @price_curve_source END AS VARCHAR) +',
					@pnl_source_value_id = ' + CAST(CASE WHEN @var_approach IN (1521, 1522) THEN @Monte_Carlo_Curve_Source ELSE @price_curve_source END AS VARCHAR) +',
					@hedge_or_item = ''h'',
					@process_id = ''' + @process_id + ''',
					@job_name = ''' + @mtm_job + ''',
					@user_id = ''' + ISNULL(@user_name, 'null') + ''',
					@assessment_curve_type_value_id = 77,
					@table_name = ''' +  @MTMProcessTableName + ''',
					@print_diagnostic = NULL,
					@curve_as_of_date = ''' + CAST(CONVERT(VARCHAR(10), @curve_as_of_date, 120) AS VARCHAR) + ''',
					@tenor_option = NULL,
					@summary_detail = ''s'',
					@options_only = NULL,
					@trader_id = NULL,
					@status_table_name = NULL,
					@term_start = ''' + @mtm_as_of_date + ''',
					@term_end = ''' + @mtm_as_of_date + ''',
					@calc_type = ''' + CASE WHEN @calc_type = 'w' THEN 'w' ELSE 'v' END +''',
					@curve_shift_val = ' + CAST(CASE WHEN @shift_by = 'v' THEN ISNULL(@shift_val,0) ELSE 0 END AS VARCHAR)+ ',
					@curve_shift_per = ' + CAST(CASE WHEN @shift_by = 'p' THEN ISNULL(@shift_val/100 , 0) ELSE 0 END AS VARCHAR)+ ', 
					@deal_list_table = ''' + @tmp_deals_process_table + ''',
					@criteria_id = ' +  CASE WHEN @var_approach IN (1521, 1522) THEN '-1' ELSE 'NULL' END-- @criteria_id=-1 for monte carlo vAR
					
				exec spa_print @st_sql
				EXEC(@st_sql)	
				EXEC spa_print 'END [spa_calc_mtm_job] '
				FETCH NEXT FROM b_cursor INTO @curve_as_of_date
			END
			CLOSE b_cursor
			DEALLOCATE  b_cursor
		
			IF EXISTS(SELECT TOP 1 1 FROM MTM_TEST_RUN_LOG WHERE code = 'Error' AND process_id = @process_id)
			BEGIN 
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
				SELECT  @process_id, 'Error', @module, @source, 'mtm_err', 'Error found for the '
				+ CASE WHEN @criteria_name IS NULL THEN '' ELSE 'Criteria: ' 
				+ @hyperlink 
				+ ' while calculating MTM on' END +  convert(varchar(10),@as_of_date,120) + '.','Please check data.'
				
				RAISERROR ('CatchError', 16, 1)
			END
			exec spa_print 'Historical Simulation Var Calculation'
		END
	-------------------------------------------------------------------------------------------------------
	----------Historical Simulation Var Calculation
	-------------------------------------------------------------------------------------------------------
		SET @st_sql = '
			DELETE ' + @MTMProcessTableName	+ ' 
			FROM ' + @MTMProcessTableName  + ' t 
				INNER JOIN source_deal_header sdh ON t.source_deal_header_id = sdh.source_deal_header_id
			WHERE (sdh.deal_date > ''' + CAST(@as_of_date AS VARCHAR) + ''' or t.term_end < ''' + CAST(@as_of_date AS VARCHAR) + ''')' + 
					CASE WHEN @trader IS NULL THEN '' ELSE ' and sdh.trader_id = ' + CAST(@trader AS VARCHAR)  END
					
		exec spa_print @st_sql
		EXEC(@st_sql)
		
		SET @st_sql = '
			ALTER TABLE ' + @MTMProcessTableName + ' 
			ADD map_months int,
				debt_rating int,
				MTMC float,
				MTMI float,
				counterparty_id int'
				
		EXEC(@st_sql)
		
		IF @measure NOT IN(17352, 17353)
		BEGIN
			SET @st_sql = '
			INSERT INTO ' + @MTMProcessTableName + '(
				criteria_id,
				source_deal_header_id, 
				term_start, 
				term_end, 
				leg, 
				pnl_as_of_date, 
				und_pnl, 
				und_intrinsic_pnl, 
				und_extrinsic_pnl,
				dis_pnl,
				dis_intrinsic_pnl, 
				dis_extrinisic_pnl,
				pnl_source_value_id, 
				pnl_conversion_factor,
				pnl_adjustment_value,
				create_user,
				create_ts,
				update_user,
				update_ts,
				und_pnl_set,
				market_value,
				contract_value,
				dis_market_value,
				dis_contract_value,
				map_months, 
				debt_rating, 
				MTMC, 
				MTMI,
				counterparty_id,
				curve_id
				) 
			SELECT DISTINCT
				' + CASE WHEN @var_approach IN (1521, 1522) THEN '-1' ELSE '0' END + ',
				tt.source_deal_header_id,
	 			tt.term_start, 
	 			dbo.FNALastDayInDate(tt.term_start), 
	 			1,
	 			''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''' pnl_as_of_date, 
	 			tt.mtm, 
	 			0,0,0,0,0,
	 			' + CAST(CASE WHEN @var_approach IN (1521, 1522) THEN @Monte_Carlo_Curve_Source ELSE @price_curve_source END AS VARCHAR) +' pnl_source_value_id,
	 			1,
	 			0,
	 			dbo.FNADBUser(),
	 			getdate(),
	 			dbo.FNADBUser(),
	 			getdate(),
	 			tt.und_pnl_set,
	 			0,0,0,0,
	 			tt.map_months, 
	 			tt.debt_rating, 
	 			tt.mtmc, 
	 			tt.mtmi ,
	 			tt.counterparty_id,
	 			tt.curve_id 
			FROM #tmp_term tt'
			
			exec spa_print @st_sql
			EXEC(@st_sql)	
		END
	
		
		EXEC ('CREATE INDEX ind_aaaa_11_'+ @process_id+' ON ' + @MTMProcessTableName + '([pnl_as_of_date]) INCLUDE ([und_pnl], [pnl_currency_id], [MTMC], [MTMI])')
		--EXEC ('CREATE INDEX ind_aaaa_22_'+ @process_id+' ON ' + @MTMProcessTableName + '([pnl_as_of_date]) INCLUDE ([source_deal_header_id], [term_start], [und_pnl], [MTMC], [MTMI])')		
		--EXEC ('CREATE INDEX ind_aaaa_33_'+ @process_id+' ON ' + @MTMProcessTableName + '([term_start],[map_months],[debt_rating])INCLUDE ([und_pnl],[MTMC],[MTMI])')
		
		
		SELECT counterparty_id,
								max(debt_rating) debt_rating 
							into #tmp_cci FROM counterparty_credit_info  
							GROUP BY counterparty_id
		CREATE INDEX tmp_cci_ix_pt ON #tmp_cci (counterparty_id, debt_rating)
		
		SET @st_sql = '
			UPDATE ' + @MTMProcessTableName + ' SET counterparty_id = sdh.counterparty_id 
			FROM ' + @MTMProcessTableName + ' mtm 
			INNER JOIN source_deal_header sdh on mtm.source_deal_header_id = sdh.source_deal_header_id'
			 
		exec spa_print @st_sql
		EXEC(@st_sql)
		
		SET @st_sql = '
			UPDATE ' + @MTMProcessTableName + ' SET debt_rating = scp.debt_rating 
			FROM ' + @MTMProcessTableName + ' mtm 
			INNER JOIN source_deal_header sdh on mtm.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #tmp_cci scp ON sdh.counterparty_id = scp.counterparty_id'
		exec spa_print @st_sql
		EXEC(@st_sql)
	
		IF @calc_type = 'w' AND EXISTS(SELECT TOP 1 1 FROM #tmp_term WHERE source_deal_header_id < 0)
		BEGIN
			SET @st_sql = '
				UPDATE ' + @MTMProcessTableName + ' SET debt_rating = scp.debt_rating 
				FROM ' + @MTMProcessTableName + ' mtm 
				INNER JOIN ' + @hypo_deal_header + ' sdh on mtm.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN #tmp_cci scp ON sdh.counterparty_id = scp.counterparty_id'
			exec spa_print @st_sql
			EXEC(@st_sql)
		END
		
		SET @st_sql = 'UPDATE ' + @MTMProcessTableName + ' SET map_months = datediff(mm, ''' + CAST(@as_of_date AS VARCHAR) + ''', term_start) '
		
		exec spa_print @st_sql
		EXEC(@st_sql)
		
		IF OBJECT_ID('tempdb..##tmp_rip') IS not NULL
			drop table ##tmp_rip
		IF OBJECT_ID('tempdb..##tmp_rip1') IS not NULL
			drop table ##tmp_rip1	
		
		set @st_sql  = 'select distinct term_start, map_months,debt_rating into ##tmp_rip from ' + @MTMProcessTableName + ' a'
		EXEC (@st_sql)
		
		set @st_sql  = 'select term_start,debt_rating, map_months, ISNULL(dbo.FNAGetProbabilityDefault(debt_rating, map_months,''' + CAST(@as_of_date AS VARCHAR) + ''' ), 0) default_probab, ISNULL(dbo.FNAGetRecoveryRate(debt_rating, map_months, ''' + CAST(@as_of_date AS VARCHAR) + '''), 0) rec_rate into ##tmp_rip1 from ##tmp_rip'
		EXEC (@st_sql)
				
		SET @st_sql='UPDATE ' + @MTMProcessTableName + ' SET     
				MTMC = und_pnl * a.default_probab * (1 - a.rec_rate),
				MTMI = und_pnl* (1 + a.default_probab) from ' +   @MTMProcessTableName + ' mtm 
				inner join ##tmp_rip1 a on a.term_start = mtm.term_start
				and ISNULL(a.debt_rating, 0) = ISNULL(mtm.debt_rating, 0) 
				and a.map_months = mtm.map_months'
				
		
		--SET @st_sql='UPDATE ' + @MTMProcessTableName + ' SET     
		--		MTMC = und_pnl * dbo.FNAGetProbabilityDefault(debt_rating, map_months, ''' + CAST(@as_of_date AS VARCHAR) + ''')
		--		* ( 1 - dbo.FNAGetRecoveryRate(debt_rating, map_months,
		--									   ''' + CAST(@as_of_date AS VARCHAR) + ''') ),
		--		MTMI = und_pnl * ( 1 + dbo.FNAGetProbabilityDefault(debt_rating, map_months, ''' + CAST(@as_of_date AS VARCHAR) + ''') ) '
				
		exec spa_print @st_sql
		EXEC(@st_sql)

		--Holding period enhancement start
		SET @st_sql='SELECT * INTO ' + @MTMProcessTableNameNew + ' FROM ' +  @MTMProcessTableName
					
		exec spa_print @st_sql
		EXEC(@st_sql)
	
		IF @hold_to_maturity = 'Y'
		BEGIN
			SET @st_sql='UPDATE ' + @MTMProcessTableName + ' SET     
					und_pnl = und_pnl * SQRT(DATEDIFF(DAY, ''' + CAST(@as_of_date AS VARCHAR) + ''', term_end)),
					MTMC = MTMC * SQRT(DATEDIFF(DAY, ''' + CAST(@as_of_date AS VARCHAR) + ''', term_end)),
					MTMI = MTMI * SQRT(DATEDIFF(DAY, ''' + CAST(@as_of_date AS VARCHAR) + ''', term_end))'
					
			exec spa_print @st_sql
			EXEC(@st_sql)	
		END
		--Holding period enhancement end
		--EXEC ('select * from ' + @MTMProcessTableNameNew + ' order by pnl_as_of_date desc ')
		--EXEC ('select * from ' + @MTMProcessTableName + ' order by pnl_as_of_date desc ')	
	END	
	--Common variable declaration for PFE and Others
	DECLARE @VAR FLOAT, @VAR_C FLOAT, @VAR_I FLOAT, @RAROC FLOAT, @RAROC_I FLOAT, @pnl_currency_id INT
	DECLARE @confidence_level FLOAT,@K FLOAT,@tmp_val1 FLOAT,@tmp_val2 FLOAT,@tmp_K INT
	DECLARE @mean_value FLOAT, @standard_dev FLOAT --PFE variables
	
	--###############################--
		--@measure = 17355 --PFE--
	--###############################--
	IF @measure = '17355'
	BEGIN
		DECLARE @subValuePfe FLOAT,	@current_pfe FLOAT,	@mtm_query VARCHAR(500), @counterparty_name NVARCHAR(1000), @netting_counterparty_id INT, 
			@fixed_exposure FLOAT, @st_and VARCHAR(200), @count_total INT, @count_fail INT, @counterparty_list VARCHAR(500), @counterparty_list_real VARCHAR(500)
			
		SET @count_total = 0
		SET @count_fail = 0	

	
 		IF @calc_type <> 'w'
 		BEGIN
 			IF @counterparty_id IS NOT NULL
				SELECT @counterparty_name = counterparty_name FROM source_counterparty WHERE source_counterparty_id = @counterparty_id
			
			--if front provided cpty has no mapping with that criteria: error
			IF @counterparty_id IS NOT NULL AND NOT EXISTS (SELECT TOP 1 1 FROM counterparty_credit_info cci WHERE cci.pfe_criteria = @var_criteria_id AND cci.Counterparty_id = @counterparty_id)
			BEGIN
				EXEC spa_print 'no criteria has been defined for counterparty:'
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps)
				SELECT @process_id, 'Error', @module, @source, 'PFE Calculation', 'Criteria ( ' + @criteria_name + ' ) has not been defined for counterparty: ' + @counterparty_name , 'Please check data.'
				
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps)
				SELECT @process_id, 'Error', @module, @source, 'PFE Calculation', 
				'  <b>Total Counterparty Processed Count</b>: (1) <b>Error Count</b>: (1).', 'Please check data.'
				 
				RAISERROR ('CatchError', 16, 1)
					
			END
			-- if cpty not provided from front and no counterparty mapped for that criteria: error
			ELSE IF @counterparty_id IS NULL AND NOT EXISTS(SELECT TOP 1 1 FROM counterparty_credit_info cci WHERE cci.pfe_criteria = @var_criteria_id)
			BEGIN
				EXEC spa_print 'no counterparty has been mapped for criteria:'
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps)
				SELECT @process_id, 'Error', @module, @source, 'PFE Calculation'
				, 'No Counterparty has been defined for criteria: ' + @criteria_name + ', Total counterparty processed (0)', 'Please define Counterparty.'
				
				RAISERROR ('CatchError', 16, 1)
				
			END
			-- if cpty not provided from front and counterparty has been mapped to criteria: select mapped counterparty for that criteria
			ELSE IF @counterparty_id IS NULL
			BEGIN
				SELECT @counterparty_list = COALESCE(@counterparty_list + ',', '') + CAST(cci.Counterparty_id AS VARCHAR)
				FROM counterparty_credit_info cci
				WHERE cci.pfe_criteria IS NOT NULL AND cci.pfe_criteria = @var_criteria_id
				
			END
			ELSE --IF @counterparty_id IS NOT NULL
			BEGIN
				SET @counterparty_list = CAST(@counterparty_id AS VARCHAR(50))
			END	
 		END
 			
		
--SELECT @counterparty_list
--RETURN
		--test1
		
		SET @st_and = ''
		--Returning most recent available run_date and total no of as_of_date for that run_date
		--Because @total_available_date shoud equal to @simulation_days
		IF @calc_type = 'w' AND @call_to = 'n'
			IF @revaluation = 'y'
				SELECT @run_date = MAX(run_date) FROM source_deal_delta_value_whatif WHERE run_date <= @as_of_date AND criteria_id = @whatif_criteria_id AND pnl_source_value_id = @Monte_Carlo_Curve_Source
			ELSE
				SELECT @run_date = MAX(run_date) FROM source_deal_delta_value WHERE run_date <= @as_of_date
				AND pnl_source_value_id = @Monte_Carlo_Curve_Source
		ELSE	
			SELECT @run_date = MAX(run_date) FROM source_deal_pfe_simulation WHERE run_date <= @as_of_date
		SET @run_date = ISNULL(@run_date, @as_of_date)
		--Storing unique as_of_date to join below
		IF @calc_type = 'w' AND @call_to = 'n'
		BEGIN
			IF @counterparty_list IS NOT NULL
			SET @st_and = @st_and + ' AND counterparty_id IN (' + @counterparty_list + ')'
			
			SET @st_sql = '
			INSERT INTO #as_of_date_point(as_of_date)
			SELECT DISTINCT TOP ' + CAST(@simulation_days AS VARCHAR) + ' 
				as_of_date
			FROM source_deal_delta_value' + CASE WHEN @revaluation = 'y' THEN '_whatif' ElSE '' END + '
			WHERE pnl_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '
			AND run_date = ''' + CAST(@run_date AS VARCHAR) + '''' +
			CASE WHEN @revaluation = 'y' THEN ' AND criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END + '
				AND as_of_date IS NOT NULL 
				' + @st_and + '
			ORDER BY as_of_date ASC'
			
			exec spa_print @st_sql
			EXEC(@st_sql)
		END
		ELSE
		BEGIN
			IF @counterparty_list IS NOT NULL
			SET @st_and = @st_and + ' AND netting_counterparty_id IN (' + @counterparty_list + ')'
			
			SET @st_sql = '
			INSERT INTO #as_of_date_point(as_of_date)
			SELECT DISTINCT TOP ' + CAST(@simulation_days AS VARCHAR) + ' 
				as_of_date
			FROM source_deal_pfe_simulation
			WHERE run_date = ''' + CAST(@run_date AS VARCHAR) + '''
				AND as_of_date IS NOT NULL 
				' + @st_and + '
			ORDER BY as_of_date ASC'
			
			exec spa_print @st_sql
			EXEC(@st_sql)
		END	
			
		IF @calc_type = 'w'
		BEGIN
			SET @st_sql = 'SELECT as_of_date INTO ' + @as_of_date_point_process_table + ' FROM #as_of_date_point'
			exec spa_print @st_sql
			EXEC(@st_sql)
			
			SET @st_sql = '
			DELETE vsd
			FROM ' + CASE WHEN @call_to = 'o' THEN 'var_simulation_data'  ELSE 'source_deal_delta_value' + CASE WHEN @revaluation = 'y' THEN '_whatif' ElSE '' END + ''  END + ' vsd
			INNER JOIN (SELECT source_deal_header_id FROM ' + @tbl_name + ' WHERE real_deal = ''n'') t ON vsd.source_deal_header_id = t.source_deal_header_id
			AND vsd.pnl_source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '' + 
			CASE WHEN @revaluation = 'y' THEN ' AND vsd.criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END
			
			exec spa_print @st_sql
			EXEC(@st_sql)
			
			IF @call_to = 'o'
				SET @st_sql = '
				INSERT INTO var_simulation_data(
					run_date,
					source_deal_header_id,
					term_start,
					term_end,
					Leg,
					pnl_as_of_date,
					und_pnl,
					und_intrinsic_pnl,
					und_extrinsic_pnl,
					dis_pnl,
					dis_intrinsic_pnl,
					dis_extrinisic_pnl,
					pnl_source_value_id,
					pnl_currency_id,
					pnl_conversion_factor,
					pnl_adjustment_value,
					deal_volume,
					create_user,
					create_ts,
					und_pnl_set,
					market_value,
					contract_value,
					dis_market_value,
					dis_contract_value)
				SELECT 
					''' + CAST(@run_date AS VARCHAR) + ''', 
					sdd.source_deal_header_id, 
					sdd.term_start, 
					sdd.term_end, 
					sdd.leg, 
					a.as_of_date, 
					ISNULL(CASE WHEN sdd.pay_opposite = ''y'' AND sdd.buy_sell_flag = ''s'' THEN ''-1'' ELSE ''1'' END *
						(sdd.total_volume * spc.curve_value), 0) + 
					ISNULL(CASE WHEN sdd.pay_opposite = ''y'' AND sdd.buy_sell_flag = ''b''	THEN -1 ELSE 1 END *
						(sdd.total_volume * ISNULL(sdd.fixed_price, 0)), 0) und_pnl,
					0 und_intrinsic_pnl,
					0 und_extrinsic_pnl,
					0 dis_pnl,
					0 dis_intrinsic_pnl,
					0 dis_extrinisic_pnl,
					' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + ',  
					sdd.fixed_price_currency_id,
					0 pnl_conversion_factor,
					0 pnl_adjustment_value,
					sdd.total_volume,
					''' + @user_name + ''',
					GETDATE(),
					ISNULL(CASE WHEN sdd.pay_opposite = ''y'' AND sdd.buy_sell_flag = ''s'' THEN ''-1'' ELSE ''1'' END *
						(sdd.total_volume * spc.curve_value), 0) + 
					ISNULL(CASE WHEN sdd.pay_opposite = ''y'' AND sdd.buy_sell_flag = ''b''	THEN -1 ELSE 1 END *
						(sdd.total_volume * ISNULL(sdd.fixed_price, 0)), 0) und_pnl_set,
					CASE WHEN sdd.pay_opposite = ''y'' AND sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END *
					(sdd.total_volume * spc.curve_value)  market_value,
					CASE WHEN sdd.pay_opposite = ''y'' AND sdd.buy_sell_flag = ''b'' THEN -1 ELSE 1 END *
					(sdd.total_volume * ISNULL(sdd.fixed_price, 0)) contract_value, 
					NULL dis_market_value,
					NULL dis_contract_value
				FROM ' + @hypo_deal_detail + ' sdd 
				INNER JOIN (SELECT source_deal_header_id FROM ' + @tbl_name + ' WHERE real_deal = ''n'') t ON sdd.source_deal_header_id = t.source_deal_header_id
				CROSS JOIN #as_of_date_point a
				LEFT JOIN source_price_curve_simulation spc ON spc.source_curve_def_id = sdd.curve_id
					AND spc.curve_Source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '	
					AND spc.as_of_date = a.as_of_date
					AND spc.maturity_date = sdd.term_start
					AND spc.run_date = ''' + CAST(@run_date AS VARCHAR) + ''''
			ELSE
				SET @st_sql = '
				INSERT INTO source_deal_delta_value' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + '(
					' + CASE WHEN @revaluation = 'y' THEN 'criteria_id,' ELSE '' END + '
					run_date,
					source_deal_header_id,
					term_start,
					term_end,
					as_of_date,
					delta_value,
					pnl_source_value_id,
					currency_id,
					Position,
					avg_delta_value,
					market_value_delta,
					contract_value_delta,
					counterparty_id,
					curve_id)
				SELECT
					' + CASE WHEN @revaluation = 'y' THEN CAST(@whatif_criteria_id AS VARCHAR)+',' ELSE '' END + ' 
					''' + CAST(@run_date AS VARCHAR) + ''', 
					sdd.source_deal_header_id, 
					sdd.term_start, 
					sdd.term_end, 
					a.as_of_date, 
					ISNULL(CASE WHEN sdd.buy_sell_flag = ''s'' THEN ''-1'' ELSE ''1'' END *
						(sdd.total_volume * spc.curve_value_delta), 0) und_pnl,
					' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + ',  
					sdd.fixed_price_currency_id,
					sdd.total_volume,
					ISNULL(CASE WHEN sdd.buy_sell_flag = ''s'' THEN ''-1'' ELSE ''1'' END *
						(sdd.total_volume * spc.curve_value_avg_delta), 0) und_pnl_set,
					CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END *
					(sdd.total_volume * spc.curve_value_delta)  market_value,
					0 contract_value,
					t.counterparty,
					sdd.curve_id	
				FROM ' + @hypo_deal_detail + ' sdd 
				INNER JOIN (SELECT source_deal_header_id, counterparty FROM ' + @tbl_name + ' WHERE real_deal = ''n'') t ON sdd.source_deal_header_id = t.source_deal_header_id
				CROSS JOIN #as_of_date_point a
				INNER JOIN source_price_simulation_delta' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + ' spc ON spc.source_curve_def_id = sdd.curve_id
					AND spc.curve_Source_value_id = ' + CAST(@Monte_Carlo_Curve_Source AS VARCHAR) + '	
					AND spc.as_of_date = a.as_of_date
					AND spc.maturity_date = sdd.term_start
					AND spc.run_date = ''' + CAST(@run_date AS VARCHAR) + '''' +
				CASE WHEN @revaluation = 'y' THEN ' AND spc.criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END		
			
			exec spa_print @st_sql
			EXEC(@st_sql)
			--Hypothetical Deal's Counterparty
			SELECT @counterparty_list = COALESCE(@counterparty_list + ',', '') + CAST(td.counterparty_id AS VARCHAR)
			FROM (SELECT DISTINCT counterparty_id FROM #tmp_deal) td
			--Real Deal's Counterparty	
			SELECT @counterparty_list_real = COALESCE(@counterparty_list_real + ',', '') + CAST(a.counterparty_id AS VARCHAR)
			FROM (SELECT DISTINCT sdh.counterparty_id FROM #tmp_deal td
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.deal_id) a

			SET @st_sql = '
				DELETE source_deal_pfe_simulation_whatif 
				FROM source_deal_pfe_simulation_whatif sdps
				WHERE run_date = ''' + CAST(@as_of_date AS VARCHAR) + '''' 
			
			exec spa_print @st_sql
			EXEC(@st_sql)	
			
			--PFE simulation for real deals
			SET @st_sql = '[dbo].[spa_Calc_Credit_Netting_Exposure] 
				@as_of_date = ''' + CONVERT(VARCHAR(10),@as_of_date ,120) + ''',
				@curve_source_value_id = ''' + CAST(@price_curve_source AS VARCHAR) + ''',
				@counterparty_id = ''' + @counterparty_list_real + ''',
				@what_if_group = ''y'',
				@simulation = ''y'',
				@batch_process_id = ''' + @process_id + ''',
				@purge_all = ''n'',
				@calc_type = ''w'',
				@criteria_id = ' + CAST (@whatif_criteria_id AS VARCHAR) + ''
					
			exec spa_print @st_sql
			EXEC(@st_sql)
			
			IF @counterparty_list IS NOT NULL
			BEGIN
				--PFE simulation for hypothetical deals
				SET @st_sql = '[dbo].[spa_Calc_Credit_Netting_Exposure] 
					@as_of_date = ''' + CONVERT(VARCHAR(10),@as_of_date ,120) + ''',
					@curve_source_value_id = ''' + CAST(@price_curve_source AS VARCHAR) + ''',
					@counterparty_id = ''' + @counterparty_list + ''',
					@what_if_group = ''y'',
					@simulation = ''y'',
					@batch_process_id = ''' + @process_id + ''',
					@purge_all = ''n'',
					@calc_type = ''w'',
					@criteria_id = -' + CAST (@whatif_criteria_id AS VARCHAR) + ''
						
				exec spa_print @st_sql
				EXEC(@st_sql)
				
				--Deleting existing exposure for hypothetical deals
				DELETE 
					credit_exposure_detail 
				FROM credit_exposure_detail ced
				WHERE ced.source_deal_header_id < 0					
				
				--Calculating exposure for hypothetical deals: credit_exposure_detail	
				SET @st_sql = '[dbo].[spa_Calc_Credit_Netting_Exposure] 
					@as_of_date = ''' + CONVERT(VARCHAR(10),@as_of_date ,120) + ''',
					@curve_source_value_id = ''' + CAST(@price_curve_source AS VARCHAR) + ''',
					@counterparty_id = ''' + @counterparty_list + ''',
					@what_if_group = NULL,
					@simulation = NULL,
					@batch_process_id = ''' + @process_id + ''',
					@purge_all = ''n'',
					@calc_type = ''w'',
					@criteria_id = -' + CAST (@whatif_criteria_id AS VARCHAR) + ''
						
				exec spa_print @st_sql
				EXEC(@st_sql)
			END
			
			IF @call_to = 'n'
				SET @run_date = @as_of_date
				
			SET @counterparty_list = NULL
			SELECT @counterparty_list = COALESCE(@counterparty_list + ',', '') + CAST(a.counterparty_id AS VARCHAR)
				FROM (SELECT DISTINCT ISNULL(sdh.counterparty_id, td.counterparty_id) counterparty_id FROM #tmp_deal td
						LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.deal_id) a	
		END 
		
		IF @counterparty_list IS NOT NULL
			SELECT @count_total = COUNT(item) FROM dbo.SplitCommaSeperatedValues(@counterparty_list)
		ELSE 
			SET @count_total = 0				
		--Inserting data into Process table for provided @as_of_date
		--The data might be found in source_deal_pfe_simulation for provided @as_of_date
		SET @st_sql = '
		INSERT INTO ' + @PFEProcessTableName + '
		SELECT DISTINCT 
			ced.as_of_date,
			ced.curve_source_value_id,
			ced.Source_Deal_Header_ID,
			ced.term_start,
			ced.exp_type_id,
			ced.netting_counterparty_id,
			ced.counterparty_name,
			ced.currency_name,
			ced.net_exposure_to_us,
			NULL 
		FROM credit_exposure_detail ced
		WHERE as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
			AND ced.source_deal_header_id >= 0
			AND ced.curve_source_value_id = ''' + CAST(@price_curve_source AS VARCHAR) + '''
			AND ced.term_start >= ''' + CAST(@as_of_date AS VARCHAR) + ''''
			
		--to do:test1
		IF @counterparty_list IS NOT NULL--true always if flow is hERE
			SET @st_sql = @st_sql + ' AND ced.netting_counterparty_id IN (' + @counterparty_list + ')'
		IF @term_start IS NOT NULL 
			SET @st_sql = @st_sql + ' AND ced.term_start >= '''	+ CAST(@term_start AS VARCHAR) + ''''
		IF @term_end IS NOT NULL 
			SET @st_sql = @st_sql + ' AND ced.term_start <= ''' + CAST(@term_end AS VARCHAR) + ''''
		
		IF @calc_type = 'w'
		BEGIN
		SET @st_sql = @st_sql + '
			UNION ALL SELECT DISTINCT 
				ced.as_of_date,
				ced.curve_source_value_id,
				ced.Source_Deal_Header_ID,
				ced.term_start,
				ced.exp_type_id,
				ced.netting_counterparty_id,
				ced.counterparty_name,
				ced.currency_name,
				ced.net_exposure_to_us,
				NULL
			FROM credit_exposure_detail ced
			INNER JOIN (SELECT source_deal_header_id FROM ' + @tbl_name + ' WHERE real_deal = ''n'') t ON ced.source_deal_header_id = t.source_deal_header_id 
			WHERE 1 = 1 
				AND ced.curve_source_value_id = ''' + CAST(@price_curve_source AS VARCHAR) + '''
				AND ced.term_start >= ''' + CAST(@as_of_date AS VARCHAR) + ''''
		
		IF @counterparty_list IS NOT NULL--true always if flow is hERE
			SET @st_sql = @st_sql + ' AND ced.netting_counterparty_id IN (' + @counterparty_list + ')'
		IF @term_start IS NOT NULL 
			SET @st_sql = @st_sql + ' AND ced.term_start >= '''	+ CAST(@term_start AS VARCHAR) + ''''
		IF @term_end IS NOT NULL 
			SET @st_sql = @st_sql + ' AND ced.term_start <= ''' + CAST(@term_end AS VARCHAR) + ''''	
		END
			
		exec spa_print @st_sql
		EXEC(@st_sql)
		
		IF @@ROWCOUNT < 1
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps)
			SELECT @process_id, 'Error', @module, @source, 'PFE Calculation', 'Credit Exposure value not found for' + CASE WHEN @counterparty_name IS NULL THEN ' Any Counterparty' ELSE ' Counterparty : '
			+ @counterparty_name END + ' for as of date: ' + convert(varchar(10),@as_of_date,120), 'Please Run Credit Exposure'
			
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps)
			SELECT @process_id, 'Error', @module, @source, 'PFE Calculation', 'PFE Calculation done for' + CASE WHEN @name IS NULL THEN '' ELSE ' Criteria: '+ @hyperlink+ ';'
			END + '  <b>Total Counterparty Processed Count</b>: (' + CAST(@count_total AS VARCHAR) + ') <b>Error Count</b>: (' +
			CAST(@count_total AS VARCHAR) + ').', 'Please Run Credit Exposure'
								
			RAISERROR ('CatchError', 16, 1)
		END	
		
		EXEC ('CREATE INDEX ind_aaaa_33_'+ @process_id+' ON ' + @PFEProcessTableName + '([term_start], [netting_counterparty_id],[pnl_as_of_date]) INCLUDE ([net_exposure_to_us])')
		
		--Total number of missing as_of_date in simulated data
		--Setting up default value in case of NULL
		SELECT @total_available_date = COUNT(*) FROM #as_of_date_point
		SET @total_available_date = ISNULL(@total_available_date, 0)
		SET @total_count = ABS(@simulation_days - @total_available_date)
		
		--IF @counterparty_id IS NOT NULL 
		--	SET @count_total = 1 
		--ELSE 
		--	SELECT @count_total = COUNT(DISTINCT(netting_counterparty_id)) FROM credit_exposure_detail WHERE as_of_date = CAST(@as_of_date AS VARCHAR) AND curve_source_value_id = @price_curve_source
		  
		--Total available date should equal to @simulation_days
		IF (@total_available_date < @simulation_days)
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT @process_id,'Error', @module, @source, 'PFE Calculation', CAST(@total_count AS VARCHAR) + ' Credit Exposure simulation value(s) not found ' + 
			CASE WHEN @counterparty_name IS NOT NULL THEN 'for Counterparty: ' + @counterparty_name ELSE '' END +' 
			for As of Date: '+ convert(varchar(10),@as_of_date,120) + '.','Please check data.'
			
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps)
			SELECT @process_id, 'Error', @module, @source, 'PFE Calculation', 'PFE Calculation done for' + CASE WHEN @name IS NULL THEN '' ELSE ' Criteria: '+ @hyperlink+ ';'
			END + '  <b>Total Counterparty Processed Count</b>: (' + CAST(@count_total AS VARCHAR) + ') <b>Error Count</b>: (' +
			CAST(@count_total AS VARCHAR) + ').', 'Please Run Credit Exposure Simulation'
			
			RAISERROR ('CatchError', 16, 1)
		END
		IF OBJECT_ID('tempdb..##tmp_netting') IS not NULL
			drop table ##tmp_netting
		set @st_sql = 'SELECT DISTINCT netting_counterparty_id into ##tmp_netting FROM ' + @PFEProcessTableName + ''
		exec (@st_sql)
		create index ix_pt_netting1 on ##tmp_netting(netting_counterparty_id)
		--Inserting Simulated data into Process table 
		SET @st_sql = 'INSERT INTO ' + @PFEProcessTableName + '
			SELECT sdps.as_of_date,
				sdps.curve_source_value_id,
				sdps.Source_Deal_Header_ID,
				sdps.term_start,
				sdps.exp_type_id,
				sdps.netting_counterparty_id,
				sdps.counterparty_name,
				sdps.currency_name,
				sdps.net_exposure_to_us,
				NULL
			FROM source_deal_pfe_simulation' + CASE WHEN @calc_type = 'w' THEN '_whatif' ELSE '' END + ' sdps
			INNER JOIN #as_of_date_point aodp ON sdps.as_of_date = aodp.as_of_date
			INNER JOIN source_counterparty sc ON sdps.netting_counterparty_id = sc.source_counterparty_id
			INNER JOIN ##tmp_netting pfe ON sc.source_counterparty_id = pfe.netting_counterparty_id
			WHERE run_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
				AND sdps.as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + '''
				AND sdps.source_deal_header_id >= 0
				AND sdps.term_start >= ''' + CAST(@as_of_date AS VARCHAR) + ''''
		
		IF @term_start IS NOT NULL 
			SET @st_sql = @st_sql + ' AND sdps.term_start >= '''	+ CAST(@term_start AS VARCHAR) + ''''
		IF @term_end IS NOT NULL 
			SET @st_sql = @st_sql + ' AND sdps.term_start <= ''' + CAST(@term_end AS VARCHAR) + ''''
		
		IF @calc_type = 'w'
			SET @st_sql = @st_sql + '
			UNION ALL SELECT sdps.as_of_date,
				sdps.curve_source_value_id,
				sdps.Source_Deal_Header_ID,
				sdps.term_start,
				sdps.exp_type_id,
				sdps.netting_counterparty_id,
				sdps.counterparty_name,
				sdps.currency_name,
				sdps.net_exposure_to_us,
				NULL
			FROM source_deal_pfe_simulation' + CASE WHEN @calc_type = 'w' THEN '_whatif' ELSE '' END + ' sdps
			INNER JOIN #as_of_date_point aodp ON sdps.as_of_date = aodp.as_of_date
			INNER JOIN (SELECT source_deal_header_id FROM ' + @tbl_name + ' WHERE real_deal = ''n'') t ON sdps.source_deal_header_id = t.source_deal_header_id 
			INNER JOIN source_counterparty sc ON sdps.netting_counterparty_id = sc.source_counterparty_id
			INNER JOIN ##tmp_netting pfe ON sc.source_counterparty_id = pfe.netting_counterparty_id
			WHERE run_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
				AND sdps.as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + '''
				AND sdps.term_start >= ''' + CAST(@as_of_date AS VARCHAR) + ''''
				
		exec spa_print @st_sql
		EXEC(@st_sql)
		
		-- ######## Term wise pfe calculation start
		CREATE TABLE #pfe_results_term_wise(
					as_of_date DATETIME,
					term_start DATETIME,
					counterparty_id INT,
					criteria_id INT,
					measurement_approach INT,
					confidence_interval INT,
					fixed_exposure FLOAT,
					current_exposure FLOAT,
					pfe FLOAT,
					total_future_exposure FLOAT,
					currency_id INT
				)
			
		CREATE TABLE #term_wise_pnl(netting_counterparty_id INT, counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT , total_cnt INT, term_start DATETIME)
		SET @st_sql = '
		INSERT INTO #term_wise_pnl(netting_counterparty_id, counterparty_name, total_cnt, term_start)
		SELECT  distinct
			netting_counterparty_id,
 			counterparty_name,
			COUNT(DISTINCT pnl_as_of_date) ,
			term_start
		FROM ' + @PFEProcessTableName + ' 
		GROUP BY netting_counterparty_id, counterparty_name, term_start'
		
		exec spa_print @st_sql
		EXEC(@st_sql)
		
		SET @st_sql='SELECT * INTO ' + @PFEProcessTableNameNew + ' FROM ' +  @PFEProcessTableName
					
		exec spa_print @st_sql
		EXEC(@st_sql)
				
		--PFE holding period enhancement start		
		IF @hold_to_maturity = 'Y'
		BEGIN
			SET @st_sql='UPDATE ' + @PFEProcessTableName + ' SET     
						term_end = sdd.term_end 
						FROM ' + @PFEProcessTableName + ' pfe
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = pfe.source_deal_header_id
							AND pfe.term_start = sdd.term_start
							AND sdd.leg=''1'''
					
			exec spa_print @st_sql
			EXEC(@st_sql)
			
			SET @st_sql='UPDATE ' + @PFEProcessTableName + ' SET     
					net_exposure_to_us = net_exposure_to_us * SQRT(DATEDIFF(DAY, ''' + CAST(@as_of_date AS VARCHAR) + ''', term_end))'
					
			exec spa_print @st_sql
			EXEC(@st_sql)
--EXEC('SELECT * FROM ' + @PFEProcessTableNameNew)			
--EXEC('SELECT * FROM ' + @PFEProcessTableName)				
		END
		--PFE holding period enhancement end
		--EXEC('select * from ' + @PFEProcessTableNameNew)
		--EXEC('select * from ' + @PFEProcessTableName)
		-- ======= Term wise loop starts here
		
		DECLARE @term_start_pfe_cursor DATETIME
		DECLARE term_wise_pfe_cursor CURSOR FOR
		SELECT DISTINCT netting_counterparty_id, counterparty_name, term_start  FROM #term_wise_pnl WHERE total_cnt > @simulation_days	
		OPEN term_wise_pfe_cursor
		FETCH NEXT FROM term_wise_pfe_cursor INTO @netting_counterparty_id, @counterparty_name, @term_start_pfe_cursor
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			--Storing @current_pfe for @as_of_date and counterparty in a loop and exp_type_id IN (1,2)
			SELECT 
				@current_pfe = SUM(net_exposure_to_us) 
			FROM credit_exposure_detail 
			WHERE as_of_date = CAST(@as_of_date AS VARCHAR)
				AND netting_counterparty_id = @netting_counterparty_id
				AND term_start = @term_start_pfe_cursor
				AND curve_source_value_id = @price_curve_source
				AND exp_type_id IN (1,2)
			
			--Storing @fixed_exposure for @as_of_date, counterparty in a loop and exp_type_id IN (3,4,5,6,7,8)				
			SELECT 
				@fixed_exposure = ISNULL(SUM(net_exposure_to_us), 0) 
			FROM credit_exposure_detail 
			WHERE as_of_date = CAST(@as_of_date AS VARCHAR)
				AND netting_counterparty_id = @netting_counterparty_id
				AND curve_source_value_id = @price_curve_source
				AND term_start = @term_start_pfe_cursor
				AND exp_type_id IN (3,4,5,6,7,8)
			
			IF OBJECT_ID('tempdb..#term_wise_pfe_avg') IS NOT NULL
				DROP TABLE #term_wise_pfe_avg
					
			CREATE TABLE #term_wise_pfe_avg(term_start DATETIME, pnl_as_of_date DATETIME, net_exposure_to_us FLOAT)
			
			SET @st_sql = '
			INSERT INTO #term_wise_pfe_avg (term_start, pnl_as_of_date, net_exposure_to_us) 
			SELECT max(term_start),
					pnl_as_of_date, 
				SUM(net_exposure_to_us) 
			FROM ' + @PFEProcessTableName + ' 
			WHERE netting_counterparty_id = ''' + CAST(@netting_counterparty_id AS VARCHAR) + '''
				AND term_start = ''' + CAST(@term_start_pfe_cursor AS VARCHAR) + '''
				AND pnl_as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + '''
			GROUP BY pnl_as_of_date'
			
			exec spa_print @st_sql
			EXEC(@st_sql)

			IF OBJECT_ID('tempdb..#term_wise_ranked_pfe') IS NOT NULL
				DROP TABLE #term_wise_ranked_pfe
				
			CREATE TABLE #term_wise_ranked_pfe (
				pfe_rank INT, 
				pnl_as_of_date DATETIME,
				pfe FLOAT,
				pnl_currency_id INT
			)
			
			SET @st_sql = '
				INSERT INTO #term_wise_ranked_pfe (pfe_rank, pnl_as_of_date, pfe, pnl_currency_id)
				SELECT 
					ROW_NUMBER() OVER(order by pfe asc) rnk
					,pnl_as_of_date
					,pfe
					,pnl_currency_id
				FROM 
				(
				SELECT pnl_as_of_date, 
					SUM(net_exposure_to_us) pfe,
					MAX(cci.curreny_code) pnl_currency_id 
				FROM ' + @PFEProcessTableName + ' 
				LEFT JOIN counterparty_credit_info cci ON cci.Counterparty_id = netting_counterparty_id
				WHERE pnl_as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + ''' 
					AND netting_counterparty_id = ''' + CAST(@netting_counterparty_id AS VARCHAR) + '''
					AND term_start = ''' + CAST(@term_start_pfe_cursor AS VARCHAR) + '''
				GROUP BY pnl_as_of_date
				) pfe_sum'
				
			exec spa_print @st_sql
			EXEC(@st_sql)

			SELECT @confidence_level =
			CASE @confidence_interval 
				WHEN 1502 THEN .99
				WHEN 1503 THEN .9
				WHEN 1504 THEN .95
			 END 
			
			SET @K = (@confidence_level * @simulation_days ) --+ @confidence_level
			-----------------VaR
			SELECT @tmp_val1 = MAX(CASE WHEN pfe_rank = FLOOR(@k) THEN pfe ELSE NULL END),
				@tmp_val2 = MAX(CASE WHEN pfe_rank = CEILING(@k) THEN pfe ELSE NULL END)
			FROM #term_wise_ranked_pfe
			
			IF @tmp_val1 = @tmp_val2
				SET @VAR = @tmp_val1
			ELSE
			BEGIN
				SET @VAR =(@tmp_val2 * (@k - FLOOR(@k))) + (@tmp_val1 * (CEILING(@k) - @k))
			END
			
			--SELECT @VAR = @VAR + AVG(net_exposure_to_us) FROM #term_wise_pfe_avg

			--Multiply all the VAR results by SQRT(@holding_period) if @holding_period greater than '0'
			IF @holding_period > 0
			BEGIN
				SET @VAR = (@VAR * SQRT(@holding_period))
			END

			SELECT @pnl_currency_id = MAX(pnl_currency_id) FROM #term_wise_ranked_pfe WHERE pfe_rank BETWEEN FLOOR(@k) AND CEILING(@k)
			
			INSERT INTO #pfe_results_term_wise
			  (
			    as_of_date,
			    term_start,
			    counterparty_id,
			    criteria_id,
			    measurement_approach,
			    confidence_interval,
			    fixed_exposure,
			    current_exposure,
			    pfe,
			    total_future_exposure,
			    currency_id
			  )
			VALUES
			  (
			    @as_of_date,
			    @term_start_pfe_cursor,
			    @netting_counterparty_id,
			    @var_criteria_id,
			    @var_approach,
			    @confidence_interval,
			    @fixed_exposure,
			    @current_pfe,
			    ABS(@VAR),
			    (@fixed_exposure + ABS(@VAR)),
			    @pnl_currency_id
			  )
			
			
			
			FETCH NEXT FROM term_wise_pfe_cursor INTO @netting_counterparty_id, @counterparty_name, @term_start_pfe_cursor 
		END
		CLOSE term_wise_pfe_cursor
		DEALLOCATE  term_wise_pfe_cursor
		-- ======= Term wise loop ends here
		UPDATE prt
		SET prt.term_start = DATEADD(MONTH, DATEDIFF(MONTH, 0, prt.term_start), 0)
		FROM #pfe_results_term_wise prt
		
		IF @calc_type = 'w'
			DELETE prtw 
			FROM pfe_results_term_wise_whatif prtw 
			--INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_list) scsv ON scsv.item = prtw.counterparty_id
			WHERE prtw.as_of_date = CAST(@as_of_date AS VARCHAR) AND prtw.criteria_id = @whatif_criteria_id
		ELSE
			DELETE prt 
			FROM pfe_results_term_wise prt 
			--INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_list) scsv ON scsv.item = prt.counterparty_id
			WHERE prt.as_of_date = CAST(@as_of_date AS VARCHAR) 
				AND prt.criteria_id = @var_criteria_id
				AND prt.counterparty_id = CASE WHEN @counterparty_id IS NOT NULL THEN @counterparty_id ELSE prt.counterparty_id END
		
		IF @calc_type = 'w'
		BEGIN
			INSERT INTO pfe_results_term_wise_whatif (as_of_date,term_start,counterparty_id,criteria_id,measurement_approach
			,confidence_interval,fixed_exposure,current_exposure,pfe,total_future_exposure, currency_id)
			SELECT as_of_date, term_start, counterparty_id, ABS(criteria_id),
			       measurement_approach, confidence_interval, SUM(fixed_exposure),
			       SUM(current_exposure), SUM(pfe), SUM(total_future_exposure), MAX(currency_id)
			FROM #pfe_results_term_wise
			GROUP BY as_of_date, term_start, counterparty_id, criteria_id, measurement_approach, confidence_interval
		END
		ELSE
		BEGIN
			INSERT INTO pfe_results_term_wise (as_of_date, term_start, counterparty_id, criteria_id,
			       measurement_approach, confidence_interval, fixed_exposure,
			       current_exposure, pfe, total_future_exposure, currency_id)
			SELECT as_of_date, term_start, counterparty_id, criteria_id,
			       measurement_approach, confidence_interval, sum(fixed_exposure),
			       sum(current_exposure), sum(pfe), sum(total_future_exposure), MAX(currency_id)
			FROM #pfe_results_term_wise
			GROUP BY as_of_date, term_start, counterparty_id, criteria_id, measurement_approach, confidence_interval
		END
		-- ####### Term wise pfe calculation end
		
		
		CREATE TABLE #count_counterparty_val(netting_counterparty_id INT, counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT , total_cnt INT)
		SET @st_sql = '
		INSERT INTO #count_counterparty_val(netting_counterparty_id, counterparty_name, total_cnt)
		SELECT  
			netting_counterparty_id,
 			counterparty_name,
			COUNT(DISTINCT(pnl_as_of_date)) 
		FROM ' + @PFEProcessTableName + ' 
		GROUP BY netting_counterparty_id, counterparty_name'
		
		exec spa_print @st_sql
		EXEC(@st_sql)

		IF @calc_type = 'w'
			DELETE prw FROM pfe_results_whatif prw 
			--INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_list) scsv ON scsv.item = prw.counterparty_id
			WHERE prw.as_of_date = CAST(@as_of_date AS VARCHAR) 
				AND prw.criteria_id = @whatif_criteria_id
		ELSE
			DELETE pr FROM pfe_results pr 
			--INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_list) scsv ON scsv.item = pr.counterparty_id
			WHERE pr.as_of_date = CAST(@as_of_date AS VARCHAR) 
				AND pr.criteria_id = @var_criteria_id
				AND pr.counterparty_id = CASE WHEN @counterparty_id IS NOT NULL THEN @counterparty_id ELSE pr.counterparty_id END 					
			
		--Counterparty wise loop starts here
		DECLARE pfe_cursor CURSOR FOR
		SELECT DISTINCT netting_counterparty_id, counterparty_name FROM #count_counterparty_val WHERE total_cnt > @simulation_days	
		OPEN pfe_cursor
		FETCH NEXT FROM pfe_cursor INTO @netting_counterparty_id, @counterparty_name
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			--Storing @current_pfe for @as_of_date and counterparty in a loop and exp_type_id IN (1,2)
			SELECT 
				@current_pfe = SUM(net_exposure_to_us) 
			FROM credit_exposure_detail 
			WHERE as_of_date = CAST(@as_of_date AS VARCHAR)
				AND netting_counterparty_id = @netting_counterparty_id
				AND term_start BETWEEN 
					CASE WHEN @term_start IS NOT NULL THEN @term_start ELSE term_start END 
					AND 
					CASE WHEN @term_end IS NOT NULL THEN @term_end ELSE term_start END
				AND exp_type_id IN (1,2)
				AND curve_source_value_id = @price_curve_source
			
			--Storing @fixed_exposure for @as_of_date, counterparty in a loop and exp_type_id IN (3,4,5,6,7,8)				
			SELECT 
				@fixed_exposure = ISNULL(SUM(net_exposure_to_us), 0) 
			FROM credit_exposure_detail 
			WHERE as_of_date = CAST(@as_of_date AS VARCHAR)
				AND netting_counterparty_id = @netting_counterparty_id
				AND exp_type_id IN (3,4,5,6,7,8)
			
			IF OBJECT_ID('tempdb..#tmp_pfe_avg') IS NOT NULL
				DROP TABLE #tmp_pfe_avg
					
			CREATE TABLE #tmp_pfe_avg(pnl_as_of_date DATETIME, net_exposure_to_us FLOAT)
			
			SET @st_sql = '
				INSERT INTO #tmp_pfe_avg (pnl_as_of_date, net_exposure_to_us) 
				SELECT pnl_as_of_date, 
					SUM(net_exposure_to_us) 
				FROM ' + @PFEProcessTableName + ' 
				WHERE netting_counterparty_id = ''' + CAST(@netting_counterparty_id AS VARCHAR) + '''
					AND pnl_as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + '''
				GROUP BY pnl_as_of_date'
			
			exec spa_print @st_sql
			EXEC(@st_sql)
			
			IF OBJECT_ID('tempdb..#ranked_pfe') IS NOT NULL
				DROP TABLE #ranked_pfe
				
			CREATE TABLE #ranked_pfe (
				pfe_rank INT, 
				as_of_date DATETIME,
				pfe FLOAT,
				pnl_currency_id INT
			)
			
			SET @st_sql = '
				INSERT INTO #ranked_pfe (pfe_rank, as_of_date, pfe, pnl_currency_id)
				SELECT 
					ROW_NUMBER() OVER(order by pfe asc) rnk
					,pnl_as_of_date
					,pfe
					,pnl_currency_id
				FROM 
				(
				SELECT pnl_as_of_date, 
					SUM(net_exposure_to_us) pfe,
					MAX(cci.curreny_code) pnl_currency_id 
				FROM ' + @PFEProcessTableName + ' 
				LEFT JOIN counterparty_credit_info cci ON cci.Counterparty_id = netting_counterparty_id
				WHERE pnl_as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + ''' 
					AND netting_counterparty_id = ''' + CAST(@netting_counterparty_id AS VARCHAR) + '''
				GROUP BY pnl_as_of_date  
				) pfe_sum'
				
			exec spa_print @st_sql
			EXEC(@st_sql)
 
			SELECT @confidence_level =
			CASE @confidence_interval 
				WHEN 1502 THEN .99
				WHEN 1503 THEN .9
				WHEN 1504 THEN .95
			 END 
			
			SET @K = (@confidence_level * @simulation_days ) --+ @confidence_level
			-----------------VaR
			SELECT @tmp_val1 = MAX(CASE WHEN pfe_rank = FLOOR(@k) THEN pfe ELSE NULL END),
				@tmp_val2 = MAX(CASE WHEN pfe_rank = CEILING(@k) THEN pfe ELSE NULL END)
			FROM #ranked_pfe
			
			IF @tmp_val1 = @tmp_val2
				SET @VAR = @tmp_val1
			ELSE
			BEGIN
				SET @VAR =(@tmp_val2 * (@k - FLOOR(@k))) + (@tmp_val1 * (CEILING(@k) - @k))
			END

			--Multiply all the VAR results by SQRT(@holding_period) if @holding_period greater than '0'
			IF @holding_period > 0
			BEGIN
				SET @VAR = (@VAR * SQRT(@holding_period))
			END

			SELECT @pnl_currency_id = MAX(pnl_currency_id) FROM #ranked_pfe WHERE pfe_rank BETWEEN FLOOR(@k) AND CEILING(@k)
			-- storeing pfe results seperate for whatif and at risk
			IF @calc_type = 'w'
			BEGIN
				INSERT INTO pfe_results_whatif
				(
					as_of_date,
					counterparty_id,
					counterparty,
					criteria_id,
					criteria_name,
					measurement_approach,
					confidence_interval,
					fixed_exposure,
					current_exposure,
					pfe,
					total_future_exposure,
					currency_id
				)
				VALUES
				(
					@as_of_date,
					@netting_counterparty_id,
					@counterparty_name,
					@whatif_criteria_id,
					@criteria_name,
					@var_approach,
					@confidence_interval,
					@fixed_exposure,
					@current_pfe,
					ABS(@VAR),
					(@fixed_exposure + ABS(@VAR)),
					@pnl_currency_id
				)
			END
			ELSE
			BEGIN
				INSERT INTO pfe_results
				(
					as_of_date,
					counterparty_id,
					counterparty,
					criteria_id,
					criteria_name,
					measurement_approach,
					confidence_interval,
					fixed_exposure,
					current_exposure,
					pfe,
					total_future_exposure,
					currency_id
				)
				VALUES
				(
					@as_of_date,
					@netting_counterparty_id,
					@counterparty_name,
					@var_criteria_id,
					@criteria_name,
					@var_approach,
					@confidence_interval,
					@fixed_exposure,
					@current_pfe,
					ABS(@VAR),
					(@fixed_exposure + ABS(@VAR)),
					@pnl_currency_id
				)
			END
			
			--plotting feature start here ---	
			--FNANormDist(@value FLOAT, @mean FLOAT, @sigma FLOAT, @cummulative BIT)
			IF ABS(@VAR) <> 0
			BEGIN
				DELETE FROM #tmp_curse
			
				SET @st_sql = '
					INSERT INTO #tmp_curse(as_of_date, und_pnl, counterparty_id)
					SELECT  
						pnl_as_of_date, 
						SUM(net_exposure_to_us),
						netting_counterparty_id
					FROM ' + @PFEProcessTableName + '
					WHERE netting_counterparty_id = ''' + CAST(@netting_counterparty_id AS VARCHAR) + '''
						AND pnl_as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + '''
					GROUP BY pnl_as_of_date, netting_counterparty_id'
				
				exec spa_print @st_sql		
				EXEC(@st_sql)
				
				SELECT @mean_value = AVG(und_pnl), @standard_dev = STDEV(und_pnl) FROM #tmp_curse 
				
				-- seperate table storing for whatif and risk for probability density value
				IF @calc_type = 'w'
				BEGIN
					SET @st_sql = '
						DELETE vpdw
						FROM [dbo].[var_probability_density_whatif] vpdw
						WHERE 1=1 
							AND vpdw.whatif_criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '
							AND vpdw.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
							AND vpdw.measure = ' + CAST(@measure AS VARCHAR) + 
						CASE WHEN @netting_counterparty_id IS NOT NULL THEN ' 
							AND vpdw.counterparty = ''' + CAST(@netting_counterparty_id AS VARCHAR) + ''''
						ELSE  '' 
						END
					exec spa_print @st_sql		
					EXEC(@st_sql)
					
					SET @st_sql = '
						INSERT INTO var_probability_density_whatif(
							whatif_criteria_id,
							as_of_date,
							counterparty,
							mtm_value,
							probab_den,
							measure,
							create_user,
							create_ts,
							update_user,
							update_ts
						)
						SELECT ' + CAST(@whatif_criteria_id AS VARCHAR) + ', 
							''' + CAST(@as_of_date AS VARCHAR) + ''',
							counterparty_id, 
							und_pnl, 
							dbo.FNANormDist(und_pnl, ' + CONVERT(VARCHAR(100), @mean_value, 2) + ', ' + CONVERT(VARCHAR(100), @standard_dev, 2) + ', 0) probab_den,
							' + CAST(@measure AS VARCHAR) + ',
							dbo.FNADBUser(),
							getdate(),
							dbo.FNADBUser(),
							getdate()
						FROM 
							#tmp_curse
						WHERE counterparty_id = ''' + CAST(@netting_counterparty_id AS VARCHAR) + '''	
						ORDER BY as_of_date'
						
					exec spa_print @st_sql
					EXEC (@st_sql)
					
				END
				ELSE
				BEGIN
					SET @st_sql = '
						DELETE [dbo].[var_probability_density] 
						FROM [dbo].[var_probability_density] vpd
						WHERE 1=1 
							AND vpd.var_criteria_id = ' + CAST(@var_criteria_id AS VARCHAR) + '
							AND vpd.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
							AND vpd.counterparty = ''' + CAST(@netting_counterparty_id AS VARCHAR) + ''''	
							
					exec spa_print @st_sql		
					EXEC(@st_sql)
				
					SET @st_sql = '
						INSERT INTO var_probability_density(
							var_criteria_id,
							as_of_date,
							counterparty,
							mtm_value,
							probab_den,
							create_user,
							create_ts,
							update_user,
							update_ts
						)
						SELECT ' + CAST(@var_criteria_id AS VARCHAR) + ', 
							''' + CAST(@as_of_date AS VARCHAR) + ''',
							counterparty_id, 
							und_pnl, 
							dbo.FNANormDist(und_pnl, ' + CONVERT(VARCHAR(100), @mean_value, 2) + ', ' + CONVERT(VARCHAR(100), @standard_dev, 2) + ', 0) probab_den,
							dbo.FNADBUser(),
							getdate(),
							dbo.FNADBUser(),
							getdate()
						FROM 
							#tmp_curse
						WHERE counterparty_id = ''' + CAST(@netting_counterparty_id AS VARCHAR) + '''	
						ORDER BY as_of_date'
						
					exec spa_print @st_sql
					EXEC (@st_sql)
				END
			END
			--End of Plotting
			FETCH NEXT FROM pfe_cursor INTO @netting_counterparty_id, @counterparty_name 
		END
		CLOSE pfe_cursor
		DEALLOCATE  pfe_cursor
		--End of Loop
		
		--Deleting existing exposure for hypothetical deals
		DELETE 
			credit_exposure_detail 
		FROM credit_exposure_detail ced
		WHERE ced.source_deal_header_id < 0
		-- seperate pfe data store for whatif and at risk.
		IF @calc_type = 'w'
		BEGIN
			SET @st_sql = '
				DELETE [dbo].[mtm_pfe_simulation_whatif] 
				FROM [dbo].[mtm_pfe_simulation_whatif] m
				INNER JOIN ' + @PFEProcessTableName + ' tmp on m.as_of_date = tmp.pnl_as_of_date
					AND m.whatif_criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR)
				
			exec spa_print @st_sql	
			EXEC(@st_sql)
			
			SET @st_sql = '
				INSERT into	[dbo].[mtm_pfe_simulation_whatif]
				   ([as_of_date]
				   ,[whatif_criteria_id]
				   ,term
				   ,source_deal_header_id 
				   ,pfe 
	   			   ,pfe_c 
				   ,pfe_i
				   ,counterparty_id 
				   ,[create_user]
				   ,[create_ts] 
				)	
				SELECT pnl_as_of_date,
					MAX(' + CAST(@whatif_criteria_id AS VARCHAR) + '),
					term_start,
					source_deal_header_id,
					SUM(net_exposure_to_us) mtm,
					0,
					0,
					netting_counterparty_id,
					max(dbo.FNADBUser()) usr,
					GETDATE() 
				FROM ' + @PFEProcessTableName + ' 
				GROUP BY pnl_as_of_date, term_start, source_deal_header_id, netting_counterparty_id'
				
			exec spa_print @st_sql
			EXEC (@st_sql)
		END
		ELSE
		BEGIN
			SET @st_sql = '
				DELETE [dbo].[mtm_var_simulation] 
				FROM [dbo].[mtm_var_simulation] m
				INNER JOIN ' + @PFEProcessTableName + ' tmp on m.as_of_date = tmp.pnl_as_of_date
					AND m.var_criteria_id = ' + CAST(@var_criteria_id AS VARCHAR)
				
			exec spa_print @st_sql	
			EXEC(@st_sql)
			
			SET @st_sql = '
				INSERT into	[dbo].[mtm_var_simulation]
				   ([as_of_date]
				   ,[var_criteria_id]
				   ,term
				   ,source_deal_header_id 
				   ,mtm_value 
		   		   ,mtm_value_C 
				   ,mtm_value_I
				   ,counterparty_id 
				   ,[create_user]
				   ,[create_ts] 
				)	
				SELECT pnl_as_of_date,
					MAX(' + CAST(@var_criteria_id AS VARCHAR) + '),
					term_start,
					source_deal_header_id,
					SUM(net_exposure_to_us) mtm,
					0,
					0,
					netting_counterparty_id,
					max(dbo.FNADBUser()) usr,
					GETDATE() 
				FROM ' + @PFEProcessTableName + ' 
				GROUP BY pnl_as_of_date, term_start, source_deal_header_id, netting_counterparty_id'
				
			exec spa_print @st_sql
			EXEC (@st_sql)
		
		END
		
		SELECT @count_total = COUNT(DISTINCT(netting_counterparty_id)) FROM #count_counterparty_val
		SELECT @count_fail = COUNT(DISTINCT(netting_counterparty_id)) FROM #count_counterparty_val WHERE total_cnt <= @simulation_days
		
		IF EXISTS(SELECT total_cnt FROM #count_counterparty_val WHERE total_cnt <= @simulation_days)
		BEGIN 
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps)
			SELECT @process_id, 'Error', @module, @source, 'PFE Calculation', 'Credit Exposure simulation value not found for Counterparty: ' 
			+ counterparty_name + ' As of Date: ' + convert(varchar(10),@as_of_date,120), 'Please Run Credit Exposure' 
			FROM #count_counterparty_val
			WHERE total_cnt <= @simulation_days	
		END 
		
		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps)
		SELECT @process_id, 
			CASE WHEN @calc_type = 'w' THEN
				CASE WHEN @count_fail = @count_total THEN 'Error' WHEN @count_fail= 0 THEN 'Success' ELSE 'Warning' END
			ELSE 
				CASE WHEN @count_fail > 0 THEN 'Error' ELSE 'Success' END
			END, 
			@module, @source, 'PFE Calculation', 'PFE Calculation done for' + CASE WHEN @name IS NULL THEN '' ELSE ' Criteria: '
			+ @hyperlink+ ';'
			END + CASE WHEN @count_fail = 0 THEN ' As of Date:' + convert(varchar(10),@as_of_date,120) ELSE '' END +
		'  <b>Total Counterparty Processed Count</b>: (' + CAST(@count_total AS VARCHAR) + ') <b>Error Count</b>: (' +
		 CAST(@count_fail AS VARCHAR) + ').', 'Please Run Credit Exposure'
		
		SET @is_warning = 'y'
		
		EXEC spa_print 'Finish Simulation PFE Calculation'
		
		SET @desc = CASE WHEN @calc_type = 'w' THEN NULL ELSE 'PFE Results' END
		SET @errorcode = 's'
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
					'&spa=exec spa_get_VaR_report ''v'',null,null,''' + CAST(YEAR(@as_of_date) AS VARCHAR) + '-' + CAST(MONTH(@as_of_date) AS VARCHAR) + '-' + CAST(DAY(@as_of_date) AS VARCHAR) +''',' + CAST(@var_criteria_id AS VARCHAR) + ', null, null, null' + CASE WHEN @counterparty_id IS NOT NULL THEN ', ' + CAST(@counterparty_id AS VARCHAR(20)) ELSE '' END

		EXEC spa_print @errorcode
		EXEC spa_print @process_id
	
	END		
	
	--End of PFE calculation 
	--Start	of VAR, CFaR, Ear Calculation 
	ELSE
	BEGIN
		DECLARE @subValueMtm FLOAT, @subValueMtmC FLOAT,@subValueMtmI FLOAT
		IF @measure IN(17352, 17353) 
		BEGIN
			IF  @call_to = 'o'
			BEGIN
				CREATE TABLE #tmp_summary_mtm(mtm FLOAT, mtmc FLOAT, mtmi FLOAT)
				SET @st_sql = 'INSERT INTO #tmp_summary_mtm(mtm, mtmc, mtmi)
					SELECT 
						SUM(und_pnl), 
						SUM(MTMC), SUM(MTMI) 
					FROM ' + @MTMProcessTableName + ' 
					WHERE pnl_as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + '''
					GROUP BY pnl_as_of_date'
				
				exec spa_print @st_sql	 
				EXEC(@st_sql)
				
				SELECT @subValueMtm = AVG(MTM), @subValueMtmC = AVG(MTMC), @subValueMtmI = AVG(MTMI) FROM #tmp_summary_mtm	
			END
			ELSE
				SELECT @subValueMtm = SUM(und_pnl_set), @subValueMtmC = SUM(MTMC), @subValueMtmI = SUM(MTMI) FROM #tmp_term
		END
		ELSE
		BEGIN
			SELECT @subValueMtm = SUM(MTM), @subValueMtmC = SUM(MTMC), @subValueMtmI = SUM(MTMI) FROM #tmp_term
		END	
			
		CREATE TABLE #ranked_mtm (
			mtm_rank INT, 
			mtmc_rank INT, 
			mtmi_rank INT,
			as_of_date DATETIME,
			mtm FLOAT,
			mtmi FLOAT,
			mtmc FLOAT,
			pnl_currency_id INT
		)
		
		--GMaR calculation logic starts here
		IF @measure = 17357
		BEGIN
			IF OBJECT_ID('tempdb..#MTMProcessTableName') IS NOT NULL
				DROP TABLE #MTMProcessTableName
				
			CREATE TABLE #MTMProcessTableName(run_date DATETIME, 
						 pnl_as_of_date DATETIME, 
						 source_deal_header_id INT,
						 term_start DATETIME,
						 und_pnl FLOAT,
						 pnl_currency_id INT,
						 MTMC FLOAT,
						 MTMI FLOAT) 
			
			SET @st_sql = 'INSERT INTO #MTMProcessTableName(run_date, pnl_as_of_date, source_deal_header_id, term_start, und_pnl, pnl_currency_id)
				SELECT ''' + CAST(@as_of_date AS VARCHAR) + ''', pnl_as_of_date, source_deal_header_id, term_start, und_pnl, pnl_currency_id FROM ' + @MTMProcessTableName
			
			exec spa_print @st_sql
			EXEC(@st_sql)
		
			--Colleting necessary information to join with pnl table
			IF OBJECT_ID('tempdb..#tmpDeals') IS NOT NULL
				DROP TABLE #tmpDeals
				
			CREATE TABLE #tmpDeals(as_of_date DATETIME, source_deal_header_id INT, term_start DATETIME, leg BIT)
			
			SET @st_sql = 'INSERT INTO #tmpDeals
				SELECT DISTINCT ''' + CAST(@as_of_date AS VARCHAR) + ''', source_deal_header_id, term_start, leg FROM ' + @MTMProcessTableName

			EXEC(@st_sql)
		
			IF OBJECT_ID('tempdb..#source_deal_pnl') IS NOT NULL
				DROP TABLE #source_deal_pnl
			IF OBJECT_ID('tempdb..#total_margin') IS NOT NULL
				DROP TABLE #total_margin
			IF OBJECT_ID('tempdb..#positive_cf_info') IS NOT NULL
				DROP TABLE #positive_cf_info
			IF OBJECT_ID('tempdb..#positive_margin') IS NOT NULL
				DROP TABLE #positive_margin
			IF OBJECT_ID('tempdb..#gross_margin') IS NOT NULL
				DROP TABLE #gross_margin
			IF OBJECT_ID('tempdb..#MTMProcessTableNameFinal') IS NOT NULL
				DROP TABLE #MTMProcessTableNameFinal	
			
			CREATE TABLE #source_deal_pnl(source_deal_header_id INT, term_start DATETIME, und_pnl_set FLOAT)
			
			SET @st_sql = '	
				INSERT INTO #source_deal_pnl
				SELECT sdp.source_deal_header_id, sdp.term_start, sdp.und_pnl_set
				FROM #tmpDeals td
				INNER JOIN source_deal_pnl' + CASE WHEN @calc_type = 'w' THEN '_whatif' ELSE '' END + ' sdp ON sdp.source_deal_header_id = td.source_deal_header_id
					AND sdp.term_start = td.term_start
					AND sdp.Leg = td.leg
					AND sdp.pnl_as_of_date = td.as_of_date' +
					CASE WHEN @calc_type = 'w' THEN ' AND sdp.criteria_id =' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END					
					
			EXEC(@st_sql)

			DECLARE 
				@positive_cashflow FLOAT,	
				@negative_cashflow FLOAT,	
				@total_cashflow FLOAT,	
				@gross_margin FLOAT
			
			SELECT @positive_cashflow = positive_cashflow, 
				@negative_cashflow = negative_cashflow, 
				@total_cashflow = (positive_cashflow+negative_cashflow), 
				@gross_margin = (positive_cashflow+negative_cashflow)/CASE WHEN positive_cashflow = 0 THEN 1 ELSE positive_cashflow END
			FROM(	
				SELECT
					SUM(CASE WHEN sdp.und_pnl_set >= 0 THEN sdp.und_pnl_set ELSE 0 END) AS positive_cashflow, 
					SUM(CASE WHEN sdp.und_pnl_set < 0 THEN sdp.und_pnl_set ELSE 0 END) AS negative_cashflow
				FROM #source_deal_pnl sdp) tt
			
			
			IF (@negative_cashflow = 0 OR @positive_cashflow = 0) 
			BEGIN
				EXEC spa_message_board 'i', @user_name, NULL, 'Warning', 'Revenue/Cost not found to calculate GMaR for the criteria.', NULL, '', @errorcode, 
				'', NULL, @process_id
				
				RETURN	
			END
							
			SELECT run_date, 
				pnl_as_of_date,
				MAX(pnl_currency_id) AS pnl_currency_id,
				(@total_cashflow+SUM(und_pnl)) AS simulated_margin,
				SUM(MTMC) AS MTMC,
				SUM(MTMI) AS MTMI 
			INTO #total_margin 
			FROM #MTMProcessTableName
			GROUP BY run_date, pnl_as_of_date
			order by pnl_as_of_date
			
			SELECT DISTINCT source_deal_header_id, term_start INTO #positive_cf_info FROM #source_deal_pnl WHERE und_pnl_set >= 0

			SELECT run_date, pnl_as_of_date, (@positive_cashflow+SUM(und_pnl)) AS simulated_margin 
			INTO #positive_margin 
			FROM #MTMProcessTableName cdv
			INNER JOIN #positive_cf_info pci ON pci.source_deal_header_id = cdv.source_deal_header_id
				AND pci.term_start = cdv.term_start 
			GROUP BY run_date, pnl_as_of_date

			SELECT tm.run_date, tm.pnl_as_of_date, tm.pnl_currency_id, (tm.simulated_margin/pm.simulated_margin) AS gross_margin, mtmc, mtmi
			INTO #gross_margin 
			FROM #total_margin tm
			INNER JOIN #positive_margin pm ON pm.pnl_as_of_date = tm.pnl_as_of_date
				AND pm.run_date = tm.run_date

			SELECT run_date, pnl_as_of_date, pnl_currency_id, (@gross_margin-gross_margin) AS und_pnl, mtmc, mtmi
			INTO #MTMProcessTableNameFinal
			FROM #gross_margin 
			ORDER BY pnl_as_of_date
 --RETURN

		END
		
		SET @st_sql = '
			INSERT INTO #ranked_mtm (mtm_rank, mtmc_rank, mtmi_rank, as_of_date, mtm,mtmc, mtmi, pnl_currency_id)
			SELECT 
				ROW_NUMBER() OVER ( order by mtm asc) rnk
				,ROW_NUMBER() OVER ( order by mtmc asc) rnkc
				,ROW_NUMBER() OVER ( order by mtmi asc) rnki
				,pnl_as_of_date
				,mtm
				,mtmc
				,mtmi
				,pnl_currency_id
			FROM 
				(
				SELECT pnl_as_of_date,
				' + CASE WHEN @call_to = 'O' THEN '
					(SUM(und_pnl) - (' + CONVERT(VARCHAR(100), @subValueMtm, 2) + ')) mtm, 
					(SUM(MTMC) - (' + CONVERT(VARCHAR(100), @subValueMtmC, 2) + ')) mtmc, 
					(SUM(MTMI) - (' + CONVERT(VARCHAR(100), @subValueMtmI, 2) + ')) mtmi,
				'  ELSE '
					SUM(und_pnl)  mtm, 
					SUM(MTMC) mtmc, 
					SUM(MTMI) mtmi, ' END + '	
					max(pnl_currency_id) pnl_currency_id 
				FROM ' + CASE WHEN @measure = 17357 THEN '#MTMProcessTableNameFinal' ELSE @MTMProcessTableName END + ' 
				WHERE pnl_as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + ''' 
				GROUP BY pnl_as_of_date  
				) mtm_sum'
				
		exec spa_print @st_sql
		EXEC(@st_sql)

		SELECT @confidence_level =
		CASE @confidence_interval 
				WHEN 1502 THEN .99	  --WHEN 1502 THEN 2.33
				WHEN 1503 THEN .9	  --WHEN 1503 THEN 1.28
				WHEN 1504 THEN .95	  --WHEN 1504 THEN 1.65
		  END
		
		SET @K = ((1 - @confidence_level) * @simulation_days ) --+ @confidence_level

		-----------------VaR
		SELECT @tmp_val1 = MAX(CASE WHEN mtm_rank = FLOOR(@k) THEN mtm ELSE NULL END)
			,@tmp_val2 = MAX(CASE WHEN mtm_rank = CEILING(@k) THEN mtm ELSE NULL END)
		FROM #ranked_mtm
		
		IF @tmp_val1 = @tmp_val2
			SET @VAR = @tmp_val1
		ELSE
		BEGIN
			SET @VAR =(@tmp_val2 * (@k - FLOOR(@k))) + (@tmp_val1 * (CEILING(@k) - @k))
		END
		----------------VaRC
		SELECT @tmp_val1 = MAX(CASE WHEN mtmc_rank = FLOOR(@k) THEN mtmc ELSE NULL END)
			,@tmp_val2 = MAX(CASE WHEN mtmc_rank = CEILING(@k) THEN mtmc ELSE NULL END)
		FROM #ranked_mtm
		
		IF @tmp_val1 = @tmp_val2
			SET @VAR_C = @tmp_val1
		ELSE
		BEGIN
			SET @VAR_C = (@tmp_val2 * (@k - FLOOR(@k))) + (@tmp_val1 * (CEILING(@k) - @k))
		END
		
		---------------VaRI
		SELECT @tmp_val1 = MAX(CASE WHEN mtmi_rank = FLOOR(@k) THEN mtmi ELSE NULL END)
			,@tmp_val2 = MAX(CASE WHEN mtmi_rank = CEILING(@k) THEN mtmi ELSE NULL END)
		FROM #ranked_mtm
		
	 	
		IF @tmp_val1 = @tmp_val2
			SET @VAR_I = @tmp_val1
		ELSE
			SET @VAR_I =(@tmp_val2 * (@k - FLOOR(@k))) + (@tmp_val1 * (CEILING(@k) - @k))
		
		--Multiply all the VAR results by SQRT(@holding_period) if @holding_period greater than '0'
		IF @holding_period > 0
		BEGIN
			SET @VAR = (@VAR * SQRT(@holding_period))
			SET @VAR_C = (@VAR_C * SQRT(@holding_period))		
			SET @VAR_I = (@VAR_I * SQRT(@holding_period))	
		END
	
		IF ABS(@VAR) > 0
		SELECT  @RAROC = @subValueMtm / @VAR, @RAROC_I = @subValueMtm / @VAR_I --FROM #tmp_term
		SELECT @pnl_currency_id = MAX(pnl_currency_id) FROM #ranked_mtm WHERE mtm_rank BETWEEN FLOOR(@k) AND CEILING(@k)
	
			------saving VaR result
		EXEC spa_print '------saving VaR result'
		
		IF @calc_type = 'w'
		BEGIN
			IF @measure = 17351
			BEGIN
				SET @st_sql = '
					DELETE [var_results_whatif] 
					WHERE [as_of_date] = ''' + CONVERT (VARCHAR(10), @as_of_date,120) + ''' 
						AND whatif_criteria_id = '+ CAST (@whatif_criteria_id AS VARCHAR) 
						
				exec spa_print @st_sql		
				EXEC(@st_sql)
			
				INSERT INTO [dbo].[var_results_whatif]
				   (whatif_criteria_id
				   ,[as_of_date]
				   ,[var_criteria_id]
				   ,[VAR]
				   ,[VaRC]
				   ,[VaRI]
				   ,[RAROC1]
				   ,[RAROC2]
				   ,[create_user]
				   ,[create_ts]
				   ,[currency_id])
				 VALUES
				   (@whatif_criteria_id
				   ,@as_of_date
				   ,@var_criteria_id
				   ,ABS(@VAR)
				   ,ABS(@VAR_C)
				   ,ABS(@VAR_I)
				   ,ABS(@RAROC)
				   ,ABS(@RAROC_I)
				   ,dbo.FNADBUser(), GETDATE()
				   ,@pnl_currency_id
				   )
			END	   
			ELSE IF @measure = 17352
			BEGIN
				SET @st_sql = '
					DELETE [cfar_results_whatif] 
					WHERE [as_of_date] = ''' + CONVERT (VARCHAR(10), @as_of_date,120) + ''' 
						AND whatif_criteria_id = ' + CAST (@whatif_criteria_id AS VARCHAR)
								
				exec spa_print @st_sql		
				EXEC(@st_sql)
				
				INSERT INTO [dbo].[cfar_results_whatif]
				   (whatif_criteria_id
				   ,[as_of_date]
				   ,[var_criteria_id]
				   ,[cfar]
				   ,[currency_id]
				   ,[create_user]
				   ,[create_ts])
				 VALUES
				   (@whatif_criteria_id
				   ,@as_of_date
				   ,@var_criteria_id
				   ,ABS(@VAR)
				   ,@pnl_currency_id
				   ,dbo.FNADBUser()
				   ,GETDATE()
				   )
			END
			ELSE IF @measure = 17353
			BEGIN
				SET @st_sql = '
					DELETE [ear_results_whatif] 
					WHERE [as_of_date] = ''' + CONVERT (VARCHAR(10), @as_of_date,120) + ''' 
						AND whatif_criteria_id = ' + CAST (@whatif_criteria_id AS VARCHAR)
								
				exec spa_print @st_sql		
				EXEC(@st_sql)
				
				INSERT INTO [dbo].[ear_results_whatif]
				   (whatif_criteria_id
				   ,[as_of_date]
				   ,[var_criteria_id]
				   ,[ear]
				   ,[currency_id]
				   ,[create_user]
				   ,[create_ts])
				 VALUES
				   (@whatif_criteria_id
				   ,@as_of_date
				   ,@var_criteria_id
				   ,ABS(@VAR)
				   ,@pnl_currency_id
				   ,dbo.FNADBUser()
				   ,GETDATE()
				   )
			END	
			
			ELSE IF @measure = 17357 AND ABS(@VAR) <> 0
			BEGIN
				SET @st_sql = '
					DELETE [gmar_results_whatif] 
					WHERE [as_of_date] = ''' + CONVERT (VARCHAR(10), @as_of_date,120) + ''' 
						AND whatif_criteria_id = ' + CAST (@whatif_criteria_id AS VARCHAR)
								
				exec spa_print @st_sql		
				EXEC(@st_sql)
				
				INSERT INTO [dbo].[gmar_results_whatif]
				   (whatif_criteria_id,
					as_of_date,
					positive_cashflow,
					negative_cashflow,
					total_cashflow,
					gross_margin,
					GMaR,
					currency_id,
					create_user,
					create_ts)
				 VALUES
				   (@whatif_criteria_id,
					@as_of_date,
					@positive_cashflow,
					@negative_cashflow,
					@total_cashflow,
					@gross_margin,
					ABS(@VAR),
					@pnl_currency_id,
				    dbo.FNADBUser(),
				    GETDATE()
				   )
			END	   
		END 
		ELSE
		BEGIN
			IF @measure = 17357 AND ABS(@VAR) <> 0
			BEGIN
				SET @st_sql = '
					DELETE [gmar_results] 
					WHERE [as_of_date] = ''' + CONVERT (VARCHAR(10), @as_of_date,120) + ''' 
						AND criteria_id = ' + CAST (@var_criteria_id AS VARCHAR)
								
				exec spa_print @st_sql		
				EXEC(@st_sql)
				
				INSERT INTO [dbo].[gmar_results]
				   (criteria_id,
					as_of_date,
					positive_cashflow,
					negative_cashflow,
					total_cashflow,
					gross_margin,
					GMaR,
					currency_id,
					create_user,
					create_ts)
				 VALUES
				   (@var_criteria_id,
					@as_of_date,
					@positive_cashflow,
					@negative_cashflow,
					@total_cashflow,
					@gross_margin,
					ABS(@VAR),
					@pnl_currency_id,
				    dbo.FNADBUser(),
				    GETDATE()
				   )
			END
			ELSE
				BEGIN
					SET @st_sql = '
					DELETE [var_results] 
					WHERE [as_of_date] = ''' + CONVERT (VARCHAR(10), @as_of_date,120) + ''' 
						AND var_criteria_id = ' + CAST (@var_criteria_id AS VARCHAR)
				exec spa_print @st_sql		
				EXEC(@st_sql)
			
				INSERT INTO [dbo].[var_results]
						([as_of_date]
						,[var_criteria_id]
						,[VAR]
						,[VaRC]
						,[VaRI]
						,[RAROC1]
						,[RAROC2]
						,[create_user]
						,[create_ts]
						,[currency_id])
					VALUES
						(@as_of_date
						,@var_criteria_id
						,ABS(@VAR)
						,ABS(@VAR_C)
						,ABS(@VAR_I)
						,ABS(@RAROC)
						,ABS(@RAROC_I)
						,dbo.FNADBUser()
						,GETDATE()
						,@pnl_currency_id
						)
			END
		END	
		--plotting feature start here ---	
		--FNANormDist(@value FLOAT, @mean FLOAT, @sigma FLOAT, @cummulative BIT)
		--Start Enhancement 
		--Updating changed mtm to original mtm using new approach 
		IF @call_to = 'n'
		BEGIN
		
		IF OBJECT_ID('tempdb..#tmp_tt') IS not NULL
			drop table #tmp_tt
		IF OBJECT_ID('tempdb..##tmp_tt2') IS not NULL
			drop table ##tmp_tt2	
		
		SELECT DISTINCT term_start, map_months,debt_rating into #tmp_tt FROM #tmp_term
		
		set @st_sql  = 'select term_start,debt_rating, map_months, ISNULL(dbo.FNAGetProbabilityDefault(debt_rating, map_months,''' + CAST(@as_of_date AS VARCHAR) + ''' ), 0) default_probab, ISNULL(dbo.FNAGetRecoveryRate(debt_rating, map_months, ''' + CAST(@as_of_date AS VARCHAR) + '''), 0) rec_rate into ##tmp_tt2 from #tmp_tt'
		EXEC (@st_sql)
				
			IF @measure IN(17352, 17353)
				SET @st_sql = 'UPDATE ' + @MTMProcessTableName + ' SET 
						und_pnl = mtm.und_pnl + tt.und_pnl_set, 
						MTMC = mtm.MTMC + (tt.und_pnl_set * a.default_probab * ( 1 - a.rec_rate)),
						MTMI = mtm.MTMI + (tt.und_pnl_set * (1 + a.default_probab))
					FROM ' + @MTMProcessTableName + ' mtm
					INNER JOIN #tmp_term tt ON mtm.source_deal_header_id = tt.source_deal_header_id
						AND mtm.term_start = tt.term_start
						AND mtm.pnl_as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + '''
					inner join ##tmp_tt2 a on a.term_start = tt.term_start 
						and ISNULL(a.debt_rating, 0) = ISNULL(tt.debt_rating, 0) 
						and a.map_months = tt.map_months
				'
			ELSE
				SET @st_sql = 'UPDATE ' + @MTMProcessTableName + ' SET 
						und_pnl = und_pnl + tt.MTM, 
						MTMC = mtm.MTMC + tt.MTMC, 
						MTMI = mtm.MTMI + tt.MTMI 
					FROM ' + @MTMProcessTableName + ' mtm
					INNER JOIN #tmp_term tt ON mtm.source_deal_header_id = tt.source_deal_header_id
						AND mtm.term_start = tt.term_start
						AND mtm.leg = tt.leg
						AND mtm.pnl_as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + ''''
						
			exec spa_print @st_sql
			EXEC(@st_sql)		
		END
		--End Enhancement
		IF ABS(@VAR) <> 0
		BEGIN
			DELETE FROM #tmp_curse

			SET @st_sql = 'UPDATE mtm SET mtm.und_pnl = mtm.und_pnl*ISNULL(ABS(delta.delta), 1)
			    FROM ' + @MTMProcessTableName + ' mtm
				OUTER APPLY (
							SELECT delta 
							FROM source_deal_pnl_detail_options' + CASE WHEN @calc_type ='w' THEN '_whatif' ELSE '' END + ' AS sdpdow 
							WHERE sdpdow.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''' 
								AND sdpdow.source_deal_header_id = mtm.source_deal_header_id 
								AND sdpdow.term_Start = mtm.term_Start ' + 
								CASE WHEN @calc_type ='w' THEN ' AND sdpdow.criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '' ELSE '' END + ') delta'

				EXEC spa_print @st_sql
				EXEC(@st_sql)

			IF @measure = 17357
				INSERT INTO #tmp_curse(as_of_date, und_pnl)
				SELECT  
					pnl_as_of_date, 
					SUM(gross_margin) AS val
				FROM #gross_margin
				WHERE pnl_as_of_date <> @as_of_date
				GROUP BY pnl_as_of_date
			ELSE
			BEGIN
				SET @st_sql = '
					INSERT INTO #tmp_curse(as_of_date, und_pnl)
					SELECT  
						pnl_as_of_date, 
						SUM(und_pnl) AS val
					FROM ' + @MTMProcessTableName + '
					WHERE pnl_as_of_date <> ''' + CAST(@as_of_date AS VARCHAR) + '''
					GROUP BY pnl_as_of_date'
			
				exec spa_print @st_sql		
				EXEC(@st_sql)
			END
			
			SELECT @mean_value = AVG(und_pnl), @standard_dev = STDEV(und_pnl) FROM #tmp_curse
			
			IF @calc_type = 'w'
			BEGIN
				SET @st_sql = '
					DELETE vpdw
					FROM [dbo].[var_probability_density_whatif] vpdw
					WHERE 1=1 
						AND vpdw.whatif_criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '
						AND vpdw.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
						AND vpdw.measure = ' + CAST(@measure AS VARCHAR) + 
					CASE WHEN @netting_counterparty_id IS NOT NULL THEN ' 
						AND vpdw.counterparty = ''' + CAST(@netting_counterparty_id AS VARCHAR) + ''''
					ELSE  '' 
					END
					
				exec spa_print @st_sql		
				EXEC(@st_sql)
				
				SET @st_sql = '
					INSERT INTO var_probability_density_whatif(
						whatif_criteria_id,
						as_of_date,
						counterparty,
						mtm_value,
						probab_den,
						measure,
						create_user,
						create_ts,
						update_user,
						update_ts
					)
					SELECT 
						' + CAST(@whatif_criteria_id AS VARCHAR) + ', 
						''' + CAST(@as_of_date AS VARCHAR) + ''',
						0, 
						und_pnl, 
						dbo.FNANormDist(und_pnl, ' + CONVERT(VARCHAR(100), @mean_value, 2) + ', ' + CONVERT(VARCHAR(100), @standard_dev, 2) + ', 0) probab_den,
						' + CAST(@measure AS VARCHAR) + ',
						dbo.FNADBUser(),
						getdate(),
						dbo.FNADBUser(),
						getdate()
					FROM 
						#tmp_curse
					ORDER BY as_of_date'

				exec spa_print @st_sql
				EXEC (@st_sql)
			END
			ELSE
			BEGIN
				SET @st_sql = '
					DELETE [dbo].[var_probability_density] 
					FROM [dbo].[var_probability_density] vpd
					WHERE 1 = 1 
						AND vpd.var_criteria_id = ' + CAST(@var_criteria_id AS VARCHAR) + '
						AND vpd.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''
						
				exec spa_print @st_sql		
				EXEC(@st_sql)
				
				SET @st_sql = '
					INSERT INTO var_probability_density(
						var_criteria_id,
						as_of_date,
						counterparty,
						mtm_value,
						probab_den,
						create_user,
						create_ts,
						update_user,
						update_ts
					)
					SELECT 
						' + CAST(@var_criteria_id AS VARCHAR) + ', 
						''' + CAST(@as_of_date AS VARCHAR) + ''',
						0, 
						und_pnl, 
						dbo.FNANormDist(und_pnl, ' + CONVERT(VARCHAR(100), @mean_value, 2) + ', ' + CONVERT(VARCHAR(100), @standard_dev, 2) + ', 0) probab_den,
						dbo.FNADBUser(),
						getdate(),
						dbo.FNADBUser(),
						getdate()
					FROM 
						#tmp_curse
					ORDER BY as_of_date'

				exec spa_print @st_sql
				EXEC (@st_sql)
			END
		END
		
		--Hold to maturity enhancement start
		IF @hold_to_maturity = 'Y'
		BEGIN
			SET @st_sql='UPDATE ' + @MTMProcessTableName + ' SET     
						und_pnl = mtm.und_pnl,
						MTMC = mtm.MTMC,
						MTMI = mtm.MTMI
						FROM ' + @MTMProcessTableName + ' mc
						INNER JOIN ' + @MTMProcessTableNameNew + ' mtm ON mc.pnl_as_of_date = mtm.pnl_as_of_date
							AND mc.source_deal_header_id = mtm.source_deal_header_id
							AND mc.term_start = mtm.term_start  
							AND mtm.pnl_as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''
					
			exec spa_print @st_sql
			EXEC(@st_sql)	
		END
		--Hold to maturity enhancement end
		---curve wise mtm saving
		IF @calc_type = 'w'
		BEGIN
			IF @measure = 17351
			BEGIN
				SET @st_sql = '
					DELETE [dbo].[mtm_var_simulation_whatif] FROM [dbo].[mtm_var_simulation_whatif] m
					  INNER JOIN 
					' + @MTMProcessTableName + ' tmp on m.as_of_date = tmp.pnl_as_of_date
					AND m.whatif_criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR)
				
				exec spa_print @st_sql	
				EXEC(@st_sql)
				
				SET @st_sql = '
				INSERT into	[dbo].[mtm_var_simulation_whatif]
				   ([as_of_date]
				   ,[whatif_criteria_id]
				   ,term
				   ,source_deal_header_id 
				   ,mtm_value 
	   			   ,mtm_value_c 
				   ,mtm_value_i 
				   ,counterparty_id
				   ,[create_user]
				   ,[create_ts] 
				)	
				SELECT 
					pnl_as_of_date,
					MAX(' + CAST(@whatif_criteria_id AS VARCHAR) + '),
					term_start,
					source_deal_header_id,
					SUM(und_pnl) mtm,
					SUM(MTMC) mtmc,
					SUM(MTMI) mtmi,
					counterparty_id,
					max(dbo.FNADBUser()) usr,
					GETDATE() 
				FROM ' + @MTMProcessTableName + ' 
				GROUP BY pnl_as_of_date, term_start, source_deal_header_id, counterparty_id'
				
				exec spa_print @st_sql
				EXEC (@st_sql)	
			END
			ELSE IF @measure = 17352
			BEGIN
				SET @st_sql = '
					DELETE [dbo].[mtm_cfar_simulation_whatif] FROM [dbo].[mtm_cfar_simulation_whatif] m
					INNER JOIN ' + @MTMProcessTableName + ' tmp ON m.as_of_date = tmp.pnl_as_of_date
						AND m.whatif_criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR)
				
				exec spa_print @st_sql	
				EXEC(@st_sql)
				
				SET @st_sql = '
				INSERT into	[dbo].[mtm_cfar_simulation_whatif]
				   ([as_of_date]
				   ,[whatif_criteria_id]
				   ,term
				   ,source_deal_header_id 
				   ,cash_flow 
	   			   ,cash_flow_c 
				   ,cash_flow_i 
				   ,counterparty_id
				   ,[create_user]
				   ,[create_ts] 
				)	
				SELECT 
					pnl_as_of_date,
					MAX(' + CAST(@whatif_criteria_id AS VARCHAR) + '),
					term_start,
					source_deal_header_id,
					SUM(und_pnl) mtm,
					SUM(MTMC) mtmc,
					SUM(MTMI) mtmi,
					counterparty_id,
					max(dbo.FNADBUser()) usr,
					GETDATE() 
				FROM ' + @MTMProcessTableName + ' 
				GROUP BY pnl_as_of_date, term_start, source_deal_header_id, counterparty_id'
				
				exec spa_print @st_sql
				EXEC (@st_sql)
			END
			ELSE IF @measure = 17353
			BEGIN
				SET @st_sql = '
					DELETE [dbo].[mtm_ear_simulation_whatif] FROM [dbo].[mtm_ear_simulation_whatif] m
					INNER JOIN ' + @MTMProcessTableName + ' tmp ON m.as_of_date = tmp.pnl_as_of_date
						AND m.whatif_criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR)
				
				exec spa_print @st_sql	
				EXEC(@st_sql)
				
				SET @st_sql = '
				INSERT into	[dbo].[mtm_ear_simulation_whatif]
				   ([as_of_date]
				   ,[whatif_criteria_id]
				   ,term
				   ,source_deal_header_id 
				   ,earning 
	   			   ,earning_c 
				   ,earning_i 
				   ,counterparty_id
				   ,[create_user]
				   ,[create_ts] 
				)	
				SELECT 
					pnl_as_of_date,
					MAX(' + CAST(@whatif_criteria_id AS VARCHAR) + '),
					term_start,
					source_deal_header_id,
					SUM(und_pnl) mtm,
					SUM(MTMC) mtmc,
					SUM(MTMI) mtmi,
					counterparty_id,
					max(dbo.FNADBUser()) usr,
					GETDATE() 
				FROM ' + @MTMProcessTableName + ' 
				GROUP BY pnl_as_of_date, term_start, source_deal_header_id, counterparty_id'
				
				exec spa_print @st_sql
				EXEC (@st_sql)
			END
			ELSE IF @measure = 17357
			BEGIN
				SET @st_sql = '
					DELETE [dbo].[mtm_gmar_simulation_whatif] FROM [dbo].[mtm_gmar_simulation_whatif] m
					INNER JOIN ' + @MTMProcessTableName + ' tmp ON m.as_of_date = tmp.pnl_as_of_date
						AND m.whatif_criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR)
				
				exec spa_print @st_sql	
				EXEC(@st_sql)
				
				SET @st_sql = '
				INSERT into	[dbo].[mtm_gmar_simulation_whatif]
				   ([as_of_date]
				   ,[whatif_criteria_id]
				   ,term
				   ,source_deal_header_id 
				   ,cash_flow 
	   			   ,cash_flow_c 
				   ,cash_flow_i 
				   ,counterparty_id
				   ,[create_user]
				   ,[create_ts] 
				)	
				SELECT 
					pnl_as_of_date,
					MAX(' + CAST(@whatif_criteria_id AS VARCHAR) + '),
					term_start,
					source_deal_header_id,
					SUM(und_pnl) mtm,
					SUM(MTMC) mtmc,
					SUM(MTMI) mtmi,
					counterparty_id,
					max(dbo.FNADBUser()) usr,
					GETDATE() 
				FROM ' + @MTMProcessTableName + ' 
				GROUP BY pnl_as_of_date, term_start, source_deal_header_id, counterparty_id'
				
				exec spa_print @st_sql
				EXEC (@st_sql)
			END		
		END
		ELSE
		BEGIN
			SET @st_sql = '
			DELETE [dbo].[mtm_var_simulation] FROM [dbo].[mtm_var_simulation] m
			INNER JOIN ' + @MTMProcessTableName + ' tmp on m.as_of_date = tmp.pnl_as_of_date
				AND m.var_criteria_id = ' + CAST(@var_criteria_id AS VARCHAR)
		
			exec spa_print @st_sql	
			EXEC(@st_sql)
			
			SET @st_sql = '
			INSERT into	[dbo].[mtm_var_simulation]
			   ([as_of_date]
			   ,[var_criteria_id]
			   ,term
			   ,source_deal_header_id 
			   ,mtm_value 
	   		   ,mtm_value_C 
			   ,mtm_value_I 
			   ,counterparty_id
			   ,[create_user]
			   ,[create_ts] 
			)	
			SELECT 
				pnl_as_of_date,
				MAX(' + CAST(@var_criteria_id AS VARCHAR) + '),
				term_start,
				source_deal_header_id,
				SUM(und_pnl) mtm,
				SUM(MTMC) mtmc,
				SUM(MTMI) mtmi,
				counterparty_id,
				max(dbo.FNADBUser()) usr,
				GETDATE() 
			FROM ' + @MTMProcessTableName + ' 
			GROUP BY pnl_as_of_date, term_start, source_deal_header_id, counterparty_id'
				
		exec spa_print @st_sql
		EXEC (@st_sql)	
	END		
		
		EXEC spa_print 'Finish Simulation VaR Calculation'
		SET @desc = @msg_desc + ' process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + '.'
		SET @errorcode = 's'
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
					'&spa=exec spa_get_VaR_report '+CASE WHEN @calc_type = 'w' THEN '''w''' ELSE CASE WHEN @measure = '17357' THEN '''g''' ELSE '''v''' END END+
					',null,null,''' 
					+ CAST(YEAR(@as_of_date) AS VARCHAR) + '-' + CAST(MONTH(@as_of_date) AS VARCHAR) + '-' + CAST(DAY(@as_of_date) AS VARCHAR) 
					+''',' + CAST(case when @calc_type = 'w' then @whatif_criteria_id else @var_criteria_id end AS VARCHAR)


		EXEC spa_print @errorcode
		EXEC spa_print @process_id
	
	END
	--End of VAR, MTM, CFaR, Ear Calculation 
		 
-------------------End error Trapping--------------------------------------------------------------------------
END TRY

BEGIN CATCH
	EXEC spa_print 'Catch Error'
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC spa_print @process_id
	SET @errorcode = 'e'
	--EXEC spa_print ERROR_LINE()
	IF ERROR_MESSAGE() = 'CatchError'
	BEGIN
		SET @desc = @msg_desc + ' process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + ' (ERRORS found).'
		EXEC spa_print @desc
	END
	ELSE
	BEGIN
		SET @desc = @msg_desc + ' critical error found ( Errr Description:' +  ERROR_MESSAGE() + '; Line no: ' + CAST(ERROR_LINE() AS VARCHAR) + ').'
		EXEC spa_print @desc
	END

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''','+ CASE WHEN @measure = 17355 THEN '''PFE Calculation''' ELSE '''y''' END
END CATCH

SET @url_desc = '' 

IF @errorcode = 'e'
BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'

	SET @url_desc = '<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''+@process_id+'''">Click here...</a>'
	SELECT 'Error' ErrorCode, 'Calculate vol_cor' MODULE, 
			'spa_calc_VaR' Area, 'DB Error' Status, @msg_desc + ' completed with error, Please view this report. ' + @url_desc MESSAGE, '' Recommendation
END
ELSE
BEGIN
	IF @warningcode = 'e'
	BEGIN
		SET @desc = @msg_desc + ' process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + ' with warnings.'
		SELECT @desc1 = '<a target="_blank" href="' + @url + '">' + @calc_for + ' Results</a>'
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''
	END
	
		SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '</a>'
		EXEC spa_ErrorHandler 0, @msg_desc, @msg_desc, 'Success', @desc, ''
END

IF @errorcode <> 'e' AND @var_approach NOT IN (1521, 1522)
BEGIN
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @MTMProcessTableName + ''',''m'''

	SELECT @desc1 = '<a target="_blank" href="' + @url + '">View MTM</a>'	
END

IF @var_approach IN (1521, 1522) AND @is_warning = 'y'
BEGIN
	SET @desc1 = CASE WHEN (@count_fail <> @count_total) THEN @desc ELSE '' END
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''PFE Calculation'''
	SELECT @desc = '<a target="_blank" href="' + @url + '"> ' + @msg_desc + ' process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + CASE WHEN @count_fail > 0 THEN ' (ERRORS found)' ELSE '' END + '.</a>'
END	

IF (@var_criteria_id > 0 OR (@is_warning = 'y' AND NOT EXISTS(SELECT TOP 1 1 FROM fas_eff_ass_test_run_log WHERE process_id = @process_id AND TYPE IN ('Debt_Rating', 'Default_Recovery', 'Probability') AND code = 'Warning')))
EXEC  spa_message_board 
		'i', 
		@user_name,
		NULL, 
		@msg_desc,
		@desc, 
		@desc1,
		'', 
		@errorcode, 
		@msg_desc,
		NULL,
		@process_id
