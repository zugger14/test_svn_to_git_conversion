IF OBJECT_ID('spa_calc_explain_mtm') IS NOT NULL
    DROP PROC [dbo].[spa_calc_explain_mtm]
GO
---sync with spa_calc_mtm_job unto revision #18917	
CREATE PROCEDURE [dbo].[spa_calc_explain_mtm]
	@sub_id VARCHAR(100) = NULL,
	@strategy_id VARCHAR(100) = NULL,
	@book_id VARCHAR(100) = NULL,
	@source_book_mapping_id VARCHAR(100) = NULL,
	@source_deal_header_id VARCHAR(5000) = NULL,
	@as_of_date VARCHAR(100),
	@curve_source_value_id INT ,
	@pnl_source_value_id INT ,
	@hedge_or_item CHAR(1) = NULL,
	@process_id VARCHAR(50) = NULL,
	@job_name VARCHAR(100) = NULL,
	@user_id VARCHAR(100) = NULL,
	@assessment_curve_type_value_id INT = 77,
	@table_name VARCHAR(100) = NULL,
	@print_diagnostic INT = NULL,
	@curve_as_of_date VARCHAR(100) = NULL,
	@tenor_option VARCHAR(1) = NULL,
	@summary_detail VARCHAR(1) = NULL,
	@options_only VARCHAR(1) = NULL,
	@trader_id INT = NULL,
	@status_table_name VARCHAR(100) = NULL,
	@run_incremental CHAR(1) = NULL,
	@term_start VARCHAR(100) = NULL,
	@term_end VARCHAR(100) = NULL,
	@calc_type VARCHAR(1) = NULL, --'m' for mtm, 'w' for what if and 's' for settlement
	@curve_shift_val FLOAT = NULL,
	@curve_shift_per FLOAT = NULL,
	@deal_list_table VARCHAR(100) = NULL, -- contains list of deals to be processed
	@criteria_id INT,
	@counterparty_id VARCHAR(500) = NULL,
	@st_hr VARCHAR(300) = NULL,
	@st_criteria VARCHAR(500) = NULL,
	@round CHAR(1) = NULL,
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(1000) = NULL,
	@enable_paging INT = 0, --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS
	
--SET STATISTICS IO OFF
--SET NOCOUNT OFF
--SET ROWCOUNT 0
--------------------BEGIN OF TESTING -------------------------
-----------------------------------------------------------------------
/*

--SELECT * FROM   adiha_process.dbo.explain_position_farrms_admin_66A653C5_E9B4_43AD_8BEC_2C55A2467DB3
  
DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
DBCC stackdump(1)

DECLARE @sub_id                          VARCHAR(100),
        @strategy_id                     VARCHAR(100),
        @book_id                         VARCHAR(100),
        @source_book_mapping_id          VARCHAR(100),
        @source_deal_header_id           VARCHAR(5000),
        @as_of_date                      VARCHAR(100),
        @curve_source_value_id           INT,
        @pnl_source_value_id             INT,
        @hedge_or_item                   CHAR(1),
        @process_id                      VARCHAR(50),
        @job_name                        VARCHAR(100),
        @user_id                         VARCHAR(100),
        @assessment_curve_type_value_id  INT,
        @table_name                      VARCHAR(200),
        @print_diagnostic                INT,
        @curve_as_of_date                VARCHAR(100),
        @tenor_option                    VARCHAR(1),
        @summary_detail                  VARCHAR(1),
        @options_only                    VARCHAR(1),
        @trader_id                       INT,
        @status_table_name               VARCHAR(100),
        @run_incremental                 CHAR(1),
        @term_start                      VARCHAR(100),
        @term_end                        VARCHAR(100),
        @calc_type                       VARCHAR(1),	--'m' for mtm, 'w' for what if and 's' for settlement
        @curve_shift_val                 FLOAT,
        @curve_shift_per                 FLOAT,
        @deal_list_table                 VARCHAR(100),	-- contains list of deals to be processed	@batch_process_id	varchar(50),
        @criteria_id                     INT,	--what-if criteria id
        @counterparty_id                 INT,
        @batch_process_id                VARCHAR(50) = NULL,
        @batch_report_param              VARCHAR(1000) = NULL,
        @enable_paging                   INT = 0,	--'1' = enable, '0' = disable
        @page_size                       INT = NULL,
        @page_no                         INT = NULL,
		@st_hr VARCHAR(300) = NULL,
		@st_criteria VARCHAR(500) = NULL,
		@round CHAR(1) = NULL
SELECT @sub_id = NULL, --'147,148,149',	--148, 
       @strategy_id = NULL,
       @book_id = NULL,
       @source_book_mapping_id = NULL,
       @source_deal_header_id = '44494',	--1654
       @as_of_date = '2012-03-06',
       @curve_source_value_id = 4500,
       @pnl_source_value_id = 775,
       @hedge_or_item = NULL,
       @process_id = NULL,
       @job_name = NULL,
       @user_id = 'farrms_admin',
       @assessment_curve_type_value_id = 77,
       @table_name = 'adiha_process.dbo.explain_position_farrms_admin_B0AE59F4_71D4_48F4_832A_2045E224BD25',
       @print_diagnostic = NULL,
       @curve_as_of_date = NULL,
       @tenor_option = NULL,
       @summary_detail = 'd',
       @options_only = NULL,
       @trader_id = NULL,
       @status_table_name = NULL,
       @run_incremental = 'n',
       @term_start = '2000-01-01',
       @term_end = '2019-12-31',
       @calc_type = '1',	--'m', --'m',
       @curve_shift_val = NULL,
       @curve_shift_per = NULL,
       @criteria_id = NULL,
       @deal_list_table = NULL,	--'adiha_process.dbo.WhatIfSample',
       @batch_process_id = NULL,
       @batch_report_param = NULL
	
	SET @print_diagnostic = 1
	SET @curve_as_of_date = NULL
	SET @tenor_option = NULL
	SET @summary_detail = 'd'
	SET @options_only = NULL
	SET @trader_id = NULL
 
	DELETE FROM MTM_TEST_RUN_LOG



DROP TABLE #inserted_deals
	DROP TABLE #temp_deals
	DROP TABLE #temp_curves
	DROP TABLE #temp_leg_mtm
	DROP TABLE #avg_temp_curves
	DROP TABLE #non_expired_deals
	DROP TABLE #curve_uom_conv_factor
	DROP TABLE #tx
	DROP TABLE #formula_value
	DROP TABLE #fx_curve_ids
	DROP TABLE #fx_curves
	DROP TABLE #uom_ids
	DROP TABLE #tmp_delete
	DROP TABLE #source_deal_header_id
	DROP TABLE #hourly_vol_deals
	DROP TABLE #hourly_vol
	DROP TABLE #hrly_wght_avg_price
	DROP TABLE #cids
	DROP TABLE #cids_derived
	DROP TABLE  #tmp_hourly_price_vol  
	DROP TABLE #hrly_price_curves
	DROP TABLE #source_deal_settlement
	DROP TABLE #lag_curves
	DROP TABLE #lag_curves_values
	DROP TABLE #lag_curves_values_fx
	DROP TABLE #tmp_hourly_price_vol_c
	DROP TABLE #hrl_pos
	DROP TABLE #hrl_pos_c
	DROP TABLE #as_of_date_to
	DROP TABLE #hrly_price_curves_to
	DROP TABLE #temp_curves_to
	DROP TABLE #lag_curves_values_to
	DROP TABLE #avg_temp_curves_to
	DROP TABLE #tmp_hourly_price_vol_c
	DROP TABLE #tmp_hourly_price_vol
DROP TABLE #explain_mtm_deal
	DROP TABLE #deleted_deals
	DROP TABLE #non_deleted_deals

	DROP TABLE #source_deal_header
	DROP TABLE #source_deal_detail
	DROP TABLE #books
	DROP TABLE #formula_value_to
	
	DROP TABLE #explain_mtm
	DROP TABLE #explain_mtm_final
	DROP TABLE #tmp_sum_explain_mtm
	DROP TABLE #explain_mtm_monthly
	DROP TABLE #tmp_sum_explain_mtm
	
	DROP TABLE #tmp_sum_per_alloc

	DROP TABLE #left_side_term
	DROP TABLE #sum_left_side_term
	
	DROP TABLE #source_deal_header_ob
	DROP TABLE #source_deal_detail_ob
	
	DROP TABLE  #calcprocess_inventory_wght_avg_cost_forward
	
	DROP TABLE #explain_mtm_ob
	DROP TABLE #explain_mtm_cash_ob
	DROP TABLE #explain_mtm_cash
	
--*/

-------------------------- END OF TESTING scripts -------------
----------------------------------------------------------------
SET DEADLOCK_PRIORITY LOW




declare @mtm_loop tinyint

DECLARE @is_discount_curve_a_factor INT
DECLARE @no_days_left varchar(1000)
DECLARE @no_days_accrued varchar(1000)
DECLARE @str_batch_table  VARCHAR(8000)
DECLARE @is_batch         BIT
DECLARE @sql_paging       VARCHAR(8000)
DECLARE @mtm_hourly_prices INT
DECLARE @proc_begin_time      DATETIME
DECLARE @log_time             DATETIME
DECLARE @pr_name              VARCHAR(5000)
DECLARE @log_increment        INT
DECLARE @trading_days         INT
DECLARE @source_price_curve   VARCHAR(100)
DECLARE @derived_curve_table  VARCHAR(100)
DECLARE @DiscountTableName    VARCHAR(200)
DECLARE @orginal_calc_type    VARCHAR(200)
DECLARE @formula_table2 VARCHAR(100)
DECLARE @calc_result_table2 VARCHAR(100)
DECLARE @calc_result_table_breakdown2 VARCHAR(100)
DECLARE @process_id2 VARCHAR(100)
DECLARE  @termstart DATETIME, @formula VARCHAR(8000), @volume FLOAT, @contract_expiration_date DATETIME, @formula_stmt VARCHAR(8000)
DECLARE @maturity_date varchar(1000)
DECLARE @maturity_date_m varchar(1000)
DECLARE @maturity_date_p varchar(1000)
DECLARE @maturity_date_p3 varchar(1000)
DECLARE @maturity_date_s varchar(1000)
DECLARE @monthly_maturity varchar(1000)
DECLARE @sql VARCHAR(8000)
DECLARE @sql_expired_deals varchar(8000)

DECLARE @explain_sql varchar(max)
DECLARE @explain_sql1 varchar(max)
DECLARE @formula_table VARCHAR(100)
DECLARE @calc_result_table VARCHAR(100)
DECLARE @calc_result_table_breakdown VARCHAR(100)
declare @user_login_id varchar(100)

DECLARE @first_date_point VARCHAR(1)

declare @der_curve_id int
declare @min_term_start datetime
declare @max_term_start datetime
declare @curve_as_of_date_from datetime

DECLARE @count             INT
DECLARE @sqlstmt           VARCHAR(MAX)
DECLARE @sqlstmt2          VARCHAR(MAX)
DECLARE @sqlstmt3          VARCHAR(MAX)
DECLARE @url               VARCHAR(500)
DECLARE @urlP              VARCHAR(500)
DECLARE @url_desc          VARCHAR(8000)
DECLARE @user_name         VARCHAR(25)
DECLARE @desc              VARCHAR(8000)
DECLARE @price_curve_name  VARCHAR(50)
DECLARE @price_curve_id    VARCHAR(50)
DECLARE @where_clause      VARCHAR(5000)
DECLARE @from_clause       VARCHAR(8000)

DECLARE @sp_name          VARCHAR(100)
DECLARE @report_name      VARCHAR(100)

--Start tracking time for Elapse time
DECLARE @begin_time     DATETIME,
        @as_of_date_to  DATETIME

DECLARE @dst AS varchar(MAX)
		,@fields  AS varchar(MAX)		,@rpt_fields  AS varchar(MAX)
		,@set_cb_value   AS varchar(MAX)
		,@set_price_changed   AS varchar(MAX)
		,@set_delivered   AS varchar(MAX)
		,@set_deleted  AS varchar(MAX)
		,@set_forecast_changed  AS varchar(MAX)
		,@set_modify_deal  AS varchar(MAX)
		,@set_new_deal  AS varchar(MAX)
		,@set_ob_value  AS varchar(MAX)
		,@price_changed  AS varchar(MAX)
		,@CB_MTM  AS varchar(MAX)
		,@market_cb_value  AS varchar(MAX)
		,@contract_cb_value  AS varchar(MAX)
		,@market_delivered  AS varchar(MAX)
		,@contract_delivered  AS varchar(MAX)
		,@delivered  AS varchar(MAX)
		,@market_deleted  AS varchar(MAX)
		,@contract_deleted  AS varchar(MAX)
		,@deleted  AS varchar(MAX)
		,@market_forecast_changed  AS varchar(MAX)
		,@contract_forecast_changed  AS varchar(MAX)
		,@forecast_changed  AS varchar(MAX)
		,@modify_deal  AS varchar(MAX)
		,@OB_MTM  AS varchar(MAX)
		,@market_ob_value  AS varchar(MAX)		
		,@contract_ob_value  AS varchar(MAX)
		,@market_new_deal  AS varchar(MAX)
		,@contract_new_deal  AS varchar(MAX)
		,@new_deal  AS varchar(MAX)
		,@from1  AS varchar(MAX)
		,@from2  AS varchar(MAX)
		,@from3  AS varchar(MAX)
		,@from4  AS varchar(MAX)
		,@where  AS varchar(MAX)	
		,@st_as_of_date  AS varchar(1000)
		,@st_currency  AS varchar(100)

DECLARE @baseload_block_type varchar(30),@baseload_block_define_id varchar(30)

DECLARE @temptablequery VARCHAR(500)
Declare @mkt_drill_down varchar(1)
declare @premium_id INT


set @term_start=ISNULL(@term_start,'2000-01-01')
set @term_end=ISNULL(@term_end,'9999-12-01')


SET @orginal_calc_type = @calc_type


SET @premium_id = 2 ---fees 1

SET @mkt_drill_down = NULL

If @calc_type IN ('d', 'c')
BEGIN
	SET @mkt_drill_down = @calc_type
	SET @calc_type = 'm'
END 
If @calc_type IN ('e')
BEGIN
	SET @mkt_drill_down = 'd'
	SET @calc_type = 's'
END 
If @calc_type IN ('f')
BEGIN
	SET @mkt_drill_down = 'c'
	SET @calc_type = 's'
END 


SET @begin_time = GETDATE()
SET @proc_begin_time = GETDATE()


IF @user_id IS NULL
    SET @user_id = dbo.FNADBUser()

SET @baseload_block_type = '12000'	-- Internal Static Data
SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data

SET @pnl_source_value_id = @curve_source_value_id
SET @trading_days = 252

IF @process_id IS NULL
BEGIN
    SET @process_id = REPLACE(NEWID(), '-', '_')
END
--SET @source_price_curve = dbo.FNAGetProcessTableName(@as_of_date, 'source_price_curve')
SET @derived_curve_table = dbo.FNAProcessTableName('der_price_curve', @user_id, @process_id)
SET @DiscountTableName = dbo.FNAProcessTableName('calcprocess_discount_factor', @user_id, @process_id)


SET @temptablequery = 'exec ' + DB_NAME() + '.dbo.spa_get_mtm_test_run_log ''' + @process_id + ''''

IF @curve_as_of_date IS NULL
    SET @curve_as_of_date = @as_of_date

IF @assessment_curve_type_value_id IS NULL
    SET @assessment_curve_type_value_id = 77

IF @calc_type IS NULL OR (@calc_type <> 's' AND @calc_type <> 'w')
    SET @calc_type = 'm'

IF @calc_type = 'w'
BEGIN
    IF @curve_shift_val IS NULL
        SET @curve_shift_val = 0
    
    IF @curve_shift_per IS NULL OR @curve_shift_per = 0
        SET @curve_shift_per = 1
    ELSE
        SET @curve_shift_per = @curve_shift_per + 1
END
ELSE
BEGIN
    SET @curve_shift_val = 0
    SET @curve_shift_per = 1
END 


 
--BEGIN TRY

IF @table_name = ''
    SET @table_name = NULL



SET @where_clause = ''
SET @from_clause = ''

SET @user_name = @user_id

--0 means do not calcualte and 1 means calculate

SELECT @mtm_hourly_prices = var_value
FROM   adiha_default_codes_values
WHERE  (instance_no = 1)
       AND (default_code_id = 40)
       AND (seq_no = 1)

IF @mtm_hourly_prices IS NULL
    SET @mtm_hourly_prices = 0

CREATE TABLE #deleted_deals(source_deal_id INT)
CREATE TABLE #non_deleted_deals(source_deal_id INT)

PRINT('INSERT INTO #non_deleted_deals(source_deal_id ) 
		SELECT DISTINCT source_deal_header_id FROM '+@table_name + ' 
		WHERE deleted =0')

EXEC('INSERT INTO #non_deleted_deals(source_deal_id ) 
		SELECT DISTINCT source_deal_header_id FROM '+@table_name + ' 
		WHERE deleted =0')

PRINT('INSERT INTO #deleted_deals(source_deal_id ) 
		SELECT DISTINCT source_deal_header_id FROM '+@table_name+' s 
			LEFT JOIN #non_deleted_deals d ON s.source_deal_header_id=d.source_deal_id  
		WHERE d.source_deal_id IS NULL AND s.deleted <>0')

EXEC('INSERT INTO #deleted_deals(source_deal_id ) 
		SELECT DISTINCT source_deal_header_id FROM '+@table_name+' s 
		LEFT JOIN #non_deleted_deals d ON s.source_deal_header_id=d.source_deal_id  
		WHERE d.source_deal_id IS NULL AND s.deleted <>0')



SELECT source_deal_header_id,source_system_id,deal_id,deal_date,ext_deal_id,physical_financial_flag,structured_deal_id,counterparty_id,
	entire_term_start,entire_term_end,source_deal_type_id,deal_sub_type_type_id,option_flag,option_type,option_excercise_type,
	source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,description1,description2,description3,
	deal_category_value_id,trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,broker_id,
	generator_id,status_value_id,status_date,assignment_type_value_id,compliance_year,state_value_id,assigned_date,assigned_by,generation_source,
	aggregate_environment,aggregate_envrionment_comment,rec_price,rec_formula_id,rolling_avg,contract_id,create_user,create_ts
	,update_user,update_ts,legal_entity,internal_desk_id,product_id,internal_portfolio_id,commodity_id,reference,deal_locked,close_reference_id,
	block_type,block_define_id,granularity_id,Pricing,deal_reference_type_id,unit_fixed_flag,broker_unit_fees,broker_fixed_cost,broker_currency_id,
	deal_status,term_frequency,option_settlement_date,verified_by,verified_date,risk_sign_off_by,risk_sign_off_date,back_office_sign_off_by,
	back_office_sign_off_date,book_transfer_id,confirm_status_type
INTO #source_deal_header
FROM delete_source_deal_header dsdh  INNER JOIN (select source_deal_id from #deleted_deals union all select source_deal_id from #non_deleted_deals ) d ON dsdh.source_deal_header_id=d.source_deal_id
UNION 
SELECT source_deal_header_id,source_system_id,deal_id,deal_date,ext_deal_id,physical_financial_flag,structured_deal_id,counterparty_id,
	entire_term_start,entire_term_end,source_deal_type_id,deal_sub_type_type_id,option_flag,option_type,option_excercise_type,
	source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,description1,description2,description3,
	deal_category_value_id,trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,broker_id,
	generator_id,status_value_id,status_date,assignment_type_value_id,compliance_year,state_value_id,assigned_date,assigned_by,generation_source,
	aggregate_environment,aggregate_envrionment_comment,rec_price,rec_formula_id,rolling_avg,contract_id,create_user,create_ts
	,update_user,update_ts,legal_entity,internal_desk_id,product_id,internal_portfolio_id,commodity_id,reference,deal_locked,close_reference_id,
	block_type,block_define_id,granularity_id,Pricing,deal_reference_type_id,unit_fixed_flag,broker_unit_fees,broker_fixed_cost,broker_currency_id,
	deal_status,term_frequency,option_settlement_date,verified_by,verified_date,risk_sign_off_by,risk_sign_off_date,back_office_sign_off_by,
	back_office_sign_off_date,book_transfer_id,confirm_status_type
FROM source_deal_header sdh INNER JOIN (select source_deal_id from #deleted_deals union all select source_deal_id from #non_deleted_deals ) d ON sdh.source_deal_header_id=d.source_deal_id

SELECT source_deal_detail_id,source_deal_header_id,term_start,term_end,Leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,
	fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,deal_detail_description,
	formula_id,volume_left,settlement_volume,settlement_uom,create_user,create_ts,update_user,update_ts,price_adder,price_multiplier,
	settlement_date,day_count_id,location_id,meter_id,physical_financial_flag,Booked,process_deal_status,fixed_cost,multiplier,
	adder_currency_id,fixed_cost_currency_id,formula_currency_id,price_adder2,price_adder_currency2,volume_multiplier2,total_volume,
	pay_opposite,capacity,settlement_currency,standard_yearly_volume,formula_curve_id,price_uom_id,category,profile_code,pv_party
INTO #source_deal_detail
FROM dbo.delete_source_deal_detail dsdd  INNER JOIN (select source_deal_id from #deleted_deals union all select source_deal_id from #non_deleted_deals ) d ON dsdd.source_deal_header_id=d.source_deal_id
UNION 
SELECT source_deal_detail_id,source_deal_header_id,term_start,term_end,Leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,
	fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,deal_detail_description,
	formula_id,volume_left,settlement_volume,settlement_uom,create_user,create_ts,update_user,update_ts,price_adder,price_multiplier,
	settlement_date,day_count_id,location_id,meter_id,physical_financial_flag,Booked,process_deal_status,fixed_cost,multiplier,
	adder_currency_id,fixed_cost_currency_id,formula_currency_id,price_adder2,price_adder_currency2,volume_multiplier2,total_volume,
	pay_opposite,capacity,settlement_currency,standard_yearly_volume,formula_curve_id,price_uom_id,category,profile_code,pv_party
FROM dbo.source_deal_detail sdd  INNER JOIN (select source_deal_id from #deleted_deals union all select source_deal_id from #non_deleted_deals ) d ON sdd.source_deal_header_id=d.source_deal_id


---for opening balance
SELECT source_deal_header_id,source_system_id,deal_id,deal_date,ext_deal_id,physical_financial_flag,structured_deal_id,counterparty_id,
	entire_term_start,entire_term_end,source_deal_type_id,deal_sub_type_type_id,option_flag,option_type,option_excercise_type,
	source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,description1,description2,description3,
	deal_category_value_id,trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,broker_id,
	generator_id,status_value_id,status_date,assignment_type_value_id,compliance_year,state_value_id,assigned_date,assigned_by,generation_source,
	aggregate_environment,aggregate_envrionment_comment,rec_price,rec_formula_id,rolling_avg,contract_id,create_user,create_ts
	,update_user,update_ts,legal_entity,internal_desk_id,product_id,internal_portfolio_id,commodity_id,reference,deal_locked,close_reference_id,
	block_type,block_define_id,granularity_id,Pricing,deal_reference_type_id,unit_fixed_flag,broker_unit_fees,broker_fixed_cost,broker_currency_id,
	deal_status,term_frequency,option_settlement_date,verified_by,verified_date,risk_sign_off_by,risk_sign_off_date,back_office_sign_off_by,
	back_office_sign_off_date,book_transfer_id,confirm_status_type
INTO #source_deal_header_ob
from delete_source_deal_header dsdh  INNER JOIN (select source_deal_id from #deleted_deals union all select source_deal_id from #non_deleted_deals ) d ON dsdh.source_deal_header_id=d.source_deal_id
UNION 
select a.* FROM source_deal_header sdh INNER JOIN #non_deleted_deals d1 ON sdh.source_deal_header_id=d1.source_deal_id
cross apply (
SELECT  top 1 source_deal_header_id,source_system_id,deal_id,deal_date,ext_deal_id,physical_financial_flag,structured_deal_id,counterparty_id,
	entire_term_start,entire_term_end,source_deal_type_id,deal_sub_type_type_id,option_flag,option_type,option_excercise_type,
	source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,description1,description2,description3,
	deal_category_value_id,trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,broker_id,
	generator_id,status_value_id,status_date,assignment_type_value_id,compliance_year,state_value_id,assigned_date,assigned_by,generation_source,
	aggregate_environment,aggregate_envrionment_comment,rec_price,rec_formula_id,rolling_avg,contract_id,create_user,create_ts
	,update_user,update_ts,legal_entity,internal_desk_id,product_id,internal_portfolio_id,commodity_id,reference,deal_locked,close_reference_id,
	block_type,block_define_id,granularity_id,Pricing,deal_reference_type_id,unit_fixed_flag,broker_unit_fees,broker_fixed_cost,broker_currency_id,
	deal_status,term_frequency,option_settlement_date,verified_by,verified_date,risk_sign_off_by,risk_sign_off_date,back_office_sign_off_by,
	back_office_sign_off_date,book_transfer_id,confirm_status_type
FROM source_deal_header_audit sdh where sdh.source_deal_header_id=d1.source_deal_id
	and  update_ts <=@as_of_date
order by update_ts desc
) a

SELECT  source_deal_detail_id,source_deal_header_id,term_start,term_end,Leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,
	fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,deal_detail_description,
	formula_id,volume_left,settlement_volume,settlement_uom,create_user,create_ts,update_user,update_ts,price_adder,price_multiplier,
	settlement_date,day_count_id,location_id,meter_id,physical_financial_flag,Booked,process_deal_status,fixed_cost,multiplier,
	adder_currency_id,fixed_cost_currency_id,formula_currency_id,price_adder2,price_adder_currency2,volume_multiplier2,total_volume,
	pay_opposite,capacity,settlement_currency,standard_yearly_volume,formula_curve_id,price_uom_id,category,profile_code,pv_party
INTO #source_deal_detail_ob
FROM dbo.delete_source_deal_detail dsdd  INNER JOIN (select source_deal_id from #deleted_deals union all select source_deal_id from #non_deleted_deals ) d ON dsdd.source_deal_header_id=d.source_deal_id
UNION 
select a.* from source_deal_detail m inner join #non_deleted_deals nd on m.source_deal_header_id=nd.source_deal_id
cross apply (
SELECT  top 1 source_deal_detail_id,source_deal_header_id,term_start,term_end,Leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,
	fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,deal_detail_description,
	formula_id,volume_left,settlement_volume,settlement_uom,create_user,create_ts,update_user,update_ts,price_adder,price_multiplier,
	settlement_date,day_count_id,location_id,meter_id,physical_financial_flag,Booked,process_deal_status,fixed_cost,multiplier,
	adder_currency_id,fixed_cost_currency_id,formula_currency_id,price_adder2,price_adder_currency2,volume_multiplier2,total_volume,
	pay_opposite,capacity,settlement_currency,standard_yearly_volume,formula_curve_id,price_uom_id,category,profile_code,pv_party
FROM dbo.source_deal_detail_audit sdd  where sdd.source_deal_detail_id=m.source_deal_detail_id
 and update_ts <=@as_of_date
order by update_ts desc
) a  


CREATE TABLE #books ( 
	fas_book_id INT
	,fas_stra_id INT
	,fas_sub_id INT
	,book_deal_type_map_id INT
	,source_system_book_id1 INT
	,source_system_book_id2 INT
	,source_system_book_id3 INT
	,source_system_book_id4  INT
	,fas_deal_type_value_id INT
	,func_cur_value_id INT
	,discount_curve_id INT
	,risk_free_curve_id int
) 

 
 
SET @from_clause = '
	INSERT INTO  #books
	SELECT  distinct sbm.fas_book_id,stra.entity_id,stra.parent_entity_id,sbm.book_deal_type_map_id fas_book_id,source_system_book_id1,
		source_system_book_id2,source_system_book_id3,source_system_book_id4,sbm.fas_deal_type_value_id 
		, fs.func_cur_value_id,
		fs.discount_curve_id
		,fs.risk_free_curve_id
	FROM portfolio_hierarchy book (nolock) 
	INNER JOIN	Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id 
	 inner JOIN	source_system_book_map sbm ON sbm.fas_book_id = book.entity_id   
	 inner join  fas_subsidiaries fs ON fs.fas_subsidiary_id = stra.parent_entity_id      
	WHERE 1=1 '   


if @hedge_or_item ='h'	
	set @where_clause = @where_clause + ' AND (sbm.fas_deal_type_value_id = 400 OR sbm.fas_deal_type_value_id = 407 OR sbm.fas_deal_type_value_id = 409)'
else if @hedge_or_item ='i'	
	set @where_clause = @where_clause + ' AND sbm.fas_deal_type_value_id = 401 '
else
	set @where_clause = @where_clause + ' AND (sbm.fas_deal_type_value_id = 400 OR sbm.fas_deal_type_value_id = 401 OR sbm.fas_deal_type_value_id = 407 OR sbm.fas_deal_type_value_id = 409)'
					  			
if ISNULL(@sub_id, '') <> ''
	set @where_clause = @where_clause + ' AND stra.parent_entity_id in ('+@sub_id + ')'	
if ISNULL(@strategy_id, '') <>''
	set @where_clause = @where_clause + ' AND stra.entity_id in ('+@strategy_id+')'
if ISNULL(@book_id, '') <>''
	set @where_clause = @where_clause + ' AND book.entity_id in ('+@book_id+')'
if ISNULL(@source_book_mapping_id, '') <> ''
	set @where_clause = @where_clause + ' AND sbm.book_deal_type_map_id in ('+@source_book_mapping_id+')'

print(@from_clause+@where_clause)
EXEC(@from_clause+@where_clause)


-- 0 means it is interest rate, 1 means the vale is already discount factor, 2 discount factor provided at deal level


SELECT  @is_discount_curve_a_factor   = var_value 
FROM         adiha_default_codes_values
WHERE     (instance_no = '1') AND (default_code_id = 14) AND (seq_no = 1)


exec spa_Calc_Discount_Factor @as_of_date, NULL, NULL, NULL, @DiscountTableName, NULL, @source_deal_header_id

--changed 1 to 0 below to remove 1 day from the logic as the start and end date are overlapping by a day.
set @no_days_left = 
	'
	case    when (isnull(sdd.settlement_date, sdd.contract_expiration_date) <= ''' + @as_of_date + ''') then 0
			when (dcd.no_days is null) then
				datediff(dd, sdd.term_start, isnull(sdd.settlement_date, sdd.contract_expiration_date)) + 0 -
				case when (''' + @as_of_date + ''' > sdd.term_start) then
					(datediff(dd, sdd.term_start, ''' + @as_of_date + ''') + 0)
				else 0 end
			else
				(datediff(dd, sdd.term_start, isnull(sdd.settlement_date, sdd.contract_expiration_date))/28) *
				dcd.no_days -

				case when (''' + @as_of_date + ''' > sdd.term_start) then
					dcd.no_days - (datediff(dd, sdd.term_start, ''' + @as_of_date + ''') + 0)
				else 0 end
	end
	'


set @no_days_accrued = 
	'
	case when (sdd.term_start >= ''' + @as_of_date + ''') then 0 
	else 
		case when (dcd.no_days is null) then 
			datediff(dd, sdd.term_start, isnull(sdd.settlement_date, sdd.contract_expiration_date)) + 0
		else (datediff(dd, sdd.term_start, isnull(sdd.settlement_date, sdd.contract_expiration_date))/28) * dcd.no_days end - ' + @no_days_left + ' 
	end 		
	'

set @where_clause = ' where   sdh.deal_date <='''+ dbo.FNAGetSQLStandardDate(@as_of_date)+ ''''	

If isnull(@source_deal_header_id ,'')= ''
BEGIN
	if @trader_id <> ''
		set @where_clause = @where_clause + ' AND sdh.trader_id = ' + cast(@trader_id as varchar)
	if @options_only = 'y'
	    set @where_clause = @where_clause + ' AND sdh.option_flag = ''' + @options_only + ''''
	    

	if @counterparty_id <> ''
	    set @where_clause = @where_clause + ' AND sdh.counterparty_id IN(' + @counterparty_id + ')'

END

IF @calc_type <> 's'
	SET @where_clause = @where_clause + ' AND sdd.term_end > ''' +  @as_of_date  + ''''



SELECT
	b.gl_account_id,
	term_date,
	b.wght_avg_cost
INTO #calcprocess_inventory_wght_avg_cost_forward
FROM
	calcprocess_inventory_wght_avg_cost_forward b 
WHERE  as_of_date = @as_of_date

--980 monthly, 981 daily, 991 quarterly, 992 semi-annual, 993 annual


set @monthly_maturity = 
'
	cast(Year(sdd.term_start) as varchar) + ''-'' + cast(Month(sdd.term_start) as varchar) + ''-01'' 
'

set @maturity_date = 
'
	CASE WHEN (spcd.Granularity = 980) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(Month(sdd.term_start) as varchar) + ''-01'' 
		 WHEN (spcd.Granularity = 981) THEN sdd.term_start
		 WHEN (spcd.Granularity = 991) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(datepart(q, sdd.term_start) as varchar) + ''-01''  
		 WHEN (spcd.Granularity = 992) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, sdd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
		 WHEN (spcd.Granularity = 993) THEN cast(Year(sdd.term_start) as varchar) + ''-01-01'' 
		 ELSE sdd.term_start 
	END 		 
'

set @maturity_date_m = 
'
	CASE WHEN (spcd_m.Granularity = 980) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(Month(sdd.term_start) as varchar) + ''-01'' 
		 WHEN (spcd_m.Granularity = 981) THEN sdd.term_start
		 WHEN (spcd_m.Granularity = 991) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(datepart(q, sdd.term_start) as varchar) + ''-01''  
		 WHEN (spcd_m.Granularity = 992) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, sdd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
		 WHEN (spcd_m.Granularity = 993) THEN cast(Year(sdd.term_start) as varchar) + ''-01-01'' 
		 ELSE sdd.term_start 
	END 		 
'

set @maturity_date_p = 
'
	CASE WHEN (spcd_p.Granularity = 980) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(Month(sdd.term_start) as varchar) + ''-01'' 
		 WHEN (spcd_p.Granularity = 981) THEN sdd.term_start
		 WHEN (spcd_p.Granularity = 991) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(datepart(q, sdd.term_start) as varchar) + ''-01''  
		 WHEN (spcd_p.Granularity = 992) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, sdd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
		 WHEN (spcd_p.Granularity = 993) THEN cast(Year(sdd.term_start) as varchar) + ''-01-01'' 
		 ELSE sdd.term_start 
	END 		 
'

set @maturity_date_p3 = 
'
	CASE WHEN (spcd_p3.Granularity = 980) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(Month(sdd.term_start) as varchar) + ''-01'' 
		 WHEN (spcd_p3.Granularity = 981) THEN sdd.term_start
		 WHEN (spcd_p3.Granularity = 991) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(datepart(q, sdd.term_start) as varchar) + ''-01''  
		 WHEN (spcd_p3.Granularity = 992) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, sdd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
		 WHEN (spcd_p3.Granularity = 993) THEN cast(Year(sdd.term_start) as varchar) + ''-01-01'' 
		 ELSE sdd.term_start 
	END 		 
'

set @maturity_date_s = 
'
	CASE WHEN (spcd_s.Granularity = 980) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(Month(sdd.term_start) as varchar) + ''-01'' 
		 WHEN (spcd_s.Granularity = 981) THEN sdd.term_start
		 WHEN (spcd_s.Granularity = 991) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(datepart(q, sdd.term_start) as varchar) + ''-01''  
		 WHEN (spcd_s.Granularity = 992) THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, sdd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''  
		 WHEN (spcd_s.Granularity = 993) THEN cast(Year(sdd.term_start) as varchar) + ''-01-01'' 
		 ELSE sdd.term_start 
	END 		 
'

set @explain_sql='insert into #temp_deals  
		SELECT    
		sdh.source_deal_header_id,sdd.source_deal_detail_id, sdh.source_system_id,sdh.deal_id,sdh.deal_date,sdh.ext_deal_id,
		sdh.physical_financial_flag,
		sdh.structured_deal_id,sdh.counterparty_id,sdh.entire_term_start,sdh.entire_term_end,sdh.source_deal_type_id, 
		sdh.deal_sub_type_type_id,sdh.option_flag,sdh.option_type,sdh.option_excercise_type,sdh.source_system_book_id1,
		sdh.source_system_book_id2,sdh.source_system_book_id3,sdh.source_system_book_id4,sdh.description1,
		sdh.description2,sdh.description3,sdh.deal_category_value_id,sdh.trader_id,
		' + @maturity_date + ' maturity_date,
		sdd.term_start, sdd.term_end,
		sdd.leg, 
		sdd.contract_expiration_date, 
		sdd.fixed_float_leg,sdd.buy_sell_flag,
		spcd.source_curve_def_id,		
		COALESCE(wacog.wght_avg_cost, sdd.fixed_price, 0) fixed_price,
		case when (isnull(sdd.fixed_price, 0) = 0) then NULL else ISNULL(sc5.currency_id_to, sdd.fixed_price_currency_id) end fixed_price_currency_id,
		sdd.option_strike_price,
		round(isnull(sdd.total_volume, sdd.deal_volume), isnull(r.rounding, 100)) deal_volume,
		sdd.deal_volume_frequency, 
		isnull(spcd.display_uom_id, spcd.uom_id) deal_volume_uom_id,
		sdd.block_description,	
		coalesce(sdh.internal_deal_type_value_id, sdht.internal_deal_type_value_id, 1) internal_deal_type_value_id,
		coalesce(sdh.internal_deal_subtype_value_id, sdht.internal_deal_subtype_value_id, 1) internal_deal_subtype_value_id,
		sdd.deal_detail_description, 
		sdd.formula_id, fe.formula, 0 formula_value,
		isnull(sdd.price_adder, 0) price_adder, isnull(sdd.price_multiplier, 1) price_multiplier, --isnull(nullif(sdd.price_multiplier, 0), 1) price_multiplier, 
		sdd.day_count_id, dcd.no_days, isnull(dcd.days_year, 365) days_year, 
		isnull(sdd.settlement_date, sdd.contract_expiration_date) settlement_date, ' 
		+ @no_days_left + ' no_days_left, ' +
		@no_days_accrued + ' no_days_accrued, NULL spot_price, sbm.func_cur_value_id,
		sbm.discount_curve_id, sbm.risk_free_curve_id,
		CASE WHEN ('''+@calc_type+'''= ''s'' AND sdh.pricing=1601 AND DATEDIFF(dd, sdd.term_start, sdd.term_end)  <> DATEDIFF(dd, cast(convert(varchar(8),sdd.term_start,120) +''01'' AS datetime),
				dateadd(mm, 1,cast(convert(varchar(8),sdd.term_start,120) +''01'' AS datetime))-1)) THEN 1602
			 WHEN ('''+@calc_type+'''<> ''s'' AND sdh.pricing = 1601) THEN -1 -- For swaps always use forward price and not lag curve for swaps for example
			 ELSE isnull(sdh.pricing, -1) 
		END pricing,
		sdh.contract_id, 	
		case when (spcd.formula_id is not null) then ''y'' else ''n'' end derived_curve,
		isnull(sdd.fixed_cost, 0) fixed_cost,
		CASE WHEN (spcd.source_curve_type_value_id <> 576) THEN ISNULL(sc1.currency_id_to, spcd.source_currency_id) ELSE spcd.source_currency_to_id END curve_currency_id,
		case when (spcd.display_uom_id <> spcd.uom_id) then  spcd.uom_id else NULL end curve_uom_id,
		case when (sdd.contract_expiration_date > ''' + @curve_as_of_date + ''') then 0 else 1 end settled,
		isnull(sdd.physical_financial_flag, sdh.physical_financial_flag) leg_physical_financial_flag,
		sbm.fas_deal_type_value_id, dist.discount_factor, sdd.deal_volume contract_volume, isnull(sdd.multiplier, 1) volume_multiplier,
		isnull(sdd.volume_multiplier2, 1) volume_multiplier2, isnull(sdd.price_adder2, 0) price_adder2, isnull(sdd.pay_opposite, ''n'') pay_opposite,
		case when (isnull(sdd.price_adder, 0)=0) then NULL else ISNULL(sc7.currency_id_to, sdd.adder_currency_id) end price_adder_currency, 
		case when (isnull(sdd.price_adder2, 0)=0) then NULL else ISNULL(sc8.currency_id_to, sdd.price_adder_currency2) end price_adder2_currency, 
		case when ((sdd.formula_id IS NULL AND sdd.formula_curve_id IS NULL)OR sdd.formula_currency_id=0) then NULL else ISNULL(sc9.currency_id_to, sdd.formula_currency_id) end formula_currency, 
		case when (isnull(sdd.fixed_cost, 0)=0) then NULL else ISNULL(sc6.currency_id_to, sdd.fixed_cost_currency_id) end fixed_cost_currency, '

set @explain_sql1='				
		case when (sdd.contract_expiration_date < ''' + @curve_as_of_date + ''' AND sdh.Pricing = -1) then sdd.contract_expiration_date else 
				''' + @curve_as_of_date + ''' end exp_curve_as_of_date,
		CASE when (sdd.contract_expiration_date >= ''' + @curve_as_of_date + ''') THEN ' + @maturity_date + '
		ELSE sdd.contract_expiration_date END exp_maturity_date,
		CASE WHEN (' + cast(@assessment_curve_type_value_id as varchar) + '= 77) THEN ' + @maturity_date + '
		ELSE ''' + @as_of_date + ''' END  curve_type_maturity_date,
		ISNULL(sdh.internal_desk_id, 17300) volume_type,
		spcd.Granularity curve_granularity,isnull(sdht.hourly_position_breakdown,''n'') hourly_position_breakdown,
		spcd.monthly_index,
		sdd.location_id, isnull(sdh.product_id, 4101) product_id, ' + -- 4100 is fixation and 4101 is original
		CASE WHEN (@calc_type<>'s') THEN ' NULL option_settlement_date ' ELSE ' sdh.option_settlement_date ' END + ',
		spcd.proxy_source_curve_def_id proxy_curve_id, spcd.proxy_curve_id3, spcd.settlement_curve_id,
		sdd.formula_curve_id, sdd.settlement_Currency,
		' + @maturity_date_m + ' monthly_index_maturity,
		' + @maturity_date_p + ' proxy_curve_maturity,
		' + @maturity_date_p3 + ' proxy_curve_maturity3,
		' + @maturity_date_s + ' settlement_curve_maturity, 
		spcd_m.Granularity monthly_index_granularity, spcd_p.Granularity proxy_curve_granularity, spcd_p3.Granularity proxy_curve_granularity3, spcd_s.Granularity settlement_curve_granularity, 	
		case when (spcd_p.formula_id is not null) then ''y'' else ''n'' end proxy_derived_curve,
		case when (spcd_p3.formula_id is not null) then ''y'' else ''n'' end proxy_derived_curve3,
		case when (spcd_m.formula_id is not null) then ''y'' else ''n'' end monthly_index_derived_curve,
		case when (spcd_s.formula_id is not null) then ''y'' else ''n'' end settlement_derived_curve,
		sdd.price_uom_id,
		isnull(sc1.factor,1) curve_factor, isnull(sc2.factor,1) proxy_curve_factor, isnull(sc10.factor,1) proxy_curve_factor3, isnull(sc3.factor,1) monthly_index_factor, 
		isnull(sc4.factor,1) settlement_curve_factor, isnull(sc5.factor,1) fixed_price_cur_factor, 
		isnull(sc6.factor,1) fixed_cost_cur_factor,  isnull(sc7.factor,1) adder1_cur_factor, 
		isnull(sc8.factor,1) adder2_cur_factor, 
		CASE WHEN sdd.formula_curve_id IS NOT NULL AND '''+@calc_type+'''<>''s'' THEN 1 ELSE isnull(sc9.factor, 1) END formula_cur_factor,
		ISNULL(sc2.currency_id_to, spcd_p.source_currency_id) proxy_currency_id, ISNULL(sc10.currency_id_to, spcd_p3.source_currency_id) proxy_currency_id3, 
		ISNULL(sc3.currency_id_to, spcd_m.source_currency_id) monthly_index_currency_id, 
		ISNULL(sc4.currency_id_to, spcd_s.source_currency_id) settlement_curve_currency_id,
		' + @monthly_maturity + ',
		ISNULL(NULLIF(sdd.formula_currency_id, 0), sbm.func_cur_value_id) Original_formula_currency,
		sdd.capacity,
		CASE WHEN(sdh.product_id=4100 AND close_reference_id IS NOT NULL) THEN close_reference_id ELSE sdh.source_deal_header_id END meter_deal_id,
		ISNULL(spcd.curve_tou, -1) curve_tou,
		ISNULL(r.rounding, 100) volume_rounding,
		sdd.fixed_price_currency_id original_fixed_price_currency_id,
		NULLIF(sdd.meter_id, 0) meter_id
		' 


	CREATE TABLE #explain_mtm(
		[source_deal_header_id] [int] NOT NULL,
		[curve_id] [int] NULL,
		[location_id] [int] NULL,
		[term_start] [datetime] NULL,
		[hr] [tinyint] NULL,
		[market_ob_value] [float] NULL,
		[contract_ob_value] [float] NULL,
		[ob_mtm] [float] NULL,
		[market_new_deal] [float] NULL,
		[contract_new_deal] [float] NULL,
		[new_deal] [float] NULL,
		[market_forecast_changed] [float] NULL,
		[contract_forecast_changed] [float] NULL,
		[forecast_changed] [float] NULL,
		[market_deleted] [float] NULL,
		[contract_deleted] [float] NULL,
		[deleted] [float] NULL,
		[market_delivered] [float] NULL,
		[contract_delivered] [float] NULL,
		[delivered] [float] NULL,
		[market_cb_value] [float] NULL,
		[contract_cb_value] [float] NULL,
		[cb_mtm] [float] NULL,
		[price_changed] [float] NULL,
		[discount_factor] [float] NULL,
		[currency_id] [int] NULL,
		[create_ts] [datetime] NULL,
		[create_user] [varchar](30) COLLATE DATABASE_DEFAULT NULL,
		formula_breakdown bit,physical_financial_flag VARCHAR(1) COLLATE DATABASE_DEFAULT
	)
	CREATE TABLE #explain_mtm_ob(
		[source_deal_header_id] [int] NOT NULL,
		[curve_id] [int] NULL,
		[location_id] [int] NULL,
		[term_start] [datetime] NULL,
		[hr] [tinyint] NULL,
		[market_ob_value] [float] NULL,
		[contract_ob_value] [float] NULL,
		[ob_mtm] [float] NULL,
		[discount_factor] [float] NULL,
		[currency_id] [int] NULL,
		[create_ts] [datetime] NULL,
		[create_user] [varchar](30) COLLATE DATABASE_DEFAULT NULL,
		formula_breakdown bit,physical_financial_flag VARCHAR(1) COLLATE DATABASE_DEFAULT
	)
	CREATE TABLE #explain_mtm_final(
			[source_deal_header_id] [int] NOT NULL,
			[curve_id] [int] NULL,
			[location_id] [int] NULL,
			[term_start] [datetime] NULL,
			[hr] [tinyint] NULL,
			[market_ob_value] [float] NULL,
			[contract_ob_value] [float] NULL,
			[ob_mtm] [float] NULL,
			[market_new_deal] [float] NULL,
			[contract_new_deal] [float] NULL,
			[new_deal] [float] NULL,
			[market_forecast_changed] [float] NULL,
			[contract_forecast_changed] [float] NULL,
			[forecast_changed] [float] NULL,
			[market_deleted] [float] NULL,
			[contract_deleted] [float] NULL,
			[deleted] [float] NULL,
			[market_delivered] [float] NULL,
			[contract_delivered] [float] NULL,
			[delivered] [float] NULL,
			[market_cb_value] [float] NULL,
			[contract_cb_value] [float] NULL,
			[cb_mtm] [float] NULL,
			[price_changed] [float] NULL,
			[discount_factor] [float] NULL,
			[currency_id] [int] NULL,
			min_term datetime,max_term DATETIME,physical_financial_flag VARCHAR(1) COLLATE DATABASE_DEFAULT,
			 market_other_modify FLOAT,contract_other_modify FLOAT,other_modify FLOAT
		)

--market_ob_value----------------------------------------------------------------------------------------------------------------------------		
SET @market_ob_value='
,	CASE WHEN  hv.volume_OB_value=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
		WHEN (a.product_id=4101) THEN
			CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE 1 END *
			CASE when hv.curve_id IS NULL then
				case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
				a.deal_volume 
			ELSE
					CASE WHEN (a.pricing=1600 and ''' + @calc_type + ''' =''s'') THEN hv.volume_ob_value * ROUND(hv.avg_curve_value, ISNULL(cr.index_round_value,100)) ELSE 
						hv.market_value_ob_value -- market value is already negative if sell deal	
					END
			END	*	
			CASE when  a.curve_id is not NULL then 
				CASE when hv.curve_id IS NULL then
					case when (lcv.lag_curve_value is not null) then lcv.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
					else coalesce(atc.avg_curve_value, tc.curve_value, tc_p.curve_value, tc_m.curve_value, tc_p3.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
				ELSE
					case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)																				
				END
			ELSE 0 END 
		ELSE
			case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
			(	--Market Value	
				case when(a.pricing <> 1603) then	
					ABS(hv.volume_ob_value) * 
					round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
				else
					ABS((ISNULL(hv_c.contract_value_ob_value, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
				end
			)				
	END  as	 numeric(38,18))
END AS market_ob_value
'
---contract_ob_value-------------------------------------------------------------------------------------------------------------------
SET @contract_ob_value=',CASE WHEN  hv.volume_ob_value=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
		(			
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
					(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume ELSE
						ABS(hv.volume_ob_value) 
					END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
					((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
					(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
					(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
					(round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
					)
			 + ABS((ISNULL(hv_c.contract_value_OB_value, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
		)
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume   ELSE
				ABS(hv.volume_ob_value) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
			+ (ISNULL(hv_c.contract_value_ob_value, 0)* case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)) 
		) 					
	END  as numeric(38,18)) 
END as contract_ob_value
'
---OB_MTM	----------------------------------------------------------------------------------------------------------------	
SET @OB_MTM=',CASE WHEN  hv.volume_OB_value=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		CASE when (a.buy_sell_flag=''s'' and a.pay_opposite <> ''y'' and hv.curve_id IS NULL) then -1 else 1 end *
		(	
			( --Market Value
				CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE	1 END * 
				case when hv.curve_id IS NULL then
					case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
					a.deal_volume   --total_volume already has multiplier
				ELSE
					hv.market_value_OB_value -- market value is already negative if sell deal
				END
				*	
				case when  a.curve_id is not NULL then 
					case when hv.curve_id IS NULL then
						case when (lcv.lag_curve_value is not null) then lcv.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
						else coalesce(atc.avg_curve_value, tc.curve_value, tc_p.curve_value, tc_m.curve_value, tc_p3.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
					ELSE
						case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)							
					END
				else 0 
				end 
			)
			+case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
			(	--Contract Value		
				ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
						(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
							ABS(hv.volume_OB_value) 
						END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
						((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
						(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
						(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
						(round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
						)
			 + ABS((ISNULL(hv_c.contract_value_OB_value, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
			)
		)   
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
				ABS(hv.volume_OB_value) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
		) +
			case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
			(	--Market Value	
				case when(a.pricing <> 1603) then	
					ABS(hv.volume_ob_value) * 
					round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
				else
					ABS((ISNULL(hv_c.contract_value_ob_value, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
				end
			)				
	END as numeric(18,10)) 
END as [BeginningMTM]
'
		
----market_new_deal---------------------------------------------------------------------------------------------------------------	
SET @market_new_deal=',CASE WHEN  hv.volume_new_deal=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE 1 END *
		CASE when hv.curve_id IS NULL then
			case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
			a.deal_volume 
		ELSE
				CASE WHEN (a.pricing=1600 and ''' + @calc_type + ''' =''s'') THEN hv.volume_new_deal * ROUND(hv.avg_curve_value, ISNULL(cr.index_round_value,100)) ELSE 
					hv.market_value_new_deal -- market value is already negative if sell deal	
				END
		END	*	
		CASE when  a.curve_id is not NULL then 
			CASE when hv.curve_id IS NULL then
				case when (lcv_to.lag_curve_value is not null) then lcv_to.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
				else coalesce(atc_to.avg_curve_value, tc_to.curve_value, tc_p_to.curve_value, tc_m_to.curve_value, tc_p3_to.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
			ELSE
				case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)																				
			END
		ELSE 0 END 
	ELSE
			case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
			(	--Market Value	
				case when(a.pricing <> 1603) then	
					ABS(hv.volume_new_deal) * 
					round(isnull(f_to.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
				else
					ABS((ISNULL(hv_c.contract_value_new_deal, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
				end
			)				
	END  as	 numeric(38,18))
END AS market_new_deal
'
--contract_new_deal------------------------------------------------------------------------------------------------------------------------------	
SET @contract_new_deal=',CASE WHEN  hv.volume_new_deal=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
		(			
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
					(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume ELSE
						ABS(hv.volume_new_deal) 
					END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
					((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
					(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
					(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
					(round(isnull(f_to.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
					)
			 + ABS((ISNULL(hv_c.contract_value_new_deal, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
		)
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume   ELSE
				ABS(hv.volume_new_deal) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
			+ (ISNULL(hv_c.contract_value_new_deal, 0)* case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)) 
		) 					
	END  as numeric(38,18)) 
END AS contract_new_deal	
'
---new_deal-----------------------------------------------------------------------------------------------------------
SET @new_deal=',CASE WHEN  hv.volume_new_deal=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		CASE when (a.buy_sell_flag=''s'' and a.pay_opposite <> ''y'' and hv.curve_id IS NULL) then -1 else 1 end *
		(	
			( --Market Value
				CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE	1 END * 
				case when hv.curve_id IS NULL then
					case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
					a.deal_volume   --total_volume already has multiplier
				ELSE
					hv.market_value_new_deal -- market value is already negative if sell deal
				END
				*	
				case when  a.curve_id is not NULL then 
					case when hv.curve_id IS NULL then
						case when (lcv_to.lag_curve_value is not null) then lcv_to.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
						else coalesce(atc_to.avg_curve_value, tc_to.curve_value, tc_p_to.curve_value, tc_m_to.curve_value, tc_p3_to.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
					ELSE
						case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)							
					END
				else 0 
				end 
			)	+
			case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
			(	--Contract Value		
				ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
						(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
							ABS(hv.volume_new_deal) 
						END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
						((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
						(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
						(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
						(round(isnull(f_to.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
						) 
			 + ABS((ISNULL(hv_c.contract_value_new_deal, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
			)
		)   
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
				ABS(hv.volume_new_deal) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
			+ (ISNULL(hv_c.contract_value_new_deal, 0)* case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)) 
		) +
			case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
			(	--Market Value	
				case when(a.pricing <> 1603) then	
					ABS(hv.volume_new_deal) * 
					round(isnull(f_to.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
				else
					ABS((ISNULL(hv_c.contract_value_new_deal, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
				end
			)				
	END as numeric(18,10))
END AS [NewBusinessMTM]
'	

---market_forecast_changed---------------------------------------------------------------------------------------------------------------
SET @market_forecast_changed=',CASE WHEN  hv.volume_forecast_changed=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
		WHEN (a.product_id=4101) THEN
			CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE 1 END *
			CASE when hv.curve_id IS NULL then
				case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
				a.deal_volume 
			ELSE
					CASE WHEN (a.pricing=1600 and ''' + @calc_type + ''' =''s'') THEN hv.volume_forecast_changed * ROUND(hv.avg_curve_value, ISNULL(cr.index_round_value,100)) ELSE 
						hv.market_value_forecast_changed -- market value is already negative if sell deal	
					END
			END
			*	
			CASE when  a.curve_id is not NULL then 
				CASE when hv.curve_id IS NULL then
					case when (lcv_to.lag_curve_value is not null) then lcv_to.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
					else coalesce(atc_to.avg_curve_value, tc_to.curve_value, tc_p_to.curve_value, tc_m_to.curve_value, tc_p3_to.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
				ELSE
					case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)																				
				END
			ELSE 0 END 
		ELSE
		case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
			(	--Market Value	
				case when(a.pricing <> 1603) then	
					ABS(hv.volume_forecast_changed) * 
					round(isnull(f_to.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
				else
					ABS((ISNULL(hv_c.contract_value_forecast_changed, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
				end
			)				
	END  as	 numeric(38,18)) 
END AS market_forecast_changed
'
----contract_forecast_changed------------------------------------------------------------------------------------------------------------------
SET @contract_forecast_changed=',CASE WHEN  hv.volume_forecast_changed=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		case when (a.pay_opposite <> ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *	
		case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
		(			
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
					(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume ELSE
						ABS(hv.volume_forecast_changed) 
					END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
					((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
					(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
					(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
					(round(isnull(f_to.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
					)
			 + ABS((ISNULL(hv_c.contract_value_forecast_changed, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
		)
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume   ELSE
				ABS(hv.volume_forecast_changed) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
			+ (ISNULL(hv_c.contract_value_forecast_changed, 0)* case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)) 
		) 					
	END  as numeric(38,18))
END AS contract_forecast_changed
'
-----forecast_changed----------------------------------------------------------------------------------------		
SET @forecast_changed=',CASE WHEN  hv.volume_forecast_changed=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		CASE when (a.buy_sell_flag=''s'' and a.pay_opposite <> ''y'' and hv.curve_id IS NULL) then -1 else 1 end *
		(	
			( --Market Value
				CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE	1 END * 
				case when hv.curve_id IS NULL then
					case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
					a.deal_volume   --total_volume already has multiplier
				ELSE
					hv.market_value_forecast_changed -- market value is already negative if sell deal
				END
				*	
				case when  a.curve_id is not NULL then 
					case when hv.curve_id IS NULL then
						case when (lcv_to.lag_curve_value is not null) then lcv_to.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
						else coalesce(atc_to.avg_curve_value, tc_to.curve_value, tc_p_to.curve_value, tc_m_to.curve_value, tc_p3_to.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
					ELSE
						case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)							
					END
				else 0 
				end 
			)
			+
			case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
			(	--Contract Value		
				ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
						(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
							ABS(hv.volume_forecast_changed) 
						END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
						((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
						(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
						(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
						(round(isnull(f_to.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
						) 
			 + ABS((ISNULL(hv_c.contract_value_forecast_changed, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
			)
		)   
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
				ABS(hv.volume_forecast_changed) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
			+ (ISNULL(hv_c.contract_value_forecast_changed, 0)* case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)) 
		) +
			case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
			(	--Market Value	
				case when(a.pricing <> 1603) then	
					ABS(hv.volume_forecast_changed) * 
					round(isnull(f_to.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
				else
					ABS((ISNULL(hv_c.contract_value_forecast_changed, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
				end
			)				
	END as numeric(18,10))
END AS [Re-forecastMTM]
'
---market_deleted-------------------------------------------------------------------------------------------------------------------
SET @market_deleted=',CASE WHEN  hv.volume_deleted=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE 1 END *
		CASE when hv.curve_id IS NULL then
			case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
			a.deal_volume 
		ELSE
				CASE WHEN (a.pricing=1600 and ''' + @calc_type + ''' =''s'') THEN hv.volume_deleted * ROUND(hv.avg_curve_value, ISNULL(cr.index_round_value,100)) ELSE 
					hv.market_value_deleted -- market value is already negative if sell deal	
				END
		END	*	
		CASE when  a.curve_id is not NULL then 
			CASE when hv.curve_id IS NULL then
				case when (lcv.lag_curve_value is not null) then lcv.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
				else coalesce(atc.avg_curve_value, tc.curve_value, tc_p.curve_value, tc_m.curve_value, tc_p3.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
			ELSE
				case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)																				
			END
		ELSE 0 END 
	ELSE
		case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
			(	--Market Value	
				case when(a.pricing <> 1603) then	
					ABS(hv.volume_deleted) * 
					round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
				else
					ABS((ISNULL(hv_c.contract_value_deleted, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
				end
			)				
	END  as	 numeric(38,18))
END AS market_deleted
'
-----contract_deleted---------------------------------------------------------------------------------------------------------------------------	
SET @contract_deleted=',CASE WHEN  hv.volume_deleted=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
		(			
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
					(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume ELSE
						ABS(hv.volume_deleted) 
					END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
					((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
					(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
					(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
					(round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
					)
			 + ABS((ISNULL(hv_c.contract_value_deleted, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
		)
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume   ELSE
				ABS(hv.volume_deleted) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
			+ (ISNULL(hv_c.contract_value_deleted, 0)* case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)) 
		) 					
	END  as numeric(38,18))
END AS contract_deleted	
'	

---deleted------------------------------------------------------------------------------------------		
SET @deleted=',CASE WHEN  hv.volume_deleted=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		CASE when (a.buy_sell_flag=''s'' and a.pay_opposite <> ''y'' and hv.curve_id IS NULL) then -1 else 1 end *
		(	
			( --Market Value
				CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE	1 END * 
				case when hv.curve_id IS NULL then
					case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
					a.deal_volume   --total_volume already has multiplier
				ELSE
					hv.market_value_deleted -- market value is already negative if sell deal
				END	*	
				case when  a.curve_id is not NULL then 
					case when hv.curve_id IS NULL then
						case when (lcv.lag_curve_value is not null) then lcv.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
						else coalesce(atc.avg_curve_value, tc.curve_value, tc_p.curve_value, tc_m.curve_value, tc_p3.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
					ELSE
						case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)							
					END
				else 0 
				end 
			)+
			case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
			(	--Contract Value		
				ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
						(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
							ABS(hv.volume_deleted) 
						END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
						((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
						(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
						(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
						(round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
						) 
			 + ABS((ISNULL(hv_c.contract_value_deleted, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
			)
		)   
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
				ABS(hv.volume_deleted) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
			+ (ISNULL(hv_c.contract_value_deleted, 0)* case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)) 
		) +
		case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
		(	--Market Value	
			case when(a.pricing <> 1603) then	
				ABS(hv.volume_deleted) * 
				round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
			else
				ABS((ISNULL(hv_c.contract_value_deleted, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
			end
		)				
	END as numeric(18,10))
END AS [DeletedMTM]
'
--market_delivered----------------------------------------------------------------------------------------------
SET @market_delivered=',CASE WHEN  hv.volume_delivered=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE 1 END *
		CASE when hv.curve_id IS NULL then
			case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
			a.deal_volume 
		ELSE
				CASE WHEN (a.pricing=1600 and ''' + @calc_type + ''' =''s'') THEN hv.volume_delivered * ROUND(hv.avg_curve_value, ISNULL(cr.index_round_value,100)) ELSE 
					hv.market_value_delivered -- market value is already negative if sell deal	
				END
		END
		*	
		CASE when  a.curve_id is not NULL then 
			CASE when hv.curve_id IS NULL then
				case when (lcv.lag_curve_value is not null) then lcv.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
				else coalesce(atc.avg_curve_value, tc.curve_value, tc_p.curve_value, tc_m.curve_value, tc_p3.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
			ELSE
				case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)																				
			END
		ELSE 0 END 
	ELSE
			case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
			(	--Market Value	
				case when(a.pricing <> 1603) then	
					ABS(hv.volume_delivered) * 
					round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
				else
					ABS((ISNULL(hv_c.contract_value_delivered, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
				end
			)				
	END  as	 numeric(38,18))
END AS market_delivered
'
----contract_delivered-----------------------------------------------------------------------------------------------------------
SET @contract_delivered=',CASE WHEN  hv.volume_delivered=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
		(			
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
					(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume ELSE
						ABS(hv.volume_delivered) 
					END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
					((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
					(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
					(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
					(round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
					)
			 + ABS((ISNULL(hv_c.contract_value_delivered, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
		)
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume   ELSE
				ABS(hv.volume_delivered) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
			+ (ISNULL(hv_c.contract_value_delivered, 0)* case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)) 
		) 					
	END  as numeric(38,18))
END AS contract_delivered
'
--delivered------------------------------------------------------------------------------------------------------------		
SET @delivered=',CASE WHEN  hv.volume_delivered=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		CASE when (a.buy_sell_flag=''s'' and a.pay_opposite <> ''y'' and hv.curve_id IS NULL) then -1 else 1 end *
		(	
			( --Market Value
				CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE	1 END * 
				case when hv.curve_id IS NULL then
					case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
					a.deal_volume   --total_volume already has multiplier
				ELSE
					hv.market_value_delivered -- market value is already negative if sell deal
				END
				*	
				case when  a.curve_id is not NULL then 
					case when hv.curve_id IS NULL then
						case when (lcv.lag_curve_value is not null) then lcv.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
						else coalesce(atc.avg_curve_value, tc.curve_value, tc_p.curve_value, tc_m.curve_value, tc_p3.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
					ELSE
						case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)							
					END
				else 0 
				end 
			)	+
			case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
			(	--Contract Value		
				ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
						(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
							ABS(hv.volume_delivered) 
						END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
						((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
						(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
						(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
						(round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
						) 
			 + ABS((ISNULL(hv_c.contract_value_delivered, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
			)
		)   
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
				ABS(hv.volume_delivered) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
			+ (ISNULL(hv_c.contract_value_delivered, 0)* case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)) 
		) +
			case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
		(	--Market Value	
			case when(a.pricing <> 1603) then	
				ABS(hv.volume_delivered) * 
				round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
			else
				ABS((ISNULL(hv_c.contract_value_delivered, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
			end
		)				
	END as numeric(18,10))
END AS [DeliveryMTM]
'
----market_cb_value------------------------------------------------------------------
SET @market_cb_value=',CASE WHEN  hv.volume_cb_value=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE 1 END *
		CASE when hv.curve_id IS NULL then
			case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
			a.deal_volume 
		ELSE
				CASE WHEN (a.pricing=1600 and ''' + @calc_type + ''' =''s'') THEN hv.volume_cb_value * ROUND(hv.avg_curve_value, ISNULL(cr.index_round_value,100)) ELSE 
					hv.market_value_cb_value -- market value is already negative if sell deal	
				END
		END
		*	
		CASE when  a.curve_id is not NULL then 
			CASE when hv.curve_id IS NULL then
				case when (lcv_to.lag_curve_value is not null) then lcv_to.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
				else coalesce(atc_to.avg_curve_value, tc_to.curve_value, tc_p_to.curve_value, tc_m_to.curve_value, tc_p3_to.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
			ELSE
				case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)																				
			END
		ELSE 0 END 
	ELSE
			case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
		(	--Market Value	
			case when(a.pricing <> 1603) then	
				ABS(hv.volume_cb_value) * 
				round(isnull(f_to.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
			else
				ABS((ISNULL(hv_c.contract_value_cb_value, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
			end
		)				
	END  as	 numeric(38,18))
END AS market_cb_value
'
---contract_cb_value-------------------------------------------------------------------------------------------------------------------
SET @contract_cb_value=',CASE WHEN  hv.volume_cb_value=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
		(			
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
					(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume ELSE
						ABS(hv.volume_cb_value) 
					END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
					((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
					(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
					(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
					(round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
					)
				+ (ISNULL(hv_c.contract_value_cb_value, 0)* case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)) 
		)
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume   ELSE
				ABS(hv.volume_cb_value) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
			 + ABS((ISNULL(hv_c.contract_value_cb_value, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
		) 					
	END  as numeric(38,18))
END AS contract_cb_value	
'
---CB_MTM-----------------------------------------------------------------------------------------------------------------------------
SET @CB_MTM=',CASE WHEN  hv.volume_cb_value=0  and hv.hr<>0 THEN 0 ELSE 	
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		CASE WHEN (a.buy_sell_flag=''s'' and a.pay_opposite <> ''y'' and hv.curve_id IS NULL) then -1 else 1 end *
		(	
			( --Market Value
				CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE	1 END * 
				case when hv.curve_id IS NULL then
					case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
					a.deal_volume   --total_volume already has multiplier
				ELSE
					hv.market_value_CB_value -- market value is already negative if sell deal
				END
				*	
				case when  a.curve_id is not NULL then 
					case when hv.curve_id IS NULL then
						case when (lcv_to.lag_curve_value is not null) then lcv_to.lag_curve_value * isnull(cucf.curve_uom_conv_factor, 1)
						else coalesce(atc_to.avg_curve_value, tc_to.curve_value, tc_p_to.curve_value, tc_m_to.curve_value, tc_p3_to.curve_value) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
					ELSE
						case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)							
					END
				else 0 
				end 
			)	+
			case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''b'') then -1 else 1 end *					
			(	--Contract Value		
				ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
						(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
							ABS(hv.volume_CB_value) 
						END * 	--case when a.buy_sell_flag=''s'' then -1 else 1 end 
						((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
						(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
						(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
						(round(isnull(f_to.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
						) 
			 + ABS((ISNULL(hv_c.contract_value_cb_value, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
			)
		)   
	ELSE
		case when (a.buy_sell_flag=''b'') then -1 else 1 end *					
		( -- contract value	
			ISNULL(a.fixed_cost, 0)*ISNULL(fixed_cost_cur_factor, 1) * isnull(fcucf.price_fx_conv_factor, 1) +
			(CASE WHEN hv.curve_id IS NULL THEN a.deal_volume  ELSE
				ABS(hv.volume_CB_value) 
			END * 	
			((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
			(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
			(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
			)
			+ (ISNULL(hv_c.contract_value_CB_value, 0)* case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)) 
		) +
			case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
		(	--Market Value	
			case when(a.pricing <> 1603) then	
				ABS(hv.volume_cb_value) * 
				round(isnull(f_to.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
			else
				ABS((ISNULL(hv_c.contract_value_cb_value, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
			end
		)				
	END as numeric(18,10))
END as [EndingMTM]
'
--price_changed------------------------------------------------------------------------------------		
SET @price_changed=',CASE WHEN ( hv.volume_OB_value=0  and hv.hr<>0 )OR (
		CASE when  a.curve_id is not NULL then 
			CASE when hv.curve_id IS NULL then
				case when (ISNULL(lcv.lag_curve_value,lcv_to.lag_curve_value) is not null) 
				then 
					(lcv_to.lag_curve_value-lcv.lag_curve_value)
				else 
					(coalesce(atc_to.avg_curve_value, tc_to.curve_value, tc_p_to.curve_value, tc_m_to.curve_value, tc_p3_to.curve_value)-coalesce(atc.avg_curve_value, tc.curve_value, tc_p.curve_value, tc_m.curve_value, tc_p3.curve_value)) 
				END 
			ELSE
				case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)																				
			END
		ELSE 0 END )=0 OR ISNULL(hv.monthly_term_end,hv_c.monthly_term_end)<='''+ convert(varchar(10),@curve_as_of_date,120) +'''  
	THEN 0 ELSE 
	cast(CASE WHEN (a.fas_deal_type_value_id = 409) THEN 0 
	WHEN (a.product_id=4101) THEN
		CASE WHEN (a.physical_financial_flag=''p'' and ''' + @calc_type + ''' =''s'') THEN 0 ELSE 1 END *
		CASE when hv.curve_id IS NULL then
			case when (a.pay_opposite = ''y'' and a.buy_sell_flag=''s'') then -1 else 1 end *					
			a.deal_volume 
		ELSE
				CASE WHEN (a.pricing=1600 and ''' + @calc_type + ''' =''s'') THEN abs(hv.volume_ob_value) * ROUND(hv.avg_curve_value, ISNULL(cr.index_round_value,100)) ELSE 
					hv.curve_value_price_changed_value -- market value is already negative if sell deal	
				END
		END		*	
		CASE when  a.curve_id is not NULL then 
			CASE when hv.curve_id IS NULL then
				case when (ISNULL(lcv.lag_curve_value,lcv_to.lag_curve_value) is not null) then (lcv_to.lag_curve_value-lcv.lag_curve_value) * isnull(cucf.curve_uom_conv_factor, 1)
				else (coalesce(atc_to.avg_curve_value, tc_to.curve_value, tc_p_to.curve_value, tc_m_to.curve_value)-coalesce(atc.avg_curve_value, tc.curve_value, tc_p.curve_value, tc_m.curve_value)) * isnull(cucf.curve_uom_conv_factor, 1) * isnull(cfcf.price_fx_conv_factor, 1) end
			ELSE
				case when (a.Pricing not in (1601,1602)) then isnull(cfcf.price_fx_conv_factor, 1)  else 1 end * isnull(cucf.curve_uom_conv_factor, 1)																				
			END
		ELSE 0 END 
	ELSE
			case when (a.buy_sell_flag=''b'') then 1 else -1 end *					
			(	--Market Value	
				case when(a.pricing <> 1603) then	
					ABS(hv.volume_ob_value) * 
					round(isnull(f_to.formula_value, 0)-isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1) * isnull(cucfP.curve_uom_conv_factor, 1)
				else
					ABS((ISNULL(hv_c.contract_value_ob_value, 0)* case when (a.Pricing not in (1601,1602)) then ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1)  else 1 end * isnull(cucfP.curve_uom_conv_factor, 1))) 		
				end
			)						
	END  as	 numeric(38,18))
END as [PriceChangedMTM]
'	


SET @fields='a.source_deal_header_id [Deal ID],	a.curve_id,	isnull(a.location_id,-1) location_id,ISNULL(hv.monthly_term_end,hv_c.monthly_term_end) term_start,
	--a.term_start,
	--ISNULL(hv.monthly_term_end,hv_c.monthly_term_end) term_end,
	ISNULL(hv.hr,hv_c.hr) hr
/*
,a.fixed_price
	,ISNULL(a.fixed_cost, 0) fixed_cost,
		hv.volume_ob_value,
		hv.volume_new_deal,
		hv.volume_modify_deal,
		hv.volume_forecast_changed,
		hv.volume_deleted,
		hv.volume_delivered,
		hv.volume_cb_value,
	 
		((isnull(a.fixed_price, 0)*isnull(a.fixed_price_cur_factor, 1)*coalesce(lfx.price_fx_conv_factor, pfcf.price_fx_conv_factor, 1)*isnull(a.price_multiplier, 1)) + 
		(isnull(a.price_adder, 0)*ISNULL(adder1_cur_factor, 1)*isnull(pa1ucf.price_fx_conv_factor, 1)) + 
		(isnull(a.price_adder2, 0)*ISNULL(adder2_cur_factor, 1)*isnull(pa2ucf.price_fx_conv_factor, 1)) + 
		(round(isnull(f.formula_value, 0), isnull(cfr.formula_rounding, 100))*ISNULL(formula_cur_factor, 1)*isnull(foucf.price_fx_conv_factor, 1))) * isnull(cucfP.curve_uom_conv_factor, 1)
	contract_price,
	hv.avg_curve_value 	price_curve_from	,	
	hv.avg_curve_value_to price_curve_to
	
--	*/	
'

declare @deal_header_source varchar(120),@deal_detail_source varchar(120),@ob_calc varchar(1)
select  @deal_header_source='#source_deal_header',@deal_detail_source='#source_deal_detail',@ob_calc='n'

while 1=1
begin

--#region Drop Temporary table

	if OBJECT_ID('tempdb..#fx_curve_ids') is not null	
		DROP TABLE #fx_curve_ids
		
	if OBJECT_ID('tempdb..#temp_deals') is not null	
		DROP TABLE #temp_deals

	if OBJECT_ID('tempdb..#tx') is not null
		DROP TABLE #tx
		
	if OBJECT_ID('tempdb..#fx_curves') is not null
		DROP TABLE #fx_curves
		
	if OBJECT_ID('tempdb..#lag_curves') is not null
		DROP TABLE #lag_curves		
	
	if OBJECT_ID('tempdb..#lag_curves_values_fx') is not null
		DROP TABLE #lag_curves_values_fx
		
	if OBJECT_ID('tempdb..#hrly_price_curves_to') is not null
		DROP TABLE #hrly_price_curves_to
		
	if OBJECT_ID('tempdb..#hrly_price_curves') is not null
		DROP TABLE #hrly_price_curves
		
	if OBJECT_ID('tempdb..#lag_curves_values_to') is not null
		DROP TABLE #lag_curves_values_to
		
	if OBJECT_ID('tempdb..#lag_curves_values') is not null
		DROP TABLE #lag_curves_values
		
	if OBJECT_ID('tempdb..#avg_temp_curves_to') is not null
		DROP TABLE #avg_temp_curves_to
		
	if OBJECT_ID('tempdb..#avg_temp_curves') is not null
		DROP TABLE #avg_temp_curves
		
	if OBJECT_ID('tempdb..#cids') is not null
		DROP TABLE #cids
		
	if OBJECT_ID('tempdb..#temp_curves_to') is not null
		DROP TABLE #temp_curves_to
		
	if OBJECT_ID('tempdb..#temp_curves') is not null
		DROP TABLE #temp_curves
		
	if OBJECT_ID('tempdb..#formula_value_to') is not null
		DROP TABLE #formula_value_to	
		
	if OBJECT_ID('tempdb..#as_of_date_to') is not null
		DROP TABLE #as_of_date_to
		

	if OBJECT_ID('tempdb..#formula_value') is not null
		DROP TABLE #formula_value
			
	if OBJECT_ID('tempdb..#cids_derived') is not null
		DROP TABLE #cids_derived
		
	if OBJECT_ID('tempdb..#uom_ids') is not null
		DROP TABLE #uom_ids
		
	if OBJECT_ID('tempdb..#curve_uom_conv_factor') is not null
		DROP TABLE #curve_uom_conv_factor

	if OBJECT_ID('tempdb..#formula_value2_to') is not null
		DROP TABLE #formula_value2_to
		
	if OBJECT_ID('tempdb..#formula_value2') is not null
		DROP TABLE #formula_value2
		
	if OBJECT_ID('tempdb..#tmp_hourly_price_vol_c') is not null
		DROP TABLE #tmp_hourly_price_vol_c
		
	if OBJECT_ID('tempdb..#tmp_hourly_price_vol') is not null
		DROP TABLE #tmp_hourly_price_vol
		
	if OBJECT_ID('tempdb..#tx2') is not null
		DROP TABLE #tx2
		
	if OBJECT_ID('tempdb..#hrl_pos_c') is not null
		DROP TABLE #hrl_pos_c
		
	if OBJECT_ID('tempdb..#hrl_pos') is not null
		DROP TABLE #hrl_pos
--#endregion


--#region create temporary table


	create table #temp_deals(
		[temp_deal_id] [int] identity(1,1),
		[source_deal_header_id] [int]  NOT NULL ,
		[source_deal_detail_id] [int]  NOT NULL ,
		[source_system_id] [int] NOT NULL ,
		[deal_id] [varchar] (50) COLLATE DATABASE_DEFAULT NOT NULL ,
		[deal_date] [datetime] NOT NULL ,
		[ext_deal_id] [varchar] (50) COLLATE DATABASE_DEFAULT NULL ,
		[physical_financial_flag] [char] (10) COLLATE DATABASE_DEFAULT NOT NULL ,
		[structured_deal_id] [varchar] (50) COLLATE DATABASE_DEFAULT NULL ,
		[counterparty_id] [int] NOT NULL ,
		[entire_term_start] [datetime] NOT NULL ,
		[entire_term_end] [datetime] NOT NULL ,
		[source_deal_type_id] [int] NOT NULL ,
		[deal_sub_type_type_id] [int] NULL ,
		[option_flag] [char] (1) COLLATE DATABASE_DEFAULT NOT NULL ,
		[option_type] [char] (1) COLLATE DATABASE_DEFAULT NULL ,
		[option_excercise_type] [char] (1) COLLATE DATABASE_DEFAULT NULL ,
		[source_system_book_id1] [int] NOT NULL ,
		[source_system_book_id2] [int] NULL ,
		[source_system_book_id3] [int] NULL ,
		[source_system_book_id4] [int] NULL ,
		[description1] [varchar] (100) COLLATE DATABASE_DEFAULT NULL ,
		[description2] [varchar] (50) COLLATE DATABASE_DEFAULT NULL ,
		[description3] [varchar] (50) COLLATE DATABASE_DEFAULT NULL ,
		[deal_category_value_id] [int] NOT NULL,
		[trader_id] [int] NOT NULL,
		[maturity_date] [datetime] NOT NULL,
		[term_start] [datetime] NOT NULL ,
		[term_end] [datetime] NOT NULL ,
		[Leg] [int] NOT NULL ,
		[contract_expiration_date] [datetime] NOT NULL ,
		[fixed_float_leg] [char] (1) COLLATE DATABASE_DEFAULT NOT NULL ,
		[buy_sell_flag] [char] (1) COLLATE DATABASE_DEFAULT  NOT NULL ,
		[curve_id] [int] NULL ,
		[fixed_price] [float] NULL ,
		[fixed_price_currency_id] [int] NULL ,
		[option_strike_price] [float] NULL ,
		[deal_volume] [float]  NULL ,
		[deal_volume_frequency] [char] (1) COLLATE DATABASE_DEFAULT NOT NULL ,
		[deal_volume_uom_id] [int] NULL ,
		[block_description] [varchar] (100) COLLATE DATABASE_DEFAULT NULL ,
		[internal_deal_type_value_id] INT  NULL , -- 17 is storage ACTUAL,  20 is nomination and 21 is scheduled which will be processed
		[internal_deal_subtype_value_id] INT  NULL, -- 12 is lagging,19 is Storage Actual, 20 Storage Nom, 21 Storage Scheduled 
		[deal_detail_description] [varchar] (100) COLLATE DATABASE_DEFAULT NULL,
		formula_id int NULL,
		[formula] varchar(6000) COLLATE DATABASE_DEFAULT NULL,
		[formula_value] float NULL,
		[price_adder] float NULL, 
		[price_multiplier] float NULL,
		[day_count_id] int NULL,
		[no_days] int NULL,
		[days_year] int NULL,
		[settlement_date] datetime NULL,
		[no_days_left] float NULL,
		[no_days_accrued] float NULL,
		[spot_price] float NULL,
		[func_cur_id] float NULL,
		[discount_curve_id] int NULL,
		[risk_free_curve_id] int NULL,
		pricing int NULL, --1600 is avg pricing,
		contract_id int NULL,
		derived_curve varchar(1) COLLATE DATABASE_DEFAULT,
		fixed_cost float,
		curve_currency_id int,
		curve_uom_id int,
		settled int, -- 1 means yes and 0 means no
		leg_physical_financial_flag varchar(1) COLLATE DATABASE_DEFAULT NULL,
		fas_deal_type_value_id int,
		discount_factor float,
		contract_volume float, 
		volume_multiplier float,
		volume_multiplier2 float,
		price_adder2 float,
		pay_opposite varchar(1) COLLATE DATABASE_DEFAULT,
		price_adder_currency int,
		price_adder2_currency int,
		formula_currency int,
		fixed_cost_currency int,
		exp_curve_as_of_date datetime,
		exp_maturity_date datetime,
		curve_type_maturity_date datetime,
		volume_type INT, -- Deal Volume (17300)   Forecasted (17301) Shaped (17302)
		curve_granularity INT, --982 is hourly
		hourly_position_breakdown VARCHAR(1) COLLATE DATABASE_DEFAULT,
		monthly_index INT,
		location_id INT,
		product_id INT,
		option_settlement_date DATETIME,
		proxy_curve_id  INT,
		proxy_curve_id3  INT,
		settlement_curve_id INT,
		formula_curve_id INT,
		settlement_currency INT,
		monthly_index_maturity DATETIME,
		proxy_curve_maturity DATETIME,
		proxy_curve_maturity3 DATETIME,
		settlement_curve_maturity DATETIME, 
		monthly_index_granularity INT,
		proxy_curve_granularity INT,
		proxy_curve_granularity3 INT,
		settlement_curve_granularity INT,
		proxy_derived_curve varchar(1) COLLATE DATABASE_DEFAULT,
		proxy_derived_curve3 varchar(1) COLLATE DATABASE_DEFAULT,
		monthly_index_derived_curve varchar(1) COLLATE DATABASE_DEFAULT, 
		settlement_derived_curve varchar(1) COLLATE DATABASE_DEFAULT,
		price_uom_id INT,
		curve_factor float, 
		proxy_curve_factor float,
		proxy_curve_factor3 float,
		monthly_index_factor float,
		settlement_curve_factor float,
		fixed_price_cur_factor float,
		fixed_cost_cur_factor float, 
		adder1_cur_factor float,
		adder2_cur_factor float,
		formula_cur_factor float,
		proxy_currency_id int,
		proxy_currency_id3 int,
		monthly_index_currency_id int, 
		settlement_curve_currency_id int,
		monthly_maturity datetime,
		original_formula_currency INT,
		capacity FLOAT,
		meter_deal_id INT,
		curve_tou INT,
		volume_rounding INT,
		original_fixed_price_currency_id INT,
		meter_id INT 
		) 


	CREATE TABLE #tx([ID] INT IDENTITY, as_of_date DATETIME, term_start DATETIME, formula_id INT, granularity INT, contract_id INT, source_deal_detail_id INT)		

	CREATE TABLE #formula_value (term_start datetime, formula_id INT, contract_expiration_date datetime, formula_value float,contract_id INT, source_deal_detail_id INT)
	CREATE TABLE #cids_derived (curve_id INT, maturity_date DATETIME, as_of_date DATETIME, pnl_as_of_date DATETIME, curve_granularity INT)
	CREATE TABLE #uom_ids (curve_uom_id INT, deal_volume_uom_id INT) 
	CREATE TABLE #as_of_date_to(as_of_date_to DATETIME)
	CREATE TABLE #fx_curves (fx_currency_id INT, func_cur_id INT, source_system_id INT, as_of_date DATETIME, 
				maturity_date DATETIME, price_fx_conv_factor FLOAT)
	--INSERT UNIQUE CURRENCIES FROM WHICH WE NEED CONVERSIONS
	CREATE TABLE #fx_curve_ids (fx_currency_id INT, exp_curve_as_of_date DATETIME, source_system_id INT, func_cur_id INT)
	CREATE TABLE #curve_uom_conv_factor (curve_uom_id INT, deal_volume_uom_id INT, curve_uom_conv_factor FLOAT)

	CREATE TABLE #formula_value_to (term_start datetime, formula_id INT, contract_expiration_date datetime, formula_value float,contract_id INT,source_deal_detail_id int)

	CREATE TABLE #temp_curves(
		[source_curve_def_id] [int] NOT NULL,
		[as_of_date] [datetime] NOT NULL,
		[Assessment_curve_type_value_id] [int] NOT NULL,
		[curve_source_value_id] [int] NOT NULL,
		[maturity_date] [datetime] NOT NULL,
		is_dst bit,
		[curve_value] [float] NOT NULL,
		[pnl_as_of_date] [datetime] NOT NULL,
		curve_granularity INT
	) 

	CREATE TABLE #temp_curves_to(
		[source_curve_def_id] [int] NOT NULL,
		[as_of_date] [datetime] NOT NULL,
		[Assessment_curve_type_value_id] [int] NOT NULL,
		[curve_source_value_id] [int] NOT NULL,
		[maturity_date] [datetime] NOT NULL,
		is_dst bit,
		[curve_value] [float] NOT NULL,
		[pnl_as_of_date] [datetime] NOT NULL,
		curve_granularity INT
	) 

	CREATE TABLE #cids (curve_id INT, maturity_date DATETIME, as_of_date DATETIME, pnl_as_of_date DATETIME, curve_granularity INT, factor FLOAT)

	CREATE TABLE #avg_temp_curves(source_deal_header_id int, leg INT , curve_id INT ,min_term_start DATETIME, max_term_end DATETIME, 
			avg_curve_value FLOAT , curve_granularity INT )

	CREATE TABLE #avg_temp_curves_to(source_deal_header_id int, leg INT , curve_id INT ,min_term_start DATETIME, max_term_end DATETIME, 
			avg_curve_value FLOAT , curve_granularity INT )

	CREATE TABLE #lag_curves_values(curve_id INT ,term_start DATETIME,term_end DATETIME,contract_id INT , func_cur_id INT, lag_curve_value FLOAT )
	CREATE TABLE #lag_curves_values_to (curve_id INT ,term_start DATETIME,term_end DATETIME,contract_id INT , func_cur_id INT, lag_curve_value FLOAT )

	CREATE TABLE #hrly_price_curves (
		curve_id INT ,as_of_date DATETIME,Assessment_curve_type_value_id INT ,curve_source_value_id INT 
		,curve_value FLOAT ,Granularity INT , maturity_date DATETIME , hr TINYINT 
	)

	CREATE TABLE #hrly_price_curves_to (
		curve_id INT ,as_of_date DATETIME,Assessment_curve_type_value_id INT ,curve_source_value_id INT 
		,curve_value FLOAT ,Granularity INT , maturity_date DATETIME , hr TINYINT 
	)
--#endregion



	set @from_clause = '
		FROM   '+@deal_header_source+' sdh with(nolock) inner join 
			   '+@deal_detail_source+' sdd with(nolock) ON sdh.source_deal_header_id = sdd.source_deal_header_id 
		inner join #books sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
			   sdh.source_system_book_id2 = sbm.source_system_book_id2 AND sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
			   sdh.source_system_book_id4 = sbm.source_system_book_id4 			
		 LEFT OUTER JOIN  formula_editor fe ON sdd.formula_id = fe.formula_id   LEFT OUTER JOIN
		source_deal_header_template sdht on sdht.template_id = sdh.template_id  LEFT OUTER JOIN
		days_count_def dcd on dcd.value_id = sdd.day_count_id LEFT OUTER JOIN 
		source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id LEFT OUTER JOIN 
		source_price_curve_def spcd_p ON spcd_p.source_curve_def_id = spcd.proxy_source_curve_def_id LEFT OUTER JOIN 
		source_price_curve_def spcd_m ON spcd_m.source_curve_def_id = spcd.monthly_index LEFT OUTER JOIN 
		source_price_curve_def spcd_s ON spcd_s.source_curve_def_id = spcd.settlement_curve_id LEFT OUTER JOIN 
		source_price_curve_def spcd_p3 ON spcd_p3.source_curve_def_id = spcd.proxy_curve_id3 LEFT OUTER JOIN 
		source_currency sc1 ON sc1.source_currency_id = spcd.source_currency_id LEFT OUTER JOIN
		source_currency sc2 ON sc2.source_currency_id = spcd_p.source_currency_id LEFT OUTER JOIN
		source_currency sc3 ON sc3.source_currency_id = spcd_m.source_currency_id LEFT OUTER JOIN
		source_currency sc4 ON sc4.source_currency_id = spcd_s.source_currency_id LEFT OUTER JOIN
		source_currency sc5 ON sc5.source_currency_id = sdd.fixed_price_currency_id LEFT OUTER JOIN
		source_currency sc6 ON sc6.source_currency_id = sdd.fixed_cost_currency_id LEFT OUTER JOIN
		source_currency sc7 ON sc7.source_currency_id = sdd.adder_currency_id LEFT OUTER JOIN
		source_currency sc8 ON sc8.source_currency_id = sdd.price_adder_currency2 LEFT OUTER JOIN
		source_currency sc9 ON sc9.source_currency_id = sdd.formula_currency_id LEFT OUTER JOIN			
		source_currency sc10 ON sc10.source_currency_id = spcd_p3.source_currency_id LEFT OUTER JOIN
		vol_value_rounding r ON r.contract_id = sdh.contract_id AND r.item_type = ''v'' AND r.field_id = -1 LEFT OUTER JOIN 
		inventory_account_type iat ON iat.location_id = sdd.location_id LEFT OUTER JOIN 
		#calcprocess_inventory_wght_avg_cost_forward wacog ON wacog.gl_account_id = iat.gl_account_id AND
		wacog.term_date = sdd.term_start AND sdd.buy_sell_flag = ''b'' 
					AND sdh.internal_deal_type_value_id IN(17,19,20,21) 
					LEFT OUTER JOIN 						
		'+	@DiscountTableName + ' dist ON ' +
			CASE WHEN (@is_discount_curve_a_factor IN (2)) THEN ' dist.source_deal_header_id = sdd.source_deal_header_id AND dist.term_start = sdd.term_start '
			ELSE  ' dist.fas_subsidiary_id = sbm.fas_sub_id AND dist.term_start = sdd.term_start ' END  

	print @explain_sql 
	print @explain_sql1 
	print @from_clause

	exec(@explain_sql+@explain_sql1 + @from_clause)


--################ For Storage, if Actual deal exists then delete the nomination deals for that day
	exec('DELETE td FROM #temp_deals td
	INNER JOIN '+@deal_header_source+' sdh ON sdh.close_reference_id=td.source_deal_header_id
		AND td.internal_deal_type_value_id=20
	INNER JOIN #temp_deals td1 ON td1.source_deal_header_id=sdh.source_deal_header_id
		AND td.term_start=td1.term_start AND td1.deal_volume<>0')	

---################

	create index indx_derived_curve_settled_temp_deals on #temp_deals (derived_curve,settled )
	create index indx_curve_id_temp_deals on #temp_deals (curve_id )
	create index indx_maturity_date_temp_deals on #temp_deals (maturity_date )
	--create index indx_contract_expiration_date_temp_deals on #temp_deals (maturity_date )
	create index indx_internal_deal_type_value_id_temp_deals on #temp_deals (internal_deal_type_value_id )
	create index indx_contract_expiration_date_temp_deals on #temp_deals (contract_expiration_date )
	create index indx_source_deal_header_id_temp_deals on #temp_deals (source_deal_header_id,term_end,Leg )
	create index indx_curve_type_maturity_date_temp_deals on #temp_deals (curve_type_maturity_date )
	--create index indx_term_start_temp_deals on #temp_deals (term_start )
	create index indx_exp_curve_as_of_date_temp_deals on #temp_deals (exp_curve_as_of_date )

	

	-----------------------------------------------update formula values -----------------------
	-------------------------------------------------------------------------------------------


	create index indx_curve_uom_id_temp_deals on #temp_deals (curve_uom_id)
	create index indx_deal_volume_uom_id_deals on #temp_deals (deal_volume_uom_id)

	--Get conversion factor between curve uom and volume uom of the deal leg 
	INSERT INTO #uom_ids
	SELECT curve_uom_id, deal_volume_uom_id 
	FROM #temp_deals td
	WHERE td.curve_uom_id <> td.deal_volume_uom_id
	GROUP BY curve_uom_id, deal_volume_uom_id 

	INSERT INTO #uom_ids
	SELECT DISTINCT price_uom_id, deal_volume_uom_id 
	FROM #temp_deals td
	WHERE isnull(td.price_uom_id, -1) <> isnull(td.deal_volume_uom_id, -1) AND 
			td.curve_uom_id <> isnull(td.price_uom_id, -1)
	GROUP BY price_uom_id, deal_volume_uom_id 


	-- convert position uom to curve uom
	INSERT INTO #curve_uom_conv_factor
	SELECT DISTINCT curve_uom_id, deal_volume_uom_id, vuc.conversion_factor curve_uom_conv_factor
	FROM #uom_ids u INNER JOIN
	rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id = u.deal_volume_uom_id   AND
										vuc.to_source_uom_id = u.curve_uom_id 

	CREATE index indx_curve_uom_conv_factor ON #curve_uom_conv_factor (deal_volume_uom_id,curve_uom_id )


	create index indx_fixed_price_currency_id_temp_deals on #temp_deals (fixed_price_currency_id)
	create index indx_func_cur_id_temp_deals1 on #temp_deals (func_cur_id)

	INSERT INTO #fx_curve_ids 
	select fixed_price_currency_id fx_currency_id, exp_curve_as_of_date, source_system_id, max(func_cur_id) func_cur_id
	from #temp_deals WHERE fixed_price_currency_id <> func_cur_id AND  fixed_price_currency_id is not null
	group by fixed_price_currency_id, exp_curve_as_of_date, source_system_id
	--having fixed_price_currency_id is not null

	create index indx_fixed_cost_currency_temp_deals on #temp_deals (fixed_cost_currency)

	INSERT INTO #fx_curve_ids 
	SELECT a.* from 
	(
		select fixed_cost_currency fx_currency_id, exp_curve_as_of_date, source_system_id, max(func_cur_id) func_cur_id
		from #temp_deals WHERE fixed_cost_currency <> func_cur_id AND fixed_cost_currency is NOT NULL
		group by fixed_cost_currency, exp_curve_as_of_date, source_system_id
		--having fixed_cost_currency is NOT NULL
	) a left join
		#fx_curve_ids f on f.fx_currency_id = a.fx_currency_id and f.exp_curve_as_of_date = a.exp_curve_as_of_date and
			f.source_system_id = a.source_system_id and f.func_cur_id = a.func_cur_id
	where f.fx_currency_id IS NULL

	create index indx_formula_currency_temp_deals on #temp_deals (formula_currency)

	INSERT INTO #fx_curve_ids 
	SELECT a.* from 
	(
		select formula_currency fx_currency_id, exp_curve_as_of_date, source_system_id, max(func_cur_id) func_cur_id 
		from #temp_deals WHERE formula_currency <> func_cur_id AND formula_currency is NOT NULL
		group by formula_currency, exp_curve_as_of_date, source_system_id
		--having formula_currency is NOT NULL
	) a left join
		#fx_curve_ids f on f.fx_currency_id = a.fx_currency_id and f.exp_curve_as_of_date = a.exp_curve_as_of_date and
			f.source_system_id = a.source_system_id and f.func_cur_id = a.func_cur_id
	where f.fx_currency_id IS NULL

	create index indx_price_adder_currency_temp_deals on #temp_deals (price_adder_currency)
	create index indx_price_adder2_currency_temp_deals on #temp_deals (price_adder2_currency)
	create index indx_curve_currency_id_temp_deals on #temp_deals (curve_currency_id)

	INSERT INTO #fx_curve_ids 
	SELECT a.* from 
	(
		select price_adder_currency fx_currency_id, exp_curve_as_of_date, source_system_id, max(func_cur_id) func_cur_id 
		from #temp_deals WHERE price_adder_currency <> func_cur_id AND price_adder_currency is NOT NULL
		group by price_adder_currency, exp_curve_as_of_date, source_system_id
		--having price_adder_currency is NOT NULL
	) a left join
		#fx_curve_ids f on f.fx_currency_id = a.fx_currency_id and f.exp_curve_as_of_date = a.exp_curve_as_of_date and
			f.source_system_id = a.source_system_id and f.func_cur_id = a.func_cur_id
	where f.fx_currency_id IS NULL

	INSERT INTO #fx_curve_ids 
	SELECT a.* from 
	(
		select price_adder2_currency fx_currency_id, exp_curve_as_of_date, source_system_id, max(func_cur_id) func_cur_id 
		from #temp_deals WHERE price_adder2_currency <> func_cur_id AND price_adder2_currency is NOT NULL
		group by price_adder2_currency, exp_curve_as_of_date, source_system_id
		--having price_adder2_currency is NOT NULL
	) a left join
		#fx_curve_ids f on f.fx_currency_id = a.fx_currency_id and f.exp_curve_as_of_date = a.exp_curve_as_of_date and
			f.source_system_id = a.source_system_id and f.func_cur_id = a.func_cur_id
	where f.fx_currency_id IS NULL


	INSERT INTO #fx_curve_ids 
	SELECT a.* from 
	(
		select curve_currency_id fx_currency_id, exp_curve_as_of_date, source_system_id, max(func_cur_id) func_cur_id 
		from #temp_deals WHERE curve_currency_id <> func_cur_id AND curve_currency_id is NOT NULL
		group by curve_currency_id, exp_curve_as_of_date, source_system_id
		UNION 
		select proxy_currency_id fx_currency_id, exp_curve_as_of_date, source_system_id, max(func_cur_id) func_cur_id 
		from #temp_deals WHERE proxy_currency_id <> func_cur_id AND proxy_currency_id is NOT NULL
		group by proxy_currency_id, exp_curve_as_of_date, source_system_id
		UNION 
		select proxy_currency_id3 fx_currency_id, exp_curve_as_of_date, source_system_id, max(func_cur_id) func_cur_id 
		from #temp_deals WHERE proxy_currency_id3 <> func_cur_id AND proxy_currency_id3 is NOT NULL
		group by proxy_currency_id3, exp_curve_as_of_date, source_system_id	
		UNION 
		select monthly_index_currency_id fx_currency_id, exp_curve_as_of_date, source_system_id, max(func_cur_id) func_cur_id 
		from #temp_deals WHERE monthly_index_currency_id <> func_cur_id AND monthly_index_currency_id is NOT NULL
		group by monthly_index_currency_id, exp_curve_as_of_date, source_system_id
		UNION 
		select settlement_curve_currency_id fx_currency_id, exp_curve_as_of_date, source_system_id, max(func_cur_id) func_cur_id 
		from #temp_deals WHERE settlement_curve_currency_id <> func_cur_id AND settlement_curve_currency_id is NOT NULL
		group by settlement_curve_currency_id, exp_curve_as_of_date, source_system_id
		--having curve_currency_id is NOT NULL
	) a left join
		#fx_curve_ids f on f.fx_currency_id = a.fx_currency_id and f.exp_curve_as_of_date = a.exp_curve_as_of_date and
			f.source_system_id = a.source_system_id and f.func_cur_id = a.func_cur_id
	where f.fx_currency_id IS NULL

	CREATE index indx_fx_curve_ids ON #fx_curve_ids ( source_system_id,fx_currency_id, func_cur_id)
	CREATE index indx_exp_curve_as_of_date_curve_ids ON #fx_curve_ids ( exp_curve_as_of_date )

	-- only pick forward monthly value for mtm calculation
	INSERT INTO #fx_curves
	SELECT fc.fx_currency_id, fc.func_cur_id, fc.source_system_id, COALESCE(spc.as_of_date, spc2.as_of_date), COALESCE(spc.maturity_date, spc2.maturity_date), 
				COALESCE(spc.curve_value, 1/NULLIF(spc2.curve_value,0)) price_fx_conv_factor
	from #fx_curve_ids fc LEFT OUTER JOIN
	source_price_curve_def spcd ON	spcd.source_system_id = fc.source_system_id  and spcd.source_currency_id = fc.fx_currency_id AND
									spcd.source_currency_to_ID = fc.func_cur_id and
									spcd.Granularity=980
	LEFT JOIN source_price_curve_def spcd2 ON	spcd2.source_system_id = fc.source_system_id  and spcd2.source_currency_id = fc.func_cur_id AND
									spcd2.source_currency_to_ID = fc.fx_currency_id	and
									spcd2.Granularity=980					
	LEFT JOIN source_price_curve spc ON	spc.source_curve_def_id = spcd.source_curve_def_id AND
								spc.as_of_date = fc.exp_curve_as_of_date AND
								spc.curve_source_value_id = @curve_source_value_id 							
	LEFT JOIN source_price_curve spc2 ON	spc2.source_curve_def_id = spcd2.source_curve_def_id AND
								spc2.as_of_date = fc.exp_curve_as_of_date AND
								spc2.curve_source_value_id = @curve_source_value_id 
	WHERE COALESCE(spc.maturity_date, spc2.maturity_date) IS NOT NULL  AND @calc_type <> 's'

	-- SELECT * FROM #lag_curves_values_fx
	--NOW calcualte avg fx curves using lag curves
	select  fixed_price_currency_id fx_currency_id, func_cur_id, source_system_id, exp_curve_as_of_date as_of_date,
			cast(year(term_start) as varchar) + '-' + cast(month(term_start) as varchar) + '-01' maturity_date,
			POWER(NULLIF( CASE WHEN pricing = 1602 THEN 
					dbo.FNAPartialAvgCurve(term_start,term_end,@curve_as_of_date,@curve_source_value_id,contract_id, fx_curve_id,NULL)
				WHEN pricing = 1601 AND @as_of_date < term_end THEN
					dbo.FNAPartialAvgCurve(term_start,@as_of_date,@curve_as_of_date,@curve_source_value_id,contract_id, fx_curve_id,NULL)
			 ELSE 
				dbo.FNARCLagcurve(term_start, @curve_as_of_date, @curve_source_value_id,contract_id, fx_curve_id, 0, 0, 0, 1, NULL, 0, 1, NULL, NULL) END, 0),
				opposite) price_fx_conv_factor,
			term_start, term_end
	INTO #lag_curves_values_fx
	from 
	(select a.fixed_price_currency_id, a.exp_curve_as_of_date, a.source_system_id, max(a.func_cur_id) func_cur_id,
			MAX(ISNULL(spcd.source_curve_def_id, spcd2.source_curve_def_id)) fx_curve_id,
			a.term_start, MAX(a.contract_id) contract_id,
			MAX(CASE WHEN(spcd2.source_curve_def_id is not null) THEN -1 ELSE 1 END) opposite,
			MAX(a.pricing) pricing,
			a.term_end
	from #temp_deals a LEFT JOIN
	source_price_curve_def spcd ON	spcd.source_system_id = a.source_system_id  and 
									spcd.source_currency_id = a.fixed_price_currency_id AND
									spcd.source_currency_to_ID = a.func_cur_id and
									spcd.Granularity=980
									
	LEFT JOIN source_price_curve_def spcd2 ON	spcd2.source_system_id = a.source_system_id  and 
									spcd2.source_currency_id = a.func_cur_id AND
									spcd2.source_currency_to_ID = a.fixed_price_currency_id	and
									spcd2.Granularity=980
									
	WHERE a.fixed_price_currency_id <> a.func_cur_id AND  a.fixed_price_currency_id is not null
		and a.pricing in (1600, 1601, 1602) 
	group by a.fixed_price_currency_id, a.exp_curve_as_of_date, a.source_system_id, a.term_start, a.term_end
	) X

	create index indx_lag_curves_values_fx_1 on #lag_curves_values_fx (fx_currency_id)
	create index indx_lag_curves_values_fx_2 on #lag_curves_values_fx (func_cur_id)
	create index indx_lag_curves_values_fx_3 on #lag_curves_values_fx (source_system_id)
	create index indx_lag_curves_values_fx_4 on #lag_curves_values_fx (as_of_date)
	create index indx_lag_curves_values_fx_5 on #lag_curves_values_fx (term_start)
	create index indx_lag_curves_values_fx_6 on #lag_curves_values_fx (term_end)


						
	CREATE index indx_fx_curves ON #fx_curves (fx_currency_id, func_cur_id, source_system_id, as_of_date, maturity_date)

	select	curve_id, term_start, contract_id, func_cur_id, Pricing,
			case when (curve_currency_id = func_cur_id) then NULL else func_cur_id end currency_id,
			MAX(curve_factor) factor, term_end
	into #lag_curves
	from #temp_deals 
	where Pricing IN (1601 , 1602)
	group by curve_id, term_start, contract_id, Pricing, func_cur_id,
				case when (curve_currency_id = func_cur_id) then NULL else func_cur_id end,
				term_end 

	set @user_login_id = dbo.FNADBUser()

	INSERT INTO #tx (as_of_date, term_start, formula_id, granularity,contract_id,source_deal_detail_id )
	select   @curve_as_of_date as_of_date, t.term_start, t.formula_id, 980 granularity,MAX(t.contract_id), t.source_deal_detail_id 		 
	from #temp_deals t 
	WHERE t.formula_id is not null AND t.formula_curve_id IS NULL AND t.pricing < 1603 
	group by t.term_start, t.formula_id, t.source_deal_detail_id


	set @curve_as_of_date=@as_of_date

	SET @first_date_point='y'
------------------------------------------------------------------------------------------------------------------
-------------------------Start colleect data for two date point----------------------------------------------------
------------------------------------------------------------------------------------------------------------------
collect_data_for_two_date_point:

	print 'collect_data_for_two_date_point'

		TRUNCATE TABLE #cids_derived
		TRUNCATE TABLE #cids
		SET @process_id = REPLACE(newid(),'-','_')
		SET @formula_table=dbo.FNAProcessTableName('curve_formula_table', @user_login_id, @process_id)
		SET @calc_result_table=dbo.FNAProcessTableName('formula_calc_result', @user_login_id, @process_id)
		set @source_price_curve = dbo.FNAGetProcessTableName(@curve_as_of_date, 'source_price_curve')
		
		if OBJECT_ID(@formula_table) is not null
			exec('drop table '+@formula_table)
		
		if OBJECT_ID(@calc_result_table) is not null
			exec('drop table '+@calc_result_table)
		
		
		SET @sql='
			CREATE TABLE '+@formula_table+'(
				rowid int ,
				counterparty_id INT,
				contract_id INT,
				curve_id INT,
				prod_date DATETIME,
				as_of_date DATETIME,
				volume FLOAT,
				onPeakVolume FLOAT,
				source_deal_detail_id INT,
				formula_id INT,
				invoice_Line_item_id INT,			
				invoice_line_item_seq_id INT,
				price FLOAT,			
				granularity INT,
				volume_uom_id INT,
				generator_id INT,
				[Hour] INT,
				commodity_id INT,
				meter_id INT,
				curve_source_value_id INT,
				mins INT
			)	'
			
		EXEC(@sql)	

		SET @sql=' INSERT INTO '+@formula_table+'(rowid,formula_id,curve_source_value_id,prod_date, as_of_date,granularity,contract_id,source_deal_detail_id)
					SELECT 	[ID], formula_id, ' + cast(@curve_source_value_id as varchar) + ',term_start, '''+CONVERT(VARCHAR(10),@curve_as_of_date,120) +''' as_of_date, granularity,contract_id, source_deal_detail_id
					FROM #tx
			'
		print(@sql)
		EXEC(@sql)
		
				
		--select * from #formula_value
		print 'EXEC spa_calculate_formula	'''+convert(varchar(10),@curve_as_of_date,120) +''','''+ @formula_table+''','''+@process_id+''','''+@calc_result_table+''','''+ @calc_result_table_breakdown+ ''' output,''n'',' +@ob_calc
		EXEC spa_calculate_formula	@curve_as_of_date, @formula_table,@process_id,@calc_result_table, @calc_result_table_breakdown output,'n',@ob_calc

		SET @sql='INSERT INTO #formula_value'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +' 
				select prod_date, formula_id, NULL contract_expiration_date, 
				nullif(formula_eval_value, 0) formula_value, 
				ISNULL(contract_id,-1) contract_id	,source_deal_detail_id
				from ' +  @calc_result_table 
		print(@sql)
		exec(@sql)


		If @print_diagnostic = 1
		BEGIN
			print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
			print '****************End of collecting unique FORMULA in Deals *****************************'	
		END

		----------------------------------------------- End update formula values -----------------------
		-------------------------------------------------------------------------------------------

			
		--Now insert hourly or daily settlment prices based on calendar required for settlement only - market side
		set @sqlstmt = 'insert into #temp_curves'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +'  (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,
				curve_source_value_id, maturity_date,is_dst, curve_value, pnl_as_of_date, curve_granularity)
			select spc.source_curve_def_id, spc.as_of_date, spc.Assessment_curve_type_value_id, spc.curve_source_value_id,
					spc.maturity_date, spc.is_dst, spc.curve_value, s_cids.pnl_as_of_date, s_cids.curve_granularity
			from 
			(
				select DISTINCT td.curve_id curve_id, hol_date maturity_date, exp_date pnl_as_of_date,
						exp_date as_of_date,
						spcd.Granularity curve_granularity, 
						case when (td.settlement_curve_id is not null) then settlement_curve_factor else curve_factor end curve_factor 		 
			 
				from #temp_deals td INNER JOIN
					 source_price_curve_def spcd on spcd.source_curve_def_id = isnull(td.settlement_curve_id, td.curve_id) LEFT JOIN
					 holiday_group hg ON hg.hol_group_value_id = spcd.exp_calendar_id 				
				WHERE ''' + @calc_type +''' = ''s'' AND spcd.Granularity IN (981, 982) AND  td.Pricing IN (1600, -1) '
				+ case when @term_start is not null then ' AND hol_date >='''+convert(varchar(10),@term_start,120) +'''' else '' end
				+ case when @term_end is not null then 
					' AND hol_date <='''+CONVERT(varchar(10),case when  cast(@term_end as DATE) > @curve_as_of_date then  @curve_as_of_date else cast(@term_end as DATE) END,120)+''''
				 else '' end
				 +' AND hourly_position_breakdown=''y''
			) s_cids inner join
			source_price_curve spc on spc.source_curve_def_id = s_cids.curve_id AND 
					spc.as_of_date = s_cids.pnl_as_of_date AND
					year(spc.maturity_date) = year(s_cids.maturity_date) and month(spc.maturity_date) = month(s_cids.maturity_date) and 
					day(spc.maturity_date) = day(s_cids.maturity_date) and
					curve_source_value_id = '+CAST(@curve_source_value_id AS VARCHAR) +'
			WHERE spc.curve_value IS NOT NULL'

		print(@sqlstmt)
		EXEC(@sqlstmt)
		--Now insert hourly or daily settlment prices based on calendar required for settlement only - contract side  SIMPLE FORMULA
		set @sqlstmt = 'insert into #temp_curves'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +'  (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,
				curve_source_value_id, maturity_date,is_dst, curve_value, pnl_as_of_date, curve_granularity)
			select spc.source_curve_def_id, spc.as_of_date, spc.Assessment_curve_type_value_id, spc.curve_source_value_id,
					spc.maturity_date, spc.is_dst, spc.curve_value,  spc.as_of_date, s_cids.curve_granularity
			from 
			(
				select DISTINCT ISNULL(spcd2.source_curve_def_id, spcd.source_curve_def_id) curve_id, 
					hol_date maturity_date, exp_date pnl_as_of_date,
					exp_date as_of_date, --td.contract_expiration_date as_of_date, 
					spcd.Granularity curve_granularity
					,case when (td.settlement_curve_id is not null) then settlement_curve_factor else curve_factor end curve_factor 		 
				from #temp_deals td INNER JOIN
				 source_price_curve_def spcd on spcd.source_curve_def_id = td.formula_curve_id LEFT JOIN
				 source_price_curve_def spcd2 on spcd2.source_curve_def_id = spcd.settlement_curve_id LEFT JOIN
	 				holiday_group hg ON hg.hol_group_value_id = isnull(spcd2.exp_calendar_id, spcd.exp_calendar_id) 				
				WHERE td.formula_curve_id IS NOT NULL AND td.curve_id <> td.formula_curve_id and '''+@calc_type+'''  = ''s'' AND 
					spcd.Granularity IN (981, 982) AND  td.Pricing IN (-1, 1603) AND
					(hg.hol_group_value_id IS NULL ' 
					+ case when @term_start is not null then ' OR ( hol_date >='''+convert(varchar(10),@term_start,120) +''' 
					 AND hol_date <='''+CONVERT(varchar(10),case when  cast(@term_end as DATE) > @curve_as_of_date then  @curve_as_of_date else cast(@term_end as DATE) END,120) +''')' 
				 else '' end
				+') AND hourly_position_breakdown=''y''
			) s_cids inner join
				source_price_curve spc with(nolock) on spc.source_curve_def_id = s_cids.curve_id AND 
				spc.as_of_date = ISNULL(s_cids.pnl_as_of_date, spc.as_of_date) AND
			((s_cids.maturity_date IS NOT NULL AND 
			year(spc.maturity_date) = year(s_cids.maturity_date) AND month(spc.maturity_date) = month(s_cids.maturity_date) AND 
			day(spc.maturity_date) = day(s_cids.maturity_date)) OR
			--If calendar not defined assume daily and as of date equals maturity date
			(s_cids.maturity_date IS NULL AND spc.maturity_date = spc.as_of_date '
				+ case when @term_start is not null then ' AND spc.maturity_date >='''+convert(varchar(10),@term_start,120) +'''' else '' end
				+ case when @term_end is not null then 
					' AND spc.maturity_date <='''+CONVERT(varchar(10),case when  cast(@term_end as DATE) > @curve_as_of_date then  @curve_as_of_date else cast(@term_end as DATE) END,120)+''''
				 else '' end
			+'))	
			AND curve_source_value_id ='+CAST(@curve_source_value_id AS VARCHAR)+' LEFT JOIN 
			#temp_curves tc ON tc.source_curve_def_id = spc.source_curve_def_id AND 
				convert(varchar(10),tc.maturity_date,120) = convert(varchar(10),spc.maturity_date,120) 
			WHERE tc.maturity_date IS NULL	 
				AND spc.curve_value IS NOT NULL
			'
						
		
		print(@sqlstmt)
		EXEC(@sqlstmt)

		set @sqlstmt = '
				INSERT INTO #cids
				select distinct curve_id, maturity_date, ''' + @curve_as_of_date + ''' as_of_date, ''' + @curve_as_of_date + ''' pnl_as_of_date,
						curve_granularity, curve_factor
				from #temp_deals 
				where derived_curve = ''n'' and settled = 0 AND curve_id is NOT NULL AND pricing IN (-1, 1603)
				UNION
				select distinct proxy_curve_id, maturity_date, ''' + @curve_as_of_date + ''' as_of_date, ''' + @curve_as_of_date + ''' pnl_as_of_date,
					proxy_curve_granularity, proxy_curve_factor
				from #temp_deals 
					where proxy_derived_curve = ''n'' and settled = 0 AND curve_id is NOT NULL AND proxy_curve_id IS NOT NULL AND pricing IN (1600,-1, 1603)
				UNION
				select distinct proxy_curve_id3, maturity_date, ''' + @curve_as_of_date + ''' as_of_date, ''' + @curve_as_of_date + ''' pnl_as_of_date,
					proxy_curve_granularity3, proxy_curve_factor3
				from #temp_deals 
				where proxy_derived_curve3 = ''n'' and settled = 0 AND curve_id is NOT NULL AND proxy_curve_id3 IS NOT NULL AND pricing IN (1600,-1, 1603)
				
				UNION --ALL
				select distinct monthly_index, maturity_date, ''' + @curve_as_of_date + ''' as_of_date, ''' + @curve_as_of_date + ''' pnl_as_of_date,
					monthly_index_granularity, monthly_index_factor
				from #temp_deals 
				where monthly_index_derived_curve = ''n'' and settled = 0 AND curve_id is NOT NULL AND monthly_index IS NOT NULL AND pricing IN (1600,-1, 1603)
				UNION
				select distinct formula_curve_id, maturity_date, ''' + @curve_as_of_date + ''' as_of_date, ''' + @curve_as_of_date + ''' pnl_as_of_date,
						s.granularity, ISNULL(su.factor, 1)
				from #temp_deals a inner join
					 source_price_curve_def s ON s.source_curve_def_id = a.formula_curve_id inner join
					 source_currency su on su.source_currency_id = s.source_currency_id
				UNION
				select distinct sp1.source_curve_def_id, maturity_date, ''' + @curve_as_of_date + ''' as_of_date, ''' + @curve_as_of_date + ''' pnl_as_of_date,
						sp1.granularity, ISNULL(su.factor, 1)
				from #temp_deals a inner join
					 source_price_curve_def s ON s.source_curve_def_id = a.formula_curve_id inner join
					 source_price_curve_def sp1 ON sp1.source_curve_def_id = s.proxy_source_curve_def_id inner join
					 source_currency su on su.source_currency_id = sp1.source_currency_id
				UNION	 	
				select distinct sp1.source_curve_def_id, maturity_date, ''' + @curve_as_of_date + ''' as_of_date, ''' + @curve_as_of_date + ''' pnl_as_of_date,
						sp1.granularity, ISNULL(su.factor, 1)
				from #temp_deals a inner join
					 source_price_curve_def s ON s.source_curve_def_id = a.formula_curve_id inner join
					 source_price_curve_def sp1 ON sp1.source_curve_def_id = s.monthly_index inner join
					 source_currency su on su.source_currency_id = sp1.source_currency_id
				UNION	 	
				select distinct sp1.source_curve_def_id, maturity_date, ''' + @curve_as_of_date + ''' as_of_date, ''' + @curve_as_of_date + ''' pnl_as_of_date,
						sp1.granularity, ISNULL(su.factor, 1)
				from #temp_deals a inner join
					 source_price_curve_def s ON s.source_curve_def_id = a.formula_curve_id inner join
					 source_price_curve_def sp1 ON sp1.source_curve_def_id = s.proxy_curve_id3 inner join
					 source_currency su on su.source_currency_id = sp1.source_currency_id
			'
		-- select * from #cids
		print(@sqlstmt)
		EXEC(@sqlstmt)

		if @first_date_point ='y' 
		BEGIN 
			CREATE INDEX idx_cids1 ON #cids(curve_id)
			CREATE INDEX idx_cids2 ON #cids(maturity_date)
			CREATE INDEX idx_cids3 ON #cids(pnl_as_of_date)
		END 
		
		If @print_diagnostic = 1
		BEGIN
			print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
			print '**************** End of Collecting curve id maturity date and pnl as of date*****************************'	
		END

		--Only insert price curves that are not already picked up in #temp_curves
		set @sqlstmt = '
			insert into #temp_curves'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +'  (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,
				curve_source_value_id, maturity_date,is_dst, curve_value, pnl_as_of_date, curve_granularity)
			select	spc.source_curve_def_id, spc.as_of_date, spc.assessment_curve_type_value_id, spc.curve_source_value_id,
					spc.maturity_date, spc.is_dst, spc.curve_value, spc.pnl_as_of_date, spc.curve_granularity
			FROM
			(	
				select	cids.curve_id source_curve_def_id, 
						cids.as_of_date, spc.assessment_curve_type_value_id, spc.curve_source_value_id, spc.maturity_date,isnull(spc.is_dst,0) is_dst,
						(cids.factor * spc.curve_value + ' + cast(@curve_shift_val as varchar) + ') * ' + cast(@curve_shift_per as varchar) + ' curve_value, 
						cids.pnl_as_of_date pnl_as_of_date, cids.curve_granularity
				from (select distinct as_of_date,pnl_as_of_date,curve_id, year(maturity_date) yr, curve_granularity, factor from #cids ) cids  inner join --left outer join
				' + @source_price_curve + ' spc ON 
					cids.curve_id = spc.source_curve_def_id AND
					year(spc.maturity_date)=cids.yr  AND
					cids.pnl_as_of_date = spc.as_of_date AND 
					spc.assessment_curve_type_value_id = ' + cast(@assessment_curve_type_value_id as varchar) + '
					AND spc.curve_source_value_id = ' + cast(@curve_source_value_id as varchar) + ' 
				where spc.curve_value IS NOT NULL
			) spc  left join 
			#temp_curves'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +' tc ON tc.source_curve_def_id = spc.source_curve_def_id AND 
				convert(varchar(10),tc.maturity_date,120) = convert(varchar(10),spc.maturity_date,120) 
			WHERE tc.maturity_date IS NULL
			 AND spc.curve_value IS NOT NULL
		'
		print (@sqlstmt)
		exec (@sqlstmt)

		If @print_diagnostic = 1
		BEGIN
			print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
			print '****************Selecting price curves1*****************************'	
		END

		If @print_diagnostic = 1
		begin
			set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
			set @log_increment = @log_increment + 1
			set @log_time=getdate()
			print @pr_name+' Running..............'
		end



		--Intrest Rates/Bonds
		set @sqlstmt = '
			insert into #temp_curves'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +'  (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,
				curve_source_value_id, maturity_date,is_dst, curve_value, pnl_as_of_date, curve_granularity) 
			select DISTINCT spc.source_curve_def_id, spc.as_of_date, spc.assessment_curve_type_value_id,
					spc.curve_source_value_id, spc.maturity_date,spc.is_dst, 
					(spc.curve_value + ' + cast(@curve_shift_val as varchar) + ') * ' + cast(@curve_shift_per as varchar) + ', 
					spc.as_of_date,
					a.curve_granularity 
			from #temp_deals a inner join
			' + @source_price_curve + ' spc ON a.curve_id = spc.source_curve_def_id and
				spc.as_of_date = ''' + @curve_as_of_date + ''' and 
				spc.maturity_date= a.term_end and
				spc.assessment_curve_type_value_id = ' + cast(@assessment_curve_type_value_id as varchar) + ' and
				spc.curve_source_value_id = ' + cast(@curve_source_value_id as varchar) + ' left outer join
			#temp_curves'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +' tc ON tc.source_curve_def_id = spc.source_curve_def_id and
							   tc.as_of_date = spc.as_of_date and tc.maturity_date = spc.maturity_date
			where a.curve_id IS NOT NULL AND (a.internal_deal_type_value_id = 6 OR a.internal_deal_type_value_id = 7) AND
				tc.source_curve_def_id IS NULL AND a.derived_curve = ''n''
		'
		print(@sqlstmt)
		EXEC(@sqlstmt)

		If @print_diagnostic = 1
		BEGIN
			print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
			print '****************Selecting price curves2*****************************'	
		END

		
		----------------------get derived curves

		SET @sqlstmt =
		'
			CREATE TABLE ' + @derived_curve_table + ' (
				source_curve_def_id INT,
				as_of_date datetime,
				maturity_date datetime,
				is_dst bit,
				formula_value float,
				formula_id INT,
				formula_str VARCHAR(500)
			)
		'

		Exec(@sqlstmt)

		DECLARE formula_cursor_derc CURSOR FOR 
		select 	curve_id, dbo.FNAGetContractMonth(min(term_start)), max(term_end) 
		from #temp_deals where derived_curve = 'y'
		group by curve_id

		OPEN formula_cursor_derc

		FETCH NEXT FROM formula_cursor_derc
		INTO @der_curve_id, @min_term_start, @max_term_start
		WHILE @@FETCH_STATUS = 0
		BEGIN

			set @curve_as_of_date_from = case when (@min_term_start < @curve_as_of_date) then @min_term_start else @curve_as_of_date end

			EXEC spa_derive_curve_value @der_curve_id,@curve_as_of_date_from,
				 @curve_as_of_date, @curve_source_value_id, @derived_curve_table, @min_term_start, @max_term_start

			FETCH NEXT FROM formula_cursor_derc
			INTO @der_curve_id, @min_term_start, @max_term_start

		END

		CLOSE formula_cursor_derc
		DEALLOCATE  formula_cursor_derc

		set @sqlstmt = '
			INSERT INTO #cids_derived
			select distinct curve_id, maturity_date, ''' + @curve_as_of_date + ''' as_of_date, ''' + @curve_as_of_date + ''' pnl_as_of_date,
					curve_granularity
			from #temp_deals 
			where settled = 0 AND curve_id is NOT NULL AND derived_curve = ''y'' AND (curve_granularity <> 982 OR (curve_granularity = 982 AND ' + cast(@mtm_hourly_prices as varchar) + ' = 0)) 
			UNION --ALL
			select td.curve_id, spc.maturity_date, td.contract_expiration_date as_of_date, max(spc.as_of_date) pnl_as_of_date,
					max(curve_granularity) curve_granularity
			from #temp_deals td INNER JOIN
			' + @derived_curve_table + ' spc ON spc.source_curve_def_id = td.curve_id AND 
				spc.maturity_date = td.maturity_date 
			where derived_curve = ''y'' AND td.settled = 1 AND spc.as_of_date >= td.contract_expiration_date 
			 AND (curve_granularity <> 982 OR (curve_granularity = 982 AND ' + cast(@mtm_hourly_prices as varchar) + ' = 0)) 
			group by td.curve_id, spc.maturity_date, td.contract_expiration_date'

		EXEC(@sqlstmt)

		IF @first_date_point ='y' 
			CREATE INDEX idx_cids_derived ON #cids_derived(curve_id, maturity_date, pnl_as_of_date)

		If @print_diagnostic = 1
		BEGIN
			print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
			print '**************** End of Collecting curve id maturity date and pnl as of date for Derived curves*****************************'	
		END

		set @sqlstmt = '
			insert into #temp_curves'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +' (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,curve_source_value_id, maturity_date,is_dst, curve_value, pnl_as_of_date, curve_granularity)
			select	cids.curve_id source_curve_def_id, 
					cids.as_of_date, 
					' + cast(@assessment_curve_type_value_id as varchar) + ' assessment_curve_type_value_id,
					' + cast(@curve_source_value_id as varchar) + ' curve_source_value_id,
					spc.maturity_date,isnull(spc.is_dst,0), 
					(spc.formula_value + ' + cast(@curve_shift_val as varchar) + ') * ' + cast(@curve_shift_per as varchar) + ' curve_value,
					cids.pnl_as_of_date pnl_as_of_date,
					curve_granularity
			from 
			(
				select distinct as_of_date,pnl_as_of_date,curve_id, year(maturity_date) yr, curve_granularity from #cids_derived 
			)  cids inner join
				' + @derived_curve_table + ' spc ON 
					cids.curve_id = spc.source_curve_def_id AND
					year(spc.maturity_date) =cids.yr  AND
					cids.as_of_date = spc.as_of_date  
			where spc.formula_value IS NOT NULL 
		'

		print @sqlstmt
		EXEC(@sqlstmt)

		--DROP TEMP derived processing TABLE
		set @sqlstmt = dbo.FNAProcessDeleteTableSql(@derived_curve_table)
		EXEC (@sqlstmt)

		If @print_diagnostic = 1
		BEGIN
			print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
			print '****************END OF Processing Derived deals *****************************'	
		END


		If @print_diagnostic = 1
		begin
			set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
			set @log_increment = @log_increment + 1
			set @log_time=getdate()
			print @pr_name+' Running..............'
		end


		
		set @sqlstmt = 'INSERT INTO #avg_temp_curves'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +' (source_deal_header_id, leg , curve_id,min_term_start, max_term_end , avg_curve_value, curve_granularity)
			select	a.source_deal_header_id, a.leg, a.curve_id, min(a.term_start) min_term_start, max(a.term_end) max_term_end, 
					avg(tc.curve_value) avg_curve_value, MAX(a.curve_granularity) curve_granularity
			from #temp_deals a INNER JOIN
			#temp_curves'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +' tc ON tc.source_curve_def_id = a.curve_id AND 
							tc.maturity_date = CASE WHEN ('+CAST(@assessment_curve_type_value_id AS VARCHAR)+' = 77) THEN
												dbo.FNAGetSQLStandardDate(a.maturity_date)
											ELSE '''+ @curve_as_of_date +'''   END AND
							tc.as_of_date = case when (a.contract_expiration_date <'''+ @curve_as_of_date+''') then a.contract_expiration_date else '''+@curve_as_of_date+''' end
			where Pricing = 1600 AND hourly_position_breakdown=''n''
			group by a.source_deal_header_id, a.leg, a.curve_id'

		
		print @sqlstmt
		EXEC(@sqlstmt)
		
		set @sqlstmt = 'INSERT INTO #lag_curves_values'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END 
		+' (curve_id,term_start ,term_end,contract_id , func_cur_id, lag_curve_value)
		select	a.curve_id, a.term_start, a.term_end, 
			isnull(a.contract_id, -1) contract_id, isnull(a.func_cur_id, -1) func_cur_id,
			a.factor * 
			CASE WHEN pricing = 1602 THEN 
				dbo.FNAPartialAvgCurve(a.term_start,a.term_end, '''+@curve_as_of_date+''', '+CAST(@curve_source_value_id AS VARCHAR)+',a.contract_id, a.curve_id,a.currency_id)
			WHEN pricing = 1601 AND  '''+@curve_as_of_date+''' < a.term_end THEN
				dbo.FNAPartialAvgCurve(a.term_start,'''+@curve_as_of_date+''', '''+@curve_as_of_date+''', '+CAST(@curve_source_value_id AS VARCHAR)+',a.contract_id, a.curve_id,a.currency_id)
			ELSE 
				dbo.FNARCLagcurve(a.term_start, '''+@curve_as_of_date+''','+CAST(@curve_source_value_id AS VARCHAR)+',a.contract_id, a.curve_id, 0, 0, 0, 1, a.currency_id, 0, 1, NULL, NULL) 
			END	lag_curve_value
		from #lag_curves a	
	'
				
		print @sqlstmt
		EXEC(@sqlstmt)


		set @sqlstmt = 'INSERT INTO #hrly_price_curves'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +'
			(curve_id ,as_of_date ,Assessment_curve_type_value_id,curve_source_value_id,curve_value ,Granularity, maturity_date,hr)
			select tc.source_curve_def_id curve_id,tc.as_of_date,Assessment_curve_type_value_id,tc.curve_source_value_id,tc.curve_value,spcd.Granularity
				,convert(varchar(10),maturity_date,120) maturity_date,case when is_dst=1 then 25 else datepart(hh,maturity_date)+1 end  hr 
			from #temp_curves'+CASE WHEN @first_date_point ='y' THEN '' ELSE '_to' END +' tc left join source_price_curve_def spcd on tc.source_curve_def_id=spcd.source_curve_def_id
			where spcd.Granularity in(981,982)' --hourly,daily


		print @sqlstmt
		EXEC(@sqlstmt)

		print('INSERT INTO #as_of_date_to SELECT  TOP 1 as_of_date_to FROM '+@table_name)

		EXEC('INSERT INTO #as_of_date_to SELECT  TOP 1 as_of_date_to FROM '+@table_name)
	
	
		print '	&&&&before&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
		print @curve_as_of_date
		print '	&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'

		SELECT TOP 1 @curve_as_of_date=CONVERT(VARCHAR(10),as_of_date_to,120) FROM #as_of_date_to
	

		print '	&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
		print @curve_as_of_date
		print '	&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
		
		set @as_of_date_to=@curve_as_of_date
		IF @first_date_point='y'
		begin
			SET @first_date_point ='n' 
			GOTO collect_data_for_two_date_point
		end


-------------------------------end of collecting data for two date points---------------------------------
--------------------------------------------------------------------------------------------	

	create index indx_lag_curves_values_1 on #lag_curves_values (curve_id)
	create index indx_lag_curves_values_2 on #lag_curves_values (term_start)
	create index indx_lag_curves_values_3 on #lag_curves_values (term_end)
	create index indx_lag_curves_values_4 on #lag_curves_values (contract_id)
	create index indx_lag_curves_values_5 on #lag_curves_values (func_cur_id)

	create index indx_lag_curves_values_1_to on #lag_curves_values_to (curve_id)
	create index indx_lag_curves_values_2_to on #lag_curves_values_to (term_start)
	create index indx_lag_curves_values_3_to on #lag_curves_values_to (term_end)
	create index indx_lag_curves_values_4_to on #lag_curves_values_to (contract_id)
	create index indx_lag_curves_values_5_to on #lag_curves_values_to (func_cur_id)



	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '****************End of collecting Prices for Hourly Market Value Calculation *****************************'	
	END



	CREATE TABLE #hrl_pos (
		location_id INT , leg TINYINT , source_deal_header_id INT ,curve_id INT , monthly_index INT ,source_deal_detail_id int
		,commodity_id INT ,  term_start DATETIME , curve_granularity INT ,proxy_curve_id INT ,proxy_curve_id3 int, settlement_curve_id INT , 
		formula_curve_id INT ,b_s_mult INT ,hr TINYINT ,
		curve_maturity DATETIME, proxy_curve_maturity DATETIME,	 proxy_curve_maturity3	  DATETIME,
		monthly_index_maturity DATETIME,		 		
		monthly_index_granularity INT , proxy_curve_granularity INT , proxy_curve_granularity3 INT ,
		settlement_curve_granularity INT ,  func_cur_id INT , contract_id INT ,
		monthly_term DATETIME, deal_term_start DATETIME,deal_term_end DATETIME,
		[OB_value] NUMERIC(18,10),[new_deal]  NUMERIC(18,10),[modify_deal]  NUMERIC(18,10),[forecast_changed]  NUMERIC(18,10)
		,[deleted]  NUMERIC(18,10),[delivered]  NUMERIC(18,10),[CB_value]  NUMERIC(18,10),formula_breakdown bit
	)	

	SET @sqlstmt = 'INSERT INTO #hrl_pos (
			location_id, leg , source_deal_header_id ,curve_id , monthly_index ,source_deal_detail_id,
			commodity_id ,term_start, curve_granularity ,proxy_curve_id ,proxy_curve_id3, settlement_curve_id , 
			formula_curve_id ,b_s_mult,hr ,curve_maturity, proxy_curve_maturity,proxy_curve_maturity3,monthly_index_maturity,		 		
			monthly_index_granularity, proxy_curve_granularity,proxy_curve_granularity3, settlement_curve_granularity ,  func_cur_id , contract_id ,
			monthly_term, deal_term_start,deal_term_end,[OB_value],[new_deal],[modify_deal],[forecast_changed],[deleted],[delivered],[CB_value]	,formula_breakdown
		)		
		SELECT isnull(td.location_id, -1) location_id, td.leg, rp.source_deal_header_id,rp.curve_id, td.monthly_index,td.source_deal_detail_id,
				rp.commodity_id, rp.term_start, td.curve_granularity, td.proxy_curve_id,td.proxy_curve_id3, td.settlement_curve_id, 
				td.formula_curve_id, -1  b_s_mult --case when(td.buy_sell_flag=''s'') then 1 else -1 end
				,rp.hr,	
				CAST(CASE WHEN (td.curve_granularity = 980 OR td.pricing IN (1601,1602)) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(Month(td.term_start) as varchar) + ''-01'' 
					 WHEN (td.curve_granularity = 991) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(datepart(q, td.term_start) as varchar) + ''-01'' 
					 WHEN (td.curve_granularity = 992) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
					 WHEN (td.curve_granularity = 993) THEN cast(Year(td.term_start) as varchar) + ''-01-01'' 
					 ELSE td.term_start 
				END AS DATETIME) curve_maturity,		 			
				CAST(CASE WHEN (td.proxy_curve_granularity = 980) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(Month(td.term_start) as varchar) + ''-01'' 
					 WHEN (td.proxy_curve_granularity = 991) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(datepart(q, td.term_start) as varchar) + ''-01'' 
					 WHEN (td.proxy_curve_granularity = 992) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
					 WHEN (td.proxy_curve_granularity = 993) THEN cast(Year(td.term_start) as varchar) + ''-01-01'' 
					 ELSE td.term_start 
				END AS DATETIME) proxy_curve_maturity,	
				CAST(CASE WHEN (td.proxy_curve_granularity3 = 980) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(Month(td.term_start) as varchar) + ''-01'' 
					 WHEN (td.proxy_curve_granularity3 = 991) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(datepart(q, td.term_start) as varchar) + ''-01'' 
					 WHEN (td.proxy_curve_granularity3 = 992) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
					 WHEN (td.proxy_curve_granularity3 = 993) THEN cast(Year(td.term_start) as varchar) + ''-01-01'' 
					 ELSE td.term_start 
				END AS DATETIME) proxy_curve_maturity3,				
				CAST(CASE WHEN (td.monthly_index_granularity = 980) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(Month(td.term_start) as varchar) + ''-01'' 
					 WHEN (td.monthly_index_granularity = 991) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(datepart(q, td.term_start) as varchar) + ''-01''
					 WHEN (td.monthly_index_granularity = 992) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
					 WHEN (td.monthly_index_granularity = 993) THEN cast(Year(td.term_start) as varchar) + ''-01-01'' 
					 ELSE td.term_start 
				END AS DATETIME) monthly_index_maturity,		 		
				td.monthly_index_granularity, td.proxy_curve_granularity, td.proxy_curve_granularity3, 
				td.settlement_curve_granularity, ISNULL(td.func_cur_id, -1) func_cur_id, ISNULL(td.contract_id, -1) contract_id,
				cast(cast(year(rp.term_start) as varchar) + ''-'' + cast(MONTH(rp.term_start) as varchar) + ''-01'' as DATETIME) monthly_term, 
				td.term_start deal_term_start,td.term_end deal_term_end,
				[OB_value],[new_deal],[modify_deal],[forecast_changed],[deleted],[delivered],[CB_value],rp.formula_breakdown
			from '+@table_name+' rp inner join #temp_deals td on rp.source_deal_header_id=td.source_deal_header_id 
				and rp.term_start between td.term_start and td.term_end and rp.curve_id=isnull(td.curve_id,-1) and
					rp.location_id = isnull(td.location_id, -1) AND (td.hourly_position_breakdown= ''y'' or rp.hr=0)  ---if cash deal then rp.hr=0 
			WHERE rp.expiration_date > '''+CONVERT(VARCHAR(10),@as_of_date,120)+''' and rp.term_start > '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''

	'
	PRINT @sqlstmt
	EXEC(@sqlstmt)


	CREATE index indx_kk1 ON #hrl_pos (term_start)
	CREATE index indx_kk2 ON #hrl_pos (curve_granularity)
	CREATE index indx_kk3 ON #hrl_pos (proxy_curve_granularity)
	CREATE index indx_kk4 ON #hrl_pos (monthly_index_granularity)
	CREATE index indx_kk5 ON #hrl_pos (curve_id)
	CREATE index indx_kk6 ON #hrl_pos (proxy_curve_id)
	CREATE index indx_kk7 ON #hrl_pos (monthly_index)
	CREATE index indx_kk8 ON #hrl_pos (curve_maturity)
	CREATE index indx_kk9 ON #hrl_pos (proxy_curve_maturity)
	CREATE index indx_kk10 ON #hrl_pos (monthly_index_maturity)
	CREATE index indx_kk11 ON #hrl_pos (contract_id)
	CREATE index indx_kk12 ON #hrl_pos (commodity_id)
	CREATE index indx_kk13 ON #hrl_pos (func_cur_id)

	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '****************Saving Hourly Position and creating index for Market Value*****************************'	
	END

	-- select * from #hrl_pos
	-- select * from #hrl_pos_c


	If @print_diagnostic = 1
	BEGIN 
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	END 

	select
		vol.source_deal_header_id, vol.leg, vol.location_id, vol.curve_id, vol.monthly_term, 
		vol.deal_term_start, vol.term_start monthly_term_end, formula_curve_id, b_s_mult,vol.hr,
		coalesce(lcv.lag_curve_value, pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value) p1,
		coalesce(lcv_to.lag_curve_value, pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value) p2,
		
		isnull(coalesce(lcv.lag_curve_value, pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.[OB_value],0) market_value_OB_value,
		isnull(coalesce(lcv.lag_curve_value, pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.[OB_value],0) curve_value_OB_value,
		isnull(vol.OB_value,0) volume_OB_value,
		
		isnull(coalesce(lcv_to.lag_curve_value, pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[new_deal],0) market_value_new_deal,
		isnull(coalesce(lcv_to.lag_curve_value, pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[new_deal],0) curve_value_new_deal,
		isnull(vol.new_deal,0) volume_new_deal,

		isnull(coalesce(lcv_to.lag_curve_value, pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[modify_deal],0) market_value_modify_deal,
		isnull(coalesce(lcv_to.lag_curve_value, pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[modify_deal],0) curve_value_modify_deal,
		isnull(vol.modify_deal,0) volume_modify_deal,
		
		isnull(coalesce(lcv_to.lag_curve_value, pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[forecast_changed],0) market_value_forecast_changed,
		isnull(coalesce(lcv_to.lag_curve_value, pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[forecast_changed],0) curve_value_forecast_changed,
		isnull(vol.forecast_changed,0) volume_forecast_changed,
		
		coalesce(lcv.lag_curve_value, pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value) avg_curve_value,
		
		isnull(coalesce(lcv.lag_curve_value, pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.[deleted],0) market_value_deleted,
		isnull(coalesce(lcv.lag_curve_value, pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.[deleted],0) curve_value_deleted,
		isnull(vol.deleted,0) volume_deleted,
		
		isnull(coalesce(lcv.lag_curve_value, pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.[delivered],0) market_value_delivered,
		isnull(coalesce(lcv.lag_curve_value, pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.[delivered],0) curve_value_delivered,
		isnull(vol.delivered,0) volume_delivered,

		isnull(coalesce(lcv_to.lag_curve_value, pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[CB_value],0) market_value_CB_value,
		isnull(coalesce(lcv_to.lag_curve_value, pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[CB_value],0) curve_value_CB_value,
		isnull(vol.CB_value,0) volume_CB_value,
		
		isnull((coalesce(lcv_to.lag_curve_value, pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)-coalesce(lcv.lag_curve_value, pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value))* vol.[OB_value],0) curve_value_price_changed_value,

		coalesce(lcv_to.lag_curve_value, pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value) avg_curve_value_to
		,vol.formula_breakdown
	into #tmp_hourly_price_vol
	FROM #hrl_pos vol LEFT JOIN 
	#hrly_price_curves pr1  ON pr1.maturity_date=vol.term_start AND vol.curve_granularity IN (981,982) AND  
				pr1.curve_id=vol.curve_id AND case when pr1.granularity =981 then -1 else pr1.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end   LEFT JOIN -- original curve
	#hrly_price_curves pr2 ON pr2.maturity_date=vol.term_start and vol.proxy_curve_granularity IN (981,982)  AND
				pr2.curve_id=vol.proxy_curve_id AND case when pr2.granularity =981 then -1 else pr2.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end LEFT JOIN -- proxy curve
	#hrly_price_curves pr3 ON pr3.maturity_date=vol.term_start and vol.monthly_index_granularity IN (981,982)  AND
				pr3.curve_id=vol.monthly_index AND case when pr3.granularity =981 then -1 else pr3.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end LEFT JOIN -- monthly index curve	
	#temp_curves pr4 ON pr4.maturity_date=vol.curve_maturity and vol.curve_granularity NOT IN (981,982) AND 
				pr4.source_curve_def_id = vol.curve_id AND pr4.as_of_date = @as_of_date  LEFT JOIN --original curve higher granularity 
	#temp_curves pr5 ON pr5.maturity_date=vol.proxy_curve_maturity and vol.proxy_curve_granularity NOT IN (981,982) AND 
				pr5.source_curve_def_id = vol.proxy_curve_id AND pr5.as_of_date = @as_of_date LEFT JOIN --proxly curve higher granularity 
	#temp_curves pr6 ON pr6.maturity_date=vol.monthly_index_maturity and vol.monthly_index_granularity NOT IN (981,982) AND 
				pr6.source_curve_def_id = vol.monthly_index AND pr6.as_of_date = @as_of_date LEFT JOIN --monthly index curve higher granularity 
	#lag_curves_values lcv ON lcv.curve_id = vol.curve_id AND --lcv.term_start = vol.curve_maturity AND 
				lcv.term_start = vol.deal_term_start AND lcv.term_end = vol.deal_term_end AND
				lcv.contract_id =  vol.contract_id AND lcv.func_cur_id = vol.func_cur_id				
	LEFT JOIN 	
	#hrly_price_curves_to pr1_to  ON pr1_to.maturity_date=vol.term_start AND vol.curve_granularity IN (981,982) AND  
				pr1_to.curve_id=vol.curve_id AND case when pr1_to.granularity =981 then -1 else pr1_to.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end LEFT JOIN -- original curve
	#hrly_price_curves_to pr2_to ON pr2_to.maturity_date=vol.term_start and vol.proxy_curve_granularity IN (981,982)  AND
				pr2_to.curve_id=vol.proxy_curve_id AND case when pr2_to.granularity =981 then -1 else pr2_to.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end LEFT JOIN -- proxy curve
	#hrly_price_curves_to pr3_to ON pr3_to.maturity_date=vol.term_start and vol.monthly_index_granularity IN (981,982)  AND
				pr3_to.curve_id=vol.monthly_index  AND case when pr3_to.granularity =981 then -1 else pr3_to.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end LEFT JOIN -- monthly index curve	
	#temp_curves_to pr4_to ON pr4_to.maturity_date=vol.curve_maturity and vol.curve_granularity NOT IN (981,982) AND 
				pr4_to.source_curve_def_id = vol.curve_id AND pr4_to.as_of_date = @curve_as_of_date  LEFT JOIN --original curve higher granularity 
	#temp_curves_to pr5_to ON pr5_to.maturity_date=vol.proxy_curve_maturity and vol.proxy_curve_granularity NOT IN (981,982) AND 
				pr5_to.source_curve_def_id = vol.proxy_curve_id AND pr5_to.as_of_date = @curve_as_of_date LEFT JOIN --proxly curve higher granularity 
	#temp_curves_to pr6_to ON pr6_to.maturity_date=vol.monthly_index_maturity and vol.monthly_index_granularity NOT IN (981,982) AND 
				pr6_to.source_curve_def_id = vol.monthly_index AND pr6_to.as_of_date = @curve_as_of_date LEFT JOIN --monthly index curve higher granularity 
	#lag_curves_values_to lcv_to ON lcv_to.curve_id = vol.curve_id AND --lcv.term_start = vol.curve_maturity AND 
							lcv_to.term_start = vol.deal_term_start AND lcv_to.term_end = vol.deal_term_end AND
				lcv_to.contract_id =  vol.contract_id AND lcv_to.func_cur_id = vol.func_cur_id	
	--	select * from #tmp_hourly_price_vol

	create index indx_tmp_hour#tmp_hourly_price_volly_price_vol_deal111 on  #tmp_hourly_price_vol(source_deal_header_id,curve_id,deal_term_start)

	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '****************End of Calculating Hourly Market Values*****************************'	
	END


	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end

	select source_deal_header_id, leg, location_id, formula_curve_id, monthly_term, deal_term_start, monthly_term_end, hr,
		b_s_mult*market_value_OB_value contract_value_OB_value, curve_value_OB_value, b_s_mult*volume_OB_value volume_OB_value,
		b_s_mult*market_value_new_deal contract_value_new_deal, curve_value_new_deal, b_s_mult*volume_new_deal volume_new_deal, 
		b_s_mult*market_value_modify_deal contract_value_modify_deal, curve_value_modify_deal, b_s_mult*volume_modify_deal volume_modify_deal,
		b_s_mult*market_value_forecast_changed contract_value_forecast_changed, curve_value_forecast_changed, b_s_mult*volume_forecast_changed volume_forecast_changed, avg_curve_value,
		b_s_mult*market_value_deleted contract_value_deleted, curve_value_deleted, b_s_mult*volume_deleted volume_deleted,
		b_s_mult*market_value_delivered contract_value_delivered, curve_value_delivered, b_s_mult*volume_delivered volume_delivered,
		b_s_mult*market_value_CB_value contract_value_CB_value, curve_value_CB_value, b_s_mult*volume_CB_value volume_CB_value
		, avg_curve_value_to,formula_breakdown
	into  #tmp_hourly_price_vol_c
	from #tmp_hourly_price_vol
	where formula_curve_id is not null and formula_curve_id = curve_id


	CREATE TABLE #hrl_pos_c (
		location_id INT , leg TINYINT , source_deal_header_id INT ,curve_id_m INT , monthly_index INT , source_deal_detail_id int,
		commodity_id INT ,  term_start DATETIME , curve_granularity INT ,proxy_curve_id INT,proxy_curve_id3 int ,hr TINYINT , settlement_curve_id INT , 
		curve_id INT ,b_s_mult INT  ,
		curve_maturity DATETIME, proxy_curve_maturity DATETIME,		 
		monthly_index_maturity DATETIME,		 		
		monthly_index_granularity INT , proxy_curve_granularity INT ,proxy_curve_granularity3 int, proxy_curve_maturity3 DATETIME,
		settlement_curve_granularity INT ,  func_cur_id INT , contract_id INT ,
		monthly_term DATETIME, deal_term_start DATETIME,deal_term_end DATETIME,
		[OB_value] NUMERIC(18,10),[new_deal]  NUMERIC(18,10),[modify_deal]  NUMERIC(18,10),[forecast_changed]  NUMERIC(18,10)
		,[deleted]  NUMERIC(18,10),[delivered]  NUMERIC(18,10),[CB_value]  NUMERIC(18,10),formula_breakdown bit
		,volume_rounding int, formula_id int, pricing int, formula_curve_id int, original_formula_currency int
	)	

	SET @sqlstmt = '
		INSERT INTO #hrl_pos_c (location_id , leg , source_deal_header_id ,curve_id_m , monthly_index , source_deal_detail_id,
			commodity_id , term_start , curve_granularity ,proxy_curve_id,proxy_curve_id3,hr , settlement_curve_id , 
			curve_id ,b_s_mult ,curve_maturity, proxy_curve_maturity,proxy_curve_maturity3,monthly_index_maturity,		 		
			monthly_index_granularity , proxy_curve_granularity ,proxy_curve_granularity3,settlement_curve_granularity ,  func_cur_id , contract_id ,
			monthly_term, deal_term_start,deal_term_end,[OB_value],[new_deal],[modify_deal],[forecast_changed],[deleted],[delivered],[CB_value],formula_breakdown,
			volume_rounding, formula_id, pricing, formula_curve_id, original_formula_currency
		)	
		select	isnull(td.location_id, -1) location_id, td.leg, rp.source_deal_header_id,rp.curve_id curve_id_m, td.monthly_index, td.source_deal_detail_id,
		rp.commodity_id, rp.term_start, spcd.granularity curve_granularity, spcd.proxy_source_curve_def_id proxy_curve_id,spcd.proxy_curve_id3,rp.hr, 
		spcd.settlement_curve_id, td.formula_curve_id curve_id,	case when (td.buy_sell_flag=''s'') then 1 else -1 end b_s_mult,
		CAST(CASE WHEN (spcd.granularity = 980 OR td.pricing IN (1601,1602)) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(Month(td.term_start) as varchar) + ''-01'' 
			 WHEN (spcd.granularity = 991) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(datepart(q, td.term_start) as varchar) + ''-01'' 
			 WHEN (spcd.granularity = 992) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
			 WHEN (spcd.granularity = 993) THEN cast(Year(td.term_start) as varchar) + ''-01-01'' 
			 ELSE td.term_start 
		END AS DATETIME) curve_maturity,		 			
		CAST(CASE WHEN (spcd_p.Granularity = 980) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(Month(td.term_start) as varchar) + ''-01'' 
			 WHEN (spcd_p.Granularity = 991) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(datepart(q, td.term_start) as varchar) + ''-01'' 
			 WHEN (spcd_p.Granularity = 992) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
			 WHEN (spcd_p.Granularity = 993) THEN cast(Year(td.term_start) as varchar) + ''-01-01'' 
			 ELSE td.term_start 
		END AS DATETIME) proxy_curve_maturity,	
		CAST(CASE WHEN (spcd_p3.Granularity = 980) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(Month(td.term_start) as varchar) + ''-01'' 
			 WHEN (spcd_p3.Granularity = 991) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(datepart(q, td.term_start) as varchar) + ''-01'' 
			 WHEN (spcd_p3.Granularity = 992) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
			 WHEN (spcd_p3.Granularity = 993) THEN cast(Year(td.term_start) as varchar) + ''-01-01'' 
			 ELSE td.term_start 
		END AS DATETIME) proxy_curve_maturity3,
		CAST(CASE WHEN (spcd_m.Granularity = 980) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(Month(td.term_start) as varchar) + ''-01'' 
			 WHEN (spcd_m.Granularity = 991) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(datepart(q, td.term_start) as varchar) + ''-01'' 
			 WHEN (spcd_m.Granularity = 992) THEN cast(Year(td.term_start) as varchar) + ''-'' + cast(CASE datepart(q, td.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
			 WHEN (spcd_m.Granularity = 993) THEN cast(Year(td.term_start) as varchar) + ''-01-01'' 
			 ELSE td.term_start 
		END AS DATETIME) monthly_index_maturity,		 		
		spcd_m.Granularity monthly_index_granularity, 
		spcd_p.Granularity proxy_curve_granularity, 
		spcd_p3.Granularity proxy_curve_granularity3,
		spcd_p.Granularity settlement_curve_granularity, 
		ISNULL(td.func_cur_id, -1) func_cur_id, ISNULL(td.contract_id, -1) contract_id,
		cast(cast(year(rp.term_start) as varchar) + ''-'' + cast(MONTH(rp.term_start) as varchar) + ''-01'' as DATETIME) monthly_term, 
		td.term_start deal_term_start,td.term_end deal_term_end,
		[OB_value],[new_deal],[modify_deal],[forecast_changed],[deleted],[delivered],[CB_value],rp.formula_breakdown
		,td.volume_rounding, td.formula_id, td.pricing, td.formula_curve_id, td.original_formula_currency
	from '+@table_name+' rp inner join #temp_deals td on rp.source_deal_header_id=td.source_deal_header_id 
		and rp.term_start between td.term_start and td.term_end and rp.curve_id=isnull(td.curve_id,-1) and
			rp.location_id = isnull(td.location_id, -1) AND (td.hourly_position_breakdown= ''y'' or rp.hr=0) left join ---if cash deal then rp.hr=0 
		source_price_curve_def spcd ON spcd.source_curve_def_id = td.formula_curve_id left join
		source_price_curve_def spcd_p ON spcd_p.source_curve_def_id = spcd.proxy_source_curve_def_id left join
		source_price_curve_def spcd_p3 ON spcd_p3.source_curve_def_id = spcd.proxy_curve_id3 left join
		source_price_curve_def spcd_m ON spcd_m.source_curve_def_id = spcd.monthly_index left join
		source_price_curve_def spcd_s ON spcd_s.source_curve_def_id = spcd.monthly_index 
	WHERE (td.formula_curve_id IS NOT NULL AND td.formula_curve_id <> td.curve_id) AND (('''+@calc_type+''' <> ''s'' 
	AND rp.expiration_date > '''+CONVERT(VARCHAR(10),@as_of_date,120)+''' and rp.term_start > '''+CONVERT(VARCHAR(10),@as_of_date,120)+''') OR
		(1=1 '	+ case when @term_start is not null then ' AND rp.term_start >='''+@term_start +'''' else '' end
			+ case when @term_end is not null then 
				' AND rp.term_start <='''+CONVERT(varchar(10),case when  cast(@term_end as DATE)  > @curve_as_of_date then  @curve_as_of_date else cast(@term_end as DATE) END,120)+''''
			 else '' end		+'))
	'


	PRINT @sqlstmt
	EXEC(@sqlstmt)

	CREATE index indx_kk1c ON #hrl_pos_c (term_start)
	CREATE index indx_kk2c ON #hrl_pos_c (curve_granularity)
	CREATE index indx_kk3c ON #hrl_pos_c (proxy_curve_granularity)
	CREATE index indx_kk4c ON #hrl_pos_c (monthly_index_granularity)
	CREATE index indx_kk5c ON #hrl_pos_c (curve_id)
	CREATE index indx_kk6c ON #hrl_pos_c (proxy_curve_id)
	CREATE index indx_kk7c ON #hrl_pos_c (monthly_index)
	CREATE index indx_kk8c ON #hrl_pos_c (curve_maturity)
	CREATE index indx_kk9c ON #hrl_pos_c (proxy_curve_maturity)
	CREATE index indx_kk10c ON #hrl_pos_c (monthly_index_maturity)
	CREATE index indx_kk11c ON #hrl_pos_c (contract_id)
	CREATE index indx_kk12c ON #hrl_pos_c (commodity_id)
	CREATE index indx_kk13c ON #hrl_pos_c (func_cur_id)


	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '****************Saving Hourly Position and creating index for Contract Value*****************************'	
	END


	-------------Weighted Avg Contract Price for formula on the contract side ---------------------
	-- If pricing is 1603 which is Daily Wght Avg
	-- If pricing is 1604 which is Hourly Wght Avg (Not implemented now but for the future - needs to be added to static data value if required)



	SET @process_id2 = REPLACE(newid(),'-','_')
		
	SET @formula_table2=dbo.FNAProcessTableName('curve_formula_table2', @user_login_id, @process_id2)
		
	if OBJECT_ID(@formula_table2) is not null
		exec('drop table '+@formula_table2)
		
	SET @sql='
			CREATE TABLE '+@formula_table2+'(
				rowid int ,
				counterparty_id INT,
				contract_id INT,
				curve_id INT,
				prod_date DATETIME,
				as_of_date DATETIME,
				volume FLOAT,
				onPeakVolume FLOAT,
				source_deal_detail_id INT,
				formula_id INT,
				invoice_Line_item_id INT,			
				invoice_line_item_seq_id INT,
				price FLOAT,			
				granularity INT,
				volume_uom_id INT,
				generator_id INT,
				[Hour] INT,
				commodity_id INT,
				meter_id INT,
				curve_source_value_id INT,
				[mins] INT
			)	'
			
	EXEC(@sql)	
		
	CREATE TABLE #tx2([ID] INT IDENTITY, as_of_date DATETIME, term_start DATETIME, formula_id INT, granularity INT, contract_id INT, source_deal_detail_id INT, volume FLOAT)

	CREATE TABLE #formula_value2
	(term_start datetime, formula_id INT, contract_expiration_date datetime, formula_value float,contract_id INT, source_deal_detail_id INT)

	CREATE TABLE #formula_value2_to
	(term_start datetime, formula_id INT, contract_expiration_date datetime, formula_value float,contract_id INT, source_deal_detail_id INT)

	SET @sql='
	INSERT INTO #tx2 (as_of_date, term_start, formula_id, granularity,contract_id,source_deal_detail_id, volume)
	select  '''+@as_of_date +''' as_of_date, t.term_start, t.formula_id, 980 granularity, MAX(t.contract_id), t.source_deal_detail_id,
			SUM('+ case when @ob_calc='n' then '[CB_value]' else '[OB_value]' end +') volume 		 
	from	#hrl_pos_c t
	WHERE   t.formula_id is not null AND t.formula_curve_id IS NULL AND t.pricing IN (1603) -- Weighted Daily and Hourly pricing 
	group by t.term_start, t.formula_id, t.source_deal_detail_id'

	Exec(@sql)

	SET @sql=' INSERT INTO '+@formula_table2+'(rowid,formula_id,curve_source_value_id,prod_date, as_of_date,granularity,contract_id, source_deal_detail_id, volume)
				SELECT 	[ID], formula_id, ' + cast(@curve_source_value_id as varchar) + ', term_start, as_of_date, granularity,contract_id, source_deal_detail_id, volume
				FROM #tx2
		'

	Exec(@sql)
	
	SET @process_id2 = REPLACE(newid(),'-','_')
	 
	EXEC spa_calculate_formula	@as_of_date, @formula_table2, @process_id2, @calc_result_table2 output, @calc_result_table_breakdown2 output,'n',@ob_calc

	SET @sql='INSERT INTO #formula_value2
			select crt.prod_date, crt.formula_id, NULL contract_expiration_date, 
			nullif(crt.formula_eval_value, 0) formula_value, 
			ISNULL(crt.contract_id,-1) contract_id,
			crt.source_deal_detail_id
			from ' +  @calc_result_table2 + ' crt ' 

	exec (@sql)

	create index indx_source_deal_detail_id_formula_value2 on #formula_value2 (source_deal_detail_id)
	create index indx_term_start_formula_value2 on #formula_value2 (term_start)

	SET @sql=' update '+@formula_table2+' set prod_date='''+convert(varchar(10),@curve_as_of_date,120)+''''

	Exec(@sql)
	
	 SET @process_id2 = REPLACE(newid(),'-','_')

	EXEC spa_calculate_formula	@curve_as_of_date, @formula_table2, @process_id2, @calc_result_table2 output, @calc_result_table_breakdown2 output,'n',@ob_calc

	SET @sql='INSERT INTO #formula_value2_to
			select crt.prod_date, crt.formula_id, NULL contract_expiration_date, 
			nullif(crt.formula_eval_value, 0) formula_value, 
			ISNULL(crt.contract_id,-1) contract_id,
			crt.source_deal_detail_id
			from ' +  @calc_result_table2 + ' crt ' 

	exec (@sql)

	create index indx_source_deal_detail_id_formula_value2_to on #formula_value2_to (source_deal_detail_id)
	create index indx_term_start_formula_value2_to on #formula_value2_to (term_start)


	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '****************Calculated weighted average daily price on formula on contract side..*****************************'	
	END

	insert into  #tmp_hourly_price_vol_c
	select
		vol.source_deal_header_id, vol.leg, vol.location_id, vol.curve_id formula_curve_id, vol.monthly_term, 
		vol.deal_term_start, vol.term_start monthly_term_end,vol.hr,
		
		vol.b_s_mult* isnull(coalesce( round(f.formula_value, isnull(cfr.formula_rounding, 100)),pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.[OB_value],0) contract_value_OB_value,
		isnull(coalesce(round(f.formula_value, isnull(cfr.formula_rounding, 100)), pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.[OB_value],0) curve_value_OB_value,
		vol.b_s_mult*isnull(vol.[OB_value],0) volume_OB_value,
			
		vol.b_s_mult*isnull(coalesce(round(f_to.formula_value, isnull(cfr.formula_rounding, 100)), pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[new_deal],0) contract_value_new_deal,
		isnull(coalesce( round(f_to.formula_value, isnull(cfr.formula_rounding, 100)),pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[new_deal],0) curve_value_new_deal,
		vol.b_s_mult*isnull(vol.[new_deal],0) volume_new_deal,
		
		vol.b_s_mult*isnull(coalesce( round(f_to.formula_value, isnull(cfr.formula_rounding, 100)),pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[modify_deal],0) contract_value_modify_deal,
		isnull(coalesce( round(f_to.formula_value, isnull(cfr.formula_rounding, 100)),pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[modify_deal],0) curve_value_modify_deal,
		vol.b_s_mult*isnull(vol.[modify_deal],0) volume_modify_deal,
		
		vol.b_s_mult*isnull(coalesce(round(f_to.formula_value, isnull(cfr.formula_rounding, 100)), pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[forecast_changed],0) contract_value_forecast_changed,
		isnull(coalesce( round(f_to.formula_value, isnull(cfr.formula_rounding, 100)),pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[forecast_changed],0) curve_value_forecast_changed,
		vol.b_s_mult*isnull(vol.[forecast_changed],0) volume_forecast_changed,
		
		coalesce( round(f.formula_value, isnull(cfr.formula_rounding, 100)),pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value) avg_curve_value,
		
		vol.b_s_mult*isnull(coalesce( round(f.formula_value, isnull(cfr.formula_rounding, 100)), pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.[deleted],0) contract_value_deleted,
		isnull(coalesce(round(f.formula_value, isnull(cfr.formula_rounding, 100)), pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.[deleted],0) curve_value_deleted,
		vol.b_s_mult*isnull(vol.[deleted],0) volume_deleted,
		
		vol.b_s_mult*isnull(coalesce( round(f.formula_value, isnull(cfr.formula_rounding, 100)),pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.delivered,0) contract_value_delivered,
		isnull(coalesce( round(f.formula_value, isnull(cfr.formula_rounding, 100)),pr1.curve_value, pr2.curve_value, pr3.curve_value, pr4.curve_value, pr5.curve_value, pr6.curve_value)* vol.delivered,0) curve_value_delivered,
		vol.b_s_mult*isnull(vol.delivered,0) volume_delivered,

		vol.b_s_mult*isnull(coalesce( round(f_to.formula_value, isnull(cfr.formula_rounding, 100)), pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[CB_value],0) market_value_CB_value,
		isnull(coalesce(round(f_to.formula_value, isnull(cfr.formula_rounding, 100)),pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value)* vol.[CB_value],0) curve_value_CB_value,
		vol.b_s_mult*isnull(vol.[CB_value],0) volume_CB_value,

		coalesce( round(f_to.formula_value, isnull(cfr.formula_rounding, 100)),pr1_to.curve_value, pr2_to.curve_value, pr3_to.curve_value, pr4_to.curve_value, pr5_to.curve_value, pr6_to.curve_value) avg_curve_value_to
		,vol.formula_breakdown
	FROM #hrl_pos_c vol INNER JOIN 
	#hrly_price_curves pr1  ON pr1.maturity_date=vol.term_start AND vol.curve_granularity IN (981,982) AND  
				pr1.curve_id=vol.curve_id AND case when pr1.granularity =981 then -1 else pr1.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end   LEFT JOIN -- original curve
	#hrly_price_curves pr2 ON pr2.maturity_date=vol.term_start and vol.proxy_curve_granularity IN (981,982)  AND
				pr2.curve_id=vol.proxy_curve_id AND case when pr2.granularity =981 then -1 else pr2.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end LEFT JOIN -- proxy curve
	#hrly_price_curves pr3 ON pr3.maturity_date=vol.term_start and vol.monthly_index_granularity IN (981,982)  AND
				pr3.curve_id=vol.monthly_index AND case when pr3.granularity =981 then -1 else pr3.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end LEFT JOIN -- monthly index curve	
	#temp_curves pr4 ON pr4.maturity_date=vol.curve_maturity and vol.curve_granularity NOT IN (981,982) AND 
				pr4.source_curve_def_id = vol.curve_id AND pr4.as_of_date = @as_of_date  LEFT JOIN --original curve higher granularity 
	#temp_curves pr5 ON pr5.maturity_date=vol.proxy_curve_maturity and vol.proxy_curve_granularity NOT IN (981,982) AND 
				pr5.source_curve_def_id = vol.proxy_curve_id AND pr5.as_of_date = @as_of_date LEFT JOIN --proxly curve higher granularity 
	#temp_curves pr6 ON pr6.maturity_date=vol.monthly_index_maturity and vol.monthly_index_granularity NOT IN (981,982) AND 
				pr6.source_curve_def_id = vol.monthly_index AND pr6.as_of_date = @as_of_date LEFT JOIN --monthly index curve higher granularity 
	#temp_curves pr6b ON pr6b.maturity_date=vol.proxy_curve_maturity3 and vol.proxy_curve_granularity3 NOT IN (981,982) AND 
				pr6b.source_curve_def_id = vol.proxy_curve_id3 AND pr6b.as_of_date = @as_of_date LEFT JOIN --proxly curve higher granularity 
	#lag_curves_values lcv ON lcv.curve_id = vol.curve_id AND lcv.term_start = vol.curve_maturity AND 
			lcv.contract_id =  vol.contract_id AND lcv.func_cur_id = vol.func_cur_id				
	LEFT JOIN 	
	#hrly_price_curves_to pr1_to  ON pr1_to.maturity_date=vol.term_start AND vol.curve_granularity IN (981,982) AND  
				pr1_to.curve_id=vol.curve_id AND case when pr1_to.granularity =981 then -1 else pr1_to.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end LEFT JOIN -- original curve
	#hrly_price_curves_to pr2_to ON pr2_to.maturity_date=vol.term_start and vol.proxy_curve_granularity IN (981,982)  AND
				pr2_to.curve_id=vol.proxy_curve_id AND case when pr2_to.granularity =981 then -1 else pr2_to.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end LEFT JOIN -- proxy curve
	#hrly_price_curves_to pr3_to ON pr3_to.maturity_date=vol.term_start and vol.monthly_index_granularity IN (981,982)  AND
				pr3_to.curve_id=vol.monthly_index  AND case when pr3_to.granularity =981 then -1 else pr3_to.hr end =case when vol.curve_granularity =981 then -1 else vol.hr end LEFT JOIN -- monthly index curve	
	#temp_curves_to pr4_to ON pr4_to.maturity_date=vol.curve_maturity and vol.curve_granularity NOT IN (981,982) AND 
				pr4_to.source_curve_def_id = vol.curve_id AND pr4_to.as_of_date = @curve_as_of_date  LEFT JOIN --original curve higher granularity 
	#temp_curves_to pr5_to ON pr5_to.maturity_date=vol.proxy_curve_maturity and vol.proxy_curve_granularity NOT IN (981,982) AND 
				pr5_to.source_curve_def_id = vol.proxy_curve_id AND pr5_to.as_of_date = @curve_as_of_date LEFT JOIN --proxly curve higher granularity 
	#temp_curves_to pr6_to ON pr6_to.maturity_date=vol.monthly_index_maturity and vol.monthly_index_granularity NOT IN (981,982) AND 
				pr6_to.source_curve_def_id = vol.monthly_index AND pr6_to.as_of_date = @curve_as_of_date LEFT JOIN --monthly index curve higher granularity 
	#temp_curves pr6b_to ON pr6b_to.maturity_date=vol.proxy_curve_maturity3 and vol.proxy_curve_granularity3 NOT IN (981,982) AND 
				pr6b_to.source_curve_def_id = vol.proxy_curve_id3 AND pr6b_to.as_of_date = @curve_as_of_date LEFT JOIN --proxly curve higher granularity 
	#lag_curves_values_to lcv_to ON lcv_to.curve_id = vol.curve_id AND lcv_to.term_start = vol.curve_maturity AND 
				lcv_to.contract_id =  vol.contract_id AND lcv_to.func_cur_id = vol.func_cur_id	left join				
	#formula_value2 f ON vol.source_deal_detail_id = f.source_deal_detail_id AND
				vol.term_start = f.term_start LEFT OUTER JOIN 
	contract_formula_rounding cfr on cfr.contract_id = vol.contract_id AND cfr.formula_currency = vol.original_formula_currency left join
	#formula_value2_to f_to ON vol.source_deal_detail_id = f_to.source_deal_detail_id AND
				vol.term_start = f_to.term_start

	create index indx_tmp_hour_tmp_hourly_price_volly_price_vol_c_deal111 on  #tmp_hourly_price_vol_c(source_deal_header_id,formula_curve_id,deal_term_start)
	--select * from #tmp_hourly_price_vol_c
	--return
	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '****************End of Calculating Hourly Contract Values*****************************'	
	END

	SET @from1='
		,a.discount_factor discount_factor 
		,a.func_cur_id currency_id
		,ISNULL(hv.formula_breakdown,hv_c.formula_breakdown) formula_breakdown,a.physical_financial_flag
		from #temp_deals a 
		left outer join #tmp_hourly_price_vol hv on
		hv.source_deal_header_id=a.source_deal_header_id and hv.curve_id=isnull(a.curve_id,-1) and hv.deal_term_start=a.term_start and	
			hv.leg = a.leg LEFT OUTER JOIN
		#tmp_hourly_price_vol_c hv_c on
			hv_c.source_deal_header_id=a.source_deal_header_id and hv_c.formula_curve_id=a.formula_curve_id and hv_c.deal_term_start=a.term_start and	
			hv_c.leg = a.leg LEFT OUTER JOIN		
		#temp_curves tc ON tc.source_curve_def_id = a.curve_id AND 
			 tc.maturity_date = a.curve_type_maturity_date AND
			 tc.as_of_date = a.exp_curve_as_of_date LEFT OUTER JOIN	 
		#temp_curves tc_p ON tc_p.source_curve_def_id = a.proxy_curve_id AND 
			 tc_p.maturity_date = a.proxy_curve_maturity AND
			 tc_p.as_of_date = '''+ convert(varchar(10),@curve_as_of_date,120) +'''   LEFT OUTER JOIN
		#temp_curves tc_m ON tc_m.source_curve_def_id = a.monthly_index AND 
			 tc_m.maturity_date = a.monthly_index_maturity AND
			 tc_m.as_of_date = '''+ convert(varchar(10),@curve_as_of_date,120) +''' 	'
			 
	SET @from2='		 	 		 		 
		LEFT OUTER JOIN #avg_temp_curves atc ON atc.source_deal_header_id = a.source_deal_header_id AND	atc.leg = a.leg 
		LEFT OUTER JOIN #lag_curves_values lcv ON lcv.curve_id = a.curve_id AND lcv.term_start = a.term_start AND 
			lcv.contract_id = isnull(a.contract_id, -1) AND lcv.func_cur_id = ISNULL(a.func_cur_id, -1)	
		LEFT JOIN 					
			#temp_curves_to tc_to ON tc_to.source_curve_def_id = a.curve_id AND 
				 tc_to.maturity_date = a.curve_type_maturity_date AND
				 tc_to.as_of_date = a.exp_curve_as_of_date LEFT OUTER JOIN	 
			#temp_curves_to tc_p_to ON tc_p_to.source_curve_def_id = a.proxy_curve_id AND 
				 tc_p_to.maturity_date = a.proxy_curve_maturity AND
				 tc_p_to.as_of_date = '''+ convert(varchar(10),@as_of_date_to,120) +'''   LEFT OUTER JOIN
			#temp_curves_to tc_m_to ON tc_m_to.source_curve_def_id = a.monthly_index AND 
				 tc_m_to.maturity_date = a.monthly_index_maturity AND
				 tc_m_to.as_of_date ='''+ convert(varchar(10),@as_of_date_to,120) +'''	 		 		 
		LEFT OUTER JOIN #avg_temp_curves_to atc_to ON atc_to.source_deal_header_id = a.source_deal_header_id AND
				atc_to.leg = a.leg 
		LEFT OUTER JOIN #lag_curves_values_to lcv_to ON lcv_to.curve_id = a.curve_id AND lcv_to.term_start = a.term_start AND 
			lcv_to.contract_id = isnull(a.contract_id, -1) AND lcv_to.func_cur_id = ISNULL(a.func_cur_id, -1)	
		'	

	SET @from3='	
		LEFT OUTER JOIN #curve_uom_conv_factor cucf ON  
				cucf.deal_volume_uom_id = a.deal_volume_uom_id and cucf.curve_uom_id  = a.curve_uom_id
		LEFT OUTER JOIN #curve_uom_conv_factor cucfP ON  
				cucfP.deal_volume_uom_id = a.deal_volume_uom_id and cucfP.curve_uom_id  = a.price_uom_id
		LEFT OUTER JOIN #fx_curves pfcf ON pfcf.fx_currency_id = a.fixed_price_currency_id AND 
				pfcf.func_cur_id = a.func_cur_id AND pfcf.source_system_id = a.source_system_id AND
				pfcf.as_of_date= a.exp_curve_as_of_date AND pfcf.maturity_date= a.monthly_maturity
		LEFT OUTER JOIN #fx_curves cfcf ON cfcf.fx_currency_id = a.curve_currency_id AND 
				cfcf.func_cur_id = a.func_cur_id AND cfcf.source_system_id = a.source_system_id AND
				cfcf.as_of_date= a.exp_curve_as_of_date AND cfcf.maturity_date= a.monthly_maturity
		LEFT OUTER JOIN #fx_curves fcucf ON fcucf.fx_currency_id = a.fixed_cost_currency AND 
				fcucf.func_cur_id = a.func_cur_id AND fcucf.source_system_id = a.source_system_id AND
				fcucf.as_of_date= a.exp_curve_as_of_date AND fcucf.maturity_date= a.monthly_maturity
		LEFT OUTER JOIN #fx_curves foucf ON foucf.fx_currency_id = a.formula_currency AND 
				foucf.func_cur_id = a.func_cur_id AND foucf.source_system_id = a.source_system_id AND
				foucf.as_of_date= a.exp_curve_as_of_date AND foucf.maturity_date= a.monthly_maturity
		LEFT OUTER JOIN #fx_curves pa1ucf ON pa1ucf.fx_currency_id = a.price_adder_currency AND 
				pa1ucf.func_cur_id = a.func_cur_id AND pa1ucf.source_system_id = a.source_system_id AND
				pa1ucf.as_of_date= a.exp_curve_as_of_date AND pa1ucf.maturity_date= a.monthly_maturity
		LEFT OUTER JOIN #fx_curves pa2ucf ON pa2ucf.fx_currency_id = a.price_adder2_currency AND 
				pa2ucf.func_cur_id = a.func_cur_id AND pa2ucf.source_system_id = a.source_system_id AND
				pa2ucf.as_of_date= a.exp_curve_as_of_date AND pa2ucf.maturity_date= a.monthly_maturity
		'

	SET @from4='	
		LEFT OUTER JOIN #formula_value f ON a.source_deal_detail_id = f.source_deal_detail_id AND
				a.term_start = f.term_start
		LEFT OUTER JOIN #formula_value_to f_to ON a.term_start = f_to.term_start and
				a.source_deal_detail_id = f_to.source_deal_detail_id			
		LEFT OUTER JOIN #lag_curves_values_fx lfx ON lfx.fx_currency_id = a.fixed_price_currency_id AND 
				lfx.func_cur_id = a.func_cur_id AND lfx.source_system_id = a.source_system_id AND
				lfx.as_of_date= a.exp_curve_as_of_date AND lfx.maturity_date= a.monthly_maturity AND
				(a.pricing=1600 OR a.pricing=1601 OR a.pricing=1602)
		LEFT OUTER JOIN contract_formula_rounding_options cr on cr.contract_id = a.contract_id and cr.curve_id = a.curve_id	and
				a.pricing <> 1601 and a.pricing <> 1602	
		LEFT OUTER JOIN contract_formula_rounding_options pr on pr.contract_id = a.contract_id and pr.curve_id = a.fixed_price_currency_id		
		LEFT OUTER JOIN contract_formula_rounding cfr on cfr.contract_id = a.contract_id AND cfr.formula_currency = a.original_formula_currency
		left join	#temp_curves tc_p3 ON tc_p3.source_curve_def_id = a.proxy_curve_id3 AND 
			 tc_p3.maturity_date = a.proxy_curve_maturity3 AND
			 tc_p3.as_of_date = '''+ convert(varchar(10),@as_of_date,120) +'''
		left join	#temp_curves tc_p3_to ON tc_p3.source_curve_def_id = a.proxy_curve_id3 AND 
			 tc_p3.maturity_date = a.proxy_curve_maturity3 AND
			 tc_p3.as_of_date = '''+ convert(varchar(10),@curve_as_of_date,120) +'''
		'
	SET @where='	
		where ISNULL(a.option_flag, ''n'') = ''n'' AND a.internal_deal_type_value_id <> 6 AND a.internal_deal_type_value_id <> 7
			AND ISNULL(hv.monthly_term_end,hv_c.monthly_term_end) IS NOT NULL 
		-- AND(a.hourly_position_breakdown<>''y'' OR (a.hourly_position_breakdown=''y'' AND hv.curve_id IS NOT NULL))
		'


																				
	if @ob_calc='n'
	begin
		SET @dst='
			INSERT INTO  #explain_mtm(
				[source_deal_header_id],[curve_id],[location_id],[term_start],[hr],[market_ob_value]
				,[contract_ob_value],[ob_mtm],[market_new_deal],[contract_new_deal],[new_deal]
				,[market_forecast_changed],[contract_forecast_changed],[forecast_changed],[market_deleted],[contract_deleted],[deleted]
				,[market_delivered],[contract_delivered],[delivered],[market_cb_value],[contract_cb_value],[cb_mtm]	,[price_changed]
				,[discount_factor],[currency_id],formula_breakdown,physical_financial_flag)
		'
		
	--	set @dst=''
		PRINT @dst
		PRINT 'SELECT '
		PRINT @fields
		PRINT @market_ob_value
		PRINT @contract_ob_value
		PRINT @OB_MTM
		PRINT @market_new_deal
		PRINT @contract_new_deal
		PRINT @new_deal
		PRINT @market_forecast_changed
		PRINT @contract_forecast_changed
		PRINT @forecast_changed
		PRINT @market_deleted
		PRINT @contract_deleted
		PRINT @deleted
		PRINT @market_delivered
		PRINT @contract_delivered
		PRINT @delivered
		PRINT @market_cb_value
		PRINT @contract_cb_value
		PRINT @CB_MTM
		PRINT @price_changed
		PRINT @from1
		PRINT @from2
		PRINT @from3
		PRINT @from4
		PRINT @where

		exec(@dst+
			'SELECT ' +
			@fields+
			@market_ob_value+
			@contract_ob_value+
			@OB_MTM+
			@market_new_deal+
			@contract_new_deal+
			@new_deal+
			@market_forecast_changed+
			@contract_forecast_changed+
			@forecast_changed+
			@market_deleted+
			@contract_deleted+
			@deleted+
			@market_delivered+
			@contract_delivered+
			@delivered+
			@market_cb_value+
			@contract_cb_value+
			@CB_MTM+
			@price_changed+
			@from1+
			@from2+
			@from3+
			@from4+
			@where
		)	
	end	
	else
	begin
	
		SET @dst='
			INSERT INTO  #explain_mtm_ob(
				[source_deal_header_id],[curve_id],[location_id],[term_start],[hr],[market_ob_value]
				,[contract_ob_value],[ob_mtm],[discount_factor],[currency_id],formula_breakdown,physical_financial_flag)
		'
	--	set @dst=''
		PRINT @dst
		PRINT 'SELECT '
		PRINT @fields
		PRINT @market_ob_value
		PRINT @contract_ob_value
		PRINT @OB_MTM
		PRINT @from1
		PRINT @from2
		PRINT @from3
		PRINT @from4
		PRINT @where

		exec(@dst+
			'SELECT ' +
			@fields+
			@market_ob_value+
			@contract_ob_value+
			@OB_MTM+
			@from1+
			@from2+
			@from3+
			@from4+
			@where
		)
	end	

	if @ob_calc='y'
		BREAK 
	
	select  @deal_header_source='#source_deal_header_ob',@deal_detail_source='#source_deal_detail_ob',@ob_calc='y'
	
end
-------------------------end of mtm_loop--------------------------------------------------------------
--return
--select * from #source_deal_detail_ob
--select * from #source_deal_detail

--select * from #explain_mtm_ob
--select * from #explain_mtm

CREATE TABLE #explain_mtm_cash(
		[source_deal_header_id] [int] NOT NULL,
		[curve_id] [int] NULL,
		[location_id] [int] NULL,
		[term_start] [datetime] NULL,
		[hr] [tinyint] NULL,
		[market_ob_value] [float] NULL,
		[contract_ob_value] [float] NULL,
		[ob_mtm] [float] NULL,
		[market_new_deal] [float] NULL,
		[contract_new_deal] [float] NULL,
		[new_deal] [float] NULL,
		[market_forecast_changed] [float] NULL,
		[contract_forecast_changed] [float] NULL,
		[forecast_changed] [float] NULL,
		[market_deleted] [float] NULL,
		[contract_deleted] [float] NULL,
		[deleted] [float] NULL,
		[market_delivered] [float] NULL,
		[contract_delivered] [float] NULL,
		[delivered] [float] NULL,
		[market_cb_value] [float] NULL,
		[contract_cb_value] [float] NULL,
		[cb_mtm] [float] NULL,
		[price_changed] [float] NULL,
		[discount_factor] [float] NULL,
		[currency_id] [int] NULL,
		[create_ts] [datetime] NULL,
		[create_user] [varchar](30) COLLATE DATABASE_DEFAULT NULL,
		formula_breakdown bit,physical_financial_flag VARCHAR(1) COLLATE DATABASE_DEFAULT
	)
	CREATE TABLE #explain_mtm_cash_ob(
		[source_deal_header_id] [int] NOT NULL,
		[curve_id] [int] NULL,
		[location_id] [int] NULL,
		[term_start] [datetime] NULL,
		[hr] [tinyint] NULL,
		[market_ob_value] [float] NULL,
		[contract_ob_value] [float] NULL,
		[ob_mtm] [float] NULL,
		[discount_factor] [float] NULL,
		[currency_id] [int] NULL,
		[create_ts] [datetime] NULL,
		[create_user] [varchar](30) COLLATE DATABASE_DEFAULT NULL,
		formula_breakdown bit,physical_financial_flag VARCHAR(1) COLLATE DATABASE_DEFAULT
	)


delete #explain_mtm_ob
 output deleted.* into #explain_mtm_cash_ob
   where hr=0
   
delete #explain_mtm
 output deleted.* into #explain_mtm_cash
   where hr=0
      
INSERT INTO  #explain_mtm_ob(
			[source_deal_header_id],[curve_id],[location_id],[term_start],[hr],[market_ob_value]
			,[contract_ob_value],[ob_mtm],[discount_factor],[currency_id],formula_breakdown,physical_financial_flag)
	
select  e.[source_deal_header_id],isnull(e.[curve_id],-1),isnull(e.[location_id],-1),hb.term_date [term_start] ,replace(hb.[hr],'hr','') hr
	,0,no_hrs*e.[contract_ob_value]/hb_term.term_hours
	,no_hrs*e.[ob_mtm]/hb_term.term_hours,e.[discount_factor],e.[currency_id],e.formula_breakdown,e.physical_financial_flag

 from #explain_mtm_cash_ob e inner join #source_deal_detail sdd on sdd.source_deal_header_id=e.source_deal_header_id
	and isnull(sdd.curve_id,-1)=isnull(e.curve_id,-1) and isnull(sdd.location_id,-1)=isnull(e.location_id,-1)
	and sdd.term_start=e.term_start
outer apply ( select nullif(sum(volume_mult),0) term_hours from hour_block_term (nolock) 
				where term_date between sdd.term_start and sdd.term_end 
					AND block_type = 12000 AND block_define_id = 292037
		) hb_term
outer apply 
(
	select term_date,hr,no_hrs from 
	(
		select hb.term_date,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
		 from hour_block_term hb (nolock) where hb.block_define_id=@baseload_block_define_id--292037 -- 
			and  hb.block_type=@baseload_block_type --12000 --	
			and hb.term_date between sdd.term_start and sdd.term_end
	) p
		UNPIVOT
		(no_hrs for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
		)AS u	
) hb


INSERT INTO  #explain_mtm(
	[source_deal_header_id],[curve_id],[location_id],[term_start],[hr],[market_ob_value]
	,[contract_ob_value],[ob_mtm],[market_new_deal],[contract_new_deal],[new_deal]
	,[market_forecast_changed],[contract_forecast_changed],[forecast_changed],[market_deleted],[contract_deleted],[deleted]
	,[market_delivered],[contract_delivered],[delivered],[market_cb_value],[contract_cb_value],[cb_mtm]	,[price_changed]
	,[discount_factor],[currency_id],formula_breakdown,physical_financial_flag
)

select	e.[source_deal_header_id],isnull(e.[curve_id],-1),isnull(e.[location_id],-1),hb.term_date [term_start] ,replace(hb.[hr],'hr','') hr
	,0,no_hrs*e.[contract_ob_value]/hb_term.term_hours,no_hrs*e.[ob_mtm]/hb_term.term_hours
	,0,0,0,0,0,0,0,0,0,0,0,0,0,no_hrs*e.[contract_cb_value]/hb_term.term_hours,no_hrs*e.[cb_mtm]/hb_term.term_hours,0
	,e.[discount_factor],e.[currency_id],e.formula_breakdown,e.physical_financial_flag
 from #explain_mtm_cash e inner join #source_deal_detail sdd on sdd.source_deal_header_id=e.source_deal_header_id
		and isnull(sdd.curve_id,-1)=isnull(e.curve_id,-1) and isnull(sdd.location_id,-1)=isnull(e.location_id,-1)
		and sdd.term_start=e.term_start
	outer apply ( select nullif(sum(volume_mult),0) term_hours from hour_block_term (nolock) 
					where term_date between sdd.term_start and sdd.term_end 
						AND block_type = @baseload_block_type AND block_define_id = @baseload_block_define_id
			) hb_term
	outer apply 
	(
		select term_date,hr,no_hrs from 
		(
			select hb.term_date,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
			 from hour_block_term hb (nolock) where hb.block_define_id=292037 --@baseload_block_define_id 
				and  hb.block_type=12000 --@baseload_block_type	
				and hb.term_date between sdd.term_start and sdd.term_end
		) p
			UNPIVOT
			(no_hrs for Hr IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
			)AS u	
	) hb





SELECT 
	e.[source_deal_header_id],e.[curve_id],isnull(e.[location_id],-1) location_id,cast(convert(varchar(8),e.[term_start],120)+'01' AS DATETIME) term_start
	,min(e.term_start) min_term,max(e.term_start) max_term
	,sum(isnull(o.[market_ob_value],e.[market_ob_value])) [market_ob_value]
	,sum(isnull(o.[contract_ob_value],e.[contract_ob_value])) [contract_ob_value],sum(isnull(o.[ob_mtm],e.[ob_mtm])) [ob_mtm]
	,sum([market_new_deal]) [market_new_deal]
	,sum([contract_new_deal]) [contract_new_deal],sum([new_deal]) [new_deal],sum([market_forecast_changed]) [market_forecast_changed]
	,sum([contract_forecast_changed]) [contract_forecast_changed]
	,sum([forecast_changed]) [forecast_changed],sum([market_deleted]) [market_deleted],sum([contract_deleted]) [contract_deleted]
	,sum([deleted]) [deleted],sum([market_delivered]) [market_delivered],sum([contract_delivered]) [contract_delivered],sum([delivered]) [delivered]
	,sum([market_cb_value]) [market_cb_value],sum([contract_cb_value]) [contract_cb_value],sum([cb_mtm]) [cb_mtm]
	,sum([price_changed]) [price_changed],max(e.[discount_factor]) [discount_factor],max(e.[currency_id]) [currency_id],e.formula_breakdown
	,e.physical_financial_flag
INTO #explain_mtm_monthly
FROM #explain_mtm e left join #explain_mtm_ob o on e.[source_deal_header_id]=o.[source_deal_header_id] and e.[curve_id]=o.[curve_id] 
	and  isnull(e.location_id,-1)=isnull(o.location_id,-1) and e.term_start=o.term_start and e.hr=o.hr
GROUP BY e.physical_financial_flag,e.[source_deal_header_id],e.[curve_id],e.[location_id],e.formula_breakdown,convert(varchar(8),e.[term_start],120)

-------------------------------------------------------------------------------------------------
-------------------------Start Month level calc---------------------------------------------------------------------------
---Start hedge deferral-----------------------------------------------------------
--DROP TABLE #tmp_sum_explain_mtm
SELECT hdv.source_deal_header_id,e.[curve_id],isnull(e.[location_id],-1) [location_id]
	, hdv.pnl_term,e.formula_breakdown,min(e.min_term) min_term,max(e.max_term) max_term,
	sum(e.market_ob_value) market_ob_value,
	sum(e.contract_ob_value) contract_ob_value,
	sum(e.OB_MTM) OB_MTM,
	sum(e.market_new_deal) market_new_deal,
	sum(e.contract_new_deal) contract_new_deal,
	sum(e.new_deal) new_deal,
	sum(e.market_forecast_changed) market_forecast_changed,
	sum(e.contract_forecast_changed) contract_forecast_changed,
	sum(e.forecast_changed) forecast_changed,
	sum(e.market_deleted) market_deleted,
	sum(e.contract_deleted) contract_deleted,
	sum(e.deleted) DELETED,
	sum(e.market_delivered) market_delivered,
	sum(e.contract_delivered) contract_delivered,
	sum(e.delivered) delivered,
	sum(e.market_cb_value) market_cb_value,
	sum(e.contract_cb_value) contract_cb_value,
	sum(e.cb_mtm) cb_mtm,
	sum(e.price_changed) price_changed,max([discount_factor]) [discount_factor],max([currency_id]) [currency_id]
	,e.physical_financial_flag
INTO #tmp_sum_explain_mtm	
FROM #explain_mtm_monthly e inner JOIN hedge_deferral_values hdv ON e.source_deal_header_id=hdv.source_deal_header_id 
	AND e.term_start=hdv.cash_flow_term AND hdv.as_of_date=@curve_as_of_date --'2011-11-01'
GROUP BY hdv.as_of_date,hdv.source_deal_header_id,e.[curve_id],e.[location_id],hdv.pnl_term,e.formula_breakdown,e.physical_financial_flag

SELECT hdv.source_deal_header_id,hdv.pnl_term, max(per_alloc) per_alloc
INTO #tmp_sum_per_alloc	
  FROM #explain_mtm_monthly e left JOIN hedge_deferral_values hdv 
	ON e.source_deal_header_id=hdv.source_deal_header_id 
		AND e.term_start= hdv.cash_flow_term AND hdv.as_of_date=@curve_as_of_date
GROUP BY hdv.source_deal_header_id,hdv.pnl_term

CREATE TABLE #inserted_deals (source_deal_header_id int)

INSERT INTO #explain_mtm_final(
		[source_deal_header_id],[curve_id],[location_id],[term_start],[market_ob_value]
		,[contract_ob_value],[ob_mtm],[market_new_deal],[contract_new_deal],[new_deal],[market_forecast_changed],[contract_forecast_changed]
		,[forecast_changed],[market_deleted],[contract_deleted],[deleted],[market_delivered],[contract_delivered],[delivered]
		,[market_cb_value],[contract_cb_value],[cb_mtm],[price_changed]
		--,[set_ob_value],[set_new_deal],[set_deal_modify],[set_forecast_changed],[set_deleted]
		--,[set_delivered],[set_price_changed],[set_cb_value]
		,[discount_factor],[currency_id],min_term,max_term,physical_financial_flag)
	OUTPUT INSERTED.source_deal_header_id into #inserted_deals
SELECT	e.[source_deal_header_id],e.[curve_id],e.[location_id],hdv.pnl_term
		,e.[market_ob_value]*hdv.per_alloc
		,e.[contract_ob_value]*hdv.per_alloc,e.[ob_mtm]*hdv.per_alloc,e.[market_new_deal]*hdv.per_alloc
		,e.[contract_new_deal]*hdv.per_alloc,e.[new_deal]*hdv.per_alloc,e.[market_forecast_changed]*hdv.per_alloc
		,e.[contract_forecast_changed]*hdv.per_alloc,e.[forecast_changed]*hdv.per_alloc
		,e.[market_deleted]*hdv.per_alloc,e.[contract_deleted]*hdv.per_alloc,e.[deleted]*hdv.per_alloc
		,e.[market_delivered]*hdv.per_alloc,e.[contract_delivered]*hdv.per_alloc,e.[delivered]*hdv.per_alloc
		,e.[market_cb_value]*hdv.per_alloc,e.[contract_cb_value]*hdv.per_alloc,[cb_mtm]*hdv.per_alloc
		,CASE WHEN e.formula_breakdown=1 THEN 0 ELSE [price_changed]*hdv.per_alloc END
		--,[set_ob_value],[set_new_deal],[set_other_modify],[set_forecast_changed],[set_deleted]
		--,[set_delivered],[set_price_changed],[set_cb_value]
		,[discount_factor],[currency_id],hdv.pnl_term,dateadd(MONTH,1,hdv.pnl_term)-1,e.physical_financial_flag
 FROM #tmp_sum_explain_mtm e INNER JOIN #tmp_sum_per_alloc hdv ON e.source_deal_header_id=hdv.source_deal_header_id 
	AND hdv.pnl_term=e.pnl_term --AND e.formula_breakdown=hdv.formula_breakdown
	
--ALTER TABLE #explain_mtm_final ADD market_other_modify FLOAT,contract_other_modify FLOAT,other_modify FLOAT

UPDATE #explain_mtm_final
SET market_other_modify=market_cb_value-(market_ob_value+market_new_deal+market_forecast_changed+market_deleted+market_delivered),
	contract_other_modify=contract_cb_value-(contract_ob_value+contract_new_deal+contract_forecast_changed+contract_deleted+contract_delivered),
	other_modify=round(cb_mtm-(ob_mtm+new_deal+forecast_changed+[deleted]+delivered+[price_changed]),8)	
	
UPDATE #explain_mtm_final
SET --[contract_new_deal]=0,[market_new_deal]=0,[new_deal]=0,
	[market_forecast_changed]=0,[contract_forecast_changed]=0
	,[forecast_changed]=0,[market_deleted]=0,[contract_deleted]=0,[deleted]=0,[price_changed]=0
	,[market_delivered]=-1*([market_ob_value]+[market_new_deal]),[contract_delivered]=-1*([contract_ob_value]+[contract_new_deal])
	,[delivered]=-1*([ob_mtm]+[new_deal])
where 	isnull(delivered ,0)<>0

UPDATE #explain_mtm_final
SET --[contract_new_deal]=0,[market_new_deal]=0,[new_deal]=0,
	[market_forecast_changed]=0,[contract_forecast_changed]=0
	,[forecast_changed]=0,[market_deleted]=-1*([market_ob_value]+[market_new_deal]),[contract_deleted]=-1*([contract_ob_value]+[contract_new_deal])
	,[deleted]=-1*([ob_mtm]+[new_deal]),[price_changed]=0
	,[market_delivered]=0,[contract_delivered]=0,[delivered]=0
where 	isnull(deleted ,0)<>0
--------------end hedge deferral-----------------------------------------------------------
	
---formula breakdown deferral-----------------------------------------------------------

SELECT  
	max(dpb.source_deal_detail_id) source_deal_detail_id,max(e.source_deal_header_id) source_deal_header_id,max(e.[curve_id]) [curve_id],max(e.[location_id]) [location_id]
	,max(sdd.term_start) term_start,max(sdd.term_end) term_end,
	min(dpb.fin_term_start) min_fin_term_start,max(dpb.fin_term_start) max_fin_term_start,
	max(sdd.total_volume) total_volume ,max(e.[discount_factor]) [discount_factor],max(e.[currency_id]) [currency_id]
INTO #left_side_term	
FROM source_deal_detail sdd INNER JOIN deal_position_break_down dpb ON sdd.source_deal_detail_id=dpb.source_deal_detail_id
	INNER JOIN #explain_mtm_monthly e  ON e.source_deal_header_id=dpb.source_deal_header_id AND e.term_start=dpb.fin_term_start
		AND dpb.curve_id=e.curve_id and  e.formula_breakdown=1
GROUP BY sdd.source_deal_detail_id

SELECT 
	 source_deal_header_id,e.[curve_id]	,min_fin_term_start,max_fin_term_start,	sum(e.total_volume) sum_total_volume
INTO  #sum_left_side_term
FROM 
	#left_side_term e
GROUP BY 
	 source_deal_header_id,e.[curve_id]	,min_fin_term_start,max_fin_term_start
 
INSERT INTO #explain_mtm_final(
	[source_deal_header_id],[curve_id],[location_id],[term_start],[market_ob_value]
	,[contract_ob_value],[ob_mtm],[market_new_deal],[contract_new_deal],[new_deal],[market_forecast_changed],[contract_forecast_changed]
	,[forecast_changed],[market_deleted],[contract_deleted],[deleted],[market_delivered],[contract_delivered],[delivered]
	,[market_cb_value],[contract_cb_value],[cb_mtm],[price_changed]
	,market_other_modify,contract_other_modify,other_modify
	--,[set_ob_value],[set_new_deal],[set_deal_modify],[set_forecast_changed],[set_deleted]
	--,[set_delivered],[set_price_changed],[set_cb_value]
	,[discount_factor],[currency_id],min_term,max_term)
SELECT e.[source_deal_header_id],e.[curve_id],e.[location_id],e.[term_start],0 [market_ob_value]
	,0 [contract_ob_value],0 [ob_mtm],0 [market_new_deal]
	,0 [contract_new_deal],0 [new_deal],0 [market_forecast_changed]
	,0 [contract_forecast_changed],0 [forecast_changed]
	,0 [market_deleted],0 [contract_deleted],0 [deleted]
	,0 [market_delivered],0 [contract_delivered],0 [delivered]
	,0 [market_cb_value],0 [contract_cb_value],0 [cb_mtm]
	,fin.[price_changed]*(e.total_volume/s.sum_total_volume) [price_changed]
	,0 market_other_modify,0 contract_other_modify,0 other_modify
	--,[set_ob_value],[set_new_deal],[set_other_modify],[set_forecast_changed],[set_deleted]
	--,[set_delivered],[set_price_changed],[set_cb_value]
	,[discount_factor],[currency_id],e.term_start,e.term_end
FROM #left_side_term e INNER JOIN  #sum_left_side_term s ON 
  e.source_deal_header_id=s.source_deal_header_id AND e.[curve_id]=s.[curve_id] AND e.term_start=s.min_fin_term_start AND e.term_start=s.max_fin_term_start
 CROSS APPLY (
 	SELECT sum([price_changed]) [price_changed]  FROM #explain_mtm_monthly e
 	WHERE formula_breakdown=1 and source_deal_header_id=e.source_deal_header_id AND [curve_id]=e.[curve_id] AND term_start BETWEEN s.min_fin_term_start AND s.max_fin_term_start
 ) fin
 
	
	--,set_modify_deal = set_cb_value -(set_ob_value+set_new_deal+set_forecast_changed+set_deleted+set_delivered)

-------------------------End Month level calc---------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------

 -------------------------Start hour level calc---------------------------------------------------------------------------

CREATE TABLE #explain_mtm_deal(
	[source_deal_header_id] [int] NOT NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[hr] [tinyint] NULL,
	[market_ob_value] [float] NULL,
	[contract_ob_value] [float] NULL,
	[ob_mtm] [float] NULL,
	[market_new_deal] [float] NULL,
	[contract_new_deal] [float] NULL,
	[new_deal] [float] NULL,
	[market_other_modify] [float] NULL,
	[contract_other_modify] [float] NULL,
	[other_modify] [float] NULL,
	[market_forecast_changed] [float] NULL,
	[contract_forecast_changed] [float] NULL,
	[forecast_changed] [float] NULL,
	[market_deleted] [float] NULL,
	[contract_deleted] [float] NULL,
	[deleted] [float] NULL,
	[market_delivered] [float] NULL,
	[contract_delivered] [float] NULL,
	[delivered] [float] NULL,
	[market_cb_value] [float] NULL,
	[contract_cb_value] [float] NULL,
	[cb_mtm] [float] NULL,
	[price_changed] [float] NULL,
	[discount_factor] [float] NULL,
	[currency_id] [int] NULL,
	physical_financial_flag varchar(1) COLLATE DATABASE_DEFAULT NULL
) 

SET @fields='INSERT INTO  #explain_mtm_deal(
		[source_deal_header_id],[curve_id],[location_id],[term_start],[hr],[market_ob_value],[contract_ob_value],[ob_mtm],[market_new_deal]
		,[contract_new_deal],[new_deal],[market_forecast_changed],[contract_forecast_changed],[forecast_changed],[market_deleted],[contract_deleted]
		,[deleted],[market_delivered],[contract_delivered],[delivered],[market_cb_value],[contract_cb_value],[cb_mtm],[price_changed],market_other_modify
		,contract_other_modify,other_modify,[discount_factor],[currency_id],physical_financial_flag)
	SELECT f.[source_deal_header_id],f.[curve_id],isnull(f.[location_id],-1),hr.term_date [term_start],hr.[hr]
		,sum([market_ob_value]/term_hrs.term_no_hrs) market_ob_value,sum([contract_ob_value]/term_hrs.term_no_hrs) contract_ob_value
		,sum([ob_mtm]/term_hrs.term_no_hrs) ob_mtm,sum([market_new_deal]/term_hrs.term_no_hrs) market_new_deal
		,sum([contract_new_deal]/term_hrs.term_no_hrs) contract_new_deal,sum([new_deal]/term_hrs.term_no_hrs) new_deal
		,sum([market_forecast_changed]/term_hrs.term_no_hrs) market_forecast_changed,sum([contract_forecast_changed]/term_hrs.term_no_hrs) contract_forecast_changed
		,sum([forecast_changed]/term_hrs.term_no_hrs) forecast_changed,sum([market_deleted]/term_hrs.term_no_hrs) market_deleted
		,sum([contract_deleted]/term_hrs.term_no_hrs) contract_deleted,sum([deleted]/term_hrs.term_no_hrs) DELETED
		,sum([market_delivered]/term_hrs.term_no_hrs) market_delivered,sum([contract_delivered]/term_hrs.term_no_hrs) contract_delivered
		,sum([delivered]/term_hrs.term_no_hrs) delivered,sum([market_cb_value]/term_hrs.term_no_hrs) market_cb_value
		,sum([contract_cb_value]/term_hrs.term_no_hrs) contract_cb_value,sum([cb_mtm]/term_hrs.term_no_hrs)	cb_mtm 
		,sum([price_changed]/term_hrs.term_no_hrs) price_changed,sum(market_other_modify/term_hrs.term_no_hrs) market_other_modify
		,sum(contract_other_modify/term_hrs.term_no_hrs) contract_other_modify,sum(other_modify/term_hrs.term_no_hrs) other_modify
		,max([discount_factor]) discount_factor,max([currency_id]) currency_id,f.physical_financial_flag
'

SET @from1=' FROM #explain_mtm_final f 
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=f.curve_id
		OUTER APPLY
		( 
			SELECT term_date,cast(substring(hr,3,2) AS INT) Hr FROM 
			(
				SELECT term_date,Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24
				FROM hour_block_term hb WHERE  hb.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+') --292037
					AND hb.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') --12000
					AND hb.term_date BETWEEN f.min_term AND f.max_term 
			) p
			UNPIVOT
			( hr_value for Hr IN
				(hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
			) AS u WHERE hr_value=1
		UNION ALL 	
			SELECT term_date, add_dst_hour hr FROM hour_block_term hb WHERE  hb.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')
				AND hb.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') AND hb.term_date BETWEEN f.min_term AND f.max_term AND add_dst_hour>0 		
		) hr
		OUTER APPLY 
		(
			SELECT sum(volume_mult) term_no_hrs FROM hour_block_term hbt WHERE hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	
				AND hbt.block_type= COALESCE(spcd.block_type,'+@baseload_block_type+') AND hbt.term_date BETWEEN f.min_term AND f.max_term 
		) term_hrs
	GROUP BY
		f.[source_deal_header_id],f.[curve_id],f.[location_id],hr.term_date,hr.[hr],f.physical_financial_flag
		
'

--All the item deal or hedge defferal not calculated hedge deal
SET @from2=' UNION ALL 
	SELECT e.[source_deal_header_id],e.[curve_id],isnull(e.[location_id],-1),e.[term_start]
	,e.[hr],isnull(o.[market_ob_value],e.[market_ob_value]) [market_ob_value]
		,isnull(o.[contract_ob_value],e.contract_ob_value) contract_ob_value,isnull(o.[ob_mtm],e.ob_mtm) ob_mtm
		,e.market_new_deal [market_new_deal],e.contract_new_deal  [contract_new_deal],e.new_deal  [new_deal]
		,case when isnull(e.[delivered],0)<>0 or isnull(e.[deleted],0)<>0 then 0  else e.market_forecast_changed end [market_forecast_changed]
		,case when isnull(e.[delivered],0)<>0 or isnull(e.[deleted],0)<>0 then 0  else e.contract_forecast_changed end [contract_forecast_changed]
		,case when isnull(e.[delivered],0)<>0 or isnull(e.[deleted],0)<>0 then 0  else e.forecast_changed  end [forecast_changed]
		,case when isnull(e.[delivered],0)<>0 then 0  else case when isnull(e.[deleted],0)=0 then 0 else -1* (isnull(o.[market_ob_value],e.[market_ob_value])+e.[market_new_deal]) end end [market_deleted]
		,case when isnull(e.[delivered],0)<>0 then 0  else case when isnull(e.[deleted],0)=0 then 0 else  -1* (isnull(o.[contract_ob_value],e.[contract_ob_value])+e.[contract_new_deal])  end end [contract_deleted]
		,case when isnull(e.[delivered],0)<>0 then 0  else case when isnull(e.[deleted],0)=0 then 0  else -1* (isnull(o.[ob_mtm],e.[ob_mtm])+e.[new_deal]) end end [deleted]
		,case when isnull(e.[delivered],0)=0 then 0 else -1* (isnull(o.[market_ob_value],e.[market_ob_value])+e.[market_new_deal] ) end [market_delivered]
		,case when isnull(e.[delivered],0)=0 then 0 else -1* (isnull(o.[contract_ob_value],e.[contract_ob_value])+e.[contract_new_deal])  end [contract_delivered]
		,case when isnull(e.[delivered],0)=0 then 0 else -1* (isnull(o.[ob_mtm],e.[ob_mtm])+e.[new_deal] )  end [delivered]
		,e.[market_cb_value],e.[contract_cb_value],e.[cb_mtm]
		,case when isnull(e.[delivered],0)<>0 or isnull(e.[deleted],0)<>0 then 0  else  e.[price_changed] end price_changed
		,case when isnull(e.[delivered],0)<>0 or isnull(e.[deleted],0)<>0 then 0  else  e.market_cb_value-(isnull(o.[market_ob_value],e.[market_ob_value])+e.market_new_deal+e.market_forecast_changed+e.market_deleted) end market_other_modify
		,case when isnull(e.[delivered],0)<>0 or isnull(e.[deleted],0)<>0 then 0  else  e.contract_cb_value-(isnull(o.[contract_ob_value],e.contract_ob_value)+e.contract_new_deal+e.contract_forecast_changed+e.contract_deleted) end contract_other_modify
		,case when isnull(e.[delivered],0)<>0 or isnull(e.[deleted],0)<>0 then 0  else  round(e.cb_mtm-(isnull(o.ob_mtm,e.ob_mtm)+e.new_deal+forecast_changed+[deleted]+[price_changed]),8) end other_modify	
		,e.[discount_factor],e.[currency_id],e.physical_financial_flag
	FROM #explain_mtm e LEFT JOIN 
		#explain_mtm_ob  o on e.[source_deal_header_id]=o.[source_deal_header_id] and e.[curve_id]=o.[curve_id] 
	and isnull(e.location_id,-1)=isnull(o.location_id,-1) and e.term_start=o.term_start and e.hr=o.hr  LEFT JOIN
		(SELECT DISTINCT source_deal_header_id FROM #inserted_deals) i ON e.source_deal_header_id=i.source_deal_header_id
	WHERE i.source_deal_header_id IS NULL 
'

PRINT @fields
PRINT @from1
PRINT @from2

exec(@fields+ @from1+@from2)

create index indx_explain_mtm_deal on #explain_mtm_deal ([source_deal_header_id],[curve_id],[location_id],[term_start])


if @orginal_calc_type in (0,1)
begin
	SET @dst='
		DELETE explain_mtm WHERE [as_of_date_from]='''+ convert(varchar(10),@as_of_date,120) +'''  AND [as_of_date_to]='''+ convert(varchar(10),@as_of_date_to,120) +''' 
		INSERT INTO  explain_mtm(
			[as_of_date_from],[as_of_date_to],[curve_id],[location_id],[term_start],[hr],[book_deal_type_map_id]
			,[broker_id],[profile_id],[deal_type_id],[trader_id],[contract_id],[product_id],[template_id],[deal_status_id]
			,[counterparty_id],[index_id],[pvparty_id],[uom_id],[physical_financial_flag],[buy_sell_Flag],[Category_id]
			,[user_toublock_id],[toublock_id],[market_ob_value],[contract_ob_value],[ob_mtm],[market_new_deal],[contract_new_deal]
			,[new_deal],[market_other_modify],[contract_other_modify],[other_modify],[market_forecast_changed],[contract_forecast_changed]
			,[forecast_changed],[market_deleted],[contract_deleted],[deleted],[market_delivered],[contract_delivered],[delivered]
			,[market_cb_value],[contract_cb_value],[cb_mtm],[price_changed],[discount_factor],[currency_id],[create_ts],[create_user]
		)
	'

	SET @from1='SELECT '''+convert(varchar(10),@as_of_date,120) +''' [as_of_date_from],'''+convert(varchar(10),@as_of_date_to,120) +''' [as_of_date_to]
		,f.[curve_id],f.[location_id],f.[term_start],f.[hr],ssbm.[book_deal_type_map_id]
		,sdh.[broker_id],sdh.internal_desk_id,sdh.source_deal_type_id,sdh.[trader_id],sdh.[contract_id],sdh.internal_portfolio_id,sdh.[template_id]
		,sdh.[deal_status],sdh.[counterparty_id],ISNULL(spcd1.source_curve_def_id,spcd.source_curve_def_id) [index_id],sdd.pv_party [pvparty_id]
		,ISNULL(spcd.display_uom_id,spcd.uom_id) [uom_id],sdd.[physical_financial_flag],sdd.[buy_sell_Flag],sdd.[Category]
		, COALESCE(spcd1.block_define_id,spcd.block_define_id) user_toublock_id,COALESCE(spcd1.udf_block_group_id,spcd.udf_block_group_id,grp.block_type_group_id) toublock_id
		,sum(f.[market_ob_value]),sum(f.[contract_ob_value]),sum(f.[ob_mtm]),sum(f.[market_new_deal]),sum(f.[contract_new_deal])
		,sum(f.[new_deal]),sum(f.[market_other_modify]),sum(f.[contract_other_modify]),sum(f.[other_modify]),sum(f.[market_forecast_changed])
		,sum(f.[contract_forecast_changed])	,sum(f.[forecast_changed]),sum(f.[market_deleted]),sum(f.[contract_deleted])
		,sum(f.[deleted]),sum(f.[market_delivered]),sum(f.[contract_delivered])
		,sum(f.[delivered]),sum(f.[market_cb_value]),sum(f.[contract_cb_value]),sum(f.[cb_mtm]),sum(f.[price_changed])
		,max(f.[discount_factor]),max(f.[currency_id]),getdate(),'''+@user_id+'''
		FROM #explain_mtm_deal f 		
		left join #source_deal_header sdh on sdh.source_deal_header_id=f.source_deal_header_id
		left join #source_deal_detail sdd on f.source_deal_header_id=sdd.source_deal_header_id and isnull(sdd.curve_id,-1)=isnull(f.curve_id,-1)
			and isnull(sdd.location_id,-1)=isnull(f.location_id,-1) and f.term_start between sdd.term_start and sdd.term_end
		left join source_system_book_map ssbm on sdh.source_system_book_id1 =ssbm.source_system_book_id1  and
			sdh.source_system_book_id2=ssbm.source_system_book_id2 and sdh.source_system_book_id3=ssbm.source_system_book_id3 
			and sdh.source_system_book_id4=ssbm.source_system_book_id4
		left JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id  
		LEFT JOIN  source_price_curve_def spcd1 ON  spcd1.source_curve_def_id=spcd.proxy_curve_id
		left join block_type_group grp ON ISNULL(spcd1.block_define_id,spcd.block_define_id)=grp.hourly_block_id 
			AND ISNULL(spcd.block_type,spcd.block_type)=grp.block_type_id 
		GROUP BY
		f.[curve_id],f.[location_id],f.[term_start],f.[hr],ssbm.[book_deal_type_map_id]
		,sdh.[broker_id],sdh.internal_desk_id,sdh.source_deal_type_id,sdh.[trader_id],sdh.[contract_id],sdh.internal_portfolio_id,sdh.[template_id]
		,sdh.[deal_status],sdh.[counterparty_id],ISNULL(spcd1.source_curve_def_id,spcd.source_curve_def_id),sdd.pv_party
		,ISNULL(spcd.display_uom_id,spcd.uom_id),sdd.[physical_financial_flag],sdd.[buy_sell_Flag],sdd.[Category]
		, COALESCE(spcd1.block_define_id,spcd.block_define_id),COALESCE(spcd1.udf_block_group_id,spcd.udf_block_group_id,grp.block_type_group_id)
	'
	print @dst
	print @from1
	exec( @dst+	 @from1)
	
	IF @orginal_calc_type IN ('0')
	RETURN
end


-----------------------------------------------------------------------------------------------------------------------

	---START Batch initilization--------------------------------------------------------
	--------------------------------------------------------------------------------------
--select @orginal_calc_type
IF @orginal_calc_type IN ('1','2')	
BEGIN  
	
	SET @str_batch_table = ''


	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

	IF @batch_process_id IS NULL
		SET @batch_process_id = dbo.FNAGetNewID()	

	IF @is_batch = 1
		SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
		
	set  @str_batch_table =ISNULL(@str_batch_table, '')
	IF @enable_paging = 1 --paging processing
	BEGIN
		SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

		--retrieve data from paging table instead of main table
		IF @page_no IS NOT NULL  
		BEGIN
			SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)    
			EXEC (@sql_paging)  
			RETURN  
		END
	END

END

	---END Batch initilization--------------------------------------------------------
	--------------------------------------------------------------------------------------
--/*


IF @orginal_calc_type IN ('2')	
BEGIN 
	SET @sqlstmt='SELECT 
			delta.[source_deal_header_id] [Deal ID],
			spcd.[curve_name] [Index],
			 CASE WHEN delta.physical_financial_flag=''p'' THEN ''Physical'' ELSE ''Financial'' END [Physical/Financial],
			dbo.FNADateFormat(delta.[term_start]) [Term]
			,delta.hr [Hr]
			,delta.[ob_mtm] [BeginningMTM] 
			,delta.new_deal [NewBusinessMTM]
			,delta.other_modify [OtherModifiedMTM]
			,delta.[DELETED] [DeletedMTM]
			,delta.forecast_changed [Re-forecastMTM]
			,delta.[delivered] [DeliveryMTM]
			,delta.[price_changed] [PriceChangedMTM]
			,delta.[cb_mtm] [EndingMTM]
			,sc.currency_name Currency
			'+ isnull(@str_batch_table,'') +'
		FROM #explain_mtm_deal delta
			LEFT JOIN  source_price_curve_def spcd 
				ON spcd.source_curve_def_id = delta.curve_id 
			LEFT JOIN source_minor_location sml 
				ON sml.source_minor_location_id = delta.location_id
			LEFT JOIN source_currency sc on sc.source_currency_id=delta.currency_id
		WHERE 1=1'
			+ CASE WHEN @term_start IS NULL THEN '' ELSE ' AND delta.term_start >= ''' + @term_start + '''' END
			+ CASE WHEN @term_end IS NULL THEN '' ELSE ' AND delta.term_start <= ''' + @term_end + '''' END
			+ case when @st_hr is null then '' else @st_hr end   + case when @st_criteria is null then '' else  @st_criteria end + 
		' ORDER BY delta.physical_financial_flag,[deal id], [index],delta.term_start,delta.hr'	        
	   

	PRINT(@sqlstmt)
	exec(@sqlstmt)
END 

 
IF @orginal_calc_type IN ('1')	
BEGIN 
	SET @sqlstmt='SELECT 
			spcd.[curve_name] [Index],
			 CASE WHEN delta.physical_financial_flag=''p'' THEN ''Physical'' ELSE ''Financial'' END [Physical/Financial],
			dbo.FNADateFormat(delta.[term_start]) [Term]
			,delta.hr [Hr]
			,delta.ob_mtm  [BeginningMTM] 
			,delta.new_deal [NewBusinessMTM]
			,delta.other_modify [OtherModifiedMTM]
			,delta.deleted [DeletedMTM]
			,delta.forecast_changed  [Re-forecastMTM]
			,delta.delivered [DeliveryMTM]
			,delta.cb_mtm [EndingMTM]
			,delta.price_changed [PriceChangedMTM]
			,sc.currency_name Currency
			'+ isnull(@str_batch_table,'') +'
		FROM explain_mtm delta
			LEFT JOIN  source_price_curve_def spcd 
				ON spcd.source_curve_def_id = delta.index_id 
			LEFT JOIN source_currency sc on sc.source_currency_id=delta.currency_id
		WHERE delta.as_of_date_from='''+convert(varchar(10),@as_of_date,120) +''' AND delta.as_of_date_to='''+convert(varchar(10),@as_of_date_to,120) +''''
		+ CASE WHEN @term_start IS NULL THEN '' ELSE ' AND delta.term_start >= ''' + CONVERT(VARCHAR(12), @term_start, 120) + '''' END
		+ CASE WHEN @term_end IS NULL THEN '' ELSE ' AND delta.term_start <= ''' + CONVERT(VARCHAR(12), @term_end, 120) + '''' END
		+ isnull(@st_hr,'') + isnull(@st_criteria,'') +  
		' ORDER BY delta.physical_financial_flag, [index],delta.term_start,delta.hr'	        
	    
	PRINT @str_batch_table
	PRINT(@sqlstmt)
	EXEC(@sqlstmt)
END 


/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
	EXEC(@str_batch_table)                   

	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_calc_explain_position', 'Explain MTM Report')         
	EXEC(@str_batch_table)        
	RETURN
END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END*****************************************/		
		
 	
FinalStep:
/************************************* Object: 'spa_calc_explain_mtm' END *************************************/





/************************************* Object: 'spa_calc_explain_mtm' END *************************************/
