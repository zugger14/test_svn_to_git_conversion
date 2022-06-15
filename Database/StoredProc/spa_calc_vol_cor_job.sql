

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Calculate Volatility, Correlation and Expected Return

	Parameters :
	@as_of_date : Date for processing
    @price_curve_source : Source to take price
    @var_criteria_id : Criteria ID to process the calculation
    @process_id : To run calculation using provided process id
    @term_start : Term Start filter to process
    @term_end : Term End filter to process
    @daily_return_data_series :
    @data_points : Number to take most recent dates for calculation
    @what_if : Call from WhatIf 'y' - Yes	'n' - No
    @calc_only_vol_cor : 'n' - call from VaR Calculation; 
						'y' - call from drift/vol/cor calculation UI (not from  VaR Calculation)
    @calc_option : Calculation Option  
					'a' - all 
					'd' - drift 
					'v- - volatility 
					'c' - correlation
    @curve_ids1 : Curve Ids filter to process
    @whatif_criteria_id : Whatif Criteria ID to process the calculation
    @calc_type : Calculation Type 'w' - whatif    'r' - not whatif
    @tbl_name : Provide table which holds deals to process
	@measurement_approach : Approach to use in the calculation as defined in the static data
								1520 - Variance/Covariance Approach
	@conf_interval : Percentage for the calculation as defined in the static data
						1502 - 99%, 1503 - 90%, 1504 - 95%
	@hold_period : Integer value to multiply processed value using square root
	@volatility_source : Source of the volatility to be taken
	@calculate_for_same_term : Calculatin for same term 'y' - Yes	'n' - No
    @batch_process_id : Process id when run through batch
    @batch_report_param : Paramater to run through batch

**/
IF OBJECT_ID(N'[dbo].[spa_calc_vol_cor_job]') IS NOT NULL 
    DROP PROCEDURE [dbo].[spa_calc_vol_cor_job]
GO
CREATE PROC [dbo].[spa_calc_vol_cor_job]
    @as_of_date DATETIME,
    @price_curve_source INT = 4500,
    @var_criteria_id INT = NULL,
    @process_id VARCHAR(50) = NULL,
    @curve_ids VARCHAR(1000) = NULL,
    @term_start VARCHAR(30) = NULL,
    @term_end VARCHAR(30) = NULL,
    @daily_return_data_series INT = 1562,
    @data_points INT = 30,
    @what_if VARCHAR(1) = 'n',
    @calc_only_vol_cor VARCHAR(1) = 'n',
    @calc_option VARCHAR(1) = 'a',
    @curve_ids1 VARCHAR(1000) = NULL,
    @whatif_criteria_id INT = NULL,
    @calc_type VARCHAR(1) = 'r',
    @tbl_name VARCHAR(200) = NULL,
	@measurement_approach INT = NULL,
	@conf_interval INT = NULL,
	@hold_period INT = NULL,
	@volatility_source INT = NULL,
	@calculate_for_same_term CHAR(1) = 'n',

	@return_output BIT = 1,
    @batch_process_id VARCHAR(50) = NULL,
    @batch_report_param VARCHAR(1000) = NULL
AS 

/*
	--exec [dbo].[spa_calc_vol_cor_job] '2012-04-12',4500,	NULL,	'ADEF5369_AB70_49BD_8C67_B51FCAC2D403',	105	
	--,'2013-01-01','2013-03-01',1562,	100	,'n','y','d',NULL,NULL,'r',NULL,NULL,NULL,NULL		 
--SELECT * FROM fas_eff_ass_test_run_log WHERE process_id='vvv'

declare @as_of_date DATETIME,
    @price_curve_source INT ,
    @var_criteria_id INT ,
    @process_id VARCHAR(50) ,
    @curve_ids VARCHAR(1000) ,--90, 105, 106, 138.
    @term_start VARCHAR(30) , --'2013-01-01',
    @term_end VARCHAR(30) ,
    @daily_return_data_series INT ,
    @data_points TINYINT ,
    @what_if VARCHAR(1) ,
    @calc_only_vol_cor VARCHAR(1) , --n: call from VaR Calculation; y=call from drift/vol/cor calculation UI (not from  VaR Calculation)
    @calc_option VARCHAR(1) , -- calculation d=drift v=volatility c=correlation
    @curve_ids1 VARCHAR(1000) ,
    @whatif_criteria_id INT ,
    @calc_type VARCHAR(1) , ---w= whatif    r=not whatif
    @tbl_name VARCHAR(200) ,
	@measurement_approach INT ,
	@conf_interval INT,
	@hold_period INT ,@volatility_source INT,
    @batch_process_id VARCHAR(50),
    @batch_report_param VARCHAR(1000),
	@calculate_for_same_term CHAR(1) = 'y'  --,@calc_only_vol_cor varchar(1)='y',@process_id VARCHAR(50) =null

--SELECT * FROM fas_eff_ass_test_run_log WHERE process_id='fgh'
--SELECT * FROM source_price_curve_def where source_curve_def_id in (19,28)
--
--SELECT * FROM source_price_curve where source_curve_def_id in (19,28) and year(As_of_Date)=2011  order by source_curve_def_id,As_of_Date desc,Maturity_Date



SELECT @as_of_date ='2013-12-19',
    @price_curve_source  = 4500,
    @var_criteria_id  = null,
    @process_id  = null,
    @curve_ids = 2420,--90, 105, 106, 138.
    @term_start  ='2013-12-01', --'2013-01-01',
    @term_end  = '2014-12-31',
    @daily_return_data_series  = 1563, --select * from static_data_value where type_id = 1560
    @data_points  = 250,
    @what_if  = 'n',
    @calc_only_vol_cor  = 'y', --n: call from VaR Calculation; y=call from drift/vol/cor calculation UI (not from  VaR Calculation)
    @calc_option  = 'a', -- calculation d=drift v=volatility c=correlation
    @curve_ids1  = 2417,
    @whatif_criteria_id  = NULL,
    @calc_type  = null, ---w= whatif    r=not whatif
    @tbl_name  = NULL,
	@measurement_approach  = NULL,
	@conf_interval  = NULL,
	@hold_period  = NULL,@volatility_source  = NULL
    ,@batch_process_id = NULL,
    @batch_report_param  = NULL --,@calc_only_vol_cor varchar(1)='y',@process_id VARCHAR(50) =null

DROP TABLE #tmp_err1
DROP TABLE #tmp_data
DROP TABLE #as_of_date_point
DROP TABLE #curve_matrix
DROP TABLE #return_matrix
DROP TABLE #tmp_term
DROP TABLE #tmp_cor
DROP TABLE #tmp_book
DROP TABLE #tmp_risk
DROP TABLE #term_correlation
DROP TABLE #tmp_volatility_taken
DROP TABLE #tmp_vol_not_found
DROP TABLE #curve_matrix_vol
DROP TABLE #return_matrix_vol
--*/
--  SELECT * FROM fas_eff_ass_test_run_log WHERE process_id='zzzz'

IF OBJECT_ID('tempdb..#tmp_err1') IS NOT NULL
	DROP TABLE #tmp_err1

IF OBJECT_ID('tempdb..#tmp_data') IS NOT NULL
	DROP TABLE #tmp_data

IF OBJECT_ID('tempdb..#as_of_date_point') IS NOT NULL
	DROP TABLE #as_of_date_point

IF OBJECT_ID('tempdb..#curve_matrix') IS NOT NULL
	DROP TABLE #curve_matrix

IF OBJECT_ID('tempdb..#return_matrix') IS NOT NULL
	DROP TABLE #return_matrix

IF OBJECT_ID('tempdb..#tmp_term') IS NOT NULL
	DROP TABLE #tmp_term

IF OBJECT_ID('tempdb..#tmp_curve_deal') IS NOT NULL
	DROP TABLE #tmp_curve_deal

IF OBJECT_ID('tempdb..#tmp_cor') IS NOT NULL
	DROP TABLE #tmp_cor

--IF OBJECT_ID('tempdb..#tmp_book') IS NOT NULL
--DROP TABLE #tmp_book

IF OBJECT_ID('tempdb..#tmp_risk') IS NOT NULL
	DROP TABLE #tmp_risk

IF OBJECT_ID('tempdb..#term_correlation') IS NOT NULL
	DROP TABLE #term_correlation


IF OBJECT_ID('tempdb..#max_maturity_price_exist') IS NOT NULL
	DROP TABLE #max_maturity_price_exist	

--Shift value enhancement tables
--IF OBJECT_ID('tempdb..#data_shift') IS NOT NULL
--	DROP TABLE #data_shift

--IF OBJECT_ID('tempdb..#ranked_data') IS NOT NULL
--	DROP TABLE #ranked_data
	
--IF OBJECT_ID('tempdb..#data_shift') IS NOT NULL
--	DROP TABLE #data_shift_vol

--IF OBJECT_ID('tempdb..#ranked_data') IS NOT NULL
--	DROP TABLE #ranked_data_vol	

IF OBJECT_ID('tempdb..#curve_ids') IS NOT NULL
	DROP TABLE #curve_ids
	CREATE TABLE #curve_ids(curve_id INT)
--Used in volatility enhancement
IF OBJECT_ID('tempdb..#tmp_volatility_taken') IS NOT NULL
	DROP TABLE #tmp_volatility_taken
CREATE TABLE #tmp_volatility_taken(curve_id INT, term_start DATETIME, vol_value FLOAT, volatility_method CHAR(1) COLLATE DATABASE_DEFAULT )

IF OBJECT_ID('tempdb..#tmp_vol_not_found') IS NOT NULL
	DROP TABLE #tmp_vol_not_found	
CREATE TABLE #tmp_vol_not_found(curve_id INT, term_start DATETIME)
	
IF OBJECT_ID('tempdb..#curve_matrix_vol') IS NOT NULL
	DROP TABLE #curve_matrix_vol
CREATE TABLE #curve_matrix_vol(curve_id INT, term_start DATETIME, Row_id INT, as_of_date DATETIME, curve_value FLOAT, data_series INT)

IF OBJECT_ID('tempdb..#return_matrix_vol') IS NOT NULL
	DROP TABLE #return_matrix_vol
CREATE TABLE #return_matrix_vol(curve_id INT, term_start DATETIME, Row_id INT, as_of_date DATETIME, MATRIX_Value FLOAT, MATRIX_Mean FLOAT)	
		
IF OBJECT_ID('tempdb..#valid_aod_for_shifting') IS NOT NULL
	DROP TABLE #valid_aod_for_shifting


IF OBJECT_ID('tempdb..#aod_ignor_status_for_shifting') IS NOT NULL
	DROP TABLE #aod_ignor_status_for_shifting
--Used in hold to maturity
IF OBJECT_ID('tempdb..#mtm_process_table_new') IS NOT NULL
	DROP TABLE #mtm_process_table_new
CREATE TABLE #mtm_process_table_new(curve_id INT, term_start DATETIME, MTM FLOAT, MTMC FLOAT, MTMI FLOAT, data_series INT, currency_id INT, is_mapped INT, term_end DATETIME, risk_bucket_map INT, map_term_start DATETIME)

--Tables used in shift value enhancement
--CREATE TABLE #data_shift(
--	id			INT IDENTITY(1,1),
--	curve_id    INT,
--	term_start  DATETIME,
--	Row_id      INT,
--	as_of_date  DATETIME,
--	curve_value FLOAT,
--	data_series INT
--)
--CREATE TABLE #ranked_data(
--	curve_id    INT,
--	term_start  DATETIME,
--	Row_id      INT,
--	as_of_date  DATETIME,
--	curve_value FLOAT,
--	data_series INT
--)
--End shift value enhancement

IF @calc_option IN ('v', 'd')
	SET @curve_ids1 = NULL
	
DECLARE @user_name	VARCHAR(50)
DECLARE @url        VARCHAR(500)
DECLARE @desc       VARCHAR(500)
DECLARE @errorMsg   VARCHAR(200)
DECLARE @errorcode  VARCHAR(1)
DECLARE @url_desc   VARCHAR(500)
DECLARE @max_sno_maturity INT

SET @user_name = DBO.FNADBUser()
SET @url = ''
SET @desc = ''
SET @errorMsg = ''
SET @errorcode = 'e'
SET @url_desc = ''

IF @process_id IS NULL
    SET @process_id = REPLACE(NEWID(), '-', '_')

DECLARE @month_1st_date       DATETIME
DECLARE @st_where             VARCHAR(2000)
DECLARE @st_hypo			  VARCHAR(2000)  --to address hypothetical deals in #tmp_term
--DECLARE @st_where_book        VARCHAR(2000)
--Shift Enhancement Variables
DECLARE @relative_volatility CHAR(1) = 'n', @term_exist CHAR(1) = 'n'

DECLARE @VolProcessTableName  VARCHAR(200)
DECLARE @CorProcessTableName  VARCHAR(200)
DECLARE @MTMProcessTableName  VARCHAR(200)
DECLARE @MTMProcessTableNameNew  VARCHAR(200)
DECLARE @DriftProcessTableName VARCHAR(200)
DECLARE @MTMVolProcessTableName  VARCHAR(200) --For volatility calculation
DECLARE @std_deal_table	VARCHAR(250)
DECLARE @term_freq VARCHAR(250)
DECLARE @vol_cor_header_id INT
DECLARE @risk_id VARCHAR(1000), @risk_id1 VARCHAR(1000)
DECLARE @error_count INT = 0

DECLARE @criteria_name VARCHAR(250)
IF @whatif_criteria_id IS NOT NULL
	 SELECT @criteria_name = criteria_name FROM maintain_whatif_criteria mwc WHERE mwc.criteria_id = @whatif_criteria_id
ELSE SET @criteria_name = ''


SET @VolProcessTableName = dbo.FNAProcessTableName('Volatility', @user_name, @process_id)
SET @CorProcessTableName = dbo.FNAProcessTableName('Correlation', @user_name, @process_id)
SET @MTMProcessTableName = dbo.FNAProcessTableName('MTM', @user_name, @process_id)
SET @MTMProcessTableNameNew = dbo.FNAProcessTableName('MTM_new', @user_name, @process_id)
SET @MTMVolProcessTableName = dbo.FNAProcessTableName('MTMVol', @user_name, @process_id)
SET @DriftProcessTableName = dbo.FNAProcessTableName('Drift', @user_name, @process_id)
SET @std_deal_table = dbo.FNAProcessTableName('std_deals', @user_name, @process_id)
SET @term_start = NULLIF(@term_start,'')
SET @term_end = NULLIF(@term_end,'')

IF OBJECT_ID(@CorProcessTableName) IS NOT NULL EXEC ('DROP TABLE ' + @CorProcessTableName)
IF OBJECT_ID(@VolProcessTableName) IS NOT NULL EXEC ('DROP TABLE ' + @VolProcessTableName)
IF OBJECT_ID(@MTMProcessTableName) IS NOT NULL EXEC ('DROP TABLE ' + @MTMProcessTableName)
IF OBJECT_ID(@MTMProcessTableNameNew) IS NOT NULL EXEC ('DROP TABLE ' + @MTMProcessTableNameNew)
IF OBJECT_ID(@MTMVolProcessTableName) IS NOT NULL EXEC ('DROP TABLE ' + @MTMVolProcessTableName)
IF OBJECT_ID(@DriftProcessTableName) IS NOT NULL EXEC ('DROP TABLE ' + @DriftProcessTableName)
IF OBJECT_ID(@std_deal_table) IS NOT NULL EXEC ('DROP TABLE ' + @std_deal_table)

	
EXEC ('CREATE TABLE ' + @CorProcessTableName + ' (X_curve_id INT, Y_curve_id INT, X_term_start DATETIME, Y_term_start DATETIME, Cor_value FLOAT, Cor_value_shift FLOAT)'    )--updated for risk bucket mapping logic
EXEC ('CREATE TABLE ' + @VolProcessTableName + ' (curve_id INT, term_start DATETIME, STDEV_Value FLOAT, STDEV_Value_shift FLOAT)')--updated for risk bucket mapping logic
EXEC ('CREATE TABLE ' + @MTMProcessTableName + ' (curve_id INT, term_start DATETIME, MTM FLOAT, MTMC FLOAT, MTMI FLOAT, data_series INT, currency_id INT, is_mapped INT, term_end DATETIME)'    )--updated for risk bucket mapping logic
EXEC ('CREATE TABLE ' + @MTMVolProcessTableName + ' (curve_id INT, term_start DATETIME, MTM FLOAT, MTMC FLOAT, MTMI FLOAT, data_series INT, currency_id INT, is_mapped INT)')
EXEC ('CREATE TABLE ' + @DriftProcessTableName + ' (curve_id int, term_start DATETIME, AVG_Value FLOAT, AVG_Value_shift FLOAT)')--updated for risk bucket mapping logic
--EXEC ('CREATE TABLE ' + @std_deal_table	+ '(real_deal VARCHAR(1), source_deal_header_id INT, counterparty INT, buy_index INT, buy_price FLOAT,
--											buy_volume FLOAT, buy_UOM INT, buy_term_start DATETIME, buy_term_end DATETIME, sell_index INT, 
--											sell_price FLOAT, sell_volume FLOAT, sell_UOM INT, sell_term_start DATETIME, sell_term_end DATETIME)')


SELECT @risk_id = STUFF((SELECT DISTINCT ',' +  CAST(ISNULL(spcd.risk_bucket_id, a.item) AS VARCHAR(20)) 
						 FROM source_price_curve_def spcd
						 INNER JOIN dbo.FNASplit(@curve_ids,',') a
							ON a.item = spcd.source_curve_def_id
						FOR XML PATH(''))
						, 1, 1, '')
						
SELECT @risk_id1 = STUFF((SELECT DISTINCT ',' +  CAST(ISNULL(spcd.risk_bucket_id, a.item) AS VARCHAR(20)) 
						 FROM source_price_curve_def spcd
						 INNER JOIN dbo.FNASplit(@curve_ids1,',') a
							ON a.item = spcd.source_curve_def_id
						FOR XML PATH(''))
						, 1, 1, '')  

CREATE TABLE #tmp_cor(
	X_curve_id    INT,
	Y_curve_id    INT,
	X_term_start  DATETIME,
	Y_term_start  DATETIME,
	Cor_value     FLOAT
)
CREATE TABLE #tmp_term(
	map_months         INT,
	term_start         DATETIME,
	map_term_start     DATETIME,
	curve_id           INT,
	debt_rating        INT,
	MTM                FLOAT,
	MTMC               FLOAT,
	MTMI               FLOAT,
	deal_id            NVARCHAR(400) COLLATE DATABASE_DEFAULT ,
	counterparty_id    INT,
	counterparty_name  NVARCHAR(2000) COLLATE DATABASE_DEFAULT ,
	currency_id			INT,
	risk_bucket_map		INT ,		--added later for risk bucket mapping logic, sligal
	shift_by			CHAR(1) COLLATE DATABASE_DEFAULT , -- " "
	shift_value			FLOAT,		-- " "
	is_mapped			INT,			-- " " -- updated for riskbucket mapping logic
	term_end			DATETIME
)
CREATE TABLE #tmp_curve_deal(curve_id INT, deal_id  NVARCHAR(400) COLLATE DATABASE_DEFAULT )
--CREATE TABLE #tmp_book(	book_id INT)
CREATE TABLE #as_of_date_point(Row_id INT IDENTITY(1, 1), as_of_date  DATETIME, curve_id INT,data_shift int,shift_status bit,sno_as_of_date int,lambda float)
CREATE TABLE #curve_matrix(
	curve_id     INT,
	term_start   DATETIME,
	Row_id       INT,
	as_of_date   DATETIME,
	curve_value  FLOAT,data_series INT,sno_as_of_date int,sno_maturity int
)
CREATE TABLE #return_matrix(
	curve_id      INT,
	term_start    DATETIME,
	Row_id        INT,
	as_of_date    DATETIME,
	MATRIX_Value  FLOAT,
	MATRIX_Mean   FLOAT
)

CREATE TABLE #tmp_data(curve_id INT, term_start DATETIME, as_of_date DATETIME,sno_as_of_date int,sno_maturity int,row_id int,data_series int)
CREATE TABLE #tmp_err1(curve_id INT, term_start DATETIME, as_of_date DATETIME,sno_as_of_date int,sno_maturity int)

SET @st_where = ''

DECLARE @name                               VARCHAR(200),
        @category                           INT,
        @trader                             INT,
        @include_options_delta              VARCHAR(1),
        @include_options_notional           VARCHAR(1),
        @market_credit_correlation          FLOAT,
        @var_approach                       INT,
        @simulation_days                    INT,
        @confidence_interval                INT,
        @holding_period                     INT,
        @active                             VARCHAR(1),
        @vol_cor                            VARCHAR(1),
        @fas_book_id                        VARCHAR(500),
        @calc_vol_cor                       VARCHAR(1),
        @hold_to_maturity					CHAR(1) = 'N',
        @tenor_from							INT = NULL,
        @tenor_to							INT = NULL,
        @function_id						VARCHAR(10) = NULL,
        @id									INT = NULL,
        @hyperlink							VARCHAR(500),
        @use_dis_val						CHAR(1),
		@use_market_value					char(1)

DECLARE @st_stmt    VARCHAR(8000)
DECLARE @st_where1  VARCHAR(800)
DECLARE @st_where2  VARCHAR(800)
DECLARE @source  VARCHAR(100)
DECLARE @module  VARCHAR(100)


SET @trader = NULL
SET @fas_book_id = NULL
--SET @st_where_book = ''

SET @source = 'VAR Calculation'
SET @module = 'VAR Calculation'

IF @calc_only_vol_cor = 'y'
BEGIN
    SET @source = 'Vol_Cor Calculation'
    SET @module = 'Vol_Cor Calculation'
END
ELSE
    SET @calc_option = 'a'
    
    
    --Start Logic NOW
SET @calc_type = ISNULL(@calc_type, 'r')      
       
BEGIN TRY
	IF @var_criteria_id IS NULL
	    SELECT @name = 'Vol_Cor',
           @category = NULL,
           @trader = NULL,
           @include_options_delta = 'n',
           @include_options_notional = 'n',
           @market_credit_correlation = NULL,
           @var_approach = @measurement_approach,
           @simulation_days = 30,
           @confidence_interval = @conf_interval,
           @holding_period = ISNULL(@hold_period, 1),
           @price_curve_source = ISNULL(@price_curve_source, 4500),
           @daily_return_data_series = ISNULL(@daily_return_data_series, 1562),
           @data_points = ISNULL(@data_points, 250),
           @active = 'y',
           @vol_cor = 'v', --d =data of same as_of_date;   v=data of most recent
           @fas_book_id = NULL,
           @calc_vol_cor = 'n'
           
	--IF NOT (@var_criteria_id IS NULL AND @calc_only_vol_cor = 'y')
	SET @daily_return_data_series = ISNULL(@daily_return_data_series, 1562)
	
	IF @var_criteria_id IS NOT NULL --AND @calc_only_vol_cor = 'n' --only while call from VaR Calculation
	BEGIN
			--IF @fas_book_id IS NOT NULL
			   -- SET @st_where_book = ' and ssbm.fas_book_id in (' + @fas_book_id + ')'
		IF @calc_type = 'w'
		BEGIN
			IF @whatif_criteria_id IS NOT NULL
			BEGIN
	    		SELECT 
	    			@id = @whatif_criteria_id,
	    			@price_curve_source = ISNULL(ISNULL(mwc.source,msg.source), 4500),
	    			@hold_to_maturity = ISNULL(hold_to_maturity, 'N'),
					@volatility_source = ISNULL(ISNULL(mwc.volatility_source, msg.volatility_source), 4500),
					@tenor_from = pmt.starting_month,
	    			@tenor_to = pmt.no_of_month,
	    			@function_id = 10183400,
					@use_market_value = ISNULL(mwc.use_market_value, 'n'),
	    			@use_dis_val = ISNULL(use_discounted_value, 'n'),
	    			@include_options_delta = 'y'
	    		FROM maintain_whatif_criteria mwc
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
				   @id = @var_criteria_id,
				   @name = [name],
				   @criteria_name = [name],
				   @category = category,
				   @trader = trader,
				   @include_options_delta = CASE WHEN var_approach = '1520' THEN 'y' ELSE include_options_delta END,
				   @include_options_notional = include_options_notional,
				   @market_credit_correlation = market_credit_correlation,
				   @var_approach = var_approach,
				   @simulation_days = simulation_days,
				   @confidence_interval = confidence_interval,
				   @holding_period = ISNULL(holding_period, 1),
				   @price_curve_source = ISNULL(price_curve_source, 4500),
				   @daily_return_data_series = ISNULL(daily_return_data_series, 1562),
				   @data_points = 250,
				   @active = active,
				   @vol_cor = vol_cor,
				   @hold_to_maturity = ISNULL(hold_to_maturity, 'N'),
				   @volatility_source = volatility_source,
				   @tenor_from = pmt.starting_month,
	    		   @tenor_to = pmt.no_of_month,
	    		   @function_id = 10181200,
	    		   @use_dis_val = ISNULL(use_discounted_value, 'n'),
				   @use_market_value = isnull(vmwc.use_market_value, 'n')
				FROM  [dbo].[var_measurement_criteria_detail] vmwc
				LEFT JOIN portfolio_mapping_source pms ON pms.mapping_source_usage_id = vmwc.id
					AND pms.mapping_source_value_id = 23203
				LEFT JOIN portfolio_mapping_tenor pmt ON pmt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
				WHERE  id = @var_criteria_id
			END
		END
		
		SET @hyperlink = @criteria_name --dbo.FNATRMWinHyperlink('a', @function_id, @criteria_name, @id,null,null,null,null,null,null,null,null,null,null,null,0)
		--Collecting All deals from different sources	
	
		SET @term_start = dbo.FNAGetContractMonth(ISNULL(@term_start, DATEADD (MONTH, @tenor_from, @as_of_date)))
		SET @term_end = CONVERT(VARCHAR(10), dbo.FNALastDayInDate(ISNULL(@term_end, DATEADD (MONTH, @tenor_to, @as_of_date))), 120)
		
		--DECLARE @str_and VARCHAR(100)
		--DECLARE @str_union VARCHAR(200)
		--SET @str_and = ''
		--SET @str_union = ''
			
		--IF @trader IS NOT NULL
		--	SET @str_and = @str_and + 'AND sdh.trader_id = ''' + CAST(@trader AS VARCHAR) + ''''
			
		--IF NOT EXISTS(SELECT * FROM var_measurement_criteria WHERE var_criteria_id = @var_criteria_id) AND @trader IS NOT NULL
		--	SET @str_union = @str_union + 'UNION 
		--			SELECT DISTINCT ''y'',source_deal_header_id deal_id   FROM source_deal_header 
		--			WHERE trader_id = ''' + CAST(@trader AS VARCHAR) + ''''
			                                       	
		--SET @st_stmt = '
		--	INSERT INTO ' + @std_deal_table + '(real_deal, source_deal_header_id)
		--	SELECT DISTINCT ''y'', sdh.source_deal_header_id deal_id 
		--	FROM dbo.source_system_book_map ssbm 
		--	INNER JOIN var_measurement_criteria vmc ON ssbm.fas_book_id = vmc.book_id 
		--			AND vmc.var_criteria_id = ''' + CAST(@var_criteria_id AS VARCHAR) + '''
		--	INNER JOIN source_deal_header sdh ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
		--			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
		--			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
		--			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		--			' + @str_and + '
		--	UNION
		--	SELECT DISTINCT 
		--		''y'', deal_id  
		--	FROM var_measurement_deal 
		--	WHERE var_criteria_id = ''' + CAST(@var_criteria_id AS VARCHAR) + '''' + @str_union + ''
				
		--PRINT(@st_stmt)
		--EXEC(@st_stmt)
		
		EXEC spa_collect_mapping_deals @as_of_date, 23203, @var_criteria_id, @std_deal_table
    
		--Storing deal ids from process table to temporary table to execute dynamic query below
		CREATE TABLE #tmp_deal(deal_id INT) 
		SET @st_stmt = 'INSERT INTO #tmp_deal SELECT source_deal_header_id FROM ' + @std_deal_table
		EXEC(@st_stmt)
	    
		IF (NOT EXISTS(SELECT deal_id FROM #tmp_deal) AND (@calc_type <> 'w')) 
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
				SELECT  @process_id, 'Error', @module, @source, 'no_rec', 'The deals are not found for '
				+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink + ';'
				END + ' As_of_Date:' + dbo.FNADateFormat(@as_of_date) + '; Criteria:' + ISNULL(@name, '') + '.','Please check data.'
			
			RAISERROR ('CatchError', 16, 1)
		END
	
		SET @price_curve_source = ISNULL(@price_curve_source, 4500)
		SET @st_where = ''
		SET @st_where1 = ''
		SET @st_hypo = ''
	    
		IF @term_start IS NOT NULL
			SET @st_where = @st_where + ' AND sdd.term_start >= ''' + CAST(@term_start AS VARCHAR) + ''''
	    
		IF @term_end IS NOT NULL
			SET @st_where = @st_where + ' AND sdd.term_end <= ''' + CAST(@term_end AS VARCHAR) + ''''
	     
		 SET @st_hypo = @st_hypo + '
			UNION ALL
				SELECT sdpdw.term_start, sdpdw.term_start map_term_start, sdpdw.curve_id curve_id,
					scp.debt_rating, 
					' + CASE WHEN @use_dis_val = 'y' THEN ' sdpdw.dis_pnl' ELSE ' sdpdw.und_pnl' END + ' AS MTM, 
					CAST(wif.source_deal_header_id AS VARCHAR) deal_id, 
					wif.counterparty, sc.counterparty_name, sdpdw.pnl_currency_id, sdpdw.term_end
				FROM source_deal_pnl_detail_whatif sdpdw 
				INNER JOIN ' + @tbl_name + ' wif ON sdpdw.source_deal_header_id = wif.source_deal_header_id
					AND wif.real_deal = ''n''
				LEFT JOIN (SELECT counterparty_id, 
									MAX(debt_rating) debt_rating 
						   FROM counterparty_credit_info  
						   GROUP BY counterparty_id) scp ON wif.counterparty = scp.counterparty_id
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = wif.counterparty			   
				WHERE sdpdw.pnl_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + ' 
					AND sdpdw.criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '
					AND pnl_as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''   
	    
		SET @st_stmt = '
			INSERT INTO #tmp_term(term_start, map_term_start, curve_id, debt_rating, MTM, deal_id, counterparty_id, counterparty_name, currency_id, term_end)
			SELECT DISTINCT sdd.term_start, sdd.term_start map_term_start, ISNULL(spcd.risk_bucket_id, spcd.source_curve_def_id) curve_id,
				scp.debt_rating, 
				' + CASE WHEN @use_dis_val = 'y' THEN 
						IIF(@use_market_value = 'y', 'ISNULL(rtc.dis_market_value,sdpd.dis_market_value)', 'ISNULL(rtc.dis_pnl, sdpd.dis_pnl)') 
					ELSE IIF(@use_market_value = 'y', 'ISNULL(rtc.market_value, sdpd.market_value)', 'ISNULL(rtc.und_pnl,sdpd.und_pnl)') 
					END + 
				CASE WHEN ISNULL(@include_options_delta, 'n') = 'n' THEN ''
				ELSE 
					' * ISNULL(ABS(delta.delta), 1)' 
				END + ' MTM,sdh.deal_id, sdh.counterparty_id, sc.counterparty_name, 
				ISNULL(rtc.pnl_currency_id, sdpd.pnl_currency_id), 
				sdd.term_end
			FROM source_deal_header sdh' + 
			CASE WHEN ISNULL(@calc_type, 'r') = 'w' THEN 
				' INNER JOIN ' + @tbl_name + ' wif ON sdh.source_deal_header_id = wif.source_deal_header_id 
					AND real_deal = ''y'''
			ELSE 
				' INNER JOIN ' + @std_deal_table + ' sdt ON sdt.source_deal_header_id = sdh.source_deal_header_id'  
			END + '
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
				AND sdh.deal_date <= ''' + CAST(@as_of_date AS VARCHAR) + '''
				AND sdd.term_start >= 
				CASE WHEN sdh.term_frequency = ''m'' THEN
					''' + CONVERT(VARCHAR(7), @as_of_date, 120) + '-01' + '''
				ELSE						
					''' + CAST(@as_of_date AS VARCHAR)+ '''
				END
				AND sdd.term_end > ''' + CAST(@as_of_date AS VARCHAR) + '''
				AND curve_id IS NOT NULL ' + @st_where + ' 
			OUTER APPLY (SELECT rspc.rtc_curve,
								sdpt.pnl_currency_id,
								sdpt.pnl_source_value_id,
								SUM(market_value) market_value, 
								SUM(und_pnl) und_pnl, 
								SUM(dis_market_value) dis_market_value, 
								SUM(dis_pnl) dis_pnl 
						FROM rtc_source_price_curve rspc
						INNER JOIN source_price_curve_def spcdr ON spcdr.source_curve_def_id = rspc.rtc_curve
						INNER JOIN source_deal_pnl_tou sdpt ON sdd.source_deal_header_id = sdpt.source_deal_header_id 
							AND sdd.term_start = sdpt.term_start 
							AND sdd.term_end = sdpt.term_end 
							and sdd.leg = sdpt.leg
							AND sdpt.pnl_as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
							AND sdpt.pnl_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + '
							AND sdpt.tou_id = spcdr.block_define_id
						WHERE rspc.rtc_curve_def_id = sdd.curve_id
						GROUP BY rtc_curve,	sdpt.pnl_currency_id, sdpt.pnl_source_value_id) rtc
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = ISNULL(rtc.rtc_curve, sdd.curve_id)
			LEFT JOIN source_deal_pnl_detail' + CASE WHEN ISNULL(@calc_type, 'r') = 'w' THEN '_whatif'  ELSE ''  END + ' sdpd ON sdd.source_deal_header_id = sdpd.source_deal_header_id 
				AND sdd.term_start = sdpd.term_start 
				AND sdd.term_end = sdpd.term_end and sdd.leg = sdpd.leg
				AND pnl_as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
			LEFT JOIN (SELECT counterparty_id, max(debt_rating) debt_rating FROM counterparty_credit_info GROUP BY counterparty_id) scp ON sdh.counterparty_id = scp.counterparty_id
			LEFT JOIN source_price_curve_def risk_spcd ON spcd.source_curve_def_id = risk_spcd.risk_bucket_id 
				AND risk_spcd.risk_bucket_id IS NOT NULL
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id' + 
			CASE WHEN ISNULL(@include_options_delta, 'n') = 'n' THEN ''
			ELSE ' LEFT JOIN (
					SELECT  source_deal_header_id, term_Start, 1 leg, delta FROM source_deal_pnl_detail_options WHERE as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + '''' 
					--+ CASE WHEN ISNULL(@calc_type, 'r') = 'w' THEN '_whatif'  ELSE '' END + ' WHERE as_of_date=''' + CAST(@as_of_date AS VARCHAR) + '''
					--UNION all SELECT source_deal_header_id, term_Start, 2 leg , delta2 delta FROM source_deal_pnl_detail_options' + CASE WHEN ISNULL(@calc_type, 'r') = 'w' THEN '_whatif'  ELSE '' END + '  WHERE as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''
				+' ) delta ON delta.source_deal_header_id = sdd.source_deal_header_id 
					AND delta.term_Start = sdd.term_Start '
			END + ' WHERE ISNULL(rtc.pnl_source_value_id, sdpd.pnl_source_value_id) = ' + CAST(@price_curve_source AS VARCHAR) 
				 + CASE WHEN ISNULL(@calc_type, 'r') = 'w' THEN ' AND sdpd.criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR)  ELSE '' END
			+ CASE WHEN ISNULL(@calc_type, 'r') = 'w' THEN @st_hypo ELSE '' END	 	  
	    
		EXEC spa_print @st_stmt
		EXEC (@st_stmt)

		--Updating #tmp_term to assign MTM values to primary curve in case of multiple legged deal	
		--start  
		 --   SET @st_stmt ='
			--	INSERT INTO #tmp_curve_deal(curve_id, deal_id)
			--		SELECT ISNULL(risk_spcd1.source_curve_def_id,spcd1.source_curve_def_id),tt.deal_id FROM source_deal_detail sdd
			--		LEFT JOIN source_price_curve_def spcd1 on sdd.curve_id=spcd1.source_curve_def_id
			--		LEFT JOIN source_price_curve_def risk_spcd1 ON risk_spcd1.source_curve_def_id = spcd1.risk_bucket_id 
			--			AND spcd1.risk_bucket_id IS NOT NULL
			--		INNER JOIN #tmp_term tt ON tt.term_start = sdd.term_start
			--			AND sdd.Leg = ''1''
			--		INNER JOIN source_deal_header sdh ON tt.deal_id = sdh.deal_id
			--			AND sdh.source_deal_header_id = sdd.source_deal_header_id
			--	UNION ALL
			--		SELECT 
			--			ISNULL(risk_spcd.source_curve_def_id,spcd.source_curve_def_id),tt1.deal_id
			--		FROM source_deal_pnl_detail_whatif sdpdw
			--		LEFT JOIN source_price_curve_def spcd on sdpdw.curve_id=spcd.source_curve_def_id
			--		LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
			--			AND spcd.risk_bucket_id IS NOT NULL
			--		INNER JOIN #tmp_term tt1 ON tt1.term_start = sdpdw.term_start
			--			AND tt1.deal_id = CAST(sdpdw.source_deal_header_id AS VARCHAR)
			--			AND sdpdw.Leg = ''1'''
					
			--PRINT @st_stmt
		 --   EXEC (@st_stmt)
		    
		 --   UPDATE #tmp_term 
			--	SET curve_id = tcd.curve_id 
		 --   FROM #tmp_term tt
			--INNER JOIN #tmp_curve_deal tcd ON tt.deal_id = tcd.deal_id

		--end
	    
			IF NOT EXISTS(SELECT 1 FROM #tmp_term)
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
				SELECT @process_id,'Error',@module,@source,'MTM','MTM is not found for '
				+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN 
					(CASE WHEN @var_criteria_id = -1 THEN 
						'Criteria: ' + @hyperlink
					ELSE '' 
					END
					)
				ELSE 'Criteria: ' + @hyperlink 
				END + '.','Please check data.'
					        
				RAISERROR('CatchError', 16, 1)
			END
		    
			IF EXISTS(SELECT 1 FROM #tmp_term WHERE counterparty_id IS NULL)
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
				SELECT @process_id, 'Error', @module, @source, 'Counterparty', 'Counterparty is not found for '
					+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN ''
					  ELSE 'Criteria: ' + @hyperlink + ';' END + ' Deal_ID:' + deal_id + '.','Please check data.'
				FROM #tmp_term
				WHERE counterparty_id IS NULL
		        
				RAISERROR ('CatchError', 16, 1)
			END
		    
			UPDATE #tmp_term SET map_months = dbo.FNAGetMapMonthNo(curve_id, term_start, @as_of_date)
	    
			SET @month_1st_date = CAST(CAST(YEAR(@as_of_date) AS VARCHAR) + '-' + CAST(MONTH(@as_of_date) AS VARCHAR) + '-01' AS DATETIME)
		    
			UPDATE #tmp_term SET map_term_start = DATEADD(mm, map_months, @month_1st_date)
		    
			/* start risk bucket mapping logic
			* update later added cols: risk_bucket_map, shift_by, shift_value, is_mapped: according to difference in updated values of term_start and map_term_start */
			UPDATE tt
			SET risk_bucket_map = vtbm.risk_bucket,
				tt.shift_by = vtbm.shift_by,
				tt.shift_value = vtbm.shift_value,
				tt.is_mapped = 1
			FROM #tmp_term tt
			INNER JOIN var_time_bucket_mapping vtbm ON vtbm.curve_id = tt.curve_id
			WHERE (DATEDIFF(mm, tt.term_start, tt.map_term_start) <> 0) AND tt.map_term_start > @as_of_date
			/*
			* end risk bucket mapping logic
			*/
			-- updated for riskbucket mapping logic
			IF @calc_only_vol_cor = 'y'
			BEGIN
				SET @st_stmt = 'INSERT into ' + @MTMProcessTableName + ' (curve_id, term_start, data_series, is_mapped)
					SELECT 
					CASE WHEN ISNULL(tt.is_mapped, 0) = 1 THEN 
						ISNULL(tt.risk_bucket_map, tt.curve_id)
					ELSE 
						tt.curve_id
					END
					[curve_id], map_term_start term_start, ' + CAST(@daily_return_data_series AS VARCHAR) + ', is_mapped FROM #tmp_term tt
					GROUP BY curve_id, tt.risk_bucket_map, map_term_start, is_mapped'
			    
				exec spa_print @st_stmt
				EXEC (@st_stmt)	   
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT deal_id FROM #tmp_term WHERE MTM IS NULL)
				BEGIN
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
						SELECT @process_id,'Error', @module, @source, 'MTM_Value', 'MTM Value is not found for '
						+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN '' 
						ELSE 'Criteria: ' + @hyperlink + ';'
						END + ' As_of_Date:'+ dbo.FNADateFormat(@as_of_date)+ '; Deal_ID:' + deal_id + '; Term_Start: ' + 
						dbo.FNADateFormat(term_start) + '.','Please check data.'
					FROM #tmp_term
					WHERE MTM IS NULL
			        
					RAISERROR ('CatchError', 16, 1)
				END
				
				IF EXISTS(SELECT 1 FROM #tmp_term WHERE debt_rating IS NULL)
				BEGIN
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
					SELECT DISTINCT @process_id, 'Warning',@module,@source,'Debt_Rating','Debt Rating is not found for '
						+ CASE  WHEN @name IS NULL OR @var_criteria_id IS NULL THEN ''  
						ELSE 
							'Criteria: ' + @hyperlink + ';'
						END + ' Counterparty:'+ counterparty_name+ '.','Please check data.'
					FROM #tmp_term
					WHERE debt_rating IS NULL
			        
					--RAISERROR ('CatchError', 16, 1)
				END	    
			    
				UPDATE #tmp_term
				SET MTMC = MTM * dbo.FNAGetProbabilityDefault(debt_rating, map_months, @as_of_date)
				   * ( 1 - dbo.FNAGetRecoveryRate(debt_rating, map_months, @as_of_date)),
				   MTMI = MTM * (1 + dbo.FNAGetProbabilityDefault(debt_rating, map_months, @as_of_date))
			    
				IF EXISTS(SELECT 1 FROM #tmp_term WHERE mtmc IS NULL)
				BEGIN
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
					SELECT DISTINCT @process_id, 'Warning', @module, @source, 'Default_Recovery', 'Default Probability/Recoverary Rate is not found '
						+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN '' 
						ELSE 
							'Criteria: ' + @hyperlink + ';'
						END + ' for Rating:' + s.code+ '; As of Date:'+ dbo.FNADateFormat(@as_of_date)+ '; No of Month(s):'
						+ CAST(map_months AS VARCHAR)+ '; Deal ID:' + deal_id + '.','Please check data.'
					FROM #tmp_term t 
					JOIN static_data_value s ON t.debt_rating = s.value_id
					WHERE mtmc IS NULL
			        
					--RAISERROR ('CatchError', 16, 1)
				END
			    
				IF EXISTS (SELECT deal_id FROM #tmp_term WHERE  mtmi IS NULL)
				BEGIN
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
					SELECT DISTINCT @process_id,	'Warning',@module,@source,'Probability','Default Probability is not found '
						+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN '' 
						ELSE 
							'Criteria: ' + @hyperlink + ';'
						END + ' for Rating:' + s.code + '; As of Date:' + dbo.FNADateFormat(@as_of_date)+ '; No of Month(s):' + 
						CAST(map_months AS VARCHAR) + '; Deal ID:' + deal_id + '.', 'Please check data.'
					FROM #tmp_term t 
					JOIN static_data_value s ON t.debt_rating = s.value_id
					WHERE mtmi IS NULL
			        
					--RAISERROR ('CatchError', 16, 1)
				END

				UPDATE #tmp_term
				SET MTMC = MTM * ISNULL(dbo.FNAGetProbabilityDefault(debt_rating, map_months, @as_of_date), 0)
				   * ( 1 - ISNULL(dbo.FNAGetRecoveryRate(debt_rating, map_months, @as_of_date), 0)),
				   MTMI = MTM * (1 + ISNULL(dbo.FNAGetProbabilityDefault(debt_rating, map_months, @as_of_date), 0))

				--Hold to maturity enhancement start
				IF @hold_to_maturity = 'Y'
				BEGIN
					SET @st_stmt='INSERT INTO #mtm_process_table_new
							SELECT curve_id, 
								term_start, 
								MTM * SQRT(DATEDIFF(DAY, ''' + CAST(@as_of_date AS VARCHAR) + ''', term_end)) MTM, 
								MTMC * SQRT(DATEDIFF(DAY, ''' + CAST(@as_of_date AS VARCHAR) + ''', term_end)) MTMC, 
								MTMI * SQRT(DATEDIFF(DAY, ''' + CAST(@as_of_date AS VARCHAR) + ''', term_end)) MTMI, 
								' + CAST(@daily_return_data_series AS VARCHAR) + ' data_series,
								currency_id, 
								is_mapped, 
								term_end,
								risk_bucket_map,
								map_term_start 
							FROM #tmp_term'  
									
					exec spa_print @st_stmt
					EXEC(@st_stmt)
					
					SET @st_stmt = '
					INSERT INTO ' + @MTMProcessTableName + ' (curve_id, term_start, MTM, MTMC, MTMI, data_series, currency_id, is_mapped)
					SELECT 
						CASE WHEN ISNULL(tt.is_mapped, 0) = 1 THEN 
							ISNULL(tt.risk_bucket_map, tt.curve_id)
						ELSE 
							tt.curve_id
						END [curve_id],
						map_term_start term_start, SUM(mtm) MTM, SUM(mtmc) MTMC, SUM(mtmi) MTMI,' + CAST(@daily_return_data_series AS VARCHAR) + ', 
						max(currency_id), is_mapped 
					FROM #mtm_process_table_new tt
					GROUP BY curve_id, tt.risk_bucket_map, map_term_start, is_mapped'
		    
					exec spa_print @st_stmt
					EXEC (@st_stmt)
				--Hold to maturity enhancement end	
				END
				ELSE
				BEGIN
					-- updated for riskbucket mapping logic
					SET @st_stmt = '
					INSERT INTO ' + @MTMProcessTableName + ' (curve_id, term_start, MTM, MTMC, MTMI, data_series, currency_id, is_mapped)
					SELECT 
						CASE WHEN ISNULL(tt.is_mapped, 0) = 1 THEN 
							ISNULL(tt.risk_bucket_map, tt.curve_id)
						ELSE 
							tt.curve_id
						END [curve_id],
						map_term_start term_start, SUM(mtm) MTM, SUM(mtmc) MTMC, SUM(mtmi) MTMI,' + CAST(@daily_return_data_series AS VARCHAR) + ', 
						max(currency_id), is_mapped 
					FROM #tmp_term tt
					GROUP BY curve_id, tt.risk_bucket_map, map_term_start, is_mapped'
		    
					exec spa_print @st_stmt
					EXEC (@st_stmt)
				END	
				
				SET @st_stmt = 'SELECT 
						CASE WHEN ISNULL(tt.is_mapped, 0) = 1 THEN 
							ISNULL(tt.risk_bucket_map, tt.curve_id)
						ELSE 
							tt.curve_id
						END curve_id,
						map_term_start term_start, SUM(mtm) MTM, SUM(mtmc) MTMC, SUM(mtmi) MTMI,' + CAST(@daily_return_data_series AS VARCHAR) + ' data_series, 
						max(currency_id) currency_id, is_mapped 
					INTO ' + @MTMProcessTableNameNew + '	
					FROM #tmp_term tt
					GROUP BY curve_id, tt.risk_bucket_map, map_term_start, is_mapped'
		    
					exec spa_print @st_stmt
					EXEC (@st_stmt)
			END --else   @calc_only_vol_cor = 'y'
	END
	ELSE  ---(@var_criteria_id IS NULL )
	BEGIN
		SET @st_where2=''
		SET @st_where1=''
		SET @st_where=''
		
		IF @term_start IS NOT NULL AND @term_end IS NOT NULL AND ISNULL(@calc_type,'r') <> 'w'--generate maturity_term from @term_start and @term_end 
		BEGIN  
			IF @curve_ids IS NOT NULL
			BEGIN
				SET @st_where = @st_where + ' AND (ISNULL(risk_spcd.source_curve_def_id, spcd.source_curve_def_id) IN (' + @curve_ids + ')
					OR spcd.source_curve_def_id IN (' + @curve_ids + '))'
				
				IF @curve_ids1 IS NOT NULL
					SET @st_where = @st_where + ' OR (ISNULL(risk_spcd.source_curve_def_id, spcd.source_curve_def_id) IN (' + @curve_ids1 + ')
					OR spcd.source_curve_def_id IN ('+@curve_ids1+'))'
			END
		
			CREATE TABLE #tmp_risk (curve_id INT,Granularity VARCHAR(1) COLLATE DATABASE_DEFAULT , [volatility] VARCHAR(50) COLLATE DATABASE_DEFAULT ,	[drift] VARCHAR(50) COLLATE DATABASE_DEFAULT  ,[data_series] INT ,[curve_source] INT,seed VARCHAR(50) COLLATE DATABASE_DEFAULT )	

			IF @calc_only_vol_cor = 'y'  
				SET @st_stmt = '
					INSERT INTO #tmp_risk(curve_id, Granularity, [data_series], [curve_source])
					SELECT ISNULL(risk_spcd.source_curve_def_id, spcd.source_curve_def_id) curve_id,
						CASE ISNULL(risk_spcd.Granularity, spcd.Granularity) 
							WHEN 982 THEN ''h''	WHEN 981 THEN ''d'' WHEN 980 THEN ''m'' 
							WHEN 991 THEN ''q'' WHEN 992 THEN ''s'' WHEN 993 THEN ''a'' 
							WHEN 10000289 THEN ''m'' 
							WHEN 10000290 THEN ''d''
							ELSE ''w''
					END Granularity,' + CAST(@daily_return_data_series AS VARCHAR) + ',' + CAST(ISNULL(@price_curve_source,4500) AS VARCHAR) + '
					FROM source_price_curve_def spcd 
					LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
						AND spcd.risk_bucket_id IS NOT NULL 
					WHERE 1 = 1 ' + @st_where
			ELSE
				SET @st_stmt = '
					INSERT INTO #tmp_risk(curve_id, Granularity, [volatility], [drift], [data_series], [curve_source], seed)
					SELECT ISNULL(risk_spcd.source_curve_def_id, spcd.source_curve_def_id) curve_id,
						CASE ISNULL(risk_spcd.Granularity, spcd.Granularity) 
							WHEN 982 THEN ''h''	WHEN 981 THEN ''d'' WHEN 980 THEN ''m'' 
							WHEN 991 THEN ''q'' WHEN 992 THEN ''s'' WHEN 993 THEN ''a'' 
							WHEN 10000289 THEN ''m'' 
							WHEN 10000290 THEN ''d''
							ELSE ''w''
						END Granularity, m.volatility, m.drift, m.data_series, m.curve_source,m.seed
					FROM source_price_curve_def spcd 
					LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
						AND spcd.risk_bucket_id IS NOT NULL
					LEFT JOIN monte_carlo_model_parameter m ON m.monte_carlo_model_parameter_id = ISNULL(risk_spcd.monte_carlo_model_parameter_id, spcd.monte_carlo_model_parameter_id)
					WHERE ISNULL(risk_spcd.monte_carlo_model_parameter_id, spcd.monte_carlo_model_parameter_id) IS NOT NULL ' + @st_where

				EXEC spa_print @st_stmt
				EXEC(@st_stmt)


			SET @st_stmt = '
				INSERT INTO ' + @MTMProcessTableName + ' (term_start, curve_id, data_series)
				SELECT DISTINCT	t.term_start, r.curve_id,' + 
					CASE WHEN @calc_only_vol_cor = 'y' THEN 
						CAST(@daily_return_data_series AS VARCHAR) 
					ELSE 
						'r.data_series' 
					END + ' 
				FROM #tmp_risk r
				CROSS APPLY [dbo].[FNATermBreakdown](r.Granularity, ''' + CONVERT(VARCHAR(11), @term_start, 120) + ''',''' + CONVERT(VARCHAR(11), @term_end, 120) + ''') t'

			EXEC spa_print @st_stmt
			EXEC(@st_stmt)
		END -- @term_start is not null 	  and @term_end is not null and ISNULL(@calc_type,'r') <> 'w'
		ELSE  --generate maturity_term from source_price_curve
		BEGIN
			SET @st_where=''
			SET @term_start = ISNULL(@term_start, dbo.FNAGetContractMonth(@as_of_date))

			IF @term_start IS NOT NULL
				SET @st_where = @st_where + ' AND spc.maturity_date >= ''' + CAST(@term_start AS VARCHAR) + ''''
					
			IF @term_end IS NOT NULL
				SET @st_where = @st_where + ' AND spc.maturity_date <= ''' + CAST(@term_end AS VARCHAR) + ''''

			IF @curve_ids IS NOT NULL
				SET @st_where1 = ' AND spc.source_curve_def_id IN (' + @risk_id + ')'
				
			IF @curve_ids1 IS NOT NULL
				SET @st_where2 = ' AND spc.source_curve_def_id IN (' + @risk_id1 + ')'
		  
			IF @st_where2 <> ''
			BEGIN
				SET @st_where = ' AND ((1 = 1 ' + @st_where + @st_where1 + ')  or  ( 1 = 1 ' + @st_where + @st_where2 + '))'; 
				EXEC spa_print 'stage 1:', @st_where
			END
			ELSE
			BEGIN
				SET @st_where = @st_where +  @st_where1	
				EXEC spa_print 'stage 2:', @st_where	
			END
		    
			SET @st_stmt = '
				INSERT INTO ' + @MTMProcessTableName + ' (curve_id, term_start, data_series)
				SELECT DISTINCT spc.source_curve_def_id, spc.maturity_date, ' + CAST(@daily_return_data_series AS VARCHAR) + ' 
				FROM (SELECT DISTINCT source_curve_def_id FROM source_price_curve WHERE curve_source_value_id = ' + CAST(ISNULL(@price_curve_source, 4500) AS VARCHAR) + ' 
				) a 
				CROSS APPLY (
					SELECT TOP(1) as_of_date 
					FROM source_price_curve 
					WHERE source_curve_def_id = a.source_curve_def_id 
					AND as_of_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''' 
					ORDER BY as_of_date DESC
					) d
				INNER JOIN source_price_curve spc ON spc.source_curve_def_id = a.source_curve_def_id 
					AND spc.as_of_date = d.as_of_date 
					AND spc.curve_source_value_id = ''' + CAST(ISNULL(@price_curve_source, 4500) AS VARCHAR) + '''' 
					+ @st_where + 
				CASE WHEN @calc_type = 'w' THEN '
				INNER JOIN source_deal_detail sdd ON spc.source_curve_def_id = sdd.curve_id 
				INNER JOIN source_Deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id'
				ELSE ''
				END + '
				GROUP BY spc.source_curve_def_id, spc.maturity_date'
		    
			exec spa_print @st_stmt
			EXEC (@st_stmt)
		END
	END
		
	IF @calc_only_vol_cor = 'y'
		SET @calc_vol_cor = 'y'
		
	-----------start calculating drif/vol/cor and inserting result into process table
	EXEC spa_print '****', @calc_only_vol_cor
	
	--Shift value enhancement start
	SET @st_stmt = 'INSERT INTO #curve_ids
		SELECT DISTINCT curve_id FROM ' + @MTMProcessTableName
	
	exec spa_print @st_stmt
	EXEC (@st_stmt)

	INSERT INTO #curve_ids
	SELECT item 
	FROM dbo.FNASplit(@curve_ids, ',') t
	WHERE NOT EXISTS(SELECT 1 FROM #curve_ids c WHERE c.curve_id = t.item)
	
	SELECT DISTINCT 
		@relative_volatility = ISNULL(mcmp.relative_volatility, 'n') 
	FROM source_price_curve_def spcd
	INNER JOIN #curve_ids ci ON ci.curve_id = spcd.source_curve_def_id
	INNER JOIN monte_carlo_model_parameter mcmp ON spcd.monte_carlo_model_parameter_id = mcmp.monte_carlo_model_parameter_id
		AND mcmp.relative_volatility = 'y'

	--Shift value enhancement end  
	IF @calc_only_vol_cor = 'y'
	BEGIN
			SELECT 
				@data_points = ISNULL(MIN(mcmp.vol_data_points), @data_points) 
			FROM source_price_curve_def spcd
			INNER JOIN #curve_ids ci ON ci.curve_id = spcd.source_curve_def_id
			INNER JOIN monte_carlo_model_parameter mcmp ON spcd.monte_carlo_model_parameter_id = mcmp.monte_carlo_model_parameter_id
	
		IF @curve_ids1 IS NULL
		BEGIN
	  		SET @st_stmt = '
				INSERT INTO #as_of_date_point (curve_id, as_of_date,sno_as_of_date)	
		 		SELECT mtm.curve_id,a.as_of_date,ROW_NUMBER() OVER (PARTITION BY mtm.curve_id ORDER BY  a.as_of_date desc) FROM 
		 		(SELECT DISTINCT curve_id FROM ' + @MTMProcessTableName + ' ) mtm
	 			LEFT JOIN source_price_curve_def spcd1 on mtm.curve_id = spcd1.source_curve_def_id
				LEFT JOIN source_price_curve_def risk_spcd1 ON risk_spcd1.source_curve_def_id = spcd1.risk_bucket_id 
					AND spcd1.risk_bucket_id IS NOT NULL
				CROSS APPLY (
					SELECT TOP(' + CAST(@data_points AS VARCHAR)  + ') spc.as_of_date FROM ' + @MTMProcessTableName   + ' m 
					LEFT JOIN source_price_curve_def spcd on m.curve_id = spcd.source_curve_def_id
					LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
						AND spcd.risk_bucket_id IS NOT NULL 
					INNER JOIN source_price_curve spc ON spc.source_curve_def_id = ISNULL(risk_spcd.source_curve_def_id, spcd.source_curve_def_id) 
						--AND m.term_start = spc.maturity_date 
						AND spc.as_of_date <= ''' + CAST(@as_of_date AS VARCHAR) + '''
						AND spc.source_curve_def_id = ISNULL(risk_spcd1.source_curve_def_id, spcd1.source_curve_def_id)
						AND spc.curve_source_value_id = ' + CAST(@price_curve_source AS VARCHAR)+' 
				GROUP BY spc.as_of_date 
				ORDER BY as_of_date DESC) a'	
								 
			
		END
		ELSE -- for calc correlation
		BEGIN
			SET @st_stmt = '
				INSERT INTO #as_of_date_point (curve_id, as_of_date,sno_as_of_date)
				SELECT TOP (' + CAST(@data_points AS VARCHAR) + ') -1, *,ROW_NUMBER() OVER (ORDER BY  as_of_date desc) FROM (
				SELECT spc.as_of_date  FROM 
					(SELECT MIN(term_start) term_start_min, MAX(term_start) term_start_max, COUNT(1) no_rec   
					FROM ' + @MTMProcessTableName + ' m
					LEFT JOIN source_price_curve_def spcd on m.curve_id = spcd.source_curve_def_id
					LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
						AND spcd.risk_bucket_id IS NOT NULL 
					WHERE ISNULL(risk_spcd.source_curve_def_id, spcd.source_curve_def_id) IN (' + @risk_id + ')
						OR (risk_spcd.source_curve_def_id IS NOT NULL AND spcd.source_curve_def_id IN (' + @risk_id + '))) t
				INNER JOIN  source_price_curve spc ON spc.source_curve_def_id IN (' + @risk_id + ')
					AND spc.maturity_date BETWEEN t.term_start_min AND t.term_start_max
					AND spc.as_of_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''' 
					AND spc.curve_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + '
				GROUP BY spc.as_of_date ' + CASE WHEN ISNULL(@relative_volatility, 'n') = 'Y' THEN '' ELSE 'HAVING COUNT(1) = MAX(t.no_rec)' END + '
				INTERSECT 
				SELECT spc.as_of_date FROM 
				(SELECT MIN(term_start) term_start_min, MAX(term_start) term_start_max, COUNT(1) no_rec   
				FROM ' + @MTMProcessTableName + ' m
				LEFT JOIN source_price_curve_def spcd on m.curve_id=spcd.source_curve_def_id
				LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
					AND spcd.risk_bucket_id IS NOT NULL 
				WHERE ISNULL(risk_spcd.source_curve_def_id, spcd.source_curve_def_id) IN (' + @risk_id1 + ')
					OR (risk_spcd.source_curve_def_id IS NOT NULL AND spcd.source_curve_def_id IN (' + @risk_id1 + ') )
				) t
				INNER JOIN source_price_curve spc ON spc.source_curve_def_id IN (' + @risk_id1 + ')
					AND spc.maturity_date BETWEEN t.term_start_min AND t.term_start_max
					AND spc.as_of_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''' 
					AND spc.curve_source_value_id = ' + CAST(@price_curve_source AS VARCHAR) + '
				GROUP BY spc.as_of_date ' + CASE WHEN ISNULL(@relative_volatility, 'n') = 'Y' THEN '' ELSE 'HAVING COUNT(1) = MAX(t.no_rec)' END + ') a  
				ORDER BY as_of_date DESC'
	    
		END
		exec spa_print @st_stmt
		EXEC (@st_stmt)



		SET @st_stmt = 'INSERT INTO ' + @MTMVolProcessTableName + '(curve_id, term_start, MTM, MTMC, MTMI, data_series, currency_id, is_mapped)
			SELECT mtm.curve_id, mtm.term_start, mtm.MTM, mtm.MTMC, mtm.MTMI, ISNULL(mcmp.vol_data_series, 1562), mtm.currency_id, mtm.is_mapped 
			FROM ' + @MTMProcessTableName + ' mtm
			LEFT JOIN source_price_curve_def spcd ON mtm.curve_id = spcd.source_curve_def_id
			LEFT JOIN monte_carlo_model_parameter mcmp ON spcd.monte_carlo_model_parameter_id = mcmp.monte_carlo_model_parameter_id'
		
		exec spa_print @st_stmt
		EXEC (@st_stmt)

		SET @st_stmt = 'INSERT INTO #tmp_data(curve_id, term_start, as_of_date,sno_as_of_date,sno_maturity,row_id,data_series)
			SELECT m.curve_id, m.term_start, a.as_of_date ,isnull(a.sno_as_of_date,a.row_id)
				,ROW_NUMBER() OVER (PARTITION BY m.curve_id,a.as_of_date ORDER BY  m.term_start) sno_maturity,a.row_id,m.data_series
			FROM ' + @MTMVolProcessTableName + ' m 
			INNER JOIN #as_of_date_point a ON '+ case when @curve_ids1 is null then ' m.curve_id = ISNULL(a.curve_id, m.curve_id)' else '1=1' end
	    
		exec spa_print @st_stmt
		EXEC (@st_stmt)

		INSERT INTO #tmp_err1(curve_id, term_start, as_of_date,sno_as_of_date,sno_maturity)
		SELECT --DISTINCT 
		ISNULL(risk_spcd.source_curve_def_id, spcd.source_curve_def_id) curve_id, d.term_start, d.as_of_date,d.sno_as_of_date,d.sno_maturity
		FROM #tmp_data d  
		LEFT JOIN source_price_curve_def spcd ON d.curve_id = spcd.source_curve_def_id
		LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
			AND spcd.risk_bucket_id IS NOT NULL
		LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = ISNULL(risk_spcd.source_curve_def_id, spcd.source_curve_def_id) 
			AND d.term_start = spc.maturity_date   
			AND d.as_of_date = spc.as_of_date
			AND spc.curve_source_value_id = @price_curve_source
		WHERE spc.source_curve_def_id IS NULL 
		
		SET @hyperlink = @name --dbo.FNATRMWinHyperlink('a', 312, @name, @var_criteria_id,null,null,null,null,null,null,null,null,null,null,null,0)
		
		IF (EXISTS(SELECT 1 FROM #tmp_err1) AND (SELECT COUNT(DISTINCT(as_of_date)) FROM #as_of_date_point) < @data_points)
			AND @relative_volatility <> 'y'
		BEGIN
    		INSERT INTO fas_eff_ass_test_run_log(process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
			SELECT DISTINCT  @process_id, 'Error', @module, @source, 'Price_Curve_Risk_As_of_Date', 'Price Curve value is not found '
			+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN ''
			  ELSE 'Criteria: ' + @hyperlink + ';' 
			END + ' for As_of_Date:' + dbo.FNADateFormat(as_of_date) + '; Curve_ID:' + spcd.curve_id + '; Maturity Date: ' 
			+ dbo.FNADateFormat(term_start) + '.', 'Please check data.'
			FROM #tmp_err1 t 
			INNER JOIN source_price_curve_def spcd ON t.curve_id = spcd.source_curve_def_id
	        
			RAISERROR ('CatchError', 16, 1)
		END
		
		DELETE td 
		FROM #tmp_data td
		INNER JOIN #tmp_err1 te ON te.curve_id = td.curve_id
			AND te.term_start = td.term_start
			AND @relative_volatility = 'n'

		IF EXISTS(SELECT TOP 1 1 FROM #tmp_err1)    
			SET @term_exist = 'y'
			
		IF @relative_volatility = 'y' AND @term_exist = 'y'
		BEGIN
			SET @st_stmt = 'INSERT INTO ' + @MTMProcessTableName + '(curve_id, term_start, data_series)
				SELECT DISTINCT curve_id, DATEADD(MONTH, 1, MAX(term_start)), data_series  FROM ' + @MTMProcessTableName + ' GROUP BY curve_id, data_series'
				
			exec spa_print @st_stmt
			EXEC (@st_stmt)
		END
	
		
		--INSERT INTO #curve_matrix(curve_id, term_start, Row_id, as_of_date, curve_value, data_series,sno_as_of_date,sno_maturity)
		--SELECT mtm.curve_id, mtm.term_start, mtm.Row_id, mtm.as_of_date, spc.curve_value, mtm.data_series, mtm.sno_as_of_date, mtm.sno_maturity
		--FROM #tmp_data mtm
		--INNER JOIN source_price_curve spc ON spc.source_curve_def_id = mtm.curve_id  
		--	AND mtm.term_start = spc.maturity_date 
		--	AND spc.curve_source_value_id =@price_curve_source
		--	and mtm.as_of_date = spc.as_of_date 
		--ORDER BY mtm.curve_id, mtm.term_start, mtm.Row_id
			    
		select @max_sno_maturity=max(sno_maturity) from #tmp_data
		--Shift value enhancement start

		--select * from #aod_ignor_status_for_shifting
		--select * from #as_of_date_point
		--select * from #tmp_err1
		update #as_of_date_point set data_shift=case when e.curve_id is null then 0 else e.sno_maturity end from #as_of_date_point a 
		left join (select  sno_as_of_date,curve_id,max(sno_maturity) sno_maturity from #tmp_err1 group by sno_as_of_date,curve_id)  e 
		on e.sno_as_of_date=a.sno_as_of_date and e.curve_id= case when @calc_option in ('c','a') then e.curve_id else a.curve_id end

		select isnull(a.curve_id,b.curve_id) curve_id,isnull(a.row_id,b.row_id) sno_as_of_date,isnull(a.as_of_date,b.as_of_date) as_of_date
			,case when a.data_shift=b.data_shift or (a.row_id is not null and b.row_id is null ) then 0 else 1 end ignor_status 
		into #aod_ignor_status_for_shifting 
		from #as_of_date_point a left join #as_of_date_point b on a.curve_id=b.curve_id 
			and a.sno_as_of_date=b.sno_as_of_date-1

		IF @relative_volatility = 'y' AND @term_exist = 'y'
		BEGIN
			--Deleting odd rows
			--DELETE FROM #tmp_err1 WHERE CONVERT(VARCHAR(7),term_start, 120) <> CONVERT(VARCHAR(7), as_of_date, 120)
	
	--start new shift------------------------------------------------------------------------------------------------------------------
			
			--Inserting term which need to sfhit with curve_id
			--INSERT INTO #curve_matrix
			--SELECT te.curve_id, te.term_start, ds.Row_id, te.as_of_date, NULL curve_value, ds.data_series FROM #tmp_err1 te
			--OUTER APPLY(
			--	SELECT DISTINCT dsn.row_id, dsn.data_series FROM #curve_matrix dsn WHERE dsn.as_of_date = te.as_of_date
			--		AND dsn.curve_id = te.curve_id 
			--	) ds
	

			--Taking countinues maturity point for deleting un continuos maturity data poin.
			-- select * from #valid_aod_for_shifting
			--select * from #tmp_err1



			select isnull(b.curve_id,a.curve_id) curve_id,isnull(b.as_of_date,a.as_of_date) as_of_date
				,isnull(b.sno_as_of_date,a.sno_as_of_date) sno_as_of_date ,min(isnull(b.sno_maturity,a.sno_maturity)) min_valid_maturity into #valid_aod_for_shifting 
			from #tmp_err1 a left join #tmp_err1 b on a.curve_id=b.curve_id and  a.as_of_date=b.as_of_date
				and a.sno_maturity=b.sno_maturity-1
			where (a.sno_maturity is not null and b.sno_maturity is null ) or (a.sno_maturity-b.sno_maturity)<>1
			group by isnull(b.curve_id,a.curve_id),isnull(b.as_of_date,a.as_of_date),isnull(b.sno_as_of_date,a.sno_as_of_date)
			


			SELECT mtm.curve_id, mtm.as_of_date, max(mtm.term_start) max_term,max(mtm.data_series) data_series into #max_maturity_price_exist
			FROM #tmp_data mtm inner join  #valid_aod_for_shifting b
				on mtm.curve_id=b.curve_id and mtm.sno_as_of_date=b.sno_as_of_date
			left join #tmp_err1 e on mtm.curve_id=e.curve_id and mtm.sno_as_of_date=e.sno_as_of_date and mtm.sno_maturity=e.sno_maturity
			where e.curve_id is null
			group by  mtm.curve_id, mtm.as_of_date


				--select * from #aod_ignor_status_for_shifting where ignor_status=1
			--maintain status for ignoring as_of_deate while calculating..
			


			-- select * from #aod_ignor_status_for_shifting where ignor_status=1
			-- select * from #tmp_data
		--	select * from #last_record
		--  select * from #valid_aod_for_shifting 
		


			--shift price 
			EXEC spa_print 'shift price '
			INSERT INTO #curve_matrix(curve_id,  Row_id, as_of_date, curve_value, data_series,sno_as_of_date,sno_maturity,term_start)
			SELECT mtm.curve_id, mtm.Row_id, mtm.as_of_date, spc.curve_value, mtm.data_series, mtm.sno_as_of_date
				, mtm.sno_maturity, mtm.term_start --,mtm.sno_maturity,isnull(a.min_valid_maturity,0)
			 FROM #tmp_data mtm
			outer apply (
				 select m.* from #tmp_data m  
				left join #valid_aod_for_shifting a on a.curve_id=m.curve_id and a.as_of_date=m.as_of_date 
				where  m.curve_id=mtm.curve_id and m.sno_as_of_date=mtm.sno_as_of_date
					and m.sno_maturity-isnull(a.min_valid_maturity,0)=mtm.sno_maturity
			) mtm1
			INNER JOIN source_price_curve spc ON spc.source_curve_def_id = mtm1.curve_id  
				AND mtm1.term_start = spc.maturity_date 
				AND spc.curve_source_value_id =@price_curve_source
				and mtm1.as_of_date = spc.as_of_date 

		EXEC spa_print 'fill up gaps after shift price '

		--select * from #curve_matrix
	--taking next maturity date price for fill up blank cell after shifting
			INSERT INTO #curve_matrix(curve_id,  Row_id, as_of_date, curve_value, data_series,sno_as_of_date,sno_maturity,term_start)
			select mtm.curve_id,mtm.sno_as_of_date,  mtm.as_of_date, a.curve_value, mtm.data_series,mtm.sno_as_of_date, mtm.sno_maturity, mtm.term_start
			 FROM #tmp_data mtm
			inner join #valid_aod_for_shifting s on s.curve_id=mtm.curve_id and s.as_of_date=mtm.as_of_date 
				and mtm.sno_maturity>13-s.min_valid_maturity
			inner join  #max_maturity_price_exist m on s.as_of_date=m.as_of_date and s.curve_id=m.curve_id
			cross apply
			(
			 select spc.* from source_price_curve spc where  spc.source_curve_def_id = s.curve_id  
				AND   spc.maturity_date = dateadd(month,s.min_valid_maturity,mtm.term_start)
				AND spc.curve_source_value_id =@price_curve_source
				and s.as_of_date = spc.as_of_date
			) a 

						EXEC spa_print ' @max_sno_maturity'

			----update last blank price that are after shifting.
			--update #curve_matrix set Row_id=b.Row_id, as_of_date=b.as_of_date, curve_value=b.curve_value
			--	, data_series=b.data_series,sno_as_of_date=b.sno_as_of_date,sno_maturity=b.sno_maturity+a.sno_maturity
			--from #curve_matrix a inner join #last_record b on a.curve_id=b.curve_id and a.as_of_date=b.as_of_date 
			-- and a.sno_maturity<=0

			--update #curve_matrix set term_start=b.term_start
			--	from #curve_matrix a inner join #tmp_data b on a.curve_id=b.curve_id and a.as_of_date=b.as_of_date 
			--	 and a.sno_maturity=b.sno_maturity
			

			

	--end new shift----------------------------------------------------------------------------------

		END
		else
			INSERT INTO #curve_matrix(curve_id, term_start, Row_id, as_of_date, curve_value, data_series,sno_as_of_date,sno_maturity)
			SELECT mtm.curve_id, mtm.term_start, mtm.Row_id, mtm.as_of_date, spc.curve_value, mtm.data_series, mtm.sno_as_of_date, mtm.sno_maturity
			FROM #tmp_data mtm
			INNER JOIN source_price_curve spc ON spc.source_curve_def_id = mtm.curve_id  
				AND mtm.term_start = spc.maturity_date 
				AND spc.curve_source_value_id =@price_curve_source
				and mtm.as_of_date = spc.as_of_date 
		--	ORDER BY mtm.curve_id, mtm.term_start, mtm.Row_id



		/*
		@daily_return_data_series:
		1562	Arithmetic Rate of Return
		1563	Geometric Rate of Return
		*/


		INSERT INTO #return_matrix (curve_id, term_start, Row_id, as_of_date, MATRIX_Value) 
		SELECT t1.curve_id, t1.term_start, t2.Row_id, t2.as_of_date,
			CASE t1.data_series
				WHEN 1560 THEN t1.curve_value
				WHEN 1561 THEN t2.curve_value - t1.curve_value
				WHEN 1562 THEN (t2.curve_value - t1.curve_value) / NULLIF(t1.curve_value, 0)
				WHEN 1563 THEN CASE WHEN NULLIF(t2.curve_value / NULLIF(t1.curve_value,0),0)<0 THEN NULL ELSE log(NULLIF(t2.curve_value / NULLIF(t1.curve_value,0),0)) END--log10(t2.curve_value/NULLIF(t1.curve_value,0))
			ELSE 9999
			END curve_value
		FROM #curve_matrix t1 
		INNER JOIN #curve_matrix t2 ON t1.sno_as_of_date = CASE WHEN t1.sno_as_of_date = 1560 THEN t2.sno_as_of_date ELSE t2.sno_as_of_date + 1 END
			AND t1.term_start = t2.term_start 
			AND t1.curve_id = t2.curve_id
    
		--Most recent Volatility taken for each curve	
		INSERT INTO #tmp_volatility_taken (curve_id, term_start, vol_value, volatility_method)
		SELECT rm.curve_id, rm.term_start, CASE WHEN mcmp.volatility_method <> 'e' THEN cv.value ELSE CAST(NULL AS FLOAT) END, mcmp.volatility_method
		FROM (select distinct curve_id,term_start from #return_matrix) rm
		outer apply (
			SELECT MAX(as_of_date) available_date FROM curve_volatility 
				WHERE as_of_date < @as_of_date  AND curve_id = rm.curve_id  AND curve_source_value_id = ISNULL(@volatility_source, @price_curve_source)
		) m_dt
		LEFT JOIN source_price_curve_def spcd ON rm.curve_id = spcd.source_curve_def_id
		LEFT JOIN monte_carlo_model_parameter mcmp ON spcd.monte_carlo_model_parameter_id = mcmp.monte_carlo_model_parameter_id	
		LEFT JOIN curve_volatility cv  ON rm.term_start = cv.term  AND curve_source_value_id = coalesce(@volatility_source,mcmp.volatility_source, @price_curve_source )
			AND cv.as_of_date = m_dt.available_date AND cv.curve_id = rm.curve_id
		
			
		--Storing terms of each curve where volatility value is null
		INSERT INTO #tmp_vol_not_found (curve_id, term_start)
		SELECT curve_id, term_start 
		FROM #tmp_volatility_taken 
		WHERE vol_value IS NULL 
		


		IF (NOT EXISTS(SELECT TOP 1 1 FROM #tmp_vol_not_found) AND NOT EXISTS (SELECT TOP 1 1 FROM #tmp_volatility_taken WHERE volatility_method IN ('x', 'g'))) 
			AND ((SELECT COUNT(DISTINCT(as_of_date)) FROM #as_of_date_point) <>  @data_points)
		BEGIN
			SELECT @error_count = (@data_points - COUNT(DISTINCT(as_of_date))) FROM #as_of_date_point
			INSERT INTO fas_eff_ass_test_run_log(process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
			VALUES(@process_id, 'Error', @module, @source, 'Price_Curve_As_of_Date','Price Curve values not found for ' + CAST(@error_count AS VARCHAR) + ' 
				(out of ' + CAST(@data_points AS VARCHAR) + ') data points from '
				+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN ''
				ELSE 
					'Criteria: ' + @hyperlink + ';'
				END + ' As_of_Date: '+ dbo.FNADateFormat(@as_of_date) + '.','Please check data.')
				
			RAISERROR ('CatchError', 16, 1)
		END 
		
		IF (@calc_option = 'v' OR @calc_option = 'a') 
		BEGIN

			update #as_of_date_point set lambda = (1-mcmp.lambda) * POWER(mcmp.lambda,sno_as_of_date-1) 
			from #as_of_date_point a
			inner JOIN source_price_curve_def spcd ON a.curve_id = spcd.source_curve_def_id 
			inner JOIN monte_carlo_model_parameter mcmp ON mcmp.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
				and mcmp.volatility_method='x'

			SET @st_stmt = '
			INSERT INTO ' + @VolProcessTableName + ' (curve_id, term_start, STDEV_Value)
			SELECT rm.curve_id, rm.term_start, 
				CASE WHEN max(isnull(mcmp.volatility_method,''e'')) = ''x'' THEN 
						SQRT(sum((aod.lambda * POWER((rm.MATRIX_Value-avg_val.avg_value), 2))/nullif(sum_lambda.sum_lambda,0)))
					 WHEN max(isnull(mcmp.volatility_method,''e'')) = ''e'' THEN 
						ISNULL(STDEVP(rm.MATRIX_Value), 0)
					ELSE	 
			 			max(SQRT((vol_gamma * vol_long_run_volatility + vol_beta * POWER(tvt.vol_value, 2) + vol_alpha * POWER(latest_return.MATRIX_Value, 2))))
			 	END STDEV_Value
			FROM #return_matrix rm
			inner join #as_of_date_point aod on '+case when @calc_option not in ('a') then 'rm.curve_id =aod.curve_id' else '1=1' end +' 
				AND rm.as_of_date = aod.as_of_date
			inner JOIN #tmp_volatility_taken tvt ON rm.curve_id = tvt.curve_id
				AND rm.term_start = tvt.term_start
			outer apply (
				select avg(mx.MATRIX_Value) avg_value from #return_matrix mx
				left join  #aod_ignor_status_for_shifting s on '+case when @calc_option not in ('a') then 's.curve_id=mx.curve_id' else '1=1' end +'  
				and s.as_of_date=mx.as_of_date
				where s.ignor_status<>1 and mx.curve_id=rm.curve_id and mx.term_start= rm.term_start
				) avg_val
			outer apply (
				select sum(a.lambda) sum_lambda from #as_of_date_point a
				left join  #aod_ignor_status_for_shifting s1 on s1.curve_id=a.curve_id and s1.as_of_date=a.as_of_date
				where s1.ignor_status<>1 and a.curve_id=rm.curve_id
				) sum_lambda
			outer apply (
				select top(1) a.* from #return_matrix a
				left join  #aod_ignor_status_for_shifting s1 on '+case when @calc_option not in ('a') then 's1.curve_id=a.curve_id' else '1=1' end +'  
				and s1.as_of_date=a.as_of_date
				where s1.ignor_status<>1 and '+case when @calc_option not in ('a') then 'a.curve_id=rm.curve_id' else '1=1' end +'  
				and a.term_start=rm.term_start
				order by a.as_of_date desc
				) latest_return
			left JOIN source_price_curve_def spcd ON rm.curve_id = spcd.source_curve_def_id 
			left JOIN monte_carlo_model_parameter mcmp ON mcmp.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
			left join  #aod_ignor_status_for_shifting s on '+case when @calc_option not in ('a') then 'rm.curve_id=s.curve_id' else '1=1' end +'  
				and rm.as_of_date=s.as_of_date
			where s.ignor_status<>1
			GROUP BY rm.curve_id, rm.term_start'
			exec spa_print @st_stmt
			EXEC (@st_stmt)


		END	
		

		IF (@calc_option = 'd' OR @calc_option = 'a') 
		BEGIN
			SET @st_stmt = '
			INSERT INTO ' + @DriftProcessTableName + ' (curve_id, term_start, AVG_Value)
			SELECT rm.curve_id, rm.term_start, AVG(rm.MATRIX_Value) avg_Value
			FROM #return_matrix rm
			left join  #aod_ignor_status_for_shifting s on '+case when @calc_option not in ('a') then 'rm.curve_id=s.curve_id' else '1=1' end +'   
			and rm.as_of_date=s.as_of_date
			where s.ignor_status<>1
			GROUP BY rm.curve_id, rm.term_start'
			
			exec spa_print @st_stmt
			EXEC (@st_stmt)
		END	    
		    
		IF (@calc_option = 'c' OR @calc_option = 'a') 
		BEGIN
			--IF EXISTS (SELECT * FROM #return_matrix WHERE  MATRIX_Value IS NULL        )
			--BEGIN
			--	INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
			--	SELECT DISTINCT @process_id, 'Error', @module, @source, 'Division_by_ZERO_Return', 'Division by ZERO is found in '
			--		+ CASE @daily_return_data_series
			--			  WHEN 1560 THEN 'Daily Price'
			--			  WHEN 1561 THEN 'Daily Return'
			--			  WHEN 1562 THEN 'Arithmetic Rate of Return'
			--			  WHEN 1563 THEN 'Geometric Rate of Return'
			--		 END + ' Series for '
			--		+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN '' 
			--		ELSE 
			--			'Criteria: ' + @hyperlink + ';'
			--		END + ' As_of_Date:' + dbo.FNADateFormat(as_of_date) + '; Curve_ID:' + spcd.curve_id
			--		+ '; Maturity Date: ' + dbo.FNADateFormat(term_start) + '.', 'Please check data.'
			--	FROM #return_matrix t 
			--	INNER JOIN source_price_curve_def spcd ON t.curve_id = spcd.source_curve_def_id
			--	WHERE MATRIX_Value IS NULL
	            
			--	RAISERROR ('CatchError', 16, 1)
			--END
	
			SELECT X.curve_id X_curve_id, Y.curve_id Y_curve_id, X.term_start X_term_start, Y.term_start Y_term_start INTO #term_correlation
			FROM (SELECT DISTINCT curve_id,term_start FROM #return_matrix) X
			CROSS JOIN(SELECT DISTINCT curve_id,term_start FROM #return_matrix) Y
			WHERE x.term_start = CASE @calculate_for_same_term WHEN 'y' THEN y.term_start ELSE x.term_start END --added for calculate for same terms
	                    
			--## ignore values if matrix multiplication is 0
			SELECT DISTINCT  x.as_of_date,cor.X_curve_id curve_id, cor.Y_curve_id, cor.X_term_start term_start,X.MATRIX_Value
			INTO #ignore_error_values
			FROM  #term_correlation cor 
				INNER JOIN #return_matrix X ON cor.X_curve_id = X.curve_id 
					AND X.term_start = cor.X_term_start
				INNER JOIN #return_matrix Y ON cor.Y_curve_id = Y.curve_id 
					AND Y.term_start = cor.Y_term_start 
					AND x.as_of_date = y.as_of_date
			WHERE X.MATRIX_Value * Y.MATRIX_Value IS  NULL  
			ORDER BY x.as_of_date

			UPDATE #return_matrix
			SET MATRIX_Mean = Mean.mean_curve_value
			FROM #return_matrix MATRIX
			OUTER APPLY 
				(
					SELECT rm.curve_id, rm.term_start, AVG(rm.MATRIX_Value) mean_curve_value
					FROM #return_matrix  rm
					LEFT JOIN #ignore_error_values igv ON igv.curve_id = rm.curve_id
					AND igv.as_of_date =rm.as_of_date
					AND igv.term_start =rm.term_start
					WHERE igv.curve_id IS NULL
					AND rm.curve_id = MATRIX.curve_id  
					AND rm.term_start = MATRIX.term_start
					GROUP BY rm.curve_id, rm.term_start
				) Mean 

	
				SET @st_stmt = '
				INSERT INTO ' + @CorProcessTableName + ' (X_curve_id, Y_curve_id, X_term_start, Y_term_start, Cor_value)
				SELECT cor.X_curve_id, cor.Y_curve_id, cor.X_term_start, cor.Y_term_start, 
					SUM((X.MATRIX_Value - X.MATRIX_Mean) * (Y.MATRIX_Value - Y.MATRIX_Mean)) / NULLIF(SQRT(SUM(SQUARE(X.MATRIX_Value - X.MATRIX_Mean)) * SUM(POWER(Y.MATRIX_Value-Y.MATRIX_Mean,2))), 0) Cor_value
				FROM #term_correlation cor 
				INNER JOIN #return_matrix X ON cor.X_curve_id = X.curve_id 
					AND X.term_start = cor.X_term_start
				INNER JOIN #return_matrix Y ON cor.Y_curve_id = Y.curve_id 
					AND Y.term_start = cor.Y_term_start 
					AND x.as_of_date = y.as_of_date
				left join  #aod_ignor_status_for_shifting s on  X.as_of_date=s.as_of_date
				left join  #aod_ignor_status_for_shifting s1 on   Y.as_of_date=s1.as_of_date
				LEFT JOIN #ignore_error_values igv ON igv.curve_id = X.curve_id 
					AND igv.as_of_date =X.as_of_date
					AND igv.term_start =X.term_start
				where (s.ignor_status<>1 or s1.ignor_status<>1)
				AND igv.curve_id IS NULL
				GROUP BY cor.X_curve_id, cor.Y_curve_id, cor.X_term_start, cor.Y_term_start
				'
			EXEC (@st_stmt)
	        
			SET @st_stmt = '
			INSERT into #tmp_cor (X_curve_id, Y_curve_id, X_term_start, Y_term_start, Cor_value)
			SELECT X_curve_id, Y_curve_id, X_term_start, Y_term_start, Cor_value 
			FROM ' + @CorProcessTableName + ' 
			WHERE Cor_value IS NULL'
	        
			EXEC (@st_stmt)
	        
			IF EXISTS(SELECT 1 FROM #tmp_cor)
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps )
				SELECT DISTINCT @process_id, 'Error', @module, @source, 'Division_by_ZERO_Cor', 'Division by ZERO is found in Correlation for '
					+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN ''
					ELSE 
						'Criteria: ' + @hyperlink + ';'
					END + ' X_Curve_ID:' + spcdx.curve_id + ', Y_Curve_ID:'+ spcdy.curve_id+ '; X_Term: '+ dbo.FNADateFormat(X_term_start)
					+ ',Y_Term: '+ dbo.FNADateFormat(Y_term_start)+ '.','Please check data.'
				FROM #tmp_cor t
				INNER JOIN source_price_curve_def spcdx ON t.x_curve_id = spcdx.source_curve_def_id
				INNER JOIN source_price_curve_def spcdy ON  t.y_curve_id = spcdy.source_curve_def_id
	            
				RAISERROR ('CatchError', 16, 1)
			END
		END 
	  
	  



	    --after saving into process table , now saving into physical table
		-- ------------saving Result  data 
  		BEGIN TRAN
  		--DECLARE @vol_cor_header_id INT
  		IF @calc_option = 'c' OR @calc_option = 'a'
		BEGIN
			SET @st_stmt = '
			DELETE curve_correlation FROM curve_correlation s 
			INNER JOIN source_price_curve_def spcd ON s.curve_id_from = spcd.source_curve_def_id 
			INNER JOIN monte_carlo_model_parameter mcmp ON mcmp.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
				AND s.curve_source_value_id = isnull(mcmp.volatility_source,' + CAST(ISNULL(@volatility_source, @price_curve_source) AS VARCHAR) + ')
			INNER JOIN ' + @CorProcessTableName + ' c ON s.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''' 
				AND s.[curve_id_from] = c.X_curve_id 
				AND s.[curve_id_to] = Y_curve_id 
				AND s.[term1] = c.X_term_start 
				AND s.[term2] = c.Y_term_start'
            
			exec spa_print @st_stmt
			EXEC (@st_stmt)
		END
        
		IF @calc_option = 'v' OR @calc_option = 'a'
		BEGIN
			SET @st_stmt = '
				DELETE [curve_volatility] FROM [curve_volatility] s 
				INNER JOIN source_price_curve_def spcd ON s.curve_id = spcd.source_curve_def_id 
				INNER JOIN monte_carlo_model_parameter mcmp ON mcmp.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
					AND s.curve_source_value_id = isnull(mcmp.volatility_source,' + CAST(ISNULL(@volatility_source, @price_curve_source) AS VARCHAR) + ')
				INNER JOIN ' + @VolProcessTableName + ' v ON s.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''' 
					AND s.[curve_id] = v.curve_id 
					AND s.term = v.term_start'
            
			EXEC (@st_stmt)
		END
        
		IF @calc_option = 'd' OR @calc_option = 'a'
		BEGIN
			SET @st_stmt = '
				DELETE [expected_return] FROM [expected_return] s 
				INNER JOIN source_price_curve_def spcd ON s.curve_id = spcd.source_curve_def_id 
				INNER JOIN monte_carlo_model_parameter mcmp ON mcmp.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
					AND s.curve_source_value_id = isnull(mcmp.volatility_source,' + CAST(ISNULL(@volatility_source, @price_curve_source) AS VARCHAR) + ')
				INNER JOIN ' + @DriftProcessTableName + ' v ON s.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''' 
					AND s.[curve_id] = v.curve_id 
					AND s.term = v.term_start'
				
			exec spa_print @st_stmt
			EXEC (@st_stmt)
		END

		IF @vol_cor_header_id IS NULL
		BEGIN
			INSERT INTO [dbo].[vol_cor_header]
			  (
				[as_of_date],
				var_criteria_id,
				[data_points],
				[curve_source_value_id],
				[daily_return_data_series],
				[vol_calc],
				[cor_calc],
				[create_user],
				[create_ts],
				[update_user],
				[update_ts]
			  )
			VALUES
			  (
				@as_of_date,
				@var_criteria_id,
				@data_points,
				ISNULL(@volatility_source, @price_curve_source),
				@daily_return_data_series,
				CASE 
					 WHEN @calc_option = 'v' OR @calc_option = 'a' THEN 'y'
					 ELSE 'n'
				END,
				CASE 
					 WHEN @calc_option = 'c' OR @calc_option = 'a' THEN 'y'
					 ELSE 'n'
				END,
				dbo.FNADBUser(),
				GETDATE(),
				dbo.FNADBUser(),
				GETDATE()
			  )

			SET @vol_cor_header_id = SCOPE_IDENTITY()	
		END

		IF @calc_option = 'v' OR @calc_option = 'a'
		BEGIN
			SET @st_stmt = '
			INSERT INTO [curve_volatility](vol_cor_header_id, [as_of_date], [curve_id], curve_source_value_id, [term], [value],[create_user], 
				[create_ts], [update_user], [update_ts], granularity)
			SELECT ' + ISNULL(CAST(@vol_cor_header_id AS VARCHAR), 'NULL') + ','''
				+ CAST(@as_of_date AS VARCHAR)
				+ ''',s.curve_id,isnull(mcmp.volatility_source,' + CAST(ISNULL(@volatility_source, @price_curve_source) AS VARCHAR)+ '), term_start, STDEV_Value
			, dbo.FNADBUser() create_usr, GETDATe() create_ts, dbo.FNADBUser() update_usr, GETDATE() update_ts, 700
			FROM ' + @VolProcessTableName+' s
            INNER JOIN source_price_curve_def spcd ON s.curve_id = spcd.source_curve_def_id 
			INNER JOIN monte_carlo_model_parameter mcmp ON mcmp.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
			where STDEV_Value is not null'

			exec spa_print @st_stmt
			EXEC (@st_stmt)
		END
		
		IF @calc_option = 'd' OR @calc_option = 'a'
		BEGIN
			SET @st_stmt = '
			INSERT INTO [expected_return](vol_cor_header_id, [as_of_date], [curve_id], curve_source_value_id, [term], [value], [create_user],
				[create_ts], [update_user], [update_ts], granularity)
			SELECT ' + ISNULL(CAST(@vol_cor_header_id AS VARCHAR), 'NULL') + ','''
				+ CAST(@as_of_date AS VARCHAR)
				+ ''',s.curve_id,
				isnull(mcmp.volatility_source,' + CAST(ISNULL(@volatility_source, @price_curve_source) AS VARCHAR)
				+ '),term_start,avg_Value
			, dbo.FNADBUser() create_usr, GETDATE() create_ts, dbo.FNADBUser() update_usr, GETDATE() update_ts, 700
			FROM ' + @DriftProcessTableName +' s
			INNER JOIN source_price_curve_def spcd ON s.curve_id = spcd.source_curve_def_id 
			INNER JOIN monte_carlo_model_parameter mcmp ON mcmp.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
			'
            
			exec spa_print @st_stmt
			EXEC (@st_stmt)
		END
        
		IF @calc_option = 'c' OR @calc_option = 'a'
		BEGIN
			SET @st_stmt = '
			INSERT INTO [dbo].[curve_correlation]
				   ([vol_cor_header_id]
				   ,[as_of_date]
				   ,[curve_id_from]
				   ,[curve_id_to]
				   ,[term1]
				   ,[term2]
				   ,[curve_source_value_id]
				   ,[value]
				   ,[create_user]
				   ,[create_ts]
				   ,[update_user]
				   ,[update_ts])
			 SELECT '
				+ ISNULL(CAST(@vol_cor_header_id AS VARCHAR), 'NULL') + ','''
				+ CAST(@as_of_date AS VARCHAR)
				+ ''',X_curve_id
					 ,Y_curve_id 
					,X_term_start 
					,Y_term_start
					, isnull(mcmp.volatility_source,' + CAST(ISNULL(@volatility_source, @price_curve_source) AS VARCHAR)+')
					,Cor_value
				   , dbo.FNADBUser()
					,GETDATE()
					,dbo.FNADBUser()
					,GETDATE()
			FROM ' + @CorProcessTableName +' s
			INNER JOIN source_price_curve_def spcd ON s.X_curve_id = spcd.source_curve_def_id 
			INNER JOIN monte_carlo_model_parameter mcmp ON mcmp.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
			'
            exec spa_print @st_stmt
            
			EXEC (@st_stmt)
		END
	        
		COMMIT TRAN
		 ------end saving data into physical table
	END
	ELSE  --taking existing data into process table (calling from VaR Calculation)
	BEGIN
		DECLARE @as_of_date_rec DATETIME

		SET @st_stmt = 'DELETE ' + @VolProcessTableName
		EXEC (@st_stmt)
	    
	    -- updated for risk bucket mapping logic
		CREATE TABLE #tmpcor([curve_id_from] INT, [curve_id_to] INT, [term1] DATETIME, [term2] DATETIME, cv_value FLOAT, is_mapped INT,
			 cv_shift_value FLOAT, quarterly DATETIME, quarterly2 DATETIME,semi_annually DATETIME, semi_annually2 DATETIME, annually DATETIME, vol_cor_term DATETIME)
		SET @st_stmt = '
			INSERT INTO #tmpcor([curve_id_from], [term1], cv_value, is_mapped) 
			SELECT 
				CASE WHEN ISNULL(m.is_mapped, 0) = 1 THEN 
					m.curve_id
				ELSE 
					ISNULL(risk_spcd.source_curve_def_id, m.curve_id)
				END,
				m.term_start, NULL, m.is_mapped FROM ' + @MTMProcessTableName + ' m 
			LEFT JOIN source_price_curve_def spcd ON m.curve_id = spcd.source_curve_def_id 
			LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
				AND spcd.risk_bucket_id IS NOT NULL'
	    
		exec spa_print @st_stmt
		EXEC (@st_stmt)

		--SELECT term1 monthly,
		UPDATE tc SET
			quarterly = 
		--SELECT
			CASE  
				WHEN DATEPART(QUARTER, term1) = 1 THEN DATEADD(yy, DATEDIFF(yy, 0, term1), 0) 
				WHEN DATEPART(QUARTER, term1) = 2 THEN DATEADD(MM, 3, DATEADD(yy, DATEDIFF(yy, 0, term1), 0)) 
				WHEN DATEPART(QUARTER, term1) = 3 THEN DATEADD(MM, 6, DATEADD(yy, DATEDIFF(yy, 0, term1), 0)) 
				WHEN DATEPART(QUARTER, term1) = 4 THEN DATEADD(MM, 9, DATEADD(yy, DATEDIFF(yy, 0, term1), 0)) 
			END,
			semi_annually =
			CASE WHEN DATEPART(MONTH, term1) < 7 THEN
				DATEADD(yy, DATEDIFF(yy, 0, term1), 0)
			ELSE
				DATEADD(MM, 6, DATEADD(yy, DATEDIFF(yy, 0, term1), 0))
			END,
			annually = 
			DATEADD(yy, DATEDIFF(yy, 0, term1), 0)
		FROM #tmpcor tc
	    
		------------------------start Taking Volatility---------------------------------------------
		 --updated for riskbucket mapping logic
		UPDATE #tmpcor
		SET cv_value = cv.[value]/SQRT(CASE cv.granularity	
				WHEN 706	THEN 252 --	Annually
				WHEN 700	THEN 1 --	Daily
				WHEN 703	THEN 21--	Monthly
				WHEN 704	THEN 63 --	Quarterly
				WHEN 705	THEN 126 --	Semi-annually
				WHEN 701	THEN 5 --	Weekly
				ELSE 1 END),
			cv_shift_value =
			(
			CASE WHEN ISNULL(tt.is_mapped, 0) = 1 THEN
				(
				CASE WHEN tt.shift_by = 'v' THEN (cv.[value] + (tt.shift_value))
					ELSE (cv.[value] * (1 + tt.shift_value / 100)) 
				END
				)	    
				ELSE cv.[value] 
			END
			)/SQRT(CASE cv.granularity	
		WHEN 706	THEN 252 --	Annually
		WHEN 700	THEN 1 --	Daily
		WHEN 703	THEN 21--	Monthly
		WHEN 704	THEN 63 --	Quarterly
		WHEN 705	THEN 126 --	Semi-annually
		WHEN 701	THEN 5 --	Weekly
		ELSE 1 END),
		vol_cor_term = CASE spcd.granularity
							WHEN  991 THEN t.quarterly
							WHEN  992 THEN t.semi_annually
							WHEN  993 THEN t.annually
						ELSE t.term1 END
		FROM #tmpcor t
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = t.curve_id_from
		INNER JOIN [curve_volatility] cv ON  cv.term = CASE spcd.granularity
															WHEN  991 THEN t.quarterly
															WHEN  992 THEN t.semi_annually
															WHEN  993 THEN t.annually
														ELSE t.term1 END
			AND cv.curve_id = t.curve_id_from
			AND cv.curve_source_value_id = ISNULL(@volatility_source, @price_curve_source)
		INNER JOIN(
	   			SELECT MAX(
				CASE 
					WHEN @vol_cor = 'd' THEN @as_of_date --same as_of_date value
					ELSE s.[as_of_date] ---most recent
				END) [as_of_date]
				FROM [curve_volatility] s
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = s.curve_id
				INNER JOIN #tmpcor t ON s.term = CASE spcd.granularity
															WHEN  991 THEN t.quarterly
															WHEN  992 THEN t.semi_annually
															WHEN  993 THEN t.annually
														ELSE t.term1 END
					AND s.curve_id = t.curve_id_from
					AND s.as_of_date <= @as_of_date
					AND s.curve_source_value_id = ISNULL(@volatility_source, @price_curve_source)) mx ON cv.as_of_date = mx.as_of_date  
		LEFT JOIN(
				SELECT distinct ty.curve_id,
					   ty.shift_by,
					   ty.shift_value,
					   ty.risk_bucket_map,
					   ty.is_mapped, 
					   ty.map_term_start
				FROM   #tmp_term ty
				WHERE  ty.is_mapped = 1) tt ON tt.map_term_start = t.term1
		
		IF EXISTS (SELECT 1 FROM #tmpcor WHERE cv_value IS NULL)
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
			SELECT DISTINCT @process_id,'Error',@module,@source,'Vol_Value','Volatility Value is not found '
				+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN '' 
				ELSE 
					'Criteria: '+ @hyperlink + ';'
				END + ' for as_of date:' + dbo.FNADateFormat(@as_of_date)+ '; Curve_ID:' + spcdx.curve_id + '; Term: ' + 
				dbo.FNADateFormat(t.term1) + '.', 'Please check data.'
			FROM #tmpcor t
			INNER JOIN source_price_curve_def spcdx ON t.curve_id_from = spcdx.source_curve_def_id
			WHERE t.cv_value IS NULL
	        
			RAISERROR ('CatchError', 16, 1)
		END
	    	    
		SET @st_stmt = '
			INSERT INTO ' + @VolProcessTableName + ' (curve_id, term_start, STDEV_Value, STDEV_Value_shift)
			SELECT curve_id_from, term1, cv_value, cv_shift_value FROM #tmpcor'
	    
		exec spa_print @st_stmt
		EXEC (@st_stmt)

		--------------------------end Taking Volatility---------------------------------------------
		--------------------------start Taking Drift---------------------------------------------
		UPDATE #tmpcor
		SET cv_value = NULL
		
		-- updated for riskbucket mapping logic
		UPDATE #tmpcor
		SET cv_value = cv.[value]/(CASE cv.granularity
				WHEN 706	THEN 252 --	Annually
				WHEN 700	THEN 1 --	Daily
				WHEN 703	THEN 21--	Monthly
				WHEN 704	THEN 63 --	Quarterly
				WHEN 705	THEN 126 --	Semi-annually
				WHEN 701	THEN 5 --	Weekly
				ELSE 1 END),
			cv_shift_value = 
			(
			CASE WHEN isnull(tt.is_mapped, 0) = 1 THEN
				(
				CASE WHEN tt.shift_by = 'v' THEN (cv.[value] + (tt.shift_value))
					ELSE (cv.[value] * (1 + tt.shift_value / 100))
				END
				)	    
				ELSE cv.[value] 
			END
			)/(CASE cv.granularity
		WHEN 706	THEN 252 --	Annually
		WHEN 700	THEN 1 --	Daily
		WHEN 703	THEN 21--	Monthly
		WHEN 704	THEN 63 --	Quarterly
		WHEN 705	THEN 126 --	Semi-annually
		WHEN 701	THEN 5 --	Weekly
		ELSE 1 END),
		vol_cor_term = CASE spcd.granularity
							WHEN  991 THEN t.quarterly
							WHEN  992 THEN t.semi_annually
							WHEN  993 THEN t.annually
						ELSE t.term1 END
		FROM #tmpcor t
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = t.curve_id_from
		INNER JOIN [expected_return] cv ON  cv.term = CASE spcd.granularity
															WHEN  991 THEN t.quarterly
															WHEN  992 THEN t.semi_annually
															WHEN  993 THEN t.annually
														ELSE t.term1 END
			AND cv.curve_id = t.curve_id_from
			AND cv.curve_source_value_id = ISNULL(@volatility_source, @price_curve_source)
		INNER JOIN(
				SELECT MAX(
					CASE WHEN @vol_cor = 'd' THEN 
						@as_of_date --same as_of_date value
					ELSE 
						s.[as_of_date] ---most recent
					END
					) [as_of_date]
				FROM [expected_return] s 
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = s.curve_id
				INNER JOIN #tmpcor t ON  s.term = CASE spcd.granularity
														WHEN  991 THEN t.quarterly
														WHEN  992 THEN t.semi_annually
														WHEN  993 THEN t.annually
													ELSE t.term1 END
					AND s.curve_id = t.curve_id_from
					AND s.as_of_date <= @as_of_date
					AND s.curve_source_value_id = ISNULL(@volatility_source, @price_curve_source)) mx ON cv.as_of_date = mx.as_of_date 
		LEFT JOIN(
				SELECT distinct ty.curve_id,
					   ty.shift_by,
					   ty.shift_value,
					   ty.risk_bucket_map,
					   ty.is_mapped,
					   ty.map_term_start
				FROM   #tmp_term ty
				WHERE  ty.is_mapped = 1) tt ON tt.map_term_start = t.term1

	  --  IF EXISTS (SELECT * FROM #tmpcor WHERE cv_value IS NULL)
	  --  BEGIN
	  --      INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
	  --      SELECT DISTINCT @process_id,'Error',@module,@source,'Drift_Value','Drift Value is NOT found '
			--	+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink + ';'
			--	END + ' for as_of date:' + dbo.FNADateFormat(@as_of_date)+ '; Curve_ID:' + spcdx.curve_id + '; Term: ' + dbo.FNADateFormat(t.term1) + '.','Please check data.'
			--FROM #tmpcor t
			--INNER JOIN source_price_curve_def spcdx	ON  t.curve_id_from = spcdx.source_curve_def_id
			--WHERE t.cv_value IS NULL
	        
	  --      RAISERROR ('CatchError', 16, 1)
	  --  END
	    	    
		SET @st_stmt = '
			INSERT INTO ' + @DriftProcessTableName + ' (curve_id, term_start, AVG_Value, AVG_Value_shift)
			SELECT curve_id_from, term1, cv_value, cv_shift_value FROM #tmpcor'
	    
		exec spa_print @st_stmt
		EXEC (@st_stmt)
	    
		--------------------------end Taking Drift---------------------------------------------
   		--------------------------start Taking Correlation---------------------------------------------
	    
		DELETE #tmpcor
	    
		SET @st_stmt = 'DELETE ' + @CorProcessTableName
		EXEC(@st_stmt)
	    
		SET @st_stmt = '
			INSERT INTO #tmpcor ([curve_id_from], [curve_id_to], [term1], [term2], cv_value, is_mapped)
			SELECT a.curve_id [curve_id_from], b.curve_id [curve_id_to], a.term_start [term1], b.term_start [term2], NULL, a.is_mapped
			FROM(
				SELECT ISNULL(risk_spcd.source_curve_def_id, m.curve_id) curve_id, m.term_start, m.is_mapped 
				FROM ' + @MTMProcessTableName + ' m 
				LEFT JOIN source_price_curve_def spcd ON m.curve_id = spcd.source_curve_def_id 
				LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
					AND spcd.risk_bucket_id IS NOT NULL
				) a 
			CROSS JOIN 
			(
			SELECT ISNULL(risk_spcd.source_curve_def_id, m.curve_id) curve_id, m.term_start 
			FROM ' + @MTMProcessTableName + ' m 
			LEFT JOIN source_price_curve_def spcd ON m.curve_id = spcd.source_curve_def_id 
			LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
				AND spcd.risk_bucket_id IS NOT NULL ) b'
	    
		EXEC (@st_stmt)
		-- updated for riskbucket mapping logic
		
		UPDATE tc SET
			quarterly = 
			CASE  
				WHEN DATEPART(QUARTER, term1) = 1 THEN DATEADD(yy, DATEDIFF(yy, 0, term1), 0) 
				WHEN DATEPART(QUARTER, term1) = 2 THEN DATEADD(MM, 3, DATEADD(yy, DATEDIFF(yy, 0, term1), 0)) 
				WHEN DATEPART(QUARTER, term1) = 3 THEN DATEADD(MM, 6, DATEADD(yy, DATEDIFF(yy, 0, term1), 0)) 
				WHEN DATEPART(QUARTER, term1) = 4 THEN DATEADD(MM, 9, DATEADD(yy, DATEDIFF(yy, 0, term1), 0)) 
			END,
			quarterly2 = 
			CASE  
				WHEN DATEPART(QUARTER, term2) = 1 THEN DATEADD(yy, DATEDIFF(yy, 0, term2), 0) 
				WHEN DATEPART(QUARTER, term2) = 2 THEN DATEADD(MM, 3, DATEADD(yy, DATEDIFF(yy, 0, term2), 0)) 
				WHEN DATEPART(QUARTER, term2) = 3 THEN DATEADD(MM, 6, DATEADD(yy, DATEDIFF(yy, 0, term2), 0)) 
				WHEN DATEPART(QUARTER, term2) = 4 THEN DATEADD(MM, 9, DATEADD(yy, DATEDIFF(yy, 0, term2), 0)) 
			END,
			semi_annually =
			CASE WHEN DATEPART(MONTH, term1) < 7 THEN
				DATEADD(yy, DATEDIFF(yy, 0, term1), 0)
			ELSE
				DATEADD(MM, 6, DATEADD(yy, DATEDIFF(yy, 0, term1), 0))
			END,
			semi_annually2 =
			CASE WHEN DATEPART(MONTH, term2) < 7 THEN
				DATEADD(yy, DATEDIFF(yy, 0, term2), 0)
			ELSE
				DATEADD(MM, 6, DATEADD(yy, DATEDIFF(yy, 0, term2), 0))
			END
		FROM #tmpcor tc

		UPDATE #tmpcor SET cv_value = cc.[value],
		cv_shift_value =
			CASE WHEN isnull(tt.is_mapped, 0) = 1 THEN
					(
					CASE WHEN (
						CASE WHEN tt.shift_by = 'v' THEN (cc.[value] + (tt.shift_value))
							ELSE (cc.[value] * (1 + tt.shift_value/100)) 
						END) < -1 THEN -1 
					WHEN(
						CASE WHEN tt.shift_by = 'v' THEN (cc.[value] + (tt.shift_value))
							ELSE (cc.[value] * (1 + tt.shift_value/100)) 
						END) > 1 THEN 1
					ELSE (
						CASE WHEN tt.shift_by = 'v' THEN (cc.[value] + (tt.shift_value))
							ELSE (cc.[value] * (1 + tt.shift_value/100)) 
						END
						)						
					END
					)	    
				ELSE cc.[value]
			END
		FROM #tmpcor t 
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = t.curve_id_from
		INNER JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = t.curve_id_to
		INNER JOIN [curve_correlation] cc ON cc.term1 = 
			CASE spcd.granularity 
				WHEN  991 THEN t.quarterly
				WHEN  992 THEN t.semi_annually
				WHEN 993 THEN REPLACE(cc.term1, YEAR(cc.term1), YEAR(t.term1))
				ELSE t.term1
			END
			AND cc.term2 = CASE spcd1.granularity 
								WHEN  991 THEN t.quarterly2
								WHEN  992 THEN t.semi_annually2
								WHEN 993 THEN REPLACE(cc.term2, YEAR(cc.term2), YEAR(t.term2))
								ELSE t.term2
							END
			AND cc.[curve_id_from] = t.[curve_id_from]
			AND cc.[curve_id_to] = t.[curve_id_to]
			AND cc.curve_source_value_id = ISNULL(@volatility_source, @price_curve_source)
		INNER JOIN(
			SELECT TOP 1 (CASE WHEN @vol_cor = 'd' THEN @as_of_date ELSE s.[as_of_date]  END ) [as_of_date]
			FROM #tmpcor t
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = t.curve_id_from
			INNER JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = t.curve_id_to
			INNER JOIN [curve_correlation] s ON s.[curve_id_from] = t.[curve_id_from]
				AND s.[curve_id_to] = t.[curve_id_to]
				AND s.as_of_date <= @as_of_date
				AND s.curve_source_value_id = ISNULL(@volatility_source, @price_curve_source) 
				AND s.term1 = 
				CASE spcd.granularity 
					WHEN  991 THEN t.quarterly
					WHEN  992 THEN t.semi_annually
					WHEN 993 THEN REPLACE(s.term1, YEAR(s.term1), YEAR(t.term1))
					ELSE t.term1 END
				AND s.term2 = CASE spcd1.granularity
						WHEN  991 THEN t.quarterly2
						WHEN  992 THEN t.semi_annually2
						WHEN 993 THEN REPLACE(s.term2, YEAR(s.term2), YEAR(t.term2))
						ELSE t.term2 END
				ORDER BY s.[as_of_date] DESC
					) mx ON cc.as_of_date = mx.as_of_date 
		LEFT JOIN(
				SELECT DISTINCT ty.curve_id,
				   ty.shift_by,
				   ty.shift_value,
				   ty.risk_bucket_map,
				   ty.is_mapped,
				   ty.map_term_start
				FROM #tmp_term ty
				WHERE ty.is_mapped = 1) tt ON tt.map_term_start = t.term1 OR tt.map_term_start = t.term2
	    
	  --SELECT *  into adiha_process.dbo.aaa FROM #tmpcor
		IF EXISTS(SELECT 1 FROM #tmpcor WHERE cv_value IS NULL)
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log(process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)
			SELECT DISTINCT @process_id, 'Error', @module, @source, 'Cor_Value', 'Correlation value is not found for '
				+ CASE WHEN @name IS NULL OR @var_criteria_id IS NULL THEN ''   
				ELSE 
					'Criteria: ' + @hyperlink  + ';'
				 END + ' as_of_date:' + dbo.FNADateFormat(@as_of_date) + ', X_Curve_ID:' + spcdx.curve_id + ', Y_Curve_ID:' + 
				 spcdy.curve_id+ '; X_Term: '+ dbo.FNADateFormat(term1) + ',Y_Term: '+ dbo.FNADateFormat(term2) + '.', 'Please check data.'
			FROM #tmpcor t 
			INNER JOIN source_price_curve_def spcdx ON t.curve_id_from = spcdx.source_curve_def_id
			INNER JOIN source_price_curve_def spcdy ON t.curve_id_to = spcdy.source_curve_def_id
			WHERE t.cv_value IS NULL
			
			RAISERROR ('CatchError', 16, 1)
		END
	    
		SET @st_stmt = '
		INSERT INTO ' + @CorProcessTableName + ' (X_curve_id, Y_curve_id, X_term_start, Y_term_start, Cor_value, Cor_value_shift)
		SELECT [curve_id_from], [curve_id_to], [term1], [term2],  cv_value,  cv_shift_value FROM #tmpcor'
	    
		exec spa_print @st_stmt
		EXEC (@st_stmt)
		--------------------------end Taking Correlation---------------------------------------------
	END
	
	EXEC spa_print 'finish'
	SET @desc = 'Volatility/Correlation Calculation process is completed for '
	    + dbo.FNAUserDateFormat(@as_of_date, @user_name) + '.'
	
	SET @errorcode = 's'
	SET @url = ''
		
	EXEC spa_print @process_id
	-------------------END error Trapping--------------------------------------------------------------------------
END TRY

BEGIN CATCH
	EXEC spa_print 'Catch Error'
	IF @calc_only_vol_cor = 'y'
	BEGIN
	    IF @@TRANCOUNT > 0
	        ROLLBACK
	END
	
	EXEC spa_print @process_id
	
	EXEC spa_print 'SELECT * FROM fas_eff_ass_test_run_log WHERE process_id = ''', @process_id, ''''
	SET @errorcode = 'e'
	IF ERROR_MESSAGE() = 'CatchError'
	BEGIN
	    SET @desc = 'Volatility/Correlation Calculation process has been run for '
	        + dbo.FNAUserDateFormat(@as_of_date, @user_name)
	        + ' (ERRORS found).'
	    
	    EXEC spa_print @desc
	END
	ELSE
	BEGIN
	    SET @desc = 'Volatility/Correlation Calculation critical error found ( Error Description:'
	        + ERROR_MESSAGE() + '; Line no: '
	        + CAST(ERROR_LINE() AS VARCHAR) + ').'
	    
	    EXEC spa_print @desc
	END
	
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name
	       + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id
	       + ''',''y'''
END CATCH

SET @url_desc = '' 
IF @errorcode = 'e'
BEGIN
    SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc
           + '.</a>'
    
    SET @url_desc = '<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''
        + @process_id + '''">Click here...</a>'
    
    IF @return_output = 1 
	BEGIN
		IF @calc_only_vol_cor = 'y'
			IF OBJECT_ID('tempdb..#tmp_result_calc_vol_cor_job') IS NOT NULL 
				INSERT INTO #tmp_result_calc_vol_cor_job
				SELECT 'Error' ErrorCode,
					   'Calculate vol_cor' MODULE,
					   'spa_calc_vol_cor' Area,
						--'DB Error' STATUS,
					   'Technical Error' STATUS,
					   'Volatility/Correlation Calculation process has been run with error, Please view this report. '
					   + @url_desc MESSAGE,
					   '' Recommendation
			ELSE
				SELECT 'Error' ErrorCode,
				   'Calculate vol_cor' MODULE,
				   'spa_calc_vol_cor' Area,
				   'Technical Error' STATUS,
				   'Volatility/Correlation Calculation process has been run with error, Please view this report. '
				   + @url_desc MESSAGE,
				   '' Recommendation
		ELSE
		BEGIN
			IF OBJECT_ID('tempdb..#matrix_covar') IS NOT NULL
				INSERT INTO #matrix_covar(X_curve_id)
				SELECT -1
			ELSE
				SELECT -1
		END
	END
END
ELSE
BEGIN
	IF @return_output = 1
	BEGIN
		IF @calc_only_vol_cor = 'y'
			IF OBJECT_ID('tempdb..#tmp_result_calc_vol_cor_job') IS NOT NULL 
				INSERT INTO #tmp_result_calc_vol_cor_job
				EXEC spa_ErrorHandler 0,
					 'Volatility/Correlation Calculation',
					 'Vol_Cor_Calculation',
					 'Success',
					 @desc,
					 ''
			ELSE
				EXEC spa_ErrorHandler 0,
						'Volatility/Correlation Calculation',
						'Vol_Cor_Calculation',
						'Success',
						@desc,
							''
		ELSE
		BEGIN
			IF OBJECT_ID('tempdb..#matrix_covar') IS NOT NULL
				INSERT INTO #matrix_covar(X_curve_id)
				SELECT 0
			ELSE
				SELECT 0
		END
	END
END

--DECLARE @temptablequery VARCHAR(500)
--IF @errorcode = 'e'
--    SET @temptablequery = 'EXEC ' + DB_NAME() + '.dbo.spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''
--ELSE
--    SET @temptablequery = NULL

IF @calc_only_vol_cor = 'y'
EXEC spa_message_board 'u',
	 @user_name,
	 NULL,
	 'Calc Volatility Correlation',
	 @desc,
	 '',
	 '',
	 @errorcode,
	 @batch_process_id,
	 NULL,
	 @batch_process_id,
     NULL,
	 'n'--,
     --@temptablequery,
     --'y'
