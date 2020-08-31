IF OBJECT_ID('spa_Collect_Link_Deals_PNL_OffSetting_Links') IS NOT NULL
	DROP PROC dbo.[spa_Collect_Link_Deals_PNL_OffSetting_Links]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
Collect all the links and deals and prepare all paramaters for measurement process.
	Parameters: 
	@as_of_date					: Date to run the proces
	@assessment_date			: Assessment date
	@sub_entity_id				: Subsidiary Entity ids
	@strategy_entity_id			: Strategy Entity ids
	@book_entity_id				: Book Entity ids
	@process_id					: Unique Identidier
	@dedesignation_calc			: TBD
	@print_diagnostic			: Print SQL statement for Debug process
	@user_login_id				: Username
	@what_if					: TBD
	@link_filter_id				: Link ids filter
	@what_if_assmt_profile_id	: TBD
	@eff_pnl_all				: TBD
	@eff_month_from				: Effective date from
	@eff_month_to				: Effective dato to		

*/
CREATE PROC  [dbo].[spa_Collect_Link_Deals_PNL_OffSetting_Links] 
	@as_of_date					VARCHAR(20), 
	@assessment_date			VARCHAR(15), 
	@sub_entity_id				VARCHAR(MAX) = NULL, 
	@strategy_entity_id			VARCHAR(MAX) = NULL, 
	@book_entity_id				VARCHAR(MAX) = NULL, 
	@process_id					VARCHAR(50), 
	@dedesignation_calc			CHAR(1),
	@print_diagnostic			INT = 0,
	@user_login_id				VARCHAR(50),
	@what_if					VARCHAR(1) = NULL,
	@link_filter_id				VARCHAR(5000) = NULL,
	@what_if_assmt_profile_id	INT = NULL,
	@eff_pnl_all				VARCHAR(1) = 'n',
	@eff_month_from				VARCHAR(20) = null,
	@eff_month_to				VARCHAR(20) = null
AS

--============Test==========================================
/*
drop table #basicinfo
drop table #temp_fas_link_header
drop table #ass_info
drop table #t_f_test_error
drop table #deal_leg_1
drop table #effpnldate 
drop table #Release_term_range
--drop table #ssbm_b
 DECLARE @as_of_date VARCHAR(20), @assessment_date VARCHAR(15), @sub_entity_id VARCHAR(100), 
 	@strategy_entity_id VARCHAR(100), 
 	@book_entity_id VARCHAR(100), @process_id VARCHAR(50), @dedesignation_calc CHAR(1),
 	@print_diagnostic INT,
 	@user_login_id VARCHAR(50),
 	@what_if VARCHAR(1),
 	@link_filter_id INT,
 	@what_if_assmt_profile_id INT,
	@eff_pnl_all VARCHAR(1),
	@eff_month_from VARCHAR(20),
	@eff_month_to VARCHAR(20)

 SET @as_of_date = '2009-10-31' --'2005-10-31' -- '2005-10-30' --
 SET	@assessment_date = null
 SET	@sub_entity_id = '6,16,17,77,795,1,9,772,781,787' --11 --'1' --'2' --'45' --'291' --'30' --null 
 SET	@strategy_entity_id = null --'60,61'--'299' --'292' --'228'
 SET	@book_entity_id = null--'787' --'56'
 SET	@process_id = '123456'
 SET	@dedesignation_calc ='m'
 SET	@print_diagnostic = 1
 SET	@user_login_id = 'farrms_admin'
 SET	@what_if = 'n'
 SET	@link_filter_id =435-- 116 --435 --520 --16 --166 --159 -- -- 746
 SET	@what_if_assmt_profile_id = null
 SET    @eff_pnl_all = 'n'


-- SELECT * from adiha_process.dbo.calcprocess_deal_pnl_farrms_admin_123456 WHERE source_deal_header_id = 1715
-- SELECT * from adiha_process.dbo.calcprocess_deals_farrms_admin_123456 WHERE link_id in (616, 619)
--SELECT * from adiha_process.dbo.aocirelease_schedule_farrms_admin_123456 WHERE per_d_pnl <> 1
drop table adiha_process.dbo.calcprocess_discount_factor_farrms_admin_123456
EXEC spa_Calc_Discount_Factor @as_of_date, null, null, null, 'adiha_process.dbo.calcprocess_discount_factor_farrms_admin_123456'
drop table adiha_process.dbo.calcprocess_deals_farrms_admin_123456
drop table adiha_process.dbo.calcprocess_deal_pnl_farrms_admin_123456
drop table adiha_process.dbo.selected_deals_farrms_admin_123456
drop table adiha_process.dbo.aocirelease_schedule_farrms_admin_123456
drop table adiha_process.dbo.process_books_farrms_admin_123456
drop table adiha_process.dbo.max_term_farrms_admin_123456
drop table adiha_process.dbo.link_deal_term_used_per_farrms_admin_123456
delete from measurement_process_status

drop table #tmp_deal
drop table #sum_item
drop table #eff_pnl_dates
drop table #sdd1
drop table #sdd2
drop table #d_cpr
drop table #d_max_pnl
drop table #prior_val
drop table #max_hedge_term
drop table #cp_aa
--Inventory Hedge Change
drop table #fully_inventory_aoci_released
/*drop table #missing_pnl_count*/
drop table #source_deal_detail
drop table #t_fdgl
drop table #cp_expired
drop table #inception_links
drop table #tmp_hedge_term
--*/
--===============END of Test ==========================================
-- SELECT use_eff_Test_profile_id, link_effective_date, link_id, link_type, * from #BasicInfo 
--SELECT * from #temp_fas_link_header
--uncomment this to keep the processing tables
-- IF @dedesignation_calc = 'd'
-- 	SET @print_diagnostic = 1
--print 'Entering...1'

SET STATISTICS IO OFF
SET NOCOUNT OFF
SET ROWCOUNT 0

DECLARE @sqlSelect1 VARCHAR(8000)
DECLARE @sqlSelect2 VARCHAR(8000)
DECLARE @sqlSelect3 VARCHAR(8000)
DECLARE @sqlFrom VARCHAR(8000)
DECLARE @sqlFrom1 VARCHAR(8000)
DECLARE @sqlFrom2 VARCHAR(8000)
DECLARE @sqlWhere1 VARCHAR(8000)
DECLARE @sqlWhere2 VARCHAR(8000)
DECLARE @sqlSelect10 VARCHAR(8000)
DECLARE @sqlSelect20 VARCHAR(8000)
DECLARE @sqlFrom10 VARCHAR(8000)
DECLARE @sqlFrom20 VARCHAR(8000)
DECLARE @sqlWhere10 VARCHAR(8000)
DECLARE @sqlWhere20 VARCHAR(8000)
DECLARE @continue_disc_factor INT
DECLARE @continue_pnl INT
DECLARE @continue_eff_pnl INT
DECLARE @continue_assmt_value_quarter INT
DECLARE @continue_conv_factor INT
DECLARE @log_increment INT
DECLARE @proc_begin_time DATETIME

DECLARE @MTableName VARCHAR(200)
DECLARE @DiscountTableName VARCHAR(200)
DECLARE @process_books VARCHAR(200)
DECLARE @DealProcessTableName VARCHAR(200)
DECLARE @DollarOffsetTableName VARCHAR(200)
DECLARE @DollarOffsetConMonthTableName VARCHAR(200)
DECLARE @DollarOffsetLinkTableName VARCHAR(200)
DECLARE @DollarOffsetBookTableName VARCHAR(200)
DECLARE @DollarOffsetStrategyTableName VARCHAR(200)
DECLARE @tempPreviousAoci VARCHAR(200)
DECLARE	@tempPreviousItemMTM VARCHAR(200)
DECLARE @AOCIReleaseSchedule VARCHAR(200)
DECLARE @UnlinkedLockedValuesTableName VARCHAR(200)
DECLARE @dealPNL VARCHAR(200)
DECLARE @tempLinksTableName VARCHAR(200)
DECLARE @tempCurrConvName VARCHAR(200)
DECLARE @tempSpotMTM VARCHAR(200)
DECLARE @link_id_filter VARCHAR (MAX)
--DECLARE @tempSourceDealPNLTableName VARCHAR(200)
DECLARE @deal VARCHAR(200)
DECLARE @std_as_of_date VARCHAR(20)
DECLARE @std_contract_month VARCHAR(20)
DECLARE @std_prior_as_of_date VARCHAR(20)
DECLARE @link_deal_term_used_per VARCHAR(200)

SET @proc_begin_time = GETDATE()

--print 'Entering...2'
SET @std_as_of_date = dbo.FNAGetSQLStandardDate(@as_of_date)
SET @std_contract_month = dbo.FNAGetContractMonth(@as_of_date) 
--SELECT @std_prior_as_of_date =  dbo.FNAGetContractMonth(MAX(as_of_date)) from measurement_run_dates WHERE as_of_date < @as_of_date
--SELECT @std_prior_as_of_date =  dbo.FNAGetSQLStandardDate(MAX(as_of_date)) from measurement_run_dates WHERE as_of_date < @as_of_date
SELECT @std_prior_as_of_date = dbo.FNAGetSQLStandardDate(MAX(as_of_date)) FROM measurement_run_dates 
WHERE as_of_date < CONVERT(DATETIME, @std_contract_month, 102)

DECLARE @pr_name VARCHAR(100)
DECLARE @log_time DATETIME

IF @print_diagnostic = 1
BEGIN
	SET @log_increment = 1
	PRINT '******************************************************************************************'
	PRINT '********************START &&&&&&&&&[spa_Collect_Link_Deals_PNL_OffSetting_Links]**********'
END

IF @what_if IS NULL
	SET @what_if = 'n'

--creating process tables
--SET @tempSourceDealPNLTableName = dbo.FNAProcessTableName('calcprocess_source_deal_pnl', @user_login_id, @process_id)
SET @DiscountTableName = dbo.FNAProcessTableName('calcprocess_discount_factor', @user_login_id, @process_id)
SET @DealProcessTableName = dbo.FNAProcessTableName('calcprocess_deals', @user_login_id, @process_id)
SET @DollarOffsetTableName = dbo.FNAProcessTableName('calcprocess_dollar_offset', @user_login_id, @process_id)
SET @DollarOffsetConMonthTableName = dbo.FNAProcessTableName('calcprocess_dollar_offset_conmonth_', @user_login_id, @process_id)
SET @DollarOffsetLinkTableName = dbo.FNAProcessTableName('calcprocess_dollar_offset_link_', @user_login_id, @process_id)
SET @DollarOffsetBookTableName = dbo.FNAProcessTableName('calcprocess_dollar_offset_book_', @user_login_id, @process_id)
SET @DollarOffsetStrategyTableName = dbo.FNAProcessTableName('calcprocess_dollar_offset_strategy_', @user_login_id, @process_id)
SET @tempPreviousAoci = dbo.FNAProcessTableName('calcprocess_previous_aoci', @user_login_id, @process_id)
SET @tempPreviousItemMTM = dbo.FNAProcessTableName('calcprocess_previous_item_mtm', @user_login_id, @process_id)
SET @UnlinkedLockedValuesTableName = dbo.FNAProcessTableName('calcprocess_unlinked_locked_values', @user_login_id, @process_id)
SET @tempLinksTableName = dbo.FNAProcessTableName('calcprocess_mismatch_links', @user_login_id, @process_id)
SET @tempSpotMTM = dbo.FNAProcessTableName('temp_spot_mtm', @user_login_id, @process_id)
SET @dealPNL = dbo.FNAProcessTableName('calcprocess_deal_pnl', @user_login_id, @process_id)
SET @deal = dbo.FNAProcessTableName('selected_deals', @user_login_id, @process_id)
SET @AOCIReleaseSchedule = dbo.FNAProcessTableName('aocirelease_schedule', @user_login_id, @process_id)
SET @process_books = dbo.FNAProcessTableName('process_books', @user_login_id, @process_id)
SET @MTableName = dbo.FNAProcessTableName('max_term', @user_login_id, @process_id)
SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)

IF @what_if = 'a'
BEGIN
	--If dollar offset logic invoked from front END
	--print @DiscountTableName
	EXEC spa_Calc_Discount_Factor @as_of_date, @sub_entity_id, @strategy_entity_id, @book_entity_id, @DiscountTableName
END
 
DECLARE @Sql_SelectB VARCHAR(MAX)        
DECLARE @Sql_WhereB VARCHAR(MAX)        
DECLARE @assignment_type INT        
        
SET @Sql_WhereB = ''        

EXEC('CREATE TABLE ' + @process_books + ' (fas_book_id INT) ')

SET @Sql_SelectB =  'INSERT INTO  ' + @process_books + '       
					SELECT DISTINCT book.entity_id fas_book_id FROM portfolio_hierarchy book (nolock) INNER JOIN
							Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
							source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
					WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 
'   
              
IF @sub_entity_id IS NOT NULL        
	SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN ( ' + @sub_entity_id + ') '         
IF @strategy_entity_id IS NOT NULL        
	SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN (' + @strategy_entity_id + ' ))'        
IF @book_entity_id IS NOT NULL        
	SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN (' + @book_entity_id + ')) '        
        
SET @Sql_SelectB =@Sql_SelectB+@Sql_WhereB        
     
EXEC spa_print @Sql_SelectB
EXEC(@Sql_SelectB)

--Collect all DISTINCT books to be used for joins
------------------------------END of SELECT portfolio hierarchy ---------------
--------------------Collect deals that should be used in joins
EXEC(
	'CREATE TABLE ' + @deal + ' 
	(
	source_deal_header_id INT,
	source_system_id INT,
	ext_deal_id VARCHAR(5000),
	header_buy_sell_flag CHAR(1),
	deal_date DATETIME,
	fas_deal_type_value_id INT,
	fas_deal_sub_type_value_id INT, 
	source_deal_type_id INT,
	deal_sub_type_type_id INT,
	counterparty_id INT,
	physical_financial_flag VARCHAR(1),
	deal_id VARCHAR(5000),
	option_flag VARCHAR(1),	
	source_system_book_id1 INT,
	source_system_book_id2 INT,
	source_system_book_id3 INT,
	source_system_book_id4 INT,
	use_source_deal_header_id INT,
	use_header_buy_sell_flag CHAR(1),
	use_deal_date DATETIME,
	default_book_id INT,
	internal_deal_type_value_id INT)' )

CREATE TABLE #tmp_deal (
	source_deal_header_id INT,
	source_system_id INT,
	ext_deal_id VARCHAR(5000) COLLATE DATABASE_DEFAULT,
	header_buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT,
	deal_date DATETIME,
	fas_deal_type_value_id INT,
	fas_deal_sub_type_value_id INT, 
	source_deal_type_id INT,
	deal_sub_type_type_id INT,
	counterparty_id INT,
	physical_financial_flag CHAR(1) COLLATE DATABASE_DEFAULT,
	deal_id VARCHAR(5000) COLLATE DATABASE_DEFAULT,
	option_flag VARCHAR(1) COLLATE DATABASE_DEFAULT,	
	source_system_book_id1 INT,
	source_system_book_id2 INT,
	source_system_book_id3 INT,
	source_system_book_id4 INT,
	default_book_id INT,
	internal_deal_type_value_id INT
)

SET @Sql_SelectB = 'INSERT INTO #tmp_deal
					SELECT	sdh.source_deal_header_id, sdh.source_system_id, sdh.ext_deal_id, sdh.header_buy_sell_flag, sdh.deal_date, 
							MAX(ISNULL(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)) fas_deal_type_value_id, MAX(ssbm.fas_deal_sub_type_value_id) fas_deal_sub_type_value_id,
							MAX(sdh.source_deal_type_id) source_deal_type_id, MAX(sdh.deal_sub_type_type_id) deal_sub_type_type_id, 
							MAX(sdh.counterparty_id) counterparty_id, MAX(sdh.physical_financial_flag) physical_financial_flag,
							MAX(sdh.deal_id) deal_id, MAX(sdh.option_flag) option_flag, MAX(sdh.source_system_book_id1) source_system_book_id1,
							MAX(sdh.source_system_book_id2) source_system_book_id2, MAX(sdh.source_system_book_id3) source_system_book_id3,
							MAX(sdh.source_system_book_id4) source_system_book_id4,
							MAX(ssbm.fas_book_id) default_book_id,
							ISNULL(MAX(sdh.internal_deal_type_value_id), -1) internal_deal_type_value_id  
					FROM source_deal_header sdh INNER JOIN 
					source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 AND 
													ssbm.source_system_book_id2 = sdh.source_system_book_id2 AND 
													ssbm.source_system_book_id3 = sdh.source_system_book_id3 AND 
													ssbm.source_system_book_id4 = sdh.source_system_book_id4 
					AND (ISNULL(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) =400 or ISNULL(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) =401)
					INNER JOIN  -- ?? this join is not required.
					' + @process_books + ' pb ON pb.fas_book_id = ssbm.fas_book_id 
					GROUP BY sdh.source_deal_header_id,sdh.source_system_id,sdh.ext_deal_id,sdh.header_buy_sell_flag, sdh.deal_date
' 
EXEC spa_print  @Sql_SelectB
EXEC(@Sql_SelectB)

CREATE INDEX INDX_TMP_DEAL99 ON #tmp_deal (ext_deal_id)

SET @Sql_SelectB = 'INSERT INTO ' + @deal + '
					SELECT	tmp.source_deal_header_id, tmp.source_system_id, tmp.ext_deal_id,
							tmp.header_buy_sell_flag, tmp.deal_date, 
							tmp.fas_deal_type_value_id, tmp.fas_deal_sub_type_value_id,
							tmp.source_deal_type_id, tmp.deal_sub_type_type_id, 
							tmp.counterparty_id, tmp.physical_financial_flag,
							tmp.deal_id, tmp.option_flag, tmp.source_system_book_id1,
							tmp.source_system_book_id2, tmp.source_system_book_id3,
							tmp.source_system_book_id4,
							sdhR.source_deal_header_id, 
							sdhR.header_buy_sell_flag, 
							sdhR.deal_date use_deal_date,
							tmp.default_book_id,
							tmp.internal_deal_type_value_id  
					FROM #tmp_deal tmp 
					LEFT OUTER JOIN source_deal_header sdhR ON sdhR.deal_id = tmp.ext_deal_id 
						AND tmp.source_system_id=sdhR.source_system_id
					'    
EXEC(@Sql_SelectB)

EXEC('CREATE INDEX [IX_DEAL_HEADER_ID] ON ' + @deal + ' (source_deal_header_id,source_system_id,ext_deal_id)')
--EXEC('create index [ix_deal_header_id] on '+@deal+' (source_deal_header_id,source_system_id,ext_deal_id,fas_stra_id)')

---END of collecting deals that should be used in joins

 -----------------------------  BEGIN  OF CREATING TEMP_FAS_LINK_HEADER ---------------------------------
IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name +' Running..............'
END

-- Bring all link headers for later use
CREATE TABLE [dbo].[#temp_fas_link_header](
	[link_id] [INT] NOT NULL,
	[original_link_id] [INT] NULL,
	[perfect_hedge] [CHAR](1)  COLLATE DATABASE_DEFAULT NOT NULL,
	[fully_dedesignated] [CHAR](1) COLLATE DATABASE_DEFAULT NOT NULL ,
	[eff_test_profile_id] [INT] NOT NULL,
	[link_effective_date] [DATETIME] NOT NULL,
	[dedesignation_date] [DATETIME] NULL,
	[link_type_value_id] [INT] NOT NULL,
	[link_active] [CHAR](1) COLLATE DATABASE_DEFAULT NOT NULL,
	[dedesignated_percentage] [FLOAT] NULL,
	[fas_book_id] [INT] NOT NULL
)

SET @Sql_SelectB = 'INSERT INTO #temp_fas_link_header
					SELECT  flh.link_id, flh.original_link_id, flh.perfect_hedge, flh.fully_dedesignated, 
							flh.eff_test_profile_id, flh.link_effective_date,
							flh.link_end_date dedesignation_date, flh.link_type_value_id,
							flh.link_active, flh.dedesignated_percentage, flh.fas_book_id
					FROM ' + @process_books + ' pb  INNER JOIN  
						fas_link_header flh ON pb.fas_book_id = flh.fas_book_id 
					WHERE flh.link_effective_date <= ''' + @as_of_date + ''''
EXEC(@Sql_SelectB)

CREATE INDEX [INDX_TEMP_FAS_LINK_HEADER] ON #temp_fas_link_header (link_id,fas_book_id)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) + '*************************************'
	PRINT '****************END of Collecting Links *****************************'	
END

-----------------------------  END OF CREATING TEMP_FAS_LINK_HEADER ---------------------------------
-----------------------------  BEGIN OF RETRIEVING DEFAULT VALUES FOR CALCULATION ---------------------------------
-- 0 means it is interest rate, 1 means the vale is already discount factor, 2 discount factor provided at deal level
DECLARE @is_discount_curve_a_factor INT
SELECT  @is_discount_curve_a_factor   = var_value 
FROM adiha_default_codes_values
WHERE (instance_no = '1') AND (default_code_id = 14) AND (seq_no = 1)

-- 0 means MTM table contains discounted values, 1 means dynamically calculated in measurement or other reporting logic
DECLARE @mtm_value_source INT
SELECT  @mtm_value_source   = var_value 
FROM adiha_default_codes_values
WHERE (instance_no = '1') AND (default_code_id = 27) AND (seq_no = 1)

IF @mtm_value_source IS NULL
	SET @mtm_value_source = 1

-- 0 Means use the undiscounted aoci and discount by current value.. 1 means use prior discounted values.
DECLARE @prior_aoci_disc_value INT
SELECT  @prior_aoci_disc_value = var_value 
FROM adiha_default_codes_values
WHERE (instance_no = '1') AND (default_code_id = 29) AND (seq_no = 1)

IF @prior_aoci_disc_value IS NULL
	SET @prior_aoci_disc_value = 0

-- For derivatives this does not apply. First day gain/loss is controlled based on threshold WHERE each derivative is saved
-- For item the following configuration applies. 0 means ignore first day gain/loss. If 5, it will strip out first day gain/loss
-- If 6, it will strip out first day gain/loss of item only if hedge eff date is less than effective date
DECLARE @first_day_pnl VARCHAR(2)
SELECT @first_day_pnl  = CAST(var_value AS VARCHAR) FROM adiha_default_codes_values
WHERE instance_no = 1 AND seq_no = 1
	AND default_code_id = 16

IF @first_day_pnl IS NULL
	SET @first_day_pnl = '1'

--Measurment calc default DISC Factor code: (0 meanhs halt/1 - continue with value of 1 with warnings/2 - continue with value of 1 with out warnings)
SELECT @continue_disc_factor = var_value FROM adiha_default_codes_values
WHERE instance_no = 1 and seq_no = 1
 AND default_code_id = 3

--Measurement calc default PNL code: (0 meanhs halt/1 - continue with value of 0 with warnings/2 - continue with value of 0 with out warnings)
SELECT @continue_pnl = var_value FROM adiha_default_codes_values
WHERE instance_no = 1 
	AND seq_no = 1
	AND default_code_id = 4

DECLARE @fv_level VARCHAR(50)
-- Later retrieve this from table for now go with NULL
SET @fv_level = NULL 

--(0 meanhs halt/1 - Use 0 with warnings/2 - Use 0 with out warnings/3 - Use MAX(as_of_date) or 0 prior to hedge effective date with warnings/4 - Use MAX(as_of_date) prior to hedge effective date with out warnings/5 - Use min(as_of_date) or 0after hedge effective date with warnings/6 - continue with min(as_of_date) after hedge effective date with out warnings)
IF @dedesignation_calc = 'd'
	SELECT @continue_eff_pnl = var_value from adiha_default_codes_values
	WHERE instance_no = 1 AND seq_no = 1
		AND default_code_id = 5
ELSE
	SELECT @continue_eff_pnl = var_value from adiha_default_codes_values
	WHERE instance_no = 2 AND seq_no = 1
		AND default_code_id = 5 

--print 'PNL default code is = ' + CAST(@continue_eff_pnl AS VARCHAR)
--(0 meanhs halt/1 - continue with prior value with warnings/2 - continue with prior value with out warnings)
SELECT @continue_assmt_value_quarter = var_value from adiha_default_codes_values
WHERE instance_no = 1 AND seq_no = 1
	AND default_code_id = 6

--(0 meanhs halt/1 - continue with value of 1 with warnings/2 - continue with value of 1 with out warnings)
SELECT @continue_conv_factor = var_value from adiha_default_codes_values
WHERE instance_no = 1 AND seq_no = 1
	AND default_code_id = 7

--print 'PRINT 2'
-----------------------------  END OF RETRIEVING DEFAULT VALUES FOR CALCULATION ---------------------------------
CREATE TABLE #inception_links (link_id INT, inception_flag INT)

IF @first_day_pnl = '6'
BEGIN
	INSERT INTO #inception_links
	SELECT	flh.link_id, 
			MAX(CASE WHEN(ISNULL(fld.effective_date, flh.link_effective_date) > sdh.deal_date) THEN 1 ELSE 0 END) inception_flag
	FROM #temp_fas_link_header flh 
	INNER JOIN fas_link_detail fld on fld.link_id = flh.link_id 
	INNER JOIN source_deal_header sdh on sdh.source_deal_header_id = fld.source_deal_header_id
	WHERE hedge_or_item = 'h'
	GROUP BY flh.link_id
	HAVING MAX(CASE WHEN (ISNULL(fld.effective_date, flh.link_effective_date) > sdh.deal_date) THEN 1 ELSE 0 END) = 1

	CREATE INDEX INCEPTION_LINKS1 ON #inception_links (link_id)
END

-----------------------------  BEGIN  OF CREATING BASIC INFO TABLE ------------------------------------
 CREATE TABLE #BasicInfo (
	[fas_subsidiary_id] [INT] NOT NULL ,
	[fas_strategy_id] [INT] NOT NULL ,
	[fas_book_id] [INT] NOT NULL ,
	[source_deal_header_id] [INT] NOT NULL ,
	[as_of_date] [DATETIME] NOT NULL ,
	[deal_date] [DATETIME] NOT NULL ,
	[deal_type] [INT] NOT NULL ,
	[deal_sub_type] [INT]  NULL ,
	[source_counterparty_id] [INT] NULL,
	[physical_financial_flag] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
	[term_start] [DATETIME] NOT NULL ,
	[term_end] [DATETIME] NOT NULL ,
	[Leg] [INT] NOT NULL ,
	[contract_expiration_date] [DATETIME] NOT NULL ,
	[fixed_float_leg] [CHAR](1) COLLATE DATABASE_DEFAULT NOT NULL ,
	[buy_sell_flag] [CHAR](1) COLLATE DATABASE_DEFAULT NOT NULL ,
	[curve_id] [INT] NULL ,
	[fixed_price] [FLOAT] NULL ,
	[fixed_price_currency_id] [INT] NULL ,
	[option_strike_price] [FLOAT] NULL ,
	[deal_volume] [FLOAT] NULL ,
	[deal_volume_frequency] [CHAR](1) COLLATE DATABASE_DEFAULT NOT NULL ,
	[deal_volume_uom_id] [INT] NOT NULL ,
	[block_description] [VARCHAR] (100) COLLATE DATABASE_DEFAULT NULL ,
	[deal_detail_description] [VARCHAR] (1000) COLLATE DATABASE_DEFAULT NULL ,
	[hedge_or_item] [CHAR](1) COLLATE DATABASE_DEFAULT NULL ,
	[link_id] [INT] NULL ,
	[percentage_included] [FLOAT] NULL ,
	[link_effective_date] [DATETIME] NULL ,
	[dedesignation_link_id] [INT] NULL ,
	[link_type] [VARCHAR] (5) COLLATE DATABASE_DEFAULT NOT NULL ,
	[percentage_dedesignated] [FLOAT] NULL ,
	[func_cur_value_id] [INT] NOT NULL ,
	[link_active] [CHAR](1) COLLATE DATABASE_DEFAULT NULL ,
	[fully_dedesignated] [CHAR](1) COLLATE DATABASE_DEFAULT NULL ,
	[perfect_hedge] [CHAR](1) COLLATE DATABASE_DEFAULT NULL ,
	[eff_test_profile_id] [INT] NULL,
	[link_type_value_id] [INT] NULL,
	[dedesignated_link_id] [INT] NULL ,
	[hedge_type_value_id] [INT] NOT NULL ,
	[fx_hedge_flag] [CHAR](1) COLLATE DATABASE_DEFAULT NOT NULL ,
	[no_links] [CHAR](1) COLLATE DATABASE_DEFAULT NOT NULL ,
	[mes_gran_value_id] [INT] NULL ,
	[mes_cfv_value_id] [INT]  NULL ,
	[mes_cfv_values_value_id] [INT]  NULL ,
	[gl_grouping_value_id] [INT] NULL ,
	[mismatch_tenor_value_id] [INT] NULL ,
	[strip_trans_value_id] [INT] NULL ,
	[asset_liab_calc_value_id] [INT] NOT NULL ,
	[test_range_from] [FLOAT] NULL ,
	[test_range_to] [FLOAT]  NULL ,
	[additional_test_range_from] [FLOAT] NULL ,
	[additional_test_range_to] [FLOAT] NULL ,
	[additional_test_range_from2] [FLOAT] NULL ,
	[additional_test_range_to2] [FLOAT] NULL ,
	[include_unlinked_hedges] [CHAR](1) COLLATE DATABASE_DEFAULT NOT NULL ,
	[include_unlinked_items] [CHAR](1) COLLATE DATABASE_DEFAULT NOT NULL ,
	[no_link] [CHAR](1) COLLATE DATABASE_DEFAULT NULL ,
	[use_eff_test_profile_id] [INT] NULL ,
	[no_links_fas_eff_test_profile_id] [INT] NULL ,
	[source_system_id] [INT] NULL ,
	[dedesignation_pnl_currency_id] [INT] NULL ,
	[pnl_ineffectiveness_value] [FLOAT] NULL ,
	[pnl_dedesignation_value] [FLOAT] NULL ,
	[locked_aoci_value] [FLOAT] NULL ,
	[dedesignated_cum_pnl] [FLOAT] NULL,
	[dedesignation_date] [DATETIME] NULL ,
	[dedesignated_by_link_id] [INT] NULL, 
	[of_link_dedesignated_percentage] [FLOAT] NULL,
	[long_term_months] [INT],
	[deal_id] [VARCHAR] (5000) COLLATE DATABASE_DEFAULT NULL,
	[option_flag] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
	[options_premium_approach] [INT] NULL,
	[options_amortization_factor] [FLOAT] NULL,
	[ext_deal_id] [VARCHAR] (5000) COLLATE DATABASE_DEFAULT NULL,
	[fas_deal_type_value_id] INT NULL,
	[fas_deal_sub_type_value_id] INT NULL,
	[book_map_end_date] [DATETIME] NULL,
	[rollout_per_type] [INT] NULL,
	[tax_perc] [FLOAT] NULL,
	[oci_rollout_approach_value_id] [INT] NULL,
	[link_end_date] [DATETIME] NULL,
	[use_source_deal_header_id] [INT] NULL,
	[use_header_buy_sell_flag] [VARCHAR] (1) COLLATE DATABASE_DEFAULT NULL,
	[use_deal_date] [DATETIME] NULL,
	[prior_value_link_id] INT,
	[hedge_item_same_sign] CHAR(1) COLLATE DATABASE_DEFAULT NULL,
	[inception_flag] INT NULL
) ON [PRIMARY]
	
-----------------------------  COLLECT DEALS (HEDGES/ITEMS) FOR PROCESSING  ------------------------------------
CREATE TABLE #deal_leg_1 
(
	source_deal_header_id INT,
	term_start DATETIME,
	buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT,
	curve_id INT, 
	fixed_price FLOAT,
	fixed_price_currency_id INT, 
	option_strike_price [FLOAT], 
	deal_volume_frequency CHAR(1) COLLATE DATABASE_DEFAULT, 
	deal_volume_uom_id INT,
	min_leg INT
)

EXEC(' INSERT INTO #deal_leg_1
		SELECT	sdd.source_deal_header_id, sdd.term_start, MAX(buy_sell_flag) buy_sell_flag, MAX(curve_id) curve_id, 
				MAX(fixed_price) fixed_price, MAX(fixed_price_currency_id) fixed_price_currency_id, 
				MAX(option_strike_price) option_strike_price, MAX(deal_volume_frequency) deal_volume_frequency, 
				MAX(deal_volume_uom_id) deal_volume_uom_id, min(sdd.leg) min_leg
		FROM ' + @deal + ' sd INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sd.source_deal_header_id
		WHERE --sdd.leg = 1 and 
				sd.fas_deal_type_value_id = 401
		GROUP BY sdd.source_deal_header_id, sdd.term_start
		')

CREATE INDEX [INDX_DEAL_LEG_1] ON #deal_leg_1 (source_deal_header_id)

CREATE TABLE #source_deal_detail (
	source_deal_header_id INT, 
	term_start DATETIME, 
	term_end DATETIME,
	Leg INT, 
	contract_expiration_date DATETIME,
	fixed_float_leg CHAR(1) COLLATE DATABASE_DEFAULT, 
	buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT,
	curve_id INT, 
	fixed_price FLOAT,
	fixed_price_currency_id INT, 
	option_strike_price FLOAT, 
	deal_volume FLOAT, 
	deal_volume_frequency VARCHAR(2) COLLATE DATABASE_DEFAULT, 
	deal_volume_uom_id INT,
	deal_fas_deal_sub_type_value_id INT
)

DECLARE @source_deal_detail VARCHAR(4000)
SET @source_deal_detail = '
INSERT INTO  #source_deal_detail
SELECT	sdd.source_deal_header_id, 
		CASE WHEN (sd.internal_deal_type_value_id IN (6,7)) THEN sdd.term_end ELSE sdd.term_start END term_start, 
		term_end, 1 Leg, 
		MAX(contract_expiration_date) contract_expiration_date, ''t'' fixed_float_leg, 
		MAX(buy_sell_flag) buy_sell_flag, MAX(curve_id) curve_id, 
		MAX(fixed_price) fixed_price, MAX(fixed_price_currency_id) fixed_price_currency_id, 
		MAX(option_strike_price) option_strike_price, 
		MAX(deal_volume) deal_volume, 
		MAX(deal_volume_frequency) deal_volume_frequency, 
		MAX(deal_volume_uom_id) deal_volume_uom_id,
		1225 deal_fas_deal_sub_type_value_id
FROM ' + @deal + ' sd INNER JOIN
source_deal_detail sdd ON sdd.source_deal_header_id = sd.source_deal_header_id
WHERE sd.fas_deal_type_value_id = 400
GROUP BY sdd.source_deal_header_id, --internal_deal_type_value_id,
		--term_start, 
		CASE WHEN (sd.internal_deal_type_value_id IN (6,7)) THEN sdd.term_end ELSE sdd.term_start END,
		term_end --, contract_expiration_date
UNION ALL
SELECT	sdd.source_deal_header_id, 
		CASE WHEN (sd.internal_deal_type_value_id IN (6,7)) THEN sdd.term_end ELSE sdd.term_start END term_start, 
		term_end, 1 Leg, 
		MAX(contract_expiration_date) contract_expiration_date, ''t'' fixed_float_leg, 
		MAX(CASE WHEN (1 = sdd.leg) THEN sdd.buy_sell_flag ELSE ''b'' END) buy_sell_flag,
--		MAX(l1.buy_sell_flag) buy_sell_flag, 
		MAX(l1.curve_id) curve_id, 
		MAX(l1.fixed_price) fixed_price, MAX(l1.fixed_price_currency_id) fixed_price_currency_id, 
		MAX(l1.option_strike_price) option_strike_price, 
		MAX(CASE WHEN (1 = sdd.leg) THEN deal_volume ELSE 0 END) deal_volume,
--		MAX(CASE WHEN (sdd.leg = l1.min_leg) THEN deal_volume ELSE 0 END) deal_volume, 
		MAX(l1.deal_volume_frequency) deal_volume_frequency, 
		MAX(l1.deal_volume_uom_id) deal_volume_uom_id,
		min(CASE WHEN (sdd.leg = 1) THEN 1225 ELSE 1226 END) deal_fas_deal_sub_type_value_id
FROM ' + @deal + ' sd INNER JOIN
source_deal_detail sdd ON sdd.source_deal_header_id = sd.source_deal_header_id INNER JOIN 
#deal_leg_1 l1 on l1.source_deal_header_id = sd.source_deal_header_id and l1.term_start = sdd.term_start
WHERE sd.fas_deal_type_value_id = 401 --and sdd.leg = 1 -- get all contract months as leg 1 but volume for other legs should be 0
GROUP BY sdd.source_deal_header_id, --internal_deal_type_value_id,
		--term_start, 
		CASE WHEN (sd.internal_deal_type_value_id IN (6,7)) THEN sdd.term_end ELSE sdd.term_start END,
		term_end --, contract_expiration_date 
'

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END
EXEC(@source_deal_detail)


create index [indx_source_deal_detail_tmp] on #source_deal_detail (source_deal_header_id)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************inserting into #source_deal_detail *****************************'
END

--print @source_deal_detail
--return

EXEC dbo.spa_get_link_deal_term_used_per @as_of_date = NULL,@link_ids = @link_filter_id, @header_deal_id = NULL,@term_start= NULL,@no_include_link_id = NULL,@output_type =1
	,@include_gen_tranactions  = 'n',@process_table = @link_deal_term_used_per,@call_from = 1
 
SET @sqlSelect1 =
 '
INSERT INTO #BasicInfo
SELECT  COALESCE(fas_link_header.link_sub_id, fas_subsidiaries.fas_subsidiary_id) fas_subsidiary_id, 
		COALESCE(fas_link_header.link_strategy_id, fas_strategy.fas_strategy_id) fas_strategy_id, 
		COALESCE(fas_link_header.link_book_id, fas_books.fas_book_id) fas_book_id, 
		source_deal_header.source_deal_header_id,
		''' + @std_as_of_date + ''' AS as_of_date,
		source_deal_header.deal_date,
		source_deal_header.source_deal_type_id,
		source_deal_header.deal_sub_type_type_id, 
		source_deal_header.counterparty_id,
		source_deal_header.physical_financial_flag,
		source_deal_detail.term_start, 
		source_deal_detail.term_end, 
		source_deal_detail.Leg, 
		source_deal_detail.contract_expiration_date, 
        source_deal_detail.fixed_float_leg, 
		source_deal_detail.buy_sell_flag, 
		source_deal_detail.curve_id, 
		source_deal_detail.fixed_price, 
        source_deal_detail.fixed_price_currency_id, 
		source_deal_detail.option_strike_price, 
		source_deal_detail.deal_volume, 
        source_deal_detail.deal_volume_frequency, 
		source_deal_detail.deal_volume_uom_id, 
		'''' block_description, 
        '''' deal_detail_description, 
		CASE WHEN (source_deal_header.fas_deal_type_value_id = 400) THEN ''h''
			WHEN (source_deal_header.fas_deal_type_value_id = 401) THEN ''i''
			END AS hedge_or_item, 
		CASE WHEN(fas_link_detail_dedesignation.dedesignated_link_id IS NOT NULL) THEN fas_link_detail_dedesignation.dedesignated_link_id
			ELSE (CASE 
				WHEN(ISNULL(fas_books.hedge_type_value_id, fas_strategy.hedge_type_value_id) BETWEEN 150 AND 151 AND (fas_strategy.mes_gran_value_id BETWEEN 177 AND 178)) THEN -1*fas_books.fas_book_id
				WHEN(fas_link_detail.link_id IS NOT NULL) THEN fas_link_detail.link_id
				ELSE source_deal_header.source_deal_header_id 
			      END)
			END
		AS link_id, 
		COALESCE(lp.percentage_used, fas_link_detail.percentage_included, source_system_book_map.percentage_included, 1) percentage_included, 
		CASE WHEN(fas_link_detail_dedesignation.dedesignated_link_id IS NOT NULL) THEN fas_link_detail_dedesignation.effective_date 
			 WHEN(ISNULL(fas_books.hedge_type_value_id, fas_strategy.hedge_type_value_id) = 152 AND fas_link_header.link_effective_date IS NULL) THEN COALESCE(source_system_book_map.effective_start_date, source_deal_header.deal_date) ELSE
			dbo.FNAMaxDate(COALESCE(lp.effective_date,fas_link_detail.link_detail_effective_date, fas_link_header.link_effective_date, 
					source_system_book_map.effective_start_date, str_no_link.effective_start_date, book_no_link.effective_start_date,
				source_deal_header.deal_date), source_deal_header.deal_date) 
		END As link_effective_date,
		COALESCE(fas_link_detail_dedesignation.link_id, fas_link_header.original_link_id, NULL) AS dedesignation_link_id, 
		CASE 	
			WHEN(ISNULL(fas_books.hedge_type_value_id, fas_strategy.hedge_type_value_id) BETWEEN 150 AND 151 AND (fas_strategy.mes_gran_value_id BETWEEN 177 AND 178)) THEN ''link''
			WHEN(fas_link_detail.link_id IS NOT NULL ) THEN ''link''
			ELSE ''deal'' 
			END
			AS link_type, 
		COALESCE(fas_link_detail_dedesignation.percentage_dedesignated, fas_link_header.dedesignated_percentage) AS percentage_dedesignated,
        fas_subsidiaries.func_cur_value_id, 
        fas_link_header.link_active, 
		ISNULL(fas_link_header.fully_dedesignated, ''n'') fully_dedesignated, 
		ISNULL(fas_link_header.perfect_hedge, ''n'') perfect_hedge,
		CASE	WHEN (ISNULL(fas_books.hedge_type_value_id, fas_strategy.hedge_type_value_id) = 152) THEN NULL
				WHEN (fas_strategy.mes_gran_value_id = 177) THEN  fas_books.no_links_fas_eff_test_profile_id
				WHEN (fas_strategy.mes_gran_value_id = 178) THEN  fas_strategy.no_links_fas_eff_test_profile_id
				ELSE fas_link_header.eff_test_profile_id 
		END AS eff_test_profile_id, 
		CASE WHEN (ISNULL(fas_books.hedge_type_value_id, fas_strategy.hedge_type_value_id) BETWEEN 150 AND 151 AND fas_strategy.mes_gran_value_id BETWEEN 177 AND 178) THEN 450 ELSE fas_link_header.link_type_value_id END link_type_value_id, 
		fas_link_detail_dedesignation.dedesignated_link_id, 
		ISNULL(fas_books.hedge_type_value_id, fas_strategy.hedge_type_value_id), 
        ISNULL(fas_strategy.fx_hedge_flag,''n''),
		ISNULL(fas_strategy.no_links, ''n'') no_links,  --This is used as Short Term only transactions for strategy 
		CASE WHEN (fas_strategy.mes_gran_value_id BETWEEN 176 AND 177) THEN 176 ELSE fas_strategy.mes_gran_value_id END mes_gran_value_id,
		fas_strategy.mes_cfv_value_id,
		CASE WHEN (ISNULL(fas_books.hedge_type_value_id, fas_strategy.hedge_type_value_id) = 152) THEN 227 ELSE fas_strategy.mes_cfv_values_value_id END mes_cfv_values_value_id,		
		fas_strategy.gl_grouping_value_id,
		fas_strategy.mismatch_tenor_value_id mismatch_tenor_value_id,
		CASE WHEN (fas_strategy.mismatch_tenor_value_id = 252 OR fas_strategy.oci_rollout_approach_value_id <> 500) THEN 626 ELSE fas_strategy.strip_trans_value_id END strip_trans_value_id,
		ISNULL(fas_strategy.asset_liab_calc_value_id, 277) asset_liab_calc_value_id,
		fas_strategy.test_range_from,
		fas_strategy.test_range_to,
		fas_strategy.additional_test_range_from,
		fas_strategy.additional_test_range_to,
		fas_strategy.additional_test_range_from2,
		fas_strategy.additional_test_range_to2,
		ISNULL(fas_strategy.include_unlinked_hedges,''n''),
		ISNULL(fas_strategy.include_unlinked_items, ''n''),
		ISNULL(fas_books.no_link, ''n'') no_link, -- Use this for Hypothetial Book for What If Analysis only y means it is hypothetical
		CASE	WHEN (fas_strategy.mes_gran_value_id BETWEEN 177 AND 178) THEN  
					COALESCE(str_no_link.inherit_assmt_eff_test_profile_id, fas_strategy.no_links_fas_eff_test_profile_id, 
						book_no_link.inherit_assmt_eff_test_profile_id, fas_books.no_links_fas_eff_test_profile_id)								
				ELSE ISNULL(fas_eff_hedge_rel_type.inherit_assmt_eff_test_profile_id, fas_link_header.eff_test_profile_id)
		END AS use_eff_test_profile_id, 
		fas_strategy.no_links_fas_eff_test_profile_id,
		fas_strategy.source_system_id,  
		NULL dedesignation_pnl_currency_id , 
		0 pnl_ineffectiveness_value, 
		0 pnl_dedesignation_value, 
		0 locked_aoci_value,
		0 dedesignated_cum_pnl,
		fas_link_header.dedesignation_date,
		NULL dedesignated_by_link_id,
		NULL of_link_dedesignated_percentage,
		fas_subsidiaries.long_term_months,
		source_deal_header.deal_id,
		source_deal_header.option_flag,
	 	fas_strategy.options_premium_approach,
		0 as options_amortization_factor,
		source_deal_header.ext_deal_id,
		source_deal_header.fas_deal_type_value_id,
		CASE WHEN (ISNULL(source_system_book_map.fas_deal_sub_type_value_id, 1225) = 1225 AND source_deal_detail.deal_fas_deal_sub_type_value_id = 1226) THEN
					source_deal_detail.deal_fas_deal_sub_type_value_id ELSE ISNULL(source_system_book_map.fas_deal_sub_type_value_id, 1225) END
		fas_deal_sub_type_value_id,
		CASE WHEN (COALESCE(fas_link_header.dedesignation_date, source_system_book_map.end_date) <= ''' + @std_as_of_date + ''') 
			THEN COALESCE(fas_link_header.dedesignation_date, source_system_book_map.end_date) ELSE NULL END book_map_end_date,
		ISNULL(fas_strategy.rollout_per_type, 520) rollout_per_type,
		COALESCE(fas_books.tax_perc, fas_subsidiaries.tax_perc, 0) tax_perc,
		fas_strategy.oci_rollout_approach_value_id,	
'

SET @sqlSelect2 = '
		fas_link_header.dedesignation_date link_end_date, 
		ISNULL(source_deal_header.use_source_deal_header_id, source_deal_header.source_deal_header_id) use_source_deal_header_id, 
		source_deal_header.use_header_buy_sell_flag use_header_buy_sell_flag, 
		ISNULL(source_deal_header.use_deal_date, source_deal_header.deal_date) use_deal_date,
	    CASE WHEN (fas_link_header.link_type_value_id <> 450 AND MONTH(fas_link_header.dedesignation_date) = MONTH(''' + @std_as_of_date + ''') AND  
				YEAR(fas_link_header.dedesignation_date) = YEAR(''' + @std_as_of_date + ''')) THEN fas_link_header.original_link_id 
	    ELSE CASE WHEN(fas_link_detail_dedesignation.dedesignated_link_id IS NOT NULL) THEN fas_link_detail_dedesignation.dedesignated_link_id
			 ELSE (CASE 
				WHEN(ISNULL(fas_books.hedge_type_value_id, fas_strategy.hedge_type_value_id) BETWEEN 150 AND 151 AND (fas_strategy.mes_gran_value_id BETWEEN 177 AND 178)) THEN -1*fas_books.fas_book_id
				WHEN(fas_link_detail.link_id IS NOT NULL) THEN fas_link_detail.link_id
				ELSE source_deal_header.source_deal_header_id 
			    END)
		END END prior_value_link_id,
		CASE WHEN (source_deal_header.fas_deal_type_value_id = 401 AND ISNULL(fb_hi_sign.hedge_item_same_sign, ''n'') = ''y'') THEN ''y'' ELSE ''n'' END hedge_item_same_sign,
		ISNULL(il.inception_flag, 0) inception_flag
'

SET @sqlFrom1 = '
FROM ' + @deal + ' source_deal_header INNER JOIN
source_system_book_map ON source_system_book_map.source_system_book_id1 = source_deal_header.source_system_book_id1 AND 
						  source_system_book_map.source_system_book_id2 = source_deal_header.source_system_book_id2 AND 
                          source_system_book_map.source_system_book_id3 = source_deal_header.source_system_book_id3 AND 
                          source_system_book_map.source_system_book_id4 = source_deal_header.source_system_book_id4 INNER JOIN
#source_deal_detail source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id
LEFT JOIN ' + @link_deal_term_used_per + ' lp on lp.source_deal_header_id = source_deal_detail.source_deal_header_id AND lp.term_start = source_deal_detail.term_start
LEFT JOIN (SELECT fld.link_id, fld.source_deal_header_id, 
		fld.percentage_included as percentage_included,
		fld.hedge_or_item, ''l'' AS d_link_type, fld.effective_date as link_detail_effective_date
	 FROM fas_link_detail fld INNER JOIN #temp_fas_link_header flh ON fld.link_id = flh.link_id
) AS fas_link_detail ON fas_link_detail.source_deal_header_id = source_deal_header.source_deal_header_id 
	and lp.link_id=fas_link_detail.link_id LEFT OUTER JOIN 	
(SELECT flh.link_id, original_link_id, flh.perfect_hedge, 
		flh.fully_dedesignated, flh.eff_test_profile_id, flh.link_effective_date,	
		flh.dedesignation_date, flh.link_type_value_id, flh.link_active, 
		flh.dedesignated_percentage, ''l'' AS d_link_type,
		pstr.parent_entity_id link_sub_id, pstr.entity_id link_strategy_id,  
		pb.entity_id link_book_id
FROM    #temp_fas_link_header flh INNER JOIN 
portfolio_hierarchy pb on pb.entity_id = flh.fas_book_id INNER JOIN
portfolio_hierarchy pstr on pstr.entity_id = pb.parent_entity_id
) AS fas_link_header ON fas_link_detail.link_id = fas_link_header.link_id AND fas_link_detail.d_link_type = fas_link_header.d_link_type LEFT OUTER JOIN

fas_books ON fas_books.fas_book_id = ISNULL(fas_link_header.link_book_id, source_system_book_map.fas_book_id) LEFT OUTER JOIN 
fas_books fb_hi_sign ON fb_hi_sign.fas_book_id = source_system_book_map.fas_book_id LEFT OUTER JOIN 
portfolio_hierarchy book ON book.entity_id = fas_books.fas_book_id LEFT OUTER JOIN
portfolio_hierarchy str ON str.entity_id = book.parent_entity_id LEFT OUTER JOIN
fas_strategy ON str.entity_id = fas_strategy.fas_strategy_id LEFT OUTER JOIN
fas_subsidiaries ON str.parent_entity_id = fas_subsidiaries.fas_subsidiary_id LEFT OUTER JOIN
fas_link_detail_dedesignation ON fas_link_header.link_id = fas_link_detail_dedesignation.link_id LEFT OUTER JOIN
fas_eff_hedge_rel_type ON fas_eff_hedge_rel_type.eff_test_profile_id = fas_link_header.eff_test_profile_id LEFT OUTER JOIN
fas_eff_hedge_rel_type book_no_link ON book_no_link.eff_test_profile_id = fas_books.no_links_fas_eff_test_profile_id LEFT OUTER JOIN
fas_eff_hedge_rel_type str_no_link ON str_no_link.eff_test_profile_id = fas_strategy.no_links_fas_eff_test_profile_id LEFT OUTER JOIN
#inception_links il ON il.link_id = fas_link_header.link_id
'

--print @sqlFrom1 
--For measurement logic
SET @sqlWhere1 = 
'
 WHERE ((ISNULL(fas_books.hedge_type_value_id, fas_strategy.hedge_type_value_id) = 152 AND source_deal_header.fas_deal_type_value_id = 400) OR
		(ISNULL(fas_books.hedge_type_value_id, fas_strategy.hedge_type_value_id) <> 152 AND source_deal_header.fas_deal_type_value_id BETWEEN 400 AND 401))  
	AND (link_active IS NULL OR link_active <> ''n'' )
	AND (fas_link_header.d_link_type IS NULL OR fas_link_header.d_link_type = ''l'' )
	AND (ISNULL(fas_books.hedge_type_value_id, fas_strategy.hedge_type_value_id) BETWEEN 150 AND 152)
	AND (source_deal_header.deal_date <=  ''' + @std_as_of_date + ''')
	AND (lp.link_id IS NULL or (lp.link_id IS NOT NULL AND lp.source_deal_header_id IS NOT NULL))
'
--	AND (source_deal_detail.source_deal_header_id IS NOT NULL)
 
-- getting link_id should be consistent with link_id in SELECT condition
IF @link_filter_id IS NOT NULL 
	SET @link_id_filter = ' AND (fas_link_detail.link_id IN (' + @link_filter_id  + ') OR 
			fas_link_detail_dedesignation.dedesignated_link_id IN (' + @link_filter_id  + ')' +
			CASE WHEN (@dedesignation_calc = 'd') THEN
				' OR (fas_link_header.original_link_id IS NOT NULL AND fas_link_header.original_link_id IN (' + @link_filter_id + ')'
			ELSE '' END +
			')'
		
IF @link_filter_id IS NOT NULL 
	SET @sqlWhere1 = @sqlWhere1 + @link_id_filter

--print @sqlSelect1
--print @sqlSelect2
--print @sqlFrom1
--print @sqlWhere1
--return

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

EXEC spa_print @sqlSelect1
EXEC spa_print @sqlSelect2
EXEC spa_print @sqlFrom1
EXEC spa_print @sqlWhere1

EXEC(@sqlSelect1 + @sqlSelect2 + @sqlFrom1 + @sqlWhere1)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Collecting Deals in BasicInfo *****************************'
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

CREATE  INDEX [IX_b_info1] ON [#BasicInfo](source_deal_header_id,term_start,term_end,as_of_date, link_effective_date, book_map_end_date)
CREATE  INDEX [IX_b_info_sub1] ON [#BasicInfo](fas_subsidiary_id)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Creating Index in BasicInfo *****************************'	
END

IF ((SELECT COUNT(1) FROM #BasicInfo) = 0)
BEGIN
	IF @print_diagnostic = 1
		PRINT 'No data to process in BasicInfo...'

	INSERT INTO MEASUREMENT_PROCESS_STATUS
	SELECT 'Error' as status_code, 
		'There is no data found to process as of ' + dbo.FNADateFormat(@as_of_date) status_description, @as_of_date  run_as_of_date,
		''  assessment_values, @assessment_date, @sub_entity_id, @strategy_entity_id, @book_entity_id,
		'n' can_proceed, 
		@process_id, @dedesignation_calc as calc_type, NULL as create_user, NULL as create_ts

	DECLARE @deleteStmtB VARCHAR(5000)
	SET @deleteStmtB = dbo.FNAProcessDeleteTableSql(@deal)
	EXEC(@deleteStmtB)

	SET @deleteStmtB = dbo.FNAProcessDeleteTableSql(@DiscountTableName)
	EXEC(@deleteStmtB)

	RETURN
END

-----------------------------  END OF CREATING BASIC INFO TABLE ------------------------------------
-----------------------------  BEGIN OF SAVING EFFECTIVE PNL ------------------------------------

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

CREATE TABLE #effpnldate (use_source_deal_header_id INT, pnl_as_of_date DATETIME)

SET @sqlSelect1 = 
'
INSERT INTO #effpnldate
SELECT	use_source_deal_header_id, pnl_as_of_date
FROM 
	(		
	SELECT	bi.use_source_deal_header_id, 
			bi.link_effective_date pnl_as_of_date
	FROM	#BasicInfo bi 
	WHERE   bi.leg = 1 AND ((bi.ext_deal_id IS NOT NULL AND bi.use_source_deal_header_id IS NOT NULL) OR bi.ext_deal_id IS NULL)
			AND bi.link_effective_date <= ''' + @std_as_of_date + '''' +
	CASE WHEN (@eff_pnl_all = 'n') THEN ' AND MONTH(bi.link_effective_date) = MONTH(''' + @std_as_of_date + ''') AND YEAR(bi.link_effective_date) = YEAR(''' + @std_as_of_date + ''') ' 
	ELSE CASE WHEN (@eff_month_from IS NOT NULL and @eff_month_to IS NOT NULL) THEN 
			' AND bi.link_effective_date BETWEEN ''' + @eff_month_from + ''' AND ''' + @eff_month_to + '''' ELSE '' END END +
	'
	UNION ALL 
	SELECT	bi.use_source_deal_header_id, 
					bi.book_map_end_date pnl_as_of_date				
	FROM	#BasicInfo bi 
	WHERE   bi.leg = 1 AND bi.book_map_end_date IS NOT NULL  AND
			((bi.ext_deal_id IS NOT NULL AND bi.use_source_deal_header_id IS NOT NULL) OR bi.ext_deal_id IS NULL) AND
			bi.book_map_end_date <= ''' + @std_as_of_date + '''' +
	CASE WHEN (@eff_pnl_all = 'n') THEN ' AND MONTH(bi.book_map_end_date) = MONTH(''' + @std_as_of_date + ''') AND YEAR(bi.book_map_end_date) = YEAR(''' + @std_as_of_date + ''') ' 
	ELSE CASE WHEN (@eff_month_from IS NOT NULL and @eff_month_to IS NOT NULL) THEN 
			' AND bi.book_map_end_date BETWEEN ''' + @eff_month_from + ''' AND ''' + @eff_month_to + '''' ELSE '' END END +

/*
//first day gain/loss value is known now and dont need to be provided
'
UNION ALL 
SELECT	source_deal_header_id use_source_deal_header_id, 
		deal_date pnl_as_of_date 
from first_day_gain_loss_decision
WHERE   deal_date <= ''' + @std_as_of_date + '''' +
CASE WHEN (@eff_pnl_all = 'n') THEN ' AND MONTH(deal_date) = MONTH(''' + @std_as_of_date + ''') AND YEAR(deal_date) = YEAR(''' + @std_as_of_date + ''') ' 
ELSE CASE WHEN (@eff_month_from IS NOT NULL and @eff_month_to IS NOT NULL) THEN 
		' AND deal_date BETWEEN ''' + @eff_month_from + ''' AND ''' + @eff_month_to + '''' ELSE '' END END 
*/

+
') all_dates
GROUP BY use_source_deal_header_id, pnl_as_of_date '

EXEC(@sqlSelect1)

CREATE INDEX IX_EFFPNLDATE ON #effpnldate (use_source_deal_header_id, pnl_as_of_date)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Collecting Dates for Effective PNL in temp table *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

DECLARE @pnl_table_name VARCHAR(8000)

IF @eff_pnl_all = 'n'
	SET @pnl_table_name = dbo.FNAGetProcessTableName(@std_contract_month, 'source_deal_pnl')
ELSE
--	SET @pnl_table_name = ' (SELECT * from source_deal_pnl union SELECT * from source_deal_pnl_arch1) '
	SELECT  @pnl_table_name= '(' + dbo.FNASelectProcessTableSql('source_deal_pnl_id,source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date,und_pnl,und_intrinsic_pnl,und_extrinsic_pnl,dis_pnl,dis_intrinsic_pnl,dis_extrinisic_pnl,pnl_source_value_id,pnl_currency_id,pnl_conversion_factor,pnl_adjustment_value,deal_volume,create_user,create_ts,update_user,update_ts,und_pnl_set','source_deal_pnl','') +')'

CREATE TABLE #eff_pnl_dates(use_source_deal_header_id INT, pnl_as_of_date DATETIME, max_as_of_date DATETIME)

----(' + @sqlSelect1 + ') sdd INNER JOIN
SET @sqlSelect1 = 
'
INSERT INTO #eff_pnl_dates
SELECT	sdd.use_source_deal_header_id use_source_deal_header_id,
		sdd.pnl_as_of_date, MAX(fd.pnl_as_of_date) max_as_of_date 
FROM	#effpnldate sdd INNER JOIN
' + @pnl_table_name + ' fd ON 	fd.source_deal_header_id = sdd.use_source_deal_header_id AND
								fd.pnl_as_of_date <= sdd.pnl_as_of_date
WHERE (fd.pnl_source_value_id = 775 OR fd.pnl_source_value_id = 4500)
GROUP BY sdd.use_source_deal_header_id, sdd.pnl_as_of_date
'

EXEC(@sqlSelect1)
--SELECT * from #mod1
--SELECT * from #eff_pnl_dates
--SELECT * from source_deal_pnl_eff WHERE source_deal_header_id = 130014

CREATE INDEX IX_EFF_PNL_DATES ON #eff_pnl_dates (use_source_deal_header_id, pnl_as_of_date)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Collecting Effective Dates for PNL (Closest Value) *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

SET @sqlSelect1 = 'DELETE source_deal_pnl_eff
					FROM source_deal_pnl_eff sdpe
					INNER JOIN #eff_pnl_dates e ON	sdpe.source_deal_header_id = e.use_source_deal_header_id 
						AND sdpe.pnl_as_of_date = e.pnl_as_of_date --e.max_as_of_date '
EXEC(@sqlSelect1)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Deleting PNL for Effective Dates *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

SET @sqlSelect1 =
'INSERT INTO source_deal_pnl_eff (source_deal_header_id, term_start, term_end, Leg, pnl_as_of_date, und_pnl, und_intrinsic_pnl, 
			und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl, dis_extrinisic_pnl, pnl_source_value_id, pnl_currency_id, 
			pnl_conversion_factor, pnl_adjustment_value, deal_volume, create_user, create_ts, update_user, update_ts, pnl_used_as_of_date) 
SELECT sdp.source_deal_header_id, sdp.term_start, sdp.term_end, sdp.Leg, e.pnl_as_of_date, sdp.und_pnl, sdp.und_intrinsic_pnl, 
			sdp.und_extrinsic_pnl, sdp.dis_pnl, sdp.dis_intrinsic_pnl, sdp.dis_extrinisic_pnl, sdp.pnl_source_value_id, sdp.pnl_currency_id, 
			sdp.pnl_conversion_factor, sdp.pnl_adjustment_value, sdp.deal_volume, ''' + @user_login_id + ''' create_user, getdate() create_ts,
			''' + @user_login_id + ''' update_user, getdate() update_ts, sdp.pnl_as_of_date
FROM ' + @pnl_table_name + ' sdp INNER JOIN #eff_pnl_dates e on sdp.source_deal_header_id = e.use_source_deal_header_id 
	AND sdp.pnl_as_of_date = e.max_as_of_date
WHERE (sdp.pnl_source_value_id = 775 OR sdp.pnl_source_value_id = 4500)
'
EXEC spa_print @sqlSelect1

EXEC(@sqlSelect1)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) + '*************************************'
	PRINT '****************END of Inserting PNL for Effective Dates *****************************'	
END


--This needs to come from correct pnl table and inserted into Eff table (Delete first)
-- For all do we do union????
--SELECT * from source_deal_pnl sdp INNER JOIN #mod1 md on sdp.source_deal_header_id = md.use_source_deal_header_id and

-----------------------------  END OF SAVING EFFECTIVE PNL ------------------------------------
-----------------------------  COLLECT PNLS FOR DEALS ABOVE FOR AS_OF_DATE AND OTHER EFFECTIVE AND END DATES ------

DECLARE @pnl_sql1 VARCHAR(8000)
DECLARE @pnl_sql1_b VARCHAR(8000)
DECLARE @pnl_sql2 VARCHAR(8000)
DECLARE @e_pnl_sql2 VARCHAR(8000)
DECLARE @pnl_sql3 VARCHAR(8000)
--by gyan

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

CREATE TABLE #sdd1(
	[deal_volume] [FLOAT] NULL,
	[source_deal_header_id] [INT] NOT NULL,
	[use_source_deal_header_id] [INT] NULL,
	[use_header_buy_sell_flag] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
	[curve_id] [INT] NULL,
	[term_start] [DATETIME] NOT NULL,
	[term_end] [DATETIME] NOT NULL,
	[leg] [INT] NULL,
	[pnl_as_of_date] [DATETIME] NULL,
	[dedesignation_date] [INT] NULL,
	[link_effective_date] [INT] NULL,
	[use_deal_date] [DATETIME] NULL,
	hedge_item_same_sign VARCHAR(1) COLLATE DATABASE_DEFAULT
) 

CREATE TABLE #sdd2(
	[deal_volume] [FLOAT] NULL,
	[source_deal_header_id] [INT] NOT NULL,
	[use_source_deal_header_id] [INT] NULL,
	[use_header_buy_sell_flag] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
	[curve_id] [INT] NULL,
	[term_start] [DATETIME] NOT NULL,
	[term_end] [DATETIME] NOT NULL,
	[leg] [INT] NULL,
	[pnl_as_of_date] [DATETIME] NULL,
	[dedesignation_date] [INT] NULL,
	[link_effective_date] [INT] NULL,
	[use_deal_date] [DATETIME] NULL,
	hedge_item_same_sign CHAR(1) COLLATE DATABASE_DEFAULT
) 

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END


SET @pnl_sql1 =
'
INSERT INTO #sdd1
SELECT	MAX(deal_volume) deal_volume, source_deal_header_id, MAX(use_source_deal_header_id) use_source_deal_header_id,
		MAX(use_header_buy_sell_flag) use_header_buy_sell_flag, MAX(curve_id) curve_id, term_start, term_end, 
		MAX(leg) leg, ''' + @std_as_of_date + ''' pnl_as_of_date, 
		NULL dedesignation_date, NULL link_effective_date, MAX(use_deal_date) use_deal_date, 
		MAX(hedge_item_same_sign) hedge_item_same_sign
FROM #BasicInfo bi 
WHERE bi.leg = 1  AND ((bi.ext_deal_id IS NOT NULL AND bi.use_source_deal_header_id IS NOT NULL) OR bi.ext_deal_id IS NULL)
GROUP BY source_deal_header_id, term_start, term_end

'
EXEC(@pnl_sql1)

CREATE INDEX IX_SDD1 ON #sdd1 (source_deal_header_id,  term_start, term_end, pnl_as_of_date)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Collecting deals and PNL Date *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

SET @pnl_sql1 = ' INSERT INTO #sdd2 
SELECT	MAX(all_dates.deal_volume) deal_volume, all_dates.source_deal_header_id, 
		MAX(all_dates.use_source_deal_header_id) use_source_deal_header_id,
		MAX(all_dates.use_header_buy_sell_flag) use_header_buy_sell_flag, MAX(all_dates.curve_id) curve_id, 
		all_dates.term_start, all_dates.term_end, MAX(all_dates.leg) leg,
		all_dates.pnl_as_of_date, NULL dedesignation_date, NULL link_effective_date, MAX(all_dates.use_deal_date) use_deal_date,
		MAX(all_dates.hedge_item_same_sign) hedge_item_same_sign
FROM (
	SELECT	bi.deal_volume, bi.source_deal_header_id, bi.use_source_deal_header_id, bi.use_header_buy_sell_flag, 
			bi.curve_id curve_id, bi.term_start, bi.term_end, bi.leg leg, 
			bi.link_effective_date pnl_as_of_date,
			NULL dedesignation_date, NULL link_effective_date, bi.use_deal_date, bi.hedge_item_same_sign  
	FROM	#BasicInfo bi 
	WHERE   bi.leg = 1 AND ((bi.ext_deal_id IS NOT NULL AND bi.use_source_deal_header_id IS NOT NULL) OR bi.ext_deal_id IS NULL)
			AND bi.link_effective_date <= ''' + @std_as_of_date + '''
UNION ALL 
	SELECT	bi.deal_volume, bi.source_deal_header_id, bi.use_source_deal_header_id, bi.use_header_buy_sell_flag, 
			bi.curve_id curve_id, bi.term_start, bi.term_end, bi.leg leg, 
			bi.book_map_end_date pnl_as_of_date,
			NULL dedesignation_date, NULL link_effective_date, bi.use_deal_date, bi.hedge_item_same_sign  
	FROM	#BasicInfo bi 
	WHERE   bi.leg = 1 AND bi.book_map_end_date IS NOT NULL  AND
			((bi.ext_deal_id IS NOT NULL AND bi.use_source_deal_header_id IS NOT NULL) OR bi.ext_deal_id IS NULL) AND
			bi.book_map_end_date <= ''' + @std_as_of_date + '''
) all_dates LEFT OUTER JOIN #sdd1 on #sdd1.source_deal_header_id = all_dates.source_deal_header_id AND
	#sdd1.term_start = all_dates.term_start AND #sdd1.term_end = all_dates.term_end AND
	#sdd1.pnl_as_of_date = all_dates.pnl_as_of_date
WHERE #sdd1.source_deal_header_id IS NULL
GROUP BY all_dates.source_deal_header_id, all_dates.term_start, all_dates.term_end, all_dates.pnl_as_of_date
'

EXEC(@pnl_sql1)

CREATE INDEX IX_SDD2 ON #sdd2 (source_deal_header_id,  term_start, term_end, pnl_as_of_date)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Collecting deals and PNL Date *****************************'	
END

/*
IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	EXEC spa_print @pr_name + ' Running..............'
END

CREATE TABLE #max_aod (use_source_deal_header_id INT, pnl_as_of_date DATETIME,
	term_start DATETIME, term_end DATETIME, leg TINYINT, max_as_of_date DATETIME)

EXEC('
INSERT INTO #max_aod (use_source_deal_header_id, pnl_as_of_date, term_start,term_end, leg, max_as_of_date)
SELECT	bi.use_source_deal_header_id,
		req_pnl.pnl_as_of_date, bi.term_start, bi.term_end, bi.leg, MAX(fd.pnl_as_of_date) max_as_of_date 
FROM	#BasicInfo bi LEFT OUTER JOIN
		(SELECT source_deal_header_id, pnl_as_of_date from #sdd1 GROUP BY source_deal_header_id, pnl_as_of_date) req_pnl on
			bi.source_deal_header_id = req_pnl.source_deal_header_id LEFT OUTER JOIN
		' + @pnl_table_name + ' fd ON 	fd.source_deal_header_id = bi.use_source_deal_header_id AND
						fd.term_start = bi.term_start AND
						fd.term_end  = bi.term_end AND
						fd.leg = bi.leg AND
						fd.pnl_as_of_date <= req_pnl.pnl_as_of_date
GROUP BY bi.use_source_deal_header_id, bi.term_start, bi.term_end, bi.leg, req_pnl.pnl_as_of_date
')

delete #max_aod WHERE max_as_of_date IS NULL


IF @print_diagnostic = 1
BEGIN
	EXEC spa_print @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	EXEC spa_print '****************END of #max_aod *****************************'	
END
*/

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END
CREATE TABLE #t_fdgl (source_deal_header_id INT, term_start DATETIME,  treatment_value_id INT, first_day_pnl FLOAT)

INSERT INTO #t_fdgl
SELECT sdh.source_deal_header_id, sdd.term_start, sdh.treatment_value_id , sdh.first_day_pnl/sdh.total_months first_day_pnl
FROM
	(SELECT sdd.source_deal_header_id, MAX(treatment_value_id) treatment_value_id,  MAX(first_day_pnl) first_day_pnl, COUNT(sdd.term_start) total_months  
	from first_day_gain_loss_decision fdgld INNER JOIN
	source_deal_detail sdd ON sdd.source_deal_header_id = fdgld.source_deal_header_id
	WHERE fdgld.treatment_value_id <> 4085 and fdgld.deal_date <= @as_of_date
	GROUP BY sdd.source_deal_header_id) sdh INNER JOIN
	(SELECT fdgld.source_deal_header_id, sdd.term_start FROM first_day_gain_loss_decision fdgld INNER JOIN
	source_deal_detail sdd ON sdd.source_deal_header_id = fdgld.source_deal_header_id
	WHERE treatment_value_id <> 4085 and fdgld.deal_date <= @as_of_date
) sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id

CREATE INDEX [INDX_T_FDGL] ON #t_fdgl (source_deal_header_id, term_start)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************inserting into #t_fdgl *****************************'	
END

EXEC('
CREATE TABLE ' + @dealPNL + ' (
	[source_deal_header_id] [INT] NOT NULL,
	[term_start] [DATETIME] NOT NULL,
	[term_end] [DATETIME] NOT NULL,
	[leg] [INT] NULL,
	[pnl_as_of_date] [DATETIME] NULL,
	[main_deal_volume] [FLOAT] NULL,
	[ref_source_deal_header_id] [INT] NULL,
	[ref_deal_volume] [FLOAT] NULL,
	[pnl_used] [FLOAT] NULL,
	[pnl_as_of_date_used] [DATETIME] NULL,
	[buy_sell_flag] [VARCHAR](1)   NULL,
	[und_pnl] [FLOAT] NULL,
	[und_intrinsic_pnl] [FLOAT] NULL,
	[und_extrinsic_pnl] [FLOAT] NULL,
	[pnl_source_value_id] [INT] NULL,
	[pnl_currency_id] [INT] NULL,
	[pnl_conversion_factor] [FLOAT] NULL,
	[pnl_adjustment_value] [FLOAT] NULL,
	[fd_und_pnl] [FLOAT] NULL,
	[fd_und_intrinsic_pnl] [FLOAT] NULL,
	[fd_und_extrinsic_pnl] [FLOAT] NULL,
	[fd_und_ignored_pnl] [FLOAT] NULL,
	[hedge_effective_date] [INT] NULL,
	[dedesignation_date] [INT] NULL,
	[use_deal_date] [DATETIME] NULL,
	[accrued_interest] FLOAT NULL,
	[dis_pnl_used] [FLOAT] NULL,
	[dis_pnl] [FLOAT] NULL,
	[dis_intrinsic_pnl] [FLOAT] NULL,
	[dis_extrinsic_pnl] [FLOAT] NULL

) ON [PRIMARY]
')

--CASE WHEN (sdd.term_start <= sdd.pnl_as_of_date) THEN ISNULL(cpm.und_pnl, 0) ELSE COALESCE(cpp.und_pnl, cpm.und_pnl, 0) END
SET @pnl_sql1 = 'INSERT INTO ' + @dealPNL + ' 
SELECT	sdd.source_deal_header_id, sdd.term_start, sdd.term_end, sdd.leg, 
	sdd.pnl_as_of_date pnl_as_of_date, 
	sdd.deal_volume main_deal_volume,
	sdd.use_source_deal_header_id ref_source_deal_header_id,
	NULLIF(rdeal.deal_volume, 0) ref_deal_volume,
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *	
	COALESCE(cpp.und_pnl, CASE WHEN (cpm.pnl_as_of_date <= ISNULL(cpp.pnl_as_of_date, sdd.pnl_as_of_date) AND sdd.term_start <= sdd.pnl_as_of_date) THEN cpm.und_pnl ELSE 0 END, 0) pnl_used,
	COALESCE(cpp.pnl_as_of_date, CASE WHEN (cpm.pnl_as_of_date <= ISNULL(cpp.pnl_as_of_date, sdd.pnl_as_of_date) AND sdd.term_start <= sdd.pnl_as_of_date) THEN cpm.pnl_as_of_date ELSE NULL END, NULL) pnl_as_of_date_used,
	sdh.header_buy_sell_flag buy_sell_flag,
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *
	CASE WHEN (sdd.use_header_buy_sell_flag IS NOT NULL AND sdd.use_header_buy_sell_flag <> sdh.header_buy_sell_flag) THEN -1 ELSE 1 END *
	CASE WHEN (sdd.source_deal_header_id = sdd.use_source_deal_header_id) THEN 1 ELSE ISNULL(sdd.deal_volume/NULLIF(rdeal.deal_volume, 0), 1) END *
	( (COALESCE(cpp.und_pnl, CASE WHEN (cpm.pnl_as_of_date <= ISNULL(cpp.pnl_as_of_date, sdd.pnl_as_of_date) AND sdd.term_start <= sdd.pnl_as_of_date) THEN cpm.und_pnl ELSE 0 END, 0) +
		COALESCE(cpp.pnl_adjustment_value, cpm.pnl_adjustment_value, 0)) *
		COALESCE(cpp.pnl_conversion_factor, cpm.pnl_conversion_factor, 1)) 
	- CASE 	WHEN (ISNULL(fdgl.treatment_value_id, -1) = 4087) THEN ISNULL(fdgl.first_day_pnl, 0) ELSE 0 END und_pnl, 
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *
	CASE WHEN (sdd.use_header_buy_sell_flag IS NOT NULL AND sdd.use_header_buy_sell_flag <> sdh.header_buy_sell_flag) THEN -1 ELSE 1 END *
	CASE WHEN (sdd.source_deal_header_id = sdd.use_source_deal_header_id) THEN 1 ELSE ISNULL(sdd.deal_volume/NULLIF(rdeal.deal_volume, 0), 1) END *
	((COALESCE(cpp.und_intrinsic_pnl, CASE WHEN (cpm.pnl_as_of_date <= ISNULL(cpp.pnl_as_of_date, sdd.pnl_as_of_date)  AND sdd.term_start <= sdd.pnl_as_of_date) THEN cpm.und_intrinsic_pnl ELSE 0 END, 0) +
		COALESCE(cpp.pnl_adjustment_value, cpm.pnl_adjustment_value, 0)) *
		COALESCE(cpp.pnl_conversion_factor, cpm.pnl_conversion_factor, 1))
	- CASE 	WHEN (ISNULL(fdgl.treatment_value_id, -1) = 4087) THEN ISNULL(fdgl.first_day_pnl, 0) ELSE 0 END und_intrinsic_pnl, 
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *
	CASE WHEN (sdd.use_header_buy_sell_flag IS NOT NULL AND sdd.use_header_buy_sell_flag <> sdh.header_buy_sell_flag) THEN -1 ELSE 1 END *
	CASE WHEN (sdd.source_deal_header_id = sdd.use_source_deal_header_id) THEN 1 ELSE ISNULL(sdd.deal_volume/NULLIF(rdeal.deal_volume, 0), 1) END *
	COALESCE(cpp.und_extrinsic_pnl, CASE WHEN (cpm.pnl_as_of_date <= ISNULL(cpp.pnl_as_of_date, sdd.pnl_as_of_date) AND sdd.term_start <= sdd.pnl_as_of_date) THEN cpm.und_extrinsic_pnl ELSE 0 END, 0) und_extrinsic_pnl, 
	COALESCE(cpp.pnl_source_value_id, cpm.pnl_source_value_id, 0) pnl_source_value_id, 
	COALESCE(cpp.pnl_currency_id, cpm.pnl_currency_id, 0) pnl_currency_id,  
	COALESCE(cpp.pnl_conversion_factor, cpm.pnl_conversion_factor, 1) pnl_conversion_factor,  
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *
	COALESCE(cpp.pnl_adjustment_value, cpm.pnl_adjustment_value, 0) pnl_adjustment_value,
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *
	CASE WHEN (ISNULL(fdgl.treatment_value_id, -1) = 4086) THEN  ISNULL(fdgl.first_day_pnl, 0) ELSE 0 END fd_und_pnl, 
'

SET @pnl_sql1_b = '
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *
	CASE WHEN (ISNULL(fdgl.treatment_value_id, -1) = 4086) THEN  ISNULL(fdgl.first_day_pnl, 0) ELSE 0 END fd_und_intrinsic_pnl,
	0 fd_und_extrinsic_pnl,
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *
	CASE WHEN (ISNULL(fdgl.treatment_value_id, -1) = 4087) THEN ISNULL(fdgl.first_day_pnl, 0) ELSE 0 END fd_und_ignored_pnl,	
	sdd.link_effective_date hedge_effective_date,
	sdd.dedesignation_date,
	sdd.use_deal_date, 
	CASE WHEN (sdh.internal_deal_type_value_id = 6 OR sdh.internal_deal_type_value_id = 7) THEN
		COALESCE(cpp.dis_extrinisic_pnl, CASE WHEN (cpm.pnl_as_of_date <= ISNULL(cpp.pnl_as_of_date, sdd.pnl_as_of_date) AND sdd.term_start <= sdd.pnl_as_of_date) THEN cpm.dis_extrinisic_pnl ELSE 0 END, 0) 
	ELSE 0 END accrued_interest,
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *
	COALESCE(cpp.dis_pnl, CASE WHEN (cpm.pnl_as_of_date <= ISNULL(cpp.pnl_as_of_date, sdd.pnl_as_of_date) AND sdd.term_start <= sdd.pnl_as_of_date) THEN cpm.dis_pnl ELSE 0 END, 0) dis_pnl_used,
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *
	CASE WHEN (sdd.use_header_buy_sell_flag IS NOT NULL AND sdd.use_header_buy_sell_flag <> sdh.header_buy_sell_flag) THEN -1 ELSE 1 END *
	CASE WHEN (sdd.source_deal_header_id = sdd.use_source_deal_header_id) THEN 1 ELSE ISNULL(sdd.deal_volume/NULLIF(rdeal.deal_volume, 0), 1) END *
	( (COALESCE(cpp.dis_pnl, CASE WHEN (cpm.pnl_as_of_date <= ISNULL(cpp.pnl_as_of_date, sdd.pnl_as_of_date) AND sdd.term_start <= sdd.pnl_as_of_date) THEN cpm.dis_pnl ELSE 0 END, 0) +
		COALESCE(cpp.pnl_adjustment_value, cpm.pnl_adjustment_value, 0)) *
		COALESCE(cpp.pnl_conversion_factor, cpm.pnl_conversion_factor, 1)) 
	- CASE 	WHEN (ISNULL(fdgl.treatment_value_id, -1) = 4087) THEN ISNULL(fdgl.first_day_pnl, 0) ELSE 0 END dis_pnl, 
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *
	CASE WHEN (sdd.use_header_buy_sell_flag IS NOT NULL AND sdd.use_header_buy_sell_flag <> sdh.header_buy_sell_flag) THEN -1 ELSE 1 END *
	CASE WHEN (sdd.source_deal_header_id = sdd.use_source_deal_header_id) THEN 1 ELSE ISNULL(sdd.deal_volume/NULLIF(rdeal.deal_volume, 0), 1) END *
	((COALESCE(cpp.dis_intrinsic_pnl, CASE WHEN (cpm.pnl_as_of_date <= ISNULL(cpp.pnl_as_of_date, sdd.pnl_as_of_date)  AND sdd.term_start <= sdd.pnl_as_of_date) THEN cpm.dis_intrinsic_pnl ELSE 0 END, 0) +
		COALESCE(cpp.pnl_adjustment_value, cpm.pnl_adjustment_value, 0)) *
		COALESCE(cpp.pnl_conversion_factor, cpm.pnl_conversion_factor, 1))
	- CASE 	WHEN (ISNULL(fdgl.treatment_value_id, -1) = 4087) THEN ISNULL(fdgl.first_day_pnl, 0) ELSE 0 END dis_intrinsic_pnl, 
	CASE WHEN (sdd.hedge_item_same_sign = ''y'') THEN -1 ELSE 1 END *
 	CASE WHEN (sdd.use_header_buy_sell_flag IS NOT NULL AND sdd.use_header_buy_sell_flag <> sdh.header_buy_sell_flag) THEN -1 ELSE 1 END *
	CASE WHEN (sdd.source_deal_header_id = sdd.use_source_deal_header_id) THEN 1 ELSE ISNULL(sdd.deal_volume/NULLIF(rdeal.deal_volume, 0), 1) END *
	COALESCE(cpp.dis_extrinisic_pnl, CASE WHEN (cpm.pnl_as_of_date <= ISNULL(cpp.pnl_as_of_date, sdd.pnl_as_of_date) AND sdd.term_start <= sdd.pnl_as_of_date) THEN cpm.dis_extrinisic_pnl ELSE 0 END, 0) dis_extrinsic_pnl 
FROM   ' + @deal + ' sdh INNER JOIN '

SET @pnl_sql2 = '
	#sdd2 sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id  
'

SET @pnl_sql3 = '
	LEFT OUTER JOIN	
		source_deal_pnl_eff cpp ON cpp.pnl_as_of_date = sdd.pnl_as_of_date AND
				cpp.source_deal_header_id = sdd.use_source_deal_header_id AND
				cpp.term_start = sdd.term_start AND
				cpp.term_end  = sdd.term_end 
		LEFT OUTER JOIN	
		source_deal_pnl_settlement cpm ON 	
				cpm.source_deal_header_id = sdd.use_source_deal_header_id AND
				cpm.term_start = sdd.term_start AND
				cpm.term_end  = sdd.term_end 
		LEFT OUTER JOIN
		#t_fdgl fdgl ON fdgl.source_deal_header_id = sdd.source_deal_header_id and
					fdgl.term_start = sdd.term_start 
		LEFT OUTER JOIN
		#sdd1 rdeal ON  rdeal.source_deal_header_id = sdd.use_source_deal_header_id AND
						rdeal.term_start = sdd.term_start AND
						rdeal.term_end  = sdd.term_end 
	
'	

EXEC spa_print @pnl_sql1
EXEC spa_print @pnl_sql1_b
EXEC spa_print @pnl_sql2 
EXEC spa_print @pnl_sql3
--return

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END
--EXEC(@pnl_sql1 + @pnl_sql1_b + @dealPNL  + @pnl_sql2 + @pnl_sql3)

EXEC(@pnl_sql1 + @pnl_sql1_b + @pnl_sql2 + @pnl_sql3)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Collecting PNL *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

SET @pnl_sql2 = '
	#sdd1 sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id  
'

SET @pnl_sql3 = '
	LEFT OUTER JOIN
		' + @pnl_table_name + ' cpp ON cpp.pnl_as_of_date = sdd.pnl_as_of_date AND
				cpp.source_deal_header_id = sdd.use_source_deal_header_id AND
				cpp.term_start = sdd.term_start AND
				cpp.term_end  = sdd.term_end AND
				(cpp.pnl_source_value_id = 775 OR cpp.pnl_source_value_id = 4500)
		LEFT OUTER JOIN
		source_deal_pnl_settlement cpm ON 	
				cpm.source_deal_header_id = sdd.use_source_deal_header_id AND
				cpm.term_start = sdd.term_start AND
				cpm.term_end  = sdd.term_end 
		LEFT OUTER JOIN	
		#t_fdgl fdgl ON fdgl.source_deal_header_id = sdd.source_deal_header_id and
					fdgl.term_start = sdd.term_start 
		LEFT OUTER JOIN
		#sdd1 rdeal ON  rdeal.source_deal_header_id = sdd.use_source_deal_header_id AND
						rdeal.term_start = sdd.term_start AND
						rdeal.term_end  = sdd.term_end 
'	

EXEC spa_print @pnl_sql1
EXEC spa_print @pnl_sql1_b
EXEC spa_print @pnl_sql2
EXEC spa_print @pnl_sql3

EXEC(@pnl_sql1 + @pnl_sql1_b + @pnl_sql2 + @pnl_sql3)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Collecting PNL FOR as of date*****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

EXEC('CREATE INDEX [INDX_CALCPROCESS_DEAL_PNL_11] ON ' + @dealPNL + ' (source_deal_header_id,term_start,term_end,pnl_as_of_date)')

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Creating Index in PNL Table *****************************'	
END
-----------------------------  BEGIN OF SELECT COMMON TO MEASUREMENT AND DEDESIGNATION ----------------
-----------------------------  BEGIN OF RETRIEVING ASSESSMENT VALUES ----------------------------------
IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

SELECT 	MAX(C.eff_test_profile_id) eff_test_profile_id, 
	MAX(B.result_value) as assessment_values,
	MAX(B.additional_result_value) as additional_assessment_values,
	MAX(B.additional_result_value2) as additional_assessment_values2,
	MAX(CASE WHEN (C.on_eff_test_approach_value_id IN (305, 307, 309, 311, 313)) THEN td.t_value
		WHEN (C.on_eff_test_approach_value_id IN (306, 308, 310, 312, 314)) THEN fd.f_value
		ELSE NULL
	END) AS t_f_value,
	MAX(B.as_of_date) AS assessment_date, 
	MAX(C.on_eff_test_approach_value_id) on_eff_test_approach_value_id,
	MAX(D.regression_df) ddf,
	MAX(CAST(CASE WHEN (C.on_eff_test_approach_value_id = 305) THEN fs.test_range_from/2
			WHEN (C.on_eff_test_approach_value_id IN (307, 309, 311, 313)) THEN fs.additional_test_range_from/2
			WHEN (C.on_eff_test_approach_value_id = 306) THEN fs.test_range_from
			WHEN (C.on_eff_test_approach_value_id IN (308, 310, 312, 314)) THEN fs.additional_test_range_from
	END AS VARCHAR)) alpha,
	--CASE WHEN(B.link_id IS NULL) THEN -1 ELSE B.link_id END as link_id, 
	A.link_id ass_link_id,
	A.real_link_id link_id,
	MAX(CASE WHEN(B.calc_level IS NULL) THEN -1 ELSE B.calc_level END) as calc_level, 
	MAX(B.eff_test_result_id) eff_test_result_id,
	MAX(ISNULL(C.force_intercept_zero, 'n')) as short_cut_method,
	MAX(ISNULL(C.ineffectiveness_in_hedge, 'n')) as exclude_spot_forward_diff
INTO #ass_info
FROM
(SELECT  md.eff_test_profile_id eff_test_profile_id, 
			md.real_link_id real_link_id, md.link_id, md.calc_level, md.as_of_date,
			md.res_as_of_date, MAX(fr.eff_test_result_id) eff_test_result_id
	FROM 
	(
	SELECT	rel.use_eff_test_profile_id eff_test_profile_id, 
			rel.link_id real_link_id, rel.ass_rel_id link_id, rel.calc_level, rel.as_of_date,
			MAX(featr.as_of_date) res_as_of_date
	FROM
	(SELECT	bi.link_id, MAX(use_eff_test_profile_id) use_eff_test_profile_id, 
			MAX(CASE WHEN(rel_type.on_eff_test_approach_value_id IN (302, 304, 320)) THEN  -1 
				 WHEN (rel_type.individual_link_calc = 'y') THEN 
						CASE WHEN (bi.link_type_value_id <> 450) THEN bi.dedesignation_link_id 
							 WHEN (bi.mes_gran_value_id = 178) THEN -1*bi.fas_strategy_id 
						ELSE bi.link_id END
			ELSE -1 END) ass_rel_id,
			MAX(CASE WHEN(rel_type.on_eff_test_approach_value_id IN (302, 304, 320)) THEN  -1 
				 WHEN (rel_type.individual_link_calc = 'y') THEN 2 ELSE 1 
			END) calc_level,
			MAX(CASE WHEN (bi.link_type_value_id <> 450) THEN bi.dedesignation_date ELSE @as_of_date END) as_of_date
	FROM #BasicInfo bi INNER JOIN
	fas_eff_hedge_rel_type rel_type ON rel_type.eff_test_profile_id = bi.use_eff_test_profile_id 
	WHERE bi.link_type = 'link'
	GROUP BY link_id) rel INNER JOIN
	fas_eff_ass_test_results featr ON featr.eff_test_profile_id = rel.use_eff_test_profile_id AND
		featr.link_id = rel.ass_rel_id AND featr.initial_ongoing = 'o' AND featr.calc_level = rel.calc_level AND
		featr.as_of_date <= rel.as_of_date
	GROUP BY rel.link_id, rel.use_eff_test_profile_id, rel.ass_rel_id, rel.calc_level, rel.as_of_date
	) md INNER JOIN
	fas_eff_ass_test_results fr ON fr.eff_test_profile_id = md.eff_test_profile_id AND
		fr.link_id = md.link_id AND fr.initial_ongoing = 'o' AND fr.calc_level = md.calc_level AND
		fr.as_of_date = md.res_as_of_date
	GROUP BY md.eff_test_profile_id, md.real_link_id, md.link_id, md.calc_level, md.as_of_date, md.res_as_of_date
) As A INNER JOIN --LEFT OUTER JOIN
fas_eff_ass_test_results B(NOLOCK) ON A.eff_test_result_id = B.eff_test_result_id INNER JOIN --RIGHT OUTER JOIN 
fas_eff_hedge_rel_type C(NOLOCK) ON A.eff_test_profile_id = C.eff_test_profile_id LEFT OUTER JOIN 
fas_eff_ass_test_results_process_header D ON D.eff_test_result_id = B.eff_test_result_id INNER  JOIN 
portfolio_hierarchy book ON book.entity_id = C.fas_book_id INNER  JOIN 
fas_strategy fs ON book.parent_entity_id = fs.fas_strategy_id LEFT OUTER JOIN t_distribution td ON 
				td.df = 
						CASE WHEN (D.regression_df > 1001) THEN 1001 
						  WHEN (D.regression_df BETWEEN 100 AND 1000) THEN 100
						  WHEN (D.regression_df BETWEEN 80 AND 100) THEN 80
						  WHEN (D.regression_df BETWEEN 60 AND 80) THEN 60
						  WHEN (D.regression_df BETWEEN 50 AND 60) THEN 50	
						  WHEN (D.regression_df BETWEEN 40 AND 50) THEN 40
						  WHEN (D.regression_df BETWEEN 30 AND 40) THEN 30
					          ELSE 	D.regression_df END
		AND td.alpha = 
			CAST(CASE WHEN (C.on_eff_test_approach_value_id = 305) THEN fs.test_range_from/2
				  when (C.on_eff_test_approach_value_id IN (307, 309, 311, 313)) THEN fs.additional_test_range_from/2
				  when (C.on_eff_test_approach_value_id = 306) THEN fs.test_range_from
				  when (C.on_eff_test_approach_value_id IN (308, 310, 312, 314)) THEN fs.additional_test_range_from
			END AS VARCHAR)
LEFT OUTER JOIN f_distribution fd ON fd.ndf = 1 AND 
		fd.ddf = CASE WHEN (D.regression_df > 34) THEN 34 ELSE D.regression_df END   
		AND fd.alpha = 
			CAST(CASE WHEN (C.on_eff_test_approach_value_id = 305) THEN fs.test_range_from/2
				  WHEN (C.on_eff_test_approach_value_id IN (307, 309, 311, 313)) THEN fs.additional_test_range_from/2
				  WHEN (C.on_eff_test_approach_value_id = 306) THEN fs.test_range_from
				  WHEN (C.on_eff_test_approach_value_id IN (308, 310, 312, 314)) THEN fs.additional_test_range_from
			END AS VARCHAR)
GROUP BY A.link_id, A.real_link_id

--OLD Ass info logic WHERE dedesignation was not working
/*
SELECT 	C.eff_test_profile_id, 
	B.result_value as assessment_values,
	B.additional_result_value as additional_assessment_values,
	B.additional_result_value2 as additional_assessment_values2,
	CASE 	WHEN (C.on_eff_test_approach_value_id IN (305, 307, 309, 311, 313)) THEN td.t_value
		WHEN (C.on_eff_test_approach_value_id IN (306, 308, 310, 312, 314)) THEN fd.f_value
		ELSE NULL
	END as t_f_value,
	B.as_of_date AS assessment_date, 
	C.on_eff_test_approach_value_id,
	D.regression_df as ddf,
	CAST(case 	when (C.on_eff_test_approach_value_id = 305) THEN fs.test_range_from/2
			when (C.on_eff_test_approach_value_id IN (307, 309, 311, 313)) THEN fs.additional_test_range_from/2
			when (C.on_eff_test_approach_value_id = 306) THEN fs.test_range_from
			when (C.on_eff_test_approach_value_id IN (308, 310, 312, 314)) THEN fs.additional_test_range_from
	END AS VARCHAR) alpha,
	CASE WHEN(B.link_id IS NULL) THEN -1 ELSE B.link_id END as link_id, 
	CASE WHEN(B.calc_level IS NULL) THEN -1 ELSE B.calc_level END as calc_level, 
	B.eff_test_result_id,
	ISNULL(C.force_intercept_zero, 'n') as short_cut_method,
	ISNULL(C.ineffectiveness_in_hedge, 'n') as exclude_spot_forward_diff
INTO #ass_info
FROM
(
SELECT    MaxDate.eff_test_profile_id, MaxDate.link_id, MaxDate.calc_level, MaxDate.as_of_date, 
	  MAX(featr.eff_test_result_id) AS eff_test_result_id
FROM      fas_eff_ass_test_results featr(NOLOCK) 
	LEFT OUTER JOIN
          (
		SELECT	eff_test_profile_id, link_id, calc_level, MAX(as_of_date) AS as_of_date
		FROM    fas_eff_ass_test_results(NOLOCK)
		                         
		WHERE   (as_of_date = ISNULL(CONVERT(DATETIME, @assessment_date,102), as_of_date)) AND 
			(initial_ongoing = 'o') AND (as_of_date <= @as_of_date AND
			calc_level <> 3)                          
		GROUP BY eff_test_profile_id, link_id, calc_level
	   ) MaxDate ON featr.eff_test_profile_id = MaxDate.eff_test_profile_id AND 
	      	featr.as_of_date = MaxDate.as_of_date AND featr.link_id = MaxDate.link_id 
		AND featr.calc_level = MaxDate.calc_level 
GROUP BY MaxDate.eff_test_profile_id, MaxDate.link_id, MaxDate.calc_level, MaxDate.as_of_date
)
As A 
	LEFT OUTER JOIN
fas_eff_ass_test_results B(NOLOCK)
ON A.eff_test_profile_id = B.eff_test_profile_id AND A.as_of_date = B.as_of_date AND 
	A.eff_test_result_id = B.eff_test_result_id
RIGHT OUTER JOIN 
fas_eff_hedge_rel_type C(NOLOCK) ON A.eff_test_profile_id = C.eff_test_profile_id
LEFT OUTER JOIN 
fas_eff_ass_test_results_process_header D ON D.eff_test_result_id = B.eff_test_result_id
INNER  JOIN portfolio_hierarchy book ON book.entity_id = C.fas_book_id
INNER  JOIN fas_strategy fs ON book.parent_entity_id = fs.fas_strategy_id
LEFT OUTER JOIN t_distribution td ON 
				td.df = 
						CASE WHEN (D.regression_df > 1001) THEN 1001 
						  WHEN (D.regression_df BETWEEN 100 AND 1000) THEN 100
						  WHEN (D.regression_df BETWEEN 80 AND 100) THEN 80
						  WHEN (D.regression_df BETWEEN 60 AND 80) THEN 60
						  WHEN (D.regression_df BETWEEN 50 AND 60) THEN 50	
						  WHEN (D.regression_df BETWEEN 40 AND 50) THEN 40
						  WHEN (D.regression_df BETWEEN 30 AND 40) THEN 30
					          ELSE 	D.regression_df END
		AND td.alpha = 
			CAST(CASE WHEN (C.on_eff_test_approach_value_id = 305) THEN fs.test_range_from/2
				  when (C.on_eff_test_approach_value_id IN (307, 309, 311, 313)) THEN fs.additional_test_range_from/2
				  when (C.on_eff_test_approach_value_id = 306) THEN fs.test_range_from
				  when (C.on_eff_test_approach_value_id IN (308, 310, 312, 314)) THEN fs.additional_test_range_from
			END AS VARCHAR)
LEFT OUTER JOIN f_distribution fd ON fd.ndf = 1 AND 
		fd.ddf = CASE WHEN (D.regression_df > 34) THEN 34 ELSE D.regression_df END   
		AND fd.alpha = 
			CAST(CASE WHEN (C.on_eff_test_approach_value_id = 305) THEN fs.test_range_from/2
				  when (C.on_eff_test_approach_value_id IN (307, 309, 311, 313)) THEN fs.additional_test_range_from/2
				  when (C.on_eff_test_approach_value_id = 306) THEN fs.test_range_from
				  when (C.on_eff_test_approach_value_id IN (308, 310, 312, 314)) THEN fs.additional_test_range_from
			END AS VARCHAR)
*/

create index [idx_ass_info_tmp] on #ass_info (eff_test_profile_id,link_id,on_eff_test_approach_value_id)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Collecting Assessment Values *****************************'	
END
-----------------------------  END OF RETRIEVING ASSESSMENT VALUES ----------------------------------		
-----------------------------  BEGIN CALC_PROCESS_DEALS WITH DEALS AND PNL -------------------------------------------------
DECLARE @remove_eff_pnl VARCHAR(500)
DECLARE @u_pnl VARCHAR(1000)
DECLARE @u_int_pnl VARCHAR(1000)
DECLARE @u_ext_pnl VARCHAR(1000)
DECLARE @d_pnl VARCHAR(1000)
DECLARE @d_int_pnl VARCHAR(1000)
DECLARE @d_ext_pnl VARCHAR(1000)
DECLARE @include VARCHAR(1000)
DECLARE @f_u_pnl VARCHAR(1000)
DECLARE @f_d_pnl VARCHAR(1000)

SET @remove_eff_pnl = ' CASE WHEN pnl_Data.use_deal_date IS NULL OR #BasicInfo.hedge_type_value_id = 152 OR #BasicInfo.link_type = ''deal'' OR
							((#BasicInfo.link_effective_date = #BasicInfo.deal_date) AND
							(#BasicInfo.deal_date = pnl_Data.use_deal_date) AND ('+@first_day_pnl+' = 1 OR ('+@first_day_pnl+' = 7 AND #BasicInfo.link_id < 0 ) OR ('+@first_day_pnl+'IN (5, 6) and #BasicInfo.hedge_or_item <> ''i'') OR ('+@first_day_pnl+'=6 and #BasicInfo.hedge_or_item = ''i'' and inception_flag=0))) THEN 0 
						ELSE 1 END '

SET @u_pnl = ' (CASE WHEN (#BasicInfo.book_map_end_date IS NULL) THEN ISNULL(pnl_Data.und_pnl, 0) - ISNULL(pnl_Data.fd_und_pnl, 0) 
				  ELSE ISNULL(por_end_pnl.und_pnl, 0) - ISNULL(por_end_pnl.fd_und_pnl, 0) END - 
					CASE WHEN (' + @remove_eff_pnl + ' = 1) THEN ISNULL(eff_pnl_Data.und_pnl, 0) - ISNULL(eff_pnl_Data.fd_und_pnl, 0) ELSE 0 END)
					* ISNULL(#BasicInfo.percentage_included, 1) '

SET @f_u_pnl = ' (CASE WHEN (#BasicInfo.book_map_end_date IS NULL) THEN ISNULL(pnl_Data.und_pnl, 0) - ISNULL(pnl_Data.fd_und_pnl, 0) 
				  ELSE ISNULL(por_end_pnl.und_pnl, 0) - ISNULL(por_end_pnl.fd_und_pnl, 0) END)
					* ISNULL(#BasicInfo.percentage_included, 1) '

SET @u_int_pnl = ' (CASE WHEN (#BasicInfo.book_map_end_date IS NULL) THEN ISNULL(pnl_Data.und_intrinsic_pnl, 0) - ISNULL(pnl_Data.fd_und_intrinsic_pnl, 0)
				  ELSE ISNULL(por_end_pnl.und_intrinsic_pnl, 0) - ISNULL(por_end_pnl.fd_und_intrinsic_pnl, 0) END - 
					CASE WHEN (' + @remove_eff_pnl + ' = 1) THEN ISNULL(eff_pnl_Data.und_intrinsic_pnl, 0) - ISNULL(eff_pnl_Data.fd_und_intrinsic_pnl, 0) ELSE 0 END)
				 * ISNULL(#BasicInfo.percentage_included, 1) '

SET @u_ext_pnl = ' (CASE WHEN (#BasicInfo.book_map_end_date IS NULL) THEN ISNULL(pnl_Data.und_extrinsic_pnl, 0) - ISNULL(pnl_Data.fd_und_extrinsic_pnl, 0)
				  ELSE ISNULL(por_end_pnl.und_extrinsic_pnl, 0) - ISNULL(por_end_pnl.fd_und_extrinsic_pnl, 0) END - 
					CASE WHEN (' + @remove_eff_pnl + ' = 1) THEN ISNULL(eff_pnl_Data.und_extrinsic_pnl, 0) - ISNULL(eff_pnl_Data.fd_und_extrinsic_pnl, 0) ELSE 0 END)
				 * ISNULL(#BasicInfo.percentage_included, 1) '

SET @d_pnl = ' (CASE WHEN (#BasicInfo.book_map_end_date IS NULL) THEN ISNULL(pnl_Data.dis_pnl, 0) - (ISNULL(pnl_Data.fd_und_pnl, 0) * ISNULL(dist.discount_factor, 1))
				  ELSE ISNULL(por_end_pnl.dis_pnl, 0) - (ISNULL(por_end_pnl.fd_und_pnl, 0) * ISNULL(dist.discount_factor, 1)) END - 
					CASE WHEN (' + @remove_eff_pnl + ' = 1) THEN ISNULL(eff_pnl_Data.dis_pnl, 0) - (ISNULL(eff_pnl_Data.fd_und_pnl, 0) * ISNULL(dist.discount_factor, 1)) ELSE 0 END)
					* ISNULL(#BasicInfo.percentage_included, 1) '

SET @f_d_pnl = ' (CASE WHEN (#BasicInfo.book_map_end_date IS NULL) THEN ISNULL(pnl_Data.dis_pnl, 0) - (ISNULL(pnl_Data.fd_und_pnl, 0) * ISNULL(dist.discount_factor, 1))
				  ELSE ISNULL(por_end_pnl.dis_pnl, 0) - (ISNULL(por_end_pnl.fd_und_pnl, 0) * ISNULL(dist.discount_factor, 1)) END)
					* ISNULL(#BasicInfo.percentage_included, 1) '

SET @d_int_pnl = ' (CASE WHEN (#BasicInfo.book_map_end_date IS NULL) THEN ISNULL(pnl_Data.dis_intrinsic_pnl, 0) - (ISNULL(pnl_Data.fd_und_intrinsic_pnl, 0)* ISNULL(dist.discount_factor, 1))
				  ELSE ISNULL(por_end_pnl.dis_intrinsic_pnl, 0) - (ISNULL(por_end_pnl.fd_und_intrinsic_pnl, 0) * ISNULL(dist.discount_factor, 1)) END - 
					CASE WHEN (' + @remove_eff_pnl + ' = 1) THEN ISNULL(eff_pnl_Data.dis_intrinsic_pnl, 0) - (ISNULL(eff_pnl_Data.fd_und_intrinsic_pnl, 0) * ISNULL(dist.discount_factor, 1)) ELSE 0 END)
				 * ISNULL(#BasicInfo.percentage_included, 1) '

SET @d_ext_pnl = ' (CASE WHEN (#BasicInfo.book_map_end_date IS NULL) THEN ISNULL(pnl_Data.dis_extrinsic_pnl, 0) - (ISNULL(pnl_Data.fd_und_extrinsic_pnl, 0) * ISNULL(dist.discount_factor, 1))
				  ELSE ISNULL(por_end_pnl.dis_extrinsic_pnl, 0) - (ISNULL(por_end_pnl.fd_und_extrinsic_pnl, 0) * ISNULL(dist.discount_factor, 1)) END - 
					CASE WHEN (' + @remove_eff_pnl + ' = 1) THEN ISNULL(eff_pnl_Data.dis_extrinsic_pnl, 0) - (ISNULL(eff_pnl_Data.fd_und_extrinsic_pnl, 0) * ISNULL(dist.discount_factor, 1)) ELSE 0 END)
				 * ISNULL(#BasicInfo.percentage_included, 1) '

--SET @include = '
--				CASE WHEN(ISNULL(#BasicInfo.fully_dedesignated, ''n'') = ''y'' AND #BasicInfo.link_end_date IS NULL) THEN ''n''
--					 WHEN (#BasicInfo.link_type = ''deal'' AND #BasicInfo.hedge_type_value_id = 152 ) THEN ''y''
--					 WHEN (#BasicInfo.link_type = ''deal'' AND #BasicInfo.hedge_or_item = ''h'') THEN
--						CASE 	WHEN (#BasicInfo.include_unlinked_hedges = ''y'' ) THEN ''y'' ELSE ''n'' END
--					WHEN 	(#BasicInfo.link_type = ''deal'' AND #BasicInfo.hedge_or_item = ''i'') THEN
--						CASE 	WHEN (#BasicInfo.include_unlinked_items = ''y'' ) THEN ''y'' ELSE ''n'' END
--				ELSE ''y'' END 
--			'

SET @include = '
	CASE WHEN (
		(ISNULL(#BasicInfo.fully_dedesignated, ''n'') = ''y'' AND #BasicInfo.link_end_date IS NULL)
		or (#BasicInfo.link_type = ''deal'' AND #BasicInfo.hedge_or_item = ''h'' AND #BasicInfo.include_unlinked_hedges <> ''y'')
		or (#BasicInfo.link_type = ''deal'' AND #BasicInfo.hedge_or_item = ''i'' AND #BasicInfo.include_unlinked_items <> ''y'')
	) THEN ''n'' ELSE ''y'' END
'

EXEC('
CREATE TABLE '+ @DealProcessTableName+' (
	[fas_subsidiary_id] [INT] NOT NULL,
	[fas_strategy_id] [INT] NOT NULL,
	[fas_book_id] [INT] NOT NULL,
	[source_deal_header_id] [INT] NOT NULL,
	[deal_date] [DATETIME] NOT NULL,
	[deal_type] [INT] NOT NULL,
	[deal_sub_type] [INT] NULL,
	[source_counterparty_id] [INT] NULL,
	[physical_financial_flag] [CHAR](1)   NULL,
	[as_of_date] [DATETIME] NOT NULL,
	[term_start] [DATETIME] NOT NULL,
	[term_end] [DATETIME] NOT NULL,
	[Leg] [INT] NOT NULL,
	[contract_expiration_date] [DATETIME] NOT NULL,
	[fixed_float_leg] [CHAR](1)   NOT NULL,
	[buy_sell_flag] [CHAR](1)   NOT NULL,
	[curve_id] [INT] NULL,
	[fixed_price] [FLOAT] NULL,
	[fixed_price_currency_id] [INT] NULL,
	[option_strike_price] [FLOAT] NULL,
	[deal_volume] [FLOAT] NOT NULL,
	[deal_volume_frequency] [CHAR](1)   NOT NULL,
	[deal_volume_uom_id] [INT] NOT NULL,
	[block_description] [VARCHAR](100)   NULL,
	[deal_detail_description] [VARCHAR](1000)   NULL,
	[hedge_or_item] [VARCHAR](1)   NULL,
	[link_id] [INT] NULL,
	[percentage_included] [FLOAT] NOT NULL,
	[link_effective_date] [DATETIME] NULL,
	[dedesignation_link_id] [INT] NULL,
	[link_type] [VARCHAR](5)   NOT NULL,
	[discount_factor] [FLOAT] NOT NULL,
	[func_cur_value_id] [INT] NOT NULL,
	[und_pnl] [FLOAT] NULL,
	[und_intrinsic_pnl] [FLOAT] NULL,
	[und_extrinsic_pnl] [FLOAT] NULL,
	[pnl_currency_id] [INT] NULL,
	[pnl_conversion_factor] [FLOAT] NULL,
	[pnl_source_value_id] [INT] NULL,
	[link_active] [CHAR](1)   NULL,
	[fully_dedesignated] [CHAR](1)   NULL,
	[perfect_hedge] [CHAR](1)   NULL,
	[eff_test_profile_id] [INT] NULL,
	[link_type_value_id] [INT] NULL,
	[dedesignated_link_id] [INT] NULL,
	[hedge_type_value_id] [INT] NOT NULL,
	[fx_hedge_flag] [CHAR](1)   NOT NULL,
	[no_links] [CHAR](1)   NOT NULL,
	[mes_gran_value_id] [INT] NULL,
	[mes_cfv_value_id] [INT] NULL,
	[mes_cfv_values_value_id] [INT] NULL,
	[gl_grouping_value_id] [INT] NULL,
	[mismatch_tenor_value_id] [INT] NULL,
	[strip_trans_value_id] [INT] NULL,
	[asset_liab_calc_value_id] [INT] NOT NULL,
	[test_range_from] [FLOAT] NULL,
	[test_range_to] [FLOAT] NULL,
	[additional_test_range_from] [FLOAT] NULL,
	[additional_test_range_to] [FLOAT] NULL,
	[additional_test_range_from2] [FLOAT] NULL,
	[additional_test_range_to2] [FLOAT] NULL,
	[include_unlinked_hedges] [CHAR](1)   NOT NULL,
	[include_unlinked_items] [CHAR](1)   NOT NULL,
	[no_link] [CHAR](1) NULL,
	[use_eff_test_profile_id] [INT] NULL,
	[on_eff_test_approach_value_id] [INT] NULL,
	[no_links_fas_eff_test_profile_id] [INT] NULL,
	[dedesignation_pnl_currency_id] [INT] NULL,
	[pnl_ineffectiveness_value] [FLOAT] NULL,
	[pnl_dedesignation_value] [FLOAT] NULL,
	[locked_aoci_value] [FLOAT] NULL,
	[pnl_cur_coversion_factor] FLOAT NOT NULL,
	[ded_pnl_cur_conversion_factor] FLOAT NOT NULL,
	[eff_pnl_cur_conversion_factor] FLOAT NOT NULL,
	[assessment_values] [FLOAT] NULL,
	[additional_assessment_values] [FLOAT] NULL,
	[additional_assessment_values2] [FLOAT] NULL,
	[use_assessment_values] [FLOAT] NULL,
	[use_additional_assessment_values] [FLOAT] NULL,
	[use_additional_assessment_values2] [FLOAT] NULL,
	[assessment_date] [DATETIME] NULL,
	[ddf] [INT] NULL,
	[alpha] [VARCHAR](30)   NULL,
	[eff_und_pnl] [FLOAT] NULL,
	[eff_und_intrinsic_pnl] [FLOAT] NULL,
	[eff_und_extrinsic_pnl] [FLOAT] NULL,
	[eff_pnl_source_value_id] [INT] NULL,
	[eff_pnl_currency_id] [INT] NULL,
	[eff_pnl_conversion_factor] [FLOAT] NULL,
	[eff_pnl_as_of_date] [DATETIME] NULL,
	[pnl_as_of_date] [DATETIME] NULL,
	[dedesignation_date] [DATETIME] NULL,
	[deal_id] [VARCHAR](5000)   NULL,
	[option_flag] [CHAR](1)   NULL,
	[final_dis_pnl] [FLOAT] NULL,
	[final_dis_instrinsic_pnl] [FLOAT] NULL,
	[final_dis_extrinsic_pnl] [FLOAT] NULL,
	[final_dis_locked_aoci_value] FLOAT NOT NULL,
	[final_dis_dedesignated_cum_pnl] FLOAT NOT NULL,
	[final_dis_pnl_ineffectiveness_value] FLOAT NOT NULL,
	[final_dis_pnl_dedesignation_value] FLOAT NOT NULL,
	[final_dis_pnl_remaining] [FLOAT] NULL,
	[final_dis_pnl_intrinsic_remaining] [FLOAT] NULL,
	[final_dis_pnl_extrinsic_remaining] [FLOAT] NULL,
	[final_und_pnl] [FLOAT] NOT NULL,
	[final_und_instrinsic_pnl] [FLOAT] NOT NULL,
	[final_und_extrinsic_pnl] [FLOAT] NOT NULL,
	[final_und_locked_aoci_value] FLOAT NOT NULL,
	[final_und_dedesignated_cum_pnl] FLOAT NOT NULL,
	[final_und_pnl_ineffectiveness_value] FLOAT NOT NULL,
	[final_und_pnl_dedesignation_value] FLOAT NOT NULL,
	[final_und_pnl_remaining] [FLOAT] NULL,
	[final_und_pnl_intrinsic_remaining] [FLOAT] NULL,
	[final_und_pnl_extrinsic_remaining] [FLOAT] NULL,
	[item_match_term_month] [DATETIME] NULL,
	[item_term_month] [DATETIME] NULL,
	[long_term_months] [INT] NULL,
	[source_system_id] [INT] NULL,
	[include] [VARCHAR](1)   NOT NULL,
	[hedge_term_month] [DATETIME] NULL,
	[eff_test_result_id] [INT] NULL,
	[notional_pay_pnl] FLOAT NOT NULL,
	[notional_rec_pnl] FLOAT NOT NULL,
	[receive_float] [VARCHAR](1)   NOT NULL,
	[carrying_amount] FLOAT NOT NULL,
	[carrying_set_amount] FLOAT NOT NULL,
	[interest_debt] FLOAT NULL,
	[short_cut_method] [CHAR](1) NULL,
	[exclude_spot_forward_diff] [CHAR](1)   NULL,
	[option_premium] [FLOAT] NULL,
	[options_premium_approach] [INT] NULL,
	[options_amortization_factor] [FLOAT] NULL,
	[fd_und_pnl] [FLOAT] NOT NULL,
	[fd_und_intrinsic_pnl] [FLOAT] NOT NULL,
	[fd_und_extrinsic_pnl] [FLOAT] NOT NULL,
	[fd_und_ignored_pnl] [FLOAT] NOT NULL,
	[link_dedesignated_percentage] [FLOAT] NOT NULL,
	[fas_deal_type_value_id] [INT] NULL,
	[fas_deal_sub_type_value_id] [INT] NULL,
	[mstm_eff_test_type_id] [INT] NOT NULL,
	[p_u_hedge_mtm] [FLOAT] NULL,
	[p_d_hedge_mtm] [FLOAT] NULL,
	[p_u_aoci] [FLOAT] NULL,
	[p_d_aoci] [FLOAT] NULL,
	[p_u_total_pnl] [FLOAT] NULL,
	[p_d_total_pnl] [FLOAT] NULL,
	[test_settled] [INT] NOT NULL,
	[rollout_per_type] [INT] NULL,
	[tax_perc] [FLOAT] NULL,
	[oci_rollout_approach_value_id] [INT] NULL,
	[link_end_date] [DATETIME] NULL,
	[dis_pnl] [FLOAT] NULL,
	[prior_assessment_test] [INT] null
) ON [PRIMARY]'
)

CREATE TABLE [dbo].[#prior_val](
	[p_link_id] [INT] NULL,
	[p_source_deal_header_id] [INT] NOT NULL,
	[p_leg] [INT] NOT NULL,
	[p_term_start] [DATETIME] NOT NULL,
	[p_u_hedge_mtm] [FLOAT] NULL,
	[p_u_aoci] [FLOAT] NULL,
	[p_u_total_pnl] [FLOAT] NULL,
	[p_d_hedge_mtm] [FLOAT] NULL,
	[p_d_aoci] [FLOAT] NULL,
	[p_d_total_pnl] [FLOAT] NULL,
	[deal_volume] [FLOAT] NULL,
	[final_und_dedesignated_cum_pnl] [FLOAT] NULL, --prior locked ineffectivenss cumulative undiscounted value
	[final_dis_dedesignated_cum_pnl] [FLOAT] NULL, --prior locked ineffectivenss cumulative discounted value
    [p_percentage_included] [FLOAT] NULL,
	[prior_p_u_aoci] [FLOAT] NULL,
	[prior_p_d_aoci] [FLOAT] NULL,
	[prior_assessment_test] [INT] NULL
)

-- UB DEBUG
-- SELECT * from #prior_val WHERE p_source_deal_header_id = 365438 and p_link_id = 1671 and p_term_start = '2019-01-01'
-- SELECT link_type_value_id, prior_assessment_Test, * from adiha_process.dbo.calcprocess_deals_farrms_admin_123456 WHERE source_deal_header_id = 365438 and term_Start = '2019-01-01' and link_id = 1671
--SELECT assessment_test, link_type_value_id, * from calcprocess_deals_arch1 WHERE source_deal_header_id = 365438 and term_Start = '2019-01-01' and link_id = 1671 order by as_of_Date desc
--SELECT * from static_data_value WHERE value_id = 451
SET @sqlSelect1 = 
'
INSERT INTO #prior_val
SELECT cp.link_id p_link_id, cp.source_deal_header_id p_source_deal_header_id,
	   cp.leg p_leg,	
	   cp.term_start AS p_term_start,
	   SUM(CASE WHEN (mes_cfv_values_value_id = 225) THEN 
				final_und_pnl_intrinsic_remaining ELSE
					final_und_pnl_remaining END / NULLIF(percentage_included, 0)) AS p_u_hedge_mtm,
	   SUM(u_aoci / NULLIF(percentage_included, 0)) p_u_aoci,
	   SUM((u_pnl_ineffectiveness+u_extrinsic_pnl+u_pnl_mtm) / NULLIF(percentage_included, 0)) p_u_total_pnl,
	   SUM(CASE WHEN (mes_cfv_values_value_id = 225) THEN 
			final_dis_pnl_intrinsic_remaining ELSE
			final_dis_pnl_remaining END/ NULLIF (percentage_included, 0)) AS p_d_hedge_mtm,
	   SUM(d_aoci/NULLIF(percentage_included, 0)) p_d_aoci,
	   SUM((d_pnl_ineffectiveness+d_extrinsic_pnl+d_pnl_mtm) / NULLIF(percentage_included, 0)) p_d_total_pnl,
	   NULLIF(SUM(cp.deal_volume), 0) deal_volume,
	   SUM(final_und_dedesignated_cum_pnl) final_und_dedesignated_cum_pnl,
	   SUM(final_dis_dedesignated_cum_pnl) final_dis_dedesignated_cum_pnl,
	   MAX(cP.percentage_included) p_percentage_included,
	   SUM(p_u_aoci) prior_p_u_aoci,
	   SUM(p_d_aoci) prior_p_d_aoci,
	   MAX(cp.assessment_test) prior_assessment_test	
FROM #tmp_deal td INNER JOIN ' + dbo.FNAGetProcessTableName(@std_prior_as_of_date, 'calcprocess_deals') + ' cp 
	ON cp.source_deal_header_id = td.source_deal_header_id
WHERE cp.as_of_date = ''' + @std_prior_as_of_date  + '''
GROUP BY cp.link_id, cp.source_deal_header_id, cp.leg, cp.term_start
'

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END
EXEC(@sqlSelect1)

CREATE INDEX [IDX_PRIOR_VAL] ON #prior_val (p_source_deal_header_id,p_term_start,p_link_id)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) + '*************************************'
	PRINT '****************inserting into #prior_val *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

CREATE TABLE #fully_inventory_aoci_released (f_link_id INT, f_link_type VARCHAR(20) COLLATE DATABASE_DEFAULT)

--Inventory Hedge Change
--retrieves links whose aoci have been fully released and no need to process further
INSERT INTO #fully_inventory_aoci_released
SELECT DISTINCT link_id, 'link' from inventory_reclassify_aoci
WHERE fully_released = 'y' and reclassify_date < @std_contract_month

CREATE INDEX [IDX_FIAR] ON #fully_inventory_aoci_released (f_link_id, f_link_type)

SELECT link_id, link_type, MAX(term_end) max_hedge_term_month
INTO #max_hedge_term
FROM #BasicInfo 
WHERE (hedge_or_item = 'h' AND link_type <> 'deal') AND  
	(link_active <> 'n' OR link_active IS NULL) 
	--Inventory Hedge Change
	AND (mismatch_tenor_value_id = 252 OR (oci_rollout_approach_value_id <> 500))
	--AND mismatch_tenor_value_id = 252
	AND hedge_type_value_id BETWEEN 150 AND 151 
	AND fas_deal_sub_type_value_id = 1225 
GROUP BY link_id, link_type
 
CREATE INDEX [IDX_MAX_HEDGE_TERM] ON #max_hedge_term (link_id,link_type)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************inserting into #prior_val *****************************'	
END
--SELECT * from #BasicInfo
--DECLARE @no_months INT 
DECLARE @sql_lag_stm VARCHAR(8000) 
--SET @no_months=3 --this had been replaced by rel_type.strip_item_months

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

EXEC ('CREATE TABLE ' + @MTableName + ' (m_link_id INT, item_end_month DATETIME NULL, m_link_type VARCHAR(20))')

--InventoryHedge Change
SET @sqlSelect1 = 
'
	INSERT INTO ' + @MTableName + '
	SELECT cpd.link_id,
		MAX(
		CASE WHEN(rel_type.strip_months = 1 AND rel_type.strip_item_months = 1 AND rel_type.lagging_months IS NOT NULL) THEN
				DATEADD(mm, rel_type.lagging_months, cpd.term_start)
				WHEN rel_type.strip_months IS NULL or rel_type.lagging_months IS NULL or rel_type.strip_item_months IS NULL OR
					(rel_type.strip_months = 0 or rel_type.lagging_months = 0 or rel_type.strip_item_months = 0) THEN
				NULL
		ELSE
			DATEADD(mm,-rel_type.strip_item_months+ISNULL(rel_type.strip_months,6)+ISNULL(rel_type.lagging_months,0)+ISNULL(rel_type.strip_item_months,3),CONVERT(DATETIME,CAST(YEAR(cpd.term_start) AS VARCHAR)+''-''+ CAST(((MONTH(cpd.term_start)/rel_type.strip_item_months)+(CASE WHEN (MONTH(cpd.term_start)%rel_type.strip_item_months=0) THEN 0 ELSE 1 END))*rel_type.strip_item_months AS VARCHAR)+''-01'',120))
		END) item_end_month, ''link'' m_link_type
	FROM (
		SELECT source_deal_header_id,curve_id,link_id,link_type, term_start, as_of_date, use_eff_test_profile_id
						from #BasicInfo
		WHERE  hedge_type_value_id = 150 AND hedge_or_item = ''h''  and as_of_date= ''' + @std_as_of_date + '''  AND curve_id IS NOT NULL 				
	AND (mismatch_tenor_value_id=252 AND rollout_per_type BETWEEN 522 and 523)
		GROUP BY source_deal_header_id,curve_id,link_id,link_type, term_start, as_of_date,use_eff_test_profile_id
		) cpd --hedge Deal
		LEFT JOIN
		(
			SELECT eff_test_profile_id,source_curve_def_id curve_id,MAX(strip_months) strip_months,MAX(strip_year_overlap) lagging_months,MAX(roll_forward_year) strip_item_months 
			from fas_eff_hedge_rel_type_detail WHERE  hedge_or_item=''h'' and source_curve_def_id IS NOT NULL
			GROUP BY eff_test_profile_id,source_curve_def_id
		) rel_type on rel_type.curve_id=cpd.curve_id AND rel_type.eff_test_profile_id = cpd.use_eff_test_profile_id
GROUP BY cpd.link_id
'
EXEC(@sqlSelect1)
EXEC('CREATE INDEX [IDX_MTERM] ON ' + @MTableName + ' (m_link_id, m_link_type)')

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************inserting into @MTableName *****************************'	
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END
--SELECT * from #mterm
--SELECT * from #cp_aa

CREATE TABLE #cp_aa (link_id INT, link_type VARCHAR(5) COLLATE DATABASE_DEFAULT)

----#cp_aa contains fully expired links that should not be processed
SET @sqlSelect1 =
'
INSERT INTO #cp_aa
SELECT link_id,link_type 
FROM #BasicInfo  
--Inventory Hedge Change
LEFT OUTER JOIN #fully_inventory_aoci_released fiar on f_link_id = link_id AND f_link_type = link_type
LEFT OUTER JOIN ' + @MTableName + ' mterm on m_link_id = link_id AND mterm.m_link_type = link_type
WHERE hedge_type_value_id = 151 OR hedge_type_value_id = 152 OR (hedge_type_value_id = 150 AND oci_rollout_approach_value_id = 500) OR
	(hedge_type_value_id = 150 AND oci_rollout_approach_value_id <> 500 AND f_link_id IS NOT NULL)
GROUP BY link_id, link_type 
HAVING MAX(ISNULL(mterm.item_end_month, #BasicInfo.term_start)) <= DATEADD(mm,-1, ''' + @std_as_of_date + ''') '

----Inventory Hedge Change
--AND (MAX(oci_rollout_approach_value_id) = 500 OR
--	MAX(oci_rollout_approach_value_id) <> 500 AND f_link_id IS NOT NULL)
EXEC(@sqlSelect1)

cREATE INDEX [IDX_CP_AA] ON #cp_aa (link_id,link_type)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************inserting into #cp_aa *****************************'	
END
 
SET @sqlSelect1 = 'INSERT INTO ' + @DealProcessTableName + 
		' SELECT #BasicInfo.fas_subsidiary_id, 
			#BasicInfo.fas_strategy_id, 
			#BasicInfo.fas_book_id, 
			#BasicInfo.source_deal_header_id, 
			#BasicInfo.deal_date,
			#BasicInfo.deal_type,
			#BasicInfo.deal_sub_type, 
			#BasicInfo.source_counterparty_id,
			#BasicInfo.physical_financial_flag,
			#BasicInfo.as_of_date ,
			#BasicInfo.term_start, 
			#BasicInfo.term_end, 
			#BasicInfo.Leg, 
			#BasicInfo.contract_expiration_date, 
			#BasicInfo.fixed_float_leg, 
			#BasicInfo.buy_sell_flag, 
			#BasicInfo.curve_id, 
			#BasicInfo.fixed_price, 
			#BasicInfo.fixed_price_currency_id, 
 			#BasicInfo.option_strike_price, 
			#BasicInfo.deal_volume, 
			#BasicInfo.deal_volume_frequency, 
			#BasicInfo.deal_volume_uom_id, 
			#BasicInfo.block_description, 
			#BasicInfo.deal_detail_description, 
			#BasicInfo.hedge_or_item, 
			#BasicInfo.link_id, 
			ISNULL(#BasicInfo.percentage_included, 1) as percentage_included, 
			#BasicInfo.link_effective_date, 
			#BasicInfo.dedesignation_link_id, 
			#BasicInfo.link_type,  
			ISNULL(dist.discount_factor, 1) as discount_factor, 
			#BasicInfo.func_cur_value_id, 
			pnl_Data.und_pnl, 
			pnl_Data.und_intrinsic_pnl, 
			pnl_Data.und_extrinsic_pnl, 
			ISNULL(pnl_Data.pnl_currency_id, #BasicInfo.func_cur_value_id) pnl_currency_id, 
			pnl_Data.pnl_conversion_factor, 
			pnl_Data.pnl_source_value_id, 
			#BasicInfo.link_active, 
			#BasicInfo.fully_dedesignated, 
			#BasicInfo.perfect_hedge, 
			#BasicInfo.eff_test_profile_id, 
			#BasicInfo.link_type_value_id, 
			#BasicInfo.dedesignated_link_id,
			CASE WHEN (#BasicInfo.link_id = #BasicInfo.source_deal_header_id AND #BasicInfo.link_type <> ''link'') THEN 152 ELSE #BasicInfo.hedge_type_value_id END hedge_type_value_id, 
			#BasicInfo.fx_hedge_flag, 
			#BasicInfo.no_links, 
			#BasicInfo.mes_gran_value_id, 
			#BasicInfo.mes_cfv_value_id,
			#BasicInfo.mes_cfv_values_value_id,
			#BasicInfo.gl_grouping_value_id,
			CASE WHEN (#BasicInfo.link_id = #BasicInfo.source_deal_header_id AND #BasicInfo.link_type <> ''link'') THEN 250 ELSE #BasicInfo.mismatch_tenor_value_id END mismatch_tenor_value_id,
			#BasicInfo.strip_trans_value_id,
			#BasicInfo.asset_liab_calc_value_id,			
			CASE WHEN (rel_type.on_eff_test_approach_value_id BETWEEN 305 AND 306) THEN #ass_info.t_f_value ELSE #BasicInfo.test_range_from END AS test_range_from,
			#BasicInfo.test_range_to,
			CASE WHEN (rel_type.on_eff_test_approach_value_id IN (307, 308, 309, 310, 311, 312, 313, 314)) THEN #ass_info.t_f_value ELSE #BasicInfo.additional_test_range_from END AS additional_test_range_from,
			#BasicInfo.additional_test_range_to,
			#BasicInfo.additional_test_range_from2 AS additional_test_range_from2,
			#BasicInfo.additional_test_range_to2 AS additional_test_range_to2,
			#BasicInfo.include_unlinked_hedges,
			#BasicInfo.include_unlinked_items,
			#BasicInfo.no_link, 
			#BasicInfo.use_eff_test_profile_id, 
			rel_type.on_eff_test_approach_value_id, 
			#BasicInfo.no_links_fas_eff_test_profile_id, 
			ISNULL(#BasicInfo.dedesignation_pnl_currency_id, #BasicInfo.func_cur_value_id) dedesignation_pnl_currency_id, 
			--#BasicInfo.dedesignation_pnl_currency_id, 
			#BasicInfo.pnl_ineffectiveness_value, 
			#BasicInfo.pnl_dedesignation_value, 
            #BasicInfo.locked_aoci_value, 
			1 AS pnl_cur_coversion_factor, 
			1 AS ded_pnl_cur_conversion_factor, 
            1 AS eff_pnl_cur_conversion_factor, 
			CASE WHEN (#ass_info.on_eff_test_approach_value_id = 304 OR #BasicInfo.perfect_hedge= ''y'' OR #ass_info.on_eff_test_approach_value_id = 320) THEN 1 ELSE #ass_info.assessment_values END AS assessment_values, 
			#ass_info.additional_assessment_values,
			#ass_info.additional_assessment_values2,
			#ass_info.assessment_values AS use_assessment_values,
			#ass_info.additional_assessment_values AS use_additional_assessment_values,
			#ass_info.additional_assessment_values2 AS use_additional_assessment_values2,
			#ass_info.assessment_date,
			#ass_info.ddf, 
			#ass_info.alpha, 
			eff_pnl_Data.und_pnl eff_und_pnl, 
			eff_pnl_Data.und_intrinsic_pnl eff_und_intrinsic_pnl, 
            eff_pnl_Data.und_extrinsic_pnl eff_und_extrinsic_pnl, 
			eff_pnl_Data.pnl_source_value_id eff_pnl_source_value_id, 
			ISNULL(eff_pnl_Data.pnl_currency_id, #BasicInfo.func_cur_value_id) eff_pnl_currency_id, 
			--eff_pnl_Data.pnl_currency_id eff_pnl_currency_id, 
            eff_pnl_Data.pnl_conversion_factor eff_pnl_conversion_factor,
            eff_pnl_Data.pnl_as_of_date as eff_pnl_as_of_date,
			pnl_Data.pnl_as_of_date_used pnl_as_of_date,
			#BasicInfo.dedesignation_date,
			#BasicInfo.deal_id,
			#BasicInfo.option_flag,
			CASE WHEN (' + CAST(@mtm_value_source AS VARCHAR) + ' = 1) THEN ' + @f_u_pnl + ' * ISNULL( dist.discount_factor, 1)
			ELSE  ' + @f_d_pnl + ' END AS final_dis_pnl, 
			CASE WHEN (' + CAST(@mtm_value_source AS VARCHAR) + ' = 1) THEN ISNULL(pnl_Data.und_intrinsic_pnl, 0) * ISNULL( dist.discount_factor, 1) ELSE ISNULL(pnl_Data.dis_intrinsic_pnl, 0) END AS final_dis_instrinsic_pnl, 
			CASE WHEN (' + CAST(@mtm_value_source AS VARCHAR) + ' = 1) THEN ISNULL(pnl_Data.und_extrinsic_pnl, 0) * ISNULL( dist.discount_factor, 1) ELSE ISNULL(pnl_Data.dis_extrinsic_pnl, 0) END AS final_dis_extrinsic_pnl, 
			pnl_Data.accrued_interest final_dis_locked_aoci_value, -- hold accrued interest value
			--0 AS final_dis_locked_aoci_value, 
			ISNULL(CASE WHEN (prior_val.p_link_id <> #BasicInfo.link_id) THEN #BasicInfo.percentage_dedesignated 
     WHEN (#BasicInfo.link_type_value_id = 450) THEN #BasicInfo.percentage_included/NULLIF(prior_val.p_percentage_included,0) 
				 ELSE 1 
			END * prior_val.final_dis_dedesignated_cum_pnl, 0) AS final_dis_dedesignated_cum_pnl, --prior locked ineffectivness cum value 
			0 AS final_dis_pnl_ineffectiveness_value, 
			0 AS final_dis_pnl_dedesignation_value, ' 
		
SET @sqlSelect2 = CASE WHEN (@mtm_value_source = 1) THEN
				@u_pnl + ' * ISNULL( dist.discount_factor, 1) AS final_dis_pnl_remaining, ' +
				@u_int_pnl + ' * ISNULL( dist.discount_factor, 1) AS final_dis_pnl_intrinsic_remaining, ' +
				@u_ext_pnl + ' * ISNULL( dist.discount_factor, 1) AS final_dis_pnl_extrinsic_remaining, ' 
			ELSE
				@d_pnl + ' AS final_dis_pnl_remaining, ' +
				@d_int_pnl + ' AS final_dis_pnl_intrinsic_remaining, ' +
				@d_ext_pnl + ' AS final_dis_pnl_extrinsic_remaining, ' 		
			END +
			
			@f_u_pnl + ' AS final_und_pnl, 
			ISNULL(pnl_Data.und_intrinsic_pnl, 0) AS final_und_instrinsic_pnl, 
			ISNULL(pnl_Data.und_extrinsic_pnl, 0) AS final_und_extrinsic_pnl, 
			0 AS final_und_locked_aoci_value, 
			ISNULL(CASE WHEN (prior_val.p_link_id <> #BasicInfo.link_id) THEN #BasicInfo.percentage_dedesignated 
			WHEN (#BasicInfo.link_type_value_id = 450) THEN #BasicInfo.percentage_included/NULLIF(prior_val.p_percentage_included,0)   
				 ELSE 1 
			END * prior_val.final_und_dedesignated_cum_pnl, 0) AS final_und_dedesignated_cum_pnl, --prior locked ineffectivness cum value 
			0 AS final_und_pnl_ineffectiveness_value, 
			0 AS final_und_pnl_dedesignation_value, ' +
			@u_pnl + ' AS final_und_pnl_remaining, ' +
			@u_int_pnl + ' AS final_und_pnl_intrinsic_remaining, ' +
			@u_ext_pnl + ' AS final_und_pnl_extrinsic_remaining, 
			dbo.FNALastDayInDate(ISNULL(max_hedge_term.max_hedge_term_month, #BasicInfo.term_start)) AS item_match_term_month,
			CAST(dbo.FNAGetContractMonth(#BasicInfo.term_start) AS DATETIME) AS item_term_month,
			#BasicInfo.long_term_months,
			#BasicInfo.source_system_id,
			' + @include + ' AS include,
			CAST(dbo.FNAGetContractMonth(#BasicInfo.term_end) AS DATETIME) AS hedge_term_month,
			#ass_info.eff_test_result_id, '

SET @sqlFrom = 
'
			0 AS notional_pay_pnl,	
			0 AS notional_rec_pnl,
			''n'' receive_float,
			0 AS carrying_amount,
			0 AS carrying_set_amount,
			NULL interest_debt,
			#ass_info.short_cut_method,
			#ass_info.exclude_spot_forward_diff,
			CASE WHEN (#BasicInfo.option_flag <> ''y'') THEN 0 
				ELSE CASE WHEN (#BasicInfo.buy_sell_flag = ''b'') THEN  1 ELSE -1 END * 
					ISNULL(#BasicInfo.fixed_price, 0) *  ISNULL(#BasicInfo.deal_volume, 0) *
					CASE WHEN #BasicInfo.deal_volume_frequency =''d'' THEN (datediff(day,#BasicInfo.term_start,#BasicInfo.term_end)+1) ELSE 1 END 
			END AS option_premium, 	
			CASE WHEN (#BasicInfo.option_flag <> ''y'') THEN  NULL ELSE #BasicInfo.options_premium_approach END options_premium_approach, 
			#BasicInfo.options_amortization_factor,
			ISNULL(pnl_Data.fd_und_pnl, 0) fd_und_pnl,
			ISNULL(pnl_Data.fd_und_intrinsic_pnl, 0) fd_und_intrinsic_pnl,
			ISNULL(pnl_Data.fd_und_extrinsic_pnl, 0) fd_und_extrinsic_pnl,
			ISNULL(pnl_Data.fd_und_ignored_pnl, 0) fd_und_ignored_pnl,
			ISNULL(#BasicInfo.percentage_dedesignated, 1) link_dedesignated_percentage,
			#BasicInfo.fas_deal_type_value_id,
			#BasicInfo.fas_deal_sub_type_value_id,
			ISNULL(rel_type.mstm_eff_test_type_id, 4075) mstm_eff_test_type_id, ' +
			CASE WHEN (@prior_aoci_disc_value = 0) THEN
			' 
			ISNULL(prior_val.p_u_hedge_mtm*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included p_u_hedge_mtm,  
			ISNULL(prior_val.p_u_hedge_mtm*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included * ISNULL(dist.discount_factor, 1) AS p_d_hedge_mtm,  
						CASE WHEN (#BasicInfo.link_type_value_id=452 AND #BasicInfo.prior_value_link_id = #BasicInfo.link_id) THEN prior_p_u_aoci 
			ELSE ISNULL(prior_val.p_u_aoci*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included END p_u_aoci,  
						CASE WHEN (#BasicInfo.link_type_value_id=452 AND #BasicInfo.prior_value_link_id = #BasicInfo.link_id) THEN prior_p_d_aoci 
							 WHEN (#BasicInfo.link_type_value_id=452 AND #BasicInfo.prior_value_link_id <> #BasicInfo.link_id) THEN ISNULL(prior_val.p_d_aoci*#BasicInfo.deal_volume/prior_val.deal_volume, 0) * #BasicInfo.percentage_included  
			ELSE ISNULL(prior_val.p_u_aoci*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included * ISNULL(dist.discount_factor, 1) END p_d_aoci,  
			ISNULL(prior_val.p_u_total_pnl*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included p_u_total_pnl,  
			ISNULL(prior_val.p_u_total_pnl*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included * ISNULL(dist.discount_factor, 1) p_d_total_pnl,  
					'
					ELSE
					' 
			ISNULL(prior_val.p_u_hedge_mtm*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included p_u_hedge_mtm,  
			ISNULL(prior_val.p_d_hedge_mtm*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included AS p_d_hedge_mtm,  
						CASE WHEN (#BasicInfo.link_type_value_id=452 AND #BasicInfo.prior_value_link_id = #BasicInfo.link_id) THEN prior_p_u_aoci 
			ELSE ISNULL(prior_val.p_u_aoci*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included END p_u_aoci,   
						CASE WHEN (#BasicInfo.link_type_value_id=452 AND #BasicInfo.prior_value_link_id = #BasicInfo.link_id) THEN prior_p_d_aoci 
			ELSE ISNULL(prior_val.p_d_aoci*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included END p_d_aoci,  
			ISNULL(prior_val.p_u_total_pnl*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included p_u_total_pnl,  
			ISNULL(prior_val.p_d_total_pnl*#BasicInfo.deal_volume/NULLIF(prior_val.deal_volume,0), 0) * #BasicInfo.percentage_included p_d_total_pnl,  
					'
			END +
			'
			CASE WHEN (#BasicInfo.term_start <= #BasicInfo.as_of_date) THEN 1 ELSE 0 END test_settled,
			#BasicInfo.rollout_per_type, #BasicInfo.tax_perc, #BasicInfo.oci_rollout_approach_value_id, #BasicInfo.book_map_end_date link_end_date,
			CASE WHEN (' + CAST(@mtm_value_source AS VARCHAR) + ' = 1) THEN pnl_data.und_pnl *  ISNULL(dist.discount_factor, 1) ELSE pnl_data.dis_pnl END AS dis_pnl,
			ISNULL(prior_val.prior_assessment_test, 1) prior_assessment_test
	
		 FROM   #BasicInfo LEFT OUTER JOIN ' 
				+ @dealPNL + ' pnl_Data ON
				pnl_Data.source_deal_header_id = #BasicInfo.source_deal_header_id AND pnl_Data.term_start = #BasicInfo.term_start AND 
                pnl_Data.term_end = #BasicInfo.term_end AND --pnl_Data.Leg = #BasicInfo.Leg AND 
				pnl_Data.pnl_as_of_date = #BasicInfo.as_of_date LEFT OUTER JOIN ' + 
				@dealPNL + ' eff_pnl_Data ON
				eff_pnl_Data.source_deal_header_id = #BasicInfo.source_deal_header_id AND eff_pnl_Data.term_start = #BasicInfo.term_start AND 
                eff_pnl_Data.term_end = #BasicInfo.term_end AND --eff_pnl_Data.Leg = #BasicInfo.Leg AND 
				eff_pnl_Data.pnl_as_of_date = #BasicInfo.link_effective_date LEFT OUTER JOIN
                ' + @dealPNL + ' por_end_pnl ON 
                --#BasicInfo.Leg = por_end_pnl.Leg AND 
				#BasicInfo.term_end = por_end_pnl.term_end AND #BasicInfo.book_map_end_date = por_end_pnl.pnl_as_of_date AND
                #BasicInfo.term_start = por_end_pnl.term_start AND 
				#BasicInfo.source_deal_header_id = por_end_pnl.source_deal_header_id LEFT OUTER JOIN
				fas_eff_hedge_rel_type rel_type ON rel_type.eff_test_profile_id = #BasicInfo.use_eff_test_profile_id LEFT OUTER JOIN	
				#ass_info ON #ass_info.ass_link_id =  CASE	WHEN(#ass_info.on_eff_test_approach_value_id IN (302, 304, 320)) THEN  -1 
														WHEN (rel_type.individual_link_calc = ''y'' AND #BasicInfo.mes_gran_value_id = 178) THEN -1*#BasicInfo.fas_strategy_id
														WHEN (rel_type.individual_link_calc = ''y'' AND #BasicInfo.link_type_value_id <> 450) THEN #BasicInfo.dedesignation_link_id 
														WHEN (rel_type.individual_link_calc = ''y'') THEN #BasicInfo.link_id 
														ELSE -1 END AND 
				#ass_info.link_id = #BasicInfo.link_id AND
				#ass_info.calc_level = CASE WHEN(#ass_info.on_eff_test_approach_value_id IN (302, 304, 320)) THEN  -1 WHEN (rel_type.individual_link_calc = ''y'') THEN 2 ELSE 1	END	
			'
SET @sqlFrom1 = '
			LEFT OUTER JOIN
			 ' + @DiscountTableName + ' dist ON ' +
				CASE WHEN (@is_discount_curve_a_factor IN (2)) THEN ' dist.source_deal_header_id = #BasicInfo.source_deal_header_id AND dist.term_start = #BasicInfo.term_start '
				ELSE  ' dist.term_start = #BasicInfo.term_start AND dist.fas_subsidiary_id = #BasicInfo.fas_subsidiary_id ' END + '

			LEFT OUTER JOIN 
			 #prior_val prior_val ON  #BasicInfo.source_deal_header_id = prior_val.p_source_deal_header_id AND 
				--#BasicInfo.leg = prior_val.p_leg AND 
				#BasicInfo.term_start = prior_val.p_term_start AND
				#BasicInfo.prior_value_link_id = prior_val.p_link_id
				--#BasicInfo.link_id = prior_val.p_link_id
			LEFT OUTER JOIN 
			#cp_aa aa 	on #BasicInfo.link_id=aa.link_id AND #BasicInfo.link_type=aa.link_type ' +
			' LEFT OUTER JOIN 
			#max_hedge_term max_hedge_term ON
				max_hedge_term.link_id = #BasicInfo.link_id AND max_hedge_term.link_type = #BasicInfo.link_type 
			WHERE aa.link_id IS NULL AND aa.link_type IS NULL 
				AND #BasicInfo.link_effective_date <= ''' + @std_as_of_date + '''
				AND (' + @include + ' = ''y'') ' 

--print @sqlFrom1
-- SELECT * from adiha_process.dbo.calcprocess_deals_farrms_admin_123456

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

--SELECT len(@sqlSelect1), len(@sqlSelect2), len(@sqlFrom), len(@sqlFrom1)
EXEC spa_print @sqlSelect1
EXEC spa_print @sqlSelect2
EXEC spa_print @sqlFrom
EXEC spa_print @sqlFrom1

EXEC(@sqlSelect1 + @sqlSelect2 + @sqlFrom + @sqlFrom1)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '*********************************DONE COLLECTING IN calcprocess deals process table '
END

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

EXEC('CREATE INDEX INDX_DEAL_PROCESS_12 ON ' +@DealProcessTableName +' (source_deal_header_id, as_of_date, term_start, term_end)') 

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '********************************************DONE Creating index in calcprocess deals'
END

---------------------------------------CALCULATE AOCI RELEASE SCHEDULE ----------------------------------------

--DECLARE @no_months INT --,@link_id INT,@as_of_date DATETIME
--DECLARE @sql_lag_stm VARCHAR(8000) --@DealProcessTableName VARCHAR(100)

--SET @DealProcessTableName='adiha_process.dbo.calcprocess_deals_farrms_admin_123456'
--SET @link_id=-229
--SET @as_of_date='2005-03-31'
--SET @no_months=3
CREATE TABLE #sum_item(
	source_deal_header_id INT,
	curve_id INT,
	link_id INT,
	h_term DATETIME,
	strip_months TINYINT,
	lagging_months TINYINT,
	strip_item_months TINYINT,
	i_start_term DATETIME,
	i_start_end DATETIME,
	pnl FLOAT,
	volume FLOAT,
	rollout_per_type INT,
	shift_only INT,
	d_pnl FLOAT
)

CREATE TABLE #Release_term_range(
	source_deal_header_id INT,
	curve_id INT,
	link_id INT,
	min_term DATETIME,
	max_term DATETIME
)

CREATE TABLE #tmp_hedge_term(
	[source_deal_header_id] [INT] NOT NULL,
	[curve_id] [INT] NULL,
	[link_id] [INT] NULL,
	[term_start] [DATETIME] NOT NULL,
	[strip_months] [INT] NULL,
	[lagging_months] [INT] NULL,
	[strip_item_months] [INT] NULL,
	[Item_start_month] [DATETIME] NULL,
	[Item_end_month] [DATETIME] NULL,
	[rollout_per_type] [INT] NULL,
	shift_only INT,
	overlap_start DATETIME,
	overlap_end DATETIME
) 

SET @sql_lag_stm = 'INSERT INTO #Release_term_range(source_deal_header_id,curve_id,link_id,min_term ,max_term )
					SELECT cpd.source_deal_header_id,cpd.curve_id,cpd.link_id,
						min(CASE WHEN (strip_months IN (0,1) AND strip_item_months IN (0,1) AND  lagging_months IS NOT NULL) THEN
							DATEADD(mm, lagging_months, cpd.term_start)	
						ELSE --add strip_months+lagging_months to first month of quarter
							DATEADD(month,strip_months+lagging_months,CONVERT(DATETIME,CAST(YEAR(cpd.term_start) AS VARCHAR) +''-''+ right(''0''+ CAST((((MONTH(cpd.term_start)/strip_item_months)
							+ CASE WHEN MONTH(cpd.term_start)%strip_item_months=0 THEN -1 ELSE 0 END)*strip_item_months)+1 AS VARCHAR),2) +''-01'',120))
						END
					 ) min_term ,
					MAX(
						CASE WHEN (strip_months IN (0,1) AND strip_item_months IN (0,1) AND  lagging_months IS NOT NULL) THEN
								DATEADD(mm, lagging_months, cpd.term_start)	
						ELSE
							DATEADD(month,
								CASE WHEN  datediff(month,cpd.term_start,cpd_max.max_term_start)+1>=strip_months THEN
									(strip_months+lagging_months+strip_item_months)-1	
								ELSE
									1
								END,
								CASE WHEN datediff(month,cpd.term_start,cpd_max.max_term_start)+1>=strip_months THEN
									CONVERT(DATETIME,CAST(YEAR(cpd.term_start) AS VARCHAR) + ''-'' + 
										CAST((rel_type.strip_item_months* CASE WHEN MONTH(cpd.term_start)%rel_type.strip_item_months=0 THEN  (MONTH(cpd.term_start)/rel_type.strip_item_months)-1 ELSE  MONTH(cpd.term_start)/rel_type.strip_item_months END)+1 AS VARCHAR)	 
										+''-01'' ,120)
								ELSE
									cpd.term_start
								END	)
						END		
					) max_term
					 FROM 
					(
						SELECT c.source_deal_header_id,c.curve_id,c.link_id, 
						MAX(CONVERT(DATETIME,CAST(YEAR(term_start) AS VARCHAR) +''-''+ right(''0''+ CAST((((MONTH(term_start)/strip_item_months)
							+ CASE WHEN MONTH(term_start)%strip_item_months=0 THEN 0 ELSE 1 END)*strip_item_months) AS VARCHAR),2) +''-01'',120)
						) max_term_start
						FROM ' + @DealProcessTableName + ' c
							LEFT JOIN  (
							SELECT eff_test_profile_id,source_curve_def_id curve_id,MAX(strip_months) strip_months,MAX(strip_year_overlap) lagging_months,MAX(roll_forward_year) strip_item_months 
							FROM fas_eff_hedge_rel_type_detail WHERE  hedge_or_item = ''h'' AND source_curve_def_id IS NOT NULL
							GROUP BY eff_test_profile_id,source_curve_def_id
							) r on  r.curve_id=c.curve_id and r.eff_test_profile_id = c.use_eff_test_profile_id				
						WHERE  c.hedge_type_value_id = 150 AND c.hedge_or_item = ''h''  AND as_of_date= ''' + @std_as_of_date + '''  AND c.curve_id IS NOT NULL 
							AND (c.mismatch_tenor_value_id=252 and c.rollout_per_type BETWEEN 522 AND 524)
						GROUP BY c.source_deal_header_id,c.curve_id,c.link_id
					) cpd_max
					INNER JOIN 	' + @DealProcessTableName + ' cpd 
					on cpd_max.source_deal_header_id = cpd.source_deal_header_id AND cpd_max.curve_id = cpd.curve_id AND cpd.link_id=cpd_max.link_id
					LEFT JOIN  			(
						SELECT eff_test_profile_id,source_curve_def_id curve_id,MAX(strip_months) strip_months,MAX(strip_year_overlap) lagging_months,MAX(roll_forward_year) strip_item_months 
						from fas_eff_hedge_rel_type_detail WHERE  hedge_or_item = ''h'' AND source_curve_def_id IS NOT NULL
						GROUP BY eff_test_profile_id,source_curve_def_id
					) rel_type ON rel_type.curve_id=cpd.curve_id AND rel_type.eff_test_profile_id= cpd.use_eff_test_profile_id
					WHERE  hedge_type_value_id = 150 AND hedge_or_item = ''h''  AND as_of_date= ''' + @std_as_of_date + '''  AND rel_type.curve_id IS NOT NULL 
						AND (mismatch_tenor_value_id=252 AND rollout_per_type BETWEEN 522 AND 524)
						AND NOT (ISNULL(rel_type.strip_months,0) = 6 AND ISNULL(rel_type.strip_item_months, 0) = 6)
					GROUP BY cpd.source_deal_header_id,cpd.curve_id,cpd.link_id'


EXEC spa_print @sql_lag_stm
EXEC(@sql_lag_stm)

--SELECT * from #sum_item
--SELECT * from #Release_term_range
-- This is for Lagging % release mechanism

SET @sql_lag_stm = 'INSERT INTO #tmp_hedge_term (
												[source_deal_header_id],[curve_id],[link_id],[term_start],[strip_months],[lagging_months],
												[strip_item_months],[Item_start_month],[Item_end_month],[rollout_per_type],shift_only)
	
					SELECT cpd.source_deal_header_id,cpd.curve_id,cpd.link_id, cpd.term_start
					, rel_type.strip_months strip_months,rel_type.lagging_months lagging_months,rel_type.strip_item_months strip_item_months,
					CASE WHEN rel_type.strip_months IS NULL or rel_type.lagging_months IS NULL or rel_type.strip_item_months IS NULL
					THEN NULL
					ELSE
						CASE WHEN(rel_type.strip_months IN (0,1) AND rel_type.strip_item_months IN (0,1) AND rel_type.lagging_months IS NOT NULL) THEN
								DATEADD(mm, rel_type.lagging_months, cpd.term_start)
						when MONTH(cpd.term_start)<=((((MONTH(cpd.term_start)/rel_type.strip_item_months)+(CASE WHEN (MONTH(cpd.term_start)%rel_type.strip_item_months=0) THEN 0 ELSE 1 END))*rel_type.strip_item_months)-rel_type.strip_item_months+(ISNULL(rel_type.strip_months,6)-rel_type.strip_item_months))
						THEN --if the month lie in the first overlap section of a strip_months THEN
							DATEADD(mm,(1-rel_type.strip_item_months+(ISNULL(rel_type.strip_months,6)-rel_type.strip_item_months)+ISNULL(rel_type.lagging_months,0)),CONVERT(DATETIME,CAST(YEAR(cpd.term_start) AS VARCHAR)+''-''+ CAST(((MONTH(cpd.term_start)/rel_type.strip_item_months)+(CASE WHEN (MONTH(cpd.term_start)%rel_type.strip_item_months=0) THEN 0 ELSE 1 END))*rel_type.strip_item_months AS VARCHAR)+''-01'',120))
						ELSE --if the month lie beyond the first overlap section of a strip_months AND prior to the second ovelap section.
							DATEADD(mm,1-rel_type.strip_item_months+ISNULL(rel_type.strip_months,6)+ISNULL(rel_type.lagging_months,0),CONVERT(DATETIME,CAST(YEAR(cpd.term_start) AS VARCHAR)+''-''+ CAST(((MONTH(cpd.term_start)/rel_type.strip_item_months)+(CASE WHEN (MONTH(cpd.term_start)%rel_type.strip_item_months=0) THEN 0 ELSE 1 END))*rel_type.strip_item_months AS VARCHAR)+''-01'',120))
						END
					END Item_start_month,
					CASE WHEN rel_type.strip_months IS NULL or rel_type.lagging_months IS NULL or rel_type.strip_item_months IS NULL
					THEN NULL
					ELSE
						CASE WHEN(rel_type.strip_months IN (0,1) AND rel_type.strip_item_months IN (0,1) AND rel_type.lagging_months IS NOT NULL) THEN
							DATEADD(mm, rel_type.lagging_months, cpd.term_start)
						ELSE
							DATEADD(mm,-rel_type.strip_item_months+ISNULL(rel_type.strip_months,6)+ISNULL(rel_type.lagging_months,0)+ISNULL(rel_type.strip_item_months,3),CONVERT(DATETIME,CAST(YEAR(cpd.term_start) AS VARCHAR)+''-''+ CAST(((MONTH(cpd.term_start)/rel_type.strip_item_months)+(CASE WHEN (MONTH(cpd.term_start)%rel_type.strip_item_months=0) THEN 0 ELSE 1 END))*rel_type.strip_item_months AS VARCHAR)+''-01'',120))
						END
					END Item_end_month,cpd.rollout_per_type,
					CASE WHEN(rel_type.strip_months IN (0,1) AND rel_type.strip_item_months IN (0,1) AND rel_type.lagging_months IS NOT NULL) THEN 1 ELSE 0 END shift_only
				FROM (
					SELECT source_deal_header_id,curve_id,link_id,link_type, term_start, as_of_date, use_eff_test_profile_id,
							SUM(CASE WHEN (fas_deal_sub_type_value_id = 1225) THEN
										CASE WHEN(hedge_type_value_id <> 152) THEN
										CASE WHEN (mes_cfv_values_value_id = 225) THEN 
											final_und_pnl_intrinsic_remaining ELSE final_und_pnl_remaining END
										ELSE
										CASE WHEN (mes_cfv_values_value_id = 225) THEN 
											final_und_instrinsic_pnl ELSE final_und_pnl END
										END
								ELSE 0 END) AS und_pnl,
							SUM(CASE WHEN (leg = 1 AND fas_deal_sub_type_value_id = 1225) THEN CASE WHEN(fully_dedesignated = ''y'') THEN 1 ELSE percentage_included END *
									CASE WHEN (buy_sell_flag = ''s'') THEN -1 ELSE 1 END * 
									deal_volume ELSE 0 END) volume,
							dbo.FNATestSettled(term_start, as_of_date) test_settled,MAX(rollout_per_type) rollout_per_type
					FROM '  +@DealProcessTableName + '
					WHERE  hedge_type_value_id = 150 AND hedge_or_item = ''h''  AND as_of_date= ''' + @std_as_of_date + '''  AND curve_id IS NOT NULL 
						AND (mismatch_tenor_value_id = 252 AND rollout_per_type BETWEEN 522 AND 524)
							GROUP BY source_deal_header_id,curve_id,link_id,link_type, term_start, as_of_date,use_eff_test_profile_id
							) cpd --hedge Deal
							LEFT JOIN
							(
								SELECT eff_test_profile_id,source_curve_def_id curve_id,MAX(strip_months) strip_months,MAX(strip_year_overlap) lagging_months,MAX(roll_forward_year) strip_item_months 
								from fas_eff_hedge_rel_type_detail WHERE hedge_or_item = ''h'' AND source_curve_def_id IS NOT NULL
								GROUP BY eff_test_profile_id,source_curve_def_id
							) rel_type ON rel_type.curve_id = cpd.curve_id AND rel_type.eff_test_profile_id = cpd.use_eff_test_profile_id
'
EXEC(@sql_lag_stm)

UPDATE #tmp_hedge_term 
SET Item_start_month = CASE WHEN aa.Item_start_month IS NULL THEN null
						ELSE
							CASE WHEN aa.rollout_per_type BETWEEN 522 AND 524 THEN
								CASE WHEN (aa.strip_months IN (0,1) AND aa.lagging_months IN (0,1) AND aa.strip_item_months IS NOT NULL) THEN
										aa.Item_start_month
								ELSE
									CASE WHEN aa.Item_start_month< ISNULL(rr.min_term,aa.Item_start_month) THEN rr.min_term ELSE aa.Item_start_month END
								END 
							ELSE
								aa.Item_start_month
							END
						END ,
	Item_end_month = CASE WHEN aa.Item_end_month IS NULL THEN null
					ELSE
						CASE WHEN aa.rollout_per_type BETWEEN 522 AND 524 THEN
							CASE WHEN (aa.strip_months IN (0,1) AND aa.lagging_months IN (0,1) AND aa.strip_item_months IS NOT NULL) THEN
									aa.Item_end_month
							ELSE
								CASE WHEN ISNULL(rr.max_term,aa.Item_end_month)>=aa.Item_end_month THEN aa.Item_end_month ELSE rr.max_term END
							END 
						ELSE
							aa.Item_end_month
						END
					END  
FROM #tmp_hedge_term aa 
INNER JOIN  #Release_term_range rr ON rr.link_id=aa.link_id AND aa.source_deal_header_id=rr.source_deal_header_id

--SELECT * from #tmp_hedge_term
--return
UPDATE #tmp_hedge_term 
SET [Item_start_month] = CASE 
							WHEN MONTH([term_start]) BETWEEN 1 AND 4 THEN CONVERT(DATETIME,CAST(YEAR([term_start]) AS VARCHAR) + '-07-01',120)
							WHEN MONTH([term_start]) BETWEEN 5 AND 10 THEN CONVERT(DATETIME,CAST(YEAR([term_start])+1 AS VARCHAR) + '-01-01',120)
							WHEN MONTH([term_start]) BETWEEN 11 AND 12 THEN CONVERT(DATETIME,CAST(YEAR([term_start])+1 AS VARCHAR) + '-07-01',120) 
						END
, [Item_end_month] = CASE 
						WHEN MONTH([term_start]) BETWEEN 1 AND 4 THEN CONVERT(DATETIME,CAST(YEAR([term_start]) AS VARCHAR) + '-12-01',120)
						WHEN MONTH([term_start]) BETWEEN 5 AND 10 THEN CONVERT(DATETIME,CAST(YEAR([term_start])+1 AS VARCHAR) + '-06-01',120)
						WHEN MONTH([term_start]) BETWEEN 11 AND 12 THEN CONVERT(DATETIME,CAST(YEAR([term_start])+1 AS VARCHAR) + '-12-01',120) 
					END
WHERE [strip_months] = 6 AND [lagging_months] = 2 AND [strip_item_months] = 6

SET @sql_lag_stm = '
INSERT INTO #sum_item (source_deal_header_id,curve_id,link_id,h_term,strip_months,lagging_months,strip_item_months,i_start_term,i_start_end,pnl,volume,rollout_per_type,shift_only, d_pnl)
SELECT cc.source_deal_header_id,cc.curve_id,cc.link_id,cc.h_term,cc.strip_months,cc.lagging_months,cc.strip_item_months,cc.Item_start_month,cc.Item_end_month,SUM(cc.pnl),SUM(cc.volume),MAX(cc.rollout_per_type) rollout_per_type,MAX(cc.shift_only) shift_only, SUM(cc.d_pnl)
FROM 
(
	SELECT DISTINCT aa.source_deal_header_id,aa.curve_id,aa.link_id,aa.term_start h_term,
	aa.strip_months,aa.lagging_months,aa.strip_item_months,
	aa.Item_start_month,
	aa.Item_end_month,		
	CASE WHEN bb.term_start IS NOT NULL
	THEN
		CASE WHEN bb.term_start BETWEEN aa.Item_start_month AND aa.Item_end_month
		THEN bb.term_start
		ELSE NULL END
	ELSE
		aa.term_start
	END itm_date,
	bb.und_pnl pnl, bb.volume volume,aa.rollout_per_type,
	aa.shift_only,
	bb.dis_pnl d_pnl
	FROM #tmp_hedge_term aa  --hedge term
	LEFT JOIN
	(SELECT link_id,link_type, term_start, as_of_date, 
			SUM(CASE WHEN (fas_deal_sub_type_value_id = 1225) THEN
					CASE WHEN(hedge_type_value_id <> 152) THEN
					CASE WHEN (mes_cfv_values_value_id = 225) THEN 
						final_und_pnl_intrinsic_remaining ELSE final_und_pnl_remaining END
					ELSE
					CASE WHEN (mes_cfv_values_value_id = 225) THEN 
						final_und_instrinsic_pnl ELSE final_und_pnl END
					END
				ELSE 0 END) AS und_pnl,
				SUM(CASE WHEN (fas_deal_sub_type_value_id = 1225) THEN
						CASE WHEN(hedge_type_value_id <> 152) THEN
						CASE WHEN (mes_cfv_values_value_id = 225) THEN 
							final_dis_pnl_intrinsic_remaining ELSE final_dis_pnl_remaining END
						ELSE
						CASE WHEN (mes_cfv_values_value_id = 225) THEN 
							final_dis_instrinsic_pnl ELSE final_dis_pnl END
						END
				ELSE 0 END) AS dis_pnl,
			SUM(CASE WHEN (leg = 1 AND fas_deal_sub_type_value_id = 1225) THEN CASE WHEN(fully_dedesignated = ''y'') THEN 1 ELSE percentage_included END * 
					CASE WHEN (buy_sell_flag = ''s'') THEN -1 ELSE 1 END * 
					deal_volume ELSE 0 END) volume
		FROM '+@DealProcessTableName+'
	WHERE  hedge_type_value_id = 150 AND hedge_or_item = ''i'' AND leg = 1 AND fas_deal_sub_type_value_id = 1225 AND as_of_date=''' + @std_as_of_date + '''
	AND (mismatch_tenor_value_id=252 AND rollout_per_type BETWEEN 522 AND 524)
	AND link_type = ''link''
	GROUP BY link_id,link_type, term_start, as_of_date
	) bb --item term
	ON aa.link_id=bb.link_id --AND bb.term_start BETWEEN aa.Item_start_month AND aa.Item_end_month
) cc --cross multiplecation result of hedge AND item
--WHERE cc.itm_date IS NOT NULL
WHERE (cc.strip_months IN (0, 1) AND cc.strip_item_months IN (0, 1)) OR
	  (cc.strip_months NOT IN (0, 1) AND cc.strip_item_months NOT IN (0, 1) AND (cc.itm_date IS NOT NULL or cc.rollout_per_type=524)) 
GROUP BY cc.source_deal_header_id,cc.curve_id,cc.link_id,cc.h_term,cc.Item_start_month,cc.Item_end_month,cc.strip_months,cc.lagging_months,cc.strip_item_months
'

--SELECT * from #sum_item

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

--print @sql_lag_stm
--return

EXEC(@sql_lag_stm)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of Collecting Lagging Info for AOCI Release Schedule*****************************'	
END

EXEC('
CREATE TABLE ' + @AOCIReleaseSchedule + ' (
	[source_deal_header_id] [INT] NULL,
	[as_of_date] [DATETIME] NULL,
	[link_id] [INT] NULL,
	[h_term] [DATETIME] NULL,
	[strip_months] [TINYINT] NULL,
	[lagging_months] [TINYINT] NULL,
	[strip_item_months] [TINYINT] NULL,
	[i_term] [DATETIME] NULL,
	[per_pnl] [FLOAT] NULL,
	[per_vol] [FLOAT] NULL,
	[per_d_pnl] [FLOAT] NULL
) ON [PRIMARY]
')
--SELECT * from #sum_item
SET @sql_lag_stm='
INSERT INTO ' + @AOCIReleaseSchedule + '
	SELECT aa.source_deal_header_id,COALESCE(bb.as_of_date,''' + @std_as_of_date + ''')  as_of_date,aa.link_id,aa.h_term,
	aa.strip_months,aa.lagging_months,aa.strip_item_months,
	--***--
	--COALESCE(bb.term_start,aa.h_term) i_term,
	COALESCE(bb.term_start,aa.i_start_term, aa.h_term) i_term,

	CASE  WHEN aa.pnl IS NULL or bb.pnl IS NULL or aa.shift_only=1 THEN 1
		WHEN aa.pnl=0 THEN 0
		ELSE 
			bb.pnl/aa.pnl 
	END [per_pnl],
	CASE WHEN aa.volume IS NULL or bb.volume IS NULL or aa.shift_only=1 THEN 1 
					WHEN aa.volume=0 THEN 0 
					ELSE bb.volume/aa.volume  
	END [per_vol],
	CASE  WHEN aa.d_pnl IS NULL or bb.d_pnl IS NULL or aa.shift_only=1 THEN 1
		WHEN aa.d_pnl=0 THEN 0
			ELSE bb.d_pnl/aa.d_pnl 
	END [per_d_pnl]
FROM #sum_item aa
LEFT JOIN
	(SELECT link_id,link_type, term_start, as_of_date, 
			SUM(CASE WHEN (fas_deal_sub_type_value_id = 1225) THEN
					CASE WHEN(hedge_type_value_id <> 152) THEN
					CASE WHEN (mes_cfv_values_value_id = 225) THEN 
						final_und_pnl_intrinsic_remaining ELSE final_und_pnl_remaining END
					ELSE
					CASE WHEN (mes_cfv_values_value_id = 225) THEN 
						final_und_instrinsic_pnl ELSE final_und_pnl END
					END
				ELSE 0 END) AS pnl,
				SUM(CASE WHEN (fas_deal_sub_type_value_id = 1225) THEN
					CASE WHEN(hedge_type_value_id <> 152) THEN
					CASE WHEN (mes_cfv_values_value_id = 225) THEN 
						final_dis_pnl_intrinsic_remaining ELSE final_dis_pnl_remaining END
					ELSE
					CASE WHEN (mes_cfv_values_value_id = 225) THEN 
						final_dis_instrinsic_pnl ELSE final_dis_pnl END
					END
				ELSE 0 END) AS d_pnl,
			SUM(CASE WHEN (leg = 1 AND fas_deal_sub_type_value_id = 1225) THEN CASE WHEN(fully_dedesignated = ''y'') THEN 1 ELSE percentage_included END * 
				CASE WHEN (buy_sell_flag = ''s'') THEN -1 ELSE 1 END * 
				deal_volume ELSE 0 END) volume
	FROM '+@DealProcessTableName+'
	WHERE  hedge_type_value_id = 150 AND hedge_or_item = ''i'' and leg = 1 and fas_deal_sub_type_value_id = 1225 and as_of_date=''' + @std_as_of_date + '''
		AND (mismatch_tenor_value_id=252 and rollout_per_type BETWEEN 522 and 523)
	GROUP BY link_id,link_type, term_start, as_of_date
	) bb ON aa.link_id=bb.link_id AND (bb.term_start BETWEEN i_start_term and i_start_end OR bb.term_start IS NULL) 
 WHERE aa.rollout_per_type BETWEEN 522 and 523
ORDER BY aa.source_deal_header_id,aa.link_id,aa.h_term,bb.term_start
'

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END
EXEC(@sql_lag_stm)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of calculating AOCI Release Schedule 1*****************************'	
END

--SELECT * from #sum_item

-- Volume or PNL % mechansim
SET @sql_lag_stm = ' 
INSERT INTO ' + @AOCIReleaseSchedule + '
SELECT hedge.source_deal_header_id,hedge.as_of_date,hedge.link_id, hedge.term_start h_term,null strip_months,null lagging_months,
null strip_item_months, item.term_start i_term,item.[% PNL],item.[% VOLUME], item.[% DPNL]   from (
SELECT ITEM.as_of_date,ITEM.link_id,ITEM.link_type,ITEM.term_start,ITEM.und_pnl,ITEM.volume,SUM_LINK.und_pnl S_und_pnl,SUM_LINK.volume S_VOLUME,
CASE WHEN SUM_LINK.und_pnl=0 THEN 0 ELSE ITEM.und_pnl/SUM_LINK.und_pnl END AS [% PNL],
CASE WHEN SUM_LINK.volume=0 THEN 0 ELSE ITEM.volume/SUM_LINK.volume END AS [% VOLUME], 
CASE WHEN SUM_LINK.dis_pnl=0 THEN 0 ELSE ITEM.dis_pnl/SUM_LINK.dis_pnl END AS [% DPNL]
FROM ( SELECT link_id, link_type, term_start, as_of_date, 
			SUM(CASE WHEN(hedge_type_value_id <> 152) THEN
				CASE WHEN (mes_cfv_values_value_id = 225) THEN 
					final_und_pnl_intrinsic_remaining ELSE
					final_und_pnl_remaining END
			ELSE
				CASE WHEN (mes_cfv_values_value_id = 225) THEN 
			                final_und_instrinsic_pnl ELSE 
					final_und_pnl END
			END) AS und_pnl,
			SUM(CASE WHEN(hedge_type_value_id <> 152) THEN
				CASE WHEN (mes_cfv_values_value_id = 225) THEN 
					final_dis_pnl_intrinsic_remaining ELSE
					final_dis_pnl_remaining END
			ELSE
				CASE WHEN (mes_cfv_values_value_id = 225) THEN 
			                final_dis_instrinsic_pnl ELSE 
					final_dis_pnl END
			END) AS dis_pnl,
			SUM(CASE WHEN leg = 1 THEN CASE WHEN(fully_dedesignated = ''y'') THEN 1 ELSE percentage_included END * 
					CASE WHEN (buy_sell_flag = ''s'') THEN -1 ELSE 1 END * 
					deal_volume ELSE 0 END) volume
			
		FROM '+@DealProcessTableName+'
		WHERE hedge_type_value_id = 150 AND hedge_or_item = ''i'' AND LEG=1 AND fas_deal_sub_type_value_id = 1225 AND as_of_date=''' + @std_as_of_date + '''
			AND (mismatch_tenor_value_id=252 AND rollout_per_type BETWEEN 520 AND 521)
		GROUP BY link_id, link_type, term_start, as_of_date) ITEM
INNER JOIN (SELECT link_id, link_type, as_of_date, 
				SUM(CASE WHEN(hedge_type_value_id <> 152) THEN
					CASE WHEN (mes_cfv_values_value_id = 225) THEN 
						final_und_pnl_intrinsic_remaining ELSE
						final_und_pnl_remaining END
				ELSE
					CASE WHEN (mes_cfv_values_value_id = 225) THEN 
								final_und_instrinsic_pnl ELSE 
						final_und_pnl END
				END) AS und_pnl	,
				SUM(CASE WHEN(hedge_type_value_id <> 152) THEN
					CASE WHEN (mes_cfv_values_value_id = 225) THEN 
						final_dis_pnl_intrinsic_remaining ELSE
						final_dis_pnl_remaining END
				ELSE
					CASE WHEN (mes_cfv_values_value_id = 225) THEN 
								final_dis_instrinsic_pnl ELSE 
						final_dis_pnl END
				END) AS dis_pnl	,
				SUM(CASE WHEN leg = 1 THEN CASE WHEN(fully_dedesignated = ''y'') THEN 1 ELSE percentage_included END * 
					CASE WHEN (buy_sell_flag = ''s'') THEN -1 ELSE 1 END * 
					deal_volume ELSE 0 END) volume		
		FROM '+@DealProcessTableName+'
		WHERE hedge_type_value_id = 150 AND hedge_or_item = ''i'' AND LEG=1 AND fas_deal_sub_type_value_id = 1225 AND as_of_date=''' + @std_as_of_date + '''
			AND (mismatch_tenor_value_id=252 and rollout_per_type BETWEEN 520 and 521)
		GROUP BY link_id, link_type,as_of_date) SUM_LINK
ON SUM_LINK.link_id=ITEM.link_id AND SUM_LINK.link_type=ITEM.link_type AND SUM_LINK.as_of_date=ITEM.as_of_date
) item
CROSS JOIN (
		SELECT source_deal_header_id,link_id, link_type, term_start, as_of_date
		FROM ' + @DealProcessTableName + '
		WHERE hedge_type_value_id = 150 AND hedge_or_item = ''h'' AND leg=1 AND as_of_date=''' + @std_as_of_date + '''
			AND (mismatch_tenor_value_id=252 AND rollout_per_type BETWEEN 520 AND 521)
		GROUP BY as_of_date,link_id, link_type, term_start,source_deal_header_id ) hedge
WHERE item.as_of_date=hedge.as_of_date AND item.link_id=hedge.link_id AND item.link_type = hedge.link_type
ORDER BY hedge.as_of_date,hedge.source_deal_header_id,hedge.link_id, hedge.link_type, hedge.term_start, item.term_start
'

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END
--print @sql_lag_stm
EXEC(@sql_lag_stm)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of calculating AOCI Release Schedule 2*****************************'	
END

-- perfect match tenor
SET @sql_lag_stm=' INSERT INTO ' + @AOCIReleaseSchedule + '
		SELECT source_deal_header_id,as_of_date,link_id, term_start h_term,null strip_months,null lagging_months,
		null strip_item_months, term_start i_term, 1 per_pnl,1 per_vol, 1 per_d_pnl
		FROM '+@DealProcessTableName+'
		WHERE hedge_type_value_id = 150 AND hedge_or_item = ''h'' AND LEG = 1 AND as_of_date = ''' + @std_as_of_date + '''
			AND (mismatch_tenor_value_id=250)
		GROUP BY link_id, link_type,source_deal_header_id, term_start, as_of_date
		ORDER BY source_deal_header_id,as_of_date,link_id, term_start'

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

EXEC(@sql_lag_stm)

IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of calculating AOCI Release Schedule 3*****************************'	
END

SET @sql_lag_stm='
;WITH cte (source_deal_header_id,curve_id,link_id,h_term,strip_months,lagging_months,strip_item_months,term_start,no_mnth, depth,start_mnth) AS (
		  SELECT source_deal_header_id,curve_id,link_id,h_term,strip_months,lagging_months,strip_item_months,i_start_term i_term, datediff(month,i_start_term,i_start_end)+1 no_mnth, 0 as depth ,i_start_term start_mnth 
			 FROM #sum_item WHERE rollout_per_type=524
		  UNION ALL
		  SELECT c.source_deal_header_id,c.curve_id,c.link_id, c.h_term,c.strip_months,c.lagging_months,c.strip_item_months, DATEADD(month,1,c.term_start) i_term,c.no_mnth,depth+1 depth,t.i_start_term start_mnth
		  FROM #sum_item t
		  INNER JOIN cte c on c.source_deal_header_id=t.source_deal_header_id AND c.h_term=t.h_term 
			AND c.link_id=t.link_id
			AND c.term_start<t.i_start_end AND rollout_per_type = 524
)
INSERT INTO ' + @AOCIReleaseSchedule + '
SELECT  source_deal_header_id,''' + @std_as_of_date + ''' as_of_date, link_id,h_term
	,strip_months,lagging_months,strip_item_months,term_start i_term,
	CASE WHEN cte.strip_months=6 AND cte.strip_item_months=6 THEN
		CASE WHEN no_mnth=9 THEN 
			CASE WHEN (datediff(month,cte.start_mnth,term_start) BETWEEN 3 AND 5) THEN
				(CASE WHEN no_mnth<=0 THEN 1 ELSE 2.0000/12 END) 
			ELSE
				(CASE WHEN no_mnth<=0 THEN 1 ELSE 1.0000/12 END)
			END
		ELSE
				(CASE WHEN no_mnth<=0 THEN 1 ELSE 1.0000/no_mnth END)
		END
	ELSE
		(CASE WHEN no_mnth<=0 THEN 1 ELSE 1.0000/no_mnth END)
	END [per_pnl],
	CASE WHEN cte.strip_months=6 AND cte.strip_item_months=6 THEN
		CASE WHEN no_mnth=9 THEN 
			CASE WHEN (datediff(month,cte.start_mnth,term_start) BETWEEN 3 AND 5) THEN
				(CASE WHEN no_mnth<=0 THEN 1 ELSE 2.0000/12 END) 
			ELSE
				(CASE WHEN no_mnth<=0 THEN 1 ELSE 1.0000/12 END)
			END
		ELSE
				(CASE WHEN no_mnth<=0 THEN 1 ELSE 1.0000/no_mnth END)
		END
	ELSE
		(CASE WHEN no_mnth<=0 THEN 1 ELSE 1.0000/no_mnth END)
	END [per_vol],
	CASE WHEN cte.strip_months=6 AND cte.strip_item_months=6 THEN
		CASE WHEN no_mnth=9 THEN 
			CASE WHEN (datediff(month,cte.start_mnth,term_start) BETWEEN 3 AND 5) THEN
				(CASE WHEN no_mnth<=0 THEN 1 ELSE 2.0000/12 END) 
			ELSE (CASE WHEN no_mnth<=0 THEN 1 ELSE 1.0000/12 END)
			END
		ELSE (CASE WHEN no_mnth<=0 THEN 1 ELSE 1.0000/no_mnth END) END
	ELSE
		(CASE WHEN no_mnth<=0 THEN 1 ELSE 1.0000/no_mnth END)
	END [per_d_pnl]  
FROM cte 
ORDER BY source_deal_header_id,link_id,h_term,i_term
OPTION (maxrecursion 0)
'

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END
EXEC spa_print @sql_lag_stm
EXEC(@sql_lag_stm)

--return
IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of calculating AOCI Release Schedule 4*****************************'	
END
--return
----------------------------------------END OF AOCI RELEASE SCHEDULE ------------------------------------------
--============DISGNOSTIC FOR MEASUREMENT LOGIC !!!!!!!! ==================================================
-----------------------------  BEGIN OF DIAGNOSTIC LOGIC ------------------------------------
DECLARE @diagnostic_sql VARCHAR(8000)
DECLARE @error_count INT
DECLARE @url_desc VARCHAR(8000)
DECLARE @url VARCHAR(8000)
DECLARE @user_name VARCHAR(50)

SET @user_name = @user_login_id

IF @print_diagnostic = 1
BEGIN
	SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
	SET @log_increment = @log_increment + 1
	SET @log_time = GETDATE()
	PRINT @pr_name + ' Running..............'
END

--1. discount_factor IS NULL
--msmt_excp_disc_factor
/*
SET @diagnostic_sql = 'INSERT INTO msmt_excp_disc_factor' + 
		      ' SELECT DISTINCT ''' + @process_id + ''' process_id, ''' + @dedesignation_calc +  ''' calc_type, as_of_date, ' + 
		      ' source_system_id, term_start Term ' + ', ''' + CONVERT(VARCHAR , getdate(), 21) + ''', ''' + @user_login_id + '''' + 
		      ' FROM ' + @DealProcessTableName + 
		      ' WHERE discount_factor IS NULL'
EXEC(@diagnostic_sql)
*/
--print @diagnostic_sql

/*
SELECT @error_count = COUNT(*) from msmt_excp_disc_factor 
WHERE process_id = @process_id and calc_type = @dedesignation_calc
IF @error_count > 0 AND @continue_disc_factor <> 2
BEGIN 
	SET @url = './spa_html.php?__user_name__=' + @user_name + 
	'&spa=EXEC spa_msmt_excp_disc_factor ''' + @process_id + ''''
	 
	SET @url_desc = '<a target="_blank" href="' + @url + '">' + 
		CASE WHEN(@dedesignation_calc = 'd') THEN 'De-designation' ELSE 'Measurment' END + 
		CASE WHEN (@continue_disc_factor = 1) THEN
			' WARNING(S): ' + CAST(@error_count AS VARCHAR) + 
			' Missing discount factors found due to missing discount rates. Value of 1 is used.' 
		     ELSE
			' ERROR(S): ' + CAST(@error_count AS VARCHAR) + 
			' Missing discount factors found due to missing discount rates.' 
		     END
		+ '</a>'
	INSERT INTO measurement_process_status
	SELECT CASE WHEN (@continue_disc_factor = 1) THEN 'Warning' ELSE 'Error' END as status_code, 
		@url_desc as status_description, @as_of_date as run_as_of_date,
		'' as assessment_values, @assessment_date, @sub_entity_id, @strategy_entity_id, @book_entity_id,
		CASE WHEN (@continue_disc_factor = 1) THEN 'y' ELSE 'n' END as can_proceed, 
		@process_id, @dedesignation_calc as calc_type, NULL as create_user, NULL as create_ts
END	

IF @print_diagnostic = 1
	EXEC spa_print 'END of diagnostic for msmt_excp_disc_factor'
*/


-----CHECK TO SEE IF NO PNL FOUND FOR AS_OF_DATE
--Inventroy Hedge Change
/*
CREATE TABLE #missing_pnl_count
(count_id INT, miss_count INT)

EXEC('INSERT INTO #missing_pnl_count SELECT 1, COUNT(*) TotalCount from ' + @dealPNL + ' WHERE pnl_as_of_date = ''' + @as_of_date + '''') 
EXEC('INSERT INTO #missing_pnl_count SELECT 2, COUNT(*) TotalCount from ' + @dealPNL + ' WHERE pnl_as_of_date_used IS NULL and pnl_as_of_date = ''' + @as_of_date + '''') 

if (SELECT miss_count from #missing_pnl_count WHERE count_id = 1) = (SELECT miss_count from #missing_pnl_count WHERE count_id = 2)
BEGIN
	INSERT INTO measurement_process_status
	SELECT 	'Error' as status_code, 
		'There is no MTM found for some to all deals as of date: '''  + dbo.FNADateFormat(@as_of_date) + '''' as status_description, 
		@as_of_date as run_as_of_date,
		'' as assessment_values, 
		NULL assessment_date, 
		NULL sub_entity_id, 
		NULL strategy_entity_id, 
		NULL book_entity_id,
		'n' as can_proceed, 
		@process_id,
		@dedesignation_calc, 
		NULL as create_user, NULL as create_ts
	
	EXEC spa_print '*******************No MTM found for given as of date***********************'

	--SELECT * from measurement_process_status
	RETURN
END
*/

--2. SUM(und_pnl) by source_deal_header_id, contract month, leg if null (pnl_as_of_date vs as_of_date)
--	pnl intrinsic vs extrinisic
/*	
SET @diagnostic_sql = ' INSERT INTO msmt_excp_pnl
			SELECT DISTINCT ''' + @process_id + ''' process_id, ''' + @dedesignation_calc +  ''' calc_type, as_of_date, ' + 
		' fas_subsidiary_id, fas_strategy_id, fas_book_id, 
			CAST(source_deal_header_id AS VARCHAR) + '' ('' + deal_id + '')'' DealID, as_of_date Term, 
			as_of_date PNLDate, pnl_as_of_date PNLDateUsed, 
			CASE WHEN (und_pnl IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingPNL,
			ISNULL(und_pnl, 0) PNLUsed,
			CASE WHEN (mes_cfv_values_value_id = 225 AND option_flag = ''y'' 
					AND und_intrinsic_pnl IS NULL) THEN ''Yes'' ELSE ''No'' END MissingIntrinsicPNL, 
			ISNULL(und_intrinsic_pnl, 0) PNLIntrinsicUsed,
			CASE WHEN (mes_cfv_values_value_id = 225 AND option_flag = ''y'' 
					AND und_extrinsic_pnl IS NULL) THEN ''Yes'' ELSE ''No'' END MissingExtrinsicPNL, 
			ISNULL(und_extrinsic_pnl, 0) PNLExtrinsicUsed ' + ', ''' + CONVERT(VARCHAR , getdate(), 21) + ''', ''' + @user_login_id + '''' + 
		      ' FROM ' + @DealProcessTableName + ' cdeals ' +
		' WHERE   (cdeals.pnl_as_of_date IS NULL) '

--print @diagnostic_sql

EXEC(@diagnostic_sql)



--print @diagnostic_sql
--print @diagnostic_sql

SELECT @error_count = COUNT(*) from msmt_excp_pnl 
WHERE process_id = @process_id 
IF @error_count > 0 --AND @continue_pnl  <> 2
BEGIN 
	SET @url = './spa_html.php?__user_name__=' + @user_name + 
	'&spa=EXEC spa_msmt_excp_pnl ''' + @process_id + ''''
	 
	SET @continue_pnl = 1
	SET @url_desc = '<a target="_blank" href="' + @url + '">' + 
		CASE WHEN(@dedesignation_calc = 'd') THEN 'De-designation' ELSE 'Measurment' END + 
		CASE WHEN (@continue_pnl = 1) THEN
			' WARNING(S): ' + CAST(@error_count AS VARCHAR) + 
			' Missing PNL found for some deals for as of date: ' + dbo.FNADateFormat(@std_as_of_date) + '. Value of 0 is used to continue.' 
		     ELSE
			' ERROR(S): ' + CAST(@error_count AS VARCHAR) + 

			' Missing PNL found.' 
		     END
		+ '</a>'
	INSERT INTO measurement_process_status
	SELECT CASE WHEN (@continue_pnl = 1) THEN 'Warning' ELSE 'Error' END as status_code, 
		@url_desc as status_description, @as_of_date as run_as_of_date,
		'' as assessment_values, @assessment_date, @sub_entity_id, @strategy_entity_id, @book_entity_id,
		CASE WHEN (@continue_pnl = 1) THEN 'y' ELSE 'n' END as can_proceed, 
		@process_id, @dedesignation_calc as calc_type, NULL as create_user, NULL as create_ts

END	


IF @print_diagnostic = 1
	EXEC spa_print 'END of diagnostic for msmt_excp_pnl'
*/
--delete from measurement_process_status

/*
--8. eff_und_pnl and eff_pnl_as_of_date vs link_effective_date
SET @diagnostic_sql = 'INSERT INTO msmt_excp_eff_pnl' + 
		' SELECT DISTINCT MAX(''' + @process_id + ''') process_id, MAX(''' + @dedesignation_calc +  ''') calc_type, as_of_date, ' + 
		' fas_subsidiary_id, fas_strategy_id, fas_book_id, 
			deal_id, term_start, 
			link_effective_date, 
			MAX(eff_pnl_as_of_date) eff_pnl_as_of_date, SUM(ISNULL(eff_und_pnl, 0)) pnl_used ' + ', MAX(''' + CONVERT(VARCHAR , getdate(), 21) + '''), MAX(''' + @user_login_id + ''')' + 
		      ' FROM ' + @DealProcessTableName + ' cdeals ' +
		'	LEFT OUTER JOIN
			(SELECT DISTINCT source_deal_header_id ' + 
					      ' FROM ' + @DealProcessTableName + 		
						' WHERE eff_pnl_as_of_date = link_effective_date) edeals ON 
			cdeals.source_deal_header_id = edeals.source_deal_header_id
		' + 
		
		' WHERE   (eff_pnl_as_of_date <> deal_date) AND (eff_pnl_as_of_date <> link_effective_date OR
		        eff_pnl_as_of_date IS NULL) AND
			edeals.source_deal_header_id IS NULL
		  GROUP BY as_of_date, fas_subsidiary_id, fas_strategy_id, fas_book_id, deal_id, term_start, link_effective_date'
		
EXEC(@diagnostic_sql)
*/
--print @diagnostic_sql

/*
SELECT @error_count = COUNT(*) from msmt_excp_eff_pnl 
WHERE process_id = @process_id and calc_type = @dedesignation_calc
IF @error_count > 0 AND @continue_eff_pnl NOT IN (2, 4, 6)
BEGIN 
	SET @url = './spa_html.php?__user_name__=' + @user_name + 
	'&spa=EXEC spa_msmt_excp_eff_pnl ''' + @process_id + ''''
	 
	SET @url_desc = '<a target="_blank" href="' + @url + '">' + 
		CASE WHEN(@dedesignation_calc = 'd') THEN 'De-designation' ELSE 'Measurment' END + 
		CASE WHEN(@continue_eff_pnl IN (1, 3, 5)) THEN
			' WARNING(S): ' + CAST(@error_count AS VARCHAR) + 
			' Missing PNL found as of relationship effective date. ' + 
			CASE WHEN(@continue_eff_pnl = 1) THEN
				'PNL value as of effective date is used or 0 if no PNL found.' 
			WHEN (@continue_eff_pnl = 3) THEN
				'Proxy PNL value of the closest prior available date is used or 0 if no PNL found.'
			WHEN (@continue_eff_pnl = 5) THEN
				'Proxy PNL value of the closest next available date is used or 0 if no PNL found.'
			END
		ELSE
			' ERROR(S): ' + CAST(@error_count AS VARCHAR) + 
			' Missing PNL found as of relationship effective date.' 
		END
		+ '</a>'
	INSERT INTO measurement_process_status
	SELECT 	CASE WHEN(@continue_eff_pnl = 0) THEN 'Error' ELSE 'Warning' END as status_code, 
		@url_desc as status_description, @as_of_date as run_as_of_date,
		'' as assessment_values, @assessment_date, @sub_entity_id, @strategy_entity_id, @book_entity_id,
		CASE WHEN(@continue_eff_pnl = 0) THEN 'n' ELSE 'y' END as can_proceed, 
		@process_id, @dedesignation_calc as calc_type, NULL as create_user, NULL as create_ts
END	

IF @print_diagnostic = 1
	EXEC spa_print 'END of diagnostic for msmt_excp_eff_pnl'
*/

--3. test_range_from, test_range_to for on_eff_test_approach_value_id and for included additional_test_range_from and additional_test_range_to
SET @diagnostic_sql = 'INSERT INTO msmt_excp_test_range(process_id,calc_type,fas_subsidiary_id,fas_strategy_id,fas_book_id,missing_test_range_from,missing_test_range_to,missing_add_test_range_from,missing_add_test_range_to,missing_add_test_range_from2,missing_add_test_range_to2,as_of_date,create_ts,create_user)' + 
		' SELECT DISTINCT ''' + @process_id + ''' process_id, ''' + @dedesignation_calc +  ''' calc_type, ' + 
		' * ' + ', ''' + CONVERT(VARCHAR , getdate(), 21) + ''', ''' + @user_login_id + '''' +   ' FROM (
		SELECT  DISTINCT fas_subsidiary_id, fas_strategy_id, fas_book_id, 
			CASE WHEN(test_range_from IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingTestRangeFrom, 
			CASE WHEN(test_range_to IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingTestRangeTo, 
			CASE WHEN(on_eff_test_approach_value_id BETWEEN 307 AND 314 AND additional_test_range_from IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingAddTestRangeFrom, 
			''No'' as MissingAddTestRangeTo, 
			CASE WHEN(on_eff_test_approach_value_id BETWEEN 311 AND 314 AND additional_test_range_from2 IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingAddTestRangeFrom2, 
			CASE WHEN(on_eff_test_approach_value_id BETWEEN 311 AND 314 AND additional_test_range_to2 IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingAddTestRangeTo2, ' + 
			' as_of_date ' + 
		      ' FROM ' + @DealProcessTableName + 		
		' WHERE (perfect_hedge <> ''y'' AND on_eff_test_approach_value_id IS NULL AND link_type_value_id = 450) AND on_eff_test_approach_value_id IS NOT NULL
		) miss_test_ranges 
		WHERE   miss_test_ranges.MissingTestRangeFrom = ''Yes'' OR 
			miss_test_ranges.MissingTestRangeTo = ''Yes'' OR
			miss_test_ranges.MissingAddTestRangeFrom = ''Yes'' OR
			miss_test_ranges.MissingAddTestRangeTo = ''Yes'' OR
			miss_test_ranges.MissingAddTestRangeFrom2 = ''Yes'' OR
			miss_test_ranges.MissingAddTestRangeTo2 = ''Yes'''


EXEC(@diagnostic_sql)

SELECT @error_count = COUNT(*) from msmt_excp_test_range 
WHERE process_id = @process_id and calc_type = @dedesignation_calc
IF @error_count > 0
BEGIN 
	SET @url = './spa_html.php?__user_name__=' + @user_name + 
	'&spa=EXEC spa_msmt_excp_test_range ''' + @process_id + ''''
	 
	SET @url_desc = '<a target="_blank" href="' + @url + '">' + 
		CASE WHEN(@dedesignation_calc = 'd') THEN 'De-designation' ELSE 'Measurment' END + 
		' ERROR(S): ' + CAST(@error_count AS VARCHAR) + 
		' Missing test range definitions found. Please proceed to respective Strategy property set up to define test ranges.' + 
		'</a>'
	INSERT INTO measurement_process_status
	SELECT 'Error' as status_code, @url_desc as status_description, @as_of_date as run_as_of_date,
	'' as assessment_values, @assessment_date, @sub_entity_id, @strategy_entity_id, @book_entity_id,
	'n' as can_proceed, @process_id, @dedesignation_calc as calc_type, NULL as create_user, NULL as create_ts
END	

--print @diagnostic_sql
--If roll forward match failed THEN item match term month for hedge will be null
SET @diagnostic_sql =
'INSERT INTO measurement_process_status
SELECT 	''Error'' as status_code, 
	''Could not resolve hedged item term for the hedge for relationship ID '' + dbo.FNAHyperLinkText(61,CAST(link_id AS VARCHAR), CAST(link_id AS VARCHAR)) + ''-'' + link_type  as status_description, 
	MAX(as_of_date) as run_as_of_date,
	'''' as assessment_values, 
	NULL assessment_date, 
	MAX(fas_subsidiary_id) sub_entity_id, 
	MAX(fas_strategy_id) strategy_entity_id, 
	MAX(fas_book_id) book_entity_id,
	''n'' as can_proceed, ''' + 
	@process_id + ''', ''' +  
	@dedesignation_calc + ''', 
	NULL as create_user, NULL as create_ts
from ' +  @DealProcessTableName + '
WHERE item_match_term_month IS NULL
GROUP BY link_id, link_type'
--print @diagnostic_sql
EXEC(@diagnostic_sql)

--For lagging specific release of aoci if lagging info not found in hedging relationship type give error
SET @diagnostic_sql =
'INSERT INTO measurement_process_status
SELECT 	''Error'' as status_code, 
	''Could not find lagging characterstics for hedge relationship ID: '' + dbo.FNAHyperLinkText(61,CAST(cd.link_id AS VARCHAR), CAST(cd.link_id AS VARCHAR)) +
	''  for hedging relationship type ID: '' + dbo.FNAHyperLinkText(50,CAST(cd.use_eff_test_profile_id AS VARCHAR), CAST(cd.use_eff_test_profile_id AS VARCHAR)) + 
	''. Either change the roll out approach or define lagging characterstics. ''  as status_description, 
	MAX(cd.as_of_date) as run_as_of_date,
	'''' as assessment_values, 
	NULL assessment_date, 
	MAX(cd.fas_subsidiary_id) sub_entity_id, 
	MAX(cd.fas_strategy_id) strategy_entity_id, 
	MAX(cd.fas_book_id) book_entity_id,
	''n'' as can_proceed, ''' + 
	@process_id + ''', ''' +  
	@dedesignation_calc + ''', 
	NULL as create_user, NULL as create_ts
FROM (SELECT link_id, use_eff_test_profile_id, as_of_date, MAX(fas_subsidiary_id) fas_subsidiary_id, MAX(fas_strategy_id) fas_strategy_id,
		MAX(fas_book_id) fas_book_id, MAX(rollout_per_type) rollout_per_type, MAX(mismatch_tenor_value_id) mismatch_tenor_value_id from ' +  
	@DealProcessTableName + ' GROUP BY link_id, use_eff_test_profile_id, as_of_date) cd
INNER JOIN (SELECT link_id, as_of_date from ' + @AOCIReleaseSchedule + ' WHERE strip_months IS NULL OR lagging_months IS NULL OR strip_item_months IS NULL
		GROUP BY link_id, as_of_date) ar ON ar.link_id = cd.link_id AND ar.as_of_date = cd.as_of_date
WHERE cd.mismatch_tenor_value_id <> 250 AND  cd.rollout_per_type BETWEEN 522 and 523
GROUP BY cd.link_id, cd.use_eff_test_profile_id'
--print @diagnostic_sql aocirelease_schedule_farrms_admin_123456

EXEC(@diagnostic_sql)

IF @print_diagnostic = 1
	PRINT 'END of diagnostic for msmt_excp_test_range'

-- --4. no_links_fas_eff_test_profile_id
SET @diagnostic_sql = 'INSERT INTO msmt_excp_nolinks_profile (process_id,calc_type,as_of_date,fas_subsidiary_id,fas_strategy_id,fas_book_id,create_ts,create_user)' + 
		' SELECT DISTINCT ''' + @process_id + ''' process_id, ''' + @dedesignation_calc +  ''' calc_type, as_of_date, ' + 
		' fas_subsidiary_id, fas_strategy_id, fas_book_id ' + ', ''' + CONVERT(VARCHAR , getdate(), 21) + ''', ''' + @user_login_id + '''' +
		' FROM ' + @DealProcessTableName + 		
		' WHERE  --(use_eff_test_profile_id IS NULL AND no_link = ''y'') OR  
				use_eff_test_profile_id IS NULL
				AND (link_type = ''link'')						
		'
EXEC(@diagnostic_sql)

--print @diagnostic_sql 
--EXEC('SELECT * from ' + @DealProcessTableName) 
IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************aaEnd of diagnostic for msmt_excp_test_range*****************************'	
END

SELECT @error_count = COUNT(*) FROM msmt_excp_nolinks_profile 
WHERE process_id = @process_id AND calc_type = @dedesignation_calc
IF @error_count > 0
BEGIN 
	SET @url = './spa_html.php?__user_name__=' + @user_name + 
	'&spa=EXEC spa_msmt_excp_nolinks_profile ''' + @process_id + ''''

	SET @url_desc = '<a target="_blank" href="' + @url + '">' + 
		CASE WHEN(@dedesignation_calc = 'd') THEN 'De-designation' ELSE 'Measurment' END + 
		' ERROR(S): ' + CAST(@error_count AS VARCHAR) + 
		' Missing test relationship(s) definitions found for no link Strategy/Book setup. Please proceed to respective Strategy/Book property set up to define test relationship.' + 
		'</a>'
	INSERT INTO measurement_process_status
	SELECT 'Error' as status_code, @url_desc as status_description, @as_of_date as run_as_of_date,
	'' as assessment_values, @assessment_date, @sub_entity_id, @strategy_entity_id, @book_entity_id,
	'n' as can_proceed, @process_id, @dedesignation_calc as calc_type, NULL as create_user, NULL as create_ts
END	

IF @print_diagnostic = 1
	PRINT 'END of diagnostic for msmt_excp_nolinks_profile'

--7. use_assessment_values and use_additional_assessment_Values (vs assessment_date for quarter analysis)
-- missing values, can not continue

-- EXEC('SELECT use_assessment_values, * from ' + @DealProcessTableName)

SET @diagnostic_sql = 'INSERT INTO msmt_excp_assmt_values (process_id,calc_type,fas_subsidiary_id,fas_strategy_id,fas_book_id,use_eff_test_profile_id,on_eff_test_approach_value_id,missing_assmt_value,missing_add_assmt_value,missing_add_assmt_value2,as_of_date,create_ts,create_user)' + 
		' SELECT DISTINCT ''' + @process_id + ''' process_id, ''' + @dedesignation_calc +  ''' calc_type,  ' + 
		' * ' + ', ''' + CONVERT(VARCHAR , getdate(), 21) + ''', ''' + @user_login_id + '''' +   ' FROM (
		SELECT  DISTINCT fas_subsidiary_id, fas_strategy_id, fas_book_id, 
			(CAST(link_id AS VARCHAR) + ''/'' + CAST(use_eff_test_profile_id AS VARCHAR)) use_eff_test_profile_id,
			on_eff_test_approach_value_id,
			CASE WHEN (on_eff_test_approach_value_id = 304 OR perfect_hedge = ''y'' OR on_eff_test_approach_value_id = 320) THEN ''No''
			     when (use_assessment_values IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingAssmtValue, 
			CASE WHEN(on_eff_test_approach_value_id BETWEEN 307 AND 316 AND use_additional_assessment_Values IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingAddAssmtValue, 
			CASE WHEN(on_eff_test_approach_value_id BETWEEN 311 AND 314 AND use_additional_assessment_Values2 IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingAddAssmtValue2, ' + 
		      	' as_of_date ' + 
			' FROM ' + @DealProcessTableName + 		
		' WHERE item_match_term_month > as_of_date AND 
			link_type <> ''deal'' AND hedge_type_value_id BETWEEN 150 AND 151 AND
			on_eff_test_approach_value_id <> 304 AND on_eff_test_approach_value_id <> 302 AND on_eff_test_approach_value_id <> 320
			AND perfect_hedge <> ''y'' AND link_type_value_id = 450 AND fully_dedesignated <> ''y'') miss_test_ranges 
		WHERE ISNULL(on_eff_test_approach_value_id,-1)<>320 AND (  miss_test_ranges.MissingAssmtValue = ''Yes'' OR 
			miss_test_ranges.MissingAddAssmtValue = ''Yes'' OR
			miss_test_ranges.MissingAddAssmtValue2 = ''Yes'')' 

--print @diagnostic_sql
EXEC(@diagnostic_sql)

--print @diagnostic_sql

SELECT @error_count = COUNT(*) from msmt_excp_assmt_values 
WHERE process_id = @process_id and calc_type = @dedesignation_calc
IF @error_count > 0
BEGIN 
	SET @url = './spa_html.php?__user_name__=' + @user_name + 
	'&spa=EXEC spa_msmt_excp_assmt_values ''' + @process_id + ''''
	 
	SET @url_desc = '<a target="_blank" href="' + @url + '">' + 
		CASE WHEN(@dedesignation_calc = 'd') THEN 'De-designation' ELSE 'Measurment' END + 
		' ERROR(S): ' + CAST(@error_count AS VARCHAR) + 
		' Missing assessment test values. Please proceed to assessment of effectiveness testing before continuing.' + 
		'</a>'
	INSERT INTO measurement_process_status

	SELECT 'Error' as status_code, @url_desc as status_description, @as_of_date as run_as_of_date,
	'' as assessment_values, @assessment_date, @sub_entity_id, @strategy_entity_id, @book_entity_id,
	'n' as can_proceed, @process_id, @dedesignation_calc as calc_type, NULL as create_user, NULL as create_ts
END	

IF @print_diagnostic = 1
	PRINT 'END of diagnostic for msmt_excp_assmt_values'

--- Test here for missing t or f distribution alpha value (the system does not have proper distribution)
CREATE TABLE #t_f_test_error
(
	fas_subsidiary_id INT, 
	fas_strategy_id INT, 
	fas_book_id INT, 
	use_eff_test_profile_id INT, 
	on_eff_test_approach_value_id INT ,
	MissingAssmtValue VARCHAR(5) COLLATE DATABASE_DEFAULT, 
	MissingAddAssmtValue VARCHAR(5) COLLATE DATABASE_DEFAULT,
	MissingAddAssmtValue2 VARCHAR(5) COLLATE DATABASE_DEFAULT,
	as_of_date DATETIME
)

SET @sqlSelect1 =
	' INSERT INTO  #t_f_test_error
	SELECT * from (
	SELECT fas_subsidiary_id, fas_strategy_id, fas_book_id, 
		use_eff_test_profile_id, 
		on_eff_test_approach_value_id,
		CASE WHEN(on_eff_test_approach_value_id = 305 AND td.t_value IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingAssmtValue, 
		CASE WHEN(on_eff_test_approach_value_id in (307, 309, 311, 313) and td.t_value  IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingAddAssmtValue,
		''No'' As MissingAddAssmtValue2,
		eff_test.as_of_date
	FROM (
	SELECT  DISTINCT fas_subsidiary_id, fas_strategy_id, fas_book_id, 
		use_eff_test_profile_id, 
		on_eff_test_approach_value_id,
		use_assessment_values,
		ddf, 
		case 	when (on_eff_test_approach_value_id = 305) THEN test_range_from/2
			ELSE   additional_test_range_from/2
		END alpha,
		as_of_date
	      FROM  ' + @DealProcessTableName + '
	) eff_test LEFT OUTER JOIN
	t_distribution td ON td.df = ddf AND td.alpha = eff_test.alpha) xx 
	WHERE 	MissingAssmtValue = ''Yes'' OR 
		MissingAddAssmtValue = ''Yes''		 
	UNION
	SELECT * from (
	SELECT fas_subsidiary_id, fas_strategy_id, fas_book_id, 
		use_eff_test_profile_id, 
		on_eff_test_approach_value_id,
		CASE WHEN(on_eff_test_approach_value_id = 306 AND fd.f_value IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingAssmtValue, 
		CASE WHEN(on_eff_test_approach_value_id in (308, 310, 312, 314) AND fd.f_value  IS NULL) THEN ''Yes'' ELSE ''No'' END as MissingAddAssmtValue,
		''No'' As MissingAddAssmtValue2,
		eff_test.as_of_date
	FROM (
	SELECT  DISTINCT fas_subsidiary_id, fas_strategy_id, fas_book_id, 
		use_eff_test_profile_id, 
		on_eff_test_approach_value_id,
		use_assessment_values,
		ddf, 
		case 	when (on_eff_test_approach_value_id = 306) THEN test_range_from
			ELSE   additional_test_range_from
		END alpha,
		as_of_date
	      FROM ' + @DealProcessTableName + '
	WHERE on_eff_test_approach_value_id in (306, 308, 310)
	) eff_test LEFT OUTER JOIN
	f_distribution fd ON fd.ndf = 1 AND fd.ddf = eff_test.ddf AND fd.alpha = eff_test.alpha) xx 
	WHERE 	MissingAssmtValue = ''Yes'' OR 
		MissingAddAssmtValue = ''Yes'' 
	'

--This logic is not working for book level measurement 
----EXEC(@sqlSelect1)

SELECT @error_count = COUNT(*) from #t_f_test_error 
IF @error_count > 0
BEGIN 
	SET @diagnostic_sql = 'INSERT INTO msmt_excp_assmt_values (process_id,calc_type,fas_subsidiary_id,fas_strategy_id,fas_book_id,use_eff_test_profile_id,on_eff_test_approach_value_id,missing_assmt_value,missing_add_assmt_value,missing_add_assmt_value2,as_of_date,create_ts,create_user)' + 
			' SELECT DISTINCT ''' + @process_id + ''' process_id, ''' + @dedesignation_calc +  ''' calc_type,  ' + 
			' * ' + ', ''' + CONVERT(VARCHAR , getdate(), 21) + ''', ''' + @user_login_id + '''' +   ' FROM (
			SELECT  * from #t_f_test_error) miss_test_ranges' 
	
	EXEC(@diagnostic_sql)


	SET @url = './spa_html.php?__user_name__=' + @user_name + 
	'&spa=EXEC spa_msmt_excp_assmt_values ''' + @process_id + ''''
	 
	SET @url_desc = '<a target="_blank" href="' + @url + '">' + 
		CASE WHEN(@dedesignation_calc = 'd') THEN 'De-designation' ELSE 'Measurment' END + 
		' ERROR(S): ' + CAST(@error_count AS VARCHAR) + 
		' Missing assessment T-test/F-test test values due to missing distribution. Please contact technical support.' + 
		'</a>'
	INSERT INTO measurement_process_status
	SELECT 'Error' as status_code, @url_desc as status_description, @as_of_date as run_as_of_date,
	'' as assessment_values, @assessment_date, @sub_entity_id, @strategy_entity_id, @book_entity_id,
	'n' as can_proceed, @process_id, @dedesignation_calc as calc_type, NULL as create_user, NULL as create_ts
END	

IF @print_diagnostic = 1
	PRINT 'END of diagnostic for msmt_excp_assmt_values'

IF @print_diagnostic = 1
	PRINT 'END of diagnostic for msmt_excp_assmt_values_offset'

-- assessment beyond a quarter proceed with warning
SET @diagnostic_sql = 'INSERT INTO msmt_excp_assmt_values_quarter(process_id,calc_type,fas_subsidiary_id,fas_strategy_id,fas_book_id,link_id,use_assessment_values,use_additional_assessment_values,assessment_date,assmt_beyond_quarter,as_of_date,create_ts,create_user)' + 
					' SELECT DISTINCT ''' + @process_id + ''' process_id, ''' + @dedesignation_calc +  ''' calc_type, ' + 
					' * ' + ', ''' + CONVERT(VARCHAR , GETDATE(), 21) + ''', ''' + @user_login_id + '''' + ' FROM (
					SELECT  DISTINCT fas_subsidiary_id, fas_strategy_id, fas_book_id, 
						link_id,
						use_assessment_values, 
						use_additional_assessment_values, 
						assessment_date,
						CASE WHEN(DATEDIFF(month, assessment_date, as_of_date) < 3 ) THEN ''No'' ELSE ''Yes'' END AS AssessmentBeyondQuarter, ' + 
		      				' as_of_date ' + 
						' FROM ' + @DealProcessTableName + 		
					'  WHERE on_eff_test_approach_value_id IS NOT NULL AND
								item_match_term_month > as_of_date AND link_type_value_id = 450 AND fully_dedesignated <> ''y'') miss_test_ranges 
					WHERE   miss_test_ranges.AssessmentBeyondQuarter = ''Yes'''

EXEC(@diagnostic_sql)

--print @diagnostic_sql

SELECT @error_count = COUNT(1) FROM msmt_excp_assmt_values_quarter 
WHERE process_id = @process_id AND calc_type = @dedesignation_calc
IF @error_count > 0 AND @continue_assmt_value_quarter <> 2
BEGIN 
	SET @url = './spa_html.php?__user_name__=' + @user_name + '&spa=EXEC spa_msmt_excp_assmt_values_quarter ''' + @process_id + ''''
	 
	SET @url_desc = '<a target="_blank" href="' + @url + '">' + 
		CASE WHEN(@dedesignation_calc = 'd') THEN 'De-designation' ELSE 'Measurment' END + 
		CASE WHEN(@continue_assmt_value_quarter = 1) THEN
			' WARNINGS(S): ' + CAST(@error_count AS VARCHAR) + 
			' Assessment values were run beyond a quarter period. Please proceed to assessment of effectiveness testing in order to run current assessment.' 
		ELSE
			' ERROR(S): ' + CAST(@error_count AS VARCHAR) + 
			' Assessment values were run beyond a quarter period. Please proceed to assessment of effectiveness testing in order to run current assessment.' 
		END
		+ '</a>'

	INSERT INTO measurement_process_status
	SELECT 	CASE WHEN(@continue_assmt_value_quarter = 1) THEN 'Warning' ELSE 'Error' END AS status_code, 
		@url_desc as status_description, @as_of_date as run_as_of_date,
		'' as assessment_values, @assessment_date, @sub_entity_id, @strategy_entity_id, @book_entity_id,
		CASE WHEN(@continue_assmt_value_quarter = 1) THEN 'y' ELSE 'n' END as can_proceed, 
		@process_id, @dedesignation_calc as calc_type, NULL as create_user, NULL as create_ts
END	

IF @print_diagnostic = 1
	PRINT 'END of diagnostic for msmt_assmt_values_quarter'

--9. pnl_cur_coversion_factor, ded_pnl_cur_conversion_factor, eff_pnl_cur_conversion_factor

/*
SET @diagnostic_sql = 'INSERT INTO msmt_excp_conv_factor' + 
		' SELECT * FROM  (SELECT DISTINCT ''' + @process_id + ''' process_id, ''' + @dedesignation_calc +  ''' calc_type, as_of_date, ' + 
		' fas_subsidiary_id, fas_strategy_id, fas_book_id,  
		term_start, func_cur_value_id , pnl_currency_id ,
		eff_pnl_currency_id , dedesignation_pnl_currency_id , 
		CASE WHEN(func_cur_value_id <> pnl_currency_id AND pnl_cur_coversion_factor IS NULL) THEN ''Yes'' ELSE ''No'' END MissingPNLConvFactor,
	        CASE WHEN(func_cur_value_id <> eff_pnl_currency_id AND eff_pnl_currency_id IS NOT NULL and eff_pnl_cur_conversion_factor IS NULL) THEN ''Yes'' ELSE ''No'' END MissingEffPNLConvFactor, 
	        CASE WHEN(func_cur_value_id <> dedesignation_pnl_currency_id AND dedesignation_pnl_currency_id IS NOT NULL and ded_pnl_cur_conversion_factor IS NULL) THEN ''Yes'' ELSE ''No'' END MissingDeDesPNLConvFactor ' +
		', ''' + CONVERT(VARCHAR , getdate(), 21) + ''' as create_ts, ''' + @user_login_id + ''' as create_user' +
		      ' FROM ' + @DealProcessTableName + 		
		' ) missing_fx_factor
		WHERE missing_fx_factor.MissingPNLConvFactor = ''Yes'' OR missing_fx_factor.MissingEffPNLConvFactor = ''Yes'' OR missing_fx_factor.MissingDeDesPNLConvFactor = ''Yes'''

--print @diagnostic_sql
EXEC(@diagnostic_sql)
*/
--print @diagnostic_sql

/*
SELECT @error_count = COUNT(*) from msmt_excp_conv_factor 
WHERE process_id = @process_id and calc_type = @dedesignation_calc
IF @error_count > 0 AND @continue_conv_factor <> 2
BEGIN 
	SET @url = './spa_html.php?__user_name__=' + @user_name + 
	'&spa=EXEC spa_msmt_excp_conv_factor ''' + @process_id + ''''
	 
	SET @url_desc = '<a target="_blank" href="' + @url + '">' + 
		CASE WHEN(@dedesignation_calc = 'd') THEN 'De-designation' ELSE 'Measurment' END + 
		CASE WHEN(@continue_conv_factor = 1) THEN
			' WARNING(S): ' + CAST(@error_count AS VARCHAR) + 
			' Missing FX conversion factors due to missing FX curves. Value of 1 is used if continued.'
		ELSE
			' ERROR(S): ' + CAST(@error_count AS VARCHAR) + 
			' Missing FX conversion factors due to missing FX curves.'
		END
		+ '</a>'
	INSERT INTO measurement_process_status
	SELECT	CASE WHEN(@continue_conv_factor = 1) THEN 'Warning' ELSE 'Error' END as status_code, 
		@url_desc as status_description, @as_of_date as run_as_of_date,
		'' as assessment_values, @assessment_date, @sub_entity_id, @strategy_entity_id, @book_entity_id,
		CASE WHEN(@continue_conv_factor = 1) THEN 'y' ELSE 'n' END as can_proceed, 
		@process_id, @dedesignation_calc as calc_type, NULL as create_user, NULL as create_ts
END	

IF @print_diagnostic = 1
	PRINT 'END of diagnostic for msmt_excp_conv_factor'
*/
----- END OF DIAGNOSTIC LOGIC  --------------------
----------------------------------------------------------------------------
IF @print_diagnostic = 1
BEGIN
	PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
	PRINT '****************END of checking diagnostics *****************************'	
END

-----------------CALCULATE DELTA PNL AND LOAD IN CALCPROCESS TABLE --------------

--Find out no errors found to proceed on
--delete from measurement_process_status

--If (SELECT COUNT(*) FROM measurement_process_status
--		WHERE (process_id = @process_id and calc_type = 'm' and can_proceed = 'n')) = 0
--BEGIN

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time = GETDATE()
		PRINT @pr_name + ' Running..............'
	END

	CREATE TABLE [dbo].[#d_cpr](
		[source_deal_header_id] [INT] NOT NULL,
		[as_of_date] [DATETIME] NOT NULL,
		[term_start] [DATETIME] NOT NULL,
		[term_end] [DATETIME] NOT NULL,
		[deal_date] [DATETIME] NULL,
		[deal_type] [INT] NULL,
		[deal_sub_type] [INT] NULL,
		[source_counterparty_id] [INT] NULL,
		[physical_financial_flag] [CHAR](1) COLLATE DATABASE_DEFAULT NULL ,
		[Leg] [INT] NOT NULL,
		[contract_expiration_date] [DATETIME] NULL,
		[fixed_float_leg] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
		[buy_sell_flag] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
		[curve_id] [INT] NULL,
		[fixed_price] [FLOAT] NULL,
		[fixed_price_currency_id] [INT] NULL,
		[option_strike_price] [FLOAT] NULL,
		[deal_volume] [FLOAT] NULL,
		[deal_volume_frequency] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
		[deal_volume_uom_id] [INT] NULL,
		[block_description] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
		[deal_detail_description] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
		[percentage_included] [FLOAT] NULL,
		[link_effective_date] [DATETIME] NULL,
		[dedesignation_link_id] [INT] NULL,
		[discount_factor] [FLOAT] NULL,
		[func_cur_value_id] [INT] NULL,
		[und_pnl] [FLOAT] NULL,
		[und_intrinsic_pnl] [INT] NULL,
		[und_extrinsic_pnl] [INT] NULL,
		[pnl_currency_id] [INT] NULL,
		[pnl_conversion_factor] [FLOAT] NULL,
		[pnl_source_value_id] [INT] NULL,
		[eff_test_profile_id] [INT] NULL,
		[link_type_value_id] [INT] NULL,
		[dedesignated_link_id] [INT] NULL,
		[mes_gran_value_id] [INT] NULL,
		[mes_cfv_value_id] [INT] NULL,
		[gl_grouping_value_id] [INT] NULL,
		[mismatch_tenor_value_id] [INT] NULL,
		[strip_trans_value_id] [INT] NULL,
		[asset_liab_calc_value_id] [INT] NULL,
		[test_range_from] [FLOAT] NULL,
		[test_range_to] [FLOAT] NULL,
		[additional_test_range_from] [FLOAT] NULL,
		[additional_test_range_to] [FLOAT] NULL,
		[additional_test_range_from2] [FLOAT] NULL,
		[additional_test_range_to2] [FLOAT] NULL,
		[include_unlinked_hedges] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
		[include_unlinked_items] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
		[no_link] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
		[use_eff_test_profile_id] [INT] NULL,
		[on_eff_test_approach_value_id] [INT] NULL,
		[no_links_fas_eff_test_profile_id] [INT] NULL,
		[dedesignation_pnl_currency_id] [INT] NULL,
		[pnl_ineffectiveness_value] [FLOAT] NULL,
		[pnl_dedesignation_value] [FLOAT] NULL,
		[locked_aoci_value] [FLOAT] NULL,
		[pnl_cur_coversion_factor] [INT] NULL,
		[ded_pnl_cur_conversion_factor] [INT] NULL,
		[eff_pnl_cur_conversion_factor] [INT] NULL,
		[assessment_values] [FLOAT] NULL,
		[additional_assessment_values] [FLOAT] NULL,
		[additional_assessment_values2] [FLOAT] NULL,
		[use_assessment_values] [FLOAT] NULL,
		[use_additional_assessment_values] [FLOAT] NULL,
		[use_additional_assessment_values2] [FLOAT] NULL,
		[assessment_date] [DATETIME] NULL,
		[ddf] [INT] NULL,
		[alpha] [VARCHAR](30) COLLATE DATABASE_DEFAULT NULL,
		[eff_und_pnl] [FLOAT] NULL,
		[eff_und_intrinsic_pnl] [FLOAT] NULL,
		[eff_und_extrinsic_pnl] [FLOAT] NULL,
		[eff_pnl_source_value_id] [INT] NULL,
		[eff_pnl_currency_id] [INT] NULL,
		[eff_pnl_conversion_factor] [FLOAT] NULL,
		[eff_pnl_as_of_date] [DATETIME] NULL,
		[pnl_as_of_date] [DATETIME] NULL,
		[dedesignation_date] [DATETIME] NULL,
		[deal_id] [VARCHAR](5000) COLLATE DATABASE_DEFAULT NULL,
		[option_flag] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
		[final_und_pnl_remaining] [FLOAT] NULL,
		[final_dis_instrinsic_pnl] [FLOAT] NULL,
		[final_dis_extrinsic_pnl] [FLOAT] NULL,
		[final_dis_pnl_remaining] [FLOAT] NULL,
		[final_und_instrinsic_pnl] [FLOAT] NULL,
		[final_und_extrinsic_pnl] [FLOAT] NULL,
		[item_match_term_month] [DATETIME] NULL,
		[item_term_month] [DATETIME] NULL,
		[long_term_months] [INT] NULL,
		[source_system_id] [INT] NULL,
		[hedge_term_month] [DATETIME] NULL,
		[eff_test_result_id] [INT] NULL,
		[options_premium_approach] [INT] NULL,
		[options_amortization_factor] [FLOAT] NULL,
		[fas_deal_type_value_id] [INT] NULL,
		[fas_deal_sub_type_value_id] [INT] NULL,
		[mstm_eff_test_type_id] [INT] NULL,
		[hedge_type_value_id] [INT] NULL,
		[hedge_or_item] [VARCHAR](1) COLLATE DATABASE_DEFAULT NULL,
		[no_links] [CHAR](1) COLLATE DATABASE_DEFAULT NULL,
		[fas_book_id] [INT] NULL,
		[dis_pnl] FLOAT NULL
	)

	EXEC('INSERT INTO #d_cpr 
		SELECT	cpr.source_deal_header_id, cpr.as_of_date, cpr.term_start, cpr.term_end, 
						MAX(cpr.deal_date) deal_date, MAX(cpr.deal_type) deal_type, MAX(deal_sub_type) deal_sub_type, 
						MAX(source_counterparty_id) source_counterparty_id, MAX(cpr.physical_financial_flag) physical_financial_flag, 
						1 Leg, MAX(contract_expiration_date) contract_expiration_date, MAX(fixed_float_leg) fixed_float_leg, 
						MAX(buy_sell_flag) buy_sell_flag, MAX(curve_id) curve_id, 
						MAX(fixed_price) fixed_price, MAX(fixed_price_currency_id) fixed_price_currency_id, MAX(option_strike_price) option_strike_price, 
						MAX(deal_volume) deal_volume, MAX(deal_volume_frequency) deal_volume_frequency, MAX(deal_volume_uom_id) deal_volume_uom_id, 
						MAX(block_description) block_description, MAX(deal_detail_description) deal_detail_description, 
						SUM(percentage_included) percentage_included, MAX(link_effective_date) link_effective_date, 
						MAX(dedesignation_link_id) dedesignation_link_id, MAX(discount_factor) discount_factor, MAX(func_cur_value_id) func_cur_value_id, 
						MAX(und_pnl) und_pnl, 0 und_intrinsic_pnl, 0 und_extrinsic_pnl, MAX(pnl_currency_id) pnl_currency_id, MAX(pnl_conversion_factor) pnl_conversion_factor, 
						MAX(pnl_source_value_id) pnl_source_value_id, MAX(eff_test_profile_id) eff_test_profile_id, MAX(link_type_value_id) link_type_value_id, 
						MAX(dedesignated_link_id) dedesignated_link_id, MAX(mes_gran_value_id) mes_gran_value_id, MAX(mes_cfv_value_id) mes_cfv_value_id, 
						MAX(gl_grouping_value_id) gl_grouping_value_id, MAX(mismatch_tenor_value_id) mismatch_tenor_value_id, 
						MAX(strip_trans_value_id) strip_trans_value_id, MAX(asset_liab_calc_value_id) asset_liab_calc_value_id, 
						MAX(test_range_from) test_range_from, MAX(test_range_to) test_range_to, MAX(additional_test_range_from) additional_test_range_from, 
						MAX(additional_test_range_to) additional_test_range_to, MAX(additional_test_range_from2) additional_test_range_from2, 
						MAX(additional_test_range_to2) additional_test_range_to2, MAX(include_unlinked_hedges) include_unlinked_hedges, 
						MAX(include_unlinked_items) include_unlinked_items, MAX(no_link) no_link, MAX(use_eff_test_profile_id) use_eff_test_profile_id, 
						MAX(on_eff_test_approach_value_id) on_eff_test_approach_value_id, MAX(no_links_fas_eff_test_profile_id) no_links_fas_eff_test_profile_id, 
						MAX(dedesignation_pnl_currency_id) dedesignation_pnl_currency_id, MAX(pnl_ineffectiveness_value) pnl_ineffectiveness_value, 
						MAX(pnl_dedesignation_value) pnl_dedesignation_value, MAX(locked_aoci_value) locked_aoci_value, 
						MAX(pnl_cur_coversion_factor) pnl_cur_coversion_factor, MAX(ded_pnl_cur_conversion_factor) ded_pnl_cur_conversion_factor, 
						MAX(eff_pnl_cur_conversion_factor) eff_pnl_cur_conversion_factor, MAX(assessment_values) assessment_values, 
						MAX(additional_assessment_values) additional_assessment_values, MAX(additional_assessment_values2) additional_assessment_values2, 
						MAX(use_assessment_values) use_assessment_values, MAX(use_additional_assessment_values) use_additional_assessment_values, 
						MAX(use_additional_assessment_values2) use_additional_assessment_values2, MAX(assessment_date) assessment_date, MAX(ddf) ddf, 
						MAX(alpha) alpha, MAX(eff_und_pnl) eff_und_pnl, MAX(eff_und_intrinsic_pnl) eff_und_intrinsic_pnl, 
						MAX(eff_und_extrinsic_pnl) eff_und_extrinsic_pnl, MAX(eff_pnl_source_value_id) eff_pnl_source_value_id, 
						MAX(eff_pnl_currency_id) eff_pnl_currency_id, MAX(eff_pnl_conversion_factor) eff_pnl_conversion_factor, 	
						MAX(eff_pnl_as_of_date) eff_pnl_as_of_date, MAX(pnl_as_of_date) pnl_as_of_date, 
						MAX(dedesignation_date) dedesignation_date, MAX(cpr.deal_id) deal_id, MAX(cpr.option_flag) option_flag, 
						SUM(ISNULL(cpr.final_und_pnl_remaining, 0))  final_und_pnl_remaining, 
						MAX(final_dis_instrinsic_pnl) final_dis_instrinsic_pnl, MAX(final_dis_extrinsic_pnl) final_dis_extrinsic_pnl, 
						SUM(ISNULL(cpr.final_dis_pnl_remaining, 0)) final_dis_pnl_remaining, 
						MAX(final_und_instrinsic_pnl) final_und_instrinsic_pnl, MAX(final_und_extrinsic_pnl) final_und_extrinsic_pnl, 
						MAX(item_match_term_month) item_match_term_month,  MAX(item_term_month) item_term_month, MAX(long_term_months) long_term_months, 
						MAX(cpr.source_system_id) source_system_id, MAX(hedge_term_month) hedge_term_month, MAX(eff_test_result_id) eff_test_result_id, 
						MAX(options_premium_approach) options_premium_approach, MAX(options_amortization_factor) options_amortization_factor, 
						MAX(cpr.fas_deal_type_value_id) fas_deal_type_value_id, MAX(cpr.fas_deal_sub_type_value_id) fas_deal_sub_type_value_id, 
						MAX(mstm_eff_test_type_id) mstm_eff_test_type_id, MAX(hedge_type_value_id) hedge_type_value_id, MAX(hedge_or_item) hedge_or_item,
						MAX(no_links) no_links,
						MAX(d.default_book_id) fas_book_id, MAX(dis_pnl) dis_pnl
			FROM ' + @DealProcessTableName + ' cpr 
				INNER JOIN ' + @deal + ' d ON cpr.source_deal_header_id = d.source_deal_header_id
			WHERE cpr.hedge_type_value_id IN(150,151,152) AND cpr.hedge_or_item = ''h''
			GROUP BY cpr.source_deal_header_id, cpr.as_of_date, cpr.term_start, cpr.term_end')

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************END of Creating Delta PNL: populating  #d_cpr *****************************'	
	END

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time = GETDATE()
		PRINT @pr_name + ' Running..............'
	END

	CREATE TABLE [dbo].[#d_max_pnl](
		[source_deal_header_id] [INT] NOT NULL,
		[term_start] [DATETIME] NOT NULL,
		[as_of_date] [DATETIME] NOT NULL,
		[max_final_und_pnl] [FLOAT] NULL,
		[max_final_dis_pnl] [FLOAT] NULL,
		[tax_perc] [FLOAT] NULL
	) 

	EXEC('INSERT INTO #d_max_pnl
		SELECT source_deal_header_id, term_start, as_of_date, MAX(final_und_pnl) max_final_und_pnl, MAX(final_dis_pnl) max_final_dis_pnl, MAX(tax_perc) tax_perc 
		FROM (
				SELECT link_id, source_deal_header_id, term_start, as_of_date, 
				--SUM(final_und_pnl) final_und_pnl, SUM(final_dis_pnl) final_dis_pnl, 
				--MAX(final_und_pnl) final_und_pnl, MAX(final_dis_pnl) final_dis_pnl, 
				MAX(und_pnl) final_und_pnl, MAX(dis_pnl) final_dis_pnl, 
				MAX(tax_perc) tax_perc
				FROM ' + @DealProcessTableName + '
				GROUP BY link_id, source_deal_header_id, term_start, as_of_date
				) mp GROUP BY source_deal_header_id, term_start, as_of_date ')


	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************END of Creating Delta PNL: populating  #d_max_pnl *****************************'	
	END

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name = 'sql_log_' + CAST(@log_increment AS VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time = GETDATE()
		PRINT @pr_name + ' Running..............'
	END

	CREATE INDEX IX_D_MAX_PNL  ON #d_max_pnl (source_deal_header_id, term_start, as_of_date) 
	CREATE INDEX IX_D_CPR ON #d_cpr (	source_deal_header_id, as_of_date, term_start, term_end)

	-- getting deals that are still linked but partially expired
	CREATE TABLE #cp_expired (source_deal_header_id INT, term_start DATETIME, e_und_pnl FLOAT, e_final_und_pnl FLOAT, 
			e_final_und_pnl_remaining FLOAT, e_final_dis_pnl_remaining FLOAT)

	INSERT INTO #cp_expired 
	SELECT source_deal_header_id, term_start, SUM(und_pnl) e_und_pnl, SUM(final_und_pnl) e_final_und_pnl, 
			SUM(final_und_pnl_remaining) e_final_und_pnl_remaining, SUM(final_dis_pnl_remaining) e_final_dis_pnl_remaining
	FROM calcprocess_deals_expired 
	WHERE hedge_or_item = 'h' AND link_type = 'link' AND as_of_date < @std_contract_month
	GROUP BY source_deal_header_id, term_start

	-- SELECT * from #cp_expired
	CREATE INDEX IX_CP_EXPIRED ON #cp_expired (source_deal_header_id, term_start)
	-- END of getting deals that are still linked but partially expired

	SET @sqlSelect1 = ' 
	INSERT INTO ' + @DealProcessTableName + '
	SELECT	MAX(ph_stra.parent_entity_id) fas_subsidiary_id, MAX(ph_stra.entity_id) fas_strategy_id, MAX(cpr.fas_book_id) fas_book_id,
			cpr.source_deal_header_id, 
			MAX(cpr.deal_date) deal_date, MAX(cpr.deal_type) deal_type, 
			MAX(deal_sub_type) deal_sub_type, 
			MAX(source_counterparty_id) source_counterparty_id, MAX(cpr.physical_financial_flag) physical_financial_flag, 
			cpr.as_of_date, cpr.term_start, cpr.term_end, 1 Leg, contract_expiration_date, 
			MAX(fixed_float_leg) fixed_float_leg, MAX(buy_sell_flag) buy_sell_flag, MAX(curve_id) curve_id, 
			MAX(fixed_price) fixed_price, MAX(fixed_price_currency_id) fixed_price_currency_id, MAX(option_strike_price) option_strike_price, 
			MAX(deal_volume) deal_volume, MAX(deal_volume_frequency) deal_volume_frequency, MAX(deal_volume_uom_id) deal_volume_uom_id, 
			MAX(block_description) block_description, MAX(deal_detail_description) deal_detail_description, ''h'' hedge_or_item, 
			cpr.source_deal_header_id link_id, 1-MAX(percentage_included) percentage_included, MAX(link_effective_date) link_effective_date, 
			MAX(dedesignation_link_id) dedesignation_link_id, 
			''deal'' link_type, MAX(discount_factor) discount_factor, MAX(func_cur_value_id) func_cur_value_id, 
			MAX(und_pnl) und_pnl, 0 und_intrinsic_pnl, 0 und_extrinsic_pnl, 
			MAX(pnl_currency_id) pnl_currency_id, MAX(pnl_conversion_factor) pnl_conversion_factor, 
			MAX(pnl_source_value_id) pnl_source_value_id, ''y'' link_active, ''n'' fully_dedesignated, ''n'' perfect_hedge, 
			MAX(eff_test_profile_id) eff_test_profile_id, MAX(link_type_value_id) link_type_value_id, 
			MAX(dedesignated_link_id) dedesignated_link_id, 152 hedge_type_value_id, 
			''n'' fx_hedge_flag, MAX(no_links) no_links, MAX(mes_gran_value_id) mes_gran_value_id, MAX(mes_cfv_value_id) mes_cfv_value_id, 
			227 mes_cfv_values_value_id, MAX(gl_grouping_value_id) gl_grouping_value_id, 
			NULL mismatch_tenor_value_id, 
			MAX(strip_trans_value_id) strip_trans_value_id, MAX(asset_liab_calc_value_id) asset_liab_calc_value_id, 
			MAX(test_range_from) test_range_from, MAX(test_range_to) test_range_to, MAX(additional_test_range_from) additional_test_range_from, 
			MAX(additional_test_range_to) additional_test_range_to, MAX(additional_test_range_from2) additional_test_range_from2, 
			MAX(additional_test_range_to2) additional_test_range_to2, MAX(include_unlinked_hedges) include_unlinked_hedges, 
			MAX(include_unlinked_items) include_unlinked_items, MAX(no_link) no_link, MAX(use_eff_test_profile_id) use_eff_test_profile_id, 
			MAX(on_eff_test_approach_value_id) on_eff_test_approach_value_id, MAX(no_links_fas_eff_test_profile_id) no_links_fas_eff_test_profile_id, 
			MAX(dedesignation_pnl_currency_id) dedesignation_pnl_currency_id, MAX(pnl_ineffectiveness_value) pnl_ineffectiveness_value, 
			MAX(pnl_dedesignation_value) pnl_dedesignation_value, MAX(locked_aoci_value) locked_aoci_value, 
			MAX(pnl_cur_coversion_factor) pnl_cur_coversion_factor, MAX(ded_pnl_cur_conversion_factor) ded_pnl_cur_conversion_factor, 
			MAX(eff_pnl_cur_conversion_factor) eff_pnl_cur_conversion_factor, MAX(assessment_values) assessassessment_valuesment_values, 
			MAX(additional_assessment_values) additional_assessment_values, MAX(additional_assessment_values2) additional_assessment_values2, 
			MAX(use_assessment_values) use_assessment_values, MAX(use_additional_assessment_values) use_additional_assessment_values, 
			MAX(use_additional_assessment_values2) use_additional_assessment_values2, MAX(assessment_date) assessment_date, MAX(ddf) ddf, 
			MAX(alpha) alpha, MAX(eff_und_pnl) eff_und_pnl, MAX(eff_und_intrinsic_pnl) eff_und_intrinsic_pnl, 
			MAX(eff_und_extrinsic_pnl) eff_und_extrinsic_pnl, MAX(eff_pnl_source_value_id) eff_pnl_source_value_id, 
			MAX(eff_pnl_currency_id) eff_pnl_currency_id, MAX(eff_pnl_conversion_factor) eff_pnl_conversion_factor, 	
			MAX(eff_pnl_as_of_date) eff_pnl_as_of_date, MAX(pnl_as_of_date) pnl_as_of_date, 
			MAX(dedesignation_date) dedesignation_date, MAX(cpr.deal_id) deal_id, MAX(cpr.option_flag) option_flag, 
			(MAX(ISNULL(max_pnl.max_final_dis_pnl, 0)) - SUM(ISNULL(cpr.final_dis_pnl_remaining, 0)) - SUM(ISNULL(ce.e_final_dis_pnl_remaining, 0)))   final_dis_pnl, 
			MAX(final_dis_instrinsic_pnl) final_dis_instrinsic_pnl, 
			MAX(final_dis_extrinsic_pnl) final_dis_extrinsic_pnl, 
			0 final_dis_locked_aoci_value, 0 final_dis_dedesignated_cum_pnl, 0 final_dis_pnl_ineffectiveness_value, 0 final_dis_pnl_dedesignation_value, 
			(MAX(ISNULL(max_pnl.max_final_dis_pnl, 0)) - SUM(ISNULL(cpr.final_dis_pnl_remaining, 0)) - SUM(ISNULL(ce.e_final_dis_pnl_remaining, 0)))  final_dis_pnl_remaining, 
			0 final_dis_pnl_intrinsic_remaining, 
			0 final_dis_pnl_extrinsic_remaining, 
			(MAX(ISNULL(max_pnl.max_final_und_pnl, 0)) - SUM(ISNULL(cpr.final_und_pnl_remaining, 0)) - SUM(ISNULL(ce.e_final_und_pnl_remaining, 0))) final_und_pnl, 
			MAX(final_und_instrinsic_pnl) final_und_instrinsic_pnl, 
			MAX(final_und_extrinsic_pnl) final_und_extrinsic_pnl, 
			0 final_und_locked_aoci_value, 0 final_und_dedesignated_cum_pnl, 0 final_und_pnl_ineffectiveness_value, 0 final_und_pnl_dedesignation_value, 
			(MAX(ISNULL(max_pnl.max_final_und_pnl, 0)) - SUM(ISNULL(cpr.final_und_pnl_remaining, 0)) - SUM(ISNULL(ce.e_final_und_pnl_remaining, 0))) final_und_pnl_remaining, 
			0 final_und_pnl_intrinsic_remaining, 
			0 final_und_pnl_extrinsic_remaining, 
			MAX(item_match_term_month) item_match_term_month,  MAX(item_term_month) item_term_month, MAX(long_term_months) long_term_months, 
			MAX(cpr.source_system_id) source_system_id, ''y'' [include], MAX(hedge_term_month) hedge_term_month, MAX(eff_test_result_id) eff_test_result_id, 
			0 notional_pay_pnl, 0 notional_rec_pnl, ''n'' receive_float, 0 carrying_amount, 0 carrying_set_amount, 0 interest_debt, 
			''n'' short_cut_method, ''n'' exclude_spot_forward_diff, 0 option_premium, MAX(options_premium_approach) options_premium_approach, 
			MAX(options_amortization_factor) options_amortization_factor, 0 fd_und_pnl, 0 fd_und_intrinsic_pnl, 0 fd_und_extrinsic_pnl, 
			0 fd_und_ignored_pnl, 0	link_dedesignated_percentage, MAX(cpr.fas_deal_type_value_id) fas_deal_type_value_id, 
			MAX(cpr.fas_deal_sub_type_value_id) fas_deal_sub_type_value_id, MAX(mstm_eff_test_type_id) mstm_eff_test_type_id, 
			0 p_u_hedge_mtm, 0 p_d_hedge_mtm, 0 p_u_aoci, 0 p_d_aoci, 0 p_u_total_pnl, 0 p_d_total_pnl,
			CASE WHEN (cpr.term_start <= cpr.as_of_date) THEN 1 ELSE 0 END test_settled, 520 rollout_per_type, MAX(max_pnl.tax_perc) tax_perc,
			NULL oci_rollout_approach_value_id, NULL link_end_date, MAX(dis_pnl) dis_pnl,
			0 prior_assessment_test '

	SET @sqlSelect2 = ' FROM #d_cpr cpr INNER JOIN	
							portfolio_hierarchy ph_book ON ph_book.entity_id = cpr.fas_book_id INNER JOIN
							portfolio_hierarchy ph_stra ON ph_stra.entity_id = ph_book.parent_entity_id INNER JOIN		'

	SET @sqlSelect3 = ' #d_max_pnl max_pnl ON max_pnl.as_of_date = cpr.as_of_date AND
					max_pnl.source_deal_header_id = cpr.source_deal_header_id AND max_pnl.term_start = cpr.term_start 
				LEFT OUTER JOIN #cp_expired ce on ce.source_deal_header_id = cpr.source_deal_header_id  and ce.term_start = cpr.term_start 
	GROUP BY 
		cpr.source_deal_header_id, 
		cpr.as_of_date, cpr.term_start, cpr.term_end, contract_expiration_date, cpr.source_deal_header_id
	HAVING ABS((MAX(ISNULL(max_pnl.max_final_und_pnl, 0)) - SUM(ISNULL(cpr.final_und_pnl_remaining, 0)))) > 0.01 --0.99 
	'		
	EXEC spa_print @sqlSelect1
	EXEC spa_print @sqlSelect2
	EXEC spa_print @sqlSelect3
	--return
	EXEC(@sqlSelect1 + @sqlSelect2 + @sqlSelect3)

	IF @print_diagnostic = 1
	BEGIN
		PRINT @pr_name + ': ' + CAST(DATEDIFF(ss, @log_time, GETDATE()) AS VARCHAR) +'*************************************'
		PRINT '****************END of Creating Delta PNL *****************************'	
	END
--END
-----------------CALCULATE DELTA PNL AND LOAD IN CALCPROCESS TABLE --------------
-------------------- DELETE ALL PROCESS TABLES ---------------
IF @print_diagnostic = 0
BEGIN
	DECLARE @deleteStmt VARCHAR(500)
	
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@tempLinksTableName)
	EXEC(@deleteStmt)	

--	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@tempSourceDealPNLTableName)
--	EXEC(@deleteStmt)	

	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@tempSpotMTM)
	EXEC(@deleteStmt)	

	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@dealPNL)
	EXEC(@deleteStmt)	

	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@deal)
	EXEC(@deleteStmt)

	--If Error found also delete other process tables
	IF (SELECT COUNT(1) FROM measurement_process_status
			WHERE (process_id = @process_id AND calc_type = 'm' AND can_proceed = 'n')) > 0
	BEGIN
		SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@DealProcessTableName)
		EXEC(@deleteStmt)

		SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@AOCIReleaseSchedule)
		EXEC(@deleteStmt)
	END
END

IF @print_diagnostic = 1
BEGIN
	PRINT '******************************************************************************************'
	PRINT '********************END &&&&&&&&&[spa_Collect_Link_Deals_PNL_OffSetting_Links ' + CAST(DATEDIFF(ss, @proc_begin_time, GETDATE()) AS VARCHAR) + ' Secs]**********'
END

GO