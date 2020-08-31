IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.[spa_calc_VAR_job]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.[spa_calc_VAR_job]
GO
/**
	Calculate Value at Risk(VaR) using Variance/Covariance Approach

	Parameters :
	@as_of_date : Date for processing
	@var_criteria_id : Criteria ID to process the calculation
	@term_start : Term Start filter to process 
	@term_end : Term End filter to process
	@whatif_criteria_id : WhatIf Criteria ID to process the calculation
	@calc_type : Calculation Type - 'r' - 'At Risk', 'w' - 'What If'
	@tbl_name : Provide table which holds deals to process
	@measurement_approach : Approach to use in the calculation as defined in the static data
							1520 - Variance/Covariance Approach
	@conf_interval : Percentage for the calculation as defined in the static data
						1502 - 99%, 1503 - 90%, 1504 - 95%
	@hold_period : Integer value to multiply processed value using square root
	@process_id : To run calculation using provided process id						
	@job_name : Job name to Create
	@batch_process_id : Process id when run through batch
	@batch_report_param	: Paramater to run through batch

**/
CREATE PROC dbo.spa_calc_VAR_job 
	@as_of_date DATETIME,
	@var_criteria_id INT,
	@term_start VARCHAR(25)=NULL,
	@term_end VARCHAR(25)=NULL,
	@whatif_criteria_id INT = NULL,
	@calc_type VARCHAR(1) = 'r',
	@tbl_name VARCHAR(200) = NULL,
	@measurement_approach INT = NULL,
	@conf_interval INT = NULL,
	@hold_period INT = NULL,
	@process_id VARCHAR(50) = NULL,
	@job_name VARCHAR(100) = NULL,
	@return_output BIT = 1,
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param	VARCHAR(5000) = NULL
AS
-------------------------Test Start------------------------------------------------
/*
declare	@as_of_date datetime,@var_criteria_id int,@process_id varchar(50),@job_name varchar(100),    @whatif_criteria_id int,
    @calc_type varchar(1) ,
    @tbl_name varchar(200)=null,@measurement_approach INT,@conf_interval INT,@hold_period INT

SET @as_of_date='2011-6-22'
SET @var_criteria_id=2
SET @process_id='ooo'
SET @job_name='wswsss'
select   @whatif_criteria_id =101, @calc_type = 'w',    @tbl_name ='adiha_process.dbo.WhatIfSample'
select @measurement_approach =1520,@conf_interval =1500,@hold_period =3
--select   @whatif_criteria_id =null, @calc_type = 'r',    @tbl_name =null
--select @measurement_approach =null,@conf_interval =null,@hold_period =null

DROP TABLE #matrix_covar
DROP TABLE #product_covar_mtm
DROP TABLE #result_value

--/*
If @calc_type = 'w'
BEGIN
	drop table adiha_process.dbo.WhatIfSample
	CREATE TABLE adiha_process.dbo.WhatIfSample
	(
		real_deal varchar(1), -- 'y' is existing deal and 'n' non existing deal
		source_deal_header_id INT, --FOR EXISTING DEAL
		counterparty_id INT,
		buy_index INT, 
		buy_price FLOAT,
		buy_volume FLOAT,
		buy_UOM INT, 
		buy_term_start DATETIME,
		buy_end_start DATETIME,
		sell_index INT, 
		sell_price FLOAT,
		sell_volume FLOAT,
		sell_UOM INT, 
		sell_term_start DATETIME,
		sell_end_start DATETIME
	)

	insert into adiha_process.dbo.WhatIfSample(real_deal, source_deal_header_id)
	select 'y', 1234 UNION
	select 'y', 1235  UNION
	select 'y', 1239  
END

--*/
--*/
--------------------------end test--------------------------------------------------------
--declare @whatif_criteria_id int,@calc_type varchar(1),@tbl_name varchar(200)

DECLARE @user_name VARCHAR(50)
SET @user_name = dbo.fnadbuser()
DECLARE @url        VARCHAR(500)
DECLARE @desc       VARCHAR(500)
DECLARE @desc1       VARCHAR(500)
DECLARE @errorMsg   VARCHAR(200)
DECLARE @errorcode  VARCHAR(1)
DECLARE @url_desc   VARCHAR(500), @tenor_type CHAR(1)

SET @url = ''
SET @desc = ''
SET @errorMsg = ''
SET @errorcode = 'e'
SET @url_desc = ''

IF @process_id IS NULL
    SET @process_id = REPLACE(NEWID(), '-', '_')

DECLARE @st_sql               VARCHAR(MAX)


DECLARE @VolProcessTableName  VARCHAR(200)
DECLARE @CorProcessTableName  VARCHAR(200)
DECLARE @MTMProcessTableName  VARCHAR(200)
DECLARE @MTMProcessTableNameNew  VARCHAR(200)

SET @VolProcessTableName = dbo.FNAProcessTableName('Volatility', @user_name, @process_id)
SET @CorProcessTableName = dbo.FNAProcessTableName('Correlation', @user_name, @process_id)
SET @MTMProcessTableName = dbo.FNAProcessTableName('MTM', @user_name, @process_id)
SET @MTMProcessTableNameNew = dbo.FNAProcessTableName('MTM_new', @user_name, @process_id)

DECLARE @temptablequery VARCHAR(500)

BEGIN TRY
	-- var Criteria
	DECLARE @name                               VARCHAR(200),
	        @what_if                            VARCHAR(1),
	        @category                           INT,
	        @source_system_book_id1             INT,
	        @source_system_book_id2             INT,
	        @source_system_book_id3             INT,
	        @source_system_book_id4             INT,
	        @role                               INT,
	        @trader                             INT,
	        @use_values                         INT,
	        @include_hypothetical_transactions  VARCHAR(1),
	        @include_options_delta              VARCHAR(1),
	        @include_options_gamma              VARCHAR(1),
	        @include_options_notional           VARCHAR(1),
	        @market_credit_correlation          FLOAT,
	        @var_approach                       INT,
	        @start_date                         DATETIME,
	        @simulation_days                    INT,
	        @confidence_interval                INT,
	        @holding_period                     INT,
	        @price_curve_source                 INT,
	        @daily_return_data_series           INT,
	        @data_points                        INT,
	        @active                             VARCHAR(1),
	        @vol_cor                            VARCHAR(1),
	        @fas_book_id                        VARCHAR(500),
	        @calc_vol_cor                       VARCHAR(1),
	        @function_id						INT = NULL,
			@criteria							INT = NULL,
			@source								VARCHAR(100) = NULL,
			@tenor_from							VARCHAR(10) = NULL, 
			@tenor_to							VARCHAR(10) = NULL
	
	SELECT  @calc_vol_cor='n', @data_points = 30, @what_if = 'n'
	
	SELECT @name = 'VaR',
	       @what_if = 'n',
	       @category = NULL,
	       @source_system_book_id1 = NULL,
	       @source_system_book_id2 = NULL,
	       @source_system_book_id3 = NULL,
	       @source_system_book_id4 = NULL,
	       @role = NULL,
	       @trader = NULL,
	       @use_values = NULL,
	       @include_hypothetical_transactions = 'n',
	       @include_options_delta = 'n',
	       @include_options_gamma = 'n',
	       @include_options_notional = 'n',
	       @market_credit_correlation = NULL,
	       @var_approach = @measurement_approach,
	       @start_date = NULL,
	       @simulation_days = 30,
	       @confidence_interval = @conf_interval,
	       @holding_period = ISNULL(@hold_period, 1),
	       @price_curve_source = 4500,
	       @daily_return_data_series = 1560,
	       @data_points = 30,
	       @active = 'y',
	       @vol_cor = 'v',
	       @fas_book_id = NULL,
	       @calc_vol_cor = 'n'
	       
	
	
	IF @calc_type = 'w'
	BEGIN
		IF @whatif_criteria_id IS NOT NULL
	    BEGIN
	    	SELECT 
	    		@name = [criteria_name],
	    		@criteria = @whatif_criteria_id,
	    		@function_id = 10183400,
	    		@source = 'What If Process',
	    		@tenor_type = CASE WHEN pmt.fixed_term = 1 THEN 'f' WHEN pmt.relative_term = 1 THEN 'r' ELSE 'f' END,
	    		@tenor_from = pmt.starting_month,
	    		@tenor_to = pmt.no_of_month,
	    		@term_start = pmt.term_start,
	    		@term_end = pmt.term_end
	    	FROM maintain_whatif_criteria mwc
	    	LEFT JOIN portfolio_mapping_source pms ON pms.mapping_source_usage_id = mwc.criteria_id
				AND pms.mapping_source_value_id = 23201
			LEFT JOIN portfolio_mapping_tenor pmt ON pmt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id 
			WHERE criteria_id = @whatif_criteria_id	
	    END		
	END
	ELSE
	BEGIN
		IF @var_criteria_id IS NOT NULL
		BEGIN
			SELECT @name = [name],
				@category = category,
				@trader = trader,
				@include_options_delta = include_options_delta,
				@include_options_notional = include_options_notional,
				@market_credit_correlation = market_credit_correlation,
				@var_approach = var_approach,
				@simulation_days = simulation_days,
				@confidence_interval = confidence_interval,
				@holding_period = ISNULL(holding_period, 1),
				@price_curve_source = price_curve_source,
				@daily_return_data_series = daily_return_data_series,
				@active = ACTIVE,
				@vol_cor = vol_cor,
				@criteria = @var_criteria_id,
				@function_id = 10181200,
				@source = 'VaR_Calculation',
				@tenor_type = CASE WHEN pmt.fixed_term = 1 THEN 'f' WHEN pmt.relative_term = 1 THEN 'r' ELSE 'f' END,
	    		@tenor_from = pmt.starting_month,
	    		@tenor_to = pmt.no_of_month,
				@term_start = pmt.term_start,
	    		@term_end = pmt.term_end
			FROM   [dbo].[var_measurement_criteria_detail] vmcd
			LEFT JOIN portfolio_mapping_source pms ON pms.mapping_source_usage_id = vmcd.id
				AND pms.mapping_source_value_id = 23203
			LEFT JOIN portfolio_mapping_tenor pmt ON pmt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
			WHERE  id = @var_criteria_id
	    END
	END 
	
	DECLARE @hyperlink VARCHAR(500)
	SET @hyperlink = @name --dbo.FNATRMWinHyperlink('a', @function_id, @name, @criteria,null,null,null,null,null,null,null,null,null,null,null,0)

	-- setting term_start, term_end (priority 1: fixed tenor, priority 2: relative tenor) and relative tenor conversion on reference with as of date
	SET @term_start = dbo.FNAGetContractMonth(ISNULL(@term_start, DATEADD (MONTH, CAST(@tenor_from AS INT), @as_of_date)))
	SET @term_end = dbo.FNALastDayInDate(ISNULL(@term_end, DATEADD (MONTH, CAST(@tenor_to AS INT), @as_of_date)))
	   
	    
--update [dbo].[var_measurement_criteria_detail] set holding_period=5 
	IF @confidence_interval IS NULL
	BEGIN
	    INSERT INTO fas_eff_ass_test_run_log(process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps)
	    SELECT @process_id,'Error','VAR.Calculation','VAR Calculation','confidence_interval','Confidence interval is not found '
	     + CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink + ';' END 
	     + ' for Criteria ID:' + CAST(@criteria AS VARCHAR) + '; Name:' + @name + '.','Please check data.'
	    
	    RAISERROR ('CatchError', 16, 1)
	END
	
	IF @holding_period IS NULL
	BEGIN
	    INSERT INTO fas_eff_ass_test_run_log(process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps)
		SELECT @process_id,'Error','VAR.Calculation','VAR Calculation','holding_period','Holding period is not found for ' 
		+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink END + '.','Please check data.'
	    
	    RAISERROR ('CatchError', 16, 1)
	END



----VAR Carculation logic started

--covariance calculation
CREATE TABLE #matrix_covar
(
	X_curve_id    INT,
	Y_curve_id    INT,
	X_term_start  DATETIME,
	Y_term_start  DATETIME,
	Covar_value   FLOAT
)

INSERT INTO #matrix_covar
  (
    X_curve_id
  )
EXEC spa_calc_vol_cor_job 
	 @as_of_date,
     NULL,
     @var_criteria_id,
     @process_id,
     NULL,
     @term_start,
     @term_end,
     NULL,
     NULL,
     @what_if,
     'n',
     'a',
     NULL,
     @whatif_criteria_id,
     @calc_type,
     @tbl_name,
     @measurement_approach,
     @conf_interval,
     @hold_period

IF EXISTS(
       SELECT *
       FROM   #matrix_covar
       WHERE  X_curve_id = -1
   )
    RAISERROR('CatchError', 16, 1)

DELETE #matrix_covar
SET @st_sql = 'INSERT INTO #matrix_covar (X_curve_id) SELECT count(*) from ' + @VolProcessTableName 
EXEC (@st_sql)

IF NOT EXISTS(
       SELECT *
       FROM   #matrix_covar
       WHERE  X_curve_id > 0
   )
    RAISERROR ('CatchError', 16, 1)

DELETE #matrix_covar
SET @st_sql = 'INSERT INTO #matrix_covar (X_curve_id) SELECT count(*) from ' + @CorProcessTableName 
EXEC (@st_sql)
IF NOT EXISTS(
       SELECT *
       FROM   #matrix_covar
       WHERE  X_curve_id > 0
   )
    RAISERROR ('CatchError', 16, 1)

DELETE #matrix_covar
SET @st_sql = 'INSERT INTO #matrix_covar (X_curve_id) SELECT count(*) from ' + @MTMProcessTableName 
EXEC (@st_sql)
IF NOT EXISTS(
       SELECT *
       FROM   #matrix_covar
       WHERE  X_curve_id > 0
   )
    RAISERROR ('CatchError', 16, 1)

DELETE #matrix_covar

SET @st_sql = 
    '
	INSERT #matrix_covar
	  (
	    X_curve_id,
	    Y_curve_id,
	    X_term_start,
	    Y_term_start,
	    Covar_value
	  )
	SELECT cor.X_curve_id,
	       cor.Y_curve_id,
	       cor.X_term_start,
	       cor.Y_term_start,
	       (
	           STDEV_Value1 * STDEV_Value2 * CASE 
	                                              WHEN cor.X_curve_id = cor.Y_curve_id
	           AND cor.X_term_start = cor.Y_term_start THEN 1 ELSE cor.Cor_value_shift 
	               END
	       ) Covar_value
	FROM   (
	           SELECT t1.curve_id X_curve_id,
	                  t2.curve_id Y_curve_id,
	                  t1.term_start X_term_start,
	                  t2.term_start Y_term_start,
	                  t1.STDEV_Value_shift STDEV_Value1,
	                  t2.STDEV_Value_shift STDEV_Value2
	           FROM   ' + @VolProcessTableName + ' t1
	                  CROSS JOIN ' + @VolProcessTableName + ' t2
	       ) Vol
	       INNER JOIN ' + @CorProcessTableName + 
    ' Cor
	            ON  vol.X_curve_id = cor.X_curve_id
	            AND vol.Y_curve_id = cor.Y_curve_id
	            AND vol.X_term_start = cor.X_term_start
	            AND vol.Y_term_start = cor.Y_term_start
	'
--SELECT * FROM #matrix_covar ORDER BY X_curve_id,X_term_start,Y_curve_id,Y_term_start
exec spa_print @st_sql
EXEC (@st_sql)
CREATE TABLE #product_covar_mtm
(
	X_curve_id      INT,
	X_term_start    DATETIME,
	Matrix_Value    FLOAT,
	Matrix_Value_C  FLOAT,
	Matrix_Value_I  FLOAT
)
SET @st_sql = 
    '
 INSERT INTO #product_covar_mtm
   (
     X_curve_id,
     X_term_start,
     Matrix_Value,
     Matrix_Value_C,
     Matrix_Value_I
   )
SELECT x_curve_id,
	x_term_start,
	SUM(Matrix_Value*mtm),
	SUM(Matrix_Value_C*mtmc),
	SUM(Matrix_Value_I*mtmi)
FROM(
	 SELECT DISTINCT
	  covar.x_curve_id,
	  ISNULL(covar.x_term_start, covar1.x_term_start) x_term_start,
	  ISNULL(covar.Covar_value, covar1.Covar_value) Matrix_Value,
	  ISNULL(covar.Covar_value, covar1.Covar_value) Matrix_Value_C,
	  ISNULL(covar.Covar_value, covar1.Covar_value) Matrix_Value_I,
	  mtm.mtm,
	  mtm.mtmc,
	  mtm.mtmi
	 FROM ' + @MTMProcessTableName + ' mtm   
	INNER JOIN source_price_curve_def spcd ON mtm.curve_id = spcd.source_curve_def_id
		LEFT JOIN #matrix_covar covar ON covar.y_curve_id = spcd.source_curve_def_id
			AND covar.y_term_start = mtm.term_start
		LEFT JOIN #matrix_covar covar1 ON covar1.y_curve_id = spcd.risk_bucket_id
			AND covar1.y_term_start = mtm.term_start) t
GROUP BY x_curve_id,
	x_term_start'

exec spa_print @st_sql
EXEC (@st_sql)
/*
SELECT y_curve_id,y_term_start,sum(covar.Covar_value*mtm.mtm) Matrix_Value from #matrix_covar covar
INNER JOIN adiha_process.dbo.MTM_farrms_admin_ss mtm
ON covar.x_curve_id=mtm.curve_id AND covar.x_term_start=mtm.term_start
GROUP BY  y_curve_id,y_term_start

SELECT * FROM #matrix_covar ORDER BY X_curve_id,X_term_start,Y_curve_id,Y_term_start
SELECT * FROM adiha_process.dbo.MTM_farrms_admin_ss
SELECT * FROM #product_covar_mtm ORDER BY X_curve_id,X_term_start
*/
DECLARE @Portfolio_Risk             FLOAT,
        @Portfolio_Risk_C           FLOAT,
        @Portfolio_Risk_I           FLOAT,
        @VAR                        FLOAT,
        @VAR_C                      FLOAT,
        @VAR_I                      FLOAT,
        @RAROC                      FLOAT,
        @RAROC_I                    FLOAT

DECLARE @confidence_interval_value  FLOAT
CREATE TABLE #result_value
(
	r_value    FLOAT,
	r_value_C  FLOAT,
	r_value_I  FLOAT,
	currency_id INT
)

SET @st_sql = 
    'INSERT INTO #result_value
       (
         r_value,
         r_value_C,
         r_value_I,
         currency_id
       )
     SELECT SUM(covar.Matrix_Value * mtm.mtm),
            SUM(covar.Matrix_Value_C * mtm.mtmC),
            SUM(covar.Matrix_Value_I * mtm.mtmI),
            max(currency_id)
     FROM   #product_covar_mtm covar
            INNER JOIN ' + @MTMProcessTableName + 
    ' mtm
                 ON  covar.X_curve_id = mtm.curve_id
                 AND covar.x_term_start = mtm.term_start'
exec spa_print @st_sql
EXEC (@st_sql)


IF EXISTS(SELECT *FROM   #result_value WHERE  r_value <= 0  )
BEGIN
	 INSERT INTO fas_eff_ass_test_run_log(process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps)
    SELECT @process_id,'Error','VAR.Calculation','VAR Calculation','Portfolio_Risk','Portfolio Risk is found Negative/ZERO for  '
     + CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: '+ @hyperlink END + '.','Please check data.'
    
    RAISERROR ('CatchError', 16, 1)
END

IF EXISTS(SELECT * FROM   #result_value WHERE  r_value_C < 0   )
BEGIN
 	INSERT INTO fas_eff_ass_test_run_log(process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps)
    SELECT @process_id,'Error','VAR.Calculation','VAR Calculation','Portfolio_Risk','Portfolio Risk C. is found Negative/ZERO for '
     + CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: ' + @hyperlink END + '.','Please check data.'
    
    RAISERROR ('CatchError', 16, 1)
END

IF EXISTS(SELECT * FROM   #result_value WHERE  r_value_I <= 0   )
BEGIN
	INSERT INTO fas_eff_ass_test_run_log(process_id,code,MODULE,source,TYPE,DESCRIPTION,nextsteps)
    SELECT @process_id,'Error','VAR.Calculation','VAR Calculation','Portfolio_Risk','Portfolio Risk I. is found Negative/ZERO for ' 
	+ CASE WHEN @name IS NULL THEN '' ELSE 'Criteria: '+ @hyperlink END + '.','Please check data.'
    
    RAISERROR ('CatchError', 16, 1)
END
DECLARE @currency_id INT
SELECT @Portfolio_Risk=SQRT(r_value),@Portfolio_Risk_C=SQRT(r_value_C),@Portfolio_Risk_I=SQRT(r_value_I),@currency_id =currency_id
  FROM #result_value

SELECT @confidence_interval_value = CASE @confidence_interval
         WHEN 1502 THEN 2.33
         WHEN 1503 THEN 1.28
         WHEN 1504 THEN 1.65
                                    END

SELECT @VAR = SQRT(@holding_period) * @Portfolio_Risk * @confidence_interval_value,
       @VAR_C = SQRT(@holding_period) * @Portfolio_Risk_C * @confidence_interval_value,
       @VAR_I = SQRT(@holding_period) * @Portfolio_Risk_I * @confidence_interval_value

--SELECT @holding_period holding_period,@confidence_interval confidence_interval,@Portfolio_Risk_C Portfolio_Risk_C,@Portfolio_Risk Portfolio_Risk,@Portfolio_Risk_I Portfolio_Risk_I
DELETE #result_value
SET @st_sql = 
    'INSERT INTO #result_value
       (
         r_value,
         r_value_I
       )
     SELECT SUM(mtm) / ' + CAST(@VAR AS VARCHAR) + ',
            SUM(mtmI) / ' + CAST(@VAR_I AS VARCHAR) 
    + '
     FROM   ' + @MTMProcessTableName

EXEC (@st_sql)
SELECT @RAROC = r_value,
       @RAROC_I = r_value_I
FROM   #result_value

--SELECT * FROM #result_value
--SELECT @calc_vol_cor
-- ------------saving Result of volatility and correlation data 
 BEGIN TRAN
	IF @calc_vol_cor = 'y'
	BEGIN
	    

--		DELETE [curve_volatility] 
--		from  [curve_volatility] s inner join [vol_cor_header] h
--		on s.vol_cor_header_id=h.id and h.as_of_date=@as_of_date and h.var_criteria_id=@var_criteria_id
--
--		DELETE curve_correlation
--		from  curve_correlation s inner join [vol_cor_header] h
--		on s.vol_cor_header_id=h.id and h.as_of_date=@as_of_date and var_criteria_id=@var_criteria_id

		SET @st_sql = 
		    'DELETE [curve_volatility]
		     FROM   [curve_volatility] s
		            INNER JOIN ' + @VolProcessTableName + ' v
		                 ON  s.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
		                 AND s.curve_source_value_id = 
		                     ' + CAST(@price_curve_source AS VARCHAR) + '
		                 AND s.[curve_id] = v.curve_id
		                 AND s.term = v.term_start'
		
		EXEC (@st_sql)
		exec spa_print @st_sql
		
		SET @st_sql = 
		    'DELETE curve_correlation
		     FROM   curve_correlation s
		            INNER JOIN ' + @CorProcessTableName + ' c
		                 ON  s.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''' 
		                 AND s.curve_source_value_id = 
		                     ' + CAST(@price_curve_source AS VARCHAR) + '
		                 AND s.[curve_id_from] = c.X_curve_id
		                 AND s.[curve_id_to] = Y_curve_id
		                 AND s.[term1] = c.X_term_start
		                 AND s.[term2] = c.Y_term_start'
		
		exec spa_print @st_sql
		EXEC (@st_sql)


--		delete [vol_cor_header] where [as_of_date]=@as_of_date and var_criteria_id=@var_criteria_id

		DECLARE @vol_cor_header_id INT
		
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
		    CASE WHEN @calc_type <> 'w' THEN @var_criteria_id ELSE NULL END,
		    @data_points,
		    @price_curve_source,
		    ISNULL(@daily_return_data_series, '1562'),
		    'y',
		    'y',
		    dbo.FNADBUser(),
		    GETDATE(),
		    dbo.FNADBUser(),
		    GETDATE()
		  )
		  
		SET @vol_cor_header_id = SCOPE_IDENTITY()
		
		
		SET @st_sql = 
		    '
		INSERT INTO [curve_volatility]
		  (
		    vol_cor_header_id,
		    [as_of_date],
		    [curve_id],
		    curve_source_value_id,
		    [term],
		    [value],
		    [create_user],
		    [create_ts],
		    [update_user],
		    [update_ts],
		    [granularity]
		  )
		SELECT ' + CAST(@vol_cor_header_id AS VARCHAR) + ',
		       ''' + CAST(@as_of_date AS VARCHAR) + ''',
		       curve_id,
		       ' + CAST(@price_curve_source AS VARCHAR) + ',
		       term_start,
		       STDEV_Value,
		       dbo.FNADBUser() create_usr,
		       GETDATE() create_ts,
		       dbo.FNADBUser() update_usr,
		       GETDATE() update_ts,
		       700
		FROM   ' + @VolProcessTableName
		
		exec spa_print @st_sql
		EXEC (@st_sql)
		
		SET @st_sql = 
		    '
		INSERT INTO [dbo].[curve_correlation]
		  (
		    [vol_cor_header_id],
		    [as_of_date],
		    [curve_id_from],
		    [curve_id_to],
		    [term1],
		    [term2],
		    [curve_source_value_id],
		    [value],
		    [create_user],
		    [create_ts],
		    [update_user],
		    [update_ts]
		  )
		SELECT ' + CAST(@vol_cor_header_id AS VARCHAR) + ',''' + CAST(@as_of_date AS VARCHAR) + ''',
		       X_curve_id,
		       Y_curve_id,
		       X_term_start,
		       Y_term_start,
		       ' + CAST(@price_curve_source AS VARCHAR) + ',
		       Cor_value,
		       dbo.FNADBUser(),
		       GETDATE(),
		       dbo.FNADBUser(),
		       GETDATE()
		FROM   ' + @CorProcessTableName
		
		exec spa_print @st_sql
		EXEC (@st_sql)
	END --@calc_vol_cor='y'

		IF ISNULL(@calc_type, 'r') = 'r'
		BEGIN
		    DELETE [var_results]
		    WHERE  [as_of_date] = @as_of_date
		           AND [var_criteria_id] = @var_criteria_id
		    
		    INSERT INTO [dbo].[var_results]
		      (
		        [as_of_date],
		        [var_criteria_id],
		        [VAR],
		        [VaRC],
		        [VaRI],
		        [RAROC1],
		        [RAROC2],
		        [create_user],
		        [create_ts],
		        [currency_id]
		      )
		    VALUES
		      (
		        @as_of_date,
		        @var_criteria_id,
		        ABS(@VAR),
		        ABS(@VAR_C),
		        ABS(@VAR_I),
		        ABS(@RAROC),
		        ABS(@RAROC_I),
		        dbo.FNADBUser(),
		        GETDATE(),
		        @currency_id
		      )
		      
		    DELETE [marginal_var]
		    WHERE  [as_of_date] = @as_of_date
		           AND [var_criteria_id] = @var_criteria_id
		END
		ELSE
		BEGIN
		    DELETE [var_results_whatif]
		    WHERE  [as_of_date] = @as_of_date
		           AND [whatif_criteria_id] = @whatif_criteria_id
		    
		    INSERT INTO [dbo].[var_results_whatif]
		      (
		        [whatif_criteria_id],
		        [as_of_date],
		        [var_criteria_id],
		        [VAR],
		        [VaRC],
		        [VaRI],
		        [RAROC1],
		        [RAROC2],
		        [create_user],
		        [create_ts],
		        [currency_id]
		      )
		    VALUES
		      (
		        @whatif_criteria_id,
		        @as_of_date,
		        @var_criteria_id,
		        ABS(@VAR),
		        ABS(@VAR_C),
		        ABS(@VAR_I),
		        ABS(@RAROC),
		        ABS(@RAROC_I),
		        dbo.FNADBUser(),
		        GETDATE(),
		        @currency_id
		      )	
		    
		    DELETE [marginal_var_whatif]
		    WHERE  [as_of_date] = @as_of_date
		           AND [whatif_criteria_id] = @whatif_criteria_id
		END

 --select
 -- @calc_type,@whatif_criteria_id ,@var_criteria_id ,@as_of_date , @confidence_interval ,@Portfolio_Risk ,@Portfolio_Risk_C,@Portfolio_Risk_I , @MTMProcessTableName 
		     
SET @st_sql = '
	INSERT INTO [dbo].marginal_var' 
		+ CASE 
			  WHEN ISNULL(@calc_type, 'r') = 'w' THEN 
				   '_whatif (whatif_criteria_id,'
			  ELSE '('
		END +
	   '[var_criteria_id]
	   ,[as_of_date]
	   ,[curve_id]
	   ,[term]
	   ,[create_user]
	   ,[create_ts]
	   ,[MTM_value],MTM_value_C,MTM_value_I
	   ,[MVaR]
	   ,[MVaR_C]
	   ,[MVaR_I])
	 select
	 ' + CASE 
			 WHEN ISNULL(@calc_type, 'r') = 'w' THEN CAST(@whatif_criteria_id AS VARCHAR)   + ','
			 ELSE ''
		 END + '
		  ' + ISNULL(CAST(@var_criteria_id AS VARCHAR), 'null') + ',''' + CAST(@as_of_date AS VARCHAR) + '''
		   ,mt.curve_id
		   ,mt.term_start
		   ,dbo.FNADBUser(),getdate()
		   ,mt.mtm,mt.mtmC,mt.mtmI
		,' + CASE @confidence_interval
		         WHEN 1502 THEN '2.33'
				 WHEN 1503 THEN '1.28'
				 WHEN 1504 THEN '1.65'
		     END + '* (cov.matrix_value/' + CAST(@Portfolio_Risk AS VARCHAR) + 
		    ')
		   ,' + CASE @confidence_interval
		             WHEN 1502 THEN '2.33'
					 WHEN 1503 THEN '1.28'
					 WHEN 1504 THEN '1.65'
		        END + '* (cov.matrix_value_C/' + CASE WHEN @Portfolio_Risk_C <> 0 THEN CAST(@Portfolio_Risk_C AS VARCHAR) ELSE '0.00001' END 
		    + ')
		   ,' + CASE @confidence_interval
		             WHEN 1502 THEN '2.33'
					 WHEN 1503 THEN '1.28'
					 WHEN 1504 THEN '1.65'
		        END + '* (cov.matrix_value_I/' + CAST(@Portfolio_Risk_I AS VARCHAR) 
		    + ')
		     from ' + @MTMProcessTableNameNew + 
		    ' mt inner join #product_covar_mtm cov on mt.curve_id=cov.x_curve_id and mt.term_start=cov.x_term_start'
		
		
		exec spa_print 'marginal var'  
		exec spa_print @st_sql
		EXEC (@st_sql)
		COMMIT TRAN
		
	--***** plotting for variance/covariance *****--
		
		DECLARE @i INT
		DECLARE @val FLOAT
		DECLARE @mean_value AS FLOAT
		DECLARE @standard_dev AS FLOAT
		
		DELETE FROM #result_value
		
		SET @st_sql = 'INSERT INTO #result_value(r_value) SELECT mtm FROM '+ @MTMProcessTableName	
		EXEC (@st_sql)
			
		SET @standard_dev = @Portfolio_Risk
		SELECT @mean_value = SUM(r_value) FROM #result_value 
		
		
		IF @calc_type = 'w'
		BEGIN
			SET @st_sql = '
					DELETE [dbo].[var_probability_density_whatif] FROM [dbo].[var_probability_density_whatif] vpd
					WHERE 1=1 
					AND vpd.whatif_criteria_id = ' + CAST(@whatif_criteria_id AS VARCHAR) + '
					AND vpd.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''
			exec spa_print @st_sql		
			EXEC(@st_sql)
		
			SET @i = 1
			WHILE @i <= 1000
			BEGIN
				SET @val = (dbo.FNANormSInv(RAND())* @standard_dev + @mean_value)
				
				INSERT INTO var_probability_density_whatif(
					whatif_criteria_id,
					as_of_date,
					mtm_value,
					probab_den,
					measure,
					create_user,
					create_ts,
					update_user,
					update_ts
				)
				SELECT 
					@whatif_criteria_id,
					@as_of_date,
					@val,
					dbo.FNANormDist(@val, @mean_value, @standard_dev, 0) probab,
					17351,
					dbo.FNADBUser(),
					getdate(),
					dbo.FNADBUser(),
					getdate()
				SET @i = @i + 1
			END
		END
		ELSE
		BEGIN
			SET @st_sql = '
						DELETE [dbo].[var_probability_density] FROM [dbo].[var_probability_density] vpd
						WHERE 1=1 
						AND vpd.var_criteria_id = ' + CAST(@var_criteria_id AS VARCHAR) + '
						AND vpd.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''
				exec spa_print @st_sql		
				EXEC(@st_sql)
			
			SET @i = 1
			WHILE @i <= 1000
			BEGIN
				SET @val = (dbo.FNANormSInv(RAND())* @standard_dev + @mean_value)
				
				INSERT INTO var_probability_density(
					var_criteria_id,
					as_of_date,
					mtm_value,
					probab_den,
					create_user,
					create_ts,
					update_user,
					update_ts
				)
				SELECT 
					@var_criteria_id,
					@as_of_date,
					@val,
					dbo.FNANormDist(@val, @mean_value, @standard_dev, 0) probab,
					dbo.FNADBUser(),
					getdate(),
					dbo.FNADBUser(),
					getdate()
				SET @i = @i + 1
			END
		END
		
		EXEC spa_print 'finish VaR Calculation'

	-- select dbo.FNAUserDateFormat(@as_of_date, @user_name) ,@as_of_date, @user_name
	SET @desc = 'VaR Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) 
		    + '.'
		
		SET @errorcode = 's'
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name +
		       '&spa=exec spa_get_VaR_report ''v'',null,null,''' + CAST(YEAR(@as_of_date) AS VARCHAR) 
		       + '-' + CAST(MONTH(@as_of_date) AS VARCHAR) + '-' + CAST(DAY(@as_of_date) AS VARCHAR) 
		       + ''',' + ISNULL(CAST(@var_criteria_id AS VARCHAR), 'null')
		
		SET @temptablequery = 'exec ' + DB_NAME() + '.dbo.spa_get_VaR_report ''v'',null,null,''' + CAST(YEAR(@as_of_date) AS VARCHAR) 
		    + '-' + CAST(MONTH(@as_of_date) AS VARCHAR) + '-' + CAST(DAY(@as_of_date) AS VARCHAR) 
		    + ''',' + ISNULL(CAST(@var_criteria_id AS VARCHAR), 'null')
		
		EXEC spa_print @errorcode
		EXEC spa_print @process_id
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
			    SET @desc = 'VaR Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) 
			        + ' (ERRORS found).'
			    
			    EXEC spa_print @desc
			END
			ELSE
			BEGIN
			    SET @desc = 
			        'VaR Calculation critical error found ( Errr Description:' + 
			        ERROR_MESSAGE() + '; Line no: ' + CAST(ERROR_LINE() AS VARCHAR) 
			        + ').'
			    
			    EXEC spa_print @desc
			END
			
			SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name +
			       '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + 
			       ''',''y'''
			
			SET @temptablequery = 'exec ' + DB_NAME() + '.dbo.spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''
		END CATCH
		
		
		SET @url_desc = '' 
		IF @errorcode = 'e'
		BEGIN
		    SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + 
		           '.</a>'
		    
		    SET @url_desc = 
		        '<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log ''' + @process_id + '''">Click here...</a>'
		    
			IF @return_output = 1
			BEGIN
				IF OBJECT_ID('tempdb..#tmp_result_calc_var_job') IS NOT NULL
				BEGIN 
					INSERT INTO #tmp_result_calc_var_job
					SELECT 'Error' ErrorCode,
						   'Calculate vol_cor' MODULE,
						   'spa_calc_VaR' Area,
						   'Technical Error' STATUS,
						   'VaR Calculation completed with error, Please view this report. '
						   + @url_desc MESSAGE,
						   '' Recommendation
				END
				ELSE
				BEGIN
					SELECT 'Error' ErrorCode,
						   'Calculate vol_cor' MODULE,
						   'spa_calc_VaR' Area,
						   'Technical Error' STATUS,
						   'VaR Calculation completed with error, Please view this report. '
						   + @url_desc MESSAGE,
						   '' Recommendation
				END
			END
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM fas_eff_ass_test_run_log WHERE process_id = @process_id AND TYPE IN ('Debt_Rating', 'Default_Recovery', 'Probability') AND code = 'Warning')
			BEGIN
				SET @desc = 'VaR Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + ' with warnings'
				IF ISNULL(@calc_type, 'r') <> 'w'
				BEGIN
					SELECT @desc1 = '<a target="_blank" href="' + @url + '">VaR Results</a>'
					SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''
				END
			END

		    IF ISNULL(@calc_type, 'r') <> 'w'
		    SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'
		    
			IF @return_output = 1
			BEGIN
				IF OBJECT_ID('tempdb..#tmp_result_calc_var_job') IS NOT NULL
				BEGIN
					INSERT INTO #tmp_result_calc_var_job
					SELECT 'Success' ErrorCode,
						   'Calculate vol_cor' MODULE,
						   'spa_calc_VaR' Area,
						   'Success' STATUS,
						   @desc MESSAGE,
						   '' Recommendation
				END
				ELSE
				BEGIN
					EXEC spa_ErrorHandler 0,
						 'VaR Calculation',
						 @source,
						 'Success',
						 @desc,
						 ''
				END
			END
		END
		EXEC spa_message_board 'u',
		     @user_name,
		     NULL,
		     @source,
		     @desc,
		     @desc1,
		     '',
		     @errorcode,
		     @process_id,
		     NULL,
		     @process_id,
		     NULL,
		     'n',
		     @temptablequery,
		     'y' 

