BEGIN TRY
		BEGIN TRAN
	
	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'PNL_Explain_View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'PNL_Explain_View', description = ''
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_as_of_date_from         DATETIME = ''@as_of_date_from'',--''2015-03-16'',     -- ''2012-01-16'', --''2012-01-16''
        @_as_of_date_to           DATETIME = ''@as_of_date_to'',--''2015-03-17'',     --''2012-01-17'',
        @_sub                     VARCHAR(200) = NULL,  --''148'',
        @_str                     VARCHAR(200) = NULL,  --''150'',
        @_term_start              DATETIME = NULL,
        @_term_end                DATETIME = NULL,
        @_book                    VARCHAR(200) = null,  --''158'' ,--''206'',
        @_source_deal_header_ids  VARCHAR(500) =null,
        @_index                   VARCHAR(200) = null,
        @_round                   VARCHAR(1) = ''8'',

        @_batch_process_id        VARCHAR(50) = NULL,
        @_batch_report_param      VARCHAR(1000) = NULL,
        @_enable_paging           INT = 0,       --''1'' = enable, ''0'' = disable
        @_page_size               INT = NULL,
        @_page_no                 INT = NULL

IF ''@sub_id'' <> ''NULL''
                SET @_sub = ''@sub_id''
IF ''@stra_id'' <> ''NULL''
                SET @_str = ''@stra_id''
IF ''@book_id'' <> ''NULL''
                SET @_book = ''@book_id''


     
DECLARE @_status_type VARCHAR(1)
DECLARE @_desc VARCHAR(5000)
DECLARE @_error_count INT 
DECLARE @_saved_records INT
DECLARE @_stmt VARCHAR(8000)
-----------------------------------------


DECLARE @_baseload_block_type VARCHAR(10)
DECLARE @_baseload_block_define_id VARCHAR(10)--,@_orginal_summary_option CHAR(1)
DECLARE @_st1 VARCHAR(MAX),
        @_st2 VARCHAR(MAX),
        @_st2_0 VARCHAR(MAX),
        @_st2a VARCHAR(MAX),
        @_st2b VARCHAR(MAX),
        @_st3 VARCHAR(MAX),
        @_st4 VARCHAR(MAX),
        @_st5 VARCHAR(MAX),
        @_st_fields VARCHAR(MAX),
        @_st_group_by VARCHAR(MAX),
        @_st_from VARCHAR(MAX),
        @_st_term VARCHAR(1000),
        @_st_criteria VARCHAR(MAX),
        @_source_deal_header VARCHAR(200),
        @_source_deal_detail VARCHAR(200),
        @_report_hourly_position_breakdown VARCHAR(200),
        @_delta_report_hourly_position_breakdown VARCHAR(200),
        @_report_hourly_position_breakdown_detail VARCHAR(200),
        @_delta_report_hourly_position_breakdown_detail VARCHAR(200),
        @_report_hourly_position_breakdown_detail_delivered VARCHAR(300),
        @_report_hourly_position_breakdown_detail_ending VARCHAR(300),
        @_modify_status VARCHAR(300),
        @_price_change_value VARCHAR(300),
        @_index_fee_breakdown_reforecast VARCHAR(300),
        @_temp_discounted_mtm_factor VARCHAR(200),
        @_delivered_position VARCHAR(200),
        @_deferral_temp_explain_mtm VARCHAR(200),
        @_tmp_price_changed_phy VARCHAR(200),
        @_tmp_price_changed_formula VARCHAR(200),
        @_fin_term_ratio VARCHAR(200),
        @_temp_explain_mtm_formula VARCHAR(200),
        @_temp_explain_mtm VARCHAR(200),
        @_final_explain_mtm VARCHAR(200),
        @_forecast_position VARCHAR(200),
        @_explain_reforecast_deals VARCHAR(300),
        @_explain_delivered_mtm VARCHAR(200),
        @_explain_modified_mtm VARCHAR(200),
        @_sum_left_side_term VARCHAR(200),
        @_left_side_term VARCHAR(200),
        @_process_id VARCHAR(150),
        @_tmp_price_diff VARCHAR(200),
        @_udf_modify VARCHAR(200),
        @_delta_price_changed_t0 VARCHAR(200),
        @_delta_price_changed_t1 VARCHAR(200),
        @_deal_filters VARCHAR(200),
        @_udf_status VARCHAR(200),
        --@_tmp_price_diff_distinct   VARCHAR(200),
        @_tmp_price_diff_distinct_t0 VARCHAR(200),
        @_tmp_price_diff_distinct_t1 VARCHAR(200),
        @_str_batch_table VARCHAR(MAX),
        @_begin_time DATETIME,
        @_user_login_id VARCHAR(50)


DECLARE @_sp_name VARCHAR(100)
DECLARE @_report_name VARCHAR(100)
DECLARE @_is_batch BIT
DECLARE @_sql_paging VARCHAR(8000)
DECLARE @_tmp_date VARCHAR(10)
DECLARE @_delivered_date DATE,
        @_job_name VARCHAR(500),
        @_spa VARCHAR(MAX)

DECLARE @_added_term VARCHAR(250),
        @_deleted_term VARCHAR(250)

DECLARE @_default_holiday_id     INT,
        @_start_time             DATETIME

SET @_default_holiday_id = 291898

SET @_start_time = GETDATE()

SET @_process_id = ISNULL(@_batch_process_id, REPLACE(NEWID(), ''-'', ''_''))
SET @_user_login_id = dbo.FNADBUser() 
SET @_begin_time = GETDATE()

SELECT @_as_of_date_from = ISNULL(
           @_as_of_date_from,
           dbo.FNAGetBusinessDay(''p'', @_as_of_date_to, @_default_holiday_id)
       )

SET @_as_of_date_to = ISNULL(@_as_of_date_to, GETDATE())

IF @_as_of_date_from > @_as_of_date_to
    SET @_as_of_date_from = @_as_of_date_to
       
SET @_baseload_block_type = ''12000'' -- Internal Static Data
SELECT @_baseload_block_define_id = CAST(value_id AS VARCHAR(10))
FROM   static_data_value
WHERE  [TYPE_ID] = 10018
       AND code LIKE ''Base Load'' -- External Static Data

IF @_baseload_block_define_id IS NULL
    SET @_baseload_block_define_id = ''NULL''

DECLARE @_process_id_reforecast VARCHAR(150)
SET @_process_id_reforecast = @_process_id + ''_1''

IF OBJECT_ID(''tempdb..#source_deal_header'') IS NOT NULL
    DROP TABLE #source_deal_header

IF OBJECT_ID(''tempdb..#source_deal_header_ids'') IS NOT NULL
    DROP TABLE #source_deal_header_ids

IF OBJECT_ID(''tempdb..#source_deal_detail'') IS NOT NULL
    DROP TABLE #source_deal_detail

IF OBJECT_ID(''tempdb..#temp_explain_mtm'') IS NOT NULL
    DROP TABLE #temp_explain_mtm

IF OBJECT_ID(''tempdb..#book'') IS NOT NULL
    DROP TABLE #book



SET @_added_term = dbo.FNAProcessTableName(''added_term'', @_user_login_id, @_process_id)
SET @_deleted_term = dbo.FNAProcessTableName(''deleted_term'', @_user_login_id, @_process_id)


--BEGIN TRY

---START Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------
SET @_str_batch_table = ''''
SET @_is_batch = CASE 
                      WHEN @_batch_process_id IS NOT NULL AND @_batch_report_param 
                           IS NOT NULL THEN 1
                      ELSE 0
                 END           

IF @_is_batch = 1
    SET @_str_batch_table = '' INTO '' + dbo.FNAProcessTableName(''batch_report'', @_user_login_id, @_batch_process_id)

IF @_batch_process_id IS NULL
    SET @_batch_process_id = dbo.FNAGetNewID()       
       
IF @_enable_paging = 1 --paging processing
BEGIN
    SET @_str_batch_table = dbo.FNAPagingProcess(''p'', @_batch_process_id, @_page_size, @_page_no)
    
    --retrieve data from paging table instead of main table
    IF @_page_no IS NOT NULL
    BEGIN
        SET @_sql_paging = dbo.FNAPagingProcess(''s'', @_batch_process_id, @_page_size, @_page_no)    
        EXEC (@_sql_paging) 
        RETURN
    END
END
---END Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------

SET @_st_criteria = CASE 
                         WHEN @_index IS NULL THEN ''''
                         ELSE '' AND delta.curve_id IN ('' + @_index + '')''
                    END
                     
                           
SET @_st_term = CASE 
                     WHEN @_term_start IS NULL THEN ''''
                     ELSE '' AND delta.term_start >= '''''' + CONVERT(VARCHAR(10), @_term_start, 120) 
                          + ''''''''
                END
    + CASE 
           WHEN @_term_end IS NULL THEN ''''
           ELSE '' AND delta.term_start <= '''''' + CONVERT(VARCHAR(10), @_term_end, 120) 
                + ''''''''
      END

--SET @_st_hr = CASE WHEN @_hr_from IS NULL THEN '''' ELSE '' AND delta.hr>='' +CAST(@_hr_from  AS VARCHAR) END
--                   + CASE WHEN @_hr_to IS NULL THEN '''' ELSE '' AND delta.hr<='' +CAST(@_hr_to  AS VARCHAR) END
       
----collect books for filtering          
CREATE TABLE #book
(
	book_deal_type_map_id      INT,
	source_system_book_id1     INT,
	source_system_book_id2     INT,
	source_system_book_id3     INT,
	source_system_book_id4     INT
)           
       
SET @_st1 = 
    ''INSERT INTO #book (
                           book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
                     )             
                     SELECT book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
                     FROM source_system_book_map sbm            
                           INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
                           INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
                           INNER JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
                     WHERE 1=1  ''
    + CASE 
           WHEN @_sub IS NULL THEN ''''
           ELSE '' and sb.entity_id in ('' + @_sub + '')''
      END
    + CASE 
           WHEN @_str IS NULL THEN ''''
           ELSE '' and stra.entity_id in ('' + @_str + '')''
      END
    + CASE 
           WHEN @_book IS NULL THEN ''''
           ELSE '' and book.entity_id in ('' + @_book + '')''
      END
   
PRINT(@_st1)   
EXEC (@_st1)

CREATE TABLE #source_deal_header_ids
(
	source_deal_header_id INT
)
IF @_source_deal_header_ids IS NULL
    INSERT INTO #source_deal_header_ids
      (
        source_deal_header_id
      )
    SELECT source_deal_header_id
    FROM   source_deal_header sdh
           INNER JOIN #book sbm
                ON  sdh.source_system_book_id1 = sbm.source_system_book_id1
                AND sdh.source_system_book_id2 = sbm.source_system_book_id2
                AND sdh.source_system_book_id3 = sbm.source_system_book_id3
                AND sdh.source_system_book_id4 = sbm.source_system_book_id4
ELSE
    INSERT INTO #source_deal_header_ids
      (
        source_deal_header_id
      )
    SELECT a.item
    FROM   dbo.SplitCommaSeperatedValues(@_source_deal_header_ids) a
   

----collect deals for filtering          
              

SELECT --top(10) 
       dsdh.source_deal_header_id,
       dsdh.source_system_id,
       dsdh.deal_id,
       dsdh.deal_date,
       dsdh.ext_deal_id,
       dsdh.physical_financial_flag,
       dsdh.structured_deal_id,
       dsdh.counterparty_id,
       dsdh.entire_term_start,
       dsdh.entire_term_end,
       dsdh.source_deal_type_id     deal_type_id,
       dsdh.deal_sub_type_type_id,
       dsdh.option_flag,
       dsdh.option_type,
       dsdh.option_excercise_type,
       dsdh.source_system_book_id1,
       dsdh.source_system_book_id2,
       dsdh.source_system_book_id3,
       dsdh.source_system_book_id4,
       dsdh.description1,
       dsdh.description2,
       dsdh.description3,
       dsdh.deal_category_value_id,
       dsdh.trader_id,
       dsdh.internal_deal_type_value_id,
       dsdh.internal_deal_subtype_value_id,
       dsdh.template_id,
       dsdh.header_buy_sell_flag,
       dsdh.broker_id,
       dsdh.generator_id,
       dsdh.status_value_id,
       dsdh.status_date,
       dsdh.assignment_type_value_id,
       dsdh.compliance_year,
       dsdh.state_value_id,
       dsdh.assigned_date,
       dsdh.assigned_by,
       dsdh.generation_source,
       dsdh.aggregate_environment,
       dsdh.aggregate_envrionment_comment,
       dsdh.rec_price,
       dsdh.rec_formula_id,
       dsdh.rolling_avg,
       dsdh.contract_id,
       dsdh.create_user,
       CONVERT(VARCHAR(10), dsdh.create_ts, 120) create_ts,
       dsdh.update_user,
       dsdh.update_ts,
       dsdh.legal_entity,
       dsdh.internal_desk_id        profile_id,
       dsdh.product_id              product_id,
       dsdh.commodity_id,
       dsdh.reference,
       dsdh.deal_locked,
       dsdh.close_reference_id,
       dsdh.block_type,
       dsdh.block_define_id,
       dsdh.granularity_id,
       dsdh.Pricing,
       dsdh.deal_reference_type_id,
       dsdh.unit_fixed_flag,
       dsdh.broker_unit_fees,
       dsdh.broker_fixed_cost,
       dsdh.broker_currency_id,
       -5607                        deal_status_id,
       dsdh.term_frequency,
       dsdh.option_settlement_date,
       dsdh.verified_by,
       dsdh.verified_date,
       dsdh.risk_sign_off_by,
       dsdh.risk_sign_off_date,
       dsdh.back_office_sign_off_by,
       dsdh.back_office_sign_off_date,
       dsdh.book_transfer_id,
       dsdh.confirm_status_type,
       dsdh.product_id              fixation,
       CASE 
            WHEN dsdh.deal_status = 5607 THEN CASE 
                                                   WHEN CONVERT(VARCHAR(10), dsdh.update_ts, 120)
                                                        = CONVERT(VARCHAR(10), dsdh.delete_ts, 120) THEN 
                                                        0
                                                   ELSE 1
                                              END
            ELSE 0
       END cancel_delete
INTO                                #source_deal_header
FROM   delete_source_deal_header dsdh
       INNER JOIN #source_deal_header_ids d
            ON  dsdh.source_deal_header_id = d.source_deal_header_id
WHERE  dsdh.deal_date <= @_as_of_date_to
       AND CASE 
                WHEN dsdh.deal_status = 5607 THEN CASE 
                                                       WHEN CONVERT(VARCHAR(10), dsdh.update_ts, 120)
                                                            = CONVERT(VARCHAR(10), dsdh.delete_ts, 120) THEN 
                                                            0
                                                       ELSE 1
                                                  END
                ELSE 0
           END = 0  --exclude deal that cancel first and then next day delete
UNION ALL
SELECT DISTINCT sdh.source_deal_header_id,
       sdh.source_system_id,
       sdh.deal_id,
       sdh.deal_date,
       sdh.ext_deal_id,
       sdh.physical_financial_flag,
       sdh.structured_deal_id,
       sdh.counterparty_id,
       sdh.entire_term_start,
       sdh.entire_term_end,
       sdh.source_deal_type_id,
       sdh.deal_sub_type_type_id     deal_type_id,
       sdh.option_flag,
       sdh.option_type,
       sdh.option_excercise_type,
       sdh.source_system_book_id1,
       sdh.source_system_book_id2,
       sdh.source_system_book_id3,
       sdh.source_system_book_id4,
       sdh.description1,
       sdh.description2,
       sdh.description3,
       sdh.deal_category_value_id,
       sdh.trader_id,
       sdh.internal_deal_type_value_id,
       sdh.internal_deal_subtype_value_id,
       sdh.template_id,
       sdh.header_buy_sell_flag,
       sdh.broker_id,
       sdh.generator_id,
       sdh.status_value_id,
       sdh.status_date,
       sdh.assignment_type_value_id,
       sdh.compliance_year,
       sdh.state_value_id,
       sdh.assigned_date,
       sdh.assigned_by,
       sdh.generation_source,
       sdh.aggregate_environment,
       sdh.aggregate_envrionment_comment,
       sdh.rec_price,
       sdh.rec_formula_id,
       sdh.rolling_avg,
       sdh.contract_id,
       sdh.create_user,
       CONVERT(VARCHAR(10), sdh.create_ts, 120) create_ts,
       sdh.update_user,
       sdh.update_ts,
       sdh.legal_entity,
       sdh.internal_desk_id          profile_id,
       sdh.product_id                product_id,
       sdh.commodity_id,
       sdh.reference,
       sdh.deal_locked,
       sdh.close_reference_id,
       sdh.block_type,
       sdh.block_define_id,
       sdh.granularity_id,
       sdh.Pricing,
       sdh.deal_reference_type_id,
       sdh.unit_fixed_flag,
       sdh.broker_unit_fees,
       sdh.broker_fixed_cost,
       sdh.broker_currency_id,
       sdh.deal_status               deal_status_id,
       sdh.term_frequency,
       sdh.option_settlement_date,
       sdh.verified_by,
       sdh.verified_date,
       sdh.risk_sign_off_by,
       sdh.risk_sign_off_date,
       sdh.back_office_sign_off_by,
       sdh.back_office_sign_off_date,
       sdh.book_transfer_id,
       sdh.confirm_status_type,
       sdh.product_id                fixation,
       0                             cancel_delete
FROM   source_deal_header sdh
       INNER JOIN [deal_status_group] dsg
            ON  (
                    dsg.status_value_id = sdh.deal_status
                    OR (
                           sdh.deal_status = 5607
                           AND CONVERT(VARCHAR(10), sdh.update_ts, 120) > @_as_of_date_from
                           AND CONVERT(VARCHAR(10), sdh.update_ts, 120) <= @_as_of_date_to
                       )
                )
            AND sdh.deal_date <= @_as_of_date_to
       INNER JOIN #source_deal_header_ids d
            ON  sdh.source_deal_header_id = d.source_deal_header_id

       
PRINT(@_st1)
EXEC (@_st1)

CREATE INDEX indx_header_id_aaaa ON  #source_deal_header(source_deal_header_id)
       

SELECT dsdd.source_deal_detail_id,
       dsdd.source_deal_header_id,
       dsdd.term_start,
       dsdd.term_end,
       dsdd.Leg,
       dsdd.contract_expiration_date,
       dsdd.fixed_float_leg,
       dsdd.buy_sell_flag,
       dsdd.curve_id,
       dsdd.fixed_price,
       dsdd.fixed_price_currency_id,
       dsdd.option_strike_price,
       dsdd.deal_volume,
       dsdd.deal_volume_frequency,
       dsdd.deal_volume_uom_id,
       dsdd.block_description,
       dsdd.deal_detail_description,
       dsdd.formula_id,
       dsdd.volume_left,
       dsdd.settlement_volume,
       dsdd.settlement_uom,
       dsdd.create_user,
       dsdd.create_ts,
       dsdd.update_user,
       dsdd.update_ts,
       dsdd.price_adder,
       dsdd.price_multiplier,
       dsdd.settlement_date,
       dsdd.day_count_id,
       ISNULL(dsdd.location_id, -1)     location_id,
       dsdd.meter_id,
       dsdd.physical_financial_flag,
       dsdd.Booked,
       dsdd.process_deal_status,
       dsdd.fixed_cost,
       dsdd.multiplier,
       dsdd.adder_currency_id,
       dsdd.fixed_cost_currency_id,
       dsdd.formula_currency_id,
       dsdd.price_adder2,
       dsdd.price_adder_currency2,
       dsdd.volume_multiplier2,
       dsdd.total_volume,
       dsdd.pay_opposite,
       dsdd.capacity,
       dsdd.settlement_currency,
       dsdd.standard_yearly_volume,
       dsdd.formula_curve_id,
       dsdd.price_uom_id,
       dsdd.category                    Category_id,
       dsdd.profile_code,
       dsdd.pv_party                    pvparty_id,
       ISNULL(spcd1.source_curve_def_id, spcd.source_curve_def_id) index_id,
       ISNULL(spcd.display_uom_id, spcd.uom_id) uom_id,
       COALESCE(spcd1.block_define_id, spcd.block_define_id) user_toublock_id,
       COALESCE(
           spcd1.udf_block_group_id,
           spcd.udf_block_group_id,
           grp.block_type_group_id
       ) toublock_id
INTO                                    #source_deal_detail
FROM   dbo.delete_source_deal_detail dsdd
       INNER JOIN #source_deal_header sdh
            ON  dsdd.source_deal_header_id = sdh.source_deal_header_id
       INNER JOIN source_price_curve_def spcd
            ON  spcd.source_curve_def_id = dsdd.curve_id
       LEFT JOIN source_price_curve_def spcd1
            ON  spcd1.source_curve_def_id = spcd.proxy_curve_id
       LEFT JOIN block_type_group grp
            ON  ISNULL(spcd1.block_define_id, spcd.block_define_id) = grp.hourly_block_id
            AND ISNULL(spcd.block_type, spcd.block_type) = grp.block_type_id  
UNION ALL
SELECT sdd.source_deal_detail_id,
       sdd.source_deal_header_id,
       sdd.term_start,
       sdd.term_end,
       sdd.Leg,
       sdd.contract_expiration_date,
       sdd.fixed_float_leg,
       sdd.buy_sell_flag,
       sdd.curve_id,
       sdd.fixed_price,
       sdd.fixed_price_currency_id,
       sdd.option_strike_price,
       sdd.deal_volume,
       sdd.deal_volume_frequency,
       sdd.deal_volume_uom_id,
       sdd.block_description,
       sdd.deal_detail_description,
       sdd.formula_id,
       sdd.volume_left,
       sdd.settlement_volume,
       sdd.settlement_uom,
       sdd.create_user,
       sdd.create_ts,
       sdd.update_user,
       sdd.update_ts,
       sdd.price_adder,
       sdd.price_multiplier,
       sdd.settlement_date,
       sdd.day_count_id,
       ISNULL(sdd.location_id, -1)     location_id,
       sdd.meter_id,
       sdd.physical_financial_flag,
       sdd.Booked,
       sdd.process_deal_status,
       sdd.fixed_cost,
       sdd.multiplier,
       sdd.adder_currency_id,
       sdd.fixed_cost_currency_id,
       sdd.formula_currency_id,
       sdd.price_adder2,
       sdd.price_adder_currency2,
       sdd.volume_multiplier2,
       sdd.total_volume,
       sdd.pay_opposite,
       sdd.capacity,
       sdd.settlement_currency,
       sdd.standard_yearly_volume,
       sdd.formula_curve_id,
       sdd.price_uom_id,
       sdd.category                    Category_id,
       sdd.profile_code,
       sdd.pv_party                    pvparty_id,
       ISNULL(spcd1.source_curve_def_id, spcd.source_curve_def_id) index_id,
       ISNULL(spcd.display_uom_id, spcd.uom_id) uom_id,
       COALESCE(spcd1.block_define_id, spcd.block_define_id) user_toublock_id,
       COALESCE(
           spcd1.udf_block_group_id,
           spcd.udf_block_group_id,
           grp.block_type_group_id
       )                               toublock_id
FROM   dbo.source_deal_detail sdd
       INNER JOIN #source_deal_header sdh
            ON  sdd.source_deal_header_id = sdh.source_deal_header_id
       INNER JOIN source_price_curve_def spcd
            ON  spcd.source_curve_def_id = sdd.curve_id
       LEFT JOIN source_price_curve_def spcd1
            ON  spcd1.source_curve_def_id = spcd.proxy_curve_id
       LEFT JOIN block_type_group grp
            ON  ISNULL(spcd1.block_define_id, spcd.block_define_id) = grp.hourly_block_id
            AND ISNULL(spcd.block_type, spcd.block_type) = grp.block_type_id  

CREATE INDEX indx_detail_id_qqq ON #source_deal_detail(source_deal_header_id, curve_id, term_start)


--=============================================================================================================================
       PRINT ''*************************Explain mtm (new/delete/end/begin/delivered delta mtm).********************************''
--==============================================================================================================================

       
SELECT sdp.source_deal_header_id,
       sdp.term_start,
       sdp.term_end,
       sdp.curve_id,
       sdp.leg,
       ABS(MAX(sdh.deal_status_id))     deal_status_id,
       SUM(
           CASE 
                WHEN sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.und_pnl
                ELSE 0
           END
       )                                begin_mtm,
       SUM(
           CASE 
                WHEN CONVERT(VARCHAR(10), sdh.create_ts, 120) = @_as_of_date_to
           AND sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.und_pnl ELSE 0 END
       )                                new_mtm,
       CAST(0.00 AS NUMERIC(28, 8))     modify_MTM,
       SUM(
           -1 * CASE 
                     WHEN ABS(sdh.deal_status_id) = 5607
           AND sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.und_pnl ELSE 0 
               END
       )                                deleted_mtm,
       CAST(0.00 AS NUMERIC(28, 8))     delivered_mtm,
       CAST(0.00 AS NUMERIC(28, 8))     price_changed_mtm,
       SUM(
           CASE 
                WHEN ABS(sdh.deal_status_id) <> 5607
           AND sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.und_pnl ELSE 0 END
       )                                end_mtm,
       SUM(
           CASE 
                WHEN sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.deal_volume
                ELSE 0
           END
       )                                begin_vol,
       SUM(
           CASE 
                WHEN CONVERT(VARCHAR(10), sdh.create_ts, 120) = @_as_of_date_to
           AND sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.deal_volume ELSE 0 
               END
       )                                new_vol,
       CAST(0.00 AS NUMERIC(28, 8))     modify_vol,
       SUM(
           -1 * CASE 
                     WHEN ABS(sdh.deal_status_id) = 5607
           AND sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.deal_volume ELSE 
               0 END
       )                                deleted_vol,
       SUM(
           CASE 
                WHEN ABS(sdh.deal_status_id) <> 5607
           AND sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.deal_volume ELSE 0 
               END
       )                                end_vol,
       SUM(
           CASE 
                WHEN sdp.deal_volume <> 0 THEN sdp.und_pnl / sdp.deal_volume * CASE 
                                                                                    WHEN 
                                                                                         sdp.pnl_as_of_date
                                                                                         = 
                                                                                         @_as_of_date_from THEN 
                                                                                         -
                                                                                         1
                                                                                    ELSE 
                                                                                         1
                                                                               END
                ELSE 0
           END
       )                                delta_price,
       CAST(0.00 AS NUMERIC(28, 8))     delivered_vol,
       MAX(
           CASE 
                WHEN sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.price
                ELSE 0
           END
       )                                price_to,
       MAX(
           CASE 
                WHEN sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.price
                ELSE 0
           END
       )                                price_from,
       MAX(sdp.pnl_currency_id)         pnl_currency_id,
       291905                           charge_type,
       MAX(CONVERT(VARCHAR(10), sdh.create_ts, 120)) create_ts,
       CAST(0.00 AS NUMERIC(28, 8))     unexplained_vol,
       CAST(0.00 AS NUMERIC(28, 8)) unexplained_mtm
INTO                                    #temp_explain_mtm
FROM   source_deal_pnl_detail sdp
       INNER JOIN #source_deal_header sdh
            ON  sdp.source_deal_header_id = sdh.source_deal_header_id
            AND (
                    sdp.pnl_as_of_date = @_as_of_date_from
                    OR sdp.pnl_as_of_date = @_as_of_date_to
                )
GROUP BY
       sdp.source_deal_header_id,
       sdp.term_start,
       sdp.term_end,
       sdp.curve_id,
       sdp.leg
HAVING SUM(
           CASE 
                WHEN sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.und_pnl
                ELSE 0
           END
       ) <> 0
       OR SUM(
           CASE 
                WHEN ABS(sdh.deal_status_id) <> 5607
           AND sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.und_pnl ELSE 0 END
       ) <> 0
            
                     

CREATE INDEX indx_ccc__123 ON #temp_explain_mtm(source_deal_header_id, term_start, term_end, curve_id) 
INCLUDE(new_mtm, deleted_mtm)

       -- ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Delta Collecting^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^''
       --print ''Time taken(second):'' +cast(datediff(ss,@_start_time, GETDATE()) as varchar)
SET @_start_time = GETDATE()  
       PRINT ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^''


-- Delivered Volume=Volume difference between as of date to and as of date from for not new and not deleted deals
--, if as of date to  is in between deal term start and deal term end.
--Delivered MTM: Delivered Volume* As of date from Net Price from source deal PNL detail.

UPDATE #temp_explain_mtm
SET    delivered_vol = end_vol -begin_vol,
       delivered_mtm = -1 * (end_vol -begin_vol) * price_from
WHERE  (ISNULL(deleted_vol, 0) = 0 OR ISNULL(new_vol, 0) = 0)
       AND @_as_of_date_to BETWEEN term_start AND term_end
       AND ISNULL(deleted_mtm, 0) = 0
       AND ISNULL(new_mtm, 0) = 0
  -- Price Change MTM=  Net Price difference between to as of date in source deal PNL detail* Volume of as of date from.(source deal pnl detail)

UPDATE #temp_explain_mtm
SET    price_changed_mtm = delta_price * begin_vol -delivered_mtm
WHERE  ISNULL(deleted_mtm, 0) = 0
       AND ISNULL(new_mtm, 0) = 0

       --     Modified Volume= Ending Volume-Beginning Volume-New Deals-Delivered-Deleted
       --Modified MTM=Modified Volume*(P1-P0)
              
UPDATE #temp_explain_mtm
SET    modify_vol = end_vol -(begin_vol + new_vol + deleted_vol + delivered_vol),
       modify_mtm = (
           end_mtm -(
               begin_mtm + new_mtm + deleted_mtm + delivered_mtm + 
               price_changed_mtm
           )
       )
WHERE  ISNULL(deleted_mtm, 0) = 0
       AND ISNULL(new_mtm, 0) = 0

--Unexplained Volume=If there is any volume difference.
--Unexplained MTM= If still there is any MTM difference

UPDATE #temp_explain_mtm
SET    unexplained_vol = end_vol -(
           begin_vol + new_vol + deleted_vol + delivered_vol + modify_vol
       ),
       unexplained_mtm = end_mtm -(
           begin_mtm + new_mtm + deleted_mtm + delivered_mtm + modify_mtm + 
           price_changed_mtm
       )
WHERE  end_vol -(
           begin_vol + new_vol + deleted_vol + delivered_vol + modify_vol
       ) <> 0
       OR  (
               end_mtm -(
                   begin_mtm + new_mtm + deleted_mtm + delivered_mtm + 
                   modify_mtm
               )
           ) <> 0
       AND ISNULL(deleted_mtm, 0) = 0
       AND ISNULL(new_mtm, 0) = 0

SELECT a.*,b.curve_name [curve_name],b.uom_id,su.uom_name, sc.currency_name,
       ''@as_of_date_from'' as_of_date_from,
       ''@as_of_date_to'' as_of_date_to,
       ''@sub_id'' sub_id,
       ''@stra_id'' stra_id,
       ''@book_id'' book_id,
       c1.entity_name [book],
       c2.entity_name [Strategy],
       c3.entity_name [Sub],
	   scpty.source_counterparty_id,
	   scpty.counterparty_name,
	   sdh.deal_id [reference_id],
	   ssbm.fas_deal_type_value_id [transaction_type],
	   sdv.code [transaction_type_name]
       --[__batch_report__]
FROM   #temp_explain_mtm a
       INNER JOIN source_deal_header sdh
            ON  sdh.source_deal_header_id = a.source_deal_header_id
       INNER JOIN source_system_book_map ssbm
            ON  ssbm.source_system_book_id1 = sdh.source_system_book_id1
            AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
            AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
            AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
       INNER JOIN source_price_curve_def b
            ON  a.curve_id = b.source_curve_def_id
       INNER JOIN portfolio_hierarchy c1
            ON  c1.entity_id = ssbm.fas_book_id
       INNER JOIN portfolio_hierarchy c2
            ON  c2.entity_id = c1.parent_entity_id
       INNER JOIN portfolio_hierarchy c3
            ON  c3.entity_id = c2.parent_entity_id
        LEFT JOIN source_uom AS su ON b.uom_id = su.source_uom_id
        LEFT JOIN source_currency AS sc ON a.pnl_currency_id = sc.source_currency_id
		LEFT JOIN source_counterparty scpty ON scpty.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN static_data_value sdv ON sdv.[type_id] = 400 AND ssbm.fas_deal_type_value_id = sdv.value_id', report_id = @report_id_data_source_dest 
		WHERE [name] = 'PNL_Explain_View'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'PNL_Explain_View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 1 AS [type_id], 'PNL_Explain_View' AS [name], 'PNL_Explain_View' AS ALIAS, '' AS [description],'DECLARE @_as_of_date_from         DATETIME = ''@as_of_date_from'',--''2015-03-16'',     -- ''2012-01-16'', --''2012-01-16''
        @_as_of_date_to           DATETIME = ''@as_of_date_to'',--''2015-03-17'',     --''2012-01-17'',
        @_sub                     VARCHAR(200) = NULL,  --''148'',
        @_str                     VARCHAR(200) = NULL,  --''150'',
        @_term_start              DATETIME = NULL,
        @_term_end                DATETIME = NULL,
        @_book                    VARCHAR(200) = null,  --''158'' ,--''206'',
        @_source_deal_header_ids  VARCHAR(500) =null,
        @_index                   VARCHAR(200) = null,
        @_round                   VARCHAR(1) = ''8'',

        @_batch_process_id        VARCHAR(50) = NULL,
        @_batch_report_param      VARCHAR(1000) = NULL,
        @_enable_paging           INT = 0,       --''1'' = enable, ''0'' = disable
        @_page_size               INT = NULL,
        @_page_no                 INT = NULL

IF ''@sub_id'' <> ''NULL''
                SET @_sub = ''@sub_id''
IF ''@stra_id'' <> ''NULL''
                SET @_str = ''@stra_id''
IF ''@book_id'' <> ''NULL''
                SET @_book = ''@book_id''


     
DECLARE @_status_type VARCHAR(1)
DECLARE @_desc VARCHAR(5000)
DECLARE @_error_count INT 
DECLARE @_saved_records INT
DECLARE @_stmt VARCHAR(8000)
-----------------------------------------


DECLARE @_baseload_block_type VARCHAR(10)
DECLARE @_baseload_block_define_id VARCHAR(10)--,@_orginal_summary_option CHAR(1)
DECLARE @_st1 VARCHAR(MAX),
        @_st2 VARCHAR(MAX),
        @_st2_0 VARCHAR(MAX),
        @_st2a VARCHAR(MAX),
        @_st2b VARCHAR(MAX),
        @_st3 VARCHAR(MAX),
        @_st4 VARCHAR(MAX),
        @_st5 VARCHAR(MAX),
        @_st_fields VARCHAR(MAX),
        @_st_group_by VARCHAR(MAX),
        @_st_from VARCHAR(MAX),
        @_st_term VARCHAR(1000),
        @_st_criteria VARCHAR(MAX),
        @_source_deal_header VARCHAR(200),
        @_source_deal_detail VARCHAR(200),
        @_report_hourly_position_breakdown VARCHAR(200),
        @_delta_report_hourly_position_breakdown VARCHAR(200),
        @_report_hourly_position_breakdown_detail VARCHAR(200),
        @_delta_report_hourly_position_breakdown_detail VARCHAR(200),
        @_report_hourly_position_breakdown_detail_delivered VARCHAR(300),
        @_report_hourly_position_breakdown_detail_ending VARCHAR(300),
        @_modify_status VARCHAR(300),
        @_price_change_value VARCHAR(300),
        @_index_fee_breakdown_reforecast VARCHAR(300),
        @_temp_discounted_mtm_factor VARCHAR(200),
        @_delivered_position VARCHAR(200),
        @_deferral_temp_explain_mtm VARCHAR(200),
        @_tmp_price_changed_phy VARCHAR(200),
        @_tmp_price_changed_formula VARCHAR(200),
        @_fin_term_ratio VARCHAR(200),
        @_temp_explain_mtm_formula VARCHAR(200),
        @_temp_explain_mtm VARCHAR(200),
        @_final_explain_mtm VARCHAR(200),
        @_forecast_position VARCHAR(200),
        @_explain_reforecast_deals VARCHAR(300),
        @_explain_delivered_mtm VARCHAR(200),
        @_explain_modified_mtm VARCHAR(200),
        @_sum_left_side_term VARCHAR(200),
        @_left_side_term VARCHAR(200),
        @_process_id VARCHAR(150),
        @_tmp_price_diff VARCHAR(200),
        @_udf_modify VARCHAR(200),
        @_delta_price_changed_t0 VARCHAR(200),
        @_delta_price_changed_t1 VARCHAR(200),
        @_deal_filters VARCHAR(200),
        @_udf_status VARCHAR(200),
        --@_tmp_price_diff_distinct   VARCHAR(200),
        @_tmp_price_diff_distinct_t0 VARCHAR(200),
        @_tmp_price_diff_distinct_t1 VARCHAR(200),
        @_str_batch_table VARCHAR(MAX),
        @_begin_time DATETIME,
        @_user_login_id VARCHAR(50)


DECLARE @_sp_name VARCHAR(100)
DECLARE @_report_name VARCHAR(100)
DECLARE @_is_batch BIT
DECLARE @_sql_paging VARCHAR(8000)
DECLARE @_tmp_date VARCHAR(10)
DECLARE @_delivered_date DATE,
        @_job_name VARCHAR(500),
        @_spa VARCHAR(MAX)

DECLARE @_added_term VARCHAR(250),
        @_deleted_term VARCHAR(250)

DECLARE @_default_holiday_id     INT,
        @_start_time             DATETIME

SET @_default_holiday_id = 291898

SET @_start_time = GETDATE()

SET @_process_id = ISNULL(@_batch_process_id, REPLACE(NEWID(), ''-'', ''_''))
SET @_user_login_id = dbo.FNADBUser() 
SET @_begin_time = GETDATE()

SELECT @_as_of_date_from = ISNULL(
           @_as_of_date_from,
           dbo.FNAGetBusinessDay(''p'', @_as_of_date_to, @_default_holiday_id)
       )

SET @_as_of_date_to = ISNULL(@_as_of_date_to, GETDATE())

IF @_as_of_date_from > @_as_of_date_to
    SET @_as_of_date_from = @_as_of_date_to
       
SET @_baseload_block_type = ''12000'' -- Internal Static Data
SELECT @_baseload_block_define_id = CAST(value_id AS VARCHAR(10))
FROM   static_data_value
WHERE  [TYPE_ID] = 10018
       AND code LIKE ''Base Load'' -- External Static Data

IF @_baseload_block_define_id IS NULL
    SET @_baseload_block_define_id = ''NULL''

DECLARE @_process_id_reforecast VARCHAR(150)
SET @_process_id_reforecast = @_process_id + ''_1''

IF OBJECT_ID(''tempdb..#source_deal_header'') IS NOT NULL
    DROP TABLE #source_deal_header

IF OBJECT_ID(''tempdb..#source_deal_header_ids'') IS NOT NULL
    DROP TABLE #source_deal_header_ids

IF OBJECT_ID(''tempdb..#source_deal_detail'') IS NOT NULL
    DROP TABLE #source_deal_detail

IF OBJECT_ID(''tempdb..#temp_explain_mtm'') IS NOT NULL
    DROP TABLE #temp_explain_mtm

IF OBJECT_ID(''tempdb..#book'') IS NOT NULL
    DROP TABLE #book



SET @_added_term = dbo.FNAProcessTableName(''added_term'', @_user_login_id, @_process_id)
SET @_deleted_term = dbo.FNAProcessTableName(''deleted_term'', @_user_login_id, @_process_id)


--BEGIN TRY

---START Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------
SET @_str_batch_table = ''''
SET @_is_batch = CASE 
                      WHEN @_batch_process_id IS NOT NULL AND @_batch_report_param 
                           IS NOT NULL THEN 1
                      ELSE 0
                 END           

IF @_is_batch = 1
    SET @_str_batch_table = '' INTO '' + dbo.FNAProcessTableName(''batch_report'', @_user_login_id, @_batch_process_id)

IF @_batch_process_id IS NULL
    SET @_batch_process_id = dbo.FNAGetNewID()       
       
IF @_enable_paging = 1 --paging processing
BEGIN
    SET @_str_batch_table = dbo.FNAPagingProcess(''p'', @_batch_process_id, @_page_size, @_page_no)
    
    --retrieve data from paging table instead of main table
    IF @_page_no IS NOT NULL
    BEGIN
        SET @_sql_paging = dbo.FNAPagingProcess(''s'', @_batch_process_id, @_page_size, @_page_no)    
        EXEC (@_sql_paging) 
        RETURN
    END
END
---END Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------

SET @_st_criteria = CASE 
                         WHEN @_index IS NULL THEN ''''
                         ELSE '' AND delta.curve_id IN ('' + @_index + '')''
                    END
                     
                           
SET @_st_term = CASE 
                     WHEN @_term_start IS NULL THEN ''''
                     ELSE '' AND delta.term_start >= '''''' + CONVERT(VARCHAR(10), @_term_start, 120) 
                          + ''''''''
                END
    + CASE 
           WHEN @_term_end IS NULL THEN ''''
           ELSE '' AND delta.term_start <= '''''' + CONVERT(VARCHAR(10), @_term_end, 120) 
                + ''''''''
      END

--SET @_st_hr = CASE WHEN @_hr_from IS NULL THEN '''' ELSE '' AND delta.hr>='' +CAST(@_hr_from  AS VARCHAR) END
--                   + CASE WHEN @_hr_to IS NULL THEN '''' ELSE '' AND delta.hr<='' +CAST(@_hr_to  AS VARCHAR) END
       
----collect books for filtering          
CREATE TABLE #book
(
	book_deal_type_map_id      INT,
	source_system_book_id1     INT,
	source_system_book_id2     INT,
	source_system_book_id3     INT,
	source_system_book_id4     INT
)           
       
SET @_st1 = 
    ''INSERT INTO #book (
                           book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
                     )             
                     SELECT book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
                     FROM source_system_book_map sbm            
                           INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
                           INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
                           INNER JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
                     WHERE 1=1  ''
    + CASE 
           WHEN @_sub IS NULL THEN ''''
           ELSE '' and sb.entity_id in ('' + @_sub + '')''
      END
    + CASE 
           WHEN @_str IS NULL THEN ''''
           ELSE '' and stra.entity_id in ('' + @_str + '')''
      END
    + CASE 
           WHEN @_book IS NULL THEN ''''
           ELSE '' and book.entity_id in ('' + @_book + '')''
      END
   
PRINT(@_st1)   
EXEC (@_st1)

CREATE TABLE #source_deal_header_ids
(
	source_deal_header_id INT
)
IF @_source_deal_header_ids IS NULL
    INSERT INTO #source_deal_header_ids
      (
        source_deal_header_id
      )
    SELECT source_deal_header_id
    FROM   source_deal_header sdh
           INNER JOIN #book sbm
                ON  sdh.source_system_book_id1 = sbm.source_system_book_id1
                AND sdh.source_system_book_id2 = sbm.source_system_book_id2
                AND sdh.source_system_book_id3 = sbm.source_system_book_id3
                AND sdh.source_system_book_id4 = sbm.source_system_book_id4
ELSE
    INSERT INTO #source_deal_header_ids
      (
        source_deal_header_id
      )
    SELECT a.item
    FROM   dbo.SplitCommaSeperatedValues(@_source_deal_header_ids) a
   

----collect deals for filtering          
              

SELECT --top(10) 
       dsdh.source_deal_header_id,
       dsdh.source_system_id,
       dsdh.deal_id,
       dsdh.deal_date,
       dsdh.ext_deal_id,
       dsdh.physical_financial_flag,
       dsdh.structured_deal_id,
       dsdh.counterparty_id,
       dsdh.entire_term_start,
       dsdh.entire_term_end,
       dsdh.source_deal_type_id     deal_type_id,
       dsdh.deal_sub_type_type_id,
       dsdh.option_flag,
       dsdh.option_type,
       dsdh.option_excercise_type,
       dsdh.source_system_book_id1,
       dsdh.source_system_book_id2,
       dsdh.source_system_book_id3,
       dsdh.source_system_book_id4,
       dsdh.description1,
       dsdh.description2,
       dsdh.description3,
       dsdh.deal_category_value_id,
       dsdh.trader_id,
       dsdh.internal_deal_type_value_id,
       dsdh.internal_deal_subtype_value_id,
       dsdh.template_id,
       dsdh.header_buy_sell_flag,
       dsdh.broker_id,
       dsdh.generator_id,
       dsdh.status_value_id,
       dsdh.status_date,
       dsdh.assignment_type_value_id,
       dsdh.compliance_year,
       dsdh.state_value_id,
       dsdh.assigned_date,
       dsdh.assigned_by,
       dsdh.generation_source,
       dsdh.aggregate_environment,
       dsdh.aggregate_envrionment_comment,
       dsdh.rec_price,
       dsdh.rec_formula_id,
       dsdh.rolling_avg,
       dsdh.contract_id,
       dsdh.create_user,
       CONVERT(VARCHAR(10), dsdh.create_ts, 120) create_ts,
       dsdh.update_user,
       dsdh.update_ts,
       dsdh.legal_entity,
       dsdh.internal_desk_id        profile_id,
       dsdh.product_id              product_id,
       dsdh.commodity_id,
       dsdh.reference,
       dsdh.deal_locked,
       dsdh.close_reference_id,
       dsdh.block_type,
       dsdh.block_define_id,
       dsdh.granularity_id,
       dsdh.Pricing,
       dsdh.deal_reference_type_id,
       dsdh.unit_fixed_flag,
       dsdh.broker_unit_fees,
       dsdh.broker_fixed_cost,
       dsdh.broker_currency_id,
       -5607                        deal_status_id,
       dsdh.term_frequency,
       dsdh.option_settlement_date,
       dsdh.verified_by,
       dsdh.verified_date,
       dsdh.risk_sign_off_by,
       dsdh.risk_sign_off_date,
       dsdh.back_office_sign_off_by,
       dsdh.back_office_sign_off_date,
       dsdh.book_transfer_id,
       dsdh.confirm_status_type,
       dsdh.product_id              fixation,
       CASE 
            WHEN dsdh.deal_status = 5607 THEN CASE 
                                                   WHEN CONVERT(VARCHAR(10), dsdh.update_ts, 120)
                                                        = CONVERT(VARCHAR(10), dsdh.delete_ts, 120) THEN 
                                                        0
                                                   ELSE 1
                                              END
            ELSE 0
       END cancel_delete
INTO                                #source_deal_header
FROM   delete_source_deal_header dsdh
       INNER JOIN #source_deal_header_ids d
            ON  dsdh.source_deal_header_id = d.source_deal_header_id
WHERE  dsdh.deal_date <= @_as_of_date_to
       AND CASE 
                WHEN dsdh.deal_status = 5607 THEN CASE 
                                                       WHEN CONVERT(VARCHAR(10), dsdh.update_ts, 120)
                                                            = CONVERT(VARCHAR(10), dsdh.delete_ts, 120) THEN 
                                                            0
                                                       ELSE 1
                                                  END
                ELSE 0
           END = 0  --exclude deal that cancel first and then next day delete
UNION ALL
SELECT DISTINCT sdh.source_deal_header_id,
       sdh.source_system_id,
       sdh.deal_id,
       sdh.deal_date,
       sdh.ext_deal_id,
       sdh.physical_financial_flag,
       sdh.structured_deal_id,
       sdh.counterparty_id,
       sdh.entire_term_start,
       sdh.entire_term_end,
       sdh.source_deal_type_id,
       sdh.deal_sub_type_type_id     deal_type_id,
       sdh.option_flag,
       sdh.option_type,
       sdh.option_excercise_type,
       sdh.source_system_book_id1,
       sdh.source_system_book_id2,
       sdh.source_system_book_id3,
       sdh.source_system_book_id4,
       sdh.description1,
       sdh.description2,
       sdh.description3,
       sdh.deal_category_value_id,
       sdh.trader_id,
       sdh.internal_deal_type_value_id,
       sdh.internal_deal_subtype_value_id,
       sdh.template_id,
       sdh.header_buy_sell_flag,
       sdh.broker_id,
       sdh.generator_id,
       sdh.status_value_id,
       sdh.status_date,
       sdh.assignment_type_value_id,
       sdh.compliance_year,
       sdh.state_value_id,
       sdh.assigned_date,
       sdh.assigned_by,
       sdh.generation_source,
       sdh.aggregate_environment,
       sdh.aggregate_envrionment_comment,
       sdh.rec_price,
       sdh.rec_formula_id,
       sdh.rolling_avg,
       sdh.contract_id,
       sdh.create_user,
       CONVERT(VARCHAR(10), sdh.create_ts, 120) create_ts,
       sdh.update_user,
       sdh.update_ts,
       sdh.legal_entity,
       sdh.internal_desk_id          profile_id,
       sdh.product_id                product_id,
       sdh.commodity_id,
       sdh.reference,
       sdh.deal_locked,
       sdh.close_reference_id,
       sdh.block_type,
       sdh.block_define_id,
       sdh.granularity_id,
       sdh.Pricing,
       sdh.deal_reference_type_id,
       sdh.unit_fixed_flag,
       sdh.broker_unit_fees,
       sdh.broker_fixed_cost,
       sdh.broker_currency_id,
       sdh.deal_status               deal_status_id,
       sdh.term_frequency,
       sdh.option_settlement_date,
       sdh.verified_by,
       sdh.verified_date,
       sdh.risk_sign_off_by,
       sdh.risk_sign_off_date,
       sdh.back_office_sign_off_by,
       sdh.back_office_sign_off_date,
       sdh.book_transfer_id,
       sdh.confirm_status_type,
       sdh.product_id                fixation,
       0                             cancel_delete
FROM   source_deal_header sdh
       INNER JOIN [deal_status_group] dsg
            ON  (
                    dsg.status_value_id = sdh.deal_status
                    OR (
                           sdh.deal_status = 5607
                           AND CONVERT(VARCHAR(10), sdh.update_ts, 120) > @_as_of_date_from
                           AND CONVERT(VARCHAR(10), sdh.update_ts, 120) <= @_as_of_date_to
                       )
                )
            AND sdh.deal_date <= @_as_of_date_to
       INNER JOIN #source_deal_header_ids d
            ON  sdh.source_deal_header_id = d.source_deal_header_id

       
PRINT(@_st1)
EXEC (@_st1)

CREATE INDEX indx_header_id_aaaa ON  #source_deal_header(source_deal_header_id)
       

SELECT dsdd.source_deal_detail_id,
       dsdd.source_deal_header_id,
       dsdd.term_start,
       dsdd.term_end,
       dsdd.Leg,
       dsdd.contract_expiration_date,
       dsdd.fixed_float_leg,
       dsdd.buy_sell_flag,
       dsdd.curve_id,
       dsdd.fixed_price,
       dsdd.fixed_price_currency_id,
       dsdd.option_strike_price,
       dsdd.deal_volume,
       dsdd.deal_volume_frequency,
       dsdd.deal_volume_uom_id,
       dsdd.block_description,
       dsdd.deal_detail_description,
       dsdd.formula_id,
       dsdd.volume_left,
       dsdd.settlement_volume,
       dsdd.settlement_uom,
       dsdd.create_user,
       dsdd.create_ts,
       dsdd.update_user,
       dsdd.update_ts,
       dsdd.price_adder,
       dsdd.price_multiplier,
       dsdd.settlement_date,
       dsdd.day_count_id,
       ISNULL(dsdd.location_id, -1)     location_id,
       dsdd.meter_id,
       dsdd.physical_financial_flag,
       dsdd.Booked,
       dsdd.process_deal_status,
       dsdd.fixed_cost,
       dsdd.multiplier,
       dsdd.adder_currency_id,
       dsdd.fixed_cost_currency_id,
       dsdd.formula_currency_id,
       dsdd.price_adder2,
       dsdd.price_adder_currency2,
       dsdd.volume_multiplier2,
       dsdd.total_volume,
       dsdd.pay_opposite,
       dsdd.capacity,
       dsdd.settlement_currency,
       dsdd.standard_yearly_volume,
       dsdd.formula_curve_id,
       dsdd.price_uom_id,
       dsdd.category                    Category_id,
       dsdd.profile_code,
       dsdd.pv_party                    pvparty_id,
       ISNULL(spcd1.source_curve_def_id, spcd.source_curve_def_id) index_id,
       ISNULL(spcd.display_uom_id, spcd.uom_id) uom_id,
       COALESCE(spcd1.block_define_id, spcd.block_define_id) user_toublock_id,
       COALESCE(
           spcd1.udf_block_group_id,
           spcd.udf_block_group_id,
           grp.block_type_group_id
       ) toublock_id
INTO                                    #source_deal_detail
FROM   dbo.delete_source_deal_detail dsdd
       INNER JOIN #source_deal_header sdh
            ON  dsdd.source_deal_header_id = sdh.source_deal_header_id
       INNER JOIN source_price_curve_def spcd
            ON  spcd.source_curve_def_id = dsdd.curve_id
       LEFT JOIN source_price_curve_def spcd1
            ON  spcd1.source_curve_def_id = spcd.proxy_curve_id
       LEFT JOIN block_type_group grp
            ON  ISNULL(spcd1.block_define_id, spcd.block_define_id) = grp.hourly_block_id
            AND ISNULL(spcd.block_type, spcd.block_type) = grp.block_type_id  
UNION ALL
SELECT sdd.source_deal_detail_id,
       sdd.source_deal_header_id,
       sdd.term_start,
       sdd.term_end,
       sdd.Leg,
       sdd.contract_expiration_date,
       sdd.fixed_float_leg,
       sdd.buy_sell_flag,
       sdd.curve_id,
       sdd.fixed_price,
       sdd.fixed_price_currency_id,
       sdd.option_strike_price,
       sdd.deal_volume,
       sdd.deal_volume_frequency,
       sdd.deal_volume_uom_id,
       sdd.block_description,
       sdd.deal_detail_description,
       sdd.formula_id,
       sdd.volume_left,
       sdd.settlement_volume,
       sdd.settlement_uom,
       sdd.create_user,
       sdd.create_ts,
       sdd.update_user,
       sdd.update_ts,
       sdd.price_adder,
       sdd.price_multiplier,
       sdd.settlement_date,
       sdd.day_count_id,
       ISNULL(sdd.location_id, -1)     location_id,
       sdd.meter_id,
       sdd.physical_financial_flag,
       sdd.Booked,
       sdd.process_deal_status,
       sdd.fixed_cost,
       sdd.multiplier,
       sdd.adder_currency_id,
       sdd.fixed_cost_currency_id,
       sdd.formula_currency_id,
       sdd.price_adder2,
       sdd.price_adder_currency2,
       sdd.volume_multiplier2,
       sdd.total_volume,
       sdd.pay_opposite,
       sdd.capacity,
       sdd.settlement_currency,
       sdd.standard_yearly_volume,
       sdd.formula_curve_id,
       sdd.price_uom_id,
       sdd.category                    Category_id,
       sdd.profile_code,
       sdd.pv_party                    pvparty_id,
       ISNULL(spcd1.source_curve_def_id, spcd.source_curve_def_id) index_id,
       ISNULL(spcd.display_uom_id, spcd.uom_id) uom_id,
       COALESCE(spcd1.block_define_id, spcd.block_define_id) user_toublock_id,
       COALESCE(
           spcd1.udf_block_group_id,
           spcd.udf_block_group_id,
           grp.block_type_group_id
       )                               toublock_id
FROM   dbo.source_deal_detail sdd
       INNER JOIN #source_deal_header sdh
            ON  sdd.source_deal_header_id = sdh.source_deal_header_id
       INNER JOIN source_price_curve_def spcd
            ON  spcd.source_curve_def_id = sdd.curve_id
       LEFT JOIN source_price_curve_def spcd1
            ON  spcd1.source_curve_def_id = spcd.proxy_curve_id
       LEFT JOIN block_type_group grp
            ON  ISNULL(spcd1.block_define_id, spcd.block_define_id) = grp.hourly_block_id
            AND ISNULL(spcd.block_type, spcd.block_type) = grp.block_type_id  

CREATE INDEX indx_detail_id_qqq ON #source_deal_detail(source_deal_header_id, curve_id, term_start)


--=============================================================================================================================
       PRINT ''*************************Explain mtm (new/delete/end/begin/delivered delta mtm).********************************''
--==============================================================================================================================

       
SELECT sdp.source_deal_header_id,
       sdp.term_start,
       sdp.term_end,
       sdp.curve_id,
       sdp.leg,
       ABS(MAX(sdh.deal_status_id))     deal_status_id,
       SUM(
           CASE 
                WHEN sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.und_pnl
                ELSE 0
           END
       )                                begin_mtm,
       SUM(
           CASE 
                WHEN CONVERT(VARCHAR(10), sdh.create_ts, 120) = @_as_of_date_to
           AND sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.und_pnl ELSE 0 END
       )                                new_mtm,
       CAST(0.00 AS NUMERIC(28, 8))     modify_MTM,
       SUM(
           -1 * CASE 
                     WHEN ABS(sdh.deal_status_id) = 5607
           AND sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.und_pnl ELSE 0 
               END
       )                                deleted_mtm,
       CAST(0.00 AS NUMERIC(28, 8))     delivered_mtm,
       CAST(0.00 AS NUMERIC(28, 8))     price_changed_mtm,
       SUM(
           CASE 
                WHEN ABS(sdh.deal_status_id) <> 5607
           AND sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.und_pnl ELSE 0 END
       )                                end_mtm,
       SUM(
           CASE 
                WHEN sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.deal_volume
                ELSE 0
           END
       )                                begin_vol,
       SUM(
           CASE 
                WHEN CONVERT(VARCHAR(10), sdh.create_ts, 120) = @_as_of_date_to
           AND sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.deal_volume ELSE 0 
               END
       )                                new_vol,
       CAST(0.00 AS NUMERIC(28, 8))     modify_vol,
       SUM(
           -1 * CASE 
                     WHEN ABS(sdh.deal_status_id) = 5607
           AND sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.deal_volume ELSE 
               0 END
       )                                deleted_vol,
       SUM(
           CASE 
                WHEN ABS(sdh.deal_status_id) <> 5607
           AND sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.deal_volume ELSE 0 
               END
       )                                end_vol,
       SUM(
           CASE 
                WHEN sdp.deal_volume <> 0 THEN sdp.und_pnl / sdp.deal_volume * CASE 
                                                                                    WHEN 
                                                                                         sdp.pnl_as_of_date
                                                                                         = 
                                                                                         @_as_of_date_from THEN 
                                                                                         -
                                                                                         1
                                                                                    ELSE 
                                                                                         1
                                                                               END
                ELSE 0
           END
       )                                delta_price,
       CAST(0.00 AS NUMERIC(28, 8))     delivered_vol,
       MAX(
           CASE 
                WHEN sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.price
                ELSE 0
           END
       )                                price_to,
       MAX(
           CASE 
                WHEN sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.price
                ELSE 0
           END
       )                                price_from,
       MAX(sdp.pnl_currency_id)         pnl_currency_id,
       291905                           charge_type,
       MAX(CONVERT(VARCHAR(10), sdh.create_ts, 120)) create_ts,
       CAST(0.00 AS NUMERIC(28, 8))     unexplained_vol,
       CAST(0.00 AS NUMERIC(28, 8)) unexplained_mtm
INTO                                    #temp_explain_mtm
FROM   source_deal_pnl_detail sdp
       INNER JOIN #source_deal_header sdh
            ON  sdp.source_deal_header_id = sdh.source_deal_header_id
            AND (
                    sdp.pnl_as_of_date = @_as_of_date_from
                    OR sdp.pnl_as_of_date = @_as_of_date_to
                )
GROUP BY
       sdp.source_deal_header_id,
       sdp.term_start,
       sdp.term_end,
       sdp.curve_id,
       sdp.leg
HAVING SUM(
           CASE 
                WHEN sdp.pnl_as_of_date = @_as_of_date_from THEN sdp.und_pnl
                ELSE 0
           END
       ) <> 0
       OR SUM(
           CASE 
                WHEN ABS(sdh.deal_status_id) <> 5607
           AND sdp.pnl_as_of_date = @_as_of_date_to THEN sdp.und_pnl ELSE 0 END
       ) <> 0
            
                     

CREATE INDEX indx_ccc__123 ON #temp_explain_mtm(source_deal_header_id, term_start, term_end, curve_id) 
INCLUDE(new_mtm, deleted_mtm)

       -- ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Delta Collecting^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^''
       --print ''Time taken(second):'' +cast(datediff(ss,@_start_time, GETDATE()) as varchar)
SET @_start_time = GETDATE()  
       PRINT ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^''


-- Delivered Volume=Volume difference between as of date to and as of date from for not new and not deleted deals
--, if as of date to  is in between deal term start and deal term end.
--Delivered MTM: Delivered Volume* As of date from Net Price from source deal PNL detail.

UPDATE #temp_explain_mtm
SET    delivered_vol = end_vol -begin_vol,
       delivered_mtm = -1 * (end_vol -begin_vol) * price_from
WHERE  (ISNULL(deleted_vol, 0) = 0 OR ISNULL(new_vol, 0) = 0)
       AND @_as_of_date_to BETWEEN term_start AND term_end
       AND ISNULL(deleted_mtm, 0) = 0
       AND ISNULL(new_mtm, 0) = 0
  -- Price Change MTM=  Net Price difference between to as of date in source deal PNL detail* Volume of as of date from.(source deal pnl detail)

UPDATE #temp_explain_mtm
SET    price_changed_mtm = delta_price * begin_vol -delivered_mtm
WHERE  ISNULL(deleted_mtm, 0) = 0
       AND ISNULL(new_mtm, 0) = 0

       --     Modified Volume= Ending Volume-Beginning Volume-New Deals-Delivered-Deleted
       --Modified MTM=Modified Volume*(P1-P0)
              
UPDATE #temp_explain_mtm
SET    modify_vol = end_vol -(begin_vol + new_vol + deleted_vol + delivered_vol),
       modify_mtm = (
           end_mtm -(
               begin_mtm + new_mtm + deleted_mtm + delivered_mtm + 
               price_changed_mtm
           )
       )
WHERE  ISNULL(deleted_mtm, 0) = 0
       AND ISNULL(new_mtm, 0) = 0

--Unexplained Volume=If there is any volume difference.
--Unexplained MTM= If still there is any MTM difference

UPDATE #temp_explain_mtm
SET    unexplained_vol = end_vol -(
           begin_vol + new_vol + deleted_vol + delivered_vol + modify_vol
       ),
       unexplained_mtm = end_mtm -(
           begin_mtm + new_mtm + deleted_mtm + delivered_mtm + modify_mtm + 
           price_changed_mtm
       )
WHERE  end_vol -(
           begin_vol + new_vol + deleted_vol + delivered_vol + modify_vol
       ) <> 0
       OR  (
               end_mtm -(
                   begin_mtm + new_mtm + deleted_mtm + delivered_mtm + 
                   modify_mtm
               )
           ) <> 0
       AND ISNULL(deleted_mtm, 0) = 0
       AND ISNULL(new_mtm, 0) = 0

SELECT a.*,b.curve_name [curve_name],b.uom_id,su.uom_name, sc.currency_name,
       ''@as_of_date_from'' as_of_date_from,
       ''@as_of_date_to'' as_of_date_to,
       ''@sub_id'' sub_id,
       ''@stra_id'' stra_id,
       ''@book_id'' book_id,
       c1.entity_name [book],
       c2.entity_name [Strategy],
       c3.entity_name [Sub],
	   scpty.source_counterparty_id,
	   scpty.counterparty_name,
	   sdh.deal_id [reference_id],
	   ssbm.fas_deal_type_value_id [transaction_type],
	   sdv.code [transaction_type_name]
       --[__batch_report__]
FROM   #temp_explain_mtm a
       INNER JOIN source_deal_header sdh
            ON  sdh.source_deal_header_id = a.source_deal_header_id
       INNER JOIN source_system_book_map ssbm
            ON  ssbm.source_system_book_id1 = sdh.source_system_book_id1
            AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
            AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
            AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
       INNER JOIN source_price_curve_def b
            ON  a.curve_id = b.source_curve_def_id
       INNER JOIN portfolio_hierarchy c1
            ON  c1.entity_id = ssbm.fas_book_id
       INNER JOIN portfolio_hierarchy c2
            ON  c2.entity_id = c1.parent_entity_id
       INNER JOIN portfolio_hierarchy c3
            ON  c3.entity_id = c2.parent_entity_id
        LEFT JOIN source_uom AS su ON b.uom_id = su.source_uom_id
        LEFT JOIN source_currency AS sc ON a.pnl_currency_id = sc.source_currency_id
		LEFT JOIN source_counterparty scpty ON scpty.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN static_data_value sdv ON sdv.[type_id] = 400 AND ssbm.fas_deal_type_value_id = sdv.value_id' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'as_of_date_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'as_of_date_from'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'as_of_date_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date_from' AS [name], 'as_of_date_from' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'as_of_date_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'as_of_date_to'
			   , reqd_param = 1, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'as_of_date_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date_to' AS [name], 'as_of_date_to' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'begin_mtm'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'begin_mtm'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'begin_mtm'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'begin_mtm' AS [name], 'begin_mtm' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'begin_vol'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'begin_vol'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'begin_vol'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'begin_vol' AS [name], 'begin_vol' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'book'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book' AS [name], 'book' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'book_id'
			   , reqd_param = 1, widget_id = 5, datatype_id = 5, param_data_source = 'book', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'book_id' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 5 AS datatype_id, 'book' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'charge_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'charge_type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'charge_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'charge_type' AS [name], 'charge_type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'create_ts'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'create_ts'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'create_ts'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'create_ts' AS [name], 'create_ts' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'curve_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'curve_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'curve_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'curve_id' AS [name], 'curve_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'deal_status_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'deal_status_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'deal_status_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_status_id' AS [name], 'deal_status_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'deleted_mtm'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'deleted_mtm'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'deleted_mtm'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deleted_mtm' AS [name], 'deleted_mtm' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'deleted_vol'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'deleted_vol'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'deleted_vol'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deleted_vol' AS [name], 'deleted_vol' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'delivered_mtm'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'delivered_mtm'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'delivered_mtm'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delivered_mtm' AS [name], 'delivered_mtm' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'delivered_vol'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'delivered_vol'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'delivered_vol'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delivered_vol' AS [name], 'delivered_vol' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'delta_price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'delta_price'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'delta_price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'delta_price' AS [name], 'delta_price' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'end_mtm'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'end_mtm'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'end_mtm'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'end_mtm' AS [name], 'end_mtm' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'end_vol'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'end_vol'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'end_vol'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'end_vol' AS [name], 'end_vol' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'leg'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'leg'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'leg'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'leg' AS [name], 'leg' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'modify_MTM'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'modify_MTM'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'modify_MTM'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'modify_MTM' AS [name], 'modify_MTM' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'modify_vol'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'modify_vol'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'modify_vol'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'modify_vol' AS [name], 'modify_vol' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'new_mtm'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'new_mtm'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'new_mtm'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'new_mtm' AS [name], 'new_mtm' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'new_vol'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'new_vol'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'new_vol'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'new_vol' AS [name], 'new_vol' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'pnl_currency_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'pnl_currency_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'pnl_currency_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pnl_currency_id' AS [name], 'pnl_currency_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'price_changed_mtm'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'price_changed_mtm'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'price_changed_mtm'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'price_changed_mtm' AS [name], 'price_changed_mtm' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'price_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'price_from'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'price_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'price_from' AS [name], 'price_from' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'price_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'price_to'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'price_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'price_to' AS [name], 'price_to' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'source_deal_header_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'source_deal_header_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'stra_id'
			   , reqd_param = 1, widget_id = 4, datatype_id = 5, param_data_source = 'book', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'stra_id' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 5 AS datatype_id, 'book' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'Strategy'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'Strategy'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Strategy' AS [name], 'Strategy' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'Sub'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'Sub'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Sub' AS [name], 'Sub' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_id'
			   , reqd_param = 1, widget_id = 3, datatype_id = 5, param_data_source = 'book', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'sub_id' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 5 AS datatype_id, 'book' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'term_end'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'term_end' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'term_start'
			   , reqd_param = 0, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'term_start' AS ALIAS, 0 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'unexplained_mtm'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'unexplained_mtm'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'unexplained_mtm'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'unexplained_mtm' AS [name], 'unexplained_mtm' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'unexplained_vol'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'unexplained_vol'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'unexplained_vol'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'unexplained_vol' AS [name], 'unexplained_vol' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'curve_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'curve_name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'curve_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'curve_name' AS [name], 'curve_name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'uom_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'uom_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'uom_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'uom_id' AS [name], 'uom_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'uom_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'uom_name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'uom_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'uom_name' AS [name], 'uom_name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'currency_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'currency_name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'currency_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'currency_name' AS [name], 'currency_name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'counterparty_name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'counterparty_name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'reference_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'reference_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'reference_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reference_id' AS [name], 'reference_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'source_counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'source_counterparty_id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'source_counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_counterparty_id' AS [name], 'source_counterparty_id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'transaction_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'transaction_type'
			   , reqd_param = 0, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 400', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'transaction_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'transaction_type' AS [name], 'transaction_type' AS ALIAS, 0 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 400' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'PNL_Explain_View'
	            AND dsc.name =  'transaction_type_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'transaction_type_name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'PNL_Explain_View'
			AND dsc.name =  'transaction_type_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'transaction_type_name' AS [name], 'transaction_type_name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'PNL_Explain_View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'PNL_Explain_View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	