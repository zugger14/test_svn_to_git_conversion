IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[runAssessment_main]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[runAssessment_main] 
GO

/**
  This SP is used to run assessment for the links
  Parameters:	
	@subId						: subsidiary ids
	@strategyId					: strategy ids
	@bookId						: book ids
	@assessmentId				: assessment ids 
	@initialOngoingAssessment	: initial or ongoing assessment
	@runDate  					: Date to run assessment
	@user_name  				: Username
	@process_id 				: Unique identifier
	@what_if 					: What If flag
	@batch_process_id  			: Batch Unique identifier
	@batch_report_param			: Batch parameters
*/

CREATE PROC [dbo].[runAssessment_main]
	@subId VARCHAR(MAX) = NULL,
	@strategyId VARCHAR(MAX) = NULL,
	@bookId VARCHAR(MAX) = NULL,
	@assessmentId VARCHAR(5000) = NULL,
	@initialOngoingAssessment VARCHAR(50) = NULL,
	@runDate VARCHAR(50) = NULL,
	@user_name VARCHAR(50) = 'farrms_admin',
	@process_id VARCHAR(50) = NULL,
	@what_if VARCHAR(1) = NULL,
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(1000) = NULL
	 
AS

SET NOCOUNT ON

/* 
---test
--
--DECLARE @subId VARCHAR(50),
--		@strategyId VARCHAR(50),
--        @bookId VARCHAR(50),
--		@assessmentId VARCHAR(50),
--        @initialOngoingAssessment VARCHAR(50),
--        @runDate VARCHAR(50),
--		@user_name VARCHAR(30),
--		@process_id VARCHAR(50),
--		@what_if VARCHAR(1)
--
--SET @subId = NULL
--SET @strategyId = NULL
--SET @bookId = NULL
--SET @assessmentId = '1922'
--SET @initialOngoingAssessment = 'o'
--SET @runDate = '2008-11-13'
--SET @user_name = 'farrms_admin'
--SET @process_id = NULL
--SET @what_if = NULL
--drop table #assessments_mult
--drop table #Result_ID
--drop table #HedgeRel
--drop table #HedgeRel_detail
--drop table #Status
--drop table #Results
--drop table #TMPX
--drop table #TMPY
----------------------------------
*/
DECLARE @is_batch TINYINT
SET @is_batch = 1 
SET @process_id = @batch_process_id

IF @batch_process_id IS NULL
BEGIN
	SET @process_id = REPLACE(NEWID(), '-', '_')
	SET @is_batch = 0
END

EXEC spa_print @process_id
DECLARE @url_desc VARCHAR(2000)
DECLARE @url VARCHAR(2000)
DECLARE @desc VARCHAR(2000)

CREATE TABLE #assessments_mult(
	eff_test_profile_id INT,
	link_id INT,
	calc_level INT
)
CREATE TABLE #Result_ID(
	R_ID INT
)
DECLARE @eff_test_profile_id INT
DECLARE @link_id INT
DECLARE @calc_level INT

DECLARE @resultID INT
DECLARE @assessmentAction CHAR(1)
DECLARE @useChangeSeries CHAR(1)
DECLARE @initialAssessment CHAR(1)
DECLARE @hedgeRelationshipId INT
DECLARE @statusDes VARCHAR(500)

DECLARE @assessmentApproach INT
DECLARE @curveType INT
DECLARE @curveSource INT
DECLARE @pricePoints INT
DECLARE @hedgeRelationshipName VARCHAR(100)

DECLARE @hedgeAssessmentPriceType INT
DECLARE @itemAssessmentPriceType INT
DECLARE @itemPricingValueId INT
DECLARE @hedgeFixedPriceValueId INT
DECLARE @itemCounterpartyID INT
DECLARE @itemTraderID INT
DECLARE @genCurveSourceID INT
DECLARE @commonUOMID INT
DECLARE @commonCurrencyID INT
DECLARE @commonCurrencyName VARCHAR(50)
DECLARE @hedgeAsDependent CHAR(1)
DECLARE @uom_name VARCHAR(100)
DECLARE @hedgeToItemConvFactor FLOAT

DECLARE @assessmentPriceType INT
DECLARE @relId  INT
DECLARE @inherit_assmt_eff_test_profile_id INT

DECLARE @inception_ongoing CHAR(1)
DECLARE @tmp_value FLOAT
DECLARE @st VARCHAR(5000)

DECLARE @SSx	NUMERIC(38, 11)
DECLARE @SSy	NUMERIC(38, 11)
DECLARE @SCxy	NUMERIC(38, 11)
DECLARE @correlation NUMERIC(38, 11)
DECLARE @var NUMERIC(38, 20)
DECLARE @RSQ NUMERIC(38, 11)
DECLARE @intercept NUMERIC(38, 11)
DECLARE @slope NUMERIC(38, 11)
DECLARE @df TINYINT
DECLARE @sumYError2 FLOAT
DECLARE @TVALUE NUMERIC(38, 11)
DECLARE @FVALUE NUMERIC(38, 11)
DECLARE @SError FLOAT
DECLARE @SStdError FLOAT
DECLARE @SSR NUMERIC(38, 11)
DECLARE @MSR NUMERIC(38, 11)

DECLARE @assessmentResultValue NUMERIC(38, 11)
DECLARE @assessmentAdditionalResultValue NUMERIC(38, 11)
DECLARE @assessmentAdditionalResultValue2 NUMERIC(38, 11)

DECLARE @ErrorNo INT
DECLARE @WarningNo INT
DECLARE @SuccessNo INT

CREATE TABLE  #HedgeRel(
	eff_test_profile_id INT, 
	fas_book_id INT, 
	eff_test_name VARCHAR(100) COLLATE DATABASE_DEFAULT, 
	eff_test_description VARCHAR(100) COLLATE DATABASE_DEFAULT, 
	inherit_assmt_eff_test_profile_id INT, 
	init_eff_test_approach_value_id INT, 
	init_assmt_curve_type_value_id INT, 
	init_curve_source_value_id INT, 
	init_number_of_curve_points INT, 
	on_eff_test_approach_value_id INT, 
	on_assmt_curve_type_value_id INT, 
	on_curve_source_value_id INT, 
	on_number_of_curve_points INT, 
	force_intercept_zero VARCHAR(30) COLLATE DATABASE_DEFAULT, 		
	profile_for_value_id INT, 
	convert_currency_value_id INT, 
	convert_uom_value_id INT, 
	effective_start_date VARCHAR(30) COLLATE DATABASE_DEFAULT, 
	effective_end_date VARCHAR(30) COLLATE DATABASE_DEFAULT, 
	risk_mgmt_strategy CHAR(1) COLLATE DATABASE_DEFAULT, 
	risk_mgmt_policy CHAR(1) COLLATE DATABASE_DEFAULT, 
	formal_documentation CHAR(1) COLLATE DATABASE_DEFAULT, 
	profile_approved  CHAR(1) COLLATE DATABASE_DEFAULT, 
	profile_active CHAR(1) COLLATE DATABASE_DEFAULT, 
	profile_approved_by VARCHAR(30) COLLATE DATABASE_DEFAULT, 
	profile_approved_date VARCHAR(30) COLLATE DATABASE_DEFAULT, 
	hedge_to_item_conv_factor FLOAT, 
	item_pricing_value_id INT, 
	hedge_test_price_option_value_id INT, 
	item_test_price_option_value_id INT, 
	hedge_fixed_price_value_id INT, 
	use_hedge_as_depend_var VARCHAR(50) COLLATE DATABASE_DEFAULT,	
	item_counterparty_id INT, 
	item_trader_id INT, 
	gen_curve_source_value_id INT, 
	individual_link_calc CHAR(1) COLLATE DATABASE_DEFAULT,
	create_user VARCHAR(50) COLLATE DATABASE_DEFAULT,
	create_ts VARCHAR(50) COLLATE DATABASE_DEFAULT,
	update_user VARCHAR(50) COLLATE DATABASE_DEFAULT,
	update_ts VARCHAR(50) COLLATE DATABASE_DEFAULT, 
	currency_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
	uom_name VARCHAR(50) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #HedgeRel_detail( 
	eff_test_profile_detail_id INT,
	eff_test_profile_id INT , 
	hedge_or_item CHAR(1) COLLATE DATABASE_DEFAULT, 
	book_deal_type_map_id INT, 
	source_deal_type_id INT, 
	deal_sub_type_id INT, 
	fixed_float_flag VARCHAR(5) COLLATE DATABASE_DEFAULT, 
	deal_sequence_number INT, 
	source_curve_def_id INT, 
	strip_month_from VARCHAR(20) COLLATE DATABASE_DEFAULT, 
	strip_month_to VARCHAR(20) COLLATE DATABASE_DEFAULT, 
	strip_year_overlap INT, 
	roll_forward_year INT, 
	volume_mix_percentage NUMERIC(5,2), 
	uom_conversion_factor FLOAT, 
	deal_xfer_source_book_id INT, 
	source_currency_id INT, 
	currency_name VARCHAR(100) COLLATE DATABASE_DEFAULT, 
	source_uom_id INT, 
	uom_name VARCHAR(100) COLLATE DATABASE_DEFAULT, 
	curve_name VARCHAR(100) COLLATE DATABASE_DEFAULT, 
	conversion_factor FLOAT)

CREATE TABLE #Status(
	ErrorCode VARCHAR(30) COLLATE DATABASE_DEFAULT,
	Module VARCHAR(100) COLLATE DATABASE_DEFAULT,
	Area VARCHAR(30) COLLATE DATABASE_DEFAULT, 
	[status] VARCHAR(30) COLLATE DATABASE_DEFAULT,
	[message] VARCHAR(1000) COLLATE DATABASE_DEFAULT, 
	Recommendation VARCHAR(1000) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #Results (
	[Date] VARCHAR(20) COLLATE DATABASE_DEFAULT,
	XPrice	NUMERIC(38, 11) DEFAULT (NULL),
	YPrice	NUMERIC(38, 11) DEFAULT (NULL),
	X2Price NUMERIC(38, 11) DEFAULT (0),
	Y2Price NUMERIC(38, 11) DEFAULT (0),
	XYPrice NUMERIC(38, 11) DEFAULT (0),
	XSLine  NUMERIC(38, 11) DEFAULT (0),
	YSLine  NUMERIC(38, 11) DEFAULT (0)
)
CREATE TABLE #TMPX([price_date] VARCHAR(10) COLLATE DATABASE_DEFAULT,[XPrice] FLOAT)
CREATE TABLE #TMPY([price_date] VARCHAR(10) COLLATE DATABASE_DEFAULT,[YPrice] FLOAT)

--BEGIN try
IF (@subId IS NULL) AND (@strategyId IS NULL) AND (@bookId IS NULL) AND (@assessmentId IS NULL)
BEGIN
	INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
	VALUES(@process_id,'Error', 'Hedge Assessment', 'runAssessment_main',
				'Application Error', 'No hedging relationship type selected.'
				, 'Please select hedging relationship type.')
	GOTO labelEnd
END

--print 'exec spa_get_all_assessments_to_run '+CAST(@subId as VARCHAR)+','+CAST(@strategyId as VARCHAR)+','+CAST(@bookId as VARCHAR)+','+CAST(@assessmentId as VARCHAR)
--return

IF @what_if IS NULL OR @what_if = 'n'
	INSERT INTO #assessments_mult EXEC spa_get_all_assessments_to_run @subId, @strategyId, @bookId, @assessmentId
ELSE IF @what_if='y'
	INSERT INTO #assessments_mult 
	VALUES(@assessmentId,-1,3)
ELSE 
	INSERT INTO #assessments_mult 
	VALUES(@assessmentId,-1,1)

IF NOT EXISTS (SELECT 1 FROM #assessments_mult)
BEGIN
	INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
	VALUES(@process_id,'Error', 'Hedge Assessment', 'runAssessment_main',
				'Application Error', 'Sorry, could not find Assessement to run. There may be problem in setting Assessment criteria in Hedging Relationship Types.'
				, 'Please Check hedging relationship type.')
	GOTO labelEnd
END

DECLARE @no_links INT
SELECT @no_links = COUNT(1) FROM #assessments_mult

IF @no_links>1
BEGIN
	INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, [type], [description], nextsteps) 
	SELECT @process_id,'Warning', 'Hedge Assessment', 'retrieveHedegeRelationship',
		'Ignored', 'Assessment calculation skipped for ID: '+dbo.FNAHyperLinkText(CASE WHEN calc_level = 3 THEN 10232610 ELSE 10231910 END,
		CAST(t.eff_test_profile_id as VARCHAR) + '/' + ISNULL(r.eff_test_name,''),t.eff_test_profile_id) + ' for fully dedesignated link ID: '
		 + dbo.FNAHyperLinkText(10233700, t.link_id, t.link_id) + ' for as of date ' + @runDate,'' 
	FROM #assessments_mult t 
	INNER JOIN fas_link_header l ON l.link_id = t.link_id AND ISNULL(fully_dedesignated,'n') = 'y'
	INNER JOIN fas_eff_hedge_rel_type r on r.eff_test_profile_id=l.eff_test_profile_id

	DELETE #assessments_mult FROM #assessments_mult t 
	INNER JOIN fas_link_header l ON l.link_id=t.link_id AND ISNULL(fully_dedesignated,'n') = 'y'
END

DECLARE @hyper_link_id VARCHAR(500)

DECLARE tblCursor CURSOR FOR
SELECT * FROM #assessments_mult FOR  READ ONLY
OPEN tblCursor
FETCH NEXT FROM tblCursor into @eff_test_profile_id,@link_id,@calc_level
WHILE @@FETCH_STATUS = 0
BEGIN
	--BEGIN try
		DELETE FROM #HedgeRel
		DELETE FROM #HedgeRel_detail
		DELETE FROM #Status
		DELETE FROM #Results
		DELETE FROM #TMPX
		DELETE FROM #TMPY

		SET @assessmentAction='t'
		SET @useChangeSeries='f'
		SET @hedgeRelationshipId = @eff_test_profile_id

		IF @initialOngoingAssessment='i'
			SET @initialAssessment = 't'
		ELSE
			SET @initialAssessment = 'f'
		IF @link_id > 0
			--SET @hyper_link_id = dbo.FNAHyperLinkText(10233710, @link_id, @link_id)
			SET @hyper_link_id = dbo.FNATRMWinHyperlink('a', 10233700, ISNULL(@link_id, ''), ABS(@link_id),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0)
		ELSE
			SET @hyper_link_id = @link_id
		--   retrieveHedgeRelationship
		SET @relId= -1
		-------------spa_get_assmt_rel_type_header
		BEGIN TRY
			IF @calc_level = 1 
			BEGIN
				INSERT INTO #HedgeRel (
					eff_test_profile_id, fas_book_id, eff_test_name, eff_test_description, inherit_assmt_eff_test_profile_id , 
					init_eff_test_approach_value_id,init_assmt_curve_type_value_id,init_curve_source_value_id,init_number_of_curve_points,on_eff_test_approach_value_id,
					on_assmt_curve_type_value_id , on_curve_source_value_id , on_number_of_curve_points,force_intercept_zero,profile_for_value_id, 
					convert_currency_value_id , convert_uom_value_id, effective_start_date , effective_end_date,risk_mgmt_strategy,
					risk_mgmt_policy ,formal_documentation ,profile_approved,profile_active, profile_approved_by,
					profile_approved_date,hedge_to_item_conv_factor, item_pricing_value_id ,hedge_test_price_option_value_id ,item_test_price_option_value_id ,
					hedge_fixed_price_value_id ,use_hedge_as_depend_var ,item_counterparty_id ,item_trader_id ,gen_curve_source_value_id , 
					individual_link_calc,create_user ,create_ts,update_user,update_ts, 
					currency_name,uom_name)
				SELECT eff_test_profile_id, fas_book_id,eff_test_name,eff_test_description, inherit_assmt_eff_test_profile_id,  
					init_eff_test_approach_value_id,init_assmt_curve_type_value_id, init_curve_source_value_id,init_number_of_curve_points, on_eff_test_approach_value_id, 
					on_assmt_curve_type_value_id,on_curve_source_value_id,on_number_of_curve_points, force_intercept_zero,profile_for_value_id, 
					convert_currency_value_id,convert_uom_value_id,effective_start_date, effective_end_date, risk_mgmt_strategy, 
					risk_mgmt_policy,formal_documentation,profile_approved,profile_active, profile_approved_by, 
					profile_approved_date,hedge_to_item_conv_factor, item_pricing_value_id,hedge_test_price_option_value_id,item_test_price_option_value_id, 
					hedge_fixed_price_value_id,use_hedge_as_depend_var,item_counterparty_id,item_trader_id,gen_curve_source_value_id, 
					individual_link_calc,reType.create_user,reType.create_ts,reType.update_user,reType.update_ts, 
					cur.currency_name AS currency_name,uom.uom_name AS uom_name -- into #HedgeRel
				FROM fas_eff_hedge_rel_type reType 
				LEFT OUTER JOIN source_currency cur ON reType.convert_currency_value_id = cur.source_currency_id 
				LEFT OUTER JOIN source_uom uom ON reType.convert_uom_value_id = uom.source_uom_id 
				WHERE eff_test_profile_id = @hedgeRelationshipId
			END
			ELSE IF @calc_level = 3
			BEGIN
				INSERT INTO #HedgeRel (
					eff_test_profile_id, fas_book_id, eff_test_name, eff_test_description, inherit_assmt_eff_test_profile_id , 
					init_eff_test_approach_value_id,init_assmt_curve_type_value_id,init_curve_source_value_id,init_number_of_curve_points,on_eff_test_approach_value_id,
					on_assmt_curve_type_value_id , on_curve_source_value_id , on_number_of_curve_points,force_intercept_zero,profile_for_value_id, 
					convert_currency_value_id , convert_uom_value_id, effective_start_date , effective_end_date,risk_mgmt_strategy,
					risk_mgmt_policy ,formal_documentation ,profile_approved,profile_active, profile_approved_by,
					profile_approved_date,hedge_to_item_conv_factor, item_pricing_value_id ,hedge_test_price_option_value_id ,item_test_price_option_value_id ,
					hedge_fixed_price_value_id ,use_hedge_as_depend_var ,item_counterparty_id ,item_trader_id ,gen_curve_source_value_id , 
					individual_link_calc,create_user ,create_ts,update_user,update_ts, 
					currency_name,uom_name)
				SELECT 	eff_test_profile_id,fas_book_id,eff_test_name,eff_test_description,NULL inherit_assmt_eff_test_profile_id, 
						on_eff_test_approach_value_id AS init_eff_test_approach_value_id,on_assmt_curve_type_value_id AS init_assmt_curve_type_value_id, on_curve_source_value_id AS init_curve_source_value_id,on_number_of_curve_points AS init_number_of_curve_points,on_eff_test_approach_value_id, 
						on_assmt_curve_type_value_id,on_curve_source_value_id,on_number_of_curve_points,force_intercept_zero, CASE WHEN (rel_type = 'l' and rel_id is not NULL) THEN rel_id ELSE -1 END  profile_for_value_id, 
						convert_currency_value_id, convert_uom_value_id,'1990-01-01' effective_start_date, '1990-01-01' effective_end_date, 'y' risk_mgmt_strategy, 
						'y' risk_mgmt_policy, 'y' formal_documentation, 'y' profile_approved, 'y' profile_active,'dbo' profile_approved_by, 
						'1990-01-01' profile_approved_date,1 hedge_to_item_conv_factor,425 item_pricing_value_id, hedge_test_price_option_value_id, item_test_price_option_value_id, 
						425 hedge_fixed_price_value_id, use_hedge_as_depend_var,NULL item_counterparty_id,NULL item_trader_id, NULL gen_curve_source_value_id, 
						'y' individual_link_calc,reType.create_user,reType.create_ts,reType.update_user,reType.update_ts, 
						cur.currency_name AS currency_name,uom.uom_name AS uom_name -- into #HedgeRel
				FROM fas_eff_hedge_rel_type_whatif reType 
				LEFT OUTER JOIN source_currency cur ON reType.convert_currency_value_id = cur.source_currency_id 
				LEFT OUTER JOIN source_uom uom ON reType.convert_uom_value_id = uom.source_uom_id 
				WHERE eff_test_profile_id = @hedgeRelationshipId
			END
			ELSE IF @calc_level = 2
			BEGIN
				IF @link_id > 0
				BEGIN
					INSERT INTO #HedgeRel (
						eff_test_profile_id, fas_book_id, eff_test_name, eff_test_description, inherit_assmt_eff_test_profile_id , 
						init_eff_test_approach_value_id,init_assmt_curve_type_value_id,init_curve_source_value_id,init_number_of_curve_points,on_eff_test_approach_value_id,
						on_assmt_curve_type_value_id , on_curve_source_value_id , on_number_of_curve_points,force_intercept_zero,profile_for_value_id, 
						convert_currency_value_id , convert_uom_value_id, effective_start_date , effective_end_date,risk_mgmt_strategy,
						risk_mgmt_policy ,formal_documentation ,profile_approved,profile_active, profile_approved_by,
						profile_approved_date,hedge_to_item_conv_factor, item_pricing_value_id ,hedge_test_price_option_value_id ,item_test_price_option_value_id ,
						hedge_fixed_price_value_id ,use_hedge_as_depend_var ,item_counterparty_id ,item_trader_id ,gen_curve_source_value_id , 
						individual_link_calc,create_user ,create_ts,update_user,update_ts, 
						currency_name,uom_name)		
					SELECT reType.eff_test_profile_id,reType.fas_book_id, eff_test_name, eff_test_description,inherit_assmt_eff_test_profile_id, 
						init_eff_test_approach_value_id,init_assmt_curve_type_value_id,init_curve_source_value_id,init_number_of_curve_points,on_eff_test_approach_value_id, 
						on_assmt_curve_type_value_id,on_curve_source_value_id,on_number_of_curve_points,force_intercept_zero,profile_for_value_id, 
						convert_currency_value_id,convert_uom_value_id,effective_start_date,effective_end_date,risk_mgmt_strategy, 
						risk_mgmt_policy,formal_documentation,profile_approved,profile_active,profile_approved_by, 
						profile_approved_date,hedge_to_item_conv_factor,item_pricing_value_id,hedge_test_price_option_value_id, item_test_price_option_value_id, 
						hedge_fixed_price_value_id, use_hedge_as_depend_var,item_counterparty_id,item_trader_id, gen_curve_source_value_id, 
						individual_link_calc,reType.create_user,reType.create_ts,reType.update_user,reType.update_ts, 
						cur.currency_name AS currency_name,uom.uom_name AS uom_name
					FROM fas_link_header flh 
					INNER JOIN fas_eff_hedge_rel_type reType ON flh.eff_test_profile_id = reType.eff_test_profile_id 
					LEFT OUTER JOIN source_currency cur ON reType.convert_currency_value_id = cur.source_currency_id 
					LEFT OUTER JOIN source_uom uom ON reType.convert_uom_value_id = uom.source_uom_id 
					WHERE flh.link_id = @link_id
				END
				ELSE  -- if @link id is negative (Virtual Link)
				BEGIN
					INSERT INTO #HedgeRel (
						eff_test_profile_id, fas_book_id, eff_test_name, eff_test_description, inherit_assmt_eff_test_profile_id , 
						init_eff_test_approach_value_id,init_assmt_curve_type_value_id,init_curve_source_value_id,init_number_of_curve_points,on_eff_test_approach_value_id,
						on_assmt_curve_type_value_id , on_curve_source_value_id , on_number_of_curve_points,force_intercept_zero,profile_for_value_id, 
						convert_currency_value_id , convert_uom_value_id, effective_start_date , effective_end_date,risk_mgmt_strategy,
						risk_mgmt_policy ,formal_documentation ,profile_approved,profile_active, profile_approved_by,
						profile_approved_date,hedge_to_item_conv_factor, item_pricing_value_id ,hedge_test_price_option_value_id ,item_test_price_option_value_id ,
						hedge_fixed_price_value_id ,use_hedge_as_depend_var ,item_counterparty_id ,item_trader_id ,gen_curve_source_value_id , 
						individual_link_calc,create_user ,create_ts,update_user,update_ts, 
						currency_name,uom_name)		
					SELECT 	 
						reType.eff_test_profile_id,reType.fas_book_id, eff_test_name, eff_test_description,inherit_assmt_eff_test_profile_id, 
						init_eff_test_approach_value_id,init_assmt_curve_type_value_id,init_curve_source_value_id,init_number_of_curve_points,on_eff_test_approach_value_id, 
						on_assmt_curve_type_value_id,on_curve_source_value_id,on_number_of_curve_points,force_intercept_zero,profile_for_value_id, 
						convert_currency_value_id,convert_uom_value_id,effective_start_date,effective_end_date,risk_mgmt_strategy, 
						risk_mgmt_policy,formal_documentation,profile_approved,profile_active,profile_approved_by, 
						profile_approved_date,hedge_to_item_conv_factor,item_pricing_value_id,hedge_test_price_option_value_id, item_test_price_option_value_id, 
						hedge_fixed_price_value_id, use_hedge_as_depend_var,item_counterparty_id,item_trader_id, gen_curve_source_value_id, 
						individual_link_calc,reType.create_user,reType.create_ts,reType.update_user,reType.update_ts, 
						cur.currency_name AS currency_name,uom.uom_name AS uom_name
					FROM fas_eff_hedge_rel_type reType  
					LEFT OUTER JOIN source_currency cur ON reType.convert_currency_value_id = cur.source_currency_id 
					LEFT OUTER JOIN source_uom uom ON reType.convert_uom_value_id = uom.source_uom_id 
					WHERE reType.eff_test_profile_id = @eff_test_profile_id
				END
			END
			
			-- SELECT * FROM #HedgeRel
			IF NOT EXISTS (SELECT 1 FROM #HedgeRel)
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
				VALUES(@process_id,'Error', 'Hedge Relationship', 'retrieveHedgeRelationship',
							'Application Error', 'No Hedge Relationship data found for ID:' +
							dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END, CAST(@hedgeRelationshipId AS VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,'')+
							'/ link_id: ' + @hyper_link_id +
							' / calc_level:'+ CAST(@calc_level AS VARCHAR) + 
							' for as of date '+CAST(@runDate AS VARCHAR),@hedgeRelationshipId) + ' for as of date ' + @runDate, 'Please check the Hedging Relationship Types / Designation of Hedge.')

				EXEC spa_print '889'
				SET @resultID= 0
				GOTO label1
			END

			--Retrieve Assessment Approach
			If @assessmentAction = 't' -- Assessment
			BEGIN
				IF @initialAssessment = 't'
					SELECT @assessmentApproach = init_eff_test_approach_value_id,
							@curveType =init_assmt_curve_type_value_id,
							@curveSource = init_curve_source_value_id,
							@pricePoints =init_number_of_curve_points 
					FROM #HedgeRel
				ELSE
					SELECT @assessmentApproach = on_eff_test_approach_value_id,
							@curveType = on_assmt_curve_type_value_id,
							@curveSource =on_curve_source_value_id,
							@pricePoints = on_number_of_curve_points  
					FROM #HedgeRel

				SELECT @relId = profile_for_value_id FROM #HedgeRel

				--Check for change series.. if so make it original  and turn on  the change series flag

				IF @curveType = 80
				BEGIN
					SET @curveType = 77 --Forward_Prices
					SET @useChangeSeries = 't'
				END
				ELSE IF @curveType = 81
				BEGIN
					SET @curveType = 76 --Monthly_Prices
					SET @useChangeSeries = 't'
				END
				ELSE IF @curveType = 82
				BEGIN
					SET @curveType = 75 --Spot_Prices
					SET @useChangeSeries = 't'
				END

				---  AssessmentType.Dollar_Offset = 302; AssessmentType.User_Defined=303
				EXEC spa_print '@assessmentApproach:', @assessmentApproach
				If @assessmentApproach =302 Or @assessmentApproach =303
				BEGIN
					--no need to run regression
					RAISERROR (50005, -- Message id.
								10, -- Severity,
								1, -- State,
								'Trapped error'); 
					EXEC spa_print '999'
				END

				IF EXISTS(SELECT inherit_assmt_eff_test_profile_id FROM #HedgeRel WHERE inherit_assmt_eff_test_profile_id Is not NULL)
				BEGIN
					SELECT @inherit_assmt_eff_test_profile_id=inherit_assmt_eff_test_profile_id FROM #HedgeRel
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, [source], [type], [description], nextsteps) 
					VALUES(@process_id,'Warning', 'Hedge Assessment', 'retrieveHedegeRelationship',
						'Ignored', 'Assessment not performed for ID: '+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
						CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + 
						' since it inherits value FROM another relationship type ID: '
						+ CAST(@inherit_assmt_eff_test_profile_id as VARCHAR),'')
					SET @assessmentApproach = 0 --AssessmentType.Value_Inherited
					EXEC spa_print '1010'
					RAISERROR (50005, -- Message id.
							10, -- Severity,
							1, -- State,
							'Trapped error'); 

				END
			END
			ELSE  -- Transaction Generation
			BEGIN
				SET @curveType = 77 --AssessmentCurveType.Forward_Prices
				--DEFINE A PRICE CURVE SOURCE FOR GENERATION
				SET @pricePoints = 1
				--No need to convert to same UOM and currency for transaction generation
				UPDATE #HedgeRel SET convert_uom_value_id=NULL --,fas_eff_hedge_rel_type=NULL
			END
			SELECT @hedgeRelationshipName = eff_test_name,
				@hedgeAssessmentPriceType = hedge_test_price_option_value_id,                                --Retrieve common Assement values 
				@itemAssessmentPriceType = item_test_price_option_value_id,
				@hedgeToItemConvFactor = ISNULL(hedge_to_item_conv_factor ,1),
				@itemPricingValueId = ISNULL(item_pricing_value_id, -1),
				@hedgeFixedPriceValueId = ISNULL(hedge_fixed_price_value_id, -1),
				@itemCounterpartyID = ISNULL(item_counterparty_id, -1),
				@itemTraderID = ISNULL(item_trader_id, -1),
				@genCurveSourceID = ISNULL(gen_curve_source_value_id, -1),
				@commonUOMID = ISNULL(convert_uom_value_id, -1),
				@uom_name = ISNULL(uom_name, ''),
				@commonCurrencyID = ISNULL(convert_currency_value_id, -1),
				@commonCurrencyName = ISNULL(currency_name, ''),
				@hedgeAsDependent = CASE WHEN use_hedge_as_depend_var='y' THEN 't' ELSE 'f' END
			FROM #HedgeRel

			IF @calc_level = 1
				SET @statusDes = 'Hedge assessment calculation completed for Hedging Relationship Type ID: '  
				+ dbo.FNATRMWinHyperlink('a', CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END, ISNULL(@hedgeRelationshipName, ''), ABS(@hedgeRelationshipId),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0)
				--	+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId)
			ELSE IF @calc_level = 2
				SET @statusDes = 'Hedge assessment calculation completed for Hedging Relationship ID: ' + @hyper_link_id + ' using Hedging Relationship Type ' 
					+ dbo.FNATRMWinHyperlink('a', CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END, ISNULL(@hedgeRelationshipName, ''), ABS(@hedgeRelationshipId),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0)
					--+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId)
			ELSE IF @calc_level = 3
				SET @statusDes = 'What-If hedge assessment calculation completed for Test Relationship ID: ' 
					+ dbo.FNATRMWinHyperlink('a', CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END, ISNULL(@hedgeRelationshipName, ''), ABS(@hedgeRelationshipId),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0)
					--+ dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId)
			ELSE IF @calc_level = 4
				SET @statusDes ='DEFINE THIS////'
			ELSE
				SET @statusDes = 'ERROR: CALC LEVEL NOT SUPPORTED'

			--retrieve hedges
			---------------------------retrieveHedgeRelationshipDetail("h") ("i")
			--SET @runDate=dbo.fnadateformat(@runDate)

			-- Transaction generation
			IF @assessmentAction = 'f'
				SET @assessmentPriceType =0  --TestingPricingOption.Get_All
			ELSE
				SET @assessmentPriceType = @hedgeAssessmentPriceType
			--print 'eeee'

			IF @curveType <>79 AND @curveType <> 85
			BEGIN
		
			INSERT INTO #HedgeRel_detail 
			EXEC spa_get_assmt_rel_type_detail @calc_level, @link_id, @hedgeRelationshipId, 'h', @assessmentPriceType, @runDate

			IF NOT EXISTS (SELECT 1 FROM #HedgeRel_detail)
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, [type], description, nextsteps) 
				SELECT @process_id,'Error', 'Retrieve Hedges', 'retrieveHedgeRelationshipDetail',
							'Application Error', 'Failed to retrieve Hedging relationship type (Hedge) with ID: '+
				dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for link id:' + @hyper_link_id + ' does not exist.','Please check the Hedging Relationship Types / Designation of Hedge.' 
				EXEC spa_print '811'
				SET @resultID = 0
				GOTO label1
			END

			----########## This needs to be revised.
			---###############################################
			--					IF (SELECT count(*) FROM #HedgeRel_detail WHERE hedge_or_item = 'h'	and strip_month_from > @runDate) = 0  AND @curveType=77
			--					BEGIN
			--						INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, [type], description, nextsteps) 
			--						SELECT @process_id,'Warning', 'Retrieve Hedges', 'retrieveHedgeRelationshipDetail',
			--									'Ignored', 'Expired relationship skipped for Hedging relationship type (Hedge) with ID: '+
			--						dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for link id: ' + @hyper_link_id + ' for as of date ' + @runDate,'Please check the Hedging Relationship Types / Designation of Hedge.' 
			--						EXEC spa_print '811'
			--						SET @resultID= 0
			--						GOTO label1
			--					END

			END

			IF @assessmentAction = 't'
				SET @assessmentPriceType = @itemAssessmentPriceType

			--AssessmentCurveType.Delta_Und_PNL And curveType <> AssessmentCurveType.Cum_Und_PNL
			IF @curveType <> 79 AND @curveType <> 85
			BEGIN					
				INSERT INTO #HedgeRel_detail 
				EXEC spa_get_assmt_rel_type_detail @calc_level, @link_id, @hedgeRelationshipId, 'i', @assessmentPriceType, @runDate

				IF NOT EXISTS (SELECT 1 FROM #HedgeRel_detail WHERE hedge_or_item = 'i')
				BEGIN
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, [type], description, nextsteps) 
					SELECT @process_id,'Error', 'Retrieve Hedges', 'retrieveHedgeRelationshipDetail',
								'Application Error', 'Failed to retrieve Hedging relationship type (item) with ID: '+
					dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for link id: ' + @hyper_link_id + ' does not exist.','Please check the Hedging Relationship Types / Designation of Hedge.' 
					EXEC spa_print '812'
					SET @resultID= 0
					GOTO label1
				END
			END

			--RETRIEVE CONVERSION FACTOR
			IF @commonUOMID <> -1 AND @curveType <> 79 And @curveType <> 85
			BEGIN
				UPDATE #HedgeRel_detail SET conversion_factor = NULL WHERE source_uom_id <> @commonUOMID
				
				UPDATE #HedgeRel_detail SET conversion_factor = vuc.conversion_factor  
				FROM #HedgeRel_detail t inner join volume_unit_conversion vuc on vuc.from_source_uom_id=t.source_uom_id and  vuc.to_source_uom_id=@commonUOMID
				WHERE source_uom_id <> @commonUOMID
				
				UPDATE #HedgeRel_detail SET conversion_factor=(1/vuc.conversion_factor) 
				FROM #HedgeRel_detail t inner join volume_unit_conversion vuc on vuc.from_source_uom_id=@commonUOMID and  vuc.to_source_uom_id=t.source_uom_id
				WHERE source_uom_id <> @commonUOMID
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, [type], description, nextsteps) 
				SELECT @process_id,'Error', 'Hedge Assessment', 'retrieveUOMConversionFactor',
					'Data Error', 'No UOM conversion factor from  '+uom_name+' To ' + @uom_name + ' ID:' +
					dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END, CAST(@hedgeRelationshipId AS VARCHAR) + '/' + ISNULL(@hedgeRelationshipName, ''), @hedgeRelationshipId)
					+ ' for as of date '+@runDate
					, 'Please insert UOM factor for ' + uom_name + ' To ' + @uom_name + ' or do not use UOM conversion feature while defining hedging relationship type.' 
				FROM #HedgeRel_detail WHERE conversion_factor IS NULL AND source_uom_id <> @commonUOMID
				
				UPDATE #HedgeRel_detail SET conversion_factor = 1  WHERE conversion_factor IS NULL AND source_uom_id <> @commonUOMID
			END 
		END TRY

		--error trap in getting relationship level
		BEGIN CATCH
			IF ERROR_NUMBER()<>50005
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
				VALUES(@process_id,'Error', 'Hedge Assessment', 'retrieveHedegeRelationship',
						'DB Error (' + CAST(ERROR_LINE() AS VARCHAR) + ')', ERROR_MESSAGE() + ' ID: '
						+ dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END
						, CAST(@hedgeRelationshipId AS VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for as of date ' + @runDate
						, 'Please contact technical support.')
			END
		END CATCH
--		BEGIN try

		EXEC spa_print '@calc_level:', @calc_level
		EXEC spa_print '@relId:', @relId
		EXEC spa_print '@link_id:', @link_id

		--AssessmentType.Dollar_Offset
		If @assessmentApproach = 302
		BEGIN
			IF @calc_level = 1
				SET @statusDes = 'Hedge assessment calculation skipped for Dollar Offset method for Hedging Relationship Type ID: '  
					--+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId)
					+ dbo.FNATRMWinHyperlink('a', CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END, ISNULL(@hedgeRelationshipName, ''), ABS(@hedgeRelationshipId),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0)
			ELSE IF @calc_level = 2
				SET @statusDes = 'Hedge assessment calculation skipped for Dollar Offset method for Hedging Relationship ID: ' + @hyper_link_id + ' using Hedging Relationship Type ' 
					--+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId)
					+ dbo.FNATRMWinHyperlink('a', CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END, ISNULL(@hedgeRelationshipName, ''), ABS(@hedgeRelationshipId),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0)
			ELSE IF @calc_level = 3
				SET @statusDes = 'Hedge assessment calculation skipped for Dollar Offset method for Test Relationship ID: ' 
					--+ dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId)
					+ dbo.FNATRMWinHyperlink('a', CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END, ISNULL(@hedgeRelationshipName, ''), ABS(@hedgeRelationshipId),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0)
			ELSE IF @calc_level = 4
				SET @statusDes ='DEFINE THIS////'
			ELSE
				SET @statusDes = 'ERROR: CALC LEVEL NOT SUPPORTED'

			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
			VALUES(@process_id,'Error', 'Hedge Assessment', 'runAssessment',
					'Error', @statusDes + ' for as of date ' + @runDate,'')

			/*
			SET @resultID = -1
			If (@calc_level = 1 Or (@calc_level = 3 And @relId = -1))
			BEGIN 
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
					VALUES(@process_id,'Error', 'Hedge Assessment', 'Dollar Offset Assessment',
								'Application Error', 'Dollar offset assessment not supported at hedging relationship type level or for what-if analysis non hedging relationship.'+' ID: '+
								dbo.FNAHyperLinkText(50,CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for as of date ' + @runDate, 'Please contact technical support.')
			END
			ELSE
			BEGIN
				If (@calc_level = 3 And @relId <> @link_id)
					SET  @link_id = @relId
				If @calc_level = 3
					INSERT INTO #Status exec spa_Collect_Link_Deals_PNL_OffSetting_Links @runDate, NULL, NULL, NULL, NULL, @process_id, 'm', 0, @user_name, 'a', @link_id,@eff_test_profile_id
				ELSE
					INSERT INTO #Status exec spa_Collect_Link_Deals_PNL_OffSetting_Links @runDate, NULL, NULL, NULL, NULL, @process_id, 'm', 0, @user_name, 'a', @link_id
				If (SELECT count(*) FROM #Status)= 0
				BEGIN
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
					VALUES(@process_id,'Error', 'Hedge Assessment', 'Dollar Offset Assessment',
								'Application Error', 'Dollar offset assessment calculation failed '+' ID: '
								+dbo.FNAHyperLinkText(50,
						CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for as of date ' + @runDate, 'Please contact technical support.')
				END
				ELSE
				BEGIN
					IF EXISTS (SELECT status FROM #Status WHERE status='Success')
					BEGIN
						SELECT @resultID = CAST([Message] as int) FROM #Status WHERE status='Success'
						INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
						VALUES(@process_id,'Success', 'Hedge Assessment', 'runAssessment',
								'Successful', @statusDes + ' for as of date ' + @runDate,'')

					END
					ELSE
						INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
						VALUES(@process_id,'Error', 'Hedge Assessment', 'Dollar Offset Calculation',
								'Application Error','Dollar Offset Assessment calculation failed. ID: '
								+dbo.FNAHyperLinkText(50,
						CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for as of date ' + @runDate, 'Please contact technical support.')
				            
				END
			END
			*/
			EXEC spa_print '222'
			--Return @resultID
			GOTO label1
		END
		----AssessmentType.UNDERLYING_TERMS
		ELSE IF @assessmentApproach = 317 
		BEGIN
			SET @resultID = -1
			INSERT INTO #status EXEC spa_run_eff_test_underlying_terms @link_Id, @eff_test_profile_id, @runDate, @initialOngoingAssessment
			IF (SELECT COUNT(1) FROM #Status) = 0
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
				VALUES(@process_id,'Error', 'Hedge Assessment', 'Underlying Terms Assessment',
						'Application Error','Assessment test using Underlying Terms failed ID: '
						+ dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END
						, CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''), @hedgeRelationshipId) + ' for as of date ' + @runDate
						, 'Please contact technical support.')
			ELSE
			BEGIN
				IF EXISTS(SELECT errorcode FROM #Status WHERE CAST(errorcode AS INT) <> -1)
				BEGIN
					SELECT @resultID =  CAST(errorcode AS INT) FROM #Status
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
					VALUES(@process_id,'Error', 'Hedge Assessment', 'runAssessment',
							'Successful',@statusDes+ ' for as of date ' + @runDate,'')
				END
				ELSE
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
					VALUES(@process_id,'Error', 'Hedge Assessment', 'Underlying Terms Assessment',
							'Application Error','Assessment using Underlying Terms failed. ID: '
							+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
					CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for as of date ' + @runDate, 'Please contact technical support.')
			END
			EXEC spa_print '333'
			GOTO label1
		END
		ELSE IF @assessmentApproach = 303  --AssessmentType.User_Defined
		BEGIN
					
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
			VALUES(@process_id,'Info', 'Hedge Assessment', 'User Defined Assessment',
					'Additional Info','Assessment using User Defined. ID: ' +
					+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
					CAST(@hedgeRelationshipId AS VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for as of date ' + @runDate, 'Please contact technical support.')
			EXEC spa_print '444'
			SET @resultID= 0
			GOTO label1
		END
		ELSE IF @assessmentApproach = 0  --AssessmentType.Value_Inherited( value inherited FROM other)
		BEGIN				
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
			VALUES(@process_id,'Info', 'Hedge Assessment', 'Value Inherited Assessment',
					'Additional Info','Assessment using Value Inherited. ID: ' + dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
						CAST(@hedgeRelationshipId AS VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for as of date ' + @runDate, 'Please contact technical support.')
			EXEC spa_print '555'
			--Return 0
			SET @resultID= 0
			GOTO label1
		END
		ELSE IF @assessmentApproach = 304  --AssessmentType.NO_INEFFECTIVENESS(This would be perfect hedge)
		BEGIN 				
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
			VALUES(@process_id,'Info', 'Hedge Assessment', 'NO INEFFECTIVENESS Assessment',
					'Additional Info','Assessment using NO INEFFECTIVENESS. ID: ' + dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
						CAST(@hedgeRelationshipId AS VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''), @hedgeRelationshipId) + ' for as of date ' + @runDate, 'Please contact technical support.')
			--Return 0		
			EXEC spa_print '666'
			SET @resultID= 0
			GOTO label1
		END

--		END try
--		BEGIN catch
--		END catch
		--create structure to retrieve prices and calculate
		---- createResultSet()
--		BEGIN try

		--Collect prices
		-- AssessmentCurveType.Delta_Und_PNL=79;  AssessmentCurveType.Cum_Und_PNL=85
		IF @curveType = 79 OR @curveType = 85
		BEGIN
			--collectDeltaPNLPrices()
			IF @initialAssessment = 't'
				SET @inception_ongoing = 'i'
			ELSE
				SET @inception_ongoing = 'o'
			--print CAST(@calc_level as VARCHAR)
			--EXEC spa_print 'EXEC spa_get_delta_pnl_for_regression ' +CAST(@hedgeRelationshipId as VARCHAR)+', 1,'+CAST(@inception_ongoing as VARCHAR)
			--return

			IF @calc_level = 1
				INSERT INTO #Results ([date], xprice, yprice) EXEC spa_get_delta_pnl_for_regression @hedgeRelationshipId, 1, @inception_ongoing, 'u', @rundate
			ELSE
				INSERT INTO #Results ([date], xprice, yprice) EXEC spa_get_delta_pnl_for_regression @link_Id , 2, @inception_ongoing, 'u', @rundate
	 
			IF NOT EXISTS (SELECT 1 FROM #RESULTS)
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, [type], description, nextsteps) 
				VALUES ( @process_id,'Error', 'collectPrices', 'spa_get_delta_pnl_for_regression',
							'Application Error', 'PNL series not found to run regression for ID:'+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
						CAST(@hedgeRelationshipId AS VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + 
							' for as of date '+@rundate,'. Please check the Link in Designation of Hedge.') 
				--SELECT * FROM #RESULTS WHERE (XPRICE IS NULL) OR (YPRICE IS NULL)
				--SELECT * FROM fas_eff_ass_test_run_log WHERE process_id=@process_id
				EXEC spa_print '880'

				SET @resultID= 0
				GOTO label1
			END

			SELECT @tmp_value = COUNT(*) + SUM(XPrice) + SUM(YPrice) FROM #Results
							
			IF ISNULL(@tmp_value, 0) = 0
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
				VALUES(@process_id,'Error', 'Hedge Assessment', 'collectPrices',
						'Data Error','PNL series not found for hedging  relationship ID: '+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
						CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for as of date ' + @runDate
						, 'Please import mssing prices before running assessment.')
			END
		END
		ELSE --collectPrices()
		BEGIN
			EXEC spa_print @curveType
			SET @ST='INSERT INTO #TMPX SELECT a.[price_date], SUM(a.[XPrice]) 
					FROM (SELECT
						dbo.FNAGetSQLStandardDate(as_of_date) [price_date], '+
						CASE WHEN @curveType=77 THEN 
							'AVG(CASE WHEN maturity_date between strip_month_from AND strip_month_to THEN curve_value ELSE NULL END) 
								* MAX(volume_mix_percentage) * MAX(uom_conversion_factor) * ' + CAST(@hedgeToItemConvFactor AS VARCHAR) +' AS [XPrice]'
						ELSE
							'AVG(curve_value) * MAX(volume_mix_percentage) * MAX(uom_conversion_factor) * ' + CAST(@hedgeToItemConvFactor AS VARCHAR) + ' AS [XPrice]'
						END
						+ ' FROM #HedgeRel_detail hd 
						LEFT JOIN source_price_curve spc on hd.source_curve_def_id = spc.source_curve_def_id
						WHERE as_of_date <= ''' + dbo.FNAGetSQLStandardDate(@runDate) + ''''+-- and spc.assessment_curve_type_value_id='+CAST(@curveType as VARCHAR)+
						CASE WHEN @curveType <> 76 THEN '' ELSE ' AND spc.as_of_date = spc.maturity_date AND DAY(spc.maturity_date) = 1' END +
						' AND curve_source_value_id = ' + CAST(@curveSource AS VARCHAR) + ' and hedge_or_item = ''' + CASE WHEN @hedgeAsDependent = 't' THEN 'i' ELSE 'h' END + '''
						GROUP BY dbo.FNAGetSQLStandardDate(as_of_date), hd.source_curve_def_id) a 
					GROUP BY a.[price_date]'
			EXEC spa_print @ST
			EXEC(@ST)

			IF NOT EXISTS (SELECT 1 FROM #TMPX)
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, [type], description, nextsteps) 
				VALUES ( @process_id,'Error', 'Hedge Assessment', 'collectPrices',
						'Application Error', 'No data found of Hedge/Hedge Item for ID:' + dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
						CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + 
						' for as of date ' + @rundate, 'Please check the price data.') 
				--SELECT * FROM #RESULTS WHERE (XPRICE IS NULL) OR (YPRICE IS NULL)
				--SELECT * FROM fas_eff_ass_test_run_log WHERE process_id=@process_id
				EXEC spa_print '882'
				SET @resultID = 0
				GOTO label1
			END

			SET @ST = ' INSERT INTO #TMPY 
						SELECT a.[price_date], SUM(a.[YPrice]) 
						FROM (SELECT dbo.FNAGetSQLStandardDate(as_of_date) [price_date], ' +
								CASE WHEN @curveType = 77 THEN 
									'AVG(CASE WHEN maturity_date BETWEEN strip_month_from AND strip_month_to THEN curve_value ELSE NULL END)
										* MAX(volume_mix_percentage) * MAX(uom_conversion_factor) AS [YPrice]'
								ELSE
									'AVG(curve_value) * MAX(volume_mix_percentage) * MAX(uom_conversion_factor) AS [YPrice]'
								END
							+ ' FROM #HedgeRel_detail hd left join source_price_curve spc on hd.source_curve_def_id=spc.source_curve_def_id
							WHERE as_of_date <= ''' + @runDate + ''''+--''' and spc.assessment_curve_type_value_id='+CAST(@curveType as VARCHAR)+
								CASE WHEN @curveType <> 76 THEN '' ELSE ' AND spc.as_of_date=spc.maturity_date AND DAY(spc.maturity_date) = 1' END +
								' AND curve_source_value_id = '  + CAST(@curveSource AS VARCHAR)+ ' AND hedge_or_item = ''' + CASE WHEN @hedgeAsDependent = 't' THEN 'h' ELSE 'i' END +'''
							GROUP BY dbo.FNAGetSQLStandardDate(as_of_date), hd.source_curve_def_id) a 
						GROUP BY a.[price_date]'
			EXEC spa_print @ST
			EXEC(@st)
					
			--SELECT * FROM #HedgeRel_detail
			--SELECT * FROM #TMPX
			--SELECT * FROM #TMPY
			--return 
			IF NOT EXISTS (SELECT 1 FROM #TMPY)
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, [type], description, nextsteps) 
				VALUES (@process_id,'Error', 'Hedge Assessment', 'CollectPrices',
						'Application Error', 'No data found of Hedge Item for ID:'+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
						CAST(@hedgeRelationshipId AS VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + 
						' for as of date ' + @rundate, 'Please check the price Data.') 
				--SELECT * FROM #RESULTS WHERE (XPRICE IS NULL) OR (YPRICE IS NULL)
				--SELECT * FROM fas_eff_ass_test_run_log WHERE process_id=@process_id
				EXEC spa_print '881'
				SET @resultID= 0
				GOTO label1
			END

			SET @ST = ' INSERT INTO #RESULTS ([Date],XPrice,YPrice) 
						SELECT TOP ' + CAST(@pricePoints AS VARCHAR) + '
						COALESCE(X.[price_date],Y.[price_date]) [PRICE_DATE], X.XPRICE, Y.YPRICE 
						FROM #TMPX X 
						FULL JOIN #TMPY Y ON  X.[price_date] = Y.[price_date]
						ORDER BY COALESCE(X.[price_date],Y.[price_date]) DESC'
			EXEC(@ST)

			IF EXISTS (SELECT 1 FROM #RESULTS WHERE (XPRICE IS NULL))
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, [type], description, nextsteps) 
				SELECT @process_id,'Error', 'Hedge Assessment', 'collectPrices',
							'Data Error', 'No prices found of Hedge for ID:'
							+ dbo.FNATRMWinHyperlink('a', CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END, ISNULL(@hedgeRelationshipName, ''), ABS(@hedgeRelationshipId), NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0)+
							--+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + 
							' for as of date ' + [date], 
							'Please import missing prices before running assessment.' 
				FROM #RESULTS WHERE (XPRICE IS NULL)
				--SELECT * FROM #RESULTS WHERE (XPRICE IS NULL) OR (YPRICE IS NULL)
				--SELECT * FROM fas_eff_ass_test_run_log WHERE process_id=@process_id
				EXEC spa_print '888'
				SET @resultID= 0
				GOTO label1
			END
			IF EXISTS (SELECT 1 FROM #RESULTS WHERE (YPRICE IS NULL))
			BEGIN
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, [type], description, nextsteps) 
				SELECT @process_id,'Error', 'Hedge Assessment', 'collectPrices',
						'Data Error', 'No prices found of Hedge Item for ID:'+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
						CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''), @hedgeRelationshipId) + 
						' for as of date ' + [date],'Please import missing prices before running assessment.' 
				FROM #RESULTS WHERE (YPRICE IS NULL)
				--SELECT * FROM #RESULTS WHERE (XPRICE IS NULL) OR (YPRICE IS NULL)
				--SELECT * FROM fas_eff_ass_test_run_log WHERE process_id=@process_id
				EXEC spa_print '888'
				SET @resultID= 0
				GOTO label1
			END
		END

		----runRegression
		UPDATE #Results SET X2Price=XPrice*XPrice,Y2Price=YPrice*YPrice,XYPrice=XPrice*YPrice

		SELECT @SSx		= SUM(X2Price) - ((SUM(XPrice) * SUM(XPrice)) / COUNT(1)),
				@SSy	= SUM(Y2Price) - ((SUM(YPrice) * SUM(YPrice)) / COUNT(1)),
				@SCxy	= SUM(XYPrice) - ((SUM(XPrice) * SUM(YPrice)) / COUNT(1)) 
		FROM #Results

		--SELECT @SSx,@SSy,@SCxy
		--SELECT * FROM #Results
		--return 
		SET @var=Sqrt(@SSx * @SSy)

		IF @var = 0
			SET @var = 0.00000000001

		SET @correlation = @SCxy / @var

		SET @RSQ = @correlation * @correlation
		SELECT @slope = ((COUNT(1) * SUM(XYPrice)) - (SUM(XPrice) * SUM(YPrice))), @var = ((COUNT(1) * SUM(X2Price)) - (SUM(XPrice) * SUM(XPrice))) FROM #Results
		
		IF @var=0
			SET @var = 0.00000000001

		SET @slope = @slope / @var

		SELECT @intercept = (SUM(YPrice) / COUNT(1)) - (@slope * (SUM(XPrice) / COUNT(1))) FROM #Results

		SELECT @DF = ABS(COUNT(1) - 2) FROM #Results
		UPDATE #Results SET XSLine=XPrice, YSLine=@intercept + (@slope * XPrice)
		SELECT @sumYError2 = SUM(POWER((YPrice - YSLine), 2)) FROM #Results

		SET @TVALUE = 0
		SET @FVALUE = 0

		--For TValue and FValue atleast  10 price series required 
		IF @DF >= 8 
		BEGIN
		--TVALUE Calculation
		--SELECT * FROM #results
			SET @SError = SQRT(@sumYError2 / @DF)
			SET @var = SQRT(@SSx)
			IF @var = 0
				SET @var = 0.00000000001
			SET @SStdError = @SError / @var
			--The following two  statments added to avoid divide by 0 errors
			IF @SError = 0 
				SET @SError = 0.00000000001
			IF @SStdError = 0
				SET @SStdError = 0.00000000001
			SET @TVALUE = @slope / @SStdError

			--FVALUE Calculation
			SET @var = @SSx
			
			IF @var = 0
				SET @var = 0.00000000001
			SET @SSR = POWER(@SCxy, 2) / @var
			-- MSR = SSR/1 for one independent variable
			SET @MSR = @SSR
			SET @FVALUE = @MSR / POWER(@SError, 2)
		END 
 		--	SELECT @correlation correlation , @RSQ RSQ, @slope slope, @intercept intercept, @TVALUE TVALUE, @FVALUE FVALUE,@DF df
		--return 
		-- Round to 2 decimal places
		SET @correlation = ROUND(@correlation, 2)
		SET @RSQ = ROUND(@RSQ, 2)
		SET @slope = ROUND(@slope, 2)
		SET @intercept = ROUND(@intercept, 2)
		SET @TVALUE = ROUND(@TVALUE,2)
		SET @FVALUE = ROUND(@FVALUE,2)

		--SELECT @correlation correlation , @RSQ RSQ, @slope slope, @intercept intercept, @TVALUE TVALUE, @FVALUE FVALUE,@DF df
		--RETURN

		IF @assessmentApproach = 300 --AssessmentType.Correlation
			SET @assessmentResultValue = @correlation
		ELSE IF @assessmentApproach = 301 --AssessmentType.RSQ
			SET @assessmentResultValue = @RSQ
		ELSE IF @assessmentApproach = 315 -- AssessmentType.RSQ_AND_SLOPE
		BEGIN
			SET @assessmentResultValue = @RSQ
			SET @assessmentAdditionalResultValue = @slope
		END
		ELSE IF @assessmentApproach =316 --AssessmentType.CORRELATION_AND_SLOPE
		BEGIN
			SET @assessmentResultValue = @correlation
			SET @assessmentAdditionalResultValue = @slope
		END
		ELSE IF @assessmentApproach = 305 --AssessmentType.T_TEST
			SET @assessmentResultValue = @TVALUE
		ELSE IF @assessmentApproach = 306 --AssessmentType.F_TEST
		BEGIN
			SET @assessmentResultValue = @FVALUE
		END
		ELSE IF @assessmentApproach = 307 --AssessmentType.RSQ_AND_T_TEST
		BEGIN
			SET @assessmentResultValue = @RSQ
			SET @assessmentAdditionalResultValue = @TVALUE
		END
		ELSE IF @assessmentApproach = 308 --AssessmentType.RSQ_AND_F_TEST
		BEGIN
			SET @assessmentResultValue = @RSQ
			SET @assessmentAdditionalResultValue = @FVALUE
		END
		ELSE IF @assessmentApproach = 309 --AssessmentType.CORRELATION_AND_T_TEST
		BEGIN
			SET @assessmentResultValue = @correlation
			SET @assessmentAdditionalResultValue = @TVALUE
		END
		ELSE IF @assessmentApproach = 310 --AssessmentType.CORRELATION_AND_F_TEST
		BEGIN
			SET @assessmentResultValue = @correlation
			SET @assessmentAdditionalResultValue = @FVALUE
		END
		ELSE IF @assessmentApproach =311 --AssessmentType.CORRELATION_AND_T_TEST_SLOPE
		BEGIN
			SET @assessmentResultValue = @correlation
			SET @assessmentAdditionalResultValue = @TVALUE
			SET @assessmentAdditionalResultValue2 = @slope
		END
		ELSE IF @assessmentApproach = 312 --AssessmentType.CORRELATION_AND_F_TEST_SLOPE
		BEGIN
			SET @assessmentResultValue = @correlation
			SET @assessmentAdditionalResultValue = @FVALUE
			SET @assessmentAdditionalResultValue2 = @slope
		END
		ELSE IF @assessmentApproach = 313 --AssessmentType.RSQ_AND_T_TEST_SLOPE
		BEGIN
			SET @assessmentResultValue = @RSQ
			SET @assessmentAdditionalResultValue = @TVALUE
			SET @assessmentAdditionalResultValue2 = @slope
		END
		ELSE IF @assessmentApproach = 314 --AssessmentType.RSQ_AND_F_TEST_SLOPE
		BEGIN
			SET @assessmentResultValue = @RSQ
			SET @assessmentAdditionalResultValue = @FVALUE
			SET @assessmentAdditionalResultValue2 = @slope
		END
		ELSE
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
			VALUES(@process_id,'Error', 'Hedge Assessment', 'runRegression',
				'Application Error','Assement type not supported by this module. ID: ' + dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
				CAST(@hedgeRelationshipId AS VARCHAR) + '/' + ISNULL(@hedgeRelationshipName, ''),
				@hedgeRelationshipId) + ' for as of date ' + @runDate, 'Please contact technical support.')
			EXEC spa_print '111'
			SET @resultID=0
			GOTO label1
		END

		--For TValue and FValue atleast  10 price series required
		IF @assessmentApproach> 304 and @assessmentApproach< 315
		BEGIN 
			If @DF < 8 
				INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
				VALUES(@process_id,'Info', 'Hedge Assessment', 'TTest and FTest',
					'Additional Info','For TValue and FValue atleast 10 price series required and only found ' + CAST(@DF + 2 AS VARCHAR) +' series. ID: '+dbo.FNAHyperLinkText(CASE WHEN @calc_level = 3 THEN 10232610 ELSE 10231910 END,
					CAST(@hedgeRelationshipId as VARCHAR) + '/' + ISNULL(@hedgeRelationshipName,''),@hedgeRelationshipId) + ' for as of date ' + @runDate, 
					'Please contact technical support.')
		END
		
		INSERT INTO fas_eff_ass_test_results 
		VALUES(@hedgeRelationshipId, 
			@rundate, @initialOngoingAssessment, @assessmentResultValue, @assessmentAdditionalResultValue, 'n', @link_id, @calc_level,
			@assessmentApproach, @assessmentAdditionalResultValue2, @user_name, getdate(), @user_name, getdate())
		SET @resultID = SCOPE_IDENTITY()			

		IF @curveType <> 79 AND @curveType <> 85
		BEGIN
			---Now save the test  profile used for  running the regression
			EXEC spa_fas_eff_ass_test_results_profile 'i', @resultID, @calc_level, @link_Id, @hedgeRelationshipId, @assessmentPriceType, @runDate
		END

		INSERT INTO fas_eff_ass_test_results_process_header (eff_test_result_id,regression_intercept,regression_slope,regression_corr,regression_rsq,
															regression_tvalue,regression_fvalue,regression_DF)
		VALUES (@resultID,@intercept,@slope, @correlation,@RSQ,@TVALUE,@FVALUE ,@DF)

		INSERT INTO fas_eff_ass_test_results_process_detail (eff_test_result_id,price_date,x_series,y_series,x_reg_series,y_reg_series)
		SELECT @resultID,Date,XPrice,YPrice,XSLine,YSLine FROM #Results

		--				SELECT @resultID,Date,XPrice,YPrice,XSLine,YSLine FROM #Results
		--		END try
		--		BEGIN catch
		--		if error_number()<>50005
		--		BEGIN
		--			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
		--			VALUES(@process_id,'Error', 'Hedge Assessment', 'RunRegression',
		--						'DB Error ('+CAST(ERROR_LINE() AS VARCHAR)+')', error_message() + ' ID: '+
		--						CAST(@hedgeRelationshipId as VARCHAR) + '/' + @hedgeRelationshipName + ' for as of date ' + @runDate, 'Please contact technical support.')
		--		END
		--		END catch



		LABEL1:
		INSERT INTO #Result_ID (R_ID) values(@resultID)
		IF @resultID>0
		BEGIN
			IF NOT EXISTS (SELECT status FROM #Status WHERE status='Success')
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
			VALUES(@process_id,'Success', 'Hedge Assessment', 'runAssessment', 'Successful', @statusDes + ' for as of date ' + @runDate,'')
		END
		--SELECT * FROM #HedgeRel_detail
		--SELECT * FROM #HedgeRel
		--return
		--	END try --loop level
		--	BEGIN catch
		--		if ERROR_number()<>50005
		--		INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
		--		VALUES(@process_id,'Error', 'Hedge Assessmentllllllllll', 'runAssessment_main',
		--					'DB Error(line no:'+CAST(ERROR_line() as VARCHAR)+')', ERROR_MESSAGE()+'(assessment ID:'+CAST(@eff_test_profile_id as VARCHAR)+
		--			' Link ID:'+CAST(@link_id as VARCHAR)+' Calc. level:'+CAST(@calc_level as VARCHAR) , '')
		--
		--	END catch



		--			SET @desc='<a target="_blank" href="./dev/spa_html.php?__user_name__=' + @user_name +       
		--				 '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''''   + '">' +       
		--					  'Run Assessment completed successfully  on '+dbo.FNAUserDateFormat(@runDate, @user_name) + '.'+ 
		--					  '.</a>'
		--			EXEC  spa_message_board 'i', @user_name,NULL, 'Run Assessmentaa ',      
		--			   @desc, '', '', 's', 'Run Assessment',NULL,@process_id,'u'
		FETCH NEXT FROM tblCursor into @eff_test_profile_id,@link_id,@calc_level
	END
	CLOSE tblCursor
	DEALLOCATE tblCursor

	LABELEND:
	DECLARE @stat CHAR(1)
	SET @stat = 'e'

	SELECT @ErrorNo = SUM(CASE WHEN code='Error' THEN 1 ELSE 0 END),
		@WarningNo  = SUM(CASE WHEN code='Warning' THEN 1 ELSE 0 END),
		@SuccessNo  = SUM(CASE WHEN code='Success' THEN 1 ELSE 0 END) 
	FROM fas_eff_ass_test_run_log 
	WHERE process_id=@process_id --and code='Error'

	SET @desc = 'No data found to Run Assessment  for this criteria selection..'
	IF @ErrorNo <> 0
		--SET @desc='Run Assessment completed with error'
		SET @desc = 'Error found while running assessment of hedge effectiveness'
	ELSE IF @WarningNo <> 0
	BEGIN
		SET @desc = 'Run Assessment completed with warnings'
		SET @stat = 's'
	END
	ELSE IF (SELECT COUNT(1) FROM #assessments_mult) > 0
	BEGIN
		SET @desc = 'Run Assessment completed successfully'
		SET @stat = 's'
	END
	ELSE
		SET @desc = 'No data found to Run Assessment  for Assessment ID: ' + CAST(ISNULL(@eff_test_profile_id, '') AS VARCHAR)

	SET @url_desc = ''--'View Result...'      
	SET @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''''      
	
	DECLARE @temptablequery VARCHAR(500)
	SET @temptablequery = 'EXEC '+DB_NAME()+'.dbo.spa_fas_eff_ass_test_run_log ''' + @process_id + ''''
	
	SET @url_desc = ''--dbo.FNAHyperLinkText(10232400,'View Result...',1) 
	SET @desc = '<a target="_blank" href="' + @url + '">' + @desc + ' on ' + dbo.FNAUserDateFormat(@runDate, @user_name) + '.'+ 
			  '.</a>'
			  
	IF @is_batch = 1 
		EXEC  spa_message_board 'u', @user_name,NULL, 'Run Assessment ',@desc, @url_desc, '', @stat, @process_id,NULL,@process_id,'u','n',@temptablequery,'y'  
	ELSE
	BEGIN
		IF ISNULL(@ErrorNo, 0) <> 0 OR ISNULL(@WarningNo, 0) <> 0
			EXEC  spa_message_board 'i', @user_name,NULL, 'Run Assessment ',@desc, @url_desc, '', @stat, 'Run Assessment', NULL, @process_id, 'u' 
		ELSE
			DELETE fas_eff_ass_test_run_log WHERE process_id = @process_id
	END

	IF @ErrorNo <> 0
	BEGIN
		SET @url_desc='<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''  +@process_id + '''">Click here...</a>'
			SELECT 'Error' ErrorCode, 'Run Assessment' Module, 
				'runAssessment_main' Area, 'DB Error' Status, 
				'Run Assessment completed with error, Please view this report ' + @url_desc Message, '' Recommendation
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, 'Run Assessment', 
			'runAssessment_main', 'Success', 
			@desc, ''
	END
	--print 'succ' 

	--END try  --procedure level
	--BEGIN catch
	--	if ERROR_number()<>50005
	--    INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, type, description, nextsteps) 
	--	VALUES(@process_id,'Error', 'Hedge Assessmentaaaaa', 'runAssessment_main',
	--                'DB Error(line no:'+CAST(ERROR_line() as VARCHAR)+')', ERROR_MESSAGE()+'(assessment ID:'+CAST(@eff_test_profile_id as VARCHAR)+
	--		' Link ID:'+CAST(@link_id as VARCHAR)+' Calc. level:'+CAST(@calc_level as VARCHAR) , '')
	--
	--	SET @url_desc = 'Detail...'      
	--	SET @desc='Run Assessment completed with error'
	--
	--	SET @url = './dev/spa_html.php?__user_name__=' + @user_name +       
	--		 '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''''      
	--	SET @desc = '<a target="_blank" href="' + @url + '">' +       
	--			  @desc +'('+ ERROR_MESSAGE()+')'+ ' on '+dbo.FNAUserDateFormat(@runDate, @user_name) + '.'+ 
	--			  '.</a>'
	----print @desc
	--	EXEC  spa_message_board 'i', @user_name,  
	--			   NULL, 'Run Assessment',      
	--			   @desc, '', '', 'e', 'Run Assessment',NULL,@process_id,'u'  
	--
	--END catch

GO