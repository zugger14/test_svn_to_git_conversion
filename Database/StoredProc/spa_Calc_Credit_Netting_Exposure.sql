/****** Object:  StoredProcedure [dbo].[spa_Calc_Credit_Netting_Exposure]    Script Date: 07/17/2012 19:13:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_Calc_Credit_Netting_Exposure]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Calc_Credit_Netting_Exposure]
GO
/****** Object:  StoredProcedure [dbo].[spa_Calc_Credit_Netting_Exposure]    Script Date: 07/17/2012 19:13:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Calculate credit risk exposure

	Parameters :
	@as_of_date : Date for processing
	@user_login_id : User id
	@curve_source_value_id : Source to take price as 4500 - Master
	@sub_entity_id : Subsidiary filter for deals to process
	@strategy_entity_id : Strategy filter for deals to process
	@book_entity_id : Book filter for deals to process
	@counterparty_id : Counterparty filter to process
	@purge_all : To purge existing calculation for same criteria 'Y' - Yes, 'N' - No
	@runCAReport : To run report 'Y' - Yes, 'N' - No
	@what_if_group : Define deal category type  'Y' - Yes, 'N' - No
	@print_diagnostic : Print diagnostic 1 - Yes, 0 - No
	@simulation : Use simulation 'Y' - Yes, 'N' - No
	@batch_process_id : Process id when run through batch
	@batch_report_param : Paramater to run through batch
	@show_message_in_message_board : Display calculation status in message board 'y' - Yes, 'n' - No
	@calc_type : Calculation Type - 'm' - MTM 'c' - At Risk 'w' - What If
	@criteria_id : Criteria ID to process the calculation

**/
CREATE PROC [dbo].[spa_Calc_Credit_Netting_Exposure]	
				@as_of_date VARCHAR(20),
				@user_login_id VARCHAR(50)=NULL,
				--@batch_process_id VARCHAR(100),
				@curve_source_value_id INT, 
				@sub_entity_id VARCHAR(MAX) = NULL,	
				@strategy_entity_id VARCHAR(100) = NULL,
				@book_entity_id VARCHAR(500) = NULL,																							
				@counterparty_id VARCHAR(MAX) = NULL,
				@purge_all CHAR(1) = 'n',
				@runCAReport CHAR(1) = 'n',
				@what_if_group CHAR(1) = 'n',
				@print_diagnostic INT = 0,
				@simulation CHAR(1) = 'n',
				@batch_process_id VARCHAR(50)=NULL,
				@batch_report_param VARCHAR(1000)=NULL,
				@show_message_in_message_board CHAR(1)='y',
				@calc_type CHAR(1) = 'r',
				@criteria_id INT = NULL, --it comes from whatif
				@trigger_workflow NCHAR(1) = 'y'
				--,@mtm_table_name  VARCHAR(200) = NULL,  --MTM process table for PFE - spa_calc_VAR_Simulation_job
				--@pfe_table_name  VARCHAR(200) = NULL   --Used to return value for PFE -spa_calc_VAR_Simulation_job

 AS

-------------------FOR TESTING PURPOSES
--'2008-12-31','farrms_admin','wwwwwww',12026 ,'259,195,255,192,193,196,194,26' ,NULL ,NULL ,NULL ,'n' ,'n'

/*


DECLARE
				@as_of_date VARCHAR(20)='2018-04-16',
				@user_login_id VARCHAR(50)=NULL,
				@curve_source_value_id INT=4500, 
				@sub_entity_id VARCHAR(MAX) = NULL,	
				@strategy_entity_id VARCHAR(100) = NULL,
				@book_entity_id VARCHAR(500) = NULL,
				@counterparty_id VARCHAR(MAX) = '8897',---,2975,1737',
				@purge_all CHAR(1) = 'n',
				@runCAReport CHAR(1) = 'n',
				@what_if_group CHAR(1) = 'n',
				@print_diagnostic INT = 0,
				@simulation CHAR(1) = 'n',
				@batch_process_id VARCHAR(50)=NULL,
				@batch_report_param VARCHAR(1000)=NULL,
				@show_message_in_message_board CHAR(1)='y',
				@calc_type CHAR(1) = 'r',
				@criteria_id INT = NULL --it comes from whatif
				--,@mtm_table_name  VARCHAR(200) = NULL,  --MTM process table for PFE - spa_calc_VAR_Simulation_job
				--@pfe_table_name  VARCHAR(200) = NULL   --Used to return value for PFE -spa_calc_VAR_Simulation_job


--SELECT * FROM credit_exposure_detail where as_of_date = '2017-12-01' and source_counterparty_id = 1806

drop table adiha_process.dbo.sim_delta_data_farrms_admin_123
	
drop table adiha_process.dbo.calcprocess_credit_netting_deals_farrms_admin_123
drop table adiha_process.dbo.calcprocess_credit_netting_one_farrms_admin_123
drop table adiha_process.dbo.calcprocess_discount_factor_farrms_admin_123
drop table adiha_process.dbo.NettingProcessTableCounterparty_farrms_admin_123
drop table adiha_process.dbo.calcprocess_cpty_farrms_admin_123
drop table adiha_process.dbo.tablecalcprocess_credit_netting_deals_farrms_admin_123
drop table 	adiha_process.dbo.calcprocess_credit_netting_deals_farrms_admin_123


DROP TABLE #calc_status
DROP TABLE #count_counterparty
drop table #tmp_pnl_simulation 
drop table #tmp_cpd
drop table #exp_test
drop table #cpty
drop table #books
drop table #climits
drop table #limit_check
drop table #as_of_dates
drop table  #max_date
---------------end of test this
--*/


SET STATISTICS IO OFF
SET NOCOUNT ON 
--SET NOCOUNT OFF
SET ROWCOUNT 0

BEGIN TRY

IF @user_login_id IS NULL
 SET @user_login_id=dbo.fnadbuser()

	DECLARE @sql_stmt VARCHAR(8000)
	DECLARE @sql_stmt1 VARCHAR(8000)
	DECLARE @sql_stmt2 VARCHAR(8000)
	DECLARE @NettingProcessTableOneName VARCHAR(100)
	DECLARE @NettingDealProcessTableName VARCHAR(100)
	DECLARE @NettingProcessTableCounterparty varchar(150)
	DECLARE @DiscountTableName VARCHAR(100)
	DECLARE @log_increment 	INT
	DECLARE @drill_gl_number_quote VARCHAR(5000)
	DECLARE @pr_name VARCHAR(100)
	DECLARE @log_time DATETIME
	DECLARE @comp_function_id INT
	DECLARE @risk_control_id INT
	DECLARE @message VARCHAR(1000)
	DECLARE @table_name VARCHAR(200)	
	DECLARE @e_time_text varchar(100)
	DECLARE @begin_time DATETIME
	DECLARE @user_name AS VARCHAR(100)
	DECLARE @url varchar(500)
	DECLARE @urlP varchar(500)
	DECLARE @url_desc varchar(8000)
	SET @begin_time = getdate()
	DECLARE  @e_time INT
	DECLARE @error_count INT
	DECLARE @type CHAR
	SET @e_time = datediff(ss,@begin_time,getdate())
	SET @e_time_text = cast(cast(@e_time/60 as int) as varchar) + ' Mins ' + cast(@e_time - cast(@e_time/60 as int) * 60 as varchar) + ' Secs'
	SET @user_name = @user_login_id
	DECLARE @CreditExposureDetail VARCHAR(100), @master_counterparty_id INT

	SELECT @master_counterparty_id = counterparty_id FROM fas_subsidiaries WHERE fas_subsidiary_id = -1

	--Option to decide whether to check collateral or limit status 
	DECLARE @do_not_check_limit_status INT = 0, @do_not_check_collateral_status INT = 0

	SELECT @do_not_check_limit_status = ISNULL(adcv.var_value, 0)
	FROM adiha_default_codes adc
	INNER JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id
	WHERE adc.instances = 1 AND adc.default_code_id IN (105) AND adcv.seq_no = 1

	SELECT @do_not_check_collateral_status = ISNULL(adcv.var_value, 0)
	FROM adiha_default_codes adc
	INNER JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id
		AND adc.instances = adcv.instance_no
	WHERE adc.instances = 1 AND adc.default_code_id IN (106) AND adcv.seq_no = 1
	
	--whatif hypothetical 
	DECLARE @deal_header_table VARCHAR(250), @deal_detail_table VARCHAR(250)
	
	--COLLECT BOOKS
	DECLARE @Sql_SelectB VARCHAR(MAX)        
	DECLARE @Sql_WhereB VARCHAR(MAX)        
	DECLARE @assignment_type INT        
	DECLARE @desc VARCHAR(5000),@call_to VARCHAR(1), @shift_val FLOAT = 0, @shift_by CHAR(1) = 'v', @run_date VARCHAR(20), @delta_value VARCHAR(120), @calc_type_rep CHAR(1),
		@whatif_process_id VARCHAR(50) = NULL
	SET @call_to='n' -- 'o' for old and 'n' for new logic
	SET @calc_type = ISNULL(@calc_type, 'r')
	
	IF @calc_type = 'm'
	BEGIN
		SET @calc_type_rep = @calc_type
		SET @calc_type = 'w'
	END
	
	DECLARE @revaluation CHAR(1)
	SELECT @revaluation = ISNULL(revaluation, 'n') FROM maintain_whatif_criteria WHERE criteria_id = ABS(@criteria_id)
	
	IF @batch_process_id IS NULL OR @calc_type = 'w'
	BEGIN
		SET @whatif_process_id = @batch_process_id
		SET @batch_process_id = REPLACE(NEWID(),'-','_')
	END
	
	SET @whatif_process_id = ISNULL(@whatif_process_id, @batch_process_id)	
		
	IF @calc_type = 'w' AND @call_to = 'n'
		IF @revaluation = 'y'
			SELECT @run_date = MAX(run_date) FROM source_deal_delta_value_whatif WHERE run_date <= @as_of_date AND criteria_id = ABS(@criteria_id)
		ELSE
			SELECT @run_date = MAX(run_date) FROM source_deal_delta_value WHERE run_date <= @as_of_date
			
	SET @run_date = ISNULL(@run_date, @as_of_date)
	
	IF @calc_type = 'w' AND @criteria_id > 0
	BEGIN
		SET @deal_header_table = 'source_deal_header'
		SET @deal_detail_table = 'source_deal_detail'
	END
	ELSE IF @calc_type = 'w' AND (@criteria_id IS NULL OR @criteria_id < 0)
	BEGIN
		SET @deal_header_table = dbo.FNAProcessTableName('hypo_deal_header', @user_name, @whatif_process_id)
		SET @deal_detail_table = dbo.FNAProcessTableName('hypo_deal_detail', @user_name, @whatif_process_id)	
	END	

	--Multiple scenario 
	DECLARE @whatif_shift VARCHAR(250), @as_of_date_point VARCHAR(250)
	SET @whatif_shift = dbo.FNAProcessTableName('whatif_shift', @user_name,@whatif_process_id)
	SET @as_of_date_point = dbo.FNAProcessTableName('as_of_date_point', @user_name,@whatif_process_id)
	IF OBJECT_ID(@whatif_shift) IS NULL
		EXEC('CREATE TABLE ' + @whatif_shift + ' (curve_id int, curve_shift_val FLOAT, curve_shift_per FLOAT)')
	--End

	IF ISNULL(@calc_type, 'r') = 'r'
	BEGIN
		SET @deal_header_table = 'source_deal_header'
		SET @deal_detail_table = 'source_deal_detail'
	END
	
	CREATE TABLE #calc_status
	(
		process_id varchar(100) COLLATE DATABASE_DEFAULT,
		ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
		Module varchar(100) COLLATE DATABASE_DEFAULT,
		Source varchar(100) COLLATE DATABASE_DEFAULT,
		type varchar(100) COLLATE DATABASE_DEFAULT,
		[description] varchar(8000) COLLATE DATABASE_DEFAULT,
		[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
	)
	--Checking no of available simulations, returning error if no data found 
	--@msg_desc: storing validation message for [Credit Exposure Simulation] or [Calculate Credit Exposure]
	DECLARE @total_simulations INT = NULL, @msg_desc VARCHAR(50) = 'Calculate Credit Exposure'
	IF ISNULL(@simulation, 'n') = 'y'
	BEGIN
		IF @call_to = 'o'
		BEGIN
			IF @calc_type = 'w'
				IF @criteria_id > 0
					SELECT @total_simulations = COUNT(DISTINCT(pnl_as_of_date)) FROM var_simulation_data WHERE run_date = @run_date
				ELSE	
					SELECT @total_simulations = COUNT(DISTINCT(pnl_as_of_date)) FROM var_simulation_data WHERE run_date = @run_date AND source_deal_header_id < 0
			ELSE
				SELECT @total_simulations = COUNT(DISTINCT(pnl_as_of_date)) FROM var_simulation_data WHERE run_date = @run_date
				
			SET @table_name = 'var_simulation_data'	
		END
		ELSE
		BEGIN
			IF @calc_type = 'w'
				IF @criteria_id > 0
					IF @revaluation = 'y'
						SELECT @total_simulations = COUNT(DISTINCT(as_of_date)) FROM source_deal_delta_value_whatif WHERE run_date = @run_date and criteria_id = @criteria_id
					ELSE
						SELECT @total_simulations = COUNT(DISTINCT(as_of_date)) FROM source_deal_delta_value WHERE run_date = @run_date
				ELSE
					IF @revaluation = 'y'
						SELECT 
							@total_simulations = COUNT(DISTINCT(as_of_date)) 
						FROM source_deal_delta_value_whatif 
						WHERE run_date = @run_date AND source_deal_header_id < 0 AND criteria_id = ABS(@criteria_id)
					ELSE	
						SELECT @total_simulations = COUNT(DISTINCT(as_of_date)) FROM source_deal_delta_value WHERE run_date = @run_date AND source_deal_header_id < 0
			ELSE
				SELECT @total_simulations = COUNT(DISTINCT(as_of_date)) FROM source_deal_delta_value WHERE run_date = @run_date
			
			SET @table_name = dbo.FNAProcessTableName('sim_delta_data', @user_name, @batch_process_id)
			EXEC('IF OBJECT_ID(''' + @table_name + ''') IS NOT NULL
			DROP TABLE ' + @table_name)
			
			SET @delta_value = dbo.FNAProcessTableName('delta_value', @user_name, @batch_process_id)
			EXEC('IF OBJECT_ID(''' + @delta_value + ''') IS NOT NULL
			DROP TABLE ' + @delta_value)
			
			SET @sql_stmt = '
			SELECT ''' + @as_of_date + ''' run_date, s.as_of_date, 
				CASE WHEN wis1.curve_shift_per IS NOT NULL THEN 
					(s.contract_value_delta * wis1.curve_shift_per) 
				ELSE 
					s.contract_value_delta 
				END contract_value_delta,
				(CASE WHEN wis.curve_shift_per IS NOT NULL THEN 
					(s.market_value_delta * wis.curve_shift_per) 
				ELSE 
					s.market_value_delta 
				 END +
				CASE WHEN wis1.curve_shift_per IS NOT NULL THEN 
					(s.contract_value_delta * wis1.curve_shift_per) 
				ELSE 
					s.contract_value_delta 
				END) delta_value,
				s.source_deal_header_id, s.term_start
			INTO ' + @delta_value + '	
			FROM source_deal_delta_value'+ CASE WHEN @revaluation ='y' THEN '_whatif' ELSE '' END + ' s 
			' + CASE WHEN @counterparty_id IS NOT NULL THEN '
			INNER JOIN ' + @deal_header_table + ' sdh ON s.source_deal_header_id = sdh.source_deal_header_id
				AND sdh.counterparty_id IN (' + @counterparty_id + ' ) ' ELSE '' END    
			+ CASE WHEN @calc_type = 'w' THEN '
			INNER JOIN ' + @as_of_date_point + ' aodp ON aodp.as_of_date = s.as_of_date ' ELSE '' END + ' 
			LEFT JOIN ' + @whatif_shift + ' wis ON s.curve_id = wis.curve_id
			LEFT JOIN ' + @whatif_shift + ' wis1 ON s.formula_curve_id = wis1.curve_id  
			WHERE 1= 1
				AND s.run_date = ''' + @run_date + ''''+
			CASE WHEN @revaluation ='y' THEN ' AND s.criteria_id = ' + CAST(ABS(@criteria_id) AS VARCHAR) + '' ELSE '' END
			
			--PRINT (@sql_stmt)
			EXEC(@sql_stmt)	
			
			SET @Sql_SelectB='
			SELECT ''' + @run_date + ''' run_date,sdp.source_deal_header_id,sdp.term_start,sdp.term_end,sdp.Leg, sim.as_of_date pnl_as_of_date
			,sdp.und_pnl+isnull(sim.delta_value,0) und_pnl,sdp.und_intrinsic_pnl,sdp.und_extrinsic_pnl,sdp.dis_pnl,sdp.dis_intrinsic_pnl,sdp.dis_extrinisic_pnl
			,4505 pnl_source_value_id,sdp.pnl_currency_id,sdp.pnl_conversion_factor,sdp.pnl_adjustment_value,sdp.deal_volume
			, CASE WHEN ISNULL(sdd.physical_financial_flag, ''f'') = ''p'' THEN sdp.und_pnl_set+isnull(sim.contract_value_delta,0) ELSE sdp.und_pnl+isnull(sim.delta_value,0) END und_pnl_set,
			sdp.market_value,sdp.contract_value,sdp.dis_market_value,sdp.dis_contract_value
			into  '+@table_name+'
			FROM source_deal_pnl' + CASE WHEN @calc_type = 'w' THEN '_whatif' ELSE '' END + ' sdp 
			CROSS APPLY
			(
				SELECT s.as_of_date,SUM(s.contract_value_delta) contract_value_delta ,
				SUM(s.delta_value) delta_value 
				FROM ' + @delta_value + ' s 
				WHERE s.source_deal_header_id=sdp.source_deal_header_id
				AND   s.term_start=sdp.term_start AND s.run_date=sdp.pnl_as_of_date
				GROUP BY  s.as_of_date
			) sim
			LEFT JOIN source_deal_detail sdd ON sdp.source_deal_header_id = sdd.source_deal_header_id
				AND sdd.leg = sdp.leg
				AND	sdd.term_start = sdp.term_start
			WHERE 1 = 1 
				AND	sdp.pnl_source_value_id='+CAST(@curve_source_value_id AS VARCHAR)+' 
				AND sdp.pnl_as_of_date = ''' + @as_of_date + '''' +
				CASE WHEN @calc_type = 'w' AND @criteria_id > 0 THEN ' AND sdp.criteria_id = ' + CAST(@criteria_id AS VARCHAR) ELSE '' END
					
			--PRINT @Sql_SelectB
			EXEC(@Sql_SelectB)	
		END	
	
		SET @msg_desc = 'Credit Exposure Simulation'
		SET @runCAReport = 'n'
		
		IF ISNULL(@total_simulations, 0) = 0 
		BEGIN
			INSERT INTO #calc_status
			SELECT @batch_process_id,'Error','Credit Exposure Simulation','Run Credit Exposure Simulation','Data Error',
			'No MTM simulation found to process for Credit Exposure Simulation','Please run MTM simulation'
			GOTO FinalStep
			RETURN
		END
	END
	--End of section--
	--calculating credit limit available
	--PRINT '*********************************Start calculating credit limit available***********************************'
	
	IF @runCAReport='y'
	BEGIN	
		EXEC [spa_calculate_credit_risks] @as_of_date,@counterparty_id
		EXEC  spa_message_board 'i', @user_login_id, NULL, 'Calculate Credit Exposure',  'Counterparty Credit Availability calculation is completed.', '', '', 's', '',NULL,@batch_process_id
	END
	IF ISNULL(@runCAReport,'y')='y'
		RETURN

	
	SET @NettingDealProcessTableName = dbo.FNAProcessTableName('calcprocess_credit_netting_deals', @user_login_id, @batch_process_id)
	EXEC('IF OBJECT_ID(''' + @NettingDealProcessTableName + ''') IS NOT NULL
			DROP TABLE ' + @NettingDealProcessTableName)
			
	SET @NettingProcessTableOneName = dbo.FNAProcessTableName('calcprocess_credit_netting_one', @user_login_id, @batch_process_id)
	EXEC('IF OBJECT_ID(''' + @NettingProcessTableOneName + ''') IS NOT NULL
			DROP TABLE ' + @NettingProcessTableOneName)
			
	SET @DiscountTableName = dbo.FNAProcessTableName('calcprocess_discount_factor', @user_login_id, @batch_process_id)
	EXEC('IF OBJECT_ID(''' + @DiscountTableName + ''') IS NOT NULL
			DROP TABLE ' + @DiscountTableName)
			
	SET @NettingProcessTableCounterparty = dbo.FNAProcessTableName('NettingProcessTableCounterparty', @user_login_id, @batch_process_id)
	EXEC('IF OBJECT_ID(''' + @NettingProcessTableCounterparty + ''') IS NOT NULL
			DROP TABLE ' + @NettingProcessTableCounterparty)
			
	SET @CreditExposureDetail = dbo.FNAProcessTableName('credit_exposure_detail', @user_login_id, @batch_process_id)
	EXEC('IF OBJECT_ID(''' + @CreditExposureDetail + ''') IS NOT NULL
			DROP TABLE ' + @CreditExposureDetail)

	IF @print_diagnostic = 1
	BEGIN
		SET @log_increment = 1
		PRINT '******************************************************************************************'
		PRINT '********************START &&&&&&&&&[spa_Calc_Netting_Measurement]**********'
	END

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
	END

	create table #as_of_dates(as_of_date datetime)

	if isnull(@simulation,'n')='n'
		insert into #as_of_dates(as_of_date) select @as_of_date
	else
		insert into #as_of_dates(as_of_date)
		--select distinct top(10000) as_of_date from var_simulation_data where run_date=@as_of_date
		select distinct as_of_date from source_price_curve_simulation where run_date=@as_of_date

		PRINT @pr_name+' Running..............'
		PRINT GETDATE()

	DECLARE @do_not_include_settlement INT
	SELECT  @do_not_include_settlement =  var_value
	FROM         adiha_default_codes_values
	WHERE     (instance_no = 1) AND (default_code_id = 45) AND (seq_no = 1)

	if ISNULL(@simulation,'n')='y'
	begin
		SET @do_not_include_settlement = 1	
		set @curve_source_value_id=4505
	END
	
	IF @calc_type = 'w' AND @calc_type_rep <> 'm'
		SET @do_not_include_settlement = 1
		
	DECLARE @credit_physical_buy_mth VARCHAR(10),@credit_physical_sell_mth VARCHAR(10)
	SELECT  @credit_physical_buy_mth =  var_value
	FROM         adiha_default_codes_values
	WHERE     (instance_no = 1) AND (default_code_id = 46) AND (seq_no = 1)

	SELECT  @credit_physical_sell_mth =  var_value
	FROM         adiha_default_codes_values
	WHERE     (instance_no = 1) AND (default_code_id = 46) AND (seq_no = 2)	
	
	IF @credit_physical_buy_mth IS NULL
		SET @credit_physical_buy_mth = -1000

	IF @credit_physical_sell_mth IS NULL
		SET @credit_physical_sell_mth = -1000
		
	--Changes made to address PFE development
	if ISNULL(@simulation,'n')<>'y'
	BEGIN
		IF ISNULL(@calc_type, 'r') = 'r'
			SET @table_name = 'source_deal_pnl'
		ELSE
			SET @table_name = 'source_deal_pnl_whatif'
	END
		 
	SET @Sql_WhereB = ''        

	CREATE TABLE #books (fas_subsidiary_id INT, fas_strategy_id INT, fas_book_id INT, hedge_type_value_id INT, legal_entity_id INT) 

	SET @Sql_SelectB=        
		'INSERT INTO  #books       
		SELECT distinct stra.parent_entity_id, stra.entity_id, book.entity_id, fs.hedge_type_value_id, legal_entity
		FROM portfolio_hierarchy book (nolock) 
		INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id 
		LEFT OUTER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id 
		LEFT OUTER JOIN fas_strategy fs ON fs.fas_strategy_id = book.parent_entity_id 
		LEFT OUTER JOIN fas_books fb ON fb.fas_book_id = ssbm.fas_book_id
		WHERE ssbm.fas_deal_type_value_id NOT IN(402, 404, 405, 406, 408, 411, 410)'   
	              
	IF @sub_entity_id IS NOT NULL        
	  SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '         
	 IF @strategy_entity_id IS NOT NULL        
	  SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        
	 IF @book_entity_id IS NOT NULL        
	  SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN(' + @book_entity_id + ')) '        
	        
	  SET @Sql_SelectB=@Sql_SelectB+@Sql_WhereB        
	
	--PRINT(@Sql_SelectB)            
	EXEC (@Sql_SelectB)	


	--Collect all counterparties
	CREATE TABLE #cpty(
		source_counterparty_id INT, 
		netting_counterparty_id INT,
		counterparty_name VARCHAR(250) COLLATE DATABASE_DEFAULT,
		parent_counterparty_name VARCHAR(250) COLLATE DATABASE_DEFAULT,
		counterparty_type VARCHAR(50) COLLATE DATABASE_DEFAULT,
		risk_rating VARCHAR(50) COLLATE DATABASE_DEFAULT,
		debt_rating VARCHAR(50) COLLATE DATABASE_DEFAULT,
		industry_type1 VARCHAR(50) COLLATE DATABASE_DEFAULT,
		industry_type2 VARCHAR(50) COLLATE DATABASE_DEFAULT,
		sic_code VARCHAR(50) COLLATE DATABASE_DEFAULT,
		account_status VARCHAR(50) COLLATE DATABASE_DEFAULT,
		currency_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
		--tenor_limit FLOAT,
		watch_list VARCHAR(1) COLLATE DATABASE_DEFAULT,
		int_ext_flag VARCHAR(1) COLLATE DATABASE_DEFAULT,
		risk_rating_id INT,
		debt_rating_id INT,
		industry_type1_id INT,
		industry_type2_id INT,
		sic_code_id INT,
		counterparty_type_id INT,
		exclude_after DATETIME,
		parent_counterparty_id int
		
	)

	INSERT INTO #cpty
	SELECT DISTINCT	sc.source_counterparty_id, 
			COALESCE(sc.netting_parent_counterparty_id, sc.source_counterparty_id) netting_counterparty_id, 
			sc.counterparty_name,
			ISNULL(psc.counterparty_name, sc.counterparty_name) parent_counterparty_name,
			sdv1.code counterparty_type,
			sdv2.code risk_rating,
			sdv3.code debt_rating,
			sdv4.code industry_type1,
			sdv5.code industry_type2,
			sdv6.code sic_code,
			ISNULL(sdv7.code,'Unlocked') account_status,
			scur.currency_name currency_name,
			--cci.tenor_limit,
			cci.watch_list,
			sc.int_ext_flag,
			cci.risk_rating,
			cci.debt_rating,
			cci.industry_type1,
			cci.industry_type2,
			cci.sic_code,
			sc.type_of_entity,
			DATEADD(MONTH, cci.exclude_exposure_after, @as_of_date),
			sc.parent_counterparty_id
	FROM source_counterparty sc LEFT OUTER JOIN
	counterparty_credit_info cci ON sc.source_counterparty_id = cci.counterparty_id LEFT OUTER JOIN
	static_data_value sdv1 ON 	sdv1.value_id = sc.type_of_entity LEFT OUTER JOIN
	static_data_value sdv2 ON 	sdv2.value_id = cci.risk_rating LEFT OUTER JOIN
	static_data_value sdv3 ON 	sdv3.value_id = cci.debt_rating LEFT OUTER JOIN
	static_data_value sdv4 ON 	sdv4.value_id = cci.industry_type1 LEFT OUTER JOIN
	static_data_value sdv5 ON 	sdv5.value_id = cci.industry_type2 LEFT OUTER JOIN
	static_data_value sdv6 ON 	sdv6.value_id = cci.sic_code LEFT OUTER JOIN
	static_data_value sdv7 ON 	sdv7.value_id = cci.account_status LEFT OUTER JOIN
	source_currency   scur ON   scur.source_currency_id = cci.curreny_code LEFT OUTER JOIN
	source_counterparty psc ON psc.source_counterparty_id = sc.parent_counterparty_id 
		
	WHERE	(@counterparty_id IS NULL OR sc.source_counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@counterparty_id))) 
		AND ISNULL(sc.is_active,'n') = 'y'
		AND ISNULL(cci.check_apply, 'n') = 'n'

	CREATE INDEX indx_Cpty_1 ON #cpty (source_counterparty_id)
	
	IF OBJECT_ID('tempdb..#tmp_counterparty_credit_limits') IS NOT NULL 
		DROP TABLE #tmp_counterparty_credit_limits
				
	SELECT DISTINCT 
		ccl.effective_Date,
		ccl.credit_limit,
		ccl.credit_limit_to_us,
		ccl.tenor_limit,
		ccl.max_threshold,
		ccl.min_threshold,
		ccl.counterparty_id,
		ISNULL(sng.internal_counterparty_id, ccl.internal_counterparty_id) internal_counterparty_id,
		ISNULL(sng.netting_contract_id, ccl.contract_id) contract_id,
		--ccl.internal_counterparty_id,
		--ccl.contract_id,
		ccl.currency_id,
		ccl.threshold_provided,
		ccl.threshold_received
	INTO #tmp_counterparty_credit_limits
	FROM counterparty_credit_limits ccl
	INNER JOIN #cpty c ON c.source_counterparty_id = ccl.counterparty_id
	INNER JOIN (SELECT ccl1.counterparty_id, 
					ccl1.internal_counterparty_id, 
					ccl1.contract_id, 
					MAX(ccl1.effective_date) eff_dt 
	            FROM #cpty b
	            INNER JOIN counterparty_credit_limits ccl1 ON ccl1.counterparty_id = b.source_counterparty_id
					AND ccl1.effective_date <= @as_of_date
					AND (ccl1.limit_status = 105400 OR @do_not_check_limit_status = 1)
	            GROUP BY ccl1.counterparty_id, 
					ccl1.internal_counterparty_id, ccl1.contract_id) eff ON eff.eff_dt = ccl.effective_date
	    AND eff.counterparty_id = ccl.counterparty_id
	    AND ISNULL(eff.internal_counterparty_id, 0) = ISNULL(ccl.internal_counterparty_id, 0)
	    AND ISNULL(eff.contract_id, 0) = ISNULL(ccl.contract_id, 0)
	--For Cross Netting
	OUTER APPLY (SELECT ISNULL(sng.internal_counterparty_id, @master_counterparty_id) AS internal_counterparty_id,
				sng.netting_contract_id
				FROM stmt_netting_group sng 
				INNER JOIN stmt_netting_group_detail sngd ON sngd.netting_group_id = sng.netting_group_id
					AND sngd.contract_detail_id = ccl.contract_id
				OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date,
								MAX(sng1.internal_counterparty_id) AS internal_counterparty_id 
							FROM stmt_netting_group sng1
							WHERE sng1.counterparty_id = sng.counterparty_id
							AND ISNULL(sng1.internal_counterparty_id, -1) = ISNULL(sng.internal_counterparty_id, -1)
							AND sng1.netting_type IN (109802,109800)
							AND sng1.effective_date <= @as_of_date) eff
				WHERE sng.counterparty_id = c.source_counterparty_id
				AND ISNULL(sng.internal_counterparty_id, -1) = ISNULL(eff.internal_counterparty_id, -1)
				AND COALESCE(sng.internal_counterparty_id, ccl.internal_counterparty_id, -1) = COALESCE(ccl.internal_counterparty_id, sng.internal_counterparty_id, -1)
				AND sng.effective_date = eff.eff_date
				AND sng.netting_type IN (109802,109800)) sng
	WHERE (ccl.limit_status = 105400 OR @do_not_check_limit_status = 1)

	IF OBJECT_ID('tempdb..#counterparty_credit_enhancements') IS NOT NULL 
		DROP TABLE #counterparty_credit_enhancements

	SELECT DISTINCT --ccl.*, NULL netting_ic_id, NULL netting_contract_id 
		cce.counterparty_credit_info_id,
		cce.enhance_type,
		cce.guarantee_counterparty,
		cce.comment,
		cce.amount,
		cce.currency_code,
		cce.eff_date,
		cce.margin,
		cce.rely_self,
		cce.approved_by,
		cce.expiration_date,
		cce.exclude_collateral,
		ISNULL(sng.netting_contract_id, cce.contract_id) contract_id,
		ISNULL(sng.internal_counterparty_id, cce.internal_counterparty) internal_counterparty,
		cce.deal_id,
		cce.auto_renewal,
		cce.transferred,
		cce.is_primary,
		cce.collateral_status,
		cce.blocked
	INTO #counterparty_credit_enhancements
	FROM #cpty c
	INNER JOIN counterparty_credit_info cci ON cci.Counterparty_id = c.source_counterparty_id  
	INNER JOIN counterparty_credit_enhancements cce ON cce.counterparty_credit_info_id = cci.counterparty_credit_info_id

	OUTER APPLY (SELECT ISNULL(sng.internal_counterparty_id, @master_counterparty_id) AS internal_counterparty_id,
				sng.netting_contract_id
				FROM stmt_netting_group sng 
				INNER JOIN stmt_netting_group_detail sngd ON sngd.netting_group_id = sng.netting_group_id
					AND sngd.contract_detail_id = cce.contract_id
				OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date,
								MAX(sng1.internal_counterparty_id) AS internal_counterparty_id
							FROM stmt_netting_group sng1
							WHERE sng1.counterparty_id = sng.counterparty_id
							AND ISNULL(sng1.internal_counterparty_id, -1) = ISNULL(sng.internal_counterparty_id, -1)
							AND sng1.netting_type IN (109802,109800)
							AND sng1.effective_date <= @as_of_date) eff
				WHERE sng.counterparty_id = c.source_counterparty_id
				AND sng.effective_date = eff.eff_date
				AND ISNULL(sng.internal_counterparty_id, -1) = ISNULL(eff.internal_counterparty_id, -1)
				AND COALESCE(sng.internal_counterparty_id, cce.internal_counterparty, -1) = COALESCE(cce.internal_counterparty, sng.internal_counterparty_id, -1)
				AND sng.netting_type IN (109802,109800)) sng
	WHERE (cce.collateral_status = 105200 OR @do_not_check_collateral_status = 1)

	SET @sql_stmt = '
	CREATE TABLE '+@NettingDealProcessTableName+' (
		[ID] INT IDENTITY(1,1),
		fas_subsidiary_id int NOT NULL,
		fas_strategy_id int NOT NULL,
		fas_book_id int NOT NULL,
		[source_deal_header_id] [int] NOT NULL,
		[id_type] VARCHAR(1) NOT NULL, -- d means deal, i means invoice id or ref id for cash received, c for cash received/paid
		[term_start] [DATETIME] NOT NULL,
		[physical_financial_flag] [char](1)  NULL,
		[deal_type] [int] NULL,
		[deal_sub_type] [int] NULL,
		[source_counterparty_id] [int] NULL,
		[Final_Und_Pnl] [float] NULL,
		[Final_Dis_Pnl] [float] NULL,
		[contract_id] [int] NULL,
		[legal_entity] [int] NULL,	
		[orig_source_counterparty_id] [int] NULL,
		[hedge_type_value_id] [int] NULL,
		[commodity_id] INT NULL,
		[exp_type_id] VARCHAR(10), 
		[exp_type] VARCHAR(50), 
		[invoice_due_date] DATETIME,
		[deal_volume] FLOAT,	
		[fixed_price] FLOAT,
		[price_adder] FLOAT,
		[price_multiplier] FLOAT,
		[formula] VARCHAR(5000),
		[pnl_as_of_date] [datetime],
		parent_counterparty_id int
	) ON [PRIMARY]'
	
	--PRINT(@sql_stmt)
	EXEC(@sql_stmt)

	--The following are exp_types
	-- 1,	 2,	   3,		   4,			 5,			 6,			   7,		 8            
	-- MTM+, MTM-, A/R Billed, A/R UnBilled, A/P Billed, A/P UnBilled, Cash Rec, Cash Pay
	-- Note: Cash Rec should be put as - value and Cash Pay as + value (This is not the case for collateral however)
	-- 9			10			11					12
	-- Other MTM+	Other MTM-	Other A/R UnBilled	Other A/P UnBilled
	-----------------------POPULATE CALCPROCESS DEALS---------------------------------------------------
	----------------------------------------------------------------------------------------------------------------

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************End of Collecting Books and Counterparties *****************************'	
	END

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
	END

	EXEC spa_Calc_Discount_Factor @as_of_date, @sub_entity_id, @strategy_entity_id, @book_entity_id, @DiscountTableName

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************End of Calculating discount factors *****************************'	
	END


	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
	END

	-----------------------RETRIEVE ALL PARTICIPATING DEALS FIRST---------------------------------------------------
	----------------------------------------------------------------------------------------------------------------
	
	if ISNULL(@simulation,'n')='y'
		SET @sql_stmt = '	
			insert INTO ' + @NettingDealProcessTableName + '(			
				fas_subsidiary_id ,
				fas_strategy_id ,
				fas_book_id  ,
				[source_deal_header_id],
				[id_type],
				[term_start],
				[physical_financial_flag],
				[deal_type],
				[deal_sub_type],
				[source_counterparty_id],
				[Final_Und_Pnl],
				[Final_Dis_Pnl],
				[contract_id],
				[legal_entity],	
				[orig_source_counterparty_id],
				[hedge_type_value_id],
				[commodity_id],
				[exp_type_id], 
				[exp_type], 
				[invoice_due_date],
				[pnl_as_of_date],
				parent_counterparty_id)
			SELECT		
				max(book.fas_subsidiary_id) fas_subsidiary_id,
				max(book.fas_strategy_id) fas_strategy_id,
				max(book.fas_book_id) fas_book_id,
				sdh.source_deal_header_id,
				''d'' id_type,
				sdd.term_start,
				max(sdh.physical_financial_flag) physical_financial_flag,
				max(sdh.source_deal_type_id) deal_type,
				max(sdh.deal_sub_type_type_id) deal_sub_type,
				max(sc.netting_counterparty_id) as source_counterparty_id,
				cast(null as float) AS [Final_Und_Pnl],
				cast(null as float) AS [Final_Dis_Pnl],   --need to mulitply by discount factor later
				max(sdh.contract_id) contract_id,
				max(coalesce(sdh.legal_entity, book.legal_entity_id)) legal_entity,
				max(sdh.counterparty_id) as orig_source_counterparty_id,
				max(book.hedge_type_value_id) hedge_type_value_id,
				max(sdh.commodity_id) commodity_id,
				--case when (isnull(max(cd.und_pnl), 0) > 0) then 1 else 2 end 
				null exp_type_id,
				--case when (isnull(max(cd.und_pnl), 0) > 0) then ''MTM+'' else ''MTM-'' end 
				null exp_type,
				NULL invoice_due_date,
				cast(null as datetime) pnl_as_of_date,
				max(sc.parent_counterparty_id)				
			FROM #books book 
			INNER JOIN source_system_book_map sbm ON book.fas_book_id = sbm.fas_book_id 
			INNER JOIN ' + @deal_header_table + ' sdh ON sdh.source_system_book_id1 = sbm.source_system_book_id1 
				AND sdh.source_system_book_id2 = sbm.source_system_book_id2 
				AND sdh.source_system_book_id3 = sbm.source_system_book_id3 
				AND sdh.source_system_book_id4 = sbm.source_system_book_id4 '
			+CASE WHEN (@what_if_group IS NOT NULL OR @what_if_group <> 'n') THEN 
				' AND (sdh.deal_category_value_id = 475 OR sdh.deal_category_value_id = 477) '
			ELSE  ' 
				AND (sdh.deal_category_value_id = 475) '
			END +'
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = ISNULL(sdh.deal_status,5604)
			INNER JOIN ' + @table_name + ' sdd on sdh.source_deal_header_id	= sdd.source_deal_header_id					  
			INNER JOIN	#cpty sc ON sc.source_counterparty_id = sdh.counterparty_id 
			GROUP BY sdh.source_deal_header_id, sdd.term_start '
	else
		SET @sql_stmt = '	
			insert INTO ' + @NettingDealProcessTableName + '(			
				fas_subsidiary_id ,
				fas_strategy_id ,
				fas_book_id  ,
				[source_deal_header_id],
				[id_type],
				[term_start],
				[physical_financial_flag],
				[deal_type],
				[deal_sub_type],
				[source_counterparty_id],
				[Final_Und_Pnl],
				[Final_Dis_Pnl],
				[contract_id],
				[legal_entity],	
				[orig_source_counterparty_id],
				[hedge_type_value_id],
				[commodity_id],
				[exp_type_id], 
				[exp_type], 
				[invoice_due_date],
				[pnl_as_of_date],
				parent_counterparty_id)
			SELECT		
				max(book.fas_subsidiary_id) fas_subsidiary_id,
				max(book.fas_strategy_id) fas_strategy_id,
				max(book.fas_book_id) fas_book_id,
				cd.source_deal_header_id,
				''d'' id_type,
				cd.term_start,
				max(sdh.physical_financial_flag) physical_financial_flag,
				max(sdh.source_deal_type_id) deal_type,
				max(sdh.deal_sub_type_type_id) deal_sub_type,
				max(sc.netting_counterparty_id) as source_counterparty_id,
				CASE WHEN max(sc.exclude_after) IS NOT NULL AND MAX(sdh.physical_financial_flag) = ''p'' THEN
					CASE WHEN cd.term_start <= max(sc.exclude_after) THEN	
						isnull(max(CASE WHEN sdh.is_environmental = ''y'' THEN cd.und_pnl ELSE CASE WHEN DATEDIFF(m,'''+@as_of_date+''',cd.term_start)<=CASE WHEN sdh.header_buy_sell_flag = ''b'' THEN '+@credit_physical_buy_mth+' ELSE '+@credit_physical_sell_mth+' END THEN  cd.und_pnl_set ELSE cd.und_pnl END END), 0)
					ELSE
						0
					END
				ELSE
					isnull(max(CASE WHEN sdh.is_environmental = ''y'' THEN cd.und_pnl ELSE 
					CASE WHEN DATEDIFF(m,'''+@as_of_date+''',cd.term_start)<=CASE WHEN sdh.header_buy_sell_flag = ''b'' THEN '+@credit_physical_buy_mth+' ELSE '+@credit_physical_sell_mth+' END THEN  cd.und_pnl_set ELSE cd.und_pnl END END), 0)
				END [Final_Und_Pnl],				
				--isnull(max(CASE WHEN DATEDIFF(m,'''+@as_of_date+''',cd.term_start)<=CASE WHEN sdh.header_buy_sell_flag = ''b'' THEN '+@credit_physical_buy_mth+' ELSE '+@credit_physical_sell_mth+' END THEN  cd.und_pnl_set ELSE cd.und_pnl END * isnull(df.discount_factor,1)), 0) AS [Final_Dis_Pnl],   --need to mulitply by discount factor later
				CASE WHEN max(sc.exclude_after) IS NOT NULL AND MAX(sdh.physical_financial_flag) = ''p'' THEN
					CASE WHEN cd.term_start <= max(sc.exclude_after) THEN	
						isnull(max(CASE WHEN sdh.is_environmental = ''y'' THEN cd.und_pnl ELSE CASE WHEN DATEDIFF(m,'''+@as_of_date+''',cd.term_start)<=CASE WHEN sdh.header_buy_sell_flag = ''b'' THEN '+@credit_physical_buy_mth+' ELSE '+@credit_physical_sell_mth+' END THEN  cd.dis_contract_value ELSE cd.dis_pnl END END), 0)
					ELSE
						0
					END
				ELSE
					CASE WHEN MAX(sdh.physical_financial_flag) = ''p'' THEN
						isnull(max(CASE WHEN sdh.is_environmental = ''y'' THEN cd.und_pnl ELSE CASE WHEN DATEDIFF(m,'''+@as_of_date+''',cd.term_start)<=CASE WHEN sdh.header_buy_sell_flag = ''b'' THEN '+@credit_physical_buy_mth+' ELSE '+@credit_physical_sell_mth+' END THEN  cd.dis_contract_value ELSE cd.dis_pnl END END), 0)
					ELSE
						isnull(max(cd.dis_pnl), 0)
					END
				END [Final_Dis_Pnl],
				max(sdh.contract_id) contract_id,
				max(coalesce(sdh.legal_entity, book.legal_entity_id)) legal_entity,
				max(sdh.counterparty_id) as orig_source_counterparty_id,
				max(book.hedge_type_value_id) hedge_type_value_id,
				max(sdh.commodity_id) commodity_id,
				case when (isnull(max(cd.und_pnl), 0) > 0) then 1 else 2 end exp_type_id,
				case when (isnull(max(cd.und_pnl), 0) > 0) then ''MTM+'' else ''MTM-'' end exp_type,
				NULL invoice_due_date,
				cd.pnl_as_of_date,
				ISNULL(MAX(cca.internal_counterparty_id), MAX(fs.counterparty_id))	parent_counterparty_id		
			FROM #books book 
			INNER JOIN source_system_book_map sbm ON book.fas_book_id = sbm.fas_book_id 
			INNER JOIN ' + @deal_header_table + ' sdh ON sdh.source_system_book_id1 = sbm.source_system_book_id1 
				AND sdh.source_system_book_id2 = sbm.source_system_book_id2 
				AND sdh.source_system_book_id3 = sbm.source_system_book_id3 
				AND sdh.source_system_book_id4 = sbm.source_system_book_id4 
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = ISNULL(sdh.deal_status,5604)
			INNER JOIN #cpty sc ON sc.source_counterparty_id = sdh.counterparty_id
			INNER JOIN fas_subsidiaries fs ON book.fas_subsidiary_id = fs.fas_subsidiary_id
			LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id
				AND fs.counterparty_id = cca.internal_counterparty_id 
				AND cca.contract_id = ISNULL(sdh.contract_id, cca.contract_id)
			INNER JOIN ' + @table_name + ' cd ON cd.source_deal_header_id = sdh.source_deal_header_id ' + 
			CASE WHEN @calc_type = 'w' AND @calc_type_rep = 'm' THEN 
				' AND cd.criteria_id = ' + CAST(@criteria_id AS VARCHAR) ELSE '' END +'
			LEFT OUTER JOIN ' + @DiscountTableName + ' df on  df.term_start = cd.term_start 
				and df.fas_subsidiary_id = book.fas_subsidiary_id
			LEFT JOIN source_deal_settlement sds ON sds.source_deal_header_id = cd.source_deal_header_id
				AND sds.as_of_date <= cd.pnl_as_of_date
				AND sds.term_start = cd.term_start
				AND sds.term_end = cd.term_end
				AND sdh.is_environmental = ''y''
			WHERE 1 = 1	
				AND cd.pnl_as_of_date = CONVERT(DATETIME, ''' + @as_of_date + ''', 102) 
				AND cd.leg = 1 
				AND (ISNULL(sdh.is_environmental, ''n'') = ''n'' OR sds.source_deal_header_id IS NULL)
				AND (sdh.is_environmental = ''y'' OR cd.term_end >= CONVERT(DATETIME, ''' + @as_of_date + ''', 102))
				AND cd.pnl_source_value_id = ' +  CAST(@curve_source_value_id  AS VARCHAR)
				+CASE WHEN (@what_if_group IS NOT NULL OR @what_if_group <> 'n') THEN 
					' AND (sdh.deal_category_value_id = 475 OR sdh.deal_category_value_id = 477) '
				ELSE  
					' AND (sdh.deal_category_value_id = 475) '
				END +' 
			GROUP BY cd.source_deal_header_id, cd.term_start, cd.pnl_as_of_date
			ORDER BY cd.pnl_as_of_date '

	--PRINT (@sql_stmt)
	EXEC (@sql_stmt)

	EXEC('create index indx_NettingDealProcessTableName_12 on '+@NettingDealProcessTableName+' (
			source_deal_header_id,term_start,hedge_type_value_id,source_counterparty_id)')

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************Collecting deals for counterparty exposure netting *****************************'	
	END



	---------------------------------INSERT HERE THE FOLLOWING IN TABLE @NettingDealProcessTableName)-----------------------------
	----exp_type_id = 3,		   4,			 5,			 6,			   7,		 8            
	----			  A/R Billed, A/R UnBilled, A/P Billed, A/P UnBilled, Cash Rec, Cash Pay
	---- Note: Cash Rec should be put as - value and Cash Pay as + value (This is not the case for collateral however)
	----       Data file will have opposite sign.. just multiply here by -1 while inserting
	----------------------------------------------------------------------------------------------

	IF @do_not_include_settlement = 0
	BEGIN	

	 SELECT MAX(as_of_date_finalised) as_of_date_finalised, 
		MAX(as_of_date_initial) as_of_date_initial, 
		contract_id,
		counterparty_id, 
		prod_date,
		invoice_type
	into #max_date 
	FROM (
			SELECT CASE WHEN ISNULL(finalized, 'n') = 'y' THEN MAX(as_of_date) ELSE NULL END  as_of_date_finalised,
				   CASE WHEN ISNULL(finalized, 'n') <> 'y' THEN MAX(as_of_date) ELSE NULL END  as_of_date_initial,
				   civv.counterparty_id,
				 --  DATEPART(YEAR,civv.prod_date) prod_year, DATEPART(MONTH,civv.prod_date) prod_month,
				   civv.contract_id,
				   ISNULL(civv.finalized, 'n') AS finalized,
				   max(civv.prod_date) prod_date,civv.invoice_type
				   
			FROM  calc_invoice_volume_variance civv
			INNER JOIN #cpty sc ON civv.counterparty_id = sc.source_counterparty_id
				   AND (@counterparty_id IS NULL OR (sc.source_counterparty_id  IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@counterparty_id))))
				   --AND civv.as_of_date <= @as_of_date
			GROUP BY --DATEPART(YEAR,civv.prod_date), DATEPART(MONTH,civv.prod_date) ,
			          civv.counterparty_id, civv.contract_id,civv.finalized,civv.as_of_date,civv.invoice_type
	    ) a GROUP BY --prod_year, prod_month,
	     contract_id,counterparty_id, prod_date,invoice_type



		--Taking value from source_deal_settlement
		SET @sql_stmt='
				INSERT INTO ' + @NettingDealProcessTableName + '(
					fas_subsidiary_id ,
					fas_strategy_id ,
					fas_book_id  ,
					[source_deal_header_id],
					[id_type],
					[term_start],
					[physical_financial_flag],
					[deal_type],
					[deal_sub_type],
					[source_counterparty_id],
					[Final_Und_Pnl],
					[Final_Dis_Pnl],
					[contract_id],
					[legal_entity],	
					[orig_source_counterparty_id],
					[hedge_type_value_id],
					[commodity_id],
					[exp_type_id], 
					[exp_type], 
					[invoice_due_date],
					pnl_as_of_date,
					parent_counterparty_id
				)
				SELECT 						
					MAX(COALESCE(cs.fas_subsidiary_id,dt.fas_subsidiary_id,-1)) fas_subsidiary_id,
					MAX(COALESCE(cs.fas_strategy_id,dt.fas_strategy_id,-1)) fas_strategy_id,
					MAX(COALESCE(cs.fas_book_id,dt.fas_book_id,-1)) fas_book_id,
					COALESCE(cs.source_deal_header_id,dt.source_deal_header_id,-1),''d'' id_type,
					COALESCE(dt.term_start+''-01'',cs.prod_date,'''+ CONVERT(varchar(7), @as_of_date , 120) +'-01'')  as [Term],
					MAX(cs.physical_financial_flag) physical_financial_flag,
					MAX(cs.source_deal_type_id) deal_type,
					MAX(cs.deal_sub_type_type_id) deal_sub_type,
					(sc.netting_counterparty_id) as source_counterparty_id,
					SUM(COALESCE(cs.value,sds.settlement_amount, 0)) AS [Final_Und_Pnl],
					SUM(COALESCE(cs.value,sds.settlement_amount,0)) AS [Final_Dis_Pnl],  
					ISNULL(MAX(cs.contract_id), MAX(dt.contract_id)) contract_id,
					MAX(cs.legal_entity) legal_entity,
					MAX(cs.counterparty_id) as orig_source_counterparty_id,
					MAX(cs.hedge_type_value_id) hedge_type_value_id,
					MAX(cs.commodity_id) commodity_id,
					case when max(cs.value) is null then case when sum(isnull(sds.settlement_amount,0))>0 then 4 else 6 end
					else 
						CASE WHEN SUM(COALESCE(cs.value, 0))>0 and cs.finalized=''y'' THEN 3
							 WHEN SUM(COALESCE(cs.value, 0))>0 and cs.finalized=''n'' THEN 4
							 WHEN SUM(COALESCE(cs.value, 0))<0 and cs.finalized=''y'' THEN 5
							 WHEN SUM(COALESCE(cs.value, 0))<0 and cs.finalized=''n'' THEN 6
						END
					end  AS exp_type_id,
					case when max(cs.value) is null then case when sum(isnull(sds.settlement_amount,0))>0 then ''A/R UnBilled'' else '' A/P UnBilled'' end
					else
						CASE WHEN SUM(COALESCE(cs.value, 0))>0 and cs.finalized=''y'' THEN ''A/R Billed''
							 WHEN SUM(COALESCE(cs.value, 0))>0 and cs.finalized=''n'' THEN ''A/R UnBilled''
							 WHEN SUM(COALESCE(cs.value, 0))<0 and cs.finalized=''y'' THEN '' A/P Billed''
							 WHEN SUM(COALESCE(cs.value, 0))<0 and cs.finalized=''n'' THEN '' A/P UnBilled''
						END
					end AS exp_type,
					NULL invoice_due_date ,'''+CAST(@as_of_date AS VARCHAR)+''' pnl_as_of_date,
					ISNULL(max(cs.internal_counterparty_id), MAX(dt.internal_counterparty_id))
				FROM #cpty sc  
				outer apply
				(
					select 
						h.source_deal_header_id,
						max(as_of_date) as_of_date,
						CONVERT(varchar(7), a.term_start,120) term_start,
						h.counterparty_id,
						h.contract_id, 
						max(book1.fas_subsidiary_id) fas_subsidiary_id,
						book1.fas_strategy_id,
						book1.fas_book_id, 
						ISNULL(max(cca2.internal_counterparty_id), MAX(fs1.counterparty_id)) internal_counterparty_id,
						CASE WHEN MAX(cca1.offset_method) = 43501 THEN 
						MAX(COALESCE(
						(dbo.FNAInvoiceDueDate((ISNULL((a.term_start), GETDATE())), cca1.invoice_due_date, cca1.holiday_calendar_id, cca1.payment_days)),
						(dbo.FNAInvoiceDueDate((ISNULL((a.term_start), GETDATE())), cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days)),
						(a.settlement_date),
						(a.term_end)))
						ELSE
						DATEADD(dd, 1, ''' + CAST(@as_of_date AS VARCHAR) + ''')
						END AS [invoice_due_date] '

				SET @sql_stmt1='
					FROM source_deal_settlement a 
					INNER JOIN ' + @deal_header_table + ' h ON a.source_deal_header_id = h.source_deal_header_id 
						AND h.counterparty_id=sc.source_counterparty_id 
						AND leg = 1
					INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = ISNULL(h.deal_status,5604)
					LEFT JOIN source_system_book_map sbm1 ON h.source_system_book_id1 = sbm1.source_system_book_id1 AND 
						h.source_system_book_id2 = sbm1.source_system_book_id2 AND 
						h.source_system_book_id3 = sbm1.source_system_book_id3 AND 
						h.source_system_book_id4 = sbm1.source_system_book_id4
					LEFT JOIN #books book1 ON book1.fas_book_id = sbm1.fas_book_id
					LEFT JOIN fas_subsidiaries fs1 ON book1.fas_subsidiary_id = fs1.fas_subsidiary_id

					OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date 
								FROM stmt_netting_group sng1
								WHERE sng1.counterparty_id = sc.source_counterparty_id
								AND sng1.netting_type IN (109802,109800)
								AND sng1.effective_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''') eff

					OUTER APPLY (SELECT DISTINCT sng.netting_contract_id
							FROM stmt_netting_group sng 
							INNER JOIN stmt_netting_group_detail sngd ON sngd.netting_group_id = sng.netting_group_id
								AND sngd.contract_detail_id = COALESCE(h.contract_id, sngd.contract_detail_id)
							INNER JOIN counterparty_contract_address cca1 ON cca1.counterparty_id = sng.counterparty_id
								AND cca1.contract_id = sng.netting_contract_id
							OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date,
										MAX(sng1.internal_counterparty_id) AS internal_counterparty_id 
										FROM stmt_netting_group sng1
										WHERE sng1.counterparty_id = sng.counterparty_id
										AND ISNULL(sng1.internal_counterparty_id, -1) = ISNULL(sng.internal_counterparty_id, -1)
										AND sng1.netting_type IN (109802,109800)
										AND sng1.effective_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''') eff
							WHERE sng.counterparty_id = sc.source_counterparty_id
							AND COALESCE(sng.internal_counterparty_id, cca1.internal_counterparty_id, -1) = COALESCE(cca1.internal_counterparty_id, sng.internal_counterparty_id, -1)
							AND sng.effective_date = eff.eff_date
							AND ISNULL(sng.internal_counterparty_id, -1) = ISNULL(eff.internal_counterparty_id, -1)
							AND sng.netting_type IN (109802,109800)) sng

				LEFT JOIN counterparty_contract_address cca2 ON cca2.counterparty_id = sc.source_counterparty_id
					AND (cca2.internal_counterparty_id IS NULL OR cca2.internal_counterparty_id=fs1.counterparty_id) 
					AND cca2.contract_id = COALESCE(h.contract_id, cca2.contract_id)

				LEFT JOIN counterparty_contract_address cca1 ON cca1.counterparty_id = sc.source_counterparty_id
					AND (cca1.internal_counterparty_id IS NULL OR cca1.internal_counterparty_id=fs1.counterparty_id) 
					AND ((cca1.contract_id = sng.netting_contract_id) OR (cca1.contract_id =  
										COALESCE(h.contract_id, cca1.contract_id)))
				LEFT JOIN contract_group cg ON cg.contract_id = CASE WHEN eff.eff_date IS NOT NULL									THEN sng.netting_contract_id ELSE h.contract_id END
				OUTER APPLY(SELECT MAX(sdd.source_deal_header_id) source_deal_header_id 
					FROM stmt_checkout sc 
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id= sc.source_deal_detail_id 
					WHERE sdd.source_deal_header_id = a.source_deal_header_id 
						AND sdd.leg = a.leg 
						AND sdd.term_start = a.term_start
						AND sc.accrual_or_final = ''f''
						AND (sc.accrual_or_final = ''f'' OR ISNULL(sc.is_ignore, 0) = 1)
						AND sc.deal_charge_type_id=-5500) stc
				WHERE stc.source_deal_header_id IS NULL
				AND ( (set_type = ''f'' AND as_of_date <= CONVERT(DATETIME, ''' + @as_of_date + ''', 102)) OR (set_type = ''s''  AND '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''>=a.term_end))
				GROUP BY h.source_deal_header_id,
					CONVERT(varchar(7), a.term_start,120),
					h.counterparty_id,
					h.contract_id,
					book1.fas_subsidiary_id,
					book1.fas_strategy_id,
					book1.fas_book_id
				) dt
				OUTER APPLY(SELECT ngd.netting_group_id,ngdc.source_contract_id contract_id 
					FROM netting_group ng 
					INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
					INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_detail_id 
					WHERE ngd.source_counterparty_id=dt.counterparty_id						
						AND ngdc.source_contract_id=dt.contract_id	 
						AND CAST(dt.term_start+''-01'' AS DATETIME) BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
					) netting_group			
				outer apply
				(
					select 
					ISNULL(book.fas_subsidiary_id,-1) fas_subsidiary_id,
					ISNULL(book.fas_strategy_id,-1) fas_strategy_id,
					ISNULL(book.fas_book_id,-1) fas_book_id,
					ISNULL(sdh.source_deal_header_id,-1) source_deal_header_id,
					isnull(civv.prod_date,'''+ CONVERT(VARCHAR(7), @as_of_date , 120) +'-01'') as prod_date,
					sdh.physical_financial_flag,
					sdh.source_deal_type_id,
					sdh.deal_sub_type_type_id,
					sc.netting_counterparty_id,
					 '


			SET @sql_stmt2 = 		
					'	SUM(COALESCE(cfv.value,civd.value, 0)) AS value,
						coalesce(netting_group.contract_id,civv.contract_id,sdh.contract_id) contract_id,
						coalesce(sdh.legal_entity, book.legal_entity_id) legal_entity,
						sdh.counterparty_id,
						book.hedge_type_value_id hedge_type_value_id,
						sdh.commodity_id,
						ISNULL(civv.finalized,''n'') finalized,
						COALESCE(icr.settle_status,icr1.settle_status,''o'') settle_status,
						ISNULL(cca.internal_counterparty_id, fs.counterparty_id) internal_counterparty_id
					from #max_date mdt 
					inner join calc_invoice_volume_variance civv  on mdt.counterparty_id= sc.source_counterparty_id 
						and  civv.counterparty_id=mdt.counterparty_id 
						AND civv.contract_id=mdt.contract_id 
						AND civv.prod_date=mdt.prod_date 
						AND civv.as_of_date=Isnull(mdt.as_of_date_finalised, mdt.as_of_date_initial) 
						and civv.prod_date=dt.term_start+''-01''
						and civv.invoice_type=mdt.invoice_type 
						AND civv.as_of_date = COALESCE(mdt.as_of_date_finalised,mdt.as_of_date_initial,dt.as_of_date)
					INNER JOIN calc_invoice_volume civd ON civd.calc_id = civv.calc_id 	AND ISNULL(civd.manual_input,''n'')=''n'' 
					INNER JOIN calc_formula_value cfv ON cfv.calc_id = civd.calc_id AND civd.invoice_line_item_id = cfv.invoice_line_item_id AND is_final_result = ''y''  AND  COALESCE(cfv.source_deal_header_id,cfv.deal_id) IS NOT NULL
					LEFT JOIN ' + @deal_detail_table + '  sdd ON sdd.source_deal_detail_id=cfv.deal_id 		
					LEFT JOIN ' + @deal_header_table + '  sdh ON sdh.source_deal_header_id = ISNULL(cfv.source_deal_header_id,sdd.source_deal_header_id)
					LEFT JOIN source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
						  sdh.source_system_book_id2 = sbm.source_system_book_id2 AND 
						  sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
						  sdh.source_system_book_id4 = sbm.source_system_book_id4
					LEFT JOIN #books book ON book.fas_book_id = sbm.fas_book_id
					LEFT JOIN fas_subsidiaries fs ON book.fas_subsidiary_id = fs.fas_subsidiary_id
					LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id
						AND fs.counterparty_id = cca.internal_counterparty_id 
						AND cca.contract_id = ISNULL(sdh.contract_id, sdh.contract_id) 
						--AND cca.apply_netting_rule = ''y''	  
					left JOIN invoice_cash_received icr on icr.save_invoice_detail_id=civd.calc_detail_id
					LEFT JOIN contract_group_detail cgd ON cgd.contract_id = ISNULL(netting_group.contract_id,civv.contract_id) AND cgd.invoice_line_item_id = civd.invoice_line_item_id
					CROSS APPLY(
						SELECT 
						MIN(icr.settle_status) [settle_status] FROM contract_group_detail cgd1 
							INNER JOIN calc_invoice_volume cv ON cv.invoice_line_item_id = cgd1.invoice_line_item_id AND cgd1.contract_id = civv.contract_id
							INNER JOIN invoice_cash_received icr ON icr.save_invoice_detail_id = cv.calc_detail_id
						WHERE
							cgd1.contract_id = civv.contract_id
							AND cgd1.alias = cgd.alias
							AND cv.calc_id =  civv.calc_id						
					) icr1
					WHERE COALESCE(cfv.source_deal_header_id,sdd.source_deal_header_id)=dt.source_deal_header_id 
						  AND civv.counterparty_id = dt.counterparty_id
						  AND ((civv.contract_id = dt.contract_id AND civv.netting_group_id IS NULL) OR ( netting_group.netting_group_id = civv.netting_group_id))					  
						  AND ABS(COALESCE(cfv.value,civd.value, 0))<>0 
						  AND cgd.hideInInvoice = ''s''
						  AND ((COALESCE(icr.settle_status,icr1.settle_status,''o'') <> ''s'' 
								AND YEAR(dt.as_of_date) = YEAR(civv.as_of_date) AND MONTH(dt.as_of_date) = MONTH(civv.as_of_date)) OR (COALESCE(icr.settle_status,icr1.settle_status,''o'') = ''s''))
					 GROUP BY book.fas_subsidiary_id,
						book.fas_strategy_id,
						book.fas_book_id,
						sdh.source_deal_header_id,
						civv.prod_date,
						sdh.physical_financial_flag,
						sdh.source_deal_type_id,
						sdh.deal_sub_type_type_id,
						civv.contract_id,
						sdh.counterparty_id,
						sdh.legal_entity,
						book.legal_entity_id,
						sdh.contract_id,
						book.hedge_type_value_id, 
						sdh.commodity_id,	
						civv.finalized,
						COALESCE(icr.settle_status,icr1.settle_status,''o''),
						ISNULL(cca.internal_counterparty_id, fs.counterparty_id)
				) cs	
				OUTER APPLY(SELECT sum(sds.settlement_amount) settlement_amount,
							CONVERT(varchar(7), sds.term_start,120) term_start 
					FROM  source_deal_settlement sds
					OUTER APPLY(SELECT MAX(sdd.source_deal_header_id) source_deal_header_id 
								FROM stmt_checkout sc 
								INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id= sc.source_deal_detail_id 
								WHERE sdd.source_deal_header_id = sds.source_deal_header_id 
									AND sdd.leg = sds.leg AND sdd.term_start = sds.term_start
									AND (sc.accrual_or_final = ''f'' OR ISNULL(sc.is_ignore, 0) = 1)
									AND sc.deal_charge_type_id=-5500) stc
					WHERE sds.source_deal_header_id = ISNULL(dt.source_deal_header_id,-1) 
					and CONVERT(varchar(7), sds.term_start,120) = dt.term_start
					AND sds.leg = 1 
					AND stc.source_deal_header_id IS NULL
					AND sds.as_of_date = dt.as_of_date
					and sds.term_start <= '''+CAST(@as_of_date AS VARCHAR)+'''
					GROUP BY CONVERT(varchar(7), sds.term_start,120)) sds
				WHERE COALESCE(cs.value,sds.settlement_amount,0)<>0
				AND ''' + CAST(@as_of_date AS VARCHAR) + ''' < CONVERT(VARCHAR(10), dt.invoice_due_date, 120)
				AND ISNULL(cs.settle_status,''o'') <> ''s''
			GROUP BY COALESCE(cs.source_deal_header_id,dt.source_deal_header_id,-1),
				COALESCE(dt.term_start+''-01'',cs.prod_date,'''+ CONVERT(varchar(7), @as_of_date , 120) +'-01'') ,
				cs.finalized,
				sc.netting_counterparty_id
			HAVING ROUND(SUM(COALESCE(cs.value,sds.settlement_amount)),2)  <> 0'
		
		--PRINT (@sql_stmt)
		--PRINT(@sql_stmt1)	
		--PRINT(@sql_stmt2)		
		EXEC(@sql_stmt+@sql_stmt1+@sql_stmt2)

		
		IF OBJECT_ID('tempdb..#tmp_fees_to_take_in_exposure') IS NOT NULL 
			DROP TABLE #tmp_fees_to_take_in_exposure

		SELECT field_id
		INTO #tmp_fees_to_take_in_exposure
		FROM user_defined_fields_template 
		WHERE ISNULL(include_in_credit_exposure, 'n') = 'y'
		UNION
		SELECT -5500

		--Taking fees from index_fees_breakdown
		SET @sql_stmt = '
		INSERT INTO ' + @NettingDealProcessTableName + '(			
				fas_subsidiary_id ,
				fas_strategy_id ,
				fas_book_id  ,
				[source_deal_header_id],
				[id_type],
				[term_start],
				[physical_financial_flag],
				[deal_type],
				[deal_sub_type],
				[source_counterparty_id],
				[Final_Und_Pnl],
				[Final_Dis_Pnl],
				[contract_id],
				[legal_entity],	
				[orig_source_counterparty_id],
				[hedge_type_value_id],
				[commodity_id],
				[exp_type_id], 
				[exp_type], 
				[invoice_due_date],
				[pnl_as_of_date],
				parent_counterparty_id)
			SELECT		
				max(book.fas_subsidiary_id) fas_subsidiary_id,
				max(book.fas_strategy_id) fas_strategy_id,
				max(book.fas_book_id) fas_book_id,
				cd.source_deal_header_id,
				''d'' id_type,
				cd.term_start,
				max(sdh.physical_financial_flag) physical_financial_flag,
				max(sdh.source_deal_type_id) deal_type,
				max(sdh.deal_sub_type_type_id) deal_sub_type,
				max(sc.netting_counterparty_id) as source_counterparty_id,
				CASE WHEN MAX(sc.exclude_after) IS NOT NULL AND MAX(sdh.physical_financial_flag) = ''p'' THEN
					CASE WHEN cd.term_start <= MAX(sc.exclude_after) THEN	
						ISNULL(SUM(cd.value), 0)
					ELSE
						0
					END
				ELSE
					ISNULL(SUM(cd.value), 0)
				END [Final_Und_Pnl],				
				
				CASE WHEN max(sc.exclude_after) IS NOT NULL AND MAX(sdh.physical_financial_flag) = ''p'' THEN
					CASE WHEN cd.term_start <= MAX(sc.exclude_after) THEN	
						ISNULL(SUM(cd.value), 0)
					ELSE
						0
					END
				ELSE
					ISNULL(SUM(cd.value), 0)
				END [Final_Dis_Pnl],
				max(sdh.contract_id) contract_id,
				max(coalesce(sdh.legal_entity, book.legal_entity_id)) legal_entity,
				max(sdh.counterparty_id) as orig_source_counterparty_id,
				max(book.hedge_type_value_id) hedge_type_value_id,
				max(sdh.commodity_id) commodity_id,
				case when (isnull(max(cd.value), 0) > 0) then 9 else 10 end exp_type_id,
				case when (isnull(max(cd.value), 0) > 0) then ''Other MTM+'' else ''Other MTM-'' end exp_type,
				NULL invoice_due_date,
				cd.as_of_date,
				ISNULL(MAX(cca.internal_counterparty_id), MAX(fs.counterparty_id))	parent_counterparty_id		
			FROM #books book 
			INNER JOIN source_system_book_map sbm ON book.fas_book_id = sbm.fas_book_id 
			INNER JOIN ' + @deal_header_table + ' sdh ON sdh.source_system_book_id1 = sbm.source_system_book_id1 
				AND sdh.source_system_book_id2 = sbm.source_system_book_id2 
				AND sdh.source_system_book_id3 = sbm.source_system_book_id3 
				AND sdh.source_system_book_id4 = sbm.source_system_book_id4 
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = ISNULL(sdh.deal_status,5604)
			INNER JOIN #cpty sc ON sc.source_counterparty_id = sdh.counterparty_id
			INNER JOIN fas_subsidiaries fs ON book.fas_subsidiary_id = fs.fas_subsidiary_id
			LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id
				AND fs.counterparty_id = cca.internal_counterparty_id 
				AND cca.contract_id = ISNULL(sdh.contract_id, cca.contract_id)
			INNER JOIN index_fees_breakdown cd ON cd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #tmp_fees_to_take_in_exposure tfe ON tfe.field_id = cd.field_id 
			LEFT OUTER JOIN ' + @DiscountTableName + ' df on  df.term_start = cd.term_start 
				and df.fas_subsidiary_id = book.fas_subsidiary_id
			LEFT JOIN source_deal_settlement sds ON sds.source_deal_header_id = cd.source_deal_header_id
				AND sds.as_of_date <= cd.as_of_date
				AND sds.term_start = cd.term_start
				AND sds.term_end = cd.term_end
				AND sdh.is_environmental = ''y''
			WHERE 1 = 1	
				AND cd.as_of_date = CONVERT(DATETIME, ''' + @as_of_date + ''', 102) 
				AND cd.leg = 1 
				AND (ISNULL(sdh.is_environmental, ''n'') = ''n'' OR sds.source_deal_header_id IS NULL)
				AND (sdh.is_environmental = ''y'' OR cd.term_end >= CONVERT(DATETIME, ''' + @as_of_date + ''', 102)) '
				+ CASE WHEN (@what_if_group IS NOT NULL OR @what_if_group <> 'n') THEN 
					' AND (sdh.deal_category_value_id = 475 OR sdh.deal_category_value_id = 477) '
				ELSE  
					' AND (sdh.deal_category_value_id = 475) '
				END +' 
			GROUP BY cd.source_deal_header_id, cd.term_start, cd.as_of_date
			ORDER BY cd.as_of_date '

		--PRINT (@sql_stmt)
		EXEC (@sql_stmt)

		--Taking fees from index_fees_breakdown_settlement
		SET @sql_stmt='INSERT INTO ' + @NettingDealProcessTableName + '(
			fas_subsidiary_id ,
			fas_strategy_id ,
			fas_book_id  ,
			[source_deal_header_id],
			[id_type],
			[term_start],
			[physical_financial_flag],
			[deal_type],
			[deal_sub_type],
			[source_counterparty_id],
			[Final_Und_Pnl],
			[Final_Dis_Pnl],
			[contract_id],
			[legal_entity],	
			[orig_source_counterparty_id],
			[hedge_type_value_id],
			[commodity_id],
			[exp_type_id], 
			[exp_type], 
			[invoice_due_date],
			pnl_as_of_date,
			parent_counterparty_id)
		SELECT 						
			MAX(COALESCE(cs.fas_subsidiary_id,dt.fas_subsidiary_id,-1)) fas_subsidiary_id,
			MAX(COALESCE(cs.fas_strategy_id,dt.fas_strategy_id,-1)) fas_strategy_id,
			MAX(COALESCE(cs.fas_book_id,dt.fas_book_id,-1)) fas_book_id,
			COALESCE(cs.source_deal_header_id,dt.source_deal_header_id,-1),''d'' id_type,
			COALESCE(dt.term_start+''-01'',cs.prod_date,'''+ CONVERT(varchar(7), @as_of_date , 120) +'-01'')  as [Term],
			MAX(cs.physical_financial_flag) physical_financial_flag,
			MAX(cs.source_deal_type_id) deal_type,
			MAX(cs.deal_sub_type_type_id) deal_sub_type,
			(sc.netting_counterparty_id) as source_counterparty_id,
			SUM(COALESCE(cs.value,sds.settlement_amount, 0)) AS [Final_Und_Pnl],
			SUM(COALESCE(cs.value,sds.settlement_amount,0)) AS [Final_Dis_Pnl],  
			ISNULL(MAX(cs.contract_id), MAX(dt.contract_id)) contract_id,
			MAX(cs.legal_entity) legal_entity,
			MAX(cs.counterparty_id) as orig_source_counterparty_id,
			MAX(cs.hedge_type_value_id) hedge_type_value_id,
			MAX(cs.commodity_id) commodity_id,
			CASE WHEN MAX(cs.value) IS NULL THEN 
				CASE WHEN SUM(ISNULL(sds.settlement_amount,0)) > 0 THEN 
					11 
				ELSE 
					12 
				END
			ELSE 
				CASE 
						WHEN SUM(COALESCE(cs.value, 0)) >0 THEN 11
						WHEN SUM(COALESCE(cs.value, 0)) <0 THEN 12
				END
			END  AS exp_type_id,
			CASE WHEN MAX(cs.value) IS NULL THEN 
				CASE WHEN SUM(ISNULL(sds.settlement_amount,0)) > 0 THEN 
					''Other A/R UnBilled'' 
				ELSE 
					''Other A/P UnBilled'' 
				END
			ELSE
				CASE 
						WHEN SUM(COALESCE(cs.value, 0)) >0 THEN ''Other A/R UnBilled''
						WHEN SUM(COALESCE(cs.value, 0)) <0 THEN ''Other A/P UnBilled''
				END
			END AS exp_type,
			NULL invoice_due_date ,
			'''+CAST(@as_of_date AS VARCHAR)+''' pnl_as_of_date,
			ISNULL(MAX(cs.internal_counterparty_id), 
			MAX(dt.internal_counterparty_id))
		FROM #cpty sc  
		OUTER APPLY
		(
			SELECT 
				h.source_deal_header_id,
				MAX(as_of_date) as_of_date,
				CONVERT(varchar(7), a.term_start,120) term_start,
				h.counterparty_id,
				h.contract_id, 
				MAX(book1.fas_subsidiary_id) fas_subsidiary_id,
				book1.fas_strategy_id,
				book1.fas_book_id, 
				MAX(cca2.internal_counterparty_id) internal_counterparty_id,
				CASE WHEN MAX(cca1.offset_method) = 43501 THEN 
				MAX(COALESCE(
				(dbo.FNAInvoiceDueDate((ISNULL((a.term_start), GETDATE())), cca1.invoice_due_date, cca1.holiday_calendar_id, cca1.payment_days)),
				(dbo.FNAInvoiceDueDate((ISNULL((a.term_start), GETDATE())), cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days)),
				(a.term_end)))
				ELSE
				DATEADD(dd, 1, ''' + CAST(@as_of_date AS VARCHAR) + ''')
				END AS [invoice_due_date] '
				
		SET @sql_stmt1='
			FROM index_fees_breakdown_settlement a 
			INNER JOIN #tmp_fees_to_take_in_exposure tfe ON tfe.field_id = a.field_id
			INNER JOIN ' + @deal_header_table + ' h ON a.source_deal_header_id = h.source_deal_header_id 
				AND h.counterparty_id=sc.source_counterparty_id 
				AND leg = 1
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = ISNULL(h.deal_status,5604)
			LEFT JOIN source_system_book_map sbm1 ON h.source_system_book_id1 = sbm1.source_system_book_id1 AND 
				h.source_system_book_id2 = sbm1.source_system_book_id2 AND 
				h.source_system_book_id3 = sbm1.source_system_book_id3 AND 
				h.source_system_book_id4 = sbm1.source_system_book_id4
			LEFT JOIN #books book1 ON book1.fas_book_id = sbm1.fas_book_id
			LEFT JOIN fas_subsidiaries fs1 ON book1.fas_subsidiary_id = fs1.fas_subsidiary_id

			OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date 
						FROM stmt_netting_group sng1
						WHERE sng1.counterparty_id = sc.source_counterparty_id
						AND sng1.netting_type IN (109802,109800)
						AND sng1.effective_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''') eff

			OUTER APPLY (SELECT DISTINCT sng.netting_contract_id
					FROM stmt_netting_group sng 
					INNER JOIN stmt_netting_group_detail sngd ON sngd.netting_group_id = sng.netting_group_id
						AND sngd.contract_detail_id = COALESCE(h.contract_id, sngd.contract_detail_id)
					INNER JOIN counterparty_contract_address cca1 ON cca1.counterparty_id = sng.counterparty_id
						AND cca1.contract_id = sng.netting_contract_id
					OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date,
								MAX(sng1.internal_counterparty_id) AS internal_counterparty_id 
								FROM stmt_netting_group sng1
								WHERE sng1.counterparty_id = sng.counterparty_id
								AND ISNULL(sng1.internal_counterparty_id, -1) = ISNULL(sng.internal_counterparty_id, -1)
								AND sng1.netting_type IN (109802,109800)
								AND sng1.effective_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''') eff
					WHERE sng.counterparty_id = sc.source_counterparty_id
					AND COALESCE(sng.internal_counterparty_id, cca1.internal_counterparty_id, -1) = COALESCE(cca1.internal_counterparty_id, sng.internal_counterparty_id, -1)
					AND sng.effective_date = eff.eff_date
					AND ISNULL(sng.internal_counterparty_id, -1) = ISNULL(eff.internal_counterparty_id, -1)
					AND sng.netting_type IN (109802,109800)) sng

				LEFT JOIN counterparty_contract_address cca2 ON cca2.counterparty_id = sc.source_counterparty_id
					AND (cca2.internal_counterparty_id IS NULL OR cca2.internal_counterparty_id=fs1.counterparty_id) 
					AND cca2.contract_id = COALESCE(h.contract_id, cca2.contract_id)

				LEFT JOIN counterparty_contract_address cca1 ON cca1.counterparty_id = sc.source_counterparty_id
					AND (cca1.internal_counterparty_id IS NULL OR cca1.internal_counterparty_id=fs1.counterparty_id) 
					AND cca1.contract_id = CASE WHEN eff.eff_date IS NOT NULL THEN 
											sng.netting_contract_id 
										ELSE COALESCE(h.contract_id, cca1.contract_id) END
				LEFT JOIN contract_group cg ON cg.contract_id = CASE WHEN eff.eff_date IS NOT NULL									THEN sng.netting_contract_id ELSE h.contract_id END
				OUTER APPLY(SELECT MAX(sdd.source_deal_header_id) source_deal_header_id 
					FROM stmt_checkout sc 
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id= sc.source_deal_detail_id 
					WHERE sdd.source_deal_header_id = a.source_deal_header_id 
						AND sdd.leg = a.leg 
						AND sdd.term_start = a.term_start
						AND sc.accrual_or_final = ''f''
						AND sc.deal_charge_type_id = tfe.field_id
						AND (sc.accrual_or_final = ''f'' OR ISNULL(sc.is_ignore, 0) = 1)) stc
				WHERE stc.source_deal_header_id IS NULL
				AND ( (set_type = ''f'' AND as_of_date <= CONVERT(DATETIME, ''' + @as_of_date + ''', 102)) OR (set_type = ''s''  AND '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''>=a.term_end))
				GROUP BY h.source_deal_header_id,
					CONVERT(varchar(7), a.term_start,120),
					h.counterparty_id,
					h.contract_id,
					book1.fas_subsidiary_id,
					book1.fas_strategy_id,
					book1.fas_book_id
				) dt
				OUTER APPLY(SELECT ngd.netting_group_id,ngdc.source_contract_id contract_id 
					FROM netting_group ng 
					INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
					INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_detail_id 
					WHERE ngd.source_counterparty_id=dt.counterparty_id						
						AND ngdc.source_contract_id=dt.contract_id	 
						AND CAST(dt.term_start+''-01'' AS DATETIME) BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
					) netting_group			
				outer apply
				(
					select 
					ISNULL(book.fas_subsidiary_id,-1) fas_subsidiary_id,
					ISNULL(book.fas_strategy_id,-1) fas_strategy_id,
					ISNULL(book.fas_book_id,-1) fas_book_id,
					ISNULL(sdh.source_deal_header_id,-1) source_deal_header_id,
					isnull(civv.prod_date,'''+ CONVERT(VARCHAR(7), @as_of_date , 120) +'-01'') as prod_date,
					sdh.physical_financial_flag,
					sdh.source_deal_type_id,
					sdh.deal_sub_type_type_id,
					sc.netting_counterparty_id,
					 '


			SET @sql_stmt2 = 		
					'	SUM(COALESCE(cfv.value,civd.value, 0)) AS value,
						coalesce(netting_group.contract_id,civv.contract_id,sdh.contract_id) contract_id,
						coalesce(sdh.legal_entity, book.legal_entity_id) legal_entity,
						sdh.counterparty_id,
						book.hedge_type_value_id hedge_type_value_id,
						sdh.commodity_id,
						--ISNULL(civv.finalized,''n'') finalized,
						COALESCE(icr.settle_status,icr1.settle_status,''o'') settle_status,
						cca.internal_counterparty_id
					from #max_date mdt 
					inner join calc_invoice_volume_variance civv  on mdt.counterparty_id= sc.source_counterparty_id 
						and  civv.counterparty_id=mdt.counterparty_id 
						AND civv.contract_id=mdt.contract_id 
						AND civv.prod_date=mdt.prod_date 
						AND civv.as_of_date=Isnull(mdt.as_of_date_finalised, mdt.as_of_date_initial) 
						and civv.prod_date=dt.term_start+''-01''
						and civv.invoice_type=mdt.invoice_type 
						AND civv.as_of_date = COALESCE(mdt.as_of_date_finalised,mdt.as_of_date_initial,dt.as_of_date)
					INNER JOIN calc_invoice_volume civd ON civd.calc_id = civv.calc_id 	AND ISNULL(civd.manual_input,''n'')=''n'' 
					INNER JOIN calc_formula_value cfv ON cfv.calc_id = civd.calc_id AND civd.invoice_line_item_id = cfv.invoice_line_item_id AND is_final_result = ''y''  AND  COALESCE(cfv.source_deal_header_id,cfv.deal_id) IS NOT NULL
					LEFT JOIN ' + @deal_detail_table + '  sdd ON sdd.source_deal_detail_id=cfv.deal_id 		
					LEFT JOIN ' + @deal_header_table + '  sdh ON sdh.source_deal_header_id = ISNULL(cfv.source_deal_header_id,sdd.source_deal_header_id)
					LEFT JOIN source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
						  sdh.source_system_book_id2 = sbm.source_system_book_id2 AND 
						  sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
						  sdh.source_system_book_id4 = sbm.source_system_book_id4
					LEFT JOIN #books book ON book.fas_book_id = sbm.fas_book_id
					LEFT JOIN fas_subsidiaries fs ON book.fas_subsidiary_id = fs.fas_subsidiary_id
					LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id
						AND fs.counterparty_id = cca.internal_counterparty_id 
						AND cca.contract_id = ISNULL(sdh.contract_id, sdh.contract_id) 
						--AND cca.apply_netting_rule = ''y''	  
					left JOIN invoice_cash_received icr on icr.save_invoice_detail_id=civd.calc_detail_id
					LEFT JOIN contract_group_detail cgd ON cgd.contract_id = ISNULL(netting_group.contract_id,civv.contract_id) AND cgd.invoice_line_item_id = civd.invoice_line_item_id
					CROSS APPLY(
						SELECT 
						MIN(icr.settle_status) [settle_status] FROM contract_group_detail cgd1 
							INNER JOIN calc_invoice_volume cv ON cv.invoice_line_item_id = cgd1.invoice_line_item_id AND cgd1.contract_id = civv.contract_id
							INNER JOIN invoice_cash_received icr ON icr.save_invoice_detail_id = cv.calc_detail_id
						WHERE
							cgd1.contract_id = civv.contract_id
							AND cgd1.alias = cgd.alias
							AND cv.calc_id =  civv.calc_id						
					) icr1
					WHERE COALESCE(cfv.source_deal_header_id,sdd.source_deal_header_id)=dt.source_deal_header_id 
					AND civv.counterparty_id = dt.counterparty_id
					AND ((civv.contract_id = dt.contract_id AND civv.netting_group_id IS NULL) OR ( netting_group.netting_group_id = civv.netting_group_id))					  
					AND ABS(COALESCE(cfv.value,civd.value, 0))<>0 
					AND cgd.hideInInvoice = ''s''
					AND ISNULL(civv.finalized,''n'') = ''n''
					AND ((COALESCE(icr.settle_status,icr1.settle_status,''o'') <> ''s'' 
						AND YEAR(dt.as_of_date) = YEAR(civv.as_of_date) AND MONTH(dt.as_of_date) = MONTH(civv.as_of_date)) OR (COALESCE(icr.settle_status,icr1.settle_status,''o'') = ''s''))
					 GROUP BY book.fas_subsidiary_id,
						book.fas_strategy_id,
						book.fas_book_id,
						sdh.source_deal_header_id,
						civv.prod_date,
						sdh.physical_financial_flag,
						sdh.source_deal_type_id,
						sdh.deal_sub_type_type_id,
						civv.contract_id,
						sdh.counterparty_id,
						sdh.legal_entity,
						book.legal_entity_id,
						sdh.contract_id,
						book.hedge_type_value_id, 
						sdh.commodity_id,	
						--civv.finalized,
						COALESCE(icr.settle_status,icr1.settle_status,''o''),
						cca.internal_counterparty_id
				) cs	
				OUTER APPLY(SELECT sum(sds.value) settlement_amount,
							CONVERT(varchar(7), sds.term_start,120) term_start 
					FROM  index_fees_breakdown_settlement sds
					INNER JOIN #tmp_fees_to_take_in_exposure tfe ON tfe.field_id = sds.field_id
					OUTER APPLY(SELECT MAX(sdd.source_deal_header_id) source_deal_header_id 
								FROM stmt_checkout sc 
								INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id= sc.source_deal_detail_id 
								WHERE sdd.source_deal_header_id = sds.source_deal_header_id 
									AND sdd.leg = sds.leg AND sdd.term_start = sds.term_start
									AND sc.deal_charge_type_id = tfe.field_id
									AND (sc.accrual_or_final = ''f'' OR ISNULL(sc.is_ignore, 0) = 1)
									--AND sc.deal_charge_type_id=-5500
									) stc
					WHERE sds.source_deal_header_id = ISNULL(dt.source_deal_header_id,-1) 
					and CONVERT(varchar(7), sds.term_start,120) = dt.term_start
					AND sds.leg = 1 
					AND stc.source_deal_header_id IS NULL
					AND sds.as_of_date = dt.as_of_date
					and sds.term_start <= '''+CAST(@as_of_date AS VARCHAR)+'''
					GROUP BY CONVERT(varchar(7), sds.term_start,120)) sds
				WHERE COALESCE(cs.value,sds.settlement_amount,0)<>0
				AND ''' + CAST(@as_of_date AS VARCHAR) + ''' < CONVERT(VARCHAR(10), dt.invoice_due_date, 120)
				AND ISNULL(cs.settle_status,''o'') <> ''s''
			GROUP BY COALESCE(cs.source_deal_header_id,dt.source_deal_header_id,-1),
				COALESCE(dt.term_start+''-01'',cs.prod_date,'''+ CONVERT(varchar(7), @as_of_date , 120) +'-01'') ,
				--cs.finalized,
				sc.netting_counterparty_id
			HAVING ROUND(SUM(COALESCE(cs.value,sds.settlement_amount)),2)  <> 0'
		
		--PRINT (@sql_stmt)
		--PRINT(@sql_stmt1)	
		--PRINT(@sql_stmt2)		
		EXEC(@sql_stmt+@sql_stmt1+@sql_stmt2)

		--Taking value from index_fees_breakdown_settlement 
		SET @sql_stmt='
				INSERT INTO ' + @NettingDealProcessTableName + '(
					fas_subsidiary_id ,
					fas_strategy_id ,
					fas_book_id  ,
					[source_deal_header_id],
					[id_type],
					[term_start],
					[physical_financial_flag],
					[deal_type],
					[deal_sub_type],
					[source_counterparty_id],
					[Final_Und_Pnl],
					[Final_Dis_Pnl],
					[contract_id],
					[legal_entity],	
					[orig_source_counterparty_id],
					[hedge_type_value_id],
					[commodity_id],
					[exp_type_id], 
					[exp_type], 
					[invoice_due_date],
					pnl_as_of_date,
					parent_counterparty_id)
				SELECT 						
					MAX(COALESCE(cs.fas_subsidiary_id,dt.fas_subsidiary_id,-1)) fas_subsidiary_id,
					MAX(COALESCE(cs.fas_strategy_id,dt.fas_strategy_id,-1)) fas_strategy_id,
					MAX(COALESCE(cs.fas_book_id,dt.fas_book_id,-1)) fas_book_id,
					COALESCE(cs.source_deal_header_id,dt.source_deal_header_id,-1),''d'' id_type,
					COALESCE(dt.term_start+''-01'',cs.prod_date,'''+ CONVERT(varchar(7), @as_of_date , 120) +'-01'')  as [Term],
					MAX(cs.physical_financial_flag) physical_financial_flag,
					MAX(cs.source_deal_type_id) deal_type,
					MAX(cs.deal_sub_type_type_id) deal_sub_type,
					(sc.netting_counterparty_id) as source_counterparty_id,
					SUM(COALESCE(cs.value, 0)) AS [Final_Und_Pnl],
					SUM(COALESCE(cs.value, 0)) AS [Final_Dis_Pnl],  
					ISNULL(MAX(cs.contract_id), MAX(dt.contract_id)) contract_id,
					MAX(cs.legal_entity) legal_entity,
					MAX(cs.counterparty_id) as orig_source_counterparty_id,
					MAX(cs.hedge_type_value_id) hedge_type_value_id,
					MAX(cs.commodity_id) commodity_id,
					CASE WHEN SUM(COALESCE(cs.value, 0))>0 and cs.finalized=''y'' THEN 3
							WHEN SUM(COALESCE(cs.value, 0))>0 and cs.finalized=''n'' THEN 4
							WHEN SUM(COALESCE(cs.value, 0))<0 and cs.finalized=''y'' THEN 5
							WHEN SUM(COALESCE(cs.value, 0))<0 and cs.finalized=''n'' THEN 6
					END AS exp_type_id,
					CASE WHEN SUM(COALESCE(cs.value, 0))>0 and cs.finalized=''y'' THEN ''A/R Billed''
							WHEN SUM(COALESCE(cs.value, 0))>0 and cs.finalized=''n'' THEN ''A/R UnBilled''
							WHEN SUM(COALESCE(cs.value, 0))<0 and cs.finalized=''y'' THEN '' A/P Billed''
							WHEN SUM(COALESCE(cs.value, 0))<0 and cs.finalized=''n'' THEN '' A/P UnBilled''
					END AS exp_type,
					NULL invoice_due_date ,'''+CAST(@as_of_date AS VARCHAR)+''' pnl_as_of_date,
					ISNULL(max(cs.internal_counterparty_id), MAX(dt.internal_counterparty_id))
				FROM #cpty sc  
				outer apply
				(
					select 
						h.source_deal_header_id,
						max(as_of_date) as_of_date,
						CONVERT(varchar(7), a.term_start,120) term_start,
						h.counterparty_id,
						h.contract_id, 
						max(book1.fas_subsidiary_id) fas_subsidiary_id,
						book1.fas_strategy_id,
						book1.fas_book_id, 
						max(cca2.internal_counterparty_id) internal_counterparty_id,
						CASE WHEN MAX(cca1.offset_method) = 43501 THEN 
						MAX(COALESCE(
						(dbo.FNAInvoiceDueDate((ISNULL((a.term_start), GETDATE())), cca1.invoice_due_date, cca1.holiday_calendar_id, cca1.payment_days)),
						(dbo.FNAInvoiceDueDate((ISNULL((a.term_start), GETDATE())), cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days)),
						(a.term_end)))
						ELSE
						DATEADD(dd, 1, ''' + CAST(@as_of_date AS VARCHAR) + ''')
						END AS [invoice_due_date] '

				SET @sql_stmt1='
					FROM index_fees_breakdown_settlement a 
					INNER JOIN #tmp_fees_to_take_in_exposure tfe ON tfe.field_id = a.field_id
					INNER JOIN ' + @deal_header_table + ' h ON a.source_deal_header_id = h.source_deal_header_id 
						AND h.counterparty_id=sc.source_counterparty_id 
						AND leg = 1
					INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = ISNULL(h.deal_status,5604)
					LEFT JOIN source_system_book_map sbm1 ON h.source_system_book_id1 = sbm1.source_system_book_id1 AND 
						h.source_system_book_id2 = sbm1.source_system_book_id2 AND 
						h.source_system_book_id3 = sbm1.source_system_book_id3 AND 
						h.source_system_book_id4 = sbm1.source_system_book_id4
					LEFT JOIN #books book1 ON book1.fas_book_id = sbm1.fas_book_id
					LEFT JOIN fas_subsidiaries fs1 ON book1.fas_subsidiary_id = fs1.fas_subsidiary_id

					OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date 
								FROM stmt_netting_group sng1
								WHERE sng1.counterparty_id = sc.source_counterparty_id
								AND sng1.netting_type IN (109802,109800)
								AND sng1.effective_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''') eff

					OUTER APPLY (SELECT DISTINCT sng.netting_contract_id
							FROM stmt_netting_group sng 
							INNER JOIN stmt_netting_group_detail sngd ON sngd.netting_group_id = sng.netting_group_id
								AND sngd.contract_detail_id = COALESCE(h.contract_id, sngd.contract_detail_id)
							INNER JOIN counterparty_contract_address cca1 ON cca1.counterparty_id = sng.counterparty_id
								AND cca1.contract_id = sng.netting_contract_id
							OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date,
										MAX(sng1.internal_counterparty_id) AS internal_counterparty_id 
										FROM stmt_netting_group sng1
										WHERE sng1.counterparty_id = sng.counterparty_id
										AND ISNULL(sng1.internal_counterparty_id, -1) = ISNULL(sng.internal_counterparty_id, -1)
										AND sng1.netting_type IN (109802,109800)
										AND sng1.effective_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''') eff
							WHERE sng.counterparty_id = sc.source_counterparty_id
							AND COALESCE(sng.internal_counterparty_id, cca1.internal_counterparty_id, -1) = COALESCE(cca1.internal_counterparty_id, sng.internal_counterparty_id, -1)
							AND sng.effective_date = eff.eff_date
							AND ISNULL(sng.internal_counterparty_id, -1) = ISNULL(eff.internal_counterparty_id, -1)
							AND sng.netting_type IN (109802,109800)) sng

				LEFT JOIN counterparty_contract_address cca2 ON cca2.counterparty_id = sc.source_counterparty_id
					AND (cca2.internal_counterparty_id IS NULL OR cca2.internal_counterparty_id=fs1.counterparty_id) 
					AND cca2.contract_id = COALESCE(h.contract_id, cca2.contract_id)

				LEFT JOIN counterparty_contract_address cca1 ON cca1.counterparty_id = sc.source_counterparty_id
					AND (cca1.internal_counterparty_id IS NULL OR cca1.internal_counterparty_id=fs1.counterparty_id) 
					AND cca1.contract_id = CASE WHEN eff.eff_date IS NOT NULL THEN 
											sng.netting_contract_id 
										ELSE COALESCE(h.contract_id, cca1.contract_id) END
				LEFT JOIN contract_group cg ON cg.contract_id = CASE WHEN eff.eff_date IS NOT NULL THEN																				sng.netting_contract_id 
																ELSE h.contract_id END
			OUTER APPLY(SELECT MAX(sdd.source_deal_header_id) source_deal_header_id 
					FROM stmt_checkout sc 
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id= sc.source_deal_detail_id 
					WHERE sdd.source_deal_header_id = a.source_deal_header_id 
					AND sdd.leg = a.leg and sdd.term_start = a.term_start
					AND (sc.accrual_or_final = ''f'' OR ISNULL(sc.is_ignore, 0) = 1)
					AND sc.deal_charge_type_id <> -5500) stc
			WHERE stc.source_deal_header_id IS NULL
			AND ( (set_type = ''f'' AND as_of_date <= CONVERT(DATETIME, ''' + @as_of_date + ''', 102)) OR (set_type = ''s''  AND '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''>=a.term_end))
			GROUP BY h.source_deal_header_id,CONVERT(varchar(7), a.term_start,120),h.counterparty_id,h.contract_id,book1.fas_subsidiary_id,book1.fas_strategy_id,book1.fas_book_id
				) dt
				OUTER APPLY(SELECT ngd.netting_group_id,ngdc.source_contract_id contract_id FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_detail_id WHERE ngd.source_counterparty_id=dt.counterparty_id						
						AND ngdc.source_contract_id=dt.contract_id	 AND CAST(dt.term_start+''-01'' AS DATETIME) BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
					) netting_group			
				outer apply
				(
					select 
					ISNULL(book.fas_subsidiary_id,-1) fas_subsidiary_id,
					ISNULL(book.fas_strategy_id,-1) fas_strategy_id,
					ISNULL(book.fas_book_id,-1) fas_book_id,
					ISNULL(sdh.source_deal_header_id,-1) source_deal_header_id,
					isnull(civv.prod_date,'''+ CONVERT(VARCHAR(7), @as_of_date , 120) +'-01'') as prod_date,
					sdh.physical_financial_flag,
					sdh.source_deal_type_id,
					sdh.deal_sub_type_type_id,
					sc.netting_counterparty_id,
					 '


			SET @sql_stmt2 = 		
					'	SUM(COALESCE(cfv.value,civd.value, 0)) AS value,
						coalesce(netting_group.contract_id,civv.contract_id,sdh.contract_id) contract_id,
						coalesce(sdh.legal_entity, book.legal_entity_id) legal_entity,
						sdh.counterparty_id,
						book.hedge_type_value_id hedge_type_value_id,
						sdh.commodity_id,
						ISNULL(civv.finalized,''n'') finalized,
						COALESCE(icr.settle_status,icr1.settle_status,''o'') settle_status,
						cca.internal_counterparty_id
					from #max_date mdt 
					inner join calc_invoice_volume_variance civv  on mdt.counterparty_id= sc.source_counterparty_id 
						and  civv.counterparty_id=mdt.counterparty_id 
						AND civv.contract_id=mdt.contract_id 
						AND civv.prod_date=mdt.prod_date 
						AND civv.as_of_date=Isnull(mdt.as_of_date_finalised, mdt.as_of_date_initial) 
						and civv.prod_date=dt.term_start+''-01''
						and civv.invoice_type=mdt.invoice_type 
						AND civv.as_of_date = COALESCE(mdt.as_of_date_finalised,mdt.as_of_date_initial,dt.as_of_date)
					INNER JOIN calc_invoice_volume civd ON civd.calc_id = civv.calc_id 	AND ISNULL(civd.manual_input,''n'')=''n'' 
					INNER JOIN calc_formula_value cfv ON cfv.calc_id = civd.calc_id AND civd.invoice_line_item_id = cfv.invoice_line_item_id AND is_final_result = ''y''  AND  COALESCE(cfv.source_deal_header_id,cfv.deal_id) IS NOT NULL
					LEFT JOIN ' + @deal_detail_table + '  sdd ON sdd.source_deal_detail_id=cfv.deal_id 		
					LEFT JOIN ' + @deal_header_table + '  sdh ON sdh.source_deal_header_id = ISNULL(cfv.source_deal_header_id,sdd.source_deal_header_id)
					LEFT JOIN source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
						  sdh.source_system_book_id2 = sbm.source_system_book_id2 AND 
						  sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
						  sdh.source_system_book_id4 = sbm.source_system_book_id4
					LEFT JOIN #books book ON book.fas_book_id = sbm.fas_book_id
					LEFT JOIN fas_subsidiaries fs ON book.fas_subsidiary_id = fs.fas_subsidiary_id
					LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id
						AND fs.counterparty_id = cca.internal_counterparty_id 
						AND cca.contract_id = ISNULL(sdh.contract_id, sdh.contract_id) 
						--AND cca.apply_netting_rule = ''y''	  
					left JOIN invoice_cash_received icr on icr.save_invoice_detail_id=civd.calc_detail_id
					LEFT JOIN contract_group_detail cgd ON cgd.contract_id = ISNULL(netting_group.contract_id,civv.contract_id) AND cgd.invoice_line_item_id = civd.invoice_line_item_id
					CROSS APPLY(
						SELECT 
						MIN(icr.settle_status) [settle_status] FROM contract_group_detail cgd1 
							INNER JOIN calc_invoice_volume cv ON cv.invoice_line_item_id = cgd1.invoice_line_item_id AND cgd1.contract_id = civv.contract_id
							INNER JOIN invoice_cash_received icr ON icr.save_invoice_detail_id = cv.calc_detail_id
						WHERE
							cgd1.contract_id = civv.contract_id
							AND cgd1.alias = cgd.alias
							AND cv.calc_id =  civv.calc_id						
					) icr1
					WHERE COALESCE(cfv.source_deal_header_id,sdd.source_deal_header_id)=dt.source_deal_header_id 
						  AND civv.counterparty_id = dt.counterparty_id
						  AND ((civv.contract_id = dt.contract_id AND civv.netting_group_id IS NULL) OR ( netting_group.netting_group_id = civv.netting_group_id))					  
						  AND ABS(COALESCE(cfv.value,civd.value, 0))<>0 
						  AND cgd.hideInInvoice = ''s''
						  AND ((COALESCE(icr.settle_status,icr1.settle_status,''o'') <> ''s'' 
								AND YEAR(dt.as_of_date) = YEAR(civv.as_of_date) AND MONTH(dt.as_of_date) = MONTH(civv.as_of_date)) OR (COALESCE(icr.settle_status,icr1.settle_status,''o'') = ''s''))
					 GROUP BY book.fas_subsidiary_id,
						book.fas_strategy_id,
						book.fas_book_id,
						sdh.source_deal_header_id,
						civv.prod_date,
						sdh.physical_financial_flag,
						sdh.source_deal_type_id,
						sdh.deal_sub_type_type_id,
						civv.contract_id,
						sdh.counterparty_id,
						sdh.legal_entity, 
						book.legal_entity_id,
						sdh.contract_id,
						book.hedge_type_value_id 
						,sdh.commodity_id,	
						civv.finalized,
						COALESCE(icr.settle_status,icr1.settle_status,''o''), 
						cca.internal_counterparty_id
				) cs
		WHERE COALESCE(cs.value, 0)<>0
				AND ''' + CAST(@as_of_date AS VARCHAR) + ''' < CONVERT(VARCHAR(10), dt.invoice_due_date, 120)
				AND ISNULL(cs.settle_status,''o'') <> ''s''
		GROUP BY COALESCE(cs.source_deal_header_id, dt.source_deal_header_id, -1), 
			COALESCE(dt.term_start+''-01'',cs.prod_date,'''+ CONVERT(varchar(7), @as_of_date , 120) +'-01''),
			cs.finalized,
			sc.netting_counterparty_id
		HAVING ROUND(SUM(COALESCE(cs.value, 0)), 2) <> 0'
		
		--PRINT (@sql_stmt)
		--PRINT(@sql_stmt1)	
		--PRINT(@sql_stmt2)	
		EXEC(@sql_stmt+@sql_stmt1+@sql_stmt2)

		-- Inlcude the manul adjustment and settlement values which has no deal
		SET @sql_stmt='
				INSERT INTO ' + @NettingDealProcessTableName + '(
					fas_subsidiary_id ,
					fas_strategy_id ,
					fas_book_id  ,
					[source_deal_header_id],
					[id_type],
					[term_start],
					[physical_financial_flag],
					[deal_type],
					[deal_sub_type],
					[source_counterparty_id],
					[Final_Und_Pnl],
					[Final_Dis_Pnl],
					[contract_id],
					[legal_entity],	
					[orig_source_counterparty_id],
					[hedge_type_value_id],
					[commodity_id],
					[exp_type_id], 
					[exp_type], 
					[invoice_due_date],
					pnl_as_of_date,
					parent_counterparty_id
				)
				SELECT 						
					-1 fas_subsidiary_id,
					-1 fas_strategy_id,
					-1 fas_book_id,
					-1,
					''d'' id_type,
					civv.prod_date as [Term],
					''f'' physical_financial_flag,
					-1 deal_type,
					-1 deal_sub_type,
					(sc.netting_counterparty_id) as source_counterparty_id,
					SUM(COALESCE(civd.value, 0)) AS [Final_Und_Pnl],
					SUM(COALESCE(civd.value,0)) AS [Final_Dis_Pnl],  
					MAX(civv.contract_id) contract_id,
					-1 legal_entity,
					MAX(sc.source_counterparty_id) as orig_source_counterparty_id,
					-1 hedge_type_value_id,
					-1 commodity_id,
					CASE WHEN SUM(COALESCE(civd.value, 0))>0	 and ISNULL(civd.finalized, ''n'') =''y'' THEN 3
							 WHEN SUM(COALESCE(civd.value, 0))>0 and ISNULL(civd.finalized, ''n'') =''n'' THEN 4
							 WHEN SUM(COALESCE(civd.value, 0))<0 and ISNULL(civd.finalized, ''n'') =''y'' THEN 5
							 WHEN SUM(COALESCE(civd.value, 0))<0 and ISNULL(civd.finalized, ''n'') =''n'' THEN 6
						END AS exp_type_id,
					CASE WHEN SUM(COALESCE(civd.value, 0))>0	 and ISNULL(civd.finalized, ''n'') =''y'' THEN ''A/R Billed''
							 WHEN SUM(COALESCE(civd.value, 0))>0 and ISNULL(civd.finalized, ''n'') =''n'' THEN ''A/R UnBilled''
							 WHEN SUM(COALESCE(civd.value, 0))<0 and ISNULL(civd.finalized, ''n'') =''y'' THEN '' A/P Billed''
							 WHEN SUM(COALESCE(civd.value, 0))<0 and ISNULL(civd.finalized, ''n'') =''n'' THEN '' A/P UnBilled''
						END AS exp_type,
					NULL invoice_due_date ,'''+CAST(@as_of_date AS VARCHAR)+''' pnl_as_of_date,
					max(cca.internal_counterparty_id)
				FROM
					#cpty sc 
					INNER JOIN #max_date mdt ON sc.source_counterparty_id = mdt.counterparty_id
					INNER JOIN calc_invoice_volume_variance civv 
						ON civv.counterparty_id=mdt.counterparty_id 
						AND civv.contract_id=mdt.contract_id 
						AND civv.prod_date=mdt.prod_date 
						and civv.invoice_type=mdt.invoice_type 
						AND civv.as_of_date = COALESCE(mdt.as_of_date_finalised,mdt.as_of_date_initial)
					INNER JOIN calc_invoice_volume civd ON civd.calc_id = civv.calc_id 
					LEFT JOIN calc_formula_value cfv ON cfv.calc_id = civd.calc_id AND civd.invoice_line_item_id = cfv.invoice_line_item_id 
					AND is_final_result = ''y''  AND ISNULL(cfv.deal_id,cfv.source_deal_header_id) IS NOT NULL		
					LEFT JOIN invoice_cash_received icr on icr.save_invoice_detail_id=civd.calc_detail_id
					LEFT JOIN contract_group_detail cgd ON cgd.contract_id = civv.contract_id AND cgd.invoice_line_item_id = civd.invoice_line_item_id
					OUTER APPLY(	
						SELECT DISTINCT cca.internal_counterparty_id 
						FROM #books book
						INNER JOIN fas_subsidiaries fs ON book.fas_subsidiary_id = fs.fas_subsidiary_id
						INNER JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id
						AND fs.counterparty_id = cca.internal_counterparty_id
						AND cca.contract_id = ISNULL(civv.contract_id, cca.contract_id) 
						--AND cca.apply_netting_rule = ''y''
					) cca
					CROSS APPLY(
						SELECT 
						MIN(icr.settle_status) [settle_status] FROM contract_group_detail cgd1 
							INNER JOIN calc_invoice_volume cv ON cv.invoice_line_item_id = cgd1.invoice_line_item_id AND cgd1.contract_id = civv.contract_id
							INNER JOIN invoice_cash_received icr ON icr.save_invoice_detail_id = cv.calc_detail_id
						WHERE
							cgd1.contract_id = civv.contract_id
							AND cgd1.alias = cgd.alias
							AND cv.calc_id =  civv.calc_id						
					) icr1				
					WHERE 1=1 
						AND cfv.calc_id IS NULL
						AND  COALESCE(icr.settle_status,icr1.settle_status,''o'') <> ''s''
					GROUP BY
						civv.prod_date,civv.finalized,sc.netting_counterparty_id,civd.finalized
						HAVING ROUND(SUM(civd.value),2) <> 0'
		--PRINT @sql_stmt				
		EXEC(@sql_stmt)		


		-- Inlcude the Cash received
	
		SET @sql_stmt='
				INSERT INTO ' + @NettingDealProcessTableName + '(
					fas_subsidiary_id ,
					fas_strategy_id ,
					fas_book_id  ,
					[source_deal_header_id],
					[id_type],
					[term_start],
					[physical_financial_flag],
					[deal_type],
					[deal_sub_type],
					[source_counterparty_id],
					[Final_Und_Pnl],
					[Final_Dis_Pnl],
					[contract_id],
					[legal_entity],	
					[orig_source_counterparty_id],
					[hedge_type_value_id],
					[commodity_id],
					[exp_type_id], 
					[exp_type], 
					[invoice_due_date],pnl_as_of_date,
					parent_counterparty_id
				)
				SELECT 						
					-1 fas_subsidiary_id,
					-1 fas_strategy_id,
					-1 fas_book_id,
					-1,
					''d'' id_type,
					civv.prod_date as [Term],
					''f'' physical_financial_flag,
					-1 deal_type,
					-1 deal_sub_type,
					(sc.netting_counterparty_id) as source_counterparty_id,
					(CASE WHEN icr.invoice_type = ''r'' THEN -1 ELSE 1 END)*ABS(SUM(COALESCE(icr.cash_received,0))) AS [Final_Und_Pnl],
					(CASE WHEN icr.invoice_type = ''r'' THEN -1 ELSE 1 END)*ABS(SUM(COALESCE(icr.cash_received,0))) AS [Final_Dis_Pnl],  
					MAX(civv.contract_id) contract_id,
					-1 legal_entity,
					MAX(sc.source_counterparty_id) as orig_source_counterparty_id,
					-1 hedge_type_value_id,
					-1 commodity_id,
						CASE WHEN MAX(icr.invoice_type)=''r'' THEN 7
						 WHEN MAX(icr.invoice_type)=''p'' THEN 8				
					END AS exp_type_id,
					CASE
						 WHEN (icr.invoice_type)=''r'' THEN ''Cash Received''
						 WHEN (icr.invoice_type)=''p'' THEN ''Cash Paid'' 
					END AS exp_type,
					NULL invoice_due_date ,'''+CAST(@as_of_date AS VARCHAR)+''' pnl_as_of_date,
					max(cca.internal_counterparty_id)
				FROM
					#cpty sc 
					INNER JOIN #max_date mdt ON sc.source_counterparty_id = mdt.counterparty_id
					INNER JOIN calc_invoice_volume_variance civv 
						ON civv.counterparty_id=mdt.counterparty_id 
						AND civv.contract_id=mdt.contract_id 
						AND civv.prod_date=mdt.prod_date 
						and civv.invoice_type=mdt.invoice_type 
						AND civv.as_of_date = COALESCE(mdt.as_of_date_finalised,mdt.as_of_date_initial)
					INNER JOIN calc_invoice_volume civd ON civd.calc_id = civv.calc_id
						AND ISNULL(civd.finalized,''n'') = ''y''
					INNER JOIN invoice_cash_received icr on icr.save_invoice_detail_id=civd.calc_detail_id
						AND ISNULL(icr.settle_status,''o'') = ''o''
					OUTER APPLY(	
					SELECT DISTINCT cca.internal_counterparty_id FROM #books book
						INNER JOIN fas_subsidiaries fs ON book.fas_subsidiary_id = fs.fas_subsidiary_id
						INNER JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id
						AND fs.counterparty_id = cca.internal_counterparty_id
						AND cca.contract_id = ISNULL(civv.contract_id, cca.contract_id) 
						--AND cca.apply_netting_rule = ''y''
					) cca	
					WHERE 1=1 
						AND ABS(icr.cash_received)<>0
					GROUP BY
						civv.prod_date,civv.finalized,icr.invoice_type,sc.netting_counterparty_id'
		--PRINT @sql_stmt				
		EXEC(@sql_stmt)
	

	

	--- Include the data from new settlement checkout table
        SET @sql_stmt='
            INSERT INTO ' + @NettingDealProcessTableName + '(
                fas_subsidiary_id ,
                fas_strategy_id ,
                fas_book_id  ,
                [source_deal_header_id],
                [id_type],
                [term_start],
                [physical_financial_flag],
                [deal_type],
                [deal_sub_type],
                [source_counterparty_id],
                [Final_Und_Pnl],
                [Final_Dis_Pnl],
                [contract_id],
                [legal_entity],      
                [orig_source_counterparty_id],
                [hedge_type_value_id],
                [commodity_id],
                [exp_type_id], 
                [exp_type], 
                [invoice_due_date],
                pnl_as_of_date,
                parent_counterparty_id
            )
            SELECT     
                book1.fas_subsidiary_id fas_subsidiary_id,
                book1.fas_strategy_id fas_strategy_id,
                book1.fas_book_id,
                sdh.source_deal_header_id,
                ''d'' id_type,
                stc.term_start  as [Term],
                sdh.physical_financial_flag physical_financial_flag,
                sdh.source_deal_type_id deal_type,
                sdh.deal_sub_type_type_id deal_sub_type,
                sc.netting_counterparty_id as source_counterparty_id,
                SUM(COALESCE(stc.settlement_amount,stc1.settlement_amount,0)) AS [Final_Und_Pnl],
                SUM(COALESCE(stc.settlement_amount,stc1.settlement_amount,0)) AS [Final_Dis_Pnl],  
                sdh.contract_id,
                coalesce(sdh.legal_entity, book1.legal_entity_id) legal_entity,
                sdh.counterparty_id as orig_source_counterparty_id,
                book1.hedge_type_value_id hedge_type_value_id,
                sdh.commodity_id,
                CASE WHEN SUM(COALESCE(stc.settlement_amount,stc1.settlement_amount))>0 and stc.accrual_or_final IS NOT NULL THEN 3
                            WHEN SUM(COALESCE(stc.settlement_amount,stc1.settlement_amount))>0 and stc.accrual_or_final IS NULL THEN 4
                            WHEN SUM(COALESCE(stc.settlement_amount,stc1.settlement_amount))<0 and stc.accrual_or_final IS NOT NULL THEN 5
                            WHEN SUM(COALESCE(stc.settlement_amount,stc1.settlement_amount))<0 and stc.accrual_or_final IS NULL THEN 6
                        END AS exp_type_id,
                case   WHEN SUM(COALESCE(stc.settlement_amount,stc1.settlement_amount))>0 and stc.accrual_or_final IS NOT NULL THEN ''A/R Billed''
                            WHEN SUM(COALESCE(stc.settlement_amount,stc1.settlement_amount))>0 and stc.accrual_or_final IS NULL THEN ''A/R UnBilled''
                            WHEN SUM(COALESCE(stc.settlement_amount,stc1.settlement_amount))<0 and stc.accrual_or_final IS NOT NULL THEN '' A/P Billed''
                            WHEN SUM(COALESCE(stc.settlement_amount,stc1.settlement_amount))<0 and stc.accrual_or_final IS NULL THEN '' A/P UnBilled''
                        END AS exp_type,
                NULL invoice_due_date ,
                '''+CAST(@as_of_date AS VARCHAR)+''' pnl_as_of_date,
                cca1.internal_counterparty_id
            FROM #cpty sc  
            INNER JOIN source_deal_header sdh ON sdh.counterparty_id = sc.source_counterparty_id 
			INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = ISNULL(sdh.deal_status,5604)
            INNER JOIN source_deal_detail  sdd ON sdd.source_deal_header_id=sdh.source_deal_header_id
            INNER JOIN source_system_book_map sbm1 ON sdh.source_system_book_id1 = sbm1.source_system_book_id1 
				AND sdh.source_system_book_id2 = sbm1.source_system_book_id2 
				AND sdh.source_system_book_id3 = sbm1.source_system_book_id3 
				AND sdh.source_system_book_id4 = sbm1.source_system_book_id4
            INNER JOIN #books book1 ON book1.fas_book_id = sbm1.fas_book_id
            INNER JOIN fas_subsidiaries fs1 ON book1.fas_subsidiary_id = fs1.fas_subsidiary_id

            OUTER APPLY(SELECT cca1.internal_counterparty_id,
						si.payment_status,
						CASE WHEN cca1.offset_method = 43501 AND si.payment_status <> ''u'' THEN 
							COALESCE(
								(dbo.FNAInvoiceDueDate((COALESCE(si.pd_from,(stc.term_start), GETDATE())), cca1.invoice_due_date, cca1.holiday_calendar_id, cca1.payment_days)),
								(dbo.FNAInvoiceDueDate((COALESCE(si.pd_from,(stc.term_start), GETDATE())), cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days)),
								--(a.settlement_date),
								ISNULL(si.pd_from,(stc.term_end)))
						ELSE
							DATEADD(dd, 1, ''' + CAST(@as_of_date AS VARCHAR) + ''')
						END AS [invoice_due_date],
						stc.stmt_checkout_id 
					FROM #tmp_fees_to_take_in_exposure tfe 
					INNER JOIN stmt_checkout stc ON tfe.field_id = stc.deal_charge_type_id
					OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date 
						FROM stmt_netting_group sng1
						WHERE sng1.counterparty_id = sc.source_counterparty_id
						AND sng1.netting_type IN (109802,109800)
						AND sng1.effective_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''') eff 
					OUTER APPLY(SELECT ISNULL(si.payment_status, ''i'') payment_status, 
									si.prod_date_from AS pd_from
									FROM stmt_invoice si
								INNER JOIN stmt_invoice_detail side ON side.stmt_invoice_id = si.stmt_invoice_id
								WHERE stc.stmt_invoice_detail_id = side.stmt_invoice_detail_id) si '

		SET @sql_stmt1 = '
					OUTER APPLY (SELECT DISTINCT sng.netting_contract_id
								FROM stmt_netting_group sng 
								INNER JOIN stmt_netting_group_detail sngd ON sngd.netting_group_id = sng.netting_group_id
									AND sngd.contract_detail_id = COALESCE(sdh.contract_id, sngd.contract_detail_id)
								INNER JOIN counterparty_contract_address cca1 ON cca1.counterparty_id = sng.counterparty_id
									AND cca1.contract_id = sng.netting_contract_id
								OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date,
											MAX(sng1.internal_counterparty_id) AS internal_counterparty_id 
											FROM stmt_netting_group sng1
											WHERE sng1.counterparty_id = sng.counterparty_id
											AND ISNULL(sng1.internal_counterparty_id, -1) = ISNULL(sng.internal_counterparty_id, -1)
											AND sng1.netting_type IN (109802,109800)
											AND sng1.effective_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''') eff
								WHERE sng.counterparty_id = sc.source_counterparty_id
								AND COALESCE(sng.internal_counterparty_id, cca1.internal_counterparty_id, -1) = COALESCE(cca1.internal_counterparty_id, sng.internal_counterparty_id, -1)
								AND sng.effective_date = eff.eff_date
								AND ISNULL(sng.internal_counterparty_id, -1) = ISNULL(eff.internal_counterparty_id, -1)
								AND sng.netting_type IN (109802,109800)) sng

					INNER JOIN counterparty_contract_address cca1 ON sc.source_counterparty_id = cca1.counterparty_id
						AND (cca1.internal_counterparty_id IS NULL OR fs1.counterparty_id = cca1.internal_counterparty_id) 
						AND ((cca1.contract_id = sng.netting_contract_id) OR (cca1.contract_id =
												COALESCE(sdh.contract_id, cca1.contract_id)))
					
					LEFT JOIN contract_group cg ON cg.contract_id = CASE WHEN eff.eff_date IS NOT NULL THEN																				sng.netting_contract_id 
																ELSE sdh.contract_id END
					WHERE sdd.source_deal_detail_id = stc.source_deal_detail_id 
					AND stc.term_start <= ''' + CAST(@as_of_date AS VARCHAR) + '''
					AND stc.accrual_or_final = ''f''
					AND ISNULL(stc.is_ignore, 0)=0) dt

			INNER JOIN counterparty_contract_address cca1 ON sc.source_counterparty_id = cca1.counterparty_id
				AND (cca1.internal_counterparty_id IS NULL OR fs1.counterparty_id = cca1.internal_counterparty_id) 
				AND cca1.contract_id = COALESCE(sdh.contract_id, cca1.contract_id)
			INNER JOIN stmt_checkout stc ON stc.stmt_checkout_id = dt.stmt_checkout_id
    --        LEFT JOIN stmt_checkout stc ON sdd.source_deal_detail_id = stc.source_deal_detail_id 
				--AND stc.accrual_or_final = ''f''
				--AND stc.term_start <= ''' + CAST(@as_of_date AS VARCHAR) + '''
            LEFT JOIN stmt_checkout stc1 ON  sdd.source_deal_detail_id = stc1.source_deal_detail_id 
				AND stc1.accrual_or_final = ''a''
                AND stc1.deal_charge_type_id = stc.deal_charge_type_id 
				AND stc1.term_start = stc.term_start
				AND ISNULL(stc1.is_ignore, 0)=0
			OUTER APPLY (SELECT stmt_invoice_detail_id,SUM(cash_received) [cash_received], 
							MIN(settle_status) settle_status,
							SUM(variance_amount) [variance_amount]
						FROM stmt_apply_cash 
						WHERE stmt_invoice_detail_id = ISNULL(stc.stmt_invoice_detail_id,stc1.stmt_invoice_detail_id) 
						GROUP BY stmt_invoice_detail_id) sac

			OUTER APPLY (SELECT 
							SUM(sacd.cash_received) cash_received, 
							SUM(sacd.variance_amount) variance_amount,
							MIN(settle_status) settle_status
						FROM stmt_apply_cash_detail sacd
						WHERE stmt_invoice_detail_id = sac.stmt_invoice_detail_id 
						AND (ISNULL(sac.settle_status,''o'') <> ''s'' OR sac.variance_amount <> 0) 
						AND stmt_checkout_id = ISNULL(stc.stmt_checkout_id, stc1.stmt_checkout_id)) sacd

            WHERE ISNULL(sac.settle_status,''o'') <> ''s''  
			AND ((ISNULL(sacd.settle_status,''o'') <> ''s'' AND sacd.settle_status IS NOT NULL) OR sacd.settle_status IS NULL)
			AND ''' + CAST(@as_of_date AS VARCHAR) + ''' < CONVERT(VARCHAR(10), dt.invoice_due_date, 120)
			AND dt.payment_status <> ''p''

            GROUP BY book1.fas_subsidiary_id,
				book1.fas_strategy_id,
				book1.fas_book_id,
				sdh.source_deal_header_id,
				stc.term_start,
				sdh.physical_financial_flag,
				sdh.source_deal_type_id,
				sdh.deal_sub_type_type_id,
				sc.netting_counterparty_id,
				sdh.contract_id,
				coalesce(sdh.legal_entity,book1.legal_entity_id),
				sdh.counterparty_id,
				book1.hedge_type_value_id,
				sdh.commodity_id,
				cca1.internal_counterparty_id,
				stc.accrual_or_final

            HAVING SUM(COALESCE(stc.settlement_amount, stc1.settlement_amount,0)) <> 0'

		--PRINT (@sql_stmt)
		--PRINT(@sql_stmt1)               
        EXEC(@sql_stmt+@sql_stmt1)


            -- Inlcude the Cash received in settlement checkout
       
            SET @sql_stmt='
                INSERT INTO ' + @NettingDealProcessTableName + '(
                        fas_subsidiary_id ,
                        fas_strategy_id ,
                        fas_book_id  ,
                        [source_deal_header_id],
                        [id_type],
                        [term_start],
                        [physical_financial_flag],
                        [deal_type],
                        [deal_sub_type],
                        [source_counterparty_id],
                        [Final_Und_Pnl],
                        [Final_Dis_Pnl],
                        [contract_id],
                        [legal_entity],      
                        [orig_source_counterparty_id],
                        [hedge_type_value_id],
                        [commodity_id],
                        [exp_type_id], 
                        [exp_type], 
                        [invoice_due_date],pnl_as_of_date,
                        parent_counterparty_id
                )
                SELECT                                          
                        book1.fas_subsidiary_id fas_subsidiary_id,
                        book1.fas_strategy_id fas_strategy_id,
                        book1.fas_book_id,
                        sdh.source_deal_header_id,
                        ''d'' id_type,
                        stc.term_start  as [Term],
                        sdh.physical_financial_flag physical_financial_flag,
                        sdh.source_deal_type_id deal_type,
                        sdh.deal_sub_type_type_id deal_sub_type,
                        sc.netting_counterparty_id as source_counterparty_id,
                        -1*SUM(COALESCE(sacd.cash_received,sac.cash_received,0)) AS [Final_Und_Pnl],
                        -1*SUM(COALESCE(sacd.cash_received,sac.cash_received,0)) AS [Final_Dis_Pnl],  
                        sdh.contract_id,
                        coalesce(sdh.legal_entity, book1.legal_entity_id) legal_entity,
                        sdh.counterparty_id as orig_source_counterparty_id,
                        book1.hedge_type_value_id hedge_type_value_id,
                        sdh.commodity_id,
                        CASE WHEN SUM(COALESCE(sacd.cash_received,sac.cash_received,0))>0 THEN 7
                                WHEN SUM(COALESCE(sacd.cash_received,sac.cash_received,0))<0 THEN 8                           
                        END AS exp_type_id,
                        CASE
                                WHEN SUM(COALESCE(sacd.cash_received,sac.cash_received,0))>0 THEN ''Cash Received''
                                WHEN SUM(COALESCE(sacd.cash_received,sac.cash_received,0))<0 THEN ''Cash Paid'' 
                        END AS exp_type,
                        NULL invoice_due_date ,
                        '''+CAST(@as_of_date AS VARCHAR)+''' pnl_as_of_date,
                        cca1.internal_counterparty_id
                FROM #cpty sc  
                INNER JOIN source_deal_header sdh ON sdh.counterparty_id = sc.source_counterparty_id 
				INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = ISNULL(sdh.deal_status,5604)
                INNER JOIN source_deal_detail  sdd ON sdd.source_deal_header_id=sdh.source_deal_header_id
                INNER JOIN source_system_book_map sbm1 ON sdh.source_system_book_id1 = sbm1.source_system_book_id1 AND 
                            sdh.source_system_book_id2 = sbm1.source_system_book_id2 AND 
                            sdh.source_system_book_id3 = sbm1.source_system_book_id3 AND 
                            sdh.source_system_book_id4 = sbm1.source_system_book_id4
                INNER JOIN #books book1 ON book1.fas_book_id = sbm1.fas_book_id
                INNER JOIN fas_subsidiaries fs1 ON book1.fas_subsidiary_id = fs1.fas_subsidiary_id
                INNER JOIN counterparty_contract_address cca1 ON sc.source_counterparty_id = cca1.counterparty_id
                            AND (cca1.internal_counterparty_id IS NULL OR fs1.counterparty_id = cca1.internal_counterparty_id) 
                            AND cca1.contract_id = ISNULL(sdh.contract_id, cca1.contract_id)
                LEFT JOIN stmt_checkout stc ON sdd.source_deal_detail_id = stc.source_deal_detail_id 
					AND stc.accrual_or_final = ''f''
					AND ISNULL(stc.is_ignore, 0) = 0
                OUTER APPLY (SELECT SUM(sac.cash_received) [cash_received], 
								MIN(sac.settle_status) settle_status,
								SUM(sac.variance_amount) [variance_amount]
							FROM stmt_apply_cash sac
							WHERE stmt_invoice_detail_id = stc.stmt_invoice_detail_id) sac

				OUTER APPLY (SELECT 
								SUM(sacd.cash_received) cash_received, 
								SUM(sacd.variance_amount) variance_amount ,
								MIN(settle_status) settle_status
							FROM stmt_apply_cash_detail sacd
							WHERE stmt_invoice_detail_id =  stc.stmt_invoice_detail_id 
							AND (ISNULL(sac.settle_status,''o'') <> ''s'' OR sac.variance_amount <> 0) 
							AND stmt_checkout_id = stc.stmt_checkout_id) sacd

                WHERE COALESCE(sacd.cash_received,sac.cash_received,0) <> 0 
				AND ISNULL(sac.settle_status,''o'') <> ''s'' 
				AND ((ISNULL(sacd.settle_status,''o'') <> ''s'' AND sacd.settle_status IS NOT NULL) OR sacd.settle_status IS NULL)
				GROUP BY book1.fas_subsidiary_id,
					book1.fas_strategy_id,
					book1.fas_book_id,
					sdh.source_deal_header_id,
					stc.term_start,
					sdh.physical_financial_flag,
					sdh.source_deal_type_id,
					sdh.deal_sub_type_type_id,
					sc.netting_counterparty_id,
					sdh.contract_id,
					coalesce(sdh.legal_entity,book1.legal_entity_id),
					sdh.counterparty_id,
					book1.hedge_type_value_id,
					sdh.commodity_id,
				cca1.internal_counterparty_id'
        --PRINT @sql_stmt                          
        EXEC(@sql_stmt)            
              

	END

---########################### Insert for spot physical deals

	SET @sql_stmt = '	
		insert INTO ' + @NettingDealProcessTableName + 
	'	(		fas_subsidiary_id ,
				fas_strategy_id ,
				fas_book_id  ,
				[source_deal_header_id],
				[id_type],
				[term_start],
				[physical_financial_flag],
				[deal_type],
				[deal_sub_type],
				[source_counterparty_id],
				[Final_Und_Pnl],
				[Final_Dis_Pnl],
				[contract_id],
				[legal_entity],	
				[orig_source_counterparty_id],
				[hedge_type_value_id],
				[commodity_id],
				[exp_type_id], 
				[exp_type], 
				[invoice_due_date],
				[deal_volume],	
				[fixed_price],
				[price_adder],
				[price_multiplier],
				[formula],
				parent_counterparty_id
		)
		SELECT		
				max(book.fas_subsidiary_id) fas_subsidiary_id,
				max(book.fas_strategy_id) fas_strategy_id,
				max(book.fas_book_id) fas_book_id,
				sdh.source_deal_header_id,
				''d'' id_type,
				sdd.term_start,
				max(sdh.physical_financial_flag) physical_financial_flag,
				max(sdh.source_deal_type_id) deal_type,
				max(sdh.deal_sub_type_type_id) deal_sub_type,
				max(sc.netting_counterparty_id) as source_counterparty_id,
				SUM((sdd.fixed_price+sdd.price_adder)*sdd.price_multiplier*sdd.deal_volume) AS [Final_Und_Pnl],
				SUM((sdd.fixed_price+sdd.price_adder)*sdd.price_multiplier*sdd.deal_volume) AS [Final_Dis_Pnl],   --need to mulitply by discount factor later
				max(sdh.contract_id) contract_id,
				max(coalesce(sdh.legal_entity, book.legal_entity_id)) legal_entity,
				max(sdh.counterparty_id) as orig_source_counterparty_id,
				max(book.hedge_type_value_id) hedge_type_value_id,
				max(sdh.commodity_id) commodity_id,
				case when (isnull(SUM((sdd.fixed_price+sdd.price_adder)*sdd.price_multiplier*sdd.deal_volume), 0) > 0) then 1 else 2 end exp_type_id,
				case when (isnull(SUM((sdd.fixed_price+sdd.price_adder)*sdd.price_multiplier*sdd.deal_volume), 0) > 0) then ''MTM+'' else ''MTM-'' end exp_type,
				NULL invoice_due_date,
				MAX(sdd.deal_volume),
				ISNULL(max(sdd.fixed_price),0),
				ISNULL(max(sdd.price_adder),0),
				ISNULL(max(sdd.price_multiplier),1)*case max(sdd.buy_sell_flag) WHEN ''b'' THEN -1 ELSE 1 END,
				max(dbo.FNAFormulaText(sdd.term_start,CASE WHEN sdd.term_start<='''+@as_of_date+''' THEN sdd.term_start else '''+@as_of_date+''' end,0, 0,fe.formula,0,0,0,4500,DEFAULT)), 
				max(cca.internal_counterparty_id)
				
		FROM 		
				#books book INNER JOIN 
				source_system_book_map sbm ON book.fas_book_id = sbm.fas_book_id INNER JOIN
				' + @deal_header_table + ' sdh ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
											  sdh.source_system_book_id2 = sbm.source_system_book_id2 AND 
											  sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
											  sdh.source_system_book_id4 = sbm.source_system_book_id4 INNER JOIN
				#cpty sc ON sc.source_counterparty_id = sdh.counterparty_id 
				INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = ISNULL(sdh.deal_status,5604)
				INNER JOIN ' + @deal_detail_table + ' sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
				LEFT JOIN formula_editor fe on sdd.formula_id=fe.formula_id
				INNER JOIN fas_subsidiaries fs ON book.fas_subsidiary_id = fs.fas_subsidiary_id
				LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id
				AND fs.counterparty_id = cca.internal_counterparty_id 
				AND cca.contract_id = ISNULL(sdh.contract_id, cca.contract_id)

		WHERE	1=1	
				-- AND sdh.deal_date = CONVERT(DATETIME, ''' + @as_of_date + ''', 102) and sdd.leg = 1
				--AND sdd.term_start >= CONVERT(DATETIME, ''' + @as_of_date + ''', 102) 
				AND sdh.physical_financial_flag=''p''
				AND sdh.deal_sub_type_type_id=1
				GROUP BY sdh.source_deal_header_id, sdd.term_start '

		--PRINT @sql_stmt
		EXEC (@sql_stmt)

		SET @sql_stmt = 'DELETE mtm
			FROM ' + @NettingDealProcessTableName + ' mtm
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = mtm.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				AND sdd.term_start = mtm.term_start
			WHERE EXISTS(SELECT 1 
						FROM ' + @NettingDealProcessTableName + ' mtm1 
						WHERE mtm1.source_deal_header_id = mtm.source_deal_header_id
						AND mtm1.term_start = CASE WHEN mtm1.exp_type_id IN (3,5) THEN sdd.delivery_date ELSE mtm.term_start END
						AND mtm1.exp_type_id IN (3,5,4,6)
						)
			AND mtm.exp_type_id IN (1,2)
			AND sdh.is_environmental =''y'''

		EXEC(@sql_stmt)

		EXEC('
			DECLARE @id INT,@formula VARCHAR(5000),@formula_stmt VARCHAR(5000)

			CREATE TABLE #formula_eval([item] VARCHAR(500) COLLATE DATABASE_DEFAULT)
			DECLARE cur1 CURSOR FOR
				SELECT [id],REPLACE(formula,''FNARECCurve'',''FNARDCurve'') FROM '+@NettingDealProcessTableName+' WHERE formula IS NOT NULL
			OPEN cur1
			FETCH NEXT FROM cur1 INTO @id,@formula
			WHILE @@FETCH_STATUS=0
			BEGIN

				DELETE FROM #formula_eval
				SET @formula_stmt = ''UPDATE  '+@NettingDealProcessTableName+' SET Final_Und_Pnl=(fixed_price+price_adder+''+@formula +'')*price_multiplier*deal_volume, 
									 Final_Dis_Pnl=(fixed_price+price_adder+''+@formula +'')*price_multiplier*deal_volume,
									 exp_type_id=CASE WHEN (fixed_price+price_adder+''+@formula +'')*price_multiplier*deal_volume>0 THEN  1 else 2 end ,
									 exp_type=CASE WHEN (fixed_price+price_adder+''+@formula +'')*price_multiplier*deal_volume>0 THEN  ''''MTM+'''' else ''''MTM-'''' end
						 WHERE [id]=''+CAST(@id AS VARCHAR)
				--print @formula_stmt
				EXEC(@formula_stmt)

				FETCH NEXT FROM cur1 INTO @id,@formula
			END
			CLOSE cur1
			DEALLOCATE cur1
		')



	-----------------------END OF RETRIEVE ALL PARTICIPATING DEALS FIRST--------------------------------------------
	----------------------------------------------------------------------------------------------------------------

	DECLARE @netting_parent_group_id VARCHAR(10),
		@netting_parent_group_name VARCHAR(100),
		@netting_group_id VARCHAR(10),
		@netting_group_name VARCHAR(100),
		@netting_group_detail_id VARCHAR(10),
		@source_commodity_id VARCHAR(10),
		@physical_financial_flag CHAR(1),
		@source_deal_type_id VARCHAR(10),
		@source_deal_sub_type_id VARCHAR(10),
		@hedge_type_value_id VARCHAR(10),
		@source_counterparty_id VARCHAR(10),
		@gl_number_id_st_asset VARCHAR(10),
		@gl_number_id_st_liab VARCHAR(10),
		@gl_number_id_lt_asset VARCHAR(10),
		@gl_number_id_lt_liab VARCHAR(10),
		@source_contract VARCHAR(500),
		@source_contract_id INT,
		@legal_entity VARCHAR(10),
		@contract_id INT,
		@internal_counterparty_id INT


	DECLARE @sqlSelect VARCHAR(8000)
	DECLARE @sqlSelect1 VARCHAR(8000)
	DECLARE @sqlSelect2 VARCHAR(8000)
	

	EXEC('CREATE TABLE ' + @NettingProcessTableOneName + '
		(
			[Netting_Parent_Group_ID] [int] NOT NULL ,
			[Netting_Parent_Group_Name] [VARCHAR] (100) NOT NULL ,
			[Netting_Group_ID] [int] NOT NULL ,
			[Netting_Group_Name] [VARCHAR] (100) NOT NULL ,
			[Netting_Group_Detail_ID] [int] NOT NULL ,
			[fas_subsidiary_id] int NOT NULL,
			[fas_strategy_id] int NOT NULL,	
			[fas_book_id] int NOT NULL,
			[Source_Deal_Header_ID] [int] NULL,
			[Source_Counterparty_ID] [int] NULL,
			[term_start] [DATETIME] NULL ,
			[Final_Und_Pnl] [float] NULL ,
			[Final_Dis_Pnl] [float] NULL ,
			[legal_entity] [int] NULL,
			[exp_type_id] VARCHAR(10), 
			[exp_type] VARCHAR(20),
			invoice_due_date DATETIME,
			exposure_to_us INT,
			pnl_as_of_date datetime,
			contract_id INT,
			internal_counterparty_id INT,
			netting_ic_id INT,
			netting_contract_id INT
	) ON [PRIMARY] ')


	CREATE TABLE #tmp_cpd 
	(
		fas_subsidiary_id INT,
		fas_strategy_id INT,	
		fas_book_id INT,
		source_deal_header_id INT,
		term_start DATETIME,
		source_counterparty_id INT,
		final_und_pnl FLOAT,
		final_dis_pnl FLOAT,
		legal_entity [INT],
		[exp_type_id] VARCHAR(10) COLLATE DATABASE_DEFAULT, 
		[exp_type] VARCHAR(20) COLLATE DATABASE_DEFAULT,
		invoice_due_date DATETIME,
		pnl_as_of_date DATETIME,
		contract_id INT,
		internal_counterparty_id INT
	)

	IF OBJECT_ID('tempdb..#tmp_netting_detail') IS not NULL
		DROP TABLE #tmp_netting_detail
	
	SELECT  ngp.netting_parent_group_id, 
		ngp.netting_parent_group_name, 
		ng.netting_group_id, 
		ng.netting_group_name, 
		ngd.netting_group_detail_id, 
		ng.source_commodity_id, 
		ng.physical_financial_flag, 
		ng.source_deal_type_id, 
		ng.source_deal_sub_type_id, 
		ng.hedge_type_value_id, 
		ngp.legal_entity,
		COALESCE(sc.netting_parent_counterparty_id, ngd.source_counterparty_id, NULL) AS source_counterparty_id,
		ngdc.source_contract_id,
		NULL internal_counterparty_id
	INTO #tmp_netting_detail
	FROM netting_group_detail ngd 
	INNER JOIN netting_group ng ON ngd.netting_group_id = ng.netting_group_id 
	INNER JOIN netting_group_parent ngp ON ng.netting_parent_group_id = ngp.netting_parent_group_id
	LEFT OUTER JOIN source_counterparty sc ON sc.source_counterparty_id = ngd.source_counterparty_id 
	LEFT JOIN  netting_group_detail_contract ngdc ON  ngdc.netting_group_detail_id=ngd.netting_group_detail_id	
	WHERE ngp.active = 'y' 
		AND (ng.gain_loss_flag = 'n' OR ng.gain_loss_flag IS NULL)
		AND (@counterparty_id IS NULL OR ngd.source_counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@counterparty_id))) 
		AND CONVERT(DATETIME, @as_of_date, 102) BETWEEN ng.effective_date AND ISNULL(ng.end_date, CONVERT(DATETIME, @as_of_date, 102))

	INSERT INTO #tmp_netting_detail
	SELECT  -10*cca.counterparty_contract_address_id, 
		'Unselected', 
		cca.contract_id, 
		'Unselected', 
		-10*cca.counterparty_contract_address_id, 
		null, 
		null, 
		null, 
		null, 
		null, 
		null,
		counterparty_id ,
		cca.contract_id,
		cca.internal_counterparty_id
	FROM counterparty_contract_address cca 
	WHERE NOT EXISTS(SELECT 1 
					FROM #tmp_netting_detail tnd 
					WHERE cca.counterparty_id = tnd.source_counterparty_id 
					AND ISNULL(cca.contract_id, 0) = ISNULL(tnd.source_contract_id, 0)
					AND ISNULL(cca.internal_counterparty_id, 0) = ISNULL(tnd.internal_counterparty_id, 0))
	AND ISNULL(cca.apply_netting_rule,'n')='y'
	AND (@counterparty_id IS NULL OR cca.counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@counterparty_id)))


	DECLARE netting_group CURSOR FOR 
	SELECT * FROM #tmp_netting_detail
	ORDER BY netting_parent_group_id, source_counterparty_id DESC,netting_group_id,netting_group_detail_id,source_commodity_id DESC, 
	physical_financial_flag DESC,source_deal_type_id DESC,source_deal_sub_type_id DESC, hedge_type_value_id DESC 

	DECLARE @next_id INT
	SET @next_id = 0

	OPEN netting_group

	FETCH NEXT FROM netting_group 
	INTO 	@netting_parent_group_id ,
			@netting_parent_group_name ,
			@netting_group_id ,
			@netting_group_name ,
			@netting_group_detail_id ,
			@source_commodity_id ,
			@physical_financial_flag ,
			@source_deal_type_id ,
			@source_deal_sub_type_id ,
			@hedge_type_value_id ,
			@legal_entity,
			@source_counterparty_id, 
			@contract_id,
			@internal_counterparty_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- delete from temporary table and if index exist drop it
		DELETE #tmp_cpd
	--	if exists(SELECT * FROM sysindexes where [name]='ix_tmp_cpd')
	--		drop index ix_tmp_cpd on #tmp_cpd

		SET @next_id = @next_id + 1

		IF @print_diagnostic = 1
		BEGIN
			SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
			SET @log_increment = @log_increment + 1
			SET @log_time=GETDATE()
			PRINT @pr_name+' Running..............'
		END

	----Find contracts concanted by , for a given netting group detail
		
	-- End of finding contracts for a given netting group detail

		SET @sqlSelect = ' INSERT INTO #tmp_cpd
			SELECT max(fas_subsidiary_id) fas_subsidiary_id, max(fas_strategy_id) fas_strategy_id,	max(fas_book_id) fas_book_id, 
				source_deal_header_id,
				term_start,
				source_counterparty_id,
				SUM(Final_Und_Pnl) AS final_und_pnl,
				SUM(Final_Dis_Pnl) AS final_dis_pnl,
				max(legal_entity) legal_entity,
				(exp_type_id) exp_type_id, 
				(exp_type ) exp_type,
				MAX(invoice_due_date) invoice_due_date,
				pnl_as_of_date,
				max(contract_id) contract_id,
				parent_counterparty_id
			FROM ' + @NettingDealProcessTableName +  
			
			--CASE WHEN ((SELECT COUNT(*) FROM netting_group_detail_contract WHERE netting_group_detail_id = @netting_group_id) > 0) THEN
			--' INNER JOIN 
			--	(select netting_group_detail_id, source_contract_id 
			--	from netting_group_detail_contract where netting_group_detail_id = ' + CAST(@netting_group_id AS VARCHAR) + ') con ON
			--	contract_id = con.source_contract_id 
			--'
			--ELSE '' END +
			'	
			WHERE 1 = 1 ' + 
				(CASE WHEN (@source_commodity_id IS NOT NULL) THEN ' AND (commodity_id = ' + @source_commodity_id + ')' ELSE '' END) +
				(CASE WHEN (@physical_financial_flag IS NOT NULL AND @physical_financial_flag <> 'a') THEN ' AND (physical_financial_flag = ''' + @physical_financial_flag + ''')' ELSE '' END) +
				(CASE WHEN (@source_deal_type_id IS NOT NULL) THEN ' AND (deal_type = ' + @source_deal_type_id + ')' ELSE '' END) + 
				(CASE WHEN (@source_deal_sub_type_id IS NOT NULL) THEN ' AND (deal_sub_type = ' + @source_deal_sub_type_id + ')' ELSE '' END) + 
				(CASE WHEN (@hedge_type_value_id IS NOT NULL) THEN ' AND (hedge_type_value_id = ' + @hedge_type_value_id + ')' ELSE '' END) + 
				(CASE WHEN (@source_counterparty_id IS NOT NULL) THEN ' AND (source_counterparty_id = ' + @source_counterparty_id + ')' ELSE '' END) +
				(CASE WHEN (@legal_entity IS NOT NULL) THEN ' AND (legal_entity = ' + @legal_entity + ')' ELSE '' END) +
				(CASE WHEN (@contract_id IS NOT NULL) THEN ' AND (contract_id = ' + cast(@contract_id AS VARCHAR )+ ')' ELSE '' END) + 
				(CASE WHEN (@internal_counterparty_id IS NOT NULL) THEN ' AND (parent_counterparty_id = ' + cast(@internal_counterparty_id AS VARCHAR )+ ')' ELSE '' END)
				
				
			+
			' GROUP BY source_deal_header_id,	term_start,	source_counterparty_id,exp_type_id,exp_type, pnl_as_of_date, parent_counterparty_id
			' 
		--print (@sqlSelect)
		EXEC (@sqlSelect)

		
	--	create index ix_tmp_cpd on #tmp_cpd (source_deal_header_id)

   		SET @sqlSelect = '
		INSERT INTO ' + @NettingProcessTableOneName + '
		SELECT  DISTINCT ' + @netting_parent_group_id + ' AS [Netting_Parent_Group_ID] ,'''
			+ @netting_parent_group_name + ''' AS [Netting_Parent_Group_Name] ,'
			+ @netting_group_id + ' AS [Netting_Group_ID],'''
			+ @netting_group_name + ''' AS [Netting_Group_Name],'
			+ @netting_group_detail_id + ' AS [Netting_Group_Detail_ID],
			cpd.fas_subsidiary_id,
			cpd.fas_strategy_id,
			cpd.fas_book_id,
			cpd.source_deal_header_id,
			cpd.source_counterparty_id,
			cpd.term_start,
			cpd.final_und_pnl,
			cpd.final_dis_pnl,
			legal_entity,
			cpd.exp_type_id, 
			cpd.exp_type,
			cpd.invoice_due_date,
			NULL,
			cpd.pnl_as_of_date,
			cpd.contract_id,
			cpd.internal_counterparty_id,
			NULL,
			NULL
		FROM #tmp_cpd cpd ' +
		' LEFT OUTER JOIN (SELECT DISTINCT source_deal_header_id, Source_Counterparty_ID FROM  ' + 
				@NettingProcessTableOneName + ' WHERE Netting_Parent_Group_ID = ' + @netting_parent_group_id + ') ex ON
			cpd.source_deal_header_id = ex.source_deal_header_id
			AND cpd.Source_Counterparty_ID = ex.Source_Counterparty_ID
			WHERE ex.source_deal_header_id IS NULL '

	--	return
		--PRINT @sqlSelect
		EXEC (@sqlSelect)



		IF @print_diagnostic = 1
		BEGIN
			PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
			PRINT '****************Process next netting filter *****************************'	
		END

	   -- Get the next group.
	   FETCH NEXT FROM netting_group 
	   INTO @netting_parent_group_id ,
		@netting_parent_group_name ,
		@netting_group_id ,
		@netting_group_name ,
		@netting_group_detail_id ,
		@source_commodity_id ,
		@physical_financial_flag ,
		@source_deal_type_id ,
		@source_deal_sub_type_id ,
		@hedge_type_value_id ,
		@legal_entity,
		@source_counterparty_id,
		@contract_id,
		@internal_counterparty_id
	END

	CLOSE netting_group
	DEALLOCATE netting_group
	
	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
	END


	-------------THE FOLLOWING IS FOR GROSS ENTRIES -----------------------

	SET @sqlSelect = 
	  ' INSERT INTO ' + @NettingProcessTableOneName + 
	  ' SELECT  
	   --cpd.netting_parent_group_id  AS [Netting_Parent_Group_ID] ,
	   --cpd.netting_parent_group_name  AS [Netting_Parent_Group_Name] ,
	   -1  AS [Netting_Parent_Group_ID],
	   ''Unselected''  AS [Netting_Parent_Group_Name],
	   -1  AS [Netting_Group_ID],
	   ''Unselected''  AS [Netting_Group_Name],
	   -1 AS [Netting_Group_Detail_ID],
	   cpd.fas_subsidiary_id,
	   cpd.fas_strategy_id,
	   cpd.fas_book_id,
	   cpd.source_deal_header_id,
	   cpd.source_counterparty_id,
	   cpd.term_start,
	   (cpd.final_und_pnl) AS [Final_Und_Pnl],
	   (cpd.final_dis_pnl) AS [Final_Dis_Pnl],
	   -1,
	   cpd.exp_type_id, 
	   cpd.exp_type,
	   cpd.invoice_due_date,
	   NULL,
	   pnl_as_of_date,
	   contract_id,
	   internal_counterparty_id,
	   NULL,
	   NULL
	  FROM
	  (
	  SELECT  max(fas_subsidiary_id) fas_subsidiary_id, max(fas_strategy_id) fas_strategy_id, max(fas_book_id) fas_book_id,
		source_deal_header_id,
		term_start,
		source_counterparty_id,
		SUM(Final_Und_Pnl) AS final_und_pnl,
		SUM(Final_Dis_Pnl) AS final_dis_pnl,
		--npg.netting_parent_group_id,
		--npg.netting_parent_group_name,
		--max(npg.legal_entity) legal_entity,
		max(exp_type_id) exp_type_id, 
		max(exp_type ) exp_type,
		max(invoice_due_date) invoice_due_date,
		ndp.pnl_as_of_date,
		max(ndp.contract_id) contract_id,
		max(ndp.parent_counterparty_id) internal_counterparty_id
	   FROM ' + @NettingDealProcessTableName + ' ndp (NOLOCK)
	   --CROSS JOIN (SELECT DISTINCT netting_parent_group_id, netting_parent_group_name, legal_entity 
	   --  from netting_group_parent where active = ''y''
	   --) npg 
	   --WHERE (npg.legal_entity IS NULL OR npg.legal_entity = ndp.legal_entity)
	   GROUP BY source_deal_header_id,
		term_start,
		source_counterparty_id,
		--npg.netting_parent_group_id,
		--npg.netting_parent_group_name,
		ndp.pnl_as_of_date,exp_type
		)cpd ' +
		' LEFT OUTER JOIN (select distinct source_deal_header_id, source_counterparty_id from  ' + @NettingProcessTableOneName + ') ex ON
		  cpd.source_deal_header_id = ex.source_deal_header_id  
		  --AND cpd.netting_parent_group_id = ex.netting_parent_group_id
		  AND cpd.source_counterparty_id = ex.source_counterparty_id
		 WHERE ex.source_deal_header_id IS NULL
		 ORDER BY cpd.pnl_as_of_date 
		' 

	 --PRINT (@sqlSelect)
	 EXEC(@sqlSelect)

--select @NettingDealProcessTableName, @NettingProcessTableOneName RETURN
--select * from adiha_process.dbo.calcprocess_credit_netting_deals_sbohara_D23DB7CC_C03A_400B_8E2F_ACE7F6AEB269
--where source_deal_header_id = 6388

--select * from adiha_process.dbo.calcprocess_credit_netting_one_sbohara_D23DB7CC_C03A_400B_8E2F_ACE7F6AEB269
--where source_deal_header_id = 6388

	EXEC('create index indx_NettingProcessTableOneName_11 on '+@NettingProcessTableOneName+' (netting_group_id,[Netting_Group_Detail_ID], source_counterparty_id,[fas_book_id],[legal_entity])')


	EXEC('create index indx_NettingProcessTableOneName_22 on '+@NettingProcessTableOneName+' (source_deal_header_id,term_start)')

	CREATE TABLE #exp_test (as_of_date datetime,
		netting_parent_group_id INT, netting_group_id INT, source_counterparty_id INT,
		total_und_exposure FLOAT, total_dis_exposure FLOAT, exposure_to_us INT,internal_counterparty_id INT,contract_id int
	) 

	CREATE TABLE #count_counterparty(count_cpt INT)
	
IF isnull(@simulation,'n') ='n'  --If not from PFE
BEGIN
	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
	END

	--For Cross Netting
	SET @sqlSelect = '
	UPDATE cd SET netting_ic_id = netting.internal_counterparty_id, 
		netting_contract_id = netting.netting_contract_id
	FROM ' + @NettingProcessTableOneName + ' cd
	OUTER APPLY(
				SELECT 
					ISNULL(sng.internal_counterparty_id, ' + CAST(@master_counterparty_id AS VARCHAR) + ') AS internal_counterparty_id,
					sng.netting_contract_id
				FROM stmt_netting_group sng
				INNER JOIN stmt_netting_group_detail sngd ON sngd.netting_group_id = sng.netting_group_id
					AND sngd.contract_detail_id = cd.contract_id
					AND sng.netting_type IN (109802,109800)
				OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date,
								MAX(sng1.internal_counterparty_id) AS internal_counterparty_id 
							FROM stmt_netting_group sng1
							WHERE sng1.counterparty_id = sng.counterparty_id
							AND ISNULL(sng1.internal_counterparty_id, -1) = ISNULL(sng.internal_counterparty_id, -1)
							AND sng1.netting_type IN (109802,109800)
							AND sng1.effective_date <= ''' + @as_of_date + ''') eff
				WHERE sng.counterparty_id = cd.source_counterparty_id
				AND sng.effective_date = eff.eff_date
				AND ISNULL(sng.internal_counterparty_id, -1) = ISNULL(eff.internal_counterparty_id, -1)
				AND COALESCE(sng.internal_counterparty_id, cd.internal_counterparty_id, -1) = COALESCE(cd.internal_counterparty_id, sng.internal_counterparty_id, -1)) netting'
		
	--print (@sqlSelect)
	EXEC (@sqlSelect)

	SET @sqlSelect = '
		insert into #exp_test
		select	ISNULL(pnl_as_of_date, ''' + @as_of_date + '''),netting_parent_group_id, netting_group_id, source_counterparty_id, 
				sum(Final_Und_Pnl) total_und_exposure, sum(Final_Dis_Pnl) total_dis_exposure,
				case when(sum(Final_Und_Pnl) > 0) then 1 else 0 end exposure_to_us, 
				ISNULL(netting_ic_id, internal_counterparty_id),
				ISNULL(netting_contract_id, d.contract_id)
		from ' + @NettingProcessTableOneName + ' d
		--left join fas_subsidiaries fs on fs.fas_subsidiary_id=d.fas_subsidiary_id
		where netting_group_id <> -1 
		group by pnl_as_of_date, 
			netting_parent_group_id, 
			netting_group_id, 
			source_counterparty_id, 
			ISNULL(netting_ic_id, internal_counterparty_id), 
			ISNULL(netting_contract_id, d.contract_id) '

	--print (@sqlSelect)
	EXEC (@sqlSelect)

	--For Cross Netting
	SET @sqlSelect = '
	UPDATE et SET exposure_to_us = CASE WHEN final_pnl > 0 THEN 1
									ELSE 0 END
	FROM #exp_test et
	OUTER APPLY (SELECT sum(final_und_pnl) final_pnl
				FROM ' + @NettingProcessTableOneName + ' cd
				WHERE cd.source_counterparty_id = et.source_counterparty_id
				AND ISNULL(cd.netting_ic_id, -1) = ISNULL(et.internal_counterparty_id, -1)
				AND cd.netting_contract_id = et.contract_id) cd
	WHERE cd.final_pnl IS NOT NULL '

	--print (@sqlSelect)
	EXEC (@sqlSelect)

	SET @pr_name= 'exp_test populated'
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
	PRINT GETDATE()

	SET @sqlSelect = '
		UPDATE a 
		SET a.exposure_to_us = et.exposure_to_us
		FROM ' + @NettingProcessTableOneName + ' a
		INNER JOIN #exp_test et ON a.netting_parent_group_id = et.netting_parent_group_id
			AND a.netting_group_id = et.netting_group_id
			AND a.source_counterparty_id = et.source_counterparty_id 
			and et.as_of_date = a.pnl_as_of_date
			and (a.internal_counterparty_id IS NULL OR et.internal_counterparty_id = ISNULL(a.netting_ic_id, a.internal_counterparty_id))
			and  et.contract_id = ISNULL(a.netting_contract_id, a.contract_id)
		INNER JOIN fas_subsidiaries fs on fs.fas_subsidiary_id = a.fas_subsidiary_id
			AND CASE WHEN a.fas_subsidiary_id = -1 THEN 
					ISNULL(a.internal_counterparty_id, 1)
				ELSE 
					ISNULL(fs.counterparty_id, 1) 
				END =	CASE WHEN a.fas_subsidiary_id = -1 THEN 
							COALESCE(a.internal_counterparty_id, 1) 
						ELSE 
							COALESCE(a.internal_counterparty_id, fs.counterparty_id, 1) 
						END'
	--print(@sqlSelect)
	EXEC(@sqlSelect)


	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************End of collecting in #exp_test1 for netting *****************************'	
	END

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
		PRINT GETDATE()
	END

	SET @sqlSelect = '
		insert into #exp_test
		select	ISNULL(pnl_as_of_date, ''' + @as_of_date + '''),netting_parent_group_id, netting_group_id, source_counterparty_id, 
			sum(Final_Und_Pnl) total_und_exposure,
			sum(Final_Dis_Pnl) total_dis_exposure,
			sum(exposure_to_us) exposure_to_us,
			s.counterparty_id,
			s.contract_id
		from (
		select	netting_parent_group_id, netting_group_id, source_counterparty_id, 
				cd.Final_Und_Pnl,  cd.Final_Dis_Pnl,
				CASE WHEN ((cd.Final_Und_Pnl > 0 AND cd.exp_type_id NOT IN (7, 8)) OR (cd.exp_type_id = 7)) THEN  1 ELSE 0 END exposure_to_us
				,cd.pnl_as_of_date,
				fs.counterparty_id,
				cd.contract_id
		from ' + @NettingProcessTableOneName + ' cd
		inner join fas_subsidiaries fs on fs.fas_subsidiary_id=cd.fas_subsidiary_id
		where netting_group_id = -1) s 
		group by 
			netting_parent_group_id, 
			netting_group_id, 
			source_counterparty_id, 
			pnl_as_of_date,
			s.counterparty_id,
			s.contract_id'

	EXEC (@sqlSelect)

	--For Cross Netting
	SET @sqlSelect = '
		UPDATE et SET exposure_to_us = CASE WHEN final_pnl > 0 THEN 1
										ELSE 0 END
		FROM #exp_test et
		OUTER APPLY (SELECT sum(final_und_pnl) final_pnl
					FROM ' + @NettingProcessTableOneName + ' cd
					WHERE cd.source_counterparty_id = et.source_counterparty_id
					AND ISNULL(cd.netting_ic_id, -1) = ISNULL(et.internal_counterparty_id, -1)
					AND cd.netting_contract_id = et.contract_id) cd
		WHERE cd.final_pnl IS NOT NULL 
		AND et.netting_group_id = -1'

	--print (@sqlSelect)
	EXEC (@sqlSelect)

	SET @pr_name= 'exp_test 2 populated'
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
	PRINT GETDATE()

	SET @sqlSelect = '
		UPDATE a 
		SET a.exposure_to_us = CASE WHEN ((Final_Und_Pnl > 0 AND exp_type_id NOT IN (7, 8)) OR (exp_type_id = 7)) THEN  1 ELSE 0 END
		FROM ' + @NettingProcessTableOneName + ' a where netting_group_id = -1 '

	EXEC(@sqlSelect)

	--For Cross Netting
	SET @sqlSelect = '
		UPDATE a 
			SET a.exposure_to_us = CASE WHEN ((final_pnl > 0 AND exp_type_id NOT IN (7, 8)) OR (exp_type_id = 7)) THEN  1 ELSE 0 END
		FROM ' + @NettingProcessTableOneName + ' a 
		OUTER APPLY (SELECT sum(final_und_pnl) final_pnl
				FROM ' + @NettingProcessTableOneName + ' cd
				WHERE cd.source_counterparty_id = a.source_counterparty_id
				AND ISNULL(cd.netting_ic_id, -1) = ISNULL(a.netting_ic_id, -1)
				AND cd.netting_contract_id = a.netting_contract_id) cd
		WHERE netting_group_id = -1 
		AND cd.final_pnl IS NOT NULL'

	EXEC(@sqlSelect)

	SET @pr_name= 'exp_test 2 updated'
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
	PRINT GETDATE()

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************End of collecting in #exp_test2 for gross *****************************'	
	END


	--select * from adiha_process.dbo.calcprocess_credit_netting_one_urbaral_123
	--select * from #exp_test

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
	END

	CREATE TABLE #climits (
		source_counterparty_id INT,
		days INT,
		tenor_limit INT,
		total_limit_provided FLOAT, -- this is limit to them
		total_limit_received FLOAT -- this is limit to us
		,as_of_date datetime,
		internal_counterparty_id INT ,
		contract_id INT,
		currency_id INT,
		prepay_provided FLOAT,
		prepay_received FLOAT 
	)
	

	SELECT @sqlSelect = '
		SELECT a.source_counterparty_id
			,ISNULL(a.netting_contract_id, a.contract_id) contract_id
			,ISNULL(a.netting_ic_id, a.internal_counterparty_id) internal_counterparty_id
			,i.counterparty_credit_info_id 
			,max(a.term_start) term_start  
		INTO #temp_cpty_cont 
		FROM '+@NettingProcessTableOneName+' a
		INNER JOIN counterparty_credit_info i ON i.Counterparty_id=a.source_counterparty_id
		GROUP BY a.source_counterparty_id
			,ISNULL(a.netting_contract_id, a.contract_id)
			,ISNULL(a.netting_ic_id, a.internal_counterparty_id)
			,i.counterparty_credit_info_id '
	
	SET @sqlSelect = @sqlSelect +'
		insert into #climits
		select	a.source_counterparty_id, max(datediff(dd, a.as_of_date, a.term_start)) days,
				max(isnull(a.tenor_limit, 0)) tenor_limit,
				max(isnull(a.credit_limit_provided, 0)) + max(isnull(a.enh_received, 0)) total_limit_provided,
				max(isnull(a.credit_limit_received, 0)) + max(isnull(a.enh_provided, 0)) total_limit_received
				,ISNULL(a.as_of_date, ''' + @as_of_date + ''')
				,a.internal_counterparty_id,
				a.contract_id,
				max(a.currency_id),
				max(a.prepay_provided) prepay_provided,
				max(a.prepay_received) prepay_received
		from
		 (
			select	cd.source_counterparty_id,  
				dt.as_of_date,
				max(cd.term_start) term_start,
				max(isnull(cci.tenor_limit, cci2.tenor_limit)) tenor_limit,
				max(isnull(cci.credit_limit_to_us, cci2.credit_limit_to_us)) credit_limit_received, 
				max(isnull(cci.credit_limit, cci2.credit_limit)) credit_limit_provided,
				sum(CASE WHEN isnull(cce.margin, cce2.margin) = ''y'' THEN ISNULL(cce.amount, cce2.amount) ELSE 0 END)	enh_received,
				sum(CASE WHEN isnull(cce.margin, cce2.margin) = ''n'' THEN ISNULL(cce.amount, cce2.amount) ELSE 0 END)	enh_provided,
				max(isnull(cce.currency_code, cce2.currency_code)) currency_code,
				cd.internal_counterparty_id,
				cd.contract_id,
				max(COALESCE(cci.currency_id, cci2.currency_id, cce.currency_code, cce2.currency_code)) currency_id,
				NULL prepay_provided,
				NULL prepay_received
			from #temp_cpty_cont cd 
			cross join #as_of_dates dt 
			left join #tmp_counterparty_credit_limits cci  on cci.counterparty_id = cd.source_counterparty_id
				AND cci.contract_id= isnull(cd.contract_id, cci.contract_id)
				and cci.internal_counterparty_id =isnull(cd.internal_counterparty_id, cd.internal_counterparty_id)
				and cci.effective_date <= ''' + @as_of_date + '''
			left join #tmp_counterparty_credit_limits cci2  on cci2.counterparty_id = cd.source_counterparty_id
				AND (cci2.internal_counterparty_id IS NULL OR cci2.contract_id IS NULL)
				and cci2.effective_date <= ''' + @as_of_date + '''
			LEFT JOIN #counterparty_credit_enhancements cce ON cce.counterparty_credit_info_id = cd.counterparty_credit_info_id 
				AND cce.contract_id = isnull(cd.contract_id, cce.contract_id) 
				and cce.internal_counterparty = isnull(cd.internal_counterparty_id, cce.internal_counterparty) 
				and cce.exclude_collateral = ''n''
				and ((dt.as_of_date between ISNULL(cce.eff_date, dt.as_of_date) and isnull(expiration_date, dt.as_of_date)) OR cce.auto_renewal = ''y'')
				and cce.eff_date <= ''' + @as_of_date + '''
			LEFT JOIN #counterparty_credit_enhancements cce2 ON	cce2.counterparty_credit_info_id = cd.counterparty_credit_info_id
			AND (cce2.internal_counterparty IS NULL OR cce2.contract_id IS NULL)		
			AND cce2.exclude_collateral = ''n''
			AND cce2.eff_date <= ''' + @as_of_date + '''
			AND ((dt.as_of_date between ISNULL(cce2.eff_date, dt.as_of_date) and isnull(cce2.expiration_date, dt.as_of_date)) OR cce2.auto_renewal = ''y'')
			GROUP BY cd.source_counterparty_id,cd.contract_id, dt.as_of_date,cd.internal_counterparty_id 
			union all
			select max(cci.counterparty_id) counterparty_id,  
				dt.as_of_date,
				null term_start,
				null tenor_limit,		
				abs(sum(case when ifb.value<0 then value else 0 end)) prepay_provided,
				abs(sum(case when ifb.value>0 then value else 0 end)) prepay_received,		
				null enh_received, 
				null enh_provided, 
				max(ifb.fee_currency_id) currency_code,
				cci.internal_counterparty_id,
				cci.contract_id,
				max(ISNULL(cci.currency_id, ifb.fee_currency_id)) currency_id,
				abs(sum(case when ifb.value<0 then value else 0 end)) prepay_provided,
				abs(sum(case when ifb.value>0 then value else 0 end)) prepay_received
			from index_fees_breakdown ifb 
			INNER JOIN #tmp_fees_to_take_in_exposure tfe ON tfe.field_id = ifb.field_id
			inner join source_deal_header sdh on sdh.source_deal_header_id=ifb.source_deal_header_id 
				and ifb.internal_type=18724
			inner join #tmp_counterparty_credit_limits cci on sdh.counterparty_id=cci.Counterparty_id 
				and cci.contract_id=sdh.contract_id
				and cci.effective_date <= ''' + @as_of_date + '''
			cross join #as_of_dates dt 
			where ifb.as_of_date = dt.as_of_date 	
			group by cci.internal_counterparty_id , cci.contract_id, dt.as_of_date 
		) a  group by source_counterparty_id,as_of_date, internal_counterparty_id, contract_id
	'
	--PRINT @sqlSelect

	EXEC (@sqlSelect)

	create index index_climits on #climits (source_counterparty_id ,as_of_date)

	SET @pr_name= 'limits populated'
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************End of collecting in #climits - limits *****************************'	
	END


	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
	END
	CREATE TABLE #limit_check (
		netting_parent_group_id INT,
		source_counterparty_id INT,
		tenor_limit INT, 
		tenor_days INT, 
		total_limit_provided FLOAT, 
		total_limit_received FLOAT, 
		net_exposure_to_us FLOAT, 
		net_exposure_to_them FLOAT, 
		total_net_exposure FLOAT, 
		limit_to_us_avail FLOAT, 
		limit_to_them_avail FLOAT, 
		limit_to_us_violated INT, 
		limit_to_them_violated INT, 
		tenor_limit_violated INT, 
		limit_to_us_variance FLOAT, 
		limit_to_them_variance FLOAT,
		d_net_exposure_to_us FLOAT, 
		d_net_exposure_to_them FLOAT, 
		d_total_net_exposure FLOAT, 
		d_limit_to_us_avail FLOAT, 
		d_limit_to_them_avail FLOAT, 
		d_limit_to_us_variance FLOAT, 
		d_limit_to_them_variance FLOAT
		,as_of_date DATETIME
		,internal_counterparty_id INT
		,contract_id INT
		,currency_id INT
		,prepay_provided FLOAT
		,prepay_received FLOAT
	)
	INSERT INTO #limit_check
	SELECT	DISTINCT
			eto.netting_parent_group_id netting_parent_group_id,
			cl.source_counterparty_id source_counterparty_id,
			cl.tenor_limit, cl.days tenor_days, cl.total_limit_provided, cl.total_limit_received, 
			eto.total_exposure_us net_exposure_to_us, 
			ISNULL(eto.total_exposure_them,0)  net_exposure_to_them,
			ISNULL(eto.total_exposure, 0) total_net_exposure,
			CASE WHEN (ISNULL(eto.total_exposure_us,0) > cl.total_limit_provided OR cl.total_limit_provided = 0) THEN 0 ELSE cl.total_limit_provided - ISNULL(eto.total_exposure_us,0) END limit_to_us_avail,
			CASE WHEN (ABS(ISNULL(eto.total_exposure_them,0)) > cl.total_limit_received OR cl.total_limit_received = 0) THEN 0 ELSE cl.total_limit_received - ABS(ISNULL(eto.total_exposure_them,0)) END limit_to_them_avail,
			case when (ISNULL(eto.total_exposure_us,0) > cl.total_limit_provided) then 1 else 0 end limit_to_us_violated,
			case when  (ABS(eto.total_exposure_them) > cl.total_limit_received) then 1 ELSE 0 END limit_to_them_violated,
			CASE WHEN (cl.days > cl.tenor_limit) THEN 1 ELSE 0 END tenor_limit_violated,
			ISNULL(cl.total_limit_provided, 0) - ISNULL(eto.total_exposure_us, 0) limit_to_us_variance,
			ISNULL(cl.total_limit_received, 0) - ABS(ISNULL(eto.total_exposure_them, 0)) limit_to_them_variance,
			ISNULL(eto.d_total_exposure_us, 0) d_net_exposure_to_us, ISNULL(eto.d_total_exposure_them, 0) d_net_exposure_to_them,
			ISNULL(eto.d_total_exposure, 0)  d_total_net_exposure,
			CASE WHEN (eto.total_exposure_us > cl.total_limit_provided OR cl.total_limit_provided = 0) THEN 0 ELSE cl.total_limit_provided - eto.d_total_exposure_us END d_limit_to_us_avail,
			CASE WHEN (ABS(eto.total_exposure_them) > cl.total_limit_received OR cl.total_limit_received = 0) THEN 0 ELSE cl.total_limit_received - ABS(eto.d_total_exposure_them) END d_limit_to_them_avail,
			ISNULL(cl.total_limit_provided, 0) - ISNULL(eto.d_total_exposure_us, 0) d_limit_to_us_variance,
			ISNULL(cl.total_limit_received, 0) - ABS(ISNULL(eto.d_total_exposure_them, 0)) d_limit_to_them_variance
			,cl.as_of_date,cl.internal_counterparty_id , cl.contract_id, cl.currency_id, cl.prepay_provided, cl.prepay_received

	FROM #climits cl LEFT OUTER JOIN
	(
		SELECT	as_of_date,netting_parent_group_id, source_counterparty_id,internal_counterparty_id,contract_id, 
			sum(case when exposure_to_us = 1 then ISNULL(total_und_exposure,0)  else 0 end) total_exposure_us,
			sum(case when exposure_to_us = 1 then ISNULL(total_dis_exposure,0)  else 0 end) d_total_exposure_us,
			sum(case when exposure_to_us = 0 then ISNULL(total_und_exposure,0)  else 0 end) total_exposure_them,
			sum(case when exposure_to_us =0 then ISNULL(total_dis_exposure,0)  else 0 end) d_total_exposure_them,
			sum(ISNULL(total_und_exposure,0)) total_exposure,
			sum(ISNULL(total_dis_exposure,0)) d_total_exposure
	FROM #exp_test
		GROUP BY netting_parent_group_id, source_counterparty_id,as_of_date,internal_counterparty_id,contract_id
	) eto ON cl.source_counterparty_id = eto.source_counterparty_id
	AND ISNULL(cl.internal_counterparty_id, 0) = ISNULL(eto.internal_counterparty_id, 0) 
	AND ISNULL(cl.contract_id, 0) = ISNULL(eto.contract_id, 0)
	create index indx_check_limits on #limit_check (netting_parent_group_id ,source_counterparty_id ,as_of_date)

		SET @pr_name= 'limit check populated'
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************End of collecting in #limit_check - limits check*****************************'	
	END

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
	END
	

	
	
		---------------------------------PURGE DATA  BEFORE ISNERTING

		IF @print_diagnostic = 1
		BEGIN
			SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
			SET @log_increment = @log_increment + 1
			SET @log_time=GETDATE()
			PRINT @pr_name+' Running..............'
		END


		IF @purge_all = 'y'
		BEGIN
			DELETE FROM credit_exposure_detail WHERE as_of_date = @as_of_date AND curve_source_value_id = @curve_source_value_id
			DELETE FROM credit_exposure_summary WHERE as_of_date = @as_of_date AND curve_source_value_id = @curve_source_value_id
		END

		IF @print_diagnostic = 1
		BEGIN
			PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
			PRINT '****************Purging All Exposure Detail Data *****************************'	
		END


		IF @print_diagnostic = 1
		BEGIN
			SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
			SET @log_increment = @log_increment + 1
			SET @log_time=GETDATE()
			PRINT @pr_name+' Running..............'
		END
		
		IF @calc_type <> 'w'
		BEGIN
			SET @sql_stmt = '
			DELETE  credit_exposure_detail 
			FROM credit_exposure_detail  ced 
			INNER JOIN #cpty c ON c.source_counterparty_id = ced.source_counterparty_id
			WHERE ced.as_of_date = ''' + cast(@as_of_date AS VARCHAR) + '''
				AND ced.curve_source_value_id = ''' + cast(@curve_source_value_id AS VARCHAR) + ''''
			
			--PRINT @sql_stmt
			EXEC(@sql_stmt)
			
			SET @sql_stmt = '
			DELETE ces 
			FROM credit_exposure_summary ces 
			INNER JOIN #cpty c ON c.source_counterparty_id = ces.source_counterparty_id
			WHERE ces.as_of_date = ''' + cast(@as_of_date AS VARCHAR) + '''
				AND ces.curve_source_value_id = ''' + cast(@curve_source_value_id AS VARCHAR) + ''''
			
			--PRINT @sql_stmt
			EXEC(@sql_stmt)
		END		
		
		IF @calc_type_rep = 'm'
		BEGIN
			IF @purge_all = 'y'
			BEGIN
				DELETE FROM credit_exposure_detail_whatif WHERE as_of_date = @as_of_date AND curve_source_value_id = @curve_source_value_id
				DELETE FROM credit_exposure_summary_whatif WHERE as_of_date = @as_of_date AND curve_source_value_id = @curve_source_value_id
			END
			
			SET @sql_stmt = '
			DELETE ced 
			FROM credit_exposure_detail_whatif  ced 
			INNER JOIN #cpty c ON c.source_counterparty_id = ced.source_counterparty_id
			WHERE ced.as_of_date = ''' + cast(@as_of_date AS VARCHAR) + '''
				AND ced.curve_source_value_id = ''' + cast(@curve_source_value_id AS VARCHAR) + '''
				AND ced.whatif_criteria_id = ' + CAST(ABS(@criteria_id) AS VARCHAR)
			
			--PRINT @sql_stmt
			EXEC(@sql_stmt)
			
			SET @sql_stmt = '
			DELETE ces 
			FROM credit_exposure_summary_whatif ces 
			INNER JOIN #cpty c ON c.source_counterparty_id = ces.source_counterparty_id
			WHERE ces.as_of_date = ''' + cast(@as_of_date AS VARCHAR) + '''
				AND ces.curve_source_value_id = ''' + cast(@curve_source_value_id AS VARCHAR) + '''
				AND ces.whatif_criteria_id = ' + CAST(ABS(@criteria_id) AS VARCHAR)
			
			--PRINT @sql_stmt
			EXEC(@sql_stmt)
			
		END

		IF @print_diagnostic = 1
		BEGIN
			PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
			PRINT '****************Purging Exposure Detail Data Before Inserting *****************************'	
		END

		-----------------------------------END OF PURGE DATA BEFORE ISNERTING

		IF @print_diagnostic = 1
		BEGIN
			SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
			SET @log_increment = @log_increment + 1
			SET @log_time=GETDATE()
			PRINT @pr_name+' Running..............'
		END

	SET @sqlSelect = 'UPDATE cd
	SET cd.final_und_pnl = (cd.final_und_pnl + sp.amount),
		cd.final_dis_pnl = (cd.final_dis_pnl + sp.amount)
	--SELECT cd.final_und_pnl, sp.amount
	FROM ' + @NettingProcessTableOneName + ' cd
	OUTER APPLY(SELECT ISNULL(SUM(amount), 0) amount
				FROM stmt_prepay sp 
				WHERE sp.source_deal_header_id = cd.source_deal_header_id
				AND sp.is_prepay = ''n''
				AND sp.settlement_date <= '''+@as_of_date+''') sp'

	EXEC(@sqlSelect)

	--SELECT * FROM adiha_process.dbo.calcprocess_credit_netting_one_sbohara_C80DF8F1_4E14_41B3_86D8_20F1185A6E4B RETURN

	set @sqlSelect = '
		select
			id = IDENTITY(INT, 1, 1),	
			'''+@as_of_date+''' as_of_date,
			' + CAST(@curve_source_value_id AS VARCHAR) +' curve_source_value_id,
			cd.Netting_Parent_Group_ID,
			cd.Netting_Parent_Group_Name,
			cd.Netting_Group_ID,
			cd.Netting_Group_Name,
			cd.Netting_Group_Detail_ID,
			cd.fas_subsidiary_id,
			cd.fas_strategy_id,
			cd.fas_book_id,
			cd.Source_Deal_Header_ID,
			cd.Source_Counterparty_ID,
			cd.term_start,
			case when (cd.term_start between dbo.FNAGetContractMonth(''' + CAST(@as_of_date AS VARCHAR) + ''') and dateadd(mm, 2, ''' + CAST(@as_of_date AS VARCHAR) + ''')) then dbo.FNADateFormat(cd.term_start)
				 when (cd.term_start between dbo.FNAGetContractMonth(dateadd(mm, 3, ''' + CAST(@as_of_date AS VARCHAR) + ''')) and dateadd(mm, 5, ''' + CAST(@as_of_date AS VARCHAR) + ''')) then dbo.FNADateFormat(dbo.FNAGetContractMonth(dateadd(mm, 3, ''' + CAST(@as_of_date AS VARCHAR)+ '''))) + '' (3Mths)''
				 when (cd.term_start between dbo.FNAGetContractMonth(dateadd(mm, 6, ''' + CAST(@as_of_date AS VARCHAR) + ''')) and dateadd(mm, 11, ''' + CAST(@as_of_date AS VARCHAR) + ''')) then dbo.FNADateFormat(dbo.FNAGetContractMonth(dateadd(mm, 6, ''' + CAST(@as_of_date AS VARCHAR) + '''))) + '' (6Mths)''
				 else dbo.FNADateFormat(dbo.FNAGetContractMonth(dateadd(mm, 12, ''' + CAST(@as_of_date AS VARCHAR) + '''))) + '' (12Mths+)'' 
			end agg_term_start,
			cd.Final_Und_Pnl,
			cd.Final_Dis_Pnl,
			cd.legal_entity,
			cd.exp_type_id, 
			LTRIM(RTRIM(cd.exp_type)) exp_type,
			case when ((ISNULL(cd1.final_pnl,cd.Final_Und_Pnl) > 0 AND cd.exp_type_id NOT IN (7, 8)) OR cd.exp_type_id = 7) then cd.Final_Und_Pnl else 0 end gross_exposure,
			case when ((ISNULL(cd1.final_pnl,cd.Final_Und_Pnl) > 0 AND cd.exp_type_id NOT IN (7, 8)) OR cd.exp_type_id = 7) then cd.Final_Dis_Pnl else 0 end d_gross_exposure,
			cd.invoice_due_date,
			datediff(dd, cd.invoice_due_date,''' +CAST(@as_of_date AS VARCHAR)+ ''') aged_invoice_days,
			cp.netting_counterparty_id,
			cp.counterparty_name,
			cp.parent_counterparty_name,
			cp.counterparty_type,
			cp.risk_rating,
			cp.debt_rating,
			cp.industry_type1,
			cp.industry_type2,
			cp.sic_code,
			cp.account_status,
			ISNULL(cp.currency_name, sc.currency_name) currency_name,
			--cp.tenor_limit,
			cp.watch_list,
			cp.int_ext_flag,
			lc.tenor_limit, lc.tenor_days, lc.total_limit_provided, lc.total_limit_received, 
			CASE WHEN cd.exposure_to_us=1 THEN cd.Final_Und_Pnl ELSE 0 END net_exposure_to_us, 
			CASE WHEN cd.exposure_to_us=0 THEN cd.Final_Und_Pnl ELSE 0 END net_exposure_to_them, 
			lc.total_net_exposure, 
			lc.limit_to_us_avail, 
			lc.limit_to_them_avail, 
			lc.limit_to_us_violated, 
			lc.limit_to_them_violated, 
			lc.tenor_limit_violated, 
			lc.limit_to_us_variance, 
			lc.limit_to_them_variance,
			CASE WHEN cd.exposure_to_us=1 THEN cd.Final_Dis_Pnl ELSE 0 END d_net_exposure_to_us, 
			CASE WHEN cd.exposure_to_us=0 THEN cd.Final_Dis_Pnl ELSE 0 END d_net_exposure_to_them, 
			lc.d_total_net_exposure, 
			lc.d_limit_to_us_avail, 
			lc.d_limit_to_them_avail, 
			lc.d_limit_to_us_variance, 
			lc.d_limit_to_them_variance,
			cp.risk_rating_id,
			cp.debt_rating_id,
			cp.industry_type1_id,
			cp.industry_type2_id,
			cp.sic_code_id,
			cp.counterparty_type_id,
			CASE WHEN (ISNULL(cd1.final_pnl,cd.Final_Und_Pnl) < 0 AND cd.exp_type_id IN (2,5,6)) THEN cd.Final_Und_Pnl ELSE 0 END gross_exposure_to_them,
			COALESCE(cd.netting_ic_id, cd.internal_counterparty_id, lc.internal_counterparty_id) internal_counterparty_id,
			ISNULL(cd.netting_contract_id,cd.contract_id) contract_id,
			lc.prepay_provided,
			lc.prepay_received--,
			--cd.netting_ic_id,
			--cd.netting_contract_id
		into ' + @CreditExposureDetail + '
		from ' + @NettingProcessTableOneName + ' cd 
		inner join fas_subsidiaries fs on fs.fas_subsidiary_id=cd.fas_subsidiary_id
		INNER JOIN #cpty cp ON cp.source_counterparty_id = cd.source_counterparty_id 
		left JOIN #limit_check lc ON lc.netting_parent_group_id = cd.netting_parent_group_id 
			AND lc.source_counterparty_id = cd.source_counterparty_id 
			and ISNULL(fs.counterparty_id, 1) = COALESCE(lc.internal_counterparty_id, fs.counterparty_id, 1) 
			and ISNULL(cd.contract_id,-1) = ISNULL(lc.contract_id,-1)
		left join source_currency sc ON sc.source_currency_id = lc.currency_id
		OUTER APPLY (SELECT sum(final_und_pnl) final_pnl
				FROM ' + @NettingProcessTableOneName + ' cd1
				WHERE cd1.source_counterparty_id = cd.source_counterparty_id
				AND ISNULL(cd1.netting_ic_id, -1) = ISNULL(cd.netting_ic_id, -1)
				AND cd1.netting_contract_id = cd.netting_contract_id) cd1'

		--PRINT(@sqlSelect)
		EXEC(@sqlSelect)
	-------------------------NEW ENHANCEMENT START--------------------------------

	IF OBJECT_ID('tempdb..#tmp_credit_detail') IS NOT NULL 
		DROP TABLE #tmp_credit_detail
		
	IF OBJECT_ID('tempdb..#tmp_exposure') IS NOT NULL 
		DROP TABLE #tmp_exposure
		
	IF OBJECT_ID('tempdb..#tmp_derive_col') IS NOT NULL 
		DROP TABLE #tmp_derive_col
		
	CREATE TABLE #tmp_credit_detail(
		id	INT,
		ar_prior	FLOAT,
		ar_current	FLOAT,
		other_ar_prior float,	
		other_ar_current float,
		ap_prior	FLOAT,
		ap_current	FLOAT,
		other_ap_prior float,	
		other_ap_current float,
		bom_exposure_to_us	FLOAT,
		d_bom_exposure_to_us	FLOAT,
		other_bom_exposure_to_us float,	
		bom_exposure_to_them	FLOAT,
		d_bom_exposure_to_them	FLOAT,
		other_bom_exposure_to_them float,
		mtm_exposure_to_us	FLOAT,
		mtm_exposure_to_them	FLOAT,
		d_mtm_exposure_to_us	FLOAT,
		d_mtm_exposure_to_them	FLOAT,
		other_mtm_exposure_to_us float,	
		other_mtm_exposure_to_them float,
		colletral_received	FLOAT,
		colletral_provided	FLOAT,
		cash_colletral_received	FLOAT,
		cash_colletral_provided	FLOAT,
		not_used_colletral_received	FLOAT,
		not_used_colletral_provided	FLOAT,
		limit_provided	FLOAT,
		limit_received	FLOAT,
		threshold_received	FLOAT,
		threshold_provided	FLOAT,
		apply_netting_rule	CHAR(1) COLLATE DATABASE_DEFAULT
	)

	IF OBJECT_ID('tempdb..#tmp_avail_limit_for') IS NOT NULL 
		DROP TABLE #tmp_avail_limit_for
	
	IF OBJECT_ID('tempdb..#tmp_avail_colletral_for') IS NOT NULL 
		DROP TABLE #tmp_avail_colletral_for
		
	CREATE TABLE #tmp_avail_limit_for(
		source_counterparty_id INT,
		internal_counterparty_id INT,
		contract_id INT
	)
	
	CREATE TABLE #tmp_avail_colletral_for(
		source_counterparty_id INT,
		internal_counterparty_id INT,
		contract_id INT
	)
	
	SET @sqlSelect = 'INSERT INTO #tmp_avail_limit_for	
	SELECT DISTINCT c.source_counterparty_id, 
		ccl.internal_counterparty_id,
		ccl.contract_id
	FROM (SELECT DISTINCT ced.source_counterparty_id FROM ' + @CreditExposureDetail + ' ced) c
	LEFT JOIN #tmp_counterparty_credit_limits ccl ON ccl.counterparty_id = c.source_counterparty_id
		AND ccl.effective_date <= ''' + @as_of_date + ''''
	
	--PRINT(@sqlSelect)
	EXEC(@sqlSelect)
	
	SET @sqlSelect = 'INSERT INTO #tmp_avail_colletral_for	
	SELECT DISTINCT c.source_counterparty_id, 
		cce.internal_counterparty AS internal_counterparty_id,
		cce.contract_id AS contract_id
	FROM (SELECT DISTINCT ced.source_counterparty_id FROM ' + @CreditExposureDetail + ' ced) c
	INNER JOIN counterparty_credit_info cci ON cci.counterparty_id = c.source_counterparty_id
	INNER JOIN #counterparty_credit_enhancements cce ON cce.counterparty_credit_info_id = cci.counterparty_credit_info_id
		AND cce.eff_date <= ''' + @as_of_date + '''
		AND cce.deal_id IS NULL
		AND ((''' + @as_of_date + ''' BETWEEN ISNULL(cce.eff_date, ''' + @as_of_date + ''') AND ISNULL(cce.expiration_date, ''' + @as_of_date + ''')) OR cce.auto_renewal = ''y'')'
	
	--PRINT(@sqlSelect)
	EXEC(@sqlSelect)
	
	IF OBJECT_ID('tempdb..#tmp_limit_summary') IS NOT NULL 
		DROP TABLE #tmp_limit_summary
		
	CREATE TABLE #tmp_limit_summary(
		source_counterparty_id INT,
		internal_counterparty_id INT,
		contract_id INT,
		sum_us FLOAT,
		sum_them FLOAT,
		totTerm INT
	)

	SET @sqlSelect = 'INSERT INTO #tmp_limit_summary
		SELECT tica.source_counterparty_id, tica.internal_counterparty_id, tica.contract_id,
			SUM(CASE WHEN net_exposure_to_us > 0 THEN net_exposure_to_us ELSE 0 END) sum_us,
			ABS(SUM(CASE WHEN net_exposure_to_them < 0 THEN net_exposure_to_them ELSE 0 END)) sum_them,
			NULLIF(COUNT(term_start), 0) totTerm
		FROM ' + @CreditExposureDetail + ' c
		INNER JOIN #tmp_avail_limit_for tica ON tica.source_counterparty_id = c.source_counterparty_id
			AND (tica.internal_counterparty_id IS NULL OR  tica.internal_counterparty_id = c.internal_counterparty_id)
			AND (tica.contract_id IS NULL OR  tica.contract_id = c.contract_id)
		GROUP BY tica.source_counterparty_id, tica.internal_counterparty_id, tica.contract_id'
		
	--PRINT(@sqlSelect)
	EXEC(@sqlSelect)

	IF OBJECT_ID('tempdb..#tmp_colletral_summary') IS NOT NULL 
		DROP TABLE #tmp_colletral_summary
		
	CREATE TABLE #tmp_colletral_summary(
		source_counterparty_id INT,
		internal_counterparty_id INT,
		contract_id INT,
		sum_us FLOAT,
		sum_them FLOAT,
		totTerm INT
	)
	
	SET @sqlSelect = 'INSERT INTO #tmp_colletral_summary
	SELECT tacf.source_counterparty_id, tacf.internal_counterparty_id, tacf.contract_id,
		SUM(CASE WHEN net_exposure_to_us > 0 THEN net_exposure_to_us ELSE 0 END) sum_us,
		ABS(SUM(CASE WHEN net_exposure_to_them < 0 THEN net_exposure_to_them ELSE 0 END)) sum_them,
		NULLIF(COUNT(term_start), 0) totTerm
	FROM ' + @CreditExposureDetail + ' c
	INNER JOIN #tmp_avail_colletral_for tacf ON c.source_counterparty_id = tacf.source_counterparty_id
		AND (tacf.internal_counterparty_id IS NULL OR  tacf.internal_counterparty_id = c.internal_counterparty_id)
		AND (tacf.contract_id IS NULL OR  tacf.contract_id = c.contract_id)
	GROUP BY tacf.source_counterparty_id, tacf.internal_counterparty_id, tacf.contract_id'
	
	--PRINT(@sqlSelect)
	EXEC(@sqlSelect)

	IF OBJECT_ID('tempdb..#counterparty_contract_address') IS NOT NULL 
		DROP TABLE #counterparty_contract_address

	SELECT 
		ISNULL(sng.netting_contract_id, cca.contract_id) AS contract_id,
		cca.counterparty_id,
		cca.contract_start_date,
		cca.contract_end_date,
		cca.apply_netting_rule,
		cca.contract_date,
		cca.contract_status,
		cca.contract_active,
		ISNULL(sng.internal_counterparty_id, cca.internal_counterparty_id) AS internal_counterparty_id,
		cca.rounding,
		cca.margin_provision,
		cca.invoice_due_date,
		cca.holiday_calendar_id,
		cca.threshold_provided,
		cca.threshold_received,
		cca.allow_all_products,
		cca.credit
	INTO #counterparty_contract_address
	FROM #cpty c 
	INNER JOIN counterparty_contract_address cca ON c.source_counterparty_id = cca.counterparty_id
	OUTER APPLY (SELECT ISNULL(sng.internal_counterparty_id, @master_counterparty_id) AS internal_counterparty_id,
				sng.netting_contract_id
				FROM stmt_netting_group sng 
				INNER JOIN stmt_netting_group_detail sngd ON sngd.netting_group_id = sng.netting_group_id
					AND sngd.contract_detail_id = cca.contract_id
				OUTER APPLY(SELECT MAX(sng1.effective_date) eff_date,
								MAX(sng1.internal_counterparty_id) AS internal_counterparty_id 
							FROM stmt_netting_group sng1
							WHERE sng1.counterparty_id = sng.counterparty_id
							AND ISNULL(sng1.internal_counterparty_id, -1) = ISNULL(sng.internal_counterparty_id, -1)
							AND sng1.netting_type IN (109802,109800)
							AND sng1.effective_date <= @as_of_date) eff
				WHERE sng.counterparty_id = c.source_counterparty_id
				AND sng.effective_date = eff.eff_date
				AND ISNULL(sng.internal_counterparty_id, -1) = ISNULL(eff.internal_counterparty_id, -1)
				AND COALESCE(sng.internal_counterparty_id, cca.internal_counterparty_id, -1) = COALESCE(cca.internal_counterparty_id, sng.internal_counterparty_id, -1)
				AND sng.netting_type IN (109802,109800)) sng

	SET @sqlSelect = 'INSERT INTO #tmp_credit_detail
		SELECT
			id,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) < 0 AND ced.exp_type_id IN (3,4,5,6,7,8) THEN ced.d_net_exposure_to_us ELSE 0 END ar_prior,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (3,4,5,6,7,8) THEN ced.d_net_exposure_to_us ELSE 0 END ar_current,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) < 0 AND ced.exp_type_id IN (11,12) THEN ced.d_net_exposure_to_us ELSE 0 END other_ar_prior,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (11,12) THEN ced.d_net_exposure_to_us ELSE 0 END other_ar_current,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) < 0 AND ced.exp_type_id IN (3,4,5,6,7,8) THEN ced.d_net_exposure_to_them ELSE 0 END ap_prior,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (3,4,5,6,7,8) THEN ced.d_net_exposure_to_them ELSE 0 END ap_current,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) < 0 AND ced.exp_type_id IN (11,12) THEN ced.d_net_exposure_to_them ELSE 0 END other_ap_prior,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (11,12) THEN ced.d_net_exposure_to_them ELSE 0 END other_ap_current,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (1,2) THEN ced.net_exposure_to_us ELSE 0 END bom_exposure_to_us,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (1,2) THEN ced.d_net_exposure_to_us ELSE 0 END d_bom_exposure_to_us,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (9,10) THEN ced.net_exposure_to_us ELSE 0 END other_bom_exposure_to_us,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (1,2) THEN ced.net_exposure_to_them ELSE 0 END bom_exposure_to_them,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (1,2) THEN ced.d_net_exposure_to_them ELSE 0 END d_bom_exposure_to_them,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) = 0 AND ced.exp_type_id IN (9,10) THEN ced.net_exposure_to_them ELSE 0 END other_bom_exposure_to_them,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) <> 0 AND ced.exp_type_id IN (1,2) THEN ced.net_exposure_to_us ELSE 0 END mtm_exposure_to_us,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) <> 0 AND ced.exp_type_id IN (1,2) THEN ced.net_exposure_to_them ELSE 0 END mtm_exposure_to_them,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) <> 0 AND ced.exp_type_id IN (1,2) THEN ced.d_net_exposure_to_us ELSE 0 END d_mtm_exposure_to_us,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) <> 0 AND ced.exp_type_id IN (1,2) THEN ced.d_net_exposure_to_them ELSE 0 END d_mtm_exposure_to_them,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) <> 0 AND ced.exp_type_id IN (9,10) THEN ced.net_exposure_to_us ELSE 0 END other_mtm_exposure_to_us,
			CASE WHEN DATEDIFF(DAY, dbo.FNAGetContractMonth(ced.as_of_date), dbo.FNAGetContractMonth(ced.term_start)) <> 0 AND ced.exp_type_id IN (9,10) THEN ced.net_exposure_to_them ELSE 0 END other_mtm_exposure_to_them,
			CASE WHEN net_exposure_to_us >= 0 THEN
				CASE WHEN mc1.sum_us = 0 THEN
					ISNULL((ISNULL(non_cash.colletral_received, 0)*CASE WHEN net_exposure_to_us = 0 THEN 1 ELSE net_exposure_to_us END/mc1.totTerm), 0)
				ELSE
					ISNULL((ISNULL(non_cash.colletral_received, 0)*net_exposure_to_us/mc1.sum_us), 0)
				END
			ELSE 0 END colletral_received,

			CASE WHEN net_exposure_to_them <= 0 THEN
				CASE WHEN mc1.sum_them = 0 THEN
					ISNULL((ISNULL(non_cash.colletral_provided, 0)*CASE WHEN net_exposure_to_them = 0 THEN 1 ELSE net_exposure_to_them END/mc1.totTerm), 0)
				ELSE
					(ISNULL((ISNULL(non_cash.colletral_provided, 0)*net_exposure_to_them/mc1.sum_them), 0)* -1)
				END
			ELSE 0 END colletral_provided,
			
			CASE WHEN net_exposure_to_us >= 0 THEN
				CASE WHEN mc1.sum_us = 0 THEN
					ISNULL((ISNULL(cash.cash_colletral_received, 0)*CASE WHEN net_exposure_to_us = 0 THEN 1 ELSE net_exposure_to_us END/mc1.totTerm), 0)
				ELSE
					ISNULL((ISNULL(cash.cash_colletral_received, 0)*net_exposure_to_us/mc1.sum_us), 0)
				END
			ELSE 0 END cash_colletral_received,

			CASE WHEN net_exposure_to_them <= 0 THEN
				CASE WHEN mc1.sum_them = 0 THEN
					ISNULL((ISNULL(cash.cash_colletral_provided, 0)*CASE WHEN net_exposure_to_them = 0 THEN 1 ELSE net_exposure_to_them END/mc1.totTerm), 0)
				ELSE
					(ISNULL((ISNULL(cash.cash_colletral_provided, 0)*net_exposure_to_them/mc1.sum_them), 0)* -1)
				END
			ELSE 0 END cash_colletral_provided,
			
			CASE WHEN net_exposure_to_us >= 0 THEN
				CASE WHEN mc1.sum_us = 0 THEN
					ISNULL((ISNULL(not_used.not_used_colletral_received, 0)*CASE WHEN net_exposure_to_us = 0 THEN 1 ELSE net_exposure_to_us END/mc1.totTerm), 0)
				ELSE
					ISNULL((ISNULL(not_used.not_used_colletral_received, 0)*net_exposure_to_us/mc1.sum_us), 0)
				END
			ELSE 0 END not_used_colletral_received,

			CASE WHEN net_exposure_to_them <= 0 THEN
				CASE WHEN mc1.sum_them = 0 THEN
					ISNULL((ISNULL(not_used.not_used_colletral_provided, 0)*CASE WHEN net_exposure_to_them = 0 THEN 1 ELSE net_exposure_to_them END/mc1.totTerm), 0)
				ELSE
					(ISNULL((ISNULL(not_used.not_used_colletral_provided, 0)*net_exposure_to_them/mc1.sum_them), 0)* -1)
				END
			ELSE 0 END not_used_colletral_provided,

			CASE WHEN net_exposure_to_us >= 0 THEN
				CASE WHEN mc.sum_us = 0 THEN
					ISNULL((ISNULL(ccl.credit_limit, 0)*CASE WHEN net_exposure_to_us = 0 THEN 1 ELSE net_exposure_to_us END/mc.totTerm), 0)
				ELSE
					ISNULL((ISNULL(ccl.credit_limit, 0)*net_exposure_to_us/mc.sum_us), 0)
				END
			ELSE 0 END limit_provided,

			CASE WHEN net_exposure_to_them <= 0 THEN
				CASE WHEN mc.sum_them = 0 THEN
					ISNULL((ISNULL(ccl.credit_limit_to_us, 0)*CASE WHEN net_exposure_to_them = 0 THEN 1 ELSE net_exposure_to_them END/mc.totTerm), 0)
				ELSE
					(ISNULL((ISNULL(ccl.credit_limit_to_us, 0)*net_exposure_to_them/mc.sum_them), 0)* -1)
				END
			ELSE 0 END limit_received,
			
			CASE WHEN net_exposure_to_them <= 0 THEN
				CASE WHEN mc.sum_them = 0 THEN
					ISNULL((ISNULL(cca.threshold_received, 0)*CASE WHEN net_exposure_to_them = 0 THEN 1 ELSE net_exposure_to_them END/mc.totTerm), 0)
				ELSE
					(ISNULL((ISNULL(cca.threshold_received, 0)*net_exposure_to_them/mc.sum_them), 0)* -1)
				END
			ELSE 0 END threshold_received,
			
			CASE WHEN net_exposure_to_us >= 0 THEN
				CASE WHEN mc.sum_us = 0 THEN
					ISNULL((ISNULL(cca.threshold_provided, 0)*CASE WHEN net_exposure_to_us = 0 THEN 1 ELSE net_exposure_to_us END/mc.totTerm), 0)
				ELSE
					ISNULL((ISNULL(cca.threshold_provided, 0)*net_exposure_to_us/mc.sum_us), 0)
				END
			ELSE 0 END threshold_provided,
			ISNULL(cca.apply_netting_rule, ''n'') AS apply_netting_rule'
	
	SET @sqlSelect1 = '	
		FROM source_counterparty sc
		INNER JOIN ' + @CreditExposureDetail + ' ced ON ced.source_counterparty_id = sc.source_counterparty_id
		INNER JOIN counterparty_credit_info cci ON  cci.Counterparty_id = ced.Source_Counterparty_ID
		LEFT JOIN #tmp_limit_summary mc ON mc.source_counterparty_id = sc.source_counterparty_id
				AND mc.source_counterparty_id = ced.source_counterparty_id
				AND (mc.internal_counterparty_id IS NULL OR mc.internal_counterparty_id = ced.internal_counterparty_id)
				AND (mc.contract_id IS NULL OR mc.contract_id = ced.contract_id)
		LEFT JOIN #tmp_colletral_summary mc1 ON mc1.source_counterparty_id = sc.source_counterparty_id
				AND mc1.source_counterparty_id = ced.source_counterparty_id
				AND (mc1.internal_counterparty_id IS NULL OR  mc1.internal_counterparty_id = ced.internal_counterparty_id)
				AND (mc1.contract_id IS NULL OR  mc1.contract_id = ced.contract_id)			
		OUTER APPLY(
				SELECT ISNULL(MAX(cash_colletral_received), 0) cash_colletral_received, ISNULL(MAX(cash_colletral_provided), 0) cash_colletral_provided 
				FROM (	
						SELECT 
							CASE WHEN cce.margin = ''y'' THEN  SUM(cce.amount) ELSE NULL END cash_colletral_received,
							CASE WHEN cce.margin = ''n'' THEN  SUM(cce.amount) ELSE NULL END cash_colletral_provided
						FROM #counterparty_credit_enhancements cce 
						WHERE cce.counterparty_credit_info_id = cci.counterparty_credit_info_id
							AND (cce.internal_counterparty IS NULL OR  cce.internal_counterparty = ced.internal_counterparty_id)
							AND (cce.contract_id IS NULL OR cce.contract_id = ced.contract_id)
							AND ((ced.as_of_date BETWEEN ISNULL(cce.eff_date, ced.as_of_date) AND ISNULL(cce.expiration_date, ced.as_of_date)) OR cce.auto_renewal = ''y'') 
							and cce.exclude_collateral = ''n''
							and cce.eff_date <= ced.as_of_date
							and cce.enhance_type = 10102
							AND cce.deal_id IS NULL
						GROUP BY cce.margin) tt
				) cash
		OUTER APPLY(
				SELECT ISNULL(MAX(colletral_received), 0) colletral_received, ISNULL(MAX(colletral_provided), 0) colletral_provided 
				FROM (	
						SELECT 
							CASE WHEN cce.margin = ''y'' THEN SUM(cce.amount) ELSE NULL END colletral_received,
							CASE WHEN cce.margin = ''n'' THEN SUM(cce.amount) ELSE NULL END colletral_provided
						FROM #counterparty_credit_enhancements cce
						WHERE cce.counterparty_credit_info_id = cci.counterparty_credit_info_id
							AND (cce.internal_counterparty IS NULL OR  cce.internal_counterparty = ced.internal_counterparty_id)
							AND (cce.contract_id IS NULL OR cce.contract_id = ced.contract_id)
							AND ((ced.as_of_date BETWEEN ISNULL(cce.eff_date, ced.as_of_date) AND ISNULL(cce.expiration_date, ced.as_of_date)) OR cce.auto_renewal = ''y'') 
							and cce.exclude_collateral = ''n''
							and cce.eff_date <= ced.as_of_date
							and cce.enhance_type <> 10102
							AND cce.deal_id IS NULL
						GROUP BY cce.margin) tt 
				) non_cash		
		OUTER APPLY(
				SELECT ISNULL(MAX(not_used_colletral_received), 0) not_used_colletral_received, ISNULL(MAX(not_used_colletral_provided), 0) not_used_colletral_provided 
				FROM (	
						SELECT 
							CASE WHEN cce.margin = ''y'' THEN  SUM(cce.amount) ELSE NULL END not_used_colletral_received,
							CASE WHEN cce.margin = ''n'' THEN  SUM(cce.amount) ELSE NULL END not_used_colletral_provided
						FROM #counterparty_credit_enhancements cce 
						WHERE cce.counterparty_credit_info_id = cci.counterparty_credit_info_id
							AND (cce.internal_counterparty IS NULL OR  cce.internal_counterparty = ced.internal_counterparty_id)
							AND (cce.contract_id IS NULL OR cce.contract_id = ced.contract_id)
							AND ((ced.as_of_date BETWEEN ISNULL(cce.eff_date, ced.as_of_date) AND ISNULL(cce.expiration_date, ced.as_of_date)) OR cce.auto_renewal = ''y'') 
							and cce.exclude_collateral = ''y''
							and cce.eff_date <= ced.as_of_date
							--and cce.enhance_type = 10102
							AND cce.deal_id IS NULL
						GROUP BY cce.margin) tt
				) not_used
		OUTER APPLY(
				SELECT  SUM(credit_limit) credit_limit, 
						SUM(credit_limit_to_us) credit_limit_to_us--,
						--SUM(threshold_received) threshold_received,
						--SUM(threshold_provided) threshold_provided
				FROM #tmp_counterparty_credit_limits ccl 
				WHERE ccl.counterparty_id = ced.source_counterparty_id
				AND (ccl.internal_counterparty_id IS NULL OR ccl.internal_counterparty_id = ced.internal_counterparty_id)
				AND (ccl.contract_id IS NULL OR  ccl.contract_id = ced.contract_id)
				AND ccl.effective_date <=  ced.as_of_date) ccl

		OUTER APPLY(SELECT MAX(apply_netting_rule) AS apply_netting_rule,		 	
					SUM(threshold_provided) AS threshold_provided,
					SUM(threshold_received) AS threshold_received
				FROM #counterparty_contract_address cca WHERE cca.counterparty_id = ced.Source_Counterparty_ID
				AND ISNULL(cca.contract_id, 0) = ISNULL(ced.contract_id, 0) 
				AND ISNULL(cca.internal_counterparty_id, 0) = ISNULL(ced.internal_counterparty_id, 0)) cca'



	--PRINT(@sqlSelect+@sqlSelect1)
	EXEC (@sqlSelect+@sqlSelect1)

	--Deal level collateral enhancement	
	SET @sqlSelect = '
	UPDATE tcd
	SET 
		colletral_received = tcd.colletral_received+(non_cash.colletral_received/t.tot_term),
		colletral_provided = tcd.colletral_provided+(non_cash.colletral_provided/t.tot_term),
		cash_colletral_received = tcd.cash_colletral_received+(cash.cash_colletral_received/t.tot_term),
		cash_colletral_provided = tcd.cash_colletral_provided+(cash.cash_colletral_provided/t.tot_term),
		not_used_colletral_received = tcd.not_used_colletral_received+(not_used.not_used_colletral_received/t.tot_term),
		not_used_colletral_provided = tcd.not_used_colletral_provided+(not_used.not_used_colletral_provided/t.tot_term)
	FROM ' + @CreditExposureDetail + ' ced
	INNER JOIN counterparty_credit_info cci ON cci.counterparty_id = ced.source_counterparty_id
	INNER JOIN #tmp_credit_detail tcd ON tcd.id = ced.id 
	OUTER APPLY(SELECT ISNULL(SUM(settlement_amount), 0) samt 
			FROM stmt_checkout sc
			INNER JOIN stmt_prepay sp ON sp.stmt_invoice_detail_id = sc.stmt_invoice_detail_id
				AND sp.source_deal_header_id = ced.source_deal_header_id
				AND ced.as_of_date >= sp.settlement_date
				AND sp.is_prepay = ''n''
			WHERE sc.source_deal_detail_id = ced.source_deal_header_id*-1
			AND sc.term_start = ced.term_start
		AND sc.accrual_or_final = ''f'') sa
	OUTER APPLY(SELECT ISNULL(SUM(sp.amount), 0) amount
			FROM stmt_prepay sp
			WHERE sp.source_deal_header_id = ced.source_deal_header_id
			AND ced.as_of_date >= sp.settlement_date
			AND sp.is_prepay = ''n'') pre
	OUTER APPLY(SELECT 
					ISNULL(MAX(cash_colletral_received), 0) + CASE WHEN pre.amount <= 0 THEN pre.amount ELSE 0 END cash_colletral_received, 
					ISNULL(MAX(cash_colletral_provided), 0) - CASE WHEN pre.amount > 0 THEN pre.amount ELSE 0 END AS cash_colletral_provided 
				FROM (
						SELECT 
								CASE WHEN cce.margin = ''y'' THEN  SUM(cce.amount) ELSE 0 END cash_colletral_received,
								CASE WHEN cce.margin = ''n'' THEN  SUM(cce.amount) ELSE 0 END cash_colletral_provided
							FROM #counterparty_credit_enhancements cce 
							WHERE cce.counterparty_credit_info_id = cci.counterparty_credit_info_id
								AND cce.deal_id = ced.source_deal_header_id
								AND ced.as_of_date BETWEEN ISNULL(cce.eff_date, ced.as_of_date) AND ISNULL(cce.expiration_date, ced.as_of_date) 
								and cce.exclude_collateral = ''n''
								and cce.eff_date <= ced.as_of_date
								and cce.enhance_type = 10102
							GROUP BY cce.margin) tt
				) cash

	OUTER APPLY(
					SELECT ISNULL(MAX(colletral_received), 0) colletral_received, ISNULL(MAX(colletral_provided), 0) colletral_provided 
					FROM (	
							SELECT 
								CASE WHEN cce.margin = ''y'' THEN SUM(cce.amount) ELSE 0 END colletral_received,
								CASE WHEN cce.margin = ''n'' THEN SUM(cce.amount) ELSE 0 END colletral_provided
							FROM #counterparty_credit_enhancements cce
							WHERE cce.counterparty_credit_info_id = cci.counterparty_credit_info_id
								AND cce.deal_id = ced.source_deal_header_id
								AND ced.as_of_date BETWEEN ISNULL(cce.eff_date, ced.as_of_date) AND ISNULL(cce.expiration_date, ced.as_of_date) 
								and cce.exclude_collateral = ''n''
								and cce.eff_date <= ced.as_of_date
								and cce.enhance_type <> 10102
							GROUP BY cce.margin) tt 
					) non_cash

	OUTER APPLY(
					SELECT ISNULL(MAX(not_used_colletral_received), 0) not_used_colletral_received, ISNULL(MAX(not_used_colletral_provided), 0) not_used_colletral_provided 
					FROM (	
							SELECT 
								CASE WHEN cce.margin = ''y'' THEN  SUM(cce.amount) ELSE 0 END not_used_colletral_received,
								CASE WHEN cce.margin = ''n'' THEN  SUM(cce.amount) ELSE 0 END not_used_colletral_provided
							FROM #counterparty_credit_enhancements cce 
							WHERE cce.counterparty_credit_info_id = cci.counterparty_credit_info_id
								AND cce.deal_id = ced.source_deal_header_id
								AND ced.as_of_date BETWEEN ISNULL(cce.eff_date, ced.as_of_date) AND ISNULL(cce.expiration_date, ced.as_of_date) 
								and cce.exclude_collateral = ''y''
								and cce.eff_date <= ced.as_of_date
							GROUP BY cce.margin) tt
					) not_used

	OUTER APPLY(SELECT COUNT(*) tot_term 
				FROM ' + @CreditExposureDetail + ' 
				WHERE source_deal_header_id = ced.source_deal_header_id) t'

	EXEC(@sqlSelect)

	SELECT 
		id,
		CASE WHEN apply_netting_rule = 'y' THEN
			CASE WHEN (ar_current + ar_prior + ap_current + ap_prior + d_bom_exposure_to_us + bom_exposure_to_them + mtm_exposure_to_us + mtm_exposure_to_them) > 0 THEN
				(ar_current + ar_prior + ap_current + ap_prior + bom_exposure_to_us + bom_exposure_to_them + mtm_exposure_to_us + mtm_exposure_to_them)
			ELSE
				0
			END
		ELSE
			(ar_current + ar_prior + bom_exposure_to_us + mtm_exposure_to_us)
		END exposure_to_us,
	
		CASE WHEN apply_netting_rule = 'y' THEN
			CASE WHEN (ar_current + ar_prior + ap_current + ap_prior + bom_exposure_to_us + bom_exposure_to_them + mtm_exposure_to_us + mtm_exposure_to_them) < 0 THEN
				(ar_current + ar_prior + ap_current + ap_prior + bom_exposure_to_us + bom_exposure_to_them + mtm_exposure_to_us + mtm_exposure_to_them)
			ELSE
				0
			END
		ELSE
			(ap_current + ap_prior + bom_exposure_to_them + mtm_exposure_to_them)
		END exposure_to_them,
		
		CASE WHEN apply_netting_rule = 'y' THEN
			CASE WHEN (ar_current + ar_prior + ap_current + ap_prior + d_bom_exposure_to_us + d_bom_exposure_to_them + d_mtm_exposure_to_us + d_mtm_exposure_to_them) > 0 THEN
				(ar_current + ar_prior + ap_current + ap_prior + d_bom_exposure_to_us + d_bom_exposure_to_them + d_mtm_exposure_to_us + d_mtm_exposure_to_them)
			ELSE
				0
			END
		ELSE
			(ar_current + ar_prior + d_bom_exposure_to_us + d_mtm_exposure_to_us)
		END d_exposure_to_us,
	
		CASE WHEN apply_netting_rule = 'y' THEN
			CASE WHEN (ar_current + ar_prior + ap_current + ap_prior + d_bom_exposure_to_us + d_bom_exposure_to_them + d_mtm_exposure_to_us + d_mtm_exposure_to_them) < 0 THEN
				(ar_current + ar_prior + ap_current + ap_prior + d_bom_exposure_to_us + d_bom_exposure_to_them + d_mtm_exposure_to_us + d_mtm_exposure_to_them)
			ELSE
				0
			END
		ELSE
			(ap_current + ap_prior + d_bom_exposure_to_them + d_mtm_exposure_to_them)
		END d_exposure_to_them
	INTO #tmp_exposure	
	FROM #tmp_credit_detail	

	CREATE TABLE #tmp_derive_col(
		ID INT,
		counterparty_credit_support_amt FLOAT,
		internal_credit_support_amt FLOAT,
		d_counterparty_credit_support_amt FLOAT,
		d_internal_credit_support_amt FLOAT,
		effective_exposure_to_us FLOAT,
		effective_exposure_to_them FLOAT,
		d_effective_exposure_to_us FLOAT,
		d_effective_exposure_to_them FLOAT,
		limit_available_to_us FLOAT,
		limit_available_to_them FLOAT,
		d_limit_available_to_us FLOAT,
		d_limit_available_to_them FLOAT)

	SET @sqlSelect = 'INSERT INTO #tmp_derive_col
	SELECT 
		te.id,
		(te.net_exposure_to_us - tcd.threshold_provided) AS counterparty_credit_support_amt,
		(te.net_exposure_to_them + tcd.threshold_received) AS internal_credit_support_amt,
		(te.d_net_exposure_to_us - tcd.threshold_provided) AS d_counterparty_credit_support_amt,
		(te.d_net_exposure_to_them + tcd.threshold_received) AS d_internal_credit_support_amt,
		(te.net_exposure_to_us - (tcd.colletral_received + tcd.cash_colletral_received)) AS effective_exposure_to_us,
		(te.net_exposure_to_them + (tcd.colletral_provided + tcd.cash_colletral_provided)) AS effective_exposure_to_them,
		(te.d_net_exposure_to_us - (tcd.colletral_received + tcd.cash_colletral_received)) AS d_effective_exposure_to_us,
		(te.d_net_exposure_to_them + (tcd.colletral_provided + tcd.cash_colletral_provided)) AS d_effective_exposure_to_them,
		((tcd.limit_received + colletral_provided + cash_colletral_provided) + te.net_exposure_to_them) AS limit_available_to_us,
		((tcd.limit_provided + colletral_received + cash_colletral_received) - te.net_exposure_to_us)  AS limit_available_to_them,
		((tcd.limit_received + colletral_provided + cash_colletral_provided) + te.d_net_exposure_to_them) AS d_limit_available_to_us,
		((tcd.limit_provided + colletral_received + cash_colletral_received) - te.d_net_exposure_to_us)  AS d_limit_available_to_them	   
	FROM ' + @CreditExposureDetail + ' te
	INNER JOIN #tmp_credit_detail tcd ON tcd.id = te.id	'
	
	--print(@sqlSelect)
	exec(@sqlSelect)
	
	-------------------------NEW ENHANCEMENT END--------------------------------

--We are using function 'dbo.FNACeilingMath' below calculate rounding value which is somehow equivalent to CEILING.MATH function of excel	
	DECLARE @credit_detail_table VARCHAR(100), @credit_summary_table VARCHAR(100)
	
	SET @credit_detail_table = 'credit_exposure_detail' + CASE WHEN @calc_type_rep = 'm' THEN '_whatif' ELSE '' END
	SET @credit_summary_table = 'credit_exposure_summary' + CASE WHEN @calc_type_rep = 'm' THEN '_whatif' ELSE '' END
	
	SET @sqlSelect = '
		INSERT INTO ' + @credit_detail_table + ' ( ' + CASE WHEN @calc_type_rep = 'm' THEN 'whatif_criteria_id,' ELSE '' END + '
			as_of_date,
			curve_source_value_id,
			Netting_Parent_Group_ID,
			Netting_Parent_Group_Name,
			Netting_Group_ID,
			Netting_Group_Name,
			Netting_Group_Detail_ID,
			fas_subsidiary_id,
			fas_strategy_id,
			fas_book_id,
			Source_Deal_Header_ID,
			Source_Counterparty_ID,
			term_start,
			agg_term_start,
			Final_Und_Pnl,
			Final_Dis_Pnl,
			legal_entity,
			exp_type_id,
			exp_type,
			gross_exposure,
			d_gross_exposure,
			invoice_due_date,
			aged_invoice_days,
			netting_counterparty_id,
			counterparty_name,
			parent_counterparty_name,
			counterparty_type,
			risk_rating,
			debt_rating,
			industry_type1,
			industry_type2,
			sic_code,
			account_status,
			currency_name,
			watch_list,
			int_ext_flag,
			tenor_limit,
			tenor_days,
			total_limit_provided,
			total_limit_received,
			net_exposure_to_us,
			net_exposure_to_them,
			total_net_exposure,
			limit_to_us_avail,
			limit_to_them_avail,
			limit_to_us_violated,
			limit_to_them_violated,
			tenor_limit_violated,
			limit_to_us_variance,
			limit_to_them_variance,
			d_net_exposure_to_us,
			d_net_exposure_to_them,
			d_total_net_exposure,
			d_limit_to_us_avail,
			d_limit_to_them_avail,
			d_limit_to_us_variance,
			d_limit_to_them_variance,
			risk_rating_id,
			debt_rating_id,
			industry_type1_id,
			industry_type2_id,
			sic_code_id,
			counterparty_type_id,
			gross_exposure_to_them,
			internal_counterparty_id,
			contract_id,
			apply_netting_rule,
			ar_prior,
			ar_current,
			ap_prior,
			ap_current,
			bom_exposure_to_us,
			bom_exposure_to_them,
			d_bom_exposure_to_us,
			d_bom_exposure_to_them,
			mtm_exposure_to_us,
			mtm_exposure_to_them,
			d_mtm_exposure_to_us,
			d_mtm_exposure_to_them,
			exposure_to_us,
			exposure_to_them,
			d_exposure_to_us,
			d_exposure_to_them,
			effective_exposure_to_us,
			effective_exposure_to_them,
			collateral_received,
			collateral_provided,
			cash_collateral_received,
			cash_collateral_provided,
			colletral_not_used_received,
			colletral_not_used_provided,
			prepay_received,
			prepay_provided,
			limit_provided,
			limit_received,
			limit_available_to_us,
			limit_available_to_them,
			threshold_provided,
			threshold_received,
			counterparty_credit_support_amount,
			internal_credit_support_amount,
			d_effective_exposure_to_us,
			d_effective_exposure_to_them,
			buy_sell_flag,
			commodity_id,
			physical_financial_flag,
			trader_id,
			d_counterparty_credit_support_amt,
			d_internal_credit_support_amt,
			d_limit_available_to_us,
			d_limit_available_to_them,
			other_ap_prior,
			other_ap_current,
			other_ar_prior,
			other_ar_current,
			other_bom_exposure_to_us,
			other_bom_exposure_to_them,
			other_mtm_exposure_to_us,
			other_mtm_exposure_to_them
			)
		SELECT DISTINCT	
			' + CASE WHEN @calc_type_rep = 'm' THEN CAST(ABS(@criteria_id) AS VARCHAR) + ',' ELSE '' END + '
			as_of_date,
			curve_source_value_id,
			Netting_Parent_Group_ID,
			Netting_Parent_Group_Name,
			Netting_Group_ID,
			Netting_Group_Name,
			Netting_Group_Detail_ID,
			fas_subsidiary_id,
			fas_strategy_id,
			fas_book_id,
			ced.Source_Deal_Header_ID,
			Source_Counterparty_ID,
			term_start,
			agg_term_start,
			Final_Und_Pnl,
			Final_Dis_Pnl,
			ced.legal_entity,
			exp_type_id,
			exp_type,
			cast(gross_exposure as numeric(38,20)),
			cast(d_gross_exposure as numeric(38,20)),
			ced.invoice_due_date,
			aged_invoice_days,
			netting_counterparty_id,
			counterparty_name,
			parent_counterparty_name,
			counterparty_type,
			risk_rating,
			debt_rating,
			industry_type1,
			industry_type2,
			sic_code,
			account_status,
			currency_name,
			watch_list,
			int_ext_flag,
			tenor_limit,
			tenor_days,
			total_limit_provided,
			total_limit_received,
			net_exposure_to_us,
			net_exposure_to_them,
			total_net_exposure,
			limit_to_us_avail,
			limit_to_them_avail,
			limit_to_us_violated,
			limit_to_them_violated,
			tenor_limit_violated,
			limit_to_us_variance,
			limit_to_them_variance,
			d_net_exposure_to_us,
			d_net_exposure_to_them,
			d_total_net_exposure,
			d_limit_to_us_avail,
			d_limit_to_them_avail,
			d_limit_to_us_variance,
			d_limit_to_them_variance,
			risk_rating_id,
			debt_rating_id,
			industry_type1_id,
			industry_type2_id,
			sic_code_id,
			counterparty_type_id,
			gross_exposure_to_them,
			ced.internal_counterparty_id,
			ced.contract_id,
			tcd.apply_netting_rule,
			tcd.ar_prior,
			tcd.ar_current,
			tcd.ap_prior,
			tcd.ap_current,
			tcd.bom_exposure_to_us,
			tcd.bom_exposure_to_them,
			tcd.d_bom_exposure_to_us,
			tcd.d_bom_exposure_to_them,
			tcd.mtm_exposure_to_us,
			tcd.mtm_exposure_to_them,
			tcd.d_mtm_exposure_to_us,
			tcd.d_mtm_exposure_to_them,
			te.exposure_to_us,
			te.exposure_to_them,
			te.d_exposure_to_us,
			te.d_exposure_to_them,
			tdc.effective_exposure_to_us,
			tdc.effective_exposure_to_them,
			tcd.colletral_received,
			(tcd.colletral_provided),
			tcd.cash_colletral_received,
			(tcd.cash_colletral_provided),
			tcd.not_used_colletral_received,
			tcd.not_used_colletral_provided,
			ced.prepay_received,
			ced.prepay_provided,
			tcd.limit_provided,
			(tcd.limit_received),
			tdc.limit_available_to_us,
			tdc.limit_available_to_them,
			tcd.threshold_provided,
			(tcd.threshold_received),
			tdc.counterparty_credit_support_amt,
			tdc.internal_credit_support_amt,
			tdc.d_effective_exposure_to_us,
			tdc.d_effective_exposure_to_them,
			sdh.header_buy_sell_flag, 
			sdh.commodity_id, 
			sdh.physical_financial_flag, 
			sdh.trader_id,
			tdc.d_counterparty_credit_support_amt,
			tdc.d_internal_credit_support_amt,
			tdc.d_limit_available_to_us,
			tdc.d_limit_available_to_them,
			tcd.other_ap_prior,
			tcd.other_ap_current,
			tcd.other_ar_prior,
			tcd.other_ar_current,
			tcd.other_bom_exposure_to_us,
			tcd.other_bom_exposure_to_them,
			tcd.other_mtm_exposure_to_us,
			tcd.other_mtm_exposure_to_them
		FROM ' + @CreditExposureDetail + ' ced
		LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = ced.source_deal_header_id
		INNER JOIN #tmp_credit_detail tcd ON tcd.id = ced.id
		INNER JOIN #tmp_exposure te ON te.id = ced.id
		INNER JOIN #tmp_derive_col tdc ON tdc.id = ced.id'

	--PRINT(@sqlSelect)
	EXEC(@sqlSelect)	
		
	SET @sqlSelect = '
	SELECT DISTINCT source_counterparty_id into #temp_CreditExposureDetail FROM ' + @CreditExposureDetail +';

		INSERT INTO ' + @credit_summary_table + '( ' + CASE WHEN @calc_type_rep = 'm' THEN 'whatif_criteria_id,' ELSE '' END + '
			as_of_date,
			curve_source_value_id,
			Source_Counterparty_ID,
			internal_counterparty_id,
			contract_id,
			ar_prior,
			ar_current,
			ap_prior,
			ap_current,
			bom_exposure_to_us,
			bom_exposure_to_them,
			mtm_exposure_to_us,
			mtm_exposure_to_them,
			exposure_to_us,
			exposure_to_them,
			total_exposure_to_us_round,
			total_exposure_to_them_round,
			effective_exposure_to_us,
			effective_exposure_to_them,
			d_effective_exposure_to_us,
			d_effective_exposure_to_them,
			effective_exposure_to_us_round,
			effective_exposure_to_them_round,
			collateral_received,
			collateral_provided,
			cash_collateral_received,
			cash_collateral_provided,
			colletral_not_used_received,
			colletral_not_used_provided,
			prepay_received,
			prepay_provided,
			limit_provided,
			limit_received,
			limit_available_to_us,
			limit_available_to_them,
			limit_available_to_us_round,
			limit_available_to_them_round,
			rounding,
			threshold_provided,
			threshold_received,
			counterparty_credit_support_amount,
			internal_credit_support_amount,
			create_user,
			create_ts,
			net_exposure_to_us,
			net_exposure_to_them,
			d_net_exposure_to_us,
			d_net_exposure_to_them,
			d_bom_exposure_to_us,
			d_bom_exposure_to_them,
			d_mtm_exposure_to_us,
			d_mtm_exposure_to_them,
			d_exposure_to_us,
			d_exposure_to_them,
			d_counterparty_credit_support_amt,
			d_internal_credit_support_amt,
			d_limit_available_to_us,
			d_limit_available_to_them,
			currency_name
		)
		SELECT 
			' + CASE WHEN @calc_type_rep = 'm' THEN CAST(ABS(@criteria_id) AS VARCHAR) + ',' ELSE '' END + '
			ced.as_of_date,
			ced.curve_source_value_id,
			ced.Source_Counterparty_ID,
			ced.internal_counterparty_id,
			ced.contract_id,
			SUM(ced.ar_prior+ced.other_ar_prior) ar_prior,
			SUM(ced.ar_current+ced.other_ar_current) ar_current,
			SUM(ced.ap_prior+ced.other_ap_prior) ap_prior,
			SUM(ced.ap_current+ced.other_ap_current) ap_current,
			SUM(ced.bom_exposure_to_us+ced.other_bom_exposure_to_us) bom_exposure_to_us,
			SUM(ced.bom_exposure_to_them+ced.other_bom_exposure_to_them) bom_exposure_to_them,
			SUM(ced.mtm_exposure_to_us+ced.other_mtm_exposure_to_us) mtm_exposure_to_us,
			SUM(ced.mtm_exposure_to_them+ced.other_mtm_exposure_to_them) mtm_exposure_to_them,
			SUM(ced.exposure_to_us) exposure_to_us,
			SUM(ced.exposure_to_them) exposure_to_them,
			SUM(ced.total_exposure_to_us_round) total_exposure_to_us_round,
			SUM(ced.total_exposure_to_them_round) total_exposure_to_them_round,
			SUM(ced.effective_exposure_to_us) effective_exposure_to_us,
			SUM(ced.effective_exposure_to_them) effective_exposure_to_them,
			SUM(ced.d_effective_exposure_to_us) d_effective_exposure_to_us,
			SUM(ced.d_effective_exposure_to_them) d_effective_exposure_to_them,
			SUM(ced.effective_exposure_to_us_round) effective_exposure_to_us_round,
			SUM(ced.effective_exposure_to_them_round) effective_exposure_to_them_round,
			SUM(ced.collateral_received) collateral_received,
			SUM(ced.collateral_provided) collateral_provided,
			SUM(ced.cash_collateral_received) cash_collateral_received,
			SUM(ced.cash_collateral_provided) cash_collateral_provided,
			SUM(ced.colletral_not_used_received) colletral_not_used_received,
			SUM(ced.colletral_not_used_provided) colletral_not_used_provided,
			SUM(ced.prepay_received) prepay_received,
			SUM(ced.prepay_provided) prepay_provided,
			SUM(ced.limit_provided) limit_provided,
			SUM(ced.limit_received) limit_received,
			SUM(ced.limit_available_to_us) limit_available_to_us,
			SUM(ced.limit_available_to_them) limit_available_to_them,
			SUM(ced.limit_available_to_us_round) limit_available_to_us_round,
			SUM(ced.limit_available_to_them_round) limit_available_to_them_round,
			MAX(ced.rounding) rounding,
			SUM(ced.threshold_provided) threshold_provided,
			SUM(ced.threshold_received) threshold_received,
			SUM(ced.counterparty_credit_support_amount) counterparty_credit_support_amount,
			SUM(ced.internal_credit_support_amount) internal_credit_support_amount,
			dbo.FNADBUser(),
			GETDATE(),
			SUM(net_exposure_to_us) net_exposure_to_us,
			SUM(net_exposure_to_them) net_exposure_to_them,
			SUM(d_net_exposure_to_us) d_net_exposure_to_us,
			SUM(d_net_exposure_to_them) d_net_exposure_to_them,
			SUM(d_bom_exposure_to_us+other_bom_exposure_to_us) AS d_bom_exposure_to_us,	
			SUM(d_bom_exposure_to_them+other_bom_exposure_to_them) AS d_bom_exposure_to_them,
			SUM(d_mtm_exposure_to_us+other_mtm_exposure_to_us) AS d_mtm_exposure_to_us,	
			SUM(d_mtm_exposure_to_them+other_mtm_exposure_to_them) AS d_mtm_exposure_to_them,	
			SUM(d_exposure_to_us) AS d_exposure_to_us,	
			SUM(d_exposure_to_them) AS d_exposure_to_them,
			SUM(d_counterparty_credit_support_amt) AS d_counterparty_credit_support_amt,
			SUM(d_internal_credit_support_amt) AS d_internal_credit_support_amt,
			SUM(d_limit_available_to_us) AS d_limit_available_to_us,
			SUM(d_limit_available_to_them) AS d_limit_available_to_them,
			MAX(currency_name) AS currency_name
		FROM ' + @credit_detail_table + ' ced
		INNER JOIN #temp_CreditExposureDetail c ON c.source_counterparty_id = ced.source_counterparty_id
		WHERE ced.as_of_date = ''' + @as_of_date + ''''
		+ CASE WHEN @calc_type_rep = 'm' THEN ' AND ced.whatif_criteria_id = ' + CAST(ABS(@criteria_id) AS VARCHAR) ELSE '' END + '	
		GROUP BY ced.as_of_date, ced.curve_source_value_id, ced.Source_Counterparty_ID, ced.internal_counterparty_id, ced.contract_id'
		+ CASE WHEN @calc_type_rep = 'm' THEN ' ,ced.whatif_criteria_id' ELSE '' END
		
	--PRINT(@sqlSelect)
	EXEC(@sqlSelect)

	--Updating internal counterparty when it is not creturn from counterparty_contract_address
	--Real deals will be updated by using deals subsidiaries
	--(-1) deals will be updated by contract subsidiaries

	IF OBJECT_ID('tempdb..#tmp_internal_counterparty') IS NOT NULL 
	DROP TABLE #tmp_internal_counterparty

	CREATE TABLE #tmp_internal_counterparty(
		as_of_date DATETIME,
		source_counterparty_id INT,
		source_deal_header_id INT,
		internal_counterparty_id INT
	)
	--select distinct fs.counterparty_id
	EXEC('INSERT INTO #tmp_internal_counterparty
		SELECT DISTINCT ced.as_of_date, ced.source_counterparty_id, sdh.source_deal_header_id, fs.counterparty_id
		FROM source_deal_header sdh
		INNER JOIN ' + @CreditExposureDetail + ' ced ON ced.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = sdh.sub_book
		INNER JOIN #books b ON b.fas_book_id = ssbm.fas_book_id
		INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = b.fas_subsidiary_id
		WHERE ced.internal_counterparty_id IS NULL')

	--select cg.contract_id, cg.sub_id, fs.counterparty_id 
	EXEC('INSERT INTO #tmp_internal_counterparty 
		SELECT DISTINCT ced.as_of_date, ced.source_counterparty_id, ced.source_deal_header_id, fs.counterparty_id
		FROM contract_group cg
		INNER JOIN ' + @CreditExposureDetail + ' ced ON ced.contract_id = cg.contract_id
		INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = cg.sub_id
		WHERE ced.internal_counterparty_id IS NULL
			AND ced.source_deal_header_id = ''-1''')

	UPDATE ced SET ced.internal_counterparty_id = tic.internal_counterparty_id 
	FROM credit_exposure_detail ced
	INNER JOIN #tmp_internal_counterparty  tic ON tic.as_of_date = ced.as_of_date
		AND tic.source_counterparty_id = ced.source_counterparty_id
		AND tic.source_deal_header_id = ced.source_deal_header_id

	UPDATE ces SET ces.internal_counterparty_id = ced.internal_counterparty_id 
	FROM credit_exposure_summary ces
	INNER JOIN credit_exposure_detail ced ON ced.as_of_date = ces.as_of_date
		AND ced.source_counterparty_id = ces.source_counterparty_id
		AND ced.curve_source_value_id = ces.curve_source_value_id
		AND ISNULL(ces.contract_id, 0) = ISNULL(ced.contract_id, 0)
	INNER JOIN #tmp_internal_counterparty  tic ON tic.as_of_date = ced.as_of_date
		AND tic.source_counterparty_id = ced.source_counterparty_id
	WHERE ces.internal_counterparty_id IS NULL
	
--RETURN		
		IF @calc_type = 'w'
			RETURN
END
ELSE -- for PFE	
BEGIN

	

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************Process next netting filter for GROSS calculation*****************************'	
	END

	if OBJECT_ID('tempdb..#calcprocess_cpty') is not null 
		drop table #calcprocess_cpty 



	create table #calcprocess_cpty		(
		[Netting_Parent_Group_ID] [int] NOT NULL ,
		[Netting_Parent_Group_Name] [VARCHAR] (100) COLLATE DATABASE_DEFAULT NOT NULL ,
		[Netting_Group_ID] [int] NOT NULL ,
		[Netting_Group_Name] [VARCHAR] (100) COLLATE DATABASE_DEFAULT NOT NULL ,
		[Netting_Group_Detail_ID] [int] NOT NULL ,
		[Source_Counterparty_ID] [int] NULL,
		[term_start] [DATETIME] NULL ,
		[legal_entity] [int] NULL

		) 


	SET @sqlSelect = '
	INSERT INTO #calcprocess_cpty
	  (
		[Netting_Parent_Group_ID],
		[Netting_Parent_Group_Name],
		[Netting_Group_ID],
		[Netting_Group_Name],
		[Netting_Group_Detail_ID],
		[term_start],
		[legal_entity],[Source_Counterparty_ID]
	  )
	SELECT DISTINCT d.[Netting_Parent_Group_ID],
		   d.[Netting_Parent_Group_Name],
		   d.[Netting_Group_ID],
		   d.[Netting_Group_Name],
		   d.[Netting_Group_Detail_ID],
		   d.[term_start],
		   d.[legal_entity],d.[Source_Counterparty_ID]
	FROM ' + @NettingProcessTableOneName + ' d ' --where Source_Counterparty_ID=66
    
	--PRINT(@sqlSelect)
	EXEC(@sqlSelect)

	EXEC ('CREATE INDEX ind_aaaa_11 ON ' + @NettingProcessTableOneName + '(Source_Counterparty_ID,term_start  )')

	
	SET @sqlSelect = 'SELECT a.pnl_as_of_date,
		   sdh.counterparty_id,
		   a.term_start,
		   ISNULL( SUM(CASE WHEN sdh.is_environmental = ''y'' THEN cd.und_pnl ELSE 
		   		CASE WHEN DATEDIFF(m, a.run_date, a.term_start) <= CASE WHEN sdh.header_buy_sell_flag = ''b''  THEN '+@credit_physical_buy_mth+' ELSE '+@credit_physical_sell_mth +' END 
						THEN a.und_pnl_set
						ELSE isnull(b.Final_Und_Pnl,a.und_pnl)
					END END), 0) AS [Final_Und_Pnl],
		   CASE WHEN (ISNULL(SUM(isnull(b.Final_Und_Pnl,a.und_pnl)), 0) > 0) THEN 1 ELSE 2 END exp_type_id,
		   CASE WHEN (ISNULL(SUM(isnull(b.Final_Und_Pnl,a.und_pnl)), 0) > 0) THEN ''MTM+'' ELSE ''MTM-'' END exp_type,
		   a.source_deal_header_id
	INTO #tmp_pnl_simulation
	FROM ' + @table_name + '  a INNER JOIN ' + @deal_header_table + ' sdh ON  a.source_deal_header_id = sdh.source_deal_header_id
			AND a.leg = 1  AND a.run_date = ''' + @run_date + ''' AND a.pnl_source_value_id = ' + CAST(@curve_source_value_id AS VARCHAR(20))+ '
	left join ' +@NettingProcessTableOneName +' b on a.source_deal_header_id = b.source_deal_header_id
			and a.term_start=b.term_start
	GROUP BY a.pnl_as_of_date, sdh.counterparty_id, a.term_start,a.source_deal_header_id			
	
	CREATE INDEX indx_tmp_pnl_simulation_11 ON #tmp_pnl_simulation (counterparty_id , term_start)

	select d.[Netting_Parent_Group_ID], d.[Netting_Parent_Group_Name],     
			d.[Netting_Group_ID],d.[Netting_Group_Name],  
			d.[Netting_Group_Detail_ID], null [fas_subsidiary_id],null [fas_strategy_id] , null [fas_book_id],     
			cd.source_deal_header_id [Source_Deal_Header_ID],d.[Source_Counterparty_ID],d.[term_start],cd.[Final_Und_Pnl] [Final_Und_Pnl],     
			cd.[Final_Und_Pnl]  [Final_Dis_Pnl], --* isnull(df.discount_factor,1)
			d.[legal_entity],
			case when (isnull(cd.[Final_Und_Pnl], 0) > 0) then 1 else 2 end exp_type_id,
			case when (isnull(cd.[Final_Und_Pnl], 0) > 0) then ''MTM+'' else ''MTM-'' end exp_type,
			CAST(null as datetime) invoice_due_date, 
			cast(null as int) exposure_to_us, 
			cd.pnl_as_of_date  pnl_as_of_date  
		into ' + @NettingProcessTableCounterparty + '
	from  #calcprocess_cpty d 
	inner join #tmp_pnl_simulation cd on d.[Source_Counterparty_ID]=cd.counterparty_id and d.[term_start]=cd.term_start 
	 --LEFT OUTER JOIN ' +	@DiscountTableName + ' df 
		--on  df.term_start = d.term_start  and   df.fas_subsidiary_id = d.fas_subsidiary_id  
		'	
	--print(@sqlSelect)
	exec(@sqlSelect)
	
	EXEC('create index indx_NettingProcessTableCounterparty_11 on '+@NettingProcessTableCounterparty+' (pnl_as_of_date,netting_group_id, source_counterparty_id,term_start)')

	SET @sqlSelect = '
		insert into #exp_test
		select	ISNULL(pnl_as_of_date, ''' + @as_of_date + '''),netting_parent_group_id, netting_group_id, source_counterparty_id, 
				sum(Final_Und_Pnl) total_und_exposure, sum(Final_Dis_Pnl) total_dis_exposure,
				case when(sum(Final_Und_Pnl) > 0) then 1 else 0 end exposure_to_us, null, null
		from ' + @NettingProcessTableCounterparty + '
		where netting_group_id <> -1 
		group by pnl_as_of_date,netting_parent_group_id, netting_group_id, source_counterparty_id
		'

	EXEC (@sqlSelect)

	SET @pr_name= 'exp_test populated'
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
	PRINT GETDATE()

	SET @sqlSelect = '
		UPDATE a 
		SET a.exposure_to_us = et.exposure_to_us
		FROM
			' + @NettingProcessTableCounterparty + ' a
			INNER JOIN #exp_test et ON a.netting_parent_group_id = et.netting_parent_group_id
				AND a.netting_group_id = et.netting_group_id
				AND a.source_counterparty_id = et.source_counterparty_id and et.as_of_date=a.pnl_as_of_date'

	EXEC(@sqlSelect)



	SET @sqlSelect = '
		insert into #exp_test
		select	ISNULL(pnl_as_of_date, ''' + @as_of_date + '''),netting_parent_group_id, netting_group_id, source_counterparty_id, 
				sum(Final_Und_Pnl) total_und_exposure,
				sum(Final_Dis_Pnl) total_dis_exposure,
				exposure_to_us, null, null
		from (
		select	netting_parent_group_id, netting_group_id, source_counterparty_id, 
				cd.Final_Und_Pnl,  cd.Final_Dis_Pnl,
				CASE WHEN ((cd.Final_Und_Pnl > 0 AND cd.exp_type_id NOT IN (7, 8)) OR (cd.exp_type_id = 7)) THEN  1 ELSE 0 END exposure_to_us
				,cd.pnl_as_of_date
		from ' + @NettingProcessTableCounterparty + ' cd
		where netting_group_id = -1 
		) s 
		group by netting_parent_group_id, netting_group_id, source_counterparty_id, exposure_to_us,pnl_as_of_date
		'
	EXEC (@sqlSelect)


	SET @pr_name= 'exp_test 2 populated'
	SET @log_increment = @log_increment + 1
	SET @log_time=GETDATE()
	PRINT @pr_name+' Running..............'
	PRINT GETDATE()

	SET @sqlSelect = '
		UPDATE a SET a.exposure_to_us = CASE WHEN ((Final_Und_Pnl > 0 AND exp_type_id NOT IN (7, 8)) OR (exp_type_id = 7)) THEN  1 ELSE 0 END
			FROM ' + @NettingProcessTableCounterparty + ' a where netting_group_id = -1 '

	EXEC(@sqlSelect)

	IF @purge_all = 'y'
		delete  dbo.source_deal_pfe_simulation where run_date<=@as_of_date 
	else
	BEGIN
		IF @calc_type <> 'w'
		BEGIN
			SET @sqlSelect = 'delete s from  dbo.source_deal_pfe_simulation s 
				inner join ( select distinct Source_Counterparty_ID from ' + @NettingProcessTableCounterparty + ') cd 
					on s.Source_Counterparty_ID =cd.Source_Counterparty_ID 
					and run_date=''' +convert(varchar(10),@as_of_date ,120) +''' 
					and curve_source_value_id ='+CAST(@curve_source_value_id AS VARCHAR)
				 
			--PRINT(@sqlSelect)
			EXEC(@sqlSelect)
		END
		ELSE
			PRINT 'Do nothing delete for whatif'
		
	end
	
	SET @sqlSelect = 'insert into dbo.source_deal_pfe_simulation' + CASE WHEN @calc_type = 'w' THEN '_whatif' ELSE '' END + ' (
		run_date,as_of_date,curve_source_value_id,Netting_Parent_Group_ID,Netting_Parent_Group_Name,Netting_Group_ID,Netting_Group_Name,
		Netting_Group_Detail_ID,fas_subsidiary_id,fas_strategy_id,fas_book_id,Source_Deal_Header_ID,Source_Counterparty_ID,
		term_start,agg_term_start,Final_Und_Pnl,Final_Dis_Pnl,legal_entity,exp_type_id,exp_type,gross_exposure,d_gross_exposure,
		invoice_due_date,aged_invoice_days,netting_counterparty_id,counterparty_name,parent_counterparty_name,counterparty_type,
		risk_rating,debt_rating,industry_type1,industry_type2,sic_code,account_status,currency_name,watch_list,int_ext_flag,
		tenor_limit,tenor_days,total_limit_provided,total_limit_received,net_exposure_to_us,net_exposure_to_them,total_net_exposure,
		limit_to_us_avail,limit_to_them_avail,limit_to_us_violated,limit_to_them_violated,tenor_limit_violated,limit_to_us_variance,
		limit_to_them_variance,d_net_exposure_to_us,d_net_exposure_to_them,d_total_net_exposure,d_limit_to_us_avail,d_limit_to_them_avail,
		d_limit_to_us_variance,d_limit_to_them_variance,risk_rating_id,debt_rating_id,industry_type1_id,industry_type2_id,
		sic_code_id,counterparty_type_id
	)
		
	SELECT	 '''+CAST(@as_of_date AS VARCHAR) +''',cd.pnl_as_of_date,' + CAST(@curve_source_value_id AS VARCHAR) + ' curve_source_value_id,
		cd.Netting_Parent_Group_ID,cd.Netting_Parent_Group_Name,cd.Netting_Group_ID,cd.Netting_Group_Name,cd.Netting_Group_Detail_ID,
		cd.fas_subsidiary_id,cd.fas_strategy_id,cd.fas_book_id,cd.Source_Deal_Header_ID,cd.Source_Counterparty_ID,cd.term_start,
		CASE WHEN (cd.term_start between dbo.FNAGetContractMonth(''' + CAST(@as_of_date AS VARCHAR) + ''') AND dateadd(mm, 2, ''' + CAST(@as_of_date AS VARCHAR) + ''')) THEN dbo.FNADateFormat(cd.term_start)
			 WHEN (cd.term_start between dbo.FNAGetContractMonth(dateadd(mm, 3, ''' + CAST(@as_of_date AS VARCHAR) + ''')) AND dateadd(mm, 5, ''' + CAST(@as_of_date AS VARCHAR) + ''')) THEN dbo.FNADateFormat(dbo.FNAGetContractMonth(dateadd(mm, 3, ''' + CAST(@as_of_date AS VARCHAR)+ '''))) + '' (3Mths)''
			 WHEN (cd.term_start between dbo.FNAGetContractMonth(dateadd(mm, 6, ''' + CAST(@as_of_date AS VARCHAR) + ''')) AND dateadd(mm, 11, ''' + CAST(@as_of_date AS VARCHAR) + ''')) THEN dbo.FNADateFormat(dbo.FNAGetContractMonth(dateadd(mm, 6, ''' + CAST(@as_of_date AS VARCHAR) + '''))) + '' (6Mths)''
			 ELSE dbo.FNADateFormat(dbo.FNAGetContractMonth(dateadd(mm, 12, ''' + CAST(@as_of_date AS VARCHAR) + '''))) + '' (12Mths+)'' 
		END agg_term_start,cd.Final_Und_Pnl,cd.Final_Dis_Pnl,cd.legal_entity,cd.exp_type_id, LTRIM(RTRIM(cd.exp_type)) exp_type,
		CASE WHEN ((cd.Final_Und_Pnl > 0 AND cd.exp_type_id NOT IN (7, 8)) OR cd.exp_type_id = 7) THEN cd.Final_Und_Pnl ELSE 0 END gross_exposure,
		CASE WHEN ((cd.Final_Und_Pnl > 0 AND cd.exp_type_id NOT IN (7, 8)) OR cd.exp_type_id = 7) THEN cd.Final_Dis_Pnl ELSE 0 END d_gross_exposure,
		cd.invoice_due_date,datediff(dd, cd.invoice_due_date,''' +CAST(@as_of_date AS VARCHAR)+ ''') aged_invoice_days,
		cp.netting_counterparty_id,cp.counterparty_name,cp.parent_counterparty_name,cp.counterparty_type,cp.risk_rating,
		cp.debt_rating,cp.industry_type1,cp.industry_type2,cp.sic_code,cp.account_status,cp.currency_name,cp.watch_list,
		cp.int_ext_flag
		,null tenor_limit, null tenor_days, null total_limit_provided, null total_limit_received, 
		CASE WHEN cd.exposure_to_us=1 THEN cd.Final_Und_Pnl ELSE 0 END net_exposure_to_us, 
		CASE WHEN cd.exposure_to_us=0 THEN cd.Final_Und_Pnl ELSE 0 END net_exposure_to_them, 
		null total_net_exposure, null limit_to_us_avail, null limit_to_them_avail, null limit_to_us_violated, 
		null limit_to_them_violated, null tenor_limit_violated, null limit_to_us_variance, null limit_to_them_variance,
		CASE WHEN cd.exposure_to_us=1 THEN cd.Final_Dis_Pnl ELSE 0 END d_net_exposure_to_us, 
		CASE WHEN cd.exposure_to_us=0 THEN cd.Final_Dis_Pnl ELSE 0 END d_net_exposure_to_them, 
		null d_total_net_exposure, null d_limit_to_us_avail, null d_limit_to_them_avail, null d_limit_to_us_variance, 
		null d_limit_to_them_variance,
		cp.risk_rating_id,cp.debt_rating_id,cp.industry_type1_id,cp.industry_type2_id,
		cp.sic_code_id,cp.counterparty_type_id	
	FROM ' + @NettingProcessTableCounterparty + ' cd 
	--INNER JOIN #limit_check lc ON lc.netting_parent_group_id = cd.netting_parent_group_id 
	--	AND lc.source_counterparty_id = cd.source_counterparty_id and cd.pnl_as_of_date=lc.as_of_date
	INNER JOIN #cpty cp ON cp.source_counterparty_id = cd.source_counterparty_id
	ORDER BY cd.pnl_as_of_date'

	--PRINT(@sqlSelect)
	EXEC(@sqlSelect)
	
	EXEC ('INSERT INTO #count_counterparty select distinct source_counterparty_id as count_cpt from '+ @NettingProcessTableCounterparty)
END
IF ISNULL(@simulation, 'n') = 'n' AND @trigger_workflow = 'y'--If not from PFE
BEGIN
    DECLARE @process_table VARCHAR(500)
	DECLARE @sql_st VARCHAR(MAX)
	DECLARE @alert_process_id VARCHAR(200)
	SET @alert_process_id = dbo.FNAGetNewID()  
	SET @process_table = 'adiha_process.dbo.alert_credit_exposure_' + @alert_process_id + '_ace'
	PRINT @as_of_date
	SET @sql_st = 'CREATE TABLE ' + @process_table + '
		 (
     		counterparty_id    INT,
     		counterparty_name  VARCHAR(200),
     		as_of_date VARCHAR(30),
     		fas_subsidiary_id VARCHAR(2000),
			contract_id INT,
			internal_counterparty_id INT,
     		hyperlink1 VARCHAR(5000), 
     		hyperlink2 VARCHAR(5000), 
     		hyperlink3 VARCHAR(5000), 
     		hyperlink4 VARCHAR(5000), 
     		hyperlink5 VARCHAR(5000)
		 )
		INSERT INTO ' + @process_table + '(
			counterparty_id,
			counterparty_name,
			as_of_date,
			fas_subsidiary_id,
			contract_id,
			internal_counterparty_id
		  )
		SELECT DISTINCT cd.Source_Counterparty_ID, cp.counterparty_name,''' + isnull(@as_of_date,'NULL') + ''', fas_subsidiary_id
			, cd.contract_id
			, ISNULL(cd.internal_counterparty_id, lc.internal_counterparty_id)
		FROM   ' + @NettingProcessTableOneName + ' cd
		INNER JOIN #limit_check lc
            ON  ISNULL(lc.netting_parent_group_id, -1) = ISNULL(cd.netting_parent_group_id, -1)
            AND lc.source_counterparty_id = cd.source_counterparty_id
		INNER JOIN #cpty cp ON  cp.source_counterparty_id = cd.source_counterparty_id

		DELETE temp FROM ' + @process_table + ' temp
		INNER JOIN counterparty_contract_address cca
			ON cca.counterparty_id = temp.counterparty_id
				AND cca.contract_id = temp.contract_id
				AND ISNULL(cca.internal_counterparty_id, temp.internal_counterparty_id) = temp.internal_counterparty_id
		WHERE cca.margin_provision IS NULL
			'

	EXEC(@sql_st)
	--PRINT(ISNULL(@sql_st, 'is null'))	
	
	EXEC ('INSERT INTO #count_counterparty select distinct source_counterparty_id as count_cpt from '+ @NettingProcessTableOneName)
END

If @@ERROR <> 0
BEGIN
	--**ERROR**
	INSERT INTO #calc_status
		Select @batch_process_id,'Error','Calc Credit exposure','Run Credit exposure','Application Error',
		'No Counterparty found to process for Credit exposure calculation','Please contact technical support'
		GOTO FinalStep
		RETURN
End

DECLARE @chk VARCHAR(8000)

--Setting up @total_simulations = 0 when no data found for any counterparty
IF NOT EXISTS(SELECT * FROM #count_counterparty)
	SET @total_simulations = 0
--select @chk = count(count_cpt) from #count_counterparty
 --IF (@chk = 0)
--BEGIN
--SELECT @chk=COALESCE(@chk + ',','')+counterparty_name
--	FROM #cpty c LEFT join   #count_counterparty cc ON c.source_counterparty_id = cc.count_cpt WHERE cc.count_cpt IS NULL
--IF @chk IS NOT NULL
--BEGIN
--	INSERT INTO #calc_status
--SELECT @batch_process_id,
--   'Warning',
--   'Calc Credit exposure',
--   'Run Credit exposure',
--   'Warning',
--   'No Counterparty found to process for Credit exposure calculation' + @chk +  'Total  Countrparty processed count (0).',
--   'Please check your input.'
--END	

	
	
	--GOTO FinalStep
---Return
--End



--	set @sqlSelect='
--
--		UPDATE a
--			   SET 
--					net_exposure_to_us=CASE WHEN b.source_counterparty_id IS NOT NULL THEN a.Final_Und_Pnl ELSE 0 END,
--					d_net_exposure_to_us=CASE WHEN b.source_counterparty_id IS NOT NULL THEN a.Final_Dis_Pnl ELSE 0 END
--		FROM 
--				credit_exposure_detail a
--				inner JOIN 	
--				(select 
--						source_counterparty_id,
--						Netting_Group_ID
--				FROM
--						'+@NettingProcessTableOneName+'	
--				WHERE
--						Netting_Group_ID<>-1
--				GROUP BY 
--						source_counterparty_id,Netting_Group_ID
--				HAVING 	SUM(Final_Und_Pnl)>0
--			) b
--			ON a.source_counterparty_id=b.source_counterparty_id
--			AND a.Netting_Group_ID=b.Netting_Group_ID	'
--
--	EXEC(@sqlSelect)
--	--print @sqlSelect
--
--
--		UPDATE a
--			   SET 
--					net_exposure_to_us=a.Final_Und_Pnl,
--					d_net_exposure_to_us=a.Final_Dis_Pnl
--		FROM 
--				credit_exposure_detail a
--		WHERE
--			Netting_Group_ID=-1	
--			AND Final_Und_Pnl>0
--		
--
--	SET @sqlSelect='
--
--		UPDATE a
--			   SET 
--					net_exposure_to_them=CASE WHEN b.source_counterparty_id IS NOT NULL THEN a.Final_Und_Pnl ELSE 0 END,
--					total_net_exposure=net_exposure_to_us+CASE WHEN b.source_counterparty_id IS NOT NULL THEN a.Final_Und_Pnl ELSE 0 END,
--					d_net_exposure_to_them=CASE WHEN b.source_counterparty_id IS NOT NULL THEN a.Final_Dis_Pnl ELSE 0 END,
--					d_total_net_exposure=d_net_exposure_to_us+CASE WHEN b.source_counterparty_id IS NOT NULL THEN a.Final_Dis_Pnl ELSE 0 END
--		FROM 
--				credit_exposure_detail a
--				inner JOIN 	
--				(select 
--						source_counterparty_id,
--						Netting_Group_ID
--				FROM
--						'+@NettingProcessTableOneName+'	
--				WHERE
--						Netting_Group_ID<>-1
--				GROUP BY 
--						source_counterparty_id,Netting_Group_ID
--				HAVING 	SUM(Final_Und_Pnl)<0
--			) b
--			ON a.source_counterparty_id=b.source_counterparty_id
--			AND a.Netting_Group_ID=b.Netting_Group_ID	'
--			
--			PRINT (@sqlSelect)
--			
--	EXEC(@sqlSelect)			
--	
--
--		UPDATE a
--			   SET 
--					net_exposure_to_them=a.Final_Und_Pnl,
--					total_net_exposure=net_exposure_to_us+a.Final_Und_Pnl,
--					d_net_exposure_to_them=a.Final_Dis_Pnl,
--					d_total_net_exposure=d_net_exposure_to_us+a.Final_Dis_Pnl
--		FROM 
--				credit_exposure_detail a
--	 WHERE
--						Netting_Group_ID=-1
--						AND Final_Und_Pnl<0
	---################## Publish the compliance activity when there is a credit voilation for counterparty.
	/*
	IF	(SELECT MAX(limit_to_us_violated) FROM #limit_check)=1 
		BEGIN

			SET @risk_control_id=89
			SELECT @message=CASE WHEN MAX(limit_to_us_violated)=1  THEN 'Credit limit violated' ELSE 'Tenor limit violated' END +' for some Counterparties' FROM #limit_check
			SET @message=@message+'<a target="_blank" href="dev/spa_html.php?spa=exec spa_get_counterparty_exposure_report ''e'',''s'',''c'','''+@as_of_date+''','''+CAST(ISNULL(@sub_entity_id,'NULL') AS VARCHAR)+''',NULL,NULL,NULL,NULL,NULL,NULL,e,NULL,NULL,NULL,NULL,NULL,''n'',''y'',NULL,''n'',''s'',1,''n'',4500,1,''u'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL&__user_name__='+@user_login_id+'">' + 
			' Click here to view detail...' +'</a>'
			
--			SET @sqlSelect =' EXEC spa_complete_compliance_activities ''a'',NULL,'''+cast(getdate() AS VARCHAR)+''',''<>'','+CAST(@risk_control_id AS VARCHAR)+',NULL,NULL,'''+@message+''',''v'''
			--print @message
--			EXEC(@sqlSelect)
			
			EXEC  spa_message_board 'i', @user_login_id, NULL, 'Credit Exposure',  @message, '', '', 'e', ''


		END

*/

	--select * from credit_exposure_detail order by netting_parent_group_id

DECLARE @count_fail int
DECLARE @count_fail1 int
DECLARE @count_warning int
DECLARE @count_total INT
DECLARE @original_process_id VARCHAR(100)
SET @original_process_id=@batch_process_id
set @count_fail = 0
set @count_warning = 0
set @count_total = 0

if @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

--error 
--select @count_fail = count(DISTINCT c.source_counterparty_id) from #cpty c LEFT join   #count_counterparty cc ON c.source_counterparty_id = cc.count_cpt WHERE cc.count_cpt IS NULL
print @count_fail
If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '****************Count of total failed Countryparty*****************************'	
END


If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

--warning
select @count_warning = count(c.source_counterparty_id) from #cpty c LEFT join   #count_counterparty cc ON c.source_counterparty_id = cc.count_cpt WHERE cc.count_cpt IS NULL
PRINT @count_warning

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '****************Count of total warning Countryparty*****************************'	  
END


If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

--total

SELECT @count_total  = count(DISTINCT c.source_counterparty_id) from #cpty c
PRINT @count_total
If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '****************Count of total total Countryparty processed*****************************'	
END
SET @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

set @desc = CASE WHEN ISNULL(@simulation, 'n') = 'y' THEN '(' + CAST(ISNULL(@total_simulations, 0) AS VARCHAR)+ ') Credit Exposure simulation(s)' ELSE 'Credit exposure calculation' END + ' completed for run date: '+ isnull(dbo.FNADateFormat(@as_of_date), @as_of_date) +
	'  <b> Total Counterparty Processed</b>: (' + cast(@count_total as varchar) + ')  <b>Error Count</b>: (' +
	 cast(@count_fail as varchar)  + ') <b>Warning Count</b>: (' + cast(@count_warning as varchar) + ').'
--PRINT @desc
IF (@count_fail = 0 AND  @count_warning <> 0)
BEGIN
	SELECT @chk = COALESCE(@chk + ', ','')+ c.counterparty_name 
	FROM #cpty c LEFT join   #count_counterparty cc ON c.source_counterparty_id = cc.count_cpt WHERE cc.count_cpt IS NULL
	IF @chk IS NOT NULL
	BEGIN
		INSERT INTO #calc_status
			SELECT @batch_process_id,
		   'Warning',
		   CASE WHEN ISNULL(@simulation, 'n') = 'y' THEN 'Credit Exposure Simulation' ELSE 'Calc Credit Exposure' END,
		   CASE WHEN ISNULL(@simulation, 'n') = 'y' THEN 'Run Credit Exposure Simulation'ELSE 'Run Credit Exposure' END,
		   'Warning',
		   'No data found to process for Counterparty(s) ' + @chk + '.',
		   'Please check your input.'
	END
END


insert into #calc_status values(@batch_process_id, case when @count_fail  = 0 then 'Success' else 'Error' end, CASE WHEN ISNULL(@simulation, 'n') = 'y' THEN 'Credit Exposure Simulation' ELSE 'Credit Exposure Calc' END, CASE WHEN ISNULL(@simulation, 'n') = 'y' THEN 'Run Credit Exposure Simulation' ELSE 'Run Credit Exposure' END, 'Results', --'Successful',
	@desc,'')

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '****************	INSERT INTO FINAL MESSAGE IN #calc_status *****************************'	
END

FinalStep:
DECLARE @e_count varchar(50)
set @e_time = datediff(ss,@begin_time,getdate())
set @e_time_text = cast(cast(@e_time/60 as int) as varchar) + ' Mins ' + cast(@e_time - cast(@e_time/60 as int) * 60 as varchar) + ' Secs'

		If @print_diagnostic = 1
		begin
			set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
			set @log_increment = @log_increment + 1
			set @log_time=getdate()
			print @pr_name+' Running..............'
		end
		insert into credit_exposure_calculation_log(process_id,code,module,source,type,[description],nextsteps)  
		select * from #calc_status --where process_id=@batch_process_id
	
		SET @url_desc = 'Detail...'
		SET @url = './dev/spa_html.php?__user_name__=' + @user_name +'&spa=exec spa_credit_exposure_calculation_log '+ @batch_process_id + ''''
		
		SELECT  @error_count =   COUNT(*) 
		FROM        credit_exposure_calculation_log
		WHERE     process_id = @batch_process_id  AND code = 'Error' 
		SELECT  @e_count =   Code
		FROM        credit_exposure_calculation_log
		WHERE     process_id = @batch_process_id AND code = 'Warning' 
		
			--SELECT  @error_count =  COUNT(*) FROM credit_exposure_detail  WHERE as_of_date = @as_of_date --counterparty_limit_calc_result
		IF @error_count > 0
			SET @type = 'e'
		ELSE 
			SET @type = 's'
		IF 	@e_count ='Warning'
			SET @type = 'w'
		SET @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_credit_exposure_calculation_log ''' + @batch_process_id + ''''	
		SET @desc = '<a target="_blank" href="' + @url + '">' + 
				 'Credit exposure ' + CASE WHEN ISNULL(@simulation,'n')='y' THEN 'simulation(s)' ELSE 'calculation' END + ' completed for run date ' + isnull(dbo.FNADateFormat(@as_of_date), @as_of_date) + 
				case when (@type = 'e') then ' with errors.' when (@type = 'w') then ' with warnings.' else '' end +
				' [Elapse time: ' + @e_time_text +']' + 
				'.</a>'
		--PRINT @desc
		IF ISNULL(@show_message_in_message_board,'y')='y'
			EXEC  spa_message_board 'i', @user_login_id, NULL, @msg_desc,  @desc, '', '', @type, '',NULL,@batch_process_id
	
	IF @print_diagnostic = 1
	BEGIN
		SET @log_increment = 1
		PRINT  @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		PRINT '********************END &&&&&&&&&[spa_Calc_Netting_Measurement]**********'
	END
	IF ISNULL(@simulation, 'n') = 'n' AND @count_total > (@count_fail+@count_warning) AND @trigger_workflow = 'y' --If not from PFE
		EXEC spa_register_event 20623, 20508, @process_table, 0, @alert_process_id
	
	SET @e_time = datediff(ss,@begin_time,getdate())
	SET @e_time_text = cast(cast(@e_time/60 as int) as varchar) + ' Mins ' + cast(@e_time - cast(@e_time/60 as int) * 60 as varchar) + ' Secs'
	SET @desc = 'Credit exposure calculation completed for run date ' + dbo.FNADateFormat(@as_of_date) + ' with warnings. [Elapse time: '+@e_time_text+'].'
	
	IF OBJECT_ID('tempdb..#tmp_result_credit_exposer') IS NOT NULL 
	BEGIN
		INSERT INTO #tmp_result_credit_exposer (ErrorCode, Module, Area, Status, Message, Recommendation)  
		SELECT 'Success', 'Calc Credit Netting Exposure', 'spa_Calc_Credit_Netting_Exposure', 'Success', @desc, ''
	END
	ELSE
	EXEC spa_ErrorHandler 0,
			'Calc Credit Netting Exposure',
			'spa_Calc_Credit_Netting_Exposure',
			'Success',
			@desc,
			''		
END TRY
BEGIN CATCH

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=GETDATE()
		PRINT @pr_name+' Running..............'
	END

	SET @desc =  'Error Found in Catch: ' + ERROR_MESSAGE()
	declare @module varchar(100)
	set @module = 'Calculation credit exposure'

	SET @url = './dev/spa_html.php?__user_name__=' + dbo.FNADBUser() + '&spa=spa_credit_exposure_calculation_log '''+ @batch_process_id + ''''
		
	SET @desc = '<a target="_blank" href="' + @url + '">' + @module + 
				' did not complete for run date ' + isnull(dbo.FNADateFormat(@as_of_date), @as_of_date) + 
				' (ERRORS found: ' + @desc + ')'  +
				'.</a>'
	insert into credit_exposure_calculation_log(process_id,code,module,source,type,[description],nextsteps)  
	select * from #calc_status where process_id=@batch_process_id

	--select @user_name 
	insert into credit_exposure_calculation_log(process_id,code,module,source,type,[description],nextsteps) 
	SELECT @batch_process_id,'Error','Counterparty Exposure Calc',@module,@module,
				'SQL Error found: '''  + isnull(dbo.FNADateFormat(@as_of_date), @as_of_date) + ''' (' + ERROR_MESSAGE() + ')' +
				' [Elapse time: ' + @e_time_text + ']' as status_description, 
				'Please contact technical support'
	EXEC  spa_message_board 'i', @user_login_id, NULL, 'Calc Counterparty Exposure',  @desc, '', '', 'e', '',NULL,@batch_process_id

	--select * from source_deal_pnl_Detail

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************END OF LOGIC: Error Found in Catch*****************************'	
	END	

	IF OBJECT_ID('tempdb..#tmp_result_credit_exposer') IS NOT NULL 
	BEGIN
		INSERT INTO #tmp_result_credit_exposer (ErrorCode, Module, Area, Status, Message, Recommendation)  
		SELECT 'Error', 'Calc Credit Netting Exposure', 'spa_Calc_Credit_Netting_Exposure', 'Technical Error', 'Calc Credit Netting Exposure Fail', ''
	END
	ELSE
	EXEC spa_ErrorHandler -1,
		'Calc Credit Netting Exposure',
		'spa_Calc_Credit_Netting_Exposure',
		'Technical Error',
		'Calc Credit Netting Exposure Fail',
		''	
END CATCH
