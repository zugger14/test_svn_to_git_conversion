
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_pnl_explain_view]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_pnl_explain_view]
/****** Object:  StoredProcedure [dbo].[spa_pnl_explain_view]    Script Date: 12/23/2015 9:20:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 /**
	Retrieve delta pnl explain of deals in portfolio

	Parameters : 
	@as_of_date_from : From As Of Date filter to  process
	@as_of_date_to : To As Of Date filter to  process
	@sub : Subsidiary filter to  process
	@str : Strategy filter to  process
	@term_start : Term Start filter to  process
	@term_end : Term End filter to  process
	@book : Book filter to  process
	@source_deal_header_ids : Source Deal Header Ids filter to  process
	@index : Index filter to  process
	@round : Round by value
	@batch_process_id : Process id when run through batch
	@batch_report_param : Paramater to run through barch
	@enable_paging : Enable Paging
	@page_size : Page Size
	@page_no : Page No
	@current_included : Current Included

  */

CREATE PROC [dbo].[spa_pnl_explain_view]
		@as_of_date_from         DATETIME = NULL,
		@as_of_date_to           DATETIME = NULL,
		@sub                     VARCHAR(MAX) = NULL,
		@str                     VARCHAR(MAX) = NULL,
		@term_start              DATETIME     = NULL,
		@term_end                DATETIME     = NULL,
		@book                    VARCHAR(MAX) = NULL,
		@source_deal_header_ids  VARCHAR(5000) = NULL,
		@index                   VARCHAR(200) = NULL,
		@round                   VARCHAR(1)   = NULL,
		@batch_process_id        VARCHAR(50)  = NULL,
		@batch_report_param      VARCHAR(1000)= NULL,
		@enable_paging           INT = 0      ,
		@page_size               INT = NULL   ,
		@page_no                 INT = NULL  ,	
		@current_included		 BIT = 0
AS

/*
DECLARE @as_of_date_from         DATETIME = null
DECLARE @as_of_date_to           DATETIME = '2016-01-06'
DECLARE @sub                     VARCHAR(max) = '1301,1275,1249,1188,1278,1266,1283,1305,1292,1256,1253,1315,1297,1261'
DECLARE @str                     VARCHAR(max) = '1302,1321,1323,1330,1332,1334,1276,1250,1189,1190,1281,1295,1279,1267,1268,1272,1284,1306,1293,1257,1254,1316,1298,1262,1264'
DECLARE @term_start              DATETIME     = NULL
DECLARE @term_end                DATETIME     = NULL
DECLARE @book                    VARCHAR(max) = '1303,1308,1309,1318,1319,1320,1325,1326,1327,1328,1329,1336,1337,1322,1324,1331,1333,1335,1277,1251,1274,1241,1246,1259,1243,1244,1245,1247,1248,1260,1282,1296,1280,1269,1270,1273,1285,1286,1307,1294,1313,1314,1258,1255,1317,1299,1263,1265'
DECLARE @source_deal_header_ids  VARCHAR(5000) = 35365
DECLARE @index                   VARCHAR(200) = NULL
DECLARE @round                   VARCHAR(1)   = NULL
DECLARE @batch_process_id        VARCHAR(50)  = NULL
DECLARE @batch_report_param      VARCHAR(1000)= NULL
DECLARE @enable_paging           INT = 0      
DECLARE @page_size               INT = NULL   
DECLARE @page_no                 INT = NULL  

DECLARE @current_included BIT = 1
--*/
BEGIN 


	DECLARE @_status_type VARCHAR(1)
	DECLARE @_desc VARCHAR(5000)
	DECLARE @_error_count INT 
	DECLARE @_saved_records INT
	DECLARE @_stmt VARCHAR(8000)
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
			@index_fee_breakdown_reforecast VARCHAR(300),
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
			@str_batch_table VARCHAR(MAX),
			@_begin_time DATETIME,
			@_user_login_id VARCHAR(50)
	DECLARE @_sp_name VARCHAR(100)
	DECLARE @_report_name VARCHAR(100)
	DECLARE @_is_batch BIT
	DECLARE @_sql_paging VARCHAR(8000)
	DECLARE @_tmp_date VARCHAR(10)
	DECLARE @_delivered_date DATE,
			@_job_name VARCHAR(500),
			@_spa VARCHAR(MAX),
			@_term_start_from_from DATETIME, -- for as_of_date_from
			@_term_start_from_to DATETIME, -- for as_of_date_to
			@_term_start_to_from DATETIME, -- for as_of_date_from
			@_term_start_to_to DATETIME, -- for as_of_date_to
			@insert_query VARCHAR(1000),@insert_query1 VARCHAR(MAX)
	DECLARE @_added_term VARCHAR(250),
			@_deleted_term VARCHAR(250),
			@period_from			 INT = NULL	,
			@period_to				 INT =NULL

	DECLARE @_default_holiday_id     INT,
			@_start_time             DATETIME

SET @_default_holiday_id = 291898

SET @_start_time = GETDATE()

IF @current_included = 0  
	SET @period_from = 1


EXEC spa_print @current_included

SET @_process_id = ISNULL(@batch_process_id, REPLACE(NEWID(), '-', '_'))
SET @_user_login_id = dbo.FNADBUser() 
SET @_begin_time = GETDATE()

SELECT @as_of_date_from = ISNULL(
           @as_of_date_from,
           dbo.FNAGetBusinessDay('p', @as_of_date_to, @_default_holiday_id)
       )

SET @as_of_date_to = ISNULL(@as_of_date_to, GETDATE())

IF @as_of_date_from > @as_of_date_to
    SET @as_of_date_from = @as_of_date_to
       

EXEC spa_print @as_of_date_from EXEC spa_print @period_from
    SET @_term_start_from_from = dbo.FNAGetTermStartDate('m', @as_of_date_from, @period_from)
    SET @_term_start_from_to =dbo.FNAGetTermENDDate('m', @as_of_date_from, @period_to)
    
    SET @_term_start_to_from = dbo.FNAGetTermStartDate('m', @as_of_date_to, @period_from)
    SET @_term_start_to_to = dbo.FNAGetTermENDDate('m', @as_of_date_to, @period_to)


--SELECT @period_from,@period_to,@_term_start_from_from,@_term_start_from_to,@_term_start_to_from,@_term_start_to_to,@as_of_date_to,@as_of_date_from

--RETURN

SET @_baseload_block_type = '12000' -- Internal Static Data
SELECT @_baseload_block_define_id = CAST(value_id AS VARCHAR(10))
FROM   static_data_value
WHERE  [TYPE_ID] = 10018
       AND code LIKE 'Base Load' -- External Static Data

IF @_baseload_block_define_id IS NULL
    SET @_baseload_block_define_id = 'NULL'

DECLARE @_process_id_reforecast VARCHAR(150)
SET @_process_id_reforecast = @_process_id + '_1'

IF OBJECT_ID('tempdb..#source_deal_header') IS NOT NULL
    DROP TABLE #source_deal_header

IF OBJECT_ID('tempdb..#index_temp_table') IS NOT NULL
    DROP TABLE #index_temp_table

IF OBJECT_ID('tempdb..#index_temp_result') IS NOT NULL
    DROP TABLE #index_temp_result
IF OBJECT_ID('tempdb..#index_temp_result1') IS NOT NULL
    DROP TABLE #index_temp_result1


IF OBJECT_ID('tempdb..#source_deal_header_ids') IS NOT NULL
    DROP TABLE #source_deal_header_ids

IF OBJECT_ID('tempdb..#source_deal_detail') IS NOT NULL
    DROP TABLE #source_deal_detail

IF OBJECT_ID('tempdb..#temp_explain_mtm') IS NOT NULL
    DROP TABLE #temp_explain_mtm

IF OBJECT_ID('tempdb..#book') IS NOT NULL
    DROP TABLE #book
IF OBJECT_ID('tempdb..#delivered_vol_term_level') IS NOT NULL
    DROP TABLE #delivered_vol_term_level
	
SET @_added_term = dbo.FNAProcessTableName('added_term', @_user_login_id, @_process_id)
SET @_deleted_term = dbo.FNAProcessTableName('deleted_term', @_user_login_id, @_process_id)

SET @str_batch_table = ''
SET @_is_batch = CASE 
                      WHEN @batch_process_id IS NOT NULL AND @batch_report_param 
                           IS NOT NULL THEN 1
                      ELSE 0
                 END           

IF @_is_batch = 1
    SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @_user_login_id, @batch_process_id)

IF @batch_process_id IS NULL
    SET @batch_process_id = dbo.FNAGetNewID()       
       
IF @enable_paging = 1 --paging processing
BEGIN
    SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
    
    --retrieve data from paging table instead of main table
    IF @page_no IS NOT NULL
    BEGIN
        SET @_sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)    
        EXEC (@_sql_paging) 
        RETURN
    END
END
---END Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------

SET @_st_criteria = CASE 
                         WHEN @index IS NULL THEN ''
                         ELSE ' AND delta.curve_id IN (' + @index + ')'
                    END
                     
                           
SET @_st_term = CASE 
                     WHEN @term_start IS NULL THEN ''
                     ELSE ' AND delta.term_start >= ''' + CONVERT(VARCHAR(10), @term_start, 120) 
                          + ''''
                END
    + CASE 
           WHEN @term_end IS NULL THEN ''
           ELSE ' AND delta.term_start <= ''' + CONVERT(VARCHAR(10), @term_end, 120) 
                + ''''
      END

--SET @_st_hr = CASE WHEN @_hr_from IS NULL THEN '' ELSE ' AND delta.hr>=' +CAST(@_hr_from  AS VARCHAR) END
--                   + CASE WHEN @_hr_to IS NULL THEN '' ELSE ' AND delta.hr<=' +CAST(@_hr_to  AS VARCHAR) END
       
----collect books for filtering          
CREATE TABLE #book
(
	book_deal_type_map_id      INT,
	source_system_book_id1     INT,
	source_system_book_id2     INT,
	source_system_book_id3     INT,
	source_system_book_id4     INT
)           
       
CREATE TABLE #temp_explain_mtm ( 
source_deal_header_id	int,
term_start	datetime       ,
term_end	datetime       ,
curve_id	int            ,
leg	int                    ,
deal_status_id	int        ,
begin_mtm	numeric(38,20)          ,
new_mtm	numeric(38,20)              ,
modify_MTM	numeric(38,20)        ,
deleted_mtm	numeric(38,20)          ,
delivered_mtm	numeric(38,20)   ,
price_changed_mtm	numeric(38,20),
end_mtm	numeric(38,20)              ,
begin_vol	numeric(38,20)          ,
new_vol	numeric(38,20)              ,
modify_vol	numeric(38,20)        ,
deleted_vol	numeric(38,20)          ,
end_vol	numeric(38,20)              ,
delta_price	numeric(38,20)          ,
delivered_vol	numeric(38,20)    ,
price_to	numeric(38,20)          ,
price_from	numeric(38,20)          ,
pnl_currency_id	int        ,
charge_type	int            ,
create_ts	varchar(20) COLLATE DATABASE_DEFAULT        ,
unexplained_vol	numeric(38,20)    ,
unexplained_mtm	numeric(38,20)    )

SET @_st1 = 
    'INSERT INTO #book (
                           book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
                     )             
                     SELECT book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
                     FROM source_system_book_map sbm            
                           INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
                           INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
                           INNER JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
                     WHERE 1=1  '
    + CASE 
           WHEN NULLIF(@sub, '') IS NULL THEN ''
           ELSE ' and sb.entity_id in (' + @sub + ')'
      END
    + CASE 
           WHEN NULLIF(@str, '') IS NULL THEN ''
           ELSE ' and stra.entity_id in (' + @str + ')'
      END
    + CASE 
           WHEN NULLIF(@book, '') IS NULL THEN ''
           ELSE ' and book.entity_id in (' + @book + ')'
      END
   
exec spa_print @_st1   
EXEC (@_st1)


CREATE TABLE #source_deal_header_ids
(
	source_deal_header_id INT
)
IF @source_deal_header_ids IS NULL
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
UNION ALL
SELECT source_deal_header_id
    FROM   delete_source_deal_header sdh
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
    FROM   dbo.SplitCommaSeperatedValues(@source_deal_header_ids) a
   
   --Select * FROM #source_deal_header_ids

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
WHERE  dsdh.deal_date <= @as_of_date_to
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
                           AND CONVERT(VARCHAR(10), sdh.update_ts, 120) > @as_of_date_from
                           AND CONVERT(VARCHAR(10), sdh.update_ts, 120) <= @as_of_date_to
                       )
                )
            AND sdh.deal_date <= @as_of_date_to
       INNER JOIN #source_deal_header_ids d
            ON  sdh.source_deal_header_id = d.source_deal_header_id

       
exec spa_print @_st1
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
       EXEC spa_print '*************************Explain mtm (new/delete/end/begin/delivered delta mtm).********************************'
--==============================================================================================================================


SET @insert_query = 'INSERT INTO #temp_explain_mtm(source_deal_header_id
		,term_start
		,term_end
		,curve_id
		,leg
		,deal_status_id
		,begin_mtm
		,new_mtm
		,modify_MTM
		,deleted_mtm
		,delivered_mtm
		,price_changed_mtm
		,end_mtm
		,begin_vol
		,new_vol
		,modify_vol
		,deleted_vol
		,end_vol
		,delta_price
		,delivered_vol
		,price_to
		,price_from
		,pnl_currency_id
		,charge_type
		,create_ts
		,unexplained_vol
		,unexplained_mtm)'     
SET @insert_query1 =  ' SELECT sdp.source_deal_header_id,
       sdp.term_start,
       sdp.term_end,
       sdp.curve_id,
       sdp.leg,
       ABS(MAX(sdh.deal_status_id))     deal_status_id,
       SUM(
           CASE 
                WHEN sdp.pnl_as_of_date =Convert(datetime, '+''''+ CAST(@as_of_date_from AS VARCHAR) +''''+',103) THEN sdp.und_pnl
                ELSE 0
           END
       )                                begin_mtm,
       SUM(
           CASE 
                WHEN CONVERT(VARCHAR(10), sdh.create_ts, 120) = Convert(datetime, '+''''+ CAST(@as_of_date_to AS VARCHAR) +''''+',103)
           AND sdp.pnl_as_of_date = Convert(datetime, '+''''+ CAST(@as_of_date_to AS VARCHAR) +''''+',103) THEN sdp.und_pnl ELSE 0 END
       )                                new_mtm,
       CAST(0.00 AS NUMERIC(28, 8))     modify_MTM,
       SUM(
           -1 * CASE 
                     WHEN ABS(sdh.deal_status_id) = 5607
           AND sdp.pnl_as_of_date =Convert(datetime, '+''''+ CAST(@as_of_date_from AS VARCHAR) +''''+',103)  THEN sdp.und_pnl ELSE 0 
               END
       )                                deleted_mtm,
       CAST(0.00 AS NUMERIC(28, 8))     delivered_mtm,
       CAST(0.00 AS NUMERIC(28, 8))     price_changed_mtm,
       SUM(
           CASE 
                WHEN ABS(sdh.deal_status_id) <> 5607
           AND sdp.pnl_as_of_date = Convert(datetime, '+''''+ CAST(@as_of_date_to AS VARCHAR) +''''+',103) THEN sdp.und_pnl ELSE 0 END
       )                                end_mtm,
       SUM(
           CASE 
                WHEN sdp.pnl_as_of_date = Convert(datetime, '+''''+ CAST(@as_of_date_from AS VARCHAR) +''''+',103) THEN sdp.deal_volume
                * CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END
				ELSE 0
           END
       )                                begin_vol,
       SUM(
           CASE 
                WHEN CONVERT(VARCHAR(10), sdh.create_ts, 120) = Convert(datetime, '+''''+ CAST(@as_of_date_to AS VARCHAR) +''''+',103)
           AND sdp.pnl_as_of_date = Convert(datetime, '+''''+ CAST(@as_of_date_to AS VARCHAR) +''''+',103)  THEN sdp.deal_volume 
			   * CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END
			   ELSE 0 
       END
       )                                new_vol,
       CAST(0.00 AS NUMERIC(28, 8))     modify_vol,
       SUM(
           -1 * CASE 
                     WHEN ABS(sdh.deal_status_id) = 5607
           AND sdp.pnl_as_of_date = Convert(datetime, '+''''+ CAST(@as_of_date_from AS VARCHAR) +''''+',103) THEN sdp.deal_volume 
		   * CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END
			   ELSE 0 
			   END
       )                                deleted_vol,
       SUM(
           CASE 
                WHEN ABS(sdh.deal_status_id) <> 5607
           AND sdp.pnl_as_of_date = Convert(datetime, '+''''+ CAST(@as_of_date_to AS VARCHAR) +''''+',103) THEN sdp.deal_volume  
		   * CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END
			   ELSE 0 
               END
       )                                end_vol,
       SUM(

					(ISNULL(sdp.curve_value,0) - ISNULL(sdp.formula_value,0))
				--* CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END
				* CASE 
                                                                                    WHEN 
                                                                                         sdp.pnl_as_of_date
                                                                                         = Convert(datetime, '+''''+ CAST(@as_of_date_from AS VARCHAR) +''''+',103) THEN 
                                                                                         -1 
                                                                                         
                                                                                    ELSE 
                                                                                         1 
                                                                               END
               
           
       )                                delta_price,
       CAST(0.00 AS NUMERIC(28, 8))     delivered_vol,
       sum(
           CASE 
                WHEN sdp.pnl_as_of_date = Convert(datetime, '+''''+ CAST(@as_of_date_to AS VARCHAR) +''''+',103) THEN 
						ISNULL(sdp.curve_value,0)-ISNULL(sdp.formula_value,0)-ISNULL(sdp.fixed_price,0)*ISNULL(sdp.price_multiplier,0) - ISNULL(sdp.price_adder,0)
				--* CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END
				
                ELSE 0
           END
       )                                price_to,
       sum(
           CASE 
                WHEN sdp.pnl_as_of_date = Convert(datetime, '+''''+ CAST(@as_of_date_from AS VARCHAR) +''''+',103) THEN 	
					ISNULL(sdp.curve_value,0)-ISNULL(sdp.formula_value,0)-ISNULL(sdp.fixed_price,0)*ISNULL(sdp.price_multiplier,0) - ISNULL(sdp.price_adder,0)
				--* CASE WHEN sdd.buy_sell_flag = ''s'' THEN -1 ELSE 1 END
				
                ELSE 0
           END
       )                                price_from,
       MAX(sdp.pnl_currency_id)         pnl_currency_id,
       291905                           charge_type,
       MAX(CONVERT(VARCHAR(10), sdh.create_ts, 120)) create_ts,
       CAST(0.00 AS NUMERIC(28, 8))     unexplained_vol,
       CAST(0.00 AS NUMERIC(28, 8)) unexplained_mtm

FROM   source_deal_pnl_detail sdp
       INNER JOIN #source_deal_header sdh
            ON  sdp.source_deal_header_id = sdh.source_deal_header_id
	   INNER JOIN #source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		    AND sdd.term_start = sdp.term_start and sdd.leg= sdp.leg
            AND (
                    sdp.pnl_as_of_date = Convert(datetime, '+''''+ CAST(@as_of_date_from AS VARCHAR) +''''+',103)
                    OR sdp.pnl_as_of_date = Convert(datetime, '+''''+ CAST(@as_of_date_to AS VARCHAR) +''''+',103)
                )
WHERE 1 =1  ' + CASE WHEN @period_from IS NULL AND @period_to IS NULL THEN ' ' ELSE 'AND (' END 
				 + CASE WHEN @period_from IS NOT NULL THEN 'sdp.term_start >= CONVERT(datetime,'+''''+ CAST(@_term_start_from_from AS VARCHAR)+''''+ ',103) AND' ELSE '' END
				 + CASE WHEN @period_to IS NOT NULL THEN ' sdp.term_end <= CONVERT(datetime,'+''''+ CAST(@_term_start_from_to AS VARCHAR)+''''+ ',103) AND' ELSE '' END
				 + CASE WHEN @period_from IS NULL AND @period_to IS NULL THEN ' ' ELSE  ' sdp.pnl_as_of_date =  Convert(datetime, '+''''+ CAST(@as_of_date_from AS VARCHAR) +''''+',103)) '  END 
				 + CASE WHEN @period_from IS NULL AND @period_to IS NULL THEN ' ' ELSE ' OR ( ' END 
				 + CASE WHEN @period_from IS NOT NULL THEN 'sdp.term_start >= CONVERT(datetime,'+''''+ CAST(@_term_start_to_from AS VARCHAR)+''''+ ',103) AND' ELSE '' END
				 + CASE WHEN @period_to IS NOT NULL THEN ' sdp.term_end <= CONVERT(datetime,'+''''+ CAST(@_term_start_to_to AS VARCHAR)+''''+ ',103) AND' ELSE '' END
				+  CASE WHEN @period_from IS NULL AND @period_to IS NULL THEN ' ' ELSE  '  sdp.pnl_as_of_date =  Convert(datetime, '+''''+ CAST(@as_of_date_to AS VARCHAR) +''''+',103))'  END 
			+ 	
' GROUP BY
       sdp.source_deal_header_id,
       sdp.term_start,
       sdp.term_end,
       sdp.curve_id,
       sdp.leg
HAVING SUM(
           CASE 
                WHEN sdp.pnl_as_of_date = Convert(datetime, '+''''+ CAST(@as_of_date_from AS VARCHAR) +''''+',103) THEN sdp.und_pnl
                ELSE 0
           END
       ) <> 0
       OR SUM(
           CASE 
                WHEN ABS(sdh.deal_status_id) <> 5607
           AND sdp.pnl_as_of_date =Convert(datetime, '+''''+ CAST(@as_of_date_to AS VARCHAR) +''''+',103) THEN sdp.und_pnl ELSE 0 END
       ) <> 0'
     	 exec spa_print @insert_query 
	 exec spa_print @insert_query1       

    EXEC(@insert_query+ @insert_query1)
--select * from #temp_explain_mtm where source_deal_header_id = 8
--RETURN
	
CREATE INDEX indx_ccc__123 ON #temp_explain_mtm(source_deal_header_id, term_start, term_end, curve_id) 
INCLUDE(new_mtm, deleted_mtm)

       -- '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Delta Collecting^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
       --print 'Time taken(second):' +cast(datediff(ss,@_start_time, GETDATE()) as varchar)
SET @_start_time = GETDATE()  
       EXEC spa_print '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'



-- Delivered Volume=Volume difference between as of date to and as of date from for not new and not deleted deals
--, if as of date to  is in between deal term start and deal term end.
--Delivered MTM: Delivered Volume* As of date from Net Price from source deal PNL detail.
CREATE TABLE #delivered_vol_term_level(
term_start	datetime
,term_end	datetime
,source_deal_header_id	int
,expiration_date	datetime
,delivered_vol	float
,leg INT)

SET @insert_query = '
INSERT INTO #delivered_vol_term_level (term_start
			,term_end
			,source_deal_header_id,leg
			,expiration_date
			,delivered_vol)'

SET @insert_query1 = 'Select sdd.term_start,sdd.term_end,sdd.source_deal_header_id,sdd.leg,
	MAX(rhpd.expiration_date)expiration_date,SUM(ISNULL((rhpd.hr1+rhpd.hr2+rhpd.hr3+rhpd.hr4+rhpd.hr5+rhpd.hr6+rhpd.hr7+rhpd.hr8+rhpd.hr9+rhpd.hr10+rhpd.hr11+rhpd.hr12+rhpd.hr13+rhpd.hr14+rhpd.hr15+rhpd.hr16+rhpd.hr17+rhpd.hr18+rhpd.hr19+rhpd.hr20+rhpd.hr21+rhpd.hr22+rhpd.hr23+rhpd.hr24),0)
														  +ISNULL((rhpf.hr1+rhpf.hr2+rhpf.hr3+rhpf.hr4+rhpf.hr5+rhpf.hr6+rhpf.hr7+rhpf.hr8+rhpf.hr9+rhpf.hr10+rhpf.hr11+rhpf.hr12+rhpf.hr13+rhpf.hr14+rhpf.hr15+rhpf.hr16+rhpf.hr17+rhpf.hr18+rhpf.hr19+rhpf.hr20+rhpf.hr21+rhpf.hr22+rhpf.hr23+rhpf.hr24),0)
														  +ISNULL((rhpp.hr1+rhpp.hr2+rhpp.hr3+rhpp.hr4+rhpp.hr5+rhpp.hr6+rhpp.hr7+rhpp.hr8+rhpp.hr9+rhpp.hr10+rhpp.hr11+rhpp.hr12+rhpp.hr13+rhpp.hr14+rhpp.hr15+rhpp.hr16+rhpp.hr17+rhpp.hr18+rhpp.hr19+rhpp.hr20+rhpp.hr21+rhpp.hr22+rhpp.hr23+rhpp.hr24),0))
														  delivered_vol
			 FROM source_deal_detail sdd INNER JOIN report_hourly_position_deal rhpd 
				ON rhpd.term_start BETWEEN sdd.term_start AND sdd.term_end 
			AND rhpd.source_deal_detail_id=sdd.source_deal_detail_id --AND contract_expiration_date = rhpd.expiration_date
			LEFT JOIN report_hourly_position_fixed rhpf ON rhpf.term_start BETWEEN sdd.term_start AND sdd.term_end 
				AND rhpf.source_deal_detail_id=sdd.source_deal_detail_id AND rhpf.term_start = rhpd.term_start
														  AND rhpf.expiration_date = rhpd.expiration_date
			LEFT JOIN report_hourly_position_profile rhpp ON rhpp.term_start BETWEEN sdd.term_start AND sdd.term_end 
				AND rhpp.source_deal_detail_id=sdd.source_deal_detail_id
				AND rhpp.term_start = rhpd.term_start
														  AND rhpp.expiration_date = rhpd.expiration_date
			WHERE 1=1'+ CASE WHEN @current_included = 1 THEN 'AND rhpd.expiration_date > CONVERT(DATETIME,'+''''+CAST(@as_of_date_from AS VARCHAR(20)) +''''+',103) AND rhpd.expiration_date < =  CONVERT(DATETIME,'+''''+CAST(@as_of_date_to AS VARCHAR(20)) +''''+',103)'  ELSE 
							' AND  MONTH(rhpd.expiration_date) = MONTH ('+''''+CAST(@as_of_date_to AS VARCHAR(20)) +''''+') AND  YEAR(rhpd.expiration_date) = YEAR ('+''''+CAST(@as_of_date_to AS VARCHAR(20)) +''''+') AND 
							 (YEAR('+''''+CAST(@as_of_date_from AS VARCHAR(20)) +''''+') <> YEAR ('+''''+CAST(@as_of_date_to AS VARCHAR(20)) +''''+') 
							OR  MONTH('+''''+CAST(@as_of_date_from AS VARCHAR(20)) +''''+') <> MONTH ('+''''+CAST(@as_of_date_to AS VARCHAR(20)) +''''+')) '
							END + ' 
			GROUP  BY sdd.term_start,sdd.term_end,sdd.leg,sdd.source_deal_header_id	 ' 
exec spa_print @insert_query, @insert_query1

EXEC(@insert_query+ @insert_query1)



	UPDATE tem SET tem.delivered_vol = (-1)*dvtl.delivered_vol 
				 , tem.delivered_mtm = (-1)*dvtl.delivered_vol * price_from
FROM #temp_explain_mtm tem 
		INNER JOIN  #delivered_vol_term_level dvtl 
			ON tem.source_deal_header_id = dvtl.source_deal_header_id 
				AND tem.term_start = dvtl.term_start  AND tem.term_end = dvtl.term_end
				AND tem.leg = dvtl.leg

--UPDATE #temp_explain_mtm
--SET    delivered_vol = (end_vol -begin_vol),
--       delivered_mtm = (end_vol -begin_vol) * price_from
--WHERE  (ISNULL(deleted_vol, 0) = 0 OR ISNULL(new_vol, 0) = 0)
--       AND (@as_of_date_to BETWEEN term_start AND term_end OR @as_of_date_to > term_end)
--       AND ISNULL(deleted_mtm, 0) = 0
--       AND ISNULL(new_mtm, 0) = 0

--Select * FROM #temp_explain_mtm


Select as_of_date,i.source_Deal_header_id,i.term_start,i.term_end,field_id,i.leg,CASE WHEN as_of_date = @as_of_date_to THEN 1 ELSE -1 END * price price,tem.end_vol
 INTO #index_temp_table 

FROM index_fees_breakdown i 
INNER JOIN #source_deal_header sdh ON sdh.source_deal_header_id = i.source_deal_header_id 
INNER JOIN #temp_explain_mtm tem ON tem.source_deal_header_id = sdh.source_deal_header_id 
	AND tem.term_start = i.term_start  AND tem.term_end =i.term_end
 where (as_of_date = @as_of_date_from or as_of_date = @as_of_date_to) and field_id <>-1 



 SELECT source_deal_header_id,term_start,term_end,field_id,leg,SUM(price)  * MAX(ABS(end_vol)) value
 INTO #index_temp_result1 
   FROM #index_temp_table   group by source_deal_header_id,term_start,term_end,field_id,leg
    HAVING   count(field_id) > 1 

	 SELECT source_deal_header_id,term_start,term_end,leg,SUM(value) value
 INTO #index_temp_result 
   FROM #index_temp_result1   group by source_deal_header_id,term_start,term_end,leg

 
 
  -- Price Change MTM=  Net Price difference between to as of date in source deal PNL detail* Volume of as of date from.(source deal pnl detail)
  
  	UPDATE #temp_explain_mtm
	SET    price_changed_mtm = value
   from #temp_explain_mtm tem INNER JOIN #index_temp_result itt ON 
	itt.source_deal_header_id = tem.source_deal_header_id 
	AND itt.term_start = tem.term_start 
	AND itt.term_end = tem.term_end
	WHERE  ISNULL(deleted_mtm, 0) = 0
       AND ISNULL(new_mtm, 0) = 0
AND tem.term_end > CASE WHEN @current_included = 0 THEN dbo.FNAGetFirstLastDayOfMonth(@as_of_date_to,'l') ELSE @as_of_date_to END



--UPDATE #temp_explain_mtm
--SET    price_changed_mtm = delta_price * end_vol 
--WHERE  ISNULL(deleted_mtm, 0) = 0
--       AND ISNULL(new_mtm, 0) = 0
--AND term_end > @as_of_date_to

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
EXEC spa_print @current_included
DELETE pev FROM #source_deal_header_ids s INNER JOIN 
pnl_explain_view pev ON s.source_deal_header_id = pev.source_deal_header_id
WHERE (as_of_date_from = @as_of_date_from OR as_of_date_to = @as_of_date_to) And pev.current_included = @current_included


INSERT INTO pnl_explain_view
(source_deal_header_id
,term_start
,term_end
,curve_id
,leg
,deal_status_id
,begin_mtm
,new_mtm
,modify_MTM
,deleted_mtm
,delivered_mtm
,price_changed_mtm
,end_mtm
,begin_vol
,new_vol
,modify_vol
,deleted_vol
,end_vol
,delta_price
,delivered_vol
,price_to
,price_from
,pnl_currency_id
,charge_type
,create_ts
,unexplained_vol
,unexplained_mtm
,source_curve_def_id
,source_uom_id
,source_currency_id
,as_of_date_from
,as_of_date_to
--,filter_sub_id
--,filter_stra_id
--,filter_book_id
,book_id
,Strategy_id
,Sub_id
,source_counterparty_id
,reference_id
,transaction_type_id
,transaction_type_name
,commodity_id
,sub_book_id
,deal_sub_type
,current_included,total_change_mtm,total_change_vol)
SELECT a.*,b.source_curve_def_id ,su.source_uom_id, sc.source_currency_id ,
       @as_of_date_from as_of_date_from,
       @as_of_date_to as_of_date_to,
       --@sub filter_sub_id,
       --@str filter_stra_id,
       --@book filter_book_id,
	   c1.entity_id [book_id],
       c2.entity_id [Strategy_id],
       c3.entity_id [Sub_id],
	   scpty.source_counterparty_id,
	   sdh.deal_id [reference_id],
	   ssbm.fas_deal_type_value_id [transaction_type_id],
	   sdv.code [transaction_type_name],
	   scm.source_commodity_id [commodity_id],
                        ssbm.book_deal_type_map_id [sub_book_id],
	   CASE WHEN sdts.source_deal_type_name = 'Index' AND spcd2.curve_id = 'NYMEX Monthly Settle' THEN 70 ELSE ISNULL(sdts.source_deal_type_id, 1164) END [deal_sub_type]
	  ,@current_included
	  ,(new_mtm+modify_mtm+deleted_mtm + delivered_mtm+price_changed_mtm) total_change_mtm  
	  ,(new_vol+modify_vol+deleted_vol + delivered_vol) total_change_vol

FROM   #temp_explain_mtm a
       INNER JOIN #source_deal_header sdh
            ON  sdh.source_deal_header_id = a.source_deal_header_id
       LEFT JOIN #source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	   AND a.term_start = sdd.term_start AND sdd.leg=1
       LEFT JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id = sdd.formula_curve_id
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
        LEFT JOIN source_uom AS su ON ISNULL(b.display_uom_id,b.uom_id) = su.source_uom_id
        LEFT JOIN source_currency AS sc ON a.pnl_currency_id = sc.source_currency_id
		LEFT JOIN source_counterparty scpty ON scpty.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN static_data_value sdv ON sdv.[type_id] = 400 AND ssbm.fas_deal_type_value_id = sdv.value_id
		LEFT JOIN source_commodity scm ON scm.source_commodity_id = sdh.commodity_id
		LEFT JOIN source_deal_type AS sdts ON sdts.source_deal_type_id = sdh.deal_sub_type_type_id

END


EXEC  spa_message_board 'i', 
						@_user_login_id, 
						NULL, 
						'PnL Attribute Calculation',  
						'PnL Attribute Calculation is completed.', 
						'', 
						'', 
						's', 
						''


